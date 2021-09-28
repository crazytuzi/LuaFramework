-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------爬塔通关失败

wnd_fiveUnique_failed = i3k_class("wnd_fiveUnique_failed",ui.wnd_base)



function wnd_fiveUnique_failed:ctor()

end

function wnd_fiveUnique_failed:configure()
	self._layout.vars.exitBtn:onClick(self,self.onClose)
	self._layout.vars.show_difficulty1:hide()
	self._layout.vars.show_difficulty2:hide()
	self._layout.vars.show_difficulty3:hide()
	self._layout.vars.show_difficulty4:hide()
	
	self.expLabel = self._layout.vars.expLabel
	self.coinLabel = self._layout.vars.coinLabel
	self.scroll =  self._layout.vars.scroll

end


function wnd_fiveUnique_failed:onClose(sender)
	i3k_sbean.mapcopy_leave(eUIID_FiveUniqueFailed)
end

function wnd_fiveUnique_failed:refresh(rewards, mapId, settlement)
	self:reload(rewards, mapId, settlement)
	local oldMapId = g_i3k_game_context:GetWorldMapID()--g_i3k_logic:OpenTowerUI()
	
	local callbackfun = function()
		g_i3k_logic:OpenTowerUI(true)
	end
	g_i3k_game_context:SetMapLoadCallBack(callbackfun)
end

function wnd_fiveUnique_failed:reload(rewards, mapId, settlement)
	if settlement then

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

function wnd_fiveUnique_failed:updateSchedule(haveTime)
	local str = string.format("%d秒后退出副本", haveTime)
	self._layout.vars.daojishi:setText(str)
end

function wnd_create(layout, ...)
	local wnd = wnd_fiveUnique_failed.new()
		wnd:create(layout, ...)
	return wnd
end
		
