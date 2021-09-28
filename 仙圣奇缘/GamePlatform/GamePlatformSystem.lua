--------------------------------------------------------------------------------------
-- 文件名:	GamePlatformSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	从平台服获取服务器列表 然后 保存 最近的一个服务器。维护本地的服务器数据 登入流程修改
-- 应  用:  本例子是用类对象的方式实现


------------------------------编译子项-------------------------
g_LoadFile("LuaScripts/GamePlatform/PlatformBase")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_PP")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_XY")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_I4")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_Debug")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_HM")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_JF")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_TB")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_KY")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_GP")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_ITOOLS")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_91")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_UC")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_360")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_91_and")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_MI")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_HUAWEI")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_OPPO")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_LJ")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_ViVo")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_QQ")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_CoolPad")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_Lenovo")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_JINLI")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_YIJIE")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_VTCid")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_VIETIOS")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_LE8")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_49You")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_TlanCi")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_LiuLian")     
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_37Wan")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_TianGong")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_TWGoogle")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_TWTaiYou")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_CHWIOS")
g_LoadFile("LuaScripts/GamePlatform/GamePlatformz_XIAOAO")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_XiaoAo_Android")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_MiGu")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_SamSung")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_MeiZu")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_LeShi")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_IQiYi")
g_LoadFile("LuaScripts/GamePlatform/GamePlatform_XiaoAo_Android_AT")

GamePlatformSystem = class("GamePlatformSystem")
GamePlatformSystem.__index = GamePlatformSystem

--[[
--服务器定义枚举
// 充值的机器设备类型 IOS/Android
enum RechargeDeviceType
{
	RechargeDeviceType_IOS		= 1;		// IOS
	RechargeDeviceType_Android	= 2;		// Android
}
// 充值订单状态
enum RechargeBillnoStatus
{
	RechargeBillnoStatus_Init = 0;			// 初始创建
	RechargeBillnoStatus_Success = 1;		// 充值成功
	RechargeBillnoStatus_Failed = 2;		// 充值失败
}
]]

function GamePlatformSystem:ctor()
	self.m_PlatformInterface = nil  							--具体平台对象
	self.iaccount_id = 0; 										--账号uin
	self.Device 	= macro_pb.RechargeDeviceType_IOS; 			--设备平台

	self.strToken = nil  --在登陆界面断线的时候 缓存
	self.strPassword = nil
	self.strPayData = nil
end

function GamePlatformSystem:ReleaseAccountID()
	self.iaccount_id = 0; 
end

function GamePlatformSystem:GetAccount_PlatformID()
	return (self.iaccount_id ~= 0 and self.iaccount_id) or g_MsgMgr:getPlatformUin()
end

function GamePlatformSystem:SetAccount_PlatformID(account_id)
	self.iaccount_id = account_id
end

