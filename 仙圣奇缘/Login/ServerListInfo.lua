--------------------------------------------------------------------------------------
-- 文件名:	ServerListInfo.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	从平台服获取服务器列表 然后 保存 最近的一个服务器。维护本地的服务器数据 登入流程修改
-- 应  用:  本例子是用类对象的方式实现
--[[
	table = 
	{
	uint32 port =1;		// 服务器端口
	string ip = 2;		// 服务器IP
	string name = 3;	// 服务器区名
	uint32 state = 4;	// 服务器状态，空闲，繁忙，拥挤...参见macro.pro的ServerState
	uint32 role_num = 5;// 服务器上的在线人数，不会发给客户端
	}
]]
---------------------------------------------------------------------------------------

----------------------------------------------这里修改平台类型--------------------------beg
--修改平台 ip 跟端口 没用 在
-- local GamePlatform_IP = 
-- {
-- 	GamePlatform_DEBUG 			= 1, --内网测试
-- 	GamePlatform_IOSYY 			= 2, --ios 越狱
-- 	GamePlatform_ANDROID 		= 3, --android 360 uc
-- 	GamePlatform_ANDROID_DEBUG 	= 4, --android 评测用
-- }
-- local ServerPlatform = GamePlatform_IP.GamePlatform_DEBUG

-- if g_Cfg.Platform == kTargetAndroid then
--     ServerPlatform = GamePlatform_IP.GamePlatform_ANDROID
    
-- elseif g_Cfg.Platform == kTargetIphone then
--     ServerPlatform = GamePlatform_IP.GamePlatform_IOSYY
-- end
----------------------------------------------这里修改平台类型--------------------------end


local Loading_State =
{
	Request_ServerList 				= 1,	--请求服务器列表
	Request_RoleInfo 				= 2,	--请求角色信息
	Request_RegistAccout 			= 3,	--请求注册账号
	Request_RegistAccoutSuccond 	= 4, 	--注册账号成功
	Request_Login					= 5, 	--请求登入
	Request_Logout					= 6,	--注销流程
	Request_ReConnect				= 7		--断线重连状态
}

ServerState_Client =
{
	SERVER_STATE_IDLE = 1,	-- 空闲状态
	SERVER_STATE_BUSY = 2,	-- 繁忙
	SERVER_STATE_CROWED= 3,	-- 拥挤
	SERVER_STATE_STOP = 4	-- 维护中
}

ServerListInfo = class("ServerListInfo")
ServerListInfo.__index = ServerListInfo

 --是否是注销后登入 在注销回调时为true 在帐号注册或则登入时为false
 if g_bPlatformLogout == nil then
    g_bPlatformLogout = false
 else
    g_bPlatformLogout = true
 end
-- g_bPlatformLogout = (g_bPlatformLogout == nil) and false or true

local function CreateServerListInfo()
	if g_ServerList ~= nil then
		g_ServerList:Release()
		g_ServerList = nil
	end

	g_ServerList = ServerListInfo.new()
	g_ServerList:Init()

end

function ServerListInfo:ctor()
	self.ServerList = {}		--服务器列表

	self.LocalServer = {}			--本地存取的服务器信息
    self.deviceIDServer = "0"
	--设置IP port 在CheckCurIpProt 中
	-- --平台接入的 IP 端口
	-- --添加的时候 在GamePlatform_IP 里面添加类型 然后在给ServerPlatform赋值
	-- --在下面添加逻辑
	-- --保证IP 端口 一一对应
	-- if ServerPlatform == GamePlatform_IP.GamePlatform_DEBUG then --内网
	-- 	self.ServerIp  	= "192.168.1.166"
	-- 	self.iPort 		= 8101 

	-- elseif ServerPlatform == GamePlatform_IP.GamePlatform_IOSYY then --iOS 越狱
	-- 	self.ServerIp  	= "112.74.129.64" 
	-- 	self.iPort 		= 8101 

	-- elseif  ServerPlatform == GamePlatform_IP.GamePlatform_ANDROID then --android 删档 
	-- 	--uc是单独的 
	-- 	--360 跟百度是一组
	-- 	--通过平台区分
	-- 	if g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_360_NEW or
	-- 	   g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_BAIDU then
	-- 		self.ServerIp  	= "112.74.129.64" 
	-- 		self.iPort 		= 8102

	-- 	else --UC 老版本的360
	-- 		self.ServerIp  	= "120.24.152.214" 
	-- 		self.iPort 		= 8103
			
	-- 	end

	-- elseif  ServerPlatform == GamePlatform_IP.GamePlatform_ANDROID_DEBUG then --android 评测
	-- 	self.ServerIp  	= "192.168.200.128" 
	-- 	self.iPort 		= 8101
	-- end 

	--平台服务器的IP 端口
	-- self.ServerIp  	= "192.168.1.166"--"192.168.200.128" "192.168.1.166" 内网
	-- self.ServerIp  	= "192.168.200.128"--"192.168.200.128" "192.168.1.166" 
	-- self.ServerIp  	= "112.74.129.64" --外网充值 ios 越狱
	-- self.ServerIp  	= "120.24.152.214" --android 删档


	-- self.iPort 		= 8101 --通用服务器  ios 越狱
    -- self.iPort 		= 8103 --奎爷 android 删档
    -- self.iPort 		= 8102 --一良

    --设置平台 接入IP 端口
    self:CheckCurIpProt(g_GamePlatformSystem:GetServerPlatformType())

	--初始化用的默认端口号 
	self.delfaultUint = 5665666

	self.eCurState = Loading_State.Request_ServerList

	--临时数据
	self.bReconnectSignle = false

	self.name = CCUserDefault:sharedUserDefault():getStringForKey("DailyAccount", "")
    self.password = CCUserDefault:sharedUserDefault():getStringForKey("Passwd","")
    self.name = (self.name == "" and nil) or self.name
	self.password = (self.password == "" and nil) or self.password

	self.ClientSocket = nil

	self.HasNewServer = false --是否有新区（已经开服的 准备开服的）
