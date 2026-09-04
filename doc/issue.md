# Issues

- [ ] issue 2026-08-22
  - where: MoonPhase
  - howto: ``Get-MoonPhase``
  - actual

    ```text
    Invoke-WebRequest: C:\shortcut\pwsh\Scripts\PsFrivolous\script\MoonPhase.ps1:15
    Line |
      15 |      $response = Invoke-WebRequest -Uri $uri
         |      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         | Just a
         | moment&hellip;p{line-height:1.6}.j{font-weight:700}.a{background-color:#5b9ec9;font-family:'Roboto',Helvetica,"Ubuntu
         | Light",Arial,Sans-Serif;color:#fff;letter-spacing:.5px}.b{max-width:650px;margin:200px
         | auto}.c{opacity:.7;display:inline-block}.c:hover{opacity:1}.d{margin:10px 0
         | 0;font-size:82px;font-weight:900;color:#fff}.e{font-size:12px;font-weight:400;color:#bed8e9}.f{font-size:32px;font-weight:100;padding-top:8px}.g{margin:50px 0}.h{background:#fff;color:#5b9ec9;font-size:12px;font-weight:700;border:2px solid #fff;border-radius:25px;padding:18px 24px;text-decoration:none;margin-right:15px}.i{color:#fff;background:0 0}.h:hover{background:#333;border-color:#333;color:#fff}Just a moment&hellip;Enable JavaScript and cookies to continue(function(){window._cf_chl_opt = {cFPWv: 'b',cH: 'ea6sBdkSVSWtIk42hW.YVcPzrww5hN4MvUd8tCTs4b0-1787393613-1.2.1.1-loJ86JI51H3SYrQAcqKTWjoMIYR5NoGLWKBgmqEi_kiopG_7pNmrO8aZFaZ9QThr',cITimeS: '1787393613',cRay: 'a2f11b02ea4e23de',cTplB: '0',cTplC:1,cTplO:0,cTplV:5,cType: 'managed',cUPMDTk:"/moon/phases/?__cf_chl_tk=2dKxxGEEK7W1.Gk1sZV64V0JKpmMEwoon6FfJwGiL70-1787393613-1.0.1.1-7WExlmPV3WCMB0.tDb2hwGz38gwdytKUFtZ38PRxsRM",cvId: '3',cZone: 'www.timeanddate.com',fa:"/moon/phases/?__cf_chl_f_tk=2dKxxGEEK7W1.Gk1sZV64V0JKpmMEwoon6FfJwGiL70-1787393613-1.0.1.1-7WExlmPV3WCMB0.tDb2hwGz38gwdytKUFtZ38PRxsRM",md: 'hhXnXLH.Gf1TOX_3p5fPgO5zQEdnLQXNwc4ro_i7PkE-1787393613-1.2.1.1-Lg_f8WEV9uULpgQFZpxVABLLTmBheYfT1769EDGhkmQVmYDUVL0Hdt_MXutOEoY4xMxqqM7PyX_fmeUzyiv7OIRbg.K3UH5DF2zPo1Ax7pprQwWgvb0SF85pqDREIKo9uleer2RFo3GiXNt4JkU.1BLHZUIOD0QOV4WZvIFvUR0wMRzMbfC3SsiiqZaYC0O41dXiIRobjfRgTFFbLIm7PZEUYMC5ymBwaPW7KPxmj157cKcPp7yr7cE7tM3goGJIneHzo9DKl41BEjyxF0EFB1PWBxjVBCQ3G3d._yNzyJ0uy1s845MZ7OpCD3BgG0H8dk5AemyskLHG7KMjNud5MKG3xjcTw0bH5WBCAkjGtO0kpWACoUWrl00mn2MmWU9d7N35ob189tousPjNDvrgVBXR9HX_nA9JJ283T5M9ChQ_8nTnBC8umk1.s1tn_cEo56Dcrdx2V2sIDuaZ4R1gQKDOBRrSLLWolLXp81lv0RXmLXepiaoSWhNuXKA5ep_I.ARBLNkZhtjZMoYVv4u81ovUZKBxF6xC19iZdPMvxO6HZLHeF9H4_KEfBp84HLOIelOQgucVPwSIGMD1YSnBm7t6DoeSV4Pg7XC.uBPutLRFitC4_0rcjuXaU3NOuFBiG0L6_lDUq3jJvB9Acw6uyB6niJQQhFcws4nKLDmiv41TQphMUrbyNid3N7WYVulX_hmjxXasfqUJ6D7uoHdJJZ3cddhYiWOTm4Cnwa6kR9KMWryMkRRr_DZgoRS0cu.fJSdX7vJdWl2uzZCIzQ9lw1ILiAKa9AIOK3hpPCHLQlVsP.1WN50Jt9UXIyvTYU8.WH3n1g0RdW49y8.kIRLrxCa9I7rOMpb4jjMNyGFfL0uZ5o3QWXFd6Hw0qqWjlpXcPMij7YM_ygvtDW0BCwGsJD8FEL3wOust4niBk5lisa4bzn.YDpiOswd4N0ClN2mb.PN_OJ_7r0yTVUzYJsbiEnWx.fWOxo1ieTlQ0teAnDai.AfJv4PnZOLMnwEno8LDxQGUMLzYJDF38mVughI7g_zI17l6gFJeE2LfzaahOa6KU9FyT6vigIyJ_Vt9iGXL7ta2RqemLmKUUOTUIyOOqdpflD0cxW68HZta0spcwvQvV7XOqXcEwC9DNlAOKCDLRz4W4VdYjl30coxUhNES7Q',mdrd: '4CaoXK2YI47bdAgPk0LsUphg06dxsuK9cLTnEmIwU4M-1787393613-1.2.1.1-Xe3DUCnnpRl6u6ARiZ4QA3t4qXv0B1yXD7GJB9eI6udxmEInuDIuanBHNT5vtUdmMsxL0ESvtWst8v7pqyxfC8QSBsidMyKANLydiN2CNBeHaly0gLICm4luGomUrB_5yfgKUEFcoNssUuzIiFqogXW5Oqrj9LpYpWRe7LzTLZIENsBEoevWhPCQ6EGtmJz9V.5TDT8dI1rZSiluY7X7LgpAOYCW8TuayBLvybzOAjH33VqW.lG1DMWKoM_pL5189EL5nYfXpDwcIb5u.5myRA',};var a = document.createElement('script');a.src = '/cdn-cgi/challenge-platform/h/b/orchestrate/chl_page/v1?ray=a2f11b02ea4e23de';window._cf_chl_opt.cOgUHash = location.hash === '' && location.href.indexOf('#') !== -1 ? '#' : location.hash;window._cf_chl_opt.cOgUQuery = location.search === '' && location.href.slice(0, location.href.length - window._cf_chl_opt.cOgUHash.length).indexOf('?') !== -1 ? '?' : location.search;if (window.history && window.history.replaceState) {var ogU = location.pathname + window._cf_chl_opt.cOgUQuery + window._cf_chl_opt.cOgUHash;history.replaceState(null, null,"/moon/phases/?__cf_chl_rt_tk=2dKxxGEEK7W1.Gk1sZV64V0JKpmMEwoon6FfJwGiL70-1787393613-1.0.1.1-7WExlmPV3WCMB0.tDb2hwGz38gwdytKUFtZ38PRxsRM"+ window._cf_chl_opt.cOgUHash);a.onload = function() {history.replaceState(null, null, ogU);}}document.getElementsByTagName('head')[0].appendChild(a);}());Ray ID: a2f11b02ea4e23deReport Problem
    ```

- [ ] issue 2025-01-06-032209
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

- [x] issue 2023-11-11-131922
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

- [x] issue 2023-11-11-131450
  - typo: res/fontmap/Poison.json#g

---

[← Go Back](../readme.md)
