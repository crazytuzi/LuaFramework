HuaShanZhiDianDlg = {}

setmetatable(HuaShanZhiDianDlg, Dialog);
HuaShanZhiDianDlg.__index = HuaShanZhiDianDlg;

local _instance;

function HuaShanZhiDianDlg.getInstance()
	if _instance == nil then
		_instance = HuaShanZhiDianDlg:new();
		_instance:OnCreate();
	end

	return _instance;
end

function HuaShanZhiDianDlg.getInstanceNotCreate()
	return _instance;
end

function HuaShanZhiDianDlg.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		print("HuaShanZhiDianDlg DestroyDialog")
	end
end

function HuaShanZhiDianDlg.getInstanceAndShow()
    if not _instance then
        _instance = HuaShanZhiDianDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function HuaShanZhiDianDlg.ToggleOpenClose()
	if not _instance then 
		_instance = HuaShanZhiDianDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function HuaShanZhiDianDlg.GetLayoutFileName()
	return "huashanzhidianmain.layout";
end

function HuaShanZhiDianDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, HuaShanZhiDianDlg);

	return zf;
end

------------------------------------------------------------------------------

function HuaShanZhiDianDlg:OnCreate()
	print("HuaShanZhiDianDlg OnCreate")
	Dialog.OnCreate(self);

	self.m_girlMsgId = {145960, 145961, 145962}
	self.m_girlMsgNum = table.maxn(self.m_girlMsgId)
	self.m_girlMsg = {}
	self.m_girlMsg[1] = MHSD_UTILS.get_msgtipstring(self.m_girlMsgId[1])
	self.m_girlMsg[2] = MHSD_UTILS.get_msgtipstring(self.m_girlMsgId[2])
	self.m_girlMsg[3] = MHSD_UTILS.get_msgtipstring(self.m_girlMsgId[3])

	local winMgr = CEGUI.WindowManager:getSingleton();

	-- girl
	self.m_girl = winMgr:getWindow("huashanzhidianmain/girl");
	self.m_talk = winMgr:getWindow("huashanzhidianmain/talk/txt")
	self.m_girl:subscribeEvent("MouseClick", HuaShanZhiDianDlg.HandleGirlClicked, self);

	-- food
	self.m_foodBtn = {}
	for i=1, 5 do
		self.m_foodBtn[i] = winMgr:getWindow("huashanzhidianmain/img"..tostring(i-1))
		self.m_foodBtn[i]:subscribeEvent("MouseClick", HuaShanZhiDianDlg["HandleFoodClicked"..tostring(i)], self)
	end

	-- msg
	self.m_zhanBaoBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("huashanzhidianmain/bot/chanel0"))
	self.m_chatBtn = CEGUI.Window.toGroupButton(winMgr:getWindow("huashanzhidianmain/bot/chanel1"))
	self.m_inputArea = winMgr:getWindow("huashanzhidianmain/bot/chat")
	self.m_inputEdit = CEGUI.toRichEditbox(winMgr:getWindow("huashanzhidianmain/bot/chat/box"))
	self.m_fasongBtn = winMgr:getWindow("huashanzhidianmain/bot/fasong")
	self.m_msgEditBox = CEGUI.toRichEditbox(winMgr:getWindow("huashanzhidianmain/bot/main/chat"))

	self.m_zhanBaoBtn:subscribeEvent("MouseClick", HuaShanZhiDianDlg.showZhanbao, self)
	self.m_chatBtn:subscribeEvent("MouseClick", HuaShanZhiDianDlg.showChat, self)
	self.m_fasongBtn:subscribeEvent("MouseClick", HuaShanZhiDianDlg.HandleFasongClicked, self)


	-- left buttons
	self.m_gradeBtn = {}
	self.m_gradeBtn[1] = winMgr:getWindow("huashanzhidianmain/left/load/huashan")
	self.m_gradeBtn[2] = winMgr:getWindow("huashanzhidianmain/left/load/nor")
	self.m_gradeBtn[3] = winMgr:getWindow("huashanzhidianmain/left/load/nor1")
	self.m_gradeBtn[4] = winMgr:getWindow("huashanzhidianmain/left/load/nor2")
	self.m_gradeBtn[5] = winMgr:getWindow("huashanzhidianmain/left/load/nor3")
	self.m_gradeBtn[6] = winMgr:getWindow("huashanzhidianmain/left/load/nor4")

	self.m_gradeBtn[1]:subscribeEvent("MouseClick", HuaShanZhiDianDlg.HandleShowGrade1, self)
	self.m_gradeBtn[2]:subscribeEvent("MouseClick", HuaShanZhiDianDlg.HandleShowGrade2, self)
	self.m_gradeBtn[3]:subscribeEvent("MouseClick", HuaShanZhiDianDlg.HandleShowGrade3, self)
	self.m_gradeBtn[4]:subscribeEvent("MouseClick", HuaShanZhiDianDlg.HandleShowGrade4, self)
	self.m_gradeBtn[5]:subscribeEvent("MouseClick", HuaShanZhiDianDlg.HandleShowGrade5, self)
	self.m_gradeBtn[6]:subscribeEvent("MouseClick", HuaShanZhiDianDlg.HandleShowGrade6, self)

	-- init state

	self.m_lastMsgIndex = 1
	self.m_changeMsgCD = 0
	self.m_worldMsgList = {}
	self.m_worldMsgList.beginIndex = 1
	self.m_worldMsgList.endIndex = 0
	self.m_zhanbaoList = {}
	self.m_zhanbaoList.beginIndex = 1
	self.m_zhanbaoList.endIndex = 0
	self.m_showingMsgNum = 0

	self.m_talk:setText(self.m_girlMsg[1])

	self.m_zhanBaoBtn:setSelected(true)
	self:showZhanbao() 

	print("HuaShanZhiDianDlg OnCreate finish")
