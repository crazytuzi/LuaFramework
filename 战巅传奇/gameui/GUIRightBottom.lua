local GUIRightBottom={}

local var = {}
local m_tile_step = {{0,-1},{1,-1},{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1}}

local skillPos = {
	[GameConst.JOB_ZS] = {
		[1] = GameConst.SKILL_TYPE_YiBanGongJi,
		[2] = GameConst.SKILL_TYPE_BanYueWanDao,
		[3] = GameConst.SKILL_TYPE_YeManChongZhuang,
		[4] = GameConst.SKILL_TYPE_LieHuoJianFa,
		[5] = GameConst.SKILL_TYPE_GongShaJianShu,
	},
	[GameConst.JOB_FS] = {
		[1] = GameConst.SKILL_TYPE_LeiDianShu,
		[2] = GameConst.SKILL_TYPE_BingPaoXiao,
		[3] = GameConst.SKILL_TYPE_HuoQiang,
		[4] = GameConst.SKILL_TYPE_KangJuHuoHuan,
		[5] = GameConst.SKILL_TYPE_MoFaDun,
	},
	[GameConst.JOB_DS] = {
		[1] = GameConst.SKILL_TYPE_LingHunHuoFu,
		[2] = GameConst.SKILL_TYPE_QunTiZhiLiao,
		[3] = GameConst.SKILL_TYPE_JiTiYinShenShu,
		[4] = GameConst.SKILL_TYPE_YouLingDun,
		[5] = GameConst.SKILL_TYPE_ZhaoHuanShenShou,
	}
}
local stateImg = {[100] = "all",[101] = "peace",[102] = "team",[103] = "guild",[104] = "shane",[105] = "camp"}

local function handleSwitchUIMode(event)
	if not var.rightBottom then return end
	local posX, posY
	local btnMainBag = var.rightBottom:getWidgetByName("btn_main_bag")
	if btnMainBag then
		posX, posY = btnMainBag:getPosition()
		if event.mode == GameConst.UI_COMPLETE and posY < 62 then
			btnMainBag:stopAllActions()
			btnMainBag:runAction(cca.moveTo(0.5, posX, 62))
		elseif event.mode == GameConst.UI_SIMPLIFIED and posY > -62 then
			btnMainBag:stopAllActions()
			btnMainBag:runAction(cca.moveTo(0.5, posX, -62))
		end
	end

	local boxBasicFunc = var.rightBottom:getWidgetByName("box_basic_func")
	if boxBasicFunc then
		posX, posY = boxBasicFunc:getPosition()
		if event.mode == GameConst.UI_COMPLETE and posY < 12 then
			boxBasicFunc:stopAllActions()
			boxBasicFunc:runAction(cca.moveTo(0.5, posX, 12))
		elseif event.mode == GameConst.UI_SIMPLIFIED and posY > -112 then
			boxBasicFunc:stopAllActions()
			boxBasicFunc:runAction(cca.moveTo(0.5, posX, -112))
		end
	end
end

