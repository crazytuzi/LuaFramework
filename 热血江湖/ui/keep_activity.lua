-------------------------------------------------------
module(..., package.seeall)

local require = require

require("ui/ui_funcs")
local ui = require("ui/base")

-------------------------------------------------------

wnd_keep_activity = i3k_class("wnd_keep_activity",ui.wnd_base)
local IS_SELECT = 2407
local NO_SELECT = 2406
local JL_WIDGETS = "ui/widgets/dlslt"
local RowitemCount = 1
local TaskTypeBox = 1

local LeftRedPoint = {7852, 7853}
--tab页签类型
local LoginReward = 1
local WeekLimitBox = 2
function wnd_keep_activity:ctor()
	self._pos = 0
	self._poptick = 0
	self._weekData = nil
	self._openType = LoginReward
end

function wnd_keep_activity:configure()
	local widgets = self._layout.vars

	self.scroll = widgets.scroll
	self.getBtn = widgets.getBtn
	self.getText = widgets.getText
	self.rewardText = widgets.rewardText
	self.model = widgets.model
	self.rewardIcon = widgets.rewardIcon
	self.countDownTime = widgets.countDownTime
	self.timeLabel = widgets.timeLabel
	self.getBtnRed = widgets.getBtnRed

	widgets.close:onClick(self, self.onClose)
	widgets.getBtn:onClick(self, self.onReward)
	widgets.getCjbBtn:onClick(self, self.onGetChuanjiabao)
	widgets.openBtn:onClick(self, self.onOpenBtn)
	widgets.helpBtn:onClick(self, function()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(17523))
	end)

	self.chjb_view = widgets.chjb_view
	self.getCjbBtn = widgets.getCjbBtn
	self.havetimes = widgets.havetimes
	self.curCount = widgets.curCount
	self.pros = {}
	for i = 1 , 3 do
		self.pros[i] = {}
		self.pros[i].name = widgets["curprop"..i.."name"]
		self.pros[i].value = widgets["curprop"..i.."value"]
		self.pros[i].icon = widgets["propIcon"..i]
	end
	self.tabs = {
		[LoginReward] = {btn = widgets.loginBtn, red = widgets.loginRed},
		[WeekLimitBox] = {btn = widgets.boxBtn, red = widgets.boxRed},
	}
	for i, v in ipairs(self.tabs) do
		v.btn:onClick(self, function()
			self:showIndex(i)
		end)
	end
end

function wnd_keep_activity:refresh(isLoginReward)
	local openType = isLoginReward and LoginReward or WeekLimitBox
	self:showIndex(openType)
	self:updateWeekTabRed()
end

----start
function wnd_keep_activity:showIndex(openType)
	self._openType = openType

	if openType == LoginReward and not g_i3k_game_context:isShowLoginReward() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5374))
	end

	local widgets = self._layout.vars
	for i, v in ipairs(self.tabs) do
		if i == openType then
			v.btn:stateToPressed(true)
		else
			v.btn:stateToNormal(true)
		end
	end
	widgets.chjb_view:setVisible(openType == LoginReward)
	widgets.weekBoxRoot:setVisible(openType == WeekLimitBox)
	widgets.helpBtn:setVisible(openType == WeekLimitBox)

	if openType == LoginReward then
		widgets.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(7848))
		self.getBtnRed:hide()
		self.getBtn:onClick(self, self.onReward)
		widgets.openBtn:onClick(self, self.onOpenBtn)
		self:SetScrollData()
	elseif openType == WeekLimitBox then
		widgets.titleImg:setImage(g_i3k_db.i3k_db_get_icon_path(7849))
		self.rewardIcon:hide()
		self.getText:setText("领取奖励")
		self:setWeekLimitBoxUI()
	end
end

