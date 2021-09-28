--幻境
PushSpecialView = PushSpecialView or BaseClass(BaseRender)

function PushSpecialView:__init(instance)
	self.chapter_index = 1
	self.level_index = 1

	self.left_num = self:FindVariable("left_num")
	self.can_saodang = self:FindVariable("can_saodang")
	self.now_rec = self:FindVariable("now_rec")
	self.max_rec = self:FindVariable("max_rec")
	self.is_three_star = self:FindVariable("is_three_star")
	self.show_laft_btn = self:FindVariable("show_laft_btn")
	self.show_right_btn = self:FindVariable("show_right_btn")

	self:ListenEvent("OnClickAddNum", BindTool.Bind(self.OnClickAddNum, self))
	self:ListenEvent("OnClickSaoDang", BindTool.Bind(self.OnClickSaoDang, self))
	self:ListenEvent("OnClickEnterButton", BindTool.Bind(self.OnClickEnterButton, self))
	self:ListenEvent("OnClickLeftButton", BindTool.Bind(self.OnClickLeftButton, self))
	self:ListenEvent("OnClickRightButton", BindTool.Bind(self.OnClickRightButton, self))
	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))

	self.tongguan_des = self:FindVariable("RewardDesc")
	self.item_cells = {}
	for i = 1, 5 do
		self.item_cells[i] = ItemCell.New()
		self.item_cells[i]:SetInstanceParent(self:FindObj("Item"..i))
	end

	self.special_item_list = {}
	self:ReCrateSpecialItemList()

	self.old_pass_chapter = nil
	self.old_pass_level = nil

	--引导用按钮
	self.wujin_enter_button = self:FindObj("EnterButton")

	self.get_ui_callback = BindTool.Bind(self.GetUiCallBack, self)
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.FuBen, self.get_ui_callback)
end

function PushSpecialView:__delete()
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUiByFun(ViewName.FuBen, self.get_ui_callback)
		self.get_ui_callback = nil
	end

	for k,v in pairs(self.special_item_list) do
		self.special_item_list[k]:DeleteMe()
	end

	for k, v in pairs(self.item_cells) do
		v:DeleteMe()
	end
	self.item_cells = {}
	self.old_pass_chapter = nil
	self.old_pass_level = nil

	self.special_item_list = {}
end

function PushSpecialView:OpenCallBack()
	self:Flush()
end

function PushSpecialView:CloseCallBack()
	self.old_pass_chapter = nil
	self.old_pass_level = nil
end

function PushSpecialView:ReCrateSpecialItemList()
	for k,v in pairs(self.special_item_list) do
		self.special_item_list[k]:DeleteMe()
	end
	self.special_item_list = {}
	self.level_index = 1

	for i=1,4 do
		local item_obj = self:FindObj("PushSpecialItem" .. i)
		item_obj.transform.localScale = Vector3(1, 1, 1)
		self.special_item_list[i] = PushSpecialItem.New(item_obj)
		self.special_item_list[i].push_chapter_view = self
		self:ListenEvent("OnClickBoss" .. i, BindTool.Bind(self.OnClickBoss, self, i))
	end
end

function PushSpecialView:FlushBossList()
	local data = self:GetChapterData(self.chapter_index - 1)
	for k,v in pairs(self.special_item_list) do
		if data[k - 1] then
			v:SetData(data[k - 1])
		else
			print("隐藏先不做")
		end
	end
end

function PushSpecialView:GetChapterData(chapter_index)
	local chapter_index = self.chapter_index
	local push_fb_info = {}
	push_fb_info = FuBenData.Instance:GetPushFBInfo(1, chapter_index - 1)
	return push_fb_info
end

function PushSpecialView:OnFlush()
	local data = FuBenData.Instance:GetTuituSpecialFbInfo()

	if self.old_pass_chapter ~= data.pass_chapter then
		self.old_pass_chapter = data.pass_chapter
		self:CalcChapterIndex()
	end

	if self.old_pass_level ~= data.pass_level then
		self.old_pass_level = data.pass_level
		self:CalcLevelIndex()
	end
	self.old_pass_level = nil
	self:FlushBossList()
	self:FlushDetailInfo()
end

