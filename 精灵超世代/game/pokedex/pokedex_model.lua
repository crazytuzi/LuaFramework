-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-05-26
-- --------------------------------------------------------------------
PokedexModel = PokedexModel or BaseClass()

function PokedexModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function PokedexModel:config()
    self.have_list = {}
    self.all_data = {}
    self.disband_list = {}
end

function PokedexModel:setHavePartner(data)
    if not data then return end
    self.all_data = data
    local list =data.partners or {}
    for i,data in pairs(list) do
        self.have_list[data.partner_id] = true
    end
end

function PokedexModel:getAllData()
    if self.all_data then
        return self.all_data
    end
end

-- function PokedexModel:updateAllData()
--     -- body
-- end
function PokedexModel:isHavePartner(bid)
    return self.have_list[bid]
end

--- 设置分解过的伙伴信息
function PokedexModel:setDisbandPartner(id)
    self.disband_list[id] = true
end

--- 判断是否是分结果过伙伴
function PokedexModel:isDisbandPartner(id)
    return self.disband_list[id]
end

function PokedexModel:__delete()
end