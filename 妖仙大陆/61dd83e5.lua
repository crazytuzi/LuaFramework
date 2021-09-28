local _M = {}
_M.__index = _M

local Util                          = require "Zeus.Logic.Util"
local _5V5API = require "Zeus.Model.5v5"

local self = {}

local function onEnvironmentChange(eventname,params)
    
    local key = params.key
    
    if key == "TimeCounter" then
        self.lb_time.Text = tostring(params.value)
    elseif key == "TeamAScore"  then
        if DataMgr.Instance.UserData.Force == 2 then
            self.lb_people.Text = params.value
        else
            self.lb_fightpoint.Text = params.value
        end
    elseif key == "TeamBScore" then
        if DataMgr.Instance.UserData.Force == 3 then
            self.lb_people.Text = params.value
        else
            self.lb_fightpoint.Text = params.value
        end

    elseif key == "FirstBloodPlayerUid" then
        local name = _5V5API.getMemberIndexInfo(params.value).playerName
        local data = GameSceneMgr.Instance.BattleRun.BattleClient:GetPlayerUnitByUUID(params.value); 
        if data ~= nil and name ~= nil then
            Util.SetLabelShortText(self.lb_firstblood,name )
            if data.Force == DataMgr.Instance.UserData.Force then
                self.lb_firstblood.FontColorRGBA = 0x00a0ffff
            else
                self.lb_firstblood.FontColorRGBA = 0xed2a0aff
            end
        end
       
    end

    
    
    
    
    


end



 local function RefreshOneMember(cvs, id,name,level,pro)
        cvs.UserData = id;
        cvs.Visible = true;
        local gg_blood = cvs:FindChildByEditName("gg_blood",true) 
        local lb_member_name = cvs:FindChildByEditName("lb_member_name",true)
        local img_member_follow = cvs:FindChildByEditName("img_member_follow",true)
        local lb_lvnum = cvs:FindChildByEditName("lb_lvnum",true)
        local img_member_prof = cvs:FindChildByEditName("img_member_prof",true)
        local btn_jiaohu = cvs:FindChildByEditName('btn_jiaohu',true)
        local ib_captain = cvs:FindChildByEditName("ib_captain",true)

        lb_member_name.Text = level .. "  " .. name;

        gg_blood:SetGaugeMinMax(0, 1);
        gg_blood.Value = 1;

        img_member_follow.Visible = false

        lb_lvnum.Text = level

        Util.SetIconImagByPro(img_member_prof,pro)

        btn_jiaohu.Visible = true
        btn_jiaohu.TouchClick = function(sender)
            EventManager.Fire("Hud.Team.Event.ShowInteractive", {id = id,name =name,pro = pro,level = level,type = "cfg_team"})
            
        end

        ib_captain.Visible = false
end



local function OnEnter()
    
    
    self.cvs_noteam.Visible = false
    self.cvs_inteam.Visible = true
    self.lb_people.Text = "0"
    self.lb_fightpoint.Text = "0"
    self.lb_time.Text = self.defaultTime

    self.memberinfo = _5V5API.getMemberInfo()
    local count = 1
    for i,v in ipairs(self.memberinfo) do
        if v.playerId ~= DataMgr.Instance.UserData.RoleID then
            RefreshOneMember(self["cvs_hero" .. (count-1)],v.playerId,v.playerName,v.playerLvl,v.playerPro)
            count = count +1
        end
    end
    self.lb_team_num.Text = tostring(count)
    self.lb_team_num.FontColorRGBA = 0x000000FF
    self.lb_team_num.Visible = true
    AddUpdateEvent("5v5TeamHudUpdate", function (dt)
        if GameSceneMgr.Instance.BattleRun == nil or GameSceneMgr.Instance.BattleRun.BattleClient == nil then
            return
        end
        for i=1,4 do
            local cvs = self["cvs_hero" .. (i - 1)]
            if cvs.Visible and cvs.UserData~=nil and cvs.UserData~="" then
                local uuid = cvs.UserData
                local data = GameSceneMgr.Instance.BattleRun.BattleClient:GetPlayerUnitByUUID(uuid);
                local ib_offline = cvs:FindChildByEditName("ib_offline",true)
                if data~=nil then
                    ib_offline.Visible = false
                    local gg_blood = cvs:FindChildByEditName("gg_blood",true) 
                    if gg_blood.Value ~= data.HP then
                        gg_blood:SetGaugeMinMax(0, data.MaxHP)
                        gg_blood.Value = data.HP
                    end
                else
                    ib_offline.Visible = true
                end
            end
        end
        
    end)
