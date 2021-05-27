local CrossFlopSubView = BaseClass(SubView)
local BrandRender = BaseClass(BaseRender)

local is_turning = false

function CrossFlopSubView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/penglai_fairyland.png'
	self.config_tab = {
		{"cross_boss_ui_cfg", 2, {0}},
	}
end

function CrossFlopSubView:LoadCallBack()
	self:CreateDrawRecordList()
	self:CreateCell()

	local brand_data_list = CrossServerData.Instance:GetBrandDataList()
	local ph_brand_area = self.ph_list.ph_brand_area
	self.brand_list = self:CreateBrands(ph_brand_area.x, ph_brand_area.y, ph_brand_area.w, ph_brand_area.h, #brand_data_list, BrandRender, self.ph_list.ph_cross_boss_brand)
	self.node_t_list.layout_lucky_flop.node:addChild(self.brand_list:GetView(), 99)
	self.brand_list:ReadyAllBrands(brand_data_list)
	self.brand_list:SetClickEvent(BindTool.Bind(self.OnClickBrand, self))

	XUI.AddClickEventListener(self.node_t_list.btn_tip.node, function ()
		DescTip.Instance:SetContent(Language.Boss.CrossBossFlopTips, Language.Boss.CrossBossFlopTipsName)
	end)

	--重置翻牌
	XUI.AddClickEventListener(self.node_t_list.btn_shenshi.node, function ()
		if is_turning then return end
	    if CrossServerData.Instance:BrandCanTurn() and CrossServerData.Instance:GetFreeCrossBrandTimes() > 0 then
			if self.alert_cz_view == nil then
				self.alert_cz_view = Alert.New()
				self.alert_cz_view:SetOkString(Language.Common.Cancel)
			    self.alert_cz_view:SetCancelString(Language.Common.Confirm)
			    local text = string.format("您还没翻牌呢, 请先进行翻牌", consume)
			    self.alert_cz_view:SetLableString5(text, RichVAlignment.VA_CENTER)
			    self.alert_cz_view:SetOkFunc(function ()
			    	self.alert_cz_view:Close()
			    end)
			    self.alert_cz_view:SetCancelFunc(function ()
					-- CrossServerCtrl.SentCrossTurnBrandReq(2)
			    end)
			end
		    self.alert_cz_view:Open()    	
	    else
	    	CrossServerCtrl.SentCrossTurnBrandReq(2)
	    end
	end)

	EventProxy.New(CrossServerData.Instance, self):AddEventListener(CrossServerData.FLOP_DATA_CHANGE, BindTool.Bind(self.OnInfoChange, self))
end

function CrossFlopSubView:CreateDrawRecordList()
	local ph = self.ph_list.ph_drow_record_list
	self.draw_record_list = ListView.New()
	self.draw_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CrossFlopCardRecordRender, nil, nil, nil)
	self.draw_record_list:GetView():setAnchorPoint(0.5, 0.5)
	self.draw_record_list:SetJumpDirection(ListView.Top)
	self.draw_record_list:SetItemsInterval(5)
	self.node_t_list.layout_lucky_flop.node:addChild(self.draw_record_list:GetView(), 100)
end

function CrossFlopSubView:ReleaseCallBack()
	if self.draw_record_list then
		self.draw_record_list:DeleteMe()
		self.draw_record_list = nil
	end
	if self.alert_view then
		self.alert_view:DeleteMe()
		self.alert_view = nil
	end
	if self.alert_cz_view then
		self.alert_cz_view:DeleteMe()
		self.alert_cz_view = nil
	end
end

function CrossFlopSubView:ShowIndexCallBack()
	self:OnFlushLuckyFlopView()
	-- self.get_brand_remind_view = GetBrandRemindView.New()
	-- self.get_brand_remind_view:AutoOpen()
end

function CrossFlopSubView:OnFlushLuckyFlopView()
	local flop_consume = CrossServerData.Instance:GetFlopConsume()
	local can_reset_times = Language.CrossBoss.ResetFlopConsume .. flop_consume
	-- self.node_t_list.lbl_consume.node:setString(can_reset_times)
	self.node_t_list.lbl_flop_num.node:setString(CrossServerData.Instance.cross_brand_data.flop_num)	
	self.draw_record_list:SetDataList(CrossServerData.Instance:GetBrandRecord())
	self.draw_record_list:JumpToTop()
	self.brand_list:FlushAllBrands()
end

function CrossFlopSubView:CreateCell()
	-- 获取滚动条
	self.cell_view = self.node_t_list.scroll_award_list.node
	self.cell_view:setScorllDirection(ScrollDir.Horizontal)

	self.cell_list = {}
	local cell_data_list = CrossServerData.Instance:GetBrandPreviewItems()
	local total_width
	local data_list_num = #cell_data_list
	local ph = self.ph_list.ph_award_cell
	ph.w = ph.w - 2
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

