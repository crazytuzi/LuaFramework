PlayerShenBingView = PlayerShenBingView or BaseClass(BaseRender)

local EFFECT_CD = 1
function PlayerShenBingView:__init(instance)
	if instance == nil then
		return
	end
	self.is_auto = false
	self.item_index = 1
	self.effect_cd = 0
	self.level = self:FindVariable("level")
	self.name = self:FindVariable("name")
	self.progress_text = self:FindVariable("progress_text")
	self.progress_value = self:FindVariable("progress_value")
	self.show_level = self:FindVariable("show_level")

	self.gongji_cur_value = self:FindVariable("gongji_cur_value")
	self.gongji_next_value = self:FindVariable("gongji_next_value")
	self.pojia_cur_value = self:FindVariable("pojia_cur_value")
	self.pojia_next_value = self:FindVariable("pojia_next_value")
	self.show_red_zizhi = self:FindVariable("show_red_zizhi")
	self.power_value = self:FindVariable("power_value")
	self.show_next_attr = self:FindVariable("show_next_attr")
	self.auto_btn_text = self:FindVariable("auto_btn_text")
	self.show_jinjie_gray = self:FindVariable("show_jinjie_gray")
	self.show_auto_jinjie_gray = self:FindVariable("show_auto_jinjie_gray")
	self.show_jinjie_gray:SetValue(not self.is_auto)
	self.show_auto_jinjie_gray:SetValue(ShenBingData.Instance:GetShenBingInfo().level >= ShenBingMaxLevel)
	self.toggle_group = self:FindObj("items").toggle_group

	self.item_cell_list = {}
	self.toggle_list = {}
	for i=1,3 do
		self.item_cell_list[i] = ItemCell.New()
		self.item_cell_list[i]:SetInstanceParent(self:FindObj("item"..i))
		self.item_cell_list[i]:SetToggleGroup(self.toggle_group)
		local handler = function()
			self.item_index = i
			for i=1,3 do
				self.item_cell_list[i]:SetToggle(self.item_index == i)
			end
		end
		self.item_cell_list[i]:ListenClick(handler)
	end

	self:ListenEvent("jinjie_click", BindTool.Bind(self.OnJinJieClick, self))
	self:ListenEvent("shuxingdan_click", BindTool.Bind(self.OnShuXingDanClick, self))
	self:ListenEvent("help_click", BindTool.Bind(self.OnHelpClick, self))
	self:ListenEvent("auto_jinjie_click", BindTool.Bind(self.OnAutoJinJieClick, self))
	self.skill_icon_list = {}
	self.show_skill_gray_list = {}
	for i=1,4 do
		self.show_skill_gray_list[i] = self:FindVariable("show_skill_gray_"..i)
		self:ListenEvent("skill_click_" .. i, BindTool.Bind2(self.OnSkillClick, self, i))
	end
	self.display = self:FindObj("display")
	self.effect_root = self:FindObj("effect_root")
	self.name:SetValue(Language.Common.ShenBingName)
	self.show_red_zizhi:SetValue(ShenBingData.Instance:GetShenBingZiZhiRemind())
	self:SetNotifyDataChangeCallBack()
end

function PlayerShenBingView:__delete()
	for i=1,3 do
		self.item_cell_list[i]:DeleteMe()
	end
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end
	self:RemoveNotifyDataChangeCallBack()
	self.effect_root = nil
end

