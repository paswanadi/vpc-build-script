# vpc-build-script

A Bash script that provisions a complete, segmented AWS VPC from scratch using the AWS CLI — no console clicking, fully repeatable.

## What it builds

Running `build-vpc.sh` creates the following in `ap-southeast-2` (Sydney):

- **1 VPC** (`10.0.0.0/16`)
- **4 subnets** across two Availability Zones for redundancy:
  - `X-Public-1`  — `10.0.0.0/26`   — ap-southeast-2a
  - `X-Public-2`  — `10.0.0.64/26`  — ap-southeast-2b
  - `X-Private-1` — `10.0.0.128/26` — ap-southeast-2a
  - `X-Private-2` — `10.0.0.192/26` — ap-southeast-2b
- **1 Internet Gateway**, attached to the VPC
- **2 route tables**:
  - Public — routes `0.0.0.0/0` to the Internet Gateway (makes its subnets internet-facing)
  - Private — local routing only (no internet path, keeps subnets isolated)
- **Subnet associations** wiring public subnets to the public route table and private subnets to the private route table
- **Name tags** on every resource

## How it works

The script captures each resource's ID as it's created (using `--query` and command substitution) and feeds it into the next command. This avoids hardcoded IDs, so the script runs cleanly on any account.

Example:
```bash
VPC_ID=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --query 'Vpc.VpcId' --output text)
```

## Usage

```bash
bash build-vpc.sh
```

Requires the AWS CLI configured with credentials and a default region.

## Notes / next steps

- No error handling yet — the script assumes each command succeeds.
- A companion teardown script (`delete-vpc.sh`) is planned to remove all created resources.
