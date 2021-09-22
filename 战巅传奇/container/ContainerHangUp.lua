local ContainerHangUp = {}
local var = {}
local resource = {"coin","coin_bind","vcoin","vcoin_bind"}

local lblInfos = {
	--"1.不同地图的主要产出不一样，可以根据需求选择任意挂机地图",
	--"2.经验符效果<font color=#00ff00>不可叠加</font>，重复使用会覆盖上一个的效果",
	--"3.挂机超过<font color=#00ff00>1分钟</font>自动返回登录界面",
	--"4.退出游戏后，离线挂机仍然继续",
	--"5.未使用离线挂机直接离线,则默认上次选中的地图中挂机",
	--"6.离线挂机最多持续<font color=#00ff00>24小时</font>",
	"1.离线挂机可获得以下奖励",
	"2.大量的<font color=#00ff00>人物经验</font>",
	"3.大量的<font color=#00ff00>元宝奖励</font>",
	"4.退出游戏后，离线挂机仍然继续",
	--"5.未使用离线挂机直接离线,则默认上次选中的地图中挂机",
	--"5.离线挂机最多持续<font color=#00ff00>24小时</font>",
}
local function getMultiTimes(itemName)
	local multi = 1
	if string.find(itemName,"双") then
		multi = 2
	elseif string.find(itemName,"三") then
		multi = 3
	elseif string.find(itemName,"四") then
		multi = 4
	end
	return multi
end

function ContainerHangUp.initView( extend )
	var = {
		close = function ( str ) GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL,str = str}) end,
		open = function ( str,tab ) GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = str,tab = tab or 1}) end,
		mapSelect = 1,
		xmlPanel,
		skillsDesp = {},
		mapData = {},
		monNum=0,
		award = {exp = 0,coinbind = 0},
		multiTimes =1,
		state = "",
		multiExpTime = 0,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerHangUp.uif")
	if var.xmlPanel then
		GameUtilSenior.asyncload(var.xmlPanel, "img_panel_bg", "ui/image/img_offline_bg.jpg")

		var.skillsDesp = {}
		for k,v in pairs(GameSocket.m_skillsDesp) do
			if v.mDamageEffect == 2 then
				table.insert(var.skillsDesp, v.mName)
			end
		end
		ContainerHangUp.updateListInfo(lblInfos)

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, ContainerHangUp.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_BUFF_CHANGE, ContainerHangUp.buffChange)

		local btns = {"btn_start","btn_quick_use","btn_quick_get","btn_get_award","btn_stop","btn_back_login"}
		local function clickBtn(sender)
			local name = sender:getName()
			if name == "btn_start" then
				GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "start",params = {}}))

			elseif name =="btn_quick_use" then
				local layerQuickUse = var.xmlPanel:getWidgetByName("layerQuickUse")
				local vis = layerQuickUse:isVisible()
				layerQuickUse:setVisible(not vis)
				if not vis then
					GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "shop",params = {}}))
				end
			elseif name =="btn_quick_get" then
				if GameCharacter._mainAvatar then
					local srcid = GameCharacter._mainAvatar:NetAttr(GameConst.net_id)
					if PLATFORM_BANSHU or GameSocket:getPlayerModel(srcid,5) >0 then
						GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "quickget",params = {}}))
					else
						var.state = "tovip"
						GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL,str = "panel_vip",from = "extend_offline"})
					end
				end
			elseif name =="btn_stop" then
				GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "stop",params = {var.award,var.monNum}}))
			elseif name =="btn_back_login" then
				GameBaseLogic.ExitToRelogin()
			elseif name =="btn_get_award" then
				GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "get",params = {}}))
			end
		end
		for k,v in pairs(btns) do
			local btn = var.xmlPanel:getWidgetByName(v)
			btn:addClickEventListener(clickBtn)
		end
		if PLATFORM_BANSHU then
			var.xmlPanel:getWidgetByName("lblnovipexp"):setString("未领取多倍经验")
		end
		local srcid = GameCharacter._mainAvatar:NetAttr(GameConst.net_id)
		if GameSocket:getPlayerModel(srcid,5) > 0 then
			var.xmlPanel:getWidgetByName("btn_quick_get"):setTitleText("快捷领取")
		else
			var.xmlPanel:getWidgetByName("btn_quick_get"):setTitleText("成为VIP")
		end
		return var.xmlPanel
	end
