local CRenderObject = class("CRenderObject", CObject)
CRenderObject.g_BatchCall = true
--处理材质，Renderer
function CRenderObject.ctor(self, obj)
	CObject.ctor(self, obj)
	self.m_RenderHandler = self:GetMissingComponent(classtype.RenderObjectHandler)
	self.m_BatchCallID = self.m_RenderHandler:GetInstanceID()
	self:InitValue()
end

function CRenderObject.InitValue(self)
	self.m_CallOnceFlags = {} --已经回调过的列表
	self.m_Renderers = {} --所有renderers
	self.m_RenderObjIDs = {} --已经查找过renrders的gameObject的id
	self.m_MatLoadInfo = {} --材质的加载状态
	self.m_Materials = {} --所有材质
	self.m_MatRendererMap = {} --材质和已经挂载的renderer映射
	self.m_Outline = nil --描边
	self.m_Color = nil --颜色
	self.m_ShadowHeight = nil --投影高度
end

--所有材质都会调用一次
function CRenderObject.MatsCallOnce(self, f)
	-- self.m_MatsCallOnce = f
	-- self.m_CallOnceFlags = {} --重置
	-- for i, material in pairs(self.m_Materials) do
	-- 	self:CheckMatCallOnce(material)
	-- end
end

function CRenderObject.PushBatchCall(self, funcName, ...)
	local iEnum = enum.BatchCall.FuncType[funcName]
	if CRenderObject.g_BatchCall and iEnum then
		g_BatchCallCtrl:PushCallData(enum.BatchCall.ObjType.RenderObjectHandler, 
		self.m_BatchCallID, iEnum, ...)
	else
		local c = string.sub(funcName, 1, 1)
		if string.upper(c) == c then
			-- printc(funcName, ...)
			-- printtrace()
			self.m_RenderHandler[funcName](self.m_RenderHandler, ...)
		else
			self.m_RenderHandler[funcName] = select(1, ...)
		end
	end
end

function CRenderObject.SetShadowHeight(self, i)
	if i and self.m_ShadowHeight ~= i then
		self.m_ShadowHeight = i
		self:PushBatchCall("shadowHeight", i)
	end
end

function CRenderObject.SetMatColor(self, color)
	if color and self.m_Color ~= color then
		self.m_Color = color
		self:PushBatchCall("matColor", color)
	end
end

function CRenderObject.SetOutline(self, i)
	if i and self.m_Outline ~= i then
		self.m_Outline = i
		self:PushBatchCall("outline", i)
	end
end

function CRenderObject.LoadMaterial(self, sPath, dInfo)
	dInfo = dInfo or {}
	local oOldInfo = self.m_MatLoadInfo[sPath]
	if oOldInfo then
		if oOldInfo.loading then -- 正在加载
			-- printc("--正在加载", sPath)
			dInfo.loading = true
			self.m_MatLoadInfo[sPath] = dInfo
			return
		else
			if oOldInfo.mat then -- 已经加载
				-- printc("--已经加载", sPath)
				if oOldInfo.deltimer then
					Utils.DelTimer(oOldInfo.deltimer)
					oOldInfo.deltimer = nil
				end
				if oOldInfo.timer then
					-- printc("--已经加载, 删除原来Timer")
					Utils.DelTimer(oOldInfo.timer)
				end
				-- printc("--重新渐变Alpha", sPath, dInfo.show_time)
				local time = dInfo.show_time or 0
				self:FadeShow(oOldInfo.mat.name, time)
				if dInfo.alive_time then
					dInfo.timer = Utils.AddScaledTimer(callback(self, "DelMaterial", sPath), 0, dInfo.alive_time)
				end
				dInfo.mat = oOldInfo.mat
				dInfo.matid = oOldInfo.matid
				dInfo.matname = oOldInfo.matname
				self.m_MatLoadInfo[sPath] = dInfo
				return
			end
		end
	end
	--没有load过的
	-- printc("--没有load过的", sPath)
	dInfo.loading = true
	self.m_MatLoadInfo[sPath] = dInfo
	g_ResCtrl:LoadAsync(sPath, callback(self, "OnMatLoadDone"))
end

