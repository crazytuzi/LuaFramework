require "ui.dialog"
require "utils.mhsdutils"

CampLeaderPowerDlg = {}
setmetatable(CampLeaderPowerDlg, Dialog)
CampLeaderPowerDlg.__index = CampLeaderPowerDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function CampLeaderPowerDlg.getInstance()
	LogInfo("enter get CampLeaderPowerDlg instance")
    if not _instance then
        _instance = CampLeaderPowerDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function CampLeaderPowerDlg.getInstanceAndShow()
	LogInfo("enter CampLeaderPowerDlg instance show")
    if not _instance then
        _instance = CampLeaderPowerDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set CampLeaderPowerDlg visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function CampLeaderPowerDlg.getInstanceNotCreate()
    return _instance
end

function CampLeaderPowerDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy CampLeaderPowerDlg")
		_instance:OnClose()
		_instance = nil
	end
end

function CampLeaderPowerDlg.ToggleOpenClose()
	if not _instance then 
		_instance = CampLeaderPowerDlg:new() 
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

function CampLeaderPowerDlg.GetLayoutFileName()
    return "campleaderpower.layout"
end

function CampLeaderPowerDlg:OnCreate()
	LogInfo("CampLeaderPowerDlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    self.m_pEdit = CEGUI.toEditbox(winMgr:getWindow("campleaderpower/in"))
	self.m_pHead = winMgr:getWindow("campleaderpower/line1")
	self.m_pName = winMgr:getWindow("campleaderpower/name")
	self.m_pSchool = winMgr:getWindow("campleaderpower/school")
	self.m_pLevel = winMgr:getWindow("campleaderpower/level")
	self.m_pCloseBtn = CEGUI.toPushButton(winMgr:getWindow("campleaderpower/closed"))
	self.m_pSearchBtn = CEGUI.toPushButton(winMgr:getWindow("campleaderpower/ok"))
	self.m_pInfoBtn = CEGUI.toPushButton(winMgr:getWindow("campleaderpower/btn"))

    -- subscribe event
    self.m_pCloseBtn:subscribeEvent("Clicked", CampLeaderPowerDlg.HandleCloseBtnClicked, self) 
    self.m_pSearchBtn:subscribeEvent("Clicked", CampLeaderPowerDlg.HandleSearchBtnClicked, self) 
    self.m_pInfoBtn:subscribeEvent("Clicked", CampLeaderPowerDlg.HandleInfoBtnClicked, self) 

	self.m_pEdit:subscribeEvent("MouseClick", CampLeaderPowerDlg.HandleEditClicked, self)
	self.m_pEdit:subscribeEvent("TextChanged", CampLeaderPowerDlg.OnTextChanged, self)
	self.m_pEdit:setReadOnly(true)

	self:InitDefault()
	LogInfo("CampLeaderPowerDlg oncreate end")
end

------------------- private: -----------------------------------


function CampLeaderPowerDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, CampLeaderPowerDlg)
    return self
end

function CampLeaderPowerDlg:HandleCloseBtnClicked()
	LogInfo("CampLeaderPowerDlg HandleCloseBtnClicked")
	CampLeaderPowerDlg.DestroyDialog()
end

function CampLeaderPowerDlg:HandleSearchBtnClicked()
	LogInfo("CampLeaderPowerDlg HandleSearchBtnClicked")
	self:InitDefault()
	local text = self.m_pEdit:getText()
	local len = string.len(text)
	if len < 1 then
		GetGameUIManager():AddMessageTipById(145344)
		return
	end
	local allNum = true
	for i = 1, len do
		local ch = string.sub(text, i, i)
		if ch < '0' or ch > '9' then
			allNum = false
			break
		end
	end
	if not allNum then
		GetGameUIManager():AddMessageTipById(145344)
		return
	end
	
	local roleid = tonumber(text) 
	local req = require "protocoldef.knight.gsp.campleader.creqsearchslientrole".Create()
	req.roleid = roleid
	LuaProtocolManager.getInstance():send(req)
end

function CampLeaderPowerDlg:HandleInfoBtnClicked()
	LogInfo("CampLeaderPowerDlg HandleInfoBtnClicked")
	local req = require "protocoldef.knight.gsp.campleader.creqslientrole".Create()
	req.roleid = self.m_roleBean.roleid
	LuaProtocolManager.getInstance():send(req)
end

function CampLeaderPowerDlg:InitDefault()
	self.m_pName:setVisible(false)
	self.m_pSchool:setVisible(false)
	self.m_pLevel:setVisible(false)
	self.m_pInfoBtn:setVisible(false)
	self.m_pHead:setProperty("Image", "set:roleandmonster16 image:9067")
end

function CampLeaderPowerDlg:Init(friendBean)
	LogInfo("CampLeaderPowerDlg Init")
	self.m_roleBean = friendBean
	self.m_pName:setVisible(true)
	self.m_pSchool:setVisible(true)
	self.m_pLevel:setVisible(true)
	self.m_pInfoBtn:setVisible(true)
	
	self.m_pName:setText(friendBean.name)
	self.m_pSchool:setText(knight.gsp.role.GetSchoolInfoTableInstance():getRecorder(friendBean.school).name)
	self.m_pLevel:setText(tostring(friendBean.rolelevel) .. MHSD_UTILS.get_resstring(2397))
	local shapeTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(friendBean.shape)
	local path = GetIconManager():GetImagePathByID(shapeTmp.headID):c_str()
	self.m_pHead:setProperty("Image", path)
end

function CampLeaderPowerDlg:HandleEditClicked(args)
	LogInfo("CampLeaderPowerDlg HandleEditClicked")
	NumInputDlg:ToggleOpenHide()
    NumInputDlg:GetSingleton():setTargetWindow(self.m_pEdit)

end

function CampLeaderPowerDlg:OnTextChanged(args)
	LogInfo("CampLeaderPowerDlg OnTextChanged")
	local longID = self.m_pEdit:getText()
	if string.len(longID) > 15 then
		local shortID = string.sub(longID, 1, 15)
		self.m_pEdit:setText(shortID)
	end
end

return CampLeaderPowerDlg
