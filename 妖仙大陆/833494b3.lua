


local Util   = require 'Zeus.Logic.Util'
local _M = {}
_M.__index = _M

local ui_names = {
    {
        name = "btn_close",
        click = function(self)
            self:Close();
        end
    },
    {name = "sp_frame1"},

    { name = "lb_attk1"},
    { name = "lb_attk2"},
    { name = "lb_attk_num"},
    { name = "lb_crit_num"},
    { name = "lb_hit_num"},
    { name = "lb_critharm_num"},
    { name = "lb_phydefign_num"},
    { name = "lb_skillharm_num"},
    { name = "lb_magdefign_num"},
    { name = "lb_skillcdres_num"},
    { name = "lb_hp_num"},
    { name = "lb_critres_num"},
    { name = "lb_dod_num"},
    { name = "lb_critharmres_num"},
    { name = "lb_phydef_num"},
    { name = "lb_controlres_num"},
    { name = "lb_magdef_num"},
    { name = "lb_damres_num"},
    { name = "lb_hprec_num"},
    
    { name = "lb_phydef_ignore"},
    { name = "lb_magdef_ignore"},
    { name = "lb_def_ignore_per"},
    { name = "lb_resist_ignore_per"},
    { name = "lb_ignore_pernum"},
    
    
    { name = "lb_extrahit_num"},
    { name = "lb_extracrith_num"},
    { name = "lb_extradod_num"},
    { name = "lb_extracritres_num"},
    { name = "lb_injuryref_num"},
    { name = "lb_magreduce_num"},
    { name = "lb_hpregen_num"},
    { name = "lb_resstun_num"},
    { name = "lb_resdurance_num"},
    { name = "lb_restaunt_num"},
    { name = "lb_resslowdown_num"},
    { name = "lb_allresctrl_num"},
    { name = "lb_skillhardadd_num"},
    { name = "lb_cure_num"},
    { name = "lb_becure_num"},
    
}

function _M:Close()
    self:OnExit()
end

local function SetAttrText(status, node, v, isFormat)
    local txt
    local userdata = DataMgr.Instance.UserData
    if userdata:ContainsKey(status, v) then
        local num = userdata:GetAttribute(v)
        num = num~=nil and num or 0
        if isFormat then
            txt = tostring(num/100) .. '%'
        else
            txt = tostring(num)
        end
    end
    if txt then
        node.Text = txt
    end
end

