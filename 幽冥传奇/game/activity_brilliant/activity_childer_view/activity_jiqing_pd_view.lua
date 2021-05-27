JingqingPDView = JingqingPDView or BaseClass(ActBaseView)

function JingqingPDView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function JingqingPDView:__delete()
	if self.pd_left_scroll_list then
		self.pd_left_scroll_list:DeleteMe()
		self.pd_left_scroll_list = nil
	end

	-- if self.pd_right_scroll_list then
	-- 	self.pd_right_scroll_list:DeleteMe()
	-- 	self.pd_right_scroll_list = nil
	-- end

	-- if self.cell_buyitem_list and nil ~= next(self.cell_buyitem_list) then
	-- 	for k,v in pairs(self.cell_buyitem_list) do
	-- 		v:DeleteMe()
	-- 	end
	-- end
	self.cell_buyitem_list = nil

	if self.buy_shop_list then
		self.buy_shop_list:DeleteMe()
		self.buy_shop_list = nil
	end

	if self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
		self.update_spare_timer = nil
	end

	if self.raking_cell_1 then
		for k,v in pairs(self.raking_cell_1) do
			v:DeleteMe()
		end
		self.raking_cell_1 = {}
	end

	if self.raking_cell_2 then
		for k,v in pairs(self.raking_cell_2) do
			v:DeleteMe()
		end
		self.raking_cell_2 = {}
	end

	if self.raking_cell_3 then
		for k,v in pairs(self.raking_cell_3) do
			v:DeleteMe()
		end
		self.raking_cell_3 = {}
	end
end

function JingqingPDView:InitView()
	--self.node_t_list.btn_goumai_55_1.node:addClickEventListener(BindTool.Bind(self.OnClickJQPDHandler, self, 1))
	-- self.node_t_list.btn_goumai_55_2.node:addClickEventListener(BindTool.Bind(self.OnClickJQPDHandler, self, 2))
	self:CreatPDLeftList()
	self:CreateCell()
	-- self:CreatPDRightList()
	-- self:CreatBuyItemCell()
	self:CreateBuyShopItemList()

	self.update_spare_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateSpareFFTime, self), 1)
end


function JingqingPDView:CreateCell()
	self.raking_cell_1 = {}
	for i = 1, 4 do 
		local cell = ActBaseCell.New()
		local ph = self.ph_list["ph_cell_ranking1_"..i]
		cell:SetPosition(ph.x, ph.y +3)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0, 0)
		self.node_t_list.layout_ranking1.node:addChild(cell:GetView(), 300)
		cell:GetView():setScale(0.9)
		table.insert(self.raking_cell_1, cell)
	end

	self.raking_cell_2 = {}
	for i = 1, 2 do 
		local cell = ActBaseCell.New()
		local ph = self.ph_list["ph_cell_ranking2_"..i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0, 0)
		self.node_t_list.layout_ranking2.node:addChild(cell:GetView(), 300)
		cell:GetView():setScale(0.9)
		table.insert(self.raking_cell_2, cell)
	end


	self.raking_cell_3 = {}
	for i = 1, 2 do 
		local cell = ActBaseCell.New()
		local ph = self.ph_list["ph_cell_ranking3_"..i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0, 0)
		self.node_t_list.layout_ranking3.node:addChild(cell:GetView(), 300)
		cell:GetView():setScale(0.9)
		table.insert(self.raking_cell_3, cell)
	end
	-- bod
	-- body
end

