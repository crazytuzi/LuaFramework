--------------------------------------------------------------------------------------
-- 文件名:	MsgMgr.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-1-14 15:24
-- 版  本:	1.0
-- 描  述:	服务器消息
-- 应  用:
---------------------------------------------------------------------------------------

Class_MsgMgr = class("Class_MsgMgr")
Class_MsgMgr.__index = Class_MsgMgr

Class_MsgMgr_Platform 	= 0		--接入的事平台服务器
Class_MsgMgr_Zone		= 1		--接入的是区服务器
local function ReLogin()
--	g_backToReLogin()
-- g_FormMsgSystem:SendFormMsg(FormMsg_ClientNet_LogOut, nil)
g_GamePlatformSystem:OnClickGameLoginOut()
end

local function reconnetAgain()
	--正在连接
	if g_MsgMgr.bConnetingNetWork then cclog("connecting return") return end

	g_MsgMgr.bConnectSucc = nil
	g_MsgMgr.bConnetingNetWork = true
	API_ReConnect()
end

function Class_MsgMgr:ctor()
	self.nUin = 0
	--当前建链IP类型 0为平台 1为区服务器
	self.iConnectType = Class_MsgMgr_Platform

	self.PlatformUID = 0
	self.ZoneUID 	 = 0

	--认证登陆的session token
	self.session_token = 0
end

function Class_MsgMgr:GetSession_token()
	return self.session_token
end

--初始化怪物数据
function Class_MsgMgr:create()
	local nCsvID = CCUserDefault:sharedUserDefault():getIntegerForKey("nCsvID", 0)
	if nCsvID == 0 then
	    _, nCsvID = g_DataMgr:getSeverInfoCsvNew()
	end

	self:setServerCfgID(nCsvID)

	self:createRecvThread()

	math.randomseed(os.time())

	self:setWaitTimeOut(0.5)
	self:setWaitClearTime(5)
	self.szAccount = CCUserDefault:sharedUserDefault():getStringForKey("DailyAccount", "")
    self.loginPlatform = CCUserDefault:sharedUserDefault():getIntegerForKey("loginPlatform", 0)
	self.szSessionKey = ""
    local registered_time = CCUserDefault:sharedUserDefault():getStringForKey("RegisteredTime", "")
    if registered_time == "" or not registered_time then
        local ntime = os.time()
        local n_count = math.random(1, 1000000)
        self.imei = ntime..""..n_count 
        CCUserDefault:sharedUserDefault():setStringForKey("RegisteredTime", self.imei)
    else
        self.imei = registered_time 
    end
    cclog("手机imei:"..self.imei)
end

function Class_MsgMgr:getUin()
	-- cclog("====Class_MsgMgr:getUin==== self.ZoneUID="..self.ZoneUID.." self.PlatformUID="..self.PlatformUID)
	if self.iConnectType == Class_MsgMgr_Platform then
		return self.PlatformUID
	end

	if self.iConnectType == Class_MsgMgr_Zone then
		return ( self.ZoneUID == 0 and self.PlatformUID ) or self.ZoneUID
	end

	return self.nUin

end

function Class_MsgMgr:getPlatformUin()
	return self.PlatformUID 
end

function Class_MsgMgr:getZoneUin()
	return self.ZoneUID
end

function Class_MsgMgr:SetGameUID(nUid)
	if self.iConnectType == Class_MsgMgr_Platform then
		self.PlatformUID = nUid
	end

	if self.iConnectType == Class_MsgMgr_Zone then
		self.ZoneUID = nUid
	end
end

function Class_MsgMgr:ResetGameUID()
	self.PlatformUID = 0
	self.ZoneUID = 0

end

function Class_MsgMgr:ResetZoneID()
	self.ZoneUID = 0
end

function Class_MsgMgr:SetCurConnectType(itype)
	self.iConnectType = itype
end

function Class_MsgMgr:GetCurConnectType()
	return self.iConnectType
end

function Class_MsgMgr:ignoreCheckWaitTime(bCheck)
	self.bCheckWaitTime = bCheck
end

function Class_MsgMgr:resetAccount()
	cclog("------->Class_MsgMgr:resetAccount()")
	-- self.szAccount = ""
	-- CCUserDefault:sharedUserDefault():setStringForKey("Account", "" )

	-- self.loginPlatform = 0
	-- CCUserDefault:sharedUserDefault():setIntegerForKey("loginPlatform", 0)
	
	self.nUin = 0
	--当前建链IP类型 0为平台 1为区服务器
	self.iConnectType = Class_MsgMgr_Platform

	self.PlatformUID = 0
	self.ZoneUID 	 = 0
	self.szAccount = ""
	self.szSessionKey = ""
	self.szNickName = nil
	g_GamePlatformSystem:ReleaseAccountID()
	self.session_token = 0
end

function Class_MsgMgr:setAccount(tbMsg)
	cclog("------------------->Class_MsgMgr:setAccount(tbMsg)"..tbMsg.account)
	self.szAccount = tbMsg.account
	CCUserDefault:sharedUserDefault():setStringForKey("Account", self.szAccount )

	self.loginPlatform =  tbMsg.platform
	CCUserDefault:sharedUserDefault():setIntegerForKey("loginPlatform", self.loginPlatform)

	if tbMsg.HasField and tbMsg:HasField("client_debug_info") then
		self.szNickName = tbMsg.client_debug_info
	else
		self.szNickName = nil
		self.szSessionKey = ""
	end
end

--发送消息
function Class_MsgMgr:sendMsg(nIDMsg, tbMsg)
	if(not nIDMsg)then
		error("************Class_MsgMgr:sendMsg tbMsg nil***********")
	end

	local nCurTime = API_GetCurrentTime()
	if(nIDMsg ~= msgid_pb.MSGID_UPDATE_NEWBIE_GUIDE_REQUEST and
		nIDMsg ~= msgid_pb.MSGID_ROLE_HEARTBEAT_MSG  and 
		not self.bCheckWaitTime and 
		self.nSendMsgTime and
		nCurTime - self.nSendMsgTime <= self.nWaitTimeOut)then
		cclog("************send msg too quick************")
		-- return
	end

    if(self.bConnetingNetWork)then
		cclog("=========bConnetingNetWork===========")
        return --摒弃当前消息
    end

	-- 如果是在游戏里面掉线了 发的消息存在发送队列里面 在平台服的时候只是简单的 重连
    if (not self.bConnectSucc) and (self.iConnectType == Class_MsgMgr_Platformthen) then
		cclog("=========bConnectSucc false ===========")
		reconnetAgain() --重连一次

		g_MsgNetWorkWarning:showWarningText(true)
		--return --摒弃当前消息
	end

	cclog("当前 UIN ==".. self:getUin())
	local rootMsg = xxz_msg_pb.xxz_Msg()
	rootMsg.msgid = nIDMsg
	rootMsg.uin = self:getUin()
	rootMsg.platform = self.loginPlatform
	rootMsg.account = CCUserDefault:sharedUserDefault():getStringForKey("DailyAccount", "")--self.szAccount
	rootMsg.session_key = self.szSessionKey
	rootMsg.account_id = g_GamePlatformSystem:GetAccount_PlatformID()
	rootMsg.platform = g_GamePlatformSystem:GetServerPlatformType()
	rootMsg.session_token = self.session_token
	rootMsg.game_name_type = GameType or macro_pb.GameNameType_DSX
    rootMsg.type = g_Cfg.Csv_Platform
    rootMsg.device_id = self.imei
	if(tbMsg)then
		rootMsg.buffer = tbMsg:SerializeToString()
	end

	-- --以下正式版本需要注释掉的调试信息
	if g_Cfg.Debug and nIDMsg ~= msgid_pb.MSGID_ROLE_HEARTBEAT_MSG then
		local msginfo = tostring(rootMsg)
		print(msginfo)

		if(tbMsg)then
			msginfo = tostring(tbMsg)
			cclog(msginfo)
		end
	end
	
	local szMsgData = rootMsg:SerializeToString()
	API_SendMessage(string.len(szMsgData), szMsgData)

    if(nIDMsg ~= msgid_pb.MSGID_UPDATE_NEWBIE_GUIDE_REQUEST) then--重置时间
	    self.nSendMsgTime = nCurTime
    end
