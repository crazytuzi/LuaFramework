require "Core.Module.Friend.controlls.items.PlayerInfoPanelItem"

NearbyPlayerPanelControll = class("NearbyPlayerPanelControll");
local _sortfunc = table.sort 

function NearbyPlayerPanelControll:New()
    self = { };
    setmetatable(self, { __index = NearbyPlayerPanelControll });
    return self
end


function NearbyPlayerPanelControll:Init(gameObject)
    self.gameObject = gameObject;

    local _ScrollView = UIUtil.GetChildByName(self.gameObject, "Transform", "ScrollView");
    self._pd_phalanx = UIUtil.GetChildByName(_ScrollView, "LuaAsynPhalanx", "pd_phalanx");

    self.heroMax_num = 1;
    -- 列表长度最长 50
    local tem_arr = { };
    for i = 1, self.heroMax_num do
        tem_arr[i] = { };
    end

    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._pd_phalanx, PlayerInfoPanelItem);
    self.product_phalanx:Build(self.heroMax_num, 1, tem_arr);


    MessageManager.AddListener(FriendProxy, FriendProxy.MESSAGE_NEAR_PLAYERS_CHANGE, NearbyPlayerPanelControll.UpHerosListByServer, self);



end

function NearbyPlayerPanelControll:Show()
    self.gameObject:SetActive(true);

    FriendProxy.GetNearPlayers();

end



function NearbyPlayerPanelControll:UpHerosListByServer(heros)


    local len = table.getn(heros);
    if len > 1 then
        _sortfunc(heros, function(a, b)
            return a.f > b.f;
        end );
    end

   
    self.heroMax_num = len;
    self.product_phalanx:Build(self.heroMax_num, 1, heros);

    local item = self.product_phalanx._items;

    for i = 1, len do
        item[i].itemLogic:SetData(heros[i]);
    end

end


function NearbyPlayerPanelControll:Close()
    self.gameObject:SetActive(false);
end

function NearbyPlayerPanelControll:Dispose()

    MessageManager.RemoveListener(FriendProxy, FriendProxy.MESSAGE_NEAR_PLAYERS_CHANGE, NearbyPlayerPanelControll.UpHerosListByServer)

    self.product_phalanx:Dispose();
    self.product_phalanx = nil;

    self._pd_phalanx = nil;

end