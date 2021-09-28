------------------------------------------------------
module(...,package.seeall)

local require = require

local ui = require('ui/base')
------------------------------------------------------
wnd_xiulianzhimen_fuben_jiesuan = i3k_class("wnd_xiulianzhimen_fuben_jiesuan",ui.wnd_base)

local ITEM_WIDGET = "ui/widgets/xlzmicon"
local DUNGEON_ID = 37 --对应 i3k_db_NpcDungeon id
function wnd_xiulianzhimen_fuben_jiesuan:configure()
	self._layout.vars.exitBtn:onClick(self,self.onExitBtnClick)
end

function wnd_xiulianzhimen_fuben_jiesuan:refresh(info)
	local widgets = self._layout.vars
	local buffs, monsterRound = g_i3k_game_context:GetPracticeGateData()
	local dungeonCfg = i3k_db_dungeon_practice_door[info.mapId]
	local practiceCfg = i3k_db_practice_door_award[monsterRound or 0]
	local roleLevel = g_i3k_game_context:GetLevel()
	local getBuffRate = function(buffType)
		return buffs[buffType] and buffs[buffType] * i3k_db_team_buff[buffType].value / 10000 or 0
	end
	local getRateShowTxt = function(rate)
		return ((rate + 1) * 100) .. "%"
	end
	local extraCoinRate = g_i3k_db.i3k_db_get_practice_door_extra_buff_addition(g_TEAM_BUFF_RESULT_COIN, buffs[g_TEAM_BUFF_RESULT_COIN] or 0) / 100
	local extraExpRate = g_i3k_db.i3k_db_get_practice_door_extra_buff_addition(g_TEAM_BUFF_RESULT_EXP, buffs[g_TEAM_BUFF_RESULT_EXP] or 0) / 100
	local extraItemRate = g_i3k_db.i3k_db_get_practice_door_extra_buff_addition(g_TEAM_BUFF_RESULT_ITEM, buffs[g_TEAM_BUFF_RESULT_ITEM] or 0) / 100
	widgets.finishTime:setText(i3k_get_show_rest_time(info.finishTime))
	widgets.percent:setText(i3k_get_string(15409, monsterRound))
	widgets.expRate:setText(getRateShowTxt(extraExpRate))
	widgets.coinRate:setText(getRateShowTxt(extraCoinRate))
	widgets.itemRate:setText(getRateShowTxt(extraItemRate))

	local haveAward = g_i3k_game_context:getNpcDungeonEnterTimes(DUNGEON_ID) <= i3k_db_NpcDungeon[DUNGEON_ID].joinCnt	
	local baseCoin, baseExp, baseAwards
	if haveAward then
		baseCoin = math.ceil(dungeonCfg.coinAward * practiceCfg.coinRate / 10000)
		baseExp = math.ceil(i3k_db_exp[roleLevel].practiceGateExpRate * practiceCfg.expRate / 10000)
		baseAwards = practiceCfg.awards
	else
		baseCoin = 0
		baseExp = 0
		baseAwards = {}
	end
	local extraCoin = math.ceil(baseCoin * extraCoinRate)
	local extraExp = math.ceil(baseExp * extraExpRate)
	local extraAwards = {}
	for i, v in ipairs(baseAwards) do
		extraAwards[i] = {
			id = v.id,
			count = math.ceil(v.count * extraItemRate)
		}
	end
	widgets.expLabel:setText(baseExp)
	widgets.expLabel2:setText(extraExp)
	widgets.coinLabel:setText(baseCoin)
	widgets.coinLabel2:setText(extraCoin)
	widgets.scroll:removeAllChildren()
	widgets.scroll2:removeAllChildren()
	for i, v in ipairs(baseAwards) do
		local ITEM = require(ITEM_WIDGET)()
		ITEM.vars.itemBtn:onClick(ITEM.vars.itemBtn, self.onItemTips, v.id)
		ITEM.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v.id))
		ITEM.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, i3k_game_context:IsFemaleRole()))
		ITEM.vars.num:setText(v.count)
		ITEM.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		widgets.scroll:addItem(ITEM)
	end
	for i, v in ipairs(extraAwards) do
		if v.count > 0 then
			local ITEM = require(ITEM_WIDGET)()
			ITEM.vars.itemBtn:onClick(ITEM.vars.itemBtn, self.onItemTips, v.id)
			ITEM.vars.suo:setVisible(g_i3k_db.i3k_db_get_consume_lock_visible(v.id))
			ITEM.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id, i3k_game_context:IsFemaleRole()))
			ITEM.vars.num:setText(v.count)
			ITEM.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
			widgets.scroll2:addItem(ITEM)
		end
	end
end

function wnd_xiulianzhimen_fuben_jiesuan:onExitBtnClick(sender)
	i3k_sbean.mapcopy_leave()
end

function wnd_xiulianzhimen_fuben_jiesuan:onItemTips(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_xiulianzhimen_fuben_jiesuan:updateSchedule(haveTime)
	local str = string.format("%d秒后退出副本", haveTime)
	self._layout.vars.timeCount:setText(str)
end
---------------------------------------------------------
function wnd_create(layout,...)
	local wnd = wnd_xiulianzhimen_fuben_jiesuan.new()
	wnd:create(layout,...)
	return wnd
end
