package abtesting

import (
	"testing"

	api "k8s.io/api/core/v1"
	extensions "k8s.io/api/extensions/v1beta1"
	meta_v1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/ingress-nginx/internal/ingress/annotations/parser"
	"k8s.io/ingress-nginx/internal/ingress/resolver"
)

func TestParse(t *testing.T) {
	annotationKey := parser.GetAnnotationWithPrefix("abtesting")

	ap := NewParser(&resolver.Mock{})
	if ap == nil {
		t.Fatalf("expected a parser.IngressAnnotation but returned nil")
	}

	val := `
{"backend": {"port": 80, "service": "hello-canary"},
 "rules": {
     "hello.kjy.gtapp.xyz": {"op_args": "abcdefg", "op": "equal", "type": "header", "get_args": "X-Uid"}
 }
}
`
	ann := map[string]string{annotationKey: val}
	ing := &extensions.Ingress{
		ObjectMeta: meta_v1.ObjectMeta{
			Name:      "foo",
			Namespace: api.NamespaceDefault,
		},
		Spec: extensions.IngressSpec{},
	}

	ing.SetAnnotations(ann)
	result, err := ap.Parse(ing)
	if err != nil {
		t.Errorf("Unexpected error on ingress: %v", err)
	}
	cfg := result.(*Config)
	if cfg.Backend.ServiceName != "hello-canary" ||
		cfg.Backend.ServicePort != 80 {

		t.Errorf("expected %v but returned %v, annotations: %s", "hello-canary", result, ann)
	}
}
