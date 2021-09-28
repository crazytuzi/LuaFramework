-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fengce = i3k_class("wnd_fengce", ui.wnd_base)

local f_tabColor = {
	press = {textColor = "FFFFFFFF", outlineColor = "FF9F781A"},
	normal = {textColor = "FFBBFFED", outlineColor = "FF276C61"}
}
-- local SURVEY_STATE		= 1
local LOGIN_STATE		= 2
local LEVEL_UP_STATE	= 3
local USERDATA_STATE	= 4
local SPRINT_STATE		= 5
local TIME_REWARD_STATE	= 6
local STRENG_PVP_STATE	= 7

local SYNC_FUNC_TABLE = {
	-- [SURVEY_STATE] = function (self)
	-- 	local node = require("ui/widgets/youjiangdiaoyan")()
	-- 	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "addChildWidget", node)
	-- 	return node
	-- end,
	[LOGIN_STATE] = function (self)
		local node = require("ui/widgets/yuanbaozengsong")()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "addChildWidget", node)
		return node
	end,
	[LEVEL_UP_STATE] = function (self)
		local node = require("ui/widgets/fcsjsl")()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "addChildWidget", node)
		return node
	end,
	[USERDATA_STATE] = function (self)
		local node = require("ui/widgets/wszl")()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "addChildWidget", node)
		return node
	end,
	[SPRINT_STATE] = function (self)
		local node = require("ui/widgets/fcdjs")()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "addChildWidget", node)
		return node
	end,
	[TIME_REWARD_STATE] = function (self)
		local node = require("ui/widgets/yuanbaozengsong2")()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "addChildWidget", node)
		return node
	end,
	[STRENG_PVP_STATE] = function (self)
		local node = require("ui/widgets/fcqhsl")()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "addChildWidget", node)
		return node
	end
}

function wnd_fengce:ctor()
	-- self._state = SURVEY_STATE
	self._vipListPercent = nil
	self._sprintPercent = nil
end

function wnd_fengce:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)

	self._rootWidget = self._layout.vars.rightWidget
end

function wnd_fengce:onShow()

end

local getDayIndex = function ()
	local openDay = i3k_game_get_server_open_day()
	local nowDay = g_i3k_get_day(i3k_game_get_time() - 5*60*60)
	return nowDay - openDay + 1
end

function wnd_fengce:addChildWidget(widget)
	local children = self._rootWidget:getAddChild()
	for i,v in pairs(children) do
		self._rootWidget:removeChild(v)
	end
	self._rootWidget:addChild(widget)
end

function wnd_fengce:refresh(redCache)
	g_i3k_game_context:setIsFirstLogin(false)
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren(true)
	local index = 1
	local jumpIndex = 1
	local jumpBtn = nil
	local hero = i3k_game_get_player_hero()
	for i,v in ipairs(i3k_db_fengce_name) do
		if v.name~="有奖调查" then -- 干掉有奖调研
			local node = require("ui/widgets/fchdt")()
			if not jumpBtn then
				jumpBtn = node.vars.btn
			end
			node.vars.nameLabel:setText(v.name)
			node.vars.red:setVisible(redCache[i])
			if redCache[i] and jumpIndex==1 and i~=1 then
				jumpIndex = i
				jumpBtn = node.vars.btn
			end
			node.vars.btn:setTag(i)
			node.vars.btn:onClick(self, self.onMenuClick)
			if v.name~="使命召唤" then
				scroll:addItem(node)
			elseif hero._lvl>=i3k_db_fengce.userDataLvl and g_i3k_game_context:getIsShowFengceWebLink() then
				scroll:addItem(node)
			end
			index = index + 1
		end
	end
	self:onMenuClick(jumpBtn)
	scroll:jumpToChildWithIndex(jumpIndex)
end

