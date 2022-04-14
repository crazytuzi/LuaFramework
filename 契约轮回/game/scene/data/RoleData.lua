-- 
-- @Author: LaoY
-- @Date:   2018-08-02 17:03:22
-- 
-- pic_url = 1;  // 头像地址
-- pic_vsn = 2;  // 头像版本号
-- title   = 3;  // 称号
-- equip   = 4;  // 装备外观
-- fashion = 5;  // 时装外观
-- partner = 6;  // 伙伴外观(坐骑等)
-- suit_id = 7;  // 套装id
-- mount   = 8;  // 当前的坐骑资源id
-- wing    = 9;  // 当前的翅膀资源id
-- talis   = 10; // 当前的法宝资源id
-- jobtitle = 11; //头衔服务的返回信息

RoleData = RoleData or class("RoleData",ObjectData)
local RoleData = RoleData
function RoleData:ctor()
	self.body_res_id = self.gender == 1 and 11002 or 12002
end

function RoleData:dctor()
	
end

function RoleData:GetShapeShiftBuff()
    if not self.buffs then
        return nil
    end
    for k,v in pairs(self.buffs) do
        local cf = Config.db_buff[v.id]
        if cf and cf.aim == 2 then
            return v
        end
    end
    return nil
end

function RoleData:GetFigureSkin(key)
	return self.figure and self.figure[key] and self.figure[key].skin
end

function RoleData:Revive()
	local hpmax = self.hpmax
	-- if self.attr and self.attr.hpmax then
	-- 	hpmax = self.attr.hpmax
	-- end 
	self:ChangeData("hp",hpmax or 0)
end

--[[
    @author ling
    @des    是否鼓舞了
    @return
        bool    是否存在
        number  增加倍数
        number  buff id
--]]
function RoleData:IsAddGuWuBuff()
    return self:IsAddExpBuff(3)
end

--[[
    @author LaoY
    @des    是否存在经验药水的buff
    @return
        bool    是否存在
        number  增加倍数
        number  buff id
--]]
function RoleData:IsAddExp1Buff()
    return self:IsAddExpBuff(5)
end

--[[
    @author LaoY
    @des    是否存在经验符的buff
    @return
        bool    是否存在
        number  增加倍数
        number  buff id
--]]
function RoleData:IsAddExp2Buff()
    return self:IsAddExpBuff(6)
end
--983,982
function RoleData:IsBossTired(tiredGroup)
    if not tiredGroup then
        return;
    end
    if not self.buffs then
        return false
    end
    for k,p_buff in pairs(self.buffs) do
        local cf = Config.db_buff[p_buff.id]
        if cf and cf.group == tiredGroup then
            return p_buff.value >= 3;
        end
    end
    return false;
end

--[[
    @author LaoY
    @des    是否存在经验buff
    @return
        bool    是否存在
        number  增加倍数
        number  buff id
--]]
function RoleData:IsAddExpBuff(exp_group)
    if not self.buffs then
        return false,0,nil
    end
    for k,p_buff in pairs(self.buffs) do
        local cf = Config.db_buff[p_buff.id]
        if cf and cf.group == exp_group then
            local attrs = String2Table(cf.attrs)
            for k,v in pairs(attrs) do
                if v[1] == enum.ATTR.ATTR_EXP_PER then
                    return true,v[2]/10000,p_buff.id
                end
            end
            return true,0,p_buff.id
        end
    end
    return false,0,nil
end

function RoleData:IsContainBuffGroup(group)
    if not self.buffs then
        return false
    end
    for k,p_buff in pairs(self.buffs) do
        --local cf = Config.db_buff[p_buff.id]
        if p_buff.group == group then
            return true
        end
    end
    return false
end

function RoleData:IsCanMoveByBuff()
    -- 220210001 沉默buff id
    -- 眩晕 沉默 定身 麻痹 不能移动
    local buff_effect_type_list = {
        enum.BUFF_EFFECT.BUFF_EFFECT_DIZZY,
        enum.BUFF_EFFECT.BUFF_EFFECT_SILENT,
        enum.BUFF_EFFECT.BUFF_EFFECT_IMMOB,
        enum.BUFF_EFFECT.BUFF_EFFECT_PALSY,
    }
    local bo,buff_effect_type = self:IsContainBuffEffectType(buff_effect_type_list)
    return not bo,buff_effect_type
end

function RoleData:IsCanAttackByBuff()
    -- 眩晕 沉默 混乱 定身 麻痹 不能攻击
    local buff_effect_type_list = {
        enum.BUFF_EFFECT.BUFF_EFFECT_DIZZY,
        enum.BUFF_EFFECT.BUFF_EFFECT_SILENT,
        enum.BUFF_EFFECT.BUFF_EFFECT_CHAOS,
        enum.BUFF_EFFECT.BUFF_EFFECT_IMMOB,
        enum.BUFF_EFFECT.BUFF_EFFECT_PALSY,
    }
    local bo,buff_effect_type = self:IsContainBuffEffectType(buff_effect_type_list)
    return not bo,buff_effect_type
end