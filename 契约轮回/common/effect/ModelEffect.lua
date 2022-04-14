--
-- @Author: LaoY
-- @Date:   2019-12-11 17:57:49
--


ModelEffect = ModelEffect or class("ModelEffect",BaseEffect)

local Index = 0
function ModelEffect:ctor(parent,abName,config,ower_object,is_ui)
	self.model_effect_config = config
	self.ower_object = ower_object
	self.is_ui = is_ui

	Index = Index + 1
	self.create_index = Index

	self.is_loading = false
	self.is_loaded 	= false
	self.is_show 	= false


	poolMgr:AddConfig(self.abName,self.assetName,1,15,false)

	if not self.is_ui then
		EffectManager:GetInstance():AddModelEffect(self)
	end
	if EffectManager:GetInstance():IsCanShow(self) then
		self.is_show = true
		-- ModelEffect.super.Load(self)
		self:Load()
	end
end

function ModelEffect:dctor()
	EffectManager:GetInstance():RemoveModelEffect(self)
end

function ModelEffect:Load()
	ModelEffect.super.Load(self)
	self.is_loading = true
end

function ModelEffect:CreateObject(objs, is_cache)
	self.is_loading = false
	if not self.is_show then
		return
	end
	ModelEffect.super.CreateObject(self,objs, is_cache)
end

function ModelEffect:LoadCallBack()
	if self.is_ui then
		SetChildLayer(self.transform,LayerManager.BuiltinLayer.UI)
	else
		SetChildLayer(self.transform,LayerManager.BuiltinLayer.Default)
	end
	if self.model_effect_config.scale and self.model_effect_config.scale ~= 1 then
		SetLocalScale(self.transform,self.model_effect_config.scale)
	end
end

function ModelEffect:ClearEffect()
	self.is_show = false
	self.is_loaded = false
	self:DestyoyGameObject()
end