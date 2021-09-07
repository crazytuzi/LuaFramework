BaseUtils = BaseUtils or {}

BaseUtils.BASE_TIME = os.time()
BaseUtils.Last_Tick_Time = BaseUtils.BASE_TIME

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2
local GreyMat = nil

-- 删除掉的时装列表
BaseUtils.invalid_dress_ids = {51023, 51024, 51025, 51026, 51027, 51028, 51029, 51030, 51031, 51032, 51033, 51034}
BaseUtils.invalid_head_ids = {50023, 50024, 50025, 50026, 50027, 50028, 50029, 50030, 50031, 50032, 50033, 50034}
BaseUtils.platform = nil

-- 复制table
function BaseUtils.copytab(st)
    if st == nil then return nil end
    if type(st) ~= "table" then
        return st
    end
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = BaseUtils.copytab(v)
        end
    end
    return tab
end

-- 覆盖table属性 把tab2的所有内容赋值给tab1
function BaseUtils.covertab(tab1, tab2)
    for k, v in pairs(tab2) do
        tab1[k] = v
    end
    return tab1
end

-- 检查table内容是否相同(正反调用两次，确保两个table相同)
function BaseUtils.sametab(tab1, tab2)
    if BaseUtils.checktab(tab1, tab2) and BaseUtils.checktab(tab2, tab1) then
        return true
    end
    return false
end

-- 检查table内容是否相同(如果tab2比tab1大则检查不出来)
function BaseUtils.checktab(tab1, tab2)
    if tab1 ~= nil and tab2 == nil then return false end

    for k, v in pairs(tab1 or {}) do
        if type(v) ~= "table" then
            if tab2[k] ~= v then return false end
        elseif tab2[k] ~= nil then
            if not BaseUtils.sametab(v, tab2[k]) then return false end
        else
            return false
        end
    end
    return true
end

-- 返回两个tableb内容不同的项，result 传入{}
function BaseUtils.quickspot(tab1, tab2, result)
    for k, v in pairs(tab1 or {}) do
        if type(v) ~= "table" then
            if tab2[k] ~= v then table.insert(result, k)  end
        elseif tab2 ~= nil then
            BaseUtils.quickspot(v, tab2[k], result)
        end
    end
    return result
end

--返回utf8字符串长度
function string.utf8len(str)
    local len = #str;
    local left = len;
    local cnt = 0;
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc};
    while left ~= 0 do
        local tmp=string.byte(str,-left);
        local i=#arr;
        while arr[i] do
            if tmp>=arr[i] then left=left-i;break;end
            i=i-1;
        end
        cnt=cnt+1;
    end
    return cnt;
end

function BaseUtils.get_self_id()
    local role = RoleManager.Instance.RoleData
    return BaseUtils.get_unique_roleid(role.id, role.zone_id, role.platform)
end

-- 获取role标识
function BaseUtils.get_unique_roleid(roleid, zoneid, platform)
    return string.format("%s_%s_%s", tostring(platform), tostring(zoneid), tostring(roleid))
end

-- 获取unit标识
function BaseUtils.get_unique_npcid(id, battleid)
    return string.format("%s_%s", tostring(id), tostring(battleid))
end


-- 序列化
-- 序列化时只需传入obj的值，其它保持nil
function BaseUtils.serialize(obj, name, newline, depth)
    local space = newline and "    " or ""
    newline = newline and true
    depth = depth or 0
    if depth > 10 then
        return "..."
    end
    local tmp = string.rep(space, depth)

    if name then
        if type(name) == "number" then
            tmp = tmp .. "[" .. name .. "] = "
        else
            tmp = tmp .. tostring(name) .. " = "
        end
    end

    if type(obj) == "table" then
        tmp = tmp .. "{" .. (newline and "\n" or "")

        for k, v in pairs(obj) do
            tmp =  tmp .. BaseUtils.serialize(v, k, newline, depth + 1) .. "," .. (newline and "\n" or "")
        end

        tmp = tmp .. string.rep(space, depth) .. "}"
    elseif type(obj) == "number" then
        tmp = tmp .. tostring(obj)
    elseif type(obj) == "string" then
        tmp = tmp .. string.format("%q", obj)
    elseif type(obj) == "boolean" then
        tmp = tmp .. (obj and "true" or "false")
    elseif type(obj) == "function" then
        -- tmp = tmp .. tostring(obj)
        tmp = tmp .. "\"【function】\""
    elseif type(obj) == "userdata" then
        tmp = tmp .. "\"【userdata】\""
    else
        tmp = tmp .. "\"[" .. string.format("%s", tostring(obj)) .. "]\""
    end

    return tmp
end

-- 反序列化
function BaseUtils.unserialize(str)
    return assert(loadstring("local tmp = " .. str .. " return tmp"))()
end

-- 显示指定对象的结构
function BaseUtils.dump(obj, name)
    if IS_DEBUG then
        print(BaseUtils.serialize(obj, name, true, 0))
    end
end

-- 显示指定对象的matetable结构
function BaseUtils.dump_mt(obj, name)
    if IS_DEBUG then
        BaseUtils.dump(getmetatable(obj), name)
    end
end

-- Init
function BaseUtils.InitTable(tab)
    local length = 0
    for k,v in pairs(tab) do
        length = length + 1
    end
    tab["length"] = length
end

-- Clean
function BaseUtils.CleanTable(tab)
    tab = {}
    tab["length"] = 0
end

-- Add
function BaseUtils.AddTable(tab, key, value)
    local length = tab["length"]
    if tab[key] == nil then
        tab["length"] = length + 1
    end
    tab[key] = value
end

-- Get
function BaseUtils.GetTable(tab, key, value)
    if key ~= nil then
        return tab[key]
    elseif value ~= nil then
        for k,v in pairs(tab) do
            if value == v then
                return v
            end
        end
    end
end

-- Del
function BaseUtils.DelTable(tab, key, value)
    local length = tab["length"]
    if key ~= nil then
        local value = tab[key]
        if value ~= nil then tab["length"] = length - 1 end
        return value
    elseif value ~= nil then
        for k,v in pairs(tab) do
            if value == v then
                tab["length"] = length - 1
                return v
            end
        end
    end
end

-- ContainValue
function BaseUtils.ContainValueTable(tab, value)
    for k,v in pairs(tab) do
        if value == v then
            return true
        end
    end
    return false
end

-- ContainKey
function BaseUtils.ContainKeyTable(tab, key)
    if tab[key] == nil then
        return false
    else
        return true
    end
end

--创建一个队列
function BaseUtils.create_queue()
    return { first = 0, last = -1,len = 0 }
end

--入队
function BaseUtils.enqueue(queue, value)
    local last = queue.last + 1
    local len = queue.len + 1
    queue.len = len
    queue.last = last
    queue[last] = value
end

--队头出队
function BaseUtils.dequeue(queue)
    local first = queue.first
    if first > queue.last then
        return nil --队列已空
    end
    local len = queue.len - 1
    queue.len = len
    local value = queue[first]
    queue[first] = nil
    queue.first = queue.first + 1
    return value
end

--清空队列
function BaseUtils.clearqueue(queue)
    queue.first = 0
    queue.last = -1
    queue.len = 0
end

-- 判断值是否为null、nil
function BaseUtils.is_null(value)
    return (value == nil or (type(value) == "userdata" and value:Equals(Null)))
end

function BaseUtils.isnull(obj)
    -- if obj == nil then
    --     return true
    -- end
    -- if string.match(tostring(obj), "null") ~= nil then
    --     return true
    -- end
    return BaseUtils.is_null(obj)
end

function BaseUtils.distance_bypoint(v1, v2)
    return BaseUtils.distance_byxy(v1.x, v1.y, v2.x, v2.y)
end

function BaseUtils.distance_byxy(rx, ry, tx, ty)
    local rvl = math.pow (rx - tx, 2) + math.pow (ry - ty, 2)
    rvl = math.sqrt (rvl)
    return rvl
end

function BaseUtils.get_angle_bypoint(v1, v2)
    return BaseUtils.get_angle_byxy(v1.x, v1.y, v2.x, v2.y)
end

function BaseUtils.get_angle_byxy(rx, ry, tx, ty)
    local dx = rx - tx
    local dy = ry - ty
    local angle = math.atan2(dx, dy) * 180 / math.pi
    return angle
end

function BaseUtils.distanceto_bypoint(v1, v2, d)
    return BaseUtils.distanceto_byxy(v1.x, v1.y, v2.x, v2.y, d)
end

function BaseUtils.distanceto_byxy(rx, ry, tx, ty, d)
    local dx = rx - tx;
    local dy = ry - ty;
    local dis = BaseUtils.distance_byxy(rx, ry, tx, ty)

    local x = tx + (d / dis) * dx
    local y = ty + (d / dis) * dy
    return Vector2(x, y)
end

-- 获取模型tpose的最大高度
function BaseUtils.get_tpose_height(tpose)
    local height = 0
    local tcc = tpose.childCount - 1
    for i = 0, tcc do
        local child = tpose:GetChild(i)
        if string.match(child.name, "Mesh_") ~= nil then
            local boundsy = child.renderer.bounds.size.y
            if height < boundsy then
                height = boundsy
            end
        end
    end
    return height
end
function BaseUtils.Key(...)
    if IS_DEBUG then
        return table.concat({...}, "_")
    else
        local params = {...}
        local retval = nil
        for _, v in ipairs(params) do
            if (retval == nil) then
                retval = "" .. tostring(v)
            else
                retval = retval .. "_" .. tostring(v)
            end
        end
        return retval
    end
end

-- 获取默认头饰模型
function BaseUtils.default_head(classes, sex)
    if sex == 0 then
        if classes == 1 then
            return 50002
        elseif classes == 2 then
            return 50004
        elseif classes == 3 then
            return 50006
        elseif classes == 4 then
            return 50008
        elseif classes == 5 then
            return 50010
        elseif classes == 6 then
            return 50070
        elseif classes == 7 then
            return 50012
        end
    else
        if classes == 1 then
            return 50001
        elseif classes == 2 then
            return 50003
        elseif classes == 3 then
            return 50005
        elseif classes == 4 then
            return 50007
        elseif classes == 5 then
            return 50009
        elseif classes == 6 then
            return 50071
        elseif classes == 7 then
            return 50013
        end
    end
    return 50002
end

-- 获取默认时装模型
function BaseUtils.default_dress(classes, sex)
    if sex == 0 then
        if classes == 1 then
            return 51002
        elseif classes == 2 then
            return 51004
        elseif classes == 3 then
            return 51006
        elseif classes == 4 then
            return 51008
        elseif classes == 5 then
            return 51010
        elseif classes == 6 then
            return 51070
        elseif classes == 7 then
            return 51012
        end
    else
        if classes == 1 then
            return 51001
        elseif classes == 2 then
            return 51003
        elseif classes == 3 then
            return 51005
        elseif classes == 4 then
            return 51007
        elseif classes == 5 then
            return 51009
        elseif classes == 6 then
            return 51071
        elseif classes == 7 then
            return 51013
        end
    end
    return 51002
end

function BaseUtils.isInvalidDress(dressId)
    for _, drId in ipairs(BaseUtils.invalid_dress_ids) do
        if drId == dressId then
            return true
        end
    end
    return false
end

function BaseUtils.isInvalidHead(headId)
    for _, drId in ipairs(BaseUtils.invalid_head_ids) do
        if drId == headId then
            return true
        end
    end
    return false
end

function BaseUtils.ConvertInvalidDressModel(classes, sex, modelId)
    local isInvalid = BaseUtils.isInvalidDress(modelId)
    if isInvalid then
        return BaseUtils.default_dress(classes, sex)
    else
        return modelId
    end
end

function BaseUtils.ConvertInvalidDressSkin(classes, sex, dressId)
    local isInvalid = BaseUtils.isInvalidDress(dressId)
    if isInvalid then
        return BaseUtils.default_dress_skin(classes, sex)
    else
        return dressId
    end
end

function BaseUtils.ConvertInvalidHeadModel(classes, sex, modelId)
    local isInvalid = BaseUtils.isInvalidHead(modelId)
    if isInvalid then
        return BaseUtils.default_head(classes, sex)
    else
        return modelId
    end
end

function BaseUtils.ConvertInvalidHeadSkin(classes, sex, skinId)
    local isInvalid = BaseUtils.isInvalidHead(skinId)
    if isInvalid then
        return BaseUtils.default_head_skin(classes, sex)
    else
        return skinId
    end
end

-- 获取默认头饰模型
function BaseUtils.default_head_skin(classes, sex)
    if sex == 0 then
        if classes == 1 then
            return 5000201
        elseif classes == 2 then
            return 5000401
        elseif classes == 3 then
            return 5000601
        elseif classes == 4 then
            return 5000801
        elseif classes == 5 then
            return 5001001
        elseif classes == 6 then
            return 5007001
        elseif classes == 7 then
            return 5001201
        end
    else
        if classes == 1 then
            return 5000101
        elseif classes == 2 then
            return 5000301
        elseif classes == 3 then
            return 5000501
        elseif classes == 4 then
            return 5000701
        elseif classes == 5 then
            return 5000901
        elseif classes == 6 then
            return 5007101
        elseif classes == 7 then
            return 5001301
        end
    end
    return 5000201
end

-- 获取默认时装模型
function BaseUtils.default_dress_skin(classes, sex)
    if sex == 0 then
        if classes == 1 then
            return 5100201
        elseif classes == 2 then
            return 5100401
        elseif classes == 3 then
            return 5100601
        elseif classes == 4 then
            return 5100801
        elseif classes == 5 then
            return 5101001
        elseif classes == 6 then
            return 5107001
        elseif classes == 7 then
            return 5101201
        end
    else
        if classes == 1 then
            return 5100101
        elseif classes == 2 then
            return 5100301
        elseif classes == 3 then
            return 5100501
        elseif classes == 4 then
            return 5100701
        elseif classes == 5 then
            return 5100901
        elseif classes == 6 then
            return 5107101
        elseif classes == 7 then
            return 5101301
        end
    end
    return 5100201
end

-- 获取默认武器模型
function BaseUtils.default_weapon(classes, sex)
    if sex == 0 then
        if classes == 1 then
            return 10001
        elseif classes == 2 then
            return 10101
        elseif classes == 3 then
            return 10201
        elseif classes == 4 then
            return 10301
        elseif classes == 5 then
            return 10401
        elseif classes == 6 then
            return 10501
        elseif classes == 7 then
            return 10701
        end
    else
        if classes == 1 then
            return 10001
        elseif classes == 2 then
            return 10101
        elseif classes == 3 then
            return 10201
        elseif classes == 4 then
            return 10301
        elseif classes == 5 then
            return 10401
        elseif classes == 6 then
            return 10501
        elseif classes == 7 then
            return 10701
        end
    end
    return 10001
end

