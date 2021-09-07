AdvanceMultiMountView = AdvanceMultiMountView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
function AdvanceMultiMountView:__init(instance)
	self.item_id = 0
	self.index = 1
	self.grade = nil
	self.mount_special_image = nil
	self.res_id = nil
	self.fix_show_time = 10
	self.used_imageid = nil
	self.cell_list = {}

	self.all_num = 0
	self.all_data = {}

	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = 0
	self.temp_grade = -1
	self.old_grade_bless_val = nil --用于升星提示Tips
	self.old_star_level  = nil
	self.show_up_type = false
end


function AdvanceMultiMountView:LoadCallBack()
	self.mount_display = self:FindObj("MountDisplay")
	self.mount_display:SetActive(true)
	self.have_pro_num = self:FindVariable("ActivateProNum")
	self.need_pro_num = self:FindVariable("ExchangeNeedNum")
	self.button_text = self:FindVariable("ButtonText")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.sheng_ming = self:FindVariable("ShengMing")

	self.fight_power = self:FindVariable("FightPower")
	self.up_power = self:FindVariable("UpCap")
	self.is_show_power_up_label = self:FindVariable("IsShowPowerUpLabel")

	self.title_name = self:FindVariable("TitleName")
	self.title_name:SetValue(Language.HuanHua.ZuoQi)
	self.show_upgrade_btn = self:FindVariable("IsShowUpGrade")
	self.show_activate_btn = self:FindVariable("IsShowActivate")
	self.show_use_ima_btn = self:FindVariable("IsShowUseImaButton")
	self.show_use_image = self:FindVariable("IsShowUseImage")
	self.cur_level = self:FindVariable("CurrentLevel")
	self.show_cur_level = self:FindVariable("ShowCurrentLevel")
	self.title_icon = self:FindVariable("Title_Icon")			--活动标题图标

	self.show_btn_left = self:FindVariable("ShowBtnLeft")
	self.show_btn_right = self:FindVariable("ShowBtnRight")
	self.name_obj = self:FindObj("NameObj")

	self.mount_model = RoleModel.New("mount_huanhua_panel", 100)
	self:ListenEvent("OnClickActivate",
		BindTool.Bind(self.OnClickActivate, self))
	self:ListenEvent("OnClickUpGrade",
		BindTool.Bind(self.OnClickUpGrade, self))
	self:ListenEvent("OnClickUseIma",
		BindTool.Bind(self.OnClickUseIma, self))

	self.all_num, self.all_data = MultiMountData.Instance:GetImageListCfg()

	self.list_view = self:FindObj("ListView")
	self.upgrade_btn = self:FindObj("UpGradeButton")
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	-- if self.data_listen == nil then
	-- 	self.data_listen = BindTool.Bind1(self.PlayerDataChangeCallback, self)
	-- 	PlayerData.Instance:ListenerAttrChange(self.data_listen)
	-- end

	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMountNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)

	self.star_lists = {}
	for i = 1, 10 do
		self.star_lists[i] = self:FindVariable("Star"..i)
	end

	self.upgrade_item = ItemCell.New()
	self.upgrade_item:SetInstanceParent(self:FindObj("NeedItem"))

	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.auto_buy_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))

	self.start_button = self:FindObj("StartButton")
	self.up_grade_gray = self:FindVariable("UpGradeGray")
	self.auto_button = self:FindObj("AutoButton")
	self.auto_up_grade_gray = self:FindVariable("AutoUpGradeGray")
	self.remainder_num = self:FindVariable("RemainderNum")
	self.need_num = self:FindVariable("NeedNun")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.cur_bless = self:FindVariable("CurBless")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.show_star = self:FindVariable("ShowStar")
	self.show_effect = self:FindVariable("ShowEffect")
	self.show_btn_change = self:FindVariable("ShowBtnChange")
	self.grade_str = self:FindVariable("GradeStr")

	self.active_red = self:FindVariable("ActiveRed")
	self.up_grade_red = self:FindVariable("UpGradeRed")
	self.up_level_red = self:FindVariable("UpLevelRed")
	self.use_btn_str = self:FindVariable("UseBtnStr")

	self:ListenEvent("OnClickOnceUp",
		BindTool.Bind(self.OnStartAdvance, self, true))
	self:ListenEvent("OnClickAutoUp",
		BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickChange",
		BindTool.Bind(self.OnClickChange, self))
