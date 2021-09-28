require "Core.Module.Common.Panel"

require "Core.Module.Yaoyuan.View.item.ZhongZhiCangkuItem"

ZhongZhiCangKuPanel = class("ZhongZhiCangKuPanel", Panel);
function ZhongZhiCangKuPanel:New()
    self = { };
    setmetatable(self, { __index = ZhongZhiCangKuPanel });
    return self
end


function ZhongZhiCangKuPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function ZhongZhiCangKuPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
    self._btn_yijianzhongzhi = UIUtil.GetChildInComponents(btns, "btn_yijianzhongzhi");
    self._btn_hongzhi = UIUtil.GetChildInComponents(btns, "btn_hongzhi");
    self._trsMask = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMask");

    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self.listPanel = UIUtil.GetChildByName(self.mainView, "Transform", "listPanel");
    self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");
    self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");

    self:InitList();

    MessageManager.AddListener(SeedBagDataManager, SeedBagDataManager.MESSAGE_SEEDBAG_PRODUCTS_CHANGE, ZhongZhiCangKuPanel.ProductsChange, self);

    self:ProductsChange()
end

function ZhongZhiCangKuPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
    self._onClickBtn_yijianzhongzhi = function(go) self:_OnClickBtn_yijianzhongzhi(self) end
    UIUtil.GetComponent(self._btn_yijianzhongzhi, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_yijianzhongzhi);
    self._onClickBtn_hongzhi = function(go) self:_OnClickBtn_hongzhi(self) end
    UIUtil.GetComponent(self._btn_hongzhi, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_hongzhi);
end


function ZhongZhiCangKuPanel:InitList()

    local tem = { };
    for i = 1, 25 do
        tem[i] = { { spId = 356030, am = 20 }, { spId = 356030, am = 21 } };
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, ZhongZhiCangkuItem);
    self.product_phalanx:Build(25, 1, tem);

end

function ZhongZhiCangKuPanel:SetSelectPlant(idx)

    self.idx = idx;



end

function ZhongZhiCangKuPanel:ProductsChange()

    local _items = self.product_phalanx._items;

    local t_nooum = table.getn(_items);

    local dataList = SeedBagDataManager.GetList();
    local t_num = table.getn(dataList);

    for i = 1, 25 do
        local obj = _items[i].itemLogic;
        if i <= t_num then
            obj:SetData(dataList[i]);
        else
            obj:SetData(nil);
        end
    end



    if t_num > 0 then

        if self.hasInit == nil then

            _items[1].itemLogic:SetDefSelected();
            self.hasInit = true;
        end


    end

end

function ZhongZhiCangKuPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(YaoyuanNotes.CLOSE_ZHONGZHICANGKUPANEL);
end

function ZhongZhiCangKuPanel:_OnClickBtn_yijianzhongzhi()

    if ZhongZhiCangKuProCtr.currSelect ~= nil then

        local fctr = FarmsControll.ins;
        local idxs = fctr:GetFreePlanIdx();
        local ids = { };
        local spId = ZhongZhiCangKuProCtr.currSelect.spId;
        local am = ZhongZhiCangKuProCtr.currSelect.am;
        local t_num = table.getn(idxs);

        if t_num > 0 then

            for i = 1, t_num do
                ids[i] = spId;
            end

            local res = { idxs = { }, ids = { } };

            for i = 1, am do
                if i <= t_num then
                    res.idxs[i] = idxs[i];
                    res.ids[i] = ids[i];
                end
            end

            YaoyuanProxy.TryZhongzhi(res)

        else
        MsgUtils.ShowTips("Yaoyuan/ZhongZhiCangKuPanel/label2");

        end

    else

        MsgUtils.ShowTips("Yaoyuan/ZhongZhiCangKuPanel/label1");
    end

end

--[[
 else
        MsgUtils.ShowTips("Yaoyuan/ZhongZhiCangKuPanel/label2");
]]

function ZhongZhiCangKuPanel:_OnClickBtn_hongzhi()
   

    if ZhongZhiCangKuProCtr.currSelect ~= nil then

        local fctr = FarmsControll.ins;
        local panels = fctr:GetPanels();

        local spId = ZhongZhiCangKuProCtr.currSelect.spId;

        if self.idx == nil then
            for i = 1, FarmsControll.maxNum do
                local pl = panels[i];
                if not pl.lock and not pl.hasPanel then
                    YaoyuanProxy.TryZhongzhi( { idxs = { i + 0 }, ids = { spId + 0 } })
                    return;
                end

            end

           MsgUtils.ShowTips("Yaoyuan/ZhongZhiCangKuPanel/label2");
        else
            YaoyuanProxy.TryZhongzhi( { idxs = { self.idx + 0 }, ids = { spId + 0 } })
        end


    else
        MsgUtils.ShowTips("Yaoyuan/ZhongZhiCangKuPanel/label1");
    end

end

function ZhongZhiCangKuPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function ZhongZhiCangKuPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
    UIUtil.GetComponent(self._btn_yijianzhongzhi, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_yijianzhongzhi = nil;
    UIUtil.GetComponent(self._btn_hongzhi, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_hongzhi = nil;
end

function ZhongZhiCangKuPanel:_DisposeReference()
    self._btn_close = nil;
    self._btn_yijianzhongzhi = nil;
    self._btn_hongzhi = nil;
    self._trsMask = nil;

    ZhongZhiCangKuProCtr.currSelect = nil;

    MessageManager.RemoveListener(SeedBagDataManager, SeedBagDataManager.MESSAGE_SEEDBAG_PRODUCTS_CHANGE, ZhongZhiCangKuPanel.ProductsChange);

    if self.product_phalanx ~= nil then
        self.product_phalanx:Dispose();
        self.product_phalanx = nil;
    end


    self.mainView = nil;

    self.listPanel = nil;
    self.subPanel = nil;
    self._item_phalanx = nil;

end
