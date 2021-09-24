local believerSelectTankSmallDialog=smallDialog:new()

function believerSelectTankSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	return nc
end

-- posIdx: 布阵位置几号位
function believerSelectTankSmallDialog:init(layerNum,selectTankHandler,posIdx)
    spriteController:addPlist("public/squaredImgs.plist")
  	spriteController:addTexture("public/squaredImgs.png")
	self.isTouch=nil
	self.isUseAmi=true
	self.layerNum=layerNum
	self.bgSize=CCSizeMake(600,G_VisibleSizeHeight-300)

	local believerCfg=believerVoApi:getBelieverCfg()
	local myTroopsPool=believerVoApi:getCanUseTroopPool()
	local cellNum=SizeOfTable(myTroopsPool)
	if cellNum%3>0 then
		cellNum=math.floor(cellNum/3)+1
	else
		cellNum=cellNum/3
	end
	local troopNum=believerCfg.troopsNum
	believerVoApi:getRecommendTank(posIdx,myTroopsPool)

	local function close()
		return self:close()
	end
    local dialogBg=G_getNewDialogBg(self.bgSize,getlocal("choiceFleet"),30,nil,self.layerNum,true,close)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(self.bgSize)
    self.bgLayer:setIsSallow(true)
    self.bgLayer:setTouchPriority(-(layerNum-1)*20-2)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

	local tvWidth,tvHeight,itemHeight=self.bgSize.width-40,self.bgSize.height-180,250
	local tvBg=LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
	tvBg:setAnchorPoint(ccp(0.5,1))
    tvBg:setContentSize(CCSizeMake(tvWidth,tvHeight+10))
    tvBg:setPosition(self.bgSize.width*0.5,self.bgSize.height-70)
    self.bgLayer:addChild(tvBg)

	if cellNum<=0 then
		local noTankLb=GetTTFLabelWrap(getlocal("believer_notank_avaiable"),25,CCSizeMake(tvWidth-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
		noTankLb:setPosition(getCenterPoint(tvBg))
		noTankLb:setColor(G_ColorGray)
		tvBg:addChild(noTankLb,3)
	end

    local fontSize=24
	if G_getCurChoseLanguage()~="cn" and G_getCurChoseLanguage()~="tw" then
		fontSize=22
	end
	local tankNumTb={}
	local selectTankId,selectTankSp
	local function callBack(handler,fn,idx,cel)
       	if fn=="numberOfCellsInTableView" then
			return 1
   		elseif fn=="tableCellSizeForIndex" then
       		local tmpSize
       		tmpSize=CCSizeMake(tvWidth,itemHeight*cellNum)
       		return tmpSize
   		elseif fn=="tableCellAtIndex" then
			local cell=CCTableViewCell:new()
			cell:autorelease()
			if myTroopsPool==nil then
        		do return cell end
    		end

			local selectBorderSp=CCSprite:createWithSpriteFrameName("TeamTankSelected.png")
			selectBorderSp:setScale(150/selectBorderSp:getContentSize().width)
			cell:addChild(selectBorderSp,3)

			local soldiersSelectedLbNum=GetTTFLabel(" ",24)
			cell:addChild(soldiersSelectedLbNum,4)

			local selectedBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBgSelected.png",CCRect(15, 15, 1, 1),function()end)
		   	selectedBgSp:setContentSize(CCSizeMake(100,36))
			cell:addChild(selectedBgSp,3)

			selectBorderSp:setPosition(ccp(0,-99999))
			soldiersSelectedLbNum:setPosition(ccp(0,-99999))
			selectedBgSp:setPosition(ccp(0,-99999))

	        local iconWidth,spaceW,cellHeight=150,40,itemHeight*cellNum
	        local firstPosX=(tvWidth-3*iconWidth-2*spaceW)/2
    		for k,v in pairs(myTroopsPool) do
	        	local tankId,tankNum=v[1],v[2]
    			tankNumTb[tankId]=tankNum
				local function touch(object,name,tag)
					if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
						-- print("selectTankId,tag",selectTankId,tag)
						if selectTankId then
							local lastTouchSp=tolua.cast(cell:getChildByTag(selectTankId),"LuaCCSprite")
							if lastTouchSp then
					        	local numLb=tolua.cast(lastTouchSp:getChildByTag(2),"CCLabelTTF")
								if numLb then
									numLb:setString(tankNumTb[selectTankId])
								end
							end
						end
						selectTankId=tag
						local tankNum=tankNumTb[tag]
						if tankNum<troopNum then
							local function exchangeTankHandler()
								for k,v in pairs(myTroopsPool) do
									if v[1]==tag then
										myTroopsPool[k][2]=myTroopsPool[k][2]+troopNum
										do break end
									end
								end
								if self.tv then
									local recordPoint=self.tv:getRecordPoint()
									self.tv:reloadData()
									self.tv:recoverToRecordPoint(recordPoint)
								end
							end
							local needNum=believerVoApi:getTroopExchangeCostNum(1)
                            local exchangeCostTb={{"a"..tag,needNum}}
                            local function realExchange()
        					    local function requestCallBack()
							    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_exchange_ok",{troopNum,getlocal(tankCfg[tag].name)}),30)
							    	exchangeTankHandler()
							    end
							    believerVoApi:believerExchange(exchangeCostTb,requestCallBack)
                            end
							if believerVoApi:checkAutoExchange()==true then
								--兑换所需的舰队
								if tankVoApi:getTankCountByItemId(tag)<needNum then
									smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_exchange_lack",{getlocal(tankCfg[tag].name)}),30)
								else
									realExchange()
								end
							else
								local exchangeList={{"a"..tag,believerCfg.troopsNum}}
	                     		local cost,num,exchangeNum=believerVoApi:getTroopExchangeCostNum(1),believerCfg.troopsNum
								local exchangeNum=believerVoApi:getDayExchangeNum()+1
	                            local exchangeRateTb={{cost,num,exchangeNum}}
	                            local isAutoCheck=believerVoApi:checkAutoExchange()
	                            -- print("isAutoCheck",isAutoCheck)
	                            local function oneKeyConfirmHandler(callback)
	                            	local function onConfirm()
							        	believerVoApi:requestAutoExchange(1,callback)
	                            	end
									G_showSecondConfirm(self.layerNum+2,true,true,getlocal("dialog_title_prompt"),getlocal("believer_troop_exchange_oneKey_desc"),true,onConfirm)
	                            end
	                            local function oneKeyCancelHandler(callback)
	        						believerVoApi:requestAutoExchange(0,callback)
	                            end
								believerVoApi:showTroopExchangeSmallDialog(exchangeList,exchangeRateTb,true,self.layerNum+1,realExchange,isAutoCheck,oneKeyConfirmHandler,oneKeyCancelHandler)
				        	end
				        end

				        local touchSp=tolua.cast(cell:getChildByTag(tag),"LuaCCSprite")
				        selectTankSp=touchSp
				        if touchSp then
					        local numLb=tolua.cast(touchSp:getChildByTag(2),"CCLabelTTF")
					        if numLb then
					        	local soldierCount=tankNum-troopNum
		        	            if soldierCount>0 then
					            	numLb:setString(soldierCount)
					            	soldiersSelectedLbNum:setString(troopNum)
		        	            else
					            	numLb:setString(0)
					            	soldiersSelectedLbNum:setString(tankNum)
		        	            end
					        end
					        selectBorderSp:setPosition(touchSp:getPosition())
				            soldiersSelectedLbNum:setPosition(ccp(touchSp:getPositionX(),touchSp:getPositionY()-45))
				        	selectedBgSp:setPosition(ccp(touchSp:getPositionX(),touchSp:getPositionY()-45))
				        end
					end
				end
				local tankSp=tankVoApi:getTankIconSp(tankId,nil,touch)
				tankSp:setAnchorPoint(ccp(0.5,0.5))
				tankSp:setScale(iconWidth/tankSp:getContentSize().width)
				tankSp:setTouchPriority(-(self.layerNum-1)*20-3)
				tankSp:setPosition(firstPosX+iconWidth*0.5+(k-1)%3*(iconWidth+spaceW),cellHeight-iconWidth/2-10-math.floor((k-1)/3)*itemHeight)
				tankSp:setTag(tankId)
				cell:addChild(tankSp,2)
			
				local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("TeamTankNumBg.png",CCRect(15,15,1,1),function () end)
				numBg:setContentSize(CCSizeMake(130,36))
				numBg:setPosition(tankSp:getContentSize().width/2,-numBg:getContentSize().height/2)
				tankSp:addChild(numBg,2)

				local numLb=GetTTFLabel(tankNum,26)
				numLb:setPosition(numBg:getPosition())
				numLb:setTag(2)
				tankSp:addChild(numLb,3)
				if tankNum<troopNum then --坦克数量不足
					numLb:setColor(G_ColorRed)
				end

				local tankNameLb=GetTTFLabelWrap(getlocal(tankCfg[tankId].name),24,CCSizeMake(24*8,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
				tankNameLb:setAnchorPoint(ccp(0.5,1))
				tankNameLb:setPosition(tankSp:getContentSize().width/2,numBg:getPositionY()-numBg:getContentSize().height/2-5)
				tankSp:addChild(tankNameLb,2)

				local function showInfoHandler(hd,fn,idx)
					if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
						local id=tonumber(tankId) or (tonumber(RemoveFirstChar(tankId)))
						id=G_pickedList(id)
                		tankInfoDialog:create(self.bgLayer,tonumber(id),self.layerNum+1,true,nil,nil,true)
					end
				end
				local spScale,priority=0.7,-(self.layerNum-1)*20-4
				local tipPos=ccp(57*0.5*spScale+10,iconWidth-57*0.5*spScale-10)
				G_createBotton(tankSp,tipPos,{},"i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",showInfoHandler,spScale,priority)
                -- 如果刷新之前已经存储选中tag，那么刷新之后选中tag的舰船
                if selectTankId and tankId==selectTankId then
		            selectBorderSp:setPosition(tankSp:getPosition())
		            local soldierCount=tankNum-troopNum
		            numLb:setString(soldierCount)
		            soldiersSelectedLbNum:setString(troopNum)
		            soldiersSelectedLbNum:setPosition(tankSp:getPositionX(),tankSp:getPositionY()-45)
		        	selectedBgSp:setPosition(tankSp:getPositionX(),tankSp:getPositionY()-45)
                end
	            --标记推荐
                if v[3]==true then
                	local goodTankSp=CCSprite:createWithSpriteFrameName("believerGoodTank.png")
                	goodTankSp:setAnchorPoint(ccp(1,1))
                	goodTankSp:setPosition(ccp(tankSp:getContentSize().width+2,tankSp:getContentSize().height+2))
                	goodTankSp:setScale(1/tankSp:getScale())
                	tankSp:addChild(goodTankSp,5)
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
    local hd=LuaEventHandler:createHandler(callBack)
 	self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(tvWidth,tvHeight),nil)
    self.tv:setTableViewTouchPriority((-(self.layerNum-1)*20-5))
    self.tv:setPosition((self.bgSize.width-tvWidth)/2,tvBg:getPositionY()-tvHeight-5)
    self.tv:setMaxDisToBottomOrTop(120)
    self.bgLayer:addChild(self.tv)

    --确定
    local function sureHandler()  
        if selectTankId==nil then
            self:close()
            do return end
        end
    	if myTroopsPool then
    		for k,v in pairs(myTroopsPool) do
    			if v[1]==selectTankId then
	 				local num=v[2]
					if num<troopNum then --数量不足
				    	smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("believer_troop_lack"),30)
		    			self:close()
		    			do return end
		    		end
		    		do break end
    			end
    		end 	
    	end
        selectTankHandler(selectTankId,troopNum)
        self:close()
    end
    local adaSzie = 25
    if G_isAsia() == false then
    	adaSzie = 20
    end
    G_createBotton(self.bgLayer,ccp(self.bgSize.width/2,55),{getlocal("ok"),adaSzie},"newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",sureHandler,0.6,-(self.layerNum-1)*20-4)

	self:show()

	local function touchLuaSpr()
    end
    local touchDialogBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10,10,1,1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(250)
    touchDialogBg:setAnchorPoint(ccp(0.5,0.5))
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg)

	sceneGame:addChild(self.dialogLayer,self.layerNum)
	self.dialogLayer:setPosition(0,0)
	return self.dialogLayer
end

function believerSelectTankSmallDialog:dispose()
	self.believerCfg=nil
    spriteController:removePlist("public/squaredImgs.plist")
  	spriteController:removeTexture("public/squaredImgs.png")
end

return believerSelectTankSmallDialog