function wnd_fengce:onMenuClick(sender)
	local index = sender:getTag()
	local callback = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "updateFengceMenu", index)
	end
	self._vipListPercent = nil--每次切换视图时的初始化
	self._sprintPercent = nil
	-- if index==SURVEY_STATE then--有奖调研
	-- 	i3k_sbean.sync_survey(callback)
	if index==LOGIN_STATE then--登录有礼（巨献）
		i3k_sbean.sync_login_gift(callback)
	elseif index==LEVEL_UP_STATE then--升级送礼
		i3k_sbean.sync_level_up_gift(callback)
	elseif index==USERDATA_STATE then--完善资料
		i3k_sbean.sync_userdata(callback)
	elseif index==SPRINT_STATE then--活动倒计时
		i3k_sbean.sync_sprint(callback)
	elseif index==TIME_REWARD_STATE then--限时赠礼
		i3k_sbean.sync_timeReward(callback)
	elseif index == STRENG_PVP_STATE then -- 强化比拼
		i3k_sbean.sync_strengthengift(callback)
	end
end

function wnd_fengce:updateFengceMenu(index)
	local children = self._layout.vars.scroll:getAllChildren()
	for i,v in ipairs(children) do
		v.vars.selectImg:setVisible(v.vars.btn:getTag()==index)
		if v.vars.btn:getTag()==index then
			v.vars.btn:stateToPressedAndDisable()
			--v.vars.nameLabel:setTextColor(f_tabColor.press.textColor)
			--v.vars.nameLabel:enableOutline(f_tabColor.press.outlineColor)
		else
			v.vars.btn:stateToNormal()
			--v.vars.nameLabel:setTextColor(f_tabColor.normal.textColor)
			--v.vars.nameLabel:enableOutline(f_tabColor.normal.outlineColor)
		end
	end
	self._state = index
end

function wnd_fengce:hideRedPoint(state)
	local children = self._layout.vars.scroll:getAllChildren()
	for i,v in ipairs(children) do
		if v.vars.btn:getTag()==state then
			v.vars.red:hide()
			break
		end
	end
	-- if state==SURVEY_STATE then
	-- 	g_i3k_game_context:setFengceSurveyRedCache(false)
	if state==LOGIN_STATE then
		g_i3k_game_context:setFengceLoginRedCache(false)
	elseif state==LEVEL_UP_STATE then
		g_i3k_game_context:setFengceLevelRedCache(false)
	elseif state==USERDATA_STATE then
		g_i3k_game_context:setFengceUserdataRedCache(false)
	elseif state==SPRINT_STATE then
		g_i3k_game_context:setFengceSprintRedCache(false)
	elseif state==TIME_REWARD_STATE then
		g_i3k_game_context:setFengceTimeRewardRedCache(false)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "disableTimeRewardBtn")
	elseif state == STRENG_PVP_STATE then
		g_i3k_game_context:setFengceStrenglevelRedCache(false)
	end
end

-- function wnd_fengce:setSurveyRightData(index, reward)
-- 	local widget = SYNC_FUNC_TABLE[SURVEY_STATE]()
-- 	local item = i3k_db_fengce.survey
-- 	widget.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
-- 	widget.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id))
-- 	widget.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(item.id))
-- 	widget.vars.btn:setTag(item.id)
-- 	widget.vars.btn:onClick(self, self.checkItemInfo)
-- 	if reward==1 then
-- 		widget.vars.takeLabel:setText(string.format("已完成"))
-- 		widget.vars.joinBtn:disableWithChildren()
-- 	elseif index~=#i3k_db_fengce_survey then
-- 		if g_i3k_game_context:GetLevel()<i3k_db_fengce.baseData.surveyNeedLvl then
-- 			widget.vars.takeLabel:setText(string.format("%d级开启", i3k_db_fengce.baseData.surveyNeedLvl))
-- 			widget.vars.joinBtn:disableWithChildren()
-- 		else
-- 			widget.vars.takeLabel:setText(string.format("参与调查"))
-- 			widget.vars.joinBtn:onClick(self, self.joinSurvey, index)
-- 		end
-- 	else
-- 		widget.vars.takeLabel:setText(string.format("领奖"))
-- 		widget.vars.joinBtn:onClick(self, self.takeSurveyReward)
-- 	end
-- end