function GUIRightBottom.init_ui(rightBottom)
	var = {
			rightBottom,
			sIcon = {},
			mShortCut = {},
			xmlAnDian,

	}
	var.rightBottom = rightBottom:align(display.RIGHT_BOTTOM, display.width, 0)	

	----------模拟技能--------
		
	-- GUIRightBottom.handleSkillChange()
	-- GUIRightBottom.initMasterSkill()	
	-- GUIRightBottom.initSkillIcon()

	-- local mModels = GameSocket.mModels[GameCharacter._mainAvatar:NetAttr(GameConst.net_id)]
	local srcid = GameCharacter._mainAvatar:NetAttr(GameConst.net_id)
	local mountVisible = false
	if GameBaseLogic.MainRoleLevelHigherThen(GameConst.min_mount_open_level) and GameSocket:getPlayerModel(srcid,7)>0 then
		mountVisible = true
	end
	
	GUIFocusPoint.addUIPoint(var.rightBottom:getWidgetByName("btn_main_bag"), function (sender)
		GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "menu_bag"})
	end)
	

	cc.EventProxy.new(GameSocket,rightBottom)
			-- :addEventListener(GameMessageCode.EVENT_BAG_UNFULL, GUIRightBottom.showBagFull)
	-- 		:addEventListener(GameMessageCode.EVENT_SKILL_COOLDOWN, GUIRightBottom.handleSkillCD)
	-- 		:addEventListener(GameMessageCode.EVENT_SKILL_CHANGE, GUIRightBottom.handleNewSkillMaster)
	-- 		:addEventListener(GameMessageCode.EVENT_ITEM_TIME, GUIRightBottom.freshItemTimes)
	-- 		:addEventListener(GameMessageCode.EVENT_ITEM_CHANGE, GUIRightBottom.setButtonVisible)
	-- 		:addEventListener(GameMessageCode.EVENT_NEWFUNC_OPENED, GUIRightBottom.handleNewFuncOpened) ---飞鞋功能开启
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, GUIRightBottom.handlePanelData)
			:addEventListener(GameMessageCode.EVENT_SWITCH_UI_MODE, handleSwitchUIMode)


	var.skill_touch = var.rightBottom:getWidgetByName("skill_touch")
	var.skill_touch_posy = var.skill_touch:getPositionY()
	var.box_props = var.rightBottom:getWidgetByName("box_props")
	var.box_props_posy = var.box_props:getPositionY()
	local boxBasicFunc = var.rightBottom:getWidgetByName("box_basic_func")

	local tipsList = var.rightBottom:getWidgetByName("tipsList")

	GUISkill.init(var.skill_touch)
	GUIFastMenu.init(var.box_props)
	--GUIFunctionList.init(boxBasicFunc)  --可能会出BUG，导致点击快捷回程石弹出行会

	GUIMinTips.init(rightBottom)

	GUIMinTipsManager.init(tipsList)

	-- GUIItemUsage.init(rightBottom)
end

function GUIRightBottom.showBagFull(event)
	local btnMainBag = var.rightBottom:getWidgetByName("btn_main_bag")
	btnMainBag:getWidgetByName("img_bag_full"):setVisible(event.vis or false)
	local redPoint = btnMainBag:getChildByName("redPoint")
	if not redPoint then return end
	redPoint:setVisible(not event.vis)
end

function GUIRightBottom.update()
	if not var.rightBottom then return end
	GUIFastMenu.update()

	if GUIMinTips then GUIMinTips.update() end
	-- local monsters = NetCC:getNearGhost(GameConst.GHOST_MONSTER)
	-- local items = NetCC:getNearGhost(GameConst.GHOST_ITEM)
	-- local players = NetCC:getNearGhost(GameConst.GHOST_PLAYER)
	-- local curState = GameSocket.mAttackMode -- 99
	-- local curStateImg = stateImg[curState]
	-- local targets = {}
	-- if curStateImg == "peace" or curStateImg=="shane" then
	-- 	table.insertto(targets,monsters)
	-- end
	-- table.insertto(targets,players)

	-- local button = var.rightBottom:getWidgetByName("main_auto")
	-- if button then
	-- 	if GameCharacter._autoFight ~= button.on then
	-- 		local stateImg = GameCharacter._autoFight and "btn_auto_on" or "btn_auto"
	-- 		button:loadTextureNormal(stateImg, ccui.TextureResType.plistType)
	-- 		button.on = GameCharacter._autoFight
	-- 	end
	-- end
end

function GUIRightBottom.handleNewFuncOpened(event)
	if not event or event.mType == "rbpart" then
		if not GameSocket.m_func["rbpart"] then return end
		if GameSocket.m_func["rbpart"]["main_fly"] then
			-----------暂停玩家动作-----------
			-- GameCharacter.stopAutoFight()
			-- local  mainAvatar = cc.GhostManager:getInstance():getMainAvatar()
			-- if mainAvatar then mainAvatar:clearAutoMove() end
			
			-- GameSocket:dispatchEvent({name = GameMessageCode.EVENT_SHOW_GUIDE, lv = 2})
		end
	end
