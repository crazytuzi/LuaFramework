local ContainerIM = {}
local var = {}

local CHANNEL_TAG = {
	ALL = 1, --综合
	-- HORN = 2,
	WORLD = 2, 
	GUILD = 3,
	GROUP = 4,
	CURRENT = 5,
	PRIVATE = 6,
	SYSTEM = 7,
}

local channelInfo = {

	[CHANNEL_TAG.ALL]  	  = {color = "f2e900", strChannel = GameConst.str_chat_system,		},
	[CHANNEL_TAG.WORLD]   = {color = "bd5fff", strChannel = GameConst.str_chat_world,	voiceChanne = "VoiceChannelWorld"},
	[CHANNEL_TAG.GUILD]   = {color = "3ff200", strChannel = GameConst.str_chat_guild,	voiceChanne = "VoiceChannelGuild"},
	[CHANNEL_TAG.GROUP]   = {color = "009af2", strChannel = GameConst.str_chat_group,	voiceChanne = "VoiceChannelGroup"},
	[CHANNEL_TAG.CURRENT] = {color = "f2ab00", strChannel = GameConst.str_chat_near,	voiceChanne = "VoiceChannelNear"},
	[CHANNEL_TAG.PRIVATE] = {color = "C8C8C8", strChannel = GameConst.str_chat_private,	},
}
local msg_img_key ={
	[GameConst.str_chat_all]	={	img = "img_chat_world",		colorStr = "fff843",	typeColor = "ff0000",	},
	[GameConst.str_chat_system]	={	img = "img_chat_system",	colorStr = "FFFF00",	typeColor = "FFFF00",	},
	[GameConst.str_chat_world]	={	img = "img_chat_world",		colorStr = "3ff200",	typeColor = "bd5fff",	},
	[GameConst.str_chat_private]={	img = "img_chat_private",	colorStr = "FF11CF",	typeColor = "FF11CF",	},
	[GameConst.str_chat_guild]	={	img = "img_chat_guild",		colorStr = "f2e900",	typeColor = "3ff200",	},
	[GameConst.str_chat_group]	={	img = "img_chat_group",		colorStr = "009af2",	typeColor = "009af2",	},
	[GameConst.str_chat_shout]	={	img = "img_chat_horn",		colorStr = "ffffff",	typeColor = "e60ed4",	},
	[GameConst.str_chat_horn]	={	img = "img_chat_horn",		colorStr = "ffffff",	typeColor = "ff1fec",	},
	[GameConst.str_chat_common]	={	img = "img_chat_common",	colorStr = "ffffff",	typeColor = "ff9743",	},
	[GameConst.str_chat_near]	={	img = "img_chat_near",		colorStr = "fde5b2",	typeColor = "f2ab00",	},
}

local imgChannelLength = 46
local margin = 10
local charsize = 16

function ContainerIM.initView(extend)
	var = {
		xmlPanel,
		chaIndex = 1, -- 频道index

		defaultTab = CHANNEL_TAG.ALL,
		mapInfo,
		Amark,
		listlen = 0,
		chatView,
		viewSize = cc.size(100,400),
		cellSize = cc.size(100,70),
		modelTable = {},
		firstItemIndex = 0,
		lastItemIndex = 0,
		chatModel,
		tabList,
	}

	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerIM.uif")
	if var.xmlPanel then
		-- var.xmlPanel.mAlign = display.CENTER_LEFT
		-- var.xmlPanel.mPos = cc.p(-display.cx,0)
		var.xmlPanel:setContentSize(var.xmlPanel:getContentSize().width, display.height)
		GameUtilSenior.asyncload(var.xmlPanel, "chat_bg", "ui/image/chat_bg.png")
		--var.xmlPanel:getWidgetByName("chat_bg"):loadTexture("ui/image/chat_bg.png", ccui.TextureResType.localType)
		local chat_bg = var.xmlPanel:getWidgetByName("chat_bg")
		chat_bg:setContentSize(chat_bg:getContentSize().width, display.height)
			:setScale9Enabled(true)
			:setPositionY(0)
			:setAnchorPoint(cc.p(0,0))
		-- chat_bg:setTextureRect(cc.rect())
		if extend.tab then var.defaultTab = extend.tab end

		var.chaIndex = var.defaultTab
		var.xmlPanel:getWidgetByName("panel_close"):setPositionY(display.cy)
		var.headId = (GameCharacter._mainAvatar:NetAttr(GameConst.net_job)-100) *2 + GameCharacter._mainAvatar:NetAttr(GameConst.net_gender) - GameConst.SEX_MALE+1
		-- var.other_box = var.xmlPanel:getWidgetByName("other_box"):hide()
		-- var.self_box = var.xmlPanel:getWidgetByName("self_box"):hide()
		var.chatModel = var.xmlPanel:getWidgetByName("chatModel"):hide()

		-- var.voice_other_box = var.xmlPanel:getWidgetByName("voice_other_box"):hide()
		-- var.voice_self_box = var.xmlPanel:getWidgetByName("voice_self_box"):hide()
		local box_world = var.xmlPanel:getWidgetByName("box_world")
		box_world:setContentSize(box_world:getContentSize().width, display.height- 90)

		var.tabList = var.xmlPanel:getWidgetByName("tabList")
					:setFontSize(18)
					:setTabRes("common_big_tab_v2", "common_big_tab_v1")
					:setScaleEnabled(false)
					:setTabColor(GameBaseLogic.getColor(0xfddfae),GameBaseLogic.getColor(0xfddfae))
		var.tabList:setPositionY(display.height - var.tabList:getContentSize().height/2)
		var.tabList:addTabEventListener(ContainerIM.pushTabsButton)
		--var.tabList:setItemMargin(20)
		var.xmlPanel:getWidgetByName("setLayerbg"):hide()
			:setContentSize(display.width, display.height)
			:setTouchEnabled(true)
			:addClickEventListener(function ( ... )
				select(1,...):hide()
			end)
		var.xmlPanel:getWidgetByName("btn_join"):setPositionY(display.cy):setTouchEnabled(true)
		var.xmlPanel:getWidgetByName("setLayer"):setPosition(display.cx,display.cy):setTouchEnabled(true)
		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_CHAT_MSG, ContainerIM.handleNewChatMsg)
 			:addEventListener(GameMessageCode.EVENT_TALK_PANEL, ContainerIM.ShowHandle)
 			:addEventListener(GameMessageCode.EVENT_VOICE_HANDLE_MSG, ContainerIM.onVoiceMsgHandler)
 			-- :addEventListener(GameMessageCode.EVENT_VOICE_PLAY_FINISH, ContainerIM.onPlayVoiceFinish)
 		if PLATFORM_BANSHU then
 			--var.xmlPanel:getWidgetByName("img_input_bg"):size(260,40)
 		else
 			--var.xmlPanel:getWidgetByName("img_input_bg"):size(230,40)
 		end
		ContainerIM.initContainer()
		ContainerIM.initBottomToolKit()
		-- ContainerIM.onItemChange()
		return var.xmlPanel
	end
