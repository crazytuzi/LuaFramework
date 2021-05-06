local CSchedule = class("CSchedule")

--需要盖章的
CSchedule.NeedShowFinishSpr = {
	define.Schedule.ID.YJfuben,
	define.Schedule.ID.MingLei,
	define.Schedule.ID.Pata,
	define.Schedule.ID.OrgFuben,
	define.Schedule.ID.ShiMen,
	define.Schedule.ID.Convoy,
}

function CSchedule.ctor(self, dSchedule)
	self.m_ID = dSchedule.id
	self.m_CDataGetter = function() return DataTools.GetScheduleData(dSchedule.id) end
	self.m_SData = self:CreateSData(dSchedule)
	self.m_ExtraData = {} --需要用到的额外数据通过setvalue设置
end

function CSchedule.CreateSData(self, dSchedule)
	local d = {
		scheduleid = nil,
		done_cnt = 0,		--次数(活跃用)
		maxtimes = nil, 	--最大次数(活跃用)
		activepoint = 0,	--活跃点
		buy = 0,			--购买的次数
		count = 0, 			--当前次数
		sum = 0,			--总次数
		state = 0,			--活动状态 0未开启,1正在进行 2结束
		flag = 0,			--标记(与活动状态独立),各自日程解析这个字段含义
		left = 0,			--剩余次数
	}
	return table.update(d, dSchedule)
end

function CSchedule.UpdateSData(self, dSchedule)
	self.m_SData = self:CreateSData(dSchedule)
end

function CSchedule.NewByScheuldID(id)
	local d = {id = id}
	return CSchedule.New(d)
end

function CSchedule.GetValue(self, k)
	local value = self.m_SData[k]
	if value == nil then
		value = self.m_CDataGetter()[k]
	end
	if value == nil then
		value = self.m_ExtraData[k]
	end
	if k == "mingrade" then
		value = self.m_CDataGetter()["grade"]["min"]
	end
	if k == "maxgrade" then
		value = self.m_CDataGetter()["grade"]["max"]
	end
	return value
end

function CSchedule.SetValue(self, k, v)
	self.m_ExtraData[k] = v
end

function CSchedule.CheckGrey(self)
	local grey = false
	grey = self:CheckGrade() 
		or self:CheckOpenDay() 
		or self:CheckXianShiEnd()
		or self:CheckOpenWeek()
	return grey
end

--当前等级+5级预告
function CSchedule.CheckGrade(self)
	local grey = false
	if g_AttrCtrl.grade < self:GetValue("mingrade") then
		if g_AttrCtrl.grade + 5 >= self:GetValue("mingrade") then
			grey = true
		end
	end
	return grey
end

--开服天数没到
function CSchedule.CheckOpenDay(self)
	local grey = false
	if g_ScheduleCtrl:GetOpenDay() < self:GetValue("openday") then
		grey = true
	end
	return grey
end

--开启的星期X,返回true是没开启
function CSchedule.CheckOpenWeek(self)
	local grey = false
	local iCurWeek = tonumber(g_TimeCtrl:GetTimeWeek())
	if iCurWeek == 0 then
		iCurWeek = 7
	end	
	if not table.index(self:GetValue("openweek"), iCurWeek) then
		grey = true
	end 
	return grey
end

--限时活动已结束
function CSchedule.CheckXianShiEnd(self)
	local grey = false
	if self:GetValue("limit") == define.Schedule.Limit.Xianshi then
		if self:GetValue("state") == define.Schedule.State.End then
			grey = true
		end
	end
	return grey
end

--获取日程时间信息, iBefore, iOpen, iEnd
function CSchedule.GetScheduleTimeInfo(self)
	local timeInfo
	local times = self:GetValue("times")
	if times then
		timeInfo = {}
		local iCur = g_TimeCtrl:GetTimeS() 
		local tCur = os.date("*t", iCur)
		local lOpen, iOpen, lEnd, iEnd, iBefore
		for i,v in ipairs(times) do
			lOpen = string.split(v.opentime, ":")
			iOpen = os.time({
				year=tCur.year, 
				month=tCur.month, 
				day=tCur.day, 
				hour=lOpen[1], 
				min=lOpen[2], 
				sec=0,
			})

			lEnd = string.split(v.endtime, ":")
			iEnd = os.time({
				year=tCur.year, 
				month=tCur.month, 
				day=tCur.day, 
				hour=lEnd[1], 
				min=lEnd[2], 
				sec=0,
			})

			iBefore = iOpen - 1800

			table.insert(timeInfo, {
				index = i,
				iBefore = iBefore,
				iOpen = iOpen,
				iEnd = iEnd,
			})
		end
	end
	return timeInfo
