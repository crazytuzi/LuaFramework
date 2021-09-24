acJunshijiangtanDialog = commonDialog:new()

function acJunshijiangtanDialog:new()
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

function acJunshijiangtanDialog:resetTab()
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

function acJunshijiangtanDialog:initTableView()


    local function callback( ... )
    end

    local hd= LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,400),nil)
  
    self:tabClick(0,false)
end

function acJunshijiangtanDialog:tabClick(idx,isEffect)
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
            self.acTab1=acJunshijiangtanTab1:new()
            self.layerTab1=self.acTab1:init(self.layerNum)
            self.bgLayer:addChild(self.layerTab1)
            self:refresh(2)
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
                    if sData and sData.data and sData.data.junshijiangtan and sData.data.junshijiangtan.clientReward then
                        acJunshijiangtanVoApi:setRanklist(sData.data.junshijiangtan.clientReward)
                    end
                    if sData and sData.data and sData.data.junshijiangtan then
                        acJunshijiangtanVoApi:setRank(sData.data.junshijiangtan.rank)
                    end
                    self.acTab2=acJunshijiangtanTab2:new()
                    self.layerTab2=self.acTab2:init(self.layerNum)
                    self.bgLayer:addChild(self.layerTab2)
                    self:refresh(1)
                end
                
            end
            socketHelper:activityJunshijiangtanGetanklist(getRanklist)
        end
        if self.layerTab1 then
            self.layerTab1:setPosition(ccp(999333,0))
            self.layerTab1:setVisible(false)
        end
        if self.layerTab2 then            
            local function getRanklist(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.junshijiangtan and sData.data.junshijiangtan.clientReward then
                        acJunshijiangtanVoApi:setRanklist(sData.data.junshijiangtan.clientReward)
                    end
                    if sData and sData.data and sData.data.junshijiangtan then
                        acJunshijiangtanVoApi:setRank(sData.data.junshijiangtan.rank)
                    end
                    self.layerTab2:setPosition(ccp(0,0))
                    self.layerTab2:setVisible(true)
                    self:refresh(1)
                end
                
            end
            socketHelper:activityJunshijiangtanGetanklist(getRanklist)
        end
    end
end

function acJunshijiangtanDialog:tick()
    local vo=acJunshijiangtanVoApi:getAcVo()
    if activityVoApi:isStart(vo) == false then -- 活动突然结束了并且当前板子还打开着，就要关闭板子
        if self then
            self:close()
            do return end
        end
    end

    local isSearchToday=acJunshijiangtanVoApi:isSearchToday()
    local acIsStop=acJunshijiangtanVoApi:acIsStop()

    if self.isStop~=acIsStop or self.isToday~=isSearchToday then
        self:refresh(1)
        self:refresh(2)
        self.isStop=acIsStop
        self.isToday=isSearchToday
    end
    
    if self and self.acTab1 and self.acTab1.tick then
        self.acTab1:tick()
    end
end
function acJunshijiangtanDialog:refresh( tab )
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
function acJunshijiangtanDialog:dispose()
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

