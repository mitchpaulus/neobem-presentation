---
title: "Neobem: The cool new way to EnergyPlus"
author: "Mitchell T. Paulus"
date: "2021-11-04"
---

# Intro

- Command Commissioning
- Building Optimization Group

# Topics

- Neobem
- Creating Your own DSL

# Existing Solutions

- IDFEditor (Can't program/parameterize)
- OpenStudio (Giving up control)
- `eppy` (Don't want to use Python)
- ModelKit (Don't want to use Ruby)

- Write in X favorite language?
  - Death by `print` statements

# Design Goals

- Superset of the IDF file
- Conceptually simple
- Aesthetically pleasing to read

# What Neobem is

- A language to expressively parameterize an EnergyPlus model
- A corresponding compiler
- A formatter

# What Neobem isn't

- A GUI program
- An EnergyPlus parametric runner
- An EnergyPlus linter
- A solution to all your energy modeling problems


# Language Features

- Functional syntax
- Easy data loading
- Easy importing

# Variable Assignment and Replacements

```neobem
# variable_name = expression

my_number = 10
a_string = 'Hello, World!'
```

# Variable Assignment and Replacements

```neobem
version = '9.3'

Version,
  <version>;
```

# Functions and Templates

```neobem
add_2 = \ num { num + 2 }

Version,
  <add_2(7)>;
```

# Functions and Templates

```neobem
const_temp_schedule = \ name value lower upper {
Schedule:Constant,
  <name> Schedule, ! Name
  <name> Limits,   ! Schedule Type Limits Name
  <value>;         ! Hourly Value

ScheduleTypeLimits,
  <name> Limits, ! Name
  <lower>,       ! Lower Limit Value
  <upper>,       ! Upper Limit Value
  Continuous,    ! Numeric Type [Continuous, Discrete]
  Temperature;   ! Unit Type
}

print const_temp_schedule('Zone Space Temperature', 22, 20, 24)
```

# Traditional Data Structures

- Lists: `[1, 2, 3]`
- Associative Arrays (Structures):

  ```neobem
  my_thing: {
    'name': 'Mitch',
    'height (in)': 75
    'location': {
      'city': 'Dallas'
      'state': 'TX'
    }
  }
  ```

- Booleans: `true`, `false`, `✓`, `✗`

# Inline Data Tables

```neobem
zones =
________________________________________
'name'        | 'x_origin'  | 'y_origin'
--------------|-------------|-----------
'Bedroom'     | 0           | 0
'Living Room' | 10          | 20
'Kitchen'     | 5           | 12
________________________________________

zone_template = λ zone {
Zone,
  <zone.'name'>,     ! Name
  0,                 ! Direction of Relative North {deg}
  <zone.'x_origin'>, ! X Origin {m}
  <zone.'y_origin'>, ! Y Origin {m}
  0,                 ! Z Origin {m}
  1,                 ! Type
  1,                 ! Multiplier
  autocalculate,     ! Ceiling Height {m}
  autocalculate,     ! Volume {m3}
  autocalculate,     ! Floor Area {m2}
  ,                  ! Zone Inside Convection Algorithm
  ,                  ! Zone Outside Convection Algorithm
  Yes;               ! Part of Total Floor Area
}

print map(zones, zone_template)
```

# How to Create Your Own Language

- Basic Steps:
   - Lexing
   - Parsing
   - Code Generation

# Skip to the Good Parts

Use a "Parser-Generator"!

# Tools for the First Two Steps

[ANTLR: Another tool for language recognition](antlr.org)

# ANTLR Grammar Syntax

```
```

# ANTLR Targets

- Java
- C\# (Neobem)
- Python
- JavaScript
- Go
- C++
- Swift
- PHP
- Dart

# Using ANTLR

Typically 'Walk' or 'Visit' the AST.

# Existing Grammars

[https://github.com/antlr/grammars-v4](https://github.com/antlr/grammars-v4)

# Contributing

- Currently an experimental language, subject to change
- Ask Questions on [Unmet Hours](https://unmethours.com/questions/) with Tag `neobem`.
- Check out the GitHub page at: [https://github.com/mitchpaulus/neobem](https://github.com/mitchpaulus/neobem)
- Use 'Discussions' tab for proposed ideas, Q&A

# Other References

- [Neobem homepage: neobem.io](https://neobem.io)
- [ANTLR homepage](https://www.antlr.org/)