function PlayerShenBingView:SetAuto(is_auto)
	self.is_auto = is_auto
	self.auto_btn_text:SetValue(self.is_auto and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
end

function PlayerShenBingView:CheckSelectItem()
	local index = ShenBingData.Instance:CheckSelectItem(self.item_index - 1)
	self.item_index = index + 1
	for i=1,3 do
		self.item_cell_list[i]:SetToggle(self.item_index == i)
	end
end

function PlayerShenBingView:OnFlush()
	if self.model_view == nil then
		self.model_view = RoleModel.New()
		self.model_view:SetDisplay(self.display.ui3d_display)
		self.model_view:SetMainAsset(ResPath.GetHunQiModel(17007))
		self.model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.SHEN_BING], 17007, DISPLAY_PANEL.FULL_PANEL)
	end

	local shenbing_data = ShenBingData.Instance
	for i=1,3 do
		local up_level_cfg = shenbing_data:GetUpLevelCfg(i - 1)
		local data = {}
		data.item_id = up_level_cfg.up_level_item_id
		data.num = ItemData.Instance:GetItemNumInBagById(up_level_cfg.up_level_item_id)
		self.item_cell_list[i]:SetShowNumTxtLessNum(0)
		self.item_cell_list[i]:SetData(data)
		self.item_cell_list[i]:SetIconGrayScale(data.num <= 0)
		self.item_cell_list[i]:ShowQuality(data.num > 0)
	end
	local info = shenbing_data:GetShenBingInfo()
	if next(info) and info.level and info.level >= 1 then
		local cur_attr = shenbing_data:GetLevelAttrCfg(info.level)
		local next_attr = shenbing_data:GetLevelAttrCfg(info.level + 1)
		self.gongji_cur_value:SetValue(cur_attr.gongji)
		self.pojia_cur_value:SetValue(cur_attr.per_jingzhun)
		self.level:SetValue(info.level)
		self.progress_value:SetValue(info.exp/cur_attr.uplevel_exp)
		self.progress_text:SetValue(info.exp.."/"..cur_attr.uplevel_exp)
		self.power_value:SetValue(CommonDataManager.GetCapabilityCalculation(cur_attr))
		self.show_red_zizhi:SetValue(ShenBingData.Instance:GetShenBingZiZhiRemind())
		self.show_next_attr:SetValue(info.level < ShenBingMaxLevel)
		if next_attr and next(next_attr) and info.level < ShenBingMaxLevel then
			self.gongji_next_value:SetValue(next_attr.gongji)
			self.pojia_next_value:SetValue(next_attr.per_jingzhun)
		end
		if info.level >= ShenBingMaxLevel then
			self.progress_value:SetValue(1)
			self.progress_text:SetValue(cur_attr.uplevel_exp.."/"..cur_attr.uplevel_exp)
			self.auto_btn_text:SetValue(Language.Common.MaxLevel)
			self.show_jinjie_gray:SetValue(false)
			self.show_auto_jinjie_gray:SetValue(false)
		end
		for i=1,4 do
			self.show_skill_gray_list[i]:SetValue(shenbing_data:GetIsActive(i - 1))
		end
		self.show_auto_jinjie_gray:SetValue(info.level < ShenBingMaxLevel)
	end
	self.show_jinjie_gray:SetValue(not self.is_auto and info.level < ShenBingMaxLevel )
	self:CheckSelectItem()
end

function PlayerShenBingView:OnJinJieClick()
	self.is_auto = false
	self:SendJinJie()
end

function PlayerShenBingView:AutoJinJieResult()
	if self.is_auto == true then self:SendJinJie() end
end

function PlayerShenBingView:SendJinJie()
	local item_id = ShenBingData.Instance:GetUpLevelCfg(self.item_index - 1).up_level_item_id
	local my_count = ItemData.Instance:GetItemNumInBagById(item_id)
	if my_count > 0 then
		ShenBingCtrl.SentShenBingUpLevel(self.item_index - 1)
	else
		TipsCtrl.Instance:ShowItemGetWayView(item_id)
		self.is_auto = false
	end
	self.show_jinjie_gray:SetValue(not self.is_auto)
	self.auto_btn_text:SetValue(self.is_auto and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
end

function PlayerShenBingView:OnAutoJinJieClick()
	if self.is_auto == true then --再点一次停止
		self.is_auto = false
	else
		self.is_auto = true
	end
	self.auto_btn_text:SetValue(self.is_auto and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
	self.show_jinjie_gray:SetValue(not self.is_auto)
	self:AutoJinJieResult()
end

function PlayerShenBingView:OnUpgradeResult(defalut)
	self:CheckSelectItem()
	if defalut == true and self.is_auto == true then
		self:AutoJinJieResult()
	end
end

function PlayerShenBingView:OnShuXingDanClick()
	ViewManager.Instance:Open(ViewName.TipZiZhi, nil, "shenbingzizhi", {item_id = ShenBingDanId.ZiZhiDanId})
end

function PlayerShenBingView:OnHelpClick()
	local tips_id = 164
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function PlayerShenBingView:OnSkillClick(i)
	 TipsCtrl.Instance:ShowTipSkillView(i - 1)
end

function PlayerShenBingView:RemoveNotifyDataChangeCallBack()
	if self.item_data_event ~= nil then
		if ItemData.Instance then
			ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
			self.item_data_event = nil
		end
	end
end

function PlayerShenBingView:SetNotifyDataChangeCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function PlayerShenBingView:ItemDataChangeCallback(item_id)
	local shen_data = ShenBingData.Instance
	if item_id == ShenBingDanId.ZiZhiDanId then
		self.show_red_zizhi:SetValue(shen_data:GetShenBingZiZhiRemind())
		return
	end

	local item_id_list = {}
	for i=1,3 do
		if item_id == shen_data:GetUpLevelCfg(i - 1).up_level_item_id then
			self:Flush()
			return
		end
	end
end

function PlayerShenBingView:PlayUpStarEffect()
	if self.effect_cd and self.effect_cd - Status.NowTime <= 0 then
		EffectManager.Instance:PlayAtTransformCenter(
			"effects2/prefab/ui/ui_shengjichenggong_prefab",
			"UI_shengjichenggong",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end