end

function GUIRightBottom.handlePanelData(event)
	local data = GameUtilSenior.decode(event.data)
	if event.type=="weiZhiAnDian" then
		GUIRightBottom.updateAndianBoss(data)
	elseif event.type=="hideWeiZhiAnDian" then
		if var.xmlAnDian then var.xmlAnDian:hide() end
	end
	if event and event.type =="showhongbao" then
		local data = GameUtilSenior.decode(event.data)
		local btnhongbao = var.rightBottom:getWidgetByName("btnhongbao")
		
		local openHongbao = function(sender)
			local animSprite = btnhongbao:getChildByName("animSprite")
			if not animSprite then
				animSprite = cc.Sprite:create()
					:align(display.CENTER,btnhongbao:getContentSize().width/2-24,btnhongbao:getContentSize().height/2+2)
					:addTo(btnhongbao):setName("animSprite"):setBlendFunc({src = gl.SRC_ALPHA, dst = gl.ONE})
			end
			animSprite:stopAllActions()
			btnhongbao:setTouchEnabled(false)
			-- local anim = cc.AnimManager:getInstance():getBinAnimate(4,1000100,0,true)
			if anim then
				animSprite:runAction(cca.seq{
					anim,
					cca.cb(function()
						GameSocket:PushLuaTable("npc.hongbao.openHongBao",event.data)
						btnhongbao:hide()
					end),
					cca.removeSelf(),
				})
			end
		end
		if not btnhongbao then
			btnhongbao = ccui.Button:create()
			btnhongbao:setTouchEnabled(true)
			btnhongbao:loadTextures("icon_red_packet","icon_red_packet","",ccui.TextureResType.plistType)
			btnhongbao:addTo(var.rightBottom):align(display.CENTER, -display.cx, display.cy-100):setName("btnhongbao")
		end
		btnhongbao:setVisible(data.visible)
		btnhongbao:setTouchEnabled(true)
		btnhongbao:addClickEventListener(openHongbao)
		btnhongbao:stopAllActions()
		btnhongbao:runAction(cca.repeatForever(cca.seq({
			cca.delay(1),
			cca.moveBy(0.1, 0, 10),
			cca.moveBy(0.05, 0, -5),
			cca.moveBy(0.05, 0, 5),
			cca.moveBy(0.1, 0, -10),
			})))
	end
end