end

function ContainerIM.isMsgShow(netChat)
	local curChannel = channelInfo[var.chaIndex].strChannel
	if netChat.m_strMsg ~= "" and (netChat.m_strType == curChannel or var.chaIndex ==1) then
		return true
	end
end

function ContainerIM.pushTabsButton(pSender)
	var.chaIndex = pSender:getTag()
	ContainerIM.initChatView()
	ContainerIM.updateChatView()
	if GUILeftBottom then
		GUILeftBottom.changeChatChannel(var.chaIndex)
	end
	local btn_keyboard = var.xmlPanel:getWidgetByName("btn_keyboard")
	if not btn_keyboard.bright then btn_keyboard.bright =1 end

	local inputlayer = var.xmlPanel:getWidgetByName("inputlayer")
	local btn_press = var.xmlPanel:getWidgetByName("btn_press")
	local btn_join = var.xmlPanel:getWidgetByName("btn_join")
	local lblnoinfo = var.xmlPanel:getWidgetByName("lblnoinfo")
	local showChat,title,str,color = true,"","",0xA09696
	if var.chaIndex == CHANNEL_TAG.GUILD then
		-- local mGuild = GameSocket:getGuildByName(GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name))
		local mGuild = GameCharacter._mainAvatar:NetAttr(GameConst.net_guild_name)
		if not mGuild or mGuild == "" then
			showChat = false;title = "加入帮会";str = "当前未加入帮会"
		else
			showChat = true
		end
	elseif var.chaIndex == CHANNEL_TAG.GROUP then
		if #GameSocket.mGroupMembers == 0 then
			showChat = false;title = "创建队伍"	;str = "当前未加入队伍"
		else
			showChat = true
		end
	elseif var.chaIndex == CHANNEL_TAG.ALL then
		showChat = true
		str = "注：此频道不能发言，请切换到其他频道发言"
		title = " "
		color = 0xE7BA52
	elseif var.chaIndex == CHANNEL_TAG.PRIVATE then
		showChat = true
		str = "注：此频道不能发言，请切换到其他频道发言"
		title = " "
		color = 0xE7BA52
	else
		showChat = true
		title = ""
	end
	var.chatView:setVisible(showChat)
	btn_join:setTitleText(title):setVisible(#title>0 and title ~=" ")
	lblnoinfo:setString(str):setColor(GameBaseLogic.getColor(color)):setVisible(#title>0)
	--btn_keyboard:setVisible(showChat and #title==0)
	
	inputlayer:setVisible(btn_keyboard.bright == 1 and #title==0)
	btn_press:setVisible(btn_keyboard.bright==0 and #title==0)
	if PLATFORM_BANSHU then
		btn_keyboard:hide()
	end
end

function ContainerIM.onPanelOpen(extend)
	if extend.tab then
		var.defaultTab = extend.tab
		var.chaIndex = extend.tab
	end

	GameBaseLogic.isChatOpen = true

	var.tabList:setSelectedTab(var.defaultTab)
end

function ContainerIM.initChatView()
	var.viewSize = {}
	var.viewSize.width = var.xmlPanel:getWidgetByName("box_world"):getContentSize().width - charsize
	var.viewSize.height = var.xmlPanel:getWidgetByName("box_world"):getContentSize().height
	if not GameUtilSenior.isObjectExist(var.chatView) then
		var.chatView = cc.ScrollView:create(var.viewSize)
		var.chatView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
		var.chatView:ignoreAnchorPointForPosition(true)

		var.chatView:setDelegate()
		var.chatView:setClippingToBounds(true)
		var.chatView:setBounceable(true)
		var.chatView:addTo(var.xmlPanel:getWidgetByName("box_world")):align(display.LEFT_BOTTOM, 0, 0)
		var.chatView:setLocalZOrder(0)
	
		local function scrollViewDidScroll()
			if not GameUtilSenior.isObjectExist(var.chatView) then return end

			local container = var.chatView:getContainer()
			local offsetY = var.chatView:getContentOffset().y
			local height = container:getContentSize().height

			--上面移除
			if var.firstItemIndex>=1 and var.modelTable[var.firstItemIndex] and offsetY + var.modelTable[var.firstItemIndex]:getPositionY() > var.viewSize.height+30 and offsetY<0  then
				var.modelTable[var.firstItemIndex]:removeFromParent()
				-- print("remove first-------",var.firstItemIndex)
				var.firstItemIndex = var.firstItemIndex + 1
			---下面移除
			elseif var.lastItemIndex >1 and var.modelTable[var.lastItemIndex] and
				offsetY + var.modelTable[var.lastItemIndex]:getPositionY() + var.modelTable[var.lastItemIndex]:getContentSize().height + 10 < 0 then
				-- print("··remove last-----",var.lastItemIndex)
				var.modelTable[var.lastItemIndex]:removeFromParent()
				var.lastItemIndex = var.lastItemIndex - 1
			end

 			--上面添加
			local firstModel = var.modelTable[var.firstItemIndex]
			if var.firstItemIndex>1 and offsetY + var.modelTable[var.firstItemIndex]:getPositionY() + var.modelTable[var.firstItemIndex]:getContentSize().height + 10 < var.viewSize.height and not container:getChildByTag(var.firstItemIndex - 1) then
				local item = ContainerIM.getModel(var.firstItemIndex - 1)
				local firstModel = var.modelTable[var.firstItemIndex]
				local firstPosY = firstModel:getPositionY()
				if item  then
					firstPosY = firstPosY + firstModel:getContentSize().height + margin
					item:addTo(var.chatView):align(display.BOTTOM_LEFT, 0, firstPosY)
					var.firstItemIndex = var.firstItemIndex - 1
					item:setTag(var.firstItemIndex)
					-- print("first add ",var.firstItemIndex,firstPosY)

					if firstPosY + item:getContentSize().height + margin > height then
						height = firstPosY + item:getContentSize().height + margin
						container:setContentSize(cc.size(var.viewSize.width,height))
					end
					if var.firstItemIndex == 1 then
						container:setContentSize(cc.size(var.viewSize.width,firstPosY + item:getContentSize().height))
					end
				end
			end
			--下面添加
			if var.lastItemIndex > 0 and var.modelTable[var.lastItemIndex] and offsetY + var.modelTable[var.lastItemIndex]:getPositionY() >= 0 and var.lastItemIndex < var.listlen 
				and not container:getChildByTag(var.lastItemIndex + 1) then
				local item = ContainerIM.getModel(var.lastItemIndex + 1)
				if item then
					local lastModel = var.modelTable[var.lastItemIndex]
					local modelHeight = item:getContentSize().height
					local lastPosY = lastModel:getPositionY() - modelHeight - 10
					var.lastItemIndex = var.lastItemIndex + 1
					
					item:setTag(var.lastItemIndex)
					item:addTo(var.chatView)
						:align(display.BOTTOM_LEFT, 0, lastPosY)
					if lastPosY<0 then
						local children = container:getChildren()
						for k,v in pairs(children) do
							v:setPositionY(v:getPositionY() - lastPosY)
						end
						height = container:getContentSize().height - lastPosY
						container:setContentSize(cc.size(var.viewSize.width,height))
						container:setPositionY(lastPosY)
					end
				end
			end
		end
		if not var.freshHandle then
			var.freshHandle = Scheduler.scheduleGlobal(scrollViewDidScroll,1/60)
		end
		-- var.chatView:registerScriptHandler(scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL)
	end
	var.chatView:getContainer():removeAllChildren()
	var.chatView:setViewSize(var.viewSize)
	var.chatView:setContentSize(var.viewSize)
	var.firstItemIndex = 0
	var.lastItemIndex = 0	--if var.chatView has chaildren then reset itemindex
end

function ContainerIM.getModel(index)
	local mChannerHistory = ContainerIM.updateChannelHistory()
	local model = nil
	local netChat = mChannerHistory[index]
	if var.modelTable[index] then
		return var.modelTable[index]
	else
		if netChat then
			local curChannel = channelInfo[var.chaIndex].strChannel
			if curChannel == netChat.m_strType or var.chaIndex == CHANNEL_TAG.ALL then
				model = ContainerIM.combineDialogBox(netChat)
				if not model then return nil end
				var.modelTable[index] = model
				model:setTag(index)
				model:retain()
				return model
			end
		end
	end
end

function ContainerIM.getListLen()
	local len = 0
	local mChannerHistory = ContainerIM.updateChannelHistory()
	local netChat
	for i=1,#mChannerHistory do
		netChat = mChannerHistory[i]
		if ContainerIM.isMsgShow(netChat) then
			if netChat.m_strType == GameConst.str_chat_system and netChat.m_strMsg ~= "" then --系统用文字
				len = len + 1
			else
				len = len + 1
			end
		end
	end
	return len
end

function ContainerIM.onPanelClose()
	if GameUtilSenior.isObjectExist(var.box_VoiceSetting) then var.box_VoiceSetting:hide() end
	var.chaIndex	=nil
	var.defaultTab = CHANNEL_TAG.ALL

	var.mapInfo = nil
	var.Amark = nil

	if var.freshHandle then
		Scheduler.unscheduleGlobal(var.freshHandle)
		var.freshHandle = nil
	end

	GameBaseLogic.isChatOpen = false
	if GameUtilSenior.isObjectExist(var.chatView) then
		var.chatView:getContainer():removeAllChildren()
	end
	GameSetting.save()
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_VOICE_HANDLE,vis = false, send = false})
end

function ContainerIM.handleNewChatMsg(event)
	if not GameBaseLogic.isChatOpen or not var.chaIndex or not event.msg then return end
	local netChat = event.msg
	local model
	if ContainerIM.isMsgShow(netChat) then
		model = ContainerIM.combineDialogBox(netChat)
		if model then
			var.listlen = ContainerIM.getListLen()
			local maxIndex = 0
			for k,v in pairs(var.modelTable) do
				if k>maxIndex then maxIndex = k end
			end
			if maxIndex>=200 then
				for i=1,maxIndex-199 do
					if var.modelTable[1] then
						if var.modelTable[1]:getParent() then
							var.modelTable[1]:removeFromParent()
						end
						var.modelTable[1]:release()
						var.modelTable[1] = nil
					end
					for i=1,maxIndex-1 do
						if var.modelTable[i+1] then
							var.modelTable[i] = var.modelTable[i+1]
							var.modelTable[i]:setTag(i)
						end
					end
					maxIndex = maxIndex - 1
				end
			end
			local container = var.chatView:getContainer()
			local offsetY = var.chatView:getContentOffset().y
			local containerHeight = var.chatView:getContentSize().height
			local lastModel = container:getChildByTag(maxIndex)
			local modelHeight = model:getContentSize().height
			local lastPosY = var.viewSize.height
			if lastModel  then
				-- lastPosY = lastModel:getPositionY() - modelHeight - 10
				if lastModel.targetPos then
					lastPosY = lastModel.targetPos - modelHeight - 10
				else
					lastPosY = lastModel:getPositionY() - modelHeight - 10
				end
			else
				lastPosY = lastPosY - modelHeight -10
			end

			var.modelTable[maxIndex+1] = model
			model:retain()
			model:setTag(maxIndex+1)

			if lastPosY < 0 and var.lastItemIndex >= maxIndex then
				local childrenOffsetY = 0
				if lastPosY + modelHeight + 10 >0 then
					containerHeight = containerHeight - lastPosY
					offsetY = offsetY + lastPosY
					childrenOffsetY = - lastPosY
				else
					containerHeight = containerHeight + modelHeight + 10
					offsetY = offsetY - modelHeight - 10
					childrenOffsetY =  modelHeight + 10
				end
				container:setContentSize(cc.size(var.viewSize.width,containerHeight))
				container:setPositionY(offsetY)

				local children = container:getChildren()
				for k,v in pairs(children) do
					v:setPositionY(v:getPositionY() + childrenOffsetY)
				end
			end
			-- var.chatView:setContentOffset({x=0,y=0})
			if var.lastItemIndex < maxIndex  then
				-- 不添加
			else
				-- 添加
				var.lastItemIndex = var.lastItemIndex + 1
				model:addTo(var.chatView)
					:align(display.BOTTOM_LEFT, 0,  - modelHeight -10)
					:runAction(cca.moveTo(0.1, 0, lastPosY>0 and lastPosY or 0))
				-- 
				model.targetPos = lastPosY>0 and lastPosY or 0
				if lastPosY < 0 then
					container:runAction(cca.seq{
						cca.cb(function() 
							container:setPositionY(lastPosY)
							offsetY = 0
						end),
						cca.moveBy(0.1, 0, -lastPosY)
					})
				end
			end

		end
	end
end

function ContainerIM.initEditbox(parent)
	local function onEdit(event,editBox)
		if event == "began" then
		elseif event == "changed" then
		elseif event == "ended" then
		elseif event == "return" then
			local msg = editBox:getText()
			if string.sub(msg,1,1) ~= "@" then
				msg,_ = string.gsub(msg," ","")
				editBox:setString(msg)
			end
		end
	end
	if not parent:getChildByTag(100) then
		var.mSendText = GameUtilSenior.newEditBox({
			image = "image/icon/null.png",
			size = parent:getContentSize(),
			listener = onEdit,
			x = 0,
			y = 0,
			placeHolderColor = GameBaseLogic.getColor(0x827b6e),
			placeHolderSize = 22,
			anchor = cc.p(0,0),
			fontSize = 22,
			placeHolder = GameConst.str_input,
			-- inputMode = cc.EDITBOX_INPUT_MODE_ANY,
		})
		parent:addChild(var.mSendText,1,100)
	else
		var.mSendText = parent:getChildByTag(100)
		var.mSendText:setString("")
	end
end

function ContainerIM.changeInputModel()
	local btn_press = var.xmlPanel:getWidgetByName("btn_press")
	local inputlayer = var.xmlPanel:getWidgetByName("inputlayer")
	local vis = btn_press:isVisible()
	btn_press:setVisible( not vis)
	inputlayer:setVisible( vis)
end

function ContainerIM.setEmojVisible()
	local height = var.xmlPanel:getWidgetByName("Container"):getContentSize().height

	var.xmlPanel:runAction(cca.seq({
		cca.moveTo(0.2, var.xmlPanel:getPositionX(), var.xmlPanel:getPositionY()+(var.xmlPanel.isShow and -height or height)),
		cca.cb(function ()
			var.xmlPanel.isShow = not var.xmlPanel.isShow
		end)
	}))
end

local equip_info = {
	{pos = GameConst.ITEM_WEAPON_POSITION,	etype = GameConst.EQUIP_TAG.WEAPON},
	{pos = GameConst.ITEM_CLOTH_POSITION,	etype = GameConst.EQUIP_TAG.CLOTH},
	{pos = GameConst.ITEM_GLOVE1_POSITION,	etype = GameConst.EQUIP_TAG.GLOVE},
	{pos = GameConst.ITEM_RING1_POSITION,	etype = GameConst.EQUIP_TAG.RING},
	{pos = GameConst.ITEM_BOOT_POSITION,	etype = GameConst.EQUIP_TAG.BOOT},

	{pos = GameConst.ITEM_HAT_POSITION,		etype = GameConst.EQUIP_TAG.HAT},
	{pos = GameConst.ITEM_NICKLACE_POSITION,etype = GameConst.EQUIP_TAG.NECKLACE},
	{pos = GameConst.ITEM_GLOVE2_POSITION,	etype = GameConst.EQUIP_TAG.GLOVE},
	{pos = GameConst.ITEM_RING2_POSITION,	etype = GameConst.EQUIP_TAG.RING},
	{pos = GameConst.ITEM_BELT_POSITION,	etype = GameConst.EQUIP_TAG.BELT},

	{pos = GameConst.ITEM_JADE_PENDANT_POSITION,	noTipsBtn = true},
	{pos = GameConst.ITEM_SHIELD_POSITION,			noTipsBtn = true},
	{pos = GameConst.ITEM_MIRROR_ARMOUR_POSITION,	},
	{pos = GameConst.ITEM_FACE_CLOTH_POSITION,		},
	{pos = GameConst.ITEM_DRAGON_HEART_POSITION,	noTipsBtn = true},
	{pos = GameConst.ITEM_WOLFANG_POSITION,			noTipsBtn = true},
	{pos = GameConst.ITEM_DRAGON_BONE_POSITION,		},
	{pos = GameConst.ITEM_CATILLA_POSITION,			},
}
function ContainerIM.clickItem(sender)
	local netItem = sender.netItem
	local itemdef = GameSocket:getItemDefByID(netItem.mTypeID)
	if netItem and itemdef then
		local str = var.mSendText:getText()
		str = str.."##"..itemdef.mName..","..netItem.position.."##,"
		var.mSendText:setText(str)
	end
end

function ContainerIM.onItemChange(event)
	local equipList = var.xmlPanel:getWidgetByName("equipList")
	local equips,netItem = {}
	for k,v in pairs(equip_info) do
		netItem = GameSocket:getNetItem(v.pos)
		if netItem then
			table.insert(equips,netItem)
		end
	end
	for i=0,GameConst.ITEM_BAG_SIZE + GameSocket.mBagSlotAdd do
		netItem = GameSocket:getNetItem(i)
		if netItem then
			table.insert(equips,netItem)
		end
	end
	equipList:reloadData(#equips, function(subItem)
		local item = equips[subItem.tag]
		subItem:getWidgetByName("cellbg"):setTouchEnabled(true):setTouchSwallowEnabled(false)
		subItem:getWidgetByName("cellbg"):addClickEventListener(ContainerIM.clickItem)
		subItem:getWidgetByName("cellbg").netItem = item
		-- local itemdef = GameSocket:getItemDefByID(item.mTypeID)
		-- if itemdef then
		-- 	subItem:getWidgetByName("icon")
		-- 		:setTouchSwallowEnabled(false)
		-- 		:loadTextureNormal("image/icon/"..itemdef.mIconID..".png")
		-- 		:addClickEventListener(ContainerIM.clickItem)
		-- 	subItem:getWidgetByName("icon").netItem = item
		-- end
		GUIItem.getItem({
			parent = subItem,--:getWidgetByName("cellbg"),
			typeId = item.mTypeID,
			mLevel = item.mLevel,
			mZLevel = item.mZLevel,
			iconType = 10,
			callBack = function ()
				print("···")
			end
		})
		subItem:setTouchEnabled(false):setTouchSwallowEnabled(false)
		subItem:getWidgetByName("item_icon"):setTouchEnabled(false):setTouchSwallowEnabled(false)
	end)
end

function ContainerIM.initContainer() -- 表情窗 和 快捷键
	local height = var.xmlPanel:getWidgetByName("Container"):getContentSize().height
	var.xmlPanel:getWidgetByName("Container")
		:setLocalZOrder(3)
		:align(display.LEFT_TOP, 0, 0)
		:setSwallowTouches(true)
		:setContentSize(display.width,height)
		:setTouchEnabled(true)
	local function pushEmojPng(sender)
		local tag = sender:getTag()
		var.mSendText:setString(var.mSendText:getText()..GameConst.expressions_item[tag][1])
		-- ContainerIM.changeInputModel()
	end
	local function initEmojPng()
		local facelist = var.xmlPanel:getWidgetByName("emoj_bg")
		local bgSize = facelist:getContentSize()
		for i=1,2 do
			for j=1,10 do
				local id = (i-1)*10 + j
				if not facelist:getChildByTag(id) then
					local imgFace = ccui.Button:create()
					imgFace:loadTextureNormal(GameConst.expressions_item[id][2],ccui.TextureResType.plistType)
					imgFace:setTag(id)
					imgFace:setPosition(cc.p(bgSize.width/10.5*j-20,bgSize.height+30-bgSize.height/2.5*i))
					imgFace:setTouchEnabled(true)
					imgFace:addClickEventListener(pushEmojPng)
					facelist:addChild(imgFace)
				end
			end
		end
	end
	initEmojPng()
end

function ContainerIM.initBottomToolKit()
	local btns ={
		{name ="btn_face",		},
		{name ="btn_keyboard",	},
		{name ="btn_send",		},
		{name ="btn_face_t",	},
		{name ="btn_position",	},
		{name ="btn_set",	},
		{name ="btn_close",	},
		{name ="checkbox1",	selected = GameSetting.getConf("VoiceChannelNear")},
		{name ="checkbox2",	selected = GameSetting.getConf("VoiceChannelWorld")},
		{name ="checkbox3",	selected = GameSetting.getConf("VoiceChannelGroup")},
		{name ="checkbox4",	selected = GameSetting.getConf("VoiceChannelGuild")},
		{name ="btn_join",	},
		{name ="btn_equip_bag",	},

	}
	local function pushBtns( psender )
		if psender:getName() =="btn_face" then
			if var.box_VoiceSetting then var.box_VoiceSetting:hide() end
			ContainerIM.setEmojVisible()
		elseif  psender:getName() =="btn_keyboard" then
			ContainerIM.changeInputModel()
			if var.xmlPanel.isShow then
				ContainerIM.setEmojVisible()
			end
			if not psender.bright then psender.bright =1 end
			local res = psender.bright ==1 and "img_keyboard" or "img_keyboard_sel"
			psender:loadTextures(res,res,res,ccui.TextureResType.plistType)
			psender.bright = 1 - psender.bright
		elseif  psender:getName() =="btn_send" then
			ContainerIM.sendMsg()
			if var.xmlPanel.isShow then
				ContainerIM.setEmojVisible()
			end
		elseif  psender:getName() =="btn_set" then
			var.xmlPanel:getWidgetByName("setLayerbg"):show()

		elseif  psender:getName() =="btn_position" then
			ContainerIM.setEmojVisible()
			local pos = GameCharacter._mainAvatar:PAttr(GameConst.AVATAR_X)..",".. GameCharacter._mainAvatar:PAttr(GameConst.AVATAR_Y)
			local minimap = GameSocket.mNetMap
			var.mapInfo	= minimap.mName.." "..pos
			var.Amark = "<a underline=00ff00 color=#00ff00 href=\'event:local_goto_"..minimap.mMapID.."_"..GameCharacter._mainAvatar:PAttr(GameConst.AVATAR_X).."_"..GameCharacter._mainAvatar:PAttr(GameConst.AVATAR_Y).."\'>"..var.mapInfo.."</a>"
			var.mSendText:setString(var.mSendText:getText().." "..var.mapInfo.." ")
		elseif  psender:getName() =="btn_close" then
			var.xmlPanel:getWidgetByName("setLayerbg"):hide()
		elseif  psender:getName() =="checkbox1" then
			GameSetting.setConf("VoiceChannelNear",psender:isSelected())
		elseif  psender:getName() =="checkbox2" then
			GameSetting.setConf("VoiceChannelWorld",psender:isSelected())
		elseif  psender:getName() =="checkbox3" then
			GameSetting.setConf("VoiceChannelGroup",psender:isSelected())
		elseif  psender:getName() =="checkbox4" then
			GameSetting.setConf("VoiceChannelGuild",psender:isSelected())
		elseif  psender:getName() =="btn_join" then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = var.chaIndex == CHANNEL_TAG.GUILD and "main_guild" or "main_group",from = "panel_chat"})
		elseif  psender:getName() =="btn_face_t" then
			var.xmlPanel:getWidgetByName("equipList"):setVisible(false)
			var.xmlPanel:getWidgetByName("emoj_bg"):setVisible(true)
		elseif  psender:getName() =="btn_equip_bag" then
			var.xmlPanel:getWidgetByName("equipList"):setVisible(true)
			var.xmlPanel:getWidgetByName("emoj_bg"):setVisible(false)
			ContainerIM.onItemChange()
		end
	end
	for k,v in pairs(btns) do
		local btn = var.xmlPanel:getWidgetByName(v.name)
		if btn then
			btn:addClickEventListener(pushBtns)
			if v.selected~=nil then
				btn:setSelected(v.selected)
			end
		end
	end
	var.xmlPanel:getWidgetByName("btn_press"):addTouchEventListener(function( sender,touchtype )
		if sender and touchtype == ccui.TouchEventType.began then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_VOICE_HANDLE,vis = true,channel = channelInfo[var.chaIndex].voiceChanne})
		elseif sender and touchtype == ccui.TouchEventType.ended or touchtype == ccui.TouchEventType.canceled then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_VOICE_HANDLE,vis = false, send = GameUtilSenior.hitTest(sender, sender:getTouchEndPosition())})
		else
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_VOICE_HANDLE, charVis = not GameUtilSenior.hitTest(sender, sender:getTouchMovePosition())})
		end
	end)

	ContainerIM.initEditbox(var.xmlPanel:getWidgetByName("img_input_bg"))
