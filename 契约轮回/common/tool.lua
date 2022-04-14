-- 
-- @Author: LaoY
-- @Date:   2018-08-02 21:24:26
-- 项目&unity常用或统一的方法,比如战力公式等

local math = math
local math_acos = math.acos
local max = math.max
local math_sin = math.sin
local math_cos = math.cos
local math_sqrt = math.sqrt
local math_abs = math.abs

local function concat(...)
    local param = { ... }
    if #param == 0 then
        return ""
    elseif #param == 1 then
        return tostring(param[1])
    else
        local t = {}
        for i,v in ipairs(param) do
            t[i] = tostring(v)
        end
        return table.concat(t," ")
    end 
end

--输出日志--
function log(...)
    if AppConfig.printLog then
        local str = concat(...)
        Util.Log(str);
    end
end

--错误日志--
function logError(...) 
    --traceback()
    local t = string.split(debug.traceback(), "\n")
    table.remove(t, 2)
    -- print(table.concat(t, "\n"))
    local str = concat(...)
	Util.LogError(str .. "\n" .. table.concat(t, "\n"));
end

--警告日志--
function logWarn(...) 
    if AppConfig.printLog then
        local str = concat(...)
    	Util.LogWarning(str);
    end
end

function DebugLog(...)
    local str = concat(...)
    Util.LogWarning(str)
end

--查找对象--
function find(str)
	return GameObject.Find(str);
end

--Destroy是异步销毁，一般在下一帧就销毁了，不会影响主线程的运行。
function destroy(obj)
    if obj then
        GameObject.Destroy(obj);
    end
end

--DestroyImmediate是立即销毁，立即释放资源，做这个操作的时候，会消耗很多时间的，影响主线程运行 
function destroyImmediate(obj)
    if obj then
    	GameObject.DestroyImmediate(obj)
    end
end

function newObject(prefab)
    if not prefab then
        return nil
    end
	return GameObject.Instantiate(prefab);
end

--判断C#对象是否已经被销毁
-- http://doc.ulua.org/article/faq/ulualimianzenmepanduanunityduixiangweikong.html
function IsNil(uobj)
    return uobj == nil or uobj:Equals(nil)
end

function IsGameObjectNull(uobj)
    return uobj == nil or tostring(uobj) == "null";
end

--屏幕坐标转设计坐标
function ScreenToViewportPosition(x,y)
    return x / g_standardScale, y / g_standardScale
end

--设计坐标转换屏幕坐标
function ViewportToScreenPosition(x,y)
    return x * g_standardScale, y * g_standardScale
end

--[[
    @author LaoY
    @des    是否在弧度内 距离不判断
    @param1 start_radian  其实弧度，朝向
    @param2 radian  弧度范围
    @param3 vec     向量
--]]
function IsInRadian(start_radian,radian,vec)
    if radian <= 0 then
        return false
    end
    if radian >= 360 or (vec.x == 0 and vec.y == 0) then
        return true
    end
    if start_radian < 0 then
        start_radian = ((start_radian%360) + 360)%360
    end
    local l_radian = start_radian - radian/2
    local r_radian = start_radian + radian/2
    -- 0 - 360
    local v_radian = GetAngeleByVector(vec)
    v_radian = v_radian%360
    if l_radian * r_radian < 0 then
        l_radian = l_radian + 360
        return v_radian > l_radian or v_radian < r_radian
    elseif r_radian == 0 then
        r_radian = r_radian + 360
    end
    return l_radian <= v_radian and v_radian <= r_radian
end

function GetSceneObjectRotateXZ(rotateY)
    local rate = 30
    rotateY = math.getAngle(rotateY)
    local rotateX = rotateY > 0 and rotateY/180 * rate*2-rate or -rotateY/180 * rate*2-rate
    local rotateZ = math.getAngle(rotateY - 90)
    rotateZ = rotateZ > 0 and rotateZ/180 * rate*2-rate or -rotateZ/180 * rate*2-rate
    return rotateX,rotateZ
end

function GetVector(start_pos,end_pos)
    start_pos = start_pos or {x=0,y=0}
    end_pos = end_pos or {x=0,y=0}
    return Vector2(end_pos.x - start_pos.x,end_pos.y - start_pos.y)
end

function GetAngleByPosition(start_pos,end_pos)
    return GetAngeleByVector(GetVector(start_pos,end_pos))
end

function GetAngeleByVector(to,from)
    local x,y = 0,0
    if from then
        x = to.x - from.x
        y = to.y - from.y
    else
        x = to.x
        y = to.y
    end

    local hypotenuse = math_sqrt(x*x+y*y)
    if hypotenuse == 0 then
        return 0
    end
    local cos = x / hypotenuse
    local radian = math_acos(cos)
    if radian == 0 then
        return 90
    end
    local angle = math.radian2angle(radian)
    if y < 0 then
        angle = 360 - angle
    end
    angle = 360 + 90 - angle
    angle = angle%360
    return math.round(angle)
