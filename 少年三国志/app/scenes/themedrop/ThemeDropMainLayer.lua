
local OneKnightDrop = require("app.scenes.shop.animation.OneKnightDrop")
local EffectNode = require("app.common.effects.EffectNode")
local MoShenConst = require("app.const.MoShenConst")
local ThemeDropConst = require("app.const.ThemeDropConst")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local KnightPic = require("app.scenes.common.KnightPic")
local ThemeDropMainLayer = class("ThemeDropMainLayer", UFCCSNormalLayer)

local FADE_OUT_TIME = 1.5


local function getGroupByCycle(nCycle)
	local nGroup = math.floor(nCycle / 2) + 1
	return nGroup
end

function ThemeDropMainLayer.create(scenePack, ... )
	return ThemeDropMainLayer.new("ui_layout/themedrop_MainLayer.json", nil, scenePack, ...)
end

function ThemeDropMainLayer:ctor(json, param, scenePack, ...)
	self.super.ctor(self, json, param, ...)

	self._scenePack = scenePack
	-- 当前阵营
	self._nCurGroup = MoShenConst.GROUP.WEI
	-- 切换阵营时间戳
	self._nChangeTime = 0
	-- 本日阵营将
	self._tDropKnightList = {}
	-- 主题将
	self._tThemeKnightList = {}
	-- 当前主题将索引
	self._nThemeKnightIndex = 1
	-- 是否改变显示的主题将
	self._isChangeThemeKnight = true
	-- 10连抽掉落武将碎片列表
	self._tTenFragmentList = {}
	-- 一次占星前的星运值
	self._nPreStarValue = 0

	self:_init()

	-- 屏蔽层
	self._panelShield = self:getPanelByName("Panel_Shield")
--	self._panelShield:setTouchEnabled(false)
	self._panelShield:setSize(self:getContentSize())
	self._panelShield:setVisible(false)

	self._labelTime = self:getLabelByName("Label_LeftTimeValue")
	self._labelTime:createStroke(Colors.strokeBrown, 1)
	self._labelTime:setText("")
end

function ThemeDropMainLayer:onLayerEnter( ... )
	self:adapterWidgetHeight("Panel_Knight", "Panel_Bottom", "", 2000, 0)

	-- 成功进入了主界面
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_THEME_DROP_ENTER_MAIN_LAYER, self._updateLayer, self)
	-- 占星成功（免费，1次，10次）
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_THEME_DROP_ASTROLOGY_SUCC, self._onAstrologySucc, self)
	-- 领取红将成功
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_THEME_CLAIM_RED_KNIGHT_SUCC, self._onClaimRedKnightSucc, self)

	-- 发送协议
	G_HandlersManager.themeDropHandler:sendThemeDropZY()
end

function ThemeDropMainLayer:onLayerExit( ... )
	-- 切换抽将的阵营
	if self._tChangeGroupTimer then
		G_GlobalFunc.removeTimer(self._tChangeGroupTimer)
		self._tChangeGroupTimer = nil
	end
	-- 切换2个主题将
	if self._tChangeThemeTimer then
		G_GlobalFunc.removeTimer(self._tChangeThemeTimer)
		self._tChangeThemeTimer = nil
	end
	-- 10连抽动画控制
	if self._tTenAstrologyTimer then
		G_GlobalFunc.removeTimer(self._tTenAstrologyTimer)
		self._tTenAstrologyTimer = nil
	end

	-- 主题将
	if self._imgThemeKnight1 then
		self._imgThemeKnight1:removeFromParentAndCleanup(true)
	end
	if self._imgThemeKnight2 then
		self._imgThemeKnight2:removeFromParentAndCleanup(true)
	end

	G_flyAttribute._clearFlyAttributes()
end

function ThemeDropMainLayer:_init()
	self:getLabelByName("Label_Star"):setText("")
	self:getLabelByName("Label_StarValue"):setText("")
	self:getLoadingBarByName("ProgressBar_StarValue"):setPercent(0)

	self:showWidgetByName("Panel_Once", false)
	self:showWidgetByName("Panel_Ten", false)

	self:getLabelByName("Label_Desc0"):createStroke(Colors.strokeBrown, 1)

	for i=1, 4 do
		self:getLabelByName("Label_Desc"..i):setText("")
	end
	self:getLabelByName("Label_AstrologyDesc"):setText("")
	self:getLabelByName("Label_AstrologyTime"):setText("")

	self:_addSceneEffect()

	self:showWidgetByName("Button_Help", false)
	-- 帮助
	self:registerBtnClickEvent("Button_Help", function()
		require("app.scenes.common.CommonHelpLayer").show({
			{title=G_lang:get("LANG_THEME_DROP_HELP_TITLE1"), content=G_lang:get("LANG_THEME_DROP_HELP_CONTENT1")},
    	})
	end)
	-- 返回
	self:registerBtnClickEvent("Button_Back", function()
		if self._scenePack then
			local scene = G_GlobalFunc.packToScene(self._scenePack)
			uf_sceneManager:replaceScene(scene)
		else
			uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
		end
	end)
end

