-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_callBack = i3k_class("wnd_callBack", ui.wnd_base)

function wnd_callBack:ctor()
	self.roleType = nil
end

function wnd_callBack:configure()
	self.ui = self._layout.vars
    self.ui.close:onClick(self,self.onClose)
	self.btn = {
		{['tab'] = self.ui.tab1, ['content'] = self.ui.content1, ['red'] = self.ui.red1, ['text'] = self.ui.text1},
		{['tab'] = self.ui.tab2, ['content'] = self.ui.content2, ['red'] = self.ui.red2, ['text'] = self.ui.text2},
		{['tab'] = self.ui.tab3, ['content'] = self.ui.content3, ['red'] = self.ui.red3, ['text'] = self.ui.text3},
	}
	
	self.ui.scroll1:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	
	self.ui.tab1:onClick(self,function ()
		i3k_sbean.request_role_back_sync_req(true)
	end)
	self.ui.tab2:onClick(self,function ()
		i3k_sbean.request_role_back_world_num_sync_req(true)
	end)
	self.ui.tab3:onClick(self, function ()
		i3k_sbean.request_role_back_pay_sync_req()
	end)
	
	self.ui.help:onClick(self,function ()
		g_i3k_ui_mgr:ShowHelp(
			i3k_get_string(
				16892
			)
		)
	end)
	
	g_i3k_game_context.isNeedShowCallback = false
	
	
	local config = i3k_db_call_back_common.config
	local startTick = config.startDay + config.startTime
	local endTick = config.endDay + config.endTime
	local showTime = function (time)
		local t = os.date("*t",time)
		return string.format("%.2d月%.2d日%.2d:%.2d", t.month, t.day, t.hour, t.min)
	end
	self.ui.activeTime:setText("活动时间:" .. showTime(startTick) .. "-" .. showTime(endTick))
	
	self.ui.shareBtn:onClick(self,function ()
		if i3k_game_get_os_type() == eOS_TYPE_IOS then
			g_i3k_game_handler:ShareTaskID(i3k_db_common.shareIosSdkId)
		elseif i3k_game_get_os_type() == eOS_TYPE_OTHER then
			g_i3k_game_handler:ShareTaskID(i3k_db_common.shareAndroidSdkId)
		end
	end)
	
	if i3k_is_longtu_channel() then
		self.ui.shareGroup:setVisible(true)
	end
end

local function getCfgData(cfg,roleType,day,level)
	local config = nil
	for k,v in ipairs(cfg) do
		if v.type == roleType and day == v.days and level >= v.level then
			config = v
		end
	end
	return config
end

local function getLastCfgData(cfg,roleType,level)
	local config = nil
	for k,v in ipairs(cfg) do
		if v.type == roleType and level >= v.level then
			config = v
		end
	end
	return config
end