function wnd_keep_activity:getAllTaskBoxIDs()
	local taskBoxIDs = {}
	for k, v in ipairs(i3k_db_week_limit_reward_cfg) do
		if v.taskType == TaskTypeBox then
			table.insert(taskBoxIDs, k)
		end
	end
	table.sort(taskBoxIDs, function(a, b)
		local taskIdA = i3k_db_week_limit_reward_cfg[a].args2
		local taskIdB = i3k_db_week_limit_reward_cfg[b].args2
		return taskIdA < taskIdB
	end)
	return taskBoxIDs
end

function wnd_keep_activity:getPreTaskBoxID(curBoxID, allTaskBox)
	for i, v in ipairs(allTaskBox) do
		if curBoxID == v then
			return allTaskBox[i - 1]
		end
	end
end

function wnd_keep_activity:isShowTaskBox(curBoxID, allTaskBox, weekLimitData)
	local rewardCfg = i3k_db_week_limit_reward_cfg[curBoxID]
	if rewardCfg.taskType == TaskTypeBox then
		if weekLimitData[curBoxID].isTakedReward == 1 then
			return false
		end

		--当前宝箱的上一个剧情ID
		local preBoxID = self:getPreTaskBoxID(curBoxID, allTaskBox)
		if preBoxID then
			if weekLimitData[preBoxID].isFinish == 0 then
				return false
			end
		end
	end
	return true
end

function wnd_keep_activity:setWeekLimitBoxUI()
	local weekLimitData = g_i3k_game_context:GetWeekLimitData()
	self.scroll:removeAllChildren()
	self.scroll:setBounceEnabled(false)

	local allTaskBox= self:getAllTaskBoxIDs()

	local sortData = {}
	for k, v in pairs(weekLimitData) do
		local rewardCfg = i3k_db_week_limit_reward_cfg[k]
		if rewardCfg then
			if g_i3k_game_context:GetLevel() >= rewardCfg.showLvl and self:isShowTaskBox(k, allTaskBox, weekLimitData) then
				table.insert(sortData, {boxID = k, boxData = v, taskType = rewardCfg.taskType, taskValue = rewardCfg.args2})
			end
		end
	end
	table.sort(sortData, function(a, b)
		local sortA = a.boxData.isTakedReward * 1000 + a.taskType * 100 + a.taskValue * 0.01
		local sortB = b.boxData.isTakedReward * 1000 + b.taskType * 100 + b.taskValue * 0.01
		return sortA < sortB
	end)

	local selectIndex = 0
	local allBars = self.scroll:addChildWithCount(JL_WIDGETS, RowitemCount, #sortData)
	for i, v in ipairs(allBars) do
		local data = sortData[i]
		local boxData = data.boxData
		local rewardCfg = i3k_db_week_limit_reward_cfg[data.boxID]

		if rewardCfg then
			v.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(rewardCfg.icon))
			v.vars.ask:hide()
			v.vars.isSelect:hide()
			v.vars.desc:setText(rewardCfg.name)
			v.vars.isFinish:setVisible(boxData.isTakedReward == 1)
			v.vars.rootNode:SetIsableWithChildren(true)
			v.vars.itemBtn:onClick(self, function()
				self:selectRewardBox(i, data)
			end)

			local redCount = g_i3k_game_context:getWeekLimitBoxRedPointNum(boxData)
			v.vars.redPoint:setVisible(redCount > 0)

			if selectIndex == 0 and redCount > 0 then
				selectIndex = i
			end
		end
	end
	if selectIndex == 0 then
		selectIndex = 1
	end
	self:selectRewardBox(selectIndex, sortData[selectIndex])
	self.scroll:jumpToChildWithIndex(selectIndex)
end

function wnd_keep_activity:selectRewardBox(index, data)
	local widgets = self._layout.vars

	local allBars = self.scroll:getAllChildren()
	for i, v in ipairs(allBars) do
		v.vars.isSelect:setVisible(index == i)
	end
	self:setWeekBoxView(index, data)
end