end

function CSchedule.GetDesc(self)
	local txt = ""
	local mingrade = self:GetValue("mingrade")
	if g_AttrCtrl.grade < mingrade then
		txt = string.format("%d级开启", mingrade)
	elseif self:CheckOpenDay() then
		txt = string.format("等级%d级，开服第%d天", mingrade, self:GetValue("openday"))
	elseif self:CheckOpenWeek() then
		local sweek = ""
		for i,v in ipairs(self:GetValue("openweek")) do
			sweek = sweek .. v .. ","
		end
		txt = string.format("每星期%s开启", sweek)
	else
		local limit = self:GetValue("limit")
		if limit == define.Schedule.Limit.Xianshi then
			--特殊处理据点战
			local id = self:GetValue("id")
			if id == define.Schedule.ID.Terrawar then
				txt = self:TerrawarDesc()
			else
				txt = self:GetXianShiDesc()
			end
		else
			txt = self:GetQuanTianDesc()
		end
	end
	return txt
end

--限时活动描述
function CSchedule.GetXianShiDesc(self)
	local state = self:GetValue("state")
	local txt = ""
	if state ==  define.Schedule.State.Open then
		txt = "#R正在开启"
	elseif state ==  define.Schedule.State.End then
		txt = "已结束"
	elseif state == define.Schedule.State.Not then
		--未开启显示开启时间
		local timeInfo = self:GetScheduleTimeInfo()
		if timeInfo then
			local iCurTime = g_TimeCtrl:GetTimeS()
			local iBefore, iOpen, iEnd = 0, 0, 0
			for i,d in ipairs(timeInfo) do
				iBefore = d.iBefore
				iOpen = d.iOpen
				iEnd = d.iEnd
				if iCurTime < iBefore then
					local times = self:GetValue("times")
					txt = times[i]["opentime"].."~"..times[i]["endtime"]
					break
				elseif iCurTime >= iBefore and iCurTime < iOpen then
					txt = "#R即将开启"
					break
				else
					--txt = "未开启"
					local times = self:GetValue("times")
					txt = times[i]["opentime"].."~"..times[i]["endtime"]
				end
			end
		else
			--txt = "未开启"
			local times = self:GetValue("times")
			if times and times[i] then
				txt = times[i]["opentime"].."~"..times[i]["endtime"]
			else
				txt = ""--"全天开放"
			end
		end
	end
	return txt
end

--全天活动描述
function CSchedule.GetQuanTianDesc(self)
	local descFuncs = {
		[define.Schedule.ID.DailyCultivate] = "DailyCultivateDesc",
		[define.Schedule.ID.AnLei] = "AnLeiDesc",
		[define.Schedule.ID.Treasure] = "TreasureDesc",
		[define.Schedule.ID.EqualArena] = "EqualArenaDesc",
		[define.Schedule.ID.FieldBoss] = "FieldBossDesc",
		[define.Schedule.ID.Pata] = "PataDesc",
		[define.Schedule.ID.OrgFuben] = "OrgFubenDesc",
		[define.Schedule.ID.Travel] = "TravelDesc",
		[define.Schedule.ID.PEFb] = "PEFbDesc",
		[define.Schedule.ID.EquipFb] = "EquipFbDesc",
		[define.Schedule.ID.YJfuben] = "YJfubenDesc",
		[define.Schedule.ID.EndlessPVE] = "EndlessPVEDesc",
		[define.Schedule.ID.MingLei] = "MingLeiDesc",
		[define.Schedule.ID.Chapter] = "ChapterDesc",
		[define.Schedule.ID.ShiMen] = "ShiMenDesc",
		[define.Schedule.ID.Convoy] = "ConvoyDesc",
	}
	local descFun = descFuncs[self.m_ID]
	local txt = ""
	if descFun then
		txt = self[descFun](self)
	end
	return txt
end

function CSchedule.DailyCultivateDesc(self)
	local left = self:GetValue("left")
	local txt = string.format("剩余修行%d次", left)
	if left == 0 then
		txt = "#R"..txt
	end
	return txt
end

function CSchedule.AnLeiDesc(self)
	local left = self:GetValue("left")
	local txt = string.format("剩余%d探索点", left)
	if left == 0 then
		txt = "#R"..txt
	end
	return txt
end

function CSchedule.TreasureDesc(self)
	local left = self:GetValue("left")
	local txt = string.format("剩余星象图%d个", left)
	if left == 0 then
		txt = "#R"..txt
	end
	return txt
