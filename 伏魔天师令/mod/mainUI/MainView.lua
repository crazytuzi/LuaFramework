local MainView=classGc(view,function(self)
    -- _G.GOpenProxy:addOpenEffectSysId(40900)
	self.m_mediator=require("mod.mainUI.MainViewMediator")()
	self.m_mediator:setView(self)

    self.m_winSize=cc.Director:getInstance():getWinSize()

    self.m_myProperty=_G.GPropertyProxy:getMainPlay()
    if _G.GLayerManager==nil then
        _G.GLayerManager=require("mod.mainUI.LayerManager")()
    end
    
    self.m_layerManager=_G.GLayerManager
    -- self.m_layerManager:chuangeSubView()
    self.m_subViewArray=self.m_layerManager.m_subViewArray
    self.m_isSubViewShowing=false
    self.m_iconCount=0
    self.m_iconArray={}
end)

function MainView.create(self)
	self.m_rootNode=cc.Node:create()
	self:init()
	return self.m_rootNode
end

function MainView.init(self)
	self:initView()
	self:showIconView()
	self:delayToDo()
end

function MainView.hide(self)
    self.m_rootNode:setVisible(false)
    _G.g_Stage.m_joyStick:setVisible(false)
end
function MainView.show(self)
    self.m_rootNode:setVisible(true)
    _G.g_Stage.m_joyStick:setVisible(true)
end

