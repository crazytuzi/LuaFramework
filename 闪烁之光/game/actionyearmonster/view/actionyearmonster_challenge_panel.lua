-- --------------------------------------------------------------------
-- 这里填写简要说明(必填)
-- @author: lwc(必填, 创建模块的人员)
-- @editor: lwc(必填, 后续维护以及修改的人员)
-- @description:
--      年兽挑战界面
-- <br/>2020年1月7日
ActionyearmonsterChallengePanel = ActionyearmonsterChallengePanel or BaseClass(BaseView)

local controller = ActionyearmonsterController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_sort = table.sort
local table_insert = table.insert

function ActionyearmonsterChallengePanel:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("actionyearmonster", "actionyearmonster_ch"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/actionyearmonster","actionyearmonster_challenge_bg"), type = ResourcesType.single }
    }
    self.layout_name = "actionyearmonster/actionyearmonster_challenge_panel"

    self.skill_item_list = {}

    -- --全三排行信息
    self.rank_list = {}
end

function ActionyearmonsterChallengePanel:open_callback(  )
    self.background = self.root_wnd:getChildByName("background")
    local scale = display.getMaxScale() or 1
    self.background:setScale(scale)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 1)
    self.main_panel = self.main_container:getChildByName("main_panel")

    self.panel_bg = self.main_panel:getChildByName("panel_bg")
    local path = PathTool.getPlistImgForDownLoad("bigbg/actionyearmonster","actionyearmonster_challenge_bg")
    loadSpriteTexture(self.panel_bg, path, LOADTEXT_TYPE)

    --限时挑战
    self.title_img = self.main_panel:getChildByName("title_img")

    self.title = self.main_panel:getChildByName("win_title")
    self.title:setString(TI18N("凶狠的年兽"))
    self.title:setZOrder(2)

    self.close_btn = self.main_panel:getChildByName("close_btn")
    self.rule_btn = self.main_panel:getChildByName("rule_btn")


    --排行榜
    self.rank_container = self.main_container:getChildByName("rank_container")
    -- self.rank_info_btn = self.rank_container:getChildByName("rank_btn")

    self.rank_info_btn = createRichLabel(22, cc.c4b(0x83,0xe7,0x73,0xff), cc.p(0.5, 0.5), cc.p(104, 16))
    self.rank_info_btn:setString(string_format("<div outline=2,#220101 href=xxx>%s</div>", TI18N("查看详情")))
    self.rank_info_btn:addTouchLinkListener(function(type, value, sender, pos)
        self:onClickRankBtn()
    end, { "click", "href" })
    self.rank_container:addChild(self.rank_info_btn)

    self.rank_container:getChildByName("rank_desc_label"):setString(TI18N("伤害排行前三"))

    --策划要求暂时隐藏
    self.look_btn = self.main_container:getChildByName("look_btn")
    self.look_btn:setVisible(false)

    self.challenge_btn = self.main_container:getChildByName("challenge_btn")
    -- self.challenge_btn:setPositionX(375)
    self.challenge_btn:getChildByName("label"):setString(TI18N("挑 战"))

    self.skill_container = self.main_container:getChildByName("skill_container")
    self.skill_container_size = self.skill_container:getContentSize()
    self.skill_container:setScrollBarEnabled(false)

    self.item_container = self.main_container:getChildByName("item_container")
    self.item_container:setScrollBarEnabled(false)

    self.checkbox = self.main_container:getChildByName("checkbox")
    self.checkbox:getChildByName("name"):setString(TI18N("跳过战斗"))
    self.checkbox:setSelected(false)
    -- self.checkbox:setVisible(false)
    -- self.less_time = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0.5, 0.5), cc.p(132, 224),nil,nil,720)
    -- self.main_container:addChild(self.less_time)

    local buy_panel = self.main_container:getChildByName("buy_panel")
    buy_panel:getChildByName("key"):setString(TI18N("挑战次数:"))
    self.buy_count = buy_panel:getChildByName("label")
    self.buy_btn = buy_panel:getChildByName("add_btn")

    self.reward_title = self.main_container:getChildByName("reward_title")
    self.reward_title:setString(TI18N("挑战奖励"))
    self.time_key = self.main_container:getChildByName("time_key")
    self.time_key:setString(TI18N("限时:"))
    self.time_val = self.main_container:getChildByName("time_val")
    self.time_val:setString("")
    self.buy_tips = self.main_container:getChildByName("lese_count")
    self.buy_tips:setString("")
