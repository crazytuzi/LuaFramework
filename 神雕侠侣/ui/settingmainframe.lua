require "ui.dialog"
require "ui.safelocksetdlg"
--require "ui.systemsettingdlg"

SettingMainFrame = {

typeSystemSetting = 1,
typeAdvanSetting  = 2,
typeSecurityLock = 3,
m_pButton1 = nil,
m_pButton2 = nil,
m_pButton3 = nil,

}

setmetatable(SettingMainFrame, Dialog)
SettingMainFrame.__index = SettingMainFrame

local _instance;

function SettingMainFrame.getInstance()
	if not _instance then
		_instance = SettingMainFrame:new()
		_instance:OnCreate()
	end

	return _instance
end

function SettingMainFrame.getInstanceAndShow()
	LogInfo("____SettingMainFrame.getInstanceAndShow")
    if not _instance then
        _instance = SettingMainFrame:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function SettingMainFrame.peekInstance()
	return _instance;
end

function SettingMainFrame.DestroyDialog()
    LogInfo("____SettingMainFrame.DestroyDialog")
	local systemsetting = SystemSettingDlg.peekInstance();
	local advansetting = AdvanSettingDlg.peekInstance();
	local securitysetting = SecurityLockSettingDlg.peekInstance()
	local safelocksetdlg = SafeLockSetDlg.getInstanceNotCreate()
	if _instance then
		_instance:OnClose()
		_instance = nil
	end

	if systemsetting ~= nil then
		systemsetting.DestroyDialog();
	end

	if advansetting ~= nil then
		advansetting.DestroyDialog();
	end
	if securitysetting ~= nil then
		securitysetting.DestroyDialog()
	end
	if safelocksetdlg ~= nil then 
		safelocksetdlg.DestroyDialog()
	end
end

function SettingMainFrame.GetLayoutFileName()
	return "Lable.layout"
end

function SettingMainFrame:OnCreate()

    LogInfo("____enter SettingMainFrame:OnCreate")

    --xiaolong dabao need to modify
    local enumSettingLabel = enumFactionLabel + 1
	Dialog.OnCreate(self, nil, enumSettingLabel)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pButton1 = winMgr:getWindow(tostring(enumSettingLabel) .. "Lable/button")
	self.m_pButton2 = winMgr:getWindow(tostring(enumSettingLabel) .. "Lable/button1")
    self.m_pButton3 = winMgr:getWindow(tostring(enumSettingLabel) .. "Lable/button2");
    self.m_pButton4 = winMgr:getWindow(tostring(enumSettingLabel) .. "Lable/button3");
    self.m_pButton5 = winMgr:getWindow(tostring(enumSettingLabel) .. "Lable/button4");
    self.m_pButton4:setVisible(false)
    self.m_pButton5:setVisible(false)

	self.m_pButton1:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2889).msg)
	self.m_pButton2:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2890).msg)
	self.m_pButton3:setText(knight.gsp.message.GetCStringResTableInstance():getRecorder(2993).msg)


    self.m_pButton1:subscribeEvent("Clicked", SettingMainFrame.HandleButton1Clicked, self)
	self.m_pButton2:subscribeEvent("Clicked", SettingMainFrame.HandleButton2Clicked, self)
    self.m_pButton3:subscribeEvent("Clicked", SettingMainFrame.HandleButton3Clicked, self)


    LogInfo("____exit SettingMainFrame:OnCreate")
end

function SettingMainFrame:ShowWindow(w)
	if w == self.typeSecurityLock then
		local p = require "protocoldef.knight.gsp.lock.creqlockinfo":new()
		require "manager.luaprotocolmanager":send(p)
		return
	end
	local systemsetting = SystemSettingDlg.peekInstance();
	local advansetting = AdvanSettingDlg.peekInstance();
	local secuSetting = SecurityLockSettingDlg.peekInstance()
	local safelocksetdlg = SafeLockSetDlg.getInstanceNotCreate()
	if systemsetting ~= nil then
		systemsetting:SetVisible(false);
	end

	if advansetting ~= nil then
		advansetting:SetVisible(false);
	end

	if secuSetting ~= nil then
		secuSetting:SetVisible(false)
	end
	if safelocksetdlg ~= nil then
		safelocksetdlg:SetVisible(false)
	end

	if w == self.typeSystemSetting then
		if systemsetting == nil then
            systemsetting = SystemSettingDlg.getInstance()
        end
		systemsetting:SetVisible(true)
	elseif w == self.typeAdvanSetting then
		if advansetting == nil then
            advansetting = AdvanSettingDlg.getInstance()
        end
		advansetting:SetVisible(true)
	end
end
function SettingMainFrame:CheckLockHandler(status)
	SettingMainFrame:ShowWindow("")
	if status == 0 then
		self:SetVisible(false)   
		SafeLockSetDlg.getInstanceAndShow()
	else
		SecurityLockSettingDlg.getInstance():SetVisible(true)
	end
end
function SettingMainFrame:SetVisible(b)
	self.m_pButton1:setVisible(b)
	self.m_pButton2:setVisible(b)
	self.m_pButton3:setVisible(b)
	self.m_pMainFrame:setVisible(b)
end
function SettingMainFrame:HandleButton1Clicked(arg)
	self:ShowWindow(self.typeSystemSetting);
end

function SettingMainFrame:HandleButton2Clicked(arg)
	self:ShowWindow(self.typeAdvanSetting);
end
function SettingMainFrame:HandleButton3Clicked(arg)
	self:ShowWindow(self.typeSecurityLock);
end

function SettingMainFrame:new()
	local self = {}
	self = Dialog:new()
	setmetatable(self, SettingMainFrame)
	return self
end

return SettingMainFrame
