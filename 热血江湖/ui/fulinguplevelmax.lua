-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_fulingUpLevelMax = i3k_class("wnd_fulingUpLevelMax", ui.wnd_base)

function wnd_fulingUpLevelMax:ctor()
	self._itemsEnough = true
end

function wnd_fulingUpLevelMax:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self, self.onCloseUI)
	widgets.up_btn:onClick(self, self.onCloseUI)
end

function wnd_fulingUpLevelMax:refresh(id)
	self._id = id
	self:setIconInfo(id)
end

-- InvokeUIFunction
function wnd_fulingUpLevelMax:refreshWithoutArgs()
	local id = self._id
	self:refresh(id)
end

function wnd_fulingUpLevelMax:setIconInfo(id)
	local cfgID = g_i3k_db.i3k_db_get_wuxing_index(id, #i3k_db_longyin_sprite_addPoint)
	local widgets = self._layout.vars

	local icon1, icon2 = g_i3k_db.i3k_db_get_wuxing_xiangsheng_icons(id, #i3k_db_longyin_sprite_addPoint)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(icon1))
	widgets.icon2:setImage(g_i3k_db.i3k_db_get_icon_path(icon2))

	local cfg = i3k_db_longyin_sprite_born[cfgID]
	local points = g_i3k_game_context:getXiangshengPoint(cfgID)
	widgets.name:setText(cfg[1].name)

	local data = self:getShowData(id)

	self:setCurEffect(data.cur)
	self._layout.anis.c_dakai2.play(-1)
end

-- id = 0,初始， id = #list 满级了
function wnd_fulingUpLevelMax:getShowData(id)
	local cfgID = g_i3k_db.i3k_db_get_wuxing_index(id, #i3k_db_longyin_sprite_addPoint)
	local cfg = i3k_db_longyin_sprite_born[cfgID]
	local points = g_i3k_game_context:getXiangshengPoint(cfgID)

	if points == 0 then
		return { cur = "无", next = cfg[points + 1].effectDesc, consumes = cfg[points + 1].consumes, forwardCount = cfg[points + 1].forwardCount}
	end
	if not cfg[points + 1] then
		return { cur = cfg[points].effectDesc, next = "无", consumes = {}, forwardCount = 0}
	end

	return {cur = cfg[points].effectDesc, next = cfg[points + 1].effectDesc, consumes = cfg[points + 1].consumes, forwardCount = cfg[points + 1].forwardCount}
end


function wnd_fulingUpLevelMax:setCurEffect(text)
	local widgets = self._layout.vars
	widgets.desc1:setText(text)
end


function wnd_fulingUpLevelMax:onItemTips(sender, itemID)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemID)
end

function wnd_create(layout, ...)
	local wnd = wnd_fulingUpLevelMax.new()
	wnd:create(layout, ...)
	return wnd;
end
