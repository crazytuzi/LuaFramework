local CAttrMainPage = class("CAttrMainPage", CPageBase)

function CAttrMainPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CAttrMainPage.OnInitPage(self)
	self.m_ActorTexture = self:NewUI(1, CActorTexture)
	self.m_NameLabel = self:NewUI(2, CLabel)
	self.m_NameChangeBtn = self:NewUI(3, CButton)
	self.m_IdLabel = self:NewUI(4, CLabel)
	self.m_EquipmentGrid = self:NewUI(5, CGrid)
	self.m_EquipmentBox = self:NewUI(6, CAttrEquipItemBox)
	self.m_AttrGrid = self:NewUI(7, CGrid)
	self.m_TitleChangeBtn = self:NewUI(8, CButton)
	self.m_BadgeGrid = self:NewUI(9, CGrid)
	self.m_BadgeBox = self:NewUI(10, CBox)
	self.m_ShareBtn = self:NewUI(11, CButton)
	self.m_CommentBtn = self:NewUI(12, CButton)
	self.m_SchoolIcon = self:NewUI(13, CSprite)
	self.m_ScoreLabel = self:NewUI(14, CLabel)
	self.m_GradeLabel = self:NewUI(15, CLabel)
	self.m_MainBgTextrue = self:NewUI(16, CTexture)
	self.m_TipsBtn = self:NewUI(17, CButton)
	self.m_SkinBtn = self:NewUI(18, CButton)

	self.m_DelayTimer = nil
	self:InitContent()
end


function CAttrMainPage.DelayInitPage(self)
	self.m_ActorTexture:ChangeShape(g_AttrCtrl.model_info.shape, g_AttrCtrl.model_info)
end

function CAttrMainPage.InitContent(self)
	self.m_NameChangeBtn:AddUIEvent("click", callback(self, "OnChangeName"))
	self.m_TitleChangeBtn:AddUIEvent("click", callback(self, "OnChangeTitle"))
	self.m_ShareBtn:AddUIEvent("click", callback(self, "OnShareGame"))
	self.m_CommentBtn:AddUIEvent("click", callback(self, "OnCommentGame"))
	self.m_ActorTexture:AddUIEvent("click", callback(self.m_ActorTexture, "OnClick"))
	-- self.m_TipsBtn:AddHelpTipClick("attr_main")
	self.m_TipsBtn:AddUIEvent("click", callback(self, "ShowTips"))
	self.m_SkinBtn:AddUIEvent("click", callback(self, "OnSkinBtn")) 
	local tSchoolData = data.schooldata.DATA
	self.m_SchoolIcon:SetSpriteName(tostring(tSchoolData[g_AttrCtrl.school].icon))
	self.m_IdLabel:SetText("ID: "..tostring(g_AttrCtrl.pid))
	-- self.m_MainBgTextrue:SetAsyncLoad(false)
	local path = string.format("Texture/Common/bg_juese_%d.png", g_AttrCtrl.model_info.shape)
	self.m_MainBgTextrue:LoadPath(path)
	self:InitAttrGrid()
	self:RefreshAttr()
	self.m_ShareBtn:SetActive(false)
	self.m_BadgeBox:SetActive(false)
	self:InitBadgeGrid()

	self:InitEquipmentGrid()

	g_AttrCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEvent"))
	g_ItemCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnAttrEquipMentEvent"))
	g_PartnerCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnPartnerEvent"))

	self.m_SkinBtn.m_IgnoreCheckEffect = true
	self:CheckSkinRedDot()
end

function CAttrMainPage.ShowTips(self)
	if g_AttrCtrl.grade <= tonumber(data.globaldata.GLOBAL.ignore_expadd_grade.value) then
		CHelpView:ShowView(function (oView)
			oView:ShowHelp("attr_main")
		end)
	else
		CServerLvHelpView:ShowView()
	end
end

function CAttrMainPage.OnAttrEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Attr.Event.UpdateSkin then
		self:CheckSkinRedDot()
	end
	if self.m_DelayTimer then
		Utils.DelTimer(self.m_DelayTimer)
		self.m_DelayTimer = nil
	end
	self.m_DelayTimer = Utils.AddTimer(callback(self, "RefreshAttr"), 0.1, 0.1) 
end

function CAttrMainPage.OnPartnerEvent( self, oCtrl )
	self.m_ScoreLabel:SetText(g_AttrCtrl:GetTotalPower())
	self:SetPowerGrid()
end

function CAttrMainPage.OnAttrEquipMentEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Item.Event.RefreshEquip then
		local gridList = self.m_EquipmentGrid:GetChildList()
		for i,v in ipairs(gridList) do
			v:SetMainEquipItem(g_ItemCtrl:GetEquipedByPos(i), i)
		end
		self:RefreshAttr()
	end
end

