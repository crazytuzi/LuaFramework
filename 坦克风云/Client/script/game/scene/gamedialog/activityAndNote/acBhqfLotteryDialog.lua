--百花齐放
--author: ym
acBhqfLotteryDialog={}

function acBhqfLotteryDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	nc.bgLayer=nil
	return nc
end

function acBhqfLotteryDialog:init(layerNum)
	if acBhqfVoApi and acBhqfVoApi:getVersion()==2 then
		self.showtb={{'H',1},{'A',1},{'V',1},{'E',1},{'A',2},{'G',1},{'O',1},{'O',2},{'D',1},{'T',1},{'I',1},{'M',1},{'E',2}}
		self.wptb={
			A={{292, 663},{135, 606}},
			E={{378, 662},{500, 606}},
			H={{245, 667}},
			V={{333, 669}},
			G={{200, 606}},
			O={{243, 605},{283, 607}},
			D={{322, 606}},
			T={{387, 606}},
			I={{420, 604}},
			M={{460, 607}},
		}
	else
		self.showtb={{'H',1},{'A',1},{'P',1},{'P',2},{'Y',1},{'N',1},{'E',1},{'W',1},{'Y',2},{'E',2},{'A',2},{'R',1}}
		self.wptb={
			A={{422.5, 608},{278.5, 663}},
			E={{378.5, 608},{214.5, 605}},
			H={{231.5, 667}},
			N={{170.5, 606}},
			P={{368, 662},{324, 669}},
			R={{470.5, 607}},
			W={{264.5, 611.5}},
			Y={{336, 606.5},{409, 665.5}}
		}
	end
	self.isToday=acBhqfVoApi:isToday()
	self.isAction=false
	self.removeTb={}
	self.showWordTb={}

	self.layerNum=layerNum
	self.bgLayer=CCLayer:create()
	self:initContent()
	self:initBtns()
	self:refreshUI()
	return self.bgLayer
end

function acBhqfLotteryDialog:updateAcTime()
	local acVo=acBhqfVoApi:getAcVo()
	if acVo and self.timeLb and tolua.cast(self.timeLb,"CCLabelTTF") then
		self.timeLb:setString(getlocal("activityCountdown")..": "..G_formatActiveDate(acVo.et - base.serverTime))
	end
end

