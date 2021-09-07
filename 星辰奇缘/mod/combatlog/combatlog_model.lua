-- 战斗录像
-- @author huangzefeng
-- @date 20160517
CombatLogModel = CombatLogModel or BaseClass(BaseModel)

function CombatLogModel:__init()
    self.win = nil
    self.currTab = nil
    self.Mgr = CombatManager.Instance
    self.currList = {}
    self.keepList = {}
    self.goodList = {}
    self.kuafuGoodList = {}
    self.hotList = {}
    self.firstKillList = {}
    self.recordList = {}
    self.zanData = nil
    --主界面分类页签数据
    self.barDataList = {
        [1] = {index = 5, name = TI18N("我的录像"),
                subList = {
                    [1] = {name = TI18N("最近挑战"), sub = 1},
                    [2] = {name = TI18N("我的收藏"), sub = 2},
                }
        },
        [2] = {index = 1, name = TI18N("热门录像"),
                subList = {
                    [1] = {name = TI18N("一周热门"), sub = 1},
                    [2] = {name = TI18N("历史热门"), sub = 2}
                }
        },
        [3] = {index = 2, name = TI18N("首杀集锦"),
                subList = {
                    [1] = {name = TI18N("BOSS首杀"), sub = 1}, --过滤
                    [2] = {name = TI18N("星座首杀"), sub = 14}, --过滤
                    [3] = {name = TI18N("爵位首杀"), sub = 3}, --过滤
                    [4] = {name = TI18N("天空首杀"), sub = 16}, --过滤
                    [5] = {name = TI18N("夺宝首杀"), sub = 15}, --过滤
                }
        },
        [4] = {index = 3, name = TI18N("怪物讨伐"),
                subList = {
                    {name = TI18N("世界BOSS"), sub = 1},
                    {name = TI18N("银月贤者"), sub = 10},
                    {name = TI18N("幻月灵兽"), sub = 11},
                    {name = TI18N("星座挑战"), sub = 2},
                    {name = TI18N("爵位挑战"), sub = 3},
                    {name = TI18N("玲珑宝阁"), sub = 9},
                    -- {name = TI18N("龙王资格"), sub = 7},
                    -- {name = TI18N("龙王试练"), sub = 8},
                    {name = TI18N("天空之塔"), sub = 4},
                    {name = TI18N("夺宝奇兵"), sub = 5},
                    {name = TI18N("英雄副本"), sub = 6},
                }
        },
        [5] = {index = 4, name = TI18N("玩家对决"),
                subList = {
                    [1] = {name = TI18N("武道会"), sub = 1},
                    -- [2] = {name = TI18N("冠军联赛"), sub = 2},
                    [2] = {name = TI18N("诸神之战"), sub = 2},
                    [3] = {name = TI18N("竞技场"), sub = 3},
                    [4] = {name = TI18N("段位赛"), sub = 4},
                    [5] = {name = TI18N("公会战"), sub = 5},
                    [6] = {name = TI18N("公会英雄战"), sub = 6},
                    [7] = {name = TI18N("荣耀战场"), sub = 8},
                    [8] = {name = TI18N("巅峰对决"), sub = 8},
                    [9] = {name = TI18N("英雄擂台"), sub = 9},
                    [10] = {name = TI18N("钻石联赛"), sub = 10},
                    [11] = {name = TI18N("峡谷之巅"), sub = 11},
                }
        },

    }
end

