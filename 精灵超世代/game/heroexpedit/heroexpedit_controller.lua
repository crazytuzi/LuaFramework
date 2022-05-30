HeroExpeditController = HeroExpeditController or BaseClass(BaseController)

function HeroExpeditController:config()
    self.model = HeroExpeditModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function HeroExpeditController:getModel()
    return self.model
end

function HeroExpeditController:registerEvents()
    if self.re_link_game_event == nil then
        self.re_link_game_event = GlobalEvent:getInstance():Bind(LoginEvent.RE_LINK_GAME, function()
            self:openHeroExpeditView(false)
            self:openHeroExpeditLevelView(false)
            self:openEmpolyPanelView(false)
            self:openBrowsePanelView(false)
        end)
    end

    if self.expedit_updata_event == nil then
        self.expedit_updata_event = GlobalEvent:getInstance():Bind(BattleEvent.CLOSE_RESULT_VIEW, function(combat_type)
            if combat_type == BattleConst.Fight_Type.ExpeditFight then
                if self.need_reset_event == true then
                    self:showExpeditReset()
                    self.need_reset_event = false
                end
            end
        end)
    end
end

function HeroExpeditController:registerProtocals()
    self:RegisterProtocal(24400, "handle24400")
    self:RegisterProtocal(24401, "handle24401")
    self:RegisterProtocal(24402, "handle24402")
    self:RegisterProtocal(24403, "hander24403")
    self:RegisterProtocal(24405, "hander24405")
    self:RegisterProtocal(24406, "hander24406")
    self:RegisterProtocal(24407, "hander24407")
    self:RegisterProtocal(24408, "hander24408")
    self:RegisterProtocal(24409, "hander24409")
    self:RegisterProtocal(24410, "hander24410")
    self:RegisterProtocal(24411, "hander24411")
    self:RegisterProtocal(24412, "hander24412")
    self:RegisterProtocal(24413, "hander24413")
    self:RegisterProtocal(24414, "hander24414")
    self:RegisterProtocal(24415, "hander24415")
end

--请求远征数据
function HeroExpeditController:sender24400()
    self:SendProtocal(24400, {})
end
function HeroExpeditController:handle24400(data)
    self.model:setExpeditData(data)
    self.grard_id = data.guard_id
    self.max_difficulty = data.max_difficulty
    self.model:setDifferentChoose(data.difficulty)
    GlobalEvent:getInstance():Fire(HeroExpeditEvent.HeroExpeditViewEvent, data)
    GlobalEvent:getInstance():Fire(HeroExpeditEvent.Expedit_RedPoint_Event)
    if NEEDCHANGEENTERSTATUS == 1 and not self.first_enter then
        self.first_enter  = true
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.ExpeditFight)
    end
end

--当前最大的关卡
function HeroExpeditController:getGrardID()
    if self.grard_id then
        return self.grard_id
    end
    return 1
end
function HeroExpeditController:getMaxDifficulty()
    if self.max_difficulty then
        return self.max_difficulty
    end
    return 0
end

