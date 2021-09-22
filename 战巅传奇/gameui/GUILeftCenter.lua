local GUILeftCenter={}

local var = {}

local lblhint = {
	"1.每天累计参与3小时\n2.每天0点重置\n3.未知暗殿击杀BOSS将获\t\t得大量奖励",
}

local jobNames = {GameConst.str_zs, GameConst.str_fs, GameConst.str_ds}
local headName = {{"new_main_ui_head.png","head_mfs","head_mds"},{"head_fzs","head_ffs","head_fds"}}

local function addArrowCallback(layer,btn,func)
	if btn.eventListeners_ then return end
	btn:setTouchEnabled(true)
	btn.eventListeners_ = true
	btn:addClickEventListener(function ( sender )
		layer:stopAllActions()
		if layer:getPositionX()>=0 then
			layer:runAction(cca.seq({
				cca.cb(function(target) target._action = true end),
				cca.moveTo(0.1, -layer:getContentSize().width, layer:getPositionY()),
				cca.cb(function( target )
					-- sender:setRotation(180)
					target._action = false
					if GameUtilSenior.isFunction(func) then
						func(false)
					end
				end)
			}))
		else
			layer:runAction(cca.seq({
				cca.cb(function( target )
					-- sender:setRotation(0)
					target._action = true
					if GameUtilSenior.isFunction(func) then
						func(true)
					end
				end),
				cca.moveTo(0.1, 0, layer:getPositionY()),
				cca.cb(function( target )
					target._action = false
				end),

			}))

		end
	end)
end

local function handleSwitchUIMode(event)
	if not var.leftCenter then return end
	local posX, posY = var.leftCenter:getPosition()
	if event.mode == GameConst.UI_COMPLETE and posX < 0 then
		var.leftCenter:stopAllActions()
		var.leftCenter:runAction(cca.moveTo(0.5, 0, posY))
	elseif event.mode == GameConst.UI_SIMPLIFIED and posX > -400 then
		var.leftCenter:stopAllActions()
		var.leftCenter:runAction(cca.moveTo(0.5, -400, posY))
	end
end

function GUILeftCenter.update()
	if GameUtilSenior.isObjectExist(var.xmlDefend) and var.curBg == var.xmlDefend then
		local boxStatueHp = var.xmlDefend:getWidgetByName("box_statue_hp")
		if not var.m_nStatueId then return end
		local mGhostStatue = NetCC:getGhostByID(var.m_nStatueId)
		if not mGhostStatue then 
			boxStatueHp:hide()
			return 
		end
		boxStatueHp:show()
		local hp = mGhostStatue:NetAttr(GameConst.net_hp)
		local maxHp = mGhostStatue:NetAttr(GameConst.net_maxhp)

		local statueHpBar= var.xmlDefend:getWidgetByName("img_statue_hp_bar")
		statueHpBar:setPercent(hp, maxHp)
	end
end

function GUILeftCenter.init_ui(leftCenter)
    var ={    	
		fubenBg,
		personBossBg,
		curBossName,
		anDianBossBg,
		zhenMoBg,
		btnFlag = false,

		bgVisible=true,
		blackBoard,--用于显示实时战场数据的黑板

		isTarget,--是否显示的是目标面板

		box_maintask,
		btn_operate,
		customPass,
		curMyGroup=nil,
		curGroupIndex=nil,
		curName=nil,
		xmlAnDian=nil,
		xmlDart=nil,
		xmlShaozhu = nil,
		conEquip=false,--主线获得装备模块

		boxEquipGet=nil,

		xmlDefend=nil,
		m_nStatueId = nil,
		
		bossgenMons ={}

	}
	var.leftCenter = leftCenter
	var.leftCenter:align(display.LEFT_TOP, display.left, display.height - 136)
	var.taskPro = leftCenter:getWidgetByName("task_progress"):hide()
	
	local imgTaskBg = var.leftCenter:getWidgetByName("img_task_bg"):setTouchEnabled(true):setSwallowTouches(true):setOpacity(0.4 * 255)
	
	var.box_maintask = var.leftCenter:getWidgetByName("box_maintask")

	var.xmlDart = var.box_maintask:getWidgetByName("box_dart")
	local point=cc.p(display.width/2, display.height / 4 + 20)
	local box_dart_hp = var.xmlDart:getWidgetByName("dart_hp")

	local pos = var.box_maintask:getWidgetByName("box_dart"):convertToNodeSpace(point)
	box_dart_hp:setPosition(pos)

	local btnTrans = var.xmlDart:getWidgetByName("btn_trans")
	local btnAuto = var.xmlDart:getWidgetByName("btn_auto")
	local btnGiveup = var.xmlDart:getWidgetByName("btn_giveup")

	btnTrans:addClickEventListener(function (sender)
		GameSocket:PushLuaTable("gui.PanelDart.handlePanelData",GameUtilSenior.encode({actionid = "reqTrans"}))
	end)

	btnGiveup:addClickEventListener(function (sender)
		GameSocket:PushLuaTable("gui.PanelDart.handlePanelData",GameUtilSenior.encode({actionid = "reqGiveup"}))
	end)

	btnAuto:addClickEventListener(function (sender)
		GameSocket:PushLuaTable("gui.PanelDart.handlePanelData",GameUtilSenior.encode({actionid = "reqAuto"}))
	end)

	GameSocket:PushLuaTable("gui.PanelBoss.onPanelData",GameUtilSenior.encode({actionid = "showLeftTip"}))
	
	var.leftCenter:getWidgetByName("box_group_operate"):hide()
	var.leftCenter:getWidgetByName("box_group_operate2"):hide()
	var.leftCenter:getWidgetByName("box_group_operate3"):hide()
	
	table.insert(GUIFocusPoint.UIBtnTab, {btn_task, pushTaskButton})

	---副本掉线重新上线
	if GameSocket.PersonBossData and GameSocket.PersonBossData~="" and var.bgVisible then
		GUILeftCenter.showPersonBoss({data = GameSocket.PersonBossData})
	end

	local listTask = var.leftCenter:getWidgetByName("list_task")
	listTask:setTouchEnabled(false)
	cc.EventProxy.new(GameSocket, var.leftCenter)
		:addEventListener(GameMessageCode.EVENT_CHANGE_MAP, GUILeftCenter.handleChangeMap)
		-- :addEventListener(GameMessageCode.EVENT_HIDE_MAINTASK, GUILeftCenter.hideMainTask)
		:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, GUILeftCenter.handlePanelData)
		:addEventListener(GameMessageCode.EVENT_BLACK_BOARD,GUILeftCenter.updateBlackBoard)
		:addEventListener(GameMessageCode.EVENT_GROUP_LIST_CHANGED,GUILeftCenter.updateMyGroup)
		:addEventListener(GameMessageCode.EVENT_SCREEN_TOUCHED, function ()
			GUILeftCenter.hideGroupSelect()
		end)
		-- :addEventListener(GameMessageCode.EVENT_REFRESH_BOSS, onRefreshBoss)
		:addEventListener(GameMessageCode.EVENT_SWITCH_UI_MODE, handleSwitchUIMode)

	GUILeftCenter.btnClickChange()
	-- GUILeftCenter.newTasksLabel()
	GUILeftCenter.operateTeammate()

	--任务列表,使用GUITaskView来初始化任务数据。
	local taskModel = leftCenter:getWidgetByName("box_task")
	GUITaskView.init(taskModel)

	GUILeftCenter.showBossGen()
	
	GameSocket:PushLuaTable("gui.PanelDart.handlePanelData",GameUtilSenior.encode({actionid = "initOK"}))
end

function GUILeftCenter.newTasksLabel()
	local listTask = var.leftCenter:getWidgetByName("list_task")
	local strs = {
		"<font color=#fff843>主线:恶魔石墓</font><font color=#ff3e3e>(未完成)</font>",
		"<font color=#ffffff>击杀:</font><font color=#30ff00>巨型老鼠(1/12)</font>",
		"<font color=#fff843>当一个新手玩家诞生在玛</font>",
		"<font color=#fff843>法大陆上,最迫切的任务</font>",
		"",
		"<font color=#fff843>大改就是升级了,虽说升级</font>",
		"<font color=#fff843>之路漫漫</font>",
	}
	for i=1,#strs do
		local richWidget = GUIRichLabel.new({size = cc.size(200, 30),fontSize = 16, space=10,name = "bottomsMsg"})
		richWidget:setRichLabel(strs[i],"",16)
		listTask:pushBackCustomItem(richWidget)
	end
	listTask:setSwallowTouches(false)
end

local function pushEquipGetButton(sender)
	local btnName = sender:getName()
	if btnName=="btnAnDian" then
		GameSocket:PushLuaTable("gui.PanelBag.handlePanelData",GameUtilSenior.encode({actionid = "flyAnDianNpc",}))
	elseif btnName=="btnBoss" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="btn_main_boss"})
	elseif btnName=="btnHeCheng" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_compose"})
	elseif btnName=="btnShouChong" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="extend_firstPay"})
	elseif btnName=="btnShenZhuang" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="extend_openServer"})
	end
end

function GUILeftCenter.updateEquipGetButtons(data)
	if not var.listEquipGet then return end
	if not (data and data.buttons) then return end
	local btnModel = var.boxEquipGet:getChildByName("btn_model"):hide()
	var.listEquipGet:removeAllItems()
	local btnEquipGet
	for i,v in ipairs(data.buttons) do
		btnEquipGet = btnModel:clone():setName(v.name):setTitleText(v.title):show()
		btnEquipGet:setScale9Enabled(true):setCapInsets(cc.rect(35, 13, 1, 1)):setContentSize(cc.size(150, 41))
		var.listEquipGet:pushBackCustomItem(btnEquipGet)
		GUIFocusPoint.addUIPoint(btnEquipGet, pushEquipGetButton)
	end
	var.listEquipGet:forceDoLayout()
	local listSize = var.listEquipGet:getInnerContainerSize()
	local listHeight = (41 + 5) * #data.buttons - 5 + 20
	-- print("/////////updateEquipGetButtons//////////", listSize.height)
	var.boxEquipGet:setContentSize(var.boxEquipGet:getContentSize().width, listHeight + 10)
	var.listEquipGet:setContentSize(listSize.width, listHeight):align(display.TOP_CENTER, var.boxEquipGet:getContentSize().width * 0.5, listHeight - 5)
	var.boxEquipGet:show()
end

--获得装备的途径
function GUILeftCenter.initGetEquip(show)
	if not var.conEquip then
		var.boxEquipGet = var.leftCenter:getWidgetByName("box_equip_get"):setPosition(305,145)
		var.listEquipGet = var.boxEquipGet:getChildByName("list_equip_get"):setItemsMargin(5)
		var.conEquip=true
	end
	if show then
		GameSocket:PushLuaTable("gui.moduleGuiButton.reqEquipGetButtons", "")
	else
		var.boxEquipGet:hide()
	end
end