function JingqingPDView:UpdateSpareFFTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JQPD)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.lbl_activity_spare_time55.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function JingqingPDView:RefreshView(param_list)
	-- self.pd_left_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetJQPDLeftItemList())
	-- self.pd_right_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetRankList(ACT_ID.JQPD))
	self.node_t_list.lbl_55_num.node:setString(ActivityBrilliantData.Instance.mine_num[ACT_ID.JQPD])

	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JQPD) 

	if act_cfg and act_cfg.config then
		local cfg = act_cfg.config
		local data = cfg.buyItem
		self.buy_shop_list:SetDataList(data)
		local score = ActivityBrilliantData.Instance.mine_num[ACT_ID.JQPD]
		local reward_data = ActivityBrilliantData.Instance:GetJQPDLeftItemList()
		for k, v in pairs(reward_data) do
			v.is_get = 2
			if score >= v.score  then
				if v.sign == 0 then
					v.is_get = 3
				else
					v.is_get = 1
				end
			end
		end
		
		local function sort_list()	--可领取在上面,已领取在最后,未完成在中间
			return function(c, d)
				if c.is_get ~=d.is_get then
					return c.is_get > d.is_get
				else
					return c.index < d.index
				end
			end
		end
		table.sort(reward_data, sort_list())

		self.pd_left_scroll_list:SetDataList(reward_data)
		self.pd_left_scroll_list:SetSelectItemToTop(1)

		local list_data = ActivityBrilliantData.Instance:GetRankList(ACT_ID.JQPD)
		for i = 1, 3 do
			local data = list_data[i]
			local name = data[2] 
			self.node_t_list["text_name_rank"..i].node:setString(name)
			if i == 1 then
				local rank = data[1]
				local job = data[5]
				local sex = data[6] or 0
				local path = ResPath.GetRoleHead("small_1_".. sex)
				self.node_t_list.img_bg.node:loadTexture(path)
				local ranking_reward = cfg.rankings[rank].award
				for k, v in pairs(self.raking_cell_1) do
					local single_reward = ranking_reward[k]
					local vis = single_reward ~= nil
					v:SetVisible(vis)
					if single_reward then
						v:SetData({item_id = single_reward.id, num = single_reward.count, is_bind = single_reward.bind})
					end
				end
			elseif i == 2 then
				local rank = data[1]
				local ranking_reward = cfg.rankings[rank].award
				for k, v in pairs(self.raking_cell_2) do
					local single_reward = ranking_reward[k]
					local vis = single_reward ~= nil
					v:SetVisible(vis)
					if single_reward then
						v:SetData({item_id = single_reward.id, num = single_reward.count, is_bind = single_reward.bind})
					end
				end
			elseif i == 3 then
				local rank = data[1]
				local ranking_reward = cfg.rankings[rank].award
				for k, v in pairs(self.raking_cell_3) do
					local single_reward = ranking_reward[k]
					local vis = single_reward ~= nil
					v:SetVisible(vis)
					if single_reward then
						v:SetData({item_id = single_reward.id, num = single_reward.count, is_bind = single_reward.bind})
					end
				end
			end

		end
	end

end

-- function JingqingPDView:OnClickJQPDHandler(tag)
-- 	local act_id = ACT_ID.JQPD
--    	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, tag, 1)
-- end


function JingqingPDView:CreateBuyShopItemList( ... )
	if 	nil == self.node_t_list.layout_jingqing_pd then
		return
	end
	if nil == self.buy_shop_list then
		local ph = self.ph_list.ph_buy_shop_list
		-- self.buy_shop_list = ListView.New()
		-- -- self.buy_shop_list:GetView():setAnchorPoint(0, 0)
		-- self.buy_shop_list:Create(ph.x, ph.y, ph.w, ph.h, 3, 120, BuyShopItemRender, ScrollDir.Horizontal, false, self.ph_list.ph_shop_list_item)
		-- self.node_t_list.layout_jingqing_pd.node:addChild(self.buy_shop_list:GetView(), 100)
		--self.buy_shop_list:SetDataList(ActivityBrilliantData.Instance:GetJQPDLeftItemList())
		--self.buy_shop_list:JumpToTop()

		--ph = self.ph_list.ph_qianghua_next_attr
		self.buy_shop_list = ListView.New()
		self.buy_shop_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, BuyShopItemRender, nil, nil, self.ph_list.ph_shop_list_item)
		self.buy_shop_list:SetItemsInterval(-2)
		self.buy_shop_list:GetView():setAnchorPoint(0, 0)
		self.buy_shop_list:SetMargin(2)
		self.node_t_list.layout_jingqing_pd.node:addChild(self.buy_shop_list:GetView(), 50)
	end