end
local multiExpBuffType = { 401 }
function ContainerHangUp.buffChange(event,init)
	if GameCharacter._mainAvatar and (event.srcId == GameCharacter.mID or init) then
		local expBuff = {}
		if GameSocket.mNetBuff[GameCharacter.mID] then
			for k,v in pairs(GameSocket.mNetBuff[GameCharacter.mID]) do
				local buffdef = NetCC:getBuffDef(k)
				if table.indexof(multiExpBuffType, buffdef.type) then
					if buffdef then
						v.def = buffdef
						table.insert(expBuff,v)
					end
				end
			end
		end
		if #expBuff>0 then
			local name = expBuff[#expBuff].def.name
			local timeRemain = expBuff[#expBuff].timeRemain
			var.xmlPanel:getWidgetByName("lblexptimes"):show():setString(name)
			ContainerHangUp.lblAction(timeRemain+ expBuff[#expBuff].starttime-os.time())

			var.multiTimes = getMultiTimes(name)
		else
			var.xmlPanel:getWidgetByName("lblexptimes"):hide():setString("")
			ContainerHangUp.lblAction()
			var.multiTimes = 1
		end
	end
end

function ContainerHangUp.onPanelOpen(extend)
	var.xmlPanel:getWidgetByName("layerQuickUse"):hide()
	var.xmlPanel:getWidgetByName("layerStart"):setVisible(true)
	var.xmlPanel:getWidgetByName("layerbc"):setVisible(false)

	var.xmlPanel:getWidgetByName("lblexptimes"):setVisible(false)
	var.xmlPanel:getWidgetByName("lbllefttime"):setVisible(false)
	var.xmlPanel:getWidgetByName("img_unstart"):setVisible(true)
	var.xmlPanel:getWidgetByName("listBattleInfo"):setVisible(false)

	GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "fresh",params = {}}))
	ContainerHangUp.buffChange({},"init")
end

function ContainerHangUp.handlePanelData(event)
	if event.type ~= "ContainerHangUp" then return end
	local data = GameUtilSenior.decode(event.data)
	if data.cmd == "fresh" then
		var.mapSelect = checkint(data.mapSelect)
		if var.mapSelect<1 then data.state = 0 end

		if data.mapData then
			var.mapData = data.mapData
			ContainerHangUp.initMapView()
		end
		var.multiTimes = data.multiTimes or 1
		var.multiExpTime = data.multiExpTime or 0

		if data.lblInfos then
			ContainerHangUp.updateListInfo(lblInfos)
		end
		if data.state == 1 then
			ContainerHangUp.freshPanel("guaji")
			if GameUtilSenior.isTable(data.record) then
				ContainerHangUp.freshPanel("award")
				ContainerHangUp.freshAward(data.record.award,data.record.monNum)
			end
			ContainerHangUp.startOffline()
		else
			if GameUtilSenior.isTable(data.record) then
				ContainerHangUp.freshPanel("award")
				ContainerHangUp.freshAward(data.record.award,data.record.monNum)
			else
				ContainerHangUp.freshPanel("stop")
				ContainerHangUp.freshAward({},0)
			end
		end
		ContainerHangUp.setVipExpLabel(data.vipExpAdd)
	elseif data.cmd == "changeMap" then
		var.mapSelect = data.mapSelect
		ContainerHangUp.initMapView()
	elseif data.cmd == "getTaskInfo" then
		ContainerHangUp.freshTaskInfo(data.config)
	elseif data.cmd == "shop" then
		ContainerHangUp.setQuickBuyList(data.shop)
	elseif data.cmd == "start" then
		var.monNum = 0
		ContainerHangUp.freshPanel("guaji")
		ContainerHangUp.startOffline()
	elseif data.cmd == "close" then
		var.state = "stop"
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "extend_offline"})
	elseif data.cmd == "stop" then
		-- ContainerHangUp.freshPanel("stop")
		for i=1,#var.mapData do
			var.xmlPanel:getWidgetByName("maplist"):cellAtIndex(i-1):getChildByName("_widget"):getWidgetByName("model_map"):getVirtualRenderer():setState(0)
		end
	end
