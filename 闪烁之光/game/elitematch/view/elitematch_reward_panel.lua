-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      经验赛奖励预览
-- <br/> 2019年3月1日
-- --------------------------------------------------------------------
ElitematchRewardPanel = ElitematchRewardPanel or BaseClass(BaseView)

local controller = ElitematchController:getInstance()
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort


function ElitematchRewardPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "elitematch/elitematch_reward_panel"

    self.res_list = {
     -- { path = PathTool.getPlistImgForDownLoad("form","form"), type = ResourcesType.plist },
    }

    --奖励
    self.dic_reward_list = {}
    self.show_list = {}
end

function ElitematchRewardPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.tab_container = self.main_panel:getChildByName("tab_container")
    local tab_name_list = {
        [1] = TI18N("首达奖励"),
        [2] = TI18N("段位奖励"),
        -- [3] = TI18N("王者排名"),
    }
    self.tab_list = {}
    for i=1,2 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.title = tab_btn:getChildByName("title")
            object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
            if tab_name_list[i] then
                object.title:setString(tab_name_list[i])
            end
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end
    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("奖励预览"))


    self.col_name_list = {
        [1] = {TI18N("段位"), TI18N("奖励")},
        [2] = {TI18N("段位"), TI18N("奖励")},
        [3] = {TI18N("排名"), TI18N("奖励")},
    }
    self.col_name_label = {}
    for i=1,2 do
        self.col_name_label[i] = self.main_panel:getChildByName("col_name"..i)
    end

    self.scroll_container = self.main_panel:getChildByName("scroll_container")

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.top_label = self.main_panel:getChildByName("top_label")
    self.bottom_label = self.main_panel:getChildByName("bottom_label")
    self.bottom_left_label = self.main_panel:getChildByName("bottom_left_label")
end

function ElitematchRewardPanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickBtnClose) ,false, 1)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 2)
    -- --添加英雄升星成功返回
    -- self:addGlobalEvent(HeroEvent.Next_Break_Info_Event, function(next_data) 
    --     if not next_data then return end
    --     if not self.hero_vo then return end
    --     self:setData(self.hero_vo,next_data)
    -- end)

    for k, object in pairs(self.tab_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(object.index)
                end
            end)
        end
    end
end

--关闭
function ElitematchRewardPanel:onClickBtnClose()
    controller:openElitematchRewardPanel(false)
end


-- 切换标签页
function ElitematchRewardPanel:changeSelectedTab( index )
    if self.tab_object ~= nil and self.tab_object.index == index then return end
    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.title:setTextColor(cc.c4b(0xcf, 0xb5, 0x93, 0xff))
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.title:setTextColor(cc.c4b(0xff, 0xed, 0xd6, 0xff))
    end

    if self.col_name_list[index] then
        for i,label in ipairs(self.col_name_label) do
            if self.col_name_list[index][i] then
                label:setString(self.col_name_list[index][i])
            end         
        end
    end
    local config  = Config.ArenaEliteData.data_elite_level[self.level_id]
    if index == 1 then
        self.top_label:setString(TI18N("每个赛季首次提升对应段位可手动领取"))
        if config then
            self.bottom_label:setString(TI18N("当前你的段位为:")..config.name)
        end
        self.bottom_left_label:setString("")
    elseif index == 2 then
        self.top_label:setString(TI18N("分别在上,下赛季结束后发放"))
        if config then
            self.bottom_label:setString(TI18N("当前你的段位为:")..config.name)
        end
        self.bottom_left_label:setString("")
    -- else
    --     self.top_label:setString(TI18N("分别在上,下赛季结束后发放"))
    --     if self.rank == 0 then
    --         self.bottom_label:setString(TI18N("未上榜"))
    --     else
    --         self.bottom_label:setString(TI18N("当前你的排名: ")..self.rank)
    --     end
    --     self.bottom_left_label:setString(TI18N("结算时到达“超凡王者”段位可领取"))
    end
    --数据
    self:updateList(index)
end

--@level_id 段位
--@rank 名次
function ElitematchRewardPanel:openRootWnd(index, level_id, rank)
    local index = index or 1
    self.level_id = level_id or 1
    self.rank = rank or 0
    self:initData()
    self:changeSelectedTab(index)
end

