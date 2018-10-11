# Mastering Pester Testing with PowerShell

## > Title Slide

Hello and thank you for choosing to attend my session on Mastering PowerShell Testing with Pester. Hopefully today you've seen lots of inspiring ideas of things you can do with PowerShell and (in my opinion) you've now made the smart choice of learning about how you can ensure those things work.

## > About Me

My name is Mark Wragg and I am a DevOps Engineer for XE.com. You can find me on Twitter @markwragg and I occasionally blog at wragg.io.

Per the test output you can see on this slide, I am not the foremost expert in Pester. I tend to think of myself as one of it's biggest fans. I was first introduced to Pester about 3 years ago and I recall feeling overwhelmed by it at first, and uncertain whether the effort required to both learn and implement it were necessary. I think in part that was because I was still just getting to grips with PowerShell, and layering on this additional and seemingly optional thing felt like overkill.

In fact Pester is very simple to get started with and incredibly valuable in ensuring your code works the way you intended, both now and in the future. I hope that by the end of this session you will also be one of it's biggest fans.

## > About Pester

Pester is simply a PowerShell module that you can install from the PowerShell Gallery in order to write and execute test scripts for your PowerShell code.

Pester scripts are just like regular PowerShell scripts, but with some additional keywords and structure.

The Pester module itself is written in PowerShell and is available as an open source project on GitHub. Both Microsoft and the PowerShell Community are fully invested in PowerShell. In fact if you look at the GitHub repo for PowerShell Core you will see that the PowerShell cmdlets are tested with Pester, and perhaps even more confusingly, the Pester module is tested with Pester.

You can install it by simply running: `Install-Module Pester`. It comes pre-installed on Windows 10 and Server 2016, but its now quite out of date so its worth installing the latest version on those Operating Systems by running `Install-Module Pester -Force -SkipPublisherCheck`.

## > Testing Strategies

Pester is a versatile tool that can be used to enable a variety of testing strategies. These include:

- Operational Validation : Where you write tests to validate a system is configured and/or operating in the way you expect.
- Integration Testing : Is the concept of validating the final outcome of your code is what you expect it to be and that your code works correctly with any other software it interacts (or integrates) with.
- Unit Testing : Is the concept of testing your code as a series of individual pieces, where each piece (or unit) of code does just one thing.

This session is primarily focussed on using Pester for Unit Testing, but using Pester for Operational Validation can be sometimes easier to understand and a good way to master the Pester syntax.

## > Why should you write tests?

So why should you be using Pester and writing tests for your code? Well the fact is you are of course already testing your code, as I am sure you run your code manually many times during its development to validate that its doing what you expect it to.

Pester is just a way to supplement that testing to make it more detailed and thorough.

Ultimately the ideal scenario is to have a Continuous Integration / Continuous Delivery pipeline that tests your code automatically when it changes. This is beyond the scope of this session but there is lots of guides online for implementing a pipeline for your PowerShell code and its something I now wouldn't go without. Testing is a prerequisite for this concept because you need to validate your code works in some automated fashion to decide whether your pipeline should deliver your new version of your code in to production.

Finally your tests act as a form of documentation. They describe in somewhat readable terms how you, the developer, expected your code to run.

## > You are a developer

And yes, you are a developer. Imposter Syndrome is something we likely all feel on occasion and I personally long felt like knowing PowerShell didn't make me a "real" programmer or developer because its designed around system administration. But the fact is that however simple their initial intent, the tools that we develop have a tendency (over time) to become incorporated in business processes of ever growing importance. Ensuring that these tools work correctly today and in the future is fundamental.

I imagine also that the majority of PowerShell developers (like myself) come from an operations background and unless you're in a DevOps mature organisation, developer concepts are like testing are fairly foreign to you. However if you are writing any code, you are a developer and learning to write and maintain tests is fundamental.

## > PowerShell Code Maturity

There's one last thing I need to cover before we get started with Pester, and that is this PowerShell Code Maturity model that i've mocked up.

This is the rough path that I followed as I gained experience and confidence with PowerShell.

