--require "Core.Module.Common.UIItem"
require "Core.Module.Common.BaseSelectItem"

SubFusionSelectItem = class("SubFusionSelectItem", BaseSelectItem);

-- local selectDes =
-- {
--    [0] = LanguageMgr.Get("trump/SubFusionSelectItem/selectDes0"),
--    [1] = LanguageMgr.Get("trump/SubFusionSelectItem/selectDes1"),
--    [2] = LanguageMgr.Get("trump/SubFusionSelectItem/selectDes2"),
--    [3] = LanguageMgr.Get("trump/SubFusionSelectItem/selectDes3"),
--    [4] = LanguageMgr.Get("trump/SubFusionSelectItem/selectDes4"),
-- }

-- local selectTextColor =
-- {
--    [0] = ColorDataManager.Get_white();
--    [1] = ColorDataManager.Get_green();
--    [2] = ColorDataManager.Get_blue();
--    [3] = ColorDataManager.Get_purple();
--    [4] = ColorDataManager.Get_golden();
-- } 

function SubFusionSelectItem:New()
    self = { };
    setmetatable(self, { __index = SubFusionSelectItem });
    return self
end


-- function SubFusionSelectItem:_Init()
--    self:_InitReference();
--    self:UpdateItem(self.data)
-- end

-- function SubFusionSelectItem:_InitReference()

--    self._txtDes = UIUtil.GetChildByName(self.transform, "UILabel", "Label")
--    self._toggle = UIUtil.GetComponent(self.transform, "UIToggle")

--    self._onClickItem = function(go) self:_OnClickItem(self) end
--    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickItem);
-- end 

function SubFusionSelectItem:_OnClickItem()
    if self._toggle.value then
        TrumpProxy.SetCurFusionPanelSelectQc(self.data)
    else
        TrumpProxy.SetCurFusionPanelSelectQc(-1)
    end
    ModuleManager.SendNotification(TrumpNotes.SET_ACTIVESELECT_PANEL)
end

-- function SubFusionSelectItem:UpdateItem(data)
--    if (data == nil) then return end
--    self.data = data
--    self._txtDes.text = selectDes[data]
--    self._txtDes.color = selectTextColor[data]
-- end

-- function SubFusionSelectItem:SetToggleValue(v)
--    self._toggle.value = v
-- end

----function SubFusionSelectItem:UpdateColliderEnable()
----    self._collider.enabled =(self.data.quality <= TrumpManager.GetNextQc())
----end

-- function SubFusionSelectItem:_Dispose()
--    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
--    self._onClickItem = nil;
-- end

 






