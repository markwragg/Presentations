## > TITLE SLIDE

*Introduce Self*

This talk is about developing and testing cross platform PowerShell code, which is to say PowerShell code that should run equally on Windows, MacOS or Linux.

Authoring cross-platform PowerShell code isn't particularly different to authoring Windows PowerShell code.

However there are some potential pitfalls, and as part of this talk I will demonstrate how you can leverage Continuous Integration to automate testing of your cross platform code across the different platforms.

## > THE PROBLEM

I want to start by explaining the problem I had that somewhat inspired this talk.

I was recently tasked with automating the deployment of some static content files for an application. These files are used to define the wording in things like email templates and pages of the web site. 

Historically these files could change in one of two ways:

- The developers modify or add new files as part of a release of some new feature for the app, which then gets deployed during the regular monthly release cycle.
- Outside of a scheduled release, the business make a request to change the files that they want fulfilled ASAP. There are then then implemented by the Ops team.

The dev changes were made in source control, but the ops changes tended to happen directly on the servers. As part of the automation, I wanted all changes to be in source control. But I also wanted to support two different deployment strategies:

- A full deployment where all the files in Source Control were deployed, after removing any existing copies of the files.
- A "changes only" type deployment where *just* modified files would be deployed. This was essential for the Ops-type deployment, because by just deploying the changed files Ops could implement changes without needing downtime.

Deploying just changed files seemed like it should be simple, however when you pull files from Source Control, you lose the original modified dates of the files, which made it harder to determine which had changed.

I was happy to assume that the copy of the files that were in Source Control were the canonical copy, so if any of the files were different to the ones on disk, the version in Source Control should be used. One option might have been to just compare file sizes and that probably would have been accurate 90% of the time. But I was also aware that PowerShell has a `Get-FileHash` cmdlet for generating a hash value representation of a file and that you can use this in particular as a quick way to determine if two files are identical.

## > THE SOLUTION

This led me to develop a PowerShell cmdlet called Copy-FileHash. You provide this cmdlet with two paths. It compares the files in these paths and if there are two files with the same name and in the same sub-folder location within each parent path, then it calculates their file hashes and if the hashes are different, copies the file from source to destination.

Now when I want to do a "changes only" deployment for my files, the source control copy of the files are dropped to a temp location and this cmdlet is used to copy any that are different or new.

If you'd like to explore this cmdlet yourself, its published in the PowerShell Gallery in a module named "HashCopy".

I developed my Copy-FileHash cmdlet to solve this deployment challenge on our Windows-based servers. But as you might have noticed, I'm a Mac user. This is quite a recent change for me and came from my employer asking me if I'd like a Mac, and as i'd never had one before I thought i'd give it a go.

As a Mac user, PowerShell Core was my only choice to work on my module locally, so it wasn't too much effort for me to validate that it would work on PowerShell Core as well as a Mac.

But really just looking at it I was fairly confident it was a candidate for being cross-platform, as all it really does it work with the file system.

## > POWERSHELL CORE

PowerShell Core started life as a fork of Windows PowerShell, but by the time of its official release was significantly different. 

It is built upon .NET Core, which is really what enables it to operate on a variety of operating systems, including Windows, MacOS and Linux. 

It is generally faster. There are a few exceptions, but for most operations you'll likely find it runs at least twice as fast as Windows PowerShell.

It is completely open sourced and in GitHub. It also has a strong community involvement, with 50% of code changes being driven by the community.

Despite being a continuation of the version number from Windows PowerShell (which is confusing), it is a distinct version of PowerShell. That means you can install it along side Windows PowerShell on Windows. But it also means that some of the default cmdlets that you have with Windows PowerShell are not available under Core, even when it's installed on Windows. 

PSCore 6.1 was just released, which is the second major release. 6.1 has done a lot to add compatibility for Windows PowerShell modules on Windows. There hasn't been a lot of new features/cmdlets, but one to note is `Test-Connection` is now on PS Core.

Generally where cmdlets are missing its because they are dependent on the .NET Framework or other closed source code. Overtime you will see this gap get smaller but for some this is a big blocker on moving their workloads to PowerShell Core.

Equally a number of the pre-existing Windows PowerShell modules do not yet work on PowerShell Core, including both Microsoft and community maintained modules.

## > THINGS TO CONSIDER

The availability of cmdlets is likely to be your biggest challenge, and the thing most likely to stop you writing code for PowerShell Core. 

But if the cmdlets are there, its worth being careful about how you use them. It is already considered best practice to use full cmdlet names and avoiding aliases when you're writing PowerShell scripts vs just working in the console. This is especially true when you're writing cross-platform code because aliases can vary and on the Unix systems in particular take prescedence over the PowerShell cmdlets.