end

--通过服务器的平台类型设置当前的ip 端口
--[[
//登陆账号平台
enum LoginPlatform
{
	LOGIN_PLATFORM_NONE		= 0;	//美天账号
	LOGIN_PLATFORM_QQ		= 1;	//QQ号
	LOGIN_PLATFORM_SINA		= 2;    //新浪微博账号
	LOGIN_PLATFORM_360		= 3;	//360账号
	LOGIN_PLATFORM_UC		= 4;	//UC账号
	LOGIN_PLATFORM_PP		= 5;	//PP账号
	LOGIN_PLATFORM_I4		= 6;	//I4平台
	LOGIN_PLATFORM_XY		= 7;	//XY
	LOGIN_PLATFORM_HAIMA		= 8;	//海马账号
	LOGIN_PLATFORM_KUAIYONG		= 9;	//快用账号
	LOGIN_PLATFORM_ITOOLS_GAME	= 10;	//itools game
	LOGIN_PLATFORM_91 = 11;			// 91
	LOGIN_PLATFORM_HURRICANE = 12;	// 飓风网络
	LOGIN_PLATFORM_GUOPAN = 13;		// 果盘
	LOGIN_PLATFORM_TONGBU = 14;		// 厦门同步网络
	LOGIN_PLATFORM_BAIDU = 15;		// 百度
	LOGIN_PLATFORM_360_NEW = 16;		// 360临时类型
	LOGIN_PLATFORM_XIAOMI = 17;		// 小米
	LOGIN_PLATFORM_HUAWEI = 18;		// 华为
	
	LOGIN_PLATFORM_MAX = 64;		// 无效的值
}
]]
function ServerListInfo:CheckCurIpProt(PlatformType)
    -- if g_bVersionAndroid_0_0_ == "oppo_1.0.1" then
    --     g_strStandAloneGame = "open"
    -- end

    if g_bVersionAndroid_0_0_ == "uc_1.0.1" 
    	or g_bVersionAndroid_0_0_ == "tishen_1.0.0"
    	or g_bVersionAndroid_0_0_ == "yijie_1.0.1" 
    	or g_bVersionAndroid_0_0_ == "360_1.0.1" 	
    	or g_bVersionAndroid_0_0_ == "jinli_1.0.1" 
    	or g_bVersionAndroid_0_0_ == "kupai_1.0.1"
    	or g_bVersionAndroid_0_0_ == "lenovo_1.0.1"
    	or g_bVersionAndroid_0_0_ == "baidu_1.0.1"
    	or g_bVersionAndroid_0_0_ == "migu_1.0.1"
    	or g_bVersionAndroid_0_0_ == "samsung_1.0.1"
        or g_bVersionAndroid_0_0_ == "leshi_1.0.1"
        or g_bVersionAndroid_0_0_ == "meizu_1.0.1"
        or g_bVersionAndroid_0_0_ == "iqiyi_1.0.1"
        or g_bVersionAndroid_0_0_ == "xiaoaoAT_1.0.1"    --小奥推广
        or g_bVersionAndroid_0_0_ == "huawei_1.0.2"    --huawei
        or g_bVersionAndroid_0_0_ == "vivo_1.0.2"    --vivo
    	or g_bVersionAndroid_0_0_ == "xiaomi_1.0.1" then
        g_strAndroidTS = "open"
    end
    
	if PlatformType == macro_pb.LOGIN_PLATFORM_NONE then --内网测试
			-- self.ServerIp  	= "117.103.198.148" --越南测试服
			-- self.iPort 		= 8101 --越南测试服
			self.ServerIp  	= "192.168.200.128"     --"118.123.19.76"  --yyb 服务器地址
			-- self.ServerIp  	= "game1.chanlong.vtcgame.vn"
            -- self.iPort 		= 8102
			-- self.iPort 		= 8101 --开发、发布、伍一良
			-- self.iPort 		= 8104 --User06、李奎
			self.iPort 		= 8101 --周立波

			-- self.iPort 		= 8108 --左峰

			-- self.ServerIp  	= "dsx-game1.xiaoao.com"
			-- self.ServerIp   = "dsx-test.xiaoao.com"
			-- self.iPort 		= 8101


	elseif PlatformType == macro_pb.LOGIN_PLATFORM_BAIDU then 

	    	self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101

	elseif PlatformType == macro_pb.LOGIN_PLATFORM_UC or --android uc 老360
		   PlatformType == macro_pb.LOGIN_PLATFORM_360 then 
            --正式
            self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101

	elseif  PlatformType == macro_pb.LOGIN_PLATFORM_PP or --iOS 越狱
			PlatformType == macro_pb.LOGIN_PLATFORM_I4 or
			PlatformType == macro_pb.LOGIN_PLATFORM_XY or
			PlatformType == macro_pb.LOGIN_PLATFORM_HAIMA or
			PlatformType == macro_pb.LOGIN_PLATFORM_KUAIYONG or
			PlatformType == macro_pb.LOGIN_PLATFORM_ITOOLS_GAME or
			PlatformType == macro_pb.LOGIN_PLATFORM_91 or
			PlatformType == macro_pb.LOGIN_PLATFORM_HURRICANE or
			PlatformType == macro_pb.LOGIN_PLATFORM_GUOPAN or
			PlatformType ==  macro_pb.LOGIN_PLATFORM_LE8 or--LE8 ios
			PlatformType == macro_pb.LOGIN_PLATFORM_TONGBU then

			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101
			

	elseif PlatformType == macro_pb.LOGIN_PLATFORM_XIAOMI then
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101

	elseif PlatformType == macro_pb.LOGIN_PLATFORM_HUAWEI then
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101

	elseif PlatformType == macro_pb.LOGIN_PLATFORM_OPPO then
            --正式
            self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101

            --c测试
