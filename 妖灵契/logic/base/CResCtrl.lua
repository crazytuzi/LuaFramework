local CResCtrl = class("CResCtrl", CDelayCallBase)

function CResCtrl.ctor(self)
	CDelayCallBase.ctor(self)
	self.m_OpenAllGC = true
	self.m_AllGC = false
	self.m_GCSteping = false
	self.m_UseCache = true
	self.m_IsInitDone = false
	self.m_UnloadAtlasCounter = data.resdata.UnloadAtlasCount
	self.m_AssetCache = {contents={}, idx=0, destroy=function(obj) end}
	self.m_CloneCache = {root=self:GetCacheRoot("ResCache_Clone"), contents={}, idx=0,
		destroy=function(obj)
			obj:Destroy()
		end
	}
	self.m_ObjectCache = {root=self:GetCacheRoot("ResCache_Object"), contents={}, idx=0, 
		destroy=function(obj)
			obj:Destroy()
		end
	}
	self.m_MapCache = {root=self:GetCacheRoot("ResCache_Map"), contents={}, idx=0, 
		destroy=function(obj) 
			obj.m_MapCompnent:Release()
			obj:Destroy() 
		end
	}
	self.m_ClonePool = {}
	self.m_SecondaryClonePool = {}
	self.m_InitLoadRes = {
		["UI/Hud/HudRoot.prefab"] = false,
		["UI/Misc/ActorNode.prefab"] = false,
		["UI/Misc/HouseWalker.prefab"] = false,
		["UI/Misc/MapWalker.prefab"] = false,
		["UI/Misc/Warrior.prefab"] = false,
		["UI/Misc/WarRoot.prefab"] = false,
		["UI/Misc/EffectNode.prefab"] = false,
		["UI/Misc/UIEffectCamera.prefab"] = false,
		["UI/Misc/ActorCamera.prefab"] = false,
		["UI/Misc/BehindLayer.prefab"] = false,
		["UI/Misc/Live2dModel.prefab"] = false,
		["UI/Misc/SpineCamera.prefab"] = false,
	}
	self.m_NextCheckCacheTime = 1
	self.m_ManagedAssets = {}
	self.m_Path2AssetInfos = {} --按路径映射,方便查找
	self.m_ReleaseAssetCnt = data.resdata.GcAssetReleaseCnt --第一次一定会调用释放
	self.m_LastGCTime = g_TimeCtrl:GetTimeS()
	self.m_CostPerFrame = data.resdata.CostPerFrame
end

function CResCtrl.MoveToSecondary(self)
	for k, v in pairs(self.m_ClonePool) do
		table.insert(self.m_SecondaryClonePool, v)
	end
	self.m_ClonePool = {}
end

function CResCtrl.IsExist(self, path)
	return C_api.ResourceManager.IsExist(path)
end

function CResCtrl.ManagedTextures(self, gameObject)

	local function add(arr)
		if arr.Length > 0 then
			for i=0, arr.Length - 1 do
				local comp = arr[i]
				if comp.material == nil and comp.mainTexture 
					and Utils.IsTypeOf(comp.mainTexture, classtype.Texture2D) then
					local oAssetInfo = self:GetAssetInfo(comp.mainTexture, true)
					oAssetInfo:AddRefObject(gameObject)
					oAssetInfo:SetNextScneneRelease(true)
				end
			end
		end
	end
	add(gameObject:GetComponentsInChildren(classtype.UITexture, true))
end

function CResCtrl.GetAssetInfo(self, asset, bCreate)
	local id = asset:GetInstanceID()
	if not self.m_ManagedAssets[id] and  bCreate then
		self.m_ManagedAssets[id] = CAssetInfo.New(asset)
	end
	return self.m_ManagedAssets[id]
end

