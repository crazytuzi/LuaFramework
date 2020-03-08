local tbUi = Ui:CreateClass("Commander");
local tbItemUi = Ui:CreateClass("DoubleItem");		--双按钮的scrollviewitem

tbUi.szCmd = "";
tbItemUi.nBtnNum = 2;	--当前scrollview的item每行有2个显示对象

function tbUi:DoCommand(szOrgMsg)
	local _, _, szTarget, szSpace, szCmd = string.find(szOrgMsg, "^[/\]([^ ]+)([ ]*)(.*)");

	if (szCmd == "") then
		return szTarget;
	end

	if (szTarget == "/") then
		print("GmCmd:", szCmd);		
		local fnCmd, szMsg	= loadstring(szCmd, "[GmCmd]");
		if (not fnCmd) then
			Log("Error" .. szMsg);
			error("Do GmCmd failed:"..szMsg)
			return;
		end

		local bRet, nRetCode = pcall(fnCmd);
		if not bRet then
			print(nRetCode);
			local szInfo = debug.traceback();
			print(szInfo);
			self.ErrInfo:SetText(szInfo);
			return;
		end

		self.ErrInfo:SetText("");
		self:AddRecentCmd(szOrgMsg);
		return;
	elseif (szTarget == "?") then
		GMCommand(szCmd);
	elseif (szTarget == "z") then
		GMCommand(szCmd, 1);
	end

	self.ErrInfo:SetText("");
	self:AddRecentCmd(szOrgMsg);
end

function tbUi:OnOpen()
	self:LoadCommander();
	self:LoadRecentCmd();
	
	self.TxtInfo:SetText(self.szCmd);
	self.pPanel:SetActive("ErrInfo", not WINDOWS);	
end

function tbUi:OnOpenEnd()
	local szSearch = self.Input:GetText()
	if szSearch and szSearch ~= "" and szSearch ~= "Search" then
		self:SearchSaveList(szSearch)
	end
end

function tbUi:LoadCommander()
	local f = io.open(g_szUserPath .. "Commander.lua", "r");
	local szFileContent;
	if f then
		szFileContent = f:read("*all");
	end
	if (szFileContent) then
		local fnFile	= loadstring(szFileContent);
		self.tbTextList	= fnFile();
	else
		self.tbTextList	= {};
	end
	self:RefreshList();
end

function tbUi:RefreshList()
	local fnOnSelect = function (buttonObj)
		self.SaveInput:SetText(self.tbTextList[buttonObj.Index][1]);
		self.TxtInfo:SetText(self.tbTextList[buttonObj.Index][2]);
	end

	local fnSetItem = function(itemObj, index)
		local data = self.tbTextList[index];
		itemObj.pPanel:Label_SetText("Name", data[1]);
		itemObj.Index = index;
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end
	self.ScrollView:Update(self.tbTextList, fnSetItem);
end

local szReloadTitle = "ReloadLuaFile";
function tbUi:Save()
	self.tbTextList = self.tbTextList or {};
	for i = #self.tbTextList, 1, -1 do
		if self.tbTextList[i][1] and self.tbTextList[i][1] == szReloadTitle then
			table.remove(self.tbTextList, i);
		end
	end

	local szValue = Lib:Val2Str(self.tbTextList);
	local f = assert(io.open(g_szUserPath .. "Commander.lua", "w+"))
	f:write("return" .. szValue);
	f:close();
end

function tbUi:LoadRecentCmd()
	local f = io.open(g_szUserPath .. "RecentCmd.lua", "r");
	local szFileContent;
	if f then
		szFileContent = f:read("*all");
	end
	if (szFileContent) then
		local fnFile	= loadstring(szFileContent);
		self.tbRecentCmd = fnFile();
	else
		self.tbRecentCmd = {};
	end
	
	self:RefreshRecentList();
end
 
--添加成功的指令到最近指令集中
function tbUi:AddRecentCmd(szCmd)
	if string.find(szCmd, "-- ReloadLuaFile --") then return; end

	for index, cmd in ipairs(self.tbRecentCmd) do
		if cmd == szCmd then
			table.remove(self.tbRecentCmd, index);
			break;
		end
	end
	table.insert(self.tbRecentCmd, 1, szCmd);
	for idx = #self.tbRecentCmd, 9, -1 do
		table.remove(self.tbRecentCmd, idx);
	end

	self:SaveRecentCmd();
	self:RefreshRecentList();
