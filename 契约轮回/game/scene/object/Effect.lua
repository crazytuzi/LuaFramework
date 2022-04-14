--
-- @Author: LaoY
-- @Date:   2018-11-16 16:21:52
--

Effect = Effect or class("Effect",SceneObject)

function Effect:ctor()
	self.object_type = enum.ACTOR_TYPE.ACTOR_TYPE_EFFECT
	self.body_size = {width = 90,height = 160}
	self.load_level = Constant.LoadResLevel.Low
	
	self.is_loaded = true
	self:SetPosition(self.position.x,self.position.y)
	self:SetTargetEffect(self.object_info.name,true)

	if self.name_container then
		self.name_container:destroy()
		self.name_container = nil
	end
end

function Effect:InitData(object_id)
	local scene_obj_layer = LayerManager:GetInstance():GetLayerByName(LayerManager.LayerNameList.SceneEffect)
	self.parent_transform:SetParent(scene_obj_layer)
	Effect.super.InitData(self,object_id)
end

-- 目前传送阵是放到障碍物，要修改
function Effect:SetPosition(x,y)
	self.position.x = x
	self.position.y = y
	self.position.z = self:GetDepth(y)
	local world_pos = {x = self.position.x/SceneConstant.PixelsPerUnit,y = self.position.y/SceneConstant.PixelsPerUnit}
	SetGlobalPosition(self.parent_transform,world_pos.x,world_pos.y,self.position.z)
end

function Effect:GetDepth(y)
	if self.object_info and self.object_info.level == 1 then
		y = MapManager:GetInstance().map_pixels_height
	elseif self.object_info and self.object_info.level == 3 then
		y = 0
	end
	return LayerManager:GetInstance():GetSceneObjectDepth(y)
end