function wnd_fengce:setLoginRightData(gifts)
	local widget = SYNC_FUNC_TABLE[LOGIN_STATE]()
	local dayIndex = getDayIndex()
	local item = {}
	if not i3k_db_fengce.juxian[dayIndex] then
		local openDay = i3k_game_get_server_open_day()
		local nowDay = g_i3k_get_day(i3k_game_get_time() - 5*60*60)
		local day = nowDay - openDay + 1
		error(string.format("fengce juxian dayIndex error, openDay = %d, nowDay = %d, dayIndex = %d", openDay, nowDay, day))
	end
	item.id = i3k_db_fengce.juxian[dayIndex].id
	item.count = i3k_db_fengce.juxian[dayIndex].count
	widget.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
	widget.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id,i3k_game_context:IsFemaleRole()))
	widget.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(item.id).."*"..item.count)
	widget.vars.btn:setTag(item.id)
	widget.vars.btn:onClick(self, self.checkItemInfo)
	if gifts[dayIndex] then
		widget.vars.takeLabel:setText(string.format("已领取"))
		widget.vars.takeBtn:disableWithChildren()
		self:hideRedPoint(LOGIN_STATE)
	else
		widget.vars.takeBtn:onClick(self, self.takeDiamondReward, gifts)
	end
end

function wnd_fengce:setVipRightData(gifts)
	local hero = i3k_game_get_player_hero()
	local widget = SYNC_FUNC_TABLE[LEVEL_UP_STATE]()
	widget.vars.scroll:setBounceEnabled(false)--差个没有达到等级要求显示问题
	local noTakeCount = 0
	local noTakeIndex = 1
	for i,v in ipairs(i3k_db_fengce.fengcePackage) do
		local node = require("ui/widgets/fcsjslt")()
		node.vars.requireLabel:setText(string.format("达到%d级可以领取", v.level))
		node.vars.gradeIcon1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(g_BASE_ITEM_VIP))
		node.vars.icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(g_BASE_ITEM_VIP,i3k_game_context:IsFemaleRole()))
		node.vars.countLabel1:setText("x"..v.vipPoint)
		node.vars.lock1:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(g_BASE_ITEM_VIP))
		node.vars.btn1:setTag(g_BASE_ITEM_VIP)
		node.vars.btn1:onClick(self, self.checkItemInfo)

		node.vars.gradeIcon2:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		node.vars.icon2:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		node.vars.btn2:setTag(v.id)
		node.vars.btn2:onClick(self, self.checkItemInfo)
		node.vars.countLabel2:setText("x"..v.count)
		node.vars.lock2:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(v.id))
		node.vars.stateLabel:setText(string.format("(%d/%d)", hero._lvl, v.level))
		if hero._lvl>=v.level then
			node.vars.stateLabel:setTextColor(g_i3k_get_cond_color(hero._lvl>=v.level))
		end
		node.vars.takeBtn:setTag(i)
		node.vars.takeBtn:onClick(self, self.takeLvlReward, gifts)
		noTakeCount = noTakeCount + 1
		node.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2424))
		node.vars.finish_icon:hide()
		if hero._lvl<v.level and not gifts[v.level] then
			node.vars.takeLabel:setText(string.format("未达成"))
			node.vars.takeBtn:disableWithChildren()
			noTakeCount = noTakeCount - 1
			node.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
		else
			if gifts[v.level] then
				--node.vars.takeLabel:setText(string.format("已领取"))
				node.vars.takeBtn:hide()
				node.vars.stateLabel:hide()
				noTakeCount = noTakeCount - 1
				noTakeIndex = i+1
				node.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
				node.vars.finish_icon:show()
			end
		end
		widget.vars.scroll:addItem(node)
	end

	if noTakeCount<=0 then
		self:hideRedPoint(LEVEL_UP_STATE)
	elseif not self._vipListPercent and noTakeIndex~=1 then
		widget.vars.scroll:jumpToChildWithIndex(noTakeIndex)
	end
	if self._vipListPercent then
		widget.vars.scroll:jumpToListPercent(self._vipListPercent)
	end