function GamePlatformSystem:GamePlatformInit()
	if CGamePlatform.GetPlatformType_PP ~= nil 
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_PP() then
		self.m_PlatformInterface = GamePlatform_PP.new()

	elseif CGamePlatform.GetPlatformType_XY ~= nil 
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_XY() then
		self.m_PlatformInterface = GamePlatform_XY.new()

	elseif  CGamePlatform.GetPlatformType_I4 ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_I4() then
		self.m_PlatformInterface = GamePlatform_I4.new()

	elseif CGamePlatform.GetPlatformType_Debug ~= nil 
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_Debug() then
		self.m_PlatformInterface = GamePlatform_Debug.new()

	elseif CGamePlatform.GetPlatformType_HM ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_HM() then
		self.m_PlatformInterface = GamePlatform_HM.new()

	elseif CGamePlatform.GetPlatformType_KY ~= nil 
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_KY() then
		self.m_PlatformInterface = GamePlatform_KY.new()

	elseif CGamePlatform.GetPlatformType_JF ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_JF() then
		self.m_PlatformInterface = GamePlatform_JF.new()

	elseif CGamePlatform.GetPlatformType_GP ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_GP() then
		self.m_PlatformInterface = GamePlatform_GP.new()

	elseif CGamePlatform.GetPlatformType_ITOOLS ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_ITOOLS() then
		self.m_PlatformInterface = GamePlatform_ITOOLS.new()

	elseif CGamePlatform.GetPlatformType_91 ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_91() then
		self.m_PlatformInterface = GamePlatform_91.new()

	elseif  CGamePlatform.GetPlatformType_TB ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_TB() then
		self.m_PlatformInterface = GamePlatform_TB.new()

    elseif CGamePlatform.GetPlatformType_VIET ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_VIET() then
		self.m_PlatformInterface = GamePlatform_VIETIOS.new()
		
    elseif CGamePlatform.GetPlatformType_LE8 ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_LE8() then
		self.m_PlatformInterface = GamePlatform_LE8.new()

    elseif CGamePlatform.GetPlatformType_CHW ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_CHW() then
		self.m_PlatformInterface = GamePlatform_CHWIOS.new()

    elseif CGamePlatform.GetPlatformType_XIAOAO ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_XIAOAO() then
		self.m_PlatformInterface = GamePlatform_XIAOAO.new()
		
	elseif EAndroidType_UC ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_UC then
		self.m_PlatformInterface = GamePlatform_UC.new()

	elseif EAndroidType_OPPO ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_OPPO then
		self.m_PlatformInterface = GamePlatform_OPPO.new()

	elseif EAndroidType_360 ~= nil 
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_360 then
		self.m_PlatformInterface = GamePlatform_360.new()

	elseif EAndroidType_91 ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_91 then
		self.m_PlatformInterface = GamePlatform_91_and.new()

	elseif EAndroidType_MI ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_MI then
		self.m_PlatformInterface = GamePlatform_MI.new()	
		
	elseif EAndroidType_HUAWEI ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_HUAWEI then
		self.m_PlatformInterface = GamePlatform_HUAWEI.new()
		
	elseif EAndroidType_LJ ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_LJ then
		self.m_PlatformInterface = GamePlatform_LJ.new()

    elseif EAndroidType_QQ ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_QQ then
		self.m_PlatformInterface = GamePlatform_QQ.new()
		
	elseif EAndroidType_CoolPad ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_CoolPad then
		self.m_PlatformInterface = GamePlatform_CoolPad.new()
		
	elseif EAndroidType_vivo ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_vivo then
		self.m_PlatformInterface = GamePlatform_ViVo.new()
	elseif EAndroidType_Lenovo ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_Lenovo then
		self.m_PlatformInterface = GamePlatform_Lenovo.new()
	elseif EAndroidType_JINLI ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_JINLI then
		self.m_PlatformInterface = GamePlatform_JINLI.new()

	elseif EAndroidType_YIJIE ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_YIJIE then
		self.m_PlatformInterface = GamePlatform_YIJIE.new()
	elseif EAndroidType_VTCID ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_VTCID then --越南平台
		self.m_PlatformInterface = GamePlatform_VTCid.new()
    elseif EAndroidType_49You ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_49You then
	    self.m_PlatformInterface = GamePlatform_49You.new()
	elseif EAndroidType_TLANCI ~= nil
		and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_TLANCI then --天赐平台
		self.m_PlatformInterface = GamePlatform_TlanCi.new()
    elseif EAndroidType_LiuLian ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_LiuLian then
	    self.m_PlatformInterface = GamePlatform_LiuLian.new()
    elseif EAndroidType_37Wan ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_37Wan then
	    self.m_PlatformInterface = GamePlatform_37Wan.new()
    elseif EAndroidType_TianGong ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_TianGong then
	    self.m_PlatformInterface = GamePlatform_TianGong.new()
    elseif EAndroidType_TWGoogle ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_TWGoogle then
	    self.m_PlatformInterface = GamePlatform_TWGoogle.new()
    elseif EAndroidType_TWTaiYou ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_TWTaiYou then
	    self.m_PlatformInterface = GamePlatform_TWTaiYou.new()
    elseif EPlatformType_XIAOAO_ANDROID ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EPlatformType_XIAOAO_ANDROID then
	    self.m_PlatformInterface = GamePlatform_XiaoAoAndroid.new()
    elseif EAndroidType_MiGu ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_MiGu then
	    self.m_PlatformInterface = GamePlatform_MiGu.new()
    elseif EAndroidType_SamSung ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_SamSung then
	    self.m_PlatformInterface = GamePlatform_SamSung.new()
    elseif EAndroidType_MeiZu ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_MeiZu then
	    self.m_PlatformInterface = GamePlatform_MeiZu.new()
    elseif EAndroidType_LeShi ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_LeShi then
	    self.m_PlatformInterface = GamePlatform_LeShi.new()
    elseif EAndroidType_IQiYi ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EAndroidType_IQiYi then
	    self.m_PlatformInterface = GamePlatform_IQiYi.new()
    elseif EPlatformType_XIAOAO_ANDROID_AT ~= nil
	    and CGamePlatform:SharedInstance():GetCurPlatform() == EPlatformType_XIAOAO_ANDROID_AT then
	    self.m_PlatformInterface = GamePlatform_XiaoAo_Android_AT.new()
	end
    
	if self.m_PlatformInterface ~= nil then
		self.m_PlatformInterface:PlatformInit()
	end

    if CGamePlatform:SharedInstance().AddOnEventLogin ~= nil then
	    CGamePlatform:SharedInstance():AddOnEventLogin(OnSuccedLogiin)
    end
    if CGamePlatform:SharedInstance().AddOnEventLoginout ~= nil then
	    CGamePlatform:SharedInstance():AddOnEventLoginout(OnSuccedLogOUt)
    end
    if CGamePlatform:SharedInstance().AddOnEventPaySucc ~= nil then
        CGamePlatform:SharedInstance():AddOnEventPaySucc(OnPaySucc)--充值成功的返回，暂时应用宝使用
    end
    if CGamePlatform:SharedInstance().AddOnEventrefreshTokens ~= nil then
        CGamePlatform:SharedInstance():AddOnEventrefreshTokens(OnrefreshTokens)--充值成功的返回，暂时应用宝使用
    end
    if CGamePlatform:SharedInstance().AddOnEventFBDataHandler ~= nil then
        CGamePlatform:SharedInstance():AddOnEventFBDataHandler(OnFBDataCallBack)
    end
    if CGamePlatform:SharedInstance().AddOnEventFBShareBack ~= nil then
        --CGamePlatform:SharedInstance():AddOnEventFBShareBack(OnFBShareCallBack)
    end
    if CGamePlatform:SharedInstance().AddOnEventAppstorePaySucc ~= nil then
        CGamePlatform:SharedInstance():AddOnEventAppstorePaySucc(OnAppstorePaySucc)
    end
	if CGamePlatform:SharedInstance().AddOnEventGetPriceByItemId ~= nil then
		CGamePlatform:SharedInstance():AddOnEventGetPriceByItemId(OnGetPriceByItemId)
	end
	-- 返回订单号
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_RECHARGE_BILLNUM_RESPONSE, handler(self, self.OnRespondBillNum))
	-- 通知客户端充值结果
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SDK_RECHARGE_NOTIFY_RESULT, handler(self, self.OnRespondBillResult))

	--切入后台回调
	if not g_OnExitGame then --外网没有修改c++ 老的api
		CSocketBackground:shareInstance():RegiestLuaFunction(OnGameEnterBackGround)
		CSocketBackground:shareInstance():RegiestLuaForegroundFunction(OnGameForeGround)
	
		if g_Cfg.Platform  ~= kTargetWindows  then
		CSocketBackground:shareInstance():RegiestRecountCallBackFunction(OnRecountCallBack)
		end
	else

		CSocketBackground:shareInstance():RegiestLuaFunction(OnGameEnterBackGround)
		CSocketBackground:shareInstance():RegiestForeground(OnGameForeGround)
	
		if g_Cfg.Platform  ~= kTargetWindows  then
		CSocketBackground:shareInstance():RegiestReconnectCallBack(OnRecountCallBack)
		end
	end