local function setItemUI(cfg,item,roleType,day,level,curValue,isShowNextDay,taskIndex,isGeted)
	local config = nil
	local haveNextConfig = false
	
	if isShowNextDay then
		local nextConfig = getCfgData(cfg,roleType,day+1,level)
		if nextConfig then
			config = nextConfig
			haveNextConfig = true
		end
	else
		config = getCfgData(cfg,roleType,day,level)
	end
	
	local isFinish = false
	if not config then
		--任务已经结束
		isFinish = true
		
		config = getLastCfgData(cfg, roleType, level)
		item.vars.btn:disableWithChildren()
		
	end
	local award = {}
	local checkAward = {}
	for i=1,3,1 do
		local id = config["awardId" .. i]
		if id and id ~= 0 then
			item.vars["propBg" .. i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			item.vars["prop" .. i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
			item.vars["propBtn"..i]:onClick(self,function ()
				g_i3k_ui_mgr:ShowCommonItemInfo(id)
			end)
			item.vars["propNum" .. i]:setText("X" .. config["awardNum" .. i])
			if id < 0 then
				item.vars["lock" .. i]:setVisible(false)
			end
			table.insert(award,{id=id,count=config["awardNum" .. i]})
			checkAward[id] = config["awardNum" .. i]
		else
			item.vars["award" .. i]:setVisible(false)
		end
	end

	if taskIndex == 1 then
		item.vars.btn:onClick(self,function ()
			if g_i3k_game_context:IsBagEnough(checkAward) then
				i3k_sbean.request_role_back_day_gift_take_req(function ()
					g_i3k_ui_mgr:ShowGainItemInfo(award)
				end)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16871))
			end
		end)
		
	elseif taskIndex == 2 then
		item.vars.btn:onClick(self,function ()
			if g_i3k_game_context:IsBagEnough(checkAward) then
			i3k_sbean.request_role_back_schdule_gift_take_req(function ()
				g_i3k_ui_mgr:ShowGainItemInfo(award)	
			end)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16871))
			end
		end)
	else
		item.vars.btn:onClick(self,function ()
			if g_i3k_game_context:IsBagEnough(checkAward) then
				i3k_sbean.request_role_back_pay_gift_take_req(function ()
					g_i3k_ui_mgr:ShowGainItemInfo(award)	
				end)
			else
				g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16871))
			end
		end)
	end
	
	if curValue then
		local percent = curValue / (config.pay or config.active) * 100
		percent = percent > 100 and 100 or percent
		item.vars.process:setPercent(percent)
		if percent < 100 or isShowNextDay then
			item.vars.btn:disableWithChildren()
		end
	end
	
	if isFinish then
		item.vars.desa:setText(i3k_get_string(16845))
		item.vars.finish:setVisible(true)
		item.vars.process:setPercent(0)
	else
		if taskIndex == 1 then
			if roleType == 1 then
				item.vars.desa:setText(i3k_get_string(16842))
			else
				item.vars.desa:setText(i3k_get_string(16831))
			end
		elseif taskIndex == 2 then
			if roleType == 1 then
				item.vars.desa:setText(i3k_get_string(16829,config.active,curValue))
			else
				item.vars.desa:setText(i3k_get_string(16832,config.active,curValue))
			end
		elseif taskIndex == 3 then
			if roleType == 1 then
				item.vars.desa:setText(i3k_get_string(16830,config.pay,curValue))
			else
				item.vars.desa:setText(i3k_get_string(16833,config.pay,curValue))
			end
		end
	end
	
	if haveNextConfig then
		item.vars.title:setText(item.vars.title:getText() .. "(明日)")
		item.vars.desa:setText(i3k_get_string(16846))
	end
	
	if isGeted then
		item.vars.finish:setVisible(true)
		item.vars.btn:disableWithChildren()
	end
	
end

function wnd_callBack:refreshTab1(data)
	self.roleType = data.roleType
	self:showTab(1)
	self.ui.activeInfo:setText(i3k_get_string(16869,i3k_db_call_back_common.condition.logDays))
	
	if data.roleType == 1 then
		self.ui.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(4995))
	else
		self.ui.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(4996))
	end
	
	local level = g_i3k_game_context:GetLevel()
	local scroll = self.ui.scroll1
	scroll:removeAllChildren()
	
	--回归送礼
	local _item = require("ui/widgets/huiguit1")()
	
	_item.vars.title:setText(i3k_get_string(16847))

	local isShowNextDay = false
	if data.dayLoginReward == 1 then
		_item.vars.btn:disableWithChildren()
		_item.vars.process:setPercent(0)
		isShowNextDay = true
	end
	setItemUI(i3k_db_call_back_login,_item,data.roleType,data.loginDay,level,nil,isShowNextDay,1)
	_item.vars.index:setImage(g_i3k_db.i3k_db_get_icon_path(4925))
	scroll:addItem(_item)
	
	local _item = require("ui/widgets/huiguit1")()
	
	_item.vars.title:setText(i3k_get_string(16848))

	local activity = g_i3k_game_context:GetScheduleInfo().activity
	local isShowNextDay = false
	if data.daySchduleReward == 1 then
		_item.vars.btn:disableWithChildren()
		isShowNextDay = true
		activity = 0
	end
	setItemUI(i3k_db_call_back_active,_item,data.roleType,data.loginDay,level,activity,isShowNextDay,2)
	_item.vars.index:setImage(g_i3k_db.i3k_db_get_icon_path(4926))
	
	
	scroll:addItem(_item)
	
	local _item = require("ui/widgets/huiguit1")()
	_item.vars.title:setText(i3k_get_string(16849))

	local day = data.loginDay
	local costNum = data.dayCostNum
	local isGeted = false
	if data.dayPayReward == 1 then
		isGeted = true
	end
	setItemUI(i3k_db_call_back_pay,_item,data.roleType,data.loginDay,level,costNum,nil,3,isGeted)
	_item.vars.index:setImage(g_i3k_db.i3k_db_get_icon_path(4927))

	scroll:addItem(_item)
end


