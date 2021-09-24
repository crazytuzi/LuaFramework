aiTank = {
	
}

function aiTank:new(aId,pos,area,isShow,parent,isBoss,aiSkillTb)
	local nc = {}
	setmetatable(nc,self)
	self.__index=self
	nc.pos	  = pos
	nc.area   = area
	nc.aId       = aId
	nc.parent    = parent
	nc.isShow    = isShow--初始化为false,标示不显示，什么时候对应坦克部队死亡，什么时候isShow状态为true
	nc.isCanAtt  = aiSkillTb[2] == 3 and true or false--是否攻击或buf调用，AI部队无死亡状态
	nc.isBoss    = isBoss
	nc.aiSkillTb = aiSkillTb--1:技能id 2:技能type (1：buf 2：盾 3：ai部队攻击) 3:技能的范围 4:调用的特效id 5:特效使用图片的类型 （2种
	nc.attNum	 = 1 -- 开火次数
	nc.isNotShowDestroyAITank = true
	if isBoss then
		-- nc:initCurShells()
	else
		nc:init()
	end
	return nc
end
function aiTank:initAiTanksCfg( )
	self.leftDownPos={ccp(112,394),ccp(258,294),ccp(413,195),ccp(69,245),ccp(209,148),ccp(358,53)} --左下角6个坦克位置

	if G_isIphone5()==true then
	  	self.rightTopPos={ccp(230,694+176),ccp(359,603+176),ccp(510,512+176),ccp(291,821+176),ccp(427,738+176),ccp(557,658+176)}
	else
	  	self.rightTopPos={ccp(230,694),ccp(359,603),ccp(510,512),ccp(291,821),ccp(427,738),ccp(557,658)}
	end

	--右侧履带坐标
	self.r_rtankDustPos = { ["AIid_1"]=ccp(-25,-70) ,["AIid_2"]=ccp(-25,-70) ,["AIid_3"]=ccp(-32,-60) ,["AIid_4"]=ccp(-30,-68) ,["AIid_5"]=ccp(-18,-55) ,["AIid_6"]=ccp(-18,-55),["AIid_7"]=ccp(-32,-60) ,["AIid_8"]=ccp(-32,-60)  }
	--左侧侧履带坐标
	self.l_rtankDustPos = { ["AIid_1"]=ccp(40,-47) ,["AIid_2"]=ccp(40,-50) ,["AIid_3"]=ccp(30,-30) ,["AIid_4"]=ccp(30,-30) ,["AIid_5"]=ccp(20,-35) ,["AIid_6"]=ccp(20,-35),["AIid_7"]=ccp(30,-30) ,["AIid_8"]=ccp(30,-30)  }
	--左侧尾光坐标
	self.l_downPos = { ["AIid_1"]=ccp(15,-30) ,["AIid_2"]=ccp(15,-30) ,["AIid_3"]=ccp(0,-15) ,["AIid_4"]=ccp(0,-15) ,["AIid_5"]=ccp(5,-15) ,["AIid_6"]=ccp(5,-15),["AIid_7"]=ccp(0,-15) ,["AIid_8"]=ccp(0,-15)  }
	--右侧尾光坐标
	self.r_downPos = { ["AIid_1"]=ccp(5,-10) ,["AIid_2"]=ccp(5,-10) ,["AIid_3"]=ccp(0,0) ,["AIid_4"]=ccp(0,-10) ,["AIid_5"]=ccp(10,5) ,["AIid_6"]=ccp(10,5) ,["AIid_7"]=ccp(0,0) ,["AIid_8"]=ccp(0,0)  }

	--左侧 控制子弹飞行角度
	self.l_tankBulletRotate={ ["AIid_6"]=155 , ["AIid_5"]=155 }
	--右方向上旋转为正数 控制子弹飞行角度
	self.r_tankBulletRotate={ ["AIid_6"]=-25 , ["AIid_5"]=-25 }
	--右侧开火坐标
	self.rtankFirePos={ ["AIid_6"]=ccp(-90,-28) , ["AIid_5"]=ccp(-82,-10) }
	--左侧开火坐标
	self.ltankFirePos={ ["AIid_6"]=ccp(75,55) , ["AIid_5"]=ccp(70,60) }
	--右侧子弹相对坦克本身的坐标偏移
	self.rightTopShellStartPos={ ["AIid_6"]=ccp(-90,-28) , ["AIid_5"]=ccp(-84,-12) }
	--左侧子弹相对坦克本身的坐标偏移
	self.leftDownShellStartPos={ ["AIid_6"]=ccp(84,60) , ["AIid_5"]=ccp(74,62) }

	self.tankBulletCfg={ ["AIid_6"]={"laser_1.png"} , ["AIid_5"]={"laser_1.png"} }