--传入show_id获取对应
function BaseUtils.GetShowActionId(classes, sex)
    if sex == 1 then
        --男
        if classes == 1 then --狂剑
            return 10090
        elseif classes == 2 then --魔导
            return 20090
        elseif classes == 3 then --战弓
            return 30090
        elseif classes == 4 then --兽灵
            return 40090
        elseif classes == 5 then --密言
            return 50090
        elseif classes == 6 then --月魂
            return 60090
        elseif classes == 7 then -- 圣骑
            return 70090
        end
    else
        --女
        if classes == 1 then --狂剑
            return 10100
        elseif classes == 2 then --魔导
            return 20100
        elseif classes == 3 then --战弓
            return 30090
        elseif classes == 4 then --兽灵
            return 40090
        elseif classes == 5 then --密言
            return 50090
        elseif classes == 6 then --月魂
            return 60090
        elseif classes == 7 then --圣骑
            return 70080
        end
    end
end

-- 获取子节点路径
function BaseUtils.GetChildPath(transform, nodeName)
    local tcc = transform.childCount - 1
    local rvl
    for i = 0, tcc do
        local it = transform.transform:GetChild(i)
        if it.childCount > 0 then
            if it.name == nodeName then
                return it.name
            end
            rvl = BaseUtils.GetChildPath(it, nodeName)
            if rvl ~= "" then
                return it.name.."/"..rvl
            end
        elseif it.name == nodeName then
                return it.name
        end
    end
    return ""
end


--------------------------------
--传人属性列表，计算装备评分
--------------------------------
function BaseUtils.EquipPoint(attrs)
    if attrs == nil then
        return 0
    end
    local point = 0
    for i,v in ipairs(attrs) do
        if v.type ~= GlobalEumn.ItemAttrType.shenqiCache then
            local score = DataAttr.data_score[v.name]
            if score ~= nil then
                point = point + v.val * score.score
            end
            if v.name == 100 then
                 local tmp = nil;
                 if v.type == 4 then
                   tmp = DataSkill.data_skill_effect[v.val];
                   if tmp == nil then
                       tmp = DataSkillTalent.data_skill_talent[v.val];
                   end
                elseif v.type == 10 then
                    tmp = DataSkill.data_wing_skill[v.val.."_1"];
                end
                if tmp ~= nil then
                    point = point + tmp.score;
                end
            elseif v.name == 150 then
                  point = point + 10000
            elseif v.name == 151 then
                  point = point + 10000
            end
        end
    end
    return math.ceil(point / 500)
end

-- function BaseUtils.SkillIconPath()
--     if RoleManager.Instance.RoleData.classes == 0 then
--         Log.Error("角色信息异常，角色职业为0")
--         RoleManager.Instance:Logined()
--     end
--     local path = string.format("textures/skilliconbig/roleskill/%s.unity3d", tostring(RoleManager.Instance.RoleData.classes))
--     return path
-- end

function BaseUtils.PetHeadPath(headid)
    if tonumber(headid) == 10099 then
        return AssetConfig.headother_textures
    elseif tonumber(headid) > 10025 then
        return AssetConfig.headother_textures2
    end
    return AssetConfig.headother_textures
end

function BaseUtils.string_cut(str, len, len2)
    local result = str
    if string.len(result) > len then result = string.format("%s..", string.sub(result, 1, len2)) end
    return result
end

--返回字符串内容中，符合 两个符号中间有内容的格式的列表
function BaseUtils.match_between_symbols(str, s1, s2)
    local m = {}
    local parten = string.format("%s(.-)%s", s1, s2)
    for a in string.gmatch(str, parten) do
        table.insert(m, a)
    end
    return m
end

--传入字符串和分割符，切割成table
function BaseUtils.split(str, bracket)
    if str==nil or str=='' or bracket==nil then
        return nil
    end

    local result = {}
    for match in (str..bracket):gmatch("(.-)"..bracket) do
        table.insert(result, match)
    end
    return result
end

function BaseUtils.tweenDoSlider(slider, from, to, time, endfun)
    local fun = function(value) slider.value = value end
    Tween.Instance:ValueChange(from, to, time, endfun, LeanTweenType.linear, fun)
end

--传入一段时间间隔（单位秒），将其按传入的分隔符转换格式，type=0：00-00-00(-为bracket); type = 1: 00天00分00秒
BaseUtils.time_formate = {
    DAY = 1,
    HOUR = 2,
    MIN = 3,
    SEC = 4
}

function BaseUtils.formate_time_gap(timeGap,bracket,type,formatType)
    local result = ""
    local my_date = math.modf(timeGap / 86400)
    local my_hour = math.modf(timeGap % 86400 / 3600)
    local my_minute = math.modf(timeGap % 86400 % 3600 / 60)
    local my_second = math.modf(timeGap % 86400 % 3600 % 60)
    local dayStr = my_date > 9 and my_date or string.format("0%s",my_date)
    local hourStr = my_hour > 9 and my_hour or string.format("0%s",my_hour)
    local minStr = my_minute > 9 and my_minute or string.format("0%s",my_minute)
    local secStr = my_second > 9 and my_second or string.format("0%s",my_second)
    if type==0 then
        if formatType == BaseUtils.time_formate.DAY then
            result = string.format("%s%s%s%s%s%s%s", dayStr, bracket, hourStr, bracket, minStr, bracket, secStr)
        elseif formatType == BaseUtils.time_formate.HOUR then
            result = string.format("%s%s%s%s%s", hourStr, bracket, minStr, bracket, secStr)
        elseif formatType == BaseUtils.time_formate.MIN then
            result = string.format("%s%s%s", minStr, bracket, secStr)
        elseif formatType == BaseUtils.time_formate.SEC then
            result = secStr
        end
    elseif type==1 then
        if formatType == BaseUtils.time_formate.DAY then
            result = string.format("%s%s%s%s", dayStr, TI18N("天"), hourStr, TI18N("时"))
            -- result = string.format("%s%s%s%s%s%s%s%s", dayStr, TI18N("天"), hourStr, TI18N("时"), minStr, TI18N("分"), secStr, TI18N("秒"))
        elseif formatType == BaseUtils.time_formate.HOUR then
            result = string.format("%s%s%s%s", hourStr, TI18N("时"), minStr, TI18N("分"))
            -- result = string.format("%s%s%s%s%s%s", hourStr, TI18N("时"), minStr, TI18N("分"), secStr, TI18N("秒"))
        elseif formatType == BaseUtils.time_formate.MIN then
            result = string.format("%s%s%s%s", minStr, TI18N("分"), secStr, TI18N("秒"))
        elseif formatType == BaseUtils.time_formate.SEC then
            result = string.format("%s%s", secStr ,TI18N("秒"))
        end
    end
    return result
end


--将传入的时间间隔转换为日，时，分，秒
function BaseUtils.time_gap_to_timer(timeGap)
    local result = ""
    local my_date = math.modf(timeGap / 86400)
    local my_hour = math.modf(timeGap % 86400 / 3600)
    local my_minute = math.modf(timeGap % 86400 % 3600 / 60)
    local my_second = math.modf(timeGap % 86400 % 3600 % 60)
    return my_date, my_hour, my_minute, my_second
end

-- 判断是否跨天
function BaseUtils.is_cross_day(timestamp)
    local year = os.date("%Y", timestamp)
    local month = os.date("%m", timestamp)
    local date = os.date("%d", timestamp)

    local nowyear = os.date("%Y", BaseUtils.BASE_TIME)
    local nowmonth = os.date("%m", BaseUtils.BASE_TIME)
    local nowdate = os.date("%d", BaseUtils.BASE_TIME)

    if nowyear > year then
        return true
    elseif nowmonth > month then
        return true
    elseif nowyear == year and nowmonth == month and nowdate > date then
        return true
    end
    return false
end

function BaseUtils.SetGrey(Img, Yes, Changecolor)
    if Yes then
        if GreyMat == nil then
            GreyMat = PreloadManager.Instance:GetMainAsset("textures/materials/grey.unity3d")
            if Img ~= nil then
                if Changecolor then
                    Img.color = Color(0.5, 0.5, 0.5)
                else
                    Img.material = GreyMat
                end
            end
        else
            if Img ~= nil then
                if Changecolor then
                    Img.color = Color(0.5, 0.5, 0.5)
                else
                    Img.material = GreyMat
                end
            end
        end
    elseif Img ~= nil then
        if Changecolor then
            Img.color = Color.white
        else
            Img.material = nil
        end
    end
end

function BaseUtils.NumToChn(num)
    BaseUtils.chnList = BaseUtils.chnList or {TI18N("一"), TI18N("二"), TI18N("三"), TI18N("四"), TI18N("五"), TI18N("六"), TI18N("七"), TI18N("八"), TI18N("九"), TI18N("十")}
    BaseUtils.subNumList = BaseUtils.subNumList or {TI18N("十"), TI18N("百"), TI18N("千"), TI18N("万")}
    local chn = BaseUtils.chnList
    local sub = BaseUtils.subNumList
    if num>10 and num<100000000 then
        local temp = num
        local pow = 0
        local result = ""
        local wmark = false -- 是否有万字的标记
        while (temp>0) do
            local val = temp%10
            temp = math.floor(temp /10)
            local chnString = chn[val]
            local subString = sub[pow]
            if pow == 1 and val == 1 then
                chnString = ""
            end
            if chnString ~= nil then -- 只显示非零的数字
                if pow > 0 and subString == nil then -- 处理超过万的部分
                    subString = sub[pow - #sub]
                    if not wmark then -- 如果没有加入过万字，加一个
                        subString = subString..sub[4]
                        wmark = true
                    end
                end
                if pow >0 then
                    result = chnString..subString..result
                else
                    result = chnString
                end
                if pow == 4 then
                    wmark = true
                end
            end
            pow = pow + 1
        end
        return result
    else
        if num > 0 then
            return chn[num]
        else
            return TI18N("零")
        end
    end
end


function BaseUtils.isTheSameDay(T1, T2)
    return os.date("%d", T1) == os.date("%d", T2)
end

function BaseUtils.SaveLocalFile(fileName, bytes)
    local status, err = xpcall(function() Utils.WriteBytesPath(bytes, fileName) end, function(errinfo)
        Log.Debug("储存本地文件出错了 " .. tostring(errinfo)); Log.Debug(debug.traceback())
    end)
    if not status then
        Log.Debug("储存本地文件出错了 " .. tostring(err))
    end
end

function BaseUtils.LoadLocalFile(fileName)
    local bytes = nil
    local status, err = xpcall(function() bytes = Utils.ReadBytesPath(fileName) end, function(errinfo)
        Log.Debug("读取本地文件出错了 " .. tostring(errinfo)); Log.Debug(debug.traceback())
    end)
    if not status then
        Log.Debug("读取本地文件出错了 " .. tostring(err))
    end

    return bytes
end

function BaseUtils.DelectLocalFile(fileName)
    local call = function()
        if Webcam == nil then
            os.remove(fileName)
        else
            Utils.DeletePath(fileName)
        end
    end
    local status, err = xpcall(call, function(errinfo)
        Log.Debug("删除本地文件出错了 " .. tostring(errinfo)); Log.Debug(debug.traceback())
    end)
    if not status then
        Log.Debug("删除本地文件出错了 " .. tostring(err))
    end
end

function BaseUtils.ClearFloder(path)
    local fileList = Utils.GetFilesRecursive(path)
    for i=0, fileList.Count - 1 do
        Utils.DeletePath(fileList[i])
    end
end

function BaseUtils.GetClientVerion()
    if CSVersion then
        return CSVersion.Version
    else
        return "xcqy 1.0.5"
    end
end

function BaseUtils.GetGameName()
    if CSVersion then
        return CSVersion.GameName
    else
        return "xcqy"
    end
end

function BaseUtils.GetGameNameTxt()
    if CSVersion then
        return CSVersion.GameNameTxt
    else
        return "星辰奇缘"
    end
end

function BaseUtils.GetPlatform()
    if CSVersion then
        return CSVersion.platform
    else
        return "android"
    end
end

-- 获取地区说明
-- cn => 国内
-- sg => 新马
function BaseUtils.GetLocation()
    if CSInfo then
        return CSInfo.Location
    else
        return "cn"
    end
end

function BaseUtils.HSB2RGB(h, s, v)
    assert( h >= 0 and h <= 360)
    assert( s >= 0 and s <= 1)
    assert( v >= 0 and v <= 1)

    local r = 0
    local g = 0
    local b = 0
    local i = math.floor((h / 60) % 6)
    local f = (h / 60) - i;
    local p = v * (1 - s);
    local q = v * (1 - f * s);
    local t = v * (1 - (1 - f) * s);
    if i == 0 then
        r = v;
        g = t;
        b = p;
    elseif i == 1 then
        r = q;
        g = v;
        b = p;
    elseif i == 2 then
        r = p;
        g = v;
        b = t;
    elseif i == 3 then
        r = p;
        g = q;
        b = v;
    elseif i == 4 then
        r = t;
        g = p;
        b = v;
    elseif i == 5 then
        r = v;
        g = p;
        b = q;
    end
    return Color(r ,g ,b)
end

function BaseUtils.ConvertPosition(position)
    local screenPoint = ctx.UICamera.camera:WorldToScreenPoint(position)
    local x = screenPoint.x
    local y = screenPoint.y
    local scaleHeight = ctx.ScreenHeight
    local px = x
    local py = scaleHeight - y + 2.5 * (ctx.ScreenHeight / 540)
    return {px = px, py = py}
end

function BaseUtils.FontSize(size)
    local scaleWidth = ctx.ScreenWidth
    local scaleHeight = ctx.ScreenHeight
    local localRate = scaleWidth / scaleHeight
    local r = 1 + (960 / 540 - localRate) * 1.5
    local fontSize = 12 * r * (size / 18)
    return fontSize
end

----------------------------------横向循环列表，固定宽度
--item类对应要有个update_my_self(data, i)方法用来设置数据
--setting_data = {
--    item_list --放了 item类对象的列表
--    data_list --数据列表
--    data_head_index  --数据头指针
--    data_tail_index  --数据尾指针
--    item_head_index  --item列表头指针
--    item_tail_index  --item列表尾指针
--    item_con  --item列表的父容器
--    single_item_width --一条item的宽度
--    item_con_width --item列表的父容器宽度
--    scroll_change_count --父容器滚动累计改变值
--    item_con_last_x --父容器改变时上一次的y坐标
--    scroll_con_width --显示区域的宽度
-- }
function BaseUtils.refresh_horizontal_circular_list(setting_data)
    if #setting_data.data_list < #setting_data.item_list then
        for i=1,#setting_data.item_list do
            setting_data.item_list[i].gameObject:SetActive(false)
        end
    end

    setting_data.data_head_index = 1
    setting_data.data_tail_index = #setting_data.data_list > #setting_data.item_list and #setting_data.item_list or #setting_data.data_list

    setting_data.item_head_index = 1
    setting_data.item_tail_index = #setting_data.data_list > #setting_data.item_list and #setting_data.item_list or #setting_data.data_list

    if setting_data.data_list == nil then
        setting_data.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, 0)
        return
    end
    if #setting_data.data_list == 0 then
        setting_data.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, 0)
    else
        local newW = #setting_data.data_list*setting_data.single_item_width
        setting_data.item_con_width = newW
        setting_data.item_con:GetComponent(RectTransform).sizeDelta = Vector2(newW, 0)
    end
    setting_data.item_con:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)

    for i=1,#setting_data.item_list do
        local newX = (i-1)*-setting_data.single_item_width
        local _Y = setting_data.item_list[i].gameObject.transform:GetComponent(RectTransform).anchoredPosition.y
        setting_data.item_list[i].transform:GetComponent(RectTransform).anchoredPosition = Vector2(newX, _Y)
    end

    for i=1,#setting_data.data_list do
        if i <= #setting_data.item_list then
            local item = setting_data.item_list[i]
            local data = setting_data.data_list[i]
            item:update_my_self(data, i)
            item.gameObject:SetActive(true)
        else
            break
        end
    end
