FuBenGuardView = FuBenGuardView or BaseClass(BaseRender)

local mW = 320
local W = 1000
local MID_X = 3 * mW - W
local CUR_MID_X = 3 * mW - W
function FuBenGuardView:__init(instance)
	self.cur_page = 1

	self.list_view = self:FindObj("PageView")
	self.list = {}
	local list_delegate = self.list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshListCell, self)
	self.list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))
	self.list_view.page_view:Reload()

	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	local max_pass_level = info.max_pass_level or -1
	local cur_chapter = max_pass_level + 2
	local chapter_cfg = FuBenData.Instance:GetTowerDefendChapterCfg(max_pass_level + 2)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	if chapter_cfg and chapter_cfg.need_level > role_level then
		cur_chapter = max_pass_level + 1
	end
	self.list_view.page_view:JumpToIndex(cur_chapter - 1)

	self.enter_count = 0
	self.can_enter_count = 0
	self.cell_list = {}
	self.item_list = {}


	self.can_challenge_num = self:FindVariable("CanChallengeNum")
	self.can_buy_num = self:FindVariable("CanBuyNum")
	self.title_name = self:FindVariable("TitleName")
	self.auto_gray = self:FindVariable("SaodangGray")
	self.can_challenge = self:FindVariable("CanChallenge")
	self.item_image = self:FindVariable("ItemImage")
	self.item_num= self:FindVariable("ItemNum")
	self.show_red_point = self:FindVariable("ShowRedPoint")

	self:ListenEvent("Challenge",BindTool.Bind(self.OnClickEnter, self))
	self:ListenEvent("Clear",BindTool.Bind(self.OnSaodangEnter, self))
	self:ListenEvent("OnClickBuy",BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("OnClickHelp",BindTool.Bind(self.OnClickHelp, self))
	self.last_check_time = nil

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function FuBenGuardView:__delete()
	for k, v in pairs(self.list) do
		v:DeleteMe()
	end
	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	if self.reset_timer then
		GlobalTimerQuest:CancelQuest(self.reset_timer)
		self.reset_timer = nil
	end
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function FuBenGuardView:OpenCallBack()
	self:Flush()
end

function FuBenGuardView:SelectItemCallback(cell)
	if cell == nil or cell.data == nil then return end
	self.list_view.page_view:JumpToIndex(cell.data - 1, 0, 1)
end

function FuBenGuardView:GetData(i)
	local chapter = self.cur_page + i - 3
	if chapter > 10 then
		chapter = chapter - 10
	elseif chapter < 1 then
		chapter = chapter + 10
	end
	return chapter
end

function FuBenGuardView:GetNumberOfCells()
	return 7
end

function FuBenGuardView:RefreshListCell(data_index, cell)
	local guard_item = self.list[cell]
	if guard_item == nil then
		guard_item = FbGuardItem.New(cell.gameObject)
		guard_item:SetClickCallback(BindTool.Bind(self.SelectItemCallback, self))
		guard_item.parent_view = self
		self.list[cell] = guard_item
	end
	guard_item:SetData(data_index + 1)
	guard_item:IsSelect(data_index + 1 == self.cur_page)
end

function FuBenGuardView:OnValueChanged()
	local page = self.list_view.page_view.ActiveCellsMiddleIndex + 1
	if self.cur_page ~= page then
		self.cur_page = page
		for k, v in pairs(self.list) do
			v:IsSelect(v.data == self.cur_page)
		end
		self:Flush()
	end
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
		if self.can_enter_count > 0 then
			-- local ok_fun = function ()
			-- 	FuBenCtrl.SendTowerDefendBuyJoinTimes()
			-- 	if is_sd then
			-- 		FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, self.cur_page - 1)
			-- 	else
			-- 		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, self.cur_page - 1)
			-- 		FuBenCtrl.Instance:CloseView()
			-- 	end
			-- end
			-- local info = FuBenData.Instance:GetTowerDefendRoleInfo()
			-- local buy_join_times = info.buy_join_times or 0
			-- local cost = FuBenData.Instance:GetTowerBuyCost(buy_join_times + 1)
			-- local str = is_sd and Language.TowerDefend.BuyTip3 or Language.TowerDefend.BuyTip2
			-- local cfg = string.format(str, cost)
			-- TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)

			if is_sd then
				FuBenCtrl.Instance:SendAutoFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, self.cur_page - 1)
			else
				FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TOWERDEFEND_PERSONAL, self.cur_page - 1)
				FuBenCtrl.Instance:CloseView()
			end
		else
			SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.EnterLimitTip)
		end
		
	end
end

function FuBenGuardView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(204)
end

function FuBenGuardView:OnSaodangEnter()
	self:OnClickEnter(true)
end

function FuBenGuardView:OnClickBuy()
	if self.can_enter_count > 0 then
		local ok_fun = function ()
			FuBenCtrl.SendTowerDefendBuyJoinTimes()
		end
		local info = FuBenData.Instance:GetTowerDefendRoleInfo()
		local buy_join_times = info.buy_join_times or 0
		local cost = FuBenData.Instance:GetTowerBuyCost(buy_join_times + 1)
		local cfg = string.format(Language.TowerDefend.BuyTip, cost)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg)
	else
		-- local count = VipPower.Instance:GetParam(VipPowerId.tower_defend_buy_count)
		-- local level, param = VipPower.Instance:GetMinVipLevelLimit(VipPowerId.tower_defend_buy_count, count + 1)
		-- if level < 0 then
		-- 	SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.BuyLimitTip)
		-- else
		-- 	TipsCtrl.Instance:ShowLockVipView(VIPPOWER.TOWER_FB_BUY_TIMES)
		-- end

		SysMsgCtrl.Instance:ErrorRemind(Language.TowerDefend.BuyLimitTip)
	end
