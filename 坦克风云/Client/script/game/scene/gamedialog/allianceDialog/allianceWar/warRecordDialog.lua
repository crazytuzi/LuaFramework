require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/warRecordTab1Dialog"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceWar/warRecordTab2Dialog"
warRecordDialog=commonDialog:new()

function warRecordDialog:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    -- self.layerNum=layerNum
    
    self.layerTab1=nil
    self.layerTab2=nil
    
    self.playerTab1=nil
    self.playerTab2=nil

    self.tv1=nil
    self.tv2=nil

    self.redLb=nil
    self.blueLb=nil
    self.statsBtn=nil

    return nc
end

--设置或修改每个Tab页签
function warRecordDialog:resetTab()
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

end

function warRecordDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==0) then
            self.topforbidSp:setPosition(ccp(0,G_VisibleSize.height-305-70))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 305+70))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100-65))
        elseif (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,G_VisibleSize.height-380))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 380))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100-65))
        end
    end
end

function warRecordDialog:initTableView()
    local function callBack(...)
       -- return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    -- local height=0;
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    -- self.tv:setPosition(ccp(30,30))
    -- self.bgLayer:addChild(self.tv)
    -- self.tv:setVisible(false)
    -- self.tv:setMaxDisToBottomOrTop(120)

    self:initTabLayer()
    self:tabClick(0)

    G_AllianceWarDialogTb["warRecordDialog"]=self
end

