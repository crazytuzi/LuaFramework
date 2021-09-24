local CBigHpView = classGc(view, function(self)
end)

function CBigHpView.layer(self,bigHpViewData)
    -- print("CBigHpView========>", debug.traceback())
    for k,v in pairs(bigHpViewData) do
        print(k,v)
    end


    self.m_winSize  = cc.Director:getInstance():getVisibleSize()
    local layer = cc.Node:create()
    self.bigHpViewData=bigHpViewData
    self.m_layer=layer

    if self.bigHpViewData.left then
        layer : setPosition(0,self.m_winSize.height-130)
    else
        layer : setPosition(self.m_winSize.width-475,self.m_winSize.height-70)
    end
    self:initView(layer)
    return layer
end

function CBigHpView.initView(self,layer)
    self.hpBars={}
    self.lastSpPercent=101
    self.lastHpPercent=101
    self.bigHpViewData.maxHp=self.bigHpViewData.maxHp==0 and 1 or self.bigHpViewData.maxHp

    local headNode = cc.Node:create()

    if self.bigHpViewData.characterType == _G.Const.CONST_PLAYER and not self.bigHpViewData.isSmall then
        self.mpBars={}

        local pro=self.bigHpViewData.characterId
        -- pro=(pro>4 or pro<1) and 5 or pro
        local szHeadImg=string.format("battle_role_%d.png",pro)
        local bg3       = cc.Sprite:createWithSpriteFrameName(szHeadImg)
        bg3 : setPosition(85,75)
        headNode : addChild(bg3,1)
        local bg3 = cc.Sprite:createWithSpriteFrameName("battle_role_blood_box.png")
        local bg3Size = bg3 : getContentSize()
        bg3       : setPosition(170,70)
        headNode : addChild(bg3)
        local nameText = _G.Util:createLabel(self.bigHpViewData.szName,20)
        -- nameText : setAnchorPoint(cc.p(0,0.5))
        nameText : setPosition(205,100)
        headNode : addChild(nameText,1)
        local lvText = _G.Util:createLabel(self.bigHpViewData.lv,18)
        lvText       : setPosition(132,98)
        -- lvText       : setAnchorPoint(0,1)
        headNode : addChild(lvText,1)

        local hp = cc.Node:create()--cc.Sprite:createWithSpriteFrameName("battle_role_blood_box_2.png")
        hp       : setPosition(206,53)
        local hpSize = hp:getContentSize()
        headNode : addChild(hp)

        self.mpBars[1]=cc.Sprite:createWithSpriteFrameName("battle_role_blue.png")
        self.mpBars[1]=cc.ProgressTimer:create(self.mpBars[1])
        self.mpBars[1]:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self.mpBars[1]:setBarChangeRate(cc.p(1,0))
        self.mpBars[1]:setMidpoint(cc.p(0,0.5))
        -- self.mpBars[1]:setPosition(cc.p(hpSize.width/2,hpSize.height/2))

        for index,mpBar in pairs(self.mpBars) do
            hp:addChild(mpBar)
        end

        local hp = cc.Node:create()--cc.Sprite:createWithSpriteFrameName("battle_role_blood_box_2.png")
        hp       : setPosition(210,72)
        headNode : addChild(hp)
        self.hpBars[0]=gc.GraySprite:createWithSpriteFrameName("battle_role_red.png")
        self.hpBars[0]:setGray()
        self.hpBars[0]=cc.ProgressTimer:create(self.hpBars[0])
        self.hpBars[0]:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self.hpBars[0]:setBarChangeRate(cc.p(1,0))
        self.hpBars[0]:setMidpoint(cc.p(0,0.5))
        -- self.hpBars[0]:setPosition(cc.p(hpSize.width/2,hpSize.height/2))
        self.hpBars[1]=cc.Sprite:createWithSpriteFrameName("battle_role_red.png")
        self.hpBars[1]=cc.ProgressTimer:create(self.hpBars[1])
        self.hpBars[1]:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self.hpBars[1]:setBarChangeRate(cc.p(1,0))
        self.hpBars[1]:setMidpoint(cc.p(0,0.5))
        -- self.hpBars[1]:setPosition(cc.p(hpSize.width/2,hpSize.height/2))

        for index,hpBar in pairs(self.hpBars) do
            hp:addChild(hpBar)
        end

        if self.bigHpViewData.left ~= true then
            layer:setPosition(self.m_winSize.width,self.m_winSize.height-130)
            headNode:setScaleX(-1)
            lvText : setScaleX(-1)
            nameText : setScaleX(-1)
        end

        self:setSpValue(self.bigHpViewData.sp,self.bigHpViewData.maxSp)
        self:setHpValue(self.bigHpViewData.hp,self.bigHpViewData.maxHp)
    elseif self.bigHpViewData.isSmall then
        local hp = cc.Sprite:createWithSpriteFrameName("battle_boss_blood.png")
        hp       : setPosition(160,60)
        hp       : setScaleX(-1)
        headNode  : addChild(hp)

        local headSpr
        if self.bigHpViewData.characterId then
            headSpr = cc.Sprite:createWithSpriteFrameName(string.format("battle_role_%d.png",self.bigHpViewData.characterId))
            headSpr : setPosition(236,50)
            headSpr : setScaleX(-1)
            hp   : addChild(headSpr)
        end

        self.hpBars[0]=gc.GraySprite:createWithSpriteFrameName("battle_boss_hp_1.png")
        self.hpBars[0]:setGray()
        self.hpBars[0]=cc.ProgressTimer:create(self.hpBars[0])
        self.hpBars[0]:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self.hpBars[0]:setBarChangeRate(cc.p(1,0))
        self.hpBars[0]:setMidpoint(cc.p(1,0.5))
        self.hpBars[0]:setPosition(cc.p(105,33))
        self.hpBars[1]=cc.Sprite:createWithSpriteFrameName("battle_boss_hp_1.png")
        self.hpBars[1]=cc.ProgressTimer:create(self.hpBars[1])
        self.hpBars[1]:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        self.hpBars[1]:setBarChangeRate(cc.p(1,0))
        self.hpBars[1]:setMidpoint(cc.p(1,0.5))
        self.hpBars[1]:setPosition(cc.p(105,33))

        for index,hpBar in pairs(self.hpBars) do
            hp:addChild(hpBar)
        end
        local nameText = _G.Util:createLabel(self.bigHpViewData.szName,20)
        nameText : setPosition(195,77)
        headNode : addChild(nameText)
        self.m_nameLabel=nameText

        local lvText = _G.Util:createLabel(self.bigHpViewData.lv,18)
        lvText       : setPosition(102,75)
        lvText       : setAnchorPoint(0,0.5)
        headNode : addChild(lvText)

        if self.bigHpViewData.left~=true then
            headNode:setScaleX(-1)
            lvText:setScaleX(-1)
            nameText:setScaleX(-1)
        end

        self:setHpValue(self.bigHpViewData.hp,self.bigHpViewData.maxHp)
    else 
        if self.bigHpViewData.isMonsterBoss~=true then
            local szImg=self.bigHpViewData.isPartner and "battle_npc.png" or "battle_monster.png"
            local spriteGrey = cc.Sprite:createWithSpriteFrameName("battle_monster_grey.png")
            local spriteRed = cc.Sprite:createWithSpriteFrameName(szImg)
            local SpriteBox = cc.Sprite:createWithSpriteFrameName("battle_monster_1.png")
            layer:addChild(SpriteBox)
            self.hpBars[0]=cc.ProgressTimer:create(spriteGrey)
            self.hpBars[1]=cc.ProgressTimer:create(spriteRed)
            self.hpBars[0]:setType(cc.PROGRESS_TIMER_TYPE_BAR)
            self.hpBars[0]:setBarChangeRate(cc.p(1,0))
            self.hpBars[0]:setMidpoint(cc.p(0,0.5))
            self.hpBars[0]:setPercentage(100)
            self.hpBars[1]:setType(cc.PROGRESS_TIMER_TYPE_BAR)
            self.hpBars[1]:setBarChangeRate(cc.p(1,0))
            self.hpBars[1]:setMidpoint(cc.p(0,0.5))
            self.hpBars[1]:setPercentage(100)
            layer:addChild(self.hpBars[0])
            layer:addChild(self.hpBars[1])
            self:setHpValue(self.bigHpViewData.hp,self.bigHpViewData.maxHp)
            return
        end

        local bg = cc.Sprite:createWithSpriteFrameName("battle_boss_blood.png")
        bg : setPosition(325,10)
        headNode : addChild(bg)

        -- print("JKKJKJKJKJK=======>>>>",self.bigHpViewData.characterId)
        if self.bigHpViewData.characterId then
            local szHead=string.format("h%d.png",self.bigHpViewData.characterId)
            local spriteFram=cc.SpriteFrameCache:getInstance():getSpriteFrame(szHead)
            if spriteFram then
                local head = cc.Sprite:createWithSpriteFrameName(szHead)
                head : setPosition(421,10)
                headNode : addChild(head,1)
            end
        end 

        local nameText = _G.Util:createLabel(self.bigHpViewData.szName,20)
        nameText : setAnchorPoint(cc.p(1,0.5))
        nameText : setPosition(360,27)
        headNode : addChild(nameText)
        self.m_nameLabel=nameText
        self:resetNameLabel(self.bigHpViewData.szName)

        local lvText = _G.Util:createLabel(self.bigHpViewData.lv,18)
        lvText       : setPosition(374,25)
        headNode : addChild(lvText)

        if self.bigHpViewData.hpNum == nil then
            self.bigHpViewData.hpNum=1
        end

        self.hpNumText = _G.Util:createBorderLabel("",15)
        self.hpNumText : setPosition(203,0)
        self.hpNumText : setAnchorPoint(cc.p(0,0.5))
        self.hpNumText : setString("X"..self.bigHpViewData.hpNum+1)
        headNode : addChild(self.hpNumText)

        for i=0,5 do
            if i==0 then
                self.hpBars[i]=gc.GraySprite:createWithSpriteFrameName("battle_boss_hp_1.png")
                self.hpBars[i]:setGray()
            else
                self.hpBars[i]=cc.Sprite:createWithSpriteFrameName(string.format("battle_boss_hp_%d.png",i))
            end
            
            self.hpBars[i]=cc.ProgressTimer:create(self.hpBars[i])
            self.hpBars[i]:setType(cc.PROGRESS_TIMER_TYPE_BAR)
            self.hpBars[i]:setBarChangeRate(cc.p(1,0))
            self.hpBars[i]:setMidpoint(cc.p(1,0.5))
            self.hpBars[i]:setPosition(cc.p(105,34))
            self.hpBars[i]:setLocalZOrder(i+1)
        end
        for index,hpBar in pairs(self.hpBars) do
            bg:addChild(hpBar)
        end
        -- self.hpBarsMask={}
        self:setHpValue(self.bigHpViewData.hp,self.bigHpViewData.maxHp)
    end
    layer:addChild(headNode)        
