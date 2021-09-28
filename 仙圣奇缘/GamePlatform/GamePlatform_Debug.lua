-- 文件名:	GamePlatform_Debug.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_Debug = class("GamePlatform_Debug", function () return PlatformBase:new() end)

GamePlatform_Debug.__index = GamePlatform_Debug

function GamePlatform_Debug:PlatformInit()

end

function GamePlatform_Debug:GetPlatformType()
	return CGamePlatform:GetPlatformType_Debug()
end
    
function GamePlatform_Debug:LoginPlatformSuccessCallBack(Account,  password)

end

function GamePlatform_Debug:LoginOutCallBack()

end
    
function GamePlatform_Debug:CenterDidShowCallBack()

end

function GamePlatform_Debug:CenterDidCloseCallBack()

end

function GamePlatform_Debug:GamePlatformStart()
	PlatformBase:GamePlatformStart()
end

function GamePlatform_Debug:GameConnectPlatform()
	
	g_ServerList:RequestLoginPlatform()
	
end

function GamePlatform_Debug:GameLoginOut()
	 --     g_MsgMgr:resetAccount()
		-- -- LblAccount:setText(g_MsgMgr.szAccount)
  --       AccountRegResponse(false)
        PlatformBase:GameLoginOut()
end


function GamePlatform_Debug:AccountRegResponse()
	return (g_MsgMgr.szAccount == "")
end