end

function Class_MsgMgr:setServerCfgID(nCsvID)
	self.nCsvID = nCsvID
    local tbServer = g_DataMgr:getSeverInfoCsv(self.nCsvID)
    --self.nUin = tbServer.AreaID*1000000 + CCUserDefault:sharedUserDefault():getIntegerForKey("UserID",0)
end

function Class_MsgMgr:checkNetWork()
	return self.bConnectSucc
end

--连接 平台服务器
function Class_MsgMgr:connectToDir()
	if self.bConnetingNetWork then
        cclog("connectToDir return")
        return
     end

	local tbServer = g_DataMgr:getSeverInfoCsv(self.nCsvID)
	self.bConnectSucc = nil
	self.bConnetingNetWork = true
    self.bConnetcDir = true
    --修改登录流程
	--API_InitSocket(tbServer.Aport, tbServer.AIP)
	g_ServerList:ConnectPlatform()
end

--连接 游戏服务器
function Class_MsgMgr:connectToZone(nPort, szIP)
	local tbServer = g_DataMgr:getSeverInfoCsv(self.nCsvID)
	self.bConnectSucc = nil
	--修改登录流程
	--API_ConnectToServer(tbServer.Port, tbServer.IP)
	g_ServerList:ConnectZone()
end


----------------------------------------------------------------
--请求创建角色
function Class_MsgMgr:requestCreateRole(szName, cardconfig)
 	local createRoleMsg = zone_pb.CreateRoleRequest()
	createRoleMsg.name = szName
	createRoleMsg.configid = cardconfig
	createRoleMsg.world = g_ServerList:GetLocalServerID()

	self:sendMsg(msgid_pb.MSGID_CREATEROLE_REQUEST, createRoleMsg)
	g_MsgNetWorkWarning:showWarningText()
end

--请求角色信息
function Class_MsgMgr:requestRole()
	cclog("==========requestRole===========")
	local rolelisterquset = account_pb.ListRoleRequest()
	rolelisterquset.world = g_ServerList:GetLocalServerID()
	if self:GetCurConnectType() == Class_MsgMgr_Zone then
		cclog("确实是发送了数据?")
		cclog(tostring(g_ServerList.LocalServer.port))
		cclog(tostring(g_ServerList.LocalServer.ip))
        g_MsgNetWorkWarning:showWarningText()
		self:sendMsg(msgid_pb.MSGID_LISTROLE_REQUEST, rolelisterquset)
	end
end

function Class_MsgMgr:requestCheckName(szName) --检测重名请求
	cclog("==========requestCheckName===========")
	local msg = account_pb.CheckNameRequest()
	msg.name = szName
	self:sendMsg(msgid_pb.MSGID_CHECKNAME_REQUEST, msg)
end

--请求随机名字
function Class_MsgMgr:requestRandomName()
	cclog("==========requestRandomName===========")
	self:sendMsg(msgid_pb.MSGID_RANDOMNAME_REQUEST)
	
	-- local TDdata = CDataEvent:CteateDataEvent()
	-- TDdata:PushDataEvent("Step1", "S") --S or F, Success or Fail
	-- gTalkingData:onEvent(TDEvent_Type.Create, TDdata)
end

--请求战斗
function Class_MsgMgr:requestBattleInfo(nIDMap)
	local attackRequest = zone_pb.AttackSmallPassRequest()
	attackRequest.small_passid = nIDMap
	self:sendMsg(msgid_pb.MSGID_ATTACK_SMALLPASS_REQUEST, attackRequest)
	g_MsgNetWorkWarning:showWarningText()

	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_ATTACK_SMALLPASS_REQUEST)
end


--请求登陆
function Class_MsgMgr:requestLogin()
	cclog("==========requestLogin===========")
	-- self:connectToZone()

 --    local function sendLogin()
	--     local loginin = zone_pb.LoginRequest()
	--     loginin.uin = self.nUin
	--     loginin.channel = 1
	--     self:sendMsg(msgid_pb.MSGID_LOGIN_REQUEST, loginin, true)
 --    end

 --    self.delayToSendFuc = sendLogin
 --    --同步一下服务器时间
	-- g_MsgMgr:requestSyncServerTime()

	local loginin = zone_pb.LoginRequest()
    loginin.uin = self.nUin
    loginin.channel = 1
    self:sendMsg(msgid_pb.MSGID_LOGIN_REQUEST, loginin, true)
		
    g_MsgNetWorkWarning:showWarningText()

end

--请求GM命令
function Class_MsgMgr:requestGM(szStr)
	local gmRequeset = zone_pb.GMCommandRequest()
	gmRequeset.uin = self.nUin
	gmRequeset.gm_command = szStr
	self:sendMsg(msgid_pb.MSGID_GM_COMMMAND_REQUEST, gmRequeset)
end

--邀请 更换
function Class_MsgMgr:requestInviteCard(nCardID, index)
	local rootMsg = zone_pb.ChangeArrayOpRequest()
	rootMsg.change_op = zone_pb.ChangeArrayType_Add
	rootMsg.cardid1 = nCardID
	rootMsg.index1 = index
	self:sendMsg(msgid_pb.MSGID_CHANGE_ARRAYOP_REQUEST, rootMsg)

	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_CHANGE_ARRAYOP_REQUEST)
end

--删除布阵
function Class_MsgMgr:requestDeleteCard(index)
	local rootMsg = zone_pb.ChangeArrayOpRequest()
	rootMsg.change_op = zone_pb.ChangeArrayType_Del
	rootMsg.index1 = index

	self:sendMsg(msgid_pb.MSGID_CHANGE_ARRAYOP_REQUEST, rootMsg)
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_CHANGE_ARRAYOP_REQUEST)
end

