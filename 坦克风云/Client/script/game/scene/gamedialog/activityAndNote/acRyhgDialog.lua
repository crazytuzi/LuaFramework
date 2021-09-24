--[[
活动荣耀回归

@author JNK
]]

acRyhgDialog = commonDialog:new()

function acRyhgDialog:new()
	local nc = {
        showLayerTop = nil,
        timeLb = nil,
        textLabel = nil,
        textTipsLb = nil,
        editBox = nil,
        codeStateLb = nil,
        pasteBtnItem = nil,
        rewardList = {}, -- 奖励
        showTopY = G_VisibleSizeHeight - 82,
        showTopHeight = 400,
        btnScale = 0.7,
        activationCodeDefault = "000000",
        showType = 0,
        useVip = 0,
	}
	setmetatable(nc, self)
	self.__index = self

    spriteController:addPlist("public/xsjx.plist")
    spriteController:addTexture("public/xsjx.png")
    spriteController:addPlist("public/believer/believerMain.plist")
    spriteController:addTexture("public/believer/believerMain.png")

	return nc
end

function acRyhgDialog:resetTab()
    self.panelLineBg:setVisible(false)

    local reward = acRyhgVoApi:getAcVo().returnReward
    self.rewardList = FormatItem(reward,false,true) or {}
    local newReward
    local useVip = acRyhgVoApi:getAcVo().use or 0
    self.useVip = useVip
    if useVip > 0 then
        -- 已使用
        newReward = G_clone(acRyhgVoApi:getAcVo().newReward[useVip])
    else
        -- 未使用
        newReward = G_clone(acRyhgVoApi:getAcVo().newReward[1])
    end
    local tempVipNum = acRyhgVoApi:getAcVo().num or 0
    if tempVipNum <= 0 then
        -- 如果写0解析时会不显示
        tempVipNum = 1
    end
    local vipTab = {[acRyhgVoApi:getAcVo().returnVipItem]=tempVipNum, index=0} -- 这里数量得有，否则解析不出来，并且为之放到第一位
    table.insert(newReward.p, vipTab)
    self.newRewardList = FormatItem(newReward,false,true) or {}

    -- 适配相关
    self.addDescY = 0
    self.addBoxBottomY = 0
    self.addOldBoxTitleSpace = 0
    self.addHeightBoxTop = 0
    self.addHeightBoxBottom = 0
    self.addBoxBottomSign = 0
    self.addNewBoxHeight = 0

    if G_getIphoneType() == G_iphone5 then
        self.addOldBoxTitleSpace = 10
        self.addHeightBoxTop = 48
        self.addHeightBoxBottom = 48
        self.addBoxBottomSign = 1 -- 标记不用动，1有标记根据剩余高度适配 2单独调整iphoneX
    elseif G_getIphoneType() == G_iphoneX then
        self.addDescY = 20
        self.addBoxBottomY = 20
        self.addOldBoxTitleSpace = 10
        self.addHeightBoxTop = 48
        self.addHeightBoxBottom = 100
        self.addBoxBottomSign = 2 -- 标记不用动，1有标记根据剩余高度适配 2单独调整iphoneX
        self.addNewBoxHeight = 130
    end
end

function acRyhgDialog:doUserHandler()
end

