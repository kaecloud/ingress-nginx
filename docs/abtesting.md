# ABTesting
## Test

    /nginx-ingress-controller --default-backend-service=ingress-nginx/default-http-backend --configmap=ingress-nginx/nginx-configuration --tcp-services-configmap=ingress-nginx/tcp-services --udp-services-configmap=ingress-nginx/udp-services --annotations-prefix=nginx.ingress.kubernetes.io --enable-dynamic-configuration --enable-ssl-chain-completion=false --enable-dynamic-certifications --enable-abtesting

## Nginx Rule Format
nginx contains a lua library to route traffic to different upstream, 
the user must specify rules for this library. the format of the rules is as follow:

    {
        "init": "r1",
        "rules": {
            "r1": {"type": "ua", "args": {"fail": "r3", "op": "regex", "op_args": "httpie(\\S+)$", "succ": "r4"}},
            "r2": {"type": "backend", "args": {"servername": "upstream1"}},
            "r3": {"type": "backend", "args": {"servername": "upstream2"}},
            "r4": {"type": "header", "args": {"op": "equal", "op_args": "user1", "get_args": "X-Uid", "succ": "r2", "fail": "r3"}
        },
    }

the valid values for `type` are:
1. `ua`: user-agnet
2. `ip`: client ip
3. `header`: http header, get_args must be header name
4. `cookie`: get_args must be the cookie name
5. `query`: query argument, `get_args` must be argument name
6. `backend`: a upstream, the args must contain servername field

the valid values for `op` are:
1. `regex`: `op_args` must be a regex pattern
2. `not_regex`: inverse op of `regex`
3. `equal`: `op_args` 
4. `not_equal`: inverse op of `equal`
5. `range`: `op_args` must be a table with the following format `{'start': xxx, 'end': xxx}`
6. `not_range`: inverse op of `range`
7. `oneof`: `op_args` must be an array
8. `not_oneof`: inverse op of `oneof`

## Ingress Annotations
if you want to enable A/B Testing for one domain, you must add an annotation named 
`abtesting` to Ingress object, the value of this annotation is a json string and
it must follow the following format

    {
        "backend": {
            "service": "new-svc",
            "port": 80
        },
        "rules": {
            "domain1": {
                "type": "ua",
                "op": "regex",
                "op_args": "xxx",
                "get_args": "xxx"
            },
            "domain2": {
                "type": "ua",
                "op": "regex",
                "op_args": "xxx",
                "get_args": "xxx"
            }
        }
    }
   
1. `backend` contains the new release's service name and port
2. `rules` specified the domains which needs to enable A/B Testing for,
the meaning of `type`, `op`, `get_args` and `op_args` are the same with nginx rules.
if traffic is matched by the rule, then it will be routed to canary release, 
otherwise it will be routed to default upstream.

ingress nginx converts the rules in annotation to rules lua library needed automatically.