end

function GamePlatformSystem:GetServerPlatformType()
	
	if self.m_PlatformInterface ~= nil then
		return self.m_PlatformInterface:GetServerPlatformType()
	end

	return macro_pb.LOGIN_PLATFORM_NONE
end

function GamePlatformSystem:GetChildPlatformType()
	
	if self.m_PlatformInterface ~= nil and self.m_PlatformInterface.GetChildPlatformType then
		return self.m_PlatformInterface:GetChildPlatformType()
	end

	return "无子渠道"
end

function GamePlatformSystem:PlatformStart()
	if self.m_PlatformInterface ~= nil then
		self.m_PlatformInterface:GamePlatformStart()
	end
end

function GamePlatformSystem:PlatformAffterConnect()
	if  self.strToken ~= nil then
		-- cclog("GamePlatformSystem:PlatformAffterConnect ..="..self.strToken)
		self.m_PlatformInterface:LoginPlatformSuccessCallBack(self.strToken, self.strPassword);
		self.strToken = nil
		self.strPassword = nil
	end
end

--平台点击登入
function GamePlatformSystem:OnClickGameLogin(loginType)
	if self.m_PlatformInterface ~= nil then
		return self.m_PlatformInterface:GameLogin(loginType);
	end
	return false
end

--游戏内 处理点击 注销游戏
function GamePlatformSystem:OnClickGameLoginOut()
	if self.m_PlatformInterface ~= nil then
		self.m_PlatformInterface:GameLoginOut()
	end
