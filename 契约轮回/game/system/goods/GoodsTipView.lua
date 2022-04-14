--
-- @Author: chk
-- @Date:   2019-01-15 20:20:07
--
GoodsTipView = GoodsTipView or class("GoodsTipView", BaseGoodsTip)
local GoodsTipView = GoodsTipView

function GoodsTipView:ctor(parent_node, layer)
    GlobalEvent:Brocast(GoodsEvent.CloseTipView)

    self.abName = "system"
    self.assetName = "GoodsDetailView"
    self.layer = layer

    -- self.model = 2222222222222end:GetInstance()

    self:BeforeLoad()
end

function GoodsTipView:BeforeLoad()
    GoodsTipView.super.Load(self)
end

function GoodsTipView:dctor()
    if self.jumpItemSettor ~= nil then
        self.jumpItemSettor:destroy()
    end
end

function GoodsTipView:LoadCallBack()
    GoodsTipView.super.LoadCallBack(self)
    self:AddEvent()
end

function GoodsTipView:AddEvent()
    GoodsTipView.super.AddEvent(self)
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.DelItem))
    self.events[#self.events + 1] = GlobalEvent:AddListener(GoodsEvent.CloseTipView, handler(self, self.CloseTipView))
end

function GoodsTipView:SetData(data)

end

--param包含参数
--cfg  该物品(装备)的配置(比较神兽装备配置，人物装备配置),不一定是itemConfig
--p_item 服务器给的，服务器没给，只传cfg就好
--operate_param --操作参数
function GoodsTipView:ShowTip(param)
    GoodsTipView.super.ShowTip(self, param)

    local lvValueText = self.lvValue:GetComponent('Text')
    local lvNameText = self.lvText:GetComponent('Text')
    if (self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_MC_GIFT) then
        lvNameText.text = "Tower Floors:"
        lvValueText.text = DungeonModel:GetInstance():GetTowerFloor()
    else
        lvNameText.text = "Level:"
        lvValueText.text = self.item_cfg.level
    end

    local wSize = lvNameText.preferredWidth
    SetSizeDeltaX(self.lvText, wSize)
    SetAnchoredPosition(self.lvValue, wSize + 2, self.lvValue.anchoredPosition.y)

    self.typeValue:GetComponent('Text').text = self.item_cfg.type_desc
    local desc = self.item_cfg.desc
    if self.item_cfg.stype == enum.ITEM_STYPE.ITEM_STYPE_EXP3 then
        local arr = String2Table(self.item_cfg.effect)
        local level = RoleInfoModel:GetInstance():GetRoleValue("level")
        local exp = Config.db_role_level[level].exp
        exp = math.floor(arr[1] * exp + 0.5)
        exp = math.max(exp, arr[2])
        desc = string.format(desc, exp)
    end
    self:SetDes(desc .. "\n")
    self:SetUseway(self.item_cfg.useway .. "\n")
    self:SetJump(self.item_cfg.gainway, self.item_cfg.gainwayitem)

    self:DealCreateAttEnd()
    self:SetViewPosition()
end


--function GoodsTipView:SetJump(jump)
--	if not string.isempty(jump) then
--		local height = 94 + 25
--		self.jumpItemSettor = GoodsJumpItemSettor(self.Content)
--		self.jumpItemSettor:CreateJumpItems(jump,self.height)
--
--		self.height = self.height + height
--	end
--end

function GoodsTipView:SetUseway(useway)
    if useway ~= "\n" and not string.isempty(useway) then
        self.valueTempTxt.text = useway

        local att = { title = ConfigLanguage.Goods.UseWay, info = useway, posY = self.height, itemHeight = self.valueTempTxt.preferredHeight  }
        self.atts[#self.atts + 1] = GoodsAttrItemSettor(self.Content)
        self.atts[#self.atts]:UpdatInfo(att)

        self.height = self.height + self.valueTempTxt.preferredHeight + 25 + 24
    end
end

--function GoodsTipView:SetDes(des)
--	if des ~= "\n" and not string.isempty(des) then
--		self.valueTempTxt.text = des
--
--		local att = {title = ConfigLanguage.Goods.Des,info = des,posY = self.height ,itemHeight = self.valueTempTxt.preferredHeight + 25 + 20}
--		self.atts[#self.atts+1] = GoodsAttrItemSettor(self.Content)
--		self.atts[#self.atts]:UpdatInfo(att)
--
--
--		self.height = self.height + self.valueTempTxt.preferredHeight + 25 + 20
--	end
--end


