-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_swordsman_friendship = i3k_class("wnd_swordsman_friendship", ui.wnd_base)

local FRIENDSHIP = "ui/widgets/daxiajlt"

function wnd_swordsman_friendship:ctor()
	
end

function wnd_swordsman_friendship:configure()
	self._layout.vars.close_btn:onClick(self, self.onCloseUI)
end

function wnd_swordsman_friendship:refresh()
	local info = g_i3k_game_context:getSwordsmanCircleData()
	self._layout.vars.scroll:removeAllChildren()
	for k, v in ipairs(i3k_db_swordsman_circle_reward) do
		local node = require(FRIENDSHIP)()
		node.vars.rewardCondition:setText(i3k_get_string(18330, v.friendShipName))
		if table.indexof(info.friendshipRewards, k) then
			node.vars.takeBtn:hide()
			node.vars.isTaskIcon:show()
		elseif info.friendshipLvl >= k then
			node.vars.takeBtn:show()
			node.vars.takeBtn:onClick(self, self.onTakeReward, k)
			node.vars.takeText:setText(i3k_get_string(18321))
			node.vars.isTaskIcon:hide()
		else
			node.vars.isTaskIcon:hide()
			node.vars.takeBtn:show()
			node.vars.takeBtn:disableWithChildren()
			node.vars.takeText:setText(i3k_get_string(18321))
		end
		for i = 1, 4 do
			if v.rewards[i].id ~= 0 then
				node.vars["itemBg"..i]:show()
				node.vars["itemBg"..i]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.rewards[i].id))
				node.vars["itemIcon"..i]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.rewards[i].id, g_i3k_game_context:IsFemaleRole()))
				node.vars["itemBtn"..i]:onClick(self, self.onItemTips, v.rewards[i].id)
				node.vars["itemCount"..i]:setText(v.rewards[i].count)
				node.vars["lock"..i]:setVisible(v.rewards[i].id > 0)
			else
				node.vars["itemBg"..i]:hide()
			end
		end
		self._layout.vars.scroll:addItem(node)
	end
end

function wnd_swordsman_friendship:onTakeReward(sender, index)
	local rewards = {}
	local items = {}
	for k, v in ipairs(i3k_db_swordsman_circle_reward[index].rewards) do
		if v.id ~= 0 then
			table.insert(rewards, {id = v.id, count = v.count})
			items[v.id] = v.count
		end
	end
	if g_i3k_game_context:IsBagEnough(items) then
		i3k_sbean.friend_circle_take_friendship_reward(index, rewards)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(43))
	end
end

function wnd_swordsman_friendship:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_create(layout)
	local wnd = wnd_swordsman_friendship.new()
	wnd:create(layout)
	return wnd
end