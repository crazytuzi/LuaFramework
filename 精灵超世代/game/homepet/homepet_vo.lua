-- --------------------------------------------------------------------
--
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      萌宠对象
-- <br/>Create: 2019-06-28
HomepetVo = HomepetVo or BaseClass(EventDispatcher)


function HomepetVo:__init()

    self.pet_id = 0 --宠物基础id
    self.name = "" --宠物名
    self.state = 0 --宠物状态(0未激活/1在家 2 出行)
    self.vigor = 0 --精力值
    self.vigor_time = 0--精力下次回复时间
    
    -- {uint8, key, "键:(1:本次出行食物 2:本次出行道具 3:下次出行食物 4:下次出行道具)"}
    -- ,{uint32, id, "道具唯一id"}
    self.set_item = {} --行囊 信息
    -- self.dic_set_item_id[key] = id 键: = 道具唯一id
    self.dic_set_item_id = {}

    self.rename_count = 0 --当前改名次数
    self.day_talk = 0 --今日已对话次数
    self.day_feed = 0 --今日已喂食次数
end


function HomepetVo:updateAttrData(data)
    if not data then return end
    for k, v in pairs(data) do
        if self[k] then
            self[k] = v
        end
        if k == "set_item" then
            self:updateSetItem(v)
        end
        
        self:Fire(HomepetEvent.HOME_PET_VO_ATTR_EVENT,k, v)
    end
    
end

function HomepetVo:updateSetItem(value)
    if not value then return end
    self.dic_set_item_id = {}

    for i,v in ipairs(value) do
        self.dic_set_item_id[v.key] = v.id
    end
end

--获取行囊信息  self.dic_set_item_id[位置] = id
function HomepetVo:getSetItemInfo()
    return self.dic_set_item_id or {}
end

--获取宠物名字
function HomepetVo:getPetName()
    if self.name == nil or self.name == "" then
        return TI18N("二哈")
    else
        return self.name
    end
end

--获取宠物状态
function HomepetVo:getPetState()
    return self.state 
end

--获取宠物精力值
function HomepetVo:getPetVigor()
    return self.vigor or 0
end

--获取宠物精力时间
function HomepetVo:getPetVigorTime()
    if self.vigor_time == 0 then return 0 end

    local time = self.vigor_time - GameNet:getInstance():getTime()
    if time < 0 then
        time = 0
    end
    return time
end


function HomepetVo:__delete()

end
