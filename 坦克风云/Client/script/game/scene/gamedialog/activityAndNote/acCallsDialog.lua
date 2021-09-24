acCallsDialog=commonDialog:new()

function acCallsDialog:new(layerNum)
	local nc={}
	setmetatable(nc,self)
	self.__index=self

	self.layerNum=layerNum

    self.des = nil -- 页面描述信息
    self.desH = nil -- 页面描述信息的高度

    self.rechargeMenu = nil
    self.exchangeBtns = nil
    self.openDialog = nil
	return nc
end

function acCallsDialog:getDes(content, width,size, dimensions)
  local showMsg=content or ""
  local messageLabel = GetTTFLabelWrap(showMsg,size,CCSizeMake(width, 0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
  local height=messageLabel:getContentSize().height+20
  if dimensions == true then
    messageLabel:setDimensions(CCSizeMake(width, height+50))
  end
  return height, messageLabel
end

function acCallsDialog:initTableView()
	self.panelLineBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-30,G_VisibleSize.height-105))
	self.panelLineBg:setAnchorPoint(ccp(0,0))
	self.panelLineBg:setPosition(ccp(15,15))

    
    local topH = self:initTop()
    local bottomH = self:initBottom()
    self:initCenter(bottomH, topH)
end

-- 面板上部分活动时间、说明按钮
function acCallsDialog:initTop()
	-- 上部分160
	local posY = G_VisibleSizeHeight - 115

    local timeTime=GetTTFLabelWrap(getlocal("activity_timeLabel"),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeTime:setAnchorPoint(ccp(0.5,0.5))
	timeTime:setColor(G_ColorGreen)
	timeTime:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(timeTime)

	posY = posY - 45

	local timeLb=GetTTFLabelWrap(acCallsVoApi:getTimeStr(),25,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
	timeLb:setAnchorPoint(ccp(0.5,0.5))
	timeLb:setPosition(ccp(G_VisibleSizeWidth/2,posY))
	self.bgLayer:addChild(timeLb)
	return 200
end

-- 面板中间部分
function acCallsDialog:initCenter(bottomH, topH)
	local lastH = G_VisibleSizeHeight - bottomH - topH --上下间隔40
    
    local posY = bottomH + lastH/2

    local girlImg=CCSprite:createWithSpriteFrameName("GuideCharacter.png")
	local scale = lastH/girlImg:getContentSize().height
	if scale > 1 then
		scale = 1
	end

	girlImg:setScale(scale)
	girlImg:setAnchorPoint(ccp(0,0.5))
	girlImg:setPosition(ccp(20,posY))
	self.bgLayer:addChild(girlImg)
    
    local imgW = girlImg:getContentSize().width * scale
    local bgW = G_VisibleSizeWidth - 50 - imgW

    local width = bgW - 20 -- 10 是右侧与背景的间距，左侧的间距通过设置x坐标 = 10 来设置
    local day = acCallsVoApi:getOnlineDayCfg()
	self.desH, self.des = self:getDes(getlocal("activity_calls_content",{day,day,day}),width,25,false)

    local girlDescBg=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	girlDescBg:setContentSize(CCSizeMake(bgW,self.desH + 20))
	girlDescBg:setAnchorPoint(ccp(0,0.5))
	girlDescBg:setPosition(ccp(imgW + 10,posY))
	self.bgLayer:addChild(girlDescBg)


	local function callBack(...)
		return self:eventHandler(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(bgW,self.desH),nil)
	self.bgLayer:addChild(self.tv)
	self.tv:setAnchorPoint(ccp(0,0))
	self.tv:setPosition(ccp(imgW + 10,posY - self.desH/2))
	self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
	self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv:setMaxDisToBottomOrTop(10)
end

-- 面板下部分
function acCallsDialog:initBottom()
	self.exchangeBtns = {}

    local num = 3 -- 一共有三个图标

    local msgH = 0
    local msg = nil

    local maxMsgH = 0
    local msgs = {}
    local day = acCallsVoApi:getOnlineDayCfg()
    local vip = 0
    for i=1,num do
    	vip = acCallsVoApi:getVipCfgByIndex(i)
		msgH, msg = self:getDes(getlocal("activity_calls_con",{day,vip}),G_VisibleSizeWidth - 340,24,false)
		msgs[i] = {msg = msg}
		if msgH > maxMsgH then
			maxMsgH= msgH
		end
    end

    if maxMsgH < 150 then
    	maxMsgH = 150
    end
    
    local bottomJianjv = 20
    local bgH = maxMsgH * num
    local bg=LuaCCScale9Sprite:createWithSpriteFrameName("RechargeBg.png",CCRect(20, 20, 10, 10),function () do return end end)
	bg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 40,bgH))
	bg:setAnchorPoint(ccp(0,0.5))
	bg:setPosition(ccp(20,bottomJianjv + bgH/2))
	self.bgLayer:addChild(bg)

    local btnY = 0
    local iconX = 0
    local iconScale = 1
    local iconH = 100  --图标的高度
    local iconName = nil
    local icon = nil
    local rewardLb = nil

    for i=1,num do

    	btnY = bottomJianjv + maxMsgH * (i - 1) + maxMsgH/2

    	local function exchange(tag,object)
		    if G_checkClickEnable()==false then
			    do
			        return
			    end
		    else
                base.setWaitTime=G_getCurDeviceMillTime()
		    end
            PlayEffect(audioCfg.mouseClick)
		    local tip = nil
		    if  G_getTankIsguest()=="1" then 
		    	tip = getlocal("activity_calls_tip4")
                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),tip,nil,self.layerNum+1)
                do
                  return
                end
		    end

		    local doGoTo = false -- 是否跳转充值页面
		    if acCallsVoApi:onLineAndGetAllReward() == true then
			    local index = acCallsVoApi:getCanReward()
			    if index > 0 then
				    if index == tag then

				    	local function getStatusSuccess(fn,data)
				    		local ret,sData=base:checkServerData(data)
			                if ret==true and sData.resCode ~= nil then
			                	acCallsVoApi:afterPushStatus(sData.resCode)
			                	self:openExchangeDialog()
					        end
					    end
					    local tid = acCallsVoApi:getTId()
                        if tid ~= 0 then
					        socketHelper:getCallsStatus(tid, getStatusSuccess)
                        else
                        	self:openExchangeDialog()
                        end


			            
			        elseif index < tag then
			        	doGoTo = true
		                if tag == 3 then
		                    tip = getlocal("activity_calls_tip1",{acCallsVoApi:getVipCfgByIndex(3)})
		                else
		                    tip = getlocal("activity_calls_tip1",{acCallsVoApi:getVipCfgByIndex(2)})
		                end
			        elseif index > tag then
		                tip = getlocal("activity_calls_tip2")
			        end
			    else
			    	doGoTo = true
			        tip = getlocal("activity_calls_tip1",{acCallsVoApi:getVipCfgByIndex(tag)})              
			    end
			else
				tip = getlocal("activity_calls_tip3",{acCallsVoApi:getOnlineDayCfg()})
			end
			if tip ~= nil then
				if doGoTo == false then
	                smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("dialog_title_prompt"),tip,nil,self.layerNum+1)
                else
                	local function gotoRecharge()
	                    activityAndNoteDialog:gotoByTag(9)
	                end
	                smallDialog:showSureAndCancle("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),gotoRecharge,getlocal("dialog_title_prompt"),tip,nil,self.layerNum+1)
                end
            end
		end

	    local btn =GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",exchange,i,getlocal("code_gift"),25)
	    local menu =CCMenu:createWithItem(btn)
	    menu:setPosition(ccp(G_VisibleSizeWidth - 30 - btn:getContentSize().width/2,btnY))
	    menu:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.bgLayer:addChild(menu)
	    self.exchangeBtns[i] = btn
	    if acCallsVoApi:checkIfHadReward() == true then
	    	btn:setEnabled(false)
	    end

		if i == 1 then
    		iconName = "k30.png"
    	elseif i == 2 then
    		iconName = "k50.png"
    	else
    		iconName= "k100.png"
    	end
        
        iconX = iconH/2 + 30
    	icon=CCSprite:createWithSpriteFrameName(iconName)
    	iconScale = iconH/icon:getContentSize().height
		icon:setScale(iconScale)
		icon:setPosition(ccp(iconX,btnY))
		self.bgLayer:addChild(icon)
        
        local money = acCallsVoApi:getMoneyCfgByIndex(i)
        rewardLb = GetTTFLabel(getlocal("activity_calls_reward",{money}),25)
        rewardLb:setAnchorPoint(ccp(0.5,0))
        rewardLb:setPosition(ccp((icon:getContentSize().width * iconScale)/2,2))
        rewardLb:setColor(G_ColorYellowPro)
        icon:addChild(rewardLb)

		msg = msgs[i].msg
        msg:setAnchorPoint(ccp(0, 0.5))
	    msg:setPosition(ccp(iconH + 40,btnY))
		self.bgLayer:addChild(msg)
    end

    local posY = bgH + bottomJianjv + 20 -- 20 是距离下面的间距
    local function showInfo()
    	if G_checkClickEnable()==false then
		    do
		        return
		    end
	    else
            base.setWaitTime=G_getCurDeviceMillTime()
	    end
    	PlayEffect(audioCfg.mouseClick)
        local tabStr={" ",getlocal("activity_calls_rule4")," ",getlocal("activity_calls_rule3")," ",getlocal("activity_calls_rule2")," ",getlocal("activity_calls_rule1")," ",getlocal("activity_getRich_notice")," "}
        PlayEffect(audioCfg.mouseClick)
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,25,nil)
        sceneGame:addChild(dialog,self.layerNum+1)
    end
    local infoItem = GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",showInfo,11,nil,nil)
    infoItem:setAnchorPoint(ccp(0,0.5))
    local infoBtn = CCMenu:createWithItem(infoItem)
    infoBtn:setPosition(ccp(110,posY + infoItem:getContentSize().height/2))
    infoBtn:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(infoBtn)
    local btnH = infoItem:getContentSize().height
    if acCallsVoApi:onLineAndGetAllReward() == false then
	    -- 前往按钮
		local function goto(tag,object)
		    if G_checkClickEnable()==false then
		        do
		            return
		        end
	        else
	            base.setWaitTime=G_getCurDeviceMillTime()
		    end
		    PlayEffect(audioCfg.mouseClick)
		    local newGiftsState=newGiftsVoApi:hasReward()
		    if newGiftsState ~=-1 then
		          --七日登录送好礼
                require "luascript/script/game/scene/gamedialog/newGiftsDialog"
		        local nd = newGiftsDialog:new()
		        local tbArr={}
		        local vd = nd:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("newGiftsTitle"),true,self.layerNum + 1)
		        sceneGame:addChild(vd,self.layerNum + 1)
		    end
		    -- activityAndNoteDialog:gotoByTag(8)
		end

	    local rechargeBtn =GetButtonItem("BtnRecharge.png","BtnRecharge.png","BtnRecharge.png",goto,nil,getlocal("activity_calls_btn"),28)
	    rechargeBtn:setAnchorPoint(ccp(1, 0.5))
	    self.rechargeMenu=CCMenu:createWithItem(rechargeBtn)
	    self.rechargeMenu:setPosition(ccp(G_VisibleSizeWidth-110,posY + btnH/2))
	    self.rechargeMenu:setTouchPriority(-(self.layerNum-1)*20-5)
	    self.bgLayer:addChild(self.rechargeMenu)    
	end
    
    return posY + btnH
