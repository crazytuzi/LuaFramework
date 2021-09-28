local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local CDLabelExt = require "Zeus.Logic.CDLabelExt"
local DemonTower = require "Zeus.Model.DemonTower"
local ServerTime = require "Zeus.Logic.ServerTime"

local self = {
    
}

local function StopCutDown()
    if self.CDLabelExt ~= nil then
        self.CDLabelExt:stop()
        self.CDLabelExt = nil
    end
    Util.clearUIEffect(self.cvs_effect,59)
end

local function StartCutDown()
    local function format(cd,label)
        if cd <= 0 then
            StopCutDown()
            self.menu:Close()
        end
        return ServerTime.GetCDTimeDesc(cd)
    end

    self.CDLabelExt = CDLabelExt.New(self.lb_time,self.SweepInfo.sweepTime,format)
    self.CDLabelExt:start()
end

local function UpdateItemCell(data, node)
    if data == nil then
        node.Visible = false
        return
    end
    node.Visible = true
    local detail = ItemModel.GetItemDetailByCode(data.code)
    local iconCan = node:FindChildByEditName("cvs_icon", true)
    local itshow = Util.ShowItemShow(iconCan,detail.static.Icon,detail.static.Qcolor,data.value,true)
    Util.NormalItemShowTouchClick(itshow,data.code,false)
end

local  function RefreshSweepInfo()
    local itemCount = 0
    if self.SweepInfo.itemView then
        itemCount = #self.SweepInfo.itemView
    end
    local row = math.ceil(itemCount/5)
    local column = 5
    self.sp_item_list:Initialize(
      self.cvs_drop_item.Width+10, 
      self.cvs_drop_item.Height+10, 
      row,
      5,
      self.cvs_drop_item, 
      LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
        local index = x+1+y*5
        UpdateItemCell(self.SweepInfo.itemView[index], node)
      end
      ),
      LuaUIBinding.HZTrusteeshipChildInit(function (node)
        
      end)
    )

    self.cvs_1.Visible = not self.SweepInfo.isSweeping
    self.cvs_2.Visible = self.SweepInfo.isSweeping

    self.lb_title.Text = Util.GetText(TextConfig.Type.FUBEN, "saodangTips1", self.SweepInfo.floor)
    self.lb_time.Text = ServerTime.GetCDTimeDesc(self.SweepInfo.sweepTime)
    self.lb_price.Text = self.SweepInfo.diamondCost
    self.lb_price1.Text = self.SweepInfo.diamondCost
    
    if self.SweepInfo.isSweeping then
        StartCutDown()
        Util.showUIEffect(self.cvs_effect,59)
    end
end

local function OnExit()
    StopCutDown()
end

local function OnEnter()
    DemonTower.GetDemonTowerSweepInfoRequest(function (data)
        self.SweepInfo = data
        RefreshSweepInfo()
    end)

    self.btn_free.TouchClick = function(sender)
        DemonTower.StartToSweepDemonTowerRequest(function (data)
            self.cvs_1.Visible = false
            self.cvs_2.Visible = true
            Util.showUIEffect(self.cvs_effect,59)
            StartCutDown()
        end)
    end

    self.btn_pay.TouchClick = function(sender)
        DemonTower.FinishSweepDemonTowerRequest(function (data)
            self.menu:Close()
        end)
    end

    self.btn_pay1.TouchClick = function(sender)
        
        DemonTower.FinishSweepDemonTowerRequest(function (data)
            self.menu:Close()
        end)
    end
end

local function InitUI()
    local UIName = {
        "btn_close",

        "lb_title",
        "lb_time",

        "sp_item_list",
        "cvs_drop_item",

        "cvs_1",
        "cvs_2",
        "btn_free",
        "btn_pay",
        "btn_pay1",
        "lb_price",
        "lb_price1",
        "cvs_effect",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.btn_close.TouchClick = function(sender)
        self.menu:Close()
    end

    self.cvs_drop_item.Visible = false
end

local function InitCompnent(tag,params)
    self.menu = LuaMenuU.Create("xmds_ui/demontower/saodang.gui.xml", GlobalHooks.UITAG.GameUIDemonTowerSweep)

    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        
    end)
end


local function Create(tag,params)
    setmetatable(self, _M)
    InitCompnent(tag,params)
    return self
end

return {Create = Create}
