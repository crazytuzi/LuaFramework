-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  本例子是用类对象的方式实现

GamePlatform_QQ = class("GamePlatform_QQ", function () return PlatformBase:new() end)

GamePlatform_QQ.__index = GamePlatform_QQ

function GamePlatform_QQ:ctor()
    --self.reqPaySuccCnt = 0 --充值成功，请求服务器查询，5次计数
    --self.payData = "" --缓存充值数据

    self.c_openid = ""
    self.c_openkeyser = ""
    self.c_paytoken = ""
    self.c_pf = ""
    self.c_pfkey = ""
    self.c_ts = ""
    self.c_paytype = ""
end


function GamePlatform_QQ:PlatformInit()
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_QQ_LOGIN_RESPONSE , handler(self, self.OnRespondLoginQQSDK))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_WECHAT_LOGIN_RESPONSE , handler(self, self.OnRespondLoginWeChatSDK))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_QQPAY_NOTIFY_RET_GOLD , handler(self, self.OnQQPaySuccessResponse))
end

--服务器平台类型
function GamePlatform_QQ:GetServerPlatformType()
	return macro_pb.LOGIN_PLATFORM_QQ
end

function GamePlatform_QQ:GetPlatformType()
	return CGamePlatform:SharedInstance():GetCurPlatform()
end
    
function GamePlatform_QQ:LoginPlatformSuccessCallBack(Account,  password)
	self:RequestLoginQQSDK(Account, password)
end
----------------------------------------------------------------------------
function GamePlatform_QQ:GameLogin(logintype)
    if g_OnExitGame then
        CGamePlatform:SharedInstance():ShowSDKCenter(logintype)-- -1表示无意义参数 -0 为qq -1为微信
    else
        CGamePlatform:SharedInstance():ShowSDKCenter()
    end
	return true
end

function GamePlatform_QQ:GamePlatformStart()
	PlatformBase:GamePlatformStart()
	CGamePlatform:SharedInstance():GamePlatformStartSDK("", "")
end

function GamePlatform_QQ:GameLoginOut()
	CGamePlatform:SharedInstance():LogOut()
end

function GamePlatform_QQ:LoginOutCallBack()
	PlatformBase:GameLoginOut()
end
    
function GamePlatform_QQ:CenterDidShowCallBack()

end

function GamePlatform_QQ:CenterDidCloseCallBack()

end

------------------------------------协议--------------------------------
function GamePlatform_QQ:RequestLoginQQSDK(token, password)
    if token == nil or password == nil then return end

	cclog("--------------GamePlatform_QQ:QQPlatformLoginRequest---------- "..token)

    local tbstring =  string.split(password, ",")
    local tbToken = string.split(token, ",")

    self.c_openid = tbToken[2]
    self.c_openkeyser = tbToken[3]
    self.c_paytoken = tbToken[4]
    self.c_pf = tbToken[5]
    self.c_pfkey = tbToken[6]
    self.c_ts = tbToken[7]
    self.c_paytype = tbToken[8]

    if tbstring[1] == "0" then
        local Msg = account_pb.QQPlatformLoginRequest()
	    Msg.openid = tbstring[2]
        Msg.openkey = tbToken[1]
        
	    g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_QQ_LOGIN_REQUEST, Msg)
	    g_MsgNetWorkWarning:showWarningText()
    else 
        local Msg = account_pb.WechatPlatformLoginRequest()
	    Msg.openid = tbstring[2]
        Msg.refreshToken = tbToken[1]

	    g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_WECHAT_LOGIN_REQUEST, Msg)
	    g_MsgNetWorkWarning:showWarningText()
    end
end

function GamePlatform_QQ:OnRespondLoginQQSDK(tbMsg)
	cclog("--------------GamePlatform_QQ:OnRespondLoginQQSDK()----------------------")
	local msgDetail = account_pb.QQPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.is_success == true then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_QQ:OnRespondLoginQQSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

function GamePlatform_QQ:OnRespondLoginWeChatSDK(tbMsg)
	cclog("--------------GamePlatform_QQ:OnRespondLoginWeChatSDK()----------------------")
	local msgDetail = account_pb.WechatPlatformLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.is_success == true then
		g_GamePlatformSystem:SetAccount_PlatformID(msgDetail.uin)
		g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
		--请求服务器列表
		g_ServerList:RequestServerListInfo()
		cclog("-------GamePlatform_QQ:OnRespondLoginWeChatSDK()-------------")
	else
        
	end

	AccountRegResponse(false)
	g_MsgNetWorkWarning:closeNetWorkWarning()