end

function wnd_fengce:setMaterialRightData(qq, phone, isOld, reward)
	local widget = SYNC_FUNC_TABLE[USERDATA_STATE]()

	local nosetLabel = string.format("未设置")
	widget.vars.qqLabel:setText(qq~="" and qq or nosetLabel)
	widget.vars.phoneLabel:setText(phone~="" and phone or nosetLabel)
	local oldTextId = isOld==0 and 582 or (isOld==1 and 583) or 584
	widget.vars.oldPlayerLabel:setText(i3k_get_string(oldTextId))

	local item = i3k_db_fengce.COD
	widget.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.id))
	widget.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(item.id,i3k_game_context:IsFemaleRole()))
	widget.vars.btn:setTag(item.id)
	widget.vars.btn:onClick(self, self.checkItemInfo)
	widget.vars.nameLabel:setText(g_i3k_db.i3k_db_get_common_item_name(item.id))
	local userdata = {
		qq = qq,
		phone = phone,
		isOld = isOld,
		reward = reward
	}
	local isShow = true
	if reward==1 then
		widget.vars.perfectBtn:onClick(self, self.perfectData, userdata)
		widget.vars.takeLabel:setText(string.format("修改资料"))
		isShow = false
	else
		if qq~="" and phone~="" and isOld~=0 then
			widget.vars.takeLabel:setText(string.format("领奖"))
			widget.vars.perfectBtn:onClick(self, function (sender)
				local callback = function ()
					self:setMaterialRightData(qq, phone, isOld, 1)--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, setMaterialRightData, qq, phone, isOld, 1)
					g_i3k_ui_mgr:ShowGainItemInfo({item})
				end
				i3k_sbean.take_userdata_gift(callback)
			end)
		else
			widget.vars.takeLabel:setText(string.format("完善资料"))
			widget.vars.perfectBtn:onClick(self, self.perfectData, userdata)
		end
	end
	widget.vars.urlRoot:setVisible(false) -- g_i3k_game_context:getIsShowFengceWebLink())
	widget.vars.url:onClick(self, self.onOpenURL)

	if not isShow then
		self:hideRedPoint(USERDATA_STATE)
	end
end

function wnd_fengce:onOpenURL(sender)
	i3k_open_url("https://sojump.com/jq/9852229.aspx")
	i3k_sbean.take_official_reward()
end

function wnd_fengce:setSprintRightData(gifts)
	local widget = SYNC_FUNC_TABLE[SPRINT_STATE]()
	widget.vars.scroll:setBounceEnabled(false)
	local dayIndex = getDayIndex()
	local noTakeCount = 0
	local noTakeIndex = 1
	for i,v in ipairs(i3k_db_fengce.sprint.cfg) do
		local node = require("ui/widgets/fcdjst")()
		node.vars.requireLabel:setText(string.format("封测第%d天可领取", i3k_db_fengce.sprint.startTime+i-1))
		node.vars.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		node.vars.countLabel:setText("x"..v.count)
		node.vars.btn:setTag(v.id)
		node.vars.btn:onClick(self, self.checkItemInfo)
		node.vars.takeBtn:setTag(i)
		node.vars.takeBtn:onClick(self, self.takeSprintReward, gifts)
		node.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2424))
		noTakeCount = noTakeCount + 1
		node.vars.finish_icon:hide()
		if gifts[i] then
			--node.vars.takeLabel:setText(string.format("已领取"))
			node.vars.takeBtn:hide()
			noTakeCount = noTakeCount - 1
			noTakeIndex = i+1
			node.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
			node.vars.finish_icon:show()
		elseif dayIndex<i3k_db_fengce.sprint.startTime+i-1 then
			node.vars.takeLabel:setText(string.format("未到达"))
			node.vars.takeBtn:disableWithChildren()
			noTakeCount = noTakeCount - 1
			node.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
		end
		widget.vars.scroll:addItem(node)
	end
	if noTakeCount<=0 then
		self:hideRedPoint(SPRINT_STATE)
	elseif not self._sprintPercent and noTakeIndex~=1 then
		widget.vars.scroll:jumpToChildWithIndex(noTakeIndex)
	end
	if self._sprintPercent then
		widget.vars.scroll:jumpToListPercent(self._sprintPercent)
	end
