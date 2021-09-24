loginScene = {
    loginLayer,
    loginClickEnable = true,
    curServerName,
    labelLastLogin, --显示的账号类型   推荐？已选？上次登陆
    labelSvrName, --与显示账号对应的服务器名称
    isShowing = false,
    selectedSvr = false, --已选择服务器？
    loginSuccess = false,
    tickHandlerIndex = -1,
    serverTxtBg, --选择服务器文字的背景
    aniMationSpTb = {}, --动画sp表
    kakaoBgSp,
    hexieBgShowed = false,
    hexieBgPlayEnd = false,
    acceptPk = true, --是否接受游戏内pk玩法
}
--登陆游戏方法
function loginScene:loginGame() --游客登陆按钮
    if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 8 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 9 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 10 then --rayjoy账号系统
        local tmpTb = {}
        tmpTb["action"] = "quickLogin"
        local cjson = G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
        base.loginAccountType = 2
    end
    
    local function callBack(fn, data)
        local sData = G_Json.decode(tostring(data))
        --OBJDEF:decode(data)
        if sData.ret == -1 then
            --用户名或密码不正确
            socketHelper:receivedResponse(sData["cmd"], sData["rnum"])
            local function onConfirm()
                if(base and base.changeServer)then
                    self:close()
                    base:changeServer()
                end
            end
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("netiswrong"), nil, 4, nil, onConfirm)
            base:cancleWait()
            base:cancleNetWait()
            do return end
        end
        G_setTankIsguest("1")
        healthyApi:setIsguest(true)
        local ret = self:loginCallBack(fn, data, sData) --处理登录返回数据
        if ret == false then
            do
                base:cancleWait()
                base:cancleNetWait()
                G_cancleLoginLoading()
                return
            end
        end
        if(G_curPlatName() == "21" and G_Version >= 7)then
            local tmpTb = {}
            tmpTb["action"] = "gameLoginCallback"
            local cjson = G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        end
        --阿拉伯的特殊需求，clanUserID
        if(G_curPlatName() == "androidarab")then
            local tmpTb = {}
            tmpTb["action"] = "customAction"
            tmpTb["parms"] = {}
            tmpTb["parms"]["value"] = "getClanPlayCpUserId"
            local cjson = G_Json.encode(tmpTb)
            local clanUserID = G_accessCPlusFunction(cjson)
            if(clanUserID and clanUserID ~= "")then
                base.clanUserID = clanUserID
            end
        end
        self:showBindWhenLogin()
    end
    mainloading:login(self.curServerName, callBack, true) --这两种情况都得是true,都得user.check
end


function loginScene:loginCallBack(fn, data, sData)
    self.loginSuccess = true
    CCUserDefault:sharedUserDefault():setStringForKey(G_local_lastLoginSvr, self.curServerName)
    -- if G_isIphone5()==true then
    --   require "luascript/script/config/gameconfig/otherGuideCfg_i5"
    -- else
    require "luascript/script/config/gameconfig/otherGuideCfg"
    -- end
    require "luascript/script/game/newguid/otherGuideMgr"
    
    local ret, jsonD = base:checkServerData(data, false)
    if ret == false then
        do
            return false
        end
    end
    base.lastSelectedServer = self.curServerName
    sceneGame = CCScene:create()
    G_cancleLoginLoading(); --取消登录loading
    CCDirector:sharedDirector():replaceScene(sceneGame)
    skillVoApi:init()
    emblemVoApi:initdefault()
    technologyVoApi:init({0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
    base:formatPlayerData(sData)
    base.releaseLoadingImg = true
    base:init()
    G_initGlobalVar() --初始化一下部分全局变量,必须放在base:formatPlayerData(sData)后面
    protocolController:init()
    G_addRequestQueue()
    buildingCueMgr:init()
    worldScene:init()
    heroVoApi:relationHeroInfo()
    
    --登录的时候纪录最近登陆的服务器
    local recentLogin = {}
    local rectLg
    for i = 1, 100 do
        rectLg = CCUserDefault:sharedUserDefault():getStringForKey(tostring(G_local_rectLoginSvr..i))
        if rectLg ~= "" then
            local k1, k2 = Split(rectLg, ",")[1], Split(rectLg, ",")[2]
            --if serverCfg:checkServerValid(k1,k2) then  --当前有效的登陆过的服务器
            table.insert(recentLogin, 1, {k1 = k1, k2 = k2})
            --end
        end
    end
    CCUserDefault:sharedUserDefault():setStringForKey(G_local_rectLoginSvr..(SizeOfTable(recentLogin) + 1), self.curServerName)
    CCUserDefault:sharedUserDefault():flush()
    --登录的时候纪录最近登陆的服务器
    
    mainUI:showUI()
    --三周年通知页面flag
    if(noticeMgr)then
        noticeMgr:setFirstLogin()
        local flag = noticeMgr:isShowNoticeDialog()
        if flag == true then
            noticeMgr:downloadNoticeImage()
        end
    end
    
    -- if base.platformUserId=="MMY_6709984" or  base.platformUserId=="QH_498721088" or  base.platformUserId=="Mi_64567211" or base.platformUserId=="QH_1378981164"  or base.platformUserId=="Mi_27725081" then
    --       local bhurl="http://tank-android-01.raysns.com/tankheroclient/jlbh.php?plat="..G_curPlatName().."&deviceid="..deviceids.."&platid="..base.platformUserId
    --       HttpRequestHelper:sendAsynHttpRequest(bhurl,"")
    -- end
    
    if base.platformUserId == "QH_498721088" or base.platformUserId == "Mi_64567211" or base.platformUserId == "QH_1378981164" or base.platformUserId == "QH_652491077" or base.platformUserId == "QH_1444240289" or base.platformUserId == "QH_122678114" then --应对版号审核,写死48小时后必更新
        
        local recordDstr = CCUserDefault:sharedUserDefault():getIntegerForKey("bhlastVersion")
        local tcbz = false
        if recordDstr ~= nil and tonumber(recordDstr) > 0 then
            if math.abs(base.serverTime - tonumber(recordDstr)) > 48 * 3600 then
                tcbz = true
            end
        else
            tcbz = true
        end
        
        if tcbz == true then
            CCUserDefault:sharedUserDefault():setIntegerForKey("bhlastVersion", base.serverTime)
            CCUserDefault:sharedUserDefault():flush()
            CCUserDefault:sharedUserDefault():setStringForKey("current-version-code", "0");
            CCUserDefault:sharedUserDefault():flush()
            CCUserDefault:sharedUserDefault():flush()
            
            local function sureCallBackHandler()
                
                G_cancleLoginLoading()
                local ccsp = CCSprite:create()
                sceneGame:addChild(ccsp)
                ccsp:release()
                ccsp:release()
            end
            
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), "发现了新版本，退出游戏重新启动游戏后即可开始自动更新"..recordDstr, nil, 8, nil, sureCallBackHandler)
            
        end
    end
    
    --
    
    G_sendGFdata()
    
    local numKey = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_buildingDisplay")
    local playerLv = playerVoApi:getPlayerLevel()
    if numKey == 0 and playerLv == 1 then
        CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_buildingDisplay", 2)
        CCUserDefault:sharedUserDefault():flush()
    elseif numKey == 0 and playerLv > 1 then
        CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_buildingDisplay", 1)
        CCUserDefault:sharedUserDefault():flush()
    end
    
    --CCTextureCache:sharedTextureCache():removeTextureForKeyForce("public/logo_effect.png")
    if playerVoApi:getTutorial() < 10 and GM_UidCfg[playerVoApi:getUid()] == nil then --是否是新手引导
        newGuidMgr.isGuiding = true
        sceneController:changeSceneByIndex(0)
        if G_isApplyVersion() == true then --如果是提审服登录游戏后跳过新手引导直接进入显示创建玩家昵称的引导
            playerVoApi:setTutorial(9)
        end
        newGuidMgr:setCurTask(playerVoApi:getTutorial())
        
        local tmpTb = {}
        tmpTb["action"] = "newPlayerGuidStart"
        local cjson = G_Json.encode(tmpTb)
        content = G_accessCPlusFunction(cjson)
    else
        if platCfg.platNewGuideVersion[G_curPlatName()] == 1 and GM_UidCfg[playerVoApi:getUid()] == nil then
            newGuidMgr:init()
        end
        sceneController:changeSceneByIndex(0)
    end
    local musicSetting = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_musicSetting")
    if musicSetting == 2 then
        PlayBackGroundEffect(audioCfg.backGround)
    end
    if G_curPlatName() == "15" and newGuidMgr:isNewGuiding() == false then
        local tmpTb = {}
        tmpTb["action"] = "firstGetUserName"
        local cjson = G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
    end
    
    --[[print("base.isWinter------->",base.isWinter)
          if base.isWinter then
            local skinSetting = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_seasonEffect2017")--默认开关
            if skinSetting==0 then
              CCUserDefault:sharedUserDefault():setIntegerForKey("gameSettings_seasonEffect2017",1)
              CCUserDefault:sharedUserDefault():flush()
            elseif skinSetting==1 then
              G_isOpenWinterSkin = false
              G_setWholeSkin(false)
            else
              G_isOpenWinterSkin = true
              G_setWholeSkin(true)
            end
          end
          G_initWinterSkinFirst()]]
    
    -- if base.isWinter then
    --   local skinSetting = CCUserDefault:sharedUserDefault():getIntegerForKey("gameSettings_seasonEffect2017")--默认开关
    --   local showSkinTipWithTime = CCUserDefault:sharedUserDefault():getIntegerForKey("showSkinTipWithTime") --上一次关闭提示板的时间戳
    --   local isShowSkinTip = CCUserDefault:sharedUserDefault():getBoolForKey("isShowSkinTip") --是否不再提示   因为默认是false 所以 对勾悬了 不提示用true
    --   -- print("base.isWinter---------skinSetting------>",base.isWinter,skinSetting,showSkinTipWithTime,isShowSkinTip,newGuidMgr:isNewGuiding())
    --   if newGuidMgr:isNewGuiding() ==false  then
    
    --       if skinSetting == 2 then
    
    --          local isDownWinterSkin = CCUserDefault:sharedUserDefault():getIntegerForKey("isDownWinterSkin")
    --          -- print("isDownWinterSkin------->",isDownWinterSkin)
    --          if isDownWinterSkin ==2 then
    --             G_isOpenWinterSkin = true
    --             G_setWholeSkin(G_isOpenWinterSkin)
    --          elseif showSkinTipWithTime ==0 or (isShowSkinTip == false and showSkinTipWithTime and G_isToday(showSkinTipWithTime) ==false) then
    --             G_downNewMapAndInitWinterSkin()
    --          end
    
    --       elseif showSkinTipWithTime ==0 or (isShowSkinTip == false and showSkinTipWithTime and G_isToday(showSkinTipWithTime) ==false) then
    --           G_downNewMapAndInitWinterSkin()
    --       end
    --   elseif skinSetting ==2 and isShowSkinTip ==true then
    --       -- print("newGuidMgr------>",newGuidMgr:isNewGuiding())
    --       G_isOpenWinterSkin = true
    --       G_setWholeSkin(G_isOpenWinterSkin)
    
    --   end
    -- end
    
    mainUI:touchLuaSpExpnd()
    if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 8 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 9 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 10 then --rayjoy 账号系统
        if base.loginAccountType == 0 then --fb
            local tmpTb = {}
            tmpTb["action"] = "facebookLoginCallback"
            tmpTb["parms"] = {}
            tmpTb["parms"]["error"] = "0"
            tmpTb["parms"]["uid"] = jsonD.uid
            tmpTb["parms"]["isNew"] = (base.serverTime - playerVoApi:getRegdate()) < 10 and 1 or 0
            local cjson = G_Json.encode(tmpTb)
            print("rayjoyFacebook登录成功", cjson)
            G_accessCPlusFunction(cjson)
            
        elseif base.loginAccountType == 1 then --rayjoy
            local tmpTb = {}
            tmpTb["action"] = "showLoginCallback"
            tmpTb["parms"] = {}
            tmpTb["parms"]["error"] = "0"
            tmpTb["parms"]["uid"] = jsonD.uid
            tmpTb["parms"]["isNew"] = (base.serverTime - playerVoApi:getRegdate()) < 10 and 1 or 0
            local cjson = G_Json.encode(tmpTb)
            print("rayjoy登录成功", cjson)
            G_accessCPlusFunction(cjson)
            
            -------以下代码在rayjoy账号自动登录时使用
            CCUserDefault:sharedUserDefault():setStringForKey("rayjoyAccountUname", base.tmpUserName)
            CCUserDefault:sharedUserDefault():setStringForKey("rayjoyAccountPwd", base.tmpUserPassword)
            G_saveHistoryAccount({base.tmpUserName, base.tmpUserPassword, base.serverTime})
            CCUserDefault:sharedUserDefault():flush()
            -------以上代码在rayjoy账号自动登录时使用
            
        elseif base.loginAccountType == 2 then --游客
            local tmpTb = {}
            tmpTb["action"] = "quickLoginCallback"
            tmpTb["parms"] = {}
            tmpTb["parms"]["error"] = "0"
            tmpTb["parms"]["uid"] = jsonD.uid
            tmpTb["parms"]["isNew"] = (base.serverTime - playerVoApi:getRegdate()) < 10 and 1 or 0
            local cjson = G_Json.encode(tmpTb)
            print("visitor登录成功", cjson)
            G_accessCPlusFunction(cjson)
        end
        -------以下代码在rayjoy账号自动登录时使用
        print("记录下是哪个", base.loginAccountType)
        CCUserDefault:sharedUserDefault():setStringForKey("rayjoyAccountLastLoginType", base.loginAccountType)--记录最后一次登录的账号类型
        CCUserDefault:sharedUserDefault():flush()
        -------以上代码在rayjoy账号自动登录时使用
    end
    
    --CCTextureCache:sharedTextureCache():removeTextureForKeyForce("scene/lodingxin.jpg")
    --CCTextureCache:sharedTextureCache():dumpCachedTextureInfo()
    pushController:init()
    require "luascript/script/global/skinMgr"
    skinMgr:init()
    self:close()

    statisticsHelper:uploadOption("ui") --统计用户使用UI版本数量

    return true
end

--显示历史账号下拉列表
function loginScene:showHistoryAccount(editBoxWidth, editBoxRightBottomPos, selectedCallback)
    local function close()
        self.listLayer:removeFromParentAndCleanup(true)
        self.listLayer = nil
    end
    if self.listLayer then
        close()
    end
    local touchPriority = 120
    self.listLayer = CCLayer:create()
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(self.listLayer, 4)
    
    local touchDialogBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), close)
    touchDialogBg:setTouchPriority(-touchPriority)
    touchDialogBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
    touchDialogBg:setAnchorPoint(ccp(0.5, 0.5))
    touchDialogBg:setPosition(ccp(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2))
    touchDialogBg:setOpacity(0)
    self.listLayer:addChild(touchDialogBg)
    
    local listBg = LuaCCScale9Sprite:createWithSpriteFrameName("login_historyAccountBg.png", CCRect(9, 9, 2, 2), function()end)
    listBg:setContentSize(CCSizeMake(editBoxWidth, 220))
    listBg:setAnchorPoint(ccp(1, 1))
    listBg:setPosition(editBoxRightBottomPos.x, editBoxRightBottomPos.y + 20)
    listBg:setTouchPriority(-(touchPriority + 1))
    -- listBg:setBSwallowsTouches(false)
    self.listLayer:addChild(listBg)
    
    local accountList = G_getHistoryAccount()
    local accountListSize = SizeOfTable(accountList or {})
    local listSize = CCSizeMake(listBg:getContentSize().width - 6, listBg:getContentSize().height - 6)
    local list
    local function tvCallBack(handler, fn, idx, cel)
        if fn == "numberOfCellsInTableView" then
            return accountListSize
        elseif fn == "tableCellSizeForIndex" then
            return CCSizeMake(listSize.width, 60)
        elseif fn == "tableCellAtIndex" then
            local cell = CCTableViewCell:new()
            cell:autorelease()
            local cellW, cellH, index = listSize.width, 60, idx + 1
            local accountStr = accountList[index][1]
            local passwordStr = accountList[index][2]
            
            local clickSp = LuaCCScale9Sprite:createWithSpriteFrameName("BlackAlphaBg.png", CCRect(10, 10, 1, 1), function()
                if type(selectedCallback) == "function" then
                    close()
                    selectedCallback({accountStr, passwordStr})
                end
            end)
            clickSp:setContentSize(CCSizeMake(cellW - 5, cellH - 5))
            clickSp:setPosition(cellW / 2, cellH / 2)
            clickSp:setTouchPriority(-(touchPriority + 1))
            clickSp:setOpacity(0)
            cell:addChild(clickSp)
            
            local accoutLb = GetTTFLabel(accountStr, 25)
            accoutLb:setAnchorPoint(ccp(0, 0.5))
            accoutLb:setPosition(10, cellH / 2)
            cell:addChild(accoutLb)
            
            local deleteSp = LuaCCSprite:createWithSpriteFrameName("login_historyAccount_itemClose.png", function()
                table.remove(accountList, index)
                accountListSize = SizeOfTable(accountList or {})
                list:reloadData()
                G_saveHistoryAccount(accountList, true)
            end)
            deleteSp:setAnchorPoint(ccp(1, 0.5))
            deleteSp:setPosition(cellW - 15, cellH / 2)
            deleteSp:setTouchPriority(-(touchPriority + 1))
            cell:addChild(deleteSp)
            
            if index < accountListSize then
                local lineSp = LuaCCScale9Sprite:createWithSpriteFrameName("login_historyAccount_line.png", CCRect(0, 0, 1, 1), function()end)
                lineSp:setContentSize(CCSizeMake(cellW, 2))
                lineSp:setPosition(cellW / 2, 0)
                cell:addChild(lineSp)
            end
            return cell
        elseif fn == "ccTouchBegan" then
            return true
        elseif fn == "ccTouchMoved" then
        elseif fn == "ccTouchEnded" then
        end
    end
    local hd = LuaEventHandler:createHandler(tvCallBack)
    list = LuaCCTableView:createWithEventHandler(hd, listSize, nil)
    list:setPosition(ccp(3, 3))
    list:setTableViewTouchPriority(-(touchPriority + 2))
    list:setMaxDisToBottomOrTop(100)
    listBg:addChild(list)
end

