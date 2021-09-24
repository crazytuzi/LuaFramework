acCallsExchangeDialog=commonDialog:new()

function acCallsExchangeDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=layerNum

	self.callNum = nil -- 输入的手机号码
	self.targetBoxLabel = nil
	self.resultDes = nil
	self.centerPosY = nil

	self.rechangeBtn = nil
	return nc
end

function acCallsExchangeDialog:getDes(content, width,size, dimensions)
  local showMsg=content or ""
  local messageLabel = GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  local height=messageLabel:getContentSize().height+20
  if dimensions == true then
    messageLabel:setDimensions(CCSizeMake(width, height+50))
  end
  return height, messageLabel
end

function acCallsExchangeDialog:initTableView()
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSize.height-105))
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setPosition(ccp(15,15))

    
    local topH = self:initTop()
    local bottomH = self:initBottom()
    self:initCenter(bottomH, topH)

    local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth - 200,100),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(180,10))
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setMaxDisToBottomOrTop(60)
end

-- 面板上部分活动时间、说明按钮
function acCallsExchangeDialog:initTop()
	-- 上部分160
	local totalH = 115
	local posY = G_VisibleSizeHeight - totalH

    local timeTime=GetTTFLabelWrap(getlocal("activity_timeLabel"),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeTime:setAnchorPoint(ccp(0.5,0.5))
	timeTime:setColor(G_ColorGreen)
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(timeTime)
    
    totalH = totalH + 45
	posY = G_VisibleSizeHeight - totalH

	local timeLb=GetTTFLabelWrap(acCallsVoApi:getTimeStr(),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLb:setAnchorPoint(ccp(0.5,0.5))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(timeLb)

	local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")

	totalH = totalH + girlImg:getContentSize().height + 50
	posY = G_VisibleSizeHeight - totalH

	girlImg:setAnchorPoint(ccp(0,0))
	girlImg:setPosition(ccp(20,posY))
	self.bgLayer:addChild(girlImg)
    
    local  girlImgW = 20 + girlImg:getContentSize().width + 10
    local index,money = acCallsVoApi:getCanReward()
	local desH,des = self:getDes(getlocal("activity_calls_rechargeDes1",{money}),G_VisibleSizeWidth - girlImgW - 20,30,false)
	des:setAnchorPoint(ccp(0,0.5))
	des:setPosition(ccp(girlImgW,posY + desH/2))
	self.bgLayer:addChild(des)


	local lineSp=CCSprite:createWithSpriteFrameName("LineCross.png")
    lineSp:setAnchorPoint(ccp(0.5,0))
    lineSp:setPosition(ccp(G_VisibleSizeWidth/2,posY))
    self.bgLayer:addChild(lineSp)

	return totalH
end

-- 面板中间部分
function acCallsExchangeDialog:initCenter(bottomH, topH)
	local lastH = G_VisibleSizeHeight - bottomH - topH - 40 --上下间隔40
    
    self.centerPosY = bottomH + lastH/2

    self.resultDes = GetTTFLabelWrap("",25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	self.resultDes:setAnchorPoint(ccp(0.5,1))
	self.resultDes:setPosition(ccp(G_VisibleSizeWidth/2,self.centerPosY))
	self.bgLayer:addChild(self.resultDes)
    self.resultDes:setVisible(false)
    self:showDesByStatus()
end

-- 面板下部分
function acCallsExchangeDialog:initBottom()
    local btnY = 150
    local totalH = 0
    local function rechange(tag,object)
	    if G_checkClickEnable()==false then
	      do
	        return
	      end
	    else
	    	base.setWaitTime=G_getCurDeviceMillTime()
	    end
	    PlayEffect(audioCfg.mouseClick)
	    if self.callNum ~= nil then
	    	local function rechangeSuccess(fn,data)
	    		local ret,sData=base:checkServerData(data)
                if ret==true and sData.resCode ~= nil then
                	local resCode = sData.resCode
        --         	['1002'] = "手机号不正确",
				    -- ['1003'] = "订单处理中",
				    -- ['1004'] = "该账号已充值",
				    -- ['1005'] = "充值失败，请联系客服",
				    -- ['1006'] = "该手机号已充值",
			     --    ['9999'] = "系统错误",
			        if resCode == "1002" then
                        self.resultDes:setString(getlocal("activity_calls_wrong1"))
	                    self.resultDes:setVisible(true)
                	elseif resCode == "1003" then
                		if sData.tId ~= nil then
	                		acCallsVoApi:setTId(sData.tId)
	                		self.resultDes:setString(getlocal("activity_calls_rechargeWaitTip",{sData.tId}))
		                    self.resultDes:setVisible(true)
		                	self.rechangeBtn:setEnabled(false)
	                	end	                	
	                elseif resCode == "1004" then
                        self.resultDes:setString(getlocal("activity_calls_wrong3"))
	                    self.resultDes:setVisible(true)
	                elseif resCode == "1005" then
                        self.resultDes:setString(getlocal("activity_calls_rechargeFailTip"))
	                    self.resultDes:setVisible(true)
	                elseif resCode == "1006" then
                        self.resultDes:setString(getlocal("activity_calls_wrong2",{self.callNum}))
	                    self.resultDes:setVisible(true)
	                else
                        self.resultDes:setString(getlocal("activity_calls_wrong5"))
                        self.resultDes:setVisible(true)
	                end
			    elseif sData.ret==-1981 then -- 领奖条件不满足
			    	self.resultDes:setString(getlocal("activity_calls_wrong4"))
                    self.resultDes:setVisible(true)
                else
		            self.resultDes:setVisible(false)
		        end
		    end
		    socketHelper:callsRecharge(self.callNum, rechangeSuccess)
	    end

	end
	self.rechangeBtn =GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",rechange,nil,getlocal("recharge"),25)
	local menu =CCMenu:createWithItem(self.rechangeBtn)
	menu:setPosition(ccp(G_VisibleSizeWidth/2,btnY/2))
	menu:setTouchPriority(-(self.layerNum-1)*20-5)
	self.bgLayer:addChild(menu)
    
    local index,money = acCallsVoApi:getCanReward()
    if index <= 0 or money <= 0 then
    	self.rechangeBtn:setEnabled(false)
    end

    local editBoxH = 50
    local editBoxY = btnY + editBoxH/2

    local function tthandler()
    
    end
    local function callBackUserNameHandler(fn,eB,str,type)
        if str~=nil and string.len(str) == 11 then
	       	self.callNum = str
        else
        	self.callNum = nil
            self.resultDes:setVisible(false)
        end            
    end
    
    local accountBox=LuaCCScale9Sprite:createWithSpriteFrameName("LegionInputBg.png",CCRect(10,10,1,1),tthandler)
    accountBox:setContentSize(CCSize(300,editBoxH))
    accountBox:setPosition(ccp(G_VisibleSizeWidth/2,editBoxY))
    self.bgLayer:addChild(accountBox)
    
    self.targetBoxLabel=GetTTFLabel("",30)
    self.targetBoxLabel:setAnchorPoint(ccp(0,0.5))
    self.targetBoxLabel:setPosition(ccp(10,accountBox:getContentSize().height/2))
    local customEditAccountBox=customEditBox:new()
    customEditAccountBox:init(accountBox,self.targetBoxLabel,"inputNameBg.png",nil,-(self.layerNum-1)*20-4,11,callBackUserNameHandler,nil,CCEditBox.kEditBoxInputModePhoneNumber)
    
    local msg = GetTTFLabelWrap(getlocal("activity_calls_rechargeDes2"),30,CCSizeMake(G_VisibleSizeWidth - 40, 0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    local msgY = btnY + editBoxH + msg:getContentSize().height + 50
    msg:setAnchorPoint(ccp(0.5,1))
    msg:setPosition(ccp(G_VisibleSizeWidth/2, msgY))
    self.bgLayer:addChild(msg)
    
    totalH = msgY

    return totalH
end

function acCallsExchangeDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth - 200,100)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function acCallsExchangeDialog:update()
  local acVo = acCallsVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
        self:close()
      end
    elseif self ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
      self:showDesByStatus()
    end
  end
end

function acCallsExchangeDialog:showDesByStatus()
	local status,num,phone = acCallsVoApi:getStateAndData()
	print("当前订单状态： ", status)
    if status == 0 then
        self.resultDes:setString(getlocal("activity_calls_rechargeSucTip",{phone,num}))
        self.resultDes:setVisible(true)
        self.rechangeBtn:setEnabled(false)
    elseif status == 1 then
        self.resultDes:setString(getlocal("activity_calls_rechargeFailTip"))
        self.resultDes:setVisible(true)
        self.rechangeBtn:setEnabled(true)
    elseif status == 2 then
    	local tid = acCallsVoApi:getTId() -- 订单号
    	self.resultDes:setString(getlocal("activity_calls_rechargeWaitTip2",{tid, phone, num}))
        self.resultDes:setVisible(true)
    	self.rechangeBtn:setEnabled(false)
    elseif status == 3 then
    	self.resultDes:setVisible(false)
    	self.rechangeBtn:setEnabled(true)
    end
end

function acCallsExchangeDialog:dispose()
	self.callNum = nil
	self.targetBoxLabel = nil
	self.resultDes = nil
	self.centerPosY= nil
	self.rechangeBtn = nil
end