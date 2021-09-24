tankWarehouseScene=
{
	bgLayer=nil,
	clayer=nil,
	sceneSp=nil,
	touchArr={},
	multTouch=false,
	firstOldPos,
	secondOldPos,
	startPos=ccp(0,0),
	topPos=ccp(0,0),
	sceneScale=0.7,
	isMoving=false,
	isZooming=false,
	autoMoveAddPos,
	zoomMidPosForWorld,
	zoomMidPosForSceneSp,
	touchEnable=true,
	isMoved=false, 
	
	closeBtn=nil,
	beforeHideIsShow=false, 
	isShowed=false,
	lastTouchDownPoint=ccp(0,0),
	touchEnabledSp=nil,
	tanksSpTab={},
	tankWithBulletAnim={[10145]=1,[10144]=1,[10143]=1}, --不需要第一帧炮管图片（电磁炮系列）
	initFlag=false,							--初始化标识，用于判断新坦克加进来
	oldTanks={},
	newTanks={},
}

function tankWarehouseScene:show()
	self.bgLayer=CCLayer:create()
	self.clayer=CCLayer:create()
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("scene/tankWarehouse.plist")
	spriteController:addTexture("scene/tankWarehouse.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	self.clayer:setPosition(self.startPos)
	self.bgLayer:addChild(self.clayer,3)
	
	self.clayer:setTouchEnabled(true)
	local function tmpHandler(...)
		return self:touchEvent(...)
	end

	self.clayer:registerScriptTouchHandler(tmpHandler,false,-52,true)
	self.clayer:setTouchPriority(-52)
	
	local function close()
		PlayEffect(audioCfg.mouseClick)
		return self:close()
	end
	local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
	closeBtnItem:setPosition(0, 0)
	closeBtnItem:setAnchorPoint(CCPointMake(0,0))
	closeBtnItem:registerScriptTapHandler(close)

	self.closeBtn = CCMenu:createWithItem(closeBtnItem)
	self.closeBtn:setTouchPriority(-54)
	self.closeBtn:setPosition(ccp(G_VisibleSize.width-closeBtnItem:getContentSize().width,G_VisibleSize.height-closeBtnItem:getContentSize().height))
	self.bgLayer:addChild(self.closeBtn,4)

	sceneGame:addChild(self.bgLayer,3)
	self.bgLayer:setTouchPriority(-51)
	
	local function touch()
	end
	self.touchEnabledSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)
	self.touchEnabledSp:setAnchorPoint(ccp(0,0))
	self.touchEnabledSp:setPosition(self.startPos)
	self.touchEnabledSp:setIsSallow(true)
	self.touchEnabledSp:setTouchPriority(-50)
	self.bgLayer:addChild(self.touchEnabledSp,3)
	self.touchEnabledSp:setOpacity(0)

	self.isShowed=true
	local function refreshinitTanks(event,data)
		self:initTanks()
	end
	refreshinitTanks()
	self.refreshinitTanks = refreshinitTanks
	eventDispatcher:addEventListener("tankWarehouseScene.initTanks",self.refreshinitTanks)
end

