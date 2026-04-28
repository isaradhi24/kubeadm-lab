
# Troubleshooting and fixing issues

Troubelshooting, debugging and fixing the cluster components, Containers, Pods are the day-to-day activity of a DevOps Engineer.

Before start debugging / troubleshooting, it is important to know what is the Pods's status, there are 3 states that a pod successfully deployed and working.

## It is important to know the basic process, how a pod gets created and works finall


You define your objects in manifests (yaml) file, as soon as you apply the manifests
```bash
	Kubectl apply -f manifestfile 
    Or 
    helm install
```
The information in the manifest file send to the master, in Control Plane, in which API Server will receive and pass it to the Controller. In this process, the first activity happens is 

	1. Assigning Pod to a worker node by Scheduler in the Master
		Kubernetes master looks at the content, desired state, that is in the manifest file
		Ex. I want a pod. 
        Now kubernetes says ok, to add pod what to do.
		Master says to Scheduler, to find out a machine (worker node) in cluster that is on the data plane,
        and ensure that it is matching the requirements of Pod.
		And on that machine the pod will be assigned fist and assign the pod to that machine.
		Only when it assigns successfully, then the next step.
        
        ## Possible issue(s): Pod not Scheduled
        ## Error Type : Pod not present / missing / scheduled

	2. Creating Container on the pod:
        Image will be downloaded for creating the container on the pod.
	    After the image downloaded, the container will be created from the image and after the container created, 
        then the container will start running the startup commands or whatever commands given to run inside the container.
	
        ## Possible issue(s) at this stage:
		    Pod scheduled but while downloading the image, there may be issue
		    Issue while container creating.
	    
        ## Error type: Pod Scheduled, Container creation Error
	
	3.  Once the image is downloaded and container is created 
        and the container started running the startup command 
        or the application inside the container
	
        ## Possible issue(s): issue with application running or the command in side application.
	    ## Error type: Container runtime error

### Troubleshooting process

The debugging process typically starts by checking the pod staus
```bash
    kubectl get pods
	kubectl describe pod  # to view events for more specific details.
```

Common scenarios ---

1. Insufficient Resources: Pods remain in a pending state due to lack of CPU or memory on available nodes

2. Node Selector/Affinity: Pods are pending because they cannot be assigned to a node that matches their required labels

3. Unbound Persistent Volume: Pods are pending as they cannot attach to a persistent volume claim due to the absence of available persistent volumes are an incorrectly configured storage class

4. Node Taint: Pods are pending because the node has a taint, preventing pods without corresponding tolerations from being scheduled on it

5. Unavailable Configmap:

6. Unavailable Secret

7. Resource Quota

8. Image Pull Back-Off: The pod moves to container creation but fails to download the image, often due to an incorrect image tag, credential issues, or permission problems.

9. CrashLoop Back-Off-OutofMemory (OOM): The container repeatedly crashes and restarts, often caused by an out-or-memory (OOM) error or a failed health check

10. CrashLoopBackoff-Healthcheck:

11. CrashLoopBackoOff-Init:

12. CrashLoopBachoff-Runtime:

13. Runtime Error-Serivce: Application Not Accessible (Service Object - missconfiguration): The application appears to be running successfully, but users cannot access it. This often indicates a misconfiguration in the Kubernetes Service object, where the service might not be correctly routing traffic to the pods due to mismatched labels.

## To reproduce the issue
run ```bash
        ./runme.sh -<option 1 - 13>
    ```