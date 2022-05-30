-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--       boss页签
--      开学季活动boss战 后端 锦汉 策划 建军 
-- <br/> 2019年8月22日
-- --------------------------------------------------------------------
ActiontermbeginsTabBossPanel = class("ActiontermbeginsTabBossPanel", function()
    return ccui.Widget:create()
end)

local controller = ActiontermbeginsController:getInstance()
local model = controller:getModel()
local string_format = string.format
local table_insert = table.insert
local role_vo = RoleController:getInstance():getRoleVo()

local math_floor = math.floor

function ActiontermbeginsTabBossPanel:ctor(parent)
    self.parent = parent
    self:config()
    self:layoutUI()
    self:registerEvents()
end

function ActiontermbeginsTabBossPanel:config()
    -- self.size = cc.size(680,372.97)
    -- self:setContentSize(self.size)
    --试卷id
    self.paper_item_id = 1
    local config = Config.HolidayTermBeginsData.data_const.paper_item_id
    if config then
        self.paper_item_id = config.val
    end

    --准考证id
    self.ticket_item_id = 1
    local config = Config.HolidayTermBeginsData.data_const.ticket_item_id
    if config then
        self.ticket_item_id = config.val
    end


    self.collection_quantity = 178750
    local config = Config.HolidayTermBeginsData.data_const.collection_quantity
    if config then
        self.collection_quantity = config.val
    end

    self.collection_buff = 21360
    local config = Config.HolidayTermBeginsData.data_const.collection_buff
    if config then
        self.collection_buff = config.val
    end
end

