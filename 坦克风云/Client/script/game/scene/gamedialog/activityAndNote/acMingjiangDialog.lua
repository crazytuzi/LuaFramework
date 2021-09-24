acMingjiangDialog = commonDialog:new()

function acMingjiangDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.acTab1=nil
    self.acTab2=nil
    self.layerTab1=nil
    self.layerTab2=nil
    self.isStop=false
    self.isToday=true
    return nc
end

function acMingjiangDialog:resetTab()
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

function acMingjiangDialog:initTableView()  
    self:tabClick(0,false)
end

function acMingjiangDialog:tabClick(idx,isEffect)
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
    if(idx==0)then
        if(self.acTab1==nil)then            
            self.acTab1=acMingjiangTab1:new()
            self.layerTab1=self.acTab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
            self:refresh(2)
        end
        if self.layerTab2 then
            self.layerTab2:setPosition(ccp(999333,0))
            self.layerTab2:setVisible(false)
        end
    elseif(idx==1)then
        if(self.acTab2==nil)then
            local function getRanklist(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.huoxianmingjianggai and sData.data.huoxianmingjianggai.clientReward then
                        acMingjiangVoApi:setRanklist(sData.data.huoxianmingjianggai.clientReward)
                    end
                    if sData and sData.data and sData.data.huoxianmingjianggai then
                        acMingjiangVoApi:setRank(sData.data.huoxianmingjianggai.rank)
                    end
                    self.acTab2=acMingjiangTab2:new()
                    self.layerTab2=self.acTab2:init(self.layerNum)
                    self.bgLayer:addChild(self.layerTab2)
                    self:refresh(1)
                end
                
            end
            socketHelper:activeMingjiangRank(getRanklist)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then            
            local function getRanklist(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.huoxianmingjianggai and sData.data.huoxianmingjianggai.clientReward then
                        acMingjiangVoApi:setRanklist(sData.data.huoxianmingjianggai.clientReward)
                    end
                    if sData and sData.data and sData.data.huoxianmingjianggai then
                        acMingjiangVoApi:setRank(sData.data.huoxianmingjianggai.rank)
                    end
                    self.layerTab2:setPosition(ccp(0,0))
                    self.layerTab2:setVisible(true)
                    self:refresh(1)
                end
                
            end
            socketHelper:activeMingjiangRank(getRanklist)
        end
    end
end

function acMingjiangDialog:tick()
    local vo=acMingjiangVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    if not acMingjiangVoApi:isToday() then
      self:refresh(2)
    end

    local isSearchToday=acMingjiangVoApi:isSearchToday()
    local acIsStop=acMingjiangVoApi:acIsStop()

    if self.isStop~=acIsStop or self.isToday~=isSearchToday then
        self:refresh(1)
        self:refresh(2)
        self.isStop=acIsStop
        self.isToday=isSearchToday
    end

    if self.acTab1 and self.acTab1.tick then
        self.acTab1:tick()
    end
end
function acMingjiangDialog:refresh( tab )
    if tab ==1 then
        if self.acTab2 then
            self.acTab2:refresh()
        end
    end
     if tab ==2 then
        if self.acTab1 then
            self.acTab1:refresh()
        end
    end
end
function acMingjiangDialog:dispose()
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
    self.isStop=nil
    self.isToday=nil
    
end

