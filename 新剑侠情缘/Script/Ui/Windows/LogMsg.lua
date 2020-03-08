
local tbUi = Ui:CreateClass("LogMsg");

local monthState =
{
	all = -1,
}

function tbUi:OnOpen()
	self:Update();
end

function tbUi:Update()
	if self.szDir then
		return;
	end

	self.szDir = g_szUserPath .. "logs/Client";
	if IOS then
		self.szDir = Ui.ToolFunction.LibarayPath .. "/logs/Client";
	end

	self.tbAllFiles = {};
	local tbRes = TraverseDir(self.szDir);
	for _, szPath in pairs(tbRes) do
		local szFileName = string.match(szPath, "logs/Client/([0-9_]*).log$");
		if szFileName then
			table.insert(self.tbAllFiles, szFileName);
		end
	end

	table.sort(self.tbAllFiles, function (a, b) return a > b; end);

	local fnOnSelect = function (buttonObj)
		self:ShowFile(self.tbAllFiles[buttonObj.Index]);
	end

	local fnSetItem = function(itemObj, index)
		itemObj.pPanel:Label_SetText("Name", self.tbAllFiles[index])
		itemObj.Index = index;
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end
	self.ScrollView:Update(self.tbAllFiles, fnSetItem);
end

function tbUi:UpdateFile(nMonth,nDay)
	local tbLogFile
	if nMonth == monthState.all then
		tbLogFile = self.tbAllFiles
	else
		tbLogFile = self:GetLogByMonthAndDay(nMonth,nDay)
	end
	if not tbLogFile then
		return
	end
	local fnOnSelect = function (buttonObj)
		self:ShowFile(szFileName);
	end

	local fnSetItem = function(itemObj, index)
		itemObj.pPanel:Label_SetText("Name", tbLogFile[index])
		itemObj.Index = index;
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end
	self.ScrollView:Update(tbLogFile, fnSetItem);
end

function tbUi:ShowFile(szFileName)
	self.szFileName = szFileName or self.szFileName;
	if not self.szFileName then
		return;
	end

	local file = io.open(self.szDir .. "/" .. self.szFileName .. ".log", "r");
	if not file then
		me.SendBlackBoardMsg("打开文件 " .. self.szFileName .. " 失败 ！！");
		return;
	end

	local szLogInfo = file:read("*all");
	file:close();
	if self.bSwitch then
		szLogInfo = string.gsub(szLogInfo, ".", function(s) return string.char(255 - string.byte(s)); end);
	end

	self.pPanel:TextList_Clear("Msg");
	self.pPanel:TextList_AddText("Msg", szLogInfo);
end

function tbUi:GetLogByMonthAndDay(month,day)
	local tbLogFile = {}
	month = tonumber(month)
	day = tonumber(day)
	if not month or not day then
		return tbLogFile
	end
	if self.tbAllFiles then
		for index,szFileName in ipairs(self.tbAllFiles) do
			local nameTB = Lib:SplitStr(szFileName, "_")
			if nameTB[2] and nameTB[3] then
				local  nMonth = tonumber(nameTB[2])
				local  nDay = tonumber(nameTB[3])
				if not nMonth or not nDay then
					break
				end
				if month == nMonth and day == nDay then
					table.insert(tbLogFile,szFileName)
				end
			end

		end
	end
	return tbLogFile
end

function tbUi:SwitchType()
	self.bSwitch = not self.bSwitch;
	self:ShowFile();
end

tbUi.tbOnClick = {
	Go = function (self)
		local month = self.InputMonth:GetText()
		local day = self.InputDay:GetText()
		self:UpdateFile(month,day)
	end,
	All = function (self)
		self:UpdateFile(monthState.all)
	end,

	Decoding = function (self)
		self:SwitchType();
	end
}



