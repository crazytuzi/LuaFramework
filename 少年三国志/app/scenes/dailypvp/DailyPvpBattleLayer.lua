local DailyPvpBattleLayer = class ("DailyPvpBattleLayer", UFCCSNormalLayer)
local DailyPvpKnightIcon = require("app.scenes.dailypvp.DailyPvpKnightIcon")
local DailyPvpKnight = require("app.scenes.dailypvp.DailyPvpKnight")
local EffectNode = require "app.common.effects.EffectNode"
require("app.cfg.knight_info")
require("app.cfg.daily_crosspvp_rank_title")

DailyPvpBattleLayer.EFFECT_ZORDER = 20
DailyPvpBattleLayer.HERO_ZORDER = 10
DailyPvpBattleLayer.BASE_ZORDER = 3
DailyPvpBattleLayer.TURN_ZORDER = 50

DailyPvpBattleLayer.HERO_IN = 1
DailyPvpBattleLayer.HERO_SHOW = 2
DailyPvpBattleLayer.HERO_FIGHT = 3
DailyPvpBattleLayer.HERO_OUT = 4

DailyPvpBattleLayer.HERO_TYPE_ATTACK = 1
DailyPvpBattleLayer.HERO_TYPE_WAIT = 2

function DailyPvpBattleLayer.create(...)   
    return DailyPvpBattleLayer.new("ui_layout/dailypvp_FightLayer.json", ...) 
end

--self = 1 , enemy = 2
function DailyPvpBattleLayer:ctor(json,data,msg)
    self.super.ctor(self, json)
    -- dump(data)

    self._msg = msg

    self._members = {{},{}}

    self._iconPanels = {self:getImageViewByName("Image_bottomHeroBg"),self:getImageViewByName("Image_topHeroBg")}
    self._buttons = {self:getButtonByName("Button_bottomDetail"),self:getButtonByName("Button_topDetail")}
    -- Button_jump
    -- Button_help
    self._attrPanels = {}
    self._attrPanelShow = {true,true}

    self._heros = {{},{}}
    self._heroExists = {false,false}
    self._turnNode = nil

    self._mainPanel = self:getPanelByName("Panel_mid")
    self._bottomPanel = self:getPanelByName("Panel_bottom")
    self._topPanel = self:getPanelByName("Panel_top")

    self._battleData = data
    self.pvpwar_in_eff = {}
    self.pvpwar_wait_eff = {}
    
    self._teamData = {}

    self._win = false
    self._inTeam1 = false
    self:initTeamData()
    self._batttleEnd = false
    -- dump(data)
    self:getButtonByName("Button_jump"):setVisible(self._msg.isReplay)

    self:registerBtnClickEvent("Button_jump", function()
	self:removeAllEffect()
        	self:showEnd()
    end)
    self:registerBtnClickEvent("Button_help", function()
	require("app.scenes.common.CommonHelpLayer").show({
	    {title=G_lang:get("LANG_DAILY_HELP_TITLE1"), content=G_lang:get("LANG_DAILY_HELP_TEXT1")},
	    {title=G_lang:get("LANG_DAILY_HELP_TITLE2"), content=G_lang:get("LANG_DAILY_HELP_TEXT2")},
	    {title=G_lang:get("LANG_DAILY_HELP_TITLE3"), content=G_lang:get("LANG_DAILY_HELP_TEXT3")},
	    {title=G_lang:get("LANG_DAILY_HELP_TITLE4"), content=G_lang:get("LANG_DAILY_HELP_TEXT4")},
	    } )
    end)
    self:registerBtnClickEvent("Button_topDetail", function()
    	self:showAttrPanel(2)
    end)
    self:registerBtnClickEvent("Button_bottomDetail", function()
	self:showAttrPanel(1)
    end)
    self:registerBtnClickEvent("Panel_topClick", function()
    	self:showAttrPanel(2)
    end)
    self:registerBtnClickEvent("Panel_bottomClick", function()
	self:showAttrPanel(1)
    end)
end

function DailyPvpBattleLayer:showAttrPanel(index)
	local rad = {{90,270},{270,90}}
	local button = index == 1 and self:getButtonByName("Button_bottomDetail") or self:getButtonByName("Button_topDetail")
	self._attrPanelShow[index] = not self._attrPanelShow[index]
	-- self._attrPanels[index]:setVisible(self._attrPanelShow[index])
	local scale = self._attrPanelShow[index] and 1 or 0
	local rot = self._attrPanelShow[index] and rad[index][1] or rad[index][2]
	-- button:setRotation(self._attrPanelShow[index] and rad[index][1] or rad[index][2])

	self._attrPanels[index]:runAction(CCScaleTo:create(0.2,scale))
	button:runAction(CCRotateTo:create(0.2, rot))
end

function DailyPvpBattleLayer:removeAllEffect()
	if self.pvpwar_attack_eff then
		self.pvpwar_attack_eff:stop()
		self.pvpwar_attack_eff:removeFromParentAndCleanup(true)
		self.pvpwar_attack_eff = nil
	end
	if self.pvpwar_wait_eff[1] then
		self.pvpwar_wait_eff[1]:stop()
		self.pvpwar_wait_eff[1]:removeFromParentAndCleanup(true)
		self.pvpwar_wait_eff[1] = nil
	end
	if self.pvpwar_wait_eff[2] then
		self.pvpwar_wait_eff[2]:stop()
		self.pvpwar_wait_eff[2]:removeFromParentAndCleanup(true)
		self.pvpwar_wait_eff[2] = nil
	end
	if self.pvpwar_in_eff[1] then
		self.pvpwar_in_eff[1]:stop()
		self.pvpwar_in_eff[1]:removeFromParentAndCleanup(true)
		self.pvpwar_in_eff[1] = nil
	end
	if self.pvpwar_in_eff[2] then
		self.pvpwar_in_eff[2]:stop()
		self.pvpwar_in_eff[2]:removeFromParentAndCleanup(true)
		self.pvpwar_in_eff[2] = nil
	end
