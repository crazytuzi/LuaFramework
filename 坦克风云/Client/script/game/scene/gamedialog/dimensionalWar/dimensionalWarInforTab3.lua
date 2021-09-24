dimensionalWarInforTab3={}

function dimensionalWarInforTab3:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    -- self.descColorList={}
    self.descLbList={}
    self.statusList={}

    return nc
end

function dimensionalWarInforTab3:init(layerNum,parent)
    self.bgLayer=CCLayer:create()
    self.layerNum=layerNum
    self.parent=parent
    self:initTableView()
    return self.bgLayer
end

function dimensionalWarInforTab3:initTableView()
    local descList={getlocal("dimensionalWar_help_title1"),getlocal("dimensionalWar_help_content1"),getlocal("dimensionalWar_help_title2"),getlocal("dimensionalWar_help_content2",{userWarCfg.limitLevel,userWarCfg.tankeTransRate,math.ceil(userWarCfg.prepareTime/60)}),getlocal("dimensionalWar_help_content2_1"),getlocal("dimensionalWar_help_title3"),getlocal("dimensionalWar_help_content3"),getlocal("dimensionalWar_help_content3_1",{userWarCfg.roundTime,userWarCfg.roundAccountTime}),getlocal("dimensionalWar_help_content3_2",{userWarCfg.maxbattleround}),getlocal("dimensionalWar_help_title4"),getlocal("dimensionalWar_help_content4"),getlocal("dimensionalWar_help_content4_1"),getlocal("dimensionalWar_help_title5"),getlocal("dimensionalWar_help_content5"),getlocal("dimensionalWar_help_content5_1",{userWarCfg.point[2],userWarCfg.point[1]}),getlocal("dimensionalWar_help_title6"),getlocal("dimensionalWar_help_content6"),getlocal("dimensionalWar_help_content6_1"),getlocal("dimensionalWar_help_content6_2"),"",getlocal("dimensionalWar_help_content6_3")}
    --0是标题，1是图片，2是1层缩进，3是放大且1级缩进，4是2级缩进
    self.statusList={0,nil,0,2,2,0,nil,2,2,0,nil,2,0,nil,2,0,3,4,3,1,4}
    self.descColorList={nil,nil,nil,nil,G_ColorRed,nil,nil,nil,G_ColorRed,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil}
    self.descLbList={}
    for k,v in pairs(descList) do
        local lb
        local lbSize=25
        local alignment=kCCTextAlignmentLeft
        local spacex=0
        local spacey=30
        -- if self.descColorList[k]==G_ColorGreen then
        if self.statusList[k]==0 then
            lbSize=30
            alignment=kCCTextAlignmentCenter
        elseif self.statusList[k]==2 then
            spacex=20
        elseif self.statusList[k]==3 then
            lbSize=28
            spacey=10
        elseif self.statusList[k]==4 then
            spacex=40
            spacey=10
        -- elseif k ==18 and G_getCurChoseLanguage() =="ar" then
        --     print("k=====>>",k)
        --     spacex =-20
        end
        local tmpLb=GetTTFLabelWrap(v,lbSize,CCSizeMake(G_VisibleSizeWidth-60-spacex,0),alignment,kCCVerticalTextAlignmentCenter)
        -- if v ==getlocal("dimensionalWar_help_content6_1") then
        --     print("k------->",k)--18
        -- end
        lb=GetTTFLabelWrap(v,lbSize,CCSizeMake(G_VisibleSizeWidth-60-spacex,tmpLb:getContentSize().height+spacey),alignment,kCCVerticalTextAlignmentCenter)
        self.descLbList[k]=lb
    end

    local function callBack(...)
        return self:eventHandler(...)
    end
    local hd=LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(G_VisibleSizeWidth-60,G_VisibleSizeHeight-230),nil)
    self.bgLayer:addChild(self.tv)
    self.tv:setAnchorPoint(ccp(0,0))
    self.tv:setPosition(ccp(30,50))
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setMaxDisToBottomOrTop(80)
end


