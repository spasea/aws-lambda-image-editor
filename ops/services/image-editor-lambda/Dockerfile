FROM public.ecr.aws/lambda/nodejs:22

WORKDIR ${LAMBDA_TASK_ROOT}

# Placeholder skeleton. Build steps and dependency upgrades are added later.
COPY package.json package-lock.json ./
COPY handler.js ./
COPY src ./src

CMD ["handler.processor"]