function CResCtrl.AddManageAsset(self, asset, gameObject, path)
	local oAssetInfo = self:GetAssetInfo(asset, true)
	oAssetInfo:AddRefObject(gameObject)
	if path then
		oAssetInfo:SetPath(path)
		local dMap = self.m_Path2AssetInfos[path] or {}
		dMap[oAssetInfo.m_ID] = true
		self.m_Path2AssetInfos[path] = dMap
	end
	oAssetInfo:StopDelayCall("DoCheck")
	return oAssetInfo
end

function CResCtrl.DelManagedAsset(self, asset, gameObject)
	local oAssetInfo = self:GetAssetInfo(asset, false)
	if oAssetInfo then
		oAssetInfo:DelRefObject(gameObject)
		if oAssetInfo:IsCanUnload() then
			oAssetInfo:DelayCall(2, "DoCheck")
		end
	end
end

function CResCtrl.CheckManagedAssetsLater(self)
	self:DelayCall(1, "CheckManagedAssets", nil)
end

function CResCtrl.CheckAssetInfo(self, oAssetInfo)
	oAssetInfo:StopDelayCall("DoCheck")
	if oAssetInfo:IsCanRelease() then
		oAssetInfo:DelAssetBundleRef()
		local asset = oAssetInfo:GetAsset()
		local bClearPath, bUnloadAssetBundle = false, false
		local path = oAssetInfo:GetPath()
		local id = oAssetInfo.m_ID
		if path then
			if self.m_Path2AssetInfos[path] then
				bClearPath = true
				self.m_Path2AssetInfos[path][id] = nil
			end
			bUnloadAssetBundle =  true
		end
		-- printerror("UnloadAssetBundle:", bUnloadAssetBundle, path, oAssetInfo.m_Path)
		if bUnloadAssetBundle then
			oAssetInfo:UnloadAssetBundle()
		end
		self.m_ManagedAssets[id] = nil
		self.m_ReleaseAssetCnt = self.m_ReleaseAssetCnt + 1
	end
end

function CResCtrl.CheckManagedAssets(self, func)
	-- Utils.DebugCall(function() 
	self:StopDelayCall("CheckManagedAssets")
	for id, oAssetInfo in pairs(self.m_ManagedAssets) do
		if func then
			func(oAssetInfo)
		end
		self:CheckAssetInfo(oAssetInfo)
	end
	-- end, "CResCtrl.CheckManagedAssets")
end

function CResCtrl.GetCacheRoot(self, sName)
	local obj = UnityEngine.GameObject.New(sName)
	obj:SetActive(false)
	return obj.transform
end

function CResCtrl.LoadOnStart(self)
	local t = {
		"UI/MainMenu/MainMenuView.prefab",
		"UI/Magic/WarStartView.prefab",
		"UI/War/WarMainView.prefab",
	}
	for _, path in ipairs(t) do
		local function cached(oClone, path)
			self:PutCloneInCache(path, oClone)
		end
		self:LoadCloneAsync(path, cached, false)
	end
end

function CResCtrl.ResetCtrl(self)
	self.m_ObjectIdx = 0
	self:CheckCacheSize(self.m_ObjectCache, 0)
	self:CheckCacheSize(self.m_CloneCache, 0)
	self:CheckCacheSize(self.m_MapCache, 0)
end

function CResCtrl.IsAssetBundle(self)
	return C_api.ResourceManager.useAssetBundle
end

function CResCtrl.UnloadAsset(self, asset)
	C_api.ResourceManager.UnloadAsset(asset)
end

function CResCtrl.InitLoad(self)
	local iTotalCount = table.count(self.m_InitLoadRes)
	local count = 0
	local function cb(asset, path)
		if self.m_InitLoadRes[path] == false then
			count = count +1
			self.m_InitLoadRes[path] = true
			self:PutAssetInCache(path, asset)
			local oAssetInfo = self:GetAssetInfo(asset, true)
			oAssetInfo:SetDontRelease(true)
			if count >= iTotalCount then
				print("-->resource init done!!! ".. count)
				self.m_IsInitDone = true
			end
		end
	end
	for path, _ in pairs(self.m_InitLoadRes) do
		self:LoadAsync(path, cb)
	end
