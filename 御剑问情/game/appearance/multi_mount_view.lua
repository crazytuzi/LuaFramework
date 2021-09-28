MultiMountView = MultiMountView or BaseClass(BaseRender)

local EFFECT_CD = 1.8
function MultiMountView:__init(instance)
	self:ListenEvent("StartAdvance",
		BindTool.Bind(self.OnStartAdvance, self,true))
	self:ListenEvent("AutomaticAdvance",
		BindTool.Bind(self.OnAutomaticAdvance, self))
	self:ListenEvent("OnClickUse",
		BindTool.Bind(self.OnClickUse, self))
	self:ListenEvent("OnClickZiZhi",
		BindTool.Bind(self.OnClickZiZhi, self))
	self:ListenEvent("OnClickHuanHua",
		BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickLastButton",
		BindTool.Bind(self.OnClickLastButton, self))
	self:ListenEvent("OnClickNextButton",
		BindTool.Bind(self.OnClickNextButton, self))
	self:ListenEvent("OnClickEquipBtn",
		BindTool.Bind(self.OnClickEquipBtn, self))
	self:ListenEvent("OnClickSendMsg",
		BindTool.Bind(self.OnClickSendMsg, self))
	self:ListenEvent("OnClickCancle",
		BindTool.Bind(self.OnClickCancle, self))
	self:ListenEvent("OnClickHelp",
		BindTool.Bind(self.OnClickHelp, self))

	self.mount_name = self:FindVariable("Name")
	self.mount_rank = self:FindVariable("Rank")
	self.exp_radio = self:FindVariable("ExpRadio")
	self.sheng_ming = self:FindVariable("HPValue")
	self.fight_power = self:FindVariable("FightPower")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.ming_zhong = self:FindVariable("MingZhong")
	self.shan_bi = self:FindVariable("ShanBi")
	self.bao_ji = self:FindVariable("BaoJi")
	self.jian_ren = self:FindVariable("JianRen")
	self.jia_shang = self:FindVariable("JiaShang")
	self.jian_shang = self:FindVariable("JianShang")
	self.su_du = self:FindVariable("SuDu")
	self.remainder_num = self:FindVariable("RemainderNum")
	self.quality = self:FindVariable("QualityBG")
	self.auto_btn_text = self:FindVariable("AutoButtonText")
	self.look_btn_text = self:FindVariable("LookBtnText")

	self.show_use_button = self:FindVariable("UseButton")
	self.show_use_image = self:FindVariable("UseImage")
	self.show_left_button = self:FindVariable("LeftButton")
	self.show_right_button = self:FindVariable("RightButton")
	self.show_on_look = self:FindVariable("IsOnLookState")
	self.show_equip_remind = self:FindVariable("ShowEquipRemind")
	self.show_stars = self:FindVariable("ShowStars")
	self.limit_txt = self:FindVariable("LimitTxt")

	self.prop_name = self:FindVariable("PropName")
	self.cur_bless = self:FindVariable("CurBless")
	self.show_zizhi_redpoint = self:FindVariable("ShowZizhiRedPoint")
	self.show_huanhua_redpoint = self:FindVariable("ShowHuanhuaRedPoint")
	self.show_skill_arrow1 = self:FindVariable("ShowSkillUplevel1")
	self.show_skill_arrow2 = self:FindVariable("ShowSkillUplevel2")
	self.show_skill_arrow3 = self:FindVariable("ShowSkillUplevel3")
	self.need_num = self:FindVariable("need_num")
	self.show_gray = self:FindVariable("ShowGray")

	self.auto_buy_toggle = self:FindObj("AutoToggle")
	self.auto_buy_toggle.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))

	self.start_button = self:FindObj("StartButton")
	self.auto_button = self:FindObj("AutoButton")
	self.gray_use_button = self:FindObj("GrayUseButton")
	self.display = self:FindObj("Display")
	self.effect = self:FindObj("EffectRoot")
	self.model = RoleModel.New("multi_mount_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self.item = self:FindObj("Item")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.item)


	self.cell_list = {}
	self.list_index = self.list_index or 1
	self.list_view = self:FindObj("MountList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.stars_list = {}
	local stars_obj = self:FindObj("Stars")
	for i = 1, 10 do
		self.stars_list[i] = stars_obj:FindObj("Star"..i)
	end

	self.stars_hide_list = {}
	for i=1,10 do
		self.stars_hide_list[i] = {
		hide_star = self:FindVariable("ShowStar"..i)
	}
	end

	self.is_auto = false
	self.is_can_auto = true
	self.is_enough = false
	self.jinjie_next_time = 0
	self.temp_grade = -1
	self.skill_fight_power = 0
	self.fix_show_time = 10
	self.res_id = -1
	self.is_on_look = false
	self.prefab_preload_id = 0
	self.last_level = 0
end

function MultiMountView:__delete()
	self.show_gray = nil
	self.item = nil
	self.jinjie_next_time = nil
	self.is_auto = nil
	self.temp_grade = nil
	self.list_index = nil
	self.skill_fight_power = nil
	self.res_id = nil
	self.last_level = nil
	self.effect = nil

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end

	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	if self.model then
		self.model:DeleteMe()
		self.model = nil
	end

	PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
end

function MultiMountView:SetItemCell(id)
	self.item_cell:SetData({item_id = id})
end

-- 开始进阶
function MultiMountView:OnStartAdvance(is_click)
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if nil == mount_info then
		return
	end

	local star_cfg = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade)
	if star_cfg == nil  then return end
	local stuff_item_id = star_cfg.upgrade_stuff_id

	local is_auto_buy_toggle = self.auto_buy_toggle.toggle.isOn
	if mount_info.grade >= MultiMountData.Instance:GetMaxGradeByIndex(self.list_index) then
		return
	end

	local is_auto_buy = self.auto_buy_toggle.toggle.isOn and 1 or 0
	local pack_num = star_cfg and star_cfg.upgrade_stuff_num or 1
	local next_time = star_cfg and star_cfg.next_time or 0.1
	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_UPGRADE, self.list_index, pack_num, is_auto_buy)
	-- self.jinjie_next_time = Status.NowTime + (next_time or 0.1)
