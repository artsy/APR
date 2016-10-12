resource "aws_elb" "apr-production-k8s" {
    name                        = "apr-production-k8s"
    subnets                     = [
                                    "${data.terraform_remote_state.infrastructure.vpc_production_public_subnet_1b_id}",
                                    "${data.terraform_remote_state.infrastructure.vpc_production_public_subnet_1c_id}",
                                    "${data.terraform_remote_state.infrastructure.vpc_production_public_subnet_1d_id}",
                                    "${data.terraform_remote_state.infrastructure.vpc_production_public_subnet_1e_id}"
                                  ]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 60
    security_groups             = [
                                    "${data.terraform_remote_state.infrastructure.vpc_production_default_sg_id}",
                                    "${data.terraform_remote_state.infrastructure.production-elb-security-group}"
                                  ]

    instances = ["${split(",", join(",", data.terraform_remote_state.substance.vpc_production_k8s_node_ids))}"]

    listener {
        lb_port            = 80
        lb_protocol        = "tcp"
        instance_port      = 30101
        instance_protocol  = "tcp"
    }

    health_check {
        healthy_threshold   = 4
        unhealthy_threshold = 2
        interval            = 30
        target              = "TCP:30101"
        timeout             = 10
    }

}

resource "aws_proxy_protocol_policy" "apr-production-k8s-proxy-protocol" {
  load_balancer = "${aws_elb.apr-production-k8s.name}"
  instance_ports = ["30101"]
}