--弹出账号设置板子
function loginScene:showAccountSettings(settingType)
    local sstype = settingType or 1
    self.loginLayer:setVisible(false)
    PlayEffect(audioCfg.mouseClick)
    local function touch()
        
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- local bgSp=LuaCCSprite:createWithFileName("scene/lodingxin.jpg",touch);
    -- bgSp:setIsSallow(true)
    -- bgSp:setTouchPriority(-22)
    self.accoutLayer = CCLayer:create()
    --local bgSp=CCSprite:create("scene/lodingxin.jpg");
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    -- bgSp:setPosition(getCenterPoint(self.loginLayer))
    local runningScene = CCDirector:sharedDirector():getRunningScene()
    runningScene:addChild(self.accoutLayer, 3)
    --bgSp:setTouchPriority(-21);
    local function tmpFunc()
        
    end
    
    local bgLayer = LuaCCScale9Sprite:createWithSpriteFrameName("newLoginPanel.png", CCRect(4, 4, 2, 2), tmpFunc)
    bgLayer:setIsSallow(true)
    bgLayer:setTouchPriority(-21)
    local rect = CCSizeMake(640, 580)
    bgLayer:setContentSize(rect)
    bgLayer:ignoreAnchorPointForPosition(false)
    bgLayer:setAnchorPoint(CCPointMake(0.5, 0.5))
    bgLayer:setPosition(CCPointMake(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    self.accoutLayer:addChild(bgLayer)
    self.loginPanelLayer = bgLayer
    
    local fadeBg = LuaCCScale9Sprite:createWithSpriteFrameName("loginPanelFadeBg.png", CCRect(0, 0, 1, 212), function () end)
    fadeBg:setContentSize(CCSizeMake(bgLayer:getContentSize().width, fadeBg:getContentSize().height))
    fadeBg:setAnchorPoint(ccp(0.5, 1))
    fadeBg:setPosition(bgLayer:getContentSize().width / 2, bgLayer:getContentSize().height - 58)
    bgLayer:addChild(fadeBg)
    
    local bottomLineSp = LuaCCScale9Sprite:createWithSpriteFrameName("newPanelBgLine.png", CCRect(17, 0, 2, 6), function () end)
    bottomLineSp:setContentSize(CCSizeMake(200, 6))
    bottomLineSp:setPosition(bgLayer:getContentSize().width / 2, bottomLineSp:getContentSize().height / 2)
    bgLayer:addChild(bottomLineSp)
    
    local leftTitleBg = CCSprite:createWithSpriteFrameName("newlogin_titlebg.png")
    leftTitleBg:setPosition(bgLayer:getContentSize().width / 2 - leftTitleBg:getContentSize().width / 2, bgLayer:getContentSize().height - leftTitleBg:getContentSize().height / 2)
    bgLayer:addChild(leftTitleBg)
    
    local rightTitleBg = CCSprite:createWithSpriteFrameName("newlogin_titlebg.png")
    rightTitleBg:setFlipX(true)
    rightTitleBg:setPosition(bgLayer:getContentSize().width / 2 + rightTitleBg:getContentSize().width / 2, bgLayer:getContentSize().height - rightTitleBg:getContentSize().height / 2)
    bgLayer:addChild(rightTitleBg)
    
    self.accountShowType = 1 --(1：登录账号页面，2：绑定邮箱页面，3：密码重置页面，4：注册页面)
    
    --关闭设置账号面板
    local function close()
        if self.accountShowType == 1 then --当前是登录账号页面，点击返回则回到主页面
            self:closeAccountLoginLayer(true)
        elseif self.accountShowType == 2 or self.accountShowType == 3 or self.accountShowType == 4 then --当前是绑定邮箱、密码重置、注册页面，点击返回则回到账号登录页面
            self:showAccountLoginLayer(sstype, self.accountShowType)
        end
    end
    local priority = -24
    G_createBotton(bgLayer, ccp(49 * 0.5, bgLayer:getContentSize().height - 58 * 0.5), {}, "newlogin_backBtn.png", "newlogin_backBtn_down.png", "newlogin_backBtn_down.png", close, 1, priority, 2)
    
    local titleStr = getlocal("accountSetting")
    if sstype == 2 then
        titleStr = getlocal("registerGameStr")
    end
    local titleLb = GetTTFLabel(titleStr, 30, true)
    titleLb:setAnchorPoint(ccp(0.5, 0.5))
    titleLb:setColor(G_ColorYellowPro)
    titleLb:setPosition(ccp(bgLayer:getContentSize().width / 2, leftTitleBg:getPositionY()))
    bgLayer:addChild(titleLb, 2)
    self.titleLb = titleLb
    
    --账号登录页面
    self:showAccountLoginLayer(sstype)
end

--显示账号登录页面
function loginScene:showAccountLoginLayer(sstype, fromType)
    self.accountShowType = 1
    local rayjoyUname, rayjoyPwd = base.tmpUserName or "", base.tmpUserPassword or ""
    if sstype == 2 then
        self.accountShowType = 4 --注册账号
    end
    if self.accountShowType == 1 and fromType ~= 2 then
        if G_loginType == 2 and (G_curPlatName() == "20" or G_curPlatName() == "androidjapan" or G_curPlatName() == "0" or G_curPlatName() == "31" or platCfg.platCfgRecordUserAccount[G_curPlatName()] ~= nil) then
            rayjoyUname = CCUserDefault:sharedUserDefault():getStringForKey("rayjoyAccountUname")
            rayjoyPwd = CCUserDefault:sharedUserDefault():getStringForKey("rayjoyAccountPwd")
            
            base.tmpUserName = rayjoyUname
            base.tmpUserPassword = rayjoyPwd
            -- print("base.tmpUserName,base.tmpUserPassword==>",base.tmpUserName,base.tmpUserPassword)
        end
    elseif self.accountShowType == 4 then --注册账号需要清空账号密码
        base.tmpUserName = ""
        base.tmpUserPassword = ""
        rayjoyUname, rayjoyPwd = "", ""
    end
    local isShowVisitor = true
    if G_isBindMailAndResetPwd() == true and G_isApplyVersion() == false then --审核通过后不显示游客登录按钮
        isShowVisitor = false
    elseif G_curPlatName() == "51" then
        isShowVisitor = false
    end
    if self.acccountLoginLayer == nil then
        self.acccountLoginLayer = CCNode:create()
        self.acccountLoginLayer:setContentSize(CCSizeMake(self.loginPanelLayer:getContentSize().width, self.loginPanelLayer:getContentSize().height))
        self.acccountLoginLayer:setAnchorPoint(ccp(0.5, 0.5))
        self.acccountLoginLayer:setPosition(getCenterPoint(self.loginPanelLayer))
        self.loginPanelLayer:addChild(self.acccountLoginLayer, 2)
        
        local function tthandler()
            
        end
        local function close()
            self:closeAccountLoginLayer()
        end
        local function callBackUserNameHandler(fn, eB, str, type)
            if str ~= nil then
                base.tmpUserName = str
                -- print("更新了用户名", str)
            end
        end
        
        local function callBackPassWordHandler(fn, eB, str, type)
            
            if str ~= nil then
                base.tmpUserPassword = str
                -- print("更新了密码", str)
            end
        end
        
        local accountBox = LuaCCScale9Sprite:createWithSpriteFrameName("newlogin_inputkuang.png", CCRect(30, 30, 2, 2), tthandler)
        accountBox:setContentSize(CCSize(400, accountBox:getContentSize().height))
        accountBox:setPosition(ccp(360, 400))
        self.acccountLoginLayer:addChild(accountBox)
        
        local ebFlag = nil
        if G_isBindMailAndResetPwd() == true then
            ebFlag = true
        end
        local fontSize = 30
        local targetBoxLabel = GetTTFLabel(rayjoyUname, fontSize)
        targetBoxLabel:setAnchorPoint(ccp(0, 0.5))
        targetBoxLabel:setPosition(ccp(10, accountBox:getContentSize().height / 2))
        local customEditAccountBox = customEditBox:new()
        local length = 200
        local accEditBox = customEditAccountBox:init(accountBox, targetBoxLabel, "newlogin_inputkuang.png", nil, -22, length, callBackUserNameHandler, nil, nil, nil, nil, nil, nil, nil, ebFlag)
        self.userAccountLb = targetBoxLabel
        self.userAccountEditBox = accEditBox
        
        local passwordBox = LuaCCScale9Sprite:createWithSpriteFrameName("newlogin_inputkuang.png", CCRect(30, 30, 2, 2), tthandler)
        passwordBox:setContentSize(CCSize(400, passwordBox:getContentSize().height))
        passwordBox:setPosition(ccp(360, 300))
        self.acccountLoginLayer:addChild(passwordBox)
        
        local targetBoxPasswordLabel = GetTTFLabel(rayjoyPwd, fontSize)
        targetBoxPasswordLabel:setAnchorPoint(ccp(0, 0.5))
        targetBoxPasswordLabel:setPosition(ccp(10, passwordBox:getContentSize().height / 2))
        self.userPwdLb = targetBoxPasswordLabel
        local customEditPasswordBox = customEditBox:new()
        local length = 12
        if(G_curPlatName() == "0")then
            length = 100
        end
        local pwdEditBox = customEditPasswordBox:init(passwordBox, targetBoxPasswordLabel, "newlogin_inputkuang.png", nil, -22, length, callBackPassWordHandler, CCEditBox.kEditBoxInputFlagPassword, nil, nil, nil, nil, nil, nil, ebFlag, true)
        self.userPwdEditBox = pwdEditBox
        
        -- 显示历史账号的下拉箭头
        local accountList = G_getHistoryAccount()
        if accountList and SizeOfTable(accountList) > 0 then
            local listArrowBtn = GetButtonItem("login_historyAccountBtn.png", "login_historyAccountBtn_down.png", "login_historyAccountBtn.png", function()
                local boxPos = accountBox:getParent():convertToWorldSpace(ccp(accountBox:getPositionX() + accountBox:getContentSize().width / 2, accountBox:getPositionY() - accountBox:getContentSize().height / 2))
                self:showHistoryAccount(accountBox:getContentSize().width, boxPos, function(accountData)
                    if type(accountData) == "table" then
                        rayjoyUname = accountData[1]
                        rayjoyPwd = accountData[2]
                        targetBoxLabel:setString(rayjoyUname)
                        targetBoxPasswordLabel:setString(rayjoyPwd)
                        accEditBox:setText(rayjoyUname)
                        pwdEditBox:setText(rayjoyPwd)
                        customEditPasswordBox.flagPwd = true
                        base.tmpUserName = rayjoyUname
                        base.tmpUserPassword = rayjoyPwd
                    end
                end)
            end)
            local listArrowMenu = CCMenu:createWithItem(listArrowBtn)
            listArrowMenu:setPosition(0, 0)
            listArrowMenu:setTouchPriority(-24)
            self.acccountLoginLayer:addChild(listArrowMenu, 3)
            listArrowBtn:setPosition(accountBox:getPositionX() + accountBox:getContentSize().width / 2 - listArrowBtn:getContentSize().width / 2 - 12, accountBox:getPositionY())
            self.accHistoryBtn = listArrowBtn
            self.accHistoryMenu = listArrowMenu
        end
        
        local nameLb = GetTTFLabel(getlocal("account"), fontSize)
        nameLb:setPosition(ccp(80, 400))
        self.acccountLoginLayer:addChild(nameLb)
        
        local passwordLb = GetTTFLabel(getlocal("passwordAccount"), fontSize)
        passwordLb:setPosition(ccp(80, 300))
        self.acccountLoginLayer:addChild(passwordLb)
        
        local lbFontSize = 22
        
        local function loginGame() --输入用户名密码登陆
            PlayEffect(audioCfg.mouseClick)
            
            if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 8 or platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 9 then --rayjoy 账号系统
                base.loginAccountType = 1
                PlatformManage:shared():showLogin()
            elseif platCfg.platCfgLoginSceneBtnType[G_curPlatName()] == 10 then
                base.loginAccountType = 1
            end
            self:loginByPlatAccout("", "", true)
        end
        
        local loginItem = GetButtonItem("newAccloginBtn.png", "newAccloginBtn_down.png", "newAccloginBtn.png", loginGame, nil, getlocal("idLoginTitle"), 30, 101)
        local loginMenu = CCMenu:createWithItem(loginItem);
        loginMenu:setPosition(ccp(320 + 150, 100))
        loginMenu:setTouchPriority(-22);
        self.acccountLoginLayer:addChild(loginMenu)
        self.userLoginItem, self.userLoginBtn = loginItem, loginMenu
        
        if G_isBindMailAndResetPwd() == true then
            --显示注册账号页面
            local function showRegister()
                if self.accountShowType == 1 then
                    self:showAccountLoginLayer(2)
                end
            end
            local registerLb = GetTTFLabel(getlocal("registerGameStr"), lbFontSize)
            registerLb:setColor(G_ColorYellowPro)
            local registerBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(4, 4, 2, 2), showRegister)
            self.acccountLoginLayer:addChild(registerBg, 2)
            registerBg:setContentSize(CCSizeMake(registerLb:getContentSize().width, registerLb:getContentSize().height))
            registerBg:setPosition(loginMenu:getPositionX(), loginMenu:getPositionY() - registerLb:getContentSize().height / 2 - 50)
            registerBg:setTouchPriority(-24)
            registerBg:setOpacity(0)
            registerBg:addChild(registerLb)
            registerLb:setPosition(getCenterPoint(registerBg))
            self.userRegisterBtn = registerBg
        end
        
        local function guestLogin() --游客登录
            G_setGuestLogin()
            --清空输入的用户名 密码
            base.tmpUserName = ""
            base.tmpUserPassword = ""
            mainloading.needRequestCheck = true --需要user.check
            close()
            loginScene:loginGame()
        end
        if G_curPlatName() == "51" then
            loginMenu:setPosition(ccp(320, 100))
        else
            if isShowVisitor == true then
                local loginItemVisitor = GetButtonItem("newAccloginBtn.png", "newAccloginBtn_down.png", "newAccloginBtn.png", guestLogin, nil, getlocal("gustItmeTTF"), 30)
                local loginMenuVisitor = CCMenu:createWithItem(loginItemVisitor);
                loginMenuVisitor:setPosition(ccp(320 - 150, 100))
                loginMenuVisitor:setTouchPriority(-22);
                self.acccountLoginLayer:addChild(loginMenuVisitor)
                self.visitorLoginBtn = loginItemVisitor
            end
        end
        
        if G_isBindMailAndResetPwd() == true then
            --展示修改密码的页面
            local function showModifyPwd()
                if self.accountShowType == 1 then
                    local checkCode = userAccountCenterVoApi:checkUserAccount(base.tmpUserName)
                    if checkCode ~= 0 then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("accountIllegalCode"..checkCode), 28)
                        do return end
                    end
                    checkCode = userAccountCenterVoApi:isUserAccountBind({username = base.tmpUserName})
                    if checkCode == false then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("userErrorCode111"), 28)
                        do return end
                    end
                    local flag = userAccountCenterVoApi:isCanResetPwd(base.tmpUserName)
                    if flag == false then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("resetPwdunable"), 28)
                        do return end
                    end
                    self:showResetPwdLayer()
                end
            end
            --显示绑定邮箱页面
            local function showBindMailBox()
                if self.accountShowType == 1 then
                    local checkCode = userAccountCenterVoApi:checkUserAccount(base.tmpUserName)
                    if checkCode ~= 0 then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("accountIllegalCode"..checkCode), 28)
                        do return end
                    end
                    checkCode = userAccountCenterVoApi:checkPassward(base.tmpUserPassword, base.tmpUserName)
                    if checkCode ~= 0 then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("pwdIllegalCode"..checkCode), 28)
                        do return end
                    end
                    checkCode = userAccountCenterVoApi:isUserAccountBind({username = base.tmpUserName})
                    if checkCode == true then
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("userErrorCode105"), 28)
                        do return end
                    end
                    self:showBindMailLayer()
                end
            end
            local forgetPwdLb = GetTTFLabel(getlocal("forgetPwd"), lbFontSize)
            forgetPwdLb:setColor(G_ColorHealthGray)
            local forgetPwdBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(4, 4, 2, 2), showModifyPwd)
            self.acccountLoginLayer:addChild(forgetPwdBg, 2)
            forgetPwdBg:setContentSize(CCSizeMake(forgetPwdLb:getContentSize().width, forgetPwdLb:getContentSize().height))
            forgetPwdBg:setPosition(passwordBox:getPositionX() - passwordBox:getContentSize().width / 2 + forgetPwdBg:getContentSize().width / 2 + 12, passwordBox:getPositionY() - passwordBox:getContentSize().height / 2 - forgetPwdLb:getContentSize().height / 2 - 5)
            forgetPwdBg:setTouchPriority(-24)
            forgetPwdBg:setOpacity(0)
            forgetPwdBg:addChild(forgetPwdLb)
            forgetPwdLb:setPosition(getCenterPoint(forgetPwdBg))
            local forgetPwdUnderlineSp = LuaCCScale9Sprite:createWithSpriteFrameName("pwdunderline.png", CCRect(0, 0, 1, 1), function () end)
            forgetPwdUnderlineSp:setContentSize(CCSizeMake(forgetPwdLb:getContentSize().width, forgetPwdUnderlineSp:getContentSize().height))
            forgetPwdUnderlineSp:setPosition(forgetPwdLb:getPositionX(), forgetPwdLb:getPositionY() - forgetPwdLb:getContentSize().height / 2 - forgetPwdUnderlineSp:getContentSize().height / 2)
            forgetPwdBg:addChild(forgetPwdUnderlineSp)
            self.forgetPwdBtn = forgetPwdBg
            
            local bindMailboxLb = GetTTFLabel(getlocal("bindMailBox"), lbFontSize)
            bindMailboxLb:setColor(G_ColorHealthGray)
            local bindMailboxBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(4, 4, 2, 2), showBindMailBox)
            self.acccountLoginLayer:addChild(bindMailboxBg, 2)
            bindMailboxBg:setContentSize(CCSizeMake(bindMailboxLb:getContentSize().width, bindMailboxLb:getContentSize().height))
            bindMailboxBg:setPosition(passwordBox:getPositionX() + passwordBox:getContentSize().width / 2 - forgetPwdBg:getContentSize().width / 2 - 12, passwordBox:getPositionY() - passwordBox:getContentSize().height / 2 - bindMailboxLb:getContentSize().height / 2 - 5)
            bindMailboxBg:setTouchPriority(-24)
            bindMailboxBg:setOpacity(0)
            bindMailboxBg:addChild(bindMailboxLb)
            bindMailboxLb:setPosition(getCenterPoint(bindMailboxBg))
            local bindMailboxUnderlineSp = LuaCCScale9Sprite:createWithSpriteFrameName("pwdunderline.png", CCRect(0, 0, 1, 1), function () end)
            bindMailboxUnderlineSp:setContentSize(CCSizeMake(bindMailboxLb:getContentSize().width, bindMailboxUnderlineSp:getContentSize().height))
            bindMailboxUnderlineSp:setPosition(bindMailboxLb:getPositionX(), bindMailboxLb:getPositionY() - bindMailboxLb:getContentSize().height / 2 - bindMailboxUnderlineSp:getContentSize().height / 2)
            bindMailboxBg:addChild(bindMailboxUnderlineSp)
            self.bindMailboxBtn = bindMailboxBg
        end
    end
    self.acccountLoginLayer:setVisible(true)
    self.acccountLoginLayer:setPosition(getCenterPoint(self.loginPanelLayer))
    if self.titleLb and self.userLoginItem then
        local titleStr = getlocal("accountSetting")
        local loginBtnStr = getlocal("idLoginTitle")
        if sstype == 2 then
            titleStr = getlocal("registerGameStr")
            loginBtnStr = getlocal("registerGameStr")
        end
        self.titleLb:setString(titleStr)
        local btnLb = tolua.cast(self.userLoginItem:getChildByTag(101), "CCLabelTTF")
        if btnLb then
            btnLb:setString(loginBtnStr)
        end
    end
    if self.userAccountLb and self.userPwdLb then
        self.userAccountLb:setString(rayjoyUname)
        self.userPwdLb:setString(rayjoyPwd)
        self.userAccountEditBox:setText(rayjoyUname)
        self.userPwdEditBox:setText(rayjoyPwd)
    end
    if self.accountShowType == 4 then
        if self.accHistoryBtn and self.accHistoryMenu then
            self.accHistoryBtn:setEnabled(false)
            self.accHistoryMenu:setVisible(false)
        end
        if self.visitorLoginBtn then
            self.visitorLoginBtn:setEnabled(false)
            self.visitorLoginBtn:setVisible(false)
        end
        if self.userLoginBtn then
            self.userLoginBtn:setPositionX(320)
        end
        if G_isBindMailAndResetPwd() == true then
            if self.forgetPwdBtn and self.userRegisterBtn and self.bindMailboxBtn then
                self.forgetPwdBtn:setVisible(false)
                self.userRegisterBtn:setVisible(false)
                self.bindMailboxBtn:setVisible(false)
            end
            if self.registerTipLb == nil then
                local registerTipLb = GetTTFLabelWrap(getlocal("registerAccountTip"), 20, CCSize(G_VisibleSizeWidth - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentBottom)
                registerTipLb:setAnchorPoint(ccp(0.5, 0))
                registerTipLb:setColor(G_ColorRed)
                registerTipLb:setPosition(G_VisibleSizeWidth / 2, self.userLoginBtn:getPositionY() + 50)
                self.acccountLoginLayer:addChild(registerTipLb)
                self.registerTipLb = registerTipLb
            end
            self.registerTipLb:setVisible(true)
        end
    else
        if self.accHistoryBtn and self.accHistoryMenu then
            self.accHistoryBtn:setEnabled(true)
            self.accHistoryMenu:setVisible(true)
        end
        if self.visitorLoginBtn then
            self.visitorLoginBtn:setEnabled(true)
            self.visitorLoginBtn:setVisible(true)
        end
        if self.userLoginBtn then
            if isShowVisitor == true then
                self.userLoginBtn:setPositionX(320 + 150)
            else
                self.userLoginBtn:setPositionX(320)
            end
            if G_isBindMailAndResetPwd() == true then
                if self.userRegisterBtn then
                    self.userRegisterBtn:setPositionX(self.userLoginBtn:getPositionX())
                end
            end
        end
        if G_isBindMailAndResetPwd() == true then
            if self.forgetPwdBtn and self.userRegisterBtn and self.bindMailboxBtn then
                self.forgetPwdBtn:setVisible(true)
                self.userRegisterBtn:setVisible(true)
                self.bindMailboxBtn:setVisible(true)
            end
            if self.registerTipLb then
                self.registerTipLb:setVisible(false)
            end
        end
    end
    if G_isBindMailAndResetPwd() == true then
        if self.bindMailLayer then
            self.bindMailLayer:setVisible(false)
            self.bindMailLayer:setPositionX(9999)
        end
        if self.resetPwdLayer then
            self.resetPwdLayer:setVisible(false)
            self.resetPwdLayer:setPositionX(9999)
        end
    end
end

--显示账号邮箱绑定页面
function loginScene:showBindMailLayer()
    self.accountShowType = 2
    if self.bindUser == nil then
        self.bindUser = {}
    end
    self.bindUser.mail = "" --绑定邮箱
    self.bindUser.code = "" --验证码
    self.bindUser.bcet = 0 --验证码过期时间
    local register = userAccountCenterVoApi:getUserAccountInfo(base.tmpUserName)
    if register then
        self.bindUser.bcet = tonumber(register.bcet)
    end
    local getCodeBtn, securityCodeLb
    if self.bindMailLayer == nil then
        self.bindMailLayer = CCNode:create()
        self.bindMailLayer:setContentSize(CCSizeMake(self.loginPanelLayer:getContentSize().width, self.loginPanelLayer:getContentSize().height))
        self.bindMailLayer:setAnchorPoint(ccp(0.5, 0.5))
        self.bindMailLayer:setPosition(getCenterPoint(self.loginPanelLayer))
        self.loginPanelLayer:addChild(self.bindMailLayer, 2)
        
        local bgWidth, bgHeight = self.loginPanelLayer:getContentSize().width, self.loginPanelLayer:getContentSize().height
        
        local addressInputBoxWidth, codeInputBoxWidth = 380, 250
        local fontSize, tipFontSize = 30, 22
        local inputBoxLeftPosX, textLeftPosX = 170, 70
        local length = 200
        local btnFontSize, priority = 30, -22
        
        local mailLb = GetTTFLabel(getlocal("email_title"), fontSize)
        mailLb:setPosition(ccp(textLeftPosX + mailLb:getContentSize().width / 2, bgHeight - 180))
        self.bindMailLayer:addChild(mailLb)
        
        local securityCodeLb = GetTTFLabel(getlocal("securityCode"), fontSize)
        securityCodeLb:setPosition(ccp(textLeftPosX + securityCodeLb:getContentSize().width / 2, bgHeight - 280))
        self.bindMailLayer:addChild(securityCodeLb)
        local function inputMailCallBack(fn, eB, str, type)
            if str ~= nil then
                self.bindUser.mail = str
                -- print("更新了绑定邮箱", str)
            end
        end
        
        local function inputSecurityCodeCallBack(fn, eB, str, type)
            if str ~= nil then
                self.bindUser.code = str
                -- print("更新了验证码", str)
            end
        end
        local mailBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("newlogin_inputkuang.png", CCRect(30, 30, 2, 2), function ()end)
        mailBoxBg:setContentSize(CCSize(addressInputBoxWidth, mailBoxBg:getContentSize().height))
        mailBoxBg:setPosition(ccp(inputBoxLeftPosX + mailBoxBg:getContentSize().width / 2, mailLb:getPositionY()))
        mailBoxBg:setTag(101)
        self.bindMailLayer:addChild(mailBoxBg)
        local mailBoxLb = GetTTFLabel("", 30)
        mailBoxLb:setAnchorPoint(ccp(0, 0.5))
        mailBoxLb:setPosition(ccp(10, mailBoxBg:getContentSize().height / 2))
        mailBoxLb:setTag(102)
        local meb = customEditBox:new()
        local mailEditBox = meb:init(mailBoxBg, mailBoxLb, "newlogin_inputkuang.png", nil, -22, length, inputMailCallBack)
        mailEditBox:setTag(103)
        
        local codeBoxBg = LuaCCScale9Sprite:createWithSpriteFrameName("newlogin_inputkuang.png", CCRect(30, 30, 2, 2), function ()end)
        codeBoxBg:setContentSize(CCSize(codeInputBoxWidth, codeBoxBg:getContentSize().height))
        codeBoxBg:setPosition(ccp(inputBoxLeftPosX + codeBoxBg:getContentSize().width / 2, securityCodeLb:getPositionY()))
        codeBoxBg:setTag(201)
        self.bindMailLayer:addChild(codeBoxBg)
        local codeBoxLb = GetTTFLabel("", 30)
        codeBoxLb:setAnchorPoint(ccp(0, 0.5))
        codeBoxLb:setPosition(ccp(10, codeBoxBg:getContentSize().height / 2))
        codeBoxLb:setTag(202)
        local ceb = customEditBox:new()
        local codeEditBox = ceb:init(codeBoxBg, codeBoxLb, "newlogin_inputkuang.png", nil, -22, length, inputSecurityCodeCallBack)
        codeEditBox:setTag(203)
        --获取验证码
        local function receiveSecurityCodeHandler()
            local checkCode = userAccountCenterVoApi:checkEmail(self.bindUser.mail)
            if checkCode ~= 0 then --邮箱不合法
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("mailIllegalCode"..checkCode), 28)
                do return end
            end
            local function getCodeHandler(data)
                if data.result == 1 then
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("getSecurityCodeSuccessTip"), nil, 8)
                    self.bindUser.bcet = data.bcet --验证码过期时间
                elseif data.result < 0 then
                    local ercodeStr = "userErrorCode"..math.abs(tonumber(data.result))
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal(ercodeStr), nil, 8)
                end
            end
            local args = {username = base.tmpUserName, pwd = base.tmpUserPassword, mail = self.bindUser.mail, bind = 1}
            userAccountCenterVoApi:getSecurityCode(args, getCodeHandler)
        end
        
        getCodeItem, getCodeBtn = G_createBotton(self.bindMailLayer, ccp(codeBoxBg:getPositionX() + codeInputBoxWidth / 2 + 70, codeBoxBg:getPositionY()), {"", 20}, "securitycodeBtn.png", "securitycodeBtn.png", "securitycodeBtn.png", receiveSecurityCodeHandler, 1, priority, nil, 402)
        getCodeBtn:setTag(401)
        securityCodeLb = tolua.cast(getCodeItem:getChildByTag(101), "CCLabelTTF")
        
        local codeExpireTipLb = GetTTFLabelWrap(getlocal("securityCodeExpireTip"), tipFontSize, CCSize(bgWidth - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        codeExpireTipLb:setAnchorPoint(ccp(0.5, 1))
        codeExpireTipLb:setPosition(bgWidth / 2, codeBoxBg:getPositionY() - codeBoxBg:getContentSize().height / 2 - 5)
        codeExpireTipLb:setColor(G_ColorRed)
        self.bindMailLayer:addChild(codeExpireTipLb)
        
        --绑定邮箱
        local function bindHandler()
            local checkCode = userAccountCenterVoApi:checkEmail(self.bindUser.mail)
            if checkCode ~= 0 then --邮箱不合法
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("mailIllegalCode"..checkCode), 28)
                do return end
            end
            checkCode = userAccountCenterVoApi:checkSecurityCode(self.bindUser.code)
            if checkCode ~= 0 then --邮箱不合法
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("securityCodeIllegalCode"..checkCode), 28)
                do return end
            end
            checkCode = userAccountCenterVoApi:checkPassward(base.tmpUserPassword)
            if checkCode ~= 0 then --邮箱不合法
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("pwdIllegalCode"..checkCode), 28)
                do return end
            end
            local function bindCallBack(data)
                if data.result == 1 then --绑定成功
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("activity_generalRecall_bind_success"), 28)
                    getCodeBtn:setEnabled(false)
                    securityCodeLb:setString(getlocal("receiveSecurityCodeTxt"))
                    self.bindUser.bcet = data.bcet --验证码过期时间
                    self:showAccountLoginLayer(1)
                elseif data.result < 0 then
                    local ercodeStr = "userErrorCode"..math.abs(tonumber(data.result))
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal(ercodeStr), nil, 8)
                end
            end
            local args = {username = base.tmpUserName, pwd = base.tmpUserPassword, mail = self.bindUser.mail, code = self.bindUser.code}
            userAccountCenterVoApi:bindMail(args, bindCallBack)
        end
        G_createBotton(self.bindMailLayer, ccp(bgWidth / 2, 90), {getlocal("bindMailBox", btnFontSize)}, "newAccloginBtn.png", "newAccloginBtn_down.png", "newAccloginBtn.png", bindHandler, 1, priority)
    end
    self.bindMailLayer:setVisible(true)
    self.bindMailLayer:setPosition(getCenterPoint(self.loginPanelLayer))
    if self.titleLb then
        self.titleLb:setString(getlocal("bindMailBox"))
    end
    self:clearSecurityCodeScheduler()
    if getCodeBtn == nil or securityCodeLb == nil then
        getCodeBtn = tolua.cast(self.bindMailLayer:getChildByTag(401), "CCMenu")
        getCodeItem = tolua.cast(getCodeBtn:getChildByTag(402), "CCMenuItem")
        securityCodeLb = tolua.cast(getCodeItem:getChildByTag(101), "CCLabelTTF")
    end
    local mailBoxBg = tolua.cast(self.bindMailLayer:getChildByTag(101), "LuaCCScale9Sprite")
    local mailBoxLb = tolua.cast(mailBoxBg:getChildByTag(102), "CCLabelTTF")
    local mailEditBox = tolua.cast(mailBoxBg:getChildByTag(103), "CCEditBox")
    local codeBoxBg = tolua.cast(self.bindMailLayer:getChildByTag(201), "LuaCCScale9Sprite")
    local codeBoxLb = tolua.cast(codeBoxBg:getChildByTag(202), "CCLabelTTF")
    local codeEditBox = tolua.cast(codeBoxBg:getChildByTag(203), "CCEditBox")
    mailBoxLb:setString(self.bindUser.mail)
    mailEditBox:setText(self.bindUser.mail)
    codeBoxLb:setString(self.bindUser.code)
    codeEditBox:setText(self.bindUser.code)
    
    local function refreshSecurityCodeState()
        if getCodeItem and securityCodeLb and self.bindMailLayer then
            local codeStr = ""
            local deviceTime = math.floor(G_getCurDeviceMillTime() / 1000)
            local bcet = self.bindUser.bcet
            if bcet and deviceTime <= bcet then
                codeStr = GetTimeStr(bcet - deviceTime)
                getCodeItem:setEnabled(false)
            else
                codeStr = getlocal("receiveSecurityCodeTxt")
                getCodeItem:setEnabled(true)
            end
            securityCodeLb:setString(codeStr)
        end
    end
    refreshSecurityCodeState()
    local function codeTick()
        refreshSecurityCodeState()
    end
    self.securityCodeTick = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(codeTick, 1, false)
    if self.acccountLoginLayer then
        self.acccountLoginLayer:setVisible(false)
        self.acccountLoginLayer:setPositionX(9999)
    end
    if self.resetPwdLayer then
        self.resetPwdLayer:setVisible(false)
        self.resetPwdLayer:setPositionX(9999)
    end
