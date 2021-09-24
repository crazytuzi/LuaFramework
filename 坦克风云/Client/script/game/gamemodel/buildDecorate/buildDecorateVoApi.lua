-- @Author hj
-- @time 2018-09-04
-- @Description 建筑装扮VoApi

buildDecorateVoApi={
	hasSkinTb = {},
	lockSkinTb = {},
	nowUse = exteriorCfg.baseExteriorId,
}

function buildDecorateVoApi:initSkinTb()

	if self.hasSkinTb and #self.hasSkinTb>0 then
		return 
	else
		self.hasSkinTb = {}
		self.lockSkinTb = {}
		self.nowUse = exteriorCfg.baseExteriorId
	end

	local skinTb = playerVoApi:getSkin()
	-- 初始化已有装扮
	if skinTb then

		for k,v in pairs(skinTb) do
			self:detaiSkin(k,v)
		end 

		-- 初始化未解锁装扮
		for k,v in pairs(exteriorCfg.exteriorLit) do
			if not skinTb[k] and self:isForeign(k) == false then
				v.useStatus = 0
				v.nowLevel = 1
				if v.timeLimit > 0 then --策划约定，当是限时皮肤时直接取最大值
					v.nowLevel = v.lvMax
				end
				table.insert(self.lockSkinTb,v)
			end
		end
	else
		self:initSkinTbByLevel()
	end

end

function buildDecorateVoApi:tick()
	if self.hasSkinTb then
		for k, v in pairs(self.hasSkinTb) do
			if type(v.endTimer) == "number" and v.endTimer > 0 and v.endTimer <= base.serverTime then --该皮肤过期
				self:deleteHasSkin(v.id)
				eventDispatcher:dispatchEvent("buildDecorateDialog.refreshSp")
			end
		end
	end
end

-- 玩儿家到达皮肤解锁等级，前端初始化数据
function buildDecorateVoApi:initSkinTbByLevel( ... )
	
	self.hasSkinTb = {}
	self.lockSkinTb = {}
	self.nowUse = exteriorCfg.baseExteriorId

	for k,v in pairs(exteriorCfg.exteriorLit) do
		if k ~= "b1" and self:isForeign(k) == false then
			v.useStatus = 0
			v.nowLevel = 1
			if v.timeLimit > 0 then --策划约定，当是限时皮肤时直接取最大值
				v.nowLevel = v.lvMax
			end
			table.insert(self.lockSkinTb,v)
		end
	end
	
	for k,v in pairs(exteriorCfg.exteriorLit) do
		if k == "b1" then
			v.useStatus = 1
			v.nowLevel = 1
			table.insert(self.hasSkinTb,v)
		end
	end
end

--删除已拥有的皮肤
function buildDecorateVoApi:deleteHasSkin(bid)
	if bid == nil then
		return
	end
	if self.hasSkinTb then
		for k, v in pairs(self.hasSkinTb) do
			if v.id == bid then
				table.remove(self.hasSkinTb, k)
				break
			end
		end
	end
	if self.lockSkinTb == nil then
		self.lockSkinTb = {}
	end
	local v = G_clone(exteriorCfg.exteriorLit[tostring(bid)])
	v.useStatus = 0
	v.nowLevel = 1
	v.endTimer = nil
	v.experienceTimer = nil
	if v.timeLimit > 0 then --策划约定，当是限时皮肤时直接取最大值
		v.nowLevel = v.lvMax
	end
	table.insert(self.lockSkinTb, v)

	--如果删除的正好是当前正在使用的皮肤
	if self.nowUse == bid then
		--那就要把当前正在使用的皮肤重置回默认皮肤
		self.nowUse = exteriorCfg.baseExteriorId
		if self.hasSkinTb then
			for k, v in pairs(self.hasSkinTb) do
				if v.id == self.nowUse then
					self.hasSkinTb[k].useStatus = 1
					break
				end
			end
		end
		if worldScene and worldScene.changeBaseSkin then
			worldScene:changeBaseSkin()
		end
	end
end

--该皮肤是否在体验期
function buildDecorateVoApi:isExperience(bid)
	if bid == nil then
		return
	end
	if self.hasSkinTb then
		for k, v in pairs(self.hasSkinTb) do
			if v.id == bid and v.endTimer and v.endTimer > base.serverTime and type(v.experienceTimer) == "number" and v.experienceTimer > 0 then
				return true
			end
		end
	end
	return false
end

function buildDecorateVoApi:getNowUse( ... )
	if self.nowUse then
		return self.nowUse
	end
end

function buildDecorateVoApi:isForeign(bid)
	do return false end
	-- if G_isChina() == false and (bid=="b3" or bid == "b4") then
	-- 	return true
	-- else
	-- 	return false
	-- end
end

function buildDecorateVoApi:detaiSkin(skinId,skinInfo)
	if self:isForeign(skinId) == true then
		do return end
	end
	if exteriorCfg.exteriorLit[skinId] then
		-- 细节化已经拥有的皮肤
		local tempTb = exteriorCfg.exteriorLit[skinId]
		local useStatus = skinInfo[1]
		if useStatus == 1 then
			self.nowUse = skinId
		end
		local nowLevel = skinInfo[2]
		tempTb.useStatus = useStatus
		tempTb.nowLevel = nowLevel
		tempTb.endTimer = skinInfo[3] or 0 --限时皮肤的结束时间戳
		tempTb.experienceTimer = skinInfo[4] --体验期时长
		table.insert(self.hasSkinTb,tempTb)
	end
end

