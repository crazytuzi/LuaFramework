local SystemProxy = classGc(function( self)
	self.isInited = false
    self.m_count = 0
    self.m_settingArray = {}
    self.__settingArray = {}

    self.m_neverNoticArray={}

    self.m_pkInviteArray={}

    self.m_isActivityViewShow=true
    self.m_isSystemViewShow=false
    self.m_isChatWindowShow=true
    self.m_isTaskGuideShow=true

    local mediator=require("mod.support.SystemProxyMediator")()
    mediator:setView(self)
end)

function SystemProxy.setInited( self, valueForKey)
    self.isInited   = valueForKey
end

function SystemProxy.getInited( self)
    return self.isInited
end

function SystemProxy.setCount( self, valueForKey)
    self.m_count = valueForKey
end

-- {数量}
function SystemProxy.getCount( self)
	return self.m_count
end

-- {系统设置列表}
function SystemProxy.getSysSettingList( self)
	return self.m_settingArray
end

function SystemProxy.setSysSettingList( self, valueForKey)
    self.__settingArray={}
    for k,v in pairs(valueForKey) do
        self.__settingArray[v.type]=v
        self.__settingArray[v.type].pos=k
    end
	self.m_settingArray = valueForKey
end

function SystemProxy.isBgMusicOpen(self)
    local set=self.__settingArray[_G.Const.CONST_SYS_SET_MUSIC_BG]
    if set~=nil and set.state==1 then
        return true
    end
    return false
end
function SystemProxy.isEffectSoundOpen(self)
    local set=self.__settingArray[_G.Const.CONST_SYS_SET_MUSIC]
    if set~=nil and set.state==1 then
        return true
    end
    return false
end
function SystemProxy.isPKOpen(self)
    local set=self.__settingArray[_G.Const.CONST_SYS_SET_PK]
    if set~=nil and set.state==1 then
        return true
    end
    return false
end
function SystemProxy.isHideOrtherOpen(self)
    local set=self.__settingArray[_G.Const.CONST_SYS_SET_SHOW_ROLE]
    if set~=nil and set.state==1 then
        return true
    end
    return false
end
function SystemProxy.isRoleInfoOpen(self)
    local set=self.__settingArray[_G.Const.CONST_SYS_SET_ROLE_DATA]
    if set~=nil and set.state==1 then
        return true
    end
    return false
end
function SystemProxy.isEnergyNoticOpen(self)
    local set=self.__settingArray[_G.Const.CONST_SYS_SET_ENERGY]
    if set~=nil and set.state==1 then
        return true
    end
    return false
end
function SystemProxy.isTeamOpen(self)
    local set=self.__settingArray[_G.Const.CONST_SYS_SET_TEAM]
    if set~=nil and set.state==1 then
        return true
    end
    return false
end

function SystemProxy.getSettingNameByType( self, valueForKey )
    local settingType = valueForKey
    if settingType == _G.Const.CONST_SYS_SET_MUSIC_BG then
        return _G.Lang.LAB_N[903]
    elseif settingType == _G.Const.CONST_SYS_SET_MUSIC then
        return _G.Lang.LAB_N[904]
    elseif settingType == _G.Const.CONST_SYS_SET_PK then
        return _G.Lang.LAB_N[905]
    elseif settingType == _G.Const.CONST_SYS_SET_SHOW_ROLE then
        return _G.Lang.LAB_N[906]
    elseif settingType == _G.Const.CONST_SYS_SET_ROLE_DATA then
        return _G.Lang.LAB_N[907]
    elseif settingType == _G.Const.CONST_SYS_SET_ENERGY then
        return _G.Lang.LAB_N[908]
    elseif settingType == _G.Const.CONST_SYS_SET_MOBILE then
        return _G.Lang.LAB_N[909]
    elseif settingType == _G.Const.CONST_SYS_SET_TEAM then
        return _G.Lang.LAB_N[910]
    else
        return _G.Lang.LAB_N[31]
    end
end

function SystemProxy.savaChuangByView(self,_type,_state)
    if self.__settingArray[_type]==nil then return end
    self.__settingArray[_type].state=_state

    local pos=self.__settingArray[_type].pos
    self.m_settingArray[pos].state=_state

    self:handleTypeSetting(_type)
end

