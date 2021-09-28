
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_MMRankReward = i3k_class("wnd_MMRankReward",ui.wnd_base)

function wnd_MMRankReward:ctor()

end

function wnd_MMRankReward:configure()
	self.ui = self._layout.vars
	self.ui.close_btn:onClick(self, self.onCloseUI)
end

function wnd_MMRankReward:refresh()
	local cfg = i3k_db_magic_machine.rankRewards
	local isGirl = g_i3k_game_context:IsFemaleRole()
	self.ui.scroll:removeAllChildren();
	
	for _, v in ipairs(cfg) do
		local wg = require("ui/widgets/shenjizanghaijlt")()
		local wgs = wg.vars
		wgs.rank:setText(v.showTxt)
		for k = 1, 4 do
			if v.rewards[k] then
				local id = v.rewards[k].id
				local cnt = v.rewards[k].count
				wgs["icon"..k]:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id, isGirl))
				wgs["temp"..k]:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
				wgs["btn"..k]:onClick(self, function() g_i3k_ui_mgr:ShowCommonItemInfo(id) end)
				wgs["cnt"..k]:setText("x"..cnt)
			else
				wgs["temp"..k]:setVisible(false)
			end
		end
		self.ui.scroll:addItem(wg)
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_MMRankReward.new()
	wnd:create(layout, ...)
	return wnd;
end

