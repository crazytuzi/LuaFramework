local OctetsStream = require("netio.OctetsStream")
local MailConsts = class("MailConsts")
MailConsts.MAIL_DATA_STATE_NOT_READ = 0
MailConsts.MAIL_DATA_STATE_READED = 1
MailConsts.MAIL_DATA_NO_THING = 0
MailConsts.MAIL_DATA_HAS_THING = 1
function MailConsts:ctor()
end
function MailConsts:marshal(os)
end
function MailConsts:unmarshal(os)
end
return MailConsts
