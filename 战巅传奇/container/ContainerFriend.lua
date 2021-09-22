local ContainerFriend = {}

local var = {}

local SELECTED_STATE = {
	ON = 1,
	OFF = 2,
}

local pageInfos = {
	[1] = {title = 99 	, name = "recentContacts" ,	hint="暂时没有找到与您等级相近的玩家"},
	[2] = {title = 100  , name = "FriendList" ,		hint="您还没有好友，点击推荐可以找到好友"},
	[3] = {title = 101	, name = "EnemyList" ,		hint="击杀您的玩家自动记录为您的仇人"},
	[4] = {title = 102	, name = "BlackList" ,		hint="这里显示您在聊天界面中屏蔽的玩家"},
	[5] = {title = 0	, name = "searchFriends" ,	hint="查找玩家"},
}

local operateBtns = {
	InvGroup = "InvGroup",
	Private = "Private",
	ChkInfo = "ChkInfo",
	Delete = "Delete",
	Onekey = "Onekey",
}

local chatBtns = {
	[1] = {name= "btn_switch",	},
	[2] = {name= "btn_face",	},
	[3] = {name= "btn_press",	touch = true },
	[4] = {name= "btn_send",	},
	[5] = {name= "btn_xuanyan",	},
	[6] = {name= "btn_deleteenemy",	},
	[7] = {name= "btn_enemytrack",	},
	[8] = {name= "btn_fresh_friend",},
	[9] = {name= "btn_find",	},
	[10]= {name="btn_position", },
	[11]= {name ="btn_equip_bag",	},
	[12]= {name ="btn_face_t",	},
}

local head_key ={"new_main_ui_head.png","head_fzs","head_mfs","head_ffs","head_mds","head_fds"}

function ContainerFriend.initView()
	var = {
		xmlPanel,
		listFriend,
		-- listEnemy,

		pageIndex = 1,
		editbox,
		editboxFind,
		handleItemTouchRecomnendLast ={},
		player = {},
		tabh,
		pageFriend,
		pageFind,
		pageEnemy,
		pageBlack,

		chatself,
		chatother,
		dieRecord = {},
		layerbg,
		chatTarget = nil,
		listChat,
		Container
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerFriend.uif")

	if var.xmlPanel then
		var.listFriend = var.xmlPanel:getWidgetByName("listFriend")
		-- var.listEnemy = var.xmlPanel:getWidgetByName("listEnemy"):setSliderVisible(false)

		var.tabh = var.xmlPanel:getWidgetByName("box_tab")
		var.tabh:addTabEventListener(ContainerFriend.pushTab);
		--var.tabh:setTabRes("btn_new21", "btn_new21_sel")

		cc.EventProxy.new(GameSocket, var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_FRIEND_FRESH, ContainerFriend.refreshPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerFriend.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_CHAT_MSG, ContainerFriend.handleNewChatMsg)
			:addEventListener(GameMessageCode.EVENT_CHAT_RECENT, ContainerFriend.handleChatRecentChange)

		--GameUtilSenior.asyncload(var.xmlPanel, "friend_find_bg", "ui/image/img_f_add_bg.jpg")

		if PLATFORM_BANSHU then
			var.tabh:hideTab({3,4})
		end
		var.pageFind = var.xmlPanel:getWidgetByName("pageFind");
		var.pageFriend = var.xmlPanel:getWidgetByName("pageFriend");
		var.pageEnemy = var.xmlPanel:getWidgetByName("pageEnemy");

		var.chatself = var.xmlPanel:getWidgetByName("chatself");
		--var.chatself:getChildByName("contentbg"):setRotation(-180)
		var.chatother = var.xmlPanel:getWidgetByName("chatother");
		var.pageFind:setPosition(cc.p(6,6)):setVisible(false):setSwallowTouches(true):setTouchEnabled(true)
		var.pageEnemy:setVisible(false);
		-- var.xmlPanel:getWidgetByName("btn_xuanyan"):hide()
		var.listChat = var.xmlPanel:getWidgetByName("listChat");
		var.Container = var.xmlPanel:getWidgetByName("Container");

		var.layerbg = var.xmlPanel:getWidgetByName("layerbg")
		var.xmlPanel:getWidgetByName("btn_add_friend"):setTag(5):addClickEventListener(ContainerFriend.pushTab)
		if not var.editbox then
			local img_input_bg = var.xmlPanel:getWidgetByName("img_input_bg")
			var.editbox = GameUtilSenior.newEditBox({
				name = "chatinput",
				image = "image/icon/null.png",
				size = img_input_bg:getContentSize(),
				listener = ContainerFriend.onEdit,
				color = cc.c4b(200, 200, 200,255),
				x = 0,
				y = 0,
				fontSize = 22,
				-- inputMode = cc.EDITBOX_INPUT_MODE_ANY,
				placeHolderColor = GameBaseLogic.getColor(0x827b6e),
				placeHolderSize = 22,
				anchor = cc.p(0,0),
				placeHolder = GameConst.str_input,
			})
			var.editbox:align(display.BOTTOM_LEFT,0,0)
				:setPlaceHolder(GameConst.str_input)
				:addTo(img_input_bg)
				:setString("")
				:setAnchorPoint(cc.p(0,0))
				:setVisible(true)
		end

		ContainerFriend.updateGameMoney()
		
		return var.xmlPanel
	end
end

function ContainerFriend.onPanelOpen(extend)	
	for k,v in pairs(chatBtns) do
		local sender = var.xmlPanel:getWidgetByName(v.name)
		if sender then
			if v.touch then
				sender:addTouchEventListener(ContainerFriend.pushOperateBtns)
			else
				sender:addClickEventListener(ContainerFriend.pushOperateBtns)
			end
		end
		if PLATFORM_BANSHU and v.name == "btn_switch" then
			sender:hide()
		end
	end
	var.tabh:setSelectedTab(1);--最近联系人
	ContainerFriend.initFaceList()
	var.xmlPanel:setPositionY(display.cy)
	var.Container:setPosition(cc.p(465,(300-display.cy)))
	if extend and extend.tab and GameUtilSenior.isNumber(extend.tab) then
		var.tabh:setSelectedTab(extend.tab)
	end
end

--金币刷新函数
function ContainerFriend:updateGameMoney()
	local panel = var.xmlPanel
	if panel then
		local mainrole = GameSocket.mCharacter
		local moneyLabel = {
			{name="big_title_yb_text",btn="big_title_yb_btn",	pre=GameConst.str_vcoin,	value =	mainrole.mVCoin or 0	,	icon = "icon_coin"},
			{name="big_title_hmb_text",btn="big_title_hmb_btn",	pre=GameConst.str_vcoinb,	value =	mainrole.mVCoinBind or 0,	icon = "icon_coin_bind"},
			{name="big_title_jb_text",btn="big_title_jb_btn",	pre=GameConst.str_money,	value =	mainrole.mGameMoney or 0,	icon = "icon_money"},
			{name="lblBMoney",	pre=GameConst.str_moneyb,	value =	mainrole.mGameMoneyBind or 0,	icon = "icon_money"},
		}
		--建临时表遍历设属性
		for _,v in ipairs(moneyLabel) do
			if panel:getWidgetByName(v.name) then
				panel:getWidgetByName(v.name):setString(v.value)
				panel:getWidgetByName(v.btn):addClickEventListener( function (sender)
					GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="panel_charge"})
				end)
			end
		end
	end
