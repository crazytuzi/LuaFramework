require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamRecordDialogTab1"
require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamRecordDialogTab2"
require "luascript/script/game/scene/gamedialog/serverWarTeam/serverWarTeamRecordDialogTab3"
serverWarTeamRecordDialog=commonDialog:new()

function serverWarTeamRecordDialog:new(layerNum,roundIndex,battleID,isBattle)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    -- self.layerNum=layerNum
    
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.playerTab1=nil
    self.playerTab2=nil
    self.playerTab3=nil

    self.totalNumLb1=nil
    self.totalNumLb2=nil
    self.statsBtn=nil

    self.roundIndex=roundIndex
    self.battleID=battleID
    self.isBattle=isBattle

    return nc
end

--设置或修改每个Tab页签
function serverWarTeamRecordDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if SizeOfTable(self.allTabs)==2 then
             if index==0 then
                 tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
             elseif index==1 then
                 tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+24+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
             end
         elseif SizeOfTable(self.allTabs)==3 then
             if index==0 then
                 tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+20,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
             elseif index==1 then
                 tabBtnItem:setPosition(tabBtnItem:getContentSize().width/2+23+tabBtnItem:getContentSize().width,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
             elseif index==2 then
                 tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
             end
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end

end

function serverWarTeamRecordDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==0 or self.selectedTabIndex==2) then
            self.topforbidSp:setPosition(ccp(0,G_VisibleSize.height-275))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 275))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100-65))
        elseif (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,G_VisibleSize.height-380))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 380))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100-65))
        end
    end
end

function serverWarTeamRecordDialog:initTableView()
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

    -- G_AllianceWarDialogTb["serverWarTeamRecordDialog"]=self
end