end

function MultiMountView:FlsuhAutoBuyToggle()
	if self.auto_buy_toggle and self.auto_buy_toggle.toggle then
		self.auto_buy_toggle.toggle.isOn = TipsOtherHelpData.Instance:GetIsAutoBuy()
	end
end


function MultiMountView:MultiMountUpgradeResult(result)

end


-- 自动进阶
function MultiMountView:OnAutomaticAdvance()
	local grade = MultiMountData.Instance:GetMountLevelByIndex(self.list_index)

	if grade == nil then
		return
	end
	-- if not self.is_can_auto then
	-- 	return
	-- end

	local function ok_callback()
		self.is_auto = self.is_auto == false
		self.is_can_auto = false
		self:OnStartAdvance(true)
		-- self:SetAutoButtonGray()
	end

	ok_callback()
end

function MultiMountView:OnClickSendMsg()
	local mount_info = MultiMountData.Instance:GetMountLevelByIndex(self.list_index)
	if not mount_info then return end

	-- 发送冷却CD
	if not ChatData.Instance:GetChannelCdIsEnd(CHANNEL_TYPE.WORLD) then
		local time = ChatData.Instance:GetChannelCdEndTime(CHANNEL_TYPE.WORLD) - Status.NowTime
		time = math.ceil(time)
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Chat.SendFail, time))
		return
	end

	local mount_grade = mount_info.grade
	local name = MultiMountData:GetMountNameByIndex(self.list_index)
	local color = SOUL_NAME_COLOR_CHAT[self.list_index]
	local btn_color = self.list_index

	local game_vo = GameVoManager.Instance:GetMainRoleVo()
	local content = string.format(Language.Chat.AdvancePreviewLinkList[0], game_vo.role_id, name, color, btn_color, CHECK_TAB_TYPE.MOUNT)
	ChatCtrl.SendChannelChat(CHANNEL_TYPE.WORLD, content, CHAT_CONTENT_TYPE.TEXT)

	ChatData.Instance:SetChannelCdEndTime(CHANNEL_TYPE.WORLD)
	TipsCtrl.Instance:ShowSystemMsg(Language.Chat.SendSucc)
end

-- 使用当前坐骑
function MultiMountView:OnClickUse()
	if self.list_index == nil then
		return
	end

	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	if role_vo.multi_mount_res_id > 0 then
		MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_UNRIDE)
	end

	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_SELECT_MOUNT, self.list_index)
end

