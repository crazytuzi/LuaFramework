acGzhxDialogTab1={}

function acGzhxDialogTab1:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.bgLayer=nil
	self.layerNum=nil
	self.isToday=nil
	self.heightTab={}
	self.fastTickIndex=nil
	self.secondDialog=nil
	return nc
end

function acGzhxDialogTab1:init(layerNum)
	self.bgLayer=CCLayer:create()
	self.layerNum=layerNum
	self.rate=acGzhxVoApi:getBigrewardsRate()
	self:initLayer1()
	return self.bgLayer
end
function acGzhxDialogTab1:initLayer1( ... )
	local function bgClick()
	end

	local w = G_VisibleSizeWidth - 50 -- 背景框的宽度
	local backSprie = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),bgClick)
	backSprie:setContentSize(CCSizeMake(w, 200))
	backSprie:setAnchorPoint(ccp(0.5,0))
	backSprie:setPosition(ccp(G_VisibleSizeWidth/2, G_VisibleSizeHeight - 365))
	self.bgLayer:addChild(backSprie)
	backSprie:setOpacity(0)
  
	local function touch(tag,object)
		PlayEffect(audioCfg.mouseClick)
		local tabStr={}
		tabStr={getlocal("activity_gzhx_Tab1_desc1"),getlocal("activity_gzhx_Tab1_desc2"),getlocal("activity_gzhx_Tab1_desc3")}
		local colorTb={}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr,colorTb)
	end

	w = w - 10 -- 按钮的x坐标
	local menuItemDesc=GetButtonItem("BtnInfor.png","BtnInfor_Down.png","BtnInfor_Down.png",touch,nil,nil,0)
	menuItemDesc:setAnchorPoint(ccp(1,0.5))
	local menuDesc=CCMenu:createWithItem(menuItemDesc)
	menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
	menuDesc:setPosition(ccp(w, backSprie:getContentSize().height-50))
	backSprie:addChild(menuDesc)
  
	w = w - menuItemDesc:getContentSize().width

	local acLabel = GetTTFLabel(getlocal("activity_timeLabel"),28)
	acLabel:setAnchorPoint(ccp(0.5,1))
	acLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 190))
	backSprie:addChild(acLabel)
	acLabel:setColor(G_ColorYellowPro)

	local acVo = acGzhxVoApi:getAcVo()
	local timeStr=activityVoApi:getActivityTimeStr(acVo.st,acVo.acEt)
	local messageLabel=GetTTFLabel(timeStr,28)
	messageLabel:setAnchorPoint(ccp(0.5,1))
	messageLabel:setPosition(ccp((G_VisibleSizeWidth - 20)/2, 150))
	backSprie:addChild(messageLabel)
	messageLabel:setColor(G_ColorYellowPro)
	self.timeLb=messageLabel
    self:updateAcTime()


	local desTv, desLabel = G_LabelTableView(CCSizeMake(backSprie:getContentSize().width-60, 110),getlocal("activity_gzhx_Tab1_desc"),25,kCCTextAlignmentLeft)
	backSprie:addChild(desTv)
	desTv:setPosition(ccp(30,5))
	desTv:setAnchorPoint(ccp(0,0))
	desTv:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	desTv:setMaxDisToBottomOrTop(100)
	desLabel:setColor(G_ColorGreen)


   local background=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray3.png",CCRect(50,50,1,1),function () end)
	background:setContentSize(CCSizeMake(G_VisibleSizeWidth-50,G_VisibleSizeHeight-400))
	background:setAnchorPoint(ccp(0.5,0))
	background:setPosition(ccp(G_VisibleSizeWidth/2,30))
	self.bgLayer:addChild(background)

	local lineSp1=CCSprite:createWithSpriteFrameName("openyear_line.png")
	background:addChild(lineSp1,1)
	lineSp1:setPosition(background:getContentSize().width/2,background:getContentSize().height-2)
	lineSp1:setScaleX((background:getContentSize().width*0.8)/lineSp1:getContentSize().width)

	self:initCellHeight()
	local function callBack(...)
		return self:eventHandler1(...)
	end
	local hd= LuaEventHandler:createHandler(callBack)
 	self.tv1=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(background:getContentSize().width,background:getContentSize().height-20),nil)
	self.tv1:setPosition(ccp(0,10))
	self.tv1:setTableViewTouchPriority(-(self.layerNum-1)*20-4)
	self.tv1:setMaxDisToBottomOrTop(100)
	background:addChild(self.tv1,1)
