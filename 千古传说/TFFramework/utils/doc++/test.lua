print('begin test')

local LuaDoc = require('TFFramework.LuaDoc')

--print(LuaDoc:readFile("f:/2013/MGE/Cocos2dx1.01/trunk/BaseGame/BaseGameLib/framework/client/manager/TFEventManager.lua"))

--local szRet = LuaDoc.run("f:/2013/MGE/Cocos2dx1.01/trunk/BaseGame/BaseGameLib/framework/client/manager", true)
local szRet = LuaDoc.runWithLuaCode("f:/2013/MGE/Cocos2dx1.01/trunk/BaseGame/BaseGameLib/framework/", true)
--LuaDoc.pt(szRet)

LuaDoc.write("f:/2013/MGE/Cocos2dx1.01/trunk/BaseGame/BaseGameLib/framework/utils/doc++/output.lua", LuaDoc.serialize(szRet))