end

function DailyPvpBattleLayer:initTeamData()
	local isTeam1 = false
	for k , v in pairs(self._battleData.team1_members) do 
		if v.id == G_Me.userData.id and tostring(v.sid) == tostring(G_PlatformProxy:getLoginServer().id) then
		  	isTeam1 = true
		end
	end
	self._inTeam1 = isTeam1

	if isTeam1 then
		self._teamData = {self._battleData.team1_members,self._battleData.team2_members}
		self._win = self._battleData.team1_win
	else
		self._teamData = {self._battleData.team2_members,self._battleData.team1_members}
		self._win = not self._battleData.team1_win
	end
end

function DailyPvpBattleLayer:onLayerEnter()
    self:initHeroIcons()
    self:initAttrPanels()
    self:initHeros()
    self:initTurns()
    self:initShowNode()
    self:battleStart()

    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_GET_PLAYER_TEAM, self._onRcvPlayerTeam, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_USER_INFO, self._onGetUserInfo, self) 
end

function DailyPvpBattleLayer:adapterLayer()   
	self._topPanel:setPositionXY(0,display.height - 200)
	self._mainPanel:setPositionXY(0,display.height/2 - 200)
	self:getImageViewByName("Image_bg"):setPositionXY(display.width/2,display.height/2)
end

function DailyPvpBattleLayer:initHeroIcons()
	for i = 1 , 2 do
		local data = self._teamData[i]
		for k , v in pairs(data) do 
			local pos = v.sp3 + 1
			local knightInfo = knight_info.get(v.main_role)
			--TODO CLID 还是clop需要改
			local hero = DailyPvpKnightIcon.createKnightIcon(pos,v.main_role,v.dress_id,v.vip,v.name,Colors.qualityColors[knightInfo.quality],
				v.clid,v.cltm,v.clop)
			hero:setBtnName("heroBtn"..i..pos)
			self._members[i][pos] = {}
			self._members[i][pos].hero = hero
			hero.node:setPositionXY((pos-3)*120,10)
			self._iconPanels[i]:addChild(hero.node)

			self:registerWidgetClickEvent("heroBtn"..i..pos, function()
				local info = v
				self._seeHeroData = clone(info)
				self._seeHeroData.id = self:getTrueId(info.id)
				if info.sid == G_PlatformProxy:getLoginServer().id and info.sp2 == 0 then
				    G_HandlersManager.arenaHandler:sendCheckUserInfo(self:getTrueId(info.id))
				elseif info.sid == G_PlatformProxy:getLoginServer().id then
				    G_HandlersManager.arenaHandler:sendCheckUserInfo(self:getTrueId(info.id))
				else
				    G_HandlersManager.crossWarHandler:sendGetPlayerTeam(info.sid, self:getTrueId(info.id))
				end
			end)
		end
	end
end

function DailyPvpBattleLayer:getTrueId(id)
    return id%2^24
end

function DailyPvpBattleLayer:initAttrPanels()
	self:initAttrPanel(self._teamData[1],self._bottomPanel,ccp(320,240),1)
	self:initAttrPanel(self._teamData[2],self._topPanel,ccp(320,-110),2)

	self:getButtonByName("Button_bottomDetail"):setRotation(90)
	self:getButtonByName("Button_topDetail"):setRotation(270)
end

function DailyPvpBattleLayer:initAttrPanel(data,panel,pos,index)
	local dir = index == 1 and 1 or -1
	local bgImg = ImageView:create()
	bgImg:loadTexture("ui/dungeon/fuben_baoxiang_bg.png")
	bgImg:setScale9Enabled(true)
	bgImg:setCapInsets(CCRectMake(31, 32, 1, 1))
	bgImg:setSize(CCSizeMake(590,113))
	bgImg:setAnchorPoint(ccp(0.5,-dir/2+0.5))
	panel:addChild(bgImg,2)
	bgImg:setPositionXY(pos.x,pos.y-70*dir)
	-- bgImg:setVisible(false)
	self._attrPanels[index] = bgImg

	for k , v in pairs(data) do
		local pos = v.sp3+1
		local posx = (pos-3)*120
		local posy = 55*dir
		local knightInfo = knight_info.get(v.main_role)
		-- local nameLabel = GlobalFunc.createGameLabel(v.name, 20, Colors.qualityColors[knightInfo.quality], Colors.strokeBrown)
		-- bgImg:addChild(nameLabel)
		-- nameLabel:setPositionXY(posx,52+posy)
		local fightTitleLabel = GlobalFunc.createGameLabel(G_lang:get("LANG_INFO_FIGHT"), 20, Colors.darkColors.TITLE_01, Colors.strokeBrown)
		bgImg:addChild(fightTitleLabel)
		fightTitleLabel:setPositionXY(posx,37+posy)
		local fightLabel = GlobalFunc.createGameLabel(GlobalFunc.ConvertNumToCharacter4(v.fight_value), 20, Colors.darkColors.DESCRIPTION, Colors.strokeBrown)
		bgImg:addChild(fightLabel)
		fightLabel:setPositionXY(posx,12+posy)
		local levelTitleLabel = GlobalFunc.createGameLabel(G_lang:get("LANG_INFO_LV"), 20, Colors.darkColors.TITLE_01, Colors.strokeBrown)
		bgImg:addChild(levelTitleLabel)
		levelTitleLabel:setPositionXY(posx,-12+posy)
		local levelLabel = GlobalFunc.createGameLabel(v.level, 20, Colors.darkColors.DESCRIPTION, Colors.strokeBrown)
		bgImg:addChild(levelLabel)
		levelLabel:setPositionXY(posx,-37+posy)
	end
