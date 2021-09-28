module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_swornModify = i3k_class("wnd_swornModify", ui.wnd_base)

local ROLEWIDGET = "ui/widgets/jiebaijmt"
local ALLREWARDS = 5

function wnd_swornModify:ctor()
	self._data = {}
	self._roleData = {}
end

function wnd_swornModify:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.call_btn:onClick(self, self.onCallBtn)
	widgets.jinlanpu:onClick(self, self.onJinLanPu)
	widgets.changePrefixBtn:onClick(self, self.onChangePrefixBtn)
	for i = 1, ALLREWARDS do
		widgets["reward_btn"..i]:onTouchEvent(self, self.onActivityRewards, i)
	end
	widgets.sworn_value_btn:onClick(self, self.onSwornValueBtn)
	widgets.achievement:onClick(self, self.showAchievement)
end

function wnd_swornModify:refresh(data, roleData)
	self._data = data
	self._roleData = roleData
	self:setSwornFriendsScroll()
	self:setSwornFriendsData()
	self:setSwornAcitivityReward()
	self:updateReddot()
end
function wnd_swornModify:updateReddot()
	local sworn = g_i3k_game_context
	self._layout.vars.achiReddot:setVisible(sworn.taskPush)
end

function wnd_swornModify:sortSwornData()
	local swornFriends = {}
	for k, v in pairs(self._data.roles) do
		table.insert(swornFriends, v)
	end
	table.sort(swornFriends, function(a, b)
		if a.birthday ~= b.birthday then
			return a.birthday < b.birthday
		else
			return a.role.id < b.role.id
		end
	end)
	return swornFriends
end

function wnd_swornModify:setSwornFriendsScroll()
	local swornFriends = self:sortSwornData()
	self._layout.vars.scroll:removeAllChildren()
	local isBigger = 1
	for k, v in ipairs(swornFriends) do
		local isSelf = false
		local node = require(ROLEWIDGET)()
		if v.role.id == g_i3k_game_context:GetRoleId() then
			isBigger = 0
			isSelf = true
			node.vars.changeBtn:show()
			node.vars.changeBtn:onClick(self, self.onChangeSuffixBtn)
			node.vars.bg:show()
			node.vars.rankText:setTextColor("fffff335")
			node.vars.roleName:setTextColor("fffff335")
			node.vars.activity:setTextColor("fffff335")
			node.vars.swornName:setTextColor("fffff335")
		else
			node.vars.changeBtn:hide()
			node.vars.bg:hide()
			node.vars.rankText:setTextColor("ffe6f1ff")
			node.vars.roleName:setTextColor("ff45426f")
			node.vars.activity:setTextColor("ff45426f")
			node.vars.swornName:setTextColor("ffffffff")
		end
		local orderInfo = g_i3k_db.i3k_db_get_title_orderSeatId_bySelfIndex(k, v.role.gender, (isSelf and k == 1) and 1 or isBigger)
		node.vars.rankText:setText(orderInfo.notes)
		node.vars.roleName:setText(v.role.name)
		node.vars.activity:setText(i3k_get_string(5434) .. v.dayActivity)
		node.vars.swornName:setText(self._data.prefix .. v.suffix)
		node.vars.swornName:enableOutline("ff66628c")
		node.vars.profession:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[v.role.type].classImg))
		node.vars.headIcon:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_head_icon_ex(v.role.headIcon,g_i3k_db.eHeadShapeCircie)))
		self._layout.vars.scroll:addItem(node)
	end
end

function wnd_swornModify:setSwornFriendsData()
	self._layout.vars.sworn_value:setText(self._data.swornValue)
	self._layout.vars.prefix_txt:setText(self._data.prefix)
	local index = 0
	for k, v in ipairs(i3k_db_sworn_value) do
		if self._data.swornValue < v.swornValue then
			break
		else
			index = k
		end
	end
	if index == 0 then
		self._layout.vars.title_icon:hide()
		self._layout.vars.extra_exp:setText(i3k_get_string(5419).."0%")
	else
		local titleId = i3k_db_sworn_value[index].titleId
		local title = i3k_db_title_base[titleId]
		self._layout.vars.title_icon:setImage(g_i3k_db.i3k_db_get_icon_path(title.iconbackground))
		self._layout.vars.chmc:setImage(g_i3k_db.i3k_db_get_icon_path(title.name))
		self._layout.vars.extra_exp:setText(i3k_get_string(5419)..(i3k_db_sworn_value[index].expAddition/100).."%")
	end