function acBhqfLotteryDialog:initContent()
	local acVo=acBhqfVoApi:getAcVo()
	if not acVo then
		do return end
	end

	self.yanhuaBgTb={}
	local addY,addH=0,0
	if G_isIphone5() then
		addY,addH=60,0
	end
	for i=1,5 do
		local capInSet = CCRect(20, 20, 10, 10)
		local yanhuaBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,function ()end)
		yanhuaBg:ignoreAnchorPointForPosition(false)
		yanhuaBg:setAnchorPoint(ccp(0,0))
		local sz,ps
		if i==1 then
			sz=CCSizeMake(130,140)
			ps=ccp(90,520+addY)
		elseif i==2 then
			sz=CCSizeMake(130,140)
			ps=ccp(90+160,520+addY)
		elseif i==3 then
			sz=CCSizeMake(130,140)
			ps=ccp(90+160+160,520+addY)
		elseif i==4 then
			sz=CCSizeMake(180,100+addH)
			ps=ccp(170,400+addY)
		elseif i==5 then
			sz=CCSizeMake(180,100+addH)
			ps=ccp(170+200,400+addY)
		end
		yanhuaBg:setContentSize(sz)
		yanhuaBg:setPosition(ps)
		self.bgLayer:addChild(yanhuaBg,1)
		table.insert(self.yanhuaBgTb,yanhuaBg)
		yanhuaBg:setOpacity(0)
	end

	local posy
	if G_isIphone5() then
		posy=G_VisibleSizeHeight-205
	else
		posy=G_VisibleSizeHeight-190
	end
	self.timeLb=GetTTFLabel(getlocal("activityCountdown")..": "..G_formatActiveDate(acVo.et - base.serverTime),20)
	self.timeLb:setColor(G_ColorYellowPro)
	self.timeLb:setPosition(ccp(G_VisibleSizeWidth/2,posy))
	self.bgLayer:addChild(self.timeLb,1)
	self:updateAcTime()

	if G_isIphone5() then
		posy = posy - 0
	else
		posy = posy - 20
	end
	local function touchTip()
		local tabStr={getlocal("activity_bhqf_info1",{acVo.limitLv}),getlocal("activity_bhqf_info2"),getlocal("activity_bhqf_info3"),getlocal("activity_bhqf_info4")}
		require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
		tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
	end
	G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth - 60,posy),{},nil,nil,28,touchTip,true)

	local function onLoadImage(fn,image)
		if self.bgLayer and tolua.cast(self.bgLayer,"CCLayer") then
			local imagepy
			if G_isIphone5() then
				imagepy=G_VisibleSizeHeight/2 + 0
			else
				imagepy=G_VisibleSizeHeight/2 - 15
			end
			image:setPosition(ccp(G_VisibleSizeWidth/2,imagepy))
			local middleBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
		    middleBg:setContentSize(CCSizeMake(image:getContentSize().width+4,image:getContentSize().height+6))
		    middleBg:setPosition(ccp(G_VisibleSizeWidth/2,imagepy))
		    -- middleBg:setAnchorPoint(ccp(0.5,1))
		    self.bgLayer:addChild(middleBg)
			self.bgLayer:addChild(image)
			self.image=image
		end
	end
	local weburl="active/acBhqfBg1.png"
	if G_isIphone5() then
		weburl="active/acBhqfBg2.png"
	end
	local webImage=LuaCCWebImage:createWithURL(G_downloadUrl(weburl),onLoadImage)

	if G_isIphone5() then
		posy = posy - 110
	else
		posy = posy - 90
	end
    local strSize22 = 18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="ko" then
        strSize22 = 25
    end
    --奖励库
    local function rewardPoolHandler()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if self.isAction==true then
			do return end
		end
        --显示奖池
        local content={}
        local pool=acBhqfVoApi:getRewardPool()
        for k,rewardlist in pairs(pool) do
            local item={}
            item.rewardlist=rewardlist
            item.title={getlocal("activity_bhqf_poolTitle"),G_ColorYellowPro,strSize22}
            item.subTitle={getlocal("activity_bhqf_poolDesc")}
            table.insert(content,item)
        end
        local title={getlocal("award"),nil,30}
        require "luascript/script/game/scene/gamedialog/activityAndNote/acYswjSmallDialog"
        acYswjSmallDialog:showYswjRewardDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-200),CCRect(130,50,1,1),title,content,self.layerNum+1,nil,nil,nil,true)
    end
    local poolBtn=GetButtonItem("taskBox4.png","taskBox4.png","taskBox4.png",rewardPoolHandler,11)
    poolBtn:setScale(0.7)
    poolBtn:setAnchorPoint(ccp(0.5,0.5))
    local poolMenu=CCMenu:createWithItem(poolBtn)
    poolMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    poolMenu:setPosition(ccp(60,posy))
    self.bgLayer:addChild(poolMenu,1)
    local poolBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    poolBg:setAnchorPoint(ccp(0.5,0.5))
    poolBg:setContentSize(CCSizeMake(70,30))
    poolBg:setPosition(ccp(60,posy-50))
    poolBg:setOpacity(50)
    -- poolBg:setScale(1/poolBtn:getScale())
    self.bgLayer:addChild(poolBg,1)
    local poolLb=GetTTFLabelWrap(getlocal("award"),20,CCSize(130,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    poolLb:setPosition(poolBg:getContentSize().width/2,poolBg:getContentSize().height/2)
    poolLb:setColor(G_ColorYellowPro)
    poolBg:addChild(poolLb)


    local function logCallback()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        if self.isAction==true then
			do return end
		end
        self:logHandler()
    end
    local logBtn=GetButtonItem("bless_record.png","bless_record.png","bless_record.png",logCallback,11)
    logBtn:setScale(0.7)
    logBtn:setAnchorPoint(ccp(0.5,0.5))
    local logMenu=CCMenu:createWithItem(logBtn)
    logMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    logMenu:setPosition(ccp(G_VisibleSizeWidth-60,posy))
    self.bgLayer:addChild(logMenu,1)
    local logBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60,20,1,1),function ()end)
    logBg:setAnchorPoint(ccp(0.5,0.5))
    logBg:setContentSize(CCSizeMake(70,30))
    logBg:setOpacity(50)
    logBg:setPosition(ccp(G_VisibleSizeWidth-60,posy-50))
    -- logBg:setScale(1/logBtn:getScale())
    self.bgLayer:addChild(logBg,1)
    local logLb=GetTTFLabelWrap(getlocal("serverwar_point_record"),20,CCSize(100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    logLb:setPosition(logBg:getContentSize().width/2,logBg:getContentSize().height/2)
    logLb:setColor(G_ColorYellowPro)
    logBg:addChild(logLb)

	for k,v in pairs(self.showtb) do
		local char=v[1]
		local num=v[2]
		local sp1=CCSprite:createWithSpriteFrameName("acWord"..string.upper(char).."1.png")
		local sp2=CCSprite:createWithSpriteFrameName("acWord"..string.upper(char).."2.png")
		local pos=self.wptb[char][num]
		if pos then
			if sp1 then
    			if G_isIphone5() then
    				sp1:setPosition(ccp(pos[1],pos[2]+150))
    			else
    				sp1:setPosition(ccp(pos[1],pos[2]))
    			end
    			self.bgLayer:addChild(sp1,3)
    			sp1:setTag(1220+k)
    			sp1:setVisible(false)
    		end
    		if sp2 then
    			if G_isIphone5() then
    				sp2:setPosition(ccp(pos[1],pos[2]+150))
    			else
    				sp2:setPosition(ccp(pos[1],pos[2]))
    			end
    			self.bgLayer:addChild(sp2,2)
    		end
    	end
    end

    
    if G_isIphone5() then
		posy=180
	else
		posy=145
	end
    local descLb=GetTTFLabelWrap(getlocal("activity_bhqf_desc"),20,CCSizeMake(G_VisibleSizeWidth - 100,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentBottom)
    descLb:setAnchorPoint(ccp(0.5,0))
	descLb:setPosition(G_VisibleSizeWidth/2,posy)
	self.bgLayer:addChild(descLb,1)
	descLb:setColor(G_ColorYellowPro)

end

function acBhqfLotteryDialog:initBtns()
	local acVo=acBhqfVoApi:getAcVo()
	if not acVo then
		do return end
	end
	
	local btny
    if G_isIphone5() then
    	btny=80
    else
    	btny=60
    end
	local function lotteryHandler(tag,object)
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:lottery(tag,object)
	end	
	local onceGoldLb=GetTTFLabel(acVo.activeCfg.cost,23)
	onceGoldLb:setPosition(ccp(G_VisibleSizeWidth/2-170,btny+55))
	self.bgLayer:addChild(onceGoldLb,1)
	self.onceGoldLb=onceGoldLb
	local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldIcon:setPosition(ccp(G_VisibleSizeWidth/2-120,btny+55))
	self.bgLayer:addChild(goldIcon,1)
	self.goldIcon=goldIcon
	-- local onceItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",lotteryHandler,1,getlocal("activity_bhqf_btn",{1}),24)
	-- local onceMenu=CCMenu:createWithItem(onceItem)
	-- onceMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	-- onceMenu:setPosition(ccp(G_VisibleSizeWidth/2-150,70))
	-- self.bgLayer:addChild(onceMenu,1)
	-- self.onceMenu=onceMenu

	local repeatedlyGoldLb=GetTTFLabel(acVo.activeCfg.cost5,23)
	repeatedlyGoldLb:setPosition(ccp(G_VisibleSizeWidth/2+130,btny+55))
	self.bgLayer:addChild(repeatedlyGoldLb,1)
	local goldSp=CCSprite:createWithSpriteFrameName("IconGold.png")
	goldSp:setPosition(ccp(G_VisibleSizeWidth/2+180,btny+55))
	self.bgLayer:addChild(goldSp,1)
	local repeatedlyItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",lotteryHandler,5,getlocal("activity_bhqf_btn",{5}),24)
	-- repeatedlyItem:setEnabled(enabled)
	local repeatedlyMenu=CCMenu:createWithItem(repeatedlyItem)
	repeatedlyMenu:setTouchPriority(-(self.layerNum-1)*20-4)
	repeatedlyMenu:setPosition(ccp(G_VisibleSizeWidth/2+150,btny))
	self.bgLayer:addChild(repeatedlyMenu,1)
	self.repeatedlyItem=repeatedlyItem
end

function acBhqfLotteryDialog:lottery(tag,object)
	if self.isAction==true then
		do return end
	end

	local acVo=acBhqfVoApi:getAcVo()
    local free,num = 1,1
    local needGems = 0
	if tag==1 then
		if acBhqfVoApi:isToday()==false then
			free = 0
		else
			needGems = acVo.activeCfg.cost
		end
		num=1
	else
		num=5
		needGems = acVo.activeCfg.cost5
	end

	local function realLottery( ... )
		local function lotteryCallback(fn,data)
	        local ret,sData=base:checkServerData(data)
	        if ret==true then
	            if sData and sData.data then
	            	if needGems>0 then
		            	playerVoApi:setGems(playerVoApi:getGems()-needGems)
		            end
	            	if sData.data.bhqf then
	            		acBhqfVoApi:updateData(sData.data.bhqf)
	            	end
	            	local wordtb,wordStr,tmptb={},"",{}
	            	if sData.data.report then
	            		for k,v in pairs(sData.data.report) do
	            			if v then
	            				for m,n in pairs(v) do
	            					table.insert(wordtb,m)
	            					if not tmptb[m] then
		            					wordStr=wordStr.."'"..m.."',"
		            					-- table.insert(wordtb,m)
		            					tmptb[m]=1
		            				end
	            				end
	            			end
	            		end
	            		if wordStr~="" then
	                    	wordStr=string.sub(wordStr,1,-2)
	                    end
                    end
	            	if sData.data.reward then
	            		self.isAction=true
                        local showTb = {}
	                    for m,n in pairs(sData.data.reward) do
	                        local rewardItem=FormatItem(n,nil,true)
	                        table.insert(showTb,rewardItem[1])
	                        for k,v in pairs(rewardItem) do
	                            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),false,true)
	                        end
	                    end
	                    local hxReward=acBhqfVoApi:getHxReward()
						if hxReward then
							hxReward.num=hxReward.num*num
							table.insert(showTb,1,hxReward)
							G_addPlayerAward(hxReward.type,hxReward.key,hxReward.id,hxReward.num,nil,true)
						end
						
						--添加日志
						local addReward={num,{cr=sData.data.reward,zr=sData.data.report or {}},base.serverTime}
						acBhqfVoApi:formatLog(addReward,true)

                        local function actionEndHandler()
                        	self:actionEnd(showTb,wordStr)
                        	self:cancleTouchLayer()
	                    end
	                    self:setTouchLayer(actionEndHandler)
	                    self:showAction(num,wordtb,actionEndHandler)
                    end
	            end
	        end
	    end
	    socketHelper:activeBhqfLottery(num,free,lotteryCallback)
	end
	
	if needGems>0 then
        if needGems>playerVoApi:getGems() then
            GemsNotEnoughDialog(nil,nil,needGems-playerVoApi:getGems(),self.layerNum+1,needGems)
        else
        	local function secondTipFunc(sbFlag)
	            local sValue=base.serverTime .. "_" .. sbFlag
	            G_changePopFlag("acBhqfLotteryDialog",sValue)
	        end
		    if G_isPopBoard("acBhqfLotteryDialog") then
				G_showSecondConfirm(self.layerNum+1,true,true,getlocal("dialog_title_prompt"),getlocal("second_tip_des",{needGems}),true,realLottery,secondTipFunc)
			else
				realLottery()
			end
        end
    else
		realLottery()
	end
end

function acBhqfLotteryDialog:actionEnd(showTb,wordStr)
	if self.fireworksBg then
		self.fireworksBg:removeFromParentAndCleanup(true)
		self.fireworksBg=nil
	end
	if self.removeTb then
		for k,v in pairs(self.removeTb) do
			if v then
    			local tmpsp=tolua.cast(v,"CCSprite")
    			if tmpsp then
    				tmpsp:removeFromParentAndCleanup(true)
    				tmpsp=nil
    			end
    		end
		end
		self.removeTb={}
	end
	self:refreshUI()
	if self.isAction==true then
		self:showReward(showTb,wordStr)
	end
    self.isAction=false
end

function acBhqfLotteryDialog:showReward(showTb,wordStr)
	local addStrTb = nil
    local titleStr=getlocal("activity_wheelFortune4_reward")
    local color,titleStr2
    if wordStr and wordStr~="" then
    	color=G_ColorYellowPro
    	titleStr2=getlocal("activity_bhqf_rewardDesc1",{wordStr})
    else
    	color=G_ColorRed
    	titleStr2=getlocal("activity_bhqf_rewardDesc2")
    end
    local function showTip()
    	G_showRewardTip(showTb,true)
    end
    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,showTb,showTip,titleStr,titleStr2,addStrTb,nil,nil,color)
