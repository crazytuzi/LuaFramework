acAutumnCarnivalDialog=commonDialog:new()

function acAutumnCarnivalDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.desH = {}
    return nc
end

function acAutumnCarnivalDialog:initTableView()

local desH,des 
if acAutumnCarnivalVoApi:isAutumn() ==true then
  desH,des= self:getDes(getlocal("activity_AutumnCarnival_content"),25, nil)
else
  desH,des= self:getDes(getlocal("activity_SupplyIntercept_content"),25, nil)
end
  table.insert(self.desH, desH)
if acAutumnCarnivalVoApi:isAutumn()==true then
  desH,des = self:getDes(getlocal("activity_AutumnCarnival_desc1"),25, nil)
else
  desH,des = self:getDes(getlocal("activity_SupplyIntercept_desc1"),25, nil)
end
  table.insert(self.desH, desH)
if acAutumnCarnivalVoApi:isAutumn()==true then
  desH,des = self:getDes(getlocal("activity_AutumnCarnival_desc2"),25, nil)
else
   desH,des = self:getDes(getlocal("activity_SupplyIntercept_desc2"),25, nil)
end
  table.insert(self.desH, desH)
if acAutumnCarnivalVoApi:isAutumn()==true then 
  desH,des = self:getDes(getlocal("activity_AutumnCarnival_desc3"),25, nil)
else
  desH,des = self:getDes(getlocal("activity_SupplyIntercept_desc3"),25, nil)
end
  table.insert(self.desH, desH)
if acAutumnCarnivalVoApi:isAutumn()==true then
  desH,des = self:getDes(getlocal("activity_AutumnCarnival_note"),25,G_VisibleSizeWidth-60)
else
  desH,des = self:getDes(getlocal("activity_SupplyIntercept_note"),25, G_VisibleSizeWidth-60)
end
  table.insert(self.desH, desH)

  local function callBack(...)
       return self:eventHandler(...)
  end
  local hd= LuaEventHandler:createHandler(callBack)
  self.panelLineBg:setAnchorPoint(ccp(0.5, 0))
  self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-20, G_VisibleSizeHeight - 100))
  self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,15))
 
  self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 20,G_VisibleSizeHeight - 115),nil)
  self.bgLayer:addChild(self.tv)
  self.tv:setPosition(ccp(10,30))
  self.tv:setAnchorPoint(ccp(0,0))
  self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
  self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
  self.tv:setMaxDisToBottomOrTop(120)
end