end

function DailyPvpBattleLayer:initHeros()
	local hps = self:getTotalHp(self._battleData.reports[1])
	self:initHero(self._teamData[1],self._heros[1],ccp(120,0),hps[1],1)
	self:initHero(self._teamData[2],self._heros[2],ccp(520,150),hps[2],2)
end

function DailyPvpBattleLayer:initHero(data,heroTable,pos,hp,index)
	for k , v in pairs(data) do 
		if v.sp3 == 0 then
			local resId = G_Me.dressData:getDressedResidWithClidAndCltm(v.main_role,v.dress_id,v.clid,v.cltm,v.clop)
			local knightInfo = knight_info.get(v.main_role)
			local titleId = v.sp6
			titleId = (titleId and titleId > 0) and titleId or 7
			local name = v.name.."[" .. string.gsub(v.sname, "^.-%((.-)%)", "%1") .. "]"
			local hero = DailyPvpKnight.createKnight(resId,false,titleId,name,Colors.qualityColors[knightInfo.quality],v.fight_value,v.vip,true,index==2)
			hero:initInFight(hp)
			self._mainPanel:addChild(hero.node,DailyPvpBattleLayer.HERO_ZORDER)
			hero.node:setVisible(false)
			heroTable.hero = hero
			heroTable.basePos = pos
			hero.node:retain()

			-- local baseJson = decodeJsonFile(G_Path.getBattleConfig('base', "base_1"))
			-- local cardBase = CCSpriteLighten:create(G_Path.getBattleConfigImage('base', "base_1.png"))
			local cardBase = CCNode:create()
			baseImg = CCSpriteLighten:create("battle/base/base_1.png")
			cardBase:addChild(baseImg)
			cardBase:setScale(0.7)
			-- cardBase:setPosition(ccp(pos.x+baseJson.x, pos.y+baseJson.y))
			self._mainPanel:addNode(cardBase,DailyPvpBattleLayer.BASE_ZORDER)
			-- cardBase:setPosition(pos)
			cardBase:setVisible(false)
			heroTable.cardBase = cardBase
			heroTable.cardBaseImg = baseImg
		end
	end
end

function DailyPvpBattleLayer:getTotalHp(report)
	local state = report.team1_fight_first and self._inTeam1 or (not report.team1_fight_first and not self._inTeam1)
	local hpList = state and {report.report.own.hp,report.report.enemy.hp} or {report.report.enemy.hp,report.report.own.hp}
	return hpList
end

function DailyPvpBattleLayer:initTurns()
	local turnImg = ImageView:create()
	turnImg:loadTexture("ui/text/txt/jzhlg_huihe.png")
	self._mainPanel:addChild(turnImg,DailyPvpBattleLayer.TURN_ZORDER)
	local basePos = ccp(320,300)
	turnImg:setPosition(basePos)
	turnImg:setCascadeOpacityEnabled(true)
	turnImg:setOpacity(0)
	local turnCount = ImageView:create()
	turnCount:loadTexture("ui/text/txt/jzhlg_huihe1.png")
	turnImg:addChild(turnCount)
	turnCount:setPosition(ccp(-20,0))
	turnCount:setOpacity(0)
	self._turnNode = {}
	self._turnNode.turnImg = turnImg
	self._turnNode.turnCount = turnCount
	self._turnNode.basePos = basePos
end

function DailyPvpBattleLayer:updateTurns(index)
	self._turnNode.turnCount:loadTexture("ui/text/txt/jzhlg_huihe"..index..".png")
end

function DailyPvpBattleLayer:battleStart()
	-- local co = coroutine.create(function ()
	--     for k , v in pairs(self._battleData.reports) do 
	--     	self:knightIn(v)
	--     	self:knightFight(v)
	--     	self:knightOut(v)
	--     end
	-- end)
	-- self._co = co
	-- coroutine.resume(self._co)

	-- for k , v in pairs(self._battleData.reports) do 
	-- 	self:knightIn(v)
	-- end
	-- self:knightIn(self._battleData.reports[1])
	-- self:knightOut(self._battleData.reports[1])
	local seqArr = CCArray:create()
	seqArr:addObject(CCDelayTime:create(0.5))
	seqArr:addObject(CCCallFunc:create(function()
		self:showAttrPanel(1)
		self:showAttrPanel(2)
		self:battlePlay(1,DailyPvpBattleLayer.HERO_IN)
		self._heros[1].hero.node:setVisible(true)
		self._heros[2].hero.node:setVisible(true)
		-- self._heros[1].cardBase:setVisible(true)
		-- self._heros[2].cardBase:setVisible(true)
		
	end))
	self._mainPanel:runAction(CCSequence:create(seqArr))    
	-- self:battlePlay(1,DailyPvpBattleLayer.HERO_FIGHT)
end

