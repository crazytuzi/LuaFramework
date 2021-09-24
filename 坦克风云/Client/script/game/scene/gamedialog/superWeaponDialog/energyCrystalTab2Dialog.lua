energyCrystalTab2Dialog={}

function energyCrystalTab2Dialog:new()
    local nc={}
    setmetatable(nc,self)
    self.__index=self
    self.layerNum=nil
    self.tipSp=nil
    self.allTabs={};
    self.crystalList=nil--当前选择的结晶数据
    self.selectedTabIndex=0;
    self.showCrystalNum=5--每行显示多少个结晶
    self.selectedCrystalVO1=nil--选中的第一个结晶
    self.selectedCrystalVO2=nil--选中的第二个结晶
    self.selectedCrystalIdx1=0
    self.selectedCrystalIdx2=0
    self.allCrystalIconSp={}--所有的结晶iconsp
    self.selectedCrystalIconSp1=nil--选中的第一个结晶icon
    self.selectedCrystalIconSp2=nil--选中的第二个结晶icon
    self.selectedCrystalIconPos1=nil
    self.selectedCrystalIconPos2=nil
    self.centerPos=nil--融合成功后的中心点
    self.isPlaying=false--是否在播放动画
    self.mergeSuccessCrystalVo=nil--融合成功的结晶vo
    self.mergeFailCrystalVo=nil--融合失败的结晶vo
    self.tipLayer=nil
    self.isUseProtect=0 --是否选择了稳固齿轮
    self.propNum=0 --选择融合齿轮数量
    self.propMaxNum=0 --可选择的融合齿轮最大数量
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/new_superWeapon_crysral.plist")
    spriteController:addTexture("public/new_superWeapon_crysral.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    spriteController:addPlist("public/acThfb.plist")
    spriteController:addTexture("public/acThfb.png")
    spriteController:addPlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:addTexture("public/dimensionalWar/dimensionalWar.png")

    return nc
end
--设置或修改每个Tab页签
function energyCrystalTab2Dialog:resetTab()
    self.allTabs={getlocal("redTitle"),getlocal("yellowTitle"),getlocal("blueTitle")}
    self:initTab(self.allTabs)
    local index=0
    for k,v in pairs(self.allTabs) do
         local  tabBtnItem=v
         if index==0 then
            tabBtnItem:setPosition(100,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==1 then
            tabBtnItem:setPosition(248-10,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         elseif index==2 then
            tabBtnItem:setPosition(394-20,G_VisibleSizeHeight-tabBtnItem:getContentSize().height/2-160)
         end
         if index==self.selectedTabIndex then
             tabBtnItem:setEnabled(false)
         end
         index=index+1
    end
    
end


function energyCrystalTab2Dialog:init(layerNum)

    
    self.bgLayer=CCLayer:create();
    self.layerNum=layerNum
    self:initAllBg()
    return self.bgLayer
end

function energyCrystalTab2Dialog:initAllBg()
    local swBg=CCSprite:create("public/superWeapon/weaponBg.jpg")
    swBg:setAnchorPoint(ccp(0.5,1))
    swBg:setScaleX((G_VisibleSizeWidth-45)/swBg:getContentSize().width)
    swBg:setScaleY(450/swBg:getContentSize().height)
    swBg:setPosition(G_VisibleSizeWidth/2,G_VisibleSizeHeight-160)
    self.bgLayer:addChild(swBg)

    local titLbSize =18
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
        titLbSize =25
    end
    -- 初始化融合背景
    self.crystalMergeBg=CCSprite:create()
    self.crystalMergeBg:setContentSize(CCSizeMake(334,384))
    self.crystalMergeBg:setAnchorPoint(ccp(0.5,0))
    self.crystalMergeBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.bgLayer:getContentSize().height-165-self.crystalMergeBg:getContentSize().height))
    self.bgLayer:addChild(self.crystalMergeBg,1)

    self.selectedCrystalIconPos1=ccp(165-222-20,250)
    self.selectedCrystalIconPos2=ccp(165+227+20,250)
    self.centerPos=ccp(165,230)


    self.crystalMergeBg1 = CCSprite:createWithSpriteFrameName("crystalMergeBg0000.png")
    self.crystalMergeFireBg = CCSprite:createWithSpriteFrameName("crystalMergeFire0000.png")
    local crystalMergeBottomBg = CCSprite:createWithSpriteFrameName("superWeapon_base.png")

    
    self.crystalMergeBg1:setScale(2)
    self.crystalMergeFireBg:setScale(2)
    
    self.crystalMergeBg1:setAnchorPoint(ccp(0.5,0))
    self.crystalMergeBg1:setPosition(ccp(self.crystalMergeBg:getContentSize().width/2,crystalMergeBottomBg:getContentSize().height-200))

    self.crystalMergeFireBg:setAnchorPoint(ccp(0.5,0))
    self.crystalMergeFireBg:setPosition(ccp(self.crystalMergeBg:getContentSize().width/2,0))
    
    crystalMergeBottomBg:setAnchorPoint(ccp(0.5,0))
    crystalMergeBottomBg:setPosition(ccp(self.crystalMergeBg:getContentSize().width/2,0))
    
    self.crystalMergeBg:addChild(self.crystalMergeBg1,1)
    self.crystalMergeBg:addChild(self.crystalMergeFireBg,5)
    self.crystalMergeBg:addChild(crystalMergeBottomBg,3)


    
    -- 初始化融合进度条
    -- local mergeProgressBar3Sp = CCSprite:createWithSpriteFrameName("mergeProgressBar3.png")
    -- mergeProgressBar3Sp:setAnchorPoint(ccp(0.5,1))
    -- mergeProgressBar3Sp:setPosition(ccp(self.crystalMergeBg:getContentSize().width,self.bgLayer:getContentSize().height-175))
    -- self.bgLayer:addChild(mergeProgressBar3Sp)

    self.mergeProgressBar1Sp = CCSprite:createWithSpriteFrameName("mergeProgressBar1.png")
    self.mergeProgressBar1Sp:setAnchorPoint(ccp(0.5,0.5))
    -- self.mergeProgressBar1Sp:setPosition(ccp(self.crystalMergeBg:getContentSize().width,self.bgLayer:getContentSize().height-175))
    self.mergeProgressBar1Sp:setPosition(ccp(self.crystalMergeBg:getContentSize().width-12,self.bgLayer:getContentSize().height-190-20))
    self.bgLayer:addChild(self.mergeProgressBar1Sp)
    self.mergeProgressBar1Sp:setRotation(90)
    self.mergeProgressBar1Sp:setScale(1.5)
    self.mergeProgressBar1Sp:setOpacity(128)

    local function touchTip()
        if self.isPlaying==true then
            return
        end 
        local tabStr = {}
        for i=1,5 do
            table.insert(tabStr,getlocal("sw_fusion_help"..i))
        end
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(self.layerNum+1,true,true,nil,getlocal("activity_baseLeveling_ruleTitle"),tabStr)
    end
    G_addMenuInfo(self.bgLayer,self.layerNum,ccp(G_VisibleSizeWidth - 80,self.bgLayer:getContentSize().height-190-20),{},nil,0.9,28,touchTip,true)
    
    self.mergeProLb = GetTTFLabel(getlocal("sw_add_prop_probability"),titLbSize)
    self.mergeProLb:setAnchorPoint(ccp(0,1))
    self.bgLayer:addChild(self.mergeProLb)
    self.mergeProLb:setVisible(false)
    self.mergeLb = GetTTFLabel("",titLbSize)
    self.mergeLb:setAnchorPoint(ccp(0,1))
    self.bgLayer:addChild(self.mergeLb)
    self.mergeLb:setVisible(true)
    self.mergeProLb:setPosition(ccp(self.bgLayer:getContentSize().width/2-(self.mergeProLb:getContentSize().width+self.mergeLb:getContentSize().width)/2,self.mergeProgressBar1Sp:getPositionY()-35-10))
    self.mergeLb:setPosition(ccp(self.mergeProLb:getPositionX()+self.mergeProLb:getContentSize().width,self.mergeProgressBar1Sp:getPositionY()-35-10))

    self.crystalMergeBg:setScale(0.8)

    -- 初始化融合材料
    local function touch( ... )
      -- body
    end
    local function deleteHandler1( ... )
        if self.isPlaying==true then
            return 
        end
        if self.selectedCrystalVO1 then
            self.selectedCrystalVO1=nil
            local oldIconSp=self.allCrystalIconSp[self.selectedCrystalIdx1]
            if oldIconSp then
                G_removeFlicker(oldIconSp)
            end
            self.selectedCrystalIdx1=0
            self:refreshSelectedCrystalInfo()
            -- self.deleteCrystalSp1:setVisible(false)

            if self.selectedCrystalIconSp1 then
                self.selectedCrystalIconSp1:removeFromParentAndCleanup(true)
                self.selectedCrystalIconSp1=nil
            end
        end
        if self.selectedCrystalNameLb1 then
            self.selectedCrystalNameLb1:setString(getlocal("sw_add_prop_1"))
        end
        if self.questionIcon1 then
            self.questionIcon1:setVisible(true)
        end
    end
    local function deleteHandler2( ... )
        if self.isPlaying==true then
            return
        end
        if self.selectedCrystalVO2 then
            self.selectedCrystalVO2=nil
            local oldIconSp=self.allCrystalIconSp[self.selectedCrystalIdx2]
            if oldIconSp then
                G_removeFlicker(oldIconSp)
            end
            self.selectedCrystalIdx2=0
            self:refreshSelectedCrystalInfo()
            -- self.deleteCrystalSp2:setVisible(false)

            if self.selectedCrystalIconSp2 then
                self.selectedCrystalIconSp2:removeFromParentAndCleanup(true)
                self.selectedCrystalIconSp2=nil
            end
        end
        if self.selectedCrystalNameLb2 then
            self.selectedCrystalNameLb2:setString(getlocal("sw_add_prop_2"))
        end
        if self.questionIcon2 then
            self.questionIcon2:setVisible(true)
        end
    end
    local spPosy=self.crystalMergeBg:getPositionY()+self.crystalMergeBg:getContentSize().height-200
    -- local selectedCrystalSp1 = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),deleteHandler1)
    local selectedCrystalSp1 = LuaCCSprite:createWithSpriteFrameName("dwGround1.png",deleteHandler1)
    -- selectedCrystalSp1:setContentSize(CCSizeMake(100,100))
    -- selectedCrystalSp1:setPosition(ccp(self.bgLayer:getContentSize().width-35,self.mergeProgressBar1Sp:getPositionY()+10))
    selectedCrystalSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2-200,spPosy+20))
    -- selectedCrystalSp1:setAnchorPoint(ccp(1,1))
    self.bgLayer:addChild(selectedCrystalSp1)
    selectedCrystalSp1:setTouchPriority(-(self.layerNum-1)*20-4)
    local questionIcon1=CCSprite:createWithSpriteFrameName("questionMarkIcon.png")
    questionIcon1:setPosition(getCenterPoint(selectedCrystalSp1))
    selectedCrystalSp1:addChild(questionIcon1)
    self.questionIcon1=questionIcon1

    self.arrowSp1=CCSprite:createWithSpriteFrameName("dwArrow.png")
    self.arrowSp1:setRotation(90)
    self.arrowSp1:setPosition(ccp(self.bgLayer:getContentSize().width/2-130,spPosy+20))
    self.bgLayer:addChild(self.arrowSp1)

    -- local selectedCrystalSp2 = LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",CCRect(20, 20, 10, 10),deleteHandler2)
    local selectedCrystalSp2 = LuaCCSprite:createWithSpriteFrameName("dwGround1.png",deleteHandler2)
    -- selectedCrystalSp2:setContentSize(CCSizeMake(100,100))
    -- selectedCrystalSp2:setPosition(ccp(self.bgLayer:getContentSize().width-35,self.mergeProgressBar1Sp:getPositionY()-selectedCrystalSp1:getContentSize().height))
    selectedCrystalSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2+200,spPosy+20))
    -- selectedCrystalSp2:setAnchorPoint(ccp(1,1))
    self.bgLayer:addChild(selectedCrystalSp2)
    selectedCrystalSp2:setTouchPriority(-(self.layerNum-1)*20-4)
    local questionIcon2=CCSprite:createWithSpriteFrameName("questionMarkIcon.png")
    questionIcon2:setPosition(getCenterPoint(selectedCrystalSp2))
    selectedCrystalSp2:addChild(questionIcon2)
    self.questionIcon2=questionIcon2

    self.arrowSp2=CCSprite:createWithSpriteFrameName("dwArrow.png")
    self.arrowSp2:setRotation(-90)
    self.arrowSp2:setPosition(ccp(self.bgLayer:getContentSize().width/2+130,spPosy+20))
    self.bgLayer:addChild(self.arrowSp2)


    local function addPropHandler( ... )
        if self.isPlaying==true then
            return
        end
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if self.selectedCrystalVO1 and self.selectedCrystalVO2 then

        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("no_crystal_prompt"),30)
            do return end
        end

        if self.propMaxNum<=0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("sw_fusion_not_need_prop"),30)
            do return end
        end
        local hasNum=0
        local item=superWeaponVoApi:getAddPerPropData()
        if item then
            hasNum=item.num or 0
        end
        if hasNum<=0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("sw_fusion_no_prop"),30)
            do return end
        end
        if self.selectedCrystalVO1 and self.selectedCrystalVO2 then
            local function addPropCallback(propNum)
                -- print("propNum",propNum)
                self.propNum=propNum
                self:refreshMergeProgressBar(true)
                if self.addPropBg then
                    local propIcon=tolua.cast(self.addPropBg:getChildByTag(121),"CCSprite")
                    local numLb=tolua.cast(self.addPropBg:getChildByTag(122),"CCLabelTTF")
                    local numBg=tolua.cast(self.addPropBg:getChildByTag(123),"LuaCCScale9Sprite")

                    if propNum and propNum>0 then
                        if propIcon then
                            propIcon:setVisible(true)
                        end
                        if numLb then
                            numLb:setVisible(true)
                            numLb:setString(self.propNum.."/"..self.propMaxNum)
                        end
                        if numBg then
                            numBg:setVisible(true)
                            numBg:setContentSize(CCSizeMake(math.max(40,numLb:getContentSize().width),math.min(40,numLb:getContentSize().height)))
                        end
                    else
                        if propIcon then
                            propIcon:setVisible(false)
                        end
                        if numLb then
                            numLb:setVisible(false)
                        end
                        if numBg then
                            numBg:setVisible(false)
                        end
                    end
                end
            end
            superWeaponVoApi:showAddPropSmallDialog(self.layerNum+1,self.propMaxNum,addPropCallback)
        end
    end

    -- 融合齿轮
    local addBgScale=0.8
    local addPropBg = LuaCCSprite:createWithSpriteFrameName("propIconBg.png",addPropHandler)
    -- addPropBg:setContentSize(CCSizeMake(80,80))
    addPropBg:setScale(addBgScale)
    addPropBg:setTouchPriority(-(self.layerNum-1)*20-4)
    addPropBg:setPosition(ccp(self.bgLayer:getContentSize().width/2-40,spPosy-130))
    self.bgLayer:addChild(addPropBg,1)
    self.addPropBg=addPropBg

    local function addProtectHandler( ... )

        if self.isPlaying==true then
            return
        end
        if G_checkClickEnable()==false then
            do
                return
            end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end
        PlayEffect(audioCfg.mouseClick)

        if self.selectedCrystalVO1 and self.selectedCrystalVO2 then
            if self.selectedCrystalVO1:getLevel() ~= self.selectedCrystalVO2:getLevel() then
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("protect_prop_prompt"),30)
                do return end
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("no_crystal_prompt"),30)
            do return end
        end

        if self.propMaxNum<=0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("sw_fusion_not_need_prop"),30)
            do return end
        end

        local hasNum=0
        local item=superWeaponVoApi:getProtetPropData()
        if item then
            hasNum=item.num or 0
        end
        if hasNum<=0 then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("sw_fusion_no_prop1"),30)
            do return end
        end
        

        if self.selectedCrystalVO1 and self.selectedCrystalVO2 then   
            local function addPropCallback(flag)
                self.isUseProtect = flag
                self:refreshMergeProgressBar(true)
                if self.addPropBg1 then
                    local propIcon1=tolua.cast(self.addPropBg1:getChildByTag(121),"CCSprite")
                    local numLb1=tolua.cast(self.addPropBg1:getChildByTag(122),"CCLabelTTF")
                    local numBg1=tolua.cast(self.addPropBg1:getChildByTag(123),"LuaCCScale9Sprite")
                    if propIcon1 then
                        if self.isUseProtect == 1 then
                            propIcon1:setVisible(true)
                            if numLb1 then
                                numLb1:setVisible(true)
                                numLb1:setString(tostring(1).."/"..tostring(1))
                            end
                            if numBg1 then
                                numBg1:setVisible(true)
                                numBg1:setContentSize(CCSizeMake(math.max(40,numLb1:getContentSize().width),math.min(40,numLb1:getContentSize().height)))
                            end
                        else
                            propIcon1:setVisible(false)
                            if numLb1 then
                                numLb1:setVisible(false)
                            end
                            if numBg1 then
                                numBg1:setVisible(false)
                            end
                        end
                        local mergeFailCrystalId = self.selectedCrystalVO2:getPreviousLevelId(self.isUseProtect)
                        local vo2 = superWeaponVoApi:getCrystalVoByCid(mergeFailCrystalId)
                        self.mergeFailCrystalVo=vo2
                    end
                end
            end
            superWeaponVoApi:showAddPropSmallDialog(self.layerNum+1,self.propMaxNum,addPropCallback,self.isUseProtect)
        end
    end
    local addPropBg1 = LuaCCSprite:createWithSpriteFrameName("propIconBg.png",addProtectHandler)
    addPropBg1:setScale(addBgScale)
    addPropBg1:setTouchPriority(-(self.layerNum-1)*20-4)
    addPropBg1:setPosition(ccp(self.bgLayer:getContentSize().width/2+40,spPosy-130))
    self.bgLayer:addChild(addPropBg1,1)
    self.addPropBg1=addPropBg1


    -- 加号
    local addSp = CCSprite:createWithSpriteFrameName("ProduceTankIconMore.png")
    addSp:setScale(1.8)
    addSp:setPosition(getCenterPoint(addPropBg))
    addPropBg:addChild(addSp)

    local addSp1 = CCSprite:createWithSpriteFrameName("ProduceTankIconMore.png")
    addSp1:setScale(1.8)
    addSp1:setPosition(getCenterPoint(addPropBg))
    addPropBg1:addChild(addSp1)

    -- 忽隐忽现
    local fade1 = CCFadeTo:create(0.8,55)
    local fade11 = CCFadeTo:create(0.8,55)
    local fade2 = CCFadeTo:create(0.8,255)
    local fade22= CCFadeTo:create(0.8,255)
    local seq = CCSequence:createWithTwoActions(fade1,fade2)
    local seq1 = CCSequence:createWithTwoActions(fade11,fade22)
    local repeatEver = CCRepeatForever:create(seq)
    local repeatEver1 = CCRepeatForever:create(seq1)

    addSp:runAction(repeatEver)
    addSp:setVisible(false)
    addSp:setTag(120)

    addSp1:runAction(repeatEver1)
    addSp1:setVisible(false)
    addSp1:setTag(120)

    local item=superWeaponVoApi:getAddPerPropData()
    local propIcon=CCSprite:createWithSpriteFrameName(item:getIcon())
    propIcon:setPosition(getCenterPoint(addPropBg))
    addPropBg:addChild(propIcon,2)
    propIcon:setVisible(false)
    propIcon:setTag(121)
    propIcon:setScale(70/propIcon:getContentSize().width)

    local item1=superWeaponVoApi:getProtetPropData()
    local propIcon1=CCSprite:createWithSpriteFrameName(item1:getIcon())
    propIcon1:setPosition(getCenterPoint(addPropBg1))
    addPropBg1:addChild(propIcon1,2)
    propIcon1:setVisible(false)
    propIcon1:setTag(121)
    propIcon1:setScale(70/propIcon1:getContentSize().width)

    -- 稳固齿轮的粒子动画
    local particleSp=G_playParticle(propIcon1,ccp(propIcon1:getContentSize().width/2,30),"public/chilun2.plist",nil,nil,nil,ccp(0.5,0),1,nil)
    local particleSp1=G_playParticle(propIcon1,ccp(propIcon1:getContentSize().width/2,30),"public/chilun3.plist",nil,nil,nil,ccp(0.5,0),1,nil)

    local numLb=GetTTFLabel("0/0",25)
    numLb:setAnchorPoint(ccp(0.5,1))
    numLb:setPosition(ccp(addPropBg:getContentSize().width/2,0))
    addPropBg:addChild(numLb,3)
    numLb:setVisible(false)
    numLb:setTag(122)


    local numLb1=GetTTFLabel("0/0",25)
    numLb1:setAnchorPoint(ccp(0.5,1))
    numLb1:setPosition(ccp(addPropBg:getContentSize().width/2,0))
    addPropBg1:addChild(numLb1,3)
    numLb1:setVisible(false)
    numLb1:setTag(122)



    local numBg=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    numBg:setAnchorPoint(ccp(0.5,1))
    numBg:setContentSize(CCSizeMake(math.max(40,numLb:getContentSize().width),math.min(40,numLb:getContentSize().height)))
    addPropBg:addChild(numBg,2)
    numBg:setPosition(ccp(addPropBg:getContentSize().width/2,0))
    numBg:setVisible(false)
    numBg:setTag(123)

    local numBg1=LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),function ()end)
    numBg1:setAnchorPoint(ccp(0.5,1))
    numBg1:setContentSize(CCSizeMake(math.max(40,numLb1:getContentSize().width),math.min(40,numLb1:getContentSize().height)))
    addPropBg1:addChild(numBg1,2)
    numBg1:setPosition(ccp(addPropBg:getContentSize().width/2,0))
    numBg1:setVisible(false)
    numBg1:setTag(123)

    if superWeaponVoApi:getShowTips()==nil then
        local popLb=GetTTFLabelWrap(getlocal("sw_add_prop_protect"),18,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        local function cellClick(hd,fn,idx)
        end
        local popBg=LuaCCScale9Sprite:createWithSpriteFrameName("equipBg_gray2.png",CCRect(20, 20, 1, 1),cellClick)
        popBg:setContentSize(CCSizeMake(popLb:getContentSize().width+10,popLb:getContentSize().height+10))
        popBg:ignoreAnchorPointForPosition(false)
        popBg:setAnchorPoint(ccp(0.5,0.5))
        popBg:setPosition(ccp(self.bgLayer:getContentSize().width/2,spPosy-130))
        self.bgLayer:addChild(popBg,5)
        popLb:setPosition(ccp(popBg:getContentSize().width/2,popBg:getContentSize().height/2))
        popBg:addChild(popLb,1)
        local function spCallBack( ... )
            if self and self.bgLayer and popBg then
                popBg:removeFromParentAndCleanup(true)
                popBg=nil
            end
        end
        local delay=CCDelayTime:create(5)
        local funcHandler=CCCallFunc:create(spCallBack)
        local seq=CCSequence:createWithTwoActions(delay,funcHandler)  
        popBg:runAction(seq)
        superWeaponVoApi:setShowTips(1)
    end

    -- local titLbSize =18
    -- if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" or G_getCurChoseLanguage() =="ja" then
    --     titLbSize =25
    -- end
    -- 第一个结晶
    -- local crystalTitle1=GetTTFLabel(getlocal("sw_add_prop_1"),titLbSize)
    -- crystalTitle1:setAnchorPoint(ccp(0,1))
    -- crystalTitle1:setPosition(ccp(20,selectedCrystalSp1:getContentSize().height-10))
    -- selectedCrystalSp1:addChild(crystalTitle1)
    -- crystalTitle1:setColor(G_ColorYellowPro)

    self.selectedCrystalNameLb1=GetTTFLabelWrap(getlocal("sw_add_prop_1"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.selectedCrystalNameLb1:setAnchorPoint(ccp(0.5,1))
    self.selectedCrystalNameLb1:setPosition(ccp(self.bgLayer:getContentSize().width/2-200,spPosy-30))
    self.bgLayer:addChild(self.selectedCrystalNameLb1)

    
    -- self.deleteCrystalSp1 = LuaCCSprite:createWithSpriteFrameName("IconFault.png",deleteHandler1)
    -- self.deleteCrystalSp1:setAnchorPoint(ccp(0.5,1))
    -- self.deleteCrystalSp1:setPosition(ccp(selectedCrystalSp1:getContentSize().width-5-self.deleteCrystalSp1:getContentSize().width,selectedCrystalSp1:getContentSize().height-5))
    -- selectedCrystalSp1:addChild(self.deleteCrystalSp1)
    -- self.deleteCrystalSp1:setTouchPriority(-(self.layerNum-1)*20-4)
    -- self.deleteCrystalSp1:setVisible(false)

    -- 第二个结晶
    -- local crystalTitle2=GetTTFLabel(getlocal("sw_add_prop_2"),titLbSize)
    -- crystalTitle2:setAnchorPoint(ccp(0,1))
    -- crystalTitle2:setPosition(ccp(20,selectedCrystalSp2:getContentSize().height-10))
    -- selectedCrystalSp2:addChild(crystalTitle2)
    -- crystalTitle2:setColor(G_ColorYellowPro)

    self.selectedCrystalNameLb2=GetTTFLabelWrap(getlocal("sw_add_prop_2"),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    self.selectedCrystalNameLb2:setAnchorPoint(ccp(0.5,1))
    self.selectedCrystalNameLb2:setPosition(ccp(self.bgLayer:getContentSize().width/2+200,spPosy-30))
    self.bgLayer:addChild(self.selectedCrystalNameLb2)
    
    -- self.deleteCrystalSp2 = LuaCCSprite:createWithSpriteFrameName("IconFault.png",deleteHandler2)
    -- self.deleteCrystalSp2:setAnchorPoint(ccp(0.5,1))
    -- self.deleteCrystalSp2:setPosition(ccp(selectedCrystalSp2:getContentSize().width-5-self.deleteCrystalSp1:getContentSize().width,selectedCrystalSp2:getContentSize().height-5))
    -- selectedCrystalSp2:addChild(self.deleteCrystalSp2)
    -- self.deleteCrystalSp2:setTouchPriority(-(self.layerNum-1)*20-4)
    -- self.deleteCrystalSp2:setVisible(false)
    
    -- 合成功后的结晶
    -- self.crystalTitle3=GetTTFLabel(getlocal("merge_title3"),titLbSize)
    -- self.crystalTitle3:setAnchorPoint(ccp(0,1))
    -- self.crystalTitle3:setPosition(ccp(20+selectedCrystalSp2:getPositionX()-selectedCrystalSp2:getContentSize().width,selectedCrystalSp2:getPositionY()-selectedCrystalSp2:getContentSize().height-10))
    -- self.bgLayer:addChild(self.crystalTitle3)
    -- self.crystalTitle3:setColor(G_ColorYellowPro)


    -- 初始化融合按钮，及融合动画
    local function mergeHandler( ... )
        if self.isPlaying==true then
            return
        end
        if self.selectedCrystalVO1 and self.selectedCrystalVO2 then
            local function callBack(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    self.isUseProtect = 0
                    if(sData.data.weapon)then
                        superWeaponVoApi:formatData(sData.data.weapon)
                    end
                    if sData.data and sData.data.flag then
                        -- if sData.data.flag==1 then--成功
                        --     local param = self.mergeSuccessCrystalVo:getNameAndLevel()
                        --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("merge_crystal_success",{param}),30)
                        -- else--失败
                        --     local param = self.selectedCrystalVO1:getNameAndLevel()..","..self.selectedCrystalVO2:getNameAndLevel()
                        --     smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("merge_crystal_fail",{param}),30)
                        -- end
                        self:playAction(sData.data.flag)
                        -- self:doUserHandler()
                        -- self.tv:reloadData()
                    end
                end
            end 
            if self.isUseProtect == 1 then
                socketHelper:mergeCrystal(self.selectedCrystalVO1.id,self.selectedCrystalVO2.id,callBack,self.propNum,"c201")
            else
                socketHelper:mergeCrystal(self.selectedCrystalVO1.id,self.selectedCrystalVO2.id,callBack,self.propNum)
            end
        else
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("select_need_merge_crystal"),30)
        end
    end
    
    local function mergeAllHandler( ... )
        if self.isPlaying==true then
            return
        end
        local function callback3( ... )
            self:refreshData()
        end 
        local list = superWeaponVoApi:getMergeAllListByType(tonumber(self.selectedTabIndex+1))
        smallDialog:showMergeAllCrystalDilaog(list,self.selectedTabIndex+1,self.layerNum+1,callback3)
        -- if SizeOfTable(list)>0 then
        -- else

        -- end
    end

    self.mergeBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",mergeHandler,11,getlocal("super_weapon_rob_upgrade_btn"),24/0.8,101)
    self.mergeBtn:setAnchorPoint(ccp(0.5,0))
    self.mergeBtn:setScale(0.8)
    local btnLb = self.mergeBtn:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    self.mergeBtnMenu=CCMenu:createWithItem(self.mergeBtn)
    self.mergeBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/4+15,31))
    -- self.mergeBtnMenu:setPosition(ccp(self.crystalMergeBg:getContentSize().width/2+15,self.crystalMergeBg:getPositionY()-self.crystalMergeBg:getContentSize().height+20))
    self.mergeBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(self.mergeBtnMenu,2)

    local mergeAllBtn=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",mergeAllHandler,11,getlocal("merge_all_btn"),24/0.8,101)
    mergeAllBtn:setAnchorPoint(ccp(0.5,0))
    mergeAllBtn:setScale(0.8)
    local btnLb = mergeAllBtn:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local mergeAllBtnMenu=CCMenu:createWithItem(mergeAllBtn)
    mergeAllBtnMenu:setPosition(ccp(self.bgLayer:getContentSize().width/4*3+15,31))
    mergeAllBtnMenu:setTouchPriority(-(self.layerNum-1)*20-4)
    self.bgLayer:addChild(mergeAllBtnMenu,2)
    
    -- 初始化材料仓库
    local rect = CCRect(0, 0, 50, 50);
    local capInSet = CCRect(20, 20, 10, 10);
    local function click(hd,fn,idx)
    end
    -- local tvH = self.crystalMergeBg:getPositionY()-self.crystalMergeBg:getContentSize().height-80-80
    local tvH = self.crystalMergeBg:getPositionY()-80-34--80
    -- self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("letterBgWrite.png",capInSet,click)
    self.tvBg =LuaCCScale9Sprite:createWithSpriteFrameName("btnPanelBg.png",CCRect(96, 70, 1, 1),click)
    self.tvBg:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-50,tvH))
    self.tvBg:ignoreAnchorPointForPosition(false)
    self.tvBg:setAnchorPoint(ccp(0.5,0))
    self.tvBg:setPosition(ccp(G_VisibleSizeWidth/2,30+80))
    self.bgLayer:addChild(self.tvBg)


    self:doUserHandler()

    local function callBack2(handler,fn,idx,cell)
       return self:eventHandler(handler,fn,idx,cell)
    end
    local hd= LuaEventHandler:createHandler(callBack2)
    self.tv=LuaCCTableView:createWithEventHandler(hd,CCSizeMake(self.bgLayer:getContentSize().width-60,tvH-20-40),nil)
    -- self.bgLayer:setTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setTableViewTouchPriority(-(self.layerNum-1)*20-2)
    self.tv:setPosition(ccp(0,10))
    self.tv:setAnchorPoint(ccp(0,0))
    self.tvBg:addChild(self.tv)

    self:resetTab()
