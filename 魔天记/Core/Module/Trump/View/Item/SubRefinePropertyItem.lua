require "Core.Module.Common.UIItem"
SubRefinePropertyItem = class("SubRefinePropertyItem", UIItem);
local maxDes = LanguageMgr.Get("trump/trumpPanel/unActiveRefineDes")
function SubRefinePropertyItem:New()
    self = { };
    setmetatable(self, { __index = SubRefinePropertyItem });
    return self
end

function SubRefinePropertyItem:_Init()
    self:_InitReference();
    self:UpdateItem(self.data)
end

function SubRefinePropertyItem:_InitReference()
    self._txtCur = UIUtil.GetChildByName(self.transform, "UILabel", "txtCur")
    self._txtNext = UIUtil.GetChildByName(self.transform, "UILabel", "txtNext")
    self._txtDes = UIUtil.GetChildByName(self.transform, "UILabel", "content")
    self._goUp = UIUtil.GetChildByName(self.transform, "up").gameObject
end

function SubRefinePropertyItem:UpdateItem(data)
    self.data = data
    if (self.data) then
        local green = ColorDataManager.Get_green()
        self._txtDes.text = self.data.des
        local sign = self.data.sign or ""
        if (self.data.isActive ~= nil and self.data.isActive == false) then
            self._txtCur.text = ColorDataManager.GetColorText(green, self.data.property .. sign) .. maxDes
            self._txtNext.text = ""
            self._goUp:SetActive(false)
        else
            self._txtCur.text = ColorDataManager.GetColorText(green, self.data.property .. sign)

            self._goUp:SetActive(self.data.nextProperty ~= nil)
            if (self.data.nextProperty) then
                self._txtNext.text = ColorDataManager.GetColorText(green, self.data.nextProperty .. sign)
            else
                self._txtNext.text = ""
            end
        end

    end
end

function SubRefinePropertyItem:_Dispose()

end