end

function FuBenGuardView:OnFlush()
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	local chapter_cfg = FuBenData.Instance:GetTowerDefendChapterCfg(self.cur_page)
	if nil == chapter_cfg or nil == next(info) then return end
	local other_cfg = ConfigManager.Instance:GetAutoConfig("towerdefendteam_auto").other[1]
	local towerdefend_other_cfg = FuBenData.Instance:GetTowerDefendOtherCfg()

	--显示道具和次数
	local item_count = ItemData.Instance:GetItemNumInBagById(towerdefend_other_cfg.join_replace_item_id)
	local item_info = ItemData.Instance:GetItemConfig(towerdefend_other_cfg.join_replace_item_id)
	local item_count_str = ""
	if item_count > 0 then
		item_count_str = ToColorStr(item_count, TEXT_COLOR.GREEN)
	else
		item_count_str = ToColorStr(item_count, TEXT_COLOR.RED)
	end
	local str = string.format(Language.FB.ItemNum, item_count_str)
	self.item_image:SetAsset(ResPath.GetItemIcon(towerdefend_other_cfg.join_replace_item_id))
	self.item_num:SetValue(str)

	self.enter_count = towerdefend_other_cfg.free_join_times - info.join_times
	if self.enter_count >=1 then 
		self.can_challenge_num:SetValue(ToColorStr(self.enter_count, TEXT_COLOR.GREEN))
	else
		self.can_challenge_num:SetValue(ToColorStr(self.enter_count, TEXT_COLOR.RED))
	end
	self.show_red_point:SetValue(self.enter_count > 0)

	self.can_enter_count = item_count
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
end

-- 显示道具次数
function FuBenGuardView:FlashNum()
	if other_cfg then
		local item_count = ItemData.Instance:GetItemNumInBagById(other_cfg.join_replace_item_id)
		local item_info = ItemData.Instance:GetItemConfig(other_cfg.join_replace_item_id)
		local str = string.format(Language.FB.ItemNum,item_count)
		-- if day_num >= exp_daily_fb[0].enter_day_times then
		-- 	day_num = exp_daily_fb[0].enter_day_times
		-- end
		--self.day_num:SetValue(exp_daily_fb[0].enter_day_times - day_num)
		
	end
end

function FuBenGuardView:ItemDataChangeCallback()
	self:OnFlush()
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

function FbGuardItem:SetClickCallback(handler)
	self.handler = handler
end

function FbGuardItem:OnClickItem()
	if self.handler then
		self.handler(self)
	end
end

function FbGuardItem:IsSelect(value)
	self.is_select:SetValue(value)
end

function FbGuardItem:OnFlush()
	if self.data == nil then return end
	self.title_res:SetAsset("uis/views/fubenview/images_atlas", "defence_stage_" .. self.data)
	local chapter_cfg = FuBenData.Instance:GetTowerDefendChapterCfg(self.data)
	local info = FuBenData.Instance:GetTowerDefendRoleInfo()
	if nil == chapter_cfg or nil == next(info) then
		return
	end
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local bundle, asset = ResPath.GetRawImage("defense_bg_" .. self.data)
	self.bg_res:SetAsset(bundle, asset)
	local level = self.data - 1
	self.is_open:SetValue(level <= info.max_pass_level + 1 and chapter_cfg.need_level <= role_level)
	local color = chapter_cfg.need_level <= role_level and "00ff00" or "ff0000"
	self.open_limit_1:SetValue(string.format(Language.TowerDefend.TowerChapterLimit1, color, PlayerData.GetLevelString(chapter_cfg.need_level)))
	color = level <= info.max_pass_level + 1 and "00ff00" or "ff0000"
	self.open_limit_2:SetValue(string.format(Language.TowerDefend.TowerChapterLimit2, color))
	if info.max_pass_level + 1 < level then
		self.show_star:SetValue(0)
		self.state_res:SetAsset("uis/views/fubenview/images_atlas", "defense_state_unopen")
	elseif info.max_pass_level + 1 == level then
		if chapter_cfg.need_level <= role_level then
			self.show_star:SetValue(info.personal_last_level_star)
			self.state_res:SetAsset("uis/views/fubenview/images_atlas", "defense_state_doing")
		else
			self.show_star:SetValue(0)
			self.state_res:SetAsset("uis/views/fubenview/images_atlas", "defense_state_unopen")
		end
	else
		self.show_star:SetValue(3)
		self.state_res:SetAsset("uis/views/fubenview/images_atlas", "defense_state_finish")
	end
	self.item_list[1]:SetData({item_id = chapter_cfg.show_reward, num = 1, is_bind = 0})
	self.item_list[2]:SetData({item_id = chapter_cfg.show_reward_2, num = 1, is_bind = 0})
end