end

function energyCrystalTab2Dialog:playAction(flag)

    if self.crystalMergeBg1 and self.crystalMergeFireBg then
        self.isPlaying=true
        local pzArr1=CCArray:create()

        for kk=0,9,1 do
            local nameStr1="crystalMergeBg000"..kk..".png"
            local frame1 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr1)
            -- frame1:setScale(2)
            pzArr1:addObject(frame1)
        end
        
        local animation1=CCAnimation:createWithSpriteFrames(pzArr1)
        animation1:setDelayPerUnit(0.07)
        local animate1=CCAnimate:create(animation1)
        local repeatForever1=CCRepeatForever:create(animate1)
        self.crystalMergeBg1:runAction(repeatForever1)

        local pzArr2=CCArray:create()

        for kk=0,9,1 do
            local nameStr2="crystalMergeFire000"..kk..".png"
            local frame2 = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr2)
            -- frame2:setScale(2)
            pzArr2:addObject(frame2)
        end

        local animation2=CCAnimation:createWithSpriteFrames(pzArr2)
        animation2:setDelayPerUnit(0.07)
        local animate2=CCAnimate:create(animation2)
        local repeatForever2=CCRepeatForever:create(animate2)
        self.crystalMergeFireBg:runAction(repeatForever2)
    end
    

    if self.selectedCrystalIconSp1 and self.selectedCrystalIconSp2 then
        -- local nameLb1=tolua.cast(self.selectedCrystalIconSp1:getChildByTag(101),"CCLabelTTF")
        local lvLb1=tolua.cast(self.selectedCrystalIconSp1:getChildByTag(102),"CCLabelTTF")
        -- local nameLb2=tolua.cast(self.selectedCrystalIconSp2:getChildByTag(101),"CCLabelTTF")
        local lvLb2=tolua.cast(self.selectedCrystalIconSp2:getChildByTag(102),"CCLabelTTF")
        -- if nameLb1 then
        --     nameLb1:setVisible(false)
        -- end
        if lvLb1 then
            lvLb1:setVisible(false)
        end
        -- if nameLb2 then
        --     nameLb2:setVisible(false)
        -- end
        if lvLb2 then
            lvLb2:setVisible(false)
        end
        self.selectedCrystalNameLb1:setString("")
        self.selectedCrystalNameLb2:setString("")

        local mvTo1=CCMoveTo:create(1.5,self.centerPos)
         local function spCallBack1()
            self.selectedCrystalIconSp1:stopAllActions()
            self.selectedCrystalIconSp1:removeFromParentAndCleanup(true)
            self.selectedCrystalIconSp1=nil
            
            self.crystalMergeBg1:stopAllActions()
            self.crystalMergeFireBg:stopAllActions()
            self.isPlaying=false

            local function touchNil( ... )
            end
            if flag==1 then--成功
                -- local param = self.mergeSuccessCrystalVo:getNameAndLevel()
                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("merge_crystal_success",{param}),30)
                local tmpVo=G_clone(self.mergeSuccessCrystalVo)
                local function clickIconHandler( ... )
                    smallDialog:showCrystalInfoDilaog(tmpVo:getNameAndLevel(),tmpVo:getIconSp(),tmpVo:getAtt(),self.layerNum+2,-1,nil,tmpVo:getLevel())
                end
                self:showMergeSuccessDialog(self.mergeSuccessCrystalVo:getLocalName(),self.mergeSuccessCrystalVo:getLevel(),self.mergeSuccessCrystalVo:getIconSp(clickIconHandler),self.layerNum+1)
            else--失败
                -- local param = self.mergeFailCrystalVo:getNameAndLevel()
                -- smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("merge_crystal_fail",{param}),30)
                local tmpVo=G_clone(self.mergeFailCrystalVo)
                local function clickIconHandler1( ... )
                    smallDialog:showCrystalInfoDilaog(tmpVo:getNameAndLevel(),tmpVo:getIconSp(),tmpVo:getAtt(),self.layerNum+2,-1,nil,tmpVo:getLevel())
                end
                self:showMergeSuccessDialog(self.mergeFailCrystalVo:getLocalName(),self.mergeFailCrystalVo:getLevel(),self.mergeFailCrystalVo:getIconSp(clickIconHandler1),self.layerNum+1,true)
            end
            self:doUserHandler()
            self.tv:reloadData()

            if self.arrowSp1 then
                self.arrowSp1:setVisible(true)
            end
            if self.arrowSp2 then
                self.arrowSp2:setVisible(true)
            end
            if self.selectedCrystalNameLb1 then
                self.selectedCrystalNameLb1:setString(getlocal("sw_add_prop_1"))
            end
            if self.selectedCrystalNameLb2 then
                self.selectedCrystalNameLb2:setString(getlocal("sw_add_prop_2"))
            end
            if self.questionIcon1 then
                self.questionIcon1:setVisible(true)
            end
            if self.questionIcon2 then
                self.questionIcon2:setVisible(true)
            end
        end
        local funcHandler1=CCCallFunc:create(spCallBack1)
        local seq1=CCSequence:createWithTwoActions(mvTo1,funcHandler1)  
        self.selectedCrystalIconSp1:runAction(seq1) 

        local mvTo2=CCMoveTo:create(1.5,self.centerPos)
         local function spCallBack2()
            self.selectedCrystalIconSp2:stopAllActions()
            self.selectedCrystalIconSp2:removeFromParentAndCleanup(true)
            self.selectedCrystalIconSp2=nil
         end
        local funcHandler2=CCCallFunc:create(spCallBack2)
        local seq2=CCSequence:createWithTwoActions(mvTo2,funcHandler2)  
        self.selectedCrystalIconSp2:runAction(seq2)
        
        if self.arrowSp1 then
            self.arrowSp1:setVisible(false)
        end
        if self.arrowSp2 then
            self.arrowSp2:setVisible(false)
        end
        if self.mergeSuccessIconSp then
            self.mergeSuccessIconSp:removeFromParentAndCleanup(true)
            self.mergeSuccessIconSp=nil
        end
    end