end

-- function JingqingPDView:CreatBuyItemCell()
-- 	self.cell_buyitem_list = {}
-- 	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JQPD)
-- 	for i=1,2 do
-- 		local cell = ActBaseCell.New()
-- 		local ph = self.ph_list["ph_cell_55_top_" .. i]
-- 		cell:SetPosition(ph.x, ph.y)
-- 		cell:SetIndex(i)
-- 		cell:SetAnchorPoint(0.5, 0.5)
-- 		self.node_t_list.layout_jingqing_pd.node:addChild(cell:GetView(), 300)
-- 		local item_data = {}
-- 		local data = cfg.config.buyItem[i].award[1]
-- 		if nil ~= data then
-- 			item_data.item_id = data.id
-- 			item_data.num = data.count
-- 			item_data.is_bind = data.bind
-- 			item_data.effectId = data.effectId
-- 			cell:SetData(item_data)
-- 		else
-- 			cell:SetData(nil)
-- 		end
-- 		cell:SetVisible(data ~= nil)
-- 		table.insert(self.cell_buyitem_list, cell)
-- 	end

-- 	--兑换物品
-- 	-- for i=1,2 do
-- 	-- 	local cell = ActBaseCell.New()
-- 	-- 	local ph = self.ph_list["ph_consum_cell_"..i]
-- 	-- 	cell:SetPosition(ph.x, ph.y)
-- 	-- 	cell:SetIndex(i)
-- 	-- 	cell:SetAnchorPoint(0.5, 0.5)
-- 	-- 	self.node_t_list.layout_jingqing_pd.node:addChild(cell:GetView(), 300)
-- 	-- 	local item_data = {}
-- 	-- 	local data = cfg.config.buyItem[i].consume
-- 	-- 	if nil ~= data then
-- 	-- 		if data.type == tagAwardType.qatEquipment then
-- 	-- 			cell:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = data.bind, effectId = data.effectId})
-- 	-- 		else
-- 	-- 			local virtual_item_id = ItemData.GetVirtualItemId(data.type)
-- 	-- 			if virtual_item_id then
-- 	-- 				cell:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind = 0, effectId = data.effectId})
-- 	-- 			end
-- 	-- 		end
-- 	-- 		cell:SetCellBg()
-- 	-- 		cell:GetView():setScale(0.5)
-- 	-- 		self.node_t_list["lbl_55_price_"..i].node:setString(data.count)
-- 	-- 	else
-- 	-- 		cell:SetData(nil)
-- 	-- 	end
-- 	-- 	cell:SetVisible(data ~= nil)
-- 	-- 	table.insert(self.cell_buyitem_list, cell)
-- 	-- end
-- 	self.node_t_list.lbl_55_price_1.node:setString(cfg.config.buyItem[1].consume.count)
-- 	self.node_t_list.lbl_55_price_2.node:setString(cfg.config.buyItem[2].consume.count)
-- end

function JingqingPDView:CreatPDLeftList()
	if 	nil == self.node_t_list.layout_jingqing_pd then
		return
	end
	if nil == self.pd_left_scroll_list then
		local ph = self.ph_list.ph_right_55_list
		

		self.pd_left_scroll_list = ListView.New()
		self.pd_left_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, PdLeftItemRender, nil, nil, self.ph_list.ph_55_left_item)
		self.pd_left_scroll_list:SetItemsInterval(10)
		self.pd_left_scroll_list:GetView():setAnchorPoint(0, 0)
		self.pd_left_scroll_list:SetMargin(10)
		self.node_t_list.layout_jingqing_pd.node:addChild(self.pd_left_scroll_list:GetView(), 50)
		self.pd_left_scroll_list:SetSelectItemToTop(1)
	end
end

