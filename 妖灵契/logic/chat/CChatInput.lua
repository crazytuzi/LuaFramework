local CChatInput = class("CChatInput", CInput)

function CChatInput.ctor(self, obj)
	CInput.ctor(self, obj)
	self.m_Link = {}
	self:AddUIEvent("change", callback(self, "OnInputChange"))
end

--self.m_RealText  = "hello {link1,1,1}"
--self.m_UIInput.value = "hello 道具1"
function CChatInput.OnInputChange(self)
	local sValue = self.m_UIInput.value
	local b = ""
	local dellink = {}
	for sLink, sText in pairs(self.m_Link) do
		if string.findstr(sValue, sText) then
			sValue = string.replace(sValue, sText, sLink)
		else
			table.insert(dellink, sLink)
		end
	end
	for _, sLink in ipairs(dellink) do
		self.m_Link[sLink] = nil
	end
	self.m_RealText = sValue
	g_LinkInfoCtrl:UpdateInputText(sValue)
end

function CChatInput.GetText(self)
	if self.m_RealText then
		return self.m_RealText
	else
		return ""
	end
end

function CChatInput.SetText(self, sText)
	sText = sText or ""
	self.m_RealText = sText
	self.m_Link = {}
	local t = {}
	for sLink in string.gmatch(sText, "%b{}") do
		local sPrintText = LinkTools.GetPrintedText(sLink)
		if t[sPrintText] then
			local k = t[sPrintText]
			t[sPrintText] = k + 1
			sPrintText = string.gsub(sPrintText, "]", string.format("-%d]", k))
		else
			t[sPrintText] = 1
		end
		self.m_Link[sLink] = sPrintText
		sText = string.replace(sText, sLink, sPrintText)
	end
	self.m_UIInput.value = sText
end

function CChatInput.ClearLink(self)
	local sValue = self.m_UIInput.value
	local sReal = self.m_RealText
	for sLink, sText in pairs(self.m_Link) do
		sValue = string.replace(sValue, sText, "")
		sReal = string.replace(sReal, sLink, "")
	end
	self.m_Link = {}
	self.m_RealText = sReal
	self.m_UIInput.value = sValue
end

function CChatInput.Insert(self, text)
	self.m_UIInput:Insert(text)
end
return CChatInput