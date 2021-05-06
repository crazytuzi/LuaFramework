local CLiveTexture = class("CLive2dTexture", CTexture)

function CLiveTexture.ctor(self, obj)
	CTexture.ctor(self, obj)

	self:SetPivot(enum.UIWidget.Pivot.Bottom) --下方对齐

	self.m_LiveModel = CLive2dModel.New()
	self.m_LiveModel:SetRelative(self)

	self.m_CallbackDic = {}

	self:AddUIEvent("click", callback(self, "OnClick"))
	self:AddUIEvent("drag", callback(self, "OnDrag"))
	self:AddUIEvent("dragend", callback(self, "OnDragEnd"))
	self:AddUIEvent("dragstart", callback(self, "OnDragStart"))
	-- self:AddUIEvent("repeatpress", callback(self, "OnRepeatPress"))
	
	self.m_BaseW, self.m_BaseH = self:GetSize()
	self.m_PressCount = 0
	self.m_CanTouch = true
end


function CLiveTexture.SetCamera(self, pos, graphicSize)
	self.m_LiveModel:SetCamera(pos, graphicSize)
end

function CLiveTexture.OnDrag(self, obj, moveDelta)
	-- printc("draging")
	self.m_LiveModel:EyesOn()
end

function CLiveTexture.OnDragEnd(self, obj, moveDelta)
	-- printc("OnDragEnd")
	-- self.m_Draging = false
	self.m_LiveModel:EndEyesOn()
	-- self.m_PressCount = 0
end

function CLiveTexture.OnRepeatPress(self, obj, pressing)
	-- if self.m_Draging then
	-- 	return
	-- end
	-- if not pressing then
	-- 	if self.m_PressCount <= 10 then
	-- 		self:OnClick()
	-- 	end
	-- 	self.m_PressCount = 0
	-- 	self.m_LiveModel:EndEyesOn()
	-- 	return
	-- end
	-- self.m_PressCount = self.m_PressCount + 1
	-- if self.m_PressCount == 10 then
	-- 	self.m_LiveModel:StartEyesOn()
	-- elseif self.m_PressCount > 10 then
	-- 	-- printc("OnRepeatPress")
	-- 	self.m_LiveModel:EyesOn()
	-- end
end

function CLiveTexture.OnDragStart(self, obj, ...)
	-- self.m_Draging = true
	self.m_LiveModel:StartEyesOn()
end

function CLiveTexture.OnClick(self)
	if not self.m_CanTouch and not g_HouseCtrl:IsHouseOnly() then
		-- g_NotifyCtrl:FloatMsg("操作频繁，请稍后再试")
		return
	end
	self.m_CanTouch = false
	Utils.AddTimer(function ()
		self.m_CanTouch = true
	end, 0, 0.8)
	local dData = self.m_LiveModel:CheckTouchPos()
	if dData ~= nil then
		for i,v in ipairs(self.m_CallbackDic) do
			v(dData)
		end
	end
end

function CLiveTexture.AddClickCallback(self, callbackFunc)
	table.insert(self.m_CallbackDic, callbackFunc)
end

function CLiveTexture.LoadModel(self, iShape)
	self.m_LiveModel:LoadModel(iShape)
	self:SetSize(self.m_BaseW, self.m_BaseH)
	
	local o = self:GetMainTexture(self.m_LiveModel.m_Camera.aspect)
	self.m_LiveModel:SetRenderTexture(o)
	local w, h = self:GetSize()
	self.m_LiveModel:SetSize(w, h)
	self:SetSize(0.8 * w, h)
end

function CLiveTexture.GetMainTexture(self, aspect)
	if not self.m_UIWidget.mainTexture then
		local w, h = self:GetSize()
		if aspect then
			local iTextureAspect = (w/h)
			if iTextureAspect ~= aspect then
				if iTextureAspect < aspect then
					w = h * aspect
				elseif iTextureAspect > aspect then
					h = w / aspect
				end
				self:SetSize(w, h)
			end
		end

		local o = UnityEngine.RenderTexture.GetTemporary(w, h, 16, 
				enum.RenderTextureFormat.Default, enum.RenderTextureReadWrite.Default, 1)
		self.m_UIWidget.mainTexture = o
	end
	return self.m_UIWidget.mainTexture
end

function CLiveTexture.SetDefaultMotion(self, motionName)
	self.m_LiveModel:SetDefaultMotion(motionName)
end

function CLiveTexture.PlayMotion(self, sMotion, bLoop)
	self.m_LiveModel:PlayMotion(sMotion, bLoop)
end

return CLiveTexture
