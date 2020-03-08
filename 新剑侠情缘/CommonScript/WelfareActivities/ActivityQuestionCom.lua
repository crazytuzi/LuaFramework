Require("CommonScript/WelfareActivities/DaTi.lua")

ActivityQuestion.GROUP               = 28;
ActivityQuestion.LAST_LOGIN_TIME     = 1;
ActivityQuestion.HAD_ANSWER_NUM      = 2;
ActivityQuestion.CURRENT_QUESTION_ID = 3;
ActivityQuestion.CORRECT_NUM         = 4;
ActivityQuestion.GROUP_BEGIN_IDX     = 5;
ActivityQuestion.DEGREE_NUM          = 15;
ActivityQuestion.DEGREE_TIME         = 16;
ActivityQuestion.RECEIVE_TASK        = 17;  --是否接受答题任务
ActivityQuestion.SUBMIT_TASK         = 18;  --是否提交了答题任务
ActivityQuestion.LOGIN_LEVEL         = 21;  --登录等级

ActivityQuestion.TASK_ANSWERID_NUM   = 19;  --任务答题
ActivityQuestion.TASK_CORRECT_NUM    = 20;  --任务答题，正确的数量

ActivityQuestion.ANSWER_NUM_MAX = 10;
ActivityQuestion.tbMaxAward     = {"Item", 787, 2}
ActivityQuestion.tbRightAward   = {"BasicExp", 7}
ActivityQuestion.tbWrongAward   = {"BasicExp", 5}
ActivityQuestion.MIN_LEVEL      = 10 --开放等级（该等级开始可以接）
ActivityQuestion.MAX_LEVEL      = 39 --关闭等级（该等级还能接）

ActivityQuestion.TASK_ID        = -10001;  --任务ID，主要提供给任务追踪使用

function ActivityQuestion:IsAnswerNumMax()
    local nHadAnswer = me.GetUserValue(self.GROUP, self.HAD_ANSWER_NUM);
    return nHadAnswer >= self.ANSWER_NUM_MAX;
end

function ActivityQuestion:CheckSubmitTask()
    local bReceived  = me.GetUserValue(self.GROUP, self.RECEIVE_TASK) == 1
    local bSubmited  = me.GetUserValue(self.GROUP, self.SUBMIT_TASK) == 1
    local bAnswerMax = self:IsAnswerNumMax()
    local szMsg = "未答完全部题目"
    if not bReceived then
        szMsg = "未接受答题任务"
    elseif bSubmited then
        szMsg = "已提交"
    end
    return bReceived and bAnswerMax and not bSubmited, szMsg
end

function ActivityQuestion:LoadSetting()
    self.tbNpcQuestions = {}
    self.tbNpcList      = {}
    for nId, tbInfo in pairs(DaTi.tbAllQuestion["Activity"]) do
        local nNpcTemId = tbInfo.nNpcTemplateId
        self.tbNpcQuestions[nNpcTemId] = self.tbNpcQuestions[nNpcTemId] or {}
        table.insert(self.tbNpcQuestions[nNpcTemId], tbInfo.nId)
    end

    for nNpcTemId, _ in pairs(self.tbNpcQuestions) do
        table.insert(self.tbNpcList, nNpcTemId)
    end
end
ActivityQuestion:LoadSetting();

function ActivityQuestion:GetAnswer(nQuesId)
    local tbQues = DaTi:GetQuestionInfo("Activity", nQuesId or 1)
    return tbQues.nAnswerID
end

function ActivityQuestion:IsTaskDoing()
    local bReceived = me.GetUserValue(self.GROUP, self.RECEIVE_TASK) == 1
    local bSubmited = me.GetUserValue(self.GROUP, self.SUBMIT_TASK) == 1

    return bReceived and not bSubmited
end

function ActivityQuestion:GetCurQuestionInfo()
    local nQuesId = me.GetUserValue(self.GROUP, self.CURRENT_QUESTION_ID)
    local tbInfo  = DaTi:GetQuestionInfo("Activity", nQuesId)
    return tbInfo.nMapTemplateId, tbInfo.nNpcTemplateId
end

function ActivityQuestion:IsCurQuestionNpc(nMapTemplateId, nNpcTemplateId)
    if not self:IsTaskDoing() then
        return
    end

    local nCurMapTemId, nCurNpcTemId = self:GetCurQuestionInfo()
    return (nMapTemplateId == nCurMapTemId) and (nNpcTemplateId == nCurNpcTemId)
end

function ActivityQuestion:BeginAnswer(nMapTemplateId, nNpcTemplateId)
    if not self:IsTaskDoing() then
        return
    end

    local bCurNpc = self:IsCurQuestionNpc(nMapTemplateId, nNpcTemplateId)
    if not bCurNpc then
        return
    end

    if MODULE_GAMESERVER then
        local nQuesId = me.GetUserValue(self.GROUP, self.CURRENT_QUESTION_ID)
        DaTi:TryBeginQuestion(me, "Activity", nQuesId)
    end
end


