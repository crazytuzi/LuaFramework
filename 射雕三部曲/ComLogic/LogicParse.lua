local LogicParse = class("LogicParse" , function(params)
    return {data = params}
end)

--返回对应的值
function LogicParse:convertValue(n_string)
    --判断是否是数字
    local number = tonumber(n_string)
    if number then
        return number
    end
    --T.buff = 10000,100,100
    local oList = ld.split(n_string , ",")
    if #oList > 1 then
        for i , v in ipairs(oList) do
            oList[i] = self:parseCalcValue(v)
        end
        return oList
    end
    --T.HP
    local tmpList = ld.split(n_string , ".")
    if #tmpList == 2 then
        local target = self:getTarget(tmpList[1])
        if target then
            if tmpList[2] == "BanAct" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eBanAct})
            elseif tmpList[2] == "Freeze" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eFreeze})
            elseif tmpList[2] == "BanRA" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eBanRA})
            elseif tmpList[2] == "BanNA" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eBanNA})
            elseif tmpList[2] == "BanRP" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eBanRP})
            elseif tmpList[2] == "BanHP" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eBanHP})
            elseif tmpList[2] == "Shield" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eShield})
            elseif tmpList[2] == "HPDOT" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eHPDOT})
            elseif tmpList[2] == "HPHOT" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eHPHOT})
            elseif tmpList[2] == "Dead" then
                return not target:checkAlive()
            elseif tmpList[2] == "UnThorn" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eUnThorn})
            elseif tmpList[2] == "UnCUTRP" then
                return self.data.data:checkState({posId = target.idx , state = ld.BuffState.eUnCUTRP})
            elseif tmpList[2] == "aliveEnemy" then
                local count = 0
                for i , v in ld.pairsByKeys(self.data.data:getHeroList()) do
                    if (v:getType() ~= target:getType()) and v:checkAlive() then
                        count = count + 1
                    end
                end
                return count
            elseif tmpList[2] == "aliveSelf" then
                local count = 0
                for i , v in ld.pairsByKeys(self.data.data:getHeroList()) do
                    if (v:getType() == target:getType()) and v:checkAlive() then
                        count = count + 1
                    end
                end
                return count
            else
                return target[tmpList[2]]
            end
        end
    end
    --几个特殊的值
    if n_string == "rand" then
        return self.data.data.rand:random(1,100)
    elseif n_string == "damage" then
        return math.abs(self.data.damage)
    elseif n_string == "true" then
        return true
    elseif n_string == "false" then
        return false
    else
        error(string.format("nof found value: %s buff:%s" , n_string , self.data.buff.ID))
    end
end