end

function wnd_swornModify:setSwornAcitivityReward()
	--self._data.activity
	local percent = 0
	local isFirst = true
	for i = 1, ALLREWARDS do
		local ani = nil
		if i == 1 then
			ani = self._layout.anis.c_bx
		else
			ani = self._layout.anis["c_bx"..i]
		end
		ani.stop()
		local reward = i3k_db_sworn_actRewards[i]
		if reward then
			self._layout.vars["reward_txt"..i]:setText(reward.actValue)
			if self._roleData.dayReward[reward.actValue] then
				self._layout.vars["reward_get_icon"..i]:show()
				self._layout.vars["reward_icon"..i]:hide()
			elseif self._data.activity >= reward.actValue then
				self._layout.vars["reward_get_icon"..i]:hide()
				self._layout.vars["reward_icon"..i]:show()
				ani.play()
			else
				self._layout.vars["reward_get_icon"..i]:hide()
				self._layout.vars["reward_icon"..i]:show()
			end
			if self._data.activity >= reward.actValue then
				percent = percent + 1.0 / ALLREWARDS
			else
				if isFirst then
					if i > 1 then
						percent = percent + 1.0 / ALLREWARDS * (self._data.activity - i3k_db_sworn_actRewards[i - 1].actValue) / (reward.actValue - i3k_db_sworn_actRewards[i - 1].actValue)
					else
						percent = percent + 1.0 / ALLREWARDS * self._data.activity / reward.actValue
					end
					isFirst = false
				end
			end
		end
	end
	percent = percent * 100
	self._layout.vars.loading:setPercent(percent > 100 and 100 or percent)
end

function wnd_swornModify:onChangeSuffixBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SwornChangeName)
	g_i3k_ui_mgr:RefreshUI(eUIID_SwornChangeName, false, self._data)
end

function wnd_swornModify:onChangePrefixBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SwornChangeName)
	g_i3k_ui_mgr:RefreshUI(eUIID_SwornChangeName, true, self._data)
end

function wnd_swornModify:onActivityRewards(sender, eventType, index)
	if eventType == ccui.TouchEventType.began then
		if self._data.activity < i3k_db_sworn_actRewards[index].actValue then
			g_i3k_ui_mgr:OpenUI(eUIID_Schedule_Tips)
			g_i3k_ui_mgr:RefreshUI(eUIID_Schedule_Tips, i3k_db_sworn_actRewards[index], 4)
		end
	elseif eventType == ccui.TouchEventType.moved then
	else
		if self._data.activity < i3k_db_sworn_actRewards[index].actValue then
			g_i3k_ui_mgr:CloseUI(eUIID_Schedule_Tips)
		elseif not self._roleData.dayReward[i3k_db_sworn_actRewards[index].actValue] then
			if g_i3k_game_context:checkBagCanAddCell(3, true) then
				i3k_sbean.sworn_activity_reward_take(i3k_db_sworn_actRewards[index].actValue)
			end
		end
	end
end

function wnd_swornModify:onSwornValueBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SwornValueDesc)
	g_i3k_ui_mgr:RefreshUI(eUIID_SwornValueDesc, self._data.swornValue)
end

function wnd_swornModify:onCallBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SwornCallFriends)
	g_i3k_ui_mgr:RefreshUI(eUIID_SwornCallFriends, self._data, self._roleData)
end

function wnd_swornModify:onJinLanPu(sender)
	i3k_sbean.get_sworn_card(self._data.id, false, g_i3k_game_context:GetRoleId())
		end

function wnd_swornModify:showAchievement(sender)
	g_i3k_game_context:syncData(function() 
		g_i3k_ui_mgr:OpenAndRefresh(eUIID_JinLanAchievement)
	end)
end
function wnd_create(layout)
	local wnd = wnd_swornModify.new()
	wnd:create(layout)
	return wnd
end
