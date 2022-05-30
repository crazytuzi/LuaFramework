-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      竞技场循环赛面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaLoopMatchWindow = ArenaLoopMatchWindow or BaseClass(BaseView)

local controller = ArenaController:getInstance() 
local model = ArenaController:getInstance():getModel()

function ArenaLoopMatchWindow:__init()
    self.win_type = WinType.Full
    self.is_full_screen = true
    self.layout_name = "arena/arena_loop_window"

    self.cur_type = 0

    -- self.title_str = TI18N("竞技场")

    self:initConfig()
    --结算跳转回来这里的用途 --by lwc
    self.check_class_name = "ArenaLoopMatchWindow" 
    self.panel_list = {}
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("arena", "arenaloop"), type = ResourcesType.plist},
    }

    self.tab_info_list = {
        {label = TI18N("挑战"), index = ArenaConst.loop_index.challenge, status = true},
        {label = TI18N("排名榜"),index = ArenaConst.loop_index.rank, status = RankController:getInstance():checkRankIsShow(), notice = string.format(TI18N("%d级开启"), RankConstant.limit_open_lev)},
        {label = TI18N("日常奖励"),index = ArenaConst.loop_index.activity, status = true},
        {label = TI18N("排名奖励"),index = ArenaConst.loop_index.awards, status = true},
    }

    self.select_type = RankConstant.MainTabType.LocalRank
    --当前选中的索引
    self.cur_index = nil
end

function ArenaLoopMatchWindow:initConfig()
    local id = BattleController:getInstance():curBattleResId(BattleConst.Fight_Type.Arena)
    self.background_path = string.format("resource/bigbg/battle_bg/%s/b_bg.jpg", id)
end


function ArenaLoopMatchWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:loadTexture(PathTool.getPlistImgForDownLoad("bigbg","bigbg_109",true), LOADTEXT_TYPE)
        self.background:setScale(display.getMaxScale())
    end
    
    self.mainContainer = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.mainContainer , 1) 

    self.main_panel = self.mainContainer:getChildByName("main_panel")

    self.tableContainer = self.main_panel:getChildByName("tab_container")

    self.container = self.main_panel:getChildByName("container")

    self.close_btn = self.mainContainer:getChildByName("close_btn")
end

function ArenaLoopMatchWindow:register_event()
    registerButtonEventListener(self.close_btn, function()
        self:beforeClose()
        controller:openArenaLoopMathWindow(false, self.cur_type)
    end ,true, 2)

    if self.update_my_data == nil then
        self.update_my_data = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateMyLoopData, function(key, value)
            self:updateMyInfoData(key, value)
        end)
    end

    -- 这里会计算一下红点状态
    if self.update_challenge_activity == nil then
        self.update_challenge_activity = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateLoopChallengeTimesList, function()
            self:updateChallengeActivityStatus()
        end)
    end

    if self.update_arena_red_event == nil then
        self.update_arena_red_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateArenaRedStatus, function(type, status)
            self:checkActivityStatus(type, status)
        end)
    end
end

function ArenaLoopMatchWindow:openRootWnd(type)
    self.select_type = type or ArenaConst.loop_index.challenge
    -- self:setSelecteTab(type, true)
    self:updateTabBtnList(self.select_type)

    -- 判断活跃宝箱标签是否要显示红点
    self:checkActivityStatus()
end

