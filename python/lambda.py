import boto3
import json
from datetime import datetime

def lambda_handler(event, context):
    source_bucket = "cca-pbl"
    backup_bucket = "cca-pbl-backup"
    
    s3 = boto3.client('s3')

    # Retrieve the list of objects in the main bucket
    response = s3.list_objects_v2(Bucket=source_bucket)

    # Backup each object to the backup bucket
    for obj in response.get('Contents', []):
        key = obj['Key']

        # Copy the object to the backup bucket
        s3.copy_object(
            Bucket=backup_bucket,
            CopySource={'Bucket': source_bucket, 'Key': key},
            Key=key
        )

    # Create a log file with a timestamp
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    log_content = f"Backup completed at {timestamp}"
    
    s3.put_object(
        Bucket=backup_bucket,
        Key=f"backup_logs/{timestamp}_log.txt",
        Body=log_content
    )

    return {
        'statusCode': 200,
        'body': json.dumps('Backup successful!')
    }
