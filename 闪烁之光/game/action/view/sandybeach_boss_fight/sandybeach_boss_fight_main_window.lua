-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @description:
--      沙滩争夺战主界面 后端锋林 需求 罗登耀
-- <br/> 2019年4月25日
--
-- --------------------------------------------------------------------
SandybeachBossFightMainWindow = SandybeachBossFightMainWindow or BaseClass(BaseView)

local controller = ActionController:getInstance()
local table_sort = table.sort
local string_format = string.format
local table_insert = table.insert
local step_count = 7 --站台数量
local step_pos = {{266,-235},{266,57},{145,153},{311,274},{257,394},{351,447},{330,518},{369,548}}
local step_scale = {1,1.05,1.0, 0.59,0.42,0.30,0.22,0.12}
local step_opacity = {}
function SandybeachBossFightMainWindow:__init()
    self.win_type = WinType.Full
    self.layout_name = "acitonsandybeachbossfight/sandybeach_boss_fight_main_window"

    self.res_list = { 
        {path = PathTool.getPlistImgForDownLoad("actionsandybeachbossfight", "sandybeach_boss_fight"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg/sandybeachbossfight", "sandybeach_1"), type = ResourcesType.single}
    }

    --奖励配置
    self.reward_conifg_list = Config.HolidayBossData.data_reward_info
    if self.reward_conifg_list then
        table_sort(self.reward_conifg_list, function(a,b) return a.id < b.id end)
    end
    --获取购买最大次数
    local buy_data = Config.HolidayBossData.data_buy_info
    self.buy_max_count = 1
    for i,v in pairs(buy_data) do
        if v.max >= self.buy_max_count then
            self.buy_max_count = v.max
        end
    end
    --排名配置
    self.rank_config_list = Config.HolidayBossData.data_rank_info
    if self.rank_config_list then
        table_sort(self.rank_config_list, function(a,b) return a.min < b.min end)
    end

    self.cur_master_id = nil
    self.first_init = nil
    self.cur_step_count = 0
    --写死id
    self.show_item_id = 80228
end

function SandybeachBossFightMainWindow:open_callback()
    self.bg_image = self.root_wnd:getChildByName("bg_image")
    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container)
    self.main_panel_size = self.main_container:getContentSize()
    self.top_panel = self.main_container:getChildByName("top_panel")
    self.top_panel:getChildByName("title_name"):setString(TI18N("星空试炼"))
    --问号
    self.look_btn = self.top_panel:getChildByName("look_btn")

    --左边
    self.item_icon = self.top_panel:getChildByName("item_icon")
    local item_config = Config.ItemData.data_get_data(self.show_item_id) 
    if item_config and self.item_icon then
        loadSpriteTexture(self.item_icon, PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
    end
    self.top_panel:getChildByName("summer_score_key"):setString(TI18N("试炼彩星"))
    --夏日积分
    self.summer_score_value = self.top_panel:getChildByName("summer_score_value")
    self.summer_score_value:setString("")
    --右边
    self.top_panel:getChildByName("next_text"):setString(TI18N("下一阶段"))
    self.item_node = self.top_panel:getChildByName("item_node")
    self.score_item = BackPackItem.new(false, true, false, 0.7, false, true)
    self.score_item:addBtnCallBack(function() self:onClickScoreItemBtn() end)
    self.item_node:addChild(self.score_item)

    self.progress = self.top_panel:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setCascadeOpacityEnabled(true)
    self.progress:setPercent(0)
    self.cur_score = self.top_panel:getChildByName("cur_score")
    self.cur_score:setString("")
    --中间
    self.progress_container = self.main_container:getChildByName("progress_container")
    self.progress_container:setLocalZOrder(40)
    self.boss_hp_progress = self.progress_container:getChildByName("progress")
    self.boss_hp_progress:setScale9Enabled(true)
    self.boss_hp_progress:setPercent(0)
    self.boss_hp_value = self.progress_container:getChildByName("hp_value")
    self.boss_hp_value:setString("")
    self.boss_name = self.progress_container:getChildByName("boss_name")
    self.boss_name:setString("")
    self.head_icon = PlayerHead.new(PlayerHead.type.circle)
    local headSize = self.head_icon:getContentSize()
    self.head_icon:setTouchEnabled(false)
    self.head_icon:setScale(0.55)
    self.head_icon:closeLev()
    self.head_icon:setAnchorPoint(cc.p(0.5,0.5))
    self.head_icon:setPosition(-20,25)
    self.progress_container:addChild(self.head_icon)

    --底部
    self.bottom_panel = self.main_container:getChildByName("bottom_panel")
    self.button_bg = self.bottom_panel:getChildByName("button_bg")
    self.bottom_panel:getChildByName("cur_rank_key"):setString(TI18N("当前排名:"))
    self.cur_rank_value = self.bottom_panel:getChildByName("cur_rank_value")
    self.cur_rank_value:setString("")
    self.bottom_panel:getChildByName("cur_rank_tips"):setString(TI18N("当前排名奖励"))
    --第几关
    self.dungeons_lable = self.bottom_panel:getChildByName("dungeons_lable")
    self.dungeons_lable:setString("")
    self.bottom_panel:getChildByName("boss_level_key"):setString(TI18N("怪物等级:"))
    self.boss_level_value = self.bottom_panel:getChildByName("boss_level_value")
    self.boss_level_value:setString("")
    self.bottom_panel:getChildByName("dungeons_key_0"):setString(TI18N("奖励积分:"))
    --关卡效果
    self.dungeons_key = self.bottom_panel:getChildByName("dungeons_key")
    self.dungeons_key:setString(TI18N("关卡效果:"))
    local x , y = self.dungeons_key:getPosition()
    self.dungeons_effect_label = {}
    self.dungeons_effect_label[1] = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(x, y - 38),nil,nil,720)
    self.dungeons_effect_label[2] = createRichLabel(22, cc.c4b(0x64,0x32,0x23,0xff), cc.p(0, 0.5), cc.p(x, y - 76),nil,nil,720)
    self.bottom_panel:addChild(self.dungeons_effect_label[1])
    self.bottom_panel:addChild(self.dungeons_effect_label[2])

    self.item_node_1 = self.bottom_panel:getChildByName("item_node_1")
    self.item_node_2 = self.bottom_panel:getChildByName("item_node_2")
    self.show_item_1 = BackPackItem.new(false, false, false, 0.7, false, false)
    self.item_node_1:addChild(self.show_item_1)
    self.show_item_1:setBaseData(self.show_item_id, 1)
    self.show_item_1:setGoodsName(TI18N("通关积分"), nil, 28)
    self.show_item_2 = BackPackItem.new(false, false, false, 0.7, false, false)
    self.item_node_2:addChild(self.show_item_2)
    self.show_item_2:setBaseData(self.show_item_id, 1)
    self.show_item_2:setGoodsName(TI18N("伤害积分"), nil, 28)

    self.item_scrollview = self.bottom_panel:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)

    self.match_btn = self.bottom_panel:getChildByName("match_btn")
    self.match_btn:getChildByName("label"):setString(TI18N("挑战"))
    self.close_btn = self.bottom_panel:getChildByName("close_btn")
    self.rank_btn = self.bottom_panel:getChildByName("rank_btn")
    self.rank_btn:getChildByName("label"):setString(TI18N("排行榜"))

    local buy_panel = self.bottom_panel:getChildByName("buy_panel")
    buy_panel:getChildByName("key"):setString(TI18N("挑战次数:"))
    self.buy_count = buy_panel:getChildByName("label")
    self.buy_count:setString("")
    self.buy_btn = buy_panel:getChildByName("add_btn")

    self.bottom_panel:getChildByName("Text_1"):setString(TI18N("剩余今日可购买次数："))
    self.today_count = self.bottom_panel:getChildByName("today_count")
    self.today_count:setString("")

    self.action_panel = self.main_container:getChildByName("action_panel")
    self.boss_spine_node = cc.Node:create()
    self.action_panel:addChild(self.boss_spine_node, 20)
    self:loadBackground()
    self:loadRoleLevelStep()

    --设置适配
    self:adaptationScreen()