end

function CResCtrl.LoadCloneAsync(self, path, func, bPrior)
	local oClone = self:GetCloneFromCache(path, true)
	if oClone then
		Utils.AddTimer(function()
			local oWatch = g_TimeCtrl:StartWatch()
			if Utils.IsEditor() and Utils.IsExist(oClone) then
				oClone.name = "Using_"..tostring(IOTools.GetFileName(path, true))
			end
			self:DoCloneCallback(oClone, path, func)
			local iElapsedMS = g_TimeCtrl:StopWatch(oWatch)
			self.m_CostPerFrame = self.m_CostPerFrame - iElapsedMS
		end, 0, 0)
	else
		--立即加载回调
		if bPrior then
			self:LoadAsync(path, function (asset, path)
				self:CloneWithAsset(asset, path, func, false)
			end)
		else--加载列队回调
			local function insertlist(asset, path)
				if asset then
					local oAssetInfo = self:GetAssetInfo(asset, true)
					oAssetInfo:AddRefCnt()
					self:InsertInCloneList(path, callback(self, "CloneWithAsset", asset, path, func, true))
				else
					self:CloneWithAsset(nil, path, func, false)
				end
			end
			self:LoadAsync(path, insertlist)
		end
	end
end

function CResCtrl.CloneWithAsset(self, asset, path, func, bSubRef)
	if asset then
		local oClone = asset:Instantiate()
		self:AddManageAsset(asset, oClone, path)
		self:DoCloneCallback(oClone, path, func)
		if bSubRef then
			local oAssetInfo = self:GetAssetInfo(asset, true)
			oAssetInfo:SubRefCnt()
		end
		return true
	else
		self:DoCloneCallback(nil, path, func)
		return false
	end
end

function CResCtrl.DoCloneCallback(self, clone, path, func)
	local sucess, ret = xxpcall(func, clone, path)
	if ret == false then
		self:PutCloneInCache(path, clone)
	end
end

function CResCtrl.DoAssetCallback(self, asset, path, func)
	xxpcall(func, asset, path)
end

function CResCtrl.InsertInCloneList(self, key, clonefunc)
	local dlv = table.safeget(data.resdata.Config, key, "dlv") or table.safeget(data.resdata.Config, key, "lv")
	local dCloneInfo = {
		f = clonefunc,
		key = key,
		lv = dlv or 0,
	}
	local iInsertIndx
	for i, v in ipairs(self.m_ClonePool) do
		if dCloneInfo.lv > v.lv then
			iInsertIndx = i
			break
		end
	end
	if iInsertIndx then
		table.insert(self.m_ClonePool, iInsertIndx, dCloneInfo)
	else
		table.insert(self.m_ClonePool, dCloneInfo)
	end
end

function CResCtrl.LoadAsync(self, path, func)
	local asset = self:GetAssetFromCache(path)
	if Utils.IsExist(asset) then
		local oAssetInfo = self:GetAssetInfo(asset, true)
		oAssetInfo:AddRefCnt()
		Utils.AddTimer(function() 
			local oWatch = g_TimeCtrl:StartWatch()
			oAssetInfo:SubRefCnt()
			self:DoAssetCallback(asset, path, func)
			local iElapsedMS = g_TimeCtrl:StopWatch(oWatch)
			self.m_CostPerFrame = self.m_CostPerFrame - iElapsedMS
			end, 0, 0)
	else
		local function process(path, asset)
			local oWatch = g_TimeCtrl:StartWatch()
			if asset then
				local oAssetInfo = self:GetAssetInfo(asset, true)
				oAssetInfo:SetPath(path)
			end
			self:DoAssetCallback(asset, path, func)
			local iElapsedMS = g_TimeCtrl:StopWatch(oWatch)
			self.m_CostPerFrame = self.m_CostPerFrame - iElapsedMS
		end
		local oDelegate = g_DelegateCtrl:NewDelegate(process)
		oDelegate:SetCallOnce(true)
		g_DelegateCtrl:AddStrongRef(oDelegate)
		C_api.ResourceManager.LoadAsync(oDelegate:GetID(), path)
	end
