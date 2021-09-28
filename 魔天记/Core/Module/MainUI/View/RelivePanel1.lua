require "Core.Module.Common.Panel"

RelivePanel1 = class("RelivePanel1", Panel);
 
function RelivePanel1:IsPopup()
    return false
end

function RelivePanel1:New()
    self = { };
    setmetatable(self, { __index = RelivePanel1 });
    return self
end


function RelivePanel1:_Init()
    self:_InitReference();
    self:_InitListener();
end

function RelivePanel1:_InitReference()
    self._txtTime = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTime")
    self._txtCost = UIUtil.GetChildByName(self._trsContent, "UILabel", "btnRelive/txtCount")
    self._imgIcon = UIUtil.GetChildByName(self._trsContent, "UISprite", "btnRelive/icon")
    self._timer = Timer.New( function() RelivePanel1._OnTimerHandler(self) end, 1, -1, false);
    self._btnRelive = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnRelive")
end

function RelivePanel1:_InitListener()
    self._onClickBtnRelive = function(go) self:_OnClickBtnRelive(self) end
    UIUtil.GetComponent(self._btnRelive, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnRelive);
end 

function RelivePanel1:_OnClickBtnRelive()
    MainUIProxy.SendRelive(1)
end

function RelivePanel1:_Dispose()
    if (self._timer) then
        self._timer:Stop()
        self._timer = nil
    end
    self:_DisposeListener();
    self:_DisposeReference();

end

function RelivePanel1:_DisposeListener()
    UIUtil.GetComponent(self._btnRelive, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnRelive = nil;
end

function RelivePanel1:_DisposeReference()
    self._btnRelive = nil;
    self._imgIcon = nil
end

function RelivePanel1:UpdateRelivePanel(data, config)
    self._time = config.time
    if (data) then
        self._txtTime.text = tostring(self._time)
        if (BackpackDataManager.GetProductTotalNumBySpid(config.relive_item) > 0) then
            self._txtCost.text = "1"
            local item = ProductManager.GetProductById(config.relive_item)
            if (item) then
                ProductManager.SetIconSprite(self._imgIcon, item.icon_id)
            end
        else
            self._txtCost.text = config.cost
            ProductManager.SetIconSprite(self._imgIcon, SpecialProductId.BGold)
        end
    end
    self._timer:Stop()
    self._timer:Start();
end

function RelivePanel1:_OnTimerHandler()
    self._time = self._time - 1
    self._txtTime.text = tostring(self._time)
    if (self._time <= 0) then
        self._timer:Stop()
        MainUIProxy.SendRelive(0)
        --        self:_OnClickBtnReliveInCity()
    end
end