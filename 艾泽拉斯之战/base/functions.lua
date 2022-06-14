--wz


------ 基础函数库-------------------
-- 发布时打开这个定义，屏蔽掉debug log
--function print() end

--转化为数字。    如果无法转化返回0 ， tonumber()是lua
--内置函数，但无法转化时返回nil。
function tonum(v, base)
    return tonumber(v, base) or 0
end

--转化为int。   math.round 将值舍入至最接近的整数

function toint(v)
    return math.round(tonum(v))
end

---转化为bool
function tobool(v)
    return (v ~= nil and v ~= false)
end

function stringToBool(v)
	
	if v == "false" or v == "FALSE" or v == "False" then
		return false;
	elseif v == "true" or v == "TRUE" or v == "True" then
		return true;
	end
	
	return nil;
end

--转化为table。 如果不是table类型，返回空表
function totable(v)
    if type(v) ~= "table" then v = {} end
    return v
end

-- 检查key 是否是arr的元素。
function isset(arr, key)
    local t = type(arr)
    return (t == "table" or t == "userdata") and arr[key] ~= nil
end

-- 判定obj是否是 className类的后代
function iskindof(obj, className)
    local t = type(obj)

    if t == "table" then
        local mt = getmetatable(obj)
        while mt and mt.__index do
            if mt.__index.__cname == className then
                return true
            end
            mt = mt.super
        end
        return false

    elseif t == "userdata" then

    else
        return false
    end
end	

-- 将lua对象及方法包装为一个匿名函数， 方便调用。因为c++无法识别lua对象方法，因此需要适配
function handler(target, method)
    return function(...)
        return method(target, ...)
    end
end
-- 四舍5入
function math.round(num)
    return math.floor(num + 0.5)
end

fio = {};
-- flag 
-- 0 read 
-- 1 write
function fio.open(filename, flag)
	return GameClient.FileOperationSystem:Instance():open(filename, flag);
end

function fio.close(handle)
	GameClient.FileOperationSystem:Instance():close(handle);
end

function fio.write(handle, data)
	GameClient.FileOperationSystem:Instance():write(handle, data);
end

function fio.writeKeyValue(handle, key, value)
	GameClient.FileOperationSystem:Instance():writeKeyValue(handle, key, value);
end

function fio.readKeyValue(handle, key)
	return GameClient.FileOperationSystem:Instance():readKeyValue(handle, key);
end

function fio.readall(handle)
	return GameClient.FileOperationSystem:Instance():readall(handle);
end

function fio.readIni(section, key, default_value, file)
	file = file or "config.cfg";
	return GameClient.FileOperationSystem:Instance():readIni(section, key, default_value, file);
end

function fio.writeIni(section, key, value, file)
	file = file or "config.cfg";
	GameClient.FileOperationSystem:Instance():writeIni(section, key, value, file);
end

-- 测试文件是否存在。 true表示存在
function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end
-- 读取文件内容
function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end
-- 写入文件 成功返回true
function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end
-- 拆分一个路径符串，返回各个部分。  
function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end
--返回文件的大小。失败返回false
function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end

-- 返回表格的字段数量 #虽然可以，但是仅限于从1开始连续数字为索引的表格
function table.nums(t)
    local count = 0
    for k, v in pairs(t) do
        count = count + 1
    end
    return count
