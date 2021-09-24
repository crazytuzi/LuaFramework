allianceJoinSmallDialog=smallDialog:new()

function allianceJoinSmallDialog:new()
	local nc={}
	setmetatable(nc,self)
	self.__index=self
	self.cellHight=120
	return nc
end

function allianceJoinSmallDialog:showJoinAllianceDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,isShowReward,chatDialog)
      local dialog=self:initJoinAllianceDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,isShowReward,chatDialog)
      return sd
end

function allianceJoinSmallDialog:initJoinAllianceDialog(bgSrc,size,fullRect,inRect,isuseami,layerNum,title,isShowReward,chatDialog)
    self.isTouch=false
    self.isUseAmi=isuseami
    local function touchHandler()
    
    end
    local dialogBg = LuaCCScale9Sprite:createWithSpriteFrameName(bgSrc,inRect,touchHandler)
    self.dialogLayer=CCLayer:create()
    
    self.bgLayer=dialogBg
    self.bgSize=size

    -- 计算高度
    local headBg=CCSprite:createWithSpriteFrameName("alliance_join_bg.png")
    headBg:ignoreAnchorPointForPosition(false)
    headBg:setAnchorPoint(ccp(0.5,1))
    

    local headBgH=headBg:getContentSize().height

    local jianbiandi=CCSprite:createWithSpriteFrameName("alliance_join_di.png")
    jianbiandi:setAnchorPoint(ccp(0.5,1))
    jianbiandi:setScale(headBg:getContentSize().width/jianbiandi:getContentSize().width)
    

    
    local addH=0
    -- local startH=self.bgSize.height-72-headBgH-120
    local descLbTb={}
    local welfareTb={getlocal("alliance_welfare1"),getlocal("alliance_welfare2"),getlocal("alliance_welfare3")}
    if base.isRebelOpen == 1 then
        table.insert(welfareTb,getlocal("alliance_welfare4"))
    end
    local sizeStr2 = 24
    if G_getCurChoseLanguage() =="cn" or G_getCurChoseLanguage() =="tw" or G_getCurChoseLanguage() =="ko" then
         sizeStr2 =24
    end
    for k,v in pairs(welfareTb) do
    	local descLb=GetTTFLabelWrap(v,sizeStr2,CCSize(self.bgSize.width-80-30,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    	self.bgLayer:addChild(descLb,2)
    	descLb:setAnchorPoint(ccp(0.5,1))
    	-- descLb:setPosition(ccp(startW+40,startH))

    	-- local starSprie = CCSprite:createWithSpriteFrameName("StarIcon.png")
    	-- self.bgLayer:addChild(starSprie,2)
    	-- starSprie:setAnchorPoint(ccp(0,1))
    	-- starSprie:setPosition(ccp(startW,startH+5))

    	table.insert(descLbTb,{descLb})
    	addH=addH+descLb:getContentSize().height+10
    	-- startH=startH+descLb:getContentSize().height+10
    end
    self.bgSize.height=self.bgSize.height+addH
    if base.joinReward==0 then
    	self.bgSize.height=self.bgSize.height+120
    end
    self.bgLayer:setContentSize(self.bgSize)
    self:show()

    headBg:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-72))
    self.bgLayer:addChild(headBg,1)

    jianbiandi:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-72-headBgH+20))
    self.bgLayer:addChild(jianbiandi,1)

    local startW=30
    local startH=self.bgSize.height-72-headBgH

    for k,v in pairs(descLbTb) do
    	v[1]:setPosition(ccp(self.bgSize.width/2,startH))
    	-- v[2]:setPosition(ccp(startW,startH+5))
    	startH=startH-v[1]:getContentSize().height-10
    end

    if base.joinReward==0 then
    	local firstLb=GetTTFLabelWrap(getlocal("alliance_welfare_firstDes"),24,CCSize(self.bgSize.width-80,0),kCCTextAlignmentCenter,kCCVerticalTextAlignmentTop)
    	self.bgLayer:addChild(firstLb,2)
    	firstLb:setAnchorPoint(ccp(0.5,1))
    	firstLb:setPosition(ccp(self.bgSize.width/2,startH))
    	firstLb:setColor(G_ColorYellowPro)

    	startH=startH-firstLb:getContentSize().height-5
    	local rewardTab=FormatItem(playerCfg.firstJoinAllianceCfg.reward,nil,true) or {}
    	for k,v in pairs(rewardTab) do
    		local scale=0.8
            local rewardSp=G_getItemIcon(v,100,true,layerNum)
            rewardSp:setAnchorPoint(ccp(0.5,1))
            rewardSp:setTouchPriority(-(layerNum-1)*20-4)
            rewardSp:setPosition(ccp(70+(k-1)*120,startH))
            self.bgLayer:addChild(rewardSp,1)
            G_addRectFlicker(rewardSp,1.4,1.4)
            rewardSp:setScale(scale)
            local numLb=GetTTFLabel("x"..FormatNumber(v.num),22)
            numLb:setAnchorPoint(ccp(1,0))
            numLb:setPosition(ccp(rewardSp:getContentSize().width-5,5))
            numLb:setScale(1/scale)
            rewardSp:addChild(numLb)
            local pos
            if k==2 then
                pos=ccp(self.bgLayer:getContentSize().width/2,startH)
            elseif k==1 then
                pos=ccp(self.bgLayer:getContentSize().width/2-120,startH)
            else
                pos=ccp(self.bgLayer:getContentSize().width/2+120,startH)
            end
            rewardSp:setPosition(pos)
    	end
	end

    local function touchDialog()
      
    end
    
    self.bgLayer:setPosition(getCenterPoint(self.dialogLayer))
    self.dialogLayer:addChild(self.bgLayer,2);
    self.dialogLayer:setTouchPriority(-(layerNum-1)*20-1)
    self.dialogLayer:setBSwallowsTouches(true);
    self:userHandler()
    
    local function close()
        PlayEffect(audioCfg.mouseClick)
        return self:close()
    end
    local closeBtnItem = GetButtonItem("closeBtn.png","closeBtn_Down.png","closeBtn.png",close,nil,nil,nil);
    closeBtnItem:setPosition(ccp(0,0))
    closeBtnItem:setAnchorPoint(CCPointMake(0,0))
     
    self.closeBtn = CCMenu:createWithItem(closeBtnItem)
    self.closeBtn:setTouchPriority(-(layerNum-1)*20-4)
    self.closeBtn:setPosition(ccp(self.bgSize.width-closeBtnItem:getContentSize().width,self.bgSize.height-closeBtnItem:getContentSize().height))
    self.bgLayer:addChild(self.closeBtn,2)
    
    if title then
        local titleLb=GetTTFLabel(title,32,true)
        titleLb:setAnchorPoint(ccp(0.5,0.5))
        titleLb:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-titleLb:getContentSize().height/2-15))
        dialogBg:addChild(titleLb)
    end

    local capInSet = CCRect(20, 20, 10, 10)
    local function touch(hd,fn,idx)
    end
    




    local inRect=CCRect(168, 86, 10, 10)
    local backSprie=LuaCCScale9Sprite:createWithSpriteFrameName("panelLineBg.png",inRect,touch)
    backSprie:setContentSize(CCSizeMake(self.bgLayer:getContentSize().width-30,self.bgSize.height-110-headBg:getContentSize().height-80))
    backSprie:ignoreAnchorPointForPosition(false)
    backSprie:setAnchorPoint(ccp(0.5,1))
    backSprie:setIsSallow(false)
    backSprie:setTouchPriority(-(layerNum-1)*20-1)
    backSprie:setPosition(ccp(self.bgSize.width/2,self.bgSize.height-90-headBg:getContentSize().height))
    -- self.bgLayer:addChild(backSprie,1)


    if isShowReward==true then

        local function rewardHandler(tag,object)          
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            local function rewardCallback(fn,data)
                local ret,sData=base:checkServerData(data)
                if ret==true then
                    base.joinReward=1
                    if self.menuItemAward then
                        self.menuItemAward:setEnabled(false)
                    end
                    if sData.data and sData.data.reward then
                        local reward=FormatItem(sData.data.reward)
                        for k,v in pairs(reward) do
                            G_addPlayerAward(v.type,v.key,v.id,tonumber(v.num),false,true)
                        end
                        G_showRewardTip(reward,true)
                    end
                    self:close()
                end
            end
            socketHelper:allianceOncereward(rewardCallback)
        end
        self.menuItemAward=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",rewardHandler,nil,getlocal("daily_scene_get"),24,101)
        local lb = self.menuItemAward:getChildByTag(101)
        if lb then
            lb = tolua.cast(lb,"CCLabelTTF")
            lb:setFontName("Helvetica-bold")
        end
        local menuAward=CCMenu:createWithItem(self.menuItemAward)
        menuAward:setPosition(ccp(size.width/2,50))
        menuAward:setTouchPriority(-(layerNum-1)*20-4)
        dialogBg:addChild(menuAward)
        if allianceVoApi:isHasAlliance() and base.joinReward==0 then
            self.menuItemAward:setEnabled(true)
        else
        	self.menuItemAward:setEnabled(false)
            self.menuItemAward:setVisible(false)
        end
    end

    if allianceVoApi:isHasAlliance() then
    else
        local function gotoAllianceHandler(tag,object)
            if G_checkClickEnable()==false then
                do
                    return
                end
            else
                base.setWaitTime=G_getCurDeviceMillTime()
            end
            PlayEffect(audioCfg.mouseClick)
            self:close()
            if chatDialog then
                chatDialog:close()
            end

            -- if allianceVoApi:isHasAlliance()==false then
            --     require "luascript/script/game/scene/gamedialog/allianceDialog/allianceDialog"
            --     local td=allianceDialog:new(1,layerNum+1)
            --     G_AllianceDialogTb[1]=td
            --     local tbArr={getlocal("recommendList"),getlocal("alliance_list_scene_create")}
            --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,layerNum+1)
            --     sceneGame:addChild(dialog,layerNum+1)
            --     if tag==1 then
            --         td:tabClick(1)
            --     end
            -- else
            --     allianceEventVoApi:clear()
            --     require "luascript/script/game/scene/gamedialog/allianceDialog/allianceExistDialog"
            --     local td=allianceExistDialog:new(1,3)
            --     G_AllianceDialogTb[1]=td
            --     local tbArr={getlocal("alliance_info_title"),getlocal("alliance_function"),getlocal("alliance_list_scene_list")}
            --     local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),tbArr,nil,nil,getlocal("alliance_list_scene_name"),true,3)
            --     sceneGame:addChild(dialog,3)
            -- end
            allianceVoApi:showAllianceDialog(layerNum+1)
        end
        local createItem=GetButtonItem("creatRoleBtn.png","creatRoleBtn_Down.png","creatRoleBtn.png",gotoAllianceHandler,1,getlocal("create_alliance"),24,101)
        local lb = createItem:getChildByTag(101)
        if lb then
            lb = tolua.cast(lb,"CCLabelTTF")
            lb:setFontName("Helvetica-bold")
        end
        local createdMenu=CCMenu:createWithItem(createItem)
        createdMenu:setPosition(ccp(size.width/2-120,50))
        createdMenu:setTouchPriority(-(layerNum-1)*20-4)
        dialogBg:addChild(createdMenu)

        local joinItem=GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn.png",gotoAllianceHandler,2,getlocal("join_alliance"),24,101)
        local lb = joinItem:getChildByTag(101)
        if lb then
            lb = tolua.cast(lb,"CCLabelTTF")
            lb:setFontName("Helvetica-bold")
        end
        local joinMenu=CCMenu:createWithItem(joinItem)
        joinMenu:setPosition(ccp(size.width/2+120,50))
        joinMenu:setTouchPriority(-(layerNum-1)*20-4)
        dialogBg:addChild(joinMenu)
        -- G_addRectFlicker(joinItem,2.8,1)
        G_addNewRectFlicker(joinItem)
    end


    local function touchLuaSpr()
         
    end
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png",CCRect(10, 10, 1, 1),touchLuaSpr);
    touchDialogBg:setTouchPriority(-(layerNum-1)*20-1)
    local rect=CCSizeMake(640,G_VisibleSizeHeight)
    touchDialogBg:setContentSize(rect)
    touchDialogBg:setOpacity(180)
    touchDialogBg:setPosition(getCenterPoint(self.dialogLayer))
    --touchDialogBg:setPosition(ccp(0,0))
    self.dialogLayer:addChild(touchDialogBg,1)
    
    sceneGame:addChild(self.dialogLayer,layerNum)
    --self.dialogLayer:setPosition(getCenterPoint(sceneGame))
    self.dialogLayer:setPosition(ccp(0,0))
    return self.dialogLayer
end