end

--显示重置密码页面
function loginScene:showResetPwdLayer()
    self.accountShowType = 3
    
    if self.resetUser == nil then
        self.resetUser = {}
    end
    self.resetUser.username = base.tmpUserName --账号
    self.resetUser.newPwd = "" --密码
    self.resetUser.code = "" --验证码
    self.resetUser.pwdcet = 0 --验证码过期时间
    local register = userAccountCenterVoApi:getUserAccountInfo(self.resetUser.username)
    if register then
        self.resetUser.pwdcet = tonumber(register.pwdcet)
    end
    local accountBoxLb, rsetAccEditBox, passwardBoxLb, rsetPwdEditBox, codeBoxLb, rsetCodeEditBox
    local getCodeItem, getCodeBtn, securityCodeLb
    local function refreshSecurityCodeState()
        if getCodeItem and securityCodeLb and self.resetPwdLayer then
            local codeStr = ""
            local deviceTime = math.floor(G_getCurDeviceMillTime() / 1000)
            local pwdcet = self.resetUser.pwdcet
            if pwdcet and deviceTime <= pwdcet then
                codeStr = GetTimeStr(pwdcet - deviceTime)
                getCodeItem:setEnabled(false)
            else
                codeStr = getlocal("receiveSecurityCodeTxt")
                getCodeItem:setEnabled(true)
            end
            securityCodeLb:setString(codeStr)
        end
    end
    if self.resetPwdLayer == nil then
        self.resetPwdLayer = CCNode:create()
        self.resetPwdLayer:setContentSize(CCSizeMake(self.loginPanelLayer:getContentSize().width, self.loginPanelLayer:getContentSize().height))
        self.resetPwdLayer:setAnchorPoint(ccp(0.5, 0.5))
        self.resetPwdLayer:setPosition(getCenterPoint(self.loginPanelLayer))
        self.loginPanelLayer:addChild(self.resetPwdLayer, 2)
        
        local bgWidth, bgHeight = self.loginPanelLayer:getContentSize().width, self.loginPanelLayer:getContentSize().height
        local accountInputBoxWidth, codeInputBoxWidth = 380, 250
        local fontSize, tipFontSize = 30, 22
        local inputBoxLeftPosX, textLeftPosX = 170, 70
        local length = 200
        local btnFontSize, priority = 30, -22
        
        local accountLb = GetTTFLabel(getlocal("account"), fontSize)
        accountLb:setPosition(ccp(textLeftPosX + accountLb:getContentSize().width / 2, bgHeight - 150))
        self.resetPwdLayer:addChild(accountLb)
        
        local passwordLb = GetTTFLabel(getlocal("cpNewPassword"), fontSize)
        passwordLb:setPosition(ccp(textLeftPosX + passwordLb:getContentSize().width / 2, bgHeight - 220))
        self.resetPwdLayer:addChild(passwordLb)
        
        local securityCodeLb = GetTTFLabel(getlocal("securityCode"), fontSize)
        securityCodeLb:setPosition(ccp(textLeftPosX + securityCodeLb:getContentSize().width / 2, bgHeight - 320))
        self.resetPwdLayer:addChild(securityCodeLb)
        local function inputEndCallBack()
            local register = userAccountCenterVoApi:getUserAccountInfo(self.resetUser.username)
            if register then
                self.resetUser.pwdcet = tonumber(register.pwdcet)
            else
                self.resetUser.pwdcet = 0
            end
            refreshSecurityCodeState()
        end
        local function inputAccountCallBack(fn, eB, str, itype)
            if str ~= nil then
                self.resetUser.username = str
                -- print("重置密码--->更新了账号信息,itype", str,itype)
            end
        end
        local function inputPasswardCallBack(fn, eB, str, itype)
            if str ~= nil then
                self.resetUser.newPwd = str
                -- print("重置密码--->更新了验证码", str)
            end
        end
        local function inputSecurityCodeCallBack(fn, eB, str, itype)
            if str ~= nil then
                self.resetUser.code = str
                -- print("重置密码--->更新了验证码", str)
            end
        end
        local accountBox = LuaCCScale9Sprite:createWithSpriteFrameName("newlogin_inputkuang.png", CCRect(30, 30, 2, 2), function ()end)
        accountBox:setContentSize(CCSize(accountInputBoxWidth, accountBox:getContentSize().height))
        accountBox:setPosition(ccp(inputBoxLeftPosX + accountBox:getContentSize().width / 2, accountLb:getPositionY()))
        accountBox:setTag(101)
        self.resetPwdLayer:addChild(accountBox)
        accountBoxLb = GetTTFLabel(self.resetUser.username or "", 30)
        accountBoxLb:setAnchorPoint(ccp(0, 0.5))
        accountBoxLb:setPosition(ccp(10, accountBox:getContentSize().height / 2))
        accountBoxLb:setTag(102)
        local accountEditBox = customEditBox:new()
        rsetAccEditBox = accountEditBox:init(accountBox, accountBoxLb, "newlogin_inputkuang.png", nil, -22, length, inputAccountCallBack, nil, nil, nil, nil, nil, nil, inputEndCallBack, true)
        rsetAccEditBox:setTag(103)
        
        local passwardBox = LuaCCScale9Sprite:createWithSpriteFrameName("newlogin_inputkuang.png", CCRect(30, 30, 2, 2), function ()end)
        passwardBox:setContentSize(CCSize(accountInputBoxWidth, passwardBox:getContentSize().height))
        passwardBox:setPosition(ccp(inputBoxLeftPosX + passwardBox:getContentSize().width / 2, passwordLb:getPositionY()))
        passwardBox:setTag(201)
        self.resetPwdLayer:addChild(passwardBox)
        passwardBoxLb = GetTTFLabel("", 30)
        passwardBoxLb:setAnchorPoint(ccp(0, 0.5))
        passwardBoxLb:setPosition(ccp(10, passwardBox:getContentSize().height / 2))
        passwardBoxLb:setTag(202)
        local passwardEditBox = customEditBox:new()
        rsetPwdEditBox = passwardEditBox:init(passwardBox, passwardBoxLb, "newlogin_inputkuang.png", nil, -22, length, inputPasswardCallBack)
        rsetPwdEditBox:setTag(203)
        
        local securityCodeBox = LuaCCScale9Sprite:createWithSpriteFrameName("newlogin_inputkuang.png", CCRect(30, 30, 2, 2), function ()end)
        securityCodeBox:setContentSize(CCSize(codeInputBoxWidth, securityCodeBox:getContentSize().height))
        securityCodeBox:setPosition(ccp(inputBoxLeftPosX + securityCodeBox:getContentSize().width / 2, securityCodeLb:getPositionY()))
        securityCodeBox:setTag(301)
        self.resetPwdLayer:addChild(securityCodeBox)
        codeBoxLb = GetTTFLabel("", 30)
        codeBoxLb:setAnchorPoint(ccp(0, 0.5))
        codeBoxLb:setPosition(ccp(10, securityCodeBox:getContentSize().height / 2))
        codeBoxLb:setTag(302)
        local securityCodeEditBox = customEditBox:new()
        rsetCodeEditBox = securityCodeEditBox:init(securityCodeBox, codeBoxLb, "newlogin_inputkuang.png", nil, -22, length, inputSecurityCodeCallBack)
        rsetCodeEditBox:setTag(303)
        --获取验证码
        local function receiveSecurityCodeHandler()
            local checkCode = userAccountCenterVoApi:checkUserAccount(self.resetUser.username)
            if checkCode ~= 0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("accountIllegalCode"..checkCode), 28)
                do return end
            end
            local function getCodeHandler(data)
                if data.result == 1 then
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("getSecurityCodeSuccessTip"), nil, 8)
                    self.resetUser.pwdcet = data.pwdcet --验证码过期时间
                elseif data.result < 0 then
                    local ercodeStr = "userErrorCode"..math.abs(tonumber(data.result))
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal(ercodeStr), nil, 8)
                end
            end
            local args = {username = self.resetUser.username, bind = 0}
            local ret = userAccountCenterVoApi:getSecurityCode(args, getCodeHandler)
        end
        
        getCodeItem, getCodeBtn = G_createBotton(self.resetPwdLayer, ccp(securityCodeBox:getPositionX() + codeInputBoxWidth / 2 + 70, securityCodeBox:getPositionY()), {codeStr, 20}, "securitycodeBtn.png", "securitycodeBtn.png", "securitycodeBtn.png", receiveSecurityCodeHandler, 1, priority, nil, 402)
        getCodeBtn:setTag(401)
        securityCodeLb = tolua.cast(getCodeItem:getChildByTag(101), "CCLabelTTF")
        
        local codeExpireTipLb = GetTTFLabelWrap(getlocal("securityCodeExpireTip"), tipFontSize, CCSize(bgWidth - 30, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
        codeExpireTipLb:setAnchorPoint(ccp(0.5, 1))
        codeExpireTipLb:setPosition(bgWidth / 2, securityCodeBox:getPositionY() - securityCodeBox:getContentSize().height / 2 - 5)
        codeExpireTipLb:setColor(G_ColorRed)
        self.resetPwdLayer:addChild(codeExpireTipLb)
        
        --重置密码
        local function resetPwdHandler()
            local ret = userAccountCenterVoApi:isUserAccountBind({username = self.resetUser.username})
            if ret == false then --玩家未绑定不能重置密码
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("userErrorCode111"), 28)
                do return end
            end
            local checkCode = userAccountCenterVoApi:checkSecurityCode(self.resetUser.code)
            if checkCode ~= 0 then
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("securityCodeIllegalCode"..checkCode), 28)
                do return end
            end
            checkCode = userAccountCenterVoApi:checkPassward(self.resetUser.newPwd)
            if checkCode ~= 0 then --密码不正确
                smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("pwdIllegalCode"..checkCode), 28)
                do return end
            end
            local function resetCallBack(data)
                if data.result == 1 then --重置成功
                    smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("resetPwdSuccessTip"), 28)
                    self.resetUser.pwdcet = data.pwdcet --验证码过期时间
                    self:showAccountLoginLayer(1)
                elseif data.result < 0 then --重置失败
                    local ercodeStr = "userErrorCode"..math.abs(tonumber(data.result))
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal(ercodeStr), nil, 8)
                end
            end
            local args = {username = self.resetUser.username, pwd = self.resetUser.newPwd, code = self.resetUser.code}
            userAccountCenterVoApi:resetPwd(args, resetCallBack)
        end
        G_createBotton(self.resetPwdLayer, ccp(bgWidth / 2, 90), {getlocal("resetPwd2", btnFontSize)}, "newAccloginBtn.png", "newAccloginBtn_down.png", "newAccloginBtn.png", resetPwdHandler, 1, priority)
    end
    self.resetPwdLayer:setVisible(true)
    self.resetPwdLayer:setPosition(getCenterPoint(self.loginPanelLayer))
    if self.titleLb then
        self.titleLb:setString(getlocal("resetPwd"))
    end
    if accountBoxLb == nil then
        local rsetAccEditBoxBg = tolua.cast(self.resetPwdLayer:getChildByTag(101), "LuaCCScale9Sprite")
        accountBoxLb = tolua.cast(rsetAccEditBoxBg:getChildByTag(102), "CCLabelTTF")
        rsetAccEditBox = tolua.cast(rsetAccEditBoxBg:getChildByTag(103), "CCEditBox")
        
        local rsetPwdEditBoxBg = tolua.cast(self.resetPwdLayer:getChildByTag(201), "LuaCCScale9Sprite")
        passwardBoxLb = tolua.cast(rsetPwdEditBoxBg:getChildByTag(202), "CCLabelTTF")
        rsetPwdEditBox = tolua.cast(rsetPwdEditBoxBg:getChildByTag(203), "CCEditBox")
        
        local rsetCodeEditBoxBg = tolua.cast(self.resetPwdLayer:getChildByTag(301), "LuaCCScale9Sprite")
        codeBoxLb = tolua.cast(rsetCodeEditBoxBg:getChildByTag(302), "CCLabelTTF")
        rsetCodeEditBox = tolua.cast(rsetCodeEditBoxBg:getChildByTag(303), "CCEditBox")
    end
    if accountBoxLb and rsetAccEditBox and passwardBoxLb and rsetPwdEditBox and codeBoxLb and rsetCodeEditBox then
        accountBoxLb:setString(self.resetUser.username)
        rsetAccEditBox:setText(self.resetUser.username)
        passwardBoxLb:setString(self.resetUser.newPwd)
        rsetPwdEditBox:setText(self.resetUser.newPwd)
        codeBoxLb:setString(self.resetUser.code)
        rsetCodeEditBox:setText(self.resetUser.code)
    end
    self:clearSecurityCodeScheduler()
    if getCodeBtn == nil or securityCodeLb == nil then
        getCodeBtn = tolua.cast(self.resetPwdLayer:getChildByTag(401), "CCMenu")
        getCodeItem = tolua.cast(getCodeBtn:getChildByTag(402), "CCMenuItem")
        securityCodeLb = tolua.cast(getCodeItem:getChildByTag(101), "CCLabelTTF")
    end
    refreshSecurityCodeState()
    local function codeTick()
        refreshSecurityCodeState()
    end
    self.securityCodeTick = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(codeTick, 1, false)
    if self.acccountLoginLayer then
        self.acccountLoginLayer:setVisible(false)
        self.acccountLoginLayer:setPositionX(9999)
    end
    if self.bindMailLayer then
        self.bindMailLayer:setVisible(false)
        self.bindMailLayer:setPositionX(9999)
    end
end

function loginScene:closeAccountLoginLayer(clearFlag)
    if clearFlag == true then
        base.tmpUserName = ""
        base.tmpUserPassword = ""
    end
    if self.accoutLayer and tolua.cast(self.accoutLayer, "CCLayer") then
        self.accoutLayer:removeFromParentAndCleanup(true)
        self.accoutLayer = nil
    end
    self.loginLayer:setVisible(true)
    self:clearAccountLoginLayer()
end

function loginScene:clearAccountLoginLayer()
    self.loginPanelLayer = nil
    self.acccountLoginLayer = nil
    self.bindMailLayer = nil
    self.resetPwdLayer = nil
    self.accHistoryBtn, self.accHistoryMenu, self.forgetPwdBtn, self.userRegisterBtn, self.bindMailboxBtn, self.userLoginBtn, self.visitorLoginBtn = nil, nil, nil, nil, nil, nil, nil
    self.userAccountLb, self.userPwdLb = nil, nil
    self.userAccountEditBox, self.userPwdEditBox = nil, nil
    self.registerTipLb = nil
    self.bindUser, self.resetUser = nil, nil
    self:clearSecurityCodeScheduler()
end

function loginScene:clearSecurityCodeScheduler()
    if self.securityCodeTick then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.securityCodeTick)
        self.securityCodeTick = nil
    end
end

function loginScene:loginByPlatAccout(tid, tpwd, israyjoyAccount) --平台账号登录
    print("loginScene::tid:", tid, ".tpwd:", tpwd)
    if G_loginType == 1 then --第三方平台账号登录
        base.tmpUserName = tid
        base.tmpUserPassword = tpwd
    end
    
    if G_loginType == 2 and (base.loginAccountType == 0 or base.loginAccountType == 3) then --自有登录系统,facebook账号登录
        base.tmpUserName = tid
        base.tmpUserPassword = tpwd
    end
    
    if string.find(base.tmpUserName, ' ') ~= nil or string.find(base.tmpUserPassword, ' ') ~= nil then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("blankCharacter"), true, 6, G_ColorRed)
        do
            return
        end
    end
    if base.tmpUserName == "" then
        
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("nameNullCharacter"), true, 6, G_ColorRed)
        
        do
            return
        end
    end
    if base.tmpUserPassword == "" then
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("passwordNullCharacter"), true, 6, G_ColorRed)
        
        do
            return
        end
    end
    if G_loginType == 2 and base.loginAccountType == 1 then --自有登录系统,rayjoy账号登录
        if platCfg.platRayJoyAccountPrefix[G_curPlatName()] ~= nil then
            base.tmpUserName = platCfg.platRayJoyAccountPrefix[G_curPlatName()]["rj"]..base.tmpUserName
        end
    elseif G_loginType == 2 and base.loginAccountType == 0 then
        if platCfg.platRayJoyAccountPrefix[G_curPlatName()] ~= nil then
            base.tmpUserName = platCfg.platRayJoyAccountPrefix[G_curPlatName()]["fb"]..base.tmpUserName
        end
    end
    local function callBack(fn, data)
        --local sData=OBJDEF:decode(data)
        local result, sData = base:checkServerData(data, false)
        if sData.ret == -1 then
            --用户名或密码不正确
            G_cancleLoginLoading()
            local function onConfirm()
                if(base and base.changeServer)then
                    self:close()
                    base:changeServer()
                end
            end
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("netiswrong"), nil, 4, nil, onConfirm)
            base:cancleWait()
            base:cancleNetWait()
            do
                return
            end
        end
        
        self:loginCallBack(fn, data, sData) --处理登录返回数据
        if sData.ret ~= -1 then
            G_setLocalTankUserName(base.tmpUserName)
            G_setLocalTankPwd(base.tmpUserPassword)
            G_setTankIsguest("0")
            base.tmpUserName = ""
            base.tmpUserPassword = ""
            self:showBindWhenLogin()
        end
        local tmpTb = {}
        tmpTb["action"] = "gameLoginCallback"
        local cjson = G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
        --阿拉伯的特殊需求，clanUserID
        if(G_curPlatName() == "21" or G_curPlatName() == "androidarab")then
            local tmpTb = {}
            tmpTb["action"] = "customAction"
            tmpTb["parms"] = {}
            tmpTb["parms"]["value"] = "getClanPlayCpUserId"
            local cjson = G_Json.encode(tmpTb)
            local clanUserID = G_accessCPlusFunction(cjson)
            if(clanUserID and clanUserID ~= "")then
                base.clanUserID = clanUserID
            end
        end
        
        --show float ball
        local tmpTb = {}
        tmpTb["action"] = "showFloatBall"
        tmpTb["parms"] = {}
        tmpTb["parms"]["value"] = "show"
        local cjson = G_Json.encode(tmpTb)
        G_accessCPlusFunction(cjson)
        --end show float ball
    end
    
    mainloading:login(self.curServerName, callBack, true)
    
