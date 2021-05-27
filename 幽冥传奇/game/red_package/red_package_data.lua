RedPackageData = RedPackageData or BaseClass()

function RedPackageData:__init()
	if RedPackageData.Instance then
		ErrorLog("[RedPackageData]:Attempt to create singleton twice!")
	end
	RedPackageData.Instance = self

	self:InitRedPaperInfo()
	self.rend_data = self:GetDatata()
end

function RedPackageData:__delete()
	RedPackageData.Instance = nil
end

function RedPackageData:InitRedPaperInfo()
	self.palyer_info = {}
	self.my_rank = 0
	self.my_donate_yb = 0
	self.my_rob_num = 0
	self.remaind_yb = 0
	self.rob_yb_info = {}
	self.rob_yb_num = 0
	self.count_down = 0
	self.my_rob_yb_num = 0
	self.recv_type = 0
	self.front_donate = 0
end

function RedPackageData:SetRedPaperInfo(protocol)
	self.recv_type = 0
	self.palyer_info = protocol.palyer_info
	self.my_rank = protocol.my_ranking
	self.my_donate_yb = protocol.my_donate_yb
	-- self.my_rob_num = protocol.my_rob_num
	self.remaind_yb = protocol.remaind_yb
	self.rob_yb_num = protocol.rob_money
	self.count_down = protocol.count_down + Status.NowTime
	self.front_donate = protocol.front_donate 
	local vip_lev = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	self.my_rob_num = self:GetAwardCount(vip_lev) - protocol.my_rob_num
	GlobalEventSystem:Fire(OtherEventType.ICON_REMIND_TXT_CHANGE, RemindGroupName.RedPackage, self.my_rob_num)
	for k, v in pairs(self.rend_data) do
		local info = self.palyer_info[k]
		if info then
			v.player_name = info.player_name
			v.money = info.donate_money
		else
			v.player_name = Language.RedPaper.NoPer
			v.money = 0
		end
	end

	for _,v in pairs(protocol.rob_yb_info) do
		table.insert(self.rob_yb_info,v)
	end	
end

function RedPackageData:GetRankInfoData()
	return self.rend_data
end

function RedPackageData:GetRobInfoData()
	return self.rob_yb_info
end

function RedPackageData:GetRecvDataType()
	return self.recv_type
end

-- 上一名捐献
function RedPackageData:GetFrontDonate()
	return self.front_donate
end

function RedPackageData:GetPersonalInfoData()
	return self.my_rank, self.my_donate_yb, self.remaind_yb
end

function RedPackageData:GetNotVipRobNum()
	return self.rob_yb_num, self.count_down, self.my_rob_num
end

function RedPackageData:GetDatata()
	local cur_data = {}
	for i = 1, 5 do
		cur_data[i]= {
			money = 0,
			player_name = Language.RedPaper.NoPer,
			rank = i,
		}
	end
	return cur_data
end

function RedPackageData:GetGiftRemaind(index)
	local data = {}
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	if index == 1 then
		local buff_cfg = StdBuff[buff_id_1]
		for i = 1, 2 do
			local buff_id = NationwideRedPacketsConfig.awardMinBuffList[prof][i]
			local buff_cfg = StdBuff[buff_id] 
			if buff_cfg then
				local cur_data = {buff_id = buff_cfg.id, buff_type = buff_cfg.type, buff_group = buff_cfg.group, is_no_show_cd = true, buff_name = buff_cfg.name, buff_value = buff_cfg.value, buff_icon = buff_cfg.icon}
				table.insert(data, cur_data)
			end
		end
	else
		local rank_buff_cfg = NationwideRedPacketsConfig.RankAwards[index] and NationwideRedPacketsConfig.RankAwards[index].awardBuffList
		if rank_buff_cfg then
			for i = 1, 2 do
				buff_id = rank_buff_cfg[prof][i]
				buff_cfg = StdBuff[buff_id] 
				if buff_cfg then
					local cur_data = {buff_id = buff_cfg.id, buff_type = buff_cfg.type, buff_group = buff_cfg.group, is_no_show_cd = true, buff_name = buff_cfg.name, buff_value = buff_cfg.value, buff_icon = buff_cfg.icon}
					table.insert(data, cur_data)
				end
			end
		end
	end
	return data
end

function RedPackageData:GetRedPaperRemindNum()
	local vis = 0
	if self.remaind_yb > 0 then
		if vip_lev == 0 then
			vis = 2
		else
			if self.my_rob_num == 0 then
				vis = 0
			else
				vis = 1
			end
		end
	else
		vis = 0
	end
	return vis
end

function RedPackageData:SetRobPaperShow(protocol)
	self.remain_yb = protocol.remain_yb
	-- self.my_rob_num = protocol.my_rob_num
	self.my_rob_yb_num = protocol.money_num
	local vip_lev = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	self.my_rob_num = self:GetAwardCount(vip_lev) - protocol.my_rob_num

	GlobalEventSystem:Fire(OtherEventType.ICON_REMIND_TXT_CHANGE, RemindGroupName.RedPackage, self.my_rob_num)
	local vip_lev = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
	if vip_lev <= 0 then
		self.rob_yb_num = self.my_rob_yb_num
	end
	self.count_down = protocol.meter_time + Status.NowTime
	self.recv_type = 1
end

function RedPackageData:GetMeterTime()
	return self.remain_yb, self.count_down, self.my_rob_num, self.my_rob_yb_num
end

function RedPackageData:GetAwardCount(level)
	local data = NationwideRedPacketsConfig.dailyGetAwardCount
	for k, v in pairs(data) do
		if level == v.vipLevel then
			return v.dailyCount
		end
	end
	return 0
end

