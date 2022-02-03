-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      我的矿脉信息
-- <br/> 2019年7月16日
-- --------------------------------------------------------------------
AdventureMineMyInfoPanel = AdventureMineMyInfoPanel or BaseClass(BaseView)

local controller = AdventureController:getInstance()
local model = controller:getUiModel()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function AdventureMineMyInfoPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "adventure/adventure_mine_my_info_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("adventure","adventureminemgr"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_88"), type = ResourcesType.single }
    }

    self.time_desc_list = {}


    --雇佣时间 初级
    self.primary_time = 30
    local config = Config.AdventureMineData.data_const.primary_time
    if config then
        self.primary_time = config.val
    end
    --雇佣时间 高级
    self.senior_time = 60
     local config = Config.AdventureMineData.data_const.senior_time
    if config then
        self.senior_time = config.val
    end

    self.primary_count = 2
    local config = Config.AdventureMineData.data_const.primary_count
    if config then
        self.primary_count = config.val
    end

    self.senior_count = 3
    local config = Config.AdventureMineData.data_const.senior_count
    if config then
        self.senior_count = config.val
    end



    self.role_vo = RoleController:getInstance():getRoleVo()
end

function AdventureMineMyInfoPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("我的灵矿"))
    self.close_btn = self.main_panel:getChildByName("close_btn")

    self.scroll_container1 = self.main_container:getChildByName("scroll_container1")
    self.scroll_container2 = self.main_container:getChildByName("scroll_container2")


    self.bg = self.main_container:getChildByName("bg")
    loadSpriteTexture(self.bg, PathTool.getPlistImgForDownLoad("bigbg","bigbg_88"), LOADTEXT_TYPE)


    self.all_desc1 = createRichLabel(22, cc.c4b(0xff,0xf9,0xd5,0xff), cc.p(0,0.5), cc.p(46, 738), 6, nil, 900)
    self.main_container:addChild(self.all_desc1)

    self.all_desc2 = createRichLabel(22, cc.c4b(0xff,0xf9,0xd5,0xff), cc.p(1,0.5), cc.p(636, 738), 6, nil, 900)
    self.main_container:addChild(self.all_desc2)

    self.goto_btn_label = createRichLabel(22,cc.c4b(0x79,0xff,0x50,0xff), cc.p(0.5,0.5),cc.p(593, 696))
    self.goto_btn_label:setString(string_format("<div href=xxx outline=2,#000000>%s</div>", TI18N("防守记录")))
    self.main_container:addChild(self.goto_btn_label)
    self.goto_btn_label:addTouchLinkListener(function(type, value, sender, pos)
        controller:openAdventureMineFightRecordPanel(true)
    end, { "click", "href" })
end

function AdventureMineMyInfoPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)


    --我的矿脉信息
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_MY_MINE_INFO_EVENT, function(data)
        if not data then return end
        self:setData(data)
    end)

    --购买矿脉返回
    self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_BUY_EMPLOY_EVENT, function(data)
        if not data then return end
        if not self.my_mine_list then return end
        for i,v in ipairs(self.my_mine_list) do
            if data.floor == v.floor and v.room_id == data.room_id then
                if data.type == 2 then
                    v.senior_count = v.senior_count + 1
                elseif data.type == 1 then
                    v.primary_count = v.primary_count + 1
                end
                self:setData()
                break
            end
        end
    end)

    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "vip" or key == "lev" then
                    self:initMineData(true)
                    self:setData()
                end
            end)
        end
    end
    --红点
    -- self:addGlobalEvent(AdventureEvent.ADVENTURE_MINE_RECORD_RED_POINT_EVENT, function(data)
    --     self:checkRedpoint()
    -- end)
end

function AdventureMineMyInfoPanel:checkRedpoint()
    if model:isMineRecordRedpoint() then
        addRedPointToNodeByStatus(self.goto_btn_label, true, 10, 10)
    else
        addRedPointToNodeByStatus(self.goto_btn_label, false, 10, 10)
    end
end
--关闭
function AdventureMineMyInfoPanel:onClickBtnClose()
    controller:openAdventureMineMyInfoPanel(false)
end

--@level_id 段位
function AdventureMineMyInfoPanel:openRootWnd(setting)
    self:initMineData()
    controller:send20652()
    self:checkRedpoint()
end

