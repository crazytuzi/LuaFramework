TipSkillUpgradeView = TipSkillUpgradeView or BaseClass(BaseView)

local FROM_MOUNT = 1		-- 从坐骑界面打开
local FROM_WING = 2			-- 从羽翼界面打开
local FROM_HALO = 3			-- 从光环界面打开
local FROM_SHENGONG = 4		-- 从神弓界面打开
local FROM_SHENYI = 5		-- 从神翼界面打开
local FROM_BEAUTYHALO = 6	-- 从美人光环界面打开
local FROM_HALIDOM = 7		-- 从圣物界面打开
local FROM_FIGHT = 8		-- 从战斗坐骑界面打开
local FROM_HEADWEAR = 9 	-- 从头饰
local FROM_MASK = 10 		-- 从面饰
local FROM_WAIST = 11		-- 从腰饰
local FROM_BEAD = 12		-- 从灵珠
local FROM_FABAO = 13		-- 从法宝
local FROM_KIRIN_ARM = 14 	-- 从麒麟臂
local NAME_LIST = {"坐骑", "羽翼", "天罡", "足迹", "披风", "美人光环", "圣物", "法印","头饰","面饰","腰饰","灵珠","法宝","麒麟臂"}
local EFFECT_CD = 0.8

function TipSkillUpgradeView:__init()
	self.ui_config = {"uis/views/tips/advancetips","SkillUpgradeTip"}
	self:SetMaskBg(true)
	self.play_audio = true
	self.info = nil
	self.cur_index = nil
	self.cur_data = {}
	self.next_data_cfg = {}
	self.client_grade_cfg = nil
	self.temp_level = nil
	self.next_level = nil
	self.item_id = 0
	self.effect_cd = 0
	self.skill_id = 0
end

-- 创建完调用
function TipSkillUpgradeView:LoadCallBack()
	self:ListenEvent("OnClickCloseButton", BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("OnClickUpgradeButton", BindTool.Bind(self.OnClickUpgradeButton, self))

	self.level = self:FindVariable("Level")
	self.current_effect = self:FindVariable("CurrentEffect")
	self.next_effect = self:FindVariable("NextEffect")
	self.grade = self:FindVariable("Rank")
	self.is_Active_text = self:FindVariable("IsActive")
	self.skill_icon = self:FindVariable("SkillIcon")
	self.skill_name = self:FindVariable("SkillName")
	self.need_pro_name = self:FindVariable("NeedProName")
	self.need_pro_num = self:FindVariable("NeedProNum")
	self.have_pro_num = self:FindVariable("HaveProNum")
	self.show_cur_effect = self:FindVariable("IsShowCurEffect")
	self.show_max_level_tip = self:FindVariable("ShowMaxLevelTip")
	self.show_normal_text = self:FindVariable("ShowNormalText")
	self.advance_type = self:FindVariable("AdvanceType")
	self.show_up_level_tip = self:FindVariable("ShowUpLevelTip")
	self.can_up_level_grade = self:FindVariable("Grade")
	-- self.show_effect = self:FindVariable("ShowEffect")

	self.special_skill_up_view = self:FindObj("SpecialSkillUpInfo")
	self.normal_skill_up_view = self:FindObj("NormalSkillUpInfo")
	self.gray_up_level_btn = self:FindObj("UpLevelButton")
	self.special_skill_up_view:SetActive(false)
	self.normal_skill_up_view:SetActive(true)

	self.normal_label = self:FindObj("NormalLabel")

	self.skill_flush_event = GlobalEventSystem:Bind(SkillEventType.SKILL_FLUSH,	BindTool.Bind(self.DataCallBack, self))
	self.item_change_notify = BindTool.Bind(self.DataCallBack, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_notify)
end

function TipSkillUpgradeView:ReleaseCallBack()
	self.info = nil
	self.cur_index = nil
	self.cur_data = nil
	self.next_data_cfg = nil
	self.next_level = nil
	self.item_id = nil
	self.level = nil
	self.current_effect = nil
	self.next_effect = nil
	self.grade = nil
	self.is_Active_text = nil
	self.skill_icon = nil
	self.skill_name = nil
	self.need_pro_name = nil
	self.need_pro_num = nil
	self.have_pro_num = nil
	self.show_cur_effect = nil
	self.show_max_level_tip = nil
	self.show_normal_text = nil
	self.advance_type = nil
	self.show_up_level_tip = nil
	self.can_up_level_grade = nil
	self.show_effect = nil
	self.normal_label = nil

	self.special_skill_up_view = nil
	self.normal_skill_up_view = nil
	self.gray_up_level_btn = nil
	if self.skill_flush_event then
		GlobalEventSystem:UnBind(self.skill_flush_event)
		self.skill_flush_event = nil
	end

	if self.item_change_notify then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_notify)
		self.item_change_notify = nil
	end
