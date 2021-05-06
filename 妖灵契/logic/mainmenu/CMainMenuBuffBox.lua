local CMainMenuBuffBox = class("CMainMenuBuffBox", CBox)

function CMainMenuBuffBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_BuffBoxGrid = self:NewUI(1, CGrid)
	self.m_BuffBoxClone = self:NewUI(2, CSprite)
	self.m_BuffBoxClone:SetActive(false)
	self.m_BuffBoxGrid:SetActive(false)
	self:InitContent()
end

function CMainMenuBuffBox.InitContent(self)
	self:InitBuffBox()
end

function CMainMenuBuffBox.InitBuffBox(self)
	local buffBoxList = self.m_BuffBoxGrid:GetChildList()
	local oBuffBox = nil
	for i=1,1 do
		oBuffBox = self.m_BuffBoxClone:Clone()
		oBuffBox:SpriteItemShape(10012)
		oBuffBox:AddUIEvent("click", function ()
			
		end)
		self.m_BuffBoxGrid:AddChild(oBuffBox)
		oBuffBox:SetActive(true)
	end
end

return CMainMenuBuffBox