end

function AdvanceMultiMountView:__delete()
	if self.mount_model ~= nil then
		self.mount_model:DeleteMe()
		self.mount_model = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end	

	-- if self.data_listen ~= nil then
	-- 	PlayerData.Instance:UnlistenerAttrChange(self.data_listen)
	-- 	self.data_listen = nil
	-- end

	if self.upgrade_item ~= nil then
		self.upgrade_item:DeleteMe()
		self.upgrade_item = nil
	end

	if self.item ~= nil then
		self.item:DeleteMe()
		self.item = nil
	end

	if self.cell_list ~= nil then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end

		self.cell_list = {}
	end

	self.index = 1
	self.grade = nil
	self.item_id = nil
	self.mount_special_image = nil

	self.is_auto = nil
	self.is_can_auto = nil
	self.jinjie_next_time = nil
	self.mount_skill_list = nil
	self.temp_grade = -1
	self.res_id = nil
	self.old_grade_bless_val = nil
	self.old_star_level  = nil
	self.show_up_type = false
end

function AdvanceMultiMountView:ClearTempData()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	self.grade = nil
	self.res_id = nil
	self.used_imageid = nil

	self.is_auto = false
	self.is_can_auto = true
	self.jinjie_next_time = nil
	self.temp_grade = -1
	self.res_id = nil
	self.old_grade_bless_val = nil
	self.old_star_level  = nil
	self.show_up_type = false
end

function AdvanceMultiMountView:SetNotifyDataChangeCallBack()
	if ViewManager.Instance:IsOpen(ViewName.Advance) then
		if self.item_data_event == nil then
			self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
			ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
		end
	end
end

function AdvanceMultiMountView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if self.all_data[self.index] == nil then
		return
	end

	local mount_id = self.all_data[self.index].mount_id
	if mount_id == nil then
		return
	end

	local need_item, num, is_grade = MultiMountData.Instance:GetNeedItemCfg(mount_id)
	if need_item == nil then
		return
	end

	if need_item ~= item_id then
		return
	end

	self:GetHaveProNum(need_item, num, is_grade)
	self:FlushRedPoint(mount_id)
end

