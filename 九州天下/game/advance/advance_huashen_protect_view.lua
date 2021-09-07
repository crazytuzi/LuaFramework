AdvanceHuashenProtectView = AdvanceHuashenProtectView or BaseClass(BaseRender)

function AdvanceHuashenProtectView:__init(instance)
	self:ListenEvent("StartAdvance",
		BindTool.Bind(self.OnStartAdvance, self))
	self:ListenEvent("AutomaticAdvance",
		BindTool.Bind(self.OnAutomaticAdvance, self))
	-- self:ListenEvent("OnClickUse",
	-- 	BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickBall1",
		BindTool.Bind(self.OnClickBall, self, 0))
	self:ListenEvent("OnClickBall2",
		BindTool.Bind(self.OnClickBall, self, 1))
	self:ListenEvent("OnClickBall3",
		BindTool.Bind(self.OnClickBall, self, 2))
	self:ListenEvent("OnClickBall4",
		BindTool.Bind(self.OnClickBall, self, 3))
	self:ListenEvent("OnClickBall5",
		BindTool.Bind(self.OnClickBall, self, 4))
	-- self:ListenEvent("OnClickHuanHua",
	-- 	BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickLastButton",
		BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton",
		BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnClickTrunLeft",
		BindTool.Bind(self.OnClickTrunLeft, self))
	self:ListenEvent("OnClickTrunRight",
		BindTool.Bind(self.OnClickTrunRight, self))

	self.name = self:FindVariable("Name")
	self.rank = self:FindVariable("Rank")
	self.fight_power = self:FindVariable("FightPower")
	self.bag_num = self:FindVariable("RemainderNum")
	self.need_num = self:FindVariable("NeedNun")
	-- self.quality = self:FindVariable("QualityBG")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.prop_name = self:FindVariable("PropName")
	self.cur_jinhua_value = self:FindVariable("CurBless")
	self.value_radio = self:FindVariable("ExpRadio")

	self.cur_gongji = self:FindVariable("CurGongji")
	self.cur_fangyu = self:FindVariable("CurFangyu")
	self.cur_maxhp = self:FindVariable("CurMaxhp")
	self.cur_mingzhong = self:FindVariable("CurMingzhong")
	self.cur_shanbi = self:FindVariable("CurShanbi")

	self.next_gongji = self:FindVariable("NextGongji")
	self.next_fangyu = self:FindVariable("NextFangyu")
	self.next_maxhp = self:FindVariable("NextMaxhp")
	self.next_mingzhong = self:FindVariable("NextMingzhong")
	self.next_shanbi = self:FindVariable("NextShanbi")

	self.show_next_attr = self:FindVariable("ShowNextAttr")
	self.show_use_button = self:FindVariable("UseButton")
	self.show_use_image_sprite = self:FindVariable("UseImage")
	self.show_last_button = self:FindVariable("LeftButton")
	self.show_next_button = self:FindVariable("RightButton")
	self.show_huanhua_redpoint = self:FindVariable("ShowHuanhuaRedPoint")
	self.show_grade = self:FindVariable("ShowGrade")

	self.display = self:FindObj("Display")

	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.start_button = self:FindObj("StartButton")
	self.auto_button = self:FindObj("AutoButton")
	self.gray_use_button = self:FindObj("GrayUseButton")

	self.ball_toggle_list = {
		self:FindObj("BallToggle1").toggle,
		self:FindObj("BallToggle2").toggle,
		self:FindObj("BallToggle3").toggle,
		self:FindObj("BallToggle4").toggle,
		self:FindObj("BallToggle5").toggle,
	}

	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.cur_select_img = 0
	self.click_ball_index = 0
	self.cur_ball_level = 0
	self.is_first_open = false
	self.is_trun = false
end

function AdvanceHuashenProtectView:__delete()
	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end

	self.cur_select_img = nil
	self.jinjie_next_time = nil
	self.click_ball_index = nil
	self.is_first_open = nil
	self.cur_ball_level = nil
	self.is_auto = nil
	self.ball_toggle_list = {}
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.is_trun = nil
end

