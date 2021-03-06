# Experiments with LMOD

## Family doesn't work the same as versions of a module

Consider the experiment in the ``Family`` subdirectory.

Initialize the experiment by only setting the ``Family/Core`` subdirectory in the MODULEPATH.

### Loading two modules with a the same name but different version: order of load and unload

Consider (some output deleted, only the first line of each operation shown)
``` bash
$ module load famexp/a
DEBUG: famexp/a, mode load
$ module load famexp/b
DEBUG: famexp/a, mode unload
DEBUG: famexp/b, mode load

The following have been reloaded with a version change:
  1) famexp/a => famexp/b

```
LMOD does what we would expect: Since we are loading a different version of the same
module, the module that was loaded is first unloaded and then the new module is loaded.

### Loading two modules with a different name from the same family: order of load and unload

Now try again in a re-initialised environment:
``` bash
$ module load famexp_c
DEBUG: famexp_c, mode load
$ module load famexp_d
DEBUG: famexp_d, mode load

Lmod is automatically replacing "famexp_c" with "famexp_d".

DEBUG: famexp_c, mode unload
DEBUG: famexp_d, mode unload
DEBUG: famexp_d, mode load
```
The behaviour that we observe now is different from what we would hope. Since the modules
have a different name, LMOD has no way of knowing that both modules are of the same
family and that ``famexp_d`` should replace ``famexp_c``. So it is only normal that
it first starts to load ``famexp_d``. However, one would hope that as it sees the module
belongs to a family, the commands are not executed and instead ``famexp_c`` is first
unloaded. Or that if it load ``famexp_d``, that it would at least first unload it again
to try to re-create the situation of before loading ``famexp_d``. This does not happen.
Instead Lmod proceeds first unloading ``famexp_c``, then unloading ``famexp_d`` and
then loading ``famexp_d`` again which to me seems completely unlogical.

It would be much better Lmod would first do a discovery of a module when loading a
module to see if it belongs to a family (and maybe discover other conflicts?), then
go on to first unload the previously loaded module of that family and finally loading
the new one, something like
``` bash
$ module load famexp_c
DEBUG: famexp_c, mode discovery
DEBUG: famexp_c, mode load
$ module load famexp_d
DEBUG: famexp_d, mode discovery

Lmod is automatically replacing "famexp_c" with "famexp_d".

DEBUG: famexp_c, mode unload
DEBUG: famexp_d, mode load
```
which for the first experiment would have been
``` bash
$ module load famexp/a
DEBUG: famexp/a, mode discovery
DEBUG: famexp/a, mode load
$ module load famexp/b
DEBUG: famexp/a, mode unload
DEBUG: famexp/b, mode discovery
DEBUG: famexp/b, mode load

The following have been reloaded with a version change:
  1) famexp/a => famexp/b

```
and would in most if not all cases have resulted in identical effects (unless the module
file is not written properly and makes changes in one way or another to the environment
in the discovery mode, e.g., through running shell commands).

This behaviour can have very nasty consequences in hierarchies if there is communication
between layers in the hierarchy through environment variables. The latter can be very
useful if you want a generic module in the next (higher) level in the hierarchy that behaves
differently depending on what is done in the (lower) level of the hierarchy. And this
is very useful to provide one implementation for a module that is used at the higher
level in different branches of the hierarchy with only subtle differences. It could
then be linked to a generic module that is stored elsewhere, reducing the amount of
code to deal with and ensuring that all versions remain consistent. Of course the same
could be obtained with some scripting and use of a general purpose preprocessor, but
this may not come in so handy.

### Loading two modules with a different name from the same family: The consequences

Now assume that each module in the family does the same thing:
  * It sets a variable ``FAMEXP_MODULE`` to the letter that denotes its version.
  * It uses pushenv to set the variable ``FAMEXP_PUSH`` to the letter that denotes
    its version.
  * It adds a subdirectory to the MODULEPATH to the ``famexp_x`` subdirectory with
    ``x`` again the letter corresponding to its version.

Now consider gain what happens when we load ``famexp_d`` after having loaded ``famexp_c``
in a clean environment:

