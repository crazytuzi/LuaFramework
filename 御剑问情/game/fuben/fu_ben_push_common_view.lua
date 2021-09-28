PushCommonView = PushCommonView or BaseClass(BaseRender)

function PushCommonView:__init(instance)
	if instance == nil then
		return
	end
	self.chapter_index = 1
	self.level_index = 1

	self.pass_normal_reward = self:FindVariable("pass_normal_reward")
	self.enter_num = self:FindVariable("EnterNum")
	self.star_saodang = self:FindVariable("StarSaoDang")
	self.slider_val = self:FindVariable("slider_val")
	self.set_saodang_gray = self:FindVariable("set_saodang_gray")
	self.box_star_num = {}
	self.box_state = {}
	self.box_list = {}
	self.red_point = {}
	self.all_box_list = {}

	self.old_pass_chapter = nil
	self.old_pass_level = nil
	self.old_star_reward_flag = nil

	for i = 1, 3 do
		self.box_list[i] = self:FindObj("box_" .. i)
		self.box_star_num[i] = self:FindVariable("box_star_num_" .. i)
		self.box_state[i] = self:FindVariable("box_state_" .. i)
		self.red_point[i] = self:FindVariable("RedPoint" .. i)
		self:ListenEvent("OnClickStarReward" .. i, BindTool.Bind(self.OnClickStarReward, self, i))

		self.all_box_list[i] = self:FindObj("Box" .. i)
	end

	self.item_list = {}
	for i = 1, 3 do
		self["item_cell"..i] = self:FindVariable("itemcell" .. i)
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("itemcell"..i))
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

	--引导用按钮
	self.yuansu_attack_button = self:FindObj("AttackButton")

	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, self.get_ui_callback)
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

	for k, v in pairs(self.chapter_list) do
		v:DeleteMe()
	end
	self.chapter_list = {}

	for k, v in pairs(self.level_list) do
		v:DeleteMe()
	end
	self.level_list = {}
end


function PushCommonView:FlushLevelHL()
	for k,v in pairs(self.level_list) do
		v:FlushHL()
	end
end

function PushCommonView:FlushBoxPos()
	local pro_length = 456
	local all_star_num = FuBenData.Instance:GetPushFBAllReward(self.chapter_index - 1, 2).star_num or 1

	for i = 1, 3 do
		local star_num = FuBenData.Instance:GetPushFBAllReward(self.chapter_index - 1, i - 1).star_num or 1
		local pos = self.all_box_list[i].transform.localPosition
		self.all_box_list[i].transform:SetLocalPosition(pro_length * star_num / all_star_num, pos.y, pos.z)
	end
end

function PushCommonView:ChapterJumpToIndex()
	local info_list = FuBenData.Instance:GetPushFBChapterInfo(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL)
	local max_chapter = #(info_list) + 1
	local num = (self.chapter_index - 4.5) > 0 and (self.chapter_index - 4.5) or 0
	local pos = num / (max_chapter - 1)
	self.chapter_list_view.scroll_rect.horizontalNormalizedPosition = pos
end

function PushCommonView:LevelJumpToIndex()
	local level_info_list = FuBenData.Instance:GetPushFBInfo(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL, self.chapter_index - 1)
	local max_level = self:GetLevelNumberOfCells()

	local pos = (self.level_index - 1) / (max_level - 1)
	self.level_list_view.scroll_rect.horizontalNormalizedPosition = pos
end

function PushCommonView:OpenCallBack()
	local common_push_list = FuBenData.Instance:GetTuituCommonFbInfo()
	local max_chapter = FuBenData.Instance:GetPushFbMaxChapter(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL)
	self.chapter_index = common_push_list.pass_chapter + 1
	self.chapter_index = math.min(self.chapter_index, max_chapter + 1)

	self.old_star_reward_flag = nil
	self.old_pass_level = nil
	self.timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.ChapterJumpToIndex, self), 0.1)
	self:CalcSelectLevelIndex()
	self:Flush()
	self:FlushLevelHL()
end

function PushCommonView:CloseCallBack()
	for k, v in pairs(self.level_list) do
		v:OnUnSelect()
	end
	self:RemoveDelayTime()
	self:RemoveDelayTimeOne()
	self.old_pass_chapter = nil
	self.old_pass_level = nil
	self.old_star_reward_flag = nil
end

function PushCommonView:OnFlush()
	local data = FuBenData.Instance:GetTuituCommonFbInfo()

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
	self:FlushBoxPos()
end

