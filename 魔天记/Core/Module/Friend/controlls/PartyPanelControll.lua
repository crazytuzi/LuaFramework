require "Core.Module.Friend.controlls.FBApplyPanelControll";
require "Core.Module.Friend.controlls.FBNearbyTeamControll";
require "Core.Module.Friend.controlls.MyGroudPanelControll";
require "Core.Module.Friend.controlls.NearbyPlayerPanelControll";
require "Core.Module.Friend.controlls.ApplyListPanelControll";

require "Core.Module.Friend.controlls.PartData"

require "Core.Module.Common.UIComponent";

PartyPanelControll = class("PartyPanelControll", UIComponent);
PartyPanelControll.currTeamFBId = -1;

function PartyPanelControll:New(_btnParty)
    self = { };
    setmetatable(self, { __index = PartyPanelControll });
    self:Set_btnParty(_btnParty);
    return self
end

function PartyPanelControll:_Init()
	self:_InitReference();
	
end

function PartyPanelControll:_InitReference()
   

    local trss = UIUtil.GetComponentsInChildren(self._transform, "Transform");
    self._FBApplyPanel = UIUtil.GetChildInComponents(trss, "FBApplyPanel");
    self._ApplyListPanel = UIUtil.GetChildInComponents(trss, "ApplyListPanel");
    self._MyGroudPanel = UIUtil.GetChildInComponents(trss, "MyGroudPanel");
    self._NearbyPlayerPanel = UIUtil.GetChildInComponents(trss, "NearbyPlayerPanel");
    self._FBNearbyTeam = UIUtil.GetChildInComponents(trss, "FBNearbyTeam");

    self.clearAskListBt = UIUtil.GetChildByName(self._transform, "UIButton", "clearAskListBt");


    self.groudToggle = UIUtil.GetChildByName(self._transform, "Transform", "groudToggle");



    self.gbts = UIUtil.GetChildByName(self._transform, "Transform", "gbts");

    self.groudDoBt = UIUtil.GetChildByName(self.gbts, "UIButton", "groudDoBt");
    self.groudDoBtLabel = UIUtil.GetChildByName(self.groudDoBt, "UILabel", "Label");

    self.groudDo1Bt = UIUtil.GetChildByName(self.gbts, "UIButton", "groudDo1Bt");
    self.groudDo1BtLabel = UIUtil.GetChildByName(self.groudDo1Bt, "UILabel", "Label");

    self.groudDo2Bt = UIUtil.GetChildByName(self.gbts, "UIButton", "groudDo2Bt");
    self.groudDo2Pos = self.groudDo2Bt.transform.localPosition;


    self.groudDo1Bt.gameObject:SetActive(false);
    self.groudDo2Bt.gameObject:SetActive(false);
    Util.SetLocalPos(self.groudDo2Bt, self.groudDo1Bt.transform.localPosition)

    --    self.groudDo2Bt.transform.localPosition = self.groudDo1Bt.transform.localPosition;
    self.clearAskListBt.gameObject:SetActive(false);

    self.groudDoBtHandler = function(go) self:GroudDoBtHandler(self) end
    UIUtil.GetComponent(self.groudDoBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self.groudDoBtHandler);

    self.groudDo1BtHandler = function(go) self:GroudDo1BtHandler(self) end
    UIUtil.GetComponent(self.groudDo1Bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self.groudDo1BtHandler);

    self.groudDo2BtHandler = function(go) self:GroudDo2BtHandler(self) end
    UIUtil.GetComponent(self.groudDo2Bt, "LuaUIEventListener"):RegisterDelegate("OnClick", self.groudDo2BtHandler);

    self.clearAskListBtHandler = function(go) self:ClearAskListBtHandler(self) end
    UIUtil.GetComponent(self.clearAskListBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self.clearAskListBtHandler);

    MessageManager.AddListener(FriendNotes, FriendNotes.EVENT_CHANGE_INSTANCE, PartyPanelControll._OnChangeInstanceHandler, self);

    self._FBApplyPanelControll = FBApplyPanelControll:New();
    self._ApplyListPanelControll = ApplyListPanelControll:New();
    self._FBNearbyTeamControll = FBNearbyTeamControll:New();
    self._MyGroudPanelControll = MyGroudPanelControll:New();
    self._NearbyPlayerPanelControll = NearbyPlayerPanelControll:New();

    self._FBApplyPanelControll:Init(self._FBApplyPanel.gameObject);
    self._ApplyListPanelControll:Init(self._ApplyListPanel.gameObject, self.clearAskListBt);
    self._FBNearbyTeamControll:Init(self._FBNearbyTeam.gameObject);
    self._MyGroudPanelControll:Init(self._MyGroudPanel.gameObject, self.groudDo2Bt);
    self._NearbyPlayerPanelControll:Init(self._NearbyPlayerPanel.gameObject);


    local chbs = UIUtil.GetComponentsInChildren(self._transform, "UIToggle");

    self.voluntarilyApplyTeam = UIUtil.GetChildInComponents(chbs, "voluntarilyApplyTeam");
    self.voluntarilyApplyTeamAsk = UIUtil.GetChildInComponents(chbs, "voluntarilyApplyTeamAsk");



    self.voluntarilyApplyTeamHandler = function(go) self:VoluntarilyApplyTeamHandler(self) end
    UIUtil.GetComponent(self.voluntarilyApplyTeam, "LuaUIEventListener"):RegisterDelegate("OnClick", self.voluntarilyApplyTeamHandler);

    self.voluntarilyApplyTeamAskHandler = function(go) self:VoluntarilyApplyTeamAskHandler(self) end
    UIUtil.GetComponent(self.voluntarilyApplyTeamAsk, "LuaUIEventListener"):RegisterDelegate("OnClick", self.voluntarilyApplyTeamAskHandler);


    self:SetTagleHandler(FriendNotes.classify_btnMyGroud);
    self:SetTagleHandler(FriendNotes.classify_btnApplyList);
    self:SetTagleHandler(FriendNotes.classify_btnNearbyPlayer);
    self:SetTagleHandler(FriendNotes.classify_btnNearbyTeam);

    self:SetTagleSelect(FriendNotes.classify_btnMyGroud);
    self:Classify_OnClick(FriendNotes.classify_btnMyGroud);



    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartyPanelControll.PartDataChangeHandler, self);
    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_PARTCFDATARESULT, PartyPanelControll.PartCfDataResult, self);
    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_PARTSETCFDATARESULT, PartyPanelControll.PartSetCfDataResult, self);
    MessageManager.AddListener(FriendNotes, FriendNotes.MESSAGE_GETPARTYDRESSRESULT, MyGroudPanelControll.GetPartyDressResult, self._MyGroudPanelControll);

    MessageManager.AddListener(FriendProxy, FriendProxy.MESSAGE_NEED_SHOW_APPLYTEARMLIST_TIP, PartyPanelControll.CheckAndShowAplTip, self);


    self.btnApplyList_hasApplyListTip.gameObject:SetActive(false);


    self:CheckAndShowAplTip()
    self._MyGroudPanelControll:GetPartyDressResult(FriendProxy._PartyDressData);
    
