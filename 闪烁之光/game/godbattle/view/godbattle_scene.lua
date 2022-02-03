-- --------------------------------------------------------------------
-- 众神战场
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
GodBattleScene = GodBattleScene or BaseClass(BaseView)

GodBattleScene.layer = {
    blayer = "blayer",
    slayer = "slayer"
}

local role_vo = RoleController:getInstance():getRoleVo() 
local controller = GodbattleController:getInstance()
local model = controller:getModel()

function GodBattleScene:__init(ctrl)
	self.is_full_screen = true
	self.is_godbattle_scene = true
	self.view_tag = ViewMgrTag.EFFECT_TAG 
	self.win_type = WinType.Full
    self.index = 2 
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("godbattle", "godbattle"), type = ResourcesType.plist}
    }
    self:initConfig()
end

function GodBattleScene:initConfig()
    self.map_size = cc.size(2560, 1280)
    self.blayer_size = cc.size(2560, 1280)
    self.slayer_size = cc.size(2560, 1280)
    self.step = 0
    self.add_map_interval = 2
    self.add_rolt_interval = 9
    self.add_guard_interval = 11

    self.role_data_list = {}
    self.role_list = {}

    self.guard_data_list = {}           -- 待创建的守卫信息
    self.guard_list = {}                -- 已创建的守卫

    self.blayer_sp = -0.2               --背景层移动的速率
end

function GodBattleScene:createRootWnd()
    local win_width = SCREEN_WIDTH
    local win_height = display.height
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))

    self.map_layer = ccui.Layout:create()
    self.map_layer:setAnchorPoint(cc.p(0.5, 0.5))
    self.map_layer:setContentSize(cc.size(win_width, win_height))
    self.map_layer:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    self.root_wnd:addChild(self.map_layer)

    -- 场景层,厨房地图和马赛克图
    self.main_scene_layer = ccui.Layout:create()
    self.main_scene_layer:setAnchorPoint(cc.p(0, 0))
    self.main_scene_layer:setContentSize(self.map_size)
    self.main_scene_layer:setPosition(0,0)
    self.map_layer:addChild(self.main_scene_layer)

    self.map_smalllayer = ccui.Widget:create()
    self.map_smalllayer:setAnchorPoint(cc.p(0, 0))
	self.main_scene_layer:addChild(self.map_smalllayer, 1) 

    self.map_blayer = ccui.Widget:create()
    self.map_blayer:setAnchorPoint(cc.p(0, 1))
    self.map_blayer:setPositionY(self.map_size.height)
    self.map_blayer:setContentSize(self.map_size)
	self.main_scene_layer:addChild(self.map_blayer, 2) 
    
    self.map_slayer = ccui.Widget:create()
    self.map_slayer:setAnchorPoint(cc.p(0, 0))
    self.map_slayer:setContentSize(self.map_size)
	self.main_scene_layer:addChild(self.map_slayer, 3)
    
    self.role_layer = ccui.Widget:create()
    self.role_layer:setAnchorPoint(cc.p(0, 0))
    self.role_layer:setContentSize(self.map_size)
    self.main_scene_layer:addChild(self.role_layer, 5)
    
    self.ui_layer = ccui.Widget:create()
    self.ui_layer:setAnchorPoint(cc.p(0.5, 0.5))
    self.ui_layer:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.ui_layer:setPosition(SCREEN_WIDTH*0.5, SCREEN_HEIGHT*0.5)
    self.root_wnd:addChild(self.ui_layer, 1)
end

function GodBattleScene:register_event()
    if self.add_role_event == nil then
        self.add_role_event = GlobalEvent:getInstance():Bind(GodbattleEvent.AddRoleDataEvent, function(type, data_list)
            self:updateRoleListData(type, data_list)
        end)
    end

    if self.move_role_event == nil then
        self.move_role_event = GlobalEvent:getInstance():Bind(GodbattleEvent.MoveRoleEvent, function(role_list)
            self:updateRoleMoveData(role_list)
        end)
    end

    if self.add_guard_event == nil then
        self.add_guard_event = GlobalEvent:getInstance():Bind(GodbattleEvent.AddGuardDataEvent, function(type, data_list)
            self:updateGuardListData(type, data_list)
        end)
    end
