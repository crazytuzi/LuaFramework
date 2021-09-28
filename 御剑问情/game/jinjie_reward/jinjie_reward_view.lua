JinJieRewardView = JinJieRewardView or BaseClass(BaseView)

function JinJieRewardView:__init()
	self.ui_config = {"uis/views/jinjiereward_prefab", "JinJieRewardView"}
end

function JinJieRewardView:LoadCallBack()
	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.fight_power = self:FindVariable("FightPower")
	self.is_can_free_get = self:FindVariable("IsCanFreeGet")
	self.is_free = self:FindVariable("IsFree")
	self.free_time = self:FindVariable("FreeTime")
	self.need_gold = self:FindVariable("NeedGold")       
	self.title_icon = self:FindVariable("TitleIcon")
	self.show_text_icon = self:FindVariable("ShowTextIcon")
	self.show_text_level = self:FindVariable("ShowTextLevel")
	self.effect_des = self:FindVariable("EffectDes")
	self.hp = self:FindVariable("Hp")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.is_active = self:FindVariable("IsActive")
	self.is_huanhua = self:FindVariable("IsHuanHua")
	self.is_get_active_item = self:FindVariable("IsGetActiveItem")
	self.is_show_active_red_point = self:FindVariable("IsShowActiveRedPoint")
	self.get_btn = self:FindVariable("lingqu")
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("OnClickActive", BindTool.Bind(self.OnClickActive, self))
	self:ListenEvent("OnClickLingQu", BindTool.Bind(self.OnClickLingQu, self))
	self:ListenEvent("OnClickHuanHua", BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickStopHuanHua", BindTool.Bind(self.OnClickStopHuanHua, self))
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
	self.get_red = self:FindVariable("getred")
	self.display = self:FindObj("Display")
	self.model = RoleModel.New("jinjie_reward_view_mount")
	self.model:SetDisplay(self.display.ui3d_display)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self.item_cell:SetData(nil)
	self.item_cell:SetDefualtBgState(false)
end

function JinJieRewardView:ReleaseCallBack()
	self.equip_name = nil
	self.equip_type = nil
	self.fight_power = nil
	self.is_can_free_get = nil
	self.is_free = nil
	self.free_time = nil
	self.need_gold = nil       
	self.title_icon = nil
	self.show_text_icon = nil
	self.show_text_level = nil
	self.effect_des = nil
	self.display = nil
	self.hp = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.is_active = nil
	self.is_huanhua = nil
	self.is_get_active_item = nil
	self.is_show_active_red_point = nil
	self.get_red = nil
	self.get_btn = nil
	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function JinJieRewardView:CloseCallBack()
	self:RemoveCountDown()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
end

function JinJieRewardView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self:GetRelatedCfg()
	self:FlushDes()
	self:Flush()
	self:FlushModle()
end

--设置打开面板类型
function JinJieRewardView:SetData(system_type)
	self.system_type = system_type
	JinJieRewardData.Instance:SetCurSystemType(system_type)
	if self.system_type then
		self:Open()
	end
end

--获取相关配置
function JinJieRewardView:GetRelatedCfg()
	self.system_cfg = JinJieRewardData.Instance:GetSingleRewardCfg(self.system_type)
	local img_id = self.system_cfg and self.system_cfg.param_0 
	if img_id then
		self.huan_hua_cfg = JinJieRewardData.Instance:GetSystemSpecialImageCfg(self.system_type, img_id)
	end
end

--设置不变的相关显示
function JinJieRewardView:FlushDes()
	if nil == self.huan_hua_cfg or nil == self.huan_hua_cfg.item_id then
		return
	end

	local huan_hua_item_id = self.huan_hua_cfg.item_id
	self.item_cell:SetData({item_id = huan_hua_item_id, is_bind = 0})
	self.item_cell:SetInteractable(false)

	local equip_type = Language.JinJieReward.SystemName[self.system_type] or ""
	self.equip_type:SetValue(equip_type)

	local cfg = JinJieRewardData.Instance:GetSingleAttrCfg(self.system_type)
	local per = cfg.add_per or 0
	local item_per = per/100
	local str = item_per .."%"
	local effect_des = string.format(Language.JinJieReward.EffectDes, equip_type, str)
	self.effect_des:SetValue(effect_des)

	local need_gold = self.system_cfg.cost or 0
	self.need_gold:SetValue(need_gold)

	local icon_bundle, icon_asset = ResPath.GetJinJieBg(self.system_type)
	if icon_bundle and icon_asset then
		self.show_text_icon:SetAsset(icon_bundle, icon_asset)
	end

	local reward_grade = self.system_cfg.grade 						--服务端的奖励阶数，客户端显示需减一
	if reward_grade then
		self.show_text_level:SetValue(reward_grade - 1)
	end

	local item_cfg = ItemData.Instance:GetItemConfig(huan_hua_item_id)
	if item_cfg == nil then
		return 
	end

	local item_color = item_cfg.color and item_cfg.color or 1
	local color = ITEM_TIP_NAME_COLOR[item_color] and ITEM_TIP_NAME_COLOR[item_color] or ITEM_TIP_NAME_COLOR[1]
	local name = item_cfg.name or ""
	local name_str = ToColorStr(name, color)
	self.equip_name:SetValue(name_str)

	local bundle, asset = ResPath.GetTipsImageByIndex(item_color)
	self.title_icon:SetAsset(bundle, asset)
end

--设置属性值和战力
function JinJieRewardView:SetAttrAndPower() 
	local hp = 0
	local gong_ji= 0
	local fang_yu = 0
	local img_id = self.system_cfg and self.system_cfg.param_0
	local huanhua_cfg = JinJieRewardData.Instance:GetSystemSpecialImageLevelCfg(self.system_type, img_id)
	if huanhua_cfg ~= nil then
		hp =  huanhua_cfg.maxhp or 0
		gong_ji = huanhua_cfg.gongji or 0
		fang_yu = huanhua_cfg.fangyu or 0
	end

	self.hp:SetValue(hp)
	self.gong_ji:SetValue(gong_ji)
	self.fang_yu:SetValue(fang_yu)

	local fight_power = JinJieRewardData.Instance:GetSystemSpecialImageFightPower(self.system_type, huanhua_cfg)
	self.fight_power:SetValue(fight_power)
end

--刷新按钮状态
function JinJieRewardView:FlushButtonState()
	local is_active = JinJieRewardData.Instance:GetSystemIsActiveSpecialImage(self.system_type)
	local is_get_active_item = JinJieRewardData.Instance:GetSystemIsGetActiveNeedItemFromInfo(self.system_type)
	local is_huanhua = JinJieRewardData.Instance:GetSystemIsUseCurSpecialImage(self.system_type)
	local is_can_free_get = JinJieRewardData.Instance:GetSystemIsCanFreeLingQuFromInfo(self.system_type)
	local is_end = JinJieRewardData.Instance:GetSystemFreeIsEnd(self.system_type)
	
	self.is_can_free_get:SetValue(is_can_free_get)
	self.is_free:SetValue(not is_end)
	self.is_active:SetValue(is_active)
	self.is_huanhua:SetValue(is_huanhua)

	local bag_have_active_item = JinJieRewardData.Instance:BagIsHaveActiveNeedItem(self.system_type)
	local is_get_active_need_item = is_active or is_get_active_item or bag_have_active_item
	self.is_get_active_item:SetValue(is_get_active_need_item)
	self.is_show_active_red_point:SetValue(bag_have_active_item)
	if is_can_free_get or not is_end then
	--活动未结束
		self.get_btn:SetValue(false)
		self.get_red:SetValue(is_can_free_get)
	else
		self.get_btn:SetValue(true)
	end
	if not is_can_free_get and is_end then
		self.is_can_free_get:SetValue(false)
	else
		self.is_can_free_get:SetValue(true)
	end

	self:RemoveCountDown()

	if is_end then
		self.free_time:SetValue("")
		self.is_free:SetValue(false)
		return
	end

	local end_time = JinJieRewardData.Instance:GetSystemFreeEndTime(self.system_type)
	self:FulshFreeTime(end_time)
end

function JinJieRewardView:OnFlush()
	self:FlushButtonState()
	self:SetAttrAndPower()
end

--免费时间刷新
function JinJieRewardView:FulshFreeTime(end_time)
	if end_time == 0 then
		self.free_time:SetValue("")
		self.is_free:SetValue(false)
		return
	end

	local now_time = TimeCtrl.Instance:GetServerTime()
	local rest_time = end_time - now_time
	self:SetTime(rest_time)
	if rest_time >= 0 and nil == self.least_time_timer then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
			rest_time = rest_time - 1
			self:SetTime(rest_time)
		end)
	else
		self:RemoveCountDown()
		self.free_time:SetValue("")
		self.is_free:SetValue(false)
	end	
