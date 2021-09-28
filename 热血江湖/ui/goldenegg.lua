-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_goldenEgg = i3k_class("wnd_goldenEgg", ui.wnd_base)

local MODELID = {1308, 1309, 1310}

function wnd_goldenEgg:ctor()
end

function wnd_goldenEgg:configure()
	local widget = self._layout.vars
	widget.close_btn:onClick(self, self.onCloseUI)
	widget.get_all:onClick(self, self.getAllItem)
	widget.refresh:onClick(self, self.refreshItem)
end

function wnd_goldenEgg:refresh()
end

function wnd_goldenEgg:setModels()
	local widget = self._layout.vars
	local cfg = g_i3k_game_context:GetEggModelId()
	if not next(cfg) then
		for i = 1, 6 do
			local id = MODELID[math.random(3)]
			local mcfg = i3k_db_models[id]
			widget["model" .. i]:setSprite(mcfg.path)
			widget["model" .. i]:setSprSize(mcfg.uiscale)
			widget["egg" .. i .. "_btn"]:onClick(self, self.smashEgg, i)
			g_i3k_game_context:SetEggModelId(i, id)
		end
	else
		for i = 1, 6 do
			local mcfg = i3k_db_models[cfg[i]]
			widget["model" .. i]:setSprite(mcfg.path)
			widget["model" .. i]:setSprSize(mcfg.uiscale)
			widget["egg" .. i .. "_btn"]:onClick(self, self.smashEgg, i)
		end
	end
end

--打开界面
function wnd_goldenEgg:firstOpen(info)
	
	if self.co1 then
		g_i3k_coroutine_mgr:StopCoroutine(self.co1)
		self.co1 = nil
	end
	if self.co2 then
		g_i3k_coroutine_mgr:StopCoroutine(self.co2)
		self.co2 = nil
	end
	
	self:setModels()
	self._info = info
	self._useEgg = self._info.log.useEgg                                                                 --保存当前已被砸蛋的编号                                                                                    --当前被砸蛋的编号
	self._leftRefreshTimes = self._info.cfg.refreshCfg.maxRefresh - self._info.log.dayRefreshTimes       --每日剩余的刷新次数
	self._leftSmashTimes = self._info.cfg.selectCfg.maxSelect - self._info.log.dayPlayTimes              --每日剩余砸蛋次数
	self._roundleftSmashTimes = #self._info.cfg.selectCfg.selectPrice - table.nums(self._useEgg)      --每轮剩余砸蛋次数 
	self._timeSeq = math.floor(self._info.log.dayPlayTimes/self._info.cfg.joinRewardSeq)                 --记录连续抽奖次数的奖励次数
	self._layout.vars.reward_btn:onClick(self, self.showAllGifts)
	self:realRoundTimes()                                    
	self:updateInterface()
	
	
	--self:eggsShake(false)
	--self:eggsBreak(false)
	--self:eggsSmashed(false)
	
	if table.nums(self._useEgg)  == 0 then
		--self._layout.anis.c_sx.play()
		--self:suspendEgg()
		self:eggsShake(true)
	else
	    for i = 1, 6 do
		    if self._info.log.useEgg[i] == true then
			    self._layout.vars["model" .. i]:playAction("deathloop")
			    self._layout.vars["egg" .. i .. "_btn"]:disable()
		    else
			    self._layout.vars["model" .. i]:playAction("stand")
			end
		end
	end
end

--显示界面数据
function wnd_goldenEgg:updateInterface()
	self:showItems(self._info.log.curReward)
	self:showRule()
	self:showDayLeftTimes()
	self:showRefreshTimes()
	self:showRefreshCost()
	self:showGetAllItemCost()
	self:setPlayerRecord()
	self:resetEggs()
end

