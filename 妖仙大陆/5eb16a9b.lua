
local protobuf = require "protobuf"
local common_pb = require("common_pb")
local item_pb = require("item_pb")
module('mailHandler_pb')


MAILGETALLREQUEST = protobuf.Descriptor();
MAILREADNOTIFY = protobuf.Descriptor();
local MAILREADNOTIFY_C2S_ID_FIELD = protobuf.FieldDescriptor();
MAILSENDMAILREQUEST = protobuf.Descriptor();
local MAILSENDMAILREQUEST_TOPLAYERID_FIELD = protobuf.FieldDescriptor();
local MAILSENDMAILREQUEST_MAILTITLE_FIELD = protobuf.FieldDescriptor();
local MAILSENDMAILREQUEST_MAILTEXT_FIELD = protobuf.FieldDescriptor();
local MAILSENDMAILREQUEST_MAILREAD_FIELD = protobuf.FieldDescriptor();
local MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD = protobuf.FieldDescriptor();
MAILGETATTACHMENTREQUEST = protobuf.Descriptor();
local MAILGETATTACHMENTREQUEST_C2S_ID_FIELD = protobuf.FieldDescriptor();
MAILGETATTACHMENTONEKEYREQUEST = protobuf.Descriptor();
MAILDELETEREQUEST = protobuf.Descriptor();
local MAILDELETEREQUEST_C2S_ID_FIELD = protobuf.FieldDescriptor();
MAILDELETEONEKEYREQUEST = protobuf.Descriptor();
MAILSENDTESTNOTIFY = protobuf.Descriptor();
local MAILSENDTESTNOTIFY_C2S_MAILID_FIELD = protobuf.FieldDescriptor();
local MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD = protobuf.FieldDescriptor();
MAIL = protobuf.Descriptor();
local MAIL_ID_FIELD = protobuf.FieldDescriptor();
local MAIL_MAILID_FIELD = protobuf.FieldDescriptor();
local MAIL_MAILTYPE_FIELD = protobuf.FieldDescriptor();
local MAIL_MAILICON_FIELD = protobuf.FieldDescriptor();
local MAIL_MAILSENDER_FIELD = protobuf.FieldDescriptor();
local MAIL_MAILTITLE_FIELD = protobuf.FieldDescriptor();
local MAIL_MAILTEXT_FIELD = protobuf.FieldDescriptor();
local MAIL_CREATETIME_FIELD = protobuf.FieldDescriptor();
local MAIL_STATUS_FIELD = protobuf.FieldDescriptor();
local MAIL_MAILREAD_FIELD = protobuf.FieldDescriptor();
local MAIL_HADATTACH_FIELD = protobuf.FieldDescriptor();
local MAIL_ATTACHMENT_FIELD = protobuf.FieldDescriptor();
local MAIL_MAILSENDERID_FIELD = protobuf.FieldDescriptor();
local MAIL_ITEMEAR_FIELD = protobuf.FieldDescriptor();
local MAIL_NEWATTACHMENT_FIELD = protobuf.FieldDescriptor();
MAILGETALLRESPONSE = protobuf.Descriptor();
local MAILGETALLRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local MAILGETALLRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local MAILGETALLRESPONSE_MAILS_FIELD = protobuf.FieldDescriptor();
local MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD = protobuf.FieldDescriptor();
local MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD = protobuf.FieldDescriptor();
ONGETMAILPUSH = protobuf.Descriptor();
local ONGETMAILPUSH_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local ONGETMAILPUSH_MAILS_FIELD = protobuf.FieldDescriptor();
MAILSENDMAILRESPONSE = protobuf.Descriptor();
local MAILSENDMAILRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local MAILSENDMAILRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
MAILDELETERESPONSE = protobuf.Descriptor();
local MAILDELETERESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local MAILDELETERESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
MAILDELETEONEKEYRESPONSE = protobuf.Descriptor();
local MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD = protobuf.FieldDescriptor();
MAILGETATTACHMENTRESPONSE = protobuf.Descriptor();
local MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
MAILGETATTACHMENTONEKEYRESPONSE = protobuf.Descriptor();
local MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD = protobuf.FieldDescriptor();
local MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD = protobuf.FieldDescriptor();
local MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD = protobuf.FieldDescriptor();

MAILGETALLREQUEST.name = "MailGetAllRequest"
MAILGETALLREQUEST.full_name = ".pomelo.area.MailGetAllRequest"
MAILGETALLREQUEST.nested_types = {}
MAILGETALLREQUEST.enum_types = {}
MAILGETALLREQUEST.fields = {}
MAILGETALLREQUEST.is_extendable = false
MAILGETALLREQUEST.extensions = {}
MAILREADNOTIFY_C2S_ID_FIELD.name = "c2s_id"
MAILREADNOTIFY_C2S_ID_FIELD.full_name = ".pomelo.area.MailReadNotify.c2s_id"
MAILREADNOTIFY_C2S_ID_FIELD.number = 1
MAILREADNOTIFY_C2S_ID_FIELD.index = 0
MAILREADNOTIFY_C2S_ID_FIELD.label = 3
MAILREADNOTIFY_C2S_ID_FIELD.has_default_value = false
MAILREADNOTIFY_C2S_ID_FIELD.default_value = {}
MAILREADNOTIFY_C2S_ID_FIELD.type = 9
MAILREADNOTIFY_C2S_ID_FIELD.cpp_type = 9

