# Getting-Started-Terraform in GCP

This is the implementation for GCP (Google Cloud Platform) of the course: [Terraform - Getting Started on Pluralsight](https://app.pluralsight.com/library/courses/terraform-getting-started) by @github/ned1313

## Notes

* VPC Network spans all GCP regions
* A VPC can be subdivided into multiple subnetwork
* A Subnetwork is contained within a region and not in zone
* Each subnet has contiguous private IP space
* An instance is created in a subnet
* Firewall rules can be use to isolate portions of network or entire subnetworks
* Firewall rules are global resource and applies at VPC level
* Route are also global resource and applies at VPC level

## Module 5
As subnetwork is a region level resource in GCP and not a zone level resource. We can solve this module in 2 ways:
1. We create one more subnet in same region and assign to same VPC. And create new instance in this new subnet and a different zone
2. Or we can have only 1 subnetwork and create 2 different instance in separate zones

> For simplicity, we create 2 different subnetwork

We create 2 separate [instance group](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) and use load balancer module: [GoogleCloudPlatform/lb-http/google](https://registry.terraform.io/modules/GoogleCloudPlatform/lb-http/google/latest).

[HTTP Load Balancer Example](https://github.com/terraform-google-modules/terraform-google-lb-http/tree/master/examples/multi-mig-http-lb)

Note: We don't have to create new route / firewall rules as these are global resource and applies to VPC

### To Do
* Restrict access to instance only from load balancer using firewall rule
* Firewall rule: Allow anywhere to access Load balancer

## Module 6
Using following new resources:
 * [google_storage_bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) : create a new bucket, with name using [random provider](https://registry.terraform.io/providers/hashicorp/random/latest/docs)
 * [google_storage_bucket_object](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_object): upload website logo and index files
 * [google_storage_bucket_iam_binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_binding) : used this resource instead of [google_storage_bucket_iam_policy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam#google_storage_bucket_iam_policy) as this was replacing existing IAM Policy and `google_storage_bucket_iam_binding` appends to existing IAM Policy
    * using `google_storage_bucket_iam_policy` initially removed the service account access of terraform and it was complex to fix the bucket access issue
    * had to use `gsutil -i <storage-admin service account> iam set` command to reset access, which uses `impersonation` with `token service access` role
    * created a separate service account with no permission and this policy gave the required role
* In `google_compute_instance` add `service_account` block to attach the above new service account which has access to the bucket; also adding th scope `storage-full` make `gsutil` available in the instance. 

### To Do
* Log traffic data to bucket
  * write access log to bucket