end

function GamePlatform_QQ:PlatformPayByClient(recharge_id)
    local tbRechage = g_DataMgr:getShopRechargeCsv(recharge_id)

    if tbRechage ~= nil then

        if g_OnExitGame then
            CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice*10, tbRechage.Name, "", g_ServerList:GetLocalServerID()..","..g_Hero:getMasterName())
        else
            CGamePlatform:SharedInstance():ExchangeGoos(tbRechage.RMBPrice*10, tbRechage.Name, "")
        end
	end

end

function GamePlatform_QQ:OnPlatformPaySuccess(strPayData)
    --self.payData = strPayData
    --self.reqPaySuccCnt = 0
    --g_MsgNetWorkWarning:showWarningText()
    self:SendPlatformPaySuccess(strPayData)
end

function GamePlatform_QQ:SendPlatformPaySuccess(strPayData)
   -- QQ支付基本参数
    --[[message QQGetBaseParam
{
	optional string openid = 1;
    optional string openkey = 2;		//从手Q登录态或者微信登录态中获取的access_token 的值
    optional string pay_token = 3;		//手Q登录时从手Q登录态中获取的pay_token的值,使用MSDK登录后获取到的eToken_QQ_Pay返回内容就是pay_token； 微信登录时特别注意该参数传空。
    optional string pf = 4;
    optional string pfkey = 5;
    optional string ts = 6;
    optional string zoneid = 7;
    optional uint32 pay_type = 8;		// 0：表示QQ登录支付， 1表示微信登录支付
}]]

    cclog("--------------GamePlatform_QQ:SendPlatformPaySuccess()----------------------")
    local tbstring =  string.split(strPayData, ",")
    local Msg = zone_pb.QQPaySuccessRequest()
    Msg.base_param.openid = tbstring[1]
    Msg.base_param.openkey = tbstring[2]
    Msg.base_param.pay_token = tbstring[3]
    Msg.base_param.pf = tbstring[4]
    Msg.base_param.pfkey = tbstring[5]
    Msg.base_param.ts = tbstring[6]
    Msg.base_param.zoneid = tostring(g_ServerList:GetLocalServerID())
    Msg.base_param.pay_type = tonumber( tbstring[7] )

  	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_QQPAY_SUCCESS_REQUEST, Msg)
	g_ShowSysTips({text = "充值成功，元宝到账可能有延迟，请耐心等待！"})
end

function GamePlatform_QQ:SendrefreshTokens()
    cclog("--------------GamePlatform_QQ:SendrefreshTokens()----------------------")

    local Msg = zone_pb.QQPayChangePayParamRequest()
    Msg.base_param.openid = self.c_openid
    Msg.base_param.openkey = self.c_openkeyser
    Msg.base_param.pay_token = self.c_paytoken
    Msg.base_param.pf = self.c_pf
    Msg.base_param.pfkey = self.c_pfkey
    Msg.base_param.ts = self.c_ts
    Msg.base_param.zoneid = tostring(g_ServerList:GetLocalServerID())
    Msg.base_param.pay_type = tonumber( self.c_paytype )

  	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_QQPAY_CHANGE_PAY_PARAM, Msg)
end

function GamePlatform_QQ:refreshTokens(Tokens)
    local tbToken = string.split(Tokens, ",")

    self.c_openid = tbToken[1]
    self.c_openkeyser = tbToken[2]
    self.c_paytoken = tbToken[3]
    self.c_pf = tbToken[4]
    self.c_pfkey = tbToken[5]
    self.c_ts = tbToken[6]
    self.c_paytype = tbToken[7]
end

---------------------------------------------------------------------------------------------
function GamePlatform_QQ:OnQQPaySuccessResponse(tbMsg)

	cclog("--------------GamePlatform_QQ:OnQQPaySuccessResponse()----------------------")
	local msgDetail = zone_pb.QQPayNotifyRetCopous()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

    g_Hero:setYuanBao(msgDetail.copous)
end

