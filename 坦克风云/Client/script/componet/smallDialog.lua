smallDialog={}

function smallDialog:new()
    local nc={
      bgLayer=nil,             --背景sprite
      dialogLayer,         --对话框层
      bgSize,
      isTouch,
      isUseAmi,
      refreshData={},			--需要刷新的数据
      message,
      isSizeAmi,
    }
    setmetatable(nc,self)
    self.__index=self
--    print("base.all=",base.allShowedSmallDialog)
    base.allShowedSmallDialog=base.allShowedSmallDialog+1
    return nc
end

function smallDialog:tick(isArrive)
    if(self.type=="powerchangeeffect")then
    elseif(self.type=="activateDefendersDialog")then
      if serverWarTeamVoApi:getDonateFlag()==0 then
        if self.refreshData then
          if self.refreshData.tableView then
            self.refreshData.tableView:reloadData()
          end
          local cfg=serverWarTeamVoApi:getBaseDonateTimeCfg()
          if serverWarTeamVoApi:getBaseDonateNum()>=cfg[SizeOfTable(cfg)] then
            if self.refreshData.gemsDonateItem then
              self.refreshData.gemsDonateItem:setEnabled(false)
            end
            if self.refreshData.resDonateItem then
              self.refreshData.resDonateItem:setEnabled(false)
            end
          end

        end
        serverWarTeamVoApi:setDonateFlag(1)
      end
      if self.refreshData and self.refreshData.descLb then
        local baseDonateNum=serverWarTeamVoApi:getBaseDonateNum()
        local baseNum=0
        for k,v in pairs(serverWarTeamCfg.baseDonateTime) do
            if baseDonateNum>=v then
                baseNum=baseNum+serverWarTeamCfg.baseDonateNum[k]
            end
        end
        self.refreshData.descLb:setString(getlocal("serverwarteam_has_base_defenders",{baseNum}))
      end
    elseif(self.type=="sendFlowerInfoDialog" or self.type=="teamSendFlowerInfoDialog" or self.type=="worldWarFlowerInfoDialog")then
      if self.refreshData then
        if self.refreshData.sendFlowerMenu and self.type=="sendFlowerInfoDialog" then
          if serverWarPersonalVoApi:checkStatus()>30 then
            local sendFlowerMenu = tolua.cast(self.refreshData.sendFlowerMenu,"CCMenu")
            sendFlowerMenu:setPosition(ccp(10000,0))
          end
        end
        if self.refreshData.tableView then
          if self.refreshData.timeTb and self.refreshData.label then
            for k,v in pairs(self.refreshData.timeTb) do
              local endTime=v
              local cdTime=0
              if endTime then
                if endTime==base.serverTime then
                  self.refreshData.timeTb=nil
                  self.refreshData.label=nil
                  self.refreshData.timeTb={}
                  self.refreshData.label={}
                  self.refreshData.wwrewardItem={}
                  local recordPoint = self.refreshData.tableView:getRecordPoint()
                  self.refreshData.tableView:reloadData()
                  self.refreshData.tableView:recoverToRecordPoint(recordPoint)
                else
                  cdTime=endTime-base.serverTime
                  if cdTime and cdTime>0 then
                    local label=tolua.cast(self.refreshData.label[k],"CCLabelTTF")
                    if label then
                      label:setString(getlocal("serverwar_result")..GetTimeStr(cdTime))
                    end
                  end
                end
              end
            end
          end
        end
      end
    elseif self.type=="enemyComingDialog" then
    	local flag=enemyVoApi:getFlag()
    	if flag==0 then
    		local hasEnemy=enemyVoApi:hasEnemy()
            if self.refreshData.enemyId then
                local enemyVo=enemyVoApi:getEnemyById(self.refreshData.enemyId)
                if enemyVo then
                    hasEnemy=true
                else
                    hasEnemy=false
                end
            end
    		if hasEnemy==true then
    			if self.refreshData.tableView~=nil then
    				if self.refreshData.countdownTab~=nil then
    					for k,v in pairs(self.refreshData.countdownTab) do
    						self.refreshData.countdownTab[k]=nil
    					end
    				end
    				self.refreshData.countdownTab={}
    				self.refreshData.tableView:reloadData()
    			end
    		else
    			self:close()
    		end
    		enemyVoApi:setFlag(1)
    	else
    		if self.refreshData.countdownTab~=nil then
                if self.refreshData.enemyId then
                    local enemyVo=enemyVoApi:getEnemyById(self.refreshData.enemyId)
                    if enemyVo and enemyVo.time and self.refreshData.countdownTab[1] then
                        local time=enemyVo.time-base.serverTime
                        if time<0 then
                            time=0
                        end
                        if self.refreshData.countdownTab[1].label then
                            self.refreshData.countdownTab[1].label:setString(getlocal("attackedTime",{GetTimeStr(time)}))
                        end
                    end
                else
        			local enemyAll=enemyVoApi:getEnemyAll()
        			for k,v in pairs(enemyAll) do
        				if v and v.time and self.refreshData.countdownTab[k] then
        					local time=v.time-base.serverTime
        					if time<0 then
        						time=0
        					end
        					if self.refreshData.countdownTab[k].label then
        						self.refreshData.countdownTab[k].label:setString(getlocal("attackedTime",{GetTimeStr(time)}))
        					end
        				end
        			end
                end
    		end
    	end
    end
