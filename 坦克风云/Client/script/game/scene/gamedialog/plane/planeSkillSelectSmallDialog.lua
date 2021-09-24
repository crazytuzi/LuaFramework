--选择技能的小板子
planeSkillSelectSmallDialog=smallDialog:new()

function planeSkillSelectSmallDialog:new(quality,usedList,callback,dialogType)
	local nc={}
	setmetatable(nc,self)
	self.__index=self	
	nc.dialogHeight=650
	nc.dialogWidth=550
	nc.quality=quality
	nc.usedList=usedList
	nc.type=dialogType		--1是进阶，不可堆叠，等级大于1的不显示，排序从低到高，2是出战，可堆叠，全显示，排序从高到低 		
	nc.callback=callback
	return nc
end

function planeSkillSelectSmallDialog:init(layerNum)
	self.layerNum=layerNum
	local function nilFunc()
	end
	local function close()
		return self:close()
	end
	local size=CCSizeMake(self.dialogWidth,self.dialogHeight)
	local dialogBg=G_getNewDialogBg(size,getlocal("skill_select"),30,nilFunc,layerNum,true,close)
	self.dialogLayer=CCLayer:create()
	--遮罩层
	local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
	touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
	local rect=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
	touchDialogBg:setContentSize(rect)
	touchDialogBg:setOpacity(255)
	touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(touchDialogBg)

	local grayBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	grayBgSp:setTouchPriority(-(layerNum-1)*20-1)
    grayBgSp:setAnchorPoint(ccp(0,0.5))
    grayBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.2,G_VisibleSizeHeight*0.7))
    grayBgSp:setPosition(ccp(0,G_VisibleSizeHeight*0.5))
    self.dialogLayer:addChild(grayBgSp)  

    local grayBgSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
	grayBgSp2:setTouchPriority(-(layerNum-1)*20-1)
    grayBgSp2:setAnchorPoint(ccp(1,0.5))
    grayBgSp2:setContentSize(CCSizeMake(G_VisibleSizeWidth*0.2,G_VisibleSizeHeight*0.7))
    grayBgSp2:setPosition(ccp(G_VisibleSizeWidth,G_VisibleSizeHeight*0.5))
    self.dialogLayer:addChild(grayBgSp2) 

	self.bgLayer=dialogBg
	self.bgLayer:setContentSize(CCSizeMake(self.dialogWidth,self.dialogHeight))
	self.bgLayer:setIsSallow(false)
	self:show()
	self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
	self.dialogLayer:addChild(self.bgLayer,2);
	self.dialogLayer:setTouchPriority(-(self.layerNum-1)*20-2)
	self.dialogLayer:setBSwallowsTouches(true);

	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888) 
	spriteController:addPlist("public/emblem/emblemImage.plist")
	spriteController:addTexture("public/emblem/emblemImage.png")
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
	CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

	local forbidLayerUp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),nilFunc)
	forbidLayerUp:setTouchPriority(((-(self.layerNum-1)*20-4)))
	forbidLayerUp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight/2 - self.dialogHeight/2 + 100))
	forbidLayerUp:setAnchorPoint(ccp(0,1))
	forbidLayerUp:setPosition(0,G_VisibleSizeHeight)
	self.dialogLayer:addChild(forbidLayerUp)
	local forbidLayerDown=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),nilFunc)
	forbidLayerDown:setTouchPriority(((-(self.layerNum-1)*20-4)))
	forbidLayerDown:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight/2 - self.dialogHeight/2 + 110))
	forbidLayerDown:setAnchorPoint(ccp(0,0))
	forbidLayerDown:setPosition(0,0)
	self.dialogLayer:addChild(forbidLayerDown)

	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(30,30,40,40),nilFunc)
	tvBg:setContentSize(CCSizeMake(self.dialogWidth - 40,self.dialogHeight - 200))
	tvBg:setAnchorPoint(ccp(0,0))
	tvBg:setPosition(20,110)
	dialogBg:addChild(tvBg)
	self.skillList,self.ownList=planeVoApi:getCanComposeSkills(self.quality,self.usedList)
	local skillCount=#self.skillList
	if(skillCount==0)then
		local noSkillLb=GetTTFLabelWrap(getlocal("skill_no_equip_prompt"),25,CCSizeMake(self.dialogWidth - 60,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		noSkillLb:setPosition(getCenterPoint(self.bgLayer))
		self.bgLayer:addChild(noSkillLb)
		self.noSkillLb=noSkillLb
	end
	self.cellNum=math.max(math.ceil(skillCount/3),1)
	self.selectedID=nil
	self.selectedSp=nil

	local function callback(...)
		return self:eventHandler(...)
	end
	local hd=LuaEventHandler:createHandler(callback)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.dialogWidth - 50,self.dialogHeight - 210),nil)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
	self.tv:setPosition(ccp(25,115))
	self.bgLayer:addChild(self.tv)
	self.tv:setMaxDisToBottomOrTop(80)

	local function onConfirm()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		if(self.selectedID==nil)then
			smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("skill_merge_prompt"),30)
			do return end
		end
		if(self.callback)then
			self.callback(self.selectedID)
		end
		self:close()
	end
	local scale=0.8
	local confirmItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onConfirm,nil,getlocal("confirm"),25/scale)
	confirmItem:setScale(scale)
	local confirmBtn=CCMenu:createWithItem(confirmItem)
	confirmBtn:setTouchPriority(((-(self.layerNum-1)*20-5)))
	confirmBtn:setPosition(self.dialogWidth - 150,60)
	self.bgLayer:addChild(confirmBtn)
	local function onCancel()
    	if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
		self:close()
	end
	local cancelItem=GetButtonItem("newGrayBtn.png","newGrayBtn_Down.png","newGrayBtn_Down.png",onCancel,nil,getlocal("cancel"),25/scale)
	cancelItem:setScale(scale)
	local cancelBtn=CCMenu:createWithItem(cancelItem)
	cancelBtn:setTouchPriority(((-(self.layerNum-1)*20-5)))
	cancelBtn:setPosition(150,60)
	self.bgLayer:addChild(cancelBtn)

	sceneGame:addChild(self.dialogLayer,layerNum)
	self.dialogLayer:setPosition(ccp(0,0))
	return self.dialogLayer
end

function planeSkillSelectSmallDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return self.cellNum
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(self.dialogWidth - 50,230)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		local startIndex=idx*3
		local bgWidth=(self.dialogWidth - 100)/3
		for i=1,3 do
			local skillVo=self.skillList[startIndex + i]
			if(skillVo)then
				local skillIcon
				local function onSelected()
					if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
						if skillIcon==nil then
							do return end
						end
						if(self.selectedSp)then
							self.selectedSp:removeFromParentAndCleanup(true)
							self.selectedSp=nil
						end
						if self.selectedID~=skillVo.sid then
							self.selectedID=skillVo.sid
							self.selectedSp=LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png",CCRect(3,3,4,4),function ( ... )end)
							self.selectedSp:setTag(999)
							self.selectedSp:setContentSize(skillIcon:getContentSize())
							self.selectedSp:setOpacity(120)
							self.selectedSp:setPosition(getCenterPoint(skillIcon))
							local icon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
							icon:setPosition(getCenterPoint(self.selectedSp))
							self.selectedSp:addChild(icon)
							skillIcon:addChild(self.selectedSp)
						else
							self.selectedID=nil
						end
					end
				end
				local num=self.ownList[startIndex + i]
				skillIcon=planeVoApi:getSkillIcon(skillVo.sid,nil,onSelected,num,2)
				skillIcon:setTouchPriority(((-(self.layerNum-1)*20-2)))
				-- skillIcon:setScale(bgWidth/skillIcon:getContentSize().width)
				skillIcon:setAnchorPoint(ccp(0.5,0))
				skillIcon:setPosition(ccp(15 + bgWidth/2 + (i - 1)*(bgWidth + 10),0))
				cell:addChild(skillIcon)
				
				local function showInfo()
					local selectedSp=skillIcon:getChildByTag(999)
					if(selectedSp)then
						do return end
					end
					planeVoApi:showInfoDialog(skillVo,self.layerNum+1)
				end
				-- local infoBtn = LuaCCSprite:createWithSpriteFrameName("BtnInfor.png",showInfo)
				-- infoBtn:setTouchPriority(-(self.layerNum-1)*20-3)
				-- infoBtn:setScale(0.7)
				-- infoBtn:setPosition(ccp(skillIcon:getContentSize().width - 35,skillIcon:getContentSize().height - 35))
				-- skillIcon:addChild(infoBtn)
			end
		end
		return cell
	elseif fn=="ccTouchBegan" then
	   self.isMoved=false
	   return true
   elseif fn=="ccTouchMoved" then
		self.isMoved=true
   elseif fn=="ccTouchEnded" then	   
   end
end

function planeSkillSelectSmallDialog:dispose()
	spriteController:removePlist("public/emblem/emblemImage.plist")
	spriteController:removeTexture("public/emblem/emblemImage.png")
end