local single = require "ui.singletondialog"

local FactionTask = {}
setmetatable(FactionTask, single)
FactionTask.__index = FactionTask

function FactionTask.new()
	local self = {}
	setmetatable(self, FactionTask)
	function self.GetLayoutFileName()
		return "familytaskdlg.layout"
	end
	require "ui.dialog".OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pTaskinfo = CEGUI.toRichEditbox(winMgr:getWindow("FamilyTaskdlg/bot/info"))
	self.m_pTasklist = CEGUI.toMultiColumnList(winMgr:getWindow("FamilyTaskdlg/top"))
	self.m_pStars = CEGUI.toRichEditbox(winMgr:getWindow("FamilyTaskdlg/bot/info1"))
	self.m_pStars:SetEmotionScale(CEGUI.Vector2(0.6, 0.6))
	self.m_pLeftRefreshTxt = winMgr:getWindow("FamilyTaskdlg/bot/txt1")
	self.m_pContinueRefreshTxt = winMgr:getWindow("FamilyTaskdlg/bot/txt3")
	self.m_pContinueRefreshTxt:setVisible(false)
	self.m_pRefreshValue = winMgr:getWindow("FamilyTaskdlg/bot/num")
	self.m_pRefreshBtn = CEGUI.toPushButton(winMgr:getWindow("FamilyTaskdlg/bot/refresh"))
	self.m_pAcceptBtn = CEGUI.toPushButton(winMgr:getWindow("FamilyTaskdlg/bot/ok"))
	self.m_pRefreshBtn:subscribeEvent("Clicked", self.HandleRefreshBtnClicked, self)
	self.m_pAcceptBtn:subscribeEvent("Clicked", self.HandleAcceptBtnClicked, self)
	self.m_pTasklist:subscribeEvent("SelectionChanged", self.HandleTaskSelected, self)
	self.m_pWeekLeftnumTxt = winMgr:getWindow("FamilyTaskdlg/bot/num1")
	self.m_pMainFrame:subscribeEvent("WindowUpdate", self.HandleWindowUpdate, self)
	self.m_pTaskinfo:setEnabled(false)
	return self
end

function FactionTask:GetSelectTaskid() 
    local selecteditem = self.m_pTasklist:getFirstSelectedItem()
    if not selecteditem then
        return
    end
    return self.taskids[selecteditem]
end

local function AddFactionListboxItem(title, col_id, row_id, list)
	local pItem = CEGUI.createListboxTextItem(title)
	pItem:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
    list:setItem(pItem, col_id, row_id);
    return pItem
end

local function GetExpReward(taskconfig, starconfig)
	local lv = GetDataManager():GetMainCharacterLevel()
	return math.floor((lv * taskconfig.expnum1 + taskconfig.expnum2)
		/taskconfig.expnum3*taskconfig.typenum*starconfig.expcoe)
end

local function GetGangReward(taskconfig, starconfig)
	return math.floor(taskconfig.gangnum * taskconfig.typenum * starconfig.gangcoe)
end

local showstareffect
local curStarnum = 0
local theTime = 0
local function addStarEffect(container)
	local startpos = 16
	local starsize = 24
	local offset = startpos + (curStarnum - 1 ) * starsize 
	GetGameUIManager():AddUIEffect(container, MHSD_UTILS.get_effectpath(10390), false, offset, 16)
end
function FactionTask:HandleWindowUpdate(e)
	if not showstareffect then
		return true
	end
	local updateArgs = CEGUI.toUpdateEventArgs(e)
	theTime = theTime + updateArgs.d_timeSinceLastFrame
	local interval = 0.2
	--CEGUI::Point
	local Pos = self.m_pStars:GetScreenPos()
	while theTime >= interval do
		self.m_pStars:Clear()
		for i = 1, 6 do
			if i <= curStarnum then
				self.m_pStars:AppendEmotion(154)
				if i == curStarnum then
					addStarEffect(self.m_pStars)
				end
			else
				self.m_pStars:AppendEmotion(150)
			end
		end
		self.m_pStars:Refresh()
		theTime = theTime - interval
		if curStarnum >= self.m_iStarlevel then
			showstareffect = false
			curStarnum = 0
			theTime = 0
			self.m_pRefreshBtn:setEnabled(true)
			break
		end
		curStarnum = curStarnum + 1
	end
	return true
end

function FactionTask:AppendStar(starlevel, showeffect)
	showstareffect = showeffect
	self.m_iStarlevel = starlevel
	if not showeffect then
		self.m_pStars:Clear()
		for i = 1, 6 do
			if i <= starlevel then
				self.m_pStars:AppendEmotion(154)
			else
				self.m_pStars:AppendEmotion(150)
			end
		end
		self.m_pStars:Refresh()
	else
		curStarnum = 0
		theTime = 0
		self.m_pRefreshBtn:setEnabled(false)
	end
end

function FactionTask:RefreshLeftnum(availnum)
	if not availnum or availnum == 0 then
		self.m_pLeftRefreshTxt:setVisible(false)
		self.m_pContinueRefreshTxt:setVisible(true)
		local yuanbao = knight.gsp.game.GetCyuanbaoInGameTableInstance():getRecorder(1)
		self.m_pRefreshValue:setText(yuanbao.bangpaichanglong)
	else
		self.m_pContinueRefreshTxt:setVisible(false)
		self.m_pLeftRefreshTxt:setVisible(true)
		self.m_pRefreshValue:setText(availnum)
	end
