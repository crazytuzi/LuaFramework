local _M = {}
_M.__index = _M

local Util      = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'

local self = {
    menu = nil,
}

local RollingCountDown = 5

local UpdateDuration = 0.1

local self = {
    menu = nil,
}

local function OnEnter()
   
end

local function OnExit()
    self.timer:Stop()
    self.timer = nil

    if self.menu ~= nil then
        self.menu.Visible = false
    end
end

local function requestRollItem(id, cb)
    Pomelo.BattleHandler.throwPointRequest(id, function(ex, sjson)
        if ex then return end
        local data = sjson:ToData()
        cb(data)
    end)
end

local function RefreshRollItem(can, params)
    local gg_time = can:FindChildByEditName("gg_time", true)
    local cvs_equipicon = can:FindChildByEditName("cvs_equipicon", true)
    local lb_equipname = can:FindChildByEditName("lb_equipname", true)
    local lb_itemlv = can:FindChildByEditName("lb_itemlv", true)
    local lb_zhiye = can:FindChildByEditName("lb_zhiye", true)
    
    local detail = ItemModel.GetItemDetailByCode(params.itemcode)
    
    
    if detail then
        local itshow = Util.ShowItemShow(cvs_equipicon,detail.static.Icon,detail.static.Qcolor,params.num)
        Util.NormalItemShowTouchClick(itshow,params.itemcode,false)

        if params.rollType == "rollResult" then
            lb_zhiye.Visible = false
            lb_itemlv.Visible = false
        else
            if detail.static.Pro ~= nil then
                lb_zhiye.Visible = true
                lb_zhiye.Text = detail.static.Pro
                if Util.GetProTxt(DataMgr.Instance.UserData.Pro) ~= detail.static.Pro then
                    lb_zhiye.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
                else
                    lb_zhiye.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Green)
                end
            else
                lb_zhiye.Visible = false
            end
            
            lb_itemlv.Visible = true
            lb_itemlv.Text = tostring(detail.static.LevelReq)..Util.GetText(TextConfig.Type.ATTRIBUTE, 141)
            if detail.static.LevelReq > DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL) then
                lb_itemlv.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Red)
            else
                lb_itemlv.FontColorRGBA = Util.GetQualityColorRGBA(GameUtil.Quality_Green)
            end
        end

        local c = Util.GetQualityColorRGBA(detail.static.Qcolor)
        lb_equipname.Text = detail.static.Name
        lb_equipname.FontColorRGBA = c
    end

    if params.rollType == "rolling" then
        gg_time.Visible = true
        gg_time:SetGaugeMinMax(0, params.time)
        gg_time.Value = params.time
        local btn_need = can:FindChildByEditName("btn_need", true)
        btn_need.TouchClick = function(sender)
            requestRollItem(params.id, function ()
                can.Visible = false
                self.showCount = self.showCount-1
            end)
        end
    elseif params.rollType == "rollResult" then
        gg_time.Visible = false
        gg_time:SetGaugeMinMax(0, RollingCountDown)
        gg_time.Value = RollingCountDown
        can:FindChildByEditName("lb_rollnum", true).Text = params.point
        can:FindChildByEditName("lb_cha_name", true).Text= params.name
    end

    local btn_close = can:FindChildByEditName("btn_close", true)
    btn_close.TouchClick = function(sender)
        can.Visible = false
        self.showCount = self.showCount-1
    end

    can.Visible = true
end

local function GetEmptyItemCan(rollType)
    local itemCan = nil
    if rollType == "rolling" then
        for i=1,4 do
            if self.rollingItemList[i].Visible == false then
                itemCan = self.rollingItemList[i]
            end
        end
    elseif rollType == "rollResult" then
        for i=1,4 do
            if self.rolledItemList[i].Visible == false then
                itemCan = self.rolledItemList[i]
            end
        end
    end

    return itemCan
end

local function AddRollItemShow(params)
    local itemCan = GetEmptyItemCan(params.rollType)
    if itemCan ~= nil then
        RefreshRollItem(itemCan, params)
        self.showCount = self.showCount + 1
        return true
    end

    return false
end

local function onTimerUpdate()
    for i, v in ipairs(self.rollingItemList) do
        if v.Visible == true then
            local gg_time = self.rollingItemList[i]:FindChildByEditName("gg_time", true)
            if gg_time.Value < UpdateDuration then
                v.Visible = false
                self.showCount = self.showCount-1
            else
                gg_time.Value = gg_time.Value - UpdateDuration
            end
        end
    end
    for i, v in ipairs(self.rolledItemList) do
        if v.Visible == true then
            local gg_time = self.rolledItemList[i]:FindChildByEditName("gg_time", true)
            if gg_time.Value < UpdateDuration then
                v.Visible = false
                self.showCount = self.showCount-1
            else
                gg_time.Value = gg_time.Value - UpdateDuration
            end
        end
    end

    if #self.cacheItemList > 0 then
        local result = AddRollItemShow(self.cacheItemList[1])
        if result == true then
            table.remove(self.cacheItemList, 1)
        end
    end

    if self.showCount == 0 and #self.cacheItemList == 0 then
        OnExit()
    end
end

local function InitCompnent(evtName, params)
    local UIName = {
        "cvs_rollCan",

        "cvs_rolling",
        "cvs_rollen",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:FindChildByEditName(UIName[i],true)
    end
    self.rollingItemList = {}

    self.rolledItemList = {}

    self.cacheItemList = {}

    for i=1,4 do
        if i == 1 then
            self.rollingItemList[i] = self.cvs_rolling
            self.rolledItemList[i] = self.cvs_rollen
        else
            self.rollingItemList[i] = self.cvs_rolling:Clone()
            self.cvs_rollCan:AddChild(self.rollingItemList[i])
            self.rolledItemList[i] = self.cvs_rollen:Clone()
            self.cvs_rollCan:AddChild(self.rolledItemList[i])
        end
            self.rollingItemList[i].Y = 120*i-20
            self.rolledItemList[i].Y = 580-120*i
            self.rollingItemList[i].Visible = false
            self.rolledItemList[i].Visible = false
    end
end

local function Init()
    self.menu = HudManagerU.Instance.CreateHudUIFromFile("xmds_ui/dungeon/dungeon_Roll.gui.xml")
    HudManagerU.Instance:AddHudUI(self.menu, "FubenRollUI")
    
    
    
    InitCompnent()
    
    
    
    
    
    return self.menu
end

local function Create()
    setmetatable(self, _M)
    local node = Init()
    return self.menu
end

local function Show(params)
    if self.menu == nil then
        self.showCount = 0
        self.menu = Create()
    end
    self.menu.Visible = true
    local result = AddRollItemShow(params)
    if result == false then
        table.insert(self.cacheItemList, params)
    end

    if self.timer == nil then
        self.timer = Timer.New(onTimerUpdate, 0.1, -1)
        self.timer:Start()
    end
end

local function fin(relogin)
    
    
end

return {Create = Create, fin = fin, Show = Show, dont_destroy = true}
