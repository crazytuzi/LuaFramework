--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-12-21 10:07:17
-- @description    : 
		-- 剧情副本章节地图
---------------------------------
BattleDramaMapWindows = BattleDramaMapWindows or BaseClass(BaseView)

local controller = BattleDramaController:getInstance()
local model = controller:getModel()
local _string_format = string.format

function BattleDramaMapWindows:__init()
	self.win_type = WinType.Big
	self.layout_name = "battledrama/battle_drama_map_windows"

	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("battledrop", "battledrop"), type = ResourcesType.plist},
	}
end

function BattleDramaMapWindows:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local main_container = self.root_wnd:getChildByName("main_container")
	self.main_container = main_container

	self.map_layout = main_container:getChildByName("map_layout")

	self.pos_label = main_container:getChildByName("pos_label")
	self.close_btn = main_container:getChildByName("close_btn")
    self.btn_world = main_container:getChildByName("btn_world")
    self.btn_rule = main_container:getChildByName("btn_rule")
    
    self.rank_btn = main_container:getChildByName("rank_btn")
    self.rank_btn:getChildByName("name"):setString(TI18N("排行榜"))

    local res = PathTool.getPlistImgForDownLoad("bigbg","battle_world_map_bg",true)
    local map_bg = createSprite(res,self.root_wnd:getContentSize().width/2, self.root_wnd:getContentSize().height/2, self.root_wnd, cc.p(0.5,0.5),LOADTEXT_TYPE,-1)
    map_bg:setScale(1.5)

	-- 适配
	local image_pos = main_container:getChildByName("image_pos")
	local image_dir = main_container:getChildByName("image_dir")
	local top_off = display.getTop(main_container)
    self.btn_world:setPositionY(top_off-150)
    self.btn_rule:setPositionY(top_off-240)
	image_dir:setPositionY(top_off-150)
	--image_pos:setPositionY(top_off-170)
    --self.pos_label:setPositionY(top_off-170)
    self.rank_btn:setPositionY(top_off-150)

    local rank_icon_vo = MainuiController:getInstance():getFucntionIconVoById(MainuiConst.icon.rank)
    if rank_icon_vo then
        self.rank_btn:setVisible(true)
    else
        self.rank_btn:setVisible(false)
    end
end

function BattleDramaMapWindows:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true, 2)
	registerButtonEventListener(self.btn_world, handler(self, self._onClickWorldBtn), true)
    registerButtonEventListener(self.rank_btn, handler(self, self._onClickRankBtn), true, 1)
    registerButtonEventListener(self.btn_rule, handler(self, self._onClickRuleBtn), true, 1)
    
	local function onTouchBegin(touch, event)
		self.map_layout:stopAllActions()
        return true
    end

    local function onTouchMoved(touch, event)
        self.last_point = touch:getDelta()
        self:moveMapLayer(self.last_point.x,self.last_point.y)
    end

	local function onTouchEnded(touch, event)
        if self.last_point then
        	local pos_x = self.map_layout:getPositionX() + self.last_point.x + 15
        	if self.last_point.x < 0 then
        		pos_x = self.map_layout:getPositionX() + self.last_point.x - 15
        	end
        	local return_pos = self:checkMapLayerPoint(pos_x)
        	self.map_layout:stopAllActions()
        	self.map_layout:runAction(cc.MoveTo:create(0.4, return_pos))
        end
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED)
    self.map_layout:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.map_layout)

    self:addGlobalEvent(Battle_dramaEvent.BattleDrama_Update_Data, function ( data )
    	if data.chapter_id ~= self.chapter_id then
            if self.root_wnd and not tolua.isnull(self.root_wnd) then
                self.drama_data = model:getDramaData()
				self.chapter_id = self.drama_data.chapter_id
				self:updateMapImage()
				self:updateMapPoint()
				self:updateBaseInfo()
            end
        else
            if self.root_wnd and not tolua.isnull(self.root_wnd) then
                self:updateMapPointStatus()
            end
        end
    end)
    self:addGlobalEvent(BattleEvent.MOVE_DRAMA_EVENT, function ( combat_type,result )
    	if combat_type == BattleConst.Fight_Type.Darma and self.drama_data and MainuiController:getInstance():checkIsInDramaUIFight() then
            self.is_move_start = true
            self:moveMapTag(true)
            controller:send13020()
        end
    end)
    self:addGlobalEvent(Battle_dramaEvent.UpdateDramaProgressDataEvent, function ( val )
    	local val_str = val/1000 .. "%"
    	self.progress_label:setString(_string_format(TI18N("已超过<div fontcolor=5df660>%s</div>的玩家进度"), val_str))
    end)
end