-- 开始进阶
function AdvanceHuashenProtectView:OnStartAdvance()
	local grade_cfg = HuashenData.Instance:GetHuashenProtectLevelCfg(self.cur_select_img, self.click_ball_index, self.cur_ball_level + 1)

	if not grade_cfg then self:SetAdvanceButtonState() return end

	-- local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0
	local item_id = grade_cfg.consume_item_id

	if ItemData.Instance:GetItemNumInBagById(item_id) < grade_cfg.consume_item_count and 0 == is_auto_buy then
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[item_id]
		self.is_auto = false
		self.is_can_auto = true
		self:SetAdvanceButtonState()

		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(item_id)
			return
		end

		-- if item_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowShopView(item_id, 2)
		-- 	return
		-- end

		local func = function(item_id2, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end
		local nofunc = function()
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, item_id, nofunc,
			(grade_cfg.consume_item_count - ItemData.Instance:GetItemNumInBagById(item_id)))
		return
	end

	HuashenCtrl.Instance:SendHuaShenOperaReq(HUASHEN_REQ_TYPE.HUASHEN_REQ_TYPE_UPGRADE_SPIRIT, self.cur_select_img, self.click_ball_index, 0)
	self.jinjie_next_time = Status.NowTime + 0.1
end

function AdvanceHuashenProtectView:OnSpiritUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAdvanceButtonState()
	elseif 1 == result then
		self:AutoUpGradeOnce()
	end
end

function AdvanceHuashenProtectView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.cur_ball_level < HuashenData.Instance:GetHuashenProtectMaxLevel(self.cur_select_img) then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

-- 自动进阶
function AdvanceHuashenProtectView:OnAutomaticAdvance()
	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		self.is_can_auto = false
		self.is_auto = self.is_auto == false
		self:OnStartAdvance()
		self:SetAdvanceButtonState()
	end

	local function canel_callback()
		self:SetAdvanceButtonState()
	end

	TipsCtrl.Instance:ShowCommonAutoView("auto_huashen_protect_up", Language.Mount.AutoUpDes, ok_callback, canel_callback, true)
end

-- -- 使用当前坐骑
-- function AdvanceHuashenProtectView:OnClickUse()
-- 	print("点击使用按钮")
-- 	if self.index == nil then
-- 		return
-- 	end
-- 	MountCtrl.Instance:SendUseMountImage(self.index)
-- end

function AdvanceHuashenProtectView:OnClickTrunRight()
	if self.model then
		local ball = self.model.draw_obj:GetRoot().transform:Find("BallModles(Clone)")
		if ball then
			self.is_trun = true
			local ball_tween = ball.transform:DOLocalRotate(Vector3(0, -72, 0), 3.0, DG.Tweening.RotateMode.LocalAxisAdd)
			ball_tween:SetEase(DG.Tweening.Ease.Linear)
			ball_tween:OnComplete(function()
				self.is_trun = false
			end)
		end
	end
end

function AdvanceHuashenProtectView:OnClickTrunLeft()
	if self.model then
		local ball = self.model.draw_obj:GetRoot().transform:Find("BallModles(Clone)")
		if ball then
			self.is_trun = true
			local ball_tween = ball.transform:DOLocalRotate(Vector3(0, 72, 0), 3.0, DG.Tweening.RotateMode.LocalAxisAdd)
			ball_tween:SetEase(DG.Tweening.Ease.Linear)
			ball_tween:OnComplete(function()
				self.is_trun = false
			end)
		end
	end
end

--显示上一阶形象
function AdvanceHuashenProtectView:OnClickLastButton()
	if not self.cur_select_img or self.cur_select_img <= 0 then
		return
	end
	self.cur_select_img = self.cur_select_img - 1
	self.is_first_open = true
	self:SwitchGradeAndName(self.cur_select_img)
	self.click_ball_index = 0
	self:SetHuashenProtectAtrr()
	self:SetArrowState()
end

--显示下一阶形象
function AdvanceHuashenProtectView:OnClickNextButton()
	local max_count = HuashenData.Instance:GetMaxHuashenList()
	if not self.cur_select_img or self.cur_select_img >= (max_count - 1) then
		return
	end
	self.cur_select_img = self.cur_select_img + 1
	self.is_first_open = true
	self:SwitchGradeAndName(self.cur_select_img)
	self.click_ball_index = 0
	self:SetHuashenProtectAtrr()
	self:SetArrowState()
end

function AdvanceHuashenProtectView:SetArrowState()
	local max_count = HuashenData.Instance:GetMaxHuashenList()
	self.show_next_button:SetValue(self.cur_select_img < (max_count - 1))
	self.show_last_button:SetValue(self.cur_select_img > 0)
end

function AdvanceHuashenProtectView:OnClickBall(index)
	self.click_ball_index = index
	self.is_first_open = true
	self:SetHuashenProtectAtrr()
end

