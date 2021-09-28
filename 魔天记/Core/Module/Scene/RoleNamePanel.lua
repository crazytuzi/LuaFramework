require "Core.Module.Common.UIComponent"
require "Core.Module.Common.TitleItem"
require "Core.Module.Scene.RoleNameSimple"

RoleNamePanel = class("RoleNamePanel", RoleNameSimple)

local DEFAULT_COLOR = Color.New(1, 1, 1, 1);
local up = Vector3.up
 -- 宠物筛选
local guildDes = LanguageMgr.Get("RoleNamePanel/Guild")

local tremove = table.remove
local tinsert = table.insert
local maxNum = 30
local labels = {}
local timer
function RoleNamePanel.OnTimerHandler()
    local ls = labels
    local len = #ls
    if len == 0 then return end
    --local t = os.time()
    local tf = RoleNamePanel.updateTeamFlg
    for i = len, 1, -1 do 
        local l = ls[i]
        if l._dispose then
            tremove(ls, i)
        else
            l:_OnTimerHandler()
            --l:_OnTimerHandler(t)
            if tf and l.UpdateTeam then l:UpdateTeam() end
        end
    end
    RoleNamePanel.updateTeamFlg = false
end
function RoleNamePanel.Add(role, player)
    local r
    if player then
        r = RoleNamePanel:New(role)
    else
        r = RoleNameSimple:New(role)
    end
    tinsert(labels, r)

    if not timer then
        timer = Timer.New( RoleNamePanel.OnTimerHandler, 0, -1, false);
        timer:Start()
        MessageManager.RemoveListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE,RoleNamePanel.UpdateTeamFlg)
        MessageManager.AddListener(PartData, PartData.MESSAGE_PARTY_DATA_CHANGE,RoleNamePanel.UpdateTeamFlg)
    end
end
function RoleNamePanel.UpdateTeamFlg()
    RoleNamePanel.updateTeamFlg = true
end
function RoleNamePanel.Clear()
    if timer then timer:Stop() timer = nil end
    RoleNamePanel.UpdateTeamFlg()
    local ls = labels
    local len = #ls
    if len == 0 then return end
    for i = len, 1, -1 do  ls[i]:Dispose() end
    labels = {}
end




function RoleNamePanel:New(role)
    self = { };
    setmetatable(self, { __index = RoleNamePanel });
    self:_LoadUI();
    self:_SetRole(role);
    return self;
end
function RoleNamePanel:_GetUIPath()
    return ResID.UI_ROLENAMEPANEL
end
function RoleNamePanel:_OnSetRole(role)
    self:UpdateOtherInfo()
    self:RefreshRealm()
end

function RoleNamePanel:UpdateOtherInfo()
    --if (self._role.roleType == ControllerType.HERO or self._role.roleType == ControllerType.PLAYER) then
        local pos = 25
        
        if (self._role.roleType == ControllerType.HERO) then

            if (GuildDataManager.data) then                
                self._txtGuild.text = guildDes .. GuildDataManager.data.name
                Util.SetLocalPos(self._txtGuild, 0, pos, 0)
                pos = pos + 26
                --                self._txtGuild.transform.localPosition = Vector3.up * pos
            else
                self._txtGuild.text = ""
            end
        if (self._txtRealm.text ~= "") then
            Util.SetLocalPos(self._txtRealm, 0, pos, 0)
            pos = pos + 26
        end
            ---Warning(self._role.gameObject.name ..tostring(TitleManager.GetCurrentEquipTitleId()))
            if (TitleManager.GetCurrentEquipTitleId() ~= 0) then                 
                self._titleItem:UpdateItem(TitleManager.GetCurrentEquipTitleData())
                Util.SetLocalPos(self._titleItem.transform, 0, pos, 0)    
                pos = pos + self._titleItem.height
                --                self._titleItem.transform.localPosition = Vector3.up * pos
            else
                self._titleItem:UpdateItem(nil)
            end

        elseif (self._role.roleType == ControllerType.PLAYER) then
            if (self._role.info.tgn) then
                self._txtGuild.text = guildDes .. self._role.info.tgn
                Util.SetLocalPos(self._txtGuild, 0, pos, 0)
                pos = pos + 26
            else
                self._txtGuild.text = ""
            end
            if (self._txtRealm.text ~= "") then
                Util.SetLocalPos(self._txtRealm, 0, pos, 0)
                pos = pos + 26
            end
            if (self._role.info.titleData) then                           
                self._titleItem:UpdateItem(self._role.info.titleData)
                Util.SetLocalPos(self._titleItem.transform, 0, pos, 0)    
                pos = pos + self._titleItem.height            
                --                self._titleItem.transform.localPosition = Vector3.up * pos
            else
                self._titleItem:UpdateItem(nil)
            end            
        end
        
        if (self:_SetMountName(pos)) then
            pos = pos + 26
        end

        if (self._imgCamp.gameObject.activeSelf) then
             Util.SetLocalPos(self._imgCamp.transform, 0, pos + 13, 0)
            pos = pos + 50
        end

        Util.SetLocalPos(self._imgAffiliation.transform, 0, pos - 13, 0)