function CombatLogModel:GetBarDataList()
    local list = {}
    table.sort( self.recordList, function(a, b)
        return a.combat_tyeo < b.combat_tyeo
    end )
    for i = 1, #self.barDataList do
        local data = self.barDataList[i]
        if data.index == 2 then
            --首杀
            local firstKillData = {index = 2, name = TI18N("首杀集锦"),subList = {}}
            for j = 1, #self.recordList do
                local recordData = self.recordList[j]
                if recordData.combat_tyeo == 1 then
                    table.insert(firstKillData.subList, {name = TI18N("BOSS首杀"), sub = 1})
                elseif recordData.combat_tyeo == 14 then
                    table.insert(firstKillData.subList, {name = TI18N("星座首杀"), sub = 14})
                elseif recordData.combat_tyeo == 3 then
                    table.insert(firstKillData.subList, {name = TI18N("爵位首杀"), sub = 3})
                elseif recordData.combat_tyeo == 16 then
                    table.insert(firstKillData.subList, {name = TI18N("天空首杀"), sub = 16})
                elseif recordData.combat_tyeo == 15 then
                    table.insert(firstKillData.subList, {name = TI18N("夺宝首杀"), sub = 15})
                end
            end
            if #firstKillData.subList > 0 then
                table.insert(list, firstKillData)
            end
        else
            table.insert(list, data)
        end
    end
    return list
end

function CombatLogModel:OpenWindow(tab)
    if BaseUtils.IsVerify == true then
        return
    end
    if RoleManager.Instance.RoleData.lev < 40 then
        NoticeManager.Instance:FloatTipsByString(TI18N("录像系统将在40级开放，努力升级吧～"))
        return
    end
    if self.win == nil then
        -- self.win = CombatLogWindow.New(self)
        self.win = CombatVedioWindow.New(self)
    end

    self.currTab = tab
    self.win:Open(self.currTab)
end


function CombatLogModel:CloseWin()
    if self.win ~= nil then
        WindowManager.Instance:CloseWindow(self.win)
        -- self.win = nil
    end
end

function CombatLogModel:Update()
    -- body
end

function CombatLogModel:OpenViewPanel(args)
    if self.viewpanel == nil then
        self.viewpanel = CombatLogViewPanel.New(self)
        self.viewpanel:Show(args)
    end
end


function CombatLogModel:CloseViewPanel()
    if self.viewpanel ~= nil then
        self.viewpanel:DeleteMe()
        self.viewpanel = nil
    end
end

function CombatLogModel:OpenQuestionPanel(args)
    if self.questionPanel == nil then
        self.questionPanel = CombatQuestionPanel.New(self)
        self.questionPanel:Show(args)
    end
end

function CombatLogModel:CloseQuestionPanel()
    if self.questionPanel ~= nil then
        self.questionPanel:DeleteMe()
        self.questionPanel = nil
    end
end

function CombatLogModel:OpenCombatWatchVoteTips(args)
    if self.combatWatchVoteTips == nil then
        self.combatWatchVoteTips = CombatWatchVoteTips.New(self)
        self.combatWatchVoteTips:Show(args)
    end
end

function CombatLogModel:CloseCombatWatchVoteTips()
    if self.combatWatchVoteTips ~= nil then
        self.combatWatchVoteTips:DeleteMe()
        self.combatWatchVoteTips = nil
    end
end

function CombatLogModel:GettypeList(_combat_type)
    local temp = {}
    for i,v in ipairs(self.goodList) do
        if v.combat_type == _combat_type then
            table.insert( temp, v )
        end
    end
    local sortfunc = function(a, b)
        -- if a.replayed > b.replayed then
        --     return true
        -- elseif a.time > b.time then
        --     return true
        -- end
        -- return false
        return a.time > b.time
    end
    table.sort(temp, sortfunc)
    return temp
end

function CombatLogModel:IsKeep(id)
    for i,v in ipairs(self.keepList) do
        if id == v.rec_id then
            return true
        end
    end
    return false
end

--传入战斗类型，组织该类型的录像列表
function CombatLogModel:GetVedioListByCombatType(combatTypeDic)
    -- self.goodList
    local list = {}
    if self.goodList ~= nil then
        for i = 1, #self.goodList do
            local data = self.goodList[i]
            if combatTypeDic[data.combat_type] ~= nil then
                table.insert(list, BaseUtils.copytab(data))
            end
        end
    end
    return list
end