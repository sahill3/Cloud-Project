const AWS = require('aws-sdk');
const s3 = new AWS.S3();

exports.handler = async (event) => {
    const sourceBucket = 'cca-pbl'; // Replace with your source bucket name
    const destinationBucket = 'backup-bucket'; // Replace with your destination bucket name
    
    try {
        const objects = await s3.listObjectsV2({ Bucket: sourceBucket }).promise();

        for (const obj of objects.Contents) {
            // Delete the existing object in the destination bucket, if it exists
            try {
                await s3.deleteObject({ Bucket: destinationBucket, Key: obj.Key }).promise();
            } catch (err) {
                // Ignore errors if the object doesn't exist in the destination bucket
            }

            // Copy the object from the source bucket to the destination bucket
            const copyParams = {
                CopySource: `${sourceBucket}/${obj.Key}`,
                Bucket: destinationBucket,
                Key: obj.Key,
            };

            await s3.copyObject(copyParams).promise();
        }
        
        const response = {
            statusCode: 200,
            body: JSON.stringify('S3 bucket backup completed successfully.'),
        };
        
        return response;
    } catch (error) {
        console.error('Error:', error);
        throw error;
    }
};