end

function wnd_fengce:setTimeRewardRightData(gifts)
	local widget = SYNC_FUNC_TABLE[TIME_REWARD_STATE]()

	local startString = i3k_db_fengce.timeReward.startTime
	local endString = i3k_db_fengce.timeReward.endTime
	local timeStamp = g_i3k_get_GMTtime(i3k_game_get_time())
	local year = os.date("%Y", timeStamp )
	local month = os.date("%m", timeStamp )
	local day = os.date("%d", timeStamp)
	local open = string.split(startString, ":")
	local close = string.split(endString, ":")
	local openTimeStamp = os.time({year = year, month = month, day = day, hour = open[1], min = open[2], sec = open[3]})
	local closeTimeStamp = os.time({year = year, month = month, day = day, hour = close[1], min = close[2], sec = close[3]})

	local dayIndex = getDayIndex()
	for i=1, 3 do
		local itemId = i3k_db_fengce.timeReward.rewardTable[dayIndex]["id"..i]
		if itemId==0 then
			widget.vars["gradeIcon"..i]:hide()
		else
			local count = i3k_db_fengce.timeReward.rewardTable[dayIndex]["count"..i]
			widget.vars["gradeIcon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
			widget.vars["icon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
			widget.vars["countLabel"..i]:setText("x"..count)
			widget.vars["lock"..i]:setVisible(g_i3k_common_item_has_binding_icon(itemId))
			widget.vars["btn"..i]:setTag(itemId)
			widget.vars["btn"..i]:onClick(self, self.checkItemInfo)
		end
	end
	if gifts[dayIndex] then
		widget.vars.takeLabel:setText(string.format("已领取"))
		widget.vars.takeBtn:disableWithChildren()
		self:hideRedPoint(TIME_REWARD_STATE)
		return
	else
		widget.vars.takeBtn:onClick(self, self.takeTimeReward, gifts)
	end


	if openTimeStamp>timeStamp then
		widget.vars.takeLabel:setText(string.format("时间未到"))
		widget.vars.takeBtn:disableWithChildren()
		return
	elseif timeStamp>closeTimeStamp then
		widget.vars.takeLabel:setText(string.format("已过时"))
		widget.vars.takeBtn:disableWithChildren()
	end
end

function wnd_fengce:setStrengPVPRightData(gifts)
	local widget = SYNC_FUNC_TABLE[STRENG_PVP_STATE]()
	local noTakeCount = 0
	local noTakeIndex = 1
	local allStreng_level = g_i3k_db.i3k_db_get_role_allStreng_level()
	for i,v in ipairs(i3k_db_fengce.strengPVP) do
		local node = require("ui/widgets/fcqhslt")()
		for k=1, 2 do
			node.vars["gradeIcon" .. k]:hide()
			if tonumber(v["awardID" .. k]) ~= 0 then
				node.vars["gradeIcon" .. k]:show()
				node.vars["gradeIcon" .. k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v["awardID" .. k]))
				node.vars["icon" .. k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v["awardID" .. k],i3k_game_context:IsFemaleRole()))
				node.vars["countLabel" .. k]:setText("x"..v["awardCount" .. k])
				node.vars["lock" .. k]:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(v["awardID" .. k]))
				node.vars["btn" .. k]:setTag(v["awardID" .. k])
				node.vars["btn" .. k]:onClick(self, self.checkItemInfo)
			end
		end
		node.vars.requireLabel:setText(string.format("装备升级总等级达到%d级可以领取", v.strenglevel))
		node.vars.stateLabel:setText(string.format("(%d/%d)", allStreng_level, v.strenglevel))
		if allStreng_level>=v.strenglevel then
			node.vars.stateLabel:setTextColor(g_i3k_get_cond_color(allStreng_level>=v.strenglevel))
		end
		node.vars.takeBtn:setTag(i)
		node.vars.takeBtn:onClick(self, self.takeStrengPVPReward, {gifts = gifts, strenglevel = v.strenglevel, awardID1 = v.awardID1, awardCount1 = v.awardCount1, })
		noTakeCount = noTakeCount + 1
		node.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2424))
		node.vars.finsh_icon:hide()
		node.vars.takeBtn:show()
		if allStreng_level < v.strenglevel then
			node.vars.takeLabel:setText(string.format("未达成"))
			node.vars.takeBtn:disableWithChildren()
			noTakeCount = noTakeCount - 1
			node.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
		end
		if gifts[v.strenglevel] then
			node.vars.takeBtn:hide()
			node.vars.stateLabel:hide()
			noTakeCount = noTakeCount - 1
			noTakeIndex = i+1
			node.vars.root_bg:setImage(g_i3k_db.i3k_db_get_icon_path(2423))
			node.vars.finsh_icon:show()
		end
		widget.vars.scroll:addItem(node)
	end
	if noTakeCount<=0 then
		self:hideRedPoint(STRENG_PVP_STATE)
	end
	if noTakeIndex~=1 then
		widget.vars.scroll:jumpToChildWithIndex(noTakeIndex)
	end