end
function acGzhxDialogTab1:initCellHeight( ... )
	local cellheight
	cellheight=180
	self.heightTab[1]=cellheight
	cellheight=260
	self.heightTab[2]=cellheight
	local lotteryDesc1 = GetTTFLabelWrap(getlocal("activity_refitPlanT99_lotteryDesc1"),25,CCSizeMake(self.bgLayer:getContentSize().width-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	local lotteryDesc2 = GetTTFLabelWrap(getlocal("activity_refitPlanT99_lotteryDesc2"),25,CCSizeMake(self.bgLayer:getContentSize().width-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
	cellheight=lotteryDesc1:getContentSize().height + lotteryDesc2:getContentSize().height+20
	self.heightTab[3]=cellheight
	cellheight=445
	self.heightTab[4]=cellheight
end
function acGzhxDialogTab1:eventHandler1(handler,fn,idx,cel)
	if fn=="numberOfCellsInTableView" then
		return 4
	elseif fn=="tableCellSizeForIndex" then
		local tmpSize
		local cHeight = self.heightTab[idx+1]
		tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-50,cHeight)
		return  tmpSize
	elseif fn=="tableCellAtIndex" then
		local cell=CCTableViewCell:new()
		cell:autorelease()

		local cellHeight = self.heightTab[idx+1]
		if idx ==0 then
			local bigRewardLb = GetTTFLabelWrap(getlocal("activity_refitPlanT99_bigReward"),30,CCSizeMake(G_VisibleSizeWidth-100,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			bigRewardLb:setAnchorPoint(ccp(0,1))
			bigRewardLb:setPosition(10,cellHeight-10)
			bigRewardLb:setColor(G_ColorYellow)
			cell:addChild(bigRewardLb)

			local bigRewardsCfg=acGzhxVoApi:getBigRewardsCfg()

			local rewardCfg=FormatItem(bigRewardsCfg,true,true)
			if rewardCfg ~= nil then
			    local oneLen = 120
			    local firstX = 20
			    for k,v in pairs(rewardCfg) do
			    	local function showNewPropInfo()
	                    G_showNewPropInfo(self.layerNum+1,true,true,nil,v)
	                    return false
	                end
			        local icon, iconScale = G_getItemIcon(v, 100, true, self.layerNum,showNewPropInfo)
			        iconX = (k-1) * oneLen + oneLen/2 + firstX
			        icon:ignoreAnchorPointForPosition(false)
			        icon:setAnchorPoint(ccp(0.5,1))
			        icon:setPosition(ccp(iconX,cellHeight-bigRewardLb:getContentSize().height-30))
			        icon:setIsSallow(false)
			        icon:setTouchPriority(-(self.layerNum-1)*20-3)
			        cell:addChild(icon,1)
			        icon:setTag(k)

			        local numLabel=GetTTFLabel("x"..v.num,25)
		            numLabel:setAnchorPoint(ccp(1,0))
		            numLabel:setPosition(icon:getContentSize().width-10,10)
		            icon:addChild(numLabel,1)
		            numLabel:setScaleX(1/iconScale)
		            numLabel:setScaleY(1/iconScale)
			    end
			end

		elseif idx ==1 then
			local bigRewardProLb=GetTTFLabel(getlocal("activity_refitPlanT99_bigRewardRate"),30)
			bigRewardProLb:setAnchorPoint(ccp(0,0))
			bigRewardProLb:setPosition(ccp(10,cellHeight-50))
			bigRewardProLb:setColor(G_ColorYellow)
			cell:addChild(bigRewardProLb)

			local rewardRateStr = acGzhxVoApi:getBigrewardsRate()

			self.rewardRateLb = GetBMLabel(rewardRateStr,G_GoldFontSrc,30+(rewardRateStr-1)*5)
			self.rewardRateLb:setAnchorPoint(ccp(0,0.5))
			self.rewardRateLb:setPosition(ccp(bigRewardProLb:getContentSize().width+10,cellHeight-30))
			self.rewardRateLb:setColor(G_ColorYellow)
			cell:addChild(self.rewardRateLb)

			local bigRewardProLb1=GetTTFLabel(getlocal("activity_refitPlanT99_bigRewardRateAdd"),30)
			bigRewardProLb1:setPosition(ccp(10+bigRewardProLb:getContentSize().width+self.rewardRateLb:getContentSize().width,cellHeight-50))
			bigRewardProLb1:setAnchorPoint(ccp(0,0))
			bigRewardProLb1:setColor(G_ColorYellow)
			cell:addChild(bigRewardProLb1)

			if G_getCurChoseLanguage() =="ar" then
				bigRewardProLb1:setPosition(ccp(10,cellHeight-50))
				self.rewardRateLb:setPosition(ccp(10+bigRewardProLb1:getContentSize().width,cellHeight-30))
				bigRewardProLb:setPosition(ccp(10+bigRewardProLb1:getContentSize().width + self.rewardRateLb:getContentSize().width,cellHeight-50))
			end

			local function cellClick( ... )
				-- body
			end 

			local rewardBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),cellClick)
			rewardBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-60,188))
			rewardBg:ignoreAnchorPointForPosition(false)
			rewardBg:setAnchorPoint(ccp(0.5,1))
			rewardBg:setIsSallow(false)
			rewardBg:setTouchPriority(-(self.layerNum-1)*20-2)
			cell:addChild(rewardBg)
			rewardBg:setPosition(ccp((self.bgLayer:getContentSize().width-50)/2,cellHeight-70))

			local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
			pointSp1:setPosition(ccp(5,rewardBg:getContentSize().height/2))
			rewardBg:addChild(pointSp1)
			local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
			pointSp2:setPosition(ccp(rewardBg:getContentSize().width-5,rewardBg:getContentSize().height/2))
			rewardBg:addChild(pointSp2)

			local vo=acGzhxVoApi:getAcVo()
			local free=0							--是否是第一次免费
			if acGzhxVoApi:isToday()==true then
				free=1
			end

			local gemCost=acGzhxVoApi:getLotteryOnceCost()--cfg.serverreward.gemCost
			local oneGems=gemCost				--一次抽奖需要金币
			local tenGems=acGzhxVoApi:getLotteryTenCost()			--十次抽奖需要金币

			local function btnCallback(tag,object)
				if self and self.tv1 and self.tv1:getScrollEnable()==true and self.tv1:getIsScrolled()==false then
          			if G_checkClickEnable()==false then
				        do
				            return
				        end
				    else
				        base.setWaitTime=G_getCurDeviceMillTime()
				    end 

				    PlayEffect(audioCfg.mouseClick)

					local num
					if tag==1 or tag==3 then
						if free==1 and playerVoApi:getGems()<oneGems then
							GemsNotEnoughDialog(nil,nil,oneGems-playerVoApi:getGems(),self.layerNum+1,oneGems)
							do return end
						end
						num=1
					elseif tag==2 then
						if playerVoApi:getGems()<tenGems then
							GemsNotEnoughDialog(nil,nil,tenGems-playerVoApi:getGems(),self.layerNum+1,tenGems)
							do return end
						end
						num=10
					end
					local activeName=acGzhxVoApi:getActiveName()
					local function lotteryCallback(fn,data)
				        local ret,sData=base:checkServerData(data)
				        if ret==true then
				        	if sData.data==nil then
				        		do return end
				        	end
				        	
				        	if tag==1 or tag==3 then
				        		if free==1 then
				            		playerVoApi:setValue("gems",playerVoApi:getGems()-oneGems)
				            	end
				            elseif tag==2 then
								playerVoApi:setValue("gems",playerVoApi:getGems()-tenGems)
							end

							--刷新活动数据
				        	local tipStr=""
				        	local getTank1=false
				        	local getTank2=false
				        	if sData.data[activeName]["clientReward"] then
								local awardData=sData.data[activeName]["clientReward"]

                                local isHasT99=false
								local content = {}
								local aid,tankID = acGzhxVoApi:getTankID()
								for k,v in pairs(awardData) do
									local award = {}
									local name,pic,desc,id,index,eType,equipId=getItem(v.t,v.p)
									local num=v.n
									local point = v.r
									local award={name=name,num=num,pic=pic,desc=desc,id=id,type=v.p,index=index,key=v.t,eType=eType,equipId=equipId}
									G_addPlayerAward(award.type,award.key,award.id,award.num,nil,true)
									table.insert(content,{award=award,point=point})

                                    if v.t==aid and v.p=="o" then
                                        isHasT99=true
                                    end
								end

                                if isHasT99==true then
                                    --聊天公告
                                    local paramTab={}
                                    paramTab.functionStr=activeName
                                    paramTab.addStr="i_also_want"
                                    local nameData={key=tankCfg[tankID].name,param={}}
                                    local message={key="activity_gzhx_chatMessage2",param={playerVoApi:getPlayerName(),getlocal("activity_gzhx_title"),nameData}}
                                    chatVoApi:sendSystemMessage(message,paramTab)
                                end
								acGzhxVoApi:updateData(sData.data[activeName])
								if content and SizeOfTable(content)>0 then
	                                local function confirmHandler(index)
		                            	local rate= acGzhxVoApi:getBigrewardsRate()
		                            	if rate>self.rate then
		                            		self:initChangeEff(self.rate,acGzhxVoApi:getBigrewardsRate())
		                            	else
		                            		self.rate=acGzhxVoApi:getBigrewardsRate()
		                            		self.tv1:reloadData()
		                            	end
	                                end
	                                smallDialog:showSearchEquipDialog("TankInforPanel.png",CCSizeMake(550,650),CCRect(0, 0, 400, 350),CCRect(130, 50, 1, 1),getlocal("activity_wheelFortune4_reward"),content,nil,true,self.layerNum+1,confirmHandler,true,true,nil,nil,true,nil,nil,nil,nil,nil,nil,nil,nil,nil,200)
	                            end
							end
							
							
				        end
					end

					local function sureClick()
			            socketHelper:acGzhxReward(num,free,lotteryCallback,activeName)
			            self.secondDialog=nil
			        end
			        local function cancelClick()
			        	self.secondDialog=nil
			        end
			        local function secondTipFunc(sbFlag)
			            local sValue=base.serverTime .. "_" .. sbFlag
			            G_changePopFlag(activeName,sValue)
			        end

			        if tag==1 or tag==2 then
			        	local needCost=oneGems
			        	if tag==2 then
			        		needCost=tenGems
			        	end
			            if G_isPopBoard(activeName) then
			                self.secondDialog=G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{needCost}),true,sureClick,secondTipFunc,cancelClick)
			            else
			                sureClick()
			            end
			            
			        else
			            sureClick()
			        end
				    
        		end
				
			end

			local leftPosX=rewardBg:getContentSize().width/2-150
			local rightPosX=rewardBg:getContentSize().width/2+150

			local lbY=117
			local goldSp1=CCSprite:createWithSpriteFrameName("IconGold.png")
			goldSp1:setAnchorPoint(ccp(1,0.5))
		    goldSp1:setPosition(ccp(leftPosX-10,lbY))
		    rewardBg:addChild(goldSp1)
		    goldSp1:setScale(1.5)

			local gemsLabel1=GetTTFLabel(oneGems,25)
			gemsLabel1:setAnchorPoint(ccp(0,0.5))
		    gemsLabel1:setPosition(ccp(leftPosX,lbY))
		    rewardBg:addChild(gemsLabel1,1)

			local goldSp2=CCSprite:createWithSpriteFrameName("IconGold.png")
			goldSp2:setAnchorPoint(ccp(1,0.5))
		    goldSp2:setPosition(ccp(rightPosX-10,lbY))
		    rewardBg:addChild(goldSp2)
		    goldSp2:setScale(1.5)

			local gemsLabel2=GetTTFLabel(tenGems,25)
			gemsLabel2:setAnchorPoint(ccp(0,0.5))
		    gemsLabel2:setPosition(ccp(rightPosX,lbY))
		    rewardBg:addChild(gemsLabel2,1)

			local btnY=50
			local lotteryOneBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",btnCallback,1,getlocal("active_lottery_btn1"),25)
			lotteryOneBtn:setAnchorPoint(ccp(0.5,0.5))
		    local lotteryMenu=CCMenu:createWithItem(lotteryOneBtn)
		    lotteryMenu:setPosition(ccp(leftPosX,btnY))
		    lotteryMenu:setTouchPriority(-(self.layerNum-1)*20-3)
		    rewardBg:addChild(lotteryMenu,2)

			local freeBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",btnCallback,3,getlocal("active_lottery_btn1"),25)
			freeBtn:setAnchorPoint(ccp(0.5,0.5))
		    local freeMenu=CCMenu:createWithItem(freeBtn)
		    freeMenu:setPosition(ccp(leftPosX,btnY))
		    freeMenu:setTouchPriority(-(self.layerNum-1)*20-3)
		    rewardBg:addChild(freeMenu,2)

			local lotteryTenBtn=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",btnCallback,2,getlocal("active_lottery_btn2"),25)
			lotteryTenBtn:setAnchorPoint(ccp(0.5,0.5))
		    local lotteryMenu1=CCMenu:createWithItem(lotteryTenBtn)
		    lotteryMenu1:setPosition(ccp(rightPosX,btnY))
		    lotteryMenu1:setTouchPriority(-(self.layerNum-1)*20-3)
		    rewardBg:addChild(lotteryMenu1,2)


		    if free==0 then
				goldSp1:setVisible(false)
				lotteryTenBtn:setEnabled(false)
				gemsLabel1:setString(getlocal("daily_lotto_tip_2"))
				gemsLabel1:setPosition(leftPosX-25,lbY)
				lotteryOneBtn:setVisible(false)
			else
				freeMenu:setVisible(false)
				goldSp1:setVisible(true)
				lotteryTenBtn:setEnabled(true)
				gemsLabel1:setString(oneGems)
				gemsLabel1:setPosition(leftPosX,lbY)
			end

		elseif idx ==2 then
			local lotteryDesc1 = GetTTFLabelWrap(getlocal("activity_refitPlanT99_lotteryDesc1",{acGzhxVoApi:getMaxRate()}),25,CCSizeMake(self.bgLayer:getContentSize().width-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			lotteryDesc1:setAnchorPoint(ccp(0,1))
			lotteryDesc1:setPosition(ccp(10,cellHeight-10))
			cell:addChild(lotteryDesc1)
			lotteryDesc1:setColor(G_ColorRed)
			local lotteryDesc2 = GetTTFLabelWrap(getlocal("activity_refitPlanT99_lotteryDesc2"),25,CCSizeMake(self.bgLayer:getContentSize().width-70,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
			lotteryDesc2:setAnchorPoint(ccp(0,1))
			lotteryDesc2:setPosition(ccp(10,cellHeight-lotteryDesc1:getContentSize().height-10))
			cell:addChild(lotteryDesc2)
			lotteryDesc2:setColor(G_ColorRed)
		elseif idx ==3 then
			local function nilFunc( ... )
				
			end 
			local tankBg = LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),nilFunc)
			local size=CCSizeMake(self.bgLayer:getContentSize().width-60,cellHeight)
			tankBg:setContentSize(size)
			tankBg:setAnchorPoint(ccp(0,1))
			tankBg:setPosition(ccp(5,cellHeight))
			cell:addChild(tankBg)
			tankBg:setOpacity(0)

			local lineSp2=CCSprite:createWithSpriteFrameName("openyear_line.png")
			tankBg:addChild(lineSp2,2)
			lineSp2:setPosition(tankBg:getContentSize().width/2,tankBg:getContentSize().height-10)
			lineSp2:setScaleX((tankBg:getContentSize().width*0.9)/lineSp2:getContentSize().width)

			-- 背景 线上现在
		    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
		    local url=G_downloadUrl("active/" .. "acWmzz_bg.jpg")
		    local function onLoadIcon(fn,icon)
		        if self and self.bgLayer and tankBg then
		            icon:setAnchorPoint(ccp(0.5,1))
		            icon:setScale(0.95)
		            tankBg:addChild(icon)
		            icon:setPosition(tankBg:getContentSize().width/2,tankBg:getContentSize().height-15)
		        end
		    end
		    local webImage=LuaCCWebImage:createWithURL(url,onLoadIcon)
		    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
		    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

			local updateTitleLb = GetTTFLabelWrap(getlocal("activity_gzhx_tankUpdate"),30,CCSizeMake(tankBg:getContentSize().width/2-10,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
			updateTitleLb:setAnchorPoint(ccp(0,0.5))
			updateTitleLb:setPosition(ccp(10,cellHeight-50))
			tankBg:addChild(updateTitleLb,2)
			updateTitleLb:setColor(G_ColorYellow)

			
			local aid,tankID = acGzhxVoApi:getTankID()
			if tankID then

				local cfg = tankCfg[tankID]

				-- local url2=G_downloadUrl("active/" .. "acGzhx_tank1.png")
				-- local function onLoadIcon(fn,icon)
				-- 	if self and self.bgLayer and tankBg then
				local loadIcon=CCSprite:create("public/acGzhx_tank1.png")
				loadIcon:setScale(0.9)
				loadIcon:setAnchorPoint(ccp(0,1))
				loadIcon:setPosition(ccp(tankBg:getContentSize().width/2-90,cellHeight-40))
				tankBg:addChild(loadIcon,2)
				-- 	end
				-- end
				-- local webImage2=LuaCCWebImage:createWithURL(url2,onLoadIcon)
				

				local iconWidth = 100
				local subH=60
				local attackSp = CCSprite:createWithSpriteFrameName("pro_ship_attack.png");
				attackSp:setAnchorPoint(ccp(0,0.5));
				attackSp:setPosition(ccp(25,cellHeight-50-updateTitleLb:getContentSize().height/2-80-subH))
				attackSp:setScale(77/attackSp:getContentSize().height)
				tankBg:addChild(attackSp,2)

				local attLb=GetTTFLabel(cfg.attack,25)
				attLb:setAnchorPoint(ccp(0,0.5))
				attLb:setPosition(ccp(25+iconWidth,cellHeight-50-updateTitleLb:getContentSize().height/2-80-subH))
				tankBg:addChild(attLb,2)

				local lifeSp = CCSprite:createWithSpriteFrameName("pro_ship_life.png");
				lifeSp:setAnchorPoint(ccp(0,0.5))
				lifeSp:setPosition(ccp(25,cellHeight-50-updateTitleLb:getContentSize().height/2-160-subH))
				lifeSp:setScale(77/lifeSp:getContentSize().height)
				tankBg:addChild(lifeSp,2)

				local lifeLb=GetTTFLabel(cfg.life,25)
				lifeLb:setAnchorPoint(ccp(0,0.5))
				lifeLb:setPosition(ccp(25+iconWidth,cellHeight-50-updateTitleLb:getContentSize().height/2-160-subH))
				tankBg:addChild(lifeLb,2)
				local buffLabel
				if cfg.buffType~=nil and cfg.buffvalue~=nil then
					local value=""
					if tonumber(cfg.buffvalue) <1 then
						value =(tonumber(cfg.buffvalue)*100).."%%"
					else
						value = cfg.buffvalue
					end
					local buffStr = getlocal("tankBuffName"..cfg.buffType,{value})
					local str=getlocal("activity_refitPlanT99_buff")..buffStr
					 buffLabel= GetTTFLabelWrap(str,27,CCSizeMake(tankBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					buffLabel:setAnchorPoint(ccp(0,1))
					buffLabel:setPosition(ccp(25,cellHeight-285-subH))
					tankBg:addChild(buffLabel,2)
				end

				local skillName
				if cfg.abilityID~=nil and abilityCfg[cfg.abilityID]~=nil then
				    skillName=abilityCfg[cfg.abilityID][tonumber(cfg.abilityLv)].name
				    local skillLabel = GetTTFLabelWrap(getlocal("activity_refitPlanT99_skill",{getlocal(skillName)}),27,CCSizeMake(tankBg:getContentSize().width-40,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
					skillLabel:setAnchorPoint(ccp(0,1))
					skillLabel:setPosition(ccp(25,cellHeight-270-buffLabel:getContentSize().height-30-subH))
					tankBg:addChild(skillLabel,2)
    			end
				
			end


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

function acGzhxDialogTab1:tick( ... )
	local today=acGzhxVoApi:isToday()
	if self.isToday~=today then
		self.tv1:reloadData()
		self.isToday=today
	end
	self:updateAcTime()
end
function acGzhxDialogTab1:initChangeEff(number1,number2)
    self.isTouch=false
    self.isUseAmi=true
    self.type="rateChangeeffect"
    local str1=tostring(number1)
    local str2=tostring(number2)
    --如果数字1大于数字2, 那么数字变化趋势是减少, 否则就是增加
    if(number1>number2)then
        self.rateChangeFlag=0
        self.rateChangeStrlen=string.len(str1)
    else
        self.rateChangeFlag=1
        self.rateChangeStrlen=string.len(str2)
    end

    self.rateChangeStart=number1
    self.rateChangeEnd=number2
    self.rateChangeStartTb={}
    self.rateChangeEndTb={}
    self.rateChangeTmpTb={}
    local length=string.len(str1)
    for i=1,length do
        local num=tonumber(string.sub(str1,0-i,0-i))
        table.insert(self.rateChangeStartTb,num)
        table.insert(self.rateChangeTmpTb,num)
    end
    length=string.len(str2)
    for i=1,length do
        table.insert(self.rateChangeEndTb,tonumber(string.sub(str2,0-i,0-i)))
    end
    local capInSet = CCRect(20, 20, 10, 10);
    local function nilFunc(hd,fn,idx)
    end

    local function onScaleShow()
        self.fastTickIndex=0
        --base:addNeedRefresh(self)
    end
    local callFunc=CCCallFunc:create(onScaleShow)
    local scaleTo1=CCScaleTo:create(0.2, 1.1);
    local scaleTo2=CCScaleTo:create(0.1, 1);
    local delay=CCDelayTime:create(0.5)
    local acArr=CCArray:create()
    acArr:addObject(scaleTo1)
    acArr:addObject(scaleTo2)
    acArr:addObject(delay)
    acArr:addObject(callFunc)
    local seq=CCSequence:create(acArr)
    self.rewardRateLb:runAction(seq)
end

function acGzhxDialogTab1:fastTick()
	if self.fastTickIndex ~=nil then
	    if(self.type=="rateChangeeffect")then
	        if(self.fastTickIndex<=0)then
	            local allTickEnd=true
	            self.fastTickIndex=1
	            if(self.rateChangeFlag==0)then
	            else
	                for i=1,self.rateChangeStrlen do
	                    if(self.rateChangeTmpTb[i]~=self.rateChangeEndTb[i])then
	                        allTickEnd=false
	                        if(self.rateChangeTmpTb[i]~=nil)then
	                            self.rateChangeTmpTb[i]=self.rateChangeTmpTb[i]+1
	                            if(self.rateChangeTmpTb[i]>=10)then
	                                self.rateChangeTmpTb[i]=0
	                            end
	                        end
	                    end
	                end
	            end
	            local str=table.concat(self.rateChangeTmpTb)
	            if(self.rewardRateLb and self.rewardRateLb.setString)then
	                self.rewardRateLb=tolua.cast(self.rewardRateLb,"CCLabelBMFont")
	                self.rewardRateLb:setString(string.reverse(str))
	            end
	            if(allTickEnd)then
	            	self.rateChangeStart=nil
	                self.rateChangeEnd=nil
	                self.rateChangeStartTb=nil
	                self.rateChangeEndTb=nil
	                self.rateChangeTmpTb=nil
	                self.rateChangeRollTogether=nil
	                --base:removeFromNeedRefresh(self)
	                self.fastTickIndex =nil
	                self.rate=acGzhxVoApi:getBigrewardsRate()
	                self.tv1:reloadData()
	            end
	        else
	            self.fastTickIndex=self.fastTickIndex-1
	        end
	    end
	end
end

function acGzhxDialogTab1:updateAcTime()
	local acVo=acGzhxVoApi:getAcVo()
	if acVo and self.timeLb then
		G_updateActiveTime(acVo,self.timeLb)
	end
end

function acGzhxDialogTab1:dispose()
	if self.secondDialog and self.secondDialog.close then
        self.secondDialog:close()
    end
    self.bgLayer=nil
end



