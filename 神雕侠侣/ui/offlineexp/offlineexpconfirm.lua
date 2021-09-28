require "ui.dialog"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.buff.creqtakeexp"

OfflineExpConfirm = {}
setmetatable(OfflineExpConfirm, Dialog)
OfflineExpConfirm.__index = OfflineExpConfirm

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function OfflineExpConfirm.getInstance()
	LogInfo("enter get OfflineExpConfirm instance")
    if not _instance then
        _instance = OfflineExpConfirm:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function OfflineExpConfirm.getInstanceAndShow()
	LogInfo("enter OfflineExpConfirm instance show")
    if not _instance then
        _instance = OfflineExpConfirm:new()
        _instance:OnCreate()
	else
		LogInfo("set OfflineExpConfirm visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function OfflineExpConfirm.getInstanceNotCreate()
    return _instance
end

function OfflineExpConfirm.DestroyDialog()
	if _instance then 
		LogInfo("destroy OfflineExpConfirm")
		_instance:OnClose()
		_instance = nil
	end
end

function OfflineExpConfirm.ToggleOpenClose()
	if not _instance then 
		_instance = OfflineExpConfirm:new() 
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

function OfflineExpConfirm.GetLayoutFileName()
    return "offlineexpconfirm.layout"
end

function OfflineExpConfirm:OnCreate()
	LogInfo("OfflineExpConfirm oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pNormalExp = winMgr:getWindow("offlineexpconfirm/background/back0/txt2")
	self.m_p5TimeExp = winMgr:getWindow("offlineexpconfirm/background/back1/txt2")
	self.m_pNormalBtn = CEGUI.Window.toPushButton(winMgr:getWindow("offlineexpconfirm/background/back0/button"))
	self.m_p5TimeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("offlineexpconfirm/background/back1/button"))
	self.m_pPayItem = CEGUI.Window.toItemCell(winMgr:getWindow("offlineexpconfirm/background/back1/back/item"))
	self.m_pPayItemNum = winMgr:getWindow("offlineexpconfirm/background/back1/back/txt0")
	self.m_pFreeItem = CEGUI.Window.toItemCell(winMgr:getWindow("offlineexpconfirm/background/back1/back/item2"))
	self.m_pFreeItemNum = winMgr:getWindow("offlineexpconfirm/background/back1/back/txt5")
	self.m_pMoney = winMgr:getWindow("offlineexpconfirm/background/back1/txt0/txt0")	
	self.m_pBackBtn = CEGUI.Window.toPushButton(winMgr:getWindow("offlineexpconfirm/back"))

    -- subscribe event
    self.m_pNormalBtn:subscribeEvent("Clicked", OfflineExpConfirm.HandleNormalBtnClicked, self) 
	self.m_p5TimeBtn:subscribeEvent("Clicked", OfflineExpConfirm.Handle5TimeBtnClickded, self)
	self.m_pBackBtn:subscribeEvent("Clicked", OfflineExpConfirm.HandleBackClicked, self)

	local rewardTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.clixianguaji")	
	local ids = rewardTable:getAllID()
	
	for i,v in pairs(ids) do
		local record = rewardTable:getRecorder(v)
		if GetDataManager():GetMainCharacterLevel() >= record.lvmin and GetDataManager():GetMainCharacterLevel() <= record.lvmax then
			self.m_iPayRewardID = record.paylibaoid
			self.m_iFreeRewardID = record.freelibaoid
			break
		end
	end
	
	if self.m_iPayRewardID and self.m_iFreeRewardID then
		self.m_pPayItem:SetImage(GetIconManager():GetImageByID(knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.m_iPayRewardID).icon))
		self.m_pPayItem:setID(self.m_iPayRewardID)
		self.m_pPayItem:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)

		self.m_pFreeItem:SetImage(GetIconManager():GetImageByID(knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.m_iFreeRewardID).icon))
		self.m_pFreeItem:setID(self.m_iFreeRewardID)
		self.m_pFreeItem:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
	end
	
	LogInfo("OfflineExpConfirm oncreate end")
end

------------------- private: -----------------------------------


function OfflineExpConfirm:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, OfflineExpConfirm)
    return self
end

function OfflineExpConfirm:HandleNormalBtnClicked(args)
	LogInfo("OfflineExpConfirm HandleNormalBtnClicked")
	local req = CReqTakeExp.Create()
	req.flag = 1
	LuaProtocolManager.getInstance():send(req)
end

function OfflineExpConfirm:Handle5TimeBtnClickded(args)
	LogInfo("OfflineExpConfirm Handle5TimeBtnClickded")
	local req = CReqTakeExp.Create()
	req.flag = 2
	LuaProtocolManager.getInstance():send(req)
end

function OfflineExpConfirm:HandleBackClicked(args)
	LogInfo("OfflineExpConfirm HandleBackClicked")
	OfflineExpConfirm.DestroyDialog()
end

function OfflineExpConfirm:Init(totalexp, itemnum, money)
	LogInfo("OfflineExpConfirm Init")
	self.m_pPayItemNum:setText(tostring(itemnum))
	self.m_pFreeItemNum:setText(tostring(itemnum))
	self.m_pNormalExp:setText(tostring(totalexp))
	self.m_p5TimeExp:setText(tostring(math.floor(totalexp * 1.2)))
	self.m_pMoney:setText(tostring(money))
end

return OfflineExpConfirm