--阵法更换请求
function Class_MsgMgr:requestChangeToLeader(index)
	local rootMsg = zone_pb.ChangeArrayOpRequest()
	rootMsg.change_op = zone_pb.ChangeArrayType_SetLeader
	rootMsg.index1 = index

	self:sendMsg(msgid_pb.MSGID_CHANGE_ARRAYOP_REQUEST, rootMsg)
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_CHANGE_ARRAYOP_REQUEST)
end

--客栈刷新请求(伙伴召唤)
function Class_MsgMgr:requestSummonCardRefresh()
	self:sendMsg(msgid_pb.MSGID_SUMMON_CARD_REFRESH_REQUEST)
end

--客栈招募请求(伙伴召唤)
function Class_MsgMgr:requestSummonCard(id, free,isTenExtract)
	local rootMsg = zone_pb.SummonCardRequest()
	rootMsg.type = id
	rootMsg.is_free = free
	rootMsg.is_ten_extract = isTenExtract
	self:sendMsg(msgid_pb.MSGID_SUMMON_CARD_REQUEST, rootMsg)

	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_SUMMON_CARD_REQUEST)

end

--铁匠铺/丹药 打造/合成请求
function Class_MsgMgr:requestMarketComposite(Type_ID,is_coupon)
	local rootMsg = zone_pb.MarketCompositeRequest()
	rootMsg.formula_id = Type_ID --// 配方ID
    rootMsg.is_coupon_mode = is_coupon --// 是否是元宝合成
	self:sendMsg(msgid_pb.MSGID_MARKET_COMPOSITE_REQUEST, rootMsg)
end

--移动武将
function Class_MsgMgr:requestChangeCard(nBegin, nEnd)
	if not nBegin and not nEnd then return end
	
	local rootMsg = zone_pb.ChangeArrayOpRequest()
	rootMsg.change_op = zone_pb.ChangeArrayType_Move
	rootMsg.move_start_pos = nBegin
	rootMsg.move_end_pos = nEnd
	self:sendMsg(msgid_pb.MSGID_CHANGE_ARRAYOP_REQUEST, rootMsg)
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_CHANGE_ARRAYOP_REQUEST)
	g_MsgNetWorkWarning:showWarningText()
end

--元神兑换伙伴
function Class_MsgMgr:requestExChangeCard(nServerID,costType)
	local rootMsg = zone_pb.ExchangeGodRequest()
	rootMsg.exchange_card_god_id = nServerID --兑换的魂魄id
	rootMsg.cost_type = costType;			--// 优先消耗(1:魂魄 2:万能魂石)
	
	self:sendMsg(msgid_pb.MSGID_EXCHANGEGOD_REQUEST, rootMsg)

	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_EXCHANGEGOD_REQUEST)
end

--出售伙伴
function Class_MsgMgr:requestSellCard(tbCard)
	if(not tbCard )then
		cclog("requestSellCard error")
		return
	end

	local msg = zone_pb.SellCardRequest()
	for key, value in pairs(tbCard) do
		table.insert(msg.selled_card_id, key)
	end

	self:sendMsg(msgid_pb.MSGID_SELL_CARD_REQUEST, msg)
end

--伙伴装装备
function Class_MsgMgr:requestDressEquip(nCardID, nPos, nEquipID)
	if(not nCardID or not nPos or not nEquipID)then
		cclog("requestDressEquip error")
		return
	end

	local msg = zone_pb.ChangeEquipRequest()
	msg.change_cardid = nCardID
	msg.change_idx = nPos - 1
	msg.put_equip_id = nEquipID

	self:sendMsg(msgid_pb.MSGID_CHANGE_EQUIP_REQUEST, msg)
end

--伙伴升级
function Class_MsgMgr:requestLevUp(nCardID, tbData)
	if(not tbData or not nCardID)then
		cclog("requestLevUp error")
		return
	end

	local msg = zone_pb.UpgradeCardRequest()
	msg.upgrade_card_id = nCardID

	local i = 0
	for key, vale in pairs(tbData) do
		i = i + 1
		table.insert(msg.devour_cardid, key)
	end

	if(i == 0)then
		cclog("requestLevUp has no data")
		return
	end
	self:sendMsg(msgid_pb.MSGID_UPGRADE_CARD_REQUEST, msg)
end

--[[//连接失败
static const unsigned int MESSAGE_CONNECT_FAIL = 1;
//网络异常中断
static const unsigned int MESSAGE_CONNECT_TERMINATE = 2;
//服务器关闭连接
static const unsigned int MESSAGE_SERVER_CLOSE_CONNECTION = 3;
//消息发布出去（信号很差）
static const unsigned int MESSAGE_CANNOT_SEND_MESSAGE = 4;
//提示网络可能出问题了
static const unsigned int MESSAGE_IDLE_TIMEOUT = 5;
//提示网络可能出问题了,可以退出到登录
static const unsigned int MESSAGE_RECONNECT_HINT = 6;
//提示网络可能出问题了,必须退出到登录
static const unsigned int MESSAGE_RECONNECT_FORCE = 7;
//错误提示
static const unsigned int MESSAGE_ERROR_MESSAGE = 8;
//客户端主动关闭
static const unsigned int MESSAGE_CLIENT_KILL_MESSAGE = 9;
//创建网络失败
static const unsigned int MESSAGE_CREATESOCKET_FAIL = 10;
//连接服务器失败
static const unsigned int MESSAGE_CONNECTSERVER_FAIL = 11;
//连接服务器成功
static const unsigned int MESSAGE_CONNECTSERVER_SUCC = 12;
]]
local tbErrorDesc = {
	[1] = _T("连接失败"),
	[2] = _T("网络连接中断！"),
	[3] = _T("服务器关闭连接"),
	[9] = _T("客户端主动关闭"),
	[10] = _T("创建网络失败"),
	[11] = _T("连接服务器失败"),
	[12] = _T("连接服务器成功"),
}

local function showErrorDesc(index)
	if(index ~= 12 and g_MsgMgr.bReConnect)then
		local curScene = g_pDirector:getRunningScene()
		g_ShowServerSysTips({text = tbErrorDesc[index],layout = curScene, y = 232,x = 620})
	end

	cclog(tostring(tbErrorDesc[index]))
end

--获取注册的网络回调
function Class_MsgMgr:getRevcMsgCallBack(nMsgID)
	if not self.callBackFunc then
		return nil
	end
	return self.callBackFunc[nMsgID]
end