function PushCommonView:RemoveDelayTime()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function PushCommonView:FlushDetailInfo()
	local tuitu_fb_info = FuBenData.Instance:GetTuituCommonFbInfo()
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
	self:RemoveDelayTimeOne()
	self.timer_quest_1 = GlobalTimerQuest:AddDelayTimer(BindTool.Bind(self.LevelJumpToIndex, self), 0)
	local data = FuBenData.Instance:GetTuituCommonFbInfo()
	self:SetSelectLevelIndex(data.pass_level + 1)
	self:CalcSelectLevelIndex()
end

function PushCommonView:RemoveDelayTimeOne()
	if self.timer_quest_1 then
		GlobalTimerQuest:CancelQuest(self.timer_quest_1)
		self.timer_quest_1 = nil
	end
end

function PushCommonView:GetChapterNumberOfCells()
	local info_list = FuBenData.Instance:GetPushFBChapterInfo(PUSH_FB_TYPE.PUSH_FB_TYPE_NORMAL)
	local max_chapter = #(info_list) + 1

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
	local chapter_info = FuBenData.Instance:GetTuituCommonFbInfo().chapter_info_list
	local bit_list = bit:d2b(chapter_info[self.chapter_index].star_reward_flag)
	local all_star_num = FuBenData.Instance:GetPushFBAllReward(self.chapter_index - 1, 2).star_num or 1
	local total_star = chapter_info[self.chapter_index].total_star
	local next_reward_list = FuBenData.Instance:NextCanGetStarReward(self.chapter_index)
	for i=1,3 do
		local star_num = FuBenData.Instance:GetPushFBAllReward(self.chapter_index - 1, i - 1).star_num or 1
		local box_and_red_point = FuBenData.Instance:CanGetStarReward(self.chapter_index, i - 1)
		self.box_state[i]:SetValue(0 ~= bit_list[33 - i])
		self.box_star_num[i]:SetValue(star_num)
		self.red_point[i]:SetValue(box_and_red_point)
		if box_and_red_point then
			self.box_list[i].animator:SetBool("Shake", true)
		else
			self.box_list[i].animator:SetBool("Shake", false)
		end
	end
	self.slider_val:SetValue(total_star / all_star_num)
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

	local is_pass = false
	if self.chapter_index - 1 < data.pass_chapter then
		is_pass = true
	elseif self.chapter_index - 1 == data.pass_chapter then
		if self.level_index - 1 < data.pass_level then
			is_pass = true
		end
	end

	if not is_pass then
		self.pass_normal_reward:SetValue(Language.PushFb.FirstPassRewardDesc)
	else
		self.pass_normal_reward:SetValue(Language.PushFb.PassRewardDesc)
	end

	for i = 1,3 do
		local item_data = nil
		if is_pass then
			item_data = common_item_list[i]
		else
			item_data = level_cfg.first_pass_reward[i - 1]
		end

		if item_data == nil then
			self["item_cell"..i]:SetValue(false)
			self.item_list[i]:SetItemActive(false)
		else
			self["item_cell"..i]:SetValue(true)
			self.item_list[i]:SetItemActive(true)
			self.item_list[i]:SetData(item_data)
		end
	end
end

function PushCommonView:OnClickStarReward(index)
	local reward_list = FuBenData.Instance:GetStarRewardList(self.chapter_index - 1, index - 1)
	local box_and_red_point = FuBenData.Instance:CanGetStarReward(self.chapter_index, index - 1)
	if not box_and_red_point and reward_list ~= nil then
		TipsCtrl.Instance:ShowRewardView(reward_list)
		return
	end
	FuBenCtrl.Instance:SendTuituFbOperaReq(2, self.chapter_index - 1, index - 1, param_3)
end

function PushCommonView:OnClickAddNum()
	local buy_join_times = FuBenData.Instance:GetTuituCommonFbInfo().buy_join_times
	local can_buy_times = VipPower.Instance:GetParam(VipPowerId.push_common_buy_times) - buy_join_times
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
    local can_buy_count = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.PUSH_COMMON]
	local ok_fun = function ()
		FuBenCtrl.Instance:SendTuituFbOperaReq(1, 0, 1, param_3)
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
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg, nil, nil, true, false, "chongzhi")
	else
		-- vip_level == max_vip_level or has_buy_times == max_pay_time then
		SysMsgCtrl.Instance:ErrorRemind(Language.ExpFuBen.TipsText2)
	end
end

function PushCommonView:OnClickEnterFB()
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TUITU_NORMAL_FB, 0,
		self.chapter_index - 1, self.level_index - 1)
	-- FuBenData.Instance:SetPushFbData(0, self.chapter_index - 1, self.level_index - 1)
end

function PushCommonView:OnClickSaoDang()
	FuBenCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_SAODANG, 0, self.chapter_index - 1, self.level_index - 1)
end