end

function ActionyearmonsterChallengePanel:register_event(  )
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn), false, 2)
    registerButtonEventListener(self.close_btn, handler(self, self.onClickCloseBtn), true, 2)
   
    registerButtonEventListener(self.look_btn, handler(self, self.onClickLookBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.rule_btn, handler(self, self.onClickRuleBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    registerButtonEventListener(self.challenge_btn, handler(self, self.onClickChallengeBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    --排行榜
    -- registerButtonEventListener(self.rank_info_btn, handler(self, self.onClickRankBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.buy_btn, handler(self, self.onClickBuyCountBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)

    --跳过战斗
    self.checkbox:addEventListener(function ( sender,event_type )
        playButtonSound2()
        if  not self.scdata then return end
        local is_select = self.checkbox:isSelected()
    end)

    self:addGlobalEvent(ActionyearmonsterEvent.Year_Rank_Info_Event, function(data)
        if not data then return end
        self:updateRankInfo(data)
    end)
    --购买次数
    self:addGlobalEvent(ActionyearmonsterEvent.Year_Buy_count_Event, function(data)
        if not data then return end
        if not self.scdata then return end

        self.scdata.combat_time = self.scdata.combat_time + 1
        self.scdata.buy_time = self.scdata.buy_time - 1
        if self.scdata.buy_time < 0 then
            self.scdata.buy_time = 0
        end
        self:updateBuyCount()
        if self.is_send_matching then
            --打开布阵界面
            self.is_send_matching = false
            self:onClickChallengeBtn(true)
        end
    end)

end

-- 关闭
function ActionyearmonsterChallengePanel:onClickCloseBtn(  )
    controller:openActionyearmonsterChallengePanel(false)
end
-- 打开规则说明
function ActionyearmonsterChallengePanel:onClickRuleBtn(  param, sender, event_type )
     local rule_cfg = Config.HolidayNianData.data_const["holiday_nian_fight_desc"]
    if rule_cfg then
        TipsManager:getInstance():showCommonTips(rule_cfg.desc, sender:getTouchBeganPosition())
    end
end

-- 查看
function ActionyearmonsterChallengePanel:onClickLookBtn(  )
    -- MainuiController:getInstance():openCommonExplainView(true, Config.GuildSecretAreaData.data_explain)
end

-- 打开排行榜
function ActionyearmonsterChallengePanel:onClickRankBtn(  )
    if not self.boss_config then return end
    if not self.scdata then return end
    local setting = {}
    setting.rank_type = RankConstant.RankType.year_monster
    setting.title_name = TI18N("排行榜")
    setting.background_path = PathTool.getPlistImgForDownLoad("planes/map_bg","map_bg_100001",true)
    if self.scdata.type == ActionyearmonsterConstants.Evt_Type.YearMonster then
        --显示年兽
        setting.type = 1   
        setting.only_show_rank = true
    else
        --金年兽
        setting.type = 2   
    end
    
    -- setting.show_tips = TI18N("奖励将在活动结束后通过邮件发放")
    RankController:getInstance():openSingleRankMainWindow(true, setting)
end

-- 购买次数
--@is_matching 是否是购买次数后进入布阵界面
function ActionyearmonsterChallengePanel:onClickBuyCountBtn(is_matching)
    if not self.scdata  then return end

    if self.scdata.buy_time <= 0 then
        if is_matching then
            message(TI18N("已达到本次讨伐挑战次数上限"))
        else
            message(TI18N("购买次数已达上限"))
        end
        return
    end

    local config = nil
    local monster_type = 0
    if self.scdata.type == ActionyearmonsterConstants.Evt_Type.YearMonster then
        --限时年兽
        config = Config.HolidayNianData.data_const.holiday_nian_timer_monster_buy_price
        monster_type = 1
    else
        --金年兽
        config = Config.HolidayNianData.data_const.holiday_nian_gold_monster_buy_price
        monster_type = 2
    end

    if config and next(config.val) then
        local item_id =  config.val[1][1]
        local count =  config.val[1][2]
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str = nil
        if is_matching then
            str = string_format(TI18N("挑战次数不足, 是否花费 <img src='%s' scale=0.3 /> %s购买一次挑战次数？"), iconsrc, count)
        else
            str = string_format(TI18N("是否花费 <img src='%s' scale=0.3 /> %s购买一次挑战次数？"), iconsrc, count)
        end

        local call_back = function()
            if self.scdata.bid ~= 0 then
                self.is_send_matching = is_matching
                controller:sender28212(monster_type)
            end
        end
        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    end
end

-- is_buy_back是否购买次数返回的
function ActionyearmonsterChallengePanel:onClickChallengeBtn(is_buy_back)
    if not self.scdata then return end

    --次数拦截
    if self.scdata.combat_time <= 0 then
        self:onClickBuyCountBtn(true)
        return 
    end
    local is_select = self.checkbox:isSelected()
    if  is_select then 
        local ext_list = {}
        table_insert(ext_list, {type = ActionyearmonsterConstants.Proto_28203._4, val1 = 1, val2 = 1})
        controller:sender28203( self.scdata.index, 1, ext_list )
    else
        --打开布阵界面
        local setting = {}
        setting.grid_index  = self.scdata.index
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.YearMonster, setting)
    end
end

--年兽spine
function ActionyearmonsterChallengePanel:showEffect(bool, effect_name, action)
    if bool == true then
        local action = action or PlayerAction.stand
        local effect_name = effect_name or "E28002"
        if self.play_effect == nil then
            self.play_effect = createEffectSpine(effect_name, cc.p(400,543), cc.p(0.5, 0.5), true, action)
            self.main_panel:addChild(self.play_effect, 1)
        end    
    else
        if self.play_effect then 
            self.play_effect:setVisible(false)
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    end
end


function ActionyearmonsterChallengePanel:openRootWnd(setting)
    local setting = setting or {}
    --28215协议结构
    local data = setting.data
    if not data then return end
    self:setScData(data)


end
function ActionyearmonsterChallengePanel:updateData(data)
    self.scdata = data
    self:updateBuyCount()
     if self.scdata.type == ActionyearmonsterConstants.Evt_Type.YearMonster then
        --限时年兽
        controller:sender28213(1, 0)
    else
        --金年兽
        controller:sender28213(2, 0)

    end
end

function ActionyearmonsterChallengePanel:setScData(scdata)
    self.scdata = scdata

    local evt_id = nil
    if self.scdata.type == ActionyearmonsterConstants.Evt_Type.YearMonster then
        --限时年兽
        evt_id= ActionyearmonsterConstants.evt_limit_monster_hit
        controller:sender28213(1, 0)
        self:showEffect(true, "E28002")
    else
        --金年兽
        evt_id = ActionyearmonsterConstants.evt_gold_monster_hit
        controller:sender28213(2, 0)
        self:showEffect(true, "E28003")
        if self.title_img then
            loadSpriteTexture(self.title_img, PathTool.getResFrame("actionyearmonster_ch", "txt_cn_actionyearmonster_ch_7"), LOADTEXT_TYPE_PLIST) 
        end
    end

    self.boss_config = Config.HolidayNianData.data_evt_info[evt_id]
    if not self.boss_config then return end

    self:updateBossInfoByBossID()
    self:updateBuyCount()
end

--@count 剩余挑战次数
function ActionyearmonsterChallengePanel:updateBuyCount()
    if not self.scdata then return end
    if not self.buy_count then return end
    local count = self.scdata.combat_time or 1
    local config = nil
      if self.scdata.type == ActionyearmonsterConstants.Evt_Type.YearMonster then
        --限时年兽
        config = Config.HolidayNianData.data_const.holiday_nian_timer_monster_free_time
    else
        --金年兽
        config = Config.HolidayNianData.data_const.holiday_nian_gold_monster_free_time
    end

    if config then
        local str = string_format("%s/%s",count, config.val)
        self.buy_count:setString(str)
    end

    local last_buy_time = self.scdata.buy_time or 0
    local str = string.format("%s%s",TI18N("剩余购买次数:"), last_buy_time)
    self.buy_tips:setString(str)
end


function ActionyearmonsterChallengePanel:updateBossInfoByBossID()
    if not self.scdata then return end

    self:updateSkillInfo()
    --奖励
    local data_list = self.boss_config.reward or {}
    local setting = {}
    setting.scale = 0.9
    setting.max_count = 4
    setting.is_center = true
    -- setting.show_effect_id = 263
    self.item_list = commonShowSingleRowItemList(self.item_container, self.item_list, data_list, setting)

    --boss名字
    self.title:setString(self.boss_config.name)

    local time = self.scdata.last_time or 0
    commonCountDownTime(self.time_val, time, {callback = function(time) self:setTimeFormatString(time) end})
end

function ActionyearmonsterChallengePanel:setTimeFormatString(time)
    if time > 0 then
        self.time_val:setString(TimeTool.GetTimeFormatDayIIIIII(time))
    else
        self.time_val:setString("00:00")
    end
end



--刷新技能
function ActionyearmonsterChallengePanel:updateSkillInfo()
    if not self.boss_config then return end
    local skill_list = self.boss_config.boss_skill_id or {}
    -- skill_list = {203102,203102,203102,203102}
    --技能item的宽度
    self.skill_width = 100
    local item_width = self.skill_width + 10
    local total_width = item_width * #skill_list
    local max_width = math.max(self.skill_container_size.width, total_width)
    self.skill_container:setInnerContainerSize(cc.size(max_width, self.skill_container_size.height))

    for i,v in ipairs(self.skill_item_list) do
        v:setVisible(false)
    end
    
    local x = 0
    if total_width > self.skill_container_size.width then
        --技能的总宽度大于 显示的宽度 就从左往右显示
        x = 0
    else
        --否则从中从中间显示
        x = (self.skill_container_size.width - total_width) * 0.5
    end

    for i,skill_id in ipairs(skill_list) do
        local config = Config.SkillData.data_get_skill(skill_id)
        if config then
            --是否锁住
            if self.skill_item_list[i] == nil then
                self.skill_item_list[i] = {}
                self.skill_item_list[i] = SkillItem.new(true,true,true,0.8, true)
                self.skill_container:addChild(self.skill_item_list[i])
            end
            self.skill_item_list[i]:setData(config)
            self.skill_item_list[i]:setVisible(true)
            self.skill_item_list[i]:setPosition( x + item_width * (i - 1) + item_width * 0.5, self.skill_width/2 - 2)
        else 
            print(string_format("技能表id: %s 没发现", tostring(skill_id)))
        end
    end
end

function ActionyearmonsterChallengePanel:updateRankInfo(data)
    if not self.boss_config then return end
    if not data then return end

    table_sort(data.dps_list, SortTools.KeyLowerSorter("rank"))
    local rank_list = {}
    for i=1,3 do
        local dps_data = data.dps_list[i]
        if dps_data then
            table_insert(rank_list, {name = dps_data.name, all_dps = dps_data.dps})
        else
            table_insert(rank_list, {name = TI18N("虚位以待")})
        end
    end

    if rank_list and next(rank_list or {}) ~= nil then
        for i, v in ipairs(rank_list) do
            local item = self.rank_list[i]
            if not item then
                item = self:createSingleRankItem(i,v)
                self.rank_container:addChild(item)
                self.rank_list[i] = item
            end
            
            if item then
                item:setPosition(0,238 - (i-1) * item:getContentSize().height)
                item.label:setString(v.name)
                if v.all_dps then
                    item.value:setString("["..MoneyTool.GetMoneyString(v.all_dps, false)..TI18N("伤害").."]")
                    item.label:setPositionY(40)
                else
                    item.value:setString("")
                    item.label:setPositionY(24)
                end
            end
        end
    end
end

--排行榜单项
function ActionyearmonsterChallengePanel:createSingleRankItem(i,data)
    local size = cc.size(208, 63)
    local container = ccui.Layout:create()
    container:setAnchorPoint(cc.p(0,1))
    container:setContentSize(size)
    local sp = createSprite(PathTool.getResFrame("common","common_300"..i), 10,size.height * 0.5,container)
    sp:setAnchorPoint(cc.p(0,0.5))
    sp:setScale(0.6)
    container.sp = sp
    local label = createLabel(22, cc.c4b(0xec,0xdd,0xcc,0xff), cc.c4b(0x22,0x01,0x01,0xff), 67, 40, "", container, 2, cc.p(0,0.5))
    local value = createLabel(18, cc.c4b(0xc8,0xad,0x83,0xff), cc.c4b(0x22,0x01,0x01,0xff), 67, 16, "", container, 2, cc.p(0,0.5))
    
    container.label = label
    container.value = value
    return  container
end

function ActionyearmonsterChallengePanel:close_callback(  )
    
    -- if self.role_vo ~= nil then
    --     if self.role_assets_event ~= nil then
    --         self.role_vo:UnBind(self.role_assets_event)
    --         self.role_assets_event = nil
    --     end
    -- end

    self:showEffect(false)

    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_container)
    -- model:clearBossRankInfo()
    controller:openActionyearmonsterChallengePanel(false)
end
