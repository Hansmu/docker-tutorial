# Managing Kubernetes Declaratively with YAML
## What “Declarative” Really Means

Declarative management means:

> You describe what the cluster should look like, not how to change it.

You don’t tell Kubernetes:
- “Scale this” 
- “Delete that pod” 
- “Restart this container”

You describe:
- “There should be 3 replicas” 
- “The image should be nginx:1.27” 
- “This service should expose port 80”

Kubernetes then reconciles reality to match your description.

---

## The Core Command

Declarative management revolves around one command:

```bash
kubectl apply -f <file-or-directory-or-url>
```

That’s it.

You run the same command repeatedly.

Kubernetes:
- Creates objects if they don’t exist 
- Updates them if they differ 
- Leaves them alone if nothing changed

This is called idempotency.

---

## Why YAML?

Kubernetes objects are defined as structured API objects.

YAML is simply a human-readable representation of those API objects.

Every Kubernetes resource has:
```yaml
apiVersion:
kind:
metadata:
spec:
```

---

## Anatomy of a Declarative YAML File

Let’s define a simple Deployment.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: my-nginx
    labels:
      app: my-nginx
spec:
    replicas: 3
    selector:
        matchLabels:
          app: my-nginx
    template:
        metadata:
            labels:
              app: my-nginx
        spec:
            containers:
                - name: nginx
                  image: nginx:1.27
                  ports:
                    - containerPort: 80
