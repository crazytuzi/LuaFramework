---
--- Created by  Administrator
--- DateTime: 2019/12/24 17:38
---
MachineArmorEquipPanel = MachineArmorEquipPanel or class("MachineArmorEquipPanel", BaseItem)
local this = MachineArmorEquipPanel

function MachineArmorEquipPanel:ctor(parent_node, parent_panel)

    self.abName = "machinearmor"
    self.assetName = "MachineArmorEquipPanel"
    self.layer = "UI"

    self.model = MachineArmorModel:GetInstance()
    self.clickIndex = 0
    self.attrs = {}
    self.events = {}
    self.modelEvents = {}
    self.btnSelectsTex = {}
    self.btnSelects = {}
    self.views = {}
    self.equips = {}
    self.curAttrs = {}
    self.isFirstReq = true
    self.defSlot = -1
    self.isFirstReqTab = {}
    MachineArmorEquipPanel.super.Load(self)
end

function MachineArmorEquipPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)

    self.btnSelectsTex = nil
    self.btnSelects = nil
    self.views = nil
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


    if self.PageScrollView ~= nil then
        self.PageScrollView:OnDestroy()
        self.PageScrollView = nil
    end
    if self.curIcon then
        self.curIcon:destroy()
        self.curIcon = nil
    end

    if self.red then
        self.red:destroy()
        self.red = nil
    end
    if self.red2 then
        self.red2:destroy()
        self.red2 = nil
    end

end

function MachineArmorEquipPanel:LoadCallBack()
    self.nodes = {
        "rightObj/btns/lvBtn","rightObj/btns/lvBtn/lvSelect","rightObj/btns/lvBtn/lvText","rightObj/btns/bagBtn",
        "rightObj/btns/bagBtn/bagText","rightObj/btns/bagBtn/bagSelect","rightObj/lvObj","rightObj/bagObj",
        "rightObj/bagObj/itemScrollView/Viewport","rightObj/bagObj/itemScrollView/Viewport/itemContent","rightObj/bagObj/itemScrollView",
        "middleObj/equip_7003","middleObj/equip_7005","middleObj/equip_7001","middleObj/equip_7002","middleObj/equip_7004",
        "rightObj/lvObj/curLvObj/curLvIconParent",
        "rightObj/lvObj/curLvObj/nextLv","rightObj/lvObj/curLvObj/curLv","rightObj/lvObj/curLvObj/curPowerObj/curPower",
        "rightObj/lvObj/attrParent","MachineArmorEquipAttrItem","rightObj/lvObj/levelBtn",
        "rightObj/lvObj/consumeTex","rightObj/lvObj/consumeImg","rightObj/bagObj/moneyObj/moneyName",
        "rightObj/bagObj/moneyObj/moneyIcon","rightObj/bagObj/moneyObj/moneyTex","rightObj/bagObj/fenJieBtn",
    }
    self:GetChildren(self.nodes)
    self.lvText = GetText(self.lvText)
    self.bagText = GetText(self.bagText)
    self.curPower = GetText(self.curPower)
    self.curLv = GetText(self.curLv)
    self.nextLv = GetText(self.nextLv)
    self.consumeTex = GetText(self.consumeTex)
    self.consumeImg = GetImage(self.consumeImg)
    self.moneyName = GetText(self.moneyName)
    self.moneyIcon = GetImage(self.moneyIcon)
    self.moneyTex = GetText(self.moneyTex)
    self:InitUI()
    self:AddEvent()
    self.btnSelects[1] = self.bagSelect
    self.btnSelects[2] = self.lvSelect

    self.btnSelectsTex[1] = self.bagText
    self.btnSelectsTex[2] = self.lvText

    self.views[1] = self.bagObj
    self.views[2] = self.lvObj
    if self.is_need_setData then
        self:SetData(self.info)
    end
    self:SetMask()
    BagController:GetInstance():RequestBagInfo(BagModel.mecha)
end

function MachineArmorEquipPanel:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_MECHA_MONEY].icon
    GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
    GoodIconUtil:CreateIcon(self, self.consumeImg, iconName, true)
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.mechaScore)
    self.moneyTex.text = money
end

