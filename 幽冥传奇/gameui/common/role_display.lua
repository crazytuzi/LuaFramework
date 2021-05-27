RoleDisplay = RoleDisplay or BaseClass()

function RoleDisplay:__init(parent, zorder, has_nameboard, has_mount, has_wuqi, has_chibang, has_hand, is_flip_x, offestx, offesty)
	self:InitParam()

	self.root_node = cc.Node:create()
	if parent ~= nil then
		zorder = zorder or 0
		parent:addChild(self.root_node, zorder, zorder)
	end

	if nil ~= has_mount then self.has_mount = has_mount end
	if nil ~= has_wuqi then self.has_wuqi = has_wuqi end
	if nil ~= has_chibang then self.has_chibang = has_chibang end
	if nil ~= has_hand then self.has_hand = has_hand end
	if nil ~= has_nameboard then self.has_nameboard = has_nameboard end

	self.has_zhenqi = true
	self.is_flip_x = is_flip_x or false
	self.offestx = offestx or 0 --翻转后调整位置细调
	self.offesty = offesty or 0 --翻转后调整位置细调
end

function RoleDisplay:InitParam()
	self.dir_number = GameMath.DirDown
	self.action_name = SceneObjState.Stand
	self.delay_per_unit = FrameTime.RoleStand

	self.has_mount = false
	self.has_wuqi = true
	self.has_chibang = true
	self.has_hand = true
	self.has_nameboard = false
	self.has_zhenqi = true

	self.role_vo = nil
	self.role_res_id = 0
	self.mount_res_id = 0
	self.wuqi_res_id = 0
	self.chibang_res_id = 0
	self.douli_res_id = 0
	self.sex = 0
	self.is_flip_x = false
	self.offestx = 0
	self.offesty = 0

	self.sprite_list = {}
end

function RoleDisplay:__delete()
	self:InitParam()
	self.root_node = nil

end

function RoleDisplay:GetRootNode()
	return self.root_node
end

function RoleDisplay:Reset(role)
	if role == nil or 0 == role:GetRoleResId() then
		return
	end
	self.role_vo = role:GetVo()
	self.role_res_id = role:GetRoleResId()
	self.wuqi_res_id = role:GetWuQiResId()
	self.chibang_res_id = role:GetChiBangResId()
	self.hand_res_id = role:GetHandResId()
	self.douli_res_id = role:GetDouliResId()
	self.mount_res_id = role:GetMountResId()
	self.sex = self.role_vo[OBJ_ATTR.ACTOR_SEX]
	self.sex = self.role_vo[OBJ_ATTR.ACTOR_SEX]
  	self:Show()
end

function RoleDisplay:PrivewReset(role, cfg)
	if role == nil or 0 == role:GetRoleResId() then
		return
	end
	self.role_vo = role:GetVo()
	self.role_res_id = cfg.cloth_shape or 0
	self.wuqi_res_id = cfg.wq_shape or 0
	self.chibang_res_id = cfg.cb_shape or 0
	self.hand_res_id = cfg.hand_shape or 0
	self.douli_res_id = cfg.dl_shape or 0
	self.mount_res_id = cfg.m_shape or 0
	self.sex = self.role_vo[OBJ_ATTR.ACTOR_SEX]
  	self:Show()
end

function RoleDisplay:SetRoleVo(role_vo)
	if role_vo == nil then
		return
	end

	self.role_vo = role_vo

	self.role_res_id = self.role_vo[OBJ_ATTR.ENTITY_MODEL_ID]
	self.wuqi_res_id = self.role_vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE]
	self.chibang_res_id = self.role_vo[OBJ_ATTR.ACTOR_WING_APPEARANCE]
	self.hand_res_id = self.role_vo[OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE]
	self.douli_res_id = bit:_rshift(self.role_vo[OBJ_ATTR.ACTOR_FOOT_APPEARANCE], 16)
	self.sex = self.role_vo[OBJ_ATTR.ACTOR_SEX]
	self.zhenqi_res_id = self.role_vo[OBJ_ATTR.ACTOR_GENUINEQI_APPEARANCE]

	self:Show()
end

function RoleDisplay:SetPosition(x, y)
	self.root_node:setPosition(x, y)
end

function RoleDisplay:SetScale(scale)
	self.root_node:setScale(scale)
end

function RoleDisplay:SetZOrder(zorder)
	self.root_node:setLocalZOrder(zorder)
end

function RoleDisplay:SetDelayPerUnit(delay_per_unit)
	self.delay_per_unit = delay_per_unit
	if self.role_res_id ~= 0 then
		self:Show()
	end