end

function smallDialog:fastTick()
    if(self.type=="usePropsDialog")then
        self.fastTickIndex=self.fastTickIndex+1
        -- print("self.fastTickIndex",self.fastTickIndex)
        local isChange=false
        local firstIndex=12
        local interval=3
        if self.fastTickIndex==1 then
            isChange=true
        elseif self.fastTickIndex<=firstIndex then
            if self.fastTickIndex==firstIndex then
                isChange=true
            end
        elseif self.fastTickIndex>firstIndex and self.fastTickIndex<=(firstIndex+interval*3) then
            if self.fastTickIndex%interval==0 then
                isChange=true
            end
        else
            isChange=true
        end
        if isChange==true then
            if self.isAdd==true then
                self.useNum=self.useNum+1
                if self.useNum>=self.maxNum then
                    self.useNum=self.maxNum
                    -- self.increaseBtn:setEnabled(false)
                    self.increaseSp1:setVisible(false)
                    self.increaseSp2:setVisible(true)
                    base:removeFromNeedRefresh(self)
                end
                -- self.reduceBtn:setEnabled(true)
                self.reduceSp1:setVisible(true)
                self.reduceSp2:setVisible(false)
            else
                self.useNum=self.useNum-1
                if self.useNum<=1 then
                    self.useNum=1
                    -- self.reduceBtn:setEnabled(false)
                    self.reduceSp1:setVisible(false)
                    self.reduceSp2:setVisible(true)
                    base:removeFromNeedRefresh(self)
                end
                -- self.increaseBtn:setEnabled(true)
                self.increaseSp1:setVisible(true)
                self.increaseSp2:setVisible(false)
            end
            self.numLb:setString(getlocal("scheduleChapter",{self.useNum,self.maxNum}))
        end
    elseif(self.type=="powerchangeeffect")then
        if(self.fastTickIndex<=0)then
            local allTickEnd=true
            if(self.powerChangeRollTogether)then
                self.fastTickIndex=3
            else
                self.fastTickIndex=1
            end
            if(self.powerChangeFlag==0)then
            else
                for i=1,self.powerChangeStrlen do
                    --如果这一位的标志为0,说明还没转满一圈,继续转
                    if(self.powerChangeFlagTb[i]==0)then
                        allTickEnd=false
                        if(self.powerChangeTmpTb[i]~=nil)then
                            self.powerChangeTmpTb[i]=self.powerChangeTmpTb[i]+1
                            if(self.powerChangeTmpTb[i]>=10)then
                                self.powerChangeTmpTb[i]=0
                            end
                            if(self.powerChangeStartTb[i]~=nil and self.powerChangeTmpTb[i]==self.powerChangeStartTb[i])then
                                self.powerChangeFlagTb[i]=1
                            elseif(self.powerChangeStartTb[i]==nil and self.powerChangeTmpTb[i]==0)then
                                self.powerChangeFlagTb[i]=1
                            end
                        --如果临时tb的这一位为nil, 说明两个数的位数不一样, 需要做进位处理, 如果该位的上一位为0, 说明已经转过10了, 就进位
                        elseif(self.powerChangeFlagTb[i-1]==1)then
                            self.powerChangeTmpTb[i]=1
                        end
                        if(self.powerChangeRollTogether~=true)then
                            break
                        end
                    --如果这一位的标志为1,说明已经转够一圈, 那么转到指定数之后就该停了
                    else
                        if(self.powerChangeTmpTb[i]~=self.powerChangeEndTb[i])then
                            allTickEnd=false
                            if(self.powerChangeTmpTb[i]~=nil)then
                                self.powerChangeTmpTb[i]=self.powerChangeTmpTb[i]+1
                                if(self.powerChangeTmpTb[i]>=10)then
                                    self.powerChangeTmpTb[i]=0
                                end
                            elseif(self.powerChangeFlagTb[i-1]==1)then
                                self.powerChangeTmpTb[i]=1
                            end
                            if(self.powerChangeRollTogether~=true)then
                                break
                            end
                        end
                    end
                end
            end
            local str=table.concat(self.powerChangeTmpTb)
            if(self.powerChangeLb and self.powerChangeLb.setString)then
                self.powerChangeLb:setString(string.reverse(str))
            end
            if(allTickEnd)then
                self.powerChangeStartTb=nil
                self.powerChangeEndTb=nil
                self.powerChangeTmpTb=nil
                self.powerChangeFlagTb=nil
                self.powerChangeRollTogether=nil
                base:removeFromNeedRefresh(self)
                local diff=self.powerChangeEnd-self.powerChangeStart
                if(diff>0)then
                    diff="+"..diff
                end
                local changeLb=GetBMLabel(diff,G_GoldFontSrc,30)
                changeLb:setAnchorPoint(ccp(1,0.2))
                local posX=self.powerChangeLb:getPositionX()
                changeLb:setPosition(ccp(posX+self.powerChangeLb:getContentSize().width,self.powerChangeLb:getPositionY()+50))
                changeLb:setScale(0.1)
                self.bgLayer:addChild(changeLb)
                local function onScaleShow()
                    self.powerChangeLb=nil
                    self.powerChangeStart=nil
                    self.powerChangeEnd=nil
                    self:close()
                end
                local callFunc=CCCallFunc:create(onScaleShow)
                local scaleTo1=CCScaleTo:create(0.3, 0.9)
                local scaleTo2=CCScaleTo:create(0.2, 0.8)
                local delay=CCDelayTime:create(0.5)
                local acArr=CCArray:create()
                acArr:addObject(scaleTo1)
                acArr:addObject(scaleTo2)
                acArr:addObject(delay)
                acArr:addObject(callFunc)
                local seq=CCSequence:create(acArr)
                changeLb:runAction(seq)
            end
        else
            self.fastTickIndex=self.fastTickIndex-1
        end
    end
