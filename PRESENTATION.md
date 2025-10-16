1. - [ ] What is Kubernetes?  https://kubernetes.io/docs/concepts/
2. - [x] Architecture
3. Live coding session
   1.  pod _[miniube]
   2. pod scheduling and binding
   2. _pod + sidecar _[miniube]_
   3. PodDisruptionBudget 
   3. pod + deployment _[miniube]_
   4. pod + deployment + service _[miniube]_
   5. pod + deployment + service + ingress _[miniube]_
   6. provision EKS cluster 
   7. pod + deployment + service _[EKS]_
   8. pod + deployment + service _[EKS]_
   9. pod + deployment + service + ingress _[EKS]_
   10. readinessProbe + livenessProbe
   10. PodDisruptionBudget
    11. service account vs IRSA (IAM Roles for Service Accounts)
   

AD 1
Kubernetes is a 
_portable_,
_extensible_,
_open source_
platform for managing containerized workloads and services,

AD 2
 * **cluster** = control plane + N (worker machines/nodes)
 * **control plane** = manages the worker nodes and the Pods in the cluster
   * components:
     * **API server** = front end for the Kubernetes control plane
     * **etcd** = key value store for all cluster data (including Secrets)
     * **kube-scheduler** = selects a node for Pods (many factors considered = e.g. affinity and anti-affinity specifications)
     * **kube-controller-manager** = runs controller processes (they are all compiled into a single binary and run in a single process)
     * **cloud-controller-manager** = runs controllers that are specific to your cloud provider (again, as single binary / process)
 * **node** = run containerized applications
    * components:
      * **kubelet** = takes a set of PodSpecs and ensures that the containers described are running and healthy
      * **kube-proxy** = a network proxy that runs on each node in your cluster, implementing part of the Kubernetes Service concept
      * **container runtime** = e.g. Docker Engine, containerd [GKE, EKS] or any other Kubernetes CRI (Container Runtime Interface) implementation.
        * **Pod** = smallest deployable unit of computing (1..N containers)

