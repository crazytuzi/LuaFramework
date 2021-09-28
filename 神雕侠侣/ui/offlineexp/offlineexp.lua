require "ui.dialog"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.buff.creqofflinehook"
require "protocoldef.knight.gsp.buff.creqtakeexp"

OfflineExp = {}
setmetatable(OfflineExp, Dialog)
OfflineExp.__index = OfflineExp

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
local MAX_TIME = 120
function OfflineExp.getInstance()
	LogInfo("enter get OfflineExp instance")
    if not _instance then
        _instance = OfflineExp:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function OfflineExp.getInstanceAndShow()
	LogInfo("enter OfflineExp instance show")
    if not _instance then
        _instance = OfflineExp:new()
        _instance:OnCreate()
	else
		LogInfo("set OfflineExp visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function OfflineExp.getInstanceNotCreate()
    return _instance
end

function OfflineExp.DestroyDialog()
	if _instance then 
		LogInfo("destroy OfflineExp")
		_instance:OnClose()
		_instance = nil
	end
end

function OfflineExp.ToggleOpenClose()
	if not _instance then 
		_instance = OfflineExp:new() 
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

function OfflineExp.GetLayoutFileName()
    return "offlineexp.layout"
end

function OfflineExp:OnCreate()
	LogInfo("OfflineExp oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pNormalTxtNotStart = winMgr:getWindow("offlineexp/background/back0/txt1")
	self.m_pNormalExpNotStart = winMgr:getWindow("offlineexp/background/back0/txt2")
	self.m_pNormalBtn = CEGUI.Window.toPushButton(winMgr:getWindow("offlineexp/background/back0/button"))
	self.m_pNormalTxtStarted = winMgr:getWindow("offlineexp/background/back0/txt3")
	self.m_pNormalExpStarted = winMgr:getWindow("offlineexp/background/back0/txt4")

	self.m_p5TimesTxtNotstart = winMgr:getWindow("offlineexp/background/back1/txt1")
	self.m_p5TimesExpNotStart = winMgr:getWindow("offlineexp/background/back1/txt2")
	self.m_p5TimeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("offlineexp/background/back1/button"))
	self.m_p5TimeLeft = winMgr:getWindow("offlineexp/background/back1/txt4")
	self.m_p5TimeTxtStarted = winMgr:getWindow("offlineexp/background/back1/txt5")
	self.m_p5TimeExpStarted = winMgr:getWindow("offlineexp/background/back1/txt6")
	self.m_p5TimeItemUse = CEGUI.Window.toPushButton(winMgr:getWindow("offlineexp/background/back1/imagebutton"))

	self.m_pItem = CEGUI.Window.toItemCell(winMgr:getWindow("offlineexp/ditu/back/item"))
	self.m_pTotalTime = winMgr:getWindow("offlineexp/ditu/back/txt0")
	self.m_pTotalExp = winMgr:getWindow("offlineexp/ditu/back/txt1")
	self.m_pGetExpBtn = CEGUI.Window.toPushButton(winMgr:getWindow("offlineexp/ditu/back/button"))
	self.m_pExitBtn = CEGUI.Window.toPushButton(winMgr:getWindow("offlineexp/background/back0/button1"))

    -- subscribe event
    self.m_pNormalBtn:subscribeEvent("Clicked", OfflineExp.HandleNormalBtnClicked, self) 
	self.m_p5TimeBtn:subscribeEvent("Clicked", OfflineExp.Handle5TimeBtnClicked, self)
	self.m_pGetExpBtn:subscribeEvent("Clicked", OfflineExp.HandleGetExpClicked, self)
	self.m_p5TimeItemUse:subscribeEvent("Clicked", OfflineExp.HandleItemUse, self)
	self.m_pExitBtn:subscribeEvent("Clicked", OfflineExp.HandleExitClicked, self)

	self.m_pNormalTxtStarted:setVisible(false)
	self.m_pNormalExpStarted:setVisible(false)
	self.m_p5TimeTxtStarted:setVisible(false)
	self.m_p5TimeExpStarted:setVisible(false)

	self.m_pGetExpBtn:setEnabled(false)
	self.m_iStatus = 0

	local rewardTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.clixianguaji")	
	local ids = rewardTable:getAllID()
	
	for i,v in pairs(ids) do
		local record = rewardTable:getRecorder(v)
		if GetDataManager():GetMainCharacterLevel() >= record.lvmin and GetDataManager():GetMainCharacterLevel() <= record.lvmax then
			self.m_iRewardID = record.freelibaoid
			break
		end
	end
	
	if self.m_iRewardID then
		self.m_pItem:SetImage(GetIconManager():GetImageByID(knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.m_iRewardID).icon))
		self.m_pItem:setID(self.m_iRewardID)
		self.m_pItem:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
	end
	

	LogInfo("OfflineExp oncreate end")
