-- @Author: lwj
-- @Date:   2019-08-26 20:45:37 
-- @Last Modified time: 2019-08-26 20:45:39

CoupleAnswerItem = CoupleAnswerItem or class("CoupleAnswerItem", BaseCloneItem)
local CoupleAnswerItem = CoupleAnswerItem

function CoupleAnswerItem:ctor(parent_node, layer)
    CoupleAnswerItem.super.Load(self)
end

function CoupleAnswerItem:dctor()
    if self.update_after_submit_event_id then
        GlobalEvent:RemoveListener(self.update_after_submit_event_id)
        self.update_after_submit_event_id = nil
    end
    if self.update_another_answer_event_id then
        GlobalEvent:RemoveListener(self.update_another_answer_event_id)
        self.update_another_answer_event_id = nil
    end
end

function CoupleAnswerItem:LoadCallBack()
    self.model = CoupleModel.GetInstance()
    self.nodes = {
        "tick_1", "tick_2", "des", "Bg",
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)

    self:AddEvent()
end

function CoupleAnswerItem:AddEvent()
    local function callback()
        if self.model.is_choosed then
            return
        end
        self.model.is_choosed = true
        DungeonCtrl.GetInstance():RequestAnswerQuestion(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE, self.data.answer[2])
    end
    AddClickEvent(self.Bg.gameObject, callback)

    self.update_after_submit_event_id = GlobalEvent:AddListener(DungeonEvent.HandleSuccessSubmitAnswer, handler(self, self.HandleAnswerSubmit))

    local function callback(cf_idx)
        if self.data.answer[2] == cf_idx then
            local img = self.tick_1
            if RoleInfoModel.GetInstance():GetSex() == 1 then
                img = self.tick_2
            end
            SetVisible(img, true)
        end
    end
    self.update_another_answer_event_id = self.model:AddListener(MarryEvent.ShowAnotherOneAnswer, callback)
end

function CoupleAnswerItem:SetData(data)
    self.data = data
    self:UpdateView()
end

function CoupleAnswerItem:UpdateView()
    local head_str = "A、"
    if self.data.index == 2 then
        head_str = "B、"
    end
    self.des.text = head_str .. self.data.answer[1]
end

function CoupleAnswerItem:HandleAnswerSubmit(stype, answer)
    if stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE and self.data.answer[2] == answer then
        local gender = RoleInfoModel.GetInstance():GetSex()
        local img = self.tick_1
        if gender == 2 then
            img = self.tick_2
        end
        SetVisible(img, true)
        self.model:Brocast(MarryEvent.ChoosedAnswer)
    end
end

function CoupleAnswerItem:SetDefault()
    self.model.is_choosed = true
    DungeonCtrl.GetInstance():RequestAnswerQuestion(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE, self.data.answer[2])
end