end

--scroll滚动监听，横向循环列表
function BaseUtils.on_horizontal_value_change(setting_data)
    --核心逻辑
    local cur_x = setting_data.item_con:GetComponent(RectTransform).anchoredPosition.x
    setting_data.scroll_change_count = setting_data.scroll_change_count + math.abs(cur_x - setting_data.item_con_last_x)
    if setting_data.scroll_change_count < setting_data.single_item_width then
        setting_data.item_con_last_x = cur_x
        return
    end

    local cross_step = math.floor(setting_data.scroll_change_count/setting_data.single_item_width)
    for i=1,cross_step do
        if cur_x <= setting_data.item_con_last_x then
            if setting_data.data_head_index ~= 1 and cur_x < (setting_data.item_con_width - setting_data.scroll_con_width) then
                local tail_item = setting_data.item_list[setting_data.item_tail_index]
                local oldX = tail_item.transform:GetComponent(RectTransform).anchoredPosition.x
                if math.abs(oldX) > (math.abs(cur_x)+setting_data.scroll_con_width+2*setting_data.single_item_width) then
                    setting_data.data_head_index = setting_data.data_head_index - 1
                    setting_data.data_tail_index = setting_data.data_tail_index - 1
                    local mem_data = setting_data.data_list[setting_data.data_head_index]
                    tail_item:update_my_self(mem_data, setting_data.data_head_index)
                    local newX = oldX + #setting_data.item_list*setting_data.single_item_width
                    local _Y = tail_item.gameObject.transform:GetComponent(RectTransform).anchoredPosition.y
                    tail_item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(newX, _Y)
                    setting_data.item_head_index = setting_data.item_tail_index
                    setting_data.item_tail_index = setting_data.item_tail_index - 1
                    if setting_data.item_tail_index <= 0 then
                        setting_data.item_tail_index = #setting_data.item_list
                    end
                end
            end
        elseif cur_x > setting_data.item_con_last_x then
            if setting_data.data_tail_index ~= #setting_data.data_list and cur_x >= setting_data.single_item_width then
                local head_item = setting_data.item_list[setting_data.item_head_index]
                local oldX = head_item.transform:GetComponent(RectTransform).anchoredPosition.y
                if math.abs(oldX) < math.abs(cur_x) - 2*setting_data.single_item_width then
                    setting_data.data_tail_index = setting_data.data_tail_index + 1
                    setting_data.data_head_index = setting_data.data_head_index + 1
                    local mem_data = setting_data.data_list[setting_data.data_tail_index]
                    head_item:update_my_self(mem_data, setting_data.data_tail_index)
                    local newX = oldX - #setting_data.item_list*setting_data.single_item_width
                    local _Y = head_item.gameObject.transform:GetComponent(RectTransform).anchoredPosition.y
                    head_item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(newX, _Y)
                    setting_data.item_tail_index = setting_data.item_head_index
                    setting_data.item_head_index = setting_data.item_head_index + 1
                    if setting_data.item_head_index > #setting_data.item_list then
                        setting_data.item_head_index = 1
                    end
                end
            end
        end
        setting_data.scroll_change_count = setting_data.scroll_change_count - setting_data.single_item_width
    end
    setting_data.item_con_last_x = cur_x
end


----------------------------------循环列表公用逻辑
--抽出来做通用逻辑
--item类对应要有个update_my_self(data, i)方法用来设置数据
--setting_data = {
--    item_list --放了 item类对象的列表
--    data_list --数据列表
--    data_head_index  --数据头指针
--    data_tail_index  --数据尾指针
--    item_head_index  --item列表头指针
--    item_tail_index  --item列表尾指针
--    item_con  --item列表的父容器
--    single_item_height --一条item的高度
--    item_con_height --item列表的父容器高度
--    scroll_change_count --父容器滚动累计改变值
--    item_con_last_y --父容器改变时上一次的y坐标
--    scroll_con_height --显示区域的高度
-- }
function BaseUtils.refresh_circular_list(setting_data)
    if #setting_data.data_list < #setting_data.item_list then
        for i=1,#setting_data.item_list do
            setting_data.item_list[i].gameObject:SetActive(false)
        end
    end

    setting_data.data_head_index = 1
    setting_data.data_tail_index = #setting_data.data_list > #setting_data.item_list and #setting_data.item_list or #setting_data.data_list

    setting_data.item_head_index = 1
    setting_data.item_tail_index = #setting_data.data_list > #setting_data.item_list and #setting_data.item_list or #setting_data.data_list

    if setting_data.data_list == nil then
        setting_data.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, 0)
        return
    end
    if #setting_data.data_list == 0 then
        setting_data.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, 0)
    else
        local newH = #setting_data.data_list*setting_data.single_item_height
        setting_data.item_con_height = newH
        setting_data.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, newH)
    end
    setting_data.item_con:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)

    for i=1,#setting_data.item_list do
        local newY = (i-1)*-setting_data.single_item_height
        local _X = setting_data.item_list[i].gameObject.transform:GetComponent(RectTransform).anchoredPosition.x
        setting_data.item_list[i].transform:GetComponent(RectTransform).anchoredPosition = Vector2(_X, newY)
    end

    for i=1,#setting_data.data_list do
        if i <= #setting_data.item_list then
            local item = setting_data.item_list[i]
            local data = setting_data.data_list[i]
            item:update_my_self(data, i)
            item.gameObject:SetActive(true)
        else
            break
        end
    end
end

--(item高度固定)循环列表静态刷新
function BaseUtils.static_refresh_circular_list(setting_data)
    if #setting_data.data_list < #setting_data.item_list then
        BaseUtils.refresh_circular_list(setting_data)
    else
        local offset_index = 0
        if setting_data.data_tail_index > #setting_data.data_list then
            offset_index = setting_data.data_tail_index - #setting_data.data_list
            setting_data.data_head_index = setting_data.data_head_index - offset_index
            setting_data.data_tail_index = setting_data.data_tail_index - offset_index
        end

        local data_index= setting_data.data_head_index
        for i=1,#setting_data.item_list do
            local item = setting_data.item_list[i]
            if data_index <= #setting_data.data_list then
                local data = setting_data.data_list[data_index]
                item:update_my_self(data, data_index)
                data_index = data_index + 1
            end
        end

        if offset_index ~= 0 then
            for i=1,#setting_data.item_list do
                local item = setting_data.item_list[i]
                local oldY = item.transform:GetComponent(RectTransform).anchoredPosition.y
                local offset_y = offset_index*setting_data.single_item_height
                local newY = oldY + offset_y
                local _X = item.gameObject.transform:GetComponent(RectTransform).anchoredPosition.x
                item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(_X, newY)
            end
        end

        local newH = #setting_data.data_list*setting_data.single_item_height
        setting_data.item_con_height = newH
        setting_data.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, newH)
    end
end

--scroll滚动监听
function BaseUtils.on_value_change(setting_data)
    --核心逻辑
    local cur_y = setting_data.item_con:GetComponent(RectTransform).anchoredPosition.y
    setting_data.scroll_change_count = setting_data.scroll_change_count + math.abs(cur_y - setting_data.item_con_last_y)
    if setting_data.scroll_change_count < setting_data.single_item_height then
        setting_data.item_con_last_y = cur_y
        return
    end

    local cross_step = math.floor(setting_data.scroll_change_count/setting_data.single_item_height)
    for i=1,cross_step do
        if cur_y <= setting_data.item_con_last_y then
            if setting_data.data_head_index ~= 1 and cur_y < (setting_data.item_con_height - setting_data.scroll_con_height) then
                local tail_item = setting_data.item_list[setting_data.item_tail_index]
                local oldY = tail_item.transform:GetComponent(RectTransform).anchoredPosition.y
                if math.abs(oldY) > (math.abs(cur_y)+setting_data.scroll_con_height+2*setting_data.single_item_height) then
                    setting_data.data_head_index = setting_data.data_head_index - 1
                    setting_data.data_tail_index = setting_data.data_tail_index - 1
                    local mem_data = setting_data.data_list[setting_data.data_head_index]
                    tail_item:update_my_self(mem_data, setting_data.data_head_index)
                    local newY = oldY + #setting_data.item_list*setting_data.single_item_height
                    local _X = tail_item.gameObject.transform:GetComponent(RectTransform).anchoredPosition.x
                    tail_item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(_X, newY)
                    setting_data.item_head_index = setting_data.item_tail_index
                    setting_data.item_tail_index = setting_data.item_tail_index - 1
                    if setting_data.item_tail_index <= 0 then
                        setting_data.item_tail_index = #setting_data.item_list
                    end
                end
            end
        elseif cur_y > setting_data.item_con_last_y then
            if setting_data.data_tail_index ~= #setting_data.data_list and cur_y >= setting_data.single_item_height then
                local head_item = setting_data.item_list[setting_data.item_head_index]
                local oldY = head_item.transform:GetComponent(RectTransform).anchoredPosition.y
                if math.abs(oldY) < math.abs(cur_y) - 2*setting_data.single_item_height then
                    setting_data.data_tail_index = setting_data.data_tail_index + 1
                    setting_data.data_head_index = setting_data.data_head_index + 1
                    local mem_data = setting_data.data_list[setting_data.data_tail_index]
                    head_item:update_my_self(mem_data, setting_data.data_tail_index)
                    local newY = oldY - #setting_data.item_list*setting_data.single_item_height
                    local _X = head_item.gameObject.transform:GetComponent(RectTransform).anchoredPosition.x
                    head_item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(_X, newY)
                    setting_data.item_tail_index = setting_data.item_head_index
                    setting_data.item_head_index = setting_data.item_head_index + 1
                    if setting_data.item_head_index > #setting_data.item_list then
                        setting_data.item_head_index = 1
                    end
                end
            end
        end
        setting_data.scroll_change_count = setting_data.scroll_change_count - setting_data.single_item_height
    end
    setting_data.item_con_last_y = cur_y
end

------------------------item高度可变循环列表
--item类对应要有个update_my_self(data, i)方法用来设置数据，传入的data要由height字段，同时在update_my_self中执行self.height = data.height
--setting_data = {
--    item_list --放了 item类对象的列表
--    data_list --数据列表
--    data_head_index  --数据头指针
--    data_tail_index  --数据尾指针
--    item_head_index  --item列表头指针
--    item_tail_index  --item列表尾指针
--    item_con  --item列表的父容器
--    single_item_height --一条item的最小高度
--    item_con_height --item列表的父容器高度
--    scroll_change_count --父容器滚动累计改变值
--    item_con_last_y --父容器改变时上一次的y坐标
--    scroll_con_height --显示区域的高度
--    setting_data.top_item_height --用于标记最顶的一条item的高度
--    setting_data.bottom_item_height --用于标记最底部的一条item的高度
-- }
function BaseUtils.refresh_circular_unfixed_list(setting_data)
    for i=1,#setting_data.item_list do
        setting_data.item_list[i].gameObject:SetActive(false)
    end
    setting_data.data_head_index = 1
    setting_data.data_tail_index = #setting_data.data_list > #setting_data.item_list and #setting_data.item_list or #setting_data.data_list
    setting_data.item_head_index = 1
    setting_data.item_tail_index = #setting_data.data_list > #setting_data.item_list and #setting_data.item_list or #setting_data.data_list
    if setting_data.data_list == nil then
        setting_data.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, 0)
        return
    end

    if #setting_data.data_list == 0 then
        setting_data.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, 0)
    else
        local newH = 0
        for k,v in pairs(setting_data.data_list) do
            if v.height ~= nil then
                newH = newH + v.height
            else
                newH = newH + setting_data.single_item_height
            end
        end
        setting_data.item_con_height = newH
        setting_data.item_con:GetComponent(RectTransform).sizeDelta = Vector2(0, newH)
    end
    setting_data.item_con:GetComponent(RectTransform).anchoredPosition = Vector2(0, 0)

    for i=1,#setting_data.item_list do
        local newY = (i-1)*-setting_data.single_item_height
        local _X = setting_data.item_list[i].gameObject.transform:GetComponent(RectTransform).anchoredPosition.x
        setting_data.item_list[i].transform:GetComponent(RectTransform).anchoredPosition = Vector2(_X, newY)
    end
    setting_data.top_item_height = setting_data.single_item_height
    setting_data.bottom_item_height = setting_data.single_item_height
    local next_y = 0
    for i=1,#setting_data.data_list do
        if i <= #setting_data.item_list then
            local item = setting_data.item_list[i]
            local data = setting_data.data_list[i]
            item:update_my_self(data, i)
            item.gameObject:SetActive(true)
            if item.height == nil then
                item.height = setting_data.single_item_height
            end
            local _X = item.gameObject.transform:GetComponent(RectTransform).anchoredPosition.x
            item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(_X, next_y)
            next_y = next_y - item.height

            if i == 1 then
                if item.height ~= nil then
                    setting_data.top_item_height = item.height
                end
            elseif i == #setting_data.item_list or i == #setting_data.data_list then
                if item.height ~= nil then
                    setting_data.bottom_item_height = item.height
                end
                setting_data.show_num = i
            end
        else
            break
        end
    end
end