end

function CSchedule.EndlessPVEDesc(self)
	local left = self:GetValue("left")
	local txt = string.format("剩余镜花水月%d个", left)
	if left == 0 then
		txt = "#R"..txt
	end
	return txt
end

function CSchedule.FieldBossDesc(self)
	local txt = ""
	if self:GetValue("flag") == 1 then
		txt = "#G已出现"
	else
		txt = "#R未出现"
	end
	return txt
end

function CSchedule.TravelDesc(self)
	local txt = ""
	if self:GetValue("flag") == 1 then
		txt = "#G未派遣"
	else
		txt = "#R已派遣"
	end
	return txt
end

function CSchedule.PEFbDesc(self)
	local count = g_AttrCtrl.energy--self:GetValue("left")
	local max_energy = data.globaldata.GLOBAL.max_energy.value
	if g_WelfareCtrl:HasYueKa() then
		max_energy = max_energy + data.chargedata.PRIVILEGE["tili"].yk
	end
	if g_WelfareCtrl:HasZhongShengKa() then
		max_energy = max_energy + data.chargedata.PRIVILEGE["tili"].zsk
	end
	--local sum = data.globaldata.GLOBAL.max_energy.value--self:GetValue("sum")
	local color = ""
	if count == 0 then
		color = "#R"
	end
	local txt = string.format("%s剩余体力%d/%d", color, count, max_energy)
	return txt
end

function CSchedule.EquipFbDesc(self)
	local count = g_AttrCtrl.energy--self:GetValue("left")
	local max_energy = data.globaldata.GLOBAL.max_energy.value
	if g_WelfareCtrl:HasYueKa() then
		max_energy = max_energy + data.chargedata.PRIVILEGE["tili"].yk
	end
	if g_WelfareCtrl:HasZhongShengKa() then
		max_energy = max_energy + data.chargedata.PRIVILEGE["tili"].zsk
	end
	--local sum = data.globaldata.GLOBAL.max_energy.value--self:GetValue("sum")
	local color = ""
	if count == 0 then
		color = "#R"
	end
	local txt = string.format("%s剩余体力%d/%d", color, count, max_energy)
	return txt
end

function CSchedule.YJfubenDesc(self)
	local count = self:GetValue("count")
	local sum = self:GetValue("sum")
	local buy = self:GetValue("buy")
	local color = ""
	if count == sum then
		color = "#R"
	end
	local txt = string.format("%s已挑战%d/%d #G+%d次", color, count, sum, buy)
	return txt
end

function CSchedule.MingLeiDesc(self)
	local count = self:GetValue("count")
	local sum = self:GetValue("sum")
	local buy = self:GetValue("buy")
	local color = ""
	if count == sum then
		color = "#R"
	end
	local txt = string.format("%s已挑战%d/%d #G+%d次", color, count, sum, buy)
	return txt
end

function CSchedule.PataDesc(self)
	local count = self:GetValue("count")
	local sum = self:GetValue("sum")
	local color = ""
	if count == sum then
		color = "#R"
	end
	local txt = string.format("%s可重置%d/%d次", color, count, sum)
	return txt
end

function CSchedule.OrgFubenDesc(self)
	local count = self:GetValue("count")
	local sum = self:GetValue("sum")
	local color = ""
	if count == sum then
		color = "#R"
	end
	local txt = string.format("%s已挑战%d/%d次", color, count, sum)
	return txt
end

function CSchedule.EqualArenaDesc(self)
	local count = self:GetValue("count")
	local sum = self:GetValue("sum")
	local color = ""
	if count == sum then
		color = "#R"
	end
	local txt = string.format("%s本周已获得%d/%d", color, count, sum)
	return txt
end

function CSchedule.ChapterDesc(self)
	local count = g_AttrCtrl.energy--self:GetValue("left")
	local max_energy = data.globaldata.GLOBAL.max_energy.value
	if g_WelfareCtrl:HasYueKa() then
		max_energy = max_energy + data.chargedata.PRIVILEGE["tili"].yk
	end
	if g_WelfareCtrl:HasZhongShengKa() then
		max_energy = max_energy + data.chargedata.PRIVILEGE["tili"].zsk
	end
	--local sum = data.globaldata.GLOBAL.max_energy.value--self:GetValue("sum")
	local color = ""
	if count == 0 then
		color = "#R"
	end
	local txt = string.format("%s剩余体力%d/%d", color, count, max_energy)
	return txt
end

