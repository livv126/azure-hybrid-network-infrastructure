# 🌍 Hybrid Cloud Architecture
> **프로젝트 목표:** 퍼블릭 클라우드(Azure)의 유연성과 온프레미스의 보안 통제력을 결합한 하이브리드 인프라 구축

![Terraform](https://img.shields.io/badge/Terraform-v1.5+-623CE4?logo=terraform)
![Azure](https://img.shields.io/badge/Azure-Korea_Central-0078D4?logo=microsoftazure)
![Architecture](https://img.shields.io/badge/Architecture-Hybrid_Cloud-orange)
![Security](https://img.shields.io/badge/Security-Zero_Trust-red)

## 1. 프로젝트 개요
단순한 클라우드 마이그레이션을 넘어, 물리 인프라(On-premise)의 보안성과 퍼블릭 클라우드(Azure)의 확장성을 동시에 충족하는 하이브리드 클라우드 시스템을 IaC(Terraform)로 구현함.

웹 서비스(WordPress) 프론트엔드는 클라우드(VMSS)에 배치하여 트래픽 변화에 탄력적으로 대응하고, 보안이 중요한 핵심 데이터(MySQL, Elasticsearch)는 온프레미스 사설망에 격리하여 기업 데이터 주권을 확보함. 허브-스포크(Hub-Spoke) 네트워크 구조와 Site-to-Site VPN을 기반으로 모든 통신을 중앙에서 통제하는 제로 트러스트(Zero Trust) 보안 전략을 적용함.

---

## 2. 아키텍처 구성도

외부 사용자는 Azure DMZ 영역의 WAF를 거쳐 클라우드 웹 서버에 접속하며, 웹 서버는 S2S VPN 터널과 온프레미스 방화벽을 통과해야만 내부 DB에 접근할 수 있는 심층 방어 구조.

~~~mermaid
graph LR
    User((User)) -->|HTTP/HTTPS| PIP[App Gateway PIP]
    
    subgraph "Azure Cloud (Korea Central)"
        direction TB
        AGW[App Gateway <br/> Regional WAF]
        ILB[Internal LB]
        VMSS[Web Server VMSS <br/> Auto Scaling]
        VPNGW[VPN Gateway <br/> RouteBased]
        
        PIP --> AGW
        AGW -->|Backend Routing| ILB
        ILB --> VMSS
        VMSS -->|UDR: Force Tunneling| VPNGW
    end
    
    subgraph "S2S VPN Tunnel"
        VPNGW <===>|IPsec IKEv2 / AES256| NGF
    end
    
    subgraph "On-Premises Data Center"
        direction TB
        NGF[BlueMax NGF100 <br/> 방화벽]
        DB[(MySQL)]
        ES[(Elasticsearch)]
        Logstash[Logstash]
        Kibana[Kibana]
        
        NGF -->|Allow Internal Only| DB
        NGF -->|Allow Internal Only| ES
        Logstash -.->|Pull Slow Queries| DB
        Logstash -.-> ES
    end
~~~

---

## 3. 핵심 기술 및 구현 논리

### 1. 온프레미스 보안 및 통합 관제 (On-Premise Security & Observability)
* **물리 방화벽(BlueMax NGF100) 기반 경계 보안**
    * 클라우드로부터 유입되는 SQL 질의 패킷을 실시간 탐지하고, 인가된 Azure 내부망 IP 대역만 선별적으로 허용(Allow)하여 데이터베이스 접근을 엄격히 통제함.
* **ELK Stack을 활용한 하이브리드 모니터링**
    * Logstash를 구성하여 온프레미스 MySQL의 슬로우 쿼리(Slow Query) 및 에러 로그를 수집하고, Elasticsearch에 적재함.
    * 물리적으로 분리된 두 환경(Azure-Onprem)의 트래픽 패턴과 장애 로그를 Kibana 대시보드에서 단일 뷰(Single Pane of Glass)로 시각화하여 운영 가시성 극대화.

### 2. 하이브리드 네트워크 연동 (Site-to-Site VPN)
* **사설망 수준의 보안 연결**
    * 공용 인터넷을 통과하지만 IPsec VPN(IKEv2)을 통해 전 구간 암호화 통신 수행.
    * 이기종 장비 간 호환성을 위해 Terraform 코드 내에 IPsec 정책(AES256, SHA256 등)을 명시적으로 선언함.
* **게이트웨이 전송 (Gateway Transit)**
    * VNet Peering 시 `allow_gateway_transit` 옵션을 활성화하여, Spoke(App) 네트워크가 Hub의 VPN 게이트웨이를 공유하도록 구성.

### 3. 제로 트러스트 및 강제 라우팅 (Force Tunneling)
* **아웃바운드 트래픽 통제**
    * UDR(사용자 정의 경로)을 구성하여 App 서브넷에서 온프레미스 DB(192.168.20.0/24)로 향하는 패킷이 반드시 Hub의 VPN 게이트웨이를 경유하도록 강제 라우팅함.
* **마이크로 세그먼테이션 (NSG)**
    * 관리용 SSH(22) 접속은 인터넷 전면 개방을 차단하고, Hub의 Bastion 서브넷 및 신뢰할 수 있는 온프레미스 대역에서만 접근 가능하도록 NSG 정책 수립.

---

## 4. 기술 스택

| 구분 | 기술 스택 | 활용 내용 |
|:---:|:---|:---|
| **IaC** | Terraform | 기능별 모듈(Policy, Hub, App, DMZ) 기반 인프라 코드화 배포 |
| **Regional LB** | App Gateway | 외부 진입점 역할 및 2차 방어(WAF) 수행 |
| **Compute** | VM Scale Set | Rocky Linux 9 기반 웹 서버 오토스케일링 클러스터 |
| **Database** | MySQL / Elasticsearch | 온프레미스 내부에 격리 배치하여 핵심 데이터 주권 보호 |
| **Security** | BlueMax NGF100 / NSG | 온프레미스 진입점 방화벽 및 Azure 서브넷 L3/L4 제어 |
| **Monitoring** | Log Analytics / ELK Stack | 통합 로그 수집 및 하이브리드 인프라 실시간 가시성(Kibana) 확보 |

---

## 5. 트러블슈팅 및 설계 의도

### Q1. 클라우드 웹 서버와 온프레미스 DB를 분리한 이유는?
> **설계 의도: 데이터 주권 및 유연성 동시 확보**
> 클라우드의 확장성은 누리되 핵심 데이터(포스팅 및 사용자 정보)의 외부 유출 위험을 원천 차단하기 위함. 이를 위해 데이터는 물리적 통제망(On-Premise) 내 MySQL에 안전하게 저장하고, 웹 프론트엔드만 클라우드(VMSS)에 배치하여 트래픽 부하를 분산함.

### Q2. 물리 장비(BlueMax)와 Azure VPN 간 터널링 구성 시 호환성 문제는 없었나?
> **해결 방법: IPsec/IKE 암호화 정책 명시적 적용 및 통일**
> 이기종 벤더 장비 연동 시 IKE Phase 1/2 협상 단계에서 기본 정책 충돌이 잦음. 이를 방지하기 위해 Terraform `ipsec_policy` 블록에 IKE 암호화(AES256), 무결성(SHA256), DH 그룹 등을 온프레미스 방화벽 설정과 1:1로 매핑하여 안정적인 터널링(ESTABLISHED 상태)을 확보함.

### Q3. 하위 모듈에서 네트워크 대역을 직접 정의하지 않고 Root에서 주입한 이유는?
> **설계 의도: 모듈 간 순환 참조 방지 및 재사용성 향상**
> 여러 모듈(Hub, App, DMZ)이 서로를 참조할 때 발생하는 의존성 오류(Circular Dependency)를 피하기 위해, Root 모듈의 `locals`에서 네트워크 대역(CIDR)을 사전 계산하고 하위 모듈에 변수로 주입(Injection)하는 구조를 채택함.

---

## 6. 프로젝트 한계점 및 개선 방향 (Limitations)

비용 및 일정 제약으로 인해 발생한 아키텍처 한계점과, 실제 상용(Production) 환경 도입 시 요구되는 보완 사항을 다음과 같이 정리함.

* **네트워크 단일 장애점(SPOF) 존재**
  * **현황**: 클라우드 비용 절감을 위해 VPN Gateway를 단일 구성(`active_active = false`)으로 배포함. 게이트웨이 장애 시 하이브리드 통신이 전면 단절되는 아키텍처적 한계 존재.
  * **개선**: 데이터 트래픽 증가에 따른 병목 현상 방지 및 안정적인 서비스 연속성(HA) 확보를 위해, BGP 동적 라우팅 기반의 Active-Active VPN 구성 또는 대용량 전용선(Azure ExpressRoute) 연동 구조로 전환 필요.

* **Terraform State 관리의 한계**
  * **현황**: 소규모 팀 프로젝트 특성상 Terraform State 파일을 로컬 환경에서 관리함.
  * **개선**: 실무 환경에서 다수 엔지니어 협업 시 동시 작업으로 인한 설정 충돌을 방지하기 위해, Azure Storage Account 기반의 Remote Backend 구축 및 State Lock 적용 필요.

* **수동 프로비저닝에 따른 운영 리스크**
  * **현황**: 인프라 형상 변경 시 로컬 환경에서 CLI 기반 수동 배포(`terraform apply`) 수행.
  * **개선**: 휴먼 에러를 방지하고 체계적인 인프라 형상 관리를 유지하기 위해, GitHub Actions 등을 활용한 IaC 자동 검증(Plan) 및 배포(Apply) 파이프라인(CI/CD) 구축 필요.
