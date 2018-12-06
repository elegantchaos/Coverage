# Coverage

A tool which uses xcrun and xccov to extract a summary of the code coverage results from an Xcode coverage report.

```

Usage:
coverage <results-path> [<target>] [--showFiles] [--threshold=<amount>]

Arguments:
<results-path>        Path to the xcode results file.

<target>              The target to produce output for. If this is missing, output is produced for all targets.

Options:
--showFiles           Show coverage results for each file in the target(s).
--threshold=<amount>  Tf coverage is below this threshold, we will return a non-zero error code.

```