end

function GodBattleScene:openRootWnd()    
    RenderMgr:getInstance():add(self) 

    -- 创建马赛克地图
    self:renderSmallPic()

    -- 解析地图分块数据
    self:analysisMapTile()

    if self.main_ui == nil then
        self.main_ui = GodBattleMainUI.new(self.ui_layer)
    end

    if not tolua.isnull(self.main_ui) then
        self.main_ui:open()
        self.main_ui:setVisibleStatus(true)
    end

    -- 请求状态数据
    RenderMgr:getInstance():doNextFrame(function() 
        controller:requestGodBattleRoleList()
    end)
end

function GodBattleScene:update()
	self.step = self.step + 1
    if self.step % self.add_map_interval == 0 then
        self:quequeAddMapTile()
    end

    self:addMapTile()

    if self.step % self.add_rolt_interval == 0 then
        self:queueAddRole()
    end

    if self.step % self.add_guard_interval == 0 then
        self:queueAddGuard()
    end

    for k, role in pairs(self.role_list) do
        if role and role.vo then
            role:update()
            if role_vo ~= nil then
                if getNorKey(role.vo.rid, role.vo.srv_id) == getNorKey(role_vo.rid, role_vo.srv_id) then -- 找出自己,并且摄像头跟随
				    local pos = role:getWorldPos()
				    self:updateCamera(pos)
                end
            end
        end
    end
end

function GodBattleScene:close_callback() 
	RenderMgr:getInstance():remove(self)
    controller:openGodBattleMainWindow(false)

    for k,v in pairs(self.map_pic_cache) do
        v:DeleteMe()
    end
    self.map_pic_cache = nil

    if self.add_role_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.add_role_event)
        self.add_role_event = nil
    end

    if self.move_role_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.move_role_event)
        self.move_role_event = nil
    end

    if self.add_guard_event ~= nil then
        GlobalEvent:getInstance():UnBind(self.add_guard_event)
        self.add_guard_event = nil
    end

    if self.main_ui then
        self.main_ui:DeleteMe()
    end
    self.main_ui = nil

    -- 移除角色
    for k,v in pairs(self.role_list) do
        v:DeleteMe()
    end
    self.role_list = nil

    -- 移除守卫
    for k,v in pairs(self.guard_list) do
        v:DeleteMe()
    end
    self.guard_list = nil

    -- 清空数据
    controller:clearGodBattleData()
end

-----------------------------------------创建地表地图部分,包含了马赛克-----------------------
--==============================--
--desc:创建马赛克图片
--time:2017-09-11 04:05:57
--@return 
--==============================--
function GodBattleScene:renderSmallPic()
	local res_jpg = "resource/godbattle/preview.jpg"
	local res 
    if PathTool.isFileExist(res_jpg) then
        res = res_jpg
    end
    if res then
    	local smallPic = display.newSprite(res)
    	self.map_smalllayer:addChild(smallPic)
    	smallPic:setAnchorPoint(cc.p(0.5,0.5))
        smallPic:setPosition(self.map_size.width/2, self.map_size.height/2)
    	local size = smallPic:getBoundingBox()
    	smallPic:setScale(self.map_size.width/size.width, self.map_size.height/size.height)
    end
end

--==============================--
--desc:解析一下地图数据
--time:2017-09-11 04:35:05
--@return 
--==============================--
function GodBattleScene:analysisMapTile()
    self.map_pic_cache = {}
    self.map_ren_cache = {}
    self:renderLayer(self.layer.slayer, self.slayer_size.width, self.slayer_size.height)
    -- self:renderLayer(self.layer.blayer, self.blayer_size.width, self.blayer_size.height)
end

function GodBattleScene:renderLayer(type, w, h)
    local x, y = 0, 0
    while x < w do
        y = 0
        while y < h do
			self:addFloorSprite(type, w, h, x, y)
            y = y + MapUtil.c_h
        end
		x = x + MapUtil.c_w
    end
end

