require "Core.Module.Common.UIItem"
CauldronItem = class("CauldronItem", UIItem);
local MAXQUALITY = 4

function CauldronItem:New()
    self = { };
    setmetatable(self, { __index = CauldronItem });
    return self
end


function CauldronItem:_Init()
    self._speQc = TrumpManager.GetTrumpConfig().gold_id
    self:_InitReference();
    self:UpdateItem(self.data)
end

function CauldronItem:_InitReference()
    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
    self._imgCostIcon = UIUtil.GetChildByName(self.transform, "UISprite", "costIcon")
    self._imgNameBg = UIUtil.GetChildByName(self.transform, "UISprite", "nameBg")
    self._imgBg = UIUtil.GetChildByName(self.transform, "UISprite", "bg")

    self._goSpeBg = UIUtil.GetChildByName(self.transform, "speBg").gameObject
    self._imgSelect = UIUtil.GetChildByName(self.transform, "UISprite", "select")
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
    self._txtCost = UIUtil.GetChildByName(self.transform, "UILabel", "cost")
    self._collider = UIUtil.GetComponent(self.transform, "BoxCollider")
    self._onClickItem = function(go) self:_OnClickItem(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
end 
 
function CauldronItem:_OnClickItem()
    local qcl = TrumpManager.GetQcList()
    local flag = table.contains(qcl, self.data.quality)
    if ((self.data.quality == self._speQc) and not flag) then
        TrumpProxy.SendGetTrumpByType(2, self.data.quality)
    else
        TrumpProxy.SendGetTrumpByType(0, self.data.quality)
    end
    --    TrumpManager.SetSelectQc(self.data.quality)
end

function CauldronItem:UpdateItem(data)
    if (data == nil) then return end
    self.data = data
    self:UpdateColliderEnable()
    --    self._imgIcon.spriteName = tostring(data.icon)
    self._txtName.text = data.name
    local qcl = TrumpManager.GetQcList()
    local flag = table.contains(qcl, self.data.quality)

    if ((self.data.quality == self._speQc) and not flag) then
        self._txtCost.text = TrumpManager.GetTrumpConfig().gold
        self._imgCostIcon.spriteName = "xianyu"
        self._goSpeBg:SetActive(true)
    else
        self._txtCost.text = tostring(data.cost)
        self._imgCostIcon.spriteName = "lingshi"
        self._goSpeBg:SetActive(false)
    end

    if (self.data.quality == TrumpManager.GetNextQc()) then
        self._imgSelect.gameObject:SetActive(true)
    else
        self._imgSelect.gameObject:SetActive(false)
    end

    -- 最后一个隐藏箭头
    if (self.data.quality == MAXQUALITY) then
        if (self._goArrow == nil) then
            self._goArrow = UIUtil.GetChildByName(self.transform, "arrow").gameObject
            self._goArrow:SetActive(false)
        end
    end
    --    if(self.)
    --    self._imgQuaility.spriteName =
end

-- function CauldronItem:SetToggleValue(v)
--    self._toggle.value = v
-- end

function CauldronItem:UpdateColliderEnable()
    local qcl = TrumpManager.GetQcList()
    local flag = table.contains(qcl, self.data.quality)
    if (self.data.quality == self._speQc) then
        --        ColorDataManager.UnSetGray(self._imgIcon)
        self._collider.enabled = true
    else
        self._collider.enabled = flag
        self._imgCostIcon.gameObject:SetActive(flag)
        self._txtCost.gameObject:SetActive(flag)
        if (flag) then
            ColorDataManager.UnSetGray(self._imgIcon)
            ColorDataManager.UnSetGray(self._imgNameBg)
            ColorDataManager.UnSetGray(self._imgBg)
        else
            ColorDataManager.SetGray(self._imgIcon)
            ColorDataManager.SetGray(self._imgNameBg)
            ColorDataManager.SetGray(self._imgBg)
        end
    end

end

function CauldronItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickItem = nil;
end

 