end

function TipSkillUpgradeView:OpenCallBack()
	self.temp_level = nil
	self.info = nil
	self.cur_index = nil
	self.cur_data = nil
	self.next_data_cfg = nil
	self.next_level = nil
	self.item_id = nil
end

function TipSkillUpgradeView:OnClickCloseButton()
	self:Close()
end

function TipSkillUpgradeView:CloseCallBack()
	self.temp_level = nil
end

function TipSkillUpgradeView:OnClickUpgradeButton()
	if (self.info.grade == 0) or nil then
		return
	end
	if nil == next(self.next_data_cfg) then
		return
	end

	if self.info.grade < self.next_data_cfg.grade then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.Advance.NotEnoughGrade, NAME_LIST[self.from_view]))
		return
	end

	if ItemData.Instance:GetItemNumInBagById(self.item_id) <= 0 or
		ItemData.Instance:GetItemNumInBagById(self.item_id) < self.next_data_cfg.uplevel_stuff_num then

		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[self.item_id]
		if item_cfg == nil then
			-- TipsCtrl.Instance:ShowSystemMsg(Language.Exchange.NotEnoughItem)
			TipsCtrl.Instance:ShowItemGetWayView(self.item_id)
			self:Close()
			return
		end
		-- if item_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowShopView(self.item_id, 2)
		-- 	return
		-- end

		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id)
		return
	end
	SkillCtrl.Instance:SendRoleSkillLearnReq(self.skill_id)
	-- if self.from_view == FROM_MOUNT then
	-- 	MountCtrl.Instance:MountSkillUplevelReq(self.cur_index)
	-- elseif self.from_view == FROM_WING then
	-- 	WingCtrl.Instance:WingSkillUplevelReq(self.cur_index)
	-- elseif self.from_view == FROM_HALO then
	-- 	HaloCtrl.Instance:HaloSkillUplevelReq(self.cur_index)
	-- elseif self.from_view == FROM_SHENGONG then
	-- 	ShengongCtrl.Instance:ShengongSkillUplevelReq(self.cur_index)
	-- else
	-- 	ShenyiCtrl.Instance:ShenyiSkillUplevelReq(self.cur_index)
	-- end
end