end


function ContainerFriend.pushTab(sender)
	var.pageIndex = sender:getTag();
	if var.pageIndex == 1 then
		var.xmlPanel:getWidgetByName("Image_52"):hide()
		var.xmlPanel:getWidgetByName("Image_48"):show()
		var.xmlPanel:getWidgetByName("Image_7_0"):show()
		var.xmlPanel:getWidgetByName("Image_51"):show()
		--var.layerbg:loadTexture("ui/image/img_friend_bg.jpg", ccui.TextureResType.localType)
		ContainerFriend.refreshPanel(var.pageIndex)
	elseif var.pageIndex == 2 then
		var.xmlPanel:getWidgetByName("Image_52"):hide()
		var.xmlPanel:getWidgetByName("Image_48"):show()
		var.xmlPanel:getWidgetByName("Image_7_0"):show()
		var.xmlPanel:getWidgetByName("Image_51"):show()
		--var.layerbg:loadTexture("ui/image/img_friend_bg.jpg", ccui.TextureResType.localType)
		ContainerFriend.refreshPanel(var.pageIndex)
	elseif var.pageIndex == 3 then
		var.xmlPanel:getWidgetByName("Image_52"):show()
		var.xmlPanel:getWidgetByName("Image_48"):show()
		var.xmlPanel:getWidgetByName("Image_7_0"):show()
		var.xmlPanel:getWidgetByName("Image_51"):show()
		--var.layerbg:loadTexture("ui/image/img_enemy_bg.jpg", ccui.TextureResType.localType)
		ContainerFriend.refreshPanel(var.pageIndex)
		ContainerFriend.onUpdatePageEnemy()
	elseif var.pageIndex == 4 then
		var.xmlPanel:getWidgetByName("Image_52"):hide()
		var.xmlPanel:getWidgetByName("Image_48"):show()
		var.xmlPanel:getWidgetByName("Image_7_0"):show()
		var.xmlPanel:getWidgetByName("Image_51"):show()
		--var.layerbg:loadTexture("ui/image/img_friend_bg.jpg", ccui.TextureResType.localType)
		ContainerFriend.refreshPanel(var.pageIndex)
	elseif var.pageIndex == 5 then
		var.xmlPanel:getWidgetByName("Image_52"):hide()
		var.xmlPanel:getWidgetByName("Image_48"):hide()
		var.xmlPanel:getWidgetByName("Image_7_0"):hide()
		var.xmlPanel:getWidgetByName("Image_51"):hide()
		
		
		--var.layerbg:loadTexture("null", ccui.TextureResType.plistType)
		ContainerFriend.onUpdatePageFind()
	end
	--var.layerbg:ignoreContentAdaptWithSize(false)
	var.pageFriend:setVisible(table.indexof({1,2,4},var.pageIndex)~=false);
	var.listFriend:setVisible(var.pageIndex ~= 5)
	var.pageEnemy:setVisible(var.pageIndex == 3)
	var.pageFind:setVisible(var.pageIndex == 5)

	var.listChat:setVisible(var.pageIndex ~= 4)
	var.xmlPanel:getWidgetByName("img_Background"):setVisible(var.pageIndex ~= 4)

	var.chatTarget = nil
