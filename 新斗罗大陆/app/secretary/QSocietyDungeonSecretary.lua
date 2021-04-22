-- 
-- Kumo.Wang
-- 小助手：宗門副本
-- 
local QBaseSecretary = import(".QBaseSecretary")
local QSocietyDungeonSecretary = class("QSocietyDungeonSecretary", QBaseSecretary)

local QUIViewController = import("..ui.QUIViewController")
local QSocietyDungeonArrangement = import("..arrangement.QSocietyDungeonArrangement")

function QSocietyDungeonSecretary:ctor(options)
	QSocietyDungeonSecretary.super.ctor(self, options)
end

function QSocietyDungeonSecretary:checkSecretaryIsNotActive()
    if remote.union:checkHaveUnion() == false then
        return true, "尚未加入宗门"
    end

    local needLevel = remote.union:getSocietyNeedLevel()
    if (remote.union.consortia and remote.union.consortia.level or 0) < needLevel then
        return true, "宗门等级"..needLevel.."级开启"
    end
    
    local isOpen, tipStr = remote.union:checkUnionDungeonIsOpen()
    if isOpen == false then
        return true, tipStr
    end
    return false
end

function QSocietyDungeonSecretary:convertSecretaryAwards(itemLog, logNum,info)
    QSocietyDungeonSecretary.super:convertSecretaryAwards(itemLog, logNum,info)
    local taskId = itemLog.taskType
    local secrataryConfig = remote.secretary:getSecretaryConfigById(taskId)

    local countTbl = string.split(itemLog.param, ";")

    if self._config.showResource ~= nil then
        info.token = 0
        info.money = tonumber(countTbl[2]) or 0      
    end
    return info
end

function QSocietyDungeonSecretary:_onTriggerSet()
    remote.union:unionGetBossListRequest(function()
            app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyDungeonSecretarySetting", 
                options = {setId = self._config.id, callback = handler(self, self.saveSecretarySetting)}}, {isPopCurrentDialog = false})
        end)
    
end

function QSocietyDungeonSecretary:saveSecretarySetting(id, tbl)
    local setting = tbl or {}
    local setId = id or self._config.id
    remote.secretary:updateSecretarySetting(setId, setting)
end

