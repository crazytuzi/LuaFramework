serverWarLocalInforTab1={}

function serverWarLocalInforTab1:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    self.bgLayer=nil
    self.layerNum=nil
    self.tv=nil
    -- self.kingCity={}
    self.list={}

    return nc
end



function serverWarLocalInforTab1:updateList()
    local selfAlliance=allianceVoApi:getSelfAlliance()
    local selfID
    if selfAlliance and selfAlliance.aid then
        selfID=base.curZoneID.."-"..selfAlliance.aid
    end
    
    local troops=serverWarLocalFightVoApi:getTroops()
    local playerList={}
    for k,v in pairs(troops) do
        if(v and v.uid and v.allianceID)then
            if(playerList[v.uid]==nil)then
                playerList[v.uid]=v.allianceID
            end
        end
    end
    local battleMemNumTab={}
    for uid,allianceID in pairs(playerList) do
        if battleMemNumTab[allianceID] then
            battleMemNumTab[allianceID]=battleMemNumTab[allianceID]+1
        else
            battleMemNumTab[allianceID]=1
        end
    end
    local cityList=serverWarLocalFightVoApi:getCityList()
    local occupiedNumTab={}
    -- local occupiedBaseNumTab={}
    for k,v in pairs(cityList) do
        if v and v.allianceID then
            if occupiedNumTab[v.allianceID] then
                occupiedNumTab[v.allianceID]=occupiedNumTab[v.allianceID]+1
            else
                occupiedNumTab[v.allianceID]=1
            end
            -- if v.cfg.type==1 then
            --     if occupiedBaseNumTab[v.allianceID] then
            --         occupiedBaseNumTab[v.allianceID]=occupiedBaseNumTab[v.allianceID]+1
            --     else
            --         occupiedBaseNumTab[v.allianceID]=1
            --     end
            -- end
        end
    end

    local emptyStr=getlocal("alliance_info_content")
    -- local kingCityData=serverWarLocalFightVoApi:getCity(serverWarLocalCfg.capitalID)
    -- self.kingCity={maxHp=kingCityData.cfg.hp,hp=kingCityData.hp,name=emptyStr,leaderName=emptyStr,battleMemNum=0,occupiedNum=0,occupiedBaseNum=0}
    -- local kingAllianceData=serverWarLocalFightVoApi:getDefenderAlliance()
    -- if kingAllianceData and kingAllianceData.id then
    --     if kingAllianceData.name and kingAllianceData.name~="" then
    --         self.kingCity.name=kingAllianceData.name
    --     end
    --     if kingAllianceData.commander and kingAllianceData.commander~="" then
    --         self.kingCity.leaderName=kingAllianceData.commander
    --     end
    --     self.kingCity.battleMemNum=battleMemNumTab[kingAllianceData.id] or 0
    --     self.kingCity.occupiedNum=occupiedNumTab[kingAllianceData.id] or 0
    --     self.kingCity.occupiedBaseNum=occupiedBaseNumTab[kingAllianceData.id] or 0
    -- end

    
    self.list={}
    local allianceList=serverWarLocalFightVoApi:getAllianceList()
    local pointTb=serverWarLocalFightVoApi:getPointTb()
    for k,v in pairs(allianceList) do
        if v and v.id then
            -- if kingAllianceData and kingAllianceData.id and kingAllianceData.id==v.id then
            -- else
                local side=v.side
                local itemData={name=emptyStr,leaderName=emptyStr,battleMemNum=0,occupiedNum=0,serverName="",point=0,sortId=0,side=side}
                if v.name and v.name~="" then
                    itemData.name=v.name
                end
                if v.leader and v.leader~="" then
                    itemData.leaderName=v.leader
                end
                if battleMemNumTab[v.id] then
                    itemData.battleMemNum=battleMemNumTab[v.id]
                end
                if occupiedNumTab[v.id] then
                    itemData.occupiedNum=occupiedNumTab[v.id]
                end
                if v.serverID and v.serverID~="" then
                    itemData.serverName=GetServerNameByID(v.serverID)
                end
                if pointTb and pointTb[v.id] then
                    itemData.point=pointTb[v.id]
                end
                -- if occupiedBaseNumTab[v.id] then
                --     itemData.occupiedBaseNum=occupiedBaseNumTab[v.id]
                -- end
                -- local isDefeat=false
                -- if itemData.occupiedBaseNum==nil or itemData.occupiedBaseNum==0 then
                --     isDefeat=true
                -- end
                if side and side<=4 then
                    itemData.sortId=itemData.sortId+side
                end
                if selfID and selfID==v.id then
                    itemData.sortId=itemData.sortId-100000
                else
                    -- if isDefeat==true then
                    --     itemData.sortId=itemData.sortId+10
                    -- else
                    --     if itemData.occupiedNum then
                    --         itemData.sortId=itemData.sortId-5*itemData.occupiedNum
                    --     end
                    -- end
                    if itemData.point then
                        itemData.sortId=itemData.sortId-itemData.point
                    end
                end
                table.insert(self.list,itemData)
            -- end
        end
    end
    if self.list and SizeOfTable(self.list)>0 then
        local function sortFunc1(a,b)
            if a and b and a.point and b.point and a.point~=b.point then
                return a.point>b.point
            elseif a and b and a.side and b.side and a.side~=b.side then
                return a.side<b.side
            end
        end
        table.sort(self.list,sortFunc1)
        for k,v in pairs(self.list) do
            self.list[k].rank=k
        end
        local function sortFunc(a,b)
            if a and b and a.sortId and b.sortId then
                return a.sortId<b.sortId
            end
        end
        table.sort(self.list,sortFunc)
    end

