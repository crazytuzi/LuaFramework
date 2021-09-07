AdvanceHuashenView = AdvanceHuashenView or BaseClass(BaseRender)

function AdvanceHuashenView:__init(instance)
	self:ListenEvent("StartAdvance",
		BindTool.Bind(self.OnStartAdvance, self))
	self:ListenEvent("AutomaticAdvance",
		BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickUse",
		BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickHuanHua",
		BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickLastButton",
		BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton",
		BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnClickCanCelIamge",
		BindTool.Bind(self.OnClickCanCelIamge, self))

	self.huashen_name = self:FindVariable("Name")
	self.huashen_rank = self:FindVariable("Rank")
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

	self.huashen_display = self:FindObj("Display")
	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.start_button = self:FindObj("StartButton")
	self.auto_button = self:FindObj("AutoButton")
	self.gray_use_button = self:FindObj("GrayUseButton")

	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.used_imageid = nil
	self.cur_select_img = 0
	self.cur_select_img_level = 0
	self.is_first_open = false
	self.is_click_change_ima_btn = false
end

function AdvanceHuashenView:__delete()
	if self.huashen_model ~= nil then
		self.huashen_model:DeleteMe()
		self.huashen_model = nil
	end

	self.is_can_auto = nil
	self.cur_select_img_level = nil
	self.cur_select_img = nil
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.used_imageid = nil
	self.is_first_open = nil
	self.is_click_change_ima_btn = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

-- 开始进阶
function AdvanceHuashenView:OnStartAdvance()
	local grade_cfg = HuashenData.Instance:GetHuashenLevelCfg(self.cur_select_img, self.cur_select_img_level + 1)

	if not grade_cfg then self:SetAdvanceButtonState() return end

	local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0
	local item_id = grade_cfg.stuff_id

	if ItemData.Instance:GetItemNumInBagById(item_id) < grade_cfg.stuff_num and 0 == is_auto_buy then
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
			(grade_cfg.stuff_num - ItemData.Instance:GetItemNumInBagById(item_id)))
		return
	end

	HuashenCtrl.Instance:SendHuaShenOperaReq(HUASHEN_REQ_TYPE.HUASHEN_REQ_TYPE_UP_LEVEL, self.cur_select_img, is_auto_buy, 1)
	self.jinjie_next_time = Status.NowTime + 0.1
end

function AdvanceHuashenView:OnHuashenUpgradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAdvanceButtonState()
	elseif 1 == result then
		self:AutoUpGradeOnce()
	end
end

function AdvanceHuashenView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if  self.cur_select_img_level < HuashenData.Instance:GetHuashenMaxLevel(self.cur_select_img) then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

-- 自动进阶
function AdvanceHuashenView:OnAutomaticAdvance()
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

	TipsCtrl.Instance:ShowCommonAutoView("auto_huashen_up", Language.Mount.AutoUpDes, ok_callback, canel_callback, true)
end

-- 使用当前形象
function AdvanceHuashenView:OnClickUse()
	if self.cur_select_img == nil then
		return
	end
	HuashenCtrl.Instance:SendHuaShenOperaReq(HUASHEN_REQ_TYPE.HUASHEN_REQ_TYPE_CHANGE_IMAGE, self.cur_select_img)
end

-- 取消形象
function AdvanceHuashenView:OnClickCanCelIamge()
	local huashen_info = HuashenData.Instance:GetHuashenInfo()
	if not huashen_info then return end
	HuashenCtrl.Instance:SendHuaShenOperaReq(HUASHEN_REQ_TYPE.HUASHEN_REQ_TYPE_CHANGE_IMAGE, huashen_info.cur_huashen_id)
end

--显示上一阶形象
function AdvanceHuashenView:OnClickLastButton()
	if not self.cur_select_img or self.cur_select_img <= 0 then
		return
	end
	self.cur_select_img = self.cur_select_img - 1
	self.is_click_change_ima_btn = true
	self:SwitchGradeAndName(self.cur_select_img)
	self:SetHuashenAtrr()
	self:SetAdvanceButtonState()
	self:SetArrowState()
	-- if self.huashen_display ~= nil then
	-- 	self.huashen_display.ui3d_display:ResetRotation()
	-- end
end

--显示下一阶形象
function AdvanceHuashenView:OnClickNextButton()
	local max_count = HuashenData.Instance:GetMaxHuashenList()
	if not self.cur_select_img or self.cur_select_img >= (max_count - 1) then
		return
	end
	self.cur_select_img = self.cur_select_img + 1
	self.is_click_change_ima_btn = true
	self:SwitchGradeAndName(self.cur_select_img)
	self:SetHuashenAtrr()
	self:SetAdvanceButtonState()
	self:SetArrowState()
	-- if self.huashen_display ~= nil then
	-- 	self.huashen_display.ui3d_display:ResetRotation()
	-- end
end

function AdvanceHuashenView:SetArrowState()
	local max_count = HuashenData.Instance:GetMaxHuashenList()
	self.show_next_button:SetValue(self.cur_select_img < (max_count - 1))
	self.show_last_button:SetValue(self.cur_select_img > 0)
end

function AdvanceHuashenView:SwitchGradeAndName(index)
	if index == nil then return end

	local huashen_grade_cfg = HuashenData.Instance:GetHuashenLevelCfg(index)
	local image_info = HuashenData.Instance:GetHuashenInfoCfg()[index]

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
		self.huashen_rank:SetValue(huashen_grade_cfg.gradename)
	end

	self.huashen_name:SetValue(image_info.name)
