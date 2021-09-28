local Util = require "Zeus.Logic.Util"
local Item = require "Zeus.Model.Item"
local AchievementUtil = {}

function AchievementUtil.getChapters()
    local list = GlobalHooks.DB.Find("achievement_config", {})
    table.sort(list, function(a, b) return a.TypeId < b.TypeId end)

    return list
end

function AchievementUtil.getAchievements(chapterId)
    local list = GlobalHooks.DB.Find("achievement", {ChapterID = chapterId})
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

function AchievementUtil.mergeAchievementsSD(statics, dynamics)
    table.sort(dynamics, function(a, b) return a.id < b.id end)
    local isAllFinish = true
    local currScore, maxScore = 0, 0
    for i,v in ipairs(statics) do
        local dv = dynamics[i]
        assert(dv.id == v.id, "can not mergeAchievementsSD, achievement not match")
        
        
        
        maxScore = maxScore + v.point
        
        v.scheduleCurr = dv.scheduleCurr
        v.isFinish = true
        if dv.scheduleCurr < v.TargetNum then
            isAllFinish = false
            v.isFinish = false
        end
        
        
        
        
        
        
        
        if v.isFinish then
            currScore = currScore + v.point
        end
    end
    return isAllFinish, currScore, maxScore
end

local function genRewardItems(data)
    local items = {}
    for i = 1, 5 do
        local code = data['awardKey' .. i]
        if not string.empty(code) then
            local item = GlobalHooks.DB.Find("Items", code)
            table.insert(items, {
                code = code,
                groupCount = data['awardValue' .. i],
                icon= item.Icon,
                qColor = item.Qcolor,
                name=item.Name
            })
        end
    end
    return items
end


function AchievementUtil.getOverviewRewards(chapterId)
    local proName = DataMgr.Instance.UserData:GetPro()

    
    local datas = GlobalHooks.DB.Find("achievement_award", function(t)
        return t.TypeId == chapterId and t.pro == proName
    end)
    table.sort(datas, function(a, b) return a.id < b.id end)

    for _,v in ipairs(datas) do
        v.items = genRewardItems(v)
        v.gotTimes = 0
    end
    return datas
end


function AchievementUtil.getChapterReward(chapterId)
    local proName = DataMgr.Instance.UserData:GetPro()

    
    local datas = GlobalHooks.DB.Find("achievement_award", function(t)
        return t.TypeId == chapterId and (t.pro == proName or t.pro == 'ALL')
    end)

    if #datas > 1 then
        for i,v in ipairs(datas) do
            if v.pro == 'ALL' then
                table.remove(datas, i)
                break
            end
        end
    end
    datas[1].items = genRewardItems(datas[1])
    return datas[1]
end


function AchievementUtil.getGold()
    return DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.GOLD, 0)
end

function AchievementUtil.getLv()
    return DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.LEVEL, 0)
end

function AchievementUtil.getUpLv()
    return DataMgr.Instance.UserData:TryToGetIntAttribute(UserData.NotiFyStatus.UPLEVEL, 0)
end

function AchievementUtil.getRankDesc(rank)
    local list = GlobalHooks.DB.Find("achievewords", {})
    table.sort(list, function (a, b) return a.achieverank > b.achieverank end)
    if rank == 0 then
        return Util.Format1234(list[1].description, rank)
    end
    for _,v in ipairs(list) do
        if v.achieverank <= rank then
            return Util.Format1234(v.description, rank)
        end
    end
    return ""
end


function AchievementUtil.fillItems(canvas, items, maxCount)
    for i=1, maxCount do
        local icon = canvas:FindChildByEditName("cvs_reward" .. i, true)
        if not icon then return end

        local item = items[i]
        icon.Visible = item ~= nil
        if item then
            local itemShow = Util.ShowItemShow(icon, item.icon, item.qColor, item.groupCount)
            AchievementUtil.addItemTouchTips(icon, item, itemShow)
        end
    end
end

function AchievementUtil.addItemTouchTips(canvas, item, itemShow)
    canvas.event_PointerDown = function (sender) 
        if itemShow then
            itemShow.IsSelected = true
        end
        Util.ShowItemDetailTips(itemShow,Item.GetItemDetailByCode(item.code))
    end
    canvas.event_PointerUp = function (sender)
        if itemShow then
            itemShow.IsSelected = false
        end
        GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUISimpleDetail)
    end
end

return AchievementUtil
