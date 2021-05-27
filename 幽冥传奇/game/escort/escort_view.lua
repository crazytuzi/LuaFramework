
--护送镖车view
EscortView = EscortView or BaseClass(BaseView)
EscortView.Enum = {
	Quality = 1,				--镖车品质
	RefreTimes = 2,				--刷新品质次数
	EscortTimes = 3,			--护送次数
	IsDouble = 4,				--是否双倍
}

function EscortView:__init()
	self.title_img_path = ResPath.GetWord("word_escort")
	self:SetModal(true)
	self:SetBackRenderTexture(true)

	self.texture_path_list[1] = "res/xui/escort.png"
	self.config_tab = {
		{"common_ui_cfg", 1, {0},},
		{"escort_ui_cfg", 1, {0},},
		{"common_ui_cfg", 2, {0},},
	}
	self.is_in_open = false
	self.index = nil
end

function EscortView:__delete()

end

function EscortView:ReleaseCallBack()
	self.chosen_ef = nil

	if self.confirmDlg then
		self.confirmDlg:DeleteMe()
		self.confirmDlg = nil
	end

	if self.onekeyTopDlg then
		self.onekeyTopDlg:DeleteMe()
		self.onekeyTopDlg = nil
	end

	self.is_in_open = false

	self.index = nil
end

function EscortView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		self:RegisterAllEvents()
		self:CreateConfirmDlg()
		self:CreateAwardList()
		self:InitTextBtn()

		EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	end
end

function EscortView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function EscortView:ShowIndexCallBack(index)
	self:Flush(index)
end

function EscortView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
		elseif k == "OnOpenView" then
			self:SetAllLvRewardsTexts()
			self:ChosenEffect(tonumber(v[1]))
			self:FlushOnekeyLink(tonumber(v[1]))
			self:SetCurInfoTexts(v)
			self:SetEscortTokenNum()
		elseif k == "escort_token" then
			self:SetEscortTokenNum()
		elseif "refre_quality" then
			self:FlushAfterRefre()
		end
	end
end

function EscortView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function EscortView:InitTextBtn()
	local text, text_btn, ph
	local parent = self.node_t_list["layout_escort"].node

	ph = self.ph_list["ph_text_btn"]
	self.one_key_link_text = RichTextUtil.CreateLinkText(Language.Escort.TextBtn[1], 20, COLOR3B.GREEN, nil, true)
	self.one_key_link_text:setPosition(ph.x, ph.y)
	parent:addChild(self.one_key_link_text, 20)
	XUI.AddClickEventListener(self.one_key_link_text, BindTool.Bind(self.OnOnekeyLinkClicked, self), true)

	ph = self.ph_list["ph_text_btn_2"]
	text_btn = RichTextUtil.CreateLinkText(Language.Escort.TextBtn[2], 20, COLOR3B.GREEN, nil, true)
	text_btn:setPosition(ph.x, ph.y)
	parent:addChild(text_btn, 20)
	XUI.AddClickEventListener(text_btn, BindTool.Bind(self.OnBuyTokenClicked, self), true)
end

function EscortView:CreateConfirmDlg()
	if not self.confirmDlg then
		self.confirmDlg = Alert.New()
		self.confirmDlg:SetLableString(Language.Escort.ConfirmDlgContent[1])
		self.confirmDlg:SetOkFunc(BindTool.Bind(self.ConfirmInsureClicked, self))
	end

	if not self.onekeyTopDlg then
		self.onekeyTopDlg = Alert.New()
		self.onekeyTopDlg:SetLableString(string.format(Language.Escort.ConfirmDlgContent[3], StdActivityCfg[DAILY_ACTIVITY_TYPE.YA_SONG].onekeyConsume))
		self.onekeyTopDlg:SetOkFunc(BindTool.Bind(self.OnekeyToTopLvReq, self))
	end
end

function EscortView:OnBagItemChange()
	self:Flush(0, "escort_token")
end

