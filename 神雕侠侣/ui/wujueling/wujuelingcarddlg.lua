--[[author: lvxiaolong
date: 2013/11/29
function: wu jue ling card dialog
]]

require "ui.dialog"
require "utils.mhsdutils"
require "manager.beanconfigmanager"
require "protocoldef.knight.gsp.npc.cdonefortunewheel"
require "protocoldef.knight.gsp.npc.cexitcopy"
require "ui.wujueling.wjlingcardfunc"

WujuelingCardDlg = {
    
    TOTAL_REWARD = 4,
    EXP_ITEMBASE = 50045,
    MONEY_ITEMBASE = 50046,

    eNoRotate = 0,
    eStartRotate = 1,
    eFaceRotate = 2,
    eStopRotate = 3,

    m_iResultIndex = -1,
    m_iLastPos = 0,
    m_bNormalExit = false,
    m_fLeftTime = 0,
    m_iSelectedCardID = -1,
    m_eRotateState = 0,
    m_fRotateTime = 0,
    m_pSelectedCard = nil,
    m_vCards = {},
    m_iNpcID = -1,
    m_iTaskID = -1,
    m_SelectCard = {itemtype = 1, id = 0, num = 0, times = 0,},
    m_NotSelectCard = {},
}

setmetatable(WujuelingCardDlg, Dialog)
WujuelingCardDlg.__index = WujuelingCardDlg 


------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance

function WujuelingCardDlg.SendExitCopy()
    local actionReg = CExitCopy.Create()
    LuaProtocolManager.getInstance():send(actionReg)
end

function WujuelingCardDlg.IsShow()
    --LogInfo("WujuelingCardDlg.IsShow")

    if _instance and _instance:IsVisible() then
        return true
    end

    return false
end

function WujuelingCardDlg.getInstance()
	LogInfo("WujuelingCardDlg.getInstance")
    if not _instance then
        _instance = WujuelingCardDlg:new()
        _instance:OnCreate()
    end

    return _instance
end

function WujuelingCardDlg.getInstanceAndShow()
	LogInfo("____WujuelingCardDlg.getInstanceAndShow")
    if not _instance then
        _instance = WujuelingCardDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function WujuelingCardDlg.getInstanceNotCreate()
    --print("WujuelingCardDlg.getInstanceNotCreate")
    return _instance
end

function WujuelingCardDlg.DestroyDialog()
	if _instance then
        if not _instance.m_bNormalExit then
            local actionReg = CDoneFortuneWheel.Create()
            actionReg.npckey = _instance.m_iNpcID
            actionReg.taskid = _instance.m_iTaskID
            actionReg.succ = 0
            actionReg.flag = 1
            LuaProtocolManager.getInstance():send(actionReg)
         end
		_instance:OnClose() 
		_instance = nil
	end
end

function WujuelingCardDlg.ToggleOpenClose()
	if not _instance then 
		_instance = WujuelingCardDlg:new() 
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

function WujuelingCardDlg.GetLayoutFileName()
    return "Pingfen.layout"
end

function WujuelingCardDlg:OnCreate()
	LogInfo("enter WujuelingCardDlg oncreate")

    Dialog.OnCreate(self)
    self:GetWindow():setModalState(true)

    local winMgr = CEGUI.WindowManager:getSingleton()
    --get windows
    
    self.m_vCards = {}
    for i = 1, self.TOTAL_REWARD, 1 do
        self.m_vCards[i] = lua_CardUnit.New()

        self.m_vCards[i].pBack = CEGUI.Window.toPushButton(winMgr:getWindow("Pingfen/cell" .. (i-1)))
        self.m_vCards[i].pBack:setID(i)
        self.m_vCards[i].pBack:subscribeEvent("Clicked", WujuelingCardDlg.HandleCardBtnClicked, self)
        
        self.m_vCards[i].pItemCell = CEGUI.toItemCell(winMgr:getWindow("Pingfen/cell/item" .. (i-1)))
        self.m_vCards[i].pItemCell:setMousePassThroughEnabled(true)

        self.m_vCards[i].pItemName = winMgr:getWindow("Pingfen/cell/name" .. (i-1))
        self.m_vCards[i].pItemName:setMousePassThroughEnabled(true)
        lua_CardUnit.InitTurnBack(self.m_vCards[i])

        self.m_vCards[i].pItemLight = winMgr:getWindow("Pingfen/cell/light" .. (i-1))
        self.m_vCards[i].pItemLight:setMousePassThroughEnabled(true)
		
		self.m_vCards[i].pEffectFanpai = winMgr:getWindow("Pingfen/effetfanpai" .. (i-1))
		self.m_vCards[i].pEffectFanpai:setMousePassThroughEnabled(true)
    end

    self.m_pLevelImage = winMgr:getWindow("Pingfen/level")
    self.m_pLevelText = winMgr:getWindow("Pingfen/text3")

    self.m_pExp = winMgr:getWindow("Pingfen/text5")
    self.m_pLeftSec = winMgr:getWindow("Pingfen/text6")

    self.m_pExitBtn = CEGUI.Window.toPushButton(winMgr:getWindow("Pingfen/mid1/btn"))
    self.m_pExitBtn:setVisible(false);
    self.m_pExitBtn:subscribeEvent("Clicked", WujuelingCardDlg.HandleExitBtnClicked, self)
    
    self:GetWindow():subscribeEvent("WindowUpdate", WujuelingCardDlg.HandleWindowUpdate, self)
    
    LogInfo("exit WujuelingCardDlg OnCreate")