--页签滚动列表
function ArenaLoopMatchWindow:updateTabBtnList(index)
    if not self.tab_info_list then return end

    if not self.tab_btn_list_view then

        local size = self.tableContainer:getContentSize()
        local count = self:numberOfCellsTabBtn()

        local item_width = 163
        local item_height = 64
        local position_data_list 
        if count <= 4  then
            position_data_list = {}
            local s_x = 5 --(size.width - count * item_width) * 0.5
            local y = item_height * 0.5
            for i=1,count do
                local x = s_x + item_width * 0.5 + (i -1) * item_width
                position_data_list[i] = cc.p(x, y)
            end
        end
        local setting = {
            -- item_class = HeroExhibitionItem,      -- 单元类
            start_x = 0,                  -- 第一个单元的X起点
            space_x = 0,                    -- x方向的间隔
            start_y = 0,                    -- 第一个单元的Y起点
            space_y = 0,                   -- y方向的间隔
            item_width = item_width,               -- 单元的尺寸width
            item_height = item_height,              -- 单元的尺寸height
            -- row = 1,                        -- 行数，作用于水平滚动类型
            -- col = 5,                         -- 列数，作用于垂直滚动类型
            need_dynamic = true,
            position_data_list = position_data_list
        }

        self.tab_btn_list_view = CommonScrollViewSingleLayout.new(self.tableContainer, cc.p(size.width * 0.5, size.height * 0.5) , ScrollViewDir.horizontal, ScrollViewStartPos.top, size, setting, cc.p(0.5,0.5))

        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.createNewCellTabBtn), ScrollViewFuncType.CreateNewCell) --创建cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.numberOfCellsTabBtn), ScrollViewFuncType.NumberOfCells) --获取数量
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndexTabBtn), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.tab_btn_list_view:registerScriptHandlerSingle(handler(self,self.onCellTouchedTabBtn), ScrollViewFuncType.OnCellTouched) --更新cell

        if count <= 4  then
            self.tab_btn_list_view:setClickEnabled(false)
        end
    end
    local index = index or 1
    self.tab_btn_list_view:reloadData(index)
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function ArenaLoopMatchWindow:createNewCellTabBtn(width, height)
    local cell = ccui.Widget:create()
    cell.root_wnd = createCSBNote(PathTool.getTargetCSB("common/common_tab_btn"))
    cell:addChild(cell.root_wnd)
    cell:setCascadeOpacityEnabled(true)
    cell:setAnchorPoint(cc.p(0.5, 0.5))
    cell:setContentSize(cc.size(width, height))
    cell.container = cell.root_wnd:getChildByName("container")
    cell.normal_img = cell.container:getChildByName("unselect_bg")
    cell.select_img = cell.container:getChildByName("select_bg")
    cell.normal_img:setContentSize(cc.size(width, height))
    cell.select_img:setContentSize(cc.size(width, height))
    cell.select_img:setVisible(false)
    -- cell.setOntouch
    cell.container:setSwallowTouches(false)
    cell.label = cell.container:getChildByName("title")
    cell.label:setTextColor(Config.ColorData.data_new_color4[6])

    --红点. 暂时没有红点 先隐藏
    cell.red_point = cell.container:getChildByName("tab_tips")
    cell.red_num = cell.container:getChildByName("red_num")
    cell.red_point:setVisible(false)
    cell.red_num:setVisible(false)

    registerButtonEventListener(cell.container, function() self:onCellTouchedTabBtn(cell) end, false, 2, nil, nil, nil, true)
    -- --回收用
    -- cell.DeleteMe = function() 
    -- end
    return cell
end

--获取数据数量
function ArenaLoopMatchWindow:numberOfCellsTabBtn()
    if not self.tab_info_list then return 0 end
    return #self.tab_info_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function ArenaLoopMatchWindow:updateCellByIndexTabBtn(cell, index)
    cell.index = index
    local tab_data = self.tab_info_list[index]
    if tab_data then
        cell.label:setString(tab_data.label)
        setLabelAutoScale(cell.label, cell, 20)
        local tab_btn =  self.tab_btn_list_view:getCellByIndex(index)
        if tab_data.status ~= true then
            setChildUnEnabled(true, tab_btn)
            tab_btn.label:setTextColor(Config.ColorData.data_new_color4[1])
            tab_btn.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
            return
        end
        if self.cur_index == index then
            cell.select_img:setVisible(true)
            cell.label:setTextColor(Config.ColorData.data_new_color4[1])
            cell.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        else
            cell.select_img:setVisible(false)            
            cell.label:setTextColor(Config.ColorData.data_new_color4[6])
            cell.label:disableEffect(cc.LabelEffect.SHADOW)
        end

        --先不处理.都是1级开启的 省点
        -- if tab_data.can_touch then
        --     cell.label:enableOutline(cc.c4b(0x2a, 0x16, 0x0e, 0xff), 2)
        --     setChildUnEnabled(false, cell.tab_btn)
        -- else 
        --     cell.label:disableEffect(cc.LabelEffect.OUTLINE)
        --     setChildUnEnabled(true, cell.tab_btn)
        -- end
    end
end

--index :数据的索引
function ArenaLoopMatchWindow:onCellTouchedTabBtn(cell)
    local index = cell.index
    local tab_data = self.tab_info_list[index]
    if tab_data then
        --点击需要判断
        if tab_data.status then
            -- self:changeTabView(index, true)
            self:changeTabIndex(index)
        else
            message(TI18N(tab_data.notice))
        end
    end
end