end

function energyCrystalTab2Dialog:showMergeSuccessDialog(name,level,iconSp,layerNum,isFail)

    local function touchHandler()
        if self.tipLayer then
            self.tipLayer:removeFromParentAndCleanup(true)
            self.tipLayer=nil
        end
    end
    self.tipLayer = CCLayer:create()
    self.tipLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.tipLayer:setBSwallowsTouches(true);
    -- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",CCRect(130, 50, 1, 1),touchHandler)
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg1.png",CCRect(30, 30, 1, 1),function ()end)
    dialogBg:setTouchPriority(-(layerNum-1)*20-2)
    local dialogBgWidth=600
    local descLb = GetTTFLabelWrap(getlocal("you_get_title"),25,CCSizeMake(dialogBgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    if isFail==true then
        descLb = GetTTFLabelWrap(getlocal("sw_add_prop_return"),25,CCSizeMake(dialogBgWidth-60,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    end
    dialogBg:setContentSize(CCSizeMake(dialogBgWidth,descLb:getContentSize().height+200))
    dialogBg:setAnchorPoint(ccp(0.5,0.5))
    dialogBg:setPosition(ccp(G_VisibleSizeWidth/2,G_VisibleSizeHeight/2))
    self.tipLayer:addChild(dialogBg,2)
    local dialogBg2 = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg2.png",CCRect(20, 20, 1, 1),function ()end)
    dialogBg2:setContentSize(CCSizeMake(dialogBg:getContentSize().width-40,dialogBg:getContentSize().height-40))
    dialogBg2:setPosition(getCenterPoint(dialogBg))
    dialogBg:addChild(dialogBg2)
    local lineSp1=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp1:setAnchorPoint(ccp(0.5,1))
    lineSp1:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height))
    dialogBg:addChild(lineSp1)
    local lineSp2=CCSprite:createWithSpriteFrameName("rewardPanelLine.png")
    lineSp2:setAnchorPoint(ccp(0.5,0))
    lineSp2:setPosition(ccp(dialogBg:getContentSize().width/2,lineSp2:getContentSize().height))
    dialogBg:addChild(lineSp2)
    lineSp2:setRotation(180)
    local pointSp1=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp1:setPosition(ccp(5,dialogBg:getContentSize().height/2))
    dialogBg:addChild(pointSp1)
    local pointSp2=CCSprite:createWithSpriteFrameName("pointThree.png")
    pointSp2:setPosition(ccp(dialogBg:getContentSize().width-5,dialogBg:getContentSize().height/2))
    dialogBg:addChild(pointSp2)

    local titlePos=dialogBg:getContentSize().height+40
    local titleLb = GetTTFLabel(getlocal("merge_success_title"),35)
    titleLb:setColor(G_ColorYellow)
    if isFail==true then
        titleLb = GetTTFLabel(getlocal("merge_all_fail"),35)
        -- titleLb:setColor(G_ColorGray)
    end
    titleLb:setPosition(ccp(dialogBg:getContentSize().width/2,titlePos+20))
    dialogBg:addChild(titleLb,1)
    
    local tmpBg
    if isFail==true then
        tmpBg=CCSprite:createWithSpriteFrameName("rewardPanelFailBg.png")
    else
        tmpBg=CCSprite:createWithSpriteFrameName("rewardPanelSuccessBg.png")
    end
    local originalWidth=tmpBg:getContentSize().width
    local titleBgWidth=titleLb:getContentSize().width+260
    if titleBgWidth<originalWidth then
        titleBgWidth=originalWidth
    end
    if titleBgWidth>(G_VisibleSizeWidth) then
        titleBgWidth=G_VisibleSizeWidth
    end
    local rewardTitleBg
    if isFail==true then
        rewardTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelFailBg.png",CCRect(originalWidth/2, 20, 1, 1),function ()end)
    else
        rewardTitleBg=LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelSuccessBg.png",CCRect(originalWidth/2, 20, 1, 1),function ()end)
    end
    rewardTitleBg:setContentSize(CCSizeMake(titleBgWidth,tmpBg:getContentSize().height))
    rewardTitleBg:setPosition(ccp(dialogBg:getContentSize().width/2,titlePos))
    dialogBg:addChild(rewardTitleBg)
    local rewardTitleLineSp
    if isFail==true then
        rewardTitleLineSp=CCSprite:createWithSpriteFrameName("rewardPanelFailLight.png")
    else
        rewardTitleLineSp=CCSprite:createWithSpriteFrameName("rewardPanelSuccessLight.png")
    end 
    rewardTitleLineSp:setPosition(ccp(dialogBg:getContentSize().width/2,titlePos))
    dialogBg:addChild(rewardTitleLineSp)

    local clickLbPosy=-80
    local tmpLb=GetTTFLabel(getlocal("click_screen_continue"),25)
    local clickLb=GetTTFLabelWrap(getlocal("click_screen_continue"),25,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    clickLb:setPosition(ccp(dialogBg:getContentSize().width/2,clickLbPosy))
    dialogBg:addChild(clickLb)
    local arrowPosx1,arrowPosx2
    local realWidth,maxWidth=tmpLb:getContentSize().width,clickLb:getContentSize().width
    if realWidth>maxWidth then
        arrowPosx1=dialogBg:getContentSize().width/2-maxWidth/2
        arrowPosx2=dialogBg:getContentSize().width/2+maxWidth/2
    else
        arrowPosx1=dialogBg:getContentSize().width/2-realWidth/2
        arrowPosx2=dialogBg:getContentSize().width/2+realWidth/2
    end
    local smallArrowSp1=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp1:setPosition(ccp(arrowPosx1-15,clickLbPosy))
    dialogBg:addChild(smallArrowSp1)
    local smallArrowSp2=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp2:setPosition(ccp(arrowPosx1-25,clickLbPosy))
    dialogBg:addChild(smallArrowSp2)
    smallArrowSp2:setOpacity(100)
    local smallArrowSp3=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp3:setPosition(ccp(arrowPosx2+15,clickLbPosy))
    dialogBg:addChild(smallArrowSp3)
    smallArrowSp3:setRotation(180)
    local smallArrowSp4=CCSprite:createWithSpriteFrameName("smallGreenArrow.png")
    smallArrowSp4:setPosition(ccp(arrowPosx2+25,clickLbPosy))
    dialogBg:addChild(smallArrowSp4)
    smallArrowSp4:setOpacity(100)
    smallArrowSp4:setRotation(180)

    local space=20
    smallArrowSp1:runAction(G_actionArrow(1,space))
    smallArrowSp2:runAction(G_actionArrow(1,space))
    smallArrowSp3:runAction(G_actionArrow(-1,space))
    smallArrowSp4:runAction(G_actionArrow(-1,space))

    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchHandler);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    -- touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.tipLayer))
    self.tipLayer:addChild(touchDialogBg,1)

    -- local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",touchHandler,nil,nil,nil);
    -- closeBtnItem:setPosition(0, 0)
    -- closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    -- local closeBtn = CCMenu:createWithItem(closeBtnItem)
    -- closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    -- closeBtn:setPosition(ccp(dialogBg:getContentSize().width-closeBtnItem:getContentSize().width-5,dialogBg:getContentSize().height-closeBtnItem:getContentSize().height-5))
    -- dialogBg:addChild(closeBtn)

    -- local titleLb = GetTTFLabel(getlocal("merge_success_title"),28)
    -- titleLb:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height+40))
    -- dialogBg:addChild(titleLb)

    descLb:setColor(G_ColorYellowPro)
    if isFail==true then
        descLb:setColor(G_ColorRed)
    end
    descLb:setAnchorPoint(ccp(0,1))
    descLb:setPosition(ccp(30,dialogBg:getContentSize().height-30))
    dialogBg:addChild(descLb)
    
    iconSp:setPosition(ccp(dialogBg:getContentSize().width/2,dialogBg:getContentSize().height-descLb:getContentSize().height-85))
    iconSp:setTouchPriority(-(layerNum-1)*20-4)
    dialogBg:addChild(iconSp)

    local levelLb = GetTTFLabel(getlocal("fightLevel",{level}),22)
    levelLb:setAnchorPoint(ccp(0.5,0))
    levelLb:setPosition(ccp(iconSp:getContentSize().width/2,5))
    iconSp:addChild(levelLb)

    local nameLb = GetTTFLabel(name,25)
    nameLb:setAnchorPoint(ccp(0.5,1))
    nameLb:setPosition(ccp(dialogBg:getContentSize().width/2,iconSp:getPositionY()-iconSp:getContentSize().height/2-10))
    dialogBg:addChild(nameLb)

    sceneGame:addChild(self.tipLayer,layerNum)