function ActiontermbeginsTabBossPanel:layoutUI()
    local csbPath = PathTool.getTargetCSB("actiontermbegins/action_term_begins_tab_boss_panel")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    --读取文件的大小
    self.size = self.root_wnd:getContentSize()
    self:setContentSize(self.size)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.main_container_size = self.main_container:getContentSize()

    self.item_lay_list = {}

    self.bottom_panel = self.main_container:getChildByName("bottom_panel")
    
    local panel_bg = self.bottom_panel:getChildByName("panel_bg")
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/termbegins", "term_begins_panel_bg", false)
    self.item_load_panel_bg = loadSpriteTextureFromCDN(panel_bg, bg_res, ResourcesType.single, self.item_load_panel_bg)

    --未开启的面板信息
    self.unopen_panel = self.bottom_panel:getChildByName("unopen_panel")
    local progress_container = self.unopen_panel:getChildByName("progress_container")
    self.progress = progress_container:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    -- local progress_container_size = progress_container:getContentSize()
    self.progress:setPercent(0)

    self.progress_time = progress_container:getChildByName("time")
    self.progress_time:setString("")

    self.unopen_panel:getChildByName("progress_key"):setString(TI18N("收集进度"))
    local str = TI18N("提交满分试卷可以增长进度,进度每增长1%为全服玩家提供5%伤害")
    local config = Config.HolidayTermBeginsData.data_const.collection_damage_tips
    if config then
        str = config.desc
    end
    self.unopen_panel:getChildByName("protress_tips"):setString(str)

    self.comfirm_btn = self.unopen_panel:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("提交试卷"))

    --开启的面板
    self.open_panel = self.bottom_panel:getChildByName("open_panel")
    self.open_panel:getChildByName("hit_reward_label"):setString(TI18N("击杀奖励"))
    self.open_panel:getChildByName("hit_reward_tips"):setString(TI18N("所有参与的玩家可获得"))
    self.rank_reward_label = self.open_panel:getChildByName("rank_reward_label")
    self.rank_reward_label:setString(TI18N("您当前排名:"))
    self.rank_reward_tips = self.open_panel:getChildByName("rank_reward_tips")
    self.rank_reward_tips:setString(TI18N("保持排名您可获得以上奖励"))

    local reward_item_node = self.open_panel:getChildByName("reward_item_node")
    self.reward_item = BackPackItem.new(false, true, false, 0.6, false, true)
    -- self.reward_item:addBtnCallBack(function() self:onClickScoreItemBtn() end)
    self.reward_item:setDefaultTip()
    reward_item_node:addChild(self.reward_item)

    self.item_scrollview = self.open_panel:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)

    self.rank_btn = self.bottom_panel:getChildByName("rank_btn")
    self.rank_btn:getChildByName("label"):setString(TI18N("伤害排行"))

    self.sweep_btn = self.open_panel:getChildByName("sweep_btn")
    self.sweep_btn_label =self.sweep_btn:getChildByName("label")
    self.sweep_btn_label:setString(TI18N("一键扫荡"))

    self.fight_btn = self.open_panel:getChildByName("fight_btn")
    self.fight_btn_label = self.fight_btn:getChildByName("label")
    self.fight_btn_label:setString(TI18N("前往挑战"))

    self.is_hit_img = self.main_container:getChildByName("is_hit_img")
    self.is_hit_img:setVisible(false)
    self.is_hit_img:setZOrder(2)
    local hit_tips = self.is_hit_img:getChildByName("hit_tips")
    hit_tips:setString(TI18N("BOSS已被击败可以继续追击"))
    self.buff_node = self.main_container:getChildByName("buff_node")

    --boss血量信息
    self.progress_container = self.main_container:getChildByName("progress_container")
    self.boss_hp_progress = self.progress_container:getChildByName("progress")
    -- self.boss_hp_progress:setScale9Enabled(true)
    self.boss_hp_progress:setPercent(0)
    self.boss_hp_value = self.progress_container:getChildByName("hp_value")
    self.boss_hp_value:setString("")
    self.boss_name = self.progress_container:getChildByName("boss_name")
    self.boss_name:setString("")

    self.reward_btn = self.bottom_panel:getChildByName("reward_btn")
    self.reward_btn:getChildByName("label"):setString(TI18N("收集奖励"))

    local buy_panel = self.bottom_panel:getChildByName("buy_panel")
    buy_panel:getChildByName("key"):setString(TI18N("当前拥有:"))
    self.icon = buy_panel:getChildByName("icon")
    self.buy_count = buy_panel:getChildByName("label")
    -- self.buy_btn = buy_panel:getChildByName("add_btn")
    self.key_tips = buy_panel:getChildByName("key_tips")
    self.key_tips:setString(TI18N("数量不足时可以使用钻石挑战"))
    self.key_tips:setVisible(false)

    self.look_btn = self.bottom_panel:getChildByName("look_btn")
    self.less_time = createRichLabel(22, cc.c4b(0x80,0xf7,0x31,0xff), cc.p(0.5, 0.5), cc.p(360, 1024),nil,nil,720)
    self.main_container:addChild(self.less_time)
end

--事件
function ActiontermbeginsTabBossPanel:registerEvents()
    registerButtonEventListener(self.comfirm_btn, function() self:onComfirmBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.rank_btn, function() self:onRankBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.sweep_btn, function() self:onSweepBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.fight_btn, function() self:onFightBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    registerButtonEventListener(self.reward_btn, function() self:onRewardBtn()  end ,true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
    -- registerButtonEventListener(self.level_up_btn, function() self:onClickLevelUpBtn()  end ,true, 2)

    registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
        local config = Config.HolidayTermBeginsData.data_const.boss_descreption
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
    end ,true, 1)

    -- registerButtonEventListener(self.look_btn, function(param,sender, event_type) 
    --     if self.parent and self.parent.is_move_effect then return end
    --     local config = Config.ResonateData.data_const.rule_tips
    --     if config then
    --         TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
    --     end
    -- end ,true, 2, nil, 0.8)

    -- for i,v in ipairs(self.item_lay_list) do
    --     registerButtonEventListener(v.btn, function() self:onClickHeroBtn(i)  end ,false, 2)
    -- end

    --打开布阵事件
    if not self.boss_form_event then 
        self.boss_form_event = GlobalEvent:getInstance():Bind(ActiontermbeginsEvent.TERM_BEGINS_BOSS_FORM_EVENT, function()
            HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.TermBeginsBoss) 
        end)
    end
    --提交试卷数量
    if not self.subit_paper_event then 
        self.subit_paper_event = GlobalEvent:getInstance():Bind(ActiontermbeginsEvent.TERM_BEGINS_SUBIT_PAPER_EVENT, function(data)
            if not data then return end
            self.scdata.paper_sum = data.paper_sum or 0
            self:updateParperInfo()
        end)
    end

    -- --物品道具增加 
    if not self.add_goods_event then
        self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then
                self:updateCostInfo()
            end
        end)
    end
    --物品道具删除 
    if not self.del_goods_event then
        self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
                self:updateCostInfo()
            end
        end)
    end

    --物品道具改变 
    if not self.modify_goods_event then
        self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
            if bag_code ~= BackPackConst.Bag_Code.EQUIPS then 
               self:updateCostInfo()
            end
        end)
    end
