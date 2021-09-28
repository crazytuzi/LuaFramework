SuoYaoTowerData = SuoYaoTowerData or BaseClass(BaseEvent)

SuoYaoTowerData.ChooseType =
{
	Easy = 1,
	Normal = 2,
	Hard = 3,
	WarFrame = 4,
}

local LEVEL_COUNT = 4

function SuoYaoTowerData:__init()
    if SuoYaoTowerData.Instance then
        print_error("[SuoYaoTowerData] Attempt to create singleton twice!")
        return
    end

    SuoYaoTowerData.Instance = self
    --配置信息
    self.all_cfg = ConfigManager.Instance:GetAutoConfig("suoyaota_fb_auto")
    self.fb_info = ListToMapList(self.all_cfg.fb_info, "chapter", "level")
    self.star_reward = ListToMapList(self.all_cfg.star_reward, "chapter")
    self.title = self.all_cfg.title_cfg
    self.chapter_head = self.all_cfg.chapter
    self.other_cfg = self.all_cfg.other[1]
    self.power_buy = self.all_cfg.power_buy
    --从服务端获取的信息
    self.fb_info_list = {}
    self.fb_result_list = {}
    self.fb_single_list = {}
    self.chapter_info_list = {}
    self.result_info = {}
    self.title_ser = {}
    self.vector_list = {star = 0}
    self.info = {max_chapter = 0, pass_level = 0, today_join_times = 0,buy_join_times = 0}
    self.power = 0
    self.star = 0
    self.report_num = 0

	--
	self.reward_flag = {}
	self.chapter = 0
	self.level = 1
	RemindManager.Instance:Register(RemindName.SuoYaoTower, BindTool.Bind(self.GetRemind, self))
end

function SuoYaoTowerData:__delete()
	if RemindManager.Instance then
		RemindManager.Instance:UnRegister(RemindName.SuoYaoTower)
	end
	SuoYaoTowerData.Instance = nil
end

--set
function SuoYaoTowerData:SetFbTowerInfo(protocol)
	local temp = protocol.fb_info_list
	if temp.pass_chapter >= 10 then  ----------delay do
		self.report_num = temp.pass_chapter
		self.info.max_chapter = 9
	else
		self.info.max_chapter = temp.pass_chapter
	end

	if temp.pass_level == -1 then
		self.info.pass_level = 0
	else
		self.info.pass_level = temp.pass_level
	end

    self.info.today_join_times = temp.today_join_times

	for i = 1, 50 do
		local temp_1 = {}
		local list = {}
		temp_1 = temp.chapter_info_list[i]
		list = bit:d2b(temp_1.star_reward_flag)
		self.reward_flag[i] = list
		self.chapter_info_list[i] = temp_1
	end
end

function SuoYaoTowerData:SetTitle(protocol)
	self.title_ser = protocol
end

function SuoYaoTowerData:SetFbTowerResultInfo(protocol)
	self.fb_result_list = protocol.reward_item_list

	self.vector_list.star = protocol.star or 0
end

function SuoYaoTowerData:SetFbTowerSingleInfo(protocol)
	-- local index = protocol.chatper or 0
	-- local list = bit:d2b(protocol.star_reward_flag)
	-- self.reward_flag[protocol.chatper + 1] = list
	-- -- self.info.max_chapter = protocol.chatper
	-- self.chapter = protocol.cur_chapter

	-- self.level = protocol.cur_level
	-- -- self.info.pass_level = protocol.level
	-- self.fb_single_list[index] = protocol

	-- if self.chapter_info_list[self.chapter + 1] then
	-- 	self.chapter_info_list[self.chapter + 1].level_info_list.pass_star = protocol.layer_info.pass_star
	-- end

	self.vector_list.data = {}
	self.vector_list.pass_time = protocol.pass_time_s
	self.vector_list.show_star = true
	self.vector_list.cancle_text = Language.Common.Confirm
end

function SuoYaoTowerData:SetVectorStar()
	local reward = {}
	local data = self:GetChooseInfo()
	local next_data = self:GetSingleInfo(self.chapter, self.level + 1)

	for k,v in pairs(self.fb_result_list) do
		if 0 ~= v.item_id then
			reward[k] = v
		end
	end

	self.vector_list.data = reward
	self.vector_list.cancle_text = Language.Common.Confirm
	self.vector_list.show_next = false
	LianhunCtrl.Instance:FlushVector(self.vector_list)
end

function SuoYaoTowerData:SetPower(protocol)
	self.power = protocol.power or 0
	self.info.buy_join_times = protocol.buy_join_times or 0
end

function SuoYaoTowerData:SetChooseInfo(chapter, level)
	self.chapter = chapter
	self.level = level
end

function SuoYaoTowerData:SetFBResultInfo(protocol)
	self.result_info = protocol
	self.vector_list.pass_time = protocol.pass_time_s

	if 1 == protocol.is_finish and 1 == protocol.is_pass then
		self:SetVectorStar()
	end
