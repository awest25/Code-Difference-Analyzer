# Scheme Code Difference Analyzer

**Language**: Racket extension of Scheme <br/>
**Date**: Mar 2023 <br/>
**Repository**: [github.com/awest25/Code-Difference-Analyzer](https://github.com/awest25/Code-Difference-Analyzer)

## Background

The objective of this project is to create a tool that aids in the identification and analysis of similarities between different bodies of code, focusing specifically on the Racket extension of the Scheme programming language. By comparing two sets of Scheme expressions, this solution aims to highlight similarities and differences, providing an easily interpretable summary of the overlaps, aiding in the detection of potential plagiarism or unauthorized copying.

## Objective

Design a prototype for a Scheme procedure, `expr-compare`, that compares two Scheme expressions, `x` and `y`.

### Output

A difference summary in the form of a Scheme expression (a runnable program). If executed where the Scheme variable `%` is true, it behaves like `x`, and otherwise behaves like `y`.

### Key Features

1. To symbolize differences:
    - Use `if` expressions and `!` in identifiers.
    - Use `%` for situations where `x` is `#t` and `y` is `#f`. Use `(not %)` for the opposite scenario.
    - For discrepancies between `lambda` and `λ`, the summary uses `λ`.
    - In scenarios where `x` uses a bound variable `X` and `y` uses `Y`, the summary should represent it as `X!Y`.
  
2. The prototype should handle a subset of Racket expressions, including:
    - Literal constants
    - Identifiers
    - Function calls
    - Special forms like `(quote s- exp)`, `(lambda formals expr)`, `(λ formals body)`, and `(if test-expr expr expr)`.

3. Includes a `test-expr-compare` procedure to validate the `expr-compare` function.

4. Two Scheme expressions, `test-expr-x` and `test-expr-y`, to test the output by setting the `%` variable.

### Sample Use Cases

```scheme
(expr-compare 12 12) ⇒ 12
(expr-compare #t #f) ⇒ %
(expr-compare '(cons a lambda) '(cons a λ)) ⇒ (cons a (if % lambda λ))
```

## Included Functions

1. `expr-compare`: A Scheme procedure that implements the comparison and generation of difference summary.

2. `test-expr-compare`: A Scheme procedure that tests the `expr-compare` function's output.

3. `test-expr-x` and `test-expr-y`: Two Scheme variables containing data that exercises the entire specification of `expr-compare`.

4. Any auxiliary definitions that might be required.

## Quick Start

1. Clone the repository: `git clone github.com/awest25/Code-Difference-Analyzer`
2. Navigate to the directory: `cd Code-Difference-Analyzer`
3. Run the program: racket expr-compare.ss
4. Use expr-compare [as above](#sample-use-cases).
