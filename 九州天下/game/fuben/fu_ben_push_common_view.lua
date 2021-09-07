PushCommonView = PushCommonView or BaseClass(BaseRender)
local BOX_NUM = 4
local REAWRD_ITEM_NUM = 2

function PushCommonView:__init(instance)
	if instance == nil then
		return
	end
	self.chapter_index = 1
	self.level_index = 1

	self.old_pass_chapter = nil
	self.old_pass_level = nil
	self.old_star_reward_flag = nil
end

function PushCommonView:__delete()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.FuBen, self.get_ui_callback)
		self.get_ui_callback = nil
	end

	for k, v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}

	for k, v in pairs(self.day_item_list) do
		v:DeleteMe()
	end
	self.day_item_list = {}

	for k, v in pairs(self.chapter_list) do
		v:DeleteMe()
	end
	self.chapter_list = {}

	for k, v in pairs(self.level_list) do
		v:DeleteMe()
	end
	self.level_list = {}
end

function PushCommonView:LoadCallBack()
	self.pass_normal_reward = self:FindVariable("pass_normal_reward")
	self.enter_num = self:FindVariable("EnterNum")
	self.star_saodang = self:FindVariable("StarSaoDang")
	-- self.slider_val = self:FindVariable("slider_val")
	self.set_saodang_gray = self:FindVariable("set_saodang_gray")
	self.is_show_pass = self:FindVariable("IsShowPass")

	self.box_star_num = {}
	self.box_state = {}
	self.box_list = {}
	self.red_point = {}
	self.box_res = {}
	self.box_open_res = {}

	for i = 1, BOX_NUM do
		self.box_list[i] = self:FindObj("box_" .. i)
		self.box_star_num[i] = self:FindVariable("box_star_num_" .. i)
		self.box_state[i] = self:FindVariable("box_state_" .. i)
		self.red_point[i] = self:FindVariable("RedPoint" .. i)
		self.box_res[i] = self:FindVariable("BoxRes" .. i)
		self.box_open_res[i] = self:FindVariable("BosOpenRes" .. i)
		self:ListenEvent("OnClickStarReward" .. i, BindTool.Bind(self.OnClickStarReward, self, i))
	end

	self.item_list = {}
	for i = 1, REAWRD_ITEM_NUM do
		self["item_cell"..i] = self:FindVariable("itemcell" .. i)
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("itemcell"..i))
	end

	self.day_item_list = {}
	for i = 1, REAWRD_ITEM_NUM do
		self["day_item_cell"..i] = self:FindVariable("ShowDayItem" .. i)
		self.day_item_list[i] = ItemCell.New()
		self.day_item_list[i]:SetInstanceParent(self:FindObj("DayItem"..i))
	end

	self.chapter_list = {}
	self.chapter_list_view = self:FindObj("BossChapterList")
	local chapter_list_delegate = self.chapter_list_view.list_simple_delegate
	chapter_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetChapterNumberOfCells, self)
	chapter_list_delegate.CellRefreshDel = BindTool.Bind(self.ChapterRefreshCell, self)

	self.level_list = {}
	self.level_list_view = self:FindObj("BossLevelList")
	local level_list_delegate = self.level_list_view.list_simple_delegate
	level_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetLevelNumberOfCells, self)
	level_list_delegate.CellRefreshDel = BindTool.Bind(self.LevelRefreshCell, self)
	self.level_list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.FlushLevelHL, self))

	self:ListenEvent("OnClickAddNum", BindTool.Bind(self.OnClickAddNum, self))
	self:ListenEvent("OnClickEnterFB", BindTool.Bind(self.OnClickEnterFB, self))
	self:ListenEvent("OnClickSaoDang", BindTool.Bind(self.OnClickSaoDang, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))

	self.slider = self:FindObj("Slider"):GetComponent(typeof(UnityEngine.UI.Slider))

	--引导用按钮
	self.yuansu_attack_button = self:FindObj("AttackButton")

	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, self.get_ui_callback)