function ElitematchRewardPanel:initData()

    self.dic_reward_list[1] = {}
    self.dic_reward_list[2] = {}
    self.dic_reward_list[3] = {}

    local config_list = Config.ArenaEliteData.data_elite_level
    if config_list then
        for k,v in pairs(config_list) do
            local item1 = {}
            item1.id = v.id
            item1.reward = v.lev_award
            item1.config = v
            if #v.lev_award > 0 then
                table_insert(self.dic_reward_list[1], item1)
            end
            local item2 = {}
            item2.id = v.id
            item2.reward = v.award_client
            item2.config = v
            if #v.award > 0 then
                table_insert(self.dic_reward_list[2], item2)
            end
        end
    end
    table_sort(self.dic_reward_list[1] , function(a,b) return a.id > b.id end)
    table_sort(self.dic_reward_list[2] , function(a,b) return a.id > b.id end)

    --排行榜的
    -- local config_rank = Config.ArenaEliteData.data_elite_rank_reward
    -- if config_rank then
    --     for k,v in pairs(config_rank) do
    --         local item = {}
    --         item.id = v.min_rank
    --         item.reward = v.show_award
    --         item.name = string_format("%s-%s", v.min_rank, v.max_rank)
    --         table_insert(self.dic_reward_list[3], item)
    --     end
    -- end
    -- table_sort(self.dic_reward_list[3] , function(a,b) return a.id < b.id end)
end

function ElitematchRewardPanel:updateList(index)
    if not index then return end
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 628,                -- 单元的尺寸width
            item_height = 138,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.show_list = self.dic_reward_list[index]
    self.item_scrollview:reloadData()
end


--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ElitematchRewardPanel:createNewCell(width, height)
   local cell = ElitematchRewardItem.new()
   -- cell:setActionRankCommonType(self.holiday_bid, self.type)
    -- cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function ElitematchRewardPanel:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ElitematchRewardPanel:updateCellByIndex(cell, index)
    cell.index = index
    local cell_data = self.show_list[index]
    if not cell_data then return end
    if not self.tab_object then return end
    cell:setData(cell_data, self.tab_object.index)
end


function ElitematchRewardPanel:close_callback()
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openElitematchRewardPanel(false)
end

------------------------------------------
-- 子项
ElitematchRewardItem = class("ElitematchRewardItem", function()
    return ccui.Widget:create()
end)

function ElitematchRewardItem:ctor()
    self:configUI()
    self:register_event()
end

function ElitematchRewardItem:configUI(  )
    self.size = cc.size(628,138)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)

    local csbPath = PathTool.getTargetCSB("elitematch/elitematch_reward_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.icon = container:getChildByName("icon")
    self.level_name = container:getChildByName("level_name")
    self.level_name2 = container:getChildByName("level_name2")
    self.item_scrollview = container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)

    self.setting = {}
    self.setting.scale = 0.8
    self.setting.max_count = 3
    
end

function ElitematchRewardItem:register_event( )
   
end

function ElitematchRewardItem:setData(data, tab_index)
    if not data then return end
    if not tab_index then return end
    self.data = data
    if tab_index == 3 then
        --排行榜
        self.icon:setVisible(true)
        self.level_name:setVisible(false)
        self.level_name2:setVisible(false)
        if data.id == 1 then
            local res = PathTool.getResFrame("common","common_2001")
            loadSpriteTexture(self.icon, res, LOADTEXT_TYPE_PLIST)
        elseif data.id == 2 then
            local res = PathTool.getResFrame("common","common_2002")
            loadSpriteTexture(self.icon, res, LOADTEXT_TYPE_PLIST)
        elseif data.id == 3 then
            local res = PathTool.getResFrame("common","common_2003")
            loadSpriteTexture(self.icon, res, LOADTEXT_TYPE_PLIST)
        else
            self.icon:setVisible(false)
            self.level_name:setVisible(true)
            self.level_name:setString(data.name)
        end
    else
        self.level_name:setVisible(false)
        self.level_name2:setVisible(true)
        --段位
        if data.config then
            self.level_name2:setString(data.config.name)
            self.icon:setVisible(true)
            local name = data.config.little_ico
            if name == nil or name == "" then
                name = "icon_iron"
            end
            local bg_res = PathTool.getPlistImgForDownLoad("elitematch/elitematch_icon",name, false)
            self.item_load = loadSpriteTextureFromCDN(self.icon , bg_res, ResourcesType.single, self.item_load)
        end
    end

    local reward = data.reward or {}
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, reward, self.setting)
end

function ElitematchRewardItem:DeleteMe( )
    if self.item_list then
        for i,v in ipairs(self.item_list) do
            v:DeleteMe()
        end
    end
    if self.item_load then
        self.item_load:DeleteMe()
        self.item_load = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end