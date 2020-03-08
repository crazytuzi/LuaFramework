
function MsgInfoCtrl:LoadSetting()
	self.tbSetting = LoadTabFile("Setting/MsgInfo.tab", "ds", "Id", {"Id", "Msg"});
end
MsgInfoCtrl:LoadSetting();

function MsgInfoCtrl:GetMsg(nMsgId, ...)
	if not self.tbSetting[nMsgId] then
		return "";
	end

	local szMsg = self.tbSetting[nMsgId].Msg;
	local tbParam = {...};
	for nIdx, value in pairs(tbParam or {}) do
		szMsg = string.gsub(szMsg, string.format("{%s}", nIdx), tostring(value));
	end

	return szMsg;
end