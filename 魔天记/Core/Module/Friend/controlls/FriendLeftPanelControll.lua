require "Core.Module.Friend.controlls.items.FriendListItem"

FriendLeftPanelControll = class("FriendLeftPanelControll");
local _sortfunc = table.sort 

function FriendLeftPanelControll:New()
    self = { };
    setmetatable(self, { __index = FriendLeftPanelControll });
    return self
end

function FriendLeftPanelControll:Init(gameObject)
    self.gameObject = gameObject;

    self._friendLeftToggle = UIUtil.GetChildByName(self.gameObject, "Transform", "friendLeftToggle");


    self.listMax_num = {
        [1] = 0,
        [2] = 0,
        [3] = 0,
    };
    -- 列表长度最长 50
    local tem_arr = { };
    for i = 1, self.listMax_num[1] do
        tem_arr[i] = { };
    end

    for i = 1, 3 do
        self["_ScrollView" .. i] = UIUtil.GetChildByName(self.gameObject, "Transform", "ScrollView" .. i);
        self["_pd_phalanx" .. i] = UIUtil.GetChildByName(self["_ScrollView" .. i], "LuaAsynPhalanx", "pd_phalanx");

        self["product_phalanx" .. i] = Phalanx:New();
        self["product_phalanx" .. i]:Init(self["_pd_phalanx" .. i], FriendListItem);
        -- self["product_phalanx" .. i]:Build(self.listMax_num[i], 1, tem_arr);
    end


    self.product_phalanx = nil;


    self:SetTagleHandler(FriendNotes.classify_btnNew);
    self:SetTagleHandler(FriendNotes.classify_btnFriends);
    self:SetTagleHandler(FriendNotes.classify_btnEnemy);



    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_PLAYER_CHANGE, FriendLeftPanelControll.PlayerChange, self);
    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_SELECTED, FriendLeftPanelControll.FriendListItemSelected, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_STRANGER_CHANGE, FriendLeftPanelControll.StrangerChange, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_SETSTRANGERLIST_COMPLETE, FriendLeftPanelControll.setStrangerComplete, self);

    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_TIP_CHANGE, FriendLeftPanelControll.charTipChange, self);

    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_REMOVEFRIENDCOMPLETE, FriendLeftPanelControll.RemoveFriendComplete, self);


    FriendDataManager.currSelectTarget = nil;
    self._curr_classify = FriendNotes.classify_btnNew;
    self:SetAndShowScrollView(1);

end

function FriendLeftPanelControll:SetTagleHandler(name)

    self[name .. "Handler"] = function(go) self:Classify_OnClick(name) end
    self["_" .. name] = UIUtil.GetChildByName(self._friendLeftToggle, "Transform", name).gameObject;
    UIUtil.GetComponent(self["_" .. name], "LuaUIEventListener"):RegisterDelegate("OnClick", self[name .. "Handler"]);

    self["OnTipIcon_" .. name] = UIUtil.GetChildByName(self["_" .. name], "UISprite", "ntipIcon");
    self["OnTipIcon_" .. name].gameObject:SetActive(false);

end

function FriendLeftPanelControll:RemoveTagleHandler(name)

    UIUtil.GetComponent(self["_" .. name], "LuaUIEventListener"):RemoveDelegate("OnClick");
    self[name .. "Handler"] = nil;
end

function FriendLeftPanelControll:SetTagleSelect(name)

    local gobj = UIUtil.GetChildByName(self._friendLeftToggle, "Transform", name).gameObject;
    local toggle = UIUtil.GetComponent(gobj, "UIToggle");
    toggle.value =(true);
end