function DailyPvpBattleLayer:showEnd()
	self._batttleEnd = true
	local winnerList,winList = self:getMvpHero()
	local name1 = #winnerList>0 and winnerList[1].name or G_lang:get("LANG_WUSH_NO")
	local name2 = #winnerList>1 and winnerList[2].name or ""
	local main_role1 = #winnerList>0 and winnerList[1].base_id or 0
	local main_role2 = #winnerList>1 and winnerList[2].base_id or 0
	local knightInfo1 = knight_info.get(main_role1)
	local knightInfo2 = knight_info.get(main_role2)
	local add = self._inTeam1 and self._battleData.team1_award_buff or self._battleData.team2_award_buff
	local scoreData = G_Me.dailyPvpData:getBaseScore()
	local baseScore = self._win and scoreData.award_win or scoreData.award_failure
	local baseHonor = self._win and 100 or 50
	baseHonor = self._msg.double and baseHonor*2 or baseHonor
	baseScore = self._msg.score > 0 and baseScore or 0
	baseHonor = self._msg.honor > 0 and baseHonor or 0
	local awardCount = G_Me.dailyPvpData:getAwardCountLeft()

	local showFightEnd = function ( )
		local FightEnd = require("app.scenes.common.fightend.FightEnd")
		FightEnd.show(FightEnd.TYPE_DAILY_PVP, self._win,
		    {
		       daily_pvp_mvp = {mvp_name_1 = name1,
		       			mvp_name_2 = name2,
		       			mvp_quality_1 = knightInfo1 and knightInfo1.quality or 1,
		       			mvp_quality_2 = knightInfo2 and knightInfo2.quality or 1,
		       			}, 
		       daily_pvp_score = {baseScore,self._msg.score-baseScore,add,false},
		       daily_pvp_honor = {baseHonor,self._msg.honor-baseHonor,add,self._msg.double},
		       left_time = awardCount,
		     },        
		    function() 
		    	if self._msg.isReplay then
		        		uf_sceneManager:replaceScene(require("app.scenes.dailypvp.DailyPvpMainScene").new())
		        	else
		        		uf_sceneManager:replaceScene(require("app.scenes.dailypvp.DailyPvpTeamScene").new())
		        	end
		    end 
		 )
	end

	local layer = require("app.scenes.dailypvp.DailyPvpBattleSummaryLayer").create(self._teamData,winnerList,winList,self._win,showFightEnd)
	uf_sceneManager:getCurScene():addChild(layer)
end

function DailyPvpBattleLayer:battlePlay(index,step)
	-- print("battlePlay",index,step)
	if self._batttleEnd then
		return
	end
	local goNext = function ( )
		if step == DailyPvpBattleLayer.HERO_OUT then
			self:battlePlay(index+1,DailyPvpBattleLayer.HERO_IN)
		else
			self:battlePlay(index,step+1)
		end
	end

	local data = self._battleData.reports[index]
	if not data then
		self:showEnd()
		return
	end

	if step == DailyPvpBattleLayer.HERO_IN then
		self:knightIn(data,goNext)
	elseif step == DailyPvpBattleLayer.HERO_SHOW then
		self:knightShow(data,index,goNext)
	elseif step == DailyPvpBattleLayer.HERO_FIGHT then
		self:knightFight(data,goNext)
	elseif step == DailyPvpBattleLayer.HERO_OUT then
		self:knightOut(data,goNext)
	end
end

function DailyPvpBattleLayer:knightIn(data,callBack)
	local done = false
	local effectName = {"effect_pvpwar_in_left","effect_pvpwar_in_right"}
	local pos = self._inTeam1 and {data.team1_pos+1,data.team2_pos+1} or {data.team2_pos+1,data.team1_pos+1}
	local getKnightData = function ( index )
		for k , v in pairs(self._teamData[index]) do 
			if v.sp3 + 1 == pos[index] then
				return v
			end
		end
		return nil
	end

	for i = 1 , 2 do
		if not self._heroExists[i] then
			if self.pvpwar_wait_eff[i] then
				self.pvpwar_wait_eff[i]:stop()
				self._mainPanel:removeChild(self.pvpwar_wait_eff[i])
				self.pvpwar_wait_eff[i] = nil 
			end
			local v = getKnightData(i)
			local titleId = v.sp6
			titleId = (titleId and titleId > 0) and titleId or 7
			local resId = G_Me.dressData:getDressedResidWithClidAndCltm(v.main_role,v.dress_id,v.clid,v.cltm,v.clop)
			local knightInfo = knight_info.get(v.main_role)
			self._heros[i].hero:updateKnight(resId,titleId,v.name,Colors.qualityColors[knightInfo.quality],v.fight_value,v.vip,true,i==2)
			self._heros[i].hero:resetHp(self:getTotalHp(data)[i])
			self.pvpwar_in_eff[i] = EffectNode.new(effectName[i],
				function(event, frameIndex)
					if event == "finish" then
						self.pvpwar_in_eff[i]:stop()
		        				self._mainPanel:removeChild(self.pvpwar_in_eff[i])
		        				self.pvpwar_in_eff[i] = nil 
		        				if callBack and not done then 
		        					done = true
		        					callBack()
		        				end
					end
			             end,
		              	nil, nil, 
		                	function (sprite, png, key) 
					if string.find(key, "var_card") == 1 then
						if sprite == nil then
						    local knight = self._heros[i].hero.node
						    self._heros[i].hero:hideDetail()
						    knight:removeFromParentAndCleanup(false)
						    return true, knight
						else
						    return true, sprite     
						end
					end
					-- if string.find(key, "var_base") == 1 then
					-- 	if sprite == nil then
					-- 	    local knight = self._heros[i].cardBase
					-- 	    knight:removeFromParentAndCleanup(false)
					-- 	    return true, knight
					-- 	else
					-- 	    return true, sprite     
					-- 	end
					-- end
				        	return false
			    	end)
			self.pvpwar_in_eff[i]:setPosition(ccp(320, 200))
			self.pvpwar_in_eff[i]:play()
			self._mainPanel:addNode(self.pvpwar_in_eff[i],DailyPvpBattleLayer.EFFECT_ZORDER)

			self._members[i][pos[i]].hero:active()
			self._heros[i].hero:showAll()
			-- self._heros[i].cardBase:setVisible(true)
			self._heroExists[i] = true
		else
			local effectName = {"effect_pvpwar_ready_left","effect_pvpwar_ready_right"}
			if not self.pvpwar_wait_eff[i] then
				self.pvpwar_wait_eff[i] = EffectNode.new(effectName[i],
			              	nil, nil, nil,
			                	function (sprite, png, key) 
						if string.find(key, "var_card") == 1 then
							if sprite == nil then
							    local knight = self._heros[i].hero.node
							    self._heros[i].hero:showDetail()
							    knight:removeFromParentAndCleanup(false)
							    return true, knight
							else
							    return true, sprite     
							end
						end
						-- if string.find(key, "var_base") == 1 then
						-- 	if sprite == nil then
						-- 	    local knight = self._heros[i].cardBase
						-- 	    knight:removeFromParentAndCleanup(false)
						-- 	    return true, knight
						-- 	else
						-- 	    return true, sprite     
						-- 	end
						-- end
					        	return false
				    	end)
				self.pvpwar_wait_eff[i]:setPosition(ccp(320, 200))
				self.pvpwar_wait_eff[i]:play()
				self._mainPanel:addNode(self.pvpwar_wait_eff[i],DailyPvpBattleLayer.EFFECT_ZORDER)
			end
		end
	end
	
	self:showTurn(1)
