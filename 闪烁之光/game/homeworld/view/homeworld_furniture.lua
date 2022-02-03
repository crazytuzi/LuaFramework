--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-24 09:51:47
-- @description    : 
		-- 家具
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()

HomeworldFurniture = HomeworldFurniture or BaseClass()

function HomeworldFurniture:__init( parent, callback, is_can_edit )
	self.parent = parent
    self.callback = callback -- 回调函数
    self.is_can_edit = is_can_edit  -- 当前是否可以进行编辑
	self.edit_status = false  -- 是否在编辑状态
    self.cur_dir = HomeworldConst.Dir_Type.Left -- 当前家具方向
    self.cur_grid_x = 0  -- 当前所在的格子坐标x
    self.cur_grid_y = 0  -- 当前所在的格子坐标y
    self.grid_type = HOME_TILE_TYPE_LAND -- 格子类型(见HomeTile)
	self.grid_list = {} 	  -- 格子列表
    self.range_list = {} -- 家具范围
    self.last_grid_can_use = true

    self.size = cc.size(100, 100)

	self:createRoorWnd()
    self:registerEvent()
end

function HomeworldFurniture:createRoorWnd(  )
	self.root_wnd = ccui.Layout:create()
    --[[self.root_wnd:setBackGroundColor(cc.c3b(50,50,50))
    self.root_wnd:setBackGroundColorOpacity(216)
    self.root_wnd:setBackGroundColorType(1)--]]
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0))
	self.root_wnd:setTouchEnabled(false)
	self.parent:addChild(self.root_wnd)
end

function HomeworldFurniture:registerEvent(  )
	self.root_wnd:addTouchEventListener(function ( sender, event_type )
        if not self.is_can_edit then return end
		if event_type == ccui.TouchEventType.began then
    		self.touch_began = sender:getTouchBeganPosition()
            self.move_begin_grid_x = self.cur_grid_x
            self.move_begin_grid_y = self.cur_grid_y
            self.move_begin_dir = self.cur_dir
            self.move_begin_grid_type = self.grid_type
            if self.edit_status == false and self.callback then
                self.callback(1)
            end
    	elseif event_type == ccui.TouchEventType.moved then
            if not self._is_update_occ and self.data then -- 移动的时候只需要处理一次的东西
                self._is_update_occ = true
                -- 是否为地毯
                if self:checkIsCarpet() then
                    _controller:updateOccupyGridList({{HomeworldConst.Scene_Unit_Type.Furniture, self.data.id}, {HomeworldConst.Scene_Unit_Type.Role}}, 2)
                else
                    _controller:updateOccupyGridList({{HomeworldConst.Scene_Unit_Type.Furniture, self.data.id}, {HomeworldConst.Scene_Unit_Type.Role}}, 1)
                end
            end
    		local touch_move_pos = sender:getTouchMovePosition()
            if self.touch_began and touch_move_pos and (math.abs(touch_move_pos.x - self.touch_began.x) > 10 or math.abs(touch_move_pos.y - self.touch_began.y) > 10) then 
                local node_pos = self.parent:convertToNodeSpace(touch_move_pos)
                self:moveFurnitureByPos(node_pos)
            end
        elseif event_type == ccui.TouchEventType.ended or event_type == ccui.TouchEventType.canceled then
            self._is_update_occ = false
            local touch_end = sender:getTouchEndPosition()
            local is_move = false
            if self.touch_began and touch_end and (math.abs(touch_end.x - self.touch_began.x) > 10 or math.abs(touch_end.y - self.touch_began.y) > 10) then 
                --移动大于10了
                is_move = true
            end
            if is_move == false then
            	playButtonSound2()
            	self:onClickFurniture()
            else
                -- 移动结算重新计算一下位置的格子状态
                if not self.last_grid_can_use then
                    self.cur_grid_x = self.move_begin_grid_x
                    self.cur_grid_y = self.move_begin_grid_y
                    self.data:updateIndex(HomeTile.tileIndex( self.cur_grid_x, self.cur_grid_y))
                    self:adjustPosition(self.cur_grid_x, self.cur_grid_y)
                    -- 如果是墙壁物件(需要动态判断是否要左右翻转)
                    if self.config and self.config.type == HomeworldConst.Unit_Type.WallAcc then
                        -- 如果移动之前的位置恰好在中间（11格），则需要特殊处理
                        if self.cur_grid_x == 11 and self.move_begin_dir ~= self.cur_dir then
                            self.grid_type = self.move_begin_grid_type
                            self:changeFurnitureDir()
                        else
                            self:checkWallUnitNeedOverturn(self.cur_grid_x)
                        end
                    end
                    self:updateGridStatus(self.cur_grid_x, self.cur_grid_y)
                end
            end
        end
	end)
