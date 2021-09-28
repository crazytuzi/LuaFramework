require "Core.Module.Common.Panel"

require "Core.Module.XLTInstance.View.item.XLTSaoDangAwardItem"

XLTSaoDangAwardPanel = class("XLTSaoDangAwardPanel", Panel);
function XLTSaoDangAwardPanel:New()
    self = { };
    setmetatable(self, { __index = XLTSaoDangAwardPanel });
    return self
end


function XLTSaoDangAwardPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XLTSaoDangAwardPanel:_InitReference()
    self._txtTipTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTipTitle");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self.awardBt = UIUtil.GetChildByName(self._trsContent, "UIButton", "awardBt");

     self._onClickawardBt = function(go) self:_OnClickawardBt(self) end
    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickawardBt);

    self.awardsPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "awardsPanel");
    self.subPanel = UIUtil.GetChildByName(self.awardsPanel, "Transform", "subPanel");
    self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");

     self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, XLTSaoDangAwardItem);

    MessageManager.AddListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_PROINFOCHANGE, XLTSaoDangAwardPanel.SaodandInfoChange, self);

     XLTInstanceProxy.GetXLTSaoDangProsInfo()

    --[[
    local items = { };
    items[1] = { spId = 408005, num = 2 };
    items[2] = { spId = 402005, num = 2 };
    items[3] = { spId = 402005, num = 2 };
    items[4] = { spId = 402005, num = 2 };
    items[5] = { spId = 402005, num = 2 };
    items[6] = { spId = 402005, num = 2 };
    items[7] = { spId = 402005, num = 2 };
    items[8] = { spId = 402005, num = 2 };
    items[9] = { spId = 402005, num = 2 };
    items[10] = { spId = 402005, num = 2 };
    items[11] = { spId = 402005, num = 2 };

    self:SaodandInfoChange(items);
    ]]
end

function XLTSaoDangAwardPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

--[[
 S <-- 18:09:55.488, 0x0F14, 17, {"items":[{"num":1,"spId":408005},{"num":1,"spId":402005}]}
]]
function XLTSaoDangAwardPanel:SaodandInfoChange(items)

    local len = table.getn(items);

    local res = { };
    res[1] = { };
    res[2] = { };

    for i = 1, len do
        local obj = items[i];
        local proInfo = ProductManager.GetProductInfoById(obj.spId, obj.num);

        local arr;
        if i <= 5 then
            arr = res[1];
            arr[i] = proInfo;

        elseif i > 5 and i <= 10 then

            local index = i - 5;
            arr = res[2];
            arr[index] = proInfo;

        elseif i > 10 and i <= 15 then

            if res[3] == nil then
                res[3] = { };
            end

            local index = i - 10;
            arr = res[3];
            arr[index] = proInfo;

        elseif i > 15 and i <= 20 then

            if res[4] == nil then
                res[4] = { };
            end

            local index = i - 15;
            arr = res[4];
            arr[index] = proInfo;

        end
    end
    -- end for

    ----------------------------------------------------------------------------

    len = table.getn(res);

   
    self.product_phalanx:Build(len, 1, res);

end



function XLTSaoDangAwardPanel:_OnClickawardBt()
  
 XLTInstanceProxy.TryGetXLTSaoDangAwards();
end



function XLTSaoDangAwardPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(XLTInstanceNotes.CLOSE_XLTSAODANGAWARDPANEL);
end

function XLTSaoDangAwardPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function XLTSaoDangAwardPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

     
    UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
     self._onClickawardBt = nil;


end

function XLTSaoDangAwardPanel:_DisposeReference()
    self._btn_close = nil;
    self._txtTipTitle = nil;

    MessageManager.RemoveListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_SAO_DANG_PROINFOCHANGE, XLTSaoDangAwardPanel.SaodandInfoChange);

    if self.product_phalanx ~= nil then
       self.product_phalanx:Dispose();
       self.product_phalanx = nil;
    end

   
    self.awardBt = nil;

     self._onClickawardBt = nil;

    self.awardsPanel = nil;
    self.subPanel = nil;
    self._item_phalanx = nil;


end