--点击刷新成功后的操作
function wnd_goldenEgg:afterClickRefresh(reward)
	self._roundleftSmashTimes = #self._info.cfg.selectCfg.selectPrice
	self._useEgg = {}
	self:realRoundTimes()
	self:updateleftRefreshTimes()
	self:showRefreshCost()
	self:showRefreshTimes()
	self:showGetAllItemCost()
	g_i3k_game_context:RemoveEggModelId()
	self:setModels()
	self:resetEggs()
	--self:eggsShake(false)
	--self:eggsBreak(false)
	--self:eggsSmashed(false)
	self:showItems(reward)
	--self._layout.anis.c_sx.play()
	--self:suspendEgg()
	self:eggsShake(true)
end

--砸蛋成功后的操作
function wnd_goldenEgg:afterClickSmash(useEgg, gifts, playtimes, num, flag) 
	self:handleEgg(useEgg)
	self:updateleftSmashTimes(playtimes)
	self:showDayLeftTimes()
	self:showGetAllItemCost()
	self:eggRecords(num)
	self:suspendReward(gifts, flag)
end

--点击一键夺宝成功后的操作
function wnd_goldenEgg:afterClickGetAll(gifts, playtimes)
	self:updateleftSmashTimes(playtimes)
	self:showDayLeftTimes()
	self:showRewardItems(gifts)
	g_i3k_game_context:RemoveEggModelId()
	i3k_sbean.activities_goldenEgg()
end

--重置金蛋
function wnd_goldenEgg:resetEggs()
	local widget = self._layout.vars
	for i = 1, 6 do
		widget["egg" .. i .. "_btn"]:enable()
	end
end

--展示初始物品及播放动画期间令金蛋无法点击
--[[function wnd_goldenEgg:suspendEgg()
	self._signal = true
	self.co1 = g_i3k_coroutine_mgr:StartCoroutine(function()
			g_i3k_coroutine_mgr.WaitForSeconds(5) --延时
			self._signal = false
			self:eggsShake(true)
			g_i3k_coroutine_mgr:StopCoroutine(self.co1)
			self.co1 = nil
		end)
end]]

--砸蛋之后暂停小段时间再显示奖励
function wnd_goldenEgg:suspendReward(gifts, flag)
	self._noSmash = true
	self.co2 = g_i3k_coroutine_mgr:StartCoroutine(function()
			g_i3k_coroutine_mgr.WaitForSeconds(1) --延时
			self:showRewardItems(gifts)
			g_i3k_coroutine_mgr.WaitForSeconds(1) 
			self._noSmash = false
			if flag then
				i3k_sbean.activities_goldenEgg()
			end
			g_i3k_coroutine_mgr:StopCoroutine(self.co2)
			self.co2 = nil
		end)
end

--令金蛋无法点击
function wnd_goldenEgg:disableEggs()
	local widget = self._layout.vars
	for i = 1, 6 do
		widget["egg" .. i .. "_btn"]:disable()
	end
end

--控制金蛋的摇晃动画
function wnd_goldenEgg:eggsShake(flag)
	for i = 1, 6 do
		if flag then
		    self._layout.vars["model" .. i]:playAction("stand")
	    end
	end
end

--控制蛋碎的动画
--[[function wnd_goldenEgg:eggsBreak(flag)
	for i = 1, 6 do
		if flag then
			self._layout.vars["model" .. i]:playAction("deathloop")
	    end
	end
end]]

--控制砸蛋的动画
--[[function wnd_goldenEgg:eggsSmashed(flag)
	for i = 1, 6 do
		if flag then
		    self._layout.vars["model" .. i]:playAction("death")
	    end
	end
end]]

--显示初始物品
function wnd_goldenEgg:showItems(goods)
	local widget = self._layout.vars
	for i=1,6 do
		local id = goods[i].item.id
		local count = goods[i].item.count
		local temp_select_bg = "item" .. i .. "_bg"
		local temp_select_content = "item" .. i
		local temp_select_lock = "lock" .. i
		local temp_select_count = "itemCount" .. i
		if id < 0 then
			widget[temp_select_lock]:hide()
		end
		widget[temp_select_content]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
		widget[temp_select_bg]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		widget[temp_select_count]:setText("X" .. count)
	end
end