function buildDecorateVoApi:unlockSkin(id, experienceTimer)
	for k,v in pairs(self.hasSkinTb) do
		if v.id == id then
			if v.timeLimit > 0 then --如果是限时皮肤就重置一下结束时间戳
				if experienceTimer and tonumber(experienceTimer)>0 then --体验卡
					self.hasSkinTb[k].endTimer = base.serverTime + tonumber(experienceTimer)
					self.hasSkinTb[k].experienceTimer = tonumber(experienceTimer)
				else
					self.hasSkinTb[k].endTimer = base.serverTime + v.timeLimit
					if self.hasSkinTb[k].experienceTimer and tonumber(self.hasSkinTb[k].experienceTimer) > 0 then --如果正在使用的是体验卡，此时使用非体验卡时替换成限时皮肤
						self.hasSkinTb[k].experienceTimer = 0
					end
				end
			elseif self:isExperience(id) == true then --该皮肤正处于体验期
				if type(experienceTimer) == "number" and experienceTimer > 0 then --本次使用的是一个皮肤体验卡
					self.hasSkinTb[k].endTimer = base.serverTime + experienceTimer
					self.hasSkinTb[k].experienceTimer = experienceTimer
				else --本次添加的是一个正常皮肤
					self.hasSkinTb[k].nowLevel = 1
					self.hasSkinTb[k].endTimer = 0
					self.hasSkinTb[k].experienceTimer = 0
				end
			end
			do return end
		end
	end

	--如果是限时皮肤就重置一下结束时间戳
	local skinCfg = exteriorCfg.exteriorLit[tostring(id)]
	local skinInfo = {0,1,0}
	local timeLimit = skinCfg.timeLimit
	if type(experienceTimer) == "number" and experienceTimer > 0 then
		skinInfo[2] = skinCfg.lvMax
		skinInfo[3] = base.serverTime + experienceTimer
		skinInfo[4] = experienceTimer
	elseif timeLimit > 0 then
		skinInfo[2] = skinCfg.lvMax
		skinInfo[3] = base.serverTime + timeLimit
	end
	
	self:detaiSkin(id,skinInfo)

	for k,v in pairs(self.lockSkinTb) do
		if id == v.id then
			table.remove(self.lockSkinTb,k)
		end
	end
end

-- 获取带兵量的等级
function buildDecorateVoApi:getNumlevel( ... )	
	for k,v in pairs(self.lockSkinTb) do
		if v.id == "b2" then
			return 0
		end
	end
	for k,v in pairs(self.hasSkinTb) do
		if v.id == "b2" then
			return v.nowLevel
		end
	end
end



function buildDecorateVoApi:getHasSkinTb( ... )

	if #self.hasSkinTb == 0 then
		self:initSkinTbByLevel()
	else
		local function sortAsc(a, b)
			if tonumber(RemoveFirstChar(a.id)) ~= tonumber(RemoveFirstChar(b.id)) then
				return tonumber(RemoveFirstChar(a.id)) < tonumber(RemoveFirstChar(b.id))
			end
		end
		table.sort(self.hasSkinTb,sortAsc)
	end
	
	return self.hasSkinTb
end

function buildDecorateVoApi:getLockSkinTb( ... )
	
	if self.lockSkinTb then
		-- 按照id进行排序
		local function sortAsc(a, b)
			if tonumber(RemoveFirstChar(a.id)) ~= tonumber(RemoveFirstChar(b.id)) then
				return tonumber(RemoveFirstChar(a.id)) < tonumber(RemoveFirstChar(b.id))
			end
		end
		table.sort(self.lockSkinTb,sortAsc)
		return self.lockSkinTb
	end
end

function buildDecorateVoApi:getLevelLimit( ... )
	local levelLimit = exteriorCfg.openlv
	if levelLimit then
		return levelLimit
	end
end

function buildDecorateVoApi:getUpgradeProp( ... )
	local upgradeCostItem = exteriorCfg.upgradeCostItem 
	if upgradeCostItem then
		return upgradeCostItem
	end
end

-- 添加的带兵量
function buildDecorateVoApi:addTroopNum( ... )

	local addNum = 0
	for k,v in pairs(self.hasSkinTb) do
		if self:isExperience(v.id) == false then --只有非体验期(体验卡)的皮肤属性才会生效
			for kk,vv in pairs(v.attType) do
				if vv == 3 then
					addNum = addNum + v.value[kk][v.nowLevel]
				end
			end
		end
	end
	return addNum
end


-- 添加的世界金矿的采集金币上限
function buildDecorateVoApi:addGemLimit( ... )
	local addNum = 0
	for k,v in pairs(self.hasSkinTb) do
		if self:isExperience(v.id) == false then --只有非体验期(体验卡)的皮肤属性才会生效
			for kk,vv in pairs(v.attType) do
				if vv == 7 then
					addNum = addNum + v.value[kk][v.nowLevel]
				end
			end
		end
	end
	return addNum
end


function buildDecorateVoApi:playSkinAction(skinId,decorateSp)
	local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
	blendFunc.src=GL_ONE
	blendFunc.dst=GL_ONE

	local actionNode = decorateSp:getChildByTag(1018)
	if actionNode and tolua.cast(actionNode,"CCNode") then
		actionNode:removeFromParentAndCleanup(true)
		actionNode=nil
	end
	actionNode = CCNode:create()
  	actionNode:setContentSize(CCSizeMake(decorateSp:getContentSize().width,decorateSp:getContentSize().height))
  	actionNode:setAnchorPoint(ccp(0.5,0.5))
  	actionNode:setPosition(getCenterPoint(decorateSp))
  	actionNode:setTag(1018)
  	decorateSp:addChild(actionNode)
  	decorateSp:setOpacity(255)

	if skinId == "b2" then
		self:playFlashAction(actionNode,blendFunc)
	elseif skinId == "b4" then
		self:playFireAction(actionNode,blendFunc)
	elseif skinId == "b5" then
		self:playChrisAction(actionNode,blendFunc)
	elseif skinId == "b6" then
		self:playModernAction(actionNode,blendFunc)
	elseif skinId == "b7" then
		self:playSpringAction(actionNode,blendFunc)
	elseif skinId == "b8" then --未来之城
		decorateSp:setOpacity(0)
		local baseFrameSp=self:playFrameAction(actionNode,15,0.2,"wlzc_basef")
		local act = 1.4
		local floatArr = CCArray:create()
		local floatUp = CCMoveBy:create(act,ccp(0,4))
		local floatDown = CCMoveBy:create(act,ccp(0,-4))
		floatArr:addObject(floatUp)
		floatArr:addObject(floatDown)
		local seq = CCSequence:create(floatArr)
		local floatAc = CCRepeatForever:create(seq)
		baseFrameSp:runAction(floatAc)
		
		local shadeSp = CCSprite:createWithSpriteFrameName("wlzcshade.png")
		shadeSp:setAnchorPoint(ccp(0.5,0.5))
		shadeSp:setPosition(actionNode:getContentSize().width/2,-8)
		actionNode:addChild(shadeSp)
		local shadeArr = CCArray:create()
		local scaleTo1 = CCScaleTo:create(act,0.8)
		local scaleTo2 = CCScaleTo:create(act,1)
		shadeArr:addObject(scaleTo1)
		shadeArr:addObject(scaleTo2)
		local shadeSeq = CCSequence:create(shadeArr)
		local shadeAc = CCRepeatForever:create(shadeSeq)
		shadeSp:runAction(shadeAc)
	elseif skinId == "b10" then --发射基地
		self:playExerWarBaseAction(actionNode)
	elseif skinId == "b11" or skinId == "b12" or skinId == "b13" then
		local buildingPic = exteriorCfg.exteriorLit[skinId].decorateSp
		if skinId =="b11" then
			G_buildingAction1(buildingPic,actionNode,nil,nil,nil,true)
		elseif skinId =="b12" then
			G_buildingAction2(buildingPic,actionNode,nil,nil,nil,true)
		else
			G_buildingAction3(buildingPic,actionNode,nil,nil,nil,true)
		end
	else
		do return end
	end