function GUILeftCenter.btnClickChange()
	local btnArrs = {"btnTask","btnGroup","btnLeft","btnCreatGroup","btnLeftDart"}
	local contentGroup = var.leftCenter:getWidgetByName("contentGroup"):setTouchEnabled(true)
	local function prsBtnClick(sender)
		local senderName = sender:getName()
		if senderName=="btnTask" then
			contentGroup:setVisible(false)
			var.leftCenter:getWidgetByName("list_task"):show()
			sender:setBrightStyle(1)
			var.leftCenter:getWidgetByName("btnGroup"):setBrightStyle(0)
		elseif senderName=="btnGroup" then
			contentGroup:setVisible(true)
			var.leftCenter:getWidgetByName("list_task"):hide()
			sender:setBrightStyle(1)
			var.leftCenter:getWidgetByName("btnTask"):setBrightStyle(0)
			GUILeftCenter.updateMyGroup()
		elseif senderName=="btnLeft" then
			var.box_maintask:getWidgetByName("box_main"):stopAllActions()
			local function isLayerShow(show)
				--sender:setPositionX(show and 200 or 240)
				var.box_maintask:getWidgetByName("btnLeft"):setPositionX(show and 20 or 290)
				sender:getChildByName("img_left_flag"):setRotation(show and -90 or 90):setPositionX(show and 35 or 27):setPositionY(show and 19 or 37)
			end
			addArrowCallback(var.box_maintask:getWidgetByName("box_main"),sender,isLayerShow)
		elseif senderName=="btnCreatGroup" then
			GameSocket:CreateGroup(0)
		elseif senderName=="btnLeftDart" then
			var.box_maintask:getWidgetByName("dart_info"):stopAllActions()
			local function isLayerShow(show)
				sender:setPositionX(show and 213 or 237)
				sender:getChildByName("img_left_flag"):setRotation(show and -90 or 90)
				var.box_maintask:getWidgetByName("dart_info"):getWidgetByName("left_bg"):setVisible(not show)
			end
			addArrowCallback(var.box_maintask:getWidgetByName("dart_info"),sender,isLayerShow)
		end
	end
	for i=1,#btnArrs do
		local btn = var.leftCenter:getWidgetByName(btnArrs[i])--:setPressedActionEnabled(true)
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
		if i == 1 then
			prsBtnClick(btn)
		end
		if btnArrs[i] == "btnLeft" or btnArrs[i] == "btnLeftDart" then
			btn:getChildByName("img_left_flag"):setRotation(-90)
			btn.showFlag = true
		end
	end
end

--选中队员的操作
function GUILeftCenter.operateTeammate()
	local btnArrs = {"btn_pass_captain","btn_kick_out","btn_level_team","btn_level_team2","btn_jie_san"}
	local function prsBtnClick(sender)
		var.leftCenter:getWidgetByName("box_group_operate"):hide()
		var.leftCenter:getWidgetByName("box_group_operate2"):hide()
		var.leftCenter:getWidgetByName("box_group_operate3"):hide()
		local senderName = sender:getName()
		if senderName=="btn_pass_captain" then
			if var.curName then
				GameSocket:GroupSetLeader(var.curName)
			end
		elseif senderName=="btn_kick_out" then
			if var.curName then
				GameSocket:GroupKickMember(var.curName)
			end
		elseif senderName=="btn_level_team" or senderName=="btn_level_team2" then
			GameSocket:LeaveGroup()
		elseif senderName=="btn_jie_san" then
			GameSocket:PushLuaTable("gui.PanelGroup.handlePanelData",GameUtilSenior.encode({actionid = "dissolveGroup",params={}}))
		end
	end
	for i=1,#btnArrs do
		local btn = var.leftCenter:getWidgetByName(btnArrs[i])
		GUIFocusPoint.addUIPoint(btn,prsBtnClick)
	end
end

--点击屏幕隐藏队伍选中态
function GUILeftCenter.hideGroupSelect()
	local contentGroup = var.leftCenter:getWidgetByName("contentGroup")
	if contentGroup:isVisible() then
		var.leftCenter:getWidgetByName("box_group_operate"):hide()
		var.leftCenter:getWidgetByName("box_group_operate2"):hide()
		var.leftCenter:getWidgetByName("box_group_operate3"):hide()
		if var.curMyGroup then
			var.curMyGroup:getWidgetByName("selectBg"):setVisible(false)
			var.curMyGroup=nil
			var.curGroupIndex=nil
		end
	end
end

--任务栏组队信息
function GUILeftCenter.updateMyGroup(event)
	local myGroupData=clone(GameSocket.mGroupMembers)
	local conOperate = var.leftCenter:getWidgetByName("box_group_operate")
	local conOperate2 = var.leftCenter:getWidgetByName("box_group_operate2")
	local conOperate3 = var.leftCenter:getWidgetByName("box_group_operate3")
	local function prsItemClick(sender)
		if sender:getName()=="btnYaoQing" then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str="main_group"})
			return
		end
		if sender.tag>#myGroupData then return end
		if var.curMyGroup then
			var.curMyGroup:getWidgetByName("selectBg"):setVisible(false)
		end
		sender:getWidgetByName("selectBg"):setVisible(true)
		var.curMyGroup=sender
		var.curGroupIndex=sender.tag
		local myName = GameCharacter._mainAvatar:NetAttr(GameConst.net_name)
		if GameSocket.mCharacter.mGroupLeader==myName then--我是队长
			local temp
			if myName==sender.name then--点的是自己
				temp=conOperate
			else
				temp=conOperate2--点的是队员
			end
			if var.curName==sender.name then
				if temp:isVisible() then
					temp:setVisible(false)
				else
					temp:setVisible(true):setPosition(265,162)
				end
			else
				temp:setVisible(true):setPosition(265,162)
			end
			var.curName=sender.name
		else
			if myName==sender.name then--点的是自己
				if conOperate3:isVisible() then
					conOperate3:setVisible(false)
				else
					conOperate3:setVisible(true):setPosition(265,162)
				end
			else
				conOperate3:setVisible(false)--点的是队员
			end
		end
	end
	local function updateList(item)
		if item.tag<=#myGroupData then
			if var.curMyGroup and var.curGroupIndex==item.tag then
				item:getWidgetByName("selectBg"):setVisible(true)
				var.curMyGroup=item
			else
				item:getWidgetByName("selectBg"):setVisible(false)
			end
			item:setTouchEnabled(true)
			local itemData = myGroupData[item.tag]
			if itemData.gender then
				item:getWidgetByName("head"):loadTexture(headName[itemData.gender-199][itemData.job-99], ccui.TextureResType.plistType):setScale(0.7):setVisible(true)
			end
			item:getWidgetByName("labName"):setString(itemData.name):setVisible(true)
			if itemData.job then
				item:getWidgetByName("labJob"):setString(jobNames[itemData.job-99]):setVisible(true)
			end
			if itemData.level then
				item:getWidgetByName("labLevel"):setString("Lv."..itemData.level):setVisible(true)
			end
			item.name=itemData.name
			GUIFocusPoint.addUIPoint(item,prsItemClick)
			item:getWidgetByName("btnYaoQing"):setVisible(false)
		else
			local btnYaoQing = item:getWidgetByName("btnYaoQing"):setVisible(true)
			item:getWidgetByName("head"):setVisible(false)
			item:getWidgetByName("labName"):setVisible(false)
			item:getWidgetByName("labJob"):setVisible(false)
			item:getWidgetByName("labLevel"):setVisible(false)
			GUIFocusPoint.addUIPoint(btnYaoQing,prsItemClick)
			item:getWidgetByName("selectBg"):setVisible(false)
		end
	end
	local listGroup = var.leftCenter:getWidgetByName("listGroup")
	if #myGroupData<5 and #myGroupData>0 then
		listGroup:reloadData(#myGroupData+1,updateList)
	else
		listGroup:reloadData(#myGroupData,updateList)
	end
	if #myGroupData>0 then
		var.leftCenter:getWidgetByName("btnCreatGroup"):setVisible(false)
	else
		var.leftCenter:getWidgetByName("btnCreatGroup"):setVisible(true)
	end
end

function GUILeftCenter.handleChangeMap(event)
	GUILeftCenter.handleCopyTips(false,true)
	var.curBg = nil
	var.bgVisible = true
	GUILeftCenter.stopAllLabActions()
	GameSocket.PersonBossData = ""
end

function GUILeftCenter.stopAllLabActions()
	if not var.anDianBossBg then return end
	for i=1,8 do
		local btnBoss = var.anDianBossBg:getWidgetByName("btnChuan"..i)
		if btnBoss then
			btnBoss:stopAllActions()
			btnBoss:setTitleText("")
		end	
	end
	var.anDianBossBg:getWidgetByName("labCount"):stopAllActions()
end

function GUILeftCenter.initBtnChuan(data)
	local function prsBtnCall(sender)
		if sender:getName()=="labCount" then
			GameSocket:dispatchEvent({
				name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "hint", visible = true, lblAlert1 = "未知暗殿", lblAlert2 = lblhint[1],
				alertTitle = "关闭"
			})
			return
		end
		GameSocket:PushLuaTable("gui.PanelBoss.handlePanelData",GameUtilSenior.encode({actionid = "btnChuan" , tag=sender.tag}))
	end
	if not var.btnFlag then
		for i=1,#data do
			local btn = var.anDianBossBg:getWidgetByName("btnChuan"..i)
			btn.tag = data[i].tag
			GUIFocusPoint.addUIPoint(btn,prsBtnCall)
		end
	end
	local labCount = var.anDianBossBg:getWidgetByName("labCount")
	labCount:setTouchEnabled(true)
	GUIFocusPoint.addUIPoint(labCount,prsBtnCall)
end

function GUILeftCenter.handleCopyTips(visible, changemap)
	if var.curBg then var.curBg:setVisible(visible);var.bgVisible = visible end
	
	if var.curBg and var.curBg:isVisible() then
		var.leftCenter:getWidgetByName("box_maintask"):hide()
		-- var.leftCenter:getWidgetByName("btn_maintask"):hide()
	else
		if not var.leftCenter:getWidgetByName("box_maintask"):isVisible() then
			if changemap then
				var.leftCenter:getWidgetByName("box_maintask"):show()
				-- var.leftCenter:getWidgetByName("btn_maintask"):hide()
			else
				var.leftCenter:getWidgetByName("box_maintask"):hide()
				-- var.leftCenter:getWidgetByName("btn_maintask"):show()
			end
		end
	end
	if visible then
	else
	end
end

function GUILeftCenter.updateBlackBoard(event)
	local data = GameUtilSenior.decode(event.data)
	var.blackBoard = GUILeftCenter.initCopyTip(var.blackBoard , "personBossTip.uif")
	var.blackBoard:getWidgetByName("lbl_title"):setString(data.title)
	var.blackBoard:getWidgetByName("lbl_hint_1"):setString(data.hint1)
	var.blackBoard:getWidgetByName("lbl_hint_2"):setString(data.hint2)
	var.blackBoard:getWidgetByName("labName"):setString(data.score1)
	var.blackBoard:getWidgetByName("labCount"):setString(data.score2)
	var.blackBoard:getWidgetByName("box_award"):setVisible(data.awardFlag)
end

function GUILeftCenter.handlePanelData(event)
	local data = GameUtilSenior.decode(event.data)
	if event.type =="showyuanshen" then
		GUILeftCenter.handleShowYuanshen(event)
	elseif event.type =="hidePersonBoss" then
		GUILeftCenter.showPersonBoss(event)
	elseif event.type =="setBossNum" then
		GUILeftCenter.updateBossState(event)
	-- elseif event.type =="weiZhiAnDian" then
		-- GUILeftCenter.updateAnDianBossInfo(event)
		-- GUILeftCenter.updateAndianBoss(data)
	elseif event.type =="showCaiLiao" then
		GUILeftCenter.updatecailiao(event)
	elseif event.type =="showGrBoss" then
		GUILeftCenter.updateGrBoss(event)
	elseif event.type =="showshiwang" then
		GUILeftCenter.updateshiwang(event)
	elseif event.type =="showshengwei" then
		GUILeftCenter.updateshengwei(event,data)
	elseif event.type =="showtxdy" then
		GUILeftCenter.updatetxdy(event)
	elseif event.type =="anDianCount" then
		--GUILeftCenter.updateAnDianCount(data)
	elseif event.type == "custompass" then
		if data.hide then
			GUILeftCenter.hideCustomPass()
		elseif data.showExitTips then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", 
			lblConfirm = "退出副本后，将失去即将获得的奖励，是否继续？", btnConfirm = "确定",btnCancel ="取消", confirmCallBack = function ()
				GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "exitMapSure"}))
			end})
		elseif data.showPickUpTips then
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm",
			lblConfirm = "副本里尚有未捡的物品，确定不捡了？", btnConfirm = "我要捡",btnCancel ="不捡了", cancelCallBack = function ()
				GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "exitMapSure"}))
			end})
		else
			GUILeftCenter.updateCustomPass(data)
		end
	elseif event.type == "showjyg" then
		GUILeftCenter.updateJYGLayer(data)
	elseif event.type == "showtjcf" then
		GUILeftCenter.updateTJCFLayer(data)
	elseif event.type == "showyxshacheng" then
		GUILeftCenter.updateYXLayer(data)
	elseif event.type == "dartInfo" then
		GUILeftCenter.updateDartInfo(data)
	elseif event.type == "shaozhuInfo" then
		GUILeftCenter.updateShaozhuInfo(data)
	elseif event.type == "defendInfo" then
		GUILeftCenter.updateDefendInfo(data)
	elseif event.type == "equipGetButtons" then
		GUILeftCenter.updateEquipGetButtons(data)
	end
