require "Core.Module.Friend.controlls.items.TeamInfoPanelItem"

FBNearbyTeamControll = class("FBNearbyTeamControll");
local _sortfunc = table.sort 

function FBNearbyTeamControll:New()
    self = { };
    setmetatable(self, { __index = FBNearbyTeamControll });
    return self
end


function FBNearbyTeamControll:Init(gameObject)
    self.gameObject = gameObject;


    local _ScrollView = UIUtil.GetChildByName(self.gameObject, "Transform", "ScrollView");
    self._pd_phalanx = UIUtil.GetChildByName(_ScrollView, "LuaAsynPhalanx", "pd_phalanx");

    self.teamMax_num = 1;
    -- 列表长度最长 50
    local tem_arr = { };
    for i = 1, self.teamMax_num do
        tem_arr[i] = { };
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._pd_phalanx, TeamInfoPanelItem);
    self.product_phalanx:Build(self.teamMax_num, 1, tem_arr);




end


function FBNearbyTeamControll:Show()
    self.gameObject:SetActive(true);

    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_NEARTEAMRESULT, FBNearbyTeamControll.NearTeamResult, self);

    self:TryGetNearTeam()
end

function FBNearbyTeamControll:TryGetNearTeam()
    FriendProxy.TryGetNearTeam();


end

--  S <-- 11:16:35.757, 0x0B0C, 13, {"ts":[{"f":1128,"num":1,"k":101000,"id":1,"l":1,"n":"姜小浩"}]}
function FBNearbyTeamControll:NearTeamResult(data)

    self:UpData(data.ts);


    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_NEARTEAMRESULT, FBNearbyTeamControll.NearTeamResult);
end




function FBNearbyTeamControll:UpData(arr)

    local len = table.getn(arr);

    -- 需要 进行 排序

    if len > 1 then

        _sortfunc(arr, function(a, b)
            local fight_a = a.f;
            local fight_b = b.f;

            return fight_a > fight_b;
        end );
    end


    self.teamMax_num = len;
    self.product_phalanx:Build(self.teamMax_num, 1, arr);


    local item = self.product_phalanx._items;

    for i = 1, len do
        item[i].itemLogic:SetData(arr[i]);
    end

end

function FBNearbyTeamControll:Close()
    self.gameObject:SetActive(false);

end

function FBNearbyTeamControll:Dispose()

    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_NEARTEAMRESULT, FBNearbyTeamControll.NearTeamResult);

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;
    self._pd_phalanx = nil;
end