--scroll滚动监听，item高度可变
function BaseUtils.on_value_change_unfixed(setting_data)
    local cur_y = setting_data.item_con:GetComponent(RectTransform).anchoredPosition.y
    setting_data.scroll_change_count = setting_data.scroll_change_count + math.abs(cur_y - setting_data.item_con_last_y)
    local temp_item_height = 0
    if cur_y > setting_data.item_con_last_y then
        temp_item_height = setting_data.top_item_height
    else
        temp_item_height = setting_data.bottom_item_height
    end

    if setting_data.scroll_change_count < temp_item_height then
        setting_data.item_con_last_y = cur_y
        return
    end
    local loop_height = 0
    for i=1,setting_data.show_num do
        if loop_height >= setting_data.scroll_change_count then
            break
        end
        if cur_y <= setting_data.item_con_last_y then
            if setting_data.data_head_index ~= 1 and cur_y < (setting_data.item_con_height - setting_data.scroll_con_height) then
                local tail_item = setting_data.item_list[setting_data.item_tail_index]
                local oldY = tail_item.transform:GetComponent(RectTransform).anchoredPosition.y
                if math.abs(oldY) > (math.abs(cur_y)+setting_data.scroll_con_height) then
                    setting_data.data_head_index = setting_data.data_head_index - 1
                    setting_data.data_tail_index = setting_data.data_tail_index - 1

                    local mem_data = setting_data.data_list[setting_data.data_head_index]
                    tail_item:update_my_self(mem_data, setting_data.data_head_index)
                    local head_item = setting_data.item_list[setting_data.item_head_index]
                    local newY = head_item.transform:GetComponent(RectTransform).anchoredPosition.y + tail_item.height
                    local _X = tail_item.gameObject.transform:GetComponent(RectTransform).anchoredPosition.x
                    tail_item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(_X, newY)
                    setting_data.item_head_index = setting_data.item_tail_index
                    setting_data.item_tail_index = setting_data.item_tail_index - 1
                    if setting_data.item_tail_index <= 0 then
                        setting_data.item_tail_index = #setting_data.item_list
                    end
                    loop_height = loop_height + setting_data.bottom_item_height
                    setting_data.top_item_height = setting_data.item_list[setting_data.item_head_index].height
                    setting_data.bottom_item_height = setting_data.item_list[setting_data.item_tail_index].height
                end
            end
        elseif cur_y > setting_data.item_con_last_y then
            if setting_data.data_tail_index ~= #setting_data.data_list and cur_y >= setting_data.top_item_height then
                local head_item = setting_data.item_list[setting_data.item_head_index]
                local oldY = head_item.transform:GetComponent(RectTransform).anchoredPosition.y
                if math.abs(oldY) < math.abs(cur_y) - setting_data.top_item_height then
                    setting_data.data_tail_index = setting_data.data_tail_index + 1
                    setting_data.data_head_index = setting_data.data_head_index + 1
                    local mem_data = setting_data.data_list[setting_data.data_tail_index]
                    head_item:update_my_self(mem_data, setting_data.data_tail_index)
                    local tail_item = setting_data.item_list[setting_data.item_tail_index]
                    local newY = tail_item.transform:GetComponent(RectTransform).anchoredPosition.y - tail_item.height
                    local _X = head_item.gameObject.transform:GetComponent(RectTransform).anchoredPosition.x
                    head_item.transform:GetComponent(RectTransform).anchoredPosition = Vector2(_X, newY)
                    setting_data.item_tail_index = setting_data.item_head_index
                    setting_data.item_head_index = setting_data.item_head_index + 1
                    if setting_data.item_head_index > #setting_data.item_list then
                        setting_data.item_head_index = 1
                    end
                    loop_height = loop_height + setting_data.top_item_height
                    setting_data.top_item_height = setting_data.item_list[setting_data.item_head_index].height
                    setting_data.bottom_item_height = setting_data.item_list[setting_data.item_tail_index].height
                end
            end
        end
    end
    setting_data.scroll_change_count = 0
    setting_data.item_con_last_y = cur_y
end

function BaseUtils.Platform()
    return Application.platform
end

function BaseUtils.IsIPhonePlayer()
    return Application.platform == RuntimePlatform.IPhonePlayer or Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor
end

function BaseUtils.CSVersionToNum()
    local version = "1.0.5"
    if CSVersion then
        version = CSVersion.Version
    end
    local total = 0
    local x = 10000
    for mu_id in string.gmatch(version, "(%d+)") do
        total = total + mu_id * x
        x = x / 100
    end
    return total
end

function BaseUtils.TransformBaseLooks(baseLooks)
    local looks = {}
    for i,v in ipairs(baseLooks) do
        local one = {}
        one.looks_type = v[1]
        one.looks_mode = v[2]
        one.looks_val = v[3]
        one.looks_str = v[4]
        table.insert(looks, one)
    end
    return looks
end

function BaseUtils.ChangeLayersRecursively(transform, name)
    transform.gameObject.layer = LayerMask.NameToLayer(name)
end
--当前时间是否在给定的时间范围内
function BaseUtils.IsInTimeRange(startMonth,startDay,endMonth,endDay)
    local isIn = false
    local startTime = os.time{year=os.date("%Y", BaseUtils.BASE_TIME), month=startMonth, day=startDay, hour=0,min=0,sec=0}
    local endTime = os.time{year=os.date("%Y", BaseUtils.BASE_TIME), month=endMonth, day=endDay, hour=23,min=59,sec=59}
    if startTime <= BaseUtils.BASE_TIME and BaseUtils.BASE_TIME <= endTime then
        isIn = true
    end
    return isIn
end

function BaseUtils.ChangeShaderForOldVersion(material)
    ModelShaderManager.Instance:ChangeShaderForOldVersion(material)
end
--判断别人和自己是否是来自同一个服的
function BaseUtils.IsTheSamePlatform(platform,zoneid)
    if LoginManager.Instance.mixSvrList == nil then
        return RoleManager.Instance.RoleData.platform == platform and RoleManager.Instance.RoleData.zone_id == zoneid
    end
    for k,v in pairs(LoginManager.Instance.mixSvrList) do
        if v.platform == platform and v.zone_id == zoneid then
            return true
        end
    end
    return false
end

-- 获取EYOU商 品数据
function BaseUtils.GetProductDataForEyou(amount)
    -- 跟ios同一个配置
     -- local andriodList = {
     --    [1] = {tag = "com.eyougame.mhqy.199", level = 1, rmb = 199, gold = 120, tokes = 0},
     --    [2] = {tag = "com.eyougame.mhqy.499", level = 2, rmb = 499, gold = 300, tokes = 0},
     --    [3] = {tag = "com.eyougame.mhqy.1599", level = 3, rmb = 1599, gold = 1000, tokes = 0},
     --    [4] = {tag = "com.eyougame.mhqy.3099", level = 4, rmb = 3099, gold = 2000, tokes = 0},
     --    [5] = {tag = "com.eyougame.mhqy.4999", level = 5, rmb = 4999, gold = 3200, tokes = 0},
     --    [6] = {tag = "com.eyougame.mhqy.9999", level = 6, rmb = 9999, gold = 6500, tokes = 0},
     --    [7] = {tag = "com.eyougame.mhqy.1099", level = 7, rmb = 1099, gold = 800, tokes = 0},
     --    [8] = {tag = "com.eyougame.mhqy.2099", level = 8, rmb = 2099, gold = 1500, tokes = 0},
     --    [9] = {tag = "com.eyougame.mhqy.7999", level = 9, rmb = 7999, gold = 4500, tokes = 0},
     --    [10] = {tag = "com.eyougame.mhqy.099", level = 10, rmb = 99, gold = 60, tokes = 0},
     --    [11] = {tag = "com.eyougame.mhqy.299", level = 11, rmb = 299, gold = 180, tokes = 0},
     --    [12] = {tag = "com.eyougame.mhqy.399", level = 12, rmb = 399, gold = 240, tokes = 0},
     --    [13] = {tag = "com.eyougame.mhqy.799", level = 13, rmb = 799, gold = 480, tokes = 0},
     --    [14] = {tag = "com.eyougame.mhqy.1699", level = 14, rmb = 1699, gold = 1100, tokes = 0}
     -- }
     for i,v in pairs(DataRecharge.data_ios) do
        if v.game_name == BaseUtils.GetGameName() and v.rmb == amount then
            return v
        end
    end
    return nil
end

function BaseUtils.ScreenShot()
    local index = PlayerPrefs.GetInt("ScreenShot") + 1
    PlayerPrefs.SetInt("ScreenShot", index)
    Application.CaptureScreenshot(string.format("%s/%s.jpg", Application.persistentDataPath, index))
end

-- ---------------------------------------------------------------------------------------
-- 检查是否是审核状态
-- IOS出新包的时候需要审核
-- 根据审核所用的cdn路径可以区分出是否是审核
-- 目前没有标志说明是否审核，但现在审核的资源库地址是独立的，暂用这个来做判断区分
-- hosr 2016-07-15
-- 国服线上资源库地址 => http://cdnres.xcqy.shiyuegame.com/xcqy_march_ios
-- 国服审核资源库地址 => http://cdnres.xcqy.shiyuegame.com/xcqy_four_ios
-- ---------------------------------------------------------------------------------------
function BaseUtils.CheckVerify()
    BaseUtils.IsVerify = false
    if Application.platform == RuntimePlatform.IPhonePlayer then
        if string.find(ctx.CdnPath, "xcqy_four_ios") ~= nil then
            -- print("=============== 注意:目前是审核状态 ===============")
            BaseUtils.IsVerify = true
        end
    end
end

function BaseUtils.ShowNpcDialog(npcid,msg)
    local npcBase = BaseUtils.copytab(DataUnit.data_unit[npcid])
    npcBase.buttons = {}
    npcBase.plot_talk = msg
    MainUIManager.Instance:OpenDialog({baseid = npcid, name = npcBase.name}, {base = npcBase}, true, true)
end

-- UI界面是有拉伸的，这个方法将屏幕坐标换算成UI坐标
function BaseUtils.ScreenToUIPoint(point)
    -- 返回的是屏幕长宽
    local width = ctx.ScreenWidth
    local height = ctx.ScreenHeight
    local origin = 960 / 540
    local current = width / height

    local cw = 0
    local ch = 0
    if current > origin then
        -- 以宽为准
        cw = 960 * current / origin
        ch = 540
    else
        -- 以高为准
        cw = 960
        ch = 540 * origin / current
    end
    local x = point.x * cw / ctx.ScreenWidth
    local y = point.y * ch / ctx.ScreenHeight

    -- -- 实际UI长宽
    -- local h = ((origin / current - 1) / 2 + 1) * 540
    -- local w = ((origin - current) / 2 + current) / origin * 960

    -- -- 屏幕长宽转换成UI长宽
    -- local x = w * point.x / width
    -- local y = h * point.y / height

    return Vector2(x, y)
end

-- 有序数组二分查找

-- value要查找的值
-- array经过排序的数组,array[1]<array[2]<array[3]<...<array[n-1]<array[n]
-- cmp cmp(a,b)比较函数, 返回0代表a=b, 返回1代表a<b, 返回-1代表a>b, 默认以数字大小进行比较
-- 函数返回一个表{index = index, target = target}
--      target = nil代表找不到这个值并且此时index代表array[index] < value 或者value < array[index + 1]
--      target ~= nil代表查找成功, index代表value所处的位置
function BaseUtils.BinarySearch(value, array, cmp)
    local res = {index = 0, value = nil}
    local arraySize = #array

    if arraySize == 0 then
        return res
    end

    local beginIndex = 1
    local endIndex = arraySize + 1
    local midIndex = nil
    local cmpRes = nil
    local cmpResBeg = nil
    local cmpResEnd = nil
    local floor = math.floor

    if cmp == nil then
        cmp = function(a,b)
            if a == b then return 0
            elseif a < b then return 1
            else return -1
            end
        end
    end

    cmpResBeg = cmp(array[beginIndex], value)
    cmpResEnd = cmp(array[endIndex - 1], value)

    if cmpResBeg == 0 then
        return {index = beginIndex, target = array[beginIndex]}
    elseif cmpResBeg < 0 then
        return {index = 0}
    end

    if cmpResEnd == 0 then
        return {index = endIndex - 1, target = array[endIndex - 1]}
    elseif cmpResEnd > 0 then
        return {index = arraySize}
    end

    local time = 0
    while endIndex - beginIndex > 1 do
        time = time + 1
        midIndex = floor((endIndex + beginIndex) / 2)
        cmpRes = cmp(array[midIndex], value)

        if cmpRes == 0 then
            res.index = midIndex
            res.target = array[midIndex]
            break
        elseif cmpRes < 0 then
            res.index = beginIndex
            res.target = nil
            endIndex = midIndex
        else
            res.index = midIndex
            res.target = nil
            beginIndex = midIndex
        end

        if time > 100 then
            Log.Error("二分查找死循环了")
            break
        end
    end

    return res
end

function BaseUtils.ScaleTextureBilinear(originalTexture, scaleFactor)
    local newTexture = Texture2D(math.ceil (originalTexture.width * scaleFactor), math.ceil (originalTexture.height * scaleFactor), TextureFormat.RGB24, false)
    local scale = 1.0 / scaleFactor;
    local maxX = originalTexture.width - 1
    local maxY = originalTexture.height - 1
    for y = 0, newTexture.height-1 do
        for x = 0, newTexture.width-1 do
            -- Bilinear Interpolation
            local targetX = x * scale;
            local targetY = y * scale;
            local x1 = Mathf.Min(maxX, math.floor(targetX))
            local y1 = Mathf.Min(maxY, math.floor(targetY))
            local x2 = Mathf.Min(maxX, x1 + 1)
            local y2 = Mathf.Min(maxY, y1 + 1)

            local u = targetX - x1
            local v = targetY - y1
            local w1 = (1 - u) * (1 - v)
            local w2 = u * (1 - v)
            local w3 = (1 - u) * v
            local w4 = u * v
            local color1 = originalTexture:GetPixel(x1, y1)
            local color2 = originalTexture:GetPixel(x2, y1)
            local color3 = originalTexture:GetPixel(x1, y2)
            local color4 = originalTexture:GetPixel(x2,  y2)
            local color = Color(Mathf.Clamp01(color1.r * w1 + color2.r * w2 + color3.r * w3+ color4.r * w4),
                Mathf.Clamp01(color1.g * w1 + color2.g * w2 + color3.g * w3 + color4.g * w4),
                Mathf.Clamp01(color1.b * w1 + color2.b * w2 + color3.b * w3 + color4.b * w4),
                Mathf.Clamp01(color1.a * w1 + color2.a * w2 + color3.a * w3 + color4.a * w4)
                )
            newTexture:SetPixel(x, y, color)
        end
    end
    -- newTexture:Apply(false)
    return newTexture
end

-- 将原图按长宽缩小，空白补黑边
function BaseUtils.FormatTexture(originalTexture, targetwidth, targetheight)
    local newTexture = Texture2D(targetwidth, targetheight, TextureFormat.RGB24, false)
    local WScale = targetwidth/originalTexture.width
    local HScale = targetheight/originalTexture.height
    local scaleFactor = WScale < HScale and WScale or HScale
    return BaseUtils.ScaleTextureBilinear(originalTexture, scaleFactor)
end

-- 拓扑排序
-- graph 用链表储存的图(必须保证不存在环)
-- graph = {
--     [id1] = {id2, id3, id4},
--     ...
-- }
-- 返回经过排序后的节点数组{id1', id2', id3', id4', ...}
function BaseUtils.TopologicalSort(graph)
    local res = {}
    local indegree = {}

    -- 初始化入度数组
    for id,_ in pairs(graph) do
        indegree[id] = 0
    end

    -- 计算入度
    for _,idlist in pairs(graph) do
        for _,id in ipairs(idlist) do
            indegree[id] = indegree[id] + 1
        end
    end

    while true do
        local res1 = {}
        for id,v in pairs(indegree) do
            if v ~= nil and v == 0 then
                table.insert(res1, id)
                indegree[id] = nil
            end
        end

        for _,id in ipairs(res1) do
            for _,id_ in ipairs(graph[id]) do
                indegree[id_] = indegree[id_] - 1
            end
            table.insert(res, id)
        end

        local notHaveZero = true
        for _,v in pairs(indegree) do
            if v ~= nil then
                notHaveZero = notHaveZero and (v ~= 0)
            end
        end
        if notHaveZero then
            break
        end
    end

    return res
end

function BaseUtils.DefaultHoldTime()
    if BaseUtils.platform == nil then
        BaseUtils.platform = Application.platform
    end
    if BaseUtils.platform == RuntimePlatform.IPhonePlayer then
        -- return 90
        return 45 -- 周年庆期间ios的释放时间临时缩短
    else
        return 180
    end
end