end

function WujuelingCardDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WujuelingCardDlg)
    
    self.m_eDialogType[DialogTypeTable.eDlgTypeBattleClose] = 1
    self.m_eDialogType[DialogTypeTable.eDlgTypeInScreenCenter] = 1
    self.m_eDialogType[DialogTypeTable.eDlgTypeMapChangeClose] = 1

    return self
end

function WujuelingCardDlg:InitScore(grade, score)
    self.m_pExp:setText(tostring(score))

    local PingJi = knight.gsp.task.GetCWujuepingjiTableInstance():getRecorder(grade)
    if PingJi and PingJi.id == -1 then
        return
    end

    self.m_pLevelImage:setProperty("Image", PingJi.tubiaolujing)
    self.m_pLevelText:setText(PingJi.level)
end

function WujuelingCardDlg:HandleCardBtnClicked(eventArgs)
    LogInfo("____WujuelingCardDlg:HandleCardBtnClicked")
    
    local args = CEGUI.toMouseEventArgs(eventArgs)
    
    if self.m_iSelectedCardID == -1 then
        self.m_iSelectedCardID = args.window:getID()
        self.m_pSelectedCard = args.window
        --self.m_pSelectedCard:setProperty("AutoRenderingSurface", "true")
		self.m_pSelectedCard:setVisible(false)

        self.m_eRotateState = self.eStartRotate
        self.m_fRotateTime = 0
		GetGameUIManager():AddUIEffect(self.m_vCards[self.m_iSelectedCardID].pEffectFanpai, MHSD_UTILS.get_effectpath(10450), false)
    end

    return true
end

function WujuelingCardDlg:DoWhenNotifiedByEffect()
    self.m_pExitBtn:setVisible(true)

    self.m_bNormalExit = true
    
    local actionReg = CDoneFortuneWheel.Create()
    actionReg.npckey = self.m_iNpcID
    actionReg.taskid = self.m_iTaskID
    actionReg.succ = 1
    actionReg.flag = 1
    LuaProtocolManager.getInstance():send(actionReg)
end

function WujuelingCardDlg:HandleExitBtnClicked(eventArgs)

    WujuelingCardDlg.SendExitCopy()
    WujuelingCardDlg.DestroyDialog()

    return true
end

function WujuelingCardDlg:HandleWindowUpdate(eventArgs)
    
    local args = CEGUI.toUpdateEventArgs(eventArgs)

    self.m_fLeftTime = self.m_fLeftTime + args.d_timeSinceLastFrame

    if self.m_fLeftTime >= 15 then
        WujuelingCardDlg.DestroyDialog()
        return true
    else
        local leftSecReg = 15 - math.floor(self.m_fLeftTime)
        self.m_pLeftSec:setText(tostring(leftSecReg))
    end


    if self.m_eRotateState == self.eStartRotate then
        if self.m_pSelectedCard and self.m_fRotateTime <= 0.5 then
            self.m_fRotateTime = self.m_fRotateTime + args.d_timeSinceLastFrame
        else
            self.m_eRotateState = self.eFaceRotate
            self.m_fRotateTime = 0
            self:InitCard(self.m_iSelectedCardID, self.m_SelectCard.itemtype, self.m_SelectCard.id, self.m_SelectCard.num, self.m_SelectCard.times)
            
            --设置选中图片效果
            self.m_vCards[self.m_iSelectedCardID].pItemLight:setProperty("Image", "set:MainControl1 image:Pokerlight")
            lua_CardUnit.TurnBack(self.m_vCards[self.m_iSelectedCardID])
        end
    end

    if self.m_eRotateState == self.eFaceRotate then
        if self.m_pSelectedCard and self.m_fRotateTime <= 0.75 then
            self.m_fRotateTime = self.m_fRotateTime + args.d_timeSinceLastFrame
        else
            local pos = 1
            
            --翻开余下的牌
            --print("____WujuelingCardDlg:HandleWindowUpdate: self.m_eRotateState == self.eFaceRotate")
            for i = 1, self.TOTAL_REWARD, 1 do
                if i ~= self.m_iSelectedCardID then
                    
                    --[[print("____pos: " .. pos)
                    print("____itemtype: " .. self.m_NotSelectCard[pos].itemtype)
                    print("____id: " .. self.m_NotSelectCard[pos].id)
                    print("____num: " .. self.m_NotSelectCard[pos].num)
                    print("____times: " .. self.m_NotSelectCard[pos].times)]]
                    
                    self:InitCard(i, self.m_NotSelectCard[pos].itemtype, self.m_NotSelectCard[pos].id, self.m_NotSelectCard[pos].num, self.m_NotSelectCard[pos].times)
                    pos = pos + 1
                    lua_CardUnit.TurnBack(self.m_vCards[i])
                end
            end
            self.m_eRotateState = self.eStopRotate
            --self.m_pSelectedCard:setProperty("AutoRenderingSurface", "false")
			self.m_pSelectedCard:setVisible(true)
            self.m_pSelectedCard = nil
            self.m_fRotateTime = 0
            self:DoWhenNotifiedByEffect()
        end
    end

    return true