function ThemeDropMainLayer:_initWidgets()
	-- 阵营
	self:registerBtnClickEvent("Button_Group", function()
		local tLayer = require("app.scenes.themedrop.ThemeDropScheduleLayer").create(self._nCurGroup, self._nChangeTime)
		assert(tLayer)
		if tLayer then
			uf_sceneManager:getCurScene():addChild(tLayer, 1, 1)
		end
	end)
	-- 抽1次
	self:registerBtnClickEvent("Button_Once", function()
		local nOnceCost = G_Me.themeDropData:getOnceAstrologyCost()
		local tInitInfo = G_Me.themeDropData:getInitializeInfo()
		if tInitInfo._nFreeTimes > 0 then
			G_HandlersManager.themeDropHandler:sendThemeDropAstrology(ThemeDropConst.AstrologyType.FREE, tInitInfo._nGroupCycle)
		else
			if tInitInfo._nRemainDropTimes > 0 then
				if G_Me.userData.gold >= nOnceCost then
					G_HandlersManager.themeDropHandler:sendThemeDropAstrology(ThemeDropConst.AstrologyType.ONCE, tInitInfo._nGroupCycle)
				else
					require("app.scenes.shop.GoldNotEnoughDialog").show()
				end
			else
				G_MovingTip:showMovingTip(G_lang:get("LANG_THEME_DROP_EXTRACT_TIME_USEUP"))
			end
		end
	end)
	-- 抽10次
	self:registerBtnClickEvent("Button_Ten", function()
		local nTenCost = G_Me.themeDropData:getTenAstrologyCost()
		local tInitInfo = G_Me.themeDropData:getInitializeInfo()
		if tInitInfo._nRemainDropTimes >= 10 then
			local yesHandler = function()
				if G_Me.userData.gold >= nTenCost then
					G_HandlersManager.themeDropHandler:sendThemeDropAstrology(ThemeDropConst.AstrologyType.TEN, tInitInfo._nGroupCycle)
				else
					require("app.scenes.shop.GoldNotEnoughDialog").show()
				end
			end
			local noHandler = function()
				
			end

			local text = G_lang:get("LANG_THEME_DROP_TEH_ASTROLOGY_TIPS",{money=nTenCost})
			MessageBoxEx.showYesNoMessage(nil, text, nil, yesHandler, noHandler, self, nil)
		else
			if tInitInfo._nRemainDropTimes > 0 then
				G_MovingTip:showMovingTip(G_lang:get("LANG_THEME_DROP_EXTRACT_TIME_NOT_GREATER_TEN"))
			else
				G_MovingTip:showMovingTip(G_lang:get("LANG_THEME_DROP_EXTRACT_TIME_USEUP"))
			end
		end
	end)
	-- 领取红将
	self:registerBtnClickEvent("Button_Claim", function()
		self:_onClickThemeKnight()
	end)

end

function ThemeDropMainLayer:_loadGroupImage(nGroup)
	local texture, texType = G_Path.getKnightGroupIcon(nGroup)
	if texture then
		self:getButtonByName("Button_Group"):loadTextureNormal(texture, texType)
	end
end