end

function SuoYaoTowerData:GetCanPass()
	return self.result_info.is_pass
end

--get
function SuoYaoTowerData:GetAllCfg()
	return self.all_cfg
end

function SuoYaoTowerData:GetPower()
	return self.power
end

function SuoYaoTowerData:GetVipBuyTime()
	local buy_time_cfg = VipData.Instance:GetVipLevelCfg()
	return buy_time_cfg[39]
end


function SuoYaoTowerData:GetInfo()
	return self.info
end

function SuoYaoTowerData:GetCanShowListNum()
	local temp = GetListNum(self:GetFbInfo())
	local num = self.info.max_chapter

	if num < 2 then
		return 2
	end

	return num + 1
end

function SuoYaoTowerData:GetBuyPowerCfg()
	local temp =  nil
	for k,v in pairs(self.power_buy) do
		if v.buy_times_min == (self.info.buy_join_times + 1) then
			temp = {cost = 0, time = 0, has_buy = 0}
			temp.time = v.buy_times_min
			temp.cost = v.cost_gold
			temp.add_power = self.other_cfg.add_power
			temp.has_buy = self.info.buy_join_times
			break
		end
	end

	return temp
end

function SuoYaoTowerData:GetMaxLevel()
	--9是临街值
	if 0 ~= self.report_num then
		return (self.info.max_chapter + 1) * LEVEL_COUNT + self.info.pass_level
	end
	return self.info.max_chapter * LEVEL_COUNT + self.info.pass_level
end

function SuoYaoTowerData:GetFbInfoByChapter(index)
	return self.fb_info[index]
end

function SuoYaoTowerData:GetFbInfo()
	return self.fb_info
end

function SuoYaoTowerData:GetTitleByChapter(index)
	for k,v in pairs(self.title) do
		if v.chapter == index then
			return v.title_id
		end
	end

	return 0
end

function SuoYaoTowerData:GetSingleInfo(index, level)
	local data = self.fb_info[index]
	if nil == data then
		return nil
	end

	return data[level]
end

function SuoYaoTowerData:GetChapterInfoByChapter(index)
	return self.chapter_info_list[index + 1]
end

function SuoYaoTowerData:GetStarRewardByChapter(index)
	return self.star_reward[index]
end

function SuoYaoTowerData:GetChapterHeadByChapter(index)
	return self.chapter_head[index]
end

function SuoYaoTowerData:CanSaoDang()
	return self.power >= self.other_cfg.cost_power
end

function SuoYaoTowerData:GetOtherCfg()
	return self.other_cfg
end

function SuoYaoTowerData:CanEnter()
	return self.power >= self.other_cfg.cost_power
end

function SuoYaoTowerData:GetRewardFlagByIndex(index)
	return self.reward_flag[index + 1]
end

function SuoYaoTowerData:GetTitleNameByChapter(index)
	local temp = index + 1
	return self.title_ser[temp]
end

function SuoYaoTowerData:GetChooseInfo()
	return self:GetSingleInfo(self.chapter, self.level)
end

function SuoYaoTowerData:GetIsFirst()
	local num = (self.chapter) * LEVEL_COUNT + (self.level)

	return num == self:GetMaxLevel()
end

function SuoYaoTowerData:GetChapterChooseInfo()
	return self:GetChapterHeadByChapter(self.chapter + 1)
end

--get
function SuoYaoTowerData:GetRemind()
	local num = 0
	if self:CheckRedPoint() then
		num = 1
	end

	return num
end

function SuoYaoTowerData:CanGetReward()
	for i=1, self.info.max_chapter + 1 do
		for j=0, SuoYaoTowerView.REWARD_COUNT - 1 do
			local data = self:GetStarRewardByChapter(i)
			if self.reward_flag[i] and 0 == self.reward_flag[i][32 - j]
				and self.chapter_info_list[i] and data and data[j + 1] and self.chapter_info_list[i].total_star >= data[j + 1].star_num then
				return true
			end
		end
	end
	return false
end

function SuoYaoTowerData:CheckRedPoint()
	if self:CanGetReward() then
		return true
	end
	if ClickOnceRemindList[RemindName.SuoYaoTower] == 1 and self:CanEnter() then
		return true
	end
	return false
end

function SuoYaoTowerData:GetBoxCanReward(chapter, index)
	 local cur_chapter = chapter + 1
	 local flag = self.reward_flag[cur_chapter]
	 if nil == flag then
	   return false
	  end

	 local max_star = self.chapter_info_list[cur_chapter].total_star
	 local data = self:GetStarRewardByChapter(cur_chapter)
	 if nil == data or nil == data[index] then
	   return false
	 end
	 local temp = data[index]
	 local num = temp.star_num
	 if max_star >= num and 0 == flag[(32 - index) + 1] then
	   return true
	 end

	 return false

end