end

function GamePlatformSystem:ConnectPlatform()
	if self.m_PlatformInterface ~= nil then
		self.m_PlatformInterface:GameConnectPlatform()
	end
end

function GamePlatformSystem:SetPlatformAccountInfo(uid)
	onPressed_Button_Close()
	setUserRegData() --记录本地账号
    g_MsgMgr:setUserID(uid)
    --g_MsgMgr:requestRole() 跟账号注册成功一样的流程 发送到 serverlistinfo 处理 先建链zone服务器。。。
end

--客户端请求订单号
--[[
// 请求订单号
message RechargeBillnoRequest
{
	optional RechargeDeviceType type = 1;	// 充值的机器设备类型
	optional uint32 recharge_id = 2;		// 在shoprechage表格里面的ID
}
]]
function GamePlatformSystem:RequestBillNum(recharge_id)
--	 if g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_MIGU_XIAOAO then
--	 	g_ShowSysWarningTips({text ="充值暂未开放"})
--	 	return
--	 end

--    if g_IsShenYuLing ~= nil and g_IsShenYuLing == true and  g_Cfg.Csv_Platform == 1 then
--        g_ShowSysWarningTips({text ="充值暫未開放"})
--	 	return    
--    end


    --客户端自己读取充值数据，现在适用应用宝
    if self.m_PlatformInterface~=nil and self.m_PlatformInterface.PlatformPayByClient~=nil then
        self.m_PlatformInterface:PlatformPayByClient(recharge_id)
        return
    end

	local Billmsg = zone_pb.RechargeBillnoRequest()
	Billmsg.type  = self.Device
	Billmsg.recharge_id = recharge_id
	Billmsg.sdk_uin = self.m_PlatformInterface:getUin() or ""
	Billmsg.game_name_type = GameType or macro_pb.GameNameType_DSX --区分版本类型
    if g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_YI_JIE then
        Billmsg.sdk = g_GamePlatformSystem:GetChildPlatformType()
    end
	
	cclog("--GamePlatformSystem:RequestBillNum--"..Billmsg.type .." "..Billmsg.recharge_id )
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SDK_RECHARGE_BILLNUM_REQUEST, Billmsg)

	if self.m_PlatformInterface ~= nil then
		self.m_PlatformInterface:setRecharge(recharge_id)
	end

	g_MsgNetWorkWarning:showWarningText()
