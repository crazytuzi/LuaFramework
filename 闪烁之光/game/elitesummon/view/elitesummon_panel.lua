--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 限时精英招募
-- @DateTime:    2019-06-27 20:01:30
-- *******************************
local controller = EliteSummonController:getInstance()
local arard_data = Config.RecruitHolidayEliteData.data_award
local const_data = Config.RecruitHolidayEliteData.data_const
local summon_data = Config.RecruitHolidayEliteData.data_summon
--活动配置
local action_config = Config.RecruitHolidayEliteData.data_action
EliteSummonPanel = class("EliteSummonPanel", function()
    return ccui.Widget:create()
end)

function EliteSummonPanel:ctor(bid)
	self.holiday_bid = bid
	self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("elitesummon","elitesummon"), type = ResourcesType.plist },
    } 
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
        	self:loadResListCompleted()
        end
    end)
    
    self.touch_recruit_10 = true --点击延迟
    self.is_can_award = false --是否有可领取的保底奖励
    self.recruit_type_1 = nil --单抽
    self.recruit_type_10 = nil --10抽
    self.awwrd_count = nil
end
-- 资源加载完成
function EliteSummonPanel:loadResListCompleted()
	self:configUI()
	self:register_event()
end
function EliteSummonPanel:configUI(  )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("elitesummon/elitesummon_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")

    local image_bg = main_container:getChildByName("image_bg")
    local str_bg = "txt_cn_elitesummon_1"
    local tab_vo = ActionController:getInstance():getActionSubTabVo(self.holiday_bid)
    if tab_vo and tab_vo.aim_title ~= "" and tab_vo.aim_title then
        str_bg = tab_vo.aim_title
    end
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/timesummon", str_bg)
	self.bg_load = loadSpriteTextureFromCDN(image_bg, bg_res, ResourcesType.single, self.bg_load)

    --单抽
    self.btn_summon_1 = main_container:getChildByName("btn_summon_1")
    self.btn_summon_1:getChildByName("Text_8"):setString(TI18N("招募1次"))
    self.remain_time = createRichLabel(18, cc.c4b(0xff,0xff,0xff,0xff), cc.p(0.5,0.5), cc.p(120.50,23))
    self.btn_summon_1:addChild(self.remain_time)
    
    --10抽
    self.btn_summon_10 = main_container:getChildByName("btn_summon_10")
    self.btn_summon_10:getChildByName("Text_8"):setString(TI18N("招募10次"))
    self.icon_10 = self.btn_summon_10:getChildByName("Sprite_7")
    self.count_10 = self.btn_summon_10:getChildByName("count")
    self.count_10:setString("")

    self.btn_reward = main_container:getChildByName("btn_reward")
    self.btn_reward:getChildByName("Text_9"):setString(TI18N("奖励预览"))
    self.btn_rule = main_container:getChildByName("btn_rule")

    self.icon = main_container:getChildByName("icon")
    self.icon_count = main_container:getChildByName("icon_count")
    self.icon_count:setString("")
    local config = Config.ItemData.data_get_data(const_data.common_s.val)
    if config then
        local icon_res = PathTool.getItemRes(config.icon)
        loadSpriteTexture(self.icon, icon_res, LOADTEXT_TYPE)
        self.icon:setScale(0.45)
    end

    self.summon_item_bid = const_data["common_s"].val
    local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
    self.icon_count:setString(summon_have_num)

    self.holiday_time = main_container:getChildByName("time")
    main_container:getChildByName("next_level_text"):setString(TI18N("下一阶段"))
    self.next_text = main_container:getChildByName("next_text")
    self.next_text:setString("")
    self.bar = main_container:getChildByName("bar")
    self.bar:setScale9Enabled(true)
    self.bar:setPercent(0)

    --剩余次数
    self.remain_up = createRichLabel(20, cc.c4b(0xff,0xff,0xff,0xff), cc.p(1,0.5), cc.p(659,787))
    main_container:addChild(self.remain_up)
    
    self.award_item = BackPackItem.new(true, true, false, 0.6)
    self.award_item:setPosition(cc.p(60, 718))
    self.award_item:addCallBack(handler(self, self.onClickAwardItem))
    main_container:addChild(self.award_item)

    controller:send23220()
