local CHouseActor = class("CHouseActor", CActor)

function CHouseActor.InitValue(self)
	CActor.InitValue(self)
	self.m_PartModels = {}
end

function CHouseActor.AllModelCall(self, func, ...)
	CActor.AllModelCall(self, func, ...)
	local list = {}
	for i, oModel in pairs(self.m_PartModels) do
		table.insert(list, oModel)
	end
	for i, oModel in pairs(list) do
		func(oModel, ...)
	end
end

function CHouseActor.DestroyAllModel(self)
	CActor.DestroyAllModel(self)
	for i, oModel in pairs(self.m_PartModels) do
		oModel:Recycle()
	end
	self.m_PartModels = {}
end

function CHouseActor.CheckAnim(self, sAnim)
	if self.m_PartModels and table.count(self.m_PartModels) > 0 then
		for k,v in pairs(self.m_PartModels) do
			v:CheckLoadAnim(sAnim)
		end
	end
	if self.m_MainModel then
		self.m_MainModel:CheckLoadAnim(sAnim)
	end
end

function CHouseActor.OnChangeDone(self, iShape, oClone, sPath)
	if self.m_Shape ~= iShape then
		g_ResCtrl:PutCloneInCache(sPath, oClone)
		return
	end
	if self.m_MainModel then
		print("Actor:已存在MainModel")
		self.m_MainModel:Recycle()
		self.m_MainModel = nil
	end
	-- self:SetName(string.format("Actor_%d", iShape))
	self:Resize()
	self:LoadSubModels()
	if oClone then
		self.m_MainModel = CHouseModel.New(oClone)
		if not self:MountToParentModel() then
			self.m_MainModel:SetParent(self.m_Transform)
		end
		self:SetupModel(self.m_MainModel, iShape, sPath)
		self.m_MainModel:SetInfo(self.m_ModelInfos["main"])
		if self.m_PartModels then
			for k,v in pairs(self.m_PartModels) do
				v:SetRuntimeAnimator(self.m_MainModel:GetRuntimeAnimator())
			end
		end
		self:Play(self:GetState())
		self:SetLayerDeep(self:GetLayer())
		
		local v1, v2, v3 = self.m_MainModel:GetHeights()
		local tHeightInfo = {
			head_height = v1 and self:InverseTransformPoint(v1).y or nil,
			waist_height = v2 and self:InverseTransformPoint(v2).y or nil,
			foot_height = v3 and self:InverseTransformPoint(v3).y or nil,
		}
		self:SetHeightInfo(tHeightInfo)
		for i, cb in pairs(self.m_MainModelCbList) do
			cb()
		end
	end
	self.m_MainModelCbList = {}
	if self.m_ChangeDoneCb then
		self.m_ChangeDoneCb()
	end
end


function CHouseActor.ChangePartShape(self, iPart, iShape, dModelInfo, cb)
	if not iShape then
		printerror("CHouseActor.ChangeShape 参数错误:", iShape, dModelInfo, cb)
		return
	end
	dModelInfo = table.copy(dModelInfo) or {}
	if self.m_ModelInfos[iPart] and self.m_ModelInfos[iPart].shape == iShape then
		if cb then
			Utils.AddTimer(cb, 0, 0)
		end
	else
		self.m_ModelInfos[iPart] = dModelInfo
		self.m_ChangePartDoneCb = cb
		local sPath = self:GetPath(iShape)
		g_ResCtrl:LoadCloneAsync(sPath, callback(self, "OnPartChangeDone", iPart, iShape), self.m_PriorLoad)
	end
end

function CHouseActor.OnPartChangeDone(self, iPart, iShape, oClone, sPath)
	if self.m_ModelInfos[iPart] and self.m_ModelInfos[iPart].shape and self.m_ModelInfos[iPart].shape ~= iShape then
		g_ResCtrl:PutCloneInCache(sPath, oClone)
		return
	end
	if self.m_PartModels[iPart] then
		print("Actor:已存在MainModel iPart: " .. iPart)
		self.m_PartModels[iPart]:Recycle()
		self.m_PartModels[iPart] = nil
	end
	self:Resize()
	if oClone then
		local oModel = CHouseModel.New(oClone)
		oModel:SetParent(self.m_Transform)
		oModel:SetLayerDeep(self.m_GameObject.layer)
		self:SetupModel(oModel, self.m_Shape, sPath)
		oModel:SetInfo(self.m_ModelInfos[iPart])
		self.m_PartModels[iPart] = oModel
		if self.m_MainModel then
			oModel:SetRuntimeAnimator(self.m_MainModel:GetRuntimeAnimator())
		end
		self:Play(self:GetState())

		if self.m_ChangePartDoneCb then
			self.m_ChangePartDoneCb()
		end
	end
end

return CHouseActor