function tankWarehouseScene:touchEvent(fn,x,y,touch)
	if(self.clayer==nil or tolua.cast(self.clayer,"CCLayer")==nil)then
		do return end
	end
	if fn=="began" then
		if self.touchEnable==false or SizeOfTable(self.touchArr)>=2 or newGuidMgr:isNewGuiding()==true then
			return 0
		end
		self.isMoved=false
		self.touchArr[touch]=touch
		local touchIndex=0
		for k,v in pairs(self.touchArr) do
			local temTouch= tolua.cast(v,"CCTouch")
			if self and temTouch then
				if touchIndex==0 then
					self.firstOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
				else
					self.secondOldPos=CCDirector:sharedDirector():convertToGL(temTouch:getLocationInView())
				end
			end
			touchIndex=touchIndex+1
		end
		if touchIndex==1 then
			self.secondOldPos=nil
			self.lastTouchDownPoint=self.firstOldPos
		end
		if SizeOfTable(self.touchArr)>1 then
			self.multTouch=true
		else
			self.multTouch=false
		end
		return 1
	elseif fn=="moved" then
		if self.touchEnable==false then
			do return end
		end
		self.isMoved=true
		if self.multTouch==true then --双点触摸

		else --单点触摸
			local curPos=CCDirector:sharedDirector():convertToGL(touch:getLocationInView())
			local moveDisPos=ccpSub(curPos,self.firstOldPos)
			local moveDisTmp=ccpSub(curPos,self.lastTouchDownPoint)
			if (math.abs(moveDisTmp.y)+math.abs(moveDisTmp.x))<3 then
				self.isMoved=false
				do return end
			end
			self.autoMoveAddPos= ccp((curPos.x-self.firstOldPos.x)*3,(curPos.y-self.firstOldPos.y)*3)
			local tmpPos=ccpAdd(ccp(self.clayer:getPosition()),moveDisPos)
			self.clayer:setPosition(tmpPos)
			self:checkBound()
			self.firstOldPos=curPos
			self.isMoving=true
		end
	elseif fn=="ended" then
		if self.touchEnable==false then
			do
				return
			end
		end
		self.isMoved=false
		if self.touchArr[touch]~=nil then
			self.touchArr[touch]=nil
			local touchIndex=0
			for k,v in pairs(self.touchArr) do
				if touchIndex==0 then
					self.firstOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
				else
					self.secondOldPos=CCDirector:sharedDirector():convertToGL(v:getLocationInView())
				end
				touchIndex=touchIndex+1
			end
			if touchIndex==1 then
				self.secondOldPos=nil
			end
			if SizeOfTable(self.touchArr)>1 then
				self.multTouch=true
			else
				self.multTouch=false
			end
		end
		if self.isMoving==true then
			self.isMoving=false
			local tmpToPos=ccpAdd(ccp(self.clayer:getPosition()),self.autoMoveAddPos)
			tmpToPos=self:checkBound(tmpToPos)

			local ccmoveTo=CCMoveTo:create(0.15,tmpToPos)
			local cceaseOut=CCEaseOut:create(ccmoveTo,3)
			self.clayer:runAction(cceaseOut)
		end
	else
		self.touchArr=nil
		self.touchArr={}
	end
end

function tankWarehouseScene:checkBound(pos)
	local tmpPos
	if pos==nil then
		tmpPos= ccp(self.clayer:getPosition())
	else
		tmpPos=pos
	end
	if tmpPos.x>0 then
		tmpPos.x=0
	elseif tmpPos.x<(G_VisibleSize.width - self.moveWidth) then
		tmpPos.x=G_VisibleSize.width - self.moveWidth
	end
	if tmpPos.y>0 then
		tmpPos.y=0
	elseif tmpPos.y<(G_VisibleSize.height - self.sceneHeight*self.sceneScale) then
		tmpPos.y=G_VisibleSize.height - self.sceneHeight*self.sceneScale
	end
	if pos==nil then
		self.clayer:setPosition(tmpPos)
	else
		return tmpPos
	end
end

function tankWarehouseScene:focusOn()
	self.clayer:setPosition(ccp(0,G_VisibleSize.height - self.sceneHeight*self.sceneScale))
	self:checkBound()
end

