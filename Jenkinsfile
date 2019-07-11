/**
* Jenkins Doc: https://jenkins.io/doc/
*
**/

openshift.withCluster() {
  env.NAMESPACE = openshift.project()
  env.APP_NAME = "${JOB_NAME}".replaceAll(/-build.*/, '')
  env.BUILD = "${env.NAMESPACE}"
  env.BASE_IMAGE_REPO = "ibmcom/websphere-traditional"
  env.BASE_IMAGE_TAG = "9.0.0.11"
  env.REGISTRY = "docker-registry.default.svc:5000"
  env.DEV_PROJECT = "dev"
  env.STAGE_PROJECT = "stage"
  env.DEV_IMAGE_TAG = "${env.REGISTRY}/${env.DEV_PROJECT}/${env.APP_NAME}:${env.BUILD_NUMBER}"
  env.STG_IMAGE_TAG = "${env.REGISTRY}/${env.DEV_PROJECT}/${env.APP_NAME}:promoted"
  
  
  echo "Starting Pipeline for ${APP_NAME}..."
}

pipeline {
    agent {
      label "maven"
    }
    stages {
      // Build Application using Maven
     /* stage('Maven build') {
          steps {
            sh """
            mvn -v 
            cd CustomerOrderServicesProject
            mvn clean package
            """
          }
        }
      
      // Run Maven unit tests
        stage('Unit Test'){
          steps {
            sh """
            mvn -v 
            cd CustomerOrderServicesProject
            mvn test
            """
          }
        }
      
      // Build Container Image using the artifacts produced in previous stages
      stage('Build Container Image'){
                steps {
                      script {
                              // Build container image using local Openshift cluster
                              openshift.withCluster() {
                                openshift.withProject(env.DEV_PROJECT) {
                                  timeout (time: 10, unit: 'MINUTES') {
                              // Generate the imagestreams and buildconfig
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
                                    def sImageStream = openshift.apply(src_image_stream)
                                    println "Source ImageStream Created........ ${sImageStream.names()}"

                                    def target_image_stream = [
                                      "apiVersion": "v1",
                                      "kind": "ImageStream",
                                      "metadata": [
                                          "name": "${env.APP_NAME}",
                                      ]
                                    ]
                                    def tImageStream =openshift.apply(target_image_stream)
                                    println "Target ImageStream Created........ ${tImageStream.names()}"
                                    
                                    // BuildConfig that uses Source & Target ImageStreams
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
                                    def bConfig = openshift.apply(buildconfig)
                                    println "BuildConfig Created........ ${bConfig.names()}"

                                    // run the build and wait for completion
                                    def build = openshift.selector("bc", env.APP_NAME).startBuild("--from-dir=.")
                                    
                                    // print the build logs
                                    build.logs('-f')
                                  }
                                }        
                              }
                            }
                          }
                        }    */
         stage("Deploy to DEV") {
                  steps {
                      script {
                            sh """
                            sed -i -e 's#docker-registry.default.svc:5000/appmod-twas/customerorderservices-twas:1.0#${env.DEV_IMAGE_TAG}#' Deployment/openshift/yaml/dc.yaml
                            sed -i -e 's#appmod-twas#${env.DEV_PROJECT}#' Deployment/openshift/yaml/dc.yaml
                            sed -i -e 's#appmod-twas#${env.DEV_PROJECT}#' Deployment/openshift/yaml/service.yaml
                            sed -i -e 's#appmod-twas#${env.DEV_PROJECT}#' Deployment/openshift/yaml/route.yaml
                            """
                            openshift.withCluster() {
                            openshift.withProject(env.DEV_PROJECT) {
                            def dc = openshift.apply( readFile("Deployment/openshift/yaml/dc.yaml"))
                            println "Created objects: ${dc.names()}"
                            def service = openshift.apply( readFile("Deployment/openshift/yaml/service.yaml"))
                            println "Created objects: ${service.names()}"
                            def route = openshift.apply( readFile("Deployment/openshift/yaml/route.yaml"))
                            println "Created objects: ${route.names()}"
                           }
                         }
                        }
                      }
                    }
     stage('Promote to STAGING ?') {
        steps {
            timeout(time:15, unit:'MINUTES') {
                input message: "Promote to STAGE?", ok: "Promote"
              }
             script {
                   sh """
                     sed -i -e 's#${env.DEV_PROJECT}#${env.STAGE_PROJECT}#' Deployment/openshift/yaml/dc.yaml
                     sed -i -e 's#${env.DEV_PROJECT}#${env.STAGE_PROJECT}#' Deployment/openshift/yaml/service.yaml
                     sed -i -e 's#${env.DEV_PROJECT}#${env.STAGE_PROJECT}#' Deployment/openshift/yaml/route.yaml
                      """
                   openshift.withCluster() {
                   openshift.withProject(env.STAGE_PROJECT) {
                   def dc_stage = openshift.apply( readFile("Deployment/openshift/yaml/dc.yaml"))
                   println "Created objects: ${dc_stage.names()}"
                   def service_stage = openshift.apply( readFile("Deployment/openshift/yaml/service.yaml"))
                   println "Created objects: ${service_stage.names()}"
                   def route_stage = openshift.apply( readFile("Deployment/openshift/yaml/route.yaml"))
                   println "Created objects: ${route_stage.names()}"
                   }
                  }
                 }
               }
             }
     }
  }
