HuntTreasureView = HuntTreasureView or BaseClass(ActBaseView)

function HuntTreasureView:__init(view, parent, act_id)
    self:LoadView(parent)
    self.item_config_bind = BindTool.Bind(self.RefreshView, self)
    self.itemdata_change_callback = BindTool.Bind(self.FlushConsume, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	ItemData.Instance:NotifyItemConfigCallBack(self.item_config_bind)
end

function HuntTreasureView:__delete()
   if self.jifen_progressbar then
		self.jifen_progressbar:DeleteMe()
		self.jifen_progressbar = nil
	end
	if self.treasure_record_list then
		self.treasure_record_list:DeleteMe()
		self.treasure_record_list = nil
	end
	self.page_index = nil
	
	if ItemData.Instance then
		ItemData.Instance:UnNotifyItemConfigCallBack(self.item_config_bind)
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
	end

	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
	end
end

function HuntTreasureView:InitView()
	self.page_index = 1
	self.bar_pos = {0,25, 50, 75}
	self.cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
   	self:InitPoodCell()
   	self:CreateGridScroll()
   	self:CreateProgressbar()
   	self:UpdateTreasureRecord()
   	if nil ~= self.update_spare_timer then
		GlobalTimerQuest:CancelQuest(self.update_spare_timer)
	end
	self.update_spare_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareTime, self), 1)
  	self.node_t_list.btn_oncetime.node:addClickEventListener(BindTool.Bind(self.OnClicOnceTime, self))
  	self.node_t_list.btn_tentime.node:addClickEventListener(BindTool.Bind(self.OnClicTenTime, self))
  	self.node_t_list.btn_cangku.node:addClickEventListener(BindTool.Bind(self.OnClickOpenExploreBag, self))
  	self.node_t_list.btn_tips.node:addClickEventListener(BindTool.Bind(self.OnClickTips, self))
end

function HuntTreasureView:CloseCallBack()
	if self.reward_cell_list then
    	self.reward_cell_list:DeleteMe()
    	self.reward_cell_list = nil
   	end
end

function HuntTreasureView:InitPoodCell()
	self.reward_cell_list = {}
	for i = 1, 7 do
		local cell_ph = nil
		cell_ph = self.ph_list["ph_cell_".. i]
		if nil == cell_ph then
			break
		end
		local cell = TreasureCell.New()
		cell:SetPosition(cell_ph.x, cell_ph.y)
		cell:SetIndex(i)
		cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_hunt_treasure.node:addChild(cell:GetView(), 103)
		table.insert(self.reward_cell_list, cell)
	end
end

function HuntTreasureView:FlushPoodCell()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
	if cfg.config.displayAwards then
   		for k,v in pairs(cfg.config.displayAwards) do
   			local data = ItemData.Instance:GetItemConfig(v.id)
   			if data then
   				self.reward_cell_list[k]:SetData({icon = data.icon, item_id = data.item_id, is_bind = v.bind, effectId = v.effectId})
   			end
   		end
   	end	
end

function HuntTreasureView:UpdateSpareTime()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
	if nil == cfg then
		return
	end
	
	local now_time = TimeCtrl.Instance:GetServerTime()
	local str = TimeUtil.FormatSecond2Str(cfg.end_time - now_time)
	self.node_t_list.layout_hunt_treasure.lbl_activity_spare_time.node:setString(str)

end

function HuntTreasureView:FlushConsume()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
	if cfg then
		self.node_t_list.btn_oncetime.node:setTitleText(string.format(Language.ActivityBrilliant.HuntTreasureTimes,cfg.config.grade[1].times))
		self.node_t_list.btn_tentime.node:setTitleText(string.format(Language.ActivityBrilliant.HuntTreasureTimes,cfg.config.grade[2].times))
   		for k,v in pairs(cfg.config.grade) do
   			if v.times == 1 then
   				self.node_t_list.lbl_gold_num.node:setString(v.firstConsume.yb)
   				self.node_t_list.lbl_need_num.node:setString(v.firstConsume.count)
   				local item_cfg = ItemData.Instance:GetItemConfig(v.firstConsume.id)
   				if item_cfg then
   					self.node_t_list.img_item_icon.node:loadTexture(ResPath.GetItem(item_cfg.icon))
   					self.node_t_list.img_item_icon.node:setScale(0.6)
   					local have_num = ItemData.Instance:GetItemNumInBagById(item_cfg.item_id)
   					self.node_t_list.lbl_have_num.node:setString(string.format(Language.ActivityBrilliant.HaveTreasureNum,have_num))
   				end
   			end
   		end
   	end
