local CCreateRoleWarrior = class("CCreateRoleWarrior", CWarrior)

function CCreateRoleWarrior.ctor(self, oAnimEffect)
	CWarrior.ctor(self, 0)
	self:SetLayerDeep(UnityEngine.LayerMask.NameToLayer("CreateRole"))
	self.m_Actor:SetRoot(nil)
	self.m_PosType = nil
	self.m_PosInfo = nil
	self.m_School = 2
	self.m_Branch = 1
	self.m_RoleShape = 0
	self.m_RoleModelInfo = {}
	self.m_NeedPos = false
	self.m_AnimEffect = oAnimEffect
	self.m_AnimEffect:SyncWarriorPos(self)
end

function CCreateRoleWarrior.ExtraInit(self)
	-- self.m_Act or:SetOffsetScale(1.1)
end


function CCreateRoleWarrior.SetSchool(self, i)
	self.m_School = i
	self:RefreshShape()
end

function CCreateRoleWarrior.SetSex(self, sSex)
	self.m_Sex = sSex
	self:RefreshShape()
end

function CCreateRoleWarrior.OnChangeDone(self)
	self.m_Actor:SetModelOutline(0.005)
	self:SetLayerDeep(self.m_GameObject.layer)
	self.m_Actor:LoadMaterial("Material/shadow.mat")
	local iCurMode = g_CreateRoleCtrl:GetCreateData("mode")
	local y = (iCurMode == "school") and 0.29 or 3.3
	self.m_Actor:MainModelCall(CRenderObject.SetShadowHeight, y)
	if self.m_NeedPos then
	else
		if self:GetState() == "showup" then
			self:DelayCall(0, "Showup")
		end
	end
end

function CCreateRoleWarrior.Showup(self)
	self.m_AnimEffect:ShowupAnim(self.m_RoleShape)
	self.m_RotateObj:SetLocalEulerAngles(Vector3.zero)
	self.m_Actor:MainModelCall(CModel.Play, "showup", 0, 1, function()
			if g_CreateRoleCtrl:GetCreateData("mode") == "school" then
				self:Play("idleCity")
			else
				self:Play("idleWar")
			end
		end)
end

function CCreateRoleWarrior.SetBranch(self, i)
	self.m_Branch = i
	self:RefreshShape()
end

function CCreateRoleWarrior.RefreshShape(self)
	if not (self.m_School and self.m_Branch) then
		return
	end
	local iCurMode = g_CreateRoleCtrl:GetCreateData("mode")
	local iSex = (self.m_Sex == "male") and 1 or 2
	local roletype = data.roletypedata.MAP[iSex][self.m_School]
	local iShape = data.roletypedata.DATA[roletype].shape
	local weapon
	for i, v in ipairs(data.roletypedata.BRANCH_TYPE) do
		if v.school == self.m_School and v.branch == self.m_Branch then
			weapon = v.weapon
			break
		end
	end
	self.m_RoleShape = iShape
	self.m_RoleModelInfo = {weapon = weapon}
	-- table.index({110, 120, 130, 140, 160}, self.m_RoleShape) and 
	if iCurMode == "school" then
		self:ChangeShape(iShape+1, self.m_RoleModelInfo)
		self:PosAnim()
	else
		self:ChangeShape(iShape, self.m_RoleModelInfo)
		self:Play("idleWar")
	end
end

function CCreateRoleWarrior.GetShape(self)
	return self.m_RoleShape
end

function CCreateRoleWarrior.GetPosType(self)
	return self.m_PosType
end

function CCreateRoleWarrior.InitPosType(self, sPosType, lTypeList)
	self.m_PosType = sPosType
	self.m_TypeList = lTypeList
	self.m_PosInfo = g_CameraCtrl:GetCameraInfo("createrole_pos", sPosType)
	self:UpdateWarriorPos(0)
	self:PosAnim()
end

function CCreateRoleWarrior.PosAnim(self)
	if self.m_PosType and self.m_PosType == "mid" then
		self:DelayCall(0, "Showup")
	else
		self:Play("idleCity")
	end
end

function CCreateRoleWarrior.OutScene(self)
	self.m_RotateObj:SetLocalEulerAngles(Vector3.zero)
	self.m_AnimEffect:OutSceneAnim()
	self.m_Actor:Play("outScene", 0, 1, function()
			if Utils.IsExist(self) then
				self:RefreshShape()
			end
			local oView = CCreateRoleView:GetView()
			if oView then
				oView:ShowBranchPage()
			end
		end)
	
end

function CCreateRoleWarrior.UpdateWarriorPos(self, iDir)
	local iPosIdx = table.index(self.m_TypeList, self.m_PosType)
	local iEndIdx = iPosIdx + iDir
	if iEndIdx > #self.m_TypeList or iEndIdx < 1 then
		iDir = 0
	end
	local sEndPosType
	if iDir > 0 then
		sEndPosType = self.m_TypeList[iPosIdx+1]
	elseif iDir < 0 then
		sEndPosType = self.m_TypeList[iPosIdx-1]
	end
	if not sEndPosType then
		sEndPosType = self.m_PosType
	end
	local dBeginPosInfo = self.m_PosInfo
	local dEndPosInfo = g_CameraCtrl:GetCameraInfo("createrole_pos", sEndPosType)
	local iLerp = math.abs(iDir)
	local vPos = Mathf.Lerp(dBeginPosInfo.pos, dEndPosInfo.pos, iLerp)
	local vRotate =  Mathf.Lerp(dBeginPosInfo.rotate, dEndPosInfo.rotate, iLerp)
	self:SetPos(vPos)
	self:SetLocalEulerAngles(vRotate)
	local color
	local colorfade = Color.New(0.3,0.3,0.3,1)
	if self.m_PosType == "mid" then
		color = Mathf.Lerp(Color.white,  colorfade, iLerp)
	else
		color = Mathf.Lerp(colorfade, Color.white, iLerp)
	end
	self:SetMatColor(color)
	if iDir == 1 or iDir == -1 then
		if self.m_PosType ~= sEndPosType then
			self.m_PosType = sEndPosType
			self.m_PosInfo = dEndPosInfo
			self:PosAnim()
		end
	end
end

function CCreateRoleWarrior.GetSex(self)
	return self.m_Sex
end

return CCreateRoleWarrior