-- --------------------------------------------------------------------
-- 剧情单位使用到的数据结构
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
UnitVo = UnitVo or BaseClass(EventDispatcher)

-- 场景单位的类型枚举,包含了角色,这个从kv里面枚举出来的
UnitVo.type = {
    NPC         = 1,            -- NPC
    DOOR        = 102,          -- 传送阵
}

function UnitVo:__init()
    self.battle_id      = 1
	self.id 			= 0
    self.bid            = 0
	self.type 			= 0
	self.name 			= ""
	self.x 				= 0
	self.y 				= 0
    self.dir            = 4
    self.body_res       = ""
    self.speed          = 1             -- 暂时没什么用,主要用在众神战场的角色跑步上面
    self.unit_type      = 2

    -- --------------特殊数据结构,众神战场会用到,不另作
    self.camp           = 0               -- 阵营
    self.lev            = 0
    self.status         = 0               -- 状态(0:正常, 1:战斗, 2:离线)
    self.effect         = 0               -- 特效(变身等)
    self.score          = 0
    self.win_acc        = 0
    self.pos_x          = 0               -- 格子位置
    self.pos_y          = 0
    self.skill_effect   = {}
    self.is_speed_up    = false           -- 是否在加速状态下
end

function UnitVo:getKey()
    return getNorKey(self.battle_id, self.id)
end

function UnitVo:initAttributeData(data)
	data = data or {}
    for k, v in pairs(data) do
        self:setUnitAttribute(k, v)
    end
end

function UnitVo:setUnitAttribute(key, value)
    if key == "type" then return end --这个类型是服务端类型,客户端不需要的,在外部已经设置了类型了
    if self[key] ~= value then
        self[key] = value
        if key == "speed" then -- 移动速度
            self.move_speed = (value or 0)/10
        end
    end
    self:dispatchUpdateAttrByKey(key, value)
end

function UnitVo:dispatchUpdateAttrByKey(key, value)
    if key == "x" or key == "y" then return end
    self:Fire(SceneEvent.UPDATE_UNIT_ATTRIBUTE, key, value)
end
