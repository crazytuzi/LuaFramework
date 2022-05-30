--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-07 11:14:13
-- @description    : 
		-- 元素圣殿排行榜与奖励界面
---------------------------------
WeeklyRankWindow = WeeklyRankWindow or BaseClass(BaseView)

local _controller = WeeklyActivitiesController:getInstance()
local _model = _controller:getModel()
local string_format = string.format

function WeeklyRankWindow:__init()
    --self.win_type = WinType.Full
    self.is_full_screen = true
    local activice_id = _model:getWeeklyActivityId() or 1
    local title_name = {TI18N("地宫排行榜"),TI18N("灵泉排行榜"),TI18N("石室排行榜")}
    self.title_str = title_name[activice_id]

    self.view_tag = ViewMgrTag.TOP_TAG
    self.win_type = WinType.Big
    --self.background_path = PathTool.getPlistImgForDownLoad("bigbg/element","element_main_bg", true)
    --self.res_list = {
    --    {path = PathTool.getPlistImgForDownLoad("bigbg/element","element_main_bg", true), type = ResourcesType.single },
    --}

    self.tab_info_list = {
        {label = TI18N("排行榜"), index = 1 , status = true},
        {label = TI18N("奖励一览"),index = 2, status = true},
    }
    self.selected_tab = nil -- 当前选中的标签
    self.tab_list = {}
    self.panel_list = {}

end

function WeeklyRankWindow:open_callback(  )
    if self.container then
        local con_size = self.container:getContentSize()
        if not self.tips_txt then
            --local tips_str = TI18N("奖励每周一00:00通过邮件发放")
            --self.tips_txt = createLabel(18, Config.ColorData.data_new_color4[6], nil, con_size.width-10, -4, tips_str, self.container, nil, cc.p(1, 0))
        end
    end
    self.touchBg = createImage(self.root_wnd,PathTool.getResFrame("common","common_1064"), 243, 103, cc.p(0.5, 0.5), true, -10, true)
    self.touchBg:setContentSize(cc.size(SCREEN_WIDTH,SCREEN_HEIGHT))
    self.touchBg:setAnchorPoint(cc.p(0.5,0.5))
    self.touchBg:setPosition(SCREEN_WIDTH*0.5,SCREEN_HEIGHT*0.5)
    self.touchBg:setTouchEnabled(true)
    self.touchBg:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            _controller:openRankWindow( false )
        end
    end)

    self.close_btn:setVisible(false)
    self.close_btn = CustomButton.New(self.main_panel,PathTool.getResFrame("common", "common_1028"),nil,nil,LOADTEXT_TYPE_PLIST)
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            _controller:openRankWindow( false )
        end
    end)
    self.close_btn:setPositionX(660*display.getMaxScale())
    self.close_btn:setPositionY(915*display.getMaxScale())
    self:setSelecteTab(view_type)
    self:changeSelectedTab(view_type)
    if self.background then
        self.background:setVisible(false)
    end
end

function WeeklyRankWindow:register_event(  )

end

function WeeklyRankWindow:openRootWnd( view_type )
	
end

function WeeklyRankWindow:setCloseEvent( call_back )
    self.callback = call_back
end

function WeeklyRankWindow:onEventToClose(  )
    if self.callback then
        self.callback()
        self.callback = nil
    end
    if next(self.panel_list) ~= nil then
        for k, panel in pairs(self.panel_list) do
            if(self.panel_list[k])then
                panel:DeleteMe()
            end
        end
        self.panel_list = {}
    end
    self:close()
end

function WeeklyRankWindow:selectedTabCallBack( index )
    view_type = index
    if(self.container)then
	   self:changeSelectedTab(view_type)
    end
end

function WeeklyRankWindow:changeSelectedTab( index )
	if self.selected_tab ~= nil then
        if self.selected_tab.index == index then
            return
        end
    end
    --self:setSelecteTab(index)
    if self.cur_panel ~= nil then
        self.cur_panel:setNodeVisible(false)
        self.cur_panel = nil
    end

    self.cur_panel = self.panel_list[index]
    if self.cur_panel == nil then
        if index == 1 then
            self.cur_panel = WeeklyRankPanel.new()
        elseif index == 2 then
            self.cur_panel = WeeklyAwardPanel.new()
        end
        self.panel_list[index] = self.cur_panel
        print("self.cur_panel",self.container,self.cur_panel,type(self.container),type(self.cur_panel))
        self.container:addChild(self.cur_panel)
        if self.cur_panel.addToParent then
            self.cur_panel:addToParent()
        end

    end
    self.cur_panel:setNodeVisible(true)
end

function WeeklyRankWindow:close_callback(  )
    if self.bg_load then
    	self.bg_load:deleteMe()
    	self.bg_load = nil
    end
    self.cur_panel = nil
    --self:DeleteMe()
    if next(self.panel_list) ~= nil then
        for k, panel in pairs(self.panel_list) do
            if(self.panel_list[k])then
                panel:DeleteMe()
            end
        end
        self.panel_list = {}
    end


    --_controller:openRankWindow( false )
end

function WeeklyRankWindow:DeleteMe()

    if next(self.panel_list) ~= nil then
        for k, panel in pairs(self.panel_list) do
            if(self.panel_list[k])then
                panel:DeleteMe()
            end
        end
        self.panel_list = {}
    end
    --_controller:openRankWindow( false )
end