end

function CBigHpView.resetTempmateView( self,_posIdx,_isleft)
    local hpScale=0.8
    local viewPos=cc.p(self. m_layer:getPosition())
    local posY=358-90*_posIdx
    
    if _isleft then
        self.m_layer:setPosition(cc.p((viewPos.x)*hpScale,posY))
        self.m_layer:setScaleX(hpScale)
        self.m_layer:setScaleY(hpScale)
    else
        self.m_layer:setPosition(cc.p(self.m_winSize.width,posY+44))
        self.m_layer:setScaleX(hpScale)
        self.m_layer:setScaleY(hpScale)
    end
end

function CBigHpView.setSpValue(self, _mp, _maxMp)
    if self.mpBars==nil then return end

    if _maxMp<=0 then
        return
    end
    _mp=_mp>=0 and _mp or 0
    local currentMpPercent =_mp/_maxMp*100
    self.mpBars[1]:setPercentage(currentMpPercent)
    if self.mpBubble then
        self.mpBubble:setScaleX(currentMpPercent/100)
    end
    if _G.g_Stage.m_keyBoard then
        _G.g_Stage.m_keyBoard:isBlackOrColor()
    end
end

function CBigHpView.setHpValue(self, _hp, _maxHp, _noEffect)
    if _maxHp==0 or self.hpBars==nil then
        return 0
    end
    -- print("hp,maxHp",_hp,_maxHp)
    local num = self.bigHpViewData.hpNum or 1
    local currentHp
    local currentHpPercent= math.abs((_hp*100/_maxHp))
    currentHpPercent=currentHpPercent>=100 and 100 or currentHpPercent
    -- print("self.lastHpPercent==currentHpPercent",self.lastHpPercent,currentHpPercent,num)


    if self.bigHpViewData.isMonsterBoss==true then
        -- if _hp == 0 then
        --     -- print("_hp == 0")
        --     for _,hpBar in pairs(self.hpBars) do
        --         hpBar:setVisible(false)
        --     end
        -- end
        local HpPercent = _maxHp / self.bigHpViewData.hpNum
        local num = math.ceil(self.bigHpViewData.hpNum*currentHpPercent*0.01)

        if _hp==_maxHp then
            currentHp=100
        else
            currentHp = math.floor(_hp%HpPercent/HpPercent*100)
        end
        
        -- currentHp = currentHp == 0 and 100 or currentHp
        -- print("OOOOOOOOOOOOOOOO===>>>",currentHp,currentHpPercent,HpPercent,self.bigHpViewData.hpNum)
        -- print("@@@@",self.hpBarsMask[num])
        -- local residue = num % 5
        -- if residue == 1 and num > 5 then
        --     for i=1,6 do
        --         self.hpBars[i]:setLocalZOrder(i*60)
        --     end
        -- end
        -- residue = residue==0 and 5 or residue
        -- for i=5, 1, -1 do
        --     if i > residue then
        --         self.hpBars[i]:setVisible(false)
        --     else
        --         self.hpBars[residue]:setVisible(true)
        --     end
        -- end
        local numString = self.hpNumText:getString()
        -- print(numString)
        numString=string.gsub(numString,'X','')
        -- print(numString,"@@@")
        numString = tonumber(numString)
        -- print(numString,numString==num)
        local residue = num % 5
        residue = residue==0 and 5 or residue
        if numString ~= num then
            if num == 1 then
                for i=2 , 5 do
                    self.hpBars[i]:setVisible(false)
                end
            elseif num==0 then
                for i=2 , 5 do
                    self.hpBars[i]:setVisible(false)
                end
                residue=1
                currentHp=0
            else
                for i=5,1,-1 do
                    self.hpBars[residue]:setLocalZOrder(i*10)
                    self.hpBars[residue]:setPercentage(100)
                    residue=residue-1
                    if residue == 0 then
                        residue = 5
                    end
                end
                self.hpBars[0]:setPercentage(100)
            end
        end
        -- print("YYYYYYYY======>>>>",residue,currentHp)
        self.hpBars[residue]:setPercentage(currentHp)
        self.hpBars[0]:setLocalZOrder(self.hpBars[residue]:getLocalZOrder()-1)        
        local progressFromTo = cc.ProgressTo:create(0.3, currentHp)
        self.hpBars[0]:stopAllActions()
        self.hpBars[0]:runAction(progressFromTo)
        self.hpNumText:setString(string.format("X%d",num))
    else
        if self.lastHpPercent==currentHpPercent then
            return
        end
        if self.lastHpPercent>currentHpPercent and not _noEffect then
            -- if self.hpBubble then
            --     self.hpBubble:setScaleX(currentHpPercent/100)
            -- end
            local timeInterval = (self.lastHpPercent-currentHpPercent)*0.1
            timeInterval=timeInterval>2 and 2 or timeInterval
            
            self.hpBars[1]:setPercentage(currentHpPercent)
            local progressTo = cc.ProgressTo:create(timeInterval, currentHpPercent)
            self.hpBars[0]:stopAllActions()
            self.hpBars[0]:runAction(progressTo)
        else
            -- local progressTo = cc.ProgressTo:create(0.3,currentHpPercent)
            -- self.hpBars[0]:runAction(progressTo:copy():autorelease())
            -- self.hpBars[1]:runAction(progressTo)
            self.hpBars[0]:stopAllActions()
            self.hpBars[1]:setPercentage(currentHpPercent)
            self.hpBars[0]:setPercentage(currentHpPercent)
        end
    end
    self.lastHpPercent=currentHpPercent
end

function CBigHpView.resetNameLabel(self,_szName)
    if self.m_nameLabel~=nil then
        local tempStr
        if self.bigHpViewData.characterType==_G.Const.CONST_GOODS_MONSTER and _G.g_Stage:getScenesType()==_G.Const.CONST_MAP_TYPE_COPY_BOX then
            local myName=_G.GPropertyProxy:getMainPlay():getName()
            if _szName==nil or myName==_szName then
                self.m_nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE))
            else
                self.m_nameLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_RED))
            end

            self.bigHpViewData.szName=_szName
            if _szName then
                tempStr=string.format("宝箱(%s)",_szName)
            else
                tempStr="宝箱"
            end
        elseif _szName then
            self.bigHpViewData.szName=_szName
            tempStr=self.bigHpViewData.szName
        end

        self.m_nameLabel:setString(tempStr)
    end
end

return CBigHpView
