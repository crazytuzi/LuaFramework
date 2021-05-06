local CInput = class("CInput", CWidget)

function CInput.ctor(self, obj)
	CWidget.ctor(self, obj)
	self.m_UIInput = obj:GetComponent(classtype.UIInput)
	self.m_UIInput.selectAllTextOnFocus = false
end

function CInput.GetText(self)
	return self.m_UIInput.value
end

function CInput.SetText(self, sText)
	sText = sText or ""
	self.m_UIInput.value = sText
end

function CInput.GetInputType(self)
	return self.m_UIInput.inputType
end

function CInput.SetInputType(self, inputType)
	self.m_UIInput.inputType = inputType
end

function CInput.Submit(self)
	self.m_UIInput:Submit()
end

function CInput.RemoveFocus(self)
	self.m_UIInput:RemoveFocus()
end

function CInput.GetInputLength(self)
	return self.m_UIInput:GetInputLength()
end


function CInput.SetFocus(self)
	local function delay()
		if Utils.IsNil(self) then
			return
		end
		self.m_UIInput.isSelected = true
	end
	Utils.AddTimer(delay, 0, 0)
end



function CInput.IsFocus(self)
	return self.m_UIInput.isSelected
end

function CInput.SetCharLimit(self, iLimit)
	self.m_UIInput.characterLimit = iLimit
end

function CInput.GetCharLimit(self)
	return self.m_UIInput.characterLimit
end

function CInput.SetDefaultText(self, sText)
	self.m_UIInput.defaultText = sText
end

function CInput.GetDefaultText(self)
	return self.m_UIInput.defaultText
end

function CInput.SetForbidChars(self, chars)
	self.m_ForbidChars = {}
	for k, v in pairs(chars) do
		self.m_ForbidChars[v] = true
	end
	self:AddUIEvent("UIInputOnValidate", callback(self, "CheckValidChar"))
end

function CInput.CheckValidChar(self, oInput, char)
	if self.m_ForbidChars[char] then
		return ""
	else
		return char
	end
end

function CInput.SetPermittedChars(self, charStart, charEnd)
	self.m_PermittedChars = {}
	for chascii = string.byte(charStart), string.byte(charEnd) do
		self.m_PermittedChars[chascii] = true
	end
	self:AddUIEvent("UIInputOnValidate", callback(self, "CheckPermittedChar"))
end

function CInput.CheckPermittedChar(self, oInput, char)
	-- printc("CheckPermittedChar, char = " .. char)
	if self.m_PermittedChars[string.byte(char)] then
		return char
	else
		return ""
	end
end

--限制输入字数，中英文等同一个字(ios联想会算字数，弃用)
function CInput.SetLimitLen(self, len)
	if len then
		self.m_LimitLen = len
		self:AddUIEvent("change", callback(self, "OnInputChange"))
	else
		self.m_LimitLen = len
		self:AddUIEvent("change", function() end)
	end
end

function CInput.OnInputChange(self)
	if self.m_LimitLen == 0 then
		self:SetText("")
		return
	end

	local str = self.m_UIInput.value
	local count = 0
	local len = 0
	while count < string.len(str) do
		local utf8 = string.byte(str, count + 1)
		if utf8 == nil then
			break
		end
		len = len + 1
		if len > self.m_LimitLen then
			self:SetText(string.sub(str, 1, count))
			break
		end
		--utf8字符1byte,中文3byte
		if utf8 > 127 then
			count = count + 3
		else
			count = count + 1
		end
	end
end


return CInput