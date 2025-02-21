# Issues

- [ ] 2025-01-06-032209
  - howto
    - in PowerShell 5

      ```powershell
      'est uan sin ter ius ira veh eme nit ' | Write-ColorWheel
      ```

    - actual

      ```text
      Out-String : A parameter cannot be found that matches parameter name 'NoNewline'.
      At C:\Users\karlr\OneDrive\Documents\WindowsPowerShell\Scripts\PsFrivolous\script\Draw.ps1:232 char:32
      +                     Out-String -NoNewline:$NoNewline
      +                                ~~~~~~~~~~~
          + CategoryInfo          : InvalidArgument: (:) [Out-String], ParameterBindingException
          + FullyQualifiedErrorId : NamedParameterNotFound,Microsoft.PowerShell.Commands.OutStringCommand
      ```

- [x] 2023-11-11-131922
  - breaks PsQuickform
  - howto
    - pwsh

      ```powershell
      ./PsFrivolous/Get-Scripts.ps1 | % { . $_ }

      @"
      {
        "Preferences": {
          "Caption": "What"
        },
        "MenuSpecs": [
          {
            "Name": "MyWhat",
            "Type": "Field"
          }
        ]
      }
      "@ |
      ConvertFrom-Json |
      Show-QformMenu
      ```

  - actual
    - program hangs indefinitely and takes a long time to force-terminate

- [x] 2023-11-11-131450
  - typo: res/fontmap/Poison.json#g

---

[← Go Back](../readme.md)
