-- 通知文字信息
SCNoticeNumStr = SCNoticeNumStr or BaseClass(BaseProtocolStruct)
function SCNoticeNumStr:__init()
	self.msg_type = 15000
	self.notice_numstr = ""
end

function SCNoticeNumStr:Decode()
	self.notice_numstr = MsgAdapter.ReadStrN(256)
end