function TipSkillUpgradeView:SetData()
	local bundle, asset = nil, nil
	local cur_level = 0
	local next_level = 1
	local cur_desc = nil
	local next_desc = nil
	local is_active = false

	if self.from_view == FROM_MOUNT then							-- 坐骑技能
		self.cur_data = MountData.Instance:GetMountSkillCfgById(self.cur_index) or {}
		self.info = MountData.Instance:GetMountInfo()
		bundle, asset = ResPath.GetMountSkillIcon(self.cur_index + 1)
		self.skill_cfg = MountData.Instance:GetMountSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = MountData.Instance:GetMountSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = MountData.Instance:GetMountShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_WING then							 -- 羽翼技能
		self.cur_data = WingData.Instance:GetWingSkillCfgById(self.cur_index) or {}
		self.info = WingData.Instance:GetWingInfo()
		bundle, asset = ResPath.GetWingSkillIcon(self.cur_index + 1)
		self.skill_cfg = WingData.Instance:GetWingSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = WingData.Instance:GetWingSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = WingData.Instance:GetWingShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_HALO then							-- 光环技能
		self.cur_data = HaloData.Instance:GetHaloSkillCfgById(self.cur_index) or {}
		self.info = HaloData.Instance:GetHaloInfo()
		bundle, asset = ResPath.GetHaloSkillIcon(self.cur_index + 1)
		self.skill_cfg = HaloData.Instance:GetHaloSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = HaloData.Instance:GetHaloSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = HaloData.Instance:GetHaloShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_SHENGONG then						-- 神弓技能
		self.cur_data = ShengongData.Instance:GetShengongSkillCfgById(self.cur_index) or {}
		self.info = ShengongData.Instance:GetShengongInfo()
		bundle, asset = ResPath.GetShengongSkillIcon(self.cur_index + 1)
		self.skill_cfg = ShengongData.Instance:GetShengongSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = ShengongData.Instance:GetShengongSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = ShengongData.Instance:GetShengongShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_SHENYI then						-- 神翼技能
		self.cur_data = ShenyiData.Instance:GetShenyiSkillCfgById(self.cur_index) or {}
		self.info = ShenyiData.Instance:GetShenyiInfo()
		bundle, asset = ResPath.GetShenyiSkillIcon(self.cur_index + 1)
		self.skill_cfg = ShenyiData.Instance:GetShenyiSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = ShenyiData.Instance:GetShenyiSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = ShenyiData.Instance:GetShenyiShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_BEAUTYHALO then						-- 美人光环
		self.cur_data = BeautyHaloData.Instance:GetSkillCfgById(self.cur_index) or {}
		self.info = BeautyHaloData.Instance:GetBeautyHaloInfo()
		bundle, asset = ResPath.GetBeautyHaloSkillIcon(self.cur_index + 1)
		self.skill_cfg = BeautyHaloData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = BeautyHaloData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = BeautyHaloData.Instance:GetShowBeautyHaloGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_HALIDOM then						-- 圣物技能
		self.cur_data = HalidomData.Instance:GetSkillCfgById(self.cur_index) or {}
		self.info = HalidomData.Instance:GetHalidomInfo()
		bundle, asset = ResPath.GetBaoJuSkillIcon(self.cur_index + 1)
		self.skill_cfg = HalidomData.Instance:GetSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = HalidomData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = HalidomData.Instance:GetShowHalidomGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_FIGHT then						-- 战斗坐骑技能
		self.cur_data = FaZhenData.Instance:GetSkillCfgById(self.cur_index) or {}
		self.info = FaZhenData.Instance:GetFightMountInfo()
		bundle, asset = ResPath.GetFightMountSkillIcon(self.cur_index + 1)
		self.skill_cfg = FaZhenData.Instance:GetFaZhenSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FaZhenData.Instance:GetSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = FaZhenData.Instance:GetMountShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_HEADWEAR then							 -- 头饰技能
		self.cur_data = HeadwearData.Instance:GetHeadwearSkillCfgById(self.cur_index) or {}
		self.info = HeadwearData.Instance:GetHeadwearInfo()
		bundle, asset = ResPath.GetHeadwearSkillIcon(self.cur_index + 1)
		self.skill_cfg = HeadwearData.Instance:GetHeadwearSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = HeadwearData.Instance:GetHeadwearSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = HeadwearData.Instance:GetHeadwearShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_MASK then							 -- 面饰技能
		self.cur_data = MaskData.Instance:GetMaskSkillCfgById(self.cur_index) or {}
		self.info = MaskData.Instance:GetMaskInfo()
		bundle, asset = ResPath.GetMaskSkillIcon(self.cur_index + 1)
		self.skill_cfg = MaskData.Instance:GetMaskSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = MaskData.Instance:GetMaskSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = MaskData.Instance:GetMaskShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_WAIST then							 -- 腰饰技能
		self.cur_data = WaistData.Instance:GetWaistSkillCfgById(self.cur_index) or {}
		self.info = WaistData.Instance:GetWaistInfo()
		bundle, asset = ResPath.GetWaistSkillIcon(self.cur_index + 1)
		self.skill_cfg = WaistData.Instance:GetWaistSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = WaistData.Instance:GetWaistSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = WaistData.Instance:GetWaistShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_BEAD then							 -- 灵珠技能
		self.cur_data = BeadData.Instance:GetBeadSkillCfgById(self.cur_index) or {}
		self.info = BeadData.Instance:GetBeadInfo()
		bundle, asset = ResPath.GetBeadSkillIcon(self.cur_index + 1)
		self.skill_cfg = BeadData.Instance:GetBeadSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = BeadData.Instance:GetBeadSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = BeadData.Instance:GetBeadShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_FABAO then							 -- 法宝技能
		self.cur_data = FaBaoData.Instance:GetFaBaoSkillCfgById(self.cur_index) or {}
		self.info = FaBaoData.Instance:GetFaBaoInfo()
		bundle, asset = ResPath.GetFaBaoSkillIcon(self.cur_index + 1)
		self.skill_cfg = FaBaoData.Instance:GetFaBaoSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FaBaoData.Instance:GetFaBaoSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = FaBaoData.Instance:GetFaBaoShowGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_KIRIN_ARM then							 -- 麒麟臂技能
		self.cur_data = KirinArmData.Instance:GetKirinArmSkillCfgById(self.cur_index) or {}
		self.info = KirinArmData.Instance:GetKirinArmInfo()
		bundle, asset = ResPath.GetKirinArmSkillIcon(self.cur_index + 1)
		self.skill_cfg = KirinArmData.Instance:GetKirinArmSkillCfg()
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = KirinArmData.Instance:GetKirinArmSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = KirinArmData.Instance:GetKirinArmShowGradeCfg(self.next_data_cfg.grade)
		end

	end
	is_active = nil ~= next(self.cur_data)
	self.item_id = self.cur_data.uplevel_stuff_id or self.next_data_cfg.uplevel_stuff_id
	local count = ItemData.Instance:GetItemNumInBagById(self.item_id)
	self.gray_up_level_btn.button.interactable = self.info.grade ~= 0 and nil ~= next(self.next_data_cfg)
	-- self.normal_skill_up_view:SetActive(self.cur_index ~= 0)
	-- self.special_skill_up_view:SetActive(self.cur_index == 0)
	self.skill_icon:SetAsset(bundle, asset)
	self.skill_name:SetValue(self.cur_data.skill_name or self.next_data_cfg.skill_name or "")
	self.show_cur_effect:SetValue(is_active)

	if self.normal_label ~= nil then
		local width = self.normal_label.rect.rect.width
		local height = is_active and 85 or 125
		self.normal_label.rect.sizeDelta = Vector2(width, height)
	end
	self.show_up_level_tip:SetValue(not is_active)
	self.is_Active_text:SetValue(not is_active and Language.Mount.NotActive or "")
	self.level:SetValue(cur_level)

	if self.temp_level == cur_level then
		return
	end

	if self.temp_level and self.temp_level < cur_level then
		if Status.NowTime - self.effect_cd > EFFECT_CD then
			-- self.show_effect:SetValue(false)
			-- self.show_effect:SetValue(true)
			self.effect_cd = Status.NowTime
		end
	end
	self.temp_level = cur_level

	local item_cfg = ItemData.Instance:GetItemConfig(self.item_id)
	if item_cfg ~= nil then
		self.need_pro_name:SetValue(item_cfg.name)
	end

	if is_active then
		cur_desc = string.gsub(self.cur_data.desc, "%b()%%", function (str)
			return (tonumber(self.cur_data[string.sub(str, 2, -3)]) / 1000)
		end)
		cur_desc = string.gsub(cur_desc, "%b[]%%", function (str)
			return (tonumber(self.cur_data[string.sub(str, 2, -3)]) / 100) .. "%"
		end)
		cur_desc = string.gsub(cur_desc, "%[.-%]", function (str)
			return self.cur_data[string.sub(str, 2, -2)]
		end)
		self.current_effect:SetValue(cur_desc)
	end

	if next(self.next_data_cfg) then
		self.grade:SetValue(Language.Common.NumToChs[self.next_data_cfg.grade])
		if count < self.next_data_cfg.uplevel_stuff_num then
			self.have_pro_num:SetValue(string.format(Language.Mount.ShowRedNum, count))
		else
			self.have_pro_num:SetValue(string.format(Language.Mount.ShowGreenStr, count))
		end
		self.need_pro_num:SetValue(self.next_data_cfg.uplevel_stuff_num)
		next_desc = string.gsub(self.next_data_cfg.desc, "%b()%%", function (str)
			return  (tonumber(self.next_data_cfg[string.sub(str, 2, -3)]) / 1000)..""
		end)
		next_desc = string.gsub(next_desc, "%b[]%%", function (str)
			return (tonumber(self.next_data_cfg[string.sub(str, 2, -3)]) / 100) .. "%"
		end)
		next_desc = string.gsub(next_desc, "%[.-%]", function (str)
			return self.next_data_cfg[string.sub(str, 2, -2)]
		end)
		self.next_effect:SetValue(next_desc)
		self.show_max_level_tip:SetValue(false)
		self.show_normal_text:SetValue(true)
		self.advance_type:SetValue(NAME_LIST[self.from_view])
		if self.client_grade_cfg then
			local str = string.format(Language.Mount.ShowRedStr, self.client_grade_cfg.gradename)
			if math.ceil(self.info.grade / 10 ) >= self.next_data_cfg.grade then
				str = string.format(Language.Mount.ShowGreenStr, self.client_grade_cfg.gradename)
			end
			self.can_up_level_grade:SetValue(str)
		end
	else
		self.have_pro_num:SetValue(string.format(Language.Mount.ShowRedNum, count))
		self.grade:SetValue("")
		self.next_effect:SetValue(Language.Common.MaxLvTips)
		self.show_max_level_tip:SetValue(true)
		self.show_normal_text:SetValue(false)
		self.need_pro_num:SetValue(0)
	end