function acRyhgDialog:initTableView()
    local btnScale = self.btnScale
    local showTopY = self.showTopY
    local showTopWidth = G_VisibleSizeWidth
    local showTopHeight = self.showTopHeight

    -- 添加背景
    local function callBack(...)
        return self:eventHandlerBg(...)
    end
    local hd = LuaEventHandler:createHandler(callBack)
    self.tvBg = LuaCCTableView:createWithEventHandler(hd, CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 85), nil)
    self.tvBg:setPosition(ccp(0,0))
    self.bgLayer:addChild(self.tvBg)

    -- 上边显示Layer
    self.showLayerTop = CCLayer:create()
    self.showLayerTop:ignoreAnchorPointForPosition(false)
    self.showLayerTop:setAnchorPoint(ccp(0.5, 1))
    self.showLayerTop:setContentSize(CCSize(showTopWidth, showTopHeight))
    self.showLayerTop:setPosition(ccp(showTopWidth / 2, showTopY))
    self.bgLayer:addChild(self.showLayerTop)

    -- 梯形底
    local bgShade = LuaCCScale9Sprite:createWithSpriteFrameName("believerTimeBg.png", CCRect(103, 0, 2, 80), function () end)
    bgShade:setContentSize(CCSizeMake(showTopWidth, 80))
    bgShade:setAnchorPoint(ccp(0.5, 1))
    bgShade:setPosition(showTopWidth / 2, showTopHeight)
    self.showLayerTop:addChild(bgShade)

    -- 说明文字和底
    local topDescLb = GetTTFLabelWrap(getlocal("activity_ryhg_desc"), 22, CCSizeMake(showTopWidth - 120, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    local topDescBgSp = CCSprite:createWithSpriteFrameName("newblackFade.png")
    topDescBgSp:setOpacity(100)
    topDescBgSp:setAnchorPoint(ccp(0.5, 1))
    topDescBgSp:setScaleX((topDescLb:getContentSize().width + 50) / topDescBgSp:getContentSize().width)
    topDescBgSp:setScaleY((topDescLb:getContentSize().height + 30) / topDescBgSp:getContentSize().height)
    topDescBgSp:setPosition(bgShade:getPositionX(), bgShade:getPositionY() - 90 - self.addDescY)
    self.showLayerTop:addChild(topDescBgSp)
    topDescLb:setAnchorPoint(ccp(0.5, 1))
    topDescLb:setPosition(topDescBgSp:getPositionX(), topDescBgSp:getPositionY() - 15)
    topDescLb:setColor(G_ColorYellowPro)
    self.showLayerTop:addChild(topDescLb)

    -- 根据状态显示面板
    self.showType = acRyhgVoApi:getAcVo().hg
    if self.showType == 0 then
        -- 新注册玩家
        self:initNewPlayer()
    else
        self:initOldPlayer(self.showType)
    end
    
    -- 叹号说明
    local function touch(tag, object)
        PlayEffect(audioCfg.mouseClick)
        -- 说明按钮详细
        local tabStr = {}
        local tabColor = {}
        local tabAlignment = {}
        tabStr = {"\n", 
                getlocal("activity_ryhg_desc5"), "\n",
                getlocal("activity_ryhg_desc4"), "\n",
                getlocal("activity_ryhg_desc3"), "\n",
                getlocal("activity_ryhg_desc2", {acRyhgVoApi:getAcVo().notLoginDay}), "\n",
                getlocal("activity_ryhg_desc1", {acRyhgVoApi:getAcVo().notLoginDay}), "\n"
            }
        tabColor = {nil, nil, nil, nil, nil, nil}
        tabAlignment = {nil, nil, nil, nil, nil, nil}
        local td=smallDialog:new()
        local dialog=td:init("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
            nil, true, true, self.layerNum + 1, tabStr, 25, tabColor, nil, nil, nil, tabAlignment)
        sceneGame:addChild(dialog, self.layerNum + 1)
    end
    local menuItemDesc = GetButtonItem("i_sq_Icon1.png", "i_sq_Icon2.png", "i_sq_Icon1.png", touch)
    menuItemDesc:setAnchorPoint(ccp(0.5, 0.5))
    local menuDesc = CCMenu:createWithItem(menuItemDesc)
    menuDesc:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    menuDesc:setPosition(ccp(showTopWidth - 40, showTopHeight - 40))
    self.showLayerTop:addChild(menuDesc)

    -- 倒计时
    local timeLb = GetTTFLabel("", 25)
    timeLb:setAnchorPoint(ccp(0.5, 0))
    timeLb:setPosition(ccp(showTopWidth / 2, showTopHeight - 40))
    timeLb:setColor(G_ColorYellowPro)
    self.showLayerTop:addChild(timeLb)
    self.timeLb = timeLb
    -- 刷新倒计时
    self:tick()
end

-- 新玩家
function acRyhgDialog:initNewPlayer()
    local btnScale = self.btnScale
    local showTopY = self.showTopY
    local showTopWidth = G_VisibleSizeWidth
    local showTopHeight = self.showTopHeight

    -- 基础 CCLayer
    local bottomBg = CCLayer:create()
    bottomBg:ignoreAnchorPointForPosition(false)
    bottomBg:setAnchorPoint(ccp(0.5, 0.5))
    bottomBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, 675+self.addNewBoxHeight))
    if self.addBoxBottomSign > 0 then
        local tempY = showTopY-180-bottomBg:getContentSize().height/2
        if self.addBoxBottomSign == 2 then
            tempY = tempY-(tempY - bottomBg:getContentSize().height/2)*0.3+15
        else
            tempY = tempY-(tempY - bottomBg:getContentSize().height/2)*0.4+10
        end
        bottomBg:setPosition(self.showLayerTop:getPositionX(), tempY)
    else
        bottomBg:setPosition(self.showLayerTop:getPositionX(), showTopY-180-bottomBg:getContentSize().height/2)
    end
    self.bgLayer:addChild(bottomBg)
    -- 背景框
    local bottomShowBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    bottomShowBg:setContentSize(bottomBg:getContentSize())
    bottomShowBg:setPosition(bottomBg:getContentSize().width/2, bottomBg:getContentSize().height/2)
    bottomShowBg:setOpacity(255*0.7)
    bottomBg:addChild(bottomShowBg)

    -- 新人豪礼
    local topTitleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    topTitleBg:setAnchorPoint(ccp(0.5, 0.5))
    if self.addBoxBottomSign == 2 then
        topTitleBg:setPosition(self.showLayerTop:getPositionX(), bottomBg:getContentSize().height - 80)
    else
        topTitleBg:setPosition(self.showLayerTop:getPositionX(), bottomBg:getContentSize().height - 50)
    end
    bottomBg:addChild(topTitleBg)
    local titleLb = GetTTFLabel(getlocal("activity_ryhg_content_title3"), 24, true)
    titleLb:setPosition(topTitleBg:getContentSize().width/2, topTitleBg:getContentSize().height/2)
    titleLb:setColor(G_ColorYellowPro2)
    topTitleBg:addChild(titleLb)
    -- 说明
    local topBgDescLb = GetTTFLabelWrap(getlocal("activity_ryhg_content_desc3"), 22, CCSizeMake(showTopWidth - 120, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    topBgDescLb:setAnchorPoint(ccp(0.5, 0.5))
    if self.addBoxBottomSign == 2 then
        topBgDescLb:setPosition(bottomBg:getContentSize().width/2, topTitleBg:getPositionY()-120)
    else
        topBgDescLb:setPosition(bottomBg:getContentSize().width/2, topTitleBg:getPositionY()-90)
    end
    bottomBg:addChild(topBgDescLb)
    -- 输入框背景
    local inputBigBgSp = LuaCCScale9Sprite:createWithSpriteFrameName("rewardPanelBg3.png",CCRect(19,19,2,2),function () end)
    inputBigBgSp:setContentSize(CCSizeMake(565, 225))
    if self.addBoxBottomSign == 2 then
        inputBigBgSp:setPosition(bottomBg:getContentSize().width/2, topBgDescLb:getPositionY()-inputBigBgSp:getContentSize().height/2-topBgDescLb:getContentSize().height/2-50)
    else
        inputBigBgSp:setPosition(bottomBg:getContentSize().width/2, topBgDescLb:getPositionY()-inputBigBgSp:getContentSize().height/2-topBgDescLb:getContentSize().height/2-30)
    end
    bottomBg:addChild(inputBigBgSp)
    -- 黏贴和使用按钮
    local spaceWidth = 120
    local function onBottomBtnCallBack(tag, object)
        PlayEffect(audioCfg.mouseClick)

        if tag == 10 then
            -- 粘贴
            local codeStr = acRyhgVoApi:getFlybackCode()

            if self.textLabel then
                if codeStr == "" then
                    -- 保存的激活码为空
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                        getlocal("activity_ryhg_Tips5"), 28)
                else
                    -- 保存的激活码不为空
                end
                if codeStr == "" and self.textLabel:getString() == "" then
                    -- 只有复制的内容为空就提示
                elseif self.textLabel:getString() == "" then
                    self.textLabel:setString("" .. codeStr)
                elseif codeStr == "" then
                    codeStr = self.textLabel:getString()
                else
                    self.textLabel:setString("" .. codeStr)
                end
                if self.useVip <= 0 then
                    self.textLabel:setColor(G_ColorWhite)
                    self.textLabel:setVisible(true)
                end
            end
            if self.editBox then
                self.editBox:setText("" .. codeStr)
                self.editBox:setVisible(false)
            end
            if self.textTipsLb then
                self.textTipsLb:setVisible((codeStr == "" and self.textLabel:getString() == ""))
            end
        elseif tag == 11 then
            -- 使用
            if self.textLabel and self.textLabel:getString()=="" then -- 检测输入是否符合
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("backstage34006"),28)
                return
            end
            if self.textLabel and G_matchNumLetter(self.editBox:getText()) ~= nil then -- 检测输入是否符合
                smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("alliance_illegalCharacters"),28)
                return
            end

            local function callBack(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    -- 更新数据
                    acRyhgVoApi:updateData(sData.data.ryhg)
                    -- 更新奖励显示
                    local useVip = acRyhgVoApi:getAcVo().use or 0
                    self.useVip = useVip
                    local newReward = G_clone(acRyhgVoApi:getAcVo().newReward[useVip])
                    local tempVipNum = acRyhgVoApi:getAcVo().num or 0
                    local vipTab = {[acRyhgVoApi:getAcVo().returnVipItem]=tempVipNum, index=0} -- 这里数量得有，否则解析不出来，并且为之放到第一位
                    table.insert(newReward.p, vipTab)
                    self.newRewardList = FormatItem(newReward,false,true) or {}
                    self.tvNew:reloadData()

                    -- 按钮和文字显示
                    self.codeStateLb:setString(getlocal("activity_hadReward"))
                    self.textLabel:setColor(G_ColorGray)
                    self.editBox:setVisible(false)
                    object:setEnabled(false)
                    if self.pasteBtnItem then
                        self.pasteBtnItem:setEnabled(false)
                    end
                    local lb = object:getChildByTag(101)
                    if lb then
                        lb = tolua.cast(lb,"CCLabelTTF")
                        lb:setString(getlocal("activity_ryhg_acBtn4_2"))
                    end

                    -- 奖励添加
                    for k,v in pairs(self.newRewardList) do
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end
                    -- 奖励展示
                    local rewardlist = {}
                    for k,v in pairs(self.newRewardList) do
                        table.insert(rewardlist,v)
                    end
                    require "luascript/script/game/scene/gamedialog/rewardShowSmallDialog"
                    local titleStr=getlocal("EarnRewardStr")
                    local titleStr2 = ""
                    local function showEndHandler()
                    end
                    rewardShowSmallDialog:showNewReward(self.layerNum+1,true,true,rewardlist,showEndHandler,titleStr,titleStr2,nil,nil,"")
                    -- 使用成功飘字
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                        getlocal("activity_ryhg_Tips4"), 28)
                end
            end
            socketHelper:acRyhgUseCode(callBack, self.textLabel:getString())
        end
    end
    local pasteBtnItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onBottomBtnCallBack,100,getlocal("activity_ryhg_acBtn3"), 25/btnScale)
    pasteBtnItem:setScale(btnScale)
    pasteBtnItem:setPosition(-spaceWidth, 0)
    if self.useVip > 0 then
        pasteBtnItem:setEnabled(false)
    end
    self.pasteBtnItem = pasteBtnItem
    local useBtnName = getlocal("activity_ryhg_acBtn4")
    if self.useVip > 0 then
        useBtnName = getlocal("activity_ryhg_acBtn4_2")
    end
    local useBtnItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onBottomBtnCallBack,100,useBtnName, 25/btnScale,101)
    useBtnItem:setScale(btnScale)
    useBtnItem:setPosition(spaceWidth, 0)
    if self.useVip > 0 then
        useBtnItem:setEnabled(false)
    end
    local bottomMenu = CCMenu:create()
    bottomMenu:addChild(pasteBtnItem,0,10)
    bottomMenu:addChild(useBtnItem,0,11)
    bottomMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
    bottomMenu:setPosition(inputBigBgSp:getContentSize().width/2, 60)
    inputBigBgSp:addChild(bottomMenu)
    -- 输入框
    local inputSize = CCSize(295,54)
    -- 输入的灰色提示
    local textTipsLb = GetTTFLabelWrap(getlocal("activity_ryhg_inputTips"), 24, inputSize, kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    textTipsLb:setAnchorPoint(ccp(0.5,0.5))
    textTipsLb:setPosition(ccp(inputBigBgSp:getContentSize().width/2,inputBigBgSp:getContentSize().height-70))
    textTipsLb:setColor(G_ColorGray)
    inputBigBgSp:addChild(textTipsLb,2)
    self.textTipsLb = textTipsLb
    -- 当前内容
    local textLabel = GetTTFLabelWrap("", 24, inputSize, kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
    textLabel:setAnchorPoint(ccp(0,0.5))
    textLabel:setPosition(ccp(inputBigBgSp:getContentSize().width/2-inputSize.width/2+10,inputBigBgSp:getContentSize().height-70))
    inputBigBgSp:addChild(textLabel,2)
    self.textLabel = textLabel
    if self.useVip > 0 then
        self.textLabel:setColor(G_ColorGray)
    end
    -- 框
    local editBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("cin_mainChatBgSmall.png",CCRect(4,25,2,4),function() end)
    local function inputCallbcak(fn,eB,str,type)
        textTipsLb:setVisible(false)

        local curStr = ""
        if eB then
            curStr = eB:getText() or ""
        end
        if curStr == "" then
            textTipsLb:setVisible(true)
        end

        if type==0 then  -- 开始输入
        elseif type==1 then -- 检测文本发生变化
            if str == nil then
                str = ""
            end

            if str == "" then
                textTipsLb:setVisible(true)
            end
            eB:setText(str)
            if self.textLabel then
                self.textLabel:setString(str)
            end
        elseif type==2 then -- 检测文本输入结束
            eB:setVisible(false)
            if self.textLabel then
                self.textLabel:setVisible(true)
            end
        end
    end
    local editBox=CCEditBox:createForLua(CCSize(295,54),editBoxBg,nil,nil,inputCallbcak)
    editBox:setFont(textLabel.getFontName(textLabel), textLabel.getFontSize(textLabel)/2)
    editBox:setMaxLength(6)
    editBox:setInputMode(CCEditBox.kEditBoxInputModeSingleLine)
    editBox:setInputFlag(CCEditBox.kEditBoxInputFlagInitialCapsAllCharacters)
    editBox:setAnchorPoint(ccp(0.5,0.5))
    editBox:setPosition(ccp(inputBigBgSp:getContentSize().width/2,inputBigBgSp:getContentSize().height-70))
    editBox:setVisible(false)
    inputBigBgSp:addChild(editBox,1)
    local function showEditBox()
        if self.useVip > 0 then
            return
        end
        if self.textLabel then
            self.textLabel:setVisible(false)
        end
        editBox:setVisible(true)
    end
    local editBoxBg=LuaCCScale9Sprite:createWithSpriteFrameName("cin_mainChatBgSmall.png",CCRect(4,25,2,4),showEditBox)
    editBoxBg:setPosition(editBox:getPosition())
    editBoxBg:setContentSize(inputSize)
    editBoxBg:setTouchPriority(-(self.layerNum-1)*20-4)
    inputBigBgSp:addChild(editBoxBg)
    self.editBox=editBox

    if self.useVip > 0 then
        self.textTipsLb:setVisible(false)
        self.textLabel:setString(acRyhgVoApi:getAcVo().code or "")
    end

    -- 激活码奖励，未生成时只有图标
    local function eventHandler( ... )
        return self:eventHandlerNew( ... )
    end
    local hdSize = CCSizeMake(580, 110)
    local hd = LuaEventHandler:createHandler(eventHandler)
    self.tvNew = LuaCCTableView:createHorizontalWithEventHandler(hd, hdSize, nil)
    if self.addBoxBottomSign == 2 then
        self.tvNew:setPosition(ccp((G_VisibleSizeWidth-hdSize.width)/2 - 15, 130))
    else
        self.tvNew:setPosition(ccp((G_VisibleSizeWidth-hdSize.width)/2 - 15, 110))
    end
    -- self.tvNew:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 5)
    bottomBg:addChild(self.tvNew, 2)

    local codeStateLb
    if self.useVip > 0 then
        codeStateLb = GetTTFLabel(getlocal("activity_hadReward"), 24)
    else
        codeStateLb = GetTTFLabel(getlocal("activity_ryhg_Tips6"), 24)
    end
    if self.addBoxBottomSign == 2 then
        codeStateLb:setPosition(inputBigBgSp:getPositionX(), 70)
    else
        codeStateLb:setPosition(inputBigBgSp:getPositionX(), 60)
    end
    codeStateLb:setColor(G_ColorGray)
    bottomBg:addChild(codeStateLb)
    self.codeStateLb = codeStateLb
end

-- 老玩家
function acRyhgDialog:initOldPlayer(showType)
    local btnScale = self.btnScale
    local showTopY = self.showTopY
    local showTopWidth = G_VisibleSizeWidth
    local showTopHeight = self.showTopHeight

    -- 老服豪礼
    local topBoxSpace = self.addHeightBoxTop/4
    local topTitleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    topTitleBg:setAnchorPoint(ccp(0.5, 0.5))
    topTitleBg:setPosition(self.showLayerTop:getPositionX(), showTopY - 215 - self.addOldBoxTitleSpace)
    self.bgLayer:addChild(topTitleBg)
    local titleLb = GetTTFLabel(getlocal("activity_ryhg_content_title1"), 24, true)
    titleLb:setPosition(topTitleBg:getContentSize().width/2, topTitleBg:getContentSize().height/2)
    titleLb:setColor(G_ColorYellowPro2)
    topTitleBg:addChild(titleLb)
    -- 基础 CCLayer
    local topBg = CCLayer:create()
    topBg:ignoreAnchorPointForPosition(false)
    topBg:setAnchorPoint(ccp(0.5, 0.5))
    topBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, 265+self.addHeightBoxTop))
    topBg:setPosition(self.showLayerTop:getPositionX(), topTitleBg:getPositionY()-topBg:getContentSize().height/2-topTitleBg:getContentSize().height/2-10-self.addOldBoxTitleSpace/2)
    self.bgLayer:addChild(topBg)
    -- 背景
    local topShowBg = LuaCCScale9Sprite:createWithSpriteFrameName("believerRankItemBg.png", CCRect(18, 21, 1, 1), function()end)
    topShowBg:setContentSize(topBg:getContentSize())
    topShowBg:setPosition(topBg:getContentSize().width/2, topBg:getContentSize().height/2)
    topShowBg:setOpacity(255*0.8)
    topBg:addChild(topShowBg)
    -- 拿枪的姑娘
    local womanSp = CCSprite:createWithSpriteFrameName("charater_beautyGirl.png") --姑娘
    womanSp:setAnchorPoint(ccp(0, 0))
    womanSp:setPosition(-22, 6)
    topBg:addChild(womanSp)
    -- 说明
    local topBgDescLb = GetTTFLabelWrap(getlocal("activity_ryhg_content_desc1", {acRyhgVoApi:getAcVo().notLoginDay}), 22, CCSizeMake(showTopWidth - 240, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    topBgDescLb:setAnchorPoint(ccp(0.5, 0.5))
    topBgDescLb:setPosition(topBg:getContentSize().width/2+60, topBg:getContentSize().height-45-topBoxSpace)
    -- topBgDescLb:setColor(G_ColorYellowPro)
    topBg:addChild(topBgDescLb)

    if showType == 2 then
        -- 条件不满足
        local notCanLb = GetTTFLabel(getlocal("activity_ryhg_Tips1"), 24)
        notCanLb:setColor(G_ColorRed)
        notCanLb:setPosition(topBg:getContentSize().width/2+55, 40+topBoxSpace)
        topBg:addChild(notCanLb)
    else
        -- 领取按钮
        local function onTopBtnCallBack(tag, object)
            if self.tvOld:getIsScrolled() == true then
                do return end
            end
            PlayEffect(audioCfg.mouseClick)

            -- 领取老玩家奖励
            local function callBack(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    acRyhgVoApi:updateData(sData.data.ryhg)
                    object:setEnabled(false)
                    local lb = object:getChildByTag(101)
                    if lb then
                        lb = tolua.cast(lb,"CCLabelTTF")
                        lb:setString(getlocal("activity_hadReward"))
                    end

                    local rewardlist = self.rewardList
                    for k,v in pairs(rewardlist) do
                        G_addPlayerAward(v.type,v.key,v.id,v.num,nil,true)
                    end
                    smallDialog:showTipsDialog("PanelPopup.png",CCSizeMake(500,400),CCRect(0,0,400,350),CCRect(168,86,10,10),getlocal("receivereward_received_success"),28)
                    G_showRewardTip(rewardlist,true)
                end
            end
            socketHelper:acRyhgReward(callBack)
        end
        local topBtnName = getlocal("daily_scene_get")
        if acRyhgVoApi:getAcVo().r==1 then
            topBtnName = getlocal("activity_hadReward")
        end
        local topBtnItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onTopBtnCallBack,100,topBtnName, 25/btnScale,101)
        topBtnItem:setScale(btnScale)
        topBtnItem:setEnabled(acRyhgVoApi:getAcVo().r~=1)
        local topMenu = CCMenu:createWithItem(topBtnItem)
        topMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
        topMenu:setPosition(topBg:getContentSize().width/2+55, 40+topBoxSpace)
        topBg:addChild(topMenu)
    end

    -- 奖励内容
    local function eventHandler( ... )
        return self:eventHandler( ... )
    end
    local hdSize = CCSizeMake(440, 110)
    local hd = LuaEventHandler:createHandler(eventHandler)
    self.tvOld = LuaCCTableView:createHorizontalWithEventHandler(hd, hdSize, nil)
    self.tvOld:setPosition(ccp(140, 75+topBoxSpace*1.5))
    self.tvOld:setTableViewTouchPriority(-(self.layerNum - 1) * 20 - 5)
    topBg:addChild(self.tvOld, 2)

    -- 老服特权基础 CCLayer
    local bottomBoxSpace = self.addHeightBoxBottom/4
    local bottomBg = CCLayer:create()
    bottomBg:ignoreAnchorPointForPosition(false)
    bottomBg:setAnchorPoint(ccp(0.5, 0.5))
    bottomBg:setContentSize(CCSizeMake(G_VisibleSizeWidth - 30, 320+self.addHeightBoxBottom))
    if self.addBoxBottomSign > 0 then
        local tempY = (topBg:getPositionY()-topBg:getContentSize().height/2+10)/2
        if self.addBoxBottomSign == 2 then
            -- iphoneX
            tempY = topBg:getPositionY()-topBg:getContentSize().height/2-bottomBg:getContentSize().height/2-50
        end
        bottomBg:setPosition(self.showLayerTop:getPositionX(), tempY) 
    else
        bottomBg:setPosition(self.showLayerTop:getPositionX(), 190+self.addHeightBoxBottom/2) 
    end
    self.bgLayer:addChild(bottomBg)
    -- 背景
    local bottomShowBg = LuaCCScale9Sprite:createWithSpriteFrameName("rankKuang.png", CCRect(15, 15, 2, 2), function () end)
    bottomShowBg:setContentSize(bottomBg:getContentSize())
    bottomShowBg:setPosition(bottomBg:getContentSize().width/2, bottomBg:getContentSize().height/2)
    bottomShowBg:setOpacity(255*0.7)
    bottomBg:addChild(bottomShowBg)
    -- 标题
    local bottomTitleBg = CCSprite:createWithSpriteFrameName("believerTitleBg.png")
    bottomTitleBg:setAnchorPoint(ccp(0.5, 0.5))
    if self.addBoxBottomY > 0 then
        bottomTitleBg:setPosition(self.showLayerTop:getPositionX(), bottomBg:getPositionY()+bottomBg:getContentSize().height/2-bottomTitleBg:getContentSize().height/2-50-self.addBoxBottomY)
    else
        bottomTitleBg:setPosition(self.showLayerTop:getPositionX(), bottomBg:getPositionY()+bottomBg:getContentSize().height/2-40-bottomBoxSpace/2)
    end
    self.bgLayer:addChild(bottomTitleBg)
    local titleLb = GetTTFLabel(getlocal("activity_ryhg_content_title2"), 24, true)
    titleLb:setPosition(bottomTitleBg:getContentSize().width/2, bottomTitleBg:getContentSize().height/2)
    titleLb:setColor(G_ColorYellowPro2)
    bottomTitleBg:addChild(titleLb)
    local descFontSize,tipFontSize = 22,24
    if G_getCurChoseLanguage()=="de" then
        descFontSize,tipFontSize=18,20
    end
    -- 说明
    local bottomBgDescLb = GetTTFLabelWrap(getlocal("activity_ryhg_content_desc2", {acRyhgVoApi:getAcVo().notLoginDay}), descFontSize, CCSizeMake(showTopWidth - 100, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
    bottomBgDescLb:setAnchorPoint(ccp(0.5, 0.5))
    if self.addBoxBottomY > 0 then
        bottomBgDescLb:setPosition(self.showLayerTop:getPositionX(), bottomBg:getContentSize().height/2)
    else
        bottomBgDescLb:setPosition(self.showLayerTop:getPositionX(), bottomBg:getContentSize().height-135-bottomBoxSpace*1.5)
    end
    -- bottomBgDescLb:setColor(G_ColorYellowPro)
    bottomBg:addChild(bottomBgDescLb)
    -- 激活码
    local bottomActivationCodeLb = GetTTFLabel(getlocal("activity_ryhg_ActivationCode"), tipFontSize)
    bottomActivationCodeLb:setAnchorPoint(ccp(0, 0.5))
    if self.addBoxBottomY > 0 then
        bottomActivationCodeLb:setPosition(60, bottomActivationCodeLb:getContentSize().height/2+50+self.addBoxBottomY)
    else
        bottomActivationCodeLb:setPosition(60, 80+bottomBoxSpace)
    end
    bottomBg:addChild(bottomActivationCodeLb)
    local bottomActivationCodeBg = LuaCCScale9Sprite:createWithSpriteFrameName("cin_mainChatBgSmall.png",CCRect(4,25,2,4),function () end)
    bottomActivationCodeBg:setAnchorPoint(ccp(0, 0.5))
    bottomActivationCodeBg:setContentSize(CCSizeMake(200, 54))
    bottomActivationCodeBg:setPosition(bottomActivationCodeLb:getPositionX()+bottomActivationCodeLb:getContentSize().width, bottomActivationCodeLb:getPositionY())
    bottomBg:addChild(bottomActivationCodeBg)

    if showType == 2 then
        -- 激活码
        local codeStr = self.activationCodeDefault
        local activationCodeLb = GetTTFLabel(codeStr, tipFontSize)
        activationCodeLb:setAnchorPoint(ccp(0, 0.5))
        activationCodeLb:setPosition(20, bottomActivationCodeBg:getContentSize().height/2)
        activationCodeLb:setColor(G_ColorGray)
        bottomActivationCodeBg:addChild(activationCodeLb)
        -- 条件不满足
        local codeTipsLb = GetTTFLabelWrap(getlocal("activity_ryhg_Tips2"), tipFontSize, CCSizeMake(150, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
        codeTipsLb:setAnchorPoint(ccp(0.5, 0.5))
        codeTipsLb:setPosition(bottomBg:getContentSize().width-120, bottomActivationCodeLb:getPositionY())
        bottomBg:addChild(codeTipsLb)
    else
        -- 激活码
        local codeState = 0
        local codeStr = self.activationCodeDefault
        local codeBtnStr = getlocal("activity_ryhg_acBtn1")
        local backCode = acRyhgVoApi:getAcVo().code or ""
        if backCode ~= "" then
            codeState = 1
            codeStr = backCode
            codeBtnStr = getlocal("activity_ryhg_acBtn2")
        end
        if self.useVip == 1 then
            codeState = 2
            -- 已使用
            codeBtnStr = getlocal("activity_ryhg_acBtn4_2")
        end
        local activationCodeLb = GetTTFLabel(codeStr, tipFontSize)
        activationCodeLb:setAnchorPoint(ccp(0, 0.5))
        activationCodeLb:setPosition(20, bottomActivationCodeBg:getContentSize().height/2)
        bottomActivationCodeBg:addChild(activationCodeLb)
        -- 按钮
        local function onBottomBtnCallBack(tag, object)
            if self.tvOld:getIsScrolled() == true then
                do return end
            end
            PlayEffect(audioCfg.mouseClick)

            if tag == 2 then
                -- 复制
                acRyhgVoApi:setFlybackCode("" .. acRyhgVoApi:getAcVo().code)

                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                        getlocal("activity_ryhg_Tips3"), 28)
                return
            end

            if playerVoApi:getVipLevel()<=0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                        getlocal("activity_ryhg_Tips8"), 28)
                return
            end

            -- 生成激活码
            local function callBack(fn, data)
                local ret, sData = base:checkServerData(data)
                if ret == true then
                    acRyhgVoApi:updateData(sData.data.ryhg)
                    object:setTag(2)
                    local lb = object:getChildByTag(101)
                    if lb then
                        lb = tolua.cast(lb,"CCLabelTTF")
                        lb:setString(getlocal("activity_ryhg_acBtn2"))
                    end
                    if activationCodeLb then
                        activationCodeLb:setString("" .. acRyhgVoApi:getAcVo().code)
                        activationCodeLb:setColor(G_ColorWhite)
                    end

                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10),
                            getlocal("activity_ryhg_Tips7"), 28)
                end
            end
            socketHelper:acRyhgMakeCode(callBack)
        end
        local bottomBtnItem = GetButtonItem("newGreenBtn.png","newGreenBtn_down.png","newGreenBtn_down.png",onBottomBtnCallBack,100,codeBtnStr, 25/btnScale,101)
        bottomBtnItem:setScale(btnScale)
        if codeState == 2 then
            bottomBtnItem:setEnabled(false)
            activationCodeLb:setColor(G_ColorGray)
        elseif codeState == 1 then
            bottomBtnItem:setTag(2)
            activationCodeLb:setColor(G_ColorWhite)
        else
            bottomBtnItem:setTag(1)
            activationCodeLb:setColor(G_ColorGray)
        end
        local bottomMenu = CCMenu:createWithItem(bottomBtnItem)
        bottomMenu:setTouchPriority(-(self.layerNum - 1) * 20 - 5)
        bottomMenu:setPosition(bottomBg:getContentSize().width-100, bottomActivationCodeLb:getPositionY())
        bottomBg:addChild(bottomMenu)
    end
end

function acRyhgDialog:eventHandler(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
         return SizeOfTable(self.rewardList)
    elseif fn == "tableCellSizeForIndex" then
        return  CCSizeMake(110, 110)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth = 110
        local cellHeight = 110

        if self.rewardList and next(self.rewardList) then
            local v = self.rewardList[idx+1]
            local function showPropInfo()
               G_showNewPropInfo(self.layerNum+1,true,true,nil,v,false,nil,nil,nil,true) 
            end
            local icon, scale = G_getItemIcon(v, 90, false, self.layerNum + 1, showPropInfo, self.tvOld)
            icon:setPosition(ccp(cellWidth/2, cellHeight/2))
            icon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            cell:addChild(icon, 1)

            local numLabel = GetTTFLabel("x" .. FormatNumber(v.num), 22)
            numLabel:setAnchorPoint(ccp(1, 0))
            numLabel:setPosition(icon:getContentSize().width - 5, 5)
            numLabel:setScale(1 / scale)
            icon:addChild(numLabel, 1)
        end

        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded"  then
    end
end


function acRyhgDialog:eventHandlerNew(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
         return SizeOfTable(self.newRewardList)
    elseif fn == "tableCellSizeForIndex" then
        return  CCSizeMake(116, 110)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()
        
        local cellWidth = 116
        local cellHeight = 110

        if self.newRewardList and next(self.newRewardList) then
            local v = self.newRewardList[idx+1]
            local icon, scale = G_getItemIcon(v, 100, true, self.layerNum + 1, nil, self.tvNew, nil, nil, not (self.useVip > 0))
            icon:setPosition(ccp(cellWidth/2, cellHeight/2))
            icon:setTouchPriority(-(self.layerNum - 1) * 20 - 4)
            cell:addChild(icon, 1)

            if self.useVip > 0 then
                local numLabel = GetTTFLabel("x" .. FormatNumber(v.num), 22)
                numLabel:setAnchorPoint(ccp(1, 0))
                numLabel:setPosition(icon:getContentSize().width - 5, 5)
                numLabel:setScale(1 / scale)
                icon:addChild(numLabel, 1)
            end
        end

        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded"  then
    end
end

function acRyhgDialog:eventHandlerBg(handler, fn, idx, cel)
    if fn == "numberOfCellsInTableView" then
         return 1
    elseif fn == "tableCellSizeForIndex" then
        return  CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight - 85)
    elseif fn == "tableCellAtIndex" then
        local cell = CCTableViewCell:new()
        cell:autorelease()

        -- 网络下载的图
        local function onLoadIcon(fn, webImage)
            if cell then
                webImage:setAnchorPoint(ccp(0.5, 0))
                webImage:setPosition(ccp(G_VisibleSizeWidth/2, 0))
                cell:addChild(webImage)
            end
        end
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
        local webImage = LuaCCWebImage:createWithURL(G_downloadUrl("active/acRyhgBg.jpg"), onLoadIcon)
        CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)

        return cell
    elseif fn == "ccTouchBegan" then
        self.isMoved = false
        return true
    elseif fn == "ccTouchMoved" then
        self.isMoved = true
    elseif fn == "ccTouchEnded"  then
    end
end

function acRyhgDialog:tick()
    if acRyhgVoApi:isEnd() == true then
        self:close()
        do return end
    end

    local acVo = acRyhgVoApi:getAcVo()
    if acVo and self.timeLb and tolua.cast(self.timeLb, "CCLabelTTF") then
        self.timeLb:setString(acRyhgVoApi:getTimeStr())
    end
end

function acRyhgDialog:dispose()
    self.editBox = nil
    self.showLayerTop = nil
    self.timeLb = nil
    self.textLabel = nil
    self.textTipsLb = nil
    self.codeStateLb = nil
    self.pasteBtnItem = nil
    self.rewardList = nil
    self.newRewardList = nil

    spriteController:removePlist("public/xsjx.plist")
    spriteController:removeTexture("public/xsjx.png")
    spriteController:removePlist("public/believer/believerMain.plist")
    spriteController:removeTexture("public/believer/believerMain.png")
end