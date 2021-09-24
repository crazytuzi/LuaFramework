local P_StateLang =_G.Lang.log_state_lang
local P_SymbolLang=_G.Lang.log_symbol_lang

local P_COLOR={
    [_G.Const.CONST_LOGS_DEL]=_G.Const.CONST_COLOR_RED,
    [_G.Const.CONST_LOGS_ADD]=_G.Const.CONST_COLOR_GREEN,
}

local IgnoreCodeArray={
    [132]=true,[134]=true,[131]=true,
    [123]=true,[290]=true,[8203]=true,
    [7960]=true,[8020]=true,[8050]=true,
    [8060]=true,[12040]=true,[30640]=true,
    [37425]=true,[38550]=true,[39550]=true,
    [39555]=true,[39560]=true,[40115]=true,
    [40125]=true,[40135]=true
}

local LogsMediator=classGc(mediator, function(self, _view)
    self.name="LogsMediator"
    self.view=_view
    self:regSelfLong()
end)
LogsMediator.protocolsList={
    _G.Msg["ACK_GAME_LOGS_NOTICES"],
    _G.Msg["ACK_GAME_LOGS_EVENT"],
    _G.Msg["ACK_SYSTEM_NOTICE"],
    _G.Msg["ACK_SYSTEM_ERROR"],-- [700]错误代码 -- 系统 
    _G.Msg["ACK_SYSTEM_DISCONNECT"],-- [502]服务器将断开连接 -- 系统 
}

LogsMediator.commandsList={
    CLogsCommand.TYPE,
    CPowerfulCreateCommand.TYPE,
    CErrorBoxCommand.TYPE
}

function LogsMediator.processCommand(self, _command)
    local commamdType=_command :getType()
    if commamdType==CLogsCommand.TYPE then
        -- tempT={
        --     states = _G.Const.CONST_LOGS_DEL or _G.Const.CONST_LOGS_ADD (加或减)
        --     id = _G.Const.CONST_ATTR_ (属性类型)
        --     value = 999 (属性值)
        -- }

        -- test:
        -- local tempT={states=_G.Const.CONST_LOGS_DEL,id=_G.Const.CONST_ATTR_STRONG_ATT,value=999}
        -- local command=CLogsCommand(tempT)
        -- controller:sendCommand(command)
        
        local tempT=_command:getData()
        self:pushLog(tempT)
    elseif commamdType==CErrorBoxCommand.TYPE then
        local temp=_command:getData()
        local tempType=type(temp)
        -- print("BBBBBBBBBB======>>>",temp,tempType)
        if tempType=="number" then
            self.view:showErrorTips(temp)
        elseif tempType=="string" then
            self:handleErrorTips(temp,_command.color)
        elseif tempType=="table" then
            -- local command=CErrorBoxCommand({t={ {t=[[安师大安师大]],c=_G.Const.CONST_COLOR_WHITE},
            --                                     {t=[[安师大安师大]],c=_G.Const.CONST_COLOR_WHITE}
            --                                    }
            --                                 })
            -- _G.controller:sendCommand(command)
            self:addErrorTips(temp)
        end
    elseif commamdType==CPowerfulCreateCommand.TYPE then
        self:updatePowerful()
    end
end

-- [700]错误代码 -- 系统 
function LogsMediator.ACK_SYSTEM_ERROR(self,_ackMsg)
    local errorCode = _ackMsg.error_code
    print("ACK_SYSTEM_ERROR--->>>",errorCode)
    --205 到时单独处理
    if errorCode==20 then
        _G.controller:showExitGameNotic("请勿使用加速器")
    elseif errorCode==205 then
        _G.controller:showExitGameNotic("您已在别处登录")
    else
    	-- print(errorCode)
    	-- print("_G.g_Stage",_G.g_Stage)
    	-- print("_G.g_Stage.m_isCity",_G.g_Stage.m_isCity)
    	if _G.g_Stage~=nil and _G.g_Stage.m_isCity and IgnoreCodeArray[errorCode] then
    		return
    	end
        self.view:showErrorTips(errorCode)
    end
end

