local CWorldMapEffect = class("CWorldMapEffect", CEffect)


function CWorldMapEffect.ctor(self)
	self.m_PathDict = {
		main = "Effect/UI/ui_eff_3002/Prefabs/ui_eff_3002_beijing.prefab",
		line = "Effect/UI/ui_eff_3002/Prefabs/ui_eff_3002_fly.prefab",
		ball = "Effect/UI/ui_eff_3002/Prefabs/ui_eff_3002_huoqiu.prefab",
		bg = "Effect/UI/ui_eff_3002/Prefabs/ui_eff_3002_tu_01.prefab",
		guang = "Effect/UI/ui_eff_3002/Prefabs/ui_eff_3002_guang.prefab",
		choose = "Effect/UI/ui_eff_3002/Prefabs/ui_eff_3002_dianji.prefab"
	}
	CEffect.ctor(self, self.m_PathDict["main"], define.Layer.Effect, false, nil)
	self:InitCamera()
	self.m_Layer = define.Layer.Effect
	self.m_EffectList = {}
	self:InitEffect()
end

function CWorldMapEffect.InitCamera(self)
	local effectCamera = g_CameraCtrl:GetEffectCamera()
	effectCamera:SetEnabled(true)
	effectCamera:SetLayer(self.m_Layer)
	effectCamera:SetDepth(self.m_Layer)
	effectCamera:OpenCullingMask(self.m_Layer)
	effectCamera:SetFieldOfView(43)
	effectCamera:SetLocalRotation(Quaternion.Euler(0, 0, 0))
	effectCamera:SetLocalPos(Vector3.New(0, 0, -2.5))
end

function CWorldMapEffect.InitEffect(self)
	local w, h = UITools.GetRootSize()
	local iw = w/1344
	local ih = h/750
	if iw < 1 then iw = 1 end
	if ih < 1 then ih = 1 end
	self:SetLocalScale(Vector3.New(iw, ih, 1))
	self.m_BGEffect = CEffect.New(self.m_PathDict["bg"], self.m_Layer, false, nil)
end

function CWorldMapEffect.CreateBall(self, vPos)
	local ballEffect = CEffect.New(self.m_PathDict["ball"], self.m_Layer, false, nil)
	ballEffect:SetLocalPos(vPos)
	table.insert(self.m_EffectList, ballEffect)
	return ballEffect
end

function CWorldMapEffect.CreateLine(self, vPos, iRotateX, iRotateY, iScale)
	local lineEffect = CEffect.New(self.m_PathDict["line"], self.m_Layer, false, nil)
	lineEffect:SetLocalPos(vPos)
	lineEffect:SetLocalRotation(Quaternion.Euler(iRotateX, iRotateY, 0))
	table.insert(self.m_EffectList, lineEffect)
	lineEffect.m_PointEffect = self:CreatePoint(vPos)
	lineEffect.m_Idx = 1
	local speedlist = {0.5, 1, 1.5, 2, 2.5, 3, 5, 6, 8, 10}
	local function update()
		if Utils.IsNil(lineEffect) then
			return
		end
		if lineEffect.m_Idx < 11 then
			lineEffect:SetLocalScale(Vector3.New(1, 1, iScale * speedlist[lineEffect.m_Idx] /10))
			lineEffect.m_PointEffect:SetLocalPos(self:GetPointPos(vPos, iRotateX, speedlist[lineEffect.m_Idx]))
			lineEffect.m_Idx = lineEffect.m_Idx + 1
			return true
		elseif lineEffect.m_Idx >= 11 then
			if lineEffect.m_Idx > 15 then
				lineEffect.m_PointEffect:Destroy()
			else
				lineEffect.m_Idx = lineEffect.m_Idx + 1
				return true
			end
		else
			return false
		end
	end
	Utils.AddTimer(update, 0.05, 0)
	return lineEffect
end

function CWorldMapEffect.CreatePoint(self, vPos)
	local pointEffect = CEffect.New(self.m_PathDict["guang"], self.m_Layer, false, nil)
	pointEffect:SetLocalPos(vPos)
	table.insert(self.m_EffectList, pointEffect)
	return pointEffect
end

function CWorldMapEffect.GetPointPos(self, vPos, iRotate, i)
	local iLength = 0.75
	local sita = iRotate*2*math.pi / 360
	local x = iLength * math.cos(sita) * i / 10
	local y = -iLength * math.sin(sita) * i / 10
	local vP = Vector3.New(vPos.x, vPos.y, vPos.z)
	vP.x = vPos.x + x
	vP.y = vPos.y + y
	return vP
end

function CWorldMapEffect.ShowSelectEffect(self, vPos)
	if not self.m_SelectEffect then
		self.m_SelectEffect = CEffect.New(self.m_PathDict["choose"], self.m_Layer, false, nil)
	end
	self.m_SelectEffect:SetLocalPos(vPos)
end

function CWorldMapEffect.DestroyList(self)
	for _, oEffect in ipairs(self.m_EffectList) do
		oEffect:Destroy()
	end
	if self.m_SelectEffect then
		self.m_SelectEffect:Destroy()
	end
	self.m_SelectEffect = nil
	self.m_EffectList = {}
end

function CWorldMapEffect.Destroy(self)
	if self.m_BGEffect then
		self.m_BGEffect:Destroy()
	end
	if self.m_SelectEffect then
		self.m_SelectEffect:Destroy()
	end
	self.m_BGEffect = nil
	self.m_SelectEffect = nil
	g_CameraCtrl:GetEffectCamera():SetEnabled(false)
	CEffect.Destroy(self)
end

return CWorldMapEffect