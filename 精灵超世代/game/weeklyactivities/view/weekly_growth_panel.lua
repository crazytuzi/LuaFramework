
-- --------------------------------------------------------------------
WeeklyGrowthPanel = class("WeeklyGrowthPanel", function()
	return ccui.Widget:create()
end)

local controll = WeeklyActivitiesController:getInstance()
local model    = WeeklyActivitiesController:getModel()
local card_data = Config.ChargeData.data_constant
local mainui_ctrl = MainuiController:getInstance()
local string_format = string.format
local card2_add_count = card_data.month_card2_sun.val
local item_bid_2 = card_data.month_card2_items.val[1][1]
local item_num_2 = card_data.month_card2_items.val[1][2]
local add_get_day_2 = card_data.month_card2_cont_day.val
function WeeklyGrowthPanel:ctor()
	self.current_day = 0
	self.isPlay = false
	self.playNum = 1
	self.item_id = 17449
	self:loadResources()
end

function WeeklyGrowthPanel:loadResources()
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("bigbg/welfare","txt_cn_hippocreneBg"), type = ResourcesType.single },
    	} 
    self.resources_load = ResourcesLoad.New(true)
    self.resources_load:addAllList(self.res_list, function()
        if self.loadResListCompleted then
        	self:loadResListCompleted()
        end
    end)
end

function WeeklyGrowthPanel:loadResListCompleted()
	self:configUI()
	self:register_event()
end

function WeeklyGrowthPanel:configUI()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("weeklyactivity/hippocrene_growth_panel"))
	self:addChild(self.root_wnd)
	-- self:setCascadeOpacityEnabled(true)
	self:setAnchorPoint(0, 0)
	
	self.main_container = self.root_wnd:getChildByName("main_container")
	self.animtionNode   = self.main_container:getChildByName("animtionNode")

	local bg = self.main_container:getChildByName("bg")
	local res_id = PathTool.getPlistImgForDownLoad("bigbg/welfare", "txt_cn_hippocreneBg")
    if not self.title_load then
        self.title_load = createResourcesLoad(res_id, ResourcesType.single, function()
            if not tolua.isnull(bg) then
                loadSpriteTexture(bg,res_id,LOADTEXT_TYPE)
            end
        end, self.title_load)
    end

	self.btn_cultivate1 = self.main_container:getChildByName("btn_cultivate1")
	self.btn_cultivate10 = self.main_container:getChildByName("btn_cultivate10")
	self.btn_reward = self.main_container:getChildByName("btn_reward")
	self.btn_rank = self.main_container:getChildByName("btn_rank")
	local buy_panel = self.main_container:getChildByName("buy_panel")
	self.add_btn = buy_panel:getChildByName("add_btn")
	self.btn_rule = self.main_container:getChildByName("btn_rule")
	self.item_conut = self.main_container:getChildByName("buy_panel"):getChildByName("label")
	self.time_text_0 = self.main_container:getChildByName("time_text_0")
	self.time_text   = self.main_container:getChildByName("time_text")
	self.Text_1      = self.main_container:getChildByName("Text_1")

	self.btn_reward:getChildByName("Text_9"):setString(TI18N("奖励预览"))
	self.btn_rank:getChildByName("txt"):setString(TI18N("排行"))
	self.btn_cultivate1:getChildByName("Text_4"):setString(TI18N("培育1次"))
	self.btn_cultivate10:getChildByName("Text_4"):setString(TI18N("培育10次"))
	self.main_container:getChildByName("consumeDesTxe10"):setString(TI18N("消耗"))
	self.main_container:getChildByName("consumeDesTxe1"):setString(TI18N("消耗"))
	local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id) or 0
    self.item_conut:setString(tostring(count))
    self.time_text_0:setString(TI18N("剩余时间"))
    self.Text_1:setString(TI18N("培育可获得智慧之花奖励"))

	self:playFlowerAnim( )
	self:setLessTime(model:getWeeklyActivityData())
end

function WeeklyGrowthPanel:setLessTime(data)
	local time = (data.end_time or 0 ) -GameNet:getInstance():getTime()
	if time < 0 then return end
	self.time_text:setString(TimeTool.GetTimeFormatDayIIIIII(time))

    if self.time_ticket == nil then
		local _callback = function() 
			local time = data.end_time-GameNet:getInstance():getTime()
			if  time >= 0 then
				self.time_text:setString(TimeTool.GetTimeFormatDayIIIIII(time))
			else
				if self.time_ticket then
        			GlobalTimeTicket:getInstance():remove(self.time_ticket)
        			self.time_ticket = nil
    			end
			end
		end
        self.time_ticket = GlobalTimeTicket:getInstance():add(_callback)
    end
end

function WeeklyGrowthPanel:playFlowerAnim( )
	if(self.flower == nil) then 
		self.flower = createEffectSpine("dc_hua",cc.p(0,0),cc.p(0.5, 0.5),false,"action"
			..self.playNum ,handler(self , self.flowerAnimationComplete))
		self.animtionNode:addChild(self.flower)
	end
end

function WeeklyGrowthPanel:flowerAnimationComplete()
	if(self.flower)then
		local action = "action"..self.playNum
		self.flower:setAnimation(0, action, false)
	end
