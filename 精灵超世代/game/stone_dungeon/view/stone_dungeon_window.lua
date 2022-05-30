--[[
宝石副本主界面
--]]
StoneDungeonWindow = StoneDungeonWindow or BaseClass(BaseView)
local controller = Stone_dungeonController:getInstance()
local model = controller:getModel()

local const = Config.DungeonStoneData.data_const
local data_buy = Config.DungeonStoneData.data_buy
local type_open = Config.DungeonStoneData.data_type_open
local award_list = Config.DungeonStoneData.data_award_list
local table_insert = table.insert
local table_sort = table.sort
function StoneDungeonWindow:__init()
    self.role_vo = RoleController:getInstance():getRoleVo()
    self.is_full_screen = true
    self.win_type = WinType.Full
    --self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "stonedungeon/stone_dungeon_window"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("activity", "activity"), type = ResourcesType.plist}
    }
    self.first_come_in = true
    self.cur_index = 1
    self.tab_list = {}
    self.banner_load = {}
    self.banner_title_load = {}
end

function StoneDungeonWindow:open_callback()
    local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_63",true)
    if not self.item_load then
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(background) then
                loadSpriteTexture(background,res,LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    --self:playEnterAnimatianByObj(self.main_container, 1)
    --self.main_container:getChildByName("Image_2"):getChildByName("Text_12"):setString(TI18N("日常副本"))

    local tab_container = self.main_container:getChildByName("tab_container")
    local scroll_view_size = tab_container:getContentSize()
    local setting = {
        item_class = StoneDungeonTab,      -- 单元类
        start_x = 0,                  -- 第一个单元的X起点
        space_x = 16,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 0,                    -- y方向的间隔
        item_width = 120,               -- 单元的尺寸width
        item_height = 146,              -- 单元的尺寸height
        row = 1,                        -- 行数，作用于水平滚动类型
        col = 0,                         -- 列数，作用于垂直滚动类型
    }
    self.tabScrollview = CommonScrollViewLayout.new(tab_container, cc.p(0,0), ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting)


    self.banner_img = self.main_container:getChildByName("banner_img")
    self.title_img = self.main_container:getChildByName("title_img")
    self.bg_img = self.main_container:getChildByName("bg_img")

    local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_75")
    loadSpriteTexture(self.banner_img,res,LOADTEXT_TYPE)
    res = PathTool.getPlistImgForDownLoad("activity/txt_activity","txt_activity_title_2")
    loadSpriteTexture(self.title_img,res,LOADTEXT_TYPE)
    res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_104")
    loadSpriteTexture(self.bg_img,res,LOADTEXT_TYPE)

    self.banner = self.main_container:getChildByName("banner")
    self.close_btn = self.main_container:getChildByName("close_btn")

    self.textCount = self.banner:getChildByName("textCount")
    self.textCount1 = self.banner:getChildByName("textCount_0")
    self.bannerTitleImg = self.banner:getChildByName("banner_title_img")

    self.btnRule = self.banner:getChildByName("btnRule")
    self.scoreView = self.main_container:getChildByName("scoreView")
    local scroll_view_size = cc.size(self.scoreView:getContentSize().width + 10, self.scoreView:getContentSize().height - 10)
    local setting = {
        item_class = StoneDungeonItem,      -- 单元类
        start_x = 7,                  -- 第一个单元的X起点
        space_x = 0,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                    -- y方向的间隔
        item_width = 676,               -- 单元的尺寸width
        item_height = 112,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 1                         -- 列数，作用于垂直滚动类型
    }
    self.itemScrollview = CommonScrollViewLayout.new(self.scoreView, cc.p(0,5), ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
end

function StoneDungeonWindow:register_event()
    self:addGlobalEvent(Stone_dungeonEvent.Updata_StoneDungeon_Data, function(data)
        self:changeDungeonData(self.cur_index,1)
        self.first_come_in = false
        self:redPointStatus()
    end)

    registerButtonEventListener(self.btnRule, function(param,sender, event_type)
        local config = Config.DungeonStoneData.data_const.desc_rule
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
    end,true, 1,nil,1)

    registerButtonEventListener(self.close_btn, function()
        controller:openStoneDungeonView(false)
    end,true, 2)

    if self.role_vo then
        if not self.updata_role_event then
            self.updata_role_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "lev" then
                    self:changeDungeonData(self.cur_index)
                end
            end)
        end
    end
end

--红点
function StoneDungeonWindow:redPointStatus()
    local status = {}
    local length = Config.DungeonStoneData.data_type_open_length
    local list = const.dungeon_type.val
    for i=1, length do
        local count = model:getChangeSweepCount(list[i])
        status[list[i]] = false
        local bool = MainuiController:getInstance():checkIsOpenByActivate(type_open[list[i]].activate)
        if count < 2 and bool == true then
            status[list[i]] = true
        end
        local item = self.tab_list[i]
        if item then
            item:setSelectRedPoint(status[list[i]] or false)
        end
    end
    local bool = false
    for i=1,length do
        bool = bool or (status[i] or false)
    end
    return bool
end

function StoneDungeonWindow:changeDungeonData(index,flag)
    index = type_open[index].id or 1
    local change_count = model:getChangeSweepCount(index)
    local str = ""
    local num = ""
    local free_count = 1 --1:还有次数
    if change_count >= 2 then
        free_count = 0
        if change_count >= #data_buy[index] then
            str = string.format(TI18N("今日已无次数"))
        else
            local vip_count = 1
            for i,v in ipairs(data_buy[index]) do
                if v.vip <= self.role_vo.vip_lev then
                    vip_count = i
                end
            end
            local remain_num = vip_count - change_count
            if remain_num <= 0 then
                remain_num = 0
            end
            str = string.format(TI18N("今日剩余次数:"),remain_num)
            num = remain_num
        end
    else
        str = string.format(TI18N("今日免费次数:"),const.free_num.val-change_count)
        num = const.free_num.val-change_count
    end
    self.textCount:setString(str)
    self.textCount1:setString(num)
    if self.itemScrollview then
        local data_info = {}
        for i,v in pairs(award_list[index]) do
            table_insert(data_info,v)
        end
        table_sort(data_info,function(a,b) return a.id < b.id end)


        local title_pos = self:getPoerTitle(data_info)      
        change_count = change_count + 1
        if change_count >= #data_buy[index] then
            change_count = #data_buy[index]
        end

        local tab = {
            title_pos = title_pos, --推荐位置
            count = free_count, --免费次数
            expend = data_buy[index][change_count].cost, --消耗钻石
        }

        local list_item = self.itemScrollview:getItemList()
        if flag == 1 and self.first_come_in == false then
            for i=1,#list_item do
                list_item[i]:setExtendData(tab)
                list_item[i]:setChangeData(data_info[i])
            end
        else
            self.itemScrollview:setData(data_info,nil,nil,tab)
            self.itemScrollview:jumpToMove(cc.p(0,125 * (title_pos-1)), 0.2)
        end
    end
end

--获取推荐角标
function StoneDungeonWindow:getPoerTitle(data)
    local num = 0
    local totle = tableLen(data)
    for i, v in ipairs(data) do
        local clearance = model:getPassClearanceID(v.id)
        if self.role_vo.max_power >= v.power then
            if clearance and clearance.status == 1 then
                num = i
            end
        end
    end
    if num+1 >= totle then
        if data[num+1] and self.role_vo.max_power >= data[num+1].power and self.role_vo.lev >= data[num+1].lev_limit then
            num = totle
        end
    else
        if data[num+1] and self.role_vo.max_power >= data[num+1].power and self.role_vo.lev >= data[num+1].lev_limit then
            num = num + 1
        else
            return num
        end
    end
    return num
end

function StoneDungeonWindow:openRootWnd()
    controller:send13030()
    local list = const.dungeon_type.val
    local tab = {}
    for i=1,#list do
        table.insert(tab,{id=list[i]})
    end
    self:setLoadBanner(1)

    self.tabScrollview:setData(tab,function(cell)
        local bool = MainuiController:getInstance():checkIsOpenByActivate(type_open[cell:getData().id].activate)
        if bool == false then
            message(type_open[cell:getData().id].desc)
            return
        end
        if self.cur_index == cell:getData().id then return end 

        local list_item = self.tabScrollview:getItemList()
        for k, v in pairs(list_item) do
            if v:getData().id == cell:getData().id then
                v:setSelect(true)
            else
                v:setSelect(false)
            end
        end
        self.cur_index = cell:getData().id
        self:changeDungeonData(cell:getData().id)
        print("cell:getData().id",cell:getData().id)
        self:setLoadBanner(type_open[cell:getData().id].id)
    end)

    if self.tabScrollview then
        self.tabScrollview:addEndCallBack(function()
            local list_item = self.tabScrollview:getItemList()
            for i,v in pairs(list_item) do
                table_insert(self.tab_list,v)
            end
            self:redPointStatus()
        end) 
    end
end

function StoneDungeonWindow:setLoadBanner(id)
    local str = string.format("txt_cn_activity_banner_%d", id)
    local bg_res = PathTool.getPlistImgForDownLoad("activity/activity_big", str)
    if not self.banner_load[id] then
        self.banner_load[id] = loadSpriteTextureFromCDN(self.banner, bg_res, ResourcesType.single, self.banner_load[id])
    else
        loadSpriteTexture(self.banner, bg_res, LOADTEXT_TYPE)
    end
    str = string.format("txt_stonedungeon_%d",id)
    bg_res = PathTool.getPlistImgForDownLoad("activity/txt_activity", str)
    if not self.banner_title_load[id] then
        self.banner_title_load[id] = loadSpriteTextureFromCDN(self.bannerTitleImg, bg_res, ResourcesType.single, self.banner_title_load[id])
    else
        loadSpriteTexture(self.bannerTitleImg, bg_res, LOADTEXT_TYPE)
    end

end

function StoneDungeonWindow:close_callback()
    for i,v in pairs(self.banner_load) do
        if v then
            v:DeleteMe()
            v = nil
        end
    end
    self.banner_load = {}

    if self.banner_load_top then
        self.banner_load_top:DeleteMe()
    end
    self.banner_load_top = nil
    if self.item_load then
        self.item_load:DeleteMe()
    end
    self.item_load = nil
    if self.itemScrollview then
        self.itemScrollview:DeleteMe()
        self.itemScrollview = nil
    end
    if self.tabScrollview then
        self.tabScrollview:DeleteMe()
        self.tabScrollview = nil
    end
    for i,v in pairs(self.tab_list) do
        if v.DeleteMe then
            v:DeleteMe()
            v = nil
        end
    end
    
    if self.role_vo then
        if self.updata_role_event then
            self.role_vo:UnBind(self.updata_role_event)
            self.updata_role_event = nil
        end
        self.role_vo = nil
    end
    controller:openStoneDungeonView(false)
end

--******************
--Tab
--******************
StoneDungeonTab = class("StoneDungeonTab", function()
    return ccui.Widget:create()
end)

function StoneDungeonTab:ctor()
    self:configUI()
    self:register_event()
end

function StoneDungeonTab:configUI()
    self.rootWnd = createCSBNote(PathTool.getTargetCSB("stonedungeon/stone_dungeon_tab"))
    self:setAnchorPoint(cc.p(0.5, 0.5))
    self:addChild(self.rootWnd)
    self:setTouchEnabled(true)
    self:setCascadeOpacityEnabled(true)
    self:setContentSize(cc.size(120,146))

    local main_container = self.rootWnd:getChildByName("main_container")
    self.normal = main_container:getChildByName("normal")
    self.title = main_container:getChildByName("title")
    --self.title:setPositionY(19)
    self.condite = main_container:getChildByName("condite")
    self.redpoint = main_container:getChildByName("redpoint")
    self.redpoint:setZOrder(2)
    self.select = main_container:getChildByName("select")
    self.select:setVisible(false)

    --self.effect = createEffectSpine(PathTool.getEffectRes(547), cc.p(63, 64), cc.p(0.5, 0.5), true, PlayerAction.action)
    --main_container:addChild(self.effect, 1)
    --self.effect:setVisible(false)
end
function StoneDungeonTab:setData(data)
    if not data or next(data) == nil then return end
    self.data = data
    dump(data)
    local res = PathTool.getPlistImgForDownLoad("activity/activity_tab", "activity_tab_"..data.id)
    self.tab_load = loadSpriteTextureFromCDN(self.normal, res, ResourcesType.single, self.tab_load)
    print("dddddddd ",type_open[data.id].name)
    dump(type_open[data.id])
    self.title:setString(type_open[data.id].name)
    if data.id == 1 then
        self:setSelect(true)
    end
    local bool = MainuiController:getInstance():checkIsOpenByActivate(type_open[data.id].activate)
    if bool == true then
        self.condite:setVisible(false)
    else
        self.condite:setVisible(true)
    end
end
function StoneDungeonTab:setSelect(visible)
    if self.select then
        -- self.select:setVisible(visible)
        self.select:setVisible(visible)
    end
end
function StoneDungeonTab:setSelectRedPoint(visible)
    if self.redpoint then
        self.redpoint:setVisible(visible)
    end
end
function StoneDungeonTab:getData()
    return self.data
end
function StoneDungeonTab:addCallBack(value)
    self.callback =  value
end
function StoneDungeonTab:register_event()
    self:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click = math.abs(self.touch_end.x - self.touch_began.x) <= 20 and math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                playButtonSound2()
                if self.callback then
                    self:callback()
                end
            end
            elseif event_type == ccui.TouchEventType.moved then
            elseif event_type == ccui.TouchEventType.began then
                self.touch_began = sender:getTouchBeganPosition()
            elseif event_type == ccui.TouchEventType.canceled then
            end
    end)
end
function StoneDungeonTab:DeleteMe()
    if self.tab_load then
        self.tab_load:DeleteMe()
        self.tab_load = nil
    end
    --if self.effect then
    --    self.effect:clearTracks()
    --    self.effect:removeFromParent()
    --    self.effect = nil
    --end

    self:removeAllChildren()
    self:removeFromParent()
end