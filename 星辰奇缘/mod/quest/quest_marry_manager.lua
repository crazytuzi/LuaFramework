-- -------------------------------
-- 答题任务其他处理相关管理
-- 别看文件名，这里集成了答题任务的统一处理
-- 伴侣，情缘，师徒
-- hosr
-- -------------------------------
QuestionEumn = QuestionEumn or {}

QuestionEumn.Type = {
    Couple = 0, -- 伴侣
    Ambiguous = 1, -- 情缘
    Teacher = 2, -- 师徒
}

QuestMarryManager = QuestMarryManager or BaseClass(BaseManager)

function QuestMarryManager:__init()
    if QuestMarryManager.Instance then
        return
    end
    QuestMarryManager.Instance = self

    self.answerPanel = nil
    self.answerAward = nil
    self.questItem = nil

    self:InitHandler()

    self.effectPath = "prefabs/effect/20126.unity3d"
    self.effect = nil

    self.finish = false
    self.awardData = nil
end

function QuestMarryManager:InitHandler()
    -- 伴侣
    self:AddNetHandler(15400, self.On15400)
    self:AddNetHandler(15401, self.On15401)
    self:AddNetHandler(15402, self.On15402)
    self:AddNetHandler(15403, self.On15403)

    -- 情缘
    self:AddNetHandler(15700, self.On15700)
    self:AddNetHandler(15701, self.On15701)
    self:AddNetHandler(15702, self.On15702)
    self:AddNetHandler(15703, self.On15703)

    -- 师徒
    self:AddNetHandler(16100, self.On16100)
    self:AddNetHandler(16101, self.On16101)
    self:AddNetHandler(16102, self.On16102)
    self:AddNetHandler(16103, self.On16103)
end

function QuestMarryManager:RequestInitData()
    self.finish = nil
    self:EffectTimeout()
    self.awardData = nil
    self.questItem = nil
    if self.answerPanel ~= nil then
        self.answerPanel:DeleteMe()
        self.answerPanel = nil
    end
    if self.answerAward ~= nil then
        self.answerAward:DeleteMe()
        self.answerAward = nil
    end
end

-- ---------------------------------------------------
-- 伴侣答题协议处理
-- ---------------------------------------------------
-- 心有灵犀题目数据
function QuestMarryManager:Send15400()
    self:Send(15400, {})
end

function QuestMarryManager:On15400(dat)
    self.finish = false

    if self.questItem == nil then
        self.questItem = QuestAnswerItem.New()
    end
    self.questItem:Update(dat)
    self:OpenPanel()
end

-- 心有灵犀作答
function QuestMarryManager:Send15401(sid, option)
    self:Send(15401, {sid = sid, option = option})
end

function QuestMarryManager:On15401(dat)
    -- if self.questItem == nil then
    --     self.questItem = QuestAnswerItem.New()
    -- end
    -- self.questItem:Update(dat)
    if self.answerPanel ~= nil and not BaseUtils.isnull(self.answerPanel.gameObject) then
        self.answerPanel:UpdateStatus(dat.status)
    end
end

-- 心有灵犀作答结果
function QuestMarryManager:Send15402()
end

function QuestMarryManager:On15402(dat)
    if self.questItem == nil then
        self.questItem = QuestAnswerItem.New()
    end
    -- self.questItem:Update(dat)
    self.questItem.status = dat.status

    if dat.result == 1 then
        self:PlayEffect()
    end

    if self.answerPanel ~= nil and self.answerPanel.gameObject ~= nil then
        self.answerPanel:ShowOption(dat)
    end
end

-- 心有灵犀统计数据
function QuestMarryManager:Send15403()
    self:Send(15403, {})
end

function QuestMarryManager:On15403(dat)
    self.awardData = dat
    if self.finish then
        -- 打开统计结算界面
        self:OpenAward(QuestionEumn.Type.Couple)
    end
end