--赋值
--T.buff
function LogicParse:fixValue(otype , n_string , value)
    local tmpList = ld.split(n_string , ".")
    if #tmpList == 2 then
        local target = self:getTarget(tmpList[1])
        if target then
            if target.isHero and target.isPet then
                --宠物数据不能变更
                return
            end
            target.newCalcDamage = nil
            if tmpList[2] == "buff" then
                --免疫控制buff
                local ucState = self.data.data:checkState({posId = target.idx , state = ld.BuffState.eUnControl})
                local function checkControlState(tmpBuff)
                    if tmpBuff then
                        --沉默、眩晕、麻痹
                        if tmpBuff.stateEnum == ld.BuffState.eBanRA or
                            tmpBuff.stateEnum == ld.BuffState.eBanAct or
                            tmpBuff.stateEnum == ld.BuffState.eBanNA or
                            tmpBuff.stateEnum == ld.BuffState.eFreeze then
                            return true
                        end
                    end
                    return false
                end
                --免疫负面buff
                local state = self.data.data:checkState({posId = target.idx , state = ld.BuffState.eUnDebuff})
                if type(value) == "table" then
                    local tmpBuff = ld.getBuff(value[1])
                    if (state and tmpBuff and tmpBuff.isDebuff) or (ucState and checkControlState(tmpBuff)) then
                        --不附加
                        if (ucState and checkControlState(tmpBuff)) then
                            local tmp = clone(self.data.data.BuffState[target.idx][ld.BuffState.eUnControl])
                            for i , v in ipairs(tmp) do
                                local ucbuff = self.data.data:getBuff({
                                    point = v.point,
                                    posId = target.idx,
                                    buffId = v.buffId,
                                    uniqueId = v.uniqueId,
                                })
                                if self.data.data.buffTarget:calcLifeTime(ucbuff) then
                                    self.data.data:deleteBuff({
                                        point = v.point,
                                        posId = target.idx,
                                        buffId = v.buffId,
                                        uniqueId = v.uniqueId,
                                    })
                                end
                            end
                        end
                    else
                        self.data.data:addBuff({
                            posId = target.idx ,
                            buffId = value[1],
                            fromPos = self.data.owner,
                            addition = value,
                            extend = {
                                lifeRound = self.data.buff.calcPoint == ld.BuffCalcPoint.eBattleStart,
                                lifeRound_pet = self.data.buff.extend.isPet
                            }
                        })
                        -- 统计承受的buff
                        require("ComLogic.StatisticsManager")
                        StatisticsManager.buffStatistics(target, value[1])
                    end
                else
                    local tmpBuff = ld.getBuff(value)
                    if (state and tmpBuff and tmpBuff.isDebuff) or (ucState and checkControlState(tmpBuff)) then
                        --不附加
                        if (ucState and checkControlState(tmpBuff)) then
                            local tmp = clone(self.data.data.BuffState[target.idx][ld.BuffState.eUnControl])
                            for i , v in ipairs(tmp or {}) do
                                local ucbuff = self.data.data:getBuff({
                                    point = v.point,
                                    posId = target.idx,
                                    buffId = v.buffId,
                                    uniqueId = v.uniqueId,
                                })
                                if self.data.data.buffTarget:calcLifeTime(ucbuff) then
                                    self.data.data:deleteBuff({
                                        point = v.point,
                                        posId = target.idx,
                                        buffId = v.buffId,
                                        uniqueId = v.uniqueId,
                                    })
                                end
                            end
                        end
                    else
                        self.data.data:addBuff({
                            posId = target.idx ,
                            buffId = value,
                            fromPos = self.data.owner,
                            extend = {
                                lifeRound = self.data.buff.calcPoint == ld.BuffCalcPoint.eBattleStart,
                                lifeRound_pet = self.data.buff.extend.isPet
                            }
                        })
                        -- 统计承受的buff
                        require("ComLogic.StatisticsManager")
                        StatisticsManager.buffStatistics(target, value)
                    end
                end
            elseif tmpList[2] == "damage" then
                target.newCalcDamage = value
            else
                if (tmpList[2] == "HP") or (tmpList[2] == "RP") then
                    local atom = self.data.data:getRecord():addAtom()
                    self.data.data:pushRecord(atom)
                    atom:set("toPos" , target.idx)
                    atom:set("atomType" , ld.FightAtomType.eVALUE)
                end
                if otype == "add" then
                    target:addValue({type = tmpList[2] , value = value , fromTarget = self.data.self})
                elseif otype == "set" then
                    target:setValue({type = tmpList[2] , value = value , fromTarget = self.data.self})
                end
                if (tmpList[2] == "HP") or (tmpList[2] == "RP") then
                    self.data.data:popRecord()
                end
                -- 统计buff的伤害，治疗（主要是珍兽，外功的伤害）
                require("ComLogic.StatisticsManager")
                if otype == "add" and tmpList[2] == "HP" then
                    if value > 0 then
                        StatisticsManager.healStatistics(self.data.self, value)
                    else
                        StatisticsManager.behitStatistics(target, math.abs(value))
                        StatisticsManager.damageStatistics(self.data.self, math.abs(value))
                    end
                end
            end
        end
    else
        error(TR("没有明确的目标:")..n_string.."  "..self.data.buff.ID)
    end
end