function QSocietyDungeonSecretary:executeSecretary()
    if remote.union:checkHaveUnion() == false then
        remote.secretary:nextTaskRunning()
    else
        local needLevel = remote.union:getSocietyNeedLevel()
        if (remote.union.consortia and remote.union.consortia.level or 0) < needLevel then
            remote.secretary:nextTaskRunning()
            return
        end

        if remote.union:checkUnionDungeonIsOpen() == false then
            remote.secretary:nextTaskRunning()
            return
        end

        -- 需要记录的数据
        self._buffList = {}
        self._chapter = remote.union:getShowChapter()
        self._index = 1
        self._isFirst = true
        if self._chapter <= 0 then
            remote.union:setShowChapter(remote.union:getFightChapter())
            self._chapter = remote.union:getFightChapter()
        end
        local scoietyChapterConfig = db:getScoietyChapter(self._chapter)
        for _, config in ipairs(scoietyChapterConfig) do
            if config and config.buff_des_id then
                local buffConfig = db:getScoietyDungeonBuff(config.buff_des_id)
                self._buffList[config.wave] = buffConfig.id
            end
        end

        local defaultCount = self._config.defaultCount or 9
        local config = app.unlock:getConfigByKey("UNLOCK_ZONGMENFUBEN_CD")
        if remote.user.dailyTeamLevel < config.team_level then
            defaultCount = 5
        end
        -- 首先一次性购买次数
        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
        local totalCount = curSetting.count or defaultCount

        local startTime = remote.union:getSocietyDungeonStartTime()
        local endTime = remote.union:getSocietyDungeonEndTime()
        local cd = remote.union:getSocietyCD()
        local freeCount = remote.union:getSocietyFreeCount()

        local userConsortia = remote.user:getPropForKey("userConsortia")
        local preBuyCount = 0 -- 当日已经购买过的次数
        if userConsortia.consortia_boss_buy_at ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > userConsortia.consortia_boss_buy_at then
            preBuyCount = 0
        else
            preBuyCount = userConsortia.consortia_boss_buy_count or 0
        end

        local fightFunc = function()
            local preFightCount = 0 -- 当日已经使用过的次数(要接后端数据)
            local userConsortia = remote.user:getPropForKey("userConsortia")
            if userConsortia.consortia_boss_fight_at ~= nil and q.refreshTime(remote.user.c_systemRefreshTime) > userConsortia.consortia_boss_fight_at then
                preFightCount = 0
            else
                preFightCount = userConsortia.consortia_boss_daily_fight_count or 0
            end
            local fightCount = totalCount - preFightCount
            if fightCount > 0 then
                remote.union:unionGetBossListRequest(function()
                    local chapter = remote.union:getShowChapter()
                    if chapter <= 0 then
                        remote.union:setShowChapter(remote.union:getFightChapter())
                        chapter = remote.union:getFightChapter()
                    end
                    if chapter ~= self._chapter then
                        self._chapter = chapter
                        self._index = 1
                        self._buffList = {}
                        local scoietyChapterConfig = db:getScoietyChapter(chapter)
                        for _, config in ipairs(scoietyChapterConfig) do
                            if config and config.buff_des_id then
                                local buffConfig = db:getScoietyDungeonBuff(config.buff_des_id)
                                self._buffList[config.wave] = buffConfig.id
                            end
                        end
                    end
                    local bossList = remote.union:getConsortiaBossList(chapter)
                    -- print("chapter, #bossList, self._index = ", chapter, #bossList, self._index)
                    if bossList and #bossList > 0 then 
                        local bossCount = #bossList
                        if remote.union:checkIsFinalWave(chapter, self._index) then
                            -- 因為最終boss永遠不會死（hp=1）而且不能設置集火順序，那麼按照先集火後順著wave打的原則，最終boss（wave=7）必然是最後且第7個攻打的，所以這裡的index就是wave
                            bossCount = bossCount + 1
                        end
                        -- QPrintTable(bossList)
                        if bossCount < self._index then
                            local newBossList = remote.union:getConsortiaBossList(chapter + 1)
                            -- print("#newBossList = ", #newBossList)
                            if newBossList and #newBossList > 0 then 
                                self._chapter = chapter + 1
                                remote.union:setShowChapter(self._chapter)
                                self._index = 1
                                self._buffList = {}
                                local scoietyChapterConfig = db:getScoietyChapter(chapter)
                                for _, config in ipairs(scoietyChapterConfig) do
                                    if config and config.buff_des_id then
                                        local buffConfig = db:getScoietyDungeonBuff(config.buff_des_id)
                                        self._buffList[config.wave] = buffConfig.id
                                    end
                                end
                                remote.secretary:doDelegate()
                                return
                            end
                        end
                        table.sort(bossList, function(a, b)
                                local aKey = remote.secretary:composeSettingKey(a.chapter, a.wave)
                                local bKey = remote.secretary:composeSettingKey(b.chapter, b.wave)
                                if curSetting[aKey] ~= FOUNDER_TIME and curSetting[bKey] == FOUNDER_TIME then
                                    return true
                                elseif curSetting[aKey] == FOUNDER_TIME and curSetting[bKey] ~= FOUNDER_TIME then
                                    return false
                                elseif curSetting[aKey] ~= FOUNDER_TIME and curSetting[bKey] ~= FOUNDER_TIME and curSetting[aKey] ~= curSetting[bKey] then
                                    return curSetting[aKey] < curSetting[bKey]
                                else
                                    return a.wave < b.wave
                                end
                            end)

                        if remote.union:checkIsFinalWave(chapter, self._index) then
                            -- 因為最終boss永遠不會死（hp=1）而且不能設置集火順序，那麼按照先集火後順著wave打的原則，最終boss（wave=7）必然是最後且第7個攻打的，所以這裡的index就是wave
                            local bossInfo = remote.union:getConsortiaFinalBossInfo()
                            table.insert(bossList, bossInfo)
                        end
                        -- QPrintTable(bossList)
                        local op = {}
                        op.activityBuffList = {}

                        for index, value in ipairs(bossList) do
                            if self._index == index then
                                op.bossHp = value.bossHp
                                if op.bossHp == 0 then
                                    -- print("[index + 1] : ", value.chapter, value.wave, value.bossHp)
                                    self._index = self._index + 1
                                    remote.secretary:doDelegate()
                                    return
                                end
                                op.chapter = value.chapter
                                op.wave = value.wave
                            end

                            if value.bossHp == 0 and self._buffList[value.wave] then
                                op.activityBuffList[value.wave] = self._buffList[value.wave]
                            end
                        end
                        -- print("当前扫荡： ", self._index, chapter, op.chapter, "-", op.wave)
                        local scoietyWaveConfig = db:getScoietyWave(op.wave, op.chapter)
                        local bossId = scoietyWaveConfig.boss
                        local bossLevel = scoietyWaveConfig.levels
                        local little_monster = scoietyWaveConfig.little_monster
                        -- local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SOCIETYDUNGEON_ATTACK_TEAM)
                        local societyDungeonArrangement = QSocietyDungeonArrangement.new({robotCount = fightCount, chapter = op.chapter, wave = op.wave, bossId = bossId, bossHp = op.bossHp, bossLevel = bossLevel, little_monster = little_monster, activityBuffList = op.activityBuffList})
                        local startBattle = function()
                                societyDungeonArrangement:startQuickBattle(function(data)
                                    if data.gfEndResponse and data.gfEndResponse.consortiaBossQuickFightResponse and data.gfEndResponse.consortiaBossQuickFightResponse.fightInfoList then
                                        local fightInfoList = data.gfEndResponse.consortiaBossQuickFightResponse.fightInfoList
                                        remote.union.unionActive:updateActiveTaskProgress(20002, #fightInfoList)
                                        remote.secretary:updateSecretaryLog(data, 1) 
                                        remote.secretary:doDelegate()
                                    end
                                end, function(data)
                                    remote.secretary:delDelegate()
                                    remote.secretary:nextTaskRunning()
                                    return
                                end, true)
                            end
                        -- if self._isFirst then
                        --     self._isFirst = false
                        --     local isTeamIsEmpty = societyDungeonArrangement:checkTeamIsEmpty(function()
                        --             startBattle()
                        --         end, function()
                        --             remote.secretary:delDelegate()
                        --             remote.secretary:nextTaskRunning()
                        --             return
                        --         end)
                        --     if not isTeamIsEmpty then
                        --         startBattle()
                        --     end
                        -- else
                        --     startBattle()
                        -- end
                        startBattle()
                    end
                end,function()
                    remote.secretary:nextTaskRunning()
                end)
            else
                remote.secretary:delDelegate()
                remote.union:unionBossGetAllWaveRewardRequest(true, function(data)
                        remote.secretary:updateSecretaryLog(data, 2) 
                        remote.secretary:nextTaskRunning()
                    end, function()
                        remote.secretary:nextTaskRunning()
                    end)
                return
            end
        end

        remote.secretary:makeDelegate(fightFunc)
        
        if self._isFirst then
            self._isFirst = false
            -- local teamVO = remote.teamManager:getTeamByKey(remote.teamManager.SOCIETYDUNGEON_ATTACK_TEAM)
            local societyDungeonArrangement = QSocietyDungeonArrangement.new({})
            local isTeamIsEmpty = societyDungeonArrangement:checkTeamIsEmpty(function()
                    local buyCount = totalCount - freeCount - preBuyCount
                    if buyCount > 0 then
                        remote.union:unionBuyFightCountRequest(buyCount, true, function(data)
                                remote.secretary:updateSecretaryLog(data, 3) 
                                remote.secretary:doDelegate()
                            end, function()
                                remote.secretary:delDelegate()
                                remote.secretary:nextTaskRunning()
                            end)
                    else
                        remote.secretary:doDelegate()
                    end
                end, function()
                    remote.secretary:delDelegate()
                    remote.secretary:nextTaskRunning()
                    return
                end)
            if not isTeamIsEmpty then
                local buyCount = totalCount - freeCount - preBuyCount
                if buyCount > 0 then
                    remote.union:unionBuyFightCountRequest(buyCount, true, function(data)
                            remote.secretary:updateSecretaryLog(data, 3) 
                            remote.secretary:doDelegate()
                        end, function()
                            remote.secretary:delDelegate()
                            remote.secretary:nextTaskRunning()
                        end)
                else
                    remote.secretary:doDelegate()
                    remote.secretary:nextTaskRunning()
                end
            end
        else
            local buyCount = totalCount - freeCount - preBuyCount
            if buyCount > 0 then
                remote.union:unionBuyFightCountRequest(buyCount, true, function(data)
                        remote.secretary:updateSecretaryLog(data, 3) 
                        remote.secretary:doDelegate()
                    end, function()
                        remote.secretary:delDelegate()
                        remote.secretary:nextTaskRunning()
                    end)
            else
                remote.secretary:doDelegate()
                remote.secretary:nextTaskRunning()
            end
        end
        
        -- local buyCount = totalCount - freeCount - preBuyCount
        -- if buyCount > 0 then
        --     remote.union:unionBuyFightCountRequest(buyCount, true, function(data)
        --             remote.secretary:updateSecretaryLog(data, 3) 
        --             remote.secretary:doDelegate()
        --         end, function()
        --             remote.secretary:delDelegate()
        --             remote.secretary:nextTaskRunning()
        --         end)
        -- else
        --     remote.secretary:doDelegate()
        -- end
    end 
end

function QSocietyDungeonSecretary:refreshWidgetData(widget, itemData, index)
    QSocietyDungeonSecretary.super.refreshWidgetData(self, widget, itemData, index)
    if widget then
        local curSetting = remote.secretary:getSettingBySecretaryId(self._config.id)
        local defaultCount = self._config.defaultCount or 9
        local config = app.unlock:getConfigByKey("UNLOCK_ZONGMENFUBEN_CD")
        if remote.user.dailyTeamLevel < config.team_level then
            defaultCount = 5
        end
        local count = curSetting.count or defaultCount
        widget:setDescStr("扫荡"..count.."次")
    end
end

return QSocietyDungeonSecretary