function Class_MsgMgr:createRecvThread()
	local function checkRecvMsg()
        while true do--一次性把所有的消息处理完
		    local bRet, szData, nSize =  API_PickReceivedMessage()
            if bRet < 0 then return true end

		    if(bRet == 0 )then
			    self.nSendMsgTime = nil

			    local rootMsg = xxz_msg_pb.xxz_Msg()
                rootMsg:ParseFromString(szData)
			    if rootMsg.msgid ~= (msgid_pb.MSGID_ROLE_HEARTBEAT_MSG ) then
			    	print(rootMsg.msgid.." ******RecvMsg START******** ")
			   	 	local info = tostring(rootMsg)
			    	print(info)
			    end

			    local nMsgID = rootMsg.msgid
			    local nUIN = rootMsg.uin
			    local nResult = rootMsg.result
			    if rootMsg.session_token and rootMsg.session_token ~= 0 then
			    	self.session_token = rootMsg.session_token
			    end
			    

			    if(nResult > 0)then
			    	g_MsgNetWorkWarning:closeNetWorkWarning()

			    	if nMsgID == msgid_pb.MSGID_LISTROLE_RESPONSE then --如果游戏服里面请求角色列表失败，就直接切回平台服。
			    		g_ServerList:ConnectPlatform()
			    	end
			    	
			    	local szText = nil

			    	if nResult < 1000000 then
			    		szText = g_DataMgr:getMsgContentCsv(nResult)
			    	end
				   
				    if(szText)then
					    local curScene = CCDirector:sharedDirector():getRunningScene()
						
					    if szText.showtype == 1 then --消息显示类型: 0:自动消失, win32 1. 需点击才消失
						    if nResult == g_DataMgr:getMsgContentCsvID("EQEC_HasBeenKickOff")  then
						    	local callback = nil
						    	if nResult == 2051 then --你已经在其他地方登陆！
						    		callback = ReLogin
						    		callback()
						    		g_ClientMsgTips:showMsgConfirm(szText.Description_ZH, nil)
						    		g_PushOut = 2051
						    	end
						    else
						    	g_ClientMsgTips:showMsgConfirm(szText.Description_ZH, function()
							    	 --异常处理
								    if nMsgID == msgid_pb.MSGID_ACCOUNT_LOGIN_RESPONSE then
								    	g_IsExistedActor = nil
			          					g_GamePlatformSystem:OnClickGameLoginOut()
								    end
					     		end)
						    end
						    
					    else
							g_ShowServerSysTips({text = szText.Description_ZH,layout = curScene,y = 232,x = 620})
					    end
					    cclog(nMsgID.." ******RecvMsg error ******** %d %s", nResult, tostring(szText.Description_ZH))
					    
				    else
					    cclog(nMsgID.." ******RecvMsg error ********, %d", nResult)

					    if nResult >= 1000000 then

					    	-- local strError = "=========Server Client Condition error========\n"..
					    	-- rootMsg.client_debug_info..
					    	-- "\n=========Server Client Condition error========\n"

					    	-- SendError(strError)
				    		cclog("=========客户端 服务器 判断不一致=========="..rootMsg.client_debug_info)

				    		local curScene = CCDirector:sharedDirector():getRunningScene()
							
							g_ShowServerSysTips({text = rootMsg.client_debug_info,layout = curScene,y = 232,x = 620})
					    end
				    	
				    end
			    else
				    local szCallBack = self.callBackFunc[nMsgID]
				    if(not szCallBack)then
					    cclog(nMsgID.." ******checkRecvMsg callback is nil ******** ")
				    else
					    szCallBack(rootMsg)

					    if rootMsg.msgid ~= (msgid_pb.MSGID_ROLE_HEARTBEAT_MSG ) then
			   	 			cclog(nMsgID.." ******RecvMsg OVER******** ")
			    		end
			    	end
			    end
		    elseif(bRet > 0)then
			    showErrorDesc(bRet)
			    self.bConnetingNetWork = nil
			    self.bConnectSucc = nil
			    if(bRet == 12 ) then----------------------------------------------建链成功
			    	cclog("---------------------建链成功-----------------")
			    	g_MsgNetWorkWarning:closeNetWorkWarning()

				    self.bConnectSucc = true
                    if self.bConnetcDir then
						cclog("接入平台成功")
                        g_GamePlatformSystem:ConnectPlatform()

                        self.bRequestRole = nil
                        self.bConnetcDir = nil
                    end
                    --
                    g_FormMsgSystem:SendFormMsg(FormMsg_ClientNet_ConnectStack, nil)

                    if self.delayToSendFuc then
                        self.delayToSendFuc()
                        self.delayToSendFuc = nil
                    end

                    g_ClientPing:ResetPintTimes()
			    elseif( bRet == 3)then--------------------------------------------服务端主动关闭
			    	--客户端端线有段时间了 询问用户是否重连
			    	 g_FormMsgSystem:SendFormMsg(FormMsg_ClientNet_CloseTcp, nil)
			    elseif( bRet == 9 or bRet == 2)then-------------------------------客户端主动关闭等


			    elseif( bRet == 10 )then------------------------------------------创建网络失败
				    --则不需要重连了 说明服务端已经关闭
			    elseif( bRet == 11)then--------------------------------------------连接服务器失败
				    --延迟10秒重连
					g_ShowSysWarningTips({text =_T("网络连接中断！重连中...")})
					g_ClientPing:ReClientPing()
			    end
            end
		end

		if(self.nSendMsgTime )then
			local nCurTime = API_GetCurrentTime()
			if(nCurTime - self.nSendMsgTime >= self.nWaitClearTime)then
				g_MsgNetWorkWarning:closeNetWorkWarning()
				self.nSendMsgTime = nil
			elseif(nCurTime - self.nSendMsgTime >= self.nWaitTimeOut )then
				-- g_MsgNetWorkWarning:showWarningText()
			end
		end

		return true
	end
	--CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(checkRecvMsg, 0,  false)
	g_Timer:create(checkRecvMsg)
end

function Class_MsgMgr:setWaitTimeOut(nTime)
	self.nWaitTimeOut = nTime or 0.5
end

function Class_MsgMgr:setWaitClearTime(nTime)
	self.nWaitClearTime = nTime or 4
end

function Class_MsgMgr:destroy()
	g_Timer:destroy()
end

function Class_MsgMgr:registerCallBackFunc(nMsgID, szCallBack)
	if(not szCallBack)then
		cclog("registerCallBackFunc nil "..nMsgID)
		return
	end
	
	if(not nMsgID or type(nMsgID) ~= "number")then
		return
	end

	self.callBackFunc = self.callBackFunc or {}
	self.callBackFunc[nMsgID] =  szCallBack
end

function Class_MsgMgr:setUserID(nUserID)
	if(not nUserID)then
		cclog("Class_MsgMgr:nUserID nil")
	end

   local tbCurServer =g_DataMgr:getSeverInfoCsv(self.nCsvID)
   --self.nUin = tbCurServer.AreaID*1000000 + nUserID
   --CCUserDefault:sharedUserDefault():setIntegerForKey("UserID", nUserID)
   --self.nUin = nUserID
   self:SetGameUID(nUserID)
end

--丹药合成
function Class_MsgMgr:requestMedecineCompose(nMedecineID)
	if(not nMedecineID)then
		cclog("requestMedecineCompose error")
		return
	end

	local msg = zone_pb.UpgradeDanYaoRequest()
	msg.medicine_id = nMedecineID

	self:sendMsg(msgid_pb.MSGID_UPGRADE_DANYAO_REQUEST, msg)
end

