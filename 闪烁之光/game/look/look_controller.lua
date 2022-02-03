-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--英雄查看模块
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: cloud@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-07-07
-- --------------------------------------------------------------------
LookController = LookController or BaseClass(BaseController)

function LookController:config()
    self.model = LookModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function LookController:getModel()
    return self.model
end

function LookController:registerEvents()
end

function LookController:registerProtocals()
    self:RegisterProtocal(11061, "handle11061")     --查看对方英雄信息
    self:RegisterProtocal(11062, "handle11062")     --查看对方分享英雄信息
end


--查看对方英雄信息
function LookController:sender11061(r_rid,r_srvid,partner_id, attr_data)
    local protocal ={}
    protocal.r_rid = r_rid
    protocal.r_srvid = r_srvid
    protocal.partner_id = partner_id
    if self.dic_attr_data == nil then
        self.dic_attr_data = {}
    end
    local key_str = string.format("%s_%s_%s", r_rid, r_srvid, partner_id)
    self.dic_attr_data[key_str] = attr_data
    self:SendProtocal(11061,protocal)
end
function LookController:clearAttrData()
    self.dic_attr_data = nil
end
function LookController:handle11061( data )
    message(data.msg)
    if data.bid ~= 0 then
        local config = Config.PartnerData.data_partner_base[data.bid]
        local camp_type = 1
        if config then
            camp_type = config.camp_type
        end
        data.camp_type = camp_type
        --特殊位面 未改完
        local key_str = string.format("%s_%s_%s",data.r_rid, data.r_srvid, data.partner_id)
        if self.dic_attr_data and self.dic_attr_data[key_str] then
            data.atk = self.dic_attr_data[key_str].atk or data.atk
            data.hp = self.dic_attr_data[key_str].hp or data.hp
            data.power = self.dic_attr_data[key_str].power or data.power
        end

        HeroController:getInstance():openHeroTipsPanel(true, data)
    end
end
--查看对方分享英雄信息
function LookController:sender11062(id, srv_id)
    local protocal ={}
    protocal.id = id
    protocal.srv_id = srv_id
    self:SendProtocal(11062,protocal)
end
function LookController:handle11062( data )
    message(data.msg)
    if data.bid ~= 0 then
        local config = Config.PartnerData.data_partner_base[data.bid]
        local camp_type = 1
        if config then
            camp_type = config.camp_type
        end
        data.camp_type = camp_type
        HeroController:getInstance():openHeroTipsPanel(true, data)
    end
end
function LookController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end
