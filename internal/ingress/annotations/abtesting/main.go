package abtesting

import (
	"encoding/json"
	extensions "k8s.io/api/extensions/v1beta1"
	"k8s.io/ingress-nginx/internal/ingress/annotations/parser"
	"k8s.io/ingress-nginx/internal/ingress/resolver"
	"fmt"
)

type abTesting struct {
	r resolver.Resolver
}

type Rule struct {
	Type    string      `json:"type"`
	Op      string      `json:"op"`
	OpArgs  interface{} `json:"op_args"`
	GetArgs interface{} `json:"get_args,omitempty"`
}

type Backend struct {
	ServiceName string `json:"service"`
	ServicePort int    `json:"port"`
}

type Config struct {
	Rules   map[string]Rule `json:"rules"`
	Backend Backend         `json:"backend"`
}

func NewParser(r resolver.Resolver) parser.IngressAnnotation {
	return abTesting{r}
}

func checkConfig(cfg *Config) error {
	allowedOp := map[string]bool {
		"equal": true,
		"not_equal": true,
		"regex": true,
		"not_regex": true,
		"range": true,
		"not_range": true,
		"oneof": true,
		"not_oneof": true,
	}
	allowedType := map[string]bool {
		"backend": true,
		"ua": true,
		"ip": true,
		"cookie": true,
		"header": true,
		"query": true,
	}
	for _, rule := range cfg.Rules {
		if _, ok := allowedOp[rule.Op]; !ok {
			return fmt.Errorf("unknow op %v", rule.Op)
		}
		if _, ok := allowedType[rule.Type]; !ok {
			return fmt.Errorf("unknow type %v", rule.Type)
		}
	}
	return nil
}

func (s abTesting) Parse(ing *extensions.Ingress) (interface{}, error) {
	data, err := parser.GetStringAnnotation("abtesting", ing)
	if err != nil {
		return nil, err
	}
	var cfg Config
	err = json.Unmarshal([]byte(data), &cfg)
	if err != nil {
		return nil, err
	}
	err = checkConfig(&cfg)
	if err != nil {
		return nil, err
	}
	return &cfg, err
}