end

-- function wnd_fengce:joinSurvey(sender, index)
-- 	g_i3k_ui_mgr:OpenUI(eUIID_Survey)
-- 	g_i3k_ui_mgr:RefreshUI(eUIID_Survey, index+1)
-- end
--
-- function wnd_fengce:takeSurveyReward(sender)
-- 	local index = sender:getTag()
-- 	local widget = self._rootWidget:getAddChild()[1]
-- 	local itemTable = {i3k_db_fengce.survey}
-- 	local callback = function()
-- 		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "surveryRewardCB", widget, itemTable)
-- 	end
-- 	local isEnoughTable = {
-- 		[i3k_db_fengce.survey.id] = i3k_db_fengce.survey.count,
-- 	}
-- 	local isenough = g_i3k_game_context:IsBagEnough(isEnoughTable)
-- 	if isenough then
-- 		i3k_sbean.take_survey_gift(callback)
-- 	else
-- 		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(288))
-- 	end
-- end
--
-- function wnd_fengce:surveryRewardCB(widget, itemTable)
-- 	widget.vars.takeLabel:setText(string.format("已完成"))
-- 	widget.vars.joinBtn:disableWithChildren()
-- 	g_i3k_ui_mgr:ShowGainItemInfo(itemTable)
-- 	self:hideRedPoint(SURVEY_STATE)
-- end

function wnd_fengce:takeDiamondReward(sender, gifts)
	local dayIndex = getDayIndex()
	local item = {}
	item.id = i3k_db_fengce.juxian[dayIndex].id
	item.count = i3k_db_fengce.juxian[dayIndex].count
	itemTable = {
		[1] = item
	}
	local callback = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "diamondRewardCB", gifts, dayIndex, itemTable)
	end
	i3k_sbean.take_login_gift(dayIndex, callback)
end

function wnd_fengce:diamondRewardCB(gifts, dayIndex, itemTable)
	gifts[dayIndex] = true
	g_i3k_ui_mgr:ShowGainItemInfo(itemTable)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setLoginRightData", gifts)
end

function wnd_fengce:takeLvlReward(sender, gifts)
	local index = sender:getTag()
	local level = i3k_db_fengce.fengcePackage[index].level
	local item = {
		id = i3k_db_fengce.fengcePackage[index].id,
		count = i3k_db_fengce.fengcePackage[index].count,
	}
	local itemTable = {
		[1] = {id = 1001, count = i3k_db_fengce.fengcePackage[index].vipPoint},
		[2] = item,
	}
	local widget = self._rootWidget:getAddChild()[1]
	self._vipListPercent = widget.vars.scroll:getListPercent()
	local callback = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "vipRewardCB", gifts, level, itemTable)
	end
	i3k_sbean.take_level_gift(level, callback)