function tankWarehouseScene:initTanks()
	if(self.bgLayer==nil)then
		do return end
	end
	if self.tanksSpTab==nil then
		self.tanksSpTab={}
	end
	local tanksTb = tankVoApi:getTanksInWarehouse()
	local rowTb={}
	local lineTb={}
	local positionTb={}
	for k,v in pairs(tanksTb) do
		if(tankCfg[k].line and tankCfg[k].line>0)then
			lineTb[tankCfg[k].line]=1
			if(positionTb[tankCfg[k].line]==nil)then
				positionTb[tankCfg[k].line]={}
			end
		end
		if(tankCfg[k].row and tankCfg[k].row>0)then
			rowTb[tankCfg[k].row]=1
			if(positionTb[tankCfg[k].line][tankCfg[k].row]==nil)then
				positionTb[tankCfg[k].line][tankCfg[k].row]={1,{k},{tankCfg[k].line,tankCfg[k].row}}
			else
				positionTb[tankCfg[k].line][tankCfg[k].row][1]=positionTb[tankCfg[k].line][tankCfg[k].row][1] + 1
				table.insert(positionTb[tankCfg[k].line][tankCfg[k].row][2],k)
				table.sort(positionTb[tankCfg[k].line][tankCfg[k].row][2])
			end
		end
	end
	local lineNum=0
	local lineMap={}
	for line,v in pairs(lineTb) do
		table.insert(lineMap,line)
		lineNum=lineNum + 1
	end
	table.sort(lineMap)
	for k,line in pairs(lineMap) do
		lineTb[line]=k
	end
	local rowNum=0
	local rowMap={}
	for row,v in pairs(rowTb) do
		table.insert(rowMap,row)
		rowNum=rowNum + 1
	end
	table.sort(rowMap)
	for k,row in pairs(rowMap) do
		rowTb[row]=k
	end
	local wallSp1=CCSprite:createWithSpriteFrameName("warehouseWall1.png")
	local wallSp2=CCSprite:createWithSpriteFrameName("warehouseWall2.png")
	local wallHeight=wallSp1:getContentSize().height
	local wallWidth=wallSp2:getContentSize().width

	if(self.sceneSp and self.sceneSp:getParent())then
		self.sceneSp:removeFromParentAndCleanup(true)
	end
	self.sceneSp=CCSprite:createWithSpriteFrameName("BlackBg.png")
	self.sceneSp:setAnchorPoint(ccp(0,0))
	self.sceneSp:setPosition(ccp(0,0))
	self.clayer:addChild(self.sceneSp,1)

	local tmpSp=CCSprite:createWithSpriteFrameName("warehouseLand.png")
	local sceneSingleSize=tmpSp:getContentSize()
	self.moveWidth=math.max(sceneSingleSize.width*self.sceneScale*rowNum + wallWidth/2*self.sceneScale,G_VisibleSizeWidth)
	self.moveHeight=math.max(sceneSingleSize.height*self.sceneScale*lineNum + wallHeight*self.sceneScale,G_VisibleSizeHeight)
	rowNum=math.max(rowNum,math.ceil(G_VisibleSizeWidth/sceneSingleSize.width/self.sceneScale))
	lineNum=math.max(lineNum,math.ceil(G_VisibleSizeHeight/sceneSingleSize.height/self.sceneScale))
	self.sceneWidth=sceneSingleSize.width*rowNum + wallWidth
	self.sceneHeight=sceneSingleSize.height*lineNum + wallHeight
	self.sceneSp:setScale(self.sceneScale)
	self.clayer:setContentSize(CCSizeMake(self.sceneWidth,self.sceneHeight))
	self.touchEnabledSp:setContentSize(CCSizeMake(self.sceneWidth,self.sceneHeight))
	for i=1,lineNum do
		for j=1,rowNum + 1 do
			local sceneSpTmp=CCSprite:createWithSpriteFrameName("warehouseLand.png")
			sceneSpTmp:setAnchorPoint(ccp(0,0))
			sceneSpTmp:setPosition(ccp(wallWidth/2 + (j - 1)*sceneSingleSize.width,(i - 1)*sceneSingleSize.height))
			self.sceneSp:addChild(sceneSpTmp)
		end
	end

	local sceneTexture=spriteController:getTexture("scene/tankWarehouse.png")
	local sceneBatchNode=CCSpriteBatchNode:createWithTexture(sceneTexture,100)
	self.sceneSp:addChild(sceneBatchNode)
	--两行之间的栅栏,算出一排有多少个栅栏，如果数目不整的话向下取整，设置scaleX
	local tmpFence=CCSprite:createWithSpriteFrameName("warehouseFence.png")
	local fenceWidth=tmpFence:getContentSize().width
	local fenceNum=math.floor(self.sceneWidth/fenceWidth)
	local fenceScale=self.sceneWidth/fenceNum/fenceWidth
	-- 每一排画栅栏,最上面一排不画，因为是围墙
	for i=1,lineNum do
		if(i~=lineNum)then
			local fenceY=sceneSingleSize.height*i
			for j=1,fenceNum do
				local fence=CCSprite:createWithSpriteFrameName("warehouseFence.png")
				fence:setScaleX(fenceScale)
				fence:setAnchorPoint(ccp(0,0.5))
				fence:setPosition(fenceWidth*fenceScale*(j - 1) + wallWidth/2,fenceY)
				sceneBatchNode:addChild(fence)
			end
		end
	end
	--左边的围墙，根据高度算出有多少个围墙，如果数目不整的话向下取整，设置scaleY
	local wallHeight=wallSp2:getContentSize().height*0.73	--因为墙的侧视图包含了墙侧面的长度，所以要把这段距离去掉，原图中这个比例大概是0.73
	local wallNum=math.floor((self.sceneHeight - wallHeight*0.27)/wallHeight)
	local wallScale=(self.sceneHeight - wallHeight*0.27)/wallNum/wallHeight
	for i=1,wallNum do
		local wallY=wallHeight*wallScale*(i - 1)
		local wallSp2=CCSprite:createWithSpriteFrameName("warehouseWall2.png")
		wallSp2:setAnchorPoint(ccp(0,0))
		wallSp2:setScaleY(wallScale)
		wallSp2:setPosition(0,wallY)
		sceneBatchNode:addChild(wallSp2,wallNum - i + 1)	--越靠上的墙在越下层
	end
	--上面的围墙，一个围墙对一块场地，单独算scaleX
	local wallWidth=wallSp1:getContentSize().width
	local wallScale=sceneSingleSize.width/wallWidth
	for i=1,rowNum + 1 do
		local wallSp1=CCSprite:createWithSpriteFrameName("warehouseWall1.png")
		wallSp1:setAnchorPoint(ccp(0,1))
		wallSp1:setScaleX(wallScale)
		wallSp1:setPosition(wallSp2:getContentSize().width/2 + wallWidth*wallScale*(i - 1),self.sceneHeight)
		sceneBatchNode:addChild(wallSp1)
		local tankLv=rowMap[i]
		if(tankLv)then
			local lvSp=CCSprite:createWithSpriteFrameName("warehouseLv"..tankLv..".png")
			if(lvSp)then
				lvSp:setPosition(wallSp2:getContentSize().width/2 + wallWidth*wallScale*(i - 0.5),self.sceneHeight - 35)
				sceneBatchNode:addChild(lvSp)
			end
		end
	end
	self.tanksSpTab={}
	local startY=self.sceneHeight - wallSp1:getContentSize().height
	for k,v in pairs(tanksTb) do
		local skinPrefix = tankSkinVoApi:getEquipSkinByTankId(k) and tankSkinVoApi:getEquipSkinByTankId(k).."_" or "" 
		if v[1]~=0 then
			local strtank=skinPrefix.."t"..GetTankOrderByTankId(k).."_1.png"
			local strtank1=skinPrefix.."t"..GetTankOrderByTankId(k).."_1_1.png"
			if tolua.cast(self.clayer:getChildByTag(k),"CCNode")==nil then
				local function showSkinDetail()
					tankSkinVoApi:showTankSkinDialog(k, 4)
				end
				local flag=tankSkinVoApi:isTankSkinOpen(k) --该坦克皮肤有没有开放

				local function pbUIhandler()
					if self.isMoved==true or self.touchEnable==false then
						do return end
					end
					if G_checkClickEnable()==false then
						do return end
					else
						base.setWaitTime=G_getCurDeviceMillTime()
					end
					local newIcon=tolua.cast(self.sceneSp:getChildByTag(tonumber(k)*10 + 1),"CCSprite")
					if(newIcon)then
						newIcon:removeFromParentAndCleanup(true)
					end
					if(self.newTanks[k])then
						self.oldTanks[k]=1
						self.newTanks[k]=nil
					end
					if flag==true then
						showSkinDetail()
					else
						tankInfoDialog:create(sceneGame,k,5)
					end
				end
                -- print("strtank====",strtank,GetTankOrderByTankId(k))
				local tankSp =LuaCCSprite:createWithSpriteFrameName(strtank,pbUIhandler)
				tankSp:setTag(k)
				tankSp:setAnchorPoint(ccp(0.5,0.5))
				local line=tankCfg[k].line
				local row=tankCfg[k].row
				local xIndex=rowTb[row]
				local yIndex=lineTb[line]
				local childIndex=2
				local posX,posY
				if(positionTb[line][row][1]==1)then
					posX=wallSp2:getContentSize().width/2 + sceneSingleSize.width*(xIndex - 0.5)
					posY=startY - sceneSingleSize.height*(yIndex - 0.5)
				else
					local index
					for kk,id in pairs(positionTb[line][row][2]) do
						if(id==k)then
							index=kk
							break
						end
					end
					childIndex=childIndex + index
					posX=wallSp2:getContentSize().width/2 + sceneSingleSize.width*(xIndex - 0.5)
					--策划说一个格子最多放俩坦克，根据公式计算摆放的效果不好，所以特殊写坐标，只判断两种情况,如果出现一个格子放两个以上坦克的情况，让陶也改配置
					if(index==1)then
						posY=startY - sceneSingleSize.height*(yIndex - 1) - sceneSingleSize.height/3
					else
						posY=startY - sceneSingleSize.height*(yIndex - 1) - sceneSingleSize.height/4*3
					end
				end
				--地库里面的坦克，homex和homey是用来计算偏移的，不是实际坐标，跟外面的坦克不同
				--因为坦克模型形状不一样，所以坦克图的中心并不一定是理想的摆放位置，所以需要缩放
				tankSp:setPosition(posX + tonumber(tankCfg[k].homex),posY + tonumber(tankCfg[k].homey))
				self.sceneSp:addChild(tankSp,childIndex)
				tankSp:setTouchPriority(-52)
				tankSp:setIsSallow(false)
				self.tanksSpTab[k]=tankSp

				--if GetTankOrderByTankId(k)<=15 and GetTankOrderByTankId(k)~=33 then
				local tankSp1=CCSprite:createWithSpriteFrameName(strtank1);
				if tankSp1~=nil and self.tankWithBulletAnim[GetTankOrderByTankId(k)] ==nil then
					tankSp1:setPosition(getCenterPoint(tankSp))
					tankSp:addChild(tankSp1)
				end
				--end
									
				local numLb= GetTTFLabel(v[1],24);
				local lbSpBg4 =LuaCCScale9Sprite:createWithSpriteFrameName("IconBgNum.png",CCRect(5, 5, 1, 1),function(...) end)
				lbSpBg4:setContentSize(CCSizeMake(math.max(numLb:getContentSize().width+12,40),numLb:getContentSize().height+6))
				lbSpBg4:setAnchorPoint(ccp(0,0.5))
				lbSpBg4:setPosition(ccp(posX + 30,posY - 25))
				self.sceneSp:addChild(lbSpBg4,5)
				lbSpBg4:setTouchPriority(0)
				numLb:setPosition(getCenterPoint(lbSpBg4))
				lbSpBg4:addChild(numLb)

				local parkingSp=CCSprite:createWithSpriteFrameName("warehouseParking.png")
				parkingSp:setPosition(ccp(posX,posY))
				self.sceneSp:addChild(parkingSp,1)

				if(self.newTanks[k])then
					local newIcon=CCSprite:createWithSpriteFrameName("IconTip.png")
					newIcon:setTag(k*10 + 1)
					newIcon:setAnchorPoint(ccp(0,0.5))
					newIcon:setPosition(ccp(posX + 30,posY + 35))
					self.sceneSp:addChild(newIcon,5)
				end
				if flag==true then --该坦克开放了皮肤
					local iconWidth=50
					local skinTipSp = LuaCCSprite:createWithSpriteFrameName("tskinTipPic.png",showSkinDetail)
					skinTipSp:setScale(iconWidth/skinTipSp:getContentSize().width)
					local tipPosY = posY+sceneSingleSize.height/4
					skinTipSp:setPosition(posX-sceneSingleSize.width/2+iconWidth/2+15,tipPosY)
					skinTipSp:setTouchPriority(-53)
					self.sceneSp:addChild(skinTipSp,2)
				end
			end
		end
	end
