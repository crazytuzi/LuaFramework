---
--- Created by  Administrator
--- DateTime: 2019/12/25 19:13
---
MachineArmorTipView = MachineArmorTipView or class("MachineArmorTipView", BaseGoodsTip)
local this = MachineArmorTipView

function MachineArmorTipView:ctor(parent_node, parent_panel)
    self.abName = "system"
    self.assetName = "MechaDetailView"
    self.layer = layer

    self:BeforeLoad()
end

function MachineArmorTipView:BeforeLoad()
    MachineArmorTipView.super.Load(self)
end

function MachineArmorTipView:InitData()
    -- self.maxViewHeight = 240
    MachineArmorTipView.super.InitData(self)
    self.minScrollViewHeight = 90
    self.maxScrollViewHeight = 350
    self.addValueTemp = 130
end

function MachineArmorTipView:dctor()
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

function MachineArmorTipView:LoadCallBack()
    self.nodes = {
        "powerParent/powerTex","powerParent","equipPos/PosTxt","equipPos/pos","powerParent/powerArrowDown","powerParent/powerArrowUp",
        "mechaPos","mechaPos/mechaPosTxt",

    }
    self:GetChildren(self.nodes)
    self.PosTxt = GetText(self.PosTxt)
    self.pos = GetText(self.pos)
    self.powerTex = GetText(self.powerTex)
    self.mechaPosTxt = GetText(self.mechaPosTxt)
    self.powerParentRect = GetRectTransform(self.powerParent)
    MachineArmorTipView.super.LoadCallBack(self)
end

function MachineArmorTipView:AddEvent()
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.CloseTipView))
end

function MachineArmorTipView:ShowTip(param)
    self.is_compare = param["is_compare"]
    MachineArmorTipView.super.ShowTip(self, param)
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


function MachineArmorTipView:SetAttr(cfg, p_item)
    local item_id = cfg.id
    local attrString = ""
    local cfg = Config.db_mecha_equip[item_id]
    if not cfg then
        logError("检查配置db_baby_equip id:"..item_id)
        return
    end
    --判断专属
    if cfg.mecha_id == 0  then

        self.mechaPosTxt.text = "None"
    else
        --local color = ColorUtil.GetColor()
        local mechaCfg = MachineArmorModel:GetInstance():GetMechaCfg(cfg.mecha_id)
        local color = ColorUtil.GetColor(mechaCfg.color)

        self.mechaPosTxt.text = string.format("<color=#%s>%s</color>",color,mechaCfg.name)
    end


    local slot = cfg.slot  --部位
    local upLevel = p_item and p_item.extra or 0
    local upKey = slot.."@"..upLevel
    local baseAttribute = String2Table(Config.db_mecha_equip[item_id].base) --基础属性
    local upAttribute = String2Table(Config.db_mecha_equip_level[upKey].attr)  --升级属性
    local attrTab = {}

    for i = 1, #baseAttribute do
        local arrs = baseAttribute[i]
        local type = Config.db_attr_type[arrs[1]].type == 2
        local value = arrs[2]
        local value1 = arrs[2]
        if type then
            value = (value / 100).."%"
            value1 = value1/10000
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

    self.powerTex.text = p_item and p_item.equip.power or GetPowerByConfigList(attrTab,{})

    self.height = self.height + 150
    local y = self:DealContentHeight()
    self.powerParentRect.anchoredPosition = Vector2(35,
            self.scrollViewRectTra.anchoredPosition.y - y) -- self.scrollViewRectTra.sizeDelta.y)

    self:DealCreateAttEnd()
    self.pos.text = "Armor type:"
    self.PosTxt.text = enumName.ITEM_STYPE[slot]

    local mecheId = MachineArmorModel:GetInstance().curMecha
    local item =  MachineArmorModel:GetInstance():GetPutOnBySlot(mecheId,slot)
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

function MachineArmorTipView:DealCreateAttEnd()
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