--点击金蛋
function wnd_goldenEgg:smashEgg(sender, eggNum)
	local times = #self._info.cfg.selectCfg.selectPrice - self._roundleftSmashTimes
	local mySet = {}
	mySet[eggNum] = true
	if self._noSmash then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15595))
	elseif self._signal then
		    g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15593))
	elseif self._leftSmashTimes == 0 then
		    g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15592))
	elseif self._roundleftSmashTimes == 0 then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15589))
	elseif self:showSmashEggCost(times + 1) > g_i3k_game_context:GetCommonItemCanUseCount(self._info.cfg.selectCfg.costId) then
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15590))
	else
		local tbl = {effectiveTime = self._info.effectiveTime, id = self._info.cfg.id, curtimes = times, playtimes = 1, costId = self._info.cfg.selectCfg.costId, cost = self:showSmashEggCost(times + 1), recordEgg = mySet, num = eggNum, leftTimes =  math.min(self._roundleftSmashTimes, self._leftSmashTimes)}
		if g_i3k_game_context:IsExcNeedShowTip(g_GOLDEN_EGG_TYPE) then
			local tipsContent = i3k_get_string(15587, self:showSmashEggCost(times + 1) )
			g_i3k_ui_mgr:OpenUI(eUIID_Today_Tip)
			g_i3k_ui_mgr:RefreshUI(eUIID_Today_Tip, g_GOLDEN_EGG_TYPE, tbl)
			g_i3k_ui_mgr:InvokeUIFunction(eUIID_Today_Tip, "setTipsContent", tipsContent)
		else 
			i3k_sbean.activities_goldenEgg_smash(tbl.effectiveTime, tbl.id, tbl.curtimes, tbl.playtimes, tbl.costId, tbl.cost, tbl.recordEgg, tbl.num, tbl.leftTimes)
		end
	end		
end

--点击一键夺宝
function wnd_goldenEgg:getAllItem(sender)
	local times = #self._info.cfg.selectCfg.selectPrice - self._roundleftSmashTimes
	local mySet = {}
	local k = 0	
    for i = 1, 6 do
		 if k < math.min(self._roundleftSmashTimes, self._leftSmashTimes) then	
		   if self._useEgg[i] ~= true then
		       mySet[i] = true
			   k = k + 1
			end
		end
	end
	if self._signal then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15593))
	elseif self._leftSmashTimes == 0 then
		    g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15592))
	elseif self._roundleftSmashTimes == 0 then
	        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15589))
	elseif self._totalPrice > g_i3k_game_context:GetCommonItemCanUseCount(self._info.cfg.selectCfg.costId) then
	        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15590))
    else
	    local tbl = {effectiveTime = self._info.effectiveTime, id = self._info.cfg.id, curtimes = times, playtimes = math.min(self._roundleftSmashTimes, self._leftSmashTimes), costId = self._info.cfg.selectCfg.costId, cost = self._totalPrice, recordEgg = mySet, num = 0, leftTimes =  math.min(self._roundleftSmashTimes, self._leftSmashTimes)}
	    if g_i3k_game_context:IsExcNeedShowTip(g_GOLDEN_EGG_TYPE) then
		    local tipsContent = i3k_get_string(15587, self._totalPrice )
		    g_i3k_ui_mgr:OpenUI(eUIID_Today_Tip)
		    g_i3k_ui_mgr:RefreshUI(eUIID_Today_Tip, g_GOLDEN_EGG_TYPE, tbl)
		    g_i3k_ui_mgr:InvokeUIFunction(eUIID_Today_Tip, "setTipsContent", tipsContent)
		else 
		    i3k_sbean.activities_goldenEgg_smash(tbl.effectiveTime, tbl.id, tbl.curtimes, tbl.playtimes, tbl.costId, tbl.cost, tbl.recordEgg, tbl.num,  tbl.leftTimes)
		end
	end		
end

