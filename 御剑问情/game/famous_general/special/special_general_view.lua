SpecialGeneralView = SpecialGeneralView or BaseClass(BaseView)

function SpecialGeneralView:__init()
	self.ui_config = {"uis/views/famous_general_prefab", "SpecialGeneralView"}
end

function SpecialGeneralView:LoadCallBack()
	self.equip_name = self:FindVariable("EquipName")
	self.equip_type = self:FindVariable("EquipType")
	self.fight_power = self:FindVariable("FightPower")
	self.is_can_free_get = self:FindVariable("IsCanFreeGet")
	self.is_free = self:FindVariable("IsFree")
	self.free_time = self:FindVariable("FreeTime")
	self.need_gold = self:FindVariable("NeedGold")       
	self.title_icon = self:FindVariable("TitleIcon")
	self.effect_des = self:FindVariable("EffectDes")
	self.hp = self:FindVariable("Hp")
	self.gong_ji = self:FindVariable("GongJi")
	self.fang_yu = self:FindVariable("FangYu")
	self.is_active = self:FindVariable("IsActive")
	self.is_huanhua = self:FindVariable("IsHuanHua")
	self.is_get_active_item = self:FindVariable("IsGetActiveItem")
	self.is_show_active_red_point = self:FindVariable("IsShowActiveRedPoint")
	self.is_can_up_grade = self:FindVariable("IsCanUpGrade")
	self.level = self:FindVariable("Level")
	self.name = self:FindVariable("Name")

	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickBuy", BindTool.Bind(self.OnClickBuy, self))
	self:ListenEvent("OnClickActive", BindTool.Bind(self.OnClickActive, self))
	self:ListenEvent("OnClickLingQu", BindTool.Bind(self.OnClickLingQu, self))
	self:ListenEvent("OnClickHuanHua", BindTool.Bind(self.OnClickHuanHua, self))
	self:ListenEvent("OnClickStopHuanHua", BindTool.Bind(self.OnClickStopHuanHua, self))
	self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)

	self.display = self:FindObj("Display")
	self.model = RoleModel.New("famous_general_special_tip_panel")
	self.model:SetDisplay(self.display.ui3d_display)

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("Item"))
	self.item_cell:SetData(nil)
	self.item_cell:SetDefualtBgState(false)
	self.item_cell:ShowHighLight(false)
end

function SpecialGeneralView:ReleaseCallBack()
	self.equip_name = nil
	self.equip_type = nil
	self.fight_power = nil
	self.is_can_free_get = nil
	self.is_free = nil
	self.free_time = nil
	self.need_gold = nil       
	self.title_icon = nil
	self.effect_des = nil
	self.display = nil
	self.hp = nil
	self.gong_ji = nil
	self.fang_yu = nil
	self.is_active = nil
	self.is_huanhua = nil
	self.is_get_active_item = nil
	self.is_show_active_red_point = nil
	self.is_can_up_grade = nil
	self.level = nil
	self.name = nil

	if self.model ~= nil then
		self.model:DeleteMe()
		self.model = nil
	end

	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SpecialGeneralView:CloseCallBack()
	self:RemoveCountDown()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
end

function SpecialGeneralView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)

	self:GetRelatedCfg()
	self:FlushDes()
	self:Flush()
	self:FlushModle()
end

--设置打开面板类型
function SpecialGeneralView:SetData(data)
	if nil == data then
		return
	end

	self.speical_img_id = data
	self:Open()
end

--获取相关配置
function SpecialGeneralView:GetRelatedCfg()
	self.speical_img_cfg = SpecialGeneralData.Instance:GetSpecialImageCfgInfoByImageId(self.speical_img_id)
end

