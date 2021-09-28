require "ui.dialog"
require "utils.mhsdutils"
require "protocoldef.knight.gsp.friends.creqjioncamp"
require "protocoldef.knight.gsp.friends.creqchangecamp"


CampCheckDialog = {}
setmetatable(CampCheckDialog, Dialog)
CampCheckDialog.__index = CampCheckDialog

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CampCheckDialog.getInstance()
	LogInfo("enter get campcheckdialog instance")
    if not _instance then
        _instance = CampCheckDialog:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CampCheckDialog.getInstanceAndShow()
	LogInfo("enter campcheckdialog instance show")
    if not _instance then
        _instance = CampCheckDialog:new()
        _instance:OnCreate()
	else
		LogInfo("set campcheckdialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CampCheckDialog.getInstanceNotCreate()
    return _instance
end

function CampCheckDialog.DestroyDialog()
	if _instance then 
		LogInfo("destroy campcheckdialog")
		_instance:OnClose()
		_instance = nil
	end
end

function CampCheckDialog.ToggleOpenClose()
	if not _instance then 
		_instance = CampCheckDialog:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

function CampCheckDialog.ChooseCamp(recommend)
	LogInfo("campcheckdialog choose camp")
	if _instance then
		if 2 == recommend then
			_instance:ChangePos()
		end
		_instance:SetRecommend(recommend)
	end
end

function CampCheckDialog.HandleChangeCamp()
	LogInfo("campcheckdialog handle change camp")
	local changeCamp = CAgreeChangeCamp.Create()
	LuaProtocolManager.getInstance():send(changeCamp)
  	GetMessageManager():CloseConfirmBox(eConfirmNormal,false)
end


----/////////////////////////////////////////------

function CampCheckDialog.GetLayoutFileName()
    return "campcheckdialog.layout"
end

function CampCheckDialog:OnCreate()
	LogInfo("campcheckdialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pCamp1 = winMgr:getWindow("campcheckdialog/campred")
	self.m_pCamp2 = winMgr:getWindow("campcheckdialog/campblue")
    self.m_pCamp1Btn = CEGUI.Window.toPushButton(winMgr:getWindow("campcheckdialog/campred/ok"))
	self.m_pCamp2Btn = CEGUI.Window.toPushButton(winMgr:getWindow("campcheckdialog/campblue/ok"))
	self.m_pCamp1Mark = winMgr:getWindow("campcheckdialog/campred/ok/mark")
	self.m_pCamp2Mark = winMgr:getWindow("campcheckdialog/campblue/ok/mark1")
	self.m_pCamp1Text = winMgr:getWindow("campcheckdialog/campred/txt")
	self.m_pCamp2Text = winMgr:getWindow("campcheckdialog/campred/txt1")

    -- subscribe event
    self.m_pCamp1Btn:setID(1)
    self.m_pCamp1Btn:subscribeEvent("Clicked", CampCheckDialog.HandleChooseBtnClicked, self) 
	self.m_pCamp2Btn:setID(2)
	self.m_pCamp2Btn:subscribeEvent("Clicked", CampCheckDialog.HandleChooseBtnClicked, self)	

	self.m_pCamp1Mark:setVisible(false)
	self.m_pCamp2Mark:setVisible(false)
	self.m_pCamp1Text:setVisible(false)
	self.m_pCamp2Text:setVisible(false)

	local camp = GetMainCharacter():GetCamp()
	if camp ~= 1 and camp ~= 2 then
		self.m_bChangeCamp = false
	else
		self.m_bChangeCamp = true
		if camp == 1 then
			self.m_pCamp1Btn:setEnabled(false)
			self.m_pCamp2Btn:setEnabled(true)
		elseif camp == 2 then
			self.m_pCamp1Btn:setEnabled(true)
			self.m_pCamp2Btn:setEnabled(false)
		end
	end	

	LogInfo("campcheckdialog oncreate end")
end

------------------- private: -----------------------------------

function CampCheckDialog:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampCheckDialog)
    return self
end

function CampCheckDialog:ChangePos()
	LogInfo("campcheckdialog change pos")
	local pos1 = CEGUI.UDim(self.m_pCamp1:getXPosition().scale, self.m_pCamp1:getXPosition().offset)
	local pos2 = CEGUI.UDim(self.m_pCamp2:getXPosition().scale, self.m_pCamp2:getXPosition().offset)
	self.m_pCamp1:setXPosition(pos2)
	self.m_pCamp2:setXPosition(pos1)
end

function CampCheckDialog:SetRecommend(id)
	LogInfo("campcheckdialog set recommend")
	if id == 1 then
		self.m_pCamp1Mark:setVisible(true)
		self.m_pCamp1Text:setVisible(true)
	elseif id == 2 then
		self.m_pCamp2Mark:setVisible(true)
		self.m_pCamp2Text:setVisible(true)
	end
end

function CampCheckDialog:HandleChooseBtnClicked(args)
	LogInfo("campcheckdialog handle choose btn clicked")
	if self.m_bChangeCamp then
		local reqChangeCamp = CReqChangeCamp.Create()
		LuaProtocolManager.getInstance():send(reqChangeCamp)
		CampCheckDialog.DestroyDialog()
		return true
	end

	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local reqJoinCamp = CReqJionCamp.Create()
	reqJoinCamp.camptype = id
	LuaProtocolManager.getInstance():send(reqJoinCamp)
	CampCheckDialog.DestroyDialog()
end

return CampCheckDialog