function wnd_callBack:refreshTab2(data)
	self:showTab(2)
	self.ui.activeInfo:setText(i3k_get_string(16868))
	
	local scroll = self.ui.scroll2
	scroll:removeAllChildren()

	--金秋有礼
	local _item = require("ui/widgets/huiguit2")()
	local percent = 0
	for k,v in ipairs(i3k_db_call_back_count) do
		local ui = _item.vars
		ui["reward_txt" .. k ]:setText(v.count)
		ui["reward_icon" .. k]:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
		ui["reward_get_icon" .. k]:setImage(g_i3k_db.i3k_db_get_icon_path(v.openIcon))
		if data.roleNum >= v.count then
			percent = k*20
		else
			local lastCount = 0
			if k > 1 then
				lastCount = i3k_db_call_back_count[k-1].count
			end
			local total = v.count - lastCount
			local off = data.roleNum - lastCount
			if off > 0 then
				percent = percent + off / total *100 *0.2
			end
		end
		if data.roleNumReward[v.count] then
			ui["reward_get_icon" .. k]:setVisible(true)
			ui["reward_icon" .. k]:setVisible(false)
		else
			if data.roleNum >= v.count then
				ui["reward_btn" .. k]:onClick(self,function ()
					local _data = {}
					local checkData = {}
					for i=1,3,1 do
						if v["awardId" .. i] ~=0 then
							table.insert(_data,{id=v["awardId" .. i],count=v["awardNum" .. i]})
							checkData[v["awardId" .. i]] = v["awardNum" .. i]
						end
					end
					if g_i3k_game_context:IsBagEnough(checkData) then
						i3k_sbean.request_role_back_back_num_gift_take_req(v.count,function ()
							g_i3k_ui_mgr:ShowGainItemInfo(_data)						
						end)
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16871))
					end
				end)
				_item.anis["c_bx" .. k]:play()
			else
				ui["reward_btn" .. k]:onClick(self,function ()
					local data = {}
					for i=1,3,1 do
						if v["awardId" .. i] ~=0 then
							table.insert(data,{id=v["awardId" .. i],num=v["awardNum" .. i]})
						end
					end
					g_i3k_ui_mgr:OpenUI(eUIID_CallBackTips)
					g_i3k_ui_mgr:RefreshUI(eUIID_CallBackTips,data)
				end)
			end
		end
	end
	_item.vars.schedule1:setPercent(percent)
	_item.vars.index:setImage(g_i3k_db.i3k_db_get_icon_path(4925))
	_item.vars.title:setText(i3k_get_string(16843))
	_item.vars.desc:setText(i3k_get_string(16854,data.roleNum))
	scroll:addItem(_item)
	
	local _item = require("ui/widgets/huiguit2")()
	local percent = 0
	for k,v in ipairs(i3k_db_call_back_mission_count) do
		local ui = _item.vars
		ui["reward_txt" .. k ]:setText(v.count)
		ui["reward_icon" .. k]:setImage(g_i3k_db.i3k_db_get_icon_path(v.icon))
		ui["reward_get_icon" .. k]:setImage(g_i3k_db.i3k_db_get_icon_path(v.openIcon))
		if data.taskNum >= v.count then
			percent = k*20
		else
			local lastCount = 0
			if k > 1 then
				lastCount = i3k_db_call_back_mission_count[k-1].count
			end
			local total = v.count - lastCount
			local off = data.taskNum - lastCount
			if off > 0 then
				percent = percent + off / total *100 *0.2
			end
		end
		
		if data.taskNumReward[v.count] then
			ui["reward_get_icon" .. k]:setVisible(true)
			ui["reward_icon" .. k]:setVisible(false)
		else
			if data.taskNum >= v.count then
				ui["reward_btn" .. k]:onClick(self,function ()
					local _data = {}
					local checkData = {}
					for i=1,3,1 do
						if v["awardId" .. i] ~=0 then
							table.insert(_data,{id=v["awardId" .. i],count=v["awardNum" .. i]})
							checkData[v["awardId" .. i]] = v["awardNum" .. i]
						end
					end
					
					if g_i3k_game_context:IsBagEnough(checkData) then
						i3k_sbean.request_role_back_task_num_gift_take_req(v.count,function ()
							g_i3k_ui_mgr:ShowGainItemInfo(_data)
						end)
					else
						g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16871))
					end
				end)
				_item.anis["c_bx" .. k]:play()
			else
				ui["reward_btn" .. k]:onClick(self,function ()
					local data = {}
					for i=1,3,1 do
						if v["awardId" .. i] ~=0 then
							table.insert(data,{id=v["awardId" .. i],num=v["awardNum" .. i]})
						end
					end
					g_i3k_ui_mgr:OpenUI(eUIID_CallBackTips)
					g_i3k_ui_mgr:RefreshUI(eUIID_CallBackTips,data)
				end)
			end
		end
	end
	_item.vars.schedule1:setPercent(percent)
	_item.vars.index:setImage(g_i3k_db.i3k_db_get_icon_path(4926))
	_item.vars.title:setText(i3k_get_string(16844))
	_item.vars.desc:setText(i3k_get_string(16855,data.taskNum))
	scroll:addItem(_item)