end

function ContainerIM.updateChatView() --刷新当前页
	for k,v in pairs(var.modelTable) do
		v:release()
		v=nil
	end

	var.listlen = ContainerIM.getListLen()
	var.modelTable={}

	local height = 0
	var.firstItemIndex = var.listlen + 1
	var.lastItemIndex = 0
	while var.firstItemIndex >1 do
		local item = ContainerIM.getModel(var.firstItemIndex - 1)
		var.firstItemIndex = var.firstItemIndex - 1
		if item then
			item:addTo(var.chatView):align(display.BOTTOM_LEFT, 0, height)
			height = height + item:getContentSize().height + margin
			var.modelTable[var.firstItemIndex] = item
			item:setTag(var.firstItemIndex)
			if var.lastItemIndex < var.firstItemIndex then
				var.lastItemIndex = var.firstItemIndex
			end
			if height >= var.viewSize.height then break end
		end
	end

	if height < var.viewSize.height then
		local children = var.chatView:getContainer():getChildren()
		for k,v in pairs(children) do
			v:setPositionY(v:getPositionY() + var.viewSize.height - height + margin)
		end
	end

	local containerHeight = var.viewSize.height
	if var.lastItemIndex > var.firstItemIndex then
		containerHeight = var.listlen*height/(var.lastItemIndex - var.firstItemIndex)
	end
	if var.firstItemIndex ==1 then
		var.chatView:getContainer():setContentSize(cc.size(var.viewSize.width,height>var.viewSize.height and height or var.viewSize.height))
	else
		var.chatView:getContainer():setContentSize(cc.size(var.viewSize.width,containerHeight>var.viewSize.height and containerHeight or var.viewSize.height))
	end

	if var.chatView:minContainerOffset().y <= var.viewSize.height and var.chatView:minContainerOffset().y >0 then
		var.chatView:setContentOffset({x=0,y=var.chatView:minContainerOffset().y},false)
	else
		var.chatView:setContentOffset({x=0,y=var.chatView:maxContainerOffset().y},false)
	end