function wnd_keep_activity:setWeekBoxView(index, data)
	local widgets = self._layout.vars
	if data then
		self._weekData = data

		local boxData = data.boxData
		local rewardCfg = i3k_db_week_limit_reward_cfg[data.boxID]
		if rewardCfg then
			self.getBtn:onClick(self, self.onGetWeekBoxReward, data.boxID)
			widgets.openBtn:onClick(self, self.onShowWeekReward, data.boxID)

			local redCount = g_i3k_game_context:getWeekLimitBoxRedPointNum(boxData)
			self.getBtn:SetIsableWithChildren(redCount > 0)
			self.getBtnRed:setVisible(redCount > 0)
			if redCount > 0 then
				self.getBtnRed:setImage(g_i3k_db.i3k_db_get_icon_path(LeftRedPoint[redCount]))
			end

			local time = boxData.rewardTime - i3k_game_get_time()
			self.countDownTime:setVisible(boxData.leftTakeCnt <= 0 and time > 0)
			self.timeLabel:setVisible(boxData.leftTakeCnt <= 0 and time > 0)
			if time > 0 then
				self.countDownTime:setText(i3k_get_time_show_text_simple(time))
			end
			local logCnt = isEnable and rewardCfg.args1 or boxData.logCnt
			local str = string.format("(%s/%s)", logCnt, rewardCfg.args1)
			widgets.cond:setText(rewardCfg.taskDesc .. str)
			widgets.cond:setTextColor(logCnt >= rewardCfg.args1 and g_i3k_get_hl_green_color() or g_i3k_get_hl_red_color())

			self:setModel(rewardCfg.model)
		end
	end
end

function wnd_keep_activity:onUpdate(dTime)
	self._poptick = self._poptick + dTime
	if self._openType == WeekLimitBox and self._poptick >= 1 and self._weekData then
		local boxData = self._weekData.boxData

		local redCount = g_i3k_game_context:getWeekLimitBoxRedPointNum(boxData)
		self.getBtn:SetIsableWithChildren(redCount > 0)
		self.getBtnRed:setVisible(redCount > 0)
		if redCount > 0 then
			self.getBtnRed:setImage(g_i3k_db.i3k_db_get_icon_path(LeftRedPoint[redCount]))
		end

		local time = boxData.rewardTime - i3k_game_get_time()
		self.countDownTime:setVisible(boxData.leftTakeCnt <= 0 and time > 0)
		self.timeLabel:setVisible(boxData.leftTakeCnt <= 0 and time > 0)
		if time > 0 then
			self.countDownTime:setText(i3k_get_time_show_text_simple(time))
		end
		
		self._poptick = 0
	end
end

function wnd_keep_activity:setModel(id)
	local cfg = i3k_db_models[id]
	if cfg then
		self.model:setSprite(cfg.path)
		self.model:setSprSize(cfg.uiscale)
		self.model:playAction("stand")
		self.model:setRotation(math.pi/2, -0.2)
	end
end

function wnd_keep_activity:updateWeekTabRed()
	local widgets = self._layout.vars
	widgets.boxRed:setVisible(g_i3k_game_context:isShowWeekLimitBoxRed())
end

function wnd_keep_activity:onGetWeekBoxReward(sender, boxID)
	i3k_sbean.week_treasure_box_take(boxID)
end

