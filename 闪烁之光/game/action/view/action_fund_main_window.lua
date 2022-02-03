--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-01-10 10:56:54
-- @description    : 
		-- 基金主界面
---------------------------------
ActionFundMainWindow = ActionFundMainWindow or BaseClass(BaseView)

local _controller = ActionController:getInstance() 
local _model = ActionController:getInstance():getModel()

function ActionFundMainWindow:__init(ctrl)
    self.is_full_screen = true
    self.win_type = WinType.Full  
    self.layout_name = "welfare/welfare_main_view"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg_1"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_tab"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_fund_bg_1",true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/action","txt_cn_action_fund_bg_2",true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("welfare","welfare"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("welfaretab","welfaretab"), type = ResourcesType.plist},
        { path = PathTool.getPlistImgForDownLoad("actionfund","actionfund"), type = ResourcesType.plist },
    }

    self.panel_list = {}
    self.tab_list = {}
    self.tab_width = 78
    self.off_space = 50
    self.selected_tab = nil
end

function ActionFundMainWindow:open_callback(  )
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
    local sprite_tab = scroll_container:getChildByName("sprite_tab")
    loadSpriteTexture(sprite_tab, PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_tab"), LOADTEXT_TYPE)

    scroll_container:setPositionY(display.getTop())
    local top_sprite1 = scroll_container:getChildByName("top_sprite1")
    top_sprite1:setLocalZOrder(10)
    local top_sprite2 = scroll_container:getChildByName("top_sprite2")
    top_sprite2:setLocalZOrder(10)
    self.tab_scroll = createScrollView(scroll_container:getContentSize().width,scroll_container:getContentSize().height,0,0,scroll_container,ccui.ScrollViewDir.horizontal)
end

function ActionFundMainWindow:register_event(  )
	registerButtonEventListener(self.close_btn, function()
        _controller:openActionFundWindow(false)
    end, true, 2)

    self:addGlobalEvent(ActionEvent.UPDATA_FUND_ID_LIST_EVENT, function( )
        self:updateTabBtns()
    end)

    self:addGlobalEvent(ActionEvent.UPDATA_FUND_RED_STATUS_EVENT, function( )
        self:updateTabRedStatus()
    end)
end

function ActionFundMainWindow:openRootWnd( fund_type )
    self.fund_type = fund_type or FundType.type_one
    self:updateTabBtns()
end

function ActionFundMainWindow:updateTabBtns(  )
    self.sub_list = {}

    local fund_id_list = _model:getOpenFundIds()
    for k,v in pairs(fund_id_list) do
        local config = Config.MonthFundData.data_fund_data[v.id]
        if config then
            local sub_data = {}
            sub_data.bid = v.id
            sub_data.title = config.name
            sub_data.ico = config.icon_id
            table.insert(self.sub_list, sub_data)
        end
    end
    table.sort(self.sub_list, SortTools.KeyLowerSorter("bid"))
    self:createSubType()
    self:updateTabRedStatus()
end

function ActionFundMainWindow:createSubType(  )
	if self.sub_list == nil or next(self.sub_list) == nil then
		return
	end

    for k,v in pairs(self.tab_list) do
        v:setVisible(false)
    end

    local sum = #self.sub_list
    local max_width = sum * (self.tab_width + self.off_space) + self.off_space
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
            tab_item:setPosition(_x,79)
            tab_item:setClickCallBack(call_back)
            self.tab_scroll:addChild(tab_item)
            self.tab_list[data.bid] = tab_item
            if self.fund_type ~= nil then
                if self.fund_type == data.bid then
                    index_selected = i
                end
            end
        end
        if tab_item then
            tab_item:setVisible(true)
        end
    end

    if index_selected == 0 then
        index_selected = 1
    end
    -- 手动设置选中第一个
    data = self.sub_list[index_selected]
    if data ~= nil then
        self:handleSelectedTab(self.tab_list[data.bid])
    end
end

function ActionFundMainWindow:handleSelectedTab( tab )
	if self.selected_tab ~= nil and self.selected_tab == tab then return end

    if self.selected_tab ~= nil then
        self.selected_tab:setSelecte(false)
    end
    self.selected_tab = tab
    if self.selected_tab ~= nil then
        self.selected_tab:setSelecte(true)
    end

    local data = self.selected_tab.data
    if data and data.bid then
        -- 点击标签页之后购买红点消失
        if data.bid == FundType.type_one then
            _model:updateFundRedStatus(FundRedIndex.fund_buy_one, false)
        elseif data.bid == FundType.type_two then
            _model:updateFundRedStatus(FundRedIndex.fund_buy_two, false)
        end
    end

    self:changePanelByTab()
end

function ActionFundMainWindow:changePanelByTab(  )
	if self.selected_tab == nil or self.selected_tab.data == nil then return end
    local data = self.selected_tab.data
    if data.bid == nil or data.bid == 0 then return end
    if self.selected_panel ~= nil then
        if self.selected_panel.setVisibleStatus then
            self.selected_panel:setVisibleStatus(false)
        else
            self.selected_panel:setVisible(false)
        end
        self.selected_panel = nil
    end

    if self.panel_list[data.bid] == nil then
        local panel_view
        if data.bid == FundType.type_one then
            panel_view = ActionFundOnePanel.new(data.bid)
        elseif data.bid == FundType.type_two then
            panel_view = ActionFundTwoPanel.new(data.bid)
        end
        if panel_view then
            self.panel_list[data.bid] = panel_view
            self.container:addChild(panel_view)
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

-- 更新标签页红点显示
function ActionFundMainWindow:updateTabRedStatus( )
    for bid,tab_item in pairs(self.tab_list) do
        local status = false
        if bid == FundType.type_one then
            status = _model:getFundRedStatusByBid(FundRedIndex.fund_get_one)
            if not status then
                status = _model:getFundRedStatusByBid(FundRedIndex.fund_buy_one)
            end
        elseif bid == FundType.type_two then
            status = _model:getFundRedStatusByBid(FundRedIndex.fund_get_two)
            if not status then
                status = _model:getFundRedStatusByBid(FundRedIndex.fund_buy_two)
            end
        end
        if tab_item.updateTipsStatus then
            tab_item:updateTipsStatus(status)
        end
    end
end

function ActionFundMainWindow:close_callback()
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
    _controller:openActionFundWindow(false)
end