-- len2 < len
function BaseUtils.string_cut_utf8(str, len, len2)
    local tab = StringHelper.ConvertStringTable(str)
    local length = #tab
    if length > len then
        local tab1 = {}
        for i=1,len2 do
            table.insert(tab1, tab[i])
        end
        return tostring(table.concat(tab1)) .. ".."
    else
        return str
    end
end

-- 代替lua的sort，以避免出现不稳定排序问题
function BaseUtils.BubbleSort(templist, sortFuc)
    local list = {}
    for k, v in pairs(templist) do
        table.insert(list, v)
    end
    local tempVal = true
    for m=#list-1,1,-1 do
        tempVal = true
        for i=#list-1,1,-1 do
            local a = list[i]
            local b = list[i+1]
            local sortBoo = sortFuc(a, b)
            if sortBoo == false then
                list[i], list[i+1] = list[i+1], list[i]
                tempVal = false
            end
        end
        if tempVal then break end
    end
    return list
end

function BaseUtils.GetServerName(platform, zone_id)
    local serverName = TI18N("神秘大陆")
    for k, v in pairs(DataServerList.data_server_name) do
        if v.platform == platform and v.zone_id == zone_id then
            serverName = v.platform_name
            break
        end
    end
    return serverName
end

function BaseUtils.GetServerNameMerge(platform, zone_id)
    local serverName = TI18N("神秘大陆")
    for k, v in pairs(DataServerList.data_server_name_merge) do
        if v.platform == platform and v.zone_id == zone_id then
            serverName = v.platform_name
            break
        end
    end
    return serverName
end

function BaseUtils.DestroyChildObj(trans)
    if not BaseUtils.isnull(trans) then
        local childnum = trans.childCount
        for i=1,childnum do
            GameObject.DestroyImmediate(trans:GetChild(0))
        end
    end
end

function BaseUtils.LocalTime(time)
    return time + 28800
end

-- 获取当前时间到次日零点剩余多少
function BaseUtils.TimeToNextDay()
    return BaseUtils.NextZeroTime() - BaseUtils.BASE_TIME
end

-- 获取次日零点的时间戳
function BaseUtils.NextZeroTime()
    local year = os.date("%Y", BaseUtils.BASE_TIME)
    local month = os.date("%m", BaseUtils.BASE_TIME)
    local day = os.date("%d", BaseUtils.BASE_TIME)
    return os.time({year = year, month = month, day = day, hour = 0, minute = 0, second = 0}) + 86400
end

-- 获取当日零点的时间戳
function BaseUtils.CurrentZeroTime(time)
    time =  time or BaseUtils.BASE_TIME
    local year = os.date("%Y", time)
    local month = os.date("%m", time)
    local day = os.date("%d", time)
    return os.time({year = year, month = month, day = day, hour = 0, minute = 0, second = 0})
end

function BaseUtils.ToBase64(source_str)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local s64 = ""
    local str = source_str

    while #str > 0 do
        local bytes_num = 0
        local buf = 0

        for byte_cnt=1,3 do
            buf = (buf * 256)
            if #str > 0 then
                buf = buf + string.byte(str, 1, 1)
                str = string.sub(str, 2)
                bytes_num = bytes_num + 1
            end
        end

        for group_cnt=1,(bytes_num+1) do
            local b64char = math.fmod(math.floor(buf/262144), 64) + 1
            s64 = s64 .. string.sub(b64chars, b64char, b64char)
            buf = buf * 64
        end

        for fill_cnt=1,(3-bytes_num) do
            s64 = s64 .. "="
        end
    end

    return s64
end

function BaseUtils.GetRoleAssetVal(base_id)
    local roledata = RoleManager.Instance.RoleData
    if base_id == KvData.assets.coin then
        return roledata.coin
    elseif base_id == KvData.assets.gold then
        return roledata.gold
    elseif base_id == KvData.assets.gold_bind then
        return roledata.gold_bind
    elseif base_id == KvData.assets.bind then
        return roledata.bind
    elseif base_id == KvData.assets.intelligs then
        return roledata.intelligs
    elseif base_id == KvData.assets.pet_exp then
        return roledata.pet_exp
    elseif base_id == 90006 then
        return roledata.energy
    elseif base_id == KvData.assets.exp then
        return roledata.exp
    elseif base_id == KvData.assets.guild then
        return roledata.guild
    end
    return 0
end

function BaseUtils.SelectionSex(sex, conditionSex)
    if conditionSex == 2 then
        return true
    else
        return sex == conditionSex
    end
end

function BaseUtils.SelectionClasses(classes, conditionClasses)
    if conditionClasses == 0 then
        return true
    else
        return classes == conditionClasses
    end
end

-- 充值接口传递参数处理
function BaseUtils.GetServerId(roleData)
    local platform = roleData.platform
    local zone_id =  roleData.zone_id
    if platform == "beta" then
        return 1000 + tonumber(zone_id)
    elseif platform == "ios" then
        return 2000 + tonumber(zone_id)
    elseif platform == "mix" then
        return 3000 + tonumber(zone_id)
    elseif platform == "unite" then
        return 4000 + tonumber(zone_id)
    elseif platform == "verify" then
        return 10000 + tonumber(zone_id)
    end
    return zone_id
end

-- 四舍五入
-- math.round()不是传统意义上的四舍五入，这里另外做了一个
function BaseUtils.Round(value)
    return math.ceil(math.floor(value * 2) / 2)
end

function BaseUtils.GetItemPath(iconId)
    local path = ""
    if iconId < 20000 then
        path = string.format(AssetConfig.equipiconSingle, iconId)
    elseif iconId < 20800 then
        path = string.format(AssetConfig.itemiconSingle, iconId)
    elseif iconId < 22400 then
        path = string.format(AssetConfig.itemiconSingle2, iconId)
    elseif iconId < 23590 then
        path = string.format(AssetConfig.itemiconSingle3, iconId)
    elseif iconId < 28000 then
        path = string.format(AssetConfig.itemiconSingle4, iconId)
    elseif iconId <= 50000 then
        path = string.format(AssetConfig.itemiconSingle5, iconId)
    elseif iconId < 60000 then
        path = string.format(AssetConfig.itemiconSingle6, iconId)
    elseif iconId < 90000 then
        path = string.format(AssetConfig.itemiconSingle7, iconId)
    else
        path = string.format(AssetConfig.itemiconSingle8, iconId)
    end
    return path
end

