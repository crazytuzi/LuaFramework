-----------------------------------------------------------------------------
--道具提示

-----------------------------------------------------------------------------

local CPreviewItemPage = class("CPreviewItemPage", CPageBase)

function CPreviewItemPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
	self.m_TitleLabel = self:NewUI(1, CLabel)
	self.m_ContentLabel = self:NewUI(2, CLabel)
	self.m_ItemSprite = self:NewUI(3, CSprite)
	self:InitContent()

end

function CPreviewItemPage.InitContent(self)

end

function CPreviewItemPage.ShowPage(self, tExtend)
	CPageBase.ShowPage(self)
	self:SetContent(tExtend)
end

--tExtend 扩展部分根据需求对应
--[[
	--宝图事件处理
	tExtend = {
		atlas = "Treasure",
		spritename = sprite,
		name = dData.name,
		desc = dData.desc,
	}
	--宝图普通道具
	tExtend = {
		itemshape = 10022,
		name = data.name,
		desc = data.desc,
	}
]]
function CPreviewItemPage.SetContent(self, tExtend)
	if tExtend then
		if tExtend.name then
			self.m_TitleLabel:SetText(tExtend.name)
		end
		if tExtend.desc then
			self.m_ContentLabel:SetText(tExtend.desc)
		end
		if tExtend.atlas and tExtend.spritename  then
			self.m_ItemSprite:SetStaticSprite(tExtend.atlas, tExtend.spritename)
		end
		if tExtend.itemshape then
			self.m_ItemSprite:SpriteItemShape(tExtend.itemshape)
		end

		local _, h = self.m_ContentLabel:GetSize()
		self:SetHeight(self:GetHeight() + h)
	end
end


return CPreviewItemPage