end

function loginScene:showProtocol()
    require "luascript/script/game/scene/scene/chinaTermsDialog"
    local chinaTermsDialog = chinaTermsDialog:new()
    chinaTermsDialog:init(5, true)
end

function loginScene:showLoginScene()
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    spriteController:addPlist("public/newAccountSysImages.plist")
    spriteController:addTexture("public/newAccountSysImages.png")
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    G_judgeEncryption()
    
    if G_isSendAchievementToGoogle() > 0 then
        require "luascript/script/game/newguid/achievements"
        achievements:clearAll()
    end
    
    if platCfg.platOgg[G_curPlatName()] ~= nil then
        audioCfg = audioCfgKo
    end
    
    languageManager:init()
    userAccountCenterVoApi:init()
    self.loginSuccess = false
    self.isShowing = true
    local loginGameScene = CCScene:create()
    sceneGame = loginGameScene
    CCDirector:sharedDirector():replaceScene(loginGameScene)
    
    self.loginLayer = CCLayer:create()
    loginGameScene:addChild(self.loginLayer, 2)
    self.effectLayer = CCLayer:create()
    loginGameScene:addChild(self.effectLayer)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    loginScene:showHexieBg(1)
    
    self.acceptPk = CCUserDefault:sharedUserDefault():getBoolForKey("acceptProtocolKey")
    if G_isApplyVersion() == true then
        self.acceptPk = true
    end
    if G_isShowAcceptPk() == true and G_isApplyVersion() == false and self.acceptPk == false then
        self:showProtocol() --用户未接受用户协议则弹出用户协议的页面
    end
    if self.acceptPkListener == nil then
        local function acceptPkListener()
            self:refreshAcceptPk()
        end
        self.acceptPkListener = acceptPkListener
        eventDispatcher:addEventListener("user.accept.protocol", acceptPkListener)
    end
    
    --设置一个隐藏按钮可以转换是否变为测试包和正式包
    local turnCount = 0
    local function turnTest()
        if CCUserDefault:sharedUserDefault():getIntegerForKey("test_turntest") == 0 then
            turnCount = turnCount + 1
            --print("turnCount",turnCount)
            if turnCount % 10 == 0 then
                local function changeTest(type)
                    if type == 2 then
                        require "luascript/script/game/scene/gamedialog/enterServerDialog"
                        local td = enterServerDialog:new(1, 30, true)
                        local tbArr = {}
                        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, "服务器", true, 30)
                        sceneGame:addChild(dialog, 30)
                    elseif type == 1 then
                        --print("转换成功")
                        local buttonStr = "转换成功,退出游戏"
                        if G_getCurChoseLanguage() == "ar" then
                            buttonStr = "change success,please restart game"
                        end
                        smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), buttonStr, 28)
                        turnCount = 0
                        CCUserDefault:sharedUserDefault():setIntegerForKey("test_turntest", 1)
                        CCUserDefault:sharedUserDefault():flush()
                        CCUserDefault:sharedUserDefault():setIntegerForKey("test_luaversion", 1)
                        CCUserDefault:sharedUserDefault():flush()
                    end
                end
                local buttonStr = "输入密码,版本号"
                if G_getCurChoseLanguage() == "ar" then
                    buttonStr = "please input password,current package version is "
                end
                allianceSmallDialog:showTurnTestDialog(changeTest, buttonStr..G_Version, 20)
            end
        else
            local function turnYes()
                CCUserDefault:sharedUserDefault():setIntegerForKey("test_turntest", 0)
                CCUserDefault:sharedUserDefault():setIntegerForKey("test_luaversion", 1)
                CCUserDefault:sharedUserDefault():flush()
            end
            local buttonStr = "转换成正式包吗？确定之后需要退出游戏并杀掉游戏进程重进游戏"
            if G_getCurChoseLanguage() == "ar" then
                buttonStr = "do you want to change to live mode? please click confirm button and restart game"
            end
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/addNewPropImage1.plist")
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), turnYes, getlocal("dialog_title_prompt"), buttonStr, nil, 20, kCCTextAlignmentCenter)
        end
    end
    local buttonStr = "变为正式包"
    if G_getCurChoseLanguage() == "ar" then
        buttonStr = "change to live mode"
    end
    local buttonTurnTest = GetButtonItem("newAccloginBtn.png", "newAccloginBtn_down.png", "newAccloginBtn.png", turnTest, nil, buttonStr, 25)
    buttonTurnTest:setAnchorPoint(ccp(0, 1))
    local menuTurnTest = CCMenu:createWithItem(buttonTurnTest);
    menuTurnTest:setPosition(ccp(0, G_VisibleSizeHeight))
    menuTurnTest:setTouchPriority(-20);
    self.loginLayer:addChild(menuTurnTest, 5)
    if CCUserDefault:sharedUserDefault():getIntegerForKey("test_turntest") == 0 then
        buttonTurnTest:setOpacity(0)
    end
    --设置一个隐藏按钮可以转换是否变为测试包和正式包
    --显示C版本号和cn3的行数
    local versionStr
    if(G_Version == nil or tonumber(G_Version) == nil)then
        versionStr = "0" .. "."..languageManager:getLanguageVersion()
    else
        versionStr = tostring(G_Version) .. "."..languageManager:getLanguageVersion()
    end
    versionStr = getlocal("current_version", {versionStr})
    local versionLb = GetTTFLabel(versionStr, 25)
    versionLb:setAnchorPoint(ccp(0, 1))
    versionLb:setPosition(5, G_VisibleSizeHeight - 5)
    self.loginLayer:addChild(versionLb, 9)
    local contactBtnPosX, contactBtnPosY = G_VisibleSizeWidth - 80, G_VisibleSizeHeight - 30
    if(G_isChina() and G_isApplyVersion() == false)then
        local function showTermsTxt()
            require "luascript/script/game/scene/scene/chinaTermsDialog"
            local chinaTermsDialog = chinaTermsDialog:new()
            chinaTermsDialog:init(4, true)
        end
        local termsItem = GetButtonItem("newContractBtn.png", "newContractBtn_down.png", "newContractBtn.png", showTermsTxt, nil, getlocal("protocolTitle"), 22)
        -- termsItem:setScale(0.5)
        local termsBtn = CCMenu:createWithItem(termsItem)
        termsBtn:setTouchPriority(-20);
        termsBtn:setPosition(G_VisibleSizeWidth - 80, G_VisibleSizeHeight - 30)
        self.loginLayer:addChild(termsBtn)
        contactBtnPosY = termsBtn:getPositionY() - 50
    end
    --显示客服联系入口
    if G_isShowContactSys() == true and G_isApplyVersion() == false then
        local function showContactSys()
            G_showZhichiContactSys()
        end
        local contactItem = G_createBotton(self.loginLayer, ccp(contactBtnPosX, contactBtnPosY), {getlocal("contactCustomerPersonnel"), 22}, "newContractBtn.png", "newContractBtn_down.png", "newContractBtn.png", showContactSys, 1, -20)
    end
    
    local bgSp = CCSprite:create("scene/lodingxin.jpg");
    local logoSpName = nil
    if platCfg.platCfgGameLogoSingleFile ~= nil and platCfg.platCfgGameLogoSingleFile[G_curPlatName()] ~= nil then
        
        logoSpName = platCfg.platCfgGameLogoSingleFile[G_curPlatName()][G_getCurChoseLanguage()]
    else
        logoSpName = platCfg.platCfgGameLogo[G_curPlatName()][G_getCurChoseLanguage()]
    end
    -- self.logoSp=nil
    -- --飞流战地坦克特殊处理
    -- if(G_curPlatName()=="5" and G_Version<=11)then
    --     logoSpName="Logo_ky2.png"
    -- end
    -- if platCfg.platCfgGameLogoSingleFile~=nil and platCfg.platCfgGameLogoSingleFile[G_curPlatName()]~=nil then
    --        self.logoSp=CCSprite:create("scene/logoImage/"..logoSpName)
    --     else
    --        self.logoSp=CCSprite:createWithSpriteFrameName(logoSpName~=nil and logoSpName or "Logo.png")
    --     end
    -- CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    -- CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    -- bgSp:setPosition(getCenterPoint(loginGameScene))
    -- -- self.loginLayer:addChild(bgSp)
    
    -- local pointCenter=getCenterPoint(loginGameScene)
    -- self.logoSp:setPosition(ccp(pointCenter.x,pointCenter.y+280))
    -- self.loginLayer:addChild(self.logoSp)
    
    for k, v in pairs(G_GameSettings) do
        if CCUserDefault:sharedUserDefault():getIntegerForKey(v) == 0 and v ~= "gameSettings_buildingDisplay" then
            CCUserDefault:sharedUserDefault():setIntegerForKey(v, 2)
            CCUserDefault:sharedUserDefault():flush()
        end
    end
    
    local function loginGame()
        PlayEffect(audioCfg.mouseClick)
        if G_isShowAcceptPk() == true and self.acceptPk == false then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("loginTip_noAcceptPK"), 28)
            do return end
        end
        G_showLoginLoading()
        G_loginAccountType = 2
        base.tmpUserName = ""
        base.tmpUserPassword = ""
        
        local loginSceneBtnType = 1
        if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] ~= nil then
            loginSceneBtnType = platCfg.platCfgLoginSceneBtnType[G_curPlatName()]
        end
        if loginSceneBtnType == 4 or loginSceneBtnType == 5 then
            FBSdkHelper:exitLogin()
        end
        
        if loginSceneBtnType == 7 then --昆仑北美 一键试玩
            local tmpTb = {}
            tmpTb["action"] = "loginForKunLunBeiMei"
            tmpTb["parms"] = {}
            tmpTb["parms"]["type"] = 3
            local cjson = G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
            do return end
        end
        
        if loginSceneBtnType == 1 then
            if PlatformManage ~= nil then
                if HttpRequestHelper ~= nil and HttpRequestHelper.sendTmpStatisticData ~= nil then
                    HttpRequestHelper:sendTmpStatisticData("4")
                end
                G_showLoginLoading(10, false)
                local tmpTb = {}
                tmpTb["action"] = "quickLogin"
                local cjson = G_Json.encode(tmpTb)
                G_accessCPlusFunction(cjson)
                do return end
            end
        end
        G_setGuestLogin()
        self:loginGame()
    end
    
    local function loginGamePlat()
        PlayEffect(audioCfg.mouseClick)
        if G_isShowAcceptPk() == true and self.acceptPk == false then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("loginTip_noAcceptPK"), 28)
            do return end
        end
        --kakao的特殊登录逻辑
        if(G_isKakao())then
            G_showLoginLoading(10, false)
            if(base.platformUserId ~= nil)then
                loginScene:loginByPlatAccout(base.platformUserId, 123456)
            else
                PlatformManage:shared():showLogin()
            end
            return;
        end
        --虫虫助手停服
        if(G_curPlatName() == "androidchongchong")then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), "服务器已经关闭！\n如有问题请联系客服QQ: 1931235754", true, 6)
            do return end
        end
        G_loginAccountType = 1
        if G_loginType == 1 then --第三方账号登录
            G_showLoginLoading(10)
            local loginSceneBtnType = 1
            if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] ~= nil then
                loginSceneBtnType = platCfg.platCfgLoginSceneBtnType[G_curPlatName()]
            end
            if loginSceneBtnType == 4 or loginSceneBtnType == 5 then
                FBSdkHelper:loginWithFaceBook()
            elseif loginSceneBtnType == 1 or loginSceneBtnType == 2 then
                G_showLoginLoading(10, false)
                if(G_curPlatName() == "14" or G_curPlatName() == "androidkunlun" or G_curPlatName() == "androidkunlunz")then
                    local tmpTb = {}
                    tmpTb["action"] = "loginForKunLunBeiMei"
                    tmpTb["parms"] = {}
                    tmpTb["parms"]["type"] = 1
                    local cjson = G_Json.encode(tmpTb)
                    G_accessCPlusFunction(cjson)
                else
                    if(G_curPlatName() == "androidxiaomi")then
                        local retStr = G_sendHttpRequest("http://tank-android-01.raysns.com/tankheroclient/net_test.php")
                        if(retStr and retStr ~= "")then
                            local ret = G_Json.decode(retStr)
                            if(tonumber(ret.ret) == -1)then
                                local url = ret.msg
                                if(url)then
                                    local tmpTb = {}
                                    tmpTb["action"] = "openUrlInAppWithClose"
                                    tmpTb["parms"] = {}
                                    tmpTb["parms"]["connect"] = tostring(url)
                                    local cjson = G_Json.encode(tmpTb)
                                    G_accessCPlusFunction(cjson)
                                end
                                do return end
                            end
                        end
                    end
                    PlatformManage:shared():showLogin()
                end
            elseif loginSceneBtnType == 7 then --昆仑北美 facebook登录
                local tmpTb = {}
                tmpTb["action"] = "loginForKunLunBeiMei"
                tmpTb["parms"] = {}
                tmpTb["parms"]["type"] = 1
                local cjson = G_Json.encode(tmpTb)
                G_accessCPlusFunction(cjson)
            end
        elseif G_loginType == 2 then --rayjoy账号体系中的facebook登录
            base.loginAccountType = 0
            local tmpTb = {}
            tmpTb["action"] = "facebookLogin"
            local cjson = G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        end
    end
    
    local function loginGameSdkPlat()
        if G_isShowAcceptPk() == true and self.acceptPk == false then
            smallDialog:showTipsDialog("PanelPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("loginTip_noAcceptPK"), 28)
            do return end
        end
        local loginSceneBtnType = 1
        if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] ~= nil then
            loginSceneBtnType = platCfg.platCfgLoginSceneBtnType[G_curPlatName()]
        end
        if loginSceneBtnType ~= 8 and loginSceneBtnType ~= 9 and loginSceneBtnType ~= 10 then
            G_showLoginLoading(10)
        end
        if loginSceneBtnType == 7 then --昆仑北美 其他方式登录
            local tmpTb = {}
            tmpTb["action"] = "loginForKunLunBeiMei"
            tmpTb["parms"] = {}
            tmpTb["parms"]["type"] = 2
            local cjson = G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        elseif loginSceneBtnType == 8 or loginSceneBtnType == 9 or loginSceneBtnType == 10 then
            self:showAccountSettings()
        end
    end
    
    local addHeight = 10
    local temHight = 90;
    if G_getIphoneType() == G_iphoneX then
        temHight = 60
    end
    --主登陆界面 登陆按钮
    --FB登录\绑定的账号登录
    
    if G_isShowAcceptPk() == true and G_isApplyVersion() == false then
        local pkscale, pkposy = 0.6, 91
        if G_isIOS() == true then
            temHight = temHight - 35
        else
            temHight = temHight - 55
            pkposy = 108
        end
        if G_isShowNewMapAndBuildings() == 1 then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("newUI/newImage.plist")
        else
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/newImage.plist")
        end
        local pkSelectedSp = CCSprite:createWithSpriteFrameName("LegionCheckBtn.png")
        pkSelectedSp:setAnchorPoint(ccp(0, 0.5))
        pkSelectedSp:setPosition(210, pkposy)
        pkSelectedSp:setScale(pkscale)
        self.loginLayer:addChild(pkSelectedSp, 81)
        self.pkSelectedSp = pkSelectedSp
        
        local function touch(tag, object)
            if self.acceptPk == true then
                self.acceptPk = false
            else
                self.acceptPk = true
            end
            CCUserDefault:sharedUserDefault():setBoolForKey("acceptProtocolKey", self.acceptPk)
            CCUserDefault:sharedUserDefault():flush()
            self:refreshAcceptPk()
        end
        
        local pkSelectItem = GetButtonItem("LegionCheckBtnUn.png", "LegionCheckBtnUn.png", "LegionCheckBtnUn.png", touch, 5, nil)
        pkSelectItem:setAnchorPoint(ccp(0, 0.5))
        pkSelectItem:setScale(pkscale)
        local pkSelectBtn = CCMenu:createWithItem(pkSelectItem)
        pkSelectBtn:setTouchPriority(-3)
        pkSelectBtn:setPosition(210, pkposy)
        self.loginLayer:addChild(pkSelectBtn, 80)
        
        local lbWidth = 500
        local acceptPKtip, tipLbHeight = G_getRichTextLabel(getlocal("loginTip_acceptPK"), {nil, G_ColorYellowPro, nil, G_ColorYellowPro, nil}, 20, lbWidth, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop)
        acceptPKtip:setAnchorPoint(ccp(0, 1))
        self.loginLayer:addChild(acceptPKtip, 82)
        local acceptPKtipTmpLb = GetTTFLabel(getlocal("loginTip_acceptPK"), 20)
        local realWidth = acceptPKtipTmpLb:getContentSize().width
        if realWidth > lbWidth then
            realWidth = lbWidth
        end
        local tipBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(4, 4, 2, 2), self.showProtocol)
        -- tipBg:setOpacity(0)
        tipBg:setTouchPriority(-4)
        tipBg:setAnchorPoint(ccp(0, 1))
        tipBg:setContentSize(CCSizeMake(realWidth, tipLbHeight))
        self.loginLayer:addChild(tipBg, 79)
        pkSelectBtn:setPosition((G_VisibleSizeWidth - pkSelectedSp:getContentSize().width * pkscale - realWidth) / 2, pkposy)
        pkSelectedSp:setPosition(pkSelectBtn:getPosition())
        acceptPKtip:setPosition(pkSelectedSp:getPositionX() + pkSelectedSp:getContentSize().width * pkscale, pkposy + tipLbHeight / 2)
        tipBg:setPosition(acceptPKtip:getPosition())
        
        self:refreshAcceptPk()
    end
    
    --****************** 以下是新修改的登录按钮 ***************
    local loginSceneBtnType = 2
    if platCfg.platCfgLoginSceneBtnType[G_curPlatName()] ~= nil then
        loginSceneBtnType = platCfg.platCfgLoginSceneBtnType[G_curPlatName()]
    end
    
    if loginSceneBtnType == 1 or loginSceneBtnType == 2 then --使用sdk账号
        if G_curPlatName() == "androidtencently" or G_curPlatName() == "androidtencentyxb" then --腾讯包换成qq登录
            loginItemPlat = GetButtonItem2("public/qq_btn.png", "public/qq_btn_down.png", "public/qq_btn.png", loginGamePlat, nil, "QQ登录", 25, 101)
        else
            loginItemPlat = GetButtonItem("newAccloginBtn.png", "newAccloginBtn_down.png", "newAccloginBtn.png", loginGamePlat, nil, getlocal("platIDLoginGame"), 25, 101)
        end
    elseif loginSceneBtnType == 4 or loginSceneBtnType == 5 or loginSceneBtnType == 7 or loginSceneBtnType == 8 then --直接使用facebook账号登录按钮
        loginItemPlat = GetButtonItem("newAccFbloginBtn.png", "newAccFbloginBtn_down.png", "newAccFbloginBtn.png", loginGamePlat, nil, getlocal("platIDLoginGame"), 25, 101)
    end
    if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/bubbleImage.plist")
        if(G_curPlatName() == "androidkunlun1mobile")then
            loginItemPlat = GetButtonItem("kunlunLoginFb.png", "kunlunLoginFb_down.png", "kunlunLoginFb_down.png", loginGamePlat, nil, nil, 25, 101)
        else
            loginItemPlat = GetButtonItem("kunlunLogin.png", "kunlunLogin_down.png", "kunlunLogin.png", loginGamePlat, nil, nil, 25, 101)
        end
    end
    local loginMenuPlat = CCMenu:createWithItem(loginItemPlat);
    loginMenuPlat:setPosition(ccp(320, 350 - temHight + addHeight))
    loginMenuPlat:setTouchPriority(-2);
    self.loginLayer:addChild(loginMenuPlat)
    
    table.insert(self.aniMationSpTb, loginMenuPlat)
    
    --=========以下是针对loginSceneBtnType＝7 的登录界面做的特殊处理==========
    if loginSceneBtnType == 7 then
        loginMenuPlat:setPosition(ccp(320, 350 - temHight + 70))
        
        local lgnwz = getlocal("loginTypeQiTaFangShi")
        
        if G_curPlatName() == "androidkunlunz" and G_Version >= 3 then
            lgnwz = "Login"
        end
        
        local loginMenuSdkItem = GetButtonItem("newAccloginBtn.png", "newAccloginBtn_down.png", "newAccloginBtn.png", loginGameSdkPlat, nil, lgnwz, 25)
        if(platCfg.platCfgBMImage[G_curPlatName()] ~= nil)then
            loginMenuSdkItem = GetButtonItem("kunlunLogin.png", "kunlunLogin_down.png", "kunlunLogin.png", loginGameSdkPlat, nil, nil, 25)
        end
        
        local loginMenuSdkMenu = CCMenu:createWithItem(loginMenuSdkItem);
        loginMenuSdkMenu:setPosition(ccp(320, 350 - temHight - 15 + addHeight))
        loginMenuSdkMenu:setTouchPriority(-2);
        if G_curPlatName() ~= "testServer" then
            self.loginLayer:addChild(loginMenuSdkMenu)
        end
        table.insert(self.aniMationSpTb, loginMenuSdkMenu)
        
    end
    --=========以上是针对loginSceneBtnType＝7 的登录界面做的特殊处理====================
    
    --=========以下针对自定义账号loginSceneBtnType=8 or loginSceneBtnType=9 的界面(rayjoy账号按钮)做的特殊处理=========
    if loginSceneBtnType == 8 or loginSceneBtnType == 9 or loginSceneBtnType == 10 then
        if G_curPlatName() == "androidjapan" or (G_curPlatName() == "20" and G_Version == 4) then
            loginMenuPlat:setPosition(ccp(3200, 350 - temHight + 70 + addHeight))
        else
            loginMenuPlat:setPosition(ccp(320, 350 - temHight + 70 + addHeight))
        end
        
        local loginMenuSdkItem = GetButtonItem("newAccloginBtn.png", "newAccloginBtn_down.png", "newAccloginBtn.png", loginGameSdkPlat, nil, getlocal("platIDLoginGame"), 25)
        local loginMenuSdkMenu = CCMenu:createWithItem(loginMenuSdkItem);
        loginMenuSdkMenu:setPosition(ccp(320, 350 - temHight - 15 + addHeight))
        loginMenuSdkMenu:setTouchPriority(-2);
        if G_curPlatName() ~= "testServer" then
            self.loginLayer:addChild(loginMenuSdkMenu)
        end
        table.insert(self.aniMationSpTb, loginMenuSdkMenu)
    end
    --=========以上针对自定义账号loginSceneBtnType=8 or loginSceneBtnType=9 的界面做的特殊处理=========
    
    ---=========以下是快速登录(游客)按钮========
    if loginSceneBtnType == 1 or loginSceneBtnType == 3 or loginSceneBtnType == 4 or loginSceneBtnType == 6 or loginSceneBtnType == 7 or loginSceneBtnType == 8 or loginSceneBtnType == 9 or loginSceneBtnType == 10 then
        local dlWZ = getlocal("gustItmeTTF")
        if loginSceneBtnType == 7 then
            dlWZ = getlocal("loginTypeYiJianDengLu")
        end
        local loginItem
        if G_curPlatName() == "androidtencently" or G_curPlatName() == "androidtencentyxb" then --腾讯包换成微信登录
            loginItem = GetButtonItem2("public/wx_btn.png", "public/wx_btn_down.png", "public/wx_btn.png", loginGame, nil, "微信登录", 25)
        elseif(platCfg.platCfgBMImage[G_curPlatName()] ~= nil)then --北美特殊按钮
            loginMenuSdkItem = GetButtonItem("kunlunLoginGuest.png", "kunlunLoginGuest_down.png", "kunlunLoginGuest.png", loginGameSdkPlat, nil, nil, 25)
        else
            loginItem = GetButtonItem("newAccloginBtn.png", "newAccloginBtn_down.png", "newAccloginBtn.png", loginGame, nil, dlWZ, 25)
        end
        local loginMenu = CCMenu:createWithItem(loginItem);
        loginMenu:setPosition(ccp(320, 250 - temHight + addHeight))
        loginMenu:setTouchPriority(-2);
        self.loginLayer:addChild(loginMenu)
        table.insert(self.aniMationSpTb, loginMenu)
        if G_curPlatName() == "51" then
            loginItem:setEnabled(false)
            loginMenu:setVisible(false)
        end
        --=====飞流特殊处理=====开始
        if G_curPlatName() == "5" or G_curPlatName() == "9" or G_curPlatName() == "45" or G_curPlatName() == "58" then
            local isBindFLStr = CCUserDefault:sharedUserDefault():getStringForKey("isBindFL")
            if isBindFLStr == "2" then --游客玩家
                loginMenu:setPosition(ccp(320, 250 - temHight + addHeight)) --游客
                loginMenuPlat:setPosition(ccp(320 + 10000, 250 - temHight + addHeight)) --sdk用户
            elseif isBindFLStr == "1" then --绑定后
                loginMenu:setPosition(ccp(320 + 10000, 250 - temHight + addHeight)) --游客
                loginMenuPlat:setPosition(ccp(320, 250 - temHight + addHeight)) --sdk用户
            end
        end
        --=====飞流特殊处理=====结束
    end
    
    if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
        for k, v in pairs(self.aniMationSpTb) do
            if k == 3 then
                table.remove(self.aniMationSpTb, k)
                v:removeFromParentAndCleanup(true)
            end
        end
        if(self.aniMationSpTb[1])then
            self.aniMationSpTb[1]:setPosition(ccp(320, 350 - temHight - 15 + addHeight))
        end
        if(self.aniMationSpTb[2])then
            self.aniMationSpTb[2]:setPosition(ccp(320, 250 - temHight + addHeight))
        end
        
    end
    
    if loginSceneBtnType == 2 or loginSceneBtnType == 5 then
        loginMenuPlat:setPosition(ccp(320, 250 - temHight + addHeight))
    end
    
    --************************************************
    local lastLoginSvr = CCUserDefault:sharedUserDefault():getStringForKey(tostring(G_local_lastLoginSvr))
    local loginInfo
    if self.selectedSvr == true then
        loginInfo = getlocal("choicedServer")
    elseif lastLoginSvr == "" then
        loginInfo = getlocal("bestServer")
    else
        local curArea = Split(lastLoginSvr, ",")[1]
        local curAreaServer = Split(lastLoginSvr, ",")[2]
        
        if serverCfg:checkServerValid(curArea, curAreaServer) == false then
            loginInfo = getlocal("bestServer")
        else
            loginInfo = getlocal("lastServer")
        end
    end
    
    if self.selectedSvr == true then
    elseif lastLoginSvr == "" then
        self.curServerName = serverCfg:getBestServer(G_country)
    else
        local curArea = Split(lastLoginSvr, ",")[1]
        local curAreaServer = Split(lastLoginSvr, ",")[2]
        if serverCfg:checkServerValid(curArea, curAreaServer) == false then
            self.curServerName = serverCfg:getBestServer(G_country)
        else
            self.curServerName = lastLoginSvr
        end
    end
    base.curServerCfgName = self.curServerName
    ----记录当前选择的服务器的zoneID
    print("优先的服务器", self.curServerName)
    local k1, k2 = Split(self.curServerName, ",")[1], Split(self.curServerName, ",")[2]
    local serverData = serverCfg:getServerInfo(k1, k2)
    
    local svrIP = Split(serverData.ip, ",")[1]
    local userIP = serverData.userip
    base.serverUserIp = userIP
    base.memoryServerIp = serverData.msip --怀旧服入口机地址
    base.memoryServerPlatId = serverData.mspid --服务器数据中记录的各平台的平台id
    local domainIp = serverCfg:gucenterServerIp() --gucenter的访问地址
    serverCfg.baseUrl = "http://"..domainIp..serverData.domain
    serverCfg.statisticsUrl = "http://"..svrIP..serverCfg.statisticsDir
    
    serverCfg.clientErrLogUrl = "http://"..svrIP..serverCfg.clientErrLogDir
    serverCfg.feedPicUrl = "http://"..userIP..serverCfg.feedPicDir
    if(G_curPlatName() == "11")then
        serverCfg.feedPicUrl = "http://tank-ger-web01.raysns.com"..serverCfg.feedPicDir
    end
    serverCfg.feedGameUrl = "http://"..userIP..serverCfg.feedGameDir
    
    serverCfg.payUrl = "http://"..svrIP..serverCfg.payDir
    base.loginurl = serverData.loginurl
    base.serverIp = svrIP
    base.payurl = serverData.payurl
    base.orderurl = serverData.orderurl
    base.curZoneID = serverData.zoneid
    base.curOldZoneID = serverData.oldzoneid
    base.curCountry = k1
    base.curArea = k2
    ----
    local posX = G_VisibleSize.width / 2
    base.curZoneServerName = GetServerName(Split(self.curServerName, ",")[2])
    self.labelSvrName = GetTTFLabel(getlocal("server", {base.curZoneServerName}), 30)
    --self.labelSvrName:setPosition(ccp(150,160-temHight))
    self.labelSvrName:setPosition(ccp(posX, 160 - temHight + addHeight))
    
    if G_getCurChoseLanguage() == "cn" and G_curPlatName() ~= "4" and G_curPlatName() ~= "efunandroiddny" then
        self.labelSvrName:setPosition(ccp(posX, 160 - temHight + 20 + addHeight))
    end
    
    self.labelSvrName:setAnchorPoint(ccp(0.5, 0.5))
    self.loginLayer:addChild(self.labelSvrName, 1)
    table.insert(self.aniMationSpTb, self.labelSvrName)
    
    local function ShowServer()
        if G_checkClickEnable() == false then
            do return end
        end
        if self.loadResFlag == true then
            do return end
        end
        
        require "luascript/script/game/scene/gamedialog/settingsDialog/serverListDialog"
        local td = serverListDialog:new()
        local tbArr = {getlocal("recentLogin"), getlocal("allServers")}
        local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("serverListOpt"), false, 7)
        loginGameScene:addChild(dialog, 4)
        PlayEffect(audioCfg.mouseClick)
    end
    
    local capInSet = CCRect(42, 26, 10, 10)
    self.serverTxtBg = LuaCCScale9Sprite:createWithSpriteFrameName("ServerTxtBtn.png", capInSet, ShowServer)
    self.serverTxtBg:setContentSize(CCSizeMake(self.labelSvrName:getContentSize().width + 20, self.labelSvrName:getContentSize().height + 20))
    self.serverTxtBg:ignoreAnchorPointForPosition(false);
    self.serverTxtBg:setAnchorPoint(ccp(0.5, 0.5));
    
    self.serverTxtBg:setIsSallow(false)
    self.serverTxtBg:setTouchPriority(-2)
    self.loginLayer:addChild(self.serverTxtBg)
    table.insert(self.aniMationSpTb, self.serverTxtBg)
    self.serverTxtBg:setPosition(ccp(posX, 160 - temHight))
    if G_getCurChoseLanguage() == "cn" and G_curPlatName() ~= "4" and G_curPlatName() ~= "efunandroiddny" then
        self.serverTxtBg:setPosition(ccp(posX, 160 - temHight + 20 + addHeight))
    end
    base:fastTickInit()
    if G_isIOS() == false then
        JInterface:apiCall(9006, "")
    end
    
    if base.switchServerTime == 0 then --uc等平台要求第一次登录时必须弹出平台的登录界面
        if platCfg.platCfgShowPlatLoginScene[G_curPlatName()] ~= nil then
            local function loginAuto()
                if(loginScene:checkPlatShowHexieBg() == true and self.hexieBgPlayEnd == false)then
                    do return end
                end
                if self.fastTickID ~= nil then
                    CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fastTickID)
                    self.fastTickID = nil
                end
                loginGamePlat()
            end
            self.fastTickID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(loginAuto, 0, false)
        end
    end
    
    -- self:showAni()
    self:initTick()
    if G_loginType == 2 and base.switchServerTime == 0 and (G_curPlatName() == "20" or G_curPlatName() == "androidjapan" or G_curPlatName() == "31")then
        local function loginAuto()
            if self.fastTickID ~= nil then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.fastTickID)
            end
            local lastLoginTp = CCUserDefault:sharedUserDefault():getStringForKey("rayjoyAccountLastLoginType")
            if lastLoginTp == "" then
                do return end
            end
            base.loginAccountType = tonumber(lastLoginTp)
            if base.loginAccountType == 0 then --fb账号
                loginGamePlat()
            elseif base.loginAccountType == 1 then --rayjoy账号
                local luname = CCUserDefault:sharedUserDefault():getStringForKey("rayjoyAccountUname")
                local lpwd = CCUserDefault:sharedUserDefault():getStringForKey("rayjoyAccountPwd")
                base.tmpUserName = luname
                base.tmpUserPassword = lpwd
                
                self:loginByPlatAccout(luname, lpwd)
            elseif base.loginAccountType == 2 then
                loginGame()
            end
        end
        self.fastTickID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(loginAuto, 0, false)
    end
    if CCUserDefault:sharedUserDefault():getStringForKey("customServer1") ~= "" then
        self:enterServerInfo()
    end
    --kakao的特殊登录逻辑
    if(G_isKakao()) and (base.platformUserId == nil)then
        self:showkakaoLoginScene()
    end
    if(G_curPlatName() == "14")then
        local showFlag = CCUserDefault:sharedUserDefault():getIntegerForKey("gameHasShown")
        if(showFlag == 0 or showFlag == nil)then
            self:showPlatSpecialPage()
        end
        -- elseif(G_curPlatName()=="42")then
        --   if(self.showFlag==nil or self.showFlag==false)then
        --       self:showPlatSpecialPage()
        --   end
    end
    -- if(G_curPlatName()=="5" or (G_curPlatName()=="flandroid" and (G_Version==nil or tonumber(G_Version)<11)) or G_curPlatName()=="63")then
    --     if(loginScene.showFlag~=1)then
    --       loginScene:showPlatSpecialPage()
    --       loginScene.showFlag=1
    --     end
    -- end
    if G_getCurChoseLanguage() == "cn" and G_curPlatName() ~= "4" and G_curPlatName() ~= "efunandroiddny" and G_isApplyVersion() == false then
        local adaSize = 18
        local adaHeight = 30
        if G_getIphoneType() == G_iphoneX then
            adaHeight = 60
        end
        local healthGameTxt1 = "抵制不良游戏，拒绝盗版游戏。"
        local healthGameTxt2 = "注意自我保护，谨防受骗上当。"
        local healthGameTxt3 = "适度游戏益脑，沉迷游戏伤身。"
        local healthGameTxt4 = "合理安排时间，享受健康生活。"
        local healthGameTxt5 = "文网游备字[2014]M-SLG028号  ISBN: 978-7-89390-057-0"
        local healthGameLabel1 = CCLabelTTF:create(healthGameTxt1..healthGameTxt2, "Helvetica", adaSize)
        healthGameLabel1:setAnchorPoint(CCPointMake(0.5, 0.5))
        healthGameLabel1:setColor(G_ColorHealthYellow)
        healthGameLabel1:setPosition(ccp(320, healthGameLabel1:getContentSize().height + adaHeight))
        self.loginLayer:addChild(healthGameLabel1, 90)
        
        local healthGameLabel2 = CCLabelTTF:create(healthGameTxt3..healthGameTxt4, "Helvetica", adaSize)
        healthGameLabel2:setAnchorPoint(CCPointMake(0.5, 0.5))
        healthGameLabel2:setColor(G_ColorHealthYellow)
        healthGameLabel2:setPosition(ccp(320, healthGameLabel1:getPositionY() - healthGameLabel1:getContentSize().height))
        self.loginLayer:addChild(healthGameLabel2, 90)
        if(G_curPlatName() == "androidtencent" or G_curPlatName() == "androidtencentysdk" or G_curPlatName() == "androidtencently")then
            healthGameTxt5 = "文网游备字[2014]M-SLG028号  ISBN: 978-7-7979-3956-0"
        elseif(G_curPlatName() == "androidhuli" and G_Version == 10)then
            healthGameTxt5 = ""
        end
        local healthContentHeight = healthGameLabel1:getContentSize().height + healthGameLabel2:getContentSize().height + 10
        local healthPosY = 5
        if(G_curPlatName() ~= "androidewantest" and G_curPlatName() ~= "androidewan")then
            local healthGameLabel3 = CCLabelTTF:create(healthGameTxt5, "Helvetica", adaSize)
            healthGameLabel3:setColor(G_ColorHealthGray)
            healthGameLabel3:setPosition(ccp(320, healthPosY + healthGameLabel3:getContentSize().height / 2))
            -- if G_getIphoneType() == G_iphoneX then
            --     healthGameLabel3:setPosition(ccp(320, healthGameLabel2:getPositionY() - healthGameLabel2:getContentSize().height))
            -- end
            self.loginLayer:addChild(healthGameLabel3, 90)
            healthContentHeight = healthContentHeight + healthGameLabel3:getContentSize().height
            healthPosY = healthPosY + healthGameLabel3:getContentSize().height
        end
        healthGameLabel2:setPosition(G_VisibleSizeWidth / 2, healthPosY + healthGameLabel2:getContentSize().height / 2)
        healthPosY = healthPosY + healthGameLabel2:getContentSize().height
        healthGameLabel1:setPosition(G_VisibleSizeWidth / 2, healthPosY + healthGameLabel1:getContentSize().height / 2)
        
        local healthGameBg = LuaCCScale9Sprite:create("public/loadingTipBg.png", CCRect(0, 0, G_VisibleSizeWidth, healthContentHeight), CCRect(11, 11, 2, 2), function () end)
        -- local adaBgScaleY = 2.8
        if healthGameBg ~= nil then
            healthGameBg:setAnchorPoint(ccp(0.5, 0))
            -- healthGameBg:setPosition(ccp(healthGameLabel1:getPositionX(), 0))
            healthGameBg:setPosition(ccp(G_VisibleSizeWidth / 2, 0))
            healthGameBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, healthContentHeight))
            -- healthGameBg:setScaleX((healthGameLabel1:getContentSize().width + 20) / healthGameBg:getContentSize().width)
            -- if G_getIphoneType() == G_iphoneX then
            --     adaBgScaleY = (healthGameBg:getContentSize().height * adaBgScaleY + 30) / healthGameBg:getContentSize().height
            --     healthGameBg:setScaleX(G_VisibleSizeWidth / healthGameBg:getContentSize().width)
            -- end
            -- healthGameBg:setScaleY(adaBgScaleY)
            healthGameBg:setOpacity(0.7 * 255)
            self.loginLayer:addChild(healthGameBg, 89, 73)
        end
    end
    -- if(G_isIOS())then
    --     local tmpTb = {}
    --     tmpTb["action"] = "getDeviceID"
    --     tmpTb["parms"] = {}
    --     local cjson = G_Json.encode(tmpTb)
    --     local deviceids = G_accessCPlusFunction(cjson)
    --     base.deviceID = deviceids
    --     if(base.deviceID)then
    --         deviceHelper:luaPrint("设备ID："..base.deviceID)
    --     end
    -- end
    
    G_statisticsAuditRecord(AuditOp.LOGINUI) --进入登录页面