end

function GetVectorByAngle(angle,vec)
    local radian = math.angle2radian(angle)
    if not vec then
        vec = Vector2(0,0)
    end
    vec.x = math_sin(radian)
    vec.y = math_cos(radian)
    vec:SetNormalize()
    return vec
end

function GetSceneAngle(from,to)
    local vec = {x = to.x - from.x,y = to.y - from.y}
    local angle = Vector2.GetAngle(vec)
    -- do
    --     if vec.y > 0 and vec.x > 0 then
    --     --第二象限
    --    elseif vec.y > 0 and vec.x < 0 then
    --     --第三象限
    --     elseif vec.y < 0 and vec.x < 0 then
    --     --第四象限
    --      elseif vec.y < 0 and vec.x > 0 then
    --     end
    --     return angle
    -- end
    local vec = GetVectorByAngle(angle)
    local rate
    if vec.x == 0 or vec.y == 0 then
        return angle
    end
    local abs_x = math_abs(vec.x)
    local abs_y = math_abs(vec.y)
    if abs_x > abs_y then
        rate = vec.y/vec.x
    else
        rate = vec.x/vec.y
    end
    rate = math_abs(rate)
    -- rate = rate * rate * rate

    local offset = 0
    local str = ""
    --第一象限
    if vec.y > 0 and vec.x > 0 then
        -- rate = -rate/2
        str = "No.Monday象限"
        if abs_x > abs_y then
            local t = abs_x/abs_y
            if t > 1000 then
                offset = -0.4
            elseif t > 6 then
                offset = -0.9
            elseif t > 4 then
                offset = -0.8
            elseif t > 2 then
                offset = -0.8
            else
                offset = -0.4
            end
            str = string.format("No.Monday象限,x:%02f,rate=%02f,%02f",t,rate,offset)
        else
            local t = abs_y/abs_x
            if t > 6 then
                offset = 0.35
            elseif t > 4 then
                offset = rate*1.2
                -- if offset <=  
            elseif t > 3 then
                offset = rate*0.3
            elseif t > 1.5 then
                offset = 0.1
            else
                -- offset = rate * rate * rate
                offset = -0.2
            end
            str = string.format("No.Monday象限,y:%02f,rate=%02f,%02f",abs_y/abs_x,rate,offset)
        end

    --第二象限
   elseif vec.y > 0 and vec.x < 0 then
        str = "No.Tuesday象限"
        if abs_x > abs_y then
            local t = abs_x/abs_y
            if t > 1000 then
                offset = 0.4
            elseif t > 6 then
                offset = -0.1
            elseif t > 4 then
                offset = 0.6
            elseif t > 2 then
                offset = 0.8
            else
                offset = 0.8
            end
            str = string.format("No.Tuesday象限,x:%02f,rate=%02f,%02f",t,rate,offset)
        else
            local t = abs_y/abs_x
            if t > 6 then
                offset = 0.5
            elseif t > 4 then
                offset = rate*1.5
                -- if offset <=  
            elseif t > 3 then
                offset = rate*1.8
            elseif t > 1.5 then
                offset = 0.8
            else
                -- offset = rate * rate * rate
                offset = 0.8
            end
            str = string.format("No.Tuesday象限,y:%02f,rate=%02f,%02f",abs_y/abs_x,rate,offset)
        end

    --第三象限
    elseif vec.y < 0 and vec.x < 0 then
        str = "No.Wednesday象限"
        if abs_x > abs_y then
            local t = abs_x/abs_y
            if t > 1000 then
                offset = -0.4
            elseif t > 6 then
                offset = -0.9
            elseif t > 4 then
                offset = -0.8
            elseif t > 2 then
                offset = -0.8
            else
                offset = -0.5
            end
            str = string.format("No.Wednesday象限,x:%02f,rate=%02f,%02f",t,rate,offset)
        else
            local t = abs_y/abs_x
            if t > 6 then
                offset = 0.5
            elseif t > 4 then
                offset = rate*1.5
                -- if offset <=  
            elseif t > 1.5 then
                offset = 0
            else
                -- offset = rate * rate * rate
                offset = -0.33
            end
            str = string.format("No.Wednesday象限,y:%02f,rate=%02f,%02f",abs_y/abs_x,rate,offset)
        end
        -- rate = 0
    --第四象限
     elseif vec.y < 0 and vec.x > 0 then
        -- rate = -rate/2
        str = "No.Thursday象限"

        if abs_x > abs_y then
            local t = abs_x/abs_y
            if t > 6 then
                offset = 0.5
            elseif t > 4 then
                offset = 0.7
                -- if offset <=  
            elseif t > 1.5 then
                offset = rate * 1.3
            else
                offset = 0.6
            end
            str = string.format("No.Thursday象限,x:%02f,rate=%02f,%02f",t,rate,offset)
        else
            local t = abs_y/abs_x
            if t > 1000 then
                offset = 0.4
            elseif t > 6 then
                offset = 0.6
            elseif t > 4 then
                offset = 0.8
            elseif t > 2 then
                offset = 0.8
            else
                offset = 0.6
            end
            str = string.format("No.Thursday象限,y:%02f,rate=%02f,%02f",abs_y/abs_x,rate,offset)
        end
    end
    -- angle = angle + offset * 30
    return angle
