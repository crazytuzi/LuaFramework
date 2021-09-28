--game.lua

local sharedApplication = CCApplication:sharedApplication()
local target = sharedApplication:getTargetPlatform()
if patchMe and patchMe("game") then return end  
if USE_FLAT_LUA == nil or USE_FLAT_LUA == "0" then 
	if target == kTargetIphone or target == kTargetIpad or target == kTargetAndroid or target == kTargetWindows then 
		FuncHelperUtil:loadChunkWithKeyAndSign("UF.zip", "44230CC0A6FC4079", "68B3A882-4A15-4844-9CDD-6FD80FC5FA67")
	end
end 

if LOAD_APP_ZIP == 1 then
    --CCLuaLoadChunksFromZip("app.zip")
    if target == kTargetIphone or target == kTargetIpad or target == kTargetAndroid  then
    	FuncHelperUtil:loadChunkWithKeyAndSign("app.zip", "D8C092100C7F487B", "927CC05C-BE89-4356-B36E-374333E05387")
    end
end

traceMem("before app run ")

print("USE_ENCRYPT_LUA is:"..(USE_ENCRYPT_LUA and "true" or "false")..", type is:"..type(USE_ENCRYPT_LUA))
if USE_ENCRYPT_LUA then 
    local key = "D8C092100C7F487B"
    local sign = "927CC05C-BE89-4356-B36E-374333E05387"
    FuncHelperUtil:setXXTeaKeyAndSign(key, #key, sign, #sign)
end

require("app.MyApp").new():run()

if SHOW_DEBUG_PANEL == 1 then 
	require("upgrade.ConfigLayer").initConfig()
end