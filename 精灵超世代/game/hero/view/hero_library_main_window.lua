-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      宝可梦图书馆  策划 晓勤
-- <br/>Create: 2018年11月14日
--
-- --------------------------------------------------------------------
HeroLibraryMainWindow = HeroLibraryMainWindow or BaseClass(BaseView)

local controller = HeroController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function HeroLibraryMainWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.layout_name = "hero/hero_library_main_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("herolibrary","herolibrary"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_bag_bg", true), type = ResourcesType.single },
    }

    --图书馆列表
    self.hero_library_list = {}
    --阵营
    self.select_camp = 0


    --scrollview列表参数
    self.col = 3 --列数
    self.item_width     = 220  --item的宽高
    self.item_height    = 325 + 10
    self.cacheList = {} --对象池
    self.cacheMaxSize = 0 --最大池数

    -- 到时间显示的索引
    self.time_show_index = 0
    self.first_title_height = 50 --第一个的高度
    self.title_height = 80 --职业名字的高

    --列表职业对应信息
    self.career_info_list = {}
end

function HeroLibraryMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg/hero", "hero_bag_bg", true), LOADTEXT_TYPE)
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container , 1)  

    -- self.no_vedio_image = self.container:getChildByName("no_vedio_image")
    -- self.no_vedio_label = self.container:getChildByName("no_vedio_label")
    -- self.no_vedio_label:setString(TI18N("一个宝可梦都没有哦，快去召唤吧"))
    self.lay_scrollview = self.main_container:getChildByName("lay_scrollview")

    self.centre_box_1 = self.main_container:getChildByName("centre_box_1")
    self.border_left_box_2 = self.main_container:getChildByName("border_left_box_2")
    self.border_right_box_2 = self.main_container:getChildByName("border_right_box_2")
    self.top_box_4 = self.main_container:getChildByName("top_box_4")
    self.bottom_box_5 = self.main_container:getChildByName("bottom_box_5")

    local camp_node = self.bottom_box_5:getChildByName("camp_node")
    self.camp_btn_list = {}
    self.camp_btn_list[0] = camp_node:getChildByName("camp_btn0")
    self.camp_btn_list[1] = camp_node:getChildByName("camp_btn1")
    self.camp_btn_list[2] = camp_node:getChildByName("camp_btn2")
    self.camp_btn_list[3] = camp_node:getChildByName("camp_btn3")
    self.camp_btn_list[4] = camp_node:getChildByName("camp_btn4")
    self.camp_btn_list[5] = camp_node:getChildByName("camp_btn5")
    self.img_select = camp_node:getChildByName("img_select")
    local x, y = self.camp_btn_list[0]:getPosition()
    self.img_select:setPosition(x - 0.5, y + 1)

    self.close_btn = self.bottom_box_5:getChildByName("close_btn")
    self:adaptationScreen()

end

--设置适配屏幕
function HeroLibraryMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)
    local left_x = display.getLeft(self.main_container)
    local right_x = display.getRight(self.main_container)

    local main_container_size = self.main_container:getContentSize()

    --下
    local _, bottom_box_5_y = self.bottom_box_5:getPosition()
    local content_bottom = bottom_box_5_y + bottom_y
    --上
    local _, top_box_4_y = self.top_box_4:getPosition()
    local content_top =  top_y - (main_container_size.height - top_box_4_y)
    --左
    local border_left_box_2_x = self.border_left_box_2:getPositionX()
    local content_left = border_left_box_2_x + left_x
    --右
    local border_right_box_2_x = self.border_right_box_2:getPositionX()
    local content_right = right_x - (main_container_size.width - border_right_box_2_x)
    
    local width = content_right - content_left
    local height = content_top - content_bottom

    self.top_box_4:setPositionY(content_top)
    self.bottom_box_5:setPositionY(content_bottom)
    self.border_left_box_2:setPosition(content_left, content_bottom + height * 0.5)
    self.border_right_box_2:setPosition(content_right, content_bottom + height * 0.5)

    self.top_box_4:setContentSize(cc.size(width, 94)) --省读取速度直接用数字.这个是固定的.
    self.bottom_box_5:setContentSize(cc.size(width, 101)) --省读取速度直接用数字.这个是固定的.
    self.border_left_box_2:setContentSize(cc.size(35, height)) --省读取速度直接用数字.这个是固定的.
    self.border_right_box_2:setContentSize(cc.size(35, height)) --省读取速度直接用数字.这个是固定的.

    self.centre_box_1:setPosition(content_left, content_bottom)
    self.centre_box_1:setContentSize(width, height)

    -- local offset_x = 30 --上下左右都跟边框 是30的距离
    local offset_y = 30 --上下左右都跟边框 是30的距离

    self.lay_scrollview:setPosition(content_left, content_bottom + offset_y)
    self.lay_scrollview:setContentSize(width, height - offset_y * 2)

    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- --主菜单 底部的高度
    -- local bottom_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
