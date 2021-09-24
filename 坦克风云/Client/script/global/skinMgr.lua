--皮肤管理
skinMgr=
{
	idList={"winter2017"},			--所有皮肤的ID列表
	noticeList={},		--要进游戏后特殊通知的新皮肤的ID列表
	noticeFlagList={},				--通知过的皮肤列表标志位
	curSkin=nil,					--当前使用的皮肤
	skinDataList={},				--各个皮肤的一些数据
}

--第一次运行，初始化
function skinMgr:init()
	base:addNeedRefresh(self)
	local curSkin=self:getCurrentSkin()
	if(base.isWinter~=true)then
		for k,v in pairs(self.idList) do
			if(v=="winter2017")then
				table.remove(self.idList,k)
				break
			end
		end
		for k,v in pairs(self.noticeList) do
			if(v=="winter2017")then
				table.remove(self.noticeList,k)
				break
			end
		end
		if(curSkin=="winter2017")then
			self:setSkin(0)
		end
	end
	curSkin=self:getCurrentSkin()
	if(curSkin~=0)then
		self:addSkin(curSkin)
	end
end

function skinMgr:dispose()
	base:removeFromNeedRefresh(self)
	self.noticeFlagList={}
end

function skinMgr:tick()
	if(newGuidMgr and newGuidMgr.isGuiding or otherGuidMgr and otherGuidMgr.isGuiding)then
		do return end
	end
	if(sceneController==nil or base==nil or G_SmallDialogDialogTb==nil)then
		do return end
	end
	if(base.serverTime%5~=0)then
		do return end
	end
	if sceneController:getNextIndex()==1 and base.allShowedCommonDialog==0 and SizeOfTable(G_SmallDialogDialogTb)==0 then
		skinMgr:checkShowNewSkin()
	end
	local curSkin=self:getCurrentSkin()
	if(curSkin=="winter2017")then
		self:tickwinter2017()
	end
end

--public: 获取当前正在使用的皮肤ID
function skinMgr:getCurrentSkin()
	if(self.curSkin==nil)then
		local skinKey="skin_current"
		local localData=CCUserDefault:sharedUserDefault():getStringForKey(skinKey)
		if(localData~=nil and localData~="")then
			self.curSkin=localData
		else
			self.curSkin=0
		end
	end
	if  G_getGameUIVer()==2 then
		self.curSkin=0
	end
	return self.curSkin
end

--private: 设置当前正在使用的皮肤ID
--param skinID: 皮肤ID
function skinMgr:setCurrentSkin(skinID)
	self.curSkin=skinID
	local skinKey="skin_current"
	if(skinID==0)then
		CCUserDefault:sharedUserDefault():setStringForKey(skinKey,"")
	else
		CCUserDefault:sharedUserDefault():setStringForKey(skinKey,skinID)
	end
	CCUserDefault:sharedUserDefault():flush()
end

--private: 初始化检查
function skinMgr:checkShowNewSkin()
	local curSkin=self:getCurrentSkin()
	for k,v in pairs(self.noticeList) do
		if(self.noticeFlagList[v]==nil)then
			if(v~=curSkin)then
				if(v=="winter2017" and base.isWinter==false)then
				else
					local noticeKey="skin_notice_"..v
					local localData=CCUserDefault:sharedUserDefault():getIntegerForKey(noticeKey)
					if(localData==nil or localData==0)then
						self:showSkinTip(v)
						break
					elseif(localData==1)then
						local tsKey="skin_notice_ts_"..v
						local lastNoticeTs=CCUserDefault:sharedUserDefault():getIntegerForKey(tsKey)
						if(lastNoticeTs==nil or lastNoticeTs<G_getWeeTs(base.serverTime))then
							self:showSkinTip(v)
							break
						end
					end
				end
			end
		end
	end	
end

function skinMgr:showSkinTip(skinID,layerNum)
	if(layerNum==nil)then
		layerNum=3
	end
	smallDialog:showSkinNoticeDialog(skinID,layerNum)
end

--public: 设置某个皮肤是否已经弹出过提示了
--param skinID: 弹出提示皮肤的ID
--param noshowFlag: 是否以后不再提示
function skinMgr:noticeShowed(skinID,noShowFlag)
	if(noShowFlag)then
		self.noticeFlagList[skinID]=2
		local noticeKey="skin_notice_"..skinID
		CCUserDefault:sharedUserDefault():setIntegerForKey(noticeKey,2)
	else
		self.noticeFlagList[skinID]=1
		local noticeKey="skin_notice_"..skinID
		CCUserDefault:sharedUserDefault():setIntegerForKey(noticeKey,1)
		local noticeKey="skin_notice_ts_"..skinID
		CCUserDefault:sharedUserDefault():setIntegerForKey(noticeKey,base.serverTime)
	end
	CCUserDefault:sharedUserDefault():flush()
