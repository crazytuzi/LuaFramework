local CAssetInfo = class("CAssetInfo", CDelayCallBase)
CAssetInfo.g_ValidMap = {}
--不可删除
CAssetInfo.g_BalckPattrns = {
	"^Audio/Sound/UI/",
}

--可删除
CAssetInfo.g_WhitePatrrns = {
	"^Texture/",
	"^Audio/",  
	"^Map2d/",
	"^Live2d/",
	"^Spine/",
}

function CAssetInfo.ctor(self, asset)
	CDelayCallBase.ctor(self)
	self.m_ID = asset:GetInstanceID()
	self.m_Asset = asset
	self.m_Name = asset.name
	self.m_RefCnt = 0 --只有这个计数为0才能清除
	self.m_Path = nil
	self.m_RefGameObject = {}
	self.m_NexSceneRelease= false
	self.m_DontRelease = false
	setmetatable(self.m_RefGameObject, {__mode="v"})
end

function CAssetInfo.SetDontRelease(self, b)
	self.m_DontRelease = b
end

function CAssetInfo.IsDontRelease(self)
	return self.m_DontRelease
end

function CAssetInfo.AddAssetBundleRef(self)
	if self.m_Path and not self.m_DontRelease then
		C_api.ResourceManager.AddAssetBundleRef(self.m_Path)
	end
end

function CAssetInfo.DelAssetBundleRef(self)
	if self.m_Path and not self.m_DontRelease then
		C_api.ResourceManager.DelAssetBundleRef(self.m_Path)
	end
end

function CAssetInfo.UnloadAssetBundle(self)
	if self:IsCanUnload() then
		-- printerror("CAssetInfo.UnloadAssetBundle:", self.m_Path)
		C_api.ResourceManager.UnloadAssetBundle(self.m_Path, true)
	end
end

function CAssetInfo.IsCanUnload(self)
	local path = self.m_Path
	if not path then
		return false
	end
	local bValid = CAssetInfo.g_ValidMap[path]
	if bValid == nil then 
		for i, s in ipairs(CAssetInfo.g_BalckPattrns) do
			if string.find(path, s) then
				bValid = false
				break
			end
		end
		if bValid == nil then --不在黑名单中
			bValid = false
			for i, s in ipairs(CAssetInfo.g_WhitePatrrns) do
				if string.find(path, s) then --在白名单中
					bValid = true
					break
				end
			end
		end
		CAssetInfo.g_ValidMap[path] = bValid
	end
	return bValid
end

function CAssetInfo.GetAsset(self)
	return self.m_Asset
end

function CAssetInfo.SetPath(self, path)
	if self.m_Path ~= path then
		self.m_Path = path
		self:AddAssetBundleRef()
		if self:IsUI() then
			self.m_NexSceneRelease = true
		end
	end
end

function CAssetInfo.GetPath(self)
	return self.m_Path
end

function CAssetInfo.AddRefCnt(self)
	self.m_RefCnt = self.m_RefCnt + 1
end

function CAssetInfo.SubRefCnt(self)
	self.m_RefCnt = self.m_RefCnt - 1
end

function CAssetInfo.IsPrefab(self)
	if self.m_Path and string.find(self.m_Path, ".prefab$") then
		return true
	else
		return false
	end
end

function CAssetInfo.IsUI(self)
	if self.m_Path and string.find(self.m_Path, "View.prefab$") then
		return true
	else
		return false
	end
end

function CAssetInfo.AddRefObject(self, gameObject)
	self.m_RefGameObject[gameObject:GetInstanceID()] = gameObject
end


function CAssetInfo.DelRefObject(self, gameObject)
	self.m_RefGameObject[gameObject:GetInstanceID()] = nil
end

function CAssetInfo.SetNextScneneRelease(self, b)
	self.m_NexSceneRelease = b
end

function CAssetInfo.IsCanRelease(self)
	local bCanUnload = (not self.m_NexSceneRelease) and (not self.m_DontRelease)
	-- printc("IsCanRelease->", self.m_Path or self.m_Name, self.m_NexSceneRelease, self.m_DontRelease, self.m_RefCnt, table.count(self.m_RefGameObject))
	if bCanUnload then
		if self.m_RefCnt <= 0 then
			for id, gameObject in pairs(self.m_RefGameObject) do
				if C_api.Utils.IsObjectExist(gameObject) then
					-- print("残留->", gameObject.name, gameObject)
					bCanUnload = false
					break
				else
					-- print("清除->")
					self.m_RefGameObject[id] = nil
				end
			end
		else
			bCanUnload = false
		end
	end
	return bCanUnload
end

function CAssetInfo.DoCheck(self)
	-- Utils.DebugCall(function() 
	g_ResCtrl:CheckAssetInfo(self)
		-- end, "CAssetInfo.DoCheck:"..tostring(self.m_Path))
end

return CAssetInfo