end

-- 幻化
function AdvanceHuashenView:OnClickHuanHua()
	ViewManager.Instance:Open(ViewName.HuashenImageView)
end

-- 设置化神属性
function AdvanceHuashenView:SetHuashenAtrr()
	local huashen_info = HuashenData.Instance:GetHuashenInfo()
	local level_info_list = huashen_info.level_info_list
	local item_id = 0
	local need_num = 0
	if not level_info_list then return end

	if huashen_info.cur_huashen_id > -1 and self.is_first_open then
		self.cur_select_img = huashen_info.cur_huashen_id
	end
	self.cur_select_img_level = level_info_list[self.cur_select_img].level
	local cur_attr = HuashenData.Instance:GetHuashenLevelCfg(self.cur_select_img, self.cur_select_img_level)
	local next_attr = HuashenData.Instance:GetHuashenLevelCfg(self.cur_select_img, self.cur_select_img_level + 1)

	self.cur_gongji:SetValue(cur_attr.gongji)
	self.cur_maxhp:SetValue(cur_attr.maxhp)
	self.cur_fangyu:SetValue(cur_attr.fangyu)
	self.cur_shanbi:SetValue(cur_attr.shanbi)
	self.cur_mingzhong:SetValue(cur_attr.mingzhong)

	self.show_next_attr:SetValue(nil ~= next_attr)
	if next_attr then
		self.next_gongji:SetValue(next_attr.gongji - cur_attr.gongji)
		self.next_maxhp:SetValue(next_attr.maxhp - cur_attr.maxhp)
		self.next_fangyu:SetValue(next_attr.fangyu - cur_attr.fangyu)
		self.next_shanbi:SetValue(next_attr.shanbi - cur_attr.shanbi)
		self.next_mingzhong:SetValue(next_attr.mingzhong - cur_attr.mingzhong)
		if self.is_first_open then
			self.cur_jinhua_value:InitValue(level_info_list[self.cur_select_img].jinhua_val)
			self.value_radio:InitValue(level_info_list[self.cur_select_img].jinhua_val / next_attr.jinhua_val)
		else
			self.cur_jinhua_value:SetValue(level_info_list[self.cur_select_img].jinhua_val)
			self.value_radio:SetValue(level_info_list[self.cur_select_img].jinhua_val / next_attr.jinhua_val)
		end
	else
		self.cur_jinhua_value:InitValue(level_info_list[self.cur_select_img].jinhua_val)
		self.value_radio:InitValue(1)
	end

	item_id = next_attr and next_attr.stuff_id or cur_attr.stuff_id
	need_num = next_attr and next_attr.stuff_num or cur_attr.stuff_num

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg then
		self.prop_name:SetValue(item_cfg.name)
		self.need_num:SetValue(need_num)
		self.bag_num:SetValue(ItemData.Instance:GetItemNumInBagById(item_id))
	end
	local capability = CommonDataManager.GetCapability(cur_attr)
	self.fight_power:SetValue(capability)

	self:SwitchGradeAndName(self.cur_select_img)
	self:SetUseImageBtnState(self.cur_select_img)
	self:SetArrowState()
	self:SetAdvanceButtonState()

	self.is_first_open = false
	self.is_click_change_ima_btn = false
end

-- 物品不足，购买成功后刷新物品数量
function AdvanceHuashenView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	self.bag_num:SetValue(ItemData.Instance:GetItemNumInBagById(item_id))
end


-- 设置进阶按钮状态
function AdvanceHuashenView:SetAdvanceButtonState()
	local level_info = HuashenData.Instance:GetHuashenInfo().level_info_list
	local max_level = HuashenData.Instance:GetHuashenMaxLevel(self.cur_select_img)
	local level = level_info[self.cur_select_img] and level_info[self.cur_select_img].level
	if not level or level >= max_level then
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

function AdvanceHuashenView:SetUseImageBtnState(id)
	local huashen_info = HuashenData.Instance:GetHuashenInfo()
	if not id or not huashen_info then return end
	local activie_flag = huashen_info.activie_flag
	if not activie_flag then return end
	self.show_use_image_sprite:SetValue(huashen_info.cur_huashen_id == id)
	self.show_use_button:SetValue(huashen_info.cur_huashen_id ~= id and activie_flag[id] == 1)
end

function AdvanceHuashenView:SetModle(is_show)
	if is_show then
		if self.huashen_model == nil then
			self.huashen_model = RoleModel.New()
			self.huashen_model:SetDisplay(self.huashen_display.ui3d_display)
			-- self.huashen_model:SetMainAsset(ResPath.GetMountModel(id))
		end
	end
end

function AdvanceHuashenView:SetNotifyDataChangeCallBack()
	-- 监听系统事件
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self.is_first_open = true
end

function AdvanceHuashenView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
end

function AdvanceHuashenView:OnFlush(param_list)
	if self.huashen_display ~= nil then
		self.huashen_display.ui3d_display:ResetRotation()
	end

	if param_list == "huashen" then
		self:SetHuashenAtrr()
		self.show_huanhua_redpoint:SetValue(AdvanceData.Instance:IsShowHuashenHuanhuaRedPoint())
		return
	end
	for k, v in pairs(param_list) do
		if k == "huashen" then
			self:SetHuashenAtrr()
			self.show_huanhua_redpoint:SetValue(AdvanceData.Instance:IsShowHuashenHuanhuaRedPoint())
		end
	end
end
