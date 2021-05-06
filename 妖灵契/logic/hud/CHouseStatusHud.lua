local CHouseStatusHud = class("CHouseStatusHud", CAsyncHud)

function CHouseStatusHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/HouseStatusHud.prefab", cb, false)
end

function CHouseStatusHud.OnCreateHud(self)
	self.m_ItemSprite = self:NewUI(1, CSprite)
	self.m_ClickCb = nil
	self.m_ItemSprite:AddUIEvent("click", callback(self, "OnClick"))
end

function CHouseStatusHud.SetItem(self, iShape)
	if iShape then
		self.m_ItemSprite:SpriteItemShape(iShape)
	end
end

function CHouseStatusHud.OnClick(self)
	if self.m_ClickCb then
		self.m_ClickCb()
	end
end

function CHouseStatusHud.SetTouchCb(self, cb)
	self.m_ClickCb = cb
end

return CHouseStatusHud