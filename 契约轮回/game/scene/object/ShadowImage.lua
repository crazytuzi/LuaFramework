--
-- @Author: LaoY
-- @Date:   2019-01-29 19:37:25
--

ShadowImage = ShadowImage or class("ShadowImage",BaseWidget)
ShadowImage.__cache_count = 30

function ShadowImage:ctor(parent_node,builtin_layer)
	self.abName = "mapasset/mapres_shadowsprite"
    self.assetName = "shadowsprite"
    self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneImage)

	self.builtin_layer = LayerManager.BuiltinLayer.Default
    self.position = { x = 0, y = 0, z = 0 }

	ShadowImage.super.Load(self)
end

function ShadowImage:dctor()
end

function ShadowImage:__reset(...)
	self.parent_node = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneImage)
	ShadowImage.super.__reset(self,...)
	self:SetScale(100)
	self:SetAlpha(1.0)
end

function ShadowImage:LoadCallBack()
	self.nodes = {
		"",
	}
	self:GetChildren(self.nodes)

	-- self.image = self.gameObject:GetComponent('Image')
	
	self:SetScale(100)

	self:AddEvent()
end

function ShadowImage:AddEvent()
end

function ShadowImage:SetData(data)

end

function ShadowImage:SetGlobalPosition(x, y, z)
    self.position = { x = x, y = y, z = z }
    SetGlobalPosition(self.transform, x, y, z)
end

function ShadowImage:SetAlpha(alpha)
	SetAlpha(self.image,alpha)
end