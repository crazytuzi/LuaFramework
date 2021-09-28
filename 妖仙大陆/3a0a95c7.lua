local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local Player = require"Zeus.Model.Player"
local BossFightModel        = require 'Zeus.Model.BossFight'
local self = {
    menu = nil,
}






local function RefreshHuanJingItem(self,index,node,section)
    if not section then node.Visible = false end
    node.Visible = true
    local ib_gray = node:FindChildByEditName("ib_gray", false)
    local cvs_mappic = node:FindChildByEditName("cvs_mappic", false)
    local lb_name = node:FindChildByEditName("lb_name", false)
    local lb_level = node:FindChildByEditName("lb_level", false)
    local btn_go = node:FindChildByEditName("btn_go", false)
    local cvs_hope = node:FindChildByEditName("cvs_hope", false)
    local lb_nonopen = node:FindChildByEditName("lb_nonopen", false)
    local ib_discount = node:FindChildByEditName("ib_discount", false)

    if section.pleaseHold == nil then
        lb_name.Visible = true
        cvs_mappic.Visible = true
        lb_level.Visible = true
        btn_go.Visible = true
        cvs_hope.Visible = false

        btn_go.TouchClick = function(sender)
        if BattleClientBase.GetActor().CombatState then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILD, "fighting"))
            return
        end
        BossFightModel.enterLllsionRequest(section.ID,function (params)
            
            EventManager.Fire("Event.Quest.CancelAuto", {});
            
            end)
        end
        Util.HZSetImage(cvs_mappic, section.MapPicture,false,LayoutStyle.IMAGE_STYLE_BACK_4)

        local playerLv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
        btn_go.Visible  = (playerLv >= section.MinLv and playerLv <= section.MaxLv)
        ib_gray.Visible = playerLv < section.MinLv
        lb_nonopen.Visible = playerLv < section.MinLv
        ib_discount.Visible = (index == 0)

        lb_name.Text = section.Name
        lb_level.Text = string.format("(%d-%d)",section.MinLv,section.MaxLv) 
    else
        lb_name.Visible = false
        cvs_mappic.Visible = false
        lb_level.Visible = false
        btn_go.Visible = false
        cvs_hope.Visible = true
    end
end

local function OnExit()

end

local function OnEnter()
    BossFightModel.getLllsionInfoRequest(function (params)
        local exp = params.s2c_today_exp
        local gold = params.s2c_today_gold
        local lv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
        self.lb_exp_num.Text = exp
        self.lb_exp_num.FontColorRGBA = 0xffffffff  
        
        self.lb_silver_num.Text = gold
        self.lb_silver_num.FontColorRGBA = 0xffffffff  

        for i,v in ipairs(self.expRets) do
            if lv >= v.MinLv and lv <= v.MaxLv then
                if exp <= v.Rate1 then
                    self.lb_exp_rate.Text = 0
                elseif exp <= v.Rate2 then
                    self.lb_exp_rate.Text = 20
                elseif exp <= v.Rate3 then
                    self.lb_exp_rate.Text = 40
                elseif exp <= v.Rate4 then
                    self.lb_exp_rate.Text = 60
                else
                    self.lb_exp_rate.Text = 80
                end
                break
            end
        end

        for i,v in ipairs(self.glodRets) do
            if lv >= v.MinLv and lv <= v.MaxLv then
                if exp <= v.Rate1 then
                    self.lb_silver_rate.Text = 0
                elseif exp <= v.Rate2 then
                    self.lb_silver_rate.Text = 20
                elseif exp <= v.Rate3 then
                    self.lb_silver_rate.Text = 40
                elseif exp <= v.Rate4 then
                    self.lb_silver_rate.Text = 60
                else
                    self.lb_silver_rate.Text = 80
                end
                break
            end
        end
    end)
end

local function InitHuanjingList()
    local sectionDatas = GlobalHooks.DB.Find('Section', {}) 
    local playerLv = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL)
    table.sort( sectionDatas, function(a,b)
        if playerLv > a.MinLv and playerLv > b.MinLv then
            return a.ID > b.ID
        elseif a.MinLv > playerLv then
            return false
        elseif b.MinLv > playerLv then
            return true
        else
            return a.ID < b.ID
        end
    end )

    local item_counts = #sectionDatas
    self.sp_detail.Scrollable:ClearGrid()
    if self.sp_detail.Rows <= 0 then
        self.sp_detail.Visible = true
        local cs = self.cvs_single.Size2D
        self.sp_detail:Initialize(cs.x,cs.y,item_counts,1,self.cvs_single,
        function (gx,gy,node)
            local section = sectionDatas[gy + 1]
            RefreshHuanJingItem(self,gy,node,section)
        end,function () end)
    else
        self.sp_detail.Rows = item_counts
    end 
end

local function InitIntroduce()
    self.sp_rank_list1:Initialize(self.cvs_level_point1.Width,self.cvs_level_point1.Height,#self.expRets,1,self.cvs_level_point1,
    function (gx,gy,node)
        local data = self.expRets[gy + 1]
        local lb_lv = node:FindChildByEditName("lb_lv", false)
        lb_lv.Text = string.format("%d-%d%s",data.MinLv,data.MaxLv,Util.GetText(TextConfig.Type.MAP,"lv"))
        for i=1,4 do
            local lb_point = node:FindChildByEditName("lb_point"..i, false)
            lb_point.Text = data["Rate"..i]
        end
    end,function () end)

    self.sp_rank_list2:Initialize(self.cvs_level_point2.Width,self.cvs_level_point2.Height,#self.glodRets,1,self.cvs_level_point2,
    function (gx,gy,node)
        local data = self.glodRets[gy + 1]
        local lb_lv = node:FindChildByEditName("lb_lv", false)
        lb_lv.Text = string.format("%d-%d%s",data.MinLv,data.MaxLv,Util.GetText(TextConfig.Type.MAP,"lv"))
        for i=1,4 do
            local lb_point = node:FindChildByEditName("lb_point"..i, false)
            lb_point.Text = data["Rate"..i]
        end
    end,function () end)
end

local function InitUI()
    local UIName = {
        "btn_close",
        "btn_help",
        "btn_introduce",
        "sp_detail",
        "cvs_single",
        "cvs_introdece",
        "cvs_introdece1",
        "sp_rank_list1",
        "cvs_level_point1",
        "sp_rank_list2",
        "cvs_level_point2",
        "lb_exp_num",
        "lb_silver_num", 
        "lb_exp_rate",
        "lb_silver_rate",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.cvs_single.Visible = false

    self.btn_close.TouchClick = function(sender)
        self.menu:Close()
    end

    self.btn_help.TouchClick = function(sender)
        self.cvs_introdece.Visible = true
    end

    self.btn_introduce.TouchClick = function(sender)
        self.cvs_introdece.Visible = false
    end

    self.cvs_introdece1.TouchClick = function(sender)
        self.cvs_introdece.Visible = false
    end

    self.cvs_level_point1.Visible = false
    self.cvs_level_point2.Visible = false
    self.cvs_introdece.Visible = false

    self.expRets = GlobalHooks.DB.GetFullTable("ExpReduce")
    self.glodRets = GlobalHooks.DB.GetFullTable("GoldReduce")
    
    InitIntroduce()

    InitHuanjingList()
end

local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create("xmds_ui/illusion/illusion.gui.xml", tag)

    InitUI()

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)

    return self.menu
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}
