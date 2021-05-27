
GRQ_SCENE_OBJ_AUTO_XUNLU = GRQ_SCENE_OBJ + 1
GRQ_SCENE_OBJ_HP = GRQ_SCENE_OBJ + 2
GRQ_SCENE_OBJ_NAME = GRQ_SCENE_OBJ + 3
GRQ_SCENE_OBJ_FIGHT_TEXT = GRQ_SCENE_OBJ + 4
GRQ_SCENE_OBJ_FIGHT_TEXT2 = GRQ_SCENE_OBJ + 5

DrawObj = DrawObj or BaseClass()

DrawObj.DEF_SCALE = 1.0
DrawObj.DEF_ROTATION = 0
DrawObj.DEF_OPACITY = 255
DrawObj.DEF_VISIBLE = true

function DrawObj:__init(scene_obj)
	self.scene_obj = scene_obj

	self.core_game_scene = HandleRenderUnit:GetCoreScene()

	self.core_pos = cc.p(0, 0)

	self.core_nodes = {}							-- 渲染组下的核心节点
	self.render_group_child = {}					-- 核心节点下挂接的Node

	self.main_animate = nil							-- 主体动画

	self.shadow_sprite = nil						-- 影子

	self.scale = DrawObj.DEF_SCALE					-- 缩放比例
	self.rotation = DrawObj.DEF_ROTATION			-- 旋转角度
	self.opacity = DrawObj.DEF_OPACITY				-- 透明度(0~255, 透明~不透明)
	self.visible = DrawObj.DEF_VISIBLE				-- 是否可见
	self.color = COLOR3B.WHITE						-- 颜色
	self.height_offset = 0							-- 高度偏移值
	self.zorder_offest = 0							-- 深度偏移值
	self.zorder = 0

	self.anim_cache = {}							-- 动画缓存
end

function DrawObj:__delete()
	self.scene_obj = nil
	self.core_game_scene = nil

	for _, node in pairs(self.core_nodes) do
		node:removeFromParent()
	end
	self.core_nodes = {}

	self.render_group_child = {}

	self.main_animate = nil
	self.shadow_sprite = nil

	if nil ~= self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
end

function DrawObj:GetLayerNode(render_group, layer_id)
	self:_EnsureCoreNode(render_group)
	return self.render_group_child[render_group][layer_id]
end

function DrawObj:SetZorderOffest(zorder_offest)
	self.zorder_offest = zorder_offest
end

function DrawObj:SetLocalZOrder(zorder)
	self.zorder = zorder + self.zorder_offest
	self:_EnsureCoreNode(GRQ_SCENE_OBJ):setLocalZOrder(self.zorder)
end

function DrawObj:GetLocalZOrder()
	return self.zorder or 0
end

--[[
在DrawObj上挂接一个子结点，比如特效类的结点
@node:	要挂接的结点,Node类型
@pos:	挂接的偏移坐标，cc.p类型，可为nil
@render_group:	要挂接到的渲染组
@layer_id: 指定的层级
]]
function DrawObj:AttachNode(node, pos, render_group, layer_id, is_save)
	if node == nil then return end
	render_group = render_group or GRQ_SCENE_OBJ
	layer_id = layer_id or 0

	local corenode = self:_EnsureCoreNode(render_group)

	node:retain()
	node:removeFromParent(false)
	corenode:addChild(node, layer_id, layer_id)
	node:release()

	if not self.visible and self:CanVisible(render_group, layer_id) then
		node:setVisible(false)
	end

	if pos ~= nil then
		node:setPosition(pos.x, pos.y)
	end

	if render_group == GRQ_SHADOW and layer_id == InnerLayerType.Shadow then
		self.shadow_sprite = node
	end
	if is_save then
		self.render_group_child[render_group][layer_id] = node
	end
end