function MainView.initView(self)
    local tag_gold=1
    local tag_tili=2
    local tag_rmb =3
    local tag_gm  =4
    local tag_ls  =5
    local tag_head=6
    local function c(sender,eventType)
        if eventType == ccui.TouchEventType.ended then
            local tag=sender:getTag()
            print("mainUi add btn click!!--->",tag)
            if tag==tag_gold then
                _G.GLayerManager:openLayer(Cfg.UI_CCopyMapLayer)
            elseif tag==tag_tili then
                local msg=REQ_ROLE_ASK_BUY_ENERGY()
                _G.Network:send( msg)
            elseif tag==tag_rmb then
                
            elseif tag==tag_gm then
                local gmview=require("mod.support.UIGM")
                gmview:show()
            elseif tag==tag_ls then
                _G.GOpenProxy:addTextOpenData(sender)
            elseif tag==tag_head then
                self:autoShowUI()

                if self.m_headguideNode then
                    local nTag=self.m_headguideNode:getTag()
                    self.m_headguideNode:removeFromParent(true)
                    self.m_headguideNode=nil

                    if nTag==1 then
                        self:__createHeadGuide(2)
                    end
                -- else
                --     self:__createHeadGuide(1)
                end

                -- local ssss=_G.GOpenProxy:getSysSignArray()
                -- for k,v in pairs(ssss) do
                --     print(k,v)
                -- end

                -- for i=1,10 do
                --     local tempSpine=_G.SpineManager.createSpine("spine/spineboy",0.5)
                --     tempSpine:setAnimation(0,"idle",true)
                --     tempSpine:setPosition(math.random(50,1500),math.random(50,300))
                --     self.m_rootNode:addChild(tempSpine)
                -- end

                -- _G.g_BattleView:addBossWaring(self.__stage.m_lpUIContainer)
                -- local curVolume=cc.SimpleAudioEngine:getInstance():getEffectsVolume()
                -- print("getEffectsVolume==================>>>>>>>>>",curVolume)
                -- cc.SimpleAudioEngine:getInstance():setEffectsVolume(curVolume+0.1)

                -- if self.m_webView~=nil then
                --     self.m_webView:removeFromParent(true)
                --     self.m_webView=nil
                -- else
                --     if gc.CWebView==nil then
                --         local command=CErrorBoxCommand("WebView 将在下版本加入")
                --         _G.controller:sendCommand(command)
                --         return
                --     end

                --     self.m_webView=gc.CWebView:create()
                --     self.m_webView:setPosition(self.m_winSize.width*0.5,self.m_winSize.height*0.5)
                --     self.m_webView:setContentSize(cc.size(self.m_winSize.width*0.8,self.m_winSize.height*0.8))
                --     self.m_webView:loadURL(_G.SysInfo:urlUpdateLogs()) -- "http://www.baidu.com"
                --     self.m_webView:setScalesPageToFit(true);
                --     self.m_rootNode:addChild(self.m_webView,200)

                --     local function callBack(eventType)
                --         if eventType==_G.Const.sWebViewStartLoading then
                --             print("FFFFF======>>>> 开始加载")
                --         elseif eventType==_G.Const.sWebViewFinishLoading then
                --             print("FFFFF======>>>> 加载完成")
                --         elseif eventType==_G.Const.sWebViewFailLoading then
                --             print("FFFFF======>>>> 加载出错")
                --         end
                --     end
                --     local handler=gc.ScriptHandlerControl:create(callBack)
                --     self.m_webView:registerScriptHandler(handler)
                -- end
                
                -- if not self.m_EEEE then
                --     local invBuff= _G.GBuffManager:getBuffNewObject(1915, 0)
                --     _G.g_Stage:getMainPlayer():addBuff(invBuff)
                --     self.m_EEEE = true
                -- else 
                --     _G.g_Stage:getMainPlayer():removeBuff(_G.Const.CONST_BATTLE_BUFF_BURN)
                --     self.m_EEEE = nil
                -- end

                -- local p1=cc.ParticleSystemQuad:create("particle/btn_effect.plist")
                -- p1:setPosition(0,0)
                -- _G.g_Stage:getMainPlayer().m_lpMovieClip:addChildForBorn("bone21",p1)

                -- self:roleLevelUp()
                -- _G.ShaderUtil:setPoisoningShader(_G.g_Stage:getMainPlayer().m_lpMovieClip)
                -- self:slowMotion()
                
                -- _G.g_Stage:slowMotion()
                -- _G.g_Stage.m_slowMotion=nil
                -- _G.g_Stage:slowMotionDead()

                -- for uid,v in pairs(_G.CharacterManager.m_lpPlayerArray) do
                --     self:ortherPlayerLevelUp({uid=uid})
                -- end

                -- 美人跟随
                -- self.m_AAAAAAA=self.m_AAAAAAA or 1
                -- if self.m_AAAAAAA==1 then
                --     _G.g_Stage:getMainPlayer():setPetId(50101)
                --     self.m_AAAAAAA=0
                -- else
                --     _G.g_Stage:getMainPlayer():setPetId(0)
                --     self.m_AAAAAAA=1
                -- end

                -- gc.TcpClient:getInstance():close()

                -- local aaass=_G.SpineManager.createSpine("spineboy",1)
                -- aaass:setPosition(self.m_winSize.width*0.5,100)
                -- aaass:setAnimation(0, "walk", true)
                -- self.m_rootNode:addChild(aaass)
                -- grayNode(aaass)

                -- self.m_AAAAAAA=self.m_AAAAAAA or 1
                -- if self.m_AAAAAAA==1 then
                --     self.m_AAAAAAA=0
                --     _G.ShaderUtil:setPoisoningShader(_G.g_Stage:getMainPlayer().m_lpMovieClip)
                --     -- _G.ShaderUtil:setBurnShader(_G.g_Stage:getMainPlayer().m_lpMovieClip)
                --     -- _G.ShaderUtil:setFreezeShader(_G.g_Stage:getMainPlayer().m_lpMovieClip)
                -- else
                --     self.m_AAAAAAA=1
                --     _G.ShaderUtil:resetSpineShader(_G.g_Stage:getMainPlayer().m_lpMovieClip)
                -- end

                -- 副本胜利
                -- _G.g_Stage:setOpenId(7)
                -- local msg={}
                -- msg.copy_id=20301
                -- msg.eva=3
                -- msg.condition=1
                -- msg.condition2=1
                -- msg.exp=200
                -- msg.gold=22222
                -- msg.data={{goods_id=2001,count=2},{goods_id=2007,count=3}}
                -- msg.flag=0
                -- msg.copy_next=0 --10131
                -- local view=require("mod.map.UICopyPass")(msg)
                -- self.m_rootNode:addChild(view:create())

                -- 副本失败
                -- local _ackMsg = {res=0}
                -- local view=require("mod.map.UIBattleResult")(_ackMsg)
                -- self.m_rootNode:addChild(view:create())

                -- 升级特效
                -- self:roleLevelUp(10)

                -- 功能开放
                -- self:addSysOpenEffectData(20130)
                -- self:addSysOpenEffectData(20400)
                -- _G.GOpenProxy:addOpenEffectSysId(40900)

                -- local curPower=self.m_myProperty:getAllsPower()
                -- self.m_myProperty:setAllsPower(math.floor(curPower+11111))
                -- self:updatePowerNum()

                -- local command  =CGuideTouchCammand(CGuideTouchCammand.TASK_RECEIVE)
                -- command.touchId=101720
                -- _G.controller:sendCommand(command)

                -- local curTimes=_G.TimeUtil:getNowSeconds()
                -- for i=1,10 do
                --     local msg={uid=100+i,name="计算的"..i,time=curTimes-i*2}
                --     _G.GSystemProxy:addPKInvite(msg)
                -- end

                -- if self.m_tttttt1~=nil then
                --     self.m_tttttt1:removeFromParent(true)
                --     self.m_tttttt1=nil
                -- end
                -- if self.m_tttttt2~=nil then
                --     self.m_tttttt2:removeFromParent(true)
                --     self.m_tttttt2=nil
                -- end
                -- self.m_tttttt1=_G.Util:createBorderLabel("555468*912250",22)
                -- self.m_tttttt1:setPosition(self.m_winSize.width*0.5,350)
                -- self.m_rootNode:addChild(self.m_tttttt1,100)
                -- self.m_tttttt2=cc.Label:createWithTTF("555468*912250",_G.FontName.Heiti,22)
                -- self.m_tttttt2:setPosition(self.m_winSize.width*0.5,320)
                -- self.m_rootNode:addChild(self.m_tttttt2,100)

                -- local nAc=cc.MoveBy:create(1,cc.p(400,0))
                -- nAc=cc.Sequence:create(nAc,nAc:reverse())
                -- nAc=cc.RepeatForever:create(nAc)
                -- _G.g_Stage.m_lpContainer:runAction(nAc)

                -- local p1 = cc.ParticleSystemQuad:create("particle/sys_open_absorb.plist")
                -- p1:setPosition(self.m_winSize.width*0.5,self.m_winSize.height*0.5)
                -- self.m_rootNode:addChild(p1)

                -- local effectVolume=cc.SimpleAudioEngine:getInstance():getEffectsVolume()
                -- print("CCCCCCCCCCCCCCCCCCCCCCCC>>>>>>>>",effectVolume)
                -- cc.SimpleAudioEngine:getInstance():setEffectsVolume(0.2)
                -- _G.Util:playAudioEffect("ui_task_get")
            end
        end
    end

    local name    =self.m_myProperty:getName() or "?"
    local lv      =self.m_myProperty:getLv()
    local vip     =self.m_myProperty:getVipLv()
    local pro     =self.m_myProperty:getPro() or 1
    local gold,yuanBao,xianYu=self:getCurMoneyStr()
    local szTili,isFull=self:getEnergyStr()
    --[[
    local headFramSpr=cc.Sprite:createWithSpriteFrameName("general_head_fram.png")
    local headFramSize=headFramSpr:getContentSize()
    headFramSpr:setPosition(headFramSize.width*0.5,self.m_winSize.height-headFramSize.height*0.5)
    self.m_rootNode:addChild(headFramSpr)
	]]--
    

    local framBlackSpr=cc.Sprite:createWithSpriteFrameName("general_head_black.png")
    local blackSize=framBlackSpr:getContentSize()
    framBlackSpr:setPosition(blackSize.width*0.5+2,self.m_winSize.height-blackSize.height*0.5-2)
    self.m_rootNode:addChild(framBlackSpr,-5)

    -- pro=(pro>3 or pro<1) and 5 or pro
    local szHeadImg=string.format("general_head_%d.png",pro)
    local headBtn=gc.CButton:create(szHeadImg)
    local headBtnSize=headBtn:getContentSize()
    headBtn:setPosition(59,76)
    headBtn:addTouchEventListener(c)
    headBtn:setTag(tag_head)
    headBtn:setTouchActionType(_G.Const.kCButtonTouchTypeGray)
    framBlackSpr:addChild(headBtn)
    self.m_headBtn=headBtn
    -- *******************************************
    local nFontSize=20
    -- 名称
    -- self.m_textName=_G.Util:createLabel(name,20)
    -- self.m_textName:enableOutline(cc.c4b(0,0,0,255),1)
    -- self.m_textName:setPosition(175,self.m_winSize.height-28)
    -- self.m_textName:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    -- self.m_mainNode:addChild(self.m_textName)

    -- 等级
    local lvLab=_G.Util:createBorderLabel("Lv:",20)
    lvLab:enableOutline(cc.c4b(0,0,0,255),1)
    lvLab:setPosition(112,107)
    lvLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
    framBlackSpr:addChild(lvLab)

    self.m_lvLabel=lvLab
    self:updateLv(lv)

    local nPosY1=108
    local nPosY2=77
    local nPosY3=48
    -- vip
    self.m_vipSpr=cc.Sprite:createWithSpriteFrameName("general_vip.png")
    self.m_vipSpr:setPosition(150,nPosY2)
    framBlackSpr:addChild(self.m_vipSpr)
    self.m_vipNumArray={}
    self:updateVIP(vip)

    self.m_powerView=require("mod.general.PowerNumNode")(self.m_myProperty:getAllsPower())
    local powerNode=self.m_powerView:create()
    powerNode:setPosition(160,nPosY3)
    framBlackSpr:addChild(powerNode)

    -- 钻石
    local xianYuIcon=cc.Sprite:createWithSpriteFrameName("general_xianYu.png")
    xianYuIcon:setAnchorPoint(cc.p(1,0.5))
    xianYuIcon:setPosition(160,nPosY1)
    framBlackSpr:addChild(xianYuIcon)

    self.m_textXianYu=_G.Util:createLabel(xianYu,nFontSize)
    self.m_textXianYu:setAnchorPoint(cc.p(0,0.5))
    self.m_textXianYu:setPosition(160+6,nPosY1)
    framBlackSpr:addChild(self.m_textXianYu)

    -- 元宝
    local yuanbaoIcon=cc.Sprite:createWithSpriteFrameName("general_gold.png")
    yuanbaoIcon:setAnchorPoint(cc.p(1,0.5))
    yuanbaoIcon:setPosition(264,nPosY1)
    framBlackSpr:addChild(yuanbaoIcon)

    self.m_textYuanBao=_G.Util:createLabel(yuanBao,nFontSize)
    self.m_textYuanBao:setAnchorPoint(cc.p(0,0.5))
    self.m_textYuanBao:setPosition(264+6,nPosY1)
    framBlackSpr:addChild(self.m_textYuanBao)

    -- 铜钱
    local goldIcon=cc.Sprite:createWithSpriteFrameName("general_tongqian.png")
    goldIcon:setAnchorPoint(cc.p(1,0.5))
    goldIcon:setPosition(368,nPosY1)
    framBlackSpr:addChild(goldIcon)

    self.m_textGold=_G.Util:createLabel(gold,nFontSize)
    self.m_textGold:setAnchorPoint(cc.p(0,0.5))
    self.m_textGold:setPosition(368,nPosY1)
    framBlackSpr:addChild(self.m_textGold)

    -- 体力
    local tiliIcon=cc.Sprite:createWithSpriteFrameName("main_strong.png")
    tiliIcon:setAnchorPoint(cc.p(1,0.5))
    tiliIcon:setPosition(265,nPosY2)
    framBlackSpr:addChild(tiliIcon)

    self.m_textTili=_G.Util:createLabel(szTili,nFontSize)
    self.m_textTili:setPosition(315,nPosY2)
    framBlackSpr:addChild(self.m_textTili)
    if isFull then
        self.m_textTili:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    end

    local tiliBtn=gc.CButton:create("general_btn_add.png")
    tiliBtn:setPosition(378,nPosY2)
    tiliBtn:addTouchEventListener(c)
    tiliBtn:setTag(tag_tili)
    tiliBtn:ignoreContentAdaptWithSize(false)
    tiliBtn:setContentSize(cc.size(50,50))
    framBlackSpr:addChild(tiliBtn)
    
    -- local expFramSpr1=cc.Sprite:createWithSpriteFrameName("general_head_exp_01.png")
    -- local expFramSize=expFramSpr1:getContentSize()
    -- expFramSpr1:setPosition(cc.p(57,11))
    -- framBlackSpr:addChild(expFramSpr1)
    --[[
    local expFramSpr2=cc.Sprite:createWithSpriteFrameName("general_head_exp_02.png")
    expFramSpr2:setPosition(expFramSize.width*0.5,expFramSize.height*0.5)
    expFramSpr1:addChild(expFramSpr2,5)
	]]--
    -- local expSpr=cc.Sprite:createWithSpriteFrameName("general_head_exp_03.png")
    --local expFramSize=expSpr:getContentSize()
    -- self.m_expProgress=ccui.LoadingBar:create()
    -- self.m_expProgress:loadTexture("general_head_exp_03.png",ccui.TextureResType.plistType)
    -- self.m_expProgress:setReverseDirection(true)
    -- self.m_expProgress:setAnchorPoint(cc.p(0.5,0.5))
    -- self.m_expProgress:setBarChangeRate(cc.p(0,1))
    -- self.m_expProgress:setPosition(cc.p(57,11))
    -- self.m_expProgress:setPercent(60)

    local tempSprite=cc.Sprite:createWithSpriteFrameName("general_head_exp_01.png")
    local tempTimer=cc.ProgressTimer:create(tempSprite)
    tempTimer:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    tempTimer:setReverseDirection(true)
    tempTimer:setPosition(59,76)
    -- tempTimer:setBarChangeRate(cc.p(0.2,0.8))
    -- tempTimer:setMidpoint(cc.p(0.2,0.8))
    framBlackSpr:addChild(tempTimer) 
    self.m_expProgress=tempTimer
    self:updateExp()

    if _G.SysInfo:isIpNetwork() then
        local gmText = ccui.Text:create()
        gmText:setString("【G M】")
        gmText:setFontSize(30)
        gmText:setFontName(_G.FontName.Heiti)
        gmText:setTouchScaleChangeEnabled(true)
        gmText:setPosition(cc.p(320,500))
        gmText:setTouchEnabled(true)
        gmText:setTag(tag_gm)
        gmText:addTouchEventListener(c)
        gmText:enableOutline(cc.c4b(0,0,0,255),1)
        self.m_rootNode:addChild(gmText)

        local lsText = ccui.Text:create()
        lsText:setString("【临时】")
        lsText:setFontSize(30)
        lsText:setFontName(_G.FontName.Heiti)
        lsText:setTouchScaleChangeEnabled(true)
        lsText:setPosition(cc.p(420,500))
        lsText:setTouchEnabled(true)
        lsText:setTag(tag_ls)
        lsText:addTouchEventListener(c)
        lsText:enableOutline(cc.c4b(0,0,0,255),1)
        self.m_rootNode:addChild(lsText)
    end