```

---

## Understanding the Structure

### apiVersion

Defines which API group and version this resource belongs to.

### kind

Defines what type of resource it is (Deployment, Service, Pod, etc.)

### metadata

Identity information:
- name 
- namespace 
- labels 
- annotations

### spec

The desired state.

This is what Kubernetes tries to enforce.

---

## Building the structure

First thing to know that there are a ton of different resources you can use.

Based on different distributions, you can get additional resources.

You can run:
```bash
kubectl api-resources
```

To get all available resources.

```text
NAME                                SHORTNAMES   APIVERSION                          NAMESPACED   KIND
bindings                                         v1                                  true         Binding
componentstatuses                   cs           v1                                  false        ComponentStatus
configmaps                          cm           v1                                  true         ConfigMap
endpoints                           ep           v1                                  true         Endpoints
events                              ev           v1                                  true         Event
limitranges                         limits       v1                                  true         LimitRange
namespaces                          ns           v1                                  false        Namespace
nodes                               no           v1                                  false        Node
persistentvolumeclaims              pvc          v1                                  true         PersistentVolumeClaim
persistentvolumes                   pv           v1                                  false        PersistentVolume
pods                                po           v1                                  true         Pod
podtemplates                                     v1                                  true         PodTemplate
replicationcontrollers              rc           v1                                  true         ReplicationController
resourcequotas                      quota        v1                                  true         ResourceQuota
secrets                                          v1                                  true         Secret
serviceaccounts                     sa           v1                                  true         ServiceAccount
services                            svc          v1                                  true         Service
mutatingwebhookconfigurations                    admissionregistration.k8s.io/v1     false        MutatingWebhookConfiguration
validatingadmissionpolicies                      admissionregistration.k8s.io/v1     false        ValidatingAdmissionPolicy
validatingadmissionpolicybindings                admissionregistration.k8s.io/v1     false        ValidatingAdmissionPolicyBinding
validatingwebhookconfigurations                  admissionregistration.k8s.io/v1     false        ValidatingWebhookConfiguration
customresourcedefinitions           crd,crds     apiextensions.k8s.io/v1             false        CustomResourceDefinition
apiservices                                      apiregistration.k8s.io/v1           false        APIService
controllerrevisions                              apps/v1                             true         ControllerRevision
daemonsets                          ds           apps/v1                             true         DaemonSet
deployments                         deploy       apps/v1                             true         Deployment
replicasets                         rs           apps/v1                             true         ReplicaSet
statefulsets                        sts          apps/v1                             true         StatefulSet
selfsubjectreviews                               authentication.k8s.io/v1            false        SelfSubjectReview
tokenreviews                                     authentication.k8s.io/v1            false        TokenReview
localsubjectaccessreviews                        authorization.k8s.io/v1             true         LocalSubjectAccessReview
selfsubjectaccessreviews                         authorization.k8s.io/v1             false        SelfSubjectAccessReview
selfsubjectrulesreviews                          authorization.k8s.io/v1             false        SelfSubjectRulesReview
subjectaccessreviews                             authorization.k8s.io/v1             false        SubjectAccessReview
horizontalpodautoscalers            hpa          autoscaling/v2                      true         HorizontalPodAutoscaler
cronjobs                            cj           batch/v1                            true         CronJob
jobs                                             batch/v1                            true         Job
certificatesigningrequests          csr          certificates.k8s.io/v1              false        CertificateSigningRequest
leases                                           coordination.k8s.io/v1              true         Lease
endpointslices                                   discovery.k8s.io/v1                 true         EndpointSlice
events                              ev           events.k8s.io/v1                    true         Event
flowschemas                                      flowcontrol.apiserver.k8s.io/v1     false        FlowSchema
prioritylevelconfigurations                      flowcontrol.apiserver.k8s.io/v1     false        PriorityLevelConfiguration
backendtlspolicies                  btlspolicy   gateway.networking.k8s.io/v1        true         BackendTLSPolicy
gatewayclasses                      gc           gateway.networking.k8s.io/v1        false        GatewayClass
gateways                            gtw          gateway.networking.k8s.io/v1        true         Gateway
grpcroutes                                       gateway.networking.k8s.io/v1        true         GRPCRoute
httproutes                                       gateway.networking.k8s.io/v1        true         HTTPRoute
referencegrants                     refgrant     gateway.networking.k8s.io/v1beta1   true         ReferenceGrant
helmchartconfigs                                 helm.cattle.io/v1                   true         HelmChartConfig
helmcharts                                       helm.cattle.io/v1                   true         HelmChart
accesscontrolpolicies                            hub.traefik.io/v1alpha1             false        AccessControlPolicy
aiservices                                       hub.traefik.io/v1alpha1             true         AIService
apiauths                                         hub.traefik.io/v1alpha1             true         APIAuth
apibundles                                       hub.traefik.io/v1alpha1             true         APIBundle
apicatalogitems                                  hub.traefik.io/v1alpha1             true         APICatalogItem
apiplans                                         hub.traefik.io/v1alpha1             true         APIPlan
apiportalauths                                   hub.traefik.io/v1alpha1             true         APIPortalAuth
apiportals                                       hub.traefik.io/v1alpha1             true         APIPortal
apiratelimits                                    hub.traefik.io/v1alpha1             true         APIRateLimit
apis                                             hub.traefik.io/v1alpha1             true         API
apiversions                                      hub.traefik.io/v1alpha1             true         APIVersion
managedapplications                              hub.traefik.io/v1alpha1             true         ManagedApplication
managedsubscriptions                             hub.traefik.io/v1alpha1             true         ManagedSubscription
addons                                           k3s.cattle.io/v1                    true         Addon
etcdsnapshotfiles                                k3s.cattle.io/v1                    false        ETCDSnapshotFile
nodes                                            metrics.k8s.io/v1beta1              false        NodeMetrics
pods                                             metrics.k8s.io/v1beta1              true         PodMetrics
ingressclasses                                   networking.k8s.io/v1                false        IngressClass
ingresses                           ing          networking.k8s.io/v1                true         Ingress
ipaddresses                         ip           networking.k8s.io/v1                false        IPAddress
networkpolicies                     netpol       networking.k8s.io/v1                true         NetworkPolicy
servicecidrs                                     networking.k8s.io/v1                false        ServiceCIDR
runtimeclasses                                   node.k8s.io/v1                      false        RuntimeClass
poddisruptionbudgets                pdb          policy/v1                           true         PodDisruptionBudget
clusterrolebindings                              rbac.authorization.k8s.io/v1        false        ClusterRoleBinding
clusterroles                                     rbac.authorization.k8s.io/v1        false        ClusterRole
rolebindings                                     rbac.authorization.k8s.io/v1        true         RoleBinding
roles                                            rbac.authorization.k8s.io/v1        true         Role
deviceclasses                                    resource.k8s.io/v1                  false        DeviceClass
resourceclaims                                   resource.k8s.io/v1                  true         ResourceClaim
resourceclaimtemplates                           resource.k8s.io/v1                  true         ResourceClaimTemplate
resourceslices                                   resource.k8s.io/v1                  false        ResourceSlice
priorityclasses                     pc           scheduling.k8s.io/v1                false        PriorityClass
csidrivers                                       storage.k8s.io/v1                   false        CSIDriver
csinodes                                         storage.k8s.io/v1                   false        CSINode
csistoragecapacities                             storage.k8s.io/v1                   true         CSIStorageCapacity
storageclasses                      sc           storage.k8s.io/v1                   false        StorageClass
volumeattachments                                storage.k8s.io/v1                   false        VolumeAttachment
volumeattributesclasses             vac          storage.k8s.io/v1                   false        VolumeAttributesClass
ingressroutes                                    traefik.io/v1alpha1                 true         IngressRoute
ingressroutetcps                                 traefik.io/v1alpha1                 true         IngressRouteTCP
ingressrouteudps                                 traefik.io/v1alpha1                 true         IngressRouteUDP
middlewares                                      traefik.io/v1alpha1                 true         Middleware
middlewaretcps                                   traefik.io/v1alpha1                 true         MiddlewareTCP
serverstransports                                traefik.io/v1alpha1                 true         ServersTransport
serverstransporttcps                             traefik.io/v1alpha1                 true         ServersTransportTCP
tlsoptions                                       traefik.io/v1alpha1                 true         TLSOption
tlsstores                                        traefik.io/v1alpha1                 true         TLSStore
traefikservices                                  traefik.io/v1alpha1                 true         TraefikService
```

The two columns that we care about when defining our YAML is the kind and apiversion columns.

For example with Deployment:

| NAME            | SHORTNAMES | APIVERSION  | NAMESPACED | KIND           |
|-----------------|------------|-------------|------------|----------------|
| **deployments** | deploy     | **apps/v1** | true       | **Deployment** |
| replicasets     | rs         | apps/v1     | true       | ReplicaSet     |

Now let's say we've decided on a Deployment. It's got a whole list of options that it can be created with.

If we'd want to see all the keys available, we can run:
```bash
# kubectl explain <resourceName> --recursive
kubectl explain deployments --recursive
```

Notice that I'm using the name to refer to it in the explain command.

There is an overwhelming amount of properties.

It's mainly useful for finding what the exact name of a property is if you already know what you want.

<details>

<summary>Output of running explain recursive</summary>

```text
FIELDS:
  apiVersion	<string>
  kind	<string>
  metadata	<ObjectMeta>
    annotations	<map[string]string>
    creationTimestamp	<string>
    deletionGracePeriodSeconds	<integer>
    deletionTimestamp	<string>
    finalizers	<[]string>
    generateName	<string>
    generation	<integer>
    labels	<map[string]string>
    managedFields	<[]ManagedFieldsEntry>
      apiVersion	<string>
      fieldsType	<string>
      fieldsV1	<FieldsV1>
      manager	<string>
      operation	<string>
      subresource	<string>
      time	<string>
    name	<string>
    namespace	<string>
    ownerReferences	<[]OwnerReference>
      apiVersion	<string> -required-
      blockOwnerDeletion	<boolean>
      controller	<boolean>
      kind	<string> -required-
      name	<string> -required-
      uid	<string> -required-
    resourceVersion	<string>
    selfLink	<string>
    uid	<string>
  spec	<DeploymentSpec>
    minReadySeconds	<integer>
    paused	<boolean>
    progressDeadlineSeconds	<integer>
    replicas	<integer>
    revisionHistoryLimit	<integer>
    selector	<LabelSelector> -required-
      matchExpressions	<[]LabelSelectorRequirement>
        key	<string> -required-
        operator	<string> -required-
        values	<[]string>
      matchLabels	<map[string]string>
    strategy	<DeploymentStrategy>
      rollingUpdate	<RollingUpdateDeployment>
        maxSurge	<IntOrString>
        maxUnavailable	<IntOrString>
      type	<string>
      enum: Recreate, RollingUpdate
    template	<PodTemplateSpec> -required-
      metadata	<ObjectMeta>
        annotations	<map[string]string>
        creationTimestamp	<string>
        deletionGracePeriodSeconds	<integer>
        deletionTimestamp	<string>
        finalizers	<[]string>
        generateName	<string>
        generation	<integer>
        labels	<map[string]string>
        managedFields	<[]ManagedFieldsEntry>
          apiVersion	<string>
          fieldsType	<string>
          fieldsV1	<FieldsV1>
          manager	<string>
          operation	<string>
          subresource	<string>
          time	<string>
        name	<string>
        namespace	<string>
        ownerReferences	<[]OwnerReference>
          apiVersion	<string> -required-
          blockOwnerDeletion	<boolean>
          controller	<boolean>
          kind	<string> -required-
          name	<string> -required-
          uid	<string> -required-
        resourceVersion	<string>
        selfLink	<string>
        uid	<string>
      spec	<PodSpec>
        activeDeadlineSeconds	<integer>
        affinity	<Affinity>
          nodeAffinity	<NodeAffinity>
            preferredDuringSchedulingIgnoredDuringExecution	<[]PreferredSchedulingTerm>
              preference	<NodeSelectorTerm> -required-
                matchExpressions	<[]NodeSelectorRequirement>
                  key	<string> -required-
                  operator	<string> -required-
                  enum: DoesNotExist, Exists, Gt, In, ....
                  values	<[]string>
                matchFields	<[]NodeSelectorRequirement>
                  key	<string> -required-
                  operator	<string> -required-
                  enum: DoesNotExist, Exists, Gt, In, ....
                  values	<[]string>
              weight	<integer> -required-
            requiredDuringSchedulingIgnoredDuringExecution	<NodeSelector>
              nodeSelectorTerms	<[]NodeSelectorTerm> -required-
                matchExpressions	<[]NodeSelectorRequirement>
                  key	<string> -required-
                  operator	<string> -required-
                  enum: DoesNotExist, Exists, Gt, In, ....
                  values	<[]string>
                matchFields	<[]NodeSelectorRequirement>
                  key	<string> -required-
                  operator	<string> -required-
                  enum: DoesNotExist, Exists, Gt, In, ....
                  values	<[]string>
          podAffinity	<PodAffinity>
            preferredDuringSchedulingIgnoredDuringExecution	<[]WeightedPodAffinityTerm>
              podAffinityTerm	<PodAffinityTerm> -required-
                labelSelector	<LabelSelector>
                  matchExpressions	<[]LabelSelectorRequirement>
                    key	<string> -required-
                    operator	<string> -required-
                    values	<[]string>
                  matchLabels	<map[string]string>
                matchLabelKeys	<[]string>
                mismatchLabelKeys	<[]string>
                namespaceSelector	<LabelSelector>
                  matchExpressions	<[]LabelSelectorRequirement>
                    key	<string> -required-
                    operator	<string> -required-
                    values	<[]string>
                  matchLabels	<map[string]string>
                namespaces	<[]string>
                topologyKey	<string> -required-
              weight	<integer> -required-
            requiredDuringSchedulingIgnoredDuringExecution	<[]PodAffinityTerm>
              labelSelector	<LabelSelector>
                matchExpressions	<[]LabelSelectorRequirement>
                  key	<string> -required-
                  operator	<string> -required-
                  values	<[]string>
                matchLabels	<map[string]string>
              matchLabelKeys	<[]string>
              mismatchLabelKeys	<[]string>
              namespaceSelector	<LabelSelector>
                matchExpressions	<[]LabelSelectorRequirement>
                  key	<string> -required-
                  operator	<string> -required-
                  values	<[]string>
                matchLabels	<map[string]string>
              namespaces	<[]string>
              topologyKey	<string> -required-
          podAntiAffinity	<PodAntiAffinity>
            preferredDuringSchedulingIgnoredDuringExecution	<[]WeightedPodAffinityTerm>
              podAffinityTerm	<PodAffinityTerm> -required-
                labelSelector	<LabelSelector>
                  matchExpressions	<[]LabelSelectorRequirement>
                    key	<string> -required-
                    operator	<string> -required-
                    values	<[]string>
                  matchLabels	<map[string]string>
                matchLabelKeys	<[]string>
                mismatchLabelKeys	<[]string>
                namespaceSelector	<LabelSelector>
                  matchExpressions	<[]LabelSelectorRequirement>
                    key	<string> -required-
                    operator	<string> -required-
                    values	<[]string>
                  matchLabels	<map[string]string>
                namespaces	<[]string>
                topologyKey	<string> -required-
              weight	<integer> -required-
            requiredDuringSchedulingIgnoredDuringExecution	<[]PodAffinityTerm>
              labelSelector	<LabelSelector>
                matchExpressions	<[]LabelSelectorRequirement>
                  key	<string> -required-
                  operator	<string> -required-
                  values	<[]string>
                matchLabels	<map[string]string>
              matchLabelKeys	<[]string>
              mismatchLabelKeys	<[]string>
              namespaceSelector	<LabelSelector>
                matchExpressions	<[]LabelSelectorRequirement>
                  key	<string> -required-
                  operator	<string> -required-
                  values	<[]string>
                matchLabels	<map[string]string>
              namespaces	<[]string>
              topologyKey	<string> -required-
        automountServiceAccountToken	<boolean>
        containers	<[]Container> -required-
          args	<[]string>
          command	<[]string>
          env	<[]EnvVar>
            name	<string> -required-
            value	<string>
            valueFrom	<EnvVarSource>
              configMapKeyRef	<ConfigMapKeySelector>
                key	<string> -required-
                name	<string>
                optional	<boolean>
              fieldRef	<ObjectFieldSelector>
                apiVersion	<string>
                fieldPath	<string> -required-
              fileKeyRef	<FileKeySelector>
                key	<string> -required-
                optional	<boolean>
                path	<string> -required-
                volumeName	<string> -required-
              resourceFieldRef	<ResourceFieldSelector>
                containerName	<string>
                divisor	<Quantity>
                resource	<string> -required-
              secretKeyRef	<SecretKeySelector>
                key	<string> -required-
                name	<string>
                optional	<boolean>
          envFrom	<[]EnvFromSource>
            configMapRef	<ConfigMapEnvSource>
              name	<string>
              optional	<boolean>
            prefix	<string>
            secretRef	<SecretEnvSource>
              name	<string>
              optional	<boolean>
          image	<string>
          imagePullPolicy	<string>
          enum: Always, IfNotPresent, Never
          lifecycle	<Lifecycle>
            postStart	<LifecycleHandler>
              exec	<ExecAction>
                command	<[]string>
              httpGet	<HTTPGetAction>
                host	<string>
                httpHeaders	<[]HTTPHeader>
                  name	<string> -required-
                  value	<string> -required-
                path	<string>
                port	<IntOrString> -required-
                scheme	<string>
                enum: HTTP, HTTPS
              sleep	<SleepAction>
                seconds	<integer> -required-
              tcpSocket	<TCPSocketAction>
                host	<string>
                port	<IntOrString> -required-
            preStop	<LifecycleHandler>
              exec	<ExecAction>
                command	<[]string>
              httpGet	<HTTPGetAction>
                host	<string>
                httpHeaders	<[]HTTPHeader>
                  name	<string> -required-
                  value	<string> -required-
                path	<string>
                port	<IntOrString> -required-
                scheme	<string>
                enum: HTTP, HTTPS
              sleep	<SleepAction>
                seconds	<integer> -required-
              tcpSocket	<TCPSocketAction>
                host	<string>
                port	<IntOrString> -required-
            stopSignal	<string>
            enum: SIGABRT, SIGALRM, SIGBUS, SIGCHLD, ....
          livenessProbe	<Probe>
            exec	<ExecAction>
              command	<[]string>
            failureThreshold	<integer>
            grpc	<GRPCAction>
              port	<integer> -required-
              service	<string>
            httpGet	<HTTPGetAction>
              host	<string>
              httpHeaders	<[]HTTPHeader>
                name	<string> -required-
                value	<string> -required-
              path	<string>
              port	<IntOrString> -required-
              scheme	<string>
              enum: HTTP, HTTPS
            initialDelaySeconds	<integer>
            periodSeconds	<integer>
            successThreshold	<integer>
            tcpSocket	<TCPSocketAction>
              host	<string>
              port	<IntOrString> -required-
            terminationGracePeriodSeconds	<integer>
            timeoutSeconds	<integer>
          name	<string> -required-
          ports	<[]ContainerPort>
            containerPort	<integer> -required-
            hostIP	<string>
            hostPort	<integer>
            name	<string>
            protocol	<string>
            enum: SCTP, TCP, UDP
          readinessProbe	<Probe>
            exec	<ExecAction>
              command	<[]string>
            failureThreshold	<integer>
            grpc	<GRPCAction>
              port	<integer> -required-
              service	<string>
            httpGet	<HTTPGetAction>
              host	<string>
              httpHeaders	<[]HTTPHeader>
                name	<string> -required-
                value	<string> -required-
              path	<string>
              port	<IntOrString> -required-
              scheme	<string>
              enum: HTTP, HTTPS
            initialDelaySeconds	<integer>
            periodSeconds	<integer>
            successThreshold	<integer>
            tcpSocket	<TCPSocketAction>
              host	<string>
              port	<IntOrString> -required-
            terminationGracePeriodSeconds	<integer>
            timeoutSeconds	<integer>
          resizePolicy	<[]ContainerResizePolicy>
            resourceName	<string> -required-
            restartPolicy	<string> -required-
          resources	<ResourceRequirements>
            claims	<[]ResourceClaim>
              name	<string> -required-
              request	<string>
            limits	<map[string]Quantity>
            requests	<map[string]Quantity>
          restartPolicy	<string>
          restartPolicyRules	<[]ContainerRestartRule>
            action	<string> -required-
            exitCodes	<ContainerRestartRuleOnExitCodes>
              operator	<string> -required-
              values	<[]integer>
          securityContext	<SecurityContext>
            allowPrivilegeEscalation	<boolean>
            appArmorProfile	<AppArmorProfile>
              localhostProfile	<string>
              type	<string> -required-
              enum: Localhost, RuntimeDefault, Unconfined
            capabilities	<Capabilities>
              add	<[]string>
              drop	<[]string>
            privileged	<boolean>
            procMount	<string>
            enum: Default, Unmasked
            readOnlyRootFilesystem	<boolean>
            runAsGroup	<integer>
            runAsNonRoot	<boolean>
            runAsUser	<integer>
            seLinuxOptions	<SELinuxOptions>
              level	<string>
              role	<string>
              type	<string>
              user	<string>
            seccompProfile	<SeccompProfile>
              localhostProfile	<string>
              type	<string> -required-
              enum: Localhost, RuntimeDefault, Unconfined
            windowsOptions	<WindowsSecurityContextOptions>
              gmsaCredentialSpec	<string>
              gmsaCredentialSpecName	<string>
              hostProcess	<boolean>
              runAsUserName	<string>
          startupProbe	<Probe>
            exec	<ExecAction>
              command	<[]string>
            failureThreshold	<integer>
            grpc	<GRPCAction>
              port	<integer> -required-
              service	<string>
            httpGet	<HTTPGetAction>
              host	<string>
              httpHeaders	<[]HTTPHeader>
                name	<string> -required-
                value	<string> -required-
              path	<string>
              port	<IntOrString> -required-
              scheme	<string>
              enum: HTTP, HTTPS
            initialDelaySeconds	<integer>
            periodSeconds	<integer>
            successThreshold	<integer>
            tcpSocket	<TCPSocketAction>
              host	<string>
              port	<IntOrString> -required-
            terminationGracePeriodSeconds	<integer>
            timeoutSeconds	<integer>
          stdin	<boolean>
          stdinOnce	<boolean>
          terminationMessagePath	<string>
          terminationMessagePolicy	<string>
          enum: FallbackToLogsOnError, File
          tty	<boolean>
          volumeDevices	<[]VolumeDevice>
            devicePath	<string> -required-
            name	<string> -required-
          volumeMounts	<[]VolumeMount>
            mountPath	<string> -required-
            mountPropagation	<string>
            enum: Bidirectional, HostToContainer, None
            name	<string> -required-
            readOnly	<boolean>
            recursiveReadOnly	<string>
            subPath	<string>
            subPathExpr	<string>
          workingDir	<string>
        dnsConfig	<PodDNSConfig>
          nameservers	<[]string>
          options	<[]PodDNSConfigOption>
            name	<string>
            value	<string>
          searches	<[]string>
        dnsPolicy	<string>
        enum: ClusterFirst, ClusterFirstWithHostNet, Default, None
        enableServiceLinks	<boolean>
        ephemeralContainers	<[]EphemeralContainer>
          args	<[]string>
          command	<[]string>
          env	<[]EnvVar>
            name	<string> -required-
            value	<string>
            valueFrom	<EnvVarSource>
              configMapKeyRef	<ConfigMapKeySelector>
                key	<string> -required-
                name	<string>
                optional	<boolean>
              fieldRef	<ObjectFieldSelector>
                apiVersion	<string>
                fieldPath	<string> -required-
              fileKeyRef	<FileKeySelector>
                key	<string> -required-
                optional	<boolean>
                path	<string> -required-
                volumeName	<string> -required-
              resourceFieldRef	<ResourceFieldSelector>
                containerName	<string>
                divisor	<Quantity>
                resource	<string> -required-
              secretKeyRef	<SecretKeySelector>
                key	<string> -required-
                name	<string>
                optional	<boolean>
          envFrom	<[]EnvFromSource>
            configMapRef	<ConfigMapEnvSource>
              name	<string>
              optional	<boolean>
            prefix	<string>
            secretRef	<SecretEnvSource>
              name	<string>
              optional	<boolean>
          image	<string>
          imagePullPolicy	<string>
          enum: Always, IfNotPresent, Never
          lifecycle	<Lifecycle>
            postStart	<LifecycleHandler>
              exec	<ExecAction>
                command	<[]string>
              httpGet	<HTTPGetAction>
                host	<string>
                httpHeaders	<[]HTTPHeader>
                  name	<string> -required-
                  value	<string> -required-
                path	<string>
                port	<IntOrString> -required-
                scheme	<string>
                enum: HTTP, HTTPS
              sleep	<SleepAction>
                seconds	<integer> -required-
              tcpSocket	<TCPSocketAction>
                host	<string>
                port	<IntOrString> -required-
            preStop	<LifecycleHandler>
              exec	<ExecAction>
                command	<[]string>
              httpGet	<HTTPGetAction>
                host	<string>
                httpHeaders	<[]HTTPHeader>
                  name	<string> -required-
                  value	<string> -required-
                path	<string>
                port	<IntOrString> -required-
                scheme	<string>
                enum: HTTP, HTTPS
              sleep	<SleepAction>
                seconds	<integer> -required-
              tcpSocket	<TCPSocketAction>
                host	<string>
                port	<IntOrString> -required-
            stopSignal	<string>
            enum: SIGABRT, SIGALRM, SIGBUS, SIGCHLD, ....
          livenessProbe	<Probe>
            exec	<ExecAction>
              command	<[]string>
            failureThreshold	<integer>
            grpc	<GRPCAction>
              port	<integer> -required-
              service	<string>
            httpGet	<HTTPGetAction>
              host	<string>
              httpHeaders	<[]HTTPHeader>
                name	<string> -required-
                value	<string> -required-
              path	<string>
              port	<IntOrString> -required-
              scheme	<string>
              enum: HTTP, HTTPS
            initialDelaySeconds	<integer>
            periodSeconds	<integer>
            successThreshold	<integer>
            tcpSocket	<TCPSocketAction>
              host	<string>
              port	<IntOrString> -required-
            terminationGracePeriodSeconds	<integer>
            timeoutSeconds	<integer>
          name	<string> -required-
          ports	<[]ContainerPort>
            containerPort	<integer> -required-
            hostIP	<string>
            hostPort	<integer>
            name	<string>
            protocol	<string>
            enum: SCTP, TCP, UDP
          readinessProbe	<Probe>
            exec	<ExecAction>
              command	<[]string>
            failureThreshold	<integer>
            grpc	<GRPCAction>
              port	<integer> -required-
              service	<string>
            httpGet	<HTTPGetAction>
              host	<string>
              httpHeaders	<[]HTTPHeader>
                name	<string> -required-
                value	<string> -required-
              path	<string>
              port	<IntOrString> -required-
              scheme	<string>
              enum: HTTP, HTTPS
            initialDelaySeconds	<integer>
            periodSeconds	<integer>
            successThreshold	<integer>
            tcpSocket	<TCPSocketAction>
              host	<string>
              port	<IntOrString> -required-
            terminationGracePeriodSeconds	<integer>
            timeoutSeconds	<integer>
          resizePolicy	<[]ContainerResizePolicy>
            resourceName	<string> -required-
            restartPolicy	<string> -required-
          resources	<ResourceRequirements>
            claims	<[]ResourceClaim>
              name	<string> -required-
              request	<string>
            limits	<map[string]Quantity>
            requests	<map[string]Quantity>
          restartPolicy	<string>
          restartPolicyRules	<[]ContainerRestartRule>
            action	<string> -required-
            exitCodes	<ContainerRestartRuleOnExitCodes>
              operator	<string> -required-
              values	<[]integer>
          securityContext	<SecurityContext>
            allowPrivilegeEscalation	<boolean>
            appArmorProfile	<AppArmorProfile>
              localhostProfile	<string>
              type	<string> -required-
              enum: Localhost, RuntimeDefault, Unconfined
            capabilities	<Capabilities>
              add	<[]string>
              drop	<[]string>
            privileged	<boolean>
            procMount	<string>
            enum: Default, Unmasked
            readOnlyRootFilesystem	<boolean>
            runAsGroup	<integer>
            runAsNonRoot	<boolean>
            runAsUser	<integer>
            seLinuxOptions	<SELinuxOptions>
              level	<string>
              role	<string>
              type	<string>
              user	<string>
            seccompProfile	<SeccompProfile>
              localhostProfile	<string>
              type	<string> -required-
              enum: Localhost, RuntimeDefault, Unconfined
            windowsOptions	<WindowsSecurityContextOptions>
              gmsaCredentialSpec	<string>
              gmsaCredentialSpecName	<string>
              hostProcess	<boolean>
              runAsUserName	<string>
          startupProbe	<Probe>
            exec	<ExecAction>
              command	<[]string>
            failureThreshold	<integer>
            grpc	<GRPCAction>
              port	<integer> -required-
              service	<string>
            httpGet	<HTTPGetAction>
              host	<string>
              httpHeaders	<[]HTTPHeader>
                name	<string> -required-
                value	<string> -required-
              path	<string>
              port	<IntOrString> -required-
              scheme	<string>
              enum: HTTP, HTTPS
            initialDelaySeconds	<integer>
            periodSeconds	<integer>
            successThreshold	<integer>
            tcpSocket	<TCPSocketAction>
              host	<string>
              port	<IntOrString> -required-
            terminationGracePeriodSeconds	<integer>
            timeoutSeconds	<integer>
          stdin	<boolean>
          stdinOnce	<boolean>
          targetContainerName	<string>
          terminationMessagePath	<string>
          terminationMessagePolicy	<string>
          enum: FallbackToLogsOnError, File
          tty	<boolean>
          volumeDevices	<[]VolumeDevice>
            devicePath	<string> -required-
            name	<string> -required-
          volumeMounts	<[]VolumeMount>
            mountPath	<string> -required-
            mountPropagation	<string>
            enum: Bidirectional, HostToContainer, None
            name	<string> -required-
            readOnly	<boolean>
            recursiveReadOnly	<string>
            subPath	<string>
            subPathExpr	<string>
          workingDir	<string>
        hostAliases	<[]HostAlias>
          hostnames	<[]string>
          ip	<string> -required-
        hostIPC	<boolean>
        hostNetwork	<boolean>
        hostPID	<boolean>
        hostUsers	<boolean>
        hostname	<string>
        hostnameOverride	<string>
        imagePullSecrets	<[]LocalObjectReference>
          name	<string>
        initContainers	<[]Container>
          args	<[]string>
          command	<[]string>
          env	<[]EnvVar>
            name	<string> -required-
            value	<string>
            valueFrom	<EnvVarSource>
              configMapKeyRef	<ConfigMapKeySelector>
                key	<string> -required-
                name	<string>
                optional	<boolean>
              fieldRef	<ObjectFieldSelector>
                apiVersion	<string>
                fieldPath	<string> -required-
              fileKeyRef	<FileKeySelector>
                key	<string> -required-
                optional	<boolean>
                path	<string> -required-
                volumeName	<string> -required-
              resourceFieldRef	<ResourceFieldSelector>
                containerName	<string>
                divisor	<Quantity>
                resource	<string> -required-
              secretKeyRef	<SecretKeySelector>
                key	<string> -required-
                name	<string>
                optional	<boolean>
          envFrom	<[]EnvFromSource>
            configMapRef	<ConfigMapEnvSource>
              name	<string>
              optional	<boolean>
            prefix	<string>
            secretRef	<SecretEnvSource>
              name	<string>
              optional	<boolean>
          image	<string>
          imagePullPolicy	<string>
          enum: Always, IfNotPresent, Never
          lifecycle	<Lifecycle>
            postStart	<LifecycleHandler>
              exec	<ExecAction>
                command	<[]string>
              httpGet	<HTTPGetAction>
                host	<string>
                httpHeaders	<[]HTTPHeader>
                  name	<string> -required-
                  value	<string> -required-
                path	<string>
                port	<IntOrString> -required-
                scheme	<string>
                enum: HTTP, HTTPS
              sleep	<SleepAction>
                seconds	<integer> -required-
              tcpSocket	<TCPSocketAction>
                host	<string>
                port	<IntOrString> -required-
            preStop	<LifecycleHandler>
              exec	<ExecAction>
                command	<[]string>
              httpGet	<HTTPGetAction>
                host	<string>
                httpHeaders	<[]HTTPHeader>
                  name	<string> -required-
                  value	<string> -required-
                path	<string>
                port	<IntOrString> -required-
                scheme	<string>
                enum: HTTP, HTTPS
              sleep	<SleepAction>
                seconds	<integer> -required-
              tcpSocket	<TCPSocketAction>
                host	<string>
                port	<IntOrString> -required-
            stopSignal	<string>
            enum: SIGABRT, SIGALRM, SIGBUS, SIGCHLD, ....
          livenessProbe	<Probe>
            exec	<ExecAction>
              command	<[]string>
            failureThreshold	<integer>
            grpc	<GRPCAction>
              port	<integer> -required-
              service	<string>
            httpGet	<HTTPGetAction>
              host	<string>
              httpHeaders	<[]HTTPHeader>
                name	<string> -required-
                value	<string> -required-
              path	<string>
              port	<IntOrString> -required-
              scheme	<string>
              enum: HTTP, HTTPS
            initialDelaySeconds	<integer>
            periodSeconds	<integer>
            successThreshold	<integer>
            tcpSocket	<TCPSocketAction>
              host	<string>
              port	<IntOrString> -required-
            terminationGracePeriodSeconds	<integer>
            timeoutSeconds	<integer>
          name	<string> -required-
          ports	<[]ContainerPort>
            containerPort	<integer> -required-
            hostIP	<string>
            hostPort	<integer>
            name	<string>
            protocol	<string>
            enum: SCTP, TCP, UDP
          readinessProbe	<Probe>
            exec	<ExecAction>
              command	<[]string>
            failureThreshold	<integer>
            grpc	<GRPCAction>
              port	<integer> -required-
              service	<string>
            httpGet	<HTTPGetAction>
              host	<string>
              httpHeaders	<[]HTTPHeader>
                name	<string> -required-
                value	<string> -required-
              path	<string>
              port	<IntOrString> -required-
              scheme	<string>
              enum: HTTP, HTTPS
            initialDelaySeconds	<integer>
            periodSeconds	<integer>
            successThreshold	<integer>
            tcpSocket	<TCPSocketAction>
              host	<string>
              port	<IntOrString> -required-
            terminationGracePeriodSeconds	<integer>
            timeoutSeconds	<integer>
          resizePolicy	<[]ContainerResizePolicy>
            resourceName	<string> -required-
            restartPolicy	<string> -required-
          resources	<ResourceRequirements>
            claims	<[]ResourceClaim>
              name	<string> -required-
              request	<string>
            limits	<map[string]Quantity>
            requests	<map[string]Quantity>
          restartPolicy	<string>
          restartPolicyRules	<[]ContainerRestartRule>
            action	<string> -required-
            exitCodes	<ContainerRestartRuleOnExitCodes>
              operator	<string> -required-
              values	<[]integer>
          securityContext	<SecurityContext>
            allowPrivilegeEscalation	<boolean>
            appArmorProfile	<AppArmorProfile>
              localhostProfile	<string>
              type	<string> -required-
              enum: Localhost, RuntimeDefault, Unconfined
            capabilities	<Capabilities>
              add	<[]string>
              drop	<[]string>
            privileged	<boolean>
            procMount	<string>
            enum: Default, Unmasked
            readOnlyRootFilesystem	<boolean>
            runAsGroup	<integer>
            runAsNonRoot	<boolean>
            runAsUser	<integer>
            seLinuxOptions	<SELinuxOptions>
              level	<string>
              role	<string>
              type	<string>
              user	<string>
            seccompProfile	<SeccompProfile>
              localhostProfile	<string>
              type	<string> -required-
              enum: Localhost, RuntimeDefault, Unconfined
            windowsOptions	<WindowsSecurityContextOptions>
              gmsaCredentialSpec	<string>
              gmsaCredentialSpecName	<string>
              hostProcess	<boolean>
              runAsUserName	<string>
          startupProbe	<Probe>
            exec	<ExecAction>
              command	<[]string>
            failureThreshold	<integer>
            grpc	<GRPCAction>
              port	<integer> -required-
              service	<string>
            httpGet	<HTTPGetAction>
              host	<string>
              httpHeaders	<[]HTTPHeader>
                name	<string> -required-
                value	<string> -required-
              path	<string>
              port	<IntOrString> -required-
              scheme	<string>
              enum: HTTP, HTTPS
            initialDelaySeconds	<integer>
            periodSeconds	<integer>
            successThreshold	<integer>
            tcpSocket	<TCPSocketAction>
              host	<string>
              port	<IntOrString> -required-
            terminationGracePeriodSeconds	<integer>
            timeoutSeconds	<integer>
          stdin	<boolean>
          stdinOnce	<boolean>
          terminationMessagePath	<string>
          terminationMessagePolicy	<string>
          enum: FallbackToLogsOnError, File
          tty	<boolean>
          volumeDevices	<[]VolumeDevice>
            devicePath	<string> -required-
            name	<string> -required-
          volumeMounts	<[]VolumeMount>
            mountPath	<string> -required-
            mountPropagation	<string>
            enum: Bidirectional, HostToContainer, None
            name	<string> -required-
            readOnly	<boolean>
            recursiveReadOnly	<string>
            subPath	<string>
            subPathExpr	<string>
          workingDir	<string>
        nodeName	<string>
        nodeSelector	<map[string]string>
        os	<PodOS>
          name	<string> -required-
        overhead	<map[string]Quantity>
        preemptionPolicy	<string>
        enum: Never, PreemptLowerPriority
        priority	<integer>
        priorityClassName	<string>
        readinessGates	<[]PodReadinessGate>
          conditionType	<string> -required-
        resourceClaims	<[]PodResourceClaim>
          name	<string> -required-
          resourceClaimName	<string>
          resourceClaimTemplateName	<string>
        resources	<ResourceRequirements>
          claims	<[]ResourceClaim>
            name	<string> -required-
            request	<string>
          limits	<map[string]Quantity>
          requests	<map[string]Quantity>
        restartPolicy	<string>
        enum: Always, Never, OnFailure
        runtimeClassName	<string>
        schedulerName	<string>
        schedulingGates	<[]PodSchedulingGate>
          name	<string> -required-
        securityContext	<PodSecurityContext>
          appArmorProfile	<AppArmorProfile>
            localhostProfile	<string>
            type	<string> -required-
            enum: Localhost, RuntimeDefault, Unconfined
          fsGroup	<integer>
          fsGroupChangePolicy	<string>
          enum: Always, OnRootMismatch
          runAsGroup	<integer>
          runAsNonRoot	<boolean>
          runAsUser	<integer>
          seLinuxChangePolicy	<string>
          seLinuxOptions	<SELinuxOptions>
            level	<string>
            role	<string>
            type	<string>
            user	<string>
          seccompProfile	<SeccompProfile>
            localhostProfile	<string>
            type	<string> -required-
            enum: Localhost, RuntimeDefault, Unconfined
          supplementalGroups	<[]integer>
          supplementalGroupsPolicy	<string>
          enum: Merge, Strict
          sysctls	<[]Sysctl>
            name	<string> -required-
            value	<string> -required-
          windowsOptions	<WindowsSecurityContextOptions>
            gmsaCredentialSpec	<string>
            gmsaCredentialSpecName	<string>
            hostProcess	<boolean>
            runAsUserName	<string>
        serviceAccount	<string>
        serviceAccountName	<string>
        setHostnameAsFQDN	<boolean>
        shareProcessNamespace	<boolean>
        subdomain	<string>
        terminationGracePeriodSeconds	<integer>
        tolerations	<[]Toleration>
          effect	<string>
          enum: NoExecute, NoSchedule, PreferNoSchedule
          key	<string>
          operator	<string>
          enum: Equal, Exists
          tolerationSeconds	<integer>
          value	<string>
        topologySpreadConstraints	<[]TopologySpreadConstraint>
          labelSelector	<LabelSelector>
            matchExpressions	<[]LabelSelectorRequirement>
              key	<string> -required-
              operator	<string> -required-
              values	<[]string>
            matchLabels	<map[string]string>
          matchLabelKeys	<[]string>
          maxSkew	<integer> -required-
          minDomains	<integer>
          nodeAffinityPolicy	<string>
          enum: Honor, Ignore
          nodeTaintsPolicy	<string>
          enum: Honor, Ignore
          topologyKey	<string> -required-
          whenUnsatisfiable	<string> -required-
          enum: DoNotSchedule, ScheduleAnyway
        volumes	<[]Volume>
          awsElasticBlockStore	<AWSElasticBlockStoreVolumeSource>
            fsType	<string>
            partition	<integer>
            readOnly	<boolean>
            volumeID	<string> -required-
          azureDisk	<AzureDiskVolumeSource>
            cachingMode	<string>
            enum: None, ReadOnly, ReadWrite
            diskName	<string> -required-
            diskURI	<string> -required-
            fsType	<string>
            kind	<string>
            enum: Dedicated, Managed, Shared
            readOnly	<boolean>
          azureFile	<AzureFileVolumeSource>
            readOnly	<boolean>
            secretName	<string> -required-
            shareName	<string> -required-
          cephfs	<CephFSVolumeSource>
            monitors	<[]string> -required-
            path	<string>
            readOnly	<boolean>
            secretFile	<string>
            secretRef	<LocalObjectReference>
              name	<string>
            user	<string>
          cinder	<CinderVolumeSource>
            fsType	<string>
            readOnly	<boolean>
            secretRef	<LocalObjectReference>
              name	<string>
            volumeID	<string> -required-
          configMap	<ConfigMapVolumeSource>
            defaultMode	<integer>
            items	<[]KeyToPath>
              key	<string> -required-
              mode	<integer>
              path	<string> -required-
            name	<string>
            optional	<boolean>
          csi	<CSIVolumeSource>
            driver	<string> -required-
            fsType	<string>
            nodePublishSecretRef	<LocalObjectReference>
              name	<string>
            readOnly	<boolean>
            volumeAttributes	<map[string]string>
          downwardAPI	<DownwardAPIVolumeSource>
            defaultMode	<integer>
            items	<[]DownwardAPIVolumeFile>
              fieldRef	<ObjectFieldSelector>
                apiVersion	<string>
                fieldPath	<string> -required-
              mode	<integer>
              path	<string> -required-
              resourceFieldRef	<ResourceFieldSelector>
                containerName	<string>
                divisor	<Quantity>
                resource	<string> -required-
          emptyDir	<EmptyDirVolumeSource>
            medium	<string>
            sizeLimit	<Quantity>
          ephemeral	<EphemeralVolumeSource>
            volumeClaimTemplate	<PersistentVolumeClaimTemplate>
              metadata	<ObjectMeta>
                annotations	<map[string]string>
                creationTimestamp	<string>
                deletionGracePeriodSeconds	<integer>
                deletionTimestamp	<string>
                finalizers	<[]string>
                generateName	<string>
                generation	<integer>
                labels	<map[string]string>
                managedFields	<[]ManagedFieldsEntry>
                  apiVersion	<string>
                  fieldsType	<string>
                  fieldsV1	<FieldsV1>
                  manager	<string>
                  operation	<string>
                  subresource	<string>
                  time	<string>
                name	<string>
                namespace	<string>
                ownerReferences	<[]OwnerReference>
                  apiVersion	<string> -required-
                  blockOwnerDeletion	<boolean>
                  controller	<boolean>
                  kind	<string> -required-
                  name	<string> -required-
                  uid	<string> -required-
                resourceVersion	<string>
                selfLink	<string>
                uid	<string>
              spec	<PersistentVolumeClaimSpec> -required-
                accessModes	<[]string>
                dataSource	<TypedLocalObjectReference>
                  apiGroup	<string>
                  kind	<string> -required-
                  name	<string> -required-
                dataSourceRef	<TypedObjectReference>
                  apiGroup	<string>
                  kind	<string> -required-
                  name	<string> -required-
                  namespace	<string>
                resources	<VolumeResourceRequirements>
                  limits	<map[string]Quantity>
                  requests	<map[string]Quantity>
                selector	<LabelSelector>
                  matchExpressions	<[]LabelSelectorRequirement>
                    key	<string> -required-
                    operator	<string> -required-
                    values	<[]string>
                  matchLabels	<map[string]string>
                storageClassName	<string>
                volumeAttributesClassName	<string>
                volumeMode	<string>
                enum: Block, Filesystem
                volumeName	<string>
          fc	<FCVolumeSource>
            fsType	<string>
            lun	<integer>
            readOnly	<boolean>
            targetWWNs	<[]string>
            wwids	<[]string>
          flexVolume	<FlexVolumeSource>
            driver	<string> -required-
            fsType	<string>
            options	<map[string]string>
            readOnly	<boolean>
            secretRef	<LocalObjectReference>
              name	<string>
          flocker	<FlockerVolumeSource>
            datasetName	<string>
            datasetUUID	<string>
          gcePersistentDisk	<GCEPersistentDiskVolumeSource>
            fsType	<string>
            partition	<integer>
            pdName	<string> -required-
            readOnly	<boolean>
          gitRepo	<GitRepoVolumeSource>
            directory	<string>
            repository	<string> -required-
            revision	<string>
          glusterfs	<GlusterfsVolumeSource>
            endpoints	<string> -required-
            path	<string> -required-
            readOnly	<boolean>
          hostPath	<HostPathVolumeSource>
            path	<string> -required-
            type	<string>
            enum: "", BlockDevice, CharDevice, Directory, ....
          image	<ImageVolumeSource>
            pullPolicy	<string>
            enum: Always, IfNotPresent, Never
            reference	<string>
          iscsi	<ISCSIVolumeSource>
            chapAuthDiscovery	<boolean>
            chapAuthSession	<boolean>
            fsType	<string>
            initiatorName	<string>
            iqn	<string> -required-
            iscsiInterface	<string>
            lun	<integer> -required-
            portals	<[]string>
            readOnly	<boolean>
            secretRef	<LocalObjectReference>
              name	<string>
            targetPortal	<string> -required-
          name	<string> -required-
          nfs	<NFSVolumeSource>
            path	<string> -required-
            readOnly	<boolean>
            server	<string> -required-
          persistentVolumeClaim	<PersistentVolumeClaimVolumeSource>
            claimName	<string> -required-
            readOnly	<boolean>
          photonPersistentDisk	<PhotonPersistentDiskVolumeSource>
            fsType	<string>
            pdID	<string> -required-
          portworxVolume	<PortworxVolumeSource>
            fsType	<string>
            readOnly	<boolean>
            volumeID	<string> -required-
          projected	<ProjectedVolumeSource>
            defaultMode	<integer>
            sources	<[]VolumeProjection>
              clusterTrustBundle	<ClusterTrustBundleProjection>
                labelSelector	<LabelSelector>
                  matchExpressions	<[]LabelSelectorRequirement>
                    key	<string> -required-
                    operator	<string> -required-
                    values	<[]string>
                  matchLabels	<map[string]string>
                name	<string>
                optional	<boolean>
                path	<string> -required-
                signerName	<string>
              configMap	<ConfigMapProjection>
                items	<[]KeyToPath>
                  key	<string> -required-
                  mode	<integer>
                  path	<string> -required-
                name	<string>
                optional	<boolean>
              downwardAPI	<DownwardAPIProjection>
                items	<[]DownwardAPIVolumeFile>
                  fieldRef	<ObjectFieldSelector>
                    apiVersion	<string>
                    fieldPath	<string> -required-
                  mode	<integer>
                  path	<string> -required-
                  resourceFieldRef	<ResourceFieldSelector>
                    containerName	<string>
                    divisor	<Quantity>
                    resource	<string> -required-
              podCertificate	<PodCertificateProjection>
                certificateChainPath	<string>
                credentialBundlePath	<string>
                keyPath	<string>
                keyType	<string> -required-
                maxExpirationSeconds	<integer>
                signerName	<string> -required-
              secret	<SecretProjection>
                items	<[]KeyToPath>
                  key	<string> -required-
                  mode	<integer>
                  path	<string> -required-
                name	<string>
                optional	<boolean>
              serviceAccountToken	<ServiceAccountTokenProjection>
                audience	<string>
                expirationSeconds	<integer>
                path	<string> -required-
          quobyte	<QuobyteVolumeSource>
            group	<string>
            readOnly	<boolean>
            registry	<string> -required-
            tenant	<string>
            user	<string>
            volume	<string> -required-
          rbd	<RBDVolumeSource>
            fsType	<string>
            image	<string> -required-
            keyring	<string>
            monitors	<[]string> -required-
            pool	<string>
            readOnly	<boolean>
            secretRef	<LocalObjectReference>
              name	<string>
            user	<string>
          scaleIO	<ScaleIOVolumeSource>
            fsType	<string>
            gateway	<string> -required-
            protectionDomain	<string>
            readOnly	<boolean>
            secretRef	<LocalObjectReference> -required-
              name	<string>
            sslEnabled	<boolean>
            storageMode	<string>
            storagePool	<string>
            system	<string> -required-
            volumeName	<string>
          secret	<SecretVolumeSource>
            defaultMode	<integer>
            items	<[]KeyToPath>
              key	<string> -required-
              mode	<integer>
              path	<string> -required-
            optional	<boolean>
            secretName	<string>
          storageos	<StorageOSVolumeSource>
            fsType	<string>
            readOnly	<boolean>
            secretRef	<LocalObjectReference>
              name	<string>
            volumeName	<string>
            volumeNamespace	<string>
          vsphereVolume	<VsphereVirtualDiskVolumeSource>
            fsType	<string>
            storagePolicyID	<string>
            storagePolicyName	<string>
            volumePath	<string> -required-
  status	<DeploymentStatus>
    availableReplicas	<integer>
    collisionCount	<integer>
    conditions	<[]DeploymentCondition>
      lastTransitionTime	<string>
      lastUpdateTime	<string>
      message	<string>
      reason	<string>
      status	<string> -required-
      type	<string> -required-
    observedGeneration	<integer>
    readyReplicas	<integer>
    replicas	<integer>
    terminatingReplicas	<integer>
    unavailableReplicas	<integer>
    updatedReplicas	<integer>
