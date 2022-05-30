-- --------------------------------------------------------------------
-- 周活动主界面
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
WeeklyActivitiesMainWindow = WeeklyActivitiesMainWindow or BaseClass(BaseView)

local controller = WeeklyActivitiesController:getInstance()
local model = controller:getModel()
local action_controller = ActionController:getInstance()

function WeeklyActivitiesMainWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full  
    self.layout_name = "weeklyactivity/weekly_activity_view"    
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg", true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg_1"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_tab"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("welfare","welfare"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("welfaretab","welfaretab"), type = ResourcesType.plist},
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_fund_bg_1",true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_fund_bg_2",true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("actionfund","actionfund"), type = ResourcesType.plist },
    } 

    self.tab_list = {}
    self.tab_width = 78
    self.off_space = 80
    self.panel_list = {}
    self.selected_tab = nil 
    self.selected_panel = nil
end

function WeeklyActivitiesMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        loadSpriteTexture(self.background, PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg", true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    --self.main_container:setPositionY(display.getTop())
    --self.main_container:setContentSize(cc.size(SCREEN_WIDTH, SCREEN_HEIGHT))
    local main_panel = self.main_container:getChildByName("main_panel")
    self.container = main_panel:getChildByName("container")

    local tab_container = self.root_wnd:getChildByName("tab_container")
    self.close_btn = tab_container:getChildByName("close_btn")
    local bottom_height = MainuiController:getInstance():getMainUi():getBottomHeight()
    self.close_btn:setPositionY(display.getBottom()+bottom_height+25)

    local scroll_container = self.root_wnd:getChildByName("scroll_container")
    local sprite_tab = scroll_container:getChildByName("sprite_tab")
    loadSpriteTexture(sprite_tab, PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_tab"), LOADTEXT_TYPE)

    --scroll_container:setPositionY(display.getTop())
    self.tab_scroll = createScrollView(scroll_container:getContentSize().width,scroll_container:getContentSize().height,0,0,scroll_container,ccui.ScrollViewDir.horizontal)

    self:adaptationScreen()


    ---controller:send_12900( 56,1,50)
    ---controller:send_29200()
end

function WeeklyActivitiesMainWindow:adaptationScreen()

end

function WeeklyActivitiesMainWindow:openRootWnd(bid)

    --self.sub_list = controller:getWelfareSubList()                   
    --self.auto_bid = bid or WelfareIcon.sign
    self:createSubType()
    self:updateTabsStatus()
    --ActionController:getInstance():sender24700()
end

function WeeklyActivitiesMainWindow:changePanelByIndex(index)
    local index_selected = index
    self.index_selected = index
    print("index ",index)
    -- 手动设置选中第一个
    if  self.sub_list == nil then return end
    local data = self.sub_list[index_selected]
    if data ~= nil then
        local sum = #self.sub_list
        if index_selected and index_selected ~= 1 then
            self.tab_scroll:scrollToPercentHorizontal(math.ceil(100*index_selected/sum),1,true)
        end
        self:handleSelectedTab(self.tab_list[data.bid])
    end
end

function WeeklyActivitiesMainWindow:createSubType()
    local config = Config.WeekActData.data_info
    --dump(config, "-------------------6798787")
    if config then
        local activity_id = model:getWeeklyActivityId()
        print("activity_id",activity_id)
        local tmp_table = {}
        for i,v in pairs(config) do
            if v.action_type == activity_id or v.action_type == 0 then
                table.insert(tmp_table,v)
            end
        end
        --如果有往期兑换活动数据
        --local exchange_data = WeeklyActivitiesController:getInstance():getModel():getExchangeData()
        --if #exchange_data > 1 then
        --    for _,data in pairs(exchange_data) do
        --        if data.activity_id ~= activity_id then
        --            self:insertExchangeCfg(tmp_table, data.activity_id)
        --        end
        --    end
        --end
        table.sort(tmp_table,function(a, b) return a.sort_val < b.sort_val end)
        self.sub_list = tmp_table
        self:createSubType1()
    end
end

function WeeklyActivitiesMainWindow:insertExchangeCfg(temp_table, activity_id)
    local config = Config.WeekActData.data_info
    local index = 0
    if activity_id == 1 then
        index = 11008
    elseif activity_id == 2 then
        index = 11004
    else
        index = 11012
    end
    if config[index] ~= nil then
        table.insert(temp_table, config[index])
    end
    return temp_table
end

function WeeklyActivitiesMainWindow:createSubType1()
    if self.sub_list == nil or next(self.sub_list) == nil then

    else

        local sum = #self.sub_list
        local max_width = sum * (self.tab_width + self.off_space) + self.off_space
        self.max_width = math.max(self.tab_scroll:getContentSize().width,max_width)
        self.tab_scroll:setInnerContainerSize(cc.size(self.max_width,self.tab_scroll:getContentSize().height))

        local function call_back(item)
            --if item:getData().bid == WelfareIcon.quest then
            --    --WelfareController:getInstance():openSureveyQuestView(true)
            --else
                self:handleSelectedTab(item)
            --end
        end
        local index_selected = 0
        local tab_item, _x, _y, data = nil, 2

        for i=1,sum do
            data = self.sub_list[i]
            if data ~= nil and data.bid ~= nil and self.tab_list[data.bid] == nil then
                tab_item = WeeklyActivityTab.new()
                tab_item:setData(data)
                _x = self.off_space+(i-1)*(self.tab_width+self.off_space)
                tab_item:setPosition(_x,110)
                tab_item:setClickCallBack(call_back)
                tab_item:setSelecte(false)
                self.tab_scroll:addChild(tab_item)
                self.tab_list[data.bid] = tab_item
                tab_item:updateTipsStatus(false)
                if self.auto_bid ~= nil then
                    if self.auto_bid == data.bid then
                        index_selected = i
                    end
                end
                -- 设置红点状态
                --self:setTabStatus(data.bid,true)
                --print("-----------红点id------22----->>",data.bid)
            end
        end

        if index_selected == 0 then
            index_selected = 1
        end
        if self.index_selected then index_selected = self.index_selected end
        -- 手动设置选中第一个
        data = self.sub_list[index_selected]
        if data ~= nil then
            if index_selected and index_selected ~= 1 then
                self.tab_scroll:scrollToPercentHorizontal(math.ceil(100*index_selected/sum),1,true)
            end
            self:handleSelectedTab(self.tab_list[data.bid])
        end
    end
end

--刷新所有Tab红点状态
function WeeklyActivitiesMainWindow:updateTabsStatus()
    if not self.sub_list then return end
    for i,v in pairs(self.sub_list) do
        local status = controller:getTipsStatus(i)
        self:setTabStatus(i,status)
    end
end

--==============================--
--desc:设置标签页红点状态
--time:2017-08-31 03:25:54
--@bid:
--@return 
--==============================--
function WeeklyActivitiesMainWindow:setTabStatus(index,status)
    local data = self.sub_list[index]
    local tab_item = self.tab_list[data.bid]
    if tab_item == nil then return end
    local status = status or false
    tab_item:updateTipsStatus(status)
end

function WeeklyActivitiesMainWindow:handleSelectedTab(tab)

    if self.selected_tab ~= nil and self.selected_tab == tab then return end
    if self.selected_tab ~= nil then
        self.selected_tab:setSelecte(false)
    end
    --WeeklyActivitiesTypeView[self.selected_tab.data.panel_type]

    if self.selected_tab and self.panel_list and self.panel_list[self.selected_tab.data.bid] then
        --dump(self.panel_list[self.selected_tab.data.bid], "7634587345------------------>>")
        self.panel_list[self.selected_tab.data.bid]:setVisible(false)
    end

    self.selected_tab = tab
    if self.selected_tab ~= nil then
        self.selected_tab:setSelecte(true)
    end
   -- print("uiyyuityuwi7rtyuwiertywuiye----------------------------->>")
    self:changePanelByTab()
end

function WeeklyActivitiesMainWindow:changePanelByTab()
    if self.selected_tab == nil or self.selected_tab.data == nil then return end

    local data = self.selected_tab.data
    --if data.bid == nil or data.bid == 0 then return end
    if data.panel_type == nil or data.panel_type == 0 or WeeklyActivitiesTypeView[data.panel_type] == nil then return end
    --if data.bid == WelfareIcon.subscribe then   --点击订阅预览按钮取消红点
    --    controller:sender10988()
    --end

    if self.selected_panel ~= nil then
        if self.selected_panel.setVisibleStatus then
            self.selected_panel:setVisibleStatus(false)
        else
            self.selected_panel:setVisible(false)
        end
        self.selected_panel = nil
    end

    if self.panel_list[data.bid] == nil then
        local view_str = WeeklyActivitiesTypeView[data.panel_type]
        if _G[view_str] then
            self.panel_list[data.bid] = (_G[view_str]).new(data.bid)
            self.container:addChild(self.panel_list[data.bid])
        end
    end
    self.selected_panel = self.panel_list[data.bid]
    self.selected_panel:setVisible(true)
    if self.selected_panel and self.selected_panel.setVisibleStatus then
        self.selected_panel:setVisibleStatus(true)
    end
end

function WeeklyActivitiesMainWindow:register_event(  )
    registerButtonEventListener(self.close_btn, function()
        controller:openMainWindow(false)
    end,true, 2)

    self:addGlobalEvent(WelfareEvent.UPDATE_WELFARE_TAB_STATUS, function(vo)
        --self:setTabStatus(vo.bid)
    end)
    self:addGlobalEvent(ActionEvent.UPDATE_HOLIDAY_TAB_STATUS, function(function_id, vo)
        if not action_controller:isSpecialBid(vo.bid) then return end
        --self:setTabStatus(vo.bid)
    end)
end

function WeeklyActivitiesMainWindow:close_callback()
    for k,v in pairs(self.panel_list) do
        if v.DeleteMe then
            v:DeleteMe()
        end
    end
    self.panel_list = nil

    for k,v in pairs(self.tab_list) do
        if v.DeleteMe then
            v:DeleteMe()
        end
    end
    self.tab_list = nil    
    controller:openMainWindow(false)
end