-- 使用当前坐骑
function MultiMountView:OnClickCancle()
	if self.list_index == nil then
		return
	end
	MultiMountCtrl.Instance:SendMultiModuleReq(MULTI_MOUNT_REQ_TYPE.MULTI_MOUNT_REQ_TYPE_SELECT_MOUNT, self.list_index)
end


function MultiMountView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(233)
end

--显示上一阶形象
function MultiMountView:OnClickLastButton()
	if not self.list_index or self.list_index <= 1 then
		return
	end
	self.is_auto = false
	self.list_index = self.list_index - 1
	self:SetArrowState(self.list_index)
	self.temp_grade = -1
	-- self:SetAutoButtonGray()
	self:Flush()
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if mount_info then
		self.last_level = mount_info.grade
	end
end

--显示下一阶形象
function MultiMountView:OnClickNextButton()
	if not self.list_index or self.list_index >= MultiMountData.Instance:GetMaxIndex() then
		return
	end
	self.is_auto = false
	self.list_index = self.list_index + 1
	self:SetArrowState(self.list_index)
	self.temp_grade = -1
	-- self:SetAutoButtonGray()
	self:Flush()
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if mount_info then
		self.last_level = mount_info.grade
	end
end

function MultiMountView:GetSelectIndex()
	return self.list_index or 1
end

function MultiMountView:SetSelectIndex(index)
	self.list_index = index
	self:SetArrowState(self.list_index)
	self.temp_grade = -1
	self.is_auto = false
	-- self:SetAutoButtonGray()
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if mount_info then
		self.last_level = mount_info.grade
	end
	self:Flush()
end

-- 资质
function MultiMountView:OnClickZiZhi()
	-- ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "mountzizhi", {item_id = MountDanId.ZiZhiDanId})
end

-- 点击进阶装备
function MultiMountView:OnClickEquipBtn()
	-- local is_active, activite_grade = MultiMountData.Instance:IsOpenEquip()
	-- if not is_active then
	-- 	local name = Language.Advance.PercentAttrNameList[TabIndex.mount_jinjie] or ""
	-- 	TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.OnOpenEquipTip, name, CommonDataManager.GetDaXie(activite_grade)))
	-- 	return
	-- end
	-- ViewManager.Instance:Open(ViewName.AdvanceEquipView, TabIndex.mount_jinjie)
end

-- 幻化
function MultiMountView:OnClickHuanHua()
	MultiMountCtrl.Instance:OpenHuanhuaView()
end

-- 点击坐骑技能
function MultiMountView:OnClickMountSkill(index)
	-- ViewManager.Instance:Open(ViewName.TipSkillUpgrade, nil, "mountskill", {index = index - 1})
end

-- 设置坐骑属性
function MultiMountView:SetMultiMountAtrr()
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if mount_info == nil then
		-- self:SetAutoButtonGray()
		return
	end
	self.auto_btn_text:SetValue(mount_info.grade > 0 and Language.Common.Up or Language.Common.Activate)
	local next_cfg = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade + 1)
	self.show_gray:SetValue(next_cfg == nil)
	if next_cfg == nil then
		self.auto_btn_text:SetValue(Language.Common.YiManJi)
	end
	local star_cfg = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade)
	if star_cfg == nil then return end
	local stuff_item_id = star_cfg.upgrade_stuff_id

	self.need_num:SetValue(star_cfg.upgrade_stuff_num)

	self.item_cell:SetData({item_id = stuff_item_id})