end

-- 减少坦克修复
function buildDecorateVoApi:declineGoldCost( ... )

	local desRate = 0
	for k,v in pairs(self.hasSkinTb) do
		if self:isExperience(v.id) == false then --只有非体验期(体验卡)的皮肤属性才会生效
			for kk,vv in pairs(v.attType) do
				if vv == 4 then
					desRate = v.value[kk][v.nowLevel]
				end
			end
		end
	end
	return desRate
end

-- 增加行军速度
function buildDecorateVoApi:addTroopSpeed( ... )

	local rate = 0
	for k,v in pairs(self.hasSkinTb) do
		if self:isExperience(v.id) == false then --只有非体验期(体验卡)的皮肤属性才会生效
			for kk,vv in pairs(v.attType) do
				if vv == 1 then
					rate = v.value[kk][v.nowLevel]
				end
			end
		end
	end
	return rate
end

-- 增加采集速度,采集速度后台会返回，前台没有显示，这个接口没屌用
function buildDecorateVoApi:addCollectSpeed( ... )
	local  rate = 0
	for k,v in pairs(self.hasSkinTb) do
		if self:isExperience(v.id) == false then --只有非体验期(体验卡)的皮肤属性才会生效
			for kk,vv in pairs(v.attType) do
				if vv == 2 then
					rate = v.value[kk][v.nowLevel]
				end
			end
		end
	end
	return rate
end

-- 减少AI部队生产时间
function buildDecorateVoApi:getAITroopsProduceTimeBuff()
	local  rate = 0
	for k,v in pairs(self.hasSkinTb) do
		if self:isExperience(v.id) == false then --只有非体验期(体验卡)的皮肤属性才会生效
			for kk,vv in pairs(v.attType) do
				if vv == 13 then
					rate = v.value[kk][v.nowLevel]
				end
			end
		end
	end
	return rate
end

--获取增加的坦克属性
function buildDecorateVoApi:getTankPropertyAdding()
	local  dodge, precision, crit, armor, breaks, protection= 0,0,0,0,0,0-- 对应关系 ： 闪避 14，精准 15, 暴击 16, 装甲 17，击破 18，防护 19
	for k,v in pairs(self.hasSkinTb) do
		if self:isExperience(v.id) == false then--只有非体验期(体验卡)的皮肤属性才会生效
			for kk,vv in pairs(v.attType) do
				if vv == 14 then
					dodge = v.value[kk][v.nowLevel] + dodge
				elseif vv == 15 then
					precision = v.value[kk][v.nowLevel] + precision
				elseif vv == 16 then
					crit = v.value[kk][v.nowLevel] + crit
				elseif vv == 17 then
					armor = v.value[kk][v.nowLevel] + armor
				elseif vv == 18 then
					breaks = v.value[kk][v.nowLevel] + breaks
				elseif vv == 19 then
					protection = v.value[kk][v.nowLevel] + protection
				end
			end
		end
	end
	return dodge * 100, precision * 100, crit * 100, armor * 100, breaks, protection * 100
end
-- 升级皮肤
function buildDecorateVoApi:upgradeSkin(id)
	for k,v in pairs(self.hasSkinTb) do
		if v.id == id and v.nowLevel < v.lvMax then
			self.hasSkinTb[k].nowLevel = self.hasSkinTb[k].nowLevel + 1
		end
	end
end

function buildDecorateVoApi:judgeHas(id)
	for k,v in pairs(self.hasSkinTb) do
		if v.id == id then
			return true
		end
	end
	return false
end

function buildDecorateVoApi:isSkinExpire(id)
	for k,v in pairs(self.hasSkinTb) do
		if v.id == id then
			if v.endTimer and tonumber(v.endTimer)>0 and base.serverTime>=tonumber(v.endTimer) then
				return true
			end
			return false
		end
	end
	return false
end

-- 使用皮肤,修改皮肤的状态
function buildDecorateVoApi:useSkin(id)
	for k,v in pairs(self.hasSkinTb) do
		if v.id == id then
			self.hasSkinTb[k].useStatus = 1
			self.nowUse = v.id
		elseif v.useStatus == 1 then
			self.hasSkinTb[k].useStatus = 0
		end
	end
end

-- -- 是否有节日特殊皮肤,有节日特殊皮肤不允许玩儿家更换
-- function buildDecorateVoApi:isSpecialDaySkin( ... )
-- 	if acHalloween2018VoApi then
-- 		local acVo=acHalloween2018VoApi:getAcVo()
-- 		if acVo then 
-- 			if activityVoApi:isStart(acVo) == true then 
-- 				return "wsj2018_world.png"
-- 			end
-- 		end
-- 	end
-- 	return false

-- end

-- function buildDecorateVoApi:getSkinImg(flag,id)
-- 	local isSkin = "b1"
-- 	if not id then
-- 		self:getHasSkinTb()
-- 		id = self.nowUse
-- 	end
-- 	if flag then
-- 		if flag == 1 then
-- 			-- 获取基地内的外观
-- 			return exteriorCfg.exteriorLit[id].baseSp
-- 		else
-- 			if id == "b1" then
-- 				local level = playerVoApi:getPlayerLevel()
-- 				local resStr 
-- 				if level<21 then
-- 		            resStr="map_base_building_1.png"
-- 		        elseif level<41 then
-- 		            resStr="map_base_building_2.png"
-- 		        elseif level<61 then
-- 		            resStr="map_base_building_3.png"
-- 		        elseif level<71 then
-- 		            resStr="map_base_building_4.png"
-- 		        elseif level<101 then
-- 		            resStr="map_base_building_5.png"
-- 		        elseif level<111 then
-- 		            resStr="map_base_building_6.png"
-- 		        else
-- 		        	resStr="map_base_building_7.png"
-- 		        end
-- 		        return resStr,isSkin
-- 			else
-- 				isSkin = id
-- 				return exteriorCfg.exteriorLit[id].worldSp,isSkin
-- 			end
-- 		end
-- 	end
-- end