end

function acBhqfLotteryDialog:setTouchLayer(callback)
	if not self.touchLayer then
	    self.touchLayer=CCLayer:create()
	    self.touchLayer:setTouchEnabled(true)
	    self.touchLayer:setBSwallowsTouches(true)
	    self.touchLayer:setTouchPriority(-(self.layerNum-1)*20-8)
	    self.touchLayer:setContentSize(G_VisibleSize)
	    self.bgLayer:addChild(self.touchLayer,8)
	    local function touchLuaSpr()
	        if callback then
				callback()
			end
	    end
	    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
	    touchDialogBg:setTouchPriority(-(self.layerNum-1)*20-9)
	    local rect=CCSizeMake(640,G_VisibleSizeHeight)
	    touchDialogBg:setContentSize(rect)
	    touchDialogBg:setOpacity(0)
	    touchDialogBg:setPosition(getCenterPoint(self.touchLayer))
	    self.touchLayer:addChild(touchDialogBg)
	    self.touchDialogBg = touchDialogBg
	end
end
function acBhqfLotteryDialog:cancleTouchLayer()
    if self.touchLayer~=nil then
        local temLayer=tolua.cast(self.touchLayer,"CCLayer")
        if temLayer~=nil then
            temLayer:removeFromParentAndCleanup(true)
            temLayer=nil
            self.touchDialogBg=nil
        end
        self.touchLayer=nil
    end