end

function CResCtrl.Load(self, path, func)
	local oWatch = g_TimeCtrl:StartWatch()
	local asset = self:GetAssetFromCache(path)
	if not asset then
		asset = C_api.ResourceManager.Load(path)
	end
	if func then
		func(asset, path)
	end
	local iElapsedMS = g_TimeCtrl:StopWatch(oWatch)
	self.m_CostPerFrame = self.m_CostPerFrame - iElapsedMS
	return asset
end

function CResCtrl.GetPrefabFromCache(self, path)
	return self:GetAssetFromCache(path)
end

function CResCtrl.IsInitDone(self)
	return self.m_IsInitDone
end

function CResCtrl.GetCloneInfo(self)
	local dCloneInfo = self.m_ClonePool[1]
	if dCloneInfo then
		return dCloneInfo, self.m_ClonePool
	else
		return self.m_SecondaryClonePool[1],  self.m_SecondaryClonePool
	end
end

function CResCtrl.Update(self, dt)
	if not g_MapCtrl:IsLoading() then
		local dCloneInfo, pool = self:GetCloneInfo()
		while dCloneInfo and self.m_CostPerFrame > 0 do
			local oWatch = g_TimeCtrl:StartWatch()
			xxpcall(dCloneInfo.f)
			table.remove(pool, 1)
			local iElapsedMS = g_TimeCtrl:StopWatch(oWatch)
			if iElapsedMS > 0 then
				self.m_CostPerFrame = self.m_CostPerFrame - iElapsedMS
			end
			dCloneInfo, pool = self:GetCloneInfo()
		end
	end
	self.m_CostPerFrame = data.resdata.CostPerFrame
	self.m_NextCheckCacheTime = self.m_NextCheckCacheTime - dt
	if self.m_NextCheckCacheTime <= 0 then
		self:CheckCacheTime(self.m_CloneCache)
		self:CheckCacheTime(self.m_ObjectCache)
		self.m_NextCheckCacheTime = 1
	end
	self:GCStep()
end

function CResCtrl.CheckCacheTime(self, dCheckCache)
	local iCurTime =  UnityEngine.Time.realtimeSinceStartup
	for _, dOne in pairs(dCheckCache.contents) do
		local time = self:GetCachedTime(dOne.key)
		if iCurTime - dOne.time > time then
			dCheckCache.destroy(dOne.cache_obj)
			dOne.cache_obj = nil
			local list = dCheckCache[dOne.key]
			dCheckCache[dOne.key][dOne.all_idx] = nil
			dCheckCache.contents[dOne.all_idx] =nil
		end
	end
end

function CResCtrl.GetCachedTime(self, key)
	local time = table.safeget(data.resdata.Config, key, "cache_time")
	if not time then
		time = data.resdata.CachedTime
	end
	return time
end

--缓存
function CResCtrl.GetAssetFromCache(self, path)
	local idx = self.m_AssetCache[path]
	if idx then
		local dCache = self.m_AssetCache.contents[idx]
		local asset = dCache.cache_obj
		return asset
	end
	local dMap = self.m_Path2AssetInfos[path]
	if dMap then
		for id, _ in pairs(dMap) do
			local oAssetInfo = self.m_ManagedAssets[id]
			if oAssetInfo and oAssetInfo:GetPath() == path then
				local asset = oAssetInfo:GetAsset()
				-- print("使用托管的asset:", path)
				return asset
			end
		end
	end
end

--脚本不缓存asset，缓存Instantiate的东西
function CResCtrl.PutAssetInCache(self, path, asset)
	self.m_AssetCache.idx = self.m_AssetCache.idx + 1
	local dCache = {
		key = path,
		cache_obj = asset,
		all_idx = self.m_AssetCache.idx,
		time =  UnityEngine.Time.realtimeSinceStartup,
	}
	self.m_AssetCache[path] = dCache.all_idx
	self.m_AssetCache.contents[dCache.all_idx] = dCache