end
--加载底图
function SandybeachBossFightMainWindow:loadBackground()
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/sandybeachbossfight", "sandybeach_1")
    if self.bg_image then
        loadSpriteTexture(self.bg_image, bg_res, LOADTEXT_TYPE)
        self.bg_image:setScale(display.getMaxScale())
        local bottom_y = display.getBottom(self.main_container)
        self.bg_image:setPositionY(bottom_y)
    end

    local bg_res1 = PathTool.getPlistImgForDownLoad("bigbg/sandybeachbossfight", "sandybeach_2")
    if not self.load_button_bg then
        self.load_button_bg = loadSpriteTextureFromCDN(self.button_bg, bg_res1, ResourcesType.single, self.load_button_bg)
    end
end

--设置适配屏幕
function SandybeachBossFightMainWindow:adaptationScreen()
    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.main_container)
    local bottom_y = display.getBottom(self.main_container)

    local tab_y = self.top_panel:getPositionY()
    self.top_panel:setPositionY(top_y - (self.main_panel_size.height - tab_y))

     local bottom_panel_y = self.bottom_panel:getPositionY()
    self.bottom_panel:setPositionY(bottom_y + bottom_panel_y)
end
--人物站台动画
function SandybeachBossFightMainWindow:loadRoleLevelStep()
    self.sprite_action = {}

    doStopAllActions(self.action_panel)
    for i=1, step_count do
        delayRun(self.action_panel, i*5/60, function()
            local step_res = PathTool.getPlistImgForDownLoad("bigbg/sandybeachbossfight", "sandybeach_3")
            self.sprite_action[i] = createSprite(step_res,step_pos[i+1][1], step_pos[i+1][2],self.action_panel,cc.p(0.5,0.5),LOADTEXT_TYPE,10-i)
            self.sprite_action[i]:setScale(step_scale[i+1])
            if i == step_count-1 then
                self.sprite_action[i]:setOpacity(180)
            elseif i == step_count then
                self.sprite_action[i]:setOpacity(0)
            end
        end)
    end