--must_updata必须更新
function AdventureMineMyInfoPanel:initMineData(must_updata)
    if self.mine_List and not must_updata then return end
    
    self.mine_List = {}
    local config_list = Config.AdventureMineData.data_mine_unlock_info
    for k,config in pairs(config_list) do
        local data = {}
        if next(config.open_cond) ~= nil then
            local con = config.open_cond[1]
            if con[1] == "lev" then
                if self.role_vo and self.role_vo.lev >= con[2] then
                    data.lock_sort = 0
                else
                    data.lock_sort = 1
                    data.lock_str = string_format(TI18N("达到%s级解锁"), con[2])
                end
            elseif con[1] == "vip" then
                if self.role_vo and self.role_vo.vip_lev >= con[2] then
                    data.lock_sort = 0
                else
                    data.lock_sort = 1
                    data.lock_str = string_format(TI18N("达到vip%s解锁"), con[2])
                end
            end
        else
            data.lock_sort = 0
        end
        data.config = config
        table_insert(self.mine_List, data)
    end
    table_sort(self.mine_List, function(a, b) return a.lock_sort < b.lock_sort end)
end

function AdventureMineMyInfoPanel:setData(data)
    if not data and not self.my_mine_list  then return end
    if data then
        self.my_mine_list = data.mine_list
    end
    
    --计算的是道具id
    local item_id = Config.ItemData.data_assets_label2id.hallow_refine
    local item_config  = Config.ItemData.data_get_data(item_id)
    local res = PathTool.getItemRes(item_config.icon)

    local all_count1 = 0
    local all_count2 = 0
    for i,v in ipairs(self.my_mine_list) do
        for _,item in ipairs(v.hook_items) do
            if item_id and item.item_id == item_id then
                all_count2 = all_count2 + item.num
            end
        end
        v.config = Config.AdventureMineData.data_mine_data(v.mine_id)
        if v.config then
            for _,item in ipairs(v.config.hook_items) do
                if item_id and item[1] == item_id then
                    --需要计算衰减
                    all_count1 = all_count1 + model:getMineRate(v.floor, item[2])
                end
            end
            
            --计算结束时间
            local time = v.config.max_time * 60 
            time = time + v.primary_count * self.primary_time * 60
            time = time + v.senior_count * self.senior_time * 60
            --放弃的时间
            v.give_up_time = v.occupy_time + time
        end 
    end

    local str = string_format(TI18N("<div outline=2,#000000>总收益效率:<img src=%s scale=0.3 /><div fontcolor=#79ff50 outline=2,#000000>%s</div>/m</div>"),res, all_count1)
    self.all_desc1:setString(str)
    local str = string_format(TI18N("<div outline=2,#000000>总收益:<img src=%s scale=0.3 /><div fontcolor=#79ff50 outline=2,#000000>%s</div></div>"),res, all_count2)
    self.all_desc2:setString(str)

    self:startTimeTicket()

    self:updateMineList()

    if #self.my_mine_list == 0 then
         self:updateEmployList()
    end
end


function AdventureMineMyInfoPanel:updateEmployList(my_mine_data)
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container2:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 600,                -- 单元的尺寸width
            item_height = 142,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container2, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.item_scrollview:setClickEnabled(false)
    end


    self.show_list = {}
    self.show_list[1] = {}
    self.show_list[1].name = TI18N("雇佣初级矿工")
    self.show_list[1].time = self.primary_time or 30
    self.show_list[1].buy_type = 1 --后端定义的
    if my_mine_data == nil then
        self.show_list[1].count = self.primary_count or 2
        self.show_list[1].cost = {1, 0}
    else
        local count = self.primary_count - my_mine_data.primary_count
        if count < 0 then
            count = 0
        end
        self.show_list[1].count = count
        if my_mine_data.config and next(my_mine_data.config.primary_loss) ~= nil then
            self.show_list[1].cost = my_mine_data.config.primary_loss[1]
        else
            self.show_list[1].cost = {1, 0}
        end
    end

    self.show_list[2] = {}
    self.show_list[2].name = TI18N("雇佣高级矿工")
    self.show_list[2].time = self.senior_time or 60
    self.show_list[2].buy_type = 2 --后端定义的
    if my_mine_data == nil then
        self.show_list[2].count = self.senior_count or 3
        self.show_list[2].cost = {3, 0}
    else
        local count = self.senior_count - my_mine_data.senior_count
        if count < 0 then
            count = 0
        end
        self.show_list[2].count = count
        if my_mine_data.config and next(my_mine_data.config.senior_loss) ~= nil then
            self.show_list[2].cost = my_mine_data.config.senior_loss[1]
        else
            self.show_list[2].cost = {1, 0}
        end
    end
    -- if #self.show_list == 0 then
    --     commonShowEmptyIcon(self.scroll_container2, true, {text = TI18N("暂无数据")})
    -- else
    --     commonShowEmptyIcon(self.scroll_container2, false)
    -- end
    self.item_scrollview:reloadData()
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function AdventureMineMyInfoPanel:createNewCell(width, height)
   local cell = AdventureMineEmployItem.new(width, height, self)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function AdventureMineMyInfoPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function AdventureMineMyInfoPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end


