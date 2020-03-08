-- 2012/3/16 16:31:12
-- zhaoyu

FightSkill.tbAllMagicDesc = nil;
FightSkill.DESC_FUNC = {};
FightSkill.TOOL_FUNC = {};
local DESC_FUNC = FightSkill.DESC_FUNC;
local TOOL_FUNC = FightSkill.TOOL_FUNC;

local function Frame2Sec(value)
	local nRet = math.floor(value * 10 / 18) / 10;
	return nRet;
end

function DESC_FUNC:Default(szMagicName, tbMagic, tbSkillInfo)
	local szDesc = string.format("%s=%d,%d,%d", szMagicName, tbMagic[1], tbMagic[2], tbMagic[3]);
	print(string.format(XT("魔法属性描述未找到:%s"), szMagicName));
	return szDesc;
end

function DESC_FUNC:AddFlagLevel(szMagicName, tbMagic, tbSkillInfo)
	local tbSkillFlag = {
		[2] = "秘籍技能",
		[3] = "同伴护主技能",
	}
	local szKind = tbSkillFlag[tbMagic[1]] or "未定义类型技能";
	local szDesc = string.format("%s等级 +%s", szKind, tbMagic[2]);
	return szDesc;
end

function TOOL_FUNC:toSkillName(nId)
	return KFightSkill.GetSkillName(nId);
end

function TOOL_FUNC:toAddDec(nValue)
	local szPrefix;
	if (nValue > 0) then
		szPrefix = XT("增加");
	else
		szPrefix = XT("减少");
	end
	
	local szDesc = string.format("%s%d", szPrefix, math.abs(nValue));
	return szDesc;	
end

function TOOL_FUNC:toDecAdd(nValue)
	local szPrefix;
	if (nValue > 0) then
		szPrefix = XT("减少");
	else
		szPrefix = XT("增加");
	end
	
	local szDesc = string.format("%s%d", szPrefix, math.abs(nValue));
	return szDesc;	
end

function TOOL_FUNC:toDiv10(nValue)
	return tostring(nValue / 10);
end


