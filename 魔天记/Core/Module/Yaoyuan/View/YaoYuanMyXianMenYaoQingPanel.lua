require "Core.Module.Common.Panel"

require "Core.Module.Yaoyuan.View.item.YaoYuanXMYaoQingItem"

YaoYuanMyXianMenYaoQingPanel = class("YaoYuanMyXianMenYaoQingPanel", Panel);
function YaoYuanMyXianMenYaoQingPanel:New()
    self = { };
    setmetatable(self, { __index = YaoYuanMyXianMenYaoQingPanel });
    return self
end



function YaoYuanMyXianMenYaoQingPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function YaoYuanMyXianMenYaoQingPanel:_InitReference()
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._trsMask = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMask");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self.notPlayerTip = UIUtil.GetChildByName(self.mainView, "UILabel", "notPlayerTip");

    self.listPanel = UIUtil.GetChildByName(self.mainView, "Transform", "listPanel");
    self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");
    self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");

    local temArr = { };
    for i = 1, 18 do
        temArr[i] = { };
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, YaoYuanXMYaoQingItem);
    self.product_phalanx:Build(18, 1, temArr);
     
     MessageManager.AddListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_XIANMEN_YAOQING_LIST_COMPLETE, YaoYuanMyXianMenYaoQingPanel.XianMenYaoQingList, self);

     self.notPlayerTip.gameObject:SetActive(false);
    
    YaoyuanProxy.TryGetXMYaoQingList();

end

function YaoYuanMyXianMenYaoQingPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function YaoYuanMyXianMenYaoQingPanel:_OnClickBtn_close()

    ModuleManager.SendNotification(YaoyuanNotes.CLOSE_YAOYUANMYXIANMENYAOQINGPANEL);

end

--[[
 S <-- 19:57:35.598, 0x140D, 15, {"tm":[{"gts":0,"n":"\u6C88\u8FDC\u56FD","pid":"20100294","wts":0,"c":101000,"l":0}]}

 1--wts= [0]
  --n= [沈远国]
  --l= [0]
  --gts= [0]
  --c= [101000]
  --pid= [20100294]

]]
function YaoYuanMyXianMenYaoQingPanel:XianMenYaoQingList(list)

  local item = self.product_phalanx._items;

     for i = 1, 18 do
       item[i].itemLogic:SetData(list[i]);
     end

     local t_num = table.getn(list);
     if t_num <= 0 then
     self.notPlayerTip.gameObject:SetActive(true);
     end

end

function YaoYuanMyXianMenYaoQingPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function YaoYuanMyXianMenYaoQingPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function YaoYuanMyXianMenYaoQingPanel:_DisposeReference()
    self._btn_close = nil;
    self._trsMask = nil;

    MessageManager.RemoveListener(YaoyuanProxy, YaoyuanProxy.MESSAGE_GET_XIANMEN_YAOQING_LIST_COMPLETE, YaoYuanMyXianMenYaoQingPanel.XianMenYaoQingList);

     if self.product_phalanx ~= nil then
       self.product_phalanx:Dispose();
       self.product_phalanx = nil;
    end

    self.mainView = nil;

    self.notPlayerTip = nil;

    self.listPanel = nil;
    self.subPanel = nil;
    self._item_phalanx = nil;


end