end

------------------- private: -----------------------------------


function OfflineExp:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, OfflineExp)
    return self
end

function OfflineExp:HandleNormalBtnClicked(args)
	LogInfo("OfflineExp HandleNormalBtnClicked")
	local req = CReqOffLineHook.Create()
	req.flag = 1
	LuaProtocolManager.getInstance():send(req)
end

function OfflineExp:Handle5TimeBtnClicked(args)
	LogInfo("OfflineExp Handle5TimeBtnClicked")
	local req = CReqOffLineHook.Create()
	req.flag = 2
	LuaProtocolManager.getInstance():send(req)
end

function OfflineExp:HandleItemUse(args)
	LogInfo("OfflineExp HandleItemUse")
	local req = CReqOffLineHook.Create()
	req.flag = 3
	LuaProtocolManager.getInstance():send(req)
end

function OfflineExp:HandleGetExpClicked(args)
	LogInfo("OfflineExp HandleGetExpClicked")
	local req = CReqTakeExp.Create()
	req.flag = 0
	LuaProtocolManager.getInstance():send(req)
end

function OfflineExp:Init(f5timeused, normaltimeused, normalexp, f5exp, f5timeremain, flag)
	LogInfo("OfflineExp Init")
	self.m_iStatus = flag 
	self.m_f5TimeUsed = f5timeused / 1000
	self.m_fNormalTimeUsed = normaltimeused / 1000
	self.m_fNormalExpPerMin = normalexp
	self.m_f5ExpPerMin = f5exp
	self.m_f5TimeRemain = f5timeremain / 1000
	if flag == 0 then
		self.m_pNormalTxtStarted:setVisible(false)
		self.m_pNormalExpStarted:setVisible(false)
		self.m_pNormalTxtNotStart:setVisible(true)
		self.m_pNormalExpNotStart:setVisible(true)
		self.m_p5TimeTxtStarted:setVisible(false)
		self.m_p5TimeExpStarted:setVisible(false)
		self.m_p5TimesTxtNotstart:setVisible(true)
		self.m_p5TimesExpNotStart:setVisible(true)
		self.m_pGetExpBtn:setEnabled(false)
		self.m_pNormalBtn:setEnabled(true)
		self.m_p5TimeBtn:setEnabled(true)
		self.m_p5TimeItemUse:setEnabled(true)
		self.m_pNormalExpNotStart:setText(tostring(normalexp))
		self.m_p5TimesExpNotStart:setText(tostring(f5exp))
		self.m_pTotalTime:setText(tostring(0))
		self.m_pTotalExp:setText(tostring(0))
		self.m_p5TimeLeft:setText(tostring(math.floor(f5timeremain / 1000 / 60)))
		self.m_pExitBtn:setVisible(true)
	elseif flag == 1 or flag == 2 then
		self.m_pNormalTxtStarted:setVisible(true)
		self.m_pNormalExpStarted:setVisible(true)
		self.m_pNormalTxtNotStart:setVisible(false)
		self.m_pNormalExpNotStart:setVisible(false)
		self.m_p5TimeTxtStarted:setVisible(true)
		self.m_p5TimeExpStarted:setVisible(true)
		self.m_p5TimesTxtNotstart:setVisible(false)
		self.m_p5TimesExpNotStart:setVisible(false)
		self.m_pGetExpBtn:setEnabled(true)
		self.m_pNormalBtn:setEnabled(false)
		self.m_p5TimeBtn:setEnabled(false)
		self.m_p5TimeItemUse:setEnabled(false)
		local normalMin = math.floor(normaltimeused / 1000 / 60)
		local f5TimeMin = math.floor(f5timeused / 1000 / 60)
		self.m_pNormalExpStarted:setText(tostring(normalexp * normalMin) .. "/" .. tostring(normalMin))
		self.m_p5TimeExpStarted:setText(tostring(f5exp * f5TimeMin) .. "/" .. tostring(f5TimeMin))
		self.m_pTotalTime:setText(tostring(f5TimeMin + normalMin))
		self.m_pTotalExp:setText(tostring(normalexp * normalMin + f5exp * f5TimeMin))
		self.m_p5TimeLeft:setText(tostring(math.floor(f5timeremain / 1000 / 60)))
		self.m_pExitBtn:setVisible(false)
	end
