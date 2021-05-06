local CWelfareView = class("CWelfareView", CViewBase)

function CWelfareView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Welfare/WelfareView.prefab", cb)
	-- self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
	self.m_IsAlwaysShow = true
end

function CWelfareView.OnCreateView(self)
	self.m_CloseBtn = self:NewUI(1, CButton)
	self.m_BtnGrid = self:NewUI(2, CGrid)
	self.m_BtnBox = self:NewUI(3, CBox)
	self.m_SecondTestPage = self:NewPage(4, CSecondTestPage)
	self.m_DailySignPage = self:NewPage(5, CDailySignPage)
	self.m_RechargeWelfarePage = self:NewPage(6, CRechargeWelfarePage)
	self.m_TotalRechargePage = self:NewPage(7, CTotalRechargePage)
	self.m_ZhaoMuBaoLiuPage = self:NewPage(8, CZhaoMuBaoLiuPage)
	self.m_SevenDayTargetPage = self:NewPage(9, CSevenDayTargetPage)
	self.m_RewardBackPage = self:NewPage(10, CRewardBackPage)
	self.m_CzjjPage = self:NewPage(11, CCzjjPage)
	self.m_YueKaPage = self:NewPage(12, CWelfareYueKaPage)
	self.m_FreeEnergyPage = self:NewPage(13, CFreeEnergyPage)
	self.m_CodeExchagePage = self:NewPage(14, CCodeExchagePage)
	self.m_ChargeBackPage = self:NewPage(15, CChargeBackPage)
	self.m_CostSavePage = self:NewPage(16, CCostSavePage)
	self.m_TitleSpr = self:NewUI(17, CSprite)
	self.m_LimitRankWelfarePage = self:NewPage(18, CLimitRankWelfarePowerPage)
	self.m_LimitRankWelfarePartnerPage = self:NewPage(19, CLimitRankWelfarePartnerPage)
	self.m_QQVipPage = self:NewPage(20, CQQVipPage)
	self:InitContent()
end

