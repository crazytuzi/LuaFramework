

---@classdef record_treasure_robot_info
local record_treasure_robot_info = {}
  
record_treasure_robot_info.id = 0 --编号  
record_treasure_robot_info.name = "" --角色名称


treasure_robot_info = {
   _data = {
    [1] = {1,"司马煜",},
    [2] = {2,"上官晓静",},
    [3] = {3,"欧阳禁",},
    [4] = {4,"夏侯策",},
    [5] = {5,"诸葛云飞",},
    [6] = {6,"东方琪琪",},
    [7] = {7,"皇甫琳",},
    [8] = {8,"尉迟忠",},
    [9] = {9,"公孙闻溪",},
    [10] = {10,"轩辕红云",},
    [11] = {11,"令狐东",},
    [12] = {12,"宇文长虹",},
    [13] = {13,"长孙寒",},
    [14] = {14,"慕容若兰",},
    [15] = {15,"司徒空",},
    [16] = {16,"司空若梦",},
    [17] = {17,"太史雍",},
    [18] = {18,"公叔治",},
    [19] = {19,"乌孙洛",},
    [20] = {20,"南宫菲菲",},
    [21] = {21,"欧阳思",},
    [22] = {22,"夏侯破军",},
    [23] = {23,"令狐龙",},
    [24] = {24,"司徒庶",},
    [25] = {25,"太史无忌",},
    [26] = {26,"完颜肃",},
    [27] = {27,"夏侯炎",},
    [28] = {28,"司马寒",},
    [29] = {29,"公孙天佑",},
    [30] = {30,"宇文暄",},
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
    [17] = 17,
    [18] = 18,
    [19] = 19,
    [2] = 2,
    [20] = 20,
    [21] = 21,
    [22] = 22,
    [23] = 23,
    [24] = 24,
    [25] = 25,
    [26] = 26,
    [27] = 27,
    [28] = 28,
    [29] = 29,
    [3] = 3,
    [30] = 30,
    [4] = 4,
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  name = 2,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_treasure_robot_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function treasure_robot_info.getLength()
    return #treasure_robot_info._data
end



function treasure_robot_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_treasure_robot_info
function treasure_robot_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = treasure_robot_info._data[index]}, m)
    
end

---
--@return @class record_treasure_robot_info
function treasure_robot_info.get(id)
    
    return treasure_robot_info.indexOf(__index_id[id])
        
end



function treasure_robot_info.set(id, key, value)
    local record = treasure_robot_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function treasure_robot_info.get_index_data()
    return __index_id
end