end

function FactionTask:RefreshTaskReward(starlevel)
	local starconfig = require "utils.mhsdutils".getLuaBean(
		"knight.gsp.task.cstarprobability", starlevel)
	local rownum = self.m_pTasklist:getRowCount()
	for i = 1, rownum do
		local rowid = i - 1
		local grid_ref = CEGUI.MCLGridRef(rowid, 0)
		local pitem = self.m_pTasklist:getItemAtGridReference(grid_ref)
		local taskid = self.taskids[pitem] or 0
		local taskconfig = require "utils.mhsdutils".getLuaBean(
			"knight.gsp.task.ctasktype", taskid)
		local config = knight.gsp.task.GetCMainMissionInfoTableInstance():getRecorder(taskid)
		
		grid_ref = CEGUI.MCLGridRef(rowid, 1)
		pitem = self.m_pTasklist:getItemAtGridReference(grid_ref)
		pitem:setText(GetGangReward(taskconfig, starconfig))
		
		grid_ref = CEGUI.MCLGridRef(rowid, 2)
		pitem = self.m_pTasklist:getItemAtGridReference(grid_ref)
		pitem:setText(GetExpReward(taskconfig, starconfig))
	end
end

function FactionTask:initdata(starlevel, availnum, tasks, availtasknum)
	local starlevel = starlevel or 0
	self:AppendStar(starlevel, false)
	self:RefreshLeftnum(availnum)
	local starconfig = require "utils.mhsdutils".getLuaBean(
		"knight.gsp.task.cstarprobability", starlevel)
	self.taskids = {}
	for i = 1, #tasks do
		local task = tasks[i]
		local taskconfig = require "utils.mhsdutils".getLuaBean(
			"knight.gsp.task.ctasktype", task.taskid)
		self.m_pTasklist:addRow()
		local config = knight.gsp.task.GetCMainMissionInfoTableInstance():getRecorder(task.taskid)
		local rowid = i - 1
		local pitem = AddFactionListboxItem(config.MissionName, 0, rowid, self.m_pTasklist)
		self.taskids[pitem] = task.taskid
		AddFactionListboxItem(GetGangReward(taskconfig, starconfig), 1, rowid, self.m_pTasklist)
		AddFactionListboxItem(GetExpReward(taskconfig, starconfig), 2, rowid, self.m_pTasklist)
		AddFactionListboxItem(string.format("%d/%d",task.finishednum, taskconfig.pickupnum), 
			3, rowid, self.m_pTasklist)
	end
	if self.m_pTasklist:getRowCount() > 0 then
		local grid_ref = CEGUI.MCLGridRef(0, 0)
		self.m_pTasklist:setItemSelectState(grid_ref, true)
	end
	self:RefreshTaskReward(starlevel)
	
	local availtasknum = availtasknum or 0
	self.m_pWeekLeftnumTxt:setText(string.format("%d/%d", availtasknum, 50))
end

function FactionTask:HandleRefreshBtnClicked(e)
	local p = require "protocoldef.knight.gsp.faction.changlong.crefreshstartlevel":new()
	require "manager.luaprotocolmanager":send(p)
end

function FactionTask:HandleAcceptBtnClicked(e)
	local taskid = self:GetSelectTaskid()
	if not taskid then
		return true
	end
	if taskid then
		self.accepttaskco = coroutine.create(function ()
			local p = require "protocoldef.knight.gsp.faction.changlong.cacceptchanglong":new()
			p.taskid = taskid
			require "manager.luaprotocolmanager":send(p)
			local succ = coroutine.yield()
			if succ then
				self:DestroyDialog()
			end
		end)
		coroutine.resume(self.accepttaskco)
	end
end

function FactionTask:HandleTaskSelected(e)
	local taskid = self:GetSelectTaskid()
	if not taskid then
		return true
	end
	local questinfo = knight.gsp.task.GetCMainMissionInfoTableInstance():getRecorder(taskid+1)
	if questinfo.id == -1 or CEGUI.String(questinfo.TaskInfoTraceListA):empty() then
		self.m_pTaskinfo:Clear()
		return true
	end
	--[[
	local name = questinfo.MissionName
	if string.match(name,"round",0) then
		local sb = StringBuilder.new()
		sb:SetNum("round", quest.round)
		name = sb:GetString(name)
	end
    local newUnit = TaskTrackCell.new(quest.questid)
	string.gsub(name,"%[", "\\[",1)
	if GetTaskManager():IsMasterStrokeQuest(quest.questid) then
        newUnit.pTitle:setText(name)
        newUnit.pTitle:setProperty("TextColours", "FFFF33FF")
	else
        newUnit.pTitle:setText(name)
        newUnit.pTitle:setProperty("TextColours", "FFFFFF33")
	end
	--]]
	 if string.match(questinfo.TaskInfoTraceListA, "%$", 0) then
		local sb = StringBuilder.new()
		sb:SetNum("number", 0)
        self.m_pTaskinfo:Clear()
        local info = sb:GetString(questinfo.TaskInfoTraceListA)
		self.m_pTaskinfo:AppendParseText(CEGUI.String(info))
    	self.m_pTaskinfo:Refresh()
	else
	    self.m_pTaskinfo:Clear()
		self.m_pTaskinfo:AppendParseText(CEGUI.String(questinfo.TaskInfoTraceListA))
	    self.m_pTaskinfo:Refresh()
    end
    return true
end

return FactionTask