end

-- 点击家具
function HomeworldFurniture:onClickFurniture(  )
    if not self.is_can_edit then return end
	self:updateEditStatus(true)
end

-- 移动家具
function HomeworldFurniture:moveFurnitureByPos( pos )
    if not self.edit_status then
        self:updateEditStatus(true)
    end
    local grid_x, grid_y = HomeTile.toTile(self.grid_type, pos.x, pos.y)
    if self.cur_grid_x ~= grid_x or self.cur_grid_y ~= grid_y then
        -- 如果是墙壁物件(需要动态判断是否要左右翻转)
        if self.config and self.config.type == HomeworldConst.Unit_Type.WallAcc then
            self:checkWallUnitNeedOverturn(grid_x)
        end
        self:adjustPosition(grid_x, grid_y)
        self:updateGridStatus(grid_x, grid_y)
        self.cur_grid_x = grid_x
        self.cur_grid_y = grid_y
        self.data:updateIndex(HomeTile.tileIndex(grid_x, grid_y))
        self:updateRestBtnStatus()
    end
end

-- 设置层级
function HomeworldFurniture:setLocalZOrder( num, force )
    num = num or 1
    if self.root_wnd then
        -- 地毯在最底层
        if self.config.type == HomeworldConst.Unit_Type.Carpet then
            if force then
                self.root_wnd:setLocalZOrder(num)
            else
                self.root_wnd:setLocalZOrder(0)
            end
        else
            self.root_wnd:setLocalZOrder(num)
        end        
    end
end

-- 检测是否要翻转
function HomeworldFurniture:checkWallUnitNeedOverturn( grid_x )
    if (grid_x < 11 and self.cur_dir == HomeworldConst.Dir_Type.Right) or (grid_x > 11 and self.cur_dir == HomeworldConst.Dir_Type.Left) then
        if grid_x < 11 then
            self.grid_type = HOME_TILE_TYPE_L_WALL
        else
            self.grid_type = HOME_TILE_TYPE_R_WALL
        end
        self:changeFurnitureDir()
    end
end

-- 改变是否可以编辑的状态
function HomeworldFurniture:changeCanEditStatus( status )
    self.is_can_edit = status
    self.root_wnd:setTouchEnabled(self.is_can_edit)
    if status == false then
        self:updateEditStatus(false)
    end
end

-- 改变编辑状态
function HomeworldFurniture:updateEditStatus( status )
	if self.edit_status == status then return end
    if self.edit_status == true then
        -- 调整一下层级关系
        if self.callback then
            self.callback(2)
        end
    end
	self.edit_status = status

    if status == true then
        self:showGridList()
    else
        for k,object in pairs(self.grid_list) do
            object.grid:setVisible(false)
            object.status = false
            object.range = nil
        end
    end
    self:showEditUI(status)
end

function HomeworldFurniture:getEditStatus(  )
    return self.edit_status
end

