--[[
******跨服个人战数据管理器*******

	-- by quanhuan
	-- 2016/4/12
	
]]

local XiaKeExchangeManager = class("XiaKeExchangeManager")

XiaKeExchangeManager.changeEquip = "XiaKeExchangeManager.changeEquip"
XiaKeExchangeManager.changeRole = "XiaKeExchangeManager.changeRole"

function XiaKeExchangeManager:ctor(data)
    TFDirector:addProto(s2c.XIE_KE_EXCHANGE_EQUIP, self, self.onChangeEquip)
    TFDirector:addProto(s2c.XIA_KE_HEREDITARY, self, self.onChangeRole)
    self:restart()
end

function XiaKeExchangeManager:restart()
end

function XiaKeExchangeManager:requestChangeEquip(rolegmId1,rolegmId2)
    showLoading()
    local msg = {
        rolegmId1,
        rolegmId2
    }
    TFDirector:send(c2s.XIE_KE_EXCHANGE_EQUIP,msg)
end

function XiaKeExchangeManager:requestChangeRole(rolegmId1,rolegmId2)
    showLoading()
    local msg = {
        rolegmId1,
        rolegmId2
    }
    TFDirector:send(c2s.XIA_KE_HEREDITARY,msg)
end

function XiaKeExchangeManager:onChangeEquip(event)
    hideLoading()
    TFDirector:dispatchGlobalEventWith(XiaKeExchangeManager.changeEquip, event.data)
end

function XiaKeExchangeManager:onChangeRole(event)
    hideLoading()
    TFDirector:dispatchGlobalEventWith(XiaKeExchangeManager.changeRole, event.data)
end

function XiaKeExchangeManager:openEquipChangeLayer()
    local layer  = require("lua.logic.role_new.RoleEquipChangeLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function XiaKeExchangeManager:IsOpenEquipChange()
    local teamLev = MainPlayer:getLevel()
    local openLev = FunctionOpenConfigure:getOpenLevel(2204)
    if teamLev < openLev then
        return false
    else
        return true
    end
end

--转换丹数量
function XiaKeExchangeManager:getZhuanhuanNeedNum()
    return 3
end

return XiaKeExchangeManager:new()