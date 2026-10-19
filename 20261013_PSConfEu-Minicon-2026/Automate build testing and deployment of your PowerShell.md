# Automate build testing and deployment of your PowerShell

## > TITLE SLIDE

Thanks for joining me.

Today we’re going to be talking about build pipelines for PowerShell, why that matters and still matters in the age of AI

I personally use Azure DevOps which is what I’m going to demo today, but there are lots of ways to automate the build and deployment of PowerShell, and most of the concepts I talk about today can be easily run on any of the major build platforms.

## > Sponsors

Quick thank you to our sponsors.

## > About Me

My name is Mark Wragg, I’ve been semi- active in the PowerShell community for the past decade of so.

I’m based in the UK, where I live with my wife and three small humans, although one of those humans isn’t that small anymore, so I might need to come up with a new way of saying that.

I have a blog where I tend to share technical things I’ve found interesting.

You can also find me on LinkedIn and Bluesky, or if you’re interested in any of the code you see today it’s on GitHub.

This QR code on the left takes you to my blog, and was generated via a module called PSQR by Jake Hildreth.

## > Agenda

I’m going to give a very quick intro to Azure DevOps.

I’m also going to tell you why you shouldn’t use it, which is brilliant. So I’ve got a list of alternatives.

And then I’m going to talk very quickly about Disposable and Durable code.

Then we’ll get into why you might want to use a build pipeline for PowerShell, and some of things you can do with it.

And then I’m just going to jump straight into a demo, and setup a new pipeline for a new module, and dig into more of the detail around what the pipeline does and why.

## > What is Azure DevOps?

So as it says here, Azure DevOps is a cloud-based, or on-premise (if you want) tool for planning, coding, testing and deploying software.

Used in lots of enterprises, particularly where those enterprises are building Microsoft-based software, and on Azure. Although that’s by no means a requirement.

It has lots of features around the whole Software Development lifecycle, so its not just about running pipelines and automation, but also provides Kanban boards, and sprint planning tools, you can use it as a code repository to store Git repos instead of having them in GitHub. But none of this is mandatory, you just pick and choose what you want to use, and in my demo today I’m just using it for its pipelines.

It’s free, but it is about to get worse. It used to be that you could host public or private projects, public obviously being accessible and visible to everyone, and private being the opposite of that. Unfortunately public projects are going away next year, which I only discovered while prepping for this talk, but seeing as I’d already committed to talk about it I’m still going to.

There’s nothing stopping you still choosing Azure DevOps if its right for you, and you don’t mind building in private, with less concurrency for free than you used to get.

## > Alternatives

Alternatively, there are some other options. So I’m going to have a look at GitHub Actions to see if I can get some free concurrent jobs with that.

As you’ll hopefully see today, Azure DevOps Public Projects gives you 10 concurrent jobs, which means you can be simultaneously testing you code on Windows, MacOs and Linux, which obviously reduces the overall time your pipeline runs.

Be very sad to see that go, and I’ll be looking for a free alternative that allows concurrency.

There are some other populate build platforms listed here, GitLab, CircleCI, Bitbucket, AppVeyor which I used to use prior to Azure DevOps.

## > Disposable vs Durable code

So I wanted to quickly talk about Disposable vs Durable Code.

In PowerShell we’ve always had a form of disposable code, in the one-liners or console commands that would be run once, get a result, move on. Obviously Durable code is any code you want to keep longer term, reuse for the future.

AI obviously has made this much more of an issue, because people are one shotting very complex solutions, and then maybe not even keeping them once they’ve for the result they want. Obviously, this is horrible for the planet, and is like eating off of paper plates every day.

And the realy problem with disposable code, is sometimes it becomes durable code when you didn’t mean it to. And then you’ve got something that is potentially fragile, or not optimal, and suddenly you’re relying on it every day.

This is again, not a new problem that AI has caused. So often we’d write a quick script to solve a problem, and it becomes integral to the day to day operating of a company. But it’s obviously got easier than every to create very complex code, and because it’s so easy to generate, it’s easier to justify treating it as disposable.

## > More important than ever

So I found this quote in an article by Charity Majors. As it says, AI has not eliminated the need for fast feedback loops and software guardrails, (which is what you get by putting together a build pipeline for your PowerShell code).

They are not more important than ever, because the code AI is generating is more complex than ever. There’s also probably a lot more of it being created. That’s certainly my experience, where I’ve made lots of improvements to my PowerShell code recently, adding features as soon as I conceive of them because AI makes it so easy.

By having a pipeline that is run every time that code is changed and made more complex, adds an element of safety that we haven’t broken anything that previously worked, and that the new functionality does what we intended. And that we don’t publish broken code.

And then there’s secondary bits that can tend to be forgotten, such as ensuring you publish a ChangeLog so people can easily find out what's changed when you publish new versions of your code, and making documentation available where people can easily access it, such as directly in the repo. If you put these bits in your pipeline, they happen every time, with no effort.

## > A PowerShell build pipeline

OK so what do you want a PowerShell build pipeline for? Well there’s a few things you can do with it, and ultimately its up to you:

If you code your modules so that each cmdlet/function is an individual file, which is really great for tracking changes in source control, and much nicer than having a load of cmdlets in one huge file, you should still combine those into a single psm1 file before you publish the module. It’s not the end of the world if you don’t, but there’s a significant performance improvement when people then Import your module if you do.