function CWelfareView.InitBtnData(self)
	--sortId用于界面顺序,id对应welfaredata.WelfareControl的id
	self.m_BtnData = {
		{sortId = 5, id = define.Welfare.ID.SecondTest, page = self.m_SecondTestPage, unSelectName = "pic_ceshifuli_weixuanzhong", selectName = "pic_ceshifuli_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsSecondTestNeedRedDot"), isTestWelfare = true},
		{sortId = 6, id = define.Welfare.ID.DailySign, page = self.m_DailySignPage, unSelectName = "pic_meiriqiandao_weixuanzhong", selectName = "pic_meiriqiandao_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsDailySignRedDot")},
		{sortId = 7, id = define.Welfare.ID.RechargeWelfare, page = self.m_RechargeWelfarePage, unSelectName = "pic_chongzhifanli_weixuanzhong", selectName = "pic_chongzhifanli_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsRechargeNeedRedDot"), isTestWelfare = true},
			-- [4] = {id = define.Welfare.ID.TotalRecharge, page = self.m_TotalRechargePage, unSelectName = "pic_leijijiangli_weixuanzhong", selectName = "pic_leijijiangli_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsTotalRechargeNeedRedDot"), openFunc = function() return false end},
		{sortId = 8, id = define.Welfare.ID.ZhaoMuBaoLiu, page = self.m_ZhaoMuBaoLiuPage, unSelectName = "pic_zhaomubaoliu_weixuanzhong", selectName = "pic_zhaomubaoliu_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsZhaoMuBaoLiuNeedRedDot")},
		{sortId = 3, id = define.Welfare.ID.SevenDayTarget, page = self.m_SevenDayTargetPage, unSelectName = "pic_qirimubiao_weixuanzhong", selectName = "pic_qirimubiao_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsSevenDayTargetRedDot"), openFunc = callback(g_WelfareCtrl, "IsOpenSevenDayTarget")},
		{sortId = 999, id = define.Welfare.ID.RewardBack, page = self.m_RewardBackPage, unSelectName = "pic_jianglizhaohui_weixuanzhong", selectName = "pic_jianglizhaohui_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsRewardBackRedDot"), openFunc = callback(g_WelfareCtrl, "IsOpenRewardBack")},
		{sortId = 2, id = define.Welfare.ID.Czjj, page = self.m_CzjjPage, unSelectName = "pic_chengzhangjijin_weixuanzhong", selectName = "pic_chengzhangjijin_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsCzjjRedDot"), 
			openFunc = function() 
				do return not g_WelfareCtrl:IsCzjjFinish() end
			end,
		},
		{sortId = 997, id = define.Welfare.ID.CostSave, page = self.m_CostSavePage, unSelectName = "pic_jianglizhaohui_weixuanzhong", selectName = "pic_jianglizhaohui_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsCostSaveRedDot"), openFunc = callback(g_WelfareCtrl, "IsOpenCostSave")},
		{sortId = 998, id = define.Welfare.ID.ChargeBack, page = self.m_ChargeBackPage, unSelectName = "pic_jianglizhaohui_weixuanzhong", selectName = "pic_jianglizhaohui_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsChargeBackRedDot"), openFunc = callback(g_WelfareCtrl, "IsOpenChargeBack")},
		{sortId = 1, id = define.Welfare.ID.Yk, page = self.m_YueKaPage, unSelectName = "pic_chaozhiyueka_weixuanzhong", selectName = "pic_chaozhiyueka_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsYueKaRedDot")},
		{sortId = 4, id = define.Welfare.ID.FreeEnergy, page = self.m_FreeEnergyPage, unSelectName = "pic_jianglizhaohui_weixuanzhong", selectName = "pic_jianglizhaohui_xuanzhong", checkRedFunc = callback(g_WelfareCtrl, "IsFreeEnergyRedDot"), openFunc = callback(g_WelfareCtrl, "IsFreeEnergyOpen")},
		{sortId = 1000, id = define.Welfare.ID.CodeExchage, page = self.m_CodeExchagePage, unSelectName = "pic_jianglizhaohui_weixuanzhong", selectName = "pic_jianglizhaohui_xuanzhong", openFunc = callback(Utils, "IsYunYingOpen")},
		{sortId = 10, id = define.Welfare.ID.LimitRankWelfare, page = self.m_LimitRankWelfarePage, unSelectName = "pic_jianglizhaohui_weixuanzhong", selectName = "pic_jianglizhaohui_xuanzhong", isTestWelfare = true, openFunc = callback(g_WelfareCtrl, "IsRankBackOpen")},
		{sortId = 11, id = define.Welfare.ID.LimitRankPartnerWelfare, page = self.m_LimitRankWelfarePartnerPage, unSelectName = "pic_jianglizhaohui_weixuanzhong", selectName = "pic_jianglizhaohui_xuanzhong", isTestWelfare = true, openFunc = callback(g_WelfareCtrl, "IsRankBackOpen")},
		
		{sortId = 12, id = define.Welfare.ID.QQVipWelfare, page = self.m_QQVipPage, unSelectName = "pic_fuliqq_weixuanzhongqq", selectName = "pic_fuliqq_xuanzhongqq", isTestWelfare = false, openFunc = callback(g_WelfareCtrl, "IsOpenQQVip")},
	}
	local function sortFunc(v1, v2)
		return v1.sortId < v2.sortId
	end
	table.sort(self.m_BtnData, sortFunc)
end

function CWelfareView.InitBtns(self)
	self.m_BtnArr = {}
	self.m_BtnDic = {}
	local dWelfareControl = data.welfaredata.WelfareControl
	
	for i,v in ipairs(self.m_BtnData) do
		local oBtnBox = self:CreateBtn()
		self.m_BtnArr[i] = oBtnBox
		self.m_BtnDic[v.id] = oBtnBox
		v.name = dWelfareControl[v.id].name
		oBtnBox:SetData(v)
		oBtnBox.m_IgnoreCheckEffect = true
		local open = false
		open = (dWelfareControl[v.id].open == 1)
		if open and (dWelfareControl[v.id].grade > 0) then
			open = (g_AttrCtrl.grade >= dWelfareControl[v.id].grade)
		end
		if open and oBtnBox.m_Data.openFunc then
			open = oBtnBox.m_Data.openFunc()
		end
		if open then
			open = not v.isTestWelfare   
		end
		oBtnBox:SetActive(open)
	end
	
	self.m_BtnBox:SetActive(false)
