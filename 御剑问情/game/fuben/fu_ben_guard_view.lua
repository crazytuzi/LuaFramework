--守护
FuBenGuardView = FuBenGuardView or BaseClass(BaseRender)

local mW = 320
local W = 1000
local MID_X = 3 * mW - W
local CUR_MID_X = 3 * mW - W
function FuBenGuardView:__init(instance)
	self.cur_page = 1

	self.list_view = self:FindObj("PageView")
	self.list = {}
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListCell, self)
	
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	local max_pass_level = info.max_pass_level or -1
	local cur_chapter = max_pass_level + 2
	local chapter_cfg = FuBenData.Instance:GetTowerDefendChapterCfg(max_pass_level + 2)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if chapter_cfg and chapter_cfg.need_level > role_level then
		cur_chapter = max_pass_level + 1
	end

	self.enter_count = 0
	self.can_buy_count = 0
	self.cell_list = {}
	self.item_list = {}


	self.can_challenge_num = self:FindVariable("CanChallengeNum")
	self.can_buy_num = self:FindVariable("CanBuyNum")
	self.title_name = self:FindVariable("TitleName")
	self.auto_gray = self:FindVariable("SaodangGray")
	self.can_challenge = self:FindVariable("CanChallenge")
	self.turntable_info = TurntableInfoCell.New(self:FindObj("Turntable"))

	self:ListenEvent("Challenge",BindTool.Bind(self.OnClickEnter, self))
	self:ListenEvent("Clear",BindTool.Bind(self.OnSaodangEnter, self))
	self:ListenEvent("OnClickBuy",BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self.last_check_time = nil
end

function FuBenGuardView:__delete()
	for k, v in pairs(self.list) do
		v:DeleteMe()
	end
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	
	for k, v in pairs(self.cell_list) do
		v = nil
	end
	if self.reset_timer then
		GlobalTimerQuest:CancelQuest(self.reset_timer)
		self.reset_timer = nil
	end
	if self.turntable_info ~= nil then
		self.turntable_info:DeleteMe()
	end

end

function FuBenGuardView:OpenCallBack()
	self:Flush()
end

function FuBenGuardView:UpdateIndex()
	for k,v in pairs(self.cell_list) do
		if v then
			self.cur_page = k
		end
	end
end

function FuBenGuardView:GetNumberOfCells()
	return 10
end

function FuBenGuardView:RefreshListCell(cell,data_index)
	local guard_item = self.list[cell]
	if guard_item == nil then
		guard_item = FbGuardItem.New(cell.gameObject)
		guard_item.parent_view = self
		self.list[cell] = guard_item
	end
	guard_item:SetData(data_index + 1)
	guard_item:IsSelect(data_index + 1 == self.cur_page)
	if self.cell_list[data_index + 1] == nil then
		self.cell_list[data_index + 1] = guard_item.open
	end 
end

function FuBenGuardView:OnValueChanged(page)
	 	self.cur_page = page
		for k, v in pairs(self.list) do
			v:IsSelect(v.data == self.cur_page)
		end
		self:Flush()
end

function FuBenGuardView:UpdateValue()
	self:UpdateIndex()
	self:Flush()
end

function FuBenGuardView:OnClickEnter(is_sd)
	if self.enter_count > 0 then
		if is_sd then
			FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, self.cur_page - 1)
		else
			FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, self.cur_page - 1)
			FuBenCtrl.Instance:CloseView()
		end
	else
		if self.can_buy_count > 0 then
			local ok_fun = function ()
				FuBenCtrl.SendTowerDefendBuyJoinTimes()
				if is_sd then
					FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, self.cur_page - 1)
				else
					FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, self.cur_page - 1)
					FuBenCtrl.Instance:CloseView()
				end
			end
			local info = FuBenData.Instance:GetTowerDefendRoleInfo()
			local buy_join_times = info.buy_join_times or 0
			local cost = FuBenData.Instance:GetTowerBuyCost(buy_join_times + 1)
			local str = is_sd and Language.TowerDefend.BuyTip3 or Language.TowerDefend.BuyTip2
			local cfg = string.format(str, cost)
			TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
		else
			local count = VipPower.Instance:GetParam(VipPowerId.tower_defend_buy_count)
			local level, param = VipPower.Instance:GetMinVipLevelLimit(VipPowerId.tower_defend_buy_count, count + 1)
			if level < 0 then
				SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.EnterLimitTip)
			else
				TipsCtrl.Instance:ShowLockVipView(VIPPOWER.TOWER_DEFEND_COUNT)
			end
		end
	end
end

function FuBenGuardView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(199)
end

function FuBenGuardView:OnCliclYuanBao()
	ViewManager.Instance:Open(ViewName.Welfare, TabIndex.welfare_goldturn)
end

function FuBenGuardView:OnSaodangEnter()
	self:OnClickEnter(true)
end

