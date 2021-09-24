--[[
英雄技能升级
Alter

@author JNK
]]

heroSkillUpgradeDialog=smallDialog:new()

function heroSkillUpgradeDialog:new()
    local nc={
        bgLayer=nil,             --背景sprite
        dialogLayer,         --对话框层
        bgSize,
        isTouch,
        isUseAmi,
        refreshData={},     --需要刷新的数据
        message,
        isSizeAmi,
    }
    setmetatable(nc,self)
    self.__index=self

    return nc
end

function heroSkillUpgradeDialog:init(vo,skillId,layerNum,parent)
-- function heroSkillUpgradeDialog:showUpgradeDialog(vo,skillId,layerNum,parent)
    self.layerNum=layerNum
    self.isTouch=false
    self.isUseAmi=true
    self.heroVo=vo
    self.parent=parent

    local ifAwaken = false
    if vo.skill[skillId]==nil then
        local awakenSkill=equipCfg[vo.hid]["e1"].awaken.skill
        skillId=awakenSkill[skillId]
        ifAwaken=true
    end

    local size = CCSizeMake(600,650)
    local titleStr = getlocal("heroSkillUpdate")
    local titleSize = 30
    self.bgSize = size

    local function closeCallBack( ... )
        return self:close()
    end
    -- 采用新式小板子
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setBSwallowsTouches(true)
    self.dialogLayer:setPosition(ccp(0,0))
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    sceneGame:addChild(self.dialogLayer,layerNum)

    local dialogBg = G_getNewDialogBg(size,titleStr,titleSize,nil,layerNum,true,closeCallBack,nil)
    self.bgLayer=dialogBg
    self.bgLayer:setContentSize(size)
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2)

    local icon = CCSprite:create(heroVoApi:getSkillIconBySid(skillId))
    icon:setAnchorPoint(ccp(0,0.5))
    icon:setPosition(ccp(50,self.bgLayer:getContentSize().height-170))
    self.bgLayer:addChild(icon)
    icon:setScale(1.3)

    local skillName =  getlocal(heroSkillCfg[skillId].name)

    local lv,value,isMax,curLv = heroVoApi:getHeroSkillLvAndValue(vo.hid,skillId,vo.productOrder,ifAwaken)
    local lvStr = getlocal("buffLv",{lv})
    local buffNameHighPos = self.bgLayer:getContentSize().height-110
    if G_getCurChoseLanguage() =="fr" then
        buffNameHighPos =buffNameHighPos+5
    end

    local lbTB={
        {str=getlocal("buffName",{skillName}),size=20,pos={210,buffNameHighPos},aPos={0,0.5},},
        {str=lvStr,size=20,pos={210,self.bgLayer:getContentSize().height-143},aPos={0,0.5},},
        {str=getlocal("nextLvEffect"),size=20,pos={210,self.bgLayer:getContentSize().height-176},aPos={0,0.5},},
        {str=getlocal("effect"),size=20,pos={210,self.bgLayer:getContentSize().height-209},aPos={0,0.5},tag=100},
    }
    for k,v in pairs(lbTB) do
        local strLb=GetTTFLabelWrap(v.str,v.size,CCSizeMake(380,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
        if v.aPos then
            strLb:setAnchorPoint(ccp(v.aPos[1],v.aPos[2]))
        end
        if v.color then
            strLb:setColor(v.color)
        end
        if v.tag then
            strLb:setTag(v.tag)
        end
        strLb:setPosition(ccp(v.pos[1],v.pos[2]-8))
        self.bgLayer:addChild(strLb)
    end
    local lbp=GetTTFLabel(getlocal("effect"),20)
    local heroSkillAtt = {}
    if type(heroSkillCfg[skillId].attType) == "table" then
        for k, v in pairs(heroSkillCfg[skillId].attType) do
            table.insert(heroSkillAtt, {attType = v, attValue = heroSkillCfg[skillId].attValuePerLv[k]})
        end
    else
        table.insert(heroSkillAtt, {attType = heroSkillCfg[skillId].attType, attValue = heroSkillCfg[skillId].attValuePerLv})
    end
    for k, att in pairs(heroSkillAtt) do
        local value1=(vo.skill[skillId])*att.attValue*100
        local value1Str = value1.."%"
        if att.attType=="antifirst" or att.attType=="first" then
            value1=value1/100
            value1Str=value1
        end
        local valueLb1 = GetTTFLabel(value1Str,20)
        valueLb1:setAnchorPoint(ccp(0,0.5))
        local lb = self.bgLayer:getChildByTag(100)
        valueLb1:setPosition(ccp(lbp:getContentSize().width+10,lb:getContentSize().height/2-(k-1)*(lb:getContentSize().height+5)))
        lb:addChild(valueLb1)
        local aIcon = CCSprite:createWithSpriteFrameName("heroArrowRight.png")
        aIcon:setAnchorPoint(ccp(0,0.5))
        aIcon:setPosition(ccp(valueLb1:getContentSize().width+3,valueLb1:getContentSize().height/2))
        valueLb1:addChild(aIcon)
        local value2=(vo.skill[skillId]+1)*att.attValue*100
        local value2Str = value2.."%"
        if att.attType=="antifirst" or att.attType=="first" then
            value2=value2/100
            value2Str=value2
        end
        local valueLb2 = GetTTFLabel(value2Str,20)
        valueLb2:setColor(G_ColorGreen)
        valueLb2:setAnchorPoint(ccp(0,0.5))
        valueLb2:setPosition(ccp(aIcon:getContentSize().width+3,aIcon:getContentSize().height/2))
        aIcon:addChild(valueLb2)
    end

    local capInSet = CCRect(15, 15, 2, 2)
    local backSprie =LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", capInSet, function () end)
    backSprie:setContentSize(CCSizeMake(dialogBg:getContentSize().width-40, 250))
    backSprie:setPosition(ccp(dialogBg:getContentSize().width/2,245))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(self.layerNum-1)*20-1)
    dialogBg:addChild(backSprie)


    local tb,isSuccessUpdate,propsTb= heroVoApi:getSkillNeedPropIconBySid(skillId,self.heroVo.skill[skillId],self.layerNum+1)
    for i=1,SizeOfTable(tb) do
        local icon = tb[i]
        icon:setAnchorPoint(ccp(0,0.5))
        icon:setPosition(40+(icon:getContentSize().width+40)*(i-1),195)
        icon:setTouchPriority(-(layerNum-1)*20-2)
        dialogBg:addChild(icon,2)
    end
    if isSuccessUpdate==false then
        local desLb=GetTTFLabelWrap(getlocal("notEnoughRes"),23,CCSizeMake(500,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        desLb:setAnchorPoint(ccp(0.5,0.5))
        local lbHeight=320
        if G_getCurChoseLanguage() =="de" or G_getCurChoseLanguage() =="en" or G_getCurChoseLanguage() =="fr" or G_getCurChoseLanguage() =="ar" then
            lbHeight =330
        end
        desLb:setPosition(ccp(self.bgSize.width/2,lbHeight))
        dialogBg:addChild(desLb)
        desLb:setColor(G_ColorYellowPro)
    end
    local desLb=GetTTFLabelWrap(getlocal("touchinfo"),23,CCSizeMake(400,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
    desLb:setAnchorPoint(ccp(0.5,0.5))
    desLb:setPosition(ccp(self.bgSize.width/2,280))
    dialogBg:addChild(desLb)
    desLb:setColor(G_ColorYellowPro)

    local function touchLuaSpr()

    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr)
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(touchDialogBg,1)

    local function callBack()
        if G_checkClickEnable()==false then
            do return end
        else
            base.setWaitTime=G_getCurDeviceMillTime()
        end

        if isSuccessUpdate==false then
            smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("noEnoughSkill"),30)
            do return end
        end

        local function callback(fn,data)
            local ret,sData=base:checkServerData(data)
            if ret==true then

                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("newGetSkillUpdateSuccess"),30)
                for k,v in pairs(propsTb) do
                    bagVoApi:useItemNumId(tonumber(RemoveFirstChar(k)),v)
                end

                self:close()
            end
        end

        socketHelper:heroUpgradeskill(self.heroVo.hid,skillId,callback)
    end

    local okItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",callBack,nil,getlocal("upgradeBuild"),24/0.8,101)
    okItem:setScale(0.8)
    local btnLb = okItem:getChildByTag(101)
    if btnLb then
        btnLb = tolua.cast(btnLb,"CCLabelTTF")
        btnLb:setFontName("Helvetica-bold")
    end
    local okBtn=CCMenu:createWithItem(okItem)
    okBtn:setTouchPriority(-(layerNum-1)*20-2)
    okBtn:setPosition(ccp(dialogBg:getContentSize().width/2,65))
    dialogBg:addChild(okBtn)

    if curLv and tonumber(curLv) > 1 then
        local function onResetHandler(tag, obj)
            if G_checkClickEnable()==false then
                do return end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            heroVoApi:showSkillResetDialog(layerNum + 1, self.heroVo.hid, skillId, curLv, function() self:close() end)
        end
        okBtn:setPositionX(dialogBg:getContentSize().width / 2 + 50 + okItem:getContentSize().width * okItem:getScale() / 2)
        local resetBtn = GetButtonItem("newGrayBtn.png", "newGrayBtn_Down.png", "newGrayBtn.png", onResetHandler, nil, getlocal("dailyTaskReset"), 24 / 0.8, 102)
        resetBtn:setScale(0.8)
        local resetMenu = CCMenu:createWithItem(resetBtn)
        resetMenu:setTouchPriority(-(layerNum - 1) * 20 - 2)
        resetMenu:setPosition(dialogBg:getContentSize().width / 2 - 50 - resetBtn:getContentSize().width * resetBtn:getScale() / 2, okBtn:getPositionY())
        dialogBg:addChild(resetMenu)
    end
end

function heroSkillUpgradeDialog:dispose()
    self.parent:refreshTv()
    self.expandIdx=nil
end