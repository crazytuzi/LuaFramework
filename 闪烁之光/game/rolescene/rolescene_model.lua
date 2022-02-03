-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-10-09
-- --------------------------------------------------------------------
RolesceneModel = RolesceneModel or BaseClass()

function RolesceneModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()

    self:registerEvent()
end

function RolesceneModel:config()
	self.unitRange              = 100
	self.pointRange             = 40
    self.role_list              = {}
    self.unit_list              = {}
    self.effect_list            = {}
    self.astar                  = Astar:getInstance()
    self.scene_info 			= nil
	self.path 					= nil 	-- 角色寻路路线
	self.isWalking 				= false -- 是否正在寻路
	self.curPos 				= nil   -- 当前路径节点
	self.startPoint 			= nil   -- 起始坐标点 格式{0,0} {x=0,y=0} 都可以
	self.endPoint 				= nil   -- 结束坐标点 格式{0,0} {x=0,y=0} 都可以

    self.hide_scene_role        = false -- 是否隐藏场景单位
end

function RolesceneModel:registerEvent()
	if self.move_next_event == nil then
		self.move_next_event = GlobalEvent:getInstance():Bind(SceneEvent.SCENE_WALKNEXT, function(pos)
			if self.scene then
				self.scene:walkNext(pos)
			end
		end)
	end

	if self.role_walk_end_event == nil then
		self.role_walk_end_event = GlobalEvent:getInstance():Bind(SceneEvent.SCENE_WALKEND, function(pos)
			if self.scene then
            	self.astar:reset()
			end
            if self.find_vo ~= nil then
                self:clickSceneUnit(self.find_vo)
                self.find_vo = nil
            end
		end)
	end

    if self.walk_to_target_end == nil then
        self.walk_to_target_end = GlobalEvent:getInstance():Bind(RolesceneEvent.SCENE_WALKEND, function(vo)
            if self.scene then
                self.astar:reset()
            end

            if vo == nil then return end
            if vo.type == RoleSceneVo.unittype.role then
                self:clickSceneRole(self.find_vo)
            elseif vo.type == RoleSceneVo.unittype.unit then
                self:clickSceneUnit(self.find_vo)
            end
            if self.find_vo ~= nil then
                self.find_vo = nil
            end
        end)
    end

	local function clickPlayer(vo)
        if self.scene == nil then return end
        if vo == nil then return end
        
        --宗门领地点到人显示头像
        -- if self.ctrl:getIsCrossTeamHall() then
        --     self:createSceneHead()
        --     self:handleSceneHead(true)
        --     self.sceneHead:updateSceneVo(vo)
        -- end

        self.scene:cancelWalk()
	    local findVo = {}
	    findVo.type = RoleSceneVo.unittype.role
	    findVo.srv_id = vo.srv_id
	    findVo.rid = vo.rid
	    findVo.name = vo.name
	    findVo.sceneId = self.scene_info.bid
	    findVo.pos = cc.p(vo.x, vo.y)
        self.find_vo = findVo
		self.scene:gotoTarget(findVo, true)
	end
	if self.player_click_event == nil then
		self.player_click_event = GlobalEvent:getInstance():Bind(SceneEvent.SCENE_PLAYER_CLICK, clickPlayer)
	end

	local function clickUnit( vo )
        if self.scene == nil then return end
		if vo == nil then return end
		self.scene:cancelWalk()

        local findVo = {}
        findVo.type = RoleSceneVo.unittype.unit
        findVo.battle_id = vo.battle_id
        findVo.id = vo.id
        findVo.base_id = vo.base_id
        findVo.sceneId = self.scene_info.bid
        findVo.sub_type = vo.sub_type
        findVo.pos = cc.p(vo.x, vo.y)
        self.find_vo = findVo
        self.scene:gotoTarget(findVo, true)
	end
	if self.unit_click_event == nil then
		self.unit_click_event = GlobalEvent:getInstance():Bind(SceneEvent.SCENE_UNIT_CLICK, clickUnit)
	end
end

function RolesceneModel:clearFindVo()
    self.find_vo = nil
end

function RolesceneModel:handleSceneHead(status)
	if self.sceneHead ~= nil then
		self.sceneHead:setVisible(status)
	end
end

function RolesceneModel:setVisibleHideRole(status)
    if self.scene == nil then return end
    if self.hide_container and not tolua.isnull(self.hide_container) then
        self.hide_container:setVisible(status)
    end
end

