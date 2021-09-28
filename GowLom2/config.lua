SHOW_GUIDE = false
NEED_LOAD_PROTOCOL = true

if NO_UPT_CONFIG then
	require("noupt.platformConfig")
	print("NO_UPT_CONFIG noupt.platformConfig")
else
	require("platformConfig")
	print("OLD CONFIG platformConfig")
end

if OPEN_PC_UPDATE then
	SKIP_UPT = false
end

return 