function CSchedule.ShiMenDesc(self)
	local count = self:GetValue("count")
	local sum = self:GetValue("sum")
	local color = ""
	if count == sum then
		color = "#R"
	end
	local txt = string.format("%s已巡查%d/%d", color, count, sum)
	return txt
end

function CSchedule.ConvoyDesc(self)
	local count = self:GetValue("count")
	local sum = self:GetValue("sum")
	local color = ""
	if count == sum then
		color = "#R"
	end
	local txt = string.format("%s已护送%d/%d", color, count, sum)
	return txt
end

function CSchedule.TerrawarDesc(self)
	local txt = ""
	if g_TerrawarCtrl:IsKaiqi() then
		txt = "#R正在进行"
	elseif g_TerrawarCtrl:IsYure() then
		txt = "#R即将开启"
	else
		local nexttime = g_TerrawarCtrl:GetNextLeftTime()
		txt = nexttime.."后开启"
	end
	return txt
end

function CSchedule.GetSort(self)
	local sort
	if self:GetValue("limit") == define.Schedule.Limit.Xianshi then
		sort = self:GetXianShiSort()
	else
		sort = self:GetQuanTianSort()
	end
	--printc(sort, self:GetValue("name"))
	return sort
end

function CSchedule.GetQuanTianSort(self)
	--1已开启活动-2预告活动-3已完成活动-4需要盖章的
	local sort
	local curGrade = g_AttrCtrl.grade
	local addGrade = curGrade + 5
	local mingrade = self:GetValue("mingrade")
	if curGrade >= mingrade then
		if self:GetValue("count") < (self:GetValue("sum") + self:GetValue("buy")) 
			 or self:GetValue("flag") == 1
			 or self:GetValue("left") > 0 then
			sort = 1
		elseif self:GetValue("count") == (self:GetValue("sum") + self:GetValue("buy"))
			 or self:GetValue("flag") == 0 
			 or self:GetValue("left") == 0 then
			if table.index(CSchedule.NeedShowFinishSpr, self.m_ID) then
				sort = 4
			else
				sort = 3
			end
		end
	elseif addGrade >= mingrade then
		sort = 2
	end
	return sort
end

function CSchedule.GetXianShiSort(self)
	--1正在开启-2即将开启-3未开启（但开放了）-4预告-5结束
	local sort
	local curGrade = g_AttrCtrl.grade
	local addGrade = curGrade + 5
	local mingrade = self:GetValue("mingrade")
	local state = self:GetValue("state")
	local iCurTime = g_TimeCtrl:GetTimeS()
	if curGrade >= mingrade then
		if state == define.Schedule.State.Open then
			sort = 1
		elseif state == define.Schedule.State.End then
			sort = 5
		else
			local timeInfo = self:GetScheduleTimeInfo()
			if timeInfo then
				local iCurTime = g_TimeCtrl:GetTimeS()
				local iBefore, iOpen, iEnd = 0, 0, 0
				for i,d in ipairs(timeInfo) do
					iBefore = d.iBefore
					iOpen = d.iOpen
					iEnd = d.iEnd
					if iCurTime < iBefore then
						sort = 3
						break
					elseif iCurTime >= iBefore and iCurTime < iOpen then
						sort = 2
						break
					else
						sort = 5 --这里不能用break。
					end
				end
			else
				sort = 2
			end
		end
	elseif addGrade >= mingrade then
		sort = 4
	end
	return sort
end 

function CSchedule.GetSortValue(self)
	--1限时正在开启,2限时即将开启,3未开启(未完成),4已结束(已完成)
	local sort = 3
	if self:GetValue("limit") == define.Schedule.Limit.Xianshi then
		local state = self:GetValue("state")
		if state == define.Schedule.State.Open then
			sort = 1
		elseif state == define.Schedule.State.End then
			sort = 4
		else
			local timeInfo = self:GetScheduleTimeInfo()
			if timeInfo then
				local iCurTime = g_TimeCtrl:GetTimeS()
				local iBefore, iOpen, iEnd = 0, 0, 0
				for i,d in ipairs(timeInfo) do
					iBefore = d.iBefore
					iOpen = d.iOpen
					iEnd = d.iEnd
					if iCurTime < iBefore then
						sort = 3
						break
					elseif iCurTime >= iBefore and iCurTime < iOpen then
						sort = 2
						break
					end
				end
			end
		end
	end	
	local done_cnt = self:GetValue("done_cnt") 
	local maxtimes = self:GetValue("maxtimes")
	local maxactive = self:GetValue("maxactive")
	if maxtimes > 0 and done_cnt == maxtimes then
		sort = 5
	end
	return sort
end

return CSchedule