const {
    GetObjectCommand,
    PutObjectCommand,
    S3Client,
} = require('@aws-sdk/client-s3');

const process = require('./src/process');
const processMeta = require('./src/processMeta');
const prepareMeta = require('./src/prepareMeta');

const s3 = new S3Client({});

const streamToBuffer = async body => {
    if (Buffer.isBuffer(body)) {
        return body;
    }

    if (body instanceof Uint8Array) {
        return Buffer.from(body);
    }

    if (typeof body?.transformToByteArray === 'function') {
        return Buffer.from(await body.transformToByteArray());
    }

    return new Promise((resolve, reject) => {
        const chunks = [];

        body.on('data', chunk => {
            chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
        });
        body.once('end', () => resolve(Buffer.concat(chunks)));
        body.once('error', reject);
    });
};

module.exports.processor = async ({
    allow_webp: allowWebp = false,
    bucket,
    filename,
    new_filename: newFilename,
    operations = [],
    quality = 82,
    'return': output,
}) => {
    const {
        ACL: acl,
        Body: objectBody,
        Metadata: metadata = {},
    } = await s3.send(new GetObjectCommand({
        Bucket: bucket,
        Key: filename,
    }));
    const body = await streamToBuffer(objectBody);
    const { buffer, mime } = await process(body, operations, quality, allowWebp);

    if (output === 'stream') {
        return buffer.toString('base64');
    }

    const params = {
        Body: buffer,
        Bucket: bucket,
        ContentType: mime,
        Key: newFilename,
    };

    if (acl) {
        params.ACL = acl;
    }

    if (!operations.length) {
        const meta = await processMeta(body);

        if (meta !== null) {
            params.Metadata = {
                ...metadata,
                ...prepareMeta(meta),
            };
        }
    }

    await s3.send(new PutObjectCommand(params));

    return { mime };
};