function SystemProxy.handleTypeSetting(self,_type)
    if self.__settingArray[_type]==nil then return end
    local nState=self.__settingArray[_type].state
    if _type==_G.Const.CONST_SYS_SET_MUSIC_BG then
        -- 背景音乐
        if nState==0 then
            cc.UserDefault:getInstance():setBoolForKey("audio_background",false)
            cc.SimpleAudioEngine:getInstance():stopMusic(true)
        else
            cc.UserDefault:getInstance():setBoolForKey("audio_background",true)

            if _G.g_Stage==nil or _G.g_Stage:isInit()==false then return end
            _G.Util:playAudioMusic(_G.g_Stage:getBackgroundMusicId(),true,true)
        end
    elseif _type==_G.Const.CONST_SYS_SET_MUSIC then
        -- 游戏音效
        local enable=nState==1
        if ccui.Widget.setStaticEnableSound then
            ccui.Widget:setStaticEnableSound(enable)
        end
        cc.UserDefault:getInstance():setBoolForKey("audio_effect",enable)
    elseif _type==_G.Const.CONST_SYS_SET_PK then
        -- 允许切磋
        if _G.g_Stage==nil or _G.g_Stage:isInit()==false then return end

        if nState==0 then
            if #self.m_pkInviteArray>0 then
                local command=CMainUiCommand(CMainUiCommand.ICON_DEL)
                command.iconType=_G.Const.kMainIconPK
                controller:sendCommand(command)
            end
            self:removeAllPKInvite()
        end
    elseif _type==_G.Const.CONST_SYS_SET_TEAM then
        -- 允许组队

    elseif _type==_G.Const.CONST_SYS_SET_SHOW_ROLE then
        -- 屏蔽玩家
        if _G.g_Stage==nil or _G.g_Stage:isInit()==false then return end

        if nState==0 then
            _G.g_Stage:setOtherPlayerVisible(true)
        else
            _G.g_Stage:setOtherPlayerVisible(false)
        end
    end
end

function SystemProxy.addPKInvite(self,_ackMsg)
    if not self:isPKOpen() then return end

    local isUpdate=false
    local curCount=#self.m_pkInviteArray
    for i=1,curCount do
        if _ackMsg.uid==self.m_pkInviteArray[i].uid then
            self.m_pkInviteArray[i]=_ackMsg
            isUpdate=true
        end
    end
    if not isUpdate then
        self.m_pkInviteArray[curCount+1]=_ackMsg
    end

    -- 主界面提示
    local command=CMainUiCommand(CMainUiCommand.ICON_ADD)
    command.iconType=_G.Const.kMainIconPK
    controller:sendCommand(command)
end
function SystemProxy.delPKInvite(self,_uid)
    if not self:isPKOpen() then return end

    local curCount=#self.m_pkInviteArray
    for i=1,curCount do
        if _uid==self.m_pkInviteArray[i].uid then
            table.remove(self.m_pkInviteArray,i)
            break
        end
    end

    if #self.m_pkInviteArray<=0 then
        -- 删除主界面提示
        local command=CMainUiCommand(CMainUiCommand.ICON_DEL)
        command.iconType=_G.Const.kMainIconPK
        controller:sendCommand(command)
    end
end
function SystemProxy.getPKInviteArray(self)
    return self.m_pkInviteArray
end
function SystemProxy.removeAllPKInvite(self)
    self.m_pkInviteArray={}
end

function SystemProxy.setNeverNotic(self,_tag,_bool)
    self.m_neverNoticArray[_tag]=_bool
end
function SystemProxy.getNeverNotic(self,_tag)
    return self.m_neverNoticArray[_tag] or false
end

function SystemProxy.setActivityViewShow(self,_bool)
    self.m_isActivityViewShow=_bool
end
function SystemProxy.isActivityViewShow(self)
    return self.m_isActivityViewShow
end
function SystemProxy.setSystemViewShow(self,_bool)
    self.m_isSystemViewShow=_bool
end
function SystemProxy.isSystemViewShow(self)
    return self.m_isSystemViewShow
end
function SystemProxy.setChatWindowShow(self,_bool)
    self.m_isChatWindowShow=_bool
end
function SystemProxy.isChatWindowShow(self)
    return self.m_isChatWindowShow
end
function SystemProxy.setTaskGuideShow(self,_bool)
    self.m_isTaskGuideShow=_bool
end
function SystemProxy.isTaskGuideShow(self,_bool)
    return self.m_isTaskGuideShow
end

return SystemProxy