function LogsMediator.ACK_SYSTEM_DISCONNECT(self, _ackMsg)
    --断网
    _G.Network:disconnect()
    --禁止资源加载
    ScenesManger.isLoading=true
    --禁止重连接
    _G.controller.m_isCanNotConnect=true

    local function exitGame()
        cc.Director:getInstance():endToLua()
    end

    local stringMsg=nil
    if _ackMsg.msg then
        stringMsg=_ackMsg.msg
    else
        local errorCode=_ackMsg.error_code or 0
        local errorCnf=_G.Cfg.errorcode[errorCode]
        if errorCnf and errorCnf.t and errorCnf.t[1] then
            stringMsg=errorCnf.t[1].t
        end
    end
    stringMsg=stringMsg or "未配置错误信息的错误".._ackMsg.error_code

    local view=require("mod.general.TipsBox")()
    local layer=view:create(stringMsg,exitGame)
    layer:retain()
    view:setSureBtnText("退出")
    view:hideCancelBtn()

    local function local_delayFun()
        local nowScene = cc.Director:getInstance():getRunningScene()
        nowScene:addChild(layer,_G.Const.CONST_MAP_ZORDER_NOTIC+10)
        layer:release()
    end
    _G.Scheduler:performWithDelay(1,local_delayFun)
end

-- [22760]获得|失去通知 -- 日志
function LogsMediator.ACK_GAME_LOGS_NOTICES( self, _ackMsg )
    print("LogsMediator.ACK_GAME_LOGS_NOTICES",_ackMsg.type)
    local evenType=_ackMsg.type
    if evenType==_G.Const.CONST_LOGS_TYPE_CURRENCY then
        self:checkCurrency( _ackMsg )
    elseif evenType==_G.Const.CONST_LOGS_TYPE_GOODS then
        self:checkGoods( _ackMsg )
    elseif evenType==_G.Const.CONST_LOGS_TYPE_ATTR then
        self:checkAttr( _ackMsg )
    -- elseif evenType==_G.Const.CONST_LOGS_TYPE_BUFF then
    --     self:checkBuff( _ackMsg )
    -- elseif evenType==_G.Const.CONST_LOGS_TYPE_DOUQI then
    --     self:checkFightGas( _ackMsg )
    end
end

-- [22780]事件通知 -- 日志
function LogsMediator.ACK_GAME_LOGS_EVENT( self, _ackMsg )
    print("ACK_GAME_LOGS_EVENT---->",_ackMsg.id)
    --邮件8004 在主界面添加一个图标
    local iconType=nil
    if _ackMsg.id==_G.Const.CONST_LOGS_8004 then
        iconType=_G.Const.kMainIconEmal
    -- elseif _ackMsg.id==_G.Const.CONST_LOGS_2033 then
    --     iconType=_G.Const.kMainIconBoss
        -- _G.g_clanBossIcon=true
        -- local command=CClanCommand( CClanCommand.CLAN_BOSS_ICON )
        -- controller :sendCommand( command )
    elseif _ackMsg.id==_G.Const.CONST_LOGS_8007 then --苦工被抢图标
        iconType=_G.Const.kMainIconSlave
    elseif _ackMsg.id==_G.Const.CONST_LOGS_8002 then
        iconType=_G.Const.kMainIconArena
    end
    if iconType~=nil then
        _G.GBagProxy:setMainIconTypeState(iconType,true)
        local command=CMainUiCommand(CMainUiCommand.ICON_ADD)
        command.iconType=iconType
        controller:sendCommand(command)
        -- return
    end

    local tmpStr=_G.Lang.logs[_ackMsg.id]
    if tmpStr==nil then
        return
    end

    local strModule=_ackMsg.str_module
    for i=1,#strModule do
        tmpStr=self:gsub(tmpStr,"$",strModule[i].type1)
    end
    local intModule=_ackMsg.str_module
    for i=1,#intModule do
        tmpStr=self:gsub(tmpStr,"#",intModule[i].type2)
    end
    self:handleErrorTips(tmpStr)
    
    print("22780------",_ackMsg.id)
end

-- (手动) -- [800]系统通知 -- 系统 
function LogsMediator.ACK_SYSTEM_NOTICE( self, _ackMsg )
    print("CMarqueeMediator ACK_SYSTEM_NOTICE ")
    -- local result={}
    -- result.showtime=_ackMsg.show_time
    -- result.position=_ackMsg.msg_type
    -- result.msgdata =_ackMsg.msg_data 
    -- result.priorityLevel=1
    -- print("_系统通知: ",result.showtime,result.position,result.msgdata)
    -- self.view:pushErrorNotic( result )

    local tempT={contentArray={{str=_ackMsg.msg_data,color=_G.Const.CONST_COLOR_WHITE}},level=1}
    self.view:pushMarquee(tempT)
end

--{金币类判断}
function LogsMediator.checkCurrency( self, _ackMsg )
    local messArray=_ackMsg.mess
    if messArray==nil then
        return
    end
    for i=1, _ackMsg.count do
        local nStates=messArray[i].states
        local stateStr=P_SymbolLang[nStates]
        local currencyStr=_G.Lang.Currency_Type[messArray[i].id]
        if currencyStr~=nil and stateStr~=nil then
            local result =string.format("%s%s%d",currencyStr,stateStr,messArray[i].value)
            self:handleErrorTips(result,P_COLOR[nStates])
        end
    end
