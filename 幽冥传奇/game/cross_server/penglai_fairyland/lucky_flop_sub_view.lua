local LuckyFlopSubView = BaseClass(SubView)
local BrandRender = BaseClass(BaseRender)

function LuckyFlopSubView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/penglai_fairyland.png'
	self.config_tab = {
		{"penglai_fairyland_ui_cfg", 3, {0}},
	}
end

function LuckyFlopSubView:LoadCallBack()
	local scene_index = PengLaiFairylandData.Instance:GetScenesIndex() > 0 and PengLaiFairylandData.Instance:GetScenesIndex() or 1
	self:CreateCell(scene_index)
	local event_proxy = EventProxy.New(PengLaiFairylandData.Instance, self)
	event_proxy:AddEventListener(PengLaiFairylandData.LuckyFlopInfoChange, BindTool.Bind(self.OnInfoChange, self))
	local brand_data_list = PengLaiFairylandData.Instance:GetBrandDataList()
	local ph_brand_area = self.ph_list.ph_brand_area
	self.brand_list = self:CreateBrands(ph_brand_area.x, ph_brand_area.y, ph_brand_area.w, ph_brand_area.h, #brand_data_list, BrandRender, self.ph_list.ph_cross_boss_brand)
	self.node_t_list.layout_lucky_flop.node:addChild(self.brand_list:GetView(), 99)
	self.brand_list:ReadyAllBrands(brand_data_list)
	self.brand_list:SetClickEvent(BindTool.Bind(self.OnClickBrand, self))
end

function LuckyFlopSubView:ReleaseCallBack()
	
end

function LuckyFlopSubView:ShowIndexCallBack()
	self:OnFlushLuckyFlopView()
	-- self.get_brand_remind_view = GetBrandRemindView.New()
	-- self.get_brand_remind_view:AutoOpen()
end

function LuckyFlopSubView:OnFlushLuckyFlopView()
	local flop_consume = PengLaiFairylandData.Instance:GetFlopConsume()
	local can_reset_times = Language.CrossBoss.ResetFlopConsume .. flop_consume
	self.node_t_list.lbl_consume.node:setString(can_reset_times)
	self.brand_list:FlushAllBrands()
end

function LuckyFlopSubView:CreateCell(index)
	-- 获取滚动条
	self.cell_view = self.node_t_list.scroll_award_list.node
	self.cell_view:setScorllDirection(ScrollDir.Horizontal)

	self.cell_list = {}
	local cell_data_list = PengLaiFairylandData.Instance:GetFlopAwardDataList(index)
	local total_width
	local data_list_num = #cell_data_list
	local ph = self.ph_list.ph_award_cell
	if data_list_num <= 6 then
		total_width = 537
	else
		total_width = data_list_num * ph.w + (data_list_num - 1) * 15
	end
	local x, y = 0, 0
	for k, v in pairs(cell_data_list) do
		local cell = BaseCell.New()
		self.cell_view:addChild(cell:GetView(), 10)
		x = total_width / 2 - ((data_list_num / 2) * ph.w + ((data_list_num - 1) / 2) * 15) + ((ph.w + 15) * (k - 1)) + ph.w / 2
		cell:SetPosition(x, y)
		cell:SetAnchorPoint(0.5, 0)
		cell:SetData(v)
		self.cell_list[#self.cell_list + 1] = cell
	end
	self.cell_view:setInnerContainerSize(cc.size(total_width, 110))
end

function LuckyFlopSubView:OnInfoChange(brand_index)
	self:OnFlushLuckyFlopView()
	if 0 ~= brand_index then
		self:OpenOneBrand(brand_index)
	end
end

-- 翻开一张牌
function LuckyFlopSubView:OpenOneBrand(brand_index)
	brand_index = brand_index or 0
	self.brand_list:FlushAllBrands()
	self.brand_list:TurnOneBrand(brand_index, PengLaiFairylandData.Instance:GetBrandData(brand_index))
end

function LuckyFlopSubView:CreateBrands(x, y, w, h, brand_num, brand_render, render_ui_cfg)
	local view = XUI.CreateLayout(x, y, w, h)
	local brands = {}
	local item_interval = 5
	brand_num = brand_num or 1

	for i = 1, brand_num do
		local brand = brand_render.New()
		brand:SetIndex(i)
		brand:SetUiConfig(render_ui_cfg, true)
		brand:SetAnchorPoint(0.5, 0.5)
		view:addChild(brand:GetView(), 1)

		local start_x = render_ui_cfg.w / 2
		local x, y = start_x + (render_ui_cfg.w + item_interval) * (i - 1), h / 2
		brand:SetPosition(x, y)
		brands[i] = brand
	end
	view:setContentSize(cc.size(render_ui_cfg.w * brand_num + item_interval * (brand_num - 1), h))

	local brands_obj = {
		view = view,
		brands = brands,
		GetView = function(obj)
			return obj.view
		end,
		GetBrand = function(obj, index)
			return obj.brands[index]
		end,
		FlushAllBrands = function(obj)
			for k, v in pairs(obj.brands) do
				v:Flush()
			end
		end,
		ReadyAllBrands = function(obj, data_list)
			for k, v in pairs(obj.brands) do
				v:ReadyBrand(data_list and data_list[k])
			end
		end,
		SetClickEvent = function(obj, func)
			for k, v in pairs(obj.brands) do
				v:AddClickEventListener(func, false)
			end
		end,
		TurnOneBrand = function(obj, index, data)
			local brand = obj.brands[index]
			if nil ~= brand then
				brand:TurnToOpen(data)
			else
			end
		end,
		TurnCloseAllBrand = function(obj, data_list)
		for k, v in pairs(obj.brands) do
				v:TurnToClose(data_list and data_list[k])
			end
		end,
		Clear = function(obj)
			for k, v in pairs(obj.brands) do
				v:DeleteMe()
			end
			obj.brands = {}
		end,
	}
	return brands_obj
end

function LuckyFlopSubView:OnClickBrand(brand_render)
	if not IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CrossServer.OnCrossServerCanTurn)
		return
	end

	if nil == brand_render then
		return
	end

	local index = brand_render:GetIndex()
	if not brand_render:StateOpen() then
		if PengLaiFairylandData.Instance:BrandCanTurn() then
			PengLaiFairylandCtrl.SendTurnLuckyFlop(index)
		else
			SysMsgCtrl.Instance:FloatingTopRightText(Language.CrossServer.KillBossCanTurn)
		end
	end
end

----------------------------------------------
-- 牌 render
----------------------------------------------

local BRAND_STATE = {
	NONE = -1,
	OPEN = 1,
	CLOSE = 0,
}

function BrandRender:__init()
	self.is_turning = false
	self.brand_state = BRAND_STATE.NONE
end

function BrandRender:__delete()
	self.is_turning = false
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function BrandRender:CreateChild()
	BrandRender.super.CreateChild(self)

	self.node_tree.layout_brand1.node:setVisible(false)
	self.node_tree.layout_brand0.node:setVisible(false)
	XUI.RichTextSetCenter(self.node_tree.layout_brand1.rich_item_name.node)

	local ph_item = self.ph_list.ph_item
	self.item_cell = BaseCell.New()
	self.item_cell:SetAnchorPoint(0.5, 0.5)
	self.item_cell:SetPosition(ph_item.x, ph_item.y)
	self.node_tree.layout_brand1.node:addChild(self.item_cell:GetView(), 10)
end

function BrandRender:OnFlush()
	if nil == self.data then
		return
	end

	-- 正面的内容
	local item_data = self.data.item_data
	local item_id = item_data.item_id
	if item_id > 0 then
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local item_name = item_cfg and string.format("{wordcolor;%s;%s}", string.sub(string.format("%06x", item_cfg.color), 1, 6), item_cfg.name) or ""
		RichTextUtil.ParseRichText(self.node_tree.layout_brand1.rich_item_name.node, item_name)
		self.item_cell:SetData(item_data)
	end

	-- 背面的内容
	if not self.data.is_open and PengLaiFairylandData.Instance:BrandCanTurn() then
		local flop_consume = PengLaiFairylandData.Instance:GetFlopConsume()
		local can_reset_times = ""
		if flop_consume > 0 then
			can_reset_times = Language.CrossBoss.ResetFlopConsume .. flop_consume
		else
			can_reset_times = Language.CrossBoss.ResetFlopConsume .. "免费"
		end
		self.node_tree.layout_brand0.lbl_consume.node:setString(can_reset_times)
	end

	-- if not self.data.is_open and CrossServerData.Instance:BrandCanTurn() then
	-- 	local tip = ""
	-- 	if CrossServerData.Instance:IsCanBrandConsumeNow() then
	-- 		local consume_gold = CrossServerData.Instance:GetTurnCurBrandConsume()
	-- 		if consume_gold > 0 then
	-- 			local role_gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
	-- 			local color = role_gold >= consume_gold and "ffff00" or "ff2828"
	-- 			tip = string.format(Language.CrossServer.TurnBrandNeedGold, color, consume_gold)
	-- 		else
	-- 			tip = string.format("{wordcolor;1eff00;%s}", Language.Common.Free)
	-- 		end
	-- 	end
	-- 	RichTextUtil.ParseRichText(self.node_tree.layout_brand0.rich_tip.node, tip)
	-- end

	if not self.data.is_open and self:StateOpen() then
		self:TurnToClose()
	end
end

function BrandRender:FlushByState()
	local brand1_vis = false
	local brand0_vis = false
	if self.brand_state == BRAND_STATE.NONE then
	elseif self.brand_state == BRAND_STATE.OPEN then
		brand1_vis = true
		brand0_vis = false
	elseif self.brand_state == BRAND_STATE.CLOSE then
		brand1_vis = false
		brand0_vis = true
	end
	self.node_tree.layout_brand1.node:setVisible(brand1_vis)
	self.node_tree.layout_brand0.node:setVisible(brand0_vis)
	self.node_tree.layout_brand1.node:setScale(1, 1)
	self.node_tree.layout_brand0.node:setScale(1, 1)
end

function BrandRender:ReadyBrand(data)
	self.brand_state = data.is_open and BRAND_STATE.OPEN or BRAND_STATE.CLOSE
	self:FlushByState()
	self:SetData(data)
end

function BrandRender:IsTurning()
	return self.is_turning
end

function BrandRender:StateOpen()
	return self.brand_state == BRAND_STATE.OPEN
end

function BrandRender:TurnToClose(data)
	if data then
		self:SetData(data)
	end
	if self.is_turning or self.brand_state ~= BRAND_STATE.OPEN then
		return
	end
	self.brand_state = BRAND_STATE.CLOSE
	self:OnTurn(false)
end

function BrandRender:TurnToOpen(data)
	if data then
		self:SetData(data)
	end
	if self.is_turning or self.brand_state ~= BRAND_STATE.CLOSE then
		return
	end
	self.brand_state = BRAND_STATE.OPEN
	self:OnTurn(true)
end

function BrandRender:TurnStart(is_open)
	self.node_tree.layout_brand1.node:setVisible(not is_open)
	self.node_tree.layout_brand0.node:setVisible(is_open)
end

function BrandRender:TurnShowChange(is_open)
	self.node_tree.layout_brand1.node:setVisible(is_open)
	self.node_tree.layout_brand0.node:setVisible(not is_open)
end

function BrandRender:TurnEnd()
	self.is_turning = false
	self:FlushByState()
end

function BrandRender:OnTurn2(is_open)
	if nil == is_open then
		is_open = true
	end

	local act_time = 1.2
	local param1 = {0, 0}
	local param2 = {0, 0}
	param1 = {0, -90}
	param2 = {-270, -90}
	self.view:stopAllActions()
	local act = cc.Sequence:create(
		cc.CallFunc:create(function()
			self:TurnStart(is_open)
		end),
		cc.OrbitCamera:create(act_time / 2, 1, 0, param1[1], param1[2], 0, 0),
		cc.CallFunc:create(function()
			self:TurnShowChange(is_open)
		end),
		cc.OrbitCamera:create(act_time / 2, 1, 0, param2[1], param2[2], 0, 0),
		cc.CallFunc:create(function()
			self:TurnEnd(is_open)
		end)
	)
	self.view:runAction(act)
end

function BrandRender:OnTurn(is_open)
	if nil == is_open then
		is_open = true
	end

	self.is_turning = true
	local act_time = 0.8

	self.node_tree.layout_brand1.node:stopAllActions()
	self.node_tree.layout_brand0.node:stopAllActions()

	local end_callback = cc.CallFunc:create(function()
		self:TurnEnd(is_open)
	end)

	if is_open then
		self.node_tree.layout_brand1.node:setScale(-1, 1)
		self.node_tree.layout_brand1.node:setVisible(false)
		local front_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Show:create())
		local front_scale = cc.ScaleTo:create(act_time, 1, 1)
		self.node_tree.layout_brand1.node:runAction(cc.Spawn:create(front_seq, front_scale))

		self.node_tree.layout_brand0.node:setScale(1, 1)
		self.node_tree.layout_brand0.node:setVisible(true)
		local back_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Hide:create())
		local back_scale = cc.ScaleTo:create(act_time, -1, 1)
		self.node_tree.layout_brand0.node:runAction(cc.Sequence:create(cc.Spawn:create(back_seq, back_scale), end_callback))
	else
		self.node_tree.layout_brand1.node:setScale(1, 1)
		self.node_tree.layout_brand1.node:setVisible(true)
		local front_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Hide:create())
		local front_scale = cc.ScaleTo:create(act_time, -1, 1)
		self.node_tree.layout_brand1.node:runAction(cc.Spawn:create(front_seq, front_scale))

		self.node_tree.layout_brand0.node:setScale(-1, 1)
		self.node_tree.layout_brand0.node:setVisible(false)
		local back_seq = cc.Sequence:create(cc.DelayTime:create(act_time / 2), cc.Show:create())
		local back_scale = cc.ScaleTo:create(act_time, 1, 1)
		self.node_tree.layout_brand0.node:runAction(cc.Sequence:create(cc.Spawn:create(back_seq, back_scale), end_callback))
	end
end

return LuckyFlopSubView