- I started by writing PowerShell one liners in to the console to interrogate or change a system.
- Then I started to build up a collection of short .ps1 scripts, where I had a series of commands that I wanted to run.
- Then I started to understand Functions and incorporate them in my scripts to make my code more efficient, but those functions lived at the top and some PowerShell commands immediately invoked them at the bottom.
- Next I started to create .ps1 scripts that were just Functions so I could load a set of tools in to a session.
- This of course led to me storing and loading these tools as modules, which initially I just created a single .psm1 file that contained my collections of related functions.
- Then I started to learn about how it was better to organise modules by having each function in their own file, and dot sourcing them in to the .psm1. This made them easier to share and maintain, particularly in a source control system.
- Following this I learnt about the PowerShell Gallery and how if I included a manifest file with my module I could then publish it.
- And finally I reached a stage where I was generally implementing Continuous Integration and Continuous Delivery so that my modules were tested and published automatically when they changed.

As this graphic shows, you need to ideally by operating at at least the fourth stage, where your code exists as a series of functions in order to use Pester. There are ways to do testing at stage 3, but it is not ideal. 

Ultimately Pester needs to be able to read your code (by dot sourcing it) but then control how and when it executes in order to test it. The best way to enable this is to have your code in Functions.

## > Getting Started

OK so lets get stated with Pester! As I mentioned earlier, Pester is just a PowerShell script with some extra keywords and structure. The 5 most fundamental keywords you need to know are these:

- Describe
- Context
- It
- Should
- and Mock

You can (and likely will) incorporate any other PowerShell code you like in and around those statements.

Let's look at a simple example.

## > A Simple Example

This is sort of the "hello world" of Pester examples, because you'll often see it used and its not particularly useful code. But it does demonstrate 3 of the 5 keywords from the previous slide. The function at the top is the code we're  testing and this would be in a separate file as I'll demonstrate in a moment.

Our Pester script starts with a `Describe { }` block. We need at least one `Describe` block to contain our tests -- You can't declare an It { } block outside of a Describe.

It's worth noting also that the Describe block creates a scope in which our tests run, so you can have multiple `Describe` blocks in a single script and each then has its own scope.

> In case anyone isn't familiar with scopes, this simply means that things like variables that are created within the Describe block only exist until that block exits. Scoping is an important and powerful feature of Pester as it permits you to have multiple test scenarios without them polluting each other and impacting their results.

You give the `Describe` block a name, which can be anything you like but ideally you want it to indicate what you're testing, so a good standard is to name it after the function you are testing.

Within the Describe block we are performing two tests. Each of these tests are defined via the `It` block, which we also give a name, typically describing what we expect the successful outcome of the  test to be.

Within the `It` block is where our actual test occurs. Anything that happens inside an `It` that throw an exception will cause the test to be consider a failure. In these examples we are running our `Add-One` function with an input value and then we're piping the result to the 3rd Pester keyword here, `Should`. `Should` performs an assertion, in this example we're using the `-Be` assertion to state what we expect the result of our function to be 2 for the first test and 0 for the second test.

Lets now run this example and see what it looks like.

### >> Switch to Code Example #1

I find Visual Studio Code to be a really nice editor for writing Pester because of this split view which allows you to have your test script and the code you're testing side by side.

Note how my Pester test is a separate file and its named .tests.ps1. By doing this we make the script discoverable by Pester's `Invoke-Pester` command, which by default will execute any tests under the current directory and subdirectories that are named .tests.ps1.

You can then see that I am dot sourcing the script that contains my function at the top. By dot sourcing i'm executing my script in to the scope of the test script, making the function declared and available.

> Here you can see why code that isn't inside a function is difficult to test. I would have no way to load it in to my test script without having it simultaneously execute.

Lets now run this test with Pester's `Invoke-Pester` command.

```
Invoke-Pester ./1-SimpleExample.tests.ps1
```

Pester generates this pretty output with the results of my tests. You can see the name of the test script that ran, then you can see my Describe block and the tests it contained. The + and green tests show me they passed and it also tells me how long each test took to execute at the end.

Lets look at a test failure. While writing this simple example, I initially didn't strongly type $Number as [int]. Lets take that away and see what happens.

> Edit file to remove [int]
> rerun pester.

So now we can see that my function no longer handles negative numbers, because PowerShell is treating my input as a string by default. 

This just goes to show you can have a function as simple as this and just two tests in you can discover that it doesn't work entirely the way you expected.

## > A more realistic example

OK lets now look at a more realistic example. Here I have a function for cleaning up temp files from a specified path. First it retrieves any files from the path that are named *.tmp and then it pipes those files to `Remove-Item`.