end


function PushCommonView:FlushLevelHL()
	for k,v in pairs(self.level_list) do
		v:FlushHL()
	end
end

function PushCommonView:ChapterJumpToIndex()
	-- local info_list = FuBenData.Instance:GetPushFBChapterInfo(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL)
	-- local max_chapter = #(info_list) + 1
	-- local num = (self.chapter_index - 6.5) > 0 and (self.chapter_index - 6.5) or 0
	-- local pos = num / (max_chapter - 1)
	self.chapter_list_view.scroll_rect.verticalNormalizedPosition = 0
end

function PushCommonView:LevelJumpToIndex()
	local level_info_list = FuBenData.Instance:GetPushFBInfo(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL, self.chapter_index - 1)
	local max_level = self:GetLevelNumberOfCells()

	local pos = (self.level_index - 1) / (max_level - 1)
	self.level_list_view.scroll_rect.horizontalNormalizedPosition = pos
end

function PushCommonView:OpenCallBack()
	local common_push_list = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == common_push_list then
		return
	end

	FuBenData.Instance:SetOpenCommonView()

	local max_chapter = FuBenData.Instance:GetPushFbMaxChapter(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL)
	self.chapter_index = common_push_list.pass_chapter + 1
	self.chapter_index = math.min(self.chapter_index, max_chapter + 1)
	self.old_star_reward_flag = nil
	self.old_pass_level = nil

	GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.ChapterJumpToIndex, self), 0.4)
	self:CalcSelectLevelIndex()
	self:Flush()
	self:FlushLevelHL()
end

function PushCommonView:CloseCallBack()
	for k, v in pairs(self.level_list) do
		v:OnUnSelect()
	end

	self.old_pass_chapter = nil
	self.old_pass_level = nil
	self.old_star_reward_flag = nil
end

function PushCommonView:OnFlush()
	local data = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == data then
		return
	end
	self:FlushDetailInfo()
	self:FlushBoxList()

	local is_need_update_chapter = false
	local cur_star_reward_flag = data.chapter_info_list[self.chapter_index].star_reward_flag
	if self.old_star_reward_flag ~= cur_star_reward_flag then
		self.old_star_reward_flag = cur_star_reward_flag
		is_need_update_chapter = true
	end

	if self.old_pass_chapter ~= data.pass_chapter then
		self.old_pass_chapter = data.pass_chapter
		is_need_update_chapter = true
		self:FlushChaptherHL()
	end

	if is_need_update_chapter then
		self:FlushChapther()
	end

	if self.old_pass_level ~= data.pass_level then
		self.old_pass_level = data.pass_level
		self:FlushLevel()
	end

	self:FlushItemRewardShow()
end

function PushCommonView:FlushDetailInfo()
	local tuitu_fb_info = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == tuitu_fb_info then
		return
	end
	local push_star_reward = FuBenData.Instance:GetPushFBStarReward()
	local free_join_times = FuBenData.Instance:GetPushFBOtherCfg().normal_free_join_times
	local push_fb_cfg = FuBenData.Instance:GetPushFBInfo(0, self.chapter_index - 1, self.level_index - 1)
	self.enter_num:SetValue(tuitu_fb_info.buy_join_times - tuitu_fb_info.today_join_times + free_join_times)
	if nil ~= push_fb_cfg then
		self.star_saodang:SetValue(push_fb_cfg.saodang_star_num or 0)
	end

	self.set_saodang_gray:SetValue(FuBenData.Instance:GetOneLevelIsPassAndThreeStar(0, self.chapter_index - 1, self.level_index - 1))
end

function PushCommonView:FlushChapther()
	self.chapter_list_view.scroller:RefreshActiveCellViews()
end

function PushCommonView:FlushChaptherHL()
	for k,v in pairs(self.chapter_list) do
		v:FlushHL()
	end
end

