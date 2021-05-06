local CSlider = class("CSlider", CWidget)

function CSlider.ctor(self, obj)
	CWidget.ctor(self, obj)
	self.m_UISlider = self:GetComponent(classtype.UISlider)
	self.m_UILabel = false
	self.m_ClipPanel = nil

	self.m_Direction = nil
end

function CSlider.SetRightToLeft(self)
	self.m_Direction = "RTL"
end

function CSlider.FindLabel(self)
	if self.m_UILabel == false then
		self.m_UILabel= self:GetComponentInChildren(classtype.UILabel)
	end
end

function CSlider.UseClipPanel(self)
	local foreBg = self:GetForeBg()
	if not foreBg then
		return
	end
	foreBg.drawRegion = Vector4.New(0,0, 1, 1)
	local oWidget = CWidget.New(foreBg.gameObject)
	local parent = oWidget:GetParent()
	local w, h = oWidget:GetSize()
	local parentPanel = oWidget:GetComponentInParent(classtype.UIPanel)
	local iNextDepth = parentPanel.depth + 1
	local gameObject = UnityEngine.GameObject.New()
	gameObject:AddComponent(classtype.UIPanel)
	local oPanel = CPanel.New(gameObject)
	oPanel:SetClipping(enum.UIDrawCall.Clipping.SoftClip)
	oPanel:SetParent(parent)
	oPanel:SetLocalPos(oWidget:GetLocalPos())
	oPanel:SetBaseClipRegion(Vector4.New(0, 0, w, h))
	oPanel:SetLayer(oWidget:GetLayer())
	oPanel:SetDepth(iNextDepth)
	oPanel:SetName("ForeClip")
	oWidget:SetParent(oPanel.m_Transform, true)
	self.m_ClipPanel = oPanel
	self.m_OriForeBg = oWidget
	self:SetForeBg(nil)

	self:FindLabel()
	if self.m_UILabel then
		local gameObject = UnityEngine.GameObject.New()
		gameObject:AddComponent(classtype.UIPanel)
		local oPanel = CPanel.New(gameObject)
		oPanel:SetDepth(iNextDepth+1)
		oPanel:SetLayer(oWidget:GetLayer())
		oPanel:SetParent(parent)
		oPanel:SetName("LabelClip")
		self.m_UILabel.transform.parent = oPanel.m_Transform
		
	end
	self:AddUIEvent("change", callback(self, "ResizeClipPanel"))
	self:ResizeClipPanel()
end

function CSlider.ResizeClipPanel(self)
	if not self.m_ClipPanel then
		return
	end
	local v = self:GetValue()
	local width, height = self.m_OriForeBg:GetSize()

	local iClipWidth = math.lerp(0.01, width, v)
	local iOffsetX = math.min(0, -(width-iClipWidth)/2)
	if self.m_Direction == "RTL" then
		self.m_ClipPanel:SetBaseClipRegion(Vector4.New(-iOffsetX, 0, iClipWidth, height))
	else
		self.m_ClipPanel:SetBaseClipRegion(Vector4.New(iOffsetX, 0, iClipWidth, height))
	end
	self.m_ClipPanel:SimulateOnEnable()
end

function CSlider.GetForeBg(self)
	return self.m_UISlider.foregroundWidget
end

function CSlider.SetForeBg(self, widget)
	self.m_UISlider.foregroundWidget = widget
end

function CSlider.SetValue(self, v)
	self.m_UISlider.value = v
end

function CSlider.GetValue(self)
	return self.m_UISlider.value
end

function CSlider.SetMinValue(self, v)
	self.m_UISlider.minValue = v
end

function CSlider.SetMaxValue(self, v)
	self.m_UISlider.maxValue = v
end

function CSlider.SetSliderText(self, s)
	self:FindLabel()
	if self.m_UILabel then
		self.m_UILabel.text = s
	end
end

function CSlider.GetThumb(self)
	return self.m_UISlider.thumb
end

return CSlider
