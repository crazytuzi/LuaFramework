localWarHelpDialog=commonDialog:new()

function localWarHelpDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.descColorList={}
    self.descLbList={}

    return nc
end

function localWarHelpDialog:initTableView()
    self.panelLineBg:setAnchorPoint(ccp(0.5,0))
    self.panelLineBg:setContentSize(CCSizeMake(600,G_VisibleSize.height-100))
    self.panelLineBg:setPosition(ccp(G_VisibleSizeWidth/2,20))

    local battleHour=math.floor(localWarCfg.maxBattleTime/3600)
    local battleMin=localWarCfg.maxBattleTime%3600
    local battleSt=localWarCfg.startWarTime[1]..":"..localWarCfg.startWarTime[2]
    local battleEt=(localWarCfg.startWarTime[1]+battleHour)..":"..(localWarCfg.startWarTime[2]+battleMin)
    local battleTimeStr=getlocal("local_war_time",{battleSt,battleEt})

    local content7Params={}
    local cityCfg=localWarMapCfg.cityCfg
    for k,v in pairs(cityCfg["a6"].buff) do
        table.insert(content7Params,v*100)
    end
    for k,v in pairs(cityCfg["a7"].buff) do
        table.insert(content7Params,v*100)
    end
    for k,v in pairs(cityCfg["a10"].buff) do
        table.insert(content7Params,v*100)
    end
    for k,v in pairs(cityCfg["a11"].buff) do
        table.insert(content7Params,v*100)
    end
    table.insert(content7Params,localWarCfg.baseAttackCD)
    table.insert(content7Params,localWarCfg.baseAttack[1])
    for k,v in pairs(cityCfg["a2"].buff) do
        table.insert(content7Params,v*100)
    end
    for k,v in pairs(cityCfg["a3"].buff) do
        table.insert(content7Params,v*100)
    end
    
    local content8=""
    for k,v in pairs(localWarCfg.jobs) do
        if v and v.buff then
            local titleStr=getlocal(v.title)..":"
            local buffStr=""
            for m,n in pairs(v.buff) do
                if n then
                    local bStr=localWarVoApi:getBuffStr(n)
                    if buffStr=="" then
                        buffStr=bStr
                    else
                        buffStr=buffStr..";\n"..bStr
                    end
                end
            end
            if content8=="" then
                content8=titleStr.."\n"..buffStr
            else
                content8=content8..";\n"..titleStr.."\n"..buffStr
            end
        end
    end

    local descList={getlocal("local_war_help_content0"),getlocal("local_war_help_title1"),getlocal("local_war_help_content1",{battleTimeStr,localWarCfg.buffTime}),getlocal("local_war_help_title2"),getlocal("local_war_help_content2",{localWarCfg.minRegistrationFee,localWarCfg.signupBattleNum}),getlocal("local_war_help_title3"),getlocal("local_war_help_content3",{localWarCfg.signupBattleNum}),getlocal("local_war_help_title4"),getlocal("local_war_help_content4",{localWarCfg.cdTime,localWarCfg.battleQueue,localWarCfg.battleQueue}),getlocal("local_war_help_title5"),getlocal("local_war_help_content5"),getlocal("local_war_help_content5_1",{localWarCfg.tankeTransRate}),getlocal("local_war_help_title6"),getlocal("local_war_help_content6"),getlocal("local_war_help_title7"),getlocal("local_war_help_content7",content7Params),getlocal("local_war_help_content7_1"),getlocal("local_war_help_title10"),getlocal("local_war_help_content10",{localWarCfg.attackBase}),getlocal("local_war_help_title11"),getlocal("local_war_help_content11"),getlocal("local_war_help_title8"),content8,getlocal("local_war_help_title9"),getlocal("local_war_help_content9")}
    self.descColorList={nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorRed,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorRed,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil,G_ColorGreen,nil}
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


function localWarHelpDialog:eventHandler(handler,fn,idx,cel)
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

function localWarHelpDialog:dispose()
    self.descColorList={}
    self.descLbList={}
end
