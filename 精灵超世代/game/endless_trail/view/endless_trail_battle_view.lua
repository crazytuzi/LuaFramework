-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      无尽试炼战斗额外场景
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
EndlessTrailBattleView = class("EndlessTrailBattleView",function ( ... )
    return ccui.Widget:create()
end)

local controller = Endless_trailController:getInstance()
local model = Endless_trailController:getInstance():getModel()
local string_format = string.format

function EndlessTrailBattleView:ctor( ... )
    self:configUI()
    self.is_open = false
end

--UI界面
function EndlessTrailBattleView:configUI( ... )
   self.main_size = cc.size(SCREEN_WIDTH, display.height)
   self:setContentSize(self.main_size)
   self:setAnchorPoint(cc.p(0,1))
   self.root_wnd = createCSBNote(PathTool.getTargetCSB("endlesstrail/endlesstrail_battle_view"))
   self:addChild(self.root_wnd)
   self.top_container = self.root_wnd:getChildByName("top_container")

   self.top_container:setPositionY(display.getTop(self))
   self.right_container = self.top_container:getChildByName("right_container")
   self.right_container:setPositionY(65)
   self.return_btn = self.right_container:getChildByName("return_btn")
   self.backpack_btn = self.right_container:getChildByName("backpack_btn")
   self.backpack_label = createRichLabel(22, 1,cc.p(0.5,0.5),cc.p(self.backpack_btn:getContentSize().width/2 - 4,0),nil, nil, 800)
   self.backpack_btn:addChild(self.backpack_label)
   self.backpack_red = self.backpack_btn:getChildByName("red_point")
   self.left_container = self.top_container:getChildByName("left_container")
   self.left_container:setPositionY(10)
   self.container_1 = self.left_container:getChildByName("container_1")
   self.container_1_width = self.container_1:getContentSize().width
   self.container_1_height = self.container_1:getContentSize().height
   self.container_2 = self.left_container:getChildByName("container_2")
   self.container_2_width = self.container_2:getContentSize().width
   self.container_2_height = self.container_2:getContentSize().height
   self.desc_label = createRichLabel(22, 1,cc.p(0,0.5),cc.p(35,self.container_1:getContentSize().height/2 +2),nil, nil, 800)
   self.container_1:addChild(self.desc_label)
   self.desc_label_2 = createRichLabel(22, 1,cc.p(0,0.5),cc.p(160,self.container_1:getContentSize().height/2 +2),nil, nil, 800)
   self.container_1:addChild(self.desc_label_2)
   self.reward_label = createRichLabel(22, 1,cc.p(0,0.5),cc.p(0,self.container_2:getContentSize().height/2),nil, nil, 800)
   self.container_2:addChild(self.reward_label)
--    self.reward_btn_effect = createEffectSpine(PathTool.getEffectRes(257), cc.p(self.backpack_btn:getContentSize().width / 2, self.backpack_btn:getContentSize().height / 2), cc.p(0.5, 0.5), true, PlayerAction.action)
--    self.reward_btn_effect:setScale(0.5)
--    self.reward_btn_effect:setVisible(false)
--    self.backpack_btn:addChild(self.reward_btn_effect,2)

   self:registerEvent()
   self:updateData()
end

function EndlessTrailBattleView:registerEvent( ... )
    if self.return_btn then
        self.return_btn:addTouchEventListener(function(sender,event_type )
            if ccui.TouchEventType.ended == event_type then
                local str = TI18N("退出后本场战斗将判定为失败，且结束本次挑战并结算奖励，是否确认退出挑战？")
                local confirm_callback = function ( ... )
                    BattleController:getInstance():csFightExit()
                end
                CommonAlert.show(str,TI18N("我要退出"),confirm_callback,TI18N("继续挑战"),nil,CommonAlert.type.rich)
            end
        end)
    end
    if self.backpack_btn then
        self.backpack_btn:addTouchEventListener(function(sender,event_type )
            if ccui.TouchEventType.ended == event_type then
                if self.backpack_btn then
                    controller:openEndlessRewardTips(true,self.backpack_btn)
                end
            end
        end)
    end
    if not self.update_battle_data_event then
        self.update_battle_data_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_ENDLESSBATTLE_DATA,function(data)
            self:updateData(data)
        end)
    end
    if not self.update_first_event then
        self.update_first_event = GlobalEvent:getInstance():Bind(Endless_trailEvent.UPDATA_FIRST_DATA,function()
            local data = nil
            if self.battle_data then
                data = model:getFirstData(self.battle_data.type)
            end
            self:updateBtnStatus(data)
        end)
    end
