-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_delete_friend = i3k_class("wnd_delete_friend", ui.wnd_base)

local LAYER_ERITEM = "ui/widgets/haoyousct"

function wnd_delete_friend:ctor()
	self.deleteFriend = {}
	self.isContainTbl = {}
	self.friendItem = {}
end



function wnd_delete_friend:configure(...)
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self._layout.vars.oneKeyDelete:onClick(self,self.deleteAllFriends)
	
	self._layout.vars.chooseAll:onClick(self,self.chooseAllFriends)
end

function wnd_delete_friend:onShow()
	
end

function wnd_delete_friend:refresh(deleteFriendTbl)
	self.deleteFriend = deleteFriendTbl
	self:updateDeleteFriendsData()
	if #self.deleteFriend>0 then
		for i=1,#self.deleteFriend do
			self.isContainTbl[i] = false
		end
	end
end

function wnd_delete_friend:updateDeleteFriendsData()
	local scroll = self._layout.vars.friend_scroll
	scroll:removeAllChildren()
	self.friendItem = {}
	--local FriendOverview = g_i3k_game_context:GetFriendsData()
	local nowtime  = i3k_game_get_time() --当前时间
	for k,v in ipairs(self.deleteFriend) do  
		local info = v.fov.overview
		local bwType = info.bwType
		local frameId = info.headBorder
		local eachFriend = v.eachFriend
		local focusValue = v.focusValue -- 关注度
		local addTime = v.addTime --添加好友时间
		local logintime = v.fov.lastLoginTime
		local personalMsg = v.fov.personalMsg
		local online = v.fov.online
		local fightpower = info.fightPower
		local Item = require(LAYER_ERITEM)()
		table.insert(self.friendItem,Item)
		local name = Item.vars.name_label
		local state = Item.vars.state
		local tx = Item.vars.tx_img
		local level = Item.vars.level
		local zhiye = Item.vars.zhiye_img
		local isonline = Item.vars.isOnline_img--是否在线
		local iseachfriends = 	Item.vars.iseachfriends_lab
		local attention = Item.vars.attention_label--关注度
		local Iconbg=Item.vars.txb_img
		local isChoose = Item.vars.isChoose
		local offlineLongTime = Item.vars.offline
		if (nowtime - logintime)/3600 > i3k_db_common.friends_about.offline_time then
			offlineLongTime:setVisible(true)
		else
			offlineLongTime:setVisible(false)
		end
		isChoose:hide()
		Iconbg:setImage(g_i3k_get_head_bg_path(bwType, frameId))
		local fightPower = Item.vars.fightPower--战力
		if eachFriend == 0 then 
			iseachfriends:hide()
		else 
			iseachfriends:show()								
		end
		if online == 0 then
			isonline:setImage(g_i3k_db.i3k_db_get_icon_path(1319))
		elseif online == 1 then
			isonline:setImage(g_i3k_db.i3k_db_get_icon_path(1318))
		end
		fightPower:setText("战力:" .. fightpower)
		attention:setText(focusValue)
		name:setText(info.name)
		level:setText(info.level)
		local gcfg = g_i3k_db.i3k_db_get_general(info.type)
		zhiye:setImage(g_i3k_db.i3k_db_get_icon_path(gcfg.classImg))
		tx:setImage(g_i3k_db.i3k_db_get_head_icon_path(info.headIcon, false))
		state:setText(personalMsg)
		--self.isContainTbl[k] = false
		local more_btn = Item.vars.more_btn
		more_btn:onClick(self,self.isChoosed,{scrollItem = Item,index = k,parameter = v}--[[,v--]])
		scroll:addItem(Item)
	end
end

function wnd_delete_friend:updateFriendData()
	for i = #self.isContainTbl,1,-1 do  
		if self.isContainTbl[i] then
			table.remove(self.isContainTbl,i)
			table.remove(self.deleteFriend,i)
		end
	end
	--g_i3k_ui_mgr:PopupTipMessage(tmp)
	self:updateDeleteFriendsData()

end

function wnd_delete_friend:isChoosed(sender, needValue)
	local isChoose = needValue.scrollItem.vars.isChoose
	if isChoose:isVisible() then
		isChoose:hide()
		self.isContainTbl[needValue.index] = false
	else
		isChoose:show()
		--g_i3k_ui_mgr:PopupTipMessage("the index is" .. needValue.index)
		self.isContainTbl[needValue.index] = true
	end
	--g_i3k_ui_mgr:PopupTipMessage(needValue.parameter.fov.lastLoginTime)

end

function wnd_delete_friend:deleteAllFriends(sender)
	local friendIds = {}
	for  k,v in ipairs(self.isContainTbl) do
		if self.isContainTbl[k] then
			table.insert(friendIds,self.deleteFriend[k].fov.overview.id)
		end
	end
	if #friendIds>0 then
		local function callback(isOK)
			if isOK then
				i3k_sbean.deleteFriends(friendIds)
			end
		end
		local msg = "是否删除选中好友"
		g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
	end
end

function wnd_delete_friend:chooseAllFriends(sender)
	if #self.deleteFriend>0 then
		for  k,v in ipairs(self.isContainTbl) do
			self.isContainTbl[k] = true
		end
	else
		
	end
	for k,v in ipairs(self.friendItem) do
		--local Item = require(LAYER_ERITEM)()
		v.vars.isChoose:show()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_delete_friend.new();
		wnd:create(layout, ...);

	return wnd;
end
