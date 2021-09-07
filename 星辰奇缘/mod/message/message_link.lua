-- ---------------------------
-- 消息连接处理脚本
-- hosr
-- ---------------------------
MsgLink = MsgLink or {}

MsgLink.Type = {
    None = 0, -- 无操作
}

MsgLink.Action = {
    [MsgLink.Type.None] = function(args) end
}