function AdvanceHuashenProtectView:SwitchGradeAndName(huashen_id)
	if huashen_id == nil then return end

	local huashen_grade_cfg = HuashenData.Instance:GetHuashenLevelCfg(huashen_id)
	local image_info = HuashenData.Instance:GetHuashenInfoCfg()[huashen_id]
	if not huashen_grade_cfg or not image_info then return end

	if not huashen_grade_cfg.gradename then
		self.show_grade:SetValue(false)
	else
		self.show_grade:SetValue(true)
		local bundle, asset = nil, nil
		if math.floor(huashen_grade_cfg.level / 3 + 1) >= 5 then
			 bundle, asset = ResPath.GetMountGradeQualityBG(5)
		else
			 bundle, asset = ResPath.GetMountGradeQualityBG(math.floor(huashen_grade_cfg.level / 3 + 1))
		end
		-- self.quality:SetAsset(bundle, asset)
		self.rank:SetValue(huashen_grade_cfg.gradename)
	end
	self.name:SetValue(image_info.name)

end

-- -- 幻化
-- function AdvanceHuashenProtectView:OnClickHuanHua()

-- end

-- 设置坐骑属性
function AdvanceHuashenProtectView:SetHuashenProtectAtrr()
	local huashen_info = HuashenData.Instance:GetHuashenInfo()
	local item_id = 0
	local need_num = 0
	if not huashen_info or not huashen_info.cur_huashen_id then
		return
	end
	if huashen_info.cur_huashen_id > -1 then
		self.cur_select_img = huashen_info.cur_huashen_id
	end
	local protect_list = HuashenData.Instance:GetHuashenProtectInfo(self.cur_select_img)
	if not protect_list then return end

	self.cur_ball_level = protect_list[self.click_ball_index].level or 0
	local cur_protect_cfg = HuashenData.Instance:GetHuashenProtectLevelCfg(self.cur_select_img, self.click_ball_index, self.cur_ball_level)
	local next_protect_cfg = HuashenData.Instance:GetHuashenProtectLevelCfg(self.cur_select_img, self.click_ball_index, self.cur_ball_level + 1)

	self.cur_gongji:SetValue(cur_protect_cfg.gongji)
	self.cur_maxhp:SetValue(cur_protect_cfg.maxhp)
	self.cur_fangyu:SetValue(cur_protect_cfg.fangyu)
	self.cur_shanbi:SetValue(cur_protect_cfg.shanbi)
	self.cur_mingzhong:SetValue(cur_protect_cfg.mingzhong)

	self.show_next_attr:SetValue(nil ~= next_protect_cfg)
	self.ball_toggle_list[self.click_ball_index + 1].isOn = true

	if next_protect_cfg then
		self.next_gongji:SetValue(next_protect_cfg.gongji - cur_protect_cfg.gongji)
		self.next_maxhp:SetValue(next_protect_cfg.maxhp - cur_protect_cfg.maxhp)
		self.next_fangyu:SetValue(next_protect_cfg.fangyu - cur_protect_cfg.fangyu)
		self.next_shanbi:SetValue(next_protect_cfg.shanbi - cur_protect_cfg.shanbi)
		self.next_mingzhong:SetValue(next_protect_cfg.mingzhong - cur_protect_cfg.mingzhong)
		if self.is_first_open then
			self.cur_jinhua_value:InitValue(protect_list[self.click_ball_index].exp_val)
			self.value_radio:InitValue(protect_list[self.click_ball_index].exp_val / next_protect_cfg.need_exp_val)
		else
			self.cur_jinhua_value:SetValue(protect_list[self.click_ball_index].exp_val)
			self.value_radio:SetValue(protect_list[self.click_ball_index].exp_val / next_protect_cfg.need_exp_val)
		end
	else
		self.cur_jinhua_value:InitValue(protect_list[self.click_ball_index].exp_val)
		self.value_radio:InitValue(1)
	end

	item_id = next_protect_cfg and next_protect_cfg.consume_item_id or cur_protect_cfg.consume_item_id
	need_num = next_protect_cfg and next_protect_cfg.consume_item_count or cur_protect_cfg.consume_item_count
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg then
		self.prop_name:SetValue(item_cfg.name)
		self.need_num:SetValue(need_num)
		self.bag_num:SetValue(ItemData.Instance:GetItemNumInBagById(item_id))
	end

	local capability = CommonDataManager.GetCapability(cur_protect_cfg)
	self.fight_power:SetValue(capability)

	self:SwitchGradeAndName(self.cur_select_img)
	self:SetArrowState()
	self:SetAdvanceButtonState()
	self.is_first_open = false
end

-- --设置使用形象按钮和以幻化标签的显示
-- function AdvanceHuashenProtectView:SetUseImageBtnState(id)
-- 	local huashen_info = HuashenData.Instance:GetHuashenInfo()
-- 	if not id or not huashen_info then return end
-- 	local activie_flag = huashen_info.activie_flag
-- 	if not activie_flag then return end
-- 	self.show_use_image_sprite:SetValue(huashen_info.cur_huashen_id == id)
-- 	self.show_use_button:SetValue(huashen_info.cur_huashen_id ~= id and activie_flag[id] == 1)
-- end