end

function MainView.showIconView(self)
    self.m_iconActivity=require("mod.mainUI.IconActivity")(self)
    self.m_iconSystem=require("mod.mainUI.IconSystem")()

    local node1=self.m_iconActivity:create()
    local node2=self.m_iconSystem:create()

    self.m_rootNode:addChild(node1)
    self.m_rootNode:addChild(node2)

    self.m_mediator:setActivityView(self.m_iconActivity)
    self.m_mediator:setSystemView(self.m_iconSystem)

    self.m_iconActivity:showMopTypeIcon(self.m_myProperty.mopType)

    self.m_activityLeftPos=cc.p(-320,0)
    self.m_activityUpPos=cc.p(600,0)
    self.m_isUIShow=_G.GSystemProxy:isActivityViewShow()
    if not self.m_isUIShow then
        self.m_isUIShow=false
        self.m_iconActivity.m_leftContainer:setPosition(self.m_activityLeftPos)
        self.m_iconActivity.m_upContainer:setPosition(self.m_activityUpPos)
    end

    local guideCnf=_G.GGuideManager:getCurGuideCnf()
    if guideCnf~=nil then
        self:addSysGuideNotic(guideCnf.entry_id)
    end
    if #_G.GOpenProxy:getOpenEffectSysArray()>0 then
        self:setVisibleSysGuideNotic(false)
    end

    local function nFun()
        local newOpenArray=_G.GOpenProxy:getOpenEffectSysArray()
        _G.GOpenProxy:resetOpenEffectArray()
        for i=1,#newOpenArray do
            self:addSysOpenEffectData(newOpenArray[i])
        end
    end
    _G.Scheduler:performWithDelay(0.01,nFun)
end
function MainView.getIconActivity(self)
    return self.m_iconActivity
end
function MainView.getIconSystem(self)
    return self.m_iconSystem
end
function MainView.hideOpenIconBtn(self,_openId,_parentId)
    local sysId=nil
    local isSubSys=false
    if _parentId~=nil and _parentId~=0 then
        sysId=_parentId
        isSubSys=true
    else
        sysId=_openId
    end

    if sysId==nil then
        return
    end
    local sysBtn,isNormal=self.m_iconSystem:getIconBtnById(sysId)
    local isSystemBtn=true
    if sysBtn==nil then
        if isSubSys then
            sysBtn=self.m_iconActivity:getIconBtnById(sysId)
        else
            sysBtn,isSubSys=self.m_iconActivity:getIconBtnById(sysId)
        end
        isSystemBtn=false
    end

    if sysBtn==nil then
        return
    end

    if not isSubSys then
        sysBtn:setVisible(false)
    end
    return sysBtn,isSystemBtn,isNormal
end
function MainView.autoShowUI(self)
    self.m_isUIShow=not self.m_isUIShow

    self.m_iconActivity.m_leftContainer:stopAllActions()
    self.m_iconActivity.m_upContainer:stopAllActions()

    local aTime=0.3
    if self.m_isUIShow then
        mainPos=cc.p(0,0)
        leftPos=cc.p(0,0)
        rightPos=cc.p(0,0)
        local mainAction=cc.Sequence:create(cc.Show:create(),
                                            cc.MoveTo:create(aTime,cc.p(0,-5)),
                                            cc.MoveTo:create(0.1,cc.p(0,2)),
                                            cc.MoveTo:create(0.05,cc.p(0,0)))

        local leftAction=cc.Sequence:create(cc.Show:create(),
                                            cc.MoveTo:create(aTime,cc.p(15,0)),
                                            cc.MoveTo:create(0.18,cc.p(-5,0)),
                                            cc.MoveTo:create(0.12,cc.p(0,0)))

        local rightAction=cc.Sequence:create(cc.Show:create(),
                                            cc.MoveTo:create(aTime,cc.p(-15,0)),
                                            cc.MoveTo:create(0.18,cc.p(5,0)),
                                            cc.MoveTo:create(0.12,cc.p(0,0)))


        self.m_iconActivity.m_leftContainer:runAction(leftAction)
        self.m_iconActivity.m_upContainer:runAction(rightAction)
    else
        self.m_iconActivity.m_leftContainer:runAction(cc.Sequence:create(cc.MoveTo:create(aTime,self.m_activityLeftPos),cc.Hide:create()))
        self.m_iconActivity.m_upContainer:runAction(cc.Sequence:create(cc.MoveTo:create(aTime,self.m_activityUpPos),cc.Hide:create()))
    end
    _G.GSystemProxy:setActivityViewShow(self.m_isUIShow)
end
function MainView.isShowUI(self)
    return self.m_isUIShow
end

function MainView.addSysGuideNotic(self,_sysId)
    local isInHere=self.m_iconSystem:addGuideTouch(_sysId)
    if not isInHere then
        isInHere=self.m_iconActivity:addGuideTouch(_sysId)
        if isInHere then
            if not self:isShowUI() then
                self:autoShowUI()
            end
        end
    end
end
function MainView.delSysGuideNotic(self,_sysId)
    self.m_iconSystem:removeGuideTouch(_sysId)
    self.m_iconActivity:removeGuideTouch(_sysId)
end
function MainView.setVisibleSysGuideNotic(self,_bool,_isGoTask)
    self.m_iconSystem:setVisibleGuideTouch(_bool,_isGoTask)
    self.m_iconActivity:setVisibleGuideTouch(_bool,_isGoTask)
end

function MainView.delayToDo(self)
    function local_delayFun()
        self:requestMsg()
        self:showNextSubView()

        local iconTypeArray=_G.GBagProxy:getMainIconTypeArray()
        for _type,_ in pairs(iconTypeArray) do
            self:addIconBtnByType(_type)
        end
        self:addIconBtnByType(_G.Const.kMainIconTeam)

        if _G.g_Stage:getScenesID()==_G.Const.CONST_COPY_FIRST_SCENE and not _G.GLoginPoxy:isLoginCity() then
            if _G.GLoginPoxy:getFirstLogin() then
                _G.Util:playAudioEffect("sys_task")
            else
                _G.Util:playAudioEffect("sys_login")
            end
        end
        _G.GLoginPoxy:loginCity()
    end
    _G.Scheduler:performWithDelay(0.8,local_delayFun)
end

