-- 
-- @Author: LaoY
-- @Date:   2018-08-08 20:39:32
-- 

ObjectData = ObjectData or class("ObjectData", BaseMessage)
local ObjectData = ObjectData
function ObjectData:ctor(message)
    self.buff_effect_type_list = {}
    if message then
        self:InitMessage(message)
    end
end

function ObjectData:dctor()
    self:ChangeData("destroy", self)
    BuffManager:GetInstance():RemoveObject(self.uid)
end

function ObjectData:clear()
    ObjectData.super.clear(self)
    self.hp = self.hpmax
end

function ObjectData:InitMessage(message)
    self.uid = message.uid
    self.name = message.name
    self.type = message.type
    self.coord = message.coord
    self.state = message.state
end

function ObjectData:AddEvent()
    local function func(value)
        self:SetHp(value)
    end
    self:BindData("attr.hp", func)

    local function func(value)
        self:SetMaxHp(value)
    end
    self:BindData("attr.hpmax", func)

    local function func(value)
        self:SetSpeed(value)
    end
    self:BindData("attr.speed", func)
end

function ObjectData:Revive()
    self:ChangeData("hp", self.hpmax or 0)
end

function ObjectData:SetHp(hp, message_time)
    local is_message_time = message_time ~= nil
    message_time = message_time or Time.time
    if not self.last_set_hp_time or message_time > self.last_set_hp_time or hp == 0 or hp < self.hp then
        self.last_set_hp_time = message_time
        self:ChangeData("hp", hp)
    end
end

function ObjectData:SetMaxHp(hp)
    -- self.hpmax = hp
    self:ChangeData("hpmax", hp)
end

function ObjectData:SetSpeed(speed)
    self:ChangeData("speed", speed)
end

function ObjectData:SetCoord(coord)
    self:ChangeData("coord", coord)
end

function ObjectData:InitBuff()
    if not self.buffs then
        return
    end
    for k, p_buff in pairs(self.buffs) do
        BuffManager:GetInstance():UpdateBuff(self.uid, p_buff)
    end
end

function ObjectData:AddBuffList(p_buff_list)
    for i = 1, #p_buff_list do
        -- self:AddBuff(p_buff_list[i],true)
        self:ChangeBuff(p_buff_list[i], true)
    end
    self:BrocastData("buffs")
end

function ObjectData:AddBuff(p_buff, ingore_update)
    self.buffs = self.buffs or {}
    self.buffs[#self.buffs + 1] = p_buff
    self:ChangeBuffTypeList(p_buff)
    -- BuffManager:GetInstance():AddBuff(self.uid,p_buff)
    BuffManager:GetInstance():UpdateBuff(self.uid, p_buff)
    if not ingore_update then
        self:BrocastData("buffs")
    end
end

function ObjectData:RemoveBuffList(buff_id_list)
    for i = 1, #buff_id_list do
        self:RemoveBuff(buff_id_list[i], true)
    end
    self:BrocastData("buffs")
end

function ObjectData:RemoveBuff(buff_id, ingore_update)
    self.buffs = self.buffs or {}
    local index = self:GetBuffListIndexByID(buff_id)
    if index then
        local p_buff = table.remove(self.buffs, index)
        BuffManager:GetInstance():RemoveBuff(self.uid, p_buff.id)
        self:ChangeBuffTypeList()
    end
    if not ingore_update then
        self:BrocastData("buffs")
    end
end

function ObjectData:ChangeBuffList(p_buff_list)
    for i = 1, #p_buff_list do
        self:ChangeBuff(p_buff_list[i], true)
    end
    self:BrocastData("buffs")
end

function ObjectData:ChangeBuff(p_buff, ingore_update)
    self.buffs = self.buffs or {}
    local index = self:GetBuffListIndexByID(p_buff.id)
    if index then
        BuffManager:GetInstance():UpdateBuff(self.uid, p_buff)
        self.buffs[index] = p_buff
    else
        self:AddBuff(p_buff, ingore_update)
    end
    if not ingore_update then
        self:BrocastData("buffs")
    end
end

function ObjectData:GetBuffListIndexByID(buff_id)
    if not self.buffs then
        return nil
    end
    local length = #self.buffs
    for i = 1, length do
        local p_buff = self.buffs[i]
        if p_buff.id == buff_id then
            return i
        end
    end
    return nil
end

function ObjectData:GetBuffByID(buff_id)
    local index = self:GetBuffListIndexByID(buff_id)
    if not index then
        return
    end
    return self.buffs[index]
end

function ObjectData:GetBuffList()
    return self.buffs
end

function ObjectData:ChangeBuffTypeList(p_buff)
    if p_buff then
        local cf = Config.db_buff[p_buff.id]
        if cf then
            self.buff_effect_type_list[cf.effect] = p_buff.id
        end
    else
        self.buff_effect_type_list = {}
        for k, p_buff in pairs(self.buffs) do
            local cf = Config.db_buff[p_buff.id]
            if cf then
                self.buff_effect_type_list[cf.effect] = p_buff.id
            end
        end
    end
end

function ObjectData:IsHaveBuffEffectType(buff_effect_type)
    -- if not self.buffs then
    --     return false
    -- end
    -- for k,p_buff in pairs(self.buffs) do
    --     local cf = Config.db_buff[p_buff.id]
    --     if cf and cf.effect == buff_effect then
    --         return true
    --     end
    -- end
    -- return false
    return self.buff_effect_type_list[buff_effect_type]
end

function ObjectData:IsContainBuffEffectType(buff_effect_type_list)
    for k, buff_effect_type in pairs(buff_effect_type_list) do
        local bo = self:IsHaveBuffEffectType(buff_effect_type)
        if bo then
            return true, buff_effect_type
        end
    end
    return false
end