function BaseUtils.ShowEffect(id, transform, scale, position, time, rotation, callfun)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(transform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = scale or Vector3.one
        effectObject.transform.localPosition = position or Vector3(0, 0, 0)
        effectObject.transform.localRotation = rotation or Quaternion.identity
        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
        if callfun ~= nil then callfun() end
    end
    return BaseEffectView.New({effectId = id, time = time, callback = fun})
end

-- 传入一个image控件，释放sprite
function BaseUtils.ReleaseImage(image)
    if image ~= nil then
        if BaseUtils.isnull(image) then
            if IS_DEBUG then
                Log.Error("释放sprite出错，可能导致内存泄漏\n" .. debug.traceback())
            end
        else
            image.sprite = nil
        end
    else
    end
end

function BaseUtils.CheckCampaignTime(campaignId)
    -- local NowTime = BaseUtils.BASE_TIME
    --local startTime = DataCampaign.data_list[campaignId].cli_start_time[1]
    --local endTime = DataCampaign.data_list[campaignId].cli_end_time[1]
    -- local startTimeStamp = os.time({year = startTime[1], month = startTime[2], day = startTime[3], hour = startTime[4], min = startTime[5], sec = startTime[6]})
    -- local endTimeStamp = os.time({year = endTime[1], month = endTime[2], day = endTime[3], hour = endTime[4], min = endTime[5], sec = endTime[6]})
    -- if NowTime <= endTimeStamp and NowTime >= startTimeStamp then
    --     return true
    -- else
    --     return false
    -- end
    if CampaignManager.Instance.campaignTab[campaignId] ~= nil then
        return true
    else
        return false
    end
end


-- 打印很多标记，用于调试，用完记得记得记得记得记得删除
function BaseUtils.PrintAlotMark(mark, num)
    local length = num
    if length == nil then
        length = 10
    end
    for i=1, length do
        print(string.format("<color='#ff0000'>%s</color>", mark))
    end
end

function BaseUtils.FormatNum(val)
    if val >= 10000 and val < 100000 then
        local temp = math.floor(val/10000)
        return string.format("%s%s", temp, TI18N("万"))
    elseif val >= 100000 and val < 1000000 then
        local temp = math.floor(val/1000)
        return string.format("%s%s", temp / 10, TI18N("万"))
    elseif val >= 1000000 and val < 10000000 then
        local temp = math.floor(val/1000)
        return string.format("%s%s", temp / 10, TI18N("万"))
    elseif val >= 10000000 and val < 100000000 then
        local temp = math.floor(val/10000000)
        return string.format("%s%s", temp, TI18N("千万"))
    elseif val >= 100000000 and val < 1000000000 then
        local temp = math.floor(val/10000000)
        return string.format("%s%s", temp / 10, TI18N("亿"))
    elseif val >= 1000000000 then
        local temp = math.floor(val/10000000)
        return string.format("%s%s", temp / 10, TI18N("亿"))
    end
    return tostring(val)
end

-- 是否玩家测试服
function BaseUtils.IsExperienceSrv()
    if CSVersion.platform == "android_experience" then
        return true
    else
        return false
    end
end

function BaseUtils.IsWideScreen()
    return (ctx.ScreenWidth / ctx.ScreenHeight) > (16 / 9)
end

function BaseUtils.IsIPhoneX()
    -- return (Application.platform == RuntimePlatform.IPhonePlayer and BaseUtils.GetClientVerion() > "2.8.5") and BaseUtils.IsWideScreen() and ((ctx.ScreenWidth / ctx.ScreenHeight) > 2.1)
    return BaseUtils.CheckLiuHai()
end

BaseUtils.IS_LIUHAI = nil -- 刘海标记
-- 检查设备型号，判断是否是带刘海的
function BaseUtils.CheckLiuHai()
    if BaseUtils.IS_LIUHAI ~= nil then -- 检测过，有值就直接返回
        return BaseUtils.IS_LIUHAI
    end

    if Application.platform == RuntimePlatform.IPhonePlayer then
        if BaseUtils.GetClientVerion() > "2.8.5" then
            if BaseUtils.IsWideScreen() and ((ctx.ScreenWidth / ctx.ScreenHeight) > 2.1) then
                BaseUtils.IS_LIUHAI = true
            end
        end
    elseif Application.platform == RuntimePlatform.Android then
        if BaseUtils.GetClientVerion() >= "1.7.2" and BaseUtils.GetClientVerion() ~= "9.9.9" then
            BaseUtils.IS_LIUHAI = ctx:HasNotchInScreen()
            local h = Screen.height
            local w = Screen.width
            local rate = 0
            if h > w then
                rate = h / w
            else
                rate = w / h
            end
            if rate < 2.0 then
                BaseUtils.IS_LIUHAI = false
            else
                local dType = ctx:GetDeviceType()
                if dType == "MI 8" 
                    or dType == "Xiaomi dipper" 
                    or dType == "Xiaomi sirius" 
                    or dType == "MI 8 SE" 
                    or dType == "Xiaomi equuleus" 
                then
                    BaseUtils.IS_LIUHAI = true
                end
        end
        end
    end

    if BaseUtils.IS_LIUHAI then
        return true
    else
        return false
    end
end

function BaseUtils.IsMixPlatformChanle()
    if ctx.PlatformChanleId == 22 --步步高
        or ctx.PlatformChanleId == 12 -- oppo
        or ctx.PlatformChanleId == 13 -- UC
        or ctx.PlatformChanleId == 8 -- 华为
        or ctx.PlatformChanleId == 11 -- 小米
        or ctx.PlatformChanleId == 32 -- 魅族
        or ctx.PlatformChanleId == 3 -- 360
        or ctx.PlatformChanleId == 9 -- 金立
        or ctx.PlatformChanleId == 110 -- 乐视
        or ctx.PlatformChanleId == 51 -- 4399
        or ctx.PlatformChanleId == 38 -- 酷派
        or ctx.PlatformChanleId == 15 -- 联想
        or ctx.PlatformChanleId == 58 -- 酷狗
        or ctx.PlatformChanleId == 76 -- 搜狗
        or ctx.PlatformChanleId == 121 -- 三星
        or ctx.PlatformChanleId == 122  -- pptv
        then
        return true
    end
    return false
end

function BaseUtils.GetIPhoneXOffsetRight()
    return Vector2(-30, -10), Vector2(20, 10)
end

function BaseUtils.GetIPhoneXOffsetLeft()
    return Vector2(-20, -10), Vector2(30, 10)
end

function BaseUtils.AdaptIPhoneX(transform)
    if BaseUtils.isnull(transform) then
        return
    end

    BaseUtils.iPhoneXTweenId = BaseUtils.iPhoneXTweenId or {}
    local targetOffsetMax = nil
    local targetOffsetMin = nil

    if MainUIManager.Instance.adaptIPhoneX then
        if Screen.orientation == ScreenOrientation.LandscapeRight then
            targetOffsetMax, targetOffsetMin = BaseUtils.GetIPhoneXOffsetRight()
        else
            targetOffsetMax, targetOffsetMin = BaseUtils.GetIPhoneXOffsetLeft()
        end
    else
        targetOffsetMin = Vector2.zero
        targetOffsetMax = Vector2.zero
    end

    local originOffsetMax = transform.offsetMax
    local originOffsetMin = transform.offsetMin
    if BaseUtils.iPhoneXTweenId[transform:GetInstanceID()] ~= nil then
        Tween.Instance:Cancel(BaseUtils.iPhoneXTweenId[transform:GetInstanceID()])
    end
    BaseUtils.iPhoneXTweenId[transform:GetInstanceID()] = Tween.Instance:ValueChange(0, 1, 0.3, function() BaseUtils.iPhoneXTweenId[transform:GetInstanceID()] = nil end, LeanTweenType.linear, function(value)
        transform.offsetMin = originOffsetMin + (targetOffsetMin - originOffsetMin) * value
        transform.offsetMax = originOffsetMax + (targetOffsetMax - originOffsetMax) * value
    end).id
end

function BaseUtils.CancelIPhoneXTween(transform)
    if BaseUtils.iPhoneXTweenId[transform:GetInstanceID()] ~= nil then
        Tween.Instance:Cancel(BaseUtils.iPhoneXTweenId[transform:GetInstanceID()])
    end
end

-- url编码
function BaseUtils.LogUrlEncode(str)
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
    function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
    return str
end

function BaseUtils.ActiveDevice(dat)
    if BaseUtils.IsVerify then --审核状态，不做信息上报
        return
    end
    local device_id = SdkManager.Instance:GetDeviceIdIMEI()
    if device_id == nil or device_id == "" or device_id == "10000" then
        device_id = PlayerPrefs.GetString("virtual_device_id")
        if device_id == nil or device_id == "" then
            device_id = string.format("%s_%s_%s", "virtual", os.time(), Random.Range(1000, 9999))
            PlayerPrefs.SetString("virtual_device_id", device_id)
        end
    end
    if device_id ~= "" then
        -- PlayerPrefs.DeleteKey(device_id)        --测试用，删除缓存KEY
        local str = PlayerPrefs.GetString(device_id,"")
        if str == "" then
            local date_time = os.date("%Y-%m-%d %H:%M:%S")
            local source_str = KvData.product_name..date_time..KvData.secret_key
            local sign = Utils.MD52Php(source_str)
            if IS_DEBUG then
                KvData.activeUrl = "http://192.168.1.110/index.php/device/activation"
            end
            if sign ~= "" then
                local url = string.format("%s?device_id=%s&product_name=%s&platform_name=%s&channel_name=%s&date_time=%s&sign=%s",KvData.activeUrl,BaseUtils.LogUrlEncode(device_id),BaseUtils.LogUrlEncode(KvData.product_name),BaseUtils.LogUrlEncode(dat.platform),BaseUtils.LogUrlEncode(ctx.PlatformChanleId),BaseUtils.LogUrlEncode(date_time),BaseUtils.LogUrlEncode(sign))
                ctx:GetRemoteTxt(url, function(result)
                    if string.match(result, "error:") == nil then
                        local tmp = string.gsub(result,"true","\"true\"")
                        local resultData =  NormalJson(tmp)
                        -- printf(tmp)
                        if resultData ~= nil and resultData.table ~= nil then
                            -- printf(resultData.table.success)
                            if resultData.table.success == "true" then
                                -- printf(KvData.activeUrl .. "-------设备激活成功")
                                PlayerPrefs.SetString(device_id, device_id)
                            end
                        end
                    end
                end, 1, "error__")
            end
        else
            -- printf("设备已激活")
        end
    end
end

function BaseUtils.NewPlayerImport(stepData,platformName)
    if BaseUtils.IsVerify then --审核状态，不做信息上报
        return
    end
    -- BaseUtils.dump(stepData, "------BaseUtils.NewPlayerImport----")
    local device_id = SdkManager.Instance:GetDeviceIdIMEI()
    if device_id == nil or device_id == "" or device_id == "10000" then
        device_id = PlayerPrefs.GetString("virtual_device_id")
        if device_id == nil or device_id == "" then
            device_id = string.format("%s_%s_%s", "virtual", os.time(), Random.Range(1000, 9999))
            PlayerPrefs.SetString("virtual_device_id", device_id)
        end
    end
    if device_id ~= "" then
        -- printf(device_id)
        local key = string.format("%s_%s",device_id,stepData.key)
        -- PlayerPrefs.DeleteKey(key)        --测试用，删除缓存KEY
        local strKey = PlayerPrefs.GetString(key,"")
        if strKey == "" then
            local netWorkType = ctx:GetNetworkType()
            local resolution = ctx.ScreenWidth .. "*" .. ctx.ScreenHeight
            local date_time = os.date("%Y-%m-%d %H:%M:%S")
            local source_str = KvData.product_name..date_time..KvData.secret_key
            local sign = Utils.MD52Php(source_str)
            if sign ~= "" then
                local deviceType = "pc"
                if Application.platform == RuntimePlatform.IPhonePlayer then
                    deviceType = "iPhone"
                elseif Application.platform == RuntimePlatform.Android then
                    deviceType = "android"
                end

                if platformName == nil then
                    platformName = "unite"
                    if BaseUtils.PlatformChanleIdToPlatformName[ctx.PlatformChanleId] ~= nil then
                        platformName = BaseUtils.PlatformChanleIdToPlatformName[ctx.PlatformChanleId]
                    end
                end
                if IS_DEBUG then
                    KvData.newPlayerImportUrl = "http://192.168.1.110/index.php/entry/step"
                end
                local url = string.format("%s?device_id=%s&device_type=%s&network_type=%s&resolution=%s&product_name=%s&platform_name=%s&channel_name=%s&date_time=%s&step=%s&sign=%s", KvData.newPlayerImportUrl, BaseUtils.LogUrlEncode(device_id),BaseUtils.LogUrlEncode(deviceType), BaseUtils.LogUrlEncode(netWorkType), BaseUtils.LogUrlEncode(resolution), BaseUtils.LogUrlEncode(KvData.product_name), BaseUtils.LogUrlEncode(platformName), BaseUtils.LogUrlEncode(ctx.PlatformChanleId), BaseUtils.LogUrlEncode(date_time), BaseUtils.LogUrlEncode(stepData.index), BaseUtils.LogUrlEncode(sign))
                ctx:GetRemoteTxt(url, function(result)
                    if string.match(result, "error:") == nil then
                        local tmp = string.gsub(result,"true","\"true\"")
                        local resultData =  NormalJson(tmp)
                        if resultData ~= nil and resultData.table ~= nil then
                            -- printf(resultData.table.success)
                            if resultData.table.success == "true" then
                                PlayerPrefs.SetString(key, key)
                                -- print(KvData.newPlayerImportUrl .. "-------玩家导入" .. stepData.key)
                            end
                        end
                    end
                end, 1, "error_")
            end
        end
    end
end

BaseUtils.VerifyColor = {
    ["xcqy"] = Color(0.5, 0.9, 0.8, 0.9),
    ["scbb"] = Color(0.2, 0.4, 0.8, 0.9),
    ["jlhx"] = Color(0.8, 0.4, 0.2, 0.9),
    ["mlhx"] = Color(0.3, 0.4, 0.2, 0.9),
    ["syqy"] = Color(0.8, 0.8, 0.2, 0.9),
    ["mhqy2"] = Color(0.8, 0.4, 0.6, 0.9),
    ["jlmx"] = Color(0.1, 0.4, 0.2, 0.9),
    -- 以下是预订的颜色,按照游戏名直接匹配使用
    ["Vest1"] = Color(70/255,142/200,148/200,1),
    ["Vest2"] = Color(80/200,0/200,222/200,1),
    ["Vest3"] = Color(222/200,0/200,115/200,1),
    ["Vest4"] = Color(222/200,0/200,0/255,1),
    ["Vest5"] = Color(222/255,83/255,0/255,1),
    ["Vest6"] = Color(222/255,189/255,0/255,1),
    ["Vest7"] = Color(201/255,222/255,0/255,1),
    ["Vest8"] = Color(109/255,222/255,0/255,1),
    ["Vest9"] = Color(35/255,222/255,0/255,1),
    ["Vest10"] = Color(0/255,114/255,255/255,1),
    ["Vest11"] = Color(157/255,0/255,151/255,1),
    ["Vest12"] = Color(157/255,0/255,0/255,1),
    ["Vest13"] = Color(157/255,0/255,255/255,1),
    ["Vest14"] = Color(255/255,0/255,255/255,1),
    ["Vest15"] = Color(90/255,37/255,24/255,1),
    ["Vest16"] = Color(1/255,65/255,203/255,1),
    ["Vest17"] = Color(64/255,43/255,38/255,1),
    ["Vest18"] = Color(71/255,17/255,3/255,1),
    ["Vest19"] = Color(62/255,50/255,79/255,1),
    ["Vest20"] = Color(31/255,14/255,56/255,1),
    ["Vest21"] = Color(255/255,144/255,248/255,1),
    ["Vest22"] = Color(148/255,99/255,145/255,1),
    ["Vest23"] = Color(255/255,107/255,107/255,1),
    ["Vest24"] = Color(75/255,7/255,7/255,1),
    ["Vest25"] = Color(255/255,21/255,21/255,1),
    ["Vest26"] = Color(255/255,255/255,0/255,1),
    ["Vest27"] = Color(58/255,148/255,58/255,1),
    ["Vest28"] = Color(148/255,58/255,58/255,1),
    ["Vest29"] = Color(148/255,70/255,110/255,1),
    ["Vest30"] = Color(108/255,70/255,148/255,1)
}

-- 马甲包游戏名格式范例：xcqy_IosVest_Vest30
function BaseUtils.GetVerifyColor()
    -- 第一种模式，用Vest来取颜色
    -- local name = BaseUtils.GetGameName()
    -- local color = BaseUtils.VerifyColor[name]
    -- if color == nil then -- 按照游戏名匹配颜色
    --     local list = StringHelper.Split(name, "_")
    --     color = BaseUtils.VerifyColor[list[#list]]

    --     if color == nil then
    --         color = Color.white
    --     end
    -- end
    -- return color
    
    -- 第二种模式，直接把色码写进游戏名中
    local name = BaseUtils.GetGameName()
    local list = StringHelper.Split(name, "_")
    if #list == 4 then
        local str = list[3]
        --检查内容是否合法，检查字符串长度
        if(str:find("[^0-9A-Fa-f]")==nil) and (str:len()==8) then
            local index=1
            local rgba = {}
            for index=1,str:len(),2 do
                table.insert( rgba, tonumber(str:sub(index,index+1),16) )
            end
            
            return Color(rgba[1]/255, rgba[2]/255, rgba[3]/255, rgba[4]/255)
        end
    end

    return Color.white
end

-- ios马甲包名字列表
BaseUtils.IosVestName = {"scbb", "jlhx", "mlhx", "syqy", "mhqy2", "jlmx"}

-- 判断是否马甲包
function BaseUtils.IsIosVest()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        local name = BaseUtils.GetGameName()
        if table.containValue(BaseUtils.IosVestName, name) then
            return true
        end

        if string.match(name, "_IosVest") ~= nil then
            return true
        end
    end
end

-- 判断是否新马甲包，即计费点从服务端获取的版本
function BaseUtils.IsNewIosVest()
    if Application.platform == RuntimePlatform.IPhonePlayer then
        local name = BaseUtils.GetGameName()
        if string.match(name, "_IosVest") ~= nil then
            return true
        end
    end
end

function BaseUtils.GetLoadingPageBgPath()
    local path = "loading_page_bg"
    if BaseUtils.GetGameName() ~= KvData.game_name.xcqy and SdkManager.Instance:RunSdk() then
        path = SdkManager.Instance:GetLoadingPageBg()
    end
    return path
end

BaseUtils.PlatformChanleIdToPlatformName = {
    [0] = "unite",
    [8] = "mix",
    [9] = "mix",
    [11] = "mix",
    [12] = "mix",
    [13] = "mix",
    [15] = "mix",
    [22] = "mix",
    [32] = "mix",
    [33] = "unite",
    [38] = "mix",
    [51] = "mix",
    [58] = "mix",
    [74] = "unite",
    [76] = "mix",
    [110] = "mix",
    [121] = "mix",
    [122] = "mix",
    [123] = "mix",
    [124] = "mix",
}

-- 判断是否使用BaseCanvas的加载页
function BaseUtils.IsUseBaseCanvasBg()
    if BaseUtils.IsNewIosVest() or (Application.platform == RuntimePlatform.Android and BaseUtils.CSVersionToNum() >= 10701) then
        return true
    else
        return false
    end
end

-- 判断是否使用BaseCanvas的Logo
function BaseUtils.IsUseBaseCanvasLogo()
    if Application.platform == RuntimePlatform.Android and BaseUtils.CSVersionToNum() >= 10701 then
        return true
    else
        return false
    end
end

-- 审核
function BaseUtils.VerifyRequire()
    function BaseView:__OnInitCompleted()
        self:OnInitCompleted()

        BaseUtils.VestChangeWindowBg(self.gameObject)
    end
    function BasePanel:__OnInitCompleted()
        self.loading = false
        self:OnInitCompleted()

        BaseUtils.VestChangeWindowBg(self.gameObject)
        BaseUtils.VestChangeMainUIPos(self)
    end
    function BaseWindow:__OnInitCompleted()
        self.loading = false
        self.isOpen = true
        WindowManager.Instance:OnOpenWindow(self)
        self:__DoClickPanel()
        self.OnInitCompletedEvent:Fire()
        self:OnInitCompleted()

        BaseUtils.VestChangeWindowBg(self.gameObject)
    end

    math.randomseed(KvData.GetVerifyRandomSeed())

    KvData.RandomNpc()
end

-- 审核状态跳过创角
function BaseUtils.VestPassCreateRole()
    local name = nil
    local sex = math.random(0, 1)
    local first_name_index = Random.Range(1,  DataRandomName.data_create_role_random_name_length)
    first_name_index = math.floor(first_name_index)
    local sec_name_index = Random.Range(1, DataRandomName.data_create_role_random_name_length)
    sec_name_index = math.floor(sec_name_index)
    local first_name = DataRandomName.data_create_role_random_name[first_name_index].surname
    local sec_name = DataRandomName.data_create_role_random_name[sec_name_index]
    if sex == 0 then --女
        name = first_name.."丶"..sec_name.woman1
    else --男
        name = first_name.."丶"..sec_name.male1
    end

    CreateRoleManager.Instance:do_create_role(name, sex, math.random(1, 7))
end

-- 需要隐藏的单独资源(特效，大图..)
BaseUtils.VestHideSingleTable = {
    ["Rabit_0"] = true,
    ["main"] = true,
}

-- 审核换窗口底图
function BaseUtils.VestChangeWindowBg(gameObject, layer)
    if not BaseUtils.isnull(gameObject) then
        if layer == nil then
            layer = 0
        else
            layer = layer + 1
        end
        local transform = gameObject.transform
        local childCount = transform.childCount - 1
        for i=0,childCount do
            local child = transform:GetChild(i)
            local image = child:GetComponent(Image)
            if image ~= nil then
                BaseUtils.VestChangeSprite(image)
                -- if tostring(image.sprite) == "WindowBg1 (UnityEngine.Sprite)" then
                --     image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.verify_textures, "WindowBg1_Verify"..BaseUtils.GetVerifySetting().windowBgType)
                --     image.color = BaseUtils.GetVerifySetting().windowBgColor
                -- elseif tostring(image.sprite) == "WindowBg2 (UnityEngine.Sprite)" then
                --     image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.verify_textures, "WindowBg2")
                -- elseif tostring(image.sprite) == "WindowBg3 (UnityEngine.Sprite)" then
                --     image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.verify_textures, "WindowBg3")
                -- elseif tostring(image.sprite) == "TipsBg1 (UnityEngine.Sprite)" then
                --     image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.verify_textures, "Tipsbg1")
                -- elseif tostring(image.sprite) == "TipsBg2 (UnityEngine.Sprite)" then
                --     image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.verify_textures, "Tipsbg2")
                -- end
                if BaseUtils.VestHideSingleTable[string.sub(tostring(image.sprite), 1, -22)] then
                    image.gameObject:SetActive(false)
                end
            end

            if layer < 10 then
                BaseUtils.VestChangeWindowBg(child.gameObject, layer)
            end
        end
    end
end

