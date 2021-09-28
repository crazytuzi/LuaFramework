require "Core.Module.Common.UIComponent"

require "Core.Module.ActivityGifts.View.Item.SubItem5Item"

require "Core.Manager.Item.GrowthGiftDataManager"

SubItem5Panel = class("SubItem5Panel", UIComponent);


--  成长基金 

function SubItem5Panel:New(trs)
    self = { };
    setmetatable(self, { __index = SubItem5Panel });
    if (trs) then
        self:Init(trs)
    end
    return self
end


function SubItem5Panel:_Init()
    self._isInit = false

    self:_InitReference();
    self:_InitListener();

end

function SubItem5Panel:_InitReference()


    self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, SubItem5Item)
    self._scollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView")
    self.btncharge = UIUtil.GetChildByName(self._transform, "UIButton", "btncharge");
    self.actMlValueTxt = UIUtil.GetChildByName(self._transform, "UILabel", "actMlValueTxt")


    local listData = GrowthGiftDataManager.GetConfigList()
    local list_num = table.getn(listData);


    if list_num > 0 then
        self._phalanx:Build(list_num, 1, listData);
    end


    self:UpdatePanel()

    MessageManager.AddListener(ActivityGiftsProxy, ActivityGiftsProxy.MESSAGE_GETCHENGZHANGJIJINGINFOS_COMPLETE, SubItem5Panel.GetInfosHandler, self);


    ActivityGiftsProxy.GetChengZhangJiJingInfos()
end



function SubItem5Panel:_InitListener()
    self._onClickBtncharge = function(go) self:_OnClickBtncharge() end
    UIUtil.GetComponent(self.btncharge, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtncharge);

end


function SubItem5Panel:_OnClickBtncharge()

    -- FirstRechargeAwardProxy.TestPlayRMB(20)
    -- 0--普通充值 1--月卡 2--每日限购 3--成长基金
    local cfArr = VIPManager.GetChargeConfigs(3);
    local cf = cfArr[1];
    VIPManager.SendCharge(cf.id);

end





--[[
08 玩家是否购买成长基金
输入：
输出：
l:[(id(配表id) :Int,f：Int 领取状态（(0：不可领取 1：可领取但未领取 2：已领取)]  
s : Int 0 ：表示未购买 1 ：已购买
buy_lv : Int  已经购买的时候用到，购买时的角色的等级


]]
function SubItem5Panel:GetInfosHandler(list)
    
       
    if ActivityGiftsProxy._0x1a08Data ~= nil then
        local s = ActivityGiftsProxy._0x1a08Data.s;

        if s == 1 then
            self.btncharge.gameObject:SetActive(false);
        else
            self.btncharge.gameObject:SetActive(true);
        end
    end


    local items = self._phalanx._items;
    local list_num = table.getn(items);

    for i = 1, list_num do
        items[i].itemLogic:SetState(list);
    end

    self:UpdatePanel()

    MessageManager.Dispatch(ActivityGiftsPanel, ActivityGiftsPanel.MESSAGE_ACTIVITYGIFTS_UPDATETIPSTATE);

end

function SubItem5Panel:_Dispose()

    UIUtil.GetComponent(self.btncharge, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtncharge = nil;

    MessageManager.RemoveListener(ActivityGiftsProxy, ActivityGiftsProxy.MESSAGE_GETCHENGZHANGJIJINGINFOS_COMPLETE, SubItem5Panel.GetInfosHandler);


end

function SubItem5Panel:_DisposeReference()


end

function SubItem5Panel:UpdatePanel()

    local item = self._phalanx._items;
    local l_num = table.getn(item);

    if l_num > 0 then
        for i = 1, l_num do
            local obj = item[i].itemLogic;
            obj:DataChange();
        end
    end

end