end
-- 返回表格所以的key
function table.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end
-- 返回表格所有的value
function table.values(t)
    local values = {}
    for k, v in pairs(t) do
        values[#values + 1] = v
    end
    return values
end

-- 合并表格
function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

--[[--

insert list.

**Usage:**

    local dest = {1, 2, 3}
    local src  = {4, 5, 6}
    table.insertTo(dest, src)
    -- dest = {1, 2, 3, 4, 5, 6}
    dest = {1, 2, 3}
    table.insertTo(dest, src, 5)
    -- dest = {1, 2, 3, nil, 4, 5, 6}


@param table dest
@param table src
@param table begin insert position for dest
]]

-- 插入 仅限于下标1开始的连续表格
function table.insertTo(dest, src, begin)
    begin = tonumber(begin)
    if begin == nil then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

--[[
search target index at list.

@param table list
@param * target
@param int from idx, default 1
@param bool useNaxN, the len use table.maxn(true) or #(false) default:false
@param return index of target at list, if not return -1
]]
-- 返回target 的index，from为开始查询的位置 useMaxN 为最大查询索引
function table.indexOf(list, target, from, useMaxN)
    local len = (useMaxN and #list) or table.maxn(list)
    if from == nil then
        from = 1
    end
    for i = from, len do
        if list[i] == target then
            return i
        end
    end
    return -1
end
-- 返回表格中 子项中对应key为value的index
function table.indexOfKey(list, key, value, from, useMaxN)
    local len = (useMaxN and #list) or table.maxn(list)
    if from == nil then
        from = 1
    end
    local item = nil
    for i = from, len do
        item = list[i]
        if item ~= nil and item[key] == value then
            return i
        end
    end
    return -1
end
-- 删除table值为item的项
function table.removeItem(list, item, removeAll)
    local rmCount = 0
    for i = 1, #list do
        if list[i - rmCount] == item then
            table.remove(list, i - rmCount)
            if removeAll then
                rmCount = rmCount + 1
            else
                break
            end
        end
    end
end
-- table的元素调用函数fun  v为第一个参数，k为第二个参数 返回值返回到表格    
function table.map(t, fun)
    for k,v in pairs(t) do
        t[k] = fun(v, k)
    end
end


-- table的元素调用函数fun
function table.walk(t, fun)
    for k,v in pairs(t) do
        fun(v, k)
    end
end

function table.filter(t, fun)
    for k,v in pairs(t) do
        if not fun(v, k) then
            t[k] = nil
        end
    end
end

-- 表格是否存在值为item的元素
function table.find(t, item)
    return table.keyOfItem(t, item) ~= nil
end

--返回 表格value == item的key
function table.keyOfItem(t, item)
    for k,v in pairs(t) do
        if v == item then return k end
    end
    return nil
end

function table.removeWithValue(t, value)
    for k,v in pairs(t) do
        if v == value then 
		
			return table.remove(t, k) 
		
		end
    end		
end
 

--转换特殊字符为html编码
function string.htmlspecialchars(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, k, v)
    end
    return input
end
string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

-- 将html字符转化为原始基本字符
function string.htmlspecialcharsDecode(input)
    for k, v in pairs(string._htmlspecialchars_set) do
        input = string.gsub(input, v, k)
    end
    return input
end

-- 将换行符转化为html换行标记 
function string.nl2br(input)
    return string.gsub(input, "\n", "<br />")
end

-- 字符转化为html格式
function string.text2html(input)
    input = string.gsub(input, "\t", "    ")
    input = string.htmlspecialchars(input)
    input = string.gsub(input, " ", "&nbsp;")
    input = string.nl2br(input)	
    return input
end

--分割字符串
function string.split(str, delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, true) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end

function string.ParseVec3(str)
	local t = string.split(str, " ")	
    if(table.nums(t) == 3)then
	  return LORD.Vector3(t[1],t[2],t[3])
	else
	   return LORD.Vector3(0,0,0)
	end		
end	



-- 删除字符串前面的空白字符。 包括：空格、制表符“\t”、换行符“\n”和“\r”
function string.ltrim(str)
    return string.gsub(str, "^[ \t\n\r]+", "")
end
-- 删除字符串尾部的空白字符
function string.rtrim(str)
    return string.gsub(str, "[ \t\n\r]+$", "")
end

--删除字符两端的空白
function string.trim(str)
    str = string.gsub(str, "^[ \t\n\r]+", "")
    return string.gsub(str, "[ \t\n\r]+$", "")
end
-- 首字母大写
function string.ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

local function urlencodeChar(char)
    return "%" .. string.format("%02X", string.byte(c))
end
--生成符合 URL 规范的字符串。
function string.urlencode(str)
    -- convert line endings
    str = string.gsub(tostring(str), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    str = string.gsub(str, "([^%w%.%- ])", urlencodeChar)
    -- convert spaces to "+" symbols
    return string.gsub(str, " ", "+")
end

function string.urldecode(str)
    str = string.gsub (str, "+", " ")
    str = string.gsub (str, "%%(%x%x)", function(h) return string.char(tonum(h,16)) end)
    str = string.gsub (str, "\r\n", "\n")
    return str
end
--计算一个 UTF8 字符串包含的字符数量
function string.utf8len(str)
    local len  = #str
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(str, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

-- 将数字格式化为千分位格式
function string.formatNumberThousands(num)
    local formatted = tostring(tonum(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

function reload( moduleName )  
    package.loaded[moduleName] = nil  
    require(moduleName)  
end 

function clone(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for key, value in pairs(object) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
        end

        cls.ctor    = function() end
        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = clone(super)
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls
	 
        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

function LORD.Quaternion.Mul(a,b)
	local quan = LORD.Quaternion()	
			quan.w = a.w * b.w - a.x * b.x - a.y * b.y - a.z *b.z;
			quan.x = a.w * b.x + a.x * b.w + a.y * b.z - a.z *b.y;
			quan.y = a.w * b.y + a.y * b.w + a.z * b.x - a.x *b.z;
			quan.z = a.w * b.z + a.z * b.w + a.x * b.y - a.y *b.x;
	return quan			
end

function LORD.Vector3.Add(a,b)
		return LORD.Vector3(a.x+b.x,a.y+b.y,a.z+b.z)	
end

function LORD.Vector3.Sub(a,b)
		return LORD.Vector3(a.x-b.x,a.y-b.y,a.z-b.z)	
end

-- b为number
function LORD.Vector3.MulNum(a,b)
		return LORD.Vector3(a.x*b,a.y*b,a.z*b)	
end

function LORD.Vector3.IsZero(v)
		 return v.x == 0 and  v.y ==0 and v.z == 0
end




LORD.Color.WHITE = LORD.Color(1,1,1,1)
LORD.Color.RED = LORD.Color(1,0,0,1)
LORD.Color.GREEN = LORD.Color(0,1,0,1)
LORD.Color.BLUE = LORD.Color(0,0,1,1)

function math.RandomRange( min, max,uiSeed)
	uiSeed = uiSeed or 0
	math.randomseed(uiSeed)
	return math.round (math.random(min,max))	
end

function math.randomFloat(min, max)
	
	math.randomseed(dataManager.getServerTime());
	
	local range = max - min;
	local result = min + math.random() * range;
	
	--print("result "..result);
	return result;
end

function formatTime(t, isText)

	local hour = math.floor(t/3600);
	local min =  math.floor(math.fmod(t, 3600)/60);
	local sec = math.fmod(math.fmod(t, 3600), 60);

	if isText then
		if hour <= 0 then
			return string.format("%d分%02d秒", min, sec);
		elseif hour < 24 then
			return string.format("%d小时%02d分", hour, min);
		else
			local h = math.fmod(hour, 24);
			local day = math.floor(hour/24);
			return string.format("%d天%02d小时", day, h);
		end
	else
		return string.format("%02d:%02d:%02d",hour,min,sec)
	end
	
end

function formatMoney(money)
	
	if money >= 1000000000 then
		local yi = math.floor(money / 100000000);
		
		return yi.."亿";
		
	elseif money >= 1000000 then
		
		local wan = math.floor(money / 10000);
		return wan.."万";
		
	else
		return money;
	end
end

function isTimeValid(beginTime, endTime)
	local h, m, s = dataManager.getLocalTime();
	local nowTime = h*3600 + m*60 + s;
		

	local bhour, bminute = stringToTime(beginTime);
	local ehour, eminute = stringToTime(endTime);
			
	local beginTime = bhour*3600 + bminute*60;
	local endTime = ehour*3600 + eminute*60;
	
	local time24 = 24 * 3600;
	if beginTime < endTime then
		-- 当天
		return nowTime >= beginTime and nowTime < endTime
	else
		-- 跨天了
		return (nowTime>= beginTime and nowTime <= time24) or (nowTime>= time24 and nowTime <= endTime)
	end
	
end

function pairsByKeys(t)  
    local a = {}  
    for n in pairs(t) do  
        a[#a+1] = n  
    end  
    table.sort(a)  
    local i = 0  
    return function()  
        i = i + 1  
        return a[i], t[a[i]]  
    end  
end 

function stringToTime(strTime)
	local hour, minute = string.match(strTime, "(%d+):(%d+)");
	return hour, minute;
end

function stringToDate(strDate)
	
	local year, month, day = string.match(strDate, "(%d+)/(%d+)/(%d+)");
	
	return year, month, day;
end

 
function getClientVariable(key,default)
	 
		if(key == "gameSpeed") then	
			if( not global.getBattleTypeInfo(battlePrepareScene.getBattleType()).speedUp )then				
				
				if battlePrepareScene.getBattleType() == enum.BATTLE_TYPE.BATTLE_TYPE_PVP_ONLINE then
					default = SPEED_UP_GAME[2] or 2;
				end
				
				return  default
			end
		end	
		
		if(key == "AutoBattle") then	
			if( not global.getBattleTypeInfo(battlePrepareScene.getBattleType()).AutoBattle )then				
				return  false
			end
		end	
	 	
	local value = fio.readIni("Variable", key, tostring(default), global.getUserConfigFileName());
	--print("getClientVariable "..value);
	return value;

end	


function setClientVariable(key,v)
	
		if(key == "gameSpeed") then	
			if( not global.getBattleTypeInfo(battlePrepareScene.getBattleType()).speedUp )then		
				return 
			end
		end	
		if(key == "AutoBattle" ) then	
			if( not global.getBattleTypeInfo(battlePrepareScene.getBattleType()).AutoBattle )then		
				return 
			end
		end			
		
	  
	fio.writeIni("Variable", key,  tostring(v), global.getUserConfigFileName());		
end	
-- utf8
-- 	8
-- 	10 汉字3
	
--print(math.getStrByte("你好123a"))      			
--print(string.len("你好123a"))
function math.getStrByte( str)
	--return str
	return getStrByteSize(str)
end
function math.getStrWithByteSize( str,length)
	--return str
	return getStrWithByteSize(str,length)
end

-- input 应该是一个0～1的值
function getDecelerateInterpolation(input)
    local result;
    local mFactor = 1.0;
    
    if mFactor == 1.0 then
        result = (1.0 - (1.0 - input) * (1.0 - input));
    else
        result = (1.0 - math.pow((1.0 - input), 2 * mFactor));
    end
    
    return result;
end

function upLoadBugInfo()
	local file =  "battleRecord.txt"
	 
	ftp_post_file(FTP_URL..file,file)
	
end
	
	
function   __calcValueChange(old, new,rate)
		if new > old then
			local result = old + math.ceil((new - old)*rate);
			if result >= new then
				return -1;
			else
				return result;
			end
		elseif new < old then
			local result = old + math.floor((new - old)*rate);
			if result <= new then
				return -1;
			else
				return result;
			end
		else
			return -1;
		end
end