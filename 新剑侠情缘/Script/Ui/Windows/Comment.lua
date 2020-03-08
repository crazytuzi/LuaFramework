
local tbUi = Ui:CreateClass("Comment");

function tbUi:OnOpen()
	if not version_tx then
		return 0;
	end

	if Client:IsCloseIOSEntry() then
		return 0;
	end

	if not IOS and not WINDOWS then
		return 0;
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {};

tbUi.tbOnClick.BtnRefuse = function (self)
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnComplaints = function (self)
	if version_tx then
		if Sdk:IsLoginByQQ() then
			Sdk:OpenUrl("http://www.jxqy.org");
		else
			Sdk:OpenUrl("http://www.jxqy.org");
		end
	else
		Sdk:OpenUrl("http://www.jxqy.org");
	end
	Ui:CloseWindow(self.UI_NAME);
end

tbUi.tbOnClick.BtnPraise = function (self)
	if IOS then
		local szId;
		if version_tx then
			szId = "1086842482";
		elseif version_hk then
			szId = "1132435921";
		elseif version_tw then
			szId = "1132436180";
		elseif version_xm then
			szId = "1159225159";
		end
		if szId then
			Ui.CoreDll.IOSOpenUrl("itms-apps://itunes.apple.com/app/id" .. szId);
		end
	elseif ANDROID then
		if version_tx then
			Sdk:OpenUrl("http://www.jxqy.org");
			--Sdk:OpenUrl("http://sj.qq.com/myapp/detail.htm?apkName=com.tencent.tmgp.jxqy");
		else
			local szPackageName;
			if version_hk then
				szPackageName = "com.efun.jxqy.hk"
			elseif version_tw then
				szPackageName = "com.efun.jxqy.tw"
			elseif version_xm then
				szPackageName = "com.efun.jxqy.sm"
			end
			if szPackageName then
				Ui.Application.OpenURL("http://www.jxqy.org"..szPackageName);
			end
		end

	else
		me.CenterMsg("假装去评论了！");
	end
	RemoteServer.TLogClickPraise();
	Ui:CloseWindow(self.UI_NAME);
end

