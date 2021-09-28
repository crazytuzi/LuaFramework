require "Core.Module.Common.UIComponent"

local StarItem2 = class("StarItem2", UIItem);
function StarItem2:New()
    self = { };
    setmetatable(self, { __index = StarItem2 });
    return self
end


function StarItem2:_Init()
    self:_InitReference();
    self:_InitListener();
    self:UpdateItem(self.data)
end

function StarItem2:_InitReference()
    self._txtlev = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtlev");
    self._txtAtts = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtAtts");
    self._imgQuality = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgQuality");
    self._imgIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgIcon");
    self._select = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgSelect");
end

function StarItem2:UpdateItem(data)
    if not data then return end
    local dataIsId = type(data) ~= "table"
    if dataIsId then data = { spId = data} end
    self.data = data
    local pinfo = ProductManager.GetProductById(data.spId)
    local lev = (data.level and data.level or pinfo.lev)
    local quality = pinfo.quality
    self.data.quality = quality
    self._txtlev.text = ColorDataManager.GetColorText(ColorDataManager.GetColorByQuality(quality),
    LanguageMgr.Get("StarPanel/upgrade/lev", { n = pinfo.name, l = lev }))
    if self._txtAtts then
        local ps1 = ''
        local ps2 = ''
        if not data.fusion_exp then 
            local ac = StarManager.GetAttConfig(quality, lev)
            local as = ac and StarManager.GetAttForConfig(pinfo.kind, ac, true) or nil
            local propertyData = as and as:GetPropertyAndDes() or nil
            if propertyData and propertyData[1] then 
                ps1 = propertyData[1].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), " +" .. propertyData[1].property .. propertyData[1].sign)
            end
            if propertyData and propertyData[2] then
                ps2 = propertyData[2].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), " +" .. propertyData[2].property .. propertyData[2].sign)
            end
        else
            ps1 = LanguageMgr.Get("StarPanel/item/elite", { n = data.fusion_exp })
        end
        self._txtAtts.text = ps1 .. '\n' .. ps2
    end
    self._imgQuality.color = ColorDataManager.GetColorByQuality(quality)
    ProductManager.SetIconSprite(self._imgIcon, pinfo.icon_id)
end

function StarItem2:_InitListener()
    self:_AddBtnListen(self.gameObject)
end

function StarItem2:_OnBtnsClick(go)
    if self.ctroller then self.ctroller:SelectItem(self) end
end

function StarItem2:SetSelect(f)
    self._select.enabled = f
end

function StarItem2:SetTips(f)
    if not self.imgTips then
         self.imgTips = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgTips")
    end
    if self.imgTips then self.imgTips.enabled = f end
end

function StarItem2:GetSelect()
    return self._select.enabled
end

function StarItem2:_Dispose()
    self:_DisposeReference();
end

function StarItem2:_DisposeReference()
    self._txtlev = nil;
    self._txtAtts = nil;
    self._imgQuality = nil;
    self._imgIcon = nil;
end
return StarItem2