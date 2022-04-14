---
--- Created by  Administrator
--- DateTime: 2019/11/28 19:43
---
GodEquipPanel = GodEquipPanel or class("GodEquipPanel", BaseItem)
local this = GodEquipPanel

function GodEquipPanel:ctor(parent_node, parent_panel)

    self.abName = "god"
    self.assetName = "GodEquipPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.gEvents = {}
    --  self.curBabyId = 0
    self.clickIndex = 0
    self.views ={}
    self.btnSelectsTex = {}
    self.btnSelects = {}
    self.curAttrs = {}
    self.nextAttrs = {}
    self.equips = {}
    self.model = GodModel:GetInstance()
    self.isFirstReq = true
    GodEquipPanel.super.Load(self)
end

function GodEquipPanel:dctor()
    GlobalEvent:RemoveTabListener(self.gEvents)
    self.model:RemoveTabListener(self.events)
    self.views = nil
    self.btnSelectsTex = nil
    self.btnSelects = nil
    self.model.openEquipType = 1
    if self.equips then
        for i, v in pairs(self.equips) do
            v:destroy()
        end
        self.equips = {}
    end
    if self.curAttrs then
        for i, v in pairs(self.curAttrs) do
            v:destroy()
        end
        self.curAttrs = {}
    end

    if self.nextAttrs then
        for i, v in pairs(self.nextAttrs) do
            v:destroy()
        end
        self.nextAttrs = {}
    end

    if  self.monster  then
        self.monster:destroy()
    end
    self.monster = nil

    if self.curIcon then
        self.curIcon:destroy()
    end
    if self.nextIcon then
        self.nextIcon:destroy()
    end
    if self.PageScrollView ~= nil then
        self.PageScrollView:OnDestroy()
        self.PageScrollView = nil
    end

    if self.red1 then
        self.red1:destroy()
        self.red1 = nil
    end

    if self.red2 then
        self.red2:destroy()
        self.red2 = nil
    end
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function GodEquipPanel:LoadCallBack()
    self.nodes = {
        "rightObj/btns/lvBtn/lvText","rightObj/btns/bagBtn","rightObj/btns/bagBtn/bagSelect",
        "rightObj/btns/bagBtn/bagText", "rightObj/btns/lvBtn","rightObj/btns/lvBtn/lvSelect",
        "rightObj/bagObj","rightObj/lvObj","rightObj/bagObj/itemScrollView","rightObj/bagObj/itemScrollView/Viewport/itemContent",
        "leftObj/leftEquip","leftObj/rightEquip","rightObj/bagObj/itemScrollView/Viewport",
        "rightObj/moneyObj/moneyIcon","rightObj/moneyObj/moneyTex","rightObj/lvObj/nextLvObj/nextIconParent","rightObj/lvObj/curLvObj/curLvIconParent",
        "rightObj/lvObj/nextLvObj/nextName","rightObj/lvObj/curLvObj/curLvLevel","rightObj/lvObj/curLvObj/curLvName","rightObj/lvObj/nextLvObj/nextLevel",
        "rightObj/lvObj/levelBtn","rightObj/lvObj/consumeImg","rightObj/lvObj/consumeTex",
        "rightObj/lvObj/curLvObj/curAttrParent","rightObj/lvObj/nextLvObj/nextAttrParent","GodEquipAttrItem",
        "rightObj/lvObj/curLvObj/curPowerObj/curPower","rightObj/lvObj/nextLvObj/nextPowerObj/nextPower",
        "leftObj/modelCon","rightObj/bagObj/fenJieBtn","leftObj/midEquip",
    }
    self:GetChildren(self.nodes)
    self.lvText = GetText(self.lvText)
    self.bagText = GetText(self.bagText)
    self.moneyTex = GetText(self.moneyTex)
    self.moneyIcon = GetImage(self.moneyIcon)
    self.nextName = GetText(self.nextName)
    self.nextLevel = GetText(self.nextLevel)
    self.curLvName = GetText(self.curLvName)
    self.curLvLevel = GetText(self.curLvLevel)
    self.consumeImg = GetImage(self.consumeImg)
    self.consumeTex = GetText(self.consumeTex)
    self.curPower = GetText(self.curPower)
    self.nextPower = GetText(self.nextPower)
   -- self.equipPower = GetText(self.equipPower)

    self.views[1] = self.bagObj
    self.views[2] = self.lvObj

    self.btnSelects[1] = self.bagSelect
    self.btnSelects[2] = self.lvSelect

    self.btnSelectsTex[1] = self.bagText
    self.btnSelectsTex[2] = self.lvText
    self:InitUI()
    self:AddEvent()
    self:SetMask()
    GodController:GetInstance():RequstGodEquipInfo()
    BagController:GetInstance():RequestBagInfo(BagModel.God)