end

function CResCtrl.GetCloneFromCache(self, path, bNotInstantiateNow)
	local dIdxGroup = self.m_CloneCache[path]
	if dIdxGroup and next(dIdxGroup) then
		local lKeys = table.keys(dIdxGroup)
		table.sort(lKeys)
		local iAllIdx = lKeys[1]
		local oCache = self.m_CloneCache.contents[iAllIdx].cache_obj
		self.m_CloneCache[path][iAllIdx] = nil
		self.m_CloneCache.contents[iAllIdx] =nil
		return oCache
	end
	if bNotInstantiateNow ~= true then
		local asset = self:GetAssetFromCache(path)
		if asset then
			local obj = asset:Instantiate()
			self:AddManageAsset(asset, obj, path)
			return obj
		end
	end
end

function CResCtrl.PutCloneInCache(self, key, clone)
	if not Utils.IsExist(clone) then
		return
	end
	if not self.m_UseCache then
		self.m_CloneCache.destroy(clone)
		return
	end
	if Utils.IsEditor() then
		clone.name = "Recycle_"..tostring(IOTools.GetFileName(key, true))
	end
	clone.transform:SetParent(self.m_CloneCache.root, false)
	self.m_CloneCache.idx = self.m_CloneCache.idx + 1
	local dIdxGroup = self.m_CloneCache[key] or {}
	local dCache = {
		key = key,
		cache_obj = clone,
		time =  UnityEngine.Time.realtimeSinceStartup,
		all_idx = self.m_CloneCache.idx,
	}
	dIdxGroup[dCache.all_idx] = true
	self.m_CloneCache[key] = dIdxGroup
	self.m_CloneCache.contents[dCache.all_idx] = dCache

	self:CheckCacheSize(self.m_CloneCache, data.resdata.CloneCacheMaxSize)
end

--CObject的对象
function CResCtrl.PutObjectInCache(self, key, oObject, dMatchInfo)
	if not self.m_UseCache then
		self.m_ObjectCache.destroy(oObject)
		return
	end
	oObject:SetParent(self.m_ObjectCache.root, false)
	self.m_ObjectCache.idx = self.m_ObjectCache.idx + 1
	local dIdxGroup = self.m_ObjectCache[key] or {}
	local dCache = {
		key = key,
		cache_obj = oObject,
		match = dMatchInfo,
		time =  UnityEngine.Time.realtimeSinceStartup,
		all_idx = self.m_ObjectCache.idx,
	}
	dIdxGroup[dCache.all_idx] = true
	self.m_ObjectCache[key] = dIdxGroup
	self.m_ObjectCache.contents[dCache.all_idx] = dCache
	self:CheckCacheSize(self.m_ObjectCache, data.resdata.ObjectCacheMaxSize)
end

function CResCtrl.GetObjectFromCache(self, key, dMatchInfo)
	local dIdxGroup = self.m_ObjectCache[key]
	if not dIdxGroup or next(dIdxGroup) == nil then
		return
	end
	local iAllIdx, iTime
	for idx, _ in pairs(dIdxGroup) do
		local dCache = self.m_ObjectCache.contents[idx]
		if dCache.match and dMatchInfo and table.equal(dMatchInfo, dCache.match) then
			iAllIdx = idx
			break
		end
		if not iTime or dCache.time < iTime then
			iTime = dCache.time
			iAllIdx = idx
		end
	end
	local oCache = self.m_ObjectCache.contents[iAllIdx].cache_obj
	dIdxGroup[iAllIdx] = nil
	self.m_ObjectCache.contents[iAllIdx] =nil
	return oCache
end

function CResCtrl.GetMapFromCache(self, resid)
	local idx = self.m_MapCache[resid]
	if idx then
		local mapobj = self.m_MapCache.contents[idx].cache_obj
		self.m_MapCache[resid] = nil
		self.m_MapCache.contents[idx] = nil
		return mapobj
	end