function MachineArmorEquipPanel:AddEvent()
    local function call_back()  --背包
        self:Click(1)
    end
    AddClickEvent(self.bagBtn.gameObject,call_back)


    local function call_back()  --升級
        self:Click(2)
    end
    AddClickEvent(self.lvBtn.gameObject,call_back)

    local function call_back()
        MachineArmorController:GetInstance():RequstEquipUpLevelInfo(self.selectEquip.slot,self.info.id)
    end
    AddClickEvent(self.levelBtn.gameObject,call_back)


    local function call_back()
        lua_panelMgr:GetPanelOrCreate(MachineArmorDecPanel):Open()
    end
    AddClickEvent(self.fenJieBtn.gameObject,call_back)


    self.events[#self.events + 1] = GlobalEvent:AddListener(MachineArmorEvent.MechaBagInfo,handler(self,self.MechaBagInfo))
    self.events[#self.events + 1] = GlobalEvent:AddListener(MachineArmorEvent.CheckRedPoint,handler(self,self.CheckRedPoint))
    
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(MachineArmorEvent.MechaEquipInfo,handler(self,self.MechaEquipInfo))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(MachineArmorEvent.EquipItemClick,handler(self,self.EquipItemClick))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(MachineArmorEvent.OnStrongClick,handler(self,self.OnStrongClick))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(MachineArmorEvent.MechaEquipDecomposeInfo,handler(self,self.MechaEquipDecomposeInfo))
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(MachineArmorEvent.MechaEquipUpLevelInfo,handler(self,self.MechaEquipUpLevelInfo))
end

function MachineArmorEquipPanel:CheckRedPoint()
    if not self.red then
        self.red = RedDot(self.levelBtn.transform, nil, RedDot.RedDotType.Nor)
        self.red:SetPosition(58, 18)
    end
    if not self.red2 then
        self.red2 = RedDot(self.lvBtn.transform, nil, RedDot.RedDotType.Nor)
        self.red2:SetPosition(58, 18)
    end
    if self.selectEquip then
        local isRed = false
        if not table.isempty(self.model.equipRedPoints[self.info.id]) then
            for i, v in pairs(self.model.equipRedPoints[self.info.id]) do
                if v == true then
                    isRed = true
                    break
                end
            end
        end
         self.red:SetRedDotParam(isRed)
         self.red2:SetRedDotParam(isRed)
    end
   -- self.red:SetRedDotParam(self.model.equipRedPoints[self.info.id])
   -- self.red:SetRedDotParam(self.model.equipRedPoints[self.info.id])
end

function MachineArmorEquipPanel:SetData(info)
    self.info = info
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
    --self:Click(1)
    if not self.isFirstReq  then
        --for i, v in pairs(self.equips) do
        --    v:SetSelect(false)
        --end
        --self:Click(1)
        --SetVisible(self.lvBtn,false)
        if not self.selectEquip then
            for i, v in pairs(self.equips) do
                v:SetSelect(false)
            end
            self:Click(1)
            SetVisible(self.lvBtn,false)
        else
            local slot = self.selectEquip.slot
           local item =   self.model:GetPutOnBySlot(self.info.id,slot)
            if not item then
                local defSlot = self.model:GetMinSlot(self.info.id)
                if defSlot ~= 0 then
                    self:EquipItemClick(defSlot)
                else
                    self:Click(1)
                    for i, v in pairs(self.equips) do
                        v:SetSelect(false)
                    end
                    SetVisible(self.lvBtn,false)
                end
            else
                self:EquipItemClick(slot)
            end
        end
    end
    MachineArmorController:GetInstance():RequstEquipInfo(self.info.id)
   -- self:CheckRedPoint()

end

function MachineArmorEquipPanel:EquipItemClick(slot)
    for i, v in pairs(self.equips) do
        if v.slot == slot then
            self.selectEquip = v

            self:UpdateLevelInfo()
            self:CheckRedPoint()
            SetVisible(self.lvBtn,true)
            v:SetSelect(true)
        else
            v:SetSelect(false)
        end
    end
end

function MachineArmorEquipPanel:UpdateLevelInfo()
    if not self.curIcon then
        self.curIcon = MachineArmorEquipItem(self.curLvIconParent)
    end
    if self.selectEquip then
        self.curIcon:SetData(self.selectEquip.slot,2,self.info.id)
       -- if self.selectEquip then
            self:UpdataAttrs()
       -- end
    end
end

function MachineArmorEquipPanel:UpdataAttrs()
    local curItem = self.selectEquip.item or self.model:GetPutOnBySlot(self.info.id,self.selectEquip.slot)
    local isMax = self.model:IsMaxUpLv(curItem)
    if isMax then
        self.curLv.text = "Lv.".."Max"
        self.nextLv.text = "Lv.".."Max"
        SetVisible(self.levelBtn,false)
    else
        self.curLv.text = "Lv."..curItem.extra
        self.nextLv.text = "Lv."..curItem.extra + 1
        SetVisible(self.levelBtn,true)
    end
    local curAttrCfg = Config.db_mecha_equip_level[self.selectEquip.slot.."@"..curItem.extra]
    local nextAttrCfg = Config.db_mecha_equip_level[self.selectEquip.slot.."@"..curItem.extra + 1]
    local nextTab = {}
    if nextAttrCfg then
        nextTab = String2Table(nextAttrCfg.attr)
    end
    --MachineArmorEquipAttrItem
    if curAttrCfg then
        local upAttribute = String2Table(curAttrCfg.attr)
        local power = GetPowerByConfigList(upAttribute,{})
        self.curPower.text = power
        for i = 1, #upAttribute do
            local  item = self.curAttrs[i]
            if not item then
                item = MachineArmorEquipAttrItem(self.MachineArmorEquipAttrItem.gameObject,self.attrParent,"UI")
                self.curAttrs[i] = item
            else
                item:SetVisible(true)
            end
            item:SetData(upAttribute[i],nextTab[i] or {},nextAttrCfg == nil)
        end
        for i = #upAttribute + 1,#self.curAttrs do
            local buyItem = self.curAttrs[i]
            buyItem:SetVisible(false)
        end
    end

    local cost = String2Table(curAttrCfg.cost)
    self.curCost = cost[1][2]
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.mechaScore)
    local color = "3ab60e"
    if money < self.curCost then
        color = "eb0000"
    end
    self.consumeTex.text = string.format("<color=#%s>%s/%s</color>",color,self.curCost,money)
end

function MachineArmorEquipPanel:OnStrongClick()
    self:Click(2)
end

function MachineArmorEquipPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function MachineArmorEquipPanel:MechaEquipDecomposeInfo(data)
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.mechaScore)
    self.moneyTex.text = money
    if self.curCost then
        local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.mechaScore)
        local color = "3ab60e"
        if money < self.curCost then
            color = "eb0000"
        end
        self.consumeTex.text = string.format("<color=#%s>%s/%s</color>",color,self.curCost,money )
    end
