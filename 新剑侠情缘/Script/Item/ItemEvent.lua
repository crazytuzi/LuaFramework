function Item:OnUse(nTemplateId, nId)
    Log("Item:OnUse", tostring(nTemplateId), nId)
    UiNotify.OnNotify(UiNotify.emNOTIFY_ON_USE_ITEM, nTemplateId, nId)
end
