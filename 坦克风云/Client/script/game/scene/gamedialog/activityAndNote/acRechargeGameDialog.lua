acRechargeGameDialog=commonDialog:new()

function acRechargeGameDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.acTab1=nil
	self.acTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.isNeedRef=false
	self.isTimeUpToRef=false --每15秒请求一次数据
	self.secTimes=15
	self.idx=0
	return nc
end

function acRechargeGameDialog:resetTab()
	local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
          tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end

         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    self.selectedTabIndex = 0
end

function acRechargeGameDialog:initTableView() 
	self:tabClick(0,false)
end
function acRechargeGameDialog:tabClick(idx,isEffect)
	if(isEffect)then
		PlayEffect(audioCfg.mouseClick)
	end
	for k,v in pairs(self.allTabs) do
		if v:getTag()==idx then
			v:setEnabled(false)
			self.selectedTabIndex=idx
		else
			v:setEnabled(true)
		end
	end
	self.idx =idx 
	if(idx==0)then
		if(self.acTab1==nil)then
			local function rechargeSock(fn,data)
				local ret,sData=base:checkServerData(data)
		        if ret==true then
		        	if sData.data and sData.data.rechargeCompetition then
		        		local recData = sData.data.rechargeCompetition
		        		if recData.v then
		        			acRechargeGameVoApi:setSelfRank(recData.v)
		        		end
		        		if recData.rankList and SizeOfTable(recData.rankList)>0 then
		        			print("here????")
		        			acRechargeGameVoApi:setRankList(recData.rankList)
		        		end
		        	end
		        	self.acTab1=acRechargeGameTab1:new()
					self.layerTab1=self.acTab1:init(self.layerNum)
					self.bgLayer:addChild(self.layerTab1)
		        	if self.layerTab1 then
			        	self.layerTab1:setPosition(ccp(0,0))
						self.layerTab1:setVisible(true)
					end
		        end
			end
			socketHelper:activeRechargeGame(rechargeSock)
		elseif self.layerTab1 then
			print("in layerTab1---->self.secTimes:",self.secTimes)
			if self.secTimes<1 then
				self:getRankList()
				self.secTimes =15
			end
        	self.layerTab1:setPosition(ccp(0,0))
			self.layerTab1:setVisible(true)
		end
		if self.layerTab2 then
			self.layerTab2:setPosition(ccp(999333,0))
			self.layerTab2:setVisible(false)
		end
	elseif(idx==1)then
		if(self.acTab2==nil)then
			self.acTab2=acRechargeGameTab2:new()
			self.layerTab2=self.acTab2:init(self.layerNum)
			self.bgLayer:addChild(self.layerTab2)
		end
		if self.layerTab1 then
			self.layerTab1:setPosition(ccp(999333,0))
			self.layerTab1:setVisible(false)
		end
		if self.layerTab2 then
			print("in layerTab2---->self.secTimes:",self.secTimes)
			if self.secTimes<1 then
				self:getRankList()
				self.secTimes =15
			end
			self.layerTab2:setPosition(ccp(0,0))
			self.layerTab2:setVisible(true)
		end
	end
end

function acRechargeGameDialog:tick()
	local vo=acRechargeGameVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end
    if self.secTimes>0 and base.serverTime+30 < vo.acEt-86400 then
    	self.secTimes = self.secTimes-1
    end
end

function acRechargeGameDialog:refData()
	acRechargeGameVoApi:isRefRank(false)
	self.acTab1:refData()
	self.acTab2:refData()
end

function acRechargeGameDialog:getRankList()
	local function rechargeSock(fn,data)
		local ret,sData=base:checkServerData(data)
        if ret==true then
        	if sData.data and sData.data.rechargeCompetition then
        		local recData = sData.data.rechargeCompetition
        		if recData.v then
        			acRechargeGameVoApi:setSelfRank(recData.v)
        		end
        		if recData.rankList and SizeOfTable(recData.rankList)>0 then
        			acRechargeGameVoApi:setRankList(recData.rankList)
        		end
        	end
        	if acRechargeGameVoApi:isRefRank() ==false then
        		acRechargeGameVoApi:isRefRank(true)
        		self:refData()
        	end
        end
	end
	socketHelper:activeRechargeGame(rechargeSock)
end

function acRechargeGameDialog:dispose()
	if self.layerTab1 then
		self.acTab1:dispose()
	end
	if self.layerTab2 then
		self.acTab2:dispose()
	end
	self.acTab1=nil
	self.acTab2=nil
	self.layerTab1=nil
	self.layerTab2=nil
	self.isNeedRef=nil
	self.isTimeUpToRef=nil --每15秒请求一次数据
	self.secTimes=0
end