end

function GUILeftCenter.initCopyTip(obj , xmlName)
	if not obj then
		local pSize = var.leftCenter:getContentSize()
		local y = xmlName == "GDIVDarkRoomTip.uif" and 0 or pSize.height*0.5
		obj = GUIAnalysis.load("ui/layout/"..xmlName)
			:align(display.LEFT_CENTER, 0, y-15)
			:addTo(var.leftCenter, -1)
			:setTouchEnabled(true)
	end
	var.curBg = obj:show()
	if xmlName ~= "GDIVDarkRoomTip.uif" then
		GUILeftCenter.handleCopyTips(var.bgVisible)
		var.leftCenter:getWidgetByName("box_maintask"):hide() 
	end
	return obj
end

function GUILeftCenter.handleShowYuanshen(event)
	var.yuanshenbg = GUILeftCenter.initCopyTip(var.yuanshenbg , "yuanShenTip.uif")

	if event then
		local data = GameUtilSenior.decode(event.data)
		if data and data.cmd=="mainUI" then
			local time = data.time
			local function timeFlash(widget)
				if time>0 then
					time = time -1
					local min = math.floor(time/60)
					local sec = string.format("%02d",time%60)
					local str = min.."分"..sec.."秒"
					var.yuanshenbg:getWidgetByName("lbl_time"):setString(str)
					if time <60 then
						var.yuanshenbg:getWidgetByName("lbl_time"):setColor(cc.c3b(255,0,0))
					else
						var.yuanshenbg:getWidgetByName("lbl_time"):setColor(cc.c3b(0, 255, 0))
					end
				end
			end
			if data.level then
				viewLv = data.level%12>0 and data.level%12 or 12
				var.yuanshenbg:getWidgetByName("lbl_cengji"):setString(GameConst.hardLvName[math.ceil(data.level/12)]..":"..viewLv.."层")
			end
			var.yuanshenbg:getWidgetByName("label_mon"):setString(data.mon_name)
			if data.time and data.time>0 then
				var.yuanshenbg:getWidgetByName("lbl_time"):stopAllActions()
				var.yuanshenbg:getWidgetByName("lbl_time"):runAction(cca.rep(cca.seq({cca.delay(1),cca.cb(timeFlash)}),tonumber(data.time)))
			end
			var.yuanshenbg:getWidgetByName("btn_getaward"):addClickEventListener(function(sender)
				if data.task_state =="done" then
					GameSocket:PushLuaTable("gui.PanelRiChang.onPanelData",GameUtilSenior.encode({actionid ="yuanshen",params={"getAward",}}))
				elseif data.task_state =="next" then
					GameSocket:PushLuaTable("gui.PanelRiChang.onPanelData",GameUtilSenior.encode({actionid ="yuanshen",params={"next",}}))					
				elseif data.task_state =="unfinish" then
					GameSocket:PushLuaTable("gui.PanelRiChang.onPanelData",GameUtilSenior.encode({actionid ="gohome"}))
				end
			end)
			if data.task_state == "done" then
				var.yuanshenbg:getWidgetByName("btn_getaward"):setTitleText("领取奖励")
			elseif data.task_state =="next" then
				var.yuanshenbg:getWidgetByName("btn_getaward"):setTitleText("刷新下一层")
			elseif data.task_state =="unfinish" then
				var.yuanshenbg:getWidgetByName("btn_getaward"):setTitleText("回城")
			end
			if data.firstAward then
				local params ={
					parent = var.yuanshenbg:getWidgetByName("item_icon1"),
					typeId = data.award_id,
					num = data.firstAward.num1,
				}
				GUIItem.getItem(params)
				local params ={
					parent = var.yuanshenbg:getWidgetByName("item_icon2"),
					typeId = data.firstAward.id,
					num = data.firstAward.num2,
				}
				GUIItem.getItem(params)
				var.yuanshenbg:getWidgetByName("item_icon2"):show()
			else
				local params ={
					parent = var.yuanshenbg:getWidgetByName("item_icon1"),
					typeId = data.award_id,
					num = data.award_num,
				}
				GUIItem.getItem(params)
				var.yuanshenbg:getWidgetByName("item_icon2"):hide()
			end
		end
	end
end
function GUILeftCenter.updateBossState(event)
	if  var.personBossBg and GameUtilSenior.isObjectExist(var.personBossBg) then
		var.personBossBg:getWidgetByName("labName"):setString(var.curBossName.."(1/1)")
	end
end

function GUILeftCenter.showPersonBoss(event)

	var.personBossBg = GUILeftCenter.initCopyTip(var.personBossBg , "personBossTip.uif")
	
	local data = GameUtilSenior.decode(event.data)
	local labCount = var.personBossBg:getWidgetByName("labCount")
	GameUtilSenior.runCountDown(labCount,data.time/1000,function (target,time)
		labCount:setString(GameUtilSenior.setTimeFormat(time*1000,2))
	end)
	for i=1,#data.awards do
		local param = {
			parent =  var.personBossBg:getWidgetByName("item"..i),
			typeId = data.awards[i],
		}
		GUIItem.getItem(param)
	end
	var.curBossName=data.bossName
	var.personBossBg:getWidgetByName("labName"):setString(var.curBossName.."("..(data.isKill or 0).."/1)")
	GameCCBridge.callPlatformFunc({func="startLevel",name=data.bossName})

end

function GUILeftCenter.updateAnDianCount(data)
	var.anDianBossBg = GUILeftCenter.initCopyTip(var.anDianBossBg , "GDIVDarkRoomTip.uif")
	local time = data.count
	if var.anDianBossBg then
		var.anDianBossBg:getWidgetByName("lbltitle"):setString(data.title)
		local labCount = var.anDianBossBg:getWidgetByName("labCount")
		GameUtilSenior.runCountDown(labCount,time,function( target,count )
			target:setString("剩余时间："..GameUtilSenior.setTimeFormat(count*1000,2))
		end)
	end
end

--押镖信息面板
function GUILeftCenter.updateDartInfo(data)
	if not data then data={} end

	if data.hide and data.hide == 1 then
		var.box_maintask:getWidgetByName("box_dart"):hide()
		var.box_maintask:getWidgetByName("box_main"):show()
		return
	end

	if data.show and data.show == 1 then
		var.box_maintask:getWidgetByName("box_dart"):show()
		var.box_maintask:getWidgetByName("box_main"):hide()
	end

	local time = data.time_left
	if time ~= nil then 
		local lbTime = var.xmlDart:getWidgetByName("lb_time")
		lbTime:stopAllActions()
		lbTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function (target)
			--time = time - 1
			if time and time-os.time()-1 >= 0 then
				lbTime:setString(GameUtilSenior.setTimeFormat((time-os.time())*1000,3))
			else
				lbTime:stopAllActions()
			end
		end)})))
	end
	local btnAuto = var.xmlDart:getWidgetByName("btn_auto")

	local state = data.dart_state
	if state ~= nil then
		local lbState = var.xmlDart:getWidgetByName("lb_state")
		if state == 0 then
			lbState:setString("停止")
			lbState:setColor(GameBaseLogic.getColor(0xFF3E3E))
			if btnAuto ~= nil then
				GameUtilSenior.addHaloToButton(btnAuto, "btn_normal_light1",nil,100,36)	
			end

		else
			lbState:setString("移动中")
			lbState:setColor(GameBaseLogic.getColor(0x30FF00))
			
			if btnAuto ~= nil then
				GameUtilSenior.removeHaloFromButton(btnAuto)	
			end
		end
	end

	local hp = data.dart_hp
	local maxhp = data.dart_maxhp
	local progress = var.xmlDart:getWidgetByName("pro_hp")
	if state == nil then
		if hp ~= nil and maxhp ~= nil then
			local perc = math.ceil(hp * 100 / maxhp)
			progress:setPercent(perc,100)
		else
			progress:setPercent(100,100):setFontSize( 14 )
		end
	end
	if data.award then
		for i=1,2 do
			local itemIcon = var.xmlDart:getWidgetByName("item_pride"..(i - 1))
			if data.award[i] then
				itemIcon:setVisible(true)
				local param={parent=itemIcon , typeId=data.award[i].id , num = data.award[i].num}
				GUIItem.getItem(param)
			else
				itemIcon:setVisible(false)
			end
		end	
	end
end

