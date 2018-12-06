# Coverage

A tool which uses xcrun and xccov to extract a summary of the code coverage results from an Xcode coverage report.

```

Interpret XCode code coverage results.

Usage:
coverage <results-path> [<target>] [--showFiles] [--threshold=<amount>]
coverage --help

Arguments:
<results-path>        Path to the xcode results file.

<target>              The target to produce output for. If this is missing, output is produced for all targets.

Options:
--showFiles           Show coverage results for each file in the target(s).
--threshold=<amount>  Tf coverage is below this threshold, we will return a non-zero error code.

Exit Status:

The coverage command exits with one of the following values:

0   If the arguments were ok and the threshold was met (or not specified).
1   If there was an error parsing the arguments.
2   If the threshold wasn't met.

```

## Continuous Integration

You can use this tool in continuous integration runs, to check that your coverage remains above a certain threshold.

For example, to test whether the coverage project itself has a coverage of over 80%, you might do:

```
xcodebuild -workspace Coverage.xcworkspace -scheme Coverage -enableCodeCoverage YES test -resultBundlePath Test.xcresult
coverage Test.xcresult Coverage --threshold=0.8
if [[ $? != 0 ]];
  echo "Coverage is below the threshold"
  exit(1)
fi
```
