-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      世界地图主界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
WorldMapMainWindow = WorldMapMainWindow or BaseClass(BaseView)

function WorldMapMainWindow:__init(config)
    self.win_type = WinType.Full
    self.is_use_csb = false
    self.config = config
    self.size = cc.size(self.config.width, self.config.height)

    self.land_list = {}

    self.map_res = PathTool.getPlistImgForDownLoad("worldmap", "blayer", true)

    self.res_list = {
        {path = self.map_res, type = ResourcesType.single},
        {path = PathTool.getPlistImgForDownLoad("worldmap", "worldmap"), type = ResourcesType.plist},
    }
end

function WorldMapMainWindow:createRootWnd()
    local scale = display.getMaxScale()
    self.root_wnd = ccui.Layout:create()
    self.root_wnd:setContentSize(cc.size(SCREEN_WIDTH, display.height))
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5)
    self.difference_width = (SCREEN_WIDTH * scale -(display.getRight(self.root) - display.getLeft(self.root))) * 0.5 / scale 

    self.map_wnd = ccui.Layout:create()
    self.map_wnd:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    self.map_wnd:setScale(scale)
    self.map_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.map_wnd:setPosition(SCREEN_WIDTH * 0.5, display.height * 0.5)
    self.root_wnd:addChild(self.map_wnd)

    self.map_layer = createSprite(self.map_res, 0, 0, self.map_wnd, cc.p(0, 0), LOADTEXT_TYPE)

    self.top_info_container = ccui.Layout:create()
    self.top_info_container:setContentSize(SCREEN_WIDTH, 255)
    self.top_info_container:setAnchorPoint(cc.p(0, 1))
    self.top_info_container:setScale(display.getScale())
    self.top_info_container:setPosition(display.getLeft(self.root_wnd), display.getTop(self.root_wnd))
    if not tolua.isnull(self.top_info_container) then
        self.root_wnd:addChild(self.top_info_container)
    end
    local res = PathTool.getResFrame("worldmap", "txt_cn_worldmap_1009")
    self.return_btn = createImage(self.top_info_container, res,1110,155, cc.p(0.5, 0.5), true, 10)
    local offset_y = display.getRight(self.top_info_container) - (self.return_btn:getContentSize().width) / 2
    self.return_btn:setPosition(offset_y,self.return_btn:getContentSize().height/2)
    self.return_btn:setTouchEnabled(true)
end

function WorldMapMainWindow:open_callback()
end

function WorldMapMainWindow:register_event()
    self.return_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            WorldmapController:getInstance():openWorldMapMainWindow(false,self.data)
        end
    end)

    local function onTouchBegin(touch, event)
        self.last_point = nil
        doStopAllActions(self.map_layer) 
        return true
    end

    local function onTouchMoved(touch, event)
        self.last_point = touch:getDelta()
        self:moveMainScene(self.last_point.x)
    end

    local function onTouchEnded(touch, event)
        if self.last_point == nil then return end
        local interval_x = self.last_point.x * 3
        local temp_x = self.map_layer:getPositionX() + interval_x
        local target_x = self:scaleCheckPoint(temp_x)
        local root_move_to = cc.MoveTo:create(1, cc.p(target_x, 0))
        local call_fun = cc.CallFunc:create(function()
        end)
        local ease_out = cc.EaseSineOut:create(root_move_to)
        self.map_layer:runAction(cc.Sequence:create(ease_out, call_fun))
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    self.map_wnd:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.map_wnd)
end

function WorldMapMainWindow:moveMainScene(x)
    x = self.map_layer:getPositionX() + x
    local _x = self:scaleCheckPoint(x)
    self:updateMainScene(_x)
end

function WorldMapMainWindow:scaleCheckPoint(_x)
    if _x > self.difference_width then
        _x = self.difference_width
    elseif _x < SCREEN_WIDTH - self.size.width - self.difference_width then
        _x = SCREEN_WIDTH - self.size.width - self.difference_width
    end
    return _x
end

function WorldMapMainWindow:updateMainScene(x, y)
    y = y or 0
    self.map_layer:setPosition(x, y)
end