end

--客户端响应订单号
function GamePlatformSystem:OnRespondBillNum(tbMsg)
	if self.m_PlatformInterface ~= nil then
		cclog("-客户端响应订单号")
		self.m_PlatformInterface:OnRespondGameServerRechage(tbMsg)
	end
	--g_MsgNetWorkWarning:closeNetWorkWarning()
end

--客户端响应兑换结果
--[[
// 通知客户端充值结果
message RechargeResultNotify
{
	optional uint32 res_code = 1;				// 平台SDK返回的错误哦
	optional uint32 plattype = 2;				// 充值的平台类型， 和上面的code标识充值结果，如果是失败下面的不读
	optional uint32 total_recharge_value = 3;	// 累计充值元宝
	optional uint32 coupon = 4;					// 充值后总的元宝
	optional uint32 vip_level = 5;				// vip等级
	optional uint32 recharge_id = 6;			// 充值的id，这个也许客户端需要用到更新界面，保留
    optional uint32 order_id = 7;				// 订单号
}
]]
function GamePlatformSystem:OnRespondBillResult(tbMsg)
	cclog("GamePlatformSystem:OnRespondBillResult")
    g_MsgNetWorkWarning:closeNetWorkWarning()
	local msgDetail = zone_pb.RechargeResultNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
    g_GamePlatformSystem.strPayData = nil

	local nGetValue = msgDetail.coupon - g_Hero:getYuanBao()
    local tbRechage = g_DataMgr:getShopRechargeCsv(msgDetail.recharge_id)
    gTalkingData:onChargeRequst(msgDetail.order_id, tbRechage.TalkingDataID, tbRechage.RMBPrice,tbRechage.SellNum)
    gTalkingData:onChargeSuccess(msgDetail.order_id)
	g_Hero:ShopRecharge(msgDetail)
	
	--如果充值界面打开着，需要更新充值界面
    g_FormMsgSystem:SendFormMsg(FormMsg_ReCharge_UpdataWnd, nGetValue)
    if g_WndMgr:getWnd("Game_Home") ~= nil then
        g_WndMgr:getWnd("Game_Home"):refreshHomeStatusBar()
    end

    --talkingdata广告统计
    if CGameDataAdTracking and CGameDataAdTracking.onPlaceOrder then
        CGameDataAdTracking:onPlaceOrder(msgDetail.order_id, tbRechage.TalkingDataID, tbRechage.ID, tbRechage.Name, tbRechage.RMBPrice*100, 1, "CNY")
    end

    if CGameDataAdTracking and CGameDataAdTracking.onPay then
        CGameDataAdTracking:onPay(g_GamePlatformSystem:GetAccount_PlatformID(), msgDetail.order_id, tbRechage.TalkingDataID, tbRechage.ID, tbRechage.Name, tbRechage.RMBPrice*100, 1, "CNY", 1)
    end

    --CGameDataAppsFlyer广告统计
--    if CGameDataAppsFlyer and CGameDataAppsFlyer.onPay then
--        CGameDataAppsFlyer:onPay(msgDetail.order_id, tbRechage.TalkingDataID, tbRechage.ID, tbRechage.Name, tbRechage.RMBPrice*100)
--        cclog("CGameDataAppsFlyer:onPay:")
--    end
end

function GamePlatformSystem:AccountRegResponse()
	if self.m_PlatformInterface ~= nil then
		return self.m_PlatformInterface:AccountRegResponse()
	end

	return false
end