end

function ContainerFriend.onUpdatePageEnemy(enemyName)
	local dieRecords = GameSetting.getInfos(enemyName,"DieRecords") or {}
	local deathList = var.pageEnemy:getWidgetByName("deathList");
	deathList:setVisible(#dieRecords>0)

	local t = dieRecords[#dieRecords]
	if not t then
		t = GameSocket:getPlayerInfo(enemyName) or {}
	end
	var.pageEnemy:getWidgetByName("lblenemylv"):getWidgetByName("content"):setString(t.level or "")
	local job = t.job
	if checknumber(t.job)>0 then
		job = GameUtilSenior.getJobName(t.job)
	end
	var.pageEnemy:getWidgetByName("lblenemyjob"):getWidgetByName("content"):setString(job or "")
	local pGhost = NetCC:findGhostByName(enemyName)
	if pGhost then
		t.power = pGhost:NetAttr(GameConst.net_fight_point)
	end
	var.pageEnemy:getWidgetByName("lblenemypower"):getWidgetByName("content"):setString(t.power or "")
	var.pageEnemy:getWidgetByName("lblenemyguild"):getWidgetByName("content"):setString(t.guild or "")

	deathList:reloadData(#dieRecords, function( subItem )
		local d = dieRecords[subItem.tag]
		local str = subItem:getWidgetByName("modelRecord1")
		if not str then
			--str = GUIRichLabel.new({size=cc.size(subItem:getContentSize().width-10,30),name = "modelRecord1"})
			str = GUIRichLabel.new({ignoreSize = true,name = "modelRecord1"})
			str:addTo(subItem):setPosition(cc.p(10,10))
		end
		--local time = os.date("%Y-%m-%d %H时%M分",d.time);
		local time = os.date("%H时%M分",d.time);
		str:setRichLabel("<font color=#18d129>"..time.."</font> <font color=#edb846>在"..d.map.."被"..d.name.."击杀！</font>", "parent", 18)
	end)
end

function ContainerFriend.onUpdatePageFind()
	local inputFind = var.pageFind:getWidgetByName("inputFind")
	var.editboxFind = inputFind:getWidgetByName("editboxFind")

	-- var.pageFind:setBackGroundImage("ui/image/img_f_add_bg.jpg")
	if not var.editboxFind then
		var.editboxFind = GameUtilSenior.newEditBox({
			name = "editboxFind",
			image = "image/icon/null.png",
			size = inputFind:getContentSize(),
			listener = ContainerFriend.onEdit,
			color = cc.c4b(200, 200, 200,255),
			x = 0,
			y = 0,
			fontSize = 22,
			-- inputMode = cc.EDITBOX_INPUT_MODE_ANY,
			placeHolderColor = GameBaseLogic.getColor(0x827b6e),
			placeHolderSize = 22,
			anchor = cc.p(0,0),
			placeHolder = GameConst.str_input,
		})
		var.editboxFind:align(display.BOTTOM_LEFT,0,0)
			:setPlaceHolder(GameConst.str_input)
			:addTo(inputFind)
			:setAnchorPoint(cc.p(0,0))
	end
	var.editboxFind:setString("")
	ContainerFriend.freshFindList({});
end

function ContainerFriend.changeInputModel()
	local btn_press = var.xmlPanel:getWidgetByName("btn_press")
	local inputlayer = var.xmlPanel:getWidgetByName("inputlayer")
	local vis = btn_press:isVisible()
	btn_press:setVisible( not vis)
	inputlayer:setVisible( vis)
end

function ContainerFriend.onEdit(event,editBox)
	-- if event == "ended" then
	-- end
end

function ContainerFriend.initFaceList()
	local function pushEmojPng(sender)
		local tag = sender:getTag()
		var.editbox:setString(var.editbox:getText()..GameConst.expressions_item[tag][1])
		-- ContainerFriend.changeInputModel()
	end
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

function ContainerFriend.setEmojVisible()
	local containerHeight = var.xmlPanel:getWidgetByName("Container"):getContentSize().height
	local heightAddition = display.cy - var.xmlPanel:getContentSize().height/2
	local height = containerHeight - heightAddition

	var.xmlPanel:runAction(cca.seq({
		cca.cb(function(target)
			print(var.xmlPanel.isShow,heightAddition,containerHeight)
			var.Container:setPositionY(var.xmlPanel.isShow and -heightAddition or 0)
		end),
		cca.moveTo(0.2, var.xmlPanel:getPositionX(), var.xmlPanel:getPositionY()+(var.xmlPanel.isShow and -height or height)),
		cca.cb(function ()
			var.xmlPanel.isShow = not var.xmlPanel.isShow
		end)
	}))
end

function ContainerFriend.execItemString(msg)
	local startPos = 0
	local endPos = 1
	local result = msg
	local num = 0
	result=string.gsub(result,"(##.-##)",function(v)
		v=string.gsub(v,"##","")
		local vv=string.split(v,",")
		if #vv>1 then
			if num<3 then
				local itemdef = GameSocket:getItemDefByName(vv[1])
				if itemdef then
					local item = GameSocket:getNetItem(tonumber(vv[2]))
					if item then
						num = num + 1
						return "<item src=\""..vv[1]..","..item.mLevel..","..item.mZLevel.."\"/>"
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

function ContainerFriend.pushOperateBtns(sender,touchType)
	local btnFuncs = {
		["btn_switch"] = function ()
			ContainerFriend.changeInputModel()
			if var.xmlPanel.isShow then
				ContainerFriend.setEmojVisible()
			end

			if not sender.bright then sender.bright =1 end
			local res = sender.bright ==1 and "img_keyboard" or "img_keyboard_sel"
			sender:loadTextures(res,res,res,ccui.TextureResType.plistType)
			sender.bright = 1 - sender.bright
		end,
		["btn_face"] = function ()
			ContainerFriend.setEmojVisible()
		end,
		["btn_press"] = function ()
			if not GameSocket.m_strPrivateChatTarget or GameSocket.m_strPrivateChatTarget=="" then
				if touchType == ccui.TouchEventType.began then
					GameSocket:alertLocalMsg("请先选择私聊对象！", "alert")
				end
				return
			end
			if sender and touchType == ccui.TouchEventType.began then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_VOICE_HANDLE,vis = true,chanel = "VoiceChannelPrivate"})
			elseif sender and touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_VOICE_HANDLE,vis = false, send = GameUtilSenior.hitTest(sender, sender:getTouchEndPosition())})
			else
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_VOICE_HANDLE, charVis = not GameUtilSenior.hitTest(sender, sender:getTouchMovePosition())})
			end
		end,
		["btn_send"] = function (isVoice)
			local msg = var.editbox:getText();
			-- isVoice = "<voice>|"..GameUtilSenior.ToBase64("1234").."|1000|"..GameUtilSenior.ToBase64("5678").."|5"
			msg = GameBaseLogic.clearHtmlText(msg)
			if #msg<2 then
				GameSocket:alertLocalMsg("内容太短，无法发送","alert")
				return
			end
			if isVoice then
				msg = isVoice
			end
			if #msg <1 then return end

			--装备换算
			msg = ContainerFriend.execItemString(msg)

			--换算地图坐标
			if var.Amark and var.mapInfo then
				msg,_ = string.gsub(msg,var.mapInfo,var.Amark)
			end
			if var.chatTarget == "" or var.chatTarget == nil then
				GameSocket:alertLocalMsg("你还没有聊天对象！","alert")
			else
				msg,_=string.gsub(msg,"@[^>]*:","")
				GameSocket:PrivateChat(var.chatTarget,msg)
			end
			if var.xmlPanel.isShow then
				ContainerFriend.setEmojVisible()
			end
			var.editbox:setString("")
			var.mapInfo	= nil
			var.Amark 	= nil
		end,
		["btn_find"] = function()
			if var.editboxFind then
				local pName = var.editboxFind:getText();
				if #pName<=0 then
					return GameSocket:alertLocalMsg("请输入玩家姓名！")
				end
				local data = {actionid = "searchFriends", param = {var.editboxFind:getText()},}
				GameSocket:PushLuaTable("gui.ContainerFriend.onPanelData", GameUtilSenior.encode(data))
			end
		end,
		["btn_xuanyan"] = function()
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str = "revenge"})--复仇宣言
		end,
		["btn_deleteenemy"] = function()
			if var.chatTarget ~= "" or var.chatTarget ~= nil then
				GameSocket:FriendChange(var.chatTarget,0)
			end
		end,
		["btn_enemytrack"] = function()
			if var.chatTarget then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str = "enemytrack",enemyName = var.chatTarget})--仇人追踪
			end
		end,
		["btn_fresh_friend"] = function()
			local data = {actionid = "recommendPlayer"}
			GameSocket:PushLuaTable("gui.ContainerFriend.onPanelData", GameUtilSenior.encode(data))
		end,
		["btn_position"] = function()
			ContainerFriend.setEmojVisible()
			local pos = GameCharacter._mainAvatar:PAttr(GameConst.AVATAR_X)..",".. GameCharacter._mainAvatar:PAttr(GameConst.AVATAR_Y)
			local minimap = GameSocket.mNetMap
			var.mapInfo	= minimap.mName.." "..pos
			var.Amark = "<a underline=00ff00 color=#00ff00 href=\'event:local_goto_"..minimap.mMapID.."_"..GameCharacter._mainAvatar:PAttr(GameConst.AVATAR_X).."_"..GameCharacter._mainAvatar:PAttr(GameConst.AVATAR_Y).."\'>"..var.mapInfo.."</a>"
			var.editbox:setString(var.editbox:getText().." "..var.mapInfo.." ")
		end,
		["btn_face_t"] = function()
			var.xmlPanel:getWidgetByName("equipList"):setVisible(false)
			var.xmlPanel:getWidgetByName("emoj_bg"):setVisible(true)
		end,	
		["btn_equip_bag"] = function()
			var.xmlPanel:getWidgetByName("equipList"):setVisible(true)
			var.xmlPanel:getWidgetByName("emoj_bg"):setVisible(false)
			ContainerFriend.onItemChange()
		end,	

	}
	if btnFuncs[sender:getName()] then
		btnFuncs[sender:getName()]()
	end
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
function ContainerFriend.clickItem(sender)
	local netItem = sender.netItem
	local itemdef = GameSocket:getItemDefByID(netItem.mTypeID)
	if netItem and itemdef then
		local str = var.editbox:getText()
		str = str.."##"..itemdef.mName..","..netItem.position.."##,"
		var.editbox:setText(str)
	end
