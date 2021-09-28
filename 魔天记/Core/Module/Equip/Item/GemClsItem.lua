require "Core.Module.Common.UIItem"
require "Core.Module.Equip.Item.GemCompSubItem"

GemClsItem = UIItem:New();

function GemClsItem:_Init()
    self._txtTitle = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtTitle");
    self._txtNum = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtNum");
    self._icoFlag = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoFlag");

    self._phalanxTr = UIUtil.GetChildByName(self.transform, "LuaAsynPhalanx", "gem_phalanx", true);
    self._phalanx = Phalanx:New();
    self._phalanx:Init(self._phalanxTr, GemCompSubItem);

    self.show = false;
    self._gemCount = 0;

    self._onClick = function(go) self:_OnClick(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick); 

    --self:UpdateItem(self.data);
end

function GemClsItem:_Dispose()
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClick = nil;

    self._phalanx:Dispose();
    self._phalanx = nil;
end

function GemClsItem:UpdateItem(cfgs, data, showNum)
    self.data = data;
    self.allGems = cfgs;
    self.showNum = showNum;

    --self:ReCal();
    self:UpdateDisplay();
end

function GemClsItem:UpdateDisplay()
    
    if self.show then
        self._phalanxTr.gameObject:SetActive(true);
        
        local gems = self.allGems;
        local count = table.getn(gems);
        self._phalanx:Build(count, 1, gems);
        self._gemCount = count;
    else
        self._phalanxTr.gameObject:SetActive(false);
        self._gemCount = 0; 
    end

    if self.showNum and self.showNum > 0 then
        self._txtNum.text = "(" .. self.showNum .. ")";
    else
        self._txtNum.text = "";
    end

    self._icoFlag.alpha = self.show and 1 or 0;

    self._txtTitle.text = LanguageMgr.Get("ProductInfo/name_kind_2_"..self.data);
end

function GemClsItem:UpdateToggle(data)
    if self.data == data then
        self.show = not self.show;
    else
        self.show = false;
    end
    self:UpdateDisplay();
end

function GemClsItem:_OnClick()
    MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_GEM_COMP_CLS, self.data);
end

function GemClsItem:UpdateSelected(data)
    local items = self._phalanx:GetItems();
    local count = table.getCount(items);
    for k, v in pairs(items) do
        v.itemLogic:UpdateSelected(data);
    end
end

function GemClsItem:GetItems()
    return self._phalanx:GetItems();
end