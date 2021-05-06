local CBindObjBase = class("CBindObjBase", CGameObjContainer)

function CBindObjBase.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_HeadTrans = self:GetContainTransform(1) or self.m_Transform
	self.m_WaistTrans = self:GetContainTransform(2) or self.m_Transform
	self.m_FootTrans = self:GetContainTransform(3) or self.m_Transform
	self.m_ChestTrans = self:GetContainTransform(4) or self.m_Transform
	self.m_BodyTrans = self:GetContainTransform(5) or self.m_Transform

	self.m_MainHud = nil
	
	self.m_Huds = {}
	self.m_Effects = {}
	self.m_BindData = {}
	self.m_TitleTrans = nil
	self.m_HeadTransPos = Vector3.zero
	self.m_TitleHeadPos = Vector3.zero

	self.m_HudLoadCb = nil

	self:AddInitHud("chat")
	self:AddInitHud("name")
	self:AddInitHud("blood")
	self:AddInitHud("float_tip")
	self:AddInitHud("title")
	self:AddInitHud("terrawar")
end
--常用函数start
function CBindObjBase.SetBindData(self, data)
	self.m_BindData = data
end

function CBindObjBase.GetMainHud(self)
	if not self.m_MainHud then
		self.m_MainHud = g_HudCtrl:GetEmptyHud()
		self.m_MainHud:SetGameCamera(self:GetHudCamera().m_Camera)
		self.m_MainHud:SetTarget(self.m_WaistTrans)
	end
	return self.m_MainHud
end

function CBindObjBase.AddBindObj(self, sType)
	if sType == "auto_find" then
		return
	end	
	local dEffectInfo = self.m_BindData[sType]
	if not dEffectInfo then
		return
	end
	local trans = self:GetBindTrans(dEffectInfo.body)
	if dEffectInfo.type == "hud" then
		self:AddHud(sType, getgloalvar(dEffectInfo.hud), trans)
	elseif dEffectInfo.type == "effect" then
		self:AddEffect(dEffectInfo.path, dEffectInfo.cached, trans, dEffectInfo.offset)
	end
end

function CBindObjBase.DelBindObj(self, sType)
	if sType == "auto_find" then
		return
	end
	local dEffectInfo = self.m_BindData[sType]
	if dEffectInfo then
		if dEffectInfo.type == "hud" then
			self:DelHud(sType)
		elseif dEffectInfo.type == "effect" then
			self:DelEffect(dEffectInfo.path, dEffectInfo.cached)
		end
	else
		self:DelHud(sType)
	end
end

function CBindObjBase.ClearBindObjs(self)
	self:ClearEffect()
	self:ClearHud()
end

function CBindObjBase.GetBindTrans(self, sType)
	if sType == "head" then
		return self.m_HeadTrans
	elseif sType == "waist" then
		return self.m_WaistTrans
	elseif sType == "foot" then
		return self.m_FootTrans
	elseif sType == "chest" then
		return self.m_ChestTrans
	else
		return self.m_Transform
	end
end

function CBindObjBase.NewBindTransform(self, pos)
	local go = UnityEngine.GameObject.New()
	local transform = go.transform
	transform:SetParent(self.m_Transform, false)
	transform.localPosition = pos
	go.name = "BindTransform"
	go.layer = self:GetLayer()
	return transform
end
--常用函数end
function CBindObjBase.ChatMsg(self, oMsg)
	local trans = self:GetBindTrans("head")
	self:AddHud("chat", CChatHud, trans, function(oHud) oHud:AddMsg(oMsg) end, true)
end

function CBindObjBase.SetBlood(self, percent)
	local trans = self:GetBindTrans("head")
	self:AddHud("blood", CBloodHud, trans, function(oHud) oHud:SetHP(percent) end, false)
end

function CBindObjBase.SetNameHud(self, name, arenaTitleInfo, footTitleInfo)
	name = name or ""
	local trans = self:GetBindTrans("foot")
	self:AddHud("name", CNameHud, trans, function(oHud) oHud:SetName(name, arenaTitleInfo, footTitleInfo) end, false)
end

function CBindObjBase.SetTitleHud(self, headTitleInfo)
	self.m_HeadTitleInfo = headTitleInfo
	self:AddHud("title", CTitleHud, self.m_HeadTrans, function(oHud) 
		oHud:SetTitle(headTitleInfo) 
		end, false)
end

function CBindObjBase.SetTerraWarHud(self, orgid, orgflag, owner)
	local trans = self:GetBindTrans("head")
	self:AddHud("terrawar", CTerraWarHud, trans, function(oHud) oHud:SetTerraWarHud(orgid, orgflag, owner) end, true)
end

function CBindObjBase.DelTerraWarHud(self)
	self:DelHud("terrawar")
end