--	self:SetItemCell(stuff_item_id)

	--星星等级star_cfg.grade % 10

	if self.temp_grade < 0 then
		-- self:SetAutoButtonGray()
		self:SetArrowState(self.list_index)
		self:SwitchGradeAndName(self.list_index)
		self.temp_grade = mount_info.grade
	else
		if self.temp_grade < mount_info.grade then
			-- 升级成功音效
			AudioService.Instance:PlayAdvancedAudio()
			-- 升级特效
			if not self.effect_cd or self.effect_cd <= Status.NowTime then
				EffectManager.Instance:PlayAtTransform("effects2/prefab/ui/ui_jinjiechenggeng_prefab", "UI_jinjiechenggeng", self.effect.transform, 1.0, nil, nil)
				self.effect_cd = EFFECT_CD + Status.NowTime
			end

			self.is_auto = false
			self.res_id = -1
			-- self:SetAutoButtonGray()
			self:SetArrowState(self.list_index)
			self:SwitchGradeAndName(self.list_index)

			self.show_on_look:SetValue(false)
			self.look_btn_text:SetValue(Language.Common.Look)
		end
		self.temp_grade = mount_info.grade
	end
	self:SetUseImageButtonState(self.list_index)

	-- if mount_info.grade >= MultiMountData.Instance:GetMaxGradeByIndex(self.list_index) then
	-- 	self.cur_bless:SetValue(Language.Common.YiMan)
	-- 	self:SetAutoButtonGray()
	-- 	self.exp_radio:InitValue(1)
	-- 	self.show_stars:SetValue(false)
	-- else
	-- 	self.cur_bless:SetValue(mount_info.grade_bless.."/"..star_cfg.max_bless)
	-- 	if self.is_first then
	-- 		self.exp_radio:InitValue(mount_info.grade_bless/star_cfg.max_bless)
	-- 		self.is_first = false
	-- 	else
	-- 		self.exp_radio:SetValue(mount_info.grade_bless/star_cfg.max_bless)
	-- 	end
	-- 	self.show_stars:SetValue(true)
	-- end

	local skill_capability = 0

	self.skill_fight_power = skill_capability
	local attr = CommonDataManager.GetAttributteByClass(star_cfg)
	local capability = CommonDataManager.GetCapabilityCalculation(attr)
	self.fight_power:SetValue(capability + skill_capability)

	self.sheng_ming:SetValue(attr.max_hp)
	self.gong_ji:SetValue(attr.gong_ji)
	self.fang_yu:SetValue(attr.fang_yu)
	self.ming_zhong:SetValue(attr.ming_zhong)
	self.shan_bi:SetValue(attr.shan_bi)
	self.bao_ji:SetValue(attr.bao_ji)
	self.jian_ren:SetValue(attr.jian_ren)
	local speed = math.floor((attr.move_speed / GameEnum.BASE_SPEED) * 100 + 0.5)
	self.su_du:SetValue(speed..'%')

	local bag_num = ItemData.Instance:GetItemNumInBagById(stuff_item_id)
	local bag_num_str = string.format(Language.Common.ShowYellowStr, bag_num)
	if bag_num < star_cfg.upgrade_stuff_num then
		bag_num_str = string.format(Language.Mount.ShowRedNum, bag_num)
	end
	self.remainder_num:SetValue(bag_num_str)

	local item_cfg = ItemData.Instance:GetItemConfig(stuff_item_id)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.prop_name:SetValue(name_str)

	self.jia_shang:SetValue(attr.per_pofang)
	self.jian_shang:SetValue(attr.per_mianshang)
end

function MultiMountView:SetArrowState(index)
	self.show_right_button:SetValue(index < MultiMountData.Instance:GetMaxIndex())
	self.show_left_button:SetValue(index > 1)
end

function MultiMountView:SetUseImageButtonState(index)
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if mount_info == nil then
		return
	end
	local used_imageid = MultiMountData.Instance:GetCurUseMountId()
	local is_active = MultiMountData.Instance:GetMountIsActiveByIndex(index)
	self.show_use_button:SetValue(is_active and index ~= used_imageid)
	self.show_use_image:SetValue(is_active and index == used_imageid)
	--该坐骑是否激活
	local content = ""
	if not is_active then
		local grade, name = MultiMountData.Instance:GetCurMountActiveCfg(index - 1)
		local active_level = MultiMountData.Instance:GetCurMountActiveCfg(index)
		local is_mount_active = true
		local star_cfg = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade)
		if star_cfg == nil then return end
		local stuff_item_id = star_cfg.upgrade_stuff_id
		local item_cfg = ItemData.Instance:GetItemConfig(stuff_item_id)
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..name.."</color>"
		content = is_mount_active and  string.format(Language.MultiMount.ActiveLevel, MultiMountData.Instance:GetBigGrade(index, active_level)) or
		string.format(Language.MultiMount.CanActive, name_str, MultiMountData.Instance:GetBigGrade(index - 1, grade))
	end
	self.limit_txt:SetValue(content)
end

