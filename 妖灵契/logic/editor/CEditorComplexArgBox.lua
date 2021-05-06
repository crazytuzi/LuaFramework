local CEditorComplexArgBox = class("CEditorComplexArgBox", CEditorArgBoxBase)

function CEditorComplexArgBox.ctor(self, obj)
	CEditorArgBoxBase.ctor(self, obj)
	self.m_Table = self:NewUI(1, CTable)
	self.m_NormalArgBoxClone = self:NewUI(2, CEditorNormalArgBox)
	self.m_NameLabel = self:NewUI(3, CLabel)
	self.m_BgSprite = self:NewUI(4, CSprite)
	self.m_EditBtn = self:NewUI(5, CButton)
	self.m_NormalArgBoxClone:SetActive(false)
	self.m_EditBtn:SetActive(false)
	self.m_StartEditFunc = nil
	self.m_ComplexType = nil
	self.m_ChangeFunc = nil
	self.m_IsEdit = false
	self.m_EditInfo = {}
end

function CEditorComplexArgBox.SetArgInfo(self, dInfo)
	self:SetKey(dInfo.key)
	self.m_NameLabel:SetText(dInfo.name)
	self.m_ComplexType = dInfo.complex_type 
	local list = config.arg[self.m_ComplexType].sublist
	if dInfo.col then
		self.m_Table:SetColumns(dInfo.col)
	end
	self:CheckQuickEdit(dInfo)
	for i, v in ipairs(list) do
		local oBox = self.m_NormalArgBoxClone:Clone()
		oBox:SetActive(true)
		oBox:SetArgInfo(config.arg.template[v])
		if self.m_ChangeFunc then
			oBox:SetValueChangeFunc(self.m_ChangeFunc)
		end
		self.m_Table:AddChild(oBox)
	end
	self.m_Table:Reposition()
	local bouds = UITools.CalculateRelativeWidgetBounds(self.m_Transform)
	self.m_BgSprite:SetSize(bouds.size.x + 15, bouds.size.y + 15)
end

function CEditorComplexArgBox.CheckQuickEdit(self, dInfo)
	local fChange
	local bCanEdit = false
	if dInfo.complex_type == "complex_pos" then
		local oView = CEditorMagicView:GetView()
		local atkid = oView.m_UserCache["atk_id"]
		local vic_ids = oView.m_UserCache["vic_ids"]
		local atkObj, vicObj
		if config.run_env == "createrole" then
			atkObj = g_CreateRoleCtrl:GetBranchWarrior()
			vicObj = atkObj
		elseif config.run_env == "war" then
			atkObj = g_WarCtrl:GetWarrior(atkid)
			vicObj = g_WarCtrl:GetWarrior(vic_ids[1])
		end
		if dInfo.pos_cam then--像机编辑
			fChange = function ()
				local oCam = dInfo.pos_cam()
				local dInfo = self:GetArgData()[self.m_Key]
				for k, v in pairs(dInfo) do
					if v == "nil" then
						return
					end
				end
				if dInfo.base_pos ~= "nil" then
					local vPos = MagicTools.MagicCmdCall(config.run_env, "GetLocalPosByType", dInfo.base_pos, atkObj, vicObj)
					if atkObj ~= vicObj then
						local oRelative = MagicTools.MagicCmdCall(config.run_env, "GetRelativeObj", dInfo.base_pos, atkObj, vicObj)
						if oRelative and dInfo.relative_angle and dInfo.relative_dis then
							vPos = vPos + MagicTools.CalcRelativePos(oRelative,dInfo.relative_angle, dInfo.relative_dis)
						end
					end
					vPos = MagicTools.CalcDepth(vPos, dInfo.depth)
					oCam:SetLocalPos(vPos)
					oCam:LookAt(atkObj.m_WaistTrans, atkObj.m_WaistTrans.up)
				end
			end
		else--位置编辑
			fChange = function()
				local dArgInfo = self:GetArgData()[self.m_Key]
				local dData = self:GetContextCmdData()
				local bFaceDir = dData.look_at_pos and true or false
				local vPos = MagicTools.MagicCmdCall(config.run_env, "GetLocalPosByType", dArgInfo.base_pos, atkObj, vicObj)
				local oRelative = MagicTools.MagicCmdCall(config.run_env, "GetRelativeObj", dArgInfo.base_pos, atkObj, vicObj, bFaceDir)
				if oRelative and dArgInfo.relative_angle and dArgInfo.relative_dis then
					vPos = vPos + MagicTools.CalcRelativePos(oRelative, dArgInfo.relative_angle, dArgInfo.relative_dis)
				end
				vPos = MagicTools.CalcDepth(vPos, dArgInfo.depth)
				g_MagicCtrl:ResetCalcPosObject()
				if self.m_EditInfo.pos_obj then
					self.m_EditInfo.pos_obj:SetPos(vPos)
				end
			end
			self.m_EditStartFunc = function ()
				if Utils.IsExist(self) then
					local obj = self.m_EditInfo.pos_obj or CObject.New(g_ResCtrl:Load("UI/_Editor/PosObj.prefab"):Instantiate())
					self.m_EditInfo.pos_obj = obj
					obj:SetName("拖动设位置")
					if self.m_ChangeFunc then
						self.m_ChangeFunc()
					end
					local function check()
						if Utils.IsExist(self) then
							local dData = self:GetContextCmdData()
							if dData then
								if NGUI.UIInput.selection == nil then
									local bFaceDir = dData.look_at_pos and true or false
									local dArgInfo = self:GetArgData()[self.m_Key]
									local angle, dis, depth = MagicTools.ReverseCalcPos(config.run_env, dArgInfo.base_pos, atkObj,vicObj, obj:GetPos(), bFaceDir)
									local v = {relative_dis=dis,relative_angle=angle, depth=depth, base_pos = dArgInfo.base_pos}
									self:SetValue(v, true, false)
								end
								return true
							end
						end
						obj:Destroy()
						return false
					end
					self.m_CheckTimer = Utils.AddTimer(check, 0, 0)
				end
			end
			bCanEdit = true
		end
	end
	self.m_ChangeFunc = fChange
	self.m_EditBtn:SetActive(bCanEdit)
	self.m_EditBtn:AddUIEvent("click", callback(self, "OnEdit"))