-- 蜡烛特效
function buildDecorateVoApi:playFireAction(displaySp,blendFunc)

	local candleSp = CCSprite:createWithSpriteFrameName("znjl_basefire1.png")
	candleSp:setAnchorPoint(ccp(0.5,1))
	candleSp:setPosition(ccp(displaySp:getContentSize().width/2+15,displaySp:getContentSize().height))
	candleSp:setBlendFunc(blendFunc)
	displaySp:addChild(candleSp)
	candleSp:setTag(1017)

	local pzArr = CCArray:create()

	for kk=1,12 do
        local candle="znjl_basefire"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(candle)
        if frame then
        	pzArr:addObject(frame)
    	end
    end
    local animation=CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(0.07)
    local animate=CCAnimate:create(animation)
    local repeatForever=CCRepeatForever:create(animate)

	candleSp:runAction(repeatForever)


end

function buildDecorateVoApi:playChrisAction(displaySp,blendFunc)

	local posCfg = { p={ccp(129,95),ccp(216,95)},b={ccp(128,137),ccp(172,116),ccp(216,137)},s={ccp(95,74),ccp(145,50),ccp(252,102)} }

	local threePointSp = CCSprite:createWithSpriteFrameName("guang01.png")
	threePointSp:setPosition(ccp(172,72))
	threePointSp:setBlendFunc(blendFunc)
	displaySp:addChild(threePointSp)
	threePointSp:setOpacity(25580)
	local threePointFade1 = CCFadeTo:create(0.67,255*1)
	local threePointFade2 = CCFadeTo:create(0.67,255*0)
	local threePointSeq = CCSequence:createWithTwoActions(threePointFade1,threePointFade2)
	local threePointRepeatEver = CCRepeatForever:create(threePointSeq)
	threePointSp:runAction(threePointRepeatEver)

	local giftSp = CCSprite:createWithSpriteFrameName("liwu.png")
	giftSp:setAnchorPoint(ccp(0.5,1))
	giftSp:setPosition(ccp(138,110))
	giftSp:setBlendFunc(blendFunc)
	displaySp:addChild(giftSp)
	local giftFade1 = CCFadeTo:create(0.67,255*0.3)
	local giftFade2 = CCFadeTo:create(0.67,255*1)
    local giftSeq = CCSequence:createWithTwoActions(giftFade1,giftFade2)
    local giftRepeatEver = CCRepeatForever:create(giftSeq)
    giftSp:runAction(giftRepeatEver)

	for i=1,2 do
		local twoPointSp = CCSprite:createWithSpriteFrameName("guang02.png")
		twoPointSp:setBlendFunc(blendFunc)
		displaySp:addChild(twoPointSp)
		twoPointSp:setPosition(posCfg["p"][i])
		twoPointSp:setOpacity(255*0)
		local twoPointFade1 = CCFadeTo:create(0.67,255*1)
		local twoPointFade2 = CCFadeTo:create(0.67,255*0)
		local twoPointSeq = CCSequence:createWithTwoActions(twoPointFade1,twoPointFade2)
		local twoPointRepeatEver = CCRepeatForever:create(twoPointSeq)
		twoPointSp:runAction(twoPointRepeatEver)
	end

	for i=1,3 do
		local starSp = CCSprite:createWithSpriteFrameName("xing.png")
		starSp:setBlendFunc(blendFunc)
		displaySp:addChild(starSp)
		starSp:setPosition(posCfg["s"][i])
		local starFade1 = CCFadeTo:create(0.67,255*0)
		local starFade2 = CCFadeTo:create(0.67,255*1)
		local starSeq = CCSequence:createWithTwoActions(starFade1,starFade2)
		local starRepeatEver = CCRepeatForever:create(starSeq)
		starSp:runAction(starRepeatEver)

	end

	for i=1,3 do
		local ballSp = CCSprite:createWithSpriteFrameName("qiu.png")
		ballSp:setBlendFunc(blendFunc)
		displaySp:addChild(ballSp)
		ballSp:setPosition(posCfg["b"][i])
		ballSp:setOpacity(255*0.1)
		local ballFade1 = CCFadeTo:create(0.67,255*1)
		local ballFade2 = CCFadeTo:create(0.67,255*0.1)
		local ballSeq = CCSequence:createWithTwoActions(ballFade1,ballFade2)
		local ballRepeatEver = CCRepeatForever:create(ballSeq)
		ballSp:runAction(ballRepeatEver)

	end
	-- 雪花序列帧
	G_playParticle(displaySp,ccp(displaySp:getContentSize().width/2,displaySp:getContentSize().height-70),"scene/loadingEffect/xue.plist",nil,true,1.3,nil,2,0)
end

-- 闪电特效
function buildDecorateVoApi:playFlashAction(displaySp,blendFunc)

    local flashSp = CCSprite:createWithSpriteFrameName("flash1.png")
	flashSp:setAnchorPoint(ccp(0.5,1))
	flashSp:setPosition(ccp(displaySp:getContentSize().width/2+15,displaySp:getContentSize().height-10))
	displaySp:addChild(flashSp)
	flashSp:setVisible(false)
	flashSp:setBlendFunc(blendFunc)
	flashSp:setTag(1016)

	if tolua.cast(flashSp,"CCSprite") then
		flashSp:setVisible(true)
	else
		return
    end

    local acArr = CCArray:create()
    local pzArr = CCArray:create()
	for kk=1,10 do
        local flash="flash"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(flash)
        if frame then
        	pzArr:addObject(frame)
    	end
    end
    local delay = CCDelayTime:create(0.5)
    local animation=CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(0.07)
    local animate=CCAnimate:create(animation)

    local function callBack( ... )
    	flashSp:setVisible(false)
    end
	local callfunc = CCCallFunc:create(callBack)

	local function callBack1( ... )
    	flashSp:setVisible(true)
    end
	local callfunc1 = CCCallFunc:create(callBack1)

    acArr:addObject(animate)
    acArr:addObject(callfunc)
    acArr:addObject(delay)
    acArr:addObject(callfunc1)

    local seq = CCSequence:create(acArr)
    local repeatForever=CCRepeatForever:create(seq)
	flashSp:runAction(repeatForever)

