-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_chatFC = i3k_class("wnd_chatFC", ui.wnd_base)


function wnd_chatFC:ctor()

end

function wnd_chatFC:configure(...)
	self._layout.vars.btnBackGround:onClick(self, self.onClose)
end

function wnd_chatFC:onShow()

end

function wnd_chatFC:initScroll(player)
	local jsScroll = self._layout.vars.jsscroll
	jsScroll:setBounceEnabled(false)
	jsScroll:removeAllChildren()
	local jst = require("ui/widgets/ltjst")()
	jst.vars.id:setText("id:"..player.id)
	jst.vars.name:setText(player.name)
	jst.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(player.iconId, true))
	jst.vars.txb_img:setImage(g_i3k_get_head_bg_path(player.bwType, player.headBorder))
	jsScroll:addItem(jst)
end
function wnd_chatFC:refresh(player, isPrivite)
	self:initScroll(player)
	self:loadData(player, isPrivite)
end
--remove    delete   invite
function wnd_chatFC:loadData(player, isPrivite)
	local gnScroll = self._layout.vars.gnscroll
	local gnContentSize = gnScroll:getContentSize()
	gnScroll:setBounceEnabled(false)

	local playerId = player.id
	local factionId = g_i3k_game_context:GetFactionSectId()
	local myPos = g_i3k_game_context:GetSectPosition() or 0
	local num1 = 7
	local num2 = 7
	if factionId ~= 0 and i3k_db_faction_power[myPos] and i3k_db_faction_power[myPos].accept == 1 then
		if player.srcSectId == 0 then
			num1 = 8
			num2 = 8
		end
	end
	if isPrivite then
		if player.msgType == global_recent then
			local children = gnScroll:addChildWithCount("ui/widgets/ltgnt", 2, num1)
			for i,v in ipairs(children) do
				v.vars.btn:setTag(i+2000)
				if i==1 then
					local value = g_i3k_game_context:GetFriendsDataByID(playerId)
					if value == nil then
						v.vars.btnName:setText("加为好友")
						v.vars.btn:onClick(self, self.addFriend,playerId)
					else
						v.vars.btn:onClick(self, self.deleteFriends,playerId)
						v.vars.btnName:setText("删除好友")
					end
				elseif i==2 then
					local teamId = g_i3k_game_context:GetTeamId()
					if teamId > 0 then
						v.vars.btnName:setText("邀请入队")
						v.vars.btn:onClick(self, self.inviteToTeam, playerId)
					else
						if player.teamID ~= 0 then
							v.vars.btnName:setText("申请入队")
							v.vars.btn:onClick(self, self.applyToTeam, player.teamID)
						else
							v.vars.btnName:setText("邀请组队")
							v.vars.btn:onClick(self, self.inviteToTeam, playerId)
						end
					end
				elseif i==3 then
					v.vars.btnName:setText("删除记录")
					v.vars.btn:onClick(self, self.deleteData, playerId)
				elseif i==4 then
					v.vars.btnName:setText("查看资料")
					v.vars.btn:onClick(self, self.checkData,playerId)
				elseif i==5 then
					v.vars.btnName:setText("移出列表")
					v.vars.btn:onClick(self, self.removeList, playerId)
				elseif i== 6 then
					v.vars.btnName:setText("加入黑名单")
					v.vars.btn:onClick(self, self.blackList,playerId)
				elseif i== 7 then
					v.vars.btnName:setText("示爱")
					v.vars.btn:onClick(self, self.useShowLoveItem,playerId)
				elseif i== 8 then
					v.vars.btnName:setText("邀请入帮")
					v.vars.btn:onClick(self, self.inviteFaction,playerId)
				end
			end
		else
			local children = gnScroll:addChildWithCount("ui/widgets/ltgnt", 2, 1)
			for i,v in ipairs(children) do
				v.vars.btn:setTag(i+2000)
				if i == 1 then
					v.vars.btnName:setText("查看资料")
					v.vars.btn:onClick(self, self.checkData,playerId)
				end
			end
		end
	else
		local children = gnScroll:addChildWithCount("ui/widgets/ltgnt", 2, num2)
		for i,v in ipairs(children) do
			v.vars.btn:setTag(i+2000)
			if i==1 then
				local value = g_i3k_game_context:GetFriendsDataByID(playerId)
				if value == nil then
					v.vars.btnName:setText("加为好友")
					v.vars.btn:onClick(self, self.addFriend,playerId)
				else
					v.vars.btn:onClick(self, self.deleteFriends,playerId)
					v.vars.btnName:setText("删除好友")
				end
			elseif i==2 then
				local teamId = g_i3k_game_context:GetTeamId()
				if teamId > 0 then
					v.vars.btnName:setText("邀请入队")
					v.vars.btn:onClick(self, self.inviteToTeam, playerId)
				else
					if player.teamID ~= 0 then
						v.vars.btnName:setText("申请入队")
						v.vars.btn:onClick(self, self.applyToTeam, player.teamID)
					else
						v.vars.btnName:setText("邀请组队")
						v.vars.btn:onClick(self, self.inviteToTeam, playerId)
					end
				end
			elseif i==3 then
				v.vars.btnName:setText("私聊")
				v.vars.btn:onClick(self, self.priviteChat, player)
			elseif i==4 then
				v.vars.btnName:setText("赠花")
				v.vars.btn:onClick(self, self.giveFlowers, player)
				if g_i3k_game_context:GetWorldMapID() == i3k_db_spring.common.mapId then
					v.vars.btn:setVisible(false)
				end
			elseif i==5 then
				v.vars.btnName:setText("加入黑名单")
				v.vars.btn:onClick(self, self.blackList,playerId)--]]
			elseif i==6 then
				v.vars.btnName:setText("查看资料")
				v.vars.btn:onClick(self,self.checkData,playerId)
			elseif i== 7 then
				v.vars.btnName:setText("示爱")
				v.vars.btn:onClick(self, self.useShowLoveItem,playerId)
		elseif i== 8 then
				v.vars.btnName:setText("邀请入帮")
				v.vars.btn:onClick(self, self.inviteFaction,playerId)
			end
		end
	end