end

function ActiontermbeginsTabBossPanel:onComfirmBtn()
    if not self.scdata then return end
    local setting = {}
    setting.item_id = self.paper_item_id
    setting.shop_type = MallConst.MallType.TermBeginsBuy

    ActiontermbeginsController:getInstance():openActionBuyPanel(true, setting)
end
--排行榜
function ActiontermbeginsTabBossPanel:onRankBtn()
    if not self.scdata then return end
    local setting = {}
    if self.scdata.boss_flag ~= 1 then
        setting.index = 2
    end
    setting.rank_type = RankConstant.RankType.termbegins
    controller:openActiontermbeginsRankMainPanel(true, setting)
end

--扫荡
function ActiontermbeginsTabBossPanel:onSweepBtn()
    if self.is_time_out  then
        message(TI18N("活动已结束"))
        return
    end
    if not self.scdata then return end
    if self.scdata.dps > 0 then
        local count = BackpackController:getInstance():getModel():getItemNumByBid(self.ticket_item_id)
        if count <= 0 then
            local ticket_item_config = Config.ItemData.data_get_data(self.ticket_item_id)
            if not ticket_item_config then return end
            --道具不足
            local item_id = 3
            local cost = 100
            local config = Config.HolidayTermBeginsData.data_const.entrance_exam_cost
            if config and next(config.val) ~= nil then
                item_id = config.val[1] or 3
                cost = config.val[2] or 100
            end
            local item_config = Config.ItemData.data_get_data(item_id)
            local msg = string_format(TI18N("%s不足，是否花费 <img src=%s visible=true scale=0.5 />%s 购买<div fontcolor='#289b14'>1</div>张%s并扫荡？\n(扫荡根据上次的伤害量<div fontcolor=#249003>%s</div>进行结算)"), 
                ticket_item_config.name, PathTool.getItemRes(item_config.icon), cost, ticket_item_config.name, self.scdata.dps) 
            CommonAlert.show(msg, TI18N("确定"), function()
                controller:sender26712(self.scdata.boss_id)
            end, TI18N("取消"), nil, CommonAlert.type.rich)
        else
            --道具足够
            local msg = string_format(TI18N("确定按照上次挑战的伤害量<div fontcolor=#249003>%s</div>扫荡一次吗？"), self.scdata.dps)
            CommonAlert.show(msg,TI18N("确定"),function() 
                controller:sender26709(self.scdata.boss_id)
            end,TI18N("取消"),nil,CommonAlert.type.rich)
        end
    end
end

--挑战
function ActiontermbeginsTabBossPanel:onFightBtn()
    if self.is_time_out  then
        message(TI18N("活动已结束"))
        return
    end
    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.ticket_item_id)
    if count <= 0 then
        local ticket_item_config = Config.ItemData.data_get_data(self.ticket_item_id)
        if not ticket_item_config then return end
        local item_id = 3
        local cost = 100
        local config = Config.HolidayTermBeginsData.data_const.entrance_exam_cost
        if config and next(config.val) ~= nil then
            item_id = config.val[1] or 3
            cost = config.val[2] or 100
        end
        local item_config = Config.ItemData.data_get_data(item_id)
        local msg = string_format(TI18N("%s不足，是否花费 <img src=%s visible=true scale=0.5 />%s 购买<div fontcolor='#289b14'>1</div>张%s"), 
            ticket_item_config.name, PathTool.getItemRes(item_config.icon), cost, ticket_item_config.name)
        CommonAlert.show(msg, TI18N("确定"), function()
            controller:sender26712(0)
        end, TI18N("取消"), nil, CommonAlert.type.rich)
    else
        HeroController:getInstance():openFormGoFightPanel(true, PartnerConst.Fun_Form.TermBeginsBoss) 
    end
    
