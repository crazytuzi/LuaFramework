--
-- @Author: LaoY
-- @Date:   2018-09-28 12:02:48
--
JumpPoint = JumpPoint or class("JumpPoint",SceneObject)

function JumpPoint:ctor(uid)
	self.object_type = enum.ACTOR_TYPE.ACTOR_TYPE_PROTAL
	self.body_size = {width = 70,height = 70}
	self.load_level = Constant.LoadResLevel.Super
	
	self.is_loaded = true
	self:SetPosition(self.position.x,self.position.y)
	self:SetTargetEffect("effect_tiaoyuedian",true)
	
	if not AppConfig.Debug then
		self.name_container:destroy()
		self.name_container = nil
	end
end

function JumpPoint:dctor()

end

function JumpPoint:SetNameColor()
	-- self.name_container:SetColor(Color(234,234,50),Color(188,0,0))
	self.name_container:SetColor(Color.green,Color.black)
end

function JumpPoint:OnMainRoleStop()
	-- Notify.ShowText(string.format(self.object_info.target_scene))
	-- target_coord
	-- GlobalEvent:Brocast(SceneEvent.RequestChangeScene,self.object_info.target_scene,enum.SCENE_CHANGE.SCENE_CHANGE_PROTAL,self.object_info.target_coord,self.object_id)
end

-- 目前传送阵是放到障碍物，要修改
function JumpPoint:SetPosition(x,y)
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
function JumpPoint:GetDepth(y)
	y = MapManager:GetInstance().map_pixels_height
	return LayerManager:GetInstance():GetSceneObjectDepth(y)
end

function JumpPoint:OnClick()
	local main_role = SceneManager:GetInstance():GetMainRole()
	if main_role:IsJumping() then
		return
	end
	local main_pos = main_role:GetPosition()
	OperationManager:GetInstance():TryMoveToPosition(nil,main_pos,self.object_info.target_coord,nil,60,0)
	return true
end