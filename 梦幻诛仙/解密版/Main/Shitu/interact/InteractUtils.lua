local Lplus = require("Lplus")
local GUIUtils = require("GUI.GUIUtils")
local ItemUtils = require("Main.Item.ItemUtils")
local ActivityInterface = require("Main.activity.ActivityInterface")
local activityInterface = ActivityInterface.Instance()
local InteractData = require("Main.Shitu.interact.data.InteractData")
local InteractUtils = Lplus.Class("InteractUtils")
local def = InteractUtils.define
def.static("table", "table", "=>", "table").ShowRoleInfo = function(uiObjs, roleInfo)
  local model
  if uiObjs and roleInfo then
    GUIUtils.SetActive(uiObjs.Group_Model, true)
    model = InteractUtils.FillModel(roleInfo.model, uiObjs.uiModel)
    GUIUtils.SetText(uiObjs.Label_Name, roleInfo.roleName)
    GUIUtils.SetSprite(uiObjs.Img_Sex, GUIUtils.GetSexIcon(roleInfo.gender))
    GUIUtils.SetText(uiObjs.Label_Level, string.format(textRes.Shitu.Interact.ROLE_LEVEL, roleInfo.roleLevel))
    GUIUtils.SetSprite(uiObjs.Img_Class, GUIUtils.GetOccupationSmallIcon(roleInfo.occupationId))
  end
  return model
end
def.static("table", "userdata", "=>", "table").FillModel = function(modelInfo, uiModel)
  local model
  if modelInfo and uiModel and not uiModel.isnil then
    model = require("Model.ECUIModel").new(modelInfo.modelid)
    _G.LoadModelWithCallBack(model, modelInfo, false, false, function()
      model:OnLoadGameObject()
      uiModel.modelGameObject = model.m_model
    end)
  else
    warn("[ERROR][InteractUtils:FillModel] modelInfo:", modelInfo)
    warn("[ERROR][InteractUtils:FillModel] uiModel:", uiModel)
  end
  return model
end
def.static("table", "table", "=>", "table").ShowActiveInfo = function(activeAwardInfo, uiObjs)
  if activeAwardInfo then
    if InteractUtils.IsPastDay(activeAwardInfo:GetApprenticeTime()) then
      GUIUtils.SetActive(uiObjs.Group_Slider, true)
      GUIUtils.SetActive(uiObjs.Label_NoReward, false)
      local InteractTaskPanel = require("Main.Shitu.interact.ui.InteractTaskPanel")
      return InteractUtils.DoShowActiveInfo(activeAwardInfo, uiObjs, InteractTaskPanel.MAX_ACTIVE_AWARD_COUNT)
    else
      GUIUtils.SetActive(uiObjs.Group_Slider, false)
      GUIUtils.SetActive(uiObjs.Label_NoReward, true)
      return nil
    end
  else
    GUIUtils.SetActive(uiObjs.Group_Slider, false)
    GUIUtils.SetActive(uiObjs.Label_NoReward, false)
    warn("[ERROR][InteractUtils:ShowActiveInfo] activeAwardInfo nil.")
    return nil
  end