```
</details>

However, if you want to know what something actually does, then you can use:

```bash
kubectl explain deployments.spec
```

This produces something a lot more managable.

```text
GROUP:      apps
KIND:       Deployment
VERSION:    v1

FIELD: spec <DeploymentSpec>


DESCRIPTION:
    Specification of the desired behavior of the Deployment.
    DeploymentSpec is the specification of the desired behavior of the
    Deployment.
    
FIELDS:
  minReadySeconds	<integer>
    Minimum number of seconds for which a newly created pod should be ready
    without any of its container crashing, for it to be considered available.
    Defaults to 0 (pod will be considered available as soon as it is ready)

  paused	<boolean>
    Indicates that the deployment is paused.

  progressDeadlineSeconds	<integer>
    The maximum time in seconds for a deployment to make progress before it is
    considered to be failed. The deployment controller will continue to process
    failed deployments and a condition with a ProgressDeadlineExceeded reason
    will be surfaced in the deployment status. Note that progress will not be
    estimated during the time a deployment is paused. Defaults to 600s.

  replicas	<integer>
    Number of desired pods. This is a pointer to distinguish between explicit
    zero and not specified. Defaults to 1.

  revisionHistoryLimit	<integer>
    The number of old ReplicaSets to retain to allow rollback. This is a pointer
    to distinguish between explicit zero and not specified. Defaults to 10.

  selector	<LabelSelector> -required-
    Label selector for pods. Existing ReplicaSets whose pods are selected by
    this will be the ones affected by this deployment. It must match the pod
    template's labels.

  strategy	<DeploymentStrategy>
    The deployment strategy to use to replace existing pods with new ones.

  template	<PodTemplateSpec> -required-
    Template describes the pods that will be created. The only allowed
    template.spec.restartPolicy value is "Always".