function CRenderObject.OnMatLoadDone(self, oMat, sPath)
	local dInfo = self.m_MatLoadInfo[sPath]
	if oMat and dInfo and dInfo.loading then
		if dInfo.alive_time then
			self.m_MatLoadInfo[sPath].timer = Utils.AddScaledTimer(callback(self, "DelMaterial", sPath), 0, dInfo.alive_time)
		end
		dInfo.loading = false
		dInfo.mat = oMat
		dInfo.matname = IOTools.GetFileName(sPath, true)
		dInfo.matid = oMat:GetInstanceID()
		self.m_MatLoadInfo[sPath] = dInfo
		
		self:AddMaterial(oMat)
		if dInfo.show_time then
			-- printc("--渐变Alpha", sPath, dInfo.show_time)
			self:FadeShow(dInfo.matname, dInfo.show_time)
		end
	end
end

function CRenderObject.FadeShow(self, sName, time)
	self:PushBatchCall("FadeShow", sName, time)
end

function CRenderObject.FadeHide(self, sName, time)
	self:PushBatchCall("FadeHide", sName, time)
end

function CRenderObject.UpdateMaterials(self)
	self:StopDelayCall("UpdateMaterials")
	self.m_Materials = Utils.GetMaterials({self.m_GameObject})
	-- for i, material in ipairs(self.m_Materials) do
	-- 	self:CheckMatCallOnce(material)
	-- end
	self:PushBatchCall("SetMats", self.m_Materials)
end

function CRenderObject.CheckMatCallOnce(self, material)
	local id = material:GetInstanceID()
	if self.m_MatsCallOnce and not self.m_CallOnceFlags[id] then
		self.m_CallOnceFlags[id] = true
		self.m_MatsCallOnce(material)
	end
end

function CRenderObject.AddMaterial(self, oMat)
	self:AddRenderObj(self.m_GameObject)
	self:RenderersCall(function(info)
			self:RendererAddMat(info.rendererid, info.renderer, oMat:GetInstanceID(), oMat)
		end)
end

function CRenderObject.RendererAddMat(self, rendererid, renderer, matid, mat)
	if not self.m_MatRendererMap[matid] then
		self.m_MatRendererMap[matid] = {}
	end
	if not self.m_MatRendererMap[matid][rendererid] then
		self:PushBatchCall("RenderAddMat", renderer, mat)
		self.m_MatRendererMap[matid][rendererid] = true
	end
end

function CRenderObject.DelMaterial(self, sPath)
	local dInfo = self.m_MatLoadInfo[sPath]
	if not dInfo or dInfo.loading or not dInfo.mat then --还在加载之中
		self.m_MatLoadInfo[sPath] = nil
		return
	end
	if dInfo.deltimer then
		return
	end
	self:AddRenderObj(self.m_GameObject)
	local iFadeHideTime = dInfo.hide_time or 0
	if iFadeHideTime > 0 then
		self:RenderersCall(function(info)
			self:FadeHide(dInfo.matname, iFadeHideTime)
		end)
		--延迟删除
		dInfo.deltimer = Utils.AddScaledTimer(
			callback(self, "RealDelMat", sPath, dInfo.matid, dInfo.matname),
			0, iFadeHideTime)
	else
		self:RealDelMat(sPath, dInfo.matid, dInfo.matname)
	end
end

function CRenderObject.RealDelMat(self, sPath, iMatID, sMatName)
	self:RenderersCall(function(info)
			local renderer = info.renderer
			if self.m_MatRendererMap[iMatID] then
				self.m_MatRendererMap[iMatID][info.rendererid] = nil
			end
			self:PushBatchCall("RenderDelMat", renderer, sMatName)
		end)
	self.m_MatLoadInfo[sPath] = nil
end

function CRenderObject.AddRenderObj(self, gameObject, bNotCheckValid)
	local id = gameObject:GetInstanceID()
	if not self.m_RenderObjIDs[id] then
		local arr = gameObject:GetComponentsInChildren(classtype.Renderer, true)
		for i=0, arr.Length-1 do
			local renderer = arr[i]
			if bNotCheckValid or self:IsValidRenderer(renderer) then
				self:PushBatchCall("AddRenderObj", renderer)
				local rendererid = renderer:GetInstanceID()
				self.m_Renderers[rendererid] = {renderer = renderer, rendererid=renderer:GetInstanceID(), ori_mat_cnt = renderer.materials.Length, name = renderer.name}
				if next(self.m_MatLoadInfo) then
					for i, info in pairs(self.m_MatLoadInfo) do
						if info.mat then
							self:RendererAddMat(rendererid, renderer, info.matid, info.mat)
						end
					end
				end
			end
		end
		self.m_RenderObjIDs[id] = true
	end
end

function CRenderObject.UpdateRenderObj(self, gameObject)
	local id = gameObject:GetInstanceID()
	self.m_RenderObjIDs[id] = nil
	self:AddRenderObj(gameObject)