MAILREADNOTIFY.name = "MailReadNotify"
MAILREADNOTIFY.full_name = ".pomelo.area.MailReadNotify"
MAILREADNOTIFY.nested_types = {}
MAILREADNOTIFY.enum_types = {}
MAILREADNOTIFY.fields = {MAILREADNOTIFY_C2S_ID_FIELD}
MAILREADNOTIFY.is_extendable = false
MAILREADNOTIFY.extensions = {}
MAILSENDMAILREQUEST_TOPLAYERID_FIELD.name = "toPlayerId"
MAILSENDMAILREQUEST_TOPLAYERID_FIELD.full_name = ".pomelo.area.MailSendMailRequest.toPlayerId"
MAILSENDMAILREQUEST_TOPLAYERID_FIELD.number = 1
MAILSENDMAILREQUEST_TOPLAYERID_FIELD.index = 0
MAILSENDMAILREQUEST_TOPLAYERID_FIELD.label = 2
MAILSENDMAILREQUEST_TOPLAYERID_FIELD.has_default_value = false
MAILSENDMAILREQUEST_TOPLAYERID_FIELD.default_value = ""
MAILSENDMAILREQUEST_TOPLAYERID_FIELD.type = 9
MAILSENDMAILREQUEST_TOPLAYERID_FIELD.cpp_type = 9

MAILSENDMAILREQUEST_MAILTITLE_FIELD.name = "mailTitle"
MAILSENDMAILREQUEST_MAILTITLE_FIELD.full_name = ".pomelo.area.MailSendMailRequest.mailTitle"
MAILSENDMAILREQUEST_MAILTITLE_FIELD.number = 2
MAILSENDMAILREQUEST_MAILTITLE_FIELD.index = 1
MAILSENDMAILREQUEST_MAILTITLE_FIELD.label = 2
MAILSENDMAILREQUEST_MAILTITLE_FIELD.has_default_value = false
MAILSENDMAILREQUEST_MAILTITLE_FIELD.default_value = ""
MAILSENDMAILREQUEST_MAILTITLE_FIELD.type = 9
MAILSENDMAILREQUEST_MAILTITLE_FIELD.cpp_type = 9

MAILSENDMAILREQUEST_MAILTEXT_FIELD.name = "mailText"
MAILSENDMAILREQUEST_MAILTEXT_FIELD.full_name = ".pomelo.area.MailSendMailRequest.mailText"
MAILSENDMAILREQUEST_MAILTEXT_FIELD.number = 3
MAILSENDMAILREQUEST_MAILTEXT_FIELD.index = 2
MAILSENDMAILREQUEST_MAILTEXT_FIELD.label = 2
MAILSENDMAILREQUEST_MAILTEXT_FIELD.has_default_value = false
MAILSENDMAILREQUEST_MAILTEXT_FIELD.default_value = ""
MAILSENDMAILREQUEST_MAILTEXT_FIELD.type = 9
MAILSENDMAILREQUEST_MAILTEXT_FIELD.cpp_type = 9

MAILSENDMAILREQUEST_MAILREAD_FIELD.name = "mailRead"
MAILSENDMAILREQUEST_MAILREAD_FIELD.full_name = ".pomelo.area.MailSendMailRequest.mailRead"
MAILSENDMAILREQUEST_MAILREAD_FIELD.number = 4
MAILSENDMAILREQUEST_MAILREAD_FIELD.index = 3
MAILSENDMAILREQUEST_MAILREAD_FIELD.label = 2
MAILSENDMAILREQUEST_MAILREAD_FIELD.has_default_value = false
MAILSENDMAILREQUEST_MAILREAD_FIELD.default_value = 0
MAILSENDMAILREQUEST_MAILREAD_FIELD.type = 5
MAILSENDMAILREQUEST_MAILREAD_FIELD.cpp_type = 1

MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD.name = "toPlayerName"
MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD.full_name = ".pomelo.area.MailSendMailRequest.toPlayerName"
MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD.number = 5
MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD.index = 4
MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD.label = 1
MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD.has_default_value = false
MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD.default_value = ""
MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD.type = 9
MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD.cpp_type = 9

MAILSENDMAILREQUEST.name = "MailSendMailRequest"
MAILSENDMAILREQUEST.full_name = ".pomelo.area.MailSendMailRequest"
MAILSENDMAILREQUEST.nested_types = {}
MAILSENDMAILREQUEST.enum_types = {}
MAILSENDMAILREQUEST.fields = {MAILSENDMAILREQUEST_TOPLAYERID_FIELD, MAILSENDMAILREQUEST_MAILTITLE_FIELD, MAILSENDMAILREQUEST_MAILTEXT_FIELD, MAILSENDMAILREQUEST_MAILREAD_FIELD, MAILSENDMAILREQUEST_TOPLAYERNAME_FIELD}
MAILSENDMAILREQUEST.is_extendable = false
MAILSENDMAILREQUEST.extensions = {}
MAILGETATTACHMENTREQUEST_C2S_ID_FIELD.name = "c2s_id"
MAILGETATTACHMENTREQUEST_C2S_ID_FIELD.full_name = ".pomelo.area.MailGetAttachmentRequest.c2s_id"
MAILGETATTACHMENTREQUEST_C2S_ID_FIELD.number = 1
MAILGETATTACHMENTREQUEST_C2S_ID_FIELD.index = 0
MAILGETATTACHMENTREQUEST_C2S_ID_FIELD.label = 2
MAILGETATTACHMENTREQUEST_C2S_ID_FIELD.has_default_value = false
MAILGETATTACHMENTREQUEST_C2S_ID_FIELD.default_value = ""
MAILGETATTACHMENTREQUEST_C2S_ID_FIELD.type = 9
MAILGETATTACHMENTREQUEST_C2S_ID_FIELD.cpp_type = 9