```bash
$ module load famexp_c
DEBUG: famexp_c, mode load
DEBUG: famexp_c, at the start:
  * FAMEXP_MODULE = NOT SET
  * FAMEXP_PUSH = NOT SET
  * MODULEPATH = /home/klust/experiments-Grenoble/LMOD/Family/Core:/home/klust/experiments-Grenoble/modules/testview
DEBUG: famexp_c, at the start:
  * FAMEXP_MODULE = c
  * FAMEXP_PUSH = c
  * MODULEPATH =
/home/klust/experiments-Grenoble/LMOD/Family/famexp_c:/home/klust/experiments-Grenoble/LMOD/Family/Core:/home/klust/experiments-Grenoble/modules/testview

$ module load famexp_d
DEBUG: famexp_d, mode load
DEBUG: famexp_d, at the start:
  * FAMEXP_MODULE = c
  * FAMEXP_PUSH = c
  * MODULEPATH =
/home/klust/experiments-Grenoble/LMOD/Family/famexp_c:/home/klust/experiments-Grenoble/LMOD/Family/Core:/home/klust/experiments-Grenoble/modules/testview
DEBUG: famexp_d, at the start:
  * FAMEXP_MODULE = d
  * FAMEXP_PUSH = d
  * MODULEPATH =
/home/klust/experiments-Grenoble/LMOD/Family/famexp_d:/home/klust/experiments-Grenoble/LMOD/Family/famexp_c:/home/klust/experiments-Grenoble/LMOD/Family/Core:/home/klust/experiments-Grenoble/modules/testview


Lmod is automatically replacing "famexp_c" with "famexp_d".

DEBUG: famexp_c, mode unload
DEBUG: famexp_c, at the start:
  * FAMEXP_MODULE = d
  * FAMEXP_PUSH = d
  * MODULEPATH =
/home/klust/experiments-Grenoble/LMOD/Family/famexp_d:/home/klust/experiments-Grenoble/LMOD/Family/famexp_c:/home/klust/experiments-Grenoble/LMOD/Family/Core:/home/klust/experiments-Grenoble/modules/testview
DEBUG: famexp_c, at the start:
  * FAMEXP_MODULE = NOT SET
  * FAMEXP_PUSH = c
  * MODULEPATH =
/home/klust/experiments-Grenoble/LMOD/Family/famexp_d:/home/klust/experiments-Grenoble/LMOD/Family/Core:/home/klust/experiments-Grenoble/modules/testview

DEBUG: famexp_d, mode unload
DEBUG: famexp_d, at the start:
  * FAMEXP_MODULE = NOT SET
  * FAMEXP_PUSH = c
  * MODULEPATH =
/home/klust/experiments-Grenoble/LMOD/Family/famexp_d:/home/klust/experiments-Grenoble/LMOD/Family/Core:/home/klust/experiments-Grenoble/modules/testview
DEBUG: famexp_d, at the start:
  * FAMEXP_MODULE = NOT SET
  * FAMEXP_PUSH = NOT SET
  * MODULEPATH = /home/klust/experiments-Grenoble/LMOD/Family/Core:/home/klust/experiments-Grenoble/modules/testview

DEBUG: famexp_d, mode load
DEBUG: famexp_d, at the start:
  * FAMEXP_MODULE = NOT SET
  * FAMEXP_PUSH = NOT SET
  * MODULEPATH = /home/klust/experiments-Grenoble/LMOD/Family/Core:/home/klust/experiments-Grenoble/modules/testview
DEBUG: famexp_d, at the start:
  * FAMEXP_MODULE = d
  * FAMEXP_PUSH = d
  * MODULEPATH =
/home/klust/experiments-Grenoble/LMOD/Family/famexp_d:/home/klust/experiments-Grenoble/LMOD/Family/Core:/home/klust/experiments-Grenoble/modules/testview

```

