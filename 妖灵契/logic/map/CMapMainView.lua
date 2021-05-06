local CMapMainView = class("CMapMainView", CViewBase)

function CMapMainView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Map/MapMainView.prefab", cb)
	self.m_DepthType = "Dialog"
	self.m_GroupName = "main"
	self.m_ExtendClose = "Black"
	self.m_OpenEffect = "Scale"
end

function CMapMainView.OnCreateView(self)
	self.m_WorldMapPage = self:NewPage(1, CWorldMapPage)
	self.m_MiniMapPage = self:NewPage(2, CMiniMapPage)
end

function CMapMainView.ShowSpecificPage(self, index, args)
	index = index or 1
	self:ShowSubPage(self.m_PageList[index], args)
end

return CMapMainView