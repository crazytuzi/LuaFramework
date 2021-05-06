local CHouseBuffView = class("CHouseBuffView", CViewBase)

function CHouseBuffView.ctor(self, cb)
	CViewBase.ctor(self, "UI/House/HouseBuffView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	self.m_OpenEffect = "Scale"
end

function CHouseBuffView.OnCreateView(self)
	self.m_BuffBox1 = self:NewUI(1, CBox)
	self.m_BuffBox2 = self:NewUI(2, CBox)
	self.m_MaxMark = self:NewUI(3, CBox)
	self.m_JiHuoLabel = self:NewUI(4, CLabel)
	self.m_JiHuoMark = self:NewUI(5, CSprite)
	self.m_GuideSpr = self:NewUI(6, CSprite)
	self.m_HelpBtn = self:NewUI(7, CBox)
	g_GuideCtrl:CheckOtherGuideWhenBuff()
	g_GuideCtrl:AddGuideUI("house_main_buff_sprite", self.m_GuideSpr)
	self:InitContent()
end

function CHouseBuffView.InitBuffBox(self, oBuffBox)
	oBuffBox.m_LvLabel = oBuffBox:NewUI(1, CLabel)
	oBuffBox.m_ProcessLabel = oBuffBox:NewUI(2, CLabel)
	oBuffBox.m_AttrLabel = oBuffBox:NewUI(3, CLabel)
	oBuffBox.m_BuffSprite = oBuffBox:NewUI(4, CSprite)
	oBuffBox.m_ParentView = self
	function oBuffBox.SetLv(self, iLv, isDown)
		local oData = data.housedata.LoveBuff[iLv]
		local oDataNext = data.housedata.LoveBuff[iLv + 1]

		oBuffBox.m_LvLabel:SetText(string.format("%s阶", oData.level))
		if isDown then
			oBuffBox.m_ProcessLabel:SetText("[D13939]未激活")
		elseif oDataNext then
			oBuffBox.m_ProcessLabel:SetText(string.format("[6d2908][u]总亲密度[/u]：[D13939]%s/%s级[-]", g_HouseCtrl:GetTotalLoveLv(), oDataNext.total_level))
		else
			oBuffBox.m_ProcessLabel:SetText("[D13939]已满级")
		end
		oBuffBox.m_AttrLabel:SetText(g_PlayerBuffCtrl:GetHouseAttrStr(iLv, nil, 2))
		oBuffBox.m_BuffSprite:SpriteHouseBuff(oData.icon)
	end
end

function CHouseBuffView.InitContent(self)
	local oHintData = data.helpdata.DATA["house_buff"]
	self.m_HelpBtn:SetOrgHint(oHintData.title, oHintData.content, enum.UIAnchor.Side.Bottom)
	self.m_MaxMark:SetActive(false)
	self.m_MaxLv = 0
	for k,v in pairs(data.housedata.LoveBuff) do
		if self.m_MaxLv < v.level then
			self.m_MaxLv = v.level
		end
	end
	self:InitBuffBox(self.m_BuffBox1)
	self:InitBuffBox(self.m_BuffBox2)
	self:SetData()
end

function CHouseBuffView.SetData(self)
	local oInfo = g_PlayerBuffCtrl:GetHouseBuff()
	self.m_JiHuoLabel:SetActive(oInfo.stage > 0)
	if oInfo.stage > 0 then
		self.m_JiHuoMark:SetSpriteName("pic_yijihuodikuang")
	else
		self.m_JiHuoMark:SetSpriteName("pic_buffdikuang")
	end
	self.m_JiHuoMark:MakePixelPerfect()
	self.m_BuffBox1:SetLv(oInfo.stage)
	if oInfo.stage >= self.m_MaxLv then
		self.m_BuffBox2:SetActive(false)
		self.m_MaxMark:SetActive(true)
	else
		self.m_BuffBox2:SetLv(oInfo.stage + 1, true)
		self.m_BuffBox2:SetActive(true)
		self.m_MaxMark:SetActive(false)
	end
end

function CHouseBuffView.Destroy(self)
	CViewBase.Destroy(self)
	g_GuideCtrl:ReCheckHouseGuideEffect()
end

return CHouseBuffView