end

function ContainerHangUp.setVipExpLabel(exp)
	exp = 0
	local btn_quick_get = var.xmlPanel:getWidgetByName("btn_quick_get")
	local pSize = btn_quick_get:getContentSize()
	local effectSprite = btn_quick_get:getChildByName("effectSprite")
	if not effectSprite then
		effectSprite = cc.Sprite:create()
			:align(display.CENTER, 0.5 * pSize.width, 0.5 * pSize.height)
			:addTo(btn_quick_get)
			:setScale(1.8,0.7)
			:setName("effectSprite")
	end
	effectSprite:stopAllActions():hide()
	local animate = cc.AnimManager:getInstance():getPlistAnimate(4, 65080, 4, 5,false,false,0,function(animate,shouldDownload)
							local lblnovipexp = var.xmlPanel:getWidgetByName("lblnovipexp")--:show()
							GameCharacter._mainAvatar = GameCharacter._mainAvatar or CCGhostManager:getMainAvatar()
							if GameCharacter._mainAvatar then
								local srcid = GameCharacter._mainAvatar:NetAttr(GameConst.net_id)
								if GameSocket:getPlayerModel(srcid,5) >0 then
									lblnovipexp:setString("VIP经验:"..math.floor(exp))
									if exp>0 then
										effectSprite:show():runAction(cca.repeatForever(animate))
									end
								else
									lblnovipexp:setString("未领取VIP经验")
								end
							end
							if shouldDownload==true then
								var.xmlPanel:release()
								effectSprite:release()
							end
						end,
						function(animate)
							var.xmlPanel:retain()
							effectSprite:retain()
						end)
	
end

function ContainerHangUp.initMapView()
	local data = var.mapData
	if not GameUtilSenior.isTable(data) then return end
	local maplist = var.xmlPanel:getWidgetByName("maplist")
	local function clickChangeMap(sender)
		if sender.tag ~= var.mapSelect then
			GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "changeMap",params = {sender.tag}}))
		end
	end
	maplist:reloadData(#data, function( subItem )
		local d = data[subItem.tag]
		local model_map = subItem:getWidgetByName("model_map")
		subItem:getWidgetByName("mapname"):setString(d.mapname):enableOutline(cc.c3b(3,0,0), 1)
		subItem:getWidgetByName("lbl_openCondition"):setString(d.condition)

		subItem:addClickEventListener(clickChangeMap)
		subItem:setTouchEnabled(true)
		if subItem.tag == var.mapSelect then
			var.xmlPanel:getWidgetByName("lbl_map_name"):setString(d.mapname)
			model_map:loadTexture("img_youcedaojuditiao_ditu", ccui.TextureResType.plistType)
			subItem:getWidgetByName("imgSelect"):setVisible(true)
			ContainerHangUp.freshDropItem( d.dropItem )
		else
			model_map:loadTexture("img_youcedaojuditiao_ditu", ccui.TextureResType.plistType)
			subItem:getWidgetByName("imgSelect"):setVisible(false)
		end
	end, 0, false)
end

function ContainerHangUp.freshDropItem( data )
	for i=1,6 do
		if i<=#data then
			GUIItem.getItem({
				parent = var.xmlPanel:getWidgetByName("icon"..i),
				typeId = data[i].id,
				-- num = data[i].num,
			})
		else
			GUIItem.getItem({
				parent = var.xmlPanel:getWidgetByName("icon"..i)
			})
		end
	end
end