end

function CWelfareView.InitContent(self)
	self:InitBtnData()
	self:InitBtns()
	g_WelfareCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnWelfareEvnet"))
	self.m_SecondTestPage.m_ParentView = self
	self.m_CurrentBtn = nil
	self.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	
	self:RefreshRedDot()
end

function CWelfareView.ShowDefaultPage(self)
	for i,v in ipairs(self.m_BtnArr) do
		if v:GetActive() then
			self:ForceSelect(v.m_Data.id)
			break
		end
	end
end

--删测福利
function CWelfareView.ShowTestDefalutPage(self)
	self.m_TitleSpr:SetSpriteName("text_shancefuli")
	local dWelfareControl = data.welfaredata.WelfareControl
	for i,v in ipairs(self.m_BtnArr) do
		local open = false
		open = (dWelfareControl[v.m_Data.id].open == 1)
		if open and (dWelfareControl[v.m_Data.id].grade > 0) then
			open = (g_AttrCtrl.grade >= dWelfareControl[v.m_Data.id].grade)
		end
		if open and v.m_Data.openFunc then
			open = v.m_Data.openFunc()
		end
		if open then
			open = v.m_Data.isTestWelfare   
		end
		v:SetActive(open)
	end	
	for i,v in ipairs(self.m_BtnArr) do
		if v:GetActive() then
			self:ForceSelect(v.m_Data.id)
			break
		end
	end
end

function CWelfareView.ForceSelect(self, id)
	local oBtnBox = self.m_BtnDic[id]
	self:OnSelectPage(oBtnBox)
end

function CWelfareView.CreateBtn(self)
	local oBtnBox = self.m_BtnBox:Clone()
	oBtnBox.m_Btn = oBtnBox:NewUI(1, CButton)
	oBtnBox.m_OnSelectMark = oBtnBox:NewUI(2, CBox)
	oBtnBox.m_OnSelectLabel = oBtnBox:NewUI(3, CLabel)
	oBtnBox.m_UnSelectSprite = oBtnBox:NewUI(4, CSprite)
	oBtnBox.m_SelectSprite = oBtnBox:NewUI(5, CSprite)

	oBtnBox.m_OnSelectMark:SetActive(false)
	self.m_BtnGrid:AddChild(oBtnBox)
	oBtnBox.m_Btn:AddUIEvent("click", callback(self, "OnSelectPage", oBtnBox))

	function oBtnBox.SetData(self, oData)
		oBtnBox.m_Data = oData
		oBtnBox.m_Btn:SetText(oData.name)
		oBtnBox.m_OnSelectLabel:SetText(oData.name)
		oBtnBox.m_UnSelectSprite:SetSpriteName(oData.unSelectName)
		oBtnBox.m_SelectSprite:SetSpriteName(oData.selectName)
	end
	function oBtnBox.SetSelect(self, bValue)
		oBtnBox.m_OnSelectMark:SetActive(bValue)
		oBtnBox.m_Btn:SetActive(not bValue)
	end

	return oBtnBox
end