--==============================--
--desc:创建屏蔽玩家
--time:2017-10-17 04:42:15
--@return 
--==============================--
function RolesceneModel:createHideRole()
    local container = ViewManager:getInstance():getLayerByTag( ViewMgrTag.UI_TAG )
    local baseLayer = ViewManager:getInstance():getBaseLayout()
    if self.hide_container == nil then
        self.hide_container = createCSBNote(PathTool.getTargetCSB("mainui/rolescene_hide"))
		self.hide_container:setAnchorPoint(cc.p(1, 0.5))
		self.hide_container:setPosition(display.getRight(baseLayer), display.getBottom(baseLayer) + 140)
        container:addChild(self.hide_container)

        self.hide_container.backpack = self.hide_container:getChildByName("backpack")
        self.hide_container.backpack:addClickEventListener(function(sender)
            local selected = self.hide_container.check_box:isSelected()
            self.hide_container.check_box:setSelected(not selected)
            self:handleHideOtherRole(not selected)
        end)

        self.hide_container.check_box = self.hide_container:getChildByName("check_box")
        self.hide_container.check_box:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                self:handleHideOtherRole(sender:isSelected())
            end
        end)

        local check_label = self.hide_container:getChildByName("check_label")
        check_label:setString(self.ctrl:getString("rolescene_hide_label"))
    end
end

--==============================--
--desc:处理显示或者隐藏其他玩家
--time:2017-10-17 05:12:30
--@status:
--@return 
--==============================--
function RolesceneModel:handleHideOtherRole(status)
    self.hide_scene_role = status
    if self.scene ~= nil then
        if self.role_list then
            for k,v in pairs(self.role_list) do
                if v.setRoleAttribute then
                    v:setRoleAttribute("hide_self", status)
                end
            end
        end
    end
end

function RolesceneModel:createSceneHead()
	if self.sceneHead == nil then
		local container = ViewManager:getInstance():getLayerByTag( ViewMgrTag.UI_TAG )
		self.sceneHead = PlayerHead.new(PlayerHead.type.circle)
		container:addChild(self.sceneHead)
		self.sceneHead:setPosition(cc.p(SCREEN_WIDTH - 290-self.sceneHead:getContentSize().width/2, 510))
		self.sceneHead:addCallBack(function()
            if self.sceneHead.scene_vo ~= nil then
                self:handleSceneHead(false)
                FriendController:getInstance():openFriendCheckPanel(true, 1, self.sceneHead.scene_vo, "world",self.sceneHead.scene_vo.status)
            end
		end)
	end
end

function RolesceneModel:clickSceneUnit(vo)
    if vo == nil then return end
    local config = Config.UnitData.data_unit(vo.base_id)
    if config ~= nil then
        local key = getNorKey(vo.battle_id, vo.id)
        local unit = self.unit_list[key]
        if unit ~= nil then
		    GlobalEvent:getInstance():Fire(SceneEvent.SCENE_NEAR_NPC, {vo.id, vo.battle_id, vo.base_id})
        end
    end
end
function RolesceneModel:clickSceneRole(vo)
    if vo == nil then return end
    if self.ctrl:getIsInChiefWar() then 
        local rid = vo.rid or 0
        local srv_id = vo.srv_id or ""
        ChiefwarController:getInstance():sender22306(rid,srv_id)
    end
end

function RolesceneModel:__delete()
    self:clear()
    if self.scene then
        self.scene:DeleteMe()
        self.scene = nil
    end
    if self.sceneHead ~= nil then
        self.sceneHead:DeleteMe()
        self.sceneHead = nil
    end

    if self.hide_container then
        self.hide_container:removeFromParent()
        self.hide_container = nil
    end
    self.scene_data = nil
    self.scene_info = nil

    -- 移除掉npc对话的
    GlobalEvent:getInstance():Fire(NpcEvent.CloseNpcTalkViewEvent)

    GlobalEvent:getInstance():Fire(RolesceneEvent.SCENE_CHANGE)
    --移除首席
    ChiefwarController:getInstance():openChiefView(false)
    --移除钻石争霸赛
    DiamondwarController:getInstance():openDiamondWarReadyView(false)
end

--==============================--
--desc:清除场景角色,主要是切换不同场景,或者断线重连的时候,以及退出场景的时候
--time:2017-10-17 04:06:17
--@return 
--==============================--
function RolesceneModel:clearRole()
    if self.scene == nil then return end
    if self.role_list then
        for k,v in pairs(self.role_list) do
            self.scene:removeRole(v.srv_id, v.rid)
            v:DeleteMe()
        end
    end
    self.role_list = {}
