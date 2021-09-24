platWarHelpDialog=commonDialog:new()

function platWarHelpDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.descColorList={}
    self.descLbList={}

    return nc
end

function platWarHelpDialog:initTableView()
    require "luascript/script/config/gameconfig/localWar/localWarMapCfg"
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    local descList={getlocal("plat_war_help_content0"),getlocal("plat_war_help_title1"),getlocal("plat_war_help_content1"),getlocal("plat_war_help_title2"),getlocal("plat_war_help_content2"),getlocal("plat_war_help_title3"),getlocal("plat_war_help_content3"),getlocal("plat_war_help_title4"),getlocal("plat_war_help_content4"),getlocal("plat_war_help_title5"),getlocal("plat_war_help_content5"),getlocal("plat_war_help_title6"),getlocal("plat_war_help_content6"),getlocal("plat_war_help_title7"),getlocal("plat_war_help_content7"),getlocal("plat_war_help_title8"),getlocal("plat_war_help_content8"),getlocal("plat_war_help_title9"),getlocal("plat_war_help_content9")}
    self.descColorList={nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil}
    self.descLbList={}
    for k,v in pairs(descList) do
        local lbSize=25
        if self.descColorList[k]==G_ColorGreen then
            lbSize=30
        end
        local lb=GetTTFLabelWrap(v,lbSize,CCSizeMake(G_VisibleSizeWidth - 60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        self.descLbList[k]=lb
    end

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-180),nil)
    self.bgLayer:addChild(self.tv)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,80))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(80)
end


function platWarHelpDialog:eventHandler(handler,fn,idx,cel)
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

function platWarHelpDialog:dispose()
    self.descColorList={}
    self.descLbList={}
end
