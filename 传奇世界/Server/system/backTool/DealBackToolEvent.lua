--DealBackToolEvent.lua
--/*-----------------------------------------------------------------
 --* Module:  DealBackToolEvent.lua
 --* Author:  seezon
 --* Modified: 2014年8月14日
 --* Purpose: 处理后台工具事件
 -------------------------------------------------------------------*/
require ("system.backTool.DealLoopMsg")
require ("system.backTool.WindowPop")
	
DealBackToolEvent = class(nil, Singleton, Timer)

BACKTOOL_EMAIL1 = 4143	--群发邮件
BACKTOOL_EMAIL2 = 4109	--邮件赠送绑定元宝
BACKTOOL_EMAIL3 = 4111	--邮件赠送金币
BACKTOOL_EMAIL4 = 4113	--邮件赠送物品
BACKTOOL_DELE_EMAIL = 4183	--删除邮件
BACKTOOL_LOOPMSG = 4137	--走马灯
BACKTOOL_WINPOP = 4139	--系统弹窗
BACKTOOL_PERSON_WINPOP = 4225	--个人弹窗
BACKTOOL_DELE_EVENT = 4145	--删除弹窗，跑马灯，全局邮件
BACKTOOL_DELE_CHAT = 4221	--删除某个人的聊天信息
BACKTOOL_GM = 4233	--执行GM命令

function DealBackToolEvent:__init()
	g_listHandler:addListener(self)
	gTimerMgr:regTimer(self, 1000, 60000)
	print("DealBackToolEvent Timer", self._timerID_)
end

function DealBackToolEvent:onDataPacket(cmdId, content)
	if cmdId == BACKTOOL_EMAIL1 then
		self:sendGlobal(content)
	elseif cmdId == BACKTOOL_EMAIL2 then
		self:sendBindIngot(content)
	elseif cmdId == BACKTOOL_EMAIL3 then	
		self:sendMoney(content)
	elseif cmdId == BACKTOOL_EMAIL4 then
		self:sendItem(content)	
	elseif cmdId == BACKTOOL_EMAIL4 then
		self:sendItem(content)	
	elseif cmdId == BACKTOOL_DELE_EMAIL then
		self:deleteEmail(content)	
	elseif cmdId == BACKTOOL_DELE_EVENT then
		self:deleteEvent(content)	
	elseif cmdId == BACKTOOL_DELE_CHAT then
		self:deleteChat(content)	
	elseif cmdId == BACKTOOL_PERSON_WINPOP then
		self:sendMsgEmail(content)	
	elseif cmdId == BACKTOOL_GM then
		self:doGM(content)	
	end
end

function DealBackToolEvent:doGM(contentTb)
	local command = {}
	command.playerId = contentTb.RoleId
	command.cmdTxt = contentTb.GMInstruct.." "..contentTb.GMParam
	ShellSystem.getInstance():shellCmd(serialize(command))
end

function DealBackToolEvent:sendMsgEmail(contentTb)
	local offlineMgr = g_entityMgr:getOfflineMgr()
	local email = offlineMgr:createEamil()
	email:setDesc(contentTb.Message)
	offlineMgr:recvEamil(contentTb.RoleId, email, 0, 0) 
end

function DealBackToolEvent:sendBindIngot(contentTb)
	local offlineMgr = g_entityMgr:getOfflineMgr()
	local email = offlineMgr:createEamil()
	email:setTitle(contentTb.MailTitle)
	email:setDesc(contentTb.MailContent)
	email:insertProto(888888, tonumber(contentTb.GoldNum), true)
	offlineMgr:recvEamil(contentTb.RoleId, email, 60, 0) 
end

function DealBackToolEvent:sendMoney(contentTb)
	local offlineMgr = g_entityMgr:getOfflineMgr()
	local email = offlineMgr:createEamil()
	email:setTitle(contentTb.MailTitle)
	email:setDesc(contentTb.MailContent)
	email:insertProto(999998, tonumber(contentTb.GoldNum), true)
	offlineMgr:recvEamil(contentTb.RoleId, email, 60, 0) 
end

function DealBackToolEvent:sendItem(contentTb)
	local offlineMgr = g_entityMgr:getOfflineMgr()
	local email = offlineMgr:createEamil()
	email:setTitle(contentTb.MailTitle)
	email:setDesc(contentTb.MailContent)
	email:insertLink(contentTb.Hyperlink, contentTb.HyperlinkText)
	email:insertProto(tonumber(contentTb.ItemId), tonumber(contentTb.ItemNum), true)
	offlineMgr:recvEamil(contentTb.RoleId, email, 60, 0) 
end

function DealBackToolEvent:TestEmail(sid)
	local offlineMgr = g_entityMgr:getOfflineMgr()
	local email = offlineMgr:createEamil()
	email:setTitle("222222222")
	email:setDesc("333333333333")
	email:insertProto(1100, 2, true)
	offlineMgr:recvEamil(sid, email, 60, 0) 
end

function DealBackToolEvent:sendGlobal(contentTb)
	contentTb.SendTime = math.floor(contentTb.SendTime)
	print("发送全局邮件", toString(contentTb))
	if contentTb.SendTime == 0 or contentTb.SendTime < os.time() then
		contentTb.SendTime = os.time()
	end

	if not contentTb.MinLevel then
		contentTb.MinLevel = 1
	end

	if not contentTb.MaxLevel or contentTb.MaxLevel == 0 then
		contentTb.MaxLevel = 200
	end

	if not contentTb.Type then
		contentTb.Type = 0
	end

	local offlineMgr = g_entityMgr:getOfflineMgr()
	local email = offlineMgr:createEamil()
	for i=1, contentTb.ItemList_count do
		local data = contentTb.ItemList[i]
		email:insertProto(tonumber(data.ItemId), tonumber(data.ItemNum), true)
	end
	email:setTitle(contentTb.MailTitle)
	email:setDesc(contentTb.MailContent)
	email:insertLink(contentTb.Hyperlink, contentTb.ButtonContent)
	local endTime = os.time() + 31104000	--一年时间过期
	offlineMgr:addGlobalEmail(contentTb.EventId, contentTb.SendTime, endTime, contentTb.MinLevel, contentTb.MaxLevel, contentTb.Type, email)
end

function DealBackToolEvent:deleteEmail(contentTb)
	local offlineMgr = g_entityMgr:getOfflineMgr()
	offlineMgr:deleteEamil(contentTb.RoleId, contentTb.MailId) 
end

function DealBackToolEvent:deleteGlobalEmail(contentTb)
	local offlineMgr = g_entityMgr:getOfflineMgr()
	offlineMgr:deleteGlobalEmail(contentTb.MailId) 
end

function DealBackToolEvent:deleteEvent(contentTb)
	if contentTb.Type == 1 then
		g_dealLoopMsg:deleMsg(contentTb.EventId)
	elseif contentTb.Type == 2 then
		g_windowPop:deleMsg(contentTb.EventId)
	elseif contentTb.Type == 3 then
		local offlineMgr = g_entityMgr:getOfflineMgr()
		offlineMgr:deleteGlobalEmail(contentTb.EventId) 
	end
end

function DealBackToolEvent:deleteChat(contentTb)
	g_ChatSystem:clearMsgBySID(contentTb.RoleId)
end


function DealBackToolEvent:update()
	local offlineMgr = g_entityMgr:getOfflineMgr()
	offlineMgr:checkGlobalEmail()
end

function DealBackToolEvent.getInstance()
	return DealBackToolEvent()
end

g_dealBackToolEvent = DealBackToolEvent.getInstance()