HeroDealItem = class("HeroDealItem");
HeroDealItem.ins = nil;

function HeroDealItem:New()
    self = { };
    setmetatable(self, { __index = HeroDealItem });
    return self
end


function HeroDealItem:Init(gameObject)

    self.gameObject = gameObject

    self.bg = UIUtil.GetChildByName(self.gameObject, "UISprite", "bg");


    self.dealBt1 = UIUtil.GetChildByName(self.gameObject, "UIButton", "dealBt1");
    self.dealBt2 = UIUtil.GetChildByName(self.gameObject, "UIButton", "dealBt2");
    self.dealBt3 = UIUtil.GetChildByName(self.gameObject, "UIButton", "dealBt3");
    self.dealBt4 = UIUtil.GetChildByName(self.gameObject, "UIButton", "dealBt4");

    self.deal1BtHandler = function(go) self:DealBtHandler(1) end
    self.deal2BtHandler = function(go) self:DealBtHandler(2) end
    self.deal3BtHandler = function(go) self:DealBtHandler(3) end
    self.deal4BtHandler = function(go) self:DealBtHandler(4) end

    self.bgClick = function(go) self:BgClick() end

    UIUtil.GetComponent(self.dealBt1, "LuaUIEventListener"):RegisterDelegate("OnClick", self.deal1BtHandler);
    UIUtil.GetComponent(self.dealBt2, "LuaUIEventListener"):RegisterDelegate("OnClick", self.deal2BtHandler);
    UIUtil.GetComponent(self.dealBt3, "LuaUIEventListener"):RegisterDelegate("OnClick", self.deal3BtHandler);
    UIUtil.GetComponent(self.dealBt4, "LuaUIEventListener"):RegisterDelegate("OnClick", self.deal4BtHandler);

    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RegisterDelegate("OnClick", self.bgClick);


    self:SetActive(false);

end

function HeroDealItem:BgClick()

    self:SetActive(false);

end


function HeroDealItem:HideAllBts()

    self.dealBt1.gameObject:SetActive(false);
    self.dealBt2.gameObject:SetActive(false);
    self.dealBt3.gameObject:SetActive(false);
    self.dealBt4.gameObject:SetActive(false);

end


function HeroDealItem:SetActive(v)
    self.gameObject.gameObject:SetActive(v);
end

--  {"f":1128,"num":1,"k":101000,"id":1,"l":1,"n":"姜小浩"}
function HeroDealItem:SetData(data)

    self.data = data;

end


function HeroDealItem:Show(index)

    self.index = index;


    local tempPos = Vector3.zero
    if self.index == 1 then
        tempPos = Vector3.New(-651, 0, 0);
    elseif self.index == 2 then
        tempPos = Vector3.New(-390, 0, 0);
    elseif self.index == 3 then
        tempPos = Vector3.New(-103, 0, 0);
    elseif self.index == 4 then
        tempPos = Vector3.New(145, 0, 0);
    end
    Util.SetLocalPos(self.gameObject, tempPos.x, tempPos.y, tempPos.z)


    if HeroDealItem.ins ~= nil then
        HeroDealItem.ins:SetActive(false);
    end

    local myHero = HeroController.GetInstance();
    local mydata = PartData.FindMyTeammateData(myHero.info.id);

    self:SetActive(true);
    self:HideAllBts();

    if myHero.info.id == self.data.pid then
        self.bg.gameObject:SetActive(false);
    else
        self.bg.gameObject:SetActive(true);
        self.cmds = { };
        if mydata ~= nil and mydata.p == 1 then
            -- 自己是队长
            local btlabel;

            btlabel = UIUtil.GetChildByName(self.dealBt1, "UILabel", "Label");
            btlabel.text = LanguageMgr.Get("Friend/HeroDealItem/tipLabel1");
            self.cmds[1] = 1;
            self.dealBt1.gameObject:SetActive(true);

            btlabel = UIUtil.GetChildByName(self.dealBt2, "UILabel", "Label");
            btlabel.text = LanguageMgr.Get("Friend/HeroDealItem/tipLabel2");
            self.cmds[2] = 2;
            self.dealBt2.gameObject:SetActive(true);

            btlabel = UIUtil.GetChildByName(self.dealBt3, "UILabel", "Label");
            btlabel.text = LanguageMgr.Get("Friend/HeroDealItem/tipLabel3");
            self.cmds[3] = 3;
            self.dealBt3.gameObject:SetActive(true);

            btlabel = UIUtil.GetChildByName(self.dealBt4, "UILabel", "Label");
            btlabel.text = LanguageMgr.Get("Friend/HeroDealItem/tipLabel4");
            self.cmds[4] = 4;
            self.dealBt4.gameObject:SetActive(true);

            self.bg.height = 220;

        else
            -- 自己是成员
            btlabel = UIUtil.GetChildByName(self.dealBt1, "UILabel", "Label");
            btlabel.text = LanguageMgr.Get("Friend/HeroDealItem/tipLabel5");
            self.cmds[1] = 3;
            self.dealBt1.gameObject:SetActive(true);

            btlabel = UIUtil.GetChildByName(self.dealBt2, "UILabel", "Label");
            btlabel.text = LanguageMgr.Get("Friend/HeroDealItem/tipLabel6");
            self.cmds[2] = 4;
            self.dealBt2.gameObject:SetActive(true);

            self.bg.height = 115;

        end

    end



    HeroDealItem.ins = self;
end


function HeroDealItem:DealBtHandler(index)

    local cmd = self.cmds[index];

    if cmd == 1 then
        --  升为队长
        self:UpToTeamLeader()
    elseif cmd == 2 then
        -- 请离队伍
        self:GetOutFromTeam()
    elseif cmd == 3 then
        -- 加为好友
        AddFriendsProxy.TryAddFriend(self.data.pid, nil)
    elseif cmd == 4 then
        -- 查看信息
        ModuleManager.SendNotification(OtherInfoNotes.OPEN_INFO_PANEL, self.data.pid);
    end

    self:SetActive(false);
end

--[[
08 任命队长
输入:
pid:任命队长的玩家ID

输出：
pid：新队长玩家id
0x0B08

]]
function HeroDealItem:UpToTeamLeader()

    FriendProxy.TryUpToTeamLeader(self.data.pid)
end


--[[
07 队长踢人
输入:
pid:被踢玩家ID

输出：
pid：被踢玩

]]
function HeroDealItem:GetOutFromTeam()

    FriendProxy.TryGetOutFromTeam(self.data.pid);
end


function HeroDealItem:Dispose()

    UIUtil.GetComponent(self.dealBt1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.dealBt2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.dealBt3, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.dealBt4, "LuaUIEventListener"):RemoveDelegate("OnClick");

    UIUtil.GetComponent(self.bg, "LuaUIEventListener"):RemoveDelegate("OnClick");

    self.deal1BtHandler = nil;
    self.deal2BtHandler = nil;
    self.deal3BtHandler = nil;
    self.deal4BtHandler = nil;

    self.bgClick = nil;

    self.gameObject = nil;

    self.bg = nil;


    self.dealBt1 = nil;
    self.dealBt2 = nil;
    self.dealBt3 = nil;
    self.dealBt4 = nil;


end