--[[
BuffTips
lizhuangzhuang
2014年9月16日16:30:59
]]

_G.BuffTips = BaseTips:new();

TipsManager:AddParseClass(TipsConsts.Type_Buff,BuffTips);

BuffTips.buffVO = nil;
BuffTips.cfg = nil;

function BuffTips:Parse(tipsInfo)
	self.buffVO = tipsInfo;
	self.cfg = t_buff[self.buffVO.tid];
	if not self.cfg then
		self.str = "";
		return;
	end
	--
	self.str = "";
	self.str = self.str .. self:GetTitle();
	self.str = self.str .. self:GetVGap(15);
	--
	local desStr = self:GetDes();
	if desStr ~= "" then
		self.str = self.str .. self:GetDes();
	end
	--
	local timeStr = self:GetTime();
	if timeStr ~= "" then
		self.str = self.str .. self:GetLine(5,10);
		self.str = self.str .. self:GetTime();
	end
end

function BuffTips:GetShowIcon()
	return false;
end

function BuffTips:GetWidth()

	return 230;
end

--标题
function BuffTips:GetTitle()
	local str = "";
	str = str .. self:GetVGap(13);
	str = str .. self:GetHtmlText(self.cfg.name,"#ffcc33",TipsConsts.TitleSize_Two);
	return str;
end

--描述
function BuffTips:GetDes()
	local str = "";
	if self.cfg.des=="" then return str; end
	str = self.cfg.des;
	local params = {
		["{1}"] = self.buffVO.params[1],
		["{2}"] = self.buffVO.params[2],
		["{3}"] = self.buffVO.params[3],
	};
	str = string.gsub(str,"{[0-9]+}",
		function(s)
			if params[s] then
				return params[s];
			end
			Debug("Error:解析Buff效果,未处理的模式." .. s);
			return "";
		end);
	str = self:GetHtmlText(str,TipsConsts.Default_Color,TipsConsts.Default_Size,false);
	str = self:SetLineSpace(str,7);
	return str;
end

--剩余时间
function BuffTips:GetTime()
	local str = "";
	local tid = self.buffVO.tid;
	local cfg = t_buff[tid]
	if not cfg then
		Error( string.format( "cannot find buff config in t_buff, id:%s", tid ) )
		return ""
	end
	if cfg.last_time == -1 then -- 配-1表示不限时
		return "";
	else
		local time = self.buffVO.time; 
		local hour, min, sec = CTimeFormat:sec2format( toint( time/1000, -1 ) );
		local hourStr = hour > 0 and hour .. StrConfig["tips300"] or "";
		local minStr = min > 0 and min .. StrConfig["tips301"] or "";
		local secStr = sec .. StrConfig["tips302"];
		str = string.format( "%s%s%s", hourStr ,minStr ,secStr );
	end
	str = self:GetHtmlText(str,"#00ff00",TipsConsts.Default_Size,false);
	str = string.format( StrConfig["tips304"], str )
	str = string.format( "<p align='middle'>%s</p>", str );
	return str;
end

