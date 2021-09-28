--[[author: lvxiaolong
date: 2013/5/30
function: battle reward ui
]]

require "ui.dialog"
require "utils.mhsdutils"


BattleRewardDlg = {}
setmetatable(BattleRewardDlg, Dialog)
BattleRewardDlg.__index = BattleRewardDlg 

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance
local maxTimeDisplayBReward = 10

function BattleRewardDlg.getInstance()
	LogInfo("BattleRewardDlg.getInstance")
    if not _instance then
        _instance = BattleRewardDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function BattleRewardDlg.getInstanceAndShow()
	LogInfo("BattleRewardDlg.getInstanceAndShow")
    if not _instance then
        _instance = BattleRewardDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end

    _instance.m_fLeftTime = maxTimeDisplayBReward
    return _instance
end

function BattleRewardDlg.getInstanceNotCreate()
    --print("BattleRewardDlg.getInstanceNotCreate")
    return _instance
end

function BattleRewardDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose() 
		_instance = nil
	end
end

function BattleRewardDlg.ToggleOpenClose()
	if not _instance then 
		_instance = BattleRewardDlg:new() 
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

function BattleRewardDlg.GetLayoutFileName()
    return "battlerewarddlg.layout"
end

function BattleRewardDlg:OnCreate()
	LogInfo("enter BattleRewardDlg oncreate")
    
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows

    self.m_iconWndRoleHead = winMgr:getWindow("battlerewarddlg/userback/icon")
    self.m_txtWndRoleExp = winMgr:getWindow("battlerewarddlg/exp1")
    --self.m_txtWndRoleExp:setMaxTextLength(7)

    self.m_iconWndPetHead = winMgr:getWindow("battlerewarddlg/petback/icon")
    self.m_txtWndPetExp = winMgr:getWindow("battlerewarddlg/exp2")
    --self.m_txtWndPetExp:setMaxTextLength(7)

    self.m_txtWndCtDown = winMgr:getWindow("battlerewarddlg/second")
    self:GetWindow():subscribeEvent("WindowUpdate", BattleRewardDlg.HandleWindowUpdate, self)
    self.m_fLeftTime = maxTimeDisplayBReward

    self.m_txtWndSilverNum = winMgr:getWindow("battlerewarddlg/yinliangback/num")
    --self.m_txtWndSilverNum:setMaxTextLength(7)

    self.m_scrollItemList = CEGUI.Window.toScrollablePane(winMgr:getWindow("battlerewarddlg/scroll"))
    
    self.m_closeBtnMine = CEGUI.Window.toPushButton(winMgr:getWindow("battlerewarddlg/closed"))
    self.m_closeBtnMine:subscribeEvent("Clicked", BattleRewardDlg.HandleCloseBtnMineClicked, self)
    
	LogInfo("exit BattleRewardDlg OnCreate")
end

function BattleRewardDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, BattleRewardDlg)
    
    self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1

    return self
end

function BattleRewardDlg:HandleWindowUpdate(eventArgs)
    
    self.m_fLeftTime = self.m_fLeftTime or maxTimeDisplayBReward
    
    self.m_fLeftTime = self.m_fLeftTime - CEGUI.toUpdateEventArgs(eventArgs).d_timeSinceLastFrame
    if self.m_fLeftTime > 0 then
        self.m_txtWndCtDown:setText(tostring(1+math.floor(self.m_fLeftTime)))
    else
        self.m_fLeftTime = maxTimeDisplayBReward
        BattleRewardDlg.DestroyDialog()
    end

    return true

end

function BattleRewardDlg:RefreshInfo(roleExp, petExp, silverNum, itemList)
    self:RefreshExpSilverInfo(roleExp, petExp, silverNum)
    self:RefreshScrollItemList(itemList)
end