--			self.ServerIp  	= "dsx-atest.xiaoaohudong.com"
--			self.iPort 		= 8101
			
	elseif PlatformType == macro_pb.LOGIN_PLATFORM_LINGJING then
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101

    elseif PlatformType == macro_pb.LOGIN_PLATFORM_QQ then
			self.ServerIp  	= "119.29.112.119"
			self.iPort 		= 8101
	elseif PlatformType == macro_pb.LOGIN_PLATFORM_LENOVO then
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101
			
	elseif PlatformType == macro_pb.LOGIN_PLATFORM_COOLPAD then
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101

	elseif PlatformType == macro_pb.LOGIN_PLATFORM_VIVO then
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101
	elseif PlatformType == macro_pb.LOGIN_PLATFORM_AMIGO then   --金立
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101   

	elseif PlatformType == macro_pb.LOGIN_PLATFORM_YI_JIE then
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101
    elseif PlatformType == macro_pb.LOGIN_PLATFORM_SAMSUNG then   --三星
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101
    elseif PlatformType == macro_pb.LOGIN_PLATFORM_MEIZU then     --魅族
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101
    elseif PlatformType == macro_pb.LOGIN_PLATFORM_LESHI then     --乐视
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101
    elseif PlatformType == macro_pb.LOGIN_PLATFORM_AIQIYI then    --爱奇艺
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101

    elseif PlatformType == macro_pb.LOGIN_PLATFORM_XIAOAO_PROMOTION then    --小奥推广
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101

            self.ServerIp  	= "192.168.1.166"
			self.iPort 		= 8104 --周立波

    elseif PlatformType == macro_pb.LOGIN_PLATFORM_MIGU_XIAOAO then
			self.ServerIp  	= "192.168.200.128"
			self.iPort 		= 8101

	elseif PlatformType == macro_pb.LOGIN_PLATFORM_VT or --越南ios
           PlatformType == macro_pb.LOGIN_PLATFORM_VT then --越南android
			self.ServerIp  	= "192.168.200.128" --正式服务
			--self.ServerIp  	= "117.103.198.148"		--测试服务器
			self.iPort 		= 8101

    elseif PlatformType == macro_pb.LOGIN_PLATFORM_49YOU then
			self.ServerIp  	= "112.74.68.83"
			self.iPort 		= 8101
	
    elseif PlatformType == macro_pb.LOGIN_PLATFORM_TIANCI then
		self.ServerIp  	= "120.25.59.86"
		self.iPort 		= 8101

    elseif PlatformType == macro_pb.LOGIN_PLATFORM_LIULIAN then
		self.ServerIp  	= "192.168.200.128"
		self.iPort 		= 8101

    elseif PlatformType == macro_pb.LOGIN_PLATFORM_37WAN then
		self.ServerIp  	= "192.168.200.128"
		self.iPort 		= 8101

    elseif PlatformType == macro_pb.LOGIN_PLATFORM_TIANGONG then
		self.ServerIp  	= "120.25.59.86"
		self.iPort 		= 8101
    elseif PlatformType == macro_pb.LOGIN_PLATFORM_TAIWAN_ANDROID or    --台湾谷歌
           PlatformType == macro_pb.LOGIN_PLATFORM_TAIWANTAIYOU_ANDROID  then --台湾第三方支付
        self.ServerIp  	= "dss-game2.gametaiwan.com"
		self.iPort 		= 8101
        if g_IsShenYuLing == nil or g_IsShenYuLing == false then
            self.ServerIp  	= "dss-game1.gametaiwan.com"
		    self.iPort 		= 8101
		    -- self.ServerIp  	= "203.69.240.2"
		    -- self.iPort 		= 8101 --测试服
        end
    elseif PlatformType == macro_pb.LOGIN_PLATFORM_TAIWAN_IOS then        --台湾IOS
        self.ServerIp  	= "dss-game2.gametaiwan.com"
        self.iPort 		= 8101
        if g_IsShenYuLing == nil or g_IsShenYuLing == false then
            self.ServerIp  	= "dss-game1.gametaiwan.com"
		    self.iPort 		= 8101
        end
        if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
            self.ServerIp  	= "dss-test.gametaiwan.com"
		    self.iPort 		= 8102
        end 
    elseif PlatformType == macro_pb.LOGIN_PLATFORM_XIAOAO or
           PlatformType == macro_pb.LOGIN_PLATFORM_ANDROID_XIAOAO or
           PlatformType == macro_pb.LOGIN_PLATFORM_MIGU_XIAOAO then
        self.ServerIp  	= "dsx-game1.xiaoao.com"
        self.iPort 		= 8101
        
        if g_bVersionTS_0_0_ ~= nil and g_bVersionTS_0_0_ == g_NeelDisableVersion then
            self.ServerIp  	= "dsx-test.xiaoao.com"
            self.iPort 		= 8102
        end

        if g_strAndroidTS == "open" then
            self.ServerIp  	= "192.168.200.128"
		    self.iPort 		= 8101
        end
	end