--点击升级按钮
function AdvanceMultiMountView:OnClickUpGrade()
	if self.all_data[self.index] == nil then
		return
	end

	local cur_mount_id = self.all_data[self.index].mount_id
	if cur_mount_id == nil then
		return
	end

	local info_info = MultiMountData.Instance:GetDataById(cur_mount_id)
	if info_info == nil or next(info_info) == nil then
		return
	end

	local cur_grade = info_info.grade
	if cur_grade == -1 then
		return
	end

	local level_cfg, max_level = MultiMountData.Instance:GetLeveInfoById(cur_mount_id, info_info.level)
	if level_cfg == nil or next(level_cfg) == nil then
		return
	end

	if level_cfg.level >= max_level then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.YiManJi)
		return
	end

	if ItemData.Instance:GetItemNumInBagById(level_cfg.upgrade_stuff_id) < level_cfg.upgrade_stuff_num then
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[level_cfg.upgrade_stuff_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(level_cfg.upgrade_stuff_id)
			return
		end

		-- if item_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowShopView(attr_cfg.stuff_id, 2)
		-- 	return
		-- end

		local func = function(upgrade_stuff_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(upgrade_stuff_id, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, level_cfg.upgrade_stuff_id, nil, level_cfg.upgrade_stuff_num)
		return
	end

	MultiMountCtrl:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_UPLEVEL, cur_mount_id)
end

function AdvanceMultiMountView:GetMountNumberOfCells()
	--return MountData.Instance:GetMaxSpecialImage()
	--return MountData.Instance:GetShowSpecialInfo()
	return self.all_num
end

function AdvanceMultiMountView:RefreshMountCell(cell, cell_index)
	--local mount_special_image = MountData.Instance:GetSpecialImagesCfg()				--大表
	--local _, mount_special_image = MountData.Instance:GetShowSpecialInfo()
	local mount_cell = self.cell_list[cell]
	if mount_cell == nil then
		mount_cell = MultiMountCell.New(cell.gameObject)
		self.cell_list[cell] = mount_cell
	end
	mount_cell:SetToggleGroup(self.list_view.toggle_group)
	mount_cell:SetHighLight(self.index == cell_index + 1)
	local data = {}
	if self.all_data[cell_index + 1] ~= nil then
		data.image_name = self.all_data[cell_index + 1].mount_name
		data.item_id = self.all_data[cell_index + 1].active_need_item_id
		data.index = cell_index + 1
		data.mount_id = self.all_data[cell_index + 1].mount_id
		local is_show = MultiMountData.Instance:GetRenderRed(data.mount_id)
		data.is_show = is_show
		data.info = MultiMountData.Instance:GetDataById(data.mount_id)
	end
	mount_cell:SetData(data)
	mount_cell:ListenClick(BindTool.Bind(self.OnClickListCell, self, self.all_data[cell_index + 1], cell_index+1, mount_cell))
end

function AdvanceMultiMountView:OpenCallBack()
	-- if self.item_data_event == nil then
	-- 	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	-- 	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	-- end

	-- self:Flush("multi_mount")
	-- self.index = 1
	-- self:SetModleRestAni()

	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_multi_up"] then
		self.auto_buy_toggle.toggle.isOn = TipsCommonAutoView.AUTO_VIEW_STR_T["auto_multi_up"].is_auto_buy
	end

	if self.show_effect ~= nil then
		self.show_effect:SetValue(false)
	end

	self.index = 1
	self:SetModleRestAni()
end

function AdvanceMultiMountView:OnClickChange()
	self.show_up_type = not self.show_up_type
	self:Flush("multi_mount")
end

--点击激活按钮
function AdvanceMultiMountView:OnClickActivate()
	if self.all_data[self.index] == nil then
		return
	end

	local data_list = ItemData.Instance:GetBagItemDataList()
	self.item_id = self.all_data[self.index].active_need_item_id
	for k, v in pairs(data_list) do
		if v.item_id == self.item_id then
			PackageCtrl.Instance:SendUseItem(v.index, 1, v.sub_type, 0)
			return
		end
	end
	local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
	if item_cfg == nil then
		TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
		return
	end

	local func = function(item_id, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id, nil, 1)
	return
end

--点击进阶
function AdvanceMultiMountView:OnStartAdvance(is_click_one)
	if self.all_data[self.index] == nil then
		return
	end

	local cur_mount_id = self.all_data[self.index].mount_id
	if cur_mount_id == nil then
		return
	end

	local mount_info = MultiMountData.Instance:GetDataById(cur_mount_id)
	if mount_info.grade < 0 then
		return
	end

	local grade_cfg, max_grade = MultiMountData.Instance:GetGradeInfoById(cur_mount_id, mount_info.grade)

	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn
	if mount_info.grade >= max_grade then
		return
	end

	if ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id) < grade_cfg.upgrade_stuff_num and not is_auto_buy_toggle then
		self.is_auto = false
		self.is_can_auto = true
		self:SetAutoButtonGray()
		-- 物品不足，弹出TIP框
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[grade_cfg.upgrade_stuff_id]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(grade_cfg.upgrade_stuff_id)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.toggle.isOn = true
				if is_click_one then
					self:OnStartAdvance(true)
				else
					self:OnAutomaticAdvance()
				end
			end
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, grade_cfg.upgrade_stuff_id, nofunc,
			(grade_cfg.upgrade_stuff_num - ItemData.Instance:GetItemNumInBagById(grade_cfg.upgrade_stuff_id)))
		return
	end

	local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0
	if is_click_one then
		self.is_auto = false
	end

	local pack_num = self.is_auto and grade_cfg.pack_num or 1

	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_UPGRADE, cur_mount_id, pack_num or 1, is_auto_buy)
	self.jinjie_next_time = Status.NowTime + (grade_cfg.next_time or 0.1)
end

--点击使用当前形象
function AdvanceMultiMountView:OnClickUseIma()
	if self.all_data[self.index] == nil then
		return
	end

	local cur_mount_id = self.all_data[self.index].mount_id
	if cur_mount_id == nil then
		return
	end

	local info_list = MultiMountData.Instance:GetDataById(cur_mount_id)
	if info_list == nil or next(info_list) == nil then
		return
	end

	local cur_mount = MultiMountData.Instance:GetCurUseMountId()
	if cur_mount == info_list.index then
		MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_CANCEL)
	else
		MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_SELECT_MOUNT, cur_mount_id)
	end
end