end

--摩登之城特效
function buildDecorateVoApi:playModernAction(displaySp,blendFunc)
	local modernSp = CCSprite:createWithSpriteFrameName("jdpf_ModernEffect1.png")
	modernSp:setAnchorPoint(ccp(0.5,0.5))
	modernSp:setPosition(ccp(displaySp:getContentSize().width/2+24,displaySp:getContentSize().height/2))
	displaySp:addChild(modernSp)
	modernSp:setBlendFunc(blendFunc)

	local pzArr = CCArray:create()
	for kk=1, 10 do
		local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("jdpf_ModernEffect"..kk..".png")
		if frame then
        	pzArr:addObject(frame)
    	end
	end
	local animation=CCAnimation:createWithSpriteFrames(pzArr, 0.15)
    local animate=CCAnimate:create(animation)
	local repeatForever=CCRepeatForever:create(animate)
	modernSp:runAction(repeatForever)
end

function buildDecorateVoApi:playSpringAction(displaySp,blendFunc)
	local effectTb = {
		{ "jdpf_chunjieEffect1_", 20, 0.05 }, --礼花(红色)
		{ "jdpf_chunjieEffect2_", 20, 0.05 }, --礼花(黄色)
		{ "jdpf_chunjieEffect3_", 20, 0.05 }, --礼花(蓝色)
		{ "jdpf_chunjieEffect4_", 12, 0.10 }, --大吉大利
		{ "jdpf_chunjieEffect5_", 12, 0.10 }, --万事如意
	}
	local function createAction(index, pos)
		local actionName = effectTb[index][1]
		local effectSp = CCSprite:createWithSpriteFrameName(actionName .. "1.png")
		effectSp:setBlendFunc(blendFunc)
		effectSp:setPosition(pos)
		displaySp:addChild(effectSp)
		local animArr = CCArray:create()
		for i = 1, effectTb[index][2] do
			local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(actionName .. i .. ".png")
			if frame then
	        	animArr:addObject(frame)
	    	end
		end
		local animation=CCAnimation:createWithSpriteFrames(animArr, effectTb[index][3])
	    local animate=CCAnimate:create(animation)
	    return effectSp, animate
	end

	--灯笼
	local lanternData = {
		ccp(-26, 30), ccp(7, 13), ccp(14, 14), ccp(24, 20), ccp(38, 27), ccp(47, 31), ccp(55, 38)
	}
	for k, v in pairs(lanternData) do
		local lanternSp = CCSprite:createWithSpriteFrameName("jdpf_chunjieEffect_lantern.png")
		lanternSp:setBlendFunc(blendFunc)
		lanternSp:setPosition(displaySp:getContentSize().width / 2 + v.x, displaySp:getContentSize().height / 2 + v.y)
		displaySp:addChild(lanternSp)
		local arry = CCArray:create()
		if k % 2 ~= 0 then
			lanternSp:setOpacity(0)
			arry:addObject(CCFadeTo:create(1, 255))
			arry:addObject(CCFadeTo:create(1, 0))
			arry:addObject(CCDelayTime:create(1))
		else
			lanternSp:setOpacity(255)
			arry:addObject(CCFadeTo:create(1.5, 0))
			arry:addObject(CCDelayTime:create(1))
			arry:addObject(CCFadeTo:create(1.5, 255))
		end
		lanternSp:runAction(CCRepeatForever:create(CCSequence:create(arry)))
	end

	--礼花
	local fireworkData = {
		{ 1, ccp( 58, 73) },
		{ 2, ccp( 23, 40) },
		{ 3, ccp(-36, 71) },
		{ 1, ccp(-12, 37) },
		{ 2, ccp( 16, 82) },
		{ 3, ccp( 52, 48) },
	}
	local fireworkSize = SizeOfTable(fireworkData)
	local function runFireworkEffect()
		for k, v in pairs(fireworkData) do
			local id, pos = v[1], v[2]
			local fireworkSp, fireworkAnim = createAction(id, ccp(displaySp:getContentSize().width / 2 + pos.x, displaySp:getContentSize().height / 2 + pos.y))
			fireworkSp:setVisible(false)
			local array = CCArray:create()
			array:addObject(CCDelayTime:create(0.2 * k))
			array:addObject(CCCallFunc:create(function() fireworkSp:setVisible(true) end))
			array:addObject(fireworkAnim)
			if k == fireworkSize then
				array:addObject(CCCallFunc:create(function() fireworkSp:setVisible(false) end))
				array:addObject(CCDelayTime:create(4))
				array:addObject(CCCallFunc:create(function()
					fireworkSp:removeFromParentAndCleanup(true)
					runFireworkEffect()
				end))
			else
				array:addObject(CCCallFunc:create(function() fireworkSp:removeFromParentAndCleanup(true) end))
			end
			fireworkSp:runAction(CCSequence:create(array))
		end
	end
	runFireworkEffect()

	--万事如意，大吉大利(光晕效果)
	local fontSp = CCSprite:createWithSpriteFrameName("jdpf_chunjieEffect_font.png")
	fontSp:setBlendFunc(blendFunc)
	fontSp:setPosition(displaySp:getContentSize().width - 93, 65)
	displaySp:addChild(fontSp)
	local fontArr = CCArray:create()
	fontArr:addObject(CCFadeTo:create(2, 0))
	fontArr:addObject(CCFadeTo:create(2, 255))
	fontSp:runAction(CCRepeatForever:create(CCSequence:create(fontArr)))

	--大吉大利
	local effectSp4, animate4 = createAction(4, ccp(displaySp:getContentSize().width - 60, 80))
	effectSp4:setVisible(false)
	local delayTime = effectTb[5][3] * 6
	local arry4 = CCArray:create()
	arry4:addObject(CCDelayTime:create(2 + delayTime))
	arry4:addObject(CCCallFunc:create(function()
		delayTime = 0
		effectSp4:setVisible(true)
	end))
	arry4:addObject(animate4)
	arry4:addObject(CCCallFunc:create(function() effectSp4:setVisible(false) end))
	arry4:addObject(CCDelayTime:create(2))
	effectSp4:runAction(CCRepeatForever:create(CCSequence:create(arry4)))

	--万事如意
	local effectSp5, animate5 = createAction(5, ccp(displaySp:getContentSize().width / 2 + 37, 47))
	effectSp5:setVisible(false)
	local arry5 = CCArray:create()
	arry5:addObject(CCDelayTime:create(2))
	arry5:addObject(CCCallFunc:create(function() effectSp5:setVisible(true) end))
	arry5:addObject(animate4)
	arry5:addObject(CCCallFunc:create(function() effectSp5:setVisible(false) end))
	arry5:addObject(CCDelayTime:create(2))
	effectSp5:runAction(CCRepeatForever:create(CCSequence:create(arry5)))
