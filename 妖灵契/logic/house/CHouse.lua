local CHouse = class("CHouse", CObject)

function CHouse.ctor(self)
	local obj = UnityEngine.GameObject.New()
	obj.name = "HouseRoot"
	CObject.ctor(self, obj)
	self.m_InstanceID2Obj = {}
	self.m_Furnitures = {}
	self.m_Partners = {}
	self.m_Adorns = {}
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
	self.m_NotCookingEffect = nil
	self.m_CookingEffect = nil
	g_HouseCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnHouseEvent"))
end

function CHouse.Destroy(self)
	for k, v in pairs(self.m_Partners) do
		v:Destroy()
	end
	for k, v in pairs(self.m_Furnitures) do
		v:Destroy()
	end
	CObject.Destroy(self)
end

function CHouse.OnMapEvent(self, oCtrl)
	-- printc("OnMapEvent")
	if oCtrl.m_EventID == define.Map.Event.MapLoadDone then
		local obj = oCtrl.m_EventData
		g_CameraCtrl:AutoActive()
		if obj and obj:Find("Model") then
			self:InitFurniture(obj:Find("Model"))
		elseif obj then
			printerror("OnMapEvent obj.name: " .. obj:GetName())
		else
			printerror("OnMapEvent obj nil")
		end
		self:LoadWalkers()
		self:ResetWalkerPos()
		g_NotifyCtrl:HideConnect()
		return false
	end
end

function CHouse.OnHouseEvent(self, oCtrl)
	self:CheckTeaArt()
end

function CHouse.CheckTeaArt(self)
	if self.m_Furnitures["door"] == nil then
		return
	end
	if g_HouseCtrl:IsInHouse() and (not g_HouseCtrl:IsInFriendHouse()) and g_HouseCtrl:IsNeedTeaArtRedDot() then
		local trans = self.m_Furnitures["door"]:NewBindTransform(Vector3.New(0.2,-4.85,-2.82))
		self.m_Furnitures["door"]:AddHud("furniture", CFurnitureHud, trans, function(oHud) 
			oHud:SetActive(true) 
			oHud:ShowFingerEffect(false)
		end, false)
	else
		self.m_Furnitures["door"]:DelHud("furniture")
	end
end

function CHouse.ShowTearArtFinger(self, b)
	if self.m_Furnitures["door"] == nil then
		return
	end
	if g_HouseCtrl:IsInHouse() and b == true then
		local trans = self.m_Furnitures["door"]:NewBindTransform(Vector3.New(0.2,-4.85,-2.82))
		self.m_Furnitures["door"]:AddHud("furniture", CFurnitureHud, trans, function(oHud)
			 oHud:SetActive(true) 
			 oHud:ShowFingerEffect(b)
		end, false)
	else
		self.m_Furnitures["door"]:DelHud("furniture")
	end
end

function CHouse.InitFurniture(self, gameObject)
	-- local dData = data.housedata.DATA[1]
	local dData = {}
	for k,v in pairs(data.housedata.FurnitureType) do
		if v.obj_name ~= "" then
			dData[v.obj_name] = v
		end
	end
	local transform = gameObject:Find("Model").transform
	local iCnt = transform.childCount
	for idx=0, iCnt-1 do
		local child = transform:GetChild(idx)
		if dData[child.name] then
			local key = dData[child.name].id
			local oFurniture = CFurniture.New(child.gameObject, key)
			self.m_InstanceID2Obj[oFurniture:GetInstanceID()] = oFurniture
			self.m_Furnitures[key] = oFurniture
			--tzq 初始屏蔽点击，装修时开启
			oFurniture.m_BoxCollider.enabled = false
		end
		if child.name == "Object083" then
			local oFurniture = CFurniture.New(child.gameObject, "door")
			self.m_InstanceID2Obj[oFurniture:GetInstanceID()] = oFurniture
			self.m_Furnitures["door"] = oFurniture
			oFurniture:AddInitHud("furniture")
			self:CheckTeaArt()
			local oEffect = CEffect.New("Effect/Scene/sence_eff_6000/Prefabs/sence_eff_6000_door.prefab", oFurniture:GetLayer(), false)
			oEffect:SetParent(oFurniture.m_Transform)
			oEffect:SetLocalPos(Vector3.New(0.2,-4.85,-2.12))
			oEffect:SetLocalRotation(Quaternion.Euler(90, 0, 0))
			self.m_CookingEffect = oEffect
		end
		-- local key = dData.Furniture[child.name]
		-- if key then
		-- 	print("InitFurniture", child.name, key)
		-- 	local oFurniture = CFurniture.New(child.gameObject, key)
			-- self.m_InstanceID2Obj[oFurniture:GetInstanceID()] = oFurniture
		-- 	self.m_Furnitures[key] = oFurniture
		-- end
	end
end

function CHouse.LoadWalkers(self)
	g_DialogueAniCtrl:StopAllDialogueAni()
	g_NotifyCtrl:ClearFloat()
	g_DialogueAniCtrl:PlayDialgueAni(g_HouseCtrl:GetRandomDialogID())

	-- local list = g_HouseCtrl:GetPartnerList()
	-- for i, dPartnerInfo in ipairs(list) do
	-- 	self:AddPartner(dPartnerInfo)
	-- end
end


function CHouse.GetObjectByInstanceID(self, id)
	return self.m_InstanceID2Obj[id]
end

function CHouse.SetHouseMode(self, iMode)
	for k, oFurniture in pairs(self.m_Furnitures) do
		oFurniture:SetFurnitureMode(iMode)
	end
end

function CHouse.AddPartner(self, dInfo, oHousePartner)
	if self.m_Partners[dInfo.type] then
		printc("伙伴重复了哦: " .. dInfo.type)
		-- return
	end
	oHousePartner:SetModelInfo(dInfo)
	oHousePartner:SetParent(self.m_Transform)
	self.m_Partners[dInfo.type] = oHousePartner
	self.m_InstanceID2Obj[oHousePartner:GetInstanceID()] = oHousePartner
end

function CHouse.GetPartner(self, housePartnerType)
	return self.m_Partners[housePartnerType]
end

function CHouse.AddPlayer(self, oHousePlayer)
	oHousePlayer:SetParent(self.m_Transform)
end

function CHouse.ResetWalkerPos(self)
	for k, v in pairs(self.m_Partners) do
		v:ResetHeight()
	end
end

return CHouse