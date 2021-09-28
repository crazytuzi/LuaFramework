local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local FubenApi = require "Zeus.Model.Fuben"
local FubenUtil = require "Zeus.UI.XmasterFuben.FubenUtil"
local CDLabelExt = require "Zeus.Logic.CDLabelExt"

local self = {
    menu = nil,
}

local resFubenType = {
    JiXianTiaoZhan = 1,
    ShouHuShenChong = 2,
    HuanYaoNongChang = 3,
}

local function SendResFubenBiData()
    local reward = ""
    if self.fubenInfo.itemLine1 and #self.fubenInfo.itemLine1>0 then
        for i,v in ipairs(self.fubenInfo.itemLine1) do
            local detail = ItemModel.GetItemDetailByCode(v.itemCode)
            reward = reward .. "," .. string.format("%s(%s):%d", detail.static.Name,v.itemCode,v.itemNum)
        end
    end
    local mapId = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.MAPID)
    local mapData = GlobalHooks.DB.Find("Map", { MapID = mapId })[1]
    local win = Util.GetText(TextConfig.Type.SOLO, "win")
    Util.SendBIData("ResFuben","",mapData.Name,mapId,win,reward,"")
end








local function updateItemCell(data, node)
    if data == nil then
        node.Visible = false
        return
    end
    node.Visible = true
    local detail = ItemModel.GetItemDetailByCode(data.itemCode)
    local iconCan = node:FindChildByEditName("cvs_icon", true)
    local itshow = Util.ShowItemShow(iconCan,detail.static.Icon,detail.static.Qcolor,data.itemNum,true)
    Util.NormalItemShowTouchClick(itshow,data.itemCode,false)
end

local function GetProgressTitlePath(resFubenType,index)
    local path = ""
    if resFubenType == 1 then
        local resData = GlobalHooks.DB.Find("ResEvent", {Type = 1})
        if resData then
            for i,v in ipairs(resData) do
                local params = string.split(v.Parm, ':')
                if #params >= 2 and index >= tonumber(params[1]) and index <= tonumber(params[2]) then
                    path = v.ResourcePath
                    return path
                end
            end
        end
    elseif resFubenType == 2 then
        local resData = GlobalHooks.DB.Find("ResEvent", {Type = 2, Parm = tostring(index)})
        if resData then
            path = resData[1].ResourcePath
        end
    end

    return path
end

