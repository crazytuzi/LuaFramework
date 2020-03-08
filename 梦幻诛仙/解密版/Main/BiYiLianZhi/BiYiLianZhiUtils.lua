local Lplus = require("Lplus")
local BiYiLianZhiUtils = Lplus.Class("BiYiLianZhiUtils")
local def = BiYiLianZhiUtils.define
def.static("=>", "boolean").IsCanDoCoupleActivity = function()
  local teamData = require("Main.Team.TeamData").Instance()
  if teamData:HasTeam() ~= true or teamData:GetMemberCount() ~= 2 then
    return false
  end
  local mateInfo = require("Main.Marriage.MarriageInterface").GetMateInfo()
  if teamData:HasLeavingMember() or not teamData:IsTeamMember(mateInfo.mateId) then
    return false
  end
  return true
end
def.static("=>", "boolean").IsCoupleActivitySponsor = function()
  local teamData = require("Main.Team.TeamData").Instance()
  return teamData:MeIsCaptain()
end
def.static("table", "table", "=>", "table").CombineTaskStatus = function(taskList, finishList)
  local finishTaskMap = {}
  for i = 1, #finishList do
    finishTaskMap[finishList[i]] = true
  end
  local tasks = {}
  for i = 1, #taskList do
    local task = {}
    task.id = taskList[i]
    if finishTaskMap[taskList[i]] == true then
      task.status = true
    else
      task.status = false
    end
    table.insert(tasks, task)
  end
  return tasks
end
def.static("number", "=>", "table").GetTaskDataById = function(id)
  local taskRecord = DynamicData.GetRecord(CFG_PATH.DATA_COUPLE_DAILY_ACTIVITY_CFG, id)
  if taskRecord == nil then
    warn("\229\164\171\229\166\187\230\180\187\229\138\168\228\187\187\229\138\161\228\184\141\229\173\152\229\156\168:" .. id)
    return nil
  end
  local taskData = {}
  taskData.id = DynamicRecord.GetIntValue(taskRecord, "id")
  taskData.taskName = DynamicRecord.GetStringValue(taskRecord, "templatename")
  taskData.taskDesc = DynamicRecord.GetStringValue(taskRecord, "taskDes")
  return taskData
end
def.static("number", "=>", "table").GetFuqiQuestionById = function(id)
  local questionRecord = DynamicData.GetRecord(CFG_PATH.DATA_XINYOULINGXI_QUESTION_CFG, id)
  if questionRecord == nil then
    warn("\229\191\131\230\156\137\231\129\181\231\138\128\233\151\174\233\162\152id\228\184\141\229\173\152\229\156\168\239\188\154" .. id)
    return nil
  end
  local question = {}
  question.id = DynamicRecord.GetIntValue(questionRecord, "id")
  question.templatename = DynamicRecord.GetStringValue(questionRecord, "templatename")
  question.questionDesc = DynamicRecord.GetStringValue(questionRecord, "questionDesc")
  question.answerA = DynamicRecord.GetStringValue(questionRecord, "answerA")
  question.answerB = DynamicRecord.GetStringValue(questionRecord, "answerB")
  return question
end
def.static("userdata", "boolean").SetButtonEnabled = function(btn, enable)
  btn:GetComponent("UIButton"):set_enabled(enable)
  btn:GetComponent("UIButtonScale"):set_enabled(enable)
end
def.static("table", "table", "table", "table").RandomAnswerAndBtnName = function(btnShowLabels, btnAnswers, btnNames, answers)
  local swap = math.random(2) == 1
  if swap then
    btnNames[1], btnNames[2] = btnNames[2], btnNames[1]
    answers[1], answers[2] = answers[2], answers[1]
  end
  for i = 1, #btnAnswers do
    btnAnswers[i]:FindDirect("Label"):GetComponent("UILabel"):set_text(btnShowLabels[i] .. ":" .. answers[i])
    btnAnswers[i]:set_name(btnNames[i])
  end
end
return BiYiLianZhiUtils.Commit()