end

function tankWarehouseScene:setShow()
	base:setWait()
	if self.bgLayer==nil then
		self:show()
	else
		local function refreshinitTanks(event,data)
			self:initTanks()
		end
		refreshinitTanks()
		self.refreshinitTanks = refreshinitTanks
		eventDispatcher:addEventListener("tankWarehouseScene.initTanks",self.refreshinitTanks)
		self.bgLayer:setPositionX(0)
	end
	base.allShowedCommonDialog=base.allShowedCommonDialog+1
	table.insert(base.commonDialogOpened_WeakTb,self)
	if self.touchEnabledSp then
		self.touchEnabledSp:setPosition(self.startPos)
	end
	self:focusOn()
	self.touchEnable=true
	self.isMoved=false 
	self.bgLayer:setVisible(false)
	self.isShowed=true
	local fadeIn=CCFadeOutDownTiles:create(0.5,CCSizeMake(16,12))
	local back=fadeIn:reverse()

	local function callBack()
		self.bgLayer:setVisible(true)
	end
	local callFunc=CCCallFunc:create(callBack)
	local carray=CCArray:create()
	carray:addObject(callFunc)
	local spawn=CCSpawn:create(carray)

	local function hideUIHandler()
		self.bgLayer:stopAllActions()
		if portScene.clayer~=nil then
			if sceneController.curIndex==0 then
				portScene:setHide()
			elseif sceneController.curIndex==1 then
				mainLandScene:setHide()
			elseif sceneController.curIndex==2 then
				worldScene:setHide()
			end
			mainUI:setHide()
		end
		base:cancleWait()
		if(otherGuideMgr.isGuiding and otherGuideMgr.curStep==1)then
			otherGuideMgr:toNextStep()
		end
	end
	local hideUIFunc=CCCallFunc:create(hideUIHandler)
	local seq=CCSequence:createWithTwoActions(spawn,hideUIFunc)
	self.bgLayer:runAction(seq)