end

function MachineArmorEquipPanel:MechaEquipUpLevelInfo()
    local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.mechaScore)
    self.moneyTex.text = money
    if self.curCost then
        local money =  RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.mechaScore)
        local color = "3ab60e"
        if money < self.curCost then
            color = "eb0000"
        end
        self.consumeTex.text = string.format("<color=#%s>%s/%s</color>",color,self.curCost,money )
    end
end


function MachineArmorEquipPanel:MechaEquipInfo(data)
    self:CreateEquips()
    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
end

function MachineArmorEquipPanel:CreateEquips()
    for i = 1, #MachineArmorModel.slotList do
        local slot = MachineArmorModel.slotList[i]
        local item = self.equips[i]
        if not item  then
            item = MachineArmorEquipItem(self["equip_"..slot])
            self.equips[i] = item
        end
        item:SetData(slot,1,self.info.id)
    end
    --if not self.isFirstReqTab[self.info.id] then
    --    self.isFirstReqTab[self.info.id] = true
    --    if not self.selectEquip then
    --        local defSlot = self.model:GetMinSlot(self.info.id)
    --        if defSlot ~= 0 then
    --            self:EquipItemClick(defSlot)
    --        else
    --            SetVisible(self.lvBtn,false)
    --        end
    --    else
    --        local slot = self.selectEquip.slot
    --        local item = self.model:GetPutOnBySlot(self.info.id,slot)
    --        if not item then
    --            local defSlot = self.model:GetMinSlot(self.info.id)
    --            if defSlot ~= 0 then
    --                self:EquipItemClick(defSlot)
    --            else
    --                SetVisible(self.lvBtn,false)
    --            end
    --        else
    --            self:EquipItemClick(slot)
    --        end
    --    end
    --else
    --    if  not table.isempty(self.equips) then
    --        self:UpdateLevelInfo()
    --    end
    --end

    if self.isFirstReq then
        self.isFirstReq = false
        local defSlot = self.model:GetMinSlot(self.info.id)
        if defSlot ~= 0 then
            self:EquipItemClick(defSlot)
        else
            SetVisible(self.lvBtn,false)
        end
    else
        --if  not table.isempty(self.equips) then
        --    self:UpdateLevelInfo()
        --end
        if self.model.openEquipType == 2 and not table.isempty(self.equips) then
            self:UpdateLevelInfo()
        end
    end
end

function MachineArmorEquipPanel:MechaBagInfo()
    if self.model.isOpenDecompose then
        return
    end
    self:Click(1)
    self:CreateItems()
    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
end

function MachineArmorEquipPanel:Click(index)
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
    if index == 2 then
        self:UpdateLevelInfo()
    end
end

function MachineArmorEquipPanel:CreateItems()
    local param = {}
    local cellSize = {width = 77,height = 77}
    param["scrollViewTra"] = self.itemScrollView
    param["cellParent"] = self.itemContent
    param["cellSize"] = cellSize
    param["cellClass"] = MachineArmorBagSettor
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 0
    param["spanY"] = 10
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = BagModel.GetInstance().mechaOpenCells
    --logError(BagModel.GetInstance().mechaOpenCells)
    self.PageScrollView = ScrollViewUtil.CreateItems(param)
end

function MachineArmorEquipPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function MachineArmorEquipPanel:UpdateCellCB(itemCLS)
    itemCLS.bag = BagModel.mecha
    if BagModel:GetInstance().mechaItems ~=nil then
        local itemBase = BagModel:GetInstance().mechaItems[itemCLS.__item_index]
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
            param["bag"] = BagModel.mecha
            param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
            param["model"] = self.model
            itemCLS:InitItem(param)
        end
    else
        local param = {}
        param["bag"] = BagModel.mecha
        param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
        param["model"] = self.model
        itemCLS:InitItem(param)
    end
end

function MachineArmorEquipPanel:GetItemDataByIndex(index)
    return BagModel.Instance:GetMechaItemDataByIndex(index)
end