end

function ContainerFriend.onItemChange(event)
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
		-- local itemdef = GameSocket:getItemDefByID(item.mTypeID)
		-- if itemdef then
		-- 	subItem:getWidgetByName("icon")
		-- 		:setTouchSwallowEnabled(false)
		-- 		:loadTextureNormal("image/icon/"..itemdef.mIconID..".png")
		-- 		:addClickEventListener(ContainerFriend.clickItem)
		-- 	subItem:getWidgetByName("icon").netItem = item
		-- end
		subItem:getWidgetByName("cellbg"):addClickEventListener(ContainerFriend.clickItem)
		subItem:getWidgetByName("cellbg").netItem = item
		GUIItem.getItem({
			parent = subItem,--:getWidgetByName("cellbg"),
			typeId = item.mTypeID,
			mLevel = item.mLevel,
			mZLevel = item.mZLevel,
			iconType = 10,
			customCallFunc = function(...) print("---",...) end,
			callBack = function ( ... )
				print("···")
			end
		})
		subItem:setTouchEnabled(false):setTouchSwallowEnabled(false)
		subItem:getWidgetByName("item_icon"):setTouchEnabled(false):setTouchSwallowEnabled(false)
	end)
end

function ContainerFriend.handleNewChatMsg(event)
	local netChat = event.msg;
	if netChat.m_strType == "【私聊】" then
		if netChat.m_strName == GameSocket.m_strPrivateChatTarget then
			ContainerFriend.inputNewMsg(netChat);
		end
	end
