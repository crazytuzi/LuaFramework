
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_singleChallengeFailed = i3k_class("wnd_singleChallengeFailed",ui.wnd_base)

function wnd_singleChallengeFailed:ctor()

end

function wnd_singleChallengeFailed:configure()
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

function wnd_singleChallengeFailed:onClose(sender)
	i3k_sbean.mapcopy_leave(eUIID_SingleChallengeFailed)
end

function wnd_singleChallengeFailed:refresh(rewards, mapId, settlement)
	self:reload(rewards, mapId, settlement)
	local oldMapId = g_i3k_game_context:GetWorldMapID()
	local function callbackfun()
		local id, npcgroupId = g_i3k_game_context:getSingleChallengeInfo()
		for _, v in ipairs(npcgroupId) do
			if i3k_db_rightHeart2[mapId] and i3k_db_rightHeart2[mapId].npcgroupId == v then
				i3k_sbean.single_explore_sync(id)
				break
			end
		end
	end
	local mapType = g_i3k_game_context:GetWorldMapType()
	if mapType == g_RIGHTHEART then
		g_i3k_game_context:SetMapLoadCallBack(callbackfun)
	end
end

function wnd_singleChallengeFailed:onHide()
	
end

function wnd_singleChallengeFailed:reload(rewards, mapId, settlement)
	if settlement then
		self.difficultyLabel:setText("普通")
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

function wnd_singleChallengeFailed:updateSchedule(haveTime)
	local str = string.format("%s秒后退出副本", haveTime)
	self.daojishi:setText(str)
end

function wnd_create(layout, ...)
	local wnd = wnd_singleChallengeFailed.new()
	wnd:create(layout, ...)
	return wnd;
end

