-- --------------------------------------------------------------------
-- 福利主界面
--
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: {DATE}
-- --------------------------------------------------------------------
WelfareMainWindow = WelfareMainWindow or BaseClass(BaseView)

local controller = WelfareController:getInstance()
local model = controller:getModel()
local action_controller = ActionController:getInstance()

function WelfareMainWindow:__init()
    self.is_full_screen = true
    self.win_type = WinType.Full  
    self.layout_name = "welfare/welfare_main_view"    
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

function WelfareMainWindow:open_callback()
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
end

function WelfareMainWindow:adaptationScreen()

end

function WelfareMainWindow:openRootWnd(bid)
    self.sub_list = controller:getWelfareSubList()
    dump(self.sub_list, "福利的原数据---------------》》")
    self.auto_bid = bid or WelfareIcon.sign
    self:createSubType()
    ActionController:getInstance():sender24700()
end

function WelfareMainWindow:createSubType()
	if self.sub_list == nil or next(self.sub_list) == nil then

    else
        local sum = #self.sub_list
        local max_width = sum * (self.tab_width + self.off_space) + self.off_space
        self.max_width = math.max(self.tab_scroll:getContentSize().width,max_width)
        self.tab_scroll:setInnerContainerSize(cc.size(self.max_width,self.tab_scroll:getContentSize().height))

        local function call_back(item)
            if item:getData().bid == WelfareIcon.quest then
                WelfareController:getInstance():openSureveyQuestView(true)
            else
                self:handleSelectedTab(item)
            end
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
                if self.auto_bid ~= nil then
                    if self.auto_bid == data.bid then
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

--==============================--
--desc:设置标签页红点状态
--time:2017-08-31 03:25:54
--@bid:
--@return 
--==============================--
function WelfareMainWindow:setTabStatus(bid)
    local vo = controller:getWelfareStatusByID(bid)
    if action_controller:isSpecialBid(bid) then
        vo = action_controller:getHolidayAweradsStatus(bid) 
    end
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

function WelfareMainWindow:handleSelectedTab(tab)
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

function WelfareMainWindow:changePanelByTab()
    if self.selected_tab == nil or self.selected_tab.data == nil then return end

    local data = self.selected_tab.data
    if data.bid == nil or data.bid == 0 then return end
    if data.panel_type == nil or data.panel_type == 0 or WelfarePanelTypeView[data.panel_type] == nil then return end
    if data.bid == WelfareIcon.subscribe then   --点击订阅预览按钮取消红点
        controller:sender10988()
    end

    if self.selected_panel ~= nil then
        if self.selected_panel.setVisibleStatus then
            self.selected_panel:setVisibleStatus(false)
        else
            self.selected_panel:setVisible(false)
        end
        self.selected_panel = nil
    end

    if self.panel_list[data.bid] == nil then
        local view_str = WelfarePanelTypeView[data.panel_type]
        if _G[view_str] then
            self.panel_list[data.bid] = (_G[view_str]).new(data.bid)
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

function WelfareMainWindow:register_event(  )
    registerButtonEventListener(self.close_btn, function()
        controller:openMainWindow(false)
    end,true, 2)

    self:addGlobalEvent(WelfareEvent.UPDATE_WELFARE_TAB_STATUS, function(vo)
        self:setTabStatus(vo.bid)
    end)
    self:addGlobalEvent(ActionEvent.UPDATE_HOLIDAY_TAB_STATUS, function(function_id, vo)
        if not action_controller:isSpecialBid(vo.bid) then return end
        self:setTabStatus(vo.bid)
    end)
end

function WelfareMainWindow:close_callback()
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