end
--收藏奖励
function ActiontermbeginsTabBossPanel:onRewardBtn()
    controller:openActiontermbeginsCollectResultPanel(true, {scdata = self.scdata, is_time_out = self.is_time_out})
end

function ActiontermbeginsTabBossPanel:setData(parent)
    if not self.is_init then
        self.is_init = true
        if self.parent and self.parent.scdata then
            self:setScdata(self.parent.scdata)         
        end
    end
end

function ActiontermbeginsTabBossPanel:setScdata(scdata)
    self.scdata = scdata

    local round_config = Config.HolidayTermBeginsData.data_round_info[self.scdata.round]
    if not round_config then return end
    local round_boss_config = Config.HolidayTermBeginsData.data_boss_info[round_config.boss_round]
    if not round_boss_config then return end
    -- if self.scdata.boss_flag ~= 1 and self.scdata.boss_id == 0 then
        --因为不开启 后端不发boss_id 默认第一个id 
        --这样写防止不是有序的
        for k,v in pairs(round_boss_config) do
            self.scdata.boss_id = v.boss_id
            break
        end
    -- end
    self.boss_config = round_boss_config[self.scdata.boss_id]
    if not self.boss_config then return end

    if self.scdata.boss_flag == 1 then
        self:initOpenPanelInfo()
    else
        self:initUnOpenPanleInfo()
    end  
end

function ActiontermbeginsTabBossPanel:initUnOpenPanleInfo()
    if not self.scdata then return end
    self.unopen_panel:setVisible(true)
    self.open_panel:setVisible(false)
    self.progress_container:setVisible(false)
    self.buff_node:setVisible(false)
    self:updateBuffIconInfo(false)

    self:updateParperInfo()
    if self.boss_config then
        self:updateSpine(self.boss_config.unit_id)
    end
    self:updateCostInfo()

    self.less_time:setVisible(true)
    local time = self.scdata.boss_time - GameNet:getInstance():getTime()
    if time < 0 then
        time = 0
    end
    commonCountDownTime(self.less_time, time, {callback = function(time) self:setTimeFormatString(time) end})
end

function ActiontermbeginsTabBossPanel:setTimeFormatString(time)
    if time > 0 then
        local str = string.format(TI18N("<div outline=2,#000000>%s</div><div fontcolor=#ffffff outline=2,#000000 >后开放</div>"),TimeTool.GetTimeFormatDayIIIIII(time))
        self.less_time:setString(str)
    else
        local str = string.format(TI18N("<div fontcolor=#ffffff outline=2,#000000 >即将开放</div>"))
        self.less_time:setString(str)
    end
end

function ActiontermbeginsTabBossPanel:updateParperInfo()
    if not self.scdata then return end
    local per = self.scdata.paper_sum * 100/self.collection_quantity
    if per > 100 then
        per = 100
    end
    self.progress:setPercent(per)
    self.progress_time:setString(math_floor(per).."%")
end