function BattleDramaMapWindows:moveMapLayer( x, y )
	x = self.map_layout:getPositionX() + x
    y = self.map_layout:getPositionY() + y
    local return_pos = self:checkMapLayerPoint(x,y)
    self.map_layout:setPosition(return_pos.x,return_pos.y)
end

function BattleDramaMapWindows:checkMapLayerPoint( x, y )
	local map_layout_size = self.map_layout:getContentSize()
	if x > map_layout_size.width/2 then
		x = map_layout_size.width/2
	elseif x < (SCREEN_WIDTH-map_layout_size.width/2) then
		x = SCREEN_WIDTH-map_layout_size.width/2
	end
	return cc.p(x, 640)
end

function BattleDramaMapWindows:_onClickCloseBtn(  )
	controller:openBattleDramaMapWindows(false)
end


function BattleDramaMapWindows:_onClickRuleBtn(  )
	WorldmapController:getInstance():openWorldMapTipsWindow(true,self.chapter_id,WorldmapEvent.open_type.open_type_4)
end

function BattleDramaMapWindows:_onClickRankBtn(  )
	RankController:getInstance():openRankView(true, RankConstant.RankType.drama)
end

function BattleDramaMapWindows:_onClickWorldBtn(  )
	WorldmapController:getInstance():openWorldMapMainWindow(true)
end

function BattleDramaMapWindows:openRootWnd( chapter_id )
	self.drama_data = model:getDramaData()
	if self.drama_data and next(self.drama_data) ~= nil then
		self.chapter_id = chapter_id or self.drama_data.chapter_id
		self:updateMapImage()
		self:updateMapPoint()
		self:updateBaseInfo()
		controller:send13020()
	end
end

-- 更新基础信息
function BattleDramaMapWindows:updateBaseInfo(  )
	if self.drama_data then
		local drama_config = Config.DungeonData.data_drama_dungeon_info(self.drama_data.dun_id)
		if drama_config then
			self.pos_label:setString(_string_format(TI18N("当前关卡:%s"), drama_config.name))
		end
	end
end

-- 更新地图资源
function BattleDramaMapWindows:updateMapImage(  )
	local _config = Config.DungeonData.data_drama_world_info[self.drama_data.mode]
	if _config and _config[self.chapter_id] then
		local map_id =_config[self.chapter_id].map_id
		if self.resources_load then
            self.resources_load:DeleteMe()
            self.resources_load = nil
        end

        local map_bg_res = PathTool.getBattleSceneRes(_string_format("%s/blayer/big_map", map_id), false)
        print("map_bg_res",map_bg_res)
		self.resources_load = createResourcesLoad(map_bg_res, ResourcesType.single, function ()
            if not self.map_bg then
                self.map_bg = createSprite(map_bg_res, 0, 0, self.map_layout, cc.p(0, 0), LOADTEXT_TYPE)
            else
                loadSpriteTexture(self.map_bg, map_bg_res, LOADTEXT_TYPE)
            end
            local map_bg_size = self.map_bg:getContentSize()
            self.map_layout:setContentSize(map_bg_size)
        end, self.resources_load)
	end
end

-- 更新地图节点
function BattleDramaMapWindows:updateMapPoint(  )
	if self.main_point_list and next(self.main_point_list or {}) ~= nil then
        for i, item in pairs(self.main_point_list) do
            if item then
                item:clearInfo()
                item:DeleteMe()
            end
        end
    end
    self.main_point_list = {}
    local dun_data = model:getInitDungeonList()
    if dun_data then
        local item = nil
        for i, v in ipairs(dun_data) do
            delayRun(self.main_container, 4 * i/display.DEFAULT_FPS,function()
                if not self.main_point_list[v.info_data.id] then
                    item = BattleDramaMainPointItem.new()
                    self.main_point_list[v.info_data.id] = item
                    if self.map_layout then
                        self.map_layout:addChild(item, 98)
                    end
                end
                item = self.main_point_list[v.info_data.id]
                if item then
                    v.v_data = model:getCurDunInfoByID(v.info_data.id)
                    item:setPosition(v.info_data.pos[1], v.info_data.pos[2])
                    item:setData(v)
                end
            end)
        end
    end

    if not self.cur_tag_container then
        self.cur_tag_container = ccui.Layout:create()
        self.cur_tag_container:setContentSize(cc.size(50, 50))
        self.cur_tag_container:setAnchorPoint(cc.p(0.5, 0.5))
        self.map_layout:addChild(self.cur_tag_container, 99)
        self:createRole(PlayerAction.battle_stand)
    end

    self:updateMapPointStatus()
end