end

--==============================--
--desc:清除场景特效
--time:2017-10-17 04:08:19
--@return 
--==============================--
function RolesceneModel:clearEffect()
    if self.scene == nil then return end
    if self.effect_list then
        for k,v in pairs(self.effect_list) do
            self.scene:removeEffect(v.base_id, v.x, v.y)
        end
    end
    self.effect_list = {}
end

--==============================--
--desc:清除场景上的单位
--time:2017-10-17 04:09:49
--@return 
--==============================--
function RolesceneModel:clearUnit()
    type = type or 0
    if self.scene == nil then return end
    if self.unit_list ~= nil then
        for k,v in pairs(self.unit_list) do
            self.scene:removeUnit(v.id, v.battle_id)
            v:DeleteMe()
        end
    end
    self.unit_list = {}
end

--==============================--
--desc:清除上一个场景的资源数据
--time:2017-10-09 11:13:27
--@return 
--==============================--
function RolesceneModel:clear()
    if self.scene then
        if self.role_list ~= nil then
            for k,v in pairs(self.role_list) do
                self.scene:removeRole(v.srv_id, v.rid)
                v:DeleteMe()
            end
        end

        if self.unit_list ~= nil then
            for k,v in pairs(self.unit_list) do
                self.scene:removeUnit(v.id, v.battle_id)
                v:DeleteMe()
            end
        end

        if self.effect_list ~= nil then
            for k,v in pairs(self.effect_list) do
                self.scene:removeEffect(v.base_id, v.x, v.y)
            end
        end
    end
    self.effect_list = {}
    self.role_list = {}
    self.unit_list = {}
end

--==============================--
--desc:当前地图id
--time:2017-10-09 01:53:10
--@return 
--==============================--
function RolesceneModel:getSceneId()
    if self.scene_info ~= nil then
        return self.scene_info.bid
    end
    return 0
end

--==============================--
--desc:切换场景的唯一入口
--time:2017-10-09 11:07:15
--@data:
--@return 
--==============================--
function RolesceneModel:changeScene(data)
    self:clearRole()
    if self.scene_data ~= nil and self.scene_data.bid == data.bid and self.scene ~= nil then return end
    self:clearEffect()
    self:clearUnit()
    self.scene_data = data
    self:sceneStart()
    GlobalEvent:getInstance():Fire(RolesceneEvent.SCENE_CHANGE, self.scene_data)
end

function RolesceneModel:sceneStart()
    if self.scene_data == nil then
        self.ctrl:exitRoleScene(true)
    else
	    self.scene_info = Config.Map[self.scene_data.bid]
        if self.scene_info == nil then
            print("enter role scene error by id", self.scene_data.bid)
            self.ctrl:exitRoleScene(true)
            return
        end
        TileUtil.tileWidth = self.scene_info.tile_w or TileUtil.tileWidth
        TileUtil.tileHeight = self.scene_info.tile_h or TileUtil.tileHeight	

        if self.scene == nil then
            self.scene = RoleScene.New(self.ctrl)
        end
        -- 创建地图id
        self.scene:createScene(self.scene_data.x, self.scene_data.y)
        self.map_block = Config.MapBlock.get(self.scene_data.bid) 

        self.astar:clear()
        self.astar:setBlock(self.map_block)
        self:createCliUnit()

        -- if self.ctrl:getIsCrossTeamHall()==true then
        --     self:createHideRole() 
        -- end
        
        local is_fight = BattleController:getInstance():isInFight()
        self:handleScene(not is_fight)
    end
end

function RolesceneModel:getSceneInfo()
    return self.scene_info
end

function RolesceneModel:getSceneData()
    return self.scene_data
end

--==============================--
--desc:创建场景附带npc
--time:2017-10-09 12:00:04
--@return 
--==============================--
function RolesceneModel:createCliUnit()
    if self.scene_info == nil or next(self.scene_info.unit_list) == nil then return end
    for i,v in pairs(self.scene_info.unit_list) do
        local unit = Config.UnitData.data_unit(v[1])
        if unit.cli_create == 1 then
            self:addUnit({battle_id=1, id=v[4], base_id=v[1], name=unit.name, x=v[2], y=v[3], layer =v[5], looks={}})
        end
    end

    for k,v in pairs(self.scene_info.eff_list) do
        local unit = Config.UnitData.data_unit(v[1])
        if unit.cli_create == 1 then
            self:addEffect({base_id=v[1], x=v[2], y=v[3], layer=v[4]})
        end
    end
