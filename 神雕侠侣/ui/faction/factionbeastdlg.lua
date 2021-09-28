require "ui.dialog"

FactionBeastDlg = {}
setmetatable(FactionBeastDlg, Dialog)
FactionBeastDlg.__index = FactionBeastDlg

local BEAST_ADD_TRAIN	= 1 
local BEAST_MINUS_TRAIN = 2 
local BEAST_ADD_LEVEL	= 3
local BEAST_MINUS_LEVEL = 4

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function FactionBeastDlg.getInstance()
	print("enter get FactionBeastDlg dialog instance")
    	if not _instance then
    	    	_instance = FactionBeastDlg:new()
    	    	_instance:OnCreate()
    	end
    	
    	return _instance
end

function FactionBeastDlg.getInstanceAndShow()
	print("enter FactionBeastDlg dialog instance show")
    	if not _instance then
       		 _instance = FactionBeastDlg:new()
        	_instance:OnCreate()
	else
		print("set FactionBeastDlg dialog visible")
		_instance:SetVisible(true)
    	end
    
    	return _instance
end

function FactionBeastDlg.getInstanceNotCreate()
	return _instance
end

function FactionBeastDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function FactionBeastDlg.ToggleOpenClose()
	if not _instance then 
		_instance = FactionBeastDlg:new() 
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

function FactionBeastDlg.GetLayoutFileName()
	return "bangpaixunshoumain.layout"
end

function FactionBeastDlg:new()
    	local self = {}
    	self = Dialog:new()
    	setmetatable(self, FactionBeastDlg)

    	return self
end

function FactionBeastDlg:OnCreate()
	Dialog.OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
    	self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("bangpaixunshoumain/up/back"))
	self.m_pRewardBtn = CEGUI.toPushButton(winMgr:getWindow("bangpaixunshoumain/up/xuanzhong/btn"))
	self.m_pOpenActivityBtn  = CEGUI.toPushButton(winMgr:getWindow("bangpaixunshoumain/btn"))
	self.m_pAcceptTaskBtn  = CEGUI.toPushButton(winMgr:getWindow("bangpaixunshoumain/btn1"))
	self.m_pEditbox = CEGUI.toRichEditbox(winMgr:getWindow("bangpaixunshoumain/case/shuo"))
	self.m_pLeftTimes = winMgr:getWindow("bangpaixunshoumain/txt1")

	self.m_pPane:EnableHorzScrollBar(true)
	self.m_pRewardBtn:subscribeEvent("Clicked", self.HandleRewardBtnClicked, self)
	self.m_pOpenActivityBtn:subscribeEvent("Clicked", self.HandleOpenActivityBtnClicked, self)
	self.m_pAcceptTaskBtn:subscribeEvent("Clicked", self.HandleAcceptTaskBtnClicked, self)
	self.m_pEditbox:setReadOnly(true)
end

function FactionBeastDlg:HandleBeastClicked(e)
	local dlg = require "ui.faction.factionbeastinfo".getInstanceAndShow()
	dlg:initData(self.m_beastlevel, self.m_trainlevel, self.m_msglist)
end

function FactionBeastDlg:HandleRewardBtnClicked(e)
	local p = require "protocoldef.knight.gsp.faction.guardbeast.ctakeguardbeastaward":new()
	local net = require "manager.luaprotocolmanager".getInstance()
	net:send(p)
end

function FactionBeastDlg:HandleOpenActivityBtnClicked(e)
	local p = require "protocoldef.knight.gsp.faction.guardbeast.copenguardbeastactivity":new()
	local net = require "manager.luaprotocolmanager".getInstance()
	net:send(p)
end

function FactionBeastDlg:HandleAcceptTaskBtnClicked(e)
	local p = require "protocoldef.knight.gsp.faction.guardbeast.cacceptguardbeasttask":new()
	local net = require "manager.luaprotocolmanager".getInstance()
	net:send(p)
end

function FactionBeastDlg:initData(beastlevel, trainlevel, msglist, lefttimes)
	self.m_msglist = msglist
	self.m_beastlevel = beastlevel
	self.m_trainlevel = trainlevel
	self:initGuardBeast(beastlevel)
	self:initMsgEditbox(self.m_pEditbox, self.m_msglist)
	self.m_pLeftTimes:setText(tostring(lefttimes))
end

function FactionBeastDlg:initGuardBeast(beastlevel)
	require "ui.faction.factionbeastcell1"
	require "ui.faction.factionbeastcell2"
	self.m_pCells = {} 
	local showTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cgangbeastshow")
	local ids = showTable:getAllID()
	self.m_cellwidth1,self.m_cellwidth2 = 0,0
	for i = 1,#ids do
		if i == beastlevel then
			self.m_pCells[i] = FactionBeastCell2.CreateNewDlg(self.m_pPane, i, self)
			self.m_cellwidth2 = self.m_pCells[i]:GetWindow():getPixelSize().width
		else
			self.m_pCells[i] = FactionBeastCell1.CreateNewDlg(self.m_pPane, i, beastlevel)
			self.m_cellwidth1 = self.m_pCells[i]:GetWindow():getPixelSize().width
		end

		local offset = 0 
		if i > beastlevel then
			offset = self.m_cellwidth2 - self.m_cellwidth1 
		end

		self.m_pCells[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, (i - 1) * self.m_cellwidth1+offset+1),CEGUI.UDim(0, 0)))

		if beastlevel <= 1 then
			self.m_pPane:getHorzScrollbar():setScrollPosition(0)
		else
			self.m_pPane:getHorzScrollbar():setScrollPosition((beastlevel-2)*self.m_cellwidth1)
		end
	end
end


function FactionBeastDlg:initMsgEditbox(editbox, msglist)
	if editbox == nil or msglist == nil then
		return
	end

	local msgTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cgangbeasttip")
	local showTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cgangbeastshow")

	editbox:Clear()
	local tmplist = {}

	for i,v in pairs (msglist) do  
		local strbuilder = StringBuilder:new()
		if v.messagetype == BEAST_ADD_TRAIN then
			strbuilder:Set("parameter1", v.rolename)
			strbuilder:SetNum("parameter2", v.tasklevel)
			strbuilder:SetNum("parameter3", v.trainlevel)
		elseif v.messagetype == BEAST_MINUS_TRAIN then
			strbuilder:SetNum("parameter1", v.trainlevel)
		elseif v.messagetype == BEAST_ADD_LEVEL then
			strbuilder:SetNum("parameter1", v.beastlevel)
			local record = showTable:getRecorder(v.beastlevel)
			if record then
				strbuilder:Set("parameter2", record.name)
			else
				strbuilder:Set("parameter2", "")
			end
		elseif v.messagetype == BEAST_MINUS_LEVEL then
			strbuilder:SetNum("parameter1", v.beastlevel)
			local record = showTable:getRecorder(v.beastlevel)
			if record then
				strbuilder:Set("parameter2", record.name)
			else
				strbuilder:Set("parameter2", "")
			end
		end

		if v.messagetype >= BEAST_ADD_TRAIN and v.messagetype <= BEAST_MINUS_LEVEL then
			local record = msgTable:getRecorder(v.messagetype)
			if record then
				editbox:AppendBreak()
				editbox:AppendParseText(CEGUI.String(strbuilder:GetString(record.tip)))
			end
		end
	end
	editbox:Refresh()
	--editbox:HandleTop()
end


return FactionBeastDlg
