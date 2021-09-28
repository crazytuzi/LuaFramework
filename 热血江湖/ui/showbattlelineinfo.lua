module(..., package.seeall)

local require = require;

local ui = require("ui/base")

wnd_showBattleLineInfo = i3k_class("wnd_showBattleLineInfo", ui.wnd_base)

function wnd_showBattleLineInfo:ctor()
	self._timeTick = 0
end

function wnd_showBattleLineInfo:configure()

end

function wnd_showBattleLineInfo:refresh(info)
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	self:setInfo(info)
end

function wnd_showBattleLineInfo:onUpdate(dTime)

end

function wnd_showBattleLineInfo:setInfo(info)
	local scroll = self._layout.vars.scroll
	scroll:removeAllChildren()
	for i, v in ipairs(info) do
		local node = require("ui/widgets/sdymjdzqt")()
		node.vars.lineOrder:setText(i.."线")
		node.vars.totalNum:setText("人数："..v.total.."/"..i3k_db_crossRealmPVE_cfg.eachLineLoad)
		node.vars.sectNum:setText("本帮人数："..v.sect)
		if v.total >= i3k_db_crossRealmPVE_cfg.eachLineLoad then
			node.vars.enter_btn:disableWithChildren()
		end
		node.vars.enter_btn:onClick(self, self.enterBattleArea, i)
		scroll:addItem(node)
	end
end

function wnd_showBattleLineInfo:enterBattleArea(sender, lineOrder)
	if g_i3k_game_context:getPveBattleKey() < i3k_db_crossRealmPVE_cfg.needBattleCoin then
		g_i3k_ui_mgr:PopupTipMessage("所需幽冥密令不足")
	else
		i3k_sbean.enter_pveBattleArea(lineOrder)
	end
end

function wnd_showBattleLineInfo:showBattleKeys(keys)
	--self._battleKey = self._battleKey + keys
	--self._layout.vars.battleKeys:setText("幽冥密令："..self._battleKey.."/"..i3k_db_crossRealmPVE_cfg.needBattleCoin)
end

function wnd_create(layout, ...)
	local wnd = wnd_showBattleLineInfo.new();
	wnd:create(layout, ...);
	return wnd;
end
