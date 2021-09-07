-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
-- endregion
BackpackSelectGiftItem = BackpackSelectGiftItem or BaseClass()
function BackpackSelectGiftItem:__init(origin_item)
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(true)

    self.SlotCon = self.transform:Find("SlotCon");
    self.TxtTitle = self.transform:Find("TxtTitle"):GetComponent(Text);
    self.Slot = ItemSlot.New();
    self.extra = { inbag = false, nobutton = true, noselect = true }
    UIUtils.AddUIChild(self.SlotCon.gameObject, self.Slot.gameObject)

    self.BaseData = nil;
    self.BtnSelf = self.SlotCon:GetComponent(Button);
    self.ImgSelect = self.transform:Find("ImgSelect");
end

function BackpackSelectGiftItem:__delete()
    if self.Slot ~= nil then
        self.Slot:DeleteMe()
        self.Slot = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function BackpackSelectGiftItem:SetData(data)
    self.BaseData = data
    if self.BaseData == nil then
        return
    end
    self.Slot:SetAll(self.BaseData, self.extra);
    self.Slot:ShowSelect(false);
    self:SlotSelect(false);
end

function BackpackSelectGiftItem:SlotSelect(bool)
    self.ImgSelect.gameObject:SetActive(bool)
end