function wnd_keep_activity:onShowWeekReward(sender, boxID)
	local rewardCfg = i3k_db_week_limit_reward_cfg[boxID]
	if rewardCfg then
		local dropID = nil
		local randDropID = nil
		--默认最大等级奖励
		local grade = #rewardCfg.levelGrade

		local roleLvl = g_i3k_game_context:GetLevel()
		for i, v in ipairs(rewardCfg.levelGrade) do
			if roleLvl <= v then
				grade = i
				break
			end
		end

		if rewardCfg.taskType == TaskTypeBox then
			dropID = rewardCfg.taskSpecialDrop
		else
			dropID = rewardCfg.drop[grade].dropId
			randDropID = rewardCfg.drop[grade].randDropId
		end

		if randDropID then
			local items = {}
			local randItems = {}

			local drop = g_i3k_db.i3k_db_get_week_box_drop_reward(dropID)
			local randDrop = g_i3k_db.i3k_db_get_week_box_drop_reward(randDropID)
			for i, v in ipairs(drop) do
				table.insert(items, {id = v.dropid, count = v.dropNum})
			end
			for i, v in ipairs(randDrop) do
				table.insert(randItems, {id = v.dropid, count = v.dropNum})
			end

			g_i3k_ui_mgr:OpenUI(eUIID_WeekLimitReward)
			g_i3k_ui_mgr:RefreshUI(eUIID_WeekLimitReward, items, randItems)
		else
			local items = {}
			local drop = g_i3k_db.i3k_db_get_week_box_drop_reward(dropID)
			for i, v in ipairs(drop) do
				table.insert(items, {ItemID = v.dropid, count = v.dropNum})
			end
			g_i3k_ui_mgr:OpenUI(eUIID_RewardTips)
			g_i3k_ui_mgr:RefreshUI(eUIID_RewardTips, items)
		end
	end
end
------end
function wnd_keep_activity:refreshUIData()
	if self._openType ~= LoginReward then
		return
	end
	self.scroll:removeAllChildren()
	local roleType = g_i3k_game_context:GetRoleType()
	local pos = g_i3k_game_context:GetKeepActivityPos()
	self.scroll:setBounceEnabled(false)
	local allWidgets = self.scroll:addChildWithCount(JL_WIDGETS, RowitemCount, #i3k_db_seven_keep_activity)
	for i, e in ipairs(i3k_db_seven_keep_activity) do
		local node = allWidgets[i]
		node.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(e.contentIcon[roleType]))
		node.vars.ask:setImage(g_i3k_db.i3k_db_get_icon_path(e.conditionIcon))
		node.vars.desc:setText(e.name)
		node.vars.redPoint:hide()
		node.vars.isFinish:setVisible(pos >= i)
		node.vars.isSelect:setVisible(i == self._pos)
		if pos >= i and i ~= i3k_db_chuanjiabao.cfg.activityID then
			node.vars.rootNode:disableWithChildren()
		else
			node.vars.rootNode:enableWithChildren()
		end
		local condition = i == pos +1
		condition = condition and (e.type == 1 and g_i3k_game_context:GetLevel() >= e.args or g_i3k_game_context:GetLoginDays() >= e.args)
		local bgIamge = condition and IS_SELECT or NO_SELECT
		node.vars.Bg:setImage(g_i3k_db.i3k_db_get_icon_path(bgIamge))
		node.id = i
		node.vars.itemBtn:onClick(self, self.onRewardInfo, node)
	end
	self:updateBtnState(self._pos)
	self:updateModelState(self._pos)
	self.scroll:jumpToChildWithIndex(self._pos)
end

