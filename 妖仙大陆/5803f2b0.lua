local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ActivityAPI = require "Zeus.Model.Activity"
local TreeView = require "Zeus.Logic.NewTreeView"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"

local self = {}

local function InitUI()

  local UIName = {
    "sp_see",
    "cvs_single",
    "lb_time",
  }
  for i=1,#UIName do
    self[UIName[i]] = self.menu:GetComponent(UIName[i])
  end
  self.cvs_single.Visible = false
  
end

local function ReachTarget(infoList,dataList)
  for k,v in pairs(infoList) do
    for m,n in pairs(dataList) do
      if v.ID == n.taskId then
        if v.TargetNum > n.finishedNum then
          return false
        end
      end
    end
  end
  return true
end

local function UpdateState(node)
  node.Visible = false
end

local function RefreshReportList(data,reportList)
    if self.treeView and self.treeView.view then
        self.sp_see:RemoveNormalChild(self.treeView.view, true)
    end

    local subValues = {}
    local subValueChild = {1,1,1,1,1,1,1}
    local dataList = data.dayInfo
    local currDay = 1
    if data.currentDayId >= 1 and data.currentDayId <=7 then
      currDay = data.currentDayId
    end

    local cvs_typename = self.cvs_single:FindChildByEditName("cvs_typename", true)
    local tbt_subtype = self.cvs_single:FindChildByEditName("tbt_subtype", true)

    self.treeView = TreeView.Create(#subValueChild,0,self.sp_see.Size2D,TreeView.MODE_SINGLE,nil,true)
    local function rootCreateCallBack(index,node)
        local cvsList = {}
        local ibList = {}
        node.Enable = true
        local lb_day = node:FindChildByEditName("lb_day", true)
        local ib_effect = node:FindChildByEditName("ib_effect",true)
        local ib_have = node:FindChildByEditName("ib_have",true)
        local btn_operation = node:FindChildByEditName("btn_operation",true)
        local lb_complete = node:FindChildByEditName("lb_complete",true)
        local lb_target = node:FindChildByEditName("lb_target",true)

        lb_day.Layout = XmdsUISystem.CreateLayoutFroXml(reportList[index].DatePicture, LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
        local dailyInfo  = GlobalHooks.DB.Find('SevDayTask',{Date = dataList[index].dayId,ID = dataList[index].taskInfo.taskId})
        local IsActive = ReachTarget(dailyInfo,dataList[index].taskInfo)
        ib_effect.Visible = IsActive and not dataList[index].fetched
        btn_operation.Visible = not dataList[index].fetched
        lb_complete.Visible = IsActive
        lb_target.Visible = not IsActive
        ib_have.Visible = dataList[index].fetched
        btn_operation.TouchClick = function()
          ActivityAPI.FetchAwardRequest(dataList[index].dayId,function(params)
              if params.s2c_code == 200 then
                ib_have.Visible = true
                ib_effect.Visible = false
                UpdateState(btn_operation)
              end
          end)
        end
        
        table.insert(ibList,node:FindChildByEditName("ib_icon1",true))
        table.insert(ibList,node:FindChildByEditName("ib_icon2",true))
        table.insert(ibList,node:FindChildByEditName("ib_icon3",true))
        table.insert(ibList,node:FindChildByEditName("ib_icon4",true))
        table.insert(ibList,node:FindChildByEditName("ib_icon5",true))
        table.insert(ibList,node:FindChildByEditName("ib_icon6",true))

        table.insert(cvsList,node:FindChildByEditName("cvs_icon1",true))
        table.insert(cvsList,node:FindChildByEditName("cvs_icon2",true))
        table.insert(cvsList,node:FindChildByEditName("cvs_icon3",true))
        table.insert(cvsList,node:FindChildByEditName("cvs_icon4",true))
        table.insert(cvsList,node:FindChildByEditName("cvs_icon5",true))
        table.insert(cvsList,node:FindChildByEditName("cvs_icon6",true))
        local rewardList = string.split(reportList[index].Reward,";")
        for i=1,#cvsList do
          if i <= #rewardList then
            local rewardStr = string.split(rewardList[i],":")
            local code = rewardStr[1]
            local it = GlobalHooks.DB.Find("Items",code)
            local num = tonumber(rewardStr[2])
            local itshow = Util.ShowItemShow(cvsList[i],it.Icon,it.Qcolor,num,true)
            Util.NormalItemShowTouchClick(itshow,code,false)
          else
            cvsList[i].Visible = false
            ibList[i].Visible = false
          end
        end
        node.IsGray = node.UserTag > currDay
        node.Enable = node.UserTag <= currDay
        node.EnableChildren = node.UserTag <= currDay
    end
    local function rootClickCallBack(node,visible)

    end
    local rootValue = TreeView.CreateRootValue(cvs_typename,#subValueChild,rootCreateCallBack,rootClickCallBack)

    local function subClickCallback(rootIndex,subIndex,node)
 
    end
    local function subCreateCallback(rootIndex,subIndex,node)
        
        local data = dataList[rootIndex].taskInfo
        if #data > 1 then
          table.sort( data, function ( a,b)
            return a.taskId < b.taskId
          end )
        end
        local dayInfo = GlobalHooks.DB.Find('SevDayTask',{Date = dataList[rootIndex].dayId})
        if #dayInfo > 1 then
          table.sort( dayInfo, function (a,b)
            return a.ID < b.ID
          end )
        end
        local sp_list = node:FindChildByEditName("sp_list",true)
        local lb_condition = node:FindChildByEditName("lb_condition",true)
        sp_list:Initialize(lb_condition.Width, lb_condition.Height + 5, #dayInfo,1, lb_condition,
        function(x, y, cell)
          local index = y + 1
          cell.Text = dayInfo[index].Describe..":  "..data[index].finishedNum.."/"..dayInfo[index].TargetNum
          if data[index].finishedNum < dayInfo[index].TargetNum then
            cell.FontColorRGBA = 0xa1beeaff 
          else
            cell.FontColorRGBA = 0x00cc00ff 
          end
          cell.Visible = true
      end,
      function()

      end
      )
    end

    for i=1,#subValueChild do
        subValues[i] = TreeView.CreateSubValue(i,tbt_subtype,subValueChild[i], subClickCallback, subCreateCallback)
    end
    self.treeView:setValues(rootValue,subValues,true)
    self.sp_see:AddNormalChild(self.treeView.view)
    self.treeView:setScrollPan(self.sp_see)
    if reportList and #reportList > 0 then
        self.treeView:selectNode(currDay,1,true)
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
  ActivityAPI.GetSevenGoalRequest(function(data)
  local infoData = GlobalHooks.DB.Find("SevTaskReward",{})
    updateTimeAndDesc(data.startTimestamp, data.endTimestamp)
    
    
    
    
    
    
    
    RefreshReportList(data,infoData)
  end)

end

local function OnExit()

end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/carnival/seventarget.gui.xml", GlobalHooks.UITAG.GameUIHotSeventarget)
  self.menu.Enable = false
  self.menu.mRoot.Enable = false
  InitUI()
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