-- 编辑的圈
function HomeworldFurniture:showEditUI( status )
    if status == true then
        if self.callback then
            self.callback(4, true)
        end
        if not self.edit_quan_sp then
            self.edit_quan_sp = createSprite(PathTool.getPlistImgForDownLoad("homeworld","homeworld_big_bg_1"), self.size.width*0.5, self.size.height*0.5, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE, 2)
            local quan_size = self.edit_quan_sp:getContentSize()
            self.edit_touch_layer = ccui.Layout:create()
            self.edit_touch_layer:setContentSize(cc.size(quan_size.width-60, quan_size.height-60))
            self.edit_touch_layer:setAnchorPoint(cc.p(0.5, 0.5))
            self.edit_touch_layer:setPosition(cc.p(self.size.width*0.5, self.size.height*0.5))
            self.edit_touch_layer:setTouchEnabled(true)
            self.root_wnd:addChild(self.edit_touch_layer, 1)
            self.edit_touch_layer:addTouchEventListener(function ( sender, event_type )
                if not self.is_can_edit then return end
                if event_type == ccui.TouchEventType.began then
                    self.touch_began = sender:getTouchBeganPosition()
                    self.move_begin_grid_x = self.cur_grid_x
                    self.move_begin_grid_y = self.cur_grid_y
                    if self.edit_status == false and self.callback then
                        self.callback(1)
                    end
                elseif event_type == ccui.TouchEventType.moved then
                    if not self._is_update_occ and self.data then
                        self._is_update_occ = true
                        -- 是否为地毯
                        if self:checkIsCarpet() then
                            _controller:updateOccupyGridList({{HomeworldConst.Scene_Unit_Type.Furniture, self.data.id}, {HomeworldConst.Scene_Unit_Type.Role}}, 2)
                        else
                            _controller:updateOccupyGridList({{HomeworldConst.Scene_Unit_Type.Furniture, self.data.id}, {HomeworldConst.Scene_Unit_Type.Role}}, 1)
                        end
                    end
                    local touch_move_pos = sender:getTouchMovePosition()
                    if self.touch_began and touch_move_pos and (math.abs(touch_move_pos.x - self.touch_began.x) > 10 or math.abs(touch_move_pos.y - self.touch_began.y) > 10) then 
                        local node_pos = self.parent:convertToNodeSpace(touch_move_pos)
                        self:moveFurnitureByPos(node_pos)
                    end
                elseif event_type == ccui.TouchEventType.ended or event_type == ccui.TouchEventType.canceled then
                    self._is_update_occ = false
                    -- 移动结算重新计算一下位置的格子状态
                    if not self.last_grid_can_use then
                        self.cur_grid_x = self.move_begin_grid_x
                        self.cur_grid_y = self.move_begin_grid_y
                        self.data:updateIndex(HomeTile.tileIndex( self.cur_grid_x, self.cur_grid_y))
                        self:adjustPosition(self.cur_grid_x, self.cur_grid_y)
                        -- 如果是墙壁物件(需要动态判断是否要左右翻转)
                        if self.config and self.config.type == HomeworldConst.Unit_Type.WallAcc then
                            -- 如果移动之前的位置恰好在中间（11格），则需要特殊处理
                            if self.cur_grid_x == 11 and self.move_begin_dir ~= self.cur_dir then
                                self.grid_type = self.move_begin_grid_type
                                self:changeFurnitureDir()
                            else
                                self:checkWallUnitNeedOverturn(self.cur_grid_x)
                            end
                        end
                        self:updateGridStatus(self.cur_grid_x, self.cur_grid_y)
                    end
                end
            end)
            -- 方向按钮
            self.dir_btn = createImage(self.edit_quan_sp, PathTool.getResFrame("homeworld", "homeworld_1027"), 156, 303, cc.p(0.5, 0.5), true)
            self.dir_btn:setTouchEnabled(true)
            registerButtonEventListener(self.dir_btn, handler(self, self._onClickDirBtn), true)
            -- 引导需要
            self.dir_btn:setName("guide_dir_btn_" .. self.data.bid)
            -- 确定按钮
            self.confirm_btn = createImage(self.edit_quan_sp, PathTool.getResFrame("homeworld", "homeworld_1028"), 240, 32, cc.p(0.5, 0.5), true)
            self.confirm_btn:setTouchEnabled(true)
            registerButtonEventListener(self.confirm_btn, handler(self, self._onClickConfirmBtn), true)
            -- 引导需要
            self.confirm_btn:setName("guide_confirm_btn_" .. self.data.bid)
            -- 恢复按钮
            self.reset_btn = createImage(self.edit_quan_sp, PathTool.getResFrame("homeworld", "homeworld_1061"), 296, 203, cc.p(0.5, 0.5), true)
            self.reset_btn:setTouchEnabled(true)
            registerButtonEventListener(self.reset_btn, handler(self, self._onClickResetBtn), true)
            -- 查看按钮
            self.check_btn = createImage(self.edit_quan_sp, PathTool.getResFrame("homeworld", "homeworld_1029"), 74, 32, cc.p(0.5, 0.5), true)
            self.check_btn:setTouchEnabled(true)
            registerButtonEventListener(self.check_btn, handler(self, self._onClickCheckBtn), true)
            -- 删除按钮
            self.delete_btn = createImage(self.edit_quan_sp, PathTool.getResFrame("homeworld", "homeworld_1030"), 16, 203, cc.p(0.5, 0.5), true)
            self.delete_btn:setTouchEnabled(true)
            registerButtonEventListener(self.delete_btn, handler(self, self._onClickDeleteBtn), true)
        end
        local quan_size = self.edit_quan_sp:getContentSize()
        if self.config.type == HomeworldConst.Unit_Type.WallAcc then
            self.dir_btn:setVisible(false)
            self.confirm_btn:setPosition(cc.p(quan_size.width-16, quan_size.height*0.5))
            self.reset_btn:setPosition(cc.p(quan_size.width*0.5, quan_size.height-16))
            self.check_btn:setPosition(cc.p(quan_size.width*0.5, 16))
            self.delete_btn:setPosition(cc.p(16, quan_size.height*0.5))
        else
            self.dir_btn:setVisible(true)
            self.confirm_btn:setPosition(cc.p(240, 32))
            self.reset_btn:setPosition(cc.p(296, 203))
            self.check_btn:setPosition(cc.p(74, 32))
            self.delete_btn:setPosition(cc.p(16, 203))
        end
        -- 显示圈的时候记录一下当前格子，用于本次编辑过程中点击恢复按钮
        self.default_grid_x = self.cur_grid_x
        self.default_grid_y = self.cur_grid_y
        self.default_dir = self.cur_dir
        self:updateRestBtnStatus()
        self.edit_quan_sp:setVisible(true)
        self.edit_touch_layer:setVisible(true)
        self:showEditAction(true)
        -- 调整一下层级关系
        if self.callback then
            self.callback(2)
        end
        self:setLocalZOrder(99, true)
    else
        self.default_grid_x = nil
        self.default_grid_y = nil
        self.default_dir = nil
        self:updateRestBtnStatus()
        if self.edit_quan_sp then
            self.edit_quan_sp:setVisible(false)
        end
        if self.edit_touch_layer then
            self.edit_touch_layer:setVisible(false)
        end
        self:showEditAction(false)
    end
