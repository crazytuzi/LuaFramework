local ActivityLingqu = class("ActivityLingqu",UFCCSNormalLayer)
local LingquCell = require("app.scenes.activity.gm.ActivityLingquCell")
local DuihuanCell = require("app.scenes.activity.gm.ActivityDuihuanCell")

function ActivityLingqu.create(act_id)
    return ActivityLingqu.new("ui_layout/activity_ActivityLingqu.json",act_id)

end

function ActivityLingqu:ctor(_,act_id)
	self._activity = G_Me.activityData.custom:getActivityByActId(act_id)
	self._act_id = act_id
	
	self.super.ctor(self)
	self:_init()
	self:_initEvent()
	self._listData = {}
	self._listview = nil
	
	--萌妹纸可动态替换成需要展示的武将
	local mmImageView = self:getImageViewByName("ImageView_mm")
	
	mmImageView:setVisible(false)

	local knight = nil

	if self._activity and self._activity.role_icon and self._activity.role_icon > 0 then
		knight = knight_info.get(self._activity.role_icon)
	end
    
    if knight then

    	local size0 = mmImageView:getContentSize()
		local height0 = size0.height

        local heroPanel = self:getPanelByName("Panel_mm")
        local KnightPic = require("app.scenes.common.KnightPic")
        local heroImg = KnightPic.createKnightPic( knight.res_id, heroPanel, "roleInfo",true )
        
        local size1 = heroImg:getContentSize()
		local height1 = size1.height
		local posx,posy = heroImg:getPosition()
		--基本能保证头部不会被挡住
		heroImg:setPositionXY(posx+heroPanel:getContentSize().width/2+75,posy+25)

		if height1 > height0 then
			heroPanel:setScale(height0/height1)
		end
	    else
			mmImageView:setVisible(true)
	    end
	end

function ActivityLingqu:_init() 
	self:getLabelByName("Label_title"):setText(" ")
	self:getLabelByName("Label_desc"):setText(" ")
	self:getLabelByName("Label_endtime"):setText(" ")
	self:getLabelByName("Label_awardtime"):setText(" ")
end

function ActivityLingqu:_initEvent()
	self:registerBtnClickEvent("Button_help",function()
		require("app.scenes.activity.gm.ActivityDuihuanHelp").show()
		end)
end

function ActivityLingqu:_setWidgets()
	if not self._activity then
		self:_init() 
		return
	end

	self:getLabelByName("Label_endtimeTag"):setText(G_lang:get("LANG_ACTIVITY_END_TIME_TAG"))
	self:getLabelByName("Label_title"):setText(self._activity.title)
	self:getLabelByName("Label_desc"):setText(self._activity.desc)
	local timeString = G_ServerTime:getActivityTimeFormat(self._activity["start_time"],self._activity["end_time"])
	self:getLabelByName("Label_endtime"):setText(timeString)
	local award_time = rawget(self._activity,"award_time") or 0

	--兑换类默认不显示领奖截止时间
	if self._activity.act_type == 3 then  
		self:showWidgetByName("Button_help",true)
		self:showWidgetByName("Label_awardtime",false)
		self:showWidgetByName("Label_awardtimeTag",false)
	else
		self:showWidgetByName("Button_help",false)	
		self:showWidgetByName("Label_awardtime",true)
		self:showWidgetByName("Label_awardtimeTag",true)
		local date = G_ServerTime:getDateObject(award_time)
		--[[
			["LANG_ACTIVITY_AWARD_TIME"]                 = "#month#-#day# #hour#:#min#",
		]]
		local awardTimeString = G_lang:get("LANG_ACTIVITY_AWARD_TIME_WITH_HOUR",{year=date.year,month=date.month,day=date.day,hour=date.hour})
		self:getLabelByName("Label_awardtime"):setText(awardTimeString)
	end

	self:_refreshTimeCountDown()

end

function ActivityLingqu:_createStrokes()
	self:getLabelByName("Label_title"):createStroke(Colors.strokeBrown,2)
	self:getLabelByName("Label_endtimeTag"):createStroke(Colors.strokeBrown,2)
	self:getLabelByName("Label_endtime"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_awardtime"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_awardtimeTag"):createStroke(Colors.strokeBrown,2)
end

--kaka FIXME
function ActivityLingqu:_getLeftTimeString( day, hour, min, sec )
	
	local timeLeft = ""
	if day > 0 then
		timeLeft = timeLeft .. day .. "天" .. hour .. "小时" .. min .. "分" .. sec .. "秒"
	elseif hour > 0 then
		timeLeft = timeLeft .. hour .. "小时" .. min .. "分" .. sec .. "秒"
	elseif min > 0 then
		timeLeft = timeLeft .. min .. "分" .. sec .. "秒"
	elseif sec > 0 then
		timeLeft = timeLeft .. sec .. "秒"
	else
		timeLeft = "已结束"
	end

	return timeLeft
end

--倒计时刷新时间lable
function ActivityLingqu:_refreshTimeCountDown( )


