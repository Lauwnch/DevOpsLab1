module "front" {
  source = "./modules/front-end"

  vpc                 = "${ aws_vpc.project_network.id }"
  subnet              = "${ aws_subnet.public.id }"
  security_id_app     = "${ module.app.security_id }"
  security_id_bastion = "${ module.bastion.security_id }"
  security_id_db      = "${ module.database.security_id }"

  igw = "${ aws_internet_gateway.front.id }"
}

module "app" {
  source = "./modules/application-rails"

  vpc                 = "${ aws_vpc.project_network.id }"
  subnet              = "${ aws_subnet.private.id }"
  security_id_front   = "${ module.front.security_id }"
  security_id_bastion = "${ module.bastion.security_id }"
  security_id_db      = "${ module.database.security_id }"
}

module "bastion" {
  source = "./modules/bastion"

  vpc               = "${ aws_vpc.project_network.id }"
  subnet            = "${ aws_subnet.public.id }"
  security_id_front = "${ module.front.security_id }"
  security_id_app   = "${ module.app.security_id }"
  security_id_db    = "${ module.database.security_id }"
  allowed_cidrs     = ["24.92.129.23/32"]
}

module "database" {
  source = "./modules/database-mysql"

  vpc                 = "${ aws_vpc.project_network.id }"
  private_ips         = ["10.0.1.100"]
  subnet              = "${ aws_subnet.private.id }"
  security_id_front   = "${ module.front.security_id }"
  security_id_app     = "${ module.app.security_id }"
  security_id_bastion = "${ module.bastion.security_id }"
}