--==============================--
--desc:打开窗体，默认选中当前最大的大陆板块
--time:2018-06-05 08:08:22
--@return 
--==============================--
function WorldMapMainWindow:openRootWnd(data)
    self.data = data
    if self.data then --说明是章节解锁
        WorldmapController:getInstance():addLockContainer(true)
        BattleController:getInstance():setUnlockChapterStatus(true)
    end
    local dungeon_data = BattleDramaController:getInstance():getModel():getDramaData()
    if dungeon_data ~= nil then
        local dun_id = dungeon_data.dun_id
        if self.data then
            dun_id = self.data.dun_id
        end
        local dungeon_config = Config.DungeonData.data_drama_dungeon_info(dun_id) -- max_dun_id 
        if dungeon_config ~= nil then
            self.dungeon_config = dungeon_config
            self:createWorldLand()
            self:updateScenePos()
        end
    end

    delayRun(self.map_wnd, 0.2, function() 
        self.spine = createEffectSpine(PathTool.getEffectRes(199), cc.p(0,0) , cc.p(0,0),true,PlayerAction.action,nil,cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
		self.map_layer:addChild(self.spine, 10)
    end) 
end

--[[
    @desc:创建板块信息，
    author:{author}
    time:2018-05-29 15:18:30
    return
]]
function WorldMapMainWindow:createWorldLand()
    if self.config ~= nil and self.config.building_list ~= nil then
        local function click_callback(item)
            self:selectedMainLandItem(item)
        end
        local max_chapter_id = BattleDramaController:getInstance():getModel():getCurMaxChapterId(BattleDramaController:getInstance():getModel():getDramaData().mode)
        local count = 0
        for i,v in ipairs(self.config.building_list) do
            delayRun(self.root_wnd, 1*i/display.DEFAULT_FPS, function() 
                if self.land_list[v.bid] == nil then
                    count = count + 1
                    self.land_list[v.bid] = WorldMapLand.new(v, max_chapter_id, click_callback,self.data)
                    self.land_list[v.bid]:addToParent(self.map_layer)
                    self.land_list[v.bid].info_data  = v
                    if v.bid == self.dungeon_config.land_id then
                        self:selectedMainLandItem(self.land_list[v.bid])
                        -- self:updateScenePos()
                    end
                end
            end)
        end
    end
end

--==============================--
--desc:移到当前的位置,这个地方先不要这么高吧 因为有跳变
--time:2018-11-19 09:48:54
--@return 
--==============================--
function WorldMapMainWindow:updateScenePos()
    local last_id 
    if BattleDramaController:getInstance():getModel():getDramaData() then
        last_id = BattleDramaController:getInstance():getModel():getDramaData().max_dun_id
    end
    if self.data then
        last_id = self.data.dun_id 
    end
    if last_id then
        if Config.DungeonData.data_drama_dungeon_info(last_id) then
            local next_id = Config.DungeonData.data_drama_dungeon_info(last_id).next_id
            if next_id == 0 then
                next_id = last_id
            end
            if Config.DungeonData.data_drama_dungeon_info(next_id) then
                self.target_config = Config.DungeonData.data_drama_dungeon_info(next_id)
            end
            local scene_config = nil
            if self.target_config ~= nil then
                for i, v in pairs(self.land_list) do
                    if v.info_data.bid == self.target_config.land_id then
                        scene_config = v.info_data
                        break
                    end
                end
            end
            self.init_x = 0
            self.init_y = (SCREEN_HEIGHT - self.size.height) * 0.5
            if scene_config then
                if scene_config == nil then
                    self.init_x = (SCREEN_WIDTH - self.size.width) * 0.5
                else
                    local target_x
                    if scene_config.x < SCREEN_WIDTH / 2 then
                        target_x = 0
                    elseif scene_config.x > self.size.width - SCREEN_WIDTH / 2 then
                        target_x = SCREEN_WIDTH - self.size.width
                    else
                        target_x = SCREEN_WIDTH / 2 - scene_config.x
                    end
                    self.init_x = target_x
                end
            end
            self:updateMainScene(self.init_x, self.init_y)
        end
    end
end

function WorldMapMainWindow:selectedMainLandItem(item)
    if tolua.isnull(item) then return end
    if self.cur_main_land ~= nil and self.cur_main_land == item then return end
    if self.cur_main_land ~= nil then
        self.cur_main_land:setSelectedLand(false)
        self.cur_main_land = nil
    end
    self.cur_main_land = item
    self.cur_main_land:setSelectedLand(true) 
end

function WorldMapMainWindow:close_callback()
    doStopAllActions(self.map_layer) 
    doStopAllActions(self.map_wnd)
	if self.spine then
		self.spine:setVisible(false)
		self.spine:clearTracks()
		self.spine:runAction(cc.RemoveSelf:create(true))
        self.spine = nil
	end
    WorldmapController:getInstance():addLockContainer(false)
    BattleController:getInstance():setUnlockChapterStatus(false)
    for k,v in pairs(self.land_list) do
        v:DeleteMe()
    end
  
    self.land_list = nil
    WorldmapController:getInstance():openWorldMapMainWindow(false,self.data)
end