end

function HuaShanZhiDianDlg:HandleShowGrade( grade )
	local p = require "protocoldef.knight.gsp.cross.cquerygradeteams" : new()
    p.grade = grade
    require "manager.luaprotocolmanager":send(p)
end

function HuaShanZhiDianDlg:HandleShowGrade1()
	self:HandleShowGrade(1)
end

function HuaShanZhiDianDlg:HandleShowGrade2()
	self:HandleShowGrade(2)
end

function HuaShanZhiDianDlg:HandleShowGrade3()
	self:HandleShowGrade(3)
end

function HuaShanZhiDianDlg:HandleShowGrade4()
	self:HandleShowGrade(4)
end

function HuaShanZhiDianDlg:HandleShowGrade5()
	self:HandleShowGrade(5)
end

function HuaShanZhiDianDlg:HandleShowGrade6()
	self:HandleShowGrade(6)
end

function HuaShanZhiDianDlg:HandleFasongClicked()
	local config = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.chuashanglobal"):getRecorder(1)

	local sb = StringBuilder.new()
	sb:Set("parameter1", config.laba)
	local finStr = sb:GetString(MHSD_UTILS.get_msgtipstring(145967))
	GetMessageManager():AddConfirmBox(eConfirmNormal, finStr,
		HuaShanZhiDianDlg.HandleSendMsg, self, CMessageManager.HandleDefaultCancelEvent, CMessageManager)
end

function HuaShanZhiDianDlg:HandleSendMsg()
	GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
	local txt = self.m_inputEdit:GetPureText()
	print("SendMsg "..txt)
	
	local p = require "protocoldef.knight.gsp.cross.csendallservermsg" : new()
    p.worldmsg = txt
    p.flag = 1
    require "manager.luaprotocolmanager":send(p)

	self.m_inputEdit:Clear()
end

function HuaShanZhiDianDlg:PushWorldMsg( role, server, serverId, msg )
	local str = MHSD_UTILS.get_msgtipstring(145965)
	local sb = StringBuilder.new()
	sb:Set("parameter1", role)
	sb:Set("parameter2", server)
	sb:Set("parameter3", msg)
	local finStr = CEGUI.String(sb:GetString(str))
	self.m_msgEditBox:AppendParseText(finStr, false)
	self.m_msgEditBox:AppendBreak()
	self.m_msgEditBox:Refresh()
	self.m_msgEditBox:HandleEnd()
	
	self.m_worldMsgList.endIndex = self.m_worldMsgList.endIndex + 1
	self.m_worldMsgList[self.m_worldMsgList.endIndex] = finStr
	if self.m_worldMsgList.endIndex - self.m_worldMsgList.beginIndex >= 50 then --保存50条消息
		self.m_worldMsgList[self.m_worldMsgList.beginIndex] = nil
		self.m_worldMsgList.beginIndex = self.m_worldMsgList.beginIndex + 1
	end

	self.m_showingMsgNum = self.m_showingMsgNum + 1
	if self.m_showingMsgNum > 60 then --最多显示60条消息
		self:showChat()
	end

	print("HuaShanZhiDianDlg PushWorldMsg "..sb:GetString(str))