local function SetProgressTitle(resFubenType,index)
    local path = GetProgressTitlePath(resFubenType,index)
    if path and string.len(path) > 0 then
        self.lb_rank.Layout = XmdsUISystem.CreateLayoutFroXml(path,LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
        self.lb_rank.Visible = true
    else
        self.lb_rank.Visible = false
    end
end

local function SetResultTitle()
    self.lb_success.Visible = self.fubenInfo.succ == 1
    self.lb_faild.Visible = self.fubenInfo.succ == 0
end

local function SetProgress(resFubenType, num, time, wave)
    if resFubenType == 1 then
        self.lb_rank.Visible = true
        SetProgressTitle(resFubenType,time)
        self.lb_num.Text = Util.GetText(TextConfig.Type.FUBEN, "resFubenOverTips1", time)
    elseif resFubenType == 2 then
        self.lb_rank.Visible = true
        SetProgressTitle(resFubenType,wave)
        self.lb_num.Text = Util.GetText(TextConfig.Type.FUBEN, "resFubenOverTips2", wave)
    elseif resFubenType == 3 then
        self.lb_rank.Visible = false
        self.lb_num.Text = Util.GetText(TextConfig.Type.FUBEN, "resFubenOverTips3", num)
    end
end

local function InitDropCans(data)
    

    local num = self.fubenInfo.killMonster
    local time = math.floor(FubenApi.GetResFubenTime())
    local wave = math.floor(FubenApi.GetResFubenWave())
    if self.fubenInfo.succ == 0 then
        wave = wave - 1
    end

    
    local resFubenType = 1
    local mapId = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.MAPID)
    if mapId == 51001 or mapId == 51002 or mapId == 51003 then
        resFubenType = 1
        
        EventManager.Fire("Event.Hud.StopHudTimeCount", {})
    elseif mapId == 51004 or mapId == 51005 or mapId == 51006 then
        resFubenType = 2
    elseif mapId == 51007 or mapId == 51008 or mapId == 51009 then
        resFubenType = 3
    end



    SetResultTitle()
    SetProgress(resFubenType, num, time, wave)

    self.lb_exp_num.Text = self.fubenInfo.exp
    self.lb_gold_num.Text = self.fubenInfo.gold

    self.lb_doubleCost.Visible = self.fubenInfo.doubleCost > 0
    self.ib_costicon.Visible = self.fubenInfo.doubleCost > 0
    self.btn_double.Visible = self.fubenInfo.doubleCost >= 0
    self.lb_doubleCost.Text = self.fubenInfo.doubleCost

    local itemCount = 0
    if data.itemLine1 ~= nil then
        itemCount = #data.itemLine1
    end
    local row = math.ceil(itemCount/6)
    local column = 6
    self.sp_item_list:Initialize(
      self.cvs_drop_item.Width+10, 
      self.cvs_drop_item.Height+10, 
      row,
      6,
      self.cvs_drop_item, 
      LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
        local index = x+1+y*6
        local cellData = data.itemLine1[index]
        updateItemCell(cellData, node)
      end
      ),
      LuaUIBinding.HZTrusteeshipChildInit(function (node)
        
      end)
    )

    self.btn_exit.Visible = self.btn_double.Visible
    self.btn_exit1.Visible = not self.btn_double.Visible
end

local function reqLeave()
    self.CDLabelExt:stop()
    self.CDLabelExt = nil
    FubenApi.requestLeaveFuben()
end

local function SetResFubenOverInfo(info)
    self.fubenInfo = info
    InitDropCans(info)

    self.btn_close.TouchClick = function(sender)
        reqLeave()
    end
    self.btn_exit.TouchClick = function(sender)
        reqLeave()
    end
    self.btn_exit1.TouchClick = function(sender)
        reqLeave()
    end
    self.btn_double.TouchClick = function(sender)
        FubenApi.reqDoubleRewardResFuben(self.fubenInfo.dungeonId, function ()
            reqLeave()
        end)
    end

    local function format(cd,label)
        self.btn_exit.Text = Util.GetText(TextConfig.Type.FUBEN, "resFubenExit", math.floor(cd))
        self.btn_exit1.Text = Util.GetText(TextConfig.Type.FUBEN, "resFubenExit", math.floor(cd))
        if math.floor(cd) <= 0 then
            reqLeave()
        end
    end

    local CutDownExit = 30
    self.CDLabelExt = CDLabelExt.New(nil,CutDownExit,format)
    self.CDLabelExt:start()

    SendResFubenBiData()
end

local function OnExit()
    FubenApi.SetResFubenTime(0)
    FubenApi.SetResFubenWave(0)
end

local function OnEnter()

end

local function InitUI()
    local UIName = {
        "btn_close",
        "lb_success",
        "lb_faild",
        "lb_num",
        "lb_rank",
        "cvs_exp",
        "lb_exp_num",
        "cvs_money",
        "lb_gold_num",
        "sp_item_list",
        "cvs_drop_item",
        "btn_double",
        "ib_costicon",
        "lb_doubleCost",
        "btn_exit",
        "btn_exit1",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    self.cvs_drop_item.Visible = false
end

local function InitCompnent(params)
    InitUI()

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/res/res_over.gui.xml", GlobalHooks.UITAG.GameUIResFubenOverUI)
    InitCompnent(params)
    return self.menu
end

local function Create(params)
    setmetatable(self, _M)
    local node = Init(params)
    return self
end


local function initial()
    
end

_M.SetResFubenOverInfo = SetResFubenOverInfo

return {Create = Create, initial = initial}