end

function DailyPvpBattleLayer:initShowNode( )
	self._showNode = {}
	local baseNode = CCNode:create()
	local displayNode = CCLayerColor:create(ccc4(0, 0, 0, 80), display.width, display.height)
            displayNode:ignoreAnchorPointForPosition(false)
            displayNode:setAnchorPoint(ccp(0.5, 0.5))
            baseNode:addChild(displayNode,1)
	self._showNode.baseNode = baseNode
	self._showNode.displayNode = displayNode
	self._showNode.nodeTable = {{},{}}
	local vsImg = ImageView:create()
	vsImg:loadTexture("ui/text/battle/pvp_vs.png")
	vsImg:setPosition(ccp(0,-50))
	baseNode:addChild(vsImg,3)
	self._showNode.vsImg = vsImg
	self:getPanelByName("Panel_main"):addNode(baseNode,10)
	baseNode:setPosition(ccp(display.width/2,display.height/2))
	baseNode:setVisible(false)
	baseNode:setCascadeOpacityEnabled(true)
	for i = 1 , 2 do
		local node = CCNode:create()
		baseNode:addChild(node,2)
		node:setPosition(i == 1 and ccp(-320,-300) or ccp(320,50))
		self._showNode.nodeTable[i].node = node
		local bg = ImageView:create()
		bg:loadTexture(G_Path.getBattleImage(i == 1 and 'pvp_ziji_di.png' or 'pvp_difang_di.png'))
		node:addChild(bg,1)
		bg:setScaleX(-1)
		bg:setPosition(i == 1 and ccp(221,70) or ccp(-224,78))
		self._showNode.nodeTable[i].bg = bg

		local heroBg = ImageView:create()
		heroBg:loadTexture("putong_bg.png",UI_TEX_TYPE_PLIST)
		node:addChild(heroBg,2)
		heroBg:setPosition(i == 1 and ccp(77,72) or ccp(-91,80))
		local heroIcon = ImageView:create()
		heroBg:addChild(heroIcon)
		self._showNode.nodeTable[i].heroBg = heroBg
		self._showNode.nodeTable[i].heroIcon = heroIcon

		local name = GlobalFunc.createGameLabel("", 24, Colors.darkColors.TITLE_01, Colors.strokeBrown)
		node:addChild(name,2)
		name:setAnchorPoint(ccp(i-1,0.5))
		name:setPosition(i == 1 and ccp(138,88) or ccp(-151,92))
		local fight = GlobalFunc.createGameLabel("", 24, Colors.darkColors.TITLE_01, Colors.strokeBrown)
		node:addChild(fight,2)
		fight:setAnchorPoint(ccp(i-1,0.5))
		fight:setPosition(i == 1 and ccp(138,50) or ccp(-151,54))
		self._showNode.nodeTable[i].name = name
		self._showNode.nodeTable[i].fight = fight

		local firstImg = ImageView:create()
		firstImg:loadTexture("ui/text/battle/pvp_xianshou.png")
		node:addChild(firstImg,2)
		firstImg:setPosition(i == 1 and ccp(354,72) or ccp(-369,80))
		self._showNode.nodeTable[i].firstImg = firstImg
	end
end

function DailyPvpBattleLayer:updateShowNode( data )
	local pos = self._inTeam1 and {data.team1_pos+1,data.team2_pos+1} or {data.team2_pos+1,data.team1_pos+1}
	local getKnightData = function ( index )
		for k , v in pairs(self._teamData[index]) do 
			if v.sp3 + 1 == pos[index] then
				return v
			end
		end
		return nil
	end
	for i = 1 , 2 do
		local v = getKnightData(i)
		local knightInfo = knight_info.get(v.main_role)
		self._showNode.nodeTable[i].heroIcon:loadTexture(G_Path.getKnightIcon(G_Me.dressData:getDressedResidWithClidAndCltm(v.main_role,v.dress_id,v.clid,v.cltm,v.clop)))
		self._showNode.nodeTable[i].name:setText(v.name)
		self._showNode.nodeTable[i].name:setColor(Colors.qualityColors[knightInfo.quality])
		self._showNode.nodeTable[i].fight:setText(G_lang:get("LANG_DAILY_ZHANLI")..v.fight_value)
		self._showNode.nodeTable[i].firstImg:setVisible(false)
	end
	self._showNode.vsImg:setVisible(false)
end