--刷新品质后刷新界面
function EscortView:FlushAfterRefre()
	local refre_data = EscortData.Instance:GetRefreQualityData()
	local escortCarCfg = EscortData.Instance:GetEscortCfg()
	local awards_t = EscortData.Instance:GetOtherAwardsCfg()
	self:FlushOnekeyLink(refre_data.quality)
	self:ChosenEffect(refre_data.quality)
	self.node_t_list["lbl_car_level"].node:setString(Language.Escort.EscortLv[refre_data.quality])
	if refre_data.times > escortCarCfg.maxRefresh then
		refre_data.times = escortCarCfg.maxRefresh
	end
	self.node_t_list["lbl_free_times"].node:setString(string.format(Language.Escort.Times, 
		escortCarCfg.maxRefresh - refre_data.times))
end

function EscortView:FlushOnekeyLink(lv)
	self.one_key_link_text:setString(Language.Escort.TextBtn[1])
	self.one_key_link_text:setColor(lv >= 4 and COLOR3B.G_W or COLOR3B.GREEN)
	XUI.SetButtonEnabled(self.one_key_link_text, lv < 4)
	if lv < 4 then
		UiInstanceMgr.AddRectEffect({node = self.one_key_link_text, init_size_scale = 1.3, act_size_scale = 1.6, offset_w = - 15, offset_h = 8, color = COLOR3B.GREEN})
	else
		UiInstanceMgr.DelRectEffect(self.one_key_link_text)
	end
end

--设置所有不同等级护送奖励说明
function EscortView:SetAllLvRewardsTexts()
	local awards_t = EscortData.Instance:GetAwardsCfg()
	for i,v in ipairs(self.award_list) do
		if type(awards_t[i]) == "table" then
			v:SetDataList(awards_t[i])
			v:JumpToTop()
		end
	end
end

function EscortView:CreateAwardList()
	self.award_list = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_award_" .. i] or {x = 0, y = 0, w = 1, h = 1,}
		local ph_item = {x = 0, y = 0, w = BaseCell.SIZE, h = BaseCell.SIZE,}
		local parent = self.node_t_list["layout_escort"].node
		local item_render = ActBaseCell
		local line_dis = ph_item.w + 2
		local direction = ScrollDir.Horizontal -- 滑动方向-横向
		local grid_scroll = GridScroll.New()
		grid_scroll:Create(ph.x, ph.y, ph.w, ph.h, 1, line_dis, item_render, direction, false, ph_item)
		parent:addChild(grid_scroll:GetView(), 99)
		self.award_list[i] = grid_scroll
	end

	self:AddObj("award_list")
end

--打开时显示信息
function EscortView:SetCurInfoTexts(info_t)
	local escortCarCfg = EscortData.Instance:GetEscortCfg()
	local awards_t = EscortData.Instance:GetOtherAwardsCfg()
	local qual = tonumber(info_t[EscortView.Enum.Quality])
	local refre_times = tonumber(info_t[EscortView.Enum.RefreTimes])
	local is_double = tonumber(info_t[EscortView.Enum.IsDouble])
	if refre_times > escortCarCfg.maxRefresh then
		refre_times = escortCarCfg.maxRefresh
	end
	self.node_t_list["lbl_car_level"].node:setString(Language.Escort.EscortLv[qual])
	self.node_t_list["lbl_free_times"].node:setString(string.format(Language.Escort.Times, escortCarCfg.maxRefresh - refre_times))
	self.node_t_list["lbl_state"].node:setString(Language.Escort.IsDoubleTime[is_double])
	self.node_t_list["lbl_escort_times"].node:setString(string.format(Language.Escort.Times, tonumber(info_t[EscortView.Enum.EscortTimes])))
	self.node_t_list["lbl_insure_escort"].node:setString(Language.Escort.InsureEscort)
end

function EscortView:SetEscortTokenNum()
	local escort_token_id = EscortData.Instance:GetEscortCfg().tYBL.id
	local token_num = BagData.Instance:GetItemNumInBagById(escort_token_id)
	self.node_t_list["lbl_consume"].node:setString(string.format(Language.Escort.RefreCost, token_num))
