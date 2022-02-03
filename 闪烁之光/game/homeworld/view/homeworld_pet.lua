--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-06-26 00:20:57
-- @description    : 
		-- 家园宠物
---------------------------------
local _controller = HomeworldController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format
local _table_insert = table.insert

local PET_SPINE_EFFECT = {
    [1] = "H65001",
    [2] = "H65002",
    [3] = "H65003",
    [4] = "H65004",
}

HomeworldPet = HomeworldPet or BaseClass()

function HomeworldPet:__init( parent )
	self.parent = parent
	self.cur_pet_grid_x = 10 -- 当前宠物位置的格子坐标x
	self.cur_pet_grid_y = 10 -- 当前宠物位置的格子坐标y
    self.cur_btn_status = false
    self.cur_zorder = 1
    self.btn_list = {}
    self.can_move_role = true

	self:createRoorWnd()
    self:registerEvent()
end

function HomeworldPet:createRoorWnd(  )
	self.root_wnd = ccui.Layout:create()
    --[[self.root_wnd:setBackGroundColor(cc.c3b(50,50,50))
    self.root_wnd:setBackGroundColorOpacity(216)
    self.root_wnd:setBackGroundColorType(1)--]]
    self.size = cc.size(120, 80)
	self.root_wnd:setAnchorPoint(cc.p(0.5, 0))
    self.root_wnd:setContentSize(self.size)
    self.root_wnd:setTouchEnabled(true)
    self.root_wnd:setSwallowTouches(true)
    self.parent:addChild(self.root_wnd, 99)

    for i=1,3 do
        local btn_res = nil
        local pos_x, pos_y = nil, nil
        if i == 1 then
            btn_res = PathTool.getResFrame("homeworld", "homeworld_1045")
            pos_x, pos_y = -50, self.size.height*0.5 + 20
        elseif i == 2 then
            btn_res = PathTool.getResFrame("homeworld", "homeworld_1046")
            pos_x, pos_y = self.size.width*0.5, self.size.height + 50
        elseif i == 3 then
            btn_res = PathTool.getResFrame("homeworld", "homeworld_1047")
            pos_x, pos_y = self.size.width + 50, self.size.height*0.5 + 20
        end
        if btn_res and pos_x and pos_y then
            local object = {}
            object.pos_x = pos_x
            object.pos_y = pos_y
            local btn_node = createImage(self.root_wnd, btn_res, pos_x, pos_y, cc.p(0.5, 0.5), true, 2)
            btn_node:setVisible(false)
            btn_node:setTouchEnabled(true)
            registerButtonEventListener(btn_node, function (  )
                self:_onClickBtnByIndex(i)
            end, true,nil,nil,nil,0)
            object.btn_node = btn_node
            _table_insert(self.btn_list, object)
        end
    end
end

function HomeworldPet:_onClickBtnByIndex( index )
    if index == 1 then --信息
        HomepetController:getInstance():openHomePetBaseInfoPanel(true)
    elseif index == 2 then --聊天
        HomepetController:getInstance():sender26103(1)
    elseif index == 3 then --喂食
        HomepetController:getInstance():sender26103(2)
    end
    self.root_wnd:stopAllActions()
    self:showFuncBtnList(false)
end

function HomeworldPet:registerEvent(  )
	self.root_wnd:addTouchEventListener(function ( sender, event_type )
        --别人的宠物不能拖也不能点
        if not self.can_move_role then return end
        if event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
            self.move_begin_grid_x = self.cur_pet_grid_x
            self.move_begin_grid_y = self.cur_pet_grid_y
        elseif event_type == ccui.TouchEventType.moved then
            if not self._is_update_occ and self.sole_id then
                self._is_update_occ = true
                _controller:updateOccupyGridList({{HomeworldConst.Scene_Unit_Type.Role, self.sole_id}}, 1)
                self:updateGridStatus(true, self.cur_pet_grid_x, self.cur_pet_grid_y)
                self:setLocalZOrder(99)
            end
            local touch_move_pos = sender:getTouchMovePosition()
            if self.touch_began and touch_move_pos and (math.abs(touch_move_pos.x - self.touch_began.x) > 10 or math.abs(touch_move_pos.y - self.touch_began.y) > 10) then 
                local node_pos = self.parent:convertToNodeSpace(touch_move_pos)
                self:movePetByPos(node_pos)
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
                self:onClickPet()
            else
                -- 移动结算重新计算一下位置的格子状态
                if not self.last_grid_can_use then
                    self.cur_pet_grid_x = self.move_begin_grid_x
                    self.cur_pet_grid_y = self.move_begin_grid_y
                    self:adjustPosition(self.cur_pet_grid_x, self.cur_pet_grid_y)
                end
                -- self:playRoleAction(PlayerAction.caught_3)
            end
            self:updateGridStatus(false)
            _controller:updateAllUnitZorder()
            self:randomPlayAudioEffect()
        end
	end)
end

-- 点击宠物
function HomeworldPet:onClickPet(  )
    self:showFuncBtnList(not self.cur_btn_status)
