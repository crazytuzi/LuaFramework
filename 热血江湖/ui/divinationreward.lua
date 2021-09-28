module(..., package.seeall)

local require = require;
local ui = require("ui/base");
local WIDGET_ZHANBU2 = "ui/widgets/zhanbu2t"

wnd_DivinationReward = i3k_class("wnd_DivinationReward", ui.wnd_base)

local IMG_NUM = { [0]=6106,[1]=6107,[2]=6108,[3]=6109,[4]=6110,[5]=6111,[6]=6112,[7]=6113,[8]=6114,[9]=6115 } -- 显示日期的数字图片

function wnd_DivinationReward:ctor()
	self.week = {"星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"}
	self._divinationData = {}
end

function wnd_DivinationReward:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseBtn)
	self.yearText = widgets.year
	self.monthText = widgets.month
	self.weekText = widgets.week
	self.dayText = widgets.day
	self.rewardScoll = widgets.reward
	self.des = widgets.des
	self.dayLeft = widgets.dayLeft
	self.dayRight = widgets.dayRight
	self.define = widgets.define
	widgets.cancel:onClick(self, self.onCancelBtn)
	self.define:onClick(self, self.onDefineBtn)
end

function wnd_DivinationReward:refresh(info)
	self._divinationData = i3k_db_DivinationLuckyID[info.fortuneId]
	self:refreshClientTime()
	self:RefreshSroll()
	self:refreshDivinationContent(info)
	self:RefreshRewardBt(info)
end

function wnd_DivinationReward:refreshClientTime()
	local t = os.date("*t", g_i3k_get_GMTtime(i3k_game_get_time()))
	self.yearText:setText(string.format("%s年", t.year))
	self.monthText:setText(string.format("%s月", t.month))
	self.weekText:setText(self.week[t.wday])
	self.dayText:setText(string.format("%s日", t.day))

	local decade = i3k_integer(t.day / 10)
	self.dayLeft:setImage(g_i3k_db.i3k_db_get_icon_path(IMG_NUM[decade]))
	self.dayRight:setImage(g_i3k_db.i3k_db_get_icon_path(IMG_NUM[t.day % 10]))
end

function wnd_DivinationReward:refreshDivinationContent(info)
	if info == nil then return end
	self.des:setText(self._divinationData.LuckyText)

	for i, v in ipairs(self._divinationData.DivinationTextID) do
		if v ~= 0 and v ~= nil then
			local item = self.rewardScoll:getChildAtIndex(i).vars
			local itemInfo = i3k_db_DivinationTextID[v]
			item.typeImg:setImage(g_i3k_db.i3k_db_get_icon_path(6116))
			item.name:setText(itemInfo.TypeContent)
			item.name:setTextColor("ff25693c")
		end
	end

	local lastItem = self.rewardScoll:getChildAtIndex(#self._divinationData.DivinationTextID + 1).vars
	lastItem.typeImg:setImage(g_i3k_db.i3k_db_get_icon_path(6117))
	lastItem.name:setText(self._divinationData.TypeContent)
	lastItem.name:setTextColor("ffbf5222")
end

function wnd_DivinationReward:RefreshRewardBt(info)
	if info.divinationCount == nil or info.hasReward == nil then
		self.define:show()
		return
	end

	if info.divinationCount > info.hasReward then
		self.define:show()
	else
		self.define:hide()
		local weights = self._layout.vars
		weights.flag:hide()
	end
end

function wnd_DivinationReward:RefreshSroll()
	self.rewardScoll:removeAllChildren()
	self.rewardScoll:addChildWithCount(WIDGET_ZHANBU2, 1, #self._divinationData.DivinationTextID + 1)
	self.rewardScoll:stateToNoSlip()
end

function wnd_DivinationReward:onCloseBtn()
	--g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleEntrance, "refreshDivinationRedPoint")
	g_i3k_ui_mgr:CloseUI(eUIID_DivinationReward)
end

function wnd_DivinationReward:onDefineBtn()
	local info = self._divinationData
	local items = {}
	
	for i, v in ipairs(info.DivinationTextID) do
		local id = i3k_db_DivinationTextID[v].RewardID
		
		if items[id] ~= nil then
			items[id] = items[id] + i3k_db_DivinationTextID[v].RewardNum
		else
			items[id] = i3k_db_DivinationTextID[v].RewardNum
		end
	end
	
	local isEnough = g_i3k_game_context:IsBagEnough(items)
	if not isEnough then
		g_i3k_ui_mgr:PopupTipMessage("背包空间不足")
		return

	end

	i3k_sbean.receive_divination_reward()
end

function wnd_DivinationReward:changeDefineBtnGray()
	self.define:hide()
	local weights = self._layout.vars
	weights.flag:hide()
end

function wnd_DivinationReward:onCancelBtn()
	local weights = self._layout.vars
	local value = weights.flag:isVisible()
	
	if value then
		weights.flag:hide()
	else
		weights.flag:show()
	end
	
end

function wnd_DivinationReward:onHide()
	
end

function wnd_create(layout)
	local wnd = wnd_DivinationReward.new();
	wnd:create(layout);
	return wnd;
end
