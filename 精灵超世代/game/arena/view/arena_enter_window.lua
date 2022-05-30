-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      竞技场的主入口界面，分为进入循环赛和进入排位赛界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaEnterWindow = ArenaEnterWindow or BaseClass(BaseView)

local tab_name_list = {
    [1] = TI18N("排位赛"),
    [2] = TI18N("冠军赛")
}

function ArenaEnterWindow:__init()
    self.ctrl = ArenaController:getInstance()
    self.model = self.ctrl:getModel()
    self.win_type = WinType.Full
    self.layout_name = "arena/arena_enter_window"
    self.label_list = {}
    self.cur_rank_type = 0
    self.panel_list = {}
    self.tab_list = {}
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

    for i=1,2 do
        local tab_btn = self.tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local object = {}
            object.unselect_bg = tab_btn:getChildByName('unselect_bg')
            object.unselect_bg:setVisible(true)
            object.select_bg = tab_btn:getChildByName('select_bg')
            object.select_bg:setVisible(false)
            local tab_btn_size = tab_btn:getContentSize()
            object.label = createRichLabel(22, 0, cc.p(0.5, 0.5), cc.p(tab_btn_size.width/2, tab_btn_size.height/2))
            tab_btn:addChild(object.label)
            object.label:setString(string.format("<div fontcolor=%s>%s</div>", Config.ColorData.data_new_color_str[6], tab_name_list[i]))
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end
    end

    self.panel_container = self.container:getChildByName("panel_container")

    self.set_btn = self.container:getChildByName("set_btn")
    self.set_btn:getChildByName("label"):setString(TI18N("形象设置"))
    
    -- --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    -- local top_y = display.getTop(self.main_container)
    -- local left_x = display.getLeft(self.main_container)
    -- --主菜单 顶部的高度
    -- local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    -- local offy = top_y - top_height - 30 
    -- self.set_btn:setAnchorPoint(cc.p(0,1))
    -- self.set_btn:setPosition(cc.p(left_x + 20, offy))
end

function ArenaEnterWindow:register_event()
    -- registerButtonEventListener(self.loop_btn, function() self:changeArenaType(ArenaConst.arena_type.loop) end, false, 1)
    -- registerButtonEventListener(self.rank_btn, function() self:changeArenaType(ArenaConst.arena_type.rank) end, false, 1)

    for k, object in pairs(self.tab_list) do
        if object.tab_btn then
            object.tab_btn:addTouchEventListener(function(sender, event_type)
                if event_type == ccui.TouchEventType.ended then
                    self:changeArenaType(object.index)
                end
            end)
        end
    end

    registerButtonEventListener(self.set_btn, function() RoleController:getInstance():openRoleDecorateView(true, 3) end, true, 1)
end

function ArenaEnterWindow:openRootWnd(index)
    self:changeArenaType(index)
end

function ArenaEnterWindow:changeArenaType(index)
    if self.cur_rank_type == index then return end
    self.cur_rank_type = index
    -- self.loop_select:setVisible(index == ArenaConst.arena_type.rank)
    -- self.rank_select:setVisible(index == ArenaConst.arena_type.loop)

    if self.tab_object then
        self.tab_object.select_bg:setVisible(false)
        self.tab_object.label:setString(string.format("<div fontcolor=%s>%s</div>", Config.ColorData.data_new_color_str[6], tab_name_list[self.tab_object.index]))
        self.tab_object = nil
    end
    self.tab_object = self.tab_list[index]
    if self.tab_object then
        self.tab_object.select_bg:setVisible(true)
        self.tab_object.label:setString(string.format("<div fontcolor=#ffffff shadow=0,-2,2,%s>%s</div>", Config.ColorData.data_new_color_str[2], tab_name_list[index]))
    end

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