end

function HuntTreasureView:CreateGridScroll()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
	if nil == cfg then return end
	local ph_list = self.ph_list.ph_reward_list
	local cell_num = #cfg.config.integralAward
	if nil == self.treasure_grid  then
		self.treasure_grid = BaseGrid.New() 
		local grid_node = self.treasure_grid:CreateCells({w = ph_list.w, h = ph_list.h, itemRender = JiFenItemRender, ui_config = self.ph_list.ph_reward_item, cell_count = cell_num, col = 3, row = 1})
		self.node_t_list.layout_hunt_treasure.node:addChild(grid_node, 100)
		self.treasure_grid:GetView():setPosition(ph_list.x, ph_list.y)
		self.treasure_grid:SetPageChangeCallBack(BindTool.Bind(self.OnTreasurePageChangeCallBack, self))
		self.treasure_grid:SelectCellByIndex(0)
	end
end

function HuntTreasureView:UpdateTreasureRecord()
	if nil == self.treasure_record_list then
		local ph = self.ph_list.ph_record_list
		self.treasure_record_list = ListView.New()
		self.treasure_record_list:Create(ph.x, ph.y, ph.w, ph.h, nil, TreasureRecordRender, nil, nil, self.ph_list.ph_record_item)
		self.treasure_record_list:GetView():setAnchorPoint(0, 0)
		self.treasure_record_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_hunt_treasure.node:addChild(self.treasure_record_list:GetView(), 100)
	end		
end

function HuntTreasureView:FlushTreasureRecord()
	self.treasure_record_list:SetDataList(ActivityBrilliantData.Instance:GetTreasureRecord())
end

function HuntTreasureView:OnTreasurePageChangeCallBack(grid, page_index, prve_page_index)
	self.page_index = page_index
	local per = self:GetBarPer(page_index)
	self.jifen_progressbar:SetPercent(per,false)
end

function HuntTreasureView:FlushBarPer()
	local per = self:GetBarPer(self.page_index)
	self.jifen_progressbar:SetPercent(per,false)
end

function HuntTreasureView:CreateProgressbar()
	local per = self:GetBarPer()
	self.jifen_progressbar = ProgressBar.New()
	self.jifen_progressbar:SetView(self.node_t_list.prog9_qh.node)
	self.jifen_progressbar:SetTailEffect(991, nil, true)
	self.jifen_progressbar:SetEffectOffsetX(-20)
	self.jifen_progressbar:SetPercent(per,false)
end

function HuntTreasureView:GetBarPer(page_index)
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
	local index = 0
	local page_index = page_index
	for i = 1, #cfg.config.integralAward do
		local need_score = cfg.config.integralAward[i].needIntegral
		if ActivityBrilliantData.Instance:GetTreasureScore() < need_score  then
			index = i - 1
			break
		else
			index = 999
		end
	end
	local per = 100
	local score = ActivityBrilliantData.Instance:GetTreasureScore()
	if index == 999 then
		per = 100
	elseif index >= 3 and (nil == page_index or 1 == page_index) then
		per = 100
	elseif page_index and page_index > 1 and index < 3 then
		per = self.bar_pos[1]
	elseif index < 3 and (nil == page_index or 1 == page_index) then
		local need_num = 0
		if cfg.config.integralAward[index] ~= nil then
			need_num = cfg.config.integralAward[index].needIntegral
		end
		per = ((score - need_num) / (cfg.config.integralAward[index + 1].needIntegral - need_num)) * 25 + self.bar_pos[index + 1]
	elseif index >= 3 and page_index > 1 then
		local need_num = cfg.config.integralAward[index].needIntegral
		per = ((score - need_num) / (cfg.config.integralAward[index + 1].needIntegral - need_num)) * 25 + self.bar_pos[index%3 + 1]
	end
	return per
end

function HuntTreasureView:RefreshView(param_list)
	self.node_t_list.lbl_score.node:setString(ActivityBrilliantData.Instance:GetTreasureScore())
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
	local beg_time = os.date("*t", cfg.beg_time)
	local end_time = os.date("*t", cfg.end_time)
	local str_time = string.format(Language.ActivityBrilliant.AboutTime, beg_time.month, beg_time.day, beg_time.hour, beg_time.min)
	local str_time_2 = string.format(Language.ActivityBrilliant.AboutTime, end_time.month, end_time.day, end_time.hour, end_time.min)
	self.node_t_list.layout_hunt_treasure.lbl_activity_time.node:setString(str_time .. "-" .. str_time_2)

	self:FlushTreasureRecord()
	self:FlushConsume()
	local integralAward = {}
	for k,v in pairs(cfg.config.integralAward) do
		integralAward[k - 1] = v
	end
	self.treasure_grid:SetDataList(integralAward)
	self:FlushBarPer()
	self:FlushPoodCell()