end

-- 随机播放音效
function HomeworldPet:randomPlayAudioEffect(  )
    local index = math.random(1, 5)
    AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, "c_home_pet0" .. index)
end

--设置宠物聊天
function HomeworldPet:setPetTalkInfo(text)
    self:showTalkPanel(true, text)
    doStopAllActions(self.talk_panel)
    --5秒后关闭
    delayRun(self.talk_panel, 5, function (  )
        self:showTalkPanel(false)
    end)
end
--显示宠物聊天内容 
--@status 是否显示
--@text 显示文本
function HomeworldPet:showTalkPanel(status, text)
    if status then
        --聊天框最大长度
        local start_x = 10
        local start_y = 10
        local start_end_y = 24
        local max_width = 200 
        if self.talk_panel == nil then
            local res = PathTool.getResFrame("common","common_1067")
            self.talk_panel = createImage(self.root_wnd, res, self.size.width * 0.5, self.size.height, cc.p(0.5,0), true, 0, true)
            self.talk_panel:setCapInsets(cc.rect(36, 21, 6, 22))
            self.talk_label = createRichLabel(20, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0,1), cc.p(start_x,0), 6, nil, max_width - start_x * 2)
            self.talk_panel:addChild(self.talk_label)
        else
            self.talk_panel:setVisible(true)
        end
        self.talk_label:setString(text)
        local size = self.talk_label:getContentSize()
        local width = math.min(size.width, max_width)
        local height = start_y + start_end_y + size.height
        self.talk_panel:setContentSize(cc.size(start_x * 2 + width, height))
        self.talk_label:setPosition(start_x, height - start_y)

    else
        if self.talk_panel then
            self.talk_panel:setVisible(false)
        end
    end
end

-- 显示\隐藏格子
function HomeworldPet:updateGridStatus( status, grid_x, grid_y )
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
function HomeworldPet:adjustPosition( grid_x, grid_y )
    grid_x = grid_x or self.cur_pet_grid_x
    grid_y = grid_y or self.cur_pet_grid_y
    local pos_x, pos_y = HomeTile.toPixel(nil, grid_x, grid_y)
    self.root_wnd:setPosition(cc.p(pos_x, pos_y))
end

function HomeworldPet:setData( data )
	if not data then return end

	self.data = data

    if self:getRandomGridPos() then    
        self:removePetSpine()
        local effect_name = self:getPetEffectName()
        self.pet_spine = createEffectSpine(effect_name, cc.p(self.size.width*0.5, 0), cc.p(0.5, 0), true, PlayerAction.idle)
        self.root_wnd:addChild(self.pet_spine, 1)

        self:adjustPosition(self.cur_pet_grid_x, self.cur_pet_grid_y)
    end

    local config = Config.HomePetData.data_const.pet_act_interval
    if config then
        local time = config.val
        --开启宠物随机动作
        if self.action_change_ticket then
            GlobalTimeTicket:getInstance():remove(self.action_change_ticket)
            self.action_change_ticket = nil
        end
        self.action_change_ticket = GlobalTimeTicket:getInstance():add(function() 
            self:showPetSpine()
        end, time)
    end

    self:showPetArrow(true)
end

function HomeworldPet:showPetSpine()
    self:removePetSpine()
    local effect_name = self:getPetEffectName(self.spine_index)
    self.pet_spine = createEffectSpine(effect_name, cc.p(self.size.width*0.5, 0), cc.p(0.5, 0), true, PlayerAction.idle)
    self.root_wnd:addChild(self.pet_spine, 1)
    -- 切换箭头气泡
    self:updateRandomArrowRes()
end
function HomeworldPet:getPetEffectName(ignore_index)
    local index_list = {}
    if ignore_index then
        for i,v in ipairs(PET_SPINE_EFFECT) do
            if i ~= ignore_index then
                _table_insert(index_list, i)
            end
        end
        local index = math.random(1, #index_list)
        self.spine_index = index_list[index]
        return PET_SPINE_EFFECT[self.spine_index] or "H65001"
    else
        self.spine_index = math.random(1, #PET_SPINE_EFFECT)
        return PET_SPINE_EFFECT[self.spine_index] or "H65001"
    end
   
end

-- 随机取一个空的格子
function HomeworldPet:getRandomGridPos(  )
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
        self.cur_pet_grid_x = all_can_use_list[index][1]
        self.cur_pet_grid_y = all_can_use_list[index][2]
        return true
    else
        return false
    end
end

-- 显示按钮
function HomeworldPet:showFuncBtnList( status )
    self.cur_btn_status = status
    for i,object in ipairs(self.btn_list) do
        object.btn_node:stopAllActions()
        if status == true then
            self.root_wnd:setLocalZOrder(99)
            object.btn_node:setPosition(cc.p(self.size.width*0.5, self.size.height*0.5))
            object.btn_node:setVisible(true)
            object.btn_node:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(object.pos_x, object.pos_y)), cc.CallFunc:create(function (  )
                object.btn_node:setTouchEnabled(true)
            end)))
        else
            self.root_wnd:setLocalZOrder(self.cur_zorder)
            object.btn_node:setTouchEnabled(false)
            object.btn_node:setPosition(cc.p(object.pos_x, object.pos_y))
            object.btn_node:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,cc.p(self.size.width*0.5, self.size.height*0.5)), cc.CallFunc:create(function (  )
                object.btn_node:setVisible(false)
            end)))
        end
    end

    self:openAutoClostBtnTimer(status)
