require('TFFramework.base.class')
	DEBUG = 1
require('init')
EditLua = require('Editor.EditLua')

function __G__TRACKBACK__(msg)
	print("----------------------------------------");
	local msg = "LUA ERROR: " .. tostring(msg) .. "/n"
	msg = msg .. debug.traceback()
	print(msg)
	TFLOGERROR(msg)
	bIsError = true
	print("----------------------------------------");
end

function main()
	TFDirector.EditorModel = true
	TFDirector:start()
	local gameStartup = require('LuaScript.TFGameStartup'):new()
	TFLogManager:sharedLogManager():TFFtpSetUpload(false)
	TFLogManager:sharedLogManager():setCanWriteInfo(true)
	-- me.Director:setDisplayStats(true)
	gameStartup:run()
	EditLua:init()
end
szGlobleResult = ""
nCmdNum = 0
function test(id, command, args)
	nCmdNum = nCmdNum + 1
	setGlobleString("")
	szGlobleResult = ""
	EditLua:cmd(id, command, args)
end

xpcall(main, __G__TRACKBACK__);