end

function HuaShanZhiDianDlg:PushZhanBao( msgid, param )
	local str = MHSD_UTILS.get_msgtipstring(msgid)
	local sb = StringBuilder.new()
	for i,v in ipairs(param) do
		sb:Set("parameter"..tostring(i), v)
	end
	local finStr = CEGUI.String(sb:GetString(str))

	self.m_msgEditBox:AppendParseText(finStr, false)
	self.m_msgEditBox:AppendBreak()
	self.m_msgEditBox:Refresh()
	self.m_msgEditBox:HandleEnd()
	
	self.m_zhanbaoList.endIndex = self.m_zhanbaoList.endIndex + 1
	self.m_zhanbaoList[self.m_zhanbaoList.endIndex] = finStr
	if self.m_zhanbaoList.endIndex - self.m_zhanbaoList.beginIndex >= 50 then
		self.m_zhanbaoList[self.m_zhanbaoList.beginIndex] = nil
		self.m_zhanbaoList.beginIndex = self.m_zhanbaoList.beginIndex + 1
	end

	self.m_showingMsgNum = self.m_showingMsgNum + 1
	if self.m_showingMsgNum > 60 then
		self:showZhanbao()
	end

	print("HuaShanZhiDianDlg PushZhanBao "..sb:GetString(str))
end

function HuaShanZhiDianDlg:HandleGirlClicked()
	if self.m_changeMsgCD > 0 then
		GetGameUIManager():AddMessageTipById(145963)
		return
	end
	local index = math.random(self.m_girlMsgNum)
	while index == self.m_lastMsgIndex do
		index = math.random(self.m_girlMsgNum)
	end
	self.m_talk:setText(self.m_girlMsg[index])
	self.m_changeMsgCD = 1000
	self.m_lastMsgIndex = index
end

function HuaShanZhiDianDlg:HandleFoodClicked1()
	self:HandleFoodClicked(1)
end

function HuaShanZhiDianDlg:HandleFoodClicked2()
	self:HandleFoodClicked(2)
end

function HuaShanZhiDianDlg:HandleFoodClicked3()
	self:HandleFoodClicked(3)
end

function HuaShanZhiDianDlg:HandleFoodClicked4()
	self:HandleFoodClicked(4)
end

function HuaShanZhiDianDlg:HandleFoodClicked5()
	self:HandleFoodClicked(5)
end

function HuaShanZhiDianDlg:HandleFoodClicked( id )
	print("HuaShanZhiDianDlg Eat "..tostring(id))
	local p = require "protocoldef.knight.gsp.cross.ceatfood" : new()
    p.id = id
    require "manager.luaprotocolmanager":send(p)
end

function HuaShanZhiDianDlg:showZhanbao()
	self.m_fasongBtn:setVisible(false)
	self.m_inputArea:setVisible(false)
	self.m_msgEditBox:Clear()
	self.m_showingMsgNum = 0

	for i = self.m_zhanbaoList.beginIndex, self.m_zhanbaoList.endIndex do
		self.m_msgEditBox:AppendParseText(self.m_zhanbaoList[i], false)
		self.m_msgEditBox:AppendBreak()
	end
	self.m_msgEditBox:Refresh()
	self.m_msgEditBox:HandleEnd()
end

function HuaShanZhiDianDlg:showChat()
	self.m_fasongBtn:setVisible(true)
	self.m_inputArea:setVisible(true)
	self.m_msgEditBox:Clear()
	self.m_showingMsgNum = 0

	for i = self.m_worldMsgList.beginIndex, self.m_worldMsgList.endIndex do
		self.m_msgEditBox:AppendParseText(self.m_worldMsgList[i], false)
		self.m_msgEditBox:AppendBreak()
	end
	self.m_msgEditBox:Refresh()
	self.m_msgEditBox:HandleEnd()
end

function HuaShanZhiDianDlg:updateGirlCD( delta )
	if self.m_changeMsgCD <= 0 then return end
	self.m_changeMsgCD  = self.m_changeMsgCD - delta
end

function HuaShanZhiDianDlg:run( delta )
	self:updateGirlCD(delta)
end

return HuaShanZhiDianDlg