function DailyPvpBattleLayer:knightShow(data,index,callBack)
	self:knightWait(data,0)
	-- if callBack then
	-- 	callBack()
	-- end
	local pos = self._inTeam1 and {data.team1_pos+1,data.team2_pos+1} or {data.team2_pos+1,data.team1_pos+1}
	local getKnightData = function ( index )
		for k , v in pairs(self._teamData[index]) do 
			if v.sp3 + 1 == pos[index] then
				return v
			end
		end
		return nil
	end

	local first = getKnightData(1).fight_value >= getKnightData(2).fight_value and 1 or 2
	self:updateShowNode(data)
	self._showNode.baseNode:setVisible(true)
	self._showNode.baseNode:setOpacity(255)
	local seqArr = CCArray:create()
	seqArr:addObject(CCCallFunc:create(function()
	    self._showNode.nodeTable[1].node:setPosition(ccp(-820,-300))
	    self._showNode.nodeTable[2].node:setPosition(ccp(820,50))
	    local action1 = CCSequence:createWithTwoActions(CCMoveTo:create(0.10,ccp(-300,-300)),CCMoveTo:create(0.05,ccp(-320,-300)))
	    self._showNode.nodeTable[1].node:runAction(action1)
	    local action2 = CCSequence:createWithTwoActions(CCMoveTo:create(0.10,ccp(300,50)),CCMoveTo:create(0.05,ccp(320,50)))
	    self._showNode.nodeTable[2].node:runAction(action2)
	end))
	seqArr:addObject(CCDelayTime:create(0.10))
	seqArr:addObject(CCCallFunc:create(function()
	    self._showNode.vsImg:setVisible(true)
	    self._showNode.vsImg:setScale(1.2)
	    self._showNode.vsImg:runAction(CCScaleTo:create(0.05,1))
	end))
	seqArr:addObject(CCDelayTime:create(0.05))
	seqArr:addObject(CCCallFunc:create(function()
	    self._showNode.nodeTable[first].firstImg:setVisible(true)
	    self._showNode.nodeTable[first].firstImg:setScale(3.0)
	    self._showNode.nodeTable[first].firstImg:runAction(CCScaleTo:create(0.1,1))
	end))
	seqArr:addObject(CCDelayTime:create(0.8))
	seqArr:addObject(CCCallFunc:create(function()
		local action1 = CCSequence:createWithTwoActions(CCMoveTo:create(0.05,ccp(-300,-300)),CCMoveTo:create(0.10,ccp(-820,-300)))
		self._showNode.nodeTable[1].node:runAction(action1)
		local action2 = CCSequence:createWithTwoActions(CCMoveTo:create(0.05,ccp(300,50)),CCMoveTo:create(0.10,ccp(820,50)))
		self._showNode.nodeTable[2].node:runAction(action2)
	end))
	seqArr:addObject(CCDelayTime:create(0.05))
	seqArr:addObject(CCCallFunc:create(function()
		self._showNode.vsImg:setVisible(false)
	end))
	seqArr:addObject(CCDelayTime:create(0.10))
	seqArr:addObject(CCCallFunc:create(function()
		self._showNode.baseNode:setVisible(false)
		if callBack then
			callBack()
		end
	end))
	self._showNode.baseNode:runAction(CCSequence:create(seqArr))

end

function DailyPvpBattleLayer:knightFight(data,callBack)
	self:knightFightStep(data,2,DailyPvpBattleLayer.HERO_TYPE_ATTACK,callBack)
	
end