end

function ContainerFriend.callength( strMsg,size ) --根据字体大小计算长度
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

	if string.find(strMsg,"<item") then
		strMsg,num = string.gsub(strMsg,"<item src=\"(.-),(.-)/>",function(s1,s2)
			len = len + size * #s1/3 --+ 30 --30是武器icon长度
			return "<item src=\""..s1..","..s2.."/>"
		end)
	end
	return strMsg,len
end

function ContainerFriend.inputNewMsg(netChat)
	local listChat = var.xmlPanel:getWidgetByName("listChat");
	local isVoice,boxType = false,""
	if netChat.localPath or netChat.httpPath then
		isVoice = true
		if netChat.m_strName == GameBaseLogic.chrName or netChat.m_MyName == GameBaseLogic.chrName then
			boxType = isVoice and "self_voice" or"self"
		else
			boxType = isVoice and "other_voice" or "other"
		end
	end
	local chatModel,contentbg,other,richtext
	if(netChat.m_MyName and netChat.m_MyName == GameBaseLogic.chrName) then
		chatModel = var.chatself:clone();
		other = false
	else
		chatModel = var.chatother:clone();
		other = true
	end
	contentbg = chatModel:getWidgetByName("contentbg");
	local lbl_name = chatModel:getWidgetByName("lbl_name");
	lbl_name:setString(netChat.m_MyName or netChat.m_strName)
	
	richtext = chatModel:getWidgetByName("richtext");
	local strMsg,len = ContainerFriend.callength(netChat.m_strMsg,24)
	len = GameUtilSenior.bound(10, len, 270)
	if not richtext then
		richtext = GUIRichLabel.new({size= cc.size(len,0),name="richtext",})
		richtext:addTo(contentbg):setPosition(cc.p(22,15))
	end
	for j=1,#GameConst.expressions_item do
		strMsg,num = string.gsub(strMsg,GameConst.expressions_item[j][1],"<pic src=\'img_"..GameConst.expressions_item[j][2].."\'/>")
	end
	local img_voice_chat = contentbg:getWidgetByName("img_voice_chat")
	local chatTime = chatModel:getWidgetByName("chatTime")
	if not isVoice then
		if img_voice_chat then img_voice_chat:hide() end
		chatTime:hide()
		strMsg = "<font outline=\'0,0,0,0,1\' color=#ffffff>"..strMsg.."</font>"
		richtext:setRichLabel(strMsg,"panel_chat", 20)--e8ba52
	else
		chatTime:show():setString(math.ceil(netChat.duration/1000).."''")
		if not img_voice_chat then
			img_voice_chat = ccui.ImageView:create("img_chat_voice3",ccui.TextureResType.plistType)
				:addTo(contentbg):setName("img_voice_chat")
		end
		if boxType == "self_voice" then
			img_voice_chat:setRotation(0):setPosition(contentbg:getContentSize().width,26)
			chatTime:setPosition(cc.p(-1,26))
			contentbg.selfvoice = true
		elseif boxType == "other_voice" then
			contentbg.selfvoice = false
			chatTime:setPosition(cc.p(150,26))
			img_voice_chat:setRotation(180):setPosition(30,26)
		end
		contentbg:setTouchEnabled(true)
		contentbg.filepath = netChat.localPath
		contentbg.url = netChat.httpPath
		contentbg.flag = netChat.flag
		contentbg.duration = netChat.duration

		contentbg:addClickEventListener(GDivRecord.playVoice)
	end
	local msgSize = richtext:getContentSize();
	if isVoice then msgSize = cc.size(120,26) end
	contentbg:setPositionY(msgSize.height+30)
	contentbg:setContentSize(cc.size(msgSize.width + 27,msgSize.height+30));
	contentbg:setScale9Enabled(true)
		:setCapInsets(cc.rect(8,34,80,4))

	chatModel:setContentSize(cc.size(chatModel:getContentSize().width,msgSize.height+32+40));

	local headbg = chatModel:getWidgetByName("headbg")
	local head = chatModel:getWidgetByName("head")
	local job,gender,id,player
	if other then
		player = GameSocket:getPlayerInfo(netChat.m_strName)
		if player then
			job = player.job
			gender = player.gender
		end
		richtext:setPosition(cc.p(20,15))
	else
		job = GameCharacter._mainAvatar:NetAttr(GameConst.net_job)
		gender = GameCharacter._mainAvatar:NetAttr(GameConst.net_gender)
		richtext:setPosition(cc.p(10,15))
	end
	if job and gender then
		id = (job-100) * 2 + gender - 199
		head:loadTexture(head_key[id], ccui.TextureResType.plistType):setScale(0.8)
	end
	headbg:setScale(0.8)
	headbg:setPositionY(msgSize.height+20)

	listChat:pushBackCustomItem(chatModel)
	listChat:jumpToBottom()
	if #listChat:getItems()>=50 then
		listChat:removeItem(0)
	end
