--残影类
RoleGhost = RoleGhost or BaseClass(SceneObj)
function RoleGhost:__init()
	self.obj_type = SceneObjType.Ghost
end	

function RoleGhost:__delete()
end	

function RoleGhost:CanClick()
	return false
end

function RoleGhost:CreateTitle()
end	

function RoleGhost:SetCurrentInfo(role)
	self.end_time = Status.NowTime + 0.8
	self.ghost_alpha = 200
	self.vo.dir = role.vo.dir
	self.role_res_id = role.role_res_id
	self.wuqi_res_id = role.wuqi_res_id
	self.chibang_res_id = role.chibang_res_id 
	self.action_type = role.action_type
	self.sync_start_time = role.sync_start_time
	self.delay_per_unit = 0.001
	self.loops = 1
	self.is_pause_last_frame = true
	self.model:SetOpacity(self.ghost_alpha)
	self:SetScale(role:GetModel():GetScale(),false)
	self:RefreshRoleAnimation()
	

	local color = FashionData.Instance:GetShadowColor(role.vo[OBJ_ATTR.ACTOR_SHADOW_VALUE])
	if color and color.showColor then		
		self:SetModelColor(color.showColor)
	end
end	

function RoleGhost:Update(now_time, elapse_time)
	local alpha = self.ghost_alpha * (self.end_time - now_time)
	alpha = math.max(alpha,0)
	self.model:SetOpacity(alpha)
end	

function RoleGhost:IsTimeout()
	return Status.NowTime >= self.end_time
end	

function RoleGhost:Init(parent_scene)
	self.parent_scene = parent_scene
end	

function RoleGhost:RefreshRoleAnimation()
	local ani_name_prefix = self:GetAniPrefixByActionType(self.action_type)
	local dir_num, is_flip_x = GameMath.GetResDirNumAndFlipFlag(self.vo.dir)
	if self.action_type == ActionType.ReadyDead then
		dir_num = GameMath.DirUp
	end
	local anim_path, anim_name = nil, nil
	-- if self.role_res_id > 0 then
	-- 	anim_path, anim_name = self:GetBodyModelPath(self.role_res_id,ani_name_prefix,dir_num)
	-- 	self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, 
	-- 									   InnerLayerType.Main,
	-- 									   anim_path,
	-- 									   anim_name, 
	-- 		                               is_flip_x, 
	-- 		                               self.delay_per_unit, 
	-- 		                               nil, 
	-- 		                               self.loops, 
	-- 		                               self.is_pause_last_frame, 
	-- 		                               nil, nil, nil, nil, 
	-- 		                               self.sync_start_time)	
		
	-- end

	-- -- 武器
	-- local layer = InnerLayerType.WuqiUp
	-- if 0 ~= self.wuqi_res_id then
	-- 	local wuqi_id = self.wuqi_res_id
	-- 	if wuqi_id < 10 then
	-- 		wuqi_id = 10
	-- 	end	
	-- 	anim_path, anim_name = ResPath.GetWuqiAnimPath(wuqi_id, ani_name_prefix, dir_num)
	-- 	self.last_wuqi_layer = layer
	-- 	self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, layer, anim_path, anim_name, 
	-- 		is_flip_x, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, nil, nil, nil, nil, self.sync_start_time)
	-- else
	-- 	if nil ~= self.last_wuqi_layer then
	-- 		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_wuqi_layer, "", "")
	-- 		self.last_wuqi_layer = nil
	-- 	end
	-- end

	-- -- 翅膀

	-- layer = InnerLayerType.ChibangUp
	-- if dir_num == GameMath.DirDown 
	-- 	or dir_num == GameMath.DirDownRight 
	-- 	or dir_num == GameMath.DirDownLeft 
	--     then
	-- 	layer = InnerLayerType.ChibangDown
	-- elseif dir_num == GameMath.DirLeft
	-- 	   or dir_num == GameMath.DirRight then	
	-- 	layer = InnerLayerType.ChibangMid
	-- end

	-- if self.action_type == ActionType.AtkWait then
	-- 	if dir_num == GameMath.DirLeft 
	-- 		or dir_num == GameMath.DirRight
	-- 		or dir_num == GameMath.DirUpLeft 
	-- 		or dir_num == GameMath.DirUpRight then
	-- 		layer = InnerLayerType.ChibangDown
	-- 	end	
	-- end	
	

	if 0 ~= self.chibang_res_id then
		anim_path, anim_name = ResPath.GetChibangAnimPath(self.chibang_res_id, ani_name_prefix, dir_num)
		self.last_chibang_layer = InnerLayerType.ChibangUp
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_chibang_layer, anim_path, anim_name, 
			is_flip_x, self.delay_per_unit, nil, self.loops, self.is_pause_last_frame, nil, nil, nil, nil, self.sync_start_time)
	else
		if nil ~= self.last_chibang_layer then
			self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_chibang_layer, "", "")
			self.last_chibang_layer = nil
		end
	end
end	

--清理引用动画资源
function RoleGhost:ClearAnimate()
	if nil ~= self.last_chibang_layer then
		self.model:ChangeLayerResFrameAnim(GRQ_SCENE_OBJ, self.last_chibang_layer, "", "")
		self.last_chibang_layer = nil
	end
end	

--动作转化接口
function RoleGhost:GetAniPrefixByActionType(actionType)
	if actionType == ActionType.Move then
		return "run"
	elseif actionType == ActionType.Run then
		return "run"
	elseif actionType == ActionType.Sprint	then	
		return "atk1"	
	else
		return "stand"	
	end	
end	