--[[
更换指定层级的资源，把anim_path设为""，即可清除该层
@render_group: 层级所在的渲染组
@layer_id:指定的层级，通常是InnerLayerType中定义的枚举(scene_config.lua)
@anim_path:资源文件
@anim_name:动作名
@is_flip_x:是否水平翻转
@delay_per_unit:每帧时间
@has_callback:是否有动画回调，主动画默认有
@loops:循环次数，>=10为无限循环，可为nil，默认为10
@is_pause_last_frame:是否停在最后一帧，可为nil，默认为false
@x, y: 偏移位置
@off_scale: 偏移大小
@rotation：旋转角度
@anim_start_time：动画开始时间
@Return: AnimateSprite or nil
]]
function DrawObj:ChangeLayerResFrameAnim(render_group, layer_id, anim_path, anim_name, is_flip_x, 
			delay_per_unit, has_callback, loops, is_pause_last_frame, x, y, off_scale, rotation, anim_start_time)

	local core_node = self:_EnsureCoreNode(render_group)
	off_scale = off_scale and off_scale or 1

	-- 缓存参数，取消屏蔽的时候还原动画
	local cache_key = render_group * 100000 + layer_id
	if nil == self.anim_cache[cache_key] then
		self.anim_cache[cache_key] = {render_group, layer_id, anim_path, anim_name, is_flip_x, 
			delay_per_unit, has_callback, loops, is_pause_last_frame, x, y, off_scale, rotation, anim_start_time}
	else
		local cache = self.anim_cache[cache_key]
		cache[1] = render_group
		cache[2] = layer_id
		cache[3] = anim_path
		cache[4] = anim_name
		cache[5] = is_flip_x
		cache[6] = delay_per_unit
		cache[7] = has_callback
		cache[8] = loops
		cache[9] = is_pause_last_frame
		cache[10] = x
		cache[11] = y
		cache[12] = off_scale
		cache[13] = rotation
		cache[14] = anim_start_time
	end

	local animate_sprite = self.render_group_child[render_group][layer_id]
	if nil ~= anim_path and "" ~= anim_path and nil ~= anim_name and "" ~= anim_name then
		if nil ~= self.timer_quest then
			GlobalTimerQuest:CancelQuest(self.timer_quest)
			self.timer_quest = nil
		end
		-- 屏蔽时不创建动画
		if (not self.visible) and self:CanVisible(render_group, layer_id) then
			if has_callback or (nil ~= loops and loops < 10 and DrawObj.IsMain(render_group, layer_id)) then
				self.timer_quest = GlobalTimerQuest:AddDelayTimer(function()
					self.timer_quest = 0
					if nil ~= self.scene_obj then
						self.scene_obj:OnMainAnimateCallback(animate_sprite, 2, 0)
					end
				end, 0.5)
			end
			return nil
		end

		if animate_sprite == nil then
			animate_sprite = AnimateSprite:create()

			if DrawObj.IsMain(render_group, layer_id) then
				self.main_animate = animate_sprite
				animate_sprite:addEventListener(function(...)
					if nil ~= self.scene_obj then
						self.scene_obj:OnMainAnimateCallback(...)
					end
				end)
			elseif has_callback then
				animate_sprite:addEventListener(function(...)
					if nil ~= self.scene_obj then
						self.scene_obj:OnMainAnimateCallback(...)
					end
				end)
			end

			if DrawObj.DEF_VISIBLE ~= self.visible and render_group == GRQ_SCENE_OBJ then
				if self:CanVisible(render_group, layer_id) then
					animate_sprite:setVisible(self.visible)
				end
			end
			if DrawObj.DEF_OPACITY ~= self.opacity and self:CanOpacity(render_group, layer_id) then
				animate_sprite:setOpacity(self.opacity)
			end
			if (DrawObj.DEF_SCALE ~= self.scale or off_scale ~= 1) and not NotScaleLayer[layer_id] then
				animate_sprite:setScale(self.scale * off_scale)
			end
			if not IsC3bEqual(self.color, COLOR3B.WHITE) and DrawObj.CanSetColor(render_group, layer_id) then
				animate_sprite:setColor(self.color)
			end

			if DrawObj.HasHeightOffset(render_group, layer_id) then
				animate_sprite:setPositionY(animate_sprite:getPositionY() + self.height_offset)
			end

			core_node:addChild(animate_sprite, layer_id, layer_id)
			self.render_group_child[render_group][layer_id] = animate_sprite
		end
		if nil ~= rotation then
			animate_sprite:setRotation(rotation)
		end

		if nil ~= x and nil ~= y then
			animate_sprite:setPosition(x, y + self.height_offset)
		end
		
		animate_sprite:setAnimate(anim_path, anim_name, loops or COMMON_CONSTS.MAX_LOOPS, delay_per_unit or 0.15, is_flip_x or false)
		if nil ~= is_pause_last_frame then
			animate_sprite:setIsPauseLastFrame(is_pause_last_frame)
		end
		if nil ~= anim_start_time and Status.NowTime > anim_start_time then
			animate_sprite:setElapsed(Status.NowTime - anim_start_time)
		end
	elseif animate_sprite ~= nil then
		animate_sprite:setStop()
	end

	return animate_sprite
