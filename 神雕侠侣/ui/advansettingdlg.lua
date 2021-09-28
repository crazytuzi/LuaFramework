--[[
author: lvxiaolong
date:   2013/7/23
function: for advanced setting ui
]]

require "ui.dialog"
require "ui.settingmainframe"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.cautosetmaxshownum2"

local ADVAN_SETTING_INFO_INI = "AdvanSettingInfo.ini"
local NAME_SECTION_ADVANSETTING = "AdvanSettingRecord"
local NAME_KEY_ADVANSETTING = "advansettingvalue"

AdvanSettingDlg = {

typeNormalMode = 1,
typeSelfAdaptiveMode = 2,
typeEleSaveMode = 3,

}
setmetatable(AdvanSettingDlg, Dialog)
AdvanSettingDlg.__index = AdvanSettingDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function AdvanSettingDlg.GetDevEffectPlayLevel()
    LogInfo("____AdvanSettingDlg.GetDevEffectPlayLevel")
    
    local typeDevice = CDeviceInfo:GetDeviceType()
    LogInfo("____typeDevice: " .. typeDevice)
    
    local nDangwei = 3

    --ios device
    if typeDevice == 1 then
        local cpuCount = CDeviceInfo:GetCpuCount()
        local cpuFreq = CDeviceInfo:GetCpuFrequency()
        --local sizeMem = CDeviceInfo:GetTotalMemSize()
        if cpuCount >= 2 then
            if cpuFreq >= 900 then
                nDangwei = 3
            else
                nDangwei = 2
            end
        else
            nDangwei = 1
        end
            
    --android
    elseif typeDevice == 2 then
        local sizeMem = CDeviceInfo:GetTotalMemSize()
        local cpuCount = CDeviceInfo:GetCpuCount()
        local cpuMaxFreq = CDeviceInfo:GetMaxCpuFreq()
        
        --we think exception happened, so handle it for normal device
        if sizeMem <= 0 or cpuCount <= 0 or cpuMaxFreq <= 0 then
            nDangwei = 2
        else
            if sizeMem <= 600 then
                nDangwei = 1
            elseif cpuCount >= 4 then
                nDangwei = 3
            elseif cpuCount >= 2 then
                nDangwei = 2
            else
                if cpuMaxFreq > 1200 then
                    nDangwei = 2
                else
                    nDangwei = 1
                end
            end
        end
    end
    
    LogInfo("____nDangwei: " .. nDangwei)

    return nDangwei
end

function AdvanSettingDlg.GetMaxDisplayPlayerNum()
    LogInfo("____AdvanSettingDlg.GetMaxDisplayPlayerNum")
    
	--wp8
	if CDeviceInfo:GetDeviceType() == 3 then
		local sizeMem = CDeviceInfo:GetTotalMemSize()

		if sizeMem <= 512 then
			return 5
		elseif sizeMem <= 1024 then
			return 5
		else
			return 20
		end
	end
	
    local strIniPath = ADVAN_SETTING_INFO_INI or "AdvanSettingInfo.ini"
    local strSecName = NAME_SECTION_ADVANSETTING or "AdvanSettingRecord"
    local strKeyName = NAME_KEY_ADVANSETTING or "advansettingvalue"

    local iniMgr = CIniManager(strIniPath)
    
    local typeNormalMode = 1
    local typeSelfAdaptiveMode = 2
    local typeEleSaveMode = 3

    local typeMode = typeSelfAdaptiveMode
    local bExist, strAdvanConfValue, nullpart1, nullpart2 = false, tostring(typeSelfAdaptiveMode)
    bExist, nullpart1, nullpart2, strAdvanConfValue = iniMgr:GetValueByName(strSecName, strKeyName, "")
    if bExist then
        LogInfo("____strAdvanConfValue: " .. strAdvanConfValue)
        typeMode = tonumber(strAdvanConfValue)
    else
        iniMgr:WriteValueByName(strSecName, strKeyName, tostring(typeMode))
    end

    local nDangwei = 4
    if typeMode == typeEleSaveMode then
        nDangwei = 1
    elseif typeMode == typeSelfAdaptiveMode then
       local typeDevice = CDeviceInfo:GetDeviceType()
       LogInfo("____typeDevice: " .. typeDevice)

       --ios device
       if typeDevice == 1 then
            local cpuCount = CDeviceInfo:GetCpuCount()
            local cpuFreq = CDeviceInfo:GetCpuFrequency()
            --local sizeMem = CDeviceInfo:GetTotalMemSize()
            if cpuCount >= 2 then
                if cpuFreq >= 900 then
                    nDangwei = 4
                else
                    nDangwei = 3
                end
            else
                nDangwei = 2
            end
                
       --android
       elseif typeDevice == 2 then
            local sizeMem = CDeviceInfo:GetTotalMemSize()
            local cpuCount = CDeviceInfo:GetCpuCount()
            local cpuMaxFreq = CDeviceInfo:GetMaxCpuFreq()
            
            --we think exception happened, so handle it for normal device
            if sizeMem <= 0 or cpuCount <= 0 or cpuMaxFreq <= 0 then
                nDangwei = 2
            else
                if sizeMem <= 600 then
                    nDangwei = 1
                elseif cpuCount >= 4 then
                    nDangwei = 4
                elseif cpuCount >= 2 then
                    nDangwei = 3
                else
                    if cpuMaxFreq > 1200 then
                        nDangwei = 2
                    else
                        nDangwei = 1
                    end
                end
            end
       end
    end
    
    local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.systemsetting.cgaojishezhi")
    local record = tt:getRecorder(nDangwei)
    
    local numMaxShow = 20
    LogInfo("____nDangwei" .. nDangwei)
    if record ~= nil and record.id ~= -1 and record.tongping ~= nil then
        LogInfo("____record.tongping: " .. record.tongping)
        
        numMaxShow = record.tongping
    else
        LogInfo("____record==nil or record.tongping==nil")
    end
    
    return numMaxShow