end

function tankWarehouseScene:setHide(hasAnim)
	self.isShowed=false
	base.allShowedCommonDialog=base.allShowedCommonDialog-1
	if base.allShowedCommonDialog<0 then
		base.allShowedCommonDialog=0
	end
	for k,v in pairs(base.commonDialogOpened_WeakTb) do
		if v==self then
			table.remove(base.commonDialogOpened_WeakTb,k)
			break
		end
	end
	if self.touchEnabledSp then
		self.touchEnabledSp:setPosition(ccp(0,10000))
	end
	if self.bgLayer~=nil then
		self.touchEnabledSp:setVisible(false)
		base:setWait()
		if self.touchEnable==false then
			self.beforeHideIsShow=false
		else
			self.beforeHideIsShow=true
		end
		self.touchEnable=false
		
		if hasAnim==false then
			self.bgLayer:setVisible(false)
			self.bgLayer:setPositionX(999333)
			base:cancleWait()
			base:cancleNetWait()
		else
			self.bgLayer:stopAllActions()
			self.bgLayer:setVisible(false)
			self.bgLayer:setPositionX(999333)
			base:cancleWait()
			if base.allShowedCommonDialog==0 then
				if portScene.clayer~=nil then
					if sceneController.curIndex==0 then
						portScene:setShow()
					elseif sceneController.curIndex==1 then
						mainLandScene:setShow()
					elseif sceneController.curIndex==2 then
						worldScene:setShow()
					end
					mainUI:setShow()
				end
			end
		end
	end