function FriendLeftPanelControll:Classify_OnClick(name)


    --------------------------------------------------------------------------------------------------------

    FriendNotes.firend_curr_select_classify = name;
    self._curr_classify = name;
    if self._curr_classify == FriendNotes.classify_btnNew then
        self:SetAndShowScrollView(1);
        self:CheckStrangerList();
    elseif self._curr_classify == FriendNotes.classify_btnFriends then
        self:SetAndShowScrollView(2);

        self:SetListData(FriendDataManager.GetFriendList());

    elseif self._curr_classify == FriendNotes.classify_btnEnemy then
        self:SetAndShowScrollView(3);

        self:SetListData(FriendDataManager.GetEnemList());
    end

    FriendDataManager.curr_classify = name;
    MessageManager.Dispatch(FriendDataManager, FriendDataManager.MESSAGE_CLASSIFY_CHANGE);

end


function FriendLeftPanelControll:SetAndShowScrollView(index)
    self.product_phalanx = self["product_phalanx" .. index];
    self.currSelectIdx = index;
    for i = 1, 3 do
        self["_ScrollView" .. i].gameObject:SetActive(false);
    end
    self["_ScrollView" .. index].gameObject:SetActive(true);
end


function FriendLeftPanelControll:StrangerChange()

    -- if self._curr_classify == FriendNotes.classify_btnNew then
    --  只要陌生人发生改变， 都需要获取数据
    self:CheckStrangerList();

    -- end

end

function FriendLeftPanelControll:Show()

    self:hideAllListItem();
    FriendProxy.TryGetMyFriendList();

end

function FriendLeftPanelControll:PlayerChange(type)

    self:SetTagleSelect(self._curr_classify);
    self:Classify_OnClick(self._curr_classify);
end

function FriendLeftPanelControll:FriendListItemSelected(target)

    local item = self.product_phalanx._items;

    for i = 1, self.listMax_num[self.currSelectIdx] do
        local obj = item[i].itemLogic;

        if obj == target then
            obj:SetSelect(true);
        else
            obj:SetSelect(false);
        end
    end


    -- 这里需要 检测 分类 按钮 是否需要 显示 新消息图标
    self:CheckTagleNtip()

end

function FriendLeftPanelControll:RemoveFriendComplete()



end


function FriendLeftPanelControll:hideAllListItem()

    local item = self.product_phalanx._items;

    for i = 1, self.listMax_num[self.currSelectIdx] do
        if item[i] ~= nil then
            local obj = item[i].itemLogic;
            obj:SetActive(false);
        end

    end

end

function FriendLeftPanelControll:CheckStrangerList()


    local t_num = table.getn(FriendDataManager.need_get_strangerList);

    if t_num > 0 then
        FriendProxy.TryGetPlayerInfo(FriendDataManager.need_get_strangerList);
    else
        self:hideAllListItem();
        local list = FriendDataManager.Get_strangerList();
        self:SetListData(list);
    end

end

function FriendLeftPanelControll:setStrangerComplete()


    if self._curr_classify == FriendNotes.classify_btnNew then
        self:hideAllListItem();

        local list = FriendDataManager.Get_strangerList();
        self:SetListData(list);

    elseif self._curr_classify == FriendNotes.classify_btnFriends then
        self:hideAllListItem();
        self:SetListData(FriendDataManager.GetFriendList());

    elseif self._curr_classify == FriendNotes.classify_btnEnemy then

        self:hideAllListItem();
        self:SetListData(FriendDataManager.GetEnemList());

    else
        -- 这里需要 检测 分类 按钮 是否需要 显示 新消息图标
        self:CheckTagleNtip()
    end



end