function warRecordDialog:initTabLayer()
    local capInSet=CCRect(20, 20, 10, 10)
    local function touch()
    end

    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- self.redLb = GetTTFLabelWrap(str,22,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    local lbTextSize = 22
    if G_getCurChoseLanguage()=="pt" then
        lbTextSize = 18
    end
    self.redLb = GetTTFLabelWrap(getlocal("alliance_war_red_total",{allianceWarRecordVoApi.redDestroy}),lbTextSize,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    self.redLb:setAnchorPoint(ccp(0,0.5));
    self.redLb:setPosition(ccp(30,self.bgLayer:getContentSize().height-195));
    self.bgLayer:addChild(self.redLb,2);

    -- self.blueLb = GetTTFLabelWrap(str,22,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    self.blueLb = GetTTFLabelWrap(getlocal("alliance_war_blue_total",{allianceWarRecordVoApi.blueDestroy}),lbTextSize,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    self.blueLb:setAnchorPoint(ccp(0,0.5));
    self.blueLb:setPosition(ccp(30,self.bgLayer:getContentSize().height-240));
    self.bgLayer:addChild(self.blueLb,2);

    -- self.playerTab1=warRecordTab1Dialog:new()
    -- self.layerTab1=self.playerTab1:init(self.layerNum,self)
    -- self.bgLayer:addChild(self.layerTab1)
    -- self.layerTab1:setPosition(ccp(0,0))
    -- self.layerTab1:setVisible(true)

    -- self.playerTab2=warRecordTab2Dialog:new()
    -- self.layerTab2=self.playerTab2:init(self.layerNum,self)
    -- self.bgLayer:addChild(self.layerTab2)
    -- self.layerTab2:setPosition(ccp(10000,0))
    -- self.layerTab2:setVisible(false)

    self:resetForbidLayer()
    self:doUserHandler()
end

function warRecordDialog:getDataByType(type)
    -- if type==nil then
    --     type=0
    -- end 
    -- local function getbattlelogCallback(fn,data)
    --     local ret,sData=base:checkServerData(data)
    --     if ret==true then
    --         if sData.data and sData.data.ulog then
    --             allianceWarRecordVoApi:formatRecordData(sData.data.ulog)
    --             if self and self.bgLayer then
    --                 self:initTabLayer()
    --                 self:switchTag(type)
    --             end
    --         end
    --     end
    -- end
    -- local personRecordTab=allianceWarRecordVoApi:getPersonRecordTab()
    -- if type==0 and (personRecordTab==nil or SizeOfTable(personRecordTab)>0) then
    --     local selfAlliance = allianceVoApi:getSelfAlliance()
    --     local aid=selfAlliance.aid
    --     socketHelper:allianceGetbattlelog(aid,getbattlelogCallback)
    -- else
        self:switchTag(type)
    -- end
end

function warRecordDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
        
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
            self:tabClickColor(idx)
            self:getDataByType(idx)
        else
            v:setEnabled(true)
        end
    end
    
    
end

function warRecordDialog:switchTag(idx)
    if idx==0 then
        if self.playerTab1==nil then
            self.playerTab1=warRecordTab1Dialog:new()
            self.layerTab1=self.playerTab1:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab1)
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
        else
            self.layerTab1:setVisible(true)
            self.layerTab1:setPosition(ccp(0,0))
        end

        -- if self.layerTab1 then
        --     self.layerTab1:setVisible(true)
        --     self.layerTab1:setPosition(ccp(0,0))
        -- end
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(99930,0))
        end
    elseif idx==1 then
        if self.playerTab2==nil then
            self.playerTab2=warRecordTab2Dialog:new()
            self.layerTab2=self.playerTab2:init(self.layerNum,self)
            self.bgLayer:addChild(self.layerTab2)
            self.layerTab2:setPosition(ccp(0,0))
            self.layerTab2:setVisible(true)
        else
            self.layerTab2:setVisible(true)
            self.layerTab2:setPosition(ccp(0,0))
        end

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end
        -- if self.layerTab2 then
        --     self.layerTab2:setVisible(true)
        --     self.layerTab2:setPosition(ccp(0,0))
        -- end
    end
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function warRecordDialog:doUserHandler()
    if allianceWarVoApi:checkInWarOrOver()==true then
        local redDestroy=allianceWarRecordVoApi.redDestroy or 0
        local blueDestroy=allianceWarRecordVoApi.blueDestroy or 0
        if self and self.redLb then
            self.redLb:setString(getlocal("alliance_war_red_total",{redDestroy}))
        end
        if self and self.blueLb then
            self.blueLb:setString(getlocal("alliance_war_blue_total",{blueDestroy}))
        end
    else
        if self and self.redLb then
            self.redLb:setString(getlocal("alliance_war_red_total",{getlocal("alliance_war_end_show")}))
        end
        if self and self.blueLb then
            self.blueLb:setString(getlocal("alliance_war_blue_total",{getlocal("alliance_war_end_show")}))
        end
    end
end

function warRecordDialog:updateDestroyNum()
    if allianceWarVoApi:checkInWarOrOver()==true then
        local redDestroy=allianceWarRecordVoApi.redDestroy or 0
        local blueDestroy=allianceWarRecordVoApi.blueDestroy or 0
        if redDestroy==0 and blueDestroy==0 then
            local function getbattlelogCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData.data and sData.data.alog then
                        allianceWarRecordVoApi:formatResultData(sData.data.alog)
                        -- if (G_AllianceWarDialogTb["allianceWarDialog"] or G_AllianceWarDialogTb["allianceWarOverviewDialog"]) and battleScene.isBattleing==false then
                        --     local isVictory=allianceWarRecordVoApi:isVictory()
                        --     local params={}
                        --     local function callback(tag,object)
                        --     allianceSmallDialog:showWarResultDialog("PanelHeaderPopup.png",CCSizeMake(600,600),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),isVictory,callback,true,7,params)
                        -- end
                        local redDestroy1=allianceWarRecordVoApi.redDestroy or 0
                        local blueDestroy1=allianceWarRecordVoApi.blueDestroy or 0
                        if self and self.redLb then
                            self.redLb:setString(getlocal("alliance_war_red_total",{redDestroy1}))
                        end
                        if self and self.blueLb then
                            self.blueLb:setString(getlocal("alliance_war_blue_total",{blueDestroy1}))
                        end
                    end
                end
            end
            local type=2
            local selfAlliance = allianceVoApi:getSelfAlliance()
            local aid=selfAlliance.aid
            local uid=playerVoApi:getUid()
            local warid=allianceWarVoApi.warid
            print("warid",warid)
            if warid and warid>0 then
                socketHelper:allianceGetbattlelog(warid,type,aid,uid,nil,nil,getbattlelogCallback)
            end
        end
    else
        if self and self.redLb then
            self.redLb:setString(getlocal("alliance_war_red_total",{getlocal("alliance_war_end_show")}))
        end
        if self and self.blueLb then
            self.blueLb:setString(getlocal("alliance_war_blue_total",{getlocal("alliance_war_end_show")}))
        end
    end
end

--点击了cell或cell上某个按钮
function warRecordDialog:cellClick(idx)

end

function warRecordDialog:tick()
    if self.selectedTabIndex==0 and self.playerTab1~=nil then
        self.playerTab1:tick()
    elseif self.selectedTabIndex==1 and self.playerTab2~=nil then
        self.playerTab2:tick()
    end

    self:doUserHandler()
end

function warRecordDialog:dispose()
    self.layerTab1=nil
    self.layerTab2=nil
    
    self.playerTab1=nil
    self.playerTab2=nil

    self.tv1=nil
    self.tv2=nil

    self.redLb=nil
    self.blueLb=nil
    self.statsBtn=nil
    G_AllianceWarDialogTb["warRecordDialog"]=nil

    self=nil
end