function BattleDramaMapWindows:createRole( action_name )
	if not tolua.isnull(self.spine_model) then
        self.spine_model:runAction(cc.RemoveSelf:create(true))
        self.spine_model = nil
    end
    if not self.spine_model then
        self.cur_action_name = action_name
        local look_id = RoleController:getInstance():getRoleVo().look_id
        local look_config = Config.LooksData.data_data[look_id]
        local res_id = "H30009" -- 默认显示该模型
        if look_config then
            res_id = look_config.ico_id or res_id
        end
        self.spine_model = createSpineByName(res_id, action_name)
        self.spine_model:setPosition(self.cur_tag_container:getContentSize().width / 2, -15)
        self.spine_model:setScaleX(0.7 * self:getDir())
        self.spine_model:setScaleY(0.7)
        self.cur_tag_container:addChild(self.spine_model)
        self.spine_model:setAnimation(0, action_name, true)
        self.spine_model:update(0)
        local height = self.spine_model:getBoundingBox().height or 85
        if not self.cur_effect then
            self.cur_effect = createEffectSpine(Config.EffectData.data_effect_info[105], cc.p(25, 130), cc.p(0.5, 0.5), true, PlayerAction.action, nil, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
            self.cur_tag_container:addChild(self.cur_effect)
        end
        if self.cur_effect then
            self.cur_effect:setPosition(25,height)
        end

        if not self.progress_bg then
        	self.progress_bg = createSprite(PathTool.getResFrame("common", "common_90056"),self.cur_tag_container:getContentSize().width / 2, -35, self.cur_tag_container, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST)
        	self.progress_bg:setScaleY(0.5)
        end
        if not self.progress_label then
        	self.progress_label = createRichLabel(16, 1, cc.p(0.5, 0.5), cc.p(self.cur_tag_container:getContentSize().width / 2, -35))
	    	self.cur_tag_container:addChild(self.progress_label)
            self.progress_label:setString(TI18N("已超过<div fontcolor=5df660>?</div>的玩家进度"))
        end
    end
end

function BattleDramaMapWindows:getDir()
    local scale = 1
    local item = self.main_point_list[self.drama_data.dun_id]
    if item then
        local max_item = self.main_point_list[self.drama_data.max_dun_id]
        local cur_x = item:getPositionX()
        local max_x = 0
        if max_item then
            max_x = max_item:getPositionX()
        end
        if cur_x > max_x then
            scale = 1
        else
            scale = -1
        end
    end
    return scale
end

function BattleDramaMapWindows:updateMapPointStatus()
	self.drama_data = model:getDramaData()
    if self.drama_data then
        local v_data = model:getCurDunInfoByID(self.drama_data.dun_id)
        local config = Config.DungeonData.data_drama_dungeon_info(self.drama_data.dun_id)
        if config then
            if self.main_point_list and self.main_point_list[self.drama_data.dun_id] then
                local item = self.main_point_list[self.drama_data.dun_id]
                local is_big = config.is_big
                item:updateStatus(v_data.status, is_big)
            end

            if not self.is_move_start then
                self:moveMapTag()
                self.is_move_start = true
            end
        end
    end
end

-- 移动角色形象
function BattleDramaMapWindows:moveMapTag( is_start )
	if self.drama_data then
        local info_config = Config.DungeonData.data_drama_dungeon_info(self.drama_data.dun_id)
        if info_config then
            local cur_main_point = info_config.pos
            if cur_main_point then
                if not is_start then
                    self.cur_tag_container:setPosition(cur_main_point[1], cur_main_point[2] + BattleDramaMainPointItem.HEIGHT / 2 + 10)
                else
                    self.cur_tag_container:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.Spawn:create(cc.CallFunc:create(function()
                        self:createRole(PlayerAction.run)
                    end),cc.MoveTo:create(0.5, cc.p(cur_main_point[1], cur_main_point[2] + BattleDramaMainPointItem.HEIGHT / 2 + 10))),cc.CallFunc:create(function ()
                        self:createRole(PlayerAction.battle_stand)
                    end)))
                end
            end
        end
    end
end

function BattleDramaMapWindows:close_callback(  )
	if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end

    if self.main_point_list then
        for k, v in pairs(self.main_point_list) do
            if v then
                v:DeleteMe() 
            end
        end
    end

    if not tolua.isnull(self.spine_model) then
        self.spine_model:runAction(cc.RemoveSelf:create(true))
        self.spine_model = nil
    end

    if self.cur_effect then
        self.cur_effect:clearTracks()
        self.cur_effect:removeFromParent()
        self.cur_effect = nil
    end

    if self.background then
        self.background:removeAllChildren()
        self.background:stopAllActions()
    end

	controller:openBattleDramaMapWindows(false)
end