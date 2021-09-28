local ActivityDuihuanCell = class("ActivityDuihuanCell",function()
	return CCSItemCellBase:create("ui_layout/activity_ActivityDuihuanCell.json")
	end)

local ActivityDailyCellItem = require("app.scenes.activity.ActivityDailyCellItem")
local ActivityLimit  = require("app.scenes.activity.gm.ActivityLimit")
function ActivityDuihuanCell:ctor(...)
	self._space = 10
	self._callback = nil

	self:_initEvent()
	
	--消耗列表
	self._consumeList = {}

	self._scrollView = self:getScrollViewByName("ScrollView_duihuan")
	self._leftTimeTagLabel = self:getLabelByName("Label_leftTimeTag")
	self._leftTimeLabel = self:getLabelByName("Label_leftTime")
	--剩余次数
	self._leftTimeLabel:setText("")
	self._quanfuLeftTime = self:getLabelByName("Label_quanfuleftTime")
	--全服剩余次数
	self._quanfuLeftTime:setText("")
	--全服剩余和普通剩余panel先隐掉
	self:showWidgetByName("Panel_quanfuduihuan",false)
	self:showWidgetByName("Panel_duihuancishu",false)

	--不用每次都创建
	if self.denghao == nil then
		self.denghao = ImageView:create()
		self.denghao:loadTexture("ui/activity/duihuan_denghao.png")
		self.denghao:setPositionY(self:_getScrollViewHeight()/2)
		self.denghao:retain()
	end

	self:attachImageTextForBtn("Button_duihuan","Image_25")
end

function ActivityDuihuanCell:updateItem(quest)
	self._quest = quest
	self._curQuest = nil
	self._consumeList = {}
	if not quest then
		self._leftTimeLabel:setText("")
		self:showWidgetByName("Image_zhekou",false)
		return
	end
	self._curQuest = G_Me.activityData.custom:getCurQuestByQuest(self._quest)
	if not self._curQuest then
		self._leftTimeLabel:setText("")
		return
	end
	local value02 = 0
	local value01 = 0
	--判断是全服剩余还是普通的
	if self._quest.server_limit > 0 then   --全服限制
		self:showWidgetByName("Panel_quanfuduihuan",true)
		self:showWidgetByName("Panel_duihuancishu",false)
		value02 = self._quest.server_limit or 0   --限制次数
		value01 = self._quest.server_times or 0   --当前进度
		local leftTime = string.format("%s/%s",(value02-value01),value02)
		self._quanfuLeftTime:setText(leftTime)

		--判断兑换次数
		if value01 >= value02 then
			self:getButtonByName("Button_duihuan"):setTouchEnabled(false)
		else
			if self._curQuest.award_times >= self._quest.award_limit then
				self:getButtonByName("Button_duihuan"):setTouchEnabled(false)
			else
				self:getButtonByName("Button_duihuan"):setTouchEnabled(true)
			end
		end
	else
		self:showWidgetByName("Panel_quanfuduihuan",false)
		self:showWidgetByName("Panel_duihuancishu",true)
		value02 = self._quest.award_limit or 0   --限制次数
		value01 = self._curQuest.award_times or 0   --当前进度
		local leftimes = value02 > value01 and (value02-value01) or 0
		local leftTime = string.format("%s/%s",leftimes,value02)
		self._leftTimeLabel:setText(leftTime)
		--判断兑换次数
		if value01 >= value02 then
			self:getButtonByName("Button_duihuan"):setTouchEnabled(false)
		else
			self:getButtonByName("Button_duihuan"):setTouchEnabled(true)
		end
	end
	--刷新是否有折扣
	local isZhekou,zhekou = G_Me.activityData.custom:isZhekou(quest)
	self:showWidgetByName("Image_zhekou",isZhekou)
	if isZhekou then
		self:getImageViewByName("Image_zhekou"):loadTexture(string.format("ui/text/txt/xsyh_zhekou_%d.png",zhekou))
	end

	self:_initScrollView(quest)
end

function ActivityDuihuanCell:_getScrollViewHeight()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().height
end

function ActivityDuihuanCell:_getScrollViewWidth()
    if not self._scrollView then
        return 0
    end
    return self._scrollView:getContentSize().width
end