--    else
--        self._txtGuild.text = ""
--        self._txtmountName.text = ""
--        self._titleItem:UpdateItem(nil)
--    end
end

function RoleNamePanel:_SetMountName(pos)
    local mountName = self._role:GetMountName();
    if mountName ~= nil then
        self._txtmountName.text = mountName .. "";
        Util.SetLocalPos(self._txtmountName, 0, pos, 0)
        return true
    else
        self._txtmountName.text = "";
    end
    return false;
end


function RoleNamePanel:_Init()
    self._txtName = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtName");
    self._txtName.text = "";
    self._txtRealm = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtRealm");
    self._txtRealm.text = "";
    self._imgPartIcon = UIUtil.GetChildByName(self._gameObject, "UISprite", "partIcon");


    self._txtmountName = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtmountName")
    self._txtmountName.text = "";

    self._txtGuild = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtGuild")
    self._txtGuild.text = "";
    self._trsTitleItem = UIUtil.GetChildByName(self._gameObject, "trsTitleItem")
    self._titleItem = TitleItem:New()
    self._titleItem:Init(self._trsTitleItem)

    self._imgCamp = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgCamp");
    self._imgCamp.spriteName = ""

    self._imgAffiliation = UIUtil.GetChildByName(self._gameObject, "UISprite", "imgAffiliation");
    self._imgPartIcon.spriteName = ""

    --self.checkTime = os.time()
    -- self:SetActive(false);--不知道干嘛用的 去掉
end



function RoleNamePanel:SetTop(tsTop)
    self.tempTop = tsTop
    if not self.tempTop and self._role then
        self.tempTop = self._role:GetNamePoint()
    end
end

function RoleNamePanel:_OnTimerHandler(t)
    local role = self._role;
    if role then
        self:TracePos(role)
        local info = role.info
        if info then
            if (self._pkState ~= info.pkState) then
                self:_RefreshNameColor();
            end
--            if t - self.checkTime > 5 then
--                self:UpdateTeamInfo(PartData.FindMyTeammateData(info.id))
--                self.checkTime = os.time()
--            end
        end
    end
end
function RoleNamePanel:UpdateTeam()
    local role = self._role;
    if role and role.info then self:UpdateTeamInfo(PartData.FindMyTeammateData(role.info.id)) end
end
function RoleNamePanel:UpdateTeamInfo(tinfo)
    if tinfo ~= nil then
        if tinfo.p == 1 then
            self._imgPartIcon.spriteName = "duizhang";
        else
            self._imgPartIcon.spriteName = "duiyuan";
        end
    else
        self._imgPartIcon.spriteName = ""
    end
    if TabooProxy.InTaboo() then --禁忌这地, 刷新攻击状态
        self:_RefreshNameColor()
    end 
end