MAILGETATTACHMENTREQUEST.name = "MailGetAttachmentRequest"
MAILGETATTACHMENTREQUEST.full_name = ".pomelo.area.MailGetAttachmentRequest"
MAILGETATTACHMENTREQUEST.nested_types = {}
MAILGETATTACHMENTREQUEST.enum_types = {}
MAILGETATTACHMENTREQUEST.fields = {MAILGETATTACHMENTREQUEST_C2S_ID_FIELD}
MAILGETATTACHMENTREQUEST.is_extendable = false
MAILGETATTACHMENTREQUEST.extensions = {}
MAILGETATTACHMENTONEKEYREQUEST.name = "MailGetAttachmentOneKeyRequest"
MAILGETATTACHMENTONEKEYREQUEST.full_name = ".pomelo.area.MailGetAttachmentOneKeyRequest"
MAILGETATTACHMENTONEKEYREQUEST.nested_types = {}
MAILGETATTACHMENTONEKEYREQUEST.enum_types = {}
MAILGETATTACHMENTONEKEYREQUEST.fields = {}
MAILGETATTACHMENTONEKEYREQUEST.is_extendable = false
MAILGETATTACHMENTONEKEYREQUEST.extensions = {}
MAILDELETEREQUEST_C2S_ID_FIELD.name = "c2s_id"
MAILDELETEREQUEST_C2S_ID_FIELD.full_name = ".pomelo.area.MailDeleteRequest.c2s_id"
MAILDELETEREQUEST_C2S_ID_FIELD.number = 1
MAILDELETEREQUEST_C2S_ID_FIELD.index = 0
MAILDELETEREQUEST_C2S_ID_FIELD.label = 2
MAILDELETEREQUEST_C2S_ID_FIELD.has_default_value = false
MAILDELETEREQUEST_C2S_ID_FIELD.default_value = ""
MAILDELETEREQUEST_C2S_ID_FIELD.type = 9
MAILDELETEREQUEST_C2S_ID_FIELD.cpp_type = 9

MAILDELETEREQUEST.name = "MailDeleteRequest"
MAILDELETEREQUEST.full_name = ".pomelo.area.MailDeleteRequest"
MAILDELETEREQUEST.nested_types = {}
MAILDELETEREQUEST.enum_types = {}
MAILDELETEREQUEST.fields = {MAILDELETEREQUEST_C2S_ID_FIELD}
MAILDELETEREQUEST.is_extendable = false
MAILDELETEREQUEST.extensions = {}
MAILDELETEONEKEYREQUEST.name = "MailDeleteOneKeyRequest"
MAILDELETEONEKEYREQUEST.full_name = ".pomelo.area.MailDeleteOneKeyRequest"
MAILDELETEONEKEYREQUEST.nested_types = {}
MAILDELETEONEKEYREQUEST.enum_types = {}
MAILDELETEONEKEYREQUEST.fields = {}
MAILDELETEONEKEYREQUEST.is_extendable = false
MAILDELETEONEKEYREQUEST.extensions = {}
MAILSENDTESTNOTIFY_C2S_MAILID_FIELD.name = "c2s_mailId"
MAILSENDTESTNOTIFY_C2S_MAILID_FIELD.full_name = ".pomelo.area.MailSendTestNotify.c2s_mailId"
MAILSENDTESTNOTIFY_C2S_MAILID_FIELD.number = 1
MAILSENDTESTNOTIFY_C2S_MAILID_FIELD.index = 0
MAILSENDTESTNOTIFY_C2S_MAILID_FIELD.label = 2
MAILSENDTESTNOTIFY_C2S_MAILID_FIELD.has_default_value = false
MAILSENDTESTNOTIFY_C2S_MAILID_FIELD.default_value = 0
MAILSENDTESTNOTIFY_C2S_MAILID_FIELD.type = 5
MAILSENDTESTNOTIFY_C2S_MAILID_FIELD.cpp_type = 1

MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD.name = "c2s_tcCode"
MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD.full_name = ".pomelo.area.MailSendTestNotify.c2s_tcCode"
MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD.number = 2
MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD.index = 1
MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD.label = 2
MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD.has_default_value = false
MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD.default_value = ""
MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD.type = 9
MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD.cpp_type = 9

