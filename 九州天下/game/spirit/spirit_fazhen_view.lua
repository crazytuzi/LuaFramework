SpiritFazhenView = SpiritFazhenView or BaseClass(BaseRender)

function SpiritFazhenView:__init(instance)
	self:ListenEvent("StartAdvance", BindTool.Bind(self.OnClickStartAdvance, self))
	self:ListenEvent("AutomaticAdvance", BindTool.Bind(self.OnClickAutomaticAdvance, self))
	self:ListenEvent("OnClickUse", BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickLookImage", BindTool.Bind(self.OnClickLookImage, self))
	self:ListenEvent("OnClickLastButton", BindTool.Bind(self.OnClickLeftButton, self))
	self:ListenEvent("OnClickNextButton", BindTool.Bind(self.OnClickRightButton, self))

	-- self.display = self:FindObj("Display")
	-- self.modle = RoleModel.New()
	-- self.modle:SetDisplay(self.display.ui3d_display)

	self.auto_toggle = self:FindObj("AutoToggle").toggle
	self.star_btn = self:FindObj("StartButton")
	self.auto_btn = self:FindObj("AutoButton")
	self.use_image_btn = self:FindObj("GrayUseButton")

	self.cur_gongji = self:FindVariable("CurGongji")
	self.cur_fangyu = self:FindVariable("CurFangyu")
	self.cur_maxhp = self:FindVariable("CurMaxhp")
	self.cur_bless = self:FindVariable("CurBless")
	self.radio = self:FindVariable("Radio")
	self.prop_name = self:FindVariable("PropName")
	self.prop_need_num = self:FindVariable("PropNeedNum")
	self.prop_bag_had_num = self:FindVariable("PropHadNum")
	self.cur_image_name = self:FindVariable("CurImageName")
	self.cur_grade = self:FindVariable("CurGrade")
	self.grade_bg = self:FindVariable("Quality")
	self.fight_power = self:FindVariable("FightPower")
	self.auto_btn_text = self:FindVariable("AutoBtnText")

	self.next_gongji = self:FindVariable("NextGongji")
	self.next_fangyu = self:FindVariable("NextFangyu")
	self.next_maxhp = self:FindVariable("NextMaxhp")

	self.show_left_arrow = self:FindVariable("ShowLeftArrow")
	self.show_right_arrow = self:FindVariable("ShowRightArrow")
	self.show_next_effect = self:FindVariable("ShowNextEffect")
	self.show_had_use_image = self:FindVariable("ShowHadUseImage")
	self.show_use_image_btn = self:FindVariable("ShowUseImageButton")
	self.show_max_level_tip = self:FindVariable("ShowMaxLevelTip")
	self.show_bless_tip = self:FindVariable("ShowBlessTip")
	self.show_huanhua_red_point = self:FindVariable("ShowHuanhuaRedPoint")

	self.cur_select_grade = nil
	self.cur_select_index = nil
	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.is_first_open = true
	self.res_id = 0
end

function SpiritFazhenView:__delete()
	self.cur_select_grade = nil
	self.cur_select_index = nil
	self.is_auto = nil
	self.is_can_auto = nil
	self.jinjie_next_time = nil
	self.is_first_open = nil
	self.res_id = nil

	-- if self.modle then
	-- 	self.modle:DeleteMe()
	-- 	self.modle = nil
	-- end
end

function SpiritFazhenView:OpenCallBack()
	self.is_first_open = true
	-- if self.item_data_event == nil then
	-- 	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	-- 	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	-- end
end

function SpiritFazhenView:CloseCallBack()
	self.res_id = 0
	self.is_first_open = true
	-- if self.item_data_event ~= nil then
	-- 	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
	-- 	self.item_data_event = nil
	-- end
end

-- 进阶结果返回
function SpiritFazhenView:SetUppGradeOptResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAdvanceButtonState()
	elseif 1 == result then
		self:AutoUpGradeOnce()
	end
end

function SpiritFazhenView:AutoUpGradeOnce()
	local fazhen_info = SpiritData.Instance:GetSpiritFazhenInfo()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if fazhen_info.grade > 0 and fazhen_info.grade < SpiritData.Instance:GetMaxSpiritFazhenGrade() then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnClickStartAdvance, self), jinjie_next_time)
		end
	end
