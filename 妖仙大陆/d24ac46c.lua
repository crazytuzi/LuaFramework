


local Util   = require 'Zeus.Logic.Util'
local VSAPI = require "Zeus.Model.VS"
local _M = {}
_M.__index = _M

local function InitUI(self)
    local UIName = {
        "btn_close",
        "ib_player_icon",
        "lb_player_name",
        "ib_rank_num",
        "lb_player_power",
        "lb_attk_num",
        "lb_hit_num",
        "lb_crit_num",
        "lb_dod_num",
        "lb_critres_num",
        "lb_phydef_num",
        "lb_magdef_num",
        "lb_critharm_num",
        "lb_critharmres_num",
        "ib_attk",
        "ib_hit",
        "ib_crit",
        "ib_dod",
        "ib_critres",
        "ib_phydef",
        "ib_magdef",
        "ib_critharm",
        "ib_critharmres",
        "lb_attk",
        "lb_magattk",

        "ib_player_icon1",
        "lb_player_name1",
        "ib_rank_num1",
        "lb_player_power1",
        "lb_attk_num1",
        "lb_hit_num1",
        "lb_crit_num1",
        "lb_dod_num1",
        "lb_critres_num1",
        "lb_phydef_num1",
        "lb_magdef_num1",
        "lb_critharm_num1",
        "lb_critharmres_num1",
        "ib_attk1",
        "ib_hit1",
        "ib_crit1",
        "ib_dod1",
        "ib_critres1",
        "ib_phydef1",
        "ib_magdef1",
        "ib_critharm1",
        "ib_critharmres1",
        "lb_attk1",
        "lb_magattk1",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end

function _M:Close()
    self:OnExit()
end

function _M:OnEnter()
    self.menu.Visible = false
    if self.menu.ExtParam ~=nil and self.menu.ExtParam ~= "" then
        VSAPI.requestPlayerInfo(self.menu.ExtParam, function(data)
            if self.menu and self.menu.IsRunning then
                self.menu.Visible = true
                self:setData(data)
            end
        end,
        function()
            self.menu.Visible = true
        end)
    else
        self.menu.Visible = true
    end
end

function _M:OnExit()

end

function _M:OnDispose()

end

local function setValueCompare(self,str,num1,num2,addstr)
    num1 = num1 == nil and 0 or num1
    num2 = num2 == nil and 0 or num2
    if addstr == "%" then
        num1 = num1 / 100
        num2 = num2 / 100
    end
    self["lb_" .. str .. "_num"].Text = tostring(num1) .. addstr
    self["lb_" .. str .. "_num1"].Text = tostring(num2) .. addstr

    if num1 == num2 then
        self["ib_" .. str].Visible = false
        self["ib_" .. str .. "1"].Visible = false
    elseif tonumber(num1) > tonumber(num2) then
        Util.HZSetImage2(self["ib_" .. str], "#static_n/func/common2.xml|common2|73")
        Util.HZSetImage2(self["ib_" .. str .. "1"], "#static_n/func/common2.xml|common2|72")
    else
        Util.HZSetImage2(self["ib_" .. str], "#static_n/func/common2.xml|common2|72")
        Util.HZSetImage2(self["ib_" .. str .. "1"], "#static_n/func/common2.xml|common2|73")
    end
end

function _M:setData(data)
    local userdata = DataMgr.Instance.UserData
    self.mapName = {}
    for _,v in ipairs(data.attrs or {}) do
        local attrName = GlobalHooks.DB.Find("Attribute", v.id).attKey
        
        self.mapName[attrName] = v.value
    end

    self.lb_player_name.Text = userdata.Name
    self.lb_player_name1.Text = data.name

    Util.SetHeadImgByPro(self.ib_player_icon,userdata.Pro)
    Util.SetHeadImgByPro(self.ib_player_icon1,data.pro)
    
    

    self.lb_player_power.Text = userdata:GetAttribute(UserData.NotiFyStatus.FIGHTPOWER)
    self.lb_player_power1.Text = data.fightPower

    self.ib_rank_num.Text = userdata:GetAttribute(UserData.NotiFyStatus.LEVEL)
    self.ib_rank_num1.Text = data.level

    local mynum = 0
    local num = userdata:TryToGetLongAttribute(UserData.NotiFyStatus.PHY,0)
    num = num~=nil and num or 0
    local phyNum = num
    num = userdata:TryToGetLongAttribute(UserData.NotiFyStatus.MAG,0)
    num = num~=nil and num or 0
    local magNum = num

    if magNum > phyNum then
        self.lb_attk.Visible = false
        self.lb_magattk.Visible = true
        mynum = magNum
    else
        self.lb_attk.Visible = true
        self.lb_magattk.Visible = false
        mynum = phyNum
    end

    local vsnum = 0
    num = self.mapName["Phy"]
    num = num~=nil and num or 0
    phyNum = num
    num = self.mapName["Mag"]
    num = num~=nil and num or 0
    magNum = num

    if magNum > phyNum then
        self.lb_attk1.Visible = false
        self.lb_magattk1.Visible = true
        vsnum = magNum
    else
        self.lb_attk1.Visible = true
        self.lb_magattk1.Visible = false
        vsnum = phyNum
    end

    setValueCompare(self,"attk",mynum,vsnum,"")
    setValueCompare(self,"hit",userdata:GetAttribute(UserData.NotiFyStatus.HIT),self.mapName["Hit"],"")
    setValueCompare(self,"crit",userdata:GetAttribute(UserData.NotiFyStatus.CRIT),self.mapName["Crit"],"")
    setValueCompare(self,"dod",userdata:GetAttribute(UserData.NotiFyStatus.DODGE),self.mapName["Dodge"],"")
    setValueCompare(self,"critres",userdata:GetAttribute(UserData.NotiFyStatus.RESCRIT),self.mapName["ResCrit"],"")
    setValueCompare(self,"phydef",userdata:GetAttribute(UserData.NotiFyStatus.AC),self.mapName["Ac"],"")
    setValueCompare(self,"magdef",userdata:GetAttribute(UserData.NotiFyStatus.RESIST),self.mapName["Resist"],"")
    setValueCompare(self,"critharm",userdata:GetAttribute(UserData.NotiFyStatus.CRITDAMAGE),self.mapName["CritDamage"],"%")
    setValueCompare(self,"critharmres",userdata:GetAttribute(UserData.NotiFyStatus.CRITDAMAGERES),self.mapName["CritDamageRes"],"%")







    
    

    
    

    
    
    
    
    

    
    
   
    
    

    
    
    
    
    

    
    

    
    

end

local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create('xmds_ui/common/power_compare.gui.xml',tag)
    self.menu.ShowType = UIShowType.Cover
    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.EnableChildren = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.event_PointerClick = function(sender)
        self.menu:Close()
   end
    InitUI(self)

     
    self.menu:SubscribOnExit(function ()
        self:OnExit()
    end)
    self.menu:SubscribOnEnter(function ()
        self:OnEnter()
    end)
    self.menu:SubscribOnDestory(function ()
        
    end)
end

function _M.Create(tag)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag)
    return ret
end

return _M