function serverWarTeamRecordDialog:initTabLayer()
    local capInSet=CCRect(20, 20, 10, 10)
    local function touch()
    end

    -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    local lbTextSize = 22
    if G_getCurChoseLanguage()=="pt" then
        lbTextSize = 18
    end

    local battleVo=serverWarTeamVoApi:getBattleVoByID(self.roundIndex,self.battleID)
    local alliance1,alliance2=serverWarTeamVoApi:getRedAndBlueAlliance(battleVo)
    local allianceName1=""
    local allianceName2=""
    if alliance1 then
        allianceName1=alliance1.name
    end
    if alliance2 then
        allianceName2=alliance2.name
    end

    local redDestroy=serverWarTeamVoApi:getRedDestroy(self.roundIndex,self.battleID) or 0
    local blueDestroy=serverWarTeamVoApi:getBlueDestroy(self.roundIndex,self.battleID) or 0
    self.totalNumLb1 = GetTTFLabelWrap(getlocal("serverwarteam_alliance_destroy_total",{allianceName1,redDestroy}),lbTextSize,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    self.totalNumLb1:setAnchorPoint(ccp(0,0.5));
    self.totalNumLb1:setPosition(ccp(30,self.bgLayer:getContentSize().height-195));
    self.bgLayer:addChild(self.totalNumLb1,2);

    self.totalNumLb2 = GetTTFLabelWrap(getlocal("serverwarteam_alliance_destroy_total",{allianceName2,blueDestroy}),lbTextSize,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    self.totalNumLb2:setAnchorPoint(ccp(0,0.5));
    self.totalNumLb2:setPosition(ccp(30,self.bgLayer:getContentSize().height-240));
    self.bgLayer:addChild(self.totalNumLb2,2);

    self:resetForbidLayer()
    self:doUserHandler()
end

function serverWarTeamRecordDialog:getDataByType(type)
    if type==nil then
        type=0
    end 
    -- local function getbattlelogCallback(fn,data)
    --     -- local ret,sData=base:checkServerData(data)
    --     -- if ret==true then
    --     --     if sData.data and sData.data.ulog then
    --     --         serverWarTeamVoApi:formatRecordData(sData.data.ulog)
    --             serverWarTeamVoApi:formatRecordData({})
    --             if self and self.bgLayer then
    --                 self:initTabLayer()
    --                 self:switchTag(type)
    --             end
    --     --     end
    --     -- end
    -- end
    -- local recordTab=serverWarTeamVoApi:getRecordTab()
    -- if type==0 and (recordTab==nil or SizeOfTable(recordTab)==0) then
    --     -- local selfAlliance = allianceVoApi:getSelfAlliance()
    --     -- local aid=selfAlliance.aid
    --     -- socketHelper:allianceGetbattlelog(aid,getbattlelogCallback)
    --     getbattlelogCallback()
    -- else
        self:switchTag(type)
    -- end
end

function serverWarTeamRecordDialog:tabClick(idx,isEffect)
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

function serverWarTeamRecordDialog:switchTag(idx)
    if idx==0 then
        if self.playerTab1==nil then
            self.playerTab1=serverWarTeamRecordDialogTab1:new()
            self.layerTab1=self.playerTab1:init(self.layerNum,self,self.roundIndex,self.battleID,self.isBattle)
            self.bgLayer:addChild(self.layerTab1)
            self.layerTab1:setPosition(ccp(0,0))
            self.layerTab1:setVisible(true)
        else
            self.layerTab1:setVisible(true)
            self.layerTab1:setPosition(ccp(0,0))
        end

        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(10000,0))
        end
        if self.layerTab3 then
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(10000,0))
        end
    elseif idx==1 then
        if self.playerTab2==nil then
            self.playerTab2=serverWarTeamRecordDialogTab2:new()
            self.layerTab2=self.playerTab2:init(self.layerNum,self,self.roundIndex,self.battleID,self.isBattle)
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
        if self.layerTab3 then
            self.layerTab3:setVisible(false)
            self.layerTab3:setPosition(ccp(10000,0))
        end
    elseif idx==2 then
        if self.playerTab3==nil then
            self.playerTab3=serverWarTeamRecordDialogTab3:new()
            self.layerTab3=self.playerTab3:init(self.layerNum,self,self.roundIndex,self.battleID,self.isBattle)
            self.bgLayer:addChild(self.layerTab3)
            self.layerTab3:setPosition(ccp(0,0))
            self.layerTab3:setVisible(true)
        else
            self.layerTab3:setVisible(true)
            self.layerTab3:setPosition(ccp(0,0))
        end

        if self.layerTab1 then
            self.layerTab1:setVisible(false)
            self.layerTab1:setPosition(ccp(10000,0))
        end
        if self.layerTab2 then
            self.layerTab2:setVisible(false)
            self.layerTab2:setPosition(ccp(10000,0))
        end
    end
    self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function serverWarTeamRecordDialog:doUserHandler()
    local battleVo=serverWarTeamVoApi:getBattleVoByID(self.roundIndex,self.battleID)
    local alliance1,alliance2=serverWarTeamVoApi:getRedAndBlueAlliance(battleVo)
    local allianceName1=""
    local allianceName2=""
    if alliance1 then
        allianceName1=alliance1.name
    end
    if alliance2 then
        allianceName2=alliance2.name
    end
    -- if serverWarTeamVoApi:checkStatus()>=30 then
        local redDestroy=serverWarTeamVoApi:getRedDestroy(self.roundIndex,self.battleID) or 0
        local blueDestroy=serverWarTeamVoApi:getBlueDestroy(self.roundIndex,self.battleID) or 0
        if self and self.totalNumLb1 then
            self.totalNumLb1:setString(getlocal("serverwarteam_alliance_destroy_total",{allianceName1,redDestroy}))
        end
        if self and self.totalNumLb2 then
            self.totalNumLb2:setString(getlocal("serverwarteam_alliance_destroy_total",{allianceName2,blueDestroy}))
        end
    -- else
    --     if self and self.totalNumLb1 then
    --         self.totalNumLb1:setString(getlocal("serverwarteam_alliance_destroy_total",{allianceName1,getlocal("alliance_war_end_show")}))
    --     end
    --     if self and self.totalNumLb2 then
    --         self.totalNumLb2:setString(getlocal("serverwarteam_alliance_destroy_total",{allianceName2,getlocal("alliance_war_end_show")}))
    --     end
    -- end
