-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      竞技场的主入口界面，分为进入循环赛和进入排位赛界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaEnterWindow = ArenaEnterWindow or BaseClass(BaseView)

function ArenaEnterWindow:__init()
    self.ctrl = ArenaController:getInstance()
    self.model = self.ctrl:getModel()
    self.win_type = WinType.Full
    self.layout_name = "arena/arena_enter_window"
    self.label_list = {}
    self.cur_rank_type = 0
    self.panel_list = {}
    self:initConfig()

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arena", "arenaenter"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("arena", "arenaloop"), type = ResourcesType.plist},
        {path = self.background_path_1, type = ResourcesType.single},
        {path = self.background_path_2, type = ResourcesType.single},
    }
end

function ArenaEnterWindow:initConfig()
    local id = BattleController:getInstance():curBattleResId(BattleConst.Fight_Type.Arena)
    self.background_path_1 = string.format("resource/bigbg/battle_bg/%s/b_bg.jpg", id)
    
    local id = BattleController:getInstance():curBattleResId(BattleConst.Fight_Type.Champion)
    self.background_path_2 = string.format("resource/bigbg/battle_bg/%s/b_bg.jpg", id)
end

function ArenaEnterWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")
    self.tab_container = self.container:getChildByName("tab_container")

    self.loop_btn = self.tab_container:getChildByName("loop_btn")
    self.loop_select = self.loop_btn:getChildByName("select_bg")

    self.rank_btn = self.tab_container:getChildByName("rank_btn")
    self.rank_select = self.rank_btn:getChildByName("select_bg")

    self.panel_container = self.container:getChildByName("panel_container")

    self.set_btn = self.container:getChildByName("set_btn")
    self.set_btn:getChildByName("label"):setString(TI18N("形象设置"))
    
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local left_x = display.getLeft(self.main_container)
    --主菜单 顶部的高度
    local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    local offy = top_y - top_height - 30 
    self.set_btn:setAnchorPoint(cc.p(0,1))
    self.set_btn:setPosition(cc.p(left_x + 20, offy))
end

function ArenaEnterWindow:register_event()
    registerButtonEventListener(self.loop_btn, function() self:changeArenaType(ArenaConst.arena_type.loop) end, false, 1)
    registerButtonEventListener(self.rank_btn, function() self:changeArenaType(ArenaConst.arena_type.rank) end, false, 1)
    registerButtonEventListener(self.set_btn, function() RoleController:getInstance():openRoleDecorateView(true, 3) end, true, 1)
end

function ArenaEnterWindow:openRootWnd(index)
    self:changeArenaType(index)
end

function ArenaEnterWindow:changeArenaType(index)
    if self.cur_rank_type == index then return end
    self.cur_rank_type = index
    self.loop_select:setVisible(index == ArenaConst.arena_type.rank)
    self.rank_select:setVisible(index == ArenaConst.arena_type.loop)

    if self.cur_panel ~= nil then
        if self.cur_panel.addToParent then
            self.cur_panel:addToParent(false)
        end
    end
    if self.panel_list[self.cur_rank_type] == nil then
        if self.cur_rank_type == ArenaConst.arena_type.loop then
            self.panel_list[self.cur_rank_type] = ArenaEnterLoopView.new()
        else
            self.panel_list[self.cur_rank_type] = ArenaEnterChampionView.new()
        end
        if self.panel_list[self.cur_rank_type] ~= nil then
            self.panel_container:addChild(self.panel_list[self.cur_rank_type])
        end
    end
    self.cur_panel = self.panel_list[self.cur_rank_type]
    if self.cur_panel and self.cur_panel.addToParent then
        self.cur_panel:addToParent(true)
    end
    if self.cur_rank_type == ArenaConst.arena_type.loop then
        self.background:loadTexture(self.background_path_1, LOADTEXT_TYPE) 
    else
        self.background:loadTexture(self.background_path_2, LOADTEXT_TYPE) 
    end
end

function ArenaEnterWindow:close_callback()
    for k,panel in pairs(self.panel_list) do
        if panel.DeleteMe then
            panel:DeleteMe()
        end
    end
    self.panel_list = nil
    self.ctrl:openArenaEnterWindow(false)
end