end

function WujuelingCardDlg:InitCard(i, type, baseid, num, times)
    print("____WujuelingCardDlg:InitCard")
    print("____i: " .. i)
    print("____type: " .. type)
    print("____baseid: " .. baseid)
    print("____num: " .. num)
    print("____times: " .. times)

    self.m_vCards[i].num = num

    --物品
    if type == 1 then
        self.m_vCards[i].baseID = baseid
        local itembase = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(baseid)

        --设置ItemCell信息
        if itembase and itembase.id ~= -1 then
            self.m_vCards[i].pItemCell:SetImage(GetIconManager():GetItemIconByID(itembase.icon))
            self.m_vCards[i].pItemCell:SetTextUnit(tostring(num))
            --self.m_vCards[i].pItemCell:SetCellTypeMask(ItemCellType_Item)
            
            self.m_vCards[i].pItemCell:setID(baseid)
            self.m_vCards[i].pItemCell:removeEvent("TableClick")
            self.m_vCards[i].pItemCell:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)

            self.m_vCards[i].pItemCell:SetBtnVisible(false)
            self.m_vCards[i].pItemName:setText(itembase.name)
        end
    --经验
    elseif type == 2 then
        self.m_vCards[i].baseID = self.EXP_ITEMBASE
        local itembase = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.EXP_ITEMBASE)

        --设置ItemCell信息
        if itembase and itembase.id ~= -1 then
            self.m_vCards[i].pItemCell:SetImage(GetIconManager():GetItemIconByID(itembase.icon))
            --self.m_vCards[i].pItemCell:SetCellTypeMask(ItemCellType_Item)
            
            self.m_vCards[i].pItemCell:setID(baseid)
            self.m_vCards[i].pItemCell:removeEvent("TableClick")
            self.m_vCards[i].pItemCell:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)
            self.m_vCards[i].pItemCell:SetBtnVisible(false)
        end
        if num ~= 0 then
            local num32 = math.floor(num)
            if num32 >= 10000 then
                local strExp = ""
                if math.mod(num, 10000) < 1000 then
                    strExp = tostring(math.floor(num32/10000))
                else
                    strExp = math.floor(num32/10000) .. "." .. math.floor(math.mod(num32,10000)/1000)
                end

                self.m_vCards[i].pItemName:setText(strExp .. MHSD_UTILS.get_resstring(2781))
            else
                self.m_vCards[i].pItemName:setText(tostring(num32))
            end
        elseif times ~= 0 then
            local strExp = ""
            strExp = "x" .. math.floor(times/10) .. "." .. math.mod(times,10)
            self.m_vCards[i].pItemName:setText(strExp .. MHSD_UTILS.get_resstring(2782))
        end
        
    --金钱
    elseif type == 3 then
        self.m_vCards[i].baseID = self.MONEY_ITEMBASE
        local itembase = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.MONEY_ITEMBASE)

        --设置ItemCell信息
        if itembase and itembase.id ~= -1 then
            
            self.m_vCards[i].pItemCell:SetImage(GetIconManager():GetItemIconByID(itembase.icon))
            --self.m_vCards[i].pItemCell:SetCellTypeMask(ItemCellType_Item)
            
            self.m_vCards[i].pItemCell:setID(baseid)
            self.m_vCards[i].pItemCell:removeEvent("TableClick")
            self.m_vCards[i].pItemCell:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)

            self.m_vCards[i].pItemCell:SetBtnVisible(false)
        end
        if num ~= 0 then
            local num32 = math.floor(num)
            if num32 >= 10000 then
                local strMoney = ""
                if math.mod(num32,10000) < 1000 then
                    strMoney = tostring(math.floor(num32/10000))
                else
                    strMoney = math.floor(num/10000) .. "." .. math.floor(math.mod(num32,10000)/1000)
                end

                self.m_vCards[i].pItemName:setText(strMoney .. MHSD_UTILS.get_resstring(2781))
            else
                self.m_vCards[i].pItemName:setText(tostring(num32))
            end
        elseif times ~= 0 then
            local strMoney = ""
            strMoney = "×" .. math.floor(times/10) .. "." .. math.mod(times,10)
            self.m_vCards[i].pItemName:setText(strMoney .. MHSD_UTILS.get_resstring(2782))
        end
    
    --储备金
    elseif type == 4 then
        self.m_vCards[i].baseID = self.MONEY_ITEMBASE
        local itembase = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(self.MONEY_ITEMBASE)

        --设置ItemCell信息
        if itembase and itembase.id ~= -1 then
            self.m_vCards[i].pItemCell:SetImage(GetIconManager():GetItemIconByID(itembase.icon))
            --self.m_vCards[i].pItemCell:SetCellTypeMask(ItemCellType_Item)
            
            self.m_vCards[i].pItemCell:setID(baseid)
            self.m_vCards[i].pItemCell:removeEvent("TableClick")
            self.m_vCards[i].pItemCell:subscribeEvent("TableClick", CGameItemTable.HandleShowTootipsWithItemID, CGameItemTable)

            self.m_vCards[i].pItemCell:SetBtnVisible(false)
        end
        if num ~= 0 then
            local num32 = math.floor(num)
            if num32 >= 10000 then
                local strMoney = ""
                if math.mod(num,10000) < 1000 then
                    strMoney = tostring(math.floor(num32/10000))
                else
                    strMoney = math.floor(num32/10000) .. "." .. math.floor(math.mod(num32,10000)/1000)
                end

                self.m_vCards[i].pItemName:setText(strMoney .. MHSD_UTILS.get_resstring(2781))
            else
                self.m_vCards[i].pItemName:setText(tostring(num32))
            end
        elseif times ~= 0 then
            local strMoney = ""
            strMoney = math.floor(times/10) .. "." .. math.mod(times,10)
            self.m_vCards[i].pItemName:setText(strMoney .. MHSD_UTILS.get_resstring(2782))
        end
    end
