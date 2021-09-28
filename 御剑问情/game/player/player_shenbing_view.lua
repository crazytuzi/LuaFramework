PlayerShenBingView = PlayerShenBingView or BaseClass(BaseRender)

local EFFECT_CD = 1
function PlayerShenBingView:__init(instance)
	if instance == nil then
		return
	end
	self.is_auto = false
	self.item_index = 1
	self.effect_cd = 0
	self.is_on_auto_buy = 0
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
	self.is_to_maxlv = self:FindVariable("IsToMaxLv")
	self.hide_effect = self:FindVariable("HideEffect")
	self.show_auto_jinjie_gray = self:FindVariable("show_auto_jinjie_gray")
	self.show_btn_gray = self:FindVariable("show_btn_gray")
	self.show_jinjie_gray:SetValue(not self.is_auto)
	self.show_auto_jinjie_gray:SetValue(ShenBingData.Instance:GetShenBingInfo().level >= ShenBingMaxLevel)
	self.toggle_group = self:FindObj("items").toggle_group

	self.item_mask_image1 = self:FindVariable("item_mask_image1")
	self.show_mask1 = self:FindVariable("show_mask1")
	self.item_mask_image2 = self:FindVariable("item_mask_image2")
	self.show_mask2 = self:FindVariable("show_mask2")
	self.item_mask_image3 = self:FindVariable("item_mask_image3")
	self.show_mask3 = self:FindVariable("show_mask3")
	self.auto_buy = self:FindObj("auto_buy")
	self.auto_buy.toggle:AddValueChangedListener(BindTool.Bind(self.OnAutoBuyToggleChange, self))

	self.show_mask = {self.show_mask1, self.show_mask2, self.show_mask3}
	self.item_mask_image = {self.item_mask_image1, self.item_mask_image2, self.item_mask_image3}

	self.item_cell_list = {}
	local item_cell = nil
	for i = 1, 3 do
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("item"..i))
		item_cell:SetToggleGroup(self.toggle_group)
		item_cell:ListenClick(BindTool.Bind(self.ClickItem, self, i))

		table.insert(self.item_cell_list, item_cell)
	end

	self:ListenEvent("jinjie_click", BindTool.Bind(self.OnJinJieClick, self))
	self:ListenEvent("shuxingdan_click", BindTool.Bind(self.OnShuXingDanClick, self))
	self:ListenEvent("help_click", BindTool.Bind(self.OnHelpClick, self))
	self:ListenEvent("auto_jinjie_click", BindTool.Bind(self.OnAutoJinJieClick, self))
	self.skill_icon_list = {}
	self.show_skill_gray_list = {}
	self.skill_icon = {}
	for i = 1, 4 do
		self.show_skill_gray_list[i] = self:FindVariable("show_skill_gray_" .. i)
		self:ListenEvent("skill_click_" .. i, BindTool.Bind2(self.OnSkillClick, self, i))
		self.skill_icon[i] = self:FindVariable("skill_icon"..i)
		self.skill_icon[i]:SetAsset(ResPath.GetShenBingSkillIcon(i))
	end
	
	self.display = self:FindObj("display")
	self.effect_root = self:FindObj("effect_root")
	self.name:SetValue(Language.Common.ShenBingName)
	self.show_red_zizhi:SetValue(ShenBingData.Instance:GetShenBingZiZhiRemind())
	self:SetNotifyDataChangeCallBack()
end

function PlayerShenBingView:__delete()
	for _, v in ipairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}

	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	self:RemoveNotifyDataChangeCallBack()
end