end

function ContainerFriend.refreshChat()
	local listChat = var.xmlPanel:getWidgetByName("listChat");
	listChat:removeAllItems()
	local target = GameSocket.m_strPrivateChatTarget
	if target == "" or target == nil then return end
	local player = GameSocket:getPlayerInfo(target)
	if not player then
		return 
	end
	local msgs = {}
	for k,v in pairs(GameSocket.mChatHistroy) do --读取私聊信息列表
		if v.m_strName and v.m_strName == target and v.m_strType == GameConst.str_chat_private then
			table.insert(msgs,v)
		end
	end
	listChat:setItemsMargin(5);
	for k,v in ipairs(msgs) do
		ContainerFriend.inputNewMsg(v);
	end
end

function ContainerFriend.handlePanelData(event)
	if event.type ~= "ContainerFriend" then return end
	local serverTable = GameUtilSenior.decode(event.data)
	if serverTable.cmd == "recommendPlayer" then
		ContainerFriend.freshFindList(serverTable.data,"recommend")
	elseif serverTable.cmd == "searchFriends" then
		local t = {};
		if serverTable.isFind then
			table.insert(t,serverTable.data);
			ContainerFriend.freshFindList(t,"find");
		else
			GameSocket:alertLocalMsg("暂无该玩家！","alert")
		end
	elseif serverTable.cmd =="getRevenge" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_REVENGE_CHANGE,str = serverTable.str})
	end