Now consider again the four steps that are taken after issuing ``module load famexp_d``:

 1. First ``famexp_d`` is loaded as LMOD does not realise it is of the same family
    as ``famexp_c``.
      * When entering the module, ``FAMEXP_MODULE``, ``FAMEXP_PSU`` and ``MODULEPATH``
        have the values we expect.
      * When exiting however:
          * ``FAMEXP_MODULE`` now has the value ``d`` as one would expect when loading
            the module.
          * ``FAMEXP_PUSH`` now has the value ``d`` as one would expect when loading
            the module.
          * A directory is added to the front of the MODULEPATH. Note however that
            MODULEPATH now has the directories for both ``famexp_c`` and ``famexp_d``
            added to the MODULEPATH!

 2. Next ``famexp_c`` is unloaded.
      * When entering the module, ``famexp_c`` finds values of environment variables
        that it may not have expected and that it did not set:
          * ``FAMEXP_MODULE`` has the value ``d`` rather than the value ``c`` that
            it had set when loading.
          * ``FAMEXP_PUSH`` has the value ``d`` rather than the value ``c`` that it
            had set when loading.
          * ``MODULEPATH`` contains now both a ``famexp_c`` and a ``famexp_d``
            directory.
      * When exiting the module,
          * ``FAMEXP_MODULE`` is unset as one would expect after unloading this
            module.
          * ``FAMEXP_PUSH`` now has the value ``c``. It would have been unset had
            we just unloaded ``famexp_c`` in the state it left after loading.
            So it is actually the last value that gets pushed from the stack, not
            the value that ``famexp_c`` added when loading.

            **It does show however that ``pushenv`` doesn't care about its
            second argument when unloading, it simply pushes the top value from the
            stack also when that is not the same as the second argument.**
          * The right directory is removed from ``MODULEPATH`` but it does still
            contain a ``famexp_x`` subdirectory (``famexp_d``).

 3. Next ``famexp_d`` is again unloaded.
      * When entering the module, it doesn't find the state it left after loading:
          * ``FAMEXP_MODULE`` has already been unset.
          * ``FAMEXP_PUSH`` contains the value ``c`` rather than the value ``d`` that
            it had set.
          * The ``MODULEPATH`` is not as it had left the variable, but it is as it
            would have been had the sequence been ``unload famexp_c, load famex_d,
            unload famexp_d``.
      * When exiting the state is now clean though as it would have been had
        we unloaded ``famexp_c`` in the first step:
          * ``FAMEXP_MODULE`` and ``FAMEXP_PUSH`` are both unset as they were before
            we even loaded ``famexp_c`` at the start of the experiment.
          * ``MODULEPATH`` is also back to its initial value from the start of the
            experiment.

 4. Finally ``famexp_d`` is loaded again
      * When entering the module, it has a clean environment, as it would have had
        had we first unloaded ``famexp_c`` or as it was at the start of the experiment.
      * So at the end we also have the expected state.

Even though in this case we have reached the intended end state, it is important to
realise that this might not have been the case had we used ``FAMEXP_+MODULE`` or ``FAMEXP_PUSH``
to build arguments for ``prepend_path``. Since here we use only variables defined at
the same level of the module tree, there is probably no reasonable case where this
would be done. But things become different in the next section, when we study the effect
it can have on a hierarchy.


## Loading in a hierarchy

In the following example we build a hierarchy. At the second level of the hierarchy
there is a module called ``level_two`` that uses an environment variable set in the
module at the first level. The module has a version with the same name in each branch
of the hierarchy, so if we replace a module at the first level, it should get reloaded.


### Level 1 of the hierarchy: 2 modules with the same name but different version

First using versions of the same module at the first level:
```bash
$ module load famexp/a
DEBUG: famexp/a, mode load
$ module load level_two
DEBUG: ... LMOD/Family/famexp_a/level_two.lua, mode load
Found FAMEXP_MODULE = a
$ module load famexp/b
DEBUG: famexp/a, mode unload
DEBUG: LMOD/Family/famexp_a/level_two.lua, mode unload
Found FAMEXP_MODULE = UNSET
DEBUG: famexp/b, mode load
DEBUG: LMOD/Family/famexp_b/level_two.lua, mode load
Found FAMEXP_MODULE = b

Due to MODULEPATH changes, the following have been reloaded:
  1) level_two

The following have been reloaded with a version change:
  1) famexp/a => famexp/b
```
The last ``module load`` is the interesting one:

  * Instead of first unloading the module at level 2 of the hierarchy as one would hope if
    this would work as a stack, it first unloads ``famexp/a``. As a result, **``level_two``
    cannot see the value of the variable anymore that it picked up from the level 1 module
    so it may not correctly unload!** In particular, ``prepend_path`` where the addition to
    the path depends on the variable picked up from the environment, will generate the wrong
    argument for the ``prepend_path`` function and hence will fail to remove the directory
    form the PATH variable.

  * In this case, rebuilding the loaded module stack works as expected: First ``famexp/b``
    is loaded and then ``level_two`` is loaded so it has the expected behaviour.