end

function SpiritFazhenView:OnClickStartAdvance()
	local fazhen_info = SpiritData.Instance:GetSpiritFazhenInfo()
	local grade_cfg = SpiritData.Instance:GetSpiritFazhenGradeCfg()[fazhen_info.grade]

	if not grade_cfg then return end

	local auto_buy = self.auto_toggle.isOn and 1 or 0
	local bag_num = ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id)
	if bag_num < grade_cfg.upgrade_stuff_count and 0 == auto_buy then
		self.is_auto = false
		self.is_can_auto = true
		local shop_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[grade_cfg.upgrade_stuff_id]
		if shop_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(grade_cfg.upgrade_stuff_id)
			return
		end

		-- if shop_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowShopView(grade_cfg.upgrade_stuff_id, 2)
		-- 	return
		-- end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_toggle.isOn = true
			end
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, grade_cfg.upgrade_stuff_id, no_func,
			(grade_cfg.upgrade_stuff_count - ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id)))
		self:SetAdvanceButtonState()
		return
	end

	SpiritCtrl.Instance:SendSpiritFazhenUpStar(auto_buy)
	self.jinjie_next_time = Status.NowTime + 0.1
end

function SpiritFazhenView:OnClickAutomaticAdvance()
	local fazhen_info = SpiritData.Instance:GetSpiritFazhenInfo()
	if not fazhen_info or not fazhen_info.grade or fazhen_info.grade <= 0 then
		 return
	end

	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		self.is_can_auto = false
		self.is_auto = self.is_auto == false
		self:OnClickStartAdvance()
		self:SetAdvanceButtonState()
	end

	local function canel_callback()
		self:SetAdvanceButtonState()
	end

	if not self.is_auto then
		TipsCtrl.Instance:ShowCommonAutoView("auto_fazhen_up", Language.Mount.AutoUpDes, ok_callback, canel_callback, true)
	else
		ok_callback()
	end
end

function SpiritFazhenView:OnClickUse()
	if not self.cur_select_index then return end

	local grade_cfg = SpiritData.Instance:GetSpiritFazhenGradeCfg()[self.cur_select_index]
	if not grade_cfg then return end

	SpiritCtrl.Instance:SendSpiritFazhenUseImage(grade_cfg.image_id)
end

function SpiritFazhenView:OnClickLookImage()
	-- local call_back = function(select_index)
	-- 	self.cur_select_index = select_index
	-- end
	-- SpiritCtrl.Instance:ShowSpiritImageListView(TabIndex.spirit_fazhen, call_back)
	ViewManager.Instance:Open(ViewName.SpiritFazhenHuanHuaView)
end

function SpiritFazhenView:OnClickLeftButton()
	if not self.cur_select_index or self.cur_select_index <= 1 then
		 return
	end
	self.cur_select_index = self.cur_select_index - 1
	self:SetUseImageState(self.cur_select_index)
	self:SetGradeQualityAndName(self.cur_select_index)
	self:SetArrowState(self.cur_select_index)
end

function SpiritFazhenView:OnClickRightButton()
	local max_grade = SpiritData.Instance:GetMaxSpiritFazhenGrade()
	local fazhen_info = SpiritData.Instance:GetSpiritFazhenInfo()
	if not fazhen_info or not max_grade or not self.cur_select_index or self.cur_select_index >= max_grade
		or self.cur_select_index > fazhen_info.grade + 1 then
		 return
	end
	self.cur_select_index = self.cur_select_index + 1
	self:SetUseImageState(self.cur_select_index)
	self:SetGradeQualityAndName(self.cur_select_index)
	self:SetArrowState(self.cur_select_index)
end

function SpiritFazhenView:SetArrowState(cur_select_grade)
	local fazhen_info = SpiritData.Instance:GetSpiritFazhenInfo()
	local max_grade = SpiritData.Instance:GetMaxSpiritFazhenGrade()
	local grade_cfg = SpiritData.Instance:GetSpiritFazhenGradeCfg()[cur_select_grade]
	if not grade_cfg then return end

	self.show_right_arrow:SetValue(cur_select_grade < fazhen_info.grade + 1 and cur_select_grade < max_grade)
	self.show_left_arrow:SetValue(grade_cfg.image_id > 1 or (fazhen_info.grade == 1 and cur_select_grade > fazhen_info.grade))
