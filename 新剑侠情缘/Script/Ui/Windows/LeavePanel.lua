
local tbLeaveUI = Ui:CreateClass("LeavePanel");
function tbLeaveUI:OnOpen(szTitle, szMsg, tbCallback)
	self.szTitle = szTitle;
	self.szMsg = szMsg;
	self.tbCallback = tbCallback;
	self.pPanel:Button_SetText("BtnLeave", szTitle or "离开")
end

tbLeaveUI.tbOnClick = {};
function tbLeaveUI.tbOnClick:BtnLeave()
	local szMsg = self.szMsg
	if not self.szMsg then
	    self.szMsg = "确定要离开活动？"
	end
    if self.tbCallback then
    	Ui:OpenWindow("MessageBox", self.szMsg, {{function () Lib:CallBack(self.tbCallback) end}, {}}, {"确定", "取消"});
    else
    	RemoteServer.PlayerLeaveMap(szMsg);
    end
    	
end