end

function DrawObj.IsMain(render_group, layer_id)
	return (render_group == GRQ_SCENE_OBJ and layer_id == InnerLayerType.Main)
end

function DrawObj:SetPos(x, y)
	self.core_pos.x = x
	self.core_pos.y = y
	for _, node in pairs(self.core_nodes) do
		node:setPosition(self.core_pos.x, self.core_pos.y)
	end

	self:SetLocalZOrder(-y)
end

function DrawObj:GetPos()
	return self.core_pos
end

-- Get指定分组的CoreNode，无则创建
function DrawObj:_EnsureCoreNode(group)
	local corenode = self.core_nodes[group]
	if corenode == nil then
		corenode = cc.Node:create()
		self.core_nodes[group] = corenode
		self.core_game_scene:addChildToRenderGroup(corenode, group)
		corenode:setPosition(self.core_pos.x, self.core_pos.y)
		if DrawObj.DEF_ROTATION ~= self.rotation then corenode:setRotation(self.rotation) end
		if DrawObj.DEF_VISIBLE ~= self.visible and self:CanVisible(group, 0) then
			corenode:setVisible(self.visible)
		end

		self.render_group_child[group] = {}
	end

	return corenode
end

function DrawObj:MakeGray(is_gray)
	for k,v in pairs(self.render_group_child) do
		for k1,v1 in pairs(v) do
			AdapterToLua:makeGray(v1, is_gray)
		end
	end
end

function DrawObj:SetAllFrameInterval(interval)
	for k,v in pairs(self.render_group_child) do
		for k1,v1 in pairs(v) do
			v1:setFrameInterval(interval)
		end
	end
end

function DrawObj:IsClick(x, y)
	if nil ~= self.main_animate and self:IsVisible() then
		return self.main_animate:isClick(x - self.core_pos.x, y - self.core_pos.y)
	end

	return GameMath.IsInRect(x - self.core_pos.x, y - self.core_pos.y, -30, 0, 60, 120)
end

function DrawObj:GetHeight()
	if nil == self.main_animate then
		return 0
	end
	return self.main_animate:getHeight() + self.height_offset
end

function DrawObj:GetHightOffest()
	return self.height_offset
end

function DrawObj:GetScale()
	return self.scale
end

function DrawObj:SetScale(scale, is_all)
	self.scale = scale

	for group, node in pairs(self.core_nodes) do
		if group == GRQ_SCENE_OBJ then
			local child_list = node:getChildren()
			for _, sprite in pairs(child_list) do
				if is_all or self:CanScale(group, sprite:getTag()) then
					sprite:setScale(self.scale)
				end
			end
		else
			if self:CanScale(group, 0) then
				node:setScale(self.scale)
			end
		end
	end
end

function DrawObj:CanScale(group, layer_id)
	if GRQ_SCENE_OBJ == group and NotScaleLayer[layer_id] then
		return false
	end
	return true
end