--新传奇的暗殿怪物信息面板
function GUIRightBottom.updateAndianBoss(data)
	if not data then data={} end
	local selectIndex = nil--当前选中条目
	local curItem = nil
	local sortFunc = function(a,b)
		return a.upTime < b.upTime
	end
	table.sort(data, sortFunc)
	if not var.xmlAnDian then 
		var.xmlAnDian=GUIAnalysis.load("ui/layout/GDIVDarkRoomTip.uif")
		var.xmlAnDian:align(display.LEFT_CENTER, -400,330)
					 :addTo(var.rightBottom)
					 :show() 
		var.xmlAnDian:getWidgetByName("imgTitleBg"):setTouchEnabled(true)
		var.xmlAnDian:getWidgetByName("labLink"):setTouchEnabled(true):addClickEventListener(function(sender)
			GameSocket:dispatchEvent({name = GameMessageCode.EVENT_OPEN_PANEL, str = "panel_minimap"})
		end)
		var.xmlAnDian:getWidgetByName("imgBg"):setTouchEnabled(true)
		var.xmlAnDian:getWidgetByName("btnShou"):addClickEventListener(function(sender)
			local listBoss = var.xmlAnDian:getWidgetByName("listBoss")
			if listBoss:isVisible() then
				listBoss:setVisible(false)
				sender:setRotation(90)
				var.xmlAnDian:getWidgetByName("imgBg"):setVisible(false)
			else
				listBoss:setVisible(true)
				sender:setRotation(0)
				var.xmlAnDian:getWidgetByName("imgBg"):setVisible(true)
			end
		end)
		-- var.xmlAnDian:getWidgetByName("nullBg"):setTouchEnabled(true)
	else
		var.xmlAnDian:show()
	end
	local countTime = 0
	local labLink=var.xmlAnDian:getWidgetByName("labLink")
	labLink:stopAllActions()
	labLink:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
		countTime = countTime+1
	end)})))

	local function updateList(item)
		local itemData = data[item.tag]
		if not itemData then return end
		if selectIndex and selectIndex==item.tag then
			item:getWidgetByName("imgSelect"):setVisible(true)
			curItem=item
		else
			item:getWidgetByName("imgSelect"):setVisible(false)
		end
		local function prsBtnClick(item)
			GameSocket:PushLuaTable("mon.bossRefresh.onPanelData",GameUtilSenior.encode({actionid = "reqGotoTarget",index=itemData.index}))
			if curItem then
				curItem:getWidgetByName("imgSelect"):setVisible(false)
			end
			item:getWidgetByName("imgSelect"):setVisible(true)
			curItem = item
			selectIndex=item.tag
		end
		item:setTouchEnabled(true)
		GUIFocusPoint.addUIPoint(item,prsBtnClick)  
		item:getWidgetByName("bossName"):setString(itemData.bossName)
		local labCount = item:getWidgetByName("bossCount")
		-- local line = item:getWidgetByName("unLine")
		-- if not line then
		-- 	line = GameUtilSenior.addUnderLine(labCount, GameBaseLogic.getColor4f(tonumber("4ada13",16)), 1)
		-- 	line:setName("unLine")
		-- end
		labCount:stopAllActions()
		local time = itemData.upTime-countTime
		if time<=0 then
			labCount:setString("可击杀"):setColor(GameBaseLogic.getColor(0x30ff00))
			-- line:setVisible(true)
		else
			labCount:setString(GameUtilSenior.setTimeFormat(time*1000,3).." 后刷新"):setColor(GameBaseLogic.getColor(0xE7BA52))
			labCount:runAction(cca.repeatForever(cca.seq({cca.delay(1), cca.callFunc(function ()
				time = time - 1
				if time > 0 then
					labCount:setString(GameUtilSenior.setTimeFormat(time*1000,3).." 后刷新"):setColor(GameBaseLogic.getColor(0xE7BA52))
					-- line:setVisible(false)
				else
					labCount:stopAllActions()
					labCount:setString("可击杀"):setColor(GameBaseLogic.getColor(0x30ff00))
					print("可击杀",time)
					-- line:setVisible(true)
					-- GameSocket:PushLuaTable("gui.PanelBoss.handlePanelData",GameUtilSenior.encode({actionid = "reqUpdate"}))
				end
			end)})))
		end
	end
	local listBoss = var.xmlAnDian:getWidgetByName("listBoss")
	listBoss:reloadData(#data,updateList):setTouchEnabled(true)

end

function GUIRightBottom.set_Skill_Pos( skill_type )
	local move_y = 65
	--if skill_type=="up" then 
	--	var.skill_touch:setPositionY(var.skill_touch_posy+move_y)
	--	var.box_props:setPositionY(var.box_props_posy+move_y)
	--elseif skill_type == "down" then
	--	var.skill_touch:setPositionY(var.skill_touch_posy)
	--	var.box_props:setPositionY(var.box_props_posy)
	--end
	var.skill_touch:runAction(cca.seq({
		cca.moveTo(0.2, var.skill_touch:getPositionX(), var.skill_touch:getPositionY()+move_y*(skill_type and 1 or -1))
	}))
	var.box_props:runAction(cca.seq({
		cca.moveTo(0.2, var.box_props:getPositionX(), var.box_props:getPositionY()+move_y*(skill_type and 1 or -1))
	}))
end

return GUIRightBottom