function GUILeftCenter.updateDefendInfo(data)
	if not data then return end
	if not var.xmlDefend then
		var.xmlDefend = GUILeftCenter.initCopyTip(var.xmlDefend, "GDIVProtectTip.uif")
		local btnSwitch = var.xmlDefend:getWidgetByName("btn_switch")
		local boxDefendInfo = var.xmlDefend:getWidgetByName("box_defend_info")

		var.xmlDefend:getWidgetByName("img_tip_bg"):setOpacity(0.4 * 255)


		local function handleDefendVisible(visible)
			if visible then
				btnSwitch:setPositionX(182)
				btnSwitch:setRotation(0)
			else
				btnSwitch:setPositionX(214)
				btnSwitch:setRotation(180)
			end
		end

		local defendButtons = {"btn_exit", "btn_defend_power", "btn_defend_slave"}

		local function pushDefendButton(pSender)
			local name = pSender:getName()
			if name == "btn_exit" then
				GameSocket:PushLuaTable("map.defend.onClientData", GameUtilSenior.encode({actionid = "exit"}));
			elseif name == "btn_defend_power" then
				GameSocket:PushLuaTable("map.defend.onClientData", GameUtilSenior.encode({actionid = "addPower"}));
			elseif name == "btn_defend_slave" then
				GameSocket:PushLuaTable("map.defend.onClientData", GameUtilSenior.encode({actionid = "callSlave"}));
			end
		end

		addArrowCallback(boxDefendInfo, btnSwitch, handleDefendVisible)
		local btnDefend
		for i,v in ipairs(defendButtons) do
			btnDefend = var.xmlDefend:getWidgetByName(v)
			btnDefend:addClickEventListener(pushDefendButton)
			if v == "btn_defend_power" or v == "btn_defend_slave" then
				btnDefend:getTitleRenderer():setAdditionalKerning(0)
			end
		end

		local boxDefendGain = var.xmlDefend:getWidgetByName("box_defend_gain")
		-- print("//////////////////////updateDefendInfo//////////////////////", display.height)
		boxDefendGain:align(display.CENTER, display.width * 0.5, -5 - (display.height - 640))

		local boxStatueHp = var.xmlDefend:getWidgetByName("box_statue_hp")
		boxStatueHp:align(display.TOP_CENTER, 590, 424)

		local statueHpBar = boxStatueHp:getWidgetByName("img_statue_hp_bar"):setPercent(str_mp,str_maxmp):setFontSize(16):enableOutline(GameBaseLogic.getColor(0x3a0000),1)

	else
		var.curBg=var.xmlDefend
		GUILeftCenter.handleCopyTips(true)
	end

	var.m_nStatueId = data.statueId

	if data.statueName then
		var.xmlDefend:getWidgetByName("lbl_statue_name"):setString(data.statueName)
	end

	--关卡名
	if data.levelName then
		var.xmlDefend:getWidgetByName("lbl_tip_title"):setString(data.levelName)
	end

	--刷新奖励
	local awards = data.awards
	if awards then
		local awardIcon
		for i=1,3 do
			awardIcon = var.xmlDefend:getWidgetByName("award_icon"..i)
			if awards[i] then
				awardIcon:show()
				GUIItem.getItem({parent = awardIcon, typeId = awards[i].id, num = awards[i].count})
			else
				awardIcon:hide()
			end
		end
	end

	-- 关卡剩余时间
	local remainTime = data.remainTime
	if remainTime then 
		local endTime = os.time() + remainTime
		local lblRemainTime = var.xmlDefend:getWidgetByName("lbl_remain_time")
		lblRemainTime:setString(GameUtilSenior.setTimeFormat((endTime - os.time()) * 1000, 3))
		lblRemainTime:stopAllActions()
		lblRemainTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function (target)
			if endTime - os.time() >= 0 then
				lblRemainTime:setString(GameUtilSenior.setTimeFormat((endTime - os.time()) * 1000, 3))
			else
				lblRemainTime:stopAllActions()
			end
		end)})))
	end

	--鼓舞和召唤按钮刷新(显示cd和价格)
	local function updateDefendButton(pSender, cost, cdTime)
		pSender:stopAllActions()
		local titleTextPre = "免费"
		if cost and cost > 0 then
			titleTextPre = cost.."元宝"
		end

		if cdTime and cdTime > 0 then
			local endTime = os.time() + cdTime
			local remainTime = cdTime

			pSender:setTitleText(titleTextPre.."("..remainTime..")")
			pSender:setBright(false)
			-- pSender:setTouchEnabled(false)
			pSender:setZoomScale(0)

			pSender:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function (target)
				remainTime = endTime - os.time()
				if remainTime > 0 then
					pSender:setTitleText(titleTextPre.."("..remainTime..")")
				else
					pSender:stopAllActions():setTitleText(titleTextPre):setBright(true):setZoomScale(-0.12)
				end
			end)})))
		else
			pSender:setBright(true):setTitleText(titleTextPre):setZoomScale(-0.12)
		end
	end

	--鼓舞按钮刷新
	if data.updateInspire then
		local btnDefendPower = var.xmlDefend:getWidgetByName("btn_defend_power")
		updateDefendButton(btnDefendPower, data.inspireCost,  data.inspireCD)
	end

	if data.updateSlave then
		local btnDefendSlave = var.xmlDefend:getWidgetByName("btn_defend_slave")
		updateDefendButton(btnDefendSlave, data.slaveCost, data.slaveCD)
	end

end

function GUILeftCenter.updateShaozhuInfo(data)

	if not data then data={} end
	if not var.xmlShaozhu then
		var.xmlShaozhu = GUILeftCenter.initCopyTip(var.xmlShaozhu , "GDIVPigTips.uif")	
		local btnArrow = var.xmlShaozhu:getWidgetByName("btnHide")
		local tip_layer = var.xmlShaozhu:getWidgetByName("box_shzozhu_info")
		local map_name = var.xmlShaozhu:getWidgetByName("mapnamebg")
		map_name:setVisible(false)
		btnArrow:setRotation(0)
		map_name:setTouchEnabled(true)
		local function isLayerShow(show)
			if show then
				btnArrow:setPositionX(205)
				btnArrow:setRotation(0)
				map_name:setVisible(false)
			else
				btnArrow:setPositionX(237)
				btnArrow:setRotation(180)
				map_name:setVisible(true)
			end
		end
		addArrowCallback(tip_layer,btnArrow,isLayerShow)
		addArrowCallback(tip_layer,map_name,isLayerShow)

		local point=cc.p(display.width/10 * 6, display.height / 4)
		local box_op = var.xmlShaozhu:getWidgetByName("box_op")
		
		local pos = var.xmlShaozhu:convertToNodeSpace(point)
		box_op:setPosition(pos)

		-- 退出
		local btnExit = var.xmlShaozhu:getWidgetByName("btn_exit")
		btnExit:setScale(0.8)
		btnExit:addClickEventListener(GUILeftCenter.shaozhuOP)
		
		-- 开始刷怪
		local btnStart = var.xmlShaozhu:getWidgetByName("btn_shaozhu_start")
		btnStart:addClickEventListener(GUILeftCenter.shaozhuOP)

		-- 购买次数
		local btnAddLeitingCount = var.xmlShaozhu:getWidgetByName("btn_add_leiting_count")
		btnAddLeitingCount:addClickEventListener(GUILeftCenter.shaozhuOP)

		-- 购买次数
		local btnAddHaoyueCount = var.xmlShaozhu:getWidgetByName("btn_add_haoyue_count")
		btnAddHaoyueCount:addClickEventListener(GUILeftCenter.shaozhuOP)

		-- 召唤
		var.xmlShaozhu.btnLeiting = var.xmlShaozhu:getWidgetByName("btn_leiting")
		var.xmlShaozhu.btnLeiting:addClickEventListener(GUILeftCenter.shaozhuOP)

		var.xmlShaozhu.leitingNum = display.newBMFontLabel({font = "image/typeface/num_23.fnt",})
		var.xmlShaozhu.leitingNum:addTo(var.xmlShaozhu.btnLeiting)
		var.xmlShaozhu.leitingNum:setString("5");
		var.xmlShaozhu.leitingNum:setPositionX(62);
		var.xmlShaozhu.leitingNum:setPositionY(-10);

		-- 召唤
		var.xmlShaozhu.btnHaoyue = var.xmlShaozhu:getWidgetByName("btn_haoyue")
		var.xmlShaozhu.btnHaoyue:addClickEventListener(GUILeftCenter.shaozhuOP)

		var.xmlShaozhu.haoYueNum = display.newBMFontLabel({font = "image/typeface/num_23.fnt",})
		var.xmlShaozhu.haoYueNum:addTo(var.xmlShaozhu.btnHaoyue)
		var.xmlShaozhu.haoYueNum:setString("0");
		var.xmlShaozhu.haoYueNum:setPositionX(62);
		var.xmlShaozhu.haoYueNum:setPositionY(-10);

	else
		var.curBg=var.xmlShaozhu
		GUILeftCenter.handleCopyTips(true)
	end

	-- 关卡信息
	if data.section_info then
		local lbl_wave = var.xmlShaozhu:getWidgetByName("lbl_wave")
		if lbl_wave then
			lbl_wave:setString(tostring(data.section_info.cur).."/"..tostring(data.section_info.max))
		end
	end

	-- 剩余怪物数
	if data.mon_info then
		local lbl_mon_count = var.xmlShaozhu:getWidgetByName("lbl_mon_count")
		if lbl_mon_count then
			lbl_mon_count:setString(tostring(data.mon_info.cur).."/"..tostring(data.mon_info.max))
		end
	end

	-- 奖品
	if data.award then
		local itemIcon = var.xmlShaozhu:getWidgetByName("item_pride0")
		itemIcon:setVisible(true)
		local param={parent=itemIcon , typeId=data.award.id , num = data.award.num}
		GUIItem.getItem(param)
	end

	-- 关卡剩余时间
	local time = data.time_left
	if time ~= nil then 
		local lbTime = var.xmlShaozhu:getWidgetByName("lbl_time")
		lbTime:setString(GameUtilSenior.setTimeFormat((time-os.time()-1)*1000,3))
		lbTime:stopAllActions()
		lbTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function (target)
			
			if time and  time-os.time() >= 0 then
				lbTime:setString(GameUtilSenior.setTimeFormat((time-os.time()-1)*1000,3))
			else
				lbTime:stopAllActions()
			end
		end)})))
	end

	-- 刷怪剩余时间
	local tick = data.gen_mon_time
	if tick ~= nil then
		local lbNextWave = var.xmlShaozhu:getWidgetByName("lbl_next_wave_tick")
		local lbTick = var.xmlShaozhu:getWidgetByName("lbl_tick")
		local btnGenMon = var.xmlShaozhu:getWidgetByName("btn_shaozhu_start")
		btnGenMon:show()
		local tickflag=tick+os.time()
		lbNextWave:show() 
		lbTick:show() 
		lbTick:setString(tick)
		lbTick:stopAllActions()
		lbTick:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function (target)
			--tick = tick - 1
			if tick and tick-1 >= 0 then
				lbTick:setString(tickflag-os.time())
			else
				lbTick:stopAllActions()
				lbTick:hide()
				lbNextWave:hide()
				btnGenMon:hide()
			end
		end)})))
	else
		local lbNextWave = var.xmlShaozhu:getWidgetByName("lbl_next_wave_tick")
		local lbTick = var.xmlShaozhu:getWidgetByName("lbl_tick")
		local btnGenMon = var.xmlShaozhu:getWidgetByName("btn_shaozhu_start")

		if data.gen_mon_tick_show == nil or data.gen_mon_tick_show == 0 then
			lbNextWave:hide()
			lbTick:hide()
			btnGenMon:hide()
		end
	end

	-- 显示召唤次数
	if data.call_count ~= nil then
		var.xmlShaozhu.leitingNum:setString(tostring(data.call_count.leiting))
		var.xmlShaozhu.haoYueNum:setString(tostring(data.call_count.haoyue))
		var.xmlShaozhu.btnLeiting:setEnabled(true)
		var.xmlShaozhu.btnHaoyue:setEnabled(true)
	end

	var.xmlShaozhu:setTouchEnabled(true)
