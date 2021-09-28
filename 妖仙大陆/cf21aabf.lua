local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local MasteryUtil = require 'Zeus.UI.MasteryUtil'
local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"


local RICH_ITEM_MAX = 35

local self = {
    menu = nil,
}

local picIndex = {31,32,33,35,34}

local function UpdateStepAfterRoll()
    self.StepNodeList[self.NowStep].Visible = true
    if self.ShowNode then
        self.ShowNode.Visible = false
    end
    self.ShowNode = self.StepNodeList[self.NowStep]
    self.lb_count.Text = self.RichInfo.freeCount
end

local function UpdateTaskCell(node, data)
    node.Text = string.format("%s: (%d/%d)", data.schName, data.finishedCount, data.maxCount)
    if data.finishedCount >= data.maxCount then
        node.FontColor = Util.FontColorGreen
    else
        node.FontColor = GameUtil.RGBA2Color(0xFFA1BEEA)
    end
end

local function UpdateTaskList()
    local count = #(self.RichInfo.taskInfo or {})
    self.sp_list_task:Initialize(self.lb_tmp_task.Width, self.lb_tmp_task.Height + 15, count, 1, self.lb_tmp_task, 
        function (x, y, node)
            local data = self.RichInfo.taskInfo[y+1]
            UpdateTaskCell(node, data)
        end
        , 
        LuaUIBinding.HZTrusteeshipChildInit(function (node)
          
        end)
    )
end

local function UpdateRewardCell(node, data)
    local ib_turn = node:FindChildByEditName("ib_turn", true)
    local ib_get = node:FindChildByEditName("ib_get", true)
    ib_get.Visible = data.state == 2
    if data.state == 1 then
        Util.showUIEffect(node,3)
    else
        Util.clearAllEffect(node)
    end
    ib_turn.Layout = XmdsUISystem.CreateLayoutFroXml("#dynamic_n/hot/hot.xml|hot|"..picIndex[data.turnId], LayoutStyle.IMAGE_STYLE_BACK_4, 0)
    
    node.Enable = true
    node.TouchClick = function ()
        if data.state == 1 then
            ActivityAPI.FetchTurnAwardRequest(data.turnId, function()
                if self.menu then
                    data.state = 2
                    UpdateRewardCell(node, data)
                end
            end)
        else
            EventManager.Fire('Event.OnPreviewItems',{items = data.reward or {}})
        end
    end
end

local function UpdateRewardList()
    local count = #(self.RichInfo.turnReward or {})
    self.sp_list_reward:Initialize(self.cvs_tmp_reward.Width+20, self.cvs_tmp_reward.Height, 1, count, self.cvs_tmp_reward, 
        function (x, y, node)
            local data = self.RichInfo.turnReward[x+1]
            UpdateRewardCell(node, data)
        end
        , 
        LuaUIBinding.HZTrusteeshipChildInit(function (node)
          
        end)
    )
end

local function CleanShowNode()
    if self.ShowNode then
        self.ShowNode.Visible = false
        self.ShowNode = nil
    end
end

local function updateTimeAndDesc(beginTime, endTime)
    local timeStr
    if endTime == nil or endTime == "" or endTime == "3016-01-01 23:59:59" then
        timeStr = Util.GetText(TextConfig.Type.ACTIVITY, "forever")
    else
        local beginTime = string.gsub(beginTime, '%-', '/')
        local endTime = string.gsub(endTime, '%-', '/')
        timeStr = beginTime .. " - " .. endTime
    end

    self.lb_time.Text = timeStr
end

local function OnEnter()
    CleanShowNode()

    ActivityAPI.GetRichInfoRequest(function(data)
        self.RichInfo = data
        self.NowStep = data.currentStep
        self.StepNodeList[self.NowStep].Visible = true
        self.ShowNode = self.StepNodeList[self.NowStep]
        self.lb_count.Text = self.RichInfo.freeCount
        UpdateRewardList()
        UpdateTaskList()
        updateTimeAndDesc(data.startTimestamp, data.endTimestamp)
    end)
end

local function OnExit()
    CleanShowNode()
end

local function DiceRequest()
    ActivityAPI.DiceRequest(function(data)
        self.NowStep = self.NowStep + data.step
        if self.NowStep > RICH_ITEM_MAX then
            OnEnter()
        else
            UpdateStepAfterRoll()
        end
    end)
end

local ui_names = 
{
  
  

  {name = 'sp_list_reward'},
  {name = 'cvs_tmp_reward'},

  {name = 'sp_list_task'},
  {name = 'lb_tmp_task'},

  {name = 'btn_zhidian'},
  {name = 'lb_count'},

  {name = 'cvs_chest'},
  {name = 'lb_time'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  
  
  

  self.cvs_tmp_reward.Visible = false
  self.lb_tmp_task.Visible = false

  self.needDiamond = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "Zillionaire.Yuanbao.One"})[1].ParamValue)

  local ret = GlobalHooks.DB.GetFullTable("Zillionaire_Cage")

  self.StepNodeList = {}
  for i=1,RICH_ITEM_MAX do
      local node = self.cvs_chest:FindChildByEditName("cvs_" .. i, true)
      local cvs_icon = node:FindChildByEditName("cvs_icon", true)
      local ib_choice = node:FindChildByEditName("ib_choice", true)
      node.Enable = false
      ib_choice.Enable = false
      ib_choice.Visible = false
      local detail = ItemModel.GetItemDetailByCode(ret[i].ItemCode)
      local itshow = Util.ShowItemShow(cvs_icon, detail.static.Icon, detail.static.Qcolor, ret[i].NUM)
      Util.NormalItemShowTouchClick(itshow,ret[i].ItemCode,false)
      table.insert(self.StepNodeList, ib_choice)
  end

  self.btn_zhidian.TouchClick = function ()
      if self.RichInfo.freeCount > 0 then
          self.RichInfo.freeCount = self.RichInfo.freeCount - 1
          DiceRequest()
      else
          GameAlertManager.Instance:ShowAlertDialog(
              AlertDialog.PRIORITY_NORMAL, 
              Util.GetText(TextConfig.Type.ACTIVITY, "richNotEnough", self.needDiamond),
              nil,nil,nil,
              function ()
                  DiceRequest()
              end,
              nil
          )
      end
  end
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/carnival/rich.gui.xml", GlobalHooks.UITAG.GameUIHotRich)
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
