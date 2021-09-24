serverWarLocalDialogTab2={}

function serverWarLocalDialogTab2:new(isSingle)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.cellHeight=1200
    self.descColorList={}
    self.descLbList={}
    self.isSingle=isSingle
    -- self.officeStatus=0

    return nc
end

function serverWarLocalDialogTab2:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    -- 需要修改 
     require "luascript/script/config/gameconfig/localWar/localWarMapCfg"
    -- localWarVoApi:updateOffice()
    self:initTableView()
    return self.bgLayer
end

function serverWarLocalDialogTab2:initTableView()

    local descList={getlocal("local_war_stage_0"),getlocal("serverWarLocal_help_content0",{serverWarLocalVoApi:getThisServersTeamNum()}),getlocal("allianceWar_sign"),getlocal("serverWarLocal_help_content1",{serverWarLocalCfg.minRegistrationFee}),getlocal("serverWarLocal_help_content12"),getlocal("serverWarLocal_eligibility"),getlocal("serverWarLocal_help_content5"),getlocal("serverWarLocal_help_singleRank_title"),getlocal("serverWarLocal_help_content6",{serverWarLocalCfg.winPointMax,serverWarLocalCfg.maxBattleTime/60}),getlocal("local_war_help_title9"),getlocal("serverWarLocal_help_content7"),getlocal("serverWarLocal_against_rank_tab2"),getlocal("serverWarLocal_help_content8"),getlocal("serverwar_troops"),getlocal("serverWarLocal_help_content9"),getlocal("serverWarLocal_help_content10",{serverWarLocalCfg.tankeTransRate}),getlocal("serverWarLocal_help_content11"),getlocal("serverWarLocal_help_stronghold_title"),getlocal("serverWarLocal_help_content12"),getlocal("serverWarLocal_help_battletime_title"),getlocal("serverWarLocal_help_content13",{serverWarLocalCfg.cdTime}),getlocal("serverWarLocal_help_assaultTask_title"),getlocal("serverWarLocal_help_content14"),getlocal("serverWarLocal_help_continueDie_title"),getlocal("serverWarLocal_help_content15")} 
    self.descColorList={G_ColorGreen,nil,G_ColorGreen,nil,G_ColorRed,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorRed,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil}
    self.descLbList={}
    for k,v in pairs(descList) do
        local lbSize=25
        if self.descColorList[k]==G_ColorGreen then
            lbSize=30
        end
        local lb=GetTTFLabelWrap(v,lbSize,CCSizeMake(G_VisibleSizeWidth - 60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.descLbList[k]=lb
    end

    local tvSize
    local iphoneXH = 80
    if self.isSingle then
        tvSize=CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-180)
    else
        tvSize=CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-180-90)
    end
    if G_getIphoneType() == G_iphoneX then
        iphoneXH = 15
        tvSize.height = tvSize.height + 73
    end
    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,tvSize,nil)
    self.bgLayer:addChild(self.tv)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,iphoneXH))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(80)
end

function serverWarLocalDialogTab2:eventHandler(handler,fn,idx,cel)
     if fn=="numberOfCellsInTableView" then
        return #self.descLbList
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth - 60,self.descLbList[idx + 1]:getContentSize().height + 10)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        cell:addChild(self.descLbList[idx + 1])
        self.descLbList[idx + 1]:setAnchorPoint(ccp(0,0.5))
        self.descLbList[idx + 1]:setPosition(0,(self.descLbList[idx + 1]:getContentSize().height + 10)/2)
        if(self.descColorList[idx + 1])then
            self.descLbList[idx + 1]:setColor(self.descColorList[idx + 1])
        end
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function serverWarLocalDialogTab2:refresh()

end

function serverWarLocalDialogTab2:tick()
end

function serverWarLocalDialogTab2:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.descColorList={}
    self.descLbList={}
end