function AdventureMineMyInfoPanel:updateMineList()
    if self.mine_item_scrollview == nil then
        local scroll_view_size = self.scroll_container1:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 203,                -- 单元的尺寸width
            item_height = 268,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.mine_item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container1, cc.p(0,0) , ScrollViewDir.horizontal, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.mine_item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCellMine), ScrollViewFuncType.CreateNewCell) --创建cell
        self.mine_item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCellsMine), ScrollViewFuncType.NumberOfCells) --获取数量
        self.mine_item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndexMine), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.mine_item_scrollview:registerScriptHandlerSingle(handler(self,self.onCellTouchedMine), ScrollViewFuncType.OnCellTouched) --更新cell
        self.mine_item_scrollview:setClickEnabled(false)
    end
    

    if #self.mine_List == 0 then
        commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无数据")})
    else
        commonShowEmptyIcon(self.scroll_container, false)
    end
    if self.select_index then
        self.mine_item_scrollview:reloadData(self.select_index)
    else
        self.mine_item_scrollview:reloadData(1)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function AdventureMineMyInfoPanel:createNewCellMine(width, height)
   local cell = AdventureMineMineMyInfoItem.new(width, height, self)
    cell:addCallBack(function() self:onCellTouchedMine(cell) end)
    return cell
end
--获取数据数量
function AdventureMineMyInfoPanel:numberOfCellsMine()
    if not self.mine_List then return 0 end
    return #self.mine_List
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function AdventureMineMyInfoPanel:updateCellByIndexMine(cell, index)
    cell.index = index
    local cell_data = self.mine_List[index]
     local my_mine_data = self.my_mine_list[index]
    if not cell_data then return end

    local time_desc = cell:setData(cell_data, my_mine_data)
    self.time_desc_list[index] = time_desc
    self:updateTimeByIndex(index, time_desc)
end

function AdventureMineMyInfoPanel:onCellTouchedMine(cell)
    local index = cell.index
    local my_mine_data = self.my_mine_list[index]
    if my_mine_data == nil then
        return
    end

    if self.select_cell then
        -- self.select_cell:setSelected(false)
    end
    self.select_index = index
    self.select_cell = cell 
    self:showSelectEffect(cell)
    if self.select_cell then
        -- self.select_cell:setSelected(true)
    end

    if my_mine_data then
        self:updateEmployList(my_mine_data)
    end
end

function AdventureMineMyInfoPanel:showSelectEffect(cell)
    if not self.mine_item_scrollview then return end
    if not self.mine_item_scrollview.scroll_view then return end
    if self.select_effect == nil then
        self.select_effect = createEffectSpine("E23015", cc.p(0,0), cc.p(0.5, 0.5), true, PlayerAction.action)
        -- self.select_effect:setScale(1)
        self.mine_item_scrollview.scroll_view:addChild(self.select_effect, 1)
    end
    cell:setZOrder(2)
    local x = cell:getPositionX()
    if x < 0 then
        x = 102
    end
    self.select_effect:setPosition(x, 106)
end

function AdventureMineMyInfoPanel:removeSelectEffect()
    if self.select_effect then
        self.select_effect:setVisible(false)
        self.select_effect:removeFromParent()
        self.select_effect = nil
    end
end

function AdventureMineMyInfoPanel:startTimeTicket()
    if self.timeticket == nil then
        self:countDownEndTime()
        self.timeticket = GlobalTimeTicket:getInstance():add(function()
            self:countDownEndTime()
        end, 1)
    end
