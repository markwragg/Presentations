# Measure All The Things! with Influx, Grafana and PowerShell

## > TITLE SLIDE

Welcome to talk.

## > About Me

Working as a DevOps Engineer (Contractor) for SSR.
Previously worked in Ops, lots of experience with monitoring as a result, been on call.
Have blog/twitter/Github.

## > About This Talk

Introduce tools, hopefully new to audience
Inspire some creative use cases
PS is great, but use the right tool for the right job when thinking about collecting metrics (don't reinvent the wheel)
Dont make these tools your only approach to monitoring
Beware I don't cover how to run in production -- backup, running at scale etc.

## > Why Monitoring is Important (for DevOps)

DevOps is about delivering software changes more quickly and safely and in doing so, enabling a culture of experimentation
You can't do either if you don't have monitoring to see how your changes are impacting the app/service you are delivering
Traditional monitoring focus on availability -- DevOps needs a focus on events/metrics.

## > Beware The Observer Effect

When monitoring something, you can't help but affect it.
Tell story of my first monitoring solution and how it impacted the network.

## > Select All The Tools

Influx - Open Source, time series database.
TS DBs are designed to handle Timestamped data.
No need to create/tables schema to track metrics. Very good for querying time based data sets.

Grafana - Open Source, dashboard/visualisation tool.
Just a front end, but can aggregate data from different backends like Influx but also Azure Monitor, Cloud Watch etc.

PowerShell - Cross platform so lots of opportunity to use to pull data from lots of different sources.

## > Deploy All The Tools

Influx and Grafana are executables.
No installer, so you need to use something like NSSM to install as a service.
Use my install script to install on your current machine.
Use my Terraform script to install on a single VM in AWS or Azure.
Or configure manually, well worth getting familiar with the config files.

Show/step through install script (have already run before talk).

## > Record / Visualise First Metric

Use `1-WritingToInflux.ps1` to demo writing to Influx REST API using Invoke-RestMethod.

POST data using the Influx "line protocol"
Log in to Grafana
Set up Influx as a data source
Create a dashboard and graph to show everything is working.

## > Writing Metrics with the Influx Module

Effectively wraps the script just shown, generates the line protocol for you accounting for any characters that might need to be escaped.
Allows you to write metrics and tags using hashtables.
Splatting the connection details.

Use `2-WriteInflux.ps1` to show usage.
Visualise in Grafana, show having two metrics on one graph with different Axis.

## > Writing Metrics via UDP

Explain TCP vs UDP
Show how we can use `Write-InfluxUDP` to send the same metrics via a UDP listener.
Stop/start Influx service to show how the script is unaffected.
Writing via TCP would cause errors/timeouts.

## > Monitoring with PowerShell

Give some thought to covering these areas:

- Infrastructure/OS
- Application
- Business Logic
- Deployments

## > CPU / Memory / Disk / Network

Example PS script for tracking these metrics.
Use to demonstrate another graph type - bar chart

## > Alerting with Grafana

Alerts can be configured on the graph visualisation.
Show how to setup.

## > Adding Annotations with Grafana

Show adding annotations manually.
Show script for tracking system startups.
Show how we can use automatic annotations to overlay startups on the graphs.

## > Measuring App Performance

Show script that measures app execution time and errors.
Show deployment script.
Add automatic annotations for deployments.
Show how we can see the deployments made difference to the app execution.

## > Summary

Sum up per notes on slide.
