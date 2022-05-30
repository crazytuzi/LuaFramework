-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛的主界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionMatchWindow = ArenaChampionMatchWindow or BaseClass(BaseView)

local game_net = GameNet:getInstance()
local string_format = string.format

function ArenaChampionMatchWindow:__init(view_type)
	self.win_type = WinType.Full
	self.is_full_screen = true
	self.layout_name = "arena/arena_champion_match_window"
	self.cur_type = 0
	self.panel_list = {}
    self.real_panel_index = 0
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("arena", "arenachampion"), type = ResourcesType.plist},
	}

    self.view_type = view_type or ArenaConst.champion_type.normal
    if self.view_type == ArenaConst.champion_type.normal then
        self.ctrl = ArenaController:getInstance()
        self.model = self.ctrl:getChampionModel()
    else
        self.ctrl = CrosschampionController:getInstance()
        self.model = self.ctrl:getModel()
    end

    self:initConfig()
    self.tab_list = {}

    self.had_show = false
end 

function ArenaChampionMatchWindow:initConfig()
	local id = BattleController:getInstance():curBattleResId(BattleConst.Fight_Type.Champion)
    if self.view_type == ArenaConst.champion_type.cross then
        id = BattleController:getInstance():curBattleResId(BattleConst.Fight_Type.CrossChampion)
    end
	self.background_path = string.format("resource/bigbg/battle_bg/%s/b_bg.jpg", id)
    table.insert(self.res_list, {path = self.background_path, type = ResourcesType.single} )
end 

function ArenaChampionMatchWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
	self.background:loadTexture(self.background_path, LOADTEXT_TYPE)
	self.background:setScale(display.getMaxScale(self.root_wnd))

    local main_container = self.root_wnd:getChildByName("main_container")
    self.close_btn = main_container:getChildByName("close_btn")

    self.my_guess_btn = main_container:getChildByName("my_guess_btn")
    self.my_guess_btn_label = self.my_guess_btn:getChildByName("label")

    self.awards_btn = main_container:getChildByName("awards_btn")
    self.awards_btn:getChildByName("label"):setString(TI18N("奖励"))

    self.tab_container = main_container:getChildByName("tab_container")
    self.explain_btn = self.tab_container:getChildByName("explain_btn")
    self.shop_btn = main_container:getChildByName("shop_btn")
    local shop_btn_label = self.shop_btn:getChildByName("label")
    self.shop_btn:ignoreContentAdaptWithSize(true)
    if self.view_type == ArenaConst.champion_type.normal then
        -- self.shop_btn:loadTexture(PathTool.getResFrame("arena","arenachampion_1026",false,"arenachampion"), LOADTEXT_TYPE_PLIST)
        shop_btn_label:setString(TI18N("竞技商店"))
        shop_btn_label:setPositionX(31)
    else
        -- self.shop_btn:loadTexture(PathTool.getResFrame("arena","arenachampion_1036",false,"arenachampion"), LOADTEXT_TYPE_PLIST)
        shop_btn_label:setString(TI18N("冠军商店"))
        shop_btn_label:setPositionX(38.5)
    end

    self.panel_title = main_container:getChildByName("panel_title")
    self.match_time_label = main_container:getChildByName("match_time_label")
    self.panel_title:setVisible(false)
    self.match_time_label:setVisible(false)

    -- 存放各个界面的父节点
    self.container = main_container:getChildByName("container")
    
    for i=1, 4 do
        -- local tab_btn = self.tab_container:getChildByName(string.format("tab_btn_%s",i))
        -- tab_btn:setBright(false)

        -- local label = tab_btn:getChildByName("title")
        -- label:setTextColor(cc.c4b(0xd6, 0xfb, 0xff, 0xff))
        -- label:setString(self:getLabel(i))

        -- local object = {}
        -- object.tab_btn = tab_btn
        -- object.label = label
        -- object.index = i
        -- self.tab_list[i] = object

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
            object.label:setString(string.format("<div fontcolor=%s>%s</div>", Config.ColorData.data_new_color_str[6], self:getLabel(i)))
            object.tab_btn = tab_btn
            object.index = i
            self.tab_list[i] = object
        end

        if i == 2 then
            self.red_point = tab_btn:getChildByName("red_point")
        elseif i == 3 then
            self.other_red_point = tab_btn:getChildByName("red_point")
        end
    end
