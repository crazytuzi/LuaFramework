-- 跨服战场 翻牌
local CrossBattleBrand = BaseClass()
local BrandRender = BaseClass(BaseRender)

function CrossBattleBrand:__init(root_view)
	self.root_view = root_view
	self.node_t_list = {}
	self.ph_list = {}

	self.preview_items = {}
end

function CrossBattleBrand:__delete()
end

function CrossBattleBrand:LoadCallBack()
	self.node_t_list = self.root_view.node_t_list
	self.ph_list = self.root_view.ph_list
	self.view = self.node_t_list.layout_brand.node
	self.layout_preview_list = self.node_t_list.layout_preview_list.node
	self.btn_reset_brand = self.node_t_list.btn_reset_brand.node
	self.rich_reset_times = self.node_t_list.rich_reset_times.node
	self.rich_consume = self.node_t_list.rich_consume.node
	self.rich_brand_tip = self.node_t_list.rich_brand_tip.node

	local rich_size = self.rich_brand_tip:getContentSize()
	local rich_x, rich_y = self.rich_brand_tip:getPosition()
	self.rich_brand_tip:retain()
	self.rich_brand_tip:removeFromParent(false)
	local x, y = self.rich_brand_tip:getPosition()
	local size = self.rich_brand_tip:getContentSize()
	self.scroll_rich = XUI.CreateScrollView(rich_x, rich_y, rich_size.width, 90, ScrollDir.Vertical)
	self.view:addChild(self.scroll_rich, 10)
	self.scroll_rich:setAnchorPoint(0, 1)
	self.scroll_rich:addChild(self.rich_brand_tip)
	RichTextUtil.ParseRichText(self.rich_brand_tip, CrossServerData.GetBrandTipContent())
	-- self.rich_brand_tip:setVerticalSpace(0)
	self.rich_brand_tip:refreshView()
	local inner_size = self.rich_brand_tip:getInnerContainerSize()
	local inner_heigh = math.max(inner_size.height, size.height)
	inner_size.height = inner_heigh
	self.rich_brand_tip:setPosition(0, inner_heigh)
	self.scroll_rich:setInnerContainerSize(inner_size)
	self.scroll_rich:jumpToTop()

	XUI.RichTextSetCenter(self.rich_reset_times)
	self.btn_reset_brand:setTitleText(Language.CrossServer.ResetBrand)
	XUI.AddClickEventListener(self.btn_reset_brand, BindTool.Bind(self.OnClickResetBrand, self))
	self.btn_reset_brand:setVisible(false)

	local brand_data_list = CrossServerData.Instance:GetBrandDataList()
	local ph_brand_area = self.ph_list.ph_brand_area
	self.brand_list = self:CreateBrands(ph_brand_area.x, ph_brand_area.y, ph_brand_area.w, ph_brand_area.h, #brand_data_list, BrandRender, self.ph_list.ph_ljzc_brand)
	self.view:addChild(self.brand_list:GetView(), 99)
	self.brand_list:ReadyAllBrands(brand_data_list)
	self.brand_list:SetClickEvent(BindTool.Bind(self.OnClickBrand, self))
end

function CrossBattleBrand:ReleaseCallBack()
	self.node_t_list = {}
	self.ph_list = {}

	for k, v in pairs(self.preview_items) do
		v:DeleteMe()
	end
	self.preview_items = {}

	if self.brand_list then
		self.brand_list:Clear()
		self.brand_list = nil
	end
end

function CrossBattleBrand:ShowIndexCallBack()
	local brand_data_list = CrossServerData.Instance:GetBrandDataList()
	self.brand_list:ReadyAllBrands(brand_data_list)
end

function CrossBattleBrand:OnFlush(param_t)
	self.brand_list:FlushAllBrands()

	if param_t["turn_one_brand"] then
		self:OpenOneBrand(param_t["turn_one_brand"].brand_index)
		return
	end

	self:ShowPerviewItems()
	self:FlushGoldNum()
end

function CrossBattleBrand:FlushRestParts()
	local reset_brand_info = CrossServerData.Instance:GetResetBrandInfo()
	RichTextUtil.ParseRichText(self.rich_reset_times, string.format(Language.CrossServer.CanResetTimes, reset_brand_info.left_reset_times))
	RichTextUtil.ParseRichText(self.rich_consume, string.format(Language.CrossServer.GoldConsume, reset_brand_info.gold_consume))
end

function CrossBattleBrand:FlushGoldNum()
	local gold = GameMath.FormatNum(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD))
	self.node_t_list.label_gold_num.node:setString(gold)
