require "Core.Module.Friend.controlls.items.ChatMsgItem"
require "Core.Module.Friend.controlls.FriendBottomBarControll";
require "Core.Module.Friend.controlls.FriendRightBtsBarControll";
FriendRightPanelControll = class("FriendRightPanelControll");
FriendRightPanelControll.Items = {}
FriendRightPanelControll.TimeGaps = {}
local ScrollPos = Vector3(0,15,0)
local insert = table.insert

function FriendRightPanelControll:New()
    self = { };
    setmetatable(self, { __index = FriendRightPanelControll });
    return self
end
function FriendRightPanelControll:Init(gameObject)
    self.gameObject = gameObject;

    self.unSelecttip = UIUtil.GetChildByName(self.gameObject, "Transform", "unSelecttip");
    self.bottomBar = UIUtil.GetChildByName(self.gameObject, "Transform", "bottomBar");
    self.rightBtsBar = UIUtil.GetChildByName(self.gameObject, "Transform", "rightBtsBar");
    self.chatBg = UIUtil.GetChildByName(self.gameObject, "UISprite", "chatBg");

    self.bottomBarCtr = FriendBottomBarControll:New();
    self.bottomBarCtr:Init(self.bottomBar);

    self.friendRightBtsBarCtr = FriendRightBtsBarControll:New();
    self.friendRightBtsBarCtr:Init(self.rightBtsBar);

    self._ScrollView = UIUtil.GetChildByName(self.gameObject, "Transform", "scrollBg")
    self._trsScrollView = UIUtil.GetChildByName(self._ScrollView.gameObject, "Transform", "trsScrollView")
	self._scrollView = UIUtil.GetComponent(self._trsScrollView, "UIScrollView")
	self._uiTable = UIUtil.GetComponent(self._trsScrollView, "UITable")
	self._txtTimeGapGo = UIUtil.GetChildByName(self._trsScrollView, "txtTimeGap").gameObject
    self._txtTimeGapGo:SetActive(false)
	self._chatItemGo = UIUtil.GetChildByName(self._trsScrollView, "UI_ChatItem").gameObject
    self._chatItemGo:SetActive(false)
	self._chatMyItemGo = UIUtil.GetChildByName(self._trsScrollView, "UI_ChatMyItem").gameObject
    self._chatMyItemGo:SetActive(false)
--[[
    self._ScrollView = UIUtil.GetChildByName(self.gameObject, "Transform", "ScrollView");
    self._pd_phalanx = UIUtil.GetChildByName(self._ScrollView, "LuaAsynPhalanx", "pd_phalanx");
   
    self.listMax_num = 50;
    -- 列表长度最长 50
    local tem_arr = { };
    for i = 1, self.listMax_num do
        tem_arr[i] = { };
    end
    self.product_phalanx = Phalanx:New();
    self.product_phalanx:Init(self._pd_phalanx, ChatMsgItem);
    self.product_phalanx:Build(self.listMax_num, 1, tem_arr);
    ]]

    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_SELECTED, FriendRightPanelControll.FriendListItemSelected, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_DATA_CHANGE, FriendRightPanelControll.ChatDataChange, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_PLAYER_CHANGE, FriendRightPanelControll.PlayerChange, self);
    MessageManager.AddListener(FriendDataManager, FriendDataManager.MESSAGE_REMOVEFRIENDCOMPLETE, FriendRightPanelControll.RemoveFriendComplete, self);

    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_UNSELECTED, FriendRightPanelControll.RemoveFriendComplete, self);

    self:hideAllListItem();
    self:RemoveFriendComplete()
end
function FriendRightPanelControll:RemoveFriendComplete()
    self.unSelecttip.gameObject:SetActive(true);
    self.chatBg.width = 780--792;
    -- 792  722
    self.rightBtsBar.gameObject:SetActive(false);
    self._ScrollView.gameObject:SetActive(false);

end
function FriendRightPanelControll:hideAllListItem()
    --[[
    local item = self.product_phalanx._items;

    for i = 1, self.listMax_num do
        local obj = item[i].itemLogic;
        obj:SetActive(false);
    end
 ]]
end
function FriendRightPanelControll:FriendListItemSelected(target)

    self._ScrollView.gameObject:SetActive(true);
    self.unSelecttip.gameObject:SetActive(false);
    self.chatBg.width = 678;--722
    -- 792  722
    self.rightBtsBar.gameObject:SetActive(true);
    self.bottomBarCtr:ShowInput();

    self.curr_fdata = target.curr_data;
    FriendDataManager.currSelectTarget = self.curr_fdata;

    self:hideAllListItem();
    self:UpMsgs();
end
-- 聊天记录发生 改变
function FriendRightPanelControll:ChatDataChange(data)
    local id = data.s_id
    if (self.curr_fdata ~= nil and self.curr_fdata.id == id) or data.isMe then
        self:ChatReceive(data);
    end
