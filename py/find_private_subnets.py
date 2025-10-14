import boto3
import sys

def find_private_subnets(vpd_id: str):
    client = boto3.client('ec2', region_name='eu-central-1')
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


if __name__ == "__main__":
    vpc_id = sys.argv[1]
    find_private_subnets(vpc_id)