function CBindObjBase.AddFloatTip(self, sText)
	local trans = self:GetBindTrans("head")
	self:AddHud("float_tip", CFloatTipHud, trans, function(oHud) oHud:AddTipText(sText) end, true)
end

function CBindObjBase.ClearHud(self)
	if self.m_MainHud then
		self.m_MainHud:Destroy()
	end
	for sType, dHudInfo in pairs(self.m_Huds) do
		self:DelHud(sType)
	end
end

function CBindObjBase.AddHud(self, sType, cls, mountTrans, donecb, bSaveCbInList)
	local oHud = self.m_Huds[sType].obj
	if oHud then
		if donecb then
			donecb(oHud)
		end
	else
		if bSaveCbInList then
			table.insert(self.m_Huds[sType].done_cb_list, donecb)
		else
			self.m_Huds[sType].done_cb_list = {donecb}
		end
		self.m_Huds[sType].valid = true
		if not self.m_Huds[sType].loading then
			self.m_Huds[sType].loading = true
			self.m_Huds[sType].trans = mountTrans
			g_HudCtrl:AddHudByCls(cls, self:GetLoadDoneFunc(sType))
		end
	end
end

function CBindObjBase.DelHud(self, sType)
	local dHudInfo = self.m_Huds[sType]
	if dHudInfo then
		if dHudInfo.obj then
			dHudInfo.obj:SetOwner(nil)
			g_HudCtrl:SetUnused(dHudInfo.obj)
		end
		self:AddInitHud(sType, dHudInfo.init_func)
	end
	if self:IsNeedRefreshPos(sType) then
		self:DelayCall(0, "RefreshHudPos")
	end
end

function CBindObjBase.GetHud(self, sType)
	local dHudInfo = self.m_Huds[sType]
	if dHudInfo then
		if dHudInfo.obj then
			return dHudInfo.obj
		end
	end
	return nil
end

function CBindObjBase.AddInitHud(self, sType, initFunc)
	self.m_Huds[sType] = {init_func = initFunc, obj=nil, loading=false, 
	done_cb_list={}, valid=false, trans= nil}
end

function CBindObjBase.GetHudCamera(self)
	return g_CameraCtrl:GetMainCamera()
end

function CBindObjBase.GetLoadDoneFunc(self, sType)
	return function(oHud)
			if Utils.IsExist(self) then 
				self:OnHudLoadDone(sType, oHud)
			else
				g_HudCtrl:SetUnused(oHud)
			end
		end
end

function CBindObjBase.SetHudLoadCb(self, cb)
	self.m_HudLoadCb = cb
end

function CBindObjBase.OnHudLoadDone(self, sType, oHud)
	local bValid = self.m_Huds[sType].valid and self.m_Huds[sType].obj == nil
	if bValid then
		local trans = self.m_Huds[sType].trans
		if trans and C_api.Utils.IsObjectExist(trans.gameObject) then
			oHud:SetTarget(trans)
		else
			-- print(string.format("%s, %s 挂载的节点已被释放", self:GetName(), sType))
			bValid = false
		end
	end
	self.m_Huds[sType].loading = false
	if bValid then
		local oCam = self:GetHudCamera()
		if self.m_HudLoadCb then
			self.m_HudLoadCb(oHud)
		end
		oHud:SetGameCamera(oCam.m_Camera)
		oHud:SetOwner(self)
		if self.m_Huds[sType].init_func then
			self.m_Huds[sType].init_func(oHud)
		end
		for i, func in ipairs(self.m_Huds[sType].done_cb_list) do
			if func and func(oHud) == false then
				bValid = false
			end
		end
		self.m_Huds[sType].done_cb_list = {}
		self.m_Huds[sType].obj = oHud
		if self.m_Huds[sType].ishide then
			oHud:SetAutoUpdate(false)
			oHud:SetActive(false)
		end
		if self:IsNeedRefreshPos(sType) then
			self:DelayCall(0, "RefreshHudPos")
		end
	else
		g_HudCtrl:SetUnused(oHud)
	end
end

function CBindObjBase.ClearEffect(self)
	for sType, oEff in pairs(self.m_Effects) do
		oEff:Destroy()
	end
	self.m_Effects = {}
end

function CBindObjBase.AddEffect(self, path, bCached, trans, offset)
	if self.m_Effects[path] then
		return
	end
	local oEffect = CEffect.New(path, self:GetLayer(), bCached)
	oEffect:SetParent(trans)
	if offset then
		oEffect:SetLocalPos(offset)
	end
	self.m_Effects[path] = oEffect
end

function CBindObjBase.DelEffect(self, path, bCached)
	local oEffect = self.m_Effects[path]
	if oEffect then
		oEffect:Destroy()
	end
	self.m_Effects[path] = nil
end

function CBindObjBase.IsNeedRefreshPos(self, sType)
	--override
	return false
end

function CBindObjBase.RefreshHudPos()
	--override
end


return CBindObjBase