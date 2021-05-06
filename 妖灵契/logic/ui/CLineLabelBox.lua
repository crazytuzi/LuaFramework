local CLineLabelBox = class("CLineLabelBox", CBox)
--不支持富文本
function CLineLabelBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_Tabel = self:NewUI(1, CTable)
	self.m_Label = self:NewUI(2, CLabel)

	self.m_CharLen = 10
	self.m_Reverse = false
	self.m_TextList = {}
	self.m_Label:SetActive(false)
end

function CLineLabelBox.SetCharLengthPerLine(self, iCharLen)
	self.m_CharLen = iCharLen
	self:UpdateTable()
end

function CLineLabelBox.SetReverse(self, bReverse)
	self.m_Reverse = bReverse
	self:UpdateTable()
end

function CLineLabelBox.SetText(self, sText)
	self.m_TextList = string.split(sText, "\n")
	self:UpdateTable()
end

function CLineLabelBox.UpdateTable(self)
	self.m_Tabel:Clear()
	if not self.m_TextList[1] or self.m_TextList[1] == "" then
		return
	end
	local amount = 0
	for _, text in ipairs(self.m_TextList) do
		local iLen = utf8.len(text)
		local iMax = math.ceil(iLen/self.m_CharLen)
		for i= 1, iMax do
			local iStart = math.max(1, (i - 1) * self.m_CharLen + 1)
			local sSub = utf8.sub(text, iStart, iStart + self.m_CharLen)
			local oLabel = self.m_Label:Clone()
			oLabel:SetActive(true)
			oLabel:SetText(sSub)
			amount = amount + 1
			local iSort = self.m_Reverse and (99999-amount) or amount
			oLabel:SetName(tostring(iSort))
			self.m_Tabel:AddChild(oLabel)
		end
	end
	self.m_Tabel:Reposition()
end

return CLineLabelBox