MAILSENDTESTNOTIFY.name = "MailSendTestNotify"
MAILSENDTESTNOTIFY.full_name = ".pomelo.area.MailSendTestNotify"
MAILSENDTESTNOTIFY.nested_types = {}
MAILSENDTESTNOTIFY.enum_types = {}
MAILSENDTESTNOTIFY.fields = {MAILSENDTESTNOTIFY_C2S_MAILID_FIELD, MAILSENDTESTNOTIFY_C2S_TCCODE_FIELD}
MAILSENDTESTNOTIFY.is_extendable = false
MAILSENDTESTNOTIFY.extensions = {}
MAIL_ID_FIELD.name = "id"
MAIL_ID_FIELD.full_name = ".pomelo.area.Mail.id"
MAIL_ID_FIELD.number = 1
MAIL_ID_FIELD.index = 0
MAIL_ID_FIELD.label = 2
MAIL_ID_FIELD.has_default_value = false
MAIL_ID_FIELD.default_value = ""
MAIL_ID_FIELD.type = 9
MAIL_ID_FIELD.cpp_type = 9

MAIL_MAILID_FIELD.name = "mailId"
MAIL_MAILID_FIELD.full_name = ".pomelo.area.Mail.mailId"
MAIL_MAILID_FIELD.number = 2
MAIL_MAILID_FIELD.index = 1
MAIL_MAILID_FIELD.label = 2
MAIL_MAILID_FIELD.has_default_value = false
MAIL_MAILID_FIELD.default_value = 0
MAIL_MAILID_FIELD.type = 5
MAIL_MAILID_FIELD.cpp_type = 1

MAIL_MAILTYPE_FIELD.name = "mailType"
MAIL_MAILTYPE_FIELD.full_name = ".pomelo.area.Mail.mailType"
MAIL_MAILTYPE_FIELD.number = 3
MAIL_MAILTYPE_FIELD.index = 2
MAIL_MAILTYPE_FIELD.label = 2
MAIL_MAILTYPE_FIELD.has_default_value = false
MAIL_MAILTYPE_FIELD.default_value = 0
MAIL_MAILTYPE_FIELD.type = 5
MAIL_MAILTYPE_FIELD.cpp_type = 1

MAIL_MAILICON_FIELD.name = "mailIcon"
MAIL_MAILICON_FIELD.full_name = ".pomelo.area.Mail.mailIcon"
MAIL_MAILICON_FIELD.number = 4
MAIL_MAILICON_FIELD.index = 3
MAIL_MAILICON_FIELD.label = 2
MAIL_MAILICON_FIELD.has_default_value = false
MAIL_MAILICON_FIELD.default_value = 0
MAIL_MAILICON_FIELD.type = 5
MAIL_MAILICON_FIELD.cpp_type = 1

MAIL_MAILSENDER_FIELD.name = "mailSender"
MAIL_MAILSENDER_FIELD.full_name = ".pomelo.area.Mail.mailSender"
MAIL_MAILSENDER_FIELD.number = 5
MAIL_MAILSENDER_FIELD.index = 4
MAIL_MAILSENDER_FIELD.label = 2
MAIL_MAILSENDER_FIELD.has_default_value = false
MAIL_MAILSENDER_FIELD.default_value = ""
MAIL_MAILSENDER_FIELD.type = 9
MAIL_MAILSENDER_FIELD.cpp_type = 9

MAIL_MAILTITLE_FIELD.name = "mailTitle"
MAIL_MAILTITLE_FIELD.full_name = ".pomelo.area.Mail.mailTitle"
MAIL_MAILTITLE_FIELD.number = 6
MAIL_MAILTITLE_FIELD.index = 5
MAIL_MAILTITLE_FIELD.label = 2
MAIL_MAILTITLE_FIELD.has_default_value = false
MAIL_MAILTITLE_FIELD.default_value = ""
MAIL_MAILTITLE_FIELD.type = 9
MAIL_MAILTITLE_FIELD.cpp_type = 9

MAIL_MAILTEXT_FIELD.name = "mailText"
MAIL_MAILTEXT_FIELD.full_name = ".pomelo.area.Mail.mailText"
MAIL_MAILTEXT_FIELD.number = 7
MAIL_MAILTEXT_FIELD.index = 6
MAIL_MAILTEXT_FIELD.label = 2
MAIL_MAILTEXT_FIELD.has_default_value = false
MAIL_MAILTEXT_FIELD.default_value = ""
MAIL_MAILTEXT_FIELD.type = 9
MAIL_MAILTEXT_FIELD.cpp_type = 9

MAIL_CREATETIME_FIELD.name = "createTime"
MAIL_CREATETIME_FIELD.full_name = ".pomelo.area.Mail.createTime"
MAIL_CREATETIME_FIELD.number = 8
MAIL_CREATETIME_FIELD.index = 7
MAIL_CREATETIME_FIELD.label = 2
MAIL_CREATETIME_FIELD.has_default_value = false
MAIL_CREATETIME_FIELD.default_value = ""
MAIL_CREATETIME_FIELD.type = 9
MAIL_CREATETIME_FIELD.cpp_type = 9

MAIL_STATUS_FIELD.name = "status"
MAIL_STATUS_FIELD.full_name = ".pomelo.area.Mail.status"
MAIL_STATUS_FIELD.number = 9
MAIL_STATUS_FIELD.index = 8
MAIL_STATUS_FIELD.label = 2
MAIL_STATUS_FIELD.has_default_value = false
MAIL_STATUS_FIELD.default_value = 0
MAIL_STATUS_FIELD.type = 5
MAIL_STATUS_FIELD.cpp_type = 1

