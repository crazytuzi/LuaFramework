local GComponentGuidMember = {}

local operateButtons = {
	"btn_check_equip", 
	"btn_add_friend", 
	"btn_private_chat", 
	"btn_invite_team", 
	"btn_demise_admin", 
	"btn_appoint_vice", 
	"btn_appoint_elder", 
	"btn_dismiss_post", 
	"btn_kick_out",
}

function GComponentGuidMember:initView(extend)
	if self.xmlTips then
		local function pushOperateButton(sender)
			local btnName = sender:getName()
			if btnName == "btn_check_equip" then				
				GameSocket:CheckPlayerEquip(extend.memberName)
			elseif btnName == "btn_add_friend" then
				GameSocket:FriendChange(extend.memberName,100)
			elseif btnName == "btn_private_chat" then
				local data = extend.data
				if data and GameSocket:getRelation(data.name)==0 then
					GameSocket.mFriends = GameSocket.mFriends or {}
					GameSocket.mFriends[data.name] = {}
					GameSocket.mFriends[data.name].name = data.name
					GameSocket.mFriends[data.name].gender = data.gender
					GameSocket.mFriends[data.name].job = data.job
					GameSocket.mFriends[data.name].level = data.lv or data.level
					GameSocket.mFriends[data.name].title = 0--陌生人关系
					GameSocket.mFriends[data.name].guild = data.guild or ""
					GameSocket.mFriends[data.name].online_state = data.online or 1
				end
				GameSocket:addChatRecentPlayer(extend.memberName)
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "main_friend",tab = 1})
			elseif btnName == "btn_invite_team" then
				if GameSocket.mCharacter.mGroupLeader ~= GameCharacter._mainAvatar:NetAttr(GameConst.net_name) then--不是队长
					GameSocket:alertLocalMsg("队长才能邀请组队","alert")
				else
					GameSocket:InviteGroup(extend.memberName)
				end
			elseif btnName == "btn_demise_admin" then
				GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "demiseAdmin", memberName = extend.memberName}))
			elseif btnName == "btn_appoint_vice" then
				GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "appointVice", memberName = extend.memberName}))
			elseif btnName == "btn_appoint_elder" then
				GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "appointAdv", memberName = extend.memberName}))
			elseif btnName == "btn_dismiss_post" then
				GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "dismissPost", memberName = extend.memberName}))
			elseif btnName == "btn_kick_out" then
				print("zzzzz",extend.memberName)
				GameSocket:PushLuaTable("gui.ContainerGang.onPanelData", GameUtilSenior.encode({actionid = "kickOut", memberName = extend.memberName}))
			end
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = extend.str})
		end

		local btnOperate
		for i,v in ipairs(operateButtons) do
			btnOperate = self.xmlTips:getWidgetByName(v)
			GUIFocusPoint.addUIPoint(btnOperate, pushOperateButton)
		end

		self.xmlTips:getWidgetByName("lbl_player_name"):setString(extend.memberName)
	end
end

return GComponentGuidMember