end

function PartyPanelControll:Set_btnParty(_btnParty)
   
    self._btnParty = _btnParty;
    self._btnParty_hasApplyListTip = UIUtil.GetChildByName(self._btnParty, "Transform", "hasApplyListTip");
    self._btnParty_hasApplyListTip.gameObject:SetActive(false);

end

function PartyPanelControll:_OnChangeInstanceHandler(id)
    self:SetInstanceId(id);
end

function PartyPanelControll:SetInstanceId(val)
    self._currInstanceId = val
    -- self.groudDo2Bt.gameObject:SetActive(self._currInstanceId ~= nil);
    self._MyGroudPanelControll:SetInstanceId(val);
end

function PartyPanelControll:CheckAndShowAplTip()

    local t_num = table.getn(PartData.applyTearmList);
    if t_num > 0 then
        -- 需要显示提示
        self.btnApplyList_hasApplyListTip.gameObject:SetActive(true);
        self._btnParty_hasApplyListTip.gameObject:SetActive(true);

    else
        self.btnApplyList_hasApplyListTip.gameObject:SetActive(false);
        self._btnParty_hasApplyListTip.gameObject:SetActive(false);

    end

end

function PartyPanelControll:VoluntarilyApplyTeamHandler()


    if self.voluntarilyApplyTeam.value == true then
        self:SetColuntarilyData(2, 1);
    else
        self:SetColuntarilyData(2, 0);
    end

end

function PartyPanelControll:VoluntarilyApplyTeamAskHandler()

    if self.voluntarilyApplyTeamAsk.value == true then
        self:SetColuntarilyData(1, 1);
    else
        self:SetColuntarilyData(1, 0);
    end

end