end
def.static("table", "table", "number", "=>", "table").DoShowActiveInfo = function(activeAwardInfo, uiObjs, maxCount)
  if nil == activeAwardInfo then
    warn("[ERROR][InteractUtils:ShowActiveInfo] nil==activeAwardInfo.")
    return nil
  end
  local awardCfgs = InteractData.Instance():GetActiveLevelAwardCfg(activeAwardInfo:GetAwardType(), _G.GetHeroProp().level)
  if nil == awardCfgs or #awardCfgs <= 0 then
    warn("[ERROR][InteractUtils:ShowActiveInfo] nil==awardCfgs or #awardCfgs<=0.")
    return nil
  end
  if nil == uiObjs then
    warn("[ERROR][InteractUtils:ShowActiveInfo] nil==uiObjs.")
    return nil
  end
  local awardList = uiObjs.ActiveAwards
  local maxActive = 0
  for i = 1, maxCount do
    local listItem = awardList[i]
    if listItem then
      local Texture_item = listItem.awardItem:FindDirect(string.format("Texture_item_%d", i))
      local Label_Count = listItem.awardItem:FindDirect("Label_Count")
      local Img_Finished = listItem.awardItem:FindDirect("Img_Finished")
      local Text_item = listItem.activeValue
      GUIUtils.SetLightEffect(listItem.awardItem, GUIUtils.Light.None)
      local awardCfg = awardCfgs[i]
      if awardCfg then
        Texture_item:SetActive(true)
        Text_item:SetActive(true)
        Label_Count:SetActive(true)
        local uiTexture = Texture_item:GetComponent("UITexture")
        local itembase = ItemUtils.GetItemBase(awardCfg.award_item_id)
        GUIUtils.FillIcon(uiTexture, itembase.icon)
        GUIUtils.SetText(Label_Count, tostring(awardCfg.award_item_count))
        GUIUtils.SetText(Text_item, string.format(textRes.activity[285], awardCfg.activite_value))
        if activeAwardInfo:GetCurActive() >= awardCfg.activite_value then
          local bFetched = activeAwardInfo:IsAwardFetched(awardCfg.award_index)
          if bFetched == false then
            GUIUtils.SetLightEffect(listItem.awardItem, GUIUtils.Light.Square)
          end
          Img_Finished:SetActive(bFetched)
        else
          Img_Finished:SetActive(false)
        end
        if maxActive < awardCfg.activite_value then
          maxActive = awardCfg.activite_value
        end
      else
        warn("[ERROR][InteractUtils:ShowActiveInfo] awardCfg nil at index:", i)
        Texture_item:SetActive(false)
        Text_item:SetActive(false)
        Img_Finished:SetActive(false)
        Label_Count:SetActive(false)
        GUIUtils.SetLightEffect(listItem.awardItem, GUIUtils.Light.None)
      end
    else
      listItem("[ERROR][InteractUtils:ShowActiveInfo] listItem nil at index:", i)
    end
  end
  local progress = 0
  if maxActive > 0 then
    progress = activeAwardInfo:GetCurActive() / maxActive
  end
  GUIUtils.SetProgress(uiObjs.ActiveProgress, GUIUtils.COTYPE.PROGRESS, math.min(1, progress))
  return awardCfgs
end
def.static("number", "=>", "boolean").IsPastDay = function(paramTime)
  local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
  local curTime = _G.GetServerTime()
  local paramTimeTable = AbsoluteTimer.GetServerTimeTable(paramTime)
  local curTimeTable = AbsoluteTimer.GetServerTimeTable(curTime)
  if paramTimeTable.year == curTimeTable.year and paramTimeTable.month == curTimeTable.month and paramTimeTable.day == curTimeTable.day then
    return false
  else
    return true
  end
end
def.static("table", "table", "boolean", "function").ShowTaskList = function(uiObjs, taskInfos, bAssigned, stateFunc)
  if taskInfos and #taskInfos > 0 then
    local taskCount = #taskInfos
    local InteractTaskPanel = require("Main.Shitu.interact.ui.InteractTaskPanel")
    taskCount = math.min(taskCount, InteractTaskPanel.MAX_TASK_COUNT)
    uiObjs.uiListTask.itemCount = taskCount
    uiObjs.uiListTask:Resize()
    uiObjs.uiListTask:Reposition()
    for i = 1, taskCount do
      InteractUtils.FillTask(i, uiObjs.uiListTask.children[i], taskInfos[i], bAssigned, stateFunc)
    end
  else
    GUIUtils.SetActive(uiObjs.NoneTask, true)
    GUIUtils.SetActive(uiObjs.HaveTask, false)
    GUIUtils.SetText(uiObjs.Label_NoneTask, textRes.Shitu.Interact.TASK_FETCH_FAIL_NONE)
  end
end
def.static("number", "userdata", "table", "boolean", "function").FillTask = function(idx, listItem, taskInfo, bAssigned, stateFunc)
  if nil == taskInfo then
    warn("[ERROR][InteractUtils:FillTask] taskInfo nil for idx:", idx)
    return
  end
  local TaskInterface = require("Main.task.TaskInterface")
  local taskCfg = TaskInterface.GetTaskCfg(taskInfo.taskId)
  if nil == taskCfg then
    warn("[ERROR][InteractUtils:FillTask] taskCfg nil for taskid:", taskInfo.taskId)
    return
  end
  if nil == listItem then
    warn("[ERROR][InteractUtils:FillTask] listItem nil at index:", idx)
    return
  end
  local Label_Name = listItem:FindDirect("Label_Name")
  GUIUtils.SetText(Label_Name, taskCfg.taskName)
  local List_Star = listItem:FindDirect("StarLevel/List")
  local uiListStar = List_Star:GetComponent("UIList")
  uiListStar.itemCount = InteractData.Instance():GetTaskStar(taskInfo.taskId)
  local Btn_Group = listItem:FindDirect("Btn_Group")
  if stateFunc then
    stateFunc(taskInfo.taskState, Btn_Group, bAssigned)
  end
end
InteractUtils.Commit()
return InteractUtils