end


-- 刷新各种状态
function energyCrystalTab2Dialog:refreshSelectedCrystalInfo()
    -- if self.selectedCrystalVO1 then
    --     self.selectedCrystalNameLb1:setString(self.selectedCrystalVO1:getNameAndLevel())
    --     self.deleteCrystalSp1:setVisible(true)
    -- else
    --     self.selectedCrystalNameLb1:setString(getlocal("alliance_info_content"))
    --     self.deleteCrystalSp1:setVisible(false)
    -- end
    -- if self.selectedCrystalVO2 then
    --     self.selectedCrystalNameLb2:setString(self.selectedCrystalVO2:getNameAndLevel())
    --     self.deleteCrystalSp2:setVisible(true)
    -- else
    --     self.selectedCrystalNameLb2:setString(getlocal("alliance_info_content"))
    --     self.deleteCrystalSp2:setVisible(false)
    -- end

    if self.selectedCrystalVO1 and self.selectedCrystalVO2 then
        local mergeSuccessCrystalId = ""
        local mergeFailCrystalId = ""
        if self.selectedCrystalVO1:getLevel()>self.selectedCrystalVO2:getLevel() then
            mergeSuccessCrystalId=self.selectedCrystalVO1:getNextLevelId()
            mergeFailCrystalId=self.selectedCrystalVO1:getPreviousLevelId(self.isUseProtect)
        else
            mergeSuccessCrystalId=self.selectedCrystalVO2:getNextLevelId()
            mergeFailCrystalId=self.selectedCrystalVO2:getPreviousLevelId(self.isUseProtect)
        end
        local vo = superWeaponVoApi:getCrystalVoByCid(mergeSuccessCrystalId)
        local vo2 = superWeaponVoApi:getCrystalVoByCid(mergeFailCrystalId)
        self.mergeSuccessCrystalVo=vo
        self.mergeFailCrystalVo=vo2
        local function showTip( ... )
            if vo then
                smallDialog:showCrystalInfoDilaog(vo:getNameAndLevel(),vo:getIconSp(touch),vo:getAtt(),self.layerNum+1,-1,nil,vo:getLevel())
            end
        end
        local spScale=1.2
        -- local successIconSp=vo:getIconSp(showTip)
        local successIconSp=LuaCCSprite:createWithSpriteFrameName(vo:getIcon(),showTip)
        successIconSp:setAnchorPoint(ccp(0.5,0.5))
        -- successIconSp:setPosition(ccp(self.bgLayer:getContentSize().width-150,self.crystalTitle3:getPositionY()-self.crystalTitle3:getContentSize().height-10))
        successIconSp:setPosition(ccp(self.bgLayer:getContentSize().width/2,self.crystalMergeBg:getPositionY()+self.crystalMergeBg:getContentSize().height-200))
        successIconSp:setTouchPriority(-(self.layerNum-1)*20-4)
        self.bgLayer:addChild(successIconSp,2)
        successIconSp:setScale(spScale)
        -- 等级
        local levelLb=GetTTFLabel(tostring(vo:getLevelStr()),25)
        levelLb:setPosition(ccp(successIconSp:getContentSize().width/2,successIconSp:getContentSize().height-5))
        levelLb:setAnchorPoint(ccp(0.5,0.5));
        successIconSp:addChild(levelLb)
        levelLb:setScale(1/spScale)
        -- 数量
        -- local numLb=GetTTFLabel(tostring(vo:getNumStr()),20)
        -- numLb:setPosition(ccp(successIconSp:getContentSize().width-5,5))
        -- numLb:setAnchorPoint(ccp(1,0));
        -- successIconSp:addChild(numLb)
        -- numLb:setScale(1/spScale)
        self.mergeSuccessIconSp=successIconSp
        self:refreshMergeProgressBar(true)
    else
        -- self.selectedCrystalNameLb3:setString(getlocal("alliance_info_content"))
        if self.mergeSuccessIconSp then
            self.mergeSuccessIconSp:removeFromParentAndCleanup(true)
            self.mergeSuccessIconSp=nil
        end
        self:refreshMergeProgressBar(false)
    end

    if self.selectedCrystalVO1==nil and self.selectedCrystalVO2==nil then
        for k,v in pairs(self.allCrystalIconSp) do
            if v then
                local maskSp = tolua.cast(v:getChildByTag(1001),"CCSprite")
                if maskSp then
                    maskSp:setVisible(false)
                end
            end
        end
        
    else
        for k,v in pairs(self.allCrystalIconSp) do
            if v then
                local tag = v:getTag()
                local form = 0
                if self.selectedCrystalVO1 then
                    form=self.selectedCrystalVO1:getForm()
                elseif self.selectedCrystalVO2 then
                    form=self.selectedCrystalVO2:getForm()
                end
                
                local maskSp = tolua.cast(v:getChildByTag(1001),"CCSprite")
                if maskSp then
                    if self.crystalList and self.crystalList[tag] and self.crystalList[tag]:getForm()==form then
                        maskSp:setVisible(false)
                    else
                        maskSp:setVisible(true)
                    end  
                end
            end
        end
    end
