require "Core.Module.Common.Panel"

require "Core.Module.XLTInstance.View.item.ChuangGuanAwardItem"

XLTChuangGuanAwardPanel = class("XLTChuangGuanAwardPanel", Panel);
function XLTChuangGuanAwardPanel:New()
    self = { };
    setmetatable(self, { __index = XLTChuangGuanAwardPanel });
    return self
end


function XLTChuangGuanAwardPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XLTChuangGuanAwardPanel:_InitReference()
    self._txtTipTitle = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtTipTitle");

    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");

    self.awardsPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "awardsPanel");
    self.subPanel = UIUtil.GetChildByName(self.awardsPanel, "Transform", "subPanel");

    self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");

    self:InitData()

    MessageManager.AddListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_CHUANGGUAN_AWARDLOG, XLTChuangGuanAwardPanel.ChuanGuanAwardLog, self);


    
    self:ChuanGuanAwardLog(XLTInstanceProxy.chuangGuanAwardLog);
end

function XLTChuangGuanAwardPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end



function XLTChuangGuanAwardPanel:InitData()

    local awardList = InstanceDataManager:GetXLTFirstAwardArr();
    local len = table.getn(awardList);

   

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, ChuangGuanAwardItem);
    self.product_phalanx:Build(len, 1, awardList);



end

function XLTChuangGuanAwardPanel:ChuanGuanAwardLog(data)
   
   local l=data.l;
    local items = self.product_phalanx._items;
    local len = table.getn(items);
   
    for i = 1, len do
        items[i].itemLogic:SetLogData(l);
    end
end


function XLTChuangGuanAwardPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(XLTInstanceNotes.CLOSE_XLTCHUANGGUANAWARDPANEL);
end

function XLTChuangGuanAwardPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function XLTChuangGuanAwardPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function XLTChuangGuanAwardPanel:_DisposeReference()
    self._btn_close = nil;
    self._txtTipTitle = nil;

    MessageManager.RemoveListener(XLTInstanceProxy, XLTInstanceProxy.MESSAGE_CHUANGGUAN_AWARDLOG, XLTChuangGuanAwardPanel.ChuanGuanAwardLog);

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;

    self.awardsPanel = nil;
    self.subPanel = nil;

    self._item_phalanx = nil;

end
