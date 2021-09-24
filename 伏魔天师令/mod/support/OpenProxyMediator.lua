local OpenProxyMediator = classGc( mediator, function( self, _view )
	self.name = "OpenProxyMediator"
	self.view = _view

    self:regSelfLong()
    self:initSubSysArray()
end)
function OpenProxyMediator.initSubSysArray(self)
    local tempArray1={}
    local tempArray2={}
    for parentId,value in pairs(_G.Cfg.funshow) do
        for sysId,_ in pairs(value.activity) do
            tempArray1[sysId]=parentId
        end
        tempArray2[parentId]=value.activity
    end
    self.m_subSysIdArray=tempArray1
    self.m_parentSysIdArray=tempArray2
end

OpenProxyMediator.protocolsList={
    _G.Msg.ACK_ROLE_SYS_ID_2,
    _G.Msg.ACK_ROLE_SYS_CHANGE,
    _G.Msg.ACK_ROLE_BUFF,
    _G.Msg.ACK_SYSTEM_ACTIVE_OPEN, -- [850]系统活动限时开放 
    _G.Msg.ACK_ROLE_SYS_POINTS
}

OpenProxyMediator.commandsList=nil

function OpenProxyMediator.ACK_ROLE_BUFF( self, _ackMsg )
    print( "体力buff-->", _ackMsg.id, _ackMsg.state )
    local _data = {}
    _data.id      = _ackMsg.id
    _data.state   = _ackMsg.state
    self.view:setEnergyBuffActivityInfo( _data )
    
    local buffCommand = CFunctionUpdateCommand( CFunctionUpdateCommand.BUFF_TYPE )
    controller :sendCommand( buffCommand )
end

function OpenProxyMediator.ACK_ROLE_SYS_ID_2( self, _ackMsg, _isTest)
    local nCount = _ackMsg.count
    local isInit = self.view:getInited()
    print("ACK_ROLE_SYS_ID_2==", _ackMsg.count,isInit)
    if nCount<=0 then return end

    local sysList    = self.view:getSysId()
    local ollSysList = clone(sysList)
    local chuangeIdList = {}
    local chuangeIdCount= 0

    local parentArray={}
    local parentCount=0
    for key,v in pairs(_ackMsg.sys_id) do
        local parentId=self.m_subSysIdArray[key]
        if parentId~=nil and _ackMsg.sys_id[parentId]==nil then
            _ackMsg.sys_id[parentId]={}
            _ackMsg.sys_id[parentId].number=0
            _ackMsg.sys_id[parentId].id=parentId
            _ackMsg.sys_id[parentId].state=_G.Const.CONST_ACTIVITY_ZHENGCHANG
            _ackMsg.addBySub=true
        end
    end
    for k,v in pairs(self.m_parentSysIdArray) do
        if _ackMsg.sys_id[k]~=nil then
            local hasSub=false
            for subId,_ in pairs(v) do
                local sysInfo=_ackMsg.sys_id[subId] or sysList[subId]
                if sysInfo~=nil then
                    hasSub=true
                    _ackMsg.sys_id[k].number=_ackMsg.sys_id[k].number+sysInfo.number
                end
            end
            
            if not hasSub then
                _ackMsg.sys_id[k]=nil
            end
        end
    end

    for key,v in pairs(_ackMsg.sys_id) do
        local ollSys=sysList[key]
        if ollSys~=nil then
            if v.state~=ollSys.state or v.number~=ollSys.number then
                sysList[key]=v
                sysList[key].state=ollSys.state
                chuangeIdCount=chuangeIdCount+1
                chuangeIdList[chuangeIdCount]=key
            end
        elseif key==_G.Const.CONST_FUNC_OPEN_RECHARGE 
            and v.state~=_G.Const.CONST_ACTIVITY_YONGJIU then
            sysList[key]=v
            sysList[key].state=_G.Const.CONST_ACTIVITY_YONGJIU
            chuangeIdCount=chuangeIdCount+1
            chuangeIdList[chuangeIdCount]=key
            -- CCLOG("新增功能->%d",key)
        elseif v.state~=_G.Const.CONST_ACTIVITY_ZHENGCHANG then
            sysList[key]=v
            sysList[key].state=_G.Const.CONST_ACTIVITY_ZHENGCHANG
            chuangeIdCount=chuangeIdCount+1
            chuangeIdList[chuangeIdCount]=key
            -- CCLOG("新增功能->%d",key)
        else
            sysList[key]=v
            chuangeIdCount=chuangeIdCount+1
            chuangeIdList[chuangeIdCount]=key
            -- CCLOG("新增功能->%d",key)
        end
    end

    self.view:setInited( true )
    self.view:setCount( nCount )
    
    if chuangeIdCount>0 then
        local command = CFunctionOpenCommand( CFunctionOpenCommand.UPDATE )
        command.chuangeIdList = chuangeIdList
        controller :sendCommand( command)
    end

    if isInit==false then
        local curLimList = self.view:getLimitId() or {}
        for sysId,_ in pairs(curLimList) do
            local command = CFunctionOpenCommand(CFunctionOpenCommand.LIMIT_REMOVE)
            command.sysId = sysId
            controller:sendCommand(command)
        end
    end

    --等待界面按钮刷新后在显示新功能开放
    if _G.GLayerManager==nil or _isTest or _G.GUIGMView~=nil then return end

    local openArray={}
    local openCount=0
    for key,v in pairs(_ackMsg.sys_id) do
        if ollSysList[key]==nil and isInit then
            print("----->>>>新功能>>>",key)
            openCount=openCount+1
            openArray[openCount]=key
        end
    end
    if openCount>1 then
        local function nSort(v1,v2)
            return v1>v2
        end
        table.sort(openArray,nSort)
    end
    for i=1,openCount do
        self.view:addOpenEffectSysId(openArray[i])
    end
