--[[
婚礼时间选择
wangshuai
]]

_G.UIMarryTimeSelect = BaseUI:new("UIMarryTimeSelect")

UIMarryTimeSelect.curSelecteIndex = 0;
UIMarryTimeSelect.curItemIndex    = 0;
UIMarryTimeSelect.curTimeId = 0;


function UIMarryTimeSelect:Create()
	self:AddSWF("marryTimeSelect.swf",true,"center")
end;

function UIMarryTimeSelect:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide()end;

	for i=1,42 do 
		objSwf["dayItem_"..i].click = function() self:OnDayitemClick(i) end;
	end;

	for i=1,6 do 
		objSwf['timeItem_'..i].click = function() self:OnTimeItemClick(i) end;
	end;
	objSwf.yesBtn.click = function() self:OnYesClick()end;
end;

-- 显示前的判断，每个show方法第一步
function UIMarryTimeSelect:ShowJudge()

	--是否有婚姻状态
	local state = MarriageModel:GetMyMarryState();
	if state == MarriageConsts.marrySingle or state == MarriageConsts.marryLeave then 
		FloatManager:AddNormal( StrConfig['marriage021']);
		return 
	end;
	--是否组队
	local isTeam = TeamModel:IsInTeam();
	if not isTeam then 
		FloatManager:AddNormal( StrConfig['marriage094']);
		return 
	end;
	--是否队长
	local mytema = TeamUtils:MainPlayerIsCaptain();
	if not mytema then 
		FloatManager:AddNormal( StrConfig['marriage076']);
		return 
	end;

	self:Show();
end;

function UIMarryTimeSelect:OnShow()
	self:OnChangeDatList()
	self:UpdataDayShow();
	self:UpDataDayList();
end;

function UIMarryTimeSelect:OnHide()
	
end;

function UIMarryTimeSelect:OnYesClick() 	
	local data = MarriageModel.MarryTimeList;
	if self.curTimeId <= 0 then 
		FloatManager:AddNormal( StrConfig["marriage016"]);
		return 
	end;
	for i,info in ipairs(data) do
		if info.TimeID == self.curTimeId then 
			if info.naName ~= "" or info.nvName ~= "" then 
				FloatManager:AddNormal( StrConfig["marriage015"]);
				return 
			end;
		end;
	end;


	local time = t_marrytime[self.curTimeId]

	local startHour,startMin = time.openTime / 100,time.openTime % 100;
	local timeData = CTimeFormat:todate(MarriageModel.MarryTimeData + (startHour * 60 * 60 + startMin * 60), false);
	-- local yearData = split(timeData," ");  --得到现在服务器日期，并取到现在年月日
	-- local dayData = split(yearData[1],"-");   --得到年月日


	local func = function() 
		MarriagController:ReqApplyMarry(toke,MarriageModel.MarryTimeData + (startHour * 60 * 60 + startMin * 60),self.curTimeId)
	end;
	
	UIConfirm:Open( string.format(StrConfig['marriage045'],timeData),func);

	
end;

function UIMarryTimeSelect:OnTimeItemClick(index)
	local objSwf  = self.objSwf;
	if not objSwf then return end;
	self.curTimeId = index;
	for i=1,6 do 
		objSwf['timeItem_'..i].selected = false;
	end;
	objSwf['timeItem_'..self.curTimeId].selected = true;
end;

function UIMarryTimeSelect:UpdataTimeList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local list = t_marrytime
	local data = MarriageModel.MarryTimeList
	for i,info in ipairs(list) do 
		local startHour,startMin = info.openTime / 100,info.openTime % 100;
		local endHour,endMin = info.closeTime / 100,info.closeTime % 100;
		objSwf["timeItem_"..i].time.htmlText = string.format("%02d:%02d-%02d:%02d",startHour,startMin,endHour,endMin);
		objSwf["timeItem_"..i].name.htmlText = StrConfig['marriage014']
		for si,sinfo in ipairs(data) do 
			if i == sinfo.TimeID then 
				if sinfo.naName ~= "" and sinfo.nvName ~= "" then 
					objSwf["timeItem_"..i].name.htmlText = sinfo.naName .."-"..sinfo.nvName;
				else
					--print('到这里来了啊')
					objSwf["timeItem_"..i].name.htmlText = StrConfig['marriage014']
				end;
				break
			end;
		end;
	end;	
end;	

function UIMarryTimeSelect:OnDayitemClick(indexc)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local index = objSwf["dayItem_"..indexc].day.ddy
	if index < 15 and indexc > 30 then 
		--如果当前日子是10号以内，防止玩家点击下月10号
		return  
	end;
	if index > 25 and indexc < 10 then 
		--如果当前日子是25号以外，防止玩家点击上月25号
		return 
	end;

	if index < self.nowDay then 
		--self:UpDataDayList();
		return 
	end;
	self.curSelecteIndex = index;
	self.curItemIndex = indexc
	self:UpDataDayList();
end;

function UIMarryTimeSelect:UpDataDayList()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.curItemIndex == 0 then return end;
	-- --print(self.curItemIndex,'回家啊盛大大撒大声地')
	-- --print(objSwf['dayItem_'..self.curItemIndex])
	for i=1,42 do 
		objSwf['dayItem_'..i].selected = false;
	end;
	objSwf['dayItem_'..self.curItemIndex].selected = true;

	--请求当前选中天数data

	local timeData = CTimeFormat:todate(GetServerTime(), false);
	local yearData = split(timeData," ");  --得到现在服务器日期，并取到现在年月日
	local dayData = split(yearData[1],"-");   --得到年月日
	local curDay = dayData[3];--当日
	local seleDay = self.curSelecteIndex - curDay 
	if seleDay < 0 then 
		seleDay = 0;
	end;
	seleDay =  seleDay * 24 * 60 * 60; --
	local dayTime = GetServerTime() - GetDayTime();
	local selectTime = dayTime + seleDay;
	MarriagController:ReqApplyMarryData(selectTime)
