MagicCardView = MagicCardView or class("MagicCardView", BaseGoodsTip)
local MagicCardView = MagicCardView

function MagicCardView:ctor(parent_node, layer)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)

    self.abName = "system"
    self.assetName = "MagicCardView"
    self.layer = layer

    --self.model = EquipModel:GetInstance()

    self:BeforeLoad()
end

function MagicCardView:BeforeLoad()
    MagicCardView.super.Load(self)
end

function MagicCardView:dctor()
    if self.jumpItemSettor ~= nil then
        self.jumpItemSettor:destroy()
    end

    if self.baseAttrStr then
        self.baseAttrStr:destroy()
        self.baseAttrStr = nil
    end

    if self.rareAttrStr  then
        self.rareAttrStr:destroy()
        self.rareAttrStr = nil
    end
end

function MagicCardView:LoadCallBack()
    MagicCardView.super.LoadCallBack(self)
    self:AddEvent()
end

function MagicCardView:AddEvent()
    MagicCardView.super.AddEvent(self)
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.CloseTipView))
end

function MagicCardView:SetData(data)

end

--param包含参数
--cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
--p_item 服务器给的，服务器没给，只传cfg就好
--operate_param --操作参数
function MagicCardView:ShowTip(param)
    MagicCardView.super.ShowTip(self, param)

    local lvValueText = self.lvValue:GetComponent('Text')
    local lvNameText = self.lvText:GetComponent('Text')
    lvNameText.text = "Level:"
    lvValueText.text = self.item_cfg.level

    local wSize = lvNameText.preferredWidth
    SetSizeDeltaX(self.lvText, wSize)
    SetAnchoredPosition(self.lvValue, wSize + 2, self.lvValue.anchoredPosition.y)

    self:SetAttr()
    self.typeValue:GetComponent('Text').text = self.item_cfg.type_desc
    local desc = self.item_cfg.desc
    self:SetDes(desc .. "\n")
    self:SetUseway(self.item_cfg.useway .. "\n")
    self:SetJump(self.item_cfg.gainway)

    self:DealCreateAttEnd()
    self:SetViewPosition()
end


function MagicCardView:SetUseway(useway)
    if useway ~= "\n" and not string.isempty(useway) then
        self.valueTempTxt.text = useway

        local att = { title = ConfigLanguage.Goods.UseWay, info = useway, posY = self.height, itemHeight = self.valueTempTxt.preferredHeight  }
        self.atts[#self.atts + 1] = GoodsAttrItemSettor(self.Content)
        self.atts[#self.atts]:UpdatInfo(att)

        self.height = self.height + self.valueTempTxt.preferredHeight + 25 + 24
    end
end

function MagicCardView:SetAttr()
    local magicCfg = Config.db_magic_card[self.item_cfg.id]
    local baseAttr = String2Table(magicCfg.base)
    local rareAttr = String2Table(magicCfg.rare)
    if not table.isempty(baseAttr) then
        local attrInfo = ""
        self.baseAttrStr = EquipAttrItemSettor(self.Content)
        for k, v in pairs(baseAttr) do
            local valueInfo = self.model:GetAttrTypeInfo(v[1], v[2])
            attrInfo = attrInfo .. string.format("<color=#675344>%s</color>", enumName.ATTR[v[1]]) .. ":  " ..
            string.format("<color=#af3f3f>%s</color>", valueInfo)
            
            attrInfo = attrInfo .. "\n"
        end
        
        self.valueTempTxt.text = attrInfo
        local height = self.valueTempTxt.preferredHeight + 25 + 10
        self.baseAttrStr:UpdatInfo({ title = ConfigLanguage.AttrTypeName.BaseAttr, info = attrInfo,
                posY = self.height, itemHeight = height })
        
        self.height = self.height + height
    end
    if not table.isempty(rareAttr) then
        local attrInfo = ""
        self.rareAttrStr = EquipAttrItemSettor(self.Content)
        for k, v in pairs(rareAttr) do
            local valueInfo = self.model:GetAttrTypeInfo(v[1], v[2])

            attrInfo = attrInfo .. string.format("<color=#e46328>%s</color>", enumName.ATTR[v[1]]) .. ":  " ..
            string.format("<color=#e46328>%s</color>", valueInfo)
            
            attrInfo = attrInfo .. "\n"
        end
        
        self.valueTempTxt.text = attrInfo
        local height = self.valueTempTxt.preferredHeight + 25 + 10
        self.rareAttrStr:UpdatInfo({ title = ConfigLanguage.AttrTypeName.BestAttr, info = attrInfo,
                posY = self.height, itemHeight = height })
        
        self.height = self.height + height
    end 
end