--伙伴境界
-- function Class_MsgMgr:requestCardReleam(nCardID, tbCard)
	-- local msg = zone_pb.UpgradeCardRealmRequest()
	-- msg.upgrade_realm_cardid = nCardID
	-- --key 元神服务器id value 元神数量
	-- for key, value in pairs(tbCard) do
		-- table.insert(msg.cost_soul_list, key)
		-- table.insert(msg.cost_soul_num_list,value)
	-- end

	-- self:sendMsg(msgid_pb.MSGID_UPGRADE_CARD_REALM_REQUEST, msg)

	-- g_ErrorMsg:ListenMsg(msgid_pb.MSGID_UPGRADE_CARD_REALM_REQUEST)
-- end

--伙伴境界
function Class_MsgMgr:requestCardEvolute(nBreachID, nCostEquipID, nBossID)
	if(nBreachID)then
		local msg = zone_pb.BreachCardRequest()
		msg.breach_cardid = nBreachID
		if(nCostEquipID)then
			msg.cost_equal_cardid = nCostEquipID
		end

		if(nBossID)then
			msg.cost_boss_cardid = nBossID
		end

		self:sendMsg(msgid_pb.MSGID_BREACH_CARD_REQUEST, msg)

		g_ErrorMsg:ListenMsg(msgid_pb.MSGID_BREACH_CARD_REQUEST)
	end
end

--出售装备请求
function Class_MsgMgr:requestEquipSell(nIDEquip)
	local msg = zone_pb.SellEquipRequest()
	msg.sell_equip_id = nIDEquip

	self:sendMsg(msgid_pb.MSGID_SELL_EQUIP_REQUEST, msg)
end

--伙伴装备装备或更换请求
function Class_MsgMgr:requestDressMedecine(nCardID, nMedecineID, nPos)
	if(not nCardID or not nMedecineID or not nPos)then
		cclog("requestDressMedecine error")
		return
	end

	local msg = zone_pb.InlayDanYaoToCardRequest()
	msg.inlay_cardid = nCardID
	msg.danyao_id = nMedecineID
	msg.inlay_to_idx = nPos - 1

	self:sendMsg(msgid_pb.MSGID_INLAY_DANYAO_TOCARD_REQUEST, msg)
end

--强化装备请求
function Class_MsgMgr:requestEquipStrengthen(nIDEquip)
	if(nIDEquip)then
		local tbEquip = g_Hero:getEquipObjByServID(nIDEquip)
		local nActorLv = g_Hero:getMasterCardLevel()
		if tbEquip.nLevel >= (nActorLv*2 + g_DataMgr:getGlobalCfgCsv("strength_max_add_lev")) then
			g_ClientMsgTips:showMsgConfirm(_T("该装备强化等级已到上限, 需提升主角等级方可继续强化"))
			return
		end
		local msg = zone_pb.StrengthenEquipRequest()
		msg.strengthen_equip_id = nIDEquip

		self:sendMsg(msgid_pb.MSGID_STRENGTHEN_EQUIP_REQUEST, msg)

		g_ErrorMsg:ListenMsg(msgid_pb.MSGID_STRENGTHEN_EQUIP_REQUEST)
	end
end

--一键强化装备请求
function Class_MsgMgr:requestStrengthOneKeyRequest(nIDEquip)
	if(nIDEquip)then
		local tbEquip = g_Hero:getEquipObjByServID(nIDEquip)
		local nActorLv = g_Hero:getMasterCardLevel()
		if tbEquip.nLevel >= (nActorLv*2 + g_DataMgr:getGlobalCfgCsv("strength_max_add_lev")) then
			g_ClientMsgTips:showMsgConfirm(_T("该装备强化等级已到上限, 需提升主角等级方可继续强化"))
			return
		end
		local msg = zone_pb.StrengthOneKeyRequest()
		msg.equip_id = nIDEquip

		self:sendMsg(msgid_pb.MSGID_STRENGTHEN_ONEKEY_REQUEST, msg)
	end
end

--重铸装备请求
function Class_MsgMgr:requestEquipChongZhu(nIDEquip, nChooseIdx)

	if(nIDEquip and nChooseIdx)then
		local msg = zone_pb.RebuildEquipRequest()
		msg.rebuild_equip_id = nIDEquip
		msg.rebuild_index = nChooseIdx

		self:sendMsg(msgid_pb.MSGID_REBUILD_EQUIP_REQUEST, msg)
		
		g_MsgNetWorkWarning:showWarningText()
		
	end
end

--合成装备请求
function Class_MsgMgr:requestEquipHeCheng(nIDEquip, tbEquipHeChengMaterialSelected)
	if(nIDEquip and tbEquipHeChengMaterialSelected)then
		local msg = zone_pb.CompoundEquipRequest()
		msg.compound_equip_id = nIDEquip

		for k, v in pairs(tbEquipHeChengMaterialSelected) do
			table.insert(msg.cost_equip_idlst, k)
		end

		self:sendMsg(msgid_pb.MSGID_COMPOUND_EQUIP_REQUEST, msg)
	end
end

function Class_MsgMgr:requestActivity(actType, sub_idx)
	local msg = zone_pb.ActivityRequest()
	msg.type = actType
	msg.sub_idx = sub_idx or 0
	self:sendMsg(msgid_pb.MSGID_ACTIVITY_REQUEST, msg)
end

function Class_MsgMgr:requestPickPeachInviteHero()
	self:sendMsg(msgid_pb.MSGID_PICK_PEACH_INVITE_HERO_REQUEST)
end

function Class_MsgMgr:requestAssistantRefresh()
	self:sendMsg(msgid_pb.MSGID_ASSISTANT_REFRESH_REQUEST)
end

function Class_MsgMgr:requestAssistantReward()
	self:sendMsg(msgid_pb.MSGID_ASSISTANT_REWARD_REQUEST)
end

--副本过关情况请求
function Class_MsgMgr:requestEctypePassInfo(nMapBaseCsvID)
	-- g_MsgCoverLayer:showWarning()

	if(nMapBaseCsvID)then
		local msg = zone_pb.MapPointInfoRequest()
		msg.big_passid = nMapBaseCsvID
		self:sendMsg(msgid_pb.MSGID_MAP_POINT_INFO_REQUEST, msg)
		cclog("--------------副本过关情况请求--->nMapBaseCsvID="..nMapBaseCsvID)
		g_MsgNetWorkWarning:showWarningText()
		g_ErrorMsg:ListenMsg(msgid_pb.MSGID_MAP_POINT_INFO_REQUEST)
	end
end

-- --世界boss挑战请求
-- function Class_MsgMgr:requestBossInfo()
-- 	local msg = zone_pb.BossInfoRequest()
-- 	msg.type = macro_pb.ActivityType_AMBoss
-- 	self:sendMsg(msgid_pb.MSGID_BOSS_INFO_REQUEST, msg)
-- end

-- 签到
function Class_MsgMgr:requestSignInRefresh()
	self:sendMsg(msgid_pb.MSGID_SIGNIN_REFRESH_REQUEST)
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_SIGNIN_REFRESH_REQUEST)
end

function Class_MsgMgr:requestSignIn()
	self:sendMsg(msgid_pb.MSGID_SIGNIN_REQUEST)
