-- 文件名:	GamePlatform_ViVo.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_YIJIE = class("GamePlatform_YIJIE", function () return PlatformBase:new() end)
GamePlatform_YIJIE.__index = GamePlatform_YIJIE

function GamePlatform_YIJIE:ctor()
	self.billon = 0
	self.recharge = 0
    self.sdkID = "yijie"
	self.ServerPlatformType = macro_pb.LOGIN_PLATFORM_YI_JIE
end

function GamePlatform_YIJIE:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_YIJIE_LOGIN_RESPONSE , handler(self, self.OnRespondYIJIEPlatformLogin))


    --平台id，登录游戏服务器成功后，带回来
    -- self.__ViVoID = 0
end

--服务器平台类型
function GamePlatform_YIJIE:GetServerPlatformType()
	-- return self.ServerPlatformType
	return macro_pb.LOGIN_PLATFORM_YI_JIE
end

--获取子渠道类型
function GamePlatform_YIJIE:GetChildPlatformType()
    return self.sdkID
end

function GamePlatform_YIJIE:SetServerPlatformType(sdkID)
    self.sdkID = sdkID
	local function  EASY_CODE(sdkID, dirStr, dirtype)
		if tostring(sdkID) == tostring(dirStr) then
			cclog("===========GamePlatform_YIJIE:SetServerPlatformType==========="..tostring(sdkID).." "..tostring(dirStr))
			self.ServerPlatformType = dirtype
		end
	end

   EASY_CODE(sdkID, "{8DD43FEC-E77A64DE}", macro_pb.LOGIN_PLATFORM_MEIZU)
   EASY_CODE(sdkID, "{42AC3F04-D0229A31}", macro_pb.LOGIN_PLATFORM_HAI_MA_WAN)
   EASY_CODE(sdkID, "{23D9C479-1D64FA2A}", macro_pb.LOGIN_PLATFORM_SHUN_WANG)
   EASY_CODE(sdkID, "{B4447B49-BC295EFE}", macro_pb.LOGIN_PLATFORM_WAN_DOU_JIA)
   EASY_CODE(sdkID, "{A2D2F4AE-D400E281}", macro_pb.LOGIN_PLATFORM_AN_ZHI)
   EASY_CODE(sdkID, "{14A1382E-C59A6F70}", macro_pb.LOGIN_PLATFORM_GUO_PAN)
   EASY_CODE(sdkID, "{9F6FFDC3-0F5F0E97}", macro_pb.LOGIN_PLATFORM_YOU_LONG)
   EASY_CODE(sdkID, "{90636300-3FC9CACC}", macro_pb.LOGIN_PLATFORM_CHONG_CHONG)
   EASY_CODE(sdkID, "{FB589C6D-EBE9A197}", macro_pb.LOGIN_PLATFORM_DANG_LE)
   EASY_CODE(sdkID, "{8300D7FD-B402F76E}", macro_pb.LOGIN_PLATFORM_LIE_BAO)
   EASY_CODE(sdkID, "{6D00ED5B-6E998C7D}", macro_pb.LOGIN_PLATFORM_PPTV)
   EASY_CODE(sdkID, "{11AEE396-DB063871}", macro_pb.LOGIN_PLATFORM_KAO_PU)
   EASY_CODE(sdkID, "{84C1B0C4-356B6863}", macro_pb.LOGIN_PLATFORM_MU_ZHI_WAN)
   EASY_CODE(sdkID, "{3CBECEB4-C84C816E}", macro_pb.LOGIN_PLATFORM_SOU_GOU)
   EASY_CODE(sdkID, "{4F881D64-67D18EC7}", macro_pb.LOGIN_PLATFORM_YOU_KU)
   EASY_CODE(sdkID, "{65C90E90-AECD89B2}", macro_pb.LOGIN_PLATFORM_YOU_MI)
   EASY_CODE(sdkID, "{152E84D3-CAB12856}", macro_pb.LOGIN_PLATFORM_JI_FENG)
   EASY_CODE(sdkID, "{3481F08B-F45DB0D6}", macro_pb.LOGIN_PLATFORM_SHOU_MENG)
end

function GamePlatform_YIJIE:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_YIJIE:LoginPlatformSuccessCallBack(Account,  uid)
	self:RequestLoginYIJIESDK(Account, uid)
end

function GamePlatform_YIJIE:GameLogin()
	if g_OnExitGame then
        CGamePlatform:SharedInstance():ShowSDKCenter(-1)-- -1表示无意义参数
    else
        CGamePlatform:SharedInstance():ShowSDKCenter()
    end
	return true
end

function GamePlatform_YIJIE:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_YIJIE:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_YIJIE:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_YIJIE:CenterDidShowCallBack()

end

function GamePlatform_YIJIE:CenterDidCloseCallBack()

end

function GamePlatform_YIJIE:submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
	CGamePlatform:SharedInstance():submitExtendData(roleId, roleName, roleLevel, zoneName, zoneId)
end

function GamePlatform_YIJIE:setRecharge(irecharge)
	self.recharge = irecharge
end

------------------------------------协议--------------------------------
function GamePlatform_YIJIE:RequestLoginYIJIESDK(uid, token)
	if not uid or not token then return end

	local Msg = account_pb.PLYiJieLoginRequest()
	Msg.uin = token

	local ichanneld = 0
	local isid = 0
	local iint = 3 --java 构造是%3d
	local index = iint


	local context = string.sub(uid, 1, iint)
	if not context then return end

	ichanneld = tonumber(context)
	cclog("========GamePlatform_YIJIE:RequestLoginYIJIESDK======1 size = "..ichanneld.." index="..index)
	Msg.sdk = string.sub(uid, index + 1, ichanneld+iint) or ""

	index = ichanneld+iint

	context = string.sub(uid, index + 1, index + iint)
	if not context then return end
	isid = tonumber(context)

	index = index + iint

	cclog("========GamePlatform_YIJIE:RequestLoginYIJIESDK======2 size = "..isid.." index="..index)
	Msg.sess = string.sub(uid, index + 1, isid + index) or ""

	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_YIJIE_LOGIN_REQUEST, Msg)
	g_MsgNetWorkWarning:showWarningText()

	self:SetServerPlatformType(Msg.sdk)

end

function GamePlatform_YIJIE:OnRespondYIJIEPlatformLogin(tbMsg)
	cclog("--------------GamePlatform_YIJIE:OnRespondYIJIEPlatformLogin----------------------")
	local msgDetail = account_pb.PLYiJieLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.is_success  then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
        -- self.__360ID = msgDetail.sdk_id
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_ViVo:VivoPlatformLoginResponse()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end