function AdvanceMultiMountView:OnClickListCell(mount_special_data, index, mount_cell)
	--self.mount_special_image = mount_special_data
	mount_cell:SetHighLight(true)
	self.show_up_type = false
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.index == index then return end
	self.index = index or 1
	self.item_id = mount_special_data.item_id

	self.temp_grade = -1
	self.old_grade_bless_val = nil
	self.old_star_level  = nil

	self:SetMultiAttr(mount_special_data, mount_special_data.mount_id)
end

--获取激活坐骑符数量
function AdvanceMultiMountView:GetHaveProNum(item_id, need_num, is_grade)
	if item_id == nil or need_num == nil then
		return
	end

	local count = ItemData.Instance:GetItemNumInBagById(item_id)
	if count < need_num then
		count = string.format(Language.Mount.ShowRedNum, count)
	else
		count = string.format(Language.Mount.ShowGreenNum, count)
	end

	if self.have_pro_num ~= nil and not is_grade then
		self.have_pro_num:SetValue(count)

		if self.need_pro_num ~= nil then
			self.need_pro_num:SetValue(need_num)
		end
	end

	if self.remainder_num ~= nil and is_grade then
		self.remainder_num:SetValue(count)

		if self.need_num ~= nil then
			self.need_num:SetValue(need_num)
		end
	end
end

function AdvanceMultiMountView:FlushRedPoint(mount_id)
	if mount_id == nil then
		return
	end

	local _, can_active, can_up_grade, can_up_level = MultiMountData.Instance:GetRenderRed(mount_id)
	if self.active_red ~= nil then
		self.active_red:SetValue(can_active)
	end

	if self.up_grade_red ~= nil then
		self.up_grade_red:SetValue(can_up_grade)
	end

	if self.up_level_red ~= nil then
		self.up_level_red:SetValue(can_up_level)
	end
end

