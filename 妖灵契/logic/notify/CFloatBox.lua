local CFloatBox = class("CFloatBox", CBox)

function CFloatBox.ctor(self, obj)
	CBox.ctor(self, obj)

	self.m_FloatLabel = self:NewUI(1, CLabel)
	self.m_BgSprite = self:NewUI(2, CSprite)
	
	self.m_Callback = nil
	self.m_FloatTimer = nil
	self.m_PastTime = 0
	self.m_LastTime = 0
end

function CFloatBox.SetMaxWidth(self, w)
	self.m_FloatLabel:SetOverflowWidth(w)
end

function CFloatBox.SetTimer(self, iTime, cb)
	self.m_Callback = cb
	self.m_PastTime = 0
	self.m_LastTime = iTime
	if self.m_FloatTimer then
		Utils.DelTimer(self.m_FloatTimer)
		self.m_FloatTimer = nil
	end
	self.m_FloatTimer = Utils.AddTimer(callback(self, "AlphaStep"), 0, 0)
end

function CFloatBox.AlphaStep(self, t)
	local iLastTime = self.m_LastTime
	self.m_PastTime = self.m_PastTime + t
	if self.m_PastTime > iLastTime then
		local fAlpha = (1 - (self.m_PastTime - iLastTime))
		if fAlpha < 0 then
			if self.m_Callback then
				self.m_Callback(self)
				self.m_Callback = nil
			end
			return false
		else
			self:SetAlpha(fAlpha)
		end
	end
	return true
end

function CFloatBox.ResizeBg(self)
	local bounds = UITools.CalculateRelativeWidgetBounds(self.m_FloatLabel.m_Transform)
	local offseth = 0
	if self.m_Text then
		local _, sText = self.m_FloatLabel:Wrap(self.m_Text)
		local textList = string.split(sText, "\n")
		sText = textList[#textList]
		if sText then
			local size1 = self.m_FloatLabel:CalculatePrintedSize("好")
			local size2 = self.m_FloatLabel:CalculatePrintedSize(sText)
			offseth = size2.y - size1.y
		end
	end
	local iw, ih = bounds.max.x - bounds.min.x + 36, bounds.max.y - bounds.min.y + 22
	if offseth > 0 then
		self.m_BgSprite:SetLocalPos(Vector3.New(0, offseth/2, 0))
		self.m_BgSprite:SetSize(iw, ih + offseth/2)
	else
		self.m_BgSprite:SetSize(iw, ih)
	end
end

function CFloatBox.SetText(self, sText)
	if self.m_Text == sText then
		return false
	end
	self.m_Text = sText
	self.m_FloatLabel:SetRichText(sText, true)
end

return CFloatBox