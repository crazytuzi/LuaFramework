local _M = {}
local Util = require"Zeus.Logic.Util"
local Player = require "Zeus.Model.Player"


_M.__index = _M

local ui_names = {
    {
        name = "btn_close",
        click = function(self)
            self:Close();
        end
    },
    {name = "cvs_pro_before"},
    {name = "cvs_pro_after"},
    {name = "cvs_pro_max"},
    {name = "cvs_repair_all",click = function(self)
        self.cvs_repair_all.Visible = false
    end},
    {name = "cvs_break_can"},
    {name = "cvs_break_not"}, 
    {name = "lb_maxtips"},
    {name = "btn_look",click = function (self)
        
         GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRealmLook, 0)
    end},
    {name = "btn_repair_break",click = function(self)
        Player.UpgradeClassRequest(function()
        
        local num = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.REALM)
        num = num == nil and 0 or num

        local realmNext = GlobalHooks.DB.Find("UpLevelExp", { UpOrder = num + 1 })[1]
        local roleLevel= DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)

        local cultivation = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.CULTIVATION)
        cultivation = cultivation == nil and 0 or cultivation

         if roleLevel >= realmNext.ReqLevel then
              if self.flag ~= nil then
                       if self.flag > 0 then
                            if cultivation < realmNext.ReqClassExp then
                                DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.UpLevelUp)
                            end
                        else
                                DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.UpLevelUp)
                        end
              end
         else
              DataMgr.Instance.MessageData:RemoveList(MessageData.MsgType.UpLevelUp)
        end
        
        EventManager.Fire("Event.UI.PageUIProperty.CheckCanCultivation", {})
        
        local phylumStr = ""
        if self.realmNow == nil then
            phylumStr =Util.GetText(TextConfig.Type.ATTRIBUTE,110)
         else
            phylumStr = self.realmNow.ClassName .. self.realmNow.UPName
        end
        local classfieldStr = self.realmNext.ClassName .. self.realmNext.UPName
        local lineBreak = Util.GetText(TextConfig.Type.ATTRIBUTE,142)
        Util.SendBIData("RealmUpgrade","",lineBreak,phylumStr,classfieldStr,"","")
        end)
    end},
    {name = "btn_gt_go1",click = function(self)  
        
        local quest = DataMgr.Instance.QuestManager:GetTrunkQuest()
        if quest then
            quest:Seek()
            self.cvs_repair_all.Visible = false
            GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIRoleAttribute)
            self:Close()
        else
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ATTRIBUTE,111))
        end
    end},
    {name = "btn_gt_go2",click = function(self)
        self.cvs_repair_all.Visible = false
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIHuanJing, 0) 
    end},
    {name = "btn_gt_go3",click = function(self)
        self.cvs_repair_all.Visible = false
        EventManager.Fire('Event.Goto', {id = "oneDragon"})
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIRoleAttribute)
        self:Close()
    end},
    {name = "btn_gt_go4",click = function(self)
        self.cvs_repair_all.Visible = false
        EventManager.Fire('Event.Goto', {id = "teacher"})
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIRoleAttribute)
        self:Close()
    end

    },

    {name = "cvs_condition1"},
    {name = "cvs_condition2"},
    {name = "cvs_condition3"},
    {name = "cvs_condition4"},
}

function _M:Close()
    self.menu:Close()
end



function _M:UpLevelRequest()
    
    
    
    











end

local function setAddAttributeData(self,node,data,default)
    local lb_level_name = node:FindChildByEditName('lb_level_name',false)
    local lb_level_num = node:FindChildByEditName('lb_level_num',false)
    local lb_pro = node:FindChildByEditName('lb_pro',false)
    local lb_pro_num = node:FindChildByEditName('lb_pro_num',false)
    local lb_pro1 = node:FindChildByEditName('lb_pro1',false)
    local lb_pro_num1 = node:FindChildByEditName('lb_pro_num1',false)
    local lb_pro2 = node:FindChildByEditName('lb_pro2',false)
    local lb_pro_num2 = node:FindChildByEditName('lb_pro_num2',false)
    local lb_max_num = node:FindChildByEditName('lb_max_num',false)
    local lb_level_max = node:FindChildByEditName('lb_level_max',false)

    lb_level_name.Text = data.ClassName
    lb_level_num.Text = data.UPName
    lb_pro.Text = data.Prop1
    lb_pro_num.Text = "+" ..data.Max1
    lb_pro1.Text = data.Prop2
    lb_pro_num1.Text = "+" ..data.Max2
    lb_pro2.Text = data.Prop3
    lb_pro_num2.Text = "+" ..data.Max3
    local  nextdata
    if default then
        nextdata = GlobalHooks.DB.Find("UpLevelExp", {ClassID = data.ClassID,ClassUPLevel =  1})[1]
        lb_level_name.Text = Util.GetText(TextConfig.Type.ATTRIBUTE,110)
        lb_level_num.Text = ''
        lb_pro_num.Text = "+" ..0
        lb_pro_num1.Text = "+" ..0
        lb_pro_num2.Text = "+" ..0
    else
        nextdata = GlobalHooks.DB.Find("UpLevelExp", {ClassID = data.ClassID+1,ClassUPLevel =  1})[1]
    end

    
        
        
        
    
        lb_level_max.Visible = false
        lb_max_num.Visible = false
    
end

local function setAddAttribute(self)
    if self.isLast then
        setAddAttributeData(self,self.cvs_pro_max,self.realmNow)
        return
    end
    if self.realmNow == nil then
        setAddAttributeData(self,self.cvs_pro_before,self.realmNext,true)
    else
        setAddAttributeData(self,self.cvs_pro_before,self.realmNow)
    end

    setAddAttributeData(self,self.cvs_pro_after,self.realmNext)