function PushCommonView:FlushLevel()
	self.level_list_view.scroller:ReloadData(0)
	GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.LevelJumpToIndex, self), 0)
	local data = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == data then
		return
	end
	self:SetSelectLevelIndex(data.pass_level + 1)
	self:CalcSelectLevelIndex()
end

function PushCommonView:GetChapterNumberOfCells()
	local info_list_cfg = FuBenData.Instance:GetPushFBChapterInfo(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL)
	local info_list = FuBenData.Instance:GetTuituCommonFbInfo()
	local max_chapter = 0
	if info_list_cfg and info_list then
		local max_chapter_cfg = #(info_list_cfg) + 1
		local cur_chapter = info_list.pass_chapter + 1
		max_chapter = cur_chapter + 1
		
		return max_chapter > max_chapter_cfg and max_chapter_cfg or max_chapter
	end
	return max_chapter
end

function PushCommonView:ChapterRefreshCell(cell, data_index)
	data_index = data_index + 1
	local chapter_cell = self.chapter_list[cell]
	if chapter_cell == nil then
		chapter_cell = PushChapterItem.New(cell.gameObject)
		chapter_cell.root_node.toggle.group = self.chapter_list_view.toggle_group
		chapter_cell.push_chapter_view = self
		self.chapter_list[cell] = chapter_cell
	end
	self:Flush()
	chapter_cell:SetChapterItemIndex(data_index)
	chapter_cell:SetData({})
end

function PushCommonView:GetCurLevelIndex()
	return self.level_index or 1
end

function PushCommonView:GetChapterIndex()
	return self.chapter_index or 1
end

function PushCommonView:SetChapterIndex(index)
	self.chapter_index = index
	self:FlushLevel()
end

function PushCommonView:GetLevelNumberOfCells()
	local chpater_info_list = FuBenData.Instance:GetPushFBChapterInfo(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL)
	local level_info_list = FuBenData.Instance:GetPushFBInfo(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL, self.chapter_index - 1)
	local sc_info_list = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == sc_info_list then
		return 0
	end
	local cur_chapter = sc_info_list.pass_chapter
	local cur_level = sc_info_list.pass_level
	local max_level = #(level_info_list) + 1
	if cur_chapter > self.chapter_index then
		return max_level
	end
	if self.chapter_index == cur_chapter + 1 and max_level > cur_level + 1 then
		max_level = cur_level + 2
	end
	return max_level < 4 and 4 or max_level
end

function PushCommonView:LevelRefreshCell(cell, data_index)
	data_index = data_index + 1
	local level_cell = self.level_list[cell]
	if level_cell == nil then
		level_cell = PushLevelItem.New(cell.gameObject)
		level_cell.root_node.toggle.group = self.level_list_view.toggle_group
		level_cell.push_level_view = self
		self.level_list[cell] = level_cell
	end

	level_cell:SetLevelItemIndex(data_index)
	level_cell:SetData({})
end

function PushCommonView:GetLevelItem(level_index)
	for _, v in pairs(self.level_list) do
		if v:GetLevelItemIndex() == self.level_index then
			return v
		end
	end

	return nil
end

function PushCommonView:CalcSelectLevelIndex()
	local data = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == data then
		return
	end
	local pass_chapter = data.pass_chapter
	local pass_level = data.pass_level

	if self.chapter_index <= pass_chapter then
		self:SetSelectLevelIndex(1)
	else
		self:SetSelectLevelIndex(data.pass_level + 1)
	end
end

function PushCommonView:SetSelectLevelIndex(index)
	-- GlobalTimerQuest:AddDelayTimer(BindTool.Bind(function ()
		local old_item = self:GetLevelItem(self.level_index)
		if nil ~= old_item then
			old_item:OnUnSelect()
		end

		self.level_index = index
			local select_item = self:GetLevelItem(index)
			if nil ~= select_item then
				select_item:OnSelect()
			end
	-- end), 0.05)
end