end

function HeroLibraryMainWindow:register_event()
    registerButtonEventListener(self.close_btn, function() self:onClickBtnClose(false) end, true, 2)

    --阵营按钮
    for index, v in pairs(self.camp_btn_list) do
        registerButtonEventListener(v, function() self:onClickBtnShowByIndex(index) end ,true, 2)
    end
end

function HeroLibraryMainWindow:onClickBtnClose()
    controller:openHeroLibraryMainWindow(false)
end

--显示根据类型 0表示全部
function HeroLibraryMainWindow:onClickBtnShowByIndex(index, is_must_reset)
    if self.img_select and self.camp_btn_list[index] then
        local x, y = self.camp_btn_list[index]:getPosition()
        self.img_select:setPosition(x - 0.5, y + 1)
    end
    self:updateHeroList(index, is_must_reset)
end

function HeroLibraryMainWindow:openRootWnd(bid)
    self:onClickBtnShowByIndex(0, true)
end

--更新职业的ui
--title_pos_list 结构: title_pos_list[n] = {career_type = career_type, pos_y = xx}
function HeroLibraryMainWindow:updateCareerUI(title_pos_list, container_height, start_x)
    for i,career_info in ipairs(self.career_info_list) do
        if career_info.desk then
            career_info.desk:setVisible(false)
        end
        career_info.bg:setVisible(false)
    end

    local start_x  = start_x or 0
    for i, info in ipairs(title_pos_list) do
        local career_type = info.career_type or HeroConst.CareerName.eMagician
        local pos_y = info.pos_y or 0
        local name  = HeroConst.CareerName[career_type]
        local desk_y = container_height - pos_y
        local bg_y 
        if i == 1 then
            bg_y = container_height - pos_y
        else
            bg_y = container_height - (pos_y + 25)
        end
        if self.career_info_list[i] == nil then
            --第一个位置不需要台子
            local career_info = {}
            if i ~= 1 then
                local res = PathTool.getResFrame("herolibrary","hero_library_box_5")
                career_info.desk = createImage(self.list_view, res, self.scrollview_size.width/2, desk_y, cc.p(0.5,0.5), true, 0, true)
                career_info.desk:setContentSize(cc.size(self.scrollview_size.width , 103))
                career_info.desk:setCapInsets(cc.rect(41, 0, 40, 0))
            end
            local res = PathTool.getResFrame("herolibrary","hero_library_18")
            local bg_hegit = 48
            career_info.bg = createImage(self.list_view, res, start_x, bg_y, cc.p(0, 1), true, 0, true)
            career_info.bg:setContentSize(cc.size(232, bg_hegit))
            career_info.bg:setCapInsets(cc.rect(42, 0, 2, 48))

            local res = PathTool.getPartnerTypeIcon(career_type)
            career_info.career_icon = createSprite(res, 50, bg_hegit * 0.5 - 3,  career_info.bg, cc.p(0, 0.5), LOADTEXT_TYPE_PLIST)
            career_info.label = createLabel(24, cc.c4b(0x64,0x32,0x23,0xff), nil, 88, bg_hegit * 0.5 - 3, name, career_info.bg, nil, cc.p(0,0.5))
            self.career_info_list[i] = career_info
        else
            local career_info = self.career_info_list[i]
            if career_info.desk then
                career_info.desk:setVisible(true)
                career_info.desk:setPositionY(desk_y)
            end
            career_info.bg:setVisible(true)
            career_info.bg:setPositionY(bg_y)

            local res = PathTool.getPartnerTypeIcon(career_type)
            loadSpriteTexture(career_info.career_icon, res, LOADTEXT_TYPE_PLIST)
            career_info.label:setString(name)
        end
    end
end

