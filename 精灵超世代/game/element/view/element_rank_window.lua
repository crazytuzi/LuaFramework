--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-07 11:14:13
-- @description    : 
		-- 元素圣殿排行榜与奖励界面
---------------------------------
ElementRankWindow = ElementRankWindow or BaseClass(BaseView)

local _controller = ElementController:getInstance()
local _model = _controller:getModel()
local string_format = string.format

function ElementRankWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.title_str = TI18N("元素圣殿排行榜")
    self.background_path = PathTool.getPlistImgForDownLoad("bigbg/element","element_main_bg", true)
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("bigbg/element","element_main_bg", true), type = ResourcesType.single },
    }

    self.tab_info_list = {
        {label = TI18N("排行榜"), index = ElementConst.Rank_Type.Rank , status = true},
        {label = TI18N("奖励一览"),index = ElementConst.Rank_Type.Award, status = true},
    }
    self.selected_tab = nil -- 当前选中的标签
    self.tab_list = {}
    self.panel_list = {}
end

function ElementRankWindow:open_callback(  )
    if self.container then
        local con_size = self.container:getContentSize()
        if not self.tips_txt then
            local tips_str = TI18N("奖励每周一00:00通过邮件发放")
            self.tips_txt = createLabel(18, Config.ColorData.data_new_color4[6], nil, con_size.width-10, -4, tips_str, self.container, nil, cc.p(1, 0))
        end
    end
end

function ElementRankWindow:register_event(  )
	for k, tab_btn in pairs(self.tab_list) do
        tab_btn:addTouchEventListener(
            function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    playTabButtonSound()
                    self:changeSelectedTab(sender.index)
                end
            end
        )
    end

    registerButtonEventListener(self.background, function (  )
    	_controller:openElementRankWindow(false)
    end, false, 2)

    registerButtonEventListener(self.close_btn, function (  )
    	_controller:openElementRankWindow(false)
    end, false, 2)
end

function ElementRankWindow:openRootWnd( view_type )
	view_type = view_type or ElementConst.Rank_Type.Rank
    self:setSelecteTab(view_type)
end

function ElementRankWindow:selectedTabCallBack( index )
	self:changeSelectedTab(index)
end

function ElementRankWindow:changeSelectedTab( index )
	if self.selected_tab ~= nil then
        if self.selected_tab.index == index then
            return
        end
    end
    if self.selected_tab then
        self.selected_tab.label:setTextColor(cc.c4b(0xf5, 0xe0, 0xb9, 0xff))
        self.selected_tab:setBright(false)
        self.selected_tab = nil
    end
    self.selected_tab = self.tab_list[index]
    if self.selected_tab then
        self.selected_tab.label:setTextColor(cc.c4b(0x59, 0x34, 0x29, 0xff))
        self.selected_tab:setBright(true)
    end
    if self.cur_panel ~= nil then
        self.cur_panel:setNodeVisible(false)
        self.cur_panel = nil
    end

    self.cur_panel = self.panel_list[index]
    if self.cur_panel == nil then
        if index == ElementConst.Rank_Type.Rank then
            self.cur_panel = ElementRankPanel.new()
        elseif index == ElementConst.Rank_Type.Award then
            self.cur_panel = ElementAwardPanel.new()
        end
        self.panel_list[index] = self.cur_panel
        self.container:addChild(self.cur_panel)
        if self.cur_panel.addToParent then
            self.cur_panel:addToParent()
        end

    end
    self.cur_panel:setNodeVisible(true)
end

function ElementRankWindow:close_callback(  )
	for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = {}
    if self.bg_load then
    	self.bg_load:DeleteMe()
    	self.bg_load = nil
    end
    _controller:openElementRankWindow(false)
end