function TOOL_FUNC:AutoSkill(nAutoId, nAutoLevel, tbSkillInfo)
	local tbMsg			= {};
	local tbAutoInfo	= KFightSkill.GetAutoInfo(nAutoId, nAutoLevel);
	local tbChildInfo	= KFightSkill.GetSkillInfo(tbAutoInfo.nSkillId, tbAutoInfo.nSkillLevel);
	local tbAutoDesc	= FightSkill.tbAutoSkillDesc[tbSkillInfo.nId];
	
	if (not tbAutoDesc) then
		return "";
	end
	
	local szAutoDesc	= tbAutoDesc.szDesc;
	
	FightSkill.tbSkillTips:GetDescAboutLevel(tbMsg, tbChildInfo);
	
	if (#tbMsg == 0) then
		return "";
	end
	
	local szPercent = string.format("%d%%%%", tbAutoInfo.nPercent);
	szAutoDesc = string.gsub(szAutoDesc, "/p", szPercent);
	
	if (tbAutoInfo.nPerCastTime > 0) then
		local szCD = string.format(XT("%s秒"), Frame2Sec(tbAutoInfo.nPerCastTime));
		szAutoDesc = string.gsub(szAutoDesc, "/c", szCD);
	end
	
	local szIndent = FightSkill.szAutoIndent or "";
	if (not FightSkill.tbAutoIndentSkill or not FightSkill.tbAutoIndentSkill[nAutoId]) then
		FightSkill.tbAutoIndentSkill = FightSkill.tbAutoIndentSkill or {};
		FightSkill.tbAutoIndentSkill[nAutoId] = 1;
		szIndent = (FightSkill.szAutoIndent or "") .. XT("　");
		FightSkill.szAutoIndent	= szIndent;
	end
	
	if (tbAutoInfo.nType ~= FightSkill.AUTOTYPE_TIMER and tbAutoInfo.nPerCastTime > 0 and tbAutoDesc.bShowInterval == 1) then
		szAutoDesc = szAutoDesc .. string.format(XT("\n触发间隔：<color=yellow>%s秒<color>"), Frame2Sec(tbAutoInfo.nPerCastTime));
	end	
	
	for i = 1, #tbMsg do
		szAutoDesc = szAutoDesc .. "\n" .. szIndent .. tbMsg[i];
	end
	
	return szAutoDesc;
end

function FightSkill:FromatMagicDesc(szMagicName, szFormat, tbMagic, tbSkillInfo)
	local bHide;
	local function DisposeMagic(varText)
		local nId = tonumber(varText);
		if (nId) then
			return tbMagic[nId];
		else
			local tbId = {};
			local szToolFunc;
			local _;
			_, _, szToolFunc, tbId[1], tbId[2], tbId[3] = string.find(varText, "(.+):(.+);(.+);(.+)");
			
			if (not szToolFunc) then
				_, _, szToolFunc, tbId[1], tbId[2] = string.find(varText, "(.+):(.+);(.+)");
			end
			
			if (not szToolFunc) then
				_, _, szToolFunc, tbId[1] = string.find(varText, "(.+):(.+)");
			end
			
			if (not szToolFunc) then
				print(XT("技能描述参数不对:") .. szMagicName);
				return;
			end
			
			local tbValue = {};
			for i = 1, 3 do
				if (not tbId[i]) then
					break;
				end
				local nId = tonumber(tbId[i]);
				if (nId) then
					tbValue[i] = tbMagic[nId];
				else
					tbValue[i] = tbId[i];
				end
			end
			table.insert(tbValue, tbSkillInfo);
			local szFormatDesc, bNeedHide = FightSkill.TOOL_FUNC[szToolFunc](FightSkill.TOOL_FUNC, unpack(tbValue));
			if (bNeedHide) then
				bHide = true;
			end
			return szFormatDesc;
		end
	end

	local function CalcExp(szExp)
		print(szExp);
		for i = 1, 3 do
			szExp = string.gsub(szExp, "%[" .. i .. "%]", tbMagic[i]);
		end
		szExp = "return " .. szExp;
		print(szExp);
		local CalcFunc = loadstring(szExp);
		local bSucc, nResult = pcall(CalcFunc);
		if (bSucc) then
			return tostring(nResult);
		else
			print("魔法属性表达式计算错误", szExp);
			return szExp;
		end
	end
	
	TOOL_FUNC.tbSkillInfo = tbSkillInfo;
	local szDesc;

	szDesc = string.gsub(szFormat, "{=(.-)}", CalcExp)
	szDesc = string.gsub(szDesc, "{(.-)}", DisposeMagic);
	
	if (szDesc == "") then
		szDesc = nil;
	end
	
	if (bHide) then
		szDesc = nil;
	end
	
	return szDesc;
end

function FightSkill:GetMagicDesc(szMagicName, tbMagic, tbSkillInfo)
	if (not self.tbAllMagicDesc) then
		self:LoadMagicDesc();
	end
	
	local tbDesc	= self.tbAllMagicDesc[szMagicName];
	local nRow		= 0;
	local szFinalDesc;
		
	if (not tbDesc) then
		szFinalDesc = DESC_FUNC:Default(szMagicName, tbMagic, tbSkillInfo);
	else
		local fnFunc = DESC_FUNC[tbDesc.szMagicDescFunc];
		local szDescFormat = tbDesc.szMagicDesc;
		if (fnFunc) then
			szFinalDesc = fnFunc(DESC_FUNC, szMagicName, tbMagic, tbSkillInfo);
		elseif (#szDescFormat > 0) then
			szFinalDesc = self:FromatMagicDesc(szMagicName, szDescFormat, tbMagic, tbSkillInfo);
		end
		nRow = tbDesc.nRow;
	end
	return szFinalDesc, nRow;
end

function FightSkill:GetMagicDescSplit(szMagicName, tbMagic, tbSkillInfo)
	local szDesc = self:GetMagicDesc(szMagicName, tbMagic, tbSkillInfo);
	local nStart, nEnd = string.find(szDesc, "[ ]+\+");
	if nStart and nEnd then
		local s1 = string.sub(szDesc, 1, nStart - 1);
		local s2 = string.sub(szDesc, nEnd + 1);
		return s1, "+" .. s2;
	else
		return szDesc, "";
	end
end

function FightSkill:LoadMagicDesc()
	local tbData = LoadTabFile("Setting/Skill/MagicDesc.tab", "sss", nil,
		{ "szMagicAttrib", "szMagicDesc", "szMagicDescFunc" });
	local tbAllMagicDesc = {};
	for nRow, tbInfo in ipairs(tbData) do
		tbInfo.nRow = nRow;
		tbAllMagicDesc[tbInfo.szMagicAttrib] = tbInfo;
	end
	self.tbAllMagicDesc = tbAllMagicDesc;
end