end

function loginScene:refreshAcceptPk()
    if self.pkSelectedSp == nil then
        do return end
    end
    self.acceptPk = CCUserDefault:sharedUserDefault():getBoolForKey("acceptProtocolKey")
    if self.acceptPk == true then
        self.pkSelectedSp:setVisible(true)
    else
        self.pkSelectedSp:setVisible(false)
    end
end

function loginScene:showAni(logoSpName)
    if self.logoSp == nil then
        do return end
    end
    
    if G_curPlatName() == "android3kwan" then
        do
            return
        end
    end
    
    local positionTb = {}
    for k, v in pairs(self.aniMationSpTb) do
        positionTb[k] = {}
        positionTb[k][1] = v:getPositionX()
        positionTb[k][2] = v:getPositionY()
        v:setPosition(ccp(v:getPositionX(), v:getPositionY() - 800))
    end
    print("aa=", SizeOfTable(self.aniMationSpTb))
    local logoSpIndex = SizeOfTable(self.aniMationSpTb) + 1
    positionTb[logoSpIndex] = {}
    positionTb[logoSpIndex][1] = self.logoSp:getPositionX()
    positionTb[logoSpIndex][2] = self.logoSp:getPositionY()
    
    for k, v in pairs(self.aniMationSpTb) do
        local moveTo1 = CCMoveTo:create(0.5, ccp(positionTb[k][1], positionTb[k][2] + 30))
        local moveTo2 = CCMoveTo:create(0.1, ccp(positionTb[k][1], positionTb[k][2]))
        local seq = CCSequence:createWithTwoActions(moveTo1, moveTo2)
        v:runAction(seq)
    end
    
    self.logoSp:setPosition(ccp(positionTb[SizeOfTable(self.aniMationSpTb) + 1][1], positionTb[logoSpIndex][2] + 600))
    self.logoSp:setScale(0.5)
    
    local newLoadingDisabledCfg = platCfg.platCfgNewLoadingDisabled[G_curPlatName()] --不能使用新的loading效果的配置
    local function callbcak()
        if platCfg.platCfgNewLogoEffect[logoSpName] and newLoadingDisabledCfg == nil then
            self:playLogoEffect()
        else
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
            local sp = CCSprite:create("public/logo_effect.png")
            CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
            sp:setPosition(getCenterPoint(self.logoSp))
            self.logoSp:addChild(sp)
            sp:setOpacity(170)
            local fadeOut1 = CCFadeTo:create(0.2, 170)
            local rotate = CCRotateTo:create(2, 720)
            local fadeOut2 = CCFadeTo:create(0.2, 0)
            local delay = CCDelayTime:create(5)
            local acArr = CCArray:create()
            acArr:addObject(fadeOut1)
            acArr:addObject(rotate)
            acArr:addObject(fadeOut2)
            acArr:addObject(delay)
            local seq = CCSequence:create(acArr)
            
            local repeatForever = CCRepeatForever:create(seq)
            sp:runAction(repeatForever)
        end
    end
    local fc = CCCallFunc:create(callbcak)
    local moveTo = CCMoveTo:create(0.5, ccp(positionTb[logoSpIndex][1], positionTb[logoSpIndex][2]))
    local scaleTo = CCScaleTo:create(0.2, 1);
    local acArr = CCArray:create()
    acArr:addObject(moveTo)
    acArr:addObject(scaleTo)
    acArr:addObject(fc)
    local seq = CCSequence:create(acArr)
    self.logoSp:runAction(seq)
    
    if newLoadingDisabledCfg then --如果不使用新的loading效果，则播放原先loading的粒子动画
        --粒子效果
        local particleS = CCParticleSystemQuad:create("public/particleSmog.plist")
        particleS.positionType = kCCPositionTypeFree
        particleS:setPosition(ccp(300, -100))
        self.effectLayer:addChild(particleS, 10001)
        
        local particleS2 = CCParticleSystemQuad:create("public/particleFire.plist")
        particleS2.positionType = kCCPositionTypeFree
        particleS2:setPosition(ccp(500, -100))
        self.effectLayer:addChild(particleS2, 10001)
        
        -- local particleS3 = CCParticleSystemQuad:create("public/particleFlake.plist")
        -- particleS3.positionType=kCCPositionTypeFree
        -- particleS3:setPosition(ccp(150,540))
        -- self.loginLayer:addChild(particleS3,1)
        
        -- local loadingBk = CCSprite:create("public/tankLoadingBg.png")
        -- loadingBk:setPosition(ccp(320,300));
        -- CCDirector:sharedDirector():getRunningScene():addChild(loadingBk,10000);
    end
end