end

function GUILeftCenter.shaozhuOP(sender)
	if sender:getName() == "btn_exit" then
		GameSocket:PushLuaTable("map.shaozhu.btnOp",GameUtilSenior.encode({actionid = "gohome"}))
		return
	end

	if sender:getName() == "btn_shaozhu_start" then
		GameSocket:PushLuaTable("map.shaozhu.btnOp",GameUtilSenior.encode({actionid = "start_gen_mon"}))
		return
	end
	-- 购买雷霆次数
	if sender:getName() == "btn_add_leiting_count" then
		GameSocket:PushLuaTable("map.shaozhu.btnOp",GameUtilSenior.encode({actionid = "buy_leiting"}))
		return
	end
	-- 购买皓月次数
	if sender:getName() == "btn_add_haoyue_count" then
		GameSocket:PushLuaTable("map.shaozhu.btnOp",GameUtilSenior.encode({actionid = "buy_haoyue"}))
		return
	end
	-- 召唤雷霆
	if sender:getName() == "btn_leiting" then
		GameSocket:PushLuaTable("map.shaozhu.btnOp",GameUtilSenior.encode({actionid = "call_leiting"}))
		return
	end	
	-- 召唤皓月
	if sender:getName() == "btn_haoyue" then
		GameSocket:PushLuaTable("map.shaozhu.btnOp",GameUtilSenior.encode({actionid = "call_haoyue"}))
		return
	end	
end

function GUILeftCenter.updateAnDianBossInfo(event)
	var.anDianBossBg = GUILeftCenter.initCopyTip(var.anDianBossBg , "GDIVDarkRoomTip.uif")
	local sortFunc = function(a,b)
		return a.upTime < b.upTime
	end
	local data = GameUtilSenior.decode(event.data)
	table.sort(data, sortFunc)
	GUILeftCenter.initBtnChuan(data)
	for i=1,8 do
		local btnBoss = var.anDianBossBg:getWidgetByName("btnChuan"..i)
		btnBoss:setTitleColor(cc.c3b(220,220,220))
		btnBoss:stopAllActions()
		if i<=#data then
			btnBoss:setVisible(true)
			local time = data[i].upTime
			local nameStr = data[i].bossName
			if time==0 then
				btnBoss:setTitleText(nameStr.."(已刷新)")
				btnBoss:setTitleColor(cc.c3b(0,255,0))
			else	
				btnBoss:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
					time = time - 1
					if time > 0 then
						btnBoss:setTitleText(nameStr.."("..GameUtilSenior.setTimeFormat(time*1000,3)..")")
					else
						btnBoss:stopAllActions()
						btnBoss:setTitleText(nameStr.."(已刷新)")
						GameSocket:PushLuaTable("gui.PanelBoss.handlePanelData",GameUtilSenior.encode({actionid = "reqUpdate"}))
					end
				end)})))
			end
		else
			btnBoss:setVisible(false)
		end
	end
end
----------------隐藏左边tips
function GUILeftCenter_setpos(data)
	var.zhenMoBg = GUILeftCenter.initCopyTip(var.zhenMoBg , "GDIVMaterialTip.uif")
	local zhenMo_bg=var.zhenMoBg:getWidgetByName("zhenMo_bg")

	local btnArrow =var.zhenMoBg:getWidgetByName("btnHide")
	local bossnamebg =var.zhenMoBg:getWidgetByName("bossnamebg")
	local function isLayerShow(show)
		if show then
			btnArrow:setRotation(0)
			bossnamebg:setVisible(false)
		else
			btnArrow:setRotation(180)
			bossnamebg:setVisible(data.title~=nil)
		end
	end
	addArrowCallback(zhenMo_bg,btnArrow,isLayerShow)
	addArrowCallback(zhenMo_bg,bossnamebg,isLayerShow)

	if data.title then
		var.zhenMoBg:getWidgetByName("lbltitlename"):setString(data.title)
	end
	var.zhenMoBg:getWidgetByName("item1"):setPositionX(48)
	var.zhenMoBg:getWidgetByName("item2"):setPositionX(131)
end

function GUILeftCenter.updateGrBoss(event)----------个人boss
	local data = GameUtilSenior.decode(event.data)
	GUILeftCenter_setpos(data)

	
	var.zhenMoBg:getWidgetByName("object2"):setString("击杀小怪："):setVisible(true):setPositionY(240)
	var.zhenMoBg:getWidgetByName("object5"):setString("击杀boss："):setVisible(true)
	var.zhenMoBg:getWidgetByName("Text_1"):setString("副本奖励：")
	var.zhenMoBg:getWidgetByName("txt_txdy"):setVisible(false)
	var.zhenMoBg:getWidgetByName("labMo1"):setString(data.killmon.."/"..data.mon):setVisible(true):setPositionY(240)
	var.zhenMoBg:getWidgetByName("labMo2"):setString(data.killboss.."/"..data.boss):setVisible(true)
	local btnLing1 = var.zhenMoBg:getWidgetByName("btnLingQu1"):setPosition(45,54)
	local btnLing2 = var.zhenMoBg:getWidgetByName("btn_back")
	local btnLing3 = var.zhenMoBg:getWidgetByName("btnLingQu2"):setPosition(140,54)
	local imgPass = var.zhenMoBg:getWidgetByName("Img_pass"):setVisible(false)
	local txt_doublevcion = var.zhenMoBg:getWidgetByName("txt_doublevcion"):setVisible(false)
	local title=var.zhenMoBg:getWidgetByName("lbl_title"):setVisible(false)
	local labTime = var.zhenMoBg:getWidgetByName("lbl_time"):setVisible(false)
	var.zhenMoBg:getWidgetByName("lbl_pk"):setVisible(false)

	local function prsBtnItem(sender)
		if data.func then
			GameSocket:PushLuaTable(data.func,GameUtilSenior.encode({actionid ="single"}))
		end
	end
	GUIFocusPoint.addUIPoint(btnLing1 , prsBtnItem)	
	local function prsBtnItem2(sender)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm", 
		lblConfirm = "退出副本后，将失去即将获得的奖励，是否继续？", btnConfirm = "确定",btnCancel ="取消", confirmCallBack = function ()
			GameSocket:PushLuaTable(data.func,GameUtilSenior.encode({actionid ="back"}))
		end})
	end
	GUIFocusPoint.addUIPoint(btnLing2 , prsBtnItem2)	
	local function prsBtnItem3(sender)
		if data.func then
			GameSocket:PushLuaTable(data.func,GameUtilSenior.encode({actionid ="double"}))
		end
		
	end
	btnLing3:removeChildByName("img_bln")
	GameUtilSenior.addHaloToButton(btnLing3, "btn_normal_light1")
	GUIFocusPoint.addUIPoint(btnLing3 , prsBtnItem3)	
	
	if data.title then 
		title:setVisible(true):setString(data.title)
	end
	local Time = var.zhenMoBg:getWidgetByName("labMo5"):setVisible(true)
	if Time:getString()=="" then data.time=10*60*1000 end --处理掉线是不现实倒计时
	if data.time>0 then
		Time:setString(GameUtilSenior.setTimeFormat((data.time-os.time()-1)*1000,3))
		Time:stopAllActions()
		Time:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
			--data.time = data.time - 1000
			if data.time-os.time() > 0 then
				Time:setString(GameUtilSenior.setTimeFormat( (data.time-os.time())*1000,3))
			else
				Time:stopAllActions()
			end
		end)})))
	end
	if data.killmon >0 and data.killmon==data.mon and data.killboss ==data.boss  then 
		if data.isTask and data.isTask==true then
			btnLing1:setVisible(true):setPosition(93,48)
			btnLing3:setVisible(false)
			btnLing2:setVisible(false)
			imgPass:setVisible(true)
			if data.vcoin then 
				txt_doublevcion:setVisible(false):setString("消耗"..data.vcoin.."元宝")
			end
		else
			btnLing1:setVisible(true)
			btnLing3:setVisible(true)
			btnLing2:setVisible(false)
			imgPass:setVisible(true)
			if data.vcoin then 
				txt_doublevcion:setVisible(true):setString("消耗"..data.vcoin.."元宝")
			end
		end

		var.zhenMoBg:getWidgetByName("object10"):setVisible(false)
		Time:setVisible(false)
	else
		btnLing2:setVisible(true)
		btnLing1:setVisible(false)
		btnLing3:setVisible(false)
		var.zhenMoBg:getWidgetByName("object10"):setVisible(true)
	end 
	if data.award and #data.award>1 then
		var.zhenMoBg:getWidgetByName("item1"):setPositionX(48)
		var.zhenMoBg:getWidgetByName("item2"):setPositionX(131)
	else
		var.zhenMoBg:getWidgetByName("item1"):setPositionX(91)
	end
	for i=1,2 do
		local itemIcon = var.zhenMoBg:getWidgetByName("item"..i)
		if data.award[i] then
			itemIcon:setVisible(true)
			local param={parent=itemIcon , typeId=data.award[i].id , num = data.award[i].num}
			GUIItem.getItem(param)
		else
			itemIcon:setVisible(false)
		end
	end	
end

