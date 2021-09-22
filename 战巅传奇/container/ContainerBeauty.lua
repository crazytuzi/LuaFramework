local ContainerBeauty = {}
local var = {}

local levelNames = {
	"一重天", "二重天", "三重天", "四重天", "五重天", "六重天", "七重天", "八重天", "九重天", "十重天",
	"十一重天", "十二重天", "十三重天", "十四重天", "十五重天", "十六重天", "十七重天", "十八重天", "十九重天", "二十重天",
}

local defendRules = {
	"<font color=#E7BA52 size=18>玩法说明</font>",
	'1．守护女神从第一关开始挑战',
	'2．成功挑战第一关后才能挑战第二关，依次类推',
	'3．守护女神总计有20关',
	'4．通过特定的关数会开启宝石系统的部位',
	'5．首次通关会获得特殊奖励',
	'6．守护女神每日有三次挑战机会',
}

local FIRSTAWARD_STATE = {
	NULL = 0,
	UNCOLLECTED = 1,
	COLLECTED = 2,
}

local CHALLENGE_STATE = {
	PASSED = 0,
	ABLE = 1,
	DISABLE = 2,
}

local defendButtons = {
	"btn_get_first_award", "btn_challenge", "btn_sweep"
}

local openGemUI = {
	"img_defend_flag",
	"img_equip_icon",
	-- "img_gem_part",
}


local function pushTabButton(pSender, touchType,noAsk)
	print('////////////pushTabButton////////////', pSender.tag, noAsk)
	var.m_nCurLevel = pSender.tag
	if var.mPreTab then var.mPreTab:setBrightStyle(ccui.BrightStyle.normal) end
	pSender:setBrightStyle(ccui.BrightStyle.highlight)
	var.mPreTab = pSender

	if not noAsk then
		print("////////////////pushTabButton//////////////", var.m_nCurLevel)
		GameSocket:PushLuaTable("gui.ContainerBeauty.onPanelData",GameUtilSenior.encode({actionid = "updatePanel", level = var.m_nCurLevel}));
	end
end

local function updateFirstAwardState(state)	
	local imgFirstAwardMark = var.xmlPanel:getWidgetByName("img_first_award_mark")
	local btnGetFirstAwars = var.xmlPanel:getWidgetByName("btn_get_first_award")
	if state == FIRSTAWARD_STATE.NULL then
		imgFirstAwardMark:hide()
		btnGetFirstAwars:hide()
	elseif state == FIRSTAWARD_STATE.UNCOLLECTED then
		imgFirstAwardMark:hide()
		-- btnGetFirstAwars:removeChildByName("img_bln");
		GameUtilSenior.addHaloToButton(btnGetFirstAwars, "btn_normal_light3")
		btnGetFirstAwars:show()
	elseif state == FIRSTAWARD_STATE.COLLECTED then
		imgFirstAwardMark:show()
		btnGetFirstAwars:hide()
	end
end

local function updateChallengeState(state)	
	local imgChallengeMark = var.xmlPanel:getWidgetByName("img_challenge_mark")
	local btnChallenge = var.xmlPanel:getWidgetByName("btn_challenge")
	if state == CHALLENGE_STATE.PASSED then
		imgChallengeMark:show()
		btnChallenge:hide()
	elseif state == CHALLENGE_STATE.ABLE then
		imgChallengeMark:hide()
		btnChallenge:show():setBright(true)
	elseif state == CHALLENGE_STATE.DISABLE then
		imgChallengeMark:hide()
		btnChallenge:show():setBright(false)
	end
end


--加载怪物动画
local function showBossAnimation(id)
	-- print("showBossAnimation", id)
	if not id then return end
	var.fireworks = var.fireworks or cc.Sprite:create():addTo(var.xmlPanel):pos(550,315)
	local animate = cc.AnimManager:getInstance():getPlistAnimate(0,id,4,12,false,false,0,function(animate,shouldDownload)
							if animate then
								var.fireworks:stopAllActions()
								var.fireworks:runAction(cca.seq({
									cca.rep(animate,10000),
									cca.removeSelf()
								}))
							end
							if shouldDownload==true then
								var.fireworks:release()
							end
						end,
						function(animate)
							var.fireworks:retain()
						end)
	-- print("animate//////////", animate)
	
end

