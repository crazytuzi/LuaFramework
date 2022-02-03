-- --------------------------------------------------------------------
-- 自由移动场景的单位数据结构,可以用于角色,也可以用于单位
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
RoleSceneVo = RoleSceneVo or BaseClass(EventDispatcher)

RoleSceneVo.unittype = {
    none = 0,
    role = 1,
    unit = 2
}

RoleSceneVo.sub_unittype = {
    ele = 3,
    npc = 4
}

RoleSceneVo.lookstype = {
    body = 1,               -- 形象
    buff = 2,               -- 暂用于首席争霸的我分高buff特效外观
}

function RoleSceneVo:__init()
    self.rid            = 0
    self.srv_id         = ""
    self.name           = ""
    self.speed          = 0
    self.dir            = 0
    self.x              = 0
    self.y              = 0
    self.status         = 0
    self.event          = 0
    self.looks          = {}
    self.face           = 0
    self.lev            = 0
    self.sex            = 1
    self.avatar         = 0                 -- 头像框

    self.battle_id      = 1
    self.id             = 0
    self.base_id        = 0
    self.lev            = 0
    self.sub_type       = 0
    self.layer          = 1                 -- 这个单位所属于的层级

    self.scene_id       = 0
    self.type           = 0

    self.hide_self      = false             -- 是否隐藏或者显示自身

    self.unit_type      = 0                 -- 怪物类型。小怪或者boss
end

function RoleSceneVo:initAttributeData(data_list)
    if data_list == nil or next(data_list) == nil then return end
    for k, v in pairs(data_list) do
        if k == "looks" then
            self:setLooks(v, true)
        elseif type(v) ~= "table" then
            self:setRoleAttribute(k, v)
        end
    end
end

function RoleSceneVo:getSpeed()
    return self.speed * 0.1
end
function RoleSceneVo:getNowPos()
    return self.x,self.y
end
--==============================--
--desc:更新角色外观
--time:2017-10-12 04:31:18
--@data_list:
--@type:是部分更新还是全部更新
--@return 
--==============================--
function RoleSceneVo:setLooks(data_list, type)
    local is_change = (data_list and next(data_list) ~= nil)
    data_list = data_list or {}
    -- if type == true then
    --     self.looks = {}
    -- end
    self.looks = {}
    local looksVo
    for k1, v1 in pairs(data_list) do
        looksVo = self.looks[v1.looks_type]
        -- 如果这个looks_model 和looks_val 以及 looks_str 都为空就是移除掉这个looks,这逻辑貌似走不通，我屏蔽了，来一次就请一次
        if looksVo then
            if v1.looks_model == 0 and v1.looks_val == 0 and v1.looks_str == "" then
                self.looks[v1.looks_type] = nil
            else
                looksVo:setAntVo(v1)
            end
        else
            looksVo = LooksVo.New()
            looksVo:setAntVo(v1)
            self.looks[v1.looks_type] = looksVo
        end
    end

    if is_change == true then
        self:dispatchUpdateAttrByKey("looks", self.looks)
    end
end

--==============================--
--desc:获取当前显示的外观
--time:2017-10-12 05:03:03
--@return 
--==============================--
function RoleSceneVo:getBodyRes()
    local body_res = nil
    if self.type == self.unittype.role then
	    local looks_vo = self:getLooksByType(RoleSceneVo.lookstype.body)
        if looks_vo ~= nil and looks_vo.looks_val ~= nil and looks_vo.looks_val ~= 0 then
            --有时装就不读伙伴表了，有时装读时装表
            if looks_vo.looks_mode == 1 then 
                local fashion_to_config = Config.ClothesData.data_fashion_to_partner[looks_vo.looks_val]
                if not fashion_to_config then return end
                if fashion_to_config and fashion_to_config[1] and fashion_to_config[1].partner_bid then
                    local partner_bid = fashion_to_config[1].partner_bid
                    local fashion_config = Config.ClothesData.data_clothes_data[partner_bid]
                    if fashion_config and fashion_config[looks_vo.looks_val] then 
                        body_res =fashion_config[looks_vo.looks_val].model or ""
                    end
                end
            else
                local config = Config.PartnerData.data_partner[looks_vo.looks_val]
                if config ~= nil then
                    body_res = config.res_id
                end
            end
        end
    elseif self.type == self.unittype.unit then
        local config = Config.UnitData.data_unit(self.base_id)
        if config ~= nil then
            body_res = config.body_id
        end
    end
    return body_res
end

function RoleSceneVo:getLooksByType(type)
    return self.looks[type] or {}
end

function RoleSceneVo:setRoleAttribute(key, value) 
    if self[key] ~= value then
        self[key] = value
        self:dispatchUpdateAttrByKey(key, value)
    end
end

function RoleSceneVo:dispatchUpdateAttrByKey(key, value)
    self:Fire(RolesceneEvent.UPDATE_ROLE_ATTRIBUTE, key, value)
end