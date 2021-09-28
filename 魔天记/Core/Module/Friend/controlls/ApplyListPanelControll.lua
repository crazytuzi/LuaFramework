require "Core.Module.Friend.controlls.items.AskPlayerInfoPanelItem"

ApplyListPanelControll = class("ApplyListPanelControll");

function ApplyListPanelControll:New()
    self = { };
    setmetatable(self, { __index = ApplyListPanelControll });
    return self
end


function ApplyListPanelControll:Init(gameObject, clearAskListBt)
    self.gameObject = gameObject;
    self.clearAskListBt = clearAskListBt;


    local _ScrollView = UIUtil.GetChildByName(self.gameObject, "Transform", "ScrollView");
    self._pd_phalanx = UIUtil.GetChildByName(_ScrollView, "LuaAsynPhalanx", "pd_phalanx");



    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._pd_phalanx, AskPlayerInfoPanelItem);


    MessageManager.AddListener(FriendProxy, FriendProxy.MESSAGE_APPLYTEARMLIST_CHANGE, ApplyListPanelControll.ApplyteListChange, self);
    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, ApplyListPanelControll.MenberDataChange, self);

end

function ApplyListPanelControll:Show()
    self.gameObject:SetActive(true);
    self.showing = true;
    FriendProxy.GetApplyTearmList();

end



function ApplyListPanelControll:ClearAskList()


    local b = PartData.MeIsTeamLeader();
    if b then

        FriendProxy.CleanApplyTearmList()

    end


end

--[[
11:31:12.705-517: 1--f= [33435]
  --n= [王立阳]
  --kind= [101000]
  --l= [96]
  --pid= [10100039]
]]
function ApplyListPanelControll:ApplyteListChange(list)


    if self.showing then
        local len = table.getn(list);
        self.product_phalanx:Build(len, 1, list);

        if len > 0 then
            self.clearAskListBt.gameObject:SetActive(true);
        else
            self.clearAskListBt.gameObject:SetActive(false);
        end
    end



end

function ApplyListPanelControll:MenberDataChange(type)

    if type == PartData.PARTY_DATA_CHANGE_TYPE_SETMYTEAM or type == PartData.PARTY_DATA_CHANGE_TYPE_SETNEW_TEAMLEADER_NAME then
        -- 自己不是队长了， 那么就要情况数据


        local b = PartData.MeIsTeamLeader();
        if b then
            FriendProxy.GetApplyTearmList();
        else
            FriendProxy.Set_applyTearmList( { });
        end

    end


end

function ApplyListPanelControll:Close()
    self.gameObject:SetActive(false);
    self.showing = false;
end

function ApplyListPanelControll:Dispose()


    MessageManager.RemoveListener(FriendProxy, FriendProxy.MESSAGE_APPLYTEARMLIST_CHANGE, ApplyListPanelControll.ApplyteListChange);
    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, ApplyListPanelControll.MenberDataChange);

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;

    self._pd_phalanx = nil;
    self.gameObject = nil;

end