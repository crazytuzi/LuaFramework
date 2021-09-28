

---@classdef record_face_info
local record_face_info = {}
  
record_face_info.id = 0 --编号  
record_face_info.explain = "" --表情说明


face_info = {
   _data = {
    [1] = {1,"开心",},
    [2] = {2,"吐舌",},
    [3] = {3,"害羞",},
    [4] = {4,"窃喜",},
    [5] = {5,"得意",},
    [6] = {6,"么么",},
    [7] = {7,"尴尬",},
    [8] = {8,"卖萌",},
    [9] = {9,"努力",},
    [10] = {10,"有钱",},
    [11] = {11,"喜欢",},
    [12] = {12,"想入非非",},
    [13] = {13,"无奈",},
    [14] = {14,"悲惨",},
    [15] = {15,"哭泣",},
    [16] = {16,"睡觉",},
    [17] = {17,"安静",},
    [18] = {18,"不明真相",},
    [19] = {19,"瞧不起",},
    [20] = {20,"耶",},
    [21] = {21,"冷汗",},
    [22] = {22,"无语",},
    [23] = {23,"呕吐",},
    [24] = {24,"头晕",},
    [25] = {25,"无计可施",},
    [26] = {26,"惊讶",},
    [27] = {27,"发怒",},
    [28] = {28,"生气",},
    [29] = {29,"坏笑",},
    [30] = {30,"大拇指",},
    [31] = {31,"墨镜",},
    [32] = {32,"鄙视",},
    [33] = {33,"无言以对",},
    [34] = {34,"白眼",},
    [35] = {35,"鼓掌",},
    [36] = {36,"握手",},
    [37] = {37,"OK",},
    [38] = {38,"闭嘴",},
    [39] = {39,"爱心",},
    [40] = {40,"心碎",},
    [41] = {41,"玫瑰",},
    [42] = {42,"元宝",},
    [43] = {43,"忐忑",},
    [44] = {44,"打招呼",},
    [45] = {45,"灵光一闪",},
    [46] = {46,"鬼脸",},
    [47] = {47,"叹气",},
    [48] = {48,"思考",},
    [49] = {49,"无所谓",},
    [50] = {50,"什么情况",},
    [51] = {51,"摸摸",},
    [52] = {52,"飞吻",},
    [53] = {53,"得意洋洋",},
    [54] = {54,"投降",},
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
    [31] = 31,
    [32] = 32,
    [33] = 33,
    [34] = 34,
    [35] = 35,
    [36] = 36,
    [37] = 37,
    [38] = 38,
    [39] = 39,
    [4] = 4,
    [40] = 40,
    [41] = 41,
    [42] = 42,
    [43] = 43,
    [44] = 44,
    [45] = 45,
    [46] = 46,
    [47] = 47,
    [48] = 48,
    [49] = 49,
    [5] = 5,
    [50] = 50,
    [51] = 51,
    [52] = 52,
    [53] = 53,
    [54] = 54,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  explain = 2,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_face_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function face_info.getLength()
    return #face_info._data
end



function face_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_face_info
function face_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = face_info._data[index]}, m)
    
end

---
--@return @class record_face_info
function face_info.get(id)
    
    return face_info.indexOf(__index_id[id])
        
end



function face_info.set(id, key, value)
    local record = face_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function face_info.get_index_data()
    return __index_id
end