function wnd_keep_activity:SetScrollData()
	self.scroll:removeAllChildren()
	local roleType = g_i3k_game_context:GetRoleType()
	local pos = g_i3k_game_context:GetKeepActivityPos()
	self.scroll:setBounceEnabled(false)
	local allWidgets = self.scroll:addChildWithCount(JL_WIDGETS, RowitemCount, #i3k_db_seven_keep_activity)
	local heirloom = g_i3k_game_context:getHeirloomData()
	for i, e in ipairs(i3k_db_seven_keep_activity) do
		local node = allWidgets[i]
		node.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_icon_path(e.contentIcon[roleType]))
		node.vars.ask:setImage(g_i3k_db.i3k_db_get_icon_path(e.conditionIcon))
		node.vars.desc:setText(e.name)
		node.vars.redPoint:hide()
		node.vars.isFinish:setVisible(pos >= i)
		if  pos >= i3k_db_chuanjiabao.cfg.activityID and heirloom.isOpen ~= 1 and heirloom.dayWipeTimes < i3k_db_chuanjiabao.cfg.haveTimes then
			if i == i3k_db_chuanjiabao.cfg.activityID  then
				node.vars.isFinish:setVisible(false)
				node.vars.isSelect:setVisible(true)
			else
				node.vars.isSelect:setVisible(false)
			end
		else
			if i == i3k_db_chuanjiabao.cfg.activityID and (heirloom.isOpen ~= 1 or heirloom.isOpen == 1 and heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount)  then
				node.vars.isFinish:setVisible(false)
				node.vars.isSelect:setVisible(false)
			else
				node.vars.isSelect:setVisible(i == pos+1)
			end
		end
		if pos >= i and i ~= i3k_db_chuanjiabao.cfg.activityID or (i == i3k_db_chuanjiabao.cfg.activityID and heirloom.isOpen == 1 and heirloom.perfectDegree == i3k_db_chuanjiabao.cfg.topcount) then
			node.vars.rootNode:disableWithChildren()
		else
			node.vars.rootNode:enableWithChildren()
		end
		local condition = i == pos +1
		condition = condition and (e.type == 1 and g_i3k_game_context:GetLevel() >= e.args or g_i3k_game_context:GetLoginDays() >= e.args)
		local bgIamge = condition and IS_SELECT or NO_SELECT
		node.vars.Bg:setImage(g_i3k_db.i3k_db_get_icon_path(bgIamge))
		node.id = i
		node.vars.itemBtn:onClick(self, self.onRewardInfo, node)
	end
	if pos >= i3k_db_chuanjiabao.cfg.activityID and heirloom.isOpen ~= 1 and (heirloom.dayWipeTimes < i3k_db_chuanjiabao.cfg.haveTimes or not i3k_db_seven_keep_activity[pos +1]) then
		pos = i3k_db_chuanjiabao.cfg.activityID -1
	end
	self:updateBtnState(pos+1)
	self:updateModelState(pos+1)
	self.scroll:jumpToChildWithIndex(pos)
end

function wnd_keep_activity:onRewardInfo(sender, node)
	if self._pos == node.id then
		return
	end
	self:updateBtnState(node.id)
	self:updateModelState(node.id)
	for i, e in ipairs(self.scroll:getAllChildren()) do
		e.vars.isSelect:hide()
	end
	node.vars.isSelect:show()
end

function wnd_keep_activity:updateBtnState(id)
	self._pos = id
	local pos = g_i3k_game_context:GetKeepActivityPos()
	local cfg = i3k_db_seven_keep_activity[id]
	if cfg then
		local desc = self._pos <= pos and "已领取" or "领取奖励"
		if id == i3k_db_chuanjiabao.cfg.activityID then
			desc = "强化解封"
			self.chjb_view:show()
			self:updateArtifactInfo()
		else
			self.chjb_view:hide()
		end
		local conditionText =  cfg.type == 1 and g_i3k_game_context:GetLevel() >= cfg.args or g_i3k_game_context:GetLoginDays() >= cfg.args
		if  not conditionText then
			desc = cfg.type == 1 and string.format("达到%d%s" ,cfg.args,"级") or string.format("登入%d%s",cfg.args,"天")
		end
		self.getText:setText(desc)

		local condition = false
		if cfg.type == 1 then
			condition = g_i3k_game_context:GetLevel() >= cfg.args and self._pos >= pos + 1
			if id == i3k_db_chuanjiabao.cfg.activityID  and pos > i3k_db_chuanjiabao.cfg.activityID - 1 and g_i3k_game_context:GetLevel() >= cfg.args then
				condition = true
			end
		else
			condition = g_i3k_game_context:GetLoginDays() >= cfg.args and self._pos >= pos + 1
		end
		if condition  then
			self.getBtn:enableWithChildren()
			local heirloom = g_i3k_game_context:getHeirloomData()	
			if (heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount) then
				self.getBtn:enableWithChildren();
			elseif id == i3k_db_chuanjiabao.cfg.activityID then
				self.getBtn:disableWithChildren();
			end	
			if heirloom.isOpen == 0 then
				self.getCjbBtn:enableWithChildren()
			else
				self.getCjbBtn:disableWithChildren()
			end
		else
			self.getBtn:disableWithChildren()
			self.getCjbBtn:disableWithChildren()
		end
	end
