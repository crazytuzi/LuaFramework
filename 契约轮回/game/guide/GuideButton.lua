GuideButton = GuideButton or class("GuideButton",BaseItem)
local GuideButton = GuideButton

function GuideButton:ctor(parent_node,layer)
	self.abName = "guide"
	self.assetName = "GuideButton"
	self.layer = layer

	--self.model = 2222222222222end:GetInstance()
	GuideButton.super.Load(self)
end

function GuideButton:dctor()
end

function GuideButton:LoadCallBack()
	self.nodes = {
		"effect/effect_ui_xinshouyindao",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	local _, order = GetParentOrderIndex(self.transform)
	UIDepth.SetOrderIndex(self.effect_ui_xinshouyindao.gameObject, false, order+1)
end

function GuideButton:AddEvent()
end

function GuideButton:SetData(data)

end