MAIL_MAILREAD_FIELD.name = "mailRead"
MAIL_MAILREAD_FIELD.full_name = ".pomelo.area.Mail.mailRead"
MAIL_MAILREAD_FIELD.number = 10
MAIL_MAILREAD_FIELD.index = 9
MAIL_MAILREAD_FIELD.label = 2
MAIL_MAILREAD_FIELD.has_default_value = false
MAIL_MAILREAD_FIELD.default_value = 0
MAIL_MAILREAD_FIELD.type = 5
MAIL_MAILREAD_FIELD.cpp_type = 1

MAIL_HADATTACH_FIELD.name = "hadAttach"
MAIL_HADATTACH_FIELD.full_name = ".pomelo.area.Mail.hadAttach"
MAIL_HADATTACH_FIELD.number = 11
MAIL_HADATTACH_FIELD.index = 10
MAIL_HADATTACH_FIELD.label = 2
MAIL_HADATTACH_FIELD.has_default_value = false
MAIL_HADATTACH_FIELD.default_value = 0
MAIL_HADATTACH_FIELD.type = 5
MAIL_HADATTACH_FIELD.cpp_type = 1

MAIL_ATTACHMENT_FIELD.name = "attachment"
MAIL_ATTACHMENT_FIELD.full_name = ".pomelo.area.Mail.attachment"
MAIL_ATTACHMENT_FIELD.number = 12
MAIL_ATTACHMENT_FIELD.index = 11
MAIL_ATTACHMENT_FIELD.label = 3
MAIL_ATTACHMENT_FIELD.has_default_value = false
MAIL_ATTACHMENT_FIELD.default_value = {}
MAIL_ATTACHMENT_FIELD.message_type = item_pb.MINIITEM
MAIL_ATTACHMENT_FIELD.type = 11
MAIL_ATTACHMENT_FIELD.cpp_type = 10

MAIL_MAILSENDERID_FIELD.name = "mailSenderId"
MAIL_MAILSENDERID_FIELD.full_name = ".pomelo.area.Mail.mailSenderId"
MAIL_MAILSENDERID_FIELD.number = 13
MAIL_MAILSENDERID_FIELD.index = 12
MAIL_MAILSENDERID_FIELD.label = 1
MAIL_MAILSENDERID_FIELD.has_default_value = false
MAIL_MAILSENDERID_FIELD.default_value = ""
MAIL_MAILSENDERID_FIELD.type = 9
MAIL_MAILSENDERID_FIELD.cpp_type = 9

MAIL_ITEMEAR_FIELD.name = "itemEar"
MAIL_ITEMEAR_FIELD.full_name = ".pomelo.area.Mail.itemEar"
MAIL_ITEMEAR_FIELD.number = 14
MAIL_ITEMEAR_FIELD.index = 13
MAIL_ITEMEAR_FIELD.label = 3
MAIL_ITEMEAR_FIELD.has_default_value = false
MAIL_ITEMEAR_FIELD.default_value = {}
MAIL_ITEMEAR_FIELD.message_type = item_pb.EARITEMDETAIL
MAIL_ITEMEAR_FIELD.type = 11
MAIL_ITEMEAR_FIELD.cpp_type = 10

MAIL_NEWATTACHMENT_FIELD.name = "newAttachment"
MAIL_NEWATTACHMENT_FIELD.full_name = ".pomelo.area.Mail.newAttachment"
MAIL_NEWATTACHMENT_FIELD.number = 15
MAIL_NEWATTACHMENT_FIELD.index = 14
MAIL_NEWATTACHMENT_FIELD.label = 3
MAIL_NEWATTACHMENT_FIELD.has_default_value = false
MAIL_NEWATTACHMENT_FIELD.default_value = {}
MAIL_NEWATTACHMENT_FIELD.message_type = item_pb.ITEMDETAIL
MAIL_NEWATTACHMENT_FIELD.type = 11
MAIL_NEWATTACHMENT_FIELD.cpp_type = 10

MAIL.name = "Mail"
MAIL.full_name = ".pomelo.area.Mail"
MAIL.nested_types = {}
MAIL.enum_types = {}
MAIL.fields = {MAIL_ID_FIELD, MAIL_MAILID_FIELD, MAIL_MAILTYPE_FIELD, MAIL_MAILICON_FIELD, MAIL_MAILSENDER_FIELD, MAIL_MAILTITLE_FIELD, MAIL_MAILTEXT_FIELD, MAIL_CREATETIME_FIELD, MAIL_STATUS_FIELD, MAIL_MAILREAD_FIELD, MAIL_HADATTACH_FIELD, MAIL_ATTACHMENT_FIELD, MAIL_MAILSENDERID_FIELD, MAIL_ITEMEAR_FIELD, MAIL_NEWATTACHMENT_FIELD}
MAIL.is_extendable = false
MAIL.extensions = {}
MAILGETALLRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
MAILGETALLRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.MailGetAllResponse.s2c_code"
MAILGETALLRESPONSE_S2C_CODE_FIELD.number = 1
MAILGETALLRESPONSE_S2C_CODE_FIELD.index = 0
MAILGETALLRESPONSE_S2C_CODE_FIELD.label = 2
MAILGETALLRESPONSE_S2C_CODE_FIELD.has_default_value = false
MAILGETALLRESPONSE_S2C_CODE_FIELD.default_value = 0
MAILGETALLRESPONSE_S2C_CODE_FIELD.type = 5
MAILGETALLRESPONSE_S2C_CODE_FIELD.cpp_type = 1

MAILGETALLRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
MAILGETALLRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.MailGetAllResponse.s2c_msg"
MAILGETALLRESPONSE_S2C_MSG_FIELD.number = 2
MAILGETALLRESPONSE_S2C_MSG_FIELD.index = 1
MAILGETALLRESPONSE_S2C_MSG_FIELD.label = 1
MAILGETALLRESPONSE_S2C_MSG_FIELD.has_default_value = false
MAILGETALLRESPONSE_S2C_MSG_FIELD.default_value = ""
MAILGETALLRESPONSE_S2C_MSG_FIELD.type = 9
MAILGETALLRESPONSE_S2C_MSG_FIELD.cpp_type = 9

MAILGETALLRESPONSE_MAILS_FIELD.name = "mails"
MAILGETALLRESPONSE_MAILS_FIELD.full_name = ".pomelo.area.MailGetAllResponse.mails"
MAILGETALLRESPONSE_MAILS_FIELD.number = 3
MAILGETALLRESPONSE_MAILS_FIELD.index = 2
MAILGETALLRESPONSE_MAILS_FIELD.label = 3
MAILGETALLRESPONSE_MAILS_FIELD.has_default_value = false
MAILGETALLRESPONSE_MAILS_FIELD.default_value = {}
MAILGETALLRESPONSE_MAILS_FIELD.message_type = MAIL
MAILGETALLRESPONSE_MAILS_FIELD.type = 11
MAILGETALLRESPONSE_MAILS_FIELD.cpp_type = 10

MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD.name = "s2c_maxMailNum"
MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD.full_name = ".pomelo.area.MailGetAllResponse.s2c_maxMailNum"
MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD.number = 4
MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD.index = 3
MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD.label = 2
MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD.has_default_value = false
MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD.default_value = 0
MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD.type = 5
MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD.cpp_type = 1

MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD.name = "s2c_maxWordNum"
MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD.full_name = ".pomelo.area.MailGetAllResponse.s2c_maxWordNum"
MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD.number = 5
MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD.index = 4
MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD.label = 2
MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD.has_default_value = false
MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD.default_value = 0
MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD.type = 5
MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD.cpp_type = 1

MAILGETALLRESPONSE.name = "MailGetAllResponse"
MAILGETALLRESPONSE.full_name = ".pomelo.area.MailGetAllResponse"
MAILGETALLRESPONSE.nested_types = {}
MAILGETALLRESPONSE.enum_types = {}
MAILGETALLRESPONSE.fields = {MAILGETALLRESPONSE_S2C_CODE_FIELD, MAILGETALLRESPONSE_S2C_MSG_FIELD, MAILGETALLRESPONSE_MAILS_FIELD, MAILGETALLRESPONSE_S2C_MAXMAILNUM_FIELD, MAILGETALLRESPONSE_S2C_MAXWORDNUM_FIELD}
MAILGETALLRESPONSE.is_extendable = false
MAILGETALLRESPONSE.extensions = {}
ONGETMAILPUSH_S2C_CODE_FIELD.name = "s2c_code"
ONGETMAILPUSH_S2C_CODE_FIELD.full_name = ".pomelo.area.OnGetMailPush.s2c_code"
ONGETMAILPUSH_S2C_CODE_FIELD.number = 1
ONGETMAILPUSH_S2C_CODE_FIELD.index = 0
ONGETMAILPUSH_S2C_CODE_FIELD.label = 2
ONGETMAILPUSH_S2C_CODE_FIELD.has_default_value = false
ONGETMAILPUSH_S2C_CODE_FIELD.default_value = 0
ONGETMAILPUSH_S2C_CODE_FIELD.type = 5
ONGETMAILPUSH_S2C_CODE_FIELD.cpp_type = 1

ONGETMAILPUSH_MAILS_FIELD.name = "mails"
ONGETMAILPUSH_MAILS_FIELD.full_name = ".pomelo.area.OnGetMailPush.mails"
ONGETMAILPUSH_MAILS_FIELD.number = 2
ONGETMAILPUSH_MAILS_FIELD.index = 1
ONGETMAILPUSH_MAILS_FIELD.label = 3
ONGETMAILPUSH_MAILS_FIELD.has_default_value = false
ONGETMAILPUSH_MAILS_FIELD.default_value = {}
ONGETMAILPUSH_MAILS_FIELD.message_type = MAIL
ONGETMAILPUSH_MAILS_FIELD.type = 11
ONGETMAILPUSH_MAILS_FIELD.cpp_type = 10

