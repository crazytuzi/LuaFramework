local LoginView=classGc(view,function(self,_successFun)
    self.m_successFun=_successFun
    self.m_winSize=cc.Director:getInstance():getWinSize()
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/ui_login.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/ui_login32.plist")
end)

function LoginView.init(self)
    self:registEvent()
end

function LoginView.create(self)
    self.m_rootLayer=cc.Layer:create()
    local act2=cc.ScaleTo:create(0.2,1.04)
    local act3=cc.ScaleTo:create(0.1,0.98)
    local act4=cc.ScaleTo:create(0.05,1)
    self.m_rootLayer:setScale(0.9)
    self.m_rootLayer:runAction(cc.Sequence:create(act2,act3,act4))

    self:init()
    return self.m_rootLayer
end

function LoginView.registEvent(self)
    self.m_loginNode=cc.Node:create()
    self.m_loginNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2+20)
    self.m_rootLayer:addChild(self.m_loginNode,1)
    
    local tempBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    tempBg:setPreferredSize(cc.size(500,300))
    self.m_loginNode:addChild(tempBg)

    local name_button_service = "btn_service"
    local name_button_regist  = "btn_regist"
    local name_button_login   = "Button_1"
    local name_box_remember   = "CheckBox_1"

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local btnName=sender:getName()
            if btnName==name_button_service then
                print("name_button_service  click!!")
            elseif btnName==name_button_regist then
                print("name_button_regist  click!!")
                self:showRegistView()
            elseif btnName==name_button_login then
                print("name_button_login  click!!")
                self:httpLogin()
            elseif btnName==name_box_remember then
                if not sender:isSelected() then
                    print("name_box_remember  click!!   YES")
                    cc.UserDefault:getInstance():setStringForKey("normal_check", "YES")
                else
                    print("name_box_remember  click!!   NO")
                    cc.UserDefault:getInstance():setStringForKey("normal_check", "NO")
                end
            end
        end
    end

    local fontName=_G.FontName.Heiti
    local nPosx1=-130

    local textBgSize=cc.size(247,47)
    local fieldSize=cc.size(235,27)
    local fColor=_G.ColorUtil:getFloatRGBA(_G.Const.CONST_COLOR_WHITE)
    local nPosY,titleLabel,textBg,textField,textBtn

    -- 用户名
    nPosY=90
    titleLabel=_G.Util:createBorderLabel("用户名:",24)
    titleLabel:setAnchorPoint(cc.p(1,0.5))
    titleLabel:setPosition(nPosx1,nPosY)
    -- titleLabel:setColor(_G.ColorUtil:getRGB(_G.Const.CONST_COLOR_ORANGE))
    self.m_loginNode:addChild(titleLabel)

    textBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_input_box.png")
    self._editName=ccui.EditBox:create(textBgSize,textBg)
    self._editName:setPosition(nPosx1+textBgSize.width/2+5,nPosY)
    self._editName:setFont(fontName,20)
    self._editName:setPlaceholderFont(fontName,20)
    self._editName:setPlaceHolder("请输入帐号")
    self._editName:setMaxLength(10)
    self._editName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editName:setInputMode(6)
    self.m_loginNode:addChild(self._editName)

    local mmfwLabel=_G.Util:createBorderLabel("密码服务",24)
    local mmfwSize=mmfwLabel:getContentSize()
    mmfwLabel:setPosition(mmfwSize.width*0.5,mmfwSize.height*0.5)
    textBtn=ccui.Widget:create()
    textBtn:setContentSize(mmfwSize)
    textBtn:setAnchorPoint(cc.p(0,0.5))
    textBtn:setPosition(nPosx1+15+textBgSize.width,nPosY)
    textBtn:addTouchEventListener(c)
    textBtn:setName(name_button_service)
    textBtn:addChild(mmfwLabel)
    textBtn:setTouchEnabled(true)
    self.m_loginNode:addChild(textBtn)
    local lineNode=cc.DrawNode:create()--绘制线条
    lineNode:drawLine(cc.p(0,1),cc.p(mmfwSize.width,1),fColor)
    lineNode:setPosition(0,-3)
    textBtn:addChild(lineNode,2)

    -- 密码
    nPosY=30
    titleLabel=_G.Util:createBorderLabel("密 码:",24)
    titleLabel:setAnchorPoint(cc.p(1,0.5))
    titleLabel:setPosition(nPosx1,nPosY)
    self.m_loginNode:addChild(titleLabel)

    textBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_input_box.png")
    self._editPass=ccui.EditBox:create(textBgSize,textBg)
    self._editPass:setPosition(nPosx1+textBgSize.width/2+5,nPosY)
    self._editPass:setFont(fontName,20)
    self._editPass:setPlaceholderFont(fontName,20)
    self._editPass:setPlaceHolder("请输入密码")
    self._editPass:setMaxLength(10)
    self._editPass:setInputMode(6)
    self._editPass:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editPass:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self.m_loginNode:addChild(self._editPass)

    local zczhLabel=_G.Util:createBorderLabel("注册帐号",24)
    local zczhSize=zczhLabel:getContentSize()
    zczhLabel:setPosition(zczhSize.width*0.5,zczhSize.height*0.5)
    textBtn=ccui.Widget:create()
    textBtn:setContentSize(zczhSize)
    textBtn:setAnchorPoint(cc.p(0,0.5))
    textBtn:setPosition(nPosx1+15+textBgSize.width,nPosY)
    textBtn:addTouchEventListener(c)
    textBtn:setName(name_button_regist)
    textBtn:setTouchEnabled(true)
    textBtn:addChild(zczhLabel)
    self.m_loginNode:addChild(textBtn)
    local lineNode=cc.DrawNode:create()--绘制线条
    lineNode:drawLine(cc.p(0,1),cc.p(zczhSize.width,1),fColor)
    lineNode:setPosition(0,-3)
    textBtn:addChild(lineNode,2)

    local checkPos=cc.p(-37,-35)
    local checkbox=ccui.CheckBox:create()
    checkbox:setTouchEnabled(true)
    checkbox:loadTextures("general_check_cancel.png","general_check_cancel.png","general_check_selected.png","","",ccui.TextureResType.plistType)
    checkbox:setPosition(checkPos)
    checkbox:setScale(0.7)
    checkbox:setName(name_box_remember)
    checkbox:addTouchEventListener(c)
    checkbox:setAnchorPoint(cc.p(1,0.5))
    self.m_loginNode:addChild(checkbox)
    self._boxRemember=checkbox

    local checkLabel=_G.Util:createLabel("记住帐号",20)
    checkLabel:setAnchorPoint(cc.p(0,0.5))
    checkLabel:setPosition(checkPos.x+3,checkPos.y)
    self.m_loginNode:addChild(checkLabel)
    self.m_checkLabel=checkLabel

    nPosY=-105
    local button=gc.CButton:create("general_btn_lv.png")
    button:setPosition(cc.p(0,nPosY))
    button:addTouchEventListener(c)
    button:setName(name_button_login)
    button:setTitleFontName(_G.FontName.Heiti)
    button:setTitleFontSize(24)
    button:setTitleText("登 录")
    self.m_loginNode:addChild(button)

    local default_name = cc.UserDefault:getInstance():getStringForKey("normal_name", "")
    local default_pass = cc.UserDefault:getInstance():getStringForKey("normal_pass", "")
    local default_check = cc.UserDefault:getInstance():getStringForKey("normal_check", "NO")
    if default_check=="NO" then
        self._boxRemember:setSelected(false)
    else
        self._boxRemember:setSelected(true)
    end
    if default_name~="" and default_pass~="" then
        self._editName:setText(default_name)
        self._editPass:setText(default_pass)
    end

    if _G.SysInfo:isIpNetwork() then
        local function nFun(sender,eventType)
            if eventType==ccui.TouchEventType.ended then
                self:__showNetWorkView()
            end
        end
        self.m_netWorkTypeBtn=gc.CButton:create("general_base.png")
        local btnSize=self.m_netWorkTypeBtn:getContentSize()
        self.m_netWorkTypeBtn:addTouchEventListener(nFun)
        self.m_netWorkTypeBtn:setPosition(self.m_winSize.width-btnSize.width*0.5-15,640-btnSize.height*0.5-15)
        self.m_netWorkTypeBtn:setTitleFontName(_G.FontName.Heiti)
        self.m_netWorkTypeBtn:setTitleFontSize(16)
        self.m_netWorkTypeBtn:setTitleText("网络")
        self.m_netWorkTypeBtn:setButtonScale(1.4)
        self.m_rootLayer:addChild(self.m_netWorkTypeBtn,10)
    end
