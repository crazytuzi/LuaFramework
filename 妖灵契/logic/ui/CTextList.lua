local CTextList = class("CTextList",CObject)

function CTextList.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_TextList = self:GetComponent(classtype.UITextList)
end

function CTextList.Add(self, text)
	self.m_TextList:Add(text)
end

function CTextList.SetTextLabel(self, textLabel)
	self.m_TextList.textLabel.text = textLabel
end

function CTextList.GetTextLabel(self)
	return self.m_TextList.textLabel.text
end

function CTextList.SetParagraphHistory(self, i)
	self.m_TextList.paragraphHistory = i
end

function CTextList.Clear(self)
	self.m_TextList:Clear()
end

function CTextList.SetScrollValue(self, value)
	self.m_TextList.scrollValue = value
end

return CTextList