function PushCommonView:FlushBoxList()
	local data = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == data then
		return
	end
	local chapter_info = data.chapter_info_list
	local bit_list = bit:d2b(chapter_info[self.chapter_index].star_reward_flag)
	local all_star_num = FuBenData.Instance:GetPushFBAllReward(self.chapter_index - 1, 3).star_num or 1
	local total_star = chapter_info[self.chapter_index].total_star
	local next_reward_list = FuBenData.Instance:NextCanGetStarReward(self.chapter_index)
	local get_box_num = 0
	for i = 1, BOX_NUM do
		local star_num = FuBenData.Instance:GetPushFBAllReward(self.chapter_index - 1, i - 1).star_num or 1
		local box_and_red_point = FuBenData.Instance:CanGetStarReward(self.chapter_index, i - 1)
		local state = 0 ~= bit_list[33 - i]
		self.box_state[i]:SetValue(state)
		self.box_star_num[i]:SetValue(star_num)
		self.red_point[i]:SetValue(box_and_red_point)
		if box_and_red_point then
			self.box_list[i].animator:SetBool("Shake", true)
		else
			self.box_list[i].animator:SetBool("Shake", false)
		end

		self.box_res[i]:SetAsset(ResPath.GetFuBenImage("Box_" .. (state and 1 or 0) .. i - 1))
		self.box_open_res[i]:SetAsset(ResPath.GetFuBenImage("Box_" .. (state and 1 or 0) .. i - 1))

		if state then
			get_box_num = get_box_num + 1
		end
	end

	if self.cur_select_level and self.cur_select_level == self:GetChapterIndex() then
		return
	end
	self.cur_select_level =	self:GetChapterIndex()

	if get_box_num >= BOX_NUM then
		self.slider.value = 1
	else
		local value = total_star / all_star_num
		self.slider.value = 0
		if self.slider_tweener then
			self.slider_tweener:Pause()
		end
		self.slider_tweener = self.slider:DOValue(value, value, false)
		self.slider_tweener:SetEase(DG.Tweening.Ease.Linear)
		-- self.slider_val:SetValue(total_star / all_star_num)
	end	
end

function PushCommonView:FlushItemRewardShow()
	local level_cfg = FuBenData.Instance:GetPushFBInfo(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL, self.chapter_index - 1, self.level_index - 1)
	if nil == level_cfg then
		return
	end

	local prof = GameVoManager.Instance:GetMainRoleVo().prof
	local common_item_list = {}
	for i = 0, #level_cfg.normal_reward_item do
		local item_cfg = ItemData.Instance:GetItemConfig(level_cfg.normal_reward_item[i].item_id)
		if item_cfg and (item_cfg.limit_prof == 5 or item_cfg.limit_prof == prof) then
			table.insert(common_item_list, level_cfg.normal_reward_item[i])
		end
	end
	local data = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == data then
		return
	end

	local is_pass = false
	if self.chapter_index - 1 < data.pass_chapter then
		is_pass = true
	elseif self.chapter_index - 1 == data.pass_chapter then
		if self.level_index - 1 < data.pass_level then
			is_pass = true
		end
	end

	if self.is_show_pass ~= nil then
		self.is_show_pass:SetValue(is_pass)
	end
	-- if not is_pass then
	-- 	self.pass_normal_reward:SetValue(Language.PushFb.FirstPassRewardDesc)
	-- else
	-- 	self.pass_normal_reward:SetValue(Language.PushFb.PassRewardDesc)
	-- end

	for i = 1, REAWRD_ITEM_NUM do
		--local item_data = nil
		-- if is_pass then
		-- 	item_data = common_item_list[i]
		-- else
		local item_data = level_cfg.first_pass_reward[i - 1]
		--end
		if item_data == nil then
			self["item_cell"..i]:SetValue(false)
			self.item_list[i]:SetItemActive(false)
		else
			self["item_cell"..i]:SetValue(true)
			self.item_list[i]:SetItemActive(true)
			self.item_list[i]:SetData(item_data)
		end

		local day_item = level_cfg.daily_reward[i - 1]
		if day_item == nil then
			self["day_item_cell"..i]:SetValue(false)
			self.day_item_list[i]:SetItemActive(false)
		else
			self["day_item_cell"..i]:SetValue(true)
			self.day_item_list[i]:SetItemActive(true)
			self.day_item_list[i]:SetData(day_item)
		end
	end