end

function ContainerIM.addLabelEventListener(label)--点击头像显示快捷按钮界面
	label:setTouchEnabled(true):addClickEventListener(function(sender)
		if sender.data and sender.data.m_strName ~= GameBaseLogic.chrName then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = {
				name = sender.data.m_strName,
				job = sender.data.m_job,
				gender = sender.data.m_gender,
				level = sender.data.m_lv,
				vip = sender.data.m_vip,
				guild = sender.data.m_guild,
			}})
		end
	end)
end

function ContainerIM.newModelBox(netChat)
	local colorStr = msg_img_key[netChat.m_strType].colorStr
	local strMsg = netChat.m_strMsg
	local isVoice = false
	if netChat.localPath or netChat.httpPath then
		isVoice = true
	end
	local name = netChat.m_strName or ""
	local namel = ""--netChat.m_strName and "<a color=#C8C8C8 outline=\'0,0,0,0,1\' href=\'event:local_chat_"..name.."\'>"..netChat.m_strName..":</a>" or " "
	if netChat.m_strType == GameConst.str_chat_private and netChat.m_MyName == GameBaseLogic.chrName then

		namel = netChat.m_strName and "<a color=#00cae2 outline=\'0,0,0,0,1\' href=\'event:local_chat_"..name.."\'>我对"..netChat.m_strName.."说:</a>" or " "

	else
		namel = netChat.m_strName and "<a color=#00cae2 outline=\'0,0,0,0,1\' href=\'event:local_chat_"..name.."\'>"..netChat.m_strName..":</a>" or " "
	end
	local content = namel.."<font outline=\'0,0,0,0,1\' color=#"..colorStr..">"..strMsg.."</font>"
	strMsg = string.format("%s%s",netChat.m_strType,content)
	strMsg,len = ContainerIM.callength(strMsg)
	len = GameUtilSenior.bound(30, len, var.viewSize.width)
	if isVoice then
		local model = var.chatModel:clone():show():setAnchorPoint(cc.p(0,0))
		local lbl_name = model:getWidgetByName("lbl_name"):setColor(GameBaseLogic.getColor(0xc8c8c8))
		lbl_name:setString(name)
		local btn_model_voice = model:getWidgetByName("btn_model_voice")
		btn_model_voice:setPosition(lbl_name:getContentSize().width+lbl_name:getPositionX()+10,model:getContentSize().height/2)
		btn_model_voice:setContentSize(cc.size(100,30))
		btn_model_voice:addClickEventListener(GDivRecord.playVoice)
		btn_model_voice.filepath = netChat.localPath
		btn_model_voice.url = netChat.httpPath
		btn_model_voice.duration = netChat.duration
		btn_model_voice.flag = netChat.flag
		btn_model_voice.selfvoice = name == GameBaseLogic.chrName
		model:getWidgetByName("chatTime"):setString(math.ceil(netChat.duration/1000).."\"" or ""):setPosition(105,30/2)

		local res = msg_img_key[netChat.m_strType].img
		model:getWidgetByName("btn_channel"):loadTextures(res,res,res,ccui.TextureResType.plistType):setTitleText("")
		if #name >0 then
			lbl_name.data = netChat
			ContainerIM.addLabelEventListener(lbl_name)
		end

		return model
	else
		local richWidget = GUIRichLabel.new({size= cc.size(len, 0), space=8,name="other"})
		-- strMsg = "<font outline=\'0,0,0,0,10\'>"..strMsg.."</font>"
		richWidget:setRichLabel(strMsg, "panel_chat", charsize)
		return richWidget
	end
