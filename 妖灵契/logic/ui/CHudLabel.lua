local CHudLabel = class("CHudLabel", CObject)

function CHudLabel.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_LabelHud = obj:GetComponent(classtype.UILabelHUD)
end

function CHudLabel.SetText(self, sText)
	self.m_LabelHud.text = sText
end

function CHudLabel.GetText(self)
	return self.m_LabelHud.text
end

function CHudLabel.InitEmoji(self)
	if not self.m_EmojiController then
		self.m_EmojiController = self:GetMissingComponent(classtype.EmojiAnimationController)
	end
end

function CHudLabel.SetRichText(self, sText)
	sText = sText or ""
	self:InitEmoji()
	self.m_EmojiController:SetEmojiText(sText)
end

return CHudLabel