end

local function OnExit()
    
   self.memberinfo = nil
   RemoveUpdateEvent("5v5TeamHudUpdate", true)
   EventManager.Unsubscribe("Event.EnvironmentVarChange", onEnvironmentChange)
end

local function OnClickHide( ... )
    
    if self.tbn_back.IsChecked then
        self.cvs_detail.Visible = false
    else
        self.cvs_detail.Visible = true
    end
end

local function InitUI()
    
    local UIName1 = {
        "cvs_detail",
        "cvs_title",
        "tbn_team",
        "tbn_task",
        "tbn_back",
        "cvs_task",
        "cvs_team",
        "cvs_hero0",
        "cvs_hero1",
        "cvs_hero2",
        "cvs_hero3",
        "cvs_noteam",
        "cvs_inteam",
        "cvs_matching1",
        "bt_follow",
        "bt_leaveteam",
        "lb_team_num",
    }
    for i = 1, #UIName1 do
        self[UIName1[i]] = self.teamNode:FindChildByEditName(UIName1[i], true)
    end

    local UIName2 = {
        "lb_time",
        "lb_people",
        "lb_fightpoint",
        "lb_firstblood",
    }
    for i = 1, #UIName2 do
        self[UIName2[i]] = self.scorceNode:FindChildByEditName(UIName2[i], true)
    end

    EventManager.Subscribe("Event.EnvironmentVarChange", onEnvironmentChange)
end

local function InitCompnent()
    InitUI()

    for i = 1, 4 do
        self["cvs_hero" .. (i - 1)].Visible = false
    end

    self.cvs_task.Visible = false
    self.cvs_team.Visible = true

    HudManagerU.Instance:InitAnchorWithNode(self.cvs_detail, bit.bor(HudManagerU.HUD_LEFT, HudManagerU.HUD_TOP))
    HudManagerU.Instance:InitAnchorWithNode(self.cvs_title, bit.bor(HudManagerU.HUD_LEFT, HudManagerU.HUD_TOP))

    self.defaultTime = self.lb_time.Text
    self.tbn_team.IsChecked = true
    self.tbn_team.Enable = false
    self.tbn_task.IsChecked = false
    self.tbn_task.Enable = false
    self.tbn_back.IsChecked = true
    self.tbn_back.TouchClick = OnClickHide
    self.cvs_matching1.Visible = false
    self.bt_follow.Visible = false
    self.bt_leaveteam.Visible = false
    OnEnter()
end

local function Init(params)
    if not self.InitFinish then
        self.teamNode = HudManagerU.Instance.CreateHudUIFromFile("xmds_ui/5v5/5v5_team.gui.xml")
        self.teamNode.Enable = false
        HudManagerU.Instance:AddChild(self.teamNode)
    
        self.scorceNode = HudManagerU.Instance.CreateHudUIFromFile("xmds_ui/5v5/5v5_topright.gui.xml")
        self.scorceNode.Enable = false
        HudManagerU.Instance:AddChild(self.scorceNode)
    
        InitCompnent()
    end

    self.InitFinish = true
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

local function Close()
    
    if self ~= nil then
        OnExit()
        if self.teamNode ~= nil then
            self.teamNode:RemoveFromParent(true)
        end
        if self.scorceNode ~= nil then
            self.scorceNode:RemoveFromParent(true)
        end
        self = nil
    end
end

return {Create = Create, Close = Close}