end


-- function energyCrystalTab2Dialog:refresh( ... )
--     -- body
-- end

-- 刷新融合成功率
function energyCrystalTab2Dialog:refreshMergeProgressBar(isShow)
    if self.mergeProgressBar1Sp then
        for i=1,10 do
            local smallSP=tolua.cast(self.mergeProgressBar1Sp:getChildByTag(i),"CCSprite")
            if smallSP then
                smallSP:setVisible(false)
            end
        end
        self.mergeProgressBar1Sp:setOpacity(128)
    end
    if isShow==true then
        local precent,precentName,basePrecent,addPrecent,lbColor,propMaxNum,mergeLv = superWeaponVoApi:getMergePrecent(self.selectedCrystalVO1.id,self.selectedCrystalVO2.id,self.propNum)
        self.propMaxNum=propMaxNum
        if mergeLv and superWeaponCfg and superWeaponCfg.numLimit and superWeaponCfg.numLimit[mergeLv] then
            if self.propMaxNum>superWeaponCfg.numLimit[mergeLv] then
                self.propMaxNum=superWeaponCfg.numLimit[mergeLv]
            end
        end
        if self.mergeProgressBar1Sp then
            local num = math.floor(self.mergeProgressBar1Sp:getContentSize().height*basePrecent/23)
            local num2 = math.floor(self.mergeProgressBar1Sp:getContentSize().height*addPrecent/23)
            if (num+num2)>0 then
                self.mergeProgressBar1Sp:setOpacity(255)
            else -- 最低显示一格
                num=1
                self.mergeProgressBar1Sp:setOpacity(255)
            end
            for i=1,(num+num2) do
                local smallSP=tolua.cast(self.mergeProgressBar1Sp:getChildByTag(i),"CCSprite")
                if smallSP then
                    smallSP:setVisible(true)
                    smallSP:stopAllActions()
                    smallSP:setOpacity(255)
                    if i>num then
                        local fade1 = CCFadeTo:create(0.5,55)
                        local fade2 = CCFadeTo:create(0.5,255)
                        local seq = CCSequence:createWithTwoActions(fade1,fade2)
                        local repeatEver = CCRepeatForever:create(seq)
                        smallSP:runAction(repeatEver)
                    end
                else
                    smallSP = CCSprite:createWithSpriteFrameName("mergeProgressBar2.png")
                    smallSP:setAnchorPoint(ccp(0.5,0))
                    smallSP:setTag(i)
                    smallSP:setPosition(ccp(self.mergeProgressBar1Sp:getContentSize().width/2,23*(i-1)+10))
                    self.mergeProgressBar1Sp:addChild(smallSP)
                    if i>num then
                        local fade1 = CCFadeTo:create(0.5,55)
                        local fade2 = CCFadeTo:create(0.5,255)
                        local seq = CCSequence:createWithTwoActions(fade1,fade2)
                        local repeatEver = CCRepeatForever:create(seq)
                        smallSP:runAction(repeatEver)
                    end
                end
            end
        end
        if self.mergeProLb and self.mergeLb and self.mergeProgressBar1Sp then
            self.mergeLb:setString(math.floor(precent*100) .. "%")
            self.mergeProLb:setVisible(true)
            self.mergeLb:setVisible(true)
            self.mergeProLb:setPosition(ccp(self.bgLayer:getContentSize().width/2-(self.mergeProLb:getContentSize().width+self.mergeLb:getContentSize().width)/2,self.mergeProgressBar1Sp:getPositionY()-35-10))
            self.mergeLb:setPosition(ccp(self.mergeProLb:getPositionX()+self.mergeProLb:getContentSize().width,self.mergeProgressBar1Sp:getPositionY()-35-10))
            self.mergeLb:setColor(lbColor)
        end
        if self.addPropBg then
            local addSp=tolua.cast(self.addPropBg:getChildByTag(120),"CCSprite")
            if addSp then
                addSp:setVisible(false)
                if self.propMaxNum>0 then
                    local hasNum=0
                    local item=superWeaponVoApi:getAddPerPropData()
                    if item then
                        hasNum=item.num or 0
                    end
                    if hasNum and hasNum>0 then
                        addSp:setVisible(true)
                    end
                end
            end
        
            if self.propNum>0 then
                local propIcon=tolua.cast(self.addPropBg:getChildByTag(121),"CCSprite")
                local numLb=tolua.cast(self.addPropBg:getChildByTag(122),"CCLabelTTF")
                local numBg=tolua.cast(self.addPropBg:getChildByTag(123),"LuaCCScale9Sprite")
                if propIcon then
                    propIcon:setVisible(true)
                end
                if addSp then
                    addSp:setVisible(false)
                end
                if numLb then
                    numLb:setVisible(true)
                    numLb:setString(self.propNum.."/"..self.propMaxNum)
                end
                if numBg then
                    numBg:setVisible(true)
                    numBg:setContentSize(CCSizeMake(math.max(40,numLb:getContentSize().width),math.min(40,numLb:getContentSize().height)))
                end
            end
        end
        if self.addPropBg1 then
            local addSp1=tolua.cast(self.addPropBg1:getChildByTag(120),"CCSprite")
            if addSp1 then
                addSp1:setVisible(false)
                if self.propMaxNum>0 then
                    local hasNum1=0
                    local item1=superWeaponVoApi:getProtetPropData()
                    if item1 then
                        hasNum1=item1.num or 0
                    end
                    if self.selectedCrystalVO1 and self.selectedCrystalVO2 then
                        if hasNum1 and hasNum1>0 and self.selectedCrystalVO1:getLevel() == self.selectedCrystalVO2:getLevel() then
                            addSp1:setVisible(true)
                        end
                    end
                end
            end
            if self.isUseProtect == 1 then
                local propIcon1=tolua.cast(self.addPropBg1:getChildByTag(121),"CCSprite")
                local numLb1=tolua.cast(self.addPropBg1:getChildByTag(122),"CCLabelTTF")
                local numBg1=tolua.cast(self.addPropBg1:getChildByTag(123),"LuaCCScale9Sprite")
                if propIcon1 then
                    propIcon1:setVisible(true)
                end
                if addSp1 then
                    addSp1:setVisible(false)
                end
                if numLb1 then
                    numLb1:setVisible(true)
                    numLb1:setString(tostring(1).."/"..tostring(1))
                end
                if numBg1 then
                    numBg1:setVisible(true)
                    numBg1:setContentSize(CCSizeMake(math.max(40,numLb1:getContentSize().width),math.min(40,numLb1:getContentSize().height)))
                end
            end
        end
    else
        self.propNum=0
        self.isUseProtect=nil
        if self.mergeProLb then
            self.mergeProLb:setVisible(false)
        end
        if self.mergeLb then
            self.mergeLb:setVisible(false)
        end
        if self.addPropBg then
            local addSp=tolua.cast(self.addPropBg:getChildByTag(120),"CCSprite")
            if addSp then
                addSp:setVisible(false)
            end
            local propIcon=tolua.cast(self.addPropBg:getChildByTag(121),"CCSprite")
            local numLb=tolua.cast(self.addPropBg:getChildByTag(122),"CCLabelTTF")
            local numBg=tolua.cast(self.addPropBg:getChildByTag(123),"LuaCCScale9Sprite")
            if propIcon then
                propIcon:setVisible(false)
            end
            if numLb then
                numLb:setVisible(false)
            end
            if numBg then
                numBg:setVisible(false)
                numBg:setContentSize(CCSizeMake(math.max(40,numLb:getContentSize().width),math.min(40,numLb:getContentSize().height)))
            end
        end
        if self.addPropBg1 then
            local addSp1=tolua.cast(self.addPropBg1:getChildByTag(120),"CCSprite")
            if addSp1 then
                addSp1:setVisible(false)
            end
            local propIcon1=tolua.cast(self.addPropBg1:getChildByTag(121),"CCSprite")
            local numLb1=tolua.cast(self.addPropBg1:getChildByTag(122),"CCLabelTTF")
            local numBg1=tolua.cast(self.addPropBg1:getChildByTag(123),"LuaCCScale9Sprite")
            if propIcon1 then
                propIcon1:setVisible(false)
            end
            if numLb1 then
                numLb1:setVisible(false)
            end
            if numBg1 then
                numBg1:setVisible(false)
                numBg1:setContentSize(CCSizeMake(math.max(40,numLb1:getContentSize().width),math.min(40,numLb1:getContentSize().height)))
            end
        end
    end
    
