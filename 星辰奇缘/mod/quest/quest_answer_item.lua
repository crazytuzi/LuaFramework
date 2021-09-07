-- -------------------------
-- 任务答题题目结构
-- hosr
-- -------------------------

QuestAnswerItem = QuestAnswerItem or BaseClass()

function QuestAnswerItem:__init()
    self.sid = 0 -- 题目序号
    self.qid = 0 -- 题目id
    self.status = 0 -- 作答状态， 1：等待对方作答， 2：对方已作答
    self.option = 0 -- 作答选项
    self.start_time = 0 -- 题目开始时间
    self.result = 0 -- 答题结果， 0：不一致的答案， 1：一致的答案
    self.msg = ""
end

function QuestAnswerItem:Update(dat)
    for k,v in pairs(dat) do
        self[k] = v
    end
end