-- 物品不足，购买成功后刷新物品数量
function MultiMountView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if nil == mount_info or nil == self.remainder_num then
		return
	end
	local star_cfg = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.list_index, mount_info.grade)
	if nil == star_cfg  then return end
	local stuff_item_id = star_cfg.upgrade_stuff_id

	local bag_num = string.format(Language.Common.ShowYellowStr, ItemData.Instance:GetItemNumInBagById(stuff_item_id))
	if ItemData.Instance:GetItemNumInBagById(stuff_item_id) < star_cfg.upgrade_stuff_num then
		bag_num = string.format(Language.Mount.ShowRedNum, ItemData.Instance:GetItemNumInBagById(stuff_item_id))
	end
	self.remainder_num:SetValue(bag_num)
end

-- 切换坐骑阶数、名字、模型
function MultiMountView:SwitchGradeAndName(index)
	if index == nil then return end

	local mount_grade_cfg = MultiMountData.Instance:GetMountInfoCfgByIndex(index)
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(index)
	if mount_grade_cfg == nil or mount_info == nil then return end

	local bundle, asset = nil, nil
	if math.floor(index / 3 + 1) >= 5 then
		 bundle, asset = ResPath.GetMountGradeQualityBG(5)
	else
		 bundle, asset = ResPath.GetMountGradeQualityBG(math.floor(index / 3 + 1))
	end
	self.quality:SetAsset(bundle, asset)

	local big_grade = CommonDataManager.GetDaXie(mount_info.grade) .. Language.Common.Jie
	self.mount_rank:SetValue(big_grade)

	if self.res_id ~= mount_grade_cfg.res_id then
		local color = index
		local name_str = "<color=" .. SOUL_NAME_COLOR[color] .. ">" .. mount_grade_cfg.mount_name .. "</color>"
		self.mount_name:SetValue(name_str)
		local call_back = function(model, obj)
			local cfg = model:GetModelDisplayParameterCfg(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MOUNT], mount_grade_cfg.res_id)
			if obj then
				if cfg then
					obj.transform.localPosition = cfg.position
					obj.transform.localRotation = Quaternion.Euler(cfg.rotation.x, cfg.rotation.y, cfg.rotation.z)
					obj.transform.localScale = cfg.scale
				else
					obj.transform.localPosition = Vector3(0, 0, 0)
					obj.transform.localRotation = Quaternion.Euler(0, -30, 0)
					obj.transform.localScale = Vector3(0.7, 0.7, 0.7)
				end
			end
			model:SetTrigger(ANIMATOR_PARAM.REST)
		end
		bundle, asset = ResPath.GetMountModel(mount_grade_cfg.res_id)

		self.model:SetMainAsset(bundle, asset)

		PrefabPreload.Instance:StopLoad(self.prefab_preload_id)
		local load_list = {{bundle, asset}}
		self.prefab_preload_id = PrefabPreload.Instance:LoadPrefables(load_list, function()
				local bundle_list = {[SceneObjPart.Main] = bundle}
				local asset_list = {[SceneObjPart.Main] = asset}
			end)

		self.res_id = mount_grade_cfg.res_id
	end
end

-- 设置进阶按钮状态
-- function MultiMountView:SetAutoButtonGray()
-- 	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
-- 	if mount_info == nil then return end

-- 	local max_grade = MultiMountData.Instance:GetMaxGradeByIndex(self.list_index)

-- 	if not mount_info or mount_info.grade >= max_grade then
-- 		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
-- 		self.start_button.button.interactable = false
-- 		self.auto_button.button.interactable = false
-- 		return
-- 	end

-- 	if self.is_auto then
-- 		self.auto_btn_text:SetValue(Language.Common.Stop)
-- 		self.start_button.button.interactable = false
-- 		self.show_gray:SetValue(false)
-- 		self.auto_button.button.interactable = true
-- 	else
-- 		self.auto_btn_text:SetValue(Language.Common.ZiDongJinJie)
-- 		self.start_button.button.interactable = true
-- 		self.show_gray:SetValue(true)
-- 		self.auto_button.button.interactable = true
-- 	end
-- end

function MultiMountView:SetModle(is_show)
	if is_show then
		local used_imageid = MultiMountData.Instance:GetCurUseMountId()

		-- 还原到非预览状态
		self.is_on_look = false
		self.show_on_look:SetValue(false)
		self.look_btn_text:SetValue(Language.Common.Look)

		self.list_index = self.list_index > 0 and self.list_index or used_imageid
		self:SetArrowState(self.list_index)
		self:SwitchGradeAndName(self.list_index)
		self:SetModleRestAni()
	else
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
		self.list_index = -1
		self.temp_grade = -1
	end