--设置不变的相关显示
function SpecialGeneralView:FlushDes()
	if nil == self.speical_img_cfg or nil == self.speical_img_cfg.item_id then
		return
	end

	local speical_item_id = self.speical_img_cfg.item_id
	self.item_cell:SetData({item_id = speical_item_id, is_bind = 0})
	self.item_cell:ListenClick(BindTool.Bind(self.OnClickActive, self, true))

	local per = self.speical_img_cfg.add_other_soldier_attr_per or 0
	local item_per = per * 0.01
	local str = item_per .."%"
	local effect_des = string.format(Language.General.EffectDes, str)
	self.effect_des:SetValue(effect_des)

	local need_gold = self.speical_img_cfg.gold_price or 0
	self.need_gold:SetValue(need_gold)

	local item_cfg = ItemData.Instance:GetItemConfig(speical_item_id)
	if item_cfg == nil then
		return 
	end

	local item_type = item_cfg.is_display_role
	local equip_type = Language.Common.PROP_TYPE[item_type] or ""
	self.equip_type:SetValue(equip_type)

	local item_color = item_cfg.color and item_cfg.color or 1
	local color = ITEM_TIP_NAME_COLOR[item_color] and ITEM_TIP_NAME_COLOR[item_color] or ITEM_TIP_NAME_COLOR[1]
	local name = item_cfg.name or ""
	local equip_name_str = ToColorStr(name, color)
	self.equip_name:SetValue(equip_name_str)

	local name_color = SOUL_NAME_COLOR[item_color] or SOUL_NAME_COLOR[1]
	local name_str = ToColorStr(name, name_color)
	self.name:SetValue(name_str)

	local bundle, asset = ResPath.GetTipsImageByIndex(item_color)
	self.title_icon:SetAsset(bundle, asset)
end

--设置属性值和战力
function SpecialGeneralView:SetAttrAndPower()
	local hp = 0
	local gong_ji= 0
	local fang_yu = 0

	local cfg = SpecialGeneralData.Instance:GetHuanHuaCfgInfo(self.speical_img_id)
	if cfg ~= nil then
		hp =  cfg.maxhp or 0
		gong_ji = cfg.gongji or 0
		fang_yu = cfg.fangyu or 0
	end

	self.hp:SetValue(hp)
	self.gong_ji:SetValue(gong_ji)
	self.fang_yu:SetValue(fang_yu)

	local fight_power = SpecialGeneralData.Instance:GetSpecialImagesPower(self.speical_img_id, cfg)
	self.fight_power:SetValue(fight_power)

	local level = SpecialGeneralData.Instance:GetHuanHuaGrade(self.speical_img_id)
	level = level <= 0 and 1 or level
	self.level:SetValue(level)
end

--刷新按钮状态
function SpecialGeneralView:FlushButtonState()
	local is_active = SpecialGeneralData.Instance:SpecialImageIsActive(self.speical_img_id)
	local is_get_active_item = SpecialGeneralData.Instance:SpecialImageIsHasLingqu(self.speical_img_id)
	local is_huanhua = SpecialGeneralData.Instance:GetIsUseCurSpecialImage(self.speical_img_id)
	local is_can_free_get = SpecialGeneralData.Instance:SpecialImageIsCanFreeLingQu(self.speical_img_id)
	local is_end = SpecialGeneralData.Instance:GetFreeActiveIsEnd(self.speical_img_id)
	
	self.is_can_free_get:SetValue(is_can_free_get)
	self.is_free:SetValue(not is_end)
	self.is_active:SetValue(is_active)
	self.is_huanhua:SetValue(is_huanhua)

	local bag_have_active_item = SpecialGeneralData.Instance:BagIsHaveActiveNeedItem(self.speical_img_id)
	local is_get_active_need_item = is_active or is_get_active_item or bag_have_active_item
	self.is_get_active_item:SetValue(is_get_active_need_item)
	self.is_show_active_red_point:SetValue(bag_have_active_item)
	self.is_can_up_grade:SetValue(bag_have_active_item)

	self:RemoveCountDown()

	if is_end then
		self.free_time:SetValue("")
		self.is_free:SetValue(false)
		return
	end

	local end_time = SpecialGeneralData.Instance:GetActiveFreeEndTimestamp(self.speical_img_id)
	self:FulshFreeTime(end_time)
end

function SpecialGeneralView:OnFlush()
	self:FlushButtonState()
	self:SetAttrAndPower()
end