--获取对象
function LogicParse:getTarget(n_string)
    if n_string == "S" then
        --self,指buff所在对象
        if type(self.data.self) == "number" then
            return self.data.data:getHero(self.data.self)
        else
            return self.data.self
        end
    elseif n_string == "T" then
        --target,指buff目标
        if type(self.data.target) == "number" then
            return self.data.data:getHero(self.data.target)
        else
            return self.data.target
        end
    elseif n_string == "O" then
        --owner,指buff发起者
        if type(self.data.owner) == "number" then
            return self.data.data:getHero(self.data.owner)
        else
            return self.data.owner
        end
    elseif n_string == "A" then
        --attacker,指当前buff触发时的攻击者
        if type(self.data.attacker) == "number" then
            return self.data.data:getHero(self.data.attacker)
        else
            return self.data.attacker
        end
    elseif n_string == "D" then
        --defender,指当前buff触发时的防御者
        if type(self.data.defender) == "number" then
            return self.data.data:getHero(self.data.defender)
        else
            return self.data.defender
        end
    elseif n_string == "B" then
        --buff,指当前buff,主要用于B.addition2
        return self.data.buff
    elseif n_string == "SF" then
        --self-formation,指self对象所在阵容的总属性
        local tmp_self = nil
        if type(self.data.self) == "number" then
            tmp_self = self.data.data:getHero(self.data.self)
        else
            tmp_self = self.data.self
        end
        local standtype = ld.getStandType(tmp_self.idx)
        if standtype == ld.HeroStandType.eEnemy then
            return self.data.data.enemeyAttr
        elseif standtype == ld.HeroStandType.eTeammate then
            return self.data.data.friendAttr
        end
    elseif n_string == "TF" then
        --target-formation,指target对象所在阵容的总属性
        local standtype = ld.getStandType(self.data.target)
        if standtype == ld.HeroStandType.eEnemy then
            return self.data.data.enemeyAttr
        elseif standtype == ld.HeroStandType.eTeammate then
            return self.data.data.friendAttr
        end
    elseif n_string == "OF" then
        --owner-formation,指owner对象所在阵容的总属性
        local standtype = ld.getStandType(self.data.owner)
        if standtype == ld.HeroStandType.eEnemy then
            return self.data.data.enemeyAttr
        elseif standtype == ld.HeroStandType.eTeammate then
            return self.data.data.friendAttr
        end
    elseif n_string == "AF" then
        --attacker-formation,指attacker对象所在阵容的总属性
        local standtype = ld.getStandType(self.data.attacker)
        if standtype == ld.HeroStandType.eEnemy then
            return self.data.data.enemeyAttr
        elseif standtype == ld.HeroStandType.eTeammate then
            return self.data.data.friendAttr
        end
    elseif n_string == "DF" then
        --defender-formation,指defender对象所在阵容的总属性
        local standtype = ld.getStandType(self.data.defender)
        if standtype == ld.HeroStandType.eEnemy then
            return self.data.data.enemeyAttr
        elseif standtype == ld.HeroStandType.eTeammate then
            return self.data.data.friendAttr
        end
    end
end

------------------------------------------------------
local Condition_Operator = {
    '>=',
    '<=',
    '<>',
    '>',
    '<',
    '==',
}

--处理判断指令
local function deal_Cond(oper , v1 , v2)
    if oper == ">=" then
        return v1 >= v2
    elseif oper == "<=" then
        return v1 <= v2
    elseif oper == "<>" then
        return v1 ~= v2
    elseif oper == ">" then
        return v1 > v2
    elseif oper == "<" then
        return v1 < v2
    elseif oper == "==" then
        return v1 == v2
    end
end

--解析判断语句 *******************
function LogicParse:parseCondition(n_string)
    if n_string == "" then
        return true
    end

    local function condition(str)
        for i , v in ipairs(Condition_Operator) do
            local ret = ld.split(str , v)
            if #ret == 2 then
                local v1 = self:parseCalcValue(ret[1])
                local v2 = self:parseCalcValue(ret[2])
                if v1 ~= nil and v2 ~= nil then
                    return deal_Cond(v , v1 , v2)
                else
                    error(str..TR(":获取值错误！")..self.data.buff.ID)
                end
            end
        end
        error(str..TR(":找不到正确的操作符！")..self.data.buff.ID)
    end

    --分句
    local strList = ld.split(n_string , ";")
    for i , v in ipairs(strList) do
        if not condition(v) then
            return false
        end
    end
    return true
end
-------------------------------------------------------------------
--树节点类型
local ParseType = {
    eOper = 1,      --操作符
    eValue = 2,     --值(字符形式)
    eRet = 3,       --值(数值形式)
    eFunc = 4,      --函数式
}

