import boto3

client = boto3.client('ec2', region_name='eu-central-1')

def find_vpc_id(vpc_name: str):
    response = client.describe_vpcs(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                    vpc_name,
                ]
            }
        ],
        MaxResults=123,
        DryRun=False,
    )

    vpc_id = response['Vpcs'][0]['VpcId']
    print(vpc_id)
    return vpc_id

def find_private_subnets(vpd_id: str):
    response = client.describe_subnets(
        Filters=[
            {
                'Name': 'vpc-id',
                'Values': [
                    vpd_id,
                ]
            },
            {
                'Name': 'tag:aws:cloudformation:logical-id',
                'Values': [
                    'PrivateSubnet*',
                ]
            },
        ]
    )

    subnet_ids_result = []
    subnets = response['Subnets']
    for subnet in subnets:
        subnet_ids_result.append(subnet['SubnetId'])

    print(str(' '.join(subnet_ids_result)))
    return subnet_ids_result



vpc_name="VpcWithTwoPublicSubnetsForEks-VPC"
vpc_id=find_vpc_id(vpc_name)
subnet_ids = find_private_subnets(vpc_id)