end

function wnd_keep_activity:updateArtifactInfo()
	if self._openType ~= LoginReward then
		return
	end
	local heirloom = g_i3k_game_context:getHeirloomData()
	self.curCount:setText("完美度："..heirloom.perfectDegree)
	local str = "剩余次数"..(i3k_db_chuanjiabao.cfg.haveTimes - heirloom.dayWipeTimes).."/"..i3k_db_chuanjiabao.cfg.haveTimes.."次"
	if i3k_db_chuanjiabao.cfg.haveTimes == heirloom.dayWipeTimes then
		str = string.format("剩余次数<c=%s>%s</c>/%s次",g_i3k_get_red_color(),(i3k_db_chuanjiabao.cfg.haveTimes - heirloom.dayWipeTimes), i3k_db_chuanjiabao.cfg.haveTimes)
	end
	self.havetimes:setText(str)

	for i = 1 , #self.pros do
		local info = self.pros[i]
		info.name:setText("")
		info.value:setText("")
		info.icon:hide()
	end
	local cfg = {}
	for i = #i3k_db_chuanjiabao.props , 1 , -1 do
		if heirloom.perfectDegree >= i3k_db_chuanjiabao.props[i].wanmeidu  then
			cfg = i3k_db_chuanjiabao.props[i]
			break
		end
	end
	for i = 1 , 3 do
		if cfg["property"..i.."id"] and cfg["property"..i.."id"] > 0  and cfg["property"..i.."value"] > 0 then
			local info = self.pros[i]
			info.name:setText(i3k_db_prop_id[cfg["property"..i.."id"]].desc.."：")
			info.value:setText(cfg["property"..i.."value"])
			info.icon:show()
			info.icon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(cfg["property"..i.."id"])))
		end
	end
end

function wnd_keep_activity:updateModelState(id)
	local cfg = i3k_db_seven_keep_activity[id]
	local roleType = g_i3k_game_context:GetRoleType()
	if cfg then
		local showId = cfg.rewardShow[roleType]
		if cfg.rewardType == 1 then
			ui_set_hero_model(self.model, showId)
			local path = i3k_db_models[showId].path
			local uiscale = i3k_db_models[showId].uiscale
			self.model:setSprite(path)
			self.model:setSprSize(uiscale)
		else
			g_i3k_game_context:SetTestFashionData(showId)
			ui_set_hero_model(self.model, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips())
		end
		for k,v in pairs(cfg.effectList) do
			self.model:pushActionList(v, 1)
		end
		self.model:pushActionList("stand", -1)
		self.model:playActionList()
		if cfg.modelRotation ~= 0 then
			self.model:setRotation(cfg.modelRotation)
		else
			self.model:setRotation(math.pi/2,-0.2)
		end
		if cfg.rewardText == "" then
			self.rewardText:hide()
			self.rewardIcon:show()
			if id == i3k_db_chuanjiabao.cfg.activityID then
				self.rewardIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.rewardIcon[roleType]))
			else
				self.rewardIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.rewardIcon[1]))
			end
		else
			self.rewardText:show()
			self.rewardText:setText(cfg.rewardText)
			self.rewardIcon:hide()
		end
	end
end

