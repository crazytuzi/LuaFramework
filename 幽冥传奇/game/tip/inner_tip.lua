InnerTipView = InnerTipView or BaseClass(XuiBaseView)

local CONTENT_WIDTH = 400
local CONTENT_HEIGHT = 550
local LINE_HEIGHT = 30
local TITLE_HEIGHT = 40

function InnerTipView:__init()
    self:SetModal(true)
    self:SetIsAnyClickClose(true)

    self.config_tab = {
		{"innertip_ui_cfg", 1, {0}}
	}
    self.need_del_objs = {}
end

function InnerTipView:ReleaseCallBack()
    self.data = nil

    for k, v in pairs(self.need_del_objs) do
        v:DeleteMe()
    end
    self.need_del_objs = {}
    self.fight_power_view = nil
end

function InnerTipView:NewObj(type, ...)
    local obj = type.New(...)
    self.need_del_objs[#self.need_del_objs + 1] = obj
    return obj
end

function InnerTipView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
        local ph = self.ph_list.ph_fight
        self.fight_power_view = self:NewObj(FightPowerView, ph.x, ph.y, self.node_t_list.layout_inner_tip.node, 99)
        self.fight_power_view:SetScale(0.8)
        --物品
        local ph = self.ph_list.ph_cell
        self.item_cell = BaseCell.New()
        self.item_cell:SetPosition(ph.x, ph.y)
        self.item_cell:SetAnchorPoint(0.5, 0.5)
        self.node_t_list.layout_inner_tip.node:addChild(self.item_cell:GetView(), 103)

        --当前属性
        local ph = self.ph_list.ph_cur_attr
        self.cur_attr_view = self:NewObj(AttrView, 300, 25, 20)
        self.cur_attr_view:SetDefTitleText("")
        self.cur_attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
        self.cur_attr_view:GetView():setPosition(ph.x, ph.y)
        self.cur_attr_view:GetView():setAnchorPoint(0.5, 0.5)
        self.cur_attr_view:SetContentWH(ph.w, ph.h)
        self.node_t_list.layout_inner_tip.node:addChild(self.cur_attr_view:GetView(), 50)

         --下阶属性
        local ph = self.ph_list.ph_next_attr
        self.next_attr_view = self:NewObj(AttrView, 300, 25, 20)
        self.next_attr_view:SetDefTitleText("")
        self.next_attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
        self.next_attr_view:GetView():setPosition(ph.x, ph.y)
        self.next_attr_view:GetView():setAnchorPoint(0.5, 0.5)
        self.next_attr_view:SetContentWH(ph.w, ph.h)
        self.node_t_list.layout_inner_tip.node:addChild(self.next_attr_view:GetView(), 50)

        self.node_t_list.btn_up.node:addClickEventListener(BindTool.Bind(self.OnClickUpBtn, self))
        self.node_t_list.btn_up.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_up.node, 1)
        EventProxy.New(InnerData.Instance, self):AddEventListener(InnerData.EQUIP_CHANGE, BindTool.Bind(self.OnFlush, self))
        EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnFlush, self))

        --补充说明
        --self.node_t_list.lbl_content.node:setString(Language.Inner.Content)
        local x =  self.node_t_list.layout_inner_tip.node:getContentSize().width/2
        self.content = XUI.CreateRichText(x, 105,400 , 120 , false)
        local text = string.format(Language.Inner.Content)
        RichTextUtil.ParseRichText(self.content, text, 18)
        self.node_t_list.layout_inner_tip.node:addChild(self.content,100)

        --提示
        self.node_t_list.lbl_tips.node:setVisible(false)
        --self.node_t_list.img_bg.node:setOpacity(220)
    end
end

function InnerTipView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function InnerTipView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function InnerTipView:OnFlush(param_t, index)
    if not self.data then return end
    self:SetContent()
end

function InnerTipView:OnClickUpBtn()
    local equip_data = InnerData.Instance:GetCanEquipDataInBag(self.data)
    if nil ~= equip_data then
     InnerCtrl.SendInnerEquipReq(equip_data.series)
    -- self:runFaleAction()
    end
end

function InnerTipView:SetContent()
    local up_property = InnerData.GetOneEquipAttr(self.data)
    self.next_attr_view:SetData({InnerData.Instance:GetNextAttrBySlot(self.data)})
    self.item_id = self.data + 3514
    local item_data = {["item_id"] =  self.item_id, ["num"] = 1, ["is_bind"] = 0, effectId = 0}
    self.item_cell:SetData(item_data)
    local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
    self.node_t_list.img_icon.node:loadTexture(ResPath.GetItem(item_cfg.icon), false)
    --最大注入量
    local num_max = InnerData.Instance:GetEquipMaxNum(self.data)
    --当前注入量
    local cur_num = InnerData.Instance:GetEquipNum(self.data)
    --资质丹名字
    self.node_t_list.lbl_name.node:setString(item_cfg.name)
    --注入量
    self.node_t_list.lbl_add_num.node:setString(string.format(Language.Inner.AddNum, cur_num))
    --战力
    self.fight_power_view:SetNumber(CommonDataManager.GetAttrSetScore({InnerData.Instance:GetCurAttrBySlot(self.data)}))
    
    self.node_t_list.layout_costme.node:setVisible(not(cur_num == num_max))


    if cur_num < num_max then
        self.node_t_list.lbl_tips.node:setVisible(false)
        local item = InnerData.Instance:GetCanEquipDataInBag(self.data)
        if item then
            self.node_t_list.layout_costme.node:setVisible(not (item.num > 0))
            self.node_t_list.btn_up.node:setVisible(item.num > 0)
            self.cur_attr_view:SetData({InnerData.Instance:GetCurAttrBySlot(self.data)},up_property)
        else
            self.node_t_list.layout_costme.node:setVisible(true)
            self.node_t_list.btn_up.node:setVisible(false)
            self.cur_attr_view:SetData({InnerData.Instance:GetCurAttrBySlot(self.data)})
        end
    else
        self.node_t_list.lbl_tips.node:setVisible(true)
        self.node_t_list.layout_costme.node:setVisible(false)
        self.node_t_list.btn_up.node:setVisible(false)
        self.cur_attr_view:SetData({InnerData.Instance:GetCurAttrBySlot(self.data)})
    end
end

function InnerTipView:runFaleAction()
    local up_property = InnerData.GetOneEquipAttr(self.data)
    local str = string.format("↑+%d",up_property[1].value)
    local str = string.format("↑+%d",up_property[1].value)

    local ph1 = self.ph_list.ph_cur_add
    local text1 = XUI.CreateText(ph1.x, ph1.y-5, ph1.w, ph1.h, nil, str)
    text1:setColor(COLOR3B.GREEN)
    self.node_t_list.layout_inner_tip.node:addChild(text1,999)

    local ph2 = self.ph_list.ph_next_add
    local text2 = XUI.CreateText(ph2.x, ph2.y-5, ph2.w, ph2.h, nil, str)
    text2:setColor(COLOR3B.GREEN)
    self.node_t_list.layout_inner_tip.node:addChild(text2,999)

    local fade_in = cc.FadeIn:create(0.2)
    local fade_out = cc.FadeOut:create(0.8)
    local sequence = cc.Sequence:create(fade_in,fade_out)
    local moveby = cc.MoveBy:create(1,cc.p(0, 20))
    local spawn = cc.Spawn:create(sequence, moveby)
    text1:runAction(spawn)
    text2:runAction(spawn:clone())
end

function InnerTipView:SetData(data)
    self.data = data
end