end

local function setRealmBreak(self)
    
    
    
end

local function setRankBreak()
    
end

local function refreshUI(self)
    local userdata = DataMgr.Instance.UserData
    local num = userdata:GetAttribute(UserData.NotiFyStatus.REALM)
    num = num == nil and 0 or num

    self.realmNow = GlobalHooks.DB.Find("UpLevelExp", {UpOrder = num})[1]
    self.realmNext = GlobalHooks.DB.Find("UpLevelExp", {UpOrder = num+1})[1]
    self.isLast = GlobalHooks.DB.Find("UpLevelExp", {UpOrder = num+2})[1] == nil

    setAddAttribute(self)


    if not self.isLast then 
        self.lb_maxtips.Visible = false
        self.cvs_pro_before.Visible = true
        self.cvs_pro_after.Visible = true
        self.cvs_pro_max.Visible = false

        local gg_repair = nil
        local tb_use_num = nil
        local btn_getway = nil

        if self.realmNow == nil or self.realmNow.ClassID ~= self.realmNext.ClassID then
            
            self.cvs_break_can.Visible = false
            self.cvs_break_not.Visible = true

            gg_repair = self.cvs_break_not:FindChildByEditName('gg_repair',true)
            tb_use_num = self.cvs_break_not:FindChildByEditName('tb_use_num',true)
            btn_getway = self.cvs_break_not:FindChildByEditName('btn_getway',true)
             
            local ReqEvents = string.split(self.realmNext.ReqEvents,",")
            for i=1,4 do
                local node = self["cvs_condition" .. i]
                if i<= #ReqEvents and ReqEvents[i] ~= "" then
                    node.Visible = true
                    local lb_name = node:FindChildByEditName('lb_name',true)
                    local tb_count = node:FindChildByEditName('tb_count',true)
                    print("ReqEvents[i] = " .. ReqEvents[i])
                    local data = GlobalHooks.DB.Find("UpLevelEvent",tonumber(ReqEvents[i]))
                    lb_name.Text = data.EventName

                    if self.flag == 1 then 
                        
                        tb_count.XmlText = Util.GetText(TextConfig.Type.ATTRIBUTE,113)
                        node.Enable = false
                    else
                        
                        tb_count.XmlText = Util.GetText(TextConfig.Type.ATTRIBUTE,112)
                        node.Enable = true
                    end
                    node.TouchClick = function (sender)
                        EventManager.Fire('Event.Goto', {id = "Dungeons"})
                    end
                else
                    node.Visible = false
                end
            end
        else
            
            self.cvs_break_can.Visible = true
            self.cvs_break_not.Visible = false
            gg_repair = self.cvs_break_can:FindChildByEditName('gg_repair',true)
            tb_use_num = self.cvs_break_can:FindChildByEditName('tb_use_num',true)
            btn_getway = self.cvs_break_can:FindChildByEditName('btn_getway',true)
        end

        local cultivation = userdata:GetAttribute(UserData.NotiFyStatus.CULTIVATION)
        cultivation = cultivation == nil and 0 or cultivation

        gg_repair:SetGaugeMinMax(0, self.realmNext.ReqClassExp)
        gg_repair.Value = cultivation > self.realmNext.ReqClassExp and self.realmNext.ReqClassExp or cultivation
        local text = cultivation .. "/" .. self.realmNext.ReqClassExp
        if cultivation < self.realmNext.ReqClassExp then
            text = string.format("<f color='%s'>%s</f>",Util.GetQualityColorARGBStr(GameUtil.Quality_Red),text) 
            tb_use_num.XmlText = text
        else
            tb_use_num.XmlText = text
        end
        btn_getway.TouchClick = function()
            print("btn_getway.TouchClick")
            self.cvs_repair_all.Visible = true
        end
    else
        self.lb_maxtips.Visible = true
        
        self.cvs_pro_before.Visible = false
        self.cvs_pro_after.Visible = false
        self.cvs_pro_max.Visible = true
        self.cvs_break_can.Visible = false
        self.cvs_break_not.Visible = false

        self.btn_repair_break.Visible = false
    end
end

local function checkCondition(self)
    Player.GetClassEventCondition(function(flag)
        self.flag = flag
        refreshUI(self)
    end)
    
end

function _M:OnEnter()

    checkCondition(self)

    local userdata = DataMgr.Instance.UserData
    userdata:AttachLuaObserver(GlobalHooks.UITAG.GameUIUpStairs, {Notify = function(status, userData)
        if userdata:ContainsKey(status, UserData.NotiFyStatus.REALM) or
        userdata:ContainsKey(status, UserData.NotiFyStatus.CULTIVATION) then
            checkCondition(self)
        end
    end})
end

function _M:OnExit()
    DataMgr.Instance.UserData:DetachLuaObserver(GlobalHooks.UITAG.GameUIUpStairs)
end

function _M:OnDestory()

end

local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create("xmds_ui/character/realm_break.gui.xml",tag)
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.menu.ShowType = UIShowType.Cover
    self.menu.Enable = true
    self.menu:SubscribOnExit(function ()
        self:OnExit()
    end)
    self.menu:SubscribOnEnter(function ()
        self:OnEnter()
    end)
    self.menu:SubscribOnDestory(function ()
        self:OnDestory()
    end)
    
    self.cvs_repair_all.Visible = false

    self.cvs_condition1.Visible = false 
    self.cvs_condition2.Visible = false
    self.cvs_condition3.Visible = false
    self.cvs_condition4.Visible = false
end

function _M.Create(tag)
    local self = {}
    setmetatable(self,_M)
    InitComponent(self,tag)
    return self
end

return _M