function GodBattleScene:addFloorSprite(type, w, h, x, y)
    local ap = cc.p(0, 0)
    if type == self.layer.blayer then
        ap = cc.p(0, 1)
    end
	local picXNum, picYNum = self:getScenePicByPos(w, h, x, y)

    local res, res_type = self:getPicRes(type, picXNum, picYNum)
    table.insert(self.map_ren_cache, {type, res, res_type, x, y, ap, 0})
end

function GodBattleScene:getScenePicByPos(w, h, x, y)
	local modX, yuX = math.modf(x/w)
	local modY, yuY = math.modf(y/h)
	local picOverX = math.ceil(yuX*w) -- 计算出超过的像素
	local picOverY = math.ceil(yuY*h) -- 计算出超过的像素
	local picXNum = math.floor(picOverX/MapUtil.c_w)  -- 计算出图片序号
	local picYNum = math.floor(picOverY/MapUtil.c_h)  -- 计算出图片序号
	return picXNum, picYNum
end

function GodBattleScene:getPicRes(type, n, m)
    local res, res_type
	res_type = "jpg"
    res = string.format("scene/godbattle/%s/%d_%d.jpg", type, n, m)
	if not PathTool.isFileExist(res) then
		res_type = "png"
        res = string.format("scene/godbattle/%s/%d_%d.png", type, n, m)
	end
    return res, res_type
end

--==============================--
--desc:分帧创建地图快
--time:2018-09-20 10:06:31
--@return 
--==============================--
function GodBattleScene:quequeAddMapTile()
    if self.map_ren_cache == nil or next(self.map_ren_cache) == nil then return end
    local map_info = table.remove(self.map_ren_cache, 1)
    local key = getNorKey(map_info[1],map_info[4],map_info[5])
    if self.map_pic_cache[key] ~= nil then return end
    if map_info ~= nil and #map_info == 7 then
        local parent = self["map_"..map_info[1]]
        
        local type = map_info[1]        -- 前景还是背景
        local path = map_info[2]        -- 资源路径
        local _x = map_info[4]
        local _y = map_info[5]
        local is_top = false
        if type == self.layer.blayer then
            _y = self.blayer_size.height - y
            is_top = true
        end
        self.map_pic_cache[key] = MapTile.New(cc.p(_x, _y), path, type, false, false, parent, is_top) 
        self.map_pic_cache[key]:retain()
    end
end

--==============================--
--desc:把队列里面已经创建完的显示出来
--time:2018-09-20 09:54:21
--@return 
--==============================--
function GodBattleScene:addMapTile()
	for i, tile in pairs(self.map_pic_cache) do
		if not tile:isAdded() then
			tile:addChildOnParent()
		end
	end
end


----------------------------------创建单位部分
--==============================--
--desc:队列创建单位
--time:2017-09-11 07:31:52
--@return 
--==============================--
function GodBattleScene:queueAddRole()
    if self.role_data_list == nil or next(self.role_data_list) == nil then return end
    local data = table.remove( self.role_data_list, 1 )
    if data ~= nil then
        self:addRole(data)
    end
end

--==============================--
--desc:添加具体单位
--time:2017-09-11 07:32:00
--@data:
--@return 
--==============================--
function GodBattleScene:addRole(vo, is_self)
    if vo == nil then return end
    local key = getNorKey(vo.rid, vo.srv_id)
    if self.role_list[key] ~= nil then return end
    local pos = Config.ZsWarData.data_pos[vo.pos_x or 1][vo.pos_y or 1]
    if pos ~= nil then
        vo.x = pos[1]
        vo.y = pos[2]
    end
    if vo.camp == GodBattleConstants.camp.god then
        vo.name_bg = PathTool.getResFrame("godbattle", "godbattle_13")
    else
        vo.name_bg = PathTool.getResFrame("godbattle", "godbattle_12")
    end
    is_self = is_self or false
    local npc = Player.New(is_self)
	npc:setParentWnd(self.role_layer)
	npc:setVo(vo)
	npc:initSpine()
    npc:playActionOnce(PlayerAction.battle_stand)
    self.role_list[key] = npc
    
    -- 如果是自己的话,创建设置位置
    if is_self == true then
        local world_pos = npc:getWorldPos()
        self:updateCamera(world_pos, true)
        if self.map_ren_cache == nil or next(self.map_ren_cache) == nil then return end
        for i, v in pairs(self.map_ren_cache) do
            v[7] = math.abs(v[4] - world_pos.x) + math.abs(v[5] - world_pos.y)
        end

        table.sort(self.map_ren_cache,function(a,b)
            return a[7] < b[7]
        end)
    end
