require "Core.Module.Common.UIComponent"

require "Core.Manager.Item.OnlineRewardManager"

require "Core.Module.SignIn.View.Item.SubInLineItem"


SubInLinePanel = class("SubInLinePanel", UIComponent);

SubInLinePanel.ins = nil;

function SubInLinePanel:New(trs)
    self = { };
    setmetatable(self, { __index = SubInLinePanel });
    if (trs) then
        self:Init(trs)
    end
    return self
end


function SubInLinePanel:_Init()
    self._isInit = false
    SubInLinePanel.ins = self;
    self:_InitReference();
    self:_InitListener();

end

function SubInLinePanel:_InitReference()


    self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, SubInLineItem)
    self._scollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView")

    local listData = OnlineRewardManager.GetListDatas();
    local list_num = table.getn(listData);

    self._phalanx:Build(list_num, 1, listData);


    MessageManager.AddListener(OnlineRewardManager, OnlineRewardManager.MESSAGE_ONLINEREWARD_DATA_CHANGE, SubInLinePanel.InfoDataChange, self);

    self:UpdatePanel()
end

function SubInLinePanel:GetCanGetAwards()

    local items = self._phalanx._items;
    local t_num = table.getn(items);
    local needMoto1 = false;
    for i = 1, t_num do
        local obj = items[i].itemLogic;
        if obj.CanGetAward then
            return true;
        end
    end
    return false;
end

function SubInLinePanel:_InitListener()

end



function SubInLinePanel:_Dispose()


    MessageManager.RemoveListener(OnlineRewardManager, OnlineRewardManager.MESSAGE_ONLINEREWARD_DATA_CHANGE, SubInLinePanel.InfoDataChange);

    if (self._phalanx) then
        self._phalanx:Dispose()
        self._phalanx = nil
    end
    SubInLinePanel.ins = nil;


    self._phalanxInfo = nil;
    self._scollview = nil;

end

function SubInLinePanel:_DisposeReference()



end

function SubInLinePanel:UpdatePanel()

    SignInProxy.TryGetInLineInfo();

end

function SubInLinePanel:InfoDataChange()


    if self._phalanx ~= nil then

       SubInLineItem.hasShowTime=false;

        local items = self._phalanx._items;
        local t_num = table.getn(items);
        local needMoto1 = false;
        for i = 1, t_num do
            local obj = items[i].itemLogic;
            obj:DataChange();

            if i == 4 then
                if obj.data.type == OnlineRewardManager.TYPE_HAS_GET_AWARD then
                    needMoto1 = true;
                end
            end

        end


        if needMoto1 then
            self._scollview:SetDragAmount(0, 1, false);
        end

    end


end