end

function serverWarTeamRecordDialog:updateDestroyNum()
    -- local battleVo=serverWarTeamVoApi:getBattleVoByID(self.roundIndex,self.battleID)
    -- local alliance1,alliance2=serverWarTeamVoApi:getRedAndBlueAlliance(battleVo)
    -- local allianceName1=""
    -- local allianceName2=""
    -- if alliance1 then
    --     allianceName1=alliance1.name
    -- end
    -- if alliance2 then
    --     allianceName2=alliance2.name
    -- end
    -- if serverWarTeamVoApi:checkStatus()>=30 then
    --     -- local redDestroy=serverWarTeamVoApi:getRedDestroy(self.roundIndex,self.battleID) or 0
    --     -- local blueDestroy=serverWarTeamVoApi:getBlueDestroy(self.roundIndex,self.battleID) or 0
    --     -- if redDestroy==0 and blueDestroy==0 then
    --     --     local function getbattlelogCallback(fn,data)
    --     --         local ret,sData=base:checkServerData(data)
    --     --         if ret==true then
    --     --             if sData.data and sData.data.alog then
    --     --                 serverWarTeamVoApi:formatResultData(sData.data.alog)
    --                     -- local allianceName1,allianceName2=serverWarTeamVoApi:getBattleAName()
    --                     local redDestroy1=serverWarTeamVoApi.redDestroy or 0
    --                     local blueDestroy1=serverWarTeamVoApi.blueDestroy or 0
    --                     if self and self.totalNumLb1 then
    --                         self.totalNumLb1:setString(getlocal("serverwarteam_alliance_destroy_total",{allianceName1,redDestroy1}))
    --                     end
    --                     if self and self.totalNumLb2 then
    --                         self.totalNumLb2:setString(getlocal("serverwarteam_alliance_destroy_total",{allianceName2,blueDestroy1}))
    --                     end
    --     --             end
    --     --         end
    --     --     end
    --     --     local type=2
    --     --     local selfAlliance = allianceVoApi:getSelfAlliance()
    --     --     local aid=selfAlliance.aid
    --     --     local uid=playerVoApi:getUid()
    --     --     local warid=allianceWarVoApi.warid
    --     --     print("warid",warid)
    --     --     if warid and warid>0 then
    --     --         socketHelper:allianceGetbattlelog(warid,type,aid,uid,nil,nil,getbattlelogCallback)
    --     --     end
    --     -- end
    -- else
    --     -- local allianceName1,allianceName2=serverWarTeamVoApi:getBattleAName()
    --     if self and self.totalNumLb1 then
    --         self.totalNumLb1:setString(getlocal("serverwarteam_alliance_destroy_total",{allianceName1,getlocal("alliance_war_end_show")}))
    --     end
    --     if self and self.totalNumLb2 then
    --         self.totalNumLb2:setString(getlocal("serverwarteam_alliance_destroy_total",{allianceName2,getlocal("alliance_war_end_show")}))
    --     end
    -- end
end

--点击了cell或cell上某个按钮
function serverWarTeamRecordDialog:cellClick(idx)

end

function serverWarTeamRecordDialog:tick()
    if self.selectedTabIndex==0 and self.playerTab1~=nil then
        self.playerTab1:tick()
    elseif self.selectedTabIndex==1 and self.playerTab2~=nil then
        self.playerTab2:tick()
    end

    self:doUserHandler()
end

function serverWarTeamRecordDialog:dispose()
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.playerTab1=nil
    self.playerTab2=nil
    self.playerTab3=nil

    self.totalNumLb1=nil
    self.totalNumLb2=nil
    self.statsBtn=nil
    -- G_AllianceWarDialogTb["serverWarTeamRecordDialog"]=nil
    if self.isBattle and self.isBattle==1 then
        serverWarTeamVoApi:clearRecord()
        serverWarTeamVoApi:clearPRecord()
        self.isBattle=nil
    end
    self.roundIndex=nil
    self.battleID=nil
    self=nil
end




