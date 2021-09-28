require "Core.Module.Common.PropsItem"
--装备宝石容器
EquipGemItem = class("EquipGemItem", PropsItem);

function EquipGemItem:_InitReference()
    self._icoUpdate = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoUpdate");
    if(self._icoUpdate)then
        self._icoUpdate.gameObject:SetActive(false);
    end

    self._vipLabel = UIUtil.GetChildByName(self.gameObject, "UILabel", "vipLabel");
    if self._vipLabel then
        self._vipLabel.gameObject:SetActive(false);
    end
end

function EquipGemItem:_Dispose()
   self._onClickDelegate = nil;
end

function EquipGemItem:UpdateItem(data) 
    self.data = data;
    self:UpdateDisplay();
    self:UpdateIcon();
end

function EquipGemItem:UpdateIcon()
    if (self._icoUpdate) then
        if self.data ~= nil then
            local enough = GemDataManager.CanUpgrade(self.data.spId) or GemDataManager.CanImprove(self.data.spId);
            if enough then
                self._icoUpdate.gameObject:SetActive(true);
            else
                self._icoUpdate.gameObject:SetActive(false);
            end
        else
            self._icoUpdate.gameObject:SetActive(false);
        end
    end
end

function EquipGemItem:IsLock()
    return self.lock;
end

function EquipGemItem:_OnClick()
    if self._onClickDelegate ~= nil then
        self._onClickDelegate(self);
    else
        MessageManager.Dispatch(EquipNotes, EquipNotes.MESSAGE_GEM_SELECT, self);    
    end
end

function EquipGemItem:SetOnClickHandler(del)
    self._onClickDelegate = del;
end

local vip = string.split(LanguageMgr.Get("equip/gem/vip"), ",");
function EquipGemItem:SetLock(v)
    self.super.SetLock(self, v);
    if self._vipLabel then
        self._vipLabel.gameObject:SetActive(v);
        if v then
            self._vipLabel.text = LanguageMgr.Get("equip/gem/vipDesc", {vip = vip[self.pos]});
        else
            self._vipLabel.text = "";
        end
    end
end