end

function EndlessTrailBattleView:updateData(data)
    local final_data = data or model:getEndlessBattleData()
    if final_data then
        self.battle_data = final_data
        local str = string.format(TI18N("第%s关"),final_data.round)
        self:playFightStartEffect(final_data.round)
        local str_2 = TI18N("增益效果:")
        if final_data.buff_list and next(final_data.buff_list or {}) ~= nil then
            for i,v in ipairs(final_data.buff_list) do
                if Config.EndlessData.data_buff_data[v.group_id] and  Config.EndlessData.data_buff_data[v.group_id][v.id] then
                    local config = Config.EndlessData.data_buff_data[v.group_id][v.id]
                    if config then
                        str_2 = str_2 .. config.battle_desc
                    end
                end
            end
        else
            str_2 = str_2..TI18N("暂无")
        end
        self.desc_label_2:setString(str_2)
        self.desc_label:setString(str)

        local str_2 = TI18N("已累计奖励:  ")
        if final_data.acc_reward and next(final_data.acc_reward) then
            for i, v in ipairs(final_data.acc_reward) do
                local temp_str = string_format(TI18N("<img src=%s visible=true scale=0.35 /> %s "),PathTool.getItemRes(v.base_id),v.num)
                str_2 = str_2 ..temp_str
            end
        else
            if final_data.reward_flag == TRUE then
                str_2 = str_2 .. TI18N("当天已达上限,无法再结算奖励")
            else
                str_2 = string_format(TI18N("%s再过%s关开始结算(今日至第%s关)"), str_2, final_data.rest_round or 0, final_data.max_reward_round or 0)
            end
        end

        self.reward_label:setString(str_2)
        local width = math.max(self.reward_label:getSize().width,self.container_2_width)
        self.container_2:setContentSize(cc.size(width,self.container_2_height))
        local width = math.max(self.desc_label:getSize().width, self.container_1_width)
        self.container_1:setContentSize(cc.size(width, self.container_1_height))
        local data = {id = self.battle_data.id ,status = self.battle_data.status}
        self:updateBtnStatus(data)
    end
end

function EndlessTrailBattleView:playFightStartEffect(round)
    if self.cur_round == nil then
        self.cur_round = round
    end
    if self.cur_round == round then return end
    self.cur_round = round 

    if self.effect_container == nil then
        self.effect_container = ccui.Layout:create()
        self.effect_container:setContentSize(cc.size(470, 80))
        self.effect_container:setAnchorPoint(cc.p(0.5,0.5))
        self.effect_container:setPosition(self.main_size.width*0.5, 670)
        self.root_wnd:addChild(self.effect_container)

        self.top_effect = createEffectSpine( PathTool.getEffectRes(323), cc.p(235, 40), cc.p(0.5,0.5), false, PlayerAction.action)
        self.effect_container:addChild(self.top_effect)

        self.effect_img_1 = createSprite(PathTool.getResFrame("common", "txt_cn_common_90019"), 173, 45, self.effect_container, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST) 
        self.effect_img_2 = createSprite(PathTool.getResFrame("common", "txt_cn_common_90020"), 267, 45, self.effect_container, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST) 

        self.effect_width_1 = self.effect_img_1:getContentSize().width
        self.effect_width_2 = self.effect_img_2:getContentSize().width

        self.effect_num = CommonNum.new(26, self.effect_container, 1, -18, cc.p(0.5, 0.5))
        self.effect_num:setPosition(235, 74)

        self.bottom_effect = createEffectSpine( PathTool.getEffectRes(324), cc.p(235, 40), cc.p(0.5,0.5), false, PlayerAction.action)
        self.effect_container:addChild(self.bottom_effect)
    end
    self.top_effect:setAnimation(0, PlayerAction.action, false)
    self.bottom_effect:setAnimation(0, PlayerAction.action, false)
    self.effect_num:setNum(round)

    local left_x = 235-self.effect_width_1*0.5-50
    local right_x = 235+63+self.effect_width_2*0.5

    self.effect_container:setVisible(true)
    self.effect_img_1:setPosition(64,102)
    self.effect_img_2:setPosition(475,102)
    self.effect_img_1:setOpacity(0) 
    self.effect_img_2:setOpacity(0) 
    self.effect_num:setOpacity(0) 
    self.effect_num:setScale(0.5)

    local head_move_to = cc.MoveTo:create(0.08, cc.p(left_x, 45))
    local head_fade_in = cc.FadeIn:create(0.1)
    local head_delay = cc.DelayTime:create(0.3)
    local head_delay_2 = cc.DelayTime:create(0.5)
    local head_over = cc.CallFunc:create(function()
        self.effect_container:setVisible(false)
    end)
    self.effect_img_1:runAction(cc.Sequence:create(cc.Spawn:create(head_move_to ,head_fade_in), head_delay, head_delay_2, head_over))

    local label_move_to = cc.MoveTo:create(0.08, cc.p(right_x, 45))
    local label_fade_in = cc.FadeIn:create(0.1)
    self.effect_img_2:runAction(cc.Spawn:create(label_move_to,label_fade_in))
    local lanCode = cc.Application:getInstance():getCurrentLanguageCode()
    if lanCode == "en" then
        self.effect_img_2:setVisible(false)
    end

    local num_fade_in = cc.FadeIn:create(0.1) 
    local num_scale = cc.ScaleTo:create(0.1, 1)
    self.effect_num:runAction(cc.Spawn:create(num_scale, num_fade_in)) 
