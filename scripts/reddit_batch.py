# Databricks notebook source
pip install azure-storage-blob

# COMMAND ----------

from azure.storage.blob import BlobClient
import urllib3
import json
import base64
import datetime

# COMMAND ----------

client_id = dbutils.secrets.get(scope="reddit", key="client_id")
client_secret = dbutils.secrets.get(scope="reddit", key="client_secret")

connectionString = dbutils.secrets.get(scope="storage_account", key="conn_string")
containerName = "bronze"
outputBlobName	= "reddit_posts.json"

encoded_bytes = base64.b64encode(f"{client_id}:{client_secret}".encode('utf-8'))
encoded_string = encoded_bytes.decode('utf-8')
basic_auth = f"Basic {encoded_string}"

auth_url = 'https://www.reddit.com/api/v1/access_token?grant_type=client_credentials'
auth_headers = {
  "Authorization" : basic_auth,
  "User-Agent": "PostmanRuntime/7.32.2"
}
payload={}

# COMMAND ----------

http = urllib3.PoolManager()

blob = BlobClient.from_connection_string(conn_str=connectionString, container_name=containerName, blob_name=outputBlobName)

# COMMAND ----------

def get_auth(url, header, body):
    auth_response = http.request(
        'POST', 
        url, 
        headers=header, 
        body=body
    )

    auth_json = json.loads(auth_response.data)
    access_token = auth_json['access_token']

    return access_token

# COMMAND ----------

def get_posts(subreddits):
    try:
        access_token = get_auth(auth_url, auth_headers, payload)

        endpoint_headers = {
            'Authorization': f'Bearer {access_token}',
            'User-Agent': 'Databricks'
            }
        
        query_params = {
            't': 'all',
            'limit': 100
            }

        posts_list = []

        extracted_at = datetime.datetime.now()
        extracted_at = int(extracted_at.timestamp())


        for subreddit in subreddits:
            print(f"Getting posts from {subreddit}")
            while True:
                response = http.request(
                    'GET', 
                    f'https://oauth.reddit.com/r/{subreddit}/new', 
                    headers=endpoint_headers, 
                    fields=query_params
                )

                data = json.loads(response.data.decode('utf-8'))
                posts = data['data']['children']
                
                for post in posts:
                    post['data']['extracted_at'] = extracted_at
                    posts_list.append(post['data'])
                    
                if data['data']['after'] is not None:
                    query_params['after'] = data['data']['after']

                else:
                    query_params = {
                        't': 'all',
                        'limit': 100
                    }
                    break
            else:
                continue       

        blob.upload_blob(json.dumps(posts_list), overwrite=True)
        print("Post saved!")
    except Exception as e: 
        print(e)

# COMMAND ----------

get_posts(['news', 'gaming', 'pcmasterrace'])