end

function acCallsDialog:openExchangeDialog()
	self.openDialog = acCallsExchangeDialog:new(self.layerNum + 1)
    local vd = self.openDialog:init("panelBg.png",true,CCSizeMake(768,800),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,nil,nil,getlocal("code_gift"),true,self.layerNum + 1)
    sceneGame:addChild(vd,self.layerNum + 1)
end


function acCallsDialog:eventHandler(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 1
	elseif fn=="tableCellSizeForIndex" then
		return  CCSizeMake(G_VisibleSizeWidth - 200,self.desH)
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()
		self.des:setAnchorPoint(ccp(0,0.5))
		self.des:setPosition(ccp(10,self.desH/2))
		cell:addChild(self.des)
		return cell
	elseif fn=="ccTouchBegan" then
		self.isMoved=false
		return true
	elseif fn=="ccTouchMoved" then
		self.isMoved=true
	elseif fn=="ccTouchEnded"  then

	end
end

function acCallsDialog:update()
  local acVo = acCallsVoApi:getAcVo()
  if acVo ~= nil then
    if activityVoApi:isStart(acVo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
      if self ~= nil then
      	if self.openDialog ~= nil then
      		self.openDialog:close()
      	end
        self:close()
      end
    elseif self ~= nil then -- 如果数据发生了改变并且当前板子还打开着，就要刷新板子
    	if self.openDialog ~= nil then
    		self.openDialog:update()
    	end

	    if acCallsVoApi:onLineAndGetAllReward() == true and self.rechargeMenu ~= nil then
	      self.rechargeMenu:setVisible(false)
	    end

	    if acCallsVoApi:checkIfHadReward() == true then
           for k,v in pairs(self.exchangeBtns) do
           	   if v ~= nil then
           	   	v:setEnabled(false)
           	   end
           end
	    end
    end
  end
end

function acCallsDialog:dispose()
	self.des = nil -- 页面描述信息
    self.desH = nil -- 页面描述信息的高度

    self.rechargeMenu = nil
    self.exchangeBtns = nil
    self.openDialog = nil
end