--[[  把这个地方注释放开即可

	if not self._activity then
		self:_init() 
		return
	end

	--活动截止时间
    local endTime = rawget(self._activity,"end_time") or 0
    local awardEndTime = rawget(self._activity,"award_time") or 0

 	--local endTimeString = G_ServerTime:getLeftSecondsString(endTime)
    --local awardTimeString = G_ServerTime:getLeftSecondsString(awardEndTime)
    --self:getLabelByName("Label_endtime"):setText(endTimeString)
    
	local endDay, endHour, endMin, endSec = G_ServerTime:getLeftTimeParts(endTime)	

	--少于一天了显示倒计时
    if endDay < 1 then
		self:getLabelByName("Label_endtime"):setText(self:_getLeftTimeString(endDay, endHour, endMin, endSec))
		--self:enableLabelStroke("Label_endtime", Colors.strokeOrange, 2)
		self:getLabelByName("Label_endtime"):setColor(Colors.strokeOrange)	
	end

	--兑换类默认不显示领奖截止时间
	if self._activity.act_type ~= 3 then  
		local awardEndDay, awardEndHour, awardEndMin, awardEndSec = G_ServerTime:getLeftTimeParts(awardEndTime)	
		--self:getLabelByName("Label_awardtime"):setText(awardTimeString)
		if awardEndDay < 1 then
			self:getLabelByName("Label_awardtime"):setText(self:_getLeftTimeString(awardEndDay, awardEndHour, awardEndMin, awardEndSec))
			--self:enableLabelStroke("Label_awardtime", Colors.strokeOrange, 2)	
			self:getLabelByName("Label_awardtime"):setColor(Colors.strokeOrange)	
		end
	end
--]]

end

function ActivityLingqu:onLayerEnter()
	-- print("--ActivityLingqu:onLayerEnter--" .. self._act_id)
	self:adapterWidgetHeight("Panel_listviewBg", "Panel_top", "", 40, 0)
	self:adapterWidgetHeight("Panel_listview", "Panel_top", "", 60, 0)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CUSTOM_ACTIVITY_GET_AWARD, self._getAward, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CUSTOM_ACTIVITY_UPDATE_QUEST, self._refreshActQuest, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CUSTOM_ACTIVITY_UPDATE, self._refreshAct, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_RECHARGE_SUCCESS, self._rechargeSuccess, self) 

	--可能要倒计时
	self._timeHandle = G_GlobalFunc.addTimer(1, function()
		if self and self._refreshTimeCountDown then
			self:_refreshTimeCountDown()
		end
	end)
	--self._refreshTimeCountDown()

	self:_setWidgets()
	self:_createStrokes()
	self._listData = G_Me.activityData.custom:getQuestByActId(self._act_id) or {}
	if self._listview then
		self._listview:removeFromParentAndCleanup(true)
		self._listview = nil
	end 
	if self._listview == nil then
		if not self._activity then
			return
		end
		self._listData = G_Me.activityData.custom:getQuestByActId(self._act_id) or {}
		local panel = self:getPanelByName("Panel_listview")
		self._listview = CCSListViewEx:createWithPanel(panel,LISTVIEW_DIR_VERTICAL)
		self._listview:setCreateCellHandler(function(list,index)
			local item = nil
			if self._activity.act_type == 3 then  --兑换类的活动
				item = DuihuanCell.new()
			else
		    	item = LingquCell.new()        
			end
		    return item
		end)
		self._listview:setUpdateCellHandler(function(list,index,cell)
			local quest = self._listData[index+1]
			cell:updateItem(quest)
		end)

		self._listData = G_Me.activityData.custom:getQuestByActId(self._act_id) or {}
		self._listview:setSpaceBorder(10,40)
		self._listview:reloadWithLength(#self._listData,0,0.2)
	end

end

function ActivityLingqu:_getAward(data)
	if data.ret == 1 and data.act_id == self._activity.act_id then
		uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
		local award_id = nil
		if rawget(data,"award_id") then
			award_id = data.award_id
		end 
		local num = nil
		if rawget(data,"num") then
			num = data.num
		end
		local award = G_Me.activityData.custom:getAwardById(data.act_id,data.quest_id,award_id,num)
		if award == {} then
			G_MovingTip:showMovingTip(G_lang:get("LANG_WUSH_BOXEND"))
		else
			local _layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(award)
			uf_notifyLayer:getModelNode():addChild(_layer)
		end
	end
end

--刷新
function ActivityLingqu:_refreshAct()
	if self._listview then
		local len = #self._listData
		--重新取一下数据
		self._listData = G_Me.activityData.custom:getQuestByActId(self._act_id) or {}

		--活动有可能刷新了
		self._activity = G_Me.activityData.custom:getActivityByActId(self._act_id)

		self:_setWidgets()
		if len == #self._listData then
			self._listview:refreshAllCell()
		else
			self._listview:reloadWithLength(#self._listData,self._listview:getShowStart())
		end
	end
end

--刷新任务

function ActivityLingqu:_refreshActQuest()
	if self._listview then
		self._listview:refreshAllCell()
	end
end

--充值成功刷新红点
function  ActivityLingqu:_rechargeSuccess()
	uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_ACTIVITY_UPDATED, nil, false)
end

function ActivityLingqu:onLayerExit()
	uf_eventManager:removeListenerWithTarget(self)

	if self._timeHandle ~= nil then
		G_GlobalFunc.removeTimer(self._timeHandle)
	end

end

function ActivityLingqu:adapterLayer()
	-- self:adapterWidgetHeight("Panel_listviewBg", "Panel_top", "", 0, 0)
	-- self:adapterWidgetHeight("Panel_listview", "", "", 30, 320)
	-- self:_setListView()
end

function ActivityLingqu:updatePage(activity)
	if not activity then
		return
	end
	self._activity = activity.data
	self._act_id = activity.data.act_id
	self:_setWidgets()
end

return ActivityLingqu