end

function EscortView:RegisterAllEvents()
	XUI.AddClickEventListener(self.node_t_list["btn_help"].node, BindTool.Bind(self.OnInterpClicked, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_re"].node, BindTool.Bind(self.OnFreshQualityClicked, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_up"].node, BindTool.Bind(self.OnInsureEscortClicked, self), true)
	XUI.AddClickEventListener(self.node_t_list["btn_common"].node, BindTool.Bind(self.OnNormalEscortClicked, self), true)

end

--说明(?)按钮
function EscortView:OnInterpClicked()
	DescTip.Instance:SetContent(Language.Escort.DetailContent, Language.Escort.DetailTitle)
end

-- 购买令牌
function EscortView:OnBuyTokenClicked()
	ViewManager.Instance:OpenViewByDef(ViewDef.QuickBuy)
	ViewManager.Instance:FlushViewByDef(ViewDef.QuickBuy, 0, "param", {EscortData.Instance:GetEscortCfg().tYBL.id})
end

-- 刷新品质
function EscortView:OnFreshQualityClicked()
	EscortCtrl.RefreEscortCarReq(0, 0)
end

-- 保险护送
function EscortView:OnInsureEscortClicked()
	self.is_in_open = ActivityData.IsSomeActOpenNow(DAILY_ACTIVITY_TYPE.YA_SONG)
	if not self.is_in_open then
		if EscortCtrl.Instance.notDoubleEscConfDlg2 then
			EscortCtrl.Instance.notDoubleEscConfDlg2:Open()
		end
	else
		self:OpenConfirmInsureEscDlg()
	end
end

--确定保险护送
function EscortView:ConfirmInsureClicked()
	EscortCtrl.StartEscortingReq(1)
end

--打开确定保险护送弹窗
function EscortView:OpenConfirmInsureEscDlg()
	if self.confirmDlg then
		self.confirmDlg:Open()
	end
end

-- 普通护送
function EscortView:OnNormalEscortClicked()
	self.is_in_open = ActivityData.IsSomeActOpenNow(DAILY_ACTIVITY_TYPE.YA_SONG)
	if not self.is_in_open then
		if EscortCtrl.Instance.notDoubleEscConfDlg1 then
			if not EscortCtrl.Instance.notDoubleEscConfDlg1:GetIsNolongerTips() then
				EscortCtrl.Instance.notDoubleEscConfDlg1:Open()
			else
				EscortCtrl.StartEscortingReq(0)
			end
		end
	else
		EscortCtrl.StartEscortingReq(0)
	end
end

function EscortView:OnOnekeyLinkClicked()
	if self.onekeyTopDlg then
		self.onekeyTopDlg:Open()
	end
end

function EscortView:OnekeyToTopLvReq()
	EscortCtrl.RefreEscortCarReq(1, 0)
end

--选中特效
function EscortView:ChosenEffect(index)
	if type(index) == "number" then
		if index > 4 or index < 1 then 
			index = 1
		end
	else
		index = 1
	end
	if index == self.index then return end -- 镖车品质未改变时跳出
	self.index = index

	local node_cfg = self.node_t_list["img_car_" .. index]
	if not node_cfg then return end
	local p_x, p_y = node_cfg.node:getPosition()
	local size = node_cfg.node:getContentSize()
	if not self.chosen_ef then
		self.chosen_ef = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_109"), true)
		self.node_t_list["layout_escort"].node:addChild(self.chosen_ef, 999)
	end
	self.chosen_ef:setPosition(p_x, p_y)
	--未被选中的设为灰色
	for i=1,4 do
		local bool = index ~= i
		local color = bool and COLOR3B.GRAY or COLOR3B.YELLOW
		self.node_t_list["img_car_" .. i].node:setGrey(bool)
		self.node_t_list["lbl_1" .. i].node:setColor(color)
	end
end