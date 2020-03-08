--脚本定义的常用基础函数
--范围：主要是数学、字符串、table、文件等方面的操作，与游戏世界无关

Lib.tbTypeOrder = {
	["nil"] = 1, ["number"] = 2, ["string"] = 3, ["userdata"] = 4, ["function"] = 5, ["table"] = 6,
};
Lib.TYPE_COUNT = 6;	-- 类型数量
Lib.tbAwardType	= {"Exp", "Repute", "Money", "Item"};
Lib._tbCommonMetatable	= {
	__index	= function (tb, key)
		return rawget(tb, "_tbBase")[key];
	end;
};

Lib.TB_TIME_DESC	= {
	{"天", 3600 * 24};
	{"小时", 3600};
	{"分钟", 60};
	{"秒", 1};
};

Lib.nRandomSeed = nil; --Lib库随机种子

--设置Lib库随机种子 by.sunduoliang
function Lib:randomseed(nSeed)
	self.nRandomSeed = nSeed;
end

--Lib库的随机函数,只支持正整数随机 by.sunduoliang
--该函数存档一些bug，因为lua语言%的算法问题，会导致有些随机数永远都不会随到。慎用
function Lib:random(nBegin, nEnd)
	self.nRandomSeed = self.nRandomSeed or GetTime();
	self.nRandomSeed = (self.nRandomSeed * 3877 + 29573) % 0xffffffff;
	if nEnd < nBegin then
		nBegin, nEnd  = nEnd, nBegin;
	end
	return nBegin + self.nRandomSeed % (nEnd - nBegin + 1)
end

function Lib:RandomArray(tbArray)
	local nCount = #tbArray;
	if nCount > 1 then
		local tbRand = {unpack(tbArray)};
		for i = 1, nCount do
			local nMax = #tbRand;
			local nRand = MathRandom(nMax)
			tbArray[i] = table.remove(tbRand, nRand)
		end
	end
	return tbArray;
end

-- ON效率 返回一组从1~nMax中，选出nNeed个数字 的随机排列。
function Lib:GetRandomArray(nNeed , nMax)
	if nNeed > nMax then
		Log("nNeed", nNeed, "nMax", nMax)
		Log(debug.traceback())
		return
	end
	local tbAns = {};
	local tbKey = {};
	for i = 0 , nNeed - 1 do
		local nRank = MathRandom(1,nMax - i);
		table.insert(tbAns,tbKey[nRank] or nRank);
		tbKey[nRank] = tbKey[nMax - i] or (nMax - i);
	end
	return tbAns;