end

function LoginView.hideLoginView(self)
    self.m_loginNode:setVisible(false)
end
function LoginView.showLoginView(self)
    self.m_loginNode:setVisible(true)
end
function LoginView.hideRegistView(self)
    if self.m_registNode~=nil then
        self.m_registNode:removeFromParent(true)
        self.m_registNode=nil
    end
    self:showLoginView()
end
function LoginView.showRegistView(self)
    self:hideLoginView()

    if self.m_registNode~=nil then return end

    local registView=require("mod.login.RegistView")(self)
    self.m_registNode=registView:create()
    self.m_rootLayer:addChild(self.m_registNode,1)
end

function LoginView.httpLogin(self)
    local szName=self._editName:getText()
    local szPass=self._editPass:getText()
    if szName=="" or szPass=="" then
        local command=CErrorBoxCommand("帐号或密码不能为空")
        _G.controller:sendCommand(command)
        return
    end

    if self.m_checkLabel.isHasUnDefineChar then
        local isNameHasUndefineChar=self.m_checkLabel:isHasUnDefineChar(szName)
        if isNameHasUndefineChar then
            local command=CErrorBoxCommand("用户名不能含有表情或特殊符号")
            _G.controller:sendCommand(command)
            return
        end

        local isPassHasUndefineChar=self.m_checkLabel:isHasUnDefineChar(szPass)
        if isPassHasUndefineChar then
            local command=CErrorBoxCommand("密码不能含有表情或特殊符号")
            _G.controller:sendCommand(command)
            return
        end
    end

    local default_check = cc.UserDefault:getInstance():getStringForKey("normal_check", "NO")
    if default_check=="YES" then
        cc.UserDefault:getInstance():setStringForKey("normal_name", szName)
        cc.UserDefault:getInstance():setStringForKey("normal_pass", szPass)
    else
        cc.UserDefault:getInstance():setStringForKey("normal_name", "")
        cc.UserDefault:getInstance():setStringForKey("normal_pass", "")
    end

    local szUrl = string.format("%s?%s",_G.SysInfo:urlAppLogin(),_G.SysInfo:urlAppLoginSignData(szName,szPass))
    -- print("bbnbnbnbnbbnbnbnb---:>>szUrl=",szUrl)
    local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("POST", szUrl)

    local function http_login_handler()
        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
            local response = xhrRequest.response
            print("http_login_handler response="..response)
            local output   = json.decode(response,1)

            if output.ref==1 then
                local uuid=output.uuid
                self:gotoServerScene(uuid)
                return
            else
                _G.Util:showTipsBox(string.format("登录失败:%s(%d)",output.msg,output.error))
            end
        else
            _G.Util:showTipsBox(string.format("HTTP请求失败:state:%d,code=%d",xhrRequest.readyState,xhrRequest.status))
        end
        _G.Util:hideLoadCir()
    end

    xhrRequest:registerScriptHandler(http_login_handler)
    xhrRequest:send()

    _G.Util:showLoadCir()
