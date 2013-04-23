Go Webserver Cookbook for Amazon OpsWorks
===============================

We have several Go web applications that we run at http://www.crowdmob.com and wanted to be able to deploy them
using Amazon's OpsWorks http://aws.amazon.com/opsworks/ to get auto-scaling and auto-provisioning.

This is the recipe we use which we are using in production.  It `git clones` into a `releases/{NOW}` directory, builds the app (assuming your main package is defined in a go source file named `server.go`), symlinks the `current` directory to it, and tells `monit` to restart the service representing your server.

Dependencies
-----------------------------
This cookbook depends on the following:

- `deploy`: the base amazon deploy recipe at https://github.com/aws/opsworks-cookbooks/tree/master/deploy
- `golang`: the installation of go recipe at https://github.com/crowdmob/chef-golang
- `monit`: the monit package to ensure your server is running, and tries to restart it if not at https://github.com/crowdmob/chef-monit

Only Use 64 Bit EC2 Instances
-----------------------------
At this time, the `golang` cookbook mentioned doesn't dynamically choose the right binary at runtime, based on CPU.  That means that it assumes a 64 bit ec2 instance, which is a large instance or better.

Select the `Custom` Layer Type
-----------------------------
When you make your Layer in OpsWorks, be sure to select Other > Custom, rather than "Rails App Server" or some other pre-defined stack. 

Custom Chef Recipes Setup
-----------------------------
To deploy your app, you'll have to make sure 2 of the recipes in this cookbook are run.

1. `nutty::configure` should run during the configuration phase of your node in OpsWorks
2. `nutty::deploy` should run during (every) deployment phase of your node.

Databag Setup
-----------------------------
This cookbook relies on a databag, which you should set in Amazon OpsWorks as your Stack's "Custom Chef JSON", with the following parameters:

```json
{
  "service_realm": "production",
  "deploy": {
    "YOUR_APPLICATION_NAME": {
      "application_type": "nutty",
      "env": {
        "AWS_ACCESS_KEY_ID": "YOUR_AWS_ACCESS_KEY_CREDENTIALS",
        "AWS_SECRET_ACCESS_KEY": "YOUR_AWS_SECRET_KEY_CREDENTIALS",
        "AWS_REGION": "us-east-1",
        "PORT": 80
      },
      "kafka": {
        "topics": [ "YOUR_TOPIC_1" ],
        "max_message_size": 4096
      }
    }
  }
}
```

Here's a little more about the ones you have to fill in:
- `YOUR_APPLICATION_NAME` is what you named your app, in the "Apps" section of OpsWorks
- `YOUR_AWS_ACCESS_KEY_CREDENTIALS` should be gotten from Amazon AWS
- `YOUR_AWS_SECRET_KEY_CREDENTIALS` should also be gotten from Amazon AWS
- `YOUR_TOPIC_1` is an array of kafka topics, or empty

Important note: this cookbook double-checks that your `application_type` is set to `nutty` (our lite golang web framework).  If `application_type` is not set to `nutty`, none of the cookbook will run for that app.


How it Works
-----------------------------
This cookbook builds and runs a go webapp in the following way:

- The `server.go` source file is built using `go get .` followed by `go build -o ./nutty_APPNAME_server server.go`.  That results in an executable of your application at `/srv/www/APPNAME/current/nutty_APPNAME_server`
- A `nutty.properties` file is created using your databag and output at `/srv/www/APPNAME/shared/config/nutty.properties`
- A `nutty-APPNAME-server-daemon` shell script is created and placed in  `/srv/www/APPNAME/current/`, which handles start and restart commands, by calling  `/srv/www/APPNAME/current/nutty_APPNAME_server -c /srv/www/APPNAME/shared/config/nutty.properties` and outputting logs to `/srv/www/APPNAME/shared/log/nutty.log`
- A `nutty_APPNAME_server.monitrc` monit script is created, which utilizes the `nutty-APPNAME-server-daemon` script for startup and shutdown, and is placed in `/etc/monit.d` or `/etc/monit/conf.d`, depending on your OS (defined in the `monit` cookbook)
- `monit` is restarted, which incorporates the the new files.



A little about `nutty`
-----------------------------
At CrowdMob, we're working on a lite web framework we're calling `nutty`.

For the purposes of this cookbook, though, the only thing that it assumes about your webapp is:

1. Your `main` function is in a file called `server.go` in the base of your project. 
2. Your `server.go` program won't die if it's sent a `-c` flag at the command line with a filepath after it, like `go run server.go -c /path/to/config.properties`.  Whether or not it uses that file, however, is up to it.


License and Author
===============================
Author:: Matthew Moore

Copyright:: 2013, CrowdMob Inc.


Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