---------------------------------任务答题---------------------------------
ActivityQuestion.tbTaskQuestion = ActivityQuestion.tbTaskQuestion or {}
local tbTaskQuestion   = ActivityQuestion.tbTaskQuestion
tbTaskQuestion.TASK_ID = { --活动对应的任务ID
   3055, 3505,     --天王
   3075, 3505,     --峨嵋
   3085, 3505,     --桃花
   3065, 3505,     --逍遥
   3095, 3505,     --武当
   3085, 3505,     --天忍
   3055, 3505,     --少林
   3075, 3505,     --翠烟
   3065, 3505,     --唐门
    3095, 3505,     --昆仑
    3085, 3505,     --丐帮
    3065, 3505,     --五毒
    3055, 3505,     --藏剑
    3095, 3505,     --长歌
    3075, 3505,     --天山
    3505,          --明教
    3505,          --段氏
    3505,          --万花
    3505,          --杨门
}

function tbTaskQuestion:GetQuestionNum()
    return #DaTi.tbAllQuestion["Task"]
end

function tbTaskQuestion:GetMyTaskState(pPlayer)
    local nState = Task.STATE_NONE;
    local nTaskId = 0;
    for _, nTaskId in pairs(tbTaskQuestion.TASK_ID) do
        nState = Task:GetTaskState(pPlayer, nTaskId);
        if nState ~= Task.STATE_NONE then
            nTaskId = nTaskId;
            break;
        end
    end
    return nState, nTaskId;
end

function tbTaskQuestion:CheckCanAnswer(nQuestionIdx)
    local nAnsNum = me.GetUserValue(ActivityQuestion.GROUP, ActivityQuestion.TASK_ANSWERID_NUM)
    local nQuestionNum = self:GetQuestionNum()
    if nAnsNum >= nQuestionNum then
        return
    end

    local nCurIdx = self:GetCurQuestionId()
    if nCurIdx ~= nQuestionIdx then
        return
    end

    return self:GetMyTaskState(me) == Task.STATE_ON_DING
end

function tbTaskQuestion:CheckCanFinish()
    local nState, nTaskId = self:GetMyTaskState(me);
    return nState == Task.STATE_CAN_FINISH, nTaskId;
end

function tbTaskQuestion:GetCurQuestionId()
    local nCurIdx = me.GetUserValue(ActivityQuestion.GROUP, ActivityQuestion.TASK_ANSWERID_NUM) + 1
    local nQuestionNum = self:GetQuestionNum()
    nCurIdx = math.min(nCurIdx, nQuestionNum)
    return nCurIdx
end

--------------------client begin--------------------
function ActivityQuestion:OnTrack()
    local bReceived = me.GetUserValue(self.GROUP, self.RECEIVE_TASK) == 1
    if not bReceived then
        RemoteServer.TryAcceptActQuesTask()
        return
    end

    local bMax = self:IsAnswerNumMax()
    local bSubmited = me.GetUserValue(self.GROUP, self.SUBMIT_TASK) == 1
    if bMax and bSubmited then
        return
    end

    local nMapTemplateId, nNpcTemplateId
    if bMax and not bSubmited then
        nMapTemplateId = 10
        nNpcTemplateId = 99
    else
        nMapTemplateId, nNpcTemplateId = self:GetCurQuestionInfo()
    end
    local nPosX, nPosY = AutoPath:GetNpcPos(nNpcTemplateId, nMapTemplateId)
    local fnCallback = function ()
        local nNpcId = AutoAI.GetNpcIdByTemplateId(nNpcTemplateId)
        if nNpcId then
            Operation.SimpleTap(nNpcId)
        end
    end
    AutoPath:GotoAndCall(nMapTemplateId, nPosX, nPosY, fnCallback, Npc.DIALOG_DISTANCE)
end

function ActivityQuestion:GetCurQuestionDesc()
    if self:IsAnswerNumMax() then
        return "答题", "找[FFFE0D]公孙惜花[-]交任务"
    end

    local nCurQuesId = me.GetUserValue(self.GROUP, self.CURRENT_QUESTION_ID) or 1
    local nHadAnswer = me.GetUserValue(self.GROUP, self.HAD_ANSWER_NUM)

    local _, nNpcTemplateId = self:GetCurQuestionInfo()
    local szName = KNpc.GetNameByTemplateId(nNpcTemplateId)
    local szDesc = string.format("找[FFFE0D]%s[-]了解江湖(%d/%d)", szName, math.min(self.ANSWER_NUM_MAX, nHadAnswer + 1), self.ANSWER_NUM_MAX)
    return "[常]答题", szDesc
end

function ActivityQuestion:IsActQuesTask(nTaskId)
    return self.TASK_ID == nTaskId
end

function ActivityQuestion:GetState()
    local nMax = DegreeCtrl:GetMaxDegree("ActivityQuestion", me)
    local nCur = DegreeCtrl:GetDegree(me, "ActivityQuestion")
    if self:IsTaskDoing() then
        --正在进行中不能显示0/1，要显示1/1（需求）
        return math.max(1, nCur), nMax, false
    end

    return nCur, nMax, nCur <= 0
end

function ActivityQuestion:OnDataUpdate()
    Task:OnTaskUpdate(ActivityQuestion.TASK_ID)
    UiNotify.OnNotify(UiNotify.emNOTIFY_ACTIVITY_QUESTION_UPDATE)
    -- if self:IsAnswerNumMax() then
    --     me.CenterMsg("今日答题完毕")
    -- end
end

function ActivityQuestion:OnAcceptSuccess()
    self:OnTrack()
    me.CenterMsg("开始进行本日答题")
    Task:OnTaskUpdate(ActivityQuestion.TASK_ID)
    UiNotify.OnNotify(UiNotify.emNOTIFY_ACTIVITY_QUESTION_UPDATE)
end
--------------------client end--------------------