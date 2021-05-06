local CTitleHud = class("CTitleHud", CAsyncHud)

function CTitleHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/TitleHud.prefab", cb, true)
end

function CTitleHud.OnCreateHud(self)
	self.m_Sprite = self:NewUI(1, CSprite)
	self.m_Label = self:NewUI(2, CHudLabel)
end

function CTitleHud.SetTitleText(self, str)
	self.m_Label:SetText(str)
	self.m_Label:SetActive(true)
	self.m_Sprite:SetActive(false)
end

function CTitleHud.SetTitleSprite(self, icon)
	self.m_Sprite:SpriteTitle(icon)
	self.m_Sprite:MakePixelPerfect()
	self.m_Label:SetActive(false)
	self.m_Sprite:SetActive(true)
end

function CTitleHud.SetTitle(self, titleInfo)
	local titleName = nil
	local spriteName = nil
	if titleInfo then
		local tempTitleData = data.titledata.DATA[titleInfo.tid]
		local sName = tempTitleData.name
		if titleInfo.name ~= nil and titleInfo.name ~= "" then
			sName = titleInfo.name
		end
		if tempTitleData.text_color ~= "" then
			titleName = string.format("[%s]%s[-]", tempTitleData.text_color, sName)
		else
			titleName = sName
		end
		spriteName = tempTitleData.icon
	end
	if spriteName ~= nil and spriteName ~= "" then
		self:SetTitleSprite(spriteName)
	elseif titleName ~= nil then
		self:SetTitleText(titleName)
	else
		self.m_Label:SetActive(false)
		self.m_Sprite:SetActive(false)
	end
end

return CTitleHud