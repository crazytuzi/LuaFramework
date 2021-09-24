require "luascript/script/game/scene/gamedialog/Boss/BossBattleScene"
require "luascript/script/game/scene/gamedialog/Boss/BossBattleDialogTab1"
require "luascript/script/game/scene/gamedialog/Boss/BossBattleDialogTab2"
require "luascript/script/game/scene/gamedialog/Boss/BossBattleDialogTab3"
BossBattleDialog=commonDialog:new()

function BossBattleDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.bossbattleTab1=nil
    self.bossbattleTab2=nil
    self.bossbattleTab3=nil

    self.dataNeedRefresh=nil


    spriteController:addPlist("public/hydraBuf_Image.plist")
    spriteController:addTexture("public/hydraBuf_Image.png")
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("allianceWar/warMap.plist")
   
    return nc
end

function BossBattleDialog:resetTab()
    self.panelLineBg:setVisible(false)
    self.panelTopLine:setVisible(false)
    self.panelShadeBg:setVisible(true)
    local topBorder=CCSprite:createWithSpriteFrameName("newTopBorder.png")
    topBorder:setScaleX(G_VisibleSizeWidth/topBorder:getContentSize().width)
    topBorder:setScaleY(4/topBorder:getContentSize().height)
    topBorder:setAnchorPoint(ccp(0,1))
    topBorder:setPosition(0,G_VisibleSizeHeight - 158)
    self.bgLayer:addChild(topBorder)


    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v

         if index==0 then
         tabBtnItem:setPosition(119,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         elseif index==1 then
         tabBtnItem:setPosition(320,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)

         elseif index==2 then
         tabBtnItem:setPosition(521,self.bgSize.height-tabBtnItem:getContentSize().height/2-80)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end

    self:tabClick(0,false)
end

function BossBattleDialog:resetForbidLayer()
    if self and self.selectedTabIndex and self.topforbidSp and self.bottomforbidSp then
        if (self.selectedTabIndex==1) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-175+70))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 175+70))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 165))
        elseif (self.selectedTabIndex==0) then
            self.topforbidSp:setContentSize(CCSizeMake(0, 0))
            self.bottomforbidSp:setContentSize(CCSizeMake(0, 0))
        elseif (self.selectedTabIndex==2) then
            self.topforbidSp:setPosition(ccp(0,self.bgLayer:getContentSize().height-210))
            self.topforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 210))
            self.bottomforbidSp:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width, 130))
        end
    end
end

function BossBattleDialog:initTableView()
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    local function callBack(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-10,self.bgLayer:getContentSize().height-85-120),nil)
    -- self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20)
    self.tv:setPosition(ccp(30,165))
    -- self.tv:setPosition(ccp(30,130))
    -- self.bgLayer:addChild(self.tv)

    BossBattleVoApi.isInDialog = true
end

function BossBattleDialog:tabClick(idx,isEffect)
    if isEffect==false then
    else
        PlayEffect(audioCfg.mouseClick)
    end
    for k,v in pairs(self.allTabs) do
        if v:getTag()==idx then
            v:setEnabled(false)
            self:getDataByType(idx+1)
            self.selectedTabIndex=idx
        else
            v:setEnabled(true)
        end
    end
    --self:switchTab()
end
function BossBattleDialog:hideTabAll()
    for i=1,3 do
        if self then
            if (self["layerTab"..i]~=nil) then
                self["layerTab"..i]:setPosition(ccp(999333,0))
                self["layerTab"..i]:setVisible(false)
            end
        end
    end
end
function BossBattleDialog:getDataByType(type)
    self:hideTabAll()
    if type==nil then
        type=1
    end 
    if type==2 then
        if BossBattleVoApi:getFlag()==-1 then
            local function ListCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data then
                        if self and self.bgLayer then
                            if sData.data.ranklist then
                                BossBattleVoApi:setRankList(sData.data.ranklist,sData.data.kill)
                            end
                            BossBattleVoApi:setFlag(1)
                            self:tabClick(type-1,false)
                        end
                    end
                end
            end
            socketHelper:BossBattleRank(ListCallback)
        else
            for k,v in pairs(self.allTabs) do
                if v:getTag()==type-1 then
                    v:setEnabled(false)
                    self.selectedTabIndex=type-1
                else
                    v:setEnabled(true)
                end
            end
            self:switchTab(type)
        end
    else
        BossBattleVoApi:setFlag(-1)
        if self.dataNeedRefresh==false or self.dataNeedRefresh==nil  then
            local function onRequestEnd(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    if sData and sData.data and sData.data.worldboss then
                        if self and self.bgLayer then
                            self.dataNeedRefresh=true
                            BossBattleVoApi:onRefreshData(sData.data.worldboss)
                            self:tabClick(type-1,false)
                        end
                    end
                end
            end
            socketHelper:BossBattleInfo(onRequestEnd)
        else
            for k,v in pairs(self.allTabs) do
                if v:getTag()==type-1 then
                    v:setEnabled(false)
                    self.selectedTabIndex=type-1
                else
                    v:setEnabled(true)
                end
            end
            self:switchTab(type)
        end
    end
end

function BossBattleDialog:switchTab(type)
    if type==nil then
        type=1
    end
   	if self["bossbattleTab"..type]==nil then
   		local tab
   		if(type==1)then
	   		tab=BossBattleDialogTab1:new()
	   	elseif(type==2)then
	   		tab=BossBattleDialogTab2:new()
	   	else
	   		tab=BossBattleDialogTab3:new()
	   	end
	   	self["bossbattleTab"..type]=tab
	   	self["layerTab"..type]=tab:init(self.layerNum,self)
	   	self.bgLayer:addChild(self["layerTab"..type])
   	end
    for i=1,3 do
    	if(i==type)then
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(0,0))
    			self["layerTab"..i]:setVisible(true)
                if i==2 then
                    self["bossbattleTab"..type]:refresh()
                end
                if i==3 then
                    self["bossbattleTab"..type]:clearTouchSp()
                end
    		end
    	else
    		if(self["layerTab"..i]~=nil)then
    			self["layerTab"..i]:setPosition(ccp(999333,0))
    			self["layerTab"..i]:setVisible(false)
    		end
    	end
    end
end


function BossBattleDialog:tick()
    if self and self.bgLayer then
        local state = BossBattleVoApi:getBossState()
        if state==1 then
            for k,v in pairs(G_SmallDialogDialogTb) do
                if v and v.close then
                    v:close()
                end
            end
            self:close()
            do return end
        end
        if self.layerTab1 then
            self["bossbattleTab1"]:tick()
        end
    end
end

function BossBattleDialog:dispose()
    --CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("allianceWar/warMap.plist")
    --CCTextureCache:sharedTextureCache():removeTextureForKey("allianceWar/warMap.pvr.ccz")

    if self.bossbattleTab1 then
        self.bossbattleTab1:dispose()
    end
    if self.bossbattleTab2 then
        self.bossbattleTab2:dispose()
    end
    if self.BossBattleTab3 then
        self.BossBattleTab3:dispose()
    end

    self.layerTab1=nil
    self.layerTab2=nil
    self.layerTab3=nil
    
    self.bossbattleTab1=nil
    self.bossbattleTab2=nil
    self.bossbattleTab3=nil

    self.dataNeedRefresh=nil

     self.bossState = nil
     BossBattleVoApi.isInDialog = false
end
