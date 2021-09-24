--装备面板--------------------------------------------------------------------------------------------------
local RoleViewMediator=classGc(mediator, function(self, _view)
    self.name = "RoleViewMediator"
    self.view = _view

    self:regSelf()
end)


local  TAGBTN_ROLE   = 1
local  TAGBTN_EQUIP  = 2
local  TAGBTN_TITLE  = 3
local  TAGBTN_SKILL  = 4
local  TAGBTN_GILDED = 5

RoleViewMediator.protocolsList={
    _G.Msg["ACK_ROLE_ATTR_ADD_REPLY"], -- (1385手动) -- [1385]属性加成返回 -- 角色
    _G.Msg["ACK_ROLE_ATTR_FLAG_REPLY"], -- [1396]是否有属性加成返回 -- 角色 
    _G.Msg["ACK_TITLE_LIST_BACK"],
    _G.Msg["ACK_TITLE_DRESS_RES"],
    _G.Msg["ACK_TITLE_NEW_RES"],
    _G.Msg["ACK_TITLE_REFRESH"],
}
    
RoleViewMediator.commandsList={
    CRoleViewCommand.TYPE,
    CCharacterInfoUpdataCommand.TYPE,
    CCharacterEquipInfoUpdataCommand.TYPE,
    CloseWindowCommand.TYPE,
    CPropertyCommand.TYPE,
    CFunctionOpenCommand.TYPE
}

function RoleViewMediator.getView(self)
    return self.view
end
function RoleViewMediator.setEquipView(self,_view)
    self.m_equipView=_view
end
function RoleViewMediator.setInfoView(self,_infoView)
    self.m_infoView=_infoView
end

function RoleViewMediator.processCommand(self,_command)
    local comType=_command:getType()
    if comType==CRoleViewCommand.TYPE then  --人物面板发给 属性页面
        if _command.isZLF then return end
        local uid=_command.uid
        if self.m_infoView then
            self.m_infoView:chuangeRole(uid)
        end
        if self.m_bagView then
            self.m_bagView:chuangeRole(uid)
        end
    elseif comType==CCharacterInfoUpdataCommand.TYPE then
        print("数据改变 人物属性面板更新")
        if self.m_infoView then
            self.m_infoView:updateInfo()
        end
    elseif comType==CCharacterEquipInfoUpdataCommand.TYPE then
        if self.m_equipView then
            self.m_equipView:updateEquip()
        end
    elseif _command :getType() == CloseWindowCommand.TYPE then
        if _command :getData() == _G.Const.CONST_FUNC_OPEN_ROLE then
            self :getView() : closeWindow()
        end
    elseif comType==CPropertyCommand.TYPE then
        if _command:getData()==CPropertyCommand.POWERFUL then
            self.view:playerpower()
        end
    elseif _command:getType()==CFunctionOpenCommand.TYPE then
        if _command:getData()==CFunctionOpenCommand.TIMES_UPDATE then
            self.view:chuangIconNum(_command.sysId,_command.number)
        end
    end
    -- return false
end

function RoleViewMediator.ACK_ROLE_ATTR_ADD_REPLY( self, _ackMsg)
    local _count = _ackMsg.count 
    local _data  = _ackMsg.msg_xxx
    print("RoleViewMediator.ACK_ROLE_ATTR_ADD_REPLY=",_count,_data)
    self.m_infoView:setInfoMsg(_ackMsg)
end

function RoleViewMediator.ACK_ROLE_ATTR_FLAG_REPLY( self, _ackMsg)
    local _flag  = _ackMsg.flag 
    print("RoleViewMediator.ACK_ROLE_ATTR_FLAG_REPLY=",_flag)
end

function RoleViewMediator.ACK_TITLE_LIST_BACK(self,_ackMsg)
	print("count:",#_ackMsg.data)
    self.view:setTitleMsg(_ackMsg)
end

function RoleViewMediator.ACK_TITLE_DRESS_RES(self,_ackMsg)
    self.view:updateTitle()
end

function RoleViewMediator.ACK_TITLE_NEW_RES(self,_ackMsg)
    self.view:updateFlag()
end

function RoleViewMediator.ACK_TITLE_REFRESH(self,_ackMsg)
	local msg = REQ_TITLE_REQUEST()
	_G.Network: send(msg)
end

return RoleViewMediator