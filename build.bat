:: Create GUI NRoD
nim c --app:gui nrod.nim
:: Create text-based NRoD
nim c --app:console --out:nrod_legacy nrod.nim
:: Use script to zip all the files required (1 or 2, depending if we want to separate Legacy from regular)

:: Languages?
:: Python - easy, but too easy
:: Ruby   - zipping has issues w/ images
:: Lua    - zip library?
:: Elixir - no idea how this dude works
:: -------------------------------
:: All the files required:
:: - assets folder
:: - nrod.exe
:: If Legacy mode:
:: - nrod_legacy.exe
:: - nrod_legacy.bat
::
:: Additional possible
:: - nrod.nim
:: - gui.nim
:: - aspects.nim        << not used yet
:: "Docs"
:: - modding_resources.md
:: - readme.md