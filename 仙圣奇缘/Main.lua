--------------------------------------------------------------------------------------
-- 文件名:	Main.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-7-31 11:24
-- 版  本:	1.0
-- 描  述:	程序主入口
-- 应  用:  
---------------------------------------------------------------------------------------
--跟安装包的版本一致 因为此文件是不会走自动更新的文件夹
--强制类型 360测试的专用服务器. 临时增加测试服

-- 游戏类型 服务器定义的在probuf maroc 文件中。要预先确定版本类型
local GameNameType =
{
	GameNameType_DSX = 1,		-- 大神仙
	GameNameType_LTJ = 2,		-- 逆天记
    GameNameType_XJQT = 3		-- 仙剑奇谭
}

GameType = GameNameType.GameNameType_DSX

--添加全局变量 退出游戏通知服务器消息 等外网统一发包的时候这个变量删除
--兼容老的API
g_OnExitGame = true

--游戏状态全局变量 在进入注成后 为 true
g_In_Game = false

g_IsXianShengQingYuan = true --仙圣情缘Logo
g_IsXiaoXiaoXianSheng = false --小小仙圣Logo
g_IsXianJianQiTan = false --新仙剑奇谭Logo
g_IsShenYuLing = false --神御灵Logo
--g_bVersionTS_0_0_ = "xiaoaoIOS_2.0.0"  --提审用版本 
g_bVersionAndroid_0_0_ = "jinli_1.0.1"  --安卓版本

--全局标识 如果有lua报错 那在第一次进入主界界面的时候会重新加载一次lua
G_Load = false 
--加载文件
function g_LoadFile(filename)
	package.loaded[filename] = nil
	require(filename)
end

function SendError(strError)
	local rootMsg = xxz_msg_pb.xxz_Msg()
	rootMsg.msgid = msgid_pb.MSGID_SHOW_CLIENT_ERROR_INFO
	rootMsg.uin = g_MsgMgr:getUin()
	rootMsg.platform = g_MsgMgr.loginPlatform
	rootMsg.account = CCUserDefault:sharedUserDefault():getStringForKey("DailyAccount", "")--self.szAccount
	rootMsg.session_key = g_MsgMgr.szSessionKey
	rootMsg.account_id = g_GamePlatformSystem:GetAccount_PlatformID()
	rootMsg.platform = g_GamePlatformSystem:GetServerPlatformType()
	rootMsg.session_token = g_MsgMgr:GetSession_token()
	--输出异常
	rootMsg.client_debug_info = strError

	local szMsgData = rootMsg:SerializeToString()
	API_SendMessage(string.len(szMsgData), szMsgData)
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    local strError = "-----------------__G__TRACKBACK__-----------------------\n"..
                    "LUA ERROR: " .. tostring(msg) .. "\n"..
                    debug.traceback()..
                    "\n-----------------__G__TRACKBACK__-----------------------\n"
	cclog(strError)

	--异常 发送错误消息给服务器
	SendError(strError)
	G_Load = true 
	-- __G__TRACKBACK__ = function ()
	-- end
end


g_LResPath = 
{
    ["LRT_NONE"] = {ui = "GameUI" , cfg = "Config"} ,               --大陆资源
    ["LRT_VIET"] = {ui = "GameUI_viet" , cfg = "Config_viet"} ,     --越南资源
    ["LRT_CHT"] = {ui = "GameUI_cht" , cfg = "Config_cht"} ,        --台湾繁体资源
	["LRT_AUDIT"] = {ui = "GameUI_audit" , cfg = "Config_audit"} ,        --版号审查
}

--只供策划测试使用，出包时一律“LRT_NONE”
LResType = "LRT_NONE" --

local function initGame()
	-- avoid memory leak
	
	CCTexture2D:PVRImagesHavePremultipliedAlpha(true)
    CCFileUtils:sharedFileUtils():addSearchPath(g_LResPath[LResType].ui)
	--增加热更新目录
    
	g_LoadFile("LuaScripts/GameLogic/GlobalConfig/Config_DebugCfg")
	CCFileUtils:sharedFileUtils():addSearchPath(g_writepath.."GameUI/")
    
	g_LoadFile("LuaScripts/FrameWork/functions")
	--Spine骨骼动画文件，UpdateFile那里要创建骨骼动画
	g_LoadFile("LuaScripts/GameLogic/GlobalFunc/GFunc_SpineAnimation")
	--Loading代码
    g_LoadFile("LuaScripts/Login/LYP_Loading")
end

local function main()


	initGame()



	local sceneGame = LYP_GetLoadingScene()
	CCDirector:sharedDirector():runWithScene(sceneGame)
	
	
	
end

xpcall(main, __G__TRACKBACK__)