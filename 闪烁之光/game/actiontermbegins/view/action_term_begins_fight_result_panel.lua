-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      boss战斗结算
-- <br/>Create: 2019年8月26日
--
-- --------------------------------------------------------------------
ActiontermbeginsFightResultPanel = ActiontermbeginsFightResultPanel or BaseClass(BaseView)

local controller = ActiontermbeginsController:getInstance()
local model = ActiontermbeginsController:getInstance():getModel()
local string_format = string.format
local table_insert = table.insert

function ActiontermbeginsFightResultPanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Tips
    self.is_full_screen = false
    self.effect_cache_list = {}
    self.layout_name = "actiontermbegins/action_term_begins_fight_result_panel"
    
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("guildboss", "guildboss"), type = ResourcesType.plist}
    }

    self.fight_type = BattleConst.Fight_Type.GuildDun
end

function ActiontermbeginsFightResultPanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")

    self.title_container = self.root_wnd:getChildByName("title_container") 
    self.title_width = self.title_container:getContentSize().width
    self.title_height = self.title_container:getContentSize().height

    -- self.dps_list_btn = container:getChildByName("dps_list_btn")        -- 查看伤害排名的
    self.harm_btn = container:getChildByName("harm_btn")
    self.harm_btn:setVisible(false)
    self.harm_btn:getChildByName("harm_lab"):setString(TI18N("数据统计"))

    self.partner_item = HeroExhibitionItem.new(1, false)
    self.partner_item:setPosition(560, 192)
    container:addChild(self.partner_item)
    self.dps_value = container:getChildByName("dps_value")
    self.container = container

    self.fight_text = createLabel(24, cc.c4b(0xff,0xee,0xac,0xff), nil, 360, 380, "",self.container, nil, cc.p(0.5,0.5))

    self.item_scrollview = self.container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    -- self.item_scrollview:setSwallowTouches(false)

    self.comfirm_btn = createButton(self.container,TI18N("确 定"), 620, 500, cc.size(162, 62), PathTool.getResFrame("common", "common_1017"), 24, Config.ColorData.data_color4[1])
    self.comfirm_btn:setPosition(self.container:getContentSize().width / 2 - 170, 42)
    self.comfirm_btn:enableOutline(Config.ColorData.data_color4[264], 2)
    self.comfirm_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openActiontermbeginsFightResultPanel(false)
        end
    end)

    self.cancel_btn = createButton(self.container,TI18N("返回玩法"), 620, 500, cc.size(162, 62), PathTool.getResFrame("common", "common_1018"), 24, Config.ColorData.data_color4[1])
    self.cancel_btn:setPosition(self.container:getContentSize().width / 2 + 170, 42)
    self.cancel_btn:enableOutline(Config.ColorData.data_color4[263], 2)
    self.cancel_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local cur_win = BaseView.winMap[#BaseView.winMap-1]
            if cur_win and cur_win.layout_name == "actiontermbegins/action_term_begins_main_window" then
                controller:openActiontermbeginsFightResultPanel(false)
            else
                MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.TermBegins, {index = 2}) 
            end
        end
    end)
end

function ActiontermbeginsFightResultPanel:register_event()
    self.background:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openActiontermbeginsFightResultPanel(false)
        end
    end)
    registerButtonEventListener(self.harm_btn, handler(self, self._onClickHarmBtn), true)
end

function ActiontermbeginsFightResultPanel:_onClickHarmBtn(  )
    if self.data and next(self.data) ~= nil then
        BattleController:getInstance():openBattleHarmInfoView(true, self.data)
    end
end

function ActiontermbeginsFightResultPanel:openRootWnd(data, fight_type)
    data = data or {}
    self.fight_type = BattleConst.Fight_Type.TermBeginsBoss
    if self.fight_text then
        local name = Config.BattleBgData.data_fight_name[self.fight_type]
        if name then
            self.fight_text:setString(TI18N("当前战斗：")..name)
        end
    end

    self:handleEffect(true)
    if data ~= nil then
        self.data = data
        self.dps_value:setString(string.format(TI18N("总伤害：%s"), data.all_dps))
        local hero_vo = HeroController:getInstance():getModel():getHeroById(data.best_partner)
        self.partner_item:setData(hero_vo)
        self:createRewardsList(data.award_list)
        self.harm_btn:setVisible(true)
    end
end

--==============================--
--desc:创建奖励
--time:2018-06-14 10:22:01
--@award_list:
--@return 
--==============================--
function ActiontermbeginsFightResultPanel:createRewardsList(award_list)
    if award_list == nil then return end
    local data_list = {}
    for i,v in ipairs(award_list) do
        table_insert(data_list, {v.bid, v.num})
    end

    local setting = {}
    setting.scale = 0.75
    setting.max_count = 3
    -- setting.is_center = true
    -- setting.show_effect_id = 263
    self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
end

function ActiontermbeginsFightResultPanel:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.title_container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(103), cc.p(self.title_width * 0.5, self.title_height * 0.5), cc.p(0.5, 0.5), false, PlayerAction.action_2)
            self.title_container:addChild(self.play_effect, 1)
        end
    end
end 

function ActiontermbeginsFightResultPanel:close_callback()
    self.container:stopAllActions()
    if self.partner_item then
        self.partner_item:DeleteMe()
        self.partner_item = nil
    end
    self:handleEffect(false)
    controller:openActiontermbeginsFightResultPanel(false)
end 