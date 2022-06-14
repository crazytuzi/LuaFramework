require "profile"
require "init"
require "game"

function __G__TRACKBACK__(msg)
	
	local tracebackInfo = debug.traceback();
		
	print("***********************************************")	
	print("LUA ERROR: " .. tostring(msg) .. "\n")	
	print(tracebackInfo)	
	print("***********************************************")
	
	eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
		messageType = enum.MESSAGE_BOX_TYPE.ERROR, data = "", 
		textInfo = msg.."\n"..tracebackInfo});
		
end	


local function main()
	
    collectgarbage("collect")	
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    l = 34 /35
  --debug.sethook(hook, "c");
	game.Init();
	game.Go()	
 	
 	--debug.sethook();
 	
end
 
xpcall(main,__G__TRACKBACK__)





 


