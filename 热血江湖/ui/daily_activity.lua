-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
-------------------------------------------------------
wnd_daily_Activity = i3k_class("wnd_daily_Activity", ui.wnd_base)
--在线奖励

function wnd_daily_Activity:ctor()
	
	self._canopen = false
	self._index = 0
end
function wnd_daily_Activity:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	
end
function wnd_daily_Activity:refresh(info,Index)
	
	--可以记录已领取的位置
	self._canopen = true

	self:updateOnlineGiftInfo(info,Index)
end

--累计在线
function wnd_daily_Activity:updateOnlineGiftInfo(info,Index)
	
	
	
	self:updateOnlineGiftMainInfo(info)
	self:updateOnlineGiftLevelsInfo(info,Index)
	
end

function wnd_daily_Activity:updateOnlineGiftMainInfo(info)
	
	local content = string.format("%s分钟",info.dayOnlineTime)
	self._layout.vars.ActivitiesTime:setText(content)
	
end

function wnd_daily_Activity:updateOnlineGiftLevelsInfo(info,Index)
	self._canGet = true
	local PayGiftList = self._layout.vars.ExchangeGiftList
	PayGiftList:removeAllChildren()
	local dailyActivity = i3k_db_little_activity
	
	for i, v in ipairs(dailyActivity) do
		
		self:appendOnlineGiftLevelItem( v.rewards,  v.keepTime, info.dayOnlineTime, info.rewards[v.keepTime],i)
	end
	if Index then
		PayGiftList:jumpToListPercent(Index)
	else
		
		if not next(info.rewards) then
			PayGiftList:jumpToChildWithIndex(self._index )--跳到最近未领奖的控件
		else
			PayGiftList:jumpToListPercent(0)
		end
		--i3k_log("----------------reward = ",i3k_table_length(info.rewards),self._index )----
	end
	
end

function wnd_daily_Activity:appendOnlineGiftLevelItem(gifts, keepTime, dayOnlineTime,reward,id)
	
	local PayGiftLevelWidgets = require("ui/widgets/leijizaixiant")()
	
	self:updateOnlineGiftLevelItem(PayGiftLevelWidgets,  gifts, keepTime, dayOnlineTime,reward ,id)
	self._layout.vars.ExchangeGiftList:addItem(PayGiftLevelWidgets)
	
end

function wnd_daily_Activity:updateOnlineGiftLevelItem(item, gifts,keepTime, dayOnlineTime,reward ,id)

	local onlineGiftTb = {
		{root = item.vars.item_bg, icon = item.vars.item_icon, count = item.vars.item_count,suo = item.vars.item_suo,bg = item.vars.count_bg},
		{root = item.vars.item_bg2, icon = item.vars.item_icon2, count = item.vars.item_count2 ,suo = item.vars.item_suo2,bg = item.vars.count_bg2},
		{root = item.vars.item_bg3, icon = item.vars.item_icon3, count = item.vars.item_count3 ,suo = item.vars.item_suo3,bg = item.vars.count_bg3}
	}
	
	for k,v in ipairs(gifts) do
		if v.itemCount > 0 and v.itemid then
			onlineGiftTb[k].root:show()
			onlineGiftTb[k].root:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.itemid) )
			onlineGiftTb[k].icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.itemid,i3k_game_context:IsFemaleRole()))
			if v.itemCount > 1 then
				onlineGiftTb[k].count:setText("x"..v.itemCount)
			else
				onlineGiftTb[k].bg:hide()
				onlineGiftTb[k].count:hide()
			end
			onlineGiftTb[k].icon:onClick(self, self.onTips,v.itemid)
		else
			onlineGiftTb[k].root:hide()
		end
		if v.itemid == 3 or v.itemid == 4 or v.itemid == 31 or v.itemid == 32 or v.itemid == 33 or v.itemid < 0 then
			onlineGiftTb[k].suo:hide()
		else
			onlineGiftTb[k].suo:show()
		end
		
	end
	
	local content = string.format("%s分钟",keepTime)
	--content = g_i3k_make_color_string(content,g_i3k_get_blue_color() )
	item.vars.GoalContent:setText(content)
	
	if  dayOnlineTime >= keepTime then
		if reward then
			item.vars.GetImage:show()
			item.vars.alreadyGet1:show()
			item.vars.alreadyGet2:show()
			item.vars.alreadyGet3:show()
			item.vars.GetBtn:hide()
			--table.insert(self.rewardsTb, {id = id , name = keepTime } )
			--g_i3k_game_context:SetIsExistOnlineGift(self.rewardsTb)
		else
			self._canGet = false
			
			if self._canopen then
			
				self._index = id
				self._canopen = false
			end
			item.vars.Whole:show()
			local TakePayGift = {Time = keepTime ,gifts = gifts,control = self._layout.vars}
			item.vars.GetBtn:onClick(self, self.onTakePayGiftReward, TakePayGift)
			
		end
	else
		--item.vars.Count:setTextColor(g_i3k_get_cond_color(false))
		if self._canopen then
			
			self._index = id
			self._canopen = false
		end
		item.vars.GetBtnText:setText("未达标")
		item.vars.GetBtn:disableWithChildren()
	end
	
end



function wnd_daily_Activity:onTakePayGiftReward(sender,needValue)
	local giftsTb = needValue.gifts
	local percent = needValue.control.ExchangeGiftList:getListPercent()
	local isEnoughTable = { }
	local gift = {}
	local index = 0
	for i,v in pairs(giftsTb) do
		if v.itemid ~= 0 then
			isEnoughTable[v.itemid] = v.itemCount
		end
	end
	local isEnough = g_i3k_game_context:IsBagEnough(isEnoughTable)
	for i,v in pairs (isEnoughTable) do
		index = index + 1
		
		gift[index] = {id = i,count = v}
		
		
	end
	if isEnough then
		i3k_sbean.activities_onlinegift_take(needValue.Time,percent,gift,index)
	else
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
	end
	
end

function wnd_daily_Activity:onTips(sender,itemId)
	
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

--[[function wnd_daily_Activity:closeBtn(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_DailyActivity)
end--]]

function wnd_create(layout)
	local wnd = wnd_daily_Activity.new();
	wnd:create(layout);
	return wnd;
end