end

function ContainerIM.combineDialogBox(netChat) --model 生产器
	if true then
		return ContainerIM.newModelBox(netChat)
	end
	local colorStr = msg_img_key[netChat.m_strType].colorStr
	local strMsg = netChat.m_strMsg
	local isVoice = false
	if netChat.localPath or netChat.httpPath then
		isVoice = true
	end
	local vip = netChat.m_vip

	strMsg = "<font color=#"..colorStr..">"..strMsg.."</font>"
	local name = netChat.m_strName or ""
	local len = 0
	local boxType
	strMsg,len = ContainerIM.callength(strMsg)

	if netChat.m_strName == GameBaseLogic.chrName or netChat.m_MyName == GameBaseLogic.chrName then
		boxType = isVoice and "self_voice" or"self"
		vip = GameSocket:getPlayerModel(GameCharacter._mainAvatar:NetAttr(GameConst.net_id),5)
	else
		boxType = isVoice and "other_voice" or "other"
	end
	vip = 0
	local maxlen = var.viewSize.width-- var.chatView:getViewSize().width
	len = GameUtilSenior.bound(20, len, maxlen-50)
	local model = nil
	local realheight,richWidget,lbl_name
	if boxType == "self" then
		model = var.self_box:clone():show():setAnchorPoint(cc.p(0,1))		
		
		richWidget = GUIRichLabel.new({size= cc.size(len, 0), space=8,name="self"})
		richWidget:setRichLabel(strMsg, "panel_chat", 20)
		realheight = richWidget:getContentSize().height >48 and richWidget:getContentSize().height+10 or 48

		lbl_name = model:getWidgetByName("lbl_name")
			:setString(GameBaseLogic.chrName)
			:setAnchorPoint(cc.p(1,1))
			:setPosition(maxlen - 54,realheight+23)
		model:getWidgetByName("img_bg")
			:setScale9Enabled(true)
			:setAnchorPoint(cc.p(1,0))
			:setCapInsets(cc.rect(4,34,80,4))
			:setPosition(cc.p(maxlen-6,0))
			:setContentSize(cc.size(len+25,realheight>48 and realheight or realheight))
			:setOpacity(60)

		richWidget:align(display.CENTER_LEFT,12,(realheight+10)/2)
			:addTo(model:getWidgetByName("img_bg"))

		model:setContentSize(len+30,model:getWidgetByName("img_bg"):getContentSize().height+26)
		model:getWidgetByName("btn_channel")
			:setPosition(cc.p(maxlen-4,model:getWidgetByName("img_bg"):getContentSize().height+26))

	elseif boxType == "other" then
		model = var.other_box:clone():show():setAnchorPoint(cc.p(0,1))
		richWidget = GUIRichLabel.new({size= cc.size(len, 0), space=8,name="other"})
		richWidget:setRichLabel(strMsg, "panel_chat", 20)
		realheight = richWidget:getContentSize().height >48 and richWidget:getContentSize().height+10 or 48

		lbl_name = model:getWidgetByName("lbl_name")
			:setString(name)
			:setPosition(50,realheight+23)

		if #name >0 then
			lbl_name.data = netChat
			ContainerIM.addLabelEventListener(lbl_name)
		end
		
		model:getWidgetByName("img_bg")
			:setScale9Enabled(true)
			:setAnchorPoint(cc.p(0,0))
			:setCapInsets(cc.rect(15,35,80,5))
			:setPosition(cc.p(6,0))
			:setContentSize(cc.size(len+20,realheight>48 and realheight or realheight))
			:setOpacity(60)

		richWidget:align(display.CENTER_LEFT,18,(realheight+10)/2)
			:addTo(model:getWidgetByName("img_bg"))
		model:setContentSize(maxlen,model:getWidgetByName("img_bg"):getContentSize().height+26)
		model:getWidgetByName("btn_channel")
			:setPosition(cc.p(0,model:getWidgetByName("img_bg"):getContentSize().height+26))

	elseif boxType =="self_voice" then
		model = var.voice_self_box:clone():show():setAnchorPoint(cc.p(0,1))		
		realheight = 10

		lbl_name = model:getWidgetByName("lbl_name")
			:setString(GameBaseLogic.chrName)
			:setAnchorPoint(cc.p(1,1))
			:setPosition(maxlen - 50,realheight+67)
		model:getWidgetByName("chatTime"):setString(math.ceil(netChat.duration/1000).."\"" or ""):setPositionY((realheight+35)/2)

		model:getWidgetByName("btn_model_voice")
			:setPosition(cc.p(model:getContentSize().width-50,realheight+41))
			:addClickEventListener(GDivRecord.playVoice)
		model:getWidgetByName("btn_model_voice").filepath = netChat.localPath
		model:getWidgetByName("btn_model_voice").url = netChat.httpPath
		model:getWidgetByName("btn_model_voice").duration = netChat.duration
		model:getWidgetByName("btn_model_voice").flag = netChat.flag
		model:getWidgetByName("btn_model_voice").selfvoice = true
		model:getWidgetByName("img_voice_chat"):setPosition(85,(realheight+35)/2):loadTexture("img_chat_voice3", ccui.TextureResType.plistType)

		model:setContentSize(model:getContentSize().width,67+realheight)
		model:getWidgetByName("btn_channel")
			:setPosition(cc.p(maxlen-4,model:getWidgetByName("btn_model_voice"):getContentSize().height+32))

	elseif boxType =="other_voice" then
		model = var.voice_other_box:clone():show():setAnchorPoint(cc.p(0,1))

		realheight = 10

		lbl_name = model:getWidgetByName("lbl_name")
			:setString(name)
			:setPosition(50,realheight+67)
		lbl_name.data = netChat
		ContainerIM.addLabelEventListener(lbl_name)
		model:getWidgetByName("chatTime"):setString(math.ceil(netChat.duration/1000).."\"" or ""):setPosition(115,(realheight+35)/2)

		model:getWidgetByName("btn_model_voice")
			:setPosition(cc.p(50,realheight+41))
			:addClickEventListener(GDivRecord.playVoice)
		model:getWidgetByName("btn_model_voice").filepath = netChat.localPath
		model:getWidgetByName("btn_model_voice").url = netChat.httpPath
		model:getWidgetByName("btn_model_voice").duration = netChat.duration
		model:getWidgetByName("btn_model_voice").flag = netChat.flag
		model:getWidgetByName("btn_model_voice").selfvoice = false
		model:getWidgetByName("img_voice_chat"):setPosition(25,(realheight+35)/2):loadTexture("img_chat_voice3", ccui.TextureResType.plistType)

		model:setContentSize(model:getContentSize().width+20,realheight+67)
		model:getWidgetByName("btn_channel")
			:setPosition(cc.p(0,model:getWidgetByName("btn_model_voice"):getContentSize().height+32))
	end
	local res = msg_img_key[netChat.m_strType].img
	model:getWidgetByName("btn_channel"):loadTextures(res,res,res,ccui.TextureResType.plistType):setTitleText("")

	local vipLevel = model:getWidgetByName("vipLevel")
	if checknumber(vip)>0 then
		vipLevel:show()
		vipLevel:setString(string.format("[VIP%d]",vip))
		local vipSize = vipLevel:getContentSize().width
		local nameSize = lbl_name:getContentSize().width
		if string.find(boxType,"other") then
			vipLevel:setPosition(lbl_name:getPositionX(),lbl_name:getPositionY())
			lbl_name:setPositionX(vipLevel:getPositionX()+vipSize)
		else
			vipLevel:setPosition(lbl_name:getPositionX()-nameSize,lbl_name:getPositionY())
		end
	else
		vipLevel:hide()
	end
	return model