function GUILeftCenter.updatecailiao(event)----------材料副本
	local data = GameUtilSenior.decode(event.data)
	GUILeftCenter_setpos(data)

	
	var.zhenMoBg:getWidgetByName("object2"):setString("击杀小怪："):setVisible(true):setPositionY(225)
	var.zhenMoBg:getWidgetByName("object5"):setString("击杀boss："):setVisible(false)
	var.zhenMoBg:getWidgetByName("Text_1"):setString("副本奖励：")
	
	var.zhenMoBg:getWidgetByName("labMo1"):setString(data.killmon.."/"..data.mon):setPositionY(225):setVisible(true)
	var.zhenMoBg:getWidgetByName("labMo2"):setString(data.killboss.."/"..data.boss):setVisible(false)
	local btnLing1 = var.zhenMoBg:getWidgetByName("btnLingQu1"):setPosition(45,54)
	local btnLing2 = var.zhenMoBg:getWidgetByName("btn_back"):setScale(0.8)
	local btnLing3 = var.zhenMoBg:getWidgetByName("btnLingQu2")
	GameUtilSenior.addHaloToButton(btnLing3, "btn_normal_light1")---呼吸灯
	local imgPass = var.zhenMoBg:getWidgetByName("Img_pass"):setVisible(false)
	local txt_doublevcion = var.zhenMoBg:getWidgetByName("txt_doublevcion"):setVisible(false)
	local title=var.zhenMoBg:getWidgetByName("lbl_title"):setVisible(false)
	local labTime = var.zhenMoBg:getWidgetByName("lbl_time"):setVisible(false)
	var.zhenMoBg:getWidgetByName("lbl_pk"):setVisible(false)
	var.zhenMoBg:getWidgetByName("txt_txdy"):setVisible(false)
	var.zhenMoBg:getWidgetByName("object10"):setVisible(true)
	local function prsBtnItem(sender)
		if data.func then
			GameSocket:PushLuaTable(data.func,GameUtilSenior.encode({actionid ="single"}))
		end
	end
	GUIFocusPoint.addUIPoint(btnLing1 , prsBtnItem)	
	local function prsBtnItem2(sender)
		GameSocket:PushLuaTable("npc.party.cailiao.handlePanelData",GameUtilSenior.encode({actionid ="back"}))
	end
	GUIFocusPoint.addUIPoint(btnLing2 , prsBtnItem2)	
	local function prsBtnItem3(sender)
		if data.func then
			GameSocket:PushLuaTable(data.func,GameUtilSenior.encode({actionid ="double"}))
		end
		
	end
	GUIFocusPoint.addUIPoint(btnLing3 , prsBtnItem3)	
	
	if data.title then 
		title:setVisible(true):setString(data.title)
	end
	local Time = var.zhenMoBg:getWidgetByName("labMo5"):setVisible(true)
	if data.falg==0 then 
		--if Time:getString()=="" then data.time=10*60*1000 end --处理掉线是不现实倒计时
		if data.time>0 then
			Time:stopAllActions()
			
			Time:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
				
				if data.time-os.time()-1 > 0 then
					--print(data.time-os.time()-1,os.time())
					Time:setString(GameUtilSenior.setTimeFormat((data.time-os.time()-1)*1000,3))
				else
					Time:stopAllActions()
				end
			end)})))
		end
	end
	if data.killmon >0 and data.killmon==data.mon and data.killboss ==data.boss  then 
		btnLing1:setVisible(true)
		btnLing3:setVisible(true)
		btnLing2:setVisible(false)
		imgPass:setVisible(true)
		if data.vcoin then 
			txt_doublevcion:setVisible(true):setString("消耗"..data.vcoin.."元宝")
		end
		var.zhenMoBg:getWidgetByName("object10"):setVisible(false)
		Time:setVisible(false)
	else
		btnLing2:setVisible(true)
		btnLing1:setVisible(false)
		btnLing3:setVisible(false)
	end 
	for i=1,2 do
		local itemIcon = var.zhenMoBg:getWidgetByName("item"..i)
		if data.award[i] then
			itemIcon:setVisible(true)
			local param={parent=itemIcon , typeId=data.award[i].id , num = data.award[i].num}
			GUIItem.getItem(param)
		else
			itemIcon:setVisible(false)
		end
	end	
end

function GUILeftCenter.updateshiwang(event)----------尸王殿
	local data = GameUtilSenior.decode(event.data)
	--data.title="尸王殿"
	GUILeftCenter_setpos(data)

	local data = GameUtilSenior.decode(event.data)
	var.zhenMoBg:getWidgetByName("txt_txdy"):setVisible(false)
	var.zhenMoBg:getWidgetByName("object2"):setString("当前波数："):setVisible(true):setPositionY(240)
	var.zhenMoBg:getWidgetByName("object5"):setString("剩余尸王数："):setVisible(true)
	var.zhenMoBg:getWidgetByName("Text_1"):setString("奖励浏览：")
	var.zhenMoBg:getWidgetByName("object10"):setVisible(true)
	var.zhenMoBg:getWidgetByName("labMo1"):setString(data.killmon.."/"..data.mon):setVisible(true):setPositionY(240)
	var.zhenMoBg:getWidgetByName("labMo2"):setString(data.killboss.."/"..data.boss):setVisible(true)
	local btnLing1 = var.zhenMoBg:getWidgetByName("btnLingQu1")
	local btnLing2 = var.zhenMoBg:getWidgetByName("btn_back")
	local btnLing3 = var.zhenMoBg:getWidgetByName("btnLingQu2")
	var.zhenMoBg:getWidgetByName("txt_doublevcion"):setVisible(false)
	--print(">>>",data.title)
	local title=var.zhenMoBg:getWidgetByName("lbl_title"):setVisible(false)
	local imgPass = var.zhenMoBg:getWidgetByName("Img_pass"):setVisible(false)
	local labTime = var.zhenMoBg:getWidgetByName("lbl_time"):setVisible(false)
	var.zhenMoBg:getWidgetByName("lbl_pk"):setVisible(false)
	btnLing1:setVisible(false)
	btnLing2:setVisible(true)
	btnLing3:setVisible(false)
	if data.title then 
		title:setVisible(true):setString(data.title)
	end
	local function prsBtnItem2(sender)
		GameSocket:PushLuaTable("npc.shiwang.back_home",GameUtilSenior.encode({actionid ="back"}))
	end
	GUIFocusPoint.addUIPoint(btnLing2 , prsBtnItem2)	

	local Time = var.zhenMoBg:getWidgetByName("labMo5"):setVisible(true)
	if Time:getString()=="" then data.time=10*60*1000 end --处理掉线是不现实倒计时
	if data.time>0 then
		Time:stopAllActions()
		Time:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
		--	print(data.time-os.time()-1)
			if data.time-os.time()-1 > 0 then
				Time:setString(GameUtilSenior.setTimeFormat((data.time-os.time()-1)*1000,3)):setVisible(true)
			else
				Time:stopAllActions()
			end
		end)})))
	end
	if data.award and #data.award>1 then
		var.zhenMoBg:getWidgetByName("item1"):setPositionX(48)
		var.zhenMoBg:getWidgetByName("item2"):setPositionX(131)
	else
		var.zhenMoBg:getWidgetByName("item1"):setPositionX(91)
	end
	for i=1,2 do
		local itemIcon = var.zhenMoBg:getWidgetByName("item"..i)
		if data.award[i] then
			itemIcon:setVisible(true)
			local param={parent=itemIcon , typeId=data.award[i].id , num = data.award[i].num}
			GUIItem.getItem(param)
		else
			itemIcon:setVisible(false)
		end
	end	
	--:setPositionY(225)
end


-------神威狱----
function GUILeftCenter.updateshengwei(event,flag)
	local data = GameUtilSenior.decode(event.data)
	data.title="神威魔狱"
	GUILeftCenter_setpos(data)

	
	var.zhenMoBg:getWidgetByName("txt_txdy"):setVisible(false)
	var.zhenMoBg:getWidgetByName("object2"):setVisible(true):setString("BOSS"):setPositionY(240)
	var.zhenMoBg:getWidgetByName("object5"):setVisible(true):setString("需要通行证：")
	var.zhenMoBg:getWidgetByName("Text_1"):setVisible(true):setString("到达下一层可得：")
	local title=var.zhenMoBg:getWidgetByName("lbl_title"):setVisible(false)
	var.zhenMoBg:getWidgetByName("labMo1"):setVisible(true):setString(data.killmon==0 and "已击杀"  or "未击杀"):setPositionY(240)
	var.zhenMoBg:getWidgetByName("labMo2"):setVisible(true):setString(data.killboss.."/"..data.boss)
	var.zhenMoBg:getWidgetByName("object10"):setVisible(true)
	local title=var.zhenMoBg:getWidgetByName("lbl_title"):setVisible(false)
	local btnLing1 = var.zhenMoBg:getWidgetByName("btnLingQu1")
	local btnLing2 = var.zhenMoBg:getWidgetByName("btn_back")
	local btnLing3 = var.zhenMoBg:getWidgetByName("btnLingQu2")
	local imgPass = var.zhenMoBg:getWidgetByName("Img_pass"):setVisible(false)
	local txt_doublevcion = var.zhenMoBg:getWidgetByName("txt_doublevcion"):setVisible(false)
	local labTime = var.zhenMoBg:getWidgetByName("lbl_time"):setVisible(false)
	var.zhenMoBg:getWidgetByName("lbl_pk"):setVisible(false)
	btnLing1:setVisible(false)
	btnLing2:setVisible(true)
	btnLing3:setVisible(false)
	
	if data.title then 
		--print(data.title)
		title:setVisible(true):setString(data.title)
	end
	local function prsBtnItem2(sender)
		GameSocket:PushLuaTable("npc.shengwei.handlePanelData",GameUtilSenior.encode({actionid ="back"}))
	end
	GUIFocusPoint.addUIPoint(btnLing2 , prsBtnItem2)	

	local Time = var.zhenMoBg:getWidgetByName("labMo5"):setVisible(true)
	if data.falg==0 then 
		if Time:getString()=="" then data.time=10*60*1000 end --处理掉线是不现实倒计时
		if data.time>0 then
			Time:stopAllActions()
			Time:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
				
				if data.time-os.time()-1 > 0  then
					Time:setString(GameUtilSenior.setTimeFormat((data.time-os.time()-1)*1000,3))
				else
					Time:stopAllActions()
				end
			end)})))
		end
	end

	for i=1,2 do
		local itemIcon = var.zhenMoBg:getWidgetByName("item"..i)
		if data.award[i] then
			itemIcon:setVisible(true)
			local param={parent=itemIcon , typeId=data.award[i].id , num = data.award[i].num}
			GUIItem.getItem(param)
		else
			itemIcon:setVisible(false)
		end
	end	