function FriendLeftPanelControll:SetListData(list)

    -- 这里需要 进行  最近聊天记录 排序
    local t_num = table.getn(list);


    for i = 1, t_num do
        list[i].order = 0;
        local dinfo = list[i];
        local id = dinfo.id;
        local msg = FriendDataManager.charMsg[id];
        if msg ~= nil then
            local msg_num = table.getn(msg);
            if msg_num > 0 then
                local order = msg[1].order;
                list[i].order = order;
            end

        end
    end

    -- 这里需要 对 列表进行 排序，
    -- 是否 在线
    -- 最新消息时间

    _sortfunc(list, function(a, b)

        if a.order == nil then
            a.order = 0;
        end

        if b.order == nil then
            b.order = 0;
        end

        if a.is_online == nil then
            a.is_online = 0;
        end

        if b.is_online == nil then
            b.is_online = 0;
        end


        return(a.is_online * 100 + a.order) >(b.is_online * 100 + b.order)
    end );

    ----------------------------

    self:hideAllListItem();


    MessageManager.Dispatch(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_UNSELECTED);

    if self.listMax_num[self.currSelectIdx] < t_num then
        self.listMax_num[self.currSelectIdx] = t_num;
        self["product_phalanx" .. self.currSelectIdx]:Build(self.listMax_num[self.currSelectIdx], 1, list);
    end


    local item = self.product_phalanx._items;
    for i = 1, t_num do
        local obj = item[i].itemLogic;
        obj:SetData(list[i], i);
    end


    -- 这里需要 检测 分类 按钮 是否需要 显示 新消息图标
    self:CheckTagleNtip()

end

function FriendLeftPanelControll:charTipChange()

    local item = self.product_phalanx._items;

    for i = 1, self.listMax_num[self.currSelectIdx] do
        local obj = item[i].itemLogic;
        obj:CheckChatTip();
    end

    -- 这里需要 检测 分类 按钮 是否需要 显示 新消息图标
    self:CheckTagleNtip()
end

-- 这里需要 检测 分类 按钮 是否需要 显示 新消息图标


function FriendLeftPanelControll:CheckTagleNtip()

    local list = FriendDataManager.Get_strangerList();
    -- 陌生人
    local b = self:CheckIsNeedNtip(list);
    if b then
        self["OnTipIcon_" .. FriendNotes.classify_btnNew].gameObject:SetActive(true);
    else
        self["OnTipIcon_" .. FriendNotes.classify_btnNew].gameObject:SetActive(false);
    end

    list = FriendDataManager.GetFriendList();
    -- 好友
    b = self:CheckIsNeedNtip(list);
    if b then
        self["OnTipIcon_" .. FriendNotes.classify_btnFriends].gameObject:SetActive(true);
    else
        self["OnTipIcon_" .. FriendNotes.classify_btnFriends].gameObject:SetActive(false);
    end

    list = FriendDataManager.GetEnemList();
    -- 敌人
    b = self:CheckIsNeedNtip(list);
    if b then
        self["OnTipIcon_" .. FriendNotes.classify_btnEnemy].gameObject:SetActive(true);
    else
        self["OnTipIcon_" .. FriendNotes.classify_btnEnemy].gameObject:SetActive(false);
    end


end

function FriendLeftPanelControll:CheckIsNeedNtip(list)

    local t_num = table.getn(list);
    for i = 1, t_num do

        local id = list[i].id;
        local b = FriendDataManager.GetNeedShowTip(id);

        if b then
            return true;
        end
    end

    return false;
end



function FriendLeftPanelControll:Dispose()

    FriendDataManager.curr_select_stranger_id = "";
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_PLAYER_CHANGE, FriendLeftPanelControll.PlayerChange)
    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_SELECTED, FriendLeftPanelControll.FriendListItemSelected)
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_STRANGER_CHANGE, FriendLeftPanelControll.StrangerChange);
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_SETSTRANGERLIST_COMPLETE, FriendLeftPanelControll.setStrangerComplete);
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_TIP_CHANGE, FriendLeftPanelControll.charTipChange);
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_REMOVEFRIENDCOMPLETE, FriendLeftPanelControll.RemoveFriendComplete);

    for i = 1, 3 do
        self["product_phalanx" .. i]:Dispose();
        self["product_phalanx" .. i] = nil;

        self["_ScrollView" .. i] = nil;
        self["_pd_phalanx" .. i] = nil;

    end

    self:RemoveTagleHandler(FriendNotes.classify_btnNew);
    self:RemoveTagleHandler(FriendNotes.classify_btnFriends);
    self:RemoveTagleHandler(FriendNotes.classify_btnEnemy);

    self._friendLeftToggle = nil;
end