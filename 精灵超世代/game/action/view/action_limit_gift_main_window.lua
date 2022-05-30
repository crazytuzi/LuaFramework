-- --------------------------------------------------------------------
-- 限时礼包入口
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      限时礼包入口
-- <br/>Create: 2019年1月9日
-- --------------------------------------------------------------------
ActionLimitGiftMainWindow = ActionLimitGiftMainWindow or BaseClass(BaseView)

local controller = ActionController:getInstance() 
local model = ActionController:getInstance():getModel()

function ActionLimitGiftMainWindow:__init(ctrl)
    self.is_full_screen = true
    self.win_type = WinType.Full  
    self.layout_name = "welfare/welfare_main_view"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_bg_1"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","welfare_tab"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("welfare","welfare"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("welfaretab","welfaretab"), type = ResourcesType.plist},
    }

    self.panel_list = {}
    self.tab_list = {}
    self.tab_width = 78
    self.off_space = 50
    self.selected_tab = nil
end

function ActionLimitGiftMainWindow:open_callback()
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

function ActionLimitGiftMainWindow:register_event()
    registerButtonEventListener(self.close_btn, function()
        controller:openActionLimitGiftMainWindow(false)
    end,true, 2)

    self:addGlobalEvent(ActionEvent.LIMIT_GIFT_MAIN_EVENT, function(scdata)
        self:initData(scdata)
    end)
end

function ActionLimitGiftMainWindow:openRootWnd(id)
    self.record_id = id
    controller:send21210()
end

function ActionLimitGiftMainWindow:initData(scdata)
    if not scdata then return end

    if #scdata.gifts == 0 then
        controller:openActionLimitGiftMainWindow(false)
        return 
    end
    
    self.sub_list = {}
    for i,gift in ipairs(scdata.gifts) do
        local config = Config.StarGiftData.data_limit_gift(gift.id)
        if config then
            gift.ico = config.ico
            gift.config = config
            gift.title = config.name
            table.insert(self.sub_list, gift)
        end
    end
    table.sort(self.sub_list, function(a, b) return a.id < b.id end)
    self:createSubType()
end

function ActionLimitGiftMainWindow:createSubType()
    if self.sub_list == nil or next(self.sub_list) == nil then
        return
    end

    local sum = #self.sub_list
    local max_width = sum * (self.tab_width + self.off_space) + self.off_space
    self.max_width = math.max(self.tab_scroll:getContentSize().width,max_width)
    self.tab_scroll:setInnerContainerSize(cc.size(self.max_width,self.tab_scroll:getContentSize().height))

    local function call_back(item)
        self:handleSelectedTab(item)
    end

    -- 捕获当前选中的
    local select_id = 0
    if self.selected_panel then
        self.selected_panel:DeleteMe()
        if self.selected_tab and self.selected_tab.data then
            select_id = self.selected_tab.data.id
            self.selected_tab = nil
        end
        self.panel_list[select_id] = nil
        self.selected_panel = nil
    end

    -- 移除有问题
    for i,v in pairs(self.tab_list) do
        v:DeleteMe()
    end
    self.tab_list = {}

    local tab_item, _x, _y, data = nil, 2
    local select_index = 1
    for i=1,sum do
        data = self.sub_list[i]
        tab_item = self.tab_list[data.id]
        if tab_item == nil then
            tab_item = WelfareTab.new()
            tab_item:setData(data)
            _x = self.off_space+(i-1)*(self.tab_width+self.off_space)
            tab_item:setPosition(_x,79)
            tab_item:updateTipsStatus(false)
            tab_item:setClickCallBack(call_back)
            self.tab_scroll:addChild(tab_item)
            self.tab_list[data.id] = tab_item
        end
        if select_id ~= 0 and select_id == data.id then
            select_index = i
        elseif self.record_id and self.record_id == data.id then
            select_index = i
        end
    end
    -- 手动设置选中第一个
    data = self.sub_list[select_index]
    self:handleSelectedTab(self.tab_list[data.id], true)
end

function ActionLimitGiftMainWindow:handleSelectedTab( tab , not_check)
    if not not_check and self.selected_tab ~= nil and self.selected_tab == tab then return end

    if self.selected_tab ~= nil then
        self.selected_tab:setSelecte(false)
    end
    self.selected_tab = tab
    if self.selected_tab ~= nil then
        self.selected_tab:setSelecte(true)
    end

    self:changePanelByTab()
end

function ActionLimitGiftMainWindow:changePanelByTab(  )
    if self.selected_tab == nil or self.selected_tab.data == nil then return end
    local data = self.selected_tab.data
    if data.id == nil or data.id == 0 then return end

    if self.selected_panel ~= nil then
        if self.selected_panel.setVisibleStatus then
            self.selected_panel:setVisibleStatus(false)
        else
            self.selected_panel:setVisible(false)
        end
        self.selected_panel = nil
    end

    if self.panel_list[data.id] == nil then
        self.panel_list[data.id] = ActionLimitGiftMainPanel.new(data)
        self.container:addChild(self.panel_list[data.id])
    end
    self.selected_panel = self.panel_list[data.id]
    
    if self.selected_panel.setVisibleStatus then
        self.selected_panel:setVisibleStatus(true)
    else
        self.selected_panel:setVisible(true)
    end
end

function ActionLimitGiftMainWindow:setTabStatus( id )
    local vo = controller:getHolidayAweradsStatus(id)
    local tab_item = self.tab_list[id]
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

function ActionLimitGiftMainWindow:close_callback()
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
    controller:openActionLimitGiftMainWindow(false)
end
