local LoginServerView=classGc(view,function(self,_isChuangeServer)
    self.m_serverList={}

    self.m_isChuangeServer=_isChuangeServer
    self.m_winSize=cc.Director:getInstance():getWinSize()

    self:show()
end)

function LoginServerView.show(self,sceneId)
    -- 显示界面
    local tempLayer=self:create()

    if self.m_isChuangeServer then
        _G.SysInfo:setTextureFormat(cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
        local tempScene=gc.UpdateScene:create()
        tempScene:hideLoadNode()
        tempScene:hideContentLabel()
        tempScene:addChild(tempLayer,100)
        local tempScene2=cc.TransitionCrossFade:create(0.35,tempScene)
        cc.Director:getInstance():replaceScene(tempScene2)
        _G.SysInfo:resetTextureFormat()
    else
        cc.Director:getInstance():getRunningScene():addChild(tempLayer,100)
    end
end

function LoginServerView.create(self)
    self.m_rooLayer=cc.Layer:create()

    if not self.m_isChuangeServer then
        self:addNotice()
    end

    local function delayFun1()        
        self:httpRequestServer()
    end

    local act1=cc.DelayTime:create(0.2)
    local act2=cc.CallFunc:create(delayFun1)
    self.m_rooLayer:runAction(cc.Sequence:create(act1,act2))
    return self.m_rooLayer
end

function LoginServerView.addNotice( self, _juhua )
    local NoticeView = require( "mod.login.LoadNotice" )()
    local view       = NoticeView : create(_juhua)
    self.m_noticView=NoticeView
end

function LoginServerView.removeNotice( self )
    local view = cc.Director:getInstance():getRunningScene():getChildByTag(5656)
    if view then
        view : removeFromParent(true)
        view = nil
    end
end

function LoginServerView.initStartGame( self )
	local serverData=nil
    if #self.m_serverList.h>0 then
    	serverData=self.m_serverList.h[#self.m_serverList.h]
    elseif #self.m_serverList.r>0 then
    	serverData=self.m_serverList.r[#self.m_serverList.r]
    else
    	serverData=self.m_serverList.a[#self.m_serverList.a]
    end

    if not serverData then
    	return
    end

    local function selectEvent( send,event )
    	if event == ccui.TouchEventType.ended then
    		print("start......")
    		self:goSelectServerView()
    	end
    end

    local selectBtn= gc.CButton:create()
    selectBtn:loadTextures("login_server_dins.png")
    selectBtn:addTouchEventListener(selectEvent)
    --selectBtn:setTitleText(serverData.n)
    -- selectBtn:setTitleFontName(_G.FontName.Heiti)
    -- selectBtn:setTitleFontSize(24)
    -- selectBtn:enableTitleOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_PSTROKE))
    -- selectBtn:setEnableTitleOutline(_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_XSTROKE))
    selectBtn:setPosition(cc.p(self.m_winSize.width*0.5,120))
    self.m_rooLayer:addChild(selectBtn,1)

    local serverName = _G.Util:createLabel(serverData.n,20)
    serverName:setAnchorPoint(cc.p(0,0.5))
    local buttonSize = selectBtn:getContentSize()
    serverName:setPosition(cc.p(10,buttonSize.height/2))
    selectBtn:addChild(serverName)

    --local startSpr=cc.Sprite:createWithSpriteFrameName("login_dins.png")
    local startSpr = ccui.Widget:create()
    startSpr:setContentSize(cc.size(197,178)) 
    startSpr:setPosition(cc.p(self.m_winSize.width*0.5,55))
    startSpr:setScale(0.3)
    startSpr:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2,1.2),cc.ScaleTo:create(0.05,1)))
    startSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.TintBy:create(0.5,0,-50,-50),cc.TintBy:create(0.5,0,50,50))))
    self.m_rooLayer:addChild(startSpr,1)

    local function startGameEvent( send,event )
    	if event == ccui.TouchEventType.ended then
    		self:httpRequestRole(serverData.s)
    	end
    end

    local sprSize=startSpr:getContentSize()
    local startGame=gc.CButton:create()
    startGame:loadTextures("login_btn_normal.png","login_btn_down.png","login_btn_down.png")
    startGame:setPosition(cc.p(sprSize.width*0.5,sprSize.height*0.5+3))
    startGame:addTouchEventListener(startGameEvent)
    startSpr:addChild(startGame,2)

    local function showGongGao( send,event )
        if event == ccui.TouchEventType.ended then
            self : addNotice(true)
        end
    end

    local NewGongGao = gc.CButton : create()
    NewGongGao       : loadTextures( "login_gonggao.png" )
    NewGongGao       : addTouchEventListener( showGongGao )
    NewGongGao       : setAnchorPoint( 1, 1 )
    NewGongGao       : setPosition( self.m_winSize.width-10, self.m_winSize.height-10)
    self.m_rooLayer  : addChild( NewGongGao,1 )
