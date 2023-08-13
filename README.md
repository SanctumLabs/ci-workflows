# CI Workflows

CI Workflows scripts & resources. We store templates for gitlab CI, Github Actions here and include them where they are needed.

## Templates

These templates can be included in other pipelines.They are "functions" for things we do often.

To use them first include the template

``` yaml
include:
  - project: 'sanctumlabs/tools/gitlab-ci'
    file: '/templates/docker-ecr-build.yml'
```

Next we need to extend them in a job, by overriding the variables with what we want them to be

```yaml
build-dev:
  stage: build
  needs: []
  extends: .docker-ecr-build
  variables:
    AWS_DEFAULT_REGION: "$DEV_AWS_REGION"
    AWS_ACCESS_KEY_ID: "$DEV_AWS_ACCESS_KEY_ID"
    AWS_SECRET_ACCESS_KEY: "$DEV_AWS_SECRET_ACCESS_KEY"
    ECR_IMAGE_REPO: "$DEV_REGISTRY_IMAGE"
    ECR_IMAGE_TAG: "$CI_COMMIT_SHA"
  except:
    - master
```