end

function Class_MsgMgr:requestRewardInfo()
	self:sendMsg(msgid_pb.MSGID_REWARD_INFO_REQUEST)
end

function Class_MsgMgr:requestGainReward(reward_id, reward_lv)
	if(reward_id and reward_lv)then
		local msg = zone_pb.GainRewardRequest()
		msg.gain_reward_id = reward_id
		msg.gain_reward_lv = reward_lv

		self:sendMsg(msgid_pb.MSGID_GAIN_REWARD_REQUEST, msg)
	end
end

function Class_MsgMgr:requestSyncServerTime()
	g_SetServerTime(os.time())
	self:sendMsg(msgid_pb.MSGID_SYNCSERVERTIME_REQUEST)
end


function Class_MsgMgr:requestDujie(tbCardID)
	if tbCardID then
		local msg = zone_pb.DujieCardRequest()
		local t = {}
		for i =1,#tbCardID do 
			table.insert(msg.cardid,tbCardID[i].nCardID)
		end
		self:sendMsg(msgid_pb.MSGID_DUJIE_CARD_REQUEST,msg)
		
		g_MsgNetWorkWarning:showWarningText()
		
		-- g_ErrorMsg:ListenMsg(msgid_pb.MSGID_DUJIE_CARD_REQUEST)
	end
end
--------------------------------------------------------------------------------------------------
function Class_MsgMgr:requestRelationGetRoleInfo(uin)
	local msg = zone_pb.RelationGetRoleInfoRequest()
	msg.uin = uin
	self:sendMsg(msgid_pb.MSGID_RELATION_GET_ROLEINFO_REQUEST, msg)
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_RELATION_GET_ROLEINFO_REQUEST)
end

function Class_MsgMgr:requestRelationSetRoleInfo(tb)
	local msg = zone_pb.RelationSetRoleInfoRequest()
	msg.is_man = tb.is_man
	msg.profession = tb.profession
	msg.area = tb.area
	msg.signature = tb.signature
	msg.industry = tb.industry
	self:sendMsg(msgid_pb.MSGID_RELATION_SET_ROLEINFO_REQUEST, msg)
end

function Class_MsgMgr:requestRelationAddFriend(tb)
	local msg = zone_pb.RelationAddFriendRequest()
	if tb.uin then msg.target_uin = tb.uin end
	if tb.target_name then msg.target_name = tb.target_name end
	if tb.msg then msg.msg = tb.msg end
	self:sendMsg(msgid_pb.MSGID_RELATION_ADD_FRIEND_REQUEST, msg)
end

function Class_MsgMgr:requestRelationDealAddFriend(tb)
	local msg = zone_pb.RelationDealAddFriendRequest()
	msg.target_uin = tb.target_uin
	msg.is_accept = tb.is_accept
	self:sendMsg(msgid_pb.MSGID_RELATION_DEAL_ADD_FRIEND_REQUEST, msg)
end

function Class_MsgMgr:requestRelationRmFriend(uin)
	local msg = zone_pb.RelationRmFriendRequest()
	msg.target_uin = uin
	self:sendMsg(msgid_pb.MSGID_RELATION_RM_FRIEND_REQUEST, msg)
end

function Class_MsgMgr:requestRelationGetFriendList()
	self:sendMsg(msgid_pb.MSGID_RELATION_GET_FRIENDLIST_REQUEST)
end

function Class_MsgMgr:requestRelationSendMsg(tb)
	local msg = zone_pb.RelationSendMsgRequest()
	msg.target_uin = tb.target_uin
	msg.msg = tb.msg
	msg.need_detail = tobool(tb.need_detail)
	self:sendMsg(msgid_pb.MSGID_RELATION_SEND_MSG_REQUEST, msg)
end

function Class_MsgMgr:requestRelationGetOfflineMsg()
	self:sendMsg(msgid_pb.MSGID_RELATION_GET_OFFLINE_MSG_REQUEST)
	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_RELATION_GET_OFFLINE_MSG_REQUEST)
end
function Class_MsgMgr:relationCheckNameRequest(target_name)
	local msg = zone_pb.RelationCheckNameRequest()
	msg.name = tostring(target_name)
	self:sendMsg(msgid_pb.MSGID_RELATION_CHECK_NAME_REQUEST,msg)
end


function Class_MsgMgr:requestChangeFate(nOperator, nCardID, index, nFateID)
	if(nOperator and index and nFateID)then
		local msg = zone_pb.OperatorFateFromCardRequest()
		msg.operator_type = nOperator
		msg.cardid = nCardID
		msg.fate_id = nFateID
		msg.fate_index = index - 1

		self:sendMsg(msgid_pb.MSGID_OPERATOR_FATE_FROMCARD_REQUEST, msg)
	end
end

function Class_MsgMgr:requestUpgardeFate(nFateID, tbFateInfo)
	if(nFateID and tbFateInfo)then
		local msg = zone_pb.UpgradeFateRequest()
		msg.upgrade_fate_id = nFateID
		for key, value in pairs(tbFateInfo) do
			table.insert(msg.cost_fate_idlst, value)
		end

		self:sendMsg(msgid_pb.MSGID_UPGRADE_FATE_REQUEST, msg)
	end
end

function Class_MsgMgr:requestRelationGetNearByList()
	self:sendMsg(msgid_pb.MSGID_RELATION_GET_NEARBY_LIST_REQUEST)
end

-- function Class_MsgMgr:registerErrorCallBackFunc(func)
	-- self.funcNetError = func
-- end

-- function Class_MsgMgr:requestFarmRefresh()
	-- self:sendMsg(msgid_pb.MSGID_FARM_REFRESH_REQUEST)
-- end

function Class_MsgMgr:requestShopRecharge(id)
	local msg = zone_pb.ShopRechargeRequest()
	msg.id = id
	self:sendMsg(msgid_pb.MSGID_SHOP_RECHARGE_REQUEST, msg)
end

function Class_MsgMgr:requestBagSell(itemType, configId, lv, serverId, nNum)
	local msg = zone_pb.ShopSellRequest()
	msg.type = itemType
	msg.config_id = configId
	msg.lv = lv
	msg.server_id = serverId
	msg.num = nNum
	self:sendMsg(msgid_pb.MSGID_BAG_SELL_REQUEST, msg)
end
----------------竞技场--------------------------------------------------------------------
function Class_MsgMgr:requestArenaInfo() --竞技场请求
    g_MsgNetWorkWarning:showWarningText(true)
	self:sendMsg(msgid_pb.MSGID_ARENAINFO_REQUEST)
end

function Class_MsgMgr:requestArenaChallenge(challen_rank) --竞技场挑战请求
    g_MsgNetWorkWarning:showWarningText(true)
	local msg = zone_pb.ArenaChallengeRequest()
	msg.challen_rank  = challen_rank
	self:sendMsg(msgid_pb.MSGID_ARENA_CHALLENGE_REQUEST,msg)
end