end
function aiTank:init( )
	self:initAiTanksCfg()
	local aiTroopCfg = AITroopsVoApi:getModelCfg()
	local btPic = aiTroopCfg.aitroopType[self.aId].btPic.."_"..self.area..".png"
	self.btPic = btPic
	self.AiId = aiTroopCfg.aitroopType[self.aId].btPic--给自己的初始化配置表使用的
	-- print("aiTank--area : pos : AIid-->>>",self.area,self.pos,self.AiId)
	self.container=CCNode:create()
	self.sprite=CCSprite:createWithSpriteFrameName(btPic)
	self.container:addChild(self.sprite,2) --ai坦克本身

	self:showRTankDust()

	if self.area==1 then
        local stPos=self.rightTopPos[self.pos]
        self.container:setPosition(stPos)
        self.tankPosition=stPos
        self.randPosition=stPos
   else
        local stPos=self.leftDownPos[self.pos]
        self.container:setPosition(stPos)
        self.tankPosition=stPos
        self.randPosition=stPos
   end
   self.sprite:setVisible(false)

   if self.area==1 then
      if self.parent and self.parent.r_tankLayer then
         self.parent.r_tankLayer:addChild(self.container,2) --添加到战场
      else
        battleScene.r_tankLayer:addChild(self.container,2) --添加到战场
     end
   else
      if self.parent and self.parent.l_tankLayer then
         self.parent.l_tankLayer:addChild(self.container,2) --添加到战场
      else
        battleScene.l_tankLayer:addChild(self.container,2) --添加到战场
     end
   end
end

---履带烟雾
function aiTank:showRTankDust( )
	local rtankDustSp = CCSprite:createWithSpriteFrameName("aiTrack1_1.png")
	rtankDustSp:setRotation(6)
	local subWidth = rtankDustSp:getContentSize().width
	local subHeight = rtankDustSp:getContentSize().height
	rtankDustSp:setScaleX(0.7)
	rtankDustSp:setAnchorPoint(ccp(0,0))
	self.rtankDustSp = rtankDustSp
	if self.area == 2 then
		rtankDustSp:setFlipY(true)
		rtankDustSp:setFlipX(true)
	end
	local dustArr = CCArray:create()
	for kk=1,10 do
        local nameStr="aiTrack1_"..kk..".png"
        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
        dustArr:addObject(frame)
   end
   local animation=CCAnimation:createWithSpriteFrames(dustArr)
   animation:setDelayPerUnit(0.03)
   local animate=CCAnimate:create(animation)
   local repeatForever=CCRepeatForever:create(animate)
   rtankDustSp:runAction(repeatForever)
   self.container:addChild(rtankDustSp,7) --履带烟雾
   if self.area==1 then
        rtankDustSp:setPosition(self.r_rtankDustPos[self.AiId])
   elseif  self.area==2 then --左方坦克
        rtankDustSp:setPosition(self.l_rtankDustPos[self.AiId].x - subWidth * 0.5,self.l_rtankDustPos[self.AiId].y - subHeight * 0.5)
   end
   self.rtankDustSp:setVisible(false)
end


