--require "luascript/script/componet/commonDialog"
require "luascript/script/game/gamemodel/newGifts/newGiftsVoApi"

newGiftsDialog=commonDialog:new()

function newGiftsDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
	self.loginDay=1
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    spriteController:addPlist("public/purpleFlicker.plist")
    spriteController:addTexture("public/purpleFlicker.png")
    return nc
end

--设置对话框里的tableView
function newGiftsDialog:initTableView()
	--[[
	local function touch()
	end
	local capInSet = CCRect(20, 20, 10, 10)
	local headSprie=LuaCCScale9Sprite:createWithSpriteFrameName("TaskHeaderBg.png",capInSet,touch)
    headSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,50))
    headSprie:setAnchorPoint(ccp(0,0))
    headSprie:setPosition(ccp(10,self.bgLayer:getContentSize().height-80-53))
    self.bgLayer:addChild(headSprie)
	]]
	self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
	self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-95))
	
	local loginDescLabel=GetTTFLabelWrap(getlocal("newGiftsSubTitle"),24,CCSizeMake(self.bgLayer:getContentSize().width-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
	loginDescLabel:setAnchorPoint(ccp(0,0.5))
    loginDescLabel:setPosition(ccp(20,self.bgLayer:getContentSize().height-125))
    self.bgLayer:addChild(loginDescLabel)
	loginDescLabel:setColor(G_ColorYellowPro)
	--[[
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30, self.bgLayer:getContentSize().height-160))
    backSprie:setAnchorPoint(ccp(0,0))
    backSprie:setPosition(ccp(15,20))
    self.bgLayer:addChild(backSprie)
	]]
	self.loginDay=newGiftsVoApi:getLoginDay()
	
    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-180),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(19,20))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(140)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function newGiftsDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return newGiftsVoApi:getNewGiftsNum()
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,150)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
		
		local sprieBg=CCSprite:createWithSpriteFrameName("7daysBg.png")
		sprieBg:setAnchorPoint(ccp(0,0))
        sprieBg:setPosition(ccp(0,10))
        cell:addChild(sprieBg)
        --[[
		local loginLabel=GetTTFLabel(getlocal("newGiftsDesc"),25)
		loginLabel:setAnchorPoint(ccp(0,0.5))
        loginLabel:setPosition(ccp(10,sprieBg:getContentSize().height-25))
        sprieBg:addChild(loginLabel,1)
		loginLabel:setColor(G_ColorGreen)
		
		local numLabel=GetTTFLabel(idx+1,35)
		numLabel:setAnchorPoint(ccp(0,0.5))
        numLabel:setPosition(ccp(10+loginLabel:getContentSize().width+5,sprieBg:getContentSize().height-25))
        sprieBg:addChild(numLabel,1)
		numLabel:setColor(G_ColorYellow)
		
		local dayLabel=GetTTFLabel(getlocal("newGiftsDayDesc"),25)
		dayLabel:setAnchorPoint(ccp(0,0.5))
        dayLabel:setPosition(ccp(10+loginLabel:getContentSize().width+dayLabel:getContentSize().width+5,sprieBg:getContentSize().height-25))
        sprieBg:addChild(dayLabel,1)
		dayLabel:setColor(G_ColorGreen)
		]]
		local numLabel=GetTTFLabel(getlocal("signDayNum",{idx+1}),24,true)
		numLabel:setAnchorPoint(ccp(0,0.5))
        numLabel:setPosition(ccp(15,sprieBg:getContentSize().height-25))
        sprieBg:addChild(numLabel,1)
		numLabel:setColor(G_ColorGreen)
		
		local newGiftsVo = newGiftsVoApi:getNewGiftsVo(idx+1)
		local award=newGiftsVo.award
		
		local function showInfoHandler(hd,fn,idx)
			if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
				local item=award[idx]
				-- if tostring(item.name)==getlocal("honor") then
				-- 	item.num=playerVoApi:getRankDailyHonor(playerVoApi:getRank())
				-- end
				if item then
					propInfoDialog:create(sceneGame,item,self.layerNum+1)
				end
			end
		end
		for k,v in pairs(award) do
			local icon
			local pic=v.pic
			local iconScaleX=1
			local iconScaleY=1
			--[[
			local startIndex,endIndex=string.find(pic,"^rank(%d+).png$")
			if startIndex~=nil and endIndex~=nil then
				icon=GetBgIcon(pic)
			else
			]]
			-- if v.type=="p" and v.equipId then
			-- 	local eType=string.sub(v.equipId,1,1)
			-- 	if eType=="a" then
			-- 		icon = accessoryVoApi:getAccessoryIcon(v.equipId,80,100,showInfoHandler)
			-- 	elseif eType=="f" then
			-- 		icon = accessoryVoApi:getFragmentIcon(v.equipId,80,100,showInfoHandler)
			-- 	else
			-- 		icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
			-- 	end
			-- elseif pic then
			-- 	icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
			-- end
			icon=G_getItemIcon(v,80,true,self.layerNum+1)
			if icon then
				if icon:getContentSize().width>100 then
					iconScaleX=0.78*100/150
					iconScaleY=0.78*100/150
				else
					iconScaleX=0.78
					iconScaleY=0.78
				end
				icon:setScaleX(iconScaleX)
				icon:setScaleY(iconScaleY)
					--end
				icon:ignoreAnchorPointForPosition(false)
		        icon:setAnchorPoint(ccp(0,0))
		      	icon:setPosition(ccp(10+(k-1)*85,12))
				icon:setIsSallow(false)
				icon:setTouchPriority(-(self.layerNum-1)*20-2)
				sprieBg:addChild(icon,1)
				icon:setTag(k)
			
				if tostring(v.name)~=getlocal("honor") then
					local numLabel=GetTTFLabel("x"..v.num,25)
			        --numLabel:setColor(G_ColorGreen)
					numLabel:setAnchorPoint(ccp(1,0))
					numLabel:setPosition(icon:getContentSize().width-10,0)
					icon:addChild(numLabel,1)
					numLabel:setScaleX(1/iconScaleX)
					numLabel:setScaleY(1/iconScaleY)
					--numLabel:setPosition((k-1)*85+icon:getContentSize().width*iconScaleX/2+12,10)
					--cell:addChild(numLabel,1)
				end

				if idx==6 and k==1 then
	                G_addRectFlicker2(icon,1.2,1.2,2,"p")
				end
			end
		end
		
		local loginDay=newGiftsVoApi:getLoginDay()
		if newGiftsVo.num<=0 and loginDay>=(idx+1) then
			local function rewardHandler(tag,object)
	            PlayEffect(audioCfg.mouseClick)
	            if self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
					local function newuserawardCallback(fn,data)
						if base:checkServerData(data)==true then
							local callsVo = activityVoApi:getActivityVo("calls")
						    if callsVo ~= nil and activityVoApi:isStart(callsVo) == true then
						        activityVoApi:updateShowState(callsVo)
						        callsVo.stateChanged = true -- 强制更新数据
						    end
						    
                            if self==nil or self.tv==nil then
                                do return end
                            end
							local recordPoint = self.tv:getRecordPoint()
							self.tv:reloadData()
							self.tv:recoverToRecordPoint(recordPoint)
							local awardStr,awardTab=newGiftsVoApi:getAwardStr(idx+1)
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),awardStr,28,nil,nil,awardTab)
						end
	                end
					socketHelper:newuseraward(idx+1,newuserawardCallback)
	            end
			end
		    local menuItemAward=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",rewardHandler,idx+1,getlocal("newGiftsReward"),24,100)
		    --self:iconFlicker(menuItemAward)
		    local lb = menuItemAward:getChildByTag(100)
		    if lb then
		    	lb = tolua.cast(lb,"CCLabelTTF")
		    	lb:setFontName("Helvetica-bold")
		    end
			menuItemAward:setScaleX(0.7)
			menuItemAward:setScaleY(0.7)
			local menuAward=CCMenu:createWithItem(menuItemAward)
	        menuAward:setAnchorPoint(ccp(0.5,0.5))
	        menuAward:setPosition(ccp(self.bgLayer:getContentSize().width-120,sprieBg:getContentSize().height/2))
		    menuAward:setTouchPriority(-(self.layerNum-1)*20-2)
		    sprieBg:addChild(menuAward,1)
		
		    local lightSp = CCSprite:createWithSpriteFrameName("7daysLight.png")
	        lightSp:setPosition(getCenterPoint(sprieBg))
	        sprieBg:addChild(lightSp)
		end
		
		if newGiftsVo.num<=0 and loginDay==idx then
			local nextLabel=GetTTFLabelWrap(getlocal("newGiftsNextReward"),19,CCSizeMake(125,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop,"Helvetica-bold")
	        nextLabel:setPosition(ccp(self.bgLayer:getContentSize().width-121,sprieBg:getContentSize().height/2))
	        sprieBg:addChild(nextLabel,1)
		end
		
		if newGiftsVo.num>0 then
			local rightIcon=CCSprite:createWithSpriteFrameName("7daysCheckmark.png")
			rightIcon:setAnchorPoint(ccp(0.5,0.5))
			rightIcon:setPosition(ccp(self.bgLayer:getContentSize().width-120,sprieBg:getContentSize().height/2))
			sprieBg:addChild(rightIcon,1)
			--rightIcon:setScaleX(1.2)
			--rightIcon:setScaleY(1.2)
		end
		--[[
		local lineSprite = CCSprite:createWithSpriteFrameName("LineCross.png")
		lineSprite:setAnchorPoint(ccp(0.5,0.5))
		lineSprite:setPosition(ccp(self.bgLayer:getContentSize().width/2-15,0))
		cell:addChild(lineSprite,1)
		]]
		return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
       
    end
		
end

function newGiftsDialog:tick()
	if self.loginDay~=newGiftsVoApi:getLoginDay() then
		self.loginDay=newGiftsVoApi:getLoginDay()
		local recordPoint = self.tv:getRecordPoint()
		self.tv:reloadData()
		self.tv:recoverToRecordPoint(recordPoint)
	end
end

--用户处理特殊需求,没有可以不写此方法
function newGiftsDialog:doUserHandler()

end

function newGiftsDialog:dispose()
	self.loginDay=nil
	spriteController:removePlist("public/purpleFlicker.plist")
    spriteController:removeTexture("public/purpleFlicker.png")
   --  CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/accessoryImage.plist")
   --  if G_isCompressResVersion()==true then
  	-- 	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.png")
  	-- else
  	-- 	CCTextureCache:sharedTextureCache():removeTextureForKey("public/accessoryImage.pvr.ccz")
  	-- end
end