end

function ServerListInfo:Init()
	self.LocalServer = {}
	self.LocalServer.port 	= nil
	self.LocalServer.ip 	= nil
	self.LocalServer.name 	= nil
    self.LocalServer.id = nil
	--读取本地数据
	self.LocalServer.name  	= CCUserDefault:sharedUserDefault():getStringForKey("ServerName")
	self.LocalServer.ip  	= CCUserDefault:sharedUserDefault():getStringForKey("ServerIp")
	self.LocalServer.port  	= CCUserDefault:sharedUserDefault():getIntegerForKey("ServerPort", self.delfaultUint)
	self.LocalServer.id  	= CCUserDefault:sharedUserDefault():getIntegerForKey("Serverid")
	--cclog("=============ServerListInfo:SetLocalServerInfo======222======"..tostring(self.LocalServer.port))
    
	--注册网络消息
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SERVER_LIST_RESPONSE , handler(self, self.RespondSeverListInfo))

	--注册本地消息
	--建链成功
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ClientNet_ConnectStack, handler(self, self.ConnectNetSuccend))

	--点击注册账号
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ClientNet_RequestRegistAccout, handler(self, self.OnMsgRequestAccount))

	--响应服务器 注册账号消息
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ClientNet_AccountSuccond, handler(self, self.RespondRegistAccount))

	g_FormMsgSystem:RegisterFormMsg(FormMsg_ClientNet_AccountRegistSuccond, handler(self, self.Respondaccount))

	--响应服务器 注消账号消息
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ClientNet_LogOut, handler(self, self.OnMsgLogOut))

	--点击登入
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ClientNet_OnClickLogin, handler(self, self.OnMsgOnClickLogin))

	--服务器主动断开客户端
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ClientNet_CloseTcp, handler(self, self.ServerCloseTcpClient))
	
end

function ServerListInfo:Release()
	self.ServerList = {}		--服务器列表

	self.LocalServer = {}			--本地存取的服务器信息

	self.ServerIp  	= ""
	self.iPort 		= ""

	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ClientNet_ConnectStack)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ClientNet_RequestRegistAccout)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ClientNet_AccountSuccond)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ClientNet_LogOut)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ClientNet_OnClickLogin)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ClientNet_CloseTcp)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ClientNet_AccountRegistSuccond)
	
end

function ServerListInfo:RequestLoginPlatform()
    if g_bPlatformLogout == true then return end

	local account = CCUserDefault:sharedUserDefault():getStringForKey("DailyAccount", "")
    local passwd = CCUserDefault:sharedUserDefault():getStringForKey("Passwd","")
    if account ~= "" and passwd ~= "" then
    	g_MsgMgr:requestAccountLogin(account, passwd)
    else
    	g_MsgNetWorkWarning:closeNetWorkWarning()
    end
end

--建链成功 
function ServerListInfo:ConnectNetSuccend()

	if self.eCurState == Loading_State.Request_RegistAccout then 		--准备注册账号，建链到平台服成功
		g_MsgMgr:requestAccountReg(self.name, self.password)
	end

	if self.eCurState == Loading_State.Request_RegistAccoutSuccond then --注册账号成功 登入成功
		g_MsgMgr:requestRole()
	end

	if self.eCurState == Loading_State.Request_Login then				--点击登入后 建链处理
		g_MsgMgr:requestAccountLogin(self.name, self.password)
	end

--	if self.eCurState == Loading_State.Request_Logout then				--注销流程
--		g_goBackReLogin = true
--    	g_WndMgr:reset()

--       --重新加载资源
--    	LoadGamWndFile()

--    	g_LoadFile("LuaScripts/GameLogic/Class_Hero")
--    	g_MsgMgr:resetAccount()
--		local sceneGame = LYP_GetStartGameScene()
--		CCDirector:sharedDirector():replaceScene(sceneGame)
--	end

	if (self.eCurState == Loading_State.Request_ReConnect) and 
		(g_MsgMgr:GetCurConnectType() == Class_MsgMgr_Zone) then
		cclog("重连第一条消息")
		g_ClientPing:StartPing()
		g_ClientPing:ReListen()
		g_ClientPing:SendPing()
		RunPaySucc()
		--处理异常消息
		-- g_ErrorMsg:SendErrorMsg()
		
	end


	self.eCurState = nil

	--建链成功 改变重连状态
	self.bReconnectSignle = false

	self.ClientSocket = 1

	g_GamePlatformSystem:PlatformAffterConnect()
end