end
-- 返回一个函数
-- 此函数 可在 1-nCount 范围内产生一个随机抽取一个数字，当nCount个数字全部抽出时，则再次从 1-nCount 范围内抽取
-- 如:
-- local fn = Lib:GetRandomSelect(3); for i = 9 do print(fn()) end;
-- 则输出循环可能为 1 3 2 2 1 3 1 3 2
function Lib:GetRandomSelect(nCount)
	local tbCurInfo = {};
	return function ()
		if #tbCurInfo <= 0 then
			for i = 1, nCount do
				tbCurInfo[i] = i;
			end
		end

		local nRandom = MathRandom(#tbCurInfo);
		local nIdx = tbCurInfo[nRandom];
		table.remove(tbCurInfo, nRandom);
		return nIdx;
	end
end

function Lib:GetRandomNext(nCount)
	local tbCurInfo = {};
	local fnSelect = self:GetRandomSelect(nCount);
	for i = 1, nCount do
		tbCurInfo[i] = fnSelect();
	end

	local nIdx = 0;
	return function ()
		if nIdx >= nCount then
			nIdx = 0;
		end
		nIdx = nIdx + 1;
		return tbCurInfo[nIdx];
	end
end

--对table进行一层的复制（不遍历下层）
--如果是连续的table，完全可以使用{unpack(tb)}，而不必使用此函数
function Lib:CopyTB1(tb)
	local tbCopy	= {};
	for k, v in pairs(tb) do
		tbCopy[k]	= v;
	end;
	return tbCopy;
end;

function Lib:CopyTB(tb)
	local tbCopy	= {};

	for k, v in pairs(tb) do
		if type(v) == "table" then
			tbCopy[k]	= Lib:CopyTB(v);
		else
			tbCopy[k]	= v;
		end
	end;

	return tbCopy;
end

function Lib:CopySetTB(tbA, tbB)
	for k,v in pairs(tbB) do
		if type(v) == "table" then
			tbA[k] = {};
			Lib:CopySetTB(tbA[k], v);
		else
			tbA[k]	= v;
		end
	end
	return tbA;
end

function Lib:TypeId(szType)
	if self.tbTypeOrder[szType] then
		return self.tbTypeOrder[szType];
	end;
	self.TYPE_COUNT = self.TYPE_COUNT + 1;
	self.tbTypeOrder[szType] = self.TYPE_COUNT;
	return self.TYPE_COUNT;
end;

function Lib:ShowTB1(tbVar, szBlank)
	if (not szBlank) then
		szBlank = "";
	end;
	for k, v in pairs(tbVar) do
		print(szBlank.."["..self:Val2Str(k).."]	= "..tostring(v));
	end;
end;

function Lib:ShowTB(tbVar, szBlank, nCount)
	if (not szBlank) then
		szBlank = "";
	end;
	nCount = nCount or 0;
	if nCount > 10000 then
		print("ERROE~~ 层数太多，超过了1万次，防止死循环！！！！");
		return 0;
	end
	local tbType = {};
	for k, v in pairs(tbVar) do
		local nType = self:TypeId(type(v));
		if (not tbType[nType]) then
			tbType[nType] = {n = 0, name = type(v)};
		end;
		local tbTmp = tbType[nType];
		tbTmp.n = tbTmp.n + 1;
		tbTmp[tbTmp.n] = k;
	end;
	for i = 1, self.TYPE_COUNT do
		if tbType[i] then
			local tbTmp = tbType[i];
			local szType = tbTmp.name;
			--print(">"..szType..":")
			table.sort(tbTmp);
			for i = 1, tbTmp.n do
				local key = tbTmp[i];
				local value = tbVar[key];
				local str;
				if (type(key) == "number") then
					str = szBlank.."["..key.."]";
				else
					str = szBlank.."."..key;
				end;
				if (szType == "nil") then
					print(str.."\t= nil");
				elseif (szType == "number") then
					print(str.."\t= "..tbVar[key]);
				elseif (szType == "string") then
					print(str..'\t= "'..tbVar[key]..'"');
				elseif (szType == "function") then
					print(str.."()");
				elseif (szType == "table") then
					if (tbVar[key] == tbVar) then
						print(str.."\t= {...}(self)");
					else
						print(str..":");
						self:ShowTB(tbVar[key], str, nCount+1);
					end;
				elseif (szType == "userdata") then
					print(str.."*");
				else
					print(str.."\t= "..tostring(tbVar[key]));
				end;
			end;
		end;
	end;
end;

function Lib:LogTB(tbVar, szBlank, nCount)
	if (not szBlank) then
		szBlank = "";
	end;
	nCount = nCount or 0;
	if nCount > 10000 then
		Log("ERROE~~ 层数太多，超过了1万次，防止死循环！！！！");
		return 0;
	end
	local tbType = {};
	for k, v in pairs(tbVar) do
		local nType = self:TypeId(type(v));
		if (not tbType[nType]) then
			tbType[nType] = {n = 0, name = type(v)};
		end;
		local tbTmp = tbType[nType];
		tbTmp.n = tbTmp.n + 1;
		tbTmp[tbTmp.n] = k;
	end;
	for i = 1, self.TYPE_COUNT do
		if tbType[i] then
			local tbTmp = tbType[i];
			local szType = tbTmp.name;
			--print(">"..szType..":")
			table.sort(tbTmp);
			for i = 1, tbTmp.n do
				local key = tbTmp[i];
				local value = tbVar[key];
				local str;
				if (type(key) == "number") then
					str = szBlank.."["..key.."]";
				else
					str = szBlank.."."..key;
				end;
				if (szType == "nil") then
					Log(str.."\t= nil");
				elseif (szType == "number") then
					Log(str.."\t= "..tbVar[key]);
				elseif (szType == "string") then
					Log(str..'\t= "'..tbVar[key]..'"');
				elseif (szType == "function") then
					Log(str.."()");
				elseif (szType == "table") then
					if (tbVar[key] == tbVar) then
						Log(str.."\t= {...}(self)");
					else
						Log(str..":");
						self:LogTB(tbVar[key], str, nCount+1);
					end;
				elseif (szType == "userdata") then
					Log(str.."*");
				else
					Log(str.."\t= "..tostring(tbVar[key]));
				end;
			end;
		end;
	end;
end;

function Lib:LogData(...)
	local arg = {...};

	for _, value in ipairs(arg) do
		if type(value) == "table" then
			Lib:LogTB(value);
			Log("----------------------------");
		else
			Log(value);
		end
	end
end

-- 比较两个table是否相同（用于key相同的表）
function Lib:CompareTB(tableA, tableB)
	for k,v in pairs(tableA) do
		if tableB[k] ~= v then
			return false;
		end
	end

	return true;
end

function Lib:CompareArray(tableA, tableB)
	if #tableA ~= #tableB then
		return false
	end
	for i,v in ipairs(tableA) do
		if tableB[i] ~= v then
			return false
		end
	end
	return true
end

function Lib:CountTB(tbVar)
	local nCount = 0;
	for _, _ in pairs(tbVar) do
		nCount	= nCount + 1;
	end;
	return nCount;
end;

function Lib:HaveCountTB(tbVar)
	for _, _ in pairs(tbVar) do
		return true;
	end;

	return false;
end;

-- 合并2个表，用于下标默认的表
function Lib:MergeTable(tableA, tableB)
	for _, item in ipairs(tableB) do
		tableA[#tableA + 1] = item;
	end

	return tableA;
end;

-- 合并2个表，返回顺序表
function Lib:MergeMapTable(tableA, tableB)
	local tbSeq = {}
	local tbMap = {tableA, tableB}
	for _, item in pairs(tbMap) do
		for _, v in pairs(item) do
			table.insert(tbSeq, v)
		end
	end

	return tbSeq;
end;

-- 根据第一层key合并2个表，第二层是连续的
function Lib:MergeSameKeyTable(tableA, tableB)
	for key, item in pairs(tableB) do
		tableA[key] = Lib:MergeTable(tableA[key] or {}, item)
	end

	return tableA;
end;

function Lib:StrVal2Str(szVal)
	szVal	= string.gsub(szVal, "\\", "\\\\");
	szVal	= string.gsub(szVal, '"', '\\"');
	szVal	= string.gsub(szVal, "\n", "\\n");
	szVal	= string.gsub(szVal, "\r", "\\r");
	--szVal	= string.format("%q", szVal);
	return '"'..szVal..'"';
end;

-- 过滤字符串中的指定字符
-- tbReplacedChars是所有要被过滤的字符table
-- szReplaceWith是用来替换过滤字符的字符，默认为空字符
function Lib:StrFilterChars(szOrg, tbReplacedChars, szReplaceWith)
	szReplaceWith = szReplaceWith or ""
	local szTmp = szOrg
	for _,c in pairs(tbReplacedChars) do
		c = string.gsub(c, '[().%+%-%*?[^$]', function(s) return "%"..s end)
		szTmp = string.gsub(szTmp, c, szReplaceWith)
	end
	return szTmp
end

-- 去除指定字符串中的颜色标记: [color]xxx[-] -> xxx
function Lib:StrTrimColorMark(szOrg)
	return string.gsub(szOrg, "%[[^%[%]]*%]", "")
end

-- 去除指定字符串首尾指定字符
function Lib:StrTrim(szDes, szTrimChar)
	if (not szTrimChar) then
		szTrimChar = " ";
	end

	if (string.len(szTrimChar) ~= 1) then
		return szDes;
	end

	local szRet, nCount = string.gsub(szDes, "("..szTrimChar.."*)([^"..szTrimChar.."]*.*[^"..szTrimChar.."])("..szTrimChar.."*)", "%2");
	if (nCount == 0) then
		return "";
	end

	return szRet;
end


function Lib:Val2Str(var, szBlank)
	local szType	= type(var);
	if (szType == "nil") then
		return "nil";
	elseif (szType == "number") then
		return tostring(var);
	elseif (szType == "string") then
		return self:StrVal2Str(var);
	elseif (szType == "function") then
		local szCode	= string.dump(var);
		local arByte	= {string.byte(szCode, i, #szCode)};
		szCode	= "";
		for i = 1, #arByte do
			szCode	= szCode..'\\'..arByte[i];
		end;
		return 'loadstring("' .. szCode .. '")';
	elseif (szType == "table") then
		if not szBlank then
			szBlank	= "";
		end;
		local szTbBlank	= szBlank .. "  ";
		local szCode	= "";
		for k, v in pairs(var) do
			local szPair	= szTbBlank.."[" .. self:Val2Str(k) .. "]	= " .. self:Val2Str(v, szTbBlank) .. ",\n";
			szCode	= szCode .. szPair;
		end;
		if (szCode == "") then
			return "{}";
		else
			return "\n"..szBlank.."{\n"..szCode..szBlank.."}";
		end;
	elseif szType == "boolean" then
		return var and "true" or "false";
	else	--if (szType == "userdata") then
		return '"' .. tostring(var) .. '"';
	end;
end;

function Lib:Str2Val(szVal)
	return assert(loadstring("return "..szVal))();
end;


function Lib:NewClass(tbBase, ...)
	local arg = {...};
	local tbNew	= { _tbBase = tbBase };							-- 基类
	setmetatable(tbNew, self._tbCommonMetatable);
	local tbRoot = tbNew;
	local tbInit = {};
	repeat										-- 寻找最基基类
		tbRoot = rawget(tbRoot, "_tbBase");
		local fnInit = rawget(tbRoot, "init");
		if (type(fnInit) == "function") then
			table.insert(tbInit, fnInit);		-- 放入构造函数栈
		end
	until (not rawget(tbRoot, "_tbBase"));
	for i = #tbInit, 1, -1 do
		local fnInit = tbInit[i];
		if fnInit then
			fnInit(tbNew, unpack(arg));			-- 从底向上调用构造函数
		end
	end
	return tbNew;
end

function Lib:ConcatStr(tbStrElem, szSep)
	if (not szSep) then
		szSep = ",";
	end
	return table.concat(tbStrElem, szSep);
end

function Lib:ConcatKeys(tb, szSep)
	if (not szSep) then
		szSep = ",";
	end

	local tbList = {};
	for k,v in pairs(tb) do
		table.insert(tbList, k);
	end

	return table.concat(tbList, szSep);
end

function Lib:SplitStr(szStrConcat, szSep)
	if (not szSep) then
		szSep = ",";
	end;
	local tbStrElem = {};

	--特殊转义字符指定长度
	local tbSpeSep = {
		["%."] = 1;
	};

	local nSepLen = tbSpeSep[szSep] or #szSep;
	local nStart = 1;
	local nAt = string.find(szStrConcat, szSep);
	while nAt do
		tbStrElem[#tbStrElem+1] = string.sub(szStrConcat, nStart, nAt - 1);
		nStart = nAt + nSepLen;
		nAt = string.find(szStrConcat, szSep, nStart);
	end
	tbStrElem[#tbStrElem+1] = string.sub(szStrConcat, nStart);
	return tbStrElem;
end

function Lib:GetTableFromString(szValue, bKeyNotNumber, bValueNotNumber)
	local tbResult = {};
	local tbLines = Lib:SplitStr(szValue, ";");
	for _, szCell in ipairs(tbLines) do
		if szCell ~= "" then
			local Key, Value = string.match(szCell, "^([^|]+)|([^|]+)$");
			if not Key then
				return;
			end

			if not bKeyNotNumber then
				Key = tonumber(Key)
			end
			if not bValueNotNumber then
				Value = tonumber(Value);
			end

			if not Key or not Value then
				return;
			end

			tbResult[Key] = Value;
		end
	end

	return tbResult;
end

--TODO 缺的自己加上去
function Lib:GetAwardDesCount(tbAllAward, pPlayer)
	local nFaction = pPlayer.nFaction;
	local nSex = pPlayer.nSex;
	local tbAwardDes = {};
	for nIndex, tbAward in pairs(tbAllAward) do
		local tbDes = {};
		local szAwardType = tbAward[1];
		local nAwardType = Player.AwardType[tbAward[1]];
		if nAwardType == Player.award_type_item or nAwardType == Player.award_type_collect_clue then
			local szName = Item:GetItemTemplateShowInfo(tbAward[2], nFaction, nSex);
			tbDes.szName = szName;
			tbDes.szDesc = string.format("%s:%s", szName, tbAward[3]);
		elseif nAwardType == Player.award_type_money then
			local szName, szMoneyEmotion = Shop:GetMoneyName(szAwardType);
			tbDes.szName = szName;
			tbDes.szDesc = string.format("%s:%s", szName, tbAward[2]);
			if szMoneyEmotion and szMoneyEmotion ~= "" then
				tbDes.szEmotionDesc = string.format("%s%s:%s", szMoneyEmotion, szName, tbAward[2]);
			end
		elseif nAwardType == Player.award_type_kin_found then
			tbDes.szName = "家族资金";
			tbDes.szDesc = string.format("家族资金%s两", tbAward[2]);
		elseif nAwardType == Player.award_type_equip_debris then
			local szName = Item:GetItemTemplateShowInfo(tbAward[2], nFaction, nSex)
			tbDes.szName = string.format("%s碎片", szName);
			tbDes.szDesc = string.format("%s碎片:1", szName);
		elseif nAwardType == Player.award_type_basic_exp then
			tbDes.szName = "经验";
			local nCount = tbAward[2] * pPlayer.GetBaseAwardExp();
			if pPlayer.TrueChangeExp then
				nCount = pPlayer.TrueChangeExp(nCount);
			end
			tbDes.szDesc = string.format("经验%s点", nCount);
		elseif nAwardType == Player.award_type_faction_honor then
			tbDes.szName = "门派荣誉";
			tbDes.szDesc = string.format("门派荣誉%s点", tbAward[2]);
		elseif nAwardType == Player.award_type_battle_honor or nAwardType == Player.award_type_battle_honor2 then
			tbDes.szName = "战场荣誉";
			tbDes.szDesc = string.format("战场荣誉%s点", tbAward[2]);
		end

		local nHave = Lib:CountTB(tbDes);
		if nHave > 0 then
			tbAwardDes[nIndex] = tbDes;
		end
	end

	return tbAwardDes;
end

function Lib:GetAwardDesCount2(tbAllAward, pPlayer)
	local nFaction = pPlayer and pPlayer.nFaction or 0;
	local nSex = pPlayer and pPlayer.nSex or 0;
	local tbMsgs = {};
	for i,v in ipairs(tbAllAward) do
		local szMsg = ""
		local nAwardType = Player.AwardType[v[1]];
		if nAwardType == Player.award_type_item then
			local szName = Item:GetItemTemplateShowInfo(v[2], nFaction, nSex)
			if v[3] == 1 then
				szMsg = szName
			else
				szMsg = string.format("%s*%d", szName, v[3])
			end
		elseif nAwardType == Player.award_type_money then
			local szName = Shop:GetMoneyName(v[1]);
			szMsg = string.format("%d%s", v[2], szName)
		else
			szMsg = "其他奖励"
		end
		table.insert(tbMsgs, szMsg)
	end
	return tbMsgs
end

function Lib:Str2LunStr(szTxtStr)
    local szLunStr = string.gsub(szTxtStr, "\\n", "\n");
    return szLunStr;
end

function Lib:GetAwardFromString(szAwardInfo)
	local tbResult = {};
	szAwardInfo = string.gsub(szAwardInfo, "\"", "");
	local tbLines = Lib:SplitStr(szAwardInfo, ";");
	if tbLines[#tbLines] == "" then
		tbLines[#tbLines] = nil;
	end

	if not tbLines or #tbLines < 1 then
		--Log("Lib:GetAwardFromString(szAwardInfo) fail ?? ", szAwardInfo);
		return {};
	end

	for _, szCell in ipairs(tbLines) do
		if szCell ~= "" then
			local tbItemInfo = Lib:SplitStr(szCell, "|");
			if tbItemInfo[#tbItemInfo] == "" then
				tbItemInfo[#tbItemInfo] = nil;
			end

			if tbItemInfo and #tbItemInfo >= 2 then
				for k, v in ipairs(tbItemInfo) do
					local nv = tonumber(v);
					if nv then
						tbItemInfo[k] = nv;
					end
				end
				table.insert(tbResult, tbItemInfo);
			--else
			--	Log("Lib:GetAwardFromString(szAwardInfo) fail ?? ", szCell, szAwardInfo);
			end
		end
	end
	return tbResult;
end

function Lib:IsTrue(var)
	return (var ~= nil and var ~= 0 and var ~= false and var ~= "false" and var ~= "");
end;

function Lib:IsEmptyStr(var)
    if type(var) ~= "string" or var == "" or var == " " then
        return true;
    end

    return false;
end

function Lib:AnalyzeParamStrOne(szParamInfo)
    if Lib:IsEmptyStr(szParamInfo) then
        return {};
    end

    local tbParam = Lib:AnalyzeParamStr(szParamInfo);
    local tbResult = {};
    for _, tbInfo in pairs(tbParam) do
        tbResult[tbInfo[1]] = tbInfo[2];
    end

    return tbResult;
end

function Lib:AnalyzeParamStr(szParamInfo)
    if Lib:IsEmptyStr(szParamInfo) then
        return {};
    end

    local tbResult = {};
    szParamInfo = string.gsub(szParamInfo, "\"", "");
    local tbLines = Lib:SplitStr(szParamInfo, ";");
    if tbLines[#tbLines] == "" then
        tbLines[#tbLines] = nil;
    end

    if not tbLines or #tbLines < 1 then
        return {};
    end

    for _, szCell in ipairs(tbLines) do
        if not Lib:IsEmptyStr(szCell) then
            local tbItemInfo = Lib:SplitStr(szCell, "|");
            if tbItemInfo[#tbItemInfo] == "" then
                tbItemInfo[#tbItemInfo] = nil;
            end

            for k, v in ipairs(tbItemInfo) do
                local nv = tonumber(v);
                if nv then
                    tbItemInfo[k] = nv;
                end
            end

            if #tbItemInfo >= 1 then
            	table.insert(tbResult, tbItemInfo);
            end
        end
    end
    return tbResult;
end

-- 按照统一的格式回调函数
function Lib:CallBack(tbCallBack)
	local varFunc	= tbCallBack[1];
	local szType	= type(varFunc);

	local function InnerCall()
		if (szType == "function") then	-- 直接指定了函数及参数
			return	tbCallBack[1](unpack(tbCallBack, 2));
		elseif (szType == "string") then	-- 按照字符串的方式指定了函数
			local fnFunc, tbSelf	= KLib.GetValByStr(varFunc);
			if (fnFunc) then
				if (tbSelf) then
					return fnFunc(tbSelf, unpack(tbCallBack, 2));
				else
					return fnFunc(unpack(tbCallBack, 2));
				end;
			else
				return false, "Wrong name string : "..varFunc;
			end;
		else
			local szErrMsg = " ERR : tbCallBack[1] is not function or string, type is "..szType
			Log(szErrMsg)
			Log(debug.traceback())
			return false, szErrMsg
		end;
	end

	local tbRet	= {xpcall(InnerCall, Lib.ShowStack)};

	return unpack(tbRet);
end;

function Lib:MergeCallBack(tbCallBack, ...)
    local tbCall = {unpack(tbCallBack)};
    local tbArg  = {...}
    Lib:MergeTable(tbCall, tbArg);
    return Lib:CallBack(tbCall); -- 调用回调
end

function Lib.ShowStack(s)
	Log(debug.traceback(s,2));
	return s;
end

-- 检查一个Table是否另一个Table的派生Table
function Lib:IsDerived(tbThis, tbBase)
	if (not tbThis) or (not tbBase) then
		return	0;
	end;
	repeat
		local pBase = rawget(tbThis, "_tbBase");
		if (pBase == tbBase) then
			return	1;
		end
		tbThis = pBase;
	until (not tbThis);
	return	0;
end

-- 得到当天0点0时的秒数
function Lib:GetTodayZeroHour(nTime)
    local nTimeNow = nTime or GetTime();
    local tbTime = os.date("*t", nTimeNow);

    return nTimeNow - (tbTime.hour * 3600 + tbTime.min * 60 + tbTime.sec);
end

-- 今周过的多少秒
function Lib:GetLocalWeekTime(nTime)
    local nTimeNow  = nTime or GetTime();
    local nW        = tonumber(os.date("%w", nTimeNow));
    local tbTime    = os.date("*t", nTimeNow);
    if nW == 0 then
        nW = 7;
    end

    nW = nW - 1;
    return nW * 86400 + tbTime.hour * 3600 + tbTime.min * 60 + tbTime.sec;
end

-- 功能:	把秒数转换为 nHour小时，nMinute分钟, nSecond秒
-- 参数:	nSecondTime秒
-- 返回值:	nHour小时，nMinute分钟, nSecond秒
function Lib:TransferSecond2NormalTime(nSecondTime)
	local nHour, nMinute, nSecond = 0, 0, 0;

	if (nSecondTime >= 3600) then
		nHour = math.floor(nSecondTime / 3600);
		nSecondTime = math.floor(nSecondTime % 3600)
	end

	if (nSecondTime >= 60) then
		nMinute = math.floor(nSecondTime / 60);
		nSecondTime = math.floor(nSecondTime % 60)
	end
	nSecond	= math.floor(nSecondTime);
	return nHour, nMinute, nSecond;
end

-- 功能:	把一个长度不超过4位的阿拉伯数字整数转化成为中文数字
-- 参数:	nDigit, (0 <= nDigit) and (nDigit < 10000)
-- 返回值:	中文数字
function Lib:Transfer4LenDigit2CnNum(nDigit)
	if version_vn then
		--越南版不做转化
		return tostring(nDigit)
	end

	local tbCnNum  = self.tbCnNum;
	if not tbCnNum then
		tbCnNum =
		{
			[1] 	= "一",
			[2]	 	= "二",
			[3]		= "三",
			[4]		= "四",
			[5] 	= "五",
			[6]		= "六",
			[7] 	= "七",
			[8]		= "八",
			[9] 	= "九",
		};
		self.tbCnNum = tbCnNum;
	end
	local tb4LenCnNum = self.tb4LenCnNum;
	if not tb4LenCnNum then
		tb4LenCnNum =
		{
			[1]		= "",
			[2]		= "十",
			[3]		= "百",
			[4]		= "千",
		};
		self.tb4LenCnNum = tb4LenCnNum;
	end

	local nDigitTmp	= nDigit;			-- 临时变量
	local nModel	= 0;				-- nDigit中每一位数字的值
	local nPreNum	= 0;				-- nDigit低一位数字的值
	local bOneEver	= false;			-- 做标记,当前是否出现过不为0的值
	local szCnNum	= "";				-- 保存中文数字的变量
	local szNumTmp	= "";				-- 临时变量

	if (nDigit == 0) then
		return;
	end

	if (nDigit >= 10 and nDigit < 20) then
		if (nDigit == 10) then
			szCnNum = tb4LenCnNum[2];
		else
			szCnNum = tb4LenCnNum[2]..tbCnNum[math.floor(nDigit % 10)];
		end
		return szCnNum;
	end

	for i = 1, #tb4LenCnNum do
		szNumTmp	= "";
		nModel		= math.floor(nDigitTmp % 10);	-- 取得nDigit当前位上的值
		if (nModel ~= 0) then
			szNumTmp = szNumTmp..tbCnNum[nModel]..tb4LenCnNum[i];
			if (nPreNum == 0 and bOneEver) then
				szNumTmp = szNumTmp.."零";
			end
			bOneEver = true;
		end
		szCnNum	= szNumTmp..szCnNum;

		nPreNum	= nModel;
		nDigitTmp	= math.floor(nDigitTmp / 10);
		if (nDigitTmp == 0) then
			break;
		end
	end

	return szCnNum;
end

-- 功能:	把一个阿拉伯数字nDigit转化成为中文数字
-- 参数:	nDigit,nDigit是整数,并且(1万亿 > nDigit) and (nDigit > -1万亿)
-- 返回值:	中文数字
function Lib:TransferDigit2CnNum(nDigit)
	local tbModelUnit = {
		[1]	= "";
		[2]	= "万";
		[3] = "亿";
	};

	local nDigitTmp = nDigit;	-- 临时变量,
	local n4LenNum	= 0;		-- 每一次对nDigit取4位操作,n4LenNum表示取出来的数的值
	local nPreNum	= 0;		-- 记录前一次进行取4位操作的n4LenNum的值
	local szCnNum	= "";		-- 就是所要求的结果
	local szNumTmp	= "";		-- 临时变量,每取四位的操作中得到的中文数字

	if (nDigit == 0) then
		szCnNum = "零";
		return szCnNum;
	end

	if (nDigit < 0) then
		nDigitTmp = math.floor(nDigit * (-1));
		szCnNum	  = "负";
	end

	-- 分别从个,万,亿三段考虑,因为nDigit的值小于1万亿,所以每一段都不超过4位
	for i = 1, #tbModelUnit do
		szNumTmp	= "";
		n4LenNum	= math.floor(nDigitTmp % 10000);
		if (n4LenNum ~= 0) then
			szNumTmp = self:Transfer4LenDigit2CnNum(n4LenNum);					-- 得到该四位的中文表达式
			szNumTmp = szNumTmp..tbModelUnit[i];								-- 加上单位
			if ((nPreNum > 0 and nPreNum < 1000) or								-- 两个数字之间有0,所以要加"零"
				(math.floor(n4LenNum % 10) == 0 and i > 1)) then
				szNumTmp	= szNumTmp.."零";
			end
		end
		szCnNum	= szNumTmp..szCnNum;

		nPreNum	= n4LenNum;
		nDigitTmp = math.floor(nDigitTmp / 10000);
		if (nDigitTmp == 0) then
			break;
		end
	end

	return szCnNum;
end

function  Lib:ThousandSplit(nDigit)
	local szMinus = nDigit > 0 and "" or "-"
	nDigit = math.abs(nDigit)
	local n3T = math.floor(nDigit / 1000000);
	local n2T = math.floor((nDigit % 1000000) / 1000);
	local n1T = nDigit % 1000
	if n3T ~= 0 then
		return string.format("%s%d,%03d,%03d", szMinus, n3T, n2T, n1T)
	elseif n2T ~= 0 then
		return string.format("%s%d,%03d", szMinus, n2T, n1T)
	else
		return string.format("%s%d", szMinus, n1T)
	end
end

-- 功能:	把阿拉伯数字表示的小时转换成中文的小时
-- 参数:	nHour,小时,(1万亿 > nHour) and (nHour > -1万亿)
-- 返回值:	szXiaoshi小时
function Lib:GetCnTime(nHour)
	local szXiaoshi	= "";
	local szShichen	= "";
	local nDigit	= math.floor(nHour);

	if (nHour - nDigit == 0.5 and nDigit > 0) then
		szXiaoshi	= self:TransferDigit2CnNum(nDigit).."个半小时";
	elseif (nHour - nDigit == 0.5) then
		szXiaoshi	= "半个小时";
	else
		szXiaoshi	= self:TransferDigit2CnNum(nDigit).."个小时";
	end

	return szXiaoshi;
end

-- 将秒数转为时间描述字符串，短描述
function Lib:TimeDesc(nSec)
	nSec = math.max(0, nSec)
	if (nSec < 60) then
		return string.format("%d秒", nSec);
	elseif (nSec < 3600) then	-- 小于1小时
		return string.format("%d分%d秒", nSec / 60, math.mod(nSec, 60));
	elseif (nSec < 3600 * 24) then	-- 小于1天
		return  string.format( nSec % 3600 == 0 and "%d小时" or "%.1f小时", nSec / 3600)
	else
		return string.format(nSec % (3600 * 24) == 0 and "%d天" or "%.1f天", nSec / (3600 * 24));
	end
end

function Lib:TimeDesc2(nSec)
	local nDaySec = 3600*24
	if (nSec < 3600) then	-- 小于1小时
		return string.format("%d分%d秒", nSec / 60, math.mod(nSec, 60));
	elseif (nSec < nDaySec) then	-- 小于1天
		return string.format("%d小时%d分", nSec / 3600, (nSec % 3600) / 60);
	else
		local nSecLeft = nSec % nDaySec
		if nSecLeft==0 then
			return string.format("%d天", nSec / nDaySec);
		else
			return string.format("%d天%d小时", nSec / nDaySec, nSecLeft / 3600);
		end
	end
end

function Lib:TimeDesc3(nSec)
	if nSec < 3600 then
		return string.format("%02d:%02d", nSec % 3600 / 60, nSec % 60);
	else
		return string.format("%02d:%02d:%02d", nSec / 3600, nSec % 3600 / 60, nSec % 60);
	end
end

function Lib:TimeDesc4(nSec)
	if nSec < 60 then
		return string.format("%d\"", nSec % 60);
	else
		return string.format("%d\'%d\"", nSec / 60, nSec % 60);
	end
end

function Lib:TimeDesc5(nSec)
	local nHour,nMin = self:TransferSecond2NormalTime(nSec)

	if nHour > 0 then
		if math.floor(nHour / 24) > 0 then
			return string.format("%d天%d小时%d分",math.floor(nHour / 24),nHour % 24 ,nMin);
		else
			return string.format("%d小时%d分",nHour,nMin);
		end
	end

	return string.format("%d分",nMin);
end



-- 将秒数转为时间描述字符串，短描述
function Lib:TimeDesc6(nSec)
	nSec = math.max(0, nSec)
	if (nSec < 60) then
		return string.format("%d秒", nSec);
	elseif (nSec < 3600) then	-- 小于1小时
		return string.format("%d分%d秒", nSec / 60, math.mod(nSec, 60))
	elseif (nSec < 3600 * 24) then	-- 小于1天
		return  string.format("%d小时", math.floor(nSec / 3600))
	else
		return string.format("%d天", math.floor(nSec/(3600 * 24)))
	end
end

function Lib:TimeDesc7(nTime)
	nTime = math.max(0, nTime)
	local tbTime    = os.date("*t", nTime);
	return string.format("%s年%s月%s日%s点",tbTime.year,tbTime.month,tbTime.day,tbTime.hour)

end

function Lib:TimeDesc8(nSec)
	local nHour,nMin = self:TransferSecond2NormalTime(nSec)

	if nHour > 0 then
		return string.format("%d小时%d分",nHour,nMin);
	end

	return string.format("%d分",nMin);
end

function Lib:TimeDesc9(nTime)
	nTime = math.max(0, nTime)
	local tbTime    = os.date("*t", nTime);
	return string.format("%s年%s月%s日%s点%s分%s秒",tbTime.year,tbTime.month,tbTime.day,tbTime.hour,tbTime.min,tbTime.sec)
end

function Lib:TimeDesc10(nTime)
	nTime = math.max(0, nTime)
	local tbTime    = os.date("*t", nTime);
	return string.format("%s月%s日%s点",tbTime.month,tbTime.day,tbTime.hour)
end

function Lib:TimeDesc11(nTime)
	nTime = math.max(0, nTime);
	local tbTime    = os.date("*t", nTime);
	return string.format("%s年%s月%s日",tbTime.year,tbTime.month,tbTime.day);
end

function Lib:TimeDesc12(nSec)
	nSec = math.max(0, nSec)
	if (nSec < 60) then
		return string.format("%d秒", nSec);
	elseif (nSec < 3600) then	-- 小于1小时
		return string.format("%d分%d秒", nSec / 60, math.mod(nSec, 60))
	elseif (nSec < 3600 * 24) then	-- 小于1天
		return  string.format("%d时%d分%d秒", math.floor(nSec / 3600), math.mod(nSec, 3600) / 60, math.mod(math.mod(nSec, 3600), 60))
	else
		return string.format("%d天", math.floor(nSec/(3600 * 24)))
	end
end

function Lib:TimeDesc13(nSec)
	nSec = math.max(0, nSec)
	if (nSec < 3600) then	-- 小于1小时
		return string.format("%d分", nSec / 60);
	elseif (nSec < 3600 * 24) then	-- 小于1天
		return  string.format("%d小时", math.floor(nSec / 3600))
	else
		return string.format("%d天", math.ceil(nSec/(3600 * 24)));
	end
end

function Lib:TimeDesc14(nTime)
	nTime = math.max(0, nTime);
	local tbTime    = os.date("*t", nTime);
	return string.format("%s月%s日",tbTime.month,tbTime.day);
end

function Lib:TimeDesc15(nSec)
	nSec = math.max(0, nSec)
	local nDaySec = 86400;
	if (nSec < 60) then
		return string.format("%d秒", nSec);
	elseif (nSec < 3600) then	-- 小于1小时
		return string.format("%d分%d秒", nSec / 60, math.mod(nSec, 60));
	elseif (nSec < nDaySec) then	-- 小于1天
		return string.format("%d小时%d分", nSec / 3600, (nSec % 3600) / 60);
	else
		local nHourLeft = math.floor((nSec % nDaySec) / 3600);
		if nHourLeft==0 then
			return string.format("%d天", nSec / nDaySec);
		else
			return string.format("%d天%d小时", nSec / nDaySec, nHourLeft);
		end
	end
end

function Lib:TimeDesc16(nSec)
	local nHour,nMin = self:TransferSecond2NormalTime(nSec)

	if nHour > 0 then
		if math.floor(nHour / 24) > 0 then
			return string.format("%d天%d小时",math.floor(nHour / 24),nHour % 24);
		else
			return string.format("%d小时%d分",nHour,nMin);
		end
	end

	return string.format("%d分",nMin);
end

function Lib:TimeDesc17(nTime)
	nTime = math.max(0, nTime)
	local tbTime    = os.date("*t", nTime);
	return string.format("%s月%s日%s点%s分",tbTime.month,tbTime.day,tbTime.hour,tbTime.min)
end

-- 将秒数转为时间描述字符串，精确值
function Lib:TimeFullDesc(nSec, nPrecision)
	local nMaxLevel = #self.TB_TIME_DESC;
	nPrecision = nPrecision or nMaxLevel;

	local szMsg	= "";
	local nLastLevel = nMaxLevel;
	for nLevel = 1, nMaxLevel do
		local tbTimeDesc = self.TB_TIME_DESC[nLevel];
		local nUnit	= tbTimeDesc[2];
		if (nSec >= nUnit or (nUnit == 1 and szMsg == "")) then
			if (nLevel > nLastLevel + 1) then
				szMsg = szMsg .. "零";
			end
			szMsg	= szMsg .. math.floor(nSec / nUnit) .. tbTimeDesc[1];
			nSec	= math.mod(nSec, nUnit);
			nLastLevel = nLevel;

			nPrecision = nPrecision - 1;
			if nPrecision <= 0 then
				break;
			end
		end
	end
	return szMsg;
end

-- 将秒数转为时间描述字符串，精确值
function Lib:TimeFullDescEx(nSec)
	local szMsg	= "";
	local nLastLevel	= #self.TB_TIME_DESC;
	for nLevel, tbTimeDesc in ipairs(self.TB_TIME_DESC) do
		local nUnit	= tbTimeDesc[2];
		if (nSec >= nUnit or (nUnit == 1 and szMsg == "")) then
			if (nLevel > nLastLevel + 1) then
				szMsg	= szMsg .. "零";
			end
			szMsg	= szMsg .. string.format("%02d" .. tbTimeDesc[1], math.floor(nSec / nUnit));
			nSec	= math.mod(nSec, nUnit);
			nLastLevel	= nLevel;
		end
	end
	return szMsg;
end

-- 将游戏桢数转换为时间描述字符串
function Lib:FrameTimeDesc(nFrame)
	local nSec	= math.floor(nFrame / Env.GAME_FPS);
	return self:TimeDesc(nSec);
end

-- 将TabFile一次性载入，并返回一个数据table
--	数据以第一行为依据形成列名，返回值形如：
--	{
--		[nRow]	= {[szCol] = szValue, [szCol] = szValue, ...},
--		[nRow]	= {[szCol] = szValue, [szCol] = szValue, ...},
--		...
--	}
function Lib:LoadTabFile(szFileName, tbNumColName, bOutsidePackage)
	local tbData	= KLib.LoadTabFile(szFileName, 1, bOutsidePackage or 0);
	if (not tbData) then	-- 未能读取到
		return;
	end
	tbNumColName	= tbNumColName or {};
	local tbColName	= tbData[1];
	tbData[1]	= nil;
	local tbRet	= {};
	for nRow, tbDataRow in pairs(tbData) do
		local tbRow	= {}
		tbRet[nRow - 1]	= tbRow;
		for nCol, szName in pairs(tbColName) do
			if (tbNumColName[szName]) then
				tbRow[szName]	= tonumber(tbDataRow[nCol]) or 0;
			else
				tbRow[szName]	= tbDataRow[nCol];
			end
		end
	end


	return tbRet;
end

-- 将IniFile一次性载入，并返回一个数据table
--	以[Section]为第一级table下标，Key为第二级table下标，形如：
--	{
--		[szSection]	= {[szKey] = szValue, [szKey] = szValue, ...},
--		[szSection]	= {[szKey] = szValue, [szKey] = szValue, ...},
--		...
--	}
function Lib:LoadIniFile(szFileName, nTranslateFlag, nOutSidePack)
	if nTranslateFlag == nil then
		nTranslateFlag = 1
	end

	if nOutSidePack == nil then
		nOutSidePack = 0
	end

	return KLib.LoadIniFile(szFileName, nTranslateFlag, nOutSidePack);
end

-- 随机打乱一个连续的Table
function Lib:SmashTable(tb)
	local nLen	= #tb;
	for n, value in pairs(tb) do
		local nRand = MathRandom(nLen);
		tb[n]		= tb[nRand];
		tb[nRand]	= value;
	end
end

-- 是否为空的table
function Lib:IsEmptyTB(tb)
    return type(tb) == "table" and _G.next( tb ) == nil;
end

-- 获得一个32位数中指定位段(0~31)所表示的整数
function Lib:LoadBits(nInt32, nBegin, nEnd)
	if (nBegin > nEnd) then
		local _ = nBegin;
		nBegin = nEnd;
		nEnd   = _;
	end
	if (nBegin < 0) or (nEnd >= 32) then
		return 0;
	end
	nInt32 = nInt32 % (2 ^ (nEnd + 1));
	nInt32 = nInt32 / (2 ^ nBegin);
	return math.floor(nInt32);
end

-- 设置一个32位数中的指定位段(0~31)为指定整数
function Lib:SetBits(nInt32, nBits, nBegin, nEnd)
	if (nBegin > nEnd) then
		local _ = nBegin;
		nBegin = nEnd;
		nEnd   = _;
	end
	nBits = nBits % (2 ^ (nEnd - nBegin + 1));
	nBits = nBits * (2 ^ nBegin);
	nInt32 = nInt32 % (2 ^ nBegin) + nInt32 - nInt32 % (2 ^ (nEnd + 1));
	nInt32 = nInt32 + nBits;
	return nInt32;
end

-- 获取bit值
function Lib:GetTableBit(tb, nPos)
	assert(nPos >= 0, "Lib:GetTableBit nPos = " .. nPos);

	local nIndex = math.floor(nPos / 32);
	local nRealPos = nPos % 32;

	if not tb or not tb[nIndex] then
		return 0;
	end

	return self:LoadBits(tb[nIndex], nRealPos, nRealPos);
end

-- 设置表内bit值
function Lib:SetTableBit(tb, nPos, nBit)
	assert(nPos >= 0, "Lib:GetTableBit nPos = " .. nPos);

	local nIndex = math.floor(nPos / 32);
	local nRealPos = nPos % 32;

	if not nBit or nBit ~= 0 then
		nBit = 1;
	end

	tb[nIndex] = tb[nIndex] or 0;
	tb[nIndex] = self:SetBits(tb[nIndex], nBit, nRealPos, nRealPos);
end

--从凌晨开始算 获得当天过了多少秒
function Lib:GetTodaySec(nTime)
	return Lib:GetLocalDayTime(nTime)
end

-- 20:00:00 20:15 解析当天的时间
function Lib:ParseTodayTime(szDateTime)
   local nHour, nMinute, nSecond = string.match(szDateTime, "(%d+):(%d+):(%d+)");
   if not nHour then
		nHour, nMinute = string.match(szDateTime, "(%d+):(%d+)");
   end

   nSecond = nSecond or 0;
   local nTime = nHour * 3600 + nMinute * 60 + nSecond;
   return nTime;
end

function Lib:GetLuaGMTSec(bUpdateGMT)
	if not self.nLuaGMTSec or bUpdateGMT then
		local now = os.time()
		self.nLuaGMTSec = os.difftime(now, os.time(os.date("!*t", now)))
	end
	return self.nLuaGMTSec;
end

-- 获取时差（秒数）
function Lib:GetGMTSec()
	local nGMTSec = 0;
	if MODULE_GAMESERVER or MODULE_ZONESERVER then
		nGMTSec = Lib:GetLuaGMTSec();
	else
		nGMTSec = GetLogicGMTSec();
		if nGMTSec == -1 then
			nGMTSec = Lib:GetLuaGMTSec();
		end
	end

	return nGMTSec;
end

function Lib:LocalDate(szFormat, nSec, bUpdateGMT)
	if MODULE_GAMECLIENT then
		nSec = nSec + GetLogicGMTSec() - Lib:GetLuaGMTSec(bUpdateGMT);
	end

	return os.date(szFormat, nSec);
end

-- 根据秒数（UTC，GetTime()返回）计算当地时间今天已经过的秒数
function Lib:GetLocalDayTime(nUtcSec)
	local nLocalSec	= (nUtcSec or GetTime()) + self:GetGMTSec();
	return math.mod(nLocalSec, 3600 * 24);
end


-- 根据秒数（UTC，GetTime()返回）计算当地时间今天已经过的小时
function Lib:GetLocalDayHour(nUtcSec)
	local nLocalSec	= (nUtcSec or GetTime()) + self:GetGMTSec();
	local nDaySec = math.mod(nLocalSec, 3600 * 24);
	return math.floor(nDaySec / 3600);
end

-- 根据秒数（UTC，GetTime()返回）计算当地天数
--	1970年1月1日 返回0
--	1970年1月2日 返回1
--	1970年1月3日 返回2
--	……依此类推
function Lib:GetLocalDay(nUtcSec)
	local nLocalSec	= (nUtcSec or GetTime()) + self:GetGMTSec();
	return math.floor(nLocalSec / (3600 * 24));
end

-- 根据日期获取时间,当日0点的时间
function Lib:GetTimeByLocalDay(nLocalDay)
	local nLocalSec = nLocalDay * (3600 * 24);
	return nLocalSec - self:GetGMTSec();
end

-- 根据秒数（UTC，GetTime()返回）计算当地周数
--	1970年1月1日 星期四 返回0
--	1970年1月4日 星期日 返回0
--	1970年1月5日 星期一 返回1
--	……依此类推
function Lib:GetLocalWeek(nUtcSec)
	local nLocalDay	= self:GetLocalDay(nUtcSec);
	return math.floor((nLocalDay + 3) / 7);
end

--获取本周结束时的 秒数
function Lib:GetLocalWeekEndTime(nUtcSec)
	local nWeekDay = Lib:GetLocalWeek(nUtcSec)
	return (nWeekDay * 7 + 4) * (3600 * 24) - Lib:GetGMTSec()
end

-- 周一到周日 返回 1~7
function Lib:GetLocalWeekDay(nUtcSec)
	local nLocalDay	= self:GetLocalDay(nUtcSec);
	return (nLocalDay + 3) % 7 + 1;
end

-- 获取第nWeek周(本地周数), 星期nDay(1-7), nHour:nMin:nSec的时间
function Lib:GetTimeByWeek(nWeek, nDay, nHour, nMin, nSec)
    if not nWeek or not nDay
    or (nWeek <= 0) then        -- 第0周就不处理了。。。
        return nil;
    end
    nDay = nDay + (nWeek - 1) * 7 + 4;
    return os.time{year = 1970, month = 1, day = nDay,
                   hour = nHour, min = nMin, sec = nSec
}
end

-- 返回时间戳对应的人类可阅读的数字（如：20160222）
function Lib:GetTimeNum(timestamp)
	timestamp = timestamp or GetTime()
	local tbTime = os.date("*t", timestamp)
	return tbTime.year*10000 + tbTime.month*100 + tbTime.day
end

-- 返回2016-03-22
function Lib:GetTimeStr(nTimestamp)
	nTimestamp = nTimestamp or GetTime()
	local tbTime = os.date("*t", nTimestamp)
	return string.format("%d-%.2d-%.2d", tbTime.year, tbTime.month, tbTime.day)
end

-- 返回03-22 16:33
function Lib:GetTimeStr2(nTimestamp)
	nTimestamp = nTimestamp or GetTime()
	local tbTime = os.date("*t", nTimestamp)
	return string.format("%.2d-%.2d %.2d:%.2d", tbTime.month, tbTime.day, tbTime.hour, tbTime.min)
end

-- 返回2016-03-22 16:33
function Lib:GetTimeStr3(nTimestamp)
	nTimestamp = nTimestamp or GetTime()
	local tbTime = os.date("*t", nTimestamp)
	return string.format("%d-%.2d-%.2d %.2d:%.2d", tbTime.year, tbTime.month, tbTime.day, tbTime.hour, tbTime.min)
end

-- 返回2016-03-22 16:33:22
function Lib:GetTimeStr4(nTimestamp)
	nTimestamp = nTimestamp or GetTime()
	local tbTime = os.date("*t", nTimestamp)
	return string.format("%d-%.2d-%.2d %.2d:%.2d:%.2d", tbTime.year, tbTime.month, tbTime.day, tbTime.hour, tbTime.min, tbTime.sec)
end

-- 根据秒数（UTC，GetTime()返回）计算当地月数
--	1970年1月 返回0
--	1970年2月 返回1
--	1970年3月 返回2
--	……依此类推
function Lib:GetLocalMonth(nUtcSec)
	local tbTime 	= os.date("*t", nUtcSec or GetTime());
	return (tbTime.year - 1970) * 12 + tbTime.month - 1;
end

--获取季度数，以3月、6月、9月、12月为每个季度最后一个月
function Lib:GetLocalSeason(nUtcSec)
	local tbTime 	= os.date("*t", nUtcSec or GetTime());
	return (tbTime.year - 1970) * 4 + math.ceil( tbTime.month / 3 ) - 1;
end

function Lib:GetLocalYear(nUtcSec)
	local tbTime 	= os.date("*t", nUtcSec or GetTime());
	return tbTime.year - 1970;
end

function Lib:GetMonthDay(nUtcSec)
    local tbTime = os.date("*t", nUtcSec or GetTime());
    return tbTime.day;
end

-- 获取nUtcSec所在月 第nWeek周的星期nDay nHour:nMin:nSec 的时间
function Lib:GetTimeByWeekInMonth(nUtcSec, nWeek, nDay, nHour, nMin, nSec)
	if nWeek == 0 then
		return;
	end

	nHour = nHour or 0;
	nMin = nMin or 0;
	nSec = nSec or 0;

	local nDstDay = 0;
	if nWeek > 0 then
		local tbTime 	= os.date("*t", nUtcSec or GetTime());
		local nMonthFirstDay	= self:GetLocalDay(os.time({year = tbTime.year, month = tbTime.month, day = 1}));
		local nMonthFirstWeekDay = (nMonthFirstDay + 3) % 7 + 1;

		nWeek = nMonthFirstWeekDay > nDay and nWeek or nWeek - 1;
		nDstDay = (nDay - nMonthFirstWeekDay) + nMonthFirstDay + nWeek * 7;
	else
		local tbTime 	= os.date("*t", nUtcSec or GetTime());

		local nMonthLastDay	= self:GetLocalDay(os.time({
															year = tbTime.month == 12 and tbTime.year + 1 or tbTime.year,
															month = tbTime.month == 12 and 1 or tbTime.month + 1,
															day = 1
														})) - 1;

		local nMonthLastWeekDay = (nMonthLastDay + 3) % 7 + 1;

		nWeek = nMonthLastWeekDay < nDay and nWeek or nWeek + 1;
		nDstDay = (nDay - nMonthLastWeekDay) + nMonthLastDay + nWeek * 7;
	end
	return nDstDay * 3600 * 24 + nHour * 3600 + nMin * 60 + nSec - self:GetGMTSec();
end

--检查时间是否是月份第一周的周几(1-7)
function Lib:IsMonthlyFirstWeekday(nWeekDay, nTime)
	nTime = nTime or GetTime();
	local tbTime = Lib:LocalDate("*t", nTime);
	local nCurWeekDay = tbTime.wday - 1;
	if nCurWeekDay == 0 then
		nCurWeekDay = 7
	end

	if (nCurWeekDay ~= nWeekDay) then
		return false
	end

	--减去周几判断是否是第一周
	return (tbTime.day - 7) <= 0
end

--检查时间是否是月份最后一周的周几(1-7)
function Lib:IsMonthlyLastWeekday(nWeekDay, nTime)
	nTime = nTime or GetTime();
	local tbTime = Lib:LocalDate("*t", nTime);
	local nCurWeekDay = tbTime.wday - 1;
	if nCurWeekDay == 0 then
		nCurWeekDay = 7
	end

	if (nCurWeekDay ~= nWeekDay) then
		return false
	end

	local tbNextWeekTime = Lib:LocalDate("*t", nTime + 7*24*60*60);
	--判断是否跨越到下一个月
	return tbNextWeekTime.year ~= tbTime.year or tbNextWeekTime.month ~= tbTime.month
end

--返回固定日期的秒数
--nDate格式如(2008-6-25 00:00:00):20080625 ; 2008062500; 200806250000 ; 20080625000000
function Lib:GetDate2Time(nDate)
	local nDate = tonumber(nDate);
	if nDate == nil then
		return
	end
	local nSecd = 0;
	local nMin 	= 0;
	local nHour	= 0;
	local nDay 	= 0;
	local nMon 	= 0;
	local nYear = 0;
	if string.len(nDate) == 8 then
		 nDay = math.mod(nDate, 100);
		 nMon = math.mod(math.floor(nDate/100), 100);
		 nYear = math.mod(math.floor(nDate/10000),10000);
	elseif string.len(nDate) == 10 then
		 nHour = math.mod(nDate, 100);
		 nDay = math.mod(math.floor(nDate/100), 100);
		 nMon = math.mod(math.floor(nDate/10000),100);
		 nYear = math.mod(math.floor(nDate/1000000),10000);
	elseif string.len(nDate) == 12 then
		 nMin = math.mod(nDate, 100);
		 nHour= math.mod(math.floor(nDate/100), 100);
		 nDay = math.mod(math.floor(nDate/10000),100);
		 nMon = math.mod(math.floor(nDate/1000000),100);
		 nYear = math.mod(math.floor(nDate/100000000),10000);
	elseif string.len(nDate) == 14 then
		 nSecd = math.mod(nDate, 100);
		 nMin = math.mod(math.floor(nDate/100), 100);
		 nHour= math.mod(math.floor(nDate/10000), 100);
		 nDay = math.mod(math.floor(nDate/1000000),100);
		 nMon = math.mod(math.floor(nDate/100000000),100);
		 nYear = math.mod(math.floor(nDate/10000000000),10000);
	else
		return 0;
	end
	local tbData = {year=nYear, month=nMon, day=nDay, hour=nHour, min=nMin, sec=nSecd};
	local nSec = Lib:GetSecFromNowData(tbData)
	return nSec;
end

function Lib:GetSecFromNowData(tbData)
	local nSecTime = os.time(tbData);
	return nSecTime;
end

--时间显示转换:如1030转成10:30 ; 0转换成0:00
function Lib:HourMinNumber2TimeDesc(nTime)
	local nMin = math.mod(nTime, 100);
	local nHour = math.floor(nTime/ 100);
	local szMin = nMin;
	if nMin < 10 then
		szMin = "0" .. nMin;
	end
	local szTime = nHour .. ":" .. szMin;
	return szTime
end

--时间显示转换:如10:30转成 10*3600+30*60; 00:00转换成0
function Lib:HourMinTimeDesc2Second(szTime)
	local nHour, nMin = string.match(szTime, "(%d+):(%d+)");
	nHour = tonumber(nHour) or 0;
	nMin = tonumber(nMin) or 0;
	return nHour * 3600 + nMin * 60;
end

-- 支持,支持不传秒
--		2012/09/28 10:50:51
--		2012-09-28 10:50:51
--		2012.09.28 10:50:51
--		2018-02-10-03-59-59
--		2012-09-28
--		2012.09.28
function Lib:ParseDateTime(szDateTime)
	local year, month, day, hour, minute, second = string.match(szDateTime, "(%d+)/(%d+)/(%d+) (%d+):(%d+):?(%d?%d?)");
	if not year then
		year, month, day, hour, minute, second = string.match(szDateTime, "(%d+)-(%d+)-(%d+) (%d+):(%d+):?(%d?%d?)");
	end
	if not year then
		year, month, day, hour, minute, second = string.match(szDateTime, "(%d+)%.(%d+)%.(%d+) (%d+):(%d+):?(%d?%d?)");
	end
	if not year then
		year, month, day, hour, minute, second = string.match(szDateTime, "(%d+)-(%d+)-(%d+)-(%d+)-(%d+)-?(%d?%d?)");
	end
	second = second or 0;
	if not year then
		year, month, day = string.match(szDateTime, "(%d+)/(%d+)/(%d+)");
		hour, minute, second = 0, 0, 0;
	end

	if not year then
		year, month, day = string.match(szDateTime, "(%d+)-(%d+)-(%d+)");
		hour, minute, second = 0, 0, 0;
	end

	if not year then
		year, month, day = string.match(szDateTime, "(%d+).(%d+).(%d+)");
		hour, minute, second = 0, 0, 0;
	end

	if not year then
		Log("Lib:ParseDateTime 时间字符串格式不合法" .. szDateTime);
		return;
	end

	local nSec = os.time({year = year, month = month, day = day, hour = hour, min = minute, sec = second});
	if MODULE_GAMECLIENT and GetLogicGMTSec() ~= -1 then
		nSec = nSec - GetLogicGMTSec() + Lib:GetLuaGMTSec();
	end

	return nSec;
end

--把整形的IP地址转成字符串表示(xxx.xxx.xxx.xxx)
function Lib:IntIpToStrIp(nIp)
	--local nIp = tonumber(nIp);
	if nIp == nil then
		return "";
	end
	local tbIp = {};
	tbIp[1] = self:LoadBits(nIp, 0,  7);
	tbIp[2] = self:LoadBits(nIp, 8, 15);
	tbIp[3] = self:LoadBits(nIp, 16, 23);
	tbIp[4] = self:LoadBits(nIp, 24, 31);
	local szIp = string.format("%d.%d.%d.%d", tbIp[1], tbIp[2], tbIp[3], tbIp[4]);
	return szIp;
end

function Lib:IsInteger(val)
	if (not val or type(val) ~= "number") then
		return 0;
	elseif (math.floor(val) == val) then
		return 1;
	end
	return 0;
end

function Lib:HasNonChineseChars(s)
	if version_vn then
		return false;
	end
	local tbUtf8 = self:GetUft8Chars(s)
	for _,c in ipairs(tbUtf8) do
		if string.byte(c)<=127 then
			return true
		end
	end
	return false
end

function Lib:GetUft8Chars(s)
	local nTotalLen = string.len(s);
	local nCurIdx = 1;
	local tbResult = {};
	while nCurIdx <= nTotalLen do
		local c = string.byte(s, nCurIdx);
		if c > 0 and c <= 127 then
			table.insert(tbResult, string.sub(s, nCurIdx, nCurIdx));
			nCurIdx = nCurIdx + 1;
		elseif c >= 194 and c <= 223 then
			table.insert(tbResult, string.sub(s, nCurIdx, nCurIdx + 1));
			nCurIdx = nCurIdx + 2;
		elseif c >= 224 and c <= 239 then
			table.insert(tbResult, string.sub(s, nCurIdx, nCurIdx + 2));
			nCurIdx = nCurIdx + 3;
		elseif c >= 240 and c <= 244 then
			table.insert(tbResult, string.sub(s, nCurIdx, nCurIdx + 3));
			nCurIdx = nCurIdx + 4;
		end
	end

	return tbResult;
end

function Lib:Utf8Len(s)
	if s and type(s) == "string" then
		return KLib.GetUtf8Len(s);
	else
		return 0;
	end
end

function Lib:CutUtf8(s, nLen, nCharLen)
	return KLib.CutUtf8(s, nLen, nCharLen);
end

function Lib:InitTable(tb, ...)
	local tbIdx = {...};
	for _, key in ipairs(tbIdx) do
		tb[key] = tb[key] or {};
		tb = tb[key];
	end

	return tb;
end

--获得当前最大的时间轴
function Lib:GetMaxTimeFrame(tbTimeFrame)
    local szCurTimeFrame 	= "";
    local nCurTimeFrameTime = -1;

    for szTimeFrame, _ in pairs(tbTimeFrame) do
        if szTimeFrame ~= "-1" and GetTimeFrameState(szTimeFrame) == 1 then
            local nOpenTime = CalcTimeFrameOpenTime(szTimeFrame);
            if nOpenTime > nCurTimeFrameTime then
                nCurTimeFrameTime = nOpenTime;
                szCurTimeFrame = szTimeFrame;
            end
        end
    end

    return szCurTimeFrame;
end

function Lib:GetCountInTable(tbItems, fnEqual, param)
	local nCount = 0;
	for _, tbItem in pairs(tbItems) do
		if fnEqual(tbItem, param) then
			nCount = nCount + 1;
		end
	end

	return nCount;
end

function Lib:GetDistsSquare(nX1, nY1, nX2, nY2)
    local fOfX = nX2 - nX1;
    local fOfY = nY2 - nY1;
    return (fOfX * fOfX + fOfY * fOfY);
end

function Lib:GetDistance(nX1, nY1, nX2, nY2)
	local fDist = Lib:GetDistsSquare(nX1, nY1, nX2, nY2);
	return math.sqrt(fDist);
end

function Lib:GetServerOpenDay()
	local nCreateTime = GetServerCreateTime();
	local nToday = Lib:GetLocalDay();
	return nToday - Lib:GetLocalDay(nCreateTime) + 1;
end

--功能：判断两个时间是否不在同一天
--nOffset:时间偏移(单位为s)，比如以4点为新的一天标准，那么该值为 4 * 60 * 60
--nTime1:需要比较的第一个时间(s)
--nTime2:需要比较的第二个时间(s)，不传便取当前时间
--返回值：true：两个时间不在同一天，false：两个时间在同一天
function Lib:IsDiffDay(nOffset, nTime1, nTime2)
	nTime2 = nTime2 or GetTime();
	local nDay1 = self:GetLocalDay(nTime1 - nOffset);
	local nDay2 = self:GetLocalDay(nTime2 - nOffset);

	return nDay1 ~= nDay2;
end

function Lib:GetDiffDays(nOffset, nTime1, nTime2)
	local nDay1 = self:GetLocalDay(nTime1 - nOffset)
	local nDay2 = self:GetLocalDay(nTime2 - nOffset)
	return math.abs(nDay2-nDay1)
end

function Lib:IsDiffWeek(nTime1, nTime2, nOffset)
	nOffset = nOffset or 0
	local nWeek1 = self:GetLocalWeek(nTime1-nOffset)
	local nWeek2 = self:GetLocalWeek(nTime2-nOffset)
	return nWeek1~=nWeek2
end

function Lib:IsDiffMonth(nTime1, nTime2, nOffset)
	nOffset = nOffset or 0
	local nMonth1 = self:GetLocalMonth(nTime1-nOffset)
	local nMonth2 = self:GetLocalMonth(nTime2-nOffset)
	return nMonth1~=nMonth2
end

function Lib:SecondsToDays(nSeconds)
	return math.floor(nSeconds/(24*3600))
end

-- 功能:	把字符串扩展为长度为nLen,左对齐, 其他地方用空格补齐
-- 参数:	szStr	需要被扩展的字符串
-- 参数:	nLen	被扩展成的长度
function Lib:StrFillL(szStr, nLen, szFilledChar)
	szStr				= tostring(szStr);
	szFilledChar		= szFilledChar or " ";
	local nRestLen		= nLen - string.len(szStr);								-- 剩余长度
	local nNeedCharNum	= math.floor(nRestLen / string.len(szFilledChar));	-- 需要的填充字符的数量

	szStr = szStr..string.rep(szFilledChar, nNeedCharNum);					-- 补齐
	return szStr;
end


-- 功能:	把字符串扩展为长度为nLen,右对齐, 其他地方用空格补齐
-- 参数:	szStr	需要被扩展的字符串
-- 参数:	nLen	被扩展成的长度
function Lib:StrFillR(szStr, nLen, szFilledChar)
	szStr				= tostring(szStr);
	szFilledChar		= szFilledChar or " ";
	local nRestLen		= nLen - string.len(szStr);								-- 剩余长度
	local nNeedCharNum	= math.floor(nRestLen / string.len(szFilledChar));	-- 需要的填充字符的数量

	szStr = string.rep(szFilledChar, nNeedCharNum).. szStr;					-- 补齐
	return szStr;
end

-- 功能:	把字符串扩展为长度为nLen,居中对齐, 其他地方以空格补齐
-- 参数:	szStr	需要被扩展的字符串
-- 参数:	nLen	被扩展成的长度
function Lib:StrFillC(szStr, nLen, szFilledChar)
	szStr				= tostring(szStr);
	szFilledChar		= szFilledChar or " ";
	local nRestLen		= nLen - string.len(szStr);								-- 剩余长度
	local nNeedCharNum	= math.floor(nRestLen / string.len(szFilledChar));	-- 需要的填充字符的数量
	local nLeftCharNum	= math.floor(nNeedCharNum / 2);							-- 左边需要的填充字符的数量
	local nRightCharNum	= nNeedCharNum - nLeftCharNum;							-- 右边需要的填充字符的数量

	szStr = string.rep(szFilledChar, nLeftCharNum)
			..szStr..string.rep(szFilledChar, nRightCharNum);				-- 补齐
	return szStr;
end

-- 功能:	判断文件是否存在
-- 参数:	strFilePath	文件路径
function Lib:IsFileExsit(strFilePath)
	local file, err = io.open(strFilePath, "rb");
	if  not file then
		return false
	end

	file:close();
	return true
end

-- 功能:	读取一个二进制文件
-- 参数:	strFilePath	文件路径
function Lib:ReadFileBinary(strFilePath)
	local file, err = io.open(strFilePath, "rb");
	if  not file then
		return nil
	end

	local len = file:seek("end")

	file:seek("set")

	local data = file:read("*all");

	file:close();
	return data, len
end

-- 功能:	写二进制文件
-- 参数:	strFilePath	文件路径
-- 参数:	szData	二进制数据
function Lib:WriteFileBinary(strFilePath, szData)
	local file, err = io.open(strFilePath, "wb");
	if  not file then
		return false
	end

	file:write(szData);

	file:close();
	return true
end

-- 获取一个table占用内存大小
function Lib:GetTableSize(tbRoot)
	local tbChecked = {};
	local function fnGetSize(tb)
		local nSize = debug.gettablesize(tb);
		for _, value in pairs(tb) do
			if type(value) == "table" and not tbChecked[value] then
				tbChecked[value] = true;
				nSize = nSize + fnGetSize(value);
			end
		end
		return nSize;
	end
	local nSize = fnGetSize(tbRoot);
	tbChecked = nil;
	return nSize;
end

-- 获取一个table占用内存大小(新版本，会计算userdata占用)
function Lib:GetTableSizeNew(tbRoot)
	local tbChecked = {};
	local function fnGetSize(tb)
		local nSize = debug.gettablesizenew(tb);
		for _, value in pairs(tb) do
			if type(value) == "table" and not tbChecked[value] then
				tbChecked[value] = true;
				nSize = nSize + fnGetSize(value);
			end
		end
		return nSize;
	end
	local nSize = fnGetSize(tbRoot);
	tbChecked = nil;
	return nSize;
end

function Lib:DecodeJson(szJson)
	return cjson.decode(szJson);
end

function Lib:EncodeJson(value)
	return cjson.encode(value);
end

--判断数组中是否包含指定元素
function Lib:IsInArray(tbArray, xCheck)
	for _, v in ipairs(tbArray) do
		if v==xCheck then
			return true
		end
	end
	return false
end

-- 功能:	根据概率随机选取表的某一项
-- 参数:	tbRateTable	随机表
-- 参数:	[szRateKey]	概率数据Key(可选默认Key是"nRate")
function Lib:GetRandomTable( tbRateTable, szRateKey )
	local nTotalRate = 0;
	local tbTmpRate = {};
	szRateKey = szRateKey or "nRate"

	for key,tbEntry in pairs(tbRateTable) do
		local nRate = tbEntry[szRateKey]
		if  nRate then
			nTotalRate = nTotalRate + nRate
			table.insert(tbTmpRate, {key = key, nRate = nTotalRate} )
		end
	end

	if nTotalRate <= 0 then
		return nil
	end

	local nRandomRate = MathRandom(nTotalRate);
	for _,tbRateInfo in ipairs(tbTmpRate) do
		if nRandomRate <= tbRateInfo.nRate then
			return tbRateTable[tbRateInfo.key], tbRateInfo.key
		end
	end

	return nil
end

function Lib:CallZ2SOrLocalScript(nConnectIdx, szFunc, ...)
	local bRet = false;
	if not MODULE_ZONESERVER then
        if string.find(szFunc, ":") then
			local szTable, szFunc = string.match(szFunc, "^(.*):(.*)$");
			local tb = loadstring("return " .. szTable)();
			if tb and tb[szFunc] then
				bRet = Lib:CallBack({tb[szFunc], tb, ...});
			end
		else
			local func = loadstring("return " .. szFunc)();
			bRet = Lib:CallBack({func, ...});
		end
    else
    	if nConnectIdx then
	        CallZoneClientScript(nConnectIdx, szFunc, ...);
	        bRet = true;
	    end
    end

	if not bRet then
		Log("Error CallZ2SOrLocalScript Error", debug.traceback(), nConnectIdx, szFunc, ...)
	end
end

function Lib:UrlEncode(str)
	local pattern = "[^%w%d%._%-%* ]"
	str = string.gsub(str, pattern, function(c)
		local c = string.format("%%%02X",string.byte(c))
		return c
	end)
	str = string.gsub(str," ","+")
	return str
end

--标准UrlEncode，除了数字，字母，.-_,其他都转
function Lib:UrlEncode_N(str)
    str = string.gsub(str, "([^%w%.%-%_ ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(str, " ", "+")
end

function Lib:UrlDecode_N(str)
    str = string.gsub(str, "+", " ")
    return string.gsub(str, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
end

function Lib:SortStrByAlphabet(tbSort)
	table.sort( tbSort, function (k1, k2)
		local nMax1 = #k1;
		local nMax2 = #k2;
		local nKLen = math.min(nMax1, nMax2)
		for i=1,nKLen do
			local b1 = string.byte(k1, i)
			local b2 = string.byte(k2, i)
			if b1 ~= b2 then
				return b1 < b2
			end
		end
		return nMax1 < nMax2
	end )
	return tbSort
end

function Lib:GetTimeFrameRemainDay(szTimeFrame)
	if GetTimeFrameState(szTimeFrame) == 1 then
		return 0;
	end

	local nOpenTime = CalcTimeFrameOpenTime(szTimeFrame);
	return Lib:GetLocalDay(nOpenTime) - Lib:GetLocalDay();
end

-- 随机获得与上一次不重复的随机数
function Lib:GetDifferentRandomNum(nCount)
	assert(nCount > 0);

	local nLastNum = 0;
	return function ()
		if nCount == 1 then
			return 1;
		end

		if nLastNum == 0 then
			nLastNum = MathRandom(1, nCount);
			return nLastNum;
		end

		local nNum = MathRandom(1, nCount - 1);
		if nNum < nLastNum then
			nLastNum = nNum;
		else
			nLastNum = nNum + 1;
		end

		return nLastNum;
	end
end

-- 随机获得与上一次不重复的值
-- 参数: tbInfo 为索引以1开始有序递增的table表
function Lib:GetDifferentRandomSelect(tbInfo)
	local nCount = #tbInfo;
	local nLastIndex = 0;
	return function ()
		if nCount == 0 then
			return;
		end

		local nCurIndex = nil;
		if nCount == 1 then
			nCurIndex = 1;
		elseif nLastIndex == 0 then
			nCurIndex = MathRandom(1, nCount);
		else
			nCurIndex = MathRandom(1, nCount - 1);
			if nCurIndex >= nLastIndex then
				nCurIndex = nCurIndex + 1;
			end
		end

		nLastIndex = assert(nCurIndex);
		return tbInfo[nLastIndex];
	end
end

-- 随机获得table不重复项
-- 参数: tbInfo 为索引以1开始有序递增的table表
function Lib:GetDifferentEntry(tbInfo)
	local tbUnselected = {}
	local nCount = #tbInfo;
	for nIndex=1,nCount do
		table.insert(tbUnselected, nIndex)
	end

	return function ()
		if #tbUnselected <= 0 then
			return;
		end

		local nSelect = MathRandom(1, #tbUnselected);
		local nIndex = tbUnselected[nSelect]
		table.remove(tbUnselected, nSelect)

		return tbInfo[nIndex], nIndex;
	end
end

-- 返回月份一共有几天
function Lib:GetMonthDayCount(nTime)
	local tbTime = os.date("*t", nTime or GetTime());
	return tonumber(os.date("%d", os.time({year = tbTime.year, month = tbTime.month + 1, day = 0})))
end

-- 判断是否是闰年
function Lib:IsLeapYear(nYear)
	return (nYear%4==0 and nYear%100~=0) or nYear%400==0
end

-- 获取相差自然月数，向下取整
-- 2月特殊：闰年29天，否则28天
local nMinMonthSec = 28*24*3600	--最小月的秒数
function Lib:GetDiffMonth(nTimeFrom, nTimeTo)
	if (nTimeTo-nTimeFrom)<nMinMonthSec then
		return 0
	end

	local tbFromDate = os.date("*t", nTimeFrom)
	local tbToDate = os.date("*t", nTimeTo)

	local nFromDay = tbFromDate.day
	local nToDay = tbToDate.day
	if nFromDay>nToDay then
		local bLastDay = nToDay>=28 and self:GetMonthDayCount(nTimeTo)==nToDay
		if not bLastDay then
			tbToDate.month = tbToDate.month-1
		end
	end
	return (tbToDate.year*12+tbToDate.month)-(tbFromDate.year*12+tbFromDate.month)
end

function Lib:SplitArrayByCount(tb, nCount)
	local nEnd = #tb;
	if nEnd <= nCount then
		return {tb};
	end

	local tbRet = {};
	local nBegin = 1;
	while nBegin <= nEnd do
		table.insert(tbRet, {unpack(tb, nBegin, math.min(nBegin + nCount - 1, nEnd))});
		nBegin = nBegin + nCount;
	end
	return tbRet;
end

function Lib:CheckVersion(tbInfo)
	if (tbInfo.version_tx == 1 and version_tx) or
		(tbInfo.version_vn == 1 and version_vn) or
		(tbInfo.version_hk == 1 and version_hk) or
		(tbInfo.version_hk == 1 and version_tw) or
		(tbInfo.version_xm == 1 and version_xm) or
		(tbInfo.version_en == 1 and version_en) or
		(tbInfo.version_kor == 1 and version_kor) or
		(tbInfo.version_th == 1 and version_th) then
		return true;
	end

	return false;
end


function Lib:CheckNotVersion(tbInfo)
	if (tbInfo.NotVersion_tx == 1 and version_tx) or
		(tbInfo.NotVersion_vn == 1 and version_vn) or
		(tbInfo.NotVersion_hk == 1 and version_hk) or
		(tbInfo.NotVersion_hk == 1 and version_tw) or
		(tbInfo.NotVersion_xm == 1 and version_xm) or
		(tbInfo.NotVersion_en == 1 and version_en) or
		(tbInfo.NotVersion_kor == 1 and version_kor) or
		(tbInfo.NotVersion_th == 1 and version_th) then
		return true;
	end

	return false;
end

function Lib:insertionSort(tbSort, fnSort)
	local fncomp = fnSort;
	if not fncomp then
		fncomp = function (a, b)
			return a > b;
		end
	end
	if #tbSort > 1 then
		for i = 2, #tbSort, 1 do
			local tmp = tbSort[i];
			local j = i - 1;
			while j >= 1 and fncomp(tmp, tbSort[j]) do
				tbSort[j+1] = tbSort[j];
				j = j - 1;
			end
			tbSort[j+1] = tmp;
		end
	end
end

function Lib:SortTable(tbSort, fnSort)
	if #tbSort > 1 then
		table.sort(tbSort, fnSort)
	end
	return tbSort
end

function Lib:CombineUniqId(nServerId, dwID)
	return nServerId * (2^32) + dwID;
end

function Lib:RestoreUniqId(nUniqId)
	local nServerId 	= math.floor(nUniqId / (2^32));
	local dwID 		= math.floor(nUniqId % (2^32));
	return dwID, nServerId;
end

function Lib:GetNumLen(nNum)
	if type(nNum) ~= "number" then
		return 0
	end
	local szNum = tostring(nNum)
	return string.len(szNum)
end

function Lib:MultiTable(tbOrg, nMulti)
	local tbResult = {};
	for i = 1, nMulti do
		for _, v in ipairs(tbOrg) do
			table.insert(tbResult, v);
		end
	end
	return tbResult;
end

function Lib:GetMilliSec()
	return os.clock() * 1000
end

function Lib:RecordCost(szFunc, nTime)
	self.tbFuncCost = self.tbFuncCost or {nLastLogTime = 0, nTotalCount = 0, nTotalTime = 0, tbFuncs = {}}

	self.tbFuncCost.nTotalCount = self.tbFuncCost.nTotalCount + 1
	self.tbFuncCost.nTotalTime = self.tbFuncCost.nTotalTime + nTime

	local tbFunc = self.tbFuncCost.tbFuncs[szFunc] or {nCount = 0, nTime = 0}
	tbFunc.nCount = tbFunc.nCount + 1
	tbFunc.nTime = tbFunc.nTime + nTime
	self.tbFuncCost.tbFuncs[szFunc] = tbFunc

	self:LogCost()
end

Lib.nLogCostInterval = 2 * 3600
function Lib:LogCost()
	if not self.tbFuncCost then
		return
	end

	local nNow = GetTime()
	if nNow < (self.tbFuncCost.nLastLogTime or 0) + self.nLogCostInterval then
		return
	end
	self.tbFuncCost.nLastLogTime = nNow

	Log("LogCost", self.tbFuncCost.nTotalCount, self.tbFuncCost.nTotalTime)
	for szFunc, tb in pairs(self.tbFuncCost.tbFuncs or {}) do
		Log("\t", szFunc, tb.nCount, tb.nTime, tb.nCount / self.tbFuncCost.nTotalCount, tb.nTime / self.tbFuncCost.nTotalTime)
	end
end

function Lib:IsPointInRect(tbLT, tbRT, tbLB, tbRB, tbP)
	local a = (tbLT[1] - tbLB[1])*(tbP[2] - tbLB[2]) - (tbLT[2] - tbLB[2])*(tbP[1] - tbLB[1])
	local b = (tbRT[1] - tbLT[1])*(tbP[2] - tbLT[2]) - (tbRT[2] - tbLT[2])*(tbP[1] - tbLT[1])
	local c = (tbRB[1] - tbRT[1])*(tbP[2] - tbRT[2]) - (tbRB[2] - tbRT[2])*(tbP[1] - tbRT[1])
	local d = (tbLB[1] - tbRB[1])*(tbP[2] - tbRB[2]) - (tbLB[2] - tbRB[2])*(tbP[1] - tbRB[1])
	return ((a > 0 and b > 0 and c > 0 and d > 0) or (a < 0 and b < 0 and c < 0 and d < 0))
end

-- 求P到直线AB的距离的平方
function Lib:Point2LineDisSquare(tbA, tbB, tbP)
	local x1, y1 = unpack(tbA)
	local x2, y2 = unpack(tbB)
	local x0, y0 = unpack(tbP)

	return (((x0 - x1) * (y2 - y1) + (y0 - y1) * (x1 - x2)) ^ 2) / ((y2 - y1) ^ 2 + (x1 - x2) ^ 2)
end

Lib.Epsinon = 1.0e-7
function Lib:IsZero(num)
	return num > -self.Epsinon and num < self.Epsinon
end