end

-- 设置是否可以移动角色
function HomeworldPet:setCanMoveRoleStatus( status )
    self.can_move_role = status
end


-- 3秒后自动关闭按钮
function HomeworldPet:openAutoClostBtnTimer( status )
    if status == true then
        delayRun(self.root_wnd, 3, function (  )
            self:showFuncBtnList(false)
        end)
    else
        self.root_wnd:stopAllActions()
    end
end

function HomeworldPet:setVisible( status )
    if self.root_wnd then
        self.root_wnd:setVisible(status)
    end
end

function HomeworldPet:removePetSpine(  )
	if self.pet_spine then
        self.pet_spine:clearTracks()
        self.pet_spine:removeFromParent()
        self.pet_spine = nil
    end
end

-- 获取角色所占的格子坐标(目前只占一格)
function HomeworldPet:getOccupyGridList(  )
    return {{self.cur_pet_grid_x, self.cur_pet_grid_y}}
end

function HomeworldPet:getCurGridPos(  )
    return self.cur_pet_grid_x, self.cur_pet_grid_y
end

function HomeworldPet:getUnitType(  )
    return HomeworldConst.Scene_Unit_Type.Pet
end

function HomeworldPet:movePetByPos( pos )
    local grid_x, grid_y = HomeTile.toTile(nil, pos.x, pos.y - 30)
    if self.cur_pet_grid_x ~= grid_x or self.cur_pet_grid_y ~= grid_y then
        self:adjustPosition(grid_x, grid_y)
        self:updateGridStatus(true, grid_x, grid_y)
        self.cur_pet_grid_x = grid_x
        self.cur_pet_grid_y = grid_y
        if _model:checkGridIsCanWalk(grid_x, grid_y, HOME_TILE_TYPE_LAND) then
            self.last_grid_can_use = true
        else
            self.last_grid_can_use = false
        end
    end
end

function HomeworldPet:getBottomGridPos(  )
    return self.cur_pet_grid_x, self.cur_pet_grid_y
end

-- 设置层级
function HomeworldPet:setLocalZOrder( num )
    num = num or 1
    if self.root_wnd then
        self.root_wnd:setLocalZOrder(num)
    end
    self.cur_zorder = num
end

-- 显示标识箭头
function HomeworldPet:showPetArrow( status )
    if status == true then
        if not self.arrow_icon then
            local arrow_res = self:getRandomArrowRes()
            self.arrow_icon = createSprite(arrow_res, self.size.width*0.5, self.size.height+70, self.root_wnd, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
            self.arrow_icon:setVisible(false)
        end
        if self.arrow_icon:isVisible() == false then
            local sequence = cc.Sequence:create(cc.MoveTo:create(0.7, cc.p(self.size.width*0.5, self.size.height+50)), cc.MoveTo:create(0.7, cc.p(self.size.width*0.5, self.size.height+70)))
            self.arrow_icon:runAction(cc.RepeatForever:create(sequence))
        end
        self.arrow_icon:setVisible(true)
    else
        self.arrow_icon:setVisible(false)
        doStopAllActions(self.arrow_icon)
    end
end

function HomeworldPet:getRandomArrowRes(  )
    local temp_list = {}
    for k,v in pairs(HomeworldConst.Pet_Arrow_Res) do
        if not self.cur_arrow_res or self.cur_arrow_res ~= v then
            _table_insert(temp_list, v)
        end
    end

    local index = math.random(1, #temp_list)
    local res_str = temp_list[index]

    self.cur_arrow_res = res_str
    return PathTool.getResFrame("homeworld", res_str)
end

-- 随机切换气泡资源
function HomeworldPet:updateRandomArrowRes(  )
    if not self.arrow_icon then return end
    local arrow_res = self:getRandomArrowRes()

    local act_1 = cc.FadeOut:create(0.2)
    local act_2 = cc.CallFunc:create(function (  )
        loadSpriteTexture(self.arrow_icon, arrow_res, LOADTEXT_TYPE_PLIST)
    end)
    local act_3 = cc.FadeIn:create(0.2)
    self.arrow_icon:runAction(cc.Sequence:create(act_1, act_2, act_3))
end

function HomeworldPet:__delete(  )
    GlobalTimeTicket:getInstance():remove(self.action_change_ticket)
    self.action_change_ticket = nil
    doStopAllActions(self.arrow_icon)
    doStopAllActions(self.talk_panel)
	self:removePetSpine()
    if self.root_wnd then
        self.root_wnd:removeAllChildren()
        self.root_wnd:removeFromParent()
    end
end