```

Then you can continue drilling down. 

For example:

```bash
kubectl explain deployments.spec.strategy
```

```text
GROUP:      apps
KIND:       Deployment
VERSION:    v1

FIELD: strategy <DeploymentStrategy>


DESCRIPTION:
    The deployment strategy to use to replace existing pods with new ones.
    DeploymentStrategy describes how to replace existing pods with new ones.
    
FIELDS:
  rollingUpdate	<RollingUpdateDeployment>
    Rolling update config params. Present only if DeploymentStrategyType =
    RollingUpdate.

  type	<string>
  enum: Recreate, RollingUpdate
    Type of deployment. Can be "Recreate" or "RollingUpdate". Default is
    RollingUpdate.
    
    Possible enum values:
     - `"Recreate"` Kill all existing pods before creating new ones.
     - `"RollingUpdate"` Replace the old ReplicaSets by new one using rolling
    update i.e gradually scale down the old ReplicaSets and scale up the new
    one.

```

But of course, you can get all of this data from the docs as well.

For example: https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/

### apiVersion

This relates to the versions that you see when listing all the resources.

So each kind has a different version.

With the above example of Deployment, we'd need `apps/v1`.

With same cases, you'll see multiple different versions for the same resources.

In this case, you'll need to do some research to decide what to choose.

### kind

Referring to the above table, we'd want `Deployment`.

### metadata

Add what you need to identify it.

### spec

This means looking into the doc a bit deeper, because it often differs between resources.

---

## Dry runs and diffs

Dry running can be used to see what already exists and what's going to happen.

It shows if things will be changed or not.

```bash
kubectl apply -f deployments-example.yml
```

A better command would be to get a visual diff:
```bash
kubectl diff -f deployments-example.yml
```

```text
--- /tmp/LIVE-3817713164/apps.v1.Deployment.default.my-nginx
+++ /tmp/MERGED-2552125940/apps.v1.Deployment.default.my-nginx
@@ -0,0 +1,43 @@
+apiVersion: apps/v1
+kind: Deployment
+metadata:
+  creationTimestamp: "2026-02-27T07:03:10Z"
+  generation: 1
+  labels:
+    app: my-nginx
+  name: my-nginx
+  namespace: default
+  uid: d176b1a3-4a6d-4418-a76f-a182efa774cb
+spec:
+  progressDeadlineSeconds: 600
+  replicas: 3
+  revisionHistoryLimit: 10
+  selector:
+    matchLabels:
+      app: my-nginx
+  strategy:
+    rollingUpdate:
+      maxSurge: 25%
+      maxUnavailable: 25%
+    type: RollingUpdate
+  template:
+    metadata:
+      labels:
+        app: my-nginx
+    spec:
+      containers:
+      - image: nginx:1.27
+        imagePullPolicy: IfNotPresent
+        name: nginx
+        ports:
+        - containerPort: 80
+          protocol: TCP
+        resources: {}
+        terminationMessagePath: /dev/termination-log
+        terminationMessagePolicy: File
+      dnsPolicy: ClusterFirst
+      restartPolicy: Always
+      schedulerName: default-scheduler
+      securityContext: {}
+      terminationGracePeriodSeconds: 30
+status: {}
```

So this would be when nothing has been created.

But if we'd change the label, for example, after it already exists.

```text
--- /tmp/LIVE-1475523243/apps.v1.Deployment.default.my-nginx
+++ /tmp/MERGED-1603368948/apps.v1.Deployment.default.my-nginx
@@ -8,7 +8,7 @@
   creationTimestamp: "2026-02-27T07:04:23Z"
   generation: 1
   labels:
-    app: my-nginx
+    app: other-nginx
   name: my-nginx
   namespace: default
   resourceVersion: "10468"
```

---

## Labels and label selectors

Labels go under metadata in the YAML.

Simple list of `key: value` for identifying your resource later.

Common example:
```yaml
tier: frontend
app: api
env: prod
customer: acme.co
```

You can do all sorts of filtering with it, even with apply commands to only apply parts of the file.
```bash
kubectl apply -f myfile.yaml -l app=nginx
```

But filtering isn't the only use case. There are resources that talk to other resources.

Labels can become the glue for resources to know what resources to communicate to. For example telling Services and Deployments which pods are theirs.

Many resources use Label Selectors to "link" resource dependencies.

Use Labels and Selectors to control which pods go to which nodes.

They aren't meant to hold complex, large, or non-identify info, which is what annotations are for.

Annotations are often used to store config data. Things that actually talks to Kubernetes.

---

## Applying the YAML

Apply it:
```bash
kubectl apply -f deployments-example.yml
```

Check:

```bash
kubectl get deploy
kubectl get pods
```

---

## Updating Declaratively

Now change:
```bash
replicas: 3
```

to:

```bash
replicas: 5
```

Reapply:
```bash
kubectl apply -f deployment.yaml
```

You did not run `kubectl scale`.

You changed the desired state.

Kubernetes notices the difference and reconciles.

---

## Managing Multiple Resources

You can define multiple resources in one file:

```yaml
---
apiVersion: apps/v1
kind: Deployment
...