The lesson from this case is that we must ensure that the module at level two will
unload correctly even if no module at level one is loaded anymore. This does restrict
what we can do in the module. It should be able to remember all information it needs
to correctly unload which may be very non-trivial to accomplish.

### Level 1 of the hierarchy: Two modules with different name but same family

Now we do the same - starting from a clean environment - with the two level 1 modules
with a different name but same family. We only show some of the relevant output:
```bash
$ module load famexp_c
DEBUG: famexp_c, mode load
$ module load level_two
DEBUG: ... LMOD/Family/famexp_c/level_two.lua, mode load
Found FAMEXP_MODULE = c
$ module load famexp_d
DEBUG: famexp_d, mode load

Lmod is automatically replacing "famexp_c" with "famexp_d".

DEBUG: famexp_c, mode unload
DEBUG: famexp_d, mode unload
DEBUG: famexp_d, mode load
DEBUG: ... LMOD/Family/famexp_c/level_two.lua, mode unload
Found FAMEXP_MODULE = d
DEBUG: ... LMOD/Family/famexp_d/level_two.lua, mode load
Found FAMEXP_MODULE = d

Due to MODULEPATH changes, the following have been reloaded:
  1) level_two
```
The reloading of the ``level_two`` module will again not work as expected, but the
case will react differently due to the strange way in which ``family`` works in Lmod.
  * We get the same strange sequence of loads and unloads for the ``famexp_c`` and
    ``famexp_d`` modules.
  * However, the moment at which the ``level_two`` module gets
    unloded is different. It is no longer unloaded immediately after unloading
    ``famexp_c`` but only at the end of the sequence, after loading ``famexp_d`` a
    second time! So now the environment variable that ``level_two`` expects to find
    is present but it still has the wrong value as it already had the value that
    it gets from ``famexp_d`` rather than the value that it had from ``famexp_c``
    for the matching load. So rather than using environment variables, it should
    have used its place in the hierarchy as when unloading LMOD still correctly
    executes the version of ``level_two.lua`` that was loaded when ``famexp_c``
    was loaded.


## Playing around with HierarchyA in a software stack for a heterogeneous cluster

Assume that we have a cluster with various partitions on which we want to offer multiple
versions of a software stack (think various editions of the EasyBuild common toolchains
or similarly editions of the EESSI stack).

A good way to offer this software stack to users is through a two-level hierarchy,
and there are two options:

 1. Use the partition of the cluster as the first level, and the software stack as the
    second level. The system can then preload the partition module for the hardware
    on which the user logs on in ``.bashrc`` or so (though one would need to think
    about the consequences this would have when starting a job through Slurm as then
    the environment is inherited).

 2. Use the software stack as the first level and the partition as the second level.
    This is a nicer fit if there are also software stacks for which there are no worries
    with the different partition, e.g., the EESSI stack which has its own built-in
    mechanism to select the right binaries which would be in the software stack module
    itself if there would be a module, or a module just offering the bare system as
    delivered by the vendor, e.g., on a HPE-Cray system with the Cray Programming
    Environment.

For this example, we will go with the second setup,as it can be used to demonstrate
the ideosyncracies of the LMOD ``hierarchyA`` function for introspection.

Such a setup is useful for multiple reasons

 1. ``module spider`` can now tell you wich versions of which packages are available
    in which partitions of the cluster as when you do a level 2 ``module spider`` command
    (one specifying the full name and version of the package) it will tell you which
    combinations of software stack and partition modules you need to load to be able
    to load the module.

 2. If the partitions correspond to partitions in the cluster job system (rather than
    processor architectures as our example suggest)


### Setup of the hierarchy

Our setup is as follows. The choice of names doesn't entirely follow the typical
LMOD conventions, but our names make it clearer which type of modules are stored where.

 1. ``$MODULEROOT/SoftwareStack``: Contains the software stack modules

 2. ``$MODULEROOT/SystemPartition/EBcommon/2020b`` etc.: Contain the modules for the partitions,
    in this case the partitions for which the ``EBcommon/2020b`` software stack is available.

 3. ``$MODULEROOT/Applications/EBcommon/2020b/partition/SKL`` and similar: software for the
    software stack and partition indicated by the directory, in this case the ``EBcommon/2020b``
    for the ``partition/SKL`` partition of the cluster.