end

function MultiMountView:ClearTempData()
	self.res_id = -1
	self.list_index = -1
	self.temp_grade = -1
	self.is_auto = false
end

function MultiMountView:SetModleRestAni()
	self.timer = self.fix_show_time
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
	if not self.time_quest then
		self.time_quest = GlobalTimerQuest:AddRunQuest(function()
			self.timer = self.timer - UnityEngine.Time.deltaTime
			if self.timer <= 0 then
					if part then
						part:SetTrigger(ANIMATOR_PARAM.REST)
					end
				self.timer = self.fix_show_time
			end
		end, 0)
	end
end

function MultiMountView:RemoveNotifyDataChangeCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end

	self.temp_grade = -1
	self.list_index = -1
	self.res_id = -1
	if self.upgrade_timer_quest then
		GlobalTimerQuest:CancelQuest(self.upgrade_timer_quest)
		self.upgrade_timer_quest = nil
	end
end

function MultiMountView:ResetModleRotation()

end

-- 剩余时间刷新
function MultiMountView:SetRestTime()
end

function MultiMountView:OnAutoBuyToggleChange(isOn)

end

function MultiMountView:InitView()
	if self.show_effect then
		self.show_effect:SetValue(false)
	end
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.list_index)
	if mount_info then
		self.last_level = mount_info.grade
	end
	self.is_first = true
	self:Flush()
end

function MultiMountView:OnFlush(param_list)
	if self.root_node.gameObject.activeSelf then
		self:SetMultiMountAtrr()
		-- self:FlushStars()
		self.list_view.scroller:RefreshActiveCellViews()
	end
end

function MultiMountView:GetNumberOfCells()
	return math.max(MultiMountData.Instance:GetMaxIndex(), 4)
end


function MultiMountView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local star_cell = self.cell_list[cell]
	if star_cell == nil then
		star_cell = MultiMountItem.New(cell.gameObject)
		star_cell.root_node.toggle.group = self.list_view.toggle_group
		star_cell.multi_mount_view = self
		self.cell_list[cell] = star_cell
	end

	star_cell:SetItemIndex(data_index)
	star_cell:SetData(MultiMountData.Instance:GetMountInfoCfgByIndex(data_index))
end


---------------------MultiMountItem--------------------------------
MultiMountItem = MultiMountItem or BaseClass(BaseCell)

function MultiMountItem:__init()
	self.multi_mount_view = nil
	self.show_hl = self:FindVariable("show_hl")
	self.show_rp = self:FindVariable("show_rp")
	-- self.level = self:FindVariable("level")
	self.name = self:FindVariable("Name")
	self.image_path = self:FindVariable("image_path")
	self.show_lock = self:FindVariable("show_lock")

	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClickItem, self))
end

function MultiMountItem:__delete()
	self.multi_mount_view = nil
end

function MultiMountItem:SetItemIndex(index)
	self.item_index = index
end

function MultiMountItem:OnFlush()
	self:FlushHL()
	self.show_lock:SetValue(self.data == nil)
	if self.data == nil then
		self.name:SetValue(Language.Role.ToExpect)
		return
	end
	local is_active = true
	if self.item_index > 1 then
		is_active = MultiMountData.Instance:GetMountIsActiveByIndex(self.item_index - 1)
	end
	local mount_info = MultiMountData.Instance:GetMountInfoByIndex(self.item_index)
	local star_cfg = MultiMountData.Instance:GetMountCfgByIdAndLevel(self.item_index, mount_info.grade)
	local temp = ItemData.Instance:GetItemNumInBagById(star_cfg.upgrade_stuff_id)
	self.show_rp:SetValue(MultiMountData.Instance:GetRedPoint(self.item_index,temp,mount_info.grade) and is_active)
	self.image_path:SetAsset("uis/views/appearance/images_atlas", "multi_mount_head_" .. self.item_index)

end

function MultiMountItem:OnClickItem(is_click)
	if is_click then
		local select_index = self.multi_mount_view:GetSelectIndex()
		if select_index == self.item_index then
			return
		end
		self.multi_mount_view:SetSelectIndex(self.item_index)
	end
end

function MultiMountItem:FlushHL()
	local select_index = self.multi_mount_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.item_index)
end

