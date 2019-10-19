godot --export "html5" export/html/index.html
rem godot --export "mac" export/mac/dcsim-prototype.zip
godot --export "linux" export/linux/dcsim-prototype.x86_64
godot --export "windows" export/windows/dcsim-prototype.exe

rem butler push export/html/ vinzBad/dcsim-prototype:html-develop
rem butler push export/linux/ vinzBad/dcsim-prototype:linux-develop
rem butler push export/windows/ vinzBad/dcsim-prototype:windows-develop