end
function EliteSummonPanel:onClickAwardItem()
    if self.data then
        if self.is_can_award then
            controller:send23222()
        else
            TimesummonController:getInstance():openTimeSummonProgressView(true, self.data.times, self.data.camp_id)
        end
    end
end
--******** 设置倒计时
function EliteSummonPanel:setCountDownTime(node,less_time)
    if tolua.isnull(node) then return end
    doStopAllActions(node)

    less_time = less_time - GameNet:getInstance():getTime()
    local setTimeFormatString = function(time)
        if tolua.isnull(node) then return end
        if time > 0 then
            local str = string.format(TI18N("<div fontcolor=#35FF14>%s</div>%s"),TimeTool.GetTimeFormat(time),"后免费")
            node:setString(str)
        else
            doStopAllActions(node)
            node:setString(TI18N("免费召唤"))
        end
    end
    if less_time > 0 then
        setTimeFormatString(less_time)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(node)
                node:setString(TI18N("免费召唤"))
            else
                setTimeFormatString(less_time)
            end
        end))))
    else
        setTimeFormatString(less_time)
    end
end

function EliteSummonPanel:register_event()
    if not self.message_event then
        self.message_event = GlobalEvent:getInstance():Bind(EliteSummonEvent.EliteSummon_Message,function(data)
            if not data then return end
            local status = controller:getModel():isHolidayHasID(data.camp_id)
            if status then
                self:setData(data)
            end
        end)
    end

    registerButtonEventListener(self.btn_reward, function()
        if self.data and self.data.camp_id then
            local config = action_config[self.data.camp_id]
            if config then
                local probabily_data = Config.RecruitHolidayEliteData.data_probability[config.group_id]
                TimesummonController:getInstance():openTimeSummonAwardView(true, config.group_id, self.data,TimesummonConst.ActonInfoType.EliteType)
            end
        end
    end, true)

    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
        if self.data and self.data.camp_id then
            local config = action_config[self.data.camp_id]
            if config then
                TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition(),nil,nil,500)
            end
        end
    end, true,nil,nil,0.8)

    registerButtonEventListener(self.btn_summon_1, function()
        if self.recruit_type_1 then --钻石
            if self.recruit_type_1 == 3 then
                if self.data and self.data.camp_id then
                    self:RecruitDaimond(1)
                end
            else
                controller:send23221(1,self.recruit_type_1)
            end
        end
    end, true)
    registerButtonEventListener(self.btn_summon_10, function()
        if not self.touch_recruit_10 then
            message(TI18N("点击过快~~~"))
            return
        end
        if self.recruit_10_ticket == nil then
            self.recruit_10_ticket = GlobalTimeTicket:getInstance():add(function()
                self.touch_recruit_10 = true
                if self.recruit_10_ticket ~= nil then
                    GlobalTimeTicket:getInstance():remove(self.recruit_10_ticket)
                    self.recruit_10_ticket = nil
                end
            end,2)
        end
        self.touch_recruit_10 = nil
        if self.recruit_type_10 then
            if self.recruit_type_10 == 3 then
                self:RecruitDaimond(10)
            else
                controller:send23221(10,self.recruit_type_10)
            end
        end
    end, true)
    
	-- 道具数量更新
    if not self.update_add_good_event then
        self.update_add_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
    if not self.update_delete_good_event then
        self.update_delete_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
    if not self.update_modify_good_event then
        self.update_modify_good_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM,function(bag_code, data_list)
            self:updateItemNum(bag_code,data_list)
        end)
    end
end

