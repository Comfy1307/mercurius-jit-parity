FROM public.ecr.aws/d3j8x8q7/olympus-base-typescript:latest

WORKDIR /app

COPY . .

RUN npm install --include=dev --ignore-scripts --no-audit --no-fund