end

--设置dialogLayer触摸优先级
function smallDialog:setTouchPriority(p)
    self.dialogLayer:setTouchPriority(p)
end
--特殊处理
function smallDialog:userHandler()

end

--显示面板,加效果
function smallDialog:show(actionCallback)
    if(self.bgLayer and tolua.cast(self.bgLayer,"CCNode"))then
        if self.isSizeAmi==true then
            self.bgLayer:setScaleY(100/self.bgSize.height)
            local function callBack()
                base:cancleWait()
            end
            local callFunc=CCCallFunc:create(callBack)
    
            local scaleTo1=CCScaleTo:create(0.5,1,1)
    
            local acArr=CCArray:create()
            acArr:addObject(scaleTo1)
            acArr:addObject(callFunc)
    
            local seq=CCSequence:create(acArr)
            self.bgLayer:runAction(seq)
    
        elseif self.isUseAmi~=nil then
           local moveTo=CCMoveTo:create(0.3,CCPointMake(G_VisibleSize.width/2,G_VisibleSize.height/2))
           local function callBack()
               base:cancleWait()
               if type(actionCallback)=="function" then
                    actionCallback()
               end
           end
           local callFunc=CCCallFunc:create(callBack)
           
           local scaleTo1=CCScaleTo:create(0.1, 1.1);
           local scaleTo2=CCScaleTo:create(0.07, 1);
    
           local acArr=CCArray:create()
           acArr:addObject(scaleTo1)
           acArr:addObject(scaleTo2)
           acArr:addObject(callFunc)
            
           local seq=CCSequence:create(acArr)
           self.bgLayer:runAction(seq)
       end
    end
   
   table.insert(G_SmallDialogDialogTb,self)
end

