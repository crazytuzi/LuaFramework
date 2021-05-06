local CHouseModel = class("CHouseModel", CModel)

function CHouseModel.ctor(self, obj)
	CRenderObject.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_Animator = self:GetComponent(classtype.Animator)
	self.m_OriRuntimeAnimatorController = self.m_Animator.runtimeAnimatorController
	if not self.m_OriRuntimeAnimatorController then
		-- error("没有设置动作Animator·, "..self:GetName())
		return
	end
	if Utils.IsEditor() then
		self.m_DataContainer = self:GetMissingComponent(classtype.DataContainer)
	end
	self.m_Animator.runtimeAnimatorController = self.m_OriRuntimeAnimatorController:Instantiate()
	self.m_IsIgnoreTimescale = false
	self:InitValue()
	self:UpdateMaterials()
	self:InitAnimEffectInfo()
end

function CHouseModel.InitValue(self, obj)
	CModel.InitValue(self)
	self.m_State = "idleHouse"
end

function CHouseModel.LoadAndAction(self, sState, action)
	self:SetState(sState)
	self:CheckLoadAnim(sState)
	self:DelayCall(0, "DoAction", sState, action)
end

function CHouseModel.LoadAnim(self, sAnim)
	self.m_AnimLoadedFrames[sAnim] = UnityEngine.Time.frameCount
	-- local iShape = data.modeldata.SHARE_ANIM[self.m_Shape] or self.m_Shape
	--tzq缺动作临时处理
	local iShape = 11011
	local iAnimType = self.m_AnimType
	local sType = self:GetAnimTypeString(iAnimType)
	local sFileName = string.format("%s%s", sAnim, sType)
	local path
	-- printc(string.format("iShape: %s, iAnimType: %s, sFileName: %s", iShape, iAnimType, sFileName))
	if data.animclipdata.DATA[iShape] then
		if not data.animclipdata.DATA[iShape][iAnimType] or 
			not data.animclipdata.DATA[iShape][iAnimType][sFileName] then
			iAnimType = 1
			sFileName = string.format("%s%s", sAnim, sType)
		end
		path = string.format("Model/Character/%d/Anim/%d_%s.anim", iShape, iShape, sFileName)
		if not data.animclipdata.DATA[iShape][iAnimType] or 
			not data.animclipdata.DATA[iShape][iAnimType][sFileName] then
			print(string.format("%d没有这个动作%s", iShape, sFileName))
			return nil
		end
	else
		print(string.format("%d没有动作时间文件", iShape))
		return nil
	end
	local clip = g_ResCtrl:Load(path)
	self.m_BakAnimatorInfo.controller:set_Item(sAnim, clip)
	self.m_BakAnimatorInfo.clips[sAnim] = clip
	return clip
end

return CHouseModel