end


function GodEquipPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function GodEquipPanel:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_GOD_MONEY].icon
    GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
    GoodIconUtil:CreateIcon(self, self.consumeImg, iconName, true)
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.GodScore)
    self.moneyTex.text = money
end

function GodEquipPanel:AddEvent()
    local function call_back()
        GodController:GetInstance():RequstGodEquipUpLevelInfo(self.selectEquip.slot)
    end
    AddClickEvent(self.levelBtn.gameObject,call_back)


    local function call_back()  --背包
        self:Click(1)
    end
    AddClickEvent(self.bagBtn.gameObject,call_back)


    local function call_back()  --升級
        self:Click(2)
    end
    AddClickEvent(self.lvBtn.gameObject,call_back)

    local function call_back()
        lua_panelMgr:GetPanelOrCreate(GodDecomposePanel):Open()
    end
    AddClickEvent(self.fenJieBtn.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(GodEvent.GodEquipInfo,handler(self,self.GodEquipInfo))
    self.events[#self.events + 1] = self.model:AddListener(GodEvent.EquipItemClick,handler(self,self.EquipItemClick))
    self.events[#self.events + 1] = self.model:AddListener(GodEvent.GodEquipDecomposeInfo,handler(self,self.GodEquipDecomposeInfo))
    self.events[#self.events + 1] = self.model:AddListener(GodEvent.GodEquipUpLevelInfo,handler(self,self.GodEquipUpLevelInfo))

    self.events[#self.events + 1] = self.model:AddListener(GodEvent.OnStrongClick,handler(self,self.OnStrongClick))
    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(GodEvent.CheckRedPoint, handler(self, self.UpdateRedPoint))
    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(GodEvent.GodBagInfo,handler(self,self.GodBagInfo))

end

function GodEquipPanel:UpdateRedPoint()
    if not self.red1 then
        self.red1 = RedDot(self.lvBtn, nil, RedDot.RedDotType.Nor)
        self.red1:SetPosition(53, 15)
    end

    if not self.red2 then
        self.red2 = RedDot(self.levelBtn, nil, RedDot.RedDotType.Nor)
        self.red2:SetPosition(61, 17)
    end

    if self.selectEquip then
        self.red1:SetRedDotParam(self.model.equipRedPoints[self.selectEquip.slot])
        self.red2:SetRedDotParam(self.model.equipRedPoints[self.selectEquip.slot])
    end
end

function GodEquipPanel:GodEquipUpLevelInfo()
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.GodScore)
    self.moneyTex.text = money
end

function GodEquipPanel:GodEquipInfo()
    self:CreateEquips()
    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
end

function GodEquipPanel:CreateEquips()
    --GodModel.slotList
    local tab = GodModel.slotList
    local parent
    local pos = 0
    local index1 = 0
    local index2 = 0
    for i = 1, #tab do
        if i<= 3  then
            parent = self.leftEquip
            pos = 1
            index1 = index1 + 1
        elseif i > 3 and i <= 7 then
            parent = self.midEquip
            pos = 2
        else
            parent = self.rightEquip
            pos = 3
            index2 = index2 + 1
        end
        local item = self.equips[i]
        if not item  then
            item = GodEquipItem(parent)
            self.equips[i] = item
        end
        local tarIndex = index2
        if pos == 1 then
            tarIndex = index1
        end
        item:SetData(tab[i],1,nil,pos,tarIndex)
    end

    if self.isFirstReq then
        self.isFirstReq = false
        local defSlot = self.model:GetMinSlot()
        if defSlot ~= 0 then
            self:EquipItemClick(defSlot)
        else
            SetVisible(self.lvBtn,false)
        end
        --self.equipPower.text = self.model:GetAllPower()
        --local showId = self.model:GetShowBaby()
        --local babyCfg = Config.db_baby_order[showId.."@".."0"]
        --if babyCfg then
        --    self:InitModel(babyCfg.res_id)
        --end
        --self.babyName.text = babyCfg.name
    else
        if  not table.isempty(self.equips) then
            self:UpdateLevelInfo()
        end
    end
end

function GodEquipPanel:GodEquipDecomposeInfo()
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.GodScore)
    self.moneyTex.text = money
    if self.curCost then
        local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.GodScore)
        local color = "3ab60e"
        if money < self.curCost then
            color = "eb0000"
        end
        self.consumeTex.text = string.format("<color=#%s>%s</color>",color,self.curCost )
    end
end



function GodEquipPanel:GodBagInfo(data)
    if self.model.isOpenDecompose then
        return
    end
    self:Click(1)
    self:CreateItems()
    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
end

function GodEquipPanel:Click(index)
    if self.clickIndex == index then
        return
    end
    self.clickIndex = index
    self.model.openEquipType = index
    for i = 1, 2 do
        if index == i then
            SetVisible(self.btnSelects[i],true)
            SetVisible(self.views[i].gameObject,true)
            SetColor(self.btnSelectsTex[i], 133, 132, 176, 255)
        else
            SetVisible(self.views[i].gameObject,false)
            SetVisible(self.btnSelects[i],false)
            SetColor(self.btnSelectsTex[i], 255, 255, 255, 255)
        end
    end
end

function GodEquipPanel:EquipItemClick(slot)
    for i, v in pairs(self.equips) do
        if v.slot == slot then
            self.selectEquip = v
            self:UpdateLevelInfo()
            self:UpdateRedPoint()
            SetVisible(self.lvBtn,true)
            v:SetSelect(true)
        else
            v:SetSelect(false)
        end
    end
end

function GodEquipPanel:OnStrongClick()
    self:Click(2)
end

function GodEquipPanel:UpdateLevelInfo()
    if not self.curIcon then
        self.curIcon = GodEquipItem(self.curLvIconParent)
    end
    if not self.nextIcon then
        self.nextIcon = GodEquipItem(self.nextIconParent)
    end
    if self.selectEquip then
        self.curIcon:SetData(self.selectEquip.slot,2)
        self.nextIcon:SetData(self.selectEquip.slot,2,true)
        self:UpdataAttrs()
    end
end

function GodEquipPanel:UpdataAttrs()
    --self.equipPower.text = self.model:GetAllPower()
    local curItem = self.selectEquip.item or self.model:GetPutOnBySlot(self.selectEquip.slot)
    local curCfg = Config.db_item[curItem.id]
    local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(curCfg.color), curCfg.name)
    self.curLvName.text = str
    self.nextName.text = str
    local isMax = self.model:IsMaxUpLv(curItem)
    if isMax then
        self.curLvLevel.text = "Lv.".."Max"
        self.nextLevel.text = "Lv.".."Max"
        SetVisible(self.levelBtn,false)
    else
        self.curLvLevel.text = "Lv."..curItem.extra
        self.nextLevel.text = "Lv."..curItem.extra + 1
        SetVisible(self.levelBtn,true)
    end
    local curAttrCfg = Config.db_god_equip_level[self.selectEquip.slot.."@"..curItem.extra]

    --self.curPower.text = curItem.equip.power
    --local arrTab = String2Table(traCfg.attrs)
    if curAttrCfg then
        local upAttribute = String2Table(curAttrCfg.attr)
        local power = GetPowerByConfigList(upAttribute,{})
        self.curPower.text = power
        for i = 1, #upAttribute do
            local  item = self.curAttrs[i]
            if not item then
                item = GodEquipAttrItem(self.GodEquipAttrItem.gameObject,self.curAttrParent,"UI")
                self.curAttrs[i] = item
            end
            item:SetData(upAttribute[i])
        end
        for i = #upAttribute + 1,#self.curAttrs do
            local buyItem = self.curAttrs[i]
            buyItem:SetVisible(false)
        end
    end
    local nextAttrCfg = Config.db_god_equip_level[self.selectEquip.slot.."@"..curItem.extra + 1]
    if not nextAttrCfg then
        nextAttrCfg = curAttrCfg
    end
    local upAttribute2 = String2Table(nextAttrCfg.attr)
    local power2 = GetPowerByConfigList(upAttribute2,{})
    self.nextPower.text = power2
    for i = 1, #upAttribute2 do
        local  item = self.nextAttrs[i]
        if not item then
            item = GodEquipAttrItem(self.GodEquipAttrItem.gameObject,self.nextAttrParent,"UI")
            self.nextAttrs[i] = item
        end
        item:SetData(upAttribute2[i],true)
    end
    for i = #upAttribute2 + 1,#self.nextAttrs do
        local buyItem = self.curAttrs[i]
        buyItem:SetVisible(false)
    end
    local cost = String2Table(curAttrCfg.cost)
    self.curCost = cost[1][2]
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.GodScore)
    local color = "3ab60e"
    if money < self.curCost then
        color = "eb0000"
    end
    self.consumeTex.text = string.format("<color=#%s>%s</color>",color,self.curCost )