end

--移除计时器
function JinJieRewardView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--设置时间
function JinJieRewardView:SetTime(time)
	if time > 0 then
		local show_time_str = ""
		if time > 3600 * 24 then
			show_time_str = TimeUtil.FormatSecond(time, 7)
		elseif time > 3600 then
			show_time_str = TimeUtil.FormatSecond(time, 1)
		else
			show_time_str = TimeUtil.FormatSecond(time, 4)
		end
		self.free_time:SetValue(show_time_str)
	else
		self:RemoveCountDown()
		self.free_time:SetValue("")
		self.is_free:SetValue(false)
		self:Flush()
	end
end

--购买(不能免费领取)
function JinJieRewardView:OnClickBuy()
	if nil == self.system_cfg or nil == self.system_cfg.cost or nil == self.huan_hua_cfg or nil == self.huan_hua_cfg.item_id then
		return
	end

	local need_gold = self.system_cfg.cost
	local is_enough = JinJieRewardData.Instance:GoldIsEnough(need_gold)
	if not is_enough then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	local item_id = self.huan_hua_cfg.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg == nil then
		return 
	end

	local function ok_callback()
		JinJieRewardCtrl.Instance:SendJinJieRewardOpera(JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_BUY, self.system_type, JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET)
	end

	local item_color = item_cfg.color and item_cfg.color or 1
	local color = ITEM_COLOR[item_color] and ITEM_COLOR[item_color] or TEXT_COLOR.GREEN_SPECIAL_1
	local name = item_cfg.name or ""
	local name_str = ToColorStr(name, color)
	local need_gpld_str = ToColorStr(need_gold, TEXT_COLOR.BLUE1)
	local des = string.format(Language.JinJieReward.BuyTip, need_gpld_str, name_str)
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