--二元操作符
local Calc_Operator = {
    43,     --"+",
    45,     --"-",
    42,     --"*",
    47,     --"/",
    37,     --"%"
}

--二元操作符优先级
local priority = {
    ["+"] = 1,
    ["-"] = 1,
    ["*"] = 2,
    ["/"] = 2,
    ["%"] = 2,
}

--处理计算指令
local function deal_Calc(oper , v1 , v2)
    if oper == "*" then
        return v1 * v2
    elseif oper == "/" then
        return v1 / v2
    elseif oper == "+" then
        return v1 + v2
    elseif oper == "-" then
        return v1 - v2
    elseif oper == "%" then
        return v1 % v2
    end
end

--单参数函数名
local func_keyword = {
    "floor",--向下取整
    "ceil",--向上取整
    "round",--四舍五入
}

--函数计算
local function deal_func(key , value1)
    if func_keyword[key] == "floor" then
        return math.floor(value1)
    elseif func_keyword[key] == "ceil" then
        return math.ceil(value1)
    elseif func_keyword[key] == "round" then
        return (value1 % 1 >= 0.5 and math.ceil(value1)) or math.floor(value1)
    end
end

--检查函数
local function parseFuncKeyword(prev_string)
    for i , v in ipairs(func_keyword) do
        local tmp = string.match(prev_string , v.."%s*")
        if tmp then
            return i , tmp
        end
    end
    return nil
end

--解析计算语句 *******************
function LogicParse:parseCalc(n_string)
    if n_string and n_string ~= "" then
        --分句
        local strList = ld.split(n_string , ";")
        for i , v in ipairs(strList) do
            --条件选择
            if not self:parseSelect(v) then
                local operValue = {
                    "+=",
                    "-=",
                    "=",
                }
                for p , q in ipairs(operValue) do
                    local tmpList = ld.split(v , q)
                    if #tmpList == 2 then
                        if q == "+=" then
                            self:fixValue("add" , tmpList[1] , self:parseCalcValue(tmpList[2]))
                        elseif q == "-=" then
                            self:fixValue("add" , tmpList[1] , -self:parseCalcValue(tmpList[2]))
                        elseif q == "=" then
                            if string.find(tmpList[1] , ".buff") then
                                self:fixValue("set" , tmpList[1] , self:convertValue(tmpList[2]))
                            else
                                self:fixValue("set" , tmpList[1] , self:parseCalcValue(tmpList[2]))
                            end
                        end
                        break
                    end
                end
            end
        end
    end
end

--计算值
function LogicParse:parseCalcValue(n_string)
    local n_table = self:buildTree(n_string)
    local value = self:calcTree(n_table)
    local ret = nil
    if value.t == ParseType.eValue then
        ret = self:convertValue(value.v)
    elseif value.t == ParseType.eRet then
        ret = value.v
    end

    if ret == nil then
        error(TR("配置错误：%s %d" , n_string , self.data.buff.ID))
    end
    return ret
end

--解析条件语句
function LogicParse:parseSelect(n_string)
    local tmpList = ld.split(n_string , "?")
    if #tmpList == 2 then
        local sel = ld.split(tmpList[2] , ":")
        if #sel == 2 then
            if self:parseCondition(tmpList[1]) then
                self:parseCalc(sel[1])
            else
                self:parseCalc(sel[2])
            end
            return true
        elseif #sel == 1 then
            if self:parseCondition(tmpList[1]) then
                self:parseCalc(sel[1])
            end
            return true
        else
            error(TR("不合规范的条件选择语句：")..n_string)
        end
    end
    return false
end