function wnd_keep_activity:onReward(sender)
	local pos = g_i3k_game_context:GetKeepActivityPos()
	local cfg = i3k_db_seven_keep_activity[self._pos]
	if cfg then
		if self._pos == pos +1 or  self._pos == i3k_db_chuanjiabao.cfg.activityID  or (pos >= i3k_db_chuanjiabao.cfg.activityID -1 and self._pos == i3k_db_chuanjiabao.cfg.activityID + 1) then
			if self._pos == i3k_db_chuanjiabao.cfg.activityID then
				local heirloom = g_i3k_game_context:getHeirloomData()
				--[[local lvl = g_i3k_game_context:GetLevel();--]]
				if heirloom.perfectDegree < i3k_db_chuanjiabao.cfg.topcount then
					self._layout.vars.getBtn:enableWithChildren();
					g_i3k_ui_mgr:OpenUI(eUIID_OpenArtufact)
					g_i3k_ui_mgr:InvokeUIFunction(eUIID_OpenArtufact,"setType",1)
				end
			else
				local roleType = g_i3k_game_context:GetRoleType()
				local gifts = {}
				for i = 1 , 6 do
					if cfg["itemCount"..i]  and cfg["itemCount"..i]  > 0 then
						gifts[cfg["rewardItem"..i][roleType]] = cfg["itemCount"..i]
					end
				end
				if g_i3k_game_context:IsBagEnough(gifts) then
					i3k_sbean.rmactivity_akereward(self._pos, cfg)
				else
					g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(123))
				end
			end
		else
		 	g_i3k_ui_mgr:PopupTipMessage("请先领取上一个奖励")
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("领取失败")
	end
end

function wnd_keep_activity:onGetChuanjiabao(sender)
	if g_i3k_game_context:GetIsInHomeLandZone() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5092))
	end
	local heirloom = g_i3k_game_context:getHeirloomData()
	if heirloom.isOpen == 0 then
		if heirloom.perfectDegree >= i3k_db_chuanjiabao.cfg.leastcount then
			if heirloom.perfectDegree == i3k_db_chuanjiabao.cfg.topcount then
				g_i3k_ui_mgr:ShowCustomMessageBox1("穿戴", "解封神器已经恢复灵性，现在就穿上与其一起闯荡江湖吧！", function(ok)
					i3k_sbean.getHeirloom()
				end)
			else
				local str = string.format("解封神器已经可以使用，完美度未达\n100％状态（当前%s％），是否取出？\n<c=%s>（取出后可以继续强化，但强化进度将会变慢）</c>",heirloom.perfectDegree,g_i3k_get_red_color())
				g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", str , function(ok)
					if ok then
						i3k_sbean.getHeirloom()
					end
				end)
			end
		else
			g_i3k_ui_mgr:ShowCustomMessageBox1("确定",string.format("神器还没有修复完成，至少要达到%d%s",i3k_db_chuanjiabao.cfg.leastcount,"完美度方可取出"))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage("神器已取出，打开角色装备介面查看")
	end
end

function wnd_keep_activity:onOpenBtn(sender)
	local cfg = i3k_db_seven_keep_activity[self._pos]
	if cfg and cfg.canOpen and cfg.canOpen == 1 then
		local roleType = g_i3k_game_context:GetRoleType()
		local items = {}
		for i = 1 ,6 do
			if cfg["itemCount"..i] and cfg["itemCount"..i] > 0 then
				local t = {ItemID = cfg["rewardItem"..i][roleType], count = cfg["itemCount"..i]}
				table.insert(items, t)
			end
		end
		g_i3k_ui_mgr:OpenUI(eUIID_RewardTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_RewardTips,items)
	end
end

function wnd_keep_activity:callback( )
	if self._openType ~= LoginReward then
		return
	end
	self.model:pushActionList("get", 1)
	self.model:pushActionList("stand", -1)
	self.model:playActionList()
	self.getCjbBtn:disableWithChildren()
end

function wnd_keep_activity:onClose(sender)
	g_i3k_game_context:ResetTestFashionData()
	ui_set_hero_model(self.model, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion())
	g_i3k_ui_mgr:CloseUI(eUIID_KeepActivity)
end

function wnd_create(layout)
	local wnd = wnd_keep_activity.new()
	wnd:create(layout)
	return wnd
end
