
DayCounterData = DayCounterData or BaseClass(BaseController)

function DayCounterData:__init()
	if DayCounterData.Instance ~= nil then
		ErrorLog("[DayCounterData] attempt to create singleton twice!")
		return
	end
	DayCounterData.Instance = self

	self.day_count_list = {}
end

function DayCounterData:__delete()
	DayCounterData.Instance = nil
end

function DayCounterData:SetDayCount(day_counter_id, count)
	self.day_count_list[day_counter_id] = count
end

function DayCounterData:GetRealDayCount(day_counter_id)
	return self.day_count_list[day_counter_id]
end

function DayCounterData:GetDayCount(day_counter_id)
	if nil ~= self.day_count_list[day_counter_id] then
		return self.day_count_list[day_counter_id]
	end

	return 0
end