function PartyPanelControll:SetTagleHandler(name)

    self[name .. "Handler"] = function(go) self:Classify_OnClick(name) end
    self["_" .. name] = UIUtil.GetChildByName(self.groudToggle, "Transform", name).gameObject;
    UIUtil.GetComponent(self["_" .. name], "LuaUIEventListener"):RegisterDelegate("OnClick", self[name .. "Handler"]);

    if name == "btnApplyList" then
        self.btnApplyList_hasApplyListTip = UIUtil.GetChildByName(self["_" .. name], "Transform", "hasApplyListTip");
    end

end



function PartyPanelControll:RemoveTagleHandler(name)

    UIUtil.GetComponent(self["_" .. name], "LuaUIEventListener"):RemoveDelegate("OnClick");
    self[name .. "Handler"] = nil;

end

function PartyPanelControll:SetTagleSelect(name)

    local gobj = UIUtil.GetChildByName(self.groudToggle, "Transform", name).gameObject;
    local toggle = UIUtil.GetComponent(gobj, "UIToggle");
    toggle.value = true;
end

function PartyPanelControll:Classify_OnClick(name)

    self.clearAskListBt.gameObject:SetActive(false);
    self.gbts.gameObject:SetActive(true);

    if self._curr_classify ~= name then
        self._curr_classify = name;
        if name == FriendNotes.classify_btnMyGroud then

            self._FBApplyPanelControll:Close();
            self._FBNearbyTeamControll:Close();
            self._MyGroudPanelControll:Show();
            self._NearbyPlayerPanelControll:Close();
            self._ApplyListPanelControll:Close();
            -- 尝试获取当前副本 id
            FriendProxy.TryGetTeamFBID();


        elseif name == FriendNotes.classify_btnApplyList then



            self._FBApplyPanelControll:Close();
            self._FBNearbyTeamControll:Close();
            self._MyGroudPanelControll:Close();
            self._NearbyPlayerPanelControll:Close();
            self._ApplyListPanelControll:Show();


            self.gbts.gameObject:SetActive(false);


            local b = PartData.MeIsTeamLeader();
            if b then
                self.clearAskListBt.gameObject:SetActive(true);
            else
                self.clearAskListBt.gameObject:SetActive(false);
            end


        elseif name == FriendNotes.classify_btnNearbyPlayer then
            self._FBApplyPanelControll:Close();
            self._FBNearbyTeamControll:Close();
            self._MyGroudPanelControll:Close();
            self._NearbyPlayerPanelControll:Show();
            self._ApplyListPanelControll:Close();

        elseif name == FriendNotes.classify_btnNearbyTeam then
            self._FBApplyPanelControll:Close();
            self._FBNearbyTeamControll:Show();
            self._MyGroudPanelControll:Close();
            self._NearbyPlayerPanelControll:Close();
            self._ApplyListPanelControll:Close();
        end
    end

end


function PartyPanelControll:GroudDoBtHandler()

    if self.btType == 1 then
        self:TryCreateArmy();
    elseif self.btType == 2 then
        -- 解散队伍
        self:DismissArmy();
    elseif self.btType == 3 then
        -- 退出队伍
        self:SecedeArmy();
    end

end

-- 解散队伍
function PartyPanelControll:GroudDo1BtHandler()


    self:DismissArmy();

end

function PartyPanelControll:GroudDo2BtHandler()
    if (self._currInstanceId) then
        local tnum = PartData.GetMyTeamNunberNum();
        if (tnum > 0) then
            if (PartData.MeIsTeamLeader()) then
                -- 打开雇佣面板
                HirePlayerProxy.LoadDataByInstanceId(self._currInstanceId)
            else
                -- 提示非队长，不能雇佣
                MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("Friend/PartyPanelControll/tip5"));
            end
        else
            -- 没有队伍，自动创建
            self:TryCreateArmy();
            HirePlayerProxy.LoadDataByInstanceId(self._currInstanceId)
        end
    end
end

function PartyPanelControll:ClearAskListBtHandler()


    self._ApplyListPanelControll:ClearAskList();

end



function PartyPanelControll:Show()
    self._gameObject:SetActive(true);
    self:TryGetConfigData();
    self:PartDataChangeHandler( { isShow = true });
end

function PartyPanelControll:close()
    self._gameObject:SetActive(false);
end


function PartyPanelControll:TryGetConfigData()

    FriendProxy:TryPartCfData()

end

--[[
10 获取自动接受邀请/自动接受入队伍参数
输入：

输出：
inv：自动接受组队邀请（0:关闭1:开启）
acc：自动接受入队申请（0:关闭1:开启）
0x0B10
]]
function PartyPanelControll:PartCfDataResult(data)
    self.voluntarilyData = data;
    self:UpColuntarilyData();