end

function ContainerIM.callength( strMsg,size ) --根据字体大小计算长度
	if not size then size = 22 end
	local len,num = 0,0
	local cloneStr,n = GameBaseLogic.clearHtmlText(strMsg)
	local length = cc.SystemUtil:getUtf8StrLen(cloneStr)
	len = (#cloneStr+length)*(size/4) --+ n/2*15 --加超链接的要多加10像素

	for j=1,#GameConst.expressions_item do
		strMsg,num = string.gsub(strMsg,GameConst.expressions_item[j][1],"<pic src=\'img_"..GameConst.expressions_item[j][2].."\'/>")
		if num>0 then
			len = len + num * (31 - (size/2*3))
		end
	end

	for k,v in pairs(channelInfo) do
		strMsg,num = string.gsub(strMsg,v.strChannel,"<pic src=\'"..msg_img_key[v.strChannel].img.."\'/>",1)
		if num>0 then
			len = len  + num*(imgChannelLength- (size/2)*8)
			break
		end
	end
	if string.find(strMsg,"<item") then
		strMsg,num = string.gsub(strMsg,"<item src=\"(.-),(.-)/>",function(s1,s2)
			len = len + size * #s1/3 --+ 30 --30是武器icon长度
			return "<item src=\""..s1..","..s2.."/>"
		end)
	end
	return strMsg,len
end

function ContainerIM.updateChannelHistory() -- 消息筛选器
	local mChannerHistory = {}
	for i,v in ipairs(GameSocket.mChatHistroy) do
		if ContainerIM.isMsgShow(v) then
			table.insert(mChannerHistory,v)
		end
	end
	return mChannerHistory
end

function ContainerIM.execItemString(msg)
	local startPos = 0
	local endPos = 1
	local result = msg
	local enum = 0
	result=string.gsub(result,"(##.-##)",function(v)
		v=string.gsub(v,"##","")
		local vv=string.split(v,",")
		if #vv>1 then
			if enum <3 then
				local itemdef = GameSocket:getItemDefByName(vv[1])
				if itemdef then
					local item = GameSocket:getNetItem(tonumber(vv[2]))
					if item and item.mTypeID == itemdef.mTypeID then
						enum = enum + 1
						return "<item src=\""..vv[1]..","..item.mLevel..","..item.mZLevel.."\"/>"
					else
						return vv[1]
					end
				end
			else
				return vv[1]
			end
		end
		return ""
	end)
	return result
end

function ContainerIM.sendMsg(isVoice)
	-- isVoice = "<voice>|"..GameUtilSenior.ToBase64("1234").."|10200|"..GameUtilSenior.ToBase64("5678").."|10000"
	local msg = var.mSendText:getText()
	msg = GameBaseLogic.clearHtmlText(msg)
	if #msg<2 then
		GameSocket:alertLocalMsg("内容太短，无法发送","alert")
		return
	end
	if isVoice then
		msg = isVoice
	end
	local mNum = 0
	local shoutMsg = msg
	local mainRole = CCGhostManager:getMainAvatar()

	if #msg <1 then return end

	msg = ContainerIM.execItemString(msg)

	-- local mModels = GameSocket.mModels[mainRole:NetAttr(GameConst.net_id)]
	-- local vip = GameSocket:getPlayerModel(mainRole:NetAttr(GameConst.net_id),5)
	-- if mModels and mModels[5] then vip =mModels[5] end
	-- vip = string.format("%02d",vip)
	-- msg = var.headId..vip.."||"..msg

	if var.Amark and var.mapInfo then
		msg,_ = string.gsub(msg,var.mapInfo,var.Amark)
	end
	local success = true
	if string.len(msg) > 0 then
		if var.chaIndex == CHANNEL_TAG.WORLD then -- 世界
			if string.sub(shoutMsg,1,1) == "@" then
				GameSocket:WorldChat(shoutMsg)
			else
				GameSocket:WorldChat(msg)
			end
		elseif var.chaIndex == CHANNEL_TAG.GUILD then
			if mainRole:NetAttr(GameConst.net_guild_title) > 101 and string.len(mainRole:NetAttr(GameConst.net_guild_name)) > 0 then
				GameSocket:GuildChat(msg)
			else
				success = false
				GameSocket:alertLocalMsg("你还没有帮会！","alert")
			end
		elseif var.chaIndex == CHANNEL_TAG.GROUP then 
			if #GameSocket.mGroupMembers > 0 then
				GameSocket:GroupChat(msg)
			else
				success = false
				GameSocket:alertLocalMsg("你还没有队伍,请先创建队伍！","alert")
			end
		elseif var.chaIndex == CHANNEL_TAG.PRIVATE then
			local target = GameSocket.m_strPrivateChatTarget
			if target == "" or target == nil then
				GameSocket:alertLocalMsg("你还没有聊天对象！","alert")
				success = false
			else
				msg,_=string.gsub(msg,"@[^>]*:","")
				GameSocket:PrivateChat(target,msg)
			end
		elseif var.chaIndex == CHANNEL_TAG.CURRENT then -- 当前 地图频道
			if string.sub(shoutMsg,1,1) ~= "@" then
				GameSocket:NormalChat(msg)
			else
				GameSocket:NormalChat(shoutMsg)
			end
		elseif var.chaIndex == CHANNEL_TAG.HORN then -- 喇叭
			GameSocket:HornChat(msg)
		elseif var.chaIndex == CHANNEL_TAG.ALL then
			if string.sub(shoutMsg,1,1) ~= "@" then
				GameSocket:WorldChat(msg)
			else
				GameSocket:WorldChat(shoutMsg)
			end
		end
		if success and not isVoice then
			var.Amark = nil
			var.mapInfo = nil
		end
	end
	var.mSendText:setString("")
end

function ContainerIM.ShowHandle(event)
	if event then
		if event.result[2] == "chat" then
			local pName = event.result[3]
			local channel = event.result[4]
			if channel then --切换频道
				-- for k,v in pairs(channelInfo) do
				-- 	if v.strChannel == pName then

				-- 		var.mSendText:setString(string.sub(pName,4,9)..":")
				-- 	end
				-- end
			elseif pName ~= GameBaseLogic.chrName and pName~="" then
				for k,v in pairs(GameSocket.mChatHistroy) do
					if v.m_strName == pName and v.m_job and v.m_uSrcId>0 then
						GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = {
							name = v.m_strName,
							job = v.m_job,
							gender = v.m_gender,
							level = v.m_lv,
							vip = v.m_vip,
							guild = v.m_guild,
						}})
						break;
					end
				end
			end
		end
	end
end

function ContainerIM.onVoiceMsgHandler(event)
	if event and event.params then
		local params = string.split(event.params,"|")
		if #params>=5 then
			params[3] = GameUtilSenior.ToBase64(params[3])
			params[4] = GameUtilSenior.ToBase64(params[4])
		end
		if not params[2]  then params[2] =" " end
		ContainerIM.sendMsg(table.concat( params,"|" ))
	end
end

return ContainerIM