function aiTank:showAiTankAnimation(willDetTime,allTankTb,callback)--,callBackFire)
	self.isShow =true

	local function animation3Show( )

			if self.sprite then
				self.sprite:setVisible(true)
				if self.rtankDustSp then
					self.rtankDustSp:setVisible(true)
				elseif self.ltankDustSp then
					self.ltankDustSp:setVisible(true)
				end
			else
				print "~~~~~~~~~~~~~~error in aiTank animation3Show -->>self.sprite is nil~~~~~~~~~~~~~~"
			end
			---------添加释放技能的位置
			local canUseSkillTb = { [1]=1, [2]=2, [8]=8 }--如果有新的技能类型，继续往这里添加即可
			if self.aiSkillTb and canUseSkillTb[self.aiSkillTb[2]] then--根据技能类型选择释放效果  旧逻辑： self.aiSkillTb[2] > 0 and self.aiSkillTb[2] < 3 then 
				self:animationCtrlByType(allTankTb,0.05,callback)
			elseif callback then
				callback()
			end
	end

	local function animation2Show ()

		local ani2Sp = CCSprite:createWithSpriteFrameName("AiShow_2_1.png")-- 爆 点
		self.container:addChild(ani2Sp,3)
		ani2Sp:setScale(1.25)
		local blendFunc=ccBlendFunc:new()--爆点裁图混合模式为 ONE ONE
		blendFunc.src=GL_ONE
		blendFunc.dst=GL_ONE
		ani2Sp:setBlendFunc(blendFunc)

		local animArr2=CCArray:create()
		for kk=1,14 do
	        local nameStr="AiShow_2_"..kk..".png"
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	        animArr2:addObject(frame)
	    end
	    local function ani2SpStopCall( ... )
	    	ani2Sp:stopAllActions()
	        ani2Sp:removeFromParentAndCleanup(true)
	        
	    end
	    local ani2SpStop=CCCallFunc:create(ani2SpStopCall)
	    local animation2=CCAnimation:createWithSpriteFrames(animArr2)
	    animation2:setDelayPerUnit(0.033 * G_battleSpeed)
	    local animate2=CCAnimate:create(animation2)
		local seq2=CCSequence:createWithTwoActions(animate2,ani2SpStop)  
		ani2Sp:runAction(seq2)
		

		-----------------------
		local ani3Sp = CCSprite:createWithSpriteFrameName("AiShow_3_1.png")-- 底 部 扩 散
		self.container:addChild(ani3Sp,2)
		ani3Sp:setScale(1.25)
		local animArr3=CCArray:create()
		for kk=1,10 do
	        local nameStr="AiShow_3_"..kk..".png"
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	        animArr3:addObject(frame)
	    end
	    local function ani3SpStopCall( ... )
	    	ani3Sp:stopAllActions()
	        ani3Sp:removeFromParentAndCleanup(true)
	        
	    end
	    local ani3SpStop=CCCallFunc:create(ani3SpStopCall)
	    local animation3=CCAnimation:createWithSpriteFrames(animArr3)
	    animation3:setDelayPerUnit(0.033 * G_battleSpeed)
	    local animate3=CCAnimate:create(animation3)
		local seq3=CCSequence:createWithTwoActions(animate3,ani3SpStop)  
		ani3Sp:runAction(seq3)
					
	end

	local function animation1Show ()
			local animatDownSp = CCSprite:createWithSpriteFrameName("AiShowDown_"..self.area.."_1.png")
			animatDownSp:setScale(1.25)
			if self.area == 1 then
				animatDownSp:setPosition(self.r_downPos[self.AiId])
			else
				animatDownSp:setPosition(self.l_downPos[self.AiId])
			end
			self.container:addChild(animatDownSp,1)

			local animatDownArr=CCArray:create()
			for kk=1,10 do
				  local nameStr="AiShowDown_"..self.area.."_"..kk..".png"
				  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				  animatDownArr:addObject(frame)
			end
			local animationDown=CCAnimation:createWithSpriteFrames(animatDownArr)
			animationDown:setDelayPerUnit(0.033 * G_battleSpeed)
			local animateDown=CCAnimate:create(animationDown)
			local repeatForever=CCRepeatForever:create(animateDown)
			animatDownSp:runAction(repeatForever)

			-----------------------
			local ani1Sp = CCSprite:createWithSpriteFrameName("AiShow_1_1.png")-- 聚 集
			self.container:addChild(ani1Sp,3)
			ani1Sp:setScale(1.25)
			local animArr1=CCArray:create()
			for kk=1,32 do
		        local nameStr="AiShow_1_"..kk..".png"
		        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
		        animArr1:addObject(frame)
		    end
		    local function ani1SpStopCall( ... )
		    	ani1Sp:stopAllActions()
		        ani1Sp:removeFromParentAndCleanup(true)
		        animation2Show()
		    end
		    local ani1SpStop=CCCallFunc:create(ani1SpStopCall)
		    local animation1=CCAnimation:createWithSpriteFrames(animArr1)
		    animation1:setDelayPerUnit(0.033 * G_battleSpeed)
		    local animate1=CCAnimate:create(animation1)
			local seq1=CCSequence:createWithTwoActions(animate1,ani1SpStop)  
			ani1Sp:runAction(seq1)
			
	end



	local function beginFun( )
		animation1Show()	
	end
	local function animate3Fun( )
		animation3Show()
	end
	local ani3Det = CCDelayTime:create(0.03 * 40 * G_battleSpeed)
	local animate3Call = CCCallFunc:create(animate3Fun)
	local beginGo = CCCallFunc:create(beginFun)
	local beginDet = CCDelayTime:create((willDetTime + 0.5) * G_battleSpeed)
	local beginArr = CCArray:create()
	beginArr:addObject(beginDet)
	beginArr:addObject(beginGo)
	beginArr:addObject(ani3Det)
	beginArr:addObject(animate3Call)
	local beginSeq = CCSequence:create(beginArr)
	self.container:runAction(beginSeq)
	