end
function LoginView.gotoServerScene(self,_uuid)
    if self.m_rootLayer==nil then return end

    local function nFun()
        self.m_rootLayer:removeFromParent(true)
        self.m_rootLayer=nil
        self.m_successFun(_uuid)
    end
    performWithDelay(self.m_rootLayer,nFun,0.5)
end






local NETWORK_ARRAY={
    {name=[[IP]],host=[[192.168.1.3:89]]},
    {name=[[域名]],host=[[jqxs-api.gamecore.cn:89]]},
    {name=[[外网]],host=[[fm-api.aoxingame.com]],cid="888",key="781d648d04dc047c53aa277a059a219a"},
    {name=[[越南]],host=[[xm-api.30405.net]]},
    {name=[[凤凰测试]],host=[[xm-api-test.aoxingame.com]]},
    {name=[[凤凰正式]],host=[[xm-api.aoxingame.com]]},
    {name=[[凤凰I苹果]],host=[[xm-api.aoxingame.com]],cid="1518",key="0f8a985398b76389ab21dd20800f5a19"},
}
function LoginView.__selectNetWorkView(self,_tempBtn)
    if self.m_selectNetworkSpr==nil then
        self.m_selectNetworkSpr=cc.Sprite:createWithSpriteFrameName("general_check_selected.png")
        self.m_selectNetworkSpr:setPosition(0,15)
        _tempBtn:addChild(self.m_selectNetworkSpr)
    else
        self.m_selectNetworkSpr:retain()
        self.m_selectNetworkSpr:removeFromParent(false)
        _tempBtn:addChild(self.m_selectNetworkSpr)
        self.m_selectNetworkSpr:release()
    end