function ActiontermbeginsTabBossPanel:initOpenPanelInfo()
    if not self.scdata then return end
    if not self.boss_config then return end
    self.unopen_panel:setVisible(false)
    self.open_panel:setVisible(true)
    
    self.buff_node:setVisible(true)
    self:updateBuffIconInfo(true)
    self.less_time:setVisible(false)

    if self.scdata.dps and self.scdata.dps > 0 then
        self.sweep_btn_label:enableOutline(Config.ColorData.data_color4[263], 2)
        setChildUnEnabled(false, self.sweep_btn)
    else
        setChildUnEnabled(true, self.sweep_btn)
        self.sweep_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    end
    --boss血量
    local per = self.scdata.boss_hp_per/10
    self.boss_hp_progress:setPercent(per)
    self.boss_hp_value:setString(math_floor(per).."%")
    self.boss_name:setString(self.boss_config.boss_name)

    if self.boss_config then
        self:updateSpine(self.boss_config.unit_id)
    end

    if self.scdata.boss_hp_per == 0 then
        self.is_hit_img:setVisible(true)
        self.progress_container:setVisible(false)
    else
        self.is_hit_img:setVisible(false)
        self.progress_container:setVisible(true)
    end

    if next(self.boss_config.hit_award) ~= nil then
        local item_id = self.boss_config.hit_award[1][1]
        local count = self.boss_config.hit_award[1][2]
        self.reward_item:setBaseData(item_id,count)   
    end

    local rank = self.scdata.boss_rank or 0

    if rank and rank > 0 then
        self.rank_reward_label:setString(string_format(TI18N("您当前排名: %s%%"), rank))
        self.rank_reward_tips:setString(TI18N("保持排名您可获得以上奖励"))
    else
        self.rank_reward_label:setString(string_format(TI18N("您当前排名: 未上榜")))
        self.rank_reward_tips:setString(TI18N("前1%可获得以上奖励"))
    end

    local reward = model:getRankRewardByRank(rank)
    if reward and not self.item_list then
        local data_list = reward
        local setting = {}
        setting.scale = 0.6
        setting.max_count = 5
        setting.is_center = true
        -- setting.show_effect_id = 263
        self.item_list = commonShowSingleRowItemList(self.item_scrollview, self.item_list, data_list, setting)
    end

    self:updateCostInfo()

    local time = self.scdata.end_time - GameNet:getInstance():getTime()
    if time <= 0 then
        time = 0
        self:setBtnUnEnabled()
    else
        if self.time_ticket == nil then
            local _callback = function()
                time = time - 1
                if time <= 0 then
                    self:setBtnUnEnabled()
                    self:updateCostInfo()
                    self:clearTimeTicket()
                end 
            end
            self.time_ticket = GlobalTimeTicket:getInstance():add(_callback, 1)
        end
    end
end

function ActiontermbeginsTabBossPanel:setBtnUnEnabled()
    self.is_time_out = true
    setChildUnEnabled(true, self.sweep_btn)
    self.sweep_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
    setChildUnEnabled(true, self.fight_btn)
    self.fight_btn_label:disableEffect(cc.LabelEffect.OUTLINE)
end

function ActiontermbeginsTabBossPanel:clearTimeTicket()
    if self.time_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end
end 

--@bid buff的bid
function ActiontermbeginsTabBossPanel:updateBuffIconInfo(status)
    if not self.scdata then return end
    if status then
        if self.battle_buff_object == nil then
            self.battle_buff_object = {}
            
            local container = createCSBNote(PathTool.getTargetCSB("battle/battle_buff_icon"))
            container:setAnchorPoint(0.5, 0.5)
            -- container:setPosition(self.main_size.width-118, self.main_size.height/2+190)
            self.buff_node:addChild(container)
            local icon = container:getChildByName("icon")
            local Panel_1 = container:getChildByName("Panel_1")
            Panel_1:setVisible(false)
            local num_label = container:getChildByName("num_label")
            num_label:setVisible(false)
            local desc_label = container:getChildByName("desc_label")
            
            self.battle_buff_object.container = container           -- 父节点
            self.battle_buff_object.buff_icon = icon                -- 资源
            -- self.battle_buff_object.buff_time = num_label           -- 时间倒计时
            self.battle_buff_object.buff_desc = desc_label          -- 描述
        end
        if self.collection_buff then
            self.battle_buff_object.container:setVisible(true)
            local battle_buff_icon_res = PathTool.getBuffRes(self.collection_buff)
            if battle_buff_icon_res ~= self.battle_buff_object.buff_res then
                self.battle_buff_object.buff_res = battle_buff_icon_res
                loadSpriteTexture(self.battle_buff_object.buff_icon, battle_buff_icon_res, LOADTEXT_TYPE)
            end
            local per = self.scdata.buff_per
            self.battle_buff_object.buff_desc:setString(string_format(TI18N("伤害+%s%%"), per))
            -- self.battle_buff_object.buff_desc:setString(config.des)
        else
            self.battle_buff_object.container:setVisible(false)
        end
    else
        if self.battle_buff_object and self.battle_buff_object.container then
            self.battle_buff_object.container:setVisible(false)
        end
    end
