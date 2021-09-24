-- 雕像系统
function model_statue(uid,data)
    local self = {
        uid = uid,
        statue = {}, -- 雕像数据 {s1={h1=1,h2=2},s2={将领id=将领品阶}}
        updated_at = 0,
    }

    function self.bind(data)
        if type(data) ~= 'table' then
            return false
        end
        
        for k,v in pairs (self) do
            local vType = type(v)
            if vType~="function" then
                if data[k] == nil then return false end
                if vType == 'number' then
                    self[k] = tonumber(data[k]) or data[k]
                else
                    self[k] = data[k]
                end
            end
        end

        return true
    end

    function self.getSkillAttrs()
        --dmg 伤害,dmg_reduce 免伤,first 先手,add 带兵量,evade 闪避,accuracy 命中,crit 暴击,anticrit 免暴,arp 击破,armor 防护
        --moveSpeed 行军加速,colloctSpeed 采集加速,madeSpeed 生产速度,studySpeed 科研速度,buildSpeed 建筑速度
        -- local data = {skill={add=1,maxhp=1,dmg=1,first=1,dmg_reduce=1,evade=1,accuracy=1,crit=1,anticrit=1,arp=1,armor=1,moveSpeed=1,colloctSpeed=1,madeSpeed=1,studySpeed=1,buildSpeed=1},special={dmg=1,dmg_reduce=1}}
        -- skill 除计算总属性值的skill配置(包括加速类技能), special 计算总属性值
        local data = {}
        if switchIsEnabled('statue') then
            data = {skill={},special={}}
            local statueCfg = getConfig("statueCfg")
            for sid,htb in pairs(self.statue) do
                local level
                local num=0
                if htb and next(htb) then
                    for hid,p in pairs(htb) do
                        if statueCfg.arr1[sid] and statueCfg.arr1[sid][hid] and statueCfg.arr1[sid][hid][p] then
                            data.skill['dmg'] = (data.skill['dmg'] or 0) + statueCfg.arr1[sid][hid][p][1]
                            data.skill['maxhp'] = (data.skill['maxhp'] or 0) + statueCfg.arr1[sid][hid][p][2]
                        end

                        num = num + 1
                        if not level then
                            level = p
                        elseif level and level > p then
                            level = p
                        end
                    end
                end

                if level and level > 0 then
                    if statueCfg.skill[sid] and #statueCfg.skill[sid]==num and statueCfg.skill[sid][level] then
                        for sk,sv in pairs(statueCfg.skill[sid][level]) do
                            if sk == "dmg_reduce" or sk == "dmg" then
                                data.special[sk] = (data.special[sk] or 0) + sv
                            else
                                data.skill[sk] = (data.skill[sk] or 0) + sv
                            end
                        end
                    end
                end

            end
        end

        return data
    end

    -- skilltype 技能类型(带兵量和加速类buff)
    -- 'add'：带兵量，'moveSpeed'：行军加速，'colloctSpeed'：采集加速，'madeSpeed'：资源生产加速，'studySpeed'：科研加速，'buildSpeed'：建筑加速
    function self.getSkillValue(skilltype)
        if switchIsEnabled('statue') then
            local data = self.getSkillAttrs() or {}
            if data and data.skill then
                return data.skill[skilltype] or 0
            end
        end
        return 0
    end


    function self.toArray(format)
        local data = {}
        for k,v in pairs (self) do
            if type(v)~="function" and k~= 'uid' and k~= 'updated_at' and k ~= 'errorCode' then
                if format then
                    -- if type(v) == 'table'  then
                    --     if next(v) then data[k] = v end
                    -- elseif v ~= 0 and v~= '0' and v~='' then
                        data[k] = v
                    -- end
                else
                    data[k] = v
                end
            end
        end
        return data
    end

    return self
end