function MainView.requestMsg(self)
    if not _G.GTaskProxy:getInitialized() then
        local msg=REQ_TASK_REQUEST_LIST()
        _G.Network:send(msg)
    end

    if not _G.GBagProxy:getInitialized() then
        local msg_goods_request = REQ_GOODS_REQUEST()
        msg_goods_request:setArgs(
            _G.Const.CONST_GOODS_CONTAINER_BAG,
            _G.GLoginPoxy:getServerId(),
            _G.GLoginPoxy:getUid()
            )
        _G.Network :send( msg_goods_request)
        CCLOG("请求背包信息结束")
        -----请求购回的物品－－－－－－－－－－－－－－－－
        local msg_goods_request = REQ_GOODS_REQUEST()
        msg_goods_request:setArgs(
            _G.Const.CONST_GOODS_CONTAINER_BUY_BACK,
            _G.GLoginPoxy:getServerId(),
            _G.GLoginPoxy:getUid()
            )
        _G.Network :send( msg_goods_request)
        CCLOG("请求背包信息结束")

        -- 登录日志
        -- local msg_log=REQ_GAME_LOGS_LOGIN_CHECK()
        -- _G.Network:send(msg_log)
    end

    -- 好友
    if not _G.GFriendProxy:getInitValueF() then
        local reqList = { _G.Const.CONST_FRIEND_FRIEND,_G.Const.CONST_FRIEND_RECENT,
        _G.Const.CONST_FRIEND_GET_BLESS,_G.Const.CONST_FRIEND_BLACKLIST}
        for i,v in ipairs(reqList) do
            print("REQ_FRIEND_REQUES --->",i,v)
            local msg=REQ_FRIEND_REQUES()
            msg:setArgs(v)
            _G.Network:send(msg)
        end
    end
end

function MainView.getEnergyStr(self)
    local curTili=self.m_myProperty:getSum() or 0      --当前体力值
    local maxTili=self.m_myProperty:getMax() or 0     --最大体力值
    return string.format("%d/%d",curTili,maxTili),curTili>=maxTili
end
function MainView.getCurMoneyStr(self)
    local gold=self.m_myProperty:getGold()
    local xianYu=self.m_myProperty:getRmb()
    local yuanBao=self.m_myProperty:getBindRmb()
    if gold>100000000 then
        gold=math.modf(gold*0.00000001).._G.Lang.number_Chinese["亿"]
    elseif gold>100000 then
        gold=math.modf(gold*0.0001).._G.Lang.number_Chinese["万"]
    end
    if yuanBao>100000000 then
        yuanBao=math.modf(yuanBao*0.00000001).._G.Lang.number_Chinese["亿"]
    elseif yuanBao>100000 then
        yuanBao=math.modf(yuanBao*0.0001).._G.Lang.number_Chinese["万"]
    end
    if xianYu>100000000 then
        xianYu=math.modf(xianYu*0.00000001).._G.Lang.number_Chinese["亿"]
    elseif xianYu>100000 then
        xianYu=math.modf(xianYu*0.0001).._G.Lang.number_Chinese["万"]
    end
    return gold,yuanBao,xianYu
end
function MainView.updateMoney(self)
    local gold,yuanBao,xianYu=self:getCurMoneyStr()
    print("updateMoney=====>>>",gold,yuanBao,xianYu)
    self.m_textXianYu:setString(xianYu)
    self.m_textGold:setString(gold)
    self.m_textYuanBao:setString(yuanBao)

    if _G.GMoneyView then
        _G.GMoneyView:updateMoney(gold,yuanBao,xianYu)
    end
end
function MainView.updateLv(self,_lv)
    -- _lv=88
    local szLv=tostring(_lv)
    self.m_lvLabel:setString(szLv)
end
function MainView.updateVIP(self,_vipLv)
    -- if _vipLv<=0 then return end
    local szVip=tostring(_vipLv)
    local numPosY=self.m_vipSpr:getContentSize().height*0.5
    for i=1,string.len(szVip) do
        local curNum=string.sub(szVip,i,i)
        if self.m_vipNumArray[i]==nil then
            local szNumImg=string.format("general_vipno_%d.png",curNum)
            local numSpr=cc.Sprite:createWithSpriteFrameName(szNumImg)
            numSpr:setPosition(68+(i-1)*11,numPosY)
            self.m_vipSpr:addChild(numSpr)

            local numT={}
            numT.num=curNum
            numT.spr=numSpr
            self.m_vipNumArray[i]=numT
        elseif self.m_vipNumArray[i].num~=curNum then
            local szNumImg=string.format("general_vipno_%d.png",curNum)
            self.m_vipNumArray[i].spr:setSpriteFrame(szNumImg)
            self.m_vipNumArray[i].num=curNum
        end
    end
end
function MainView.updateEnergy(self)
    local szTili,isFull=self:getEnergyStr()
    self.m_textTili:setString(szTili)
    if isFull then
        self.m_textTili:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    else
        self.m_textTili:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE))
    end
end
function MainView.updateName(self,_szName)
    _szName=_szName or "?"
    -- self.m_textName:setString(_szName)
end
function MainView.updatePowerNum(self)
    self.m_powerView:setPower(self.m_myProperty:getAllsPower())
end
function MainView.updateExp(self)
    local curExp=self.m_myProperty:getExp() or 0
    local maxExp=self.m_myProperty:getExpn() or 1
    local startPre=36
    local percent=curExp/maxExp*100
    print(">>>>>>>>>>   percent  <<<<<<<<<<<<",percent)
    self.m_expProgress:setPercentage(percent)
    -- self.m_expBar:setPercent(percent)
    -- local nWidth=percent*self.m_expSprSize.width
    -- self.m_expSpr:setPreferredSize(cc.size(nWidth,self.m_expSprSize.height))
end

function MainView.showAcceptTaskEffect(self)
    if self.m_taskAcceptSpr~=nil then return end
    _G.Util:playAudioEffect("ui_task_get")

    self.m_taskAcceptSpr=cc.Sprite:createWithSpriteFrameName("main_effect_word_jsrw.png")
    self.m_taskAcceptSpr:setScale(0.05)
    self.m_taskAcceptSpr:setPosition(self.m_winSize.width*0.5,480)
    cc.Director:getInstance():getRunningScene():addChild(self.m_taskAcceptSpr,_G.Const.CONST_MAP_ZORDER_LAYER+10)

    local function f1()
        self.m_taskAcceptSpr:removeFromParent(true)
        self.m_taskAcceptSpr=nil
    end
    local function f2()
        local action=cc.Sequence:create(cc.FadeTo:create(0.15,0),cc.CallFunc:create(f1))
        self.m_taskAcceptSpr:runAction(action)
    end
    local function f3()
        local szPlist="anim/task_accept.plist"
        local szFram="task_accept_"
        local act1=_G.AnimationUtil:createAnimateAction(szPlist,szFram,0.12)
        local act2=cc.CallFunc:create(f2)

        local sprSize=self.m_taskAcceptSpr:getContentSize()
        local effectSpr=cc.Sprite:create()
        effectSpr:setPosition(sprSize.width*0.5,sprSize.height*0.5)
        effectSpr:runAction(cc.Sequence:create(act1,act2))
        self.m_taskAcceptSpr:addChild(effectSpr)
    end
    local action=cc.Sequence:create(cc.ScaleTo:create(0.15,1),cc.CallFunc:create(f3))
    self.m_taskAcceptSpr:runAction(action)
end
function MainView.showFinishTaskEffect(self)
    if self.m_taskFinishSpr~=nil then return end
    _G.Util:playAudioEffect("ui_task_ok")
    
    self.m_taskFinishSpr=cc.Sprite:createWithSpriteFrameName("main_effect_word_wcrw.png")
    self.m_taskFinishSpr:setScale(0.05)
    self.m_taskFinishSpr:setPosition(self.m_winSize.width*0.5,480)
    cc.Director:getInstance():getRunningScene():addChild(self.m_taskFinishSpr,_G.Const.CONST_MAP_ZORDER_LAYER+10)

    local function f1()
        self.m_taskFinishSpr:removeFromParent(true)
        self.m_taskFinishSpr=nil
    end
    local function f2()
        local action=cc.Sequence:create(cc.FadeTo:create(0.15,0),cc.CallFunc:create(f1))
        self.m_taskFinishSpr:runAction(action)
    end
    local function f3()
        local szPlist="anim/task_finish.plist"
        local szFram="task_finish_"
        local act1=_G.AnimationUtil:createAnimateAction(szPlist,szFram,0.12)
        local act2=cc.CallFunc:create(f2)

        local sprSize=self.m_taskFinishSpr:getContentSize()
        local effectSpr=cc.Sprite:create()
        effectSpr:setPosition(sprSize.width*0.5,sprSize.height*0.5)
        effectSpr:runAction(cc.Sequence:create(act1,act2))
        self.m_taskFinishSpr:addChild(effectSpr)
    end
    local action=cc.Sequence:create(cc.ScaleTo:create(0.15,1),cc.CallFunc:create(f3))
    self.m_taskFinishSpr:runAction(action)
