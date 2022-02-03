--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-26 00:20:57
-- @description    : 
		-- 家园角色
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

-- 角色行走的方向
local Move_Dir = {
    Left_Top = 1,
    Left_Down = 2,
    Rigth_Top = 3,
    Rigth_Down = 4,
}

HomeworldRole = HomeworldRole or BaseClass()

function HomeworldRole:__init( parent )
	self.parent = parent
	self.cur_role_grid_x = 10 -- 当前宠物位置的格子坐标x
	self.cur_role_grid_y = 10 -- 当前宠物位置的格子坐标y
    self.can_move_role = true
    self.is_visible = true

    self.role_action_id = 0 -- 当前动作组id
    self.role_action_cfg = {} -- 当前动作组配置数据
    self.action_step = 1     -- 当前动作组执行的动作id
    self.move_action_data = {} -- 当前行走动作的数据（方向和终点格子坐标）
    self.is_show_action = false -- 当前是否正在播放动作组

	self:createRoorWnd()
    self:registerEvent()
end

function HomeworldRole:createRoorWnd(  )
	self.root_wnd = ccui.Layout:create()
    --[[self.root_wnd:setBackGroundColor(cc.c3b(50,50,50))
    self.root_wnd:setBackGroundColorOpacity(216)
    self.root_wnd:setBackGroundColorType(1)--]]
    self.size = cc.size(120, 160)
	self.root_wnd:setAnchorPoint(cc.p(0.5, 0))
    self.root_wnd:setContentSize(self.size)
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setSwallowTouches(true)
    self.parent:addChild(self.root_wnd, 99)

    -- 预加载音效
    AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_home_character01')
    AudioManager:getInstance():preLoadEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_home_character02')
end

function HomeworldRole:registerEvent(  )
	self.root_wnd:addTouchEventListener(function ( sender, event_type )
        if not self.can_move_role then return end
		if event_type == ccui.TouchEventType.began then
            self:showRoleMoveAction(false)
    		self.touch_began = sender:getTouchBeganPosition()
            self.move_begin_grid_x = self.cur_role_grid_x
            self.move_begin_grid_y = self.cur_role_grid_y
    	elseif event_type == ccui.TouchEventType.moved then
    		if not self._is_update_occ and self.sole_id then
                self._is_update_occ = true
                _controller:updateOccupyGridList({{HomeworldConst.Scene_Unit_Type.Role, self.sole_id}}, 1)
                self:updateGridStatus(true, self.cur_role_grid_x, self.cur_role_grid_y)
                self:setLocalZOrder(99)
            end
            local touch_move_pos = sender:getTouchMovePosition()
            if self.touch_began and touch_move_pos and (math.abs(touch_move_pos.x - self.touch_began.x) > 10 or math.abs(touch_move_pos.y - self.touch_began.y) > 10) then 
                local node_pos = self.parent:convertToNodeSpace(touch_move_pos)
                self:moveRoleByPos(node_pos)
            end
        elseif event_type == ccui.TouchEventType.ended or event_type == ccui.TouchEventType.canceled then
            self.show_move_action = false
            self._is_update_occ = false
            local touch_end = sender:getTouchEndPosition()
            local is_move = false
            if self.touch_began and touch_end and (math.abs(touch_end.x - self.touch_began.x) > 10 or math.abs(touch_end.y - self.touch_began.y) > 10) then 
                --移动大于10了
                is_move = true
            end
            if is_move == false then
            	playButtonSound2()
            	self:onClickRole()
            else
                -- 移动结算重新计算一下位置的格子状态
                if not self.last_grid_can_use then
                    self.cur_role_grid_x = self.move_begin_grid_x
                    self.cur_role_grid_y = self.move_begin_grid_y
                    self:adjustPosition(self.cur_role_grid_x, self.cur_role_grid_y)
                end
                self:playRoleAction(PlayerAction.caught_3)
            end
            self:updateGridStatus(false)
            _controller:updateAllUnitZorder()
        end
	end)
end

-- 点击宠物
function HomeworldRole:onClickRole(  )
    self:showRoleMoveAction(false)
	self:playRoleAction(PlayerAction.interaction)
