-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_robber_monster = i3k_class("wnd_robber_monster",ui.wnd_base)

local JIANGHUDADAT = ("ui/widgets/jiangyangdadaot")

function wnd_robber_monster:ctor()
	self._id = 0 
end

function wnd_robber_monster:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)
	self.name = widgets.name
	self.level = widgets.level
	self.behavior = widgets.behavior
	self.scroll = widgets.scroll
	self.model = widgets.model
	self.leftTime = widgets.leftTime
	self.gotoBtn = widgets.gotoBtn
	self.descTxt = widgets.descTxt
	self.killerBtn = widgets.killerBtn
	self.killerDesc = widgets.killerDesc
	self.gotoBtn:onClick(self, self.onTransport)
end

function wnd_robber_monster:refresh(data)
	local info = data.info
	self._id = info.id

	self.name:setText(data.name)
	self.level:setText(i3k_get_string(16818, info.level))
	local str = ""
	local behavior = info.behavior
	if behavior == g_ROBBER_SLEEP then -- 睡觉
		str = i3k_get_string(16814)
	elseif behavior == g_ROBBER_WANDER then -- 游荡
		local mapID = i3k_db_robber_monster_pos[info.posID].mapID
		str = i3k_get_string(16813, i3k_db_dungeon_base[mapID].desc)
	elseif behavior == g_ROBBER_TASK then
		if i3k_db_robber_monster_task[info.taskID].isHaveArg == 0 then
			str = i3k_db_robber_monster_task[info.taskID].taskDesc
		else
			str = string.format(i3k_db_robber_monster_task[info.taskID].taskDesc, data.name)
		end
	end
	self.behavior:setText(str)
	local monsterType = i3k_db_robber_monster_cfg[info.id].monsterType
	local monsterID = i3k_db_robber_monster_type[monsterType][info.level].monsterID
	ui_set_hero_model(self.model, g_i3k_db.i3k_db_get_monster_modelID(monsterID))
	self.leftTime:setVisible(behavior ~= g_ROBBER_SLEEP)
	self.leftTime:setText(i3k_get_string(16851, self:getTimeDesc(info.leftTime)))
	if behavior ~= g_ROBBER_WANDER then
		self.gotoBtn:disableWithChildren()
	end
	self.descTxt:setText(i3k_get_string(16865))
	self:loadItemScroll(info.goods)
	self.killerDesc:setVisible(info.lastKillerID > 0)
	self.killerBtn:setVisible(info.lastKillerID > 0)
	self.killerBtn:onClick(self, self.onKillerBtn, info)
end

-- 物品
function wnd_robber_monster:loadItemScroll(goods)
	self.scroll:removeAllChildren()
	local  items = self:sortItems(goods)
	local allWidget = self.scroll:addChildWithCount(JIANGHUDADAT, 5, #items)
	for i, e in ipairs(allWidget) do
		local id = items[i].id
		local count = items[i].count
		e.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, g_i3k_game_context:IsFemaleRole()))
		e.vars.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
		e.vars.count:setText(string.format("x%s", count))
		e.vars.bt:onClick(self, self.onItemTips, id)
	end
end

function wnd_robber_monster:sortItems(goods)
	local items = {}
	for k, v in pairs(goods) do
		local rank = g_i3k_db.i3k_db_get_common_item_rank(k)
		table.insert(items, {id = k, count = v, rank = rank})
	end
	table.sort(items, function(a, b)
		return a.rank > b.rank
	end)
	return items
end

function wnd_robber_monster:onItemTips(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_robber_monster:onTransport(sender)
	if not g_i3k_game_context:CheckCanTrans(i3k_db_common.activity.transNeedItemId, 1) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16860))
		return
	end
	local function func()
		g_i3k_game_context:ClearFindWayStatus()
		i3k_sbean.robbermonster_tele(self._id)
	end
	g_i3k_game_context:CheckMulHorse(func)
end

function wnd_robber_monster:getTimeDesc(time)
	if time <= 0 then
		return string.format("%d秒", 0)
	end
	if time < 60 then --小于1分钟
		local sec = time
		return string.format("%d秒", sec)
	elseif time < 60*60 then --小于1小时
		local min =  math.floor(time/60)
		return string.format("%d分", min)
	elseif time < 60*60*24 then --小于1天
		local hour =  math.floor(time/60/60)
		local min =  math.floor(time/60) - hour * 60
		return string.format("%d小时%d分", hour, min)
	else
		local day =  math.floor(time/60/60/24)
		return string.format("%d天", day)
	end
end

function wnd_robber_monster:onKillerBtn(sender, data)
	g_i3k_ui_mgr:OpenUI(eUIID_RobberMonsterKiller)
	g_i3k_ui_mgr:RefreshUI(eUIID_RobberMonsterKiller, data)
end

function wnd_create(layout)
	local wnd = wnd_robber_monster.new()
	wnd:create(layout)
	return wnd
end