function loginScene:close()
    self.isShowing = false
    self.loadResFlag = false
    self.curServerName = nil
    self.labelLastLogin = nil --显示的账号类型   推荐？已选？上次登陆
    self.labelSvrName = nil --与显示账号对应的服务器名称
    self.loginLayer = nil
    self.effectLayer = nil
    self.selectedSvr = false
    self.aniMationSpTb = {}
    self.logoSp = nil
    if platCfg.platCfgBMImage[G_curPlatName()] ~= nil then
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile("public/bubbleImage.plist")
        CCTextureCache:sharedTextureCache():removeTextureForKey("public/bubbleImage.png")
    end
    self:clearAccountLoginLayer()
    if self.acceptPkListener then
        eventDispatcher:removeEventListener("user.accept.protocol", self.acceptPkListener)
        self.acceptPkListener = nil
    end
    self.accoutLayer=nil
    self.listLayer=nil
    self.clickHereTipLabel=nil
    self.videoPlayer=nil
    self.luaProgress=nil
    self.luaProgressLb=nil    
    self.luaDescTb = nil
end

function loginScene:setSelectServer(serverName)
    if self.labelSvrName ~= nil then
        self.labelSvrName:setString(getlocal("server", {GetServerName(Split(serverName, ",")[2])}))
        self.serverTxtBg:setContentSize(CCSizeMake(self.labelSvrName:getContentSize().width + 20, self.labelSvrName:getContentSize().height + 20))
    end
    if self.labelLastLogin ~= nil then
        self.labelLastLogin:setString(getlocal("choicedServer"))
        self.curServerName = serverName
        self.labelSvrName:setString(Split(serverName, ",")[2])
        self.labelSvrName:setString(getlocal("server", {GetServerName(Split(serverName, ",")[2])}))
        self.serverTxtBg:setContentSize(CCSizeMake(self.labelSvrName:getContentSize().width + 20, self.labelSvrName:getContentSize().height + 20))
    else
        self.selectedSvr = true
        self.curServerName = serverName
    end
    base.curServerCfgName = self.curServerName
    base.curZoneServerName = GetServerName(Split(self.curServerName, ",")[2])
    ----记录当前选择的服务器的zoneID
    local k1, k2 = Split(self.curServerName, ",")[1], Split(self.curServerName, ",")[2]
    local serverData = serverCfg:getServerInfo(k1, k2)
    local svrIP = Split(serverData.ip, ",")[1]
    local userIP = serverData.userip
    base.serverUserIp = userIP
    base.memoryServerIp = serverData.msip --怀旧服入口机地址
    base.memoryServerPlatId = serverData.mspid --服务器数据中记录的各平台的平台id
    local domainIp = serverCfg:gucenterServerIp() --gucenter的访问地址
    serverCfg.baseUrl = "http://"..domainIp..serverData.domain
    serverCfg.statisticsUrl = "http://"..svrIP..serverCfg.statisticsDir
    
    serverCfg.payUrl = "http://"..svrIP..serverCfg.payDir
    base.serverIp = svrIP
    base.loginurl = serverData.loginurl
    base.payurl = serverData.payurl
    base.orderurl = serverData.orderurl
    base.curZoneID = serverData.zoneid
    base.curOldZoneID = serverData.oldzoneid
    base.curCountry = k1
    base.curArea = k2
    -- print("serverCfg.baseUrl,base.payurl===> ",serverCfg.baseUrl,base.payurl,serverCfg.baseUrl)
    ----
end

function loginScene:createNewRole(callBackHandler, cuid)
    --PlayEffect(audioCfg.mouseClick)
    local function touch()
        
    end
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    
    local bgSp = LuaCCScale9Sprite:createWithSpriteFrameName("panelBg.png", CCRect(168, 86, 10, 10), touch)
    
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    bgSp:setContentSize(rect)
    bgSp:setPosition(CCPointMake(G_VisibleSize.width / 2, G_VisibleSize.height / 2))
    bgSp:ignoreAnchorPointForPosition(false)
    self.loginLayer:addChild(bgSp, 3)
    bgSp:setTouchPriority(-21);
    bgSp:setIsSallow(true)
    
    local rect = CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight)
    local titleLb = GetTTFLabel(getlocal("createRoleTitle"), 40)
    titleLb:setAnchorPoint(ccp(0.5, 0.5))
    titleLb:setPosition(ccp(bgSp:getContentSize().width / 2, bgSp:getContentSize().height - titleLb:getContentSize().height / 2 - 15))
    bgSp:addChild(titleLb)
    
    local function close()
        PlayEffect(audioCfg.mouseClick)
        bgSp:removeFromParentAndCleanup(true)
    end
    local closeBtnItem = GetButtonItem("closeBtn.png", "closeBtn_Down.png", "closeBtn_Down.png", close, nil, nil, nil);
    closeBtnItem:setPosition(0, 0)
    closeBtnItem:setAnchorPoint(CCPointMake(0, 0))
    
    local closeBtn = CCMenu:createWithItem(closeBtnItem)
    closeBtn:setTouchPriority(-34)
    closeBtn:setPosition(ccp(rect.width - closeBtnItem:getContentSize().width, rect.height - closeBtnItem:getContentSize().height))
    bgSp:addChild(closeBtn)
    
    local function bgAnimationSelected()
        local scaleTo = CCScaleTo:create(0.1, 1);
        local fadeOut = CCTintTo:create(0.1, 255, 255, 255)
        --local fadeOut=CCFadeTo:create(0.1,255)
        local carray = CCArray:create()
        carray:addObject(scaleTo)
        carray:addObject(fadeOut)
        local spa = CCSpawn:create(carray)
        return spa;
    end
    
    local function bgAnimationSelected2()
        local scaleTo = CCScaleTo:create(0.1, 0.7);
        local fadeOut = CCTintTo:create(0.1, 150, 150, 150)
        --local fadeOut=CCFadeTo:create(0.1,60)
        local carray = CCArray:create()
        carray:addObject(scaleTo)
        carray:addObject(fadeOut)
        local spa = CCSpawn:create(carray)
        return spa;
    end
    
    local roleType = 1;
    local roleName = "";
    local roleTb = {"public/man.png", "public/woman.png"}
    if(G_curPlatName() == "androidflbaidu" or G_curPlatName() == "48")then
        roleTb = {"flBaiduImage/man.png", "flBaiduImage/woman.png"}
    end
    local rolePh = {}
    local function touchPhoto(object, name, tag)
        local sp1 = bgSp:getChildByTag(tag);
        local sp2 = sp1:getChildByTag(2);
        local spa1 = bgAnimationSelected()
        sp1:runAction(spa1)
        local fadeOut = CCTintTo:create(0.1, 255, 255, 255)
        sp2:runAction(fadeOut)
        
        for k, v in pairs(rolePh) do
            if v:getTag() ~= tag then
                
                local spa1 = bgAnimationSelected2()
                local sp2 = v:getChildByTag(2);
                local fadeOut = CCTintTo:create(0.1, 150, 150, 150)
                v:runAction(spa1)
                sp2:runAction(fadeOut)
                
            end
        end
        
        roleType = tag;
        
    end
    local sign = 0;
    local function touchBg()
        
    end
    for k, v in pairs(roleTb) do
        sign = sign + 1
        local name = v
        local spBg = LuaCCSprite:createWithFileName("public/framebtn.png", touchPhoto);
        local chSp = LuaCCSprite:createWithFileName(name, touchBg);
        chSp:setTag(2)
        if sign <= 3 then
            spBg:setPosition(ccp(185 + (sign - 1) * 270, bgSp:getContentSize().height / 2 + 100));
            chSp:setPosition(getCenterPoint(spBg));
        else
            spBg:setPosition(ccp(155 + (sign - 4) * 160, bgSp:getContentSize().height / 2 - 270));
            chSp:setPosition(getCenterPoint(spBg));
        end
        if k == 2 then
            spBg:setScale(0.7)
            spBg:setColor(ccc3(150, 150, 150))
            chSp:setColor(ccc3(150, 150, 150))
        end
        spBg:setTag(sign);
        spBg:setIsSallow(true)
        spBg:setTouchPriority(-32)
        rolePh[k] = spBg
        bgSp:addChild(spBg, 1)
        spBg:addChild(chSp, 2)
    end
    
    local function tthandler()
        
    end
    local function callBackXHandler(fn, eB, str)
        if str ~= nil then
            roleName = str;
            roleName = G_stringGsub(roleName, " ", "")
            if self.clickHereTipLabel ~= nil then
                self.clickHereTipLabel:setVisible(false)
            end
        end
    end
    
    local nameBox = LuaCCScale9Sprite:createWithSpriteFrameName("inputNameBg.png", CCRect(70, 35, 1, 1), tthandler)
    nameBox:setContentSize(CCSize(420, 80))
    nameBox:setPosition(ccp(bgSp:getContentSize().width / 2, 220))
    bgSp:addChild(nameBox)
    
    local targetBoxLabel = GetTTFLabel("", 30)
    targetBoxLabel:setAnchorPoint(ccp(0, 0.5))
    targetBoxLabel:setPosition(ccp(10, nameBox:getContentSize().height / 2))
    local customEditBox = customEditBox:new()
    local length = 20
    customEditBox:init(nameBox, targetBoxLabel, "inputNameBg.png", nil, -32, length, callBackXHandler, nil, nil)
    
    if platCfg.platCfgShowDefaultRoleName[G_curPlatName()] == nil then
        --这里开始
        
        local tipLabel = GetTTFLabel(getlocal("limitLength", {12}), 26)
        tipLabel:setAnchorPoint(ccp(0.5, 1))
        tipLabel:setPosition(ccp(bgSp:getContentSize().width / 2 - 130, 185))
        bgSp:addChild(tipLabel, 2)
        tipLabel:setColor(G_ColorRed)
        
        self.clickHereTipLabel = GetTTFLabel("点击这里输入名称", 30)
        self.clickHereTipLabel:setAnchorPoint(ccp(0.5, 0.5))
        self.clickHereTipLabel:setPosition(ccp(bgSp:getContentSize().width / 2, 220))
        bgSp:addChild(self.clickHereTipLabel, 10)
        self.clickHereTipLabel:setColor(G_ColorYellow)
        
        local cannotInputLabel = GetTTFLabel(getlocal("cannotInput"), 26)
        cannotInputLabel:setAnchorPoint(ccp(0, 1))
        cannotInputLabel:setPosition(ccp(bgSp:getContentSize().width / 2 - 20, 185))
        bgSp:addChild(cannotInputLabel, 2)
        cannotInputLabel:setColor(G_ColorGreen)
        
        local clickHereLabel = GetTTFLabel(getlocal("clickHere"), 26)
        clickHereLabel:setAnchorPoint(ccp(0, 1))
        clickHereLabel:setPosition(ccp(bgSp:getContentSize().width / 2 + 108, 185))
        bgSp:addChild(clickHereLabel, 2)
        clickHereLabel:setColor(G_ColorGreen)
        
        local male1 = {"阿波", "阿道", "阿尔", "阿姆", "阿诺", "阿奇", "埃达", "埃德", "埃迪", "埃尔", "埃里", "埃玛", "埃文", "艾比", "艾伯", "艾布", "艾丹", "艾德", "艾登", "艾尔", "艾富", "艾理", "艾伦", "艾略", "艾谱", "艾萨", "艾塞", "艾丝", "艾文", "艾西", "爱得", "爱德", "爱迪", "爱尔", "爱格", "爱莉", "爱罗", "爱曼", "安得", "安德", "安迪", "安东", "安格", "安纳", "安其", "安斯", "奥布", "奥德", "奥尔", "奥古", "奥劳", "奥利", "奥斯", "奥特", "巴德", "巴顿", "巴尔", "巴克", "巴里", "巴伦", "巴罗", "巴奈", "巴萨", "巴特", "巴泽", "柏得", "柏德", "柏格", "柏塔", "柏特", "柏宜", "拜尔", "拜伦", "班克", "班奈", "班尼", "宝儿", "保罗", "鲍比", "鲍伯", "贝尔", "贝克", "贝齐", "本恩", "本杰", "本森", "比尔", "比利", "比其", "彼得", "毕维", "毕夏", "宾尔", "波顿", "波特", "波文", "伯顿", "伯恩", "伯里", "伯尼"}
        local male2 = {"伯特", "博格", "布德", "布拉", "布莱", "布赖", "布兰", "布朗", "布雷", "布里", "布鲁", "布伦", "布尼", "布兹", "采尼", "查德", "查尔", "达尔", "达伦", "达尼", "大卫", "戴夫", "戴纳", "丹尼", "丹普", "道格", "得利", "德博", "德尔", "德里", "德维", "德文", "邓肯", "狄克", "迪得", "迪恩", "迪克", "迪伦", "迪姆", "迪斯", "蒂安", "蒂莫", "杜克", "杜鲁", "多夫", "多洛", "多明", "尔德", "尔特", "范尼", "菲比", "菲蕾", "菲力", "菲利", "菲兹", "斐迪", "费恩", "费力", "费奇", "费兹", "费滋", "佛里", "夫兰", "弗德", "弗恩", "弗兰", "弗朗", "弗莉", "弗罗", "弗农", "弗瑞", "福特", "富宾", "富兰", "盖尔", "盖克", "高达", "高德", "戈登", "格吉", "格拉", "格里", "格林", "格罗", "格纳", "葛里", "葛列", "葛瑞", "古斯", "哈帝", "哈乐", "哈里", "哈利", "哈伦", "哈瑞", "哈威", "海顿", "海勒", "海洛", "海曼"}
        local male3 = {"韩弗", "汉克", "汉米", "汉姆", "汉特", "赫伯", "赫达", "赫尔", "赫瑟", "亨利", "华纳", "霍伯", "霍尔", "霍根", "霍华", "基诺", "吉伯", "吉蒂", "吉恩", "吉罗", "吉米", "吉姆", "吉榭", "加百", "加比", "加尔", "加菲", "加里", "加文", "迦勒", "迦利", "嘉比", "贾艾", "贾斯", "杰弗", "杰克", "杰奎", "杰拉", "杰罗", "杰农", "杰瑞", "杰西", "杰伊", "捷勒", "卡尔", "卡萝", "卡洛", "卡玛", "卡梅", "卡斯", "卡特", "凯尔", "凯里", "凯理", "凯伦", "凯撒", "凯斯", "凯文", "凯希", "凯伊", "康拉", "康那", "康奈", "康斯", "考伯", "考尔", "柯帝", "柯利", "科迪", "科尔", "科林", "科兹", "克拉", "克莱", "克劳", "克雷", "克里", "克利", "克林", "克洛", "克思", "克斯", "肯姆", "肯尼", "寇里", "昆廷", "拉丁", "拉罕", "拉里", "拉斯", "莱德", "莱姆", "莱斯", "赖安", "兰德", "兰迪", "兰斯", "兰特", "劳伦", "劳瑞"}
        
        if platCfg.platCfgDefaultLocal[G_curPlatName()] == "tw" then
            male1 = {"阿波", "阿道", "阿爾", "阿姆", "阿諾", "阿奇", "埃達", "埃德", "埃迪", "埃爾", "埃裏", "埃瑪", "埃文", "艾比", "艾伯", "艾布", "艾丹", "艾德", "艾登", "艾爾", "艾富", "艾理", "艾倫", "艾略", "艾譜", "艾薩", "艾塞", "艾絲", "艾文", "艾西", "愛得", "愛德", "愛迪", "愛爾", "愛格", "愛莉", "愛羅", "愛曼", "安得", "安德", "安迪", "安東", "安格", "安納", "安其", "安斯", "奧布", "奧德", "奧爾", "奧古", "奧勞", "奧利", "奧斯", "奧特", "巴德", "巴頓", "巴爾", "巴克", "巴裏", "巴倫", "巴羅", "巴奈", "巴薩", "巴特", "巴澤", "柏得", "柏德", "柏格", "柏塔", "柏特", "柏宜", "拜爾", "拜倫", "班克", "班奈", "班尼", "寶兒", "保羅", "鮑比", "鮑伯", "貝爾", "貝克", "貝齊", "本恩", "本傑", "本森", "比爾", "比利", "比其", "彼得", "畢維", "畢夏", "賓爾", "波頓", "波特", "波文", "伯頓", "伯恩", "伯裏", "伯尼"}
            male2 = {"伯特", "博格", "布德", "布拉", "布萊", "布賴", "布蘭", "布朗", "布雷", "布裏", "布魯", "布倫", "布尼", "布茲", "采尼", "查德", "查爾", "達爾", "達倫", "達尼", "大衛", "戴夫", "戴納", "丹尼", "丹普", "道格", "得利", "德博", "德爾", "德裏", "德維", "德文", "鄧肯", "狄克", "迪得", "迪恩", "迪克", "迪倫", "迪姆", "迪斯", "蒂安", "蒂莫", "杜克", "杜魯", "多夫", "多洛", "多明", "爾德", "爾特", "範尼", "菲比", "菲蕾", "菲力", "菲利", "菲茲", "斐迪", "費恩", "費力", "費奇", "費茲", "費滋", "佛裏", "夫蘭", "弗德", "弗恩", "弗蘭", "弗朗", "弗莉", "弗羅", "弗農", "弗瑞", "福特", "富賓", "富蘭", "蓋爾", "蓋克", "高達", "高德", "戈登", "格吉", "格拉", "格裏", "格林", "格羅", "格納", "葛裏", "葛列", "葛瑞", "古斯", "哈帝", "哈樂", "哈裏", "哈利", "哈倫", "哈瑞", "哈威", "海頓", "海勒", "海洛", "海曼"}
            male3 = {"韓弗", "漢克", "漢米", "漢姆", "漢特", "赫伯", "赫達", "赫爾", "赫瑟", "亨利", "華納", "霍伯", "霍爾", "霍根", "霍華", "基諾", "吉伯", "吉蒂", "吉恩", "吉羅", "吉米", "吉姆", "吉榭", "加百", "加比", "加爾", "加菲", "加裏", "加文", "迦勒", "迦利", "嘉比", "賈艾", "賈斯", "傑弗", "傑克", "傑奎", "傑拉", "傑羅", "傑農", "傑瑞", "傑西", "傑伊", "捷勒", "卡爾", "卡蘿", "卡洛", "卡瑪", "卡梅", "卡斯", "卡特", "凱爾", "凱裏", "凱理", "凱倫", "凱撒", "凱斯", "凱文", "凱希", "凱伊", "康拉", "康那", "康奈", "康斯", "考伯", "考爾", "柯帝", "柯利", "科迪", "科爾", "科林", "科茲", "克拉", "克萊", "克勞", "克雷", "克裏", "克利", "克林", "克洛", "克思", "克斯", "肯姆", "肯尼", "寇裏", "昆廷", "拉丁", "拉罕", "拉裏", "拉斯", "萊德", "萊姆", "萊斯", "賴安", "蘭德", "蘭迪", "蘭斯", "蘭特", "勞倫", "勞瑞"}
        end
        
        local function randRoleName()
            --roleName="克里斯来看看"
            --targetBoxLabel:setString(roleName)
            self.clickHereTipLabel:setVisible(false)
            local orderTb = {}
            local maleT = deviceHelper:getRandom()
            if maleT <= 33 then
                orderTb[1] = male1
                orderTb[2] = male2
                orderTb[3] = male3
            elseif maleT > 66 then
                orderTb[1] = male3
                orderTb[2] = male1
                orderTb[3] = male2
            else
                orderTb[1] = male2
                orderTb[2] = male3
                orderTb[3] = male1
            end
            local rand1 = deviceHelper:getRandom()
            local rand2 = deviceHelper:getRandom()
            local rand3 = deviceHelper:getRandom()
            local realName = orderTb[1][rand1 == 0 and 1 or rand1]..orderTb[2][rand2 == 0 and 1 or rand2]..orderTb[3][rand3 == 0 and 1 or rand3]
            roleName = realName
            targetBoxLabel:setString(realName)
        end
        local helpmebtn = GetButtonItem("LoadingSelectServerBtn.png", "LoadingSelectServerBtn_Down.png", "LoadingSelectServerBtn.png", randRoleName, nil, getlocal("serverList"), 25)
        helpmebtn:setOpacity(0)
        helpmebtn:registerScriptTapHandler(randRoleName)
        local helpmeMenu = CCMenu:createWithItem(helpmebtn);
        helpmeMenu:setPosition(ccp(bgSp:getContentSize().width / 2 + 170, 160))
        helpmeMenu:setTouchPriority(-100);
        bgSp:addChild(helpmeMenu, 1)
        
        randRoleName()
        ---这里结束
    else
        local tipLabel = GetTTFLabel(getlocal("limitLength", {12}), 26)
        tipLabel:setAnchorPoint(ccp(0.5, 1))
        tipLabel:setPosition(ccp(bgSp:getContentSize().width / 2, 185))
        bgSp:addChild(tipLabel, 2)
        tipLabel:setColor(G_ColorRed)
    end
    
    local function createRole()
        local hasEmjoy = G_checkEmjoy(roleName)
        if hasEmjoy == false then
            do return end
        end
        
        local count = G_utfstrlen(roleName, true)
        if platCfg.platCfgKeyWord[G_curPlatName()] ~= nil then --设置屏蔽字
            if keyWordCfg:keyWordsJudge(roleName) == false then
                do
                    return
                end
            end
        end
        if G_match(roleName) ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("alliance_illegalCharacters"), true, 6, G_ColorRed)
            do
                return
            end
        end
        print("roleName=", roleName)
        if string.find(roleName, ' ') ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("blankCharacter"), true, 6, G_ColorRed)
            do
                return
            end
        end
        
        local strFisrt = G_stringGetAt(roleName, 0, 1)
        if tonumber(strFisrt) ~= nil then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("firstCharNoNum"), true, 6, G_ColorRed)
            do
                return
            end
        end
        
        if roleName == "" then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("nameNullCharacter"), true, 6, G_ColorRed)
            do
                return
            end
        end
        if count > 12 then
            
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("namelengthwrong"), true, 6, G_ColorRed)
        elseif count < 3 then
            smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("roleNameMinLen"), true, 6, G_ColorRed)
            
        else
            local function serverUserSigupHandler(fn, data)
                --local sData=G_Json.decode(data)
                local result, sData = base:checkServerData(data, false)
                if tonumber(sData.ret) >= 0 and tonumber(sData.uid) > 0 then --登记角色名,选择头像成功
                    socketHelper:userLogin(callBackHandler, sData.uid)
                    if G_curPlatName() == "15" and newGuidMgr:isNewGuiding() == false then
                        local tmpTb = {}
                        tmpTb["action"] = "firstGetUserName"
                        local cjson = G_Json.encode(tmpTb)
                        G_accessCPlusFunction(cjson)
                    end
                else
                    smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(500, 400), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), getlocal("namehasbeenused"), true, 6, G_ColorRed)
                    G_cancleLoginLoading() --注册角色名失败 取消loading
                end
                
            end
            G_showLoginLoading() --加loading
            socketHelper:userSigup(cuid, G_getTankUserName(), G_getTankUserPassWord(), roleName, roleType, serverUserSigupHandler)
        end
    end
    local menuItemCreate = GetButtonItem("newLoginBtn.png", "newLoginBtnDown.png", "newLoginBtn.png", createRole, nil, getlocal("createRole"), 25);
    
    local createBtn = CCMenu:createWithItem(menuItemCreate)
    createBtn:setTouchPriority(-34)
    createBtn:setPosition(ccp(bgSp:getContentSize().width / 2, 95))
    bgSp:addChild(createBtn)
    
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
end

