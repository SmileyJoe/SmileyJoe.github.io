---
layout: post
title:  "Creating a custom gradle plugin for android"
date:   2017-10-13 17:27:16 +0200
categories: android gradle plugin
---

Using gradle plugins in your build scripts can provide alot of powerful benefits, this is a high level tutorial on how to build a custom plugin you can re-use over multiple projects.

# Custom gradle plugin for Android #

For more information on almost any step, please see [afterecho's](https://afterecho.uk/blog/) fantastic blog post (linked in the [Additional Resources](#additional-resources) section).

## Prep and tools ##

You will need the following installed.

1. [Intellij IDEA](https://www.jetbrains.com/idea/) the free community edition will be more then enough.
2. [Groovy](http://www.groovy-lang.org/) this should be installed when Android studio was installed.
3. [Gradle](http://gradle.org/) this should be installed when Android studio was installed.

## Project setup ##

1. In intellij create a new gradle project, select the options to add additional libraries for java and groovy. You'll need to provide the following details:
  - `GroupID` this is how your plugins will be grouped, its a good idea to stick to your java package convention of the reversal of your domain name.
  - `ArtifactID` the name of your plugin
  - `Version` this should be pre-populated as `1.0-SNAPSHOT`, you can leave that as is. The `SNAPSHOT` keyword will mean that everytime time your compile your archives a new version will be made that is time and date stamped, if you remove that and make your build version `1.0`, the archives will be overidden every time.

2. Now that we have the project setup, check if a `src` directory was created, if it was you can skip the next point and procede to making your packages.
  - Create a new directory with the following `src/main/groovy`, the `groovy` directory should be highlighted a different colour to indicate its a source directory.
  - Inside the `groovy` directory create your required packages.

3. We will need to add the following 2 `dependencies` in the `build.gradle` file that was generated.
```gradle
compile gradleApi()
compile localGroovy()
```

## Creating the plugin ##

To create the plugin we are going to need three things, the task classes that will be included, the plugin class that will set them all up and the properties file that will tell gradle where to find out plugin.

### Task class ###

Create a task that you want to be made available with the plugin, you can have as many as you want included with a plugin:

```groovy
import org.gradle.api.DefaultTask
import org.gradle.api.Project
import org.gradle.api.tasks.TaskAction

class ExampleTask extends DefaultTask{

    /**
     * We use this to add the task to the project, this doesn't have to be
     * done here, I put it here so everything with the task is kept in
     * the same place.
     *
     * @param project the project the task will be added to
     */
    static void init(Project project){
        // Create your task and give it a name //
        project.getTasks().create("exampleTask", ExampleTask.class)
    }

    /**
     * Standard constructor, we will use it to set some globals for the task.
     */
    ExampleTask() {
        // Set the group that your task will belong to, eg. upload, this will be seen //
        // in your ide, in android studio and intellij this will show up in the //
        // gradle window //
        group = "example"
        // A description to help everyone know what your task does //
        description = "Example task to print to the console"
    }

    /**
     * The function that runs when the task is called.
     * <p>
     * This can be called anything, what is important is the @TaskAction annotation
     *
     * @throws Exception
     */
    @TaskAction
    void example() throws Exception {
        // Perform task actions, we will just print something to the console //
        println("Running example task")
    }

}
```

### Plugin class ###

Create the main class for your plugin, this will be the class that is implemented when you plugin is applied:

```groovy
import org.gradle.api.Plugin
import org.gradle.api.Project
import task.ExampleTask

class ExamplePlugin implements Plugin<Project> {

    /**
     * This is the function that is run when the plugin is applied,
     * its the first thing that will run.
     *
     * @param project the project that the plugin is applied to
     */
    @Override
    void apply(Project project) {
        println("Applying Plugin")
        // Create all the tasks you want to be made available //
        // with the plugin //
        ExampleTask.init(project)
    }
}
```

### Properties File ###

The propertiese file will give your plugin a name that can be used with including it, aswell as tell gradle what class to find your plugin in, there are 3 simple steps to this:

1. Create the following directories `resources/META-INF/gradle-plugins` under the `src/main` directory. The `resources` directory might already exist from the project setup steps.

2. Create a new `.properties` file in the directory you just created, the name of this file will be the name of the plugin when it is applied, for example `io.smileyjoe.example.gradle.properties` would mean that this plugin would be used by calling `apply plugin: 'io.smileyjoe.gradle.example`.

3. This file contains a single line, `implementation-class=ExamplePlugin`, where `implementation-class` is pointing to your plugin class.

## Making a repository ##

This guide is just going to focus on making the repository locally inside the project, there are a couple of steps to this:

1. Add the following to the top of your `build.gradle`, this will allow us to run the task `uploadArchives` and have the archives added to the `repo` directory in the root of our project.

```gradle
apply plugin: 'maven'

uploadArchives {
    repositories {
        mavenDeployer {
            repository(url: uri('repo'))
        }
    }
}
```

2. Now that you have your compiled archives, its a good idea to add their path into your global `gradle.propertiese` this will help when you implement it into multiple projects, add the following to your global properties.

```gradle
EXAMPLE_PLUGIN_PATH = "<path_to_repo_directory>"
```

## Implementing the plugin ##

In your android application open the project level `build.gradle` and add the following.

1. In the `repositories` section in the `buildscript` section add.

```gradle
maven {
    // we can use the global gradle variable we created above //
    url uri(EXAMPLE_PLUGIN_PATH)
}
```

2. In the `dependencies` section in the `buildscript` section add the classpath, this uses the `GroupID`, `ArtifactID` and `Version` that we used in the [Project Setup](#project-setup)

```gradle
// <group_id>:<artifact_id>:<version> //
classpath 'io.smileyjoe.gradle.example:plugin:1.0'
```

The top of the file should look something like this now.

```gradle
buildscript {
    repositories {
        jcenter()
        maven {
            url uri(EXAMPLE_PLUGIN_PATH)
        }
    }
    dependencies {
        classpath 'io.smileyjoe.gradle.example:plugin:1.0'
        classpath 'com.android.tools.build:gradle:2.3.2'
    }
}
```

Now open the module level `build.gradle` file and apply the plugin at the top:

```gradle
apply plugin: 'io.smileyjoe.gradle.example'
```

## Additional Resources ##

This guide is largely based on the following pages.

1. [afterecho](https://afterecho.uk/blog/create-a-standalone-gradle-plugin-for-android-a-step-by-step-guide.html) has one of the best, if not the best, guides I could find on how to get this working.
2. [Andr? Diermann](https://medium.com/@q2ad/custom-gradle-plugin-in-java-5d04866e9e53) for help with having tasks as a seperate class.
3. [Stackoverflow](https://stackoverflow.com/questions/17664183/creating-a-gradle-custom-plugin-with-java) because stackoverflow.