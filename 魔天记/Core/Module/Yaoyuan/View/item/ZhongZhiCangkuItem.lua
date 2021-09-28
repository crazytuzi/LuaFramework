require "Core.Module.Common.UIItem"
require "Core.Module.Yaoyuan.View.item.ZhongZhiCangKuProCtr"

ZhongZhiCangkuItem = class("ZhongZhiCangkuItem", UIItem);

function ZhongZhiCangkuItem:New()
    self = { };
    setmetatable(self, { __index = ZhongZhiCangkuItem });
    return self
end
 

function ZhongZhiCangkuItem:UpdateItem(data)
    self.data = data
end

function ZhongZhiCangkuItem:Init(gameObject, data)

    self.gameObject = gameObject;

    for i = 1, 2 do

        local obj = UIUtil.GetChildByName(self.gameObject, "Transform", "p" .. i);

        self["pCtr" .. i] = ZhongZhiCangKuProCtr:New();
        self["pCtr" .. i]:Init(obj);
    end

    self:SetData(data);

end

function ZhongZhiCangkuItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

function ZhongZhiCangkuItem:SetDefSelected()
    self["pCtr1"]:_OnClickBtn()
end


function ZhongZhiCangkuItem:SetData(data)

    self.data = data;

    if data == nil then
        self:SetActive(false);
    else
        local len = table.getn(data);
        for i = 1, 2 do

            if i <= len then
                self["pCtr" .. i]:SetData(data[i]);
            else
                self["pCtr" .. i]:SetData(nil);
            end
        end
        self:SetActive(true);
    end

end


function ZhongZhiCangkuItem:_Dispose()
    self.gameObject = nil;

    for i = 1, 2 do
        self["pCtr" .. i]:Dispose();
        self["pCtr" .. i] = nil;
    end

end