end

-- 移动角色
function HomeworldRole:moveRoleByPos( pos )
    local grid_x, grid_y = HomeTile.toTile(nil, pos.x, pos.y - 80)
    if self.cur_role_grid_x ~= grid_x or self.cur_role_grid_y ~= grid_y then
        self:adjustPosition(grid_x, grid_y)
        self:updateGridStatus(true, grid_x, grid_y)
        self.cur_role_grid_x = grid_x
        self.cur_role_grid_y = grid_y
        if _model:checkGridIsCanWalk(grid_x, grid_y, HOME_TILE_TYPE_LAND) then
            self.last_grid_can_use = true
        else
            self.last_grid_can_use = false
        end
    end

    if not self.show_move_action then
        self.show_move_action = true
        self:playRoleAction(PlayerAction.caught_1)
    end
end

-- 显示\隐藏格子
function HomeworldRole:updateGridStatus( status, grid_x, grid_y )
	if status == true then
		if not self.grid_node then
			self.grid_node = createSprite(PathTool.getResFrame("homeworld", "homeworld_1024"), nil, nil, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
	        local pos_x, pos_y = HomeTile.toPixel(nil, grid_x, grid_y)
            if self.parent.pos_node then
                self.parent.pos_node:setPosition(cc.p(pos_x, pos_y))
                local world_pos = self.parent.pos_node:convertToWorldSpace(cc.p(0, 0))
                local node_pos = self.root_wnd:convertToNodeSpace(world_pos)
                self.grid_node:setPosition(node_pos)
            end
        end
		local grid_res = PathTool.getResFrame("homeworld", "homeworld_1024")
        if not _model:checkGridIsCanWalk(grid_x, grid_y, HOME_TILE_TYPE_LAND) then
            grid_res = PathTool.getResFrame("homeworld", "homeworld_1023")
        end
        if not self.cur_grid_res or self.cur_grid_res ~= grid_res then
            self.cur_grid_res = grid_res
            loadSpriteTexture(self.grid_node, grid_res, LOADTEXT_TYPE_PLIST)
        end
        self.grid_node:setVisible(true)
	elseif self.grid_node then
		self.grid_node:setVisible(false)
	end
end

-- 更新位置
function HomeworldRole:adjustPosition( grid_x, grid_y )
    grid_x = grid_x or self.cur_role_grid_x
    grid_y = grid_y or self.cur_role_grid_y
    local pos_x, pos_y = HomeTile.toPixel(nil, grid_x, grid_y)
    self.root_wnd:setPosition(cc.p(pos_x, pos_y))
end

-- is_my_home_role:标识是否为我的家园中的角色形象 is_owner:是否为房主
function HomeworldRole:setData( data, is_my_home_role, is_owner )
	if not data then return end

    self.figure_id = data.look_id
    self.role_name = data.name
    self.role_rid = data.rid
    self.role_srv_id = data.srv_id
    self.sole_id = getNorKey(data.rid, data.srv_id)
    self.can_move_role = is_my_home_role
    self.is_owner = is_owner or false

    if self:getRandomGridPos() then
        local figure_cfg = Config.HomeData.data_figure[self.figure_id]
        if not figure_cfg then return end
        
        self:removeRoleSpine()
        local effect_id = figure_cfg.look_id or "H60001"
        self.role_spine = createEffectSpine( effect_id, cc.p(60, 0), cc.p(0.5, 0), true, PlayerAction.idle, handler(self, self._onRoleActionEndCallback) )
        self.role_spine:setScale(0.65)
        self.root_wnd:addChild(self.role_spine)
        self.cur_role_action = PlayerAction.idle

        if self.owner_icon then
            self.owner_icon:setVisible(false)
        end
        if self.role_name and self.role_name ~= "" then
            if not self.name_bg then
                self.name_bg = createImage(self.root_wnd, PathTool.getResFrame("common", "common_90056"), self.size.width*0.5, -20, cc.p(0.5, 0.5), true, 1)
                self.name_bg:setScale(0.5)
            end
            if not self.name_txt then
                self.name_txt = createRichLabel(20, 1, cc.p(0.5, 0.5), cc.p(self.size.width*0.5, -20))
                self.root_wnd:addChild(self.name_txt)
                self.name_txt:setLocalZOrder(2)
            end
            local role_vo = RoleController:getInstance():getRoleVo()
            if not is_my_home_role then
                if role_vo.rid == self.role_rid and role_vo.srv_id == self.role_srv_id then
                    self.name_txt:setString(_string_format("<div fontcolor=#FFDB4C>%s</div>", self.role_name))
                elseif self.is_owner then
                    if not self.owner_icon then
                        self.owner_icon = createSprite(PathTool.getResFrame("homeworld","homeworld_1060"), -5, -20, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 1)
                    end
                    self.owner_icon:setVisible(true)
                    self.name_txt:setString(_string_format("<div fontcolor=#DBC39D>%s</div>", self.role_name))
                else
                    self.name_txt:setString(_string_format("<div fontcolor=#ffffff>%s</div>", self.role_name))
                end
            else
                self.name_txt:setString(_string_format("<div fontcolor=#ffffff>%s</div>", self.role_name))
            end
            self.name_bg:setVisible(true)
            self.name_txt:setVisible(true)
        elseif self.name_bg then
            self.name_bg:setVisible(false)
            self.name_txt:setVisible(false)
        end

        self:adjustPosition(self.cur_role_grid_x, self.cur_role_grid_y)
        self:showRoleMoveAction(true)
    end
end

-- 随机取一个空的格子
function HomeworldRole:getRandomGridPos(  )
    _controller:updateOccupyGridList(nil, 1)

    local all_can_use_list = {}
    local default_grid_x = 11
    local default_grid_y = 41
    for i=1,18 do
        for j=1,39 do
            local is_can_walk = _model:checkGridIsCanWalk(default_grid_x, default_grid_y, HOME_TILE_TYPE_LAND)
            if is_can_walk == true then
                table.insert(all_can_use_list, {default_grid_x, default_grid_y})
            end
            default_grid_y = default_grid_y - 1
        end
        default_grid_x = default_grid_x - 1
        if default_grid_x < 1 then
            default_grid_x = 21
        end
        default_grid_y = 41
    end

    if #all_can_use_list > 0 then
        local index = math.random(1, #all_can_use_list)
        self.cur_role_grid_x = all_can_use_list[index][1]
        self.cur_role_grid_y = all_can_use_list[index][2]
        return true
    else
        return false
    end
end

function HomeworldRole:_onRoleActionEndCallback(  )
	-- 交互动作播放完毕则恢复闲转动作
	if self.cur_role_action == PlayerAction.interaction then
		self:playRoleAction(PlayerAction.idle)
        self:showRoleMoveAction(true)
    elseif self.cur_role_action == PlayerAction.caught_1 then
        self:playRoleAction(PlayerAction.caught_2)
    elseif self.cur_role_action == PlayerAction.caught_3 then
        self:playRoleAction(PlayerAction.idle)
        self:showRoleMoveAction(true)
	end
end

-- 播放宠物动作
function HomeworldRole:playRoleAction( action )
    if not self.role_spine or self.cur_role_action and self.cur_role_action == action then return end
    
    if action == PlayerAction.caught_1 then -- 提起来
        AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, "c_home_character01")
    elseif action == PlayerAction.caught_3 then -- 放下去
        AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, "c_home_character02")
    end

	local is_loop = true
	if action == PlayerAction.interaction or action == PlayerAction.caught_1 or action == PlayerAction.caught_3 then
		is_loop = false
	end
    self.role_spine:setToSetupPose()
	self.role_spine:setAnimation(0, action, is_loop)
	self.cur_role_action = action
