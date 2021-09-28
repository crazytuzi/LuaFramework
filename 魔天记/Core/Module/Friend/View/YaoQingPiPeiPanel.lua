require "Core.Module.Common.Panel"

require "Core.Module.Friend.controlls.items.YaoQingPiPeiTypeItem"

require "Core.Module.Friend.controlls.YaoQingPiPeiRightControll";

YaoQingPiPeiPanel = class("YaoQingPiPeiPanel", Panel);
local _sortfunc = table.sort 

function YaoQingPiPeiPanel:New()
    self = { };
    setmetatable(self, { __index = YaoQingPiPeiPanel });
    return self
end


function YaoQingPiPeiPanel:_Init()
    self:_InitReference();
    self:_InitListener();

    self:GetData();
    self:SetList()
end

function YaoQingPiPeiPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txt_title = UIUtil.GetChildInComponents(txts, "txt_title");
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");


    self.leftPanbel = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView/leftPanbel");
    self.rightPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView/rightPanel");

    self.listPanel = UIUtil.GetChildByName(self.leftPanbel, "Transform", "listPanel");

    self._item_phalanx = UIUtil.GetChildByName(self.listPanel, "LuaAsynPhalanx", "table");
    self._clsTable = UIUtil.GetChildByName(self.listPanel, "UITable", "table");


    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._item_phalanx, YaoQingPiPeiTypeItem);

    self.yaoQingPiPeiRightControll = YaoQingPiPeiRightControll:New();
    self.yaoQingPiPeiRightControll:Init(self.rightPanel);

    ActivityProxy.TryGetActivityData()
end

function YaoQingPiPeiPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);

end

--[[
获取需要显示的数据
]]
function YaoQingPiPeiPanel:GetData()

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_lv = heroInfo.level;

    local activity_id_lists = { };

    local cf = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_EXPERIENCE_LEV);


    for key, value in pairs(cf) do

        local obj = value;
        local activity_id = obj.activity_id;
        local min_level = obj.min_level;

        if obj.show_in_match==1 and my_lv >= min_level then

            if activity_id_lists[activity_id] == nil then
                activity_id_lists[activity_id] = { };
            end

            local tem_num = table.getCount(activity_id_lists[activity_id]);
            tem_num = tem_num + 1;
            activity_id_lists[activity_id][tem_num] = obj;
        end
    end

    ---------------------- 转换成数组  ---------------------------------
    self.tbList = { };
    local tbListIndex = 1;

    for key, value in pairs(activity_id_lists) do
        self.tbList[tbListIndex] = value;
        tbListIndex = tbListIndex + 1;
    end

    for key, lt in pairs(self.tbList) do
        _sortfunc(lt, function(a, b)

            return a.order > b.order;

        end )
    end

    ------------------- 需要排序 ------------------
    _sortfunc(self.tbList, function(a, b)

        return a[1].order < b[1].order;

    end )

end

function YaoQingPiPeiPanel:SetList()

    local t_num = table.getCount(self.tbList);

    self.product_phalanx:Build(t_num, 1, self.tbList);

    local _items = self.product_phalanx._items;
    for j = 1, t_num do
        _items[j].itemLogic:SetIndex(j, self._clsTable);

        _items[j].itemLogic:HideAllItems();
    end

end

--[[
  之前的选择状态
]]
function YaoQingPiPeiPanel:SetDafultData(seledtData)

    self.seledtData = seledtData;
    if self.seledtData ~= nil then
        local _items = self.product_phalanx._items;
        local t_num = table.getn(_items);

        for j = 1, t_num do
            _items[j].itemLogic:SetSelectData(self.seledtData);
        end
    end

end


function YaoQingPiPeiPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(FriendNotes.CLOSE_YAOQINGPIPEIPANEL);
end



function YaoQingPiPeiPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function YaoQingPiPeiPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;

end

function YaoQingPiPeiPanel:_DisposeReference()

    self.product_phalanx:Dispose();
    self.yaoQingPiPeiRightControll:Dispose();
    self.yaoQingPiPeiRightControll = nil;
    YaoQingPiPeiTypeItem.currSelect = nil;
    YaoQingPiPeiItem.currSelect = nil;
    self._btn_close = nil;

    self._txt_title = nil;
end