end

function AdvanSettingDlg.SendMaxPlayerNum()
    LogInfo("____AdvanSettingDlg.SendMaxPlayerNum")
    
    local numMaxShow = AdvanSettingDlg.GetMaxDisplayPlayerNum()
    
    if numMaxShow == nil then
        LogInfo("___error when get numMaxShow")
        numMaxShow = 20
    end
    
    LogInfo("____numMaxShow: " .. numMaxShow)
    
    local setMaxShowNumAction = CAutoSetMaxShowNum2.Create()
    setMaxShowNumAction.maxshownum = numMaxShow
    LuaProtocolManager.getInstance():send(setMaxShowNumAction)
end

function AdvanSettingDlg.peekInstance()
	return _instance
end

function AdvanSettingDlg.getInstance()
	LogInfo("____AdvanSettingDlg.getInstance")
    if not _instance then
        _instance = AdvanSettingDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function AdvanSettingDlg.getInstanceAndShow()
	LogInfo("____AdvanSettingDlg.getInstanceAndShow")
    if not _instance then
        _instance = AdvanSettingDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set visible")
		_instance:SetVisible(true)
    end
    
    if not SettingMainFrame.peekInstance() then
        SettingMainFrame.getInstanceAndShow()
    end

    return _instance
end

function AdvanSettingDlg:SetVisible(bV)
	if bV == self.m_pMainFrame:isVisible() then
        return
    end
	self.m_pMainFrame:setVisible(bV);
	if bV and not SettingMainFrame.peekInstance() then
		SettingMainFrame.getInstanceAndShow()	
	end
end

function AdvanSettingDlg.getInstanceNotCreate()
    return _instance
end

function AdvanSettingDlg.DestroyDialog()
	LogInfo("____AdvanSettingDlg.DestroyDialog")
    if _instance then
		_instance:OnClose()
		_instance = nil
	end
    
    if SettingMainFrame:peekInstance() then
		SettingMainFrame.DestroyDialog()
	end
end

function AdvanSettingDlg.hasCreatedAndShow()
    --LogInfo("AdvanSettingDlg.hasCreatedAndShow?")
    
    if _instance then
        if _instance:IsVisible() then
            return 1
        else
            return 0
        end
    else
        return 0
    end
end

function AdvanSettingDlg.ToggleOpenClose()
	if not _instance then 
		_instance = AdvanSettingDlg:new() 
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

function AdvanSettingDlg.GetLayoutFileName()
    return "systemsettingmore.layout"
end