function AdvanceMultiMountView:SetModleRestAni()
	self.timer = self.fix_show_time
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
				if self.mount_model then
					local part = self.mount_model.draw_obj:GetPart(SceneObjPart.Main)
					if part then
						part:SetTrigger("rest")
					end
				end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function AdvanceMultiMountView:SetMultiAttr(mount_special_data, index)
	if mount_special_data == nil then
		return
	end

	local info_cfg = MultiMountData.Instance:GetDataById(index)
	if info_cfg == nil or next(info_cfg) == nil then
		return
	end

	local show_grade = info_cfg.grade > -1 and info_cfg.grade or 0
	local grade_cfg, max_grade = MultiMountData.Instance:GetGradeInfoById(index, show_grade)
	local image_cfg = MultiMountData.Instance:GetImageCfgById(index)
	local level_cfg, max_level = MultiMountData.Instance:GetLeveInfoById(index, info_cfg.level)
	if grade_cfg == nil or next(grade_cfg) == nil then
		return
	end

	if image_cfg == nil or next(image_cfg) == nil then
		return
	end

	if level_cfg == nil or next(level_cfg) == nil then
		return
	end

	local _, can_active, can_up_grade, can_up_level = MultiMountData.Instance:GetRenderRed(index)

	local active_item = level_cfg.upgrade_stuff_id
	if self.show_btn_change ~= nil then
		if active_item ~= nil and info_cfg.grade > -1 then
			local has_num = ItemData.Instance:GetItemNumInBagById(active_item)
			if self.show_btn_change ~= nil then
				self.show_btn_change:SetValue(has_num > 0)
			end

			if has_num <= 0 then
				self.show_up_type = true
			end
		else
			self.show_btn_change:SetValue(false)
		end
	end

	self.grade_str:SetValue(CommonDataManager.GetDaXie(grade_cfg.client_grade) .. Language.Common.Jie)

	if self.name_obj ~= nil then
		local bundle, asset = ResPath.GetAdvanceEquipIcon("multi_mount_" .. (image_cfg.title_res or 1))
		self.name_obj:GetComponent(typeof(UnityEngine.UI.Image)):LoadSprite(bundle, asset, function()
			self.name_obj:GetComponent(typeof(UnityEngine.UI.Image)):SetNativeSize()
		end)
	end


	if self.temp_grade < 0 then
		self.temp_grade = info_cfg.grade
	else
		if self.temp_grade < info_cfg.grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 进阶成功提示
			TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordAdvenceSuccess"))
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				self.show_effect:SetValue(false)
				self.show_effect:SetValue(true)
				self.effect_cd = EFFECT_CD + Status.NowTime
			end

			self.is_auto = false
			-- if GLOBAL_CONFIG.param_list.is_ppload_user_info == 1 then
			-- 	AgentAdapter.Instance:SubmitInfo(mount_info.used_imageid)
			-- end
		end
		self.temp_grade = info_cfg.grade
	end

	if self.old_grade_bless_val == nil then 
		self.old_grade_bless_val = info_cfg.grade_bless --初始化
	end

	if self.old_star_level == nil then
		self.old_star_level = grade_cfg.show_star
	end

	if info_cfg.grade >= max_grade then
		self.cur_bless:SetValue(Language.Common.YiMan)
		--self:SetAutoButtonGray()
		self.exp_radio:InitValue(1)
	else
		self.cur_bless:SetValue(info_cfg.grade_bless .. "/" .. grade_cfg.max_bless)
		self.exp_radio:SetValue(info_cfg.grade_bless / grade_cfg.max_bless)
		--升星提示
		if self.old_grade_bless_val ~= info_cfg.grade_bless then
			if(info_cfg.grade_bless - self.old_grade_bless_val >= 50)  then
				TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpStarBaoji"))
			end
			self.old_grade_bless_val = info_cfg.grade_bless
		end

		if self.old_star_level ~= grade_cfg.show_star then
			--升星提示
			TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpStarSuccess"))
			self.old_star_level = grade_cfg.show_star
		end
	end

	if self.res_id ~= image_cfg.res_id then
		self.mount_model:SetDisplay(self.mount_display.ui3d_display)
		self.mount_model:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], image_cfg.res_id, DISPLAY_PANEL.HUAN_HUA)
		self.mount_model:SetMainAsset(ResPath.GetMountModel(image_cfg.res_id))
		local part = self.mount_model.draw_obj:GetPart(SceneObjPart.Main)
		if part then
			part:SetTrigger("rest")
		end
		self.res_id = image_cfg.res_id
	end

	self.grade = info_cfg.grade


	local attr = CommonStruct.Attribute()
	--local attr_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(index)
	local show_attr = self.show_up_type and grade_cfg or level_cfg
	local grade_cap = 0
	local grade_attr = CommonDataManager.GetAttributteByClass(grade_cfg)
	local level_attr = CommonDataManager.GetAttributteByClass(level_cfg)
	grade_cap = CommonDataManager.GetCapability(CommonDataManager.AddAttributeAttr(grade_attr, level_attr))
	--if attr_cfg ~= nil then
		attr.max_hp =  show_attr.maxhp
		attr.gong_ji = show_attr.gongji
		attr.fang_yu = show_attr.fangyu

		--self.grade = 0 ~= bit_list[64 - index] and attr_cfg.grade or -1

		self.cur_level:SetValue(info_cfg.level)
		--self.need_pro_num:SetValue(image_cfg.active_need_item_id or 1)
		-- self:GetHaveProNum(image_cfg.active_need_item_id, 1)
	--end

	local need_item, need_num, is_grade = MultiMountData.Instance:GetNeedItemCfg(index, not self.show_up_type)
	self:GetHaveProNum(need_item, need_num, is_grade)
	self:FlushRedPoint(index)

	local attr2 = CommonStruct.Attribute()
	local next_cfg = nil
	if self.show_up_type then
		next_cfg = MultiMountData.Instance:GetGradeInfoById(index, show_grade + 1)
	else
		next_cfg = MultiMountData.Instance:GetLeveInfoById(index, info_cfg.level + 1)
	end
	if next_cfg ~= nil and next(next_cfg) ~= nil then
		attr2.max_hp =  self.grade ~= -1 and next_cfg.maxhp - show_attr.maxhp or next_cfg.maxhp
		attr2.gong_ji = self.grade ~= -1 and next_cfg.gongji - show_attr.gongji or next_cfg.gongji
		attr2.fang_yu = self.grade ~= -1 and next_cfg.fangyu - show_attr.fangyu or next_cfg.fangyu
	end

	local capability2 = CommonDataManager.GetCapabilityCalculation(attr2)
	self.fight_power:SetValue(grade_cap)
	self.up_power:SetValue(capability2)
	local is_max = false

	if self.show_up_type then
		is_max = info_cfg.grade >= max_grade
	else
		is_max = info_cfg.level >= max_level
	end

	self.is_show_power_up_label:SetValue(self.grade ~= -1 and not is_max)
	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)

	local data = {}
	if self.grade ~= -1 then
		data = {item_id = grade_cfg.upgrade_stuff_id, is_bind = 0}
		if self.show_up_type then
			if self.upgrade_item ~= nil then
				self.upgrade_item:SetData(data)
			end
		else
			data = {item_id = level_cfg.upgrade_stuff_id, is_bind = 0} 
			if self.item ~= nil then
				self.item:SetData(data)
			end
		end
	else
		data = {item_id = image_cfg.active_need_item_id, is_bind = 0} 
		if self.item ~= nil then
			self.item:SetData(data)
		end		
	end

	self:SetAutoButtonGray(index)
	self:IsShowActivate(index)
	self:IsShowUpGrade(index)
	self:FlushStars()