end

function EndlessTrailBattleView:updateBtnStatus(data)
    if self.battle_data and data and Config.EndlessData.data_first_data[self.battle_data.type] and Config.EndlessData.data_first_data[self.battle_data.type][data.id] then
        local first_data = Config.EndlessData.data_first_data[self.battle_data.type][data.id]
        if first_data then
            local str = ""
            self.backpack_btn.id = data.id
            if self.reward_item == nil then
                self.reward_item = BackPackItem.new(true,false)
                self.reward_item:setAnchorPoint(cc.p(0, 0))
                self.reward_item:setScale(0.7)
                self.reward_item:setPosition(6, 12)
                self.backpack_btn:addChild(self.reward_item)
            end
            if first_data.items and first_data.items[1] then
                self.reward_item:setBaseData(first_data.items[1][1], first_data.items[1][2])
            end
            -- self.backpack_label:setOpacity(255)
            -- doStopAllActions(self.backpack_label)
            -- self.reward_btn_effect:setVisible(false)
            if data.status == 1 then
                self.backpack_btn.status = 1 
                str = string_format(TI18N("<div fontcolor=#ffffff, outline=2,#581818>可领取</div>"))
                -- breatheShineAction(self.backpack_label)
                -- self.reward_btn_effect:setVisible(false)
                self.reward_item:showItemEffect(true,165,PlayerAction.action,true,1.2)
            else
                self.backpack_btn.status = 0
                str = string_format(TI18N('<div fontcolor=#fff22a outline=2,#581818>%s</div><div fontcolor=#ffffff, outline=2,#581818>关领取</div>'), first_data.limit_id) -- - self.battle_data.max_round
                self.reward_item:showItemEffect(false,165,PlayerAction.action,true)
            end
            self.backpack_label:setString(str)
        end
    end
end

function EndlessTrailBattleView:open( ... )
    if BattleController:getInstance():getCtrlBattleScene() then
        self.is_open = true
        BattleController:getInstance():getCtrlBattleScene():addExternView(self, display.getLeft(BattleController:getInstance():getCtrlBattleScene()), display.getTop(BattleController:getInstance():getCtrlBattleScene()))
        delayRun(self.root_wnd,1,function ()
            controller:send23902()
        end)
    end 
end

function EndlessTrailBattleView:isOpen( ... )
    return self.is_open
end
function EndlessTrailBattleView:close( ... )
    if self.reward_item then
		self.reward_item:DeleteMe()
		self.reward_item = nil
    end
    
    if self.effect_num then
        self.effect_num:DeleteMe()
    end
    self.effect_num = nil
    self.is_open = false
    if self.update_battle_data_event then
        GlobalEvent:getInstance():UnBind(self.update_battle_data_event)
        self.update_battle_data_event = nil
    end
    if self.update_first_event then
        GlobalEvent:getInstance():UnBind(self.update_first_event)
        self.update_first_event = nil
    end
    self:removeAllChildren()
    self:removeFromParent()
end