The third level may have a different structure, e.g., if a partition would correspond
to a cluster in a federated entity consisting of multiple clusters and multiple clusters
would have the same OS and processor and hence be able to share the software stack.
This would limit the use of introspection functions at level 3 and possible levels
beyond though as it is as if you start a new hierarchy at that level.

To experiment with this example, make sure that ``MODULEROOT`` points to the
``ClusterSoftware`` subdirectory of this repository and set ``MODULEPATH`` to
``$MODULEROOT/SoftwareStack``.

### LMOD introspection functions

As it is dangerous to pass information between levels of the hierarchy through environment
variables as we have seen in the previous section of this text, in particular if those
variables are used to compute directories that will be added to PATH-type variables
using ``preepend_path``or ``append_path``, we have to use the place of the module in the
hierarchy to derive its function.

For this purpose, and to be able to write generic module files that can then be linked
to from the various locations where they are used rather than having to use a preprocessor
to create the module files from templates, LMOD offers a number of introspection functions
[documented on the "LUA Modulefile Functions" page of the manual](https://lmod.readthedocs.io/en/latest/050_lua_modulefiles.html).

  * ``myModuleName()``: Returns the name of the current modulefile  without the version.

  * ``myModuleVersion()``: Returns the version of the current modulefile without the
    name.

  * ``myModuleFullName()``: Returns the name and version of the current module file as
    it would be used with ``module load``, so without the ``.lua`` extension if it
    is a LUA module file.

  * ``myFileName()``: Returns the absolute file name and path of the current modulefile.

  * ``hierarchyA (???fullName???, level)``: Returns the hierarchy of the current module.
    This is a tricky function to use though as (a) it doesn't seem to work when
    ``"fullname"`` is not the full name of the module calling the function (so the
    name as retuned by ``myModuleFullName()``) but (b) its interpretation of how the
    hierarchy is build depends on the format of the full name of the module. If the
    full module name is just of the type "name" without version, it assumes each level
    in the hierarchy corresponds to one level of subdirectories, while if the full
    module name is of the type "name/version" it will assume that each level in the
    hierarchy corresponds to two levels of subdirectories as is the case in our test
    hierarchy.

    ``hierarchyA`` is really a parser for the information returned by ``myFileName()``.

  * ``myModuleUsrName()``: Returns the name the user specified to load the module.
    It could be the name or the name and version, but also an alias.

Besides those introspection functions that give information about the module file that
is being executed, there are also introspection functions that give information about
the shell type but they don't matter in our discussion.

### The arguments of hierarchyA

The Lmod manual is not very clear about how ``hierarchyA`` works. According to the
manual it is called as ``hierarchyA (???fullName???, level)``. Our experience shows:

  * The "fullName" should be the correct full name of the module calling the function
    which frankly is strange that you need to add it as the module knows its name.

  * ``level`` is the number of levels in the hierarchy that should be returned. For
    this the function walks backwards in the path of the module, starting from just
    before the module name.

  * One level of the hierarchy can consist out of one or two level in the directory
    hierarchy. The way that Lmod determines whether it is one or two is strange at best:
    If the module name is of the form "name/version.lua", is assumes that in the directory
    hierarchy each level also consists of two elements (name and version), and if the
    module is just of the form "name.lua", is assumes each level in the hierarchy is
    also just a single level in the directory hierarchy. So if you mix both styles
    of modules you may have some manual parsing to do in the return values of
    ``hierachyA`` or use your own strategy for parsing the output of ``myFileName()``
    instead.

    E.g., in ``SystemPartition/EBcommon/2021a/Milan.lua``, a call to
    ``hierarchyA( myModuleFullName(), 1 )`` will only return
    ``{'2021a'}`` and a call to ``hierarchyA( myModuleFullName(), 2 )`` will
    return ``{'2021a`, `EBcommon`}`` while in
    ``SystemPartition/EBcommon/2021a/partition/Milan.lua``, a call to
    ``hierarchyA( myModuleFullName(), 1 )`` will return ``{'EBcommon/2021a'}``.

## Advanced hierarchy example: ClusterSoftwareAdv.

TODO: Show that the example works differently if SKL is loaded than when partition/SKL
is loaded if we change EXAMPLE_PARTITION to Milan and do a module reload.