end

--更新模型,也是初始化模型
function ActiontermbeginsTabBossPanel:updateSpine(unit_id)
    if not self.main_container then return end
    if self.cur_master_id == unit_id then return end

    self.cur_master_id = unit_id 
    local fun = function()
        if not self.spine then
            self.spine = BaseRole.new(BaseRole.type.unit, unit_id, nil, {scale = 1})
            self.spine:setAnimation(0,PlayerAction.show,true)
            self.spine:setCascade(true)
            self.spine:setPosition(self.main_container_size.width * 0.5, 780)
            self.spine:setAnchorPoint(cc.p(0.5,0.5))
            self.spine:setScale(0.8)
            self.main_container:addChild(self.spine)
            self.spine:setOpacity(0)
            local action = cc.FadeIn:create(0.2)
            self.spine:runAction(action)
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
end

--@day_combat_count 剩余挑战次数
function ActiontermbeginsTabBossPanel:updateCostInfo()
    if not self.scdata then return end

    local cur_item_id 
    if self.scdata.boss_flag == 1 then --开启boss 显示的准考证
        cur_item_id = self.ticket_item_id
        self.key_tips:setVisible(true)
    else --没开启显示的试卷数量
        cur_item_id = self.paper_item_id
        self.key_tips:setVisible(false)
    end

    --试卷的icon
    if self.record_cost_item_id == nil or self.record_cost_item_id ~= cur_item_id then
        self.record_cost_item_id = cur_item_id
        local config = Config.ItemData.data_get_data(cur_item_id)
        if config then
            local head_icon = PathTool.getItemRes(config.icon, false)
            loadSpriteTexture(self.icon, head_icon, LOADTEXT_TYPE)
        end
    end

    local count = BackpackController:getInstance():getModel():getItemNumByBid(cur_item_id)
    self.buy_count:setString(MoneyTool.GetMoneyString(count))
    if self.scdata.boss_flag == 1 then
        if not self.is_time_out and count > 0  then
            addRedPointToNodeByStatus(self.fight_btn, true, 5, 5)
        else
            addRedPointToNodeByStatus(self.fight_btn, false, 5, 5)
        end
    else
        if not self.is_time_out and count > 0  then
            addRedPointToNodeByStatus(self.comfirm_btn, true, 5, 5)
        else
            addRedPointToNodeByStatus(self.comfirm_btn, false, 5, 5)
        end
    end
    self:updateRewardBtnRedpoint()
end

function ActiontermbeginsTabBossPanel:updateRewardBtnRedpoint()
    if not self.scdata then return end
    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.paper_item_id)
    local is_receive = false
    if self.parent.paper_reward_scdata then
        for i,v in ipairs(self.parent.paper_reward_scdata.collect_schedule) do
            if v.staus == 1 then
                is_receive = true
                break
            end
        end
    end

    if count > 0 or is_receive then
        addRedPointToNodeByStatus(self.reward_btn, true, 5, 5)
    else
        addRedPointToNodeByStatus(self.reward_btn, false, 5, 5)
    end
end

function ActiontermbeginsTabBossPanel:setVisibleStatus(bool)
    self:setVisible(bool)
end

--移除
function ActiontermbeginsTabBossPanel:DeleteMe()
    if self.boss_form_event then
        GlobalEvent:getInstance():UnBind(self.boss_form_event)
        self.boss_form_event = nil
    end
    if self.subit_paper_event then
        GlobalEvent:getInstance():UnBind(self.subit_paper_event)
        self.subit_paper_event = nil
    end

    if self.modify_goods_event then
        GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end
    if self.add_goods_event then
        GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end
    if self.del_goods_event then
        GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end

    if self.item_load_panel_bg then
        self.item_load_panel_bg:DeleteMe()
    end
    self.item_load_panel_bg = nil

    if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    doStopAllActions(self.item_scrollview)
    self:clearTimeTicket()
end
