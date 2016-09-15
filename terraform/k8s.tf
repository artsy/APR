resource "aws_elb" "apr-production-k8s" {
    name                        = "apr-production-k8s"
    subnets                     = [
                                    "${terraform_remote_state.infrastructure.output.vpc_production_public_subnet_1b_id}",
                                    "${terraform_remote_state.infrastructure.output.vpc_production_public_subnet_1c_id}",
                                    "${terraform_remote_state.infrastructure.output.vpc_production_public_subnet_1d_id}",
                                    "${terraform_remote_state.infrastructure.output.vpc_production_public_subnet_1e_id}"
                                  ]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 60
    security_groups             = [
                                    "${terraform_remote_state.infrastructure.output.vpc_production_default_sg_id}",
                                    "${terraform_remote_state.infrastructure.output.production-elb-security-group}"
                                  ]

    instances = ["${split(",", terraform_remote_state.substance.output.vpc_production_k8s_node_ids)}"]

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

resource "aws_elb" "apr-staging-k8s" {
    name                        = "apr-staging-k8s"
    subnets                     = [
                                    "${terraform_remote_state.infrastructure.output.vpc_staging_public_subnet_1b_id}",
                                    "${terraform_remote_state.infrastructure.output.vpc_staging_public_subnet_1c_id}",
                                    "${terraform_remote_state.infrastructure.output.vpc_staging_public_subnet_1d_id}",
                                    "${terraform_remote_state.infrastructure.output.vpc_staging_public_subnet_1e_id}"
                                  ]
    cross_zone_load_balancing   = true
    idle_timeout                = 60
    connection_draining         = true
    connection_draining_timeout = 60
    security_groups             = [
                                    "${terraform_remote_state.infrastructure.output.vpc_staging_default_sg_id}",
                                    "${terraform_remote_state.infrastructure.output.staging-elb-security-group}"
                                  ]

    instances = ["${split(",", terraform_remote_state.substance.output.vpc_staging_k8s_node_ids)}"]

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

resource "aws_proxy_protocol_policy" "apr-staging-k8s-proxy-protocol" {
  load_balancer = "${aws_elb.apr-staging-k8s.name}"
  instance_ports = ["30101"]
}
