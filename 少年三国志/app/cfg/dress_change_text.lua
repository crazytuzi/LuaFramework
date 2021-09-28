

---@classdef record_dress_change_text
local record_dress_change_text = {}
  
record_dress_change_text.id = 0 --id  
record_dress_change_text.name = "" --名称  
record_dress_change_text.male_before = "" --男性换装前文字  
record_dress_change_text.male_after = "" --男性换装后文字  
record_dress_change_text.female_before = "" --女性换装前文字  
record_dress_change_text.female_after = "" --女性换装后文字


dress_change_text = {
   _data = {
    [1] = {1,"主角","别走开哦，回来给你看小鲜肉。","原来的我才是最小清新的那一个~","还记得我原来的样子吗？","翩翩衣袂，琴瑟相知~哈哈~",},
    [2] = {101,"孟获时装","蛮族不都是裸奔的吗？","换上新衣顿显王霸之气，哈哈！","哇~这件皮草好贵的吧！","很有贵妇的既视感呢，嘻嘻！",},
    [3] = {102,"祝融时装","给我穿豹纹不合适吧？","突然觉得自己有点小性感呢~","蛮族女子都穿这么拉风的款吗？","头上顶俩角很重的喂！",},
    [4] = {201,"太史慈时装","钟琴小朋友","大丈夫应射三支贱，立不世之功~噗~","钟琴小朋友","咦~我要不要把上面的大雁射下来？",},
    [5] = {202,"孙策时装","钟琴小朋友","孙权孙尚香，快来叫哥哥，哈哈！","钟琴小朋友","与小霸王孙策的情侣装哦~哈哈！",},
    [6] = {301,"张辽时装","钟琴小朋友","孙权别怕，是我~哈哈！","钟琴小朋友","穿这一身得去逍遥津溜达溜达~",},
    [7] = {302,"张郃时装","钟琴小朋友","听说有个外国人叫金刚狼？和我很像？","钟琴小朋友","专业修剪园林草坪，时薪8000元宝！",},
    [8] = {401,"赵云时装","钟琴小朋友","要是子龙知道我cos他，作何感想？","钟琴小朋友","除了赵子龙，我也可以白马银枪~哈~",},
    [9] = {402,"黄忠时装","钟琴小朋友","黄汉升~你的箭就是我的箭！","钟琴小朋友","百步穿杨，百发百中！",},
    [10] = {501,"张角时装","钟琴小朋友","嘛咪嘛咪哄，玛尼狗麦候！","钟琴小朋友","天灵灵地灵灵，魑魅魍魉快显形~",},
    [11] = {502,"于吉时装","钟琴小朋友","我这里有一本太平神书，100元宝！要不要？","钟琴小朋友","太平……我哪里平？",},
    [12] = {601,"蔡文姬时装","钟琴小朋友哪里平？","穿这身衣服，智商会被菜菜拉低么？","钟琴小朋友哪里平？","穿这身衣服，智商会被菜菜拉低么？",},
    [13] = {602,"黄月英时装","钟琴小朋友哪里平？","英英的面纱会遮住我的美貌~","钟琴小朋友哪里平？","英英的面纱会遮住我的美貌~",},
    [14] = {701,"荀彧时装","呵呵哒","戴上荀彧老师的博士帽就是知识分子了。","呵呵哒","跟着荀彧老师，做个有文化的人。",},
    [15] = {702,"诸葛亮时装","呵呵哒","万事俱备，只欠东风，哈哈！","呵呵哒","万事俱备，只欠东风，哈哈！",},
    [16] = {703,"孙坚时装","呵呵哒","哈哈，孙策孙权，快来叫爸爸！","呵呵哒","看！我后面有只老虎！",},
    [17] = {704,"吕布时装","呵呵哒","我是花果山水帘洞的美男子吕奉先！","呵呵哒","我头上有犄角~犄角，我身后有披挂~",},
	[18] = {705,"曹操时装","呵呵哒","我是花果山水帘洞的美男子曹操！","呵呵哒","我头上有犄角~犄角，我身后有披挂~",},
	[19] = {706,"关羽时装","呵呵哒","我是花果山水帘洞的美男子关羽！","呵呵哒","我头上有犄角~犄角，我身后有披挂~",},
	[20] = {707,"周瑜时装","呵呵哒","我是花果山水帘洞的美男子周瑜！","呵呵哒","我头上有犄角~犄角，我身后有披挂~",},
	[21] = {708,"左慈时装","呵呵哒","我是花果山水帘洞的美男子左慈！","呵呵哒","我头上有犄角~犄角，我身后有披挂~",},
    }
}



local __index_id = {
    [1] = 1,
    [101] = 2,
    [102] = 3,
    [201] = 4,
    [202] = 5,
    [301] = 6,
    [302] = 7,
    [401] = 8,
    [402] = 9,
    [501] = 10,
    [502] = 11,
    [601] = 12,
    [602] = 13,
    [701] = 14,
    [702] = 15,
    [703] = 16,
    [704] = 17,
	[705] = 18,
	[706] = 19,
	[707] = 20,
	[708] = 21,

}

local __key_map = {
  id = 1,
  name = 2,
  male_before = 3,
  male_after = 4,
  female_before = 5,
  female_after = 6,

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
        
        assert(__key_map[k], "cannot find " .. k .. " in record_dress_change_text")
        
        
        return t._raw[__key_map[k]]
    end
}


function dress_change_text.getLength()
    return #dress_change_text._data
end



function dress_change_text.hasKey(k)
  if __key_map[k] == nil then
    return false
  else
    return true
  end
end


---
--@return @class record_dress_change_text
function dress_change_text.indexOf(index)
    if index == nil then
        return nil
    end
    
    return setmetatable({_raw = dress_change_text._data[index]}, m)
    
end

---
--@return @class record_dress_change_text
function dress_change_text.get(id)
    
    return dress_change_text.indexOf(__index_id[id])
        
end



function dress_change_text.set(id, key, value)
    local record = dress_change_text.get(id)
    if record then
        local keyIndex = __key_map[key]
        if keyIndex then
            record._raw[keyIndex] = value
        end
    end
end




function dress_change_text.get_index_data()
    return __index_id
end