end

function MainView.showNextSubView(self)
    if #self.m_subViewArray>0 then
        self:showSubViewNow()
    end
end
function MainView.showSubViewNow(self)
    if self.m_isSubViewShowing then
        if self.m_subGoodsUseView~=nil then
            local nCount=#self.m_subViewArray
            local subData=self.m_subViewArray[nCount]
            if subData.type==self.m_layerManager.type_useGoods then
                self.m_subGoodsUseView:addSomeGoodsToUse(subData.data1)
                self.m_subViewArray[nCount]=nil
            end
        end
        return
    end
    self.m_isSubViewShowing=true

    local curData=table.remove(self.m_subViewArray,1)
    local nParent=_G.g_Stage:getScene()
    local nZorder=_G.Const.CONST_MAP_ZORDER_LAYER-10
    local nType=curData.type
    local data1=curData.data1
    local data2=curData.data2
    if nType==self.m_layerManager.type_sysOpen then
        -- _G.g_Stage:getMainPlayer():cancelMove()
        -- local subView=require("mod.mainUI.SubOpenFun")(data2,self)
        -- local subLayer=subView:create()
        -- if subLayer~=nil then
        --     nParent:addChild(subLayer,nZorder,99898)
        -- else
        --     self:subViewFinish()
        -- end
        -- 功能开放特效的逻辑单独处理了
        self:subViewFinish()
        return
    elseif nType==self.m_layerManager.type_recommendFriend then
        _G.g_Stage:getMainPlayer():cancelMove()
        local subLayer=_G.GFriendProxy:createRecommendView(data1)
        nParent:addChild(subLayer,nZorder,99898)
    elseif nType==self.m_layerManager.type_useGoods then
        if self.m_subGoodsUseView==nil then
            -- print("JJJJJJJJJJJJJJJJJJJJ>>>>>>>",data1,#data1)
            -- for i=1,#data1 do
            --     for k,v in pairs(data1[i]) do
            --         print("      =====>>>>",k,v)
            --     end
            -- end
            local subView=require("mod.mainUI.SubGoodsUse")(data1)
            local subLayer=subView:create()
            nParent:addChild(subLayer,nZorder,99898)

            self.m_subGoodsUseView=subView
        end
    else
        self:subViewFinish()
        return
    end

    if self.m_isShowingOpenEffect then
        self:setSubViewState(false)
    end

    self.m_layerManager:closeTaskDialog()
end
function MainView.subViewFinish(self)
    self.m_isSubViewShowing=false
    self.m_subGoodsUseView=nil
    self:showNextSubView()
end
function MainView.removeSubGoodsUseView(self,_goodsMsg)
    if self.m_subGoodsUseView~=nil then
        self.m_subGoodsUseView:delGoodsToUse(_goodsMsg)
    else
        local subDataArray=self.m_layerManager.m_subViewArray
        local subDataCount=#subDataArray
        if subDataCount==0 then return end

        local dataIdx=nil
        for i=1,subDataCount do
            local tempT=subDataArray[i]
            if tempT.type==self.m_layerManager.type_useGoods then
                dataIdx=i
                break
            end
        end
        if dataIdx then
            local tempData1=subDataArray[dataIdx].data1
            for i=1,#tempData1 do
                local tempMsg=tempData1[i].goodsMsg
                if tempMsg.index==_goodsMsg.index then
                    tempData1[i]=nil
                    break
                end
            end
            if #tempData1==0 then
                table.remove(self.m_layerManager.m_subViewArray,dataIdx)
            end
        end
    end
end


function MainView.addSysOpenEffectData(self,_sysId)
    _G.GOpenProxy:delOpenEffectSysId(_sysId)

    local openInfoCnf=_G.Cfg.sys_open_info[_sysId]
    if openInfoCnf==nil then
        gcprint("addSubView  type_sysOpen... openInfoCnf==nil")
        return
    elseif openInfoCnf.open_effect==0 then
        return
    end

    local sysBtn=self:hideOpenIconBtn(openInfoCnf.open_id,openInfoCnf.parent_id)
    if sysBtn==nil then return end

    if self.m_isShowingOpenEffect then
        if self.m_sysOpenEffectArray==nil then
            self.m_sysOpenEffectArray={}
        end
        self.m_sysOpenEffectArray[#self.m_sysOpenEffectArray+1]=openInfoCnf
    else
        self:showSysOpenEffect(openInfoCnf)
    end
end
function MainView.showSysOpenEffect(self,_data)
    if self.m_isShowingOpenEffect then return end

    _G.g_Stage:getMainPlayer():cancelMove()
    self.m_layerManager:closeTaskDialog()

    local nParent=_G.g_Stage:getScene()
    local nZorder=_G.Const.CONST_MAP_ZORDER_LAYER-5

    local subView=require("mod.mainUI.SubOpenFun")(_data,self)
    local subLayer=subView:create()
    if subLayer~=nil then
        nParent:addChild(subLayer,nZorder)
        self.m_isShowingOpenEffect=true
        self:setSubViewState(false)
    else
        self:showSysOpenEffectEnd()
    end
end
function MainView.showSysOpenEffectEnd(self)
    self.m_isShowingOpenEffect=false
    if self.m_sysOpenEffectArray and #self.m_sysOpenEffectArray>0 then
        self:showSysOpenEffect(table.remove(self.m_sysOpenEffectArray))
    else
        self:setSubViewState(true)
    end
end
function MainView.setSubViewState(self,_visity)
    local subView=_G.g_Stage:getScene():getChildByTag(99898)
    if subView then
        subView:setVisible(_visity)
    end

    self:setVisibleSysGuideNotic(_visity)
end

function MainView.roleLevelUp(self,_roleLv)
    _G.Util:playAudioEffect("ui_role_upgrade")

    if _roleLv==18 then
        self:__createHeadGuide(1)
    end

    self:updateLv(_roleLv)
    if self.m_lvEffectNode~=nil then return end

    if _G.g_Stage:getScene()~=cc.Director:getInstance():getRunningScene() then return end

    cc.Director:getInstance():getEventDispatcher():setEnabled(false)
    local mainPlayer=_G.g_Stage:getMainPlayer()
    local playerPosX,playerPosY=mainPlayer:getLocationXY()
    if mainPlayer.m_isJoyStickPress then
        _G.g_Stage:cancelJoyStickTouch()
    end

    self.m_lvEffectNode=cc.Node:create()
    mainPlayer:getContainer():addChild(self.m_lvEffectNode,10)
    
    local function f2(node)
        cc.Director:getInstance():getEventDispatcher():setEnabled(true)
        _G.g_Stage:resetContainerAR()
        _G.g_Stage.m_lpContainer:runAction(cc.ScaleTo:create(0.15,1))

        node:removeFromParent(true)
        self.m_lvEffectNode:removeFromParent(true)
        self.m_lvEffectNode=nil
    end

    local function f3()
        local act2=cc.CallFunc:create(f2)
        local spine = _G.SpineManager.createSpine("spine/shengji",0.5)
        spine:setAnimation(0,"idle",false)
        self.m_lvEffectNode:addChild(spine)
        self.m_lvEffectNode:runAction(cc.Sequence:create(cc.DelayTime:create(1.2),act2))
    end
    _G.g_Stage:resetContainerAR()
    _G.g_Stage.m_lpContainer:runAction(cc.Sequence:create(cc.ScaleTo:create(0.15,1.2),cc.CallFunc:create(f3)))
end

function MainView.ortherPlayerLevelUp(self,_ackMsg)
    if _G.g_Stage:getScene()~=cc.Director:getInstance():getRunningScene() then return end
    
    local nUid=_ackMsg.uid
    local tempPlayer=_G.CharacterManager:getPlayerByID(nUid)
    if tempPlayer==nil then return end

    local tempNode=tempPlayer:getContainer()

    if tempNode:getChildByTag(66996)~=nil then return end

    local function nFun(_node)
        _node:removeFromParent(true)
    end

    local tempSpr=_G.SpineManager.createSpine("spine/shengji",0.5)
    tempSpr:setTag(66996)
    -- local szPlist="anim/effect_level.plist"
    -- local szFram="effect_level_"
    -- local act1=_G.AnimationUtil:createAnimateAction(szPlist,szFram,0.1)
    tempSpr:setAnimation(0,"idle",false)
    -- local act2=cc.FadeTo:create(0.2,0)
    local act3=cc.CallFunc:create(nFun)
    tempSpr:runAction(cc.Sequence:create(cc.DelayTime:create(1.2),act3))

    tempNode:addChild(tempSpr,10)
end


function MainView.msgCallByEnergy(self,_ackMsg,_focus)
    local scene=cc.Director:getInstance():getRunningScene()
    if scene:getChildByTag(332211) then
        return
    end
    local P_VIEW_SIZE=cc.size(412,320)
    local function onTouchBegan() return true end
    local listerner=cc.EventListenerTouchOneByOne:create()
    listerner:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listerner:setSwallowTouches(true)

    local m_mainLayer=cc.LayerColor:create(cc.c4b(0,0,0,150))
    m_mainLayer : getEventDispatcher():addEventListenerWithSceneGraphPriority(listerner,m_mainLayer)
    cc.Director:getInstance():getRunningScene() :addChild(m_mainLayer,1000)

    local mainBgSpr=ccui.Scale9Sprite:createWithSpriteFrameName( "general_tips_dins.png" ) 
    mainBgSpr : setPosition(self.m_winSize.width/2, self.m_winSize.height/2-20)
    mainBgSpr : setPreferredSize( P_VIEW_SIZE )
    m_mainLayer:addChild(mainBgSpr)

    local titleLab=_G.Util:createBorderLabel("提 示",24,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    titleLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BRIGHTYELLOW))
    titleLab:setPosition(P_VIEW_SIZE.width/2,P_VIEW_SIZE.height-25)
    mainBgSpr:addChild(titleLab,10)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(P_VIEW_SIZE.width/2-115,P_VIEW_SIZE.height-25)
    mainBgSpr:addChild(titleSpr,9)

    local titleSpr=cc.Sprite:createWithSpriteFrameName("general_tips_up.png")
    titleSpr:setPosition(P_VIEW_SIZE.width/2+110,P_VIEW_SIZE.height-25)
    titleSpr:setRotation(180)
    mainBgSpr:addChild(titleSpr,9)

    local lineSpr2=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    lineSpr2:setPreferredSize(cc.size(P_VIEW_SIZE.width-15,P_VIEW_SIZE.height-50))
    lineSpr2:setPosition(P_VIEW_SIZE.width*0.5,P_VIEW_SIZE.height*0.5-17)
    mainBgSpr:addChild(lineSpr2)

    local m_sureButton=gc.CButton:create("general_btn_gold.png")
    m_sureButton:setTitleText("购 买")
    m_sureButton:setTitleFontSize(24)
    m_sureButton:setTitleFontName(_G.FontName.Heiti)
    m_sureButton:setTag(1)
    -- m_sureButton:setButtonScale(0.8)
    mainBgSpr:addChild(m_sureButton)

    local m_cancelButton=gc.CButton:create("general_btn_lv.png")
    m_cancelButton:setTitleText("取 消")
    m_cancelButton:setTitleFontSize(24)
    m_cancelButton:setTitleFontName(_G.FontName.Heiti)
    m_cancelButton:setTag(2)
    -- m_cancelButton:setButtonScale(0.8)
    mainBgSpr:addChild(m_cancelButton)
    m_sureButton   :setPosition(P_VIEW_SIZE.width*0.5-90,P_VIEW_SIZE.height/2+10)
    m_cancelButton :setPosition(P_VIEW_SIZE.width*0.5+90,P_VIEW_SIZE.height/2+10)

    self.surplusTimes=_ackMsg.sumnum-_ackMsg.num+1
    self.maxTimes=_ackMsg.sumnum
    local buyNodes=_G.Cfg.energy_buy[_ackMsg.num]
    local szSureBtn,szContent,szyousb,szNotic,szTimes

    local function local_buttonCallBack(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local btnName=sender:getTag()
            if btnName==1 or btnName==777 or btnName==888 then
                if self.surplusTimes<=0 then
                    local command=CErrorBoxCommand("剩余购买次数不足,提升VIP能增加购买次数")
                    _G.controller:sendCommand(command)
                    if m_mainLayer == nil then return end
                    m_mainLayer:removeFromParent(true)
                else
                    print("dddd-------")
                    local msg=REQ_ROLE_BUY_ENERGY()
                    _G.Network:send(msg)
                    if cc.Director:getInstance():getRunningScene():getTag()==_G.Const.CONST_FUNC_OPEN_STRATEGY then
                        local msg=REQ_GONGLUE_HY()
                        _G.Network:send(msg)
                    end
                end
            elseif btnName==2 then
                if m_mainLayer == nil then return end
                m_mainLayer:removeFromParent(true)
            elseif btnName==123 then
                for i=1,3 do
                    self.copyBtn[i]    : setVisible(true)
                    self.copyBtn[i+3]  : setVisible(false)
                    self.leftPageBtn   : setVisible(false)
                    self.rightPageBtn  : setVisible(true)
                end
            elseif btnName==321 then
                for i=1,3 do
                    self.copyBtn[i]    : setVisible(false)
                    self.copyBtn[i+3]  : setVisible(true)
                    self.leftPageBtn   : setVisible(true)
                    self.rightPageBtn  : setVisible(false)
                end
            end
        end
    end
    m_sureButton  :addTouchEventListener(local_buttonCallBack)
    m_cancelButton:addTouchEventListener(local_buttonCallBack)

    self.leftPageBtn  = gc.CButton : create()
    self.leftPageBtn  : setVisible(false)
    self.leftPageBtn  : loadTextures("general_fangye_1.png")
    self.leftPageBtn  : setTag(123)
    self.leftPageBtn  : addTouchEventListener(local_buttonCallBack)
    self.leftPageBtn  : ignoreContentAdaptWithSize(false)
    self.leftPageBtn  : setContentSize(cc.size(85,60))
    mainBgSpr    : addChild(self.leftPageBtn,5)
    self.leftPageBtn  : setPosition(40,60)

    self.rightPageBtn  = gc.CButton : create()
    self.rightPageBtn  : loadTextures("general_fangye_1.png")
    self.rightPageBtn  : setButtonScaleX(-1)
    self.rightPageBtn  : setTag(321)
    self.rightPageBtn  : addTouchEventListener(local_buttonCallBack)
    self.rightPageBtn  : ignoreContentAdaptWithSize(false)
    self.rightPageBtn  : setContentSize(cc.size(85,60))
    mainBgSpr     : addChild(self.rightPageBtn,5)
    self.rightPageBtn  : setPosition(P_VIEW_SIZE.width-40,60)

    local function CopyBtnCallBack( obj, eventType )
        if eventType == ccui.TouchEventType.ended then
            local copytag=obj:getTag()
            print("进入对应副本",copytag)
            if _G.GOpenProxy:showSysNoOpenTips(copytag) then return false end
            _G.GLayerManager:openSubLayer(copytag)
            if m_mainLayer~=nil then
                m_mainLayer:removeFromParent(true)
                m_mainLayer=nil
            end
        end
    end 

    local IconId={_G.Const.CONST_FUNC_OPEN_TOWER,_G.Const.CONST_FUNC_OPEN_STRATEGY,_G.Const.CONST_FUNC_OPEN_FRIEND,
                    _G.Const.CONST_FUNC_OPEN_SHOP,_G.Const.CONST_FUNC_OPEN_WELFARE,_G.Const.CONST_FUNC_OPEN_BAG}
    if _G.GOpenProxy:showSysNoOpenTips(IconId[5],true) then
        IconId={_G.Const.CONST_FUNC_OPEN_STRATEGY,_G.Const.CONST_FUNC_OPEN_FRIEND,_G.Const.CONST_FUNC_OPEN_SHOP,
                _G.Const.CONST_FUNC_OPEN_BAG,_G.Const.CONST_FUNC_OPEN_TOWER,_G.Const.CONST_FUNC_OPEN_WELFARE}
    elseif _G.GOpenProxy:showSysNoOpenTips(IconId[1],true) then
        IconId={_G.Const.CONST_FUNC_OPEN_BAG,_G.Const.CONST_FUNC_OPEN_FRIEND,_G.Const.CONST_FUNC_OPEN_SHOP,
                _G.Const.CONST_FUNC_OPEN_BAG,_G.Const.CONST_FUNC_OPEN_WELFARE,_G.Const.CONST_FUNC_OPEN_TOWER}
    end

    self.copyBtn={}
    for i=1,6 do
        local partnerRes=_G.Cfg.IconResList[IconId[i]]
        local copyBtn = gc.CButton:create(partnerRes)
        copyBtn : setPosition( 115+(i-1)*90, 60 )
        copyBtn : addTouchEventListener(CopyBtnCallBack)
        -- copyBtn : setButtonScale(0.8)
        copyBtn : setTag(IconId[i])
        copyBtn : setSwallowTouches(false)
        mainBgSpr : addChild(copyBtn) 
        if i>3 then
            copyBtn : setPosition( 115+(i-4)*90, 60 )
            copyBtn : setVisible(false)
        end
        self.copyBtn[i]=copyBtn
    end

    local lineSpr=ccui.Scale9Sprite:createWithSpriteFrameName("general_double_line.png")
    lineSpr:setPreferredSize(cc.size(P_VIEW_SIZE.width-50,2))
    lineSpr:setPosition(P_VIEW_SIZE.width/2,P_VIEW_SIZE.height/2-25)
    mainBgSpr:addChild(lineSpr)

    local tipLab=_G.Util:createLabel("获取体力",20)
    -- tipLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
    tipLab:setPosition(P_VIEW_SIZE.width*0.5,P_VIEW_SIZE.height/2-45)
    mainBgSpr:addChild(tipLab)
    
    local szAdd=buyNodes and buyNodes.add_energy or ""
    szContent=_G.Lang.LAB_N[43].._ackMsg.rmb.._G.Lang.Currency_Type[3].._G.Lang.LAB_N[218]..szAdd.._G.Lang.LAB_N[554].._G.Lang.Currency_Type[5]
    
    szNotic=string.format("剩余%s：",_G.Lang.BTN_N[38])
    szTimes=self.surplusTimes

    local labWidth=0
    if szNotic~=nil then
        local noticLab=_G.Util:createLabel(szNotic,20)
        -- noticLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
        noticLab:setAnchorPoint(cc.p(0,0.5))
        noticLab:setPosition(120,P_VIEW_SIZE.height-103)
        mainBgSpr:addChild(noticLab)
        labWidth=noticLab:getContentSize().width
    end
    
    if szTimes~=nil then
        self.timesLab=_G.Util:createLabel(string.format("%d/%d",szTimes,self.maxTimes),20)
        self.timesLab:setAnchorPoint(cc.p(0,0.5))
        self.timesLab:setPosition(125+labWidth,P_VIEW_SIZE.height-103)
        self.timesLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GRASSGREEN))
        mainBgSpr:addChild(self.timesLab)
        if szTimes==0 then 
            self.timesLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
        end
    end
    if szContent~=nil then
        if self.value==nil then
            self.contentLab=_G.Util:createLabel(szContent,20)
            -- self.contentLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BROWN))
            self.contentLab:setPosition(P_VIEW_SIZE.width*0.5,P_VIEW_SIZE.height-70)
            mainBgSpr:addChild(self.contentLab)
        else
            local labWidth=60
            self.contentLab=_G.Util:createLabel(_G.Lang.LAB_N[43].._ackMsg.rmb.._G.Lang.Currency_Type[3].._G.Lang.LAB_N[218]..szAdd,20)
            self.contentLab:setAnchorPoint(cc.p(0,0.5))
            self.contentLab:setPosition(labWidth,P_VIEW_SIZE.height-70)
            mainBgSpr:addChild(self.contentLab)

            labWidth=labWidth+self.contentLab:getContentSize().width
            self.beishuLab=_G.Util:createLabel(string.format("x%d",self.value),20)
            self.beishuLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_YELLOW))
            self.beishuLab:setAnchorPoint(cc.p(0,0.5))
            self.beishuLab:setPosition(labWidth,P_VIEW_SIZE.height-70)
            mainBgSpr:addChild(self.beishuLab)

            labWidth=labWidth+self.beishuLab:getContentSize().width
            self.contentLab1=_G.Util:createLabel(_G.Lang.LAB_N[554].._G.Lang.Currency_Type[5],20)
            -- self.contentLab1:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_GOLD))
            self.contentLab1:setAnchorPoint(cc.p(0,0.5))
            self.contentLab1:setPosition(labWidth,P_VIEW_SIZE.height-70)
            mainBgSpr:addChild(self.contentLab1)
        end
    end
