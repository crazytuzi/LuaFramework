require "ui.dialog"
require "protocoldef.knight.gsp.npc.csendyunyouanswerl"
require "protocoldef.knight.gsp.npc.cyunyoudlgclosel"

YunYouSongBaoDlg = {}
setmetatable(YunYouSongBaoDlg, Dialog)
YunYouSongBaoDlg.__index = YunYouSongBaoDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function YunYouSongBaoDlg.getInstance()
	LogInfo("enter get YunYouSongBaoDlg dialog instance")
    if not _instance then
        _instance = YunYouSongBaoDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function YunYouSongBaoDlg.getInstanceAndShow()
	LogInfo("enter YunYouSongBaoDlg dialog instance show")
    if not _instance then
        _instance = YunYouSongBaoDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set YunYouSongBaoDlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function YunYouSongBaoDlg.getInstanceNotCreate()
    return _instance
end

function YunYouSongBaoDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		if _instance.alreadysend == false then
			local cancel = CYunYouDlgCloseL.Create()
			cancel.questiontype = _instance.qid
			LuaProtocolManager.getInstance():send(cancel)
		end
		_instance = nil
	end
end

function YunYouSongBaoDlg.ToggleOpenClose()
	if not _instance then 
		_instance = YunYouSongBaoDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

----/////////////////////////////////////////------

function YunYouSongBaoDlg.GetLayoutFileName()
    return "yunyounpcdialog.layout"
end

function YunYouSongBaoDlg:OnCreate()
	LogInfo("YunYouSongBaoDlg dialog oncreate begin")
    Dialog.OnCreate(self)

	self.autoclose = false
	self.closetime = 2
    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_NPC = {}
	self.m_NPC.icon = winMgr:getWindow("yunyounpcDialog/icon")
	self.m_NPC.name = winMgr:getWindow("yunyounpcDialog/name")
	self.m_effect = winMgr:getWindow("yunyounpcDialog/back/effect")
	self.m_Question = winMgr:getWindow("yunyounpcDialog/back/ditu/question")
	self.m_Answer = {}
	for i=0, 3 do
		self.m_Answer[i+1] = {}
		self.m_Answer[i+1].btn = winMgr:getWindow("yunyounpcDialog/back/answer" .. tostring(i))
		self.m_Answer[i+1].opt = winMgr:getWindow("yunyounpcDialog/back/answer/letter" .. tostring(i))
		self.m_Answer[i+1].txt = winMgr:getWindow("yunyounpcDialog/back/answer/txt" .. tostring(i))
	end

    -- subscribe event
	self.m_Answer[1].btn:subscribeEvent("Clicked", YunYouSongBaoDlg.HandleAnswer1Clicked, self)
	self.m_Answer[2].btn:subscribeEvent("Clicked", YunYouSongBaoDlg.HandleAnswer2Clicked, self)
	self.m_Answer[3].btn:subscribeEvent("Clicked", YunYouSongBaoDlg.HandleAnswer3Clicked, self)
	self.m_Answer[4].btn:subscribeEvent("Clicked", YunYouSongBaoDlg.HandleAnswer4Clicked, self)

	self:GetWindow():subscribeEvent("WindowUpdate", YunYouSongBaoDlg.HandleWindowUpdate, self)

	LogInfo("YunYouSongBaoDlg dialog oncreate end")
end

------------------- private: -----------------------------------


function YunYouSongBaoDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, YunYouSongBaoDlg)
    return self
end

function YunYouSongBaoDlg:setNpcInfo(NpcId)
	local tt
	local record
	tt = knight.gsp.npc.GetCNPCConfigTableInstance()
	record = tt:getRecorder(NpcId)
	tt = knight.gsp.npc.GetCNpcShapeTableInstance()
	record = tt:getRecorder(record.modelID)
	local iconPath = GetIconManager():GetImagePathByID(record.headID):c_str()
	self.m_NPC.icon:setProperty("Image",iconPath)
end

function YunYouSongBaoDlg:initQuestion(NpcId, NpcKey, Qtype, Qid)
	self:setNpcInfo(NpcId)
	self.npckey = NpcKey
	self.qid = Qid
	local tt
	local record
	if Qtype == 1 then
		tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.ctangshiquestion")
	elseif Qtype == 2 then
		tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.csongciquestion")
	elseif Qtype == 3 then
		tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyunyougamequestion")
	end
	record = tt:getRecorder(Qid)
	self.m_Question:setText(record.question)
	LogInfo("record.question --> " .. record.question)
	LogInfo("record.options1 --> " .. record.options1)
	LogInfo("record.options2 --> " .. record.options2)
	LogInfo("record.options3 --> " .. record.options3)
	LogInfo("record.options4 --> " .. record.options4)
	self.m_Answer[1].txt:setText(record.options1)
	self.m_Answer[2].txt:setText(record.options2)
	self.m_Answer[3].txt:setText(record.options3)
	self.m_Answer[4].txt:setText(record.options4)

	self.alreadysend = false
	self.m_Answer[1].btn:setVisible(true)
	self.m_Answer[2].btn:setVisible(true)
	self.m_Answer[3].btn:setVisible(true)
	self.m_Answer[4].btn:setVisible(true)
end

function YunYouSongBaoDlg:results(right, tipsid)
	if right == 1 then
		GetGameUIManager():AddUIEffect(self.m_effect, MHSD_UTILS.get_effectpath(10244), false)
	else
		GetGameUIManager():AddUIEffect(self.m_effect, MHSD_UTILS.get_effectpath(10245), false)
	end
	self.autoclose = true
	self.m_Answer[1].btn:setVisible(false)
	self.m_Answer[2].btn:setVisible(false)
	self.m_Answer[3].btn:setVisible(false)
	self.m_Answer[4].btn:setVisible(false)
	local tt
	tt = knight.gsp.message.GetCMessageTipTableInstance()
	local record
	record = tt:getRecorder(tipsid)
	self.m_Question:setText(record.msg)
end

function YunYouSongBaoDlg:sendAnswer(num)
	if self.alreadysend == true then
		return
	end
	self.alreadysend = true
	local answer = CSendYunYouAnswerL.Create()
	answer.npckey = self.npckey
	answer.answerid = num
	LuaProtocolManager.getInstance():send(answer)
end

function YunYouSongBaoDlg:HandleAnswer1Clicked(args)
	LogInfo("YunYouSongBaoDlg:HandleAnswer1Clicked clicked")
	self:sendAnswer(1)
	return true
end

function YunYouSongBaoDlg:HandleAnswer2Clicked(args)
	LogInfo("YunYouSongBaoDlg:HandleAnswer2Clicked clicked")
	self:sendAnswer(2)
	return true
end

function YunYouSongBaoDlg:HandleAnswer3Clicked(args)
	LogInfo("YunYouSongBaoDlg:HandleAnswer3Clicked clicked")
	self:sendAnswer(3)
	return true
end

function YunYouSongBaoDlg:HandleAnswer4Clicked(args)
	LogInfo("YunYouSongBaoDlg:HandleAnswer4Clicked clicked")
	self:sendAnswer(4)
	return true
end

function YunYouSongBaoDlg:HandleWindowUpdate(args)
	if self.autoclose == true then
		self.closetime = self.closetime - CEGUI.toUpdateEventArgs(args).d_timeSinceLastFrame
		LogInfo("-----------------self.closetime:  " .. self.closetime)
		if self.closetime <= 0 then
			YunYouSongBaoDlg.DestroyDialog()
		end
	end
end

return YunYouSongBaoDlg