In my Pester script, I am using `New-Item` to create a test file for it to work with.

My Pester script is testing for three things, that the function returns no output, which is what I expect, that the test file I create in /tmp is removed and that it doesn't throw an exception.

This is an example of the unit testing pattern:

Arrange
Act
Assert

I use `New-Item` to arrange the necessary input file needed for my test.

I execute my function to act upon my input file.

Then I use `Should` to assert two different results that I expect.

Note here that i'm testing that my code doesn't throw and exception. Pester provides an assertion operator for this which you you can see is `-Throw` and I am negating this by adding `-Not` to it. You can use `-Not` to negate any of Pesters assertions. Note also that `-Throw` is a special case that requires the input to `Should` to be a script block, hence why there are extra curly braces around the code being input for this test.

While these tests are OK, the way my function is currently designed means that I can only really test that it removes one or more files. 

What might be better would be if I could test that the `Get-ChildItem` part is selecting the correct files to start with.

To test this, I need to do some "Refactoring".

## > Refactoring

Refactoring is the concept of restructuring your code without changing its overall behaviour. Generally that means breaking your code in to smaller pieces, which is useful when you're doing unit testing because you want to be able to test each individual "unit" of code independently, and a unit of code should do just one thing.

Refactoring code in this way can be a good thing in general, it can make the code easier to maintain by making each distinct piece more obvious and constrained.

## > A refactored example

OK so here's a refactored version of my code. I've now split it in to two functions, one that retrieves my temp files and then one that removes my temp files.

Note that I'm not asking my users to have to run Get-TempFile directly. In this example its intended to be a private/internal function that is used by the `Remove-TempFile` function. In this way the behaviour of my code has not changed, a user still calls `Remove-TempFile`.

I've also improved my test setup here a little, by including two files as inputs, of which I only expect one to be removed.

Now you might have noticed that when I refactored this code, I *accidentally* introduced a bug. Lets run the tests and see what happens.

> Run 3.

Ok so we can see that my test fails because there was a .doc file returned that I didn't want.

Let's fix the bug and rerun the tests to make sure it's solved.

> Fix bug and run 3 again.

It's worth noting that if I had found this bug without this test already existing, this is perhaps the kind of test I would then write.

It's a great practice to write a new test after each time you find a bug, even though you're of course simultaneously fixing the bug, because it just makes sure that bug doesn't inadvertently get reintroduced in the future and it also proves its fixed.

## > About TestDrive

So you might have noticed that after I refactored I also started to use a drive called TestDrive:/.

This is another great Pester concept, which is that it creates a randomly named folder under your system temp path that it mounts as a PSDrive called TestDrive:/. This is a safe space you can use to work on files that will be automatically cleaned up at the end of the current scope, for example the describe block. This means that for each describe block there is a unique/clean testdrive:. 

The testdrive: contents are also somewhat managed within Context blocks. I haven't mentioned Context yet, but its simply an optional way to create another scope for your testing. You can have multiple context blocks in a describe and its a great way to have multiple test scenarios that are scoped such that any output they generate doesn't pollute other tests.

## > Mocking

So you already have enough Pester knowledge to create some pretty comprehensive test scripts. But there's one more concept I want to introduce that is a very powerful feature of most test runners and that is Mocking.

Mocking, as its name suggests, is a way to replace some real part of your code with a simulation. This can be useful for a number of reasons:

1. Often code you write will rely on external resources. For example, it might need to talk to an Active Directory domain to pull some users, or it might need to talk to some web-based API to pull some data. These resources might not always be available or accessible on the system where your tests run, which can be particularly true when you're using CICD to automate your tests on a build server.

2. Your code might make some kind of destructive or other change that is undesirable for the sake of testing. While I demonstrated earlier how you can use things like TestDrive:\ as a safe space to play with files, you don't always have the luxury of a test system to destroy. Or it can even be as simple as your code sends an email on completion and you don't want that email to go out every time you are running your tests.

3. Finally your code might use some secondary function that already has its own set of tests. If that's the case, it can be simpler to just mock its behaviour in its entirety rather than having to worry mocking any individual destructive or undesirable changes that it makes. If it has its own set of tests, you don't really need to test it again.

## > A mocking example

Building on the previous code example again, here's a simple example of a Mock.