end

function CEditorComplexArgBox.OnEdit(self)
	if self.m_IsEdit then
		self:SetParent(self.m_EditInfo.parent)
		self:SetSiblingIndex(self.m_EditInfo.sibling)
		self:SetLocalPos(self.m_EditInfo.local_pos)
		self.m_EditBtn:SetText("编辑")
		self:SimulateOnEnable()
		if self.m_CheckTimer then
			Utils.DelTimer(self.m_CheckTimer)
		end
		if self.m_EditHideObj then
			self.m_EditHideObj:SetActive(true)
		end
		if self.m_EditInfo.pos_obj then
			self.m_EditInfo.pos_obj:Destroy()
			self.m_EditInfo.pos_obj = nil
		end
		if self.m_DragObjCompnent then
			self.m_DragObjCompnent.target = nil
		end
	else
		self.m_EditBtn:SetText("退出")
		self.m_EditInfo = {local_pos = self:GetLocalPos(), parent = self:GetParent(), sibling=self:GetSiblingIndex()}
		if self.m_EditHideObj then
			self.m_EditHideObj:SetActive(false)
		end
		self:SetParent(UITools.GetUIRootObj(false):GetTransform(), false)
		self:SetLocalPos(Vector3.zero)
		self:SimulateOnEnable()
		if self.m_EditStartFunc then
			self.m_EditStartFunc()
		end
		if self.m_DragObjCompnent then
			self.m_DragObjCompnent.target = self.m_Transform
		end
	end
	self.m_IsEdit = not self.m_IsEdit
end

function CEditorComplexArgBox.GetArgData(self)
	local dVal = {}
	for i, oBox in ipairs(self.m_Table:GetChildList()) do
		local dSub = oBox:GetArgData()
		table.update(dVal, dSub)
	end
	return {[self.m_Key]=dVal}
end

function CEditorComplexArgBox.SetValue(self, v, bInput, bCallback)
	for i, oBox in ipairs(self.m_Table:GetChildList()) do
		local k = oBox:GetKey()
		if k and v[k] ~= nil then
			oBox:SetValue(v[k], bInput, bCallback)
		else
			oBox:ResetDefault()
		end
	end
end

function CEditorComplexArgBox.ResetDefault(self)
	for i, oBox in ipairs(self.m_Table:GetChildList()) do
		oBox:ResetDefault()
	end
end

return CEditorComplexArgBox