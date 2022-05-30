-- --------------------------------------------------------------------
-- 世界地图介绍界面
-- 
-- @author: xhj(必填, 创建模块的人员)
-- @editor: xhj(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2020-4-16
-- --------------------------------------------------------------------
local _controller = WorldmapController:getInstance()
local _model = _controller:getModel()

WorldMapTipsWindow =  WorldMapTipsWindow or BaseClass(BaseView)

function WorldMapTipsWindow:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "worldmap/worldmap_tips_view"
    self.cache_list = {}
    self.open_type = WorldmapEvent.open_type.open_type_3
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("worldmap","tips_bg"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("worldmap","worldmap"), type = ResourcesType.plist },
	}
    
end

function WorldMapTipsWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    
    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)
    self.tips_img = self.container:getChildByName("tips_img")
    --self.tips_lab_bg = self.container:getChildByName("tips_lab_bg")
    self.tips_lab = self.container:getChildByName("tips_lab")
    
    self.go_btn = self.container:getChildByName("go_btn")
    self.go_btn:getChildByName("label"):setString(TI18N("前 往"))
    
    
    self.scroll_view = self.container:getChildByName("scroll_view")
    self.scroll_view:setScrollBarEnabled(false)
    self.scroll_width = self.scroll_view:getContentSize().width
    self.scroll_height = self.scroll_view:getContentSize().height
    self.win_title = self.container:getChildByName("win_title")
end

function WorldMapTipsWindow:register_event()
    registerButtonEventListener(self.background, function()
		_controller:openWorldMapTipsWindow(false)
    end ,false, 2)

    registerButtonEventListener(self.go_btn, function()
        BattleDramaController:getInstance():openBattleDramaMapWindows(false)
        WorldmapController:getInstance():openWorldMapMainWindow(false)
		_controller:openWorldMapTipsWindow(false)
    end ,false, 2)
end

function WorldMapTipsWindow:openRootWnd(id,open_type)
    if not id or not open_type then return end
    local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    if not drama_data or not drama_data.mode then return end
    self.open_type = open_type
    
    local _config = Config.DungeonData.data_drama_world_info[drama_data.mode]
    if _config and _config[id] then
        local conf = _config[id]
        self.win_title:setString(conf.name)
        self.max_height = 0
        self:setDataList(conf.map_tips)

        local res = PathTool.getTargetRes("worldmap/tips_img", conf.tips_img, false, false)
        if not self.item_load then
            self.item_load = loadSpriteTextureFromCDN(self.tips_img, res, ResourcesType.single, self.item_load)
        end
    end
    --self.tips_lab_bg:setVisible(false)
    self.go_btn:setVisible(false)
    self.tips_lab:setVisible(false)
    if self.open_type == WorldmapEvent.open_type.open_type_1 then --当前关卡
        self.go_btn:setVisible(true)
    elseif self.open_type == WorldmapEvent.open_type.open_type_2 then--已开启
        --self.tips_lab_bg:setVisible(true)
        self.tips_lab:setVisible(true)
        self.tips_lab:setString(TI18N("已通关"))
        --self.tips_lab:setTextColor(cc.c4b(0xf4,0xde,0xbc,0xff))
    elseif self.open_type == WorldmapEvent.open_type.open_type_3 then--未开启
        self.tips_lab:setVisible(true)
        self.tips_lab:setString(TI18N("未到达"))
        --self.tips_lab:setTextColor(cc.c4b(0x95,0x53,0x22,0xff))
    end
end

function WorldMapTipsWindow:setDataList(disc)
    local descArr= {}
    descArr[1] = disc

    self.render_list = descArr
    for i, v in ipairs(self.render_list) do
        delayRun(
            self.container, i / display.DEFAULT_FPS, function()
                self:createList(v)
            end
        )
    end
end

function WorldMapTipsWindow:createList(data)
    local container, height = self:createTitleContent(data)
    self.scroll_view:addChild(container)

    table.insert(self.cache_list, container)
    self.max_height = self.max_height + height + 30

    local max_height = math.max(self.max_height, self.scroll_height)
	self.scroll_view:setInnerContainerSize(cc.size(self.scroll_width, max_height))
    local off_y = 0
    for i,v in ipairs(self.cache_list) do
        v:setPosition(8, max_height-off_y)
        off_y = off_y + v:getContentSize().height + 30
    end

end

function WorldMapTipsWindow:createTitleContent(data)
    if data == nil then return end
    local container = ccui.Widget:create()
    container:setAnchorPoint(cc.p(0, 1))
    container:setCascadeOpacityEnabled(true)
    
   local _height = 0

    -- 重新矫正一下位置坐标
    local content = createRichLabel(24, Config.ColorData.data_new_color4[6], cc.p(0.5, 1), cc.p(547/2, 0), 15, nil, 547)
    content:setString(data)
    container:addChild(content)
    local _width = self.scroll_width - 8
    _height = content:getContentSize().height
    container:setContentSize(cc.size(_width, _height))
    content:setPositionY(_height - 8)
    
    return container, _height
end

function WorldMapTipsWindow:close_callback()
    GlobalEvent:getInstance():Fire(WorldmapEvent.World_Map_Unlock_item)
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    self.container:stopAllActions()
    _controller:openWorldMapTipsWindow(false)
end