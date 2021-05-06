local CNameHud = class("CNameHud", CAsyncHud)

function CNameHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/NameHud.prefab", cb, false)
end

function CNameHud.OnCreateHud(self)
	self.m_Label = self:NewUI(1, CHudLabel)
	self.m_Name = ""
	self.m_Pos = self.m_Label:GetLocalPos()
	self.m_TitlePos = Vector3.New(self.m_Pos.x, self.m_Pos.y - 10, self.m_Pos.z)
end

function CNameHud.SetName(self, s, arenaTitleInfo, footTitleInfo)
	self.m_Name = s
	local arenaName = ""
	local titleName = ""
	local tempTitleData = nil

	if arenaTitleInfo then
		tempTitleData = data.titledata.DATA[arenaTitleInfo.tid]
		local sName = tempTitleData.name
		if arenaTitleInfo.name ~= nil and arenaTitleInfo.name ~= "" then
			sName = arenaTitleInfo.name
		end
		if tempTitleData.text_color ~= "" then
			arenaName = string.format("[%s]%s[-] ", tempTitleData.text_color, sName)
		else
			arenaName = sName .. " "
		end
	end
	if footTitleInfo then
		tempTitleData = data.titledata.DATA[footTitleInfo.tid]
		local sName = tempTitleData.name
		if footTitleInfo.name ~= nil and footTitleInfo.name ~= "" then
			sName = footTitleInfo.name
		end
		if tempTitleData.text_color ~= "" then
			titleName = string.format("[%s]%s[-]\n", tempTitleData.text_color, sName)
		else
			titleName = sName .. "\n"
		end
		self.m_Label:SetLocalPos(self.m_TitlePos)
	else
		self.m_Label:SetLocalPos(self.m_Pos)
	end

	self.m_Label:SetText(string.format("%s%s%s", titleName, arenaName, s))
end

function CNameHud.GetName(self)
	return self.m_Name
end

return CNameHud