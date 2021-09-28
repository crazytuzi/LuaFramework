-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_room_tips = i3k_class("wnd_room_tips", ui.wnd_base)


local LAYER_AN = "ui/widgets/an"
local LAYER_AN2 = "ui/widgets/an2"
local LAYER_AN3 = "ui/widgets/an3"

function wnd_room_tips:ctor()
	self._pos = nil
	self._isLeader = nil 
	self._id = nil
end

function wnd_room_tips:configure()
	local widgets = self._layout.vars
	
	self.scroll = widgets.scroll
	self.rootView = widgets.rootView
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
end

function wnd_room_tips:refresh(pos, isLeader, id)
	self._pos = pos
	self._isLeader = isLeader
	self._id = id
	
	if self._isLeader then
		self:SetLeaderLayer()
	else
		self:SetOtherLayer()
	end
end

function wnd_room_tips:SetLeaderLayer()
	self.scroll:setBounceEnabled(false)
	self.rootView:setPosition(self._pos)
	local size = self.rootView:getContentSize()
	local factionId = g_i3k_game_context:GetFactionSectId()
	local height = 0
	for i=1,6 do
		local is_add = true
		local root
		if i==1 then
			root = require(LAYER_AN)()
		--[[elseif i==5 then --Zhang 暂时注释掉寻径至目标按钮
			root = require(LAYER_AN3)()--]]
		else
			root = require(LAYER_AN2)()
		end
		local btn = root.vars.btn
		local btnName = root.vars.btnName
		if i==1 then
			btn:onClick(self, self.onFriend)
			btnName:setText("好友")
		elseif i==2 then
			btn:onClick(self, self.letItLeader)
			btnName:setText("升为房主")
		elseif i==3 then
			btn:onClick(self, self.priviteChat)
			btnName:setText("私聊")
		elseif i==4 then
			btn:onClick(self, self.check)
			btnName:setText("查看")
		--[[elseif i == 5 then
			btn:onClick(self, self.toTheAim)
			btnName:setText("寻径至目标")--]]
		elseif i == 5 then
			btn:onClick(self, self.kickPlayer)
			btnName:setText("踢出队员")
		elseif i == 6 then
			local myPos = g_i3k_game_context:GetSectPosition() or 0
			if factionId ~= 0 and  i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].accept == 1 then
				btn:onClick(self, self.inviteFaction)
				btnName:setText("邀请入帮")
			else
				is_add = false
			end 
		end
		if is_add then
			self.scroll:addItem(root)
			height = height + root.rootVar:getSizeInScroll(self.scroll).height
		end 
	end
	--[[self.rootView:setContentSize(size.width, height)
	self.scroll:setContentSize(size.width, height)
	self.scroll:setContainerSize(size.width, height)
	self.scroll:update()--]]
	
	self.rootView:setContentSize(size.width,height+10)
	self.scroll:setContentSize(size.width, height+10)
	self.scroll:setContainerSize(size.width, height+10)
	self.scroll:update()
	local child = self.scroll:getChildAtIndex(1)
	local pos = child.rootVar:getPositionInScroll(self.scroll)
	self.rootView:setAnchorPoint(0, pos.y/(height+10))
	self.rootView:setPosition(self._pos)
end

--TODO
function wnd_room_tips:letItLeader(sender)
	i3k_sbean.dungeon_change_leader(self._id)
end

function wnd_room_tips:inviteFaction(sender)
	i3k_sbean.invite_faction(self._id)
end 

--私聊
function wnd_room_tips:priviteChat(sender)
	local roleId = self._id
	local data = g_i3k_game_context:GetRoomData()
	local player = {}
	for k,v in pairs(data) do
		if v.id == roleId then
			player.msgType = global_recent
			player.name = v.name
			player.id = v.id
			player.level = v.lvl
			player.iconId = v.headIcon
			player.bwType = v.bwType
		end
	end
	local nearByRole = g_i3k_game_context:GetNearByRoleData()
	if next(player) == nil then --如果获取play为空可能是点击的是附近的玩家
		for k, v in pairs(nearByRole) do
			if v.id == roleId then
				player.msgType = global_recent
				player.name = v.name
				player.id = v.id
				player.level = v.lvl
				player.iconId = v.headIcon
				player.bwType = v.bwType
			end
		end
	end
	
	g_i3k_ui_mgr:OpenUI(eUIID_PriviteChat)
	g_i3k_ui_mgr:RefreshUI(eUIID_PriviteChat, player)
	g_i3k_ui_mgr:CloseUI(eUIID_RoomTips)
end

function wnd_room_tips:check(sender)
	i3k_sbean.query_rolefeature(self._id)
end

function wnd_room_tips:toTheAim(sender)

end

function wnd_room_tips:onFriend(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_FBLB)
	g_i3k_ui_mgr:CloseUI(eUIID_CreateRoom)
	g_i3k_ui_mgr:CloseUI(eUIID_RoomTips)
	g_i3k_logic:OpenMyFriendsUI()
end

function wnd_room_tips:SetOtherLayer()
	self.scroll:setBounceEnabled(false)
	local size = self.rootView:getContentSize()
	local factionId = g_i3k_game_context:GetFactionSectId()
	local height = 0
	for i=1,3 do
		local is_add = true
		local root 
		if i==1 then
			root = require(LAYER_AN)()
		--[[elseif i==3 then --Zhang 暂时注释掉寻径至目标按钮
			root = require(LAYER_AN3)()--]]
		else
			root = require(LAYER_AN2)()
		end
		local btn = root.vars.btn
		local btnName = root.vars.btnName
		if i==1 then
			btn:onClick(self, self.priviteChat)
			btnName:setText("私聊")
		elseif i==2 then
			btn:onClick(self, self.check)
			btnName:setText("查看")
		elseif i == 3 then
			local myPos = g_i3k_game_context:GetSectPosition() or 0
			if factionId ~= 0 and  i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].accept == 1 then
				btn:onClick(self, self.inviteFaction)
				btnName:setText("邀请入帮")
			else
				is_add = false
			end 
		else
			--[[btn:onClick(self, self.toTheAim)
			btnName:setText("寻径至目标")--]]
		end
		if is_add then
			self.scroll:addItem(root)
			height = height + root.rootVar:getSizeInScroll(self.scroll).height
		end 
	end
	
	self.rootView:setContentSize(size.width,height+10)
	self.scroll:setContentSize(size.width, height+10)
	self.scroll:setContainerSize(size.width, height+10)
	self.scroll:update()
	local child = self.scroll:getChildAtIndex(1)
	local pos = child.rootVar:getPositionInScroll(self.scroll)
	self.rootView:setAnchorPoint(0, pos.y/(height+10))
	self.rootView:setPosition(self._pos)
end

function wnd_room_tips:kickPlayer(sender)
	local data = i3k_sbean.mroom_kick_req.new()
	data.roleId = self._id
	i3k_game_send_str_cmd(data,i3k_sbean.mroom_kick_res.getName())
	g_i3k_ui_mgr:CloseUI(eUIID_RoomTips)
end

--[[function wnd_room_tips:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_RoomTips)
end--]]

function wnd_create(layout)
	local wnd = wnd_room_tips.new()
		wnd:create(layout)
	return wnd
end