--点击刷新
function wnd_goldenEgg:refreshItem(sender)
	if self._leftSmashTimes == 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15592))
	elseif self._signal then
		    g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15593))
	elseif self._leftRefreshTimes == 0 then
		    g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15591))
	elseif self._refreshPrice > g_i3k_game_context:GetCommonItemCanUseCount(-g_BASE_ITEM_DIAMOND) then
	        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15590))
	else   
	    local times = self._info.cfg.refreshCfg.maxRefresh - self._leftRefreshTimes
		local tbl = {effectiveTime = self._info.effectiveTime, id = self._info.cfg.id, curtimes = times, cost = self._refreshPrice}	
	    if g_i3k_game_context:IsExcNeedShowTip(g_REFRESH_GOLDEN_EGG_TYPE) then
		    local tipsContent = i3k_get_string(15588)
		    g_i3k_ui_mgr:OpenUI(eUIID_Today_Tip)
		    g_i3k_ui_mgr:RefreshUI(eUIID_Today_Tip, g_REFRESH_GOLDEN_EGG_TYPE, tbl)
		    g_i3k_ui_mgr:InvokeUIFunction(eUIID_Today_Tip, "setTipsContent", tipsContent)
		else 
		    i3k_sbean.activities_goldenEgg_refresh(tbl.effectiveTime, tbl.id, tbl.curtimes, tbl.cost)
	    end		
	end
end

