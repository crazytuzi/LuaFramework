-- 系统消息
MsgAction = MsgAction or BaseClass(CombatBaseAction)

function MsgAction:__init(brocastCtx, actionData)
    self.actionData = actionData
    self.brocastCtx = brocastCtx
    self.msgdata = {
        type = 3,
        msg = actionData.action_msg,
        limit = {}
    }
end

function MsgAction:Play()
    if self.actionData.target_id == self.brocastCtx.controller.selfData.id then
        NoticeManager.Instance.dispatcher:Dispatch(self.msgdata)
    end
    self:OnActionEnd()
end

function MsgAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