function ContainerHangUp.setQuickBuyList( data )
	local listquick = var.xmlPanel:getWidgetByName("listquick")
	local function clickbuy(sender)
		GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "buy",params = {sender.storeId}}))
	end
	listquick:reloadData(#data, function( subItem )
		local d = data[subItem.tag]
		local model_buy = subItem:getWidgetByName("model_buy")
		model_buy:addClickEventListener(clickbuy)
		model_buy.storeId = d.storeId
		subItem:getWidgetByName("mocelname"):setString(d.name)
		subItem:getWidgetByName("lblvcoin"):setString(d.money)
		GUIItem.getItem({
			parent = subItem:getWidgetByName("icon"),
			typeId = d.id,
			num = d.num,
		})

		local res = resource[d.MoneyKind-99]
		subItem:getWidgetByName("vcoin"):loadTexture(res,ccui.TextureResType.plistType)
	end, 0, false)
end

function ContainerHangUp.updateListInfo(infoTable)
	local listInfo = var.xmlPanel:getWidgetByName("listInfo")
	local strs = {}
	if type(infoTable) == "string" then
		strs = {infoTable}
	elseif type(infoTable) == "table" then
		strs = infoTable
	end
	for i,v in ipairs(strs) do
		local richLabel = GUIRichLabel.new({size = cc.size(listInfo:getContentSize().width-8, 30), space=8,name = "listinfo"..i})
		richLabel:setRichLabel("<font color=#fddfae>"..v.."</font>","",18)
		listInfo:pushBackCustomItem(richLabel)
	end
end

function ContainerHangUp.updateListBattleInfo(infoTable)
	local listBattleInfo = var.xmlPanel:getWidgetByName("listBattleInfo")
	local strs = {}
	if type(infoTable) == "string" then
		strs = {infoTable}
	elseif type(infoTable) == "table" then
		strs = infoTable
	end
	for i,v in ipairs(strs) do
		local richLabel = GUIRichLabel.new({size = cc.size(listBattleInfo:getContentSize().width, 30), space=3,name = "listBattleInfo"..i})
		richLabel:setRichLabel("<font color=#f1e8d0>"..v.."</font>","",20)
		listBattleInfo:pushBackCustomItem(richLabel)
	end
end

function ContainerHangUp.freshPanel(state)
	var.state = state
	if state == "stop" then
		var.xmlPanel:getWidgetByName("layerStart"):setVisible(true)
		var.xmlPanel:getWidgetByName("layerbc"):setVisible(false)
		var.xmlPanel:getWidgetByName("img_unstart"):setVisible(true)
		var.xmlPanel:getWidgetByName("listBattleInfo"):setVisible(false):stopAllActions()
		
		var.xmlPanel:getWidgetByName("btn_stop"):setVisible(false)
		var.xmlPanel:getWidgetByName("btn_back_login"):setVisible(false)
		var.xmlPanel:getWidgetByName("btn_get_award"):setVisible(false)
		var.xmlPanel:getWidgetByName("listInfo"):setVisible(true)

	elseif state == "guaji" then
		var.xmlPanel:getWidgetByName("layerStart"):setVisible(false)
		var.xmlPanel:getWidgetByName("layerbc"):setVisible(false)
		var.xmlPanel:getWidgetByName("img_unstart"):setVisible(false)
		var.xmlPanel:getWidgetByName("listBattleInfo"):setVisible(true)
		
		var.xmlPanel:getWidgetByName("btn_stop"):setVisible(true)
		var.xmlPanel:getWidgetByName("btn_back_login"):setVisible(true)
		var.xmlPanel:getWidgetByName("btn_get_award"):setVisible(false)

		var.xmlPanel:getWidgetByName("btn_stop"):setVisible(true)
		var.xmlPanel:getWidgetByName("btn_back_login"):setVisible(true)
		var.xmlPanel:getWidgetByName("btn_get_award"):setVisible(false)
		var.xmlPanel:getWidgetByName("listInfo"):setVisible(false)
		var.xmlPanel:getWidgetByName("Image_20"):loadTexture("tips_2.png", ccui.TextureResType.plistType)
		
		
		-- var.xmlPanel:getWidgetByName("img_state"):loadTexture("img_offline_going", ccui.TextureResType.plistType)

	elseif state == "award" then
		-- var.xmlPanel:getWidgetByName("img_state"):loadTexture("img_lbl_get_offline_award", ccui.TextureResType.plistType)
		var.xmlPanel:getWidgetByName("layerStart"):setVisible(false)
		var.xmlPanel:getWidgetByName("layerbc"):setVisible(true)
		var.xmlPanel:getWidgetByName("img_unstart"):setVisible(true)
		var.xmlPanel:getWidgetByName("listBattleInfo"):setVisible(false):stopAllActions()

		var.xmlPanel:getWidgetByName("btn_stop"):setVisible(false)
		var.xmlPanel:getWidgetByName("btn_back_login"):setVisible(false)
		var.xmlPanel:getWidgetByName("btn_get_award"):setVisible(true)
		var.xmlPanel:getWidgetByName("listInfo"):setVisible(false)
	end
