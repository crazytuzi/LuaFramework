local Dialog = require "ui.dialog"

NormalDaTiDlg = {}
setmetatable(NormalDaTiDlg, Dialog)
NormalDaTiDlg.__index = NormalDaTiDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function NormalDaTiDlg.getInstance()
	LogInfo("enter get NormalDaTiDlg dialog instance")
    if not _instance then
        _instance = NormalDaTiDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function NormalDaTiDlg.getInstanceAndShow()
	LogInfo("enter NormalDaTiDlg dialog instance show")
    if not _instance then
        _instance = NormalDaTiDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set NormalDaTiDlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function NormalDaTiDlg.getInstanceNotCreate()
    return _instance
end

function NormalDaTiDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function NormalDaTiDlg.ToggleOpenClose()
	if not _instance then 
		_instance = NormalDaTiDlg:new() 
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

function NormalDaTiDlg.GetLayoutFileName()
    return "yunyounpcdialog.layout"
end

function NormalDaTiDlg:OnCreate()
	LogInfo("NormalDaTiDlg dialog oncreate begin")
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
	self.m_Answer[1].btn:subscribeEvent("Clicked", NormalDaTiDlg.HandleAnswer1Clicked, self)
	self.m_Answer[2].btn:subscribeEvent("Clicked", NormalDaTiDlg.HandleAnswer2Clicked, self)
	self.m_Answer[3].btn:subscribeEvent("Clicked", NormalDaTiDlg.HandleAnswer3Clicked, self)
	self.m_Answer[4].btn:subscribeEvent("Clicked", NormalDaTiDlg.HandleAnswer4Clicked, self)

--	self:GetWindow():subscribeEvent("WindowUpdate", NormalDaTiDlg.HandleWindowUpdate, self)

	LogInfo("NormalDaTiDlg dialog oncreate end")
end

------------------- private: -----------------------------------


function NormalDaTiDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, NormalDaTiDlg)
    return self
end

function NormalDaTiDlg:setNpcInfo(NpcId)
	local tt
	local record
	tt = knight.gsp.npc.GetCNPCConfigTableInstance()
	record = tt:getRecorder(NpcId)
	self.m_NPC.name:setText(record.name)
	tt = knight.gsp.npc.GetCNpcShapeTableInstance()
	record = tt:getRecorder(record.modelID)
	local iconPath = GetIconManager():GetImagePathByID(record.headID):c_str()
	self.m_NPC.icon:setProperty("Image",iconPath)
end

function NormalDaTiDlg:SetQuestion(qtype, qid)
	local table
	local record
	if     qtype == 1 then  -- 情侣灵犀题库
		table = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.cqinglvtiku")
	elseif qtype == 2 then  -- 灯谜题库
		table = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyuanxiaorepository")
	elseif qtype == 3 then  -- 一百层活动－智客答题
		table = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cyibaiceng")
	end
	if not table then
		return
	end

	record = table:getRecorder(qid)
	if qtype == 3 then
		self.m_Question:setText(record.title)
	else
		self.m_Question:setText(record.name)
	end

	local TableUtil =  require "utils.tableutil"
	local size = TableUtil.tablelength(record.options)
	for i=1, size do
		self.m_Answer[i].txt:setText(record.options[i-1])
	end
	for i=1, 4 do
		self.m_Answer[i].btn:setVisible(true)
	end
	for i=size+1, 4 do
		self.m_Answer[i].btn:setVisible(false)
	end
end

function NormalDaTiDlg:Refresh(result, NpcKey, Qtype, Qid)
	if Qid == 0 then
		NormalDaTiDlg.DestroyDialog()
		return;
	end
	self.result = result
	self.npckey = NpcKey
	self.qid = Qid
	self.qtype = Qtype
--	LogErr("NormalDaTiDlg:Refresh : " .. self.npckey .. ", " .. self.qid .. ", " .. self.qtype)
	self.alreadysend = false
	npcid = GetScene():FindNpcByID(NpcKey):GetNpcBaseID()
	self:setNpcInfo(npcid)
	self:SetQuestion(Qtype, Qid)
end

function NormalDaTiDlg:sendAnswer(num)
	if self.alreadysend == true then
		return
	end
	self.alreadysend = true
	local CAnsQuestion =  require "protocoldef.knight.gsp.task.cansquestion"
	local req = CAnsQuestion.Create()
	req.npckey = self.npckey
	req.questionid = self.qid
	req.answer = num
	req.flag = self.qtype
	LuaProtocolManager.getInstance():send(req)
	if self.result == -2 then --点完就关闭窗口
		NormalDaTiDlg.DestroyDialog()
	end
end

function NormalDaTiDlg:HandleAnswer1Clicked(args)
	LogInfo("NormalDaTiDlg:HandleAnswer1Clicked clicked")
	self:sendAnswer(1)
	return true
end

function NormalDaTiDlg:HandleAnswer2Clicked(args)
	LogInfo("NormalDaTiDlg:HandleAnswer2Clicked clicked")
	self:sendAnswer(2)
	return true
end

function NormalDaTiDlg:HandleAnswer3Clicked(args)
	LogInfo("NormalDaTiDlg:HandleAnswer3Clicked clicked")
	self:sendAnswer(3)
	return true
end

function NormalDaTiDlg:HandleAnswer4Clicked(args)
	LogInfo("NormalDaTiDlg:HandleAnswer4Clicked clicked")
	self:sendAnswer(4)
	return true
end

return NormalDaTiDlg