function loginScene:showBindWhenLogin()
    if G_isApplyVersion() == true then
        do return end
    end
    if SizeOfTable(buildingVoApi:getBuildingVoByBtype(7)) > 0 and buildingVoApi:getBuildingVoByBtype(7)[1].level >= 5 then
        --主基地大于5级,弹出绑定提示
        local function playerBindSrue()
            --弹出绑定账号面板
            --[[
                    require "luascript/script/game/scene/gamedialog/settingsDialog/bindingAccountDialog"
                    local td=bindingAccountDialog:new()
                    local dialog=td:init("panelBg.png",true,CCSizeMake(600,900),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),{},nil,nil,getlocal("bindAccount"),false,4)
                    sceneGame:addChild(dialog,4)
                    ]]
            require "luascript/script/game/scene/gamedialog/settingsDialog/settingsDialog"
            local td = settingsDialog:new()
            local tbArr = {}
            local dialog = td:init("panelBg.png", true, CCSizeMake(600, 900), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), tbArr, nil, nil, getlocal("options"), true, 4)
            sceneGame:addChild(dialog, 4)
        end
        if G_getTankIsguest() == "1" then
            smallDialog:showSureAndCancle("PanelHeaderPopup.png", CCSizeMake(550, 460), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), playerBindSrue, getlocal("dialog_title_prompt"), getlocal("playerBindTips"), nil, 7, kCCTextAlignmentLeft)
        end
    end
    
end

function loginScene:stopTick()
    
    if self.tickHandlerIndex ~= -1 then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.tickHandlerIndex)
        self.tickHandlerIndex = -1
    end
    
end

function loginScene:initTick()
    local function checkResponse()
        self:requireLua()
        socketHelper:tick()
        if socketHelper2 ~= nil and socketHelper2.isConnected then
            socketHelper2:tick()
        end
    end
    if self.tickHandlerIndex == -1 then
        self.tickHandlerIndex = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(checkResponse, 0.1, false)
    end
    
    if G_isUseOldLogin() and self.videoPlayer == nil and UIVideoPlayer and UIVideoPlayer.create then
        local deviceSize = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
        self.videoPlayer = UIVideoPlayer:create()
        self.videoPlayer:setFileName("story/splashVideo.mp4")
        self.videoPlayer:setContentSize(deviceSize)
        self.videoPlayer:setKeepAspectRatioEnabled(true)
        self.videoPlayer:addEventListener(function(sener, eventType)
            if eventType == kUIVideoPlayer_EventType_PLAYING then --正在播放
            elseif eventType == kUIVideoPlayer_EventType_PAUSED then --暂停播放
            elseif eventType == kUIVideoPlayer_EventType_STOPPED then --停止播放
            elseif eventType == kUIVideoPlayer_EventType_COMPLETED then --播放完成
                if tolua.cast(self.videoPlayer, "CCNode") then
                    self.videoPlayer:removeFromParentAndCleanup(true)
                    self.videoPlayer = nil
                end
            end
        end)
        -- self.videoPlayer:play()
        sceneGame:addChild(self.videoPlayer, 555)
        self.videoPlayer:setLandscapeEnabled(true)
        self.videoPlayer:setVisible(false)
        self.videoPlayer:setPosition(99999, 99999)
    end
end

function loginScene:enterServerInfo()
    
    local k1, k2 = Split(self.curServerName, ",")[1], Split(self.curServerName, ",")[2]
    local serverData = serverCfg:getServerInfo(k1, k2)
    
    serverData.userip = CCUserDefault:sharedUserDefault():getStringForKey("customServer1")
    serverData.ip = CCUserDefault:sharedUserDefault():getStringForKey("customServer2")
    serverData.zoneid = tonumber(CCUserDefault:sharedUserDefault():getStringForKey("customServer3"))
    serverData.domain = "/gucenter/"
    
    for k, v in pairs(serverCfg.allserver[k1]) do
        if v.name == k2 then
            serverCfg.allserver[k1][k].port = tonumber(CCUserDefault:sharedUserDefault():getStringForKey("customServer4"))
            serverCfg.allserver[k1][k].domain = "/gucenter/"
            do
                break
            end
        end
    end
    
    for k, v in pairs(serverCfg.allChatServer[k1]) do
        if v.name == k2 then
            serverCfg.allChatServer[k1][k].port = tonumber(CCUserDefault:sharedUserDefault():getStringForKey("customServer5"))
            serverCfg.allChatServer[k1][k].ip = serverData.ip
            do
                break
            end
        end
    end
    
    local svrIP = Split(serverData.ip, ",")[1]
    local userIP = serverData.userip
    base.serverUserIp = userIP
    base.memoryServerIp = serverData.msip --怀旧服入口机地址
    base.memoryServerPlatId = serverData.mspid --服务器数据中记录的各平台的平台id
    local domainIp = serverCfg:gucenterServerIp() --gucenter的访问地址
    serverCfg.baseUrl = "http://"..domainIp..serverData.domain
    serverCfg.statisticsUrl = "http://"..svrIP..serverCfg.statisticsDir
    
    serverCfg.clientErrLogUrl = "http://"..svrIP..serverCfg.clientErrLogDir
    serverCfg.feedPicUrl = "http://"..userIP..serverCfg.feedPicDir
    if(G_curPlatName() == "11")then
        serverCfg.feedPicUrl = "http://tank-ger-web01.raysns.com"..serverCfg.feedPicDir
    end
    serverCfg.feedGameUrl = "http://"..userIP..serverCfg.feedGameDir
    
    serverCfg.payUrl = "http://"..svrIP..serverCfg.payDir
    base.loginurl = serverData.loginurl
    base.serverIp = svrIP
    base.payurl = serverData.payurl
    base.orderurl = serverData.orderurl
    base.curZoneID = serverData.zoneid
    base.curOldZoneID = serverData.oldzoneid
    base.curCountry = k1
    base.curArea = k2
end

function loginScene:showPlatSpecialPage()
    if(G_isKakao())then
        CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(G_BuildingAnimSrc)
        if G_isShowNewMapAndBuildings() == 1 then
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("newUI/newImage.plist")
        else
            CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("public/newImage.plist")
        end
        require "luascript/script/game/scene/scene/kakaoTermsDialog"
        local kakaoDialog = kakaoTermsDialog:new()
        kakaoDialog:init(4, true)
    elseif(G_curPlatName() == "14")then
        require "luascript/script/game/scene/scene/kunlunTermsDialog"
        local kunlunDialog = kunlunTermsDialog:new()
        kunlunDialog:init(4, true)
    elseif(G_curPlatName() == "5" or G_curPlatName() == "flandroid" or G_curPlatName() == "63" or G_curPlatName() == "0")then
        require "luascript/script/componet/smallDialog2"
        local str
        if(G_curPlatName() == "5" or G_curPlatName() == "0")then
            str = "亲爱的指挥官：\n由于网络波动，部分指挥官出现登录问题，我们正在进行紧急抢修，建议您点击确定按钮，下载最新游戏客户端登录游戏。\n如果点击按钮无法跳转，请在App Store中搜索“坦克风云-巨兽崛起”手动下载\n如遇到问题请联系客服QQ：690533821"
        elseif(G_curPlatName() == "flandroid" and (G_Version == nil or tonumber(G_Version) < 11))then
            str = "亲爱的指挥官：\n由于网络波动，部分指挥官出现登录问题，我们正在进行紧急抢修，建议您点击确定按钮，下载最新游戏客户端登录游戏。\n反馈问题请联系客服QQ：690533821\n"
        elseif(G_curPlatName() == "63")then
            str = "亲爱的指挥官：\n由于网络波动，部分指挥官出现登录问题，我们正在进行紧急抢修，给您带来的不便请您谅解。\n反馈问题请联系客服QQ：800032234\n"
        end
        local function onConfirm()
            local tmpTb = {}
            tmpTb["action"] = "openUrl"
            tmpTb["parms"] = {}
            if(G_curPlatName() == "5")then
                tmpTb["parms"]["url"] = "https://itunes.apple.com/cn/app/%E5%9D%A6%E5%85%8B%E9%A3%8E%E4%BA%91-%E5%B7%A8%E5%85%BD%E5%B4%9B%E8%B5%B7/id1434663744?mt=8"
                tmpTb["parms"]["connect"] = "https://itunes.apple.com/cn/app/%E5%9D%A6%E5%85%8B%E9%A3%8E%E4%BA%91-%E5%B7%A8%E5%85%BD%E5%B4%9B%E8%B5%B7/id1434663744?mt=8"
            elseif(G_curPlatName() == "flandroid" or G_curPlatName() == "0")then
                tmpTb["parms"]["url"] = "http://tank-android-download.raygame1.com/download/tank_androidfeiliu_v13_1.6.7_c11_20181207_2018127231736.apk"
                tmpTb["parms"]["connect"] = "http://tank-android-download.raygame1.com/download/tank_androidfeiliu_v13_1.6.7_c11_20181207_2018127231736.apk"
            end
            local cjson = G_Json.encode(tmpTb)
            G_accessCPlusFunction(cjson)
        end
        smallDialog:showSure("PanelHeaderPopup.png", CCSizeMake(550, 500), CCRect(0, 0, 400, 350), CCRect(168, 86, 10, 10), getlocal("dialog_title_prompt"), str, nil, 8, nil, onConfirm)
    elseif(G_curPlatName() == "42")then
        require "luascript/script/componet/smallDialog2"
        local str = "游戏服务器列表现在已经调整\n服务器名称不变，服务器序号调整的规则为：原服务器序列号+48\n例如，您原来所在\n服务器为1服，现在需要登录49服\n服务器为86服，现在需要登录134服\n服务器为90服，现在需要登录138服\n服务器为91服，现在需要登录139服\n\n以此类推，如果您遇到任何疑问，请您联系客服QQ：690533821。"
        smallDialog:showTableViewSure("TankInforPanel.png", CCSizeMake(550, 800), CCRect(0, 0, 400, 350), CCRect(130, 50, 1, 1), getlocal("shuoming"), str, true, 8, nil)
    end
end

function loginScene:requireLua()
    if(self.requireFlag ~= 1)then
        require "luascript/script/componet/smallDialog2"
        require "luascript/script/componet/smallDialog3"
        require "luascript/script/componet/newBattleResultDialog"
        require "luascript/script/game/scene/gamedialog/activityAndNote/activityAndNoteDialog"
        require "luascript/script/game/scene/gamedialog/allianceDialog/allianceSmallDialog"
        self.requireFlag = 1
    end
end

--显示加载游戏进度界面
function loginScene:showLoadGameProcess(percent)
    if G_isUseOldLogin() and tolua.cast(self.videoPlayer, "UIVideoPlayer") then
        self.videoPlayer:setPosition(0, 0)
        self.videoPlayer:setVisible(true)
        self.videoPlayer:play()
    end
    if percent >= 100 then
        self.loadResFlag = false
    else
        self.loadResFlag = true
    end
    if (self.luaBgSp == nil or tolua.cast(self.luaBgSp, "CCLayer") == nil) then
        if self.loginLayer then
            self.loginLayer:setVisible(false)
        end
        if self.accoutLayer then
            self.accoutLayer:setVisible(false)
        end
        local runningScene = CCDirector:sharedDirector():getRunningScene()
        local function nilFunc()
        end
        -- self.luaBgSp=LuaCCSprite:createWithFileName("scene/lodingxin.jpg",nilFunc)
        -- self.luaBgSp:setTouchPriority(-99)
        -- self.luaBgSp:setPosition(getCenterPoint(runningScene))
        self.luaBgSp = CCLayer:create()
        runningScene:addChild(self.luaBgSp, 999)
        --  local logoSpName= nil
        --  if platCfg.platCfgGameLogoSingleFile~=nil and platCfg.platCfgGameLogoSingleFile[G_curPlatName()]~=nil then
        --      logoSpName=platCfg.platCfgGameLogoSingleFile[G_curPlatName()][G_getCurChoseLanguage()]
        --  else
        --      logoSpName=platCfg.platCfgGameLogo[G_curPlatName()][G_getCurChoseLanguage()]
        --  end
        -- --飞流战地坦克特殊处理
        --  if(G_curPlatName()=="5" and G_Version<=11)then
        --      logoSpName="Logo_ky2.png"
        --  end
        --  local logoSp
        --  if platCfg.platCfgGameLogoSingleFile~=nil and platCfg.platCfgGameLogoSingleFile[G_curPlatName()]~=nil then
        --      logoSp=CCSprite:create("scene/logoImage/"..logoSpName)
        --  else
        --      logoSp=CCSprite:createWithSpriteFrameName(logoSpName~=nil and logoSpName or "Logo.png")
        --  end
        --  local pointCenter=getCenterPoint(self.luaBgSp)
        --  logoSp:setPosition(ccp(pointCenter.x,pointCenter.y+280))
        --  self.luaBgSp:addChild(logoSp)
        local loadingBg = CCSprite:create("public/tankLoadingBg.png")
        loadingBg:setPosition(ccp(G_VisibleSizeWidth / 2, 200))
        self.luaBgSp:addChild(loadingBg)
        self.luaProgress = CCProgressTimer:create(CCSprite:create("public/tankLoadingBar.png"))
        self.luaProgress:setType(kCCProgressTimerTypeBar)
        self.luaProgress:setMidpoint(ccp(0, 0))
        self.luaProgress:setBarChangeRate(ccp(1, 0))
        self.luaProgress:setPosition(ccp(G_VisibleSizeWidth / 2, 200))
        self.luaBgSp:addChild(self.luaProgress, 1)
        self.luaProgressLb = GetTTFLabel(getlocal(""), 25)
        self.luaProgressLb:setPosition(ccp(G_VisibleSizeWidth / 2, 150))
        self.luaBgSp:addChild(self.luaProgressLb)
        self.luaDescTb = {}
        local dt = 2.5
        if G_checkUseAuditUI() == true then
            dt = 1.5
            loadingBg:setVisible(false)
            self.luaProgress:setVisible(false)
        end
        for i = 1, 10 do
            table.insert(self.luaDescTb, getlocal("loading_lua_tip"..i))
        end
        local function updateWz()
            if self.luaProgressLb then
                if self.luaDescTb then
                    local num = #self.luaDescTb
                    if num >= 1 then
                        local index = math.random(1, #self.luaDescTb)
                        local str = self.luaDescTb[index]
                        self.luaProgressLb:setString(str)
                        table.remove(self.luaDescTb, index)
                    end
                end
            end
        end
        local funcall = CCCallFunc:create(updateWz)
        local delay = CCDelayTime:create(dt)
        local seq = CCSequence:createWithTwoActions(funcall, delay)
        local updateWzAc = CCRepeatForever:create(seq)
        self.luaProgressLb:runAction(updateWzAc)
    end
    if self and self.luaProgress and self.luaProgress.setPercentage then
        self.luaProgress:setPercentage(percent)
    end
end

--移除加载游戏进度界面
function loginScene:removeLoadGameProcess()
    if self.luaBgSp and tolua.cast(self.luaBgSp, "CCLayer") then
        self.luaBgSp:removeFromParentAndCleanup(true)
        self.luaBgSp = nil
    end
end

--重新回到登录界面
function loginScene:backLoginScene()
    self:removeLoadGameProcess()
    self:closeAccountLoginLayer()
    if self.loginLayer and tolua.cast(self.loginLayer, "CCLayer") then
        self.loginLayer:setVisible(true)
    end
end

function loginScene:showkakaoLoginScene()
    
    self.kakaoBgSp = CCSprite:create("scene/lodingxin.jpg");
    self.kakaoBgSp:setPosition(getCenterPoint(CCDirector:sharedDirector():getRunningScene()))
    self.loginLayer:addChild(self.kakaoBgSp, 1000)
    local logoSpName = nil
    if platCfg.platCfgGameLogoSingleFile ~= nil and platCfg.platCfgGameLogoSingleFile[G_curPlatName()] ~= nil then
        logoSpName = platCfg.platCfgGameLogoSingleFile[G_curPlatName()][G_getCurChoseLanguage()]
    else
        logoSpName = platCfg.platCfgGameLogo[G_curPlatName()][G_getCurChoseLanguage()]
    end
    local logoSp
    if platCfg.platCfgGameLogoSingleFile ~= nil and platCfg.platCfgGameLogoSingleFile[G_curPlatName()] ~= nil then
        logoSp = CCSprite:create("scene/logoImage/"..logoSpName)
    else
        logoSp = CCSprite:createWithSpriteFrameName(logoSpName ~= nil and logoSpName or "Logo.png")
    end
    local pointCenter = getCenterPoint(self.kakaoBgSp)
    logoSp:setPosition(ccp(pointCenter.x, pointCenter.y + 280))
    self.kakaoBgSp:addChild(logoSp)
    
    local function loginGamePlat()
        PlatformManage:shared():showLogin()
    end
    local showFlag = CCUserDefault:sharedUserDefault():getIntegerForKey("gameHasShown")
    if(G_kakaoLogout ~= true and showFlag ~= 0 and showFlag ~= nil)then
        loginGamePlat()
    else
        local showFlag = CCUserDefault:sharedUserDefault():getIntegerForKey("gameHasShown")
        if(showFlag == 0 or showFlag == nil)then
            local function removeListener()
                local temHight = 90
                local kakaoLoginBtn = LuaCCSprite:createWithFileName("zsyImage/loginBtn_kakao.png", loginGamePlat)
                kakaoLoginBtn:setPosition(ccp(G_VisibleSizeWidth / 2, 350 - temHight))
                kakaoLoginBtn:setTouchPriority(-2);
                self.kakaoBgSp:addChild(kakaoLoginBtn)
            end
            self.removeListener = removeListener
            eventDispatcher:addEventListener("kakao.terms.dialogClose", removeListener)
            self:showPlatSpecialPage()
            do return end
        end
    end
    local temHight = 90
    local kakaoLoginBtn = LuaCCSprite:createWithFileName("zsyImage/loginBtn_kakao.png", loginGamePlat)
    kakaoLoginBtn:setPosition(ccp(G_VisibleSizeWidth / 2, 350 - temHight))
    kakaoLoginBtn:setTouchPriority(-2);
    self.kakaoBgSp:addChild(kakaoLoginBtn)
end

function loginScene:removekakaoLoginScene()
    eventDispatcher:removeEventListener("kakao.terms.dialogClose", self.removeListener)
    if(self.kakaoBgSp and self.kakaoBgSp:getParent())then
        self.loginLayer:removeChild(self.kakaoBgSp, true)
    end
end

function loginScene:showHexieBg(index)
    if(self.hexieBgShowed == false and self.loginLayer and self.loginLayer.addChild)then
        if(loginScene:checkPlatShowHexieBg())then
            local hexieBg = LuaCCScale9Sprite:createWithSpriteFrameName("BlackBg.png", CCRect(4, 4, 2, 2), function (...)end)
            hexieBg:setTouchPriority(-99)
            hexieBg:setContentSize(CCSizeMake(G_VisibleSizeWidth, G_VisibleSizeHeight))
            hexieBg:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2)
            self.loginLayer:addChild(hexieBg, 99)
            local contentStr = "抵制不良游戏，拒绝盗版游戏。\n注意自我保护，谨防受骗上当。\n适度游戏益脑，沉迷游戏伤身。\n合理安排时间，享受健康生活。"
            local contentLb = GetTTFLabelWrap(contentStr, 28, CCSize(G_VisibleSizeWidth - 60, 0), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
            contentLb:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2)
            hexieBg:addChild(contentLb)
            local titleStr = "健康游戏忠告"
            local titleLb = GetTTFLabel(titleStr, 32)
            titleLb:setPosition(G_VisibleSizeWidth / 2, G_VisibleSizeHeight / 2 + contentLb:getContentSize().height / 2 + 25)
            hexieBg:addChild(titleLb)
            local isbnLb
            if G_isApplyVersion() == false then
                local isbnStr
                if(G_curPlatName() == "androidewan")then
                    isbnStr = "文网游备字：（2016）M_2122号\n新广出审：新广出审[2017]3353 号\n出版物号：ISBN 978-7-7979-6873-7\n著作权人：上海益玩网络科技有限公司\n出版单位：天津电子出版社有限公司"
                else
                    isbnStr = "游戏运营许可\n著作权人：雷尚（北京）科技有限公司\n出版服务单位：华东理工大学电子音像出版社\n批准文号：新广出审【2015】748号\n出版物号：978-7-89390-057-0"
                end
                isbnLb = GetTTFLabelWrap(isbnStr, 28, CCSizeMake(G_VisibleSizeWidth - 100, 0), kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter)
                isbnLb:setAnchorPoint(ccp(0, 0.5))
                isbnLb:setPosition(50, G_VisibleSizeHeight / 2)
                hexieBg:addChild(isbnLb)
                isbnLb:setOpacity(0)
            end
            local action1 = CCDelayTime:create(2)
            local function fadeFunc1()
                contentLb:runAction(CCFadeOut:create(0.5))
                titleLb:runAction(CCFadeOut:create(0.5))
            end
            local callFunc1 = CCCallFunc:create(fadeFunc1)
            local action2 = CCDelayTime:create(0.4)
            local function fadeFunc2()
                if isbnLb then
                    isbnLb:runAction(CCFadeIn:create(0.5))
                end
            end
            local callFunc2 = CCCallFunc:create(fadeFunc2)
            local action3 = CCDelayTime:create(3)
            local function removeFunc()
                if(hexieBg and hexieBg.removeFromParentAndCleanup)then
                    hexieBg:removeFromParentAndCleanup(true)
                end
                self.hexieBgPlayEnd = true
                self:playLoadingEffect()
            end
            local callFunc3 = CCCallFunc:create(removeFunc)
            local acArr = CCArray:create()
            acArr:addObject(action1)
            acArr:addObject(callFunc1)
            if G_isApplyVersion() == false then
                acArr:addObject(action2)
                acArr:addObject(callFunc2)
                acArr:addObject(action3)
            end
            acArr:addObject(callFunc3)
            hexieBg:runAction(CCSequence:create(acArr))
            self.hexieBgShowed = true
        else
            self:playLoadingEffect()
        end
    else
        self:playLoadingEffect()
    end
end

function loginScene:checkPlatShowHexieBg()
    if G_curPlatName() == "0" then
        do return false end
    end
    if(G_curPlatName() == "androidhuli" and G_Version == 10)then
        return false
    elseif(G_isChina())then
        return true
    else
        return false
    end