end

function wnd_callBack:refreshTab3(data)
	self:showTab(3)
	local scroll = self.ui.scroll3
	scroll:removeAllChildren()
	local shouldRedVisible = false
	for k, v in ipairs(i3k_db_call_back_pay_gift) do
		local widgets = require("ui/widgets/huiguit3")()
		local max = 4
		for i = 1, max do
			if v.items[i] then
				widgets.vars['icon' .. i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.items[i].id, i3k_game_context:IsFemaleRole()))
				widgets.vars['rank' .. i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.items[i].id))
				widgets.vars['cnt' .. i]:setText(string.format("x%d", v.items[i].count))
				widgets.vars['btn' .. i]:onClick(self, function ()
					g_i3k_ui_mgr:ShowCommonItemInfo(v.items[i].id)
				end)
			else
				widgets.vars['icon' .. i]:setVisible(false)
				widgets.vars['rank' .. i]:setVisible(false)
				widgets.vars['cnt' .. i]:setVisible(false)
				widgets.vars['btn' .. i]:setVisible(false)
			end
		end
		local residueTimes = v.times - (data.info.rewards[k] or 0)
		widgets.vars.times:setText(i3k_get_string(18343, residueTimes))
		widgets.vars.btn:onClick(self, self.onExchangeBtnClick, k)
		widgets.vars.scoreText:setText(i3k_get_string(18349, v.score))
		if residueTimes <= 0 or data.info.score < v.score then
			widgets.vars.btn:disableWithChildren()
		else
			shouldRedVisible = true
		end
		self.ui.activeInfo:setText(i3k_get_string(18476))
		scroll:addItem(widgets)
	end
	if not shouldRedVisible then
		g_i3k_game_context:ClearNotice(g_NOTICE_TYPE_SWORN)
		self.ui.red3:setVisible(false)
	end
	self.ui.desc_text:setText(i3k_get_string(18341))
	self.ui.score_text:setText(i3k_get_string(18342, data.info.score))
	self.ui.goto_pay_btn:onClick(self, self.onGotoPayBtnClick)
end
function wnd_callBack:onExchangeBtnClick(sender, id)
	local items = {}
	for k, v in ipairs(i3k_db_call_back_pay_gift[id].items) do
		items[v.id] = v.count
	end
	if g_i3k_game_context:IsBagEnough(items) then
		i3k_sbean.request_role_back_pay_take_reward_req(id)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(17423))
	end
end
function wnd_callBack:onGotoPayBtnClick(sender)
	g_i3k_logic:OpenChannelPayUI()
	g_i3k_ui_mgr:CloseUI(eUIID_CallBack)
end
function wnd_callBack:showTab(index)
	for i = 1, #self.btn do
		if i == index then
			local pressedTextColor = "ffec0b10"
			local pressedOutLineColor = "fffffeb1"
			self.btn[i].tab:stateToPressed()
			self.btn[i].text:stateToPressed(pressedTextColor, pressedOutLineColor)
			self.btn[i].content:setVisible(true)
		else
			self.btn[i].tab:stateToNormal()
			self.btn[i].text:stateToNormal()
			self.btn[i].content:setVisible(false)
		end
		if i == 3 then
			local isShow = i3k_db_call_back_common.payGiftCfg.isOnlyReturnPlayer == 0 or self.roleType == 1
			self.btn[i].tab:setVisible(isShow)
			self.btn[i].red:setVisible(g_i3k_game_context:testNotice(g_NOTICE_TYPE_SWORN))
		else
			self.btn[i].red:setVisible(false)
		end
	end
end

function wnd_callBack:onClose()
	g_i3k_ui_mgr:CloseUI(eUIID_CallBack)
end

function wnd_create(layout, ...)
	local wnd = wnd_callBack.new()
	wnd:create(layout, ...)
	return wnd
end