--注册角色前 接入平台服
function ServerListInfo:OnMsgRequestAccount(tbMsg)
	self.name = tbMsg.name
	self.password = tbMsg.password
	self.eCurState = Loading_State.Request_RegistAccout

	--重新建链 平台服
	if g_MsgMgr:GetCurConnectType() == Class_MsgMgr_Platform then
		g_MsgMgr:requestAccountReg(self.name, self.password)
	else
		self:ConnectPlatform()
	end
end

--注册账号成功处理
function ServerListInfo:RespondRegistAccount()
    g_bPlatformLogout = false
	self:RequestServerListInfo()
end

function ServerListInfo:Respondaccount()
	--重置端口标签 在服务器列表中重新获取最新的服务器 注册帐号成功
	self.LocalServer.port  	= self.delfaultUint
end

local function checkUpdateVersion(pSender, nType, nData, nMax)
    if(nType == CResUpdateMgr.kVersion)then
		local function verCompare(ver1,ver2)
			ver1 = ver1.."."
			ver2 = ver2.."."
			local func1 = string.gfind(ver1,"%d.")
			local func2 = string.gfind(ver2,"%d.")
			for i = 1,3 do
				local a,b = tonumber(func1()),tonumber(func2())
				if a ~= b then
					return a > b
				end
			end
			return false;
		end

		local nAPKVer = API_GetVersion()
		local curVer = CCUserDefault:sharedUserDefault():getStringForKey("Version","0.0.0")

        if( nAPKVer ~= curVer )then
			if verCompare(nAPKVer,curVer) then 
				if CCFileUtils:sharedFileUtils():isFileExist(g_writepath) then
					os.rmdir(g_writepath)
				end
				curVer = nAPKVer;
			end
            CCFileUtils:sharedFileUtils():addSearchPath(g_writepath)
        end

        local bRet = string.find(nData, "Not Found")
		if bRet or string.len(nData) == 0 then    --未能取得版本文件
            g_ServerList:ConnectZone()
	        g_ServerList.eCurState = Loading_State.Request_RegistAccoutSuccond
			return
		end


		g_MsgNetWorkWarning:closeNetWorkWarning()		
	    local starIndex,endIndex = string.find(nData, "(v.+,)",-10)
        local newestVer = string.sub(nData,starIndex+1,endIndex-1)
	    if newestVer == curVer then 
            g_ServerList:ConnectZone()
	        g_ServerList.eCurState = Loading_State.Request_RegistAccoutSuccond
        else
            g_ClientMsgTips:showMsgConfirm(_T("客户端资源有最新版本，请重启游戏进行更新。"))
        end
    else
            g_ServerList:ConnectZone()
	        g_ServerList.eCurState = Loading_State.Request_RegistAccoutSuccond
    end
end

function ServerListInfo:OnEventGetServerList()
    if g_Cfg.Update == true and rootURL ~= nil and version ~= nil then
    	g_MsgNetWorkWarning:showWarningText()
        local updateResMgr = CResUpdateMgr:create()
        updateResMgr:setResponseScriptCallback(checkUpdateVersion)
        updateResMgr:init(rootURL..version)
    else
	    self:ConnectZone()
	    self.eCurState = Loading_State.Request_RegistAccoutSuccond
    end
end

--注销账号
function ServerListInfo:OnMsgLogOut()
    --重新建链 平台服
    --API_CloseSocket()
	--self:ConnectPlatform()
	--self.eCurState = Loading_State.Request_Logout
	
    g_bPlatformLogout = true
	g_goBackReLogin = true

	---全局对象 清空已注册过的消息
	g_FormMsgSystem = FormMsgSystem.new()
	g_WndMgr:reset()
	
	
   --重新加载资源
	LoadGamWndFile()

	-- g_LoadFile("LuaScripts/GameLogic/Class_Hero")
	g_MsgMgr:resetAccount()
	local sceneGame = LYP_GetStartGameScene()
	CCDirector:sharedDirector():replaceScene(sceneGame)

	g_Hero = Class_Hero.new()
	g_Hero:Init()

	g_EctypeListSystem = Game_EctypeListSystem.new()
   	g_EctypeListSystem:Init()

	g_ErrorMsg:ClearErrorMsg()

end

--点击登入
function ServerListInfo:OnMsgOnClickLogin(tbMsg)
	self.name = tbMsg.name
	self.password = tbMsg.password
    g_bPlatformLogout = false

	self.eCurState = Loading_State.Request_Login

	--重新建链 平台服
	if g_MsgMgr:GetCurConnectType() == Class_MsgMgr_Platform then

		g_MsgMgr:requestAccountLogin(self.name, self.password)
	else
		self:ConnectPlatform()
		cclog("g_MsgMgr:GetCurConnectType() =======")
	end
end