end

-- 角色行走
function HomeworldRole:showRoleMoveAction( status )
    self.root_wnd:stopAllActions()
    self:openMoveActionGridTimer(false)
    self.role_action_id = 0
    self.role_action_cfg = {}
    self.action_step = 0
    self.move_action_data = {}
    self:playRoleAction(PlayerAction.idle)
    if status == true then
        if not _controller:getHomeEditStatus() then
            _controller:updateAllUnitZorder()
        end
        self.is_show_action = true
        self.role_action_id = math.random(1, Config.HomeData.data_role_action_length)
        self.role_action_cfg = Config.HomeData.data_role_action[self.role_action_id]
        self:playNextAction()
    else
        self:playRoleAction(PlayerAction.idle)
        self.is_show_action = false
    end
end

function HomeworldRole:playNextAction(  )
    if not self.role_action_cfg then return end
    self.action_step = self.action_step + 1
    local act_cfg = self.role_action_cfg.action[self.action_step]
    if act_cfg then
        local act_name = act_cfg[1]
        local act_num = act_cfg[2] or 1
        if act_name == "idle" then -- 待机动作
            self:playRoleAction(PlayerAction.idle)
            delayRun(self.root_wnd, act_num, function (  )
                self:playNextAction()
            end)
        elseif act_name == "move" then -- 移动动作
            -- 这里校正一遍位置
            local cur_pos_x, cur_pos_y = self.root_wnd:getPosition()
            self.cur_role_grid_x, self.cur_role_grid_y = HomeTile.toTile(HOME_TILE_TYPE_LAND, cur_pos_x, cur_pos_y)
            local grids, grid_num = self:getMoveDirAndGridNumByNum(act_num)
            if grids and next(grids) ~= nil then
                self:playRoleAction(PlayerAction.move)
                self.move_action_data = grids
                local pos_x, pos_y = HomeTile.toPixel(HOME_TILE_TYPE_LAND, grids[1], grids[2])
                if grids[3] == Move_Dir.Left_Top or grids[3] == Move_Dir.Left_Down then
                    self.role_spine:setScaleX(-0.65)
                else
                    self.role_spine:setScaleX(0.65)
                end
                local time = grid_num*2
                self.root_wnd:runAction(cc.Sequence:create(cc.MoveTo:create(time, cc.p(pos_x, pos_y)), cc.CallFunc:create(function (  )
                    self.root_wnd:stopAllActions()
                    self:openMoveActionGridTimer(false)
                    self:playNextAction()
                end)))
                -- 更新坐标位置
                self:openMoveActionGridTimer(true)
            else
                self:showRoleMoveAction(true)
            end
        else
            self:showRoleMoveAction(true)
        end
    elseif self.is_visible == true then
        self:showRoleMoveAction(true)
    end
