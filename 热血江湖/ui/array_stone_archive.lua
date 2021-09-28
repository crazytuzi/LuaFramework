-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_array_stone_archive = i3k_class("wnd_array_stone_archive", ui.wnd_base)

function wnd_array_stone_archive:ctor()
	self._curLevel = 1
end

function wnd_array_stone_archive:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	self._layout.vars.leftBtn:onClick(self, self.onLeftBtn)
	self._layout.vars.rightBtn:onClick(self, self.onRightBtn)
	self._layout.vars.scroll:setBounceEnabled(false)
end

function wnd_array_stone_archive:refresh()
	self:updateStoneScroll()
end

function wnd_array_stone_archive:updateStoneScroll()
	local stones = {}
	for k, v in pairs(i3k_db_array_stone_cfg) do
		if v.level == self._curLevel then
			table.insert(stones, v)
		end
	end
	table.sort(stones, function(a, b)
		if a.suffixId == b.suffixId then
			return a.prefixId < b.prefixId
		else
			return a.suffixId < b.suffixId
		end
	end)
	self._layout.vars.scroll:removeAllChildren()
	local children = self._layout.vars.scroll:addItemAndChild("ui/widgets/zfstjt", 9, #stones)
	for k, v in ipairs(children) do
		v.vars.stoneBg:setImage(g_i3k_get_icon_frame_path_by_rank(stones[k].rank, false))
		v.vars.stoneIcon:setImage(g_i3k_db.i3k_db_get_icon_path(stones[k].stoneIcon))
		v.vars.stoneBtn:onClick(self, self.showStoneInfo, {id = stones[k].id, inBag = 3})
	end
	self._layout.vars.title:setText(i3k_get_string(18457 + self._curLevel))
end

function wnd_array_stone_archive:showStoneInfo(sender, stoneInfo)
	g_i3k_ui_mgr:OpenUI(eUIID_ArrayStoneMWInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_ArrayStoneMWInfo, stoneInfo.id, stoneInfo.inBag)
end

function wnd_array_stone_archive:onLeftBtn(sender)
	if self._curLevel > 1 then
		self._curLevel = self._curLevel - 1
		self:updateStoneScroll()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18489))
	end
end

function wnd_array_stone_archive:onRightBtn(sender)
	if self._curLevel < i3k_db_array_stone_common.maxStoneLevel then
		self._curLevel = self._curLevel + 1
		self:updateStoneScroll()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18490))
	end
end

function wnd_create(layout)
	local wnd = wnd_array_stone_archive.new()
	wnd:create(layout)
	return wnd
end