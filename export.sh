godot --export "html5" export/html/index.html
#godot --export "mac" export/mac/dcsim-prototype.zip
godot --export "linux" export/linux/dcsim-prototype.x86_64
godot --export "windows" export/windows/dcsim-prototype.exe

butler push export/html/ vinzBad/dcsim-prototype:html-develop
#butler push export/mac/ vinzBad/dcsim-prototype:mac-develop
butler push export/linux/ vinzBad/dcsim-prototype:linux-develop
butler push export/windows/ vinzBad/dcsim-prototype:windows-develop