function CAttrMainPage.InitAttrGrid(self)
	local t = {
		{k = "职业", v = "school"},
		{k = "等级", v = "grade", unhavekey = true,},
		{k = "称谓", v = "title_info"},
		{k = "公会", v = "orgname"},
		{k = "气血", v = "max_hp"},
		{k = "速度", v = "speed"},
		{k = "攻击", v = "attack"},
		{k = "防御", v = "defense"},
		{k = "暴击", v = "critical_ratio"},
		{k = "抗暴", v = "res_critical_ratio"},
		{k = "暴击伤害",v = "critical_damage"},
		{k = "治疗暴击",v = "cure_critical_ratio"},
		{k = "异常命中",v = "abnormal_attr_ratio"},
		{k = "异常抵抗", v = "res_abnormal_ratio"},
	}

	local function init(obj, idx)
		local oBox = CBox.New(obj)
		if oBox:GetName() ~= "Badge" then
			oBox.m_NameLabel = oBox:NewUI(1, CLabel)
			oBox.m_AttrLabel = oBox:NewUI(2, CLabel)
			local info = t[idx]
			if info then
				if info.unhavekey ~= nil then
					oBox.m_NameLabel:SetText(info.k)
				end
				oBox.m_AttrKey = info.v
				oBox.m_AttrValue = info.value
			end
		end
		return oBox
	end
	self.m_AttrGrid:InitChild(init)
end

function CAttrMainPage.RefreshAttr(self)
	self.m_ActorTexture:ChangeShape(g_AttrCtrl.model_info.shape, g_AttrCtrl.model_info)
	self.m_NameLabel:SetText(g_AttrCtrl.name)
	self.m_ScoreLabel:SetText(g_AttrCtrl:GetTotalPower())
	self:SetPowerGrid()
	self.m_GradeLabel:SetText(string.format("%d", g_AttrCtrl.grade))
	for i, oBox in ipairs(self.m_AttrGrid:GetChildList()) do
		if oBox:GetName() ~= "Badge" then
			if oBox.m_AttrValue ~= nil then
				oBox.m_AttrLabel:SetText(oBox.m_AttrValue)
			else
				local v = g_AttrCtrl[oBox.m_AttrKey]
				if oBox.m_AttrKey == "school" then
					oBox.m_AttrLabel:SetText(g_AttrCtrl:GetSchoolStr(v))
				elseif string.find(oBox.m_AttrKey, "ratio") or oBox.m_AttrKey == "critical_damage" then
					--保留1位小数
					v = math.floor(v / 10)
					local value = v / 10
					oBox.m_AttrLabel:SetText(tostring(value).."%")
				elseif oBox.m_AttrKey == "title_info" then
					oBox.m_AttrLabel:SetText(g_TitleCtrl:GetTitleName(v))
				elseif oBox.m_AttrKey == "orgname" then
					local str = tostring(v)
					if str ~= "" then
						oBox.m_AttrLabel:SetText(tostring(v).."公会")
					else
						oBox.m_AttrLabel:SetText(tostring(v))
					end
				else
					oBox.m_AttrLabel:SetText(tostring(v))
				end
			end
		end
	end
end

function CAttrMainPage.InitBadgeGrid(self)
	self.m_BadgeGrid:Clear()
	for i = 1 , 5 do 
		local badgeBox = self.m_BadgeBox:Clone()
		badgeBox:SetActive(true)
		self.m_BadgeGrid:AddChild(badgeBox)
	end
end

function CAttrMainPage.InitEquipmentGrid(self)
	self.m_EquipmentGrid:InitChild(function (obj, index)
		local oBox = CAttrEquipItemBox.New(obj)
		local equipData = g_ItemCtrl:GetEquipedByPos(index)
		oBox:SetGroup(self.m_EquipmentGrid:GetInstanceID())
		oBox:SetMainEquipItem(equipData , index)
		return oBox
	end)
end

function CAttrMainPage.ShowCardView(self)
	print("showCardView")
	CCardView:ShowView()
end

function CAttrMainPage.OnShareGame(self)
	g_NotifyCtrl:FloatMsg("分享游戏")
end

function CAttrMainPage.OnCommentGame(self)
	g_NotifyCtrl:FloatMsg("评论游戏")
end

function CAttrMainPage.OnChangeTitle(self)
	g_TitleCtrl:ShowTitleView()
end

function CAttrMainPage.OnChangeName(self)
	CAttrChangeNameView:ShowView()
end

function CAttrMainPage.OnClickQuitGame(self)
	Utils.QuitGame()
end

function CAttrMainPage.OnSkinBtn(self)
	CAttrRoleSkinView:ShowView()
end

--属性界面，特别版才显示
function CAttrMainPage.SetPowerGrid(self)
	if g_AttrCtrl.m_AttrMainLayer then
		self.m_ScoreBgSprite = self:NewUI(16, CSprite)
		self.m_ScoreGrid = self:NewUI(17, CGrid)
		self.m_ScoreSprite = self:NewUI(18, CSprite)
		self.m_ScoreSprite:SetActive(false)
		local power = tostring(g_AttrCtrl:GetTotalPower())
		local t = {}
		local i = 1
		for str in string.gmatch(power, "%d") do
			t[i] = str
			i = i + 1
		end
		self.m_ScoreGrid:Clear()
		for k = 1, #t do 
			local oSpr = self.m_ScoreSprite:Clone()
			oSpr:SetActive(true)
			oSpr:SetSpriteName(string.format("text_wenzi_0%d", t[k]))
			self.m_ScoreGrid:AddChild(oSpr)
		end
		local w, _  = self.m_ScoreGrid:GetCellSize()
		self.m_ScoreBgSprite:SetWidth(self.m_ScoreBgSprite:GetWidth() + w * #t)
	end
end

function CAttrMainPage.CheckSkinRedDot(self)
	local redDot = g_AttrCtrl:GetSkinRedDot()
	if redDot and #redDot > 0 then
		self.m_SkinBtn:AddEffect("RedDot")
	else
		self.m_SkinBtn:DelEffect("RedDot")
	end
end

return CAttrMainPage
