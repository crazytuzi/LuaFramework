

---@classdef record_shop_dialogue_info
local record_shop_dialogue_info = {}
  
record_shop_dialogue_info.id = 0 --对话id  
record_shop_dialogue_info.type = 0 --对话类型  
record_shop_dialogue_info.trigger = 0 --对话触发条件  
record_shop_dialogue_info.content = "" --对话内容


shop_dialogue_info = {
   _data = {
    [1] = {1,1,1,"客官，你真有眼光！",},
    [2] = {2,1,1,"这可是我们这里的畅销货哦~",},
    [3] = {3,1,1,"小本经营，常常来关照哦~",},
    [4] = {4,1,1,"这可是别处买不到的呢~",},
    [5] = {5,1,2,"客官好久没来了，可想你了……",},
    [6] = {6,1,2,"讨厌，不要啦……",},
    [7] = {7,1,2,"新货到的时候别忘了来看看哦",},
    [8] = {8,1,2,"客官，你是想等我下班吗……",},
    [9] = {9,4,1,"客官，你真有眼光！",},
    [10] = {10,4,1,"这可是我们这里的畅销货哦~",},
    [11] = {11,4,1,"小本经营，常常来关照哦~",},
    [12] = {12,4,1,"这可是别处买不到的呢~",},
    [13] = {13,4,2,"客官好久没来了，可想你了……",},
    [14] = {14,4,2,"讨厌，不要啦……",},
    [15] = {15,4,2,"新货到的时候别忘了来看看哦",},
    [16] = {16,4,2,"客官，你是想等我下班吗……",},
    [17] = {17,5,1,"开箱技术哪家强？",},
    [18] = {18,5,1,"箱中自有黄金屋，箱中自有颜如玉……",},
    [19] = {19,5,1,"我的宝箱，时尚时尚最时尚~",},
    [20] = {20,5,1,"上厕所不洗手果然，提高人品……",},
    [21] = {21,5,2,"你想要金箱子，银箱子，还是木头箱子呢？",},
    [22] = {22,5,2,"砸箱子就好，不要砸人家啦！",},
    [23] = {23,5,2,"摸摸人家，可提升人品哦！",},
    [24] = {24,5,2,"别点了将军，我们不约！",},
    [25] = {25,6,1,"客官，您真有眼光！",},
    [26] = {26,6,1,"小本经营，概不赊欠……",},
    [27] = {27,6,1,"这可是刘备大人最喜欢的牌子，很畅销的哟！",},
    [28] = {28,6,1,"这可是被曹操大人亲自开光过的宝贝哟！",},
    [29] = {29,6,2,"今天忘记进货，感觉自己萌萌哒！",},
    [30] = {30,6,2,"无论你点我多少次，我都不会打折的……",},
    [31] = {31,6,2,"新货到的时候别忘了来看看哦",},
    [32] = {32,6,2,"客官，你是想等我下班吗……",},
    [33] = {33,8,1,"想成为演武之王，买我的东西准没错。",},
    [34] = {34,8,1,"好眼力啊客官，有了它您一定能百战百胜。",},
    [35] = {35,8,1,"客官好走，祝演武大胜哟。",},
    [36] = {36,8,1,"演武比赛要开始啦，客官赶快去比赛吧！",},
    [37] = {37,8,2,"店虽小，但商品齐全，请慢慢挑选。",},
    [38] = {38,8,2,"在三国混，没称号怎么行，赶紧买一个吧！",},
    [39] = {39,8,2,"红武将红装备，本店独家贩售啦。",},
    [40] = {40,8,2,"老点我又不买东西，再这样我赶你出去哟。",},
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
    [5] = 5,
    [6] = 6,
    [7] = 7,
    [8] = 8,
    [9] = 9,

}

local __key_map = {
  id = 1,
  type = 2,
  trigger = 3,
  content = 4,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_shop_dialogue_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function shop_dialogue_info.getLength()
    return #shop_dialogue_info._data
end



function shop_dialogue_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_shop_dialogue_info
function shop_dialogue_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = shop_dialogue_info._data[index]}, m)
    
end

---
--@return @class record_shop_dialogue_info
function shop_dialogue_info.get(id)
    
    return shop_dialogue_info.indexOf(__index_id[id])
        
end



function shop_dialogue_info.set(id, key, value)
    local record = shop_dialogue_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function shop_dialogue_info.get_index_data()
    return __index_id
end