end

function SandybeachBossFightMainWindow:register_event()
    registerButtonEventListener(self.close_btn, handler(self, self.onClickBtnClose) ,true, 1)
    --排行榜 
    registerButtonEventListener(self.rank_btn, handler(self, self.onClickRankBtn), true, 1)
    registerButtonEventListener(self.buy_btn, handler(self, self.onClickBuyCountBtn), true, 1)
    registerButtonEventListener(self.match_btn, handler(self, self.onClickMatchBtn), true, 1)
    
    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config = Config.HolidayBossData.data_const.game_rule1
        if config then
            TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
        end
    end ,true, 1)

    --主信息
    self:addGlobalEvent(ActionEvent.Aandybeach_Boss_Fight_Main_Event, function(data)
        if not data then return end
        self:setData(data)
    end)
    --购买次数返回
    self:addGlobalEvent(ActionEvent.Aandybeach_Boss_Fight_Buy_Count_Event, function(data)
        if not data then return end
        if not self.data then return end
        self.data.count = data.count
        self.data.buy_count = data.buy_count
        self:updateBuyCount()
    end)

    --购买次数返回
    self:addGlobalEvent(ActionEvent.Aandybeach_Boss_Fight_Reward_Event, function(data)
        if not data then return end
        if not self.data then return end
        self.data.award_info = data.award_info
        self:updateRewardUI()
    end)

    --站台滑动
    self:addGlobalEvent(ActionEvent.Aandybeach_Boss_Fight_Result_Close,function()
        if self.IsStepSlide then
            self:onPassLevelAction()
        end
    end)

end
function SandybeachBossFightMainWindow:onClickBtnClose()
    controller:openSandybeachBossFightMainWindow(false)
end

