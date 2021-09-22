local GComponentFriendMenu = {}

function GComponentFriendMenu:initView(extend)
	if self.xmlTips then
		self.str = extend.str
		self.btnType = extend.btnType
		local data = {}
		if GameUtilSenior.isString(extend.data) then
			data = GameSocket:getPlayerInfo(extend.data)
		elseif GameUtilSenior.isTable(extend.data) then
			data = extend.data
			if GameSocket:getRelation(data.name)==0 then
				GameSocket.mFriends = GameSocket.mFriends or {}
				GameSocket.mFriends[data.name] = {}
				GameSocket.mFriends[data.name].name = data.name
				GameSocket.mFriends[data.name].gender = data.gender
				GameSocket.mFriends[data.name].job = data.job
				GameSocket.mFriends[data.name].level = data.lv or data.level
				GameSocket.mFriends[data.name].title = 0;--陌生人关系
				GameSocket.mFriends[data.name].guild = data.guild or ""
				GameSocket.mFriends[data.name].online_state = data.online_state or 1
			end
		end
		-- self.playerInView = false
		-- if NetCC:findGhostByName(data.name) then
		-- 	self.playerInView = true
		-- end
		if not data or data.name == GameBaseLogic.chrName then
			GComponentFriendMenu.close(self)
		end
		if data then
			self.xmlTips:getWidgetByName("labName"):setString(data.name or "")
			self.xmlTips:getWidgetByName("labLevel"):setString(data.level or data.lv or "")
			local relation = GameSocket:getRelation(data.name)
			self.xmlTips:getWidgetByName("img_mo_bg"):loadTexture(GameConst.friendRelation[relation], ccui.TextureResType.plistType)
			if data.job and GameConst.job_name[data.job] then
				self.xmlTips:getWidgetByName("labJob"):setString(GameConst.job_name[data.job])
			end
			self.xmlTips:getWidgetByName("labGuild"):setString(data.guild~="" and data.guild or "暂无帮会")
			GComponentFriendMenu.initOperateBtn(self,data)
		else
			GameSocket:alertLocalMsg("玩家不在线,无法私聊", "alert")
		end
	end
end

function GComponentFriendMenu:initOperateBtn(data)
	if not self.xmlTips then return end
	local releation = GameSocket:getRelation(data.name)
	local btnNames = {
		["btnSee"] = "观察",
		["btnSL"] = "私聊",
		["btnZD"] = "邀请组队",
		["btnJY"] = "交易",
		["btnSH"] = "送花",
		["btnJHY"] = "加为好友",
		["btnJCR"] = "加为仇人",
		["btnHMD"] = "加黑名单",
		["btnSHY"] = "删除好友",
		["btnJB"] = "举报",
		["btnRD"] = "入队申请",
		["btnSCR"] = "移除仇人",
		["btnSHMD"] = "解除屏蔽",
		["btnCALL"] = "好友召唤",
	}
	local btnArrs
	if PLATFORM_BANSHU then
		btnArrs = {
			[0] = {"btnSee","btnSL","btnZD","btnJY","btnJHY"},
			[100] = {"btnSee","btnSL","btnZD","btnJY","btnSHY","btnJB"},
			[101] = {"btnSee","btnSL","btnZD","btnJY","btnJHY",},
			[102] = {"btnSee","btnSL","btnZD","btnJY","btnJHY","btnSHMD"},
			["call"] = {"btnSee","btnSL","btnZD","btnSHY","btnCALL"},
			-- ["panelGroup"]={"btnSee","btnSL","btnZD","btnJY","btnJHY"},
		}
	else
		btnArrs = {
			[0] = {"btnSee","btnSL","btnZD","btnJY","btnJHY","btnJCR","btnHMD"},
			[100] = {"btnSee","btnSL","btnZD","btnJY","btnSHY","btnJCR","btnHMD","btnJB"},
			[101] = {"btnSee","btnSL","btnZD","btnJY","btnJHY","btnHMD","btnSCR"},
			[102] = {"btnSee","btnSL","btnZD","btnJY","btnJHY","btnJCR","btnSHMD"},
			["call"] = {"btnSee","btnSL","btnZD","btnSHY","btnJCR","btnHMD","btnCALL"},
			-- ["panelGroup"]={"btnSee","btnSL","btnZD","btnJY","btnJHY","btnJCR","btnHMD"},
		}
	end

	if not self.btnType then
		self.btnType = checkint(releation)
	end
	local curData = btnArrs[self.btnType]
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		-- if not self.playerInView then
		-- 	return GameSocket:alertLocalMsg("玩家不在线,无法私聊", "alert")
		-- end
		if senderName=="btnSee" then
				GameSocket:CheckPlayerEquip(data.name)
		elseif senderName=="btnZD" then
			if checkint(GameSocket.mCharacter.mGroupID) ~= 0 then
				GameSocket:InviteGroup(data.name)
			else
				GameSocket:alertLocalMsg("你还没有队伍！", "alert")
			end
		elseif senderName=="btnJHY" then
			GameSocket:FriendChange(data.name,100)
		elseif senderName=="btnHMD" then
			GameSocket:FriendChange(data.name,102)
		elseif senderName=="btnSL" then
			-- if then
				GameSocket:addChatRecentPlayer(data.name)
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "main_friend",tab = 1})
			-- else
				-- GameSocket:alertLocalMsg("玩家不在线或不在附近,无法私聊", "alert")
			-- end
		elseif senderName=="btnJY" then
			GameSocket:TradeInvite(data.name)
		elseif senderName=="btnJCR" then
			GameSocket:FriendChange(data.name,101)
		elseif senderName=="btnSH" then

		elseif senderName=="btnSHY" then
			GameSocket:FriendChange(data.name,0)
		elseif senderName=="btnJB" then

		elseif senderName=="btnRD" then

		elseif senderName=="btnSCR" then
			GameSocket:FriendChange(data.name,0)
		elseif senderName=="btnSHMD" then
			GameSocket:FriendChange(data.name,0)
		end
		GComponentFriendMenu.close(self)
		if senderName=="btnCALL" then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str = "sendCallFriend",playerName = data.name,vcoin = 1000})
		end
	end
	-- for i=1,#btnArrs do
	-- 	local btn = self.xmlTips:getWidgetByName(btnArrs[i])
	-- 	GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	-- end

	self.xmlTips:getWidgetByName("imgTipsBg"):setTouchEnabled(true)
	local function updateItem(item)
		local btnName = curData[item.tag]
		local btn = item:getWidgetByName("btnMode")
			:setTitleText(btnNames[btnName])
			:setName(btnName)
			:setPressedActionEnabled(true)
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
		GUIAnalysis.attachEffect(btn,"outline(0e0600,1)")
	end
	local listBtn=self.xmlTips:getWidgetByName("listBtn")
	listBtn:setAnimateEnabled( true ):setSliderVisible(false):setTouchEnabled(false)
	listBtn:reloadData(#curData,updateItem,0,false)
end

function GComponentFriendMenu:close()
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_HIDE_TIPS,str = self.str})
end

return GComponentFriendMenu
