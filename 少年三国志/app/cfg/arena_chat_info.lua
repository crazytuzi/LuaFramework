

---@classdef record_arena_chat_info
local record_arena_chat_info = {}
  
record_arena_chat_info.id = 0 --ID  
record_arena_chat_info.chat = "" --气泡文字  
record_arena_chat_info.type = 0 --文字类型值


arena_chat_info = {
   _data = {
    [1] = {1,"少年，你敢打我一下试试？",1,},
    [2] = {2,"以你的资质，永远达不到我这个高度。",1,},
    [3] = {3,"我是天才我怕谁，你来呀，哈哈哈！",1,},
    [4] = {4,"我充了2万块，你爱信不信。",1,},
    [5] = {5,"你瞅啥？信不信我弄你呢。",1,},
    [6] = {6,"请叫我，竞技场小霸王~",1,},
    [7] = {7,"少年三国志，少年王就是我~",1,},
    [8] = {8,"唉呀~~上面的空气~真新鲜~~",1,},
    [9] = {9,"我是低调而深沉的三国小王子~",1,},
    [10] = {10,"帅气的我，靠脸就能打到顶峰~",1,},
    [11] = {11,"除了美貌，我已经一无所有~",1,},
    [12] = {12,"来点我呀，让你见识什么叫真正的实力！",1,},
    [13] = {13,"我全身橙装强化全满，秒天秒地秒空气！",1,},
    [14] = {14,"每天早上我都会被自己帅醒。",1,},
    [15] = {15,"我已经觉醒了，你懂的，呵呵",1,},
    [16] = {16,"少年别打了，你妈妈叫你回家吃饭。",1,},
    [17] = {17,"是时候展现真正的技术了！",1,},
    [18] = {18,"我一定会成为三国之王！",1,},
    [19] = {19,"我排名这么靠前，丈母娘都为我骄傲！",1,},
    [20] = {20,"我是小学生，打这么靠前不容易，求放过。",1,},
    [21] = {21,"你知道玩命爱一个人的感受吗？",1,},
    [22] = {22,"少年三国志，玩起来带劲哟！",1,},
    [23] = {23,"来吧！我已经摩拳擦掌，跃跃欲试了！",1,},
    [24] = {24,"来嘛~尽情的挑逗，哦不，挑战我嘛~",1,},
    [25] = {25,"我站在高处，已经寂寞很久了。",1,},
    [26] = {26,"关羽赵云吕布夏侯惇加起来，不敌一个我~",1,},
    [27] = {27,"曾经有人打了我一下，第二天他就怀孕了~",1,},
    [28] = {28,"只有战斗，才能让我热血沸腾！",1,},
    [29] = {29,"第一名的元宝亮闪闪~你猜我拿到了没~",1,},
    [30] = {30,"等我天命10级，分分钟收拾掉你。",2,},
    [31] = {31,"总有一天我会超越你的，少年！",2,},
    [32] = {32,"少年，上面的风景很赞吧？",2,},
    [33] = {33,"今天你打我一下，明天我就把你踩在脚下。",2,},
    [34] = {34,"这位少年，借个位可以不！",2,},
    [35] = {35,"少年，为何你这么diao？",2,},
    [36] = {36,"少年别打了，你妈妈叫你回家吃饭。",2,},
    [37] = {37,"叔叔，我是小学生，别打我。",2,},
    [38] = {38,"少年，你充了多少钱啊？",2,},
    [39] = {39,"哼哼，凭什么你排在我前面~",2,},
    [40] = {40,"是不是我装备精炼不够？才打不过你？",2,},
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
  chat = 2,
  type = 3,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_arena_chat_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function arena_chat_info.getLength()
    return #arena_chat_info._data
end



function arena_chat_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_arena_chat_info
function arena_chat_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = arena_chat_info._data[index]}, m)
    
end

---
--@return @class record_arena_chat_info
function arena_chat_info.get(id)
    
    return arena_chat_info.indexOf(__index_id[id])
        
end



function arena_chat_info.set(id, key, value)
    local record = arena_chat_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function arena_chat_info.get_index_data()
    return __index_id
end