--获取关卡守将信息
function HeroExpeditController:sender24401(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(24401, proto)
end
function HeroExpeditController:handle24401(data)
    if not data then return end
    local box_pos = self.model:getExpeditBoxData()
    local status = false
    for i,v in pairs(box_pos) do
        if v == data.id then
            status = true
            break
        end
    end
    if status == true then
        self:openBrowsePanelView(true, data)
    else
        local grard_id = self:getGrardID()
        if data.id <= grard_id then
            self:openHeroExpeditLevelView(true)
            GlobalEvent:getInstance():Fire(HeroExpeditEvent.levelMessageEvent, data)
        else
            message(TI18N("先通关前置关卡"))
        end
    end
end
--领取关卡宝箱
function HeroExpeditController:sender24402(id)
    local proto = {}
    proto.id = id
    self:SendProtocal(24402,proto)
end
function HeroExpeditController:handle24402(data)
    message(data.msg)
    if data.code == 1 then
        local expedit_data = self.model:getExpeditData()
        table.insert(expedit_data.reward, {reward_id = data.id})
        GlobalEvent:getInstance():Fire(HeroExpeditEvent.Get_Box_Event, data.id)
    end
end

--挑战
function HeroExpeditController:sender24403(formation_type,pos_info,hallows_id)
    local proto = {}
    proto.formation_type = formation_type
    proto.pos_info = pos_info
    proto.hallows_id = hallows_id
    self:SendProtocal(24403, proto)
end
function HeroExpeditController:hander24403(data)
    message(data.msg)
    if data.code == 1 then
        HeroController:getInstance():openFormGoFightPanel(false)
    end
end

--我的支援
function HeroExpeditController:sender24405()
    self:SendProtocal(24405,{})
end
function HeroExpeditController:hander24405(data)
    GlobalEvent:getInstance():Fire(HeroExpeditEvent.Employ_Me_Help,data)
end
--我的支援选择伙伴，返回24405
function HeroExpeditController:sender24407(id)
    local proto = {}
    proto.id = id 
    self:SendProtocal(24407,proto)
end
function HeroExpeditController:hander24407(data)
    message(data.msg)
end
--支援我的
function HeroExpeditController:sender24406()
    self:SendProtocal(24406,{})
end
function HeroExpeditController:hander24406(data)
    self.model:setEmployHelpMeData(data.list)
    GlobalEvent:getInstance():Fire(HeroExpeditEvent.Employ_Help_Me)
end
--支援我的  选择伙伴  返回24406
function HeroExpeditController:sender24408(rid,srv_id,id)
    local proto = {}
    proto.rid = rid
    proto.srv_id = srv_id
    proto.id = id
    self:SendProtocal(24408,proto)
end
function HeroExpeditController:hander24408(data)
    message(data.msg)
end
--宝可梦出战
function HeroExpeditController:sender24409()
    self:SendProtocal(24409,{})
end
function HeroExpeditController:hander24409(data)
    self.model:setHeroBloodById(data)
end

--远征红点,,仅限过关
function HeroExpeditController:sender24410()
    self:SendProtocal(24410,{})
end
function HeroExpeditController:hander24410(data)
    self.model:setIsChangeRedPoint(data.is_show)
end
--派遣是否显示红点
function HeroExpeditController:sender24411()
    self:SendProtocal(24411,{})
end
function HeroExpeditController:hander24411(data)
    self.model:setHeroSendRedPoint(data.is_show)
    GlobalEvent:getInstance():Fire(HeroExpeditEvent.MeHelp_RedPoint_Event)
end
--选择难度
function HeroExpeditController:sender24412(id)
    local proto = {}
    proto.difficulty = id
    self:SendProtocal(24412,proto)
end
function HeroExpeditController:hander24412(data)
    message(data.msg)
    if data.code == 1 then
        self:openModeChooseView(false)
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.ExpeditFight)
    end
end
function HeroExpeditController:hander24413(data)
    local ui_fight_type = MainuiController:getInstance():getUIFightType()
    if ui_fight_type == MainuiConst.ui_fight_type.expedit_fight then
        local is_in_fight = BattleController:getInstance():isInFight()
        if is_in_fight then --如果是在战斗中,则等战斗结束之后,弹出提示
           self.need_reset_event = true
        else
            self:showExpeditReset()
        end
    end
end
--自动扫荡
function HeroExpeditController:hander24414(data)
    self:openHeroexpeditResultView(true,data)
    GlobalEvent:getInstance():Fire(HeroExpeditEvent.Expedit_Clear_Event,data)
end
--远征录像
function HeroExpeditController:sender24415(guard_id)
    local proto = {}
    proto.guard_id = guard_id
    self:SendProtocal(24415,proto)
end
function HeroExpeditController:hander24415(data)
    GlobalEvent:getInstance():Fire(HeroExpeditEvent.Expedit_Video_Event,data)
