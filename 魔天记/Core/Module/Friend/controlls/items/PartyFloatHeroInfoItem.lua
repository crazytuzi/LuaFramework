PartyFloatHeroInfoItem = class("PartyFloatHeroInfoItem");

function PartyFloatHeroInfoItem:New()
    self = { };
    setmetatable(self, { __index = PartyFloatHeroInfoItem });
    return self
end


function PartyFloatHeroInfoItem:Init(transform)
    self.transform = transform
    self.gameObject = self.transform.gameObject
    self.data = nil;

    self.levelText = UIUtil.GetChildByName(self.gameObject, "UILabel", "levelText");
    self.nameText = UIUtil.GetChildByName(self.gameObject, "UILabel", "nameText");
    self.cbloodct = UIUtil.GetChildByName(self.gameObject, "UISprite", "cbloodct");
    self.heroicon = UIUtil.GetChildByName(self.gameObject, "UISprite", "heroicon");
    self.team_leaderIcon = UIUtil.GetChildByName(self.gameObject, "Transform", "team_leaderIcon");
    self._imgLvBg = UIUtil.GetChildByName(self.gameObject,"UISprite","lvBg")
    self.onLineText = UIUtil.GetChildByName(self.gameObject, "UILabel", "onLineText");

    self.gensuiIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "gensuiIcon");

    self._onClickBtn = function(go) self:_OnClickBtn(self) end
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);

    self.gensuiIcon.gameObject:SetActive(false);

    self.active = true;

    self:SetOnlineState(0);

    MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_MENBER_SCENE_ID_CHANGE, PartyFloatHeroInfoItem.NumberScnecIdChaneg, self);

end

function PartyFloatHeroInfoItem:NumberScnecIdChaneg()
    self:SetOnlineState(0);
end


function PartyFloatHeroInfoItem:_OnClickBtn()

    ModuleManager.SendNotification(FriendNotes.OPEN_FRIENDPANEL, FriendNotes.PANEL_PARTY);
end


function PartyFloatHeroInfoItem:SetActive(v)

    if (self.active ~= v) then
        self.active = v;
        self.gameObject:SetActive(v);
    end
end

--  {"f":1128,"num":1,"k":101000,"id":1,"l":1,"n":"姜小浩"}
--[[
11:47:19.428-127: --f= [46996]
--pt= [10000]
--n= [赖霄川]
--hp= [2065]
--pid= [20100796]
--k= [101000]
--s= [1]
--mp= [3889]
--l= [47]
--p= [0]
]]
function PartyFloatHeroInfoItem:SetData(data)

    self.data = data;
    self.p_id = data.pid;

    self.levelText.text = "" .. GetLv(data.l);
    self._imgLvBg.spriteName = data.l <= 400 and "levelBg1" or "levelBg2"
    self._imgLvBg.width = data.l <= 400 and 35 or 42
    self._imgLvBg.height = data.l <= 400 and 35 or 42      
    
    self.nameText.text = "" .. data.n;

    if data.p == 1 then
        self.team_leaderIcon.gameObject:SetActive(true);
        self.team_leaderIcon.gameObject:SetActive(true);
    else
        self.team_leaderIcon.gameObject:SetActive(false);
    end

    self.heroicon.spriteName = "" .. data.k;

    self:SetActive(true);

    self.gensuiIcon.gameObject:SetActive(false);

    self:SetPhData(data)


end

function PartyFloatHeroInfoItem:SetOnlineState()

    if self.data == nil or not self.active then
        return;
    end

    if self.data.s == nil then
        self.data.s = 0;
    end

    local s = self.data.s;

    if s == 0 then
        self.onLineText.text = "";
        self.onLineText.color = Color.New(255 / 0xff, 255 / 0xff, 255 / 0xff);

    elseif s == 3 then
        self.onLineText.text = LanguageMgr.Get("Friend/PartyFloatHeroInfoItem/label1");
        self.onLineText.color = Color.New(255 / 0xff, 255 / 0xff, 255 / 0xff);
        self.gensuiIcon.gameObject:SetActive(false);
    end

    if s ~= 3 then

        local hp = self.data.hp;

        if hp <= 0 then
            self.onLineText.text = LanguageMgr.Get("Friend/PartyFloatHeroInfoItem/label2");
            self.onLineText.color = Color.New(255 / 0xff, 75 / 0xff, 75 / 0xff);
            self.gensuiIcon.gameObject:SetActive(false);
        end

        if GameSceneManager.map ~= nil then
            local in_view_info = GameSceneManager.map:GetRoleById(self.data.pid .. "");

            if in_view_info == nil then

                self.onLineText.text = LanguageMgr.Get("Friend/PartyFloatHeroInfoItem/label3");
                self.onLineText.color = Color.New(253 / 0xff, 255 / 0xff, 119 / 0xff);

                local sc_id = PartData.GetNumberInScene(self.data.pid);

                if sc_id ~= 0 and sc_id ~= nil and sc_id ~= "" then
                    local mapCf = ConfigManager.GetMapById(sc_id);
                    if mapCf ~= nil then
                        self.onLineText.text = mapCf.name;
                        self.onLineText.color = Color.New(253 / 0xff, 255 / 0xff, 119 / 0xff);
                    end
                end



                -- log("--------------------------------------------------------");
                --  PrintTable(self.data);


            end
        end



    end

end

-- l:{[pid:玩家Id，t:跟随状态 0：不跟随 1：跟随]}
function PartyFloatHeroInfoItem:GensuiMenberChange(list)

    self.gensuiIcon.gameObject:SetActive(false);

    if self.data ~= nil then

        local t_id = self.data.pid + 0;

        local len = table.getn(list);
        for i = 1, len do
            local pid = list[i].pid + 0;
            local t = list[i].t;

            if t_id == pid then
                if t == 1 then
                    self.gensuiIcon.gameObject:SetActive(true);
                end
                return;
            end
        end

    end



end

function PartyFloatHeroInfoItem:SetPhData(data)

    if data.max_hp ~= nil then
        local pc = data.hp / data.max_hp;
        if pc > 1.0 then
            pc = 1.0;
        end

        local w = 356 * pc;

        if w <= 0.01 then
            self.cbloodct.gameObject:SetActive(false);
        else
            self.cbloodct.width = w;
            self.cbloodct.gameObject:SetActive(true);
        end


    end

    if data.l ~= nil then
        self.levelText.text = "" ..  GetLv(data.l);
    end

    if self.data ~= nil then
        self.data.hp = data.hp;
        self.data.max_hp = data.max_hp;
    end

    self:SetOnlineState();

end

function PartyFloatHeroInfoItem:Show()
    self:SetActive(true);
end

function PartyFloatHeroInfoItem:Dispose()


    MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_MENBER_SCENE_ID_CHANGE, PartyFloatHeroInfoItem.NumberScnecIdChaneg);

    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtn = nil;

    self.gameObject = nil;


    self.data = nil;

    self.levelText = nil;
    self.nameText = nil;
    self.cbloodct = nil;
    self.heroicon = nil;
    self.team_leaderIcon = nil;

    self.onLineText = nil;
    self._imgLvBg = nil
    self.gensuiIcon = nil;

    self._onClickBtn = nil;

end