end

function PushCommonView:OnClickStarReward(index)
	local reward_list = FuBenData.Instance:GetStarRewardList(self.chapter_index - 1, index - 1)
	if reward_list ~= nil then
		local box_and_red_point = FuBenData.Instance:CanGetStarReward(self.chapter_index, index - 1)
		if box_and_red_point then
			FuBenCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_FETCH_STAR_REWARD, self.chapter_index - 1, index - 1)
		else
			TipsCtrl.Instance:ShowStarRewardView(reward_list, true, nil, false)
		end
	end
end

function PushCommonView:OnClickAddNum()
	local data = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == data then
		return
	end
	local buy_join_times = data.buy_join_times
	local can_buy_times = VipPower.Instance:GetParam(VipPowerId.push_common_buy_times) - buy_join_times
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
    local can_buy_count = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.PUSH_COMMON]
	local ok_fun = function ()
		FuBenCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_BUY_TIMES, 0, 1, param_3)
	end
	local limit_level = VipPower.Instance:GetMinVipLevelLimit(VIPPOWER.PUSH_COMMON, buy_join_times + 1) or 0
	if PlayerData.Instance.role_vo.vip_level < limit_level then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.PUSH_COMMON)
		return
	end
	if can_buy_times > 0 then
		-- if buy_join_times == can_buy_count then
		-- 	TipsCtrl.Instance:ShowLockVipView(VIPPOWER.PUSH_COMMON)
		-- 	return
		-- end
		local next_pay_money = FuBenData.Instance:GetPushFBOtherCfg().normal_buy_times_need_gold
		local cfg = string.format(Language.Push[5], next_pay_money)
		-- TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg, nil, nil, true, false, "chongzhi")
		TipsCtrl.Instance:ShowCommonAutoView("chongzhi", cfg, ok_fun)
	else
		-- vip_level == max_vip_level or has_buy_times == max_pay_time then
		SysMsgCtrl.Instance:ErrorRemind(Language.ExpFuBen.TipsText2)
	end
end

function PushCommonView:OnClickEnterFB()
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TUITU_NORMAL_FB, 0,
		self.chapter_index - 1, self.level_index - 1)
	FuBenData.Instance:SetPushFbData(0, self.chapter_index - 1, self.level_index - 1)
end

function PushCommonView:OnClickSaoDang()
	FuBenCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_SAODANG, 0, self.chapter_index - 1, self.level_index - 1)
end

function PushCommonView:OnClickHelp()
	local tips_id = 203
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PushCommonView:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end

	return nil
end

---------------------PushChapterItem--------------------------------
PushChapterItem = PushChapterItem or BaseClass(BaseCell)

function PushChapterItem:__init()
	self.push_chapter_view = nil
	self.boss_icon_level = self:FindVariable("boss_icon_level")
	self.hl_state = self:FindVariable("HL_state")
	self.chapter_item = self:FindVariable("chapter_item")
	self.open_state = self:FindVariable("open_state")
	self.chapter_red_point = self:FindVariable("RedPoint")
	self.show_select = self:FindVariable("ShowSelect")

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickChapterItem, self))
end

function PushChapterItem:__delete()
	self.push_chapter_view = nil
end

function PushChapterItem:SetChapterItemIndex(index)
	self.chapter_item_index = index
end