end

function aiTank:nextAtt(deT,nextFun)
   local function nowCall( )
   		if nextFun then
   			nextFun()
   		end
   end 
   local nextGo  = CCCallFunc:create(nowCall)
   local nextDet = CCDelayTime:create(deT * G_battleSpeed)
   local nextArr = CCArray:create()
   nextArr:addObject(nextDet)
   nextArr:addObject(nextGo)
   local nextSeq = CCSequence:create(nextArr)
   self.container:runAction(nextSeq)
end


------ca:ai部队加命中,cb:ai部队加闪避,cc:ai部队加暴击,cd:ai部队加装甲
------ce:ai部队加护盾
function aiTank:animationCtrlByType(allTankTb,curDelayT,callback)
	local curType = self.aiSkillTb[4]
	local DetT = CCDelayTime:create(curDelayT * G_battleSpeed)
	local upPosy = 70
	if curType == "ca" or curType == "cb" then
		local curDet = 0.08
		local function bufAnimatCall( )
			local toSelfSp = CCSprite:createWithSpriteFrameName("aiSelfSkillUse_1.png")
			local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
			blendFunc.src=GL_ONE
			blendFunc.dst=GL_ONE
			toSelfSp:setBlendFunc(blendFunc)

			local toSelfArr=CCArray:create()
			for kk=1,16 do
				  local nameStr = "aiSelfSkillUse_"..kk..".png"
				  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				  toSelfArr:addObject(frame)
			end

			local bufAnimation=CCAnimation:createWithSpriteFrames(toSelfArr)
			bufAnimation:setDelayPerUnit(curDet * G_battleSpeed)
			local bufAnimate=CCAnimate:create(bufAnimation)
			local function bufToTankFun( )
				toSelfSp:stopAllActions()
		        toSelfSp:removeFromParentAndCleanup(true)

				if self.aiSkillTb[3] and allTankTb then--我方全体坦克被施加盾效果
					for i=1,6 do
						if allTankTb[i].isWillDie == false then
							allTankTb[i]:animationCtrlByType(string.upper(curType),nil,true)
						end
					end
				else
					local pos = self.aiSkillTb[6]
					if not allTankTb[pos].isWillDie then
						allTankTb[pos]:animationCtrlByType(string.upper(curType),nil,true)
					else
						print("~~~~ b u f f -- e r r o r ~~~aiUseBlueSkill~~tank in pos is nil~~~~~~~pos:",pos,curType)
					end
				end	
			end 
			local bufToTankCall = CCCallFunc:create(bufToTankFun)
			local toSelfSeq = CCSequence:createWithTwoActions(bufAnimate,bufToTankCall)  
			toSelfSp:runAction(toSelfSeq)
			toSelfSp:setPosition(-10,upPosy)
			self.container:addChild(toSelfSp,2)

			local function bufRepeatFun()
					local picT = curType=="ca" and "aiHit_1.png" or "aiDodge_1.png"-----命中（ca） 缺图！！！
					local toSelfSp2 = CCSprite:createWithSpriteFrameName(picT)
					local toSelfArr2=CCArray:create()
					if curType == "ca" then
						for kk=1,10 do
						   local nameStr="aiHit_"..kk..".png"
						   local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
						   toSelfArr2:addObject(frame)
						end
					else
						toSelfSp2:setScale(1.3)
						for kk=1,12 do
						   local nameStr="aiDodge_"..kk..".png"
						   local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
						   toSelfArr2:addObject(frame)
						end
					end
					local bufAnimation2=CCAnimation:createWithSpriteFrames(toSelfArr2)
					bufAnimation2:setDelayPerUnit(curDet * G_battleSpeed)
					local bufAnimate2=CCAnimate:create(bufAnimation2)
					local bufRepeat2=CCRepeatForever:create(bufAnimate2)
					toSelfSp2:runAction(bufRepeat2)
					toSelfSp2:setPositionY(upPosy)
					self.container:addChild(toSelfSp2,2)
			end
			local bufCall2 = CCCallFunc:create(bufRepeatFun)
			local bufDet2 = CCDelayTime:create(curDet * 6 * G_battleSpeed)
			local toSelfSeq2 = CCSequence:createWithTwoActions(bufDet2,bufCall2)  
			self.container:runAction(toSelfSeq2)
			
		end 
		local bufFun = CCCallFunc:create(bufAnimatCall)
		local bufArr = CCArray:create()
		bufArr:addObject(DetT)
		bufArr:addObject(bufFun)

		if callback then
			local detCall = CCDelayTime:create(1.3)
			local function hasCall()
				callback()
			end
			local parCall = CCCallFunc:create(hasCall)
			bufArr:addObject(detCall)
			bufArr:addObject(parCall)
		end
		local bufSeq = CCSequence:create(bufArr)
		self.container:runAction(bufSeq)
	elseif curType == "cc" or curType == "cd" then--cc:ai部队加暴击,cd:ai部队加装甲
		local curDet = 0.08
		local function bufAnimatCall( )
			local toSelfSp = CCSprite:createWithSpriteFrameName("aiSelfSkillUse_1.png")
			local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
			blendFunc.src=GL_ONE
			blendFunc.dst=GL_ONE
			toSelfSp:setBlendFunc(blendFunc)
			local toSelfArr=CCArray:create()
			for kk=1,16 do
				  local nameStr = "aiSelfSkillUse_"..kk..".png"
				  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				  toSelfArr:addObject(frame)
			end
			local bufAnimation=CCAnimation:createWithSpriteFrames(toSelfArr)
			bufAnimation:setDelayPerUnit(curDet * G_battleSpeed)
			local bufAnimate=CCAnimate:create(bufAnimation)
			local function bufToTankFun( )
				toSelfSp:stopAllActions()
		        toSelfSp:removeFromParentAndCleanup(true)
		        
				if self.aiSkillTb[3] and allTankTb then--我方全体坦克被施加盾效果
					for i=1,6 do
						if allTankTb[i].isWillDie == false then
							allTankTb[i]:animationCtrlByType(string.upper(curType),nil,true)
						end
					end
				else
					local pos = self.aiSkillTb[6]
					if not allTankTb[pos].isWillDie then
						allTankTb[pos]:animationCtrlByType(string.upper(curType),nil,true)
					else
						print("~~~~ b u f f -- e r r o r ~~aiUseYeloSkill~~~tank in pos is nil~~~~~~~pos:",pos,curType)
					end
				end	
			end 
			local bufToTankCall = CCCallFunc:create(bufToTankFun)
			local toSelfSeq = CCSequence:createWithTwoActions(bufAnimate,bufToTankCall)  
			toSelfSp:runAction(toSelfSeq)
			toSelfSp:setPosition(-10,upPosy)
			self.container:addChild(toSelfSp,2)

			local function bufRepeatFun()
					local picT = curType=="cc" and "aiCrit_1.png" or "aiArmorIcon_1.png"
					local toSelfSp2 = CCSprite:createWithSpriteFrameName(picT)
					local toSelfArr2=CCArray:create()
					if curType == "cc" then
						if self.area == 1 then
							toSelfSp2:setFlipX(true)
						end
						for kk=1,12 do
						   local nameStr="aiCrit_"..kk..".png"
						   local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
						   toSelfArr2:addObject(frame)
						end
					else
						for kk=1,12 do
						   local nameStr="aiArmorIcon_"..kk..".png"
						   local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
						   toSelfArr2:addObject(frame)
						end
					end
					local bufAnimation2=CCAnimation:createWithSpriteFrames(toSelfArr2)
					bufAnimation2:setDelayPerUnit(curDet * G_battleSpeed)
					local bufAnimate2=CCAnimate:create(bufAnimation2)
					local bufRepeat2=CCRepeatForever:create(bufAnimate2)
					toSelfSp2:runAction(bufRepeat2)
					toSelfSp2:setPositionY(upPosy)
					self.container:addChild(toSelfSp2,2)
			end
			local bufCall2 = CCCallFunc:create(bufRepeatFun)
			local bufDet2 = CCDelayTime:create(curDet * 6 * G_battleSpeed)
			local toSelfSeq2 = CCSequence:createWithTwoActions(bufDet2,bufCall2)  
			self.container:runAction(toSelfSeq2)
		end 
		local bufFun = CCCallFunc:create(bufAnimatCall)
		local bufArr = CCArray:create()
		bufArr:addObject(DetT)
		bufArr:addObject(bufFun)

		if callback then
			local detCall = CCDelayTime:create(1.3)
			local function hasCall()
				callback()
			end
			local parCall = CCCallFunc:create(hasCall)
			bufArr:addObject(detCall)
			bufArr:addObject(parCall)
		end

		local bufSeq = CCSequence:create(bufArr)
		self.container:runAction(bufSeq)
	elseif curType == "ce" or curType == "cf" then
		local picT = self.aiSkillTb[5]--护盾图片类型
		local curDet = 0.08
		local function shieldAnimatCall( )
			local toSelfSp = CCSprite:createWithSpriteFrameName("aiSelfSkillUse_1.png")--"aiShieldToSelf"..picT.."_1.png")
			local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
			blendFunc.src=GL_ONE
			blendFunc.dst=GL_ONE
			toSelfSp:setBlendFunc(blendFunc)
			local toSelfArr=CCArray:create()
			for kk=1,16 do
				  local nameStr = "aiSelfSkillUse_"..kk..".png"
				  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				  toSelfArr:addObject(frame)
			end
			local function sheildShowCall( ... )
		    	toSelfSp:stopAllActions()
		        toSelfSp:removeFromParentAndCleanup(true)

				if self.aiSkillTb[3] and allTankTb then--我方全体坦克被施加盾效果
					for i=1,6 do
						if allTankTb[i].isWillDie == false then
							allTankTb[i]:animationCtrlByType(string.upper(curType),nil,true)
						end
					end
				else
					local pos = self.aiSkillTb[6]
					if not allTankTb[pos].isWillDie then
						allTankTb[pos]:animationCtrlByType(string.upper(curType),nil,true)
					else
						print("~~~~ s h i e l d -- e r r o r ~~~~~tank in pos is nil~~~~~~~pos:",pos)
					end
				end	
		    end
		    local sFun=CCCallFunc:create(sheildShowCall)
			local sAnimation=CCAnimation:createWithSpriteFrames(toSelfArr)
			sAnimation:setDelayPerUnit(curDet * G_battleSpeed)
			local sAnimate=CCAnimate:create(sAnimation)
			local toSelfSeq = CCSequence:createWithTwoActions(sAnimate,sFun)  
			toSelfSp:runAction(toSelfSeq)
			toSelfSp:setPosition(-10,upPosy)
			self.container:addChild(toSelfSp,2)

			local function shieldToTankFun( )
				local loopSp   = CCSprite:createWithSpriteFrameName("aiShieldIcon"..picT.."_1.png")
		        loopSp:setPositionY(upPosy)
		        self.container:addChild(loopSp,2)
				local loopArr=CCArray:create()
				for kk=1,12 do
					  local nameStr="aiShieldIcon"..picT.."_"..kk..".png"
					  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
					  loopArr:addObject(frame)
				end
				local loopAnimation=CCAnimation:createWithSpriteFrames(loopArr)
				loopAnimation:setDelayPerUnit(curDet * G_battleSpeed)
				local loopAnimate=CCAnimate:create(loopAnimation)
				local loopRepeat=CCRepeatForever:create(loopAnimate)
				
				loopSp:runAction(loopRepeat)
			end 
			local toTankCall = CCCallFunc:create(shieldToTankFun)
			local toTankDet = CCDelayTime:create(curDet * 6 * G_battleSpeed) -- curDet x 帧数
			local toTankSeq = CCSequence:createWithTwoActions(toTankDet,toTankCall)

			self.container:runAction(toTankSeq)
			
		end
		local shieldFun = CCCallFunc:create(shieldAnimatCall)
		local sArr = CCArray:create()
		sArr:addObject(DetT)
		sArr:addObject(shieldFun)

		if callback then
			local detCall = CCDelayTime:create(1.3)
			local function hasCall()
				callback()
			end
			local parCall = CCCallFunc:create(hasCall)
			sArr:addObject(detCall)
			sArr:addObject(parCall)
		end

		local sSeq = CCSequence:create(sArr)
		self.container:runAction(sSeq)
	elseif curType == "ck" then -- 只表现aiTank的动画，没有给坦克部队施加动画的表现
		local curDet = 0.08
		local function bufAnimatCall( )
			local toSelfSp = CCSprite:createWithSpriteFrameName("aiSelfSkillUse_1.png")
			local blendFunc=ccBlendFunc:new()--混合模式为 ONE ONE
			blendFunc.src=GL_ONE
			blendFunc.dst=GL_ONE
			toSelfSp:setBlendFunc(blendFunc)

			local toSelfArr=CCArray:create()
			for kk=1,16 do
				  local nameStr = "aiSelfSkillUse_"..kk..".png"
				  local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
				  toSelfArr:addObject(frame)
			end

			local bufAnimation=CCAnimation:createWithSpriteFrames(toSelfArr)
			bufAnimation:setDelayPerUnit(curDet * G_battleSpeed)
			local bufAnimate=CCAnimate:create(bufAnimation)
			local function bufToTankFun( )
				toSelfSp:stopAllActions()
		        toSelfSp:removeFromParentAndCleanup(true)
			end 
			local bufToTankCall = CCCallFunc:create(bufToTankFun)
			local toSelfSeq = CCSequence:createWithTwoActions(bufAnimate,bufToTankCall)  
			toSelfSp:runAction(toSelfSeq)
			toSelfSp:setPosition(-10,upPosy)
			self.container:addChild(toSelfSp,2)

			local function bufRepeatFun()
					local picT = "restrain_1.png"--curType=="ci" and "restrain_1.png" or "aiDodge_1.png"
					local toSelfSp2 = CCSprite:createWithSpriteFrameName(picT)
					local toSelfArr2=CCArray:create()
					for kk=1,12 do
					   local nameStr="restrain_"..kk..".png"
					   local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
					   toSelfArr2:addObject(frame)
					end
					local bufAnimation2=CCAnimation:createWithSpriteFrames(toSelfArr2)
					bufAnimation2:setDelayPerUnit(curDet * G_battleSpeed)
					local bufAnimate2=CCAnimate:create(bufAnimation2)
					local bufRepeat2=CCRepeatForever:create(bufAnimate2)
					toSelfSp2:runAction(bufRepeat2)
					toSelfSp2:setPositionY(upPosy)
					self.container:addChild(toSelfSp2,2)
			end
			local bufCall2 = CCCallFunc:create(bufRepeatFun)
			local bufDet2 = CCDelayTime:create(curDet * 6 * G_battleSpeed)
			local toSelfSeq2 = CCSequence:createWithTwoActions(bufDet2,bufCall2)  
			self.container:runAction(toSelfSeq2)
			
		end 
		local bufFun = CCCallFunc:create(bufAnimatCall)
		local bufArr = CCArray:create()
		bufArr:addObject(DetT)
		bufArr:addObject(bufFun)

		if callback then
			local detCall = CCDelayTime:create(1.3)
			local function hasCall()
				callback()
			end
			local parCall = CCCallFunc:create(hasCall)
			bufArr:addObject(detCall)
			bufArr:addObject(parCall)
		end
		local bufSeq = CCSequence:create(bufArr)
		self.container:runAction(bufSeq)

	end