end

function ArenaChampionMatchWindow:register_event()
    for i, object in ipairs(self.tab_list) do
        object.tab_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playTabButtonSound()
                self:changeTabView(i)
            end
        end)
    end
	self.explain_btn:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            if self.view_type == ArenaConst.champion_type.normal then
                MainuiController:getInstance():openCommonExplainView(true, Config.ArenaChampionData.data_explain)
            else
                MainuiController:getInstance():openCommonExplainView(true, Config.ArenaClusterChampionData.data_explain)
            end
		end
	end)
	self.shop_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender,event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            if self.view_type == ArenaConst.champion_type.normal then
                MallController:getInstance():openMallPanel(true, MallConst.MallType.ArenaShop)
            else
                CrosschampionController:getInstance():openCrosschampionShopWindow(true)
            end
		end
	end)
    registerButtonEventListener(self.close_btn, function()
        if self.view_type == ArenaConst.champion_type.cross and self.ctrl:getCrosschampionOpenFlag() then
            self.ctrl:openCrosschampionMainWindow(true, true)
        end
        if self.cur_selected and self.cur_selected.index == ArenaConst.champion_index.match then
            if self.cur_panel and self.cur_panel.is_in_check_info == true then
                GlobalEvent:getInstance():Fire(ArenaEvent.CheckFightInfoEvent, false) 
            else
                ArenaController:getInstance():openArenaChampionMatchWindow(false) 
            end
        else
            ArenaController:getInstance():openArenaChampionMatchWindow(false) 
        end
    end,true, 2)

	self.my_guess_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            if self.cur_selected.index == ArenaConst.champion_index.my_match_ready then
                HeroController:getInstance():openFormMainWindow(true, PartnerConst.Fun_Form.ArenaChampion)
            else
			    ArenaController:getInstance():openArenaChampionMyGuessWindow(true, self.view_type)
            end
		end
	end)
	self.awards_btn:addTouchEventListener(function(sender, event_type)
        customClickAction(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playButtonSound2()
            ArenaController:getInstance():openArenaChampionRankAwardsWindow(true, self.view_type) 
		end
	end)

    -- 更新个人信息
    if self.update_role_info_event == nil then
        self.update_role_info_event = GlobalEvent:getInstance():Bind(ArenaEvent.UpdateChampionRoleInfoEvent, function(data)
            self:updateCurPanelInfo()
        end)
    end

    if self.change_tab_from_top_event == nil then
        self.change_tab_from_top_event = GlobalEvent:getInstance():Bind(ArenaEvent.ChangeTanFromTop324, function() 
            self:changeTabView(ArenaConst.champion_index.guess)
        end)
    end
end

--==============================--
--desc:切换标签页
--time:2018-07-31 08:02:12
--@index:
--@return 
--==============================--
function ArenaChampionMatchWindow:changeTabView( index )
    if self.cur_selected and self.cur_selected.index == index then return end
    if self.cur_selected then
        -- self.cur_selected.label:setTextColor(cc.c4b(0xd6, 0xfb, 0xff, 0xff))
        -- self.cur_selected.tab_btn:setBright(false)
        self.cur_selected.select_bg:setVisible(false)
        self.cur_selected.label:setString(string.format("<div fontcolor=%s>%s</div>", Config.ColorData.data_new_color_str[6], self:getLabel(self.cur_selected.index)))
        self.cur_selected = nil
    end
    self.cur_selected = self.tab_list[index]
    if self.cur_selected == nil then return end
    if self.cur_selected then
        self.cur_selected.select_bg:setVisible(true)
        self.cur_selected.label:setString(string.format("<div fontcolor=#ffffff shadow=0,-2,2,%s>%s</div>", Config.ColorData.data_new_color_str[2], self:getLabel(index)))
    end

    if index == ArenaConst.champion_index.my_match_ready then
        self.my_guess_btn_label:setString(TI18N("我的布阵"))
    else
        self.my_guess_btn_label:setString(TI18N("我的竞猜"))
    end
    self.my_guess_btn:setVisible(index ~= ArenaConst.champion_index.rank)

    -- 移除红点
    if index == ArenaConst.champion_index.guess then
        self.red_point:setVisible(false)
    elseif index == ArenaConst.champion_index.match then
        self.other_red_point:setVisible(false)
    end

    -- self.cur_selected.label:setTextColor(cc.c4b(0x59, 0x34, 0x29, 0xff))
    -- self.cur_selected.tab_btn:setBright(true)

    if self.cur_panel then
        self.cur_panel:addToParent(false)
    end
    self.cur_panel = self:getPanel(index)
    if self.cur_panel then
        self.cur_panel:addToParent(true) 
        if self.cur_panel.updateInfo then
            self.cur_panel:updateInfo(true)
        end  
    end
    self:updateBaseInfo()

    -- 排行榜的时候不需要显示弹幕
    GlobalEvent:getInstance():Fire(BarrageEvent.SetVisibleStatus, (index ~= ArenaConst.champion_index.rank ))
end

--==============================--
--desc:更新当前标签页的情况
--time:2018-08-04 03:08:13
--@return 
--==============================--
function ArenaChampionMatchWindow:updateCurPanelInfo()
    -- 这个时候判断一下是否需要显示红点
    local base_info = self.model:getBaseInfo()
    if self.real_panel_index ~= ArenaConst.champion_index.guess then
        if base_info and base_info.round_status == ArenaConst.champion_round_status.guess then
            self.red_point:setVisible(true)
        else
            self.red_point:setVisible(false)
        end 
    end

    -- 32强赛
    if self.real_panel_index ~= ArenaConst.champion_index.match then
        if self.had_show == false then
            if base_info then
                if base_info.step == ArenaConst.champion_step.match_32 or base_info.step == ArenaConst.champion_step.match_4 or 
                base_info.step == ArenaConst.champion_step.match_64 or base_info.step == ArenaConst.champion_step.match_8 then
                    if base_info.step_status == ArenaConst.champion_step_status.opened then
                        self.other_red_point:setVisible(true)
                        self.had_show = true
                    else
                        self.other_red_point:setVisible(false)
                    end
                end
            end
        end
    end

    local is_change_tab = false
    if self.cur_selected and self.cur_selected.index == ArenaConst.champion_index.my_match_ready then -- 改变状态
        local cur_index = self.real_panel_index
        local index = self:changeMyMatchStatus()
        is_change_tab = (index ~= cur_index) 
    end
    if self.cur_panel and self.cur_panel.updateInfo then
        self.cur_panel:updateInfo(is_change_tab)
    end

    self:updateBaseInfo()
end

--==============================--
--desc:如果是第一个标签的话,那就做一下判断是否要切换显示
--time:2018-08-04 10:32:02
--@return 
--==============================--
function ArenaChampionMatchWindow:changeMyMatchStatus()
    local index = ArenaConst.champion_index.my_match_ready
    if self.model:getMyMatchStatus() == ArenaConst.champion_my_status.in_match then
        index = ArenaConst.champion_index.my_match   
    end
    if self.real_panel_index == index then 
        return index
    end
    if self.cur_panel then
        self.cur_panel:addToParent(false)
        self.cur_panel = nil
    end
    self.cur_panel = self:getPanel(ArenaConst.champion_index.my_match_ready)
    if self.cur_panel then
        self.cur_panel:addToParent(true)
    end
    return index
end

--==============================--
--desc:获取面板
--time:2018-08-01 10:29:34
--@index:
--@return 
--==============================--
function ArenaChampionMatchWindow:getPanel(index)
    if index == ArenaConst.champion_index.my_match_ready then
        if self.model:getMyMatchStatus() == ArenaConst.champion_my_status.in_match then
            index = ArenaConst.champion_index.my_match   
        end
    end
    local panel = self.panel_list[index]
    if panel == nil then
        if index == ArenaConst.champion_index.my_match_ready then
            panel = ArenaChampionMyMatchReadyPanel.new(self.view_type)
        elseif index == ArenaConst.champion_index.my_match then
            panel = ArenaChampionMyMatchPanel.new(self.view_type)
        elseif index == ArenaConst.champion_index.guess then
            panel = ArenaChampionCurGuessPanel.new(self.view_type)
        elseif index == ArenaConst.champion_index.match then
            panel = ArenaChampionTop32Panel.new(self.view_type)
        elseif index == ArenaConst.champion_index.rank then
            panel = ArenaChampionCurRankPanel.new(self.view_type)
        end
        if panel then
            self.container:addChild(panel)
        end
    end
    self.panel_list[index] = panel
    -- 记录真实的下标
    self.real_panel_index = index
    return panel
end

function ArenaChampionMatchWindow:openRootWnd(index)
    index = index or ArenaConst.champion_index.my_match_ready
    self:changeTabView(index)

    local base_info = self.model:getBaseInfo()
    if base_info then
        if base_info.round_status == ArenaConst.champion_round_status.guess then
            self.red_point:setVisible(true)
        else
            self.red_point:setVisible(false)
        end

        -- 32强赛
        if base_info.step == ArenaConst.champion_step.match_32 or base_info.step == ArenaConst.champion_step.match_4 or 
        base_info.step == ArenaConst.champion_step.match_64 or base_info.step == ArenaConst.champion_step.match_8 then
            if base_info.step_status == ArenaConst.champion_step_status.opened then
                self.other_red_point:setVisible(true)
                self.had_show = true
            else
                self.other_red_point:setVisible(false)
            end
        end
    end

    -- 打开弹幕
    if self.view_type == ArenaConst.champion_type.normal then
        GlobalEvent:getInstance():Fire(BarrageEvent.HandleBarrageType, true, BarrageConst.type.champion) 
    else
        self.ctrl:sender26216()
        GlobalEvent:getInstance():Fire(BarrageEvent.HandleBarrageType, true, BarrageConst.type.crosschampion)
    end
end

--==============================--
--desc:更新基础描述显示
--time:2018-08-05 12:50:04
--@return 
--==============================--
function ArenaChampionMatchWindow:updateBaseInfo()
    local base_info = self.model:getBaseInfo()
    if base_info == nil then return end
    
    if self.real_panel_index == ArenaConst.champion_index.my_match_ready or self.real_panel_index == ArenaConst.champion_index.rank then
        self.panel_title:setVisible(false)
        self.match_time_label:setVisible(false)
        self:clearTimeTicket()
    else
        self.panel_title:setVisible(true)
        self:setChampionStepInfo()
        if (base_info.step == ArenaConst.champion_step.match_4 or base_info.step == ArenaConst.champion_step.match_8) and base_info.step_status == ArenaConst.champion_step_status.over then
            self:clearTimeTicket()
            self.match_time_label:setVisible(false)
        else
            self.match_time_label:setVisible(true)
            if self.time_ticket == nil then
                self.time_ticket = GlobalTimeTicket:getInstance():add(function()
                    self:countDownTimeTicket()
                end, 1)
            end 
            self:countDownTimeTicket()
        end
    end
end

--==============================--
--desc:移除时间计时器
--time:2018-08-04 04:40:58
--@return 
--==============================--
function ArenaChampionMatchWindow:clearTimeTicket()
	if self.time_ticket ~= nil then
		GlobalTimeTicket:getInstance():remove(self.time_ticket)
		self.time_ticket = nil
	end
end 

function ArenaChampionMatchWindow:countDownTimeTicket()
	local base_info = self.model:getBaseInfo()
	if base_info == nil then
		self:clearTimeTicket()
		return
	end
    local end_time = game_net:getTime()

    if base_info.step == ArenaConst.champion_step.unopened then
        end_time = base_info.step_status_time 
    elseif base_info.step == ArenaConst.champion_step.score and base_info.step_status == ArenaConst.champion_step_status.unopened then
        end_time = base_info.step_status_time 
    else
        end_time = base_info.round_status_time
    end
	local less_time = end_time - game_net:getTime()
	if less_time < 0 then
		less_time = 0
		self:clearTimeTicket()
	end

    local str = ""
    if base_info.step == ArenaConst.champion_step.unopened or base_info.step_status == ArenaConst.champion_step_status.unopened then
        str = string_format(TI18N("距离开始:%s"), TimeTool.GetTimeFormat(less_time)) 
    else
        if base_info.round_status == ArenaConst.champion_round_status.prepare then
            str = string_format(TI18N("准备阶段:%s"), TimeTool.GetTimeFormat(less_time)) 
        elseif base_info.round_status == ArenaConst.champion_round_status.guess then
            str = string_format(TI18N("竞猜阶段:%s"), TimeTool.GetTimeFormat(less_time)) 
        else
            str = string_format(TI18N("比赛阶段:%s"), TimeTool.GetTimeFormat(less_time)) 
        end
    end
	self.match_time_label:setString(str)
end 

--==============================--
--desc:设置冠军赛阶段显示,这里需要判断自己是否进入了对应的阶段
--time:2018-08-04 05:44:04
--@return 
--==============================--
function ArenaChampionMatchWindow:setChampionStepInfo()
    local base_info = self.model:getBaseInfo()
    local role_info = self.model:getRoleInfo()
    if base_info == nil or role_info == nil then return end

    if base_info.step == ArenaConst.champion_step.unopened then
        local desc = string_format(TI18N("下次冠军赛 %s"), TimeTool.getMD(base_info.step_status_time))
        if self.view_type == ArenaConst.champion_type.cross then
            desc = string_format(TI18N("下次周冠军赛 %s"), TimeTool.getMD(base_info.step_status_time))
        end
        self.panel_title:setString(desc) 
    elseif base_info.step == ArenaConst.champion_step.score then
        if base_info.step_status == ArenaConst.champion_step_status.unopened then
            local desc = string_format(TI18N("下次冠军赛 %s"), TimeTool.getMD(base_info.step_status_time))
            if self.view_type == ArenaConst.champion_type.cross then
                desc = string_format(TI18N("下次周冠军赛 %s"), TimeTool.getMD(base_info.step_status_time))
            end
            self.panel_title:setString(desc) 
        elseif base_info.step_status == ArenaConst.champion_step_status.opened then
            self.panel_title:setString(string_format(TI18N("%s第%s回合"), ArenaConst.getMatchStepDesc(base_info.step), base_info.round)) 
        end
    elseif base_info.step == ArenaConst.champion_step.match_64 then
        if base_info.step_status == ArenaConst.champion_step_status.unopened then
            self.panel_title:setString(TI18N("下轮64强赛"))
        elseif base_info.step_status == ArenaConst.champion_step_status.opened then
            if base_info.round <= 1 then
                if role_info.rank > 64 then
                    self.panel_title:setString(TI18N("32强赛"))
                else
                    self.panel_title:setString(string_format(TI18N("32强赛%s"), ArenaConst.getGroup(role_info.group)))
                end
            elseif base_info.round == 2 then
                if role_info.rank > 32 then
                    self.panel_title:setString(TI18N("16强赛"))
                else
                    self.panel_title:setString(string_format(TI18N("16强赛%s"), ArenaConst.getGroup(role_info.group)))
                end
            elseif base_info.round == 3 then
                if role_info.rank > 16 then
                    self.panel_title:setString(TI18N("8强赛"))
                else
                    self.panel_title:setString(string_format(TI18N("8强赛%s"), ArenaConst.getGroup(role_info.group)))
                end
            end
        end
    elseif base_info.step == ArenaConst.champion_step.match_32 then
        if base_info.step_status == ArenaConst.champion_step_status.unopened then
            self.panel_title:setString(TI18N("下轮32强赛"))
        elseif base_info.step_status == ArenaConst.champion_step_status.opened then
            if base_info.round <= 1 then
                if role_info.rank > 32 then
                    self.panel_title:setString(TI18N("16强赛"))
                else
                    self.panel_title:setString(string_format(TI18N("16强赛%s"), ArenaConst.getGroup(role_info.group)))
                end
            elseif base_info.round == 2 then
                if role_info.rank > 16 then
                    self.panel_title:setString(TI18N("8强赛"))
                else
                    self.panel_title:setString(string_format(TI18N("8强赛%s"), ArenaConst.getGroup(role_info.group)))
                end
            elseif base_info.round == 3 then
                if role_info.rank > 8 then
                    self.panel_title:setString(TI18N("4强赛"))
                else
                    self.panel_title:setString(string_format(TI18N("4强赛%s"), ArenaConst.getGroup(role_info.group)))
                end
            end
        end
    elseif base_info.step == ArenaConst.champion_step.match_8 then
        if base_info.step_status == ArenaConst.champion_step_status.opened then
            if base_info.round == 1 then
                self.panel_title:setString(TI18N("4强赛"))
            elseif base_info.round == 2 then
                self.panel_title:setString(TI18N("半决赛"))
            elseif base_info.round == 3 then
                self.panel_title:setString(TI18N("决赛"))
            end
        elseif base_info.step_status == ArenaConst.champion_step_status.over then
            if self.view_type == ArenaConst.champion_type.normal then
                self.panel_title:setString(TI18N("本轮冠军赛已结束"))
            else
                self.panel_title:setString(TI18N("本轮周冠军赛已结束"))
            end
        end
    elseif base_info.step == ArenaConst.champion_step.match_4 then
        if base_info.step_status == ArenaConst.champion_step_status.opened then
            if base_info.round == 1 then
                self.panel_title:setString(TI18N("半决赛"))
            elseif base_info.round == 2 then
                self.panel_title:setString(TI18N("决赛"))
            end
        elseif base_info.step_status == ArenaConst.champion_step_status.over then
            if self.view_type == ArenaConst.champion_type.normal then
                self.panel_title:setString(TI18N("本轮冠军赛已结束"))
            else
                self.panel_title:setString(TI18N("本轮周冠军赛已结束"))
            end
        end
    end
end 

function ArenaChampionMatchWindow:close_callback()
    GlobalEvent:getInstance():Fire(BarrageEvent.HandleBarrageType, false)
    self:clearTimeTicket()

    if self.update_role_info_event  then
        GlobalEvent:getInstance():UnBind(self.update_role_info_event)
        self.update_role_info_event = nil
    end
    if self.change_tab_from_top_event then
        GlobalEvent:getInstance():UnBind(self.change_tab_from_top_event)
        self.change_tab_from_top_event = nil
    end
    for k, panel in pairs(self.panel_list) do
        panel:DeleteMe()
    end
    self.panel_list = nil
    CrosschampionController:getInstance():setCrosschampionOpenFlag(false)
    ArenaController:getInstance():openArenaChampionMatchWindow(false)
end

--==============================--
--desc:设置标签按钮
--time:2018-07-31 08:44:00
--@index:
--@return 
--==============================--
function ArenaChampionMatchWindow:getLabel(index)
    if index == ArenaConst.champion_index.my_match_ready then
        return TI18N("我的竞赛")
    elseif index == ArenaConst.champion_index.guess then
        return TI18N("竞猜")
    elseif index == ArenaConst.champion_index.match then
        if self.view_type == ArenaConst.champion_type.normal then
            return TI18N("32强赛")
        else
            return TI18N("64强赛")
        end
    elseif index == ArenaConst.champion_index.rank then
        return TI18N("排行榜")
    end
end