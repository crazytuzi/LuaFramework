local CGrid = class("CGrid", CObject, CUIEventHandler)

function CGrid.ctor(self, obj)
	CObject.ctor(self, obj)
	CUIEventHandler.ctor(self, obj)
	self.m_UIGrid = obj:GetComponent(classtype.UIGrid)
	self.m_ChildChange = true
	self.m_TransformList = {} --transform缓存
	self.m_LuaObjDict = {}
	self.m_RepositionLaterEnable = true
end

function CGrid.CheckChange(self)
	-- if self.m_ChildChange then
		-- self.m_ChildChange = false
	self.m_TransformList = self.m_UIGrid:GetChildList()
	-- end
end

function CGrid.SetMaxPerLine(self, i)
	self.m_UIGrid.maxPerLine = i
end

function CGrid.GetMaxPerLine(self)
	return self.m_UIGrid.maxPerLine
end

function CGrid.GetCellSize(self)
	return self.m_UIGrid.cellWidth, self.m_UIGrid.cellHeight
end

function CGrid.SetCellSize(self, w, h)
	self.m_UIGrid.cellWidth = w
	self.m_UIGrid.cellHeight = h
end

function CGrid.GetColummLimit(self)
	return self.m_UIGrid.maxPerLine
end

function CGrid.SetHideInactive(self, bActive)
	self.m_UIGrid.hideInactive = bActive
end

function CGrid.Reposition(self)
	if self:GetActiveHierarchy() then
		self.m_UIGrid:Reposition()
	else
		self:RepositionLater()
	end
end

function CGrid.GetCount(self)
	self:CheckChange()
	return #self.m_TransformList
end

function CGrid.Clear(self)
	for i, obj in pairs(self.m_LuaObjDict) do
		self:RemoveChild(obj)
	end
	self.m_TransformList = {}
	self.m_LuaObjDict = {}
end


function CGrid.Recycle(self, matchFunc)
	for i, obj in pairs(self.m_LuaObjDict) do
		local dMatchInfo
		if matchFunc then
			dMatchInfo = matchFunc(obj)
		end
		g_ResCtrl:PutObjectInCache(obj:GetCacheKey(), obj, dMatchInfo)
	end
	self.m_TransformList = {}
	self.m_LuaObjDict = {}
end


function CGrid.InitChild(self, newfunc)
	self:CheckChange()
	local len = #self.m_TransformList
	for i = 1, len do
		local t = self.m_TransformList[i]
		self.m_LuaObjDict[t.gameObject:GetInstanceID()] = newfunc(t.gameObject, i)
	end
end

function CGrid.GetChild(self, index)
	self:CheckChange()
	local oChild = self.m_TransformList[index]

	if oChild then
		return self.m_LuaObjDict[oChild.gameObject:GetInstanceID()]
	end
end

function CGrid.GetChildIdx(self, transform)
	self:CheckChange()
	return table.index(self.m_TransformList, transform)
end

function CGrid.GetChildList(self)
	self:CheckChange()
	local list = {}
	local len = #self.m_TransformList
	for i = 1, len do
		local t = self.m_TransformList[i]
		local luaobj = self.m_LuaObjDict[t.gameObject:GetInstanceID()]
		if luaobj then
			table.insert(list, luaobj)
		end
	end
	return list
end

function CGrid.AddChild(self, obj)
	self.m_ChildChange = true
	self.m_LuaObjDict[obj:GetInstanceID()] = obj
	obj:SetParent(self.m_Transform)
	self:RepositionLater()
end

function CGrid.RemoveChild(self, obj, bRetain)
	self.m_ChildChange = true
	self.m_LuaObjDict[obj:GetInstanceID()] = nil
	obj:SetParent(nil)
	if not bRetain then
		obj:Destroy()
	end
	self:RepositionLater()
end

function CGrid.RepositionLater(self)
	if self.m_RepositionLaterEnable then
		self.m_UIGrid.repositionNow = true
	end
end

function CGrid.SetRepositionLaterEnable(self, bEnable)
	self.m_RepositionLaterEnable = bEnable
end

function CGrid.GetSize(self)
	if not self.m_UIWidget then
		self.m_UIWidget = self:GetMissingComponent(classtype.UIWidget)
	end
	return self.m_UIWidget.width, self.m_UIWidget.height
end

function CGrid.SetSize(self, iW, iH)
	if not self.m_UIWidget then
		self.m_UIWidget = self:GetMissingComponent(classtype.UIWidget)
	end
	self.m_UIWidget.width = iW
	self.m_UIWidget.height = iH
end

function CGrid.UpdateAnchors(self)
	if not self.m_UIWidget then
		self.m_UIWidget = self:GetMissingComponent(classtype.UIWidget)
	end
	self.m_UIWidget:ResetAndUpdateAnchors()
end

function CGrid.RemoveChildList(self, list)
	local removeList = {}
	for i = 1, #list do
		local obj = self:GetChild(list[i])
		table.insert(removeList, obj)
	end

	for _, obj in pairs(removeList) do
		self:RemoveChild(obj)
	end

	for _, pos in pairs(list) do
		table.remove(self.m_TransformList, pos)
	end
end

function CGrid.SetClickSounPath(self, sPath)
	for i,v in ipairs(self:GetChildList()) do
		v:SetClickSounPath(sPath)
	end
end

return CGrid