function JingqingPDView:CreatPDRightList()
	if 	nil == self.node_t_list.layout_jingqing_pd then
		return
	end
	if nil == self.pd_right_scroll_list then
		local ph = self.ph_list.ph_right_55_list
		self.pd_right_scroll_list = GridScroll.New()
		self.pd_right_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 65, PdRightItemRender, ScrollDir.Vertical, false, self.ph_list.ph_55_right_item)
		self.node_t_list.layout_jingqing_pd.node:addChild(self.pd_right_scroll_list:GetView(), 100)
		self.pd_right_scroll_list:SetDataList(ActivityBrilliantData.Instance:GetRankList(ACT_ID.JQPD))
		self.pd_right_scroll_list:JumpToTop()
	end
end

PdLeftItemRender = PdLeftItemRender or BaseClass(BaseRender)
function PdLeftItemRender:__init()

end

function PdLeftItemRender:__delete()
	if nil ~= self.cell_charge_list then
    	for k,v in pairs(self.cell_charge_list) do
    		v:DeleteMe()
  		end
    	self.cell_charge_list = nil
    end
end

function PdLeftItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_charge_list = {}
	for i = 1, 3 do 
		local cell = ActBaseCell.New()
		local ph = self.ph_list["ph_cell_"..i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0, 0)
		self.view:addChild(cell:GetView(), 300)
		cell:GetView():setScale(0.9)
		table.insert(self.cell_charge_list, cell)
	end
	XUI.AddClickEventListener(self.node_tree.btn_55_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
end

function PdLeftItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
 	local act_id = ACT_ID.JQPD
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index, 2)
end

function PdLeftItemRender:OnFlush()
	if nil == self.data then
		return
	end
	RichTextUtil.ParseRichText(self.node_tree.rich_55_text_1.node, string.format(Language.ActivityBrilliant.JingQingPDLeftText, self.data.score))
	local is_lingqu = self.data.sign > 0
	local can_get_reward = ActivityBrilliantData.Instance.mine_num[ACT_ID.JQPD] >= self.data.score
	-- -- 奖励
	for k,v in pairs(self.cell_charge_list) do
		local item_data = {}
		if nil ~= self.data[k] then
			item_data.item_id = self.data[k].id
			item_data.num = self.data[k].count
			item_data.is_bind = self.data[k].bind
			item_data.effectId = self.data[k].effectId
			v:SetData(item_data)
		else
			v:SetData(nil)
		end
		v:SetVisible(self.data[k] ~= nil)
	end

	if is_lingqu then
		self.node_tree.img_charge_reward_state.node:setVisible(true)
		self.node_tree.btn_55_lingqu.node:setVisible(false)
		self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
	else
		if can_get_reward then
			self.node_tree.img_charge_reward_state.node:setVisible(false)
			self.node_tree.btn_55_lingqu.node:setVisible(true)
		else
			self.node_tree.img_charge_reward_state.node:setVisible(true)
			self.node_tree.btn_55_lingqu.node:setVisible(false)
			self.node_tree.img_charge_reward_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
		end
	end
end

function PdLeftItemRender:CreateSelectEffect()
end

PdRightItemRender = PdRightItemRender or BaseClass(BaseRender)
function PdRightItemRender:__init()

end

function PdRightItemRender:__delete()
	if nil ~= self.show_item then
		self.show_item:DeleteMe()
		self.show_item = nil
	end
end

function PdRightItemRender:CreateChild()
	BaseRender.CreateChild(self)

	self.show_item = ActivityShowItem.New()
end