end

--==============================--
--desc:更新单位外观
--time:2017-10-12 04:29:08
--@data:
--@return 
--==============================--
function RolesceneModel:updateRoleLooks(data)
    if self.scene == nil then return end
    local key = getNorKey(data.srv_id, data.rid)
    local vo = self.role_list[key]
    if vo == nil then return end
    vo:setLooks(data.looks, (type==0))
end

--==============================--
--desc:添加角色数据
--time:2017-10-09 12:25:29
--@data:
--@return 
--==============================--
function RolesceneModel:addRole(data)
    if not self.scene then return end
    
    local key = getNorKey(data.srv_id, data.rid)
    local vo = self.role_list[key]
    if vo ~= nil then
        vo:initAttributeData(data)
        return
    end
    vo = RoleSceneVo.New()
    vo.type = RoleSceneVo.unittype.role
	vo:initAttributeData(data)
	vo.name = transformNameByServ(data.name, data.srv_id)
    vo.body_res = vo:getBodyRes()
    if self.ctrl:getIsInChiefWar() == true then 
        local config = Config.ChiefWarData.data_chief_const["born_look"]
        if config and config.val then
            vo.body_res = config.val or ""
        end
        -- vo.body_res = "H30036"
    end
    vo.hide_self = self.hide_scene_role
    self.role_list[key] = vo
    self.scene:addRole(vo)

    -- 判断一下是不是主角吧,如果是的话,就直接设置摄像机位置
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo ~= nil then
        local role_key = getNorKey(role_vo.srv_id, role_vo.rid)
        if role_key == key then
	        self:updateCamera(cc.p(data.x, data.y), true)
        end
    end
end

--==============================--
--desc:移除角色
--time:2017-10-09 01:54:33
--@srv_id:
--@rid:
--@return 
--==============================--
function RolesceneModel:removeRole(srv_id, rid)
    local key = getNorKey(srv_id, rid)
    local vo = self.role_list[key]
    if vo == nil or self.scene == nil then return end
    self.scene:removeRole(srv_id, rid)
    self.role_list[key] = nil
end
--==============================--
--desc:瞬移角色
--time:2017-10-09 12:25:29
--@data:
--@return 
--==============================--
function RolesceneModel:updateHeroPos(data)
    if not self.scene then return end
    local key = getNorKey(data.srv_id, data.rid)
    local vo = self.role_list[key]
    if vo ~= nil then
        vo:initAttributeData({x=data.dx,y=data.dy})
    end
    self.scene:updateHeroPos(data)
end
--==============================--
--desc:创建场景特效
--time:2017-10-14 04:39:12
--@data:
--@return 
--==============================--
function RolesceneModel:addEffect(data)
    if self.scene == nil or data == nil then return end
    local config = Config.UnitData.data_unit(data.base_id)
    if config == nil then return end
    local key = getNorKey(data.base_id, data.x, data.y)
    local vo = self.effect_list[key]
    if vo == nil then
        vo = data
        self.scene:addEffect(vo)
        self.effect_list[key] = vo
    end
end

--==============================--
--desc:添加单位
--time:2017-10-09 01:50:11
--@data:
--@return 
--==============================--
function RolesceneModel:addUnit(data)
    if self.scene == nil or data == nil then return end
    local config = Config.UnitData.data_unit(data.base_id)
    if config == nil then return end

    local key = getNorKey(data.battle_id, data.id)
    local vo = self.unit_list[key]
    if vo ~= nil then
        vo:initAttributeData(data)
    else
        vo = RoleSceneVo.New()
		vo.type = RoleSceneVo.unittype.unit
        vo.scene_id = self:getSceneId()
		vo:initAttributeData(data)
        vo.sub_type = config.sub_type or RoleSceneVo.sub_unittype.npc
        vo.body_res = vo:getBodyRes()
        vo.unit_type = config.type or 0 --小怪或者boss
        self.unit_list[key] = vo
		self.scene:addUnit(vo)
    end
end

--==============================--
--desc:移除一个单位
--time:2017-10-09 01:56:55
--@battle_id:
--@id:
--@return 
--==============================--
function RolesceneModel:removeUnit(id, battle_id)
    if not self.scene then return end
	battle_id = battle_id or 1
    local key = getNorKey(battle_id, id)
    local vo = self.unit_list[key]
    if vo ~= nil and self:getSceneId() == vo.scene_id then
        self.scene:removeUnit(id, battle_id)
    end
    self.unit_list[key] = nil