end

function ContainerHangUp.freshAward(award,monNum)
	var.monNum = monNum or 0
	award = award or {}
	var.xmlPanel:getWidgetByName("lbl_kill_mon"):setString(monNum or "")
	local newaward = {}
	for k,v in pairs(award) do
		if v.num>0 then
			table.insert(newaward,v)
		end
	end
	for i=1,4 do
		GUIItem.getItem({
			parent = var.xmlPanel:getWidgetByName("award"..i),
			typeId = newaward[i] and newaward[i].id or nil,
			num = newaward[i] and newaward[i].num or nil
		})
		if i == 1 and newaward[i] and newaward[i].num then
			ContainerHangUp.setVipExpLabel(0.3*newaward[1].num)
		end
	end
end

function ContainerHangUp.startOffline()
	for i=1,#var.mapData do
		var.xmlPanel:getWidgetByName("maplist"):cellAtIndex(i-1):getChildByName("_widget"):getWidgetByName("model_map"):getVirtualRenderer():setState(1)
	end

	local listBattleInfo = var.xmlPanel:getWidgetByName("listBattleInfo"):stopAllActions():removeAllItems()
	local labels = {
		"你使用<font color=#00ff00>%s</font>对<font color=#00ff00>%s</font>造成<font color=#ff0000>%d</font>点伤害!",
		"你使用<font color=#00ff00>%s</font>对<font color=#00ff00>%s</font>造成<font color=#ff0000>%d</font>点伤害，击败了<font color=#00ff00>%s</font>！",
		"<font color=#00ff00>%s</font>向你攻击，对你造成<font color=#ff0000>%d</font>点伤害。",
		"<font color=#00ff00>%s</font>向你攻击，但被你躲避。",
		"<font color=#00ff00>%s</font>向你挑衅!",
	}
	local getSkill = function () local rand = math.random(1,#var.skillsDesp) return var.skillsDesp[rand] end
	local getRand = function(prob) return math.random(1,10000)<prob and 1 or 0 end
	local monNum = var.monNum
	local curTarget = "self"
	local monName,hp,hurt = nil,0,99
	local award = {
			{id = 40000001, name = "经验", num = 0},
			{id = 40000003, name = "金币", num = 0},
			{id = 23040004, name = "转生经验", num = 0},
			{id = 20011012, name = "武魂值", num = 0},
		}
	if not var.mapData[var.mapSelect] then return end
	local getMonConf = function ()
		local monConfs = var.mapData[var.mapSelect].monConf or {}
		local rand = math.random(1,#monConfs)
		return monConfs[rand]
	end
	local monConf = getMonConf()
	local miss = false
	local newLabel = function()
		local label
		if not monName then
			monConf = getMonConf()
			monName = monConf.monname
			hp = monConf.hp
			if math.random(1,100)>50 then
				label = string.format(labels[5],monName)
			end
			curTarget = "self"
		end
		if label then
			return label
		end
		if curTarget == "self" then
			curTarget = "mon"
			local skill = getSkill()
			hurt = math.random(monConf.hp*0.2,monConf.hp*0.2)
			-- print("hurt---",hp,hurt,var.multiTimes)
			if hp>hurt then
				--人物攻击
				hp = hp - hurt
				label = string.format(labels[1],skill,monName,hurt)
			else
				--怪物死亡
				hurt = hp
				hp = 0;
				label = string.format(labels[2],skill,monName,hurt,monName)
				monName = nil
				monNum = monNum + 1
				award[1].num = award[1].num + monConf.exp * var.multiTimes
				var.award.exp = award[1].num

				--if monConf.coinbind then
				--	award[2].num = award[2].num + monConf.coinbind*getRand(monConf.prob)
				--end
				--if monConf.innerpowerExp then
				--	award[3].num = award[3].num + monConf.innerpowerExp
				--end
				--if monConf.itemid then
				--	award[4].num = award[4].num + getRand(monConf.prob)
				--end
				award[2].num = award[2].num
				award[2].num = award[2].num
				award[2].num = award[2].num

				var.monNum = monNum
				ContainerHangUp.freshAward(award,monNum)

			end
		else
			--怪物攻击
			miss = math.random(1,100)>50
			curTarget = "self"
			if miss then
				--label = string.format(labels[3],monName,math.random(20,60))
				label = string.format(labels[3],monName,math.random(1,1))
			else
				label = string.format(labels[4],monName)
			end
		end
		return label
	end
	listBattleInfo:runAction(cca.repeatForever(cca.seq({
		cca.delay(1),
		cca.cb(function( target )
			local richLabel = GUIRichLabel.new({size = cc.size(listBattleInfo:getContentSize().width-8, 30), space=3})
			richLabel:setRichLabel("<font color=#f1e8d0>"..newLabel().."</font>","",20)
			target:insertCustomItem(richLabel,0)
			if #target:getItems()>10 then
				target:removeItem(10)
			end
			target:jumpToTop()
		end),
	})))
end

function ContainerHangUp.lblAction(time)
	local lbllefttime = var.xmlPanel:getWidgetByName("lbllefttime")
	local lblnoexpchar = var.xmlPanel:getWidgetByName("lblnoexpchar")
	local lblexptimes = var.xmlPanel:getWidgetByName("lblexptimes")
	if time and time>0 then
		lblnoexpchar:hide()
		lbllefttime.time = time
		lbllefttime:show():setString(GameUtilSenior.setTimeFormat(1000*time)):stopAllActions()
		lbllefttime:runAction(cca.rep(cca.seq({
			cca.delay(1),
			cca.cb(function(target)
				if not target.time then
					target.time = time
				end
				target.time = target.time - 1
				target:setString(GameUtilSenior.setTimeFormat(1000*target.time))
				if target.time<=0 then
					target:stopAllActions():hide()
					--lblnoexpchar:show()
					var.multiTimes = 1
				end
			end)
		}),time))
	else
		--lblnoexpchar:show()
		lblexptimes:hide()
		lbllefttime:hide()
		var.multiTimes = 1
	end
end

function ContainerHangUp.checkPanelClose()
	if var.state == "award" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS, str = "alert",btnConfirm = "确定",lblConfirm = "领取奖励并关闭界面",
			confirmCallBack = function ()
				var.state = "stop"
				GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "get",params = {}}))
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "extend_offline"})
			end
		})
		return false
	elseif var.state =="guaji" then
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_TIPS, str = "confirm",btnConfirm = "确定",btnCancel = "取消",
			lblConfirm = "退出后无法获得挂机奖励，确定退出离线挂机吗？",
			confirmCallBack = function ()
				var.state = "stop"
				GameSocket:PushLuaTable("gui.ContainerHangUp.onPanelData",GameUtilSenior.encode({actionid = "stop",params = {}}))
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_CLOSE_PANEL, str = "extend_offline"})
			end
		})
		return false
	else
		return true
	end
end

function ContainerHangUp.onPanelClose()
	-- var.mapData = {}
	-- var.mapSelect = nil
	var.award = {exp = 0,coinbind = 0}
	var.monNum = 0
	var.state = "stop"
	var.xmlPanel:getWidgetByName("listBattleInfo"):stopAllActions()
	var.xmlPanel:getWidgetByName("lbllefttime"):stopAllActions()
end

return ContainerHangUp