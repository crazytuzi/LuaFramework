

---@classdef record_expansion_dungeon_shop_info
local record_expansion_dungeon_shop_info = {}
  
record_expansion_dungeon_shop_info.id = 0 --id  
record_expansion_dungeon_shop_info.chapter_id = 0 --所属章节ID  
record_expansion_dungeon_shop_info.item_type = 0 --物品类型  
record_expansion_dungeon_shop_info.item_value = 0 --物品ID  
record_expansion_dungeon_shop_info.item_size = 0 --物品数量  
record_expansion_dungeon_shop_info.time = 0 --可购次数  
record_expansion_dungeon_shop_info.price_type = 0 --购买货币类型  
record_expansion_dungeon_shop_info.discount = 0 --折扣  
record_expansion_dungeon_shop_info.discount_price = 0 --折扣价  
record_expansion_dungeon_shop_info.price = 0 --原价  
record_expansion_dungeon_shop_info.discount_path = "" --折扣角标


expansion_dungeon_shop_info = {
   _data = {
    [1] = {1,1,3,13,100,1,2,3,600,2000,"xsyh_zhekou_3",},
    [2] = {2,1,1,0,1000000,1,2,3,300,1000,"xsyh_zhekou_3",},
    [3] = {3,2,1,0,1000000,1,2,3,300,1000,"xsyh_zhekou_3",},
    [4] = {4,2,3,18,300,1,2,3,450,1500,"xsyh_zhekou_3",},
    [5] = {5,3,1,0,2000000,1,2,3,600,2000,"xsyh_zhekou_3",},
    [6] = {6,3,3,60,400,2,2,3,360,1200,"xsyh_zhekou_3",},
    [7] = {7,4,1,0,2000000,1,2,3,600,2000,"xsyh_zhekou_3",},
    [8] = {8,4,3,297,5,1,2,8,400,500,"xsyh_zhekou_8",},
    [9] = {9,5,1,0,3000000,1,2,3,900,3000,"xsyh_zhekou_3",},
    [10] = {10,5,3,200,50,1,2,3,1500,5000,"xsyh_zhekou_3",},
    [11] = {11,6,1,0,3000000,1,2,3,900,3000,"xsyh_zhekou_3",},
    [12] = {12,6,3,295,5,1,2,8,800,1000,"xsyh_zhekou_8",},
    [13] = {13,7,1,0,4000000,1,2,3,1200,4000,"xsyh_zhekou_3",},
    [14] = {14,7,3,275,5,1,2,7,3500,5000,"xsyh_zhekou_7",},
    [15] = {15,8,1,0,4000000,1,2,3,1200,4000,"xsyh_zhekou_3",},
    [16] = {16,8,34,0,1000,1,2,0,1000,1000,"0",},
    }
}



local __index_id = {
    [1] = 1,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [14] = 14,
    [15] = 15,
    [16] = 16,
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
  chapter_id = 2,
  item_type = 3,
  item_value = 4,
  item_size = 5,
  time = 6,
  price_type = 7,
  discount = 8,
  discount_price = 9,
  price = 10,
  discount_path = 11,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_expansion_dungeon_shop_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function expansion_dungeon_shop_info.getLength()
    return #expansion_dungeon_shop_info._data
end



function expansion_dungeon_shop_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_expansion_dungeon_shop_info
function expansion_dungeon_shop_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = expansion_dungeon_shop_info._data[index]}, m)
    
end

---
--@return @class record_expansion_dungeon_shop_info
function expansion_dungeon_shop_info.get(id)
    
    return expansion_dungeon_shop_info.indexOf(__index_id[id])
        
end



function expansion_dungeon_shop_info.set(id, key, value)
    local record = expansion_dungeon_shop_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function expansion_dungeon_shop_info.get_index_data()
    return __index_id
end