end

--==============================--
--desc:定时创建一个守卫
--time:2017-09-13 10:24:34
--@return 
--==============================--
function GodBattleScene:queueAddGuard()
    if self.guard_data_list == nil or next(self.guard_data_list) == nil then return end
    local data = table.remove( self.guard_data_list, 1 )
    if data ~= nil then
        self:addGuard(data)
    end
end

--==============================--
--desc:创建一个守卫
--time:2017-09-13 10:21:40
--@vo:
--@return 
--==============================--
function GodBattleScene:addGuard(vo)
    if vo == nil then return end
    if self.guard_list[vo.id] ~= nil then return end
    local pos = Config.ZsWarData.data_pos[vo.pos_x or 1][vo.pos_y or 1]
    if pos ~= nil then
        vo.x = pos[1]
        vo.y = pos[2]
    end
    local npc = Npc.New()
    npc:setModelScale(1.5)
	npc:setParentWnd(self.role_layer)
	npc:setVo(vo)
	npc:initSpine()
    npc:playActionOnce(PlayerAction.battle_stand)
    self.guard_list[vo.id] = npc
end

--==============================--
--desc:移除一个单位
--time:2017-09-11 07:34:41
--@data:
--@return 
--==============================--
function GodBattleScene:removeRole(rid, srv_id)
    if self.role_list[getNorKey(rid, srv_id)] ~= nil then
        self.role_list[getNorKey(rid, srv_id)]:DeleteMe()
    end
    self.role_list[getNorKey(rid, srv_id)] = nil

    for k,v in ipairs(self.role_data_list) do
        if getNorKey(v.rid, v.srv_id) == getNorKey(rid, srv_id) then
            table.remove( self.role_data_list, k )
        end
    end
end

--==============================--
--desc:移动摄像头,跟随主角的,可能会是跳转
--time:2017-09-11 04:14:00
--@pos:
--@is_force:
--@return 
--==============================--
function GodBattleScene:updateCamera(pos, is_force)
    local scene_x, scene_y = self:getCameraPos(pos)
    if self.scene_x == scene_x then return end
    self.scene_x = scene_x
    self.main_scene_layer:setPositionX(self.scene_x)
    self.map_blayer:setPositionX(self.scene_x * self.blayer_sp)
end

--==============================--
--desc:纠正摄像机的X坐标位置,保证不会左右出去
--time:2017-09-12 10:23:55
--@target_pos:
--@return 
--==============================--
function GodBattleScene:getCameraPos(target_pos)
    if target_pos == nil then return end
    local scene_x = 0
    local scene_y = 0

    local parent = ViewManager:getInstance():getBaseLayout()
    local win_width = display.getRight(parent) - display.getLeft(parent)
    local win_height = display.getTop(parent) - display.getBottom(parent)

    local half_width = win_width * 0.5
    local half_height = win_height * 0.5
    
	if target_pos.x <= half_width then
	    scene_x = 0
	elseif target_pos.x >= (self.map_size.width - half_width) then
	    scene_x = win_width - self.map_size.width
	else
	    scene_x = half_width - target_pos.x
	end

    return scene_x, scene_y
end

--==============================--
--desc:更新或者删除守卫信息
--time:2017-09-13 10:15:12
--@type:
--@guard_list:
--@return 
--==============================--
function GodBattleScene:updateGuardListData(type, guard_list)
    if guard_list == nil or next(guard_list) == nil then return end
    local guard = nil
    if type == GodBattleConstants.update_type.update then           -- 移除一个对象
        for i,v in ipairs(guard_list) do
            guard = self.guard_list[v.id]
            if guard ~= nil then
                if guard.DeleteMe then
                    guard:DeleteMe()
                end
                self.guard_list[v.id] = nil
            else
                for index, data in ipairs(self.guard_data_list) do
                    if data.id == v.id then
                        table.remove( self.guard_data_list, index )
                        break
                    end
                end
            end
        end
    else
        if type == 0 then  
            for i,v in ipairs(guard_list) do
                table.insert( self.guard_data_list, v )
            end
        end
    end
