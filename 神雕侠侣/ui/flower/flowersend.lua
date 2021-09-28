--[[author: lvxiaolong
date: 2013/10/28
function: flower send dialog
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.ranklist.cgetrolename"
require "protocoldef.knight.gsp.ranklist.cgiverosenew"

FlowerSendDlg = {
    CT_FlowerSelType = 5,
}
setmetatable(FlowerSendDlg, Dialog)
FlowerSendDlg.__index = FlowerSendDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function FlowerSendDlg.IsShow()
    --LogInfo("FlowerSendDlg.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function FlowerSendDlg.getInstance()
	LogInfo("FlowerSendDlg.getInstance")
    if not _instance then
        _instance = FlowerSendDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function FlowerSendDlg.getInstanceAndShow()
	LogInfo("____FlowerSendDlg.getInstanceAndShow")
    if not _instance then
        _instance = FlowerSendDlg:new()
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

function FlowerSendDlg.getInstanceNotCreate()
    --print("FlowerSendDlg.getInstanceNotCreate")
    return _instance
end

function FlowerSendDlg.DestroyDialog()
	if _instance then
		_instance:OnClose() 
		_instance = nil
	end
end

function FlowerSendDlg.ToggleOpenClose()
	if not _instance then 
		_instance = FlowerSendDlg:new() 
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

function FlowerSendDlg.GetLayoutFileName()
    return "flowersend.layout"
end

function FlowerSendDlg:OnCreate()
	LogInfo("enter FlowerSendDlg oncreate")

    Dialog.OnCreate(self)
    --self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    
    self.m_txtRoleNameSendTo = winMgr:getWindow("FlowerSend/Back/Name")
    self.m_txtRoleNameSendTo:setText("")

    self.m_eBoxRoleIDSendTo = CEGUI.toEditbox(winMgr:getWindow("FlowerSend/Back/ID"))
    -- Modify by wuyao, roleid max is 9223372036854775807(19 numbers)
    -- Set the max length 18 to limit
    -- Set SetOnlyNumberMode() max_number is -1, the editbox will ignore the max_number
    -- self.m_eBoxRoleIDSendTo:SetOnlyNumberMode(true, 999999999)
    self.m_eBoxRoleIDSendTo:SetOnlyNumberMode(true, -1)
    self.m_eBoxRoleIDSendTo:setMaxTextLength(18)
    -- end modify by wuyao
    self.m_eBoxRoleIDSendTo:setText(0)
    
    self.m_btnSearchFromRoleID = CEGUI.Window.toPushButton(winMgr:getWindow("FlowerSend/search"))
    self.m_btnSearchFromRoleID:subscribeEvent("Clicked", FlowerSendDlg.HandleClickSearchBtn, self)

    self.m_arrImageBtnSelType = {}
    for i = 1, self.CT_FlowerSelType, 1 do
        self.m_arrImageBtnSelType[i] = CEGUI.Window.toPushButton(winMgr:getWindow("FlowerSend/Back/Num" .. i))
        self.m_arrImageBtnSelType[i]:setID(i)
        self.m_arrImageBtnSelType[i]:subscribeEvent("Clicked", FlowerSendDlg.HandleClickSelTypeBtn, self)
    end
    
    self.m_eBoxNumSendFlower = CEGUI.toEditbox(winMgr:getWindow("FlowerSend/Back/EditBox"))
    -- Modify by wuyao, roleid max is 9223372036854775807(19 numbers)
    -- Set the max length 18 to limit
    -- Set SetOnlyNumberMode() max_number is -1, the editbox will ignore the max_number
    -- self.m_eBoxRoleIDSendTo:SetOnlyNumberMode(true, 999999999)
    self.m_eBoxNumSendFlower:SetOnlyNumberMode(true, -1)
    self.m_eBoxNumSendFlower:setMaxTextLength(18)
    -- end modify by wuyao
    self.m_eBoxNumSendFlower:setText(1)

    self.m_reBoxFlowerWord = CEGUI.Window.toRichEditbox(winMgr:getWindow("FlowerSend/Back/Send1/Word"))
    self.m_reBoxFlowerWord:setMaxTextLength(19)
    self.m_reBoxFlowerWord:Clear()
    self.m_reBoxFlowerWord:Refresh()

    self.m_radioBtnOpenSendType = CEGUI.Window.toRadioButton(winMgr:getWindow("FlowerSend/Back/Back/Name"))
    self.m_radioBtnAnonySendType = CEGUI.Window.toRadioButton(winMgr:getWindow("FlowerSend/Back/Back/NoName"))
    self.m_radioBtnOpenSendType:setGroupID(1)
    self.m_radioBtnAnonySendType:setGroupID(1)
    self.m_radioBtnOpenSendType:setSelected(true)

    self.m_btnSendFlower = CEGUI.Window.toPushButton(winMgr:getWindow("FlowerSend/Back/Ok"))
    self.m_btnSendFlower:subscribeEvent("Clicked", FlowerSendDlg.HandleClickSendFlowerBtn, self)

	LogInfo("exit FlowerSendDlg OnCreate")
end

function FlowerSendDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, FlowerSendDlg)
    
    --self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    --self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function FlowerSendDlg.SetPlayerSendToAndShow(roleid, rolename)
    LogInfo("____FlowerSendDlg.SetPlayerSendToAndShow")
    
    local dlgFlowerSend = FlowerSendDlg.getInstanceNotCreate()

    if not dlgFlowerSend then
        dlgFlowerSend = FlowerSendDlg.getInstanceAndShow()
        
        if dlgFlowerSend then
            dlgFlowerSend:SetPlayerSendTo(roleid, rolename)
        else
            print("____error no FlowerSendDlg.getInstanceAndShow")
        end
    else
        dlgFlowerSend:RefreshPlayerNameSendTo(roleid, rolename)
    end
end

function FlowerSendDlg:SetPlayerSendTo(roleid, rolename)
    LogInfo("____FlowerSendDlg:SetPlayerSendTo")
    
    if roleid and roleid > 0 then
        print("____roleid: " .. roleid)
        self.m_eBoxRoleIDSendTo:setText(roleid)
    else
        self.m_eBoxRoleIDSendTo:setText(0)
    end
    if rolename and roleid and roleid > 0 then
        print("____rolename: " .. rolename)
        self.m_txtRoleNameSendTo:setText(rolename)
    else
        self.m_txtRoleNameSendTo:setText("")
    end
end

function FlowerSendDlg:RefreshPlayerNameSendTo(roleid, rolename)
    LogInfo("____FlowerSendDlg:RefreshPlayerNameSendTo")
    
    local strID = self.m_eBoxRoleIDSendTo:getText()
    local curRoleid = 0
    if strID and strID ~= "" then
        curRoleid = tonumber(self.m_eBoxRoleIDSendTo:getText())
    end

    if curRoleid and curRoleid > 0 and roleid and roleid == curRoleid and rolename then
        print("____roleid: " .. roleid)
        self.m_txtRoleNameSendTo:setText(rolename)
    end
end

function FlowerSendDlg:HandleClickSearchBtn(args)
    LogInfo("____FlowerSendDlg:HandleClickSearchBtn")
    
    self.m_txtRoleNameSendTo:setText("")

    local roleid = tonumber(self.m_eBoxRoleIDSendTo:getText())
    
    if roleid and roleid > 0 then
        local getRoleNameAction = CGetRoleName.Create()
        getRoleNameAction.roleid = roleid
        LuaProtocolManager.getInstance():send(getRoleNameAction)
    end

    return true
end

function FlowerSendDlg:HandleClickSelTypeBtn(args)
    LogInfo("____FlowerSendDlg.HandleClickSelTypeBtn")
    
    local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
    
    if id == 1 then
        self.m_eBoxNumSendFlower:setText(1)
    elseif id == 2 then
        self.m_eBoxNumSendFlower:setText(11)
    elseif id == 3 then
        self.m_eBoxNumSendFlower:setText(99)
    elseif id == 4 then
        self.m_eBoxNumSendFlower:setText(365)
    elseif id == 5 then
        self.m_eBoxNumSendFlower:setText(999)
    else
        print("____error id")
    end

    return true
end

function FlowerSendDlg:HandleSendConfirmClicked(args)
    LogInfo("____FlowerSendDlg:HandleSendConfirmClicked")
    
    GetMessageManager():CloseConfirmBox(eConfirmNormal,false)

    local recieverroleid = 0
    local strID = self.m_eBoxRoleIDSendTo:getText()
    if strID and strID ~= "" then
        recieverroleid = tonumber(strID)
    end
    local rosenum = 0
    local strNum = self.m_eBoxNumSendFlower:getText()
    if strNum and strNum ~= "" then
        rosenum = tonumber(strNum)
    end

    if not recieverroleid or recieverroleid <= 0 then
        return true
    end
    
    if not rosenum or rosenum <= 0 then
        return true
    end
    
    local message = self.m_reBoxFlowerWord:GetPureText()
    
    if not message then
        message = ""
    end

    local pubgive = 1
    if self.m_radioBtnAnonySendType:isSelected() then
        pubgive = 0
    end
    
    print("____recieverroleid: " .. recieverroleid)
    print("____rosenum: " .. rosenum)
    print("____pubgive: " .. pubgive)
    print("____message: " .. message)

    local giveRoseAction = CGiveRoseNew.Create()
    giveRoseAction.recieverroleid = recieverroleid
    giveRoseAction.rosenum = rosenum
    giveRoseAction.pubgive = pubgive
    giveRoseAction.message = message
    LuaProtocolManager.getInstance():send(giveRoseAction)
    
    FlowerSendDlg.DestroyDialog()

    return true
end

function FlowerSendDlg:HandleClickSendFlowerBtn(args)
    LogInfo("____FlowerSendDlg:HandleClickSendFlowerBtn")

    local recieverroleid = 0
    local strID = self.m_eBoxRoleIDSendTo:getText()
    if strID and strID ~= "" then
        recieverroleid = tonumber(strID)
    end
    local rosenum = 0
    local strNum = self.m_eBoxNumSendFlower:getText()
    if strNum and strNum ~= "" then
        rosenum = tonumber(strNum)
    end

    if not recieverroleid or recieverroleid <= 0 then
        GetGameUIManager():AddMessageTipById(145340)
        return true
    end
    
    if not rosenum or rosenum <= 0 then
        GetGameUIManager():AddMessageTipById(142792)
        return true
    end
    
    local message = self.m_reBoxFlowerWord:GetPureText()
    
    if not message then
        message = ""
    end

    local hasShieldText, strAfterShield = MHSD_UTILS.ShiedText(message)
    
    if hasShieldText then
        GetGameUIManager():AddMessageTipById(145319)
        return true
    end
    
    local pubgive = 1
    if self.m_radioBtnAnonySendType:isSelected() then
        pubgive = 0
    end
    
    print("____recieverroleid: " .. recieverroleid)
    print("____rosenum: " .. rosenum)
    print("____pubgive: " .. pubgive)
    print("____message: " .. message)

    local idTitle = 0
    if rosenum >= 999 then
        if message == "" then
            idTitle = 145315
        else
            idTitle = 145316
        end
    else
       if message ~= "" then
            idTitle = 145317
       end
    end
    
    if idTitle > 0 then
    GetMessageManager():AddConfirmBox(eConfirmNormal,MHSD_UTILS.get_msgtipstring(idTitle),FlowerSendDlg.HandleSendConfirmClicked,self,CMessageManager.HandleDefaultCancelEvent,CMessageManager)
    
        return true
    
    end

    local giveRoseAction = CGiveRoseNew.Create()
    giveRoseAction.recieverroleid = recieverroleid
    giveRoseAction.rosenum = rosenum
    giveRoseAction.pubgive = pubgive
    giveRoseAction.message = message
    LuaProtocolManager.getInstance():send(giveRoseAction)
    
    FlowerSendDlg.DestroyDialog()

    return true
end


return FlowerSendDlg
