---
--- Created by  Administrator
--- DateTime: 2019/11/11 19:31
---
BabyToysPanel = BabyToysPanel or class("BabyToysPanel", BaseItem)
local this = BabyToysPanel

function BabyToysPanel:ctor(parent_node, parent_panel)
    self.abName = "baby"
    self.assetName = "BabyToysPanel"
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
    self.model = BabyModel:GetInstance()
    self.isFirstReq = true
    BabyToysPanel.super.Load(self)
end

function BabyToysPanel:dctor()
    GlobalEvent:RemoveTabListener(self.gEvents)
    self.model:RemoveTabListener(self.events)
    self.views = nil
    self.btnSelectsTex = nil
    self.btnSelects = nil
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

function BabyToysPanel:LoadCallBack()
    self.nodes = {
        "rightObj/btns/lvBtn/lvText","rightObj/btns/bagBtn","rightObj/btns/bagBtn/bagSelect",
        "rightObj/btns/bagBtn/bagText", "rightObj/btns/lvBtn","rightObj/btns/lvBtn/lvSelect",
        "rightObj/bagObj","rightObj/lvObj","rightObj/bagObj/itemScrollView","rightObj/bagObj/itemScrollView/Viewport/itemContent",
        "leftObj/leftEquip","leftObj/rightEquip","rightObj/bagObj/itemScrollView/Viewport",
        "rightObj/moneyObj/moneyIcon","rightObj/moneyObj/moneyTex","rightObj/lvObj/nextLvObj/nextIconParent","rightObj/lvObj/curLvObj/curLvIconParent",
        "rightObj/lvObj/nextLvObj/nextName","rightObj/lvObj/curLvObj/curLvLevel","rightObj/lvObj/curLvObj/curLvName","rightObj/lvObj/nextLvObj/nextLevel",
        "rightObj/lvObj/levelBtn","rightObj/lvObj/consumeImg","rightObj/lvObj/consumeTex",
        "rightObj/lvObj/curLvObj/curAttrParent","rightObj/lvObj/nextLvObj/nextAttrParent","BabyToysAttrItem",
        "rightObj/lvObj/curLvObj/curPowerObj/curPower","rightObj/lvObj/nextLvObj/nextPowerObj/nextPower",
        "leftObj/equipPowerObj/equipPower","leftObj/modelCon","leftObj/title/babyName","rightObj/bagObj/fenJieBtn",

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
    self.equipPower = GetText(self.equipPower)
    self.babyName = GetText(self.babyName)
    self.views[1] = self.bagObj
    self.views[2] = self.lvObj

    self.btnSelects[1] = self.bagSelect
    self.btnSelects[2] = self.lvSelect
    
    self.btnSelectsTex[1] = self.bagText
    self.btnSelectsTex[2] = self.lvText


    self:InitUI()
    self:AddEvent()
    self:SetMask()
    BabyController:GetInstance():RequstBabyEquips()
    BagController:GetInstance():RequestBagInfo(BagModel.baby)



end


function BabyToysPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function BabyToysPanel:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_BABY].icon
    GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
    GoodIconUtil:CreateIcon(self, self.consumeImg, iconName, true)
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.BabyScore)
    self.moneyTex.text = money
end

function BabyToysPanel:CreateEquips()
    local tab = BabyModel.slotList
    local parent
    for i = 1, #tab do
        if i<= 3  then
            parent = self.leftEquip
        else
            parent = self.rightEquip
        end
        local item = self.equips[i]
        if not item  then
            item = BabyToysEquipItem(parent)
            self.equips[i] = item
        end
        item:SetData(tab[i],1)
    end
    if self.isFirstReq then
        self.isFirstReq = false
        local defSlot = self.model:GetMinSlot()
        if defSlot ~= 0 then
            self:EquipItemClick(defSlot)
        else
            SetVisible(self.lvBtn,false)
        end
        self.equipPower.text = self.model:GetAllPower()
        local showId = self.model:GetShowBaby()
        local babyCfg = Config.db_baby_order[showId.."@".."0"]
        if babyCfg then
            self:InitModel(babyCfg.res_id)
        end
        self.babyName.text = babyCfg.name
    else
        if  not table.isempty(self.equips) then
            self:UpdateLevelInfo()
        end
    end

end

function BabyToysPanel:AddEvent()

    local function call_back()
        BabyController:GetInstance():RequstBabyEquipUpLevel(self.selectEquip.slot)
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
        lua_panelMgr:GetPanelOrCreate(BabyDecomposePanel):Open()
    end
    AddClickEvent(self.fenJieBtn.gameObject,call_back)
    
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyEquips,handler(self,self.HandlBabyEquips))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.EquipItemClick,handler(self,self.EquipItemClick))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyEquipDecompose,handler(self,self.BabyEquipDecompose))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyEquipUpLevel,handler(self,self.BabyEquipUpLevel))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.OnStrongClick,handler(self,self.OnStrongClick))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.UpdateRedPoint, handler(self, self.UpdateRedPoint))
    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(BabyEvent.BabyBagInfo,handler(self,self.BabyBagInfo))


end