-- ---------------------------------------------------
-- 情缘答题协议处理
-- ---------------------------------------------------
-- 心有灵犀题目数据
function QuestMarryManager:Send15700()
    self:Send(15700, {})
end

function QuestMarryManager:On15700(dat)
    self.finish = false
    if dat.qid == 0 then
        Log.Debug(string.format("题目不存在qid=", dat.qid))
        return
    end

    if self.questItem == nil then
        self.questItem = QuestAnswerItem.New()
    end
    self.questItem:Update(dat)
    self:OpenPanelAmbiguous()
end

-- 心有灵犀作答
function QuestMarryManager:Send15701(sid, option)
    self:Send(15701, {sid = sid, option = option})
end

function QuestMarryManager:On15701(dat)
    -- if self.questItem == nil then
    --     self.questItem = QuestAnswerItem.New()
    -- end
    -- self.questItem:Update(dat)
    if self.answerPanel ~= nil and not BaseUtils.isnull(self.answerPanel.gameObject) then
        self.answerPanel:UpdateStatus(dat.status)
    end
end

-- 心有灵犀作答结果
function QuestMarryManager:Send15702()
end

function QuestMarryManager:On15702(dat)
    if self.questItem == nil then
        self.questItem = QuestAnswerItem.New()
    end
    -- self.questItem:Update(dat)
    self.questItem.status = dat.status

    if dat.result == 1 then
        self:PlayEffect()
    end

    if self.answerPanel ~= nil and not BaseUtils.isnull(self.answerPanel.gameObject) then
        self.answerPanel:ShowOption(dat)
    end
end

-- 心有灵犀统计数据
function QuestMarryManager:Send15703()
    self:Send(15703, {})
end

function QuestMarryManager:On15703(dat)
    self.awardData = dat
    if self.finish then
        -- 打开统计结算界面
        self:OpenAward(QuestionEumn.Type.Ambiguous)
    end
end

-- ---------------------------------------------------
-- 师徒答题协议处理
-- ---------------------------------------------------
-- 心有灵犀题目数据
function QuestMarryManager:Send16100(questId)
    self:Send(16100, {ask_id = questId, platform = QuestManager.Instance.teacher_question_platform, zone_id =QuestManager.Instance.teacher_question_zoneId})
end

function QuestMarryManager:On16100(dat)
    self.finish = false
    if dat.qid == 0 then
        Log.Debug(string.format("题目不存在qid=", dat.qid))
        return
    end

    if self.questItem == nil then
        self.questItem = QuestAnswerItem.New()
    end
    self.questItem:Update(dat)
    self:OpenPanelTeacher()
end

-- 心有灵犀作答
function QuestMarryManager:Send16101(questId, sid, option)
    self:Send(16101, {ask_id = questId, sid = sid, option = option, platform = QuestManager.Instance.teacher_question_platform, zone_id =QuestManager.Instance.teacher_question_zoneId})
end

function QuestMarryManager:On16101(dat)
    -- if self.questItem == nil then
    --     self.questItem = QuestAnswerItem.New()
    -- end
    -- self.questItem:Update(dat)
    if self.answerPanel ~= nil and not self.answerPanel.hasDestory then
        self.answerPanel:UpdateStatus(dat.status)
    end
end

-- 心有灵犀作答结果
function QuestMarryManager:Send16102()
end

function QuestMarryManager:On16102(dat)
    if self.questItem == nil then
        self.questItem = QuestAnswerItem.New()
    end
    -- self.questItem:Update(dat)
    self.questItem.status = dat.status

    if dat.result == 1 then
        self:PlayEffect()
    end

    if self.answerPanel ~= nil and self.answerPanel.gameObject ~= nil then
        self.answerPanel:ShowOption(dat)
    end
end

-- 心有灵犀统计数据
function QuestMarryManager:Send16103(questId)
    self:Send(16103, {ask_id = questId, platform = QuestManager.Instance.teacher_question_platform, zone_id =QuestManager.Instance.teacher_question_zoneId})
