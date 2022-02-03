--------------------------------------------
-- @Author  : lwc
-- @Date    : 2019-4-26
-- @description    : 
        -- 单个类型的排行榜
---------------------------------
SingleRankMainWindow = SingleRankMainWindow or BaseClass(BaseView)

local _controller = RankController:getInstance()
local _model = _controller:getModel()
local string_format = string.format

function SingleRankMainWindow:__init(title_name, background_path, rank_type)
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.title_str = title_name or TI18N("排行榜")
    self.rank_type = rank_type or RankConstant.RankType.sandybeach_boss_fight
    self.background_path = background_path or PathTool.getPlistImgForDownLoad("bigbg/element","element_main_bg", true)
    self.res_list = {
        {path = self.background_path, type = ResourcesType.single },
    }

    self.tab_info_list = {
        {label = TI18N("排行榜"), index = RankConstant.Rank_Type.Rank , status = true},
        {label = TI18N("奖励一览"),index = RankConstant.Rank_Type.Award, status = true},
    }
    self.selected_tab = nil -- 当前选中的标签
    self.tab_list = {}
    self.panel_list = {}
end

function SingleRankMainWindow:open_callback(  )
   
end

function SingleRankMainWindow:register_event(  )
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
        _controller:openSingleRankMainWindow(false)
    end, false, 2)

    registerButtonEventListener(self.close_btn, function (  )
        _controller:openSingleRankMainWindow(false)
    end, true, 2)
end


--setting
--setting.show_tips  是否显示右下角 tips说明
--setting.only_show_rank 是否仅显示排行榜 不显示奖励
function SingleRankMainWindow:openRootWnd( setting, view_type ) --sandybeach_boss_fight
    self.setting = setting or {}
    self.show_tips = setting.show_tips or ""
    self.only_show_rank = setting.only_show_rank or false

    local view_type = view_type or RankConstant.Rank_Type.Rank
    if self.only_show_rank then
        view_type = RankConstant.Rank_Type.Rank
        self.tab_info_list[2] = nil
        if self.tab_btn_list and self.tab_btn_list[2] then
            self.tab_btn_list[2]:setVisible(false)
        end
    end
    self:inittips()
    self:setSelecteTab(view_type)
end

function SingleRankMainWindow:inittips()
     if self.container then
        local con_size = self.container:getContentSize()
        if not self.tips_txt then
            self.tips_txt = createLabel(20, cc.c3b(100,50,35), nil, con_size.width-10, -10, self.show_tips, self.container, nil, cc.p(1, 0))
        end
    end
end

function SingleRankMainWindow:selectedTabCallBack( index )
    self:changeSelectedTab(index)
end

function SingleRankMainWindow:changeSelectedTab( index )
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
        if index == RankConstant.Rank_Type.Rank then
            self.cur_panel = SingleRankPanel.new()
        elseif index == RankConstant.Rank_Type.Award then
            self.cur_panel = SingleAwardPanel.new()
        end
        self.panel_list[index] = self.cur_panel
        self.container:addChild(self.cur_panel)
        if self.cur_panel.addToParent then
            self.cur_panel:addToParent(self.setting)
        end

    end
    self.cur_panel:setNodeVisible(true)
end

function SingleRankMainWindow:close_callback(  )
    for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = {}
    if self.bg_load then
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end
    _controller:openSingleRankMainWindow(false)
end