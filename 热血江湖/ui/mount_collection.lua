-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_mount_collection = i3k_class("wnd_mount_collection", ui.wnd_base)

local MOUNT = 1
local EDGE = 2
function wnd_mount_collection:ctor()
	
end

function wnd_mount_collection:configure()
	self._layout.vars.close:onClick(self, self.onClose)
	self._stateType = MOUNT
end

function wnd_mount_collection:onShow()
	
end

function wnd_mount_collection:refresh(id, cb)
	local collection = i3k_db_collection[id]
	local curCollection = g_i3k_game_context:getCollectionWithId(id)	
	local widgets = self._layout.vars
	local needItem
	if curCollection and curCollection.isMount then										--镶边
		self._stateType = EDGE
		widgets.title:setImage(g_i3k_db.i3k_db_get_icon_path(8006))
		widgets.ordinaryBtn:setText(i3k_get_string(17719))
		widgets.luxuryBtn:setText(i3k_get_string(17720))
		widgets.desc:setText(i3k_get_string(17721))
		needItem = {
		[1] = {id = collection.needEdgeId1, count = collection.needEdgeValue1},
		[2] = {id = collection.needEdgeId2, count = collection.needEdgeValue2},
		}
		i3k_log("curCollectioncurCollection")
	else
		widgets.title:setImage(g_i3k_db.i3k_db_get_icon_path(8007))
		widgets.ordinaryBtn:setText(i3k_get_string(17725))
		widgets.luxuryBtn:setText(i3k_get_string(17726))
		widgets.desc:setText(i3k_get_string(17728))
		needItem = {
		[1] = {id = collection.needId1, count = collection.needValue1},
		[2] = {id = collection.needId2, count = collection.needValue2},
	}
	end
	local needItemWidget = {
		[1] = {gradeIcon = widgets.gradeIcon1, icon = widgets.icon1, btn = widgets.btn1, countLabel = widgets.countLabel1},
		[2] = {gradeIcon = widgets.gradeIcon2, icon = widgets.icon2, btn = widgets.btn2, countLabel = widgets.countLabel2},
	}
	local isEnough = true
	for i,v in ipairs(needItemWidget) do
		local needId = needItem[i].id
		v.gradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needId))
		v.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needId,i3k_game_context:IsFemaleRole()))
		v.countLabel:setText(string.format("x%d", needItem[i].count))
		local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(needId)
		v.countLabel:setTextColor(g_i3k_get_cond_color(needItem[i].count<=canUseCount))
		if needItem[i].count>canUseCount then
			isEnough = false
		end
		v.btn:onClick(self, function ()
			g_i3k_ui_mgr:ShowCommonItemInfo(needId)
		end)
	end
	local needItemTable = {}
	for i,v in ipairs(needItem) do
		needItemTable[v.id] = v.count
	end
	self._layout.vars.normalMount:onClick(self, self.normalMount, {id = id, isEnough = isEnough, needItem = needItemTable, callback = cb})
	local bindDiamond = self._stateType == EDGE and collection.bindEdgeDiamond  or collection.bindDiamond
	self._layout.vars.diamondCount:setText(bindDiamond)
	self._layout.vars.diamondCount:setTextColor(g_i3k_get_cond_color(bindDiamond <= g_i3k_game_context:GetDiamondCanUse(false)))
	self._layout.vars.diamondMount:onClick(self, self.mountWithDiamond, {id = id, diamond = bindDiamond, callback = cb})
end

function wnd_mount_collection:normalMount(sender, needValue)
	if needValue.isEnough then
		local callback = function()
			for i,v in pairs(needValue.needItem) do
				g_i3k_game_context:UseCommonItem(i, v,AT_MEDAL_GROW)
			end
			needValue.callback()
			g_i3k_ui_mgr:CloseUI(eUIID_MountCollection)
		end
		local name = i3k_db_collection[needValue.id].name
		local desc = i3k_get_string( self._stateType == EDGE and 17713 or 15080, name)
		local callfunc = function (isOk)
			if isOk then
				if self._stateType == EDGE then
					i3k_sbean.edge_collection(needValue.id, 1, callback)
				else
				i3k_sbean.mount_collection(needValue.id, 1, callback)
				end
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callfunc)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(self._stateType == EDGE and 17714 or 15081))
	end
end

function wnd_mount_collection:mountWithDiamond(sender, needValue)
	if needValue.diamond>g_i3k_game_context:GetDiamondCanUse(false) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(self._stateType == EDGE and 17716 or 15083))
	else
		local callback = function()
			g_i3k_game_context:UseDiamond(needValue.diamond, false,AT_MEDAL_GROW)
			needValue.callback()
			g_i3k_ui_mgr:CloseUI(eUIID_MountCollection)
		end
		local name = i3k_db_collection[needValue.id].name
		local desc = i3k_get_string(self._stateType == EDGE and 17715 or 15082, needValue.diamond, name)
		local callfunc = function(isOk)
			if isOk then
				if self._stateType == EDGE then
					i3k_sbean.edge_collection(needValue.id, 2, callback)
				else
				i3k_sbean.mount_collection(needValue.id, 2, callback)
				end
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callfunc)
	end
end

function wnd_mount_collection:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_MountCollection)
end


function wnd_create(layout, ...)
	local wnd = wnd_mount_collection.new()
	wnd:create(layout, ...)
	return wnd;
end