end

function CrossBattleBrand:RoleDataChangeCallback(key)
	if key == OBJ_ATTR.ACTOR_GOLD then
		self:FlushGoldNum()
	end
end

function CrossBattleBrand:ItemConfigCallback(item_config_t)
	self.brand_list:FlushAllBrands()
end

function CrossBattleBrand:OpenOneBrand(brand_index)
	brand_index = brand_index or 0
	self.brand_list:TurnOneBrand(brand_index, CrossServerData.Instance:GetBrandData(brand_index))
end

function CrossBattleBrand:OnClickBrand(brand_render)
	if not IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CrossServer.OnCrossServerCanTurn)
		return
	end

	if nil == brand_render then
		return
	end

	local index = brand_render:GetIndex()
	if not brand_render:StateOpen() then
		if CrossServerData.Instance:BrandCanTurn() then
			CrossServerCtrl.SentCrossTurnBrandReq(index)
		else
			SysMsgCtrl.Instance:FloatingTopRightText(Language.CrossServer.KillBossCanTurn)
		end
	end
end

function CrossBattleBrand:CreateBrands(x, y, w, h, brand_num, brand_render, render_ui_cfg)
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

function CrossBattleBrand:OnClickResetBrand()
	-- local reset_brand_info = CrossServerData.Instance:GetResetBrandInfo()
	-- if reset_brand_info.left_reset_times > 0 then
	-- else
	-- 	SysMsgCtrl.Instance:FloatingTopRightText(Language.CrossServer.ResetBrandNoTimes)
	-- end

	if CrossServerData.Instance:GetFreeCrossBrandRemind() < 1 then
		CrossServerData.Instance:InitCrossBrand()
		local brand_data_list = CrossServerData.Instance:GetBrandDataList()
		self.brand_list:TurnCloseAllBrand(brand_data_list)
	end
end

-- 一排装备展示
function CrossBattleBrand:ShowPerviewItems()
	local preview_list_size = self.layout_preview_list:getContentSize()
	local items = CrossServerData.Instance:GetBrandPreviewItems()
	local total_num = #items
	local item_w = 80
	local x_interval = 5
	local total_w = total_num * item_w + (total_num - 1) * x_interval
	local start_x = (preview_list_size.width - total_w) / 2 + item_w / 2
	local function getXY(index)
		return start_x + (index - 1) * (x_interval + item_w), preview_list_size.height / 2
	end
	if #self.preview_items < total_num then
		local need_num = total_num - #self.preview_items
		for i = 1, need_num do
			local item = BaseCell.New()
			item:SetAnchorPoint(0.5, 0.5)
			self.layout_preview_list:addChild(item:GetView(), 99)
			self.preview_items[#self.preview_items + 1] = item
		end
	end
	for k, v in pairs(self.preview_items) do
		if items[k] then
			v:SetData(items[k])
			v:SetVisible(true)
			v:SetPosition(getXY(k))
		else
			v:SetVisible(false)
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

	XUI.RichTextSetCenter(self.node_tree.layout_brand0.rich_tip.node)

	local ph_item = self.ph_list.ph_item
	self.item_cell = BaseCell.New()
	self.item_cell:SetCellBg(ResPath.GetCommon("cell_110"))
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
	if not self.data.is_open and CrossServerData.Instance:BrandCanTurn() then
		local tip = ""
		if CrossServerData.Instance:IsCanBrandConsumeNow() then
			local consume_gold = CrossServerData.Instance:GetTurnCurBrandConsume()
			if consume_gold > 0 then
				local role_gold = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)
				local color = role_gold >= consume_gold and "ffff00" or "ff2828"
				tip = string.format(Language.CrossServer.TurnBrandNeedGold, color, consume_gold)
			else
				tip = string.format("{wordcolor;1eff00;%s}", Language.Common.Free)
			end
		end
		RichTextUtil.ParseRichText(self.node_tree.layout_brand0.rich_tip.node, tip)
	end

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

return CrossBattleBrand
