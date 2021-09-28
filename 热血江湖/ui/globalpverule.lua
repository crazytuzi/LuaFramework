-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_globalPveRule = i3k_class("wnd_globalPveRule",ui.wnd_base)

local SDYJMGZT3 = "ui/widgets/sdymjgzt3"

function wnd_globalPveRule:ctor()
	self._isPeace = true
end

function wnd_globalPveRule:configure()
	local widgets = self._layout.vars
	self.titleIcon = widgets.titleIcon
	self.scroll = widgets.scroll
	self.monsterDesc = widgets.monsterDesc
	self.monsterScroll = widgets.monsterScroll
	self.bossDesc = widgets.bossDesc
	self.bossScroll = widgets.bossScroll
	widgets.closeBtn:onClick(self, self.onCloseUI)
end


function wnd_globalPveRule:refresh(ruleType)
	self._isPeace = ruleType == g_FIELD_SAFE_AREA
	local titleIconID = self._isPeace and 5761 or 5767
	self.titleIcon:setImage(g_i3k_db.i3k_db_get_icon_path(titleIconID))
	self:loadRuleDesc(self._isPeace and i3k_get_string(1316) or i3k_get_string(1317))
	self.monsterDesc:setText(self._isPeace and i3k_get_string(1318) or i3k_get_string(1320))
	self.bossDesc:setText(self._isPeace and i3k_get_string(1319) or i3k_get_string(1321))
	self:loadRewardScrollData()
end

--规则
function wnd_globalPveRule:loadRuleDesc(txt)
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		local gzText = require("ui/widgets/bzt1")()
		gzText.vars.text:setText(txt)
		ui.scroll:addItem(gzText)
		g_i3k_ui_mgr:AddTask(self, {gzText}, function(ui)
			local textUI = gzText.vars.text
			local size = gzText.rootVar:getContentSize()
			local height = textUI:getInnerSize().height
			local width = size.width
			height = size.height > height and size.height or height
			gzText.rootVar:changeSizeInScroll(ui.scroll, width, height, true)
		end, 1)
	end, 1)
end

function wnd_globalPveRule:loadRewardScrollData()	
	local monsterCfg = self._isPeace and i3k_db_peaceMapSmallMonsterReward or i3k_db_battleMapbossReward
	local bossCfg = self._isPeace and i3k_db_peaceMapBossReward or i3k_db_battleMapSuperBossReward
	self:loadDropScroll(monsterCfg, self.monsterScroll)
	self:loadDropScroll(bossCfg, self.bossScroll)
end

function wnd_globalPveRule:loadDropScroll(cfg, scroll)
	scroll:removeAllChildren()
	for _, e in ipairs(cfg) do
		local node = require(SDYJMGZT3)()
		local widget = node.vars
		widget.bgIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(e.itemID))
		widget.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(e.itemID, g_i3k_game_context:IsFemaleRole()))
		widget.isShareIcon:setVisible(e.isShared == 1)
		widget.btn:onClick(self, function ()
			g_i3k_ui_mgr:ShowCommonItemInfo(e.itemID)
		end)
		scroll:addItem(node)
	end
end

function wnd_create(layout)
	local wnd = wnd_globalPveRule.new()
	wnd:create(layout)
	return wnd
end