function BattleRewardDlg:RefreshExpSilverInfo(roleExp, petExp, silverNum)
   
   LogInfo("_______BattleRewardDlg:RefreshExpSilverInfo")
   
   local mainChrShape = GetDataManager():GetMainCharacterShape()
   if mainChrShape then
        LogInfo("______get main ChrShape, roleExp: " .. roleExp)
        local mainChrShapeReal = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(mainChrShape)
        
        if mainChrShapeReal then
            local iconPathMainChr = GetIconManager():GetImagePathByID(mainChrShapeReal.headID):c_str()
            self.m_iconWndRoleHead:setVisible(true)
            self.m_iconWndRoleHead:setProperty("Image", iconPathMainChr)
            self.m_txtWndRoleExp:setText(tostring(roleExp))
        else
           self.m_iconWndRoleHead:setVisible(false)
           self.m_txtWndRoleExp:setText("") 
        end
   else
        LogInfo("______not get main chr shape, roleExp: " .. roleExp)
        self.m_iconWndRoleHead:setVisible(false)
        self.m_txtWndRoleExp:setText("") 
   end
   
   local battlePet = GetDataManager():GetBattlePet()
   if battlePet then
        LogInfo("______get battle pet, petExp: " .. petExp)

        local shapeid = battlePet:GetShapeID()
        local headshape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(shapeid)
        
        if headshape then
            local path = GetIconManager():GetImagePathByID(headshape.headID):c_str()
            self.m_iconWndPetHead:setProperty("Image", path)
            self.m_txtWndPetExp:setText(tostring(petExp))
        else
            self.m_iconWndPetHead:setProperty("Image", "set:MainControl image:Head")
            self.m_txtWndPetExp:setText("")
        end
   else
        LogInfo("______not get battle pet, petExp: " .. petExp)
        self.m_iconWndPetHead:setProperty("Image", "set:MainControl image:Head")
        self.m_txtWndPetExp:setText("")
   end
    
    LogInfo("______silverNum: " .. silverNum)

    self.m_txtWndSilverNum:setText(tostring(silverNum))

    --print the exp silver reward message
    local strbuilder = StringBuilder:new()
    local strMsg = ""
    if roleExp > 0 then
        strbuilder:SetNum("parameter1", roleExp)
        strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144958))
        if GetChatManager() then
            GetChatManager():AddMessageMsg(strMsg, true)
        end
    end

    if petExp > 0 then
        strbuilder:SetNum("parameter1", petExp)
        strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144959))
        if GetChatManager() then
            GetChatManager():AddMessageMsg(strMsg, true)
        end
    end

    if silverNum > 0 then
        strbuilder:SetNum("parameter1", silverNum)
        strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144960))
        if GetChatManager() then
            GetChatManager():AddMessageMsg(strMsg, true)
        end
    end

    strbuilder:delete()
end

function BattleRewardDlg:RefreshScrollItemList(itemList)
  LogInfo("BattleRewardDlg:RefreshScrollItemList")
  
  self.m_scrollItemList:cleanupNonAutoChildren()
  
  LogInfo("_____itemList num: " .. #itemList)

  local strbuilder = StringBuilder:new()
  local strMsg = ""

  local index = 0
  for i,v in pairs(itemList) do
      local itemReg = v
      LogInfo("itemID: " .. tostring(itemReg.itemid))
      
      local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(itemReg.itemid)
      
      if itembean.id ~= -1 then
        local itemName = itembean.name
        local itemCount = itemReg.itemnumber
        local namePrefix = tostring(itembean.id)
        local winMgr = CEGUI.WindowManager:getSingleton()
        local rootWnd = winMgr:loadWindowLayout("battlerewarddlgcell.layout",namePrefix)
        
        --print the item reward message
        if itemCount > 0 then
            strbuilder:Set("parameter1", itemName)
            strbuilder:SetNum("parameter2", itemCount)
            strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144961))
            if GetChatManager() then
                GetChatManager():AddMessageMsg(strMsg, true)
            end
        end

        LogInfo("____item i: " .. i .. ", item id: " .. itembean.id)

        if rootWnd then
            LogInfo("_____get rootwnd: " .. namePrefix .. "battlerewarddlgcell.layout")
            
            index = index + 1
            self.m_scrollItemList:addChildWindow(rootWnd)
            local height=rootWnd:getPixelSize().height
            LogInfo("height:"..tostring(height))
            local yPos=1.0+(height+5.0)*(index-1)
            local xPos=1.0
            rootWnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0.0,xPos),CEGUI.UDim(0.0,yPos)))
               
            local headWndName = namePrefix .. "battlerewarddlgcell/item"
            local headWnd = CEGUI.toItemCell(winMgr:getWindow(headWndName))
            if headWnd then
                headWnd:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
                headWnd:setID(itembean.id)
                headWnd:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
            end   

            local nameWndName = namePrefix .. "battlerewarddlgcell/name"
            local nameWnd = winMgr:getWindow(nameWndName)
            if nameWnd then
                --nameWnd:setMaxTextLength(9)
                --nameWnd:setText(itemName, CEGUI.PropertyHelper:stringToColour(itembean.colour):getARGB())
                nameWnd:setText(itemName)
                nameWnd:setProperty("TextColours", itembean.colour)
            end    

            local numWndName=namePrefix .. "battlerewarddlgcell/num"
            local numWnd=winMgr:getWindow(numWndName)
            if numWnd then
                --numWnd:setMaxTextLength(3)
                numWnd:setText(tostring(itemCount))
            end
        end
      end
  end
  
  strbuilder:delete()

end

function BattleRewardDlg:HandleCloseBtnMineClicked(args)
    BattleRewardDlg.DestroyDialog()
    return true
end

return BattleRewardDlg