function dimensionalWarInforTab3:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return #self.descLbList
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize
        if self.statusList[idx+1] and self.statusList[idx+1]==1 then
            tmpSize=CCSizeMake(G_VisibleSizeWidth - 60,140)
        else
            tmpSize=CCSizeMake(G_VisibleSizeWidth - 60,self.descLbList[idx + 1]:getContentSize().height + 20)
        end
        return tmpSize
        -- return CCSizeMake(G_VisibleSizeWidth - 60,self.descLbList[idx + 1]:getContentSize().height + 15)
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local lb=tolua.cast(self.descLbList[idx + 1],"CCLabelTTF")

        if lb then
            -- if(self.descColorList[idx + 1] and self.descColorList[idx + 1]==G_ColorGreen)then
            if self.statusList[idx+1] and self.statusList[idx+1]==0 then
                -- self.descLbList[idx + 1]:setColor(self.descColorList[idx + 1])
                lb:setAnchorPoint(ccp(0.5,0.5))
                lb:setPosition((G_VisibleSizeWidth - 60)/2,(lb:getContentSize().height + 10)/2)
                -- local titleBg=LuaCCScale9Sprite:createWithSpriteFrameName("HelpHeaderBg.png",CCRect(20, 20, 10, 10),function()end)
                local titleBg=CCSprite:createWithSpriteFrameName("SuccessPanelSmall.png")
                -- titleBg:setContentSize(CCSizeMake(titleBg:getContentSize().width,20))
                titleBg:setScaleX((G_VisibleSizeWidth-60)/titleBg:getContentSize().width)
                titleBg:setScaleY(50/titleBg:getContentSize().height)
                titleBg:setAnchorPoint(ccp(0.5,0.5))
                titleBg:setPosition(ccp((G_VisibleSizeWidth - 60)/2,(lb:getContentSize().height + 10)/2))
                cell:addChild(titleBg)
            elseif self.statusList[idx+1] and self.statusList[idx+1]==1 then
                local spacex=140
                for i=1,3 do
                    local levelBg
                    if i==1 then
                        levelBg=CCSprite:createWithSpriteFrameName("equipSelectedRect.png")
                        levelBg:setScale(115/levelBg:getContentSize().width)
                    else
                        levelBg=CCSprite:createWithSpriteFrameName("dwGroundBg"..i..".png")
                    end
                    -- local levelBg=CCSprite:createWithSpriteFrameName("dwGroundBg"..(i-1)..".png")
                    if levelBg then
                        local px,py=(G_VisibleSizeWidth - 60)/2-spacex+spacex*(i-1),140/2
                        levelBg:setPosition(ccp(px,py))
                        cell:addChild(levelBg,2)
                        local levelStr=""
                        if i==1 then
                            levelStr=getlocal("merge_precent_name4")
                        elseif i==2 then
                            levelStr=getlocal("dimensionalWar_middle")
                        else
                            levelStr=getlocal("merge_precent_name2")
                        end
                        local levelLb=GetTTFLabel(levelStr,25)
                        levelLb:setPosition(getCenterPoint(levelBg))
                        levelBg:addChild(levelLb,2)
                    end
                end
            elseif self.statusList[idx+1] and self.statusList[idx+1]==2 or self.statusList[idx+1] and self.statusList[idx+1]==3 then
                lb:setAnchorPoint(ccp(0,0.5))
                lb:setPosition(20,(lb:getContentSize().height + 10)/2)
            elseif self.statusList[idx+1] and self.statusList[idx+1]==4 then
                lb:setAnchorPoint(ccp(0,0.5))
                lb:setPosition(40,(lb:getContentSize().height + 10)/2)
            else
                lb:setAnchorPoint(ccp(0,0.5))
                lb:setPosition(0,(lb:getContentSize().height + 10)/2)
            end
            if self.descColorList and self.descColorList[idx+1] then
                local color=self.descColorList[idx+1]
                lb:setColor(color)
            end
            cell:addChild(lb,2)
        end
        if idx+1 == 18 and G_getCurChoseLanguage() =="ar" then
            lb:setPosition(ccp(10,lb:getPositionY()))
        elseif (idx+1 ==17 or idx+1 ==19) and G_getCurChoseLanguage() =="ar" then
            lb:setPosition(ccp(-10,lb:getPositionY()))
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

function dimensionalWarInforTab3:dispose()
    -- self.descColorList={}
    self.descLbList={}
    self.statusList={}
end