--断线重连流程(很长一段时间没发ping 服务器主动中断客户端链接)
function ServerListInfo:ServerCloseTcpClient()
	if self.bReconnectSignle == true then return true end

	self.bReconnectSignle = true
	cclog("------>>>>>>ServerListInfo:ServerCloseTcpClient")
	local function onClickConfirm()
		-- g_FormMsgSystem:SendFormMsg(FormMsg_ClientNet_LogOut, nil)
		g_MsgNetWorkWarning:setActivation(true)
		g_GamePlatformSystem:OnClickGameLoginOut()
		--g_bPlatformLogout = nil
		g_Timer:destroy()
		--游戏里面的各个状态下的全局变量不同。不能这样清除。因该按照游戏状态清。清除非当前状态下的所有数据
		-- g_tbPackage = {}
		-- g_tbGobalValue = {}
		local sceneGame = LYP_GetLoadingScene()
		CCDirector:sharedDirector():replaceScene(sceneGame)
	 end--直接返回登陆界面

	local function onClickCancel()
		g_MsgNetWorkWarning:setActivation(true)
		g_GamePlatformSystem:OnClickGameLoginOut()
	end

	g_MsgNetWorkWarning:setActivation(false)
	g_ClientMsgTips:showConfirm(_T("您已长时间离线，请重新登入"), onClickConfirm, onClickCancel)
	-- g_ShowSysWarningTips({text ="网络连接中断！重连中..."})
	
	self.ClientSocket = nil

	g_ClientPing:StopPing()

	return true
end

--如果客户端的ping检测到掉线了 会自动重新连接一次
function ClientCloseTcpServer()
	API_ReConnect()
end

--保存本地 登陆信息 （从服务器列表中保存）
function ServerListInfo:SetLocalServerInfo(nIndex)
	if self.ServerList[nIndex] == nil or self:GetServeState(nIndex) == macro_pb.SERVER_STATE_STOP  then
		-- g_ShowSysWarningTips({text ="当前服务器不可用,请重新选择"})
		g_ClientMsgTips:showMsgConfirm(_T("当前服务器不可用,请重新选择"), nil)
		-- cclog("ServerListInfo:SetLocalServerInfo -----"..nIndex)
		cclog("=======ServerListInfo:SetLocalServerInfo========")
		return false
	end

	self.LocalServer.port 	= self.ServerList[nIndex].port
	self.LocalServer.ip 	= self.ServerList[nIndex].ip
	self.LocalServer.name 	= self.ServerList[nIndex].name
	self.LocalServer.id 	= self.ServerList[nIndex].id
	--
	CCUserDefault:sharedUserDefault():setIntegerForKey("ServerPort", self.LocalServer.port )
	CCUserDefault:sharedUserDefault():setStringForKey("ServerIp", self.LocalServer.ip)
	CCUserDefault:sharedUserDefault():setStringForKey("ServerName", self.LocalServer.name)
	CCUserDefault:sharedUserDefault():setStringForKey("Serverid", self.LocalServer.id )

	--cclog("=============ServerListInfo:SetLocalServerInfo======111======"..tostring(self.LocalServer.port))
	return true
end

-----------------------------------------------------------------外部接口类---------------------------
--链接平台服务器
function ServerListInfo:ConnectPlatform()
	g_MsgMgr:SetCurConnectType(Class_MsgMgr_Platform)

	--进入平台先清除发送消息队列
	API_DestorySendMsg();
	API_InitSocket(self.iPort, self.ServerIp)
	cclog(tostring(self.ServerIp).."****平台建链成功****"..tostring(self.iPort))
	g_MsgNetWorkWarning:showWarningText()
end

--请求链接账号服务器
function ServerListInfo:ConnectZone()
	

	-- local function onClickConfirm()
	-- 	g_ServerList:RequestServerListInfo()
	-- 	g_FormMsgSystem:RegisterFormMsg(FormMsg_ClientNet_OpenServerForm, function() showSelectServerWnd() end )
	-- end

	-- local function onClickCancel()
	-- 	g_IsExistedActor = nil
	-- 	g_MsgMgr:SetCurConnectType(Class_MsgMgr_Zone)
	-- 	g_MsgMgr:ResetZoneID()
	-- 	API_ConnectToServer(self.LocalServer.port, self.LocalServer.ip)--self.LocalServer.port
	-- 	cclog(self.LocalServer.port.."***游戏服建链成功****"..self.LocalServer.ip)
	-- 	g_MsgNetWorkWarning:showWarningText()
	-- end
	
	-- --如果有开了新的区 提示玩家有新的服务器开启
	-- if self.HasNewServer then
	-- 	if not self:GetLocalServerStatus_isNewServer() then
	-- 		g_ClientMsgTips:showConfirm("检测到有新的游戏区开启哦, 是否跟进", onClickConfirm, onClickCancel)
	-- 	else
	-- 		onClickCancel()
	-- 	end
	-- else
	-- 	onClickCancel()
	-- end

	g_IsExistedActor = nil
	g_MsgMgr:SetCurConnectType(Class_MsgMgr_Zone)
	g_MsgMgr:ResetZoneID()
	API_ConnectToServer(self.LocalServer.port, self.LocalServer.ip)--self.LocalServer.port
	cclog(tostring(self.LocalServer.port).."***游戏服建链成功****"..tostring(self.LocalServer.ip))
	g_MsgNetWorkWarning:showWarningText()
end

function ServerListInfo:CheckNewServer(bCreate)
	cclog("========CheckNewServer======"..tostring(bCreate))
	-- --如果有开了新的区 提示玩家有新的服务器开启
	-- if self.HasNewServer then
	-- 	if not self:GetLocalServerStatus_isNewServer() and bCreate then --非新区创建角色 一开始是拒绝的
	-- 		g_ClientMsgTips:showMsgConfirm("该区已经爆满，竞争异常激烈，请仙友移驾新服~")
	-- 		self:ConnectPlatform()
	-- 	else
	-- 		--直接走以前的登入流程
	-- 		GameServerConnectSuccess()
	-- 	end
	-- else
	-- 	--直接走以前的登入流程
	-- 	GameServerConnectSuccess()
	-- end

	--客户端走正常流程 不限制玩家
	GameServerConnectSuccess()
	
	return true