function ThemeDropMainLayer:_showGoldCost()
	self:showWidgetByName("Panel_Once", true)
	self:showWidgetByName("Panel_Ten", true)

	local nOnceCost = G_Me.themeDropData:getOnceAstrologyCost()
	local nTenCost = G_Me.themeDropData:getTenAstrologyCost()

	local tInitInfo = G_Me.themeDropData:getInitializeInfo()
	-- 占星一次的按钮
	if tInitInfo._nFreeTimes > 0 then
		CommonFunc._updateLabel(self, "Label_Free", {text=G_lang:get("LANG_THEME_DROP_FREE"), stroke=Colors.strokeBrown, visible = true})
		self:showWidgetByName("Image_GoldCost1", false)
		self:showWidgetByName("Label_GoldCostValue1", false)
	else
		self:showWidgetByName("Label_Free", false)
		self:showWidgetByName("Image_GoldCost1", true)
		self:showWidgetByName("Label_GoldCostValue1", true)
		CommonFunc._updateLabel(self, "Label_GoldCostValue1", {text=nOnceCost, stroke=Colors.strokeBrown})

		local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
            self:getImageViewByName('Image_GoldCost1'),
            self:getLabelByName('Label_GoldCostValue1'),
        }, "C")
        self:getImageViewByName('Image_GoldCost1'):setPositionXY(alignFunc(1))
        self:getLabelByName('Label_GoldCostValue1'):setPositionXY(alignFunc(2))  
	end

	-- 占星10次按钮
	CommonFunc._updateLabel(self, "Label_GoldCostValue2", {text=nTenCost, stroke=Colors.strokeBrown})
	local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getImageViewByName('Image_GoldCost2'),
        self:getLabelByName('Label_GoldCostValue2'),
    }, "C")
    self:getImageViewByName('Image_GoldCost2'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_GoldCostValue2'):setPositionXY(alignFunc(2))  
end

function ThemeDropMainLayer:_initPlateLayer()

    local img = self:getPanelByName("Panel_Circle")
    if img then
        local plate = require("app.scenes.themedrop.ThemeDropTurnPlateLayer").new() 
        plate:getRootWidget():setName("plate")
        plate:init(img:getContentSize(), self._tDropKnightList)
        img:addNode(plate)  
        self._tPlateLayer = plate   
        self._tPlateLayer:setScale(0.8) 
    end
	

--[==[
    --
	--[[
	local tPointList = {
		ccp(0, 0), ccp(0, 320), ccp(200, 320), ccp(218, 220),
		ccp(400, 220), ccp(418, 320), ccp(618, 320), ccp(618, 0), ccp(0, 0),
    }
    ]]


    local tPointList = {
		 ccp(0, 0), ccp(640, 0),ccp(640, 350),ccp(418, 350),  
		 ccp(400, 220), ccp(218, 220),ccp(200, 350), ccp(0, 350),
    }


    --make mask
    local maskNode = CCDrawNode:create()
    local pointarr1 = CCPointArray:create(8)
 	for i=1, #tPointList do
 		pointarr1:add(tPointList[i])
 	end

    maskNode:drawPolygon(pointarr1:fetchPoints(), 8, ccc4f(1.0, 1.0, 0, 0.5), 1, ccc4f(1, 0, 0, 1) )


    self._clippingNode = CCClippingNode:create()
    self._clippingNode:setStencil(maskNode)
    self._clippingNode:setPosition(ccp(0, display.height/4 - 50)) 
    self:addChild(self._clippingNode, 10)

    --[[
    local sp = ImageView:create()
    sp:setScale(2)
    sp:loadTexture("ui/background/back_legionCross.png", UI_TEX_TYPE_LOCAL)
    sp:setPosition(ccp(320, 0))
    self._clippingNode:addChild(sp)
    ]]

    if self._clippingNode then
        local plate = require("app.scenes.themedrop.ThemeDropTurnPlateLayer").new() 
        plate:getRootWidget():setName("plate")
        plate:init(CCSize(618, 320), self._tDropKnightList)
        plate:setPositionXY(8, 50)
        self._clippingNode:addChild(plate)  
        self._tPlateLayer = plate    
    end
]==]

	--[[
	 // test 1
    rectangle[0] = ccp(0, 0);
    rectangle[1] = ccp(s.width, 0);
    rectangle[2] = ccp(s.width, 200);
    rectangle[3] = ccp(150, 200);
    rectangle[4] = ccp(150, s.height);
    rectangle[5] = ccp(0, s.height);
    frame->drawPolygon(rectangle, 6, ccc4f(1, 0.5, 0.5, 0.5), 1, ccc4f(1, 0, 0, 1));
	]]

--[[
	local x = 1 s = CCDirector:sharedDirector():getWinSize()
    local arrayPoint = CCPointArray:create(6)
    arrayPoint:add(ccp(0, 0))
    arrayPoint:add(ccp(s.width, 0))
    arrayPoint:add(ccp(s.width, 200))
    arrayPoint:add(ccp(150, 200))
    arrayPoint:add(ccp(150, s.height))
    arrayPoint:add(ccp(0, s.height))
    local maskNode = CCDrawNode:create()
    maskNode:drawPolygon(arrayPoint:fetchPoints(), 6, ccc4f(1, 0.5, 0.5, 0.5), 1, ccc4f(1, 0, 0, 1))
    self:addChild(maskNode)
]]

end

-- 决定有多少个将参与到抽奖其中，还有主题将是谁
function ThemeDropMainLayer:_selectThemeKnight()
	local nPlayerLevel = G_Me.userData.level

	for i=1, theme_drop_info.getLength() do
		local tTmpl = theme_drop_info.indexOf(i)
		if tTmpl and tTmpl.group_id == self._nCurGroup and tTmpl.level <= nPlayerLevel then
			table.insert(self._tDropKnightList, #self._tDropKnightList + 1, tTmpl)
		end
	end

	-- 主题将
	for key, val in pairs(self._tDropKnightList) do
		local tTmpl = val
		-- 判断有没有红将
		if tTmpl.theme == 2 then
			table.insert(self._tThemeKnightList, #self._tThemeKnightList + 1, tTmpl)
		end
	end
	if table.nums(self._tThemeKnightList) == 0 then
		-- 没有红将做为主题将,2个橙将做为主题将
		for key, val in pairs(self._tDropKnightList) do
			local tTmpl = val
			if tTmpl.theme == 1 then
				table.insert(self._tThemeKnightList, #self._tThemeKnightList + 1, tTmpl)
			end
		end
	end

end

function ThemeDropMainLayer:_themeKinghtAction()
	local tThemeTmpl1 = self._tThemeKnightList[1]
	local tThemeTmpl2 = self._tThemeKnightList[2]
	local nBaseId1 = tThemeTmpl1.id
	local nBaseId2 = tThemeTmpl2.id
	if nBaseId1 ~= 0 and nBaseId2 ~= 0 then
		-- 主题将1
		if not self._imgThemeKnight1 then
			local tKnightTmpl = knight_info.get(nBaseId1)
			if tKnightTmpl then
				assert(self._tPlateLayer ~= nil)
				self._imgThemeKnight1 = KnightPic.createKnightPic(tKnightTmpl.res_id, self._tPlateLayer._knightsLayer, "theme_knight_1", false)
				self._imgThemeKnight1:setPositionX(300)
				self._imgThemeKnight1:setZOrder(-1)
				self._imgThemeKnight1:setCascadeOpacityEnabled(true)
				-- 加名字
				self:_addThemeKnightName(nBaseId1, self._imgThemeKnight1, tKnightTmpl.name, tKnightTmpl.quality)

			end
		end
		-- 主题将2
		if not self._imgThemeKnight2 then
			local tKnightTmpl = knight_info.get(nBaseId2)
			if tKnightTmpl then
				self._imgThemeKnight2 = KnightPic.createKnightButton(tKnightTmpl.res_id, self._tPlateLayer._knightsLayer, "theme_knight_2", false)
				self._imgThemeKnight2:setPositionX(300)
				self._imgThemeKnight2:setZOrder(-1)
				self._imgThemeKnight2:setCascadeOpacityEnabled(true)
				-- 加名字
				self:_addThemeKnightName(nBaseId2, self._imgThemeKnight2, tKnightTmpl.name, tKnightTmpl.quality)
			end
		end
		-- 2个主题将交替显示
		if self._imgThemeKnight1 and self._imgThemeKnight2 then
			self._imgThemeKnight1:setOpacity(0)
			self._imgThemeKnight2:setOpacity(0)

			-- 开启一个切换主题将的timer
			if not self._tChangeThemeTimer then
				self._tChangeThemeTimer = G_GlobalFunc.addTimer(0.1, function()
					self:_twoThemeKnightAction()
				end)
			end
		end
	end
end

-- 切换阵营，做一些清理工作
function ThemeDropMainLayer:_clear()
	-- 本日阵营将
	self._tDropKnightList = {}
	-- 主题将
	self._tThemeKnightList = {}
	-- 当前主题将索引
	self._nThemeKnightIndex = 1
	-- 是否改变显示的主题将
	self._isChangeThemeKnight = true
	-- 10连抽掉落武将碎片列表
	self._tTenFragmentList = {}
	-- 阵营轮转的时间戳
	self._nChangeTime = 0

	if self._tPlateLayer then
		self._tPlateLayer:removeFromParentAndCleanup(true)
		self._tPlateLayer = nil
	end
	if self._imgThemeKnight1 then
		self._imgThemeKnight1:removeFromParentAndCleanup(true)
		self._imgThemeKnight1 = nil
	end
	if self._imgThemeKnight2 then
		self._imgThemeKnight2:removeFromParentAndCleanup(true)
		self._imgThemeKnight2 = nil
	end

	-- 切换抽将的阵营
	if self._tChangeGroupTimer then
		G_GlobalFunc.removeTimer(self._tChangeGroupTimer)
		self._tChangeGroupTimer = nil
	end
	-- 切换2个主题将
	if self._tChangeThemeTimer then
		G_GlobalFunc.removeTimer(self._tChangeThemeTimer)
		self._tChangeThemeTimer = nil
	end
	-- 10连抽动画控制
	if self._tTenAstrologyTimer then
		G_GlobalFunc.removeTimer(self._tTenAstrologyTimer)
		self._tTenAstrologyTimer = nil
	end

end


-- 收到进入界面协议后回调
function ThemeDropMainLayer:_updateLayer()
	self:_clear()

	-- 当前抽将阵营
	local tInitInfo = G_Me.themeDropData:getInitializeInfo()
--	dump(tInitInfo)

	self._nCurGroup = getGroupByCycle(tInitInfo._nGroupCycle)
	if tInitInfo._nGroupCycle % 2 == 0 then
		self._nChangeTime = G_ServerTime:getTime() + G_ServerTime:getCurrentDayLeftSceonds() + 24*60*60 + 2
	else
		self._nChangeTime = G_ServerTime:getTime() + G_ServerTime:getCurrentDayLeftSceonds() + 2
	end

	self:_loadGroupImage(self._nCurGroup)
	self:_initWidgets()
	self:_selectThemeKnight()
	self:_initPlateLayer()
	self:_themeKinghtAction()

	self:_initDesc()
	self:_updateAstrologyTimes()

	self:_showStarValueChanged(G_Me.themeDropData:getStarValue(), false)
	self:_showGoldCost()


	-- 开始下个阵营时间
	if not self._tChangeGroupTimer then
		self._tChangeGroupTimer = G_GlobalFunc.addTimer(1, function()
			local szTime = G_ServerTime:getLeftSecondsString(self._nChangeTime)
			if szTime == "-" or szTime == "24:00:00" then
			--	__Log("发协议，切换阵营")
				G_HandlersManager.themeDropHandler:sendThemeDropZY()
				if szTime == "-" then
					szTime = "00:00:00"
				end
				if self._tChangeGroupTimer then
					G_GlobalFunc.removeTimer(self._tChangeGroupTimer)
					self._tChangeGroupTimer = nil
				end
			end
			self._labelTime:setText(szTime)
		end)
	end

end

-- 占星成功（免费，1次，10次）都在这里处理
function ThemeDropMainLayer:_onAstrologySucc(data)
--	dump(data)

	if data.type == ThemeDropConst.AstrologyType.FREE or data.type == ThemeDropConst.AstrologyType.ONCE then
		-- 抽中的球转到中间
		local tResult = data.result[1]
		if tResult then
			-- 开启屏蔽层
			self._panelShield:setVisible(true)
			local nDir = 1
			local nStep = self._tPlateLayer:calcStep(tResult.knight_id)

			-- 转盘自动旋转
			self._tPlateLayer:autoRotateToCenter(tResult.knight_id, function()
				-- 飞碎片
			--	self:_flyAward(tResult.award)
				-- 飞文字提示
				self:_flyText(10000, tResult.award, tResult.star_value)

				local tKnightTmpl = knight_info.get(tResult.knight_id)
			--	__Log("--------- tKnightTmpl.name = " .. tKnightTmpl.name)

				-- 加特效
				if not self._tEffect then
					self._tEffect = EffectNode.new("effect_xingqiu_e", function(event, frameIndex)
						if event == "a" then
					 		if not self._flowerEffect then
								self._flowerEffect = EffectNode.new("effect_xingqiu_h", function(event, frameIndex)
									if event == "finish" then
								
										-- 转盘恢复点击旋转
									 	self._tPlateLayer:recoverTouch()
									 	self._tPlateLayer:setAutoRotate(false)

									 	-- 播放进度条上的动作
										local nCurStarValue = data.sv_sum
									 	self:_showStarValueChanged(nCurStarValue, true)

									 	-- 关闭屏蔽层
									 	self._panelShield:setVisible(false)
								
										self._flowerEffect:removeFromParentAndCleanup(true)
										self._flowerEffect = nil
									end
								end)

								local panelCircle = self:getImageViewByName("Image_ProgressBar")
								if panelCircle then
									panelCircle:addNode(self._flowerEffect)
									local tSize = panelCircle:getSize()
									self._flowerEffect:play()
									self._flowerEffect:setPositionXY(0, -150)
								end
							end
						elseif event == "finish" then

						 	-- 删除特效自己
						 	self._tEffect:removeFromParentAndCleanup(true)
						 	self._tEffect = nil
						end
					end)
					local tFrontNode = self._tPlateLayer:getFrontNode()
					if tFrontNode then
						local tParent = tFrontNode:getImageViewByName("ImageView_Pedestal")
						if tParent then
						 	local tSize = tParent:getSize()
							tParent:addNode(self._tEffect, 6)
							self._tEffect:setPosition(ccp(tSize.width/2-30, tSize.height/2-10))
							self._tEffect:play()
						end
					end

					-- 球飞向进度条
					local x, y = self:getImageViewByName("Image_ProgressBar"):convertToWorldSpaceXY(0, 0)
					x, y = self._tPlateLayer._knightsLayer:convertToNodeSpaceXY(x, y)
					local node = tFrontNode
					if node:getBaseImageOpacity() ~= 0 then
						local sp = display.newSprite("ui/themedrop/shiujingdi.png", UI_TEX_TYPE_LOCAL)
						if sp then
							self._tPlateLayer._knightsLayer:addChild(sp)
							sp:setZOrder(100)
							sp:setPosition(ccp(node:getPosition()))

							local nTime = 0.8
							local actMoveTo = CCMoveTo:create(nTime, ccp(x, y))
						--	local actSineIn = CCEaseSineIn:create(actMoveTo)
							local actScaleTo = CCScaleTo:create(nTime, 0.2)
							local actSpawn = CCSpawn:createWithTwoActions(actMoveTo, actScaleTo)
							local actCallback = CCCallFunc:create(function()
								if sp then
									sp:removeFromParentAndCleanup(true)
									sp = nil
								end
							end)
				
							sp:runAction(CCSequence:createWithTwoActions(actSpawn, actCallback))
						end
					end
					

				end
			end)
		end
		

	elseif data.type == ThemeDropConst.AstrologyType.TEN then
		-- 将碎片收集起来，看有多少个武将的碎片，每种多少个数量, 用于最后显示所有掉落的碎片
		self._tTenFragmentList = {}
		for i=1, #data.result do
			local tResult = data.result[i]
			self:tidyFranments(tResult.award)
		end
		-- 播放10个动画
		self:_tenAstrologyAction(data)
	end

	-- 更新占星次数
	self:_updateAstrologyTimes()
	-- 
	self:_showGoldCost()
end

-- 领取红将成功
function ThemeDropMainLayer:_onClaimRedKnightSucc(data)
	local function endCallback()
		-- 更新星运值
		self:_showStarValueChanged(G_Me.themeDropData:getStarValue(), false)
	end

	local nKnightBaseId = data.kid
	OneKnightDrop.show(3, nKnightBaseId, endCallback)
end

-- 点击主题将
function ThemeDropMainLayer:_onClickThemeKnight()
	-- 如果星运值满了
	local tInitInfo = G_Me.themeDropData:getInitializeInfo()
	-- 弹出红将2选1窗口
    local CheckFunc = require("app.scenes.common.CheckFunc")
    local scenePack = G_GlobalFunc.sceneToPack("app.scenes.themedrop.ThemeDropMainScene", {})
    if CheckFunc.checkKnightFull(scenePack) == true then
        return
    end

    -- 包装2个主题武将的type, value, size
	local data = {}
	for i=1, #self._tThemeKnightList do
		local tTmpl = self._tThemeKnightList[i]
		if tTmpl then
			data["type_"..i] = 4
			data["value_"..i] = tTmpl.id
			data["size_"..i] = 1
		end
	end

	local function claimRedKnight(nIndex)		
		if tInitInfo._nStarValue < ThemeDropConst.TOTAL_SCHEDULE then
			-- 提示星运值不足
			G_MovingTip:showMovingTip(G_lang:get("LANG_THEME_DROP_STAR_VALUE_NOT_ENOUGH"))
			return
		end

		local tTmpl = self._tThemeKnightList[nIndex]
		if tTmpl then
			local nKnightBaseId = tTmpl.id
			local nGroupCycle = tInitInfo._nGroupCycle
			G_HandlersManager.themeDropHandler:sendThemeDropExtract(nKnightBaseId, nGroupCycle)
		end
	end
	require("app.scenes.sanguozhi.SanguozhiSelectAwardLayer").show(data, claimRedKnight)
end

-- 2个主题将交替出现
function ThemeDropMainLayer:_twoThemeKnightAction( ... )
	if not self._imgThemeKnight1 or not self._imgThemeKnight2 then
		return
	end
	if not self._isChangeThemeKnight then
		return
	end
	self._isChangeThemeKnight = false
	if self._nThemeKnightIndex == 1 then
		-- 第二个主题将出现
		self._imgThemeKnight1:stopAllActions()
		self._imgThemeKnight2:stopAllActions()

		local actAppear = CCFadeIn:create(FADE_OUT_TIME)
		local actDisappert = CCFadeOut:create(FADE_OUT_TIME)
		local actCallback = CCCallFunc:create(function()
			self._nThemeKnightIndex = 2
			self._isChangeThemeKnight = true
		end)
		local tArray = CCArray:create()
		tArray:addObject(actAppear)
		tArray:addObject(CCDelayTime:create(1.5))
		tArray:addObject(actDisappert)
		tArray:addObject(actCallback)
		self._imgThemeKnight1:runAction(CCSequence:create(tArray))
	else
		-- 第一个主题将出现
		self._imgThemeKnight1:stopAllActions()
		self._imgThemeKnight2:stopAllActions()

		local actAppear = CCFadeIn:create(FADE_OUT_TIME)
		local actDisappert = CCFadeOut:create(FADE_OUT_TIME)
		local actCallback = CCCallFunc:create(function()
			self._nThemeKnightIndex = 1
			self._isChangeThemeKnight = true
		end)
		local tArray = CCArray:create()
		tArray:addObject(actAppear)
		tArray:addObject(CCDelayTime:create(1.5))
		tArray:addObject(actDisappert)
		tArray:addObject(actCallback)
		self._imgThemeKnight2:runAction(CCSequence:create(tArray))
	end
end

-- 星运进度条, nStarValue是总的星运值
function ThemeDropMainLayer:_showStarValueChanged(nStarValue, hasAction)
	nStarValue = nStarValue or 0
	hasAction = hasAction or false
	local progressBar = self:getLoadingBarByName("ProgressBar_StarValue")
	if progressBar then
		CommonFunc._updateLabel(self, "Label_Star", {text=G_lang:get("LANG_THEME_DROP_STAR_VALUE"), stroke=Colors.strokeBrown})
		CommonFunc._updateLabel(self, "Label_StarValue", {text=nStarValue.."/1000", stroke=Colors.strokeBrown})
	    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
	        self:getLabelByName('Label_Star'),
	        self:getLabelByName('Label_StarValue'),
	    }, "C")
	    self:getLabelByName('Label_Star'):setPositionXY(alignFunc(1))
	    self:getLabelByName('Label_StarValue'):setPositionXY(alignFunc(2)) 


		if hasAction then
			if nStarValue <= ThemeDropConst.TOTAL_SCHEDULE then
				progressBar:runToPercent(math.floor(nStarValue/10), 0.5)
			else
				progressBar:setPercent(100)
			end
		else
			progressBar:setPercent(math.floor(nStarValue/10))
		end
		if nStarValue >= ThemeDropConst.TOTAL_SCHEDULE then
			-- 添加进度条特效
			if not self._barEffect then
				self._barEffect = EffectNode.new("effect_xingqiu_ing", function(event, frameIndex) end)
	            self:getImageViewByName("Image_ProgressBar"):addNode(self._barEffect, 1)
	            self._barEffect:play()
			end
			-- 领取红将按钮
			self:_updateClaimButton(true)
		else
			-- 删除进度条特效
			if self._barEffect then
				self._barEffect:removeFromParentAndCleanup(true)
				self._barEffect = nil
			end
			-- 领取红将按钮
			self:_updateClaimButton(false)
		end
	end

	self._nPreStarValue = nStarValue
end

-- 将10连抽的武将碎片整理一下
function ThemeDropMainLayer:tidyFranments(tAward)
	if table.nums(self._tTenFragmentList) == 0 then
		table.insert(self._tTenFragmentList, #self._tTenFragmentList+1, tAward)
	else
		local hasSameValue = false
		for key, val in pairs(self._tTenFragmentList) do
			local award = val
			if award.value == tAward.value then
				award.size = award.size + tAward.size
				hasSameValue = true
				break
			end
		end
		if not hasSameValue then
			table.insert(self._tTenFragmentList, #self._tTenFragmentList+1, tAward)
		end
	end
end

function ThemeDropMainLayer:_tenAstrologyAction(data)
	local nDir = math.random(-11, 11)
	if nDir > 0 then
		nDir = 1
	else
		nDir = -1
	end

	local nStep = math.random(6, self._tPlateLayer:getNodeCount()-1)
	self._panelShield:setVisible(true)
	self._tPlateLayer:autoRotateToCenter1(nDir, nStep, function()
		-- 飞星运值
		local nStarValue = 0
		for i=1, #data.result do
			local tResult = data.result[i]
			if tResult then
				nStarValue = nStarValue + tResult.star_value
			--	__Log("-- tResult.star_value = " .. tResult.star_value)
			end
		end

		-- 购买到的银两
		G_flyAttribute.doAddRichtext(G_lang:get("LANG_THEME_DROP_GET_MONEY_TAG"))
		G_flyAttribute.doAddRichtext(G_lang:get("LANG_THEME_DROP_GET_MONEY", {color=Colors.getRichTextValue(Colors.getColor(1)), name=100000}))

		G_flyAttribute.doAddRichtext(G_lang:get("LANG_THEME_DROP_EXTRACT_GET_STARVALUE", {color=Colors.getRichTextValue(Colors.getColor(5)), name="x"..nStarValue}))
		G_flyAttribute.play()

		self._tEffect = EffectNode.new("effect_xingqiu_e", function(event, frameIndex)
			if event == "a" then
		 		if not self._flowerEffect then
					self._flowerEffect = EffectNode.new("effect_xingqiu_h", function(event, frameIndex)
						if event == "finish" then
					
							-- 关闭屏蔽层
						 	self._panelShield:setVisible(false)
							-- 转盘也可以拖动
						 	self._tPlateLayer:recoverTouch()
						 	self._tPlateLayer:setAutoRotate(false)
						 	-- 显示星运值
						 	self:_showStarValueChanged(data.sv_sum, true)
						 	-- 展示得到的全部碎片
							local tLayer = require("app.scenes.themedrop.ThemeDropAwardLayer").create(self._tTenFragmentList, function()

							end)
							if tLayer then
								uf_sceneManager:getCurScene():addChild(tLayer)
							end
					
							self._flowerEffect:removeFromParentAndCleanup(true)
							self._flowerEffect = nil
						end
					end)

					local panelCircle = self:getImageViewByName("Image_ProgressBar")
					if panelCircle then
						panelCircle:addNode(self._flowerEffect)
						local tSize = panelCircle:getSize()
						self._flowerEffect:play()
						self._flowerEffect:setPositionXY(0, -150)
					end
				end
				
			elseif event == "finish" then

				-- 删除特效自己
			 	self._tEffect:removeFromParentAndCleanup(true)
			 	self._tEffect = nil
			end
		end)
		local tFrontNode = self._tPlateLayer:getFrontNode()
		if tFrontNode then
			local tParent = tFrontNode:getImageViewByName("ImageView_Pedestal")
			if tParent then
			 	local tSize = tParent:getSize()
				tParent:addNode(self._tEffect, 6)
				self._tEffect:setPosition(ccp(tSize.width/2-30, tSize.height/2-10))
				self._tEffect:play()
			end
		end

		local x, y = self:getImageViewByName("Image_ProgressBar"):convertToWorldSpaceXY(0, 0)
		x, y = self._tPlateLayer._knightsLayer:convertToNodeSpaceXY(x, y)

		-- 球飞向进度条
		local tNodeList = self._tPlateLayer:getNodeList()
		for i=1, #tNodeList do
			local node = tNodeList[i]
			if node:getBaseImageOpacity() ~= 0 then
				local sp = display.newSprite("ui/themedrop/shiujingdi.png", UI_TEX_TYPE_LOCAL)
				if sp then
					self._tPlateLayer._knightsLayer:addChild(sp)
					sp:setZOrder(100)
					sp:setPosition(ccp(node:getPosition()))

					local nTime = 0.8
					local actMoveTo = CCMoveTo:create(nTime, ccp(x, y))
				--	local actSineIn = CCEaseSineIn:create(actMoveTo)
					local actScaleTo = CCScaleTo:create(nTime, 0.2)
					local actSpawn = CCSpawn:createWithTwoActions(actMoveTo, actScaleTo)
					local actCallback = CCCallFunc:create(function()
						if sp then
							sp:removeFromParentAndCleanup(true)
							sp = nil
						end
					end)
		
					sp:runAction(CCSequence:createWithTwoActions(actSpawn, actCallback))
				end
			end
		end


	--[[
		-- 除了最前面的球以外的球
		local tNodeList = self._tPlateLayer:getNodeExceptFront()
		self._tBombEffectList = {}
		for i=1, #tNodeList do
			local node = tNodeList[i]
			local tBombEffect = self._tBombEffectList[i]
			if not tBombEffect then
				tBombEffect = EffectNode.new("effect_xingqiu_e", function(event, frameIndex)
					if event == "finish" then
						tBombEffect:removeFromParentAndCleanup(true)
						tBombEffect = nil
					end
				end)
				self._tBombEffectList[i] = tBombEffect

				local tParent = node:getImageViewByName("ImageView_Pedestal")
				if tParent then
					local tSize = tParent:getSize()
					tParent:addNode(tBombEffect, 6)
					tBombEffect:setPosition(ccp(tSize.width/2-30, tSize.height/2-10))
					tBombEffect:play()
				end
			end 
		end
	]]	

	end)
end


function ThemeDropMainLayer:_flyAward(tAward)
	local tDropList = {}
    table.insert(tDropList, tAward)

    local tGoodsPopWindowsLayer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(tDropList, function() end)
    self:addChild(tGoodsPopWindowsLayer)
end

function ThemeDropMainLayer:_flyText(moneyNum, tAward, nStarValue)
	if type(tAward) ~= "table" and type(nStarValue) ~= "number" then
		return
	end

	if tAward.type > 0 and nStarValue > 0 then
		-- 购买到的银两
		G_flyAttribute.doAddRichtext(G_lang:get("LANG_THEME_DROP_GET_MONEY_TAG"))
		G_flyAttribute.doAddRichtext(G_lang:get("LANG_THEME_DROP_GET_MONEY", {color=Colors.getRichTextValue(Colors.getColor(1)), name=moneyNum}))

		-- 碎片
		local tGoods = G_Goods.convert(tAward.type, tAward.value, tAward.size)
		if tGoods then
		    G_flyAttribute.doAddRichtext(G_lang:get("LANG_THEME_DROP_EXTRACT_GET_FRAGMENT", {color=Colors.getRichTextValue(Colors.getColor(tGoods.quality)), name=tGoods.name.."x"..tGoods.size}))
		end

		-- 星运值
		local nQuality = 3
		if nStarValue == 10 then
			nQuality = 3
		elseif nStarValue == 30 then
			nQuality = 4
		elseif nStarValue == 100 then
			nQuality = 5
		end
		G_flyAttribute.doAddRichtext(G_lang:get("LANG_THEME_DROP_EXTRACT_GET_STARVALUE", {color=Colors.getRichTextValue(Colors.getColor(nQuality)), name="x"..nStarValue}))

		G_flyAttribute.play()
	end
end

function ThemeDropMainLayer:_addSceneEffect()
	if not self._tSceneEffect then
		self._tSceneEffect = EffectNode.new("effect_mojing_BG", function(event, frameIndex)

		end)
		local tParent = self:getImageViewByName("ImageView_bg")
		if tParent then
			tParent:addNode(self._tSceneEffect)
			self._tSceneEffect:setPositionY(self._tSceneEffect:getPositionY() + 40)
			self._tSceneEffect:play()
		end
	end
end

function ThemeDropMainLayer:_initDesc()
	--[[
	CommonFunc._updateLabel(self, "Label_Desc1", {text=G_lang:get("LANG_THEME_DROP_DESC_1"), stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_Desc3", {text=G_lang:get("LANG_THEME_DROP_DESC_3"), stroke=Colors.strokeBrown})
	for i=1, #self._tThemeKnightList do
		local tThemeTmpl = self._tThemeKnightList[i]
		assert(tThemeTmpl)
		local tKnightTmpl = knight_info.get(tThemeTmpl.id)
		if tKnightTmpl then
			CommonFunc._updateLabel(self, "Label_Desc"..(i*2), {text=tKnightTmpl.name, color=Colors.qualityColors[tKnightTmpl.quality], stroke=Colors.strokeBrown})
		end
	end

    local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_Desc1'),
        self:getLabelByName('Label_Desc2'),
        self:getLabelByName('Label_Desc3'),
        self:getLabelByName('Label_Desc4'),
    }, "C")
    self:getLabelByName('Label_Desc1'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_Desc2'):setPositionXY(alignFunc(2)) 
    self:getLabelByName('Label_Desc3'):setPositionXY(alignFunc(3)) 
    self:getLabelByName('Label_Desc4'):setPositionXY(alignFunc(4)) 
    ]]

	local function createRichText(labelTmpl)
	    labelTmpl:setText("")
	    local size = labelTmpl:getSize()
	    local parent = labelTmpl:getParent()
	    size = CCSizeMake(display.width, 40)

	--    local labelRichText = CCSRichText:create(size.width, size.height + 50)
		local labelRichText = CCSRichText:createSingleRow()
	    labelRichText:setFontName(labelTmpl:getFontName())
	    labelRichText:setFontSize(labelTmpl:getFontSize())
	    labelRichText:setShowTextFromTop(true)
	    labelRichText:enableStroke(Colors.strokeBrown)
	    labelRichText:setAnchorPoint(ccp(0.5, 0.5))
	    local x, y = labelTmpl:getPosition()
	    labelRichText:setPosition(ccp(x, y))
	    parent:addChild(labelRichText, 5)

	    return labelRichText
	end

	local tList = {}
	for i=1, #self._tThemeKnightList do
		local tThemeTmpl = self._tThemeKnightList[i]
		local tKnightTmpl = knight_info.get(tThemeTmpl.id)
		table.insert(tList, tKnightTmpl.name)
	end

	local szContent = G_lang:get("LANG_THEME_DROP_DESC_LINE", {knightName1 = tList[1] or "", knightName2 = tList[2] or ""})
    if not self._richText then
    	self._richText = createRichText(self:getLabelByName("Label_Desc1"))
    end
	self._richText:clearRichElement()
	self._richText:appendContent(szContent, ccc3(255, 255, 255))
	self._richText:reloadData()

end

function ThemeDropMainLayer:_updateAstrologyTimes()
	local tInitInfo = G_Me.themeDropData:getInitializeInfo()
	CommonFunc._updateLabel(self, "Label_AstrologyDesc", {text=G_lang:get("LANG_THEME_DROP_ASTROLOGY_DESC"), stroke=Colors.strokeBrown})
	CommonFunc._updateLabel(self, "Label_AstrologyTime", {text=G_lang:get("LANG_THEME_DROP_ASTROLOGY_TIMES", {num=tInitInfo._nRemainDropTimes}), stroke=Colors.strokeBrown})

	local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
        self:getLabelByName('Label_AstrologyDesc'),
        self:getLabelByName('Label_AstrologyTime'),
    }, "C")
    self:getLabelByName('Label_AstrologyDesc'):setPositionXY(alignFunc(1))
    self:getLabelByName('Label_AstrologyTime'):setPositionXY(alignFunc(2)) 
end

-- 主题将的名字
function ThemeDropMainLayer:_addThemeKnightName(nBaseId, tParent, szName, nQuality)
	if type(nBaseId) ~= "number" or tParent == nil then
		return
	end

	szName = szName or ""
	nQuality = nQuality or 6
	local tColor = Colors.qualityColors[nQuality]

	local imgBg = ImageView:create()
	imgBg:loadTexture("ui/storydungeon/mingjiang_bg_name.png", UI_TEX_TYPE_LOCAL)
	local labelName = G_GlobalFunc.createGameLabel(szName, 24, tColor, Colors.strokeBrown, CCSize(26, 140), true)
	labelName:setPositionXY(-1, -20)
	imgBg:addChild(labelName)
	imgBg:setScale(1 / 0.8)

	local tLeft = {
		10001, 10056, -- 魏
		30045,   

		-- 以下是橙将

		20023,
		30034,
		40188,
	}

	local tRight = {
		20001, 20078, 
		30001,
		40001, 40045,

		-- 以下是橙将
		10045, 10111,
		20089,
		30067,
		40133,
	}	

	local nRate = 1/3
	local nOffset = 20
	for key, val in pairs(tLeft) do
		if val == nBaseId then
			nRate = 1/3
			nOffset = -20
		end
	end
	for key, val in pairs(tRight) do
		if val == nBaseId then
			nRate = 2/3
			nOffset = 20
		end
	end
	-- local ptWorld = ccp(display.width*nRate + nOffset, display.height*2/3)
	local ptWorld = ccp(display.width*nRate + nOffset, display.height/2+130)
	local x, y = tParent:convertToNodeSpaceXY(ptWorld.x, ptWorld.y)
	imgBg:setPositionXY(x, y)
	tParent:addChild(imgBg)

	return imgBg
end

function ThemeDropMainLayer:_updateClaimButton(couldClaim)
	couldClaim = couldClaim or false
	local btnClaim = self:getButtonByName("Button_Claim")
	if couldClaim then
		btnClaim:loadTextureNormal("ui/dungeon/baoxiangjin_kai.png", UI_TEX_TYPE_LOCAL)
		if not self._tClaimButtonEffect then
			self._tClaimButtonEffect = EffectNode.new("effect_box_light", function(event, frameIndex)

			end)
			btnClaim:addNode(self._tClaimButtonEffect)
			self._tClaimButtonEffect:setPositionXY(20, 15)
			self._tClaimButtonEffect:play()
		end
	else
		btnClaim:loadTextureNormal("ui/dungeon/baoxiangjin_guan.png", UI_TEX_TYPE_LOCAL)
		if self._tClaimButtonEffect then
			self._tClaimButtonEffect:removeFromParentAndCleanup(true)
			self._tClaimButtonEffect = nil
		end
	end
end

return ThemeDropMainLayer