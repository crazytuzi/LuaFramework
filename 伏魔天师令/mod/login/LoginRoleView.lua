local LoginRoleView=classGc(view,function(self,_roleList,_isChuangeRole)
    _G.GLoginPoxy:setRoleMediator(self)
    self.m_winSize=cc.Director:getInstance():getWinSize()

    self._roleList=_roleList
    self.m_isChuangeRole=_isChuangeRole

    -- 显示界面
    self:create()
    self:initView()
end)

local TAG_BACK=1
local TAG_START=2
local TAG_TEST=3
local TAG_NAME=4
local TAG_LV=5

function LoginRoleView.destroy(self)
    _G.Util:initLog()
    self:releaseCharcter()

    if self.m_isChuangeRole then
        require("mod.login.LoginServerView")(true)
    else
        cc.Director:getInstance():popScene()
    end
    _G.GLoginPoxy:setRoleMediator(nil)
end

function LoginRoleView.create(self)
    _G.Util:initLog()
    self.m_scene=cc.Scene:create()

    local tempScene=cc.TransitionCrossFade:create(0.35,self.m_scene)
    cc.Director:getInstance():pushScene(tempScene)
end

function LoginRoleView.initView(self)
	self.m_effectsNode=cc.Node:create()
    self.m_effectsNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.m_scene:addChild(self.m_effectsNode)

    self.m_rootNode=cc.Node:create()
    self.m_rootNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.m_scene:addChild(self.m_rootNode)

    local bgSpr=cc.Sprite:create("ui/bg/bg_role_list.jpg")
    self.m_effectsNode:addChild(bgSpr)

    local upIcon=cc.Sprite:createWithSpriteFrameName("login_water.png")
    upIcon:setAnchorPoint(cc.p(0,1))
    upIcon:setPosition(cc.p(0,640))
    bgSpr:addChild(upIcon)

    local downIcon=cc.Sprite:createWithSpriteFrameName("login_water.png")
    downIcon:setFlippedY(true)
    downIcon:setAnchorPoint(cc.p(0,0))
    downIcon:setPosition(cc.p(0,0))
    bgSpr:addChild(downIcon)

    local parffect1=cc.ParticleSystemQuad:create("particle/NewParticle_1.plist")
    parffect1:setPosition(-188.5,77)
    self.m_effectsNode:addChild(parffect1)
    local parEffect2=cc.ParticleSystemQuad:create("particle/jueseyanwu_1.plist")
    parEffect2:setRotation(12)
    parEffect2:setPosition(-451.5,-182)
    self.m_effectsNode:addChild(parEffect2)
    local parEffect3=cc.ParticleSystemQuad:create("particle/jueseyanwu_1.plist")
    parEffect3:setPosition(-206.5,-177)
    self.m_effectsNode:addChild(parEffect3)

    _G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    local szName = "particle/login_bf_01"
    local m_spine=_G.SpineManager.createSpine(szName,1)
	m_spine:setPosition(0,-320)
	m_spine:setScale(-1,1)
	m_spine:setAnimation(0,"idle",true)
	self.m_effectsNode:addChild(m_spine)
	_G.SysInfo:resetTextureFormat()

    local function local_buttonCallBack(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local tag=sender:getTag()
            if tag==TAG_START or tag==TAG_TEST then
                print("local_buttonCallBack: TAG_START click!")
                
                local ret=self:connectServer()

                if ret~=1 then return end
                local function fun()
                    _G.Util:hideLoadCir()
                end
                sender:stopAllActions()
                performWithDelay(sender,fun,20)

                _G.GLoginPoxy:setFirstLogin(false)
                CCLOG(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())

                if TAG_TEST==tag then
                    self.isTestSocket=true
                else
                    self.isTestSocket=nil
                end
                
            elseif tag==TAG_BACK then
                print("local_buttonCallBack: TAG_BACK click!")
                self:destroy()
                _G.controller.m_isCanNotConnect=true
            end
        end
    end

    local backButton=gc.CButton:create("general_btn_back.png")
    backButton:setPosition(self.m_winSize.width/2-60,self.m_winSize.height/2-38)
    backButton:addTouchEventListener(local_buttonCallBack)
    backButton:setTag(TAG_BACK)
    local cBtnSize=backButton:getContentSize()
    backButton:ignoreContentAdaptWithSize(false)
    backButton:setContentSize(cc.size(cBtnSize.width+30,cBtnSize.height+30))
    self.m_rootNode:addChild(backButton)

    local startButton=gc.CButton:create("login_btn_lv.png")
    startButton:setPosition(self.m_winSize.width/2-150,-self.m_winSize.height/2+90)
    startButton:addTouchEventListener(local_buttonCallBack)
    startButton:setTag(TAG_START)
    --startButton:setTitleText("开 始")
	-- startButton:setTitleFontSize(24)
	-- startButton:setTitleFontName(_G.FontName.Heiti)
    self.m_rootNode:addChild(startButton)

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local uid=sender:getTag()
            print("ooasdssooo=========>>>",uid)
            if uid==0 then
                local createView=require("mod.login.LoginCreateView")()
                createView:init()
                return
            end
            self:selectThisRole(uid,sender)
        end
    end

    local newList=self._roleList
    self._roleList={}

    local nColor=_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_LBLUE)
    local bColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE)
    self.btnArr={}
    for i=1,3 do
        local tempBtn=gc.CButton:create("login_role_btn.png")
        local btnSize=tempBtn:getContentSize()
        tempBtn:addTouchEventListener(c)
        tempBtn:setPosition(-self.m_winSize.width/2+btnSize.width/2+35,250-btnSize.height*(i-0.5)-(i-1)*48)
        self.m_rootNode:addChild(tempBtn)
        
        local role=newList[i]
        if role then
        	self.btnArr[i]=tempBtn
            local iUid=tonumber(role.uid)
            local iPro=tonumber(role.pro)
            self._roleList[iUid]=role
            tempBtn:setTag(iUid)

            local szProImg=string.format("general_head_%d.png",iPro)
            local proSpr=cc.Sprite:createWithSpriteFrameName(szProImg)
            proSpr:setPosition(47,54)
            tempBtn:addChild(proSpr,10)

            -- string.format("%s(LV:%s)",role.uname,role.lv)
            local nameLabel=_G.Util:createLabel(role.uname,20)
            nameLabel:setPosition(btnSize.width/2+10,btnSize.height/2)
            -- nameLabel:setColor(nColor)
            nameLabel:setTag(TAG_NAME)
            tempBtn:addChild(nameLabel,10)

            local lvLable=_G.Util:createBorderLabel(string.format("LV.%d",role.lv),20,_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_BLACK))
            lvLable:setPosition(btnSize.width/2-100,btnSize.height/2-25)
            lvLable:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_WHITE))
            lvLable:setTag(TAG_LV)
            tempBtn:addChild(lvLable,11)

            if i==1 then
                self:selectThisRole(iUid,tempBtn)
            end
        else
            tempBtn:setTag(0)

            local addSpr=cc.Sprite:createWithSpriteFrameName("general_btn_add.png")
            addSpr:setPosition(47,54)
            addSpr:setScale(2)
            tempBtn:addChild(addSpr,10)

            local noticLabel=_G.Util:createLabel("创建新角色",20)
            noticLabel:setPosition(btnSize.width/2+10,btnSize.height/2)
            -- noticLabel:setColor(nColor)
            tempBtn:addChild(noticLabel,10)
        end
    end
