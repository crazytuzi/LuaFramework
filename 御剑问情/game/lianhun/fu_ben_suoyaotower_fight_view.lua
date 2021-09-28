SuoYaoTowerFightView = SuoYaoTowerFightView or BaseClass(BaseView)

local STAR_NUM = 3

function SuoYaoTowerFightView:__init()
	self.ui_config = {"uis/views/lianhun_prefab","SuoYaoTowerFightView"}

	self.time_index = 3
	self.start_time = 0
	self.star_list = {}
	self.data = {}
end

function SuoYaoTowerFightView:LoadCallBack()
	--variable
	self.task_number = self:FindVariable("TaskNumber")
	self.finish_num = self:FindVariable("FinishNumber")
	self.fight_num = self:FindVariable("FightNumber")
	self.time = self:FindVariable("Time")
	self.star_num = self:FindVariable("Star")
	self.name = self:FindVariable("Name")
	self.down_time = self:FindVariable("DownTime")
	self.chapter_name = self:FindVariable("ChapterName")
	self.show_time = self:FindVariable("ShowTime")
	
	for i = 1, STAR_NUM do
		self.star_list[i] = self:FindObj("Star_" .. i)
	end

	self:Flush()
end

function SuoYaoTowerFightView:__delete()
	
end

function SuoYaoTowerFightView:ReleaseCallBack()
	self:CloseTime()

	self.task_number = nil
	self.finish_num = nil
	self.fight_num = nil
	self.time = nil
	self.star_num = nil
	self.name = nil
	self.down_time = nil
	self.chapter_name = nil
	self.show_time = nil

	self.star_list = {}
end

function SuoYaoTowerFightView:OpenCallBack()
	self:Flush()
end

function SuoYaoTowerFightView:CloseCallBack()

end

function SuoYaoTowerFightView:OnFlush(param_t)
	self:InitInfo()

	self:InitData()
	self:FlushInfo()
	self:FlushStar()
	self:FlushTime()
end

function SuoYaoTowerFightView:InitInfo()
	self.time_index = 3
	self.start_time = TimeCtrl.Instance:GetServerTime()
end

function SuoYaoTowerFightView:CloseTime()
	if self.timequest then
		GlobalTimerQuest:CancelQuest(self.timequest)
		self.timequest = nil
	end
end

function SuoYaoTowerFightView:FlushTime()
	local cfg = self.cfg[1]
	self.star_num:SetValue(self.time_index - 1)
	self:CloseTime()
	if nil == self.timequest then
		self.timequest = GlobalTimerQuest:AddRunQuest(function()
				local time = 0
				if cfg["time_limit_".. self.time_index .."_star"] then
					time = cfg["time_limit_".. self.time_index .."_star"] + self.start_time
				else
					return
				end
				local next_time = time - TimeCtrl.Instance:GetServerTime()
				self.time:SetValue(next_time)
				if next_time <= 0 then
					self.time_index = self.time_index - 1
					self.star_num:SetValue(self.time_index - 1)
					self:FlushStar()
					self:InitData()
					self:FlushInfo()
				end
			end,0)
	end
end

function SuoYaoTowerFightView:InitData()
	self.data = SuoYaoTowerData.Instance:GetChapterChooseInfo()
	self.cfg = SuoYaoTowerData.Instance:GetChooseInfo()
end

function SuoYaoTowerFightView:FlushStar()
	for i = 1, STAR_NUM do
		if self.time_index >= i then
			self.star_list[i].grayscale.GrayScale = 0
		else
			self.star_list[i].grayscale.GrayScale = 255
		end
	end
end

function SuoYaoTowerFightView:FlushInfo()
	if nil == self.data then
		return
	end

	self.chapter_name:SetValue(self.data.fb_name)
	if 1 < self.time_index then
		self.show_time:SetValue(false)
	elseif 1 == self.time_index then
		self.show_time:SetValue(true)
	end

	if self.cfg[1].monster_0 then
		local name = BossData.Instance:GetMonsterInfo(self.cfg[1].monster_0).name
		self.name:SetValue(name)
	end
end