---
apiVersion: v1
kind: Service
...
```

Notice that there are dashes (`---`) being used to separate the resources.

Or use a directory:
```bash
kubectl apply -f ./manifests/
```

This is very common in real projects.

---

## Deleting Declaratively

To remove resources defined in a file:
```bash
kubectl delete -f deployment.yaml
```

Important:

Deletion is still explicit.

Kubernetes will not delete something just because it disappeared from your file (unless using GitOps controllers).

---

## Inspecting Differences Before Applying

You can preview changes:

```bash
kubectl diff -f deployment.yaml
```

This shows what will change before applying.

Very useful in production.

---

## Declarative vs Imperative Difference (Very Important)

Imperative:
```bash
kubectl scale deployment my-nginx --replicas=5
```

Declarative:

```yaml
replicas: 5
```
```bash
kubectl apply -f deployment.yaml
```

Imperative changes the live object.

Declarative changes the desired state source of truth.

---

## Source of Truth Principle

In declarative workflows:

> The YAML files in Git are the source of truth.

The cluster is a reflection of Git.

If someone edits the cluster manually (`kubectl edit`), that change should be reverted by reapplying YAML.

---

## Field Ownership and apply

`kubectl apply` tracks which fields it manages.

This prevents overwriting fields owned by other managers.

You can see managed fields:

```bash
kubectl get deploy my-nginx -o yaml
```

Look for:

```yaml
managedFields:
```

This is part of Kubernetes’ server-side apply mechanism.

---

## Recommended Production Pattern
1. Store YAML in Git
2. Review changes via Pull Request
3. Apply via CI/CD
4. Never manually edit production objects
5. Use kubectl apply consistently

This prevents configuration drift.

---

## Common Beginner Mistakes

### Editing live objects with `kubectl edit`

You create divergence from your YAML.

---

### Mixing imperative and declarative

Example:
- Scale manually
- YAML still says 3 replicas
- Next apply reverts scaling

---

### Forgetting labels/selectors consistency

Deployment selector must match pod template labels.

---

## Mental Model

Declarative Kubernetes is not:

> “Run this command to do something.”

It is:

> “Make the system look like this.”

Kubernetes is a continuous reconciliation engine.

---

## Minimal Declarative Workflow
1. Write YAML
2. `kubectl apply -f`
3. `kubectl get`
4. Adjust YAML
5. Apply again

Repeat forever.