ONGETMAILPUSH.name = "OnGetMailPush"
ONGETMAILPUSH.full_name = ".pomelo.area.OnGetMailPush"
ONGETMAILPUSH.nested_types = {}
ONGETMAILPUSH.enum_types = {}
ONGETMAILPUSH.fields = {ONGETMAILPUSH_S2C_CODE_FIELD, ONGETMAILPUSH_MAILS_FIELD}
ONGETMAILPUSH.is_extendable = false
ONGETMAILPUSH.extensions = {}
MAILSENDMAILRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
MAILSENDMAILRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.MailSendMailResponse.s2c_code"
MAILSENDMAILRESPONSE_S2C_CODE_FIELD.number = 1
MAILSENDMAILRESPONSE_S2C_CODE_FIELD.index = 0
MAILSENDMAILRESPONSE_S2C_CODE_FIELD.label = 2
MAILSENDMAILRESPONSE_S2C_CODE_FIELD.has_default_value = false
MAILSENDMAILRESPONSE_S2C_CODE_FIELD.default_value = 0
MAILSENDMAILRESPONSE_S2C_CODE_FIELD.type = 5
MAILSENDMAILRESPONSE_S2C_CODE_FIELD.cpp_type = 1

MAILSENDMAILRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
MAILSENDMAILRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.MailSendMailResponse.s2c_msg"
MAILSENDMAILRESPONSE_S2C_MSG_FIELD.number = 2
MAILSENDMAILRESPONSE_S2C_MSG_FIELD.index = 1
MAILSENDMAILRESPONSE_S2C_MSG_FIELD.label = 1
MAILSENDMAILRESPONSE_S2C_MSG_FIELD.has_default_value = false
MAILSENDMAILRESPONSE_S2C_MSG_FIELD.default_value = ""
MAILSENDMAILRESPONSE_S2C_MSG_FIELD.type = 9
MAILSENDMAILRESPONSE_S2C_MSG_FIELD.cpp_type = 9

MAILSENDMAILRESPONSE.name = "MailSendMailResponse"
MAILSENDMAILRESPONSE.full_name = ".pomelo.area.MailSendMailResponse"
MAILSENDMAILRESPONSE.nested_types = {}
MAILSENDMAILRESPONSE.enum_types = {}
MAILSENDMAILRESPONSE.fields = {MAILSENDMAILRESPONSE_S2C_CODE_FIELD, MAILSENDMAILRESPONSE_S2C_MSG_FIELD}
MAILSENDMAILRESPONSE.is_extendable = false
MAILSENDMAILRESPONSE.extensions = {}
MAILDELETERESPONSE_S2C_CODE_FIELD.name = "s2c_code"
MAILDELETERESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.MailDeleteResponse.s2c_code"
MAILDELETERESPONSE_S2C_CODE_FIELD.number = 1
MAILDELETERESPONSE_S2C_CODE_FIELD.index = 0
MAILDELETERESPONSE_S2C_CODE_FIELD.label = 2
MAILDELETERESPONSE_S2C_CODE_FIELD.has_default_value = false
MAILDELETERESPONSE_S2C_CODE_FIELD.default_value = 0
MAILDELETERESPONSE_S2C_CODE_FIELD.type = 5
MAILDELETERESPONSE_S2C_CODE_FIELD.cpp_type = 1

MAILDELETERESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
MAILDELETERESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.MailDeleteResponse.s2c_msg"
MAILDELETERESPONSE_S2C_MSG_FIELD.number = 2
MAILDELETERESPONSE_S2C_MSG_FIELD.index = 1
MAILDELETERESPONSE_S2C_MSG_FIELD.label = 1
MAILDELETERESPONSE_S2C_MSG_FIELD.has_default_value = false
MAILDELETERESPONSE_S2C_MSG_FIELD.default_value = ""
MAILDELETERESPONSE_S2C_MSG_FIELD.type = 9
MAILDELETERESPONSE_S2C_MSG_FIELD.cpp_type = 9

MAILDELETERESPONSE.name = "MailDeleteResponse"
MAILDELETERESPONSE.full_name = ".pomelo.area.MailDeleteResponse"
MAILDELETERESPONSE.nested_types = {}
MAILDELETERESPONSE.enum_types = {}
MAILDELETERESPONSE.fields = {MAILDELETERESPONSE_S2C_CODE_FIELD, MAILDELETERESPONSE_S2C_MSG_FIELD}
MAILDELETERESPONSE.is_extendable = false
MAILDELETERESPONSE.extensions = {}
MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.MailDeleteOneKeyResponse.s2c_code"
MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD.number = 1
MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD.index = 0
MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD.label = 2
MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD.has_default_value = false
MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD.default_value = 0
MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD.type = 5
MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD.cpp_type = 1

MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.MailDeleteOneKeyResponse.s2c_msg"
MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD.number = 2
MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD.index = 1
MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD.label = 1
MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD.has_default_value = false
MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD.default_value = ""
MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD.type = 9
MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD.cpp_type = 9

MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD.name = "s2c_ids"
MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD.full_name = ".pomelo.area.MailDeleteOneKeyResponse.s2c_ids"
MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD.number = 3
MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD.index = 2
MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD.label = 3
MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD.has_default_value = false
MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD.default_value = {}
MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD.type = 9
MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD.cpp_type = 9