end

--==============================--
--desc:处理数据
--time:2017-09-12 09:09:33
--@return 
--==============================--
function GodBattleScene:updateRoleListData(type, role_list)
    if role_list == nil or next(role_list) == nil then return end
    local role = nil
    if type == GodBattleConstants.update_type.update then
        for i,v in ipairs(role_list) do
            role = self.role_list[getNorKey(v.rid, v.srv_id)]
            if v.status == GodBattleConstants.role_status.off_line then -- 离线
                if role ~= nil then
                    if role.DeleteMe then
                        role:DeleteMe()
                    end
                    self.role_list[getNorKey(v.rid, v.srv_id)] = nil
                end
            else -- 正常状态,这个时候可能是从离线变成正常,需要创建出这个对象
                if role == nil then
                    table.insert( self.role_data_list, v )
                else
                    role:stopMove()
                    if Config.ZsWarData.data_pos[role.vo.pos_x] then
                        if Config.ZsWarData.data_pos[role.vo.pos_x][role.vo.pos_y] ~= nil then
                            local pos = Config.ZsWarData.data_pos[role.vo.pos_x][role.vo.pos_y] 
                            if pos ~= nil then
                                local end_pos = cc.p(pos[1] or role.vo.x, pos[2] or role.vo.y )
                                if role.vo.x ~= end_pos.x or role.vo.y ~= end_pos.y then
                                    role:setWorldPos(end_pos)
                                    if getNorKey(v.rid, v.srv_id) == getNorKey(role_vo.rid, role_vo.srv_id) then
                                        self:updateCamera(end_pos, true)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif type == GodBattleConstants.update_type.do_nil then

    else
        for i,v in ipairs(role_list) do
            local key = getNorKey(v.rid, v.srv_id)
            local role = self.role_list[key]
            if role == nil then
                if role_vo ~= nil and getNorKey(role_vo.rid, role_vo.srv_id) == getNorKey(v.rid, v.srv_id) then
                    self:addRole(v, true)
                else
                    -- 角色离线的时候就不要创建模型了
                    if v.status ~= GodBattleConstants.role_status.off_line then
                        table.insert( self.role_data_list, v )
                    end
                end
            else
                if type == GodBattleConstants.update_type.total then    -- 这个时候可能是断线重连的,要重置一下坐标位置
                    self:updateRolePosData(role, v.pos_x, v.pos_y)
                end
            end
        end
    end
end

--==============================--
--desc:处理移动的数据
--time:2017-09-12 09:22:11
--@role_list:
--@return 
--==============================--
function GodBattleScene:updateRoleMoveData(role_list)
    if role_list == nil or next(role_list) == nil then return end
    local role
    for i,v in ipairs(role_list) do
        role = self.role_list[getNorKey(v.rid, v.srv_id)]
        if role ~= nil and role.vo then
            if Config.ZsWarData.data_pos[role.vo.pos_x] then
                if Config.ZsWarData.data_pos[role.vo.pos_x][role.vo.pos_y] ~= nil then
                    local pos = Config.ZsWarData.data_pos[role.vo.pos_x][role.vo.pos_y] 
                    if pos ~= nil then
                        local end_pos = cc.p(pos[1] or role.vo.x , pos[2] or role.vo.y )
                        role:doMove(nil, end_pos)
                    end
                end
            end
        end
    end
end

function GodBattleScene:updateRolePosData(role, pos_x, pos_y)
    if role == nil or role.vo == nil or pos_x == nil or pos_y == nil then return end
    if Config.ZsWarData.data_pos[pos_x] then
        if Config.ZsWarData.data_pos[pos_x][pos_y] ~= nil then
            local pos = Config.ZsWarData.data_pos[pos_x][pos_y] 
            if pos ~= nil then
                role:setWorldPos(cc.p(pos[1] or role.vo.x, pos[2] or role.vo.y))
            end
        end
    end
end
