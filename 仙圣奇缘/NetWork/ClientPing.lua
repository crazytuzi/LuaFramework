-- 文件名:	ClientPing.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	客户端ping服务器 send的是偶 tick ＋1  recv的时候 tick －1
-- 应  用:  本例子是用类对象的方式实现

ClientPing = class("ClientPing")
ClientPing.__index = ClientPing

function ClientPing:ctor()
	self.iTick = 0

	--
	self.iPingTime = os.time()

	--时间间隔
	self.iConstTimeTick = 5
	self.m_bStart = false

	--
	self.iMaxPingTime = 3
	self.iCurPing	= 1

	self.bListenRecoun = false
end
-----------------------------------------外部接口----------------------------
function ClientPing:StartPing()
	self.m_bStart = true
	self.iTick = 0
	self.iPingTime = os.time()
end

function ClientPing:StopPing()
	self.m_bStart = false
	self.iTick = 0
end

function ClientPing:ReListen()
	self.bListenRecoun = true
end

function ClientPing:ReClientPing()
	if self.iCurPing <= self.iMaxPingTime then --自动连接self.iMaxPingTime 次
		g_MsgMgr.bConnetingNetWork = true
		API_ReConnect()
		g_MsgNetWorkWarning:showWarningText()
		--状态记录
		self.m_bStart = false

		self.iCurPing = self.iCurPing + 1

		g_ServerList:SetClientConnectState()
	else
		g_MsgNetWorkWarning:closeNetWorkWarning()

		g_MsgNetWorkWarning:setActivation(false)

		self.iCurPing = 0
		local function onClickConfirm()
			API_ReConnect()
		end--直接返回登陆界面

		local function onClickCancel()
			--取消的时候在后台直接发送心跳包
			g_MsgNetWorkWarning:setActivation(true)
			self:StartPing()
		end

		g_ClientMsgTips:showConfirm(_T("与服务器连接中断，点击确认重新连接。"), onClickConfirm, onClickCancel)
	end
end

--连接成功的时候 重置 连接次数
function ClientPing:ResetPintTimes()
	self.iCurPing = 1
end

-------------------------------------
function ClientPing:Init()
	--注册定时器 跑ping消息
	-- g_Timer:pushLoopTimer(5, function()
	--  self:SendPing() 
	--  end)

	g_Timer:pushLoopTimer(self.iConstTimeTick, handler(self, self.SendPing))

	--注册服务器ping响应
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ROLE_HEARTBEAT_MSG, handler(self, self.RespondPing))
end

function ClientPing:GetTick()
	return self.iTick
end

function ClientPing:RespondPing(tbMsg)
	if self.m_bStart then
		self.iTick = 1
	end

	if self.bListenRecoun then
		cclog("断线重连 检测丢失的消息")
		--处理异常消息
		g_ErrorMsg:SendErrorMsg()
		self.bListenRecoun = false
	end

	g_MsgNetWorkWarning:setActivation(true)
end

function ClientPing:WaitOneTime()
	if self.m_bStart == false then
		g_GamePlatformSystem:OnClickGameLoginOut()
	end
end

function ClientPing:SendPing()
	if self.m_bStart then
		self.iTick = self.iTick + 1
		--发送ping
		
		local msg = zone_pb.RoleHeartBeatMsg() 
		g_MsgMgr:sendMsg(msgid_pb.MSGID_ROLE_HEARTBEAT_MSG,msg)

		--检测有几个据包数
		self:bReconnect()
		
	end
end

function ClientPing:bReconnect()
	if self.m_bStart and (self:GetTick() > 4) then
		--依照以前的逻辑
		--g_MsgMgr.bConnectSucc = nil
		g_MsgMgr.bConnetingNetWork = true
		API_ReConnect()
		g_MsgNetWorkWarning:showWarningText(true)

		--状态记录
		self.m_bStart = false

		g_ServerList:SetClientConnectState()
		cclog("clientping--------->times ="..self:GetTick())
	end
end

-----定义全局ping
g_ClientPing = ClientPing.new()

function CreateClientPing()
	g_ClientPing:ctor()
	g_ClientPing:Init()
end