function PushCommonView:OnClickHelp()
	local tips_id = 204
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
	self.boss_icon_level:SetValue(CommonDataManager.GetDaXie(self.chapter_item_index))
	local cur_chapter = FuBenData.Instance:GetTuituCommonFbInfo().pass_chapter or 0
	local chapter_cfg = FuBenData.Instance:GetPushFBChapterCfg(self.chapter_item_index)
	self.open_state:SetValue(cur_chapter + 1 >= self.chapter_item_index or self.chapter_item_index == 1)
	local bundle, asset = "uis/rawimages/boss_" .. chapter_cfg.chapter_head , "boss_"  .. chapter_cfg.chapter_head
	self.chapter_item:SetAsset(bundle, asset)
	local is_show_red_point = false
	for i=1,4 do
		if FuBenData.Instance:CanGetStarReward(self.chapter_item_index, i - 1) then
			is_show_red_point = true
			break
		end
	end
	self.chapter_red_point:SetValue(is_show_red_point)
end

function PushChapterItem:OnClickChapterItem()
	local cur_chapter = FuBenData.Instance:GetTuituCommonFbInfo().pass_chapter or 0
	local select_index = self.push_chapter_view:GetChapterIndex()
	if select_index == self.chapter_item_index then
		return
	end
	if cur_chapter + 1 < self.chapter_item_index then
		return
	end
	self.push_chapter_view:SetChapterIndex(self.chapter_item_index)
	self.push_chapter_view:Flush()
	self.push_chapter_view:FlushChaptherHL()
end

function PushChapterItem:FlushHL()
	local select_index = self.push_chapter_view:GetChapterIndex()
	self.hl_state:SetValue(select_index == self.chapter_item_index)
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

	for i=1,3 do
		self.star_gray_list[i] = self:FindVariable("gray_" .. i)
	end

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickLevelItem, self))
end

function PushLevelItem:__delete()
	self.push_level_view = nil
end

function PushLevelItem:SetLevelItemIndex(index)
	self.level_item_index = index
end

function PushLevelItem:GetLevelItemIndex()
	return self.level_item_index
end

function PushLevelItem:OnFlush()
	self.particle_select:SetValue(false)
	local common_push_list = FuBenData.Instance:GetTuituCommonFbInfo()
	local pass_chapter = common_push_list.pass_chapter
	local pass_level = common_push_list.pass_level

	local chapter_index = self.push_level_view:GetChapterIndex()
	local fb_info_list = FuBenData.Instance:GetTuituCommonFbInfo().chapter_info_list[chapter_index]
	local level_info = fb_info_list.level_info_list[self.level_item_index]
	local last_level_info = fb_info_list.level_info_list[self.level_item_index > 1 and self.level_item_index - 1 or 1]
	local last_last_levle_info = fb_info_list.level_info_list[self.level_item_index > 2 and self.level_item_index - 2 or 1]
	local level_cfg = FuBenData.Instance:GetPushFBInfo(0, chapter_index - 1, self.level_item_index - 1)
	local role_level = GameVoManager.Instance:GetMainRoleVo().level
	local enter_level_limit = level_cfg.enter_level_limit
	self.boss_level:SetValue(self.level_item_index)
	if role_level < enter_level_limit then
		self.pass_cond:SetValue(enter_level_limit)
		self.open_cond:SetValue(true)
	else
		self.open_cond:SetValue(false)
	end

	self.is_level_open = false
	if chapter_index - 1 < pass_chapter then
		self.is_level_open = true
	elseif chapter_index - 1 == pass_chapter then
		if 1 == self.level_item_index or self.level_item_index - 1 <= pass_level then
			self.is_level_open = true
		end
	end

	self.is_open:SetValue(self.is_level_open)

	local bundle, asset = "uis/views/fubenview/images_atlas", "boss_bg_"  .. level_cfg.tuitu_color
	self.boss_bg_path:SetAsset(bundle, asset)

	local bundle2, asset2 = "uis/rawimages/boss_" .. level_cfg.tuitu_pic , "boss_"  .. level_cfg.tuitu_pic
	self.boss_image_path:SetAsset(bundle2, asset2)
	for i=1,3 do
		self.star_gray_list[i]:SetValue(level_info.pass_star >= i)
	end
	self.zhanli_text:SetValue(level_cfg.capability)
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
	end
end

function PushLevelItem:OnSelect()
	self.particle_select:SetValue(true)
	self.anim.animator:SetBool("fold", true)
end

function PushLevelItem:OnUnSelect()
	self.particle_select:SetValue(false)
	self.anim.animator:SetBool("fold", false)
end

function PushLevelItem:FlushHL()
	if self.level_item_index == nil then return end
	local cur_index = self.push_level_view:GetCurLevelIndex()
	self.anim.animator:SetBool("fold", self.level_item_index == cur_index)
	self.particle_select:SetValue(self.level_item_index == cur_index)
end