function PushSpecialView:FlushDetailInfo()
	local special_info = FuBenData.Instance:GetTuituSpecialFbInfo()
	local special_other_cfg = FuBenData.Instance:GetPushFBOtherCfg()
	local left_num = special_info.buy_join_times - special_info.today_join_times + special_other_cfg.hard_free_join_times
	local is_three_star = FuBenData.Instance:GetOneLevelIsPassAndThreeStar(1, self.chapter_index - 1, self.level_index - 1)
	self.left_num:SetValue(left_num)
	self.now_rec:SetValue(special_info.pass_chapter * 4 + special_info.pass_level)
	self.max_rec:SetValue(special_info.pass_chapter * 4 + special_info.pass_level)
	self.show_laft_btn:SetValue(self.chapter_index > 1)
	self.show_right_btn:SetValue(not self:IsMaxIndex())
	self.is_three_star:SetValue(is_three_star)

	local fuben_cfg = FuBenData.Instance:GetPushFBInfo(1, self.chapter_index - 1, self.level_index - 1)
	local history_star = FuBenData.Instance:GetPushFBLeveLInfo(1, self.chapter_index - 1, self.level_index - 1).pass_star
	self.tongguan_des:SetValue(history_star <= 0 and Language.FB.FirstReward or Language.FB.RewardShow)
	local reward_cfg = history_star <= 0 and fuben_cfg.first_pass_reward or fuben_cfg.normal_reward_item
	self.item_data = {}
	for k, v in pairs(self.item_cells) do
		v:SetActive(false)
		if reward_cfg[k - 1] and reward_cfg[k - 1].item_id > 0 then
			v:SetActive(true)
			v:SetData(reward_cfg[k - 1])
			self.item_data[k] = reward_cfg[k - 1]
		end
	end
end

function PushSpecialView:OnClickAddNum()
	local buy_join_times = FuBenData.Instance:GetTuituSpecialFbInfo().buy_join_times
	local can_buy_times = VipPower.Instance:GetParam(VipPowerId.push_special_buy_times) - buy_join_times
	local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
    local can_buy_count = VipData.Instance:GetVipPowerList(vip_level)[VIPPOWER.PUSH_SPECIAL]
	local ok_fun = function ()
		FuBenCtrl.Instance:SendTuituFbOperaReq(1, 1, 1, param_3)
	end
	local limit_level = VipPower.Instance:GetMinVipLevelLimit(VIPPOWER.PUSH_SPECIAL, buy_join_times + 1) or 0
	if PlayerData.Instance.role_vo.vip_level < limit_level then
		TipsCtrl.Instance:ShowLockVipView(VIPPOWER.PUSH_SPECIAL)
		return
	end
	if can_buy_times > 0 then
		-- if buy_join_times == can_buy_count then
		-- 	TipsCtrl.Instance:ShowLockVipView(VIPPOWER.PUSH_SPECIAL)
		-- 	return
		-- end
		local next_pay_money = FuBenData.Instance:GetPushFBOtherCfg().hard_buy_times_need_gold
		local cfg = string.format(Language.Push[5], next_pay_money)
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, cfg, nil, nil, true, false, "chongzhi")
	else
		-- vip_level == max_vip_level or has_buy_times == max_pay_time then
		SysMsgCtrl.Instance:ErrorRemind(Language.ExpFuBen.TipsText2)
	end
end

function PushSpecialView:OnClickEnterButton()
	local is_three_star = FuBenData.Instance:GetOneLevelIsPassAndThreeStar(1, self.chapter_index - 1, self.level_index - 1)
	if is_three_star then
		FuBenCtrl.Instance:SendTuituFbOperaReq(TUITU_FB_OPERA_REQ_TYPE.TUITU_FB_OPERA_REQ_TYPE_SAODANG, 1, self.chapter_index - 1, self.level_index - 1)
	else
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TUITU_NORMAL_FB, 1, self.chapter_index - 1, self.level_index - 1)
	end
end

function PushSpecialView:OnClickSaoDang()
	FuBenCtrl.Instance:SendTuituFbOperaReq(3, 1, self.chapter_index - 1, self.level_index - 1)
end