end

-- 显示选中编辑的动画
function HomeworldFurniture:showEditAction( status )
    if status then
        if self.edit_quan_sp then
            local scene_scale_val = _controller:getHomeSceneScaleVal()
            self.edit_quan_sp:setScale(0.5)
            self.edit_quan_sp:setOpacity(0)
            self.edit_quan_sp:stopAllActions()
            local act_1 = cc.FadeIn:create(0.2)
            local act_2 = cc.ScaleTo:create(0.1, 1/scene_scale_val+0.2)
            local act_3 = cc.ScaleTo:create(0.1, 1/scene_scale_val)
            self.edit_quan_sp:runAction(cc.Spawn:create(act_1, cc.Sequence:create(act_2, act_3)))
        end
        if self.furniture_sp then
            self.furniture_sp:setScale(0.85)
            self.furniture_sp:stopAllActions()
            local act_2 = cc.ScaleTo:create(0.1, 1.2, 1.2)
            local act_3 = cc.ScaleTo:create(0.1, 1, 1)
            if self.cur_dir == HomeworldConst.Dir_Type.Right then
                self.furniture_sp:setScaleX(-0.85)
                act_2 = cc.ScaleTo:create(0.1, -1.2, 1.2)
                act_3 = cc.ScaleTo:create(0.1, -1, 1)
            end
            self.furniture_sp:runAction(cc.Sequence:create(act_2, act_3))
        end
    else
        if self.edit_quan_sp then
            self.edit_quan_sp:stopAllActions()
        end
        if self.furniture_sp then
            self.furniture_sp:stopAllActions()
        end
    end