function CrossFlopSubView:OnInfoChange(brand_index)
	self:OnFlushLuckyFlopView()
	if 0 ~= brand_index then
		self:OpenOneBrand(brand_index)
	end
end

-- 翻开一张牌
function CrossFlopSubView:OpenOneBrand(brand_index)
	brand_index = brand_index or 0
	self.brand_list:FlushAllBrands()
	self.brand_list:TurnOneBrand(brand_index, CrossServerData.Instance:GetBrandData(brand_index))
end

function CrossFlopSubView:CreateBrands(x, y, w, h, brand_num, brand_render, render_ui_cfg)
	local view = XUI.CreateLayout(x, y, w, h)
	local brands = {}
	local item_interval = -6
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

function CrossFlopSubView:OnClickBrand(brand_render)
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:FloatingTopRightText(Language.CrossServer.NotOnCrossServerCanTurn)
		return
	end

	if nil == brand_render then
		return
	end

	local index = brand_render:GetIndex()
	if not brand_render:StateOpen() then
		if CrossServerData.Instance:BrandCanTurn() then
			-- PengLaiFairylandCtrl.SendTurnLuckyFlop(index)
			local consume = CrossServerData.Instance:GetFlopConsume()
			if consume > 0 then
				if self.alert_view == nil then
					self.alert_view = Alert.New()
				end
				self.alert_view:SetOkString(Language.Common.Cancel)
			    self.alert_view:SetCancelString(Language.Common.Confirm)
			    local text = string.format("本次翻牌需要消耗%s钻石，是否确定", consume)
			    self.alert_view:SetLableString5(text, RichVAlignment.VA_CENTER)
 				local need_text = string.format(Language.Lianyu.Consume_Show, ResPath.GetCommon("gold"), consume)
   				self.alert_view:SetLableString6(need_text, RichVAlignment.VA_CENTER)
			    self.alert_view:SetOkFunc(function ()
			    	self.alert_view:Close()
			    end)
			    self.alert_view:SetCancelFunc(function ()
			    	CrossServerCtrl.SentCrossTurnBrandReq(1, index)
			    end)
			    self.alert_view:Open()
			else
				CrossServerCtrl.SentCrossTurnBrandReq(1, index)
			end
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
	if not self.data.is_open and CrossServerData.Instance:BrandCanTurn() then
		local flop_consume = CrossServerData.Instance:GetFlopConsume()
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
	is_turning = false
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
	is_turning = true
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

CrossFlopCardRecordRender = CrossFlopCardRecordRender or BaseClass(BaseRender)
function CrossFlopCardRecordRender:__init(w, h, list_view)	
	self.view_size = cc.size(305, 24)
	self.view:setContentSize(self.view_size)
	self.list_view = list_view	
end

function CrossFlopCardRecordRender:__delete()	
end

function CrossFlopCardRecordRender:CreateChild()
	BaseRender.CreateChild(self)
	self.rich_text = RichTextUtil.ParseRichText(nil, "", 20, nil, 0, 0, self.view_size.width, self.view_size.height)
	self.rich_text:setAnchorPoint(0, 0)
	-- self.rich_text:setIgnoreSize(true)
	self.view:addChild(self.rich_text, 9)
end

function CrossFlopCardRecordRender:OnFlush()
	if self.data == nil then return end

	local rolename_color = "CCCCCC"
	local playername = Scene.Instance:GetMainRole():GetName()
	if playername ~= self.data.name then
		rolename_color = "FFFF00"
	end

	local draw_tip = "免费翻牌"
	if TurnOverCardsCfg.extraConsumes[self.data.flop_opt ].count > 0 then
		draw_tip = string.format("花费{color;1eff00;%s钻石}翻牌", TurnOverCardsCfg.extraConsumes[self.data.flop_opt ].count)
	end


	local draw_item = TurnOverCardsCfg.allCards[self.data.pool_idx][self.data.award_idx].awards[1]
	local item_cfg = ItemData.Instance:GetItemConfig(draw_item.id)
	local color = string.format("%06x", item_cfg.color)

	local content = string.format("{rolename;%s;[%s]}%s,获得{color;%s;[%sx%s]}", rolename_color, self.data.name, draw_tip, color, item_cfg.name, draw_item.count)
	-- local content = 1
	RichTextUtil.ParseRichText(self.rich_text, content, 18, COLOR3B.G_W2)
	self.rich_text:refreshView()
	local inner_size = self.rich_text:getInnerContainerSize()
	local size = {
		width = math.max(inner_size.width, self.view_size.width),
		height = math.max(inner_size.height, self.view_size.height),
	}
	self.rich_text:setContentSize(size)
	self.view:setContentSize(size)
	self.list_view:requestRefreshView()
end

function CrossFlopCardRecordRender:CreateSelectEffect()
end

return CrossFlopSubView