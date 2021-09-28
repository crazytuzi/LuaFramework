-------------------------------------------------------
module(..., package.seeall)

local require = require

local ui = require("ui/base")

-------------------------------------------------------

wnd_steedRankBase = i3k_class("wnd_steedRankBase",ui.wnd_base)

local steedUIID = {
	eUIID_RankListRoleProperty,
	eUIID_RankListRoleSteedSkin,
	eUIID_RankListRoleSteedFight,
	eUIID_RankListRoleSteedSpirit,
	eUIID_RankListRoleSteedEquip
}

local function manageSteedUI(uiid)
	for k, v in ipairs(steedUIID) do
		if v ~= uiid then
			g_i3k_ui_mgr:CloseUI(v)
		end
	end
end

function wnd_steedRankBase:ctor()
	self._data = nil
end

function wnd_steedRankBase:configure()
	local widgets = self._layout.vars

	widgets.steedBtn:onClick(self, self.onSteedBtn)
	widgets.skinBtn:onClick(self, self.onSkinBtn)
	widgets.steedFightBtn:onClick(self, self.onSteedFightBtn)
	widgets.steedSpiritBtn:onClick(self, self.onSteedSpiritBtn)
	widgets.steedEquipBtn:onClick(self, self.onSteedEquipBtn)
end

--界面需要的数据
function wnd_steedRankBase:setSteedRankBaseData(data)
	self._data = data
end

function wnd_steedRankBase:onSteedBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleProperty)
	g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleProperty, self._data.info, self._data.id, self._data.showIDs, self._data.masters, self._data.steedSpirit, self._data.steedEquip, self._data.roleOverview)
	manageSteedUI(eUIID_RankListRoleProperty)
end

function wnd_steedRankBase:onSkinBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleSteedSkin)
	g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleSteedSkin, self._data)
	manageSteedUI(eUIID_RankListRoleSteedSkin)
end

function wnd_steedRankBase:onSteedFightBtn(sender)
	if next(self._masters) == nil then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1305))
	end
	g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleSteedFight)
	g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleSteedFight, self._data)
	manageSteedUI(eUIID_RankListRoleSteedFight)
end

function wnd_steedRankBase:onSteedSpiritBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleSteedSpirit)
	g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleSteedSpirit, self._data)
	manageSteedUI(eUIID_RankListRoleSteedSpirit)
end

function wnd_steedRankBase:onSteedEquipBtn(sender)
	local curClothes = self._data.steedEquip.curClothes
	local allSuits = self._data.steedEquip.allSuits
	local isOpenUI = table.nums(curClothes) > 0 or table.nums(allSuits) > 0

	if isOpenUI then
		g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleSteedEquip)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleSteedEquip, self._data)
		manageSteedUI(eUIID_RankListRoleSteedEquip)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1643))
	end
end

function wnd_create(layout)
	local wnd = wnd_steedRankBase.new()
	wnd:create(layout)
	return wnd
end
