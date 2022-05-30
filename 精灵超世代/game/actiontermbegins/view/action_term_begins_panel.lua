-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      活动开启界面
--      开学季活动boss战 后端 锦汉 策划 建军 
-- <br/> 2019年8月22日
-- --------------------------------------------------------------------
ActiontermbeginsPanel = class("ActiontermbeginsPanel", function()
    return ccui.Widget:create()
end)

function ActiontermbeginsPanel:ctor(bid, type)
    self.holiday_bid = bid
    self:configUI()
    self:register_event()
end

function ActiontermbeginsPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("actiontermbegins/action_term_begins_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.title_img = main_container:getChildByName("title_img")

    if not self.item_load then
        local res = PathTool.getPlistImgForDownLoad("bigbg/termbegins", "action_term_begins_bg", true)
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.title_img) then
                loadSpriteTexture(self.title_img, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    self.item_scrollview = main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    local config_action_pre_reward = Config.HolidayTermBeginsData.data_const.action_pre_reward
    if config_action_pre_reward and not self.item_list then
        local data_list = config_action_pre_reward.val
        local setting = {}
        setting.scale = 0.9
        setting.max_count = 5
        setting.is_center = true
        setting.show_effect_id = 263
        self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
    end
    --时间
    self.time_title = main_container:getChildByName("time_title")
    self.time_title:setString(TI18N("活动时间:"))
    self.time_val = main_container:getChildByName("time_val")
    self.time_val:setString("")
    

    main_container:getChildByName("Text_1"):setString(TI18N("世界排名:"))
    main_container:getChildByName("Text_2"):setString(TI18N("捐献数量:"))
    main_container:getChildByName("Text_3"):setString(TI18N("击败怪物:"))

    self.fight_score_1 = main_container:getChildByName("fight_score_1")
    self.fight_score_2 = main_container:getChildByName("fight_score_2")
    self.fight_score_3 = main_container:getChildByName("fight_score_3")

    self.comfirm_btn = main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_label:setString(TI18N("前往挑战"))

    ActiontermbeginsController:getInstance():sender26711()

    local vo = ActionController:getInstance():getHolidayAweradsStatus(self.holiday_bid)
    self:updateComfirmRedPoint(vo)
end

function ActiontermbeginsPanel:register_event()
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActiontermbeginsEvent.ACTION_TERM_BEGINS_EVENT,function (data)
            if not data then return end
            self:setData(data)
        end)
    end

    if not self.update_holiday_red_event then
        self.update_holiday_red_event = GlobalEvent:getInstance():Bind(ActionEvent.UPDATE_HOLIDAY_TAB_STATUS,function (function_id, vo)
            self:updateComfirmRedPoint(vo)
        end)
    end

    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn() end,true, 2)
    -- registerButtonEventListener(self.reward_btn, function() self:onRewardBtn() end,true, 2)
end

function ActiontermbeginsPanel:updateComfirmRedPoint(vo)
    if not self.holiday_bid then return end
    if vo and vo.bid == self.holiday_bid then
        if vo.status then
            addRedPointToNodeByStatus(self.comfirm_btn, true, 5, 5)
        else
            addRedPointToNodeByStatus(self.comfirm_btn, false, 5, 5)
        end
    end 
end
--前往战斗
function ActiontermbeginsPanel:onComfirmBtn()
    -- ActiontermbeginsController:getInstance():openActiontermbeginsFightResultPanel(true, data)
    MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.TermBegins) 
end
-- --查看奖励详情
-- function ActiontermbeginsPanel:onRewardBtn()
--     local setting = {}
--     setting.rank_type = RankConstant.RankType.sandybeach_boss_fight
--     setting.title_name = TI18N("排行榜")
--     setting.background_path = PathTool.getPlistImgForDownLoad("bigbg/sandybeachbossfight", "sandybeach_1")
--     setting.show_tips = TI18N("奖励将在活动结束后通过邮件发放")
--     RankController:getInstance():openSingleRankMainWindow(true, setting, RankConstant.Rank_Type.Award)
-- end

function ActiontermbeginsPanel:setData(data)
    if data.rank == 0 then
        self.fight_score_1:setString(TI18N("暂无"))
    else
        self.fight_score_1:setString(string.format(TI18N("前%s%%"), data.rank) )
    end
    self.fight_score_2:setString(data.count)
    self.fight_score_3:setString(data.order)

    local config = Config.HolidayTermBeginsData.data_round_info[data.round]
    if config then
        self.time_val:setString(config.action_time)
    end
end

function ActiontermbeginsPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
end

function ActiontermbeginsPanel:DeleteMe()
    if self.update_action_even_event then
        GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end
    
    if self.update_holiday_red_event then
        GlobalEvent:getInstance():UnBind(self.update_holiday_red_event)
        self.update_holiday_red_event = nil
    end

    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_scrollview)

    if self.item_load then 
        self.item_load:DeleteMe()
        self.item_load = nil
    end
end