end

function tankWarehouseScene:initOldTanks()
	if(self.initFlag==false)then
		self.initFlag=true
		self.oldTanks=tankVoApi:getAllTanksInWarehouse()
	end
end

function tankWarehouseScene:checkNewTank(tankID)
	if(self.initFlag and self.oldTanks[tankID]==nil)then
		self.newTanks[tankID]=1
	end
end

function tankWarehouseScene:close()
	if self.refreshinitTanks then
	    eventDispatcher:removeEventListener("tankWarehouseScene.initTanks",self.refreshinitTanks)
	    self.refreshinitTanks = nil
    end
	self:setHide()
end

function tankWarehouseScene:realClose()
	self:setHide()
end

function tankWarehouseScene:dispose()
	spriteController:removePlist("scene/tankWarehouse.plist")
	spriteController:removeTexture("scene/tankWarehouse.png")
	if self.touchEnabledSp then
		self.touchEnabledSp:removeFromParentAndCleanup(true)
		self.touchEnabledSp=nil
	end
	self.bgLayer=nil
	self.clayer=nil
	self.sceneSp=nil
	self.touchArr={}
	self.multTouch=false
	self.firstOldPos=nil
	self.secondOldPos=nil
	self.startPos=ccp(0,0)
	self.topPos=ccp(0,0)
	self.isMoving=false
	self.isZooming=false
	self.autoMoveAddPos=nil
	self.zoomMidPosForWorld=nil
	self.zoomMidPosForSceneSp=nil
	self.touchEnable=true
	self.isMoved=false
	self.closeBtn=nil
	self.pointerSp=nil
	self.beforeHideIsShow=false
	self.tanksSpTab={}
	self.initFlag=false
	self.oldTanks={}
	self.newTanks={}
end
