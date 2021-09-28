require "Core.Module.Common.Panel"

require "Core.Module.XMBoss.View.item.XMBossJoinInfosItem"

XMBossJoinInfosPanel = class("XMBossJoinInfosPanel", Panel);
function XMBossJoinInfosPanel:New()
    self = { };
    setmetatable(self, { __index = XMBossJoinInfosPanel });
    return self
end


function XMBossJoinInfosPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XMBossJoinInfosPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._txtTitle2 = UIUtil.GetChildInComponents(txts, "txtTitle2");
    self._txtTitle3 = UIUtil.GetChildInComponents(txts, "txtTitle3");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._trsTitle = UIUtil.GetChildByName(self._trsContent, "Transform", "trsTitle");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self._item_phalanx = UIUtil.GetChildByName(self.mainView, "LuaAsynPhalanx", "listPanel/subPanel/table");


    MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETXMBOSSJOININFOS, XMBossJoinInfosPanel.RDataInHandler, self);

    XMBossProxy.GetXMBossJoinInfos();




    --  测试数据
    --[[
     local dataArr={};
      for i = 1, 10 do
      dataArr[i]={n="sdfe"..i,l=i,f=1545,c=101000};
      end

     self:RDataInHandler({l=dataArr});
     ]]
end

function XMBossJoinInfosPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

--[[
03 参战信息
输出：
l:{[n:玩家呢称，l:玩家等级，f:战斗力，c:职业]}

 S <-- 14:29:46.628, 0x1603, 30, {"l":[{"n":"\u5F6D\u6587\u5BB9","c":104000,"l":48,"f":274031},{"n":"\u9646\u57FA","c":101000,"l":100,"f":489693}]}

]]
function XMBossJoinInfosPanel:RDataInHandler(data)
    local l = data.l;
    self:InitData(l)
end


function XMBossJoinInfosPanel:InitData(dataArr)


    local len = table.getn(dataArr);

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, XMBossJoinInfosItem);
    self.product_phalanx:Build(len, 1, dataArr);



end

function XMBossJoinInfosPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(XMBossNotes.CLOSE_XMBOSSJOININFOSPANEL);
end

function XMBossJoinInfosPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function XMBossJoinInfosPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function XMBossJoinInfosPanel:_DisposeReference()

    if self.product_phalanx ~= nil then
        self.product_phalanx:Dispose();
        self.product_phalanx = nil;
    end


    MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETXMBOSSJOININFOS, XMBossJoinInfosPanel.RDataInHandler);

    self._btn_close = nil;
    self._txtTitle1 = nil;
    self._txtTitle2 = nil;
    self._txtTitle3 = nil;
    self._trsTitle = nil;

    

    self.mainView = nil;

    self._item_phalanx = nil;


end