end

function MainView.updateEnergyNum(self)
    if not self.surplusTimes or not self.timesLab then return end
    print("updateEnergyNum",self.surplusTimes)
    self.surplusTimes=self.surplusTimes-1
    self.timesLab:setString(string.format("%d/%d",self.surplusTimes,self.maxTimes))
    local num=self.maxTimes-self.surplusTimes+1
    local buyNodes=_G.Cfg.energy_buy[num]
    local szContent=_G.Lang.LAB_N[43]..buyNodes.use_rmb.._G.Lang.Currency_Type[3]..
    _G.Lang.LAB_N[218]..buyNodes.add_energy.._G.Lang.LAB_N[554].._G.Lang.Currency_Type[5]
    self.contentLab:setString(szContent)
    if self.value~=nil then 
        szContent=_G.Lang.LAB_N[43]..buyNodes.use_rmb.._G.Lang.Currency_Type[3].._G.Lang.LAB_N[218]..buyNodes.add_energy
        self.contentLab:setString(szContent)
        local labWidth=60+self.contentLab:getContentSize().width
        self.beishuLab:setPosition(labWidth,P_VIEW_SIZE.height-70)
        labWidth=labWidth+self.beishuLab:getContentSize().width
        self.contentLab1:setPosition(labWidth,P_VIEW_SIZE.height-70)
    end
    
    if self.surplusTimes<=0 then 
        self.timesLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORED))
    end