--用钻石招募的提示
function EliteSummonPanel:RecruitDaimond(model)
    if self.data and self.data.camp_id then
        local config = action_config[self.data.camp_id]
        if config then
            local role_vo = RoleController:getInstance():getRoleVo()
            if summon_data and summon_data[config.group_id] then
                local data = summon_data[config.group_id]

                local num
                if model == 1 then
                    num = data.loss_gold_once[1][2]
                else
                    num = data.loss_gold_ten[1][2]
                end
                if not num then return end

                local have_gold = role_vo.gold
                if have_gold < num then
                    message(TI18N("钻石不足~~~"))
                    return
                end

                local str = string.format(TI18N("是否使用 <img src=%s visible=true scale=0.35 /><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>(拥有:</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519>)\n</div>"),PathTool.getItemRes(3),num,have_gold)
        
                local val_num = 0
                if model == 1 then
                    val_num = data.gain_once[1][2]
                elseif model == 10 then
                    val_num = data.gain_ten[1][2]
                end

                local str_ = str..string.format(TI18N("<div fontColor=#764519>购买</div><div fontColor=#289b14 fontsize= 26>%s</div><div fontColor=#764519></div><div fontColor=#d95014 fontsize= 26>英雄经验</div><div fontColor=#764519>(同时附赠</div><div fontColor=#289b14 fontsize= 26>%d</div><div fontColor=#764519>次招募)</div>"),val_num, model)
                local function call_back()
                    controller:send23221(model,3)
                end
                CommonAlert.show(str_, TI18N("确定"), call_back, TI18N("取消"), nil, CommonAlert.type.rich)
            end
        end
    end
end

-- 刷新道具数量
function EliteSummonPanel:updateItemNum(bag_code, data_list)
    if self.summon_item_bid then
        if bag_code and data_list then
            if bag_code == BackPackConst.Bag_Code.BACKPACK then
                for i,v in pairs(data_list) do
                    if v and v.base_id and self.summon_item_bid == v.base_id then
                        local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
                        if self.icon_count then
                            self.icon_count:setString(summon_have_num)
                        end
                        self:recruitBtnStatus(1)
                        self:recruitBtnStatus(10)
                        break
                    end
                end
            end
        end
    end
end
function EliteSummonPanel:setData(data)
    self.data = data
    
    self:recruitBtnStatus(1)
    self:recruitBtnStatus(10)

    self:setCountDownTime(self.remain_time,data.free_time)

    local str_time = string.format("%s-%s",TimeTool.getMD2(data.start_time),TimeTool.getMD2(data.end_time))
    self.holiday_time:setString(str_time)

    local str = string.format(TI18N("<div outline=2,#000000>剩余</div><div fontcolor=#5fde46 fontsize=20 outline=2,#000000>%d</div><div outline=2,#000000>次招募内必出UP英雄</div>"),data.must_count)
    self.remain_up:setString(str)

    self:nextRewardLevel()