end


function PartyPanelControll:UpColuntarilyData()
    local inv = self.voluntarilyData.inv;
    local acc = self.voluntarilyData.acc;


    if inv == 1 then
        self.voluntarilyApplyTeamAsk.value = true;
    else
        self.voluntarilyApplyTeamAsk.value = false;
    end

    if acc == 1 then
        self.voluntarilyApplyTeam.value = true;
    else
        self.voluntarilyApplyTeam.value = false;
    end

end


---------------------------------------------------------------------------------------------
--[[
09 自动接受邀请/自动接受入队伍设置
输入:
t: （1:自动接受邀请 2:自动接受入队）
s: （0:关闭 1:开启）

输出：
t: （1:自动接受邀请 2:自动接受入队）
s: （0:关闭 1:开启）
0x0B09

]]
function PartyPanelControll:SetColuntarilyData(t, s)

    FriendProxy.TryPartSetCfData(t, s)

end

function PartyPanelControll:PartSetCfDataResult(data)

    local t = data.t;
    local s = data.p;

    if t == 1 then
        self.voluntarilyData.inv = s;
    else
        self.voluntarilyData.acc = s;
    end

    -- self:UpColuntarilyData();


end

---------------------------------------------------------------------------------------------


-- 退出队伍
function PartyPanelControll:SecedeArmy()
    -- LeaveTeam
    -- 如果在 组队副本中的时候， 需要 提示 ： 退出队伍后，将会同时退出副本，确定退出队伍吗？

    local curr_fb_id = PartyPanelControll.currTeamFBId;

    if curr_fb_id ~= -1 then

        local cf = InstanceDataManager.GetMapCfById(curr_fb_id);
        local enter_type = cf.enter_type;
        if enter_type == 2 or enter_type == 3 then
            -- http://192.168.0.8:3000/issues/4770
            ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                title = LanguageMgr.Get("common/notice"),
                msg = LanguageMgr.Get("Friend/PartyPanelControll/tip1"),
                ok_Label = LanguageMgr.Get("common/ok"),
                cance_lLabel = LanguageMgr.Get("common/give_up"),
                hander = PartyPanelControll.SureSecedeArmy,
                target = self;
                data = nil
            } );
            return;
        end

    end

    self:SureSecedeArmy()

end


function PartyPanelControll:SureSecedeArmy()

    if PartyPanelControll.currTeamFBId ~= -1 then
        ModuleManager.SendNotification(FriendNotes.CLOSE_FRIENDPANEL);
    end

    SocketClientLua.Get_ins():SendMessage(CmdType.LeaveTeam, { });
end



-- 解散队伍
function PartyPanelControll:DismissArmy()

    SocketClientLua.Get_ins():SendMessage(CmdType.DismissTeam, { });

end





function PartyPanelControll:TryCreateArmy()

    FriendProxy.TryCreateArmy()

end


--[[
	a）当没有队伍时
		创建队伍
	b）当有队伍，但只有自己一人时
		解散队伍
	c）当有队伍，且队伍成员不止一人时
		解散队伍	退出队伍
	d）当有队伍，身份为队员时
		退出队伍

]]
function PartyPanelControll:PartDataChangeHandler(data)

    local myTeamData = PartData.GetMyTeam();

    if data == nil then
        self._MyGroudPanelControll:UpData();
    end

    if myTeamData == nil then
        -- 没有队伍 ， 可以创建队伍
        self.groudDoBtLabel.text = LanguageMgr.Get("Friend/PartyPanelControll/tip2");
        self.groudDo1Bt.gameObject:SetActive(false);
        Util.SetLocalPos(self.groudDo2Bt, self.groudDo1Bt.transform.localPosition)

        --        self.groudDo2Bt.transform.localPosition = self.groudDo1Bt.transform.localPosition;
        self.btType = 1;
    else

        self.groudDoBtLabel.text = LanguageMgr.Get("Friend/PartyPanelControll/tip4");
        self.groudDo1Bt.gameObject:SetActive(false);
        Util.SetLocalPos(self.groudDo2Bt, self.groudDo1Bt.transform.localPosition)

        --        self.groudDo2Bt.transform.localPosition = self.groudDo1Bt.transform.localPosition;
        self.btType = 3;

        --        local m = myTeamData.m;
        --        local len = table.getn(m);

        --        if len == 1 then
        --            self.groudDoBtLabel.text = LanguageMgr.Get("Friend/PartyPanelControll/tip4");
        --            self.groudDo1Bt.gameObject:SetActive(false);
        --            self.groudDo2Bt.transform.localPosition = self.groudDo1Bt.transform.localPosition;
        --            self.btType = 3;
        --        else

        --            -- 判断 自己是否是 队长
        --            local myHero = HeroController.GetInstance();
        --            local mydata = PartData.FindMyTeammateData(myHero.info.id);

        --            if mydata.p == 1 then
        --                self.groudDoBtLabel.text = LanguageMgr.Get("Friend/PartyPanelControll/tip4");
        --                self.groudDo1BtLabel.text = LanguageMgr.Get("Friend/PartyPanelControll/tip3");
        --                self.groudDo1Bt.gameObject:SetActive(true);
        --                self.groudDo2Bt.transform.localPosition = self.groudDo2Pos
        --                self.btType = 3;
        --            else
        --                self.groudDoBtLabel.text = LanguageMgr.Get("Friend/PartyPanelControll/tip4");
        --                self.groudDo1Bt.gameObject:SetActive(false);
        --                self.groudDo2Bt.transform.localPosition = self.groudDo1Bt.transform.localPosition;
        --                self.btType = 3;
        --            end

        --        end


    end


