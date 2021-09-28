-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_unlockhead = i3k_class("wnd_unlockhead", ui.wnd_base)
function wnd_unlockhead:ctor()
	self.needcount = 0
	self.havecount = 0
	self.itemId = 0
	self.isFrame = false
end

function wnd_unlockhead:configure()
	self.money_count = self._layout.vars.money_count
	self.itemname = self._layout.vars.itemname
	self.itemimage = self._layout.vars.itemimage
	self.money_icon = self._layout.vars.money_icon
	self.tximage = self._layout.vars.tximage
	self.headBg = self._layout.vars.headBg
	self.suo = self._layout.vars.suo
	self.cancel_btn = self._layout.vars.cancel_btn
	self.ok_btn = self._layout.vars.ok_btn
	self.item_btn = self._layout.vars.item_btn
end

function wnd_unlockhead:refresh(headId, isFrame)
	self.isFrame = isFrame
	if isFrame then
		self.itemId = i3k_db_head_frame[headId].condition_1
		self.needcount = i3k_db_head_frame[headId].condition_2
		self.headBg:setImage(g_i3k_db.g_i3k_get_head_bg_path(g_i3k_game_context:GetTransformBWtype(), headId))
		self.tximage:hide()
	else
		self.itemId = i3k_db_personal_icon[headId].needItemId
		self.needcount = i3k_db_personal_icon[headId].needItemCount
		self.tximage:setImage(g_i3k_db.i3k_db_get_head_icon_path(headId , false))
	end
	local itemId = self.itemId
	local itemcfg = g_i3k_db.i3k_db_get_other_item_cfg(itemId)
	self.havecount = g_i3k_game_context:GetCommonItemCanUseCount(itemId)
	self.money_count:setText(string.format("%s/%s",self.havecount, self.needcount))
	self.money_count:setTextColor(g_i3k_get_cond_color(self.needcount <= self.havecount))
	self.itemname:setText(itemcfg.name)
	self.itemimage:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(itemId,i3k_game_context:IsFemaleRole()))
	self.money_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(itemId))
	self.suo:setVisible(g_i3k_db.i3k_db_get_reward_lock_visible(itemId))
	self.cancel_btn:onClick(self,self.cancel)
	self.ok_btn:onClick(self,self.unlockbtn, headId)
	self.item_btn:onClick(self, self.itembtn, itemId)
end

function wnd_unlockhead:unlockbtn(sender,id)
	if self.isFrame then
		if self.needcount <= self.havecount then
			local callback = function ()
				i3k_sbean.syncPlayerFrameIcon()  --同步一下头像框界面
			end
			i3k_sbean.unlockPlayerFrameIcon(id, callback, true)
		else
			g_i3k_ui_mgr:PopupTipMessage("道具不足，无法启动头像框")
		end
	else
		if self.needcount <= self.havecount then
			i3k_sbean.unlock_head(id)
		else
			g_i3k_ui_mgr:PopupTipMessage("道具不足，无法启动头像")
		end
	end
end

function wnd_unlockhead:cancel(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_UnlockHead)
end

function wnd_unlockhead:itembtn(sender, itemId)
	g_i3k_ui_mgr:ShowCommonItemInfo(itemId)
end

function wnd_unlockhead:updateItemCount()
	self.havecount = g_i3k_game_context:GetCommonItemCanUseCount(self.itemId)
	self.money_count:setText(string.format("%s/%s",self.havecount, self.needcount))
	self.money_count:setTextColor(g_i3k_get_cond_color(self.needcount <= self.havecount))
end

function wnd_create(layout, ...)
	local wnd = wnd_unlockhead.new()
	wnd:create(layout, ...)
	return wnd
end