end

function MainView.addIconBtnByType(self,_type)
    if self.m_iconArray[_type]~=nil then
        _G.GBagProxy:setMainIconTypeState(_type,nil)
        return
    end

    local szIcon=nil
    if _type==_G.Const.kMainIconTeam then
        if not _G.GSystemProxy:isTeamOpen() then
            return
        end

        local teamData=_G.GFriendProxy:getInviteTeamData()
        if #teamData==0 then return end

        szIcon="main_icon_zudui2.png"
    elseif _type==_G.Const.kMainIconPK then
        if _G.g_Stage:getTouchPlayContainer():getChildByTag(6666) then
            _G.GSystemProxy:removeAllPKInvite()
            return
        end
        szIcon="main_icon_qcuo2.png"
    -- elseif _type==_G.Const.kMainIconBoss then
    --     szIcon="general_clanboss.png"
    --     _G.GBagProxy:setMainIconTypeState(_type,nil)
    else
        szIcon="main_icon_nuli2.png"
        _G.GBagProxy:setMainIconTypeState(_type,nil)
    end

    local function c(sender,eventType)
        if eventType==ccui.TouchEventType.ended then
            if _type==_G.Const.kMainIconEmal then
                _G.GLayerManager:openLayer(_G.Const.CONST_FUNC_OPEN_MALL)
                self:removeIconBtnByType(_type)
            elseif _type==_G.Const.kMainIconTeam then
                local inviteView=require("mod.team.InviteView")(_G.GFriendProxy:getInviteTeamData())
                local tempNode=inviteView:create()
                _G.g_Stage:getScene():addChild(tempNode,_G.Const.CONST_MAP_ZORDER_LAYER)
            elseif _type==_G.Const.kMainIconSlave then
                _G.GLayerManager:openLayer(_G.Const.CONST_FUNC_OPEN_MOIL)
                self:removeIconBtnByType(_type)
            elseif _type==_G.Const.kMainIconArena then
                _G.GLayerManager:openLayer(_G.Const.CONST_FUNC_OPEN_ARENA)
                self:removeIconBtnByType(_type)
            elseif _type==_G.Const.kMainIconPK then
                local pkArray=_G.GSystemProxy:getPKInviteArray()
                if #pkArray>0 then
                    local inviteView=require("mod.mainUI.PKInviteView")(pkArray)
                    local tempNode=inviteView:create()
                    tempNode:setTag(6666)
                    _G.g_Stage:getTouchPlayContainer():addChild(tempNode)
                end
                self:removeIconBtnByType(_type)
                _G.GSystemProxy:removeAllPKInvite()
            -- elseif _type==_G.Const.kMainIconBoss then
            --     local msg = REQ_SCENE_ENTER_FLY()
            --     msg : setArgs(  _G.Const.CONST_CLAN_BOSS_MAPID  )
            --     _G.Network : send( msg )
                
            --     local msg = REQ_WORLD_BOSS_CITY_BOOSS()
            --     _G.Network : send( msg )
            end
        end
    end

    self.m_iconCount=self.m_iconCount+1
    local iconBtn=gc.CButton:create(szIcon)
    iconBtn:addTouchEventListener(c)
    iconBtn:setPosition(self.m_winSize.width*0.5+80*self.m_iconCount,180)
    iconBtn:setButtonScale(1.3)
    self.m_rootNode:addChild(iconBtn)
    self.m_iconArray[self.m_iconCount]=iconBtn
    self.m_iconArray[_type]=iconBtn

    self:addEffectsById(iconBtn)
    _G.Util:playAudioEffect("ui_message")