end

function RolesceneModel:getRole( srv_id, rid )
    local key = getNorKey(srv_id, rid)
    return self.role_list[key]
end

function RolesceneModel:getUnit(id ,battle_id)
	battle_id = battle_id or 1
    local key = getNorKey(battle_id, id)
    return self.unit_list[key]
end

function RolesceneModel:isMainRoleVo(key)
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo ~= nil then
        if getNorKey(role_vo.srv_id, role_vo.rid) == key then
            return true
        end
    end
    return false
end

--==============================--
--desc:广播其他玩家移动
--time:2017-10-09 01:58:25
--@data:
--@return 
--==============================--
function  RolesceneModel:syncRoles(data)
    if not self.scene then return end
    local key = getNorKey(data.srv_id, data.rid)
    local vo = self.role_list[key]
    if vo == nil then return end

    -- 这里做一个判断,如果是自身,则不处理,因为自己不走移动包
    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo == nil then return end
    local self_key = getNorKey(role_vo.srv_id, role_vo.rid)
    if key == self_key then return end

	self.scene:syncRole(vo.srv_id, vo.rid, cc.p(data.dx, data.dy))
end

--==============================--
--desc:寻找移动路径
--time:2017-10-10 09:39:36
--@startPoint:
--@endPoint:
--@return 
--==============================--
function RolesceneModel:findPath(startPoint, endPoint)
	if self.map_block == nil or #self.map_block == 0 then
		print("没有地图网络数据")
		return
	end

	local s = startPoint or self.startPoint
	local e = endPoint or self.endPoint

	if self.astar:find(s, e) then
        self:setStartPoint(startPoint)
        self:setEndPoint(endPoint)
        self.path = self.astar:floyd()
		table.remove(self.path)
		self.isWalking = true
	end
	return nil
end

--==============================--
--desc:设置起点
--time:2017-10-10 09:40:25
--@pt:
--@return 
--==============================--
function RolesceneModel:setStartPoint( pt )
	self.startPoint = pt
end

--==============================--
--desc:设置终点
--time:2017-10-10 09:40:33
--@pt:
--@return 
--==============================--
function RolesceneModel:setEndPoint( pt )
	self.endPoint = pt
end

--==============================--
--desc:移动摄像头,这个是系统移动,并不是跟随主角移动
--time:2017-10-10 11:16:35
--@return 
--==============================--
function RolesceneModel:moveCamera()
    if self.scene == nil then return end

end

--==============================--
--desc:更新摄像机位置
--time:2017-10-10 11:17:52
--@target_pos:
--@is_force:
--@return 
--==============================--
function RolesceneModel:updateCamera(target_pos, is_force)
    if self.scene == nil then return end
    local scene_x, scene_y, pos = self:getCameraPos(target_pos)
	self.scene:setPos(scene_x, scene_y, pos, is_force)
end

--==============================--
--desc:获取当前摄像机的位置
--time:2017-10-10 11:20:07
--@target_pos:
--@return 
--==============================--
function RolesceneModel:getCameraPos(target_pos)
    if self.scene == nil or self.scene_info == nil then return end
    local parent = ViewManager:getInstance():getBaseLayout()
    local win_width = display.getRight(parent) - display.getLeft(parent)
    local win_height = display.getTop(parent) - display.getBottom(parent)

    local half_width = win_width * 0.5 -- MapUtil.half_w
    local half_height = win_height * 0.5 -- MapUtil.half_h

    if target_pos == nil and self.scene:getHero() then
        target_pos = self.scene:getHero():getWorldPos()
    end
    local scene_x = 0
    if target_pos.x <= half_width then
        scene_x = 0
    elseif target_pos.x >= (self.scene_info.width - half_width) then
        scene_x = win_width - self.scene_info.width
    else
        scene_x = half_width - target_pos.x
    end
    local scene_y = 0
    if target_pos.y <= half_height then
        scene_y = 0
    elseif target_pos.y >= (self.scene_info.height - half_height) then
        scene_y = win_height - self.scene_info.height
    else
        scene_y = half_height - target_pos.y
    end
    return scene_x, scene_y, target_pos
end

function RolesceneModel:getScene()
    return self.scene
end

function RolesceneModel:handleScene(status)
    if self.scene then
        self.scene:setVisible(status)
        self:setVisibleHideRole(status)
        self:handleSceneHead(status)
    end
end

