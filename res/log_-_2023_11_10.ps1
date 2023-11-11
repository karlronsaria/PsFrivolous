$cat = cat .\edge.json

(0 .. $cat.Length) |
  foreach {
    if ($cat[$_] -match "`"Length`": 0,") {
      $cat[$_] -replace `
        "0", `
        "$([Regex]::Match($cat[$_ + 2], "(?<=`")[^`"]+(?=`")").Value.Length)" `
    }
    else {
      $cat[$_]
    }
  }