function BabyToysPanel:UpdateRedPoint()
    if not self.red1 then
        self.red1 = RedDot(self.lvBtn, nil, RedDot.RedDotType.Nor)
        self.red1:SetPosition(53, 15)
    end

    if not self.red2 then
        self.red2 = RedDot(self.levelBtn, nil, RedDot.RedDotType.Nor)
        self.red2:SetPosition(61, 17)
    end

    if self.selectEquip then
        self.red1:SetRedDotParam(self.model.babyToysRedPoints[self.selectEquip.slot])
        self.red2:SetRedDotParam(self.model.babyToysRedPoints[self.selectEquip.slot])
    end

end

function BabyToysPanel:OnStrongClick()
    self:Click(2)
end

function BabyToysPanel:EquipItemClick(slot)
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



function BabyToysPanel:UpdateLevelInfo()
    if not self.curIcon then
        self.curIcon = BabyToysEquipItem(self.curLvIconParent)
    end
    if not self.nextIcon then
        self.nextIcon = BabyToysEquipItem(self.nextIconParent)
    end
    if self.selectEquip then
        self.curIcon:SetData(self.selectEquip.slot,2)
        self.nextIcon:SetData(self.selectEquip.slot,2,true)
        self:UpdataAttrs()
    end
end

function BabyToysPanel:UpdataAttrs()
    self.equipPower.text = self.model:GetAllPower()
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
    local curAttrCfg = Config.db_baby_equip_level[self.selectEquip.slot.."@"..curItem.extra]

    --self.curPower.text = curItem.equip.power
    --local arrTab = String2Table(traCfg.attrs)
    if curAttrCfg then
        local upAttribute = String2Table(curAttrCfg.attr)
        local power = GetPowerByConfigList(upAttribute,{})
        self.curPower.text = power
        for i = 1, #upAttribute do
            local  item = self.curAttrs[i]
            if not item then
                item = BabyToysAttrItem(self.BabyToysAttrItem.gameObject,self.curAttrParent,"UI")
                self.curAttrs[i] = item
            end
            item:SetData(upAttribute[i])
        end
        for i = #upAttribute + 1,#self.curAttrs do
            local buyItem = self.curAttrs[i]
            buyItem:SetVisible(false)
        end
    end
    local nextAttrCfg = Config.db_baby_equip_level[self.selectEquip.slot.."@"..curItem.extra + 1]
    if not nextAttrCfg then
        nextAttrCfg = curAttrCfg
    end
    local upAttribute2 = String2Table(nextAttrCfg.attr)
    local power2 = GetPowerByConfigList(upAttribute2,{})
    self.nextPower.text = power2
    for i = 1, #upAttribute2 do
        local  item = self.nextAttrs[i]
        if not item then
            item = BabyToysAttrItem(self.BabyToysAttrItem.gameObject,self.nextAttrParent,"UI")
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
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.BabyScore)
    local color = "3ab60e"
    if money < self.curCost then
        color = "eb0000"
    end
    self.consumeTex.text = string.format("<color=#%s>%s</color>",color,self.curCost )

end

function BabyToysPanel:BabyEquipUpLevel()
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.BabyScore)
    self.moneyTex.text = money
end

function BabyToysPanel:HandlBabyEquips(data)
    self:CreateEquips()
    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
end

function BabyToysPanel:BabyBagInfo(data)
    if self.model.isOpenDecompose then
        return
    end
    self:Click(1)
    self:CreateItems()
    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
end

function BabyToysPanel:BabyEquipDecompose()
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.BabyScore)
    self.moneyTex.text = money
    if self.curCost then
        local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.BabyScore)
        local color = "3ab60e"
        if money < self.curCost then
            color = "eb0000"
        end
        self.consumeTex.text = string.format("<color=#%s>%s</color>",color,self.curCost )
    end
end

function BabyToysPanel:Click(index)
    if self.clickIndex == index then
        return
    end
    self.clickIndex = index
    self.model.openToysType = index
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

function BabyToysPanel:CreateItems()
    local param = {}
    local cellSize = {width = 78,height = 78}
    param["scrollViewTra"] = self.itemScrollView
    param["cellParent"] = self.itemContent
    param["cellSize"] = cellSize
    param["cellClass"] = BabyBagSettor
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 5
    param["spanY"] = 10
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = BagModel.GetInstance().babyOpenCells
    self.PageScrollView = ScrollViewUtil.CreateItems(param)
end

function BabyToysPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function BabyToysPanel:UpdateCellCB(itemCLS)
    itemCLS.bag = BagModel.baby
    if BagModel:GetInstance().babyItems ~=nil then
        local itemBase = BagModel:GetInstance().babyItems[itemCLS.__item_index]
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
            param["bag"] = BagModel.baby
            param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
            param["model"] = self.model
            itemCLS:InitItem(param)
        end
    else
        local param = {}
        param["bag"] = BagModel.baby
        param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
        param["model"] = self.model
        itemCLS:InitItem(param)
    end
end

function BabyToysPanel:GetItemDataByIndex(index)
    return BagModel.Instance:GetBabyItemDataByIndex(index)
end


function BabyToysPanel:InitModel(resName)
    if self.monster then
        self.monster:destroy()
    end
    local cfg = {}
    cfg.pos = {x = -1995, y = -60, z = 193}
    cfg.scale = {x=200, y=200, z=200}
    cfg.trans_offset = {y=60}
    self.monster = UIModelCommonCamera(self.modelCon, nil, resName)
    self.monster:SetConfig(cfg)
end