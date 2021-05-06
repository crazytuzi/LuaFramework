local CLabel = class("CLabel", CWidget)

function CLabel.ctor(self, obj)
	CWidget.ctor(self, obj)
	self.m_EmojiController = nil
	self.m_RawText = ""
	self.m_UILabel = obj:GetComponent(classtype.UILabel)
end

function CLabel.SetOverflowWidth(self, iWidth)
	self.m_UIWidget.overflowWidth = iWidth
end

function CLabel.InitEmoji(self)
	if not self.m_EmojiController then
		self.m_EmojiController = self:GetMissingComponent(classtype.EmojiAnimationController)
	end
end

function CLabel.SetFontSize(self, iSize)
	self.m_UIWidget.fontSize = iSize
end

function CLabel.GetFontSize(self)
	return self.m_UIWidget.fontSize
end

function CLabel.SetText(self, sText)
	sText = tostring(sText) or ""
	self.m_UIWidget.text = sText
end

function CLabel.GetText(self)
	return self.m_UIWidget.text
end

function CLabel.GetRawText(self)
	return self.m_RawText
end

--bInDark为黑色背景底色色，需要#G等颜色亮化
function CLabel.SetRichText(self, sText, bInDark)
	sText = sText or ""
	self:InitEmoji()
	local sUrlText, lLink = LinkTools.GetLinks(sText)
	if next(lLink) then
		if not self.m_UIEventHandler then
			self:AddUIEventHandler()
			self.m_UIWidget.autoResizeBoxCollider = true
			self:GetMissingComponent(classtype.BoxCollider)
			self.m_UIEventHandler:AddEventType(enum.UIEvent["click"])
		end
	end
	if bInDark then
		for oldcolor, newcolor in pairs(data.colordata.COLORINDARK) do
			sUrlText = string.replace(sUrlText, oldcolor, newcolor)
		end
	end
	self.m_Links = lLink
	self.m_RawText = sText
	self.m_EmojiController:SetEmojiText(sUrlText)
end

function CLabel.SetOverflow(self, iOverflow)
	self.m_UIWidget.overflowMethod = iOverflow
end

function CLabel.SetAlignment(self, iAlign)
	self.m_UIWidget.alignment = iAlign
end

function CLabel.SetEffectStyle(self, iStyle)
	self.m_UIWidget.effectStyle = iStyle
end

function CLabel.SetEffectColor(self, color)
	self.m_UIWidget.effectColor = color
end

function CLabel.SetColor(self, color)
	self.m_UIWidget.color = color
end

function CLabel.SetSpacingX(self, iSpacingX)
	self.m_UIWidget.spacingX = iSpacingX
end

function CLabel.SetSpacingY(self, iSpacingY)
	self.m_UIWidget.spacingY = iSpacingY
end

function CLabel.GetUrlAtPosition(self, worldPos)
	return self.m_UIWidget:GetUrlAtPosition(worldPos)
end

function CLabel.Wrap(self, sText)
	return self.m_UILabel:Wrap(sText, nil)
end

function CLabel.CalculatePrintedSize(self, sText)
	return self.m_UILabel:CalculatePrintedSize(sText)
end

function CLabel.SpecialExtendEvent(self, iEvent, ...)
	if iEvent == enum.UIEvent["click"] then
		local worldpos = g_CameraCtrl:GetNGUICamera().lastWorldPosition
		local sUrlContent = self.m_UIWidget:GetUrlAtPosition(worldpos)
		if sUrlContent then
			local iUrl = tonumber(string.split(sUrlContent, ",")[1])
			local dLink = self.m_Links[iUrl]
			if dLink and dLink.func then
				dLink.func(self)
				return true
			end
		end
	end
	return false
end

--默认10w开始转换
function CLabel.SetNumberString(self, number, iNeedConvert)
	number = tonumber(number)
	local str = ""
	if not iNeedConvert then
		iNeedConvert = 100000
	end
	if number >= iNeedConvert then
		number = number / 10000
		number = math.modf(number)
		str = string.format("%d万", number)
	else
		str = tostring(number)
	end
	self:SetText(str)
end

function CLabel.SetQualityColorText(self, quality, text)
	local color = 
	{
		[1] = "[C8C8C8]",
		[2] = "[34C8F4]",
		[3] = "[E110FA]",
		[4] = "[FAB310]",
		[5] = "[6AD709]",
	}
	if quality < 1 then
		quality = 1
	end
	if quality > #color then
		quality = #color
	end
	text = text or ""
	self:SetText(string.format("%s%s", color[quality], text))
end


return CLabel