MAILDELETEONEKEYRESPONSE.name = "MailDeleteOneKeyResponse"
MAILDELETEONEKEYRESPONSE.full_name = ".pomelo.area.MailDeleteOneKeyResponse"
MAILDELETEONEKEYRESPONSE.nested_types = {}
MAILDELETEONEKEYRESPONSE.enum_types = {}
MAILDELETEONEKEYRESPONSE.fields = {MAILDELETEONEKEYRESPONSE_S2C_CODE_FIELD, MAILDELETEONEKEYRESPONSE_S2C_MSG_FIELD, MAILDELETEONEKEYRESPONSE_S2C_IDS_FIELD}
MAILDELETEONEKEYRESPONSE.is_extendable = false
MAILDELETEONEKEYRESPONSE.extensions = {}
MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.MailGetAttachmentResponse.s2c_code"
MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD.number = 1
MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD.index = 0
MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD.label = 2
MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD.has_default_value = false
MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD.default_value = 0
MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD.type = 5
MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD.cpp_type = 1

MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.MailGetAttachmentResponse.s2c_msg"
MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD.number = 2
MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD.index = 1
MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD.label = 1
MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD.has_default_value = false
MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD.default_value = ""
MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD.type = 9
MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD.cpp_type = 9

MAILGETATTACHMENTRESPONSE.name = "MailGetAttachmentResponse"
MAILGETATTACHMENTRESPONSE.full_name = ".pomelo.area.MailGetAttachmentResponse"
MAILGETATTACHMENTRESPONSE.nested_types = {}
MAILGETATTACHMENTRESPONSE.enum_types = {}
MAILGETATTACHMENTRESPONSE.fields = {MAILGETATTACHMENTRESPONSE_S2C_CODE_FIELD, MAILGETATTACHMENTRESPONSE_S2C_MSG_FIELD}
MAILGETATTACHMENTRESPONSE.is_extendable = false
MAILGETATTACHMENTRESPONSE.extensions = {}
MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD.name = "s2c_code"
MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD.full_name = ".pomelo.area.MailGetAttachmentOneKeyResponse.s2c_code"
MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD.number = 1
MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD.index = 0
MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD.label = 2
MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD.has_default_value = false
MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD.default_value = 0
MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD.type = 5
MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD.cpp_type = 1

MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD.name = "s2c_msg"
MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD.full_name = ".pomelo.area.MailGetAttachmentOneKeyResponse.s2c_msg"
MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD.number = 2
MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD.index = 1
MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD.label = 1
MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD.has_default_value = false
MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD.default_value = ""
MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD.type = 9
MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD.cpp_type = 9

MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD.name = "s2c_ids"
MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD.full_name = ".pomelo.area.MailGetAttachmentOneKeyResponse.s2c_ids"
MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD.number = 3
MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD.index = 2
MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD.label = 3
MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD.has_default_value = false
MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD.default_value = {}
MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD.type = 9
MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD.cpp_type = 9

MAILGETATTACHMENTONEKEYRESPONSE.name = "MailGetAttachmentOneKeyResponse"
MAILGETATTACHMENTONEKEYRESPONSE.full_name = ".pomelo.area.MailGetAttachmentOneKeyResponse"
MAILGETATTACHMENTONEKEYRESPONSE.nested_types = {}
MAILGETATTACHMENTONEKEYRESPONSE.enum_types = {}
MAILGETATTACHMENTONEKEYRESPONSE.fields = {MAILGETATTACHMENTONEKEYRESPONSE_S2C_CODE_FIELD, MAILGETATTACHMENTONEKEYRESPONSE_S2C_MSG_FIELD, MAILGETATTACHMENTONEKEYRESPONSE_S2C_IDS_FIELD}
MAILGETATTACHMENTONEKEYRESPONSE.is_extendable = false
MAILGETATTACHMENTONEKEYRESPONSE.extensions = {}

Mail = protobuf.Message(MAIL)
MailDeleteOneKeyRequest = protobuf.Message(MAILDELETEONEKEYREQUEST)
MailDeleteOneKeyResponse = protobuf.Message(MAILDELETEONEKEYRESPONSE)
MailDeleteRequest = protobuf.Message(MAILDELETEREQUEST)
MailDeleteResponse = protobuf.Message(MAILDELETERESPONSE)
MailGetAllRequest = protobuf.Message(MAILGETALLREQUEST)
MailGetAllResponse = protobuf.Message(MAILGETALLRESPONSE)
MailGetAttachmentOneKeyRequest = protobuf.Message(MAILGETATTACHMENTONEKEYREQUEST)
MailGetAttachmentOneKeyResponse = protobuf.Message(MAILGETATTACHMENTONEKEYRESPONSE)
MailGetAttachmentRequest = protobuf.Message(MAILGETATTACHMENTREQUEST)
MailGetAttachmentResponse = protobuf.Message(MAILGETATTACHMENTRESPONSE)
MailReadNotify = protobuf.Message(MAILREADNOTIFY)
MailSendMailRequest = protobuf.Message(MAILSENDMAILREQUEST)
MailSendMailResponse = protobuf.Message(MAILSENDMAILRESPONSE)
MailSendTestNotify = protobuf.Message(MAILSENDTESTNOTIFY)
OnGetMailPush = protobuf.Message(ONGETMAILPUSH)