end;

-- 是否缓动b
function UIMarryTimeSelect:IsTween()
	return true;
end

--面板类型
function UIMarryTimeSelect:GetPanelType()
	return 1;
end
--是否播放开启音效
function UIMarryTimeSelect:IsShowSound()
	return true;
end

function UIMarryTimeSelect:IsShowLoading()
	return true;
end


-----------排序
UIMarryTimeSelect.oldYear = 2000;
UIMarryTimeSelect.oldMonth = 1;	 --2000年1月1日
UIMarryTimeSelect.oldWeek = 6;     --那天是星期六
UIMarryTimeSelect.gapDay = 0;   --当前日期与距离日期差了多少天

UIMarryTimeSelect.nowMonth = 0;  --现在是几月；
UIMarryTimeSelect.nowWeek = 0;   --这个月第一天是周几
UIMarryTimeSelect.nowDay = 0;   --今天是几号
UIMarryTimeSelect.lastMonthDayNum = 0;  --上个月多少天；
function UIMarryTimeSelect:OnChangeDatList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.gapDay = 0;
	local timeData = CTimeFormat:todate(GetServerTime(), false);
	local yearData = split(timeData," ");  --得到现在服务器日期，并取到现在年月日
	local dayData = split(yearData[1],"-");   --得到年月日
	
	self.nowMonth = tonumber(dayData[2]);
	-->>上个月的信息
	local lastNum = self.nowMonth - 1;  --上个月是几月
	if lastNum == 0 then
		lastNum = 12;
		self.lastMonthDayNum = 31;
		self.nowMonthDayNum = 31;
	end
	self.nowDay = tonumber(dayData[3]);
	
	local month31 = {1,3,5,7,8,10,12};
	local month30 = {4,6,9,11};
	
	local rpYear = false;
	for _year = self.oldYear , tonumber(dayData[1]) do
		if _year == tonumber(dayData[1])  then
			local monthNum = self.nowMonth ;
			for _month = self.oldMonth , monthNum - 1 do
				if _month == 2 then
					rpYear = (_year%4==0 and _year%100~=0)or(_year%400==0)
					self.gapDay = (rpYear and 29 or 28) + self.gapDay;
				else
					for j , k in pairs(month31) do
						if _month == k then 
							self.gapDay = self.gapDay + 31;
						end
						if lastNum == k then
							self.lastMonthDayNum = 31;
						end
						if self.nowMonth == k then
							self.nowMonthDayNum= 31;
						end
					end
					for j , k in pairs(month30) do
						if _month == k then 
							self.gapDay = self.gapDay + 30;
						end
						if lastNum == k then
							self.lastMonthDayNum = 30;
						end
						if self.nowMonth == k then
							self.nowMonthDayNum= 30;
						end
					end
				end
			end
		else
			self.gapDay = (((_year%4==0 and _year%100~=0)or(_year%400==0)) and 366 or 365) + self.gapDay;
		end
	end
	if lastNum == 2 then
		if rpYear then
			self.lastMonthDayNum = 29;
		else
			self.lastMonthDayNum = 28;
		end
	end
	if self.nowMonth == 2 then
		local _year = tonumber(dayData[1]);
		if (_year%4==0 and _year%100~=0)or(_year%400==0) then
			self.nowMonthDayNum = 29;
		else
			self.nowMonthDayNum = 28;
		end
	end
	local num = self.gapDay - (7 - self.oldWeek) ;
	self.nowWeek = num % 7;
end

function UIMarryTimeSelect:UpdataDayShow()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local timeData = CTimeFormat:todate(GetServerTime(), false);
	local yearData = split(timeData," ");  --得到现在服务器日期，并取到现在年月日
	local dayData = split(yearData[1],"-");   --得到年月日
	--objSwf.txt_time.htmlText = string.format(StrConfig['registerReward6001'],dayData[1],dayData[2],dayData[3]);
	
	local num = 0;
	for i = 1 , self.nowWeek do
		num = i;
		objSwf['dayItem_' .. i].day.htmlText = string.format(StrConfig['registerReward1004'],self.lastMonthDayNum - (self.nowWeek - i));
		objSwf['dayItem_' .. i].day.ddy = self.lastMonthDayNum - (self.nowWeek - i)
	end
	
	--提前签到天数
	local tiqianNum = 0
	local showTiqianNum = 0;
	
	for i = 1 , self.nowMonthDayNum do
		if i >= self.nowDay then
			if i == self.nowDay then 
				self.curSelecteIndex = self.nowDay
				self.curItemIndex = num + i;
			end;
			objSwf['dayItem_' .. (num + i)].day.htmlText = string.format(StrConfig['registerReward1001'],i);
		-- elseif i >= self.nowDay and i - self.nowDay < 7 then 
		-- 	objSwf['dayItem_' .. (num + i)].day.htmlText = string.format(StrConfig['registerReward1001'],i);
		else
			objSwf['dayItem_' .. (num + i)].day.htmlText = string.format(StrConfig['registerReward1002'],i);
		end
		objSwf['dayItem_' .. (num + i)].day.ddy = i
	end
	local nextNum = 1;
	for i = self.nowMonthDayNum + num , 42 do
		if i > 41 then
			return 
		end
		objSwf['dayItem_' .. (i + 1)].day.htmlText = string.format(StrConfig['registerReward1003'],nextNum);
		objSwf['dayItem_' .. (i + 1)].day.ddy = nextNum
		nextNum = nextNum + 1;
	end


end;