end
--下一阶段奖励
function EliteSummonPanel:nextRewardLevel()
    local count = self:nextCount(self.data.times)

    if arard_data[self.data.camp_id] and arard_data[self.data.camp_id][count] then
        local data = arard_data[self.data.camp_id]

        if self.award_item then
            local bid = data[count].reward[1][1]
            local num = data[count].reward[1][2]
            self.award_item:setBaseData(bid, num)

            self.is_can_award, can_id = self:getBaoDIStatus()
            if self.is_can_award == true then
                if can_id then
                    local bid = data[can_id].reward[1][1]
                    local num = data[can_id].reward[1][2]
                    self.award_item:setBaseData(bid, num)
                end
                self.award_item:showItemEffect(true, 263, PlayerAction.action_1, true, 1.1)
            else
                self.award_item:showItemEffect(false)
            end
            --全部领取完毕的时候
            if self.is_can_award == false and self.data.times >= data[#data].times then
                setChildUnEnabled(true, self.award_item)
                self.award_item:setReceivedIcon(true)
            end
        end
        local num_times = data[count].times
        self.next_text:setString(self.data.times.."/"..num_times)     
        local cur_num = 0
        local totle_num = num_times
        if count == 1 then
            cur_num = self.data.times
        else
            cur_num = self.data.times - data[count-1].times
            totle_num = num_times-data[count-1].times
        end
        local percent = cur_num / totle_num * 100
        if self.data.times >= data[#data].times then
            percent = 100
        end
        self.bar:setPercent(percent)
    end
end
--根据当前阶段计算下一次奖励
function EliteSummonPanel:nextCount(cur_num)
    local count = 1
    local data = arard_data[self.data.camp_id]
    if arard_data and data then
        if cur_num >= data[#data].times then
            return data[#data].id
        end

        for i=1,#data do
            local m = i+1
            if m >= #data then
                m = #data
            end
            if data[i].times > cur_num and cur_num <= data[m].times then
                count = data[i].id
                break
            end
        end
    end
    return count
end
--领取保底状态
function EliteSummonPanel:getBaoDIStatus()
    local status = false
    local id = nil
    if self.data then
        if arard_data[self.data.camp_id] then
            for i,v in ipairs(arard_data[self.data.camp_id]) do
                local cur_status = false
                local cur_id = nil
                if self.data.times >= v.times then
                    cur_status = true
                    cur_id = v.id
                end
                local true_status = true
                if cur_status == true then
                    for i,v in pairs(self.data.reward_list) do
                        if v.id == cur_id then
                            true_status = false
                            break
                        end
                    end
                end
                if cur_id and true_status == true then
                    status = true
                    id = cur_id
                end
            end
        end
    end
    return status,id
end

--设置招募按钮的状态
function EliteSummonPanel:recruitBtnStatus(model)
    if self.data and self.data.camp_id then
        local config = action_config[self.data.camp_id]
        if config then
            if summon_data and summon_data[config.group_id] then
                local data = summon_data[config.group_id]
                local summon_have_num = BackpackController:getInstance():getModel():getItemNumByBid(self.summon_item_bid)
                if summon_have_num >= model then --道具抽取
                    local config
                    if model == 1 then
                        self.recruit_type_1 = 4
                        config = Config.ItemData.data_get_data(data.loss_item_once[1][1])
                    elseif model == 10 then
                        self.recruit_type_10 = 4
                        config = Config.ItemData.data_get_data(data.loss_item_ten[1][1])
                    end
                    if config then
                        local icon_res = PathTool.getItemRes(config.icon)
                        loadSpriteTexture(self.icon_10, icon_res, LOADTEXT_TYPE)
                        self.icon_10:setScale(0.30)
                        if model == 1 then
                            self.count_10:setString(data.loss_item_once[1][2])
                        elseif model == 10 then
                            self.count_10:setString(data.loss_item_ten[1][2])
                        end
                    end
                else --钻石抽取
                    local config
                    if model == 1 then
                        self.recruit_type_1 = 3
                        config = Config.ItemData.data_get_data(data.loss_gold_once[1][1])
                    elseif model == 10 then
                        self.recruit_type_10 = 3
                        config = Config.ItemData.data_get_data(data.loss_gold_ten[1][1])
                    end
                    if config then
                        local icon_res = PathTool.getItemRes(config.icon)
                        loadSpriteTexture(self.icon_10, icon_res, LOADTEXT_TYPE)
                        self.icon_10:setScale(0.30)
                        if model == 1 then
                            self.count_10:setString(data.loss_gold_once[1][2])
                        elseif model == 10 then
                            self.count_10:setString(data.loss_gold_ten[1][2])
                        end
                    end
                end
                --单抽免费的时候
                if self.data.free_time <= 0 then
                    self.recruit_type_1 = 1
                end
            end
        end
    end
end

function EliteSummonPanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end

function EliteSummonPanel:DeleteMe()
    doStopAllActions(self.remain_time)
    if self.resources_load then
        self.resources_load:DeleteMe()
        self.resources_load = nil
    end
    if self.award_item then
        self.award_item:DeleteMe()
        self.award_item = nil
    end
	if self.bg_load then
		self.bg_load:DeleteMe()
		self.bg_load = nil
	end
    if self.message_event then
        GlobalEvent:getInstance():UnBind(self.message_event)
        self.message_event = nil
    end
    if self.update_add_good_event then
        GlobalEvent:getInstance():UnBind(self.update_add_good_event)
        self.update_add_good_event = nil
    end
    if self.update_delete_good_event then
        GlobalEvent:getInstance():UnBind(self.update_delete_good_event)
        self.update_delete_good_event = nil
    end
    if self.update_modify_good_event then
        GlobalEvent:getInstance():UnBind(self.update_modify_good_event)
        self.update_modify_good_event = nil
    end
    if self.recruit_10_ticket ~= nil then
        GlobalTimeTicket:getInstance():remove(self.recruit_10_ticket)
        self.recruit_10_ticket = nil
    end
end
