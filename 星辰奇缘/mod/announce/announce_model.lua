AnnounceModel = AnnounceModel or BaseClass(BaseModel)

function AnnounceModel:__init()

end

-- 把公告转换到邮件结构
function AnnounceModel:AnnounceToMail(announce)
    local mail = {}
    mail["sess_id"] = announce.id
    mail["platform"] = "0"
    mail["zone_id"] = 0
    mail["type"] = 3        -- 代表公告
    mail["del_type"] = 2
    mail["title"] = self:TransferString(announce.title)
    mail["content"] = self:TransferString(announce.msg)
    mail["from_name"] = TI18N("系统")
    mail["item_list"] = {}
    mail["rev_ts"] = announce.end_time
    mail["ts"] = announce.start_time
    mail["status"] = 0
    for k,v in pairs(announce.gain) do
        table.insert(mail.item_list,
            {base_id = v.gain_id, quantity = v.value}
        )
    end
    return mail
end

function AnnounceModel:TransferString(str)
    local res = string.gsub(str, "&lt;", "<")
    res = string.gsub(res, "&gt;", ">")
    res = string.gsub(res, "&amp;", "&")
    res = string.gsub(res, "<br>", "\n")
    res = string.gsub(res, "&quot;", "\"")
    res = string.gsub(res, "&#039;", "\'")
    return res
end