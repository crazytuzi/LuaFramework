local RegistView=classGc(view,function(self,_loginView)
    self.m_winSize=cc.Director:getInstance():getWinSize()
    self.m_loginView=_loginView
end)

function RegistView.create(self)
    self.m_rootNode=cc.Node:create()
    self.m_rootNode:setPosition(self.m_winSize.width/2,self.m_winSize.height/2+20)

    self:initView()

    return self.m_rootNode
end

function RegistView.initView(self)
    local name_button_regist  = "Button_2_Copy"
    local name_button_back    = "Button_2"

    local tempBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_di2kuan.png")
    tempBg:setPreferredSize(cc.size(500,300))
    self.m_rootNode:addChild(tempBg)

    local fontName=_G.FontName.Heiti
    local nPosx1=-85

    local textBgSize=cc.size(247,47)
    local fieldSize=cc.size(235,27)
    local nPosY,titleSpr,textBg,textField

    -- 用户名
    nPosY=95
    titleSpr=_G.Util:createBorderLabel("用 户 名:",24)
    titleSpr:setAnchorPoint(cc.p(1,0.5))
    titleSpr:setPosition(nPosx1,nPosY)
    self.m_rootNode:addChild(titleSpr)
    self.m_titleLabel=titleSpr

    textBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_input_box.png")
    self._editName=ccui.EditBox:create(textBgSize,textBg)
    self._editName:setPosition(nPosx1+textBgSize.width/2+20,nPosY)
    self._editName:setFont(fontName,20)
    self._editName:setPlaceholderFont(fontName,20)
    self._editName:setPlaceHolder("请输入帐号")
    self._editName:setMaxLength(10)
    self._editName:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editName:setInputMode(6)
    self.m_rootNode:addChild(self._editName)

    -- 密码
    nPosY=35
    titleSpr=_G.Util:createBorderLabel("密    码:",24)
    titleSpr:setAnchorPoint(cc.p(1,0.5))
    titleSpr:setPosition(nPosx1,nPosY)
    self.m_rootNode:addChild(titleSpr)

    textBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_input_box.png")
    self._editPass1=ccui.EditBox:create(textBgSize,textBg)
    self._editPass1:setPosition(nPosx1+textBgSize.width/2+20,nPosY)
    self._editPass1:setFont(fontName,20)
    self._editPass1:setPlaceholderFont(fontName,20)
    self._editPass1:setPlaceHolder("请输入密码")
    self._editPass1:setMaxLength(10)
    self._editPass1:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editPass1:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self._editPass1:setInputMode(6)
    self.m_rootNode:addChild(self._editPass1)

    -- 确认密码
    nPosY=-25
    titleSpr=_G.Util:createBorderLabel("确认密码:",24)
    titleSpr:setAnchorPoint(cc.p(1,0.5))
    titleSpr:setPosition(nPosx1,nPosY)
    self.m_rootNode:addChild(titleSpr)

    textBg=ccui.Scale9Sprite:createWithSpriteFrameName("general_input_box.png")
    self._editPass2=ccui.EditBox:create(textBgSize,textBg)
    self._editPass2:setPosition(nPosx1+textBgSize.width/2+20,nPosY)
    self._editPass2:setFont(fontName,20)
    self._editPass2:setPlaceholderFont(fontName,20)
    self._editPass2:setPlaceHolder("请再次输入密码")
    self._editPass2:setMaxLength(10)
    self._editPass2:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    self._editPass2:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
    self._editPass2:setInputMode(6)
    self.m_rootNode:addChild(self._editPass2)

    local function c(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            local btnName=sender:getName()
            if btnName==name_button_regist then
                print("name_button_regist  click!!")
                self:httpRegist()
            elseif btnName==name_button_back then
                print("name_button_back  click!!")
                if self.m_loginView~=nil then
                    self.m_loginView:hideRegistView()
                end
            end
        end
    end

    nPosY=-105
    local button=gc.CButton:create("general_btn_lv.png")
    button:setPosition(cc.p(-85,nPosY))
    button:addTouchEventListener(c)
    button:setTitleFontSize(24)
    button:setTitleFontName(fontName)
    button:setTitleText("确 定")
    button:setName(name_button_regist)
    self.m_rootNode:addChild(button)

    button=gc.CButton:create("general_btn_lv.png")
    button:setPosition(cc.p(85,nPosY))
    button:addTouchEventListener(c)
    button:setTitleFontSize(24)
    button:setTitleFontName(fontName)
    button:setTitleText("返 回")
    button:setName(name_button_back)
    self.m_rootNode:addChild(button)
end

function RegistView.httpRegist(self)
    local szName=self._editName:getText()
    local szPass1=self._editPass1:getText()
    local szPass2=self._editPass2:getText()
    if szName=="" then
        local command=CErrorBoxCommand("帐号不能为空")
        _G.controller:sendCommand(command)
        return
    elseif szPass1=="" then
        local command=CErrorBoxCommand("密码不能为空")
        _G.controller:sendCommand(command)
        return
    elseif szPass2=="" then
        local command=CErrorBoxCommand("确认密码不能为空")
        _G.controller:sendCommand(command)
        return
    elseif szPass1~=szPass2 then
        local command=CErrorBoxCommand("输入的密码不一致")
        _G.controller:sendCommand(command)
        return
    end

    if self.m_titleLabel.isHasUnDefineChar then
        local isNameHasUndefineChar=self.m_titleLabel:isHasUnDefineChar(szName)
        if isNameHasUndefineChar then
            local command=CErrorBoxCommand("用户名不能含有表情或特殊符号")
            _G.controller:sendCommand(command)
            return
        end

        local isHasUndefineChar=self.m_titleLabel:isHasUnDefineChar(szPass1)
        if isHasUndefineChar then
            local command=CErrorBoxCommand("密码不能含有表情或特殊符号")
            _G.controller:sendCommand(command)
            return
        end

        local isHasUndefineChar=self.m_titleLabel:isHasUnDefineChar(szPass2)
        if isHasUndefineChar then
            local command=CErrorBoxCommand("密码不能含有表情或特殊符号")
            _G.controller:sendCommand(command)
            return
        end
    end
    
    cc.UserDefault:getInstance():setStringForKey("normal_check", "YES")
    cc.UserDefault:getInstance():setStringForKey("normal_name", szName)
    cc.UserDefault:getInstance():setStringForKey("normal_pass", szPass1)

    local szUrl = string.format("%s?%s",_G.SysInfo:urlAppRegister(),_G.SysInfo:urlAppRegisterSignData(szName,szPass1))
    local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("POST", szUrl)

    print("======>>>szUrl=",szUrl)

    local function http_regist_handler()
        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
            local response = xhrRequest.response
            local output = json.decode(response,1)
            print("http_regist_handler response="..response)

            if output.ref==1 then
                local uuid=output.uuid
                self.m_loginView:gotoServerScene(uuid)
                return
            else
                _G.Util:showTipsBox(string.format("注册失败:%s(%d)",output.msg,output.error),tipsSure)
            end
        else
            _G.Util:showTipsBox(string.format("HTTP请求失败:state:%d,code=%d",xhrRequest.readyState,xhrRequest.status),tipsSure)
        end
        _G.Util:hideLoadCir()
    end

    xhrRequest:registerScriptHandler(http_regist_handler)
    xhrRequest:send()

    _G.Util:showLoadCir()
end

return RegistView