function DailyPvpBattleLayer:getMvpHero()
	local winList = {}
	local winnerList = {}
	local winCount = 0
	for k , v in pairs(self._battleData.reports) do 
		local winner = v.report.is_win and v.report.own or v.report.enemy
		local exist = false
		for k , v in pairs(winList) do 
			if winner.uid == v.data.uid and winner.sid == v.data.sid then
				exist = true
				v.count = v.count + 1
			end
		end
		if not exist then
			table.insert(winList,#winList+1,{data=winner,count=1})
		end
	end
	for k , v in pairs(winList) do 
		if v.count > winCount then
			winCount = v.count
			winnerList = {v.data}
		elseif v.count == winCount then
			table.insert(winnerList,#winnerList+1,v.data)
		end
	end
	if #winnerList >= 3 then
		winnerList = {}
	end
	return winnerList,winList
end

function DailyPvpBattleLayer:knightFightStep(data,step,_type,callBack)
	-- print("knightFightStep",step,_type)
	if self._batttleEnd then
		return
	end
	local state = data.team1_fight_first and self._inTeam1 or (not data.team1_fight_first and not self._inTeam1)
	local hpList = state and {data.report.hp_list,data.report.e_hp_list} or {data.report.e_hp_list,data.report.hp_list}
	local goNext = function ( )
		if _type == DailyPvpBattleLayer.HERO_TYPE_ATTACK then
			if hpList[1][step] and hpList[1][step]>0 and hpList[2][step]>0 and step+1 <= 4 then
				self:knightFightStep(data,step,DailyPvpBattleLayer.HERO_TYPE_WAIT,callBack)
			else
				if callBack then
					callBack()
				end
			end
		elseif _type == DailyPvpBattleLayer.HERO_TYPE_WAIT then
			self:knightFightStep(data,step+1,DailyPvpBattleLayer.HERO_TYPE_ATTACK,callBack)
		end
	end
	if _type == DailyPvpBattleLayer.HERO_TYPE_ATTACK then
		self:knightFightAnime(data,step,goNext)
	elseif _type == DailyPvpBattleLayer.HERO_TYPE_WAIT then
		self:knightWait(data,step,goNext)
	end
end

function DailyPvpBattleLayer:knightFightAnime(data,step,callBack)
	for i = 1 , 2 do 
		if self.pvpwar_wait_eff[i] then
			self.pvpwar_wait_eff[i]:stop()
			self._mainPanel:removeChild(self.pvpwar_wait_eff[i])
			self.pvpwar_wait_eff[i] = nil 
		end
	end

	local state = (data.team1_fight_first and self._inTeam1) or (not data.team1_fight_first and not self._inTeam1)
	local hpList = state and {data.report.hp_list,data.report.e_hp_list} or {data.report.e_hp_list,data.report.hp_list}
	local effectName = "effect_pvpwar_attack"
	-- dump(hpList)
	-- print("step",step)
	if hpList[1][step]>0 and hpList[2][step]>0 and step < 4 then
		effectName = "effect_pvpwar_attack"
	else
		local state = (data.team1_fight_first and self._inTeam1) or (not data.team1_fight_first and not self._inTeam1)
		state = (state and data.report.is_win) or (not state and not data.report.is_win)
		effectName = state and "effect_pvpwar_cont_right" or "effect_pvpwar_cont_left"
	end
	self.pvpwar_attack_eff = EffectNode.new(effectName,
		function(event, frameIndex)
			if event == "finish" then
				for i = 1 , 2 do 
					self._heros[i].hero:changeHpHide()
				end
				self.pvpwar_attack_eff:stop()
        				self._mainPanel:removeChild(self.pvpwar_attack_eff)
        				self.pvpwar_attack_eff = nil
        				if callBack then 
        					callBack()
        				end
			end
			if event == "hurt" then
				for i = 1 , 2 do 
					local hpChange = 0
					local enemyHpChange = 0
					local state = (data.team1_fight_first and self._inTeam1) or (not data.team1_fight_first and not self._inTeam1)
					state = (state and data.report.is_win) or (not state and not data.report.is_win)
					state = (state and i == 1) or (not state and i == 2)
					if step < 4 then
						hpChange = hpList[i][step]-hpList[i][step-1]
						enemyHpChange = hpList[3-i][step]-hpList[3-i][step-1]
					else
						hpChange = state and hpList[i][#hpList[i]]-hpList[i][step-1] or 0-hpList[i][step-1]
						enemyHpChange = state and 0-hpList[3-i][step-1] or hpList[3-i][#hpList[i]]-hpList[3-i][step-1]
					end
					self._heros[i].hero:changeHp(hpChange)
					self._heros[i].hero:showDetail()

					local index = hpChange > enemyHpChange and 1 or 0
					self._heros[i].hero:showFace(index,i)

					self:changeColorAnime(self._heros[i].hero.heroImg)
					self:changeColorAnime(self._heros[i].cardBaseImg)
				end
			end
	             end,
              	nil, nil, 
                	function (sprite, png, key) 
			for i = 1 , 2 do 
				if string.find(key, "var_card"..i) == 1 then
					if sprite == nil then
					    local knight = self._heros[i].hero.node
					    self._heros[i].hero:hideDetail()
					    knight:removeFromParentAndCleanup(false)
					    return true, knight
					else
					    return true, sprite     
					end
				end
				-- if string.find(key, "var_base"..i) == 1 then
				-- 	if sprite == nil then
				-- 	    local knight = self._heros[i].cardBase
				-- 	    knight:removeFromParentAndCleanup(false)
				-- 	    return true, knight
				-- 	else
				-- 	    return true, sprite     
				-- 	end
				-- end
			end
		        	return false
	    	end)
	self.pvpwar_attack_eff:setPosition(ccp(320, 200))
	self.pvpwar_attack_eff:play()
	self._mainPanel:addNode(self.pvpwar_attack_eff,DailyPvpBattleLayer.EFFECT_ZORDER)
	
end

function DailyPvpBattleLayer:knightOut(data,callBack)
	local pos = self._inTeam1 and {data.team1_pos+1,data.team2_pos+1} or {data.team2_pos+1,data.team1_pos+1}
	local state = (data.team1_fight_first and self._inTeam1) or (not data.team1_fight_first and not self._inTeam1)
	state = (state and data.report.is_win) or (not state and not data.report.is_win)
	local die = state and 2 or 1
	local noDie = 3 - die

	self._heroExists[die] = false
	self._members[die][pos[die]].hero:defeated()
	-- self._heros[die].hero:hideAll()
	-- self._heros[die].hero.node:setVisible(false)
	-- self._heros[die].cardBase:setVisible(false)

	if data.continue_win3 then
		local win3 = 3 - die
		self._heroExists[win3] = false
		self._members[win3][pos[win3]].hero:winFull()
		-- self._heros[win3].hero:hideAll()
		-- self._heros[win3].hero.node:setVisible(false)
		-- self._heros[win3].cardBase:setVisible(false)
	end

	local effectName = {"effect_pvpwar_ready_left","effect_pvpwar_ready_right"}
	if not self.pvpwar_wait_eff[noDie] then
		self.pvpwar_wait_eff[noDie] = EffectNode.new(effectName[noDie],
	              	nil, nil, nil,
	                	function (sprite, png, key) 
				if string.find(key, "var_card") == 1 then
					if sprite == nil then
					    local knight = self._heros[noDie].hero.node
					    knight:removeFromParentAndCleanup(false)
					    return true, knight
					else
					    return true, sprite     
					end
				end
				-- if string.find(key, "var_base") == 1 then
				-- 	if sprite == nil then
				-- 	    local knight = self._heros[noDie].cardBase
				-- 	    knight:removeFromParentAndCleanup(false)
				-- 	    return true, knight
				-- 	else
				-- 	    return true, sprite     
				-- 	end
				-- end
			        	return false
		    	end)
		self.pvpwar_wait_eff[noDie]:setPosition(ccp(320, 200))
		self.pvpwar_wait_eff[noDie]:play()
		self._mainPanel:addNode(self.pvpwar_wait_eff[noDie],DailyPvpBattleLayer.EFFECT_ZORDER)
	end

	local getKnightData = function ( index )
		for k , v in pairs(self._teamData[index]) do 
			if v.sp3 + 1 == pos[index] then
				return v
			end
		end
		return nil
	end

	local knight1 = getKnightData(noDie)
	local knight2 = getKnightData(die)
	local name1 = knight1.name
	local name2 = knight2.name
	local knightInfo1 = knight_info.get(knight1.main_role)
	local knightInfo2 = knight_info.get(knight2.main_role)
	local killCount = data.continue_win
	local node = CCNode:create()
	local countLabel = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_WIN"..killCount), 40, Colors.qualityColors[6], Colors.strokeBrown)
	node:addChild(countLabel)
	countLabel:setPositionXY(0,50)
	-- local nameLabel = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_KILL",{name1=name1,name2=name2}), 32, Colors.darkColors.DESCRIPTION, Colors.strokeBrown)
	local nameLabel = GlobalFunc.createGameRichtext(G_lang:get("LANG_DAILY_KILL",{name1=name1,color1=Colors.qualityDecColors[knightInfo1.quality],name2=name2,color2=Colors.qualityDecColors[knightInfo2.quality]}), 30, Colors.darkColors.DESCRIPTION, Colors.strokeBrown)
	node:addChild(nameLabel)
	nameLabel:setPositionXY(0,-30)
	if data.continue_win3 then
		local continueLabel = GlobalFunc.createGameLabel(G_lang:get("LANG_DAILY_BATTLE_WIN_FULL",{name=name1}), 30, Colors.qualityColors[7], Colors.strokeBrown)
		node:addChild(continueLabel)
		continueLabel:setPositionXY(0,-90)
	end
	self._mainPanel:addNode(node,DailyPvpBattleLayer.EFFECT_ZORDER+1)
	node:setPosition(ccp(320, 150))
	node:setScale(0.2)
	self._killNode = node

	local seqArr = CCArray:create()
	seqArr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.2,1.2),CCMoveBy:create(0.2,ccp(0,50))))
	seqArr:addObject(CCDelayTime:create(1.6))
	seqArr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(0.2,0.2),CCMoveBy:create(0.2,ccp(0,50))))
	seqArr:addObject(CCCallFunc:create(function()
	    if callBack then
	    	if self._killNode then
	    		self._killNode:removeFromParentAndCleanup(true)
	    	end
	    	callBack()
	    end
	end))
	node:runAction(CCSequence:create(seqArr))
