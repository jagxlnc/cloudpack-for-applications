/**
* Jenkins Doc: https://jenkins.io/doc/
*
**/

openshift.withCluster() {
  env.NAMESPACE = openshift.project()
  env.APP_NAME = "${JOB_NAME}".replaceAll(/-build.*/, '')
  echo "Starting Pipeline for ${APP_NAME}..."

  env.BUILD = "${env.NAMESPACE}"

  env.BASE_IMAGE_REPO = "ibmcom/websphere-traditional"
  env.BASE_IMAGE_TAG = "9.0.0.11"

  env.REGISTRY = "docker-registry.default.svc:5000"
  env.DST_IMAGE = "${env.REGISTRY}/${env.NAMESPACE}/${env.APP_NAME}:${env.BUILD_NUMBER}"
  
}

pipeline {
    agent {
      label "maven"
    }
    stages {
      stage('Maven build') {
          steps {
            sh """
            mvn -v 
            cd CustomerOrderServicesProject
            mvn clean package
            """
          }
        }
        // Build Container Image using the artifacts produced in previous stages
      stage('Build Container Image'){
                steps {
                      script {
                              // Build container image using local Openshift cluster
                              openshift.withCluster() {
                                openshift.withProject() {
                                  timeout (time: 10, unit: 'MINUTES') {
                                    // generate the imagestreams and buildconfig
                                    def src_image_stream = [
                                      "apiVersion": "v1",
                                      "kind": "ImageStream",
                                      "metadata": [
                                        "name": "websphere-traditional",
                                      ],
                                      "spec": [
                                        "tags": [
                                          [
                                            "name": "9.0.0.11",
                                            "from": [
                                              "kind": "DockerImage",
                                              "name": "${env.BASE_IMAGE_REPO}:${env.BASE_IMAGE_TAG}"
                                            ]
                                          ]
                                        ]
                                      ]
                                    ]
                                    openshift.apply(src_image_stream)

                                    def target_image_stream = [
                                      "apiVersion": "v1",
                                      "kind": "ImageStream",
                                      "metadata": [
                                          "name": "${env.APP_NAME}",
                                      ]
                                    ]
                                    openshift.apply(target_image_stream)

                                    def buildconfig = [
                                      "apiVersion": "v1",
                                      "kind": "BuildConfig",
                                      "metadata": [
                                        "name": "${env.APP_NAME}",
                                      ],
                                      "spec": [
                                        "output": [
                                          "to": [
                                            "kind": "ImageStreamTag",
                                            "name": "${env.APP_NAME}:${env.BUILD_NUMBER}"
                                          ]
                                        ],
                                        "source": [
                                          "type": "Binary"
                                        ],
                                        "strategy": [
                                          "dockerStrategy": [
                                            "from": [
                                              "kind": "ImageStreamTag",
                                              "name": "websphere-traditional:9.0.0.11"
                                            ],
                                            "dockerfilePath": "Dockerfile",
                                            "noCache": true,
                                            "forcePull": true
                                          ]
                                        ],
                                        "failedBuildsHistoryLimit": 3,
                                        "successfulBuildsHistoryLimit": 3
                                      ]
                                    ]
                                    openshift.apply(buildconfig)

                                    // run the build and wait for completion
                                    def build = openshift.selector("bc", env.APP_NAME).startBuild("--from-dir=.")
                                    
                                    // print the build logs
                                    build.logs('-f')
                                  }
                                }        
                              }
                            }
                          }
                        }      
         stage("Deploy objects") {
                  steps {
                      script {
                            sh """
                            sed -i -e 's#docker-registry.default.svc:5000/appmod-twas/customerorderservices-twas:1.0#${env.DST_IMAGE}#' Deployment/openshift/yaml/dc.yaml
                            """
                            openshift.withCluster() {
                            openshift.withProject() {
                            def objects1 = openshift.apply( readFile("Deployment/openshift/yaml/dc.yaml"), "--namespace=${env.NAMESPACE}" )
                            println "Created objects: ${objects1.names()}"
                            def objects2 = openshift.apply( readFile("Deployment/openshift/yaml/service.yaml"), "--namespace=${env.NAMESPACE}" )
                            println "Created objects: ${objects2.names()}"
                            def objects3 = openshift.apply( readFile("Deployment/openshift/yaml/route.yaml"), "--namespace=${env.NAMESPACE}" )
                            println "Created objects: ${objects3.names()}"
                           }
                         }
                        }
                      }
                    }        
              }
            }
