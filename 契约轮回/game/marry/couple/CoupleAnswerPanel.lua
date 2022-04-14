-- @Author: lwj
-- @Date:   2019-08-26 20:00:31 
-- @Last Modified time: 2019-08-26 20:00:33

CoupleAnswerPanel = CoupleAnswerPanel or class("CoupleAnswerPanel", BasePanel)
local CoupleAnswerPanel = CoupleAnswerPanel

function CoupleAnswerPanel:ctor()
    self.abName = "marry"
    self.assetName = "CoupleAnswerPanel"
    self.layer = "UI"

    self.is_reveal = false
    self.use_background = true
    self.is_hide_other_panel = true
    self.model = CoupleModel.GetInstance()
end

function CoupleAnswerPanel:dctor()

end

function CoupleAnswerPanel:Open()
    CoupleAnswerPanel.super.Open(self)
end

function CoupleAnswerPanel:OpenCallBack()
end

function CoupleAnswerPanel:LoadCallBack()
    self.nodes = {
        "ans_con", "ans_con/CoupleAnswerItem", "cd",  "question",
    }
    self:GetChildren(self.nodes)
    self.item_obj = self.CoupleAnswerItem.gameObject
    self.cd = GetText(self.cd)
    self.question = GetText(self.question)

    self:AddEvent()
    self:InitPanel()
end

function CoupleAnswerPanel:AddEvent()
    local function callback()
        --self:StopMySchedule()
        --SetVisible(self.cd, false)ssss
        self.model.is_Answerring = false
    end
    self.choosed_answer_event_id = self.model:AddListener(MarryEvent.ChoosedAnswer, callback)
    self.close_self_event_id = GlobalEvent:AddListener(MarryEvent.CloseAnswerPanel, handler(self, self.Close))
end

function CoupleAnswerPanel:InitPanel()
    self:StartCD()
    self:InitQues()
end

function CoupleAnswerPanel:StartCD()
    self.cd_num = String2Table(Config.db_dunge_couple.answer_timeout.val)[1]
    self.model.is_Answerring = true
    self:StopMySchedule()
    self.schedule = GlobalSchedule.StartFun(handler(self, self.BeginningCD), 1, -1)
end

function CoupleAnswerPanel:BeginningCD()
    if self.cd_num > 1 then
        self.cd_num = self.cd_num - 1
        self.cd.text = string.format(ConfigLanguage.CoupleDungeon.AnswerCDFormat, self. cd_num)
    else
        self:StopMySchedule()
        if not self.model.is_choosed then
            self:SelectDefaultAnswer()
        end
        SetVisible(self.cd, false)
        self.model.is_Answerring = false
    end
end

function CoupleAnswerPanel:StopMySchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end

function CoupleAnswerPanel:InitQues()
    self.item_list = {}
    local cf = Config.db_dunge_couple_question[self.model.cur_ques_id]
    self.question.text = cf.content
    --配置答案字符串，实际配置表中的索引(用于提交回答)
    local answer_list = { { cf.answer_1, 1 }, { cf.answer_2, 2 } }
    -- 游戏开始会设置随机种子，这里不需要再设置
    -- math.randomseed(os.time())
    local num = math.random(2)
    if num == 2 then
        answer_list = { { cf.answer_2, 2 }, { cf.answer_1, 1 } }
    end

    for i = 1, 2 do
        local list = {}
        --A或B
        list.index = i
        list.answer = answer_list[i]
        local item = CoupleAnswerItem(self.item_obj, self.ans_con)
        item:SetData(list)
        self.item_list[#self.item_list + 1] = item
    end
end

function CoupleAnswerPanel:SelectDefaultAnswer()
    self.item_list[1]:SetDefault()
end

--揭晓答案
function CoupleAnswerPanel:RevealAllAnswer(list)
    if not list then
        logError("没有答案列表")
        return
    end
    self.over_data = list
    local result = list.stat
    local my_id = RoleInfoModel.GetInstance():GetMainRoleId()
    for i, cf_answer_idx in pairs(result) do
        if i ~= my_id then
            self.model:Brocast(MarryEvent.ShowAnotherOneAnswer, cf_answer_idx)
            break
        end
    end
    self:StartShowCD()
end

---开始展示倒计时
function CoupleAnswerPanel:StartShowCD()
    self.is_reveal = true
    self:StopMySchedule()
    self.cd_num = 3
    self.schedule = GlobalSchedule.StartFun(handler(self, self.CountShowTime), 1, -1)
end
function CoupleAnswerPanel:CountShowTime()
    if self.cd_num > 1 then
        SetVisible(self.cd, true)
        self.cd_num = self.cd_num - 1
        self.cd.text = string.format(ConfigLanguage.CoupleDungeon.FewSecLaterClose, self.cd_num)
    else
        self:StopMySchedule()
        SetVisible(self.cd, false)
        self:Close()
        self.model.is_choosed = false
        lua_panelMgr:GetPanelOrCreate(CPDungeEndPanel):Open(self.over_data)
    end
end

function CoupleAnswerPanel:CloseCallBack()
    if self.close_self_event_id then
        GlobalEvent:RemoveListener(self.close_self_event_id)
        self.close_self_event_id = nil
    end
    if self.choosed_answer_event_id then
        self.model:RemoveListener(self.choosed_answer_event_id)
        self.choosed_answer_event_id = nil
    end
    self:StopMySchedule()
    if not table.isempty(self.item_list) then
        for i, v in pairs(self.item_list) do
            if v then
                v:destroy()
            end
        end
        self.item_list = {}
    end
end