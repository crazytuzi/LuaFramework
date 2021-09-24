local PowerNumNode=classGc(function(self,_powerNum)
	self.m_curPowerNum=_powerNum
	self.m_goPowerNum=_powerNum
	self.m_powerNumArray={}
end)

function PowerNumNode.create(self)
	self.m_rootNode=cc.Node:create()
	self:initView()
	return self.m_rootNode
end

function PowerNumNode.initView(self)	
	self.m_powerSpr=cc.Sprite:createWithSpriteFrameName("main_fighting.png")
    self.m_rootNode:addChild(self.m_powerSpr)

    self.m_numNode=cc.Node:create()
    self.m_numNode:setContentSize(cc.size(6,6))
    self.m_numNode:setAnchorPoint(cc.p(0,0.5))
    self.m_numNode:setPosition(30,3)
    self.m_rootNode:addChild(self.m_numNode)

    self.m_powerLabel=_G.Util:createLabel("",20)
    -- self.m_powerLabel:setPosition()
    self.m_numNode:addChild(self.m_powerLabel)

	self:updatePowerNum(self.m_curPowerNum)

	local comm=CPowerfulCreateCommand(CPowerfulCreateCommand.Type)
 	_G.controller:sendCommand(comm)
end

function PowerNumNode.updatePowerNum(self,_power)
	local szPower=tostring(_power)
	-- print("updatePowerNum======>>>",szPower)

	self.m_powerLabel:setString(string.format("战力:%d",_power))

	-- local bitNum=string.len(szPower)
 --    for i=1,bitNum do
 --        local curNum=string.sub(szPower,i,i)
 --        -- gcprint("MainView.curNum=======>>>>>",curNum)
 --        if self.m_powerNumArray[i]==nil then
 --            local szNumImg=string.format("general_powerno_%d.png",curNum)
 --            local numSpr=cc.Sprite:createWithSpriteFrameName(szNumImg)
 --            numSpr:setPosition((i-1)*15,0)
 --            -- numSpr:setScale(1.4)
 --            self.m_numNode:addChild(numSpr)

 --            local numT={}
 --            numT.num=curNum
 --            numT.spr=numSpr
 --            self.m_powerNumArray[i]=numT         
 --        elseif self.m_powerNumArray[i].num~=curNum then
 --            local szNumImg=string.format("general_powerno_%d.png",curNum)
 --            self.m_powerNumArray[i].spr:setSpriteFrame(szNumImg)
 --            self.m_powerNumArray[i].spr:setVisible(true)
 --            self.m_powerNumArray[i].num=curNum
 --        else
 --            self.m_powerNumArray[i].spr:setVisible(true)
 --        end
 --    end

 --    for i=(bitNum+1),#self.m_powerNumArray do
 --        local numSpr=self.m_powerNumArray[i].spr
 --        numSpr:setVisible(false)
 --    end

    self.m_curPowerNum=_power
end

function PowerNumNode.setPower(self,_powerNum,_noEffect)
	if self.m_curPowerNum==_powerNum and _powerNum==self.m_goPowerNum then return end

	self.m_goPowerNum=_powerNum
	if _noEffect then
		self:updatePowerNum(_powerNum)
	else
		self.m_stepPower=(self.m_goPowerNum-self.m_curPowerNum)/30
		if self.m_stepPower>0 then
			self.m_stepPower=math.ceil(self.m_stepPower)
		else
			self.m_stepPower=math.floor(self.m_stepPower)
		end

		if self.m_myScheduler==nil then
			self.m_myScheduler=true

			local function updateFun()
				local subP=self.m_goPowerNum-self.m_curPowerNum
				local curP=self.m_curPowerNum+self.m_stepPower
				if (curP>self.m_goPowerNum and self.m_stepPower>0)
					or (curP<self.m_goPowerNum and self.m_stepPower<0) then
					curP=self.m_goPowerNum
				end

				if self.m_goPowerNum==curP then
					local act=cc.Sequence:create(cc.ScaleTo:create(0.2,1))
					self.m_numNode:runAction(act)

					self.m_powerSpr:stopAllActions()
					self.m_powerSpr:setColor(cc.c3b(255,255,255))

					self:__hideSubPower()

					_G.Scheduler:unschedule(self.m_myScheduler)
					self.m_myScheduler=nil
				end

				self:updatePowerNum(curP)
			end

			local function nFun()
				self.m_myScheduler=_G.Scheduler:schedule(updateFun,0)
				self:__showSubPower()
			end
			local act=cc.Sequence:create(cc.ScaleTo:create(0.2,1.2),cc.CallFunc:create(nFun))
			self.m_numNode:stopAllActions()
			self.m_numNode:runAction(act)

			local act2=cc.Sequence:create(cc.TintTo:create(0.2,255,122,100),cc.TintTo:create(0.2,255,255,255))
			act2=cc.RepeatForever:create(act2)
			self.m_powerSpr:runAction(act2)
		end
	end
end

function PowerNumNode.__showSubPower(self)
	self:__hideSubPower()

	-- local subPower=self.m_goPowerNum - self.m_curPowerNum
	-- local subString=tostring(subPower)
	-- local cLen=string.len(subString)
	-- local tLen=string.len(tostring(self.m_goPowerNum))

	-- local nColor=nil
	-- if subPower>0 then
	-- 	nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN)
	-- 	subString=string.format("+%s",subString)
	-- else
	-- 	nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED)
	-- 	subString=string.format("-%s",subString)
	-- end

	-- local cWidth=tLen*15
	-- self.m_subPowerNode=_G.Util:createLabel(subString,22)
	-- self.m_subPowerNode:setAnchorPoint(cc.p(0,0.5))
	-- self.m_subPowerNode:setPosition(cWidth,-2)
	-- self.m_subPowerNode:setColor(nColor)
	-- self.m_numNode:addChild(self.m_subPowerNode,10)

	-- do return end

	local subPower=self.m_goPowerNum - self.m_curPowerNum
	local subString=tostring(math.abs(subPower))
	local cLen=string.len(subString)
	local tLen=string.len(tostring(self.m_goPowerNum))
	local cWidth=(tLen+1)*15

	local tempSize=self.m_powerLabel:getContentSize()
	self.m_subPowerNode=cc.Node:create()
	self.m_subPowerNode:setPosition(tempSize.width*0.5*1.2,0)
	self.m_numNode:addChild(self.m_subPowerNode,10)

	local szPer=nil
	if subPower<0 then
		szPer="general_powerno_sub.png"
	else
		szPer="general_powerno_add.png"
	end
	local perSpr=cc.Sprite:createWithSpriteFrameName(szPer)
	perSpr:setPosition(0,0)
	self.m_subPowerNode:addChild(perSpr)

	for i=1,cLen do
		local curNum=string.sub(subString,i,i)
		local szNumImg=string.format("general_powerno_%d.png",curNum)
        local numSpr=cc.Sprite:createWithSpriteFrameName(szNumImg)
        numSpr:setPosition(i*15,0)
        self.m_subPowerNode:addChild(numSpr)
	end
end
function PowerNumNode.__hideSubPower(self)
	if self.m_subPowerNode~=nil then
		self.m_subPowerNode:removeFromParent(true)
		self.m_subPowerNode=nil
	end
end


return PowerNumNode
