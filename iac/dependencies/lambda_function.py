import json
import boto3
import csv
from pymongo import MongoClient
import os

def lambda_handler(event, context):
    # Get the S3 bucket and object key from the event
    s3_client = boto3.client('s3')
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    object_key = event['Records'][0]['s3']['object']['key']
    
    # Download the file from S3
    file_path = '/tmp/' + object_key
    s3_client.download_file(bucket_name, object_key, file_path)
    
    # Connect to MongoDB
    mongo_client = MongoClient(os.environ['MONGO_URI'])
    db = mongo_client[os.environ['DATABASE']]
    collection = db[os.environ['COLLECTION']]
    
    # Process the CSV file
    with open(file_path, 'r') as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            student_id = int(row['student_id'])
            # Check if student already exists in the database
            existing_student = collection.find_one({'student_id': student_id})
            if existing_student:
                # Update existing student data
                collection.update_one({'student_id': student_id}, {'$set': row})
            else:
                # Insert new student data
                collection.insert_one(row)
    
    # Return a response
    return {
        'statusCode': 200,
        'body': json.dumps('File processed successfully!')
    }
