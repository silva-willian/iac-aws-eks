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

destroy_cluster() {

  eksctl delete cluster --region ${CLUSTER_REGION} --name ${CLUSTER_NAME}
}

validate_envs() {

  if [ -z "$ENV" ] || [ -z "$ENV_VERSION" ] || [ -z "$CLUSTER_REGION" ] || [ -z "$NAME" ]; 
  then
    echo "The parameters ENV, ENV_VERSION, AWS_REGION and NAME are mandatory"
    exit 1
  fi
}

NAME="k8s-rocketseat"
ENV="dev"
ENV_VERSION="v1"
CLUSTER_REGION="us-east-1"

validate_envs
  check_sucessful

solve_local_variables
  check_sucessful

destroy_cluster
  check_sucessful