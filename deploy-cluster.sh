check_sucessful(){
  if [ $? != 0 ];
  then
    echo "Error Execution"
    exit 1
  fi
}

solve_local_variables () {
    CLUSTER_NAME="${NAME}-${ENV}-${ENV_VERSION}"
}

get_vpc() {

    VPC_ID=$(
                aws ec2 describe-vpcs \
                    --filters Name=tag:product,Values=network \
                        Name=tag:environment/${ENV},Values=1 \
                        Name=tag:environmentVersion/${ENV_VERSION},Values=1 \
                        Name=tag:type/application,Values=1 \
                    --query 'Vpcs[*].[VpcId]' \
                    --output text
            )
}

get_private_subnets() {

    PRIVATE_SUBNETS=$(
                        aws ec2 describe-subnets \
                            --filters Name=tag:product,Values=network \
                                Name=tag:environment/${ENV},Values=1 \
                                Name=tag:environmentVersion/${ENV_VERSION},Values=1 \
                                Name=tag:type/application,Values=1 \
                                Name=tag:private,Values=1 \
                            --query 'Subnets[*].[SubnetId]' \
                            --output text
                    )

    SANITIZED_PRIVATE_SUBNETS=$(echo $PRIVATE_SUBNETS | sed "s/ /,/g")
}


get_public_subnets() {

    PUBLIC_SUBNETS=$(
                        aws ec2 describe-subnets \
                            --filters Name=tag:product,Values=network \
                                Name=tag:environment/${ENV},Values=1 \
                                Name=tag:environmentVersion/${ENV_VERSION},Values=1 \
                                Name=tag:type/application,Values=1 \
                                Name=tag:public,Values=1 \
                            --query 'Subnets[*].[SubnetId]' \
                            --output text
                    )

    SANITIZED_PUBLIC_SUBNETS=$(echo $PUBLIC_SUBNETS | sed "s/ /,/g")
}


create_tag_vpc() {

    aws ec2 create-tags \
        --resources ${VPC_ID} \
        --tags Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared
        check_sucessful
}

create_tag_private_subnet() {

    for SUBNET_ID in $(echo $PRIVATE_SUBNETS | tr "," "\n")
    do
        aws ec2 create-tags \
            --resources ${SUBNET_ID} \
            --tags Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared
            check_sucessful

        aws ec2 create-tags \
            --resources ${SUBNET_ID} \
            --tags Key=kubernetes.io/role/internal-elb,Value=1
            check_sucessful
    done
}


create_tag_public_subnet() {

    for SUBNET_ID in $(echo $PUBLIC_SUBNETS | tr "," "\n")
    do
        aws ec2 create-tags \
            --resources ${SUBNET_ID} \
            --tags Key=kubernetes.io/cluster/${CLUSTER_NAME},Value=shared
            check_sucessful

        aws ec2 create-tags \
            --resources ${SUBNET_ID} \
            --tags Key=kubernetes.io/role/elb,Value=1
            check_sucessful
    done
}

deploy_cluster() {
    eksctl create cluster \
        --name ${CLUSTER_NAME} \
        --version ${FARGATE_VERSION} \
        --region ${CLUSTER_REGION} \
        --vpc-private-subnets ${SANITIZED_PRIVATE_SUBNETS} \
        --vpc-public-subnets ${SANITIZED_PUBLIC_SUBNETS} \
        --write-kubeconfig \
        --tags environment=${ENV} \
        --tags environmentVersion=${ENV_VERSION} \
        --tags productName="containers" \
        --tags projectName="k8s" \
        --tags owner="rocketseat" \
        --tags createdBy="devops-tools" \
        --tags vendor="aws" \
        --tags region=${CLUSTER_REGION} \
        --tags role="cluster" \
        --tags tier="gold" \
        --fargate
}

validate_envs() {

  if [ -z "$ENV" ] || [ -z "$ENV_VERSION" ] || [ -z "$FARGATE_VERSION" ] || [ -z "$CLUSTER_REGION" ] || [ -z "$NAME" ]; 
  then
    echo "The parameters ENV, ENV_VERSION, REGION, FARGATE_VERSION and NAME are mandatory"
    exit 1
  fi
}

validate_network() {

  if [ -z "$VPC_ID" ] || [ -z "$PRIVATE_SUBNETS" ] || [ -z "$PUBLIC_SUBNETS" ]; 
  then
    echo "The parameters VPC_ID, PRIVATE_SUBNETS and PUBLIC_SUBNETS are mandatory"
    exit 1
  fi
}

NAME="k8s-rocketseat"
ENV="dev"
ENV_VERSION="v1"
CLUSTER_REGION="us-east-1"
FARGATE_VERSION="1.21"

validate_envs
    check_sucessful

solve_local_variables
    check_sucessful

get_vpc
    check_sucessful

get_private_subnets
    check_sucessful

get_public_subnets
    check_sucessful

validate_network
    check_sucessful

create_tag_vpc
    check_sucessful

create_tag_private_subnet
    check_sucessful

create_tag_public_subnet
    check_sucessful

deploy_cluster
    check_sucessful