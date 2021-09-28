WeddingTipsTwoView = WeddingTipsTwoView or BaseClass(BaseView)

function WeddingTipsTwoView:__init()
	self.ui_config = {"uis/views/marriageview_prefab","WeddingTips2"}
end

function WeddingTipsTwoView:__delete()

end

function WeddingTipsTwoView:LoadCallBack()
	self.fight_power = self:FindVariable("FightPowerText")
	self.title = self:FindVariable("TitleAsset")
	self.self_display = self:FindObj("SelfDisplay")
	self.lover_display = self:FindObj("LoverDisplay")

	self.ring_item = ItemCell.New()
	self.ring_item:SetInstanceParent(self:FindObj("RingItem"))

	self:ListenEvent("Close", BindTool.Bind(self.OnClickCloseView,self))
	self:ListenEvent("ClickTitle", BindTool.Bind(self.OnClickTitle,self))
end

function WeddingTipsTwoView:ReleaseCallBack()
	if self.self_model then
		self.self_model:DeleteMe()
		self.self_model = nil
	end

	if self.love_model then
		self.love_model:DeleteMe()
		self.love_model = nil
	end

	if self.ring_item then
		self.ring_item:DeleteMe()
		self.ring_item = nil
	end

	self.fight_power = nil
	self.title = nil
	self.self_display = nil
	self.lover_display = nil
end

function WeddingTipsTwoView:OpenCallBack()
	self:Flush()
end

function WeddingTipsTwoView:CloseCallBack()
end

function WeddingTipsTwoView:OnFlush()
	local wedding_index = MARRIAGE_SELECT_TYPE.MARRIAGE_SELECT_TYPE_FESTIVA.index - 1
	local wedding_info = MarriageData.Instance:GetHunliInfoByType(wedding_index)
	if next(wedding_info) == nil then
		return
	end

	-- 刷新右边内容
	self.ring_item:SetData(wedding_info.reward_tips[0])
	local bundle, asset = ResPath.GetTitleModel(wedding_info.title_id .. "_H")
	self.title:SetAsset(bundle, asset)
	local power_value = MarriageData.Instance:GetMarriageTipPower(wedding_index, WEDDING_TIPS_POWER_TYPE.SECONDGEAR)
	self.fight_power:SetValue(power_value * 2)

	-- 刷新左边内容
	self:FlushDisPlay()
end

function WeddingTipsTwoView:OnClickCloseView()
	self:Close()
end

function WeddingTipsTwoView:InitDisPlay()
	if not self.self_model then
		self.self_model = RoleModel.New("wedding_tips_model")
		self.self_model:SetDisplay(self.self_display.ui3d_display)
	end
	if not self.love_model then
		self.love_model = RoleModel.New("wedding_tips_model")
		self.love_model:SetDisplay(self.lover_display.ui3d_display)
	end
end

function WeddingTipsTwoView:FlushDisPlay()
	self:InitDisPlay()
	local wedding_info = MarriageData.Instance:GetHunliInfoByType(MARRIAGE_SELECT_TYPE.MARRIAGE_SELECT_TYPE_FESTIVA.index - 1)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	if next(wedding_info) == nil or next(main_role_vo) == nil then
		return
	end

	-- 设置自己的模型
	-- 第二档配置第二个为时装，故写死reward_type读第二个
	local res_id = FashionData.GetFashionResByItemId(wedding_info.reward_type[1].item_id, main_role_vo.sex, main_role_vo.prof) or 0
	self.self_model:SetRoleResid(res_id)

	-- 设置伴侣的模型
	local lover_sex = main_role_vo.sex == GameEnum.FEMALE and GameEnum.MALE or GameEnum.FEMALE
	local lover_prof = main_role_vo.sex == GameEnum.FEMALE and GameEnum.ROLE_PROF_1 or GameEnum.ROLE_PROF_4
	local res_id = FashionData.GetFashionResByItemId(wedding_info.reward_type[1].item_id, lover_sex, lover_prof) or 0
	self.love_model:SetRoleResid(res_id)
end

function WeddingTipsTwoView:OnClickTitle()
	local wedding_info = MarriageData.Instance:GetHunliInfoByType(MARRIAGE_SELECT_TYPE.MARRIAGE_SELECT_TYPE_FESTIVA.index - 1)
	local title_info = TitleData.Instance:GetUpgradeCfg(wedding_info.title_id)
	if next(wedding_info) == nil or next(title_info) == nil then
		return
	end

	TipsCtrl.Instance:OpenItem({item_id = title_info.stuff_id})
end