function Class_MsgMgr:requestArenaRankListRequest(start_rank ,end_rank)
    g_MsgNetWorkWarning:showWarningText(true)
	local msg = zone_pb.ArenaRankListRequest()
	msg.start_rank = start_rank or 1
	msg.end_rank = end_rank or 20
	cclog(msg.start_rank.."====ArenaRankListRequest===="..msg.end_rank )
	self:sendMsg(msgid_pb.MSGID_ARENA_RANKLIST_REQUEST,msg)
end

function Class_MsgMgr:requestBuyChallengeTimes(times)  ---竞技场挑战次数购买请求
	local msg = zone_pb.BuyChallengeTimesRequest()
	--msg.buy_times = times
	self:sendMsg(msgid_pb.MSGID_BUY_CHALLENGE_TIMES_REQUEST)
end

function Class_MsgMgr:requestExchangeUsePrestige(goodsID)  --用声望兑换物品请求
	local msg = zone_pb.BuyShopItemRequest()
	msg.shop_goods_id = goodsID
	self:sendMsg(msgid_pb.MSGID_BUY_SHOP_ITEM_REQUEST,msg)
end
function Class_MsgMgr:requestUpgardeOfficialRank() --用声望升级官阶请求
	self:sendMsg(msgid_pb.MSGID_UPGRADE_OFFICIAL_RANK_REQUEST)
end

function Class_MsgMgr:requestGainPrestige() --用声望升级官阶请求
	self:sendMsg(msgid_pb.MSGID_GAIN_PRESTIGE_REQUEST)
end

function Class_MsgMgr:requestBuyEnergy(nEnergy) --购买体力请求
	local msg = zone_pb.BuyEnergyRequest()
	msg.buy_energy_num = nEnergy
	self:sendMsg(msgid_pb.MSGID_BUY_ENERGY_REQUEST, msg)
end

function Class_MsgMgr:requestViewPlayer(uin)
	if uin==self:getUin() then return end
	local msg = zone_pb.ViewPlayerRequest()
	msg.uin = uin
	self:sendMsg(msgid_pb.MSGID_VIEW_PLAYER_REQUEST, msg)
end

function Class_MsgMgr:requestViewPlayerDetail(uin)
	if uin==self:getUin() then return end
	local msg = zone_pb.ViewPlayerDetailRequest()
	msg.uin = uin
	self:sendMsg(msgid_pb.MSGID_VIEW_PLAYER_DETAIL_REQUEST, msg)
end

function Class_MsgMgr:requestViewPlayerPk(uin)
	if uin==self:getUin() then return end
	local msg = zone_pb.ViewPlayerPkRequest()
	msg.target_uin = uin
	g_MsgNetWorkWarning:showWarningText()
	self:sendMsg(msgid_pb.MSGID_VIEW_PLAYER_PK_REQUEST, msg)
end

function Class_MsgMgr:requestViewPlayerPk_KuaFu(uin)
	if uin==self:getUin() then return end
	local msg = zone_pb.CrossViewPlayerPkReq()
	msg.target_uin = uin
	g_MsgNetWorkWarning:showWarningText()
	self:sendMsg(msgid_pb.MSGID_CROSS_VIEW_PLAYER_PK_REQ, msg)
end

-- function Class_MsgMgr:requestBuyExtraSpace(t)
	-- local msg = zone_pb.BuyExtraSpaceRequest()
	-- msg.type = t
	-- self:sendMsg(msgid_pb.MSGID_BUY_EXTRA_SPACE_REQUEST, msg)
-- end

function Class_MsgMgr:requestHandbookrec()  --图鉴
	self:sendMsg(msgid_pb.MSGID_HANDBOOKREC_REQUEST)
end

function Class_MsgMgr:requestAccountReg(name, passwd)
	local msg = account_pb.AccountRegRequest()
	msg.name = name
	msg.password = passwd
	self:sendMsg(msgid_pb.MSGID_ACCOUNT_REG_REQUEST, msg)
end

function Class_MsgMgr:requestAccountLogin(name, passwd)
	local msg = account_pb.AccountLoginRequest()
	msg.name = name
	msg.password = passwd
	self:sendMsg(msgid_pb.MSGID_ACCOUNT_LOGIN_REQUEST, msg)
end

--新手引导
function Class_MsgMgr:requestNewPlayerGuide(nGuideID, index)
	local msg = zone_pb.UpdateNewBieGuideRequest()
	msg.guide_id = nGuideID
    msg.guide_no = index
	self:sendMsg(msgid_pb.MSGID_UPDATE_NEWBIE_GUIDE_REQUEST, msg)

	-- g_ErrorMsg:ListenMsg(msgid_pb.MSGID_UPDATE_NEWBIE_GUIDE_REQUEST)
end

-- 升级技能
-- function Class_MsgMgr:requestUpgardeSkill(nCardID, index)
	-- local msg = zone_pb.UpgradeSkillRequest()
	-- msg.skill_index = index
    -- msg.upgrade_cardid = nCardID
	-- self:sendMsg(msgid_pb.MSGID_UPGRADE_SKILL_REQUEST, msg)
-- end

--[[
类型，标题，内容
t = {
	macro_pb.IT_BUG 		-- bug
	macro_pb.IT_COMPLAIN 	-- 投诉
	macro_pb.IT_SUGGEST		-- 建议
	macro_pb.IT_OTHER		-- 其他
}
]]
function Class_MsgMgr:requestReportIssue(t, title, content)
	local msg = zone_pb.ReportIssueRequest()
	msg.type = t
	msg.title = title
	msg.content = content
	self:sendMsg(msgid_pb.MSGID_REPORT_ISSUE_REQUEST, msg)
end

function Class_MsgMgr:requestAchievementRefresh()
	self:sendMsg(msgid_pb.MSGID_ACHIEVEMENT_REFRESH_REQUEST)
end

function Class_MsgMgr:requestAchievementGetReward(t, id)
	local msg = zone_pb.AchievementGetRewardRequest()
	msg.type = t
	msg.id = id
	self:sendMsg(msgid_pb.MSGID_ACHIEVEMENT_GET_REWARD_REQUEST, msg)
end


-- function Class_MsgMgr:useSkill(nType, nPos)
	-- local msg = zone_pb.BattleSkillRequest()
	-- msg.skill_no = nType
	-- msg.card_pos = nPos
	-- self:sendMsg(msgid_pb.MSGID_BATTLE_SKILL_REQUEST, msg)
-- end

function Class_MsgMgr:sendBattleRequest(tbResult)
	local msg = zone_pb.BattleResultRequest()
	msg.iswin = tbResult.iswin
	msg.battletype = tbResult.battletype
	msg.sub_ectype_id = tbResult.mapid
	msg.damage = tbResult.damage
	msg.star_num = tbResult.star_num

	cclog("Class_MsgMgr:sendBattleRequest "..tostring(msg))

	self:sendMsg(msgid_pb.MSGID_BATTLE_RESULT_REQUEST, msg)

	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_BATTLE_RESULT_REQUEST, msg)
	g_MsgNetWorkWarning:showWarningText()

