require "Core.Module.Common.Panel"

require "Core.Module.Friend.controlls.items.YaoQingZuDingListItem"

YaoQingZuDingListPanel = class("YaoQingZuDingListPanel", Panel);
function YaoQingZuDingListPanel:New()
    self = { };
    setmetatable(self, { __index = YaoQingZuDingListPanel });
    return self
end


function YaoQingZuDingListPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function YaoQingZuDingListPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txt_title = UIUtil.GetChildInComponents(txts, "txt_title");
    self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
    self._txtLevel = UIUtil.GetChildInComponents(txts, "txtLevel");
    local imgs = UIUtil.GetComponentsInChildren(self._trsContent, "UISprite");
    self._imgIcon = UIUtil.GetChildInComponents(imgs, "imgIcon");
    self._imgBackground = UIUtil.GetChildInComponents(imgs, "imgBackground");
    self._btn_close = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn_close");
    self._trsMask = UIUtil.GetChildByName(self._trsContent, "Transform", "trsMask");

    self.subPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView/listPanel/subPanel");
    self.table_phala = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");

    self.phalanx = Phalanx:New();
    self.phalanx:Init(self.table_phala, YaoQingZuDingListItem);

end

function YaoQingZuDingListPanel:_InitListener()
    self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
end

function YaoQingZuDingListPanel:_OnClickBtn_close()
    ModuleManager.SendNotification(FriendNotes.CLOSE_YAOQINGZUDINGLISTPANEL);
end

function YaoQingZuDingListPanel:SetData(d)

    local type = d.type;

    if type == 1 then
        -- 邀请好友
        MessageManager.RemoveListener(FriendProxy, FriendProxy.MESSAGE_GETMYFRIENDSLIST_RESULT, YaoQingZuDingListPanel.GetMyFriendsResult);
        MessageManager.AddListener(FriendProxy, FriendProxy.MESSAGE_GETMYFRIENDSLIST_RESULT, YaoQingZuDingListPanel.GetMyFriendsResult, self);

        FriendProxy.TryGetMyFriendList();

        self._txt_title.text = LanguageMgr.Get("Friend/YaoQingZuDingListPanel/label1") ;

    elseif type == 2 then
        -- 邀请盟友
        MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_MEMBERS, YaoQingZuDingListPanel.GetGuidListResult);
        MessageManager.AddListener(GuildNotes, GuildNotes.RSP_MEMBERS, YaoQingZuDingListPanel.GetGuidListResult, self);


        GuildProxy.ReqMember();

         self._txt_title.text = LanguageMgr.Get("Friend/YaoQingZuDingListPanel/label2") ;

    end

end

--[[
 1--level= [66]
| --id= [10000758]
| --sex= [0]
| --fight= [120977]
| --is_online= [1]
| --kind= [102000]
| --type= [1]
| --name= [龙星]
| --tid= [1049]
]]
function YaoQingZuDingListPanel:GetMyFriendsResult(list)

    MessageManager.RemoveListener(FriendProxy, FriendProxy.MESSAGE_GETMYFRIENDSLIST_RESULT, YaoQingZuDingListPanel.GetMyFriendsResult);

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_id = tonumber(heroInfo.id);

    local t_num = table.getn(list);
    local arr = { };
    local arrIndex = 1;
    -- 剔除自己的信息
    for i = 1, t_num do
    --  list[i].type==1  是自己的 好友
        if tonumber(list[i].id) ~= my_id and tonumber(list[i].is_online) == 1 and list[i].type==1 then
            arr[arrIndex] = list[i];
            arrIndex = arrIndex + 1;
        end
    end

    t_num = table.getn(arr);
    if t_num > 0 then
        self.phalanx:Build(t_num, 1, arr);
    end

end

--[[
 self.id = d.pid or -1;
    self.guildId = d.tId or -1;
    self.name = d.n or "-1";
    self.level = d.l or -1;
    self.identity = d.s or -1;    --职位
    self.fight = d.f or -1;         --战斗力
    self.kind = d.c or -1;        --职业
    self.dkpWeek = d.wd or -1;
    self.dkpDay = d.d or -1;
    self.dkpAll = d.dt or -1;
    self.joinTime = d.at or -1;
    self.onlineType = d.ol or -1;
    self.offlineTime = d.ot or -1;
]]
function YaoQingZuDingListPanel:GetGuidListResult(list)
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_MEMBERS, YaoQingZuDingListPanel.GetGuidListResult);

    local me = HeroController:GetInstance();
    local heroInfo = me.info;
    local my_id = tonumber(heroInfo.id);

    local t_num = table.getn(list);
    local arr = { };
    local arrIndex = 1;
    -- 剔除自己的信息
    for i = 1, t_num do
        if tonumber(list[i].id) ~= my_id and tonumber(list[i].onlineType) == 1 then
            arr[arrIndex] = list[i];
            arrIndex = arrIndex + 1;
        end
    end

    t_num = table.getn(arr);
    if t_num > 0 then
        self.phalanx:Build(t_num, 1, arr);
    end

end



function YaoQingZuDingListPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function YaoQingZuDingListPanel:_DisposeListener()
    UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn_close = nil;
end

function YaoQingZuDingListPanel:_DisposeReference()


    MessageManager.RemoveListener(FriendProxy, FriendProxy.MESSAGE_GETMYFRIENDSLIST_RESULT, YaoQingZuDingListPanel.GetMyFriendsResult);
    MessageManager.RemoveListener(GuildNotes, GuildNotes.RSP_MEMBERS, YaoQingZuDingListPanel.GetGuidListResult);

    self.phalanx:Dispose();
    self.phalanx = nil;

    self._btn_close = nil;
    self._txt_title = nil;
    self._txtName = nil;
    self._txtLevel = nil;
    self._imgIcon = nil;
    self._imgBackground = nil;
    self._trsMask = nil;
end
