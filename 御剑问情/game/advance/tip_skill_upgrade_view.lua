TipSkillUpgradeView = TipSkillUpgradeView or BaseClass(BaseView)

local FROM_MOUNT = 1		-- 从坐骑界面打开
local FROM_WING = 2			-- 从羽翼界面打开
local FROM_HALO = 3			-- 从光环界面打开
local FROM_SHENGONG = 4		-- 从神弓界面打开
local FROM_SHENYI = 5		-- 从神翼界面打开
local FROM_FOOT = 6			-- 从足迹界面打开
local FROM_LINGCHONG = 7	-- 从灵宠界面打开
local NAME_LIST = {"坐骑", "羽翼", "光环", "伙伴光环", "伙伴法阵", "足迹", "灵宠"}
local EFFECT_CD = 0.8

function TipSkillUpgradeView:__init()
	self.ui_config = {"uis/views/tips/advancetips_prefab","SkillUpgradeTip"}
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
end

-- 创建完调用
function TipSkillUpgradeView:LoadCallBack()
	self:ListenEvent("OnClickCloseButton",
		BindTool.Bind(self.OnClickCloseButton, self))
	self:ListenEvent("OnClickUpgradeButton",
		BindTool.Bind(self.OnClickUpgradeButton, self))

	self.level = self:FindVariable("Level")
	self.current_effect = self:FindVariable("CurrentEffect")
	self.next_effect = self:FindVariable("NextEffect")
	self.hide_next_effect = self:FindVariable("HideNextEffect")
	self.grade = self:FindVariable("Rank")
	self.is_Active_text = self:FindVariable("IsActive")
	self.skill_icon = self:FindVariable("SkillIcon")
	self.skill_name = self:FindVariable("SkillName")
	self.need_pro_num = self:FindVariable("NeedProNum")
	self.have_pro_num = self:FindVariable("HaveProNum")
	self.show_cur_effect = self:FindVariable("IsShowCurEffect")
	self.show_max_level_tip = self:FindVariable("ShowMaxLevelTip")
	self.show_normal_text = self:FindVariable("ShowNormalText")
	self.advance_type = self:FindVariable("AdvanceType")
	self.show_up_level_tip = self:FindVariable("ShowUpLevelTip")
	self.can_up_level_grade = self:FindVariable("Grade")
	self.show_effect = self:FindVariable("ShowEffect")

	self.special_skill_up_view = self:FindObj("SpecialSkillUpInfo")
	self.normal_skill_up_view = self:FindObj("NormalSkillUpInfo")
	self.gray_up_level_btn1 = self:FindObj("UpLevelButton1")
	self.gray_up_level_btn2 = self:FindObj("UpLevelButton2")
	self.gray_up_level_txt1 = self:FindObj("UpLevelTxt1")
	self.gray_up_level_txt2 = self:FindObj("UpLevelTxt2")

	self.item_cell = ItemCellReward.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
end

function TipSkillUpgradeView:ReleaseCallBack()
	if self.item_cell ~= nil then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- 清理变量和对象
	self.level = nil
	self.current_effect = nil
	self.next_effect = nil
	self.grade = nil
	self.is_Active_text = nil
	self.skill_icon = nil
	self.skill_name = nil
	self.need_pro_num = nil
	self.have_pro_num = nil
	self.show_cur_effect = nil
	self.show_max_level_tip = nil
	self.show_normal_text = nil
	self.advance_type = nil
	self.show_up_level_tip = nil
	self.can_up_level_grade = nil
	self.show_effect = nil
	self.special_skill_up_view = nil
	self.normal_skill_up_view = nil
	self.gray_up_level_btn1 = nil
	self.gray_up_level_btn2 = nil
	self.gray_up_level_txt1 = nil
	self.gray_up_level_txt2 = nil
	self.hide_next_effect = nil
end