end

--public: 使用皮肤，并添加皮肤效果
--param skinID: 要使用的皮肤ID
function skinMgr:setSkin(skinID)
	local curSkin=self:getCurrentSkin()
	self:setCurrentSkin(skinID)
	if(curSkin~=0 or skinID==0)then
		self:clearSkin(curSkin)
	end
	self:addSkin(skinID)
	self:noticeShowed(skinID,true)
end

--private: 添加皮肤效果
--param skinID: 要添加的皮肤ID
function skinMgr:addSkin(skinID)
	if(skinID=="winter2017")then
		if(mainUI and mainUI.switchWinterSkin)then
			CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/winterskin.plist")
			mainUI:switchWinterSkin(true)
		end
		CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_seasonEffect2017",2)
		CCUserDefault:sharedUserDefault():flush()
	end
end

--private: 传id，清除当前的皮肤
--param skinID: 要清除的皮肤ID
function skinMgr:clearSkin(skinID)
	if(skinID=="winter2017")then
		if(mainUI and mainUI.switchWinterSkin)then
			mainUI:switchWinterSkin(false)
		end
		if(sceneGame and sceneGame.getChildByTag)then
			local snowEffect=tolua.cast(sceneGame:getChildByTag(1024),"CCNode")
			if(snowEffect)then
				snowEffect:stopAllActions()
				snowEffect:removeFromParentAndCleanup(true)
			end
		end
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("scene/winterskin.plist")
		CCTextureCache:sharedTextureCache():removeTextureForKey("scene/winterskin.png")
	end
end

--private: 2017冬季皮肤的tick检查，主要是下雪的逻辑
function skinMgr:tickwinter2017()
	local zeroTime=G_getWeeTs(base.serverTime)
	local timeCfg
	if(self.skinDataList["winter2017"]==nil or self.skinDataList["winter2017"]["zeroTime"]~=zeroTime)then
		timeCfg={}
		local wday=G_getFormatWeekDay()
		if(mapForSnowCfg==nil)then
			do return end
		end
		local dayCfg=mapForSnowCfg[wday]
		if(dayCfg==nil)then
			do return end
		end
		for k,v in pairs(dayCfg.beginTime) do
			local st=zeroTime + v[1]*3600 + v[2]*60
			local et=st + dayCfg.lastTime[k][1]*60
			timeCfg[k]={st,et}
		end
		self.skinDataList["winter2017"]={}
		self.skinDataList["winter2017"]["timeCfg"]=timeCfg
		self.skinDataList["winter2017"]["zeroTime"]=zeroTime
	else
		timeCfg=self.skinDataList["winter2017"]["timeCfg"]
	end
	local flag=false
	local lastTime
	for k,v in pairs(timeCfg) do
		if(base.serverTime>=v[1] and base.serverTime<v[2])then
			flag=true
			lastTime=v[2]-base.serverTime
			break
		end
	end
	if(flag==false)then
		do return end
	end
	if(sceneGame and sceneGame.getChildByTag)then
		local snowEffect=tolua.cast(sceneGame:getChildByTag(1124),"CCNode")
		if(snowEffect==nil)then
			local snowEffect = CCParticleSystemQuad:create("public/snow2.plist")--冬天效果
			snowEffect:setTag(1124)
			snowEffect.positionType=kCCPositionTypeFree
			snowEffect:setPosition(ccp(320,G_VisibleSizeHeight + 20))
			sceneGame:addChild(snowEffect,2)
			local delayTime=CCDelayTime:create(lastTime)
			local function stop()
				if(snowEffect and tolua.cast(snowEffect,"CCNode"))then
					snowEffect:stopSystem()
				end
			end
			local stopFunc=CCCallFuncN:create(stop)
			local fadeOut=CCFadeOut:create(5)
			local function removeCall()
				if(snowEffect and tolua.cast(snowEffect,"CCNode"))then
					snowEffect:removeFromParentAndCleanup(true)
					snowEffect=nil
				end
			end 
			local callFunc=CCCallFuncN:create(removeCall)
			local acArr=CCArray:create()
			acArr:addObject(delayTime)
			acArr:addObject(stopFunc)
			acArr:addObject(fadeOut)
			acArr:addObject(callFunc)
			local seq=CCSequence:create(acArr)
			snowEffect:runAction(seq)
		end
	end
end