local function updateOpenGemTips(strTips)
	local imgDefendFlag = var.xmlPanel:getWidgetByName("img_defend_flag")

	local richWidget = imgDefendFlag:getChildByName("openGemTips")
	if not richWidget then
		local param = {
			size = cc.size(80, 50),
			fontSize = 16, 
			space=5,
			name = "openGemTips",
			outline = {0, 0, 0,255, 1},
		}
		richWidget = GUIRichLabel.new(param)
		richWidget:setName("openGemTips")
		imgDefendFlag:addChild(richWidget)
	end
	local pSize = imgDefendFlag:getContentSize()
	richWidget:setRichLabel("<font color=#eec557>"..strTips.."</font>", "", 14)
	richWidget:align(display.TOP_CENTER, 0.5 * pSize.width, 0.65 * pSize.height)

end

--面板刷新
local function updatePanel(data)
	-- print("updatePanel", GameUtilSenior.encode(data))
	local lblBossName = var.xmlPanel:getWidgetByName("lbl_boss_name")
	lblBossName:setString(data.bossName)
	local lblFightRecommend = var.xmlPanel:getWidgetByName("lbl_fight_recommend")
	lblFightRecommend:setString(data.recommendFight)
	local lblTimesRemain = var.xmlPanel:getWidgetByName("lbl_times_remain")
	lblTimesRemain:setString(data.remainTimes)

	local lblTimesDesp = var.xmlPanel:getWidgetByName("lbl_remian_times")
	lblTimesDesp:setString(data.remainDesp)
	--首次通关奖励
	local firstAward = data.firstAward
	local iconFirstAward = var.xmlPanel:getWidgetByName("icon_first_award")
	local param = {
		parent = iconFirstAward,
		typeId = firstAward.id,
		num = firstAward.count,
		-- bind = firstAward.bind,
	}
	GUIItem.getItem(param)

	--本重奖励
	local totalAward --= data.totalAward
	local iconDefendAward
	for i=1,4 do
		totalAward = data.totalAward[i]
		iconDefendAward = var.xmlPanel:getWidgetByName("icon_defend_award"..i)
		if totalAward then
			iconDefendAward:show()
			GUIItem.getItem({parent = iconDefendAward, typeId = totalAward.id, num = totalAward.count})
		else
			-- GUIItem.getItem({parent = iconDefendAward})
			iconDefendAward:hide()
		end
	end
	-- print("updatePanel//////", data.monId)
	showBossAnimation(data.monId)
	updateFirstAwardState(data.firstAwardState)

	updateChallengeState(data.challengeState)

	local btnSweep = var.xmlPanel:getWidgetByName("btn_sweep")
	if data.sweepState == 0 then
		btnSweep:setBright(false)
	elseif data.sweepState == 1 then
		btnSweep:setBright(true)
	end

	
	local visible = false
	if data.openGemTips and data.openGemIcon then
		visible = true
		print("////////////////////////////////", data.openGemTips, data.openGemIcon)
		if data.openGemTips then
			updateOpenGemTips(data.openGemTips)
		end

		if data.openGemIcon then
			var.xmlPanel:getWidgetByName("img_equip_icon"):loadTexture(data.openGemIcon, ccui.TextureResType.plistType)
		end
	end

	for _,name in ipairs(openGemUI) do
		var.xmlPanel:getWidgetByName(name):setVisible(visible)
	end

	if data.level then
		print("///////////////////data.level/////////////////", data.level)
		local listTab = var.xmlPanel:getWidgetByName("list_tab");
		-- print(listTab, listTab.autoMoveToIndex)
		listTab:autoMoveToIndex(data.level);

		if var.m_nCurLevel ~= data.level then
		listTab:runAction(cca.seq({
			cca.delay(0.2),
			cca.cb(function (target)
				local itemMode = target:getModelByIndex(data.level)
				if not itemMode then return end
				local btnTab = itemMode:getChildByName("btn_tab")
				pushTabButton(btnTab, nil,true);
			end)
		}))
		end
	end
end

local function updateTabRedDot(data)
	if data.redDots then
		var.tabRedDots = data.redDots
		local listTab = var.xmlPanel:getWidgetByName("list_tab")
		listTab:updateCellInView()
	end
end

