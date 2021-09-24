sellShowSureDialog=smallDialog:new()
function sellShowSureDialog:new()
    local nc={
            container,
     	   	touchDialogBg,
            isUseAmi,
            id,
          }
    setmetatable(nc,self)
    self.__index=self
    return nc
end



function sellShowSureDialog:init(callBack,cancleCallBack,isShowClose,costNum,halfNum,isSpe,subGold,parent,item,layerNum,isUseLocal,isAddBg,addDesc,descColor,isFile,isAccOrFrag,hideNum,isOwn,isHuoxianmingjianggai,leftBtnStr,callBack2)
    --self.bgLayer=CCLayer:create()
    local strSize2 = 20
    local diaHeighT = 500
    local tip1Height = 20
    local tip2Height = 60
    if G_isAsia() then
        strSize2 =25
        diaHeighT= 400
        tip1Height = 0
        tip2Height = 30
    end
    if G_getCurChoseLanguage() == "ja" and not G_isIOS() then
        strSize2 = 20
    end
    local titleStr = getlocal("buy")
    local function touchDialog()
        -- PlayEffect(audioCfg.mouseClick)
        -- self:close()
    end
    local function closeCall( )
        return self:close()
    end
    self.isSpe = isSpe
    self.dialogLayer=CCLayer:create()
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true)

    local rect = CCRect(0, 0, 400, 350)
    local capInSet = CCRect(130, 50, 1, 1)
	local capInSet1 = CCRect(10, 10, 1, 1)

    -- local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("TankInforPanel.png",capInSet,touchDialog);
    self.layerNum = layerNum
    self.dialogHeight = diaHeighT
    local useClose = true
    if addDesc then
        self.dialogWidth = 500
        -- dialogBg:setContentSize(CCSizeMake(500,diaHeighT))
    else
        self.dialogWidth = 550
        -- dialogBg:setContentSize(CCSizeMake(550,diaHeighT))
    end

    dialogBg = G_getNewDialogBg(CCSizeMake(self.dialogWidth,self.dialogHeight),titleStr,30,nil,self.layerNum+1,useClose,closeCall)
    self.dialogLayer=CCLayer:create()
    self.bgLayer=dialogBg
    
    --dialogBg:setContentSize(CCSizeMake(500,350))
    -- self.bgLayer=dialogBg
    self.dialogLayer:addChild(self.bgLayer,1)
    
    self.touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",capInSet1,touchDialog);
    self.touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect1=CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight)
    self.touchDialogBg:setContentSize(rect1)
    self.touchDialogBg:setOpacity(180)
    self.touchDialogBg:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:addChild(self.touchDialogBg)
    
    local dialogBgHeight =dialogBg:getContentSize().height-20
    local dialogBgWidth  =dialogBg:getContentSize().width-5


	if isShowClose==true then
        local function close()
            PlayEffect(audioCfg.mouseClick)
            if callBack2 then
                callBack2()
            end
            return self:close()
        end
        local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",close,nil,nil,nil);
        closeBtnItem:setPosition(0,0)
        closeBtnItem:setAnchorPoint(CCPointMake(0,0))
         
        self.closeBtn = CCMenu:createWithItem(closeBtnItem)
        self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
        self.closeBtn:setPosition(ccp(dialogBgWidth-closeBtnItem:getContentSize().width,dialogBgHeight-closeBtnItem:getContentSize().height))
        self.bgLayer:addChild(self.closeBtn)
    end

    if isSpe ==true then--activity_double11_daibiTip
        local daibiTip=GetTTFLabelWrap(getlocal("activity_double11_daibiTip"),24,CCSizeMake(dialogBgWidth-20,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
        daibiTip:setPosition(ccp(dialogBgWidth*0.5,dialogBgHeight*0.5-tip1Height - 40))
        daibiTip:setAnchorPoint(ccp(0.5,0.5));
        self.bgLayer:addChild(daibiTip,2)
        daibiTip:setColor(G_ColorOrange)
        subGold =tonumber(subGold)
        local lastSubGold = G_clone(halfNum)
        if subGold and subGold >0 then
            if halfNum-subGold >= math.floor(halfNum/2) then
                halfNum =halfNum-subGold
            else
                halfNum =lastSubGold-math.floor(lastSubGold/2)
                subGold =math.floor(lastSubGold/2)
            end
            local daibiTip2=GetTTFLabelWrap(getlocal("activity_double11_daibiTip2",{subGold}),24,CCSizeMake(dialogBgWidth-20,0),kCCVerticalTextAlignmentCenter,kCCVerticalTextAlignmentCenter)
            daibiTip2:setPosition(ccp(dialogBgWidth*0.5,dialogBgHeight*0.5-tip2Height - 40 ))
            daibiTip2:setAnchorPoint(ccp(0.5,0.5));
            self.bgLayer:addChild(daibiTip2,2)
            daibiTip2:setColor(G_ColorGreen)
        end
    end

--取消----------------
    if useClose == false  then
        local function cancleHandler()
            print(" here?????")
             PlayEffect(audioCfg.mouseClick)
             if cancleCallBack~=nil then
                cancleCallBack()
             end
             self:close()
        end
        local cancleItem =GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn_Down.png",cancleHandler,2)
        -- if rightBtnStr and rightBtnStr~="" then
        --     cancleItem=GetButtonItem("BtnOkSmall.png","BtnOkSmall_Down.png","BtnOkSmall_Down.png",cancleHandler,2,rightBtnStr,25)
        -- else
        --     cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancleHandler,2,getlocal("cancel"),25)
        -- end
        -- local cancleItem=GetButtonItem("BtnGraySmall.png","BtnGraySmall_Down.png","BtnGraySmall_Down.png",cancleHandler,2,rightStr,25)
        local cancleMenu=CCMenu:createWithItem(cancleItem);
        cancleItem:setAnchorPoint(ccp(1,1))
        cancleItem:setScale(0.9)
        cancleMenu:setPosition(ccp(dialogBg:getContentSize().width-5,dialogBg:getContentSize().height-10))
        cancleMenu:setTouchPriority(-(layerNum-1)*20-2);
        dialogBg:addChild(cancleMenu)
    end
    --确定
    local function sureHandler()
        PlayEffect(audioCfg.mouseClick)
        if self.isSpe and self.isSpe == "duanwu" then
            callBack(self)
            -- self.sureItem:setEnabled(false)
        else
            if callBack then
                callBack()
            end
            if callBack2 then
                callBack2()
             end
            self:close()
        end
    end
    local leftStr=getlocal("buy")
    if leftBtnStr and leftBtnStr~="" then
        leftStr=leftBtnStr
    end
    local sureItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",sureHandler,2,leftStr,33)
    local sureScaleNum = 0.8
    sureItem:setScale(sureScaleNum)
    local sureMenu=CCMenu:createWithItem(sureItem);
    sureMenu:setPosition(ccp(dialogBgWidth*0.5,40))
    sureMenu:setTouchPriority(-(layerNum-1)*20-2);
    self.sureItem = sureItem
    self.bgLayer:addChild(sureMenu)
    
    local needPosY = sureItem:getContentSize().height + 5
-------------
    local goldIcon = CCSprite:createWithSpriteFrameName("IconGold.png")
    -- goldIcon:setScale(0.8)
    goldIcon:setAnchorPoint(ccp(1,0))
    goldIcon:setPosition(ccp(sureItem:getContentSize().width*0.5-5,needPosY))
    sureItem:addChild(goldIcon,1)

	-- local costStr=GetTTFLabelWrap(tonumber(costNum),28,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
	local costStr= GetTTFLabel(tonumber(costNum),28)
    costStr:setPosition(ccp(goldIcon:getPositionX()-goldIcon:getContentSize().width+5,needPosY))
    costStr:setAnchorPoint(ccp(1,0));
    sureItem:addChild(costStr,2)
    costStr:setColor(G_ColorRed)

    local rline = CCSprite:createWithSpriteFrameName("redline.jpg")
    rline:setScaleX(costStr:getContentSize().width / rline:getContentSize().width)
    rline:setAnchorPoint(ccp(0.5,0.5))
    rline:setPosition(ccp(costStr:getContentSize().width*0.5,costStr:getContentSize().height*0.5))
    costStr:addChild(rline,1)

	-- local halfStr=GetTTFLabelWrap(tonumber(halfNum),28,CCSizeMake(80,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentCenter)
    local halfStr = GetTTFLabel(tonumber(halfNum),28)
    halfStr:setPosition(ccp(sureItem:getContentSize().width*0.5,needPosY))
    halfStr:setAnchorPoint(ccp(0,0));
    sureItem:addChild(halfStr,2)

    local goldIcon2 = CCSprite:createWithSpriteFrameName("IconGold.png")
    goldIcon2:setAnchorPoint(ccp(0,0))
    goldIcon2:setPosition(ccp(halfStr:getPositionX()+halfStr:getContentSize().width,needPosY))
    sureItem:addChild(goldIcon2,1)
    
    local upM_Line = LuaCCScale9Sprite:createWithSpriteFrameName("modifiersLine1.png",CCRect(34,1,1,1),function ()end)--modifiersLine2
    upM_Line:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width*1.2,upM_Line:getContentSize().height))
    upM_Line:setPosition(ccp(sureItem:getContentSize().width*0.5,needPosY + halfStr:getContentSize().height + 15))
    upM_Line:setAnchorPoint(ccp(0.5,0.5))
    sureItem:addChild(upM_Line,2)    

    local spriteIcon
    if isSpe and isSpe =="duanwu" then
        spriteIcon = G_getItemIcon(item,80,false,self.layerNum,nil)
    else
            local function touch()  end
            if item.type=="w" and item.eType and item.eType=="f" then
                spriteIcon=superWeaponVoApi:getFragmentIcon(item.key,touch)
            elseif item.type=="w" and item.eType and item.eType=="c" then
                isUseLocal=true
                spriteIcon=superWeaponVoApi:getCrystalIcon(item.key,touch)      
            elseif item.type=="h" then
                spriteIcon=heroVoApi:getHeroIcon(item.key,1,false,touch)
            elseif item.type=="p" and item.equipId then
                eType=string.sub(item.equipId,1,1)
                if eType=="a" then
                    spriteIcon=accessoryVoApi:getAccessoryIcon(item.equipId,nil,100,touch)
                elseif eType=="f" then
                    spriteIcon=accessoryVoApi:getFragmentIcon(item.equipId,nil,100,touch)
                else
                    spriteIcon = item.pic--CCSprite:createWithSpriteFrameName(item.pic)
                end
            elseif item.type=="p" and propCfg[item.key] and propCfg[item.key].useGetHero then
                local heroData={h=G_clone(propCfg[item.key].useGetHero)}
                local hItmeTb=FormatItem(heroData)
                local hItme=hItmeTb[1]
                if hItme and hItme.type=="h" then
                    if hItme.eType=="h" then
                        local productOrder=hItme.num
                        spriteIcon = heroVoApi:getHeroIcon(hItme.key,productOrder,true,touch,nil,nil,nil,{adjutants={}})
                    else
                        spriteIcon = heroVoApi:getHeroIcon(hItme.key,1,false,touch)
                    end
                end
            elseif isAccOrFrag==true then
                if item.eType=="a" then
                    spriteIcon=accessoryVoApi:getAccessoryIcon(item.id,nil,100,touch)
                elseif item.eType=="f" then
                    spriteIcon=accessoryVoApi:getFragmentIcon(item.id,nil,100,touch)
                else
                    spriteIcon = item.pic--CCSprite:createWithSpriteFrameName(item.pic)
                end
            elseif isFile==true then
                spriteIcon = item.pic--LuaCCSprite:createWithFileName(item.pic,touch)
            elseif isAddBg==true then
                --bgname：需要添加的背景框名称（结晶有用到）
                if item.bgname and item.bgname~="" then
                    spriteIcon = item.pic--GetBgIcon(item.pic,nil,item.bgname,80,100)
                else
                    spriteIcon = item.pic--GetBgIcon(item.pic,nil,nil,80,100)
                end
            else
                spriteIcon = item.pic--CCSprite:createWithSpriteFrameName(item.pic)
            end
    end
    spriteIcon:setAnchorPoint(ccp(0,0.5))
  	-- if spriteIcon:getContentSize().width>100 then
  	-- 	  spriteIcon:setScale(100/150)
  	-- end
    local spScale = 100/spriteIcon:getContentSize().width
    spriteIcon:setScale(spScale)
    spriteIcon:setPosition(30,dialogBgHeight-120)
    self.bgLayer:addChild(spriteIcon,2)
    
    local spPosyAndLength = spriteIcon:getPositionX()+spriteIcon:getContentSize().width*spScale
    if item.num then
        local picNumsStr = GetTTFLabel("x"..item.num,22)
        local thiPos = ccp(spPosyAndLength-5,spriteIcon:getPositionY()-45)
        picNumsStr:setAnchorPoint(ccp(1,0))
        picNumsStr:setPosition(thiPos)
        self.bgLayer:addChild(picNumsStr,3)

        local strBg = CCSprite:createWithSpriteFrameName("BlackAlphaBg.png")
        strBg:setAnchorPoint(ccp(1,0))
        strBg:setOpacity(150)
        strBg:setScaleX((picNumsStr:getContentSize().width+5)/strBg:getContentSize().width)
        strBg:setScaleY((picNumsStr:getContentSize().height-3)/strBg:getContentSize().height)
        strBg:setPosition(thiPos)
        self.bgLayer:addChild(strBg,2)
    end


    local nameStr=item.name
    if item and item.type and item.type=="c" then
      nameStr=getlocal(item.name,{item.num})
    end
    if isHuoxianmingjianggai==true then
      nameStr=nameStr .. "(" .. getlocal("active_mingjiang_soul") .. ")"
    end
    local lbName=GetTTFLabelWrap(nameStr,28,CCSizeMake(320,0),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    lbName:setPosition(ccp(spriteIcon:getContentSize().width+10,spriteIcon:getContentSize().height))
    lbName:setAnchorPoint(ccp(0,1));
    spriteIcon:addChild(lbName,2)
    lbName:setColor(G_ColorYellowPro)
    
    -- local lbNum=GetTTFLabel(getlocal("propInfoNum",{item.num}),25)
    local lbNum = nil
    if isOwn == true then
      lbNum=GetTTFLabel(getlocal("ownedGem",{item.num}),25)
    elseif item.type == "c" then
      lbNum=GetTTFLabel(getlocal("buffLv",{item.num}),25)
    else
      if isHuoxianmingjianggai==true then
        lbNum=GetTTFLabel(getlocal("propInfoNum",{170}),25)
      else
         lbNum=GetTTFLabel(getlocal("propInfoNum",{item.num}),25)
      end
    end
    lbNum:setPosition(140,dialogBgHeight-100)
    lbNum:setAnchorPoint(ccp(0,0.5));
    -- self.bgLayer:addChild(lbNum,2)
    if hideNum == true then
      lbNum:setVisible(false)
    end
    local labelSize = CCSize(350, 0);
    local desc=""

    if item.eType=="c" and item.type=="w" then
      desc=item.desc
    else
        if tonumber(item.id) and item.id > 4819 and item.id < 4828 then
            desc = getlocal(item.desc,{propCfg["p"..item.id].composeGetProp[1]})
        else
              desc=getlocal(item.desc)
        end
    end

    if isUseLocal or (item and item.type=="w" and item.eType=="f") then
        desc=item.desc
    elseif item and item.type and item.type=="c" then
        local techCfg=checkPointVoApi:getChallengeTechCfg()
        if techCfg and item.key and techCfg[item.key] and techCfg[item.key].value then
            local valueTb=techCfg[item.key].value
            if valueTb and valueTb[item.num] then
                local percent=(valueTb[item.num]*100).."%%"
                desc=getlocal(item.desc,{percent})
            end
        end
    end
    local lbDescription=GetTTFLabelWrap(desc,strSize2,labelSize,kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    lbDescription:setPosition(ccp(spriteIcon:getContentSize().width+10,spriteIcon:getContentSize().height-lbName:getContentSize().height-10*(1/spScale)))
    lbDescription:setAnchorPoint(ccp(0,1));
    spriteIcon:addChild(lbDescription,2)

    lbName:setScale(1/spScale)
    lbDescription:setScale(1/spScale)

    if isSpe and isSpe == "duanwu" and G_isAsia() then
        upM_Line:setPositionY(upM_Line:getPositionY() + 35)
    end
    -- lbDescription:setScale(1)
    -- if descColor then
    --     lbDescription:setColor(descColor)
    -- end

    self.bgLayer:setPosition(getCenterPoint(sceneGame))
    sceneGame:addChild(self.dialogLayer,layerNum+1)
    self:show()

end