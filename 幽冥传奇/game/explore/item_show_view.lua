ItemShowView = ItemShowView or BaseClass(BaseView)

function ItemShowView:__init()
	self.is_any_click_close = true
	self.is_modal = true
	self.background_opacity = 200		
	self.config_tab = {
		{"show_item_ui_cfg", 1, {0}, false}, -- 默认隐藏 layout_item_show,初始后才显示
	}
	self.data = nil
end

function ItemShowView:LoadCallBack()
	self.node_t_list["layout_item_show"].node:setOpacity(0)

	local ph_cell = self.ph_list.ph_cell_item
	self.cell = BaseCell.New()
	self.cell:GetView():setAnchorPoint(0.5, 0.5)
	self.cell:SetPosition(ph_cell.x, ph_cell.y)
	self.node_t_list["layout_item_show"].node:addChild(self.cell:GetView(), 999)
	XUI.AddClickEventListener(self.node_t_list["layout_close_window"].node, BindTool.Bind(self.Close, self), true)
	XUI.AddClickEventListener(self.node_t_list["img_welcomebg"].node, BindTool.Bind(self.Close, self), false)

	RenderUnit.PlayEffectOnce(1082, self.node_t_list.img_welcomebg.node, 998, 340, 200, nil, nil)
end

function ItemShowView:OpenCallBack()

end

function ItemShowView:SetData(data, reward_type, need_check)
	self.data = data
	self.reward_type = reward_type
	self.need_check = need_check
end

function ItemShowView:ShowIndexCallBack(index)
	self.node_t_list["layout_break_out"].node:setVisible(self.reward_type == 1) -- 祝福大爆炸
	self.node_t_list["layout_treasure"].node:setVisible(self.reward_type ~= 1) -- 获得珍品
	self.node_t_list["layout_item_show"].node:setOpacity(0)
	self:Flush()
end

function ItemShowView:ReleaseCallBack()
	if self.cell then
		self.cell:DeleteMe()
	end
	self.cell = nil
end

function ItemShowView:OnFlush(param_t, index)
	self.node_t_list["layout_item_show"].node:setVisible(true)

	if nil == self.data then return end
	self.cell:SetData(self.data)
	self.cell:SetBindIconVisible(false)
	self.node_t_list["layout_item_show"].node:setOpacity(0)

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local  color = string.format("%06x", item_cfg.color)
	local text = string.format("{wordcolor;%s;%s}",color, item_cfg.name)
	local rich = RichTextUtil.ParseRichText(self.node_t_list["rich_explore_item"].node, text, 18)
	XUI.RichTextSetCenter(rich)

	local fade_in = cc.FadeIn:create(0.8)
	self.node_t_list["layout_item_show"].node:runAction(fade_in)
end

function ItemShowView:CloseCallBack()
	self.data = nil
	if self.need_check then
		GlobalTimerQuest:AddDelayTimer(function ()
			ExploreCtrl.Instance:CheckOpenShowView()
		end, 0)
		self.need_check = false
	end
end