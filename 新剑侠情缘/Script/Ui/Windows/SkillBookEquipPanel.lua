local tbUi = Ui:CreateClass("SkillBookEquipPanel");
tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow("SkillBookEquipPanel");
end

function tbUi:OnScreenClick()
    Ui:CloseWindow("SkillBookEquipPanel");
end

function tbUi.tbOnClick:BtnEquip()
    if not self.nSelectItemID or not self.nItemPos then
        me.CenterMsg("请选择装备");
        return;
    end

    RemoteServer.UseEquip(self.nSelectItemID, self.nItemPos);
    Ui:CloseWindow("SkillBookEquipPanel");
end

tbUi.tbShowItemClass = 
{
    ["SkillBook"] = function (self)

        local tbBook = Item:GetClass("SkillBook");
        local funSort = function (pEquip1, pEquip2)
            local nBookLevel = pEquip1.GetIntValue(tbBook.nSaveBookLevel);
            local nSkillLevel = pEquip1.GetIntValue(tbBook.nSaveSkillLevel);
            local nValue1 = nBookLevel * 1000 + nSkillLevel;
            nBookLevel = pEquip2.GetIntValue(tbBook.nSaveBookLevel);
            nSkillLevel = pEquip2.GetIntValue(tbBook.nSaveSkillLevel); 
            local nValue2 = nBookLevel * 1000 + nSkillLevel;
            return nValue1 > nValue2;
        end

        local tbAllItem = me.FindItemInBag("SkillBook");
        local tbSelectIteam = {};
        local nItemPos = self.nItemPos;
        if not nItemPos then
            nItemPos = tbBook:FinEmptyHole(me);
        end
            
        for _, pItem in ipairs(tbAllItem) do
            local bRet = tbBook:CheckUseEquip(me, pItem, nItemPos);
            if me.nLevel >= pItem.nUseLevel and bRet then
                table.insert(tbSelectIteam, pItem);
            end
        end
        
        table.sort(tbSelectIteam, funSort);
        return  tbSelectIteam;
    end
};

function tbUi:OnOpen(szItemClass, nItemPos)
    self.szItemClass = szItemClass;
    self.nItemPos    = nItemPos;
    if not self.szItemClass then
        return;
    end

    self:UpdateInfo();
end

function tbUi:UpdateInfo()
    local tbAllItem = me.FindItemInBag(self.szItemClass);
    if tbUi.tbShowItemClass[self.szItemClass] then
        tbAllItem = tbUi.tbShowItemClass[self.szItemClass](self);
    end

    self.nSelectItemID = nil;
    local tbAllItemID = {};
    for nI, pItem in ipairs(tbAllItem) do
        table.insert(tbAllItemID, pItem.dwId);
    end    

    local fnSetItem = function(tbItemObj, nIndex)
        local nItemID = tbAllItemID[nIndex];
        local pItem = me.GetItemInBag(nItemID);
        if pItem then
            tbItemObj.pPanel:Label_SetText("SkillBookName", pItem.szName);
            tbItemObj.Item:SetItem(nItemID);
            tbItemObj.Item.fnClick =  tbItemObj.Item.DefaultClick;
        else
            tbItemObj.pPanel:Label_SetText("SkillBookName", "");
            tbItemObj.Item:Clear();
        end 
        tbItemObj.pPanel:Button_SetCheck("Main", false);
        tbItemObj.pPanel.OnTouchEvent = function ()
            self.nSelectItemID = nItemID;
            tbItemObj.pPanel:Button_SetCheck("Main", true);
        end;   
    end

    self.ScrollView:Update(#tbAllItem, fnSetItem);
end