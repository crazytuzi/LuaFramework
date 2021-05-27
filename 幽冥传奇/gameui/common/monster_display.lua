MonsterDisplay = MonsterDisplay or BaseClass()

function MonsterDisplay:__init(parent, zorder)
	self:InitParam()

	self.root_node = cc.Node:create()
	if parent ~= nil then
		zorder = zorder or 0
		parent:addChild(self.root_node, zorder, zorder)
	end
end

function MonsterDisplay:InitParam()
	self.dir_number = GameMath.DirDown
	self.action_name = SceneObjState.Stand
	self.delay_per_unit = FrameTime.Stand
	self.entity_type = EntityType.Monster

	self.monster_vo = nil
	self.monster_res_id = 0
	self.wuqi_res_id = 0
	self.chibang_res_id = 0

	self.sprite_list = {}
end

function MonsterDisplay:__delete()
	self:InitParam()
	self.root_node = nil

end

function MonsterDisplay:GetRootNode()
	return self.root_node
end

function MonsterDisplay:Reset(monster)
	if monster == nil or 0 == monster:GetVo()[OBJ_ATTR.ENTITY_MODEL_ID] then
		return
	end
	self.monster_vo = monster:GetVo()
	self.monster_res_id = self.monster_vo[OBJ_ATTR.ENTITY_MODEL_ID]
	self.wuqi_res_id = self.monster_vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE]
	self.chibang_res_id = self.monster_vo[OBJ_ATTR.ACTOR_WING_APPEARANCE]
  	self:Show()
end

function MonsterDisplay:SetMonsterVo(monster_vo)
	if monster_vo == nil then
		return
	end

	self.monster_vo = monster_vo

	self.monster_res_id = self.monster_vo[OBJ_ATTR.ENTITY_MODEL_ID] or 0
	self.wuqi_res_id = self.monster_vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] or 0
	self.chibang_res_id = self.monster_vo[OBJ_ATTR.ACTOR_WING_APPEARANCE] or 0
	self.entity_type = self.monster_vo.entity_type or EntityType.Monster
	self:Show()
end

function MonsterDisplay:SetPosition(x, y)
	self.root_node:setPosition(x, y)
end

function MonsterDisplay:SetScale(scale)
	self.root_node:setScale(scale)
end

function MonsterDisplay:SetZOrder(zorder)
	self.root_node:setLocalZOrder(zorder)
end

function MonsterDisplay:SetDelayPerUnit(delay_per_unit)
	self.delay_per_unit = delay_per_unit
	if self.monster_res_id ~= 0 then
		self:Show()
	end
end

function MonsterDisplay:GetDirection()
	return self.dir_number
end

function MonsterDisplay:SetDirDown()
	self.dir_number = GameMath.DirDown
	self:Show()
end

function MonsterDisplay:SetDirRight()
	self.dir_number = GameMath.DirRight
	self:Show()
end

function MonsterDisplay:SetDirLeft()
	self.dir_number = GameMath.DirLeft
	self:Show()
end

function MonsterDisplay:TurnLeft()
	self.dir_number = self.dir_number - 1
	if self.dir_number < GameMath.DirUp then
		self.dir_number = GameMath.DirLeft
	end

	self:Show()
end

function MonsterDisplay:TurnRight()
	self.dir_number = self.dir_number + 1
	if self.dir_number > GameMath.DirLeft then
		self.dir_number = GameMath.DirUp
	end
	self:Show()
end

function MonsterDisplay:SetMonsterResId(monster_res_id)
	self.monster_res_id = monster_res_id
	self:Show()
end

function MonsterDisplay:SetWuQiResId(wuqi_res_id)
	self.wuqi_res_id = wuqi_res_id
	self:Show()
end

function MonsterDisplay:SetChiBangResId(chibang_res_id)
	self.chibang_res_id = chibang_res_id
	self:Show()
end

