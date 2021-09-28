require "Core.Module.Pattern.Mediator"
require "Core.Module.Common.ResID"
require "Core.Module.ProductTip.ProductTipNotes"

require "Core.Module.ProductTip.View.EquipTipPanel"
require "Core.Module.ProductTip.View.SampleProductTipPanel"
require "Core.Module.ProductTip.View.ProductUsePanel"
require "Core.Module.ProductTip.View.ProductSellPanel"
require "Core.Module.ProductTip.View.EquipComparisonTipPanel"

ProductTipMediator = Mediator:New();
function ProductTipMediator:OnRegister()

end

function ProductTipMediator:_ListNotificationInterests()
    return {
        [1] = ProductTipNotes.SHOW_EQUIPTIPPANEL,
        [2] = ProductTipNotes.CLOSE_EQUIPTIPPANEL,
        [3] = ProductTipNotes.SHOW_SAMPLEPRODUCTTIPPANEL,
        [4] = ProductTipNotes.CLOSE_SAMPLEPRODUCTTIPPANEL,
        [5] = ProductTipNotes.SHOW_PRODUCTUSEPANEL,
        [6] = ProductTipNotes.CLOSE_PRODUCTUSEPANELL,
        [7] = ProductTipNotes.SHOW_PRODUCTSELLPANEL,
        [8] = ProductTipNotes.CLOSE_PRODUCTSELLPANELL,
        [9] = ProductTipNotes.SHOW_BY_PRODUCT,

        [10] = ProductTipNotes.SHOW_EQUIPCOMPARISONTIPPANEL,
        [11] = ProductTipNotes.CLOSE_EQUIPCOMPARISONTIPPANEL,

    };
end

function ProductTipMediator:_HandleNotification(notification)
    if notification:GetName() == ProductTipNotes.SHOW_BY_PRODUCT then
       -- log(ProductTipNotes.SHOW_BY_PRODUCT)
        local data = notification:GetBody();
        self:ShowTipByProductTcrl(data);
    elseif notification:GetName() == ProductTipNotes.SHOW_EQUIPTIPPANEL then

    elseif notification:GetName() == ProductTipNotes.CLOSE_EQUIPTIPPANEL then
        if (self._equipTipPanel ~= nil) then
            PanelManager.RecyclePanel(self._equipTipPanel)
            self._equipTipPanel = nil
        end
    elseif notification:GetName() == ProductTipNotes.SHOW_SAMPLEPRODUCTTIPPANEL then

    elseif notification:GetName() == ProductTipNotes.CLOSE_SAMPLEPRODUCTTIPPANEL then
        if (self._sampleProductTipPanel ~= nil) then
            PanelManager.RecyclePanel(self._sampleProductTipPanel)
            self._sampleProductTipPanel = nil
        end
    elseif notification:GetName() == ProductTipNotes.SHOW_PRODUCTUSEPANEL then

        if (self._productUsePanel == nil) then
            self._productUsePanel = PanelManager.BuildPanel(ResID.UI_PRODUCTUSEPANEL, ProductUsePanel);
        end
        local pinfo = notification:GetBody();
        self._productUsePanel:SetData(pinfo);

    elseif notification:GetName() == ProductTipNotes.CLOSE_PRODUCTUSEPANELL then
        if (self._productUsePanel ~= nil) then
            PanelManager.RecyclePanel(self._productUsePanel)
            self._productUsePanel = nil
        end

    elseif notification:GetName() == ProductTipNotes.SHOW_PRODUCTSELLPANEL then

        if (self._productSellPanel == nil) then
            self._productSellPanel = PanelManager.BuildPanel(ResID.UI_PRODUCTSELLPANEL, ProductSellPanel);
        end
        local pinfo = notification:GetBody();
        self._productSellPanel:SetData(pinfo);

    elseif notification:GetName() == ProductTipNotes.CLOSE_PRODUCTSELLPANELL then

        if (self._productSellPanel ~= nil) then
            PanelManager.RecyclePanel(self._productSellPanel)
            self._productSellPanel = nil
        end

        ------------------------------------------------------------------------------------------------------
    elseif notification:GetName() == ProductTipNotes.SHOW_EQUIPCOMPARISONTIPPANEL then



    elseif notification:GetName() == ProductTipNotes.CLOSE_EQUIPCOMPARISONTIPPANEL then
        if (self._equipComparisonTipPanel ~= nil) then
            PanelManager.RecyclePanel(self._equipComparisonTipPanel)
            self._equipComparisonTipPanel = nil
        end
    end
end


function ProductTipMediator:OnRemove()

end


function ProductTipMediator:ShowTipByProductTcrl(data)

    local _productInfo = data.info;
    local _type = data.type;
    local ctr_tg = data.ctr_tg;
    local _equipSlotInfo = data.exData;
    local _productType = _productInfo:GetType();

    if _productType == ProductManager.type_1 then
        -- 装备
        local st = _productInfo.st;

        if st == ProductManager.ST_TYPE_IN_BACKPACK or st == ProductManager.ST_TYPE_IN_OTHER then
            -- if st == ProductManager.ST_TYPE_IN_BACKPACK  then
            -- 获取装备栏对应 位置是否有装备， 如果有的话， 那么就显示 装备对照界面
            local kind = _productInfo:GetKind();

            local eqInEqbag = EquipDataManager.GetProductByKind(kind);

            if eqInEqbag ~= nil then

                local cer1 = tonumber(_productInfo:GetCareer());
                local cer2 = tonumber(eqInEqbag:GetCareer());

                if cer1 == cer2 then
                    if (self._equipComparisonTipPanel == nil) then
                        self._equipComparisonTipPanel = PanelManager.BuildPanel(ResID.UI_EQUIPCOMPARISONTIPPANEL, EquipComparisonTipPanel);
                    end

                    self._equipComparisonTipPanel:SetData(eqInEqbag, _productInfo, st == ProductManager.ST_TYPE_IN_OTHER);
                else
                    if (self._equipTipPanel == nil) then
                        self._equipTipPanel = PanelManager.BuildPanel(ResID.UI_EQUIPTIPPANEL, EquipTipPanel);
                    end
                    self._equipTipPanel:SetData(_type, _productInfo, _equipSlotInfo, st == ProductManager.ST_TYPE_IN_OTHER);
                end


            else

                if (self._equipTipPanel == nil) then
                    self._equipTipPanel = PanelManager.BuildPanel(ResID.UI_EQUIPTIPPANEL, EquipTipPanel);
                end
                self._equipTipPanel:SetData(_type, _productInfo, _equipSlotInfo, st == ProductManager.ST_TYPE_IN_OTHER);

            end

        else

            if (self._equipTipPanel == nil) then
                self._equipTipPanel = PanelManager.BuildPanel(ResID.UI_EQUIPTIPPANEL, EquipTipPanel);
            end
            self._equipTipPanel:SetData(_type, _productInfo, _equipSlotInfo, st == ProductManager.ST_TYPE_IN_OTHER);

        end
    else
        if (self._sampleProductTipPanel == nil) then
            self._sampleProductTipPanel = PanelManager.BuildPanel(ResID.UI_SAMPLEPRODUCTTIPPANEL, SampleProductTipPanel);
        end
        self._sampleProductTipPanel:SetData(_type, _productInfo);
    end
end
