--[[author: lvxiaolong
date: 2013/10/29
function: flower thanks dialog
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"

FlowerThanksDlg = {

}
setmetatable(FlowerThanksDlg, Dialog)
FlowerThanksDlg.__index = FlowerThanksDlg 

g_arrInfoFlowerThanks = {}

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function FlowerThanksDlg.IsShow()
    --LogInfo("FlowerThanksDlg.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function FlowerThanksDlg.getInstance()
	LogInfo("FlowerThanksDlg.getInstance")
    if not _instance then
        _instance = FlowerThanksDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function FlowerThanksDlg.AddFlowerThanksInfo(roleshape, rolename)
    LogInfo("____FlowerThanksDlg.AddFlowerThanksInfo")
    
    if roleshape and roleshape > 0 and rolename then
        local index = #g_arrInfoFlowerThanks+1
        g_arrInfoFlowerThanks[index] = {}
        g_arrInfoFlowerThanks[index].roleshape = roleshape
        g_arrInfoFlowerThanks[index].rolename = rolename
        
        if index == 1 then
            local dlgThanks = FlowerThanksDlg.getInstanceAndShow()
            if dlgThanks then
                dlgThanks:SetThanksInfo(roleshape, rolename)
            else
                print("____error not get FlowerThanksDlg.getInstanceAndShow")
            end
        end
        
        local dlgThanksReg = FlowerThanksDlg.getInstanceNotCreate()
        if not dlgThanksReg and g_arrInfoFlowerThanks[1] then
            print("____error not dlgThanksReg")
            dlgThanksReg = FlowerThanksDlg.getInstanceAndShow()
            if dlgThanksReg then
                local firstInfo = g_arrInfoFlowerThanks[1]
                dlgThanksReg:SetThanksInfo(firstInfo.roleshape, firstInfo.rolename)
            else
                print("____error not get FlowerThanksDlg.getInstanceAndShow")
            end
        end
    else
        print("____error not correct when addflowerthanks info")
    end
end

function FlowerThanksDlg.getInstanceAndShow()
	LogInfo("____FlowerThanksDlg.getInstanceAndShow")
    if not _instance then
        _instance = FlowerThanksDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    if GetBattleManager() and GetBattleManager():IsInBattle() then
        _instance:SetVisible(false)
    else
        _instance:SetVisible(true)
    end

    return _instance
end

function FlowerThanksDlg.getInstanceNotCreate()
    --print("FlowerThanksDlg.getInstanceNotCreate")
    return _instance
end

function FlowerThanksDlg.DestroyDialog()
	if _instance then
		_instance:OnClose() 
		_instance = nil
	end
end

function FlowerThanksDlg:PopThanksInfo()
    local numOld = #g_arrInfoFlowerThanks
    for i = 2, numOld, 1 do
        g_arrInfoFlowerThanks[i-1] = g_arrInfoFlowerThanks[i]
    end
    if numOld >= 1 then
        g_arrInfoFlowerThanks[numOld] = nil
    end

    local numNew = numOld-1
    if numNew <= 0 then
        FlowerThanksDlg.DestroyDialog()
    else
        local curInfo = g_arrInfoFlowerThanks[1]
        if curInfo then
            self:SetThanksInfo(curInfo.roleshape, curInfo.rolename)
        else
            print("____error when get curInfo")
            FlowerThanksDlg.DestroyDialog()
        end
    end
end

function FlowerThanksDlg:HandleCloseBtnClick(args)
    LogInfo("____FlowerThanksDlg:HandleCloseBtnClick")
    
    self:PopThanksInfo()
    return true
end

function FlowerThanksDlg.ToggleOpenClose()
	if not _instance then 
		_instance = FlowerThanksDlg:new() 
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

function FlowerThanksDlg.GetLayoutFileName()
    return "flowerthanks.layout"
end

function FlowerThanksDlg:OnCreate()
	LogInfo("enter FlowerThanksDlg oncreate")

    Dialog.OnCreate(self)
    --self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    
    self.m_txtRoleName = winMgr:getWindow("flowerthanks/name")
    self.m_wndRoleHead = winMgr:getWindow("flowerthanks/head")
    self.m_btnOK = CEGUI.Window.toPushButton(winMgr:getWindow("flowerthanks/Flower/TK"))
    self.m_btnOK:subscribeEvent("Clicked", FlowerThanksDlg.HandleClickOKBtn, self)
    
    self:ClearCurInfo()

	LogInfo("exit FlowerThanksDlg OnCreate")
end

function FlowerThanksDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FlowerThanksDlg)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function FlowerThanksDlg:ClearCurInfo()
    LogInfo("____FlowerThanksDlg:ClearCurInfo")
    
    self.m_txtRoleName:setText("")
    self.m_wndRoleHead:setProperty("Image","")
end

function FlowerThanksDlg:SetThanksInfo(roleshape, rolename)
    LogInfo("____FlowerThanksDlg:SetThanksInfo")
    
    if roleshape and roleshape > 0 and rolename then
        print("____roleshape: " .. roleshape)
        print("____rolename: " .. rolename)
        
        self.m_txtRoleName:setText(rolename)
        
        local shapeTmp = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(roleshape)
        local strHead = ""
        if shapeTmp and shapeTmp.id ~= -1 then
           strHead = GetIconManager():GetImagePathByID(shapeTmp.headID):c_str()
        end
        self.m_wndRoleHead:setProperty("Image",strHead)

    else
        print("____error when set thanks info")
        self:ClearCurInfo()
    end
end

function FlowerThanksDlg:HandleClickOKBtn(args)
    LogInfo("____FlowerThanksDlg:HandleClickOKBtn")
        
    self:PopThanksInfo()

    return true
end

return FlowerThanksDlg




