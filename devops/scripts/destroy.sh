#!/bin/bash
check_sucessful(){
    if [ $? != 0 ];
    then
        echo "Error Execution"
        exit 1
    fi
}

login() {
    aws ecr get-login-password --region ${AWS_REGION} | \
        docker login --username AWS --password-stdin ${AWS_ACCOUNT_REGISTRY}.dkr.ecr.${AWS_REGION}.amazonaws.com
}

deploy() {
    docker run \
        -e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
        -e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
        -e AWS_REGION="${AWS_REGION}" \
        -e ENV="${ENV}" \
        -e ENV_VERSION="${ENV_VERSION}" \
        -e FARGATE_VERSION="${FARGATE_VERSION}" \
        -e NAME="${NAME}" \
        -e PROJECT_NAME="${PROJECT_NAME}" \
        -e PRODUCT_NAME="${PRODUCT_NAME}" \
        -e CREATED_BY="${CREATED_BY}" \
        -e OWNER="${OWNER}" \
        -e ROLE="${ROLE}" \
        -e TIER="${TIER}" \
        -e CLUSTER_REGION="${CLUSTER_REGION}" \
        ${AWS_ACCOUNT_REGISTRY}.dkr.ecr.${AWS_REGION}.amazonaws.com/iac-aws-eks-fargate:1.0.3-destroy

}

AWS_ACCOUNT_REGISTRY=$(aws sts get-caller-identity --output text |awk '{print $1}')
    check_sucessful

login
    check_sucessful

deploy
    check_sucessful