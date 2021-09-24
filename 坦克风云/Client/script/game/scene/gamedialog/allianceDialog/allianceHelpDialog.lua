require "luascript/script/game/scene/gamedialog/allianceDialog/allianceHelpTab1"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceHelpTab2"
require "luascript/script/game/scene/gamedialog/allianceDialog/allianceHelpTab3"
allianceHelpDialog=commonDialog:new()

function allianceHelpDialog:new(layerNum,roundIndex,battleID)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    -- self.layerNum=layerNum
    
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.tab1=nil
    self.tab2=nil
    self.tab3=nil

    self.totalNumLb1=nil
    self.totalNumLb2=nil
    self.statsBtn=nil

    self.roundIndex=roundIndex
    self.battleID=battleID

    return nc
end

--设置或修改每个Tab页签
function allianceHelpDialog:resetTab()
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if SizeOfTable(self.allTabs)==3 then
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

-- function allianceHelpDialog:resetForbidLayer()
--     if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
--         if (self.selectedTabIndex==0 or self.selectedTabIndex==2) then
--             self.topforbidSp:setPosition(ccp(0,G_VisibleSize.height-275))
--             self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 275))
--             self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100-65))
--         elseif (self.selectedTabIndex==1) then
--             self.topforbidSp:setPosition(ccp(0,G_VisibleSize.height-380))
--             self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 380))
--             self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 100-65))
--         end
--     end
-- end

function allianceHelpDialog:initTableView()

    
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

    G_AllianceWarDialogTb["allianceHelpDialog"]=self
end

function allianceHelpDialog:initTabLayer()
    -- local capInSet=CCRect(20, 20, 10, 10)
    -- local function touch()
    -- end

    -- -- local str="啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊啊"
    -- local lbTextSize = 22
    -- if G_getCurChoseLanguage()=="pt" then
    --     lbTextSize = 18
    -- end

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

    -- local redDestroy=serverWarTeamVoApi:getRedDestroy(self.roundIndex,self.battleID) or 0
    -- local blueDestroy=serverWarTeamVoApi:getBlueDestroy(self.roundIndex,self.battleID) or 0
    -- self.totalNumLb1 = GetTTFLabelWrap(getlocal("serverwarteam_alliance_destroy_total",{allianceName1,redDestroy}),lbTextSize,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    -- self.totalNumLb1:setAnchorPoint(ccp(0,0.5));
    -- self.totalNumLb1:setPosition(ccp(30,self.bgLayer:getContentSize().height-195));
    -- self.bgLayer:addChild(self.totalNumLb1,2);

    -- self.totalNumLb2 = GetTTFLabelWrap(getlocal("serverwarteam_alliance_destroy_total",{allianceName2,blueDestroy}),lbTextSize,CCSizeMake(self.bgLayer:getContentSize().width-50,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter);
    -- self.totalNumLb2:setAnchorPoint(ccp(0,0.5));
    -- self.totalNumLb2:setPosition(ccp(30,self.bgLayer:getContentSize().height-240));
    -- self.bgLayer:addChild(self.totalNumLb2,2);

    -- self:resetForbidLayer()
    -- self:doUserHandler()
end

function allianceHelpDialog:getDataByType(type)
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

function allianceHelpDialog:tabClick(idx,isEffect)
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

function allianceHelpDialog:switchTag(idx)
    if idx==0 then
        if self.tab1==nil then
            local function callback1()
                self.tab1=allianceHelpTab1:new()
                self.layerTab1=self.tab1:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab1)
                self.layerTab1:setPosition(ccp(0,0))
                self.layerTab1:setVisible(true)
            end
            allianceHelpVoApi:formatData(idx+1,callback1)
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
        if self.tab2==nil then
            local function callback2()
                self.tab2=allianceHelpTab2:new()
                self.layerTab2=self.tab2:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab2)
                self.layerTab2:setPosition(ccp(0,0))
                self.layerTab2:setVisible(true)
            end
            allianceHelpVoApi:formatData(idx+1,callback2)
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
        if self.tab3==nil then
            local function callback3()
                self.tab3=allianceHelpTab3:new()
                self.layerTab3=self.tab3:init(self.layerNum,self)
                self.bgLayer:addChild(self.layerTab3)
                self.layerTab3:setPosition(ccp(0,0))
                self.layerTab3:setVisible(true)
            end
            allianceHelpVoApi:formatData(idx+1,callback3)
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
    -- self:resetForbidLayer()
end

--用户处理特殊需求,没有可以不写此方法
function allianceHelpDialog:doUserHandler()

    if self.panelLineBg then
        self.panelLineBg:setVisible(false)
    end
      
    if self.panelTopLine then
        self.panelTopLine:setVisible(false)
    end

    local tabLine=LuaCCScale9Sprite:createWithSpriteFrameName("yh_ltzdzHelp_tabLine.png",CCRect(4,3,1,1),function()end)
    tabLine:setContentSize(CCSizeMake(G_VisibleSizeWidth,tabLine:getContentSize().height))
    tabLine:setAnchorPoint(ccp(0.5,1))
    tabLine:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-157)
    self.bgLayer:addChild(tabLine,2)


    -- 去渐变线
    local panelBg=LuaCCScale9Sprite:createWithSpriteFrameName("panelBgShade.png",CCRect(30,0,2,3),function ()end)
    panelBg:setAnchorPoint(ccp(0.5,0))
    panelBg:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight-82))
    panelBg:setPosition(G_VisibleSizeWidth/2,2)
    self.bgLayer:addChild(panelBg)

end

--点击了cell或cell上某个按钮
function allianceHelpDialog:cellClick(idx)

end

function allianceHelpDialog:tick()
    if self and self["tab"..(self.selectedTabIndex+1)] and self["tab"..(self.selectedTabIndex+1)].tick then
        self["tab"..(self.selectedTabIndex+1)]:tick()
    end
    -- self:doUserHandler()
end

function allianceHelpDialog:dispose()
    local data={key="alliance_help"}
    eventDispatcher:dispatchEvent("allianceFunction.numChanged",data)
    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.tab1=nil
    self.tab2=nil
    self.tab3=nil

    self.totalNumLb1=nil
    self.totalNumLb2=nil
    self.statsBtn=nil
    G_AllianceWarDialogTb["allianceHelpDialog"]=nil

    self.roundIndex=nil
    self.battleID=nil

    self=nil
end