end

-- 是否可以转向
function HomeworldFurniture:checkIsCanChangDir( range )
    local is_can_walk = true
    for k,v in pairs(range) do
        local temp_grid_x, temp_grid_y = HomeTile.tileOffset(self.cur_grid_x, self.cur_grid_y, v[1], v[2])
        if not _model:checkGridIsCanWalk(temp_grid_x, temp_grid_y, self.grid_type) then
            is_can_walk = false
            break
        end
    end
    return is_can_walk
end

-- 点击方向按钮
function HomeworldFurniture:_onClickDirBtn(  )
    if not self.config or not self.furniture_sp then return end
    local is_can_change = true
    -- 是否为地毯
    if self:checkIsCarpet() then
        _controller:updateOccupyGridList({{HomeworldConst.Scene_Unit_Type.Furniture, self.data.id}, {HomeworldConst.Scene_Unit_Type.Role}}, 2)
    else
        _controller:updateOccupyGridList({{HomeworldConst.Scene_Unit_Type.Furniture, self.data.id}, {HomeworldConst.Scene_Unit_Type.Role}}, 1)
    end
    if self.cur_dir == HomeworldConst.Dir_Type.Left then
        if self:checkIsCanChangDir(self.config.tile_list_2 or {}) then
            self.cur_dir = HomeworldConst.Dir_Type.Right
            self.range_list = self.config.tile_list_2 or {}
            self.furniture_sp:setScaleX(-1)
        else
            is_can_change = false
        end
    else
        if self:checkIsCanChangDir(self.config.tile_list_1 or {}) then
            self.cur_dir = HomeworldConst.Dir_Type.Left
            self.range_list = self.config.tile_list_1 or {}
            self.furniture_sp:setScaleX(1)
        else
            is_can_change = false
        end
    end
    if is_can_change then
        self:adjustPosition(self.cur_grid_x, self.cur_grid_y)
        self:showGridList()
        self:updateRestBtnStatus()
    else
        message(TI18N("当前位置无法旋转方向"))
    end
end

function HomeworldFurniture:changeFurnitureDir(  )
    if not self.config or not self.furniture_sp then return end
    if self.cur_dir == HomeworldConst.Dir_Type.Left then
        self.cur_dir = HomeworldConst.Dir_Type.Right
        self.range_list = self.config.tile_list_2 or {}
        self.furniture_sp:setScaleX(-1)
    else
        self.cur_dir = HomeworldConst.Dir_Type.Left
        self.range_list = self.config.tile_list_1 or {}
        self.furniture_sp:setScaleX(1)
    end
    self:adjustPosition(self.cur_grid_x, self.cur_grid_y)
    self:showGridList()
    self:updateRestBtnStatus()
end

-- 点击确定按钮
function HomeworldFurniture:_onClickConfirmBtn(  )
    self:updateEditStatus(false)
    if self.callback then
        self.callback(4, false)
    end
end

-- 点击恢复按钮
function HomeworldFurniture:_onClickResetBtn(  )
    if self.default_grid_x and self.default_grid_y and self.default_dir and (self.default_grid_x ~= self.cur_grid_x or self.default_grid_y ~= self.cur_grid_y or self.default_dir ~= self.cur_dir) then
        self.cur_grid_x = self.default_grid_x
        self.cur_grid_y = self.default_grid_y
        self.data:updateIndex(HomeTile.tileIndex( self.cur_grid_x, self.cur_grid_y))
        self:adjustPosition(self.cur_grid_x, self.cur_grid_y)
        if self.default_dir ~= self.cur_dir then
            -- 如果是墙壁物件(需要动态判断是否要左右翻转)
            if self.config and self.config.type == HomeworldConst.Unit_Type.WallAcc then
                self:checkWallUnitNeedOverturn(self.cur_grid_x)
            else
                self:changeFurnitureDir()
            end
        end
        self:updateGridStatus(self.cur_grid_x, self.cur_grid_y)
        self:updateRestBtnStatus()
    else
        message(TI18N("这个家具的位置和方向未发生变化，无法撤销操作"))
    end