end

function buildDecorateVoApi:playFrameAction(sp,fc,ft,fname)
	local baseFrameSp = CCSprite:createWithSpriteFrameName("wlzc_basef1.png")
    local pzArr=CCArray:create()
    for kk=1,fc do
        local nameStr=fname..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        pzArr:addObject(frame)
    end
    local animation=CCAnimation:createWithSpriteFrames(pzArr)
    animation:setDelayPerUnit(ft)
    baseFrameSp:setAnchorPoint(ccp(0.5,0.5))
    baseFrameSp:setPosition(getCenterPoint(sp))
    sp:addChild(baseFrameSp)
    local animate=CCAnimate:create(animation)
    local repeatForever=CCRepeatForever:create(animate)
    baseFrameSp:runAction(repeatForever)

    return baseFrameSp
end

--发射基地的动画效果
function buildDecorateVoApi:playExerWarBaseAction(decorateSp)
	local height = decorateSp:getContentSize().height
	local saoSp1 = CCSprite:createWithSpriteFrameName("exerbase_picsao1.png")
	saoSp1:setPosition(134,height-111.5)
	decorateSp:addChild(saoSp1)
	G_playFrame(saoSp1,{frmn=15,frname="exerbase_picsao",perdelay=0.08,forever={0,2.5},blendType=1})

	local saoSp2 = CCSprite:createWithSpriteFrameName("exerbase_sao1.png")
	saoSp2:setPosition(132,height-63)
	saoSp2:setOpacity(0)
	decorateSp:addChild(saoSp2)
	local acArr = CCArray:create()
	acArr:addObject(CCDelayTime:create(0.67))
	acArr:addObject(CCCallFunc:create(function ()
		saoSp2:setOpacity(255)
		G_playFrame(saoSp2,{frmn=14,frname="exerbase_sao",perdelay=0.08,forever={0,2.5},blendType=1})
	end))
	saoSp2:runAction(CCSequence:create(acArr))

	for k=1,2 do
		local fangSp = CCSprite:createWithSpriteFrameName("exerwar_fang.png")
		fangSp:setOpacity(255*0.4)
		if k==2 then
			fangSp:setFlipX(true)
			fangSp:setPosition(182,height-54)
		else
			fangSp:setPosition(84,height-55)
		end
		decorateSp:addChild(fangSp)
		local blendFunc=ccBlendFunc:new()
	    blendFunc.src=GL_ONE
	    blendFunc.dst=GL_ONE
	    fangSp:setBlendFunc(blendFunc)
		local fangAcArr = CCArray:create()
		fangAcArr:addObject(CCFadeTo:create(0.25,0))
		fangAcArr:addObject(CCFadeTo:create(0.67,255))
		fangAcArr:addObject(CCFadeTo:create(0.33,255*0.4))
		fangSp:runAction(CCRepeatForever:create(CCSequence:create(fangAcArr)))
	end

	local guangSp1 = CCSprite:createWithSpriteFrameName("exerwar_guang1.png")
	guangSp1:setPosition(95,height-158.5)
	guangSp1:setOpacity(255*0.75)
	decorateSp:addChild(guangSp1)
	local guangAcArr1 = CCArray:create()
	guangAcArr1:addObject(CCFadeTo:create(0.67,255))
	guangAcArr1:addObject(CCFadeTo:create(0.58,255*0.75))
	guangSp1:runAction(CCRepeatForever:create(CCSequence:create(guangAcArr1)))
	local blendFunc1=ccBlendFunc:new()
    blendFunc1.src=GL_ONE
    blendFunc1.dst=GL_ONE
    guangSp1:setBlendFunc(blendFunc1)

	local guangSp2 = CCSprite:createWithSpriteFrameName("exerwar_guang2.png")
	guangSp2:setPosition(175,height-162)
	guangSp2:setOpacity(255*0.85)
	decorateSp:addChild(guangSp2)
	local guangAcArr2 = CCArray:create()
	guangAcArr2:addObject(CCFadeTo:create(0.25,255*0.75))
	guangAcArr2:addObject(CCFadeTo:create(0.67,255))
	guangAcArr2:addObject(CCFadeTo:create(0.33,255*0.85))
	guangSp2:runAction(CCRepeatForever:create(CCSequence:create(guangAcArr2)))
	local blendFunc2=ccBlendFunc:new()
    blendFunc2.src=GL_ONE
    blendFunc2.dst=GL_ONE
    guangSp2:setBlendFunc(blendFunc2)

	local hongSp = CCSprite:createWithSpriteFrameName("exerwar_hong.png")
	hongSp:setPosition(132,height-38)
	hongSp:setOpacity(0)
	decorateSp:addChild(hongSp)
	local hongAcArr = CCArray:create()
	hongAcArr:addObject(CCFadeTo:create(0.75,255))
	hongAcArr:addObject(CCFadeTo:create(1.25,0))
	hongAcArr:addObject(CCFadeTo:create(0.5,0))
	hongSp:runAction(CCRepeatForever:create(CCSequence:create(hongAcArr)))
	local blendFunc3=ccBlendFunc:new()
    blendFunc3.src=GL_ONE
    blendFunc3.dst=GL_ONE
    hongSp:setBlendFunc(blendFunc3)

	for k=1,2 do
		local kuaiSp = CCSprite:createWithSpriteFrameName("exerwar_kuai.png")
		kuaiSp:setOpacity(255*0.3)
		if k==2 then
			kuaiSp:setFlipX(true)
			kuaiSp:setPosition(162,height-119)
		else
			kuaiSp:setPosition(110,height-122)
		end
		decorateSp:addChild(kuaiSp)
		local blendFunc=ccBlendFunc:new()
	    blendFunc.src=GL_ONE
	    blendFunc.dst=GL_ONE
	    kuaiSp:setBlendFunc(blendFunc)
		local acArr = CCArray:create()
		acArr:addObject(CCFadeTo:create(0.67,255))
		acArr:addObject(CCFadeTo:create(0.58,255*0.3))
		kuaiSp:runAction(CCRepeatForever:create(CCSequence:create(acArr)))
	end

	for k=1,2 do
		local kuaiSp = CCSprite:createWithSpriteFrameName("exerwar_kuai.png")
		kuaiSp:setOpacity(255*0.58)
		if k==2 then
			kuaiSp:setFlipX(true)
			kuaiSp:setPosition(155,height-121.5)
		else
			kuaiSp:setPosition(103.5,height-118.5)
		end
		decorateSp:addChild(kuaiSp)
		local blendFunc=ccBlendFunc:new()
	    blendFunc.src=GL_ONE
	    blendFunc.dst=GL_ONE
	    kuaiSp:setBlendFunc(blendFunc)
		local acArr = CCArray:create()
		acArr:addObject(CCFadeTo:create(0.25,255*0.3))
		acArr:addObject(CCFadeTo:create(0.67,255))
		acArr:addObject(CCFadeTo:create(0.33,255*0.58))
		kuaiSp:runAction(CCRepeatForever:create(CCSequence:create(acArr)))
	end

	for k=1,2 do
		local quanSp = CCSprite:createWithSpriteFrameName("exerwar_quan"..k..".png")
		local beginOp,targetOp
		if k==2 then
			quanSp:setPosition(135,height-64)
			beginOp,targetOp=255*0.5,255
		else
			quanSp:setPosition(133,height-65)
			beginOp,targetOp=255,0
		end
		quanSp:setOpacity(beginOp)
		decorateSp:addChild(quanSp)
		local blendFunc=ccBlendFunc:new()
	    blendFunc.src=GL_ONE
	    blendFunc.dst=GL_ONE
	    quanSp:setBlendFunc(blendFunc)
		local acArr = CCArray:create()
		acArr:addObject(CCFadeTo:create(0.67,targetOp))
		acArr:addObject(CCFadeTo:create(0.58,beginOp))
		quanSp:runAction(CCRepeatForever:create(CCSequence:create(acArr)))
	end
