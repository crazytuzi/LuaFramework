--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 
-- @DateTime:    2019-04-11 17:02:28
-- *******************************
RecruitHeroModel = RecruitHeroModel or BaseClass()

function RecruitHeroModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function RecruitHeroModel:config()
	self.day_first_login = true
end

function RecruitHeroModel:setDayFirstLogin(status)
	self.day_first_login = status
end

--获取当前通关的最大关卡
function RecruitHeroModel:getDramaDunMaxID()
	local dun_id = 1
	local drame_controller = BattleDramaController:getInstance()
	local drama_data = drame_controller:getModel():getDramaData()
    if drama_data and drama_data.max_dun_id then
	    local current_dun = Config.DungeonData.data_drama_dungeon_info(drama_data.max_dun_id)
	    if current_dun then
	    	dun_id = current_dun.floor or 1
	    end
	end
    return dun_id
end

--结束时间
function RecruitHeroModel:setRecruitEndTime(end_time)
	local time = end_time - GameNet:getInstance():getTime()
	if time <= 0 then
		self.recruit_status = false
	else
		self.recruit_status = true
	end
end
function RecruitHeroModel:getRecruitEndTime()
	if self.recruit_status then
		return self.recruit_status
	end
	return false
end
function RecruitHeroModel:setRecruitBaseData(data)
	self.recruit_data = {}
	if data.quests then
		for i,v in pairs(data.quests) do
			self.recruit_data[v.id] = v
		end
	end
end
function RecruitHeroModel:getRecruitBaseData(id)
	if self.recruit_data[id] then
		return self.recruit_data[id]
	end
	return nil
end
--计算红点
function RecruitHeroModel:setStatusRedPoint(data)
	if not data then return end
	local info = Config.FunctionData.data_info[MainuiConst.icon.limit_recruit]
	if not info then
		print("Erro:no FunctionData id=", MainuiConst.icon.limit_recruit)
		return
	end

	local bool = MainuiController:getInstance():checkIsOpenByActivate(info.activate)
	if bool == false then return end
	local status = false
	if data.quests then
		for i,v in pairs(data.quests) do
			if v.status == 1 then
				status = true
				break
			end
		end
	end
	local all_get_status = false
	if data.state and data.state == 1 then
		all_get_status = true
	end
	local cur_status = status or all_get_status or self.day_first_login
	MainuiController:getInstance():setFunctionTipsStatus(MainuiConst.icon.limit_recruit, cur_status)
end

function RecruitHeroModel:__delete()
end