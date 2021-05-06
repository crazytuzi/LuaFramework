local CWarBoutTimeBox = class("CWarBoutTimeBox", CBox)

function CWarBoutTimeBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_WaitSpr = self:NewUI(2, CBox)
	self.m_NumberGrid = self:NewUI(3, CGrid)
	self.m_NumberSprite = self:NewUI(4, CSprite)
	self.m_NumberBgSprite = self:NewUI(5, CSprite)

	self.m_NumberBgTween = self.m_NumberBgSprite:GetComponent(classtype.TweenAlpha)
	self.m_CountDownTimer = nil
	self.m_NumberSpriteArr = {}

	self:ShowWait(false)
	self.m_NumberGrid:SetActive(false)
	self.m_NumberSprite:SetActive(false)
	self.m_LastUpdateTime = -1
	g_WarCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnCtrlEvent"))
end

function CWarBoutTimeBox.OnCtrlEvent(self, oCtrl)
	if oCtrl.m_EventID == define.War.Event.SectionEnd then
		self:CheckShowWait()
	end
end

function CWarBoutTimeBox.StartCountDown(self)
	self:ShowWait(false)
	if g_WarCtrl:IsPlayRecord() then
		return
	end
	if not self.m_CountDownTimer then
		self.m_CountDownTimer = Utils.AddTimer(callback(self, "CountDown"), 0.1, 0)
	end
end

function CWarBoutTimeBox.CountDown(self)
	if g_WarOrderCtrl:IsCanOrder() and g_WarCtrl:IsPause() then
		return true
	end
	local iRemain = g_WarOrderCtrl:GetRemainTime()
	local warType = g_WarCtrl:GetWarType()
	if iRemain then
		if (warType == define.War.Type.Arena or warType == define.War.Type.EqualArena or warType == define.War.Type.TeamPvp or warType == define.War.Type.ClubArena) and iRemain > 40 then
			self.m_NumberGrid:SetActive(false)
			return true
		elseif g_WarCtrl:IsAutoWar() then

			-- if warType == define.War.Type.Guide3 or self:IsPlayFight() then
			-- 	if iRemain > 37 then
			-- 		self:UpdateTimeSprite(iRemain)
			-- 		return true
			-- 	end
			-- elseif g_AttrCtrl.grade >= 13 and g_WarCtrl:GetBout() == 1 then
			-- 	if iRemain > 37 then
			-- 		self:UpdateTimeSprite(iRemain)
			-- 		return true
			-- 	end
			-- else
			-- 	g_WarOrderCtrl:TimeUp(false)
			-- end
			-- g_AttrCtrl.grade >= 13 and
			if iRemain > 12 then
				self:UpdateTimeSprite(iRemain)
				return true
			end
		elseif g_WarOrderCtrl:IsCanOrder() then
			if iRemain > 0 then
				self:UpdateTimeSprite(iRemain)
				return true
			end
		end
		g_WarOrderCtrl:TimeUp(true)
	end
	self.m_NumberGrid:SetActive(false)
	self.m_NumberBgSprite:SetActive(false)
	self:CheckShowWait()
	self.m_CountDownTimer = nil
	return false
end

function CWarBoutTimeBox.IsPlayFight(self)
	--一些需要显示请等待的战斗类型
	local tType = {
		define.War.Type.PVP, 
		define.War.Type.Arena,
		define.War.Type.TeamPvp,
		define.War.Type.EqualArena,
		define.War.Type.FieldBossPVP,
		define.War.Type.Terrawar,
	}
	return table.index(tType, g_WarCtrl:GetWarType())
end

function CWarBoutTimeBox.UpdateTimeSprite(self, iValue)
	self.m_NumberGrid:SetActive(true)
	self.m_NumberBgSprite:SetActive(true)

	if self.m_LastUpdateTime == iValue then
		return
	end
	self.m_LastUpdateTime = iValue
	if iValue < 10 then
		self.m_NumberBgTween.enabled = true
	else
		self.m_NumberBgTween.enabled = false
		self.m_NumberBgSprite:SetColor(Color.white)
	end
	local sList = self:GetNumList(iValue)
	for i,v in ipairs(sList) do
		if self.m_NumberSpriteArr[i] == nil then
			self.m_NumberSpriteArr[i] = self.m_NumberSprite:Clone()
			self.m_NumberGrid:AddChild(self.m_NumberSpriteArr[i])
		end
		self.m_NumberSpriteArr[i]:SetSpriteName("shuzi_jishi" .. v)
		self.m_NumberSpriteArr[i]:SetActive(true)
	end
	local startCount = #sList + 1
	for i = startCount, #self.m_NumberSpriteArr do
		self.m_NumberSpriteArr[i]:SetActive(false)
	end
	self.m_NumberGrid:Reposition()
end

function CWarBoutTimeBox.GetNumList(self, iValue)
	local sList = {}
	local str = tostring(iValue)
	local len = string.len(str)
	for i = 1, len do
		table.insert(sList, string.sub(str, i, i))
	end
	return sList
end

function CWarBoutTimeBox.CheckShowWait(self)
	if g_WarCtrl:IsInAction() or not g_WarCtrl:IsPrepare() then
		self:ShowWait(false)
	elseif g_WarCtrl:GetBout() == 1 then
		self:ShowWait(true)
	elseif self:IsPlayFight() then
		self:ShowWait(true)
	else
		self:ShowWait(false)
	end
end

function CWarBoutTimeBox.ShowWait(self, bShow)
	self.m_WaitSpr:SetActive(bShow)
end

return CWarBoutTimeBox