--[[
物品容器类
]]

local json = require "cjson"

ProductsContainer = { }
require "Core.Info.ProductInfo";

function ProductsContainer:New()
    local o = { };
    setmetatable(o, { __index = self });
    o._item = { };
    o._item_num = 0;
    self.itemClass = ProductInfo
    return o;
end  
 
function ProductsContainer:GetItem()
    return self._item;
end

function ProductsContainer:GetItemNum()
    return self._item_num;
end
 
function ProductsContainer:InitDatas(arr, key_str)

    self._item = { };
    if (arr == nil) then return end
    self._item_num = table.getCount(arr);
    for i = 1, self._item_num do
        local obj = arr[i];
        local key = obj[key_str];

        self._item[key] = self.itemClass:New();
        self._item[key]:Init(obj);
    end
end 
 
function ProductsContainer:GetByKey(key)
    return self._item[key];
end
 
function ProductsContainer:SetBykey(data, key)

    if data == nil then

        if self._item[key] ~= nil then
            self._item[key] = nil;
            self._item_num = self._item_num - 1;
        end
        -- end if
    else

        if self._item[key] == nil then
            self._item[key] = self.itemClass:New();
            self._item_num = self._item_num + 1;
        end
        -- end if
        self._item[key]:Init(data);
    end
end
 
 
function ProductsContainer:FindByAttKey(att_key, att_value)

    for key, value in pairs(self._item) do
        local att = value[att_key];
        if att == att_value then
            return value;
        end
    end
    return nil;
end

function ProductsContainer:FindTotalNumByKey(att_key, att_value)
    local num = 0;
    for key, value in pairs(self._item) do
        local att = value[att_key];
        if att == att_value then
            num = num + value.am;
        end
    end
    return num;
end

-- 替换两个容器的元素
-- -- {"m":[
-- self_data {"st":1,"pt":"10100103","id":"10142","idx":0},
-- other_data {"st":2,"pt":"10100103","id":"0","idx":0}]}

function ProductsContainer:UpData(data1, data2)

    if data2.st ~= nil then
        data1.st = data2.st;
    end

    if data2.pt ~= nil then
        data1.pt = data2.pt;
    end

    if data2.id ~= nil then
        data1.id = data2.id;
    end

    if data2.am ~= nil then
        data1.am = data2.am;
    end

    if data2.idx ~= nil then
        data1.idx = data2.idx;
    end

    if data2.spId ~= nil then
        data1.spId = data2.spId;
    end

    if data2.lev ~= nil then
        data1.lev = data2.lev;
    end

    if data2.bind ~= nil then
        data1.bind = data2.bind;
    end

    if data2.fm ~= nil then
        data1.fm = data2.fm;
    end

end

function ProductsContainer:Replace(other_container, other_data, self_data)

    local other_container_key = other_data.idx;
    local self_key = self_data.idx;

    local other_pt = other_container:GetByKey(other_container_key);
    local self_pt = self:GetByKey(self_key);

    local other_info = nil;
    local self_info = nil;

    if other_pt ~= nil then
        other_info = other_pt.baseData;

        --[[
        other_info.idx = self_data.idx;
        other_info.st = self_data.st;
        other_info.pt = self_data.pt;
        other_info.id = self_data.id;
       ]]

        self:UpData(other_info, self_data);

        if other_info.id == 0 then
            other_info = nil;
        end
    end

    if self_pt ~= nil then
        self_info = self_pt.baseData;

        --[[
        self_info.idx = other_data.idx;
        self_info.st = other_data.st;
        self_info.pt = other_data.pt;
        self_info.id = other_data.id;
        ]]

        self:UpData(self_info, other_data);

        if self_info.id == 0 then
            self_info = nil;
        end
    end


    other_container:SetBykey(self_info, other_container_key);
    self:SetBykey(other_info, self_key);

end

function ProductsContainer:SetItemClass(itemClass)
    self.itemClass = itemClass
end
  