end


function PartyPanelControll:Dispose()
    MessageManager.RemoveListener(FriendNotes, FriendNotes.EVENT_CHANGE_INSTANCE, PartyPanelControll._OnChangeInstanceHandler);
    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE, PartyPanelControll.PartDataChangeHandler);
    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_PARTCFDATARESULT, PartyPanelControll.PartCfDataResult);
    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_PARTSETCFDATARESULT, PartyPanelControll.PartSetCfDataResult);
    MessageManager.RemoveListener(FriendNotes, FriendNotes.MESSAGE_GETPARTYDRESSRESULT, MyGroudPanelControll.GetPartyDressResult);
    MessageManager.RemoveListener(FriendProxy, FriendProxy.MESSAGE_NEED_SHOW_APPLYTEARMLIST_TIP, PartyPanelControll.CheckAndShowAplTip);

    UIUtil.GetComponent(self.voluntarilyApplyTeam, "LuaUIEventListener"):RemoveDelegate("OnClick");

    UIUtil.GetComponent(self.voluntarilyApplyTeamAsk, "LuaUIEventListener"):RemoveDelegate("OnClick");



    UIUtil.GetComponent(self.groudDoBt, "LuaUIEventListener"):RemoveDelegate("OnClick");


    UIUtil.GetComponent(self.groudDo1Bt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    UIUtil.GetComponent(self.groudDo2Bt, "LuaUIEventListener"):RemoveDelegate("OnClick");


    UIUtil.GetComponent(self.clearAskListBt, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self.clearAskListBtHandler = nil;

    self.groudDoBtHandler = nil;
    self.groudDo1BtHandler = nil;
    self.groudDo2BtHandler = nil;

    self.voluntarilyApplyTeamHandler = nil;
    self.voluntarilyApplyTeamAskHandler = nil;

    self._FBApplyPanelControll:Dispose();
    self._ApplyListPanelControll:Dispose();
    self._FBNearbyTeamControll:Dispose();
    self._MyGroudPanelControll:Dispose();
    self._NearbyPlayerPanelControll:Dispose();

    self:RemoveTagleHandler(FriendNotes.classify_btnMyGroud);
    self:RemoveTagleHandler(FriendNotes.classify_btnApplyList);
    self:RemoveTagleHandler(FriendNotes.classify_btnNearbyPlayer);
    self:RemoveTagleHandler(FriendNotes.classify_btnNearbyTeam);

    self._FBApplyPanelControll = nil;
    self._ApplyListPanelControll = nil;
    self._FBNearbyTeamControll = nil;
    self._MyGroudPanelControll = nil;
    self._NearbyPlayerPanelControll = nil;



    self._FBApplyPanel = nil;
    self._MyGroudPanel = nil;
    self._NearbyPlayerPanel = nil;
    self._FBNearbyTeam = nil;



    self.groudToggle = nil;

    self.groudDoBt = nil;
    self.groudDoBtLabel = nil;

    self.groudDo1Bt = nil;
    self.groudDo1BtLabel = nil;

    self.voluntarilyApplyTeam = nil;
    self.voluntarilyApplyTeamAsk = nil;

    self.voluntarilyApplyTeamHandler = nil;

    self.voluntarilyApplyTeamAskHandler = nil;



end