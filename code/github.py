import boto3
import string
import requests
from datetime import datetime, timedelta

session = boto3.Session(profile_name='sygna-sandbox', region_name='ap-northeast-1')
ecs_client = session.client('ecs')

token = "4cad98bfd25aae16fdc8288e8c7294ee5d8f215e" # Not Secure here, but rate limit :(
owner = "ashchang"
repo = "sb"

# Check ECS service tag for github branch
service_arn = ecs_client.list_services(
    cluster='feature'
)['serviceArns'][0]
service_name = service_arn.split('service/')[1].split('/')[0]

response = ecs_client.list_tags_for_resource(
    resourceArn=service_arn
)
branch = response['tags'][0]['value']
print(branch)

# Find branch last commit time
query_url = f"https://api.github.com/repos/{owner}/{repo}/branches"
headers = {
    'Authorization': f"{token}",
    'Accept': 'application/vnd.github.v3+json'
}
response = requests.get(query_url, headers=headers)

for i in response.json():
    if branch in i['name']:
        commit_sha = i['commit']['sha']
        print(commit_sha)

query_url = f"https://api.github.com/repos/{owner}/{repo}/commits/{commit_sha}"
headers = {'Accept': 'application/vnd.github.v3+json'}
r = requests.get(query_url, headers=headers)

# Some string format processing
commit_iso8601_time = r.json()['commit']['committer']['date']
commit_time_list = commit_iso8601_time.split('T')
commit_time_processed = commit_time_list[0]+" "+commit_time_list[1].split('Z')[0]
commit_time = datetime.strptime(commit_time_processed, '%Y-%m-%d %H:%M:%S')
now_time = datetime.today()
time_delta = now_time - commit_time

# if timedelta over 3 days then do ecs update_service
if time_delta >= timedelta(days=3):
    resp = ecs_client.update_service(
        cluster='feature',
        service=service_name,
        desiredCount=0
    )
    print(resp)
    print("Terminate fargate service.")
else:
    print("Nothing happend.")