function RoleNamePanel:_RefreshNameColor()
    local r = self._role
    if (r and r.info and self._txtName) then
        local rType = r.roleType;
        local map = GameSceneManager.map;
        local blArathi = false;
        if (map and map.info and map.info.type == InstanceDataManager.MapType.ArathiWar) then
            blArathi = true
        end
        if (rType == ControllerType.HERO) then
            self._txtName.color = ColorDataManager.GetHeroNameColor(r.info.pkState,blArathi);
            self._pkState = r.info.pkState;
        elseif (rType == ControllerType.PLAYER) then
            self._txtName.color = ColorDataManager.GetPlayerNameColor(r.info.pkState,blArathi);
            self._pkState = r.info.pkState;
        elseif (rType == ControllerType.MONSTER) then
            self._txtName.color = ColorDataManager.GetMonsterNameColor();
        elseif (rType == ControllerType.PET or rType == ControllerType.HEORPET) then
            self._txtName.color = ColorDataManager.GetColorByQuality(r.info.quality)
        elseif (rType == ControllerType.NPC) then
            self._txtName.color = ColorDataManager.GetNPCNameColor();
        else
            self._txtName.color = DEFAULT_COLOR;
        end
        if TabooProxy.InTaboo() and TabooProxy.CanAttack(r) then
            self._txtName.color = ColorDataManager.GetPkRed()
        end
    end
end

function RoleNamePanel:ShowAffiliation()
    if (self._imgAffiliation) then
        self._imgAffiliation.gameObject:SetActive(true)
    end
end

function RoleNamePanel:HideAffiliation()
    if (self._imgAffiliation) then
        self._imgAffiliation.gameObject:SetActive(false)
    end
end

function RoleNamePanel:RefreshRoleCamp()
    local role = self._role;
    local map = GameSceneManager.map;
    if (role and map  and map.info 
        and (map.info.type == InstanceDataManager.MapType.ArathiWar or map.info.type == InstanceDataManager.MapType.GuildWar)
        and (role.roleType == ControllerType.PLAYER or role.roleType == ControllerType.HERO)) then
    --if (role and map  and map.info and(role.roleType == ControllerType.PLAYER or role.roleType == ControllerType.HERO)) then
        self._imgCamp.gameObject:SetActive(true)
        self._imgCamp.spriteName = "arathiIcon"..role.info.camp;
    else
        self._imgCamp.gameObject:SetActive(false)
    end
    self:UpdateOtherInfo();
end

-- 外部調用
function RoleNamePanel:RefreshRealm()
    if (self._role and self._role.info) then
        local realm = self._role.info.realm;
        if (realm) then
            local name, quality = RealmManager.GetNameAndQualityByLevel(realm.rlv);
            if (name) then
                local effColor = ColorDataManager.GetRealmTitleEffectColor(quality);
                self._txtRealm.text = name;
                self._txtRealm.applyGradient = true;
                self._txtRealm.effectColor = effColor.ec;
                self._txtRealm.gradientTop = effColor.tc;
                self._txtRealm.gradientBottom = effColor.bc;
            else
                self._txtRealm.text = "";
            end
            --self:_RefreshNamePos()
            self:UpdateOtherInfo()
        end
    end
end

function RoleNamePanel:_RefreshNamePos()
    local nWidth = self._txtName.width;
    --local rWidth = self._txtRealm.width;
    --if (self._txtRealm.text ~= "") then
        --Util.SetLocalPos(self._txtName, Vector3.right *(rWidth / 2))
        --Util.SetLocalPos(self._txtRealm, Vector3.left *(nWidth / 2))
        --Util.SetLocalPos(self._imgPartIcon, Vector3.left *((nWidth + rWidth) / 2 + 12))
    --else
        Util.SetLocalPos(self._txtName, 0, 0, 0)
        Util.SetLocalPos(self._imgPartIcon, Vector3.left *(nWidth / 2 + 12))
    --end
end

function RoleNamePanel:_Dispose()
    if self._dispose then return end
    if self._role then
        self._role.namePanel = nil
        self._role = nil
    end
    self.tempTop = nil
    
    if (self._titleItem) then
        self._titleItem:Dispose()
        self._titleItem = nil
    end
    self._txtName = nil;
    self._txtRealm = nil;
    self._imgPartIcon = nil;

    self._txtmountName = nil;
    self._txtGuild = nil;
    self._trsTitleItem = nil;

    self:HideAffiliation();
    self._imgAffiliation = nil;
    self._imgCamp = nil;

    Resourcer.Recycle(self._gameObject, true);
end
