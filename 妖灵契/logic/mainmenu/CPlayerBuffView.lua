local CPlayerBuffView = class("CPlayerBuffView", CViewBase)


function CPlayerBuffView.ctor(self, cb)
	CViewBase.ctor(self, "UI/MainMenu/PlayerBuffView.prefab", cb)
	self.m_ExtendClose = "ClickOut"
	-- self.m_OpenEffect = "Scale"
end

function CPlayerBuffView.OnCreateView(self)
	self.m_BuffGrid = self:NewUI(1, CGrid)
	self.m_BuffBox = self:NewUI(2, CBox)
	self.m_Bg = self:NewUI(3, CSprite)
	self:InitContent()
end

function CPlayerBuffView.InitContent(self)
	self.m_Timer = nil
	g_PlayerBuffCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnBuffEvent"))
	self.m_Bg:SetLocalScale(Vector3.New(0.01, 0.01, 0.01))
	local tween = DOTween.DOScale(self.m_Bg.m_Transform, Vector3.one, 0.3)
	DOTween.SetEase(tween, enum.DOTween.Ease.OutSine)
	self.m_BuffBox:SetActive(false)
	self.m_NowTime = g_TimeCtrl:GetTimeS()
	self:SetData()
end

function CPlayerBuffView.SetData(self)
	local oData = g_PlayerBuffCtrl:GetBuffList()
	-- printc("InitBuff")
	-- table.print(oData, "SetData")
	self.m_NowTime = g_TimeCtrl:GetTimeS()
	self.m_BuffBoxArr = {}
	local count = 1
	self.m_BuffGrid:Clear()
	for k,v in pairs(oData) do
		local oBuffBox = self:CreateBuffBox()
		oBuffBox:SetData(v, self.m_NowTime)
		oBuffBox:SetActive(true)
		self.m_BuffBoxArr[count] = oBuffBox
		self.m_BuffGrid:AddChild(oBuffBox)
		count = count + 1
	end
	if self.m_Timer == nil then
		Utils.AddTimer(callback(self, "UpdateTime"), 1, 1)
	else
		self.m_NowTime = self.m_NowTime - 1
		self:UpdateTime()
	end
end

function CPlayerBuffView.CreateBuffBox(self)
	local oBuffBox = self.m_BuffBox:Clone()
	oBuffBox.m_NameLabel = oBuffBox:NewUI(1, CLabel)
	oBuffBox.m_DescLabel = oBuffBox:NewUI(2, CLabel)
	oBuffBox.m_TimeLabel = oBuffBox:NewUI(3, CLabel)

	function oBuffBox.RefreshTime(self, nowTime)
		local restTime = oBuffBox.m_Data:GetValue("end_time") - nowTime
		if restTime >= 0 then
			oBuffBox:SetActive(true)
			oBuffBox.m_TimeLabel:SetText("[8C8783]剩余[ff0000]" .. g_TimeCtrl:GetLeftTime(restTime))
		else
			oBuffBox:SetActive(false)
		end
	end

	function oBuffBox.SetData(self, oData, nowTime)
		oBuffBox.m_Data = oData
		local attrList = oData:GetValue("apply_info")
		local str = nil
		for i,v in ipairs(attrList) do
			str = string.format("[8C8783]%s[00ff00]+%s", define.Attr.String[v.key], g_ItemCtrl:AttrStringConvert(v.key, v.value))
		end
		oBuffBox.m_NameLabel:SetText(oData:GetValue("name"))
		oBuffBox.m_DescLabel:SetText(str)
		oBuffBox:RefreshTime(nowTime)
	end

	return oBuffBox
end

function CPlayerBuffView.UpdateTime(self)
	self.m_NowTime = self.m_NowTime + 1
	local isInit = false
	for i,v in ipairs(self.m_BuffBoxArr) do
		if v:GetActive() then
			v:RefreshTime(self.m_NowTime)
			isInit = true
		end
	end
	if not isInit then
		self.m_Timer = nil
	end
	return isInit
end

function CPlayerBuffView.OnBuffEvent(self, oCtrl)
	if oCtrl.m_EventID == define.PlayerBuff.Event.OnRefreshBuff then
		self:SetData()
	end
end

return CPlayerBuffView