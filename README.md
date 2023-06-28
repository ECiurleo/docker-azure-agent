# Azure Build Agent

The azure build agent requires certain values to be provided to the config.sh file.

`docker build --build-arg AZP_URL=<Azure_DevOps_URL> --build-arg AZP_TOKEN=<Agent_Registration_Token> --build-arg AZP_POOL=<Agent_Pool_Name> --build-arg AZP_AGENT_NAME=<Agent_Name> -t azure-agent .`

###   <Agent_Registration_Token>
[Instructions here](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/linux-agent?view=azure-devops) but in short, you need to create a personal access token and use that in the command (remmaber the user needs permissions for the agent pool selected)

###   Running the container
All variables are being set at build time, so you just run the containers on ACA or equivilent with no variables.  Be aware though **the <Agent_Name>  must be unique in the pool**

###   Enabling the Agent for a build job
To use the agent you must specify its pool in the build job/pipleine

```
# #  To use the self-managed managed build agent and build credits
pool:
  name: <Agent_Pool_Name>
  demands:
    - agent.name -equals <Agent_Name> 

# #  To use the Azure managed build agent and build credits
# pool:
#   vmImage: ubuntu-latest
```
You can seemingly only choose one or the other.

###   Agent version 
Set at build time in the docker file. Will get updated by AzureDevOps
