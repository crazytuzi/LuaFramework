-- 
-- @Author: LaoY
-- @Date:   2018-09-03 17:19:17
-- 

Door = Door or class("Door",SceneObject)

local Door = Door
function Door:ctor()
	self.object_type = enum.ACTOR_TYPE.ACTOR_TYPE_PROTAL
	self.body_size = {width = 90,height = 160}

	self.is_loaded = true
	self:SetPosition(self.position.x,self.position.y)
	self:SetTargetEffect("effect_chuansongmen",true)
end

function Door:dctor()

end

function Door:SetNameColor()
	self.name_container:SetColor(Color(205,101,253),Color(6,0,1))
	-- self.name_container:SetColor(Color.green,Color.black)
end

function Door:OnMainRoleStop()
	-- Notify.ShowText(string.format(self.object_info.target_scene))
	-- target_coord
	GlobalEvent:Brocast(SceneEvent.RequestChangeScene,self.object_info.target_scene,enum.SCENE_CHANGE.SCENE_CHANGE_PROTAL,self.object_info.target_coord,self.object_id)
end

-- 目前传送阵是放到障碍物，要修改
function Door:SetPosition(x,y)
	self.position.x = x
	self.position.y = y
	self.position.z = self:GetDepth(y)
	local world_pos = {x = self.position.x/SceneConstant.PixelsPerUnit,y = self.position.y/SceneConstant.PixelsPerUnit}
	SetGlobalPosition(self.parent_transform,world_pos.x,world_pos.y,self.position.z)
	if self.name_container then
		local body_height = self:GetBodyHeight()
		self.name_container:SetGlobalPosition(world_pos.x,world_pos.y + body_height/SceneConstant.PixelsPerUnit,self.position.z*1.1)
	end
end

function Door:GetDepth(y)
	y = MapManager:GetInstance().map_pixels_height
	return LayerManager:GetInstance():GetSceneObjectDepth(y)
end