end

function LoginRoleView.releaseCharcter(self)
    print("LoginRoleView.releaseCharcter=========>>>>>>>",self.m_myPlayer)
    if self.m_myPlayer~=nil then
        self.m_myPlayer:releaseResource()
        self.m_myPlayer=nil
    end
    if self.m_myPlayerScheduler~=nil then
        _G.Scheduler:unschedule(self.m_myPlayerScheduler)
        self.m_myPlayerScheduler=nil
    end
end

function LoginRoleView.selectThisRole(self,_iUid,_sender)
    if self.m_curRoleId==_iUid then return end
    
    local roleData=self._roleList[_iUid]
    _G.GLoginPoxy:setUid(_iUid)
    if roleData~=nil then
        self.m_curRoleId=_iUid
        self:releaseCharcter()

        local node = cc.Node:create()
        node:setPosition(-70,-240)
        self.m_effectsNode:addChild(node)

        local skin =10000+tonumber(roleData.pro)
        local stage = require "mod.map.Stage"()
        stage.m_isCity=true
        stage.m_lpCharacterContainer=node
        self.m_myPlayer = CPlayer( _G.Const.CONST_MONSTER)
        self.m_myPlayer:releaseSkillResource()
        self.m_myPlayer.m_isShowState=true
        self.m_myPlayer.m_stageView = stage
    	local newproperty= require("mod.support.Property")()
    	newproperty.attr=require("mod.support.PropertyWar")()
    	self.m_myPlayer : setProperty(newproperty)
        self.m_myPlayer : playerInit( 0, "", roleData.pro, 0, skin, 0, 0, 0, 0)
        self.m_myPlayer : init( 0 , "", 0, 0, 100, 100, x, y, skin)
        self.m_myPlayer : setScalePer(1.5)
        node:addChild(self.m_myPlayer.m_lpContainer)

        local function b(  )
            local i = math.ceil(gc.MathGc:random_0_1()*2)
            self.m_myPlayer :useSkill(_G.Cfg.player_init[tonumber(roleData.pro)].login_skill[i])
            local function c()
                i = i%2
                i = i+1
                self.m_myPlayer :useSkill(_G.Cfg.player_init[tonumber(roleData.pro)].login_skill[i])
            end
            local delay = cc.DelayTime:create(5)
            local sequence = cc.Sequence:create(delay, cc.CallFunc:create(c))
            self.m_myPlayer.m_lpContainer:runAction(cc.RepeatForever:create(sequence))
            
            local name={"_1","_2","_3"}
            local i = math.ceil(gc.MathGc:random_0_1()*3)
            local szMp3=string.format("create_pro%d%s",roleData.pro,name[i])
            _G.Util:playAudioEffect(szMp3,nil,true)

        end
        cc.SimpleAudioEngine:getInstance():stopAllEffects()
        performWithDelay(self.m_myPlayer.m_lpContainer,b,1)

		
        local function nUpdate(_t)
            self.m_myPlayer:onUpdateSkillEffectObject(_t)
        end
        self.m_myPlayerScheduler=_G.Scheduler:schedule(nUpdate,0.25)

        if self.m_selectSpr==nil then
            local btnSize=_sender:getContentSize()
            self.m_selectSpr=cc.Sprite:createWithSpriteFrameName("login_role_btn_p.png")
            self.m_selectSpr:setPosition(47,54)
            _sender:addChild(self.m_selectSpr)
        else
            self.m_selectSpr:retain()
            self.m_selectSpr:removeFromParent(false)
            _sender:addChild(self.m_selectSpr)
            self.m_selectSpr:release()
        end
    end