end

function WujuelingCardDlg:InitCards(itemlist, resultindex, npcid, serviceid)
    LogInfo("____WujuelingCardDlg:InitCards")
    
    --[[print("____#itemlist: " .. #itemlist)
    print("____resultindex: " .. resultindex)
    print("____npcid: " .. npcid)
    print("____serviceid: " .. serviceid)
    for i = 1, #itemlist, 1 do
        print("____i: " .. i)
        if itemlist[i] then
            print("____itemtype: " .. itemlist[i].itemtype)
            print("____id: " .. itemlist[i].id)
            print("____num: " .. itemlist[i].num)
            print("____times: " .. itemlist[i].times)
        end
    end]]

    self.m_iNpcID = npcid
    self.m_iTaskID = serviceid
    
    --now we need to start from 1 with itemlist
    resultindex = resultindex + 1
    self.m_iResultIndex = resultindex
    
    if self.m_iResultIndex > self.TOTAL_REWARD then
        WujuelingCardDlg.DestroyDialog()
        return
    end

    self.m_SelectCard = itemlist[resultindex]

    self.m_NotSelectCard = {}
    
    for i = 1, self.TOTAL_REWARD, 1 do
        if i ~= resultindex then
            print("____not selected add one")
            self.m_NotSelectCard[#self.m_NotSelectCard+1] = itemlist[i]
        end
    end
    
    MHSD_UTILS.shuffletable(self.m_NotSelectCard)

    --[[print("____#self.m_NotSelectCard after: " .. #self.m_NotSelectCard)
    for i = 1, #self.m_NotSelectCard, 1 do
        print("____index: " .. i)
        print("____itemtype: " .. self.m_NotSelectCard[i].itemtype)
        print("____id: " .. self.m_NotSelectCard[i].id)
        print("____num: " .. self.m_NotSelectCard[i].num)
        print("____times: " .. self.m_NotSelectCard[i].times)
    end]]
end

return WujuelingCardDlg








