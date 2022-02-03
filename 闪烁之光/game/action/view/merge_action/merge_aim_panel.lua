--******** 文件说明 ********
-- @Author:      lc 
-- @description: 合服目标
-- @DateTime:    2019-10-15
-- *******************************
MergeAimPanel = class("MergeAimPanel", function()
    return ccui.Widget:create()
end)

local controller = ActionController:getInstance()
function MergeAimPanel:ctor(bid)
    self.holiday_bid = bid
    self.touch_buy_skin = true
    self.attr_list = {}
    self:configUI()
    self:register_event()
    self.charge_status = 0 
    self.config = Config.HolidayMergeGoalData
    self._base_val = Config.HolidayMergeGoalData.data_const["base_max_score"].val
end

function MergeAimPanel:configUI()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("welfare/merge_aim_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.holiday_bg = self.main_container:getChildByName("bg")
    self:setHolidayBG()
    
    self.time_text_0 = self.main_container:getChildByName("time_text_0")
    self.time_text_0:setString(TI18N("剩余时间："))

    self.Image_1 = self.main_container:getChildByName("Image_1")
    self.process = self.main_container:getChildByName("process")
    self.process:setContentSize(cc.size(225,17))  -- Max = 450
    self.text_process = self.main_container:getChildByName("text_process")
    self.text_process:setString("0/0")
    self.btn_reward = self.main_container:getChildByName("btn_reward")
    self.Text_9 = self.btn_reward:getChildByName("Text_9")
    self.Text_9:setString(TI18N("查看奖励"))

    self.btn_rule = self.main_container:getChildByName("btn_rule")
    self.sprite_1 = self.main_container:getChildByName("sprite_1")
    self.Text_32 = self.main_container:getChildByName("Text_32")
    self.Text_32:setString(TI18N("合服活动期间，完成一项合服任务\n即可贡献10点合服积分，宝箱达到\n目标即可领取七档豪华奖励！"))
    self.Text_lev = self.main_container:getChildByName("Text_lev")
    self.Text_lev:setString(TI18N("0级"))
    self.box_btn = self.main_container:getChildByName("reward")




    local Text_2 = self.main_container:getChildByName("Text_2")
    Text_2:setVisible(false)

    self.btn_buy = self.main_container:getChildByName("btn_buy")
    self.btn_buy_text = self.btn_buy:getChildByName("Text_4")
    self.btn_buy_text:setString(TI18N("使用礼包"))
    self.btn_buy:setVisible(false)
    self.time_text = self.main_container:getChildByName("time_text")
    self.time_text:setString("")
    
    
end

function MergeAimPanel:setHolidayBG()
    local str_bg = "action_merge_goal"
    local tab_vo = controller:getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.aim_title ~= "" and tab_vo.aim_title then
        str_bg = tab_vo.aim_title
    end
    local res = PathTool.getPlistImgForDownLoad("bigbg/action", str_bg)
    if not self.bg_load then
        self.bg_load = loadSpriteTextureFromCDN(self.holiday_bg, res, ResourcesType.single, self.bg_load)
    end
end

function MergeAimPanel:setBaseData( data )
    if data ~= nil then
        self.data = data
        commonCountDownTime(self.time_text, data.end_time)
        self:setData(data)
    end
end

function MergeAimPanel:getBoxNum(  )
    local lev = 0
    if self.data.score < self.data.max_score then 
        lev = self.data.lev -1 
    else
        lev = self.data.lev
    end
    return lev
end

function MergeAimPanel:setBoxStatus()
    local has_gain_reward = deepCopy(self.data.reward)
    local data_list = {}
    local can_gain_list = {}
    local data_finish = {} 
    table.sort(has_gain_reward,function (a,b) return a.id < b.id end)  --排序已经领取过的奖励
    local cur_lev = self:getBoxNum()
    for i=1,cur_lev do
        local data_1 =  {}
        data_1.id  = Config.HolidayMergeGoalData.data_score_award[i].id
        table.insert(data_list, data_1)  --获取初始等级到当前等级的所有奖励
    end
    if #has_gain_reward == 0 then
        for j=1,#data_list do
            local data_2 = {}
            data_2.id  = data_list[j].id
            table.insert(can_gain_list,data_2)
        end
    else
        for i=1,#has_gain_reward do
            for j=1,#data_list do
                if has_gain_reward[i].id == data_list[j].id then
                    table.insert(data_finish,data_list[j])
                end
            end
            
        end
    end
    if #data_finish > 0 then
        for k,v in ipairs(data_list) do
            for i,j in ipairs(data_finish) do
                if data_list[k].id  == data_finish[i].id then
                    table.remove(data_list,k)
                end
            end
        end
        for i,v in ipairs(data_list) do
            table.insert(can_gain_list,v)
        end
    end
    table.sort(can_gain_list,function (a,b) return a.id < b.id end)
    if #can_gain_list == 0  then 
        ActionController:getInstance():openMergeAimRewardPanel(true)
    else
        ActionController:getInstance():sender27301(can_gain_list)
    end
end

function MergeAimPanel:register_event()
    if not self.merge_info_event then
        self.merge_info_event = GlobalEvent:getInstance():Bind(ActionEvent.Merge_Aim_Event,function(data)
            if not data then return end
            self:setBaseData(data)
        end)
    end    

    if not self.merge_gain_box_event then
        self.merge_gain_box_event = GlobalEvent:getInstance():Bind(ActionEvent.Merge_Box_Status_Event,function(data)
            if not data then return end
                message(data.msg)
        end)
    end   

    registerButtonEventListener(self.btn_buy, function()
        self:gift_Use()
    end, true,2)

    registerButtonEventListener(self.btn_reward, function()  --奖励预览
        ActionController:getInstance():openMergeAimRewardPanel(true)
    end, true,2)

    registerButtonEventListener(self.box_btn, function()  --宝箱
        self:setBoxStatus()
    end, true,2)


    if self.btn_rule then
        self.btn_rule:addTouchEventListener(function( sender,event_type )
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                TipsManager:getInstance():showCommonTips(Config.HolidayMergeGoalData.data_const.game_rule.desc, sender:getTouchBeganPosition())
            end
        end)
    end
end

function MergeAimPanel:gift_Use()
    local vo  = BackpackController:getInstance():getModel():getBackPackItemByBid(80240)
    if vo then
        BackpackController:getInstance():openBatchUseItemView(true,vo,ItemConsumeType.use)
    else
        message(TI18N("暂无可打开的礼包"))
    end
end
--奖励
function MergeAimPanel:setData(data)
    self.text_process:setString(string.format("%s%s%s",data.score,"/",data.max_score))
    local length = 450 * data.score / data.max_score 
    self.process:setContentSize(cc.size(length,17))
    self.Text_lev:setString(data.lev..TI18N("级"))
    self.box_status = false
    if data.reward ~= nil and next(data.reward) ~= nil then --有领取过
        if (data.score / data.max_score) < 1 then  --当前等级未达到领取条件
            if data.lev == 1 then
                self.box_status = false
            else
                if #data.reward == data.lev - 1 then  --全部领取了
                    self.box_status = false
                else
                    self.box_status = true
                end
            end
        else 
            if #data.reward == data.lev  then  --全部领取了
                self.box_status = false
            else
                self.box_status = true
            end
        end
    else
        --可领取
        if data.lev > Config.HolidayMergeGoalData.data_score_award[1].id then
            self.box_status = true 
        else
            if (data.score / data.max_score) < 1 then  --当前等级未达到领取条件
                self.box_status = false
            else
                self.box_status = true
            end
        end

    end
    if self.box_effect then
        self.box_effect:clearTracks()
        self.box_effect:removeFromParent()
        self.box_effect = nil
    end

    if self.box_status == true then
        if not tolua.isnull(self.box_btn) and self.box_effect == nil then
            self.box_effect = createEffectSpine(PathTool.getEffectRes(110), cc.p(20, 22), cc.p(0, 0), true, PlayerAction.action_2)
            self.box_btn:addChild(self.box_effect)
        end
    else
        if not tolua.isnull(self.box_btn) and self.box_effect == nil then
            self.box_effect = createEffectSpine(PathTool.getEffectRes(110), cc.p(20, 22), cc.p(0, 0), true, PlayerAction.action_1)
            self.box_btn:addChild(self.box_effect)
        end
    end
   
end



function MergeAimPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
    if bool == true then
        ActionController:getInstance():sender27300()
    end
end

function MergeAimPanel:DeleteMe()

    doStopAllActions(self.time_text)
    if self.bg_load then
        self.bg_load:DeleteMe()
        self.bg_load = nil
    end

    if self.merge_info_event then
        GlobalEvent:getInstance():UnBind(self.merge_info_event)
        self.merge_info_event = nil
    end
    if self.merge_gain_box_event then
        GlobalEvent:getInstance():UnBind(self.merge_gain_box_event)
        self.merge_gain_box_event = nil
    end
end