--******** 文件说明 ********
-- @Author:      xhj 
-- @description: 回归活动主界面
-- @DateTime:    2019-12-13 15:12:06
-- *******************************
ReturnActionMainWindow = ReturnActionMainWindow or BaseClass(BaseView)

local controller = ReturnActionController:getInstance()
local model = controller:getModel()

function ReturnActionMainWindow:__init(ctrl)
    self.is_full_screen = true
    self.win_type = WinType.Full
    self.layout_name = "returnaction/returnaction_main_window"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg_1"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("returnaction","returnaction"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("welfaretab","welfaretab"), type = ResourcesType.plist},
    }

    self.panel_list = {}
    self.tab_list = {}
    self.tab_width = 78
    self.off_space = 50
    self.selected_tab = nil
end

function ReturnActionMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        loadSpriteTexture(self.background, PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg"), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container:setPositionY(display.getTop()-196)

    local main_panel = self.main_container:getChildByName("main_panel")
    self.container = main_panel:getChildByName("container")
    self.tab_sprite_bg = main_panel:getChildByName("tab_sprite_bg")
    loadSpriteTexture(self.tab_sprite_bg, PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg_1"), LOADTEXT_TYPE)

    local tab_container = self.root_wnd:getChildByName("tab_container")
    self.close_btn = tab_container:getChildByName("close_btn")
    local bottom_height = MainuiController:getInstance():getMainUi():getBottomHeight()
    self.close_btn:setPositionY(display.getBottom()+bottom_height+25)

    local scroll_container = self.root_wnd:getChildByName("scroll_container")
    scroll_container:setPositionY(display.getTop())
    local top_sprite1 = scroll_container:getChildByName("top_sprite1")
    top_sprite1:setLocalZOrder(10)
    local top_sprite2 = scroll_container:getChildByName("top_sprite2")
    top_sprite2:setLocalZOrder(10)
    self.tab_scroll = createScrollView(scroll_container:getContentSize().width,scroll_container:getContentSize().height,0,0,scroll_container,ccui.ScrollViewDir.horizontal)
end

function ReturnActionMainWindow:register_event()
    registerButtonEventListener(self.close_btn, function()
        controller:openReturnActionMainPanel(false)
    end,true, 2)

    self:addGlobalEvent(ReturnActionEvent.RedPoint_Event, function(vo)
        self:setTabStatus(vo.bid)
    end)
end

function ReturnActionMainWindow:openRootWnd(action_bid)
	local period = model:getActionPeriod()
	local day = model:getActionDay()

 	self.sub_list = model:getActionSubList(period, day)
    self.action_bid = action_bid
    self:createSubType()
end

function ReturnActionMainWindow:createSubType()
	if self.sub_list ~= nil and next(self.sub_list) ~= nil then
        local sum = #self.sub_list
        local max_width = sum * (self.tab_width + self.off_space) + self.off_space * 2
        max_width = math.max(self.tab_scroll:getContentSize().width,max_width)
        self.tab_scroll:setInnerContainerSize(cc.size(max_width,self.tab_scroll:getContentSize().height))

        local function call_back(item)
            self:handleSelectedTab(item)
        end
        local index_selected = 0
        local tab_item, _x, _y, data = nil, 2
        for i=1,sum do
            data = self.sub_list[i]
            if data ~= nil and data.camp_id ~= nil and self.tab_list[data.camp_id] == nil then
                tab_item = WelfareTab.new()
                tab_item:setData(data)
                _x = self.off_space+(i-1)*(self.tab_width+self.off_space)
                tab_item:setPosition(_x,79)
                tab_item:setClickCallBack(call_back)
                self.tab_scroll:addChild(tab_item)
                self.tab_list[data.camp_id] = tab_item
                if self.action_bid ~= nil then
                    if self.action_bid == data.camp_id then
                        index_selected = i
                    end
                end
                -- 设置红点状态
                self:setTabStatus(data.camp_id)
            end
        end

        if index_selected == 0 then
            index_selected = 1
        end
        -- 手动设置选中第一个
        data = self.sub_list[index_selected]
        if data ~= nil then
            if index_selected and index_selected ~= 1 then
            end
            self:handleSelectedTab(self.tab_list[data.camp_id])
        end
    end
end

function ReturnActionMainWindow:handleSelectedTab(tab)
	if self.selected_tab ~= nil and self.selected_tab == tab then return end
    if self.selected_tab ~= nil then
        self.selected_tab:setSelecte(false)
    end
    self.selected_tab = tab
    if self.selected_tab ~= nil then
        self.selected_tab:setSelecte(true)
    end
    self:changePanelByTab()
end

function ReturnActionMainWindow:changePanelByTab()
	if self.selected_tab == nil or self.selected_tab.data == nil then return end
    
    local data = self.selected_tab.data
    if data.camp_id == nil or data.camp_id == 0 then return end
    if data.panel_type == nil or data.panel_type == 0 or ReturnActionPanelTypeView[data.panel_type] == nil then return end
    if self.selected_panel ~= nil then
        if self.selected_panel.setVisibleStatus then
            self.selected_panel:setVisibleStatus(false)
        else
            self.selected_panel:setVisible(false)
        end
        self.selected_panel = nil
    end

    if self.panel_list[data.camp_id] == nil then
        local view_str = ReturnActionPanelTypeView[data.panel_type]
        if _G[view_str] then
            self.panel_list[data.camp_id] = (_G[view_str]).new(data.camp_id)--, self.function_id)
            self.container:addChild(self.panel_list[data.camp_id])
        end
    end
    self.selected_panel = self.panel_list[data.camp_id]
    
    if self.selected_panel.setVisibleStatus then
        self.selected_panel:setVisibleStatus(true)
    else
        self.selected_panel:setVisible(true)
    end
end

function ReturnActionMainWindow:setTabStatus(bid)
	local vo = controller:getRedPointStatusData(bid)
    local tab_item = self.tab_list[bid]
    if tab_item == nil then return end
    if vo == nil or vo.status == false then
        if tab_item.updateTipsStatus then
            tab_item:updateTipsStatus(false)
        end
    else
        if tab_item.updateTipsStatus then
            tab_item:updateTipsStatus(true)
        end
    end
end

function ReturnActionMainWindow:close_callback()
    CommonAlert.closeAllWin()
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
    controller:openReturnActionMainPanel(false)
end

