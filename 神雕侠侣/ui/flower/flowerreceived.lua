--[[author: lvxiaolong
date: 2013/10/29
function: flower received dialog
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.ranklist.crosethanks"

FlowerReceivedDlg = {
    m_senderroleid = 0,
    m_rolename = "",
    m_rosenum = 1,
}
setmetatable(FlowerReceivedDlg, Dialog)
FlowerReceivedDlg.__index = FlowerReceivedDlg 

g_arrInfoFlowerReceive = {}

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function FlowerReceivedDlg.IsShow()
    --LogInfo("FlowerReceivedDlg.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function FlowerReceivedDlg.getInstance()
	LogInfo("FlowerReceivedDlg.getInstance")
    if not _instance then
        _instance = FlowerReceivedDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function FlowerReceivedDlg.AddFlowerReceiveInfo(senderroleid, rolename, rosenum)
    LogInfo("____FlowerReceivedDlg.AddFlowerReceiveInfo")
    
    if senderroleid and senderroleid > 0 and rolename and rosenum then
        local index = #g_arrInfoFlowerReceive+1
        g_arrInfoFlowerReceive[index] = {}
        g_arrInfoFlowerReceive[index].senderroleid = senderroleid
        g_arrInfoFlowerReceive[index].rolename = rolename
        g_arrInfoFlowerReceive[index].rosenum = rosenum
        
        if index == 1 then
            local dlgReceive = FlowerReceivedDlg.getInstanceAndShow()
            if dlgReceive then
                dlgReceive:SetReceiveInfo(senderroleid, rolename, rosenum)
            else
                print("____error not get FlowerReceivedDlg.getInstanceAndShow")
            end
        end
        
        local dlgReceiveReg = FlowerReceivedDlg.getInstanceNotCreate()
        if not dlgReceiveReg and g_arrInfoFlowerReceive[1] then
            print("____error not dlgReceiveReg")
            dlgReceiveReg = FlowerReceivedDlg.getInstanceAndShow()
            if dlgReceiveReg then
                local firstInfo = g_arrInfoFlowerReceive[1]
                dlgReceiveReg:SetReceiveInfo(firstInfo.senderroleid, firstInfo.rolename, firstInfo.rosenum)
            else
                print("____error not get FlowerReceivedDlg.getInstanceAndShow")
            end
        end
    else
        print("____error not correct when addflowerreceive info")
    end
end

function FlowerReceivedDlg.getInstanceAndShow()
	LogInfo("____FlowerReceivedDlg.getInstanceAndShow")
    if not _instance then
        _instance = FlowerReceivedDlg:new()
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

function FlowerReceivedDlg.getInstanceNotCreate()
    --print("FlowerReceivedDlg.getInstanceNotCreate")
    return _instance
end

function FlowerReceivedDlg.DestroyDialog()
	if _instance then
		_instance:OnClose() 
		_instance = nil
	end
end

function FlowerReceivedDlg:PopReceiveInfo()
    local numOld = #g_arrInfoFlowerReceive
    for i = 2, numOld, 1 do
        g_arrInfoFlowerReceive[i-1] = g_arrInfoFlowerReceive[i]
    end
    if numOld >= 1 then
        g_arrInfoFlowerReceive[numOld] = nil
    end

    local numNew = numOld-1
    if numNew <= 0 then
        FlowerReceivedDlg.DestroyDialog()
    else
        local curInfo = g_arrInfoFlowerReceive[1]
        if curInfo then
            self:SetReceiveInfo(curInfo.senderroleid, curInfo.rolename, curInfo.rosenum)
        else
            print("____error when get curInfo")
            FlowerReceivedDlg.DestroyDialog()
        end
    end
end

function FlowerReceivedDlg:HandleCloseBtnClick(args)
    LogInfo("____FlowerReceivedDlg:HandleCloseBtnClick")
    
    self:PopReceiveInfo()
    return true
end

function FlowerReceivedDlg.ToggleOpenClose()
	if not _instance then 
		_instance = FlowerReceivedDlg:new() 
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

function FlowerReceivedDlg.GetLayoutFileName()
    return "flowerreceived.layout"
end

function FlowerReceivedDlg:OnCreate()
	LogInfo("enter FlowerReceivedDlg oncreate")

    Dialog.OnCreate(self)
    --self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    
    self.m_txtRoleNameSender = winMgr:getWindow("flowerreceived/Flower/Name")
    self.m_txtNumFlower = winMgr:getWindow("flowerreceived/Flower/Num")
    self.m_btnChat = CEGUI.Window.toPushButton(winMgr:getWindow("flowerreceived/Flower/Chat"))
    self.m_btnThank = CEGUI.Window.toPushButton(winMgr:getWindow("flowerreceived/Flower/TK"))
    self.m_btnChat:subscribeEvent("Clicked", FlowerReceivedDlg.HandleClickChatBtn, self)
    self.m_btnThank:subscribeEvent("Clicked", FlowerReceivedDlg.HandleClickThankBtn, self)
    
    self:ClearCurInfo()

	LogInfo("exit FlowerReceivedDlg OnCreate")
end

function FlowerReceivedDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FlowerReceivedDlg)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function FlowerReceivedDlg:ClearCurInfo()
    LogInfo("____FlowerReceivedDlg:ClearCurInfo")
    
    self.m_senderroleid = 0
    self.m_rolename = ""
    self.m_rosenum = 1
    self.m_txtRoleNameSender:setText("")
    self.m_txtNumFlower:setText("1")
end

function FlowerReceivedDlg:SetReceiveInfo(senderroleid, rolename, rosenum)
    LogInfo("____FlowerReceivedDlg:SetReceiveInfo")
    
    if senderroleid and senderroleid > 0 and rolename and rosenum > 0 then
        print("____senderroleid: " .. senderroleid)
        print("____rolename: " .. rolename)
        print("____rosenum: " .. rosenum)
        
        self.m_senderroleid = senderroleid
        self.m_rolename = rolename
        self.m_rosenum = rosenum
        self.m_txtRoleNameSender:setText(rolename)
        self.m_txtNumFlower:setText(tostring(rosenum))
    else
        print("____error when set receive info")
        self:ClearCurInfo()
    end
end

function FlowerReceivedDlg:HandleClickChatBtn(args)
    LogInfo("____FlowerReceivedDlg:HandleClickChatBtn")
        
    if self.m_senderroleid > 0 and GetFriendsManager() then
        GetFriendsManager():SetContactRole(self.m_senderroleid,"",-1,0,false)
        GetFriendsManager():SetChatRoleID(self.m_senderroleid, "")
    else
        print("____error self.m_senderroleid <= 0 or not GetFriendsManager")
    end

    self:PopReceiveInfo()

    return true
end

function FlowerReceivedDlg:HandleClickThankBtn(args)
    LogInfo("____FlowerReceivedDlg:HandleClickThankBtn")
    
    if self.m_senderroleid and self.m_senderroleid > 0 then
        local thankAction = CRoseThanks.Create()
        thankAction.senderroleid = self.m_senderroleid
        thankAction.thankstype = 1
        LuaProtocolManager.getInstance():send(thankAction)
    else
        print("____error not effective self.m_senderroleid")
    end

    self:PopReceiveInfo()

    return true
end

return FlowerReceivedDlg