end

function ServerListInfo:GetLoaclAccount()
	return ((self.name == nil) and "" ) or self.name 
end

function ServerListInfo:GetLoaclPassWord()
	return ((self.password == nil) and "") or self.password 
end

function ServerListInfo:SetClientConnectState()
	self.eCurState = Loading_State.Request_ReConnect
end

--选择服务器 这里要建链的。
function ServerListInfo:SelectServerAndConnect(nIndex)
	return self:SetLocalServerInfo(nIndex)
end

--获取服务器列表的数量
function ServerListInfo:GetServerListCount()
	return #self.ServerList
end

--获取单个服务器的数据 名称
function ServerListInfo:GetServerName(nIndex)
	if self.ServerList[nIndex] == nil then
		return "no name"
	end

	return (self.ServerList[nIndex].name == nil and "no name") or self.ServerList[nIndex].name
end

--获取单个服务器的数据 ip
function ServerListInfo:GetServeIp(nIndex)
	if self.ServerList[nIndex] == nil then
		return "no ip"
	end

	return (self.ServerList[nIndex].ip == nil and "no ip") or self.ServerList[nIndex].ip
end


--获取单个服务器的数据 端口
function ServerListInfo:GetServePort(nIndex)
	if self.ServerList[nIndex] == nil then
		return 0
	end

	return (self.ServerList[nIndex].port == nil and 0) or self.ServerList[nIndex].port
end

--获取单个服务器的数据 获取服务器状态
function ServerListInfo:GetServeState(nIndex)
	if self.ServerList[nIndex] == nil or self.ServerList[nIndex].state == nil then
		return macro_pb.SERVER_STATE_STOP -- 维护中 点击后无效
	end

	-- return (self.ServerList[nIndex].state == nil and macro_pb.SERVER_STATE_STOP) or self.ServerList[nIndex].state
	--新服 跟准备中的服务器 显示 1，否则显示 3.
	local state = self.ServerList[nIndex].state
--[[	if self.ServerList[nIndex].n_o_state == account_pb.SNOS_OLD then
		if state < macro_pb.SERVER_STATE_STOP then
			state = macro_pb.SERVER_STATE_CROWED
		end
	end]]
	return state
end

function ServerListInfo:GetLocalName()
	return self.LocalServer.name
end

function ServerListInfo:GetLocalServerID()
	return self.LocalServer.id
end

function ServerListInfo:GetLocalState()
	local state = macro_pb.SERVER_STATE_CROWED
	local newState = account_pb.SNOS_OLD
	for k, v in ipairs(self.ServerList)do
		if v.ip == self:GetLoaclIp() and v.port == self:GetLocalPort() then
			state = v.state
			newState = v.n_o_state
			break
		end
	end

	-- return macro_pb.SERVER_STATE_STOP 
--[[	if newState == account_pb.SNOS_OLD then
		if state < macro_pb.SERVER_STATE_STOP then
			state = macro_pb.SERVER_STATE_CROWED
		end
	end]]
	return state
end

function ServerListInfo:GetLoaclIp()
	return self.LocalServer.ip
end

function ServerListInfo:GetLocalPort()
	return self.LocalServer.port
end

function ServerListInfo:GetLocalServerStatus_isNewServer()
	local state = account_pb.SNOS_OLD
	for k, v in ipairs(self.ServerList)do
		if v.ip == self:GetLoaclIp() and v.port == self:GetLocalPort() then
			state = v.n_o_state
			break
		end
	end

	cclog("========== GetLocalServerStatus_isNewServer "..tostring(state))
	if state == account_pb.SNOS_NEW or
	   state == account_pb.SNOS_READY then
			return true
	end

	return false
end

--如果本地的纪录的IP 端口 在本次发的服务器列表里面有效那就用本地 否则用服务器第一个
function ServerListInfo:CheckLoaclIPAndPort_OK()
	local bret = false
	for k, v in ipairs(self.ServerList)do
			if v.ip == self:GetLoaclIp() and v.port == self:GetLocalPort() then
				bret = true
				break
			end
		end
	return bret
end

--优先选取最近登入的服务器 第一次登入的时候 就获取 第一个可以登入的服务器 没有的话 就提示 没有可登入的服务器
function ServerListInfo:GetCurUseServer()

	local istate = self.delfaultUint

	--如果第一次登入
	if self:GetLocalPort() == self.delfaultUint  then 
		-- cclog("========ServerListInfo:GetCurUseServer===========111111")
		self:GetServer(ServerState_Client.SERVER_STATE_IDLE)
	else --如果不是第一次登入 先检查上次登入的服务器是否在维护中 如果是就筛选一个最优的
		for k, v in ipairs(self.ServerList)do
			if v.ip == self:GetLoaclIp() and v.port == self:GetLocalPort() then
				istate = v.state
				break
			end
		end
		-- cclog("========ServerListInfo:GetCurUseServer===========222222222")
	end

	--最后一次判定
	if istate == ServerState_Client.SERVER_STATE_STOP then
		self:GetServer(ServerState_Client.SERVER_STATE_IDLE)
		-- cclog("========ServerListInfo:GetCurUseServer===========3333333")
	end

	return self:GetLoaclIp(), self:GetLocalPort(), self:GetLocalName()
