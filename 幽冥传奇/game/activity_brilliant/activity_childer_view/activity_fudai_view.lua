FuDaiView = FuDaiView or BaseClass(ActBaseView)

function FuDaiView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function FuDaiView:__delete()
	self:DeleteFudaiTimer()

	if self.fudai_progressbar then
		self.fudai_progressbar:DeleteMe()
		self.fudai_progressbar = nil
	end
	
	if nil ~= self.fudai_grid then
		self.fudai_grid:DeleteMe()
		self.fudai_grid = nil
	end

	if nil ~= self.fudai_award_list then 
		for k,v in pairs(self.fudai_award_list) do
			v:DeleteMe()
		end
		self.fudai_award_list = {}
	end
end

function FuDaiView:InitView()
	local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.FD) or {}
	if nil == act_cfg then return end

	self:CreateFudaiProgressbar()
	self:CreateCellAward()
	self:CreateFudaiGridScroll()
	self.fudai_award_list = {}

	local item_name = act_cfg.config and act_cfg.config.sellItemName or ""
	self.node_t_list.lbl_item_name.node:setString(item_name)

	self.node_t_list.lbl_item_consum.node:setString(act_cfg.config.sellItem[1].count or "")
	self.node_t_list.img_money.node:loadTexture(ActivityBrilliantData.Instance.GetMoneyTypeIcon(act_cfg.config.sellItem[1].moneytype  or  MoneyType.Yuanbao))
	
	XUI.AddClickEventListener(self.node_t_list.btn_goumai.node, BindTool.Bind(self.OnClickFudaiBuyBtn, self))
end

function FuDaiView:RefreshView(param_list)
	local page = self:GetJumpToPage()
	self.fudai_grid:SetDataList(ActivityBrilliantData.Instance:GetFudaiSignList())
	self.fudai_grid:ChangeToPage(page)

	local total_buytime = ActivityBrilliantData.Instance.mine_num[ACT_ID.FD]
	local grid_data_list = self.fudai_grid:GetDataList()
	local cur_data = grid_data_list[#grid_data_list] or {}
	local max_times = cur_data.buytime or 50
	total_buytime = total_buytime > max_times and max_times or total_buytime
	self.fudai_progressbar:SetPercent(total_buytime / max_times * 100)
end

function FuDaiView:ItemConfigCallback()
	self:RefreshView()
end

function FuDaiView:OnClickFudaiBuyBtn()
 	local act_id = ACT_ID.FD
	ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, 0)
end

function FuDaiView:OnClickBigFudaiBtn()
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.FD)
	local item = cfg.config and cfg.config.sellItem and cfg.config.sellItem[1]
	local item_data = ItemData.InitItemDataByCfg(item)
	TipCtrl.Instance:OpenItem(item_data, EquipTip.FROM_NORMAL)
end

function FuDaiView:CreateCellAward()
	self.fudai_award_list = {}
	local data = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.FD).config.randList
	for i = 1, 9 do
		local cell = ActBaseCell.New()
		local ph = self.ph_list["ph_43_cell_" .. i]
		cell:SetPosition(ph.x, ph.y)
		cell:SetIndex(i)
		self.node_t_list.layout_fudai.node:addChild(cell:GetView(), 300)
		table.insert(self.fudai_award_list, cell)
	end
	for k,v in pairs(self.fudai_award_list) do
		v:SetData(ItemData.InitItemDataByCfg(data[k], nil, true))
		v:SetVisible(data[k] ~= nil)
	end
end

function FuDaiView:DeleteFudaiTimer()
	if self.fudai_spare_time ~= nil then
		GlobalTimerQuest:CancelQuest(self.fudai_spare_time)
		self.fudai_spare_time = nil
	end
end

