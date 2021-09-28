
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_luckyPackTip = i3k_class("wnd_luckyPackTip",ui.wnd_base)

local wenhaoImg = 5556 --随机道具图标

function wnd_luckyPackTip:ctor()

end

function wnd_luckyPackTip:configure()
	local widgets = self._layout.vars
	widgets.closeBtn:onClick(self, self.onCloseUI)

	self.ui = widgets
end

function wnd_luckyPackTip:refresh(id)
	local cfg = i3k_db_lucky_pack_reward[id]
	local heroLvl = g_i3k_game_context:GetLevel()
	local index = 1
	for i, v in ipairs(cfg and cfg.levels or {}) do
		if v > heroLvl then
			index = i
			break
		end
	end
	local dropInfo = cfg["drop" .. index]
	if dropInfo then
		local itemid = i3k_db_drop_cfg[dropInfo.dropId].dropid
		local num =  i3k_db_drop_cfg[dropInfo.dropId].dropNumMax
		if itemid ~= 0 and num > 0 then
			self.ui.item_bg1:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemid))
			self.ui.item_icon1:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemid, g_i3k_game_context:IsFemaleRole()))
			self.ui.itemName1:setText(g_i3k_db.i3k_db_get_common_item_name(itemid) .. "*" .. num)
			local name_color = g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(itemid))
			self.ui.itemName1:setTextColor(name_color)
		end

		local randNum = dropInfo.randDropCnt
		self.ui.itemName2:setText("随机掉落" .. "*" .. randNum)
		self.ui.item_icon2:setImage(g_i3k_db.i3k_db_get_icon_path(wenhaoImg))
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_luckyPackTip.new()
	wnd:create(layout, ...)
	return wnd;
end

