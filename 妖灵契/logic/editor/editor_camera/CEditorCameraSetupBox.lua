local CEditorCameraSetupBox = class("CEditorCameraSetupBox", CBox)

function CEditorCameraSetupBox.ctor(self, obj)
	CBox.ctor(self, obj)
	self.m_ArgBoxTable = self:NewUI(1,CTable)
	self.m_SaveBtn = self:NewUI(2, CButton)
	self.m_TestBtn = self:NewUI(3, CButton)
	self.m_SaveInput = self:NewUI(4, CInput)
	self.m_DelBtn = self:NewUI(5, CButton)
	self.m_ArgBoxDict = {}
	self.m_UserCache = {}
	self.m_Data = table.copy(data.cameradata)
	self:InitContent()
end

function CEditorCameraSetupBox.InitContent(self)
	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSave"))
	self.m_DelBtn:AddUIEvent("click", callback(self, "OnDel"))
	self.m_TestBtn:AddUIEvent("click", callback(self, "OnTest"))
	local lKey = {"cam_type", "key_pos"}
	local function initSub(obj, idx)
		local oBox = CEditorNormalArgBox.New(obj)
		local k = lKey[idx]
		local oArgInfo = config.arg.template[k]
		oBox:SetArgInfo(oArgInfo)
		if oArgInfo.change_refresh then
			oBox:SetValueChangeFunc(callback(self, "OnArgChange", oArgInfo.change_refresh))
		end
		self.m_ArgBoxDict[k] = oBox
		return oBox
	end
	self.m_ArgBoxTable:InitChild(initSub)

	local dUserCache = IOTools.GetClientData("editor_camera")
	table.print(dUserCache, "--->editor_camera")
	if dUserCache then
		self.m_UserCache = dUserCache
		for k, oBox in ipairs(self.m_ArgBoxTable:GetChildList()) do
			local v = dUserCache[oBox:GetKey()]
			if v ~= nil then
				oBox:SetValue(v, true)
			end
		end
	end
	self:SetCameType(self.m_ArgBoxDict["cam_type"]:GetValue())
	self:ResetCam()
	self.m_InitDone = true

	CWarCtrl.GetCenterPos = function()
		local sType = self.m_ArgBoxDict["focus_on"]:GetValue()
		if not sType then
			sType = "Center"
		end
		return DataTools.GetLineupPos(sType)
	end
end

function CEditorCameraSetupBox.OnArgChange(self, iFlag, key, value)
	if not self.m_InitDone then
		return
	end
	if key == "cam_type" then
		self:SetCameType(self.m_ArgBoxDict["cam_type"]:GetValue())
	elseif key == "key_pos" then
		self:ResetCam()
	end
	local newVal = self.m_ArgBoxDict[key]:GetValue()
	self:SetUserCache(key, newVal)
end

function CEditorCameraSetupBox.SetCameType(self, type)
	if config.cam_type ~= type then
		config.cam_type = type
		g_CreateRoleCtrl:EndCreateRole()
		g_HouseCtrl:LeaveHouse()
		g_WarCtrl:End()
		if type == "createrole_cam" or type == "createrole_pos" then
			g_CreateRoleCtrl:StartCreateRole()
		elseif type == "house" then
			g_HouseCtrl:EnterHouse()
		else
			warsimulate.Start(8, 140)
		end
	end
end

function CEditorCameraSetupBox.GetCamera(self)
	local type = self.m_ArgBoxDict["cam_type"]:GetValue()
	if type == "war" then
		return g_CameraCtrl:GetWarCamera()
	elseif type == "house" then
		return g_CameraCtrl:GetHouseCamera()
	elseif type == "warrior" then
		return g_WarCtrl:GetWarrior(1)
	elseif type == "createrole_pos" then
		return g_CreateRoleCtrl.m_BranchWarrior
	elseif type == "createrole_cam" then
		return g_CameraCtrl:GetCreateRoleCamera()
	end
end

function CEditorCameraSetupBox.ResetCam(self)
	local type = self.m_ArgBoxDict["cam_type"]:GetValue()
	local name = self.m_ArgBoxDict["key_pos"]:GetValue()
	if type == 'nil' or name =='nil' or data.cameradata.INFOS[type] == nil then
		return
	end
	local info = data.cameradata.INFOS[type][name]
	if not info then
		return
	end
	local oCam = self:GetCamera()
	if oCam then
		oCam:SetPos(Vector3.New(info.pos.x, info.pos.y, info.pos.z))
		oCam:SetRotation(Quaternion.Euler(info.rotate.x, info.rotate.y, info.rotate.z))
	end
end

function CEditorCameraSetupBox.SetUserCache(self, key, val)
	local oldVal = self.m_UserCache[key]
	if not table.equal(oldVal, val) then
		self.m_UserCache[key] = val
		table.print(self.m_UserCache)
		IOTools.SetClientData("editor_camera", self.m_UserCache)
		return true
	else
		return false
	end
end