Pester injects a Mock in to your code for you when you use the `Mock` statement to reference some cmdlet or function name. The `Mock` is then invoked instead of the real cmdlet or function. 

In this example, I've decided I don't want `Remove-Item` to actually execute when I test my script, because if I've introduced some terrible bug it might go deleting things I didn't want it to. Instead I want nothing to happen when `Remove-Item` is invoked, so after my Mock i've put an empty script block to show that. If you want your Mock to perform or return something, you can put any code you like in to the scriptblock of the mock to do that.

You might have noticed now that I have a new test that does a different kind of Assertion.

Here I'm using the Pester `Assert-MockCalled` command, which does exactly what it states and just validates that when my code ran my Mock was invoked. By doing this, I make sure that my code would still invoke `Remove-Item` when run for real. Note that I am also Asserting that it should have been invoked 1 time exactly by using those parameters on `Assert-MockCalled`. Its generally a good idea to use `-Times` and `-Exactly` on this Assertion so that you catch a bug that makes some command you've mocked run more times than you expected it to.

> Run 4 to demonstrate.

## > Mocking cmdlets that aren't present

There's a couple more things I want to call out about Mocking.

A function or cmdlet must exist to be mocked. But sometimes you might want to Mock some cmdlet that isn't available. For example, you might want to Mock Get-ADUser, and be able to run your tests on a system that doesn't have the Active Directory cmdlets. If you attempt to just Mock `Get-ADUser`, Pester will throw an exception that states the command you attempted to mock is not available. However you can work around this by just declaring the cmdlet or function you want to mock as an empty function first. This can seem a bit bizarre, but can also be very useful.

> Show and run 5 to demonstrate.

## > Code Coverage

The final feature of Pester that I want to introduce is Code Coverage. As I may have already said, you already have all you need to know to write some comprehensive tests. The Code Coverage feature of Pester is a way to help you see how thorough your testing is.

The Code Coverage feature works by identifying which commands are invoked when your tests run. By using it you can therefore see which parts of your code are effectively untested. 

The Code Coverage feature shows you a list of which commands are not covered and gives you a percentage score. There's a lot of debate about how useful or even dangerous operating on the basis of this score can be because:

- 100% code coverage does not mean 100% working code
- 100% code coverage can sometimes mean writing tests just for the sake of achieving 100% code coverage. This is a waste of time if those tests do nothing to really validate your code.

In general, having a high code coverage score is a good measure that your code is well tested, but again, don't rely on it exclusively.

## > Why is code coverage reporting useful?

So how is code coverage a useful tool? Well your code probably has various logic gates such as if statements, or switch statements, or even maybe try catch statements or loops. All of these constructs result in your code having multiple paths of execution. In fact even the simplest code is going to generally have at least two paths: succeed or fail.

Code Coverage reporting is really helpful in highlighting when your current set of tests aren't traverse a certain logical path of your code.

I have previously talked about this as thinking about your code as a maze and your tests as lab rats. You want to ensure your rats traverse every path of your maze.

## > How to use the code coverage feature of Pester

The Code Coverage feature is a parameter of `Invoke-Pester`. You need to provide it with the list of files that you want to evaluate for test coverage (it doesn't work this out automatically based on what your test files interact with). So generally the easiest thing to do is something like this example, where you grab all the .ps1 files via `Get-ChildItem`.

> Run:

```
Invoke-Pester ./5-MockingMissingFunctions.tests.ps1 -CodeCoverage ./5-MockingMissingFunctions.ps1
```

Look at Example #6 for additional code coverage and example of Context.

## > Summary

In summary, Pester is an important and valuable skill to have. I think we'll see it becoming a career requirement in the near future for any jobs that involve working with PowerShell.

You can do a great deal of good by just familiarising yourself with the basic keywords of Pester. In particular you should have a look at the official Pester wiki which is very detailed, in particular have a look at the different assertions that you can use with `Should` as there are many more than I covered.

As always, there's a very friendly PowerShell community ready to help you learn Pester. I personally like to keep an eye on the #Pester tag of StackOverflow.com and would love to see some more Pester questions come there as its a really nice place to work on programming problems. There's also the PowerShell.org forums, r/PowerShell on Reddit and the PowerShell Slack community. And please feel free to reach out to me directly if you think I can help.

Does anyone have any questions?