end


function DailyPvpBattleLayer:knightWait(data,index,callBack)
	local effectName = {"effect_pvpwar_ready_left","effect_pvpwar_ready_right"}
	for i = 1 , 2 do 
		if not self.pvpwar_wait_eff[i] then
			-- print("wait",i)
			self.pvpwar_wait_eff[i] = EffectNode.new(effectName[i],
		              	nil, nil, nil,
		                	function (sprite, png, key) 
					if string.find(key, "var_card") == 1 then
						if sprite == nil then
						    local knight = self._heros[i].hero.node
						    self._heros[i].hero:showDetail()
						    knight:removeFromParentAndCleanup(false)
						    return true, knight
						else
						    return true, sprite     
						end
					end
					-- if string.find(key, "var_base") == 1 then
					-- 	if sprite == nil then
					-- 	    local knight = self._heros[i].cardBase
					-- 	    knight:removeFromParentAndCleanup(false)
					-- 	    return true, knight
					-- 	else
					-- 	    return true, sprite     
					-- 	end
					-- end
				        	return false
			    	end)
			self.pvpwar_wait_eff[i]:setPosition(ccp(320, 200))
			self.pvpwar_wait_eff[i]:play()
			self._mainPanel:addNode(self.pvpwar_wait_eff[i],DailyPvpBattleLayer.EFFECT_ZORDER)
		end
	end

	self:showTurn(index,callBack)
end

function DailyPvpBattleLayer:showTurn( index,callBack )
	if index == 0 then 
		if callBack then
			callBack()
		end
		return
	end
	self:updateTurns(index)
	local time = 0.3
	local seqArr = CCArray:create()
	seqArr:addObject(CCFadeIn:create(time)) 
	seqArr:addObject(CCFadeOut:create(time))
	seqArr:addObject(CCCallFunc:create(function()
	    if callBack then
	    	callBack()
	    end
	end))
	self._turnNode.turnImg:runAction(CCSequence:create(seqArr))
	local seqArr2 = CCArray:create()
	seqArr2:addObject(CCFadeIn:create(time)) 
	seqArr2:addObject(CCFadeOut:create(time))
	self._turnNode.turnCount:runAction(CCSequence:create(seqArr2))
end

function DailyPvpBattleLayer:changeColorAnime(target)
	local seqArr = CCArray:create()
	local red = 0.5
	for i = 1 , 5 do 
		seqArr:addObject(CCCallFunc:create(function()
		    target:setColorOffsetRGBA(red, 0, 0, 1)
		end))
		seqArr:addObject(CCDelayTime:create(0.05))
		seqArr:addObject(CCCallFunc:create(function()
		    target:setColorOffsetRGBA(0, 0, 0, 1)
		end))
		seqArr:addObject(CCDelayTime:create(0.05))
	end
	target:runAction(CCSequence:create(seqArr))
end

function DailyPvpBattleLayer:_onRcvPlayerTeam(data)
    if self._seeHeroData and data.user_id == self._seeHeroData.id and data.sid == self._seeHeroData.sid then
        local user = rawget(data, "user")
        if user ~= nil then
        	user.name = self._seeHeroData.name
            local layer = require("app.scenes.arena.ArenaZhenrong").create(user)
            uf_sceneManager:getCurScene():addChild(layer)
        end
    end
end

function DailyPvpBattleLayer:_onGetUserInfo(data)
	if self._seeHeroData and data.user.id == self._seeHeroData.id then
		data.user.name = self._seeHeroData.name
		local layer = require("app.scenes.arena.ArenaZhenrong").create(data.user)
		uf_notifyLayer:getModelNode():addChild(layer)
	end
end

function DailyPvpBattleLayer:onLayerExit( ... )
    self._heros[1].hero.node:release()
    self._heros[2].hero.node:release()
end

return DailyPvpBattleLayer