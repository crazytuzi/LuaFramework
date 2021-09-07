-- ---------------------------
-- 处理超链接 {action_x} 的方法
-- ljh
-- ---------------------------
MessageAction = MessageAction or BaseClass()

function MessageAction.DoAction(action_id)
    if action_id == 1 then
        CrossArenaManager.Instance:Send20701()
    else

    end
end