end

function MainView.addEffectsById(self,sender)
    local btnSize=sender:getContentSize()
    local tempSpr=cc.Sprite:createWithSpriteFrameName("main_icon_effect.png")
    tempSpr:setPosition(btnSize.width*0.5,btnSize.height*0.5)
    tempSpr:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.35,90)))
    -- tempSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeTo:create(1,150),cc.FadeTo:create(1,255))))
    sender:addChild(tempSpr,-1)

    local spine=_G.SpineManager.createSpine("spine/6048")
    spine:setPosition(cc.p(btnSize.width*0.5,btnSize.height*0.5))
    spine:setAnimation(0,"idle",true)
    sender:addChild(spine)
end

function MainView.removeIconBtnByType(self,_type)
    local iconBtn=self.m_iconArray[_type]
    if iconBtn==nil then return end
    self.m_iconArray[_type]=nil

    for i=1,#self.m_iconArray do
        if self.m_iconArray[i]==iconBtn then
            table.remove(self.m_iconArray,i)
            self.m_iconCount=self.m_iconCount-1
            break
        end
    end
    iconBtn:removeFromParent(true)
    for i=1,#self.m_iconArray do
        self.m_iconArray[i]:setPosition(self.m_winSize.width*0.5+60*i,180)
    end
end

function MainView.addHongBaoView(self,_ackMsg)
    print("addHongBaoView===========>>  1")
    local runningScene=cc.Director:getInstance():getRunningScene()
    local myScene=runningScene
    if myScene:getChildByTag(7795) then return end
    print("addHongBaoView===========>>  2")
    local tempView=require("mod.mainUI.GrabRedTipsView")(_ackMsg)
    local tempLayer=tempView:create()
    myScene:addChild(tempLayer,_G.Const.CONST_MAP_ZORDER_LAYER+20,7795)
end

function MainView.xianyuReturn(self)
	local _szMsg="钻石不足，是否前往充值？"
	local function fun1()
		if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_RECHARGE) then return false end
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE)
	end
	if cc.Director:getInstance():getRunningScene():getChildByTag(134) then
		
	else
		local view=require("mod.general.TipsBox")()
		local layer=view:create(_szMsg,fun1)
		cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		layer:setTag(134)
	end
end

function MainView.tongqianReturn(self)
	local _szMsg="铜钱不足，是否前往招财？"
	local function fun1()
		if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_LUCKY) then return false end
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_LUCKY)
	end
	if cc.Director:getInstance():getRunningScene():getChildByTag(132) then
		
	else
		local view=require("mod.general.TipsBox")()
		local layer=view:create(_szMsg,fun1)
		cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		layer:setTag(132)
	end
end

function MainView.goodsReturn(self,_type)
	local _szMsg="宠物丹不足，是否前往商城购买？"
	if _type == 1 then
		_szMsg="刷新符不足，是否前往商城购买？"
	elseif _type == 2 then
		_szMsg="铬合金不足，是否前往商城购买？"
	end
	local function fun1()
		if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_SHOP) then return false end
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_SHOP,false,_G.Const.CONST_MALL_TYPE_SUB_PROPS)
	end
	if cc.Director:getInstance():getRunningScene():getChildByTag(38550) then
		
	else
		local view=require("mod.general.TipsBox")()
		local layer=view:create(_szMsg,fun1)
		cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		layer:setTag(38550)
	end
end

function MainView.reputationReturn(self)
	local _szMsg="妖魂不足，是否前往竞技场获取？"
	local function fun1()
		if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_ARENA) then return false end
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_ARENA)
	end
	if cc.Director:getInstance():getRunningScene():getChildByTag(12040) then
		
	else
		local view=require("mod.general.TipsBox")()
		local layer=view:create(_szMsg,fun1)
		cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		layer:setTag(12040)
	end
end

function MainView.xuanjinReturn(self)
	local _szMsg="玄铁不足，是否前往锁妖塔获取？"
	local function fun1()
		if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_TOWER) then return false end
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_TOWER)
	end
	if cc.Director:getInstance():getRunningScene():getChildByTag(7960) then
		
	else
		local view=require("mod.general.TipsBox")()
		local layer=view:create(_szMsg,fun1)
		cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		layer:setTag(7960)
	end
end

function MainView.gongdeReturn(self)
	local _szMsg="道行不足，是否前往合战群魔获取？"
	local function fun1()
		if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_TEAM) then return false end
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_TEAM)
	end
	if cc.Director:getInstance():getRunningScene():getChildByTag(8203) then
		
	else
		local view=require("mod.general.TipsBox")()
		local layer=view:create(_szMsg,fun1)
		cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		layer:setTag(8203)
	end
end

function MainView.starReturn(self)
	local _szMsg="星石不足，是否前往历练获取？"
	local function fun1()
		if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_COPY) then return false end
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_COPY)
	end
	if cc.Director:getInstance():getRunningScene():getChildByTag(123) then
		
	else
		local view=require("mod.general.TipsBox")()
		local layer=view:create(_szMsg,fun1)
		cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		layer:setTag(123)
	end
end

function MainView.openReturn(self,_type)
	local _szMsg="激活条件不足，前往商城获取？"
    if _type == 2 or _type == 5 then
        _szMsg="激活条件不足，前往陨石商城获取？"
    elseif _type == 3 then
        _szMsg="激活条件不足，前往首充获取？"
    elseif _type == 6 then
        _szMsg="激活条件不足，前往签到获取？"
    end
	local function fun1()
		if _type == 1 then
			if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_SHOP) then return false end
			_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_SHOP,false,_G.Const.CONST_MALL_TYPE_SUB_PROPS)
		elseif _type == 2 then
			if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_RECHARGE_SUPREME) then return false end
			_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE_SUPREME)
		elseif _type == 3 then
            print("_szMsg--->>11111",_szMsg)
			if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_SRSC) then return false end
			_G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_SRSC)
        elseif _type == 4 then
            if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_SHOP) then return false end
            _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_SHOP,false,_G.Const.CONST_MALL_TYPE_SUB_PROPS)
        elseif _type == 5 then
            if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_RECHARGE_SUPREME) then return false end
            _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_RECHARGE_SUPREME)
            
        elseif _type == 6 then
            if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_RECHARGE_SUPREME) then return false end
            _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_WELFARE,false,2)
		end
	end

	if cc.Director:getInstance():getRunningScene():getChildByTag(8050) then
		
	else
        print("_szMsg--->>22222",_szMsg)
		local view=require("mod.general.TipsBox")()
		local layer=view:create(_szMsg,fun1)
		cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		layer:setTag(8050)
	end
end

function MainView.__createHeadGuide(self,_type)
    local guideNode=cc.Node:create()
    self.m_headBtn:addChild(guideNode)

    local btnPosX,btnPosY=self.m_headBtn:getPosition()
    local tempSize=self.m_headBtn:getContentSize()
    guideNode:setPosition(tempSize.width*0.5,tempSize.height*0.5)
    guideNode:addChild(_G.GGuideManager:createTouchEffect())
    guideNode:setTag(_type)

    -- local btnSize=self.m_headBtn:getContentSize()
    -- local btnPosX,btnPosY=self.m_headBtn:getPosition()
    -- local handNode=_G.GGuideManager:createTouchNode()
    -- handNode:setPosition(btnPosX,btnPosY+3)
    -- guideNode:addChild(handNode)
    -- guideNode:setTag(_type)

    -- local szContent=_type==1 and "点击可切换简洁界面" or "再次点击即可恢复"
    -- local noticNode=_G.GGuideManager:createNoticNode(szContent,false)
    -- noticNode:setPosition(btnPosX+200,btnPosY-50)
    -- guideNode:addChild(noticNode)
    self.m_headguideNode=guideNode
end

function MainView.isDouble(self,_value)
    self.value=_value
end

function MainView.artifactReturn(self)
	local _szMsg="器魂不足，是否前往玉清原始获取？"
	local function fun1()
		if _G.GOpenProxy : showSysNoOpenTips(_G.Const.CONST_FUNC_OPEN_WELKIN) then return false end
        _G.GLayerManager:openSubLayer(_G.Const.CONST_FUNC_OPEN_WELKIN)
	end
	if cc.Director:getInstance():getRunningScene():getChildByTag(290) then
		
	else
		local view=require("mod.general.TipsBox")()
		local layer=view:create(_szMsg,fun1)
		cc.Director:getInstance():getRunningScene():addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC)
		layer:setTag(290)
	end
end

return MainView