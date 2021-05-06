local CGameObjContainer = class("CGameObjContainer")

function CGameObjContainer.ctor(self, obj)
	self.m_Container = obj:GetComponent(classtype.GameObjectContainer)
	self.m_GameObjects = nil
	self.m_CurPage = nil
	self.m_PageList = {} --Page显示时才实例化每个组件，先缓存
end

function CGameObjContainer.InitAll(self)
	if not self.m_GameObjects then
		if self.m_Container then
			self.m_GameObjects = self.m_Container:GetAll()
		else
			self.m_GameObjects = {}
		end
	end
	return self.m_GameObjects
end
--force true 不存在则报错
--force false 不存在则返回nil
function CGameObjContainer.NewUI(self, objid, cls, force, ...)
	self:InitAll()
	force = (force == nil) and true or force -- 默认true
	local obj = self.m_GameObjects[objid]
	if obj == nil then
		if force then
			error(string.format("GetObject %s Wrong! objid = %d", cls.classname, objid))
		else
			return nil
		end
	end
	local ui = cls.New(obj, ...)
	return ui
end

function CGameObjContainer.GetContainTransform(self, objid)
	self:InitAll()
	if self.m_GameObjects[objid] then
		return self.m_GameObjects[objid].transform
	end
end

function CGameObjContainer.GetObject(self, objid)
	self:InitAll()
	if self.m_GameObjects[objid] then
		return self.m_GameObjects[objid]
	end
end

function CGameObjContainer.NewPage(self, objid, cls)
	local oPage = self:NewUI(objid, cls)
	oPage:SetParentView(self)
	oPage:SetActive(false)
	if not table.index(self.m_PageList, oPage) then
		table.insert(self.m_PageList, oPage)
	end
	return oPage
end

function CGameObjContainer.ShowSubPage(self, oShow, ...)
	for i, oPage in ipairs(self.m_PageList) do
		if table.equal(oShow, oPage) then
			oPage:ShowPage(...)
			self.m_CurPage = oPage
		else
			if oPage:IsInit() then
				oPage:HidePage()
			end
		end
	end
end

function CGameObjContainer.HideAllPage(self)
	for i, oPage in ipairs(self.m_PageList) do
		if oPage:IsInit() then
			oPage:HidePage()
		end
	end
end

return CGameObjContainer