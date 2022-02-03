
SceneObj = SceneObj or BaseClass()

function SceneObj:__init()
	self.parent_wnd = nil
	self.is_init = false
	self.visible_status = true

	self.node = ccui.Widget:create()
	self.node:setAnchorPoint(0.5, 0)
	self.node:setCascadeOpacityEnabled(true)
    if GM_UI_DEBUG then
        self.node.vo = self
    end

	self.boxHeight = 170 -- 对象高度
	self.boxWidth = 64
	self.topOffY = 0
	self.mechine_speed = 1.5

	-- 用于策划配置表配置修改场景模型的容器`
	self.main_container = ccui.Widget:create()
	self.main_container:setAnchorPoint(0.5, 0)
	self.main_container:setCascadeOpacityEnabled(true)
	self.node:addChild(self.main_container)

	-- 骨骼动画容器,所有spine相关的东西存储容器,可以设置翻转
	self.spineContainer = ccui.Widget:create()
	self.spineContainer:setAnchorPoint(0.5, 0)
	self.spineContainer:setCascadeOpacityEnabled(true)
	self.main_container:addChild(self.spineContainer)
	
	self.container = ccui.Layout:create()
	self.container:setAnchorPoint(0.5, 0)
	self.container:setCascadeOpacityEnabled(true)
	self.main_container:addChild(self.container)

	-- 头顶的.主要是称号,组队标示
	self.topContainer = ccui.Layout:create()
	self.topContainer:setAnchorPoint(cc.p(0.5, 0))
	self.topContainer:setPosition(0,self.boxHeight)
	self.main_container:addChild(self.topContainer)

	-- 底部容器
	self.bottom = ccui.Widget:create()
	self.bottom:setAnchorPoint(0.5, 1)
	self.bottom:setPosition(cc.p(0, -10))
	self.bottom:setCascadeOpacityEnabled(true)
	self.node:addChild(self.bottom,-2)

	-- 名字
	self.name_ttf = createWithSystemFont("", DEFAULT_FONT, 20)
	self.name_ttf:setColor(Config.ColorData.data_color3[1])
	self.name_ttf:enableOutline(Config.ColorData.data_color3[2], 1)
	self.name_ttf:setAnchorPoint(0.5, 1)
	self.topContainer:addChild(self.name_ttf)

	self.isRun = false
	self.alphaState = false
	self.vo = nil
	self.dir = 5
	self.last_dir = 0
	self.is_funing = false

	self.base_action_name = nil

	-- 身体骨骼,创建完成的
	self.body = nil 
	self.body_action_name = nil
	self.body_spine_name = nil

	self.weapon_extend = nil
	self.weapon = nil 
	self.weapon_action_name = nil
	self.weapon_spine_name = nil

	self.ride_extend = nil
	self.ride = nil
	self.ride_action_name = nil
	self.ride_spine_name = nil
end

function SceneObj:setVisible( bool )
	if not tolua.isnull(self.node) then
		self.node:setVisible(bool)
		self.visible_status = bool
	end
end

function SceneObj:isVisible()
	return self.visible_status 
end

--==============================--
--desc:初始化模型的容器
--time:2017-09-11 07:17:20
--@return 
--==============================--
function SceneObj:initSpine()
	if self.is_init == true then return end
	self.is_init = true

	-- 特殊处理
	if self.vo and self.vo.id ~= 10009 then
		self.shadow = createSprite(PathTool.getResFrame("common", "common_30009"), 0, 0, self.spineContainer, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, -99)		
	end
	
	-- 初始化的时候直接设置动作
	if self.vo ~= nil and self.vo.body_res ~= nil then
		self:playActionOnce(PlayerAction.battle_stand, self.vo.body_res)
	end

	if self.vo ~= nil then
		if self.vo.dir == 6 or self.vo.dir == 7 or self.vo.dir == 8 then
			self.spineContainer:setScaleX(-1)
		else
			self.spineContainer:setScaleX(1)
		end	
	end
end

--[[
@功能:设置父类容器
]]
function SceneObj:setParentWnd(p)
	if tolua.isnull(p) then return end
	self.parent_wnd = p
	self.parent_wnd:addChild(self.node)
end

--[[
	设置透明,主要作用于场景透明区域的显示
]]
function SceneObj:setAlpha(bool, is_alpha)
	-- 如果还没创建完成,这时候是不给设置透明
	if self.is_init == false then return end

	if is_alpha then
		if bool then
			self.spineContainer:setOpacity(128)
		else
			self.spineContainer:setOpacity(255)
		end
		return
	end
	if self.alphaState == bool then return end
	self.alphaState = bool
	if bool then
		self.spineContainer:setOpacity(128)
	else
		self.spineContainer:setOpacity(255)
	end
end

--==============================--
--desc:储存数据
--time:2017-09-11 07:15:05
--@vo:
--@return 
--==============================--
function SceneObj:setVo(vo)
	self.vo = vo
	self.dir = self.vo.dir
	if self.name_ttf then
        local name = self.vo.name
        if vo.camp then
            name = GodbattleController:getInstance():convertName(vo)
		elseif vo.srv_id then
			name = transformNameByServ(self.vo.name, vo.srv_id)
		end
        self.name_ttf:setString(name)
        if vo.name_color then
            self.name_ttf:setColor(vo.name_color)
        end
        if vo.name_bg and self.name_bg == nil then
            self.name_bg = createSprite(vo.name_bg, 0, 0, self.topContainer, cc.p(0.5, 1), LOADTEXT_TYPE_PLIST, -1)
        end
	end
	self:setWorldPos(cc.p(self.vo.x, self.vo.y))
end

function SceneObj:getVo()
	return self.vo
end

function SceneObj:setZOrder(value)
	self.node:setLocalZOrder(value)
end

function SceneObj:getZOrder()
	return self.node:getLocalZOrder()
end

--==============================--
--desc:设置实际的坐标
--time:2017-09-11 07:15:52
--@pos:
--@return 
--==============================--
function SceneObj:setWorldPos(pos)
	if self.world_pos and self.world_pos.x == pos.x and self.world_pos.y == pos.y then return end
	self.world_pos = cc.p(pos.x, pos.y)
	self.node:setPosition(self.world_pos)
	self.logic_pos = TileUtil.changeToTilePoint(self.world_pos)

	-- 储存位置
	if self.vo ~= nil then
		self.vo.x = pos.x
		self.vo.y = pos.y
	end

    if self.is_hero then
        self:setZOrder(720-pos.y + 10)
    else
        self:setZOrder(720-pos.y)
    end
end

function SceneObj:getWorldPos()
	return self.world_pos
end

--[[
	功能: 设置逻辑坐标 x、y 逻辑坐标值
]]
function SceneObj:setLogicPos(pos)
	if self.logic_pos and self.logic_pos.x == pos.x and self.logic_pos.y == pos.y then return end
	self.logic_pos = pos

	local pos = TileUtil.changeToPixsPoint(pos)
	self:setWorldPos(pos)
end

--[[功能: 获取逻辑坐标]]
function SceneObj:getLogicPos()
	return self.logic_pos
end

--[[
	
]]
function SceneObj:stopAllActions()
    doStopAllActions(self.node)
end

--[[
	注册点击事件
]]
function SceneObj:registEvent()
	
end

--[[
	预留
]]
function SceneObj:update(dt)
end

--==============================--
--desc:设置朝向
--time:2017-09-11 07:16:35
--@value:
--@force:
--@return 
--==============================--
function SceneObj:setDir(value, force)
	if value == nil then return end
	self.last_dir = self.dir -- 保存之前的朝向
	if force == nil then
		if self.dir == value then return  end
	end
	self.dir = value
	
	-- 储存一下角色数据的朝向
	if self.vo ~= nil then
		self.vo.dir = value
	end

	if self.is_init == true then
		if value == 6 or value == 7 or value == 8 then
			self.spineContainer:setScaleX(-1)
		else
			self.spineContainer:setScaleX(1)
		end	
	end
end

-- 移动（非A星，自由移动 ）
function SceneObj:freeMove( end_pos )
	local start_pos = self.world_pos	
	if start_pos.x == end_pos.x and  start_pos.y == end_pos.y then return end
    self.move_speed = self.move_speed / FPS_RATE

	self.move_pass_distance = 0
	self.move_total_distance = 0
	self.move_start_pos = start_pos
	self.move_end_pos = end_pos
	self.dir_number, self.move_total_distance, self.move_dir = self:computeMoveInfo(end_pos)
	self.isNeedRun = true
	if self.dir_number ~= self.dir then
		self:setDir(self.dir_number)
	end
	-- if not self.isRuning then
		self:doRun()
	-- end
end

function SceneObj:doRun()
	if self.is_init == false then return end
	if self.isRun and self.last_dir == self.dir then return end
	self.isRun = true
	self:playActionOnce(PlayerAction.run)
end

function SceneObj:doStand()
	if self.is_init == false then return end
	local vo = self.vo
	if vo == nil then return end
	if not self.isRun then return end
	self.isRun = false
	self:playActionOnce(PlayerAction.battle_stand)
end

-- 重新加载模型
function SceneObj:reload()
	self:playActionOnce(self.base_action_name, self.vo.body_res)
end

--==============================--
--desc:创建指定动作,
--time:2017-06-03 03:35:16
--@action_name:
--@body_spine:
--return 
--==============================--
function SceneObj:playActionOnce(action_name, body_spine)
	if self.vo == nil or self.is_init == false then return end
	action_name = action_name or PlayerAction.battle_stand
	self.base_action_name = action_name
	-- self:setDir(self.dir_number, true)
	self:_createSpineByName(action_name, body_spine or self.body_spine_name)
end

--==============================--
--desc:播放动作,如果是循环的话,则不需要监听不放完成
--time:2017-06-08 08:34:46
--@action:
--@is_loop:
--return 
--==============================--
function SceneObj:playActionOnceTime(action, is_loop)
	local last_action_name = self.base_action_name
	self:playActionOnce(action)
	if is_loop == false then
	    local finish_func = function(event)
			if event.animation == action then
				self:playActionOnce(last_action_name)
            end
		end
		if self.body ~= nil then
        	self.body:registerSpineEventHandler(finish_func, sp.EventType.ANIMATION_COMPLETE)
		end
	end
end

--[[
	创建骨骼部分
	@desc 非角色类的模型,如果资源id一样不创建,角色类的模型,
]]
function SceneObj:_createSpineByName(action_name, body_spine)
	-- 创建模型
	local create_body

	if self.body_spine_name == nil or (self.body_spine_name ~= body_spine) then
		create_body = true
	else
		if self.body_action_name == nil or self.body_action_name ~= action_name then
			create_body = true
		end
	end

	if create_body then
		self:createBody(body_spine, action_name)
	end
end

function SceneObj:createBody(spine_name, action)
	self:removeBody()
	self.body_spine_name = spine_name
	self.body_action_name = action

	self.body = self:createArmature(self.body_spine_name, self.body_action_name)
	if not tolua.isnull(self.body) then
		self.spineContainer:addChild(self.body)
	end
	if not self.changeBodyRes then
		self.changeBodyRes = true
	end
	if not tolua.isnull(self.body) then
		self.body:setAnimation(0, self.body_action_name, true)
		self.body:setToSetupPose()
	end
end

function SceneObj:removeBody()
	if self.body ~= nil then
		self.body:setVisible(false)
		self.body:clearTracks()
		self.body:removeFromParent()
	end
	self.body = nil
	self.body_action_name = nil
	self.body_spine_name = nil
end

function SceneObj:createArmature(spine_name, action_name)
	local armature = createSpineByName(spine_name, action_name)
	armature:setAnchorPoint(cc.p(0.5, 0))
	return armature
end

--==============================--
--desc:计算模型的尺寸,设置相关的位置
--time:2017-06-13 10:41:49
--return 
--==============================--
function SceneObj:updateNamePos()
	if self.changeBodyRes == true then
		if not tolua.isnull(self.body) then
			self.body:update(0)
			self.boxWidth = self.body:getBoundingBox().width < 0 and 64 or self.body:getBoundingBox().width
			self.boxHeight = self.body:getBoundingBox().height < 0 and 170 or self.body:getBoundingBox().height
		end
		self.node:setContentSize(self.boxWidth, self.boxHeight)

		self.main_container:setContentSize(self.boxWidth, self.boxHeight)
		self.main_container:setPosition(math.ceil(self.boxWidth/2), 0)

		self.spineContainer:setPosition(math.ceil(self.boxWidth/2), 0)

		self.bottom:setPositionX(math.ceil(self.boxWidth/2))

		self.topContainer:setPosition(math.ceil(self.boxWidth/2), math.ceil(self.boxHeight+self.topOffY+10))

		self.container:setContentSize(cc.size(self.boxWidth, self.boxHeight))
		self.container:setPosition(math.ceil(self.boxWidth/2), 0)

		self.changeBodyRes = false
	end
end

function SceneObj:setModelScale(scale)
	if self.main_container and not tolua.isnull(self.main_container) then
		self.main_container:setScale(scale)
	end
end

--==============================--
--desc:更新头顶特效的位置
--time:2017-09-13 11:16:00
--@argsr
--@return 
--==============================--
function SceneObj:updateEffectPos( ... )
	if self.topContainer then
		local height = 30
		--buff特效
		if not tolua.isnull(self.buffEffect) then
			self.buffEffect:setPosition(0,height)
			height = height + self.buffEffect:getBoundingBox().height
		end
		-- 战斗状态特效
		if not tolua.isnull(self.fightEffect) then
			self.fightEffect:setPosition(0,height)
			height = height + self.fightEffect:getBoundingBox().height
		end
		-- 自己指向特效
		if not tolua.isnull(self.own_mark_effect) then
			self.own_mark_effect:setPosition(0,height+20)
			height = height + self.own_mark_effect:getBoundingBox().height
		end
	end
end

--==============================--
--desc:创建特效
--time:2017-09-13 10:53:36
--@status:
--@spine:
--@parent:
--@res:
--@return 
--==============================--
function SceneObj:createSomeEffect(status, spine, parent, res)
	if status == false then
		if  not tolua.isnull(spine) then
			spine:removeFromParent()
			spine = nil
			return nil, true
		end
	else
		if parent then
			if spine == nil then
				spine = createSpineByName(res)
				spine:setAnimation(0, PlayerAction.action, true)
	    		parent:addChild(spine)
	    		return spine, true
			end
		end
	end
	return spine, false
end

function SceneObj:__delete()
	self:removeBody()
	if not tolua.isnull(self.node) then
		self.node:removeAllChildren()
		self.node:removeFromParent()
	end
	self.is_init = false
	self.node = nil
	self.vo = nil
	self.isRun = false
	self.world_pos = nil
	self.move_speed = nil
	self.mechine_speed = nil
	self.move_pass_distance = nil
	self.move_total_distance = nil
	self.move_start_pos = nil
	self.move_end_pos = nil
	self.dir = nil
	self.move_dir = nil
	self.isNeedRun = nil
	self.boxHeight = nil
	self.container = nil
	self.boxWidth = nil
	self.isRuning = nil
	self.had_ride = nil
	self.base_action_name = nil
end
