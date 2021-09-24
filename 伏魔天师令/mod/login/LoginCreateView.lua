local LoginCreateView=classGc(view,function(self)
    _G.GLoginPoxy:setCreateMediator(self)
    self.m_winSize=cc.Director:getInstance():getWinSize()
end)

local TAG_DICE=1
local TAG_BACK=2
local TAG_CREATE=3

local PRO_ARRAY=_G.SysInfo:isIpNetwork() and {[1]=true,[2]=true,[3]=true,[4]=true} or {[1]=true,[2]=true,[3]=true}

function LoginCreateView.destroy(self)
    _G.Util:initLog()
    cc.Director:getInstance():popScene()
    _G.GLoginPoxy:setCreateMediator(nil)
    _G.Network:disconnect()
    _G.GLoginPoxy:setUid(self.m_preUid)
end

function LoginCreateView.init(self,_roleList)
    -- 显示界面
    self:create()
    self:httpRequestUID()
    self:initView()

    self.m_preUid=_G.GLoginPoxy:getUid()
end

function LoginCreateView.create(self)
    _G.Util:initLog()
    self.m_scene=cc.Scene:create()
    local tempScene=cc.TransitionCrossFade:create(0.35,self.m_scene)
    cc.Director:getInstance():pushScene(tempScene)
end

function LoginCreateView.initView(self)
	-- self.m_rootNode=cc.Node:create()
 --    self.m_rootNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
 --    self.m_scene:addChild(self.m_rootNode)
    
    self.m_rootNode=cc.Node:create()
    self.m_rootNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2)
    self.m_scene:addChild(self.m_rootNode)
    local bgSpine=cc.Sprite:create("ui/bg/bg_role_list.jpg")
    self.m_rootNode:addChild(bgSpine)

    local upIcon=cc.Sprite:createWithSpriteFrameName("login_water.png")
    upIcon:setAnchorPoint(cc.p(0,1))
    upIcon:setPosition(cc.p(0,640))
    bgSpine:addChild(upIcon)

    local downIcon=cc.Sprite:createWithSpriteFrameName("login_water.png")
    downIcon:setFlippedY(true)
    downIcon:setAnchorPoint(cc.p(0,0))
    downIcon:setPosition(cc.p(0,0))
    bgSpine:addChild(downIcon)

    local parffect1=cc.ParticleSystemQuad:create("particle/NewParticle_1.plist")
    parffect1:setPosition(-188.5,77)
    self.m_rootNode:addChild(parffect1)
    local parEffect2=cc.ParticleSystemQuad:create("particle/jueseyanwu_1.plist")
    parEffect2:setRotation(12)
    parEffect2:setPosition(-451.5,-182)
    self.m_rootNode:addChild(parEffect2)
    local parEffect3=cc.ParticleSystemQuad:create("particle/jueseyanwu_1.plist")
    parEffect3:setPosition(-206.5,-177)
    self.m_rootNode:addChild(parEffect3)

    _G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    local szName = "particle/login_bf_01"
    local m_spine=_G.SpineManager.createSpine(szName,1)
	m_spine:setPosition(0,-320)
	m_spine:setScale(-1,1)
	m_spine:setAnimation(0,"idle",true)
	self.m_rootNode:addChild(m_spine)
	_G.SysInfo:resetTextureFormat()
end

