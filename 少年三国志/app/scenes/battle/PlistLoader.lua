-- PlistLoader

local PlistLoader = {}

local plist_list_default = {

    -- 角色出现
    -- ['battle/sp/sp_char_show/sp_char_show.png'] = 1,
    -- 角色死亡
    -- ['battle/sp/sp_char_die/sp_char_die.png'] = 2,
    -- 技能出手
    ['battle/sp/sp_char_skillstart/sp_char_skillstart.png'] = 1,
    
    -- 大招拉幕的两个资源
    -- 水墨
    ['battle/sp/sp_shuimo/sp_shuimo.png'] = 2,
    -- 蓝色背景
    ['battle/sp/sp_blue_bg/sp_blue_bg.png'] = 3,
    
    -- 接下来就是战斗中使用的资源
    
}

local plist_list = {}
local plist_get_list = nil

local priority = table.nums(plist_list_default)

function PlistLoader.add(plist)
    if type(plist) == "string" then
        if not plist_list[plist] and not plist_list_default[plist] then
            priority = priority + 1
            plist_list[plist] = priority
        end
    elseif type(plist) == "table" then
        for i=1, #plist do
            if not plist_list[plist[i]] and not plist_list_default[plist[i]] then
                priority = priority + 1
                plist_list[plist[i]] = priority
            end
        end
    end
end

function PlistLoader.clear()
    plist_list = {}
    plist_get_list = nil
    priority = table.nums(plist_list_default)
end

function PlistLoader.getList()

    local _t = clone(plist_list_default)
    
    for k, v in pairs(plist_list) do
        _t[k] = _t[k] and math.min(v, _t[k]) or v
    end
    
    plist_get_list = {}
    
    -- 交换键值
    for k, v in pairs(_t) do
        plist_get_list[#plist_get_list+1] = {priority = v, path = k}
    end
    
    -- 然后排序, 按从小到大
    table.sort(plist_get_list, function(a, b) return a.priority < b.priority end)
    
    local _temp = {}
    for i=1, #plist_get_list do
        _temp[i] = plist_get_list[i].path
    end
    
    plist_get_list = _temp
    
    return plist_get_list
end

function PlistLoader.desc()    
    local list = PlistLoader.getList()
    for i=1, #list do
        local plist = list[i]
        print("<load path: "..plist..">")
    end
end

return PlistLoader