--------------------内部处理函数------------
function GamePlatformSystem:OnCallBackLoginSucceed(Token, password)
	cclog("GamePlatformSystem:OnCallBackLoginSucceed")
	if self.m_PlatformInterface ~= nil then
		if g_ServerList:IsGameSocketClose() == true then

			self.strToken = Token
			self.strPassword = password

		elseif g_MsgMgr:GetCurConnectType() == Class_MsgMgr_Zone  then --专为切小号

			-- self.strToken = Token
			-- self.strPassword = password

			-- g_ServerList:ConnectPlatform()
			-- g_FormMsgSystem:SendFormMsg(FormMsg_ClientNet_LogOut, nil)
			self:OnClickGameLoginOut()

		else
			self.m_PlatformInterface:LoginPlatformSuccessCallBack(Token, password);
		end
		
	end
end

function GamePlatformSystem:OnCallBackLogOutSucced()
	if self.m_PlatformInterface ~= nil then
		self.m_PlatformInterface:LoginOutCallBack()
	end
end

------------------------c++调用锁屏回调-----------------
function OnGameEnterBackGround()
	-- local rootMsg = xxz_msg_pb.xxz_Msg()
	-- rootMsg.msgid = msgid_pb.MSGID_CLIENT_SLEEP_REQUEST
	-- rootMsg.uin = g_MsgMgr:getUin()
	-- rootMsg.platform = g_MsgMgr.loginPlatform
	-- rootMsg.account = CCUserDefault:sharedUserDefault():getStringForKey("DailyAccount", "")--self.szAccount
	-- rootMsg.session_key = g_MsgMgr.szSessionKey
	-- rootMsg.account_id = g_GamePlatformSystem:GetAccount_PlatformID()
	-- rootMsg.platform = g_GamePlatformSystem:GetServerPlatformType()

	local rootMsg = xxz_msg_pb.xxz_Msg()
	rootMsg.msgid = msgid_pb.MSGID_CLIENT_SLEEP_REQUEST
	rootMsg.uin = g_MsgMgr:getUin()
	rootMsg.platform = g_MsgMgr.loginPlatform
	rootMsg.account = CCUserDefault:sharedUserDefault():getStringForKey("DailyAccount", "")--self.szAccount
	rootMsg.session_key = g_MsgMgr.szSessionKey
	rootMsg.account_id = g_GamePlatformSystem:GetAccount_PlatformID()
	rootMsg.platform = g_GamePlatformSystem:GetServerPlatformType()
	rootMsg.session_token = g_MsgMgr:GetSession_token()

	local szMsgData = rootMsg:SerializeToString()
	API_PostMessage(string.len(szMsgData), szMsgData)

	if g_ClientPing then
		g_ClientPing:StopPing()
	end

	-- if g_In_Game then
	-- 	API_CloseSocket()
	-- end
	
end

function OnGameForeGround()
	if g_In_Game then
		API_ReConnect()
		g_ServerList:SetClientConnectState()
	end
end

function OnSuccedLogiin(Token, uid)
	-- cclog("OnSuccedLogiin-------->"..Token, pass)
	-- local Token =  CGamePlatform:SharedInstance():getPlatformToken()
	-- local uid =  CGamePlatform:SharedInstance():getPlatformUid()
	-- cclog("OnSuccedLogiin-------->"..tostring(Token).." uid="..tostring(uid))
	if g_GamePlatformSystem then
		g_GamePlatformSystem:OnCallBackLoginSucceed(Token, uid)
	end
end

--有第三方sdk 注销回调调用
function OnSuccedLogOUt()
	cclog("--------OnSuccedLogOUt-------->")
	if g_GamePlatformSystem then
		g_GamePlatformSystem:OnCallBackLogOutSucced()
	end
end

function OnrefreshTokens(Tokens)
	cclog("--------OnrefreshTokens-------->")

    if g_GamePlatformSystem.m_PlatformInterface ~=nil and  
    g_GamePlatformSystem.m_PlatformInterface.SendrefreshTokens ~=nil  and
    g_GamePlatformSystem.m_PlatformInterface.refreshTokens ~=nil
    then
        g_GamePlatformSystem.m_PlatformInterface:refreshTokens(Tokens)
        g_GamePlatformSystem.m_PlatformInterface:SendrefreshTokens()
    end