end

function tbUi:SaveRecentCmd()
	local szValue = Lib:Val2Str(self.tbRecentCmd);
	local f = assert(io.open(g_szUserPath .. "RecentCmd.lua", "w+"))
	f:write("return" .. szValue);
	f:close();
end

function tbUi:RefreshRecentList()
	local fnOnClick = function (index)
		self:DoCommand(self.tbRecentCmd[index]);
	end

	local fnSetItem = function(itemObj, index)
		itemObj.Node:Update(index, self.tbRecentCmd, fnOnClick);
	end

	local len = math.ceil(#self.tbRecentCmd / tbItemUi.nBtnNum);
	self.ScrollView_RecentCmd:Update(len, fnSetItem);
end
 
tbUi.tbOnClick = {};

tbUi.tbOnClick.BtnOK = function (self)
	self.szCmd = self.TxtInfo:GetText();
	local szName = self.SaveInput:GetText();
	self:DoCommand(self.szCmd);

	if szName == szReloadTitle then

		self.tbOnClick.BtnDelete(self);
	else
		self.tbOnClick.BtnSave(self);
	end
end

tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow("Commander");
	Ui:CloseWindow("AssistTools");
end

tbUi.tbOnClick.BtnSave = function (self)
	local name = self.SaveInput:GetText();
	local text = self.TxtInfo:GetText();
	local nChange;
	for i,v in ipairs(self.tbTextList) do
		if v[1] == name then
			nChange = i;
			break;
		end
	end

	if not nChange then
		table.insert(self.tbTextList,1,{name, text});
	elseif nChange > 10 then
		for i = nChange, 2, -1 do
			self.tbTextList[i] = {self.tbTextList[i-1][1],self.tbTextList[i-1][2]};
		end
		self.tbTextList[1] = {name, text};
	else
		self.tbTextList[nChange] = {name, text};
	end

	self:Save();
	self:RefreshList();
end

tbUi.tbOnClick.BtnDelete = function (self)
	local name = self.SaveInput:GetText();
	-- if name == szReloadTitle then
	-- 	self.tbChange = {};
	-- end

	for i,v in ipairs(self.tbTextList) do
		if v[1] == name then
			table.remove(self.tbTextList, i)
			self:RefreshList();
			self:Save();
			break;
		end
	end

	self.SaveInput:SetText("");
	self.TxtInfo:SetText("");
end

--统计功能
tbUi.tbOnClick.BtnStatistic = function (self)
	self:AttribStatistic();
end

-------------属性统计------------------------
function tbUi:AttribStatistic()
	self.tbPlayerAttribs = {};
	self:DoStatistic();
	self:SaveStatistic();
end

function tbUi:DoStatistic()
	local tbEquips = me.GetEquips();
	for nEquipPos, nEquipId in pairs(tbEquips) do
		--Equip BaseAttrib
		local pEquip = KItem.GetItemObj(nEquipId);
		local tbAttribs = KItem.GetEquipBaseProp(pEquip.dwTemplateId).tbBaseAttrib;

		local nStrenLevel =  Strengthen:GetStrengthenLevel(me, nEquipPos);
		for i, tbMA in ipairs(tbAttribs) do
			self:AddMA(tbMA, 1);
			
			--Strengthen Attrib
			if nStrenLevel > 0 and tbMA.szName then
				local tbValue = Strengthen:GetAttribValues(tbMA.szName, nStrenLevel, nEquipPos);--强化这个借口写得有点问题，看要不要改动
				if tbValue then
					local tbStrenMA  = {szName = tbMA.szName, tbValue = tbValue};
					self:AddMA(tbStrenMA, 2);
				end

			end
		end

		--InsetAttrib
		local tbInset = me.GetInsetInfo(nEquipPos);
	    for i, nTemplateId in pairs(tbInset) do
	    	if nTemplateId ~= 0 then
	    		local tbMA = StoneMgr:GetStoneMA(nTemplateId);
	    		for _,v in pairs(tbMA) do
	    			self:AddMA(v, 3);
	    		end
	    	end
	    end

		--EquipRandomAttrib	    
		local tbRandomAttribs = Item.tbRefinement:GetRandomAttrib(pEquip);
		for _, tbAttrib in ipairs(tbRandomAttribs) do
			local tbValue = Item.tbRefinement:GetAttribMA(tbAttrib, pEquip.nItemType);
			local tbMA = 
			{
				szName = tbAttrib.szAttrib,
				tbValue = tbValue,
			}

			self:AddMA(tbMA, 4);
		end
	end

	--StarAttrib
	-- local nStar = StarAttrib:CalcTotalStar(me);
	-- local nStarLevel = StarAttrib:GetStarLevel(nStar);
	-- local tbAttribs = StarAttrib:GetStarMagicAttrib(nStarLevel);
	-- for _, tbMA in pairs(tbAttribs) do
	-- 	self:AddMA(tbMA, 5)
	-- end
end 

function tbUi:AddMA(tbMA, nSrc)
	print("Statistic Add:", tbMA.szName, nSrc);
	self.tbPlayerAttribs[tbMA.szName] = self.tbPlayerAttribs[tbMA.szName] or {};
	
	for i = 1, 3 do
		local nValue = tbMA.tbValue[i] or 0;
		self.tbPlayerAttribs[tbMA.szName][i] = self.tbPlayerAttribs[tbMA.szName][i] or 0;
		self.tbPlayerAttribs[tbMA.szName][i] = self.tbPlayerAttribs[tbMA.szName][i] + nValue;
	end
end

function tbUi:SaveStatistic()
	local szValue = "";
	for szName, tbValue in pairs(self.tbPlayerAttribs) do
		szValue = szValue .. szName .. "\t" .. tbValue[1] .. "\t" .. tbValue[2] .. "\t" .. tbValue[3] .. "\n";
	end

	local f = assert(io.open(g_szUserPath .. "Statistic.tab", "w+"));
	f:write(szValue);
	f:close();	
end


------------多按钮的scrollviewitem------------
tbItemUi.tbOnClick = {};
for i = 1, tbItemUi.nBtnNum do
	tbItemUi.tbOnClick["btn" .. i] = function (self)
		self:OnClick(i);
	end
end

function tbItemUi:OnClick(index)
	self.fnOnClick((self.nIndex - 1) * self.nBtnNum + index);
end

function tbItemUi:Update(index, szCmdList, fnOnClick)
	self.nIndex = index;
	self.fnOnClick = fnOnClick;
	for i = 1, self.nBtnNum do
		local idxInCmdList = (self.nIndex - 1) * self.nBtnNum + i;
		if szCmdList[idxInCmdList] then
			self.pPanel:SetActive("child" .. i, true);
			self.pPanel:Label_SetText("name" .. i, szCmdList[idxInCmdList]);
		else
			self.pPanel:SetActive("child" .. i, false);
		end
	end
end


function tbUi:SearchSaveList(szSearch)
	local tbSaveCommond
	if szSearch == "" then
		tbSaveCommond = self.tbTextList
	else
		tbSaveCommond = self:GetSaveCommondByStr(szSearch)
	end
	if not tbSaveCommond then
		return
	end
	local fnOnSelect = function (buttonObj)
		self.SaveInput:SetText(tbSaveCommond[buttonObj.Index][1]);
		self.TxtInfo:SetText(tbSaveCommond[buttonObj.Index][2]);
	end

	local fnSetItem = function(itemObj, index)
		local data = tbSaveCommond[index];
		itemObj.pPanel:Label_SetText("Name", data[1]);
		itemObj.Index = index;
		itemObj.pPanel.OnTouchEvent = fnOnSelect;
	end
	self.ScrollView:Update(tbSaveCommond, fnSetItem);
end

function tbUi:GetSaveCommondByStr(szSearch)
	local tbCommond = {}
	for index,info in ipairs(self.tbTextList) do
		local szCommond = info[1]
		local isShow = string.find(szCommond, szSearch)
		if isShow then
			table.insert(tbCommond,info)
		end
		
	end
	return tbCommond
end
 
tbUi.tbUiInputOnChange = {};
tbUi.tbUiInputOnChange.Input = function (self)
		local szSearch = self.Input:GetText()
		self:SearchSaveList(szSearch)	
	end