function PushSpecialView:OnClickBoss(index)
	local tuitu_info = FuBenData.Instance:GetTuituSpecialFbInfo()
	local OneLevelIsPass = FuBenData.Instance:GetOneLevelIsPassBySpecial(1, self.chapter_index - 1, index - 1)
	if self.chapter_index == tuitu_info.pass_chapter + 1 and index > tuitu_info.pass_level + 1 or not OneLevelIsPass then
		SysMsgCtrl.Instance:ErrorRemind(Language.PushFb.PrveLevelPassLimit)
		return
	end

	for i = 1,4 do
		self.special_item_list[i]:SetHighLight(false)
		if i == index then
			self.special_item_list[i]:SetHighLight(true)
		end
	end

	self:SetLevelIndex(index)
	self:FlushDetailInfo()
end

function PushSpecialView:OnClickLeftButton()
	if self.chapter_index <= 1 then return end

	self:SetChapterIndex(self.chapter_index - 1)
	self:Flush()
end

function PushSpecialView:OnClickRightButton()
	if self:IsMaxIndex() then return end

	self:SetChapterIndex(self.chapter_index + 1)
	self:Flush()
end

function PushSpecialView:IsMaxIndex()
	local max_chapter = #(FuBenData.Instance:GetPushFBChapterInfo(1)) + 1
	local sc_max_chapter = FuBenData.Instance:GetTuituSpecialFbInfo().pass_chapter + 1
	if self.chapter_index >= max_chapter or self.chapter_index >= sc_max_chapter then
		return true
	end
	return false
end

function PushSpecialView:CalcChapterIndex()
	local data = FuBenData.Instance:GetTuituSpecialFbInfo()
	local max_chapter = FuBenData.Instance:GetPushFbMaxChapter(PUSH_FB_TYPE.PUSH_FB_TYPE_HARD)
	local pass_chapter = math.min(data.pass_chapter, max_chapter)
	self:SetChapterIndex(pass_chapter + 1)
end

function PushSpecialView:SetChapterIndex(index)
	if self.chapter_index == index then
		return
	end

	self.chapter_index = index
	--self:ReCrateSpecialItemList()
	self:CalcLevelIndex()
end

function PushSpecialView:CalcLevelIndex()
	local data = FuBenData.Instance:GetTuituSpecialFbInfo()
	local pass_chapter = data.pass_chapter
	local pass_level = data.pass_level
	local OneLevelIsPass = FuBenData.Instance:GetOneLevelIsPassBySpecial(1, self.chapter_index - 1, data.pass_level % 4 + 1)

	if self.chapter_index <= pass_chapter then
		self:SetLevelIndex(1)
	elseif not OneLevelIsPass then
		self:SetLevelIndex(data.pass_level % 4 ~= 0 and data.pass_level % 4 or 1)
	else
		self:SetLevelIndex(data.pass_level % 4 + 1)
	end
end

function PushSpecialView:SetLevelIndex(index)
	-- local old_item = self.special_item_list[self.level_index]
	-- if nil ~= old_item then
	-- 	old_item:OnUnSelect()
	-- end
	for k,v in pairs(self.special_item_list) do
		v:OnUnSelect()
	end

	self.level_index = index
	local select_item = self.special_item_list[index]
	if nil ~= select_item then
		select_item:OnSelect()
	end
end

function PushSpecialView:GetLevelIndex()
	return self.level_index
end

function PushSpecialView:OnClickHelp()
	local tips_id = 205
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PushSpecialView:GetUiCallBack(ui_name, ui_param)
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end

	return nil
end

---------------------PushSpecialItem--------------------------------
PushSpecialItem = PushSpecialItem or BaseClass(BaseCell)
local DISPLAYNAME = {
	[3013001] = "push_special_panel_1",
	[3043001] = "push_special_panel_2",
	[3002001] = "push_special_panel_3",
}
function PushSpecialItem:__init()
	self.push_chapter_view = nil
	self.boss_model_view = RoleModel.New("push_special_panel")

	self.is_pass = self:FindVariable("is_pass")
	self.is_open = self:FindVariable("is_open")
	self.pass_cond = self:FindVariable("pass_cond")
	self.pass_cond1 = self:FindVariable("pass_cond1")
	self.boss_level = self:FindVariable("boss_level")
	self.capability = self:FindVariable("capability")
	self.special_effects = self:FindVariable("special_effects")
	self.boss_display = self:FindObj("boss_display")
	self.anim = self:FindObj("Anim")
	self.high_light = self:FindVariable("high_light")
	self.old_res_id = 0
	self.star_gray_list = {}
	for i=1,3 do
		self.star_gray_list[i] = self:FindVariable("gray_" .. i)
	end

	self:ListenEvent("OnClickEnter", BindTool.Bind(self.OnClickEnter, self))