end

function aiTank:showLaserFire(rate)
	PlayEffect(audioCfg.tank_5)--激光的声效，老版本的

	if self.aiTankFireSp~=nil then
		  self.aiTankFireSp:stopAllActions()
		  self.aiTankFireSp:removeFromParentAndCleanup(true)
		  self.aiTankFireSp=nil
	end
	local tankFireFrameName="laserFire"..self.area.."_1.png" --开火动画
	self.aiTankFireSp=CCSprite:createWithSpriteFrameName(tankFireFrameName)

	local fireArr=CCArray:create()
	for kk=1,19 do
	   local nameStr="laserFire"..self.area.."_"..kk..".png"
	   local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	   fireArr:addObject(frame)
	end
	local animation=CCAnimation:createWithSpriteFrames(fireArr)

	if not rate then
		animation:setDelayPerUnit(0.04 * G_battleSpeed)
	else
		animation:setDelayPerUnit(rate * G_battleSpeed)
	end

	local animate=CCAnimate:create(animation)
	self.container:addChild(self.aiTankFireSp,7)
	if self.area == 1 then
		self.aiTankFireSp:setPosition(self.rtankFirePos[self.AiId])
	else
		self.aiTankFireSp:setPosition(self.ltankFirePos[self.AiId])
	end

	local function removeFireSp()
          self.aiTankFireSp:removeFromParentAndCleanup(true)
          self.aiTankFireSp=nil
    end
    local  ffunc=CCCallFuncN:create(removeFireSp)
    local  fseq=CCSequence:createWithTwoActions(animate,ffunc)
    self.aiTankFireSp:runAction(fseq)
    --************以上代码是开火动画

    local t_bulletCfg=self.tankBulletCfg[self.AiId]
   
   local bulletframeName
   if self.area==1 then
      bulletframeName=t_bulletCfg[1]
   else
      if   t_bulletCfg[2]==nil then
            bulletframeName=t_bulletCfg[1]
      else
            bulletframeName=t_bulletCfg[2]
      end
   end

   local m_shellSp=CCSprite:createWithSpriteFrameName(bulletframeName)
   m_shellSp:setAnchorPoint(ccp(0.5,0.5))
   m_shellSp:setVisible(false)
   --以下设置子弹
   local shellMV
   local curFireNum2 = 1 --self.fireNum >6 and self.fireNum%6 or self.fireNum--用于随机炮弹数量使用
   if self.area==1 then
		if self.parent and self.parent.r_shellLayer then
		 	self.parent.r_shellLayer:addChild(m_shellSp)
		else
			battleScene.r_shellLayer:addChild(m_shellSp)
		end

        local stPosX,stPosY=self.rightTopPos[self.pos].x,self.rightTopPos[self.pos].y
        stPosX=stPosX+self.rightTopShellStartPos[self.AiId].x
        stPosY=stPosY+self.rightTopShellStartPos[self.AiId].y
        m_shellSp:setPosition(ccp(stPosX,stPosY))
        
         local bulletAnimArr=CCArray:create()
	     for kk=1,14 do
	        local nameStr="laser_"..kk..".png"
	        local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
	        bulletAnimArr:addObject(frame)
	     end

	     local animation=CCAnimation:createWithSpriteFrames(bulletAnimArr)
	     animation:setDelayPerUnit(0.04 * G_battleSpeed)
	     shellMV=CCAnimate:create(animation)
	     m_shellSp:setAnchorPoint(ccp(1,0.5))
	     m_shellSp:setRotation(self.r_tankBulletRotate[self.AiId])

   else
		if self.parent and self.parent.l_shellLayer then
			self.parent.l_shellLayer:addChild(m_shellSp)
		else
			battleScene.l_shellLayer:addChild(m_shellSp)
		end

        local stPosX,stPosY=self.leftDownPos[self.pos].x,self.leftDownPos[self.pos].y
        stPosX=stPosX+self.leftDownShellStartPos[self.AiId].x
        stPosY=stPosY+self.leftDownShellStartPos[self.AiId].y
        m_shellSp:setPosition(ccp(stPosX,stPosY))
        
         local bulletAnimArr=CCArray:create()
         for kk=1,14 do
            local nameStr="laser_"..kk..".png"
            local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
            bulletAnimArr:addObject(frame)
         end

         local animation=CCAnimation:createWithSpriteFrames(bulletAnimArr)
         animation:setDelayPerUnit(0.04 * G_battleSpeed)
         shellMV=CCAnimate:create(animation)
         
         m_shellSp:setAnchorPoint(ccp(1,0.5))
         m_shellSp:setRotation(self.l_tankBulletRotate[self.AiId])

   end
   local function showFun()
   		m_shellSp:setVisible(true)
   end 
   local  ffunc3=CCCallFuncN:create(showFun)
   local function moveEnd()
        m_shellSp:removeFromParentAndCleanup(true)
        m_shellSp=nil
   end
   local  ffunc2=CCCallFuncN:create(moveEnd)
   local fArr = CCArray:create()
   local fDet = CCDelayTime:create(0.5)
   fArr:addObject(fDet)
   fArr:addObject(ffunc3)
   fArr:addObject(shellMV)
   fArr:addObject(ffunc2)
   local  fseq=CCSequence:create(fArr)
   m_shellSp:runAction(fseq)
end