end

function RoleDisplay:GetDirection()
	return self.dir_number
end

function RoleDisplay:SetDirectionAction(dir_number, action_name)
	self.dir_number = dir_number or GameMath.DirDown
	self.action_name = action_name or SceneObjState.Stand
	if self.action_name == SceneObjState.Stand then
		self.delay_per_unit = FrameTime.RoleStand
	elseif self.action_name == SceneObjState.Move then
		self.delay_per_unit = FrameTime.Move
	elseif self.action_name == SceneObjState.Dead then
		self.delay_per_unit = FrameTime.Dead
	elseif self.action_name == SceneObjState.Atk
	or self.action_name == SceneObjState.Atk .. 1
	or self.action_name == SceneObjState.Atk .. 2 then
		self.delay_per_unit = FrameTime.Atk
	end
	self:Show()
end

function RoleDisplay:TurnLeft()
	self.dir_number = self.dir_number - 1
	if self.dir_number < GameMath.DirUp then
		self.dir_number = GameMath.DirLeft
	end

	self:Show()
end

function RoleDisplay:TurnRight()
	self.dir_number = self.dir_number + 1
	if self.dir_number > GameMath.DirLeft then
		self.dir_number = GameMath.DirUp
	end
	self:Show()
end

function RoleDisplay:SetRoleResId(role_res_id)
	if role_res_id and self.role_res_id ~= role_res_id then
		self.role_res_id = role_res_id
		self:Show()
	end
end

function RoleDisplay:SetMountResId(mount_res_id)
	if mount_res_id and self.mount_res_id ~= mount_res_id then
		self.mount_res_id = mount_res_id
		self:Show()
	end
end

function RoleDisplay:SetWuQiResId(wuqi_res_id)
	if wuqi_res_id and self.wuqi_res_id ~= wuqi_res_id then
		self.wuqi_res_id = wuqi_res_id
		self:Show()
	end
end

function RoleDisplay:SetChiBangResId(chibang_res_id)
	if chibang_res_id and self.chibang_res_id ~= chibang_res_id then
		self.chibang_res_id = chibang_res_id
		self:Show()
	end
end

function RoleDisplay:SetHandResId(res_id)
	if res_id and self.hand_res_id ~= res_id then
		self.hand_res_id = res_id
		self:Show()
	end
end

function RoleDisplay:SetDouliResId(douli_res_id)
	if douli_res_id and self.douli_res_id ~= douli_res_id then
		self.douli_res_id = douli_res_id
		self:Show()
	end
end

function RoleDisplay:SetTitleList(title_list)
	if nil ==title_list then return end
	if nil == self.title_list_layout then
		self.title_list_layout = cc.Sprite:create()
		local offy = 213
		if nil ~= self.role_vo and self.role_vo.guild_id > 0 then
			offy = offy + 25
		end
		self.title_list_layout:setPosition(cc.p(0, offy))
		self.root_node:addChild(self.title_list_layout)
	end
	self.title_list_layout:removeAllChildren()
	for k,v in pairs(title_list) do
		local title = Title.New()
		title:SetTitleId(v)
		title:GetView():setPosition(cc.p(0, (k-1)*50))
		self.title_list_layout:addChild(title:GetView())
	end
end

function RoleDisplay:UpdateTitle()
	-- body
end

function RoleDisplay:SetZhenqiResIdAndVis(zhenqi_res_id, vis)
	local old_vis = self.has_zhenqi
	self.has_zhenqi = vis

	if zhenqi_res_id then
		self.zhenqi_res_id = zhenqi_res_id
	end

	if old_vis ~= self.has_zhenqi or self.zhenqi_res_id ~= zhenqi_res_id then
		self:Show()
	end
end