--免费时间刷新
function SpecialGeneralView:FulshFreeTime(end_time)
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
function SpecialGeneralView:RemoveCountDown()
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end
end

--设置时间
function SpecialGeneralView:SetTime(time)
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
function SpecialGeneralView:OnClickBuy()
	if nil == self.speical_img_cfg or nil == self.speical_img_cfg.gold_price or nil == self.speical_img_cfg.item_id then
		return
	end

	local need_gold = self.speical_img_cfg.gold_price
	local is_enough = SpecialGeneralData.Instance:GoldIsEnough(need_gold)
	if not is_enough then
		TipsCtrl.Instance:ShowLackDiamondView()
		return
	end

	local item_id = self.speical_img_cfg.item_id
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg == nil then
		return 
	end

	local function ok_callback()
		local req_type = GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_BUY_SPECIAL_SOLDIER
		FamousGeneralCtrl.Instance:SendRequest(req_type, self.speical_img_id)
	end

	local item_color = item_cfg.color and item_cfg.color or 1
	local color = ITEM_COLOR[item_color] and ITEM_COLOR[item_color] or TEXT_COLOR.GREEN_SPECIAL_1
	local name = item_cfg.name or ""
	local name_str = ToColorStr(name, color)
	local need_gpld_str = ToColorStr(need_gold, TEXT_COLOR.BLUE1)
	local des = string.format(Language.General.BuyTip, need_gpld_str, name_str)
	TipsCtrl.Instance:ShowCommonAutoView("", des, ok_callback)
end

--领取(达到条件可免费领取)
function SpecialGeneralView:OnClickLingQu()
	local req_type = GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_FETCH_SPCEIAL_IMG_REWARD
	FamousGeneralCtrl.Instance:SendRequest(req_type, self.speical_img_id)
end

--激活(得到激活道具后激活)/   升级传参数true
function SpecialGeneralView:OnClickActive(flag)
	local bag_is_have_active_item, index, sub_type = SpecialGeneralData.Instance:BagIsHaveActiveNeedItem(self.speical_img_id)
	if bag_is_have_active_item and index ~= -1 and sub_type ~= -1 then
		PackageCtrl.Instance:SendUseItem(index, 1, sub_type, 0)
		return
	end

	--通过活动得到了道具 但是可能由于XX原因丢弃了
	if not bag_is_have_active_item then
		if flag then
			return
		end

		if nil == self.speical_img_cfg or nil == self.speical_img_cfg.item_id then
			return
		end

		local item_id = self.speical_img_cfg.item_id
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if item_cfg == nil then
			return 
		end

		local name = item_cfg.name or ""
		local color = item_cfg.color and ITEM_COLOR[item_cfg.color] or TEXT_COLOR.GREEN_SPECIAL_1
		local name_str = ToColorStr(name, color)
		local str = string.format(Language.Common.ActivedErrorTips, name_str)
		SysMsgCtrl.Instance:ErrorRemind(str)
	end
end

--幻化(当前形象已激活)
function SpecialGeneralView:OnClickHuanHua()
	local req_type = GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_USE_SPECIAL_IMG
	FamousGeneralCtrl.Instance:SendRequest(req_type, self.speical_img_id)
end

--取消幻化(当前形象已激活)
function SpecialGeneralView:OnClickStopHuanHua()
	local req_type = GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_USE_SPECIAL_IMG
	FamousGeneralCtrl.Instance:SendRequest(req_type, 0)
end

function SpecialGeneralView:OnClickClose()
	self:Close()
end

--模型
function SpecialGeneralView:FlushModle()
	if nil == self.speical_img_cfg  or nil == self.speical_img_cfg.res_id or nil == self.model then
		return
	end

	local bundle, asset = ResPath.GetGeneralRes(self.speical_img_cfg.res_id)
	self.model:SetMainAsset(bundle, asset)
	self.model:SetTrigger("attack3")
end

--物品变化回调
function SpecialGeneralView:ItemDataChangeCallback()
	self:Flush()
	RemindManager.Instance:Fire(RemindName.General_Info)
end