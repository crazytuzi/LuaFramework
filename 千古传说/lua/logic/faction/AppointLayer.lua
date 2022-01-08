--[[
******帮派任命界面*******

	-- by quanhuan
	-- 2015/11/3
	
]]

local AppointLayer = class("AppointLayer",BaseLayer)

function AppointLayer:ctor(data)
	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.faction.Appoint")
end

function AppointLayer:initUI( ui )
	self.super.initUI(self, ui) 

    self.btnClose = TFDirector:getChildByPath(ui, "btn_close")
    self.btn_sr = TFDirector:getChildByPath(ui, "btn_sr")
    self.btn_DeputyLeader = TFDirector:getChildByPath(ui, "btn_DeputyLeader")
    self.btn_member = TFDirector:getChildByPath(ui, "btn_member")
    self.btn_delete = TFDirector:getChildByPath(ui, "btn_delete")
end

function AppointLayer:removeUI()
   	self.super.removeUI(self)
end

function AppointLayer:onShow()
    self.super.onShow(self)
end

function AppointLayer:registerEvents()

	self.super.registerEvents(self)

    self.btnClose:addMEListener(TFWIDGET_CLICK, audioClickfun(self.closeButtonClick))
    self.btn_sr:addMEListener(TFWIDGET_CLICK, audioClickfun(self.srButtonClick))
    self.btn_sr.logic = self
    self.btn_DeputyLeader:addMEListener(TFWIDGET_CLICK, audioClickfun(self.DeputyLeaderButtonClick))
    self.btn_DeputyLeader.logic = self
    self.btn_member:addMEListener(TFWIDGET_CLICK, audioClickfun(self.memberButtonClick))
    self.btn_member.logic = self
    self.btn_delete:addMEListener(TFWIDGET_CLICK, audioClickfun(self.deleteButtonClick))
    self.btn_delete.logic = self

end

function AppointLayer:removeEvents()

    self.super.removeEvents(self)

    self.btnClose:removeMEListener(TFWIDGET_CLICK)
    self.btn_sr:removeMEListener(TFWIDGET_CLICK)
    self.btn_DeputyLeader:removeMEListener(TFWIDGET_CLICK)
    self.btn_member:removeMEListener(TFWIDGET_CLICK)
    self.btn_delete:removeMEListener(TFWIDGET_CLICK)
end

function AppointLayer:dispose()
    self.super.dispose(self)
end

function AppointLayer:refreshWindow()
    
end

function AppointLayer.closeButtonClick( btn )
    AlertManager:close()
end
function AppointLayer.srButtonClick( btn )
    local self = btn.logic
    local info = FactionManager:getFactionInfo()
    if FactionManager:getPostInFaction() ~= 1 then
        --toastMessage("权限不够")
        toastMessage(localizable.common_no_power)
        return
    end
    if info.state == 0 then
        FactionManager:requestAppoint(OperateType.Demise, self.playerId)
    elseif info.state == 1 then
        --toastMessage("正在禅让")
        toastMessage(localizable.appointLayer_text1)
    elseif info.state == 2 then
        --toastMessage("正在解散")
        toastMessage(localizable.appointLayer_text2)
    elseif info.state == 3 then
        --toastMessage("正在弹劾")
        toastMessage(localizable.appointLayer_text3)
    end
end

function AppointLayer.DeputyLeaderButtonClick( btn )
    local self = btn.logic

    if FactionManager:getPostInFaction() ~= 1 then
        toastMessage(localizable.common_no_power)
        return
    end

    local info = FactionManager:getFactionInfo()
    if info.state ~= 0 then
        local delayTime = math.floor(info.operateTime/1000) - MainPlayer:getNowtime()
        if delayTime <= 0 then
            toastMessage(localizable.common_no_power)
            FactionManager:requestMemberInfo()
            return
        end
    end

    local post = FactionManager:getMemberPost( self.playerId )
    if post == FactionManager.DeputyLeader then
        toastMessage(localizable.appointLayer_text4)
    elseif FactionManager:getDeputyLeaderNum() >= 2 then
        toastMessage(localizable.appointLayer_text5)
    else
        FactionManager:requestAppoint(OperateType.DeputyLeader, self.playerId)
    end
end
function AppointLayer.memberButtonClick( btn )
    local self = btn.logic
    if FactionManager:getPostInFaction() ~= 1 then
        toastMessage(localizable.common_no_power)
        return
    end    
    local info = FactionManager:getFactionInfo()
    if info.state ~= 0 then
        local delayTime = math.floor(info.operateTime/1000) - MainPlayer:getNowtime()
        if delayTime <= 0 then
            toastMessage(localizable.common_no_power)
            FactionManager:requestMemberInfo()
            return
        end
    end

    local post = FactionManager:getMemberPost( self.playerId )
    if post == FactionManager.Member then
        toastMessage(localizable.appointLayer_text6)
    else    
        FactionManager:requestAppoint(OperateType.Member, self.playerId)
    end
end

function AppointLayer.deleteButtonClick( btn )
    local self = btn.logic
    
    if FactionManager:getPostInFaction() ~= 1 then
        toastMessage(localizable.common_no_power)
        return
    end

    local info = FactionManager:getFactionInfo()
    if info.state ~= 0 then
        local delayTime = math.floor(info.operateTime/1000) - MainPlayer:getNowtime()
        if delayTime <= 0 then
            toastMessage(localizable.common_no_power)
            FactionManager:requestMemberInfo()
            return
        end
    end

    local info = FactionManager:getMemberInfoByPlayerid( self.playerId )
    --local msg = "是否确认请"..info.name.."离开帮派？"
    local msg = stringUtils.format(localizable.appointLayer_t_ren_tips,info.name)
    CommonManager:showOperateSureLayer(
        function()
            FactionManager:requestAppoint(OperateType.Leave, self.playerId)
        end,
        function()
            AlertManager:close()
        end,
        {
        --title = "请离",
        title = localizable.appointLayer_out,
        msg = msg,
        }
    )
end

function AppointLayer:setPlayerId( playerId )
    self.playerId = playerId
end
return AppointLayer