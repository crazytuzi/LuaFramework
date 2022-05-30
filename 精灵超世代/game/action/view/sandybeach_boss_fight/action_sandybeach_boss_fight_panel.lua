 -- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
-- 沙滩争夺战  后端: 锋林 需求: 罗登耀
--
ActionSandybeachBossFightPanel = class("ActionSandybeachBossFightPanel", function()
    return ccui.Widget:create()
end)

local const_data = Config.HolidayBossData.data_const
function ActionSandybeachBossFightPanel:ctor(bid, type)
    self.holiday_bid = bid

    self:configUI()
    self:register_event()
end

function ActionSandybeachBossFightPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("acitonsandybeachbossfight/action_sandybeach_boss_fight_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    self.title_img = main_container:getChildByName("title_img")

    if not self.item_load then
        local res = PathTool.getPlistImgForDownLoad("bigbg/sandybeachbossfight", "txt_cn_sandybeach_1")
        self.item_load = createResourcesLoad(res, ResourcesType.single, function()
            if not tolua.isnull(self.title_img) then
                loadSpriteTexture(self.title_img, res, LOADTEXT_TYPE)
            end
        end,self.item_load)
    end

    self.item_scrollview = main_container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    local config_action_pre_reward = const_data.action_pre_reward
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
    local config_action_time = const_data.action_time
    if config_action_time then
        self.time_val:setString(config_action_time.desc)
    end

    main_container:getChildByName("Text_1"):setString(TI18N("试炼彩星:"))
    main_container:getChildByName("Text_2"):setString(TI18N("全服排名:"))
    main_container:getChildByName("Text_3"):setString(TI18N("通关层数:"))
    main_container:getChildByName("item_count_0"):setString(TI18N("剩余次数："))

    self.fight_score_1 = main_container:getChildByName("fight_score_1")
    self.fight_score_2 = main_container:getChildByName("fight_score_2")
    self.fight_score_3 = main_container:getChildByName("fight_score_3")

    --挑战次数
    self.item_count = main_container:getChildByName("item_count")
    self.item_count:setString("")

    self.comfirm_btn = main_container:getChildByName("comfirm_btn")
    self.comfirm_label = self.comfirm_btn:getChildByName("label")
    self.comfirm_label:setString(TI18N("前往挑战"))
    self.reward_btn = main_container:getChildByName("reward_btn")
    self.reward_label = self.reward_btn:getChildByName("label")
    self.reward_label:setString(TI18N("奖励详情"))

    ActionController:getInstance():sender25400()
end

function ActionSandybeachBossFightPanel:register_event()
    if not self.update_action_even_event then
        self.update_action_even_event = GlobalEvent:getInstance():Bind(ActionEvent.Aandybeach_Boss_Fight_Action_Event,function (data)
            if not data then return end
            self:setData(data)
        end)
    end
    if not self.updata_buy_count_event then
        self.updata_buy_count_event = GlobalEvent:getInstance():Bind(ActionEvent.Aandybeach_Boss_Fight_Buy_Count_Event,function (data)
            if not data then return end
            self:setRemainCount(data.count)
        end)
    end

    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn() end,true, 2)
    registerButtonEventListener(self.reward_btn, function() self:onRewardBtn() end,true, 2)
end
--前往战斗
function ActionSandybeachBossFightPanel:onComfirmBtn()
    MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.SandybeachBossFight) 
end
--查看奖励详情
function ActionSandybeachBossFightPanel:onRewardBtn()
    local setting = {}
    setting.rank_type = RankConstant.RankType.sandybeach_boss_fight
    setting.title_name = TI18N("排行榜")
    setting.background_path = PathTool.getPlistImgForDownLoad("bigbg/sandybeachbossfight", "sandybeach_1")
    setting.show_tips = TI18N("奖励将在活动结束后通过邮件发放")
    RankController:getInstance():openSingleRankMainWindow(true, setting, RankConstant.Rank_Type.Award)
end

function ActionSandybeachBossFightPanel:setData(data)
    self.fight_score_1:setString(data.score)
    self.fight_score_2:setString(data.rank)
    self.fight_score_3:setString(data.order)

    self:setRemainCount(data.count)
end
--剩余次数
function ActionSandybeachBossFightPanel:setRemainCount(count)
    if self.item_count then
        local max_count = 10
        local config_fight_max_count = const_data.fight_max_count
        if config_fight_max_count then
            max_count = config_fight_max_count.val
        end
        self.item_count:setString(string.format(TI18N("%s/%s"), count, max_count))
    end
end

function ActionSandybeachBossFightPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool) 
end

function ActionSandybeachBossFightPanel:DeleteMe()
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
    if self.update_action_even_event then
        GlobalEvent:getInstance():UnBind(self.update_action_even_event)
        self.update_action_even_event = nil
    end
    if self.updata_buy_count_event then
        GlobalEvent:getInstance():UnBind(self.updata_buy_count_event)
        self.updata_buy_count_event = nil
    end
end

