local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"
local ItemModel = require 'Zeus.Model.Item'

local self = {
    menu = nil,
}

local function UpdateTodayItem(items)
    self.sp_list:Initialize(self.cvs_icon.Width+20, self.cvs_icon.Height,
        1, #items.item, self.cvs_icon, 
        function (x, y, node)
            local data = items.item[x+1]
            local detail = ItemModel.GetItemDetailByCode(data.code)
            node.EnableChildren = true
            local itshow = Util.ShowItemShow(node,detail.static.Icon,detail.static.Qcolor,data.groupCount,true)
            Util.NormalItemShowTouchClick(itshow,data.code,false)
        end
        , 
        LuaUIBinding.HZTrusteeshipChildInit(function (node)
          
        end)
    )

    self.btn_lingqu.Visible = items.state == 1
    self.ib_today_have.Visible = items.state == 2
end

local function UpdateItemCell(node, data)
    if data == nil then
        node.Visible = false
        return
    else
        node.Visible = true
    end

    local cvs_pic = node:FindChildByEditName("cvs_pic", true)
    local lb_price = node:FindChildByEditName("lb_price", true)
    local ib_have = node:FindChildByEditName("ib_have", true)
    local lb_bj = node:FindChildByEditName("lb_bj", true)

    lb_price.Text = data.money .. "y"
    lb_bj.Visible = data.state == 1
    if data.day > 0 then
      ib_have.Visible = data.day == self.today
    else
      ib_have.Visible = data.state == 2
      cvs_pic.IsGray = data.state == 2
    end

    node.EnableChildren = false

    node.TouchClick = function ()
        if data.state == 1 then
            ActivityAPI.ContinuousRechargeAwardRequest(data.day, function()
                if self.menu then
                    data.state = 2
                    UpdateItemCell(node, data)
                end
            end)
        else
            EventManager.Fire('Event.OnPreviewItems',{items = data.item or {}})
        end
    end

    if self.today == data.day then
        UpdateTodayItem(data)
        self.btn_lingqu.TouchClick = function ()
            ActivityAPI.ContinuousRechargeAwardRequest(self.today, function()
                if self.menu then
                    data.state = 2
                    UpdateItemCell(node, data)
                end
            end)
        end
    end
end

local function UpdateContinueItem()
    self.btn_lingqu.Visible = false
    self.ib_today_have.Visible = false
    if #self.infoList > 0 then
        for i=1,6 do
          if i < 6 then
            UpdateItemCell(self["cvs_"..i+1], self.infoList[i+1])
          else
            UpdateItemCell(self["cvs_"..1], self.infoList[1])
          end
        end
    else
        self.lb_lvnum.Visible = false
        self.sp_list.Visible = false
        for i=1,6 do
          self["cvs_"..i].Visible = false
        end
    end
end

local function updateTimeAndDesc(beginTime, endTime, desc, currNum, needNum)
    local timeStr
    if endTime == nil or endTime == "" or endTime == "3016-01-01 23:59:59" then
        timeStr = Util.GetText(TextConfig.Type.ACTIVITY, "forever")
    else
        local beginTime = string.gsub(beginTime, '%-', '/')
        local endTime = string.gsub(endTime, '%-', '/')
        timeStr = beginTime .. " - " .. endTime
    end

    self.lb_time.Text = timeStr

    self.lb_jindu.Text = currNum .. "/" .. needNum
end

local function RequestInfo()
    if self.menu then
        local func = ActivityAPI.ContinuousRechargeGetInfoRequest(function ( data )
            if self.menu then
                self.infoList = data.continuousRechargeAwardInfo or {}
                self.today = data.day
                updateTimeAndDesc(data.beginTime, data.endTime, data.describe,data.currNum,data.needNum)
                UpdateContinueItem()
            end
        end)
    end
end

local function OnEnter()
    RequestInfo()

    self.rechargeExt:start()
end

local function OnExit()
    self.rechargeExt:stop()
end

local ui_names = 
{
  
  

  {name = 'lb_time'},
  {name = 'lb_lvnum'},
  {name = 'cvs_1'},
  {name = 'cvs_2'},
  {name = 'cvs_3'},
  {name = 'cvs_4'},
  {name = 'cvs_5'},
  {name = 'cvs_6'},
  {name = 'sp_list'},
  {name = 'cvs_icon'},
  {name = 'btn_lingqu'},
  {name = 'ib_today_have'},
  {name = 'btn_chongzhi'},
  {name = 'lb_jindu'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.cvs_icon.Visible = false

  
  
  

  self.btn_chongzhi.TouchClick = function ()
      EventManager.Fire('Event.Goto', {id = "Pay"})
  end

  self.rechargeExt = UserDataValueExt.New(UserData.NotiFyStatus.DIAMOND,RequestInfo)
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/carnival/continue.gui.xml", GlobalHooks.UITAG.GameUIHotContinue)
  self.menu.Enable = false
  self.menu.mRoot.Enable = false
  

  InitCompnent()
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
  self.menu:SubscribOnDestory(function ()
    self = nil
  end)
  return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

return {Create = Create}