end

--[[
    @author LaoY
    @des    获取某个方向距离为distance的点
    @param1 start_pos
    @param2 end_pos
    @param3 distance
    @param4 error_dis 误差，ps：两点实际距离10，误差1。只要计算出10-1的距离即可
    @return table
--]]
function GetDirDistancePostion(start_pos,end_pos,distance,error_dis)
    if not distance and not error_dis then
        return end_pos
    end
    if error_dis and not distance then
        distance = math.max(0,Vector2.Distance(start_pos,end_pos) - error_dis)
    end
    local vec = GetVector(start_pos,end_pos)
    vec:SetNormalize()
    if vec.x==0 and vec.y == 0 then
        vec.x = 1
        vec.y = 0
    end
    vec:Mul(distance)
    return {x = start_pos.x + vec.x,y = start_pos.y + vec.y}
end

function GetDirByVector(start_pos,end_pos)
    local vec = GetVector(start_pos,end_pos)
    vec:SetNormalize()
    return vec    
end

--设置材质贴图
function SetMaterialTexture(material, texture)
    if material:HasProperty("_MainTex") then
        material:SetTexture("_MainTex", texture)
    elseif material:HasProperty("_AmitTex") then
        material:SetTexture("_AmitTex", texture)
    end
end

--获取材质贴图
function GetMaterialTexture(material)
    local texture
    if material:HasProperty("_MainTex") then
        texture = material:GetTexture("_MainTex")
    elseif material:HasProperty("_AmitTex") then
        texture = material:GetTexture("_AmitTex")
    end
    return texture
end

AlignType = {
    Null = BitState.State[0],
    Left = BitState.State[1],
    Right = BitState.State[2],
    Top = BitState.State[3],
    Bottom = BitState.State[4],
}
function SetAlignType(transform,align,start_size)
    local x
    local y
    local l_x,l_y
    if isClass(transform) then
        l_x,l_y = transform:GetPosition()
    else
        l_x,l_y = GetLocalPosition(transform)
    end
    x = l_x
    y = l_y
    local w = start_size and start_size.x or DesignResolutionWidth
    local h = start_size and start_size.y or DesignResolutionHeight

    if BitState.StaticContain(align,AlignType.Left) then
        if g_is_standardscale_h then
            x = x or 0
            x = x + (w - ScreenWidth)/2
        end
    end
    if BitState.StaticContain(align,AlignType.Right) then
        if g_is_standardscale_h then
            x = x or 0
            x = x + (ScreenWidth - w)/2
        end
    end
    
    if BitState.StaticContain(align,AlignType.Bottom) then
        if not g_is_standardscale_h then
            y = y or 0
            y = y + (h - ScreenHeight)/2
        end
    end

    if BitState.StaticContain(align,AlignType.Top) then
        if not g_is_standardscale_h then
            y = y or 0
            y = y + (ScreenHeight - h)/2
        end
    end

    x = x or l_x
    y = y or l_y
    if isClass(transform) then
        transform:SetPosition(x,y)
    else
        SetLocalPositionX(transform,x)
        SetLocalPositionY(transform,y)
    end
    -- Yzprint('--LaoY tool.lua,line 213-- x,y=',align,g_is_standardscale_h,x,y,w,h,g_standardScale,ScreenWidth,ScreenHeight)
end

function GetVerticlePoint(p1, p2, pp, l)
    local dir = Vector2((p1.y-p2.y)/(p2.x-p1.x), 1)
    dir:SetNormalize()

    local p3 = p1 * (1-pp) + p2 * pp
    p3 = p3 + dir * l
    return p3
end