end

function TipSkillUpgradeView:OnFlush(param_list)
	local skill_id_cfg = {}
	for k, v in pairs(param_list) do
		if k == "mountskill" then
			self.cur_index = v.index
			self.from_view = FROM_MOUNT
			skill_id_cfg = MountData.Instance:GetMountSkillId()[self.cur_index + 1] or {}
		elseif k == "wingskill" then
			self.cur_index = v.index
			self.from_view = FROM_WING
			skill_id_cfg = WingData.Instance:GetWingSkillId()[self.cur_index + 1] or {}
		elseif k == "haloskill" then
			self.cur_index = v.index
			self.from_view = FROM_HALO
			skill_id_cfg = HaloData.Instance:GetHaloSkillId()[self.cur_index + 1] or {}
		elseif k == "shengongskill" then
			self.cur_index = v.index
			self.from_view = FROM_SHENGONG
			skill_id_cfg = ShengongData.Instance:GetShengongSkillId()[self.cur_index + 1] or {}
		elseif k == "shenyiskill" then
			self.cur_index = v.index
			self.from_view = FROM_SHENYI
			skill_id_cfg = ShenyiData.Instance:GetShenyiSkillId()[self.cur_index + 1] or {}
		elseif k == "beautyhaloskill" then
			self.cur_index = v.index
			self.from_view = FROM_BEAUTYHALO
			skill_id_cfg = BeautyHaloData.Instance:GetBeautyHaloSkillId()[self.cur_index + 1] or {}
		elseif k == "halidomskill" then
			self.cur_index = v.index
			self.from_view = FROM_HALIDOM
			skill_id_cfg = HalidomData.Instance:GetHalidomSkillId()[self.cur_index + 1] or {}
		elseif k == "fightmountskill" then
			self.cur_index = v.index
			self.from_view = FROM_FIGHT
			skill_id_cfg = FaZhenData.Instance:GetMountSkillId()[self.cur_index + 1] or {}
		elseif k == "headwearskill" then
			self.cur_index = v.index
			self.from_view = FROM_HEADWEAR
			skill_id_cfg = HeadwearData.Instance:GetHeadwearSkillId()[self.cur_index + 1] or {}
		elseif k == "maskskill" then
			self.cur_index = v.index
			self.from_view = FROM_MASK
			skill_id_cfg = MaskData.Instance:GetMaskSkillId()[self.cur_index + 1] or {}
		elseif k == "waistskill" then
			self.cur_index = v.index
			self.from_view = FROM_WAIST
			skill_id_cfg = WaistData.Instance:GetWaistSkillId()[self.cur_index + 1] or {}
		elseif k == "beadskill" then
			self.cur_index = v.index
			self.from_view = FROM_BEAD
			skill_id_cfg = BeadData.Instance:GetBeadSkillId()[self.cur_index + 1] or {}
		elseif k == "fabaoskill" then
			self.cur_index = v.index
			self.from_view = FROM_FABAO
			skill_id_cfg = FaBaoData.Instance:GetFaBaoSkillId()[self.cur_index + 1] or {}
		elseif k == "kirin_armskill" then
			self.cur_index = v.index
			self.from_view = FROM_KIRIN_ARM
			skill_id_cfg = KirinArmData.Instance:GetKirinArmSkillId()[self.cur_index + 1] or {}
		end
	end
	self.skill_id = skill_id_cfg.skill_id or 0


	if self.cur_index ~= nil then
		self:SetData()
	end
end

function TipSkillUpgradeView:DataCallBack()
	if self.cur_index ~= nil then
		self:SetData()
	end
end