end

function HuntTreasureView:OnClicOnceTime()
	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.SLLB, 2,1)
end

function HuntTreasureView:OnClicTenTime()
	ActivityBrilliantCtrl.ActivityReq(4, ACT_ID.SLLB, 2,2)
end

function HuntTreasureView:OnClickOpenExploreBag()
	ExploreCtrl.Instance:SendReturnWarehouseDataReq()
	ViewManager.Instance:Open(ViewName.Explore, TabIndex.explore_storage)
end

function HuntTreasureView:OnClickTips()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
	local act_desc = Split(cfg.act_desc, "#") --#号之后为btn_act_tips文本
	DescTip.Instance:SetContent(act_desc[2] or act_desc[1], Language.ActivityBrilliant.ActTip)
end

JiFenItemRender = JiFenItemRender or BaseClass(BaseRender)
function JiFenItemRender:__init()
	self:AddClickEventListener()
	
end

function JiFenItemRender:__delete()
end

function JiFenItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_yilingqu.node:setVisible(false)
	self.node_tree.img_remind.node:setVisible(false)
end

function JiFenItemRender:OnFlush()
	if self.data then
		self.node_tree.lbl_text_1.node:setString(string.format(Language.ActivityBrilliant.HaveScore, self.data.needIntegral))
		self.node_tree.btn_box_1.node:addClickEventListener(BindTool.Bind(self.OnClickLinQu, self))
		local index = self:GetIndex()
		local list = bit:d2b(ActivityBrilliantData.Instance:GetTreasureReward())
		local is_finished = list[33- (index + 1)]
		if is_finished == 1 then
			self.node_tree.img_yilingqu.node:setVisible(true)
			self.node_tree.img_remind.node:setVisible(false)
			self.node_tree.btn_box_1.node:setTouchEnabled(false)
		else
			if self.data.needIntegral <= ActivityBrilliantData.Instance:GetTreasureScore() then
				self.node_tree.img_yilingqu.node:setVisible(false)
				self.node_tree.img_remind.node:setVisible(true)
				self.node_tree.btn_box_1.node:setTouchEnabled(true)
			else
				self.node_tree.img_yilingqu.node:setVisible(false)
				self.node_tree.img_remind.node:setVisible(false)
				self.node_tree.btn_box_1.node:setTouchEnabled(true)
			end
		end
	end
end

function JiFenItemRender:OnClick()
end

function JiFenItemRender:OnClickLinQu()
	local index = self:GetIndex()
	
	self.award_view = TreasureAwardView.New(index + 1)
	self.award_view:Open()

end

-- 创建选中特效
function JiFenItemRender:CreateSelectEffect()
end

TreasureRecordRender = TreasureRecordRender or BaseClass(BaseRender)
function TreasureRecordRender:__init()	
end

function TreasureRecordRender:__delete()	
end

function TreasureRecordRender:CreateChild()
	BaseRender.CreateChild(self)
end

function TreasureRecordRender:OnFlush()
	if self.data == nil then return end
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.SLLB)
	if nil == cfg then return end
	local id = cfg.config.awardPood[tonumber(self.data.index)].id
	local count = cfg.config.awardPood[tonumber(self.data.index)].count

	if  ActivityBrilliantData.Instance == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(id)
	if nil == item_cfg then 
		return 
	end
	local color = string.format("%06x", item_cfg.color)
	local playername = Scene.Instance:GetMainRole():GetName()
	local text = {}
	-- if playername == self.data.name then
	-- 	self.rolename_color = "CCCCCC"
	-- else
		self.rolename_color = "1eff00"
	-- end
	local item_name = ItemData.Instance:GetItemName(id)
	-- local text2  = self.data.name ..item_name
	local text = string.format(Language.ActivityBrilliant.Txt, self.rolename_color, self.rolename_color, self.data.name, self.rolename_color, Language.ActivityBrilliant.GetSomething, color, item_cfg.name ,id,color,count)
	RichTextUtil.ParseRichText(self.node_tree.rich_world_reward.node,text, 18)
end

function TreasureRecordRender:CreateSelectEffect()
end

-----------------------------------------------------------------
TreasureCell = TreasureCell or BaseClass(BaseCell)
function TreasureCell:OnFlush()
    BaseCell.OnFlush(self)
    self:SetQualityEffect(self.data and self.data.effectId or 0)
end