end

function serverWarLocalInforTab1:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:updateList()
    -- self:initHeader()
    self:initTableView()
    return self.bgLayer
end

-- function serverWarLocalInforTab1:initHeader()
--     local headBg=LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () do return end end)
--     headBg:setContentSize(CCSizeMake(G_VisibleSizeWidth-40,220))
--     headBg:setAnchorPoint(ccp(0.5,1))
--     headBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160))
--     self.bgLayer:addChild(headBg,1)

--     local bgWidth=headBg:getContentSize().width
--     local bgHeight=headBg:getContentSize().height

--     -- local kingSp=CCSprite:createWithSpriteFrameName("world_island_6.png")
--     local kingSpPic=serverWarLocalCfg.cityCfg[serverWarLocalCfg.capitalID].icon
--     local kingSp=CCSprite:createWithSpriteFrameName(kingSpPic)
--     local spPosX=bgWidth-kingSp:getContentSize().width/2-80
--     kingSp:setPosition(ccp(spPosX,bgHeight/2))
--     kingSp:setScale(0.9)
--     headBg:addChild(kingSp,1)
--     local function nilFunc()
--     end
--     local scheduleBg=LuaCCScale9Sprite:createWithSpriteFrameName("allianceHeaderBg.png",CCRect(60, 20, 1, 1),nilFunc)
--     scheduleBg:setContentSize(CCSizeMake(200,40))
--     scheduleBg:setPosition(getCenterPoint(kingSp))
--     kingSp:addChild(scheduleBg,1)

--     local lbPosX=15
--     local posY=30
--     local spaceY=35
--     local kingAlliance=self.kingCity.name
--     local kingAllianceLeader=self.kingCity.leaderName
--     local defenderNum=self.kingCity.battleMemNum
--     local occupiedNum=self.kingCity.occupiedNum
--     local occupiedBaseNum=self.kingCity.occupiedBaseNum
--     local curValue=self.kingCity.hp
--     local totleValue=self.kingCity.maxHp
--     local lbTab={
--         {getlocal("local_war_king_city"),28,ccp(0,0.5),ccp(lbPosX,bgHeight-40),headBg,1,G_ColorYellowPro},
--         {getlocal("local_war_alliance_belongs",{kingAlliance}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY*3),headBg,1,G_ColorWhite},
--         {getlocal("local_war_alliance_heads",{kingAllianceLeader}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY*2),headBg,1,G_ColorWhite},
--         {getlocal("local_war_alliance_defender",{defenderNum}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY),headBg,1,G_ColorWhite},
--         {getlocal("local_war_alliance_occupied_area",{occupiedNum}),25,ccp(0,0.5),ccp(lbPosX,posY),headBg,1,G_ColorWhite},
--         {getlocal("local_war_alliance_levee_value"),25,ccp(0.5,0.5),ccp(spPosX,posY),headBg,1,G_ColorWhite},
--         {getlocal("scheduleChapter",{curValue,totleValue}),30,ccp(0.5,0.5),getCenterPoint(kingSp),kingSp,2,G_ColorYellowPro},
--     }
--     for k,v in pairs(lbTab) do
--         local key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
--         local lb=GetAllTTFLabel(key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment)
--     end