function PdRightItemRender:OnFlush()
	if nil == self.data then
		return
	end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JQPD)
	local icon_index = self:GetIndex() % 3
	if icon_index == 0 then
		icon_index = 3
	end
	self.node_tree.img_box_1.node:loadTexture(ResPath.GetActivityBrilliant("act_55_box_" .. icon_index))
	self.node_tree.lbl_role_name.node:setString(self.data[2])
	self.node_tree.lbl_55_rank.node:setString(self.data[1])

	self.remind_img = XUI.CreateImageView(200, 60, ResPath.GetMainui("remind_flag"), true)
	self.remind_img:setVisible(false)
	self.node_tree.img_box_1.node:addChild(self.remind_img, 999)

 	local is_can_join_lingqu = false
	if self.data[3] and self.data.is_jion then
		self.node_tree.lbl_55_rank.node:setString(Language.ActivityBrilliant.Text4)
		if ActivityBrilliantData.Instance.mine_num[ACT_ID.JQPD] >= cfg.config.join_award.count then
			is_can_join_lingqu = true
			local playername = Scene.Instance:GetMainRole():GetName()
			self.node_tree.lbl_role_name.node:setString(playername)
			XUI.AddClickEventListener(self.node_tree.img_box_1.node, function () ActivityBrilliantCtrl.Instance.ActivityReq(4, ACT_ID.JQPD, 1, 3) end, true)
			self.remind_img:setVisible(true)
			if self.data[3] == 1 then
				self.remind_img:setVisible(false)
				local img = XUI.CreateImageView(10, 30, ResPath.GetCommon("stamp_1"))
				self.node_tree.img_box_1.node:addChild(img, 999)
			end
		end
	end
	if not is_can_join_lingqu then
		XUI.AddClickEventListener(self.node_tree.img_box_1.node, BindTool.Bind(self.OnClickJQPDHandler, self, self:GetIndex()), true)
	end
end

function PdRightItemRender:OnClickJQPDHandler(tag)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.JQPD)
	local show_list = cfg.config.rankings[tag] and cfg.config.rankings[tag].award
	if self.data[3] and self.data.is_jion then
		show_list = cfg.config.join_award.award
	end
	self.show_item:Open()
	self.show_item:Flush({0}, "all", {show_list = show_list})
end

function PdRightItemRender:CreateSelectEffect()
end


BuyShopItemRender = BuyShopItemRender or BaseClass(BaseRender)
function BuyShopItemRender:__init( ... )
	-- body
end

function BuyShopItemRender:__delete( ... )
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function BuyShopItemRender:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_buy.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
	if self.cell == nil  then
		local ph = self.ph_list.ph_shop_cell
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.view:addChild(self.cell:GetView(),999)
	end

end

function BuyShopItemRender:OnFlush()
	if self.data== nil then
		return
	end

	local award = self.data.award[1]

	self.cell:SetData({item_id = award.id, num = award.count, is_bind = award.bind or 0})

	local item_cfg = ItemData.Instance:GetItemConfig(award.id)

	local name = item_cfg.name
	local color = Str2C3b(string.format("%06x", item_cfg.color))
	self.node_tree.text_item_name.node:setString(name)
	self.node_tree.text_item_name.node:setColor(color)

	local consume = self.data.consume
	local num = consume.count

	if consume.count == 0 then
		num = self.data.score
	end
	self.node_tree.text_price.node:setString(num)

	-- local id = consume.id
	-- if consume.id == 0 and consume.type == 0 and consume.count == 0 then
	-- 	id = self.data.showitemId
	-- end
	-- if id and id ~= 0 then
	-- 	local item_cfg = ItemData.Instance:GetItemConfig(id)
	-- 	local path = ResPath.GetItem(item_cfg.icon)
	-- 	self.node_tree.icon_img.node:loadTexture(path)
	-- 	self.node_tree.icon_img.node:setScale(0.4)
	-- end
	local path = "" 
	local scale = 1
	if consume.type > 0 then
		path = RoleData.GetMoneyTypeIconByAwardType(consume.type)
	else
		local item_cfg = ItemData.Instance:GetItemConfig(id)
		local path = ResPath.GetItem(item_cfg.icon)
		scale = 0.4
	end
	self.node_tree.icon_img.node:loadTexture(path)
	self.node_tree.icon_img.node:setScale(scale)
end

function BuyShopItemRender:OnClickGetRewardBtn()
	local act_id = ACT_ID.JQPD
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.index, 1)
end