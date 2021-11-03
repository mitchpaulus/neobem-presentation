---
title: "Neobem: The programmers choice for EnergyPlus"
author: "Mitchell T. Paulus"
institute: "Command Commissioning, LLC. & Texas A&M University"
date: "2021-11-04"
monofont: iosevka-medium
monofontoptions:
  - Path=/home/mp/.fonts/
  - Extension=.ttf
---

# Intro

## Intro

- Command Commissioning
- Building Optimization Group

## Topics

- Neobem
- Creating Your own DSL

## Goals

1. You know Neobem exists.
2. You are given the inspiration and confidence to possibly someday
   create your own useful little language.

## Ideal Prerequisites

- Know what EnergyPlus is, done some previous building energy
  simulations

- Some programming experience

- If not, that's okay! See previous goals

# Neobem

## Background

- EnergyPlus input files (\*.idf) are simple text files
- Look like:

  ```
  ObjectType,
    Field 1,
    Field 2;

  ObjectType2,
    Field 1,
    Field 2;
  ```

- Analogous to Assembly Language

## Existing Solutions

- IDFEditor (Can't program/parameterize)
- OpenStudio (Giving up control)
- `eplusr` (Don't want to learn R)
- `eppy` (Don't want to use Python)
- ModelKit (Don't want to use Ruby)

- Write in X favorite language?
  - Death by `print` statements

## Design Goals

- Superset[^1] of the IDF file
- Conceptually simple
- Aesthetically pleasing to read
- Cross Platform

[^1]: Not a *technically* perfect superset, but close enough

## What Neobem is

- A language to expressively parameterize an EnergyPlus model
- A corresponding compiler/transpiler
- A corresponding formatter

## What Neobem isn't

- A GUI program (as of now)
- An EnergyPlus parametric runner
- An EnergyPlus linter
- *A solution to all your energy modeling problems*

## Language Design

- Simple functional syntax
  - No classes/inheritance
  - No typing (as of now)
- Simple data loading
  - Built in loading of Excel, JSON, gbXML
  - `load({ 'type': 'Excel', 'path': 'my_data.xlsx' })`{.neobem}
- Simple importing
  - `import 'C:\path\to\file.nbem'`{.neobem}
  - `import 'https://website.com/file'`{.neobem}

## Unique Language Features

- Inline data tables
- Import from URL
- Non-ASCII keywords/operators (`λ`, `✓`, `✗`)
- Direct integration of Building Component Library (todo)

## Variable Assignment and Replacements

```neobem
# variable_name = expression

my_number = 10
a_string = 'Hello, World!'
```

## Variable Assignment and Replacements


:::: columns

:::: column

```neobem
version = '9.3'

Version,
  <version>;
```
::::

:::: column

```neobem
Version,
  9.3;
```

::::

::::

## Variable Assignment and Replacement - Python

```python
version = '9.3'

print(f"Version,\n{version}\n")
```

## Functions and Templates

```neobem
add_2 = \ num { num + 2 }

Version,
  <add_2(7)>;
```

## Functions and Templates

:::: columns

:::: column

\tiny

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

::::

:::: column

\tiny

```neobem
Schedule:Constant,
  Zone Space Temperature Schedule,  ! Name
  Zone Space Temperature Limits,  ! Schedule Type Limits Name
  22;                         ! Hourly Value

ScheduleTypeLimits,
  Zone Space Temperature Limits,  ! Name
  20,                         ! Lower Limit Value
  24,                         ! Upper Limit Value
  Continuous,                 ! Numeric Type [Continuous, Discrete]
  Temperature;                ! Unit Type
```

::::
::::

## Traditional Data Structures

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

## Inline Data Tables

\tiny

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

# How It's Made

## How to Create Your Own Language

- Basic Steps:
   - Lexing
   - Parsing
   - Code Generation

## Skip to the Good Part

Use a "Parser-Generator"!

## Tools for the First Two Steps

- [ANTLR: Another tool for language recognition](antlr.org)
- Bison: C++, C, Java
- Alex: Haskell
- Tree-Sitter: Many

## ANTLR Grammar Syntax

\scriptsize

```antlr
BOOLEAN_LITERAL_TRUE : 'true' | '✓' ;
BOOLEAN_LITERAL_FALSE : 'false' | '✗' ;
IDENTIFIER : [a-z][a-zA-Z0-9@_]* ;
COMMENT :  '!' .*? '\r'?'\n' ;
NEOBEM_COMMENT : '#' .*? '\r'?'\n' -> skip ;

NUMERIC : '-'?(([1-9][0-9]*|'0')('.'[0-9]+)? |
          ('.'[0-9]+))([eE]'-'?[0-9]+)? ;

STRING : '\'' .*? '\'' ;
OBJECT_TYPE : [A-Z][a-zA-Z0-9:]* -> pushMode(IDFOBJECT) ;
WS : [ \t\r\n]+ -> skip ;

mode IDFOBJECT;

FIELD : ~[,!;\r\n]+ ;
FIELD_SEP : ',' [ \t\r\n]* ;
OBJECT_COMMENT : '!' .*? '\r'?'\n' ;
OBJECT_TERMINATOR : ';' [ \t]* ('!' .*? '\r'?'\n')? -> popMode ;
OBJECT_WS : [ \t\r\n]+ -> skip ;
```

## ANTLR Targets

- Java
- C\# (Neobem)
- Python
- JavaScript
- Go
- C++
- Swift
- PHP
- Dart

## Why ANTLR?

Makes dealing with left-recursive productions extremely easy.

## Left-recursive productions

```
expression -> expression * expression
expression -> expression + expression
```

## Trees

![Example Parse Trees](../out.ps)

## Using ANTLR

Typically 'Walk' or 'Visit' the AST.

 - Example walk function:

   \small

   ```C#
   public void EnterVariableDeclaration(VariableDeclarationContext context) {
       _variables[context.name] = context.expression
   }
   ```

\normalsize


## Example Visitor

\scriptsize

```C#
public override Expression VisitMultDivide(NeobemParser.MultDivideContext context)
{
    var op = context.op.Text;

    Expression lhs = Visit(context.expression(0));
    Expression rhs = Visit(context.expression(1));

    var operatorFunction = _numericOperatorMapping[op];

    double newValue = operatorFunction(((NumericExpression)lhs).Value,
                                       ((NumericExpression)rhs).Value);
    return new NumericExpression(newValue);
}

```
## Existing Grammars

[https://github.com/antlr/grammars-v4](https://github.com/antlr/grammars-v4)

# What's Next?

## What's Next?

- [Building Component Library (BCL)](https://bcl.nrel.gov/)  integration
- Web compiler/playground
- Build standard library
- Improve surrounding tooling
- Modify/Tweak language for DOE-2 input files
- Fix all the bugs :(

## Contributing

- Currently an experimental language, subject to significant change
- Ask Questions on [Unmet Hours](https://unmethours.com/questions/) with Tag `neobem`.
- Check out the GitHub page at: [https://github.com/mitchpaulus/neobem](https://github.com/mitchpaulus/neobem)
- Use 'Discussions' tab for proposed ideas, Q&A

## Other References

- [Neobem homepage: neobem.io](https://neobem.io)
- [ANTLR homepage](https://www.antlr.org/)

