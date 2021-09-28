-- zengqingfeng
-- 2018/6/28
--eUIID_UnlockOutcastTips 
-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_unlockOutcastTips = i3k_class("unlockOutcastTips", ui.wnd_base)

function wnd_unlockOutcastTips:ctor()
	
end

function wnd_unlockOutcastTips:configure()
	local widgets = self._layout.vars
	self._widgets = widgets
	widgets.closeBtn:onClick(self, self.onCloseUI)
	widgets.imgBK:onClick(self, self.onCloseUI)
end

function wnd_unlockOutcastTips:refresh(nodeData)
	local cfg = nodeData.cfg
	g_i3k_ui_mgr:refreshScrollItems(self._layout.vars.scrollview, cfg.needItems, "ui/widgets/rchwzjst", g_ITEM_NUM_SHOW_TYPE_COMPARE)
	self._widgets.desc:setText(string.format("是否消耗以上道具解锁 %s？", nodeData.cfg.name))
	self._widgets.unlockBtn:onClick(self, self.unlock, nodeData)
end 

function wnd_unlockOutcastTips:unlock(sender, nodeData)
	-- 判断条件：道具是否齐全
	if g_i3k_game_context:checkNeedCommonItemsCfg(nodeData.cfg.needItems, true) then
		i3k_sbean.biography_unlock(nodeData.cfg.id, nodeData)
	end 
end 

function wnd_unlockOutcastTips:onUnlock(biographyID)
	self:onCloseUI()
end

function wnd_create(layout,...)
	local wnd = wnd_unlockOutcastTips.new()
	wnd:create(layout,...)
	return wnd
end