end

function energyCrystalTab2Dialog:eventHandler(handler,fn,idx,cel)
    if fn=="numberOfCellsInTableView" then
        local num = math.ceil(SizeOfTable(self.crystalList)/self.showCrystalNum)
        return num
    elseif fn=="tableCellSizeForIndex" then
        local tmpSize=CCSizeMake(110,110)
        return tmpSize
    elseif fn=="tableCellAtIndex" then
        local cell=CCTableViewCell:new()
        cell:autorelease()
        local num = self.showCrystalNum
        if (idx+1)==math.ceil(SizeOfTable(self.crystalList)/self.showCrystalNum) then
            num=SizeOfTable(self.crystalList)%self.showCrystalNum
            if num == 0 then
                num = self.showCrystalNum
            end
        end
        for i=1,(num) do
            local crystalVO = self.crystalList[idx*self.showCrystalNum+i]
            if crystalVO then
                local function selectedIcon(hd,fn,idx)
                    if self.isPlaying==true then
                        return 
                    end
                    if G_checkClickEnable()==false then
                        do
                            return
                        end
                    else
                        base.setWaitTime=G_getCurDeviceMillTime()
                    end
                    if self and self.tv and self.tv:getScrollEnable()==true and self.tv:getIsScrolled()==false then

                        if crystalVO and crystalVO:getLevel()>=superWeaponVoApi:getCrystalMaxLevel() then
                            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage17011"),30)
                            return
                        end
                        local function callback1( ... )
                            local newIconSp=self.allCrystalIconSp[idx]
                            self.selectedCrystalVO1=crystalVO
                            self:refreshSelectedCrystalInfo()
                            G_addRectFlicker(newIconSp,1.4,1.4)
                            self.selectedCrystalIdx1=idx

                            if self.selectedCrystalIconSp1 then
                                self.selectedCrystalIconSp1:removeFromParentAndCleanup(true)
                                self.selectedCrystalIconSp1=nil
                            end
                            self.selectedCrystalIconSp1=CCSprite:createWithSpriteFrameName(crystalVO:getIcon())
                            self.selectedCrystalIconSp1:setPosition(self.selectedCrystalIconPos1)
                            -- self.selectedCrystalIconSp1:setRotation(30)
                            self.crystalMergeBg:addChild(self.selectedCrystalIconSp1,4)
                            -- self.selectedCrystalIconSp1:setScale(0.7)

                            self.selectedCrystalNameLb1:setString(self.selectedCrystalVO1:getLocalName())
                            -- local nameLb=GetTTFLabelWrap(self.selectedCrystalVO1:getLocalName(),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                            -- nameLb:setAnchorPoint(ccp(0.5,1))
                            -- nameLb:setPosition(ccp(self.selectedCrystalIconSp1:getContentSize().width/2,-10))
                            -- self.selectedCrystalIconSp1:addChild(nameLb,2)
                            -- nameLb:setTag(101)
                            local lvLb=GetTTFLabel(self.selectedCrystalVO1:getLevelStr(),28)
                            lvLb:setAnchorPoint(ccp(0.5,1))
                            lvLb:setPosition(ccp(self.selectedCrystalIconSp1:getContentSize().width/2,-17-self.selectedCrystalNameLb1:getContentSize().height))
                            self.selectedCrystalIconSp1:addChild(lvLb,2)
                            lvLb:setTag(102)
                            if self.questionIcon1 then
                                self.questionIcon1:setVisible(false)
                            end
                        end
                        local function callback2( ... )
                            local newIconSp=self.allCrystalIconSp[idx]
                            self.selectedCrystalVO2=crystalVO
                            self:refreshSelectedCrystalInfo()
                            
                            G_addRectFlicker(newIconSp,1.4,1.4)
                            self.selectedCrystalIdx2=idx

                            if self.selectedCrystalIconSp2 then
                                self.selectedCrystalIconSp2:removeFromParentAndCleanup(true)
                                self.selectedCrystalIconSp2=nil
                            end
                            self.selectedCrystalIconSp2=CCSprite:createWithSpriteFrameName(crystalVO:getIcon())
                            self.selectedCrystalIconSp2:setPosition(self.selectedCrystalIconPos2)
                            -- self.selectedCrystalIconSp2:setRotation(-30)
                            self.crystalMergeBg:addChild(self.selectedCrystalIconSp2,4)
                            -- self.selectedCrystalIconSp2:setScale(0.7)

                            self.selectedCrystalNameLb2:setString(self.selectedCrystalVO2:getLocalName())
                            -- local nameLb=GetTTFLabelWrap(self.selectedCrystalVO2:getNameAndLevel(),25,CCSizeMake(200,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
                            -- nameLb:setAnchorPoint(ccp(0.5,1))
                            -- nameLb:setPosition(ccp(self.selectedCrystalIconSp2:getContentSize().width/2,-10))
                            -- self.selectedCrystalIconSp2:addChild(nameLb,2)
                            -- nameLb:setTag(101)
                            local lvLb=GetTTFLabel(self.selectedCrystalVO2:getLevelStr(),28)
                            lvLb:setAnchorPoint(ccp(0.5,1))
                            lvLb:setPosition(ccp(self.selectedCrystalIconSp2:getContentSize().width/2,-17-self.selectedCrystalNameLb2:getContentSize().height))
                            self.selectedCrystalIconSp2:addChild(lvLb,2)
                            lvLb:setTag(102)
                            if self.questionIcon2 then
                                self.questionIcon2:setVisible(false)
                            end
                        end
                        if self.selectedCrystalVO1==nil then
                            if self.selectedCrystalVO2==nil then
                                callback1()
                            elseif self.selectedCrystalVO2:getForm()==crystalVO:getForm() then
                                if self.selectedCrystalVO2.id ~= crystalVO.id or crystalVO.num>1 then
                                    callback1()
                                end
                            elseif self.selectedCrystalVO2:getForm()~=crystalVO:getForm() then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("select_correct_merge_crystal"),30)
                            end
                        elseif self.selectedCrystalVO2==nil then
                            if self.selectedCrystalVO1==nil then
                                callback2()
                            elseif self.selectedCrystalVO1:getForm()==crystalVO:getForm() then
                                if self.selectedCrystalVO1.id ~= crystalVO.id or crystalVO.num>1 then
                                    callback2()
                                end
                            elseif self.selectedCrystalVO1:getForm()~=crystalVO:getForm() then
                                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("select_correct_merge_crystal"),30)
                            end
                        else
                            print("---------dmj--------暂无空槽")    
                        end
                    end
                end
                local iconSp=crystalVO:getIconSp(selectedIcon)
                iconSp:setAnchorPoint(ccp(0,0))
                local posX = 15+(15+iconSp:getContentSize().width)*(((i-1)%self.showCrystalNum))
                local posY = 10
                iconSp:setPosition(ccp(posX,posY))
                iconSp:setTouchPriority(-(self.layerNum-1)*20-1)
                iconSp:setTag(idx*self.showCrystalNum+i)
                cell:addChild(iconSp)

                -- 等级
                local levelLb=GetTTFLabel(tostring(crystalVO:getLevelStr()),20)
                levelLb:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height-5))
                levelLb:setAnchorPoint(ccp(0.5,1));
                iconSp:addChild(levelLb)
                -- 数量
                local numLb=GetTTFLabel(tostring(crystalVO:getNumStr()),20)
                numLb:setPosition(ccp(iconSp:getContentSize().width-5,5))
                numLb:setAnchorPoint(ccp(1,0));
                iconSp:addChild(numLb)

                local function touch( ... )
        
                end
                local capInSet = CCRect(5, 5, 1, 1)
                
                local maskSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet,touch)
                maskSp:setAnchorPoint(ccp(0.5,0.5))
                maskSp:setPosition(ccp(iconSp:getContentSize().width/2,iconSp:getContentSize().height/2))
                maskSp:setContentSize(CCSizeMake(iconSp:getContentSize().width,iconSp:getContentSize().height))
                iconSp:addChild(maskSp,3)
                maskSp:setTag(1001)
                maskSp:setVisible(false)
                table.insert(self.allCrystalIconSp,iconSp)


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