end
--{装备类判断}
function LogsMediator.checkGoods( self, _ackMsg )
    local mess=_ackMsg.mess
    if mess==nil then
        return
    end
    local addArray,delArray={},{}
    local addCount,delCount=0,0
    for i=1,_ackMsg.count do
        local stateStr=P_StateLang[mess[i].states]
        local goodsNode=_G.Cfg.goods[mess[i].id]
        if goodsNode~=nil and stateStr~=nil then
            if mess[i].states==1 then --get item
                local cf=CFlyItemCommand(mess[i].id)
                controller:sendCommand(cf)
                local szResult
                if addCount>0 then
                    szResult=string.format("、%s*%d",goodsNode.name,mess[i].value)
                else
                    szResult=string.format("%s: %s*%d",stateStr,goodsNode.name,mess[i].value)
                end
                addCount=addCount+1
                addArray[addCount]=szResult
            else
                local szResult
                if delCount>0 then
                    szResult=string.format("、%s*%d",goodsNode.name,mess[i].value)
                else
                    szResult=string.format("%s: %s*%d",stateStr,goodsNode.name,mess[i].value)
                end
                delCount=delCount+1
                delArray[delCount]=szResult
            end
        end
    end
    if addCount>0 then
        local tempStr=table.concat(addArray)
        self:handleErrorTips(tempStr,P_COLOR[1])
    end
    if delCount>0 then
        local tempStr=table.concat(delArray)
        self:handleErrorTips(tempStr,P_COLOR[0])
    end
end
--{属性类判断}
function LogsMediator.updatePowerful( self )
    self.oldpow=_G.GPropertyProxy:getMainPlay():getPowerful()
end

function LogsMediator.checkAttr( self )
    local messArray={}

    local nums=_G.GPropertyProxy:getMainPlay():getPowerful()-self.oldpow
    if nums>=0 then
        messArray.states=1
        messArray.value=nums
    else
        messArray.states=0
        messArray.value=-nums
    end
    -- print("self.oldpow--->>>>>",self.oldpow,_G.GPropertyProxy:getMainPlay():getPowerful())
    if P_SymbolLang[messArray.states]~=nil then
        self.view:pushLog(messArray)
    end

    self.oldpow=_G.GPropertyProxy:getMainPlay():getPowerful()
end

function LogsMediator.gsub( self, _str ,_taget, _source )
    local isfind=false
    local sSub=string.sub
    local sArray={}
    local sCount=0
    for i=1,string.len(_str) do
        local tmpStr=sSub(_str,i,i)
        if tmpStr==_taget and isfind==false then
            if _source~=nil then
                sCount=sCount+1
                sArray[sCount]=_source
            end
            isfind=true
        else
            sCount=sCount+1
            sArray[sCount]=tmpStr
        end
    end
    local result=table.concat(sArray)
    return result
end

--{霸气类判断}
function LogsMediator.checkFightGas( self, _ackMsg )
    local nCount=_ackMsg.count
    if nCount>0 then
        local messArray=_ackMsg.mess
        local tempArray={[0]={},[1]={}}
        local countArray={[0]=0,[1]=0}
        for i=1,nCount do
            local nStates=messArray[i].states
            local stateStr=P_StateLang[nStates]
            local goodsNode=_G.Cfg.fight_gas_total[messArray[i].id]
            if goodsNode and stateStr~=nil then
                local nArray=tempArray[nStates]
                local tCount=countArray[nStates]
                local szResult
                if tCount>0 then
                    szResult=string.format("、%s*%d",stateStr,goodsNode.gas_name,messArray[i].value)
                else
                    szResult=string.format("%s: %s*%d",stateStr,goodsNode.gas_name,messArray[i].value)
                end
                nArray[tCount+1]=szResult
                countArray[nStates]=countArray[nStates]+1
            end
        end

        if countArray[0]>0 then
            local tempStr=table.concat(tempArray[0])
            self:handleErrorTips(tempStr,P_COLOR[0])
        end
        if countArray[1]>0 then
            local tempStr=table.concat(tempArray[1])
            self:handleErrorTips(tempStr,P_COLOR[1])
        end
    end
end

function LogsMediator.handleErrorTips(self,_str,_color)
    local tempT={t={{t=_str,c=_color}}}
    self:addErrorTips(tempT)
end
function LogsMediator.addErrorTips(self,_tipsDatas)
    self.view:showErrorTips(_tipsDatas)
end

return LogsMediator