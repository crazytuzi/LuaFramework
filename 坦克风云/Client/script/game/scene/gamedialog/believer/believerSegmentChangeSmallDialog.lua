local believerSegmentChangeSmallDialog=smallDialog:new()

function believerSegmentChangeSmallDialog:new()
	local nc={
		isCanClose=false
	}
	setmetatable(nc,self)
	self.__index=self

	return nc
end

function believerSegmentChangeSmallDialog:init(changeData,callBack,layerNum)
    spriteController:addPlist("public/believer/believerEffect3.plist")
    spriteController:addTexture("public/believer/believerEffect3.png")
    spriteController:addPlist("public/believer/believerEffect2.plist")
    spriteController:addTexture("public/believer/believerEffect2.png")
	self.isTouch=nil
	self.isUseAmi=true
	self.layerNum=layerNum

	local changeType=1 --默认是晋级
	local oldGrade=changeData.oldGrade --老大段位
	local newGrade=changeData.newGrade --新大段位
	local oldQueue=changeData.oldQueue --老小段位
	local newQueue=changeData.newQueue --新小段位
	--判断是否降阶
	if (oldGrade>newGrade) or (oldGrade==newGrade and oldQueue and newQueue and oldQueue>newQueue) then
        changeType=2
    end
    --青铜与最强王者没有小段位
	if oldGrade==1 or oldGrade==5 then
		oldQueue=nil
	end
	if newGrade==1 or newGrade==5 then
		newQueue=nil
	end

	local function tmpHandler()
		if self.isCanClose==true then
			self:close()
			if callBack then
				callBack()
			end
		end
	end
	local titleStr=""
	if changeType==1 then
		titleStr=getlocal("believer_seg_change_1")
	else
		titleStr=getlocal("believer_seg_change_2")
	end
    self.bgSize=CCSizeMake(580,300)
	local dialogBg=G_getNewDialogBg2(self.bgSize,self.layerNum,nil,titleStr,25,G_ColorWhite)
	self.bgLayer=dialogBg
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer=CCLayer:create()
	self.dialogLayer:addChild(self.bgLayer,1)
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.dialogLayer:setBSwallowsTouches(true)
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))

	local fontSize=25
	if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
		fontSize=22
	end
  	--中间箭头
  	local directSp=CCSprite:createWithSpriteFrameName("greenLeftArrow.png")
  	directSp:setAnchorPoint(ccp(0.5,0.5))
  	directSp:setPosition(ccp(self.bgSize.width/2,self.bgSize.height/2))
  	self.bgLayer:addChild(directSp)

  	--左侧蓝色圈
  	local lBorderSp=CCSprite:createWithSpriteFrameName("newKuang4.png")
  	lBorderSp:setAnchorPoint(ccp(0.5,0.5))
  	lBorderSp:setPosition(ccp(self.bgSize.width/2-142,self.bgSize.height/2))
  	self.bgLayer:addChild(lBorderSp)

  	local iconWidth=lBorderSp:getContentSize().width+30
  	--旧段位
  	local lGradeIconSp=believerVoApi:getSegmentIcon(oldGrade,oldQueue,iconWidth)
  	lGradeIconSp:setAnchorPoint(ccp(0.5,0.5))
  	lGradeIconSp:setPosition(ccp(lBorderSp:getPositionX(),lBorderSp:getPositionY()))
	self.bgLayer:addChild(lGradeIconSp)

  	local lnameLb=GetTTFLabel(believerVoApi:getSegmentName(oldGrade,oldQueue),fontSize)
  	lnameLb:setAnchorPoint(ccp(0.5,1))
  	lnameLb:setPosition(ccp(lBorderSp:getContentSize().width/2,-5))
  	lBorderSp:addChild(lnameLb)

  	--右侧蓝色圈
  	local rBorderSp=CCSprite:createWithSpriteFrameName("newKuang4.png")
  	rBorderSp:setAnchorPoint(ccp(0.5,0.5))
  	rBorderSp:setPosition(ccp(self.bgSize.width/2+142,self.bgSize.height/2))
  	self.bgLayer:addChild(rBorderSp)

  	--新段位
  	local rGradeIconSp=believerVoApi:getSegmentIcon(newGrade,newQueue,iconWidth)
  	rGradeIconSp:setAnchorPoint(ccp(0.5,0.5))
  	rGradeIconSp:setPosition(ccp(rBorderSp:getPositionX(),rBorderSp:getPositionY()))
	self.bgLayer:addChild(rGradeIconSp)

  	local rnameLb=GetTTFLabel(believerVoApi:getSegmentName(newGrade,newQueue),fontSize)
  	rnameLb:setAnchorPoint(ccp(0.5,1))
  	rnameLb:setPosition(ccp(rBorderSp:getContentSize().width/2,-5))
  	rBorderSp:addChild(rnameLb)
  	--晋级
  	if changeType==1 then
  		directSp:setVisible(false)
  		rGradeIconSp:setOpacity(0)
		local starBg=tolua.cast(rGradeIconSp:getChildByTag(101),"LuaCCScale9Sprite")  		
  		if starBg and newQueue then
  			for i=1,newQueue do
  				local starSp=tolua.cast(starBg:getChildByTag(10+i),"CCSprite")
  				if starSp then
  					starSp:setOpacity(0)
  				end
  			end
  		end
  		rnameLb:setOpacity(0)

  		local perFramet=0.08
  		local function showEffect()
  			self:playFrame(self.bgLayer,ccp(lGradeIconSp:getPositionX()+165,lGradeIconSp:getPositionY()-80),"believerquxian",8,perFramet)
  			self:playFrame(self.bgLayer,ccp(lGradeIconSp:getPositionX()+165,lGradeIconSp:getPositionY()+80),"believerquxian",8,perFramet,nil,true)
  			self:playFrame(self.bgLayer,ccp(lGradeIconSp:getPositionX()+165,lGradeIconSp:getPositionY()),"believerzhixian",8,perFramet)
  			self:playFrame(self.bgLayer,ccp(rGradeIconSp:getPositionX(),rGradeIconSp:getPositionY()),"believerBaofa",10,perFramet,8*perFramet+0.2) 
  		end
	  	local function showRGradeIconSp()
  			directSp:setVisible(true)
	  		local fadeIn1=CCFadeIn:create(0.3)
	  		local fadeIn2=CCFadeIn:create(0.3)
	  		if rGradeIconSp and rnameLb then
	  			rGradeIconSp:runAction(fadeIn1)
	  			rnameLb:runAction(fadeIn2)
  				local starBg=tolua.cast(rGradeIconSp:getChildByTag(101),"LuaCCScale9Sprite")
  				if starBg and newQueue then
		  			for k=1,newQueue,1 do
						local starSp=tolua.cast(starBg:getChildByTag(10+k),"CCSprite")
						if starSp then
							local fadeIn3=CCFadeIn:create(0.3)
							starSp:runAction(fadeIn3)
						end
					end
  				end
	  		end
	  	end

	  	local function effectEnd()
	  		self.isCanClose=true
	  	end
		local acArr=CCArray:create()
		acArr:addObject(CCDelayTime:create(0.4))
		acArr:addObject(CCCallFunc:create(showEffect))
		acArr:addObject(CCDelayTime:create(8*perFramet-0.3))
		acArr:addObject(CCCallFunc:create(showRGradeIconSp))
		acArr:addObject(CCCallFunc:create(effectEnd))
		local seq=CCSequence:create(acArr)
		rBorderSp:runAction(seq)
	else
		self.isCanClose=true
  	end

	self:show()

    local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(0,0)
	
    G_addForbidForSmallDialog(self.dialogLayer,self.bgLayer,-(self.layerNum-1)*20-3,tmpHandler)

    G_addArrowPrompt(self.bgLayer,nil,-80)

	return self.dialogLayer