end
----天下第一
function GUILeftCenter.updatetxdy(event)
	local data = GameUtilSenior.decode(event.data)
	--data.title="天下第一"
	data.title=""
	GUILeftCenter_setpos(data)

	var.zhenMoBg:getWidgetByName("object2"):setVisible(false)
	var.zhenMoBg:getWidgetByName("object5"):setVisible(false)
	var.zhenMoBg:getWidgetByName("Text_1"):setVisible(false)

	var.zhenMoBg:getWidgetByName("labMo1"):setVisible(false)
	var.zhenMoBg:getWidgetByName("labMo2"):setVisible(false)
	var.zhenMoBg:getWidgetByName("item"..1):setVisible(false)
	var.zhenMoBg:getWidgetByName("item"..2):setVisible(false)
	var.zhenMoBg:getWidgetByName("object10"):setVisible(false)
	var.zhenMoBg:getWidgetByName("labMo5"):setVisible(false)
	var.zhenMoBg:getWidgetByName("txt_doublevcion"):setVisible(false)
	var.zhenMoBg:getWidgetByName("txt_txdy"):setString(data.txt):setVisible(true)
	local imgPass = var.zhenMoBg:getWidgetByName("Img_pass"):setVisible(false)
	local btnLing1 = var.zhenMoBg:getWidgetByName("btnLingQu1"):setVisible(false)
	local btnLing2 = var.zhenMoBg:getWidgetByName("btn_back")
	local btnLing3 = var.zhenMoBg:getWidgetByName("btnLingQu2"):setVisible(false)

	local labTime = var.zhenMoBg:getWidgetByName("lbl_time"):setVisible(true)
	local lbl_pk =var.zhenMoBg:getWidgetByName("lbl_pk"):setVisible(true)
	--if labTime:getString()=="" then data.time=10*60*1000 end --处理掉线是不现实倒计时
	if data.time>0 then
		labTime:setString(GameUtilSenior.setTimeFormat((data.time-os.time()-1)*1000,3))
		labTime:stopAllActions()
		labTime:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
			--print(data.time)
			if data.time-os.time()-1 > 0 then
				labTime:setString(GameUtilSenior.setTimeFormat((data.time-os.time()-1)*1000,3))
			else
				labTime:stopAllActions()
				labTime:setVisible(false)
				lbl_pk:setVisible(false)
			end
		end)})))
	end

	local btnLing2 = var.zhenMoBg:getWidgetByName("btn_back"):setVisible(true)
	local title=var.zhenMoBg:getWidgetByName("lbl_title"):setVisible(false)
	if data.title then 
		title:setVisible(true):setString(data.title)
	end
 	local function prsBtnItem2(sender)
		GameSocket:PushLuaTable("npc.shiwang.back_home",GameUtilSenior.encode({actionid ="back"}))
	end
	GUIFocusPoint.addUIPoint(btnLing2 , prsBtnItem2)
end
---------------闯天关
function GUILeftCenter.hideCustomPass()
	local customPass = var.leftCenter:getWidgetByName("customPass"):hide()
	local lbllefttime = customPass:getWidgetByName("bar")
	lbllefttime:stopAllActions()
	var.leftCenter:getWidgetByName("box_maintask"):show()
	GameSocket:dispatchEvent({name = GameMessageCode.EVENT_FRESH_FUBEN,visible = false})
	-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE,visible = true,lock = "unlock"})
	-- GUIMain.hideUIPlayer()
	customPass:stopAllActions():setPosition(cc.p(0,0))
	customPass:getWidgetByName("img_fuben_pass"):hide()
	customPass:getWidgetByName("btnArrow"):setRotation(0)
	customPass:getWidgetByName("bossnamebg"):hide()
end

function GUILeftCenter.updateCustomPass(data)
	var.leftCenter:getWidgetByName("box_maintask"):hide()
	var.leftCenter:getWidgetByName("box_group_operate"):hide()
	var.leftCenter:getWidgetByName("box_group_operate2"):hide()
	var.leftCenter:getWidgetByName("box_group_operate3"):hide()
	local customPass = var.leftCenter:getWidgetByName("customPass"):show()
	customPass:getWidgetByName("img_fuben_pass"):hide()

	local bossnamebg = customPass:getWidgetByName("bossnamebg")
	local btnArrow = customPass:getWidgetByName("btnArrow")
	local function isLayerShow(show)
		if show then
			btnArrow:setRotation(0)
			bossnamebg:setVisible(false)
		else
			btnArrow:setRotation(180)
			bossnamebg:setVisible(true)
		end
	end
	addArrowCallback(customPass,btnArrow,isLayerShow)
	addArrowCallback(customPass,bossnamebg,isLayerShow)
	if not customPass._action and btnArrow:getRotation()==0 then
		customPass:show():setPosition(cc.p(0,0))
		bossnamebg:hide()
		btnArrow:setRotation(0)
	end

	local lbllefttime = customPass:getWidgetByName("bar"):setLabelVisible(false):setFontSize(14)
	if not lbllefttime.richlabel then
		lbllefttime.richlabel = GUIRichLabel.new({name = "lbllefttimelabel",ignoreSize = true})
		lbllefttime.richlabel:addTo(lbllefttime):align(display.CENTER,0,-24)
	end
	--GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE,visible = false,lock = "lock"})
	if data.second then
		if data.countDown then
			lbllefttime.countDown = data.countDown
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_FRESH_FUBEN,imgindex = data.imgindex or 1,visible = true})
		end
		if data.stars then
			lbllefttime.stars = data.stars
		end
		local function setRichString(t)
			if lbllefttime.countDown then
				if t>=lbllefttime.countDown then
					lbllefttime.richlabel:setRichLabel("<font color=#fff843>剩余时间:</font><font color=#30ff00>"..GameUtilSenior.setTimeFormat(t*1000,3).."</font>",14)
				elseif t<lbllefttime.countDown then
					lbllefttime.richlabel:setRichLabel("<font color=#fff843>剩余时间:</font><font color=#ff3e3e>"..GameUtilSenior.setTimeFormat(t*1000,3).."</font>",14)
					if t<=0 then
						lbllefttime:stopAllActions()
					end
				end
			end
			lbllefttime:setPercent(t,data.second)
			local useSecond = lbllefttime.stars[1]*60 - t
			var.leftCenter:getWidgetByName("star1"):setBrightStyle(useSecond<lbllefttime.stars[1]*60 and 1 or 0 )
			var.leftCenter:getWidgetByName("star2"):setBrightStyle(useSecond<lbllefttime.stars[2]*60 and 1 or 0 )
			var.leftCenter:getWidgetByName("star3"):setBrightStyle(useSecond<lbllefttime.stars[3]*60 and 1 or 0 )
		end
		GameUtilSenior.runCountDown(lbllefttime,data.second,function (target,coundown)
			setRichString(coundown)
		end)

		local barBg = customPass:getWidgetByName("barBg")
		local bwidth = barBg:getContentSize().width
		var.leftCenter:getWidgetByName("star1"):setTouchEnabled(false):setPositionX(bwidth*(1-lbllefttime.stars[1]*60/data.second))
		var.leftCenter:getWidgetByName("star2"):setTouchEnabled(false):setPositionX(bwidth*(1-lbllefttime.stars[2]*60/data.second))
		var.leftCenter:getWidgetByName("star3"):setTouchEnabled(false):setPositionX(bwidth*(1-lbllefttime.stars[3]*60/data.second))
		
	end
	if GameUtilSenior.isBool(data.isBoss) then
		customPass:getWidgetByName("killMonster"):setPositionY(data.isBoss and 227 or 213)
		customPass:getWidgetByName("lblkillmonster"):setPositionY(data.isBoss and 227 or 213)
		customPass:getWidgetByName("lblkillboss"):setVisible(data.isBoss)
		customPass:getWidgetByName("killBoss"):setVisible(data.isBoss)
	end

	if data.mon then
		customPass:getWidgetByName("killMonster"):setString(data.mon)
	end

	if data.bossName and data.bossName ~= "" then
		customPass:getWidgetByName("lblbossname"):setString(data.bossName)
		customPass:getWidgetByName("btnCustomPass"):setTitleText(data.bossName)
	else
		customPass:getWidgetByName("btnCustomPass"):setTitleText("")		
	end	
	if data.boss then
		customPass:getWidgetByName("killBoss"):setString(data.boss)
	end
	if data.icon1 then
		GUIItem.getItem({
			parent = customPass:getWidgetByName("icon1"),
			typeId = data.icon1,
			num = data.num1
		})
	end
	if data.icon2 then
		GUIItem.getItem({
			parent = customPass:getWidgetByName("icon2"),
			typeId = data.icon2,
			num = data.num2
		})
	end
	local btn_operate = customPass:getWidgetByName("btn_operate")
	if data.monTotal then
	 	btn_operate:setTitleText(data.monTotal>0 and "退出" or "领取退出")
	 	if data.monTotal == 0 then
			lbllefttime:stopAllActions()
			customPass:getWidgetByName("img_fuben_pass"):show()
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_FRESH_FUBEN,second = 30,visible = true})
		end
	else
		btn_operate:setTitleText("退出")
	end
	if not btn_operate._clickEvent then
		btn_operate._clickEvent = true
		btn_operate:addClickEventListener(function (sender)
			GameSocket:PushLuaTable("gui.ContainerBarrier.onPanelData",GameUtilSenior.encode({actionid = "exitMap"}))
		end)
	end
end

function GUILeftCenter.updateJYGLayer(data)
	local activityLayer = var.leftCenter:getWidgetByName("activityLayer")
	local lbllefttime = activityLayer:getWidgetByName("lbllefttime")
	local btnArrow = activityLayer:getWidgetByName("btnArrow")
	local verticalBar = activityLayer:getWidgetByName("verticalBar"):hide()
	local jygLayer = activityLayer:getWidgetByName("jygLayer"):show()
	local expLayer = activityLayer:getWidgetByName("expLayer"):hide()
	local jyg9Layer = activityLayer:getWidgetByName("jyg9Layer"):hide()
	if data.close then
		activityLayer:hide():stopAllActions():setPosition(cc.p(0,0))
		lbllefttime:stopAllActions()
		var.leftCenter:getWidgetByName("box_maintask"):show()
		-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE,visible = true,lock = "unlock"})
		btnArrow:setRotation(0)
		return
	end
	if not activityLayer._action and btnArrow:getRotation()==0 then
		activityLayer:show():setPosition(cc.p(0,0))
		verticalBar:setVisible(false)
	end
	-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE,visible = false,lock = "lock"})
	var.leftCenter:getWidgetByName("box_maintask"):hide()
	var.leftCenter:getWidgetByName("box_group_operate"):hide()
	var.leftCenter:getWidgetByName("box_group_operate2"):hide()
	var.leftCenter:getWidgetByName("box_group_operate3"):hide()
	if not lbllefttime.richLabel then
		lbllefttime.richLabel = GUIRichLabel.new({name = "lbllefttimelabel",ignoreSize = true})
		lbllefttime.richLabel:addTo(lbllefttime):align(display.CENTER,lbllefttime:getContentSize().width/2,10)
	end
	local richtext
	if data.second then
		GameUtilSenior.runCountDown(lbllefttime,data.second,function (target,coundown)
			if coundown>=5*60 then
				richtext = "<font color=#fff843>剩余时间:</font><font color=#30ff00>"..GameUtilSenior.setTimeFormat(coundown*1000,3).."</font>";
			else
				richtext = "<font color=#fff843>剩余时间:</font><font color=#ff3e3e>"..GameUtilSenior.setTimeFormat(coundown*1000,3).."</font>";
			end
			lbllefttime.richLabel:setRichLabel(richtext,14)
		end)
	end
	if data.awards then
		for i=1,2 do
			GUIItem.getItem({
				parent = jygLayer:getWidgetByName("icon"..i):show(),
				typeId = data.awards[i].id,
				num = 1
			})
		end
	else
		for i=1,2 do
			jygLayer:getWidgetByName("icon"..i):hide()
		end
		jygLayer:getWidgetByName("lblactivity"):hide()
	end
	if data.title then
		activityLayer:getWidgetByName("btnTitle"):setTitleText(data.title)
		activityLayer:getWidgetByName("activityname"):setString(data.title)
	end

	local function isLayerShow(show)
		btnArrow:setRotation(show and 0 or 180)
		verticalBar:setVisible(not show)
	end
	addArrowCallback(activityLayer,btnArrow,isLayerShow)
	addArrowCallback(activityLayer,verticalBar,isLayerShow)
	if data.btnAction then
		activityLayer:getWidgetByName("btn_operate"):addClickEventListener(function(sender)
			GameSocket:PushLuaTable(data.btnAction,GameUtilSenior.encode({actionid = "exitMap"}))
		end)
	end
	if data.lblinfo then
		jygLayer:getWidgetByName("lbljyginfo"):setString(data.lblinfo)
	end
	if GameUtilSenior.isTable(data.chartTable) then
		jygLayer:hide();jyg9Layer:show()
		jyg9Layer:getWidgetByName("mychart"):setString(data.chart)
		jyg9Layer:getWidgetByName("chartList"):show():reloadData(#data.chartTable, function(subItem)
			subItem:getWidgetByName("playerchart"):setString(subItem.tag)
			subItem:getWidgetByName("playername"):setString(data.chartTable[subItem.tag])
		end, 0, false)
	end