function ActivityDuihuanCell:_initScrollView(quest)
	if self._scrollView then
		self._scrollView:removeAllChildrenWithCleanup(true)
	end
	if not quest then
		return
	end
	self._consumeList = {}
	local awardList = {}
	local widgetWidth = 0
	for i=1,4 do
		local _type = quest["consume_type" .. i]
		if _type > 0 then
			local value = quest["consume_value" .. i]
			local size = quest["consume_size" .. i]
			local good = G_Goods.convert(_type,value,size)
			if good then
				table.insert(self._consumeList,good)
				local widget = ActivityDailyCellItem.new(good)
				--如果未拥有置灰
				widget:setGray()
				widgetWidth = widget:getContentSize().width
				local height = widget:getContentSize().height
				widget:setPosition(ccp(self._space*i + (i-1)*widgetWidth,(self:_getScrollViewHeight()-height)/2))
				self._scrollView:addChild(widget)
			end
		end
	end
	
	--添加一个等号
	--等号的x坐标
	local width = self._space*(#self._consumeList+1) + #self._consumeList*widgetWidth
	self._scrollView:addChild(self.denghao,10)
	self.denghao:setPositionX(width)
	for i=1,4 do
		local _type = quest["award_type" .. i]
		if _type > 0 then
			local value = quest["award_value" .. i]
			local size = quest["award_size" .. i]
			local good = G_Goods.convert(_type,value,size)
			if good then
				table.insert(awardList,good)
				local widget = ActivityDailyCellItem.new(good)
				widgetWidth = widget:getContentSize().width
				local height = widget:getContentSize().height
				widget:setPosition(ccp(width + self._space*i + (i-1)*widgetWidth,(self:_getScrollViewHeight()-height)/2))
				self._scrollView:addChild(widget)
			end
		end
	end
	width = width + self._space*(#awardList+1) + #awardList*widgetWidth
	print("width = " .. width)
	--总长度
	local innerWidth = width > self:_getScrollViewWidth() and width or self:_getScrollViewWidth()
	self._scrollView:setInnerContainerSize(CCSizeMake(innerWidth,self:_getScrollViewHeight()))
end


function ActivityDuihuanCell:_initEvent()
	self:registerBtnClickEvent("Button_duihuan",function()
		if not self._quest or (not self._curQuest) then
			return
		end

		if not ActivityLimit.checkByQuest(self._quest) then
			return
		end
		--判断活动是否处于预览期
		if G_Me.activityData.custom:checkPreviewByActId(self._quest.act_id) then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_IS_IN_PREVIEW",{time=G_Me.activityData.custom:getStartDateByActId(self._quest.act_id)}))
			return
		end

		--判断是否过期
		if not G_Me.activityData.custom:checkActActivate(self._quest.act_id) then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_IS_TIME_OUT_TIPS"))
			return
		end

		--判断兑换次数
		local value02 = 0   --限制次数
		local value01 = 0   --当前进度

		--判断是全服剩余还是普通的
		if self._quest.server_limit > 0 then   --全服限制
			value02 = self._quest.server_limit or 0   --限制次数
			value01 = self._quest.server_times or 0   --当前进度
		else
			value02 = self._quest.award_limit or 0   --限制次数
			value01 = self._curQuest.award_times or 0   --当前进度
		end
		if value01 >= value02 then
			--刷新条件未写好,正常是置灰的
			if self._quest.server_limit > 0 then --全服剩余次数不足需要加个提示
				G_MovingTip:showMovingTip("LANG_ACTIVITY_CAME_LATER")
			end
			return
		end
		--条件未达成
		-- if not self:_checkCondition() then
		if not G_Me.activityData.custom:checkExchangeCondition(self._quest) then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_DUIHUAN_CONDITION_NOT_ENOUGH"))
			return 
		end

		--判断领奖时间是否到了
		local act = G_Me.activityData.custom:getActivityByActId(self._quest.act_id)
		if not act then
			return
		end

		if G_ServerTime:getTime() > act.award_time then
			G_MovingTip:showMovingTip(G_lang:get("LANG_ACTIVITY_AWARD_TIME_OUT"))
			return
		end

		--判断是否是多选
		if self._quest.award_select > 0 then
			require("app.scenes.sanguozhi.SanguozhiSelectAwardLayer").showForCustomActivity(self._quest, function(index)
					G_HandlersManager.gmActivityHandler:sendGetCustomActivityAward(self._quest.act_id,self._quest.quest_id,(index-1)) 
				end)
			return
		end
		if self._quest.server_limit > 0 then
			--全服剩余时，不发送次数
			G_HandlersManager.gmActivityHandler:sendGetCustomActivityAward(self._quest.act_id,self._quest.quest_id) 
		else
			local consumeNum = G_Me.activityData.custom:getConsumeTypeNum(self._quest)
			--兑换物为1时才显示
			if consumeNum == 1 then
				require("app.scenes.activity.gm.ActivityDuihuanDialog").show(self._quest,function(buyNum)
					G_HandlersManager.gmActivityHandler:sendGetCustomActivityAward(self._quest.act_id,self._quest.quest_id,nil,buyNum) 
					end)
			else
				G_HandlersManager.gmActivityHandler:sendGetCustomActivityAward(self._quest.act_id,self._quest.quest_id) 
			end
		end
		end)
end


return ActivityDuihuanCell