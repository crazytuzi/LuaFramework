require "Core.Module.Common.UIComponent"

ArathiAwardItem = class("ArathiAwardItem", UIComponent);

function ArathiAwardItem:New(transform)
    self = { };
    setmetatable(self, { __index = ArathiAwardItem });
    if (transform) then
        self:Init(transform);
    end
    return self
end

function ArathiAwardItem:SetProductId(id, num)
    self._info = ProductManager.GetProductInfoById(id)
    self._num = num;
    self:_Refresh();
end

function ArathiAwardItem:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ArathiAwardItem:AddClickListener(owner, handler)
    self._owner = owner;
    self._handler = handler;
end


function ArathiAwardItem:_InitReference()
    self._imgQuality = UIUtil.GetComponent(self._transform, "UISprite")
    self._imgIcon = UIUtil.GetChildByName(self._transform, "UISprite", "imgIcon");
    self._txtNum = UIUtil.GetChildByName(self._transform, "UILabel", "txtNum");
    self:_Refresh();
end

function ArathiAwardItem:_Refresh()
    if (self._info) then
        if (self._imgQuality) then
            self._imgQuality.color = ColorDataManager.GetColorByQuality(self._info.baseData.quality);
        end
        if (self._txtNum) then
            if (self._num) then
                self._txtNum.text = "x" .. self._num;
            else
                self._txtNum.text = "";
            end
        end
        ProductManager.SetIconSprite(self._imgIcon, self._info.baseData.icon_id)
        self._gameObject:SetActive(true)
    else
        self._gameObject:SetActive(false)
    end
end

function ArathiAwardItem:_InitListener()
    self._onClickHandler = function(go) self:_OnClickHandler(self) end
    UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickHandler);
end

function ArathiAwardItem:_OnClickHandler()
    if (self._info) then
        -- ModuleManager.SendNotification(ProductTipNotes.SHOW_BY_PRODUCT, { info = self._info, type = ProductCtrl.TYPE_FROM_OTHER });		
        ProductCtrl.ShowProductTip(self._info.spId, ProductCtrl.TYPE_FROM_OTHER, 1);
    end
end
  
function ArathiAwardItem:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ArathiAwardItem:_DisposeListener()
    UIUtil.GetComponent(self._gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickHandler = nil
    self._owner = nil;
    self._handler = nil;
end

function ArathiAwardItem:_DisposeReference()
    self._imgQuality = nil;
    self._imgIcon = nil;
    self._txtNum = nil;
end