-- 开了也没啥用，还浪费运算量
local is_avoid_shake = false
local type = type
function Smooth(from, to, speed, smoothTime, timeDelta)
    local fromType = type(from)
    if fromType == "table" then
        return Vector2.SmoothDamp(from,to,speed,smoothTime,nil,timeDelta)
    end
    local rate = 2.0 / smoothTime
    local x = rate * timeDelta
    local exp = 1.0 / (1.0 + x + 0.48*x*x + 0.235*x*x*x)
    local change = from - to
    local old_dis
    if is_avoid_shake then
        if fromType == "table" then
            old_dis = Vector2.DistanceNotSqrt(from,to)
        else
            old_dis = math_abs(change)
        end
    end
    local temp = (speed + change * rate) * timeDelta
    local new_speed = (speed - temp * rate) * exp
    local new_pos = to + (change + temp) * exp
    local new_dis
    if is_avoid_shake then
        if fromType == "table" then
            new_dis = Vector2.DistanceNotSqrt(from,new_pos)
        else
            new_dis = math_abs(from-new_pos)
        end
    end
    if is_avoid_shake and new_dis > old_dis then
        return to,new_speed
    end
    -- if (to - from > 0) == (new_pos - to > 0) then
    --     new_pos = to
    --     new_speed = (new_pos - to)/timeDelta
    -- end
    return new_pos, new_speed
end

function GetTurnTableAngle(index,len)
    local rotate = 360/len
    local p = (-rotate * (index - 1))
    return p
end

function GetTurnTablePos(index,len,radius)
    local p = -GetTurnTableAngle(index,len)
    local rad = math.rad(p)
    local cos = math.cos(rad)
    local sin = math.sin(rad)
    return sin*radius,cos * radius
end

function ResourceName(res_str)
    local image_res = string.split(res_str, ":")
    local abName = image_res[1] and image_res[1] .. "_image"
    local assetName = image_res[2]
    return abName,assetName
end

-- 通用物品排序方法 {item_id,item_num}
-- id bu yi yang
function SortGoodsFunc1(tab1,tab2)
    local goods_id_1 = tab1[1]
    local goods_id_2 = tab2[1]
    local cf1 = Config.db_item[goods_id_1]
    local cf2 = Config.db_item[goods_id_2]
    if AppConfig.Debug then
        if not cf1 then
            logError("goods not exists config,the id :",goods_id_1)
        end
        if not cf2 then
            logError("goods not exists config,the id :",goods_id_2)
        end
    end
    local color1 = cf1.color
    local color2 = cf2.color
    if color1 == color2 then
        return goods_id_1 > goods_id_2
    else
        return color1 > color2
    end
end

--[[
    @author LaoY
    @des    map<item_id,item_num> 展开成 {{item_id,item_num}}
    @param1 map
    @param2 is_check_lap 选填，是否根据配置表堆叠数量分开
    @param3 sort_func 可以是function或者true 为true时默认用 SortGoodsFunc1
    @return table 数组
--]]
function Stack2List(map,is_check_lap,sort_func)
    local list = {}
    if is_check_lap then
        local _sort_list = Stack2List(map,false,sort_func)
        local len = #_sort_list
        for i=1,len do
            local info = _sort_list[i]
            local item_id,item_num = info[1],info[2]
            local cf = Config.db_item[item_id]
            local num = item_num
            if cf and  cf.lap > 0 and num > cf.lap then
                while(true)do
                    if num >= cf.lap then
                        list[#list+1] = {item_id,cf.lap}
                        num = num - cf.lap
                    else
                        list[#list+1] = {item_id,num}
                        num = 0
                    end
                    if num <= 0 then
                        break
                    end
                end
            else
                list[#list+1] = {item_id,item_num}
            end
        end
    else
        for item_id,item_num in table.pairsByKey(map) do
            list[#list+1] = {item_id,item_num}
        end
        if sort_func then
            if type(sort_func) ~= "function" then
                sort_func = SortGoodsFunc1
            end
            table.sort(list,sort_func)
        end
    end
    return list
end

function pos(x,y)
    return {x = x,y = y}
end

function GetSpeedRate(dir)
    return ChangeEllipseValue(dir, 1, 0.7, 1)
end

function ChangeEllipseValue(dir, value, ratio, type)
    if dir then
        ratio = ratio or 0.5
        local radian = 0
        if dir.x == 0 then
            if dir.y > 0 then
                radian = 90 / 180 * math.pi
            elseif dir.y == 0 then
                radian = 0
            elseif dir.y < 0 then
                radian = -270 / 180 * math.pi
            end
        else
            radian = math.atan(dir.y / dir.x) --先计算夹角
        end

        local func = nil
        if type == nil or type == 1 then --1为x方向较长  2 为y方向较长的椭圆
            func = math.cos
        else
            func = math.sin
        end

        --椭圆处理
        return value * ratio + math.abs(func(radian)) * value * (1 - ratio)
    else
        return value
    end
end