function energyCrystalTab2Dialog:initTab(tabTb)
   local tabBtn=CCMenu:create()
   local tabIndex=0
   local tabBtnItem;
   if tabTb~=nil then
       for k,v in pairs(tabTb) do

           -- tabBtnItem = CCMenuItemImage:create("RankBtnTab.png", "RankBtnTab_Down.png","RankBtnTab_Down.png")
           tabBtnItem = CCMenuItemImage:create("smallTabBtn.png", "smallTabBtn_Selected.png","smallTabBtn_Selected.png")
           
           tabBtnItem:setAnchorPoint(CCPointMake(0.5,0.5))

           local function tabClick(idx)
               return self:tabClick(idx)
           end
           tabBtnItem:registerScriptTapHandler(tabClick)
           
           local lb=GetTTFLabel(v,24)
           lb:setPosition(CCPointMake(tabBtnItem:getContentSize().width/2,tabBtnItem:getContentSize().height/2))
           tabBtnItem:addChild(lb)
           lb:setTag(31)
       
       
           local numHeight=25
           local iconWidth=36
           local iconHeight=36
           local newsNumLabel = GetTTFLabel("0",numHeight)
           newsNumLabel:setPosition(ccp(newsNumLabel:getContentSize().width/2+5,iconHeight/2))
           newsNumLabel:setTag(11)
           local capInSet1 = CCRect(17, 17, 1, 1)
           local function touchClick()
           end
           local newsIcon =LuaCCScale9Sprite:createWithSpriteFrameName("NumBg.png",capInSet1,touchClick)
          if newsNumLabel:getContentSize().width+10>iconWidth then
            iconWidth=newsNumLabel:getContentSize().width+10
          end
          newsIcon:setContentSize(CCSizeMake(iconWidth,iconHeight))
          newsIcon:ignoreAnchorPointForPosition(false)
          newsIcon:setAnchorPoint(CCPointMake(1,0.5))
          newsIcon:setPosition(ccp(tabBtnItem:getContentSize().width-2,tabBtnItem:getContentSize().height-30))
          newsIcon:addChild(newsNumLabel,1)
          newsIcon:setTag(10)
          newsIcon:setVisible(false)
          tabBtnItem:addChild(newsIcon)
       
          local lockSp=CCSprite:createWithSpriteFrameName("LockIcon.png")
          lockSp:setAnchorPoint(CCPointMake(0,0.5))
          lockSp:setPosition(ccp(10,tabBtnItem:getContentSize().height/2))
          lockSp:setScaleX(0.7)
          lockSp:setScaleY(0.7)
          tabBtnItem:addChild(lockSp,3)
          lockSp:setTag(30)
          lockSp:setVisible(false)
      
          self.allTabs[k]=tabBtnItem
          tabBtn:addChild(tabBtnItem)
          tabBtn:setTouchPriority(-(self.layerNum-1)*20-4)
          tabBtnItem:setTag(tabIndex)
          tabIndex=tabIndex+1

       end
   end
   local tabTbH = -self.crystalMergeBg:getContentSize().height-12
   tabBtn:setPosition(ccp(-3,tabTbH))
   self.bgLayer:addChild(tabBtn)
