local tbUi = Ui:CreateClass("Reload");

tbUi.RemainCmd = {}

function tbUi:OnOpen(szFileName)
	if szFileName then
		self.RemainCmd[szFileName] = true;
	end
end

function tbUi:OnOpenEnd()
	self:OnChangeFile();
end

function tbUi:OnChangeFile()
	local szAllCmd = ""
	for szFileName,_ in pairs(self.RemainCmd) do
		szAllCmd = szAllCmd .. (szFileName .. "\n");
	end
	self.ReloadInput:SetText(szAllCmd);
end 

function tbUi:DoCommand()
	local szAllCmd = "";
	local szCmd = "";
	local szLogInfo = "load file \n";
	for szFileName,_ in pairs(self.RemainCmd) do
		local szType = string.match(szFileName, "^([^/]*)/");
		if not szType then
			return;
		end

		local szCC = 'DoScript("%s");\n';
		local szCS = "GMCommand(\"DoScript('%s')\", %d)\n";
		if szType == "Script" then
			szCmd = szCmd .. string.format(szCC, szFileName);
			szLogInfo = szLogInfo .. szFileName .. "\n";
		elseif szType == "ServerScript" or szType == "ZoneScript"  then
			szCmd = szCmd .. string.format(szCS, szFileName, 0) .. string.format(szCS, szFileName, 1) ;
		elseif szType == "CommonScript" then
			szCmd = szCmd .. string.format(szCC, szFileName);
			szCmd = szCmd .. string.format(szCS, szFileName, 0) .. string.format(szCS, szFileName, 1) ;
			szLogInfo = szLogInfo .. szFileName .. "\n";
		end
		szAllCmd = szAllCmd .. szCmd;
	end
	if szAllCmd =="" then
		return;
	end
	local fnCmd, szMsg	= loadstring(szAllCmd);
	if (not fnCmd) then
		print(fnCmd);
		error("Do GmCmd failed:"..szMsg);
		return;
	end

	local bRet, nRetCode = pcall(fnCmd);
	if not bRet then
		print(nRetCode);
		local szInfo = debug.traceback();
		print(szInfo);
		self.ReloadInput:SetText(szInfo);
		return;
	end
	Log(szLogInfo);
	self.ReloadInput:SetText("");
end

tbUi.tbOnClick = {}
tbUi.tbOnClick.BtnCancel = function (self)
	self.RemainCmd = {};
	Ui:CloseWindow("Reload");
end
tbUi.tbOnClick.BtnLoad = function (self)
	if not next(self.RemainCmd) then
		me.CenterMsg("no change file!")
	else
		self:DoCommand();
	end
	self.RemainCmd = {};
	Ui:CloseWindow("Reload");
end