--显示获得稀有物品玩家
function wnd_goldenEgg:setPlayerRecord()
	local scroll = self._layout.vars.recordScroll
	scroll:removeAllChildren()
	for i,v in ipairs(self._info.records) do
		local widget = require("ui/widgets/jindant")()   
		local itemColor = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(v.id))
		local name = g_i3k_db.i3k_db_get_common_item_name(v.id)
		local str = g_i3k_make_color_string(name, itemColor)
		widget.vars.dsc:setText(i3k_get_string(16131, v.name, str))
		scroll:addItem(widget) 
	end
	scroll:jumpToChildWithIndex(#self._info.records)	
end

--显示得到物品
function wnd_goldenEgg:showRewardItems(gets)
	local gifts = {}		--vector
	local tmpReward = {}	--map
	local times = math.floor((self._info.cfg.selectCfg.maxSelect - self._leftSmashTimes)/self._info.cfg.joinRewardSeq)
	

	if (times - self._timeSeq) > 0 then
		for i = 1, (times - self._timeSeq) do
			local item = self._info.cfg.joinReward
			tmpReward[item.id] = (tmpReward[item.id] or 0) + item.count
		end
	end
	
	self._timeSeq = times
	
	for i, v in ipairs(gets) do
		local eggReward = self._info.log.curReward[v + 1]
		if eggReward then
			local item = eggReward.item
			tmpReward[item.id] = (tmpReward[item.id] or 0) + item.count
			item = self._info.cfg.giftItem
			tmpReward[item.id] = (tmpReward[item.id] or 0) + item.count
		end	
	end

	for k, v in pairs(tmpReward) do
		table.insert(gifts, {id = k, count = v})
	end

	g_i3k_ui_mgr:ShowGainItemInfo(gifts)
end


--显示规则
function wnd_goldenEgg:showRule()
	local widget = self._layout.vars
	widget.rule:setText(self._info.cfg.content)
end

--显示本次刷新所需费用
function wnd_goldenEgg:showRefreshCost()
	local widget = self._layout.vars
	local times = (self._info.cfg.refreshCfg.maxRefresh - self._leftRefreshTimes) + 1
	local price = self._info.cfg.refreshCfg.refreshPrice
	if times <= #price then
		widget.refresh_cost:setText(price[times])
		self._refreshPrice = price[times]            --记录刷新费用
	else
	    widget.refresh_cost:setText(price[#price])
		self._refreshPrice = price[#price]           --记录刷新费用
	end
	widget.refresh_cost:setTextColor(g_i3k_get_cond_color(self._refreshPrice <= g_i3k_game_context:GetCommonItemCanUseCount(-g_BASE_ITEM_DIAMOND)))
end

--显示今日剩余刷新次数
function wnd_goldenEgg:showRefreshTimes()
	local widget = self._layout.vars
	widget.refresh_count:setText(self._leftRefreshTimes)
	if self._leftRefreshTimes == 0 then
		widget.refresh_count:setTextColor(g_i3k_get_red_color())
	end
end

--显示今日剩余夺宝次数
function wnd_goldenEgg:showDayLeftTimes()
	local widget = self._layout.vars
	widget.dayLeftTimes:setText(i3k_get_string(15594, self._leftSmashTimes))
	if self._leftSmashTimes == 0 then
		widget.dayLeftTimes:setTextColor(g_i3k_get_red_color())
	end
end

--显示一键夺宝所需费用
function wnd_goldenEgg:showGetAllItemCost()
	local widget = self._layout.vars 
	if self._roundleftSmashTimes > 0 and self._leftSmashTimes > 0 then 
		local index = #self._info.cfg.selectCfg.selectPrice - self._roundleftSmashTimes
	    local totalPrice = 0
	    for i = index + 1, self._realRoundTimes do
		      totalPrice = totalPrice + self._info.cfg.selectCfg.selectPrice[i]
	    end
	    widget.getAll_cost:setTextColor(g_i3k_get_cond_color(totalPrice <= g_i3k_game_context:GetCommonItemCanUseCount(-g_BASE_ITEM_DIAMOND)))
	    self._totalPrice = totalPrice     --记录一键夺宝的费用
	else self._totalPrice = 0 
	end 
	widget.getAll_cost:setText(self._totalPrice)
	widget.cost_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(self._info.cfg.selectCfg.costId, g_i3k_game_context:IsFemaleRole()))
	widget.cost_icon:onClick(self, self.itemInfo, self._info.cfg.selectCfg.costId)
	widget.cost_bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(self._info.cfg.selectCfg.costId))
	widget.lock:setVisible(self._info.cfg.selectCfg.costId > 0)
end

--计算本次砸蛋所需费用
function wnd_goldenEgg:showSmashEggCost(count)
	local price = self._info.cfg.selectCfg.selectPrice[count]
	return price
end

--更新剩余每轮及每日砸蛋次数
function wnd_goldenEgg:updateleftSmashTimes(times)
	self._leftSmashTimes =self._leftSmashTimes - times
	self._roundleftSmashTimes = self._roundleftSmashTimes - times
end

--更新剩余刷新次数
function wnd_goldenEgg:updateleftRefreshTimes()
	self._leftRefreshTimes = self._leftRefreshTimes - 1
end

--对当前被砸蛋进行操作
function wnd_goldenEgg:handleEgg(useEgg)
	for i, v in pairs(useEgg) do
		self._layout.vars["model" .. i]:pushActionList("death", 1);
		self._layout.vars["model" .. i]:pushActionList("deathloop", -1);
		--self._layout.vars["model" .. i]:playAction("death")
		--self._layout.vars["model" .. i]:playAction("deathloop")
	    self._layout.vars["egg" .. i .. "_btn"]:disable()
		self._layout.vars["model" .. i]:playActionList()
	end
end

--记录当前被砸蛋的编号
function wnd_goldenEgg:eggRecords(num)
	self._useEgg[num] = true
end

--记录实际每轮能砸蛋的次数
function wnd_goldenEgg:realRoundTimes()
	self._realRoundTimes = math.min(self._roundleftSmashTimes, self._leftSmashTimes) + table.nums(self._useEgg)
end

--清理协程
function wnd_goldenEgg:onHide()
	if self.co1 then
		g_i3k_coroutine_mgr:StopCoroutine(self.co1)
		self.co1 = nil
	end
	if self.co2 then
		g_i3k_coroutine_mgr:StopCoroutine(self.co2)
		self.co2 = nil
	end
end

function wnd_goldenEgg:itemInfo(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end


function wnd_goldenEgg:showAllGifts(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_GoldenEggGifts)
	g_i3k_ui_mgr:RefreshUI(eUIID_GoldenEggGifts, self._info.cfg.infos)
end

function wnd_create(layout)
	local wnd =wnd_goldenEgg.new()
	wnd:create(layout)
	return wnd
end
