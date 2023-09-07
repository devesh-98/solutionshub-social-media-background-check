import instaloader
from datetime import datetime
from itertools import dropwhile, takewhile
import boto3
import json
from confluent_kafka import Producer
import os

instagram_username=''
s3_bucket=""
access_key=""
secret_key=""
s3 = boto3.resource('s3',region_name='ap-south-1',aws_access_key_id=access_key,aws_secret_access_key=secret_key)

def read_ccloud_config(config_file):
    conf = {}
    with open(config_file) as fh:
        for line in fh:
            line = line.strip()
            if len(line) != 0 and line[0] != "#":
                parameter, value = line.strip().split('=', 1)
                conf[parameter] = value.strip()
    return conf

class GetInstagramProfile():
    def __init__(self) -> None:
        self.L = instaloader.Instaloader()

    def get_user_information(self,username):
        profile = instaloader.Profile.from_username(self.L.context, username)
        info={}
        info['username']=profile.username
        info['userid']=profile.userid
        info["number_of_posts"]= profile.mediacount
        info["followers_count"]= profile.followers
        info["following_count"]= profile.followees
        info["bio"]=profile.biography
        info["external_url"]=profile.external_url
        info=json.dumps(info)
        print(info)
        producer.produce("user_basic_info", key=username, value=info)
    
   
    def download_users_posts_with_periods(self,username):
        self.L.download_profile(username, profile_pic_only=True)
        posts = instaloader.Profile.from_username(self.L.context, username).get_posts()
        print(posts)
        SINCE = datetime(2023, 8, 1)
        UNTIL = datetime(2023, 8, 11)
        print(SINCE)
        print(UNTIL)    

        for post in takewhile(lambda p: p.date > SINCE, dropwhile(lambda p: p.date > UNTIL, posts)):
            self.L.download_post(post, username)
        
        image_files = [file for file in os.listdir("./"+username+"/") if file.endswith(('.jpg'))]
        for image in image_files:
            path=""
            path="./"+username+"/"+image
            s3.Bucket(s3_bucket).upload_file(Filename=path, Key=username+'_'+image)
            s3_path=username+'_'+image
            info={}
            info['username'] = username
            info['s3_path'] = s3_path
            info['bucket']=s3_bucket
            info=json.dumps(info)
            print(info)
            producer.produce("user_posts_images", key=s3_path, value=info)
        
        #combining all posts caption to one single file and uploading to s3
        text_files = [file for file in os.listdir("./"+username+"/") if file.endswith(('.txt'))]
        text_info={}
        with open("./"+username+"/"+username+"_posts_caption.txt", 'w') as outfile:
            for fname in text_files:
                with open("./"+username+"/"+fname) as infile:
                    for line in infile:
                        outfile.write(line)
        s3.Bucket(s3_bucket).upload_file(Filename="./"+username+"/"+username+"_posts_caption.txt", Key= username+"_posts_caption.txt")
        text_info['s3_path']=username+"_posts_caption.txt"
        text_info['bucket']=s3_bucket
        text_info['username']=username
        text_info=json.dumps(text_info)
        print(text_info)
        producer.produce('user_posts_description',key=username,value=text_info)



        


if __name__=="__main__":
    cls = GetInstagramProfile()
    producer = Producer(read_ccloud_config("client.properties"))
    cls.get_user_information(instagram_username)
    cls.download_users_posts_with_periods(instagram_username)
    producer.flush()
    