end

function GUILeftCenter.updateTJCFLayer(data)
	local activityLayer = var.leftCenter:getWidgetByName("activityLayer"):show():setPosition(cc.p(0,0))
	local lbllefttime = activityLayer:getWidgetByName("lbllefttime")
	local expLayer = activityLayer:getWidgetByName("expLayer"):show()
	local verticalBar = activityLayer:getWidgetByName("verticalBar"):hide()
	local btnArrow = activityLayer:getWidgetByName("btnArrow")
	local jygLayer = activityLayer:getWidgetByName("jygLayer"):hide()
	local jyg9Layer = activityLayer:getWidgetByName("jyg9Layer"):hide()
	local awardList = activityLayer:getWidgetByName("awardList")

	if data.close then
		activityLayer:hide()
		lbllefttime:stopAllActions()
		var.leftCenter:getWidgetByName("box_maintask"):show()
		-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE,visible = true,lock = "unlock"})
		return
	end
	if not activityLayer._action and btnArrow:getRotation()==0 then
		activityLayer:show():setPosition(cc.p(0,0))
		verticalBar:setVisible(false)
	end
	-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE,visible = false,lock = "lock"})
	var.leftCenter:getWidgetByName("box_maintask"):hide()
	var.leftCenter:getWidgetByName("box_group_operate"):hide()
	var.leftCenter:getWidgetByName("box_group_operate2"):hide()
	var.leftCenter:getWidgetByName("box_group_operate3"):hide()
	if data.second then
		if not lbllefttime.richLabel then
			lbllefttime.richLabel = GUIRichLabel.new({name = "lbllefttimelabel",ignoreSize = true})
			lbllefttime.richLabel:addTo(lbllefttime):align(display.CENTER,lbllefttime:getContentSize().width/2,10)
		end
		GameUtilSenior.runCountDown(lbllefttime,data.second,function (target,second)
			local richtext
			if second>=5*60 then
				richtext = "<font color=#fff843 size=14>剩余时间:</font><font color=#30ff00 size=14>"..GameUtilSenior.setTimeFormat(second*1000,3).."</font>";
			else
				richtext = "<font color=#fff843 size=14>剩余时间:</font><font color=#ff3e3e size=14>"..GameUtilSenior.setTimeFormat(second*1000,3).."</font>";
			end
			lbllefttime.richLabel:setRichLabel(richtext,14)
			if second<=0 then
				target:stopAllActions()
			end
		end)
	end
	if GameUtilSenior.isTable(data.awardTable) then
		if not GameUtilSenior.isSame(awardList.data, data.awardTable) then
			awardList:reloadData(#data.awardTable, function(subItem)
				local d = data.awardTable[subItem.tag]
				subItem:getWidgetByName("lblexp"):setString(d)
			end, 0, false)
			awardList.data = data.awardTable
		end
	end
	if data.title then
		activityLayer:getWidgetByName("btnTitle"):setTitleText(data.title)
		activityLayer:getWidgetByName("activityname"):setString(data.title)
	end
	local function callBack( visible ) 
		btnArrow:setRotation(visible and 0 or 180) 
		verticalBar:setVisible(not visible) 
	end
	addArrowCallback(activityLayer,btnArrow,callBack)
	addArrowCallback(activityLayer,verticalBar,callBack)
	if data.btnAction then
		activityLayer:getWidgetByName("btn_operate"):addClickEventListener(function(sender)
			GameSocket:PushLuaTable(data.btnAction,GameUtilSenior.encode({actionid = "exitMap"}))
		end)
	end
end

function GUILeftCenter.updateYXLayer(data)
	local yxbiqiLayer  = var.leftCenter:getWidgetByName("yxbiqiLayer")
	local lbllefttime = yxbiqiLayer:getWidgetByName("lbllefttime")
	local btnArrow = yxbiqiLayer:getWidgetByName("btnArrow")
	local yxbiqititle = yxbiqiLayer:getWidgetByName("yxbiqititle")
	if data.close then
		yxbiqiLayer:hide():stopAllActions():setPosition(cc.p(0,0))
		yxbiqititle:setVisible(false)
		btnArrow:setRotation(0)
		var.leftCenter:getWidgetByName("box_maintask"):show()
		-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE,visible = true,lock = "unlock"})
		return
	end
	-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_EXTEND_VISIBLE,visible = false,lock = "lock"})
	var.leftCenter:getWidgetByName("box_maintask"):hide()
	var.leftCenter:getWidgetByName("box_group_operate"):hide()
	var.leftCenter:getWidgetByName("box_group_operate2"):hide()
	var.leftCenter:getWidgetByName("box_group_operate3"):hide()
	if not yxbiqiLayer._action and btnArrow:getRotation()==0 then
		yxbiqiLayer:show():setPosition(cc.p(0,0))
		yxbiqititle:setVisible(false)
		btnArrow:setRotation(0)
	end

	if data.score then
		yxbiqiLayer:getWidgetByName("lblmyscore"):setString(data.score)
	end
	if data.chart then
		yxbiqiLayer:getWidgetByName("lblmychart"):setString(data.chart)
	end
	if data.second then
		GameUtilSenior.runCountDown(lbllefttime,data.second,function ( target,second )
			target:setString(GameUtilSenior.setTimeFormat(second*1000,3))
			if second <=0 then
				target:setString("")
			end
		end)
	end
	if data.btnAction then
		yxbiqiLayer:getWidgetByName("btn_operate"):addClickEventListener(function(sender)
			GameSocket:PushLuaTable(data.btnAction,GameUtilSenior.encode({actionid = "exitMap"}))
		end)
	end
	local function isLayerShow(show)
		btnArrow:setRotation(show and 0 or 180)
		--yxbiqititle:setVisible(not show)
		yxbiqititle:setVisible(false) --不显示夜袭比奇的标题
	end
	addArrowCallback(yxbiqiLayer,btnArrow,isLayerShow)
	addArrowCallback(yxbiqiLayer,yxbiqititle,isLayerShow)
	yxbiqititle:setVisible(false)

	if GameUtilSenior.isTable(data.scoreChart) then
		local chartColor = {0xff3000,0x00ffff,0x30ff00,0xffffff}
		local chartList = yxbiqiLayer:getWidgetByName("chartList")
		chartList:reloadData(#data.scoreChart, function(subItem)
			local tag = subItem.tag
			local d = data.scoreChart[tag]
			local playername = subItem:getWidgetByName("playername"):setString(d.name)
			local playerscore = subItem:getWidgetByName("playerscore"):setString(d.score)
			local playerchart = subItem:getWidgetByName("playerchart"):setString(tag)
			if not chartColor[tag] then tag = #chartColor end
			playername:setColor(GameBaseLogic.getColor(chartColor[tag]))
			playerscore:setColor(GameBaseLogic.getColor(chartColor[tag]))
			playerchart:setColor(GameBaseLogic.getColor(chartColor[tag]))
			subItem:setTouchEnabled(true):addClickEventListener(function( sender )
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS,str="friendOperate", data = d})
			end)
		end,0, false)
	end
end

--打工人第四版本左侧显示普通怪物和福利怪物的倒计时
function GUILeftCenter.setBossNum(mons)
	var.bossgenMons = mons
	if #var.bossgenMons>0 then
		var.leftCenter:getWidgetByName("bossgen_putong_label"):setText("即将召唤:"..var.bossgenMons[1][2])
		if var.bossgenMons[1][2]<0 then
			var.leftCenter:getWidgetByName("bossgen_putong_label"):setText("底层已召唤:"..(-1*var.bossgenMons[1][2]).."个")
		end
	end
	if #var.bossgenMons>1 then
		var.leftCenter:getWidgetByName("bossgen_fuli_label"):setText("即将召唤:"..var.bossgenMons[2][2])
		if var.bossgenMons[2][2]<0 then
			var.leftCenter:getWidgetByName("bossgen_fuli_label"):setText("底层已召唤:"..(-1*var.bossgenMons[2][2]).."个")
		end
	end
end

function GUILeftCenter.showBossGen()
	var.leftCenter:runAction(cca.repeatForever(
		cca.seq({
			cca.cb(function ()
				--print("===========var.bossgenMons",#var.bossgenMons)
				if #var.bossgenMons>0 then
					var.leftCenter:getWidgetByName("bossgen_putong"):show()
				elseif #var.bossgenMons<1 then
					var.leftCenter:getWidgetByName("bossgen_putong"):hide()
				end
				if #var.bossgenMons>1 then
					var.leftCenter:getWidgetByName("bossgen_fuli"):show()
				elseif #var.bossgenMons<2 then
					var.leftCenter:getWidgetByName("bossgen_fuli"):hide()
				end
				if #var.bossgenMons>0 then
					GUILeftCenter.doExtendAnimation(var.leftCenter:getWidgetByName("bossgen_putong"))
				end
				if #var.bossgenMons>1 then
					GUILeftCenter.doExtendAnimation(var.leftCenter:getWidgetByName("bossgen_fuli"))
				end
			end),
			cca.delay(1)
		})
	))
end


function GUILeftCenter.doExtendAnimation(v)

	btnName = v:getName()
	animaSprite = v:getChildByName("animaSprite")
	pSize = v:getContentSize()
	if animaSprite then animaSprite:stopAllActions():hide() end
	if not animaSprite then
		animaSprite = cc.Sprite:create()
			:align(display.CENTER, 0.5 * pSize.width, 0.5 * pSize.height)
			:addTo(v)
			:setName("animaSprite")
	end
	animate = cc.AnimManager:getInstance():getPlistAnimate(4, 60040, 4, 5,false,false,0,function(animate,shouldDownload)
					animaSprite:show():runAction(animate)
					animaSprite:setBlendFunc({src=gl.SRC_ALPHA,dst=gl.ONE})
					if shouldDownload==true then
						animaSprite:release()
						var.boxExtend:release()
						v:release()
					end
				end,
				function(animate)
					animaSprite:retain()
					var.boxExtend:retain()
					v:retain()
				end)

end

return GUILeftCenter