end

function OpenProxyMediator.ACK_ROLE_SYS_CHANGE( self, _ackMsg )
    if not self.view:getInited() then return end

    local sysId   = _ackMsg.sys_id
    if sysId==_G.Const.CONST_FUNC_OPEN_ACTIVITY
        or sysId==_G.Const.CONST_FUNC_OPEN_DUEL
        or sysId==_G.Const.CONST_FUNC_OPEN_DEKARON  then
        return
    end

    local number  = _ackMsg.num
    local sysList = self.view:getSysId()
    -- sysId ~= _G.Const.CONST_FUNC_OPEN_ACTIVITIES
    if sysList[sysId] == nil then
        local curLimList = self.view:getLimitId()
        if curLimList[sysId] then
            CCLOG("大活动数字更新---->>>>%d",number)
            curLimList[sysId]=number
        else
            return
        end
    else
        sysList[sysId].number = number

        if self.m_subSysIdArray[sysId]~=nil then
            local parentId=self.m_subSysIdArray[sysId]
            local parentData=self.m_parentSysIdArray[parentId]
            if parentData~=nil and sysList[parentId]~=nil then
                sysList[parentId].number=0
                for subId,_ in pairs(parentData) do
                    if sysList[subId]~=nil then
                        print("CCCCCCCCCCC========>>>>>",sysList[subId].number,subId)
                        sysList[parentId].number=sysList[parentId].number+sysList[subId].number
                    end
                end
                sysId=parentId
                number=sysList[parentId].number
            end
        end
    end
    
    local command = CFunctionOpenCommand( CFunctionOpenCommand.TIMES_UPDATE )
    command.sysId = sysId
    command.number = number
    controller :sendCommand( command )

    CCLOG("ACK_ROLE_SYS_CHANGE--->>>>   sysId=%d, number=%d",sysId,number)
end

-- [850]系统活动限时开放
function OpenProxyMediator.ACK_SYSTEM_ACTIVE_OPEN( self, _ackMsg )
    local sysId = _ackMsg.id
    local nType = _ackMsg.state
    local command = nil
    local curLimList = self.view:getLimitId()
    if nType == 0 and curLimList[sysId] ~= nil then
        curLimList[sysId] = nil
        command = CFunctionOpenCommand(CFunctionOpenCommand.LIMIT_REMOVE)
    elseif nType == 1 and curLimList[sysId] == nil then
        print("state test here -----> ",curLimList[sysId],sysId)
        curLimList[sysId] = 0
        command = CFunctionOpenCommand(CFunctionOpenCommand.LIMIT_ADD)
    else
        return
    end
    print("state test here 22-----> ",nType,curLimList[sysId],sysId)
    self.view:setLimitId( curLimList )

    command.sysId = sysId
    controller:sendCommand(command)

    CCLOG("ACK_SYSTEM_ACTIVE_OPEN 的限时开放活动 --> active_id=%d, state=%d",sysId,nType)
end

function OpenProxyMediator.ACK_ROLE_SYS_POINTS(self,_ackMsg)
    print("ACK_ROLE_SYS_POINTS>>>>>>>>",_ackMsg.id)
    if _ackMsg.is_have==0 then
        self.view:delSysSign(_ackMsg.id)
    else
        self.view:addSysSign(_ackMsg.id)
    end
end

return OpenProxyMediator