end
function acBhqfLotteryDialog:showAction(num,wordtb,callback)
	--播放动画
    local bgy
    if G_isIphone5() then
    	bgy=400
    else
    	bgy=350
    end
    local fireworksBg=CCSprite:createWithSpriteFrameName("fireworksBg.png")
    local fwbgSize=fireworksBg:getContentSize()
    fireworksBg:setPosition(ccp(-fwbgSize.width/2-10,bgy))
    self.touchDialogBg:addChild(fireworksBg,2)
    local fireworksSp=CCSprite:createWithSpriteFrameName("fireworks.png")
    fireworksSp:setPosition(ccp(fwbgSize.width/2,60))
    fireworksBg:addChild(fireworksSp,1)
    local bgWidth,bgHeight=fireworksBg:getContentSize().width,fireworksBg:getContentSize().height
    local spWidth,spHeight=fireworksSp:getContentSize().width,fireworksSp:getContentSize().height

    -- 添加遮罩层
    local clipper=CCClippingNode:create()
    clipper:setContentSize(CCSizeMake(bgWidth-25,bgHeight-52))
    clipper:setAnchorPoint(ccp(0,0))
    clipper:setPosition(ccp(12.5,20))
    local stencil=CCDrawNode:getAPolygon(CCSizeMake(bgWidth-25,bgHeight-52),1,1)
    clipper:setStencil(stencil) --遮罩
    fireworksBg:addChild(clipper,2)

    self.acPosTb,self.interval={},{}
    local tmpNumTb={1,2,3,4,5,6,7,8,9}
    for i=1,num do
    	local rann=math.random(1,#tmpNumTb)
		local indx=tmpNumTb[rann]
		table.remove(tmpNumTb,rann)
    	local px,py=30+((indx-1)%3)*18+math.floor((indx-1)/3)*18,75+((indx-1)%3)*5-math.floor((indx-1)/3)*5
    	self.acPosTb[i]={px,py}
    	self.interval[i]=math.random(5,20)/100
    end

    --引线动画(序列帧)
    local function addYxAnimate()
    	local pzFrameName="yinxian_01.png"
        local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
        metalSp:setPosition(ccp(spWidth-15,spHeight/2-2))
        fireworksSp:addChild(metalSp,2)
        -- metalSp:setTag(3101)
        -- metalSp:setScale(1.4)

	    local pzArr=CCArray:create()
	    for kk=1,5 do
	    	local nameStr="yinxian_0"..kk..".png"
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	        pzArr:addObject(frame)
	    end
	    local animation=CCAnimation:createWithSpriteFrames(pzArr)
	    animation:setDelayPerUnit(0.16)
	    local animate=CCAnimate:create(animation)
        local function removeYxAnimate()
	        -- local metalSp=tolua.cast(fireworksSp:getChildByTag(3101),"CCSprite")
	        if metalSp~=nil then
	            metalSp:removeFromParentAndCleanup(true)
	            metalSp=nil
	        end
	    end
	    local tmpArr=CCArray:create()
        local removeF=CCCallFunc:create(removeYxAnimate)
        tmpArr:addObject(animate)
        tmpArr:addObject(removeF)
        local seq=CCSequence:create(tmpArr)
        metalSp:runAction(seq)
	end

	--从爆竹中放出礼花爆炸动画(序列帧)
	local function baoAction()
		-- for i=1,8 do
		-- 	local px,py=30+((i-1)%3)*18+math.floor((i-1)/3)*18,75+((i-1)%3)*5-math.floor((i-1)/3)*5
		-- 	local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
  --           goldIcon:setPosition(ccp(px,py))
  --           goldIcon:setScale(0.5)
  --           fireworksSp:addChild(goldIcon)
		-- end
		-- do return end
	    for i=1,num do
	    	-- local px,py=32+((i-1)%3)*18+math.floor((i-1)/3)*18,100+((i-1)%3)*5-math.floor((i-1)/3)*5
	    	local px,py=self.acPosTb[i][1],self.acPosTb[i][2]
			-- print("px,py",px,py)
		    local pzFrameName="bao1_01.png"
	        local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
	        metalSp:setPosition(ccp(px,py))
	        fireworksSp:addChild(metalSp,2)
	        metalSp:setVisible(false)
	        -- metalSp:setTag(3101)
	        -- metalSp:setScale(1.4)

		    local pzArr=CCArray:create()
		    for kk=1,10 do
		    	local nameStr
		    	if (kk-1)>=10 then
		    		nameStr="bao1_"..(kk-1)..".png"
		    	else
		    		nameStr="bao1_0"..(kk-1)..".png"
		    	end
		        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		        pzArr:addObject(frame)
		    end
		    local animation=CCAnimation:createWithSpriteFrames(pzArr)
		    animation:setDelayPerUnit(0.1)
		    local animate=CCAnimate:create(animation)
		    local interval=0
	        for nn=1,i do
	        	interval=interval+(self.interval[nn] or 0)
	        end
	        -- print("i,interval",i,interval)
		    local delayAc = CCDelayTime:create(interval)
		    local function showSp()
	        	if metalSp then
	        		metalSp:setVisible(true)
	        	end
	        end
	        local function removeYxAnimate()
		        -- local metalSp=tolua.cast(fireworksSp:getChildByTag(3101),"CCSprite")
		        if metalSp~=nil then
		            metalSp:removeFromParentAndCleanup(true)
		            metalSp=nil
		        end
		    end
		    local tmpArr=CCArray:create()
		    local showF=CCCallFunc:create(showSp)
	        local removeF=CCCallFunc:create(removeYxAnimate)
	        tmpArr:addObject(delayAc)
	        tmpArr:addObject(showF)
	        tmpArr:addObject(animate)
	        tmpArr:addObject(removeF)
	        local seq=CCSequence:create(tmpArr)
	        metalSp:runAction(seq)
	    end
	end
	--礼花升空动画
	local function xianAction()
		-- for i=1,9 do
		-- 	local px,py=47+((i-1)%3)*18+math.floor((i-1)/3)*18,72+((i-1)%3)*5-math.floor((i-1)/3)*5
		-- 	local goldIcon=CCSprite:createWithSpriteFrameName("IconGold.png")
  --           goldIcon:setPosition(ccp(px,py))
  --           goldIcon:setScale(0.5)
  --           clipper:addChild(goldIcon)
		-- end
		-- do return end
		local tmptb={1,2,3,4,5}
		for i=1,num do
			local index
			if #tmptb>0 then
				local rannum=math.random(1,#tmptb)
				index=tmptb[rannum]
				table.remove(tmptb,rannum)
			else
				index=i
			end
			local yhBg=tolua.cast(self.yanhuaBgTb[index],"CCSprite")
			-- print("yhBg:getPositionX(),yhBg:getPositionX()+yhBg:getContentSize().width",yhBg:getPositionX(),yhBg:getPositionX()+yhBg:getContentSize().width)
			-- print("yhBg:getPositionY(),yhBg:getPositionY()+yhBg:getContentSize().height",yhBg:getPositionY(),yhBg:getPositionY()+yhBg:getContentSize().height)
			local yhx,yhy=math.random(yhBg:getPositionX(),yhBg:getPositionX()+yhBg:getContentSize().width),math.random(yhBg:getPositionY(),yhBg:getPositionY()+yhBg:getContentSize().height)
			-- print("yhx,yhy",yhx,yhy)

			local imagepy,yy,xx
			if G_isIphone5() then
				imagepy=G_VisibleSizeHeight/2 + 0
				yy=yhy--imagepy-795/2
				xx=yhx-G_VisibleSizeWidth/2
			else
				imagepy=G_VisibleSizeHeight/2 - 15
				yy=yhy--imagepy-653/2
				xx=yhx-G_VisibleSizeWidth/2
			end

	    	-- local px,py=47+((i-1)%3)*18+math.floor((i-1)/3)*18,72+((i-1)%3)*5-math.floor((i-1)/3)*5
	    	local px,py=self.acPosTb[i][1]+17,self.acPosTb[i][2]-3
			-- print("px,py",px,py)
		    local pzFrameName="xian_00.png"
	        local metalSp=CCSprite:createWithSpriteFrameName(pzFrameName)
	        metalSp:setAnchorPoint(ccp(0.5,0))
	        metalSp:setPosition(ccp(px,py))
            clipper:addChild(metalSp)
	        -- fireworksSp:addChild(metalSp,2)
	        metalSp:setScaleY(0)
	        -- print("xx,yy,math.deg(math.atan(xx/yy))",xx,yy,math.deg(math.atan(xx/yy)))
	        metalSp:setRotation(math.deg(math.atan(xx/yy)))
	        local scaleTo = CCScaleTo:create(0.1,1,0.5)
	        local hh=300
	        -- print("x,y",xx/yy*(hh-py)+px,hh)
	        local moveTo = CCMoveTo:create(0.4,ccp(xx/yy*(hh-py)+px,hh))
	        local interval=0
	        for nn=1,i do
	        	interval=interval+(self.interval[nn] or 0)
	        end
	        local delayAc = CCDelayTime:create(interval)
	        local delayAc2 = CCDelayTime:create(0.5+num*0.1)

            -- local spawnArr = CCArray:create()
            -- spawnArr:addObject(moveBy)
            -- spawnArr:addObject(scaleTo)
            -- local spawn = CCSpawn:create(spawnArr)
            local tmpArr = CCArray:create()
            tmpArr:addObject(delayAc)
            tmpArr:addObject(scaleTo)
            -- tmpArr:addObject(spawn)
            tmpArr:addObject(moveTo)
	        tmpArr:addObject(delayAc2)

	        local function yanhuaAction()
	   --      	local yhBg=tolua.cast(self.yanhuaBgTb[i],"CCSprite")
				-- local yhx,yhy=math.random(yhBg:getPositionX(),yhBg:getPositionX()+yhBg:getContentSize().width),math.random(yhBg:getPositionY(),yhBg:getPositionY()+yhBg:getContentSize().height)
				-- print("yhx,yhy",yhx,yhy)

	        	local lightSp = CCSprite:createWithSpriteFrameName("yhCenterLight.png")
	        	lightSp:setPosition(ccp(yhx,yhy))
	        	self.touchDialogBg:addChild(lightSp,4)
	        	-- lightSp:setScale(0)
	        	local fadeOut = CCFadeOut:create(0.5)
	        	local function removeLightSp()
	        		if lightSp then
	        			lightSp:removeFromParentAndCleanup(true)
	        			lightSp=nil
	        		end
	        	end
	        	local removeLF=CCCallFunc:create(removeLightSp)
	        	local arr11=CCArray:create()
				arr11:addObject(fadeOut)
				arr11:addObject(removeLF)
		        local seq11=CCSequence:create(arr11)
		        lightSp:runAction(seq11)

	        	local yhParticle = CCParticleSystemQuad:create("public/yanhua.plist")
				-- yhParticle:setPositionType(kCCPositionTypeRelative)
				yhParticle.positionType=kCCPositionTypeGrouped
				-- yhParticle:setRotation(math.random(0,360))
				yhParticle:setPosition(ccp(yhx,yhy))
				yhParticle:setAutoRemoveOnFinish(true) --自动移除
				self.touchDialogBg:addChild(yhParticle,5)
				yhParticle:setScale(0)


				local function showWords()
					--字母动画
				    if wordtb and SizeOfTable(wordtb)>0 then
				    	if not self.removeTb then
				    		self.removeTb={}
				    	end
			    		local v=wordtb[i]
			    		if v and v~="" then
					    	local wordnum=#self.wptb[v]
					    	for p=1,wordnum do
					    		local sp=CCSprite:createWithSpriteFrameName("acWord"..string.upper(v).."1.png")
					    		local pos=self.wptb[v][p]
					    		if sp and pos then
						    		sp:setPosition(ccp(yhx,yhy))
						    		self.touchDialogBg:addChild(sp,3)
						    		sp:setScale(0)
						    		local guangSp=CCSprite:createWithSpriteFrameName("gguang_00.png")
						    		guangSp:setPosition(getCenterPoint(sp))
						    		sp:addChild(guangSp)
						    		local fadeIn=CCFadeIn:create(0.5)
						    		local fadeOut=CCFadeOut:create(0.5)
							        local seq11=CCSequence:createWithTwoActions(fadeIn,fadeOut)
									local repeatForever=CCRepeatForever:create(seq11)
									guangSp:runAction(repeatForever)
						    		
						    		local scale1 = CCScaleTo:create(0.3,2)
						    		local scale2 = CCScaleTo:create(0.2,1.5)
						    		local delay1 = CCDelayTime:create(0.5+0.2*(p-1))
				                    local moveTo3
					    			if G_isIphone5() then
					    				moveTo3 = CCMoveTo:create(0.2,ccp(pos[1],pos[2]+150))
					    			else						    	
					    				moveTo3 = CCMoveTo:create(0.2,ccp(pos[1],pos[2]))
					    			end
					    			local scale3 = CCScaleTo:create(0.2,1)
					    			local spawnArr = CCArray:create()
						            spawnArr:addObject(moveTo3)
						            spawnArr:addObject(scale3)
						            local spawn = CCSpawn:create(spawnArr)
						            -- local delay2 = CCDelayTime:create(1)
							    	local arr2 = CCArray:create()
								    arr2:addObject(scale1)
								    arr2:addObject(scale2)
								    arr2:addObject(delay1)
								    arr2:addObject(spawn)
								    -- arr2:addObject(delay2)
								    -- local function removeSp( ... )
								    -- 	if sp then
								    -- 		sp:removeFromParentAndCleanup(true)
								    -- 		sp=nil
								    -- 	end
								    -- end
								    -- local removeWF = CCCallFunc:create(removeSp)
								    -- arr2:addObject(removeWF)
							    	-- if i==num and p==wordnum and callback then
								    -- 	local ccfunc = CCCallFunc:create(callback)
								    -- 	arr2:addObject(ccfunc)
								    -- end
								    local seq2 = CCSequence:create(arr2)
								    sp:runAction(seq2)
								    table.insert(self.removeTb,sp)
							    end
					    	end
				    	end
				    end
				end
				local arr10=CCArray:create()
				local scale10 = CCScaleTo:create(0.8,1.5)
				if wordtb and SizeOfTable(wordtb)>0 then
					local function showWordsFunc()
						showWords()
					end
					local showWordsF=CCCallFunc:create(showWordsFunc)
			        arr10:addObject(showWordsF)
			    end
				arr10:addObject(scale10)
		        local seq=CCSequence:create(arr10)
		        yhParticle:runAction(seq)

		    end
	        local yanhuaF=CCCallFunc:create(yanhuaAction)
	        tmpArr:addObject(yanhuaF)
	        local function removeYxAnimate()
		        -- local metalSp=tolua.cast(fireworksSp:getChildByTag(3101),"CCSprite")
		        if metalSp~=nil then
		            metalSp:removeFromParentAndCleanup(true)
		            metalSp=nil
		        end
		    end
	        local removeF=CCCallFunc:create(removeYxAnimate)
	        tmpArr:addObject(removeF)
	        local seq=CCSequence:create(tmpArr)
	        metalSp:runAction(seq)
	    end
	end

    --动画
    local moveTo1 = CCMoveTo:create(0.2,ccp(fwbgSize.width/2+30,bgy))
    local delay1 = CCDelayTime:create(0.8)
    local addYxF=CCCallFunc:create(addYxAnimate)
    local baoActionFunc=CCCallFunc:create(baoAction)
    local xianActionFunc=CCCallFunc:create(xianAction)
    local moveTo2 = CCMoveTo:create(0.2,ccp(-fwbgSize.width/2-10,bgy))
    local delay2
    local delay3
    if num>1 then
    	delay2 = CCDelayTime:create(1.5)
		delay3 = CCDelayTime:create(2.5)
    else
    	delay2 = CCDelayTime:create(1)
		if wordtb and wordtb[1] and wordtb[1]~="" then
			delay3 = CCDelayTime:create(2)
		else
			delay3 = CCDelayTime:create(1)
    	end
    end
    local arr1 = CCArray:create()
    arr1:addObject(moveTo1)
    arr1:addObject(addYxF)
    arr1:addObject(delay1)
    -- arr1:addObject(removeYxF)
    arr1:addObject(baoActionFunc)
    arr1:addObject(xianActionFunc)
    arr1:addObject(delay2)
    arr1:addObject(moveTo2)
    if callback then
    	arr1:addObject(delay3)
    	local ccfunc = CCCallFunc:create(callback)
    	arr1:addObject(ccfunc)
    end
    local seq1 = CCSequence:create(arr1)
    fireworksBg:runAction(seq1)
    self.fireworksBg = fireworksBg
end

function acBhqfLotteryDialog:logHandler()
    local function showLog()
    	local rewardLog=acBhqfVoApi:getRewardLog()
        if rewardLog and SizeOfTable(rewardLog)>0 then
            local logList={}
            for k,v in pairs(rewardLog) do
                local num,reward,time,words=v.num,v.reward,v.time,v.words
                local title,wordstr,index="","",0
                if words and SizeOfTable(words)>0 then
	                for k,v in pairs(words) do
	                	if k~="" then
		                	if index==0 then
		                		wordstr=wordstr..k
		                	else
		                		wordstr=wordstr..","..k
		                	end
		                	index=index+1
		                end
	                end
	                title = {getlocal("activity_bhqf_log2",{num,wordstr})}
	            else
	            	title = {getlocal("activity_bhqf_log1",{num})}
	            end
                local content={{reward}}
                local log={title=title,content=content,ts=time}
                table.insert(logList,log)
            end
            local logNum=SizeOfTable(logList)
            require "luascript/script/game/scene/gamedialog/activityAndNote/acCjyxSmallDialog"
            acCjyxSmallDialog:showLogDialog("TankInforPanel.png",CCSizeMake(550,G_VisibleSizeHeight-300),CCRect(130, 50, 1, 1),{getlocal("activity_customLottery_RewardRecode"),G_ColorWhite},logList,false,self.layerNum+1,nil,true,10,true,true)
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_tccx_no_record"),30)
        end
    end
    acBhqfVoApi:getLog(showLog)
end

function acBhqfLotteryDialog:refreshUI()
	local acVo=acBhqfVoApi:getAcVo()
	if not acVo or not self.bgLayer then
		do return end
	end

	for k,v in pairs(self.showtb) do
		if v and v[1] and acBhqfVoApi:hasWord(v[1]) then
			local sp=tolua.cast(self.bgLayer:getChildByTag(1220+k),"CCSprite")
			if sp then
				sp:setVisible(true)
			end
		end
    end

    local btny
    if G_isIphone5() then
    	btny=80
    else
    	btny=60
    end
	local function lotteryHandler(tag,object)
		if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)
        self:lottery(tag,object)
	end
	if self.onceMenu then
		self.onceMenu:removeFromParentAndCleanup(true)
		self.onceMenu=nil
	end
	if acBhqfVoApi:isToday()==false then
		if self.onceGoldLb then
			self.onceGoldLb:setString(getlocal("daily_lotto_tip_2"))
			self.onceGoldLb:setPosition(ccp(G_VisibleSizeWidth/2-150,btny+55))
		end
		if self.goldIcon then
			self.goldIcon:setVisible(false)
		end
		local onceItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",lotteryHandler,1,getlocal("activity_bhqf_btn",{1}),24)
		local onceMenu=CCMenu:createWithItem(onceItem)
		onceMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		onceMenu:setPosition(ccp(G_VisibleSizeWidth/2-150,btny))
		self.bgLayer:addChild(onceMenu,1)
		self.onceMenu=onceMenu
		if self.repeatedlyItem then
			self.repeatedlyItem:setEnabled(false)
		end
	else
		if self.onceGoldLb then
			self.onceGoldLb:setString(acVo.activeCfg.cost)
			self.onceGoldLb:setPosition(ccp(G_VisibleSizeWidth/2-170,btny+55))
		end
		if self.goldIcon then
			self.goldIcon:setVisible(true)
		end
		local onceItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",lotteryHandler,1,getlocal("activity_bhqf_btn",{1}),24)
		local onceMenu=CCMenu:createWithItem(onceItem)
		onceMenu:setTouchPriority(-(self.layerNum-1)*20-4)
		onceMenu:setPosition(ccp(G_VisibleSizeWidth/2-150,btny))
		self.bgLayer:addChild(onceMenu,1)
		self.onceMenu=onceMenu
		if self.repeatedlyItem then
			self.repeatedlyItem:setEnabled(true)
		end
	end

end

function acBhqfLotteryDialog:tick()
	if self.bgLayer then
		self:updateAcTime()
		if acBhqfVoApi:isToday()==false and self.isToday==true then
			self:refreshUI()
			acBhqfVoApi:refreshState()
		end
		if self.isToday~=acBhqfVoApi:isToday() then
			self.isToday=acBhqfVoApi:isToday()
		end
	end
end

function acBhqfLotteryDialog:dispose()
	self.isToday=nil
	self.isAction=nil
	self.removeTb=nil
	self.showWordTb=nil
	self.touchLayer=nil
	self.bgLayer=nil
end
