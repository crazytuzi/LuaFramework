--[[
******跨服个人战数据管理器*******

	-- by quanhuan
	-- 2016/4/12
	
]]

local LianTiManager = class("LianTiManager")

LianTiManager.roleLianTiInfo = "LianTiManager.roleLianTiInfo"
LianTiManager.lianTiResult = "LianTiManager.lianTiResult"

function LianTiManager:ctor(data)
    TFDirector:addProto(s2c.XIA_KE_FORGING, self, self.onRoleLianTiInfo)
    self:restart()
end

function LianTiManager:restart()
end

function LianTiManager:requestLianti(rolegmId1,pos)
    showLoading()
    self.isLianTi = true
    local msg = {
        rolegmId1,
        pos
    }
    TFDirector:send(c2s.FORGING_THE_BODY_REQUEST,msg)
end

function LianTiManager:onRoleLianTiInfo(event)
    hideLoading()
    local data = event.data.xiake or {}
    for i=1,#data do
        local cardRole = CardRoleManager:getRoleByGmid(data[i].roleId)
        cardRole:setLianTiData(data[i].data)
    end
    if self.isLianTi == true then
        self.isLianTi = false
        TFDirector:dispatchGlobalEventWith(LianTiManager.lianTiResult, data)
    end
    TFDirector:dispatchGlobalEventWith(LianTiManager.roleLianTiInfo, data)
end

function LianTiManager:openEquipChangeLayer()
    local layer  = require("lua.logic.role_new.RoleEquipChangeLayer"):new()
    AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_1)
    AlertManager:show()
end

function LianTiManager:IsOpen()
    return true
end

function LianTiManager:getPointAttriType(point,quality)
    self.pointAttriType = self.pointAttriType or {}
    self.pointAttriType[point] = self.pointAttriType[point] or {}
    if self.pointAttriType[point][quality] == nil then
        for item in LianTiData:iterator() do
            if item.acupoint == point then
                local attri = item:getAttributeValue(quality)
                if attri then
                    self.pointAttriType[point][quality] = attri.index
                    break
                end
            end
        end
    end
    return self.pointAttriType[point][quality]
end

function LianTiManager:getMaxPointLvl(point)
    self.maxPointLvl = self.maxPointLvl or {}
    if self.maxPointLvl[point] == nil then
        local lvl = 0
        for item in LianTiData:iterator() do
            if item.acupoint == point then
                if item.level > lvl then
                    lvl = item.level
                end
            end
        end
        self.maxPointLvl[point] = lvl
    end
    return self.maxPointLvl[point]
end

return LianTiManager:new()