function PushChapterItem:OnFlush()
	self:FlushHL()
	self.boss_icon_level:SetValue(CommonDataManager.GetDaXie(self.chapter_item_index, nil, true))
	local data = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == data then
		return
	end
	local cur_chapter = data.pass_chapter or 0
	local chapter_cfg = FuBenData.Instance:GetPushFBChapterCfg(self.chapter_item_index)
	self.open_state:SetValue(cur_chapter + 1 >= self.chapter_item_index or self.chapter_item_index == 1)
	local bundle, asset = "uis/views/fubenview_images", "boss_"  .. chapter_cfg.chapter_head
	self.chapter_item:SetAsset(bundle, asset)
	local is_show_red_point = false
	
	for i=1,4 do
		if FuBenData.Instance:CanGetStarReward(self.chapter_item_index, i - 1) then
			is_show_red_point = true
			break
		end
	end

	if is_show_red_point == false and FuBenData.Instance:GetShowRedPoint(self.chapter_item_index) == nil and FuBenData.Instance:IsEnoughStar(self.chapter_item_index) then
		is_show_red_point = true
		FuBenData.Instance:SetShowRedPoint(self.chapter_item_index, 1)
	end
	
	self.chapter_red_point:SetValue(is_show_red_point)
end

function PushChapterItem:OnClickChapterItem()
	local data = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == data then
		return
	end
	local cur_chapter = data.pass_chapter or 0
	local select_index = self.push_chapter_view:GetChapterIndex()
	if select_index == self.chapter_item_index then
		return
	end
	if cur_chapter + 1 < self.chapter_item_index then
		SysMsgCtrl.Instance:ErrorRemind(Language.PushFb.PrveChapterPassLimit)
		return
	end

	if FuBenData.Instance:GetShowRedPoint(self.chapter_item_index) ~= nil and FuBenData.Instance:GetShowRedPoint(self.chapter_item_index) == 1 then
		FuBenData.Instance:SetShowRedPoint(self.chapter_item_index, 2)
	end

	self.push_chapter_view:SetChapterIndex(self.chapter_item_index)
	self.push_chapter_view:Flush()
	self.push_chapter_view:FlushChaptherHL()
end

function PushChapterItem:FlushHL()
	local select_index = self.push_chapter_view:GetChapterIndex()
	--self.hl_state:SetValue(select_index == self.chapter_item_index)
	if self.show_select ~= nil then
		self.show_select:SetValue(select_index == self.chapter_item_index)
	end
end

---------------------PushLevelItem--------------------------------
PushLevelItem = PushLevelItem or BaseClass(BaseCell)

function PushLevelItem:__init()
	self.push_level_view = nil
	self.boss_level = self:FindVariable("boss_level")
	self.open_cond = self:FindVariable("open_cond")
	self.is_open = self:FindVariable("is_open")
	self.pass_cond = self:FindVariable("pass_cond")
	self.boss_bg_path = self:FindVariable("boss_bg_path")
	self.boss_image_path = self:FindVariable("boss_image_path")
	self.zhanli_text = self:FindVariable("zhanli_text")
	self.anim = self:FindObj("Anim")
	self.particle_select = self:FindVariable("particle_select")
	self.particle_select:SetValue(false)
	self.star_gray_list = {}
	self.is_level_open = false
	self.is_select = false

	self.show_star = self:FindVariable("ShowStar")

	for i=1,3 do
		self.star_gray_list[i] = self:FindVariable("gray_" .. i)
	end

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickLevelItem, self))
end

function PushLevelItem:__delete()
	self.push_level_view = nil
	self.is_select = false
end

function PushLevelItem:SetLevelItemIndex(index)
	self.level_item_index = index
	self:CheckIsSHowParticle()
end

function PushLevelItem:GetLevelItemIndex()
	return self.level_item_index
end