local function handlePanelData(event)
	-- print("handlePanelData", event.type)
	if event.type ~= "ContainerBeauty" then return end
	-- print("//////////ContainerBeauty////////////handlePanelData")
	local data = GameUtilSenior.decode(event.data)
	-- print(event.data)
	if data.cmd == "updatePanel" then
		updatePanel(data)
	elseif data.cmd== "updateTabRedDot" then
		updateTabRedDot(data)
	end
end

--按钮回调
local function pushDefendButton(pSender)
	local name = pSender:getName()
	print("///////////pushDefendButton//////////", name)
	if name == "btn_challenge" then
		GameSocket:PushLuaTable("gui.ContainerBeauty.onPanelData", GameUtilSenior.encode({actionid = "challenge", level = var.m_nCurLevel}))
	elseif name == "btn_sweep" then
		GameSocket:PushLuaTable("gui.ContainerBeauty.onPanelData", GameUtilSenior.encode({actionid = "sweep", level = var.m_nCurLevel}))
	elseif name == "btn_get_first_award" then
		GameSocket:PushLuaTable("gui.ContainerBeauty.onPanelData", GameUtilSenior.encode({actionid = "firstAward", level = var.m_nCurLevel}))
	end
end

local function updateTabItem(item)
	-- print("/////////updateTabItem/////////", item.tag)
	local tag = item.tag
	if not levelNames[tag] then return end
	local btnTab = item:getChildByName("btn_tab")
	if not btnTab then return end
	GUIAnalysis.attachEffect(btnTab,"outline(0e0600,1)")
	btnTab:setTitleText(levelNames[tag])
	btnTab.tag = tag
	GUIFocusPoint.addUIPoint(btnTab, pushTabButton)

	btnTab:setSwallowTouches(false)

	if tag == var.m_nCurLevel then
		btnTab:setBrightStyle(ccui.BrightStyle.highlight)
		var.mPreTab = btnTab
	else
		btnTab:setBrightStyle(ccui.BrightStyle.normal)
	end

	--红点相关
	if var.tabRedDots and table.indexof(var.tabRedDots, tag) then
		GUIFocusDot.addRedPointToTarget(item)
	else
		item:removeChildByName("redPoint")
	end
end

local function initTabButtons()
	local listTab = var.xmlPanel:getWidgetByName("list_tab")
	listTab:reloadData(#levelNames, updateTabItem)
end

function ContainerBeauty.initView()
	var = {
		xmlPanel,
		--当前关卡
		m_nCurLevel,

		mPreTab,
	}
	var.xmlPanel = GUIAnalysis.load("ui/layout/ContainerBeauty.uif")
	if var.xmlPanel then
		GameUtilSenior.asyncload(var.xmlPanel, "img_defend_bg", "ui/image/protect_bg.jpg")

		-- initTabButtons()

		local lblDefendRule = var.xmlPanel:getWidgetByName("lbl_defend_rule"):setTouchEnabled(true)
		lblDefendRule:addTouchEventListener(function (pSender, touchType)
			if touchType == ccui.TouchEventType.began then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "tips", visible = true, infoTable = defendRules,})
			elseif touchType == ccui.TouchEventType.ended or touchType == ccui.TouchEventType.canceled  then
				GameSocket:dispatchEvent({name = GameMessageCode.EVENT_PANEL_ON_ALERT, panel = "all", visible = false })
			end
		end)

		local btnDefend
		for i,v in ipairs(defendButtons) do
			btnDefend = var.xmlPanel:getWidgetByName(v)
			GUIFocusPoint.addUIPoint(btnDefend, pushDefendButton)
			if v == "btn_get_first_award" then
				GameUtilSenior.addHaloToButton(btnDefend, "btn_normal_light3")
			end
		end
		-- GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName("btn_challenge"), pushDefendButton)
		-- GUIFocusPoint.addUIPoint(var.xmlPanel:getWidgetByName("btn_sweep"), pushDefendButton)

		cc.EventProxy.new(GameSocket,var.xmlPanel)
			:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, handlePanelData)
		return var.xmlPanel
	end
end

function ContainerBeauty.onPanelOpen()
	var.m_nCurLevel = 1
	initTabButtons()
	GameSocket:PushLuaTable("gui.ContainerBeauty.onPanelData", GameUtilSenior.encode({actionid = "updatePanel"}))
end

function ContainerBeauty.onPanelClose()
	
end

return ContainerBeauty