function FuDaiView:UpdateSpareTime(end_time)
	local now_time = TimeCtrl.Instance:GetServerTime()
	local spare_time = end_time - now_time 
	self.node_t_list.lbl_fudai_spare_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function FuDaiView:CreateFudaiGridScroll()
	local ph_shouhun = self.ph_list.ph_fudai_list
	local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.FD)
	local cell_num = #cfg.config.awardList
	if nil == self.fudai_grid  then
		self.fudai_grid = BaseGrid.New() 
		local grid_node = self.fudai_grid:CreateCells({w = ph_shouhun.w, h = ph_shouhun.h, itemRender = self.FudaiItemRender, ui_config = self.ph_list.ph_fudai_item, cell_count = cell_num, col = 6, row = 1})
		self.node_t_list.layout_fudai.node:addChild(grid_node, 300)
		self.fudai_grid:GetView():setPosition(ph_shouhun.x, ph_shouhun.y)
		self.fudai_grid:SetPageChangeCallBack(BindTool.Bind(self.OnFudaiPageChangeCallBack, self))
		self.fudai_grid:SetDataList(ActivityBrilliantData.Instance:GetFudaiSignList())
		self.fudai_grid:SelectCellByIndex(0)
		self.node_t_list.lbl_page_tip.node:setString(string.format(Language.ActivityBrilliant.FudaiTip, 1, self.fudai_grid:GetPageCount()))
	end
end

function FuDaiView:GetJumpToPage()
	local list = ActivityBrilliantData.Instance:GetFudaiSignList()
	local count = self.fudai_grid:GetPageCellCount()
	local page_count = self.fudai_grid:GetPageCount()
	local num = 0
	for k,v in pairs(list) do
		num = num + 1
		if v.sign == 0 then
			return math.floor(num / count) + 1
		end
	end
	return page_count
end

function FuDaiView:OnFudaiPageChangeCallBack()
	self.node_t_list.lbl_page_tip.node:setString(string.format(Language.ActivityBrilliant.FudaiTip, self.fudai_grid:GetCurPageIndex(), self.fudai_grid:GetPageCount()))
end

function FuDaiView:CreateFudaiProgressbar()
	self.fudai_progressbar = ProgressBar.New()
	self.fudai_progressbar:SetView(self.node_t_list.prog9_qh_fd.node)
	self.fudai_progressbar:SetTailEffect(991, nil, true)
	self.fudai_progressbar:SetEffectOffsetX(-20)
	self.fudai_progressbar:SetPercent(0)
end

local FudaiItemRender = FudaiItemRender or BaseClass(BaseRender)
FuDaiView.FudaiItemRender = FudaiItemRender

function FudaiItemRender:__init()
	self:AddClickEventListener()
end

function FudaiItemRender:__delete()
end

function FudaiItemRender:CreateChild()
	BaseRender.CreateChild(self)
end

function FudaiItemRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.img_award_1.node:setGrey(self.data.sign ~= 0)
	self.node_tree.img_charge_reward_1.node:setVisible(self.data.sign == 1)

	local can_lingqu = ActivityBrilliantData.Instance:IsFDLingqu(self.data.index)
	if can_lingqu and self.data.sign == 0 then
		local fade_in = cc.FadeIn:create(0.3)
		local fade_out = cc.FadeOut:create(0.8)
		local sequence = cc.Sequence:create(fade_in,fade_out)
		local forever = cc.RepeatForever:create(sequence)
		self.node_tree.img_remind_flag_1.node:setVisible(true)
		self.node_tree.img_remind_flag_1.node:runAction(forever)
	else
		self.node_tree.img_remind_flag_1.node:setVisible(false)
	end

	local text = ""
	local num = ActivityBrilliantData.Instance.mine_num[ACT_ID.FD]
	text = num >= self.data.buytime and self.data.buytime or num
	self.node_tree.lbl_43_num.node:setString(text .."/"..self.data.buytime)
end

function FudaiItemRender:OnClick()
	local can_lingqu = ActivityBrilliantData.Instance:IsFDLingqu(self.data.index)
	if can_lingqu then
		local act_id = ACT_ID.FD
		ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id, self.data.index)
	else
		self:OpenAwardShowTip()
	end

	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function FudaiItemRender:OpenAwardShowTip()
	local show_list = {}
	for i, item in ipairs(self.data.award) do
		show_list[#show_list + 1] = ItemData.InitItemDataByCfg(item)
	end

	local text = ""
	local num = ActivityBrilliantData.Instance.mine_num[ACT_ID.FD]
	local bool = num >= self.data.buytime
	local cur_times = bool and self.data.buytime or num
	local color = bool and COLORSTR.GREEN or COLORSTR.RED

	-- 例 "累计购买福袋，0/5次可免费领取"
	local text = string.format(Language.ActivityBrilliant.AwardShowText, color, cur_times, self.data.buytime)

	TipCtrl.Instance:OpenAwardShowTip(text, show_list)
end

function FudaiItemRender:CreateSelectEffect()
end