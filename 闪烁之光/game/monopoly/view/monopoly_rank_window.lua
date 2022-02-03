---------------------------------
-- @Author: htp
-- @Editor: htp
-- @date 2019/10/17 15:46:08
-- @description: 圣夜奇境排行榜界面
---------------------------------
local _controller = MonopolyController:getInstance()
local _model = _controller:getModel()
local string_format = string.format

MonopolyRankWindow = MonopolyRankWindow or BaseClass(BaseView)

function MonopolyRankWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.title_str = TI18N("圣夜奇境排行榜")
    self.background_path = PathTool.getPlistImgForDownLoad("monopoly","monopoly_enter_bg_1", true)
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("monopoly","monopoly_enter_bg_1", true), type = ResourcesType.single },
        {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single },
    }

    self.tab_info_list = {
        {label = TI18N("公会排行"), index = MonopolyConst.Rank_Type.Guild , status = true},
        {label = TI18N("个人贡献"), index = MonopolyConst.Rank_Type.Personal , status = true},
        {label = TI18N("公会奖励"),index = MonopolyConst.Rank_Type.Award, status = true},
    }
    self.selected_tab = nil -- 当前选中的标签
    self.tab_list = {}
    self.panel_list = {}
end

function MonopolyRankWindow:open_callback(  )
    if self.container then
        local con_size = self.container:getContentSize()
        if not self.tips_txt then
            self.tips_txt = createLabel(20, cc.c3b(100,50,35), nil, con_size.width-10, -10, TI18N("各章节排行奖励将在活动结束时结算，并发放进入公会宝库"), self.container, nil, cc.p(1, 0))
        end
    end
end

function MonopolyRankWindow:register_event(  )
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
    	_controller:openMonopolyRankWindow(false)
    end, false, 2)

    registerButtonEventListener(self.close_btn, function (  )
    	_controller:openMonopolyRankWindow(false)
    end, true, 2)
end

function MonopolyRankWindow:openRootWnd( step_id, view_type )
	self.step_id = step_id or 1
	view_type = view_type or MonopolyConst.Rank_Type.Guild
    self:setSelecteTab(view_type)
end

function MonopolyRankWindow:selectedTabCallBack( index )
	self:changeSelectedTab(index)
end

function MonopolyRankWindow:changeSelectedTab( index )
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

    if self.tips_txt then
        self.tips_txt:setVisible(index ~= MonopolyConst.Rank_Type.Personal)
    end

    self.cur_panel = self.panel_list[index]
    if self.cur_panel == nil then
        if index == MonopolyConst.Rank_Type.Guild then
            self.cur_panel = MonopolyGuildRankPanel.new(self.step_id)
        elseif index == MonopolyConst.Rank_Type.Personal then
        	self.cur_panel = MonopolyPersonalRankPanel.new(self.step_id)
        elseif index == MonopolyConst.Rank_Type.Award then
            self.cur_panel = MonopolyRankAwardPanel.new()
        end
        self.panel_list[index] = self.cur_panel
        self.container:addChild(self.cur_panel)
        if self.cur_panel.addToParent then
            self.cur_panel:addToParent()
        end
    end
    self.cur_panel:setNodeVisible(true)
end

function MonopolyRankWindow:close_callback(  )
	for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = {}
    _controller:openMonopolyRankWindow(false)
end