end

function CResCtrl.PutMapInCache(self, resid, mapobj)
	if not self.m_UseCache then
		self.m_MapCache.destroy(mapobj)
		return
	end
	mapobj:SetParent(self.m_MapCache.root, false)
	self.m_MapCache.idx = self.m_MapCache.idx + 1
	local dCache = {
		key = resid,
		cache_obj = mapobj,
		all_idx = self.m_MapCache.idx,
		time =  UnityEngine.Time.realtimeSinceStartup,
	}
	self.m_MapCache[resid] = dCache.all_idx
	self.m_MapCache.contents[dCache.all_idx] = dCache
	
	self:CheckCacheSize(self.m_MapCache, 1)
end

function CResCtrl.CheckCacheSize(self, dAllCache, iSize)
	local lKeys = table.keys(dAllCache.contents)
	table.sort(lKeys)
	local iAdd = 0
	for i = #lKeys, 1, -1 do
		if iAdd >= iSize then
			local idx = lKeys[i]
			local dCache = dAllCache.contents[idx]
			dAllCache.destroy(dCache.cache_obj)
			dCache.cache_obj = nil
			if type(dAllCache[dCache.key]) == "table" then
				dAllCache[dCache.key][idx] = nil
			else
				dAllCache[dCache.key] = nil
			end
			dAllCache.contents[idx] = nil
		else
			iAdd = iAdd + 1
		end
	end
end

function CResCtrl.CheckUnloadAtlas(self)
	-- self.m_UnloadAtlasCounter = self.m_UnloadAtlasCounter - 1
	-- --printerror("CheckUnloadAtlas", self.m_UnloadAtlasCounter)
	-- if self.m_UnloadAtlasCounter < 0 then
	-- 	self:UnloadAtlas(false)
	-- 	print("unload atlas!")
	-- end
end

function CResCtrl.UnloadAtlas(self, bForce)
	self.m_UnloadAtlasCounter = data.resdata.UnloadAtlasCount
	C_api.ResourceManager.UnloadAtlas(bForce)
end


function CResCtrl.GC(self, bAllGC)
	if self.m_ReleaseAssetCnt >= data.resdata.GcAssetReleaseCnt and not self.m_GCSteping then
		self.m_LastGCTime = g_TimeCtrl:GetTimeS()
		LinkTools.ClearAllLinkCache()
		self:CheckManagedAssets(function(oAssetInfo) oAssetInfo:SetNextScneneRelease(false) end)
		self.m_AllGC = self.m_OpenAllGC and bAllGC
		self.m_GCSteping = true
		print("res gc step start!")
	else
		print("res gc skip! m_ReleaseAssetCnt:", self.m_ReleaseAssetCnt)
	end
end

function CResCtrl.GCStep(self)
	if self.m_GCSteping then
		if self.m_AllGC then
			collectgarbage()
			self.m_GCSteping = false
			self.m_AllGC = false
			self:GCFinish()
		else
			local b = collectgarbage("step", data.resdata.GCStep)
			if b then
				self.m_GCSteping = false
				self:GCFinish()
			end
		end
	end
end

function CResCtrl.GCFinish(self)
	C_api.ResourceManager.UnloadUnusedAssetBundle()
	C_api.ResourceManager.UnloadUnusedAssets()
	self.m_ReleaseAssetCnt = 0
	print("res gc finish!")
end

function CResCtrl.ChangeCloneDynamicLevel (self, sType, key)
	local iDlv = data.resdata.DynamicLevel[sType]
	if not iDlv then
		return
	end
	table.safeset(data.resdata.Config, iDlv, key, "dlv")
end

function CResCtrl.ResetCloneDynamicLevel(self)
	local d = data.resdata.Config
	for k, v in pairs(d) do
		v["dlv"] = nil
	end
end

return CResCtrl