end

function LoginRoleView.connectServer(self)
    local serverData=_G.GLoginPoxy:getCurServerData()
    local szIp=serverData.i
    local szPort=serverData.p

    local netWork=_G.Network
    if netWork:isConnected() then
        print("LoginRoleView.connectServer=====>>>>isConnected=true")
        netWork:disconnect()
    end

    local ret=netWork:connect(szIp,szPort)
    if ret==1 then
        self:sendLoginMsg()
    else
        _G.Util:showTipsBox("连接失败,服务器没有打开!")
    end
    
    return ret
end

function LoginRoleView.sendLoginMsg(self)
    local iUid=_G.GLoginPoxy:getUid()
    local roleData=self._roleList[iUid]
    local msg=REQ_ROLE_LOGIN()
    msg.uid=iUid -- {用户ID}
    msg.uuid=_G.SysInfo:getUuid()  -- {用户UUID}
    msg.sid=_G.GLoginPoxy:getServerId()  -- {用户SID}
    msg.cid=_G.SysInfo:getCID()  -- {用户CID}
    msg.os=_G.SysInfo:getOS()  -- {系统}
    msg.pwd=roleData.pwd
    msg.versions=tonumber(_G.SysInfo.m_versionRes)  -- {版本号}
    msg.fcm_init=0  -- {防沉迷(0:已解除 n>0:已在线时长)}
    msg.relink=false  -- {登录类型（true:短线重连 false:正常登录）}
    msg.hide=true
    msg.debug=false  -- {是否调试 （web:false fb:true）}
    msg.login_time=roleData.login_time  -- {时间}
    _G.Network:send(msg)

    _G.Util:showLoadCir()

    self.m_isLogin=true
end

return LoginRoleView