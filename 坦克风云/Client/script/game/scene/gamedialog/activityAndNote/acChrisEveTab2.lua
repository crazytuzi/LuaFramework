acChrisEveTab2 ={}
function acChrisEveTab2:new(layerNum)
    local nc={}
    setmetatable(nc,self)
    self.__index=self

    nc.bgLayer             = nil
    nc.layerNum            = layerNum
    nc.tv                  = nil
    nc.loveGems            = 0
    nc.bgWidth             = G_VisibleSizeWidth-40
    nc.bgHeight            = G_VisibleSizeHeight-182
    nc.shopTb              = {}
    nc.buyedTb             = {}
    nc.needIphone5Height_1 = 0
    if G_isIphone5() then
        nc.needIphone5Height_1 = -40
    end
    nc.isOver=false
    nc.version                = acChrisEveVoApi:getVersion()
    return nc;

end
function acChrisEveTab2:dispose( )
    self.version             = nil
    self.bgLayer             = nil
    self.layerNum            = nil
    self.tv                  = nil
    self.loveGems            = nil
    self.bgWidth             = nil
    self.bgHeight            = nil
    self.needIphone5Height_1 = nil
    self.shopTb  = nil
    self.buyedTb = {}
end

function acChrisEveTab2:init(layerNum)
    local strSize2 = 20
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
    end
    self.shopTb =acChrisEveVoApi:getShopTb( )
    self.buyedTb =acChrisEveVoApi:getBuyedTimeTb()
    self.bgLayer=CCLayer:create()
    self.layerNum = layerNum or self.layerNum

    local function touch( )
    end 
    local wholeBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)--拉霸动画背景
    wholeBgSp:setContentSize(CCSizeMake(self.bgWidth,self.bgHeight))
    wholeBgSp:setOpacity(0)
    self.bgLayer:addChild(wholeBgSp,1)
    wholeBgSp:setAnchorPoint(ccp(0,0))
    wholeBgSp:setPosition(ccp(20,23))

    if(acChrisEveVoApi:isNormalVersion()==false) and self.version ~= 5 then
        local cloud1 = CCSprite:createWithSpriteFrameName("snowBg_1.png")
        cloud1:setAnchorPoint(ccp(0,0.5))
        cloud1:setPosition(ccp(0,self.bgHeight))
        wholeBgSp:addChild(cloud1,99999)

        local cloud2 = CCSprite:createWithSpriteFrameName("snowBg_2.png")
        cloud2:setAnchorPoint(ccp(1,1))
        cloud2:setPosition(ccp(self.bgWidth,self.bgHeight+5))
        wholeBgSp:addChild(cloud2,99999)
    end
    -------
    local headBg=nil
    if self.version == 5 then
        headBg = LuaCCScale9Sprite:createWithSpriteFrameName("newItemKuang.png",CCRect(15,15,2,2),function () end)
    else
        headBg = LuaCCScale9Sprite:createWithSpriteFrameName("CorpsLevel.png",CCRect(65,25,1,1),function () end)
    end
    headBg:setContentSize(CCSizeMake(wholeBgSp:getContentSize().width-4,wholeBgSp:getContentSize().height*0.2+self.needIphone5Height_1+15))
    headBg:setAnchorPoint(ccp(0.5,1))
    headBg:setPosition(ccp(wholeBgSp:getContentSize().width*0.5,wholeBgSp:getContentSize().height-4))
    wholeBgSp:addChild(headBg)

    local loveBagIcon = GetBgIcon("loveBagPic.png",nil,"Icon_BG.png",80,100)
    loveBagIcon:setAnchorPoint(ccp(0,1))
    loveBagIcon:setPosition(ccp(15,headBg:getContentSize().height-25))
    headBg:addChild(loveBagIcon)

    local allloveGems =acChrisEveVoApi:getLoveGems()
    local expendLoves = acChrisEveVoApi:getExpendLoveGems()
    local loveGems = allloveGems-expendLoves
    self.loveGems =GetTTFLabel(loveGems,25)
    self.loveGems:setAnchorPoint(ccp(0.5,1))
    self.loveGems:setPosition(ccp(loveBagIcon:getContentSize().width*0.5+25,headBg:getContentSize().height-loveBagIcon:getContentSize().height-50))
    headBg:addChild(self.loveGems)

    local loveGemsStr = GetTTFLabelWrap(getlocal("activity_chrisEve_loveGemsStr"),25,CCSizeMake(180,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    loveGemsStr:setAnchorPoint(ccp(0,1))
    loveGemsStr:setPosition(ccp(loveBagIcon:getContentSize().width+45,loveBagIcon:getPositionY()-10))
    headBg:addChild(loveGemsStr)

    local aboutLoveGemsStr = GetTTFLabelWrap(getlocal("activity_chrisEve_loveGemsDesc"),strSize2,CCSizeMake(350,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    aboutLoveGemsStr:setAnchorPoint(ccp(0,0.5))
    aboutLoveGemsStr:setPosition(ccp(loveBagIcon:getContentSize().width+45,loveBagIcon:getPositionY()-70))
    headBg:addChild(aboutLoveGemsStr)

    -- local function touch33(tag,object)
    --     self:openInfo()
    -- end
    -- local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch33,1,nil,0)
    -- menuItemDesc:setAnchorPoint(ccp(1,1))
    -- -- menuItemDesc:setScale(0.9)
    -- local menuDesc=CCMenu:createWithItem(menuItemDesc)
    -- menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    -- menuDesc:setPosition(ccp(headBg:getContentSize().width-5,headBg:getContentSize().height-5))
    -- headBg:addChild(menuDesc,1)
    local function touch33(tag,object)
    self:openInfo()
    end
    local menuItemDesc=GetButtonItem("i_sq_Icon1.png","i_sq_Icon2.png","i_sq_Icon1.png",touch33,1,nil,0)
    menuItemDesc:setAnchorPoint(ccp(1,1))
    menuItemDesc:setScale(0.9)
    local menuDesc=CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum-1)*20-5)
    menuDesc:setPosition(ccp(headBg:getContentSize().width-5,headBg:getContentSize().height-5))
    headBg:addChild(menuDesc,1)

    if self.version == 5 then
        menuItemDesc:setScale(1)
        menuItemDesc:setAnchorPoint(ccp(1,0.5))
        menuDesc:setPosition(ccp(headBg:getContentSize().width-15,headBg:getContentSize().height * 0.5))
    end

    if(acChrisEveVoApi:isNormalVersion()==false) and self.version ~= 5 then
    --bellPic
    local bellPic = CCSprite:createWithSpriteFrameName("bellPic.png")
    bellPic:setAnchorPoint(ccp(1,0.5))
    bellPic:setPosition(ccp(self.bgLayer:getContentSize().width+10,self.bgLayer:getContentSize().height-headBg:getContentSize().height*2+25))
    self.bgLayer:addChild(bellPic,99999)
    end


    self:initTableView()

    return self.bgLayer
end

function acChrisEveTab2:eventHandler( handler,fn,idx,cel )
    local cellBgWidth = self.bgWidth-4 
    local cellBgHeight = self.bgHeight*0.8-self.needIphone5Height_1-15
    local strSize2 = 20
    local posHscale = 0.33
    local namePosH = 80
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" or G_getCurChoseLanguage() =="tw" then
        strSize2 =25
        posHscale =0.28
        namePosH =50
    end
    if G_getIphoneType() == G_iphoneX then
        namePosH = namePosH + 15
    end
    if fn=="numberOfCellsInTableView" then
        return SizeOfTable(self.shopTb)
    elseif fn=="tableCellSizeForIndex" then
        local adaH = 0
        if G_getIphoneType() == G_iphoneX then 
            adaH = 20
        end 
        return  CCSizeMake(cellBgWidth,cellBgHeight*posHscale-adaH)-- -100
    elseif fn=="tableCellAtIndex" then
         local cell=CCTableViewCell:new()

         local function touch( )
         end     
        local cellBgSp=LuaCCScale9Sprite:createWithSpriteFrameName("panelItemBg.png",CCRect(20, 20, 10, 10),touch)--拉霸动画背景
        cellBgSp:setContentSize(CCSizeMake(cellBgWidth-2,cellBgHeight*posHscale))
        self.buyedTb = acChrisEveVoApi:getBuyedTimeTb()
        cellBgSp:setAnchorPoint(ccp(0,0))
        cellBgSp:setPosition(ccp(0,0))
        cell:addChild(cellBgSp,3)
        if self.version == 5 then
            cellBgSp:setOpacity(0)
        end
        --i1={id="i1",buynum=1,price=3000,reward={p={{p804=1}}},serverReward={props_p804=1}},
        local buyedTimes = 0
        if self.buyedTb  and self.buyedTb["i"..idx+1] then
            buyedTimes =self.buyedTb["i"..idx+1]
        end
        local singleTb = self.shopTb["i"..idx+1]

        local reward = FormatItem(singleTb["reward"],false)
        local picIcon =G_getItemIcon(reward[1],100,false,self.layerNum)
        local picName = reward[1].name
        local picNum = reward[1].num
        local picDesc = reward[1].desc
        local buyId = singleTb.id
        -- print("buyId------>",buyId)
        -- acChrisEveVoApi:setCurBuyId(buyId)
        local buyTopNum = singleTb.buynum
        local needLoveGems = singleTb.price

        picIcon:setAnchorPoint(ccp(0,0.5))
        picIcon:setPosition(ccp(15,cellBgSp:getContentSize().height*.5))
        cellBgSp:addChild(picIcon,1)
        -- print("!!!!!--->",strSize2,picName)
        local iconNum = picNum 
        local iconLabel = GetTTFLabel("x"..iconNum,25)
        iconLabel:setAnchorPoint(ccp(1,0))
        iconLabel:setPosition(ccp(picIcon:getContentSize().width-4,4))
        picIcon:addChild(iconLabel,1)
        iconLabel:setScale(picIcon:getContentSize().width*0.2/25)

        local picNameStr = GetTTFLabelWrap(picName,strSize2,CCSizeMake(250,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        picNameStr:setAnchorPoint(ccp(0,1))
        picNameStr:setPosition(ccp(picIcon:getContentSize().width+30,picIcon:getPositionY()+namePosH))
        cellBgSp:addChild(picNameStr)

        local loveBagIcon = CCSprite:createWithSpriteFrameName("loveBagPic.png")
        loveBagIcon:setAnchorPoint(ccp(1,0.5))
        loveBagIcon:setScale(0.7)
        loveBagIcon:setPosition(ccp(cellBgSp:getContentSize().width-10,cellBgSp:getContentSize().height*0.75))
        cellBgSp:addChild(loveBagIcon)

        local picDescStr = GetTTFLabelWrap(getlocal(picDesc),strSize2,CCSizeMake(300,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
        picDescStr:setAnchorPoint(ccp(0,1))
        picDescStr:setPosition(ccp(picIcon:getContentSize().width+30,loveBagIcon:getPositionY()-30))
        cellBgSp:addChild(picDescStr)

        local needLoveGemsStr = GetTTFLabel(needLoveGems,25)
        needLoveGemsStr:setAnchorPoint(ccp(1,0.5))
        needLoveGemsStr:setPosition(ccp(cellBgSp:getContentSize().width-70,cellBgSp:getContentSize().height*0.75))
        cellBgSp:addChild(needLoveGemsStr)

        local function btnclick( ... )
            local allloveGems =acChrisEveVoApi:getLoveGems()
            local expendLoves = acChrisEveVoApi:getExpendLoveGems()
            local loveGems = allloveGems-expendLoves
            if needLoveGems >loveGems then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("activity_chrisEve_noLove"),30)
                do return end
            end
            local function buyCallBack(fn,data)
              local ret,sData=base:checkServerData(data)
              if ret ==true then
                print("buyId---->",buyId)
                local awardInBuy = acChrisEveVoApi:getShopByIdIdx(buyId)
                    -- for k,v in pairs(awardInBuy) do
                    print("awardInBuy.key----->",awardInBuy.key,awardInBuy.name,awardInBuy.num)
                    G_addPlayerAward(awardInBuy.type,awardInBuy.key,awardInBuy.id,tonumber(awardInBuy.num),nil,true)
                    -- end
                    if sData.data and sData.data.shengdanqianxi and sData.data.shengdanqianxi.buy then
                        acChrisEveVoApi:setBuyedTimeTb(sData.data.shengdanqianxi.buy)
                        acChrisEveVoApi:setExpendLoveGems(sData.data.shengdanqianxi.d)
                    end
                    local allLoves = acChrisEveVoApi:getLoveGems()
                    self.loveGems:setString(allLoves - sData.data.shengdanqianxi.d)
                    local recordPoint = self.tv:getRecordPoint()
                    self.tv:reloadData()
                    self.tv:recoverToRecordPoint(recordPoint)
                      -- acChrisEveVoApi:setCurBuyId()
                      smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("allianceShop_buySuccess"),30)
                  end

              end
              socketHelper:chrisEveSend(buyCallBack,"buy",nil,buyId)

        end 
        local codeGiftbtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",btnclick,1,getlocal("code_gift"),24/0.6)
        codeGiftbtn:setAnchorPoint(ccp(1,0.5))
        codeGiftbtn:setScale(0.6)
        local menuDesc=CCMenu:createWithItem(codeGiftbtn)
        menuDesc:setTouchPriority(-(self.layerNum-1)*20-8)
        menuDesc:setPosition(ccp(cellBgSp:getContentSize().width-20,cellBgSp:getContentSize().height*0.25))
        cellBgSp:addChild(menuDesc,1)
        -- print("~~~~1")
        -- local acVo = acChrisEveVoApi:getAcVo()
        -- if base.serverTime > acVo.acEt -86400  then
        --     print("~~~~1222")
        --     codeGiftbtn:setEnabled(false)
        -- end
        --super_weapon_challenge_troops_schedule
        local showCurTimesStr = GetTTFLabel(getlocal("super_weapon_challenge_troops_schedule",{buyedTimes,buyTopNum}),25)
        showCurTimesStr:setAnchorPoint(ccp(1,0.5))
        showCurTimesStr:setPosition(ccp(cellBgSp:getContentSize().width-120,cellBgSp:getContentSize().height*0.75))
        cellBgSp:addChild(showCurTimesStr)

        -- print("buyedTimes-----buytopnum",buyedTimes ,buyTopNum)
        if buyedTimes>= buyTopNum then
            codeGiftbtn:setEnabled(false)
            showCurTimesStr:setColor(G_ColorRed)
        end

        if self.version == 5 then
            local line =LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine2.png",CCRect(2,1,1,1),function ()end)
            line:setContentSize(CCSizeMake(cellBgSp:getContentSize().width - 80,line:getContentSize().height))
            line:setPosition(ccp(cellBgSp:getContentSize().width * 0.5,0))
            cellBgSp:addChild(line,99)
        end

        cell:autorelease()
        return cell
    elseif fn=="ccTouchBegan" then
        self.isMoved=false
        return true
    elseif fn=="ccTouchMoved" then
        self.isMoved=true
    elseif fn=="ccTouchEnded"  then
    end
end

function acChrisEveTab2:openInfo( )
    -- print("in openInfo~~~~~")
    local td=smallDialog:new()
    local tabStr = nil 
    local tip2
    if(acChrisEveVoApi:isNormalVersion() or self.version == 5)then
        tip2=getlocal("activity_chrisEve_d2_tip1_1")
    else
        tip2=getlocal("activity_chrisEve_d2_tip1")
    end
    tabStr ={"\n",getlocal("activity_chrisEve_d2_tip2"),"\n",tip2,"\n"}
    local dialog=td:init("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),nil,true,true,self.layerNum+1,tabStr,28,{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil})
    sceneGame:addChild(dialog,self.layerNum+1)
end
function acChrisEveTab2:refresh( )
    local allloveGems =acChrisEveVoApi:getLoveGems()
    local expendLoves = acChrisEveVoApi:getExpendLoveGems()
    local loveGems = allloveGems-expendLoves
    self.loveGems:setString(loveGems)
    -- if self.tv then
    --     self.tv:reloadData()
    -- end
end
function acChrisEveTab2:tick( )
    -- local acVo = acChrisEveVoApi:getAcVo()
    -- if base.serverTime > acVo.acEt -86400 and self.isOver ==false then
    --     print("here???in tick")
    --     if self.tv then
    --         self.isOver =true
    --         self.tv:reloadData()
    --     end
    -- end
end

function acChrisEveTab2:initTableView()
    if self.version == 5 then
        local tvBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png",CCRect(15,15,2,2),function ()end)
        tvBg:setContentSize(CCSizeMake(self.bgWidth-4 ,self.bgHeight*0.8-self.needIphone5Height_1-20))
        tvBg:setAnchorPoint(ccp(0,0))
        tvBg:setPosition(20,23)
        self.bgLayer:addChild(tvBg)
    end
 local function callBack(...)
     return self:eventHandler(...)
 end
 local hd= LuaEventHandler:createHandler(callBack)
 self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgWidth-4 ,self.bgHeight*0.8-self.needIphone5Height_1-20),nil)
 self.bgLayer:addChild(self.tv,1)
 self.tv:setPosition(ccp(20,23))
 self.tv:setAnchorPoint(ccp(0,0))
 self.tv:setTableViewTouchPriority(-(self.layerNum-1) * 20 - 4)
 self.bgLayer:setTouchPriority(-(self.layerNum-1) * 20 - 1)
 self.tv:setMaxDisToBottomOrTop(120)
end