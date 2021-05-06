local CBox = class("CBox", CWidget, CGameObjContainer)

function CBox.ctor(self, obj)
	CWidget.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
end

return CBox