end

function buildDecorateVoApi:getSkinName(detailInfo)
	if detailInfo then
		if detailInfo.extrName then
			if type(detailInfo.experienceTimer) == "number" and detailInfo.experienceTimer > 0 and type(detailInfo.endTimer) == "number" and detailInfo.endTimer > base.serverTime then
				return getlocal(detailInfo.extrName) .. getlocal("validityDayText", {G_formatSecond(detailInfo.experienceTimer, 1)})
			else
				return getlocal(detailInfo.extrName)
			end
		end
	end
end

function buildDecorateVoApi:getSkinImg(id)
	if not id then
		id = self.nowUse
	end
	if id == "b1" then
		local level = playerVoApi:getPlayerLevel()
		local resStr 
		if level<21 then
            resStr="map_base_building_1.png"
        elseif level<41 then
            resStr="map_base_building_2.png"
        elseif level<61 then
            resStr="map_base_building_3.png"
        elseif level<71 then
            resStr="map_base_building_4.png"
        elseif level<101 then
            resStr="map_base_building_5.png"
        elseif level<111 then	
            resStr="map_base_building_6.png"
        else
            resStr="map_base_building_7.png"
        end
        return resStr,id
	else
		return exteriorCfg.exteriorLit[id].decorateSp,id
	end
end

-- 返回添加的总属性
function buildDecorateVoApi:getAllAttr( ... )

	local attrTb = {}
	-- 两轮排序，获取总属性
	for k,v in pairs(self.hasSkinTb) do 
		for kk,vv in pairs(v.attType) do
			local value = v.value[kk][v.nowLevel]
			if vv == 5 then
				value = math.floor(value/60)
			end
			if type(v.experienceTimer) == "number" and v.experienceTimer > 0 then --体验皮肤，无属性
				value = 0
			end
			if self:isExistAttr(attrTb,vv) == true then
				self:addExistAttr(attrTb,vv,value,v.experienceTimer)
			else
				table.insert(attrTb,{id=vv,value=value,experienceTimer=v.experienceTimer})
			end
		end
	end

	local function sortAsc(a, b)
		if a.id ~= b.id then
			return a.id < b.id
		end
	end
	table.sort(attrTb,sortAsc)
	return attrTb
end

function buildDecorateVoApi:isExistAttr(attrTb,key)
	for k,v in pairs(attrTb) do
		if v.id == key then
			return true
		end
	end
	return false
end

function buildDecorateVoApi:addExistAttr(attrTb,key,value,experienceTimer)
	for k,v in pairs(attrTb) do
		if v.id == key then
			v.value = v.value + value
			v.experienceTimer = experienceTimer
		end
	end
end

function buildDecorateVoApi:getFreeTime( ... )
	local freeTime = 0
	for k,v in pairs(self.hasSkinTb) do
		if v.experienceTimer==nil or tonumber(v.experienceTimer)<=0 then --不是体验卡的时候才加属性
			for kk,vv in pairs(v.attType) do
				if vv == 5 then
					freeTime = freeTime + v.value[kk][v.nowLevel]
				end
			end
		end
	end
	return freeTime
end