--领取(达到条件可免费领取)
function JinJieRewardView:OnClickLingQu()
	local is_can_free_get = JinJieRewardData.Instance:GetSystemIsCanFreeLingQuFromInfo(self.system_type)
	if not is_can_free_get then
		TipsSystemManager.Instance:ShowSystemTips("未到达等级", 1)
		return
	end
	JinJieRewardCtrl.Instance:SendJinJieRewardOpera(JINJIESYS_REWARD_OPEAR_TYPE.JINJIESYS_REWARD_OPEAR_TYPE_FETCH, self.system_type, JIN_JIE_REWARD_TARGET_TYPE.BIG_TARGET)
end

--激活(得到激活道具后激活)
function JinJieRewardView:OnClickActive()
	local bag_is_have_active_item, index, sub_type = JinJieRewardData.Instance:BagIsHaveActiveNeedItem(self.system_type)
	if bag_is_have_active_item and index ~= -1 and sub_type ~= -1 then
		PackageCtrl.Instance:SendUseItem(index, 1, sub_type, 0)
		return
	end

	--通过活动得到了道具 但是可能由于XX原因丢弃了
	if not bag_is_have_active_item then
		if nil == self.huan_hua_cfg or nil == self.huan_hua_cfg.item_id then
			return
		end

		local item_id = self.huan_hua_cfg.item_id
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg == nil then
			return 
		end

		local name = item_cfg.name or ""
		local color = item_cfg.color and ITEM_COLOR[item_cfg.color] or TEXT_COLOR.GREEN_SPECIAL_1
		local name_str = ToColorStr(name, color)
		local str = string.format(Language.JinJieReward.BagNotHaveActiveItem, name_str)
		SysMsgCtrl.Instance:ErrorRemind(str)
	end
