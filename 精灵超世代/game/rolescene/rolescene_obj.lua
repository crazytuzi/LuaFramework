-- --------------------------------------------------------------------
-- 自由移动的场景单位基础类型
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RoleSceneObj = RoleSceneObj or BaseClass()

function RoleSceneObj:__init()
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
	self.mechine_speed = 2.96

	-- 用于策划配置表配置修改场景模型的容器`
	self.main_container = ccui.Widget:create()
	self.main_container:setAnchorPoint(0.5, 0)
	self.main_container:setCascadeOpacityEnabled(true)
	self.node:addChild(self.main_container)

	-- 用于层级低于模型的特效
	self.effect_container = ccui.Widget:create()
	self.effect_container:setAnchorPoint(0.5, 0)
	self.effect_container:setCascadeOpacityEnabled(true)
	self.node:addChild(self.effect_container,-1)

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
	self.node:addChild(self.bottom,2)

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

--==============================--
--desc:创建名字格式
--time:2017-10-16 02:56:20
--@return 
--==============================--
function RoleSceneObj:createNameContainer()
	if self.vo == nil then return end

	if self.vo.type == RoleSceneVo.unittype.role then
		if self.name_ttf == nil then
			self.name_ttf = createWithSystemFont("", DEFAULT_FONT, 20)
			self.name_ttf:setColor(Config.ColorData.data_color3[1])
			self.name_ttf:enableOutline(Config.ColorData.data_color3[2], 1)
			self.name_ttf:setAnchorPoint(0.5, 1)
			self.bottom:addChild(self.name_ttf)
		end
	else
		if self.name_container == nil then
			self.name_container = createImage(self.bottom, PathTool.getActionRes("action_name_label"), 0, 0, cc.p(0.5, 1), false, 1, true)
			self.name_ttf = createWithSystemFont("", DEFAULT_FONT, 20)
			self.name_ttf:setColor(Config.ColorData.data_color3[1])
			self.name_ttf:enableOutline(Config.ColorData.data_color3[2], 1)
			self.name_ttf:setAnchorPoint(0.5, 0.5)
			self.name_ttf:setPositionY(21)
			self.name_container:addChild(self.name_ttf)
		end
	end
end

function RoleSceneObj:setVisible( bool )
	if not tolua.isnull(self.node) then
		self.node:setVisible(bool)
		self.visible_status = bool
	end
end

function RoleSceneObj:isVisible()
	return self.visible_status 
end

--==============================--
--desc:初始化模型的容器
--time:2017-09-11 07:17:20
--@return 
--==============================--
function RoleSceneObj:initSpine()
	if self.is_init == true then return end
	self.is_init = true

	-- 特殊处理
	if self.vo then
        if self.vo.sub_type ~= RoleSceneVo.sub_unittype.ele then
		    self.shadow = createSprite(PathTool.getResFrame("common2", "common_shadow"), 0, 0, self.spineContainer, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, -99)		
        end
    end
	
	-- 初始化的时候直接设置动作
	if self.vo ~= nil and self.vo.body_res ~= nil then
        if self.vo.type == RoleSceneVo.unittype.role then
		    self:playActionOnce(PlayerAction.battle_stand, self.vo.body_res)
        elseif self.vo.type == RoleSceneVo.unittype.unit then
            if self.vo.sub_type == RoleSceneVo.sub_unittype.ele then
		        self:playActionOnce(PlayerAction.action, self.vo.body_res)
            else
		        self:playActionOnce(PlayerAction.battle_stand, self.vo.body_res)
            end
        end
	end
	if self.vo ~= nil then
		if self.vo.dir == 6 or self.vo.dir == 7 or self.vo.dir == 8 then
			self.spineContainer:setScaleX(-1)
		else
			self.spineContainer:setScaleX(1)
		end	

		--首席的怪物要个随机方向
		if RolesceneController:getInstance():getIsInChiefWar() then 
			if self.vo.type == RoleSceneVo.unittype.unit then 
				local rand_num = math.random(0,1)
				if math.ceil(rand_num) == 1 then 
					self.spineContainer:setScaleX(1)
				else 
					self.spineContainer:setScaleX(-1)
				end
			end
		end
	end
end

--==============================--
--desc:设置父容器,并显示到场景中
--time:2017-10-16 03:05:08
--@p:
--@return 
--==============================--
function RoleSceneObj:setParentWnd(p)
	if tolua.isnull(p) then return end
	self.parent_wnd = p
	self.parent_wnd:addChild(self.node)
end

--==============================--
--desc:透明处理
--time:2017-10-16 03:05:34
--@bool:
--@is_alpha:
--@return 
--==============================--
function RoleSceneObj:setAlpha(bool, is_alpha)
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
function RoleSceneObj:setVo(vo)
	self.vo = vo
	self.dir = self.vo.dir
	if RolesceneController:getInstance():getIsInChiefWar() and self.vo.type == RoleSceneVo.unittype.role then
		-- 创建单位名字
		local role_vo = RoleController:getInstance():getRoleVo()
		if role_vo.rid == vo.rid and role_vo.srv_id == vo.srv_id then
			self:createNameContainer()
		end
	else
		if not RolesceneController:getInstance():getIsInChiefWar() then
			-- 创建单位名字
			self:createNameContainer()
		end
	end

	if self.name_ttf then
		self.name_ttf:setString(self.vo.name)
		if self.name_container ~= nil then
		local size = self.name_ttf:getContentSize()
			self.name_container:setContentSize(cc.size(size.width + 40, 36))
			self.name_ttf:setPositionX((size.width+40) * 0.5)
		end
	end
	if self.vo.name == nil or self.vo.name == "" then
		if self.name_container ~= nil then
			self.name_container:setVisible(false)
		end
	end
	
	--status等于0是空闲正常状态，等于1时是进入战斗状态，要显示战斗打叉特效
	if vo.status and vo.status == 1 then 
		if RolesceneController:getInstance():getIsInChiefWar() then
			self:showBattleEffect(true)
		end
	else
		self:showBattleEffect(false)
	end
	self:setWorldPos(cc.p(self.vo.x, self.vo.y))
end

function RoleSceneObj:getVo()
	return self.vo
end

function RoleSceneObj:setZOrder(value)
	self.node:setLocalZOrder(value)
end

function RoleSceneObj:getZOrder()
	return self.node:getLocalZOrder()
end

--==============================--
--desc:设置实际的坐标
--time:2017-09-11 07:15:52
--@pos:
--@return 
--==============================--
function RoleSceneObj:setWorldPos(pos)
	if self.world_pos and self.world_pos.x == pos.x and self.world_pos.y == pos.y then return end
	self.world_pos = cc.p(pos.x, pos.y)
	self.node:setPosition(self.world_pos)
	self.logic_pos = TileUtil.changeToTilePoint(self.world_pos)

	-- 储存位置
	if self.vo ~= nil then
		self.vo.x = pos.x
		self.vo.y = pos.y
	end
	self:setZOrder(720-pos.y)
end

function RoleSceneObj:getWorldPos()
	return self.world_pos
end

--[[
	功能: 设置逻辑坐标 x、y 逻辑坐标值
]]
function RoleSceneObj:setLogicPos(pos)
	if self.logic_pos and self.logic_pos.x == pos.x and self.logic_pos.y == pos.y then return end
	self.logic_pos = pos

	local pos = TileUtil.changeToPixsPoint(pos)
	self:setWorldPos(pos)
end

--[[功能: 获取逻辑坐标]]
function RoleSceneObj:getLogicPos()
	return self.logic_pos
end
--==============================--
--desc:显示或隐藏战斗特效
--time:2017-11-10 02:04:46
--@bool:
--@return 
--==============================--
function RoleSceneObj:showBattleEffect(bool)
	if not self.battle_effect and bool == false then return end 
	if self.battle_effect then 
		self.battle_effect:runAction(cc.RemoveSelf:create(true))
        self.battle_effect = nil
	end
	if bool == true then 
		if not self.battle_effect then 
			local effect_id = Config.EffectData.data_effect_info[196] or ""
			self.battle_effect = createEffectSpine( effect_id, cc.p(0,0), cc.p(0.5, 0.5), true,"action")
			self.topContainer:addChild(self.battle_effect,10)
		end
	end
end
--[[
	
]]
function RoleSceneObj:stopAllActions()
	self.node:stopAllActions()
end

--[[
	注册点击事件
]]
function RoleSceneObj:registEvent()
	
end

--[[
	预留
]]
function RoleSceneObj:update(dt)
end

--==============================--
--desc:设置朝向
--time:2017-09-11 07:16:35
--@value:
--@force:
--@return 
--==============================--
function RoleSceneObj:setDir(value, force)
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
		--首席争霸中有2个方向
		local action_name = self.body_action_name
		if RolesceneController:getInstance():getIsInChiefWar() then
			if self.vo and self.vo.type == RoleSceneVo.unittype.role then
				action_name = GameMath.GetRealActionName(action_name,self.vo.dir)
			end
		end
		if not tolua.isnull(self.body) then
			self.body:setAnimation(0, action_name, true)
			self.body:setToSetupPose()
		end
		if value == 6 or value == 7 or value == 8 then
			self.spineContainer:setScaleX(-1)
		else
			self.spineContainer:setScaleX(1)
		end	
	end
end

-- 移动（非A星，自由移动 ）
function RoleSceneObj:freeMove( end_pos )
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

function RoleSceneObj:doRun()
	if self.is_init == false then return end
	if self.isRun and self.last_dir == self.dir then return end
	self.isRun = true
	self:playActionOnce(PlayerAction.run)
end

function RoleSceneObj:doStand()
	if self.is_init == false then return end
	local vo = self.vo
	if vo == nil then return end
	if not self.isRun then return end
	self.isRun = false
	self:playActionOnce(PlayerAction.battle_stand)
end

-- 重新加载模型
function RoleSceneObj:reload()
	self:playActionOnce(self.base_action_name, self.vo.body_res)
end

--==============================--
--desc:创建指定动作,
--time:2017-06-03 03:35:16
--@action_name:
--@body_spine:
--return 
--==============================--
function RoleSceneObj:playActionOnce(action_name, body_spine)
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
function RoleSceneObj:playActionOnceTime(action, is_loop)
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
function RoleSceneObj:_createSpineByName(action_name, body_spine)
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

function RoleSceneObj:createBody(spine_name, action)
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
	--首席争霸中有2个方向
	local action_name = self.body_action_name
	if RolesceneController:getInstance():getIsInChiefWar() then
		if self.vo and self.vo.type == RoleSceneVo.unittype.role then
			action_name = GameMath.GetRealActionName(action_name, self.dir_number)
		end
	end
	if not tolua.isnull(self.body) then
		self.body:setAnimation(0, action_name, true)
		self.body:setToSetupPose()
	end
end

function RoleSceneObj:removeBody()
	if self.body ~= nil then
		self.body:setVisible(false)
		self.body:runAction(cc.RemoveSelf:create(true))
		self.body:clearTracks()
	end
	self.body = nil
	self.body_action_name = nil
	self.body_spine_name = nil
end

function RoleSceneObj:createArmature(spine_name, action_name)
	local armature = createSpineByName(spine_name, action_name)
	armature:setAnchorPoint(cc.p(0.5, 0))
	return armature
end

--==============================--
--desc:计算模型的尺寸,设置相关的位置
--time:2017-06-13 10:41:49
--return 
--==============================--
function RoleSceneObj:updateNamePos()
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

		if self.vo and self.vo.type == RoleSceneVo.unittype.unit then
			if self.vo.sub_type == RoleSceneVo.sub_unittype.npc then
				self.bottom:setPosition(math.ceil(self.boxWidth/2), math.ceil(self.boxHeight+self.topOffY+10))
			else
				self.bottom:setPosition(math.ceil(self.boxWidth/2), 0)
			end
		else
			self.bottom:setPosition(math.ceil(self.boxWidth/2), 0)
		end

		self.topContainer:setPosition(math.ceil(self.boxWidth/2), math.ceil(self.boxHeight+self.topOffY+10))

		self.container:setContentSize(cc.size(self.boxWidth, self.boxHeight))
		self.container:setPosition(math.ceil(self.boxWidth/2), 0)

		self.changeBodyRes = false
	end
end

function RoleSceneObj:setModelScale(scale)
	if self.main_container and not tolua.isnull(self.main_container) then
		self.main_container:setScale(scale)
	end
end

--==============================--
--desc:更新头顶特效的位置
--time:2017-09-13 11:16:00
--@args:
--@return 
--==============================--
function RoleSceneObj:updateEffectPos( ... )
	if self.topContainer then
		local height = 0
		--buff特效
		if self.buffEffect and self.buffEffect:getParent() then
			self.buffEffect:setPosition(0,height)
			height = height + self.buffEffect:getBoundingBox().height
		end
		-- 战斗状态特效
		if self.fightEffect and self.fightEffect:getParent() then
			self.fightEffect:setPosition(0,height)
			height = height + self.fightEffect:getBoundingBox().height
		end
		-- 自己指向特效
		if self.own_mark_effect and self.own_mark_effect:getParent() then
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
function RoleSceneObj:createSomeEffect(status, spine, parent, res)
	if status == false then
		if spine ~= nil and spine:getParent() ~= nil then
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

function RoleSceneObj:__delete()
	self:removeBody()
	self:showBattleEffect(false)
	if self.node:getParent() then
		self.node:removeAllChildren()
		self.node:getParent():removeChild(self.node)
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