end

function OfflineExp:run(elapse)
	local totalTime = math.floor(self.m_fNormalTimeUsed / 60) + math.floor(self.m_f5TimeUsed / 60)
	if totalTime >= MAX_TIME or totalTime < 0 then
		self.m_iStatus = -1
	end
	if self.m_iStatus == 0 or self.m_iStatus == -1 then
		return
	end
	local oldNormalTime = self.m_fNormalTimeUsed
	local old5Time = self.m_f5TimeUsed
	local old5Remain = self.m_f5TimeRemain
	if self.m_iStatus == 2 then
		self.m_f5TimeUsed = self.m_f5TimeUsed + elapse
		self.m_f5TimeRemain = self.m_f5TimeRemain - elapse
		if self.m_f5TimeRemain <= 0 then
			self.m_f5TimeRemain = 0
			self.m_iStatus = 1
		end
	elseif self.m_iStatus == 1 then
		self.m_fNormalTimeUsed = self.m_fNormalTimeUsed + elapse
	end

	totalTime = math.floor(self.m_fNormalTimeUsed / 60) + math.floor(self.m_f5TimeUsed / 60)
	if totalTime > MAX_TIME or totalTime < 0 then
		self.m_fNormalTimeUsed = oldNormalTime
		self.m_f5TimeUsed = old5Time
		self.m_f5TimeRemain = old5Remain
		return
	end

	local bTimeChange = false
	if math.floor(oldNormalTime / 60) ~= math.floor(self.m_fNormalTimeUsed / 60) then
		self.m_pNormalExpStarted:setText(tostring(math.floor(self.m_fNormalTimeUsed / 60) * self.m_fNormalExpPerMin) .. "/" .. tostring(math.floor(self.m_fNormalTimeUsed / 60)))
		bTimeChange = true
	end
	if math.floor(old5Time / 60) ~= math.floor(self.m_f5TimeUsed / 60) then
		self.m_p5TimeExpStarted:setText(tostring(math.floor(self.m_f5TimeUsed / 60) * self.m_f5ExpPerMin) .. "/" .. tostring(math.floor(self.m_f5TimeUsed / 60)))
		bTimeChange = true
	end
	if math.floor(old5Remain / 60) ~= math.floor(self.m_f5TimeRemain / 60) then
		self.m_p5TimeLeft:setText(tostring(math.floor(self.m_f5TimeRemain / 60)))
	end
	if bTimeChange then
		local totalTime = math.floor(self.m_fNormalTimeUsed / 60) + math.floor(self.m_f5TimeUsed / 60)
		self.m_pTotalTime:setText(tostring(totalTime))
		self.m_pTotalExp:setText(tostring(math.floor(self.m_fNormalTimeUsed / 60) * self.m_fNormalExpPerMin + math.floor(self.m_f5TimeUsed / 60) * self.m_f5ExpPerMin))
	end	
end

function OfflineExp:HandleExitClicked(args)
	LogInfo("OfflineExp handle exit clicked")
	OfflineExp.DestroyDialog()
end


return OfflineExp
