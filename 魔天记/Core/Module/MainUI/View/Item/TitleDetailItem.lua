require "Core.Module.Common.UIItem"
require "Core.Module.Common.TitleItem"


TitleDetailItem = UIItem:New();
local equip = LanguageMgr.Get("TitleDetailItem/equip")
local unequip = LanguageMgr.Get("TitleDetailItem/unequip")
 
function TitleDetailItem:_Init()
    --    self._txtName = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtName")
    self._btnEquip = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnEquip")
    local txts = UIUtil.GetComponentsInChildren(self.gameObject, "UILabel")
    self._txtEquip = UIUtil.GetChildInComponents(txts, "txtEquip")
    self._txtTime = UIUtil.GetChildInComponents(txts, "txtTime")
    self._txtProperty = UIUtil.GetChildInComponents(txts, "txtProperty1")
    self._txtProperty2 = UIUtil.GetChildInComponents(txts, "txtProperty2")

    self._txtCondition = UIUtil.GetChildInComponents(txts, "txtCondition")
    self._titleParent = UIUtil.GetChildByName(self.gameObject, "titleItem")
    self._goEquipTag = UIUtil.GetChildByName(self.gameObject, "equipTarget").gameObject
    self._goNotGet = UIUtil.GetChildByName(self.gameObject, "target").gameObject
    self._titleItem = TitleItem:New()
    self._titleItem:Init(self._titleParent)
    self:UpdateItem(self.data);
    self._onBtnClick = function(go) self:_OnBtnClick() end
    UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onBtnClick);

end


function TitleDetailItem:_Dispose()
    UIUtil.GetComponent(self._btnEquip, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onBtnClick = nil
    self._titleItem:Dispose()
    self._titleItem = nil
end 

function TitleDetailItem:UpdateItem(data)
    self.data = data
    if self.data then
        self._titleItem:UpdateItem(self.data)
        if (self.data.state == 1) then
            self._goNotGet:SetActive(false)
            self._btnEquip.gameObject:SetActive(true)
            if (self.data.limitTime == 0) then
                self._txtTime.text = TimeTranslate(self.data.eff_time)
            else
                self._txtTime.text = os.date('%Y-%m-%d %H:%M', self.data.limitTime); 
            end
        else
            self._goNotGet:SetActive(true)
            self._btnEquip.gameObject:SetActive(false)
            self._txtTime.text = TimeTranslate(self.data.eff_time)
        end

        local isEquip =(self.data.id == TitleManager.GetCurrentEquipTitleId())
        self._txtCondition.text = self.data.des
        self._goEquipTag:SetActive(isEquip)
        self._txtEquip.text = isEquip and unequip or equip
        if (self.data.attr) then
            local p = self.data.attr:GetPropertyAndDes()[1]
            local sign = p.sign or ""
            self._txtProperty.text = p.des .. "+" .. p.property .. sign

            p = self.data.attr:GetPropertyAndDes()[2]
            if (p) then
                sign = p.sign or ""
                self._txtProperty2.text = p.des .. "+" .. p.property .. sign
            else
                self._txtProperty2.text = ""
            end 
        end
    end
end

function TitleDetailItem:_OnBtnClick()
    if (self.data.id == TitleManager.GetCurrentEquipTitleId()) then
        MainUIProxy.SendChangeTitle(0)
    else
        MainUIProxy.SendChangeTitle(self.data.id)
    end

end

 