function PlayerShenBingView:SetAuto(is_auto)
	self.is_auto = is_auto
	self.auto_btn_text:SetValue(self.is_auto and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
end

function PlayerShenBingView:CheckSelectItem()
	local index = ShenBingData.Instance:CheckSelectItem(self.item_index - 1)
	self.item_index = index + 1

	--刷新自动购买展示
	if self.item_index ~= 1 then
		self.auto_buy:SetActive(false)
		self.is_on_auto_buy = 0
	elseif self.item_index == 1 then
		self.auto_buy:SetActive(true)
		self.is_on_auto_buy = self.auto_buy.toggle.isOn and 1 or 0
	end

	for k, v in ipairs(self.item_cell_list) do
		v:SetToggle(self.item_index == k)
	end
end

function PlayerShenBingView:OnAutoBuyToggleChange(is_on)
	self.is_on_auto_buy = is_on and 1 or 0
end

function PlayerShenBingView:ClickItem(index)
	self.item_index = index

	if index ~= 1 then
		self.auto_buy:SetActive(false)
		self.is_on_auto_buy = 0
	elseif index == 1 then
		self.auto_buy:SetActive(true)
		self.is_on_auto_buy = self.auto_buy.toggle.isOn and 1 or 0
	end
end

function PlayerShenBingView:OnFlush(param_t)
	if nil ~= param_t.upgraderesult then
		self:OnUpgradeResult(param_t.upgraderesult[1])
	end
	if self.model_view == nil then
		self.model_view = RoleModel.New("shenbing_panel")
		self.model_view:SetDisplay(self.display.ui3d_display)
		self.model_view:SetMainAsset(ResPath.GetHunQiModel(17011))
	end

	local shenbing_data = ShenBingData.Instance
	for i = 1, 3 do
		local up_level_cfg = shenbing_data:GetUpLevelCfg(i - 1)
		local data = {}
		data.item_id = up_level_cfg.up_level_item_id
		data.num = ItemData.Instance:GetItemNumInBagById(up_level_cfg.up_level_item_id)
		if data.num <= 0 then
			self.item_mask_image[i]:SetAsset(ResPath.GetItemIcon(data.item_id))
			self.show_mask[i]:SetValue(true)
		else
			self.show_mask[i]:SetValue(false)
		end
		self.item_cell_list[i]:SetShowNumTxtLessNum(-1)
		self.item_cell_list[i]:SetData(data)
		self.item_cell_list[i]:SetIconGrayScale(false)
		self.item_cell_list[i]:ShowQuality(true)
	end
	local info = shenbing_data:GetShenBingInfo()
	if next(info) and info.level and info.level >= 1 then
		local cur_attr = shenbing_data:GetLevelAttrCfg(info.level)
		local next_attr = shenbing_data:GetLevelAttrCfg(info.level + 1)
		self.gongji_cur_value:SetValue(cur_attr.gongji)
		self.pojia_cur_value:SetValue(cur_attr.per_jingzhun)
		self.level:SetValue(info.level)

		self.progress_text:SetValue(info.exp.."/"..cur_attr.uplevel_exp)
		self.power_value:SetValue(CommonDataManager.GetCapabilityCalculation(cur_attr))
		self.show_red_zizhi:SetValue(ShenBingData.Instance:GetShenBingZiZhiRemind())
		self.show_next_attr:SetValue(info.level < ShenBingMaxLevel)
		if next_attr and next(next_attr) and info.level < ShenBingMaxLevel then
			self.gongji_next_value:SetValue(next_attr.gongji)
			self.pojia_next_value:SetValue(next_attr.per_jingzhun)
		end

		local pro_value = 1
		if info.level >= ShenBingMaxLevel then
			self.progress_text:SetValue(cur_attr.uplevel_exp.."/"..cur_attr.uplevel_exp)
			self.auto_btn_text:SetValue(Language.Common.MaxLevel)
			self.show_jinjie_gray:SetValue(false)
			self.show_auto_jinjie_gray:SetValue(false)
			self.hide_effect:SetValue(true)
			self.show_btn_gray:SetValue(true)
		else
			pro_value = info.exp/cur_attr.uplevel_exp
		end

		--进度条第一次打开界面不做动画
		if self.is_init then
			self.is_init = false
			self.progress_value:InitValue(pro_value)
		else
			self.progress_value:SetValue(pro_value)
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
	if self.is_auto then
		self:SendJinJie()
	 end
end

function PlayerShenBingView:SendJinJie()
	local item_id = ShenBingData.Instance:GetUpLevelCfg(self.item_index - 1).up_level_item_id
	local my_count = ItemData.Instance:GetItemNumInBagById(item_id)
	if my_count > 0 or self.is_on_auto_buy == 1 and not self.is_can_send then
		ShenBingCtrl.SentShenBingUpLevel(self.item_index - 1,self.is_on_auto_buy)
	else
		self.is_auto = false
	end
	self.show_jinjie_gray:SetValue(not self.is_auto)
	self.auto_btn_text:SetValue(self.is_auto and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
end

function PlayerShenBingView:OnAutoJinJieClick()
	self.is_can_send = false
	self.is_auto = not self.is_auto
	
	if self.is_on_auto_buy and self.is_on_auto_buy == 0 then
	--物品不足弹出不足框
		local item_id = ShenBingData.Instance:GetUpLevelCfg(self.item_index - 1).up_level_item_id
		local my_count = ItemData.Instance:GetItemNumInBagById(item_id)
		if my_count <= 0 then
			--商店中有的物品就弹出购买面板
			if ShopData.Instance:CheckIsInShop(item_id) then
				local function buy_call_back(temp_item_id, item_num, is_bind, is_use, is_buy_quick)
					MarketCtrl.Instance:SendShopBuy(temp_item_id, item_num, is_bind, is_use)
					self.auto_buy.toggle.isOn = is_buy_quick
				end
				TipsCtrl.Instance:ShowCommonBuyView(buy_call_back, item_id, nil, 1)
			else
				TipsCtrl.Instance:ShowItemGetWayView(item_id)
			end
		end
	end

	self.auto_btn_text:SetValue(self.is_auto and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
	self.show_jinjie_gray:SetValue(not self.is_auto)
	self:AutoJinJieResult()
end

function PlayerShenBingView:StopJinJie()
	self.is_auto = false
	self.auto_btn_text:SetValue(self.is_auto and Language.Common.AutoUpgrade2[2] or Language.Common.AutoUpgrade2[1])
	self.show_jinjie_gray:SetValue(not self.is_auto)
end

function PlayerShenBingView:OpenCallBack()
	self.is_can_send = true
	self.is_init = true
end

function PlayerShenBingView:OnUpgradeResult(defalut)
	self:CheckSelectItem()

	if defalut then
		self:AutoJinJieResult()
	else
		self.is_auto = false
		self.show_jinjie_gray:SetValue(true)
		self.auto_btn_text:SetValue(Language.Common.AutoUpgrade2[1])
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
	 TipsCtrl.Instance:ShowTipSkillView(i - 1, "shenbing")
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
			"effects2/prefab/ui_x/ui_sjcg_prefab",
			"UI_sjcg",
			self.effect_root.transform,
			2.0)
		self.effect_cd = Status.NowTime + EFFECT_CD
	end
end