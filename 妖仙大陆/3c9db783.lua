local _M = {}

local newAchievementIds = {}
local curChapterAchievement = nil
function _M.popNewAchievementId()
  return table.remove(newAchievementIds, 1)
end

function _M.requestChapterInfos(cb)
	Pomelo.AchievementHandler.achievementGetTypesRequest(function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      cb(data.s2c_achievementTypes, data.s2c_totalScore, data.s2c_leader, data.s2c_rewardCount)
    end
  end)
end

function _M.getAchievementList(chapterId,cb)
  local staitcVo = GlobalHooks.DB.Find("achievement", {ChapterID = chapterId})
  return staitcVo
end


function _M.sortAchievementListData(cb)
    if curChapterAchievement ~= nil and curChapterAchievement.s2c_achievements ~= nil then
      table.sort(curChapterAchievement.s2c_achievements, function (aa,bb)
          if  aa.status == 1 and bb.status == 2 or
              aa.status == 0 and bb.status == 2 or
              aa.status == 1 and bb.status == 0 then
              return true
          end
          return false
      end)
    end
    if cb then
      cb(curChapterAchievement)
    end
end

function _M.getAchievementListData()
  return curChapterAchievement
end

function _M.requestOpenChapter(cb)
  Pomelo.AchievementHandler.achievementGetTypeElementRequest(10,function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      cb(data.s2c_opened_chapter)
    end
  end)
end

function _M.requestAchievements(chapterId,cb)
  Pomelo.AchievementHandler.achievementGetTypeElementRequest(chapterId,function (ex,sjson)
    if not ex then
      local data = sjson:ToData()
      
      curChapterAchievement = data
      _M.sortAchievementListData(cb)
    end
  end)
end

function _M.requestReward(rewardId, type, cb)
  Pomelo.AchievementHandler.achievementGetAwardRequest(rewardId,type,function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb()
    end
  end)
end


function _M.GetHolyArmorsRequest(cb)
  Pomelo.AchievementHandler.getHolyArmorsRequest(function (ex,sjson)
    if not ex then
      local msg = sjson:ToData()
      cb(msg.holyArmors or {})
    end
  end)
end


function _M.ActivateHolyArmorRequest(id, cb)
  Pomelo.AchievementHandler.activateHolyArmorRequest(id,function (ex,sjson)
    if not ex then
      
      cb()
    end
  end)
end

local function OnAchievementPush(ex, sjson)
  if ex then return end

  local data = sjson:ToData()
  
  for _, v in ipairs(data.s2c_achievements or {}) do
    local staitcVo = GlobalHooks.DB.Find("achievement", v.id)
    if v.scheduleCurr >= staitcVo.TargetNum then
      table.insert(newAchievementIds, v.id)
    end
  end
  if #newAchievementIds > 0 then
    EventManager.Fire("Event.Achievement.NewAchievement", {})
  end
end

function _M.fin(relogin)
  if relogin then
    newAchievementIds = {}
  end
end

function _M.InitNetWork()
  Pomelo.AchievementHandler.onAchievementPush(OnAchievementPush)
end

return _M