function DrawObj:GetOpacity()
	return self.opacity
end

function DrawObj:SetOpacity(opacity)
	if self.opacity == opacity then
		return
	end
	
	self.opacity = opacity

	for group, v in pairs(self.render_group_child) do
		for layer_id, sprite in pairs(v) do
			if self:CanOpacity(group, layer_id) then
				sprite:setOpacity(self.opacity)
			end
		end
	end
end

-- 是否可半透明
function DrawObj:CanOpacity(group, layer_id)
	if group == GRQ_SCENE_OBJ_AUTO_XUNLU and layer_id == InnerLayerType.AutoEffect then
		return false
	end

	return true
end

function DrawObj:GetRotation()
	return self.rotation
end

function DrawObj:SetRotation(rotation)
	self.rotation = rotation

	for _, node in pairs(self.core_nodes) do
		node:setRotation(self.rotation)
	end
end

function DrawObj:IsVisible()
	return self.visible
end

function DrawObj:SetVisible(visible)
	if self.visible == visible then
		return
	end

	self.visible = visible
	local layer_id = 0

	for group, node in pairs(self.core_nodes) do
		if group == GRQ_SCENE_OBJ then
			local child_list = node:getChildren()
			for _, sprite in pairs(child_list) do
				layer_id = sprite:getTag()
				if self:CanVisible(group, layer_id) then
					sprite:setVisible(visible)
					if (not visible) and nil ~= sprite.setStop and nil ~= self.anim_cache[group * 100000 + layer_id] then
						sprite:setStop()
					end
				end
			end
		else
			if self:CanVisible(group, 0) then
				node:setVisible(visible)
			end
		end
	end

	if visible then
		for _, v in pairs(self.anim_cache) do
			self:ChangeLayerResFrameAnim(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14])
		end
	end
end

-- 是否可隐藏
function DrawObj:CanVisible(group, layer_id)
	if group == GRQ_SHADOW then
		return false
	end

	if group == GRQ_SCENE_OBJ then
		if layer_id == InnerLayerType.Select then
			return false
		elseif layer_id == InnerLayerType.Title then
			return false
		end
	elseif group == GRQ_SCENE_OBJ_NAME then
		return false
	elseif group == GRQ_SCENE_OBJ_HP then
		return false
	end

	return true
end

--隐藏全部。
--shadow是单独放在一层，需要找到对应的影子进行控制
--shadow_id 可用对象id
function DrawObj:SetAllVisible(visible, shadow_id)
	self.visible = visible

	for group, node in pairs(self.core_nodes) do
		if group == GRQ_SCENE_OBJ then
			local child_list = node:getChildren()
			for _, sprite in pairs(child_list) do
				sprite:setVisible(self.visible)
			end
		else
			node:setVisible(self.visible)
		end
	end

	if self.shadow_sprite ~= nil then
		self.shadow_sprite:setVisible(self.visible)
	end
end

-- 高度偏移（骑仙剑的时候用）
function DrawObj:SetHeightOffset(height_offset)
	if self.height_offset ~= height_offset then
		local y_offset = height_offset - self.height_offset
		self.height_offset = height_offset

		for k, v in pairs(self.render_group_child) do
			for layer_id, sprite in pairs(v) do
				if DrawObj.HasHeightOffset(k, layer_id) then
					sprite:setPositionY(sprite:getPositionY() + y_offset)
				end
			end
		end
	end
end

function DrawObj.HasHeightOffset(group, layer_id)
	return group ~= GRQ_SHADOW
end

function DrawObj:SetColor(color)
	if IsC3bEqual(self.color, color) then
		return
	end

	self.color = color
	for k, v in pairs(self.render_group_child) do
		for layer_id, sprite in pairs(v) do
			if DrawObj.CanSetColor(k, layer_id) then
				sprite:setColor(color)
			end
		end
	end
end

function DrawObj.CanSetColor(group, layer_id)
	return GRQ_SCENE_OBJ == group and layer_id >= 40 and layer_id <= 60
end