end

function wnd_chatFC:priviteChat(sender, player)
	g_i3k_ui_mgr:OpenUI(eUIID_PriviteChat)
	g_i3k_ui_mgr:RefreshUI(eUIID_PriviteChat, player)
	g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Chat, "onBack")
end

function wnd_chatFC:giveFlowers(sender, player)
	local id = g_i3k_db.i3k_db_get_common_cfg().give_flower.flowerID
	local cfg = g_i3k_db.i3k_db_get_other_item_cfg(id)
	if g_i3k_game_context:GetCommonItemCanUseCount(id) > 0 then
		g_i3k_ui_mgr:OpenUI(eUIID_GiveFlower)
		g_i3k_ui_mgr:RefreshUI(eUIID_GiveFlower, player)
		g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
	else
		g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
		local fun = (function(ok)
			if ok then
				g_i3k_logic:OpenVipStoreUI(cfg.showType, cfg.isBound, cfg.id) --打开商城其他分页
			end
		end)
		local desc = string.format("您的背包里没有鲜花可以赠送~")
		g_i3k_ui_mgr:ShowCustomMessageBox2("前往购买", "以后再买", desc, fun)
	end
end

function wnd_chatFC:blackList(sender,playerId)
	i3k_sbean.addBlackFriend(playerId)
	g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
end
function wnd_chatFC:inviteFaction(sender,playerId) --邀请入帮协议
	i3k_sbean.invite_faction(playerId)
end
function  wnd_chatFC:deleteFriends(sender,playerId)
	local callback = function (isOk)
		if isOk then
			i3k_sbean.deleteFriend(playerId)
			g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2("确定删除该好友？", callback)
end

function wnd_chatFC:addFriend(sender,playerId)
	i3k_sbean.addFriend(playerId)
	g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
end

function wnd_chatFC:checkData(sender,playerId)
	i3k_sbean.query_rolefeature(playerId)
	--g_i3k_ui_mgr:PopupTipMessage("查看资料")
	g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
end

function wnd_chatFC:removeList(sender, id)--移除好友
	local function fun(player)
		local callFunc = function()
			g_i3k_ui_mgr:PopupTipMessage("对话已经移出清单")
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PriviteChat, "specialOperate",callFunc, id)
		g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
	end
	g_i3k_game_context:SetRecentChatData(id, 1, fun)
	--g_i3k_ui_mgr:InvokeUIFunction(eUIID_PriviteChat, "refresh")
end

function wnd_chatFC:deleteData(sender, id)--删除记录
	local function fun(player)
		local callFunc = function()
			g_i3k_ui_mgr:PopupTipMessage("聊天记录已清除")
		end
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_PriviteChat, "specialOperate",callFunc)
		g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
	end
	g_i3k_game_context:SetRecentChatData(id, 2, fun)
end

function wnd_chatFC:inviteToTeam(sender, id)--邀请组队id为人的id
	i3k_sbean.invite_role_join_team(id)
end

function wnd_chatFC:applyToTeam(sender, teamId)
	local apply = i3k_sbean.team_apply_req.new()
	apply.teamId = teamId
	i3k_game_send_str_cmd(apply, i3k_sbean.team_apply_res.getName())
end

function wnd_chatFC:useShowLoveItem(sender, id)
	g_i3k_logic:openShowLoveItemUI(id)
end

function wnd_chatFC:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ChatFC)
end

function wnd_create(layout, ...)
	local wnd = wnd_chatFC.new();
		wnd:create(layout, ...);
	return wnd;
end