end
function HeroExpeditController:requestEnterHeroExpedit()
    PlanesController:getInstance():openPlanesMainWindow(true)
    --[[ local open_data = Config.DailyplayData.data_exerciseactivity[EsecsiceConst.exercise_index.heroexpedit]
    if open_data == nil then
        message(TI18N("远征数据异常"))
        return
    end
    local bool = MainuiController:getInstance():checkIsOpenByActivate(open_data.activate)
    if bool == false then 
        message(open_data.lock_desc)
        return 
    end
    local choose = self.model:getDifferentChoose()
    if choose == 0 then
        self:openModeChooseView(true)
    else
        MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.ExpeditFight)
    end ]]
end

--检查是否开启功能
function HeroExpeditController:checkoutExpeditIsOpen()
    local is_open = false
    local open_data = Config.DailyplayData.data_exerciseactivity[EsecsiceConst.exercise_index.heroexpedit]
    if open_data == nil then
        message(TI18N("远征数据异常"))
    end
    local bool = MainuiController:getInstance():checkIsOpenByActivate(open_data.activate)
    if bool == true then
        is_open = true 
    end

    return is_open
end

function HeroExpeditController:showExpeditReset()
    MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.main_scene)

    delayOnce(function() 
        local msg = TI18N("远征已重置，是否重新进入？")
        CommonAlert.show(msg, TI18N("确定"),function() 
            self:requestEnterHeroExpedit()
        end, TI18N("取消"))
    end, 0.2)     
end
--打开远征界面
function HeroExpeditController:openHeroExpeditView(bool)
    --[[ if bool == true then 
        if not self.heroExpeditView then
            self.heroExpeditView = HeroExpeditWindow.New()
        end
        self.heroExpeditView:open()
    else
        if self.heroExpeditView then
            self.heroExpeditView:close()
            self.heroExpeditView = nil
        end
    end ]]
end
--打开远征关卡信息界面
function HeroExpeditController:openHeroExpeditLevelView(bool)
    --[[ if bool == true then 
        if not self.heroExpeditLevelView then
            self.heroExpeditLevelView = HeroExpeditLevel.New()
        end
        self.heroExpeditLevelView:open()
    else
        if self.heroExpeditLevelView then 
            self.heroExpeditLevelView:close()
            self.heroExpeditLevelView = nil
        end
    end ]]
end
--打开远征雇佣界面
function HeroExpeditController:openEmpolyPanelView(bool)
    --[[ if bool == true then 
        if not self.empolyPanelView then
            self.empolyPanelView = EmpolyPanel.New()
        end
        self.empolyPanelView:open()
    else
        if self.empolyPanelView then 
            self.empolyPanelView:close()
            self.empolyPanelView = nil
        end
    end ]]
end
--打开查看宝箱奖励
function HeroExpeditController:openBrowsePanelView(bool, data)
    --[[ if bool == true then 
        if not self.browsePanelView then
            self.browsePanelView = BrowsePanel.New()
        end
        self.browsePanelView:open(data)
    else
        if self.browsePanelView then 
            self.browsePanelView:close()
            self.browsePanelView = nil
        end
    end ]]
end
--打开难度选择界面
function HeroExpeditController:openModeChooseView(bool)
    --[[ if bool == true then 
        if not self.mode_choose_view then
            self.mode_choose_view = ModeChooseWindow.New()
        end
        self.mode_choose_view:open()
    else
        if self.mode_choose_view then 
            self.mode_choose_view:close()
            self.mode_choose_view = nil
        end
    end ]]
end
--扫荡结算界面
function HeroExpeditController:openHeroexpeditResultView(bool,data)
    --[[ if bool == true then 
        if not self.expedit_result_view then
            self.expedit_result_view = HeroexpeditResultWindow.New(data)
        end
        self.expedit_result_view:open()
    else
        if self.expedit_result_view then 
            self.expedit_result_view:close()
            self.expedit_result_view = nil
        end
    end ]]
end
--打开录像馆
function HeroExpeditController:openHeroexpeditVideoView(bool,cur_grard_id)
    --[[ if bool == true then 
        if not self.expedit_video_view then
            self.expedit_video_view = HeroexpeditVideoWindow.New()
        end
        self.expedit_video_view:open(cur_grard_id)
    else
        if self.expedit_video_view then 
            self.expedit_video_view:close()
            self.expedit_video_view = nil
        end
    end ]]
end

function HeroExpeditController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end