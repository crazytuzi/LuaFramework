require "Core.Module.Common.UIComponent"

require "Core.Module.ActivityGifts.View.Item.SubItem4Item"


SubItem4Panel = class("SubItem4Panel", UIComponent);


--[[
[4] = {
		['id'] = 4,
		['title_name'] = '累计充值',
		['openVal'] = 1,
		['code_id'] = 4,
		['isOpen'] = true
		},
]]
function SubItem4Panel:New(trs)
    self = { };
    setmetatable(self, { __index = SubItem4Panel });
    if (trs) then
        self:Init(trs)
    end
    return self
end

-- 活动时间：


function SubItem4Panel:_Init()
    self._isInit = false

    self:_InitReference();
    self:_InitListener();

end

function SubItem4Panel:_InitReference()


    self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, SubItem4Item)
    self._scollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView")
    self.btncharge = UIUtil.GetChildByName(self._transform, "UIButton", "btncharge");
    self.actTimeValueTxt = UIUtil.GetChildByName(self._transform, "UILabel", "actTimeValueTxt")

    local listData = RechargRewardDataManager.GetInActivityItems(RechargRewardDataManager.TYPE_TOTAL_RECHARGE)
   -- http://192.168.0.8:3000/issues/4449
   table.sort(listData, function(x, y) return x.param2 < y.param2 end)
   
    local list_num = table.getn(listData);

    if list_num > 0 then

        self.actTimeValueTxt.text = listData[1].starttime .. " - " .. listData[1].endtime;

        SubItem4Item.hasSetT = false;
        self._phalanx:Build(list_num, 1, listData);
    end




    self:UpdatePanel();

    MessageManager.AddListener(RechargRewardDataManager, RechargRewardDataManager.MESSAGE_RECHARGREWARDDATA_CHANGE, SubItem4Panel.ServerDataChange, self);


end



function SubItem4Panel:_InitListener()

    self._onClickBtncharge = function(go) self:_OnClickBtncharge() end
    UIUtil.GetComponent(self.btncharge, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtncharge);


end

function SubItem4Panel:_OnClickBtncharge()

   --ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 3 })
   ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3});
end

function SubItem4Panel:ServerDataChange()

    self:UpdatePanel();

    MessageManager.Dispatch(ActivityGiftsPanel, ActivityGiftsPanel.MESSAGE_ACTIVITYGIFTS_UPDATETIPSTATE);

end

function SubItem4Panel:_Dispose()

    UIUtil.GetComponent(self.btncharge, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtncharge = nil;

    MessageManager.RemoveListener(RechargRewardDataManager, RechargRewardDataManager.MESSAGE_RECHARGREWARDDATA_CHANGE, SubItem4Panel.ServerDataChange);

    if (self._phalanx) then
        self._phalanx:Dispose()
        self._phalanx = nil
    end

end

function SubItem4Panel:_DisposeReference()


end

function SubItem4Panel:UpdatePanel()

    local item = self._phalanx._items;
    local l_num = table.getn(item);
     SubItem4Item.hasSetT = false;
    if l_num > 0 then
        for i = 1, l_num do
            local obj = item[i].itemLogic;
            obj:DataChange();
        end
    end

end