end




function GodEquipPanel:CreateItems()
    local param = {}
    local cellSize = {width = 78,height = 78}
    param["scrollViewTra"] = self.itemScrollView
    param["cellParent"] = self.itemContent
    param["cellSize"] = cellSize
    param["cellClass"] = GodBagSettor
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 5
    param["spanY"] = 10
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = BagModel.GetInstance().godOpenCells
    self.PageScrollView = ScrollViewUtil.CreateItems(param)
end

function GodEquipPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function GodEquipPanel:UpdateCellCB(itemCLS)
    itemCLS.bag = BagModel.God
    if BagModel:GetInstance().godItems ~=nil then
        local itemBase = BagModel:GetInstance().godItems[itemCLS.__item_index]
        if itemBase ~= nil and itemBase ~= 0 then
            local configItem = Config.db_item[itemBase.id]
            if configItem ~= nil then --配置表存该物品
                --type,uid,id,num,bag,bind,outTime
                local param = {}
                param["type"] = configItem.type
                param["uid"] = itemBase.uid
                param["id"] = configItem.id
                param["num"] = itemBase.num
                param["bag"] = itemBase.bag
                param["bind"] = itemBase.bind
                param["itemSize"] = {x=78, y=78}
                param["get_item_cb"] = handler(self,self.GetItemDataByIndex)

                param["model"] = self.model
                param["itemIndex"] = itemCLS.__item_index
                param["stencil_id"] = self.StencilId
                itemCLS:DeleteItem()
                itemCLS:UpdateItem(param)
            end

        else
            local param = {}
            param["bag"] = BagModel.God
            param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
            param["model"] = self.model
            itemCLS:InitItem(param)
        end
    else
        local param = {}
        param["bag"] = BagModel.God
        param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
        param["model"] = self.model
        itemCLS:InitItem(param)
    end
end

function GodEquipPanel:GetItemDataByIndex(index)
    return BagModel.Instance:GetGodItemDataByIndex(index)
end
