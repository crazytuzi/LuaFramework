require "Core.Module.Common.UIItem"
require "Core.Module.Common.PropsItem";

GemCompSubItem = UIItem:New();
 
function GemCompSubItem:_Init()
    self._txtTitle = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtTitle");
    self._txtDesc = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtDesc");
    
    self._icoGemTr = UIUtil.GetChildByName(self.gameObject, "Transform", "icoGem");
    self._icoSelect = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoSelect");
    self._icoSelect.gameObject:SetActive(false);

    self._icon = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon");
    self._icon_quality = UIUtil.GetChildByName(self.gameObject, "UISprite", "icon_quality");

    self._onClick = function(go) self:OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick); 
    if(self.data) then self:UpdateItem(self.data); end
end

function GemCompSubItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;
end

function GemCompSubItem:UpdateItem(data)
    self.data = data;
    if data ~= nil then
        self.gameObject.name = self.data.id;
        self._txtTitle.text = data.name;
        if data ~= nil then
            local d = ProductInfo:New();
            d:Init({spId = data.id, am = 1});

            local quality = d:GetQuality();
            ProductManager.SetIconSprite(self._icon, d:GetIcon_id());
            self._icon_quality.color = ColorDataManager.GetColorByQuality(quality);

            local needId = GemDataManager.GetGemsId(data.kind, data.lev - 1)
            local count = GemDataManager.GetGemNumById(needId);
            if(count >= 3) then
                self._txtDesc.text = LanguageMgr.Get("equip/gem/comp/1");
            else
                self._txtDesc.text = LanguageMgr.Get("equip/gem/comp/0");
            end
        end
    else
        self._txtTitle.text = "";
        self._txtDesc.text = "";
    end
end

function GemCompSubItem:OnClick()
    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_GEM_COMP_ITEM, self.data);
end

function GemCompSubItem:UpdateSelected(data)
    local selected = false;
    if (self.data ~= nil and data) then
         selected = self.data.id == data.id;
    end
    self._icoSelect.gameObject:SetActive(selected);
end