end

--播放序列帧
function believerSegmentChangeSmallDialog:playFrame(target,pos,frameName,fc,ft,dt,flip,callback)
	if target==nil then
		do return end
	end
	local frameSp=CCSprite:createWithSpriteFrameName(frameName.."1.png")
  	local lieArr=CCArray:create()
	for kk=1,fc do
	    local nameStr=frameName..kk..".png"
	    local frame=CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	    lieArr:addObject(frame)
	end
	local animation=CCAnimation:createWithSpriteFrames(lieArr)
	animation:setDelayPerUnit(ft)
	local animate=CCAnimate:create(animation)
	frameSp:setAnchorPoint(ccp(0.5,0.5))
	frameSp:setPosition(pos)
	if flip then
		frameSp:setFlipY(true)
	end
	target:addChild(frameSp,5)
	local blendFunc=ccBlendFunc:new()
	blendFunc.src=GL_ONE
	blendFunc.dst=GL_ONE
	frameSp:setBlendFunc(blendFunc)
	local acArr=CCArray:create()
	acArr:addObject(animate)
	if dt then
		local delay=CCDelayTime:create(dt)
		acArr:addObject(delay)
	end
	local function playEnd()
		frameSp:removeFromParentAndCleanup(true)
		frameSp=nil
		if callback then
			callback()
		end
	end
	local func=CCCallFunc:create(playEnd)
	acArr:addObject(func)
	local seq=CCSequence:create(acArr)
	frameSp:runAction(seq)
end

function believerSegmentChangeSmallDialog:dispose()
	if self.bgLayer then
		self.bgLayer:removeFromParentAndCleanup(true)
		self.bgLayer=nil
	end
    self.layerNum=nil
    self.isCanClose=nil
    spriteController:removePlist("public/believer/believerEffect3.plist")
    spriteController:removeTexture("public/believer/believerEffect3.png")
    spriteController:removePlist("public/believer/believerEffect2.plist")
    spriteController:removeTexture("public/believer/believerEffect2.png")
end

return believerSegmentChangeSmallDialog