end

function LoginServerView.showAllServerView(self)
    self.m_allServerView=require("mod.general.TabLeftView")()
    local tempLayer=self.m_allServerView:create("选择服务器")
    self.m_rooLayer:addChild(tempLayer,3)

    self.m_allServerNode=cc.Node:create()
    self.m_allServerNode:setPosition(self.m_winSize.width/2,0)
    tempLayer:addChild(self.m_allServerNode)

    local function closeEvent()
    	tempLayer:removeFromParent()
    	self.m_serverNode = nil
    end
    self.m_allServerView:addCloseFun(closeEvent)
end

function LoginServerView.httpRequestServer(self)
    local szUrl = _G.SysInfo:urlServList()
    local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("GET", szUrl)

    local function http_handler()
        _G.Util:hideLoadCir()
        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
            local response = xhrRequest.response

            print("http_handler response11="..response)

            local output
            local function nFun()
                output=json.decode(response,1)
            end
            local status, msg=pcall(nFun)
            if not status then
                local function nFun2()
                    self:httpRequestServer()
                end
                __G__TRACKBACK__(msg)
                _G.Util:showTipsBox("服务器列表出错,请重试",nFun2)
                if self.m_noticView then
                    self.m_noticView:closeWindow()
                end
                return
            end

            if output.ref==1 then
                self.m_serverList.r=output.r
                -- local allNum=#output.a
                -- for i=1,4 do
                --     for j=1,allNum do
                --         output.a[j+(i-1)*allNum]=output.a[j]
                --     end
                -- end
                self.m_serverList.a=output.a

                self.m_serverList.h={}
                local nCount=#output.h
                for i=nCount,1,-1 do
                    self.m_serverList.h[nCount-i+1]=output.h[i]
                end
                -- self.m_serverList.a[#self.m_serverList.a+1]=self.m_serverList.a[1]
                -- self.m_serverList.a[#self.m_serverList.a+1]=self.m_serverList.a[1]
                -- self.m_serverList.a[#self.m_serverList.a+1]=self.m_serverList.a[1]
                
                self:initStartGame() 
                _G.GLoginPoxy:setServerList(self.m_serverList.a)
            else
                local function nFun()
                    self:httpRequestServer()
                end
                _G.Util:showTipsBox(string.format("获取服务器列表失败:%s(%d)",output.msg,output.error),nFun)
            end
        else
            local function nFun()
                self:httpRequestServer()
            end
            _G.Util:showTipsBox(string.format("获取服务器列表失败:state:%d,code=%d",xhrRequest.readyState,xhrRequest.status),nFun)
        end
    end

    xhrRequest:registerScriptHandler(http_handler)
    xhrRequest:send()
    _G.Util:showLoadCir()
end

local One_Page_Count=10
function LoginServerView.initAllServerView(self)
    local serverList=self.m_serverList.a

    local allCount=#serverList
    local pageCount=math.ceil(allCount/One_Page_Count)

    local function tabFun(_tag)
        self:selectThisPage(_tag)
    end

    self.m_allServerView:addTabFun(tabFun)
    self.m_allServerView:addTabButton("最近登录",0)
    local curTag=0
    for i=pageCount,1,-1 do
        local startIdx=(i-1)*One_Page_Count+1
        local endIdx=i==pageCount and allCount or startIdx+One_Page_Count-1
        local szName=string.format("%.2d-%.2d区",startIdx,endIdx)
        self.m_allServerView:addTabButton(szName,i)
    end
    self:selectThisPage(curTag)
    self.m_allServerView:selectTagByTag(curTag)
end

function LoginServerView.selectThisPage(self,_pageIdx)
    if self.m_serverNode~=nil then
        self.m_serverNode:removeAllChildren(true)
    else
        self.m_serverNode=cc.Node:create()
        self.m_allServerNode:addChild(self.m_serverNode)
    end

    local serverList
    if _pageIdx==0 then
        serverList=self.m_serverList.h
    else
        local allCount=#self.m_serverList.a
        local pageCount=math.ceil(allCount/One_Page_Count)
        local startIdx=(_pageIdx-1)*One_Page_Count+1
        local endIdx=_pageIdx==pageCount and allCount or startIdx+One_Page_Count-1
        print("dsadsadsada==>>",allCount,pageCount,startIdx,endIdx)
        serverList={}
        local serverCount=0
        local NowCount=math.ceil(endIdx/One_Page_Count)-1
        local nowIdx=(2*NowCount+1)*One_Page_Count-allCount
        if endIdx<=10 then
            if allCount>10 then
                nowIdx=-(allCount-One_Page_Count)
            else
                nowIdx=0
            end
        elseif endIdx==allCount then
            nowIdx=NowCount*One_Page_Count
        end
        for i=endIdx,startIdx,-1 do
            serverCount=serverCount+1
            print("serverCount===>>",i-nowIdx)
            serverList[serverCount]=self.m_serverList.a[i-nowIdx]
        end
    end

    local function local_buttonCallBack(sender, eventType)
        if eventType==ccui.TouchEventType.began then
            sender:setOpacity(180)
        elseif eventType==ccui.TouchEventType.ended then
            local sid=sender:getTag()
            print("local_buttonCallBack  click!!  sid="..sid)
            sender:setOpacity(255)
            self:httpRequestRole(sid)
        elseif eventType==ccui.TouchEventType.canceled then
            sender:setOpacity(255)
        end
    end

    local viewSize=self.m_allServerView:getSecondSize()
    local oneHeight=(viewSize.height-30)/One_Page_Count*2
    local yPosTop=viewSize.height+5-oneHeight*0.5
    local buttonSize=cc.size(282,81)
    local xPosLeft=-38
    local xPosRight=264
    -- print("===========>>>>>>>>>>",buttonSize.width,buttonSize.height)
    local szNormal ="login_pblue.png"
    local szPress  ="login_lblue.png"
    local szStatus ={"login_line_weihu.png","login_line_hot.png","login_line_new.png","login_line_tuijian.png"}
    local bColor=_G.ColorUtil:getRGBA(_G.Const.CONST_COLOR_PSTROKE)
    local iCount = #serverList
    if iCount > 10 then
    	iCount = 10
    end

    local curTimes=_G.SysInfo:getServSeconds()
    for i=1,iCount do
        local server=serverList[iCount-i+1]
        local isLeft=i%2==1
        local x_pos =isLeft and xPosLeft or xPosRight

        local button=ccui.Button:create()
        button:setScale9Enabled(true)
        button:loadTextures(szNormal,szNormal,szNormal,1)
        button:setContentSize(buttonSize)
        button:setPosition(x_pos,yPosTop)
        button:addTouchEventListener(local_buttonCallBack)
        button:setTag(tonumber(server.s))
        self.m_serverNode:addChild(button)
        -- local buttonSize=button:getContentSize()
        local tempLabel=_G.Util:createBorderLabel(server.n,24,bColor)
        tempLabel:setAnchorPoint(cc.p(0,0.5))
        tempLabel:setPosition(30,buttonSize.height/2)
        button:addChild(tempLabel,10)

        local serverStatus
        if server.r~=nil then
            serverStatus=tonumber(server.r)
        end

        if serverStatus~=nil and szStatus[serverStatus] then
            local sprite=cc.Sprite:createWithSpriteFrameName(szStatus[serverStatus])
            sprite:setPosition(cc.p(buttonSize.width-50,buttonSize.height/2))
            button:addChild(sprite,10)
        end

        if not isLeft then
            yPosTop=yPosTop-oneHeight
        end
    end

end

function LoginServerView.getTimeStr( self, _time)
    local time = os.date("*t",_time)

    if time.month < 10 then time.month = "0"..time.month end
    if time.day < 10 then time.day = "0"..time.day end
    if time.hour < 10 then time.hour = "0"..time.hour
    elseif time.hour < 0 then time.hour = "00" end
    if time.min < 10 then time.min = "0"..time.min
    elseif time.min < 0 then time.min = "00" end

    local time  = time.year.."/"..time.month.."/"..time.day.." "..time.hour..":"..time.min

    return time
end

function LoginServerView.ReturnPlayer(self)
    self:httpRequestRole(201)
end

function LoginServerView.httpRequestRole(self,_sid)
    if _sid==nil then return end

    _G.GLoginPoxy:setServerId(_sid)

    local serverData=_G.GLoginPoxy:getCurServerData()
    if serverData.o~=nil then
        local openTimes=tonumber(serverData.o)
        local curTimes=_G.SysInfo:getServSeconds()

        if openTimes>curTimes then
            local szTimes=self:getTimeStr(openTimes)
            local command=CErrorBoxCommand(string.format("开服时间:%s",szTimes))
            controller:sendCommand(command)
            return
        end
    end

    local szUrl = _G.SysInfo:urlRoleList(_sid)
    local xhrRequest = cc.XMLHttpRequest:new()
    xhrRequest.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhrRequest:open("GET", szUrl)
    print("httpRequestRole->  url="..szUrl)

    local function http_handler()
        _G.Util:hideLoadCir()

        if xhrRequest.readyState == 4 and (xhrRequest.status >= 200 and xhrRequest.status < 207) then
            local response = xhrRequest.response
            response = string.gsub(response,'\\','')
            print("http_handler response="..response)

            local output = json.decode(response,1)
            if output.ref==1 then
                local roleList=output.role_list
                if #roleList==0 then
                    self:goLoginCreateView()
                else
                    self:goLoginRoleView(roleList)
                end

                self:__loginServer()
            else
                _G.Util:showTipsBox(string.format("获取角色列表失败:%s(%d)",output.msg,output.error))

                self : removeNotice()
            end
        else
            _G.Util:showTipsBox(string.format("HTTP请求失败:state:%d,code=%d",xhrRequest.readyState,xhrRequest.status))

            self : removeNotice()
        end
    end

    xhrRequest:registerScriptHandler(http_handler)
    xhrRequest:send()

    _G.Util:showLoadCir()
end

function LoginServerView.goSelectServerView(self)
    self:showAllServerView()
    self:initAllServerView()
end

function LoginServerView.goLoginCreateView(self)
    local createView=require("mod.login.LoginCreateView")()
    createView:init()
end

function LoginServerView.goLoginRoleView(self,_roleList)
    local view = cc.Director:getInstance():getRunningScene():getChildByTag(5656)
    if view then
        view : removeFromParent(true)
        view = nil
    end
    require("mod.login.LoginRoleView")(_roleList,false)
end

function LoginServerView.__loginServer(self)
    if gc.UserCache.setServerId==nil then return end

    gcprint("SDK submitServerDatas=============>>>>>>>>")

    gc.UserCache:getInstance():setServerId(tostring(_G.GLoginPoxy:getServerId()))
    gc.UserCache:getInstance():setServerName(_G.GLoginPoxy:getServerName())

    gc.SDKManager:getInstance():submitServerDatas()
end

return LoginServerView