end

function QuestMarryManager:On16103(dat)
    self.awardData = dat
    if self.finish then
        -- 打开统计结算界面
        self:OpenAward(QuestionEumn.Type.Teacher)
    end
end


-- --------------------------------------------
-- 答题界面处理
-- --------------------------------------------
function QuestMarryManager:OpenPanel()
    if self.answerAward ~= nil then
        self.answerAward:DeleteMe()
        self.answerAward = nil
    end

    if self.answerPanel == nil then
        self.answerPanel = QuestAnswerPanel.New()
    end
    self.answerPanel:Show(self.questItem)
end

function QuestMarryManager:OpenPanelAmbiguous()
    if self.answerAward ~= nil then
        self.answerAward:DeleteMe()
        self.answerAward = nil
    end

    if self.answerPanel == nil then
        self.answerPanel = QuestAnswerAmbiguousPanel.New()
    end
    self.answerPanel:Show(self.questItem)
end

function QuestMarryManager:OpenPanelTeacher()
    if self.answerAward ~= nil then
        self.answerAward:DeleteMe()
        self.answerAward = nil
    end

    if self.answerPanel == nil then
        self.answerPanel = QuestAnswerTeacherPanel.New()
    end
    self.answerPanel:Show(self.questItem)
end

function QuestMarryManager:ClosePanel()
    if self.answerPanel ~= nil then
        self.answerPanel:DeleteMe()
        self.answerPanel = nil
    end
end

function QuestMarryManager:OpenAward(type)
    self:ClosePanel()
    if self.awardData ~= nil then
        self.finish = false
        if self.answerAward == nil then
            self.answerAward = QuestAnswerReward.New()
        end
        self.answerAward.type = type
        self.answerAward:Show(self.awardData)
    end
end

function QuestMarryManager:CloseAward(type)
    if self.answerAward ~= nil then
        self.answerAward:DeleteMe()
        self.answerAward = nil
    end

    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader then
        if type == QuestionEumn.Type.Ambiguous then
            QuestManager.Instance.model:DoAmbiguous()
        elseif type == QuestionEumn.Type.Couple then
            QuestManager.Instance.model:DoCouple()
        elseif type == QuestionEumn.Type.Teacher then
            QuestManager.Instance.model:DoTeacher()
        end
    end
end

function QuestMarryManager:PlayEffect()
    if self.effect == nil then
        --创建加载wrapper
        self.assetWrapper = AssetBatchWrapper.New()
        local func = function()
            if self.assetWrapper == nil then return end
            self.effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.effectPath))
            self.effect.name = "QuestionEffect"
            self.effect.transform:SetParent(NoticeManager.Instance.model.noticeCanvas.transform)
            self.effect.transform.localScale = Vector3.one * 100
            self.effect.transform.localPosition = Vector3.zero
            Utils.ChangeLayersRecursively(self.effect.transform, "UI")

            self.effect:SetActive(false)
            self.effect:SetActive(true)

            self.assetWrapper:ClearMainAsset()

            if self.effectId ~= nil then
                LuaTimer.Delete(self.effectId)
                self.effectId = nil
            end
            self.effectId = LuaTimer.Add(60000, function() self:EffectTimeout() end)
        end
        self.assetWrapper:LoadAssetBundle({{file = self.effectPath, type = AssetType.Main}}, func)
    else
        if self.effectId ~= nil then
            LuaTimer.Delete(self.effectId)
             self.effectId = nil
        end
        self.effectId = LuaTimer.Add(60000, function() self:EffectTimeout() end)
        self.effect:SetActive(false)
        self.effect:SetActive(true)
    end
end

function QuestMarryManager:EffectTimeout()
    if self.effectId ~= nil then
        LuaTimer.Delete(self.effectId)
        self.effectId = nil
    end

    if not BaseUtils.is_null(self.effect) then
        GameObject.DestroyImmediate(self.effect)
        self.effect = nil
    end
end