function CWelfareView.OnSelectPage(self, oBtnBox)
	if oBtnBox.m_Data.page == self.m_SecondTestPage then
		netfuli.C2GSGetBackPartnerInfo()
		return		
		-- IOTools.SetRoleData("welfare_secondtest", false)
		-- IOTools.SetRoleData("welfare_secondtest_first", true)
		-- if g_WelfareCtrl.m_SecondTest == 1 then
		-- 	IOTools.SetRoleData("welfare_secondtest_finish", true)
		-- end
		-- g_WelfareCtrl:OnEvent(define.Welfare.Event.OnChangeSecondTest)
	elseif oBtnBox.m_Data.page == self.m_DailySignPage then
		g_WelfareCtrl:OnEvent(define.Welfare.Event.OnDailySign)
	elseif oBtnBox.m_Data.page == self.m_TotalRechargePage then
		IOTools.SetRoleData("welfare_totalRecharge_first", true)
		g_WelfareCtrl:OnEvent(define.Welfare.Event.OnHistoryRecharge)
	elseif oBtnBox.m_Data.page == self.m_RechargeWelfarePage then
		netfuli.C2GSOpenChargeBackUI()
		return
		-- IOTools.SetRoleData("welfare_RechargeWelfare_first", true)
		-- g_WelfareCtrl:OnEvent(define.Welfare.Event.OnRechargeWelfare)
	elseif oBtnBox.m_Data.page == self.m_ZhaoMuBaoLiuPage then
		netfuli.C2GSGetBackPartnerInfo()
		return
	elseif oBtnBox.m_Data.page == self.m_SevenDayTargetPage then
		netachieve.C2GSOpenSevenDayMain(math.min(g_WelfareCtrl:GetSevenDayServerDay() + 1, 7))
		--return
	elseif oBtnBox.m_Data.page == self.m_YueKaPage then
		g_WelfareCtrl.m_YuekaRedDot = false
		g_WelfareCtrl:OnEvent(define.Welfare.Event.RefreshRedDot)
	end
	self:ChangeBtn(oBtnBox)
end

function CWelfareView.ChangeBtn(self, oBtnBox)
	if self.m_CurrentBtn then
		self.m_CurrentBtn:SetSelect(false)
	end
	self.m_CurrentBtn = oBtnBox
	self.m_CurrentBtn:SetSelect(true)
	self:ShowSubPage(oBtnBox.m_Data.page)
end

function CWelfareView.RefreshRedDot(self)
	for i,v in ipairs(self.m_BtnArr) do
		if v.m_Data.checkRedFunc and v.m_Data.checkRedFunc() then
			v:AddEffect("RedDot")
		else
			v:DelEffect("RedDot")
		end
	end
end

function CWelfareView.OnWelfareEvnet(self, oCtrl)
	if oCtrl.m_EventID == define.Welfare.Event.OnBackPartnerInfo then
		self:ChangeBtn(self.m_BtnDic[define.Welfare.ID.SecondTest])
	elseif oCtrl.m_EventID == define.Welfare.Event.UpdateRechargeWelfare then
		self:ChangeBtn(self.m_BtnDic[define.Welfare.ID.RechargeWelfare])
		IOTools.SetRoleData("welfare_RechargeWelfare_first", true)
		g_WelfareCtrl:OnEvent(define.Welfare.Event.OnRechargeWelfare)
	elseif oCtrl.m_EventID == define.Welfare.Event.OnSevenDayTarget then
		if g_WelfareCtrl:IsOpenSevenDayTarget() then
			self.m_BtnDic[define.Welfare.ID.SevenDayTarget]:SetActive(true)
			self.m_BtnGrid:Reposition()
			self:ChangeBtn(self.m_BtnDic[define.Welfare.ID.SevenDayTarget])
		else
			if self.m_CurrentBtn == self.m_BtnDic[define.Welfare.ID.SevenDayTarget] then
				self:CloseView()
			else
				self.m_BtnDic[define.Welfare.ID.SevenDayTarget]:SetActive(false)
				self.m_BtnGrid:Reposition()
			end
		end
	elseif oCtrl.m_EventID == define.Welfare.Event.OnFreeEnergyZhongwu or
		oCtrl.m_EventID == define.Welfare.Event.OnFreeEnergyWanshang or
		oCtrl.m_EventID == define.Welfare.Event.OnFreeEnergyClose then
		self.m_BtnDic[define.Welfare.ID.FreeEnergy]:SetActive(g_WelfareCtrl:IsFreeEnergyOpen())
		self.m_BtnGrid:Reposition()
	end
	self:RefreshRedDot()
end

return CWelfareView