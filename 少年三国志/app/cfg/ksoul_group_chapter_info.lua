

---@classdef record_ksoul_group_chapter_info
local record_ksoul_group_chapter_info = {}
  
record_ksoul_group_chapter_info.id = 0 --章节id  
record_ksoul_group_chapter_info.name = "" --章节名称  
record_ksoul_group_chapter_info.image = 0 --背景图  
record_ksoul_group_chapter_info.star_image = 0 --星阵图  
record_ksoul_group_chapter_info.star_color = 0 --星阵颜色（十进制）  
record_ksoul_group_chapter_info.level = 0 --开启等级限制  
record_ksoul_group_chapter_info.pre_chapter = 0 --前置章节id  
record_ksoul_group_chapter_info.group_num = 0 --前置章节达成组合数


ksoul_group_chapter_info = {
   _data = {
    [1] = {1,"群雄逐鹿",1,1,7265792,55,0,0,},
    [2] = {2,"奇人异士",2,1,15561984,70,1,50,},
    [3] = {3,"旷世能臣",3,1,7265792,85,2,50,},
    [4] = {4,"天下无双",2,1,15561984,100,3,40,},
    }
}



local __index_id = {
    [1] = 1,
    [2] = 2,
    [3] = 3,
    [4] = 4,

}

local __key_map = {
  id = 1,
  name = 2,
  image = 3,
  star_image = 4,
  star_color = 5,
  level = 6,
  pre_chapter = 7,
  group_num = 8,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_ksoul_group_chapter_info")
        
        
        return t._raw[__key_map[k]]
    end
}


function ksoul_group_chapter_info.getLength()
    return #ksoul_group_chapter_info._data
end



function ksoul_group_chapter_info.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_ksoul_group_chapter_info
function ksoul_group_chapter_info.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = ksoul_group_chapter_info._data[index]}, m)
    
end

---
--@return @class record_ksoul_group_chapter_info
function ksoul_group_chapter_info.get(id)
    
    return ksoul_group_chapter_info.indexOf(__index_id[id])
        
end



function ksoul_group_chapter_info.set(id, key, value)
    local record = ksoul_group_chapter_info.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function ksoul_group_chapter_info.get_index_data()
    return __index_id
end