function ArenaLoopMatchWindow:changeTabIndex(index)
    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[6])
            self.cur_tab.label:disableEffect(cc.LabelEffect.SHADOW)
        end
        self.cur_tab.select_img:setVisible(false)
    end

    self.select_type = index
    self.cur_tab =  self.tab_btn_list_view:getCellByIndex(self.select_type)

    if self.cur_tab ~= nil then
        if self.cur_tab.label then
            self.cur_tab.label:setTextColor(Config.ColorData.data_new_color4[1])
            self.cur_tab.label:enableShadow(Config.ColorData.data_new_color4[2],cc.size(0, -2),2)
        end
        self.cur_tab.select_img:setVisible(true)
    end

    self:changeTabPanel(index)
end

-- function ArenaLoopMatchWindow:selectedTabCallBack(index)
--     self:changeTabPanel(index)
-- end

function ArenaLoopMatchWindow:changeTabPanel(index)
    if self.cur_panel ~= nil then
        self.cur_panel:setNodeVisible(false)
        self.cur_panel = nil
    end
    self.cur_type  = index
    self.cur_panel = self.panel_list[index]

    if self.cur_panel == nil then
        local loop_index = self.tab_info_list[index].index
        if loop_index == ArenaConst.loop_index.challenge then
            self.cur_panel = ArenaLoopChallengePanel.new()
        elseif loop_index == ArenaConst.loop_index.activity then
            self.cur_panel = ArenaLoopActivityPanel.new()
        elseif loop_index == ArenaConst.loop_index.rank then
            self.cur_panel = ArenaLoopRankPanel.new()
        elseif loop_index == ArenaConst.loop_index.awards then
            self.cur_panel = ArenaLoopAwardsPanel.new()
        end
        self.panel_list[index] = self.cur_panel
        self.container:addChild(self.cur_panel)
        if self.cur_panel.addToParent then
            self.cur_panel:addToParent()
        end
    end
    if self.cur_panel ~= nil then
        self.cur_panel:setNodeVisible(true)
        if self.cur_panel.updatePanelInfo then
            self.cur_panel:updatePanelInfo(false)
        end
    end
end

--[[
    @desc:针对需要根据自身信息做更新的面板
    author:{author};ll
    time:2018-05-14 21:43:04
    --@key:
	--@value: 
    return
]]
function ArenaLoopMatchWindow:updateMyInfoData()
    if self.cur_panel ~= nil and self.cur_panel.updatePanelInfo then
        self.cur_panel:updatePanelInfo(true)
    end
end

--[[
    @desc:添加宝箱标签页红点，以及如果是当前标签，则更新相关数据的
    author:{author}
    time:2018-05-14 21:43:19
    return
]]
function ArenaLoopMatchWindow:updateChallengeActivityStatus()
    local panel = self.panel_list[ArenaConst.loop_index.activity]
    if panel ~= nil then
        panel:updatePanelInfo(true)
    end
end

function ArenaLoopMatchWindow:checkActivityStatus(type, status)
    if type == nil then
        local red_status = model:getLoopMatchRedStatus(ArenaConst.red_type.loop_challenge)
        -- self:setTabTips(red_status, ArenaConst.loop_index.challenge)

        red_status = model:getLoopMatchRedStatus(ArenaConst.red_type.loop_artivity)
        self:setTabTips(red_status, ArenaConst.loop_index.activity)
    else
        if type == ArenaConst.red_type.loop_challenge then
            -- self:setTabTips(status, ArenaConst.loop_index.challenge)
        elseif type == ArenaConst.red_type.loop_artivity then
            self:setTabTips(status, ArenaConst.loop_index.activity)
        elseif type == ArenaConst.red_type.loop_log then
            if self.cur_type == ArenaConst.loop_index.challenge then
                if self.cur_panel and self.cur_panel.updateMyLogTips then
                    self.cur_panel:updateMyLogTips()
                end
            end
        end
    end
end

function ArenaLoopMatchWindow:beforeClose()
    controller:openArenaEnterWindow(true)
end

function ArenaLoopMatchWindow:close_callback()
    -- 还原ui战斗类型
    MainuiController:getInstance():resetUIFightType()
    
    controller:openArenaLoopMathWindow(false, self.cur_type)
    if self.update_my_data ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_my_data)
        self.update_my_data = nil
    end

    if self.update_challenge_activity ~= nil then
        GlobalEvent:getInstance():UnBind(self.update_challenge_activity)
        self.update_challenge_activity = nil
    end

    if self.update_arena_red_event == nil then
        GlobalEvent:getInstance():UnBind(self.update_arena_red_event)
        self.update_arena_red_event = nil
    end

    for k, panel in pairs(self.panel_list) do
        if panel.DeleteMe then
            panel:DeleteMe()
        end
    end
    self.panel_list = nil
end