--     local hSpace=65
--     if occupiedBaseNum and occupiedBaseNum>0 then
--         for i=1,occupiedBaseNum do
--             -- local baseSp=CCSprite:createWithSpriteFrameName("world_island_6.png")
--             local baseSp=CCSprite:createWithSpriteFrameName(serverWarLocalCfg.cityCfg["a1"].icon)
--             baseSp:setScale(0.5)
--             local bx=bgWidth-baseSp:getContentSize().width/2*0.6
--             local by=(bgHeight-hSpace*2)/2+(i-1)*hSpace
--             baseSp:setPosition(ccp(bx,by))
--             headBg:addChild(baseSp,1)
--         end
--     end

-- end

function serverWarLocalInforTab1:initTableView()
    local function callback(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callback)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-40,G_VisibleSizeHeight-210),nil)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(20,30)
    self.bgLayer:addChild(self.tv)
    self.tv:setMaxDisToBottomOrTop(80)
end
function serverWarLocalInforTab1:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.list)
    elseif fn=="tableCellSizeForIndex" then
        return CCSizeMake(G_VisibleSizeWidth-40,230)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth,cellHeight=G_VisibleSizeWidth-40,230
        local lbPosX=15
        local posY=30
        local spaceY=35
        local cityData=self.list[idx+1]
        local allianceName=cityData.name
        local allianceLeader=cityData.leaderName
        local battleMemNum=cityData.battleMemNum
        local occupiedNum=cityData.occupiedNum
        -- local occupiedBaseNum=cityData.occupiedBaseNum or 0
        local serverName=cityData.serverName
        local point=cityData.point
        local side=cityData.side
        local mapCfg=serverWarLocalFightVoApi:getMapCfg()
        local rank=cityData.rank
        local selfAlliance=allianceVoApi:getSelfAlliance()
        local isSelf=false
        if selfAlliance and selfAlliance.name and selfAlliance.name==allianceName then
            isSelf=true
        end

        local rect = CCRect(0, 0, 50, 50);
        local capInSet = CCRect(20, 20, 10, 10);
        local function cellClick(hd,fn,idx)
        end
        local hei=230-5
        local backSprie

        if idx==0 then
            if isSelf==true then
                backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),cellClick)
                backSprie:setContentSize(CCSizeMake(cellWidth,cellHeight-5))
                -- backSprie:ignoreAnchorPointForPosition(false)
                -- backSprie:setAnchorPoint(ccp(0,0))
                backSprie:setPosition(ccp(cellWidth/2,cellHeight/2))
                backSprie:setIsSallow(false)
                backSprie:setTouchPriority(-(self.layerNum-1)*20-2)
                cell:addChild(backSprie,1)
            else
                backSprie=G_getThreePointBg(CCSizeMake(cellWidth,cellHeight-5),cellClick,ccp(0.5,0.5),ccp(cellWidth/2,cellHeight/2),cell)
            end
        else
            backSprie=G_getThreePointBg(CCSizeMake(cellWidth,cellHeight-5),cellClick,ccp(0.5,0.5),ccp(cellWidth/2,cellHeight/2),cell)
        end
        
        local bgWidth=backSprie:getContentSize().width
        local bgHeight=backSprie:getContentSize().height
        local aColor=G_ColorWhite
        if side==1 then
            aColor=ccc3(255, 50, 50)
        elseif side==2 then
            aColor=ccc3(218, 30, 214)
        elseif side==3 then
            aColor=ccc3(0, 255, 255)
        elseif side==4 then
            aColor=ccc3(56,246,154)
        end
        -- if isSelf==true then
        --     aColor=G_ColorYellowPro
        -- elseif rank==1 then
        --     aColor=G_ColorPurple
        -- elseif rank==2 then
        --     aColor=G_ColorBlue
        -- elseif rank==3 then
        --     aColor=G_ColorGreen
        -- end
        local lbTab={
            {allianceName,28,ccp(0,0.5),ccp(lbPosX,bgHeight-40),backSprie,1,aColor},
            {getlocal("serverWarLocal_server",{serverName}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY*3),backSprie,1,G_ColorWhite},
            {getlocal("local_war_alliance_heads",{allianceLeader}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY*2),backSprie,1,G_ColorWhite},
            {getlocal("local_war_alliance_battle_member_num",{battleMemNum}),25,ccp(0,0.5),ccp(lbPosX,posY+spaceY),backSprie,1,G_ColorWhite},
            {getlocal("local_war_alliance_occupied_area",{occupiedNum}),25,ccp(0,0.5),ccp(lbPosX,posY),backSprie,1,G_ColorWhite},
        }
        for k,v in pairs(lbTab) do
            local key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment=v[1],v[2],v[3],v[4],v[5],v[6],v[7],v[8],v[9],v[10]
            local lb=GetAllTTFLabel(key,size,anchorPoint,position,parent,zOrder,color,dimensions,hAlignment,vAlignment)
        end

        local px,py=backSprie:getContentSize().width-120,backSprie:getContentSize().height-70
        if rank>=1 and rank<=3 then
            local rankSp=CCSprite:createWithSpriteFrameName("top"..rank..".png")
            rankSp:setPosition(ccp(px,py))
            backSprie:addChild(rankSp,1)
        else
            local rankBg=LuaCCScale9Sprite:createWithSpriteFrameName("serverWarLocal_bg4.png",CCRect(10, 10, 1, 1),function ()end)
            rankBg:setContentSize(CCSizeMake(180,65))
            rankBg:setPosition(ccp(px,py))
            backSprie:addChild(rankBg,1)
            local rankLb=GetTTFLabelWrap(getlocal("rankOne",{rank}),25,CCSizeMake(backSprie:getContentSize().width-10,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            rankLb:setPosition(getCenterPoint(rankBg))
            rankBg:addChild(rankLb,1)
        end
        
        py=70
        local getPointLb=GetTTFLabel(getlocal("serverWarLocal_get_point"),25)
        getPointLb:setAnchorPoint(ccp(1,0.5))
        getPointLb:setPosition(ccp(px,py))
        getPointLb:setColor(G_ColorGreen)
        cell:addChild(getPointLb,1)
        local pointLb=GetBMLabel(point,G_GoldFontSrc,10)
        pointLb:setAnchorPoint(ccp(0,0.5))
        pointLb:setPosition(ccp(px,py))
        pointLb:setScale(0.5)
        cell:addChild(pointLb,1)

        -- local midX=bgWidth-120
        -- local midY=bgHeight/2
        -- local spaceX=110
        -- local spaceY=80
        -- if occupiedBaseNum>0 then
        --     for i=1,occupiedBaseNum do
        --         local scale
        --         local bx
        --         local by
        --         -- local baseSp=CCSprite:createWithSpriteFrameName("world_island_6.png")
        --         local baseSp=CCSprite:createWithSpriteFrameName(mapCfg.cityCfg["a1"].icon)
        --         if occupiedBaseNum==1 then
        --             scale=1.2
        --             bx=midX
        --             by=midY
        --         elseif occupiedBaseNum==2 then
        --             scale=0.7
        --             bx=midX+(i-1.5)*spaceX
        --             by=midY
        --         elseif occupiedBaseNum==3 then
        --             scale=0.7
        --             if i==1 then
        --                 bx=midX
        --                 by=midY+spaceY/2
        --             else
        --                 bx=midX+(i-2.5)*spaceX
        --                 by=midY-spaceY/2
        --             end
        --         elseif occupiedBaseNum==4 then
        --             scale=0.7
        --             spaceY=85
        --             bx=midX-0.5*spaceX+((i-1)%2)*spaceX
        --             by=midY+spaceY/2-math.floor((i-1)/2)*spaceY
        --         end
        --         baseSp:setScale(scale)
        --         baseSp:setPosition(ccp(bx,by))
        --         backSprie:addChild(baseSp,1)
        --     end
        -- else --出局
        --     local function nilFunc()
        --     end
        --     local mask=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),nilFunc)
        --     mask:setTouchPriority(-(self.layerNum-1)*20-2)
        --     local rect=CCSizeMake(backSprie:getContentSize().width,backSprie:getContentSize().height)
        --     mask:setContentSize(rect)
        --     mask:setOpacity(180)
        --     mask:setPosition(getCenterPoint(backSprie))
        --     backSprie:addChild(mask,5)
        --     local outLb=GetTTFLabelWrap(getlocal("local_war_alliance_already_out"),25,CCSizeMake(mask:getContentSize().width-40,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        --     outLb:setPosition(getCenterPoint(mask))
        --     outLb:setColor(G_ColorRed)
        --     mask:addChild(outLb,1)
        -- end

        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function serverWarLocalInforTab1:refresh()

end

function serverWarLocalInforTab1:tick()
  
end

function serverWarLocalInforTab1:dispose()
    self.bgLayer=nil
    self.layerNum=nil
    self.tv=nil
    -- self.kingCity={}
    self.list={}
end
