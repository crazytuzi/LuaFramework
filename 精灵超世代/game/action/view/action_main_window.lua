-- --------------------------------------------------------------------
-- 活动主界面
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 
-- --------------------------------------------------------------------
ActionMainWindow = ActionMainWindow or BaseClass(BaseView)

local controller = ActionController:getInstance() 
local model = ActionController:getInstance():getModel()

function ActionMainWindow:__init(ctrl)
    self.is_full_screen = true
    self.win_type = WinType.Full  
    self.layout_name = "welfare/welfare_main_view"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg", true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("welfare","welfare"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("welfaretab","welfaretab"), type = ResourcesType.plist},
    }

    self.panel_list = {}
    self.tab_list = {}
    self.tab_width = 78
    self.off_space = 80
    self.selected_tab = nil
end

function ActionMainWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        loadSpriteTexture(self.background, PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg", true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    self.main_container = self.root_wnd:getChildByName("main_container")
    --self.main_container:setPositionY(display.getTop())

    local main_panel = self.main_container:getChildByName("main_panel")
    self.container = main_panel:getChildByName("container")

    local tab_container = self.root_wnd:getChildByName("tab_container")
    self.close_btn = tab_container:getChildByName("close_btn")
    local bottom_height = MainuiController:getInstance():getMainUi():getBottomHeight()
    self.close_btn:setPositionY(display.getBottom()+bottom_height+25)

    local scroll_container = self.root_wnd:getChildByName("scroll_container")
    scroll_container:setPositionY(display.getTop())
    self.tab_scroll = createScrollView(scroll_container:getContentSize().width,scroll_container:getContentSize().height,0,0,scroll_container,ccui.ScrollViewDir.horizontal)
end

function ActionMainWindow:register_event()
    registerButtonEventListener(self.close_btn, function()
        controller:openActionMainPanel(false)
    end,true, 2)

    self:addGlobalEvent(ActionEvent.UPDATE_HOLIDAY_TAB_STATUS, function(function_id, vo)
        if function_id ~= self.function_id then return end
        self:setTabStatus(vo.bid)
    end)

    self:addGlobalEvent(ActionEvent.SHOW_ACTIVITY_RED_POINT, function(bid, status)
        self:setSpecialTabStatus(bid, status)
    end)
end

function ActionMainWindow:openRootWnd( function_id, action_bid)
	function_id = function_id or MainuiConst.icon.action
    self.function_id = function_id
    self.sub_list = controller:getActionSubList(self.function_id)
    self.action_bid = action_bid
    self:createSubType()
end

function ActionMainWindow:createSubType(  )
	if self.sub_list ~= nil and next(self.sub_list) ~= nil then
        local sum = #self.sub_list
        local max_width = sum * (self.tab_width + self.off_space) + self.off_space * 2
        self.max_width = math.max(self.tab_scroll:getContentSize().width,max_width)
        self.tab_scroll:setInnerContainerSize(cc.size(self.max_width,self.tab_scroll:getContentSize().height))

        local function call_back(item)
            self:handleSelectedTab(item)
        end
        local index_selected = 0
        local tab_item, _x, _y, data = nil, 2
        for i=1,sum do
            data = self.sub_list[i]
            if data ~= nil and data.bid ~= nil and self.tab_list[data.bid] == nil then
                tab_item = WelfareTab.new()
                tab_item:setData(data)
                _x = self.off_space+(i-1)*(self.tab_width+self.off_space)
                tab_item:setPosition(_x,110)
                tab_item:setClickCallBack(call_back)
                tab_item:setSelecte(false)
                self.tab_scroll:addChild(tab_item)
                self.tab_list[data.bid] = tab_item
                if self.action_bid ~= nil then
                    if self.action_bid == data.bid then
                        index_selected = i
                    end
                end
                -- 设置红点状态
                self:setTabStatus(data.bid)
            end
        end

        if index_selected == 0 then
            index_selected = 1
        end
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

function ActionMainWindow:handleSelectedTab( tab )
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


function ActionMainWindow:changePanelByTab(  )

	if self.selected_tab == nil or self.selected_tab.data == nil then return end
    local data = self.selected_tab.data
    if data.bid == nil or data.bid == 0 then return end
    if data.bid and data.bid == ActionRankCommonType.ouqi_gift then
        --特殊处理
        controller:openOuqiGiftTips()
        return
    end
    if data.panel_type == nil or data.panel_type == 0 or ActionPanelTypeView[data.panel_type] == nil then return end
    if self.selected_panel ~= nil then
        if self.selected_panel.setVisibleStatus then
            self.selected_panel:setVisibleStatus(false)
        else
            self.selected_panel:setVisible(false)
        end
        self.selected_panel = nil
    end

    if self.panel_list[data.bid] == nil then
        local view_str = ActionPanelTypeView[data.panel_type]
        if _G[view_str] then
            self.panel_list[data.bid] = (_G[view_str]).new(data.bid, self.function_id)
            self.container:addChild(self.panel_list[data.bid])
        end
    end
    self.selected_panel = self.panel_list[data.bid]
    if self.selected_panel then
        if self.selected_panel.setVisibleStatus then
            self.selected_panel:setVisibleStatus(true)
        else
            self.selected_panel:setVisible(true)
        end
    end
end

function ActionMainWindow:setTabStatus( bid )
	local vo = controller:getHolidayAweradsStatus(bid)
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
    --特殊活动红点
    local status = model:getGiftRedStatusByBid(bid)
    self:setSpecialTabStatus(bid, status)
end

function ActionMainWindow:isSpecialTabByBid(bid)
    return bid == ActionRankCommonType.high_value_gift or bid == ActionRankCommonType.mysterious_store --or bid == ActionRankCommonType.ouqi_gift 
end

function ActionMainWindow:setSpecialTabStatus(bid, status)
    if self.specail_tab_status and self.specail_tab_status == status then
        return
    end
    self.specail_tab_status = status

    if self:isSpecialTabByBid(bid) then
        local tab_item = self.tab_list[bid]
        if tab_item == nil then return end
        if not status then
            if tab_item.updateTipsStatus then
                tab_item:updateTipsStatus(false)
            end
        else
            if tab_item.updateTipsStatus then
                tab_item:updateTipsStatus(true)
            end
        end
    end
end

function ActionMainWindow:close_callback()
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
    controller:openActionMainPanel(false)
end