end

function HomeworldFurniture:updateRestBtnStatus(  )
    if self.default_grid_x and self.default_grid_y and self.default_dir and (self.default_grid_x ~= self.cur_grid_x or self.default_grid_y ~= self.cur_grid_y or self.default_dir ~= self.cur_dir) then
        setChildUnEnabled(false, self.reset_btn)
    else
        setChildUnEnabled(true, self.reset_btn)
    end
end

-- 点击查看按钮
function HomeworldFurniture:_onClickCheckBtn(  )
    if self.config then
        _controller:openFurnitureInfoWindow(true, self.config.bid)
    end
end

-- 点击删除按钮
function HomeworldFurniture:_onClickDeleteBtn(  )
    if self.data then
        self.callback(3, self.data.id)
    end
    if self.callback then
        self.callback(4, false)
    end
    GlobalEvent:getInstance():Fire(HomeworldEvent.Discharge_Furniture_Event, self.config.bid)
end

-- 显示家具格子
function HomeworldFurniture:showGridList(  )
	for k,object in pairs(self.grid_list) do
        object.grid:setVisible(false)
        object.status = false
        object.range = nil
    end
    if not self.config or not self.data then return end
    local grid_res = self:getGridResByTypeAndStatus(self.config.type, true)
    for k,v in pairs(self.range_list) do
        local object = self.grid_list[k]
        if not object then
            object = {}
            object.grid = createSprite(grid_res, nil, nil, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            object.grid_res = grid_res
            object.scale_x = 1
            self.grid_list[k] = object
        else
            loadSpriteTexture(object.grid, grid_res, LOADTEXT_TYPE_PLIST)
        end
        object.grid:setVisible(true)
        object.status = true
        object.range = v
        object.scale_x = 1
        if self.grid_type == HOME_TILE_TYPE_R_WALL then
            object.scale_x = -1
        end
        object.grid:setScaleX(object.scale_x)
        -- 位置
        local temp_grid_x, temp_grid_y = HomeTile.tileOffset(self.cur_grid_x, self.cur_grid_y, v[1], v[2])
        local pos_x, pos_y = HomeTile.toPixel(self.grid_type, temp_grid_x, temp_grid_y)
        if self.parent.pos_node then
            local node_pos = self:convertPosToNodePos(pos_x, pos_y)
            object.grid:setPosition(node_pos)
            object.node_pos = node_pos
        end
    end
end

-- 更新家具格子状态
function HomeworldFurniture:updateGridStatus( grid_x, grid_y )
    if not self.config then return end
    self.last_grid_can_use = true
    for k,object in pairs(self.grid_list) do
        if object.status and object.range then
            local temp_grid_x, temp_grid_y = HomeTile.tileOffset(grid_x, grid_y, object.range[1], object.range[2])
            local is_can_walk = true
            if not _model:checkGridIsCanWalk(temp_grid_x, temp_grid_y, self.grid_type) then
                is_can_walk = false
                self.last_grid_can_use = false
            end
            -- 位置
            local pos_x, pos_y = HomeTile.toPixel(self.grid_type, temp_grid_x, temp_grid_y)
            local node_pos = self:convertPosToNodePos(pos_x, pos_y)
            if not object.node_pos or object.node_pos.x ~= node_pos.x or object.node_pos.y ~= node_pos.y then
                object.grid:setPosition(node_pos)
                object.node_pos = node_pos
            end
            local grid_res = self:getGridResByTypeAndStatus(self.config.type, is_can_walk)
            if not object.grid_res or object.grid_res ~= grid_res then
                loadSpriteTexture(object.grid, grid_res, LOADTEXT_TYPE_PLIST)
                object.grid_res = grid_res
            end
            local scale_x = 1
            if self.grid_type == HOME_TILE_TYPE_R_WALL then
                scale_x = -1
            end
            if not object.scale_x or object.scale_x ~= scale_x then
                object.grid:setScaleX(scale_x)
                object.scale_x = scale_x
            end
        end
    end
end

-- 格子坐标转为父节点坐标系内坐标
function HomeworldFurniture:convertPosToNodePos( pos_x, pos_y )
    if self.parent.pos_node then
        self.parent.pos_node:setPosition(cc.p(pos_x, pos_y))
        local world_pos = self.parent.pos_node:convertToWorldSpace(cc.p(0, 0))
        local node_pos = self.root_wnd:convertToNodeSpace(world_pos)
        return node_pos
    end
end

-- 根据家具类型和状态获取格子资源
function HomeworldFurniture:getGridResByTypeAndStatus( _type, status )
    if _type == HomeworldConst.Unit_Type.WallAcc then -- 墙饰
        if status then
            return PathTool.getResFrame("homeworld", "homeworld_1026")
        else
            return PathTool.getResFrame("homeworld", "homeworld_1025")
        end
    else  -- 地面家具
        if status then
            return PathTool.getResFrame("homeworld", "homeworld_1024")
        else
            return PathTool.getResFrame("homeworld", "homeworld_1023")
        end
    end
end

function HomeworldFurniture:setData( data, edit_status )
    if not data then return end
	self.data = data
    self.config = data.config
    self.cur_dir = data.dir or data.config.dir or HomeworldConst.Dir_Type.Left
    if self.config.type ~= HomeworldConst.Unit_Type.WallAcc then
        self.grid_type = HOME_TILE_TYPE_LAND
    elseif self.cur_dir == HomeworldConst.Dir_Type.Left then
        self.grid_type = HOME_TILE_TYPE_L_WALL
    elseif self.cur_dir == HomeworldConst.Dir_Type.Right then
        self.grid_type = HOME_TILE_TYPE_R_WALL
    end

    -- 引导需要
    self.root_wnd:setName("guide_furniture_" .. data.bid)

    -- 恢复透明度
    self:setTranslucenceState(false)

	-- 家具图片
    local icon_res = PathTool.getFurnitureSceneRes( self.config.res )
	if not self.furniture_sp then
        self.furniture_sp = createSprite(nil, 0, 0, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE, 1)
	end

    if self.cur_dir == HomeworldConst.Dir_Type.Left then
        self.range_list = self.config.tile_list_1 or {}
        self.furniture_sp:setScaleX(1)
    elseif self.cur_dir == HomeworldConst.Dir_Type.Right then
        self.range_list = self.config.tile_list_2 or {}
        self.furniture_sp:setScaleX(-1)
    end

    if self.data and self.data.index and self.config then
        self.cur_grid_x, self.cur_grid_y = HomeTile.indexTile(self.data.index)
        self:adjustPosition()
    end

    if icon_res then
        if self.unit_load then
            self.unit_load:DeleteMe()
            self.unit_load = nil
        end
        self.unit_load = ResourcesLoad.New()
        self.unit_load:addDownloadList(icon_res, ResourcesType.single, function() 
            loadSpriteTexture(self.furniture_sp, icon_res, LOADTEXT_TYPE)
            self.size = self.furniture_sp:getContentSize()
            self:initSizeAndPos()
        end)
    end

    -- 当前编辑状态
    self:changeCanEditStatus(edit_status)
end

function HomeworldFurniture:initSizeAndPos(  )
    self.root_wnd:setContentSize(self.size)
    self.furniture_sp:setPosition(cc.p(self.size.width*0.5, self.size.height*0.5))
    if self.edit_quan_sp then
        self.edit_quan_sp:setPosition(cc.p(self.size.width*0.5, self.size.height*0.5))
    end
    if self.edit_status then
        self:updateGridStatus(self.cur_grid_x, self.cur_grid_y)
    end    
end

function HomeworldFurniture:adjustPosition( grid_x, grid_y )
    grid_x = grid_x or self.cur_grid_x
    grid_y = grid_y or self.cur_grid_y
    if grid_x and grid_y then
        local offset = {}
        if self.cur_dir == HomeworldConst.Dir_Type.Left then
            offset = self.config.offset_1 or {}
        elseif self.cur_dir == HomeworldConst.Dir_Type.Right then
            offset = self.config.offset_2 or {}
        end
        local pos_x, pos_y = HomeTile.tileRangePixel2( self.grid_type, grid_x, grid_y, self.range_list )
        pos_x = pos_x + (offset[1] or 0)
        pos_y = pos_y + (offset[2] or 0)
        self.root_wnd:setPosition(cc.p(pos_x, pos_y))
    end
end

function HomeworldFurniture:setVisible( status )
	if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end
end

function HomeworldFurniture:suspendAllActions(  )
    self:updateEditStatus(false)
    self:changeCanEditStatus(false)
end

-- 获取该家具的bid
function HomeworldFurniture:getFurnitureBid(  )
    if self.data then
        return self.data.bid
    end
end

-- 获取该家具的唯一id
function HomeworldFurniture:getFurnitureId(  )
    if self.data then
        return self.data.id
    end
end

function HomeworldFurniture:getData(  )
    return self.data
end

function HomeworldFurniture:getUnitType(  )
    return HomeworldConst.Scene_Unit_Type.Furniture
end

-- 获取家具类型
function HomeworldFurniture:getFurnitureType(  )
    if self.config then
        return self.config.type
    end
end

-- 获取该家具所占格子坐标
function HomeworldFurniture:getOccupyGridList(  )
    local grid_list = {}
    if self.cur_grid_x and self.cur_grid_y and self.range_list then
        grid_list = HomeTile.tilesOffset(self.cur_grid_x, self.cur_grid_y, self.range_list)
    end
    return grid_list
end

-- 获取家具所占格子的数量
function HomeworldFurniture:getOccupyGridNum(  )
    if self.range_list then
        return #self.range_list
    end
    return 0
end

-- 获取家具所占的中心点格子
function HomeworldFurniture:getCurGridPos(  )
    return self.cur_grid_x, self.cur_grid_y
end

-- 获取家具最靠下的格子
function HomeworldFurniture:getBottomGridPos(  )
    local temp_grid_x = self.cur_grid_x
    local temp_grid_y = self.cur_grid_y
    if self.range_list then
        for k,v in pairs(self.range_list) do
            local grid_x, grid_y = HomeTile.tileOffset(self.cur_grid_x, self.cur_grid_y, v[1], v[2])
            if grid_y < temp_grid_y then
                temp_grid_x = grid_x
                temp_grid_y = grid_y
            end
        end
    end

    return temp_grid_x, temp_grid_y
end

-- 获取家具的 bid、索引index、方向dir
function HomeworldFurniture:getFurnitureBaseData(  )
    if not self.config then return {} end
    local base_data = {}
    base_data.bid = self.config.bid
    base_data.index = HomeTile.tileIndex(self.cur_grid_x, self.cur_grid_y)
    base_data.dir = self.cur_dir
    return base_data
end

-- 该家具是否为地毯
function HomeworldFurniture:checkIsCarpet(  )
    if self.config and self.config.type == HomeworldConst.Unit_Type.Carpet then
        return true
    end
    return false
end

-- 设置半透明状态
function HomeworldFurniture:setTranslucenceState( status )
    if not self.furniture_sp then return end
    if status and not self.edit_status then
        self.furniture_sp:setOpacity(150)
    else
        self.furniture_sp:setOpacity(255)
    end
end

function HomeworldFurniture:__delete(  )
	if self.unit_load then
        self.unit_load:DeleteMe()
        self.unit_load = nil
    end
    if self.root_wnd then
        self.root_wnd:removeAllChildren()
        self.root_wnd:removeFromParent()
    end
end