end
--合成装备请求
-- function Class_MsgMgr:sendComposeEquipRequest(nEquipID,bFlag)
	-- local msg = zone_pb.ComposeEquipRequest()
	-- msg.equip_id = nEquipID
	-- msg.use_coupons = bFlag
	-- self:sendMsg(msgid_pb.MSGID_COMPOSE_EQUIP_REQUEST, msg)

	-- g_ErrorMsg:ListenMsg(msgid_pb.MSGID_COMPOSE_EQUIP_REQUEST)
-- end

function Class_MsgMgr:requestArrayHeartUpgradeRequest(arrayidx, heartidx)
	local msg = zone_pb.ArrayHeartUpgradeRequest()
	msg.arrayidx = arrayidx
    msg.heartidx = heartidx
	self:sendMsg(msgid_pb.MSGID_ARRAY_HEART_UPGRADE_REQUEST, msg)
end

--聊天频道
function Class_MsgMgr:requestChatRequest(tb_msg)
	cclog("========requestChatRequest=======")
	local rootMsg = zone_pb.ChatRequest()
	rootMsg.recv_uin = tb_msg.uin
	rootMsg.channel = tb_msg.channel
	rootMsg.title = tb_msg.title
	rootMsg.content = tb_msg.content

	self:sendMsg(msgid_pb.MSGID_CHAT_REQUEST, rootMsg)
end

--第一次打开世界频道
function Class_MsgMgr:requestFirstChatRequest()
	if not self.isFirstChat then
		self.isFirstChat = true
		cclog("========requestChatRequest=======")
		self:sendMsg(msgid_pb.MSGID_FIRST_OPEN_REQUEST)
		g_ChatCenter.Chat_Channel_World = {}
		g_ChatCenter.Chat_Channel_Notice = {}
	end 
end

function Class_MsgMgr:requestUseItemRequest(tb_msg)
	cclog("========requestUseItemRequest=======")
	local rootMsg = zone_pb.UseItemRequest()
	rootMsg.item_id = tb_msg.item_id
	local itemInfo = zone_pb.UseItemInfo()

	itemInfo.use_num = tb_msg.use_item_info.use_num
	if tb_msg.use_item_info.object_id then
		itemInfo.object_id = tb_msg.use_item_info.object_id
	end
	table.insert(rootMsg.use_item_info,itemInfo)
	self:sendMsg(msgid_pb.MSGID_USE_ITEM_REQUEST,rootMsg)

end

function Class_MsgMgr:requestUCLogin(szSid)
	self.szSessionKey = szSid
	local rootMsg = xxz_msg_pb.xxz_Msg()
	rootMsg.msgid = msgid_pb.MSGID_ACCOUNT_AUTH_REQUEST

	rootMsg.uin = self.nUin
	rootMsg.session_key = szSid
	rootMsg.platform = macro_pb.LOGIN_PLATFORM_UC
	rootMsg.session_token = self.session_token

	local szMsgData = rootMsg:SerializeToString()

	API_SendMessage(string.len(szMsgData), szMsgData)
	self.nSendMsgTime = nCurTime
end

--发送爱心
function Class_MsgMgr:SendHeartRequest(tb_uin)
	cclog("========SendHeartRequest=======")
	local rootMsg = zone_pb.SendHeartRequest()
	for i,v in ipairs(tb_uin)do
		table.insert(rootMsg.recv_uin,v)
	end
	self:sendMsg(msgid_pb.MSGID_SENDHEART_REQUEST,rootMsg)
end
-- 收取爱心
function Class_MsgMgr:RecvHeartRequest(tb_uin)
	cclog("========RecvHeartRequest=======")
	local rootMsg = zone_pb.RecvHeartRequest()
	for i,v in ipairs(tb_uin)do
		table.insert(rootMsg.recv_uin,v)
	end
	self:sendMsg(msgid_pb.MSGID_RECVHEART_REQUEST,rootMsg)
end

-- 邮件
function Class_MsgMgr:MailBoxInfoRequest()---已废除
	cclog("========MailBoxInfoRequest=======")
	self:sendMsg(msgid_pb.MSGID_MAILBOX_INFO_REQUEST)
end
function Class_MsgMgr:MailRewardRequest(mail_id)
	cclog("========MailRewardRequest====id==="..mail_id)
	local rootMsg = zone_pb.MailRewardRequest()
	rootMsg.mail_id = tonumber(mail_id) or 0
	self:sendMsg(msgid_pb.MSGID_MAIL_REWARD_REQUEST,rootMsg)
end
-- 邮件
function Class_MsgMgr:MailReadRequest(mail_id)
	local rootMsg = zone_pb.MailReadRequest()
	rootMsg.mail_id = tonumber(mail_id) or 0
	self:sendMsg(msgid_pb.MSGID_MAIL_READ_REQUEST,rootMsg)
end

-- 升星
function Class_MsgMgr:UpgradeStarRequest(card_id, costType)
	local rootMsg = zone_pb.UpgradeStarRequest()
	rootMsg.card_id = tonumber(card_id)
	rootMsg.cost_type = costType
		-- optional uint32 card_id = 1;		// 卡牌id
	-- optional uint32 cost_type = 2;	        // 优先消耗(1:魂魄 2:万能魂石)
	self:sendMsg(msgid_pb.MSGID_UPGRADE_CARDSTAR_REQUEST, rootMsg)
end


--[[
	一键升级技能请求 
]]
function Class_MsgMgr:OnceUpgradeSkillRequest(skillIndex,upgradeCardID)
	cclog("========OnceUpgradeSkillRequest=======")
	local rootMsg = zone_pb.OnceUpgradeSkillRequest()
	
	rootMsg.skill_index = skillIndex-1		-- 技能索引
	rootMsg.upgrade_cardid = upgradeCardID	-- 升级的卡牌id
	self:sendMsg(msgid_pb.MSGID_ONCE_LVUP_SKILL_REQUEST,rootMsg)

	g_ErrorMsg:ListenMsg(msgid_pb.MSGID_ONCE_LVUP_SKILL_REQUEST)
end

--材料副本信息请求
function Class_MsgMgr:requestMaterialEctypeRequest(materialId,starLv,itemType)
	cclog("材料副本信息请求")
	local msg = zone_pb.MaterialEctypeRequest() 
	msg.material_id = materialId;		--材料id
	msg.material_star = starLv;		--材料星级
	msg.item_type = itemType; --物品类型 只有三种 5 魂魄 6 道具 7 元神
	g_MsgMgr:sendMsg(msgid_pb.MSGID_MATERIAL_ECTYPE_REQUEST,msg)
end	

--物品合成请求
function Class_MsgMgr:requestComPoseItemRequest(materialId,starLv)
	cclog("物品合成请求")
	local msg = zone_pb.ComPoseItemRequest() 
	msg.target_cfg_id = materialId --目标id
	msg.target_starlv = starLv --目标星级
	g_MsgMgr:sendMsg(msgid_pb.MSGID_COMPOSE_ITEM_REQUEST,msg)
end	

--------------------------------------------------初始化全局的对象
g_MsgMgr = Class_MsgMgr.new()
g_Hero:Init()