end

-- 物品不足，购买成功后刷新物品数量
function SpiritFazhenView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local fazhen_info = SpiritData.Instance:GetSpiritFazhenInfo()
	local grade_cfg = SpiritData.Instance:GetSpiritFazhenGradeCfg()[fazhen_info.grade]
	if not grade_cfg then return end

	local bag_num = string.format(Language.Mount.ShowGreenNum, ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id))
	if ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) < grade_cfg.upgrade_stuff_count then
		bag_num = string.format(Language.Mount.ShowRedNum, ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id))
	end
	self.prop_bag_had_num:SetValue(bag_num)
end

function SpiritFazhenView:SetFazhenInfo()
	local fazhen_info = SpiritData.Instance:GetSpiritFazhenInfo()
	local max_grade = SpiritData.Instance:GetMaxSpiritFazhenGrade()
	local grade_cfg = SpiritData.Instance:GetSpiritFazhenGradeCfg()[fazhen_info.grade]
	if not fazhen_info.grade or fazhen_info.grade <= 0 or not grade_cfg then
		self:SetAdvanceButtonState()
		return
	end
	if not self.cur_select_grade then
		if grade_cfg.show_grade == 0 then
			self.cur_select_index = fazhen_info.grade
		else
			self.cur_select_index = fazhen_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and fazhen_info.grade
									or SpiritData.Instance:GetFazhenGradeByUseImageId(fazhen_info.used_imageid)
		end
		self:SetUseImageState(self.cur_select_index)
		self:SetGradeQualityAndName(self.cur_select_index)
		self:SetArrowState(self.cur_select_index)
		self:SetAdvanceButtonState()
	elseif self.cur_select_grade < fazhen_info.grade then
		if grade_cfg.show_grade == 0 then
			self.cur_select_index = fazhen_info.grade
		else
			self.cur_select_index = fazhen_info.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID and fazhen_info.grade
									or SpiritData.Instance:GetFazhenGradeByUseImageId(fazhen_info.used_imageid)
		end
		self:SetGradeQualityAndName(self.cur_select_index)
		self.is_auto = false
		self:SetAdvanceButtonState()
		self:SetArrowState(self.cur_select_index)
	end
	self.cur_select_grade = fazhen_info.grade

	self.cur_bless:SetValue(fazhen_info.grade_bless_val.."/"..grade_cfg.bless_val_limit)

	if self.is_first_open then
		self.radio:InitValue(fazhen_info.grade_bless_val / grade_cfg.bless_val_limit)
	else
		self.radio:SetValue(fazhen_info.grade_bless_val / grade_cfg.bless_val_limit)
	end

	local bag_num = string.format(Language.Mount.ShowGreenNum, ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id))
	if ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) < grade_cfg.upgrade_stuff_count then
		bag_num = string.format(Language.Mount.ShowRedNum, ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id))
	end
	self.prop_bag_had_num:SetValue(bag_num)
	self.prop_need_num:SetValue(grade_cfg.upgrade_stuff_count)

	local attr_list = SpiritData.Instance:SpiritFazhenAttrSum()
	self.cur_gongji:SetValue(attr_list.gongji)
	self.cur_fangyu:SetValue(attr_list.fangyu)
	self.cur_maxhp:SetValue(attr_list.maxhp)

	self.show_next_effect:SetValue(fazhen_info.grade < max_grade)
	self.show_max_level_tip:SetValue(fazhen_info.grade >= max_grade)
	self.show_bless_tip:SetValue(fazhen_info.grade < max_grade)
	self.show_huanhua_red_point:SetValue(nil ~= next(SpiritData.Instance:ShowFazhenHuanhuaRedPoint()))

	if fazhen_info.grade >= max_grade then
		self.radio:InitValue(1)
	end
	if fazhen_info.grade < max_grade then
		local next_attr_list = SpiritData.Instance:SpiritFazhenAttrSum(fazhen_info.grade + 1)
		self.next_gongji:SetValue(next_attr_list.gongji)
		self.next_fangyu:SetValue(next_attr_list.fangyu)
		self.next_maxhp:SetValue(next_attr_list.maxhp)
	end

	local capability = CommonDataManager.GetCapability(attr_list)
	self.fight_power:SetValue(capability)

	local item_cfg = ItemData.Instance:GetItemConfig(grade_cfg.upgrade_stuff_id)
	if item_cfg then
		self.prop_name:SetValue(item_cfg.name)
	end

	self:SetUseImageState(self.cur_select_index)
	self:SetGradeQualityAndName(self.cur_select_index)
	self.is_first_open = false