end

--设置激活按钮显示和隐藏
function AdvanceMultiMountView:IsShowActivate(mount_id)
	if mount_id == nil then
		return
	end
	--local info_list = MountData.Instance:GetMountInfo()
	-- local bit_list = bit:ll2b(info_list.active_special_image_flag_high,info_list.active_special_image_flag_low)
	--local bit_list = info_list.active_special_image_list	

	local info_list = MultiMountData.Instance:GetDataById(mount_id)	
	if info_list == nil or next(info_list) == nil then
		return
	end		

	local cur_mount = MultiMountData.Instance:GetCurUseMountId()
	--把64位转换成table,返回1，表示激活
	self.show_activate_btn:SetValue(info_list.grade == -1)
	--self.show_use_ima_btn:SetValue(0 ~= info_list.is_mount_active)
	--self.show_use_image:SetValue(0 ~= info_list.is_mount_active)
	self.show_cur_level:SetValue(info_list.grade ~= -1)
	-- if info_list.used_imageid >= GameEnum.MOUNT_SPECIAL_IMA_ID then
	-- 	self.show_use_ima_btn:SetValue(image_id ~= (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
	-- 												and 0 ~= bit_list[64 - image_id])
	-- 	self.show_use_image:SetValue(image_id == (info_list.used_imageid - GameEnum.MOUNT_SPECIAL_IMA_ID)
	-- 												and 0 ~= bit_list[64 - image_id])
	-- else
	-- 	self.show_use_ima_btn:SetValue(0 ~= bit_list[64 - image_id])
	-- 	self.show_use_image:SetValue(false)
	-- end

	--self.show_use_ima_btn:SetValue(info_list.grade ~= -1 and cur_mount ~= info_list.index)
	--self.show_use_image:SetValue(info_list.grade ~= -1 and cur_mount == info_list.index)
	if self.show_use_ima_btn ~= nil then
		self.show_use_ima_btn:SetValue(info_list.grade ~= -1)
	end

	if self.use_btn_str ~= nil then
		local str = cur_mount == info_list.index and Language.Common.CancelUse or Language.Common.Use
		self.use_btn_str:SetValue(str)
	end
end

--设置升级按钮显示和隐藏
function AdvanceMultiMountView:IsShowUpGrade(image_id)
	-- if image_id == nil then
	-- 	return
	-- end
	-- local special_img_up = MountData.Instance:GetSpecialImageUpgradeCfg()
	-- local info_list = MountData.Instance:GetMountInfo()
	-- -- local bit_list = bit:ll2b(info_list.active_special_image_flag_high,info_list.active_special_image_flag_low)
	-- local bit_list = info_list.active_special_image_list
	-- for k, v in pairs(special_img_up) do
	-- 	if v.special_img_id == image_id then
	-- 		self.show_upgrade_btn:SetValue(0 ~= bit_list[64 - image_id])
	-- 		break
	-- 	else
	-- 		self.show_upgrade_btn:SetValue(false)
	-- 	end
	-- end

	self.show_upgrade_btn:SetValue(self.show_up_type)
end

--升级按钮是否置灰
function AdvanceMultiMountView:SetAutoButtonGray(mount_id)
	if mount_id == nil  then return end

	local info_cfg = MultiMountData.Instance:GetDataById(mount_id)
	if info_cfg == nil or next(info_cfg) == nil then
		return
	end

	local _, max_grade = MultiMountData.Instance:GetGradeInfoById(mount_id, info_cfg.grade)

	if info_cfg.is_mount_active == 0 or info_cfg.grade >= max_grade then
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = false
		self.up_grade_gray:SetValue(false)
		self.auto_button.button.interactable = false
		self.auto_up_grade_gray:SetValue(false)
		return
	end

	if self.is_auto then
		self.auto_btn_text:SetValue(Language.Common.Stop)
		self.start_button.button.interactable = false
		self.up_grade_gray:SetValue(false)
		self.auto_button.button.interactable = true
		self.auto_up_grade_gray:SetValue(true)
		self.is_can_auto = true
	else
		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
		self.start_button.button.interactable = true
		self.up_grade_gray:SetValue(true)
		self.auto_button.button.interactable = true
		self.auto_up_grade_gray:SetValue(true)
	end
end

function AdvanceMultiMountView:FlushStars()
	if self.all_data[self.index] == nil then
		return
	end

	local cur_mount_id = self.all_data[self.index].mount_id
	if cur_mount_id == nil then
		return
	end

	local info_cfg = MultiMountData.Instance:GetDataById(cur_mount_id)
	local grade_cfg = MultiMountData.Instance:GetGradeInfoById(cur_mount_id, info_cfg.grade)
	if grade_cfg == nil or next(grade_cfg) == nil then
		return
	end

	if self.show_star ~= nil then
		self.show_star:SetValue(grade_cfg.client_star > 0)
	end

	for i = 1, 10 do
		if self.star_lists[i] ~= nil then
			self.star_lists[i]:SetValue(grade_cfg.client_star >= i)
		end
	end
end

function AdvanceMultiMountView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "multi_mount" then
			local need_change = false
			local old_id = nil
			if self.all_data ~= nil and self.all_data[self.index] then
				old_id = self.all_data[self.index].mount_id
			end

			self.all_num, self.all_data = MultiMountData.Instance:GetImageListCfg()
			local mount_id = self.all_data[self.index]
			if old_id ~= nil and old_id ~= mount_id then
				need_change = true
			end
			--self.title_icon:SetAsset("uis/views/advanceview_images","icon_mounthuanhua")
			--local mount_special_image = MountData.Instance:GetSpecialImagesCfg()
			--local _, mountprint_special_image = MountData.Instance:GetShowSpecialInfo()
			if self.all_data ~= nil and self.index ~= nil and self.all_data[self.index] == nil then
				self.index = 1
			end
			if v.need_flush then
				self.list_view.scroller:ReloadData(0)
			else
				self.list_view.scroller:RefreshActiveCellViews()
			end
	
			--local upgrade_cfg = MountData.Instance:GetSpecialImageUpgradeInfo(self.all_data[self.index].image_id)
			--local info_list = MountData.Instance:GetMountInfo()
			-- local bit_list = bit:ll2b(info_list.active_special_image_flag_high,info_list.active_special_image_flag_low)
			--local bit_list = info_list.active_special_image_list
			

			if self.all_data[self.index] ~= nil then
				--self:GetHaveProNum(self.item_id, upgrade_cfg.stuff_num)
				--self:IsShowActivate(self.all_data[self.index].image_id)
				--self:IsShowUpGrade(self.all_data[self.index].image_id)
				self:SetMultiAttr(self.all_data[self.index], self.all_data[self.index].mount_id)
				self:SetAutoButtonGray(self.all_data[self.index].mount_id)
				-- self.list_view.scroller:RefreshActiveCellViews()
			end
		end
	end
end

function AdvanceMultiMountView:MultiMountUpGradeResult(result)
	self.is_can_auto = true
	if 0 == result then
		self.is_auto = false
		self:SetAutoButtonGray()
	else
		self:AutoUpGradeOnce()
	end
end

function AdvanceMultiMountView:AutoUpGradeOnce()
	local jinjie_next_time = 0
	if nil ~= self.upgrade_timer_quest then
		if self.jinjie_next_time >= Status.NowTime then
			jinjie_next_time = self.jinjie_next_time - Status.NowTime
		end
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
	end

	if self.all_data[self.index] == nil then
		return
	end

	local mount_id = self.all_data[self.index].mount_id
	if mount_id == nil then
		return
	end

	local info_cfg = MultiMountData.Instance:GetDataById(mount_id)
	if info_cfg == nil or next(info_cfg) == nil then
		return
	end

	local _, max_grade = MultiMountData.Instance:GetGradeInfoById(mount_id)
	if info_cfg.grade > -1 and info_cfg.grade < max_grade then
		if self.is_auto then
			self.upgrade_timer_quest = GlobalTimerQuest:AddDelayTimer(BindTool.Bind2(self.OnStartAdvance,self), jinjie_next_time)
		end
	end
end

-- 自动进阶
function AdvanceMultiMountView:OnAutomaticAdvance()
	if self.all_data[self.index] == nil then
		return
	end

	local mount_id = self.all_data[self.index].mount_id
	if mount_id == nil then
		return
	end

	local info_cfg = MultiMountData.Instance:GetDataById(mount_id)
	if info_cfg == nil or next(info_cfg) == nil then
		return
	end

	if info_cfg.grade == -1 then
		return
	end

	if not self.is_can_auto then
		return
	end

	local function ok_callback()
		if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_multi_up"] and TipsCommonAutoView.AUTO_VIEW_STR_T["auto_multi_up"].is_auto_buy then
			self.auto_buy_toggle.toggle.isOn = true
		end
		self.is_auto = self.is_auto == false
		--self.auto_buy_toggle.toggle.isOn = is_show
		self.is_can_auto = false
		self:OnStartAdvance()
		self:SetAutoButtonGray()
	end

	local function canel_callback()
		self:SetAutoButtonGray()
	end
	--if not self.is_auto then
	if not self.auto_buy_toggle.toggle.isOn then
		TipsCtrl.Instance:ShowCommonAutoView("auto_multi_up", Language.Mount.AutoUpDes, ok_callback, canel_callback, false, nil, nil, nil, true)
	else
		ok_callback()
	end
end

function AdvanceMultiMountView:OnAutoBuyToggleChange(isOn)
	if TipsCommonAutoView.AUTO_VIEW_STR_T["auto_multi_up"] then
		TipsCommonAutoView.AUTO_VIEW_STR_T["auto_multi_up"].is_auto_buy = isOn
	end
end


MultiMountCell = MultiMountCell or BaseClass(BaseCell)

function MultiMountCell:__init()
	-- self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.name_hl = self:FindVariable("Name_HL")
	self.show_red_ponit = self:FindVariable("ShowRedPoint")
	self.is_possess_img = self:FindVariable("Is_Possess")
	self.show_tip = self:FindVariable("ShowTip")
	self:ListenEvent("ClickTip", BindTool.Bind(self.ClickTip, self))
	self.index = 0
end

function MultiMountCell:__delete()
	self.icon = nil
	self.name = nil
	self.show_red_ponit = nil
	self.is_possess_img = nil
end

function MultiMountCell:OnFlush()
	if self.data == nil or next(self.data) == nil then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then return end

	local name_str = self.data.image_name
	self.name:SetValue(name_str)
	self.name_hl:SetValue(self.data.image_name)
	self.show_red_ponit:SetValue(self.data.is_show)
	self.index = self.data.index

	-- local info_list = MountData.Instance:GetMountInfo()

	-- local bit_list = info_list.active_special_image_list
	-- local _, special_data = MountData.Instance:GetShowSpecialInfo()
	-- local image_id = special_data[self.index].image_id
	-- self.is_possess_img:SetValue(bit_list[64 - image_id] == 1)
	if self.data.mount_id ~= nil then
		local info_cfg = MultiMountData.Instance:GetDataById(self.data.mount_id)
		if info_cfg ~= nil and next(info_cfg) ~= nil then
			self.is_possess_img:SetValue(info_cfg.grade > -1)
		end
	end

	local check_grade = MultiMountData.Instance:GetRemindGrade()
	if self.show_tip ~= nil and self.data.info ~= nil then
		local grade_bless = self.data.info and self.data.info.grade_bless or 0
		local grade = self.data.info and self.data.info.grade or 0
		self.show_tip:SetValue(grade_bless > 0 and grade >= check_grade)
	end
end

function MultiMountCell:ClickTip()
	SysMsgCtrl.Instance:ErrorRemind(Language.Advance.MultiShowTip)
end

function MultiMountCell:ListenClick(handler)
	self:ClearEvent("Click")
	self:ListenEvent("Click", handler)
end

function MultiMountCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function MultiMountCell:SetHighLight(enable)
	self.root_node.toggle.isOn = enable
end