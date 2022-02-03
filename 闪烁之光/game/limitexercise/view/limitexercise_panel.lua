--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 限时试炼之境入口界面
-- @DateTime:    2019-05-29 19:34:10
-- *******************************
LimitExercisePanel = class("LimitExercisePanel", function()
    return ccui.Widget:create()
end)

local controller = LimitExerciseController:getInstance()
function LimitExercisePanel:ctor(bid)
	self.holiday_bid = bid
	self:configUI()
	self:register_event()
end

function LimitExercisePanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("limitexercise/limitexercise_panel"))
    self.root_wnd:setPosition(-40,-82)
    self:addChild(self.root_wnd)
    self:setCascadeOpacityEnabled(true)
    self:setAnchorPoint(0, 0)

    local main_container = self.root_wnd:getChildByName("main_container")
    local load_bg = main_container:getChildByName("bg")
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/limitexercise", "txt_cn_limit_exercise")
    if not self.holiday_load_bg then
        self.holiday_load_bg = loadSpriteTextureFromCDN(load_bg, bg_res, ResourcesType.single, self.holiday_load_bg)
    end

    main_container:getChildByName("Text_1"):setString(TI18N("活动时间："))
    
    self.btn_change = main_container:getChildByName("btn_change")
    self.btn_change:getChildByName("Text_4"):setString(TI18N("前往挑战"))

    main_container:getChildByName("Text_1_0"):setString(TI18N("剩余次数:"))
    main_container:getChildByName("Text_2"):setString(TI18N("本轮剩余:"))
    self.round_time = main_container:getChildByName("round_time")
    self.round_time:setString("")
    main_container:getChildByName("Text_2_0"):setString(TI18N("所在区域:"))
    main_container:getChildByName("Text_2_0_0"):setString(TI18N("挑战次数:"))
    main_container:getChildByName("Text_2_0_1"):setString(TI18N("击败怪物:"))
    self.aera_text = main_container:getChildByName("aera_text")
    self.aera_text:setString("")
    self.change_count = main_container:getChildByName("change_count")
    self.change_count:setString("")
    self.defaet_master = main_container:getChildByName("defaet_master")
    self.defaet_master:setString("")

    self.item_count = main_container:getChildByName("item_count")
    self.item_count:setString("")
    self.remain_time = main_container:getChildByName("remain_time")
    self.remain_time:setString("")
    self.goods_con = main_container:getChildByName("goods_con")
    self.goods_con:setScrollBarEnabled(false)
    self:setData()
    
    controller:send25410()
end
function LimitExercisePanel:setData()
	local const_data = Config.HolidayBossNewData.data_const
	if const_data then
		if const_data.action_time then
			local time_desc = const_data.action_time.desc or ""
			self.remain_time:setString(time_desc)
		end
		if const_data.action_pre_reward then
		    local data_list = const_data.action_pre_reward.val or {}
		    local setting = {}
		    setting.scale = 0.9
		    setting.max_count = 4
		    setting.is_center = true
		    setting.show_effect_id = 263
		    self.item_list = commonShowSingleRowItemList(self.goods_con, self.item_list, data_list, setting)
		end
	end
end
function LimitExercisePanel:register_event()
	if not self.action_reward_list then
        self.action_reward_list = GlobalEvent:getInstance():Bind(LimitExerciseEvent.LimitExercise_Message_Event,function(data)
            if not data then return end
            if self.actionHolidayData then
	            self:actionHolidayData(data)
	        end
        end)
    end
	registerButtonEventListener(self.btn_change, function()
		MainuiController:getInstance():requestOpenBattleRelevanceWindow(BattleConst.Fight_Type.LimitExercise)
	end, true)

    if not self.get_buy_event then
        self.get_buy_event = GlobalEvent:getInstance():Bind(LimitExerciseEvent.LimitExercise_BuyCount_Event,function(data)
            if not data then return end
            if self.item_count then
                self.item_count:setString(data.count or 0)
            end
        end)
    end
end

function LimitExercisePanel:actionHolidayData(data)
	local time = data.endtime or 0
	self:setCountDownTime(self.round_time, time - GameNet:getInstance():getTime())
	self.item_count:setString(data.count or 0)
	self.aera_text:setString(LimitExerciseConstants.type[data.order_type or 1])
	self.change_count:setString(data.round_combat or 0)
	self.defaet_master:setString(data.round_boss or 0)
end

function LimitExercisePanel:setVisibleStatus(bool)
    bool = bool or false
    self:setVisible(bool)
end
--******** 设置倒计时
function LimitExercisePanel:setCountDownTime(node,less_time)
    if tolua.isnull(node) then return end
    doStopAllActions(node)
    if less_time > 0 then
        self:setTimeFormatString(node,less_time)
        node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(1), cc.CallFunc:create(function()
            less_time = less_time - 1
            if less_time < 0 then
                doStopAllActions(node)
                node:setString("00:00:00")
            else
                self:setTimeFormatString(node,less_time)
            end
        end))))
    else
        self:setTimeFormatString(node,less_time)
    end
end
function LimitExercisePanel:setTimeFormatString(node,time)
    if time > 0 then
        node:setString(TimeTool.GetTimeFormatDay(time))
    else
        doStopAllActions(node)
        node:setString("00:00:00")
    end
end
function LimitExercisePanel:DeleteMe()
	doStopAllActions(self.round_time)
	if self.action_reward_list ~= nil then
        GlobalTimeTicket:getInstance():remove(self.action_reward_list)
        self.action_reward_list = nil
    end
    if self.get_buy_event ~= nil then
        GlobalTimeTicket:getInstance():remove(self.get_buy_event)
        self.get_buy_event = nil
    end

	if self.item_list then
        for i,v in pairs(self.item_list) do
            v:DeleteMe()
        end
        self.item_list = nil
    end
    if self.holiday_load_bg then
        self.holiday_load_bg:DeleteMe()
    end
    self.holiday_load_bg = nil
end

