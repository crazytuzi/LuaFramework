---
--- Created by  Administrator
--- DateTime: 2019/11/29 11:46
---
GodTipView = GodTipView or class("GodTipView", BaseGoodsTip)
local this = GodTipView

function GodTipView:ctor(parent_node, layer)
    self.abName = "system"
    self.assetName = "BabyDetailView"
    self.layer = layer

    self:BeforeLoad()
end

function GodTipView:BeforeLoad()
    GodTipView.super.Load(self)
end

function GodTipView:InitData()
    -- self.maxViewHeight = 240
    GodTipView.super.InitData(self)
    self.minScrollViewHeight = 90
    self.maxScrollViewHeight = 350
    self.addValueTemp = 130
end


function GodTipView:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.attrStr1 then
        self.attrStr1:destroy()
        self.attrStr1 = nil
    end
    if self.attrStr2 then
        self.attrStr2:destroy()
        self.attrStr2 = nil
    end

end

function GodTipView:LoadCallBack()
    self.nodes = {
        "powerParent/powerTex","powerParent","equipPos/PosTxt","equipPos/pos","powerParent/powerArrowDown","powerParent/powerArrowUp",

    }
    self:GetChildren(self.nodes)
    self.PosTxt = GetText(self.PosTxt)
    self.pos = GetText(self.pos)
    self.powerTex = GetText(self.powerTex)
    self.powerParentRect = GetRectTransform(self.powerParent)
    GodTipView.super.LoadCallBack(self)

    --self.PosTxt = GetText(self.PosTxt)
    --self.wareValue = GetText(self.wareValue)
    --self.valueTempTxt = GetText(self.valueTemp)
end

function GodTipView:AddEvent()
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.CloseTipView))
end

function GodTipView:ShowTip(param)
    self.is_compare = param["is_compare"]
    GodTipView.super.ShowTip(self, param)
    SetVisible(self.wearLV,false)
    if not self.is_compare then
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
        self:AddClickCloseBtn()
        self:SetViewPosition()
        self:AddEvent()
    else
        SetVisible(self.mask.gameObject, false)
    end
    self:SetAttr(param["cfg"], param["p_item"])
    -- self:SetPowerUp(param["p_item"])

    --self:DealCreateAttEnd()
    self:SetViewPosition()


end




function GodTipView:SetAttr(cfg, p_item)
    local item_id = cfg.id
    local attrString = ""
    local cfg = Config.db_god_equip[item_id]
    if not cfg then
        logError("检查配置db_baby_equip id:"..item_id)
        return
    end
    local slot = cfg.slot  --部位
    local upLevel = p_item and p_item.extra or 0
    local upKey = slot.."@"..upLevel
    local baseAttribute = String2Table(Config.db_god_equip[item_id].base) --基础属性
    local upAttribute = String2Table(Config.db_god_equip_level[upKey].attr)  --升级属性
    local attrTab = {}
    for i = 1, #baseAttribute do
        local arrs = baseAttribute[i]
        local type = Config.db_attr_type[arrs[1]].type == 2
        local value = arrs[2]
        local value1 = arrs[2]
        if type then
            value = (value / 100).."%"
            value1 = (value1/10000)
        end
        table.insert(attrTab,{arrs[1],value1})
        if attrString == "" then
            attrString = string.format("<color=#675344>%s：</color><color=#2FAD25>%s</color>",enumName.ATTR[arrs[1]],value)
        else
            attrString = attrString .. "\n"..string.format("<color=#675344>%s：</color><color=#2FAD25>%s</color>",enumName.ATTR[arrs[1]],value)
        end

    end

    self.attrStr1 = EquipTwoAttrItemSettor(self.Content)
    self.valueTempTxt.text = attrString
    local height = self.valueTempTxt.preferredHeight + 25 + 10 + 20
    self.attrStr1:UpdatInfo({ title = "Basic Attribute", info1 = attrString, info2 = nil,
                              posY = self.height, itemHeight = height })
    self.height = self.height + height

    local upattrString = ""
    for i = 1, #upAttribute do
        local arrs = upAttribute[i]
        local type = Config.db_attr_type[arrs[1]].type == 2
        local value = arrs[2]
        if type then
            value = (value / 100).."%"
        end
        if upattrString == "" then
            upattrString = string.format("<color=#675344>%s：</color><color=#2FAD25>%s</color>",enumName.ATTR[arrs[1]],value)
        else
            upattrString = upattrString .. "\n"..string.format("<color=#675344>%s：</color><color=#2FAD25>%s</color>",enumName.ATTR[arrs[1]],value)
        end
    end

    self.attrStr2 = EquipTwoAttrItemSettor(self.Content)
    self.valueTempTxt.text = attrString
    local height = self.valueTempTxt.preferredHeight + 25 + 10
    self.attrStr2:UpdatInfo({ title = "Upgrade", info1 = upattrString, info2 = nil,
                              posY = self.height, itemHeight = height })
    self.height = self.height + height
    -- self:DealCreateAttEnd()
    local power
    --if p_item then
    --    power = p_item.equip.power
    --else
    --    local num,tab = GetPowerByConfigList(attrTab,{})
    --    power =  GetPowerByConfigList(attrTab,tab)
    --end

    self.powerTex.text = p_item and p_item.equip.power or GetPowerByConfigList(attrTab,{})

    self.height = self.height + 150
    local y = self:DealContentHeight()
    self.powerParentRect.anchoredPosition = Vector2(35,
            self.scrollViewRectTra.anchoredPosition.y - y) -- self.scrollViewRectTra.sizeDelta.y)

    self:DealCreateAttEnd()
    self.pos.text = "Hallow type:"
    self.PosTxt.text = enumName.ITEM_STYPE[slot]


    local item =  GodModel:GetInstance():GetPutOnBySlot(slot)
    if not item then
        SetVisible(self.powerArrowUp,true)
        SetVisible(self.powerArrowDown,false)
    else
        local id = item.id
        local equipCfg = Config.db_item[id]
        local curCfg = Config.db_item[item_id]
        if equipCfg then
            if curCfg.color > equipCfg.color then
                SetVisible(self.powerArrowUp,true)
                SetVisible(self.powerArrowDown,false)
            end
            if curCfg.color == equipCfg.color then
                SetVisible(self.powerArrowUp,false)
                SetVisible(self.powerArrowDown,false)
            end
            if curCfg.color < equipCfg.color then
                SetVisible(self.powerArrowUp,false)
                SetVisible(self.powerArrowDown,true)
            end

        end
    end

end

function GodTipView:DealCreateAttEnd()
    SetSizeDeltaY(self.contentRectTra, self.height - 150)

    local srollViewY = self:DealContentHeight()
    SetSizeDeltaY(self.scrollViewRectTra, 270)

    local y = srollViewY + self.addValueTemp
    if y > self.maxViewHeight then
        y = self.maxViewHeight
    end
    self.viewRectTra.sizeDelta = Vector2(self.viewRectTra.sizeDelta.x, y)
    self.bgRectTra.sizeDelta = self.viewRectTra.sizeDelta
end