-- 物品不足，购买成功后刷新物品数量
function AdvanceHuashenProtectView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self.bag_num:SetValue(ItemData.Instance:GetItemNumInBagById(item_id))
end

-- 设置进阶按钮状态
function AdvanceHuashenProtectView:SetAdvanceButtonState()
	local spirit_list = HuashenData.Instance:GetHuashenProtectInfo(self.cur_select_img)
	local max_level = HuashenData.Instance:GetHuashenProtectMaxLevel(self.click_ball_index)
	local level = spirit_list[self.click_ball_index] and spirit_list[self.click_ball_index].level
	if not level or level >= (max_level - 1) then
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = false
		self.auto_button.button.interactable = false
		return
	end
	if self.is_auto then
		self.auto_btn_text:SetValue(Language.Common.Stop)
		self.start_button.button.interactable = false
		self.auto_button.button.interactable = true
	else
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = true
		self.auto_button.button.interactable = true
	end
end

function AdvanceHuashenProtectView:SetModle(is_show)
	if is_show then
		if self.model == nil then
			self.model = RoleModel.New()
			self.model:SetDisplay(self.display.ui3d_display)
			self.model:SetMainAsset(ResPath.GetHuashenBallModle())
			GlobalTimerQuest:AddDelayTimer(function()
				local ball_jin = self.model.draw_obj:GetRoot().transform:Find("BallModles(Clone)/qiu_0001_jin")
				local ball_mu = self.model.draw_obj:GetRoot().transform:Find("BallModles(Clone)/qiu_0003_mu")
				local ball_shui = self.model.draw_obj:GetRoot().transform:Find("BallModles(Clone)/qiu_0005_shui")
				local ball_huo = self.model.draw_obj:GetRoot().transform:Find("BallModles(Clone)/qiu_0007_huo")
				local ball_tu = self.model.draw_obj:GetRoot().transform:Find("BallModles(Clone)/qiu_0009_tu")
				if ball_jin and ball_mu and ball_shui and ball_huo and ball_tu then
					local ball_jin_tween = ball_jin.transform:DOLocalRotate(Vector3(0, 360, 0), 5.0, DG.Tweening.RotateMode.LocalAxisAdd)
					ball_jin_tween:SetLoops(-1, DG.Tweening.LoopType.Incremental)
					ball_jin_tween:SetEase(DG.Tweening.Ease.Linear)

					local ball_mu_tween = ball_mu.transform:DOLocalRotate(Vector3(0, 360, 0), 5.0, DG.Tweening.RotateMode.LocalAxisAdd)
					ball_mu_tween:SetLoops(-1, DG.Tweening.LoopType.Incremental)
					ball_mu_tween:SetEase(DG.Tweening.Ease.Linear)

					local ball_shui_tween = ball_shui.transform:DOLocalRotate(Vector3(0, 360, 0), 5.0, DG.Tweening.RotateMode.LocalAxisAdd)
					ball_shui_tween:SetLoops(-1, DG.Tweening.LoopType.Incremental)
					ball_shui_tween:SetEase(DG.Tweening.Ease.Linear)

					local ball_huo_tween = ball_huo.transform:DOLocalRotate(Vector3(0, 360, 0), 5.0, DG.Tweening.RotateMode.LocalAxisAdd)
					ball_huo_tween:SetLoops(-1, DG.Tweening.LoopType.Incremental)
					ball_huo_tween:SetEase(DG.Tweening.Ease.Linear)

					local ball_tu_tween = ball_tu.transform:DOLocalRotate(Vector3(0, 360, 0), 5.0, DG.Tweening.RotateMode.LocalAxisAdd)
					ball_tu_tween:SetLoops(-1, DG.Tweening.LoopType.Incremental)
					ball_tu_tween:SetEase(DG.Tweening.Ease.Linear)
				end
			end, 0.2)
			-- local part = self.model.draw_obj and self.model.draw_obj:GetPart(SceneObjPart.Main)
			-- if part then
				-- local ball_jin = self.model.draw_obj:GetRoot().gameObject.transform:Find("UICamera2")
			-- end
		end
	end
end

function AdvanceHuashenProtectView:SetNotifyDataChangeCallBack()
	self.is_first_open = true
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function AdvanceHuashenProtectView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function AdvanceHuashenProtectView:OnFlush(param_list)
	if self.display ~= nil then
		self.display.ui3d_display:ResetRotation()
	end

	if param_list == "huashenprotect" then
		self:SetHuashenProtectAtrr()
		return
	end
	for k, v in pairs(param_list) do
		if k == "huashenprotect" then
			self:SetHuashenProtectAtrr()
		end
	end
end