function AdvanSettingDlg:new()
    LogInfo("____AdvanSettingDlg:new")
    
    local self = {}
    self = Dialog:new()
    setmetatable(self, AdvanSettingDlg)

    self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function AdvanSettingDlg:OnCreate()
	LogInfo("____enter AdvanSettingDlg:OnCreate")
    Dialog.OnCreate(self)

    self:GetWindow():setModalState(true)
    
    local winMgr = CEGUI.WindowManager:getSingleton()

    self.m_pRaioBtn1 = CEGUI.Window.toRadioButton(winMgr:getWindow("systemsettingmore/back/channel1"))
    self.m_pRaioBtn2 = CEGUI.Window.toRadioButton(winMgr:getWindow("systemsettingmore/back/channel2"))
    self.m_pRaioBtn3 = CEGUI.Window.toRadioButton(winMgr:getWindow("systemsettingmore/back/channel3"))
	self.m_pRaioBtn1:setGroupID(1)
    self.m_pRaioBtn2:setGroupID(1)
    self.m_pRaioBtn3:setGroupID(1)
	--self.m_pRaioBtn1:subscribeEvent("SelectStateChanged", AdvanSettingDlg.HandleSelectStateChanged, self)
	--self.m_pRaioBtn2:subscribeEvent("SelectStateChanged", AdvanSettingDlg.HandleSelectStateChanged, self)
    --self.m_pRaioBtn3:subscribeEvent("SelectStateChanged", AdvanSettingDlg.HandleSelectStateChanged, self)
    self.m_pBtnSave = CEGUI.Window.toPushButton(winMgr:getWindow("systemsettingmore/ok"))
    self.m_pBtnSave:subscribeEvent("Clicked", AdvanSettingDlg.HandleClickeSaveBtn, self)
    self:Refresh()

	LogInfo("____exit AdvanSettingDlg:OnCreate")
end

function AdvanSettingDlg:Refresh()
    LogInfo("____AdvanSettingDlg:Refresh")

    local strIniPath = ADVAN_SETTING_INFO_INI or "AdvanSettingInfo.ini"
    local strSecName = NAME_SECTION_ADVANSETTING or "AdvanSettingRecord"
    local strKeyName = NAME_KEY_ADVANSETTING or "advansettingvalue"
    
    local iniMgr = CIniManager(strIniPath)
    
    local typeMode = self.typeSelfAdaptiveMode
    local bExist, strAdvanConfValue, nullpart1, nullpart2 = false, tostring(self.typeSelfAdaptiveMode)
    bExist, nullpart1, nullpart2, strAdvanConfValue = iniMgr:GetValueByName(strSecName, strKeyName, "")
    if bExist then
        LogInfo("____strAdvanConfValue: " .. strAdvanConfValue)
        typeMode = tonumber(strAdvanConfValue)
    else
        iniMgr:WriteValueByName(strSecName, strKeyName, tostring(typeMode))
    end

    if typeMode == self.typeEleSaveMode then
        self.m_pRaioBtn3:setSelected(true)
    elseif typeMode == self.typeSelfAdaptiveMode then
        self.m_pRaioBtn2:setSelected(true)
    else
        self.m_pRaioBtn1:setSelected(true)
    end
end

function AdvanSettingDlg:HandleClickeSaveBtn(args)
    LogInfo("____AdvanSettingDlg:HandleClickeSaveBtn")
    
    local typeMode = self.typeNormalMode
    if self.m_pRaioBtn3:isSelected() then
        typeMode = self.typeEleSaveMode
    elseif self.m_pRaioBtn2:isSelected() then
        typeMode = self.typeSelfAdaptiveMode
    end
    
    local strIniPath = ADVAN_SETTING_INFO_INI or "AdvanSettingInfo.ini"
    local strSecName = NAME_SECTION_ADVANSETTING or "AdvanSettingRecord"
    local strKeyName = NAME_KEY_ADVANSETTING or "advansettingvalue"
    local iniMgr = CIniManager(strIniPath)
    
    LogInfo("____typeMode: " .. typeMode)

    iniMgr:WriteValueByName(strSecName, strKeyName, tostring(typeMode))
    
    AdvanSettingDlg.SendMaxPlayerNum()

    return true
end

return AdvanSettingDlg