end

function OnPaySucc(strPayData)
	cclog("--------OnPaySucc-------->")
    --if g_GamePlatformSystem.m_PlatformInterface ~=nil and  g_GamePlatformSystem.m_PlatformInterface.OnPlatformPaySuccess ~=nil then
	--	g_GamePlatformSystem.m_PlatformInterface:OnPlatformPaySuccess(strPayData)
	--end
    local pay_data = string.split(strPayData, "|")
	local result = pay_data[1]
    local orderId = pay_data[2]
    if not orderId then
        cclog("--------not orderId------")
        g_GamePlatformSystem.strPayData = strPayData
        g_MsgNetWorkWarning:closeNetWorkWarning()    
    else
    	if result == "0" then
        	--充值成功
        	g_GamePlatformSystem.strPayData = orderId
    	else
        	--充值取消，或失败
        	g_MsgNetWorkWarning:closeNetWorkWarning()    
    	end
    end
end

function RunPaySucc()
	if g_GamePlatformSystem.strPayData and g_GamePlatformSystem.m_PlatformInterface ~=nil and  g_GamePlatformSystem.m_PlatformInterface.OnPlatformPaySuccess ~=nil then
		g_GamePlatformSystem.m_PlatformInterface:OnPlatformPaySuccess(g_GamePlatformSystem.strPayData)
		g_GamePlatformSystem.strPayData = nil
    end
end

function OnRecountCallBack()
	cclog("--------OnRecountCallBack-------->")

	g_MsgMgr.bConnetingNetWork = true
	API_ReConnect()
	g_MsgNetWorkWarning:showWarningText(true)
	g_ServerList:SetClientConnectState()
	
	-- --第一只有在区服务器里面 切后台返回来的时候
	-- if g_ClientPing and g_MsgMgr and g_MsgMgr:GetCurConnectType() == Class_MsgMgr_Zone then
	-- 	g_ClientPing:StartPing()
	-- end

end

--appstore充值成功返回
function OnAppstorePaySucc(strPaydata, productId)
	cclog("--------OnAppstorePaySucc-------->")
    if strPaydata == "false" then 
        g_ShowSysTips({text=_T("充值失败")})
        g_MsgNetWorkWarning:closeNetWorkWarning()
        return
    end
    cclog("%s", productId)

    local msg = zone_pb.RechargeXiaoaoIosReq()
	msg.type  = g_GamePlatformSystem.Device
	msg.game_name_type = GameType or macro_pb.GameNameType_DSX --区分版本类型
    msg.ios_codes = strPaydata
	g_MsgMgr:sendMsg(msgid_pb.MSGID_XIAOAO_IOS_RECHARGE_REQUEST, msg)

	g_MsgNetWorkWarning:showWarningText()

end

--用商品Id获取商品美元价格
function OnGetPriceByItemId(itemId)
	cclog("--------OnGetPriceByItemId-------->"..itemId)
	local price
	for i, v in pairs(ConfigMgr["ShopRecharge"]) do
		if itemId == v.ProductID then
			price = v.DollarPrice..""
		end
	end

	return price
end

--FB 通知回调
function OnEventAppstorePaySucc(strData)
    if g_FacebookRewardSys then
        g_FacebookRewardSys:ReqInviteReward(strData)
    end
end

--FB 通知回调
function OnFBDataCallBack(strData)
    if g_FacebookRewardSys then
        g_FacebookRewardSys:ReqInviteReward(strData)
    end
end
--FB 通知回调
function OnFBShareCallBack(strData)
    if g_FacebookRewardSys then
        g_FacebookRewardSys:ReqShareReward(strData)
    end
end

---------------------------------------协议-------------------


g_GamePlatformSystem = GamePlatformSystem.new()
g_GamePlatformSystem:GamePlatformInit()