function PushLevelItem:OnFlush()
	self.particle_select:SetValue(false)
	local common_push_list = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == common_push_list then
		return
	end
	local pass_chapter = common_push_list.pass_chapter
	local pass_level = common_push_list.pass_level

	local chapter_index = self.push_level_view:GetChapterIndex()
	local fb_info_list = common_push_list.chapter_info_list[chapter_index]
	if fb_info_list == nil then
		self.particle_select:SetValue(false)
		return
	end

	local level_info = fb_info_list.level_info_list[self.level_item_index]
	local last_level_info = fb_info_list.level_info_list[self.level_item_index > 1 and self.level_item_index - 1 or 1]
	local last_last_levle_info = fb_info_list.level_info_list[self.level_item_index > 2 and self.level_item_index - 2 or 1]
	local level_cfg = FuBenData.Instance:GetPushFBInfo(0, chapter_index - 1, self.level_item_index - 1)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local enter_level_limit = level_cfg.enter_level_limit
	self.boss_level:SetValue(CommonDataManager.GetDaXie(self.level_item_index))
	if role_level < enter_level_limit then
		self.pass_cond:SetValue(enter_level_limit)
		self.open_cond:SetValue(true)
	else
		self.open_cond:SetValue(false)
	end

	self:CheckIsSHowParticle()
	-- self.is_level_open = false
	-- if chapter_index - 1 < pass_chapter then
	-- 	self.is_level_open = true
	-- elseif chapter_index - 1 == pass_chapter then
	-- 	if 1 == self.level_item_index or self.level_item_index - 1 <= pass_level then
	-- 		self.is_level_open = true
	-- 	end
	-- end

	self.is_open:SetValue(self.is_level_open)
	--self.particle_select:SetValue(self.is_level_open or self.is_select)
	--self.show_star:SetValue(self.is_level_open or self.is_select)

	local bundle, asset = "uis/views/fubenview/images_atlas", "boss_bg_"  .. level_cfg.tuitu_color
	self.boss_bg_path:SetAsset(bundle, asset)

	local bundle2, asset2 = ResPath.GetRawImage("boss_" .. level_cfg.tuitu_pic)
	self.boss_image_path:SetAsset(bundle2, asset2)

	for i=1,3 do
		self.star_gray_list[i]:SetValue(level_info.pass_star >= i)
	end
	self.zhanli_text:SetValue(level_cfg.capability_show)
end

function PushLevelItem:OnClickLevelItem(is_click)
	if is_click then
		if not self.is_level_open then
			SysMsgCtrl.Instance:ErrorRemind(Language.PushFb.PrveLevelPassLimit)
			return
		end

		self.push_level_view:SetSelectLevelIndex(self.level_item_index)
		self.push_level_view:FlushDetailInfo()
		self.push_level_view:FlushItemRewardShow()
		self.push_level_view:LevelJumpToIndex()
	end
end

function PushLevelItem:OnSelect()
	self.particle_select:SetValue(true)
	self.anim.animator:SetBool("fold", true)
	self.is_select = true
	self:CheckIsSHowParticle()
end

function PushLevelItem:OnUnSelect()
	self.particle_select:SetValue(false)
	self.anim.animator:SetBool("fold", false)
	self.is_select = false
	self:CheckIsSHowParticle()
end

function PushLevelItem:FlushHL()
	if self.level_item_index == nil then return end
	local cur_index = self.push_level_view:GetCurLevelIndex()
	self.anim.animator:SetBool("fold", self.level_item_index == cur_index)
	self.is_select = self.level_item_index == cur_index
	--self.particle_select:SetValue(self.level_item_index == cur_index)
	self:CheckIsSHowParticle()
end

function PushLevelItem:CheckIsSHowParticle()
	if self.level_item_index == nil or self.push_level_view == nil then
		self.particle_select:SetValue(false)
		return
	end

	local chapter_index = self.push_level_view:GetChapterIndex()
	local common_push_list = FuBenData.Instance:GetTuituCommonFbInfo()
	if nil == common_push_list then
		return
	end
	local pass_chapter = common_push_list.pass_chapter
	local pass_level = common_push_list.pass_level

	self.is_level_open = false
	if chapter_index - 1 < pass_chapter then
		self.is_level_open = true
	elseif chapter_index - 1 == pass_chapter then
		if 1 == self.level_item_index or self.level_item_index - 1 <= pass_level then
			self.is_level_open = true
		end
	end

	self.show_star:SetValue(self.is_level_open or self.is_select)
	self.particle_select:SetValue(self.is_level_open and self.is_select)
end