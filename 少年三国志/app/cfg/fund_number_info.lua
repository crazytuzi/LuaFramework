

---@classdef record_fund_number_info
local record_fund_number_info = {}
  
record_fund_number_info.id = 0 --id  
record_fund_number_info.buy_number = 0 --购买人数  
record_fund_number_info.name = "" --奖励  
record_fund_number_info.type = 0 --货物类型  
record_fund_number_info.value = 0 --货物类型值  
record_fund_number_info.size = 0 --货物数量


fund_number_info = {
   _data = {
    [1] = {1,1000,"贪狼头盔*3",5,4023,3,},
    [2] = {2,500,"元宝*4500",2,0,4500,},
    [3] = {3,600,"元宝*6000",2,0,6000,},
    [4] = {4,700,"元宝*9000",2,0,9000,},
    [5] = {5,800,"元宝*15000",2,0,15000,},
    [6] = {6,10,"金龙宝宝*3",4,2003,3,},
    [7] = {7,30,"30万银两",1,0,300000,},
    [8] = {8,50,"60万银两",1,0,600000,},
    [9] = {9,100,"精力丹*30",3,4,100,},
    [10] = {10,200,"中级精炼石*300",3,11,200,},
    [11] = {11,300,"宝物精炼石*300",3,18,300,},
    [12] = {12,500,"天命石*300",3,14,300,},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [2] = 2,
    [3] = 3,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  buy_number = 2,
  name = 3,
  type = 4,
  value = 5,
  size = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_fund_number_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function fund_number_info.getLength()
    return #fund_number_info._data
end



function fund_number_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_fund_number_info
function fund_number_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = fund_number_info._data[index]}, m)
    
end

---
--@return @class record_fund_number_info
function fund_number_info.get(id)
    
    return fund_number_info.indexOf(__index_id[id])
        
end



function fund_number_info.set(id, key, value)
    local record = fund_number_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function fund_number_info.get_index_data()
    return __index_id
end