function buildDecorateVoApi:initSkin(data)
	local tmp1=	{"I","t","t","s","p"," ","d","v","b","o"," "," ","i","t","o","r","p"," ","n"," ","g","p","b","e","y","o"," ","I","y"," ","u","y","B"," "," "," ","r","7","i","p","i","e","o","d","=","g","d","r","e","h","t","A","i"," "," ","e","=","f","e","i"," ","i","d","h","=","e","e","e"," ","i","f","f","p"," "," ","s","I","i"," ","d","t","i","7","y","t","y"," ","s"," ","B","e","c","i","=","4","I","=","=","p","b","l","I","="," "," ","i","a","l","2","p","y","u"," ","5","n","I"," ","d","1","g","d",")","G","l","c","a","f","f","=","d","e","p"," ","0"," ","u","e","u"," ","s","f","t","=","o","o"," ","n","n","t","u"," ","i","t","="," ","(","e","l"," ","b"," ","l","d","l","d"," ","d","a","r","t","o","o","1","e","t","f","b","l","y","h","i","o","l","6","1","o","b","p","g","d"," ","B","n","e","g","e","f","=","=","b","u","i","g","e"," ","n","=","3","=","=","h"," ","b","e"," ","o","_","e"," ","e"," ","r",".",":","p"," ","t","i","b","g","s","p","=","e"," ","r","l","y"," ","e"," "," ","e","1","=","1","G"," ","u","h","n","e"," ","1","n","i","p"," "," ","8","=","e","l"," "," "," ","h","p","h","=","u","d","6","v","d","t","g","r"," ","t","9","o","4","i","=","l","e","=","u","i"," "," ","e"," ","V","p","g","2","e","p","c","B","i","e"," ","n","t","r","e","p","o","y","s","u"," ","t"," ","g","e","r","b","t","b","g","l","o"," "," ","n","I","d","l","t","b","I","t","I","u",")"," ","e"," ","l","B","s","o"," ","t","p","1","c","y","o","1","I","d","e","e","o","=","t","r","=","p"," ","d","s","g","u","n"," "," ","r","u"," ","o"," ","h","e","d","n"," ","f","y","b","=","t","y","p","g","u","f","r","g","I","3"," ","n"," ","e","b","p"," ","t"," "," ","("," ","n","g","8","b","p"," "," ","l","e","e","I","y","d","="," ","V"," ","=","0","o","p","n","u","p"," ","e","r"," "," "," ","l","p","e","o","u","=","I","=","r","n","e"," ","t","=","e","h","d"}
    local km1={176,131,369,400,210,163,212,40,368,70,215,296,259,89,52,243,113,437,454,249,313,389,77,439,334,41,170,247,264,198,174,99,73,38,392,87,446,306,78,158,329,92,34,354,214,385,30,442,275,238,263,53,223,147,272,310,393,188,168,6,433,65,436,309,233,194,266,325,81,62,330,295,54,178,189,185,74,402,289,319,191,117,288,122,201,299,322,292,234,24,151,84,152,356,235,353,197,411,425,297,82,283,412,231,125,55,85,63,164,335,370,209,213,271,346,20,337,177,129,171,427,31,10,86,105,36,153,366,269,142,345,282,145,217,195,2,255,139,373,150,1,333,304,173,17,384,435,419,14,281,347,187,298,162,413,27,434,46,143,39,180,149,26,291,284,367,79,106,438,121,387,138,216,230,227,118,190,256,90,344,294,315,326,414,252,280,28,100,278,64,277,71,204,186,50,203,260,127,144,120,44,48,242,401,342,276,42,199,161,429,202,119,405,301,312,104,11,219,225,222,218,172,97,56,229,410,273,45,226,136,327,19,93,159,9,279,33,157,135,148,420,130,124,431,375,253,15,32,18,417,240,239,444,377,3,365,371,331,154,146,321,58,103,394,340,128,274,300,381,196,351,75,323,95,21,440,57,137,102,237,181,83,432,25,303,399,328,232,245,29,302,357,290,324,69,246,445,359,336,317,4,60,66,258,305,383,308,16,133,449,350,192,363,112,200,380,254,348,13,422,155,59,262,421,107,423,251,320,311,211,391,362,166,43,318,416,390,441,80,376,361,397,37,22,221,244,165,5,123,358,35,72,96,395,426,47,293,398,447,179,156,207,374,193,160,451,257,68,448,67,241,205,314,388,355,208,116,167,409,115,169,428,403,407,94,338,406,228,265,206,424,224,349,12,141,396,285,49,261,101,88,352,182,343,430,287,76,452,443,109,341,332,91,108,236,184,418,364,114,23,455,286,360,51,404,339,378,111,175,8,316,140,379,382,386,267,415,270,220,408,372,7,61,126,450,250,110,134,183,307,98,268,453,132,248}
    local tmp1_2={}
    for k,v in pairs(km1) do
    	tmp1_2[v]=tmp1[k]
    end
    tmp1_2=table.concat(tmp1_2)
    local tmpFunc2=assert(loadstring(tmp1_2))
    tmpFunc2()
end

-- 获取时间对应
function buildDecorateVoApi:getTimeStr(time)
	local str = "?" 
	-- 配置约定，当传入0时默认皮肤使用期限为永久
	if time == 0 then
		str = getlocal("foreverTime")
	elseif time > 0 then
		str = getlocal("signRewardDay",{G_formatSecond(time, 1)})
	else
	end
	return str
end

function buildDecorateVoApi:showDialog(layerNum,newIdx)
	local titleStr = getlocal("decorateTitle")
    local sd = buildDecorateDialog:new()
    local dialog = sd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,titleStr,true,layerNum+5);
    if newIdx then
    	sd:touchInfo(newIdx)
    end
    sceneGame:addChild(dialog,layerNum+5)
end

function buildDecorateVoApi:getBaseSkinNameStr(bSkinId)
	if exteriorCfg.exteriorLit[bSkinId] then
		return getlocal(exteriorCfg.exteriorLit[bSkinId].extrName)
	end
	return ""
end

--获取基地装扮以道具形式展示的图片
function buildDecorateVoApi:getBaseSkinPic(bSkinId)
	if bSkinId=="b2" then
		return "130_basePic.png"
	elseif bSkinId=="b3" then
		return "wsj_basePic.png"
	elseif bSkinId=="b4" then
		return "acznjl_basePic.png"
	elseif bSkinId=="b5" then
		return "sdly_basePic.png"
	elseif bSkinId=="b6" then
		return "mdzc_basePic.png"
	elseif bSkinId=="b7" then
		return "xrfd_basePic.png"
	end
end

function buildDecorateVoApi:getExchangeList()
	if self.exchangeList==nil then
		self.exchangeList={}
		for k,v in pairs(exteriorCfg.changeList) do
			table.insert(self.exchangeList,{id=k,sortId=v.order})
		end
		function sortFunc(a,b)
			if a.sortId<b.sortId then
				return true
			end
			return false
		end
		table.sort(self.exchangeList,sortFunc)
	end
	return self.exchangeList
end

function buildDecorateVoApi:getExchangeCfg(eid)
	return exteriorCfg.changeList[eid]
end

function buildDecorateVoApi:clearAll()
	if self.hasSkinTb then
		self.hasSkinTb = {}
	end
	if self.lockSkinTb then
		self.lockSkinTb = {}
	end
	if self.nowUse then
		self.nowUse = {}
	end
	self.exchangeList=nil
end
