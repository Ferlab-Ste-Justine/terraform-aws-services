# fsx_lustre module

Provisions an **FSx for Lustre PERSISTENT_2 SSD** file system, its own
security group, and an arbitrary number of **Data Repository
Associations** to S3.

Designed for shared scratch + reference storage for Nextflow pipelines on
EKS at the 100-1000-pod scale.

## Why SSD (not Intelligent-Tiering)

- AWS rejects DRA creation on Intelligent-Tiering with
  `UnsupportedOperation: Cannot create data repository association for
  file system with 'INTELLIGENT_TIERING' storage type.` IT internally
  uses S3 as a tier (invisible to the customer), which conflicts with
  customer-managed DRA buckets.
- The user requirement here is **S3-as-bucket** (DRA), so SSD is the
  only option that works.
- On SSD, throughput scales with capacity: baseline =
  `storage_capacity x per_unit_storage_throughput / 1024` MBps.

## What it creates

- `aws_fsx_lustre_file_system.this` - PERSISTENT_2 / SSD with
  `storage_capacity` and `per_unit_storage_throughput` set.
- `aws_security_group.fsx` - attached to the file system's ENIs. Owns
  self-ingress on Lustre's TCP 988 (LNet) and 1018-1023 (aux). The caller
  adds an ingress rule on the same ports from its client SG.
- `aws_fsx_data_repository_association.this` - one per entry in the
  caller-supplied `data_repository_associations` map.

## How callers mount it

```yaml
apiVersion: v1
kind: PersistentVolume
spec:
  accessModes: [ReadWriteMany]
  csi:
    driver: fsx.csi.aws.com
    volumeHandle: <output.file_system_id>
    volumeAttributes:
      dnsname: <output.dns_name>
      mountname: <output.mount_name>
```

The FSx CSI driver (chart `aws-fsx-csi-driver`, kubernetes-sigs) handles
the mount. EKS Auto Mode nodes run Bottlerocket, which ships with the
Lustre client.

## Inputs (highlights)

| Name | Type | Default | Notes |
|---|---|---|---|
| `file_system_name` | `string` | - | Name tag and SG-name prefix. The AWS-side `fs-XXXX` is auto-generated. |
| `vpc_id` | `string` | - | |
| `subnet_id` | `string` | - | **Single** subnet. FSx Lustre is mono-AZ. |
| `storage_capacity` | `number` | `4800` | GiB. Multiples of 1200 (i.e. 1.2 TiB increments). |
| `per_unit_storage_throughput` | `number` | `500` | MB/s/TiB. One of `125`, `250`, `500`, `1000`. |
| `data_compression_type` | `string` | `LZ4` | `LZ4` or `NONE`. |
| `data_repository_associations` | `map(object)` | `{}` | See variables.tf for the object shape. |

## Outputs

`file_system_id`, `file_system_arn`, `dns_name`, `mount_name`,
`security_group_id`, `network_interface_ids`,
`data_repository_association_ids`.

## Why this changed from Intelligent-Tiering

The first iteration of this module used `storage_type =
"INTELLIGENT_TIERING"` with a `data_read_cache_configuration` and
`metadata_configuration` block. That config validates fine and creates
the file system, but DRA creation then fails at apply time with
`UnsupportedOperation` (AWS API limit, not a Terraform bug). The fix was
to switch the FS to SSD and drop the IT-only blocks.