end

function ContainerFriend.freshFindList(data,typed)
	local listfind = var.xmlPanel:getWidgetByName("listfind")
	if typed == "find" then
		--var.xmlPanel:getWidgetByName("img_addfriend_bg"):setContentSize(cc.size(900.00,398))
		var.xmlPanel:getWidgetByName("Image_62"):hide()
		var.xmlPanel:getWidgetByName("Image_61"):hide()
		var.xmlPanel:getWidgetByName("btn_fresh_friend"):hide()
	else
		var.xmlPanel:getWidgetByName("btn_fresh_friend"):show()
		var.xmlPanel:getWidgetByName("Image_62"):show()
		var.xmlPanel:getWidgetByName("Image_61"):show()
		
		--var.xmlPanel:getWidgetByName("img_addfriend_bg"):setContentSize(cc.size(900.00,398))
	end
	listfind:reloadData(#data,function( item )
		local d = data[item.tag];
		item:getWidgetByName("lblName"):setString(d.name);
		item:getWidgetByName("lblLevel"):setString(d.level.."级");
		item:getWidgetByName("lblJob"):setString(GameConst.job_name[d.job]);

		local id = (d.job-100) * 2 + d.gender - 199

		item:getWidgetByName("img_head"):loadTexture(head_key[id], ccui.TextureResType.plistType):setScale(0.7):addClickEventListener(function(sender)
			if d.name ~= GameBaseLogic.chrName then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = d, btnType= nil})
			end
		end)
		local btn_add = item:getWidgetByName("btn_add")
		btn_add:setVisible(d.name ~= GameBaseLogic.chrName)
		btn_add:addClickEventListener(function (sender)
			local title = GameSocket:getRelation(d.name)
			if title == 100 then
				GameSocket:alertLocalMsg(d.name.."已经是您好友了", "alert")
			else
				GameSocket:FriendChange(d.name,100)
			end
		end)
	end,0,false)
end

function ContainerFriend.setFriendListInfos(friendName,friendInfo,index)
	-- local FriendListInfos = GameSetting.getInfos(friendName, "FriendList")
	GameSetting.setInfos(friendName, friendInfo,pageInfos[index].name)
	GameSetting.save(pageInfos[index].name)
end

function ContainerFriend.getFriendListInfos(friendName,index)
	return GameSetting.getInfos(friendName, pageInfos[index].name)
end

function ContainerFriend.refreshPanel(event)

	ContainerFriend.refreshList(var.pageIndex)
	local listChat = var.xmlPanel:getWidgetByName("listChat");
	listChat:removeAllItems()
end