end

--幻化(当前形象已激活)
function JinJieRewardView:OnClickHuanHua()
	if nil == self.system_cfg or nil == self.system_cfg.param_0 then
		return
	end
	local use_img_id = self.system_cfg.param_0 + GameEnum.MOUNT_SPECIAL_IMA_ID
	JinJieRewardCtrl.Instance:SendHuanHuaUseOrCancle(self.system_type, use_img_id)
end

--取消幻化(当前形象已激活)
function JinJieRewardView:OnClickStopHuanHua()
	local item_id = JinJieRewardData.Instance:GetSystemCurJinJieGradeImageId(self.system_type)
	if item_id ~= 0 then
		JinJieRewardCtrl.Instance:SendHuanHuaUseOrCancle(self.system_type, item_id)
	end
end

function JinJieRewardView:OnClickClose()
	self:Close()
end

--模型
function JinJieRewardView:FlushModle()
	if nil == self.huan_hua_cfg  or nil == self.huan_hua_cfg.res_id or nil == self.model then
		return
	end

	self.model:ClearModel()
	self.model:ResetRotation()
	if system_type ~= JINJIE_TYPE.JINJIE_TYPE_MOUNT and system_type ~= JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then
		self.model:SetInteger(ANIMATOR_PARAM.STATUS, 0)
	end

	local res_id = self.huan_hua_cfg.res_id
	local main_role = Scene.Instance:GetMainRole()
	local role_res_id = main_role:GetRoleResId()

	if self.system_type == JINJIE_TYPE.JINJIE_TYPE_MOUNT then 						-- 坐骑
		local bundle, asset = ResPath.GetMountModel(res_id)
		self.model:SetPanelName("jinjie_reward_view_mount")
		self.model:SetMainAsset(bundle, asset)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_WING then 					-- 羽翼
		self.model:SetPanelName("jinjie_reward_view_wing")
		self.model:SetRoleResid(role_res_id)
		self.model:SetWingResid(res_id)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_SHENGONG then				-- 伙伴光环
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.weapon_res_id = res_id
		self.model:SetPanelName("jinjie_reward_view_shengong")
		self.model:SetGoddessModelResInfo(info)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_SHENYI then					-- 伙伴法阵
		local info = {}
		info.role_res_id = GoddessData.Instance:GetShowXiannvResId()
		info.wing_res_id = res_id
		self.model:SetPanelName("jinjie_reward_view_shenyi")
		self.model:SetGoddessModelResInfo(info)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_HALO then					-- 角色光环
		self.model:SetPanelName("jinjie_reward_view_halo")
		self.model:SetRoleResid(role_res_id)
		self.model:SetHaloResid(res_id)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_FOOTPRINT then				-- 足迹
		self.model:SetPanelName("jinjie_reward_view_foot")
		self.model:SetRoleResid(role_res_id)
		self.model:SetFootResid(res_id)
		self.model:SetInteger(ANIMATOR_PARAM.STATUS, 1)
	elseif self.system_type == JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then				-- 战骑
		local bundle, asset = ResPath.GetFightMountModel(res_id)
		self.model:SetPanelName("jinjie_reward_view_fight_mount")
		self.model:SetMainAsset(bundle, asset)
	end

	if self.model and self.system_type ~= JINJIE_TYPE.JINJIE_TYPE_FIGHT_MOUNT then
		self.model:SetTrigger(ANIMATOR_PARAM.REST)
	end
end

--物品变化回调
function JinJieRewardView:ItemDataChangeCallback()
	self:Flush()
end