HeroExpeditModel = HeroExpeditModel or BaseClass()

local table_insert = table.insert
function HeroExpeditModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function HeroExpeditModel:config()
	self.isChangeRedPointStatus = 0
	self.sendRedPointStatus = 0
end


--难度选择
function HeroExpeditModel:setDifferentChoose(different)
	self.different = different
end
function HeroExpeditModel:getDifferentChoose()
	if self.different then
		return self.different
	end
	return 0
end
-- --远征的主界面数据
function HeroExpeditModel:setExpeditData(data)
	if not data then return end
	self.expeditData = data
	local status = self:checkRedStatus()
	MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.esecsice, {bid=RedPointType.heroexpedit, status=status}) 
end

function HeroExpeditModel:getExpeditData()
	if self.expeditData then
		return self.expeditData
	end
	return {}
end
--支援我的
function HeroExpeditModel:setEmployHelpMeData(data)
	self.help_me_data = data
end
function HeroExpeditModel:getEmployHelpMeData()
	if self.help_me_data then
		return self.help_me_data
	end
	return {}
end

--是否存在挑战红点
function HeroExpeditModel:setIsChangeRedPoint(status)
	self.isChangeRedPointStatus = status
end
--是否可以存在有派遣宝可梦
function HeroExpeditModel:setHeroSendRedPoint(status)
	local open_data = Config.DailyplayData.data_exerciseactivity
	if open_data[EsecsiceConst.exercise_index.heroexpedit] == nil then 
		return
	end
	local bool = MainuiController:getInstance():checkIsOpenByActivate(open_data[EsecsiceConst.exercise_index.heroexpedit].activate)
	if bool == false then 
		return
	end

	self.sendRedPointStatus = status
	GlobalEvent:getInstance():Fire(HeroExpeditEvent.Expedit_RedPoint_Event)

	--[[ local red_point = false
	if status == 1 then
		red_point = true
	end
	MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.esecsice, {bid=RedPointType.heroexpedit, status=red_point})  ]]
end
function HeroExpeditModel:getHeroSendRedPoint()
	return false
	--[[ if self.sendRedPointStatus == 1 then
		return true
	else
		return false
	end ]]
end
--远征红点
function HeroExpeditModel:checkRedStatus()
	return false
	--[[ local open_data = Config.DailyplayData.data_exerciseactivity
	if open_data[EsecsiceConst.exercise_index.heroexpedit] == nil then 
		return false
	end
	local bool = MainuiController:getInstance():checkIsOpenByActivate(open_data[EsecsiceConst.exercise_index.heroexpedit].activate)
	if bool == false then return false end
	local num = self.isChangeRedPointStatus + self.sendRedPointStatus
    local status = false
    if num <= 0 then
    	status = false
    else
    	status = true
    end
    return status ]]
end
-- --获取宝箱的位置
function HeroExpeditModel:getExpeditBoxData()
	local box = {}
	local data = Config.ExpeditionData.data_sign_info
	for i,v in ipairs(data) do
		if v.type == 2 then
			table.insert(box,i)
		end
	end
	return box
end

--血条
function HeroExpeditModel:setHeroBloodById(data)
	self.HeroBloodData = {}
	self.hireHeroData = {}
	self.hireHeroIsUsedData = {} --雇佣的宝可梦是否使用过
	self:setExpeditEmployData(data.list)
	--本身的
	local role_vo = RoleController:getInstance():getRoleVo()
	local rid = 0
	local srv_id = ""
	if role_vo then
		rid = role_vo.rid
		srv_id = role_vo.srv_id
	end
	for i,v in ipairs(data.p_list) do
		local key = getNorKey(rid, srv_id, v.id)
		self.HeroBloodData[key] = v.hp_per
	end
	--雇佣的
	if next(data.list) ~= nil then
		for i,v in pairs(data.list) do
			local key = getNorKey(v.rid, v.srv_id, v.id)
			self.hireHeroData[key] = true
			self.HeroBloodData[key] = v.hp_per
			self.hireHeroIsUsedData[key] = v.is_used
		end
	end
end
function HeroExpeditModel:getHeroBloodById(id, rid, srv_id)
    if not self.HeroBloodData then return 100 end
    if not id or type(id) ~= "number" then return 100 end
	rid = rid or 0
	srv_id = srv_id or ""
	local key = getNorKey(rid, srv_id, id)
    return self.HeroBloodData[key] or 100
end
--雇佣的
function HeroExpeditModel:getHireHero(id, rid, srv_id)
	if not self.hireHeroData then return false end
    if not id or type(id) ~= "number" then return false end
	rid = rid or 0
	srv_id = srv_id or ""
	local key = getNorKey(rid, srv_id, id)
    return self.hireHeroData[key] or false
end
--雇佣使用的
function HeroExpeditModel:getHireHeroIsUsed(id, rid, srv_id)
	if not self.hireHeroIsUsedData then return 0 end
    if not id or type(id) ~= "number" then return 0 end
	rid = rid or 0
	srv_id = srv_id or ""
	local key = getNorKey(rid, srv_id, id)
    return self.hireHeroIsUsedData[key] or 0
end

--宝可梦出征的雇佣宝可梦
function HeroExpeditModel:setExpeditEmployData(data)
	self.expeditEmployData = data
end
function HeroExpeditModel:getExpeditEmployData()
	return self.expeditEmployData or {}
end

function HeroExpeditModel:__delete()
end