local CContainerObject = class("CContainerObject", CObject, CGameObjContainer)

function CContainerObject.ctor(self, obj)
	CObject.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
end

return CContainerObject