end
function energyCrystalTab2Dialog:tabClick(idx)
    if self.isPlaying==true then
        return 
    end
    PlayEffect(audioCfg.mouseClick)

    for k,v in pairs(self.allTabs) do
         if v:getTag()==idx then
            v:setEnabled(false)
            self.selectedTabIndex=idx
         else
            v:setEnabled(true)
         end
    end
    self:refreshData()
end

-- 切页签刷新所有数据
function energyCrystalTab2Dialog:refreshData( ... )
    if self.selectedCrystalIconSp1 then
        self.selectedCrystalIconSp1:removeFromParentAndCleanup(true)
        self.selectedCrystalIconSp1=nil
    end
    if self.selectedCrystalIconSp2 then
        self.selectedCrystalIconSp2:removeFromParentAndCleanup(true)
        self.selectedCrystalIconSp2=nil
    end
    if self.selectedCrystalNameLb1 then
        self.selectedCrystalNameLb1:setString(getlocal("sw_add_prop_1"))
    end
    if self.selectedCrystalNameLb2 then
        self.selectedCrystalNameLb2:setString(getlocal("sw_add_prop_2"))
    end
    if self.questionIcon1 then
        self.questionIcon1:setVisible(true)
    end
    if self.questionIcon2 then
        self.questionIcon2:setVisible(true)
    end
    if self and self.tv then
        self:doUserHandler()
        self.tv:reloadData()
    end
end


--用户处理特殊需求,没有可以不写此方法
function energyCrystalTab2Dialog:doUserHandler()
    -- 获取该页签下的所有结晶
    self.allCrystalIconSp={}
    self.selectedCrystalVO1=nil--选中的第一个结晶
    self.selectedCrystalVO2=nil--选中的第二个结晶
    self.selectedCrystalIdx1=0
    self.selectedCrystalIdx2=0
    self.mergeSuccessCrystalVo=nil
    self.mergeFailCrystalVo=nil
    self:refreshSelectedCrystalInfo()
    self.crystalList=superWeaponVoApi:getEnergycrystalByType(tonumber(self.selectedTabIndex+1))
end

function energyCrystalTab2Dialog:tick()
    if self.tipSp then

    end
end

function energyCrystalTab2Dialog:dispose()
    self.tipSp=nil
    self.isUseProtect=nil
    self.crystalList=nil
    self.isPlaying=false
    self.mergeSuccessCrystalVo=nil--融合成功的结晶vo
    self.mergeFailCrystalVo=nil--融合失败的结晶vo
    self.propNum=0
    self.propMaxNum=0
    if self.tipLayer then
        self.tipLayer:removeFromParentAndCleanup(true)
        self.tipLayer=nil
    end
    if self.crystalMergeBg1 then
        self.crystalMergeBg1:stopAllActions()
        self.crystalMergeBg1:removeFromParentAndCleanup(true)
        self.crystalMergeBg1=nil
    end
    if self.crystalMergeFireBg then
        self.crystalMergeFireBg:stopAllActions()
        self.crystalMergeFireBg:removeFromParentAndCleanup(true)
        self.crystalMergeFireBg=nil
    end
    if self.selectedCrystalIconSp1 then
        self.selectedCrystalIconSp1:stopAllActions()
        self.selectedCrystalIconSp1:removeFromParentAndCleanup(true)
        self.selectedCrystalIconSp1=nil
    end
    if self.selectedCrystalIconSp2 then
        self.selectedCrystalIconSp2:stopAllActions()
        self.selectedCrystalIconSp2:removeFromParentAndCleanup(true)
        self.selectedCrystalIconSp2=nil
    end
    self.allCrystalIconSp={}
    if self.bgLayer ~=nil then
        self.bgLayer:removeFromParentAndCleanup(true)
        self.bgLayer=nil;
    end
    spriteController:removePlist("public/dimensionalWar/dimensionalWar.plist")
    spriteController:removeTexture("public/dimensionalWar/dimensionalWar.png")
end