There’s a great tool called PSScriptAnalyzer which you can use to enforce PowerShell recommended practices in your code, such as using full cmdlet names instead of aliases, avoiding accepting password input in plain text, that you haven’t make mistakes like having unused variables, or mandatory parameters with a default value. You can configure these rules to suit your needs, but they help keep you on the straight and narrow.

You should be writing Pester tests, or at least having AI generate some. These then make sure your code works the way you expect, and should be run every time the code changes.

As I said earlier, you can generate documentation. So you can turn your PowerShell help output into Markdown files, and put those back in the repo or anywhere else you want to publish documentation.

And finally, if all of the above has worked, and you want to deploy some new code to the PowerShell Gallery, or anywhere else you store your code (which obviously could include a private artifact repo) then we can have the pipeline do that, so we don’t do all this fabulous work and then forget to share it.

## > Demo

Demo by setting up Azure DevOps build pipeline for https://github.com/markwragg/PowerShell-Minecraft

### Pipeline summary

**build.ps1** — entry point. Optionally bootstraps dependencies (NuGet, PSDepend) via `-ResolveDependency`, sets up build env vars (`BuildHelpers`), then hands off to **build.psake.ps1**, which just defines shared `Properties` and dot-sources every task file.

**Tasks (in dependency order):**

1. **Init** — dumps build environment info (`BH*` vars) for diagnostics.
2. **Clean** — wipes and recreates the `Artifacts`/`Staging` folders.
3. **CombineFunctionsAndStage** — concatenates all Public/Private function files into one `.psm1`, copies manifest, docs, and format files, into `Staging`.
4. **ImportStagingModule** — imports that staged module (globally, so later tasks like PlatyPS can see it).
5. **Analyze** — runs PSScriptAnalyzer against the staged module; fails the build on any `Error`-severity findings.
6. **Test** — runs Pester unit tests + code coverage against the staged module; fails build on test failures, outputs coverage % as a pipeline variable.
7. **UpdateCoverageBadge** — stamps the coverage % from `Test` onto a shields.io badge in README.md.
8. **UpdateDocumentation** — regenerates Markdown help (PlatyPS) from comment-based help into `/Documentation`.
9. **UpdateWiki** — clones the repo's separate GitHub wiki repo, regenerates function reference pages, commits/pushes (with several safety checks to avoid ever pushing into the main repo by mistake).
10. **Deploy** — bumps the module version (auto-next or pinned via a `## !Deploy [x.y.z]` line in CHANGELOG.md), publishes to PowerShell Gallery via `deploy.psdeploy.ps1` if a deploy was requested, updates CHANGELOG with the release date, and signals `DidDeploy` for later steps.
11. **CreateBuildArtifact** — zips the built module into `Artifacts/<name>-v<version>.zip`.
12. **GitHubRelease** — (only runs if `DidDeploy` was set) creates a GitHub Release tagged `v<version>` using the matching CHANGELOG section as notes, and attaches the zip as an asset.
13. **Commit** — copies the refreshed comic-cache JSON back to source, commits updated docs/README/CHANGELOG/cache, and pushes `[skip ci]` to avoid retriggering the pipeline.

The `Default` psake task just runs `Test` (used for local/dev runs); the full chain above is what the CI pipeline invokes end-to-end.

### azure-pipelines.yml summary

This wires the psake tasks from build.psake.ps1 into an Azure DevOps pipeline with two stages:

**Triggers:** runs on pushes to `master` and on PRs targeting `master` (kept in sync with the `DeployBranch` variable).

**Stage: Test** (runs on every push/PR)

- **Windows job** — caches PS modules, installs deps, combines module, runs `Analyze`, then tests on both PowerShell Core (`TestCore`, outputs coverage %) and Windows PowerShell.
- **CrossPlatform job** (matrix: Linux + macOS) — same combine/analyze/test flow on PowerShell Core only (no Windows PowerShell there).
- Both publish Pester NUnit results.

**Stage: Build** (only if Test succeeds; carries `CoveragePercent` across from the Windows job's output)

- Single Windows job that runs, in order: `CombineFunctionsAndStage` → `UpdateDocumentation` → `UpdateWiki` → `Deploy` → `UpdateCoverageBadge` → `Commit` → `CreateBuildArtifact` → `GitHubRelease`.
- The publish-y steps (`UpdateWiki`, `Deploy`, `Commit`, `GitHubRelease`) are gated with `ne(Build.Reason, 'PullRequest')`, so PR builds validate but never push to the wiki, gallery, or repo.
- `GitHubRelease` has the extra condition that `Deploy.DidDeploy == 'true'` (i.e. only runs if a real version was actually published).
- Secrets (`GitHubPAT`, `NugetApiKey`) come from the `powershell-gallery` variable group, injected only into the steps that need them.
- Finishes by publishing two build artifacts: the zipped module (`Artifacts`) and the raw staged module (`Staging`/`PSModule`).

So in short: Test stage = validate on 4 OS/PS combos; Build stage = regenerate docs/wiki, bump version & publish to Gallery, update README badge, commit results back, zip + GitHub-release it — with all the "writes somewhere" steps skipped on PR builds.