end

function CRenderObject.IsValidRenderer(self, renderer)
	if renderer.material then
		if string.find(renderer.material.shader.name, "^Baoyu/Model/") or 
			string.find(renderer.gameObject.name, "adorn") then
			return true
		end
	end
	return false
end

function CRenderObject.DelRenderObj(self, gameObject)
	local id = gameObject:GetInstanceID()
	if self.m_RenderObjIDs[id] then
		arr = gameOblocal ject:GetComponentsInChildren(classtype.Renderer, true)
		for i=0, arr.Length-1 do
			local renderer = arr[i]
			local renderid = renderer:GetInstanceID()
			local dInfo = self.m_Renderers[renderid]
			if dInfo then
				for k, v in pairs(self.m_MatRendererMap) do
					v[renderid] = nil
				end
				self:PushBatchCall("DelRenderObj", renderer, dInfo.ori_mat_cnt)
				self.m_Renderers[renderid] = nil
			end
		end
		self.m_RenderObjIDs[id] = nil
	end
end

function CRenderObject.RenderersCall(self, func)
	if next(self.m_Renderers) then
		local delkeys = {}
		for id, v in pairs(self.m_Renderers) do
			if v.renderer then
				xxpcall(func, v)
			else
				delkeys[id] = true
			end
		end
		for k, v in pairs(delkeys) do
			self.m_Renderers[k] = nil
		end
	end
end

function CRenderObject.Recycle(self)
	self:RenderersCall(function(info)
				self:PushBatchCall("RenderResizeMatCnt", info.renderer, info.ori_mat_cnt)
			end)
	self:SetMatColor(Color.white)
	self:SetOutline(0)
end


-- function CRenderObject.DelMaterialOld(self, sPath)
-- 	local dInfo = self.m_MatLoadInfo[sPath]
-- 	if not dInfo or dInfo.loading or not dInfo.mat then --还在加载之中
-- 		self.m_MatLoadInfo[sPath] = nil
-- 		return
-- 	end
	
-- 	self:AddRenderObj(self.m_GameObject)
-- 	local lRealdel = {}
-- 	local lRenderersCnt = table.count(self.m_Renderers)
-- 	local function chekdelmat(renderer)
-- 		lRealdel[renderer] = true
-- 		if table.count(lRealdel) == lRenderersCnt then
-- 			self.m_MatLoadInfo[sPath] = nil
-- 		end
-- 	end
-- 	local matid = dInfo.matid
-- 	local matname = dInfo.matname
-- 	self:RenderersCall(function(info)
-- 		local renderer = info.renderer
-- 		local arr = renderer.materials
-- 		local lRetain = {}
-- 		local lDel = {}
-- 		for i=0, arr.Length-1 do
-- 			local oMat = arr[i]
-- 			if string.find(oMat.name, matname) == nil then
-- 				table.insert(lRetain, oMat)
-- 			else
-- 				table.insert(lDel, oMat)
-- 			end
-- 		end
-- 		if #lRetain == arr.Length then
-- 			chekdelmat(renderer)
-- 			return
-- 		end
-- 		local newArr = System.Array.CreateInstance(classtype.Material, #lRetain)
-- 		for i = 1, #lRetain do
-- 			newArr[i-1] = lRetain[i]
-- 		end
-- 		local function realdel()
-- 			if Utils.IsNil(self) then
-- 				return
-- 			end
-- 			if self.m_MatRendererMap[matid] then
-- 				self.m_MatRendererMap[matid][renderer:GetInstanceID()] = nil
-- 			end
-- 			renderer.materials = newArr
-- 			chekdelmat(renderer)
-- 			self:DelayCall(0, "UpdateMaterials")
-- 		end
-- 		if dInfo.hide_time and dInfo.hide_time > 0 then
-- 			for i, oMat in ipairs(lDel) do
-- 				DOTween.DOKill(oMat, false)
-- 				oMat:SetFloat("_Alpha", 1)
-- 				-- printc("DelMaterial", oMat.name, dInfo.hide_time)
-- 				local tweener = DOTween.DOFloat(oMat, 0, "_Alpha", dInfo.hide_time)
-- 				DOTween.SetEase(tweener, enum.DOTween.Ease.Linear)
-- 				if i == 1 then
-- 					DOTween.OnComplete(tweener, realdel)
-- 				end
-- 			end
-- 		else
-- 			realdel()
-- 		end
-- 	end)
-- end
return CRenderObject