end

function PushSpecialItem:__delete()
	self.push_chapter_view = nil
	if self.boss_model_view then
		self.boss_model_view:DeleteMe()
		self.boss_model_view = nil
	end
	self.special_effects = nil
end

function PushSpecialItem:SetChapterItemIndex(index)
	self.chapter_item_index = index
end

function PushSpecialItem:OnFlush()
	if self.data == nil then
		self.old_res_id = 0
		return
	end
	local data = self.data
	local special_info = FuBenData.Instance:GetTuituSpecialFbInfo()
	local OneLevelIsPass = FuBenData.Instance:GetOneLevelIsPassBySpecial(data.fb_type, data.chapter, data.level)
	local push_fb_cfg = FuBenData.Instance:GetPushFBInfo(data.fb_type, data.chapter, data.level)
	local res_id = BossData.Instance:GetMonsterInfo(push_fb_cfg.monster_0).resid
	local str1 = ""
	local is_open = self:IsOpen(special_info, data.chapter, data.level)
	if OneLevelIsPass and is_open then
		self.pass_cond:SetValue(false)
	else
		self.pass_cond:SetValue(true)
		str1 = string.format(Language.PushFb.NeedPassOneLeve2, push_fb_cfg.need_pass_chapter + 1, push_fb_cfg.need_pass_level + 1)
	end
	self.pass_cond1:SetValue(str1)
	self.is_pass:SetValue(data.chapter < special_info.pass_chapter or (special_info.pass_level > data.level and data.chapter == special_info.pass_chapter))
	self.is_open:SetValue(is_open)
	self.boss_level:SetValue(data.chapter * 4 + data.level + 1)
	self.capability:SetValue(data.capability)
	local fb_info_list = FuBenData.Instance:GetTuituSpecialFbInfo().chapter_info_list[data.chapter + 1]
	local level_info = fb_info_list.level_info_list[data.level + 1]
	for i=1,3 do
		self.star_gray_list[i]:SetValue(level_info.pass_star >= i)
	end

	self.boss_model_view:SetDisplay(self.boss_display.ui3d_display)
	self.boss_model_view:SetPanelName(self:SetSpecialModle(res_id))
	if self.old_res_id ~= res_id then
		self.old_res_id = res_id
		self.boss_model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
	end
end

function PushSpecialItem:SetHighLight(is_show)
	self.high_light:SetValue(is_show)
end

function PushSpecialItem:IsOpen(special_info, chapter, level)
	local one_level_is_pass = FuBenData.Instance:GetOneLevelIsPassBySpecial(self.data.fb_type, chapter, level)
	return (chapter == 0 and level == 0 and one_level_is_pass) or chapter < special_info.pass_chapter or
						 (one_level_is_pass and special_info.pass_level >= level and chapter == special_info.pass_chapter and (chapter ~= 0 or level ~= 0))
end

function PushSpecialItem:OnSelect()
	self.anim.animator:SetBool("fold", true)
	self.special_effects:SetValue(true)
	self.high_light:SetValue(true)
end

function PushSpecialItem:OnUnSelect()
	self.anim.animator:SetBool("fold", false)
	self.special_effects:SetValue(false)
	self.high_light:SetValue(false)
end

function PushSpecialItem:OnClickEnter()
	FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_TUITU_NORMAL_FB, 1, self.data.chapter, self.data.level)
end

--处理特殊模型大小
function PushSpecialItem:SetSpecialModle(res_id)
	local name = "push_special_panel"
	local id = tonumber(res_id)
	for k,v in pairs(DISPLAYNAME) do
		if k == id then
			return v
		end
	end
	return name
end