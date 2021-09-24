superWeaponCRewardListDialog=commonDialog:new()
function superWeaponCRewardListDialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.rewardList={}
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/accessoryImage.plist")
    return nc
end

--设置对话框里的tableView
function superWeaponCRewardListDialog:initTableView()
    self.panelLineBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height/2-35))
    self.panelLineBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-20,G_VisibleSize.height-95))

    if swChallengeCfg and swChallengeCfg.list then
        for k,v in pairs(swChallengeCfg.list) do
            if v and v.clientReward and v.clientReward.rand and SizeOfTable(v.clientReward.rand)>0 then
                local rewardTb=FormatItem(v.clientReward.rand)
                local itemData={k,rewardTb}
                table.insert(self.rewardList,itemData)
            end
        end
        local function sortFunc(a,b)
            if a and a[1] and b and b[1] then
                return a[1]<b[1]
            end
        end
        table.sort(self.rewardList,sortFunc)
    end

    local function callBack(...)
       return self:eventHandler(...)
    end
    local hd= LuaEventHandler:createHandler(callBack)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgLayer:getContentSize().height-130),nil)
    self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-1)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-3)
    self.tv:setPosition(ccp(15,30))
    self.bgLayer:addChild(self.tv,1)
    self.tv:setMaxDisToBottomOrTop(140)
end

--这里是tableView的详细逻辑 handler:方法索引  fn:方法名 idx:cell索引 cel:cell
function superWeaponCRewardListDialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.rewardList)
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(self.bgLayer:getContentSize().width-30,130)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        
        -- local sprieBg=CCSprite:createWithSpriteFrameName("7daysBg.png")
        -- sprieBg:setAnchorPoint(ccp(0,0))
        -- sprieBg:setPosition(ccp(0,10))
        -- cell:addChild(sprieBg)

        local rect = CCRect(0, 0, 50, 50)
        local capInSet = CCRect(20, 20, 10, 10)
        local function cellClick(hd,fn,idx)
        end
        local sprieBg =LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",capInSet,cellClick)
        sprieBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,120))
        sprieBg:ignoreAnchorPointForPosition(false)
        sprieBg:setAnchorPoint(ccp(0,0))
        sprieBg:setIsSallow(false)
        sprieBg:setTouchPriority(-(self.layerNum-1)*20-2)
        sprieBg:setPosition(ccp(0,10))
        cell:addChild(sprieBg)

        local cfg=self.rewardList[idx+1]
        local index=cfg[1]
        local rewardTb=cfg[2]

        -- local numLabel=GetTTFLabel(getlocal("super_weapon_challenge_floors",{idx+1}),25)
        -- numLabel:setAnchorPoint(ccp(0.5,0.5))
        -- numLabel:setPosition(ccp(15,sprieBg:getContentSize().height-25))
        -- sprieBg:addChild(numLabel,1)
        -- numLabel:setColor(G_ColorGreen)

        local numLabel=GetTTFLabelWrap(getlocal("super_weapon_challenge_floors",{index}),24,CCSizeMake(150,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter,"Helvetica-bold")
        -- local numLabel=GetTTFLabelWrap("啊啊啊啊啊啊啊啊啊啊啊啊",25,CCSizeMake(180,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        numLabel:setAnchorPoint(ccp(0.5,0.5))
        numLabel:setPosition(ccp(105,sprieBg:getContentSize().height/2))
        numLabel:setColor(G_ColorGreen)
        sprieBg:addChild(numLabel,1)

        local award={}
        -- if cfg and cfg.clientReward then
        --     if cfg.clientReward.base and SizeOfTable(cfg.clientReward.base)>0 then
        --         local baseReward=FormatItem(cfg.clientReward.base)
        --         for k,v in pairs(baseReward) do
        --             table.insert(award,v)
        --         end
        --     end
        --     if cfg.clientReward.rand and SizeOfTable(cfg.clientReward.rand)>0 then
        --         local randReward=FormatItem(cfg.clientReward.rand)
        --         for k,v in pairs(randReward) do
        --             table.insert(award,v)
        --         end
        --     end
        -- end
        if rewardTb and SizeOfTable(rewardTb)>0 then
            for k,v in pairs(rewardTb) do
                table.insert(award,v)
            end
        end
        local function showInfoHandler(hd,fn,idx)
            if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then
                local item=award[idx]
                if item then
                    propInfoDialog:create(sceneGame,item,self.layerNum+1)
                end
            end
        end
        for k,v in pairs(award) do
            local icon
            local pic=v.pic
            local iconScaleX=1
            local iconScaleY=1
            local iScale=1--0.78
            if v.type=="p" and v.equipId then
                local eType=string.sub(v.equipId,1,1)
                if eType=="a" then
                    icon = accessoryVoApi:getAccessoryIcon(v.equipId,80,100,showInfoHandler)
                elseif eType=="f" then
                    icon = accessoryVoApi:getFragmentIcon(v.equipId,80,100,showInfoHandler)
                else
                    icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
                end
            elseif pic then
                icon = LuaCCSprite:createWithSpriteFrameName(pic,showInfoHandler)
            end
            if icon:getContentSize().width>100 then
                iconScaleX=iScale*100/150
                iconScaleY=iScale*100/150
            else
                iconScaleX=iScale
                iconScaleY=iScale
            end
            icon:setScaleX(iconScaleX)
            icon:setScaleY(iconScaleY)
                --end
            icon:ignoreAnchorPointForPosition(false)
            -- icon:setAnchorPoint(ccp(0,0))
            -- icon:setPosition(ccp(10+(k-1)*85,12))
            icon:setPosition(ccp(10+(k-1)*120+250,sprieBg:getContentSize().height/2))
            icon:setIsSallow(false)
            icon:setTouchPriority(-(self.layerNum-1)*20-2)
            sprieBg:addChild(icon,1)
            icon:setTag(k)
        
            if tostring(v.name)~=getlocal("honor") then
                local numLabel=GetTTFLabel("x"..v.num,25)
                --numLabel:setColor(G_ColorGreen)
                numLabel:setAnchorPoint(ccp(1,0))
                numLabel:setPosition(icon:getContentSize().width-10,0)
                icon:addChild(numLabel,1)
                numLabel:setScaleX(1/iconScaleX)
                numLabel:setScaleY(1/iconScaleY)
                --numLabel:setPosition((k-1)*85+icon:getContentSize().width*iconScaleX/2+12,10)
                --cell:addChild(numLabel,1)
            end
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

function superWeaponCRewardListDialog:tick()

end

--用户处理特殊需求,没有可以不写此方法
function superWeaponCRewardListDialog:doUserHandler()

end

function superWeaponCRewardListDialog:dispose()
    self.rewardList=nil
end




