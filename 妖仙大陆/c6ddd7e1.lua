local _M = {}
_M.__index = _M

local Util              = require "Zeus.Logic.Util"
local Relive            = require "Zeus.Model.Relive"
local FubenApi          = require "Zeus.Model.Fuben"
local CDLabelExt        = require "Zeus.Logic.CDLabelExt"
local ServerTime        = require "Zeus.Logic.ServerTime"


local self = {
    menu = nil,
}

local ReliveType = {
    FieldLeave = 0, 
    Relive = 1,     
    Leave = 2,      
}

local ReliveSeconds = 30

local function ReqLeave()
    DataMgr.Instance.UserData.ReLiveType = 0
    FubenApi.requestLeaveFuben()
    MenuMgrU.Instance:CloseMenuByTag(GlobalHooks.UITAG.GameUIDeadCommon)
end

local function ReqOriginReLive(payConfirm)
    DataMgr.Instance.UserData.ReLiveType = 2
    Relive.RequestRelive(1,payConfirm,function()
    end)
end

local function ReqSafeReLive()
    DataMgr.Instance.UserData.ReLiveType = 1
    Relive.RequestRelive(0,0,function()
        if Relive.AutoOpenFeatureId and Relive.ReliveData.reliveType == ReliveType.FieldLeave then
            self.menu:Close()
            if Relive.AutoOpenFeatureId.param == nil then
                GlobalHooks.OpenUI(Relive.AutoOpenFeatureId.id, 0)
            else
                GlobalHooks.OpenUI(Relive.AutoOpenFeatureId.id, 0, Relive.AutoOpenFeatureId.param)
            end
            Relive.AutoOpenFeatureId = nil
        end
    end)
end

local function OnExit()
    if self.CDLabelExt then
        self.CDLabelExt:stop()
        self.CDLabelExt = nil
    end

    if self.CDLabelExt1 then
        self.CDLabelExt1:stop()
        self.CDLabelExt1 = nil
    end
end

local function GetCutDownText(cd)
    if Relive.ReliveData.cbType == 0 then
        return Util.GetText(TextConfig.Type.FUBEN, "autoClose", cd)
    elseif Relive.ReliveData.cbType == 1 then
        return Util.GetText(TextConfig.Type.FUBEN, "autoRelive", cd)
    else
        return Util.GetText(TextConfig.Type.FUBEN, "autoLeave", cd)
    end
end

local function ResetBtnPos()
    local showCount = 0
    local index = 1
    for i=1,3 do
        if self.btnList[i].Visible == true then
            showCount = showCount+1
        end
    end
    for i=1,3 do
        if self.btnList[i].Visible == true then
            self.btnList[i].X = self.btnPosX[showCount][index]
            index = index+1
        end
    end
end

local function OnEnter()
    self.cvs_reborn.Visible = (Relive.ReliveData.reliveType == ReliveType.FieldLeave or Relive.ReliveData.reliveType == ReliveType.Relive)
                                and Relive.ReliveData.btnShow > 0 and Relive.ReliveData.btnSafe == 1

    self.cvs_prop.Visible = (Relive.ReliveData.reliveType == ReliveType.FieldLeave or Relive.ReliveData.reliveType == ReliveType.Relive)
                                and Relive.ReliveData.btnShow > 0 and Relive.ReliveData.btnCurr == 1

    self.cvs_exit.Visible = (Relive.ReliveData.reliveType == ReliveType.Relive or Relive.ReliveData.reliveType == ReliveType.Leave)
                                and Relive.ReliveData.btnShow > 0 and Relive.ReliveData.btnCity == 1
    

    self.btn_reborn.Enable = Relive.ReliveData.btnShow == 1
    self.btn_reborn1.Enable = Relive.ReliveData.btnShow == 1
    self.bt_exit.Enable = Relive.ReliveData.btnShow == 1

    self.btn_reborn.TouchClick = ReqSafeReLive
    self.btn_reborn1.TouchClick = function ()
        if Relive.ReliveData.payConfirm == 1 then
            local tipsMenu = MenuMgrU.Instance:CreateUIByTag(GlobalHooks.UITAG.GameUIDeadCommonTips, 0)
            MenuMgrU.Instance:AddMsgBox(tipsMenu)
        else
            ReqOriginReLive(0)
        end
    end

    self.bt_exit.TouchClick = ReqLeave

    self.lb_kfh.Visible = Relive.ReliveData.totalCount > 0 and Relive.ReliveData.reliveType ~= ReliveType.FieldLeave
    self.lb_kfhnum.Visible = Relive.ReliveData.totalCount > 0 and Relive.ReliveData.reliveType ~= ReliveType.FieldLeave
    self.lb_kfhnum.Text = Relive.ReliveData.currCount .. "/" .. Relive.ReliveData.totalCount

    self.lb_free_count.Text = Relive.ReliveData.costStr

    self.countDown = ReliveSeconds
    if Relive.ReliveData.countDown and Relive.ReliveData.countDown > 0 then
        self.countDown = Relive.ReliveData.countDown
    end
    self.lb_autoreborn.Text = GetCutDownText(self.countDown)
    self.CDLabelExt = CDLabelExt.New(self.lb_autoreborn,self.countDown,function(cd,label)
        if cd <= 0 then
            self.CDLabelExt:stop()
            if Relive.ReliveData.cbType == 0 then
                EventManager.Fire("Event.relive.ShowReliveBtn", {})
                self.menu:Close()
            elseif Relive.ReliveData.cbType == 1 then
                ReqSafeReLive()
            elseif Relive.ReliveData.cbType == 2 then
                ReqLeave()
            end
            
        else
            return GetCutDownText(math.floor(cd))
        end
    end)
    if Relive.ReliveData.cooltime > 0 and self.cvs_reborn.Visible == true then
        self.CDLabelExt1 = CDLabelExt.New(self.reborn_text,Relive.ReliveData.cooltime,function(cd,label)
            if cd <= 0 then
                self.reborn_text.Text = ""
                self.btn_reborn.Text = Util.GetText(TextConfig.Type.PET, "relive")
                self.btn_reborn.IsGray = false
                self.btn_reborn.Enable = Relive.ReliveData.btnShow == 1
                self.CDLabelExt1:stop()
            else
                self.btn_reborn.Text = ""
                self.btn_reborn.IsGray = true
                self.btn_reborn.Enable = false
                Relive.ReliveData.cooltime = cd
                return Util.GetText(TextConfig.Type.PET, "secondrelive",tostring(math.floor(cd)))
            end
        end)
        self.CDLabelExt1:start()
    else
        self.reborn_text.Text = ""
        self.btn_reborn.Text = Util.GetText(TextConfig.Type.PET, "relive")
        self.btn_reborn.IsGray = false
        self.btn_reborn.Enable = Relive.ReliveData.btnShow == 1
    end

    self.btn_close.Visible = Relive.ReliveData.cbType == 0
    self.btn_close.TouchClick = function ()
        EventManager.Fire("Event.relive.ShowReliveBtn", {})
        self.menu:Close()
    end

    ResetBtnPos()

    self.CDLabelExt:start()