function MonsterDisplay:SetEntityType(entity_type)
	self.entity_type = entity_type
	self:Show()
end

function MonsterDisplay:Show()
	local dir_num, is_flip_x = self:GetResDirNumAndFlipFlag()

	local rel_action_name = self.action_name

	-- 主体
	local anim_path, anim_name = "", ""
	if self.monster_res_id ~= 0 then
		if self.entity_type ~= EntityType.Humanoid then
			anim_path, anim_name = ResPath.GetMonsterAnimPath(self.monster_res_id, self.action_name, dir_num)
		else
			anim_path, anim_name = ResPath.GetRoleBigAnimPath(self.monster_res_id, self.action_name, dir_num)
		end
	end

	if "" ~= anim_path and self:CheckRes(anim_path) then
		self:ChangeLayerResFrameAnim(InnerLayerType.Main, anim_path, anim_name, is_flip_x)
	end

	-- 武器
	if 0 ~= self.wuqi_res_id then
		anim_path, anim_name = ResPath.GetWuqiBigAnimPath(self.wuqi_res_id, self.action_name, dir_num)
	end
	
	if "" ~= anim_path and self:CheckRes(anim_path) then
		self:ChangeLayerResFrameAnim(InnerLayerType.WuqiUp, anim_path, anim_name, is_flip_x)
	end

	-- 翅膀
	if 0 ~= self.chibang_res_id then
		anim_path, anim_name = ResPath.GetChibangBigAnimPath(self.chibang_res_id, self.action_name, dir_num)
	end
	
	if "" ~= anim_path and self:CheckRes(anim_path) then
		local chibang_layer = InnerLayerType.ChibangUp
		if dir_num ~= GameMath.DirUp then
			chibang_layer = InnerLayerType.ChibangDown
		end
		self:ChangeLayerResFrameAnim(chibang_layer, anim_path, anim_name, is_flip_x, nil, 0, 20, 0.6)
	end


end

function MonsterDisplay:GetResDirNumAndFlipFlag()
	local dir_num, is_flip_x = GameMath.GetResDirNumAndFlipFlag(self.dir_number)

	-- 非人形怪只有4方向
	if self.entity_type ~= EntityType.Humanoid then
		if dir_num == GameMath.DirUpRight then
			dir_num = GameMath.DirRight
		elseif dir_num == GameMath.DirDownRight then
			dir_num = GameMath.DirRight
		end
	end

	return dir_num, is_flip_x
end

function MonsterDisplay:ChangeLayerResFrameAnim(layer_id, res_path, anim_name, is_flip_x, delay_per_unit, x, y, scale)
	local sprite = self.sprite_list[layer_id]

	if "" == res_path or "" == anim_name then
		if sprite then
			sprite:removeFromParent()
			self.sprite_list[layer_id] = nil
		end
		return
	end

	if not sprite then
		sprite = AnimateSprite:create()
		self.root_node:addChild(sprite, layer_id, layer_id)
		self.sprite_list[layer_id] = sprite
	end

	if nil ~= x and nil ~= y then
		sprite:setPosition(x, y)
	end

	if nil ~= scale then
		sprite:setScale(scale)
	end

	sprite:setAnimate(res_path, anim_name, COMMON_CONSTS.MAX_LOOPS, delay_per_unit or self.delay_per_unit, is_flip_x)
end

function MonsterDisplay:MakeGray(is_gray)
	for k,v in pairs(self.sprite_list) do
		AdapterToLua:makeGray(v, is_gray)
	end
end

function MonsterDisplay:RunAction(action)
	self.root_node:runAction(action)
end

function MonsterDisplay:ShowAnim(is_visible)
	self.root_node:setVisible(is_visible)
end

function MonsterDisplay:StopAllActions()
	self.root_node:stopAllActions()
end

function MonsterDisplay:SetVisible(boo)
	self.root_node:setVisible(boo)
end

function MonsterDisplay:CheckRes(path)
	return true
end
