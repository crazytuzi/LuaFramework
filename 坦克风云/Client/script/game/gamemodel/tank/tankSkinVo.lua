tankSkinVo = {}
function tankSkinVo:new()
    local nc = {}
    setmetatable(nc, self)
    self.__index = self
    return nc
end

function tankSkinVo:initSkin(skinId, data)
    self.id = skinId
    self.lv = data[1] or 1
    self.et = data[2] or 0 --皮肤生效结束时间
end