function FuBenGuardView:OnClickBuy()
	if self.can_buy_count > 0 then
		local ok_fun = function ()
			FuBenCtrl.SendTowerDefendBuyJoinTimes()
		end
		local info = FuBenData.Instance:GetTowerDefendRoleInfo()
		local buy_join_times = info.buy_join_times or 0
		local cost = FuBenData.Instance:GetTowerBuyCost(buy_join_times + 1)
		local cfg = string.format(Language.TowerDefend.BuyTip, cost)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
	else
		local count = VipPower.Instance:GetParam(VipPowerId.tower_defend_buy_count)
		local level, param = VipPower.Instance:GetMinVipLevelLimit(VipPowerId.tower_defend_buy_count, count + 1)
		if level < 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.BuyLimitTip)
		else
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.TOWER_DEFEND_COUNT)
		end
	end
end

function FuBenGuardView:OnFlush(param)
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	local chapter_cfg = FuBenData.Instance:GetTowerDefendChapterCfg(self.cur_page)
	if nil == chapter_cfg or nil == next(info) then return end
	local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
	self.enter_count = other_cfg.free_join_times + info.buy_join_times - info.join_times
	self.can_challenge_num:SetValue(self.enter_count)
	self.can_buy_count = VipPower.Instance:GetParam(VipPowerId.tower_defend_buy_count) - info.buy_join_times
	self.can_buy_num:SetValue(self.can_buy_count)
	self.title_name:SetValue(chapter_cfg.fb_name)
	self.auto_gray:SetValue(self.cur_page > info.max_pass_level + 1 and info.max_pass_level < 9)
	if self.cur_page == info.max_pass_level + 2 and info.personal_last_level_star == 3 then
		self.auto_gray:SetValue(false)
	end
	for i,v in ipairs(self.item_list) do
		v:Flush()
	end
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local level = self.cur_page - 1
	self.can_challenge:SetValue(level <= info.max_pass_level + 1 and chapter_cfg.need_level <= role_level)
	for k,v in pairs(param) do
		if k == "update" then
			self:UpdateValue()
		end
	end
end

function FuBenGuardView:IsShowEffect()
	self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)
end

FbGuardItem = FbGuardItem or BaseClass(BaseRender)

function FbGuardItem:__init()
	self.title_res = self:FindVariable("TitleRes")
	self.state_res = self:FindVariable("StateRes")
	self.bg_res = self:FindVariable("BgRes")
	self.show_star = self:FindVariable("ShowStar")
	self.is_select = self:FindVariable("IsSelect")
	self.is_open = self:FindVariable("IsOpen")
	self.open_limit_1 = self:FindVariable("OpenLimit1")
	self.open_limit_2 = self:FindVariable("OpenLimit2")
	self.show_limit_1 = self:FindVariable("ShowLimit1")
	self.show_limit_2 = self:FindVariable("ShowLimit2")

	self.item_list = {}
	for i = 1, 2 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		table.insert(self.item_list, item)
	end

	self:ListenEvent("OnClick", BindTool.Bind(self.OnClickItem, self))
end

function FbGuardItem:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function FbGuardItem:SetData(data)
	self.data = data
	if self.data ~= nil then
		self:OnFlush()
	end
end

function FbGuardItem:OnClickItem()
	self.parent_view:OnValueChanged(self.data)
end

function FbGuardItem:IsSelect(value)
	self.is_select:SetValue(value)
end

function FbGuardItem:OnFlush()
	if self.data == nil then return end
	self.title_res:SetAsset(ResPath.GetFbViewImage("defence_stage_" .. self.data))							
	local chapter_cfg = FuBenData.Instance:GetTowerDefendChapterCfg(self.data)
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	if nil == chapter_cfg or nil == next(info) then
		return
	end
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	self.bg_res:SetAsset(ResPath.GetRawImage("defense_bg_" .. self.data .. ".png"))							--chapter_cfg.level_pic
	local level = self.data - 1
	self.open = level <= info.max_pass_level + 1 and chapter_cfg.need_level <= role_level
	self.is_open:SetValue(self.open)
	local color = "00ff06"

	self.show_limit_1:SetValue(false)
	self.show_limit_2:SetValue(false)
	if chapter_cfg.need_level > role_level then
		self.show_limit_1:SetValue(true)
		self.open_limit_1:SetValue(string.format(Language.TowerDefend.TowerChapterLimit1, color, PlayerData.GetLevelString(chapter_cfg.need_level)))
	end
	if level > info.max_pass_level + 1 then
		self.show_limit_2:SetValue(true)
		self.open_limit_2:SetValue(string.format(Language.TowerDefend.TowerChapterLimit2, color))
	end
	if info.max_pass_level + 1 < level then
		self.show_star:SetValue(0)
		self.state_res:SetAsset(ResPath.GetFbViewImage("defense_state_unopen"))
	elseif info.max_pass_level + 1 == level then
		if chapter_cfg.need_level <= role_level then
			self.show_star:SetValue(info.personal_last_level_star)
			self.state_res:SetAsset(ResPath.GetFbViewImage("defense_state_doing"))
		else
			self.show_star:SetValue(0)
			self.state_res:SetAsset(ResPath.GetFbViewImage("defense_state_unopen"))
		end
	else
		self.show_star:SetValue(3)
		self.state_res:SetAsset(ResPath.GetFbViewImage("defense_state_finish"))
	end
	self.item_list[1]:SetData({item_id = chapter_cfg.show_reward, num = 1, is_bind = 0})
	self.item_list[2]:SetData({item_id = chapter_cfg.show_reward_2, num = 1, is_bind = 0})
end