import boto3
import sys

def find_vpc_id_by_name(vpc_name: str):
    client = boto3.client('ec2', region_name='eu-central-1')
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


'''
vpc_name="VpcWithTwoPublicSubnetsForEks-VPC"
'''
if __name__ == "__main__":
    vpc_name = sys.argv[1]
    vpc_id=find_vpc_id_by_name(vpc_name)
