local tbUi = Ui:CreateClass("EvaluatePanel");
local Application = luanet.import_type("UnityEngine.Application")

function tbUi:OnOpen()
	if version_xm then
		if Sdk:XMISEvaluateAwardSend(me) then
			return 0;
		end
	end
end

tbUi.tbOnClick =
{
	BtnGoNow = function (self)
		Sdk:XGTakeEvaluateReward();

		if IOS then
			local szId;
			if version_hk then
				szId = "1132435921"
			elseif version_tw then
				szId = "1132436180"
			elseif version_xm then
				szId = "1159225159"
			elseif version_kor then
				szId = "1252553361"
			end
			if szId then
				Application.OpenURL("itms-apps://itunes.apple.com/app/id"..szId)
			end
		elseif ANDROID then
			local szPackageName;
			if version_hk then
				szPackageName = "com.efun.jxqy.hk"
			elseif version_tw then
				szPackageName = "com.efun.jxqy.tw"
			elseif version_xm then
				szPackageName = "com.efun.jxqy.sm"
			elseif version_kor then
				if Sdk:GetChannelId() == "ejonestore" then
					Application.OpenURL("http://www.jxqy.org");
				else
					szPackageName = "com.kingsoftgame.ggplay.jxqykr"
				end
			end
			if szPackageName then
				Application.OpenURL("http://www.jxqy.org/?id="..szPackageName);

			end
		else
			Application.OpenURL("http://www.jxqy.org");
		end
		local tbEnvaluate = Client:GetUserInfo("Evaluate")
		tbEnvaluate.bIgnore = true;
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnLater = function (self)
		if version_kor then
			Application.OpenURL("http://www.jxqy.org")
			--self.tbOnClick.BtnGoNow(self)
		else
        	Ui:CloseWindow(self.UI_NAME)
        end
	end,
	BtnNoThank = function (self)
--		if version_kor then
--			Sdk:XGOpenUserCenter()
--		end
		local tbEnvaluate = Client:GetUserInfo("Evaluate")
		tbEnvaluate.bIgnore = true;
		Client:SaveUserInfo();
		Ui:CloseWindow(self.UI_NAME)
	end,
}


