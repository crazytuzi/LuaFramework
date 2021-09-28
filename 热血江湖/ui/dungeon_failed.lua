-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_dungeon_failed = i3k_class("wnd_dungeon_failed",ui.wnd_base)

function wnd_dungeon_failed:ctor()
	
end

function wnd_dungeon_failed:configure()
	local widgets = self._layout.vars
	
	self.daojishi = widgets.daojishi
	self.difficultyLabel = widgets.difficulty
	self.finishTimeLabel = widgets.finishTime
	self.deadTimesLabel = widgets.deadTimes
	self.killMonstersLabel = widgets.killMonsters
	
	self.expLabel = widgets.expLabel
	self.coinLabel = widgets.coinLabel
	
	self.scroll = widgets.scroll
	widgets.exitBtn:onClick(self, self.onClose)
end


function wnd_dungeon_failed:onClose(sender)
	i3k_sbean.mapcopy_leave(eUIID_DungeonFailed)
end

function wnd_dungeon_failed:refresh(rewards, mapId, settlement)
	self:reload(rewards, mapId, settlement)
	local oldMapId = g_i3k_game_context:GetWorldMapID()
	local function callbackfun()
		g_i3k_logic:OpenDungeonUI(i3k_db_new_dungeon[mapId].openType == g_BASE_DUNGEON, oldMapId)
	end
	g_i3k_game_context:SetMapLoadCallBack(callbackfun)
end

function wnd_dungeon_failed:onHide()
	
end

function wnd_dungeon_failed:reload(rewards, mapId, settlement)
	if settlement then
		local dungeon = i3k_db_new_dungeon[mapId]
		if dungeon then
			local difficultDes = ""
			local difficult = dungeon.difficulty
			if difficult == 0 then
				difficultDes = "组队"
			elseif difficult == 1 then
				difficultDes = "剧情"
			elseif difficult == 2 then
				difficultDes = "普通"
			elseif difficult == 3 then
				difficultDes = "困难"
			end
			self.difficultyLabel:setText(difficultDes)
		end
		self.finishTimeLabel:setText(settlement.finishTime.."秒")
		self.deadTimesLabel:setText(settlement.deadTimes.."次")
		self.killMonstersLabel:setText("x"..settlement.killMonsters)

		self.expLabel:setText("+"..rewards.exp)
		self.coinLabel:setText("+"..rewards.coin)
		
		local normalRewards = rewards.normalRewards
		self.scroll:setBounceEnabled(false)
		for i,v in ipairs(normalRewards) do
			local node = require("ui/widgets/dj1")()
			local id = v.id
			local path = g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole())
			node.vars.item_icon:setImage(path)
			local test = g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id)
			node.vars.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
			node.vars.item_count:setText(v.count)
			self.scroll:addItem(node)
		end
	end
end

function wnd_dungeon_failed:updateSchedule(haveTime)
	local str = string.format("%s秒后退出副本", haveTime)
	self.daojishi:setText(str)
end

function wnd_create(layout)
	local wnd = wnd_dungeon_failed.new()
		wnd:create(layout)
	return wnd
end
