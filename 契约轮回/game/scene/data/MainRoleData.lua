-- 
-- @Author: LaoY
-- @Date:   2018-08-02 17:02:31
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

MainRoleData = MainRoleData or class("MainRoleData", RoleData)
local MainRoleData = MainRoleData

function MainRoleData:ctor()
    self.uid = self.id
    self.last_level = -1
    self.level = 0
    self.body_res_id = 11001

    self.attr = {}

    if self.event ~= RoleInfoModel.Event then
        self.event:destroy()
        self.event = nil
    end
    self.event = RoleInfoModel.Event

    self:SetDefalutValue()
    self:AddEvent()
end


function MainRoleData:clear()
    
end

-- 对应的艺术字 战力属性改变需要飘字
local map = {
    ["attr.hpmax"]     = "a",    -- 生命上限
    ["attr.att"]       = "b",    -- 攻击
    ["attr.def"]       = "c",    -- 防御
    ["attr.wreck"]     = "d",    -- 破甲
    ["attr.hit"]       = "e",    -- 命中
    ["attr.miss"]      = "f",    -- 闪避
    ["attr.crit"]      = "g",    -- 暴击
    ["attr.tough"]     = "h",    -- 坚韧
    ["attr.holy_att"]  = "j",    -- 神圣(五行)攻击
    ["attr.holy_def"]  = "i",    -- 神圣(五行)防御   
}
function MainRoleData:ChangeData(data_name, value,ingore_update,is_udpate_power)
    if data_name == "boss_belong" then
        SceneManager:GetInstance():GetMainRole().name_container:ShowBelong(false);
    elseif data_name == "power" then
        if self.power and is_udpate_power then
            GlobalEvent:Brocast(MainEvent.ChangePower,self.power,value,nil)
        end
    elseif map[data_name] then
        if map[data_name] and is_udpate_power then
            local attr_tab = {}
            local old_value = self:GetValue(data_name)
            if old_value and value > old_value then
                attr_tab[#attr_tab+1] = {key = map[data_name],value = value- old_value}
                GlobalEvent:Brocast(MainEvent.ChangePower,self.power,self.power,attr_tab)
            end
        end
    elseif data_name == "money" then
        for money_id,money_value in pairs(value) do
            local key = Constant.GoldIDMap[money_id]
            if key then
                if money_id == enum.ITEM.ITEM_LEVEL then
                    self.last_level = self.level
                    if money_value > self.last_level then
                        self.level = money_value
                        if not AppConfig.Debug then
                            PlatformManager:GetInstance():uploadUserDataByRoleData(self,3)
                        end
                        GlobalEvent:Brocast(EventName.ChangeLevel,money_value)
                    end
                end
                MainRoleData.super.ChangeData(self, key, money_value, ingore_update)
            end
        end
        -- GlobalEvent:Brocast(BagEvent.UpdateGoods)
        self:BrocastData(data_name)
        return
    end
    MainRoleData.super.ChangeData(self, data_name, value,ingore_update)
end

function MainRoleData:ChangeMessage(message,isThorough)
    if not self.uid then
        self.uid = message.id
    end
    local changlevelEventFlag = false;
    local is_first;
    if message.level and message.level > self.level then
        is_first = self.level == 0
        self.level = message.level
        changlevelEventFlag = true;

    end

    if message.money then
        for money_id,money_value in pairs(message.money) do
            local money_key = Constant.GoldIDMap[money_id]
            if money_key then
               self[money_key] = money_value
            end
        end
    end

    -- buff只读场景里面的
    local scene_buffs = SceneManager:GetInstance():GetSceneBuff()
    if scene_buffs then
        message.buffs = scene_buffs
    end
    MainRoleData.super.ChangeMessage(self, message,isThorough)

    self.uid = self.id
    
    self.clearKeyList = {}

    for k,v in pairs(message) do
        self.clearKeyList[k] = true
    end

    -- if self.attr then
    --     self:BrocastData("attr")
    -- end

    -- if self.buffs then
    --     self:BrocastData("buffs")
    -- end

    if changlevelEventFlag then
        GlobalEvent:Brocast(EventName.ChangeLevel,message.level,is_first)
    end

    self:BrocastAll()

    if self.gender then
        self.body_res_id = self.gender == 1 and 11002 or 12002
    end
end

function MainRoleData:ClearData()
    if not self.clearKeyList then
        return
    end
    for k,v in pairs(self.clearKeyList) do
        self[k] = nil
    end
    for i, v in pairs(Constant.GoldType) do
        if self[v] then
            self[v] = nil
        end

    end

    self.last_level = -1
    self.level = 0
    self.body_res_id = 11001
end

function MainRoleData:ChangeMessageByScene(message)
    local event_list = {}
    local function recursion(value1,value2,parent_name)
        for k,v in pairs(value2) do
            local key = k
            if tonumber(k) or tonumber(parent_name) then
                key = nil
            elseif parent_name then
                key = parent_name .. "." .. k
            end
            if k == "level" then
                if value1[k] < v then
                    value1[k] = v
                    if key then
                        event_list[key] = v
                    end
                end
            elseif type(v) == "table" then
                value1[k] = value1[k] or {}
                recursion(value1[k],v,key)
                if key then
                    event_list[key] = v
                end
            else
                if value1[k] ~= v then
                    value1[k] = v
                    if key then
                        event_list[key] = v
                    end
                end
            end
        end
    end
    recursion(self,message,nil)

    for event_id,value in pairs(event_list) do
        
    end
end

function MainRoleData:AddEvent()
    MainRoleData.super.AddEvent(self)
    --属性变化要触发部分属性变化事件
    local function func()
        self:SetHp(self.attr.hp)
        self:SetMaxHp(self.attr.hpmax)
        self:SetSpeed(self.attr.speed)
    end
    -- self:BindData("attr", func)
end

function MainRoleData:SetDefalutValue()
    self:SetHp(self.attr.hp)
    self:SetMaxHp(self.attr.hpmax)
    self:SetSpeed(self.attr.speed)
    local scend_info = SceneManager:GetInstance():GetSceneInfo()
    self.coord = self.coord or { x = 0, y = 0 }
    if scend_info then
        self:SetCoord(scend_info.coord)
    end

    for money_id,money_key in pairs(Constant.GoldIDMap) do
        self[money_key] = 0
    end
end

function MainRoleData:dctor()
end

--父类处理的，这里不需要处理
function MainRoleData:InitMessage()
end

function MainRoleData:GetShowBuffList()
    if not self.buffs then
        return {}
    end
    local list = {}
    local len = #self.buffs
    for i=1,len do
        local p_buff = self.buffs[i]
        local cf = Config.db_buff[p_buff.id]
        if cf and cf.is_show == 1 then
            list[#list+1] = p_buff
        end
    end
    return list
end

function MainRoleData:GetValue(key)
    if not key then
        return nil
    end
    if Constant.GoldIDMap[key] then
        key = Constant.GoldIDMap[key]
    end
    return MainRoleData.super.GetValue(self,key)
end

--[[
    @author LaoY
    @des    根据属性名|序号 获取对应值，详细见：PowerConfig
--]]
function MainRoleData:GetAttr(name)
    if not self.attr then
        return nil
    end
    if tonumber(name) then
        name = IndexToMapKey(name)
    end
    return self.attr[name]
end

function MainRoleData:ChangeBuffTypeList(p_buff)
    if p_buff then
        local old_is_can_move = self:IsCanMoveByBuff()
        MainRoleData.super.ChangeBuffTypeList(self,p_buff)
        -- 中了禁止移动的buff 要停止移动
        if old_is_can_move and not self:IsCanMoveByBuff() then
            OperationManager:GetInstance():StopAStarMove()
            local role = SceneManager:GetInstance():GetObject(self.uid)
            if role and (role:IsRunning() or role:IsCollecting()) then
                -- role:SetMovePosition(nil)
                role:ChangeToMachineDefalutState()
            end
        end
    else
        MainRoleData.super.ChangeBuffTypeList(self,p_buff)
    end
end