end

function SpiritFazhenView:SetAdvanceButtonState()
	local fazhen_info = SpiritData.Instance:GetSpiritFazhenInfo()
	local max_grade = SpiritData.Instance:GetMaxSpiritFazhenGrade()
	if not fazhen_info or not fazhen_info.grade or fazhen_info.grade <= 0
		or fazhen_info.grade >= max_grade then
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.star_btn.button.interactable = false
		self.auto_btn.button.interactable = false
		return
	end
	if self.is_auto then
		self.auto_btn_text:SetValue(Language.Common.Stop)
		self.star_btn.button.interactable = false
		self.auto_btn.button.interactable = true
	else
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.star_btn.button.interactable = true
		self.auto_btn.button.interactable = true
	end
end

function SpiritFazhenView:SetUseImageState(grade)
	local fazhen_info = SpiritData.Instance:GetSpiritFazhenInfo()
	local grade_cfg = SpiritData.Instance:GetSpiritFazhenGradeCfg()[grade]
	local max_grade = SpiritData.Instance:GetMaxSpiritFazhenGrade()
	local image_cfg = SpiritData.Instance:GetSpiritFazhenImageCfg()[grade_cfg and grade_cfg.image_id]
	if not fazhen_info or not fazhen_info.grade or not grade or not max_grade or not image_cfg then
		return
	end

	self.show_use_image_btn:SetValue(grade <= fazhen_info.grade and image_cfg.image_id ~= fazhen_info.used_imageid)
	self.show_had_use_image:SetValue(image_cfg.image_id == fazhen_info.used_imageid)
end

function SpiritFazhenView:SetGradeQualityAndName(grade)
	grade = grade or SpiritData.Instance:GetSpiritFazhenInfo().grade
	local grade_cfg = SpiritData.Instance:GetSpiritFazhenGradeCfg()[grade]
	local image_cfg = SpiritData.Instance:GetSpiritFazhenImageCfg()[grade_cfg and grade_cfg.image_id]
	if nil == grade or nil == grade_cfg or nil == image_cfg then return end
	local bundle, asset = nil, nil
	local color = math.floor(grade / 3 + 1)
	if color >= 5 then
		 bundle, asset = ResPath.GetSpiritFazhenGradeQualityBG(5)
	else
		 bundle, asset = ResPath.GetSpiritFazhenGradeQualityBG(color)
	end
	self.grade_bg:SetAsset(bundle, asset)
	self.cur_grade:SetValue(grade_cfg.gradename)

	local name_str = "<color="..SOUL_NAME_COLOR[color]..">"..image_cfg.image_name.."</color>"
	self.cur_image_name:SetValue(name_str)
	-- if self.modle then
	-- 	self.modle:SetMainAsset(ResPath.GetEffect(image_cfg.res_id))
	-- end
	if self.res_id ~= image_cfg.res_id then
		local call_back = function(model, obj)
			local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SPIRIT_FAZHEN], image_cfg.res_id)
			if obj then
				if cfg then
					obj.transform.localPosition = cfg.position
					obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
					obj.transform.localScale = cfg.scale
				else
					obj.transform.localPosition = Vector3(0, 0, 0)
					obj.transform.localRotation = Quaternion.Euler(0, 0, 0)
					obj.transform.localScale = Vector3(1, 1, 1)
				end
			end
		end
		UIScene:SetModelLoadCallBack(call_back)
		bundle, asset = ResPath.GetEffect(image_cfg.res_id)
		UIScene:ModelBundle({[SceneObjPart.Main] = bundle}, {[SceneObjPart.Main] = asset})

		self.res_id = image_cfg.res_id
	end
end

function SpiritFazhenView:Flush()
	self:SetFazhenInfo()
end