end

function WeeklyGrowthPanel:setFlowerNum( num )
	self.playNum = num
end


function WeeklyGrowthPanel:playWetOutAnimation(num)
	if self.isPlay == true then  return  end
	self.isPlay = true
	local id = BackpackController:getInstance():getModel():getBackPackItemIDByBid(self.item_id)
	local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id) 
	if count > 0 then
		controll:send_29201(id,num)
	else 
		local config = Config.ItemData.data_get_data(self.item_id)
		BackpackController:getInstance():openTipsSource(true, config)
	end

	if not self.wetOut  then
		self.wetOut = createEffectSpine("dc_death",cc.p(0,0),cc.p(0.5, 0.5),false,"action",handler(self , self.wetOutAnimationComplete))
		self.animtionNode:addChild(self.wetOut)
	else
		self.wetOut:setAnimation(0, "action", false)
	end
end

function WeeklyGrowthPanel:wetOutAnimationComplete()
	self.isPlay = false
end


function WeeklyGrowthPanel:register_event()
	self.update_week_data = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.UPDATE_WEEK_DATA, function(data)
		if data then
			self:setLessTime(data)
		end
	end)

	self.update_cultivace = GlobalEvent:getInstance():Bind(WeeklyActivitiesEvent.UPDATE_CULTIVACE, function(data)
		--dump(data, "培育结果-------------->")
		--local count = BackpackController:getInstance():getModel():getItemNumByBid(self.draw_consume[1])
        --self.icon_num:setString(count or 0)
	end)
	--
	registerButtonEventListener(self.btn_cultivate1, function()
		self:playWetOutAnimation(1)
    end,true, 1)

    registerButtonEventListener(self.btn_cultivate10, function()
		self:playWetOutAnimation(110)
    end,true, 1)
    registerButtonEventListener(self.btn_reward, function()
		controll:openRankWindow( true ,2)
    end,true, 1)

    registerButtonEventListener(self.btn_rank, function()
		controll:openRankWindow( true ,1)
    end,true, 1)

    registerButtonEventListener(self.add_btn, function()
    	local config = Config.ItemData.data_get_data(self.item_id)
		BackpackController:getInstance():openTipsSource(true, config)
    end,true, 1)

    registerButtonEventListener(self.btn_rule, function(param,sender, event_type)
		local config = Config.WaterBreedData.data_const
        if config["water_breed_tips"] then
	        TipsManager:getInstance():showCommonTips(config["water_breed_tips"].desc, sender:getTouchBeganPosition(),nil,nil,500)
	    end
    end ,false)

    if self.add_goods_event == nil then
   		self.add_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.ADD_GOODS, function(bag_code,temp_add)
      		local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id) or 0
      		self.item_conut:setString(tostring(count))
			mainui_ctrl:getInstance():setFunctionTipsStatus(MainuiConst.icon.WeekAction, count > 0)
			--print("---------------22----44-------->>",count)
    	end)
    end
    
    if  self.del_goods_event == nil then
    	self.del_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.DELETE_GOODS, function(bag_code,temp_del)
        	local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id) or 0
        	self.item_conut:setString(tostring(count))
        	mainui_ctrl:getInstance():setFunctionTipsStatus(MainuiConst.icon.WeekAction, count > 0)
        	--print("---------------22------------>>",count)
    	end)
    end
    

    if self.modify_goods_event == nil then 
    	self.modify_goods_event = GlobalEvent:getInstance():Bind(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code,temp_list)
    	    local count = BackpackController:getInstance():getModel():getItemNumByBid(self.item_id)
    	    self.item_conut:setString(tostring(count))
    	    mainui_ctrl:getInstance():setFunctionTipsStatus(MainuiConst.icon.WeekAction, count > 0)
    	    --print("---------------22---22--------->>",count)
    	end)
    end
end

function WeeklyGrowthPanel:setVisibleStatus(bool)
	--bool = bool or false
	--self:setVisible(bool)
end

function WeeklyGrowthPanel:DeleteMe()
	if self.resources_load then
		self.resources_load:DeleteMe()
		self.resources_load = nil
	end

    if self.title_load then 
        self.title_load:DeleteMe()
        self.title_load = nil
    end

    if self.animtionNode then 
        self.animtionNode:removeSelf()
        self.animtionNode = nil
    end

	if self.update_week_data ~= nil then
		GlobalEvent:getInstance():UnBind(self.update_week_data)
		self.update_week_data = nil
	end
	if self.update_cultivace ~= nil then
		GlobalEvent:getInstance():UnBind(self.update_cultivace)
		self.update_cultivace = nil
	end
	if self.time_ticket then
        GlobalTimeTicket:getInstance():remove(self.time_ticket)
        self.time_ticket = nil
    end

    if self.add_goods_event then 
    	GlobalEvent:getInstance():UnBind(self.add_goods_event)
        self.add_goods_event = nil
    end

    if self.del_goods_event then 
    	GlobalEvent:getInstance():UnBind(self.del_goods_event)
        self.del_goods_event = nil
    end

    if self.modify_goods_event then 
    	GlobalEvent:getInstance():UnBind(self.modify_goods_event)
        self.modify_goods_event = nil
    end
end 