end

-- 根据需要行走的格子数，获取满足条件的方向上的格子坐标
function HomeworldRole:getMoveDirAndGridNumByNum( num )
    local dir_grids = {}
    while (next(dir_grids) == nil and num > 0) do
        for dir=1,4 do
            local is_can_walk, grid_x, grid_y = self:checkDirGridIsCanWalk(dir, num)
            if is_can_walk and self.cur_role_grid_x ~= grid_x and self.cur_role_grid_y ~= grid_y then
                _table_insert(dir_grids, {grid_x, grid_y, dir})
            end
        end
        num = num - 1
    end

    if next(dir_grids) ~= nil then
        local index = math.random(1, #dir_grids)
        return dir_grids[index], num+1
    else
        return
    end
end

function HomeworldRole:checkDirGridIsCanWalk( dir, num )
    local is_can_walk = true
    local temp_grid_x = self.cur_role_grid_x
    local temp_grid_y = self.cur_role_grid_y
    local occ_grid_list = _controller:getOccupyGridList({{HomeworldConst.Scene_Unit_Type.Role, self.sole_id}}, 1)
    for k=1,num do
        if dir == Move_Dir.Left_Top then
            temp_grid_x, temp_grid_y = HomeTile.tileOffset(self.cur_role_grid_x, self.cur_role_grid_y, 0, k)
        elseif dir == Move_Dir.Left_Down then
            temp_grid_x, temp_grid_y = HomeTile.tileOffset(self.cur_role_grid_x, self.cur_role_grid_y, -k, 0)
        elseif dir == Move_Dir.Rigth_Top then
            temp_grid_x, temp_grid_y = HomeTile.tileOffset(self.cur_role_grid_x, self.cur_role_grid_y, k, 0)
        elseif dir == Move_Dir.Rigth_Down then
            temp_grid_x, temp_grid_y = HomeTile.tileOffset(self.cur_role_grid_x, self.cur_role_grid_y, 0, -k)
        end
        is_can_walk = _model:checkGridIsCanWalk(temp_grid_x, temp_grid_y, HOME_TILE_TYPE_LAND, occ_grid_list)
        if is_can_walk == false then
            break
        end
    end
    return is_can_walk, temp_grid_x, temp_grid_y
end

function HomeworldRole:openMoveActionGridTimer( status )
    if status == true then
        if self.move_act_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.move_act_timer)
            self.move_act_timer = nil
        end
        self.move_act_timer = GlobalTimeTicket:getInstance():add(function ()
            local cur_pos_x, cur_pos_y = self.root_wnd:getPosition()
            local cur_grid_x, cur_grid_y = HomeTile.toTile(HOME_TILE_TYPE_LAND, cur_pos_x, cur_pos_y)
            local occ_grid_list = _controller:getOccupyGridList({{HomeworldConst.Scene_Unit_Type.Role, self.sole_id}}, 1)
            if not _model:checkGridIsCanWalk(cur_grid_x, cur_grid_y, HOME_TILE_TYPE_LAND, occ_grid_list) then -- 当前格子不能走了
                self:showRoleMoveAction(true)
            elseif self.cur_role_grid_x ~= cur_grid_x or self.cur_role_grid_y ~= cur_grid_y then
                self.cur_role_grid_x = cur_grid_x
                self.cur_role_grid_y = cur_grid_y
                if not _controller:getHomeEditStatus() then
                    _controller:updateAllUnitZorder() -- 格子变化了，更新一下层级关系 
                end
            end                   
        end, 0.1)
    else
        if self.move_act_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.move_act_timer)
            self.move_act_timer = nil
        end
    end