--按照符号优先级，构造树
function LogicParse:buildTree(n_string)
    local function parseExp(n_string)
        local ret = {}
        local s_start = 1
        local exp = 1
        while(s_start <= #n_string) do
            local char = string.byte(n_string , s_start)
            for i , v in ipairs(Calc_Operator) do
                if char == v then
                    if exp ~= s_start then
                        local str = ld.trim(string.sub(n_string , exp  , s_start - 1))
                        if str ~= "" then
                            table.insert(ret , {v = str , t = ParseType.eValue})
                        end
                    end
                    table.insert(ret , {v = string.char(v) , t = ParseType.eOper})
                    exp = s_start + 1
                    break
                end
            end
            s_start = s_start + 1
        end
        if exp ~= s_start then
            local str = ld.trim(string.sub(n_string , exp  , s_start))
            if str ~= "" then
                table.insert(ret , {v = str , t = ParseType.eValue})
            end
        end
        return ret
    end

    local function split_round_brackets(n_string)
        --分割()
        local ret = {}
        local current = 1
        local count = 0
        local last_pos = 1
        local c_function = nil
        while(current <= #n_string) do
            local char = string.byte(n_string , current)
            if char == 40 then --"("
                count = count + 1
                if count == 1 then
                    if current ~= last_pos then
                        local prev = string.sub(n_string , last_pos , current - 1)
                        local idx , keyword = parseFuncKeyword(prev)
                        if idx then
                            c_function = idx
                            --作函数处理
                            local tmp = parseExp(string.gsub(prev , keyword , ""))
                            for i , v in ipairs(tmp) do
                                table.insert(ret , v)
                            end
                        else
                            c_function = nil
                            --作优先级调整处理
                            local tmp = parseExp(prev)
                            for i , v in ipairs(tmp) do
                                table.insert(ret , v)
                            end
                        end
                    end
                    last_pos = current + 1
                end
            elseif char == 41 then --")"
                count = count - 1
                if count == 0 then
                    if current ~= last_pos then
                        local str = string.sub(n_string , last_pos  , current - 1)
                        local n_out = self:buildTree(str)
                        if c_function then
                            table.insert(ret , {v = n_out , t = ParseType.eFunc , f = c_function})
                        else
                            table.insert(ret , n_out)
                        end
                    end
                    last_pos = current + 1
                end
            end
            current = current + 1
        end
        if current ~= last_pos then
            local tmp = parseExp(string.sub(n_string , last_pos  , current))
            for i , v in ipairs(tmp) do
                table.insert(ret , v)
            end
        end

        if count ~= 0 then
            error(n_string..TR(":括号数量不匹配!"))
        end
        return ret
    end
    return split_round_brackets(n_string)
end

--计算树的最终值
function LogicParse:calcTree(n_table)
    while(true) do
        --判断是否仅为值
        if (#n_table == 1) and ((n_table[1].t == ParseType.eValue) or (n_table[1].t == ParseType.eRet)) then
            return n_table[1]
        else
            --寻找最高优先级
            local max = nil
            for i , v in ipairs(n_table) do
                if v.t == ParseType.eOper then
                    if max == nil then
                        max = i
                    else
                        if priority[v.v] > priority[n_table[max].v] then
                            max = i
                        end
                    end
                end
            end
            if not max then
                error(TR("表达式错误！"))
            end
            --因为只有二元操作符
            local v_left = nil
            local left = n_table[max - 1]
            if left.t == ParseType.eValue then
                v_left = self:convertValue(left.v)
            elseif left.t == ParseType.eRet then
                v_left = left.v
            elseif left.t == ParseType.eFunc then
                local tmp = self:calcTree(left.v)
                v_left = deal_func(left.f , (tmp.t == ParseType.eValue) and self:convertValue(tmp.v) or tmp.v)
            else
                local tmp = self:calcTree(left)
                v_left = (tmp.t == ParseType.eValue) and self:convertValue(tmp.v) or tmp.v
            end
            local v_right = nil
            local right = n_table[max + 1]
            if right.t == ParseType.eValue then
                v_right = self:convertValue(right.v)
            elseif right.t == ParseType.eRet then
                v_right = right.v
            elseif right.t == ParseType.eFunc then
                local tmp = self:calcTree(right.v)
                v_right = deal_func(right.f , (tmp.t == ParseType.eValue) and self:convertValue(tmp.v) or tmp.v)
            else
                local tmp = self:calcTree(right)
                v_right = (tmp.t == ParseType.eValue) and self:convertValue(tmp.v) or tmp.v
            end

            local ret = {v = deal_Calc(n_table[max].v , v_left , v_right) , t = ParseType.eRet}
            table.remove(n_table , max - 1)
            table.remove(n_table , max - 1)
            table.remove(n_table , max - 1)
            table.insert(n_table , max - 1 , ret)
        end
    end
end

return LogicParse