function TipSkillUpgradeView:__delete()
	self.info = nil
	self.cur_index = nil
	self.cur_data = nil
	self.next_data_cfg = nil
	self.next_level = nil
	self.item_id = nil
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
		if item_cfg.bind_gold == 0 then
			TipsCtrl.Instance:ShowShopView(self.item_id, 2)
			return
		end

		local func = function(item_id, item_num, is_bind, is_use)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
		end
		TipsCtrl.Instance:ShowCommonBuyView(func, self.item_id)
		return
	end
	if self.from_view == FROM_MOUNT then
		MountCtrl.Instance:MountSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_WING then
		WingCtrl.Instance:WingSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_HALO then
		HaloCtrl.Instance:HaloSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_SHENGONG then
		ShengongCtrl.Instance:ShengongSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_FOOT then
		FootCtrl.Instance:FootSkillUplevelReq(self.cur_index)
	elseif self.from_view == FROM_LINGCHONG then
		FootCtrl.Instance:FootSkillUplevelReq(self.cur_index)
	else
		ShenyiCtrl.Instance:ShenyiSkillUplevelReq(self.cur_index)
	end
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
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = MountData.Instance:GetMountSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = MountData.Instance:GetMountGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_WING then							 -- 羽翼技能
		self.cur_data = WingData.Instance:GetWingSkillCfgById(self.cur_index) or {}
		self.info = WingData.Instance:GetWingInfo()
		bundle, asset = ResPath.GetWingSkillIcon(self.cur_index + 1)
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = WingData.Instance:GetWingSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = WingData.Instance:GetWingGradeCfg(self.next_data_cfg.grade)
		end
	elseif self.from_view == FROM_HALO then							-- 光环技能
		self.cur_data = HaloData.Instance:GetHaloSkillCfgById(self.cur_index) or {}
		self.info = HaloData.Instance:GetHaloInfo()
		bundle, asset = ResPath.GetHaloSkillIcon(self.cur_index + 1)
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = HaloData.Instance:GetHaloSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = HaloData.Instance:GetHaloGradeCfg(self.next_data_cfg.grade)
		end
	elseif self.from_view == FROM_SHENGONG then						-- 神弓技能
		self.cur_data = ShengongData.Instance:GetShengongSkillCfgById(self.cur_index) or {}
		self.info = ShengongData.Instance:GetShengongInfo()
		bundle, asset = ResPath.GetShengongSkillIcon(self.cur_index + 1)
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = ShengongData.Instance:GetShengongSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = ShengongData.Instance:GetShengongGradeCfg(self.next_data_cfg.grade)
		end
	elseif self.from_view == FROM_SHENYI then						-- 神翼技能
		self.cur_data = ShenyiData.Instance:GetShenyiSkillCfgById(self.cur_index) or {}
		self.info = ShenyiData.Instance:GetShenyiInfo()
		bundle, asset = ResPath.GetShenyiSkillIcon(self.cur_index + 1)
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = ShenyiData.Instance:GetShenyiSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg(self.next_data_cfg.grade)
		end
	elseif self.from_view == FROM_FOOT then						-- 足迹技能
		self.cur_data = FootData.Instance:GetFootSkillCfgById(self.cur_index) or {}
		self.info = FootData.Instance:GetFootInfo()
		bundle, asset = ResPath.GetFootSkillIcon(self.cur_index + 1)
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = FootData.Instance:GetFootSkillCfgById(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = FootData.Instance:GetFootGradeCfg(self.next_data_cfg.grade)
		end

	elseif self.from_view == FROM_LINGCHONG then						-- 灵宠技能
		self.cur_data = LingChongData.Instance:GetSkillCfgInfo(self.cur_index) or {}
		self.info = LingChongData.Instance:GetLingChongInfo()
		bundle, asset = "uis/views/appearance/images_atlas", "lingchong_skill"
		if next(self.cur_data) then
			cur_level = self.cur_data.skill_level
			next_level = cur_level + 1
		end
		self.next_data_cfg = LingChongData.Instance:GetSkillCfgInfo(self.cur_index, next_level) or {}
		if not next(self.cur_data) and next(self.next_data_cfg) then
			self.client_grade_cfg = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade(self.next_data_cfg.grade)
		end
	end
	is_active = nil ~= next(self.cur_data)
	self.item_id = self.cur_data.uplevel_stuff_id or self.next_data_cfg.uplevel_stuff_id
	local count = ItemData.Instance:GetItemNumInBagById(self.item_id)

	local bool_btn_interactable = self.info.grade ~= 0 and nil ~= next(self.next_data_cfg)  --获取升级按钮是否可用
	self.gray_up_level_btn1.button.interactable = bool_btn_interactable
	self.gray_up_level_btn2.button.interactable = bool_btn_interactable
	--如果按钮置为不可用（灰色）则字体也置为灰色
	if bool_btn_interactable then
		self.gray_up_level_txt1.grayscale.GrayScale = 0
	else
		self.gray_up_level_txt1.grayscale.GrayScale = 255
	end
	if bool_btn_interactable then
		self.gray_up_level_txt2.grayscale.GrayScale = 0
	else
		self.gray_up_level_txt2.grayscale.GrayScale = 255
	end
	self.normal_skill_up_view:SetActive(self.cur_index ~= 0)
	self.special_skill_up_view:SetActive(self.cur_index == 0)
	self.skill_icon:SetAsset(bundle, asset)
	self.skill_name:SetValue(self.cur_data.skill_name or self.next_data_cfg.skill_name or "")
	self.show_cur_effect:SetValue(is_active)
	self.show_up_level_tip:SetValue(not is_active)
	self.is_Active_text:SetValue(not is_active and Language.Mount.NotActive or Language.Mount.HadActive)
	self.level:SetValue(cur_level)

	if self.temp_level == cur_level then
		return
	end

	if self.temp_level and self.temp_level < cur_level then
		if Status.NowTime - self.effect_cd > EFFECT_CD then
			self.show_effect:SetValue(false)
			self.show_effect:SetValue(true)
			self.effect_cd = Status.NowTime
		end
	else
		self.show_effect:SetValue(false)
	end
	self.temp_level = cur_level


	--设置所需升级物品ItemCell
	local data = {}
	data.item_id = self.item_id
	local func = function() if ViewManager.Instance:IsOpen(ViewName.Shop) then self:Close() end end
	data.close_call_back = func
	self.item_cell:SetData(data)



	if is_active then
		cur_desc = string.gsub(self.cur_data.desc, "%b()%%", function (str)
			return ToColorStr((tonumber(self.cur_data[string.sub(str, 2, -3)]) / 1000), TEXT_COLOR.BLUE_4)
		end)
		cur_desc = string.gsub(cur_desc, "%b[]%%", function (str)
			return ToColorStr((tonumber(self.cur_data[string.sub(str, 2, -3)]) / 100) .. "%", TEXT_COLOR.BLUE_4)
		end)
		cur_desc = string.gsub(cur_desc, "%[.-%]", function (str)
			return ToColorStr(self.cur_data[string.sub(str, 2, -2)], TEXT_COLOR.BLUE_4)
		end)
		self.current_effect:SetValue(cur_desc)
	end

	if next(self.next_data_cfg) then
		self.grade:SetValue(Language.Common.NumToChs[self.next_data_cfg.grade - 1])
		if count < self.next_data_cfg.uplevel_stuff_num then
			self.have_pro_num:SetValue(string.format(Language.Mount.ShowRedNum, count))
		else
			self.have_pro_num:SetValue(count)
		end
		self.need_pro_num:SetValue(self.next_data_cfg.uplevel_stuff_num)
		next_desc = string.gsub(self.next_data_cfg.desc, "%b()%%", function (str)
			return  ToColorStr((tonumber(self.next_data_cfg[string.sub(str, 2, -3)]) / 1000).."", TEXT_COLOR.BLUE_4)
		end)
		next_desc = string.gsub(next_desc, "%b[]%%", function (str)
			return ToColorStr((tonumber(self.next_data_cfg[string.sub(str, 2, -3)]) / 100) .. "%", TEXT_COLOR.BLUE_4)
		end)
		next_desc = string.gsub(next_desc, "%[.-%]", function (str)
			return ToColorStr(self.next_data_cfg[string.sub(str, 2, -2)], TEXT_COLOR.BLUE_4)
		end)
		self.next_effect:SetValue(next_desc)
		self.show_max_level_tip:SetValue(false)
		self.hide_next_effect:SetValue(true)
		self.show_normal_text:SetValue(true)
		self.advance_type:SetValue(NAME_LIST[self.from_view])
		if self.client_grade_cfg then
			local str = string.format(Language.Mount.ShowRedStr, self.client_grade_cfg.gradename)
			if self.info.grade >= self.next_data_cfg.grade then
				print_log(self.client_grade_cfg.gradename)
				str = string.format(Language.Mount.ShowBlue2Str, self.client_grade_cfg.gradename)
			end
			self.can_up_level_grade:SetValue(str)
		end
	else
		self.have_pro_num:SetValue(string.format(Language.Mount.ShowRedNum, count))
		self.grade:SetValue("")
		self.next_effect:SetValue(Language.Common.MaxLvTips)
		self.show_max_level_tip:SetValue(true)
		self.hide_next_effect:SetValue(false)
		self.show_normal_text:SetValue(false)
		self.need_pro_num:SetValue(0)
	end
end

function TipSkillUpgradeView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "mountskill" then
			self.cur_index = v.index
			self.from_view = FROM_MOUNT
		elseif k == "wingskill" then
			self.cur_index = v.index
			self.from_view = FROM_WING
		elseif k == "haloskill" then
			self.cur_index = v.index
			self.from_view = FROM_HALO
		elseif k == "shengongskill" then
			self.cur_index = v.index
			self.from_view = FROM_SHENGONG
		elseif k == "shenyiskill" then
			self.cur_index = v.index
			self.from_view = FROM_SHENYI
		elseif k == "footskill" then
			self.cur_index = v.index
			self.from_view = FROM_FOOT
		elseif k == "lingchongkill" then
			self.cur_index = v.index
			self.from_view = FROM_LINGCHONG
		end
	end

	if self.cur_index ~= nil then
		self:SetData()
	end
end