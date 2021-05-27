FireCrackeView = FireCrackeView or BaseClass(ActBaseView)

function FireCrackeView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function FireCrackeView:__delete()
	if self.spare_85_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.spare_85_time)
		self.spare_85_time = nil
	end
	if self.show_list then
		for k , v in pairs(self.show_list) do
			v:DeleteMe()
		end
	end
	if self.cell_list then
		for k , v in pairs(self.cell_list) do
			v:DeleteMe()
		end
	end
	if self.big_cell_list then
		for k,v in pairs(self.big_cell_list) do
			v:DeleteMe()
		end
	end
	if self.charge_grade_list then
		self.charge_grade_list:DeleteMe()
		self.charge_grade_list = nil
	end

	if self.alert_window then
		self.alert_window:DeleteMe()
		self.alert_window = nil
	end
end

function FireCrackeView:InitView()
	 self.cell_list = {}
	 self.show_list = {}
	 self.big_cell_list = {}
	 self:CreateSpareFFTimer()
	 self:GiftShowList()
	 self:MenuAddOnClicklistener()
	 self.node_t_list.rich_recount.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
end

function FireCrackeView:RefreshView()
	local num_count = 0
	-- self.node_t_list.img_firecrackes_top.node:loadTexture(ResPath.GetBigPainting("act_85_top_bg", true))
	-- self.node_t_list.img_big_firecraceke.node:loadTexture(ResPath.GetActivityBrilliant("act_big_firecrackers"))
	local small_firecrackes_list = ActivityBrilliantData.Instance:GetWardList()
	local big_firecrackes_list = ActivityBrilliantData.Instance:GetBigWardList()
	self.node_t_list.rich_recount.node:setVisible(true)
	-- self.node_t_list.lbl_firecrackes_count.node:setVisible(true)
	self.node_t_list.btn_firecrackes_reward.node:setVisible(false)
	-- for i = 1,small_firecrackes_list.small_firecrackes_count do
		-- self.node_t_list["img_friecrackes_" .. i].node:loadTexture(ResPath.GetActivityBrilliant("act_firecrackers"))
	-- end
	if nil ~= big_firecrackes_list then
		for i = 1, big_firecrackes_list.big_firecrackes_rewardcount do
			self.can_reset = false -- 可重置活动
			if nil == self.big_cell_list[i] then
				local big_cell = ActBaseCell.New()
				local bh_x, bh_y = 590, 230--self.node_t_list.img_big_firecraceke.node:getPosition()
				if i == 1 then
					big_cell:SetPosition(bh_x, bh_y + 80 - 23)
					big_cell:SetAnchorPoint(0.5,0.5)
				end
				if i ~= 1 and i % 2 == 0 then
					big_cell:SetPosition(bh_x - 50 , bh_y - (i - 2) * 40 - 23)
					big_cell:SetAnchorPoint(0.5,0.5)
				end
				if i ~= 1 and i % 2 == 1 then
					big_cell:SetPosition(bh_x + 50, bh_y - (i - 3) * 40 - 23)
					big_cell:SetAnchorPoint(0.5,0.5)
				end
				self.big_cell_list[i] = big_cell
				self.node_t_list.layout_act_firecrackes.node:addChild(big_cell:GetView(),300)
				self.big_cell_list[i]:GetView():setVisible(false)
			end
			if 0 ~= big_firecrackes_list[i] then
				local big_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.HDBP).config.big[big_firecrackes_list[i]].award
				self.big_cell_list[i]:SetData({item_id = big_cfg.id, num = big_cfg.count, is_bind = 0})
				self.big_cell_list[i]:GetView():setVisible(true)
				self.can_reset = true
			else
				if big_firecrackes_list[i] == 0 then
					self.big_cell_list[i]:GetView():setVisible(false)
				end
			end
		end
		if self.can_reset  then
			self.node_t_list["btn_firecrackes_reward"].node:setTitleText(Language.Common.Reset)
		else
			self.node_t_list["btn_firecrackes_reward"].node:setTitleText(Language.Common.LingQu)
		end
	end
	if nil ~= small_firecrackes_list then
		for i = 1, small_firecrackes_list.small_firecrackes_count do
			if nil == self.cell_list[i] then
				local cell = ActBaseCell.New()
				local ph_x,ph_y = self.node_t_list["img_friecrackes_" .. i].node:getPosition()
				cell:SetPosition(ph_x, ph_y)
				cell:SetAnchorPoint(0.5,0.5)
				self.cell_list[i] = cell
				self.node_t_list.layout_act_firecrackes.node:addChild(cell:GetView(), 300)
				self.cell_list[i]:GetView():setVisible(false)
			end
			if 0 ~= small_firecrackes_list[i] then
				local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.HDBP).config.small[small_firecrackes_list[i]].award
				self.cell_list[i]:SetData({item_id = cfg.id, num = cfg.count,is_bind = 0})
				self.cell_list[i]:GetView():setVisible(true)
			else
				if small_firecrackes_list[i] == 0 then
					self.cell_list[i]:GetView():setVisible(false)
				end
			end
		end
	end
	for i = 1, small_firecrackes_list.small_firecrackes_count do
		if num_count <= small_firecrackes_list.small_firecrackes_count then
			if small_firecrackes_list[i] ~= 0 then
				num_count = num_count + 1
			end
		end
	end
	-- self.node_t_list.lbl_firecrackes_count.node:setString(small_firecrackes_list.small_firecrackes_count - num_count .. "/12")
	RichTextUtil.ParseRichText(self.node_t_list.rich_recount.node, string.format("  再砸碎{wordcolor;00ffaa;%s}个小鞭炮\n可免费连砸三个大鞭炮", small_firecrackes_list.small_firecrackes_count - num_count))
	if num_count == small_firecrackes_list.small_firecrackes_count then
		self.node_t_list.rich_recount.node:setVisible(false)
		-- self.node_t_list.lbl_firecrackes_count.node:setVisible(false)
		self.node_t_list.btn_firecrackes_reward.node:setVisible(true)
	end
	
	self.nock_num = num_count + 1
