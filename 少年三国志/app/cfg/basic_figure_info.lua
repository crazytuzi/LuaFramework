

---@classdef record_basic_figure_info
local record_basic_figure_info = {}
  
record_basic_figure_info.id = 0 --数值ID  
record_basic_figure_info.type = 0 --数值类型  
record_basic_figure_info.name = "" --数值名称  
record_basic_figure_info.unit_recover = 0 --数值单元恢复量  
record_basic_figure_info.unit_time = 0 --数值单元时间量  
record_basic_figure_info.time_limit = 0 --时间上限  
record_basic_figure_info.max_limit = 0 --最大上限


basic_figure_info = {
   _data = {
    [1] = {1,1,"体力",1,360,100,500,},
    [2] = {2,2,"精力",1,1800,30,200,},
    [3] = {3,3,"征讨令",1,3600,10,80,},
    [4] = {4,4,"粮草",500,3599,999999,999999,},
    [5] = {5,5,"可攻打次数",1,3600,999,999,},
    [6] = {6,6,"挑战次数",1,3600,999,999,},
    [7] = {7,7,"挑战次数",1,7200,10,999,},
    [8] = {8,8,"挑战次数",1,60,10,999,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,

}

local __key_map = {
  id = 1,
  type = 2,
  name = 3,
  unit_recover = 4,
  unit_time = 5,
  time_limit = 6,
  max_limit = 7,

}



local m = { 
    __index = function(t, k) 
        if k == "toObject" then
            return function()  
                local o = {}
                for key, v in pairs (__key_map) do 
                    o[key] = t._raw[v]
                end
                return o
            end 
        end
        
        assert(__key_map[k], "cannot find " .. k .. " in record_basic_figure_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function basic_figure_info.getLength()
    return #basic_figure_info._data
end



function basic_figure_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_basic_figure_info
function basic_figure_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = basic_figure_info._data[index]}, m)
    
end

---
--@return @class record_basic_figure_info
function basic_figure_info.get(id)
    
    return basic_figure_info.indexOf(__index_id[id])
        
end



function basic_figure_info.set(id, key, value)
    local record = basic_figure_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function basic_figure_info.get_index_data()
    return __index_id
end