end
function FriendRightPanelControll:PlayerChange(type)
    if FriendDataManager.currSelectTarget == nil then
        self:hideAllListItem();
    end
end
function FriendRightPanelControll:GetCurrentPid()
    return self.curr_fdata.id
end

function FriendRightPanelControll:_ClearMsg()
    for i,v in ipairs(FriendRightPanelControll.Items) do v:Dispose() end
    FriendRightPanelControll.Items = {}
    for i,v in ipairs(FriendRightPanelControll.TimeGaps) do 
        --GameObject.Destroy(v)
        if not IsNil(v) then GameObject.Destroy(v) end
    end
    FriendRightPanelControll.TimeGaps = {}
end
function FriendRightPanelControll:AddMsg(msg)
   -- PrintTable(msg)

    if msg.prohibit_show == true then
     return ;
    end

    if msg.needShowTime then 
        local tt = Resourcer.Clone(self._txtTimeGapGo,self._trsScrollView)
        tt:SetActive(true)
        UIUtil.GetComponent(tt, "UILabel").text = msg.sysTime .. ""
        insert(FriendRightPanelControll.TimeGaps, tt)
    end
    local c = ChatItem:New()
    local myMsg = msg.s_id == PlayerManager.playerId
    local cv = Resourcer.Clone(myMsg and self._chatMyItemGo or self._chatItemGo,self._trsScrollView)
    c:Init(cv.transform)
    c:InitData(msg,myMsg)
    cv:SetActive(true)
    insert(FriendRightPanelControll.Items,c)
    if self._last then self._last.nextItem = c end
    self._last = c
end
function FriendRightPanelControll:ChatReceive(data)
    --print(data.s_id , PlayerManager.playerId ,  data.msg) 
    if data.s_id == PlayerManager.playerId then self.bottomBarCtr:SendMsgComplete(data) end
    if ChatManager.isFirstMsg(data) then
        self:AddMsg(data)
    else --第二次语音翻译
        for _,value in pairs(FriendRightPanelControll.Items) do
            if ChatManager.CheckSameMsg(value.data, data) then
                value:UpdataVoiceMsg(data, data.s_id == PlayerManager.playerId)
                break
            end
        end
    end
    self:UpdateReset()
end
function FriendRightPanelControll:UpdateReset()
    self._uiTable:Reposition()
    self._scrollView:ResetPosition()
    Util.SetLocalPos(self._trsScrollView,ScrollPos.x,ScrollPos.y,ScrollPos.z)

--    self._trsScrollView.localPosition = ScrollPos
end

function FriendRightPanelControll:UpMsgs()
    
    local id =  self.curr_fdata.id;
    local msgs = FriendDataManager.GetChatMsg(id);
    local t_num = table.getn(msgs);
    local start_i = 1;
    if t_num > FriendDataManager.friend_max_num then
        start_i = t_num-FriendDataManager.friend_max_num+1;
    end

    self:_ClearMsg()
  ---  print(t_num, start_i)
    for i = t_num, start_i,-1 do
        self:AddMsg(msgs[i])
    end
    Timer.New(function() self:UpdateReset() end,0.01,1):Start()
--[[
    local item = self.product_phalanx._items;
    local item_index = self.listMax_num;

    local total_h = -self.listMax_num*130+40;

    for i = t_num, start_i,-1 do
        local obj = item[item_index].itemLogic;
        local data = msgs[i];
        local h = obj:SetData(data);
        obj:SetPos(total_h);
        total_h = total_h+h;

        item_index = item_index-1;
    end
]]
    FriendDataManager.SetHasNewChatMsg(id);
    FriendDataManager.DispatchShowChatListEvent();
    --self._ScrollView.gameObject:SetActive(false);
    --self._ScrollView.gameObject:SetActive(true);

end


function FriendRightPanelControll:Show()



end



function FriendRightPanelControll:Dispose()
    self:_ClearMsg()
    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_SELECTED, FriendRightPanelControll.FriendListItemSelected)
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_CHAT_DATA_CHANGE, FriendRightPanelControll.ChatDataChange);
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_PLAYER_CHANGE, FriendRightPanelControll.PlayerChange)
    MessageManager.RemoveListener(FriendDataManager, FriendDataManager.MESSAGE_REMOVEFRIENDCOMPLETE, FriendRightPanelControll.RemoveFriendComplete);
    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_FRIENDLISTITEM_UNSELECTED, FriendRightPanelControll.RemoveFriendComplete);

    self.bottomBarCtr:Dispose();

    self.friendRightBtsBarCtr:Dispose();

	self._trsScrollView = nil
    self._scrollView = nil
	self._uiTable = nil
	self._chatItemGo = nil
	self._chatMyItemGo = nil
    self._txtTimeGapGo = nil
end