function RoleDisplay:Show()
	local dir_num, is_flip_x = GameMath.GetResDirNumAndFlipFlag(self.dir_number)

	local bool_f = self.is_flip_x or is_flip_x
	local rel_action_name = self.action_name
	local is_shield = false
	-- 主体
	local anim_path, anim_name = "", ""

	if self.role_res_id ~= 0 and self.role_res_id then
		anim_path, anim_name = ResPath.GetRoleBigAnimPath(self.role_res_id, self.action_name, dir_num)
	end

	if self.has_nameboard and nil ~= self.role_vo then
		if nil == self.name_board then
			self.name_board = RoleNameBoard.New()
			self.name_board:GetRootNode():setPosition(cc.p(0, 178))
			self.root_node:addChild(self.name_board:GetRootNode())
		end
		self.name_board:SetRole(self.role_vo)
	end

	if "" ~= anim_path or self:CheckRes(anim_path) then
		self:ChangeLayerResFrameAnim(InnerLayerType.Main, anim_path, anim_name, bool_f, nil, 10, -20,1)
	end

	-- 武器
	anim_path, anim_name = "", ""
	if 0 ~= self.wuqi_res_id and self.wuqi_res_id and self.has_wuqi then
		anim_path, anim_name = ResPath.GetWuqiBigAnimPath(self.wuqi_res_id, self.action_name, dir_num, self.sex)
	end
	
	if "" == anim_path or self:CheckRes(anim_path) then
		self:ChangeLayerResFrameAnim(InnerLayerType.WuqiUp, anim_path, anim_name, bool_f, nil, 30 + self.offestx, -10 + self.offesty , 1)
	end

	-- 翅膀
	anim_path, anim_name = "", ""
	if 0 ~= self.chibang_res_id and self.chibang_res_id and self.has_chibang then
		anim_path, anim_name = ResPath.GetChibangBigAnimPath(self.chibang_res_id, self.action_name, dir_num)
	end
	
	if "" == anim_path or self:CheckRes(anim_path) then
		local chibang_layer = InnerLayerType.ChibangUp
		if dir_num ~= GameMath.DirUp then
			chibang_layer = InnerLayerType.ChibangDown
		end
		self:ChangeLayerResFrameAnim(chibang_layer, anim_path, anim_name, bool_f, nil, 15, 3, 1)
	end

	-- 手套
	anim_path, anim_name = "", ""
	is_shield = SettingData.Instance:GetOneSysSetting(SETTING_TYPE.SHIELD_HANDS)
	if 0 ~= self.hand_res_id and self.hand_res_id and self.has_hand and not is_shield then
		anim_path, anim_name = ResPath.GetHandBigAnimPath(self.hand_res_id, self.action_name, dir_num)
	end

	if "" == anim_path or self:CheckRes(anim_path) then
		local hand_layer = InnerLayerType.HandUp
		-- if dir_num ~= GameMath.DirUp then
		-- 	hand_layer = InnerLayerType.HandDown
		-- end
		self:ChangeLayerResFrameAnim(hand_layer, anim_path, anim_name, bool_f, nil, 0, -5, 1)
	end


	-- 真气
	anim_path, anim_name = "", ""
	is_shield = SettingData.Instance:GetOneSysSetting(SETTING_TYPE.SHIELD_ZHENQI)
	if 0 ~= self.zhenqi_res_id and self.zhenqi_res_id and self.has_zhenqi and not is_shield then
		anim_path, anim_name = ResPath.GetEffectUiAnimPath(self.zhenqi_res_id)
	end

	if "" == anim_path or self:CheckRes(anim_path) then
		local zhenqi_layer = InnerLayerType.ZhenQi
		self:ChangeLayerResFrameAnim(zhenqi_layer, anim_path, anim_name, bool_f, FrameTime.Effect, 0, -200, 1.5)
	end

	-- 斗笠
	-- anim_path, anim_name = "", ""
	-- is_shield = SettingData.Instance:GetOneSysSetting(SETTING_TYPE.SHIELD_HATS)
	-- if 0 ~= self.douli_res_id and self.douli_res_id and not is_shield then
	-- 	anim_path, anim_name = ResPath.GetDouLiBigAnimPath(self.douli_res_id + self.sex, self.action_name, dir_num)
	-- end
	-- if "" == anim_path or self:CheckRes(anim_path) then
	-- 	self:ChangeLayerResFrameAnim(InnerLayerType.DouLi, anim_path, anim_name, bool_f)
	-- end

end

function RoleDisplay:ChangeLayerResFrameAnim(layer_id, res_path, anim_name, is_flip_x, delay_per_unit, x, y, scale)
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

function RoleDisplay:MakeGray(is_gray)
	for k,v in pairs(self.sprite_list) do
		AdapterToLua:makeGray(v, is_gray)
	end
end

function RoleDisplay:RunAction(action)
	self.root_node:runAction(action)
end

function RoleDisplay:ShowAnim(is_visible)
	self.root_node:setVisible(is_visible)
end

function RoleDisplay:StopAllActions()
	self.root_node:stopAllActions()
end

function RoleDisplay:SetVisible(boo)
	self.root_node:setVisible(boo)
end

function RoleDisplay:CheckRes(path)
	return true
end

function RoleDisplay:SetRoleDisplayFlipX(is_flip_x)
	for k,v in pairs(self.sprite_list) do
		v:setFlippedX(is_flip_x)
	end
end