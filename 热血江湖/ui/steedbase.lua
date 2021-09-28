-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_steedBase = i3k_class("wnd_steedBase", ui.wnd_base)

function wnd_steedBase:configure()
	local widgets 		= self._layout.vars
	widgets.steedBtn:onClick(self, function()
		g_i3k_logic:OpenSteedUI()
	end)
	widgets.steedSkinBtn:onClick(self, function()
		g_i3k_logic:OpenSteedSkinUI(true)
	end)
	widgets.masterBtn:onClick(self, g_i3k_logic.OpenSteedFightUI)
	widgets.spiritBtn:onClick(self, g_i3k_logic.OpenSteedSpriteUI)
	widgets.equipBtn:onClick(self, g_i3k_logic.OpenSteedEquipUI)
	widgets.suitBtn:onClick(self, function()
		g_i3k_logic:OpenSteedSuitUI()
	end)
	widgets.stoveBtn:onClick(self, g_i3k_logic.OpenSteedStoveUI)
	widgets.steedFightBtn:stateToPressed()
	widgets.helpBtn:onClick(self, self.onHelpBtn)
	widgets.closeBtn:onClick(self, self.onCloseUI)
	self:updateSteedRed()
	self:setButtonColor(widgets)
end

-- 骑战相关btn按钮颜色优化
function wnd_steedBase:setButtonColor(widgets)
	local textColor = { -- 页签文本颜色 选择和为被选中状态
		{"ffcf571c", "ffffd27c"}, -- 主色和描边
		{"ffffc898", "ffa06448"}
	}
	local buttonType = {
		widgets.masterBtn, 
		widgets.spiritBtn, 
		widgets.equipBtn, 
		widgets.suitBtn, 
		widgets.stoveBtn, 
	}
	for _, btn in ipairs(buttonType) do
		btn:setTitleTextColor(textColor)
	end
end


function wnd_steedBase:updateSteedRed()
	local widgets = self._layout.vars
	widgets.steed_point:setVisible(g_i3k_game_context:canBetterSteed() or g_i3k_game_context:canAddBook())
	widgets.fightRedPoint:setVisible(g_i3k_game_context:getIsShowSteedFightRed())
	widgets.enhanceRed:setVisible(g_i3k_game_context:canfightSteedRed())
	widgets.spiritRed:setVisible(g_i3k_game_context:getIsShowSteedSpiritRed())
	widgets.equipRed:setVisible(g_i3k_game_context:getSteedEquipRed())
	widgets.suitRed:setVisible(g_i3k_game_context:getSteedEquipSuitRed())
	widgets.stoveRed:setVisible(g_i3k_game_context:getSteedEquipStoveRed())
end

function wnd_steedBase:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1264))
end

function wnd_create(layout)
	local wnd = wnd_steedBase.new();
		wnd:create(layout);
	return wnd;
end