end

function wnd_fengce:takeStrengPVPReward(sender, data)
	local itemTable = {
			[1] = {id = data.awardID1, count = data.awardCount1},
			--[2] = {id = data.awardID2, count = data.awardCount2}
	}
	local callback = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "StrengPVPRewardCB", data.gifts, data.strenglevel, itemTable)
	end
	i3k_sbean.take_strengthengift(data.strenglevel, callback)
end

function wnd_fengce:StrengPVPRewardCB(gifts, strenglevel, itemTable)
	gifts[strenglevel] = true
	g_i3k_ui_mgr:ShowGainItemInfo(itemTable)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setStrengPVPRightData", gifts)
end

function wnd_fengce:vipRewardCB(gifts, level, itemTable)
	gifts[level] = true
	g_i3k_ui_mgr:ShowGainItemInfo(itemTable)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setVipRightData", gifts)
end

function wnd_fengce:perfectData(sender, userdata)
	g_i3k_ui_mgr:OpenUI(eUIID_PerfectUserdata)
	g_i3k_ui_mgr:RefreshUI(eUIID_PerfectUserdata, userdata.qq, userdata.phone, userdata.isOld, userdata.reward)
	--g_i3k_ui_mgr:PopupTipMessage(string.format("完善资料"))
end

function wnd_fengce:takeSprintReward(sender, gifts)
	--g_i3k_ui_mgr:PopupTipMessage(string.format("最后冲刺奖励"))
	local index = sender:getTag()
	local item = i3k_db_fengce.sprint.cfg[index]
	local itemTable = {item}
	local widget = self._rootWidget:getAddChild()[1]
	local node = widget.vars.scroll:getAllChildren()[index]
	self._sprintPercent = widget.vars.scroll:getListPercent()
	local callback = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "sprintRewardCB", gifts, index, itemTable)
	end
	i3k_sbean.take_sprint_gift(index, callback)
end

function wnd_fengce:sprintRewardCB(gifts, index, itemTable)
	gifts[index] = true
	g_i3k_ui_mgr:ShowGainItemInfo(itemTable)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setSprintRightData", gifts)
end

function wnd_fengce:takeTimeReward(sender, gifts)
	local dayIndex = getDayIndex()
	local item = {}
	rewardCfg = i3k_db_fengce.timeReward.rewardTable[dayIndex]
	itemTable = {
		[1] = {id = rewardCfg.id1, count = rewardCfg.count1},
		[2] = {id = rewardCfg.id2, count = rewardCfg.count2},
		[3] = {id = rewardCfg.id3, count = rewardCfg.count3},
	}
	for i,v in ipairs(itemTable) do
		if v.id==0 or v.id==nil then
			itemTable[i] = nil
		end
	end
	local callback = function ()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "timeRewardCB", gifts, dayIndex, itemTable)
	end
	i3k_sbean.take_timeReward(dayIndex, callback)
end

function wnd_fengce:timeRewardCB(gifts, dayIndex, itemTable)
	gifts[dayIndex] = true
	g_i3k_ui_mgr:ShowGainItemInfo(itemTable)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Fengce, "setTimeRewardRightData", gifts)
end

function wnd_fengce:disableTimeRewardBtn()
	if self._state==TIME_REWARD_STATE then
		local widget = self._rootWidget:getAddChild()[1]
		widget.vars.takeLabel:setText(string.format("已过时"))
		widget.vars.takeBtn:disableWithChildren()
	end
end

function wnd_fengce:checkItemInfo(sender)
	local itemId = sender:getTag()
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

--[[function wnd_fengce:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_Fengce)
end--]]

function wnd_create(layout, ...)
	local wnd = wnd_fengce.new()
	wnd:create(layout, ...)
	return wnd;
end
