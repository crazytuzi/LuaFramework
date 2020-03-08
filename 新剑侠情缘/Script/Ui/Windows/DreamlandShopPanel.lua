
local tbUi = Ui:CreateClass("DreamlandShopPanel");


function tbUi:OnOpen(tbServerWares, nNpcId )
    self.tbServerWares = tbServerWares;
    self.nDifferNpcId = nNpcId
    self.nSelectItemId = nil;
    self.pPanel:Toggle_SetChecked("Toggle", true)
    self:UpdateList()
end

function tbUi:UpdateList()
    local tbView = self:GetCurShopWares();

    local fnOnClick = function (buttonObj)
        self.nSelectItemId = buttonObj.tbData.nTemplateId
        buttonObj.pPanel:Toggle_SetChecked("Main", true);
        Ui:OpenWindow("MarketStallBuyPanel", buttonObj.tbData)
    end

    local fnSetItem = function (itemObj, index)
        local tbData = tbView[index]
        itemObj.tbData = tbData
        itemObj.pPanel:Label_SetText("TxtPrice", tbData.nPrice)
        local tbBaseInfo = KItem.GetItemBaseProp(tbData.nTemplateId);
        itemObj.pPanel:Label_SetText("TxtItemName", tbBaseInfo.szName)
        
        itemObj.pPanel:Toggle_SetChecked("Main", self.nSelectItemId == tbData.nTemplateId);

        local tbControls = {};
        local bOutOfStock = false
        if tbData.nCount then
            tbControls.bShowCDLayer = tbData.nCount == 0;
            bOutOfStock = tbData.nCount == 0;
        else
            tbControls.bShowCDLayer = false;
        end
        itemObj.Item:SetItemByTemplate(tbData.nTemplateId, tbData.nCount, me.nFaction, nil, tbControls);
        itemObj.Item.fnClick = itemObj.Item.DefaultClick
        if bOutOfStock then
            itemObj.pPanel:SetActive("TagDT", true)
            itemObj.pPanel:Sprite_SetSprite("TagDT", "OutOfStock")   
        else
            itemObj.pPanel:SetActive("TagDT", false)
        end
        itemObj.pPanel.OnTouchEvent = fnOnClick;
    end

    self.ScrollView:Update(tbView, fnSetItem)
end

function tbUi:GetCurShopWares()
    local tbWares = {}
    local bChecked = self.pPanel:Toggle_GetChecked("Toggle")
    for nTemplateId, nLeftCount in pairs(self.tbServerWares) do
        local nShowItemId = nTemplateId
        local nClientShowBook = InDifferBattle:GetRandSkillBookId(nTemplateId, me.nFaction)
        if nClientShowBook then
            nShowItemId = nClientShowBook;
        end
        if not bChecked or Item:IsUsableItem(me, nShowItemId) then
            local tbSetting = InDifferBattle.tbDefine.tbSellWareSetting[nTemplateId] 
                table.insert(tbWares, {
                        nTemplateId = nShowItemId, 
                        nPrice = tbSetting.nPrice,
                        szMoneyType = InDifferBattle.tbDefine.szMonoeyType,
                        nCount = nLeftCount,
                        nDifferNpcId = self.nDifferNpcId,
                        bInDifferBattle = true,
                        nSort = tbSetting.nSort,
                        });
        end
    end

    table.sort( tbWares, function (a,b)
        return a.nSort < b.nSort
    end )

    return tbWares;
end

function tbUi:SyncShopWare(tbServerWares, nNpcId)
    self.tbServerWares = tbServerWares;
    self.nDifferNpcId = nNpcId
    self:UpdateList()
end


tbUi.tbOnClick = {}

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi.tbOnClick:Toggle()
    self:UpdateList();
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_SHOP_WARE,      self.SyncShopWare},
    };

    return tbRegEvent;
end