local function initProperties(status, userdata, self)
    local num = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.PHY,0)
    num = num~=nil and num or 0
    local phyNum = num
    num = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.MAG,0)
    num = num~=nil and num or 0
    local magNum = num 

    if magNum > phyNum then
        self.lb_attk1.Visible = false
        self.lb_attk2.Visible = true
        SetAttrText(status, self.lb_attk_num, UserData.NotiFyStatus.MAG)

        
        self.lb_phydefign_num.Visible = false
        self.lb_magdefign_num.Visible = true
        self.lb_phydef_ignore.Visible = false
        self.lb_magdef_ignore.Visible = true
        self.lb_def_ignore_per.Visible = false
        self.lb_resist_ignore_per.Visible = true
        SetAttrText(status, self.lb_ignore_pernum, UserData.NotiFyStatus.IGNORERESISTPER,true)
        
    else
        self.lb_attk1.Visible = true
        self.lb_attk2.Visible = false
        SetAttrText(status, self.lb_attk_num, UserData.NotiFyStatus.PHY)

         
        self.lb_phydefign_num.Visible = true
        self.lb_magdefign_num.Visible = false
        self.lb_phydef_ignore.Visible = true
        self.lb_magdef_ignore.Visible = false
        self.lb_def_ignore_per.Visible = true
        self.lb_resist_ignore_per.Visible = false
        SetAttrText(status, self.lb_ignore_pernum, UserData.NotiFyStatus.IGNOREACPER,true)
        
    end

    SetAttrText(status, self.lb_crit_num, UserData.NotiFyStatus.CRIT)
    SetAttrText(status, self.lb_hit_num, UserData.NotiFyStatus.HIT)
    SetAttrText(status, self.lb_critharm_num, UserData.NotiFyStatus.CRITDAMAGE,true)
    SetAttrText(status, self.lb_skillhardadd_num, UserData.NotiFyStatus.INCALLDAMAGE,true)
    SetAttrText(status, self.lb_phydefign_num, UserData.NotiFyStatus.IGNOREAC)
    SetAttrText(status, self.lb_skillharm_num, 0,true)
    SetAttrText(status, self.lb_magdefign_num, UserData.NotiFyStatus.IGNORERESIST)
    SetAttrText(status, self.lb_skillcdres_num, UserData.NotiFyStatus.SKILLCD,true)

    if userdata:ContainsKey(status, UserData.NotiFyStatus.HP) or
        userdata:ContainsKey(status, UserData.NotiFyStatus.MAXHP) then
        local hp = userdata:GetAttribute(UserData.NotiFyStatus.HP)
        self.lb_hp_num.Text = tostring(hp)
    end
    SetAttrText(status, self.lb_critres_num, UserData.NotiFyStatus.RESCRIT)
    SetAttrText(status, self.lb_dod_num, UserData.NotiFyStatus.DODGE)
    SetAttrText(status, self.lb_critharmres_num, UserData.NotiFyStatus.CRITDAMAGERES,true)
    SetAttrText(status, self.lb_phydef_num, UserData.NotiFyStatus.AC)
    SetAttrText(status, self.lb_magdef_num, UserData.NotiFyStatus.RESIST)
    SetAttrText(status, self.lb_controlres_num, UserData.NotiFyStatus.CTRLTIMEREDUCE,true)
    SetAttrText(status, self.lb_damres_num, UserData.NotiFyStatus.ALLDAMAGEREDUCE,true)
    SetAttrText(status, self.lb_hprec_num, UserData.NotiFyStatus.HITLEECHHP)

    SetAttrText(status, self.lb_cure_num, UserData.NotiFyStatus.HEALEFFECT,true)
    SetAttrText(status, self.lb_becure_num, UserData.NotiFyStatus.HEALEDEFFECT,true)

    SetAttrText(status, self.lb_extrahit_num, UserData.NotiFyStatus.HITRATE,true) 
    SetAttrText(status, self.lb_extracrith_num, UserData.NotiFyStatus.CRITRATE,true)
    SetAttrText(status, self.lb_extradod_num, UserData.NotiFyStatus.DODGERATE,true)
    SetAttrText(status, self.lb_extracritres_num, UserData.NotiFyStatus.RESCRITRATE,true)
    SetAttrText(status, self.lb_injuryref_num, UserData.NotiFyStatus.PHYDAMAGEREDUCE,true)
    SetAttrText(status, self.lb_magreduce_num, UserData.NotiFyStatus.MAGICDAMAGEREDUCE,true)
    SetAttrText(status, self.lb_hpregen_num, UserData.NotiFyStatus.HPREGEN)
    SetAttrText(status, self.lb_resstun_num, UserData.NotiFyStatus.RESSTUN,true)
    SetAttrText(status, self.lb_resdurance_num, UserData.NotiFyStatus.RESDURANCE,true)
    SetAttrText(status, self.lb_restaunt_num, UserData.NotiFyStatus.RESTAUNT,true)
    SetAttrText(status, self.lb_resslowdown_num, UserData.NotiFyStatus.RESSLOWDOWN,true)
    SetAttrText(status, self.lb_allresctrl_num, UserData.NotiFyStatus.ALLRESCTRL,true)
end

function _M:OnEnter()
    print("UIPropertyDetail OnEnter")
    self.menu.Visible = true
    initProperties(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData, self)
end

function _M:OnExit()
    self.menu.Visible = false
end

function _M:OnDispose()

end


local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create('xmds_ui/character/property_morepro.gui.xml',tag)
    self.menu.ShowType = UIShowType.Cover
    self.menu.Enable = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    self.menu.mRoot.IsInteractive = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = function (sender)
        self.menu:Close()
    end})

    self.menu.Visible = false
    Util.CreateHZUICompsTable(self.menu, ui_names, self)

     self.menu.Enable = false
    self.menu:SubscribOnExit(function ()
        self:OnExit()
    end)
    self.menu:SubscribOnEnter(function ()
        self:OnEnter()
    end)
    self.menu:SubscribOnDestory(function ()
           self = nil
    end)
end

function _M.Create(tag)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag)
    return ret
end

return _M