function SandybeachBossFightMainWindow:onClickRankBtn()
    local setting = {}
    setting.rank_type = RankConstant.RankType.sandybeach_boss_fight
    setting.title_name = TI18N("排行榜")
    setting.background_path = PathTool.getPlistImgForDownLoad("bigbg/sandybeachbossfight", "sandybeach_1")
    setting.show_tips = TI18N("奖励将在活动结束后通过邮件发放")
    RankController:getInstance():openSingleRankMainWindow(true, setting)
end
--购买次数
function SandybeachBossFightMainWindow:onClickBuyCountBtn( )
    if not self.data then return end
    local count = self.data.count or 0
    local max_count = 10
    local config_fight_max_count = Config.HolidayBossData.data_const.fight_max_count
    if config_fight_max_count then
        max_count = config_fight_max_count.val
    end
    if count >= max_count then
        message(TI18N("挑战次数已达上限"))
        return
    end

    local config_list = Config.HolidayBossData.data_buy_info
    if not config_list then return end
    local list = {}
    for i,v in pairs(config_list) do
        table_insert(list, v)
    end
    table_sort(list, function(a, b) return a.min < b.min end)
    if #list == 0 then return end
    local max_config = list[#list]
    if self.data.buy_count >= list[#list].max then
        message(TI18N("购买次数已达上限"))
        return
    end
    local buy_config
    for i,v in ipairs(list) do
        if self.data.buy_count >= v.min and self.data.buy_count <= v.max then
            buy_config = v
        end
    end
    if buy_config and next(buy_config.expend) ~= nil then
        local item_id =  buy_config.expend[1][1] 
        local count =  buy_config.expend[1][2] 
        local iconsrc = PathTool.getItemRes(Config.ItemData.data_get_data(item_id).icon)
        local str = string_format(TI18N("是否花费<img src='%s' scale=0.3 />%s购买一次挑战次数？"), iconsrc, count)
        local call_back = function()
            controller:sender25402()
        end
        CommonAlert.show(str, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
    end
end
--站台移动
function SandybeachBossFightMainWindow:moveTo(count,node, pos, scale)
    if node then
        local move = cc.MoveTo:create(1,pos)
        if count == 1 then
            scale = 0.2
        end
        local scaleto = cc.ScaleTo:create(1, scale)
        if count == (step_count-1) then
            local spawn = cc.Spawn:create(move, scaleto,cc.CallFunc:create(function()
                node:setOpacity(255)
            end))
            node:runAction(spawn)
        else
            local spawn = cc.Spawn:create(move, scaleto)
            node:runAction(spawn)
        end
    end
end
--怪物变化的时候出现的动作
function SandybeachBossFightMainWindow:onPassLevelAction()
    if self.station_node  then
        doStopAllActions(self.station_node)
    end
    self:resetStepPos()

    self.station_node = cc.Node:create()
    self:addChild(self.station_node)

    self.IsStepSlide = nil
    local moveStep = {}
    local m_flag = {}
    for i=1, step_count-1 do
        local function test()
            if not m_flag[i] then
                m_flag[i] = true
                self:moveTo(i,self.sprite_action[i],cc.p(step_pos[i][1],step_pos[i][2]),step_scale[i])
            end
        end
        moveStep[i] = cc.CallFunc:create(test)
    end

    --最后一个
    local station_fadein = cc.CallFunc:create(function()
        if self.sprite_action[step_count] then
            self.sprite_action[step_count]:setPosition(cc.p(step_pos[step_count+1][1],step_pos[step_count+1][2]))
            self.sprite_action[step_count]:setScale(0)
            local fadein = cc.FadeIn:create(1)
            local scaleto = cc.ScaleTo:create(1, step_scale[step_count])
            local move = cc.MoveTo:create(1,cc.p(step_pos[step_count][1],step_pos[step_count][2]))
            local spawn = cc.Spawn:create(fadein,scaleto,move)
            local seq = cc.Sequence:create(cc.CallFunc:create(function()
                self.sprite_action[step_count]:setOpacity(180)
            end),spawn)
            self.sprite_action[step_count]:runAction(seq)
        end
    end)

    --背景
    local bg_action = cc.CallFunc:create(function()
        local diff_pos = 10
        if math.abs(self.bg_image:getPositionY() - diff_pos) >= (self.bg_image:getContentSize().height - 1280) then
            diff_pos = 0
        end
        local move = cc.MoveTo:create(1, cc.p(self.bg_image:getPositionX(), self.bg_image:getPositionY() - diff_pos))
        local easeSineInOut = cc.EaseSineInOut:create(move)
        if self.bg_image then
            self.bg_image:runAction(easeSineInOut)
        end
    end)

    local spine_action = cc.CallFunc:create(function()
        if self.spine then
            local fadein = cc.FadeIn:create(1)
            self.spine:runAction(fadein)
        end
    end)
    local spine_bg_action = cc.CallFunc:create(function()
        if self.load_rolespine_bg then
            local fadein = cc.FadeIn:create(1)
            self.load_rolespine_bg:runAction(fadein)
        end
    end)
    local role_spawn = cc.Spawn:create(spine_action,spine_bg_action)

    self.station_node:runAction(cc.Sequence:create(
        cc.Spawn:create(bg_action,moveStep[1],moveStep[2],moveStep[3],moveStep[4],moveStep[5],moveStep[6],station_fadein),
        cc.DelayTime:create(1.5),role_spawn))
end
--重置站台的位置
function SandybeachBossFightMainWindow:resetStepPos()
    for i=1,step_count-1 do
        if self.sprite_action[i] then
            self.sprite_action[i]:setPosition(step_pos[i+1][1],step_pos[i+1][2])
            self.sprite_action[i]:setScale(step_scale[i+1])
        end
    end
    self.cur_step_count = self.cur_step_count + 1
    local pos = cc.p(step_pos[step_count-2][1],step_pos[step_count-2][2])
    if self.cur_step_count == 2 then
        self.cur_step_count = 0
        pos = cc.p(step_pos[step_count-1][1],step_pos[step_count-1][2])
    end
    if self.sprite_action[step_count] then
        self.sprite_action[step_count]:setPosition(pos)
        self.sprite_action[step_count]:setOpacity(0)
    end
end
--设置按钮状态
function SandybeachBossFightMainWindow:setShowBossData()
    if not self.select_boss_index then return end

    if self.config_id_list[self.select_boss_index] then
        local boss_config
        if self.dic_boss_config[self.config_id_list[self.select_boss_index].order_id] == nil then
            boss_config = Config.HolidayBossData.data_boss_info(self.config_id_list[self.select_boss_index].order_id)
        else
            boss_config = self.dic_boss_config[self.config_id_list[self.select_boss_index].order_id]
        end
        self:updateBossInfo(boss_config)
    end
end

--点击积分道具
function SandybeachBossFightMainWindow:onClickScoreItemBtn()
    if not self.data then return end
    local config, is_all = self:getCurrentRewardConfig()
    if config then
        local score = self.data.score or 0
        if not is_all and score >= config.num then
            --领取奖励
            controller:sender25403()
        else
            --打开界面
            local setting = {}
            setting.title_name = TI18N("奖励详情")
            setting.tips = TI18N("达到指定积分,可领取对应奖励")
            setting.cur_txt = string_format(TI18N("当前夏日积分:%s"), score)
            setting.cur_score = score
            setting.score_data_list = {}
            for i,v in ipairs(self.reward_conifg_list) do
                local data = {}
                data.score = v.num
                data.reward = v.items[1]
                table_insert(setting.score_data_list, data)
            end
            controller:openActionCommonRewardPanel(true, setting)
        end
    end
end

-- 挑战
function SandybeachBossFightMainWindow:onClickMatchBtn()
    if not self.select_boss_index then return end
    if not self.config_id_list then return end
    local cur_order_id = self.config_id_list[self.select_boss_index].order_id
    if cur_order_id > self.data.order then
        message(TI18N("请先通关前置关卡"))
    elseif cur_order_id < self.data.order then
        message(TI18N("该关卡已经通关"))
    else
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.Sandybeach_boss)
    end
end

function SandybeachBossFightMainWindow:openRootWnd()
    controller:sender25401()
end

function SandybeachBossFightMainWindow:setData(data)
    self.data = data or {}
    local boss_config = Config.HolidayBossData.data_boss_info(data.order)
    if not boss_config then return end
    self.dic_boss_config = {}
    self.dic_boss_config[boss_config.order_id] = boss_config
    self.config_id_list = Config.HolidayBossData.data_boss_group[boss_config.group_id]
    if self.config_id_list == nil then return end
    table_sort(self.config_id_list, function(a,b) return a.order_id < b.order_id end)
    for i,v in pairs(self.config_id_list) do
        if boss_config.order_id == v.order_id then
            self.select_boss_index = i
        end
    end

    --top部分
    self.summer_score_value:setString(self.data.score)
    --右边奖励ui
    self:updateRewardUI()

    --中间
    self:setShowBossData()
    --底部
    --当前排名
    self:updateRankUI()
    --更新购买次数
    self:updateBuyCount()
end
--更新右边奖励
function SandybeachBossFightMainWindow:updateRewardUI()
    local config, is_all = self:getCurrentRewardConfig()
    if config then
        local reward = config.items
        if reward and next(reward) ~= nil then
            --道具
            self.score_item:setBaseData(reward[1][1],reward[1][2], true)

        end
        local score = self.data.score or 0
        if score >= config.num then
            if is_all then
                self.score_item:setReceivedIcon(true)
                self.score_item:showItemEffect(false)
            else
                self.score_item:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
            end
            score = config.num
        else
            self.score_item:showItemEffect(false)
        end
        self.progress:setPercent(score * 100/config.num)
        self.cur_score:setString(string_format("%s/%s", score, config.num))
    end
end
--获取当前奖励配置
function SandybeachBossFightMainWindow:getCurrentRewardConfig()
    if not self.data then return end
    if not self.reward_conifg_list then return end
    local config
    local is_all = false
    if #self.data.award_info == 0 then
        config = self.reward_conifg_list[1]
    else
        local dic_id = {}
        for i,v in ipairs(self.data.award_info) do
            dic_id[v.award_id] = true
        end
        for i,v in ipairs(self.reward_conifg_list) do
            if not dic_id[v.id] then
                config = v
                break
            end
        end
        if config == nil then
            config = self.reward_conifg_list[#self.reward_conifg_list]
            is_all = true 
        end
    end

    return config, is_all
end

--更新排名信息
function SandybeachBossFightMainWindow:updateRankUI()
    if not self.data then return end
    if not self.rank_config_list then return end
    local rank = self.data.rank or 0
    local config 
    if rank == 0 then
        self.cur_rank_value:setString(TI18N("未上榜"))
        config = self.rank_config_list[#self.rank_config_list]
    else
        self.cur_rank_value:setString(self.data.rank)
        for i,v in ipairs(self.rank_config_list) do
            if rank >= v.min and rank <= v.max then
                config = v
            end
        end
    end
    if config == nil then
        config = self.rank_config_list[#self.rank_config_list]
    end
    if config then
        local data_list = config.items
        local setting = {}
        setting.scale = 0.6
        setting.max_count = 3
        self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
    end
end
--更新boss信息
function SandybeachBossFightMainWindow:updateBossInfo(boss_config)
    if not boss_config then return end

    local per = 0
    local hp_per = 0
    if boss_config.order_id > self.data.order then
        per = 100
        hp_per = 100
    elseif boss_config.order_id < self.data.order then
        per = 0
        hp_per = 0
    else
        per = math.floor(self.data.hp_per/1000)
        hp_per = self.data.hp_per/1000
    end

    self.boss_hp_value:setString(string_format("%s%%", per))
    self.boss_hp_progress:setPercent(hp_per)
    self.boss_name:setString(boss_config.name)
    --头像
    if self.record_head_id == nil or self.record_head_id ~= boss_config.head_id then
        self.record_head_id = boss_config.head_id
        self.head_icon:setHeadRes(boss_config.head_id)
    end

    self:updateSpine(boss_config.unit_id)

    --第几关
    self.dungeons_lable:setString(string_format(TI18N("第%s关"), boss_config.order_id))
    self.boss_level_value:setString(boss_config.level)

    for i=1,2 do
        if self.dungeons_effect_label[i] then
            if boss_config.add_skill_decs[i] then
                self.dungeons_effect_label[i]:setString(boss_config.add_skill_decs[i])
            else
                boss_config.add_skill_decs[i]:setString("")
            end
        end
    end
    if self.show_item_1 then
        self.show_item_1:setNum(boss_config.kill_score)
    end
    if self.show_item_2 then
        self.show_item_2:setNum(boss_config.dps_score)
    end

end
--更新模型,也是初始化模型
function SandybeachBossFightMainWindow:updateSpine(unit_id)
    if self.cur_master_id == unit_id then return end

    if not self.load_rolespine_bg then
        local res = PathTool.getPlistImgForDownLoad("bigbg/sandybeachbossfight", "sandybeach_4")
        self.load_rolespine_bg = createSprite(res,step_pos[3][1], step_pos[3][2]+61,self.boss_spine_node,cc.p(0.5,0),LOADTEXT_TYPE)
    end
    
    self.IsStepSlide = true
    self.cur_master_id = unit_id
    local fun = function()
        if not self.spine then
            self.spine = BaseRole.new(BaseRole.type.unit, unit_id, nil, {scale = 1})
            self.spine:setAnimation(0,PlayerAction.show,true)
            self.spine:setCascade(true)
            self.spine:setPosition(cc.p(step_pos[3][1],step_pos[3][2]+256))
            self.spine:setAnchorPoint(cc.p(0.5,0))
            self.spine:setScale(0.8)
            self.boss_spine_node:addChild(self.spine)
            if self.first_init then
                self.spine:setOpacity(0)
                self.load_rolespine_bg:setOpacity(0)
            else
                self.spine:setOpacity(0)
                local action = cc.FadeIn:create(0.2)
                self.spine:runAction(action)
            end
        end
    end
    if self.spine then
        doStopAllActions(self.spine)
        self.spine:removeFromParent()
        self.spine = nil
        fun()
    else
        fun()
    end
    self.first_init = true
end

--@day_combat_count 剩余挑战次数
function SandybeachBossFightMainWindow:updateBuyCount()
    if not self.data then return end
    local count = self.data.count or 0
    local max_count = 10
    local config_fight_max_count = Config.HolidayBossData.data_const.fight_max_count
    if config_fight_max_count then
        max_count = config_fight_max_count.val
    end
    local str = string_format("%s/%s",count, max_count)
    self.buy_count:setString(str)
    local buy_count = self.buy_max_count - self.data.buy_count
    if buy_count <= 0 then buy_count = 0 end
    self.today_count:setString(buy_count..TI18N("次"))
end

function SandybeachBossFightMainWindow:close_callback()
    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_scrollview)
    doStopAllActions(self.station_node)
    doStopAllActions(self.action_panel)

    if self.load_button_bg ~= nil then
        self.load_button_bg:DeleteMe()
        self.load_button_bg = nil
    end
   
    if self.head_icon ~= nil then
        self.head_icon:DeleteMe()
        self.head_icon = nil
    end

    if self.score_item ~= nil then
        self.score_item:DeleteMe()
        self.score_item = nil
    end

    if self.show_item_1 ~= nil then
        self.show_item_1:DeleteMe()
        self.show_item_1 = nil
    end
    if self.show_item_2 ~= nil then
        self.show_item_2:DeleteMe()
        self.show_item_2 = nil
    end
    if self.spine then
        self.spine:removeFromParent()
        self.spine = nil
    end
    controller:openSandybeachBossFightMainWindow(false)
end