--创建宝可梦列表 
-- @select_camp 选中阵营
function HeroLibraryMainWindow:updateHeroList(select_camp, is_must_reset)
    local select_camp = select_camp or 1
    if not is_must_reset and select_camp == self.select_camp then 
        return
    end
    if not self.list_view then
        local size = self.lay_scrollview:getContentSize()
        --方法里面定义了 self.list_view
        self:createLibraryScrollView(size, size.width * 0.5, size.height * 0.5)
    end

    self.select_camp = select_camp

    local config_list = Config.PartnerData.data_partner_base or {}
    
    local list = {}
    for k, config in pairs(config_list) do
        if select_camp == 0 or (select_camp == config.camp_type) then
            table_insert(list, config)    
        end
    end
    local sort_func = SortTools.tableCommonSorter({{"type", false}, {"init_star", true}, {"camp_type", false}, {"sort_order", false}})
    table_sort(list, sort_func)

    local content_y = 0 
    local start_x = (self.scrollview_size.width - self.item_width * self.col) * 0.5 
    --获取下一个位置根据当前数量
    local function _getNextPositionBySize(size)
        local count = size % self.col 
        if count == 0 then
            --换行
            content_y = content_y + self.item_height
        end
        local x = start_x + self.item_width * count + self.item_width * 0.5
        local y = content_y + self.item_height * 0.5 
        return x, y
    end

    local title_pos_list = {}
    local career_type = nil
    self.hero_library_list = {}
    for i,v in ipairs(list) do
        if career_type == nil then
            career_type = v.type
            --(之所以减一个高度是因为下面计算第一次时会加一个高度)
            content_y = self.first_title_height - self.item_height 
            table_insert(title_pos_list , {career_type = career_type, pos_y = 0})
        end

        if career_type ~= v.type then
            --算出多出的空位置 用{}去填补
            local count = self.col - #self.hero_library_list % self.col
            if count < self.col and count ~= 0 then
                for i=1,count do
                    local x, y = _getNextPositionBySize(#self.hero_library_list)
                    table_insert(self.hero_library_list, {x = x, y = y}) 
                end
            end
            career_type = v.type
            table_insert(title_pos_list ,{career_type = career_type, pos_y = content_y + self.item_height})
            --遇到新职业..加title高度
            content_y = content_y + self.title_height
        end    
        local x, y = _getNextPositionBySize(#self.hero_library_list)
        table_insert(self.hero_library_list, {config = v, x = x, y = y})   
    end
    --内容的高度
    local container_height 
    if #self.hero_library_list > 0 then
        container_height  = content_y + self.item_height
    else
        container_height = 0
    end

    self:updateCareerUI(title_pos_list, container_height, start_x)
    self:reloadData(container_height)

    -- if #self.hero_library_list == 0 then
    --     self.no_vedio_image:setVisible(true)
    --     self.no_vedio_label:setVisible(true)
    --     return
    -- else
    --     self.no_vedio_image:setVisible(false)
    --     self.no_vedio_label:setVisible(false)
    -- end
end

--获取数据数量
function HeroLibraryMainWindow:numberOfCells()
    return #self.hero_library_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function HeroLibraryMainWindow:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.hero_library_list[index]
    if cell_data.config then
        cell:setVisible(true)
        cell:setData(cell_data.config)
    else
        cell:setVisible(false)
    end
end

--点击cell .需要在 createNewCell 设置点击事件
function HeroLibraryMainWindow:onCellTouched(cell)
    local index = cell.index
    local cell_data = self.hero_library_list[index]
    if cell_data and cell_data.config then

        local draw_res = cell_data.config.draw_res
        local library_config = Config.PartnerData.data_partner_library(cell_data.config.bid)
        if draw_res and library_config and draw_res ~= "" then
            --有立绘的 并且有配置图书馆的
            controller:openHeroLibraryInfoWindow(true, cell_data.config.bid)
        else
            message(TI18N("画师正快马加鞭地制作该立绘中哟~"))
             --没有立绘的 宝可梦详情
            local pokedex_config = Config.PartnerData.data_partner_pokedex[cell_data.config.bid]
            if pokedex_config and pokedex_config[1] then
                local star = pokedex_config[1].star or 1
                controller:openHeroInfoWindowByBidStar(cell_data.config.bid, star)
            end
        end
    end
end

--------------------------------开始-------------------------  
--内内部写一个无限的scrollview 
function HeroLibraryMainWindow:createLibraryScrollView(size, x, y)
    self.scrollview_size = size
    self.list_view = createScrollView(size.width, size.height, x, y, self.lay_scrollview, ScrollViewDir.vertical) 
    self.list_view:setAnchorPoint(cc.p(0.5, 0.5))
    self.scrollview_container = self.list_view:getInnerContainer() 

    self.cacheMaxSize = (math.ceil(size.height / self.item_height) + 1) * self.col
    self.list_view:addEventListener(function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.containerMoved then
            self:checkOverShowByVertical()
        end
    end)
end

--==============================--
--desc:竖直方向的监测判断
--time:2018-07-20 03:11:13
--@return 
--==============================--
function HeroLibraryMainWindow:checkOverShowByVertical()
    if not self.cellList then return end
    local container_y = self.scrollview_container:getPositionY()
    --计算 视图的上部分和下部分在self.container 的位置
    local bot = -container_y
    local top = self.scrollview_size.height + bot
    local col_count = math.ceil(#self.cellList/self.col)
    --下面因为 self.cellList 是一维数组 所以要换成二维来算
    --活跃cell开始行数
    local activeCellStartRow = 1
    for i=1, col_count do
        local index = 1 + (i-1)* self.col
        local cell = self.cellList[index]
        activeCellStartRow = i
        if cell and cell.y - self.item_height * 0.5 <= top then
            break
        end
    end
    --活跃cell结束行数
    local activeCellEndRow = col_count
    if bot > 0 then
        for i = activeCellStartRow, col_count do
            local index = 1 + (i-1)* self.col
            local cell = self.cellList[index]
            if cell and cell.y + self.item_height * 0.5 < bot then
                activeCellEndRow = i - 1
                break
            end
        end
    end
    -- print("保留--> top --> :"..top .." self.col:"..self.col)
    -- print("保留--> bot --> :"..bot )
    -- print("保留--> 开始行: "..activeCellStartRow.."结束行: "..activeCellEndRow)
    local max_count = self:numberOfCells()
    for i=1, col_count do
        if i >= activeCellStartRow and i <= activeCellEndRow then
            for k=1, self.col do
                local index = (i-1) * self.col + k
                if not self.activeCellIdx[index] then
                    if index <= max_count then
                        self:updateCellAtIndex(index)
                        self.activeCellIdx[index] = true
                    end
                end    
            end
        else
            for k=1, self.col do
                local index = (i-1) * self.col + k
                if index <= max_count then
                    self.activeCellIdx[index] = false
                end
            end
        end
    end
end

function HeroLibraryMainWindow:reloadData(container_height)
    self.cellList = {}
    self.activeCellIdx = {}
    for k, v in ipairs(self.cacheList) do
        --相当于隐藏
        v:setPositionX(-10000)
    end
    
    local container_height = math.max(container_height, self.scrollview_size.height)
    self.container_size = cc.size(self.scrollview_size.width, container_height)
    self.list_view:setInnerContainerSize(self.container_size)
    self.list_view:jumpToTop()

    local number = self:numberOfCells()
    if number == 0 then
        return
    end

    for i = 1, number do
        local data = self.hero_library_list[i]
        if data ~= nil then
            local cell = nil 
            if i <= self.time_show_index then
                cell = self:getCacheCellByIndex(i)
            end
            local count = #self.cellList
            local x = data.x
            local y = container_height - data.y
            local cellData = {cell = cell, x = x, y = y}
            table_insert(self.cellList, cellData)
        end
    end
    
    -- if self.is_first_init then
    --     self:startTimeTicket()
    -- else
    --     --如果时间显示索引小于总数 应该显示继续当前定时器 让下面的能显示出来
    --     if self.time_show_index <= number then
    --         self:startTimeTicket()
    --     end
    -- end
    -- if select_index == nil then
        local maxRefreshNum = self.cacheMaxSize - self.col
        local refreshNum = number < maxRefreshNum and number or maxRefreshNum

        for i = 1, refreshNum do
            local index = i
            delayRun(self.list_view,index / display.DEFAULT_FPS,function ()
                if self.time_show_index < index then
                    self.time_show_index = index
                end
                self:updateCellAtIndex(index)
                if self.time_show_index == refreshNum then
                    self.time_show_index = 9999
                end
            end)
            self.activeCellIdx[i] = true
        end
    -- else
    --     self:selectCellByIndex(select_index)
    -- end   

     
end

--获得格子下标对应的缓存itemCell
function HeroLibraryMainWindow:getCacheCellByIndex(index)
    local cacheIndex = (index - 1) % self.cacheMaxSize + 1
    if not self.cacheList[cacheIndex] then
        local newCell = HeroLibraryMainItem.new()
        newCell:addCallBack(function() self:onCellTouched(newCell) end)
        newCell:setAnchorPoint(cc.p(0.5, 0.5))
        newCell:setPositionX(-10000)--隐藏
        self.cacheList[cacheIndex] = newCell
        self.list_view:addChild(newCell, 2)
        return newCell
    else
        return self.cacheList[cacheIndex]
    end
end

--更新格子，并记为活跃
function HeroLibraryMainWindow:updateCellAtIndex(index)
    if index > self.time_show_index then
        return
    end
    if not self.cellList[index] then return end
    local cellData = self.cellList[index]
    if cellData.cell == nil then
        cellData.cell = self:getCacheCellByIndex(index)
    end
    cellData.cell:setPosition(cellData.x, cellData.y)
    self:updateCellByIndex(cellData.cell, index)
end


--------------------------scrollview结束-------------------------

function HeroLibraryMainWindow:close_callback()
    doStopAllActions(self.list_view)
    -- if self.list_view then
    --     self.list_view:DeleteMe()
    --     self.list_view = nil
    -- end
    for k, item in ipairs(self.cacheList) do
        if item.DeleteMe then
            item:DeleteMe()
        end
    end
    controller:openHeroLibraryMainWindow(false)
end


-- 图书馆item--------------------------------------------------------------------------------------------
HeroLibraryMainItem = class("HeroLibraryMainItem", function() 
    return ccui.Layout:create()
end)

function HeroLibraryMainItem:ctor()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("hero/hero_library_main_item"))
    self.size = self.root_wnd:getContentSize()
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setTouchEnabled(true)
    self:setAnchorPoint(0,0)
    self:setContentSize(self.size)
    self.root_wnd:setPosition(0, 0)

    self.main_panel = self.root_wnd:getChildByName("main_panel")
    self.hero_icon = self.main_panel:getChildByName("hero_icon")
    self.camp_icon = self.main_panel:getChildByName("camp_icon")
    self.profession_icon = self.main_panel:getChildByName("profession_icon")
    self.name = self.main_panel:getChildByName("name")

    self:registerEvent()
end

function HeroLibraryMainItem:registerEvent()
    self:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            self:clickFun()
        end
    end)
end

function HeroLibraryMainItem:addCallBack(callback)
    self.callback = callback
end
function HeroLibraryMainItem:clickFun()
    if self.callback then
        self:callback()
    end
end

--@config 结构是 Config.PartnerData.data_partner_base
function HeroLibraryMainItem:setData(config)
    if not config then return end
    self.config = config
    --heroicon
    local res_id = PathTool.getPlistImgForDownLoad("bigbg/partnercard", "partnercard_" .. self.config.bid)
    if self.record_res_id == nil or self.record_res_id ~= res_id then
        self.record_res_id = res_id
        self.item_load = loadSpriteTextureFromCDN(self.hero_icon, res_id, ResourcesType.single, self.item_load, 60)
    end
    --阵营
    local camp_res = PathTool.getHeroCampTypeIcon(self.config.camp_type)
    if self.record_camp_res == nil or self.record_camp_res ~= camp_res then
        self.record_camp_res = camp_res 
        loadSpriteTexture(self.camp_icon, camp_res, LOADTEXT_TYPE_PLIST)
    end

    --职业
    local hero_type = self.config.type or 4
    local res = PathTool.getPartnerTypeIcon(hero_type)
    if self.record_type_res == nil or  self.record_type_res ~= res then
        self.record_type_res = res
        loadSpriteTexture(self.profession_icon, res, LOADTEXT_TYPE_PLIST)
    end

    self.name:setString(self.config.name)

    local icon_size = self.profession_icon:getContentSize()
    local name_size = self.name:getContentSize()

    local offset = 5
    total_width = icon_size.width + offset + name_size.width
    local x = (self.size.width - total_width) * 0.5 

    self.profession_icon:setPositionX(x +  icon_size.width * 0.5)
    self.name:setPositionX(x +  icon_size.width + offset + name_size.width * 0.5)
end

function HeroLibraryMainItem:DeleteMe()
    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end

    self:removeAllChildren()
    self:removeFromParent()
end