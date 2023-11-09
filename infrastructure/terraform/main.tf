resource "yandex_kubernetes_cluster" "k8s-zonal" {
  
  name = "momo-store-k8s-cluster"
  network_id = yandex_vpc_network.momo-net.id
  
  master {
    version = var.k8s_version
    zonal {
      zone      = yandex_vpc_subnet.momo-subnet.zone
      subnet_id = yandex_vpc_subnet.momo-subnet.id
    }

  maintenance_policy {
    auto_upgrade = true
    
    maintenance_window {
      day        = "sunday"
      start_time = "02:00"
      duration   = "3h"
    }
  }
    public_ip = true

  }
  service_account_id      = yandex_iam_service_account.sa-momo-k8s.id
  node_service_account_id = yandex_iam_service_account.sa-momo-k8s.id
  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_member.vpc-public-admin,
    yandex_resourcemanager_folder_iam_member.images-puller
  ]
}

resource "yandex_vpc_network" "momo-net" {
  name = "momo-net"
}

resource "yandex_vpc_subnet" "momo-subnet" {
  v4_cidr_blocks = ["10.1.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.momo-net.id
}

resource "yandex_iam_service_account" "sa-momo-k8s" {
  name        = "sa-momo-k8s"
  description = "K8S zonal service account"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-clusters-agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  member    = "serviceAccount:${yandex_iam_service_account.sa-momo-k8s.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "vpc-public-admin" {
  # Сервисному аккаунту назначается роль "vpc.publicAdmin".
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  member    = "serviceAccount:${yandex_iam_service_account.sa-momo-k8s.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  member    = "serviceAccount:${yandex_iam_service_account.sa-momo-k8s.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.sa-momo-k8s.id}"
}
resource "yandex_kubernetes_node_group" "group" {
  cluster_id = yandex_kubernetes_cluster.k8s-zonal.id
  name       = "momo-store-k8s-nodes"
  version    = var.k8s_version

  labels = {
    "env" = "momo-store-production"
  }

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.momo-subnet.id]
    }

    resources {
      memory = var.node_memory
      cores  = var.node_cores
    }

    boot_disk {
      type = "network-hdd"
      size = 64
    }

  }

  scale_policy {
    fixed_scale {
      size = var.scale_size
    }
  }

  allocation_policy {
    location {
      zone = var.network_zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = var.node_day_maintenance
      start_time = var.node_hour_maintenance
      duration   = var.node_duration_maintenance
    }
  }
}