end

function loginScene:playLoadingEffect()
    self:showMigrationNotice()
    local newLoadingDisabledCfg = platCfg.platCfgNewLoadingDisabled[G_curPlatName()] --不能使用新的loading效果的配置
    local lzorder = 10000
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)
    -- 上下层背景板 出图以后注释掉
    --local upBg = "scene/gameBorder1.png"
    --local downBg = "scene/gameBorder2.png"
    local loadingBgPng = "scene/loading_new.jpg"
    if G_getIphoneType() == G_iphoneX then
        loadingBgPng = "scene/loading_newX.jpg"
    end
    if newLoadingDisabledCfg or G_isUseOldLogin() then
        loadingBgPng = "scene/lodingxin.jpg"
    end
    --local upBgSp = CCSprite:create(upBg)
    --local downBgSp = CCSprite:create(downBg)
    local loadingSp = CCSprite:create(loadingBgPng)
    local centerpoint = getCenterPoint(CCDirector:sharedDirector():getRunningScene())
    --centerpoint.y = centerpoint.y - 40
    loadingSp:setPosition(centerpoint)
    --local ypos1 = loadingSp:getPositionY() + loadingSp:getContentSize().height/2
    --local ypos2 = loadingSp:getPositionY() - loadingSp:getContentSize().height/2
    --upBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight - ypos1))
    --upBgSp:setPosition(G_VisibleSizeWidth/2,(G_VisibleSizeHeight - ypos1)/2 + ypos1)
    --downBgSp:setContentSize(CCSizeMake(G_VisibleSizeWidth,G_VisibleSizeHeight - loadingSp:getContentSize().height - upBgSp:getContentSize().height))
    --downBgSp:setPosition(G_VisibleSizeWidth/2,ypos2 - (G_VisibleSizeHeight - loadingSp:getContentSize().height - upBgSp:getContentSize().height)/2)
    self.effectLayer:addChild(loadingSp, lzorder)
    --self.effectLayer:addChild(upBgSp,lzorder)
    --self.effectLayer:addChild(downBgSp,lzorder)
    CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    CCTexture2D:setPvrDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    
    local logoSpName = nil
    if platCfg.platCfgGameLogoSingleFile ~= nil and platCfg.platCfgGameLogoSingleFile[G_curPlatName()] ~= nil then
        logoSpName = platCfg.platCfgGameLogoSingleFile[G_curPlatName()][G_getCurChoseLanguage()]
    else
        logoSpName = platCfg.platCfgGameLogo[G_curPlatName()][G_getCurChoseLanguage()]
    end
    if platCfg.platCfgNewLogoEffect[logoSpName] and newLoadingDisabledCfg == nil then
        logoSpName = "Logo_zh.png"
    end
    local logoSp
    if platCfg.platCfgGameLogoSingleFile ~= nil and platCfg.platCfgGameLogoSingleFile[G_curPlatName()] ~= nil then
        logoSp = CCSprite:create("scene/logoImage/"..logoSpName)
    else
        logoSp = CCSprite:createWithSpriteFrameName(logoSpName ~= nil and logoSpName or "Logo.png")
    end
    local addH = 350
    if G_isIphone5() then
        addH = 400
    end
    local pointCenter = getCenterPoint(self.effectLayer)
    logoSp:setPosition(ccp(pointCenter.x, pointCenter.y + addH))
    -- logoSp:setScale(0.9)
    self.effectLayer:addChild(logoSp, lzorder + 6)
    self.logoSp = logoSp
    self:showAni(logoSpName)
    
    if newLoadingDisabledCfg or G_isUseOldLogin() then --有些平台不能使用新的loading效果
        do return end
    end
    
    local actionLayer = CCNode:create()
    actionLayer:setAnchorPoint(ccp(0.5, 0.5))
    actionLayer:setContentSize(loadingSp:getContentSize())
    actionLayer:setPosition(loadingSp:getPosition())
    self.effectLayer:addChild(actionLayer, lzorder + 3)
    
    local addH = -120
    if G_getIphoneType() == G_iphoneX then
        addH = -58
    end
    local function playParticleFire(plist, pos, zorder, scale, unmoveFlag, angle)
        local fire = CCParticleSystemQuad:create(plist)
        if fire then
            fire:setAutoRemoveOnFinish(true)
            fire:setPositionType(kCCPositionTypeFree)
            fire:setPosition(pos)
            fire:setScale(scale or 1)
            fire:setRotation(angle or 0)
            if zorder == nil then
                zorder = 1
            end
            if unmoveFlag or unmoveFlag == true then
                self.effectLayer:addChild(fire, zorder)
            else
                actionLayer:addChild(fire, zorder)
            end
        end
        return fire
    end
    
    local lightSpTb = {}
    local bodySp = CCSprite:createWithSpriteFrameName("logo_tankbody.png")
    bodySp:setPosition(320, 599.5 + addH)
    actionLayer:addChild(bodySp, 3)
    local lightSp = CCSprite:createWithSpriteFrameName("logo_tanklight.png")
    lightSp:setPosition(240, 655 + addH)
    lightSp:setOpacity(0)
    actionLayer:addChild(lightSp, 5)
    lightSpTb[1] = lightSp
    local lightSp2 = CCSprite:createWithSpriteFrameName("logo_tanklight2.png")
    lightSp2:setPosition(364, 604 + addH)
    lightSp2:setOpacity(0)
    actionLayer:addChild(lightSp2, 5)
    lightSpTb[2] = lightSp2
    
    local gunSp = CCSprite:createWithSpriteFrameName("logo_tankgun.png")
    gunSp:setPosition(453.5, 855.5 + addH)
    actionLayer:addChild(gunSp, 1)
    
    local burnCfg = {
        {"flake.plist", posCfg = {ccp(280, 800), ccp(100, 400), ccp(200, 380), ccp(270, 380), ccp(320, 0), ccp(550, 0)}, zorder = 5, scale = {2, 2, 1, 1, 2, 2}},
        {"burn.plist", posCfg = {ccp(100, 250), ccp(200, 380), ccp(270, 380), ccp(600, 0)}, zorder = 3, scale = {2, 2, 2, 3}},
        -- {"smog.plist",posCfg={ccp(700,500),ccp(700,500),ccp(240,500),ccp(400,500)},zorder=lzorder+1,scale={3,3,3,3},unmove=true},
        {"smog.plist", posCfg = {ccp(600, 300), ccp(680, 300), ccp(240, 300), ccp(400, 300)}, zorder = lzorder + 1, scale = {3, 3, 3, 3}, unmove = true},
        
    }
    for k, cfg in pairs(burnCfg) do
        for idx, pos in pairs(cfg.posCfg) do
            if k == 3 and (idx == 2 or idx == 4) then
                local smogNode = CCNode:create()
                actionLayer:addChild(smogNode)
                local arr = CCArray:create()
                local function showSmog()
                    playParticleFire("scene/loadingEffect/"..cfg[1], ccp(pos.x, pos.y + addH), cfg.zorder, cfg.scale[idx], cfg.unmove)
                end
                local delay = CCDelayTime:create(1.5)
                local funcall = CCCallFunc:create(showSmog)
                arr:addObject(delay)
                arr:addObject(funcall)
                local smogSeq = CCSequence:create(arr)
                smogNode:runAction(smogSeq)
            else
                playParticleFire("scene/loadingEffect/"..cfg[1], ccp(pos.x, pos.y + addH), cfg.zorder, cfg.scale[idx], cfg.unmove)
            end
        end
    end
    
    local function playFireLight()
        for i = 1, 2 do
            local fireArr = CCArray:create()
            local fadeTo = CCFadeTo:create(0.1, 255)
            local delay = CCDelayTime:create(0.1)
            local fadeTo2 = CCFadeTo:create(0.1, 0)
            fireArr:addObject(fadeTo)
            fireArr:addObject(delay)
            fireArr:addObject(fadeTo2)
            local fireSeq = CCSequence:create(fireArr)
            local lightSp = lightSpTb[i]
            if lightSp then
                lightSp:runAction(fireSeq)
            end
        end
        local fireLight = CCSprite:createWithSpriteFrameName("logo_tankfire.png")
        fireLight:setPosition(ccp(560, 900))
        fireLight:setOpacity(0)
        fireLight:setScale(7)
        loadingSp:addChild(fireLight, 4)
        local arr = CCArray:create()
        local fadeTo = CCFadeTo:create(0.1, 255)
        local delay = CCDelayTime:create(0.1)
        local fadeTo2 = CCFadeTo:create(0.1, 0)
        local blink = CCBlink:create(1, 1)
        local function removeSelf()
            fireLight:removeFromParentAndCleanup(true)
            fireLight = nil
        end
        local funcall = CCCallFunc:create(removeSelf)
        arr:addObject(fadeTo)
        arr:addObject(delay)
        arr:addObject(fadeTo2)
        arr:addObject(funcall)
        local fireSeq = CCSequence:create(arr)
        fireLight:runAction(fireSeq)
        
        local burnSp = CCSprite:createWithSpriteFrameName("logo_tankfire2.png")
        burnSp:setPosition(110, 190)
        gunSp:addChild(burnSp, 5)
        local burnArr = CCArray:create()
        local function removeBurnSp()
            burnSp:removeFromParentAndCleanup(true)
            burnSp = nil
        end
        local delay = CCDelayTime:create(0.5)
        burnArr:addObject(delay)
        local fadeIn = CCFadeTo:create(0.5, 0)
        burnArr:addObject(fadeIn)
        local funcall = CCCallFunc:create(removeBurnSp)
        burnArr:addObject(funcall)
        local burnSeq = CCSequence:create(burnArr)
        burnSp:runAction(burnSeq)
    end
    
    local function playShake()
        local shakeArr = CCArray:create()
        local shakeArr2 = CCArray:create()
        for i = 1, 5 do
            local dd = deviceHelper:getRandom()
            local rndx = 15 - (math.random(1, 100) / 100) * 30 + G_VisibleSizeWidth / 2
            local rndy = 15 - (math.random(1, 100) / 100) * 30 + G_VisibleSizeHeight / 2
            -- local rndx=15-(deviceHelper:getRandom()/100)*30+G_VisibleSizeWidth/2
            -- local rndy=15-(deviceHelper:getRandom()/100)*30+G_VisibleSizeHeight/2
            local moveTo = CCMoveTo:create(0.02, ccp(rndx, rndy))
            shakeArr:addObject(moveTo)
            local moveTo2 = CCMoveTo:create(0.02, ccp(rndx, rndy))
            shakeArr2:addObject(moveTo2)
        end
        local function resetPos()
            loadingSp:setPosition(getCenterPoint(self.effectLayer))
        end
        local funcall = CCCallFunc:create(resetPos)
        shakeArr:addObject(funcall)
        local shakeSeq = CCSequence:create(shakeArr)
        loadingSp:runAction(shakeSeq)
        local function resetPos2()
            actionLayer:setPosition(getCenterPoint(self.effectLayer))
        end
        local funcall2 = CCCallFunc:create(resetPos2)
        shakeArr2:addObject(funcall2)
        local shakeSeq2 = CCSequence:create(shakeArr2)
        actionLayer:runAction(shakeSeq2)
    end
    
    local function play()
        gunSp:stopAllActions()
        local gunArr = CCArray:create()
        local moveTo = CCMoveTo:create(0.05, ccp(434.5, 818.5 + addH))
        local function playFire()
            playFireLight()
            playShake()
            playParticleFire("scene/loadingEffect/fire.plist", ccp(520, 950 + addH), lzorder + 5, 1.3, true)
            PlayEffect(audioCfg.tank_2)
        end
        local funcall = CCCallFunc:create(playFire)
        local back = CCMoveTo:create(0.5, ccp(453.5, 855.5 + addH))
        gunArr:addObject(moveTo)
        gunArr:addObject(funcall)
        gunArr:addObject(back)
        local seq = CCSequence:create(gunArr)
        gunSp:runAction(seq)
    end
    
    local function playLoadEffect()
        play()
    end
    local arr = CCArray:create()
    local funcall = CCCallFunc:create(playLoadEffect)
    arr:addObject(funcall)
    local delay = CCDelayTime:create(6)
    arr:addObject(delay)
    local seq = CCSequence:create(arr)
    local repeatForever = CCRepeatForever:create(seq)
    self.effectLayer:runAction(repeatForever)
end

function loginScene:playLogoEffect()
    if G_isUseOldLogin() then
        do return end
    end
    if self.logoSp == nil then
        do return end
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/logoImage/logoEffect_zh.plist")--logo效果
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/logoImage/logoEffect2_zh.plist")--logo效果
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("scene/logoImage/logoEffect3_zh.plist")--logo效果
    local function playFrameAni(pngPrefix, sidx, eidx, delayPerTime, delayTime, callback, repeatDelayTime, pos)
        local function realPlay()
            local aniSp = CCSprite:createWithSpriteFrameName(pngPrefix.."_"..sidx..".png")
            local aniArr = CCArray:create()
            for kk = sidx, eidx do
                local nameStr = pngPrefix.."_"..kk..".png"
                local frame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(nameStr)
                aniArr:addObject(frame)
            end
            local animation = CCAnimation:createWithSpriteFrames(aniArr)
            animation:setDelayPerUnit(delayPerTime)
            local animate = CCAnimate:create(animation)
            if pngPrefix ~= "shan" then
                aniSp:setScale(1.25)
            end
            aniSp:setAnchorPoint(ccp(0.5, 0.5))
            aniSp:setPosition(ccp(self.logoSp:getContentSize().width / 2, self.logoSp:getContentSize().height / 2))
            self.logoSp:addChild(aniSp)
            if pos then
                aniSp:setPosition(pos)
            end
            local blendFunc = ccBlendFunc:new()
            -- blendFunc.src=GL_SRC_ALPHA
            blendFunc.src = GL_ONE
            blendFunc.dst = GL_ONE
            aniSp:setBlendFunc(blendFunc)
            
            local acArr = CCArray:create()
            local function opacityFull()
                aniSp:setOpacity(255)
            end
            local opacityFunc = CCCallFunc:create(opacityFull)
            acArr:addObject(opacityFunc)
            acArr:addObject(animate)
            local function opacityEmpty()
                local fadeTo = CCFadeOut:create(0.4)
                local function removeSp()
                    aniSp:removeFromParentAndCleanup(true)
                    aniSp = nil
                end
                local removeCall = CCCallFunc:create(removeSp)
                local seq = CCSequence:createWithTwoActions(fadeTo, removeCall)
                aniSp:runAction(seq)
            end
            local opacityFunc2 = CCCallFunc:create(opacityEmpty)
            acArr:addObject(opacityFunc2)
            if callback then
                local func = CCCallFunc:create(callback)
                acArr:addObject(func)
            end
            if repeatDelayTime then
                local delay = CCDelayTime:create(repeatDelayTime)
                acArr:addObject(delay)
                local seq = CCSequence:create(acArr)
                local repeatAc = CCRepeatForever:create(seq)
                aniSp:runAction(repeatAc)
            else
                local seq = CCSequence:create(acArr)
                aniSp:runAction(seq)
            end
        end
        local acArr = CCArray:create()
        local delayTime = delayTime or 0
        local delay = CCDelayTime:create(delayTime)
        local playfunc = CCCallFunc:create(realPlay)
        acArr:addObject(delay)
        acArr:addObject(playfunc)
        local seq = CCSequence:create(acArr)
        self.logoSp:runAction(seq)
    end
    local function playLogoBgEffect(delayTime)
        local logoBg = CCSprite:createWithSpriteFrameName("logoLightBg.png")
        logoBg:setScale(1.2)
        logoBg:setOpacity(0)
        logoBg:setPosition(self.logoSp:getPosition())
        self.effectLayer:addChild(logoBg, 10000)
        local delayTime = delayTime or 0
        local delay = CCDelayTime:create(delayTime)
        local fadeOut = CCFadeOut:create(0.2)
        local fadeIn = CCFadeIn:create(0.2)
        local function removeSp()
            logoBg:removeFromParentAndCleanup(true)
            logoBg = nil
        end
        local removeCall = CCCallFunc:create(removeSp)
        local acArr = CCArray:create()
        acArr:addObject(delay)
        acArr:addObject(fadeIn)
        acArr:addObject(fadeOut)
        acArr:addObject(removeCall)
        local seq = CCSequence:create(acArr)
        logoBg:runAction(seq)
    end
    
    local function juqiCallBack()
        playFrameAni("lizi", 0, 11, 0.085)
        playFrameAni("shan", 1, 5, 0.07)
        playFrameAni("guangLight", 1, 6, 0.08, 0.3)
        
        local acArr = CCArray:create()
        local function playGuang()
            playFrameAni("guangLight", 1, 6, 0.08)
        end
        local function playShan()
            playFrameAni("shan", 1, 5, 0.07)
        end
        local delay = CCDelayTime:create(3)
        acArr:addObject(delay)
        local shanFunc = CCCallFunc:create(playShan)
        acArr:addObject(shanFunc)
        for i = 1, 2 do
            local time = 0
            if i == 2 then
                time = 0.48
            end
            local delay = CCDelayTime:create(time)
            acArr:addObject(delay)
            local guangFunc = CCCallFunc:create(playGuang)
            acArr:addObject(guangFunc)
        end
        local seq = CCSequence:create(acArr)
        local repeatAc = CCRepeatForever:create(seq)
        self.logoSp:runAction(repeatAc)
        playLogoBgEffect()
    end
    local juqiArr = CCArray:create()
    local delay = CCDelayTime:create(0.2)
    juqiArr:addObject(delay)
    local juqiCall = CCCallFunc:create(juqiCallBack)
    juqiArr:addObject(juqiCall)
    local juqiAc = CCSequence:create(juqiArr)
    self.logoSp:runAction(juqiAc)
    -- playFrameAni(pngPrefix,sidx,eidx,delayPerTime,delayTime,callback,repeatDelayTime,pos)
    local pos = ccp(self.logoSp:getContentSize().width / 2, self.logoSp:getContentSize().height / 2 - 16)
    playFrameAni("juqi", 1, 5, 0.085, nil, nil, nil, pos)
    
    local lightSp = CCSprite:createWithSpriteFrameName("logoLight.png")
    lightSp:setPosition(ccp(self.logoSp:getContentSize().width / 2, self.logoSp:getContentSize().height / 2 - 20))
    lightSp:setScale(0)
    self.logoSp:addChild(lightSp)
    local acArr = CCArray:create()
    local scaleTo = CCScaleTo:create(0.3, 1)
    acArr:addObject(scaleTo)
    local seq = CCSequence:create(acArr)
    lightSp:runAction(seq)
end

--显示迁移账号的公告
function loginScene:showMigrationNotice()
    --飞流正版巨兽崛起因sdk问题暂时登录不上，先给玩家弹出公告
    if G_isForceMigration() == true then
        require "luascript/script/componet/smallDialog2"
        require "luascript/script/game/gamemodel/migration/migrationVoApi"
        local function confirm()
            G_getServerCfgFromHttp(true)
            local function showMigrationAccountDialog(codeList)
                if codeList and SizeOfTable(codeList) > 0 then
                    local migrationAccountDialog = G_requireLua("game/scene/gamedialog/migrationAccountDialog")
                    migrationAccountDialog:showAccountDialog(codeList, 12)
                end
            end
            migrationVoApi:getMigrationCodeList(showMigrationAccountDialog)
        end
        local textTb = {}
        local flag, mtype = G_isForceMigration()
        if mtype == 2 then
            textTb = {
                "尊敬的指挥官",
                "由于账号系统无法登录，总部为指挥官提供角色转移服务。",
                "您现在可以查看到您手机上登录过角色的迁移码，选择您想要迁移的角色，请您自行记录迁移码，并且下载新包进行迁移。",
                "请您注册新的账号和密码，此账号系统与之前账号系统不互通，进入游戏后跳过新手引导，点击设置按钮，在“迁移码”按钮中输入您的迁移码，当前角色会被覆盖，角色完成迁移。",
                "迁移码只能对应原来的服务器进行迁移，例如原角色在第10服务器，那么只能进入第10服务器进行迁移，进入其他服务器会迁移失败；",
                "注意事项：",
                "迁移码只能使用一次，一旦使用完毕，角色将无法再次迁移；",
                "在角色迁移前请查看好角色信息，角色被覆盖后无法找回；",
                "不同服务器的角色可以迁移到1个账号内，如果同一个服务器存在多个账号，请您多注册一些账号进行迁移；",
                "如果您遇到任何问题，您可以在游戏设置中的“联系我们”功能，客服MM竭诚为您服务；",
                "您可以在游戏设置中进行修改密码的操作，总部建议您不要进行账号共享行为，以免账号被盗，",
                "如果您手机中没有显示角色迁移码，说明您已经删除过游戏客户端，遇到此问题，您可以进入游戏联系客服为您处理。",
            }
        else
            textTb = {
                "尊敬的指挥官",
                "由于账号系统出现故障，总部为指挥官提供角色转移服务。",
                "您现在可以查看到您手机上登录过角色的迁移码，选择您想要迁移的角色，复制迁移码，每次只能复制一条迁移码。迁移码只能对应原来的服务器进行迁移，例如原角色在第10服务器，那么只能进入第10服务器进行迁移，进入其他服务器会迁移失败；",
                "请您注册新的账号和密码，此账号系统与之前账号系统不互通，进入游戏后跳过新手引导，点击设置按钮，在“迁移码”按钮中粘贴您刚刚复制的角色迁移码，当前角色会被覆盖，角色完成迁移。",
                "注意事项：",
                "迁移码只能使用一次，一旦使用完毕，角色将无法再次迁移；",
                "在角色迁移前请查看好角色信息，角色被覆盖后无法找回；",
                "不同服务器的角色可以迁移到1个账号内，如果同一个服务器存在多个账号，请您多注册一些账号进行迁移；",
                "如果您遇到任何问题，您可以在游戏设置中的“联系我们”功能，客服MM竭诚为您服务；",
                "您可以在游戏设置中进行修改密码的操作，总部建议您不要进行账号共享行为，以免账号被盗，",
                "如果您手机中没有显示角色迁移码，说明您已经删除过游戏客户端，遇到此问题，您可以进入游戏联系客服为您处理。",
            }
        end
        
        local titleStr = getlocal("note")
        require "luascript/script/game/scene/gamedialog/tipShowSmallDialog"
        tipShowSmallDialog:showStrInfo(12, true, true, confirm, titleStr, textTb, nil, 25)
        -- smallDialog:showSure("PanelHeaderPopup.png",CCSizeMake(550,400),CCRect(0, 0, 400, 350),CCRect(168, 86, 10, 10),getlocal("note"),"游戏目前无法正常登录，请您不要删除游戏客户端，正在紧急修复中。",nil,12,nil,confirm)
    end
end