I was recently tripped up by `Sort`, which I will often use vs writing `Sort-Object` in full, but discovered that on Mac `Sort` is a built in command and was being in called instead of `Sort-Object` by default.

The most obvious consideration is file paths. Although actually i've found that a Unix system won't necessarily fall over if you've used a backslash in a path vs a forward slash. However where you can cause problems is when a path is being constructed. For example, I was using `$PSScriptRoot` and then adding on `\somefile.htm` that I needed to upload to an endpoint. This was fine on Windows, but on Unix the path was a mixture of forward and back slashes and as a result was considered invalid.

My experience so far is that Windows has no problem with using forward slashes in paths and so thats generally the best to use by default.

It's also a good idea to let PowerShell handle paths wherever possible. By that I mean two things:

1. Use environment variables whenever possible to reference system paths. You obviously need to avoid ever hard coding C:\some\path
2. Use the `-Path` cmdlets to handle path manipulation for you.

`Get-Command *-path`.

You also need to wary of file encoding, particularly if you're primarily authoring your code on Windows where line breaks are handled differently. Generally you probably want to ensure all files are encoded as UTF8.

## > WHY WRITE CROSS-PLATFORM?

So.. writing PowerShell code that works on PowerShell Core can be challenging and you should quite rightly be selective about when you choose to do so.

My personal opinion is: if you can, you should. Microsoft have been very clear that PowerShell Core is the future of PowerShell and that Windows PowerShell will only be bug fixed going forward, it will not receive any new features. 

And there are PowerShell Core cmdlets that are already improved over their Windows PowerShell equivalents. The `Invoke-WebRequest` and `Invoke-RestMethod` cmdlets for example have a number of new paramaters for handling SSL. If you've ever had to work around connecting to an API that is using a self-signed SSL certificate with Windows PowerShell you will know what a relief this is.

Ultimately, ensuring your code works on PowerShell Core and across the different platforms is about future proofing.
As compute continues to move to the cloud, containers or to serverless/function type models (or whatever comes next) having code that is portable across these platforms is going to make your life easier.

In fact in the last week or so AWS have announced that their serverless function platform Lambda now supports PowerShell Core.

Making your code cross platform will ultimately make it accessible to a wider audience (particularly if you also open source it and put it in the PowerShell Gallery). A wider audience means more feedback, more real-world tests, and so better code.

However..

It isn't always possible. If you have code that is exclusively for operating on Windows (for example a module that manipulates the Registry), there is probably not a lot of value trying to get it to work on PowerShell Core at this point, unless you think you'd benefit significantly from the performance improvement.

Equally if getting a module to work on PowerShell Core makes it incompatible with Windows PowerShell, you might to consider maintaining both as separate versions. This is true of the AWS module for example, where in PSGallery there is both `AWSPowerShell` and `AWSPowerShell.NetCore`.

## > TESTING YOUR CODE

If you want a high degree of certainty that your code works across multiple platforms, you need a good set of automated tests to prove it.

PowerShell has Pester as a testing framework. If you're not familiar with Pester I strongly suggest you check it out. In brief, Pester provides a domain-specific language for defining tests and then provides a consistent way to run those tests and report on success/failure.

## > APPVEYOR

Pester is a prerequisite to then leveraging a service like AppVeyor to configure automated tests of your code.

AppVeyor is a Continuous Integration tool, alternatives include Azure DevOps, CircleCI, TravisCI, Jenkins etc.

You can effectively hook it up to your GitHub account and have it watch one or more of your repositories for commits and then execute code when a commit occurs.

I've created a very basic example to demonstrate called PowerShell-ExampleModule. I've already committed this module to GitHub and you can see it has one simple cmdlet and a Pester test file. 

I've created a config file that AppVeyor looks for by default called Appveyor.yml. Within this file i'm telling AppVeyor that it should use two of its build images to test my commits, the Ubuntu image and the Visual Studio 2017 image (this runs Windows 2016 that has PowerShell Core installed).

I can now add the project in to AppVeyor and either manually kick off a build, or make a commit to the project. It will then start two jobs and run my tests. 

This is a simplified example but lets now look at PowerShell-HashCopy which is following the same premise but is slightly more complicated.

## > SUMMARY

In summary:

- If you have PowerShell code that works in PowerShell Core, it shouldn't be too difficult to ensure it works across any OS platform.
- If you want reassurance that your code is cross-platform compatible, a service like AppVeyor is your friend.
- Coding for PowerShell Core as a first party is an investment in the future.

Thank you.

*Any questions?*