function smallDialog:close(closeCallback)
    if self.isUseAmi~=nil and self.bgLayer~=nil then
	    local function realClose()
	        return self:realClose(closeCallback)
	    end
	   local fc= CCCallFunc:create(realClose)
	   local scaleTo1=CCScaleTo:create(0.1, 1.1);
	   local scaleTo2=CCScaleTo:create(0.07, 0.8);

	   local acArr=CCArray:create()
	   acArr:addObject(scaleTo1)
	   acArr:addObject(scaleTo2)
	   acArr:addObject(fc)
    
	   local seq=CCSequence:create(acArr)
	   self.bgLayer:runAction(seq)
   else
        self:realClose(closeCallback)

   end
end

--添加处理上下遮挡层
function smallDialog:addForbidSp(parent,rect,layerNum,isAddBottom,isClose,isAllScreen,priority)
    local function forbidClick()
        if isClose==true then
            PlayEffect(audioCfg.mouseClick)
            self:close()
        end
    end
    local touchPriority = priority or -(layerNum-1)*20-3
    local rect2 = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local topforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    topforbidSp:setTouchPriority(touchPriority)
    topforbidSp:setAnchorPoint(ccp(0,0))
    local bottomforbidSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,forbidClick)
    bottomforbidSp:setTouchPriority(touchPriority)
    bottomforbidSp:setAnchorPoint(ccp(0,0))
    local topY
    local topHeight
    local tvX,tvY
    if self.refreshData and self.refreshData.tableView then
        tvX,tvY=self.refreshData.tableView:getPosition()
        topY=tvY+self.refreshData.tableView:getViewSize().height
        topHeight=rect.height-topY
    else
        topHeight=0
        topY=0
    end
    local addHeight=0
    if isAllScreen and isAllScreen==true then
        addHeight=(G_VisibleSizeHeight-rect.height)/2
    end
    topforbidSp:setContentSize(CCSize(rect.width,topHeight+addHeight))
    topforbidSp:setPosition(0,topY)
    parent:addChild(topforbidSp)
    if tvY then
        if isAddBottom==true then
            bottomforbidSp:setContentSize(CCSizeMake(rect.width,tvY+G_VisibleSizeHeight-topHeight))
            bottomforbidSp:setPosition(ccp(0-(G_VisibleSizeWidth-bottomforbidSp:getContentSize().width)/2,topHeight-G_VisibleSizeHeight))
            topforbidSp:setPosition(0-(G_VisibleSizeWidth-topforbidSp:getContentSize().width)/2,topY)
        else
            bottomforbidSp:setContentSize(CCSizeMake(rect.width,tvY+addHeight))
        end
        parent:addChild(bottomforbidSp)
    end
    if isAllScreen and isAllScreen==true then
        bottomforbidSp:setPosition(0,bottomforbidSp:getPositionY()-addHeight)
    end
    topforbidSp:setVisible(false)
    bottomforbidSp:setVisible(false)
end


function smallDialog:setDisplay(bool)
    if self and self.dialogLayer and self.dialogLayer.setVisible then
        if(tolua.cast(self.dialogLayer,"CCNode"))then
            if bool==true then
                self.dialogLayer:setVisible(true)
            else
                self.dialogLayer:setVisible(false)
            end
        end
    end
end

function smallDialog:dispose()


end

function smallDialog:realClose(closeCallback)
    self:dispose()
    base.allShowedSmallDialog=base.allShowedSmallDialog-1
    --print("base.allShowedSmallDialog=",base.allShowedSmallDialog)
    if base.allShowedSmallDialog<0 then
        base.allShowedSmallDialog=0
    end
    for k,v in pairs(G_SmallDialogDialogTb) do
        if v==self then
            v=nil
            G_SmallDialogDialogTb[k]=nil
        end
    end
    G_AllianceDialogTb["chatSmallDialog"]=nil
	base:removeFromNeedRefresh(self)
	if self.dialogLayer and tolua.cast(self.dialogLayer,"CCNode") and self.dialogLayer.removeFromParentAndCleanup then
	    self.dialogLayer:removeFromParentAndCleanup(true)
	end
    self.bgLayer=nil
    self.dialogLayer=nil
    self.bgSize=nil
	if self.refreshData~=nil then
		for k,v in pairs(self.refreshData) do
			self.refreshData[k]=nil
		end
	end
	self.refreshData=nil
    self.message=nil
    self=nil
    if type(closeCallback) == "function" then
        closeCallback()
    end
end

function smallDialog:isClosed()
    if self.bgLayer==nil or tolua.cast(self.bgLayer,"CCNode")==nil then
        return true
    end
    return false
end