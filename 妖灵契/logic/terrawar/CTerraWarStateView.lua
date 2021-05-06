local CTerraWarStateView = class("CTerraWarStateView", CViewBase)

function CTerraWarStateView.ctor(self, cb)
	CViewBase.ctor(self, "UI/TerraWar/TerraWarStateView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_BehindStrike = true
	self.m_ExtendClose = "Shelter"
end

function CTerraWarStateView.OnCreateView(self)
	self.m_HasPart = self:NewUI(1, CBox)
	self.m_NotPart = self:NewUI(2, CBox)
	self.m_BtnClone = self:NewUI(3, CButton)
	self.m_BtnClone:SetActive(false)
	self:InitContent()
end

function CTerraWarStateView.InitContent(self)
	self.m_BtnType = {
		Recall = 1,
		WatchWar = 2,
		Help = 3,
		Attack = 4,
	}
	self.m_BtnInfo = {
		[self.m_BtnType.Recall] = {txt = "召回", func = "OnRecallBtn", },
		[self.m_BtnType.WatchWar] = {txt = "观战", func = "OnWatchWarBtn", },
		[self.m_BtnType.Help] = {txt = "支援", func = "OnHelpBtn", },
		[self.m_BtnType.Attack] = {txt = "攻击", func = "OnAttackBtn", },
	}
end

function CTerraWarStateView.OnBuyLingliBtn(self, oBtn)
	local lingli_cost = tonumber(data.globaldata.GLOBAL.lingli_cost.value)
	local cost = lingli_cost
	local interval = tonumber(data.globaldata.GLOBAL.lingli_cost_interval.value)
	if self.m_BuyTimes > 0 then
		cost = lingli_cost + interval * self.m_BuyTimes
	end
	cost = math.min(cost, 50)
	local lingli_pergive = data.globaldata.GLOBAL.lingli_pergive.value
	if cost > g_AttrCtrl.goldcoin then
		g_NotifyCtrl:FloatMsg("您的水晶不足")
		g_SdkCtrl:ShowPayView()
	else
		local args = 
			{
				msg = string.format("是否花费%s水晶购买%s点灵力", cost, lingli_pergive),
				okCallback = function ( )
					nethuodong.C2GSBuyLingli(1, self.m_Terraid)
					end,
				okStr = "确定",
				cancelStr = "取消",
			}
		g_WindowTipCtrl:SetWindowConfirm(args)
	end
end

function CTerraWarStateView.InitView(self, terrainfo, lingli_info)
	self.m_Terraid = terrainfo.id
	self.m_BuyTimes = lingli_info and lingli_info.buy_times or 0
	self.m_NotPart:SetActive(false)
	self.m_HasPart:SetActive(false)
	self:InitNotPart()
	self:InitHasPart()
	self:RefreshView(terrainfo, lingli_info)
end

function CTerraWarStateView.InitNotPart(self)
	if not self.m_NotPart.m_Init then
		self.m_NotPart.m_CloseBtn = self.m_NotPart:NewUI(1, CButton)
		self.m_NotPart.m_StateLabel = self.m_NotPart:NewUI(2, CLabel)
		self.m_NotPart.m_LingLiLabel = self.m_NotPart:NewUI(3, CLabel)
		self.m_NotPart.m_BuyLingliBtn = self.m_NotPart:NewUI(4, CButton)
		self.m_NotPart.m_BtnGrid = self.m_NotPart:NewUI(5, CGrid)
		self.m_NotPart.m_Init = true
	end

	self.m_NotPart.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_NotPart.m_BuyLingliBtn:AddUIEvent("click", callback(self, "OnBuyLingliBtn"))
end

function CTerraWarStateView.InitHasPart(self)
	if not self.m_HasPart.m_Init then
		self.m_HasPart.m_CloseBtn = self.m_HasPart:NewUI(1, CButton)
		self.m_HasPart.m_NameLabel = self.m_HasPart:NewUI(2, CLabel)
		self.m_HasPart.m_StateLabel = self.m_HasPart:NewUI(3, CLabel)
		self.m_HasPart.m_ScoreLabel = self.m_HasPart:NewUI(4, CLabel)
		self.m_HasPart.m_WaitLabel = self.m_HasPart:NewUI(5, CLabel)
		self.m_HasPart.m_LingLiLabel = self.m_HasPart:NewUI(6, CLabel)
		self.m_HasPart.m_BuyLingliBtn = self.m_HasPart:NewUI(7, CButton)
		self.m_HasPart.m_PartnerGrid = self.m_HasPart:NewUI(8, CGrid)
		self.m_HasPart.m_PartnerBox = self.m_HasPart:NewUI(9, CBox)
		self.m_HasPart.m_BtnGrid = self.m_HasPart:NewUI(10, CGrid)
		self.m_HasPart.m_Init = true
	end

	self.m_HasPart.m_PartnerBox:SetActive(false)
	self.m_HasPart.m_CloseBtn:AddUIEvent("click", callback(self, "OnClose"))
	self.m_HasPart.m_BuyLingliBtn:AddUIEvent("click", callback(self, "OnBuyLingliBtn"))
end

function CTerraWarStateView.RefreshView(self, terrainfo, lingli_info)
	if not terrainfo.playername or terrainfo.playername == "" then
		--无占领
		self.m_NotPart:SetActive(true)
	else
		--有占领
		self.m_HasPart:SetActive(true)
		local txt = ""
		if terrainfo.orgname and terrainfo.orgname ~= "" then
			txt = string.format("领主：%s（%s）", terrainfo.playername, terrainfo.orgname)
		else
			txt = string.format("领主：%s", terrainfo.playername)
		end
		self.m_HasPart.m_NameLabel:SetText(txt)
		self.m_HasPart.m_ScoreLabel:SetText(string.format("累计积分：%s", terrainfo.orgscore))
		self.m_HasPart.m_WaitLabel:SetText(
			string.format("排队状态：支援方(%d/%d) VS 攻击方(%d/%d)", 
				math.min(terrainfo.help, 5), terrainfo.max_help,
				terrainfo.attack, terrainfo.max_attack))
	end
	self:InitStatus(terrainfo)
	self:InitLingli(lingli_info)
	self:InitBtbGrid(terrainfo)
	self:InitPartnerGrid(terrainfo)
end

function CTerraWarStateView.InitStatus(self, terrainfo)
	local tStatus = {
		[0] = "据点未占据",
		[1] = "战斗中",
		[2] = "保护中",
		[3] = "和平状态",
	}
	local status = terrainfo.status
	self.m_NotPart.m_StateLabel:SetText(string.format("据点状态：%s", tStatus[status]))
	self.m_HasPart.m_StateLabel:SetText(string.format("据点状态：%s", tStatus[status]))
	if status == define.Terrawar.status.Protect then
		if self.m_StatusTimer then
			Utils.DelTimer(self.m_StatusTimer)
			self.m_StatusTimer = nil
		end
		local time = terrainfo.times - g_TimeCtrl:GetTimeS()
		local function countdown()
			if Utils.IsNil(self) then
				return
			end
			if time >= 0 then
				self.m_HasPart.m_StateLabel:SetText(string.format("据点状态：%s (%s)", tStatus[status], g_TimeCtrl:GetLeftTime(time, true)))
				self.m_NotPart.m_StateLabel:SetText(string.format("据点状态：%s (%s)", tStatus[status], g_TimeCtrl:GetLeftTime(time, true)))
				time = time - 1
				return true
			else
				printc("重新请求刷新界面->", self.m_Terraid)
				nethuodong.C2GSGetTerraInfo(self.m_Terraid)
			end
		end
		self.m_StatusTimer = Utils.AddTimer(countdown, 1, 0)
	end
end

function CTerraWarStateView.InitLingli(self, lingli_info)
	if self.m_LingliTimer then
		Utils.DelTimer(self.m_LingliTimer)
		self.m_LingliTimer = nil
	end
	if lingli_info.lingli < lingli_info.max_lingli then
		local time = lingli_info.lefttime
		local function countdown()
			if Utils.IsNil(self) then
				return
			end
			if time >= 0 then
				self.m_NotPart.m_LingLiLabel:SetText(string.format("我的灵力：%d/%d (%s)", lingli_info.lingli, lingli_info.max_lingli, g_TimeCtrl:GetLeftTime(time)))
				self.m_HasPart.m_LingLiLabel:SetText(string.format("我的灵力：%d/%d (%s)", lingli_info.lingli, lingli_info.max_lingli, g_TimeCtrl:GetLeftTime(time)))
				time = time - 1
				return true
			else
				printc("重新请求刷新界面->", self.m_Terraid)
				nethuodong.C2GSGetTerraInfo(self.m_Terraid)
			end
		end
		self.m_LingliTimer = Utils.AddTimer(countdown, 1, 0)
	else
		self.m_NotPart.m_LingLiLabel:SetText(string.format("我的灵力：%d/%d", lingli_info.lingli, lingli_info.max_lingli))
		self.m_HasPart.m_LingLiLabel:SetText(string.format("我的灵力：%d/%d", lingli_info.lingli, lingli_info.max_lingli))
	end
end

function CTerraWarStateView.InitBtbGrid(self, terrainfo)
	self.m_NotPart.m_BtnGrid:Clear()
	self.m_HasPart.m_BtnGrid:Clear()
	local oBtn 
	if not terrainfo.playername or terrainfo.playername == "" then
		--无占领
		oBtn = self:CreateBtn(self.m_BtnType.Attack)
		self.m_NotPart.m_BtnGrid:AddChild(oBtn)
	elseif terrainfo.playername == g_AttrCtrl.name then
		--自己占领
		if terrainfo.status == define.Terrawar.status.Protect then
			--保护隐藏所有按钮
			--oBtn = self:CreateBtn(self.m_BtnType.Recall)
			--self.m_HasPart.m_BtnGrid:AddChild(oBtn)
		elseif terrainfo.status == define.Terrawar.status.Attack then
			oBtn = self:CreateBtn(self.m_BtnType.WatchWar)
			self.m_HasPart.m_BtnGrid:AddChild(oBtn)
			oBtn = self:CreateBtn(self.m_BtnType.Help)
			self.m_HasPart.m_BtnGrid:AddChild(oBtn)
		else
			oBtn = self:CreateBtn(self.m_BtnType.Recall)
			self.m_HasPart.m_BtnGrid:AddChild(oBtn)
		end
	elseif terrainfo.orgid == g_AttrCtrl.org_id then
		--同公会占领
		if terrainfo.status == define.Terrawar.status.Protect then
			--保护隐藏所有按钮
		elseif terrainfo.status == define.Terrawar.status.Attack then
			oBtn = self:CreateBtn(self.m_BtnType.WatchWar)
			self.m_HasPart.m_BtnGrid:AddChild(oBtn)
			oBtn = self:CreateBtn(self.m_BtnType.Help)
			self.m_HasPart.m_BtnGrid:AddChild(oBtn)
		end
	else
		--其他占领
		if terrainfo.status == define.Terrawar.status.Protect then
			--保护隐藏所有按钮
		elseif terrainfo.status == define.Terrawar.status.Attack then
			oBtn = self:CreateBtn(self.m_BtnType.WatchWar)
			self.m_HasPart.m_BtnGrid:AddChild(oBtn)
			oBtn = self:CreateBtn(self.m_BtnType.Attack)
			self.m_HasPart.m_BtnGrid:AddChild(oBtn)
		else
			oBtn = self:CreateBtn(self.m_BtnType.Attack)
			self.m_HasPart.m_BtnGrid:AddChild(oBtn)
		end
	end
end

function CTerraWarStateView.CreateBtn(self, idx)
	local oBtn = self.m_BtnClone:Clone()
	oBtn:SetActive(true)
	oBtn:SetText(self.m_BtnInfo[idx].txt)
	oBtn:AddUIEvent("click", callback(self, self.m_BtnInfo[idx].func))
	return oBtn
end

function CTerraWarStateView.OnWatchWarBtn(self, oBtn)
	printc("CTerraWarStateView.OnWatchWar")
	nethuodong.C2GSTerrawarOperate(self.m_Terraid, define.Terrawar.Operate.WatchWar, define.Terrawar.Next.GetTerraInfo)
end

function CTerraWarStateView.OnAttackBtn(self, oBtn)
	printc("CTerraWarStateView.OnAttack")
	nethuodong.C2GSTerrawarOperate(self.m_Terraid, define.Terrawar.Operate.Attack, define.Terrawar.Next.GetTerraInfo)
end

function CTerraWarStateView.OnRecallBtn(self, oBtn)
	printc("CTerraWarStateView.OnRecall")
	nethuodong.C2GSTerrawarOperate(self.m_Terraid, define.Terrawar.Operate.Recall, define.Terrawar.Next.GetTerraInfo)
end

function CTerraWarStateView.OnHelpBtn(self, oBtn)
	printc("CTerraWarStateView.OnHelp")
	nethuodong.C2GSTerrawarOperate(self.m_Terraid, define.Terrawar.Operate.Help, define.Terrawar.Next.GetTerraInfo)
end

function CTerraWarStateView.InitPartnerGrid(self, info)
	self.m_HasPart.m_PartnerGrid:Clear()
	for i,v in ipairs(info.partner_info) do
		local oPartnerBox = self:CreatePartnerBox()
		self:SetPartnerBoxData(oPartnerBox, v)
		self.m_HasPart.m_PartnerGrid:AddChild(oPartnerBox)
	end
	self.m_HasPart.m_PartnerGrid:Reposition()
end

function CTerraWarStateView.CreatePartnerBox(self, oBox)
	local oPartnerBox = self.m_HasPart.m_PartnerBox:Clone()
	oPartnerBox:SetActive(true)
	oPartnerBox.m_BoderSpr = oPartnerBox:NewUI(1, CSprite)
	oPartnerBox.m_Icon = oPartnerBox:NewUI(2, CSprite)
	oPartnerBox.m_StarGrid = oPartnerBox:NewUI(3, CGrid)
	oPartnerBox.m_StarSpr = oPartnerBox:NewUI(4, CSprite)
	oPartnerBox.m_AwakeSpr = oPartnerBox:NewUI(5, CSprite)
	oPartnerBox.m_GradeLabel = oPartnerBox:NewUI(6, CLabel)
	oPartnerBox.m_NameLabel = oPartnerBox:NewUI(7, CLabel)
	oPartnerBox.m_HPSlider = oPartnerBox:NewUI(8, CSlider)

	oPartnerBox.m_StarSpr:SetActive(false)
	oPartnerBox.m_StarGrid:Clear()
	for i = 1, 5 do
		local oSpr = oPartnerBox.m_StarSpr:Clone()
		oSpr:SetActive(true)
		oPartnerBox.m_StarGrid:AddChild(oSpr)
	end
	oPartnerBox.m_StarGrid:Reposition()

	return oPartnerBox
end


function CTerraWarStateView.SetPartnerBoxData(self, oPartnerBox, dData)
	--[[
		self:UpdateShape(oPartner:GetValue("icon"))
		self:UpdateStar(oPartner:GetValue("star"))
		self:UpdateBorder(oPartner:GetValue("rare"))
		self:UpdateAwake(oPartner:GetValue("awake"))
		self:UpdateGrade(oPartner:GetValue("grade"))
	]]
	local icon = dData.model_info.shape
	oPartnerBox.m_Icon:SpriteAvatar(icon)

	local star = dData.star
	for i, oSpr in ipairs(oPartnerBox.m_StarGrid:GetChildList()) do
		if star >= i then
			oSpr:SetSpriteName("pic_chouka_dianliang")
		else
			oSpr:SetSpriteName("pic_chouka_weidianliang")
		end
	end

	local rare = dData.rare
	local sSprite = oPartnerBox.m_BoderSpr:GetSpriteName()
	if string.startswith(sSprite, "bg_haoyoukuang_") then
		local filename = define.Partner.CardColor[rare] or "hui"
		oPartnerBox.m_BoderSpr:SetSpriteName("bg_haoyoukuang_"..filename.."se")
	elseif string.startswith(sSprite, "bg_huobankuang_") then
		oPartnerBox.m_BoderSpr:SetSpriteName(string.format("bg_huobankuang_da%d", rare))
	end

	local awake = dData.awake
	oPartnerBox.m_AwakeSpr:SetActive(awake == 1)

	local grade = dData.grade
	oPartnerBox.m_GradeLabel:SetText(string.format("%d", grade))

	local name = dData.name
	oPartnerBox.m_NameLabel:SetText(name)

	local hp = dData.hp
	local max_hp = dData.max_hp
	oPartnerBox.m_HPSlider:SetValue(hp/max_hp)
	oPartnerBox.m_HPSlider:SetSliderText(string.format("%d/%d", hp, max_hp))
end

function CTerraWarStateView.ExtendCloseView(self)
	if self.m_ExtendClose == false then
		self.m_ExtendClose = true
		return
	end
	self:CloseView()
end

return CTerraWarStateView