function LoginCreateView.registEvent(self)
	
    self.m_rightSize=cc.size(300,580)

    self.m_leftSpr=cc.Sprite:createWithSpriteFrameName("login_create_line.png")
    -- self.m_leftSpr:setPreferredSize(self.m_leftSize)
    self.m_leftSpr:setAnchorPoint(cc.p(0,0.5))
    self.m_leftSpr:setPosition(-self.m_winSize.width/2 + 80,30)
    -- self.m_leftSpr:setOpacity(0.7*255)
    self.m_rootNode:addChild(self.m_leftSpr)

    self.m_leftSize=self.m_leftSpr:getContentSize()

    self.m_rightSpr=cc.Node:create()
    self.m_rightSpr:setPosition(self.m_winSize.width*0.5 - self.m_rightSize.width - 50,-300)
    self.m_rootNode:addChild(self.m_rightSpr)

    local dins1 =cc.Sprite:createWithSpriteFrameName("login_role_base.png")
    -- dins1:setPreferredSize(cc.size(self.m_rightSize.width,62))
    dins1:setPosition(cc.p(self.m_rightSize.width/2+20,self.m_rightSize.height/2+70))
    self.m_rightSpr:addChild(dins1,1)
    
    local function fun1(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local tag=sender:getTag()
            if tag==TAG_CREATE then
                print("fun1: TAG_CREATE click!")
                self:sendCreateMsg()

                local function fun()
                    _G.Util:hideLoadCir()
                end
                sender:stopAllActions()
                performWithDelay(sender,fun,5)
                _G.GLoginPoxy:setFirstLogin(true)
            elseif tag==TAG_BACK then
                print("fun1: TAG_BACK click!")
                self:destroy()
            elseif tag==TAG_DICE then
                print("fun1: TAG_DICE click!")
                self:sendRoleNameMsg()
            end
        end
    end

    local backButton=gc.CButton:create()
    backButton:loadTextures("general_btn_back.png")
    backButton:setPosition(self.m_rightSize.width+15,self.m_rightSize.height)
    backButton:addTouchEventListener(fun1)
    backButton:setTag(TAG_BACK)
    local cBtnSize=backButton:getContentSize()
    backButton:ignoreContentAdaptWithSize(false)
    backButton:setContentSize(cc.size(cBtnSize.width+30,cBtnSize.height+30))
    self.m_rightSpr:addChild(backButton,1)

    -- 
    local nPosY=-260
    local nPosX=-30
    local textBgSize=cc.size(145,38)
    local fieldSize=cc.size(135,30)
    local nameTips=cc.Sprite:createWithSpriteFrameName("login_name.png")
    nameTips:setAnchorPoint(cc.p(0,0.5))
    nameTips:setPosition(cc.p(0,118))
    self.m_rightSpr:addChild(nameTips,2)

    local textBg=ccui.Scale9Sprite:createWithSpriteFrameName("login_namekuang.png",cc.rect(20,20,1,1))
    self.m_fieldRoleName=ccui.EditBox:create(textBgSize,textBg)
    self.m_fieldRoleName:setFont(_G.FontName.Heiti,20)
    self.m_fieldRoleName:setInputMode(6)
    self.m_fieldRoleName:setMaxLength(6)
    self.m_fieldRoleName:setPlaceHolder("角色名")
    self.m_fieldRoleName:setPlaceholderFont(_G.FontName.Heiti,20)
    self.m_fieldRoleName:setPosition(self.m_rightSize.width/2+40,118)
    self.m_fieldRoleName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self.m_rightSpr:addChild(self.m_fieldRoleName,2)

    local createButton=gc.CButton:create("login_btn_role.png")
    createButton:setPosition(self.m_rightSize.width*0.5+20,50)
    createButton:addTouchEventListener(fun1)
    createButton:setTag(TAG_CREATE)
    -- createButton:setTitleText("创 建")
	-- createButton:setTitleFontSize(24)
	-- createButton:setTitleFontName(_G.FontName.Heiti)
    self.m_rightSpr:addChild(createButton,1)

    local diceButton=gc.CButton:create()
    diceButton:loadTextures("login_dice.png")
    diceButton:setPosition(self.m_rightSize.width-5,118)
    diceButton:addTouchEventListener(fun1)
    diceButton:setTag(TAG_DICE)
    self.m_rightSpr:addChild(diceButton,2)

    -- 各个职业按钮
    local function fun2(sender, eventType)
        if eventType~=ccui.TouchEventType.ended then
            if not self.m_isDefaultOK then return end

            local pro=sender:getTag()
            local Position=sender:getPosition()
            if pro==0 or pro == 6 or pro == 7 then
                print( "pro1 = ", pro )
                return
            end
            print( "pro2 = ", pro )
            --for k,v in pairs(self.buttonArray) do
            --	v:loadTextures(string.format("login_icon_%d.png",k))
            --end
            --sender:loadTextures(string.format("login_icon_select_%d.png",pro))
            self:selectThisPro(pro)
            -- self.selectIcon:setPosition(Position.x-1.5,Position.y+2)
        end
    end

    local proCount=4
    local oneHeight=self.m_leftSize.height/3.3

    --self.buttonArray = {}
    local posX={self.m_leftSize.width/2+20,self.m_leftSize.width/2-35,
                self.m_leftSize.width/2-40,self.m_leftSize.width/2+20}
    self.selectPoint = {}
    for i=1,proCount do
        local nHeight=(proCount-i)*oneHeight
        local iconkuang=cc.Sprite:createWithSpriteFrameName("login_create_kuang.png")
        iconkuang:setPosition(posX[i],nHeight)
        self.m_leftSpr:addChild(iconkuang)

        local tag=i
        local szImg=string.format("general_head_%d.png",tag)
    	if not PRO_ARRAY[i] then
            local titleLab1=_G.Util:createLabel("新职业",18)
            titleLab1:setPosition(49,70)
            iconkuang:addChild(titleLab1)

            local titleLab2=_G.Util:createLabel("敬请期待",18)
            titleLab2:setPosition(49,45)
            iconkuang:addChild(titleLab2)
    	else
            self.selectPoint[tag] = cc.p(posX[i],nHeight)

            local proButton=gc.CButton:create()
            proButton:loadTextures(szImg)
            --proButton:setPosition(0,nHeight)
            proButton:setPosition(47,54)
            proButton:addTouchEventListener(fun2)
            proButton:setTag(tag)
            iconkuang:addChild(proButton)
            --self.buttonArray[tag] = proButton

            if i==3 then
                local titleLab1=_G.Util:createLabel("40级",18)
                titleLab1:setPosition(49,70)
                iconkuang:addChild(titleLab1)

                local titleLab2=_G.Util:createLabel("可转职",18)
                titleLab2:setPosition(49,45)
                iconkuang:addChild(titleLab2)
            end
        end
    end

    self.selectIcon=cc.Sprite:createWithSpriteFrameName("login_role_btn_p.png")
    self.m_leftSpr:addChild(self.selectIcon)
    self.selectIcon:setVisible(false)

    self.m_filterLabel=_G.Util:createLabel("",10)
    self.m_rootNode:addChild(self.m_filterLabel)
end

function LoginCreateView.httpRequestUID(self)
    local sid = _G.GLoginPoxy:getServerId()
    local szUrl = _G.SysInfo:urlRoleCreate(sid)
    local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("GET", szUrl)

    print("ooooooo---????>>>>>",szUrl)

    local function tipsSure()
        self:httpRequestUID()
    end
    local function http_handler()
        self:registEvent()
        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
            local response = xhrRequest.response
            print("http_handler response="..response)
            local output = json.decode(response,1)
            if output.ref==1 then
                self.m_roleUidData=output
                self:connectServer()
            else
                _G.Util:showTipsBox(string.format("获取UID失败:%s(%d)",output.msg,output.error),tipsSure)
            end
        else
            _G.Util:showTipsBox(string.format("HTTP请求失败:state:%d,code=%d",xhrRequest.readyState,xhrRequest.status),tipsSure)
        end
    end

    xhrRequest:registerScriptHandler(http_handler)
    xhrRequest:send()
end

function LoginCreateView.connectServer(self)
    local serverData=_G.GLoginPoxy:getCurServerData()
    local szIp=serverData.i
    local szPort=serverData.p

    local netWork=_G.Network
    if netWork:isConnected() then
        netWork:disconnect()
    end

    _G.GLoginPoxy:setUid(tonumber(self.m_roleUidData.uid))
    
    local ret=netWork:connect(szIp,szPort)
    if ret==1 then
        self:sendLoginMsg()
    else
        local function nFun()
            self:destroy()
        end
        _G.Util:showTipsBox("连接失败,服务器没有打开!",nFun,nFun)
    end
end
function LoginCreateView.connectServerAgain(self)
    if self.m_waitToConnectScheduler then return end

    _G.Util:showLoadCir()

    local netWork=_G.Network
    if netWork:isConnected() then
        netWork:disconnect()
    end

    local function nFun()
        self:connectServer()
        self.m_waitToConnectScheduler=nil
    end
    self.m_waitToConnectScheduler=_G.Scheduler:performWithDelay(0.1,nFun)
end

function LoginCreateView.sendCreateMsg(self)
    local szName=self.m_fieldRoleName:getText()
    szName=string.gsub(szName," ","")

    if szName=="" then
        local command = CErrorBoxCommand("名字不能为空!")
   	    controller : sendCommand( command )
        return
    end

    if self.m_filterLabel.isHasUnDefineChar then
        local isNameHasUndefineChar=self.m_filterLabel:isHasUnDefineChar(szName)
        if isNameHasUndefineChar then
            local command=CErrorBoxCommand("角色名不能含有表情或特殊符号")
            _G.controller:sendCommand(command)
            return
        end
    end
    

    self.m_wordFilter=self.m_wordFilter or require("util.WordFilter")

    if not self.m_wordFilter:checkName(szName) then
        return
    end

    if not _G.Network:isConnected() then
        _G.Util:showTipsBox("连接失败,服务器已断开!")
        return
    end

    local msg = REQ_ROLE_CREATE()
    msg.uid = self.m_roleUidData.uid  -- {用户ID    }
    msg.uuid = _G.SysInfo:getUuid()  -- {用户UUID}
    msg.sid = _G.GLoginPoxy:getServerId()  -- {服务器ID}
    msg.cid = _G.SysInfo:getCID()  -- {合作方ID}
    msg.os = _G.SysInfo:getOS()  -- {客户端类型(见:CONST_CLIENT_*)}
    msg.versions = tonumber(_G.SysInfo.m_versionRes)  -- {版本号}
    msg.uname = szName  -- {用户名}
    msg.sex = self:getSex()  -- {性别}
    msg.pro = self.m_iPro  -- self.m_iPro  -- {职业}
    msg.source = "0"  -- {来源渠道}
    msg.source_sub = "0"  -- {子渠道}
    msg.login_time = self.m_roleUidData.login_time  -- {登陆时间}
    msg.ext1 = 1  -- {扩展一}
    msg.ext2 = 1  -- {扩展二}

    for i,v in pairs(msg) do
        print("aaaaaaaaaaa"..i,v)
    end

    _G.Network:send(msg)

    _G.Util:showLoadCir()
end

function LoginCreateView.sendLoginMsg(self)
    local msg=REQ_ROLE_LOGIN()
    msg.uid=self.m_roleUidData.uid -- {用户ID}
    msg.uuid=_G.SysInfo:getUuid()  -- {用户UUID}
    msg.sid=_G.GLoginPoxy:getServerId()  -- {用户SID}
    msg.cid=_G.SysInfo:getCID()  -- {用户CID}
    msg.os=_G.SysInfo:getOS()  -- {系统}
    msg.pwd=self.m_roleUidData.pwd
    msg.versions=tonumber(_G.SysInfo.m_versionRes)  -- {版本号}
    msg.fcm_init=0  -- {防沉迷(0:已解除 n>0:已在线时长)}
    msg.relink=false  -- {登录类型（true:短线重连 false:正常登录）}
    msg.hide=true
    msg.debug=false  -- {是否调试 （web:false fb:true）}
    msg.login_time=self.m_roleUidData.login_time  -- {时间}
    _G.Network:send(msg)

    _G.Util:showLoadCir()
end

function LoginCreateView.sendRoleNameMsg(self)
    local msg=REQ_ROLE_RAND_NAME()
    msg:setArgs(self:getSex())
    _G.Network:send(msg)
end

function LoginCreateView.ackDefaultPro(self,_iPro)
    if self.m_isDefaultOK then return end
    self.m_isDefaultOK=true
    self:selectThisPro(_iPro)
end

function LoginCreateView.releaseCharcter(self)
    if self.m_myPlayer~=nil then
        self.m_myPlayer:releaseResource()
        self.m_myPlayer=nil
    end
    if self.m_myPlayerScheduler~=nil then
        _G.Scheduler:unschedule(self.m_myPlayerScheduler)
        self.m_myPlayerScheduler=nil
    end
end


function LoginCreateView.selectThisPro(self,_iPro)
    if self.m_iPro==_iPro then return end
    _iPro=PRO_ARRAY[_iPro] and _iPro or 1

    self.m_iPro=_iPro
    self:sendRoleNameMsg()
    
    self.selectIcon:setPosition(self.selectPoint[_iPro].x-1.5,self.selectPoint[_iPro].y+2)
    self.selectIcon:setVisible(true)

    self:releaseCharcter()

    local node=cc.Node:create()
    node:setPosition(-70,-240)
    self.m_rootNode:addChild(node)

    local skin = 10000+tonumber(_iPro)
    local stage = require "mod.map.Stage"()
    stage.m_isCity=true
    self.m_myPlayer = CPlayer( _G.Const.CONST_MONSTER)
    self.m_myPlayer.m_isShowState=true
    self.m_myPlayer.m_stageView =stage
    stage.m_lpCharacterContainer=node
	local newproperty= require("mod.support.Property")()
	newproperty.attr=require("mod.support.PropertyWar")()
	self.m_myPlayer : setProperty(newproperty)
    self.m_myPlayer : playerInit( 0, "", _iPro, 0, skin, 0, 0, 0, 0)
    self.m_myPlayer : init( 0 , "", 0, 0, 100, 100, x, y, skin)
    self.m_myPlayer : setScalePer(1.5)
    node:addChild(self.m_myPlayer.m_lpContainer)

    local function b()
        local i = math.ceil(gc.MathGc:random_0_1()*2)
        self.m_myPlayer :useSkill(_G.Cfg.player_init[tonumber(_iPro)].login_skill[i])
        local function c()
            i = i%2
            i = i+1
            self.m_myPlayer :useSkill(_G.Cfg.player_init[tonumber(_iPro)].login_skill[i])
        end
        local delay = cc.DelayTime:create(3)
        local sequence = cc.Sequence:create(delay, cc.CallFunc:create(c))
        self.m_myPlayer.m_lpContainer:runAction(cc.RepeatForever:create(sequence))
        
        local name={"_1","_2","_3"}
        local i = math.ceil(gc.MathGc:random_0_1()*3)
        local szMp3=string.format("create_pro%d%s",_iPro,name[i])
        _G.Util:playAudioEffect(szMp3,nil,true)
    end
    cc.SimpleAudioEngine:getInstance():stopAllEffects()
    performWithDelay(self.m_myPlayer.m_lpContainer,b,1)

    local function nUpdate(_t)
        self.m_myPlayer:onUpdateSkillEffectObject(_t)
    end
    self.m_myPlayerScheduler=_G.Scheduler:schedule(nUpdate,0.25)

    local szProperty=string.format("login_pro_property_%d.png",_iPro)
    local szName=string.format("login_pro_name_%d.png",_iPro)
    --self.m_infoLabel:setString(_G.Cfg.player_init[_iPro].describe)

    if self.m_nameSpr~=nil then
        self.m_nameSpr:removeFromParent(true)
        self.m_nameSpr=nil
    end

    self.m_nameSpr=cc.Sprite:createWithSpriteFrameName(szName)
    -- self.m_nameSpr:setAnchorPoint(cc.p(0.5,1))
    self.m_nameSpr:setPosition(self.m_rightSize.width/2+20,self.m_rightSize.height-67)
    self.m_rightSpr:addChild(self.m_nameSpr,1)

    if self.titleLab~=nil then
        self.titleLab:removeFromParent(true)
        self.titleLab=nil
    end

    local content=string.format("        %s",_G.Cfg.player_init[_iPro].describe)
    self.titleLab=_G.Util:createLabel(content,22)
    self.titleLab:setPosition(self.m_rightSize.width/2-110,self.m_rightSize.height-167)
    self.titleLab:setDimensions(self.m_rightSize.width-20, 110)
    self.titleLab:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    self.titleLab:setAnchorPoint( cc.p(0.0,0.5) )
    self.m_rightSpr:addChild(self.titleLab)

    if self.attrStarNode~=nil then
        self.attrStarNode:removeFromParent(true)
        self.attrStarNode=nil
    end
    self.attrStarNode=cc.Node:create()
    self.attrStarNode:setPosition(self.m_rightSize.width/2-90,self.m_rightSize.height/2-100)
    self.m_rightSpr:addChild(self.attrStarNode,1)

    local attrName={"攻击","防御","命中","闪避","暴击"}
    local attrHeight=135
    for i=1,5 do
        local attrLab=_G.Util:createLabel(attrName[i],20)
        attrLab:setPosition(self.m_rightSize.width/2-145,attrHeight)
        attrLab:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORANGE))
        self.attrStarNode:addChild(attrLab)

        local count=_G.Cfg.player_init[_iPro].shuxing[i]
        for m=1,count do
            local starSpr=cc.Sprite:createWithSpriteFrameName("general_star2.png")
            starSpr:setPosition(5+m*40,attrHeight)
            self.attrStarNode:addChild(starSpr)
        end

        attrHeight=attrHeight-31
    end
end
function LoginCreateView.getSex(self)
    if self.m_iPro==_G.Const.CONST_PRO_SUNMAN or self.m_iPro==_G.Const.CONST_PRO_BIGSISTER then
        return _G.Const.CONST_SEX_MM
    else
        return _G.Const.CONST_SEX_GG
    end
end

function LoginCreateView.ackRoleName(self,_szName)
    self.m_fieldRoleName:setText(_szName)
end

return LoginCreateView