end

function ServerListInfo:GetServer(icurState)
	if icurState > ServerState_Client.SERVER_STATE_STOP then
		return nil , nil , nil
	end

	for k, v in ipairs(self.ServerList)do
			if v.state == icurState and v.n_o_state == account_pb.SNOS_NEW then
				self:SetLocalServerInfo(k)
				return v.ip, v.port, v.name
			end
	end
	self:GetServer(icurState + 1)
	return nil , nil , nil
end

function ServerListInfo:IsGameSocketClose()
	cclog("ServerListInfo:IsGameSocketClose .."..tostring(self.ClientSocket))
	return nil == self.ClientSocket
end


function ServerListInfo:HasNewServer()
	return self.HasNewServer
end


function ServerListInfo:GetStatus_isNewServer(nIndex)
	if not self.ServerList or not self.ServerList[nIndex] then return false end


	if self.ServerList[nIndex].n_o_state == account_pb.SNOS_NEW or
	   self.ServerList[nIndex].n_o_state == account_pb.SNOS_READY then
			return true
	end

	return false
end
----------------------------------协议--------------------------------
--
--
--
--[[
// 服务器状态
enum ServerState
{
	SERVER_STATE_IDLE = 1;	// 空闲状态
	SERVER_STATE_BUSY = 2;	// 繁忙
	SERVER_STATE_CROWED= 3;	// 拥挤
	SERVER_STATE_STOP = 4;	// 维护中
}

message ServerListRequest		// 请求服务器列表，空消息
{
}

message SeverInfo
{
	optional uint32 port =1;	// 服务器端口
	optional string ip = 2;		// 服务器IP
	optional string name = 3;	// 服务器区名
	optional uint32 state = 4;	// 服务器状态，空闲，繁忙，拥挤...参见macro.pro的ServerState
	optional uint32 role_num = 5;// 服务器上的在线人数，不会发给客户端
}

message ServerListResponse		// 服务器列表响应
{
	repeated SeverInfo server_list = 1;	// 所有服务器列表
}
]]
 
--------------------------------------------------------------------请求服务器列表
function ServerListInfo:RequestServerListInfo()

	local tbMsg = account_pb.ServerListRequest();
	tbMsg.game_type = GameType or macro_pb.GameNameType_DSX

	g_MsgMgr:sendMsg(msgid_pb.MSGID_SERVER_LIST_REQUEST, tbMsg)
end

--------------------------------------------------------------------服务器列表响应
--获取服务器列表成功
function ServerListInfo:RespondSeverListInfo(tbMsg)
	local msgDetail = account_pb.ServerListResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
    self.deviceIDServer = msgDetail.device_id
	self.ServerList = {}
	local ip = nil
    local PlatformType = g_GamePlatformSystem:GetServerPlatformType()
	for k, v in ipairs(msgDetail.server_list) do
		local vtem = {}
		vtem.ip 	= v.ip
		vtem.port 	= v.port
		vtem.state 	= v.state
		vtem.name 	= v.name
		vtem.id 	= v.worldid
		vtem.n_o_state = v.n_o_state
        table.insert(self.ServerList, vtem)
--        if vtem.id == 50 then
--            if PlatformType == macro_pb.LOGIN_PLATFORM_VIVO or PlatformType == macro_pb.LOGIN_PLATFORM_HUAWEI then
--                table.insert(self.ServerList, vtem)
--            end
--        else
--            if PlatformType ~= macro_pb.LOGIN_PLATFORM_VIVO and PlatformType ~= macro_pb.LOGIN_PLATFORM_HUAWEI then
--                table.insert(self.ServerList, vtem)
--            end
--        end

		if v.n_o_state == account_pb.SNOS_NEW or v.n_o_state == account_pb.SNOS_READY then
			self.HasNewServer = true
		end
	end

--    --如果当前没有置顶服，则选择最新的服为置顶服
--    local newServer = false
--    for i, v in ipairs(self.ServerList) do
--        if v.n_o_state == account_pb.SNOS_NEW then
--            newServer = true
--        end
--    end
--    if not newServer and #self.ServerList >= 1 then
--        self.ServerList[#self.ServerList].n_o_state = account_pb.SNOS_NEW
--    end
	
	--设置本地服务器
	self:GetCurUseServer()
	if self.LocalServer.port == self.delfaultUint or not self:CheckLoaclIPAndPort_OK()then --本地是第一次创建 并且 服务器列表也是异常的（状态都在维护）
		-- self:SetLocalServerInfo(1) --按默认的第一个
		-- local curScene = CCDirector:sharedDirector():getRunningScene()
		-- g_ShowServerSysTips({text = "当前服务器正在维护中，请联系客服或选择新区", layout=curScene, y = 232, x = 620})
		g_ClientMsgTips:showMsgConfirm(_T("当前服务器正在维护中，请联系客服或选择新区"), nil)
	end

	-- --通知界面关闭 loading界面
	g_FormMsgSystem:PostFormMsg(FormMsg_ClientNet_ConnectSucc, nil)
	g_FormMsgSystem:PostFormMsg(FormMsg_ClientNet_OpenServerForm, nil)
	
end




---------------------定义外部全局对象-----------------------------------
g_ServerList = nil
CreateServerListInfo()