function ContainerFriend.refreshList(tabIndex)
	var.chatTarget = nil
	local pageListInfos = {}
	if pageInfos[tabIndex] then

		if tabIndex ==1 then
			pageListInfos = GameSocket.chatRecent
		else
			for _,v in pairs(GameSocket.mFriends) do
				if v.title == pageInfos[tabIndex].title then
					local tempTable
					if v.online_state == 1 then
						tempTable = v
						ContainerFriend.setFriendListInfos(v.name,v,tabIndex)
					else
						tempTable = ContainerFriend.getFriendListInfos(v.name,tabIndex) or v
						tempTable.online_state = 0
					end
					table.insert(pageListInfos, tempTable)
				end
			end
		end
	end

	local function sortF(fa, fb)
		if checkint(fa.state) == checkint(fb.state) then
			return checkint(fa.level)> checkint(fb.level)
		else
			return checkint(fa.online_state)> checkint(fb.online_state)
		end
	end
	table.sort( pageListInfos, sortF)

	local function updateList(item)
		local d = pageListInfos[item.tag]
		local lblTables = {
			["job"]			= {widgetName = "lblJob",	string = GameConst.job_name[d.job], vis = tabIndex~=4},
			["name"]		= {widgetName = "lblName",	},
			["level"]		= {widgetName = "lblLevel", plusString = "级",	pos = cc.p(tabIndex==4 and 126.00 or 170,38)},
			["online"]		= {widgetName = "lblOnlineState", pos = cc.p(222.00,tabIndex ==4 and 92 or 68),string = GameConst.online[d.online_state], color = GameConst.onlineColor[d.online_state]},
			["shield"]		= {widgetName = "btn_shield", vis = tabIndex==4},
		}
		item.online_state = d.online_state
		for k,v in pairs(lblTables) do
			if k == "name" then
				item.name = d.name
			end

			local widget = item:getWidgetByName(v.widgetName)
			local strValue
			if v.string then
				strValue = v.string
			else
				strValue = (d[k] or "")..(v.plusString~=nil and v.plusString or "")
			end
			if strValue == nil or strValue == "" or strValue == 0 or strValue == "0" then
				strValue = GameConst.str_unknown
			end
			if widget:getDescription() == "Label" then
				widget:setString(strValue)
			end
			if v.color then
				widget:setColor(GameBaseLogic.getColor(v.color))
			end
			if v.pos then
				widget:setPosition(v.pos)
			end
			if v.vis~=nil then
				widget:setVisible(v.vis)
			end
		end
		local id = (d.job-100) * 2 + d.gender - 199
		item:getWidgetByName("img_head"):loadTexture(head_key[id], ccui.TextureResType.plistType):setScale(0.8)
		if d.online_state == 0 and head_key[id] then
			item:getWidgetByName("img_head"):getVirtualRenderer():setState(1)
		else
			item:getWidgetByName("img_head"):getVirtualRenderer():setState(0)
		end
		local btn_shield = item:getWidgetByName("btn_shield")
		btn_shield:setTouchEnabled(true)
		btn_shield:addClickEventListener(function(sender)
			GameSocket:FriendChange(d.name,0)
		end)
		local head_mask = item:getWidgetByName("head_mask");
		head_mask:setTouchEnabled(true):setTouchSwallowEnabled(false)
		head_mask:addClickEventListener(function(sender)
			var.listFriend.selectItem = sender:getParent():getParent()
			ContainerFriend.handleItemTouch(var.listFriend.selectItem)
			-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = d, btnType= (var.pageIndex==2 and "call" or nil)})
		end)
		item.d = d
		item:setTouchEnabled(true)
		item:addClickEventListener(ContainerFriend.handleItemTouch)
		if d.name == GameSocket.m_strPrivateChatTarget then
			ContainerFriend.handleItemTouch(item)
		end
	end

	var.listFriend:setVisible(#pageListInfos>0):setSliderVisible(false)
	var.listFriend:reloadData(#pageListInfos,updateList,nil,false)
end

function ContainerFriend.handleItemTouch(sender)
	if var.listFriend.selectItem then
		var.listFriend.selectItem:getWidgetByName("randerbg"):loadTexture("img_f_list", ccui.TextureResType.plistType)
	end
	GameSocket.m_strPrivateChatTarget = sender.d.name;
	sender:getWidgetByName("randerbg"):loadTexture("img_f_list_sel", ccui.TextureResType.plistType)
	if table.indexof({1,2,4},var.pageIndex)~=false then
		ContainerFriend.refreshChat();
	elseif var.pageIndex == 3 then
		ContainerFriend.onUpdatePageEnemy(sender.name)
	end
	var.chatTarget = sender.name
	if var.selectLast then
		var.selectLast:getWidgetByName("randerbg"):loadTexture("render_bg",ccui.TextureResType.plistType)
	end
	var.selectLast = sender
	if var.selectLast:getWidgetByName("randerbg") then
		var.selectLast:getWidgetByName("randerbg"):loadTexture("rank_selBorder1_scale3",ccui.TextureResType.plistType)
	end
	if var.listFriend.selectItem == sender then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = sender.d, btnType= (var.pageIndex==2 and "call" or nil)})
	end
	
	var.listFriend.selectItem = sender
	-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = sender.d})
end

function ContainerFriend.handleChatRecentChange(event)
	if var.pageIndex ~=1 then return end
	ContainerFriend.refreshList(1)
end

function ContainerFriend.onPanelClose()
	if var.xmlPanel and not tolua.isnull(var.xmlPanel) then
		GameSetting.save("FriendList")
		GameSetting.save("recentContacts")
		if GameUtilSenior.isObjectExist(var.tabh) then
			var.tabh:setSelectedTab(1);
		end
	end
	GameSocket.tipsMsg["tip_private"] = {}
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_VOICE_HANDLE,vis = false, send = false})
end

function ContainerFriend.checkPanelClose()
	if var.pageIndex == 5 then
		var.tabh:setSelectedTab(2);
		return false
	end
	return true
end

return ContainerFriend