end

function FireCrackeView:MenuAddOnClicklistener()
	local all_count = ActivityBrilliantData.Instance:GetWardList().small_firecrackes_count
	for i = 1, all_count do
		XUI.AddClickEventListener(self.node_t_list["img_friecrackes_" .. i].node, BindTool.Bind(self.OnClickShowWardBtn, self, i), false)
	end
	XUI.AddClickEventListener(self.node_t_list.btn_firecrackes_reward.node,BindTool.Bind(self.OnClickBigGift,self, all_count+1), false)
end

function FireCrackeView:OnClickShowWardBtn(index)
	local count = ActivityBrilliantData.Instance:GetWardList().firecrackes_open_count + 1

	if self.alert_window == nil then
		self.alert_window = AlertConsumTip.New()
	end
	self.alert_window:SetOkString(Language.Common.Cancel)
    self.alert_window:SetCancelString("消声")

    local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.HDBP)
    local config = act_cfg.config or {}
    local consume = config.consume or {}
    local consume_count = consume[count] or 0
    local gold_consum_per = config.reel.yb * consume_count
    local item_cfg = ItemData.Instance:GetItemConfig(config.reel.id)
    local color = string.sub(string.format("%06x", item_cfg.color), 1, 6)
    local text = string.format("{color;%s;%s}可获得一份奖励,\n物品不足时每次消声消耗{color;1eff00;%s钻石}", color, item_cfg.name, gold_consum_per)
    self.alert_window:SetLableString5(text, RichVAlignment.VA_CENTER)

    local path =  ResPath.GetCommon("gold")
   local  need_text = string.format(Language.Lianyu.Consume_Show, path, gold_consum_per)

   self.alert_window:SetLableString6(need_text, RichVAlignment.VA_CENTER)
   self.alert_window:SetConsume(config.reel.id, consume_count)
    self.alert_window:SetCancelFunc(function ()
    	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.HDBP, index)
    	ActivityBrilliantCtrl.ActivityReq(3,ACT_ID.HDBP)
    end)
	self.alert_window:SetOkFunc(function ()
    	self.alert_window:Close()
    end)
    self.alert_window:Open()
end

function FireCrackeView:OnClickBigGift(index)
	local big_firecrackes_list = ActivityBrilliantData.Instance:GetBigWardList()
	if self.can_reset then
		local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.HDBP)
		local config = cfg and cfg.config or {}
		local cannon_count = config.cannonCount or 0
		local big_count = config.bigCount or 0
		local index2 = cannon_count + big_count + 1
		ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.HDBP, index2)
	else
		ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.HDBP, index)
	end
	-- TipsCtrl.Instance:OpenFireReTip()	
end

function FireCrackeView:GiftShowList()
	local show = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.HDBP).config.show
	local temp_list = {}
	local data_list = {}
	for k, v in pairs(show) do
		if type(v) == "table" then
			table.insert(data_list, ItemData.FormatItemData(v))
		end
	end
	for i = 0, (#show - 1) do
		temp_list[i] = data_list[i+1]
	end
	if nil == self.charge_grade_list then
		local ph = self.ph_list.ph_test_bg
		self.charge_grade_list = BaseGrid.New()
		local grid_node = self.charge_grade_list:CreateCells({w=ph.w, h=ph.h, cell_count = #show, col=6, row=1, itemRender = BaseCell})
		grid_node:setPosition(ph.x,ph.y)
		grid_node:setAnchorPoint(0.5,0.5)
		self.node_t_list.layout_act_firecrackes.node:addChild(grid_node, 100)
		self.charge_grade_list:SetDataList(temp_list)
	end
end

function FireCrackeView:UpdateSpareFFTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.HDBP)
	if nil == cfg then return end
	local now_time =TimeCtrl.Instance:GetServerTime()
	local end_time = cfg.end_time 
	local spare_time = end_time - now_time 
	self.node_t_list.lbl_friecrackes_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function FireCrackeView:CreateSpareFFTimer()
	self.spare_85_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareFFTime, self), 1)
end