end

function AdventureMineMyInfoPanel:countDownEndTime()
    if self.mine_item_scrollview then
         for i,v in pairs(self.mine_item_scrollview.activeCellIdx) do
            if v and self.time_desc_list[i] then
                self:updateTimeByIndex(i, self.time_desc_list[i])
            end
        end
    end
end

function AdventureMineMyInfoPanel:updateTimeByIndex(index, time_desc)
    -- body 
    local my_mine_data = self.my_mine_list[index]
    if my_mine_data then
        if time_desc then
            local time = my_mine_data.give_up_time - GameNet:getInstance():getTime()
            if time < 0 then
                time = 0
                self.my_mine_list[index] = nil
                self:setData()
            end
            -- time_desc:setString(string_format("%s%s", TI18N("剩余"), TimeTool.getDayOrHour(time)))
            time_desc:setString(TimeTool.GetTimeFormatDayIIIIIIII(time))
        end
    end
end


function AdventureMineMyInfoPanel:close_callback()
    self:removeSelectEffect()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    if self.mine_item_scrollview then
        self.mine_item_scrollview:DeleteMe()
    end
    self.mine_item_scrollview = nil

    if self.timeticket then
        GlobalTimeTicket:getInstance():remove(self.timeticket)
        self.timeticket = nil
    end

    if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
        self.role_vo = nil
    end
    controller:openAdventureMineMyInfoPanel(false)
end


-- 子项 雇佣
AdventureMineEmployItem = class("AdventureMineEmployItem", function()
    return ccui.Widget:create()
end)

function AdventureMineEmployItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function AdventureMineEmployItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("adventure/adventure_mine_employ_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.icon = self.container:getChildByName("icon")
    self.count = self.container:getChildByName("count")
    self.name = self.container:getChildByName("name")

    self.desc = self.container:getChildByName("desc")

    --剩余次数
    self.times_lable = createRichLabel(20, cc.c4b(0x95,0x53,0x22,0xff), cc.p(1,0.5), cc.p(422, 86), 6, nil, 900)
    self.container:addChild(self.times_lable)

    self.goto_btn = self.container:getChildByName("goto_btn")
    self.goto_btn:getChildByName("label"):setString(TI18N("雇 佣"))
end

function AdventureMineEmployItem:register_event( )
    registerButtonEventListener(self.goto_btn, function() self:onGotoBtn()  end ,true, 1)
end

--雇佣
function AdventureMineEmployItem:onGotoBtn()
    if not self.data then return end
    if not self.parent then return end
    if self.parent.my_mine_list == nil or #self.parent.my_mine_list == 0 then
        message(TI18N("暂无占领灵矿"))
        return
    end
    if self.data.count <= 0 then
        message(TI18N("该矿工已无购买次数"))
        return 
    end
    if self.parent.select_index and self.parent.my_mine_list and self.parent.my_mine_list[self.parent.select_index] then
        local my_mine_data = self.parent.my_mine_list[self.parent.select_index]
        controller:send20654(my_mine_data.floor, my_mine_data.room_id, self.data.buy_type)
    end
end


--data
function AdventureMineEmployItem:setData(data)
    if not data then return end
    self.data = data

    if self.data.cost and next(self.data.cost) ~= nil then
        local item_id = Config.ItemData.data_assets_label2id.gold
        local item_config  = Config.ItemData.data_get_data(self.data.cost[1])
        if item_config then
            local res = PathTool.getItemRes(item_config.icon)
            loadSpriteTexture(self.icon, res, LOADTEXT_TYPE)
        end
        self.count:setString(self.data.cost[2]) 
    end

    self.name:setString(self.data.name)
    local str1 = string_format(TI18N("当前灵矿可采矿时间+%s分钟"), self.data.time)
    self.desc:setString(str1)

    local str = string_format(TI18N("剩余次数：<div fontcolor=#157e22>%s</div>"), self.data.count)
    self.times_lable:setString(str)
end

function AdventureMineEmployItem:DeleteMe()
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end


-- 子项
AdventureMineMineMyInfoItem = class("AdventureMineMineMyInfoItem", function()
    return ccui.Widget:create()
end)

function AdventureMineMineMyInfoItem:ctor(width, height, parent)
    self.parent = parent
    self:configUI(width, height)
    self:register_event()
end

function AdventureMineMineMyInfoItem:configUI(width, height)
    self.size = cc.size(width,height)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("adventure/adventure_mine_my_info_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self.root_wnd:setAnchorPoint(cc.p(0.5, 0.5))
    self.root_wnd:setPosition(width * 0.5, height * 0.5)
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")

    self.lock_img = self.container:getChildByName("lock_img")
    self.lock_label = self.container:getChildByName("lock_label")

    
    self.info_lay = self.container:getChildByName("info_lay")

    self.icon = self.info_lay:getChildByName("icon")
    self.item_name = self.info_lay:getChildByName("item_name")
    self.occupy_time = self.info_lay:getChildByName("occupy_time")
    self.emplay_count = self.info_lay:getChildByName("emplay_count")

    self.item_icon = self.info_lay:getChildByName("item_icon")
    self.item_count = self.info_lay:getChildByName("item_count")

    self.goto_btn = self.info_lay:getChildByName("goto_btn")
    self.goto_btn:getChildByName("label"):setString(TI18N("前 往"))
end

function AdventureMineMineMyInfoItem:register_event( )
    registerButtonEventListener(self.goto_btn, function() self:onGotoBtn()  end ,true, 1)
    registerButtonEventListener(self.container, function() 
        if self.callback then
            self.callback()
        end
      end ,false, 1)
end

--选择
function AdventureMineMineMyInfoItem:onGotoBtn()
    if not self.data then return end
    if not self.my_mine_data then return end
    if not self.parent then return end
    local base_data = model:getAdventureBaseData()
    if base_data and base_data.current_id ~= self.my_mine_data.floor then
        controller:requestEnterAdventureMine(self.my_mine_data.floor, {room_id = self.my_mine_data.room_id})
    else   
        local win = controller:getAdventureMineWindow()
        if win and win.gotoAdventureFloorRoom then
            win:gotoAdventureFloorRoom({room_id = self.my_mine_data.room_id})
        end
    end
    self.parent:onClickBtnClose()
end

function AdventureMineMineMyInfoItem:addCallBack(callback)
    self.callback = callback
end

--data
function AdventureMineMineMyInfoItem:setData(data, my_mine_data)
    if not data then return end
    self.data = data
    self.my_mine_data = my_mine_data

    if self.data.lock_sort == 1 then --未解锁
        self.info_lay:setVisible(false)
        self.lock_img:setVisible(true)
        self.lock_label:setVisible(true)
        self.lock_label:setString(self.data.lock_str or "")
    else
        if self.my_mine_data == nil then
             self.info_lay:setVisible(false)
            self.lock_img:setVisible(false)
            self.lock_label:setVisible(false)
        else
            self.info_lay:setVisible(true)

            self.lock_img:setVisible(false)
            self.lock_label:setVisible(false)
            self.mine_config = my_mine_data.config or Config.AdventureMineData.data_mine_data(110031)
            if not self.mine_config then return end

            local res_id = self.mine_config.res_id
            local res = PathTool.getPlistImgForDownLoad("adventure/mine_icon", res_id, false)
            if self.record_res == nil or self.record_res ~= res then
                self.record_res = res
                self.item_load = loadSpriteTextureFromCDN(self.icon, res, ResourcesType.single, self.item_load) 
            end
            self.item_name:setString(self.mine_config.name)

            local h = (self.parent.primary_time * self.my_mine_data.primary_count + self.parent.senior_time * self.my_mine_data.senior_count)/60
            h = math.floor(h * 10)/10
            self.emplay_count:setString(string_format("+%sh", h))

            if next(self.mine_config.hook_items) ~= nil then
                local item_id = self.mine_config.hook_items[1][1]
                local item_config  = Config.ItemData.data_get_data(item_id)
                local res = PathTool.getItemRes(item_config.icon)
                loadSpriteTexture(self.item_icon, res, LOADTEXT_TYPE)
                local count = model:getMineRate(my_mine_data.floor, self.mine_config.hook_items[1][2])
                if count < 0 then
                    count = 0
                end
                self.item_count:setString(count.."/m")
            end
            return self.occupy_time
        end
    end 
end

function AdventureMineMineMyInfoItem:DeleteMe()
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end