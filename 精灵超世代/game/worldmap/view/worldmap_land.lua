-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      世界地图大陆板块
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
WorldMapLand =
    class(
    "WorldMapLand",
    function()
        return ccui.Layout:create()
    end
)

local tolua_isnull = tolua.isnull

function WorldMapLand:ctor(config, land_id, click_callback,data)
    self.config = config
    self.land_id = land_id
    self.click_callback = click_callback
    self.size = cc.size(100, 53)
    self.scale = 2
    self.item_list = {}
    self.had_unlock = false
    self.open_chapter_data = data
    self:createRootWnd()
end

function WorldMapLand:createRootWnd()
    self:setContentSize(self.size)
    self:setAnchorPoint(cc.p(0.5, 0))
    
    -- if self.land_id >= self.config.bid then     -- 当前挑战到的大陆版本比该板块大，就标识已经开启了，这个时候不需要创建静态云的,而直接创建当前大陆板块的名字
        self.name_container = createImage(self, PathTool.getResFrame("common", "common_2046"), self.config.name_x, self.config.name_y, cc.p(0.5, 0.5), true, 10, true)
        self.name_container:setCapInsets(cc.rect(43, 1, 1, 1))
        self.name_container:setContentSize(cc.size(230,51))
    --self.name_container = createSprite(PathTool.getResFrame("common", "common_2046"), self.config.name_x, self.config.name_y, self, cc.p(0.5, 0.5), LOADTEXT_TYPE_PLIST, 10)
        self.name_label = createLabel(20, Config.ColorData.data_new_color4[6], nil, 115, 25, TI18N(self.config.name), self.name_container, nil, cc.p(0.5, 0.5))
        self.name_label:setLocalZOrder(9)
        self.had_unlock = true
    -- else
        -- if self.config.bid > 1 then
        --     local res = PathTool.getPlistImgForDownLoad("bigbg", string.format("worldmap/worldmap_100%s", self.config.bid))
        --     self.main_land_load = createResourcesLoad(res, ResourcesType.single, function()
        --         self.mainland = createImage(self, res, self.size.width * 0.5, self.size.height * 0.5, cc.p(0.5, 0.5), false)
        --         self.mainland:setScale(self.scale)
        --     end, self.main_land_load)
        -- end
    -- end

    -- 绘制点击区域，不做像素监测了，直接做一个不相互压住的做点击判断,只有解锁的才做点击响应
    if self.had_unlock == true then
        self.click_layout = ccui.Layout:create()
        self.click_layout:setAnchorPoint(0.5, 0.5)
        self.click_layout:setTouchEnabled(true)
        self.click_layout:setSwallowTouches(false) 
        self:addChild(self.click_layout, 10)
        if self.config.bid == 1 then
            self.click_layout:setPosition(34, -14) 
            self.click_layout:setContentSize(cc.size(440, 300)) 
        elseif self.config.bid == 2 then
            self.click_layout:setPosition(23, 17) 
            self.click_layout:setContentSize(cc.size(600, 200)) 
        elseif self.config.bid == 3 then
            self.click_layout:setPosition(111, -5) 
            self.click_layout:setContentSize(cc.size(500, 300)) 
        elseif self.config.bid == 4 then
            self.click_layout:setPosition(2, 49)
            self.click_layout:setContentSize(cc.size(200, 380)) 
        elseif self.config.bid == 5 then
            self.click_layout:setPosition(74, 14)
            self.click_layout:setContentSize(cc.size(200, 380)) 
        end
    end

    self:registerEvent()
end

function WorldMapLand:registerEvent()
    if self.click_layout ~= nil then
        self.click_layout:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then	
                self.touch_end = sender:getTouchEndPosition()
                local is_click = true
                if self.touch_began ~= nil then
                    is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
                end
                if is_click == true then
                    self:clickHandler()				
                end
            elseif event_type == ccui.TouchEventType.began then			
                self.touch_began = sender:getTouchBeganPosition()
            end
        end) 
    end
end

--==============================--
--desc:点击大陆板块的回调处理，这个时候就选中当前的
--time:2018-06-05 08:47:19
--@return 
--==============================--
function WorldMapLand:clickHandler()
    if self.click_callback then
        self.click_callback(self)
    end
end

function WorldMapLand:addToParent(parent)
    if not tolua_isnull(parent) and self.config then
        parent:addChild(self)
        self:setPosition(self.config.x, self.config.y)
    end
end

--==============================--
--desc:设置选中大陆，这个时候会创建大陆板块上面的据点或者隐藏
--time:2018-06-05 09:02:58
--@status:
--@return 
--==============================--
function WorldMapLand:setSelectedLand(status)
    if status == true then
        if self.item_list then
            for k, v in pairs(self.item_list) do
                v:clearEffect()
            end
        end
        if not tolua_isnull(self.name_container) then
            self.name_container:setVisible(false)
        end
        if self.item_container == nil then
            self.item_container = ccui.Layout:create()
            self.item_container:setContentSize(self.size)
            self.item_container:setAnchorPoint(cc.p(0, 0))
            self:addChild(self.item_container)
        end
        self.item_container:setVisible(true)
        self:createItemList()
    else
        if not tolua_isnull(self.name_container) then 
            self.name_container:setVisible(true)
        end
        if not tolua_isnull(self.item_container) then
            self.item_container:setVisible(false)
        end
    end
end

function WorldMapLand:createItemList()
    if self.config ~= nil and self.config.dungeon_list ~= nil then
        local call_back = function ()
            if self.item_list then
                for k, v in pairs(self.item_list) do
                    v:clearEffect()
                end
            end
        end
        for i, v in ipairs(self.config.dungeon_list) do
            delayRun(
                self.item_container,
                2 * i / display.DEFAULT_FPS,
                function()
                    if self.item_list[v.bid] == nil then
                        self.item_list[v.bid] = WorldMapItem.new(v,self.open_chapter_data)
                        self.item_list[v.bid]:addToParent(self.item_container,call_back)
                    end
                end
            )
        end
    end
end


function WorldMapLand:DeleteMe()
    doStopAllActions(self.item_container) 
    for k, v in pairs(self.item_list) do
        v:DeleteMe()
    end
    self.item_list = nil
    if self.main_land_load then
        self.main_land_load:DeleteMe()
        self.main_land_load = nil
    end
end