end
function LoginView.__showNetWorkView(self)
    if self.m_netWorkTypeLayer==nil then
        self.m_netWorkSize=cc.size(120,640)
        self.m_netWorkTypeLayer=cc.LayerColor:create(cc.c4b(0,0,0,160))
        self.m_netWorkTypeLayer:setContentSize(self.m_netWorkSize)
        self.m_netWorkTypeLayer:setPosition(self.m_winSize.width,0)
        self.m_rootLayer:addChild(self.m_netWorkTypeLayer)

        local ipBtn,releaseBtn,doMainBtn
        local function nFun(sender,eventType)
            if eventType==ccui.TouchEventType.ended then
                self:__selectNetWorkView(sender)

                local nTag=sender:getTag()
                local szHost=NETWORK_ARRAY[nTag].host
                _G.SysInfo:setHostTest(szHost)

                local szCid=NETWORK_ARRAY[nTag].cid
                local szKey=NETWORK_ARRAY[nTag].key
                if szCid then
                    gc.ChannelManager:setChannelData(_G.Const.sKeyCID217,szCid)

                    _G.SysInfo.m_cid=szCid
                end
                if szKey then
                    gc.ChannelManager:setChannelData(_G.Const.sKeyPrivatekey217,szKey)
                end
            end
        end

        local defaultHost=_G.SysInfo:getHost()
        local tempHeight=500
        for i=1,#NETWORK_ARRAY do
            tempBtn=ccui.Text:create()
            tempBtn:setString(NETWORK_ARRAY[i].name)
            tempBtn:setFontSize(24)
            tempBtn:setFontName(_G.FontName.Heiti)
            tempBtn:setTouchScaleChangeEnabled(true)
            tempBtn:setPosition(self.m_netWorkSize.width*0.5,tempHeight)
            tempBtn:setTouchEnabled(true)
            tempBtn:addTouchEventListener(nFun)
            tempBtn:enableOutline(cc.c4b(0,0,0,255),1)
            tempBtn:setTag(i)
            self.m_netWorkTypeLayer:addChild(tempBtn)
            tempHeight=tempHeight-60

            if defaultHost==NETWORK_ARRAY[i].host then
                self:__selectNetWorkView(tempBtn)
            end
        end

        self.m_isShowingNetType=false
    end

    self.m_netWorkTypeLayer:stopAllActions()
    if self.m_isShowingNetType then
        self.m_netWorkTypeLayer:runAction(cc.MoveTo:create(0.17,cc.p(self.m_winSize.width,0)))
    else
        self.m_netWorkTypeLayer:runAction(cc.MoveTo:create(0.17,cc.p(self.m_winSize.width-self.m_netWorkSize.width,0)))
    end
    self.m_isShowingNetType=not self.m_isShowingNetType
end

return LoginView