function CEditorCameraSetupBox.OnSave(self)
	local type = self.m_ArgBoxDict["cam_type"]:GetValue()
	local name = self.m_SaveInput:GetText() 
	if name == "" then
		name = self.m_ArgBoxDict["key_pos"]:GetValue()
	end
	if type == 'nil' or name =='nil' then
		return
	end
	local oCam = self:GetCamera()
	local p = oCam:GetPos()
	local r = oCam:GetRotation().eulerAngles
	if not self.m_Data.INFOS[type] then
		self.m_Data.INFOS[type] = {}
	end
	self.m_Data.INFOS[type][name] = {
		pos = {x=p.x, y=p.y, z=p.z},
		rotate = {x=r.x, y=r.y, z= r.z},
	}
	if type == "house" then
		local rotateY = (self.m_Data.INFOS[type][name].rotate.y % 360)
		if rotateY > 180 then
			self.m_Data.INFOS[type][name].rotate.y = rotateY - 360
		elseif rotateY < -180 then
			self.m_Data.INFOS[type][name].rotate.y = rotateY + 360
		end
	end
	data.cameradata = self.m_Data
	local path = IOTools.GetAssetPath("/Lua/logic/data/cameradata.lua")
	local s = "module(...)\n--camera editor build\n"..table.dump(self.m_Data.INFOS, "INFOS")
	IOTools.SaveTextFile(path, s)
	g_NotifyCtrl:FloatMsg("保存成功  "..path)
end

function CEditorCameraSetupBox.OnTest(self)
	CEditorCameraView:CloseView()
	CEditorMagicView:ShowView()
end

function CEditorCameraSetupBox.OnDel(self)
	local type = self.m_ArgBoxDict["cam_type"]:GetValue()
	local name = self.m_SaveInput:GetText() 
	if name == "" then
		name = self.m_ArgBoxDict["key_pos"]:GetValue()
	end
	if type == 'nil' or name =='nil' then
		return
	end
	if not self.m_Data.INFOS[type] then
		self.m_Data.INFOS[type] = {}
	end
	self.m_Data.INFOS[type][name] = nil
	data.cameradata = self.m_Data
	local path = IOTools.GetAssetPath("/Lua/logic/data/cameradata.lua")
	local s = "module(...)\n--camera editor build\n"..table.dump(self.m_Data.INFOS, "INFOS")
	IOTools.SaveTextFile(path, s)
	g_NotifyCtrl:FloatMsg("删除成功  ")
end


















	-- self.m_NameInput = self.NewUI(1, CInput)
	-- self.m_ChooseBtn = self:NewUI(2, CButton)
	-- self.m_SaveBtn = self:NewUI(3, CButton)
	-- self.m_TypeBox = self.New(2, CEditorNormalArgBox)
	
	-- self.m_ArgTable = self:NewUI(4, CTable)
	-- self.m_ComplexArgBoxClone = self:NewUI(6, CEditorComplexArgBox)
	-- self.m_Data = table.copy(data.cameradata)
	-- self.m_CurName = ""
-- function CEditorCameraSetupBox.InitContent(self)
-- 	self.m_ChooseBtn:AddUIEvent("click", callback(self, "OnChoose"))
-- 	self.m_SaveBtn:AddUIEvent("click", callback(self, "OnSave"))

-- 	self.m_TypeBox:SetArgIngfo(config.arg.template["type"])
-- 	self.m_TypeBox:SetValueChangeFunc(callback(self, "OnChangeType"))
-- end

-- function CEditorCameraSetupBox.OnChangeType(self)

-- end

-- function CEditorCameraSetupBox.OnChoose(self)
-- 	local sType = self.m_TypeBox:GetValue()
-- 	if sType then
-- 		local typelist = table.keys(data.cameradata[sType])
-- 		table.sort(typelist)
-- 		local function sel(v)
-- 			self.m_CurName = v
-- 			self:RefreshArgsTable()
-- 		end
-- 		CMiscSelectView:ShowView(function(oView) 
-- 				oView:SetData(typelist, sel)
-- 			end)
-- 	else
-- 		g_NotifyCtrl:FloatMsg("请先选择类型")
-- 	end
-- end

-- function CEditorCameraSetupBox.OnSave(self)
-- 	-- local dData = 
-- 	data.cameradata = self.m_Data
-- end

-- function CEditorCameraSetupBox.RefreshArgsTable(self)
-- 	self.m_ArgTable:Clear()
-- 	local sType = self.m_TypeBox:GetValue()
-- 	if not sType then
-- 		return
-- 	end
-- 	for i, arg in ipairs(config.action[sType].args) do
-- 		local oBox
-- 		if arg.complex_type then
-- 			oBox = self.m_ComplexArgBoxClone:Clone()
-- 		else
-- 			oBox = self.m_NormalArgBoxClone:Clone()
-- 		end
-- 		oBox:SetActive(true)
-- 		oBox:SetArgInfo(arg)
-- 		self.m_ArgsTable:AddChild(oBox)
-- 	end
-- end



return CEditorCameraSetupBox