end

function HomeworldRole:setVisible( status )
    if self.root_wnd then
        self.root_wnd:setVisible(status)
        self.is_visible = status
        self:playRoleAction(PlayerAction.idle)
        if status == true then -- 判断一下当前位置是否还能用，不能的话就再随机一个位置
            _controller:updateOccupyGridList({{HomeworldConst.Scene_Unit_Type.Role, self.sole_id}}, 1)
            local is_can_walk = _model:checkGridIsCanWalk(self.cur_role_grid_x, self.cur_role_grid_y, HOME_TILE_TYPE_LAND)
            if not is_can_walk then
                if self:getRandomGridPos() then
                    self:adjustPosition()
                    self:showRoleMoveAction(true)
                end
            else
                self:showRoleMoveAction(true)
            end
        else
            self:showRoleMoveAction(false)
        end
    end
end

function HomeworldRole:isVisible(  )
    return self.is_visible
end

function HomeworldRole:removeRoleSpine(  )
	if self.role_spine then
        self.role_spine:clearTracks()
        self.role_spine:removeFromParent()
        self.role_spine = nil
    end
end

-- 设置是否可以移动角色
function HomeworldRole:setCanMoveRoleStatus( status )
    self.can_move_role = status
end

-- 获取角色的唯一id
function HomeworldRole:getSoleId(  )
	return self.sole_id
end

function HomeworldRole:getUnitType(  )
    return HomeworldConst.Scene_Unit_Type.Role
end

-- 获取角色所占的格子坐标(目前只占一格)
function HomeworldRole:getOccupyGridList(  )
	return {{self.cur_role_grid_x, self.cur_role_grid_y}}
end

-- 设置层级
function HomeworldRole:setLocalZOrder( num )
    num = num or 1
    if self.root_wnd then
        self.root_wnd:setLocalZOrder(num)
    end
end

function HomeworldRole:getCurGridPos(  )
    return self.cur_role_grid_x, self.cur_role_grid_y
end

function HomeworldRole:getBottomGridPos(  )
    return self.cur_role_grid_x, self.cur_role_grid_y
end

function HomeworldRole:__delete(  )
    self:showRoleMoveAction(false)
    self:openMoveActionGridTimer(false)
    self:removeRoleSpine()
    if self.root_wnd then
        self.root_wnd:removeAllChildren()
        self.root_wnd:removeFromParent()
    end
end