end

local function InitGotoFunctions()
    
    local equipstrong = Util.GetText(TextConfig.Type.PET, "equipstrong")
    local skillstrong = Util.GetText(TextConfig.Type.PET, "skillstrong")
    local zuojistrong = Util.GetText(TextConfig.Type.PET, "zuojistrong")
    local baoshixiangqian = Util.GetText(TextConfig.Type.PET, "baoshixiangqian")
    local featureGotoId = {{id = 101, iconPath = "static_n/functions/Reworking.png",name = equipstrong, param = "strength"},
                           {id = 200, iconPath = "static_n/functions/Solo.png",name = skillstrong},
                           {id = 2001, iconPath = "static_n/functions/fishman.png",name = zuojistrong},
                           {id = 101, iconPath = "static_n/functions/Character.png",name = baoshixiangqian, param = "inlay"}}
    for i=1,4 do
        local featureCan
        if i == 1 then
            featureCan = self.cvs_promote
        else
            featureCan = self.cvs_promote:Clone()
            featureCan.Position2D = Vector2.New(self.cvs_promote.Position2D.x + 130*(i-1), self.cvs_promote.Position2D.y)
            self.cvs_desc:AddChild(featureCan)
        end

        local ib_func = featureCan:FindChildByEditName("ib_func", true)
        Util.HZSetImage(ib_func, featureGotoId[i].iconPath, false,LayoutStyle.IMAGE_STYLE_BACK_4)

        local lb_proname = featureCan:FindChildByEditName("lb_proname", true)
        lb_proname.Text = featureGotoId[i].name

        local btn_pro = featureCan:FindChildByEditName("btn_pro", true)
        btn_pro.Enable = Relive.ReliveData.btnEnable == 1
        btn_pro.TouchClick = function ()
            Relive.AutoOpenFeatureId = featureGotoId[i]
            if Relive.ReliveData.reliveType == ReliveType.FieldLeave then
                ReqSafeReLive()
            elseif Relive.ReliveData.reliveType == ReliveType.Leave then
                ReqLeave()
            end
        end
    end
end

local function InitCompnent()
    local UIName = {
        "btn_close",
        "ib_title",
        "lb_wenben",

        "cvs_desc",
        "cvs_promote",

        "cvs_reborn",
        "cvs_exit",
        "cvs_prop",
        "btn_reborn",
        "reborn_text",
        "btn_reborn1",
        "bt_exit",

        "lb_kfh",
        "lb_kfhnum",
        "lb_autoreborn",
        "lb_free_count",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.btnList = {self.cvs_reborn, self.cvs_exit, self.cvs_prop}

    self.btnPosX = {{self.cvs_exit.X},
                    {self.cvs_reborn.X, self.cvs_prop.X},
                    {self.cvs_reborn.X, self.cvs_exit.X, self.cvs_prop.X}}
    
    InitGotoFunctions()
end

local function Init(params)
	self.menu = LuaMenuU.Create("xmds_ui/common/common_dead.gui.xml", GlobalHooks.UITAG.GameUIDeadCommon)
    self.menu.ShowType = UIShowType.HideBackHud
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)

    InitCompnent()
    return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return node
end

local function OnActorRebirth(...)
    if self and self.menu then
        self.menu:Close()
    end
end

local function initial()
    EventManager.Subscribe("Event.ActorRebirth",OnActorRebirth)
end

return {Create = Create, initial = initial}
