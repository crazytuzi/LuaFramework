-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      32强赛的面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionTop32Panel = class("ArenaChampionTop32Panel", function()
	return ccui.Layout:create()
end)

local table_insert = table.insert

function ArenaChampionTop32Panel:ctor(view_type)
	self.tab_list = {}
    self.panel_list = {}
    self.is_in_check_info = false

    self.view_type = view_type or ArenaConst.champion_type.normal
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl = ArenaController:getInstance()
        self.model = self.ctrl:getChampionModel()
    else
        self.ctrl = CrosschampionController:getInstance()
        self.model = self.ctrl:getModel()
    end
	
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("arena/arena_champion_top_32_panel"))
	
	self.size = self.root_wnd:getContentSize()
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd) 

    local container = self.root_wnd:getChildByName("container")

    local main_panel = container:getChildByName("main_panel")

    self.page_container = main_panel:getChildByName("page_container")

    local tab_container = main_panel:getChildByName("tab_container")
    for i=1, 2 do
        local tab_btn = tab_container:getChildByName(string.format("tab_btn_%s",i))
        tab_btn:setBright(false)

        local label = tab_btn:getChildByName("title")
        label:setTextColor(cc.c4b(0xfe, 0xd1, 0x9c, 0xff))
        -- label:enableOutline(cc.c4b(0x64, 0x27, 0x05, 0xff))
        if i == 1 then
            if self.view_type == ArenaConst.champion_type.normal then
                label:setString(TI18N("32强赛"))
            else
                label:setString(TI18N("64强赛"))
            end
        else
            if self.view_type == ArenaConst.champion_type.normal then
                label:setString(TI18N("4强赛"))
            else
                label:setString(TI18N("8强赛"))
            end
        end

        local object = {}
        object.tab_btn = tab_btn 
        object.label = label 
        object.index = i
        self.tab_list[i] = object
    end

    self.main_panel = main_panel
    self.tab_container = tab_container

    self:registerEvent()
end

function ArenaChampionTop32Panel:registerEvent()
    for i, object in ipairs(self.tab_list) do
        object.tab_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playTabButtonSound()
                self:changeTabView(i, true)
            end
        end)
    end
    if self.check_fight_info == nil then
        self.check_fight_info = GlobalEvent:getInstance():Bind(ArenaEvent.CheckFightInfoEvent, function(status, group, pos) 
            self:changeToFightinfo(status, group, pos)
        end)
    end
end

--==============================--
--desc:切换到查看战斗信息的界面
--time:2018-08-02 10:54:59
--@status:
--@group:所在小组
--@pos:所在位置
--@return 
--==============================--
function ArenaChampionTop32Panel:changeToFightinfo(status, group, pos)
    self.is_in_check_info = status
    if status == true then
        if self.check_info == nil then
            self.check_info = ArenaChampionCheckFightInfoView.new(self.view_type)
            self.main_panel:addChild(self.check_info)
        end
        self.check_info:addToParent(true)
        self.page_container:setVisible(false)
        self.tab_container:setVisible(false)
        self.check_info:setBaseInfo(group, pos)
    else
        if self.check_info then
            self.check_info:addToParent(false)
        end
        self.page_container:setVisible(true)
        self.tab_container:setVisible(true)
        -- 默认请求一下
        if self.cur_panel and self.cur_panel.updateInfo then
            self.cur_panel:updateInfo(true)
        end
    end
end

function ArenaChampionTop32Panel:changeTabView( index, is_change_tab )
    if self.cur_selected and self.cur_selected.index == index then return end
    if self.cur_selected then
        self.cur_selected.label:setTextColor(cc.c4b(0xfe, 0xd1, 0x9c, 0xff))
        self.cur_selected.tab_btn:setBright(false)
        self.cur_selected = nil 
    end
    self.cur_selected = self.tab_list[index]
    if self.cur_selected == nil then return end

    self.cur_selected.label:setTextColor(cc.c4b(0xff, 0xff, 0xff, 0xff))
    self.cur_selected.tab_btn:setBright(true)

    if self.cur_panel then
        self.cur_panel:addToParent(false)
    end
    self.cur_panel = nil

    self.cur_panel = self:getPanel(index)
    if self.cur_panel then
        self.cur_panel:addToParent(true)
        if self.cur_panel.updateInfo then
            self.cur_panel:updateInfo(is_change_tab)
        end
    end
end

function ArenaChampionTop32Panel:getPanel(index)
    local panel = self.panel_list[index]
    if panel == nil then
        if index == 1 then
            panel = ArenaChampionTop321View.new(self.view_type)
        elseif index == 2 then
            if self.view_type == ArenaConst.champion_type.normal then
                panel = ArenaChampionTop322View.new(self.view_type)
            else
                panel = ArenaChampionTop8View.new(self.view_type)
            end
        end
        if panel then
            self.page_container:addChild(panel)
        end
    end
    self.panel_list[index] = panel
    return panel
end

function ArenaChampionTop32Panel:addToParent(status)
	self:setVisible(status)
end 

--==============================--
--desc:主窗体更新触发
--time:2018-08-06 08:39:09
--@status:
--@return 
--==============================--
function ArenaChampionTop32Panel:updateInfo(status)
    local base_info = self.model:getBaseInfo()
    local role_info = self.model:getRoleInfo()
    if base_info == nil or role_info == nil then return end
    self.is_change_tab = status
    if base_info.step == ArenaConst.champion_step.unopened or base_info.step == ArenaConst.champion_step.score or ((base_info.step == ArenaConst.champion_step.match_32 or base_info.step == ArenaConst.champion_step.match_64) and base_info.step_status == ArenaConst.champion_step_status.unopened) then
        self.main_panel:setVisible(false)
    else
        self.main_panel:setVisible(true)
        if self.is_in_check_info == true then
            if self.check_info then
                self.check_info:updateInfo(self.is_change_tab)
            end
        else
            if self.cur_panel == nil then
                self:changeTabView(1, self.is_change_tab)
            else
                if self.cur_panel.updateInfo then
                    self.cur_panel:updateInfo(self.is_change_tab)
                end
            end
        end
    end
end

function ArenaChampionTop32Panel:DeleteMe() 
    if self.check_fight_info then
        GlobalEvent:getInstance():UnBind(self.check_fight_info)
        self.check_fight_info = nil
    end

    for k,panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = nil
    if self.check_info then
        self.check_info:DeleteMe()
    end
    self.check_info = nil
end