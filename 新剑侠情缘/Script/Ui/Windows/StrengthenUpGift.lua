local tbUi = Ui:CreateClass("StrengthenUpGift")

function tbUi:OnOpen()
    self:Update();
end


function tbUi:Update()
    local tbProds = Recharge:GetCanBuyDirectEnhanceProds()

    for i=1,3 do
        local v = tbProds[i]
        if v then
            local tbLimitInfo = Recharge.tbDirectEnhanceSetting[v.nGroupIndex]
            self.pPanel:SetActive("Package" .. i, true)
            self.pPanel:Label_SetText("PackageTitle" .. i, "全身强化" .. tbLimitInfo.nEnhanceLevel)
            self.pPanel:Label_SetText("PackageTxt" .. i, string.format("立即全身强化至%d级\n%s", tbLimitInfo.nEnhanceLevel, v.szNoromalDesc))
            self.pPanel:Button_SetText("BtnBuy" .. i, v.szFirstDesc)
            self["itemframe" .. i]:SetItemByTemplate(v.tbAward[1][2], 1)

        else
            self.pPanel:SetActive("Package" .. i, false)
        end
    end
end

tbUi.tbOnClick = {};

function tbUi:OnClickProd(nIndex)
   local tbProds = Recharge:GetCanBuyDirectEnhanceProds()
   local v = tbProds[nIndex]
   if not v then
        me.CenterMsg("无效的购买项")
        return
    end
   Recharge:RequestBuyDirectEnhance(v)
end

for i=1,3 do
    tbUi.tbOnClick["BtnBuy" .. i] = function (self)
        self:OnClickProd(i)
    end
end