local LoginMediator=classGc(mediator,function(self)
    self.name="LoginMediator"
    self._createView=nil
    self._roleView=nil
    self:regSelf()
end)

LoginMediator.protocolsList = 
{
    _G.Msg["ACK_ROLE_NAME"],  -- (手动) -- [1024]请求随机名字 -- 角色
    _G.Msg["ACK_ROLE_LOGIN_OK_NO_ROLE"], -- [1023]登录成功(没有角色) -- 角色 
    _G.Msg["ACK_ROLE_LOGIN_OK_HAVE"],-- (手动) -- [1021]创建/登录(有角色)成功 -- 角色
    _G.Msg["ACK_SYSTEM_ERROR"],-- [700]错误代码 -- 系统 
}
LoginMediator.commandsList = {
    CNetworkCommand.TYPE,
    CGotoSceneCommand.TYPE
}

-- 处理消息
function LoginMediator.processCommand(self, _command)
    if _command:getType()==CNetworkCommand.TYPE then
        if _command:getData()==CNetworkCommand.ACT_DISCONNECT then
            if self._createView~=nil
                 or (self._roleView~=nil and self._roleView.m_isLogin) then

                _G.Util:hideLoadCir()
                
                -- _G.Util:showTipsBox("服务器断开连接!")

                if self._roleView~=nil then
                    self._roleView.m_isLogin=false
                end
                if self._createView~=nil then
                    self._createView:connectServerAgain()
                else
                    local command=CErrorBoxCommand("服务器断开连接")
                    controller:sendCommand(command)
                end
            end
        end
    elseif _command:getType()==CGotoSceneCommand.TYPE then
        if self._roleView~=nil then
            self._roleView:releaseCharcter()
        end
        if self._createView~=nil then
            self._createView:releaseCharcter()
        end
    end
end

-- (手动) -- [1024]请求随机名字 -- 角色
function LoginMediator.ACK_ROLE_NAME(self,_ackMsg)
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    
    if self._createView~=nil then
        self._createView:ackRoleName(_ackMsg.name)
    end
end

-- [1023]登录成功(没有角色) -- 角色 
function LoginMediator.ACK_ROLE_LOGIN_OK_NO_ROLE(self,_ackMsg)
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    if self._createView~=nil then
        print("ackDefaultPro-->")
        if not _G.SysInfo:isIpNetwork() then
			if _ackMsg.pro~=1 and _ackMsg.pro~=2 then
				_ackMsg.pro = 1
			end
		end
        self._createView:ackDefaultPro(_ackMsg.pro)
    end

    _G.Util:hideLoadCir()
end

-- [700]错误代码 -- 系统 
function LoginMediator.ACK_SYSTEM_ERROR(self,_ackMsg)
    -- for k,v in pairs(_ackMsg) do
    --     print(k,v)
    -- end
    _G.Util:hideLoadCir()
end

-- (手动) -- [1021]创建/登录(有角色)成功 -- 角色
function LoginMediator.ACK_ROLE_LOGIN_OK_HAVE(self,_ackMsg)
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end

    if self._roleView and self._roleView.isTestSocket then
        self:showTestScene()
        return
    end

    _G.controller.m_isCanNotConnect=nil

    if _G.g_Stage~=nil then
        print("lua warning!!!!!!!======>>>LoginMediator.ACK_ROLE_LOGIN_OK_HAVE 收到两次!!!!!!!!")
        -- return
    else
        _G.g_Stage=require("mod.map.Stage")()
        _G.g_Stage:addStageMediator()
    end

    local msg=REQ_ROLE_VIP_MY()
    _G.Network:send(msg)

    local mainProperty=_G.GPropertyProxy:getMainPlay()
    if mainProperty==nil then
        print("没有找到主角1",_ackMsg.uid)
        _G.GPropertyProxy:initMainPlay(_ackMsg.uid)
        mainProperty=_G.GPropertyProxy:getMainPlay()
    end
    mainProperty:setPro( _ackMsg.pro)
    mainProperty:setSex( _ackMsg.sex)
    mainProperty:setIsRedName( _ackMsg.is_red_name)
    mainProperty:updateProperty( _G.Const.CONST_ATTR_NAME, _ackMsg.uname)
    mainProperty:updateProperty( _G.Const.CONST_ATTR_ARMOR, _ackMsg.skin_armor)
    mainProperty:updateProperty( _G.Const.CONST_ATTR_COUNTRY, _ackMsg.country)
    mainProperty:updateProperty( _G.Const.CONST_ATTR_LV, _ackMsg.lv)
end

function LoginMediator.showTestScene(self)
    if self.m_testScene~=nil then return end

    _G.Util:hideLoadCir()

    local tempScene=cc.Scene:create()
    cc.Director:getInstance():pushScene(tempScene)

    self.m_testScene=tempScene

    local tempLayer=cc.Layer:create()
    tempScene:addChild(tempLayer)

    local winSize=cc.Director:getInstance():getWinSize()
    local niticLabel=_G.Util:createLabel("Socket 发热测试........",35)
    niticLabel:setPosition(winSize.width*0.5,winSize.height*0.5)
    tempLayer:addChild(niticLabel)

    local niticLabel=_G.Util:createLabel("我只是一个空场景,什么都不做,放着看看会不会发热...",20)
    niticLabel:setPosition(winSize.width*0.5,250)
    tempLayer:addChild(niticLabel)

    controller:unMediatorAll()    --清空所有Mediator
    _G.Scheduler:unAllschedule()

    local function local_buttonCallBack(sender, eventType)
        if eventType==ccui.TouchEventType.ended then
            print("FFFFFFFFFFFFF>>>>>>>>>>>>")
            cc.Director:getInstance():popScene()
            _G.Network:disconnect()
            self.m_testScene=nil
        end
    end

    local testButton=gc.CButton:create("general_btn_lv.png")
    testButton:setTitleFontName(_G.FontName.Heiti)
    testButton:setTitleFontSize(24)
    testButton:setTitleText("返 回")
    testButton:setPosition(winSize.width*0.5,130)
    testButton:addTouchEventListener(local_buttonCallBack)
    tempLayer:addChild(testButton,100)
end

return LoginMediator