function BaseUtils.GetVestMainUIPosSettingMode()
    local name = BaseUtils.GetGameName()
    local seedstr = ""
    for i =1, #name do
        local str = string.sub(name,i,i)
        seedstr = seedstr..(string.byte(str))
    end
    math.randomseed(tonumber(seedstr))

    local bool = {}
    for i = 1, 12 do
        bool[i] = false 
    end

    local modeRes = {
        {6,7,8},
        {1,3},
        {2,3,7,8},
        {2,4,6,8,9,11,12}
    }

    local mode = {6,3,2,9}
    local index
    for i =1 ,4 do
        for k, v in ipairs(bool) do
            if v then 
                for j = #modeRes[i], 1, -1 do
                    if modeRes[i][j] == k then 
                        table.remove(modeRes[i], j)
                    end
                end
            end
        end 
        index = modeRes[i][math.random(1,#modeRes[i])]
        mode[i] = index
        bool[index] = true
    end
    return mode
end


function BaseUtils.VestChangeMainUIPos(ts)
    if ts == nil then return end
    if BaseUtils.isnull(ts.gameObject) then return end
    local mode = BaseUtils.GetVerifySetting().mode

    if ts.name == "MainUIIconView" then 
        ts.iconPanelRect3.gameObject:SetActive(false)
    end

    if ts.gameObject.name == "ChatMini" then 
        if mode[1] == 6 then 

        elseif mode[1] == 7 then 
            ts.mainRect.anchorMin = Vector2(0.5,0)
            ts.mainRect.anchorMax = Vector2(0.5,0)
            ts.mainRect.anchoredPosition = Vector2(-212,10)
            ts.transform:Find("MainContent/ButtonContainer").anchoredPosition = Vector2(62,0)
        elseif mode[1] == 8 then 
            ts.mainRect.anchorMin = Vector2(1,0)
            ts.mainRect.anchorMax = Vector2(1,0)
            ts.mainRect.anchoredPosition = Vector2(-320,10)
            ts.transform:Find("MainContent/ButtonContainer").anchoredPosition = Vector2(126,0)
        end
    end

    if ts.gameObject.name == "PetInfoView" then 
        if mode[2] == 1 then 
            ts.mainRect.anchorMin = Vector2(0,1)
            ts.mainRect.anchorMax = Vector2(0,1)
            ts.mainRect.anchoredPosition = Vector2(-159,13)
        elseif mode[2] == 3 then 
            ts.mainRect.anchorMin = Vector2(1,1)
            ts.mainRect.anchorMax = Vector2(1,1)
            ts.mainRect.anchoredPosition = Vector2(-289,13)
        end
    end

    if ts.name == "MainUIIconView" then 
        if mode[3] == 3 then 
            ts.iconPanelRect1.anchorMin = Vector2(1,1)
            ts.iconPanelRect1.anchorMax = Vector2(1,1)
            ts.iconPanelRect1.anchoredPosition = Vector2(0,-90)
        elseif mode[3] == 8 then 
            ts.iconPanelRect1.anchorMin = Vector2(1,0)
            ts.iconPanelRect1.anchorMax = Vector2(1,0)
            ts.iconPanelRect1.anchoredPosition = Vector2(0,0)
        elseif mode[3] == 2 then 
            ts.iconPanelRect1.anchorMin = Vector2(0.5,1)
            ts.iconPanelRect1.anchorMax = Vector2(0.5,1)
            ts.iconPanelRect1.anchoredPosition = Vector2(120,-90)
        elseif mode[3] == 7 then 
            ts.iconPanelRect1.anchorMin = Vector2(0.5,0)
            ts.iconPanelRect1.anchorMax = Vector2(0.5,0)
            if mode[1] == 8 then
                ts.iconPanelRect1.anchoredPosition = Vector2(120,0)
            elseif mode[1] == 6 then 
                ts.iconPanelRect1.anchoredPosition = Vector2(213,0)
            end
        end
        
        if mode[4] == 9 then 
            ts.iconPanelRect2.anchorMin = Vector2(0,1)
            ts.iconPanelRect2.anchorMax = Vector2(0,1)
            ts.iconPanelRect2.anchoredPosition = Vector2(0,0)
        elseif mode[4] == 10 then 
            ts.iconPanelRect2.anchorMin = Vector2(1,1)
            ts.iconPanelRect2.anchorMax = Vector2(1,1)
            if mode[3] == 3 then 
                ts.iconPanelRect2.anchoredPosition = Vector2(-78,13)
            else
                ts.iconPanelRect2.anchoredPosition = Vector2(-78,0)
            end
        elseif mode[4] == 11 then 
            ts.iconPanelRect2.anchorMin = Vector2(1,0)
            ts.iconPanelRect2.anchorMax = Vector2(1,0)
            if mode[1] == 8 then 
                ts.iconPanelRect2.anchoredPosition = Vector2(-78,340)
            else
                ts.iconPanelRect2.anchoredPosition = Vector2(-78,215)
            end
        elseif mode[4] == 8 then 
            ts.iconPanelRect2.anchorMin = Vector2(1,0)
            ts.iconPanelRect2.anchorMax = Vector2(1,0)
            ts.iconPanelRect2.anchoredPosition = Vector2(-78,140)
        elseif mode[4] == 6 then 
            ts.iconPanelRect2.anchorMin = Vector2(0,0)
            ts.iconPanelRect2.anchorMax = Vector2(0,0)
            ts.iconPanelRect2.anchoredPosition = Vector2(0,140)
        elseif mode[4] == 2 then 
            ts.iconPanelRect2.anchorMin = Vector2(1,1)
            ts.iconPanelRect2.anchorMax = Vector2(1,1)
            ts.iconPanelRect2.anchoredPosition = Vector2(-360,51)
        end
    end
end

BaseUtils.VestChangeSpriteTable = {
    ["I18NAchievement"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NAgenda"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NArenaButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 2 },
    ["I18NBackpackButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 3 },
    ["I18NBlacksmithsButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 2 },
    ["I18NCombatRec"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NExpText"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NFriendButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NGlory"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NGuardianButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 3 },
    ["I18NGuildButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 3 },
    ["I18NHandbook"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NHandupButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NHelp"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NHomeButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NMarketButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NRanksButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NRewards"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 1 },
    ["I18NRideIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 2 },
    ["I18NSettingsButtonIcon2"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 3 },
    ["I18NShopButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 3 },
    ["I18NSkillButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 3 },
    ["I18NTowerEnd"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 2 },
    ["I18NUpgradeButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 3 },
    ["I18NWelfareButtonIcon"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 3 },
    ["IconSwitcher1"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 2 },
    ["IconSwitcher2"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 2 },
    ["MainUIBarBg"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 2 },
    ["MainUIBarBg1"] = { folder = "VerifyUI/MainUI", slice = false, typeNum = 2 },

    ["TabButton1Normal"] = { folder = "VerifyUI/Base", slice = true, typeNum = 2 },
    ["TabButton1Select"] = { folder = "VerifyUI/Base", slice = true, typeNum = 2 },
    ["TabButton2Normal"] = { folder = "VerifyUI/Base", slice = true, typeNum = 2 },
    ["TabButton2Select"] = { folder = "VerifyUI/Base", slice = true, typeNum = 2 },
    ["TalkBg"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TextBg1"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TextBg2"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TextBg3"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TextBg4"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TextBg5"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TickBg"] = { folder = "VerifyUI/Base", slice = false, typeNum = 1 },
    ["TipsBg1"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["Tipsbg2"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["Tipslabel1"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["Tipslabel2"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["Tipslabel3"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["Tipslabel4"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["titleBg"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TitleBg1"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TitleBg2"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TitleBg3"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TitleBg4"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TitleBg5"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TitleBg6"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["TitleBg7"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ToggleBg"] = { folder = "VerifyUI/Base", slice = false, typeNum = 1 },
    ["ToggleMark"] = { folder = "VerifyUI/Base", slice = false, typeNum = 1 },
    ["WindowBg1"] = { folder = "VerifyUI/Base", slice = true, typeNum = 2 },
    ["WindowBg2"] = { folder = "VerifyUI/Base", slice = true, typeNum = 2 },
    ["WindowBg3"] = { folder = "VerifyUI/Base", slice = true, typeNum = 2 },
    ["WindowBg4"] = { folder = "VerifyUI/Base", slice = true, typeNum = 2 },
    ["WindowBg5"] = { folder = "VerifyUI/Base", slice = true, typeNum = 2 },
    ["WindowsCloseButton"] = { folder = "VerifyUI/Base", slice = false, typeNum = 1 },
    ["WindowsMiniButton"] = { folder = "VerifyUI/Base", slice = false, typeNum = 1 },
    ["WindowTitleBg"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton1"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton10"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton11"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton2"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton3"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton4"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton5"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton6"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton7"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton8"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["DefaultButton9"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["GuideBg"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["HeadBg"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["InfoIconBg1"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["InfoIconBg2"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["Item4"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["Item5"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBackground"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg10"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg11"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg12"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg13"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg14"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg2"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg21"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg22"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg3"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg4"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg5"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg6"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg8"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemBg9"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1 },
    ["ItemDefault"] = { folder = "VerifyUI/Base", slice = true, typeNum = 1},
    ["Assets90002"] = { folder = "VerifyUI/Base", slice = false, typeNum = 1},

    ["ChatBg"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatBg2"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatBg3"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatBg4"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatButton1"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatButton2"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatButton3"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatButton4"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatButton5"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatButton6"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatButton7"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["ChatInputBg1"] = { folder = "VerifyUI/Chat", slice = true, typeNum = 1 },
    ["I18NChatTopBtn1"] = { folder = "VerifyUI/Chat", slice = false, typeNum = 1 },
    ["I18NChatTopBtn2"] = { folder = "VerifyUI/Chat", slice = false, typeNum = 1 },
    ["I18NChatTopBtn3"] = { folder = "VerifyUI/Chat", slice = false, typeNum = 1 },
    ["I18NChatTopBtn4"] = { folder = "VerifyUI/Chat", slice = false, typeNum = 1 },

    ["Excharge1"] = { folder = "VerifyUI/Shop", slice = false, typeNum = 1 },
    ["Excharge2"] = { folder = "VerifyUI/Shop", slice = false, typeNum = 1 },
    ["Excharge3"] = { folder = "VerifyUI/Shop", slice = false, typeNum = 1 },
    ["Excharge4"] = { folder = "VerifyUI/Shop", slice = false, typeNum = 1 },
    ["Excharge5"] = { folder = "VerifyUI/Shop", slice = false, typeNum = 1 },
    ["Excharge6"] = { folder = "VerifyUI/Shop", slice = false, typeNum = 1 },
}

local _borderVector4 = Vector4.one
local _pivot = Vector2(0.5, 0.5)
function BaseUtils.VestChangeSprite(image)
    local spriteName = string.sub(tostring(image.sprite), 1, -22)

    local setting = BaseUtils.VestChangeSpriteTable[spriteName]
    if setting ~= nil then
        -- local typeNum = BaseUtils.GetVerifySetting().windowBgType % setting.typeNum + 1
        local path = string.format("%s/%s", setting.folder, spriteName)
        local tex = Resources.Load(path)
        local t = image.transform
        local pivot = t.pivot
        local anchorMax = t.anchorMax
        local anchorMin = t.anchorMin
        local offsetMin = t.offsetMin
        local offsetMax = t.offsetMax
        local localScale = t.localScale
        local localPosition = t.localPosition
        local anchoredPosition3D = t.anchoredPosition3D
        local border = Vector4.zero
        if setting.slice then
            -- 设置九宫格裁切
            border = _borderVector4 * math.min(tex.width, tex.height) / 3
            image.type = Image.Type.Sliced
        end
        image.sprite = Sprite.Create(tex, Rect(0, 0, tex.width, tex.height), pivot, 1, 0, SpriteMeshType.Tight, border)
        image:SetNativeSize()
        t.pivot = pivot
        t.anchorMax = anchorMax
        t.anchorMin = anchorMin
        t.offsetMin = offsetMin
        t.offsetMax = offsetMax
        t.localScale = localScale
        t.localPosition = localPosition
        t.anchoredPosition3D = anchoredPosition3D

        -- image.color = BaseUtils.GetVerifySetting().windowBgColor
    end
end

BaseUtils.VestMapId = { 10001,10003,10004,10009,10010,10011,20001,20005 }
function BaseUtils.VestMapTexture(path)
    local path = string.gsub (path, "textures/maps/", "VerifyUI/Map/")
    path = string.gsub (path, ".unity3d", "")
    for index, id in ipairs(BaseUtils.VestMapId) do
        path = string.gsub (path, "/"..id.."/", "/"..id.."0/")
    end
    local tex = Resources.Load(path)
    return tex
end

function BaseUtils.VestMiniMapTexture(miniMapId)
    local file = string.format("VerifyUI/Map/%s0/mini", miniMapId)
    local tex = Resources.Load(file)
    return tex
end

BaseUtils.monthlyText1 = "超值月度礼包\n只需30元即可开启尊享特权\n购买后即刻返还300钻\n每天可领取5000金币\n共可领取30天"
BaseUtils.monthlyText2 = "月度福利卡\n只需30元\n开启尊享特权\n购买后立即获得300钻\n连续30天共返还150000金币"
BaseUtils.monthlyText3 = "豪华月度好礼\n花费30元\n即可开启豪华返利\n购买后可获得300钻外\n还可在30天内每日领取5000金币"

BaseUtils.VerifySetting = {
    ["xcqy"] = {windowBgType = 1, windowBgColor = Color(0.5, 0.9, 0.8, 0.9), rechargeType = 1, rechargeItemBg = 1, monthlyText = BaseUtils.monthlyText1},
    ["scbb"] = {windowBgType = 2, windowBgColor = Color(0.2, 0.4, 0.8, 0.9), rechargeType = 2, rechargeItemBg = 2, monthlyText = BaseUtils.monthlyText2},
    ["jlhx"] = {windowBgType = 3, windowBgColor = Color(0.8, 0.4, 0.2, 0.9), rechargeType = 3, rechargeItemBg = 3, monthlyText = BaseUtils.monthlyText3},
    ["mlhx"] = {windowBgType = 4, windowBgColor = Color(0.3, 0.4, 0.2, 0.9), rechargeType = 1, rechargeItemBg = 4, monthlyText = BaseUtils.monthlyText1},
    ["syqy"] = {windowBgType = 1, windowBgColor = Color(0.8, 0.8, 0.2, 0.9), rechargeType = 2, rechargeItemBg = 5, monthlyText = BaseUtils.monthlyText2},
    ["mhqy2"] = {windowBgType = 2, windowBgColor = Color(0.8, 0.4, 0.6, 0.9), rechargeType = 3, rechargeItemBg = 1, monthlyText = BaseUtils.monthlyText3},
    ["jlmx"] = {windowBgType = 3, windowBgColor = Color(0.1, 0.4, 0.2, 0.9), rechargeType = 1, rechargeItemBg = 2, monthlyText = BaseUtils.monthlyText1},
    ["Vest1"] = {windowBgType = 1, windowBgColor = Color(70/255,142/255,148/255,1), rechargeType = 1, rechargeItemBg = 1, monthlyText = BaseUtils.monthlyText2},
    ["Vest2"] = {windowBgType = 2, windowBgColor = Color(80/255,0/255,222/255,1), rechargeType = 2, rechargeItemBg = 2, monthlyText = BaseUtils.monthlyText3},
    ["Vest3"] = {windowBgType = 3, windowBgColor = Color(222/255,0/255,115/255,1), rechargeType = 3, rechargeItemBg = 3, monthlyText = BaseUtils.monthlyText1},
    ["Vest4"] = {windowBgType = 4, windowBgColor = Color(222/255,0/255,0/255,1), rechargeType = 1, rechargeItemBg = 4, monthlyText = BaseUtils.monthlyText2},
    ["Vest5"] = {windowBgType = 1, windowBgColor = Color(222/255,83/255,0/255,1), rechargeType = 2, rechargeItemBg = 5, monthlyText = BaseUtils.monthlyText3},
    ["Vest6"] = {windowBgType = 2, windowBgColor = Color(222/255,189/255,0/255,1), rechargeType = 3, rechargeItemBg = 1, monthlyText = BaseUtils.monthlyText1},
    ["Vest7"] = {windowBgType = 3, windowBgColor = Color(201/255,222/255,0/255,1), rechargeType = 1, rechargeItemBg = 2, monthlyText = BaseUtils.monthlyText2},
    ["Vest8"] = {windowBgType = 4, windowBgColor = Color(109/255,222/255,0/255,1), rechargeType = 2, rechargeItemBg = 3, monthlyText = BaseUtils.monthlyText3},
    ["Vest9"] = {windowBgType = 1, windowBgColor = Color(35/255,222/255,0/255,1), rechargeType = 3, rechargeItemBg = 4, monthlyText = BaseUtils.monthlyText1},
    ["Vest10"] = {windowBgType = 2, windowBgColor = Color(0/255,114/255,255/255,1), rechargeType = 1, rechargeItemBg = 5, monthlyText = BaseUtils.monthlyText2},
    ["Vest11"] = {windowBgType = 3, windowBgColor = Color(157/255,0/255,151/255,1), rechargeType = 2, rechargeItemBg = 1, monthlyText = BaseUtils.monthlyText3},
    ["Vest12"] = {windowBgType = 4, windowBgColor = Color(157/255,0/255,0/255,1), rechargeType = 3, rechargeItemBg = 2, monthlyText = BaseUtils.monthlyText1},
    ["Vest13"] = {windowBgType = 1, windowBgColor = Color(157/255,0/255,255/255,1), rechargeType = 1, rechargeItemBg = 3, monthlyText = BaseUtils.monthlyText2},
    ["Vest14"] = {windowBgType = 2, windowBgColor = Color(255/255,0/255,255/255,1), rechargeType = 2, rechargeItemBg = 4, monthlyText = BaseUtils.monthlyText3},
    ["Vest15"] = {windowBgType = 3, windowBgColor = Color(90/255,37/255,24/255,1), rechargeType = 3, rechargeItemBg = 5, monthlyText = BaseUtils.monthlyText1},
    ["Vest16"] = {windowBgType = 4, windowBgColor = Color(1/255,65/255,203/255,1), rechargeType = 1, rechargeItemBg = 1, monthlyText = BaseUtils.monthlyText2},
    ["Vest17"] = {windowBgType = 1, windowBgColor = Color(64/255,43/255,38/255,1), rechargeType = 2, rechargeItemBg = 2, monthlyText = BaseUtils.monthlyText3},
    ["Vest18"] = {windowBgType = 2, windowBgColor = Color(71/255,17/255,3/255,1), rechargeType = 3, rechargeItemBg = 3, monthlyText = BaseUtils.monthlyText1},
    ["Vest19"] = {windowBgType = 3, windowBgColor = Color(62/255,50/255,79/255,1), rechargeType = 1, rechargeItemBg = 4, monthlyText = BaseUtils.monthlyText2},
    ["Vest20"] = {windowBgType = 4, windowBgColor = Color(31/255,14/255,56/255,1), rechargeType = 2, rechargeItemBg = 5, monthlyText = BaseUtils.monthlyText3},
    ["Vest21"] = {windowBgType = 1, windowBgColor = Color(255/255,144/255,248/255,1), rechargeType = 1, rechargeItemBg = 1, monthlyText = BaseUtils.monthlyText1},
    ["Vest22"] = {windowBgType = 2, windowBgColor = Color(148/255,99/255,145/255,1), rechargeType = 2, rechargeItemBg = 2, monthlyText = BaseUtils.monthlyText2},
    ["Vest23"] = {windowBgType = 3, windowBgColor = Color(255/255,107/255,107/255,1), rechargeType = 3, rechargeItemBg = 3, monthlyText = BaseUtils.monthlyText3},
    ["Vest24"] = {windowBgType = 4, windowBgColor = Color(75/255,7/255,7/255,1), rechargeType = 1, rechargeItemBg = 4, monthlyText = BaseUtils.monthlyText1},
    ["Vest25"] = {windowBgType = 1, windowBgColor = Color(255/255,21/255,21/255,1), rechargeType = 2, rechargeItemBg = 5, monthlyText = BaseUtils.monthlyText2},
    ["Vest26"] = {windowBgType = 2, windowBgColor = Color(255/255,255/255,0/255,1), rechargeType = 3, rechargeItemBg = 1, monthlyText = BaseUtils.monthlyText3},
    ["Vest27"] = {windowBgType = 3, windowBgColor = Color(58/255,148/255,58/255,1), rechargeType = 1, rechargeItemBg = 2, monthlyText = BaseUtils.monthlyText1},
    ["Vest28"] = {windowBgType = 4, windowBgColor = Color(148/255,58/255,58/255,1), rechargeType = 2, rechargeItemBg = 3, monthlyText = BaseUtils.monthlyText2},
    ["Vest29"] = {windowBgType = 1, windowBgColor = Color(148/255,70/255,110/255,1), rechargeType = 3, rechargeItemBg = 4, monthlyText = BaseUtils.monthlyText3},
    ["Vest30"] = {windowBgType = 2, windowBgColor = Color(108/255,70/255,148/255,1), rechargeType = 1, rechargeItemBg = 5, monthlyText = BaseUtils.monthlyText1},
}

-- 获取审核配置
function BaseUtils.GetVerifySetting()
    local name = BaseUtils.GetGameName()
    local verifySetting = BaseUtils.VerifySetting[name]
    if verifySetting == nil then -- 按照游戏名匹配颜色
        local list = StringHelper.Split(name, "_")
        verifySetting = BaseUtils.VerifySetting[list[#list]]

        if verifySetting == nil then
            verifySetting = BaseUtils.VerifySetting["xcqy"]
        end
    end
    if verifySetting.mode == nil then 
        verifySetting.mode = BaseUtils.GetVestMainUIPosSettingMode()
    end
    return verifySetting
end

--渠道包下载二维码图片地址URL
function BaseUtils.ChannelBagDownLoadQRCodeURl()
    local date_time = os.time()
    local source_str = KvData.product_name..date_time..KvData.secret_key
    local sign = Utils.MD52Php(source_str)

    local _url = string.format("%s?product_name=%s&date_time=%s&sign=%s&channel_name=%s", KvData.channelBagDownLoadUrl, BaseUtils.LogUrlEncode(KvData.product_name), BaseUtils.LogUrlEncode(date_time), BaseUtils.LogUrlEncode(sign), BaseUtils.LogUrlEncode(ctx.PlatformChanleId))

    -- print(_url)
    local callback = function(result)
        -- BaseUtils.dump(result)
        local tmp = string.gsub(result,"true","\"true\"")
        local resultData =  NormalJson(tmp)
        if resultData ~= nil and resultData.table ~= nil then
            if resultData.table.success == "true" then
                BibleManager.Instance.model.qrCodeData = BaseUtils.copytab(resultData.table)
            end
        end
    end

    ctx:GetRemoteTxt(_url,callback,3)
end

--粒子大小跟随特效大小
function BaseUtils.TposeEffectScale(teffect, _scale)
    if teffect == nil or teffect.transform == nil then return end
    local scale =  teffect.transform.localScale.x / 144
    local particleSystemList = teffect.transform:GetComponentsInChildren(ParticleSystem, true)
    for i=1, #particleSystemList do
        local particleSystem = particleSystemList[i]
        if _scale ~= nil then 
            particleSystem.startSize = _scale
        else
            particleSystem.startSize = particleSystem.startSize * scale
        end
    end
end

function BaseUtils.RaycastHitToGameObject(raycastHits)
    return Utils.RaycastHitToGameObject(raycastHits)
end

--替换商城金币银币的描述显示
function BaseUtils.ReplacePattern(baseData)
    local model_id = nil
    local ddesc = baseData.desc
    if next(baseData.effect) ~= nil then
        local effectType = baseData.effect[1].effect_type
        if effectType == 77 then
            model_id = baseData.effect[1].val[1]
        end
    end
    if model_id ~= nil then
        
        local lev = RoleManager.Instance.RoleData.lev
        local num = DataItem.data_get_model[model_id.."_"..lev].num
        ddesc = string.gsub(baseData.desc, "%[coin_num%]", num)
    end
    return ddesc
end

--替换雕文的描述显示
function BaseUtils.ReplaceGlyphsPattern(baseData)
    local glyphs_id = nil
    local glyphs_lev = nil
    local total_min = {}
    local total_max = {}
    local ddesc = baseData.desc
    if next(baseData.effect_client) ~= nil then
        local effectType = baseData.effect_client[1].effect_type_client
        if effectType == BackpackEumn.ItemUseClient.glyphs_effect then
            glyphs_id = baseData.effect_client[1].val_client[1]
            glyphs_lev = baseData.effect_client[1].val_client[2]
        end
    end
    if glyphs_id ~= nil and glyphs_lev ~= nil then
        local lev = RoleManager.Instance.RoleData.lev
        local custom_lev = math.floor(lev/10) * 10
        local start_index, end_index = string.find(ddesc,"%[buff%]", 1)
        local beforeStr = string.sub(ddesc, 1, start_index - 1)
        local afterStr = string.sub(ddesc, end_index + 1, string.len(ddesc))
        if glyphs_lev > custom_lev then
            --雕文等级大于自身等级
            local buff_data = DataBuff.data_list[glyphs_id]
            local buff_attr = {}  --属性名
            for i = 1,#buff_data.dynamic_attr do
                buff_attr[i] = buff_data.dynamic_attr[i].attr_type
            end
            local curr_data_class = buff_data.class --类别

            local curr_min_prop = {} --当前雕文最小属性表
            local curr_max_prop = {} --当前雕文最大属性表
            curr_min_prop, curr_max_prop = BaseUtils.GetGlyphsProp(glyphs_id)
            local lev_buff_id = nil   --自身等级对应的该类型的buffid
            local get_glyph_data = DataBuff.data_get_glyph[curr_data_class.."_"..custom_lev]
            if get_glyph_data ~= nil then
                lev_buff_id = get_glyph_data.buffid
            end
            local curr_min_prop_2 = {} --等级雕文最小属性表
            local curr_max_prop_2 = {} --等级雕文最大属性表
            curr_min_prop_2, curr_max_prop_2 = BaseUtils.GetGlyphsProp(lev_buff_id)
            for j = 1,#curr_min_prop_2 do
                total_min[j] = math.min(curr_min_prop[j],curr_max_prop_2[j])
                total_max[j] = curr_max_prop_2[j]
            end
            if #total_min > 1 then
                ddesc = beforeStr..string.format("\n<color='#ffff00'>等级效果：</color>雕文超出人物等级，实际效果%s增加<color='#ffff00'>%s，</color>%s增加<color='#ffff00'>%s</color>", KvData.attr_name[buff_attr[1]], total_min[1].."~"..total_max[1], KvData.attr_name[buff_attr[2]], total_min[2].."~"..total_max[2])..afterStr
            else
                ddesc = beforeStr..string.format("\n<color='#ffff00'>等级效果：</color>雕文超出人物等级，实际效果%s增加<color='#ffff00'>%s</color>", KvData.attr_name[buff_attr[1]], total_min[1].."~"..total_max[1])..afterStr
            end
            --%[glyph_num1%]  %[glyph_num2%]
        else
            ddesc = beforeStr..afterStr
        end
    end
    return ddesc
end

function BaseUtils.GetGlyphsProp(buff_id)
    local buff_data = DataBuff.data_list[buff_id]
    local buff_dynamic_data = DataBuff.data_get_dynamic_attr[buff_id]
    local curr_min_prop = {} --当前雕文最小属性表
    local curr_max_prop = {} --当前雕文最大属性表
    if buff_data ~= nil and buff_dynamic_data ~= nil then
        local base_prop = {}
        local extra_prop = {}
        local curr_min = 0
        local curr_max = 0
        for i = 1,#buff_data.dynamic_attr do
            base_prop[i] = buff_data.dynamic_attr[i].val
        end

        local odds = buff_dynamic_data.odds
        if odds ~= nil then
            curr_min = odds[1][1]
            curr_max = odds[#odds][1]
        end
        for i = 1,#buff_data.dynamic_attr do
            curr_min_prop[i] = math.floor(base_prop[i] * curr_min/100 + 0.5)
            curr_max_prop[i] = math.floor(base_prop[i] * curr_max/100 + 0.5)
        end
    end
    return curr_min_prop,curr_max_prop
end

--item_list要有gameObject、effect属性
--item的pivot.x为0,
--item.effectflag
function BaseUtils.DealExtraEffect(scrollRect,item_list,setting)
    setting = setting or {}
    local axis = setting.axis or BoxLayoutAxis.X    --轴
    local delta1 = setting.delta1 or 0              --左方（上方）偏移量
    local delta2 = setting.delta2 or 0              --右方（下方）偏移量

    local __xy =  (axis == BoxLayoutAxis.X) and "x" or "y"
    local container = scrollRect.content

    local a_side = -container.anchoredPosition[__xy]                
    local b_side = a_side + scrollRect.transform.sizeDelta[__xy]    

    local flag                                      --用来标记特效是否真正显示（物品刷新，特效不为空，但实际不需要特效）
    local a_xy,s_xy = 0,0
    for k,v in pairs(item_list) do
        a_xy = v.gameObject.transform.anchoredPosition[__xy] + delta1
        s_xy = v.gameObject.transform.sizeDelta[__xy] - delta1 - delta2
        flag = v.effectflag
        if flag == nil  then flag = true end
        if v.effect ~= nil and flag then 
            v.effect:SetActive(a_xy > a_side and a_xy + s_xy < b_side)
        end
    end
end

--钻石数对应Rmb数
function BaseUtils.DiamondToRmb(diamond_num)
    return diamond_num / 10 
end

BaseUtils.IS_CUSTOMKEYBOARD = nil -- 自定义键盘标记
-- 检查设备型号，判断是否是否使用自定义键盘
function BaseUtils.CustomKeyboard()
    if BaseUtils.IS_CUSTOMKEYBOARD ~= nil then -- 检测过，有值就直接返回
        return BaseUtils.IS_CUSTOMKEYBOARD
    end

    if Application.platform == RuntimePlatform.IPhonePlayer then
        BaseUtils.IS_CUSTOMKEYBOARD = false
    elseif Application.platform == RuntimePlatform.Android then
        -- if BaseUtils.GetClientVerion() >= "1.7.2" and BaseUtils.GetClientVerion() ~= "9.9.9" then
        --     local dType = string.lower(ctx:GetDeviceType())
        --     if string.match(dType, "oppo") ~= nil
        --         or string.match(dType, "vivo") ~= nil
        --         or string.match(dType, "mi") ~= nil
        --         or string.match(dType, "xiaomi") ~= nil
        --     then
        --         BaseUtils.IS_CUSTOMKEYBOARD = false
        --     end
        -- else
        --     BaseUtils.IS_CUSTOMKEYBOARD = true
        -- end
        BaseUtils.IS_CUSTOMKEYBOARD = false
    end

    if BaseUtils.IS_CUSTOMKEYBOARD then
        return true
    else
        return false
    end
end