function acAutumnCarnivalDialog:eventHandler(handler,fn,idx,cel)
  if fn=="numberOfCellsInTableView" then
    return 10
  elseif fn=="tableCellSizeForIndex" then
    local tmpSize
    if idx == 0 or idx == 2 or idx == 5  then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,55)
    elseif idx==1 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,30)
    elseif idx == 3 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[1])
    elseif idx == 4 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,500)
    elseif idx == 6 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[2])
    elseif idx == 7 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[3])
    elseif idx == 8 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[4])
    elseif idx == 9 then
      tmpSize = CCSizeMake(G_VisibleSizeWidth - 50,self.desH[5])
    end
    return  tmpSize
  elseif fn=="tableCellAtIndex" then
    local cell=CCTableViewCell:new()
    cell:autorelease()
    local desLabel
    if idx == 0 then
      desLabel = GetTTFLabel(getlocal("activity_timeLabel"),26)
      desLabel:setAnchorPoint(ccp(0.5,0))
      desLabel:setColor(G_ColorGreen)
      desLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,10))
      cell:addChild(desLabel)
    elseif idx == 1 then
      local acVo = acAutumnCarnivalVoApi:getAcVo()
      if acVo ~= nil then
        local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
        desLabel=GetTTFLabel(timeStr,26)
        desLabel:setAnchorPoint(ccp(0.5,1))
        desLabel:setPosition(ccp(self.bgLayer:getContentSize().width/2,30))
        cell:addChild(desLabel)
        self.timeLb=desLabel
        self:updateAcTime()
      end
    elseif idx == 2 then
      desLabel = GetTTFLabel(getlocal("activity_contentLabel"),26)
      desLabel:setAnchorPoint(ccp(0,0))
      desLabel:setColor(G_ColorGreen)
      desLabel:setPosition(ccp(10,10))
      cell:addChild(desLabel)
    elseif idx == 3 then
      local contentStr
      if acAutumnCarnivalVoApi:isAutumn()==true then 
        contentStr = getlocal("activity_AutumnCarnival_content")
      else
        contentStr = getlocal("activity_SupplyIntercept_content")
      end
      local contentLabel = GetTTFLabelWrap(contentStr,25,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      contentLabel:setAnchorPoint(ccp(0,0.5))
      contentLabel:setPosition(ccp(35,self.desH[1]/2))
      cell:addChild(contentLabel)
    elseif idx == 4 then -- 礼盒图标

      local function nilFun()
	  end
      local capInSet = CCRect(20, 20, 10, 10);
	  local backSprite = LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",capInSet,nilFun)
	  backSprite:setContentSize(CCSizeMake(G_VisibleSizeWidth-60,500))
	  backSprite:setPosition(ccp(20,0))
	  backSprite:setAnchorPoint(ccp(0,0))
	  cell:addChild(backSprite)
      local pCfg = nil
      local totalH = 500
      for i=1,6 do

        local id = "b"..i
        pCfg = acAutumnCarnivalVoApi:getGiftCfgForShowByPid(id)
        local hadNum = tonumber(acAutumnCarnivalVoApi:getGiftNum(id))
        local pIcon = self:getIcon(pCfg,hadNum)
        pIcon:setAnchorPoint(ccp(0,1))
        local pIconX = 90+((i-1)%3)*200
		local pIconY = totalH-(math.floor((i-1)/3))*240-70
        pIcon:setAnchorPoint(ccp(0.5,1))
        pIcon:setPosition(ccp(pIconX,pIconY))
        pIcon:setTouchPriority(-(self.layerNum-1)*20-2)
        backSprite:addChild(pIcon)
        
        local numLb = GetTTFLabel(hadNum,25)
        numLb:setAnchorPoint(ccp(1,0))
        numLb:setPosition(pIcon:getContentSize().width-10,5)
        pIcon:addChild(numLb)
        local nameLabel=GetTTFLabelWrap(getlocal(pCfg.name),25,CCSizeMake(170,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        nameLabel:setAnchorPoint(ccp(0.5,0.5))
        nameLabel:setPosition(ccp(pIconX,pIconY+35))
        nameLabel:setColor(G_ColorYellowPro)
        backSprite:addChild(nameLabel)
    	local function onClickBtn( ... )
    		if self and self.tv and self.tv:getIsScrolled()==true then
    			do
    				return
    			end
    		end
      		if G_checkClickEnable()==false then
          		do
              		return
          		end
      		else
         		 base.setWaitTime=G_getCurDeviceMillTime()
      		end

	        if newGuidMgr:isNewGuiding()==true then --新手引导
	            do
	              return
	            end
	        end
	        PlayEffect(audioCfg.mouseClick)
	    
			if hadNum>0 then
				local function callBack(fn,data)
					local ret,sData=base:checkServerData(data)
  					if ret==true then
						local str = ""
            local isChat = false
						if sData.clientReward and SizeOfTable(sData.clientReward)>0 then
								--local content = {}
							for k,v in pairs(sData.clientReward) do
								local award = {}
                print(v.t,v.p,v.n)
								local name,pic,desc,id,index,eType,equipId=getItem(v.t,v.p)
                print(name,pic,desc,id,index,eType,equipId)
								local num=v.n
								local award={name=name,num=num,pic=pic,desc=desc,id=id,type=v.p,index=index,key=v.t,eType=eType,equipId=equipId}
								G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
								--table.insert(content,{award=award,point=point})
								if k==SizeOfTable(sData.clientReward) then
							        str =str..name .. " x" .. num
							    else
							        str =str..name .. " x" .. num .. ","
							   end
                 if acAutumnCarnivalVoApi:isToChatMessegeByID(v.t,v.p)==true then
                    isChat = true
                 end

							end
							local rewardStr = getlocal("activity_AutumnCarnival_getReward",{getlocal(acAutumnCarnivalVoApi:getGiftCfgForShowByPid(id).name),str})
							smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),rewardStr,28)
							-- local chestName = getlocal(pCfg.name)
							-- local nameData={key=str,param={}}
       --        local chatData={playerVoApi:getPlayerName(),chestName,nameData}
       --        local message={key="chatSystemMessage12",param=chatData}
             if isChat==true then
                local paramTab={}
                paramTab.functionStr="autumnCarnival"
                paramTab.addStr="i_also_want"
                local message={key="chatSystemMessage12",param={playerVoApi:getPlayerName(),getlocal(acAutumnCarnivalVoApi:getGiftCfgForShowByPid(id).name),str}}
                chatVoApi:sendSystemMessage(message,paramTab)
              end
						end
  						acAutumnCarnivalVoApi:openGift(id,1)
                        acAutumnCarnivalVoApi:updateShow()
  						self.tv:reloadData()
  					end
				end
				socketHelper:activeAutumnCarnivalOpen(id,callBack)
			else
				activityAndNoteDialog:closeAllDialog()
	    		storyScene:setShow()
			end
    	end
    	local btnItem
    	if hadNum>0 then
    		btnItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",onClickBtn,2,getlocal("open_setting"),25)
    	else
    		
    		btnItem=GetButtonItem("BtnCancleSmall.png","BtnCancleSmall_Down.png","BtnCancleSmall_Down.png",onClickBtn,2,getlocal("accessory_get"),25)
    	end
    	btnItem:setScale(0.8)
    	local btnMenu=CCMenu:createWithItem(btnItem);
		btnMenu:setTouchPriority(-(self.layerNum-1)*20-2);
		btnMenu:setPosition(ccp(pIconX,pIconY-pIcon:getContentSize().height-40))
		backSprite:addChild(btnMenu)
      end
	elseif idx == 5 then
      local descriptionStr
      if acAutumnCarnivalVoApi:isAutumn()==true then 
        contentStr = getlocal("activity_AutumnCarnival_content")
      else
        contentStr = getlocal("activity_SupplyIntercept_content")
      end
      local descriptionLabel = GetTTFLabel(getlocal("activityDescription"),26)
      descriptionLabel:setAnchorPoint(ccp(0,0))
      descriptionLabel:setColor(G_ColorGreen)
      descriptionLabel:setPosition(ccp(10,10))
      cell:addChild(descriptionLabel)

    elseif idx == 6 then -- 提示信息
      local desc1Str 
      if acAutumnCarnivalVoApi:isAutumn()==true then 
        desc1Str = getlocal("activity_AutumnCarnival_desc1")
      else
        desc1Str = getlocal("activity_SupplyIntercept_desc1")
      end

      local descLabel1 = GetTTFLabelWrap(desc1Str,25,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      descLabel1:setAnchorPoint(ccp(0,0.5))
      descLabel1:setPosition(ccp(35,self.desH[2]/2))
      --desLabel:setColor(G_ColorRed)
      cell:addChild(descLabel1)
     elseif idx == 7 then -- 提示信息
      local desc2Str
      if acAutumnCarnivalVoApi:isAutumn()==true then 
        desc2Str = getlocal("activity_AutumnCarnival_desc2")
      else
        desc2Str = getlocal("activity_SupplyIntercept_desc2")
      end
      local descLabel2 = GetTTFLabelWrap(desc2Str,25,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      descLabel2:setAnchorPoint(ccp(0,0.5))
      descLabel2:setPosition(ccp(35,self.desH[3]/2))
      --desLabel:setColor(G_ColorRed)
      cell:addChild(descLabel2)
    elseif idx == 8 then -- 提示信息
      local desc3Str
      if acAutumnCarnivalVoApi:isAutumn()==true then 
        desc3Str = getlocal("activity_AutumnCarnival_desc3")
      else
        desc3Str = getlocal("activity_SupplyIntercept_desc3")
      end
      local descLabel3 = GetTTFLabelWrap(desc3Str,25,CCSizeMake(G_VisibleSizeWidth - 80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      descLabel3:setAnchorPoint(ccp(0,0.5))
      descLabel3:setPosition(ccp(35,self.desH[4]/2))
      --desLabel:setColor(G_ColorRed)
      cell:addChild(descLabel3)
    elseif idx == 9 then -- 提示信息
      local noteStr
      if acAutumnCarnivalVoApi:isAutumn()==true then 
        noteStr = getlocal("activity_AutumnCarnival_note")
      else
        noteStr = getlocal("activity_SupplyIntercept_note")
      end
      local noteLabel = GetTTFLabelWrap(noteStr,25,CCSizeMake(G_VisibleSizeWidth - 60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
      noteLabel:setAnchorPoint(ccp(0,0.5))
      noteLabel:setPosition(ccp(15,self.desH[5]/2))
      noteLabel:setColor(G_ColorRed)
      cell:addChild(noteLabel)
    end

    return cell
  elseif fn=="ccTouchBegan" then
    self.isMoved=false
    return true
  elseif fn=="ccTouchMoved" then
    self.isMoved=true
  elseif fn=="ccTouchEnded"  then
   
  end
end

function acAutumnCarnivalDialog:getIcon(pCfg,hadNum)
  local function showInfoHandler(hd,fn,idx)
    if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
      if G_checkClickEnable()==false then
          do
              return
          end
      else
          base.setWaitTime=G_getCurDeviceMillTime()
      end
      PlayEffect(audioCfg.mouseClick)
      local item = {name = getlocal(pCfg.name), pic= pCfg.icon, num = hadNum, desc = pCfg.des}
      propInfoDialog:create(sceneGame,item,self.layerNum+1,nil,nil,nil,nil,nil,nil,nil,true)
    end
  end
  local pIcon = LuaCCSprite:createWithSpriteFrameName(pCfg.icon,showInfoHandler)
  return pIcon
end

function acAutumnCarnivalDialog:updateAcTime()
    local acVo=acAutumnCarnivalVoApi:getAcVo()
    if acVo and self.timeLb then
        G_updateActiveTime(acVo,self.timeLb)
    end
end

function acAutumnCarnivalDialog:tick()
    local vo=acAutumnCarnivalVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
  self:updateAcTime()
end

function acAutumnCarnivalDialog:update()
  local acVo = acAutumnCarnivalVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil and self.tv ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
   		self.tv:reloadData()
     end
  end
end

function acAutumnCarnivalDialog:getDes(content, size, width)
  local showMsg=content or ""
  local width= width
  if width == nil then
    width = G_VisibleSizeWidth - 80
  end

  local messageLabel=GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  local height=messageLabel:getContentSize().height+20
  messageLabel:setDimensions(CCSizeMake(width, height+50))
  return height
end

function acAutumnCarnivalDialog:dispose()
  self.desH = nil
  self.timeLb=nil

  self=nil
end





