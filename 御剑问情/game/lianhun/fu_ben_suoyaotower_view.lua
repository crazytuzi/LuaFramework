SuoYaoTowerView = SuoYaoTowerView or BaseClass(BaseRender)

SuoYaoTowerView.REWARD_COUNT = 3
local REWARD_PASS = 3
local CHAPTER_TYPE = 4
local STAR_NUM = 3
local FB_TYPE = 0
local SHOW_LEFT_ITEM = 2
local TOTAL_POWER = 200

function SuoYaoTowerView:__init()
	--self
	self.data_instance = SuoYaoTowerData.Instance
	self.select_type = SuoYaoTowerData.ChooseType.Easy
	self.now_chapter = 0 		--章节选择
	self.select_index = 0 		--选择4种难度
	self.old_max_chapter = -1
	self.box_reward = {}
	self.pass_reward = {}
	self.chapter_list = {}
	self.left_list_cell = {}

	self.is_click = {}
	for i = 0, 15 do
		self.is_click[i] = 0
	end

	self.click_list = {}

	self.total_star = 1
	--variable
	self.desc = self:FindVariable("Desc")
	self.slider = self:FindVariable("Slider")
	self.label = self:FindVariable("Label")
	self.reward_text = self:FindVariable("RewardText")
	self.title = self:FindVariable("Title")
	self.name = self:FindVariable("Name")
	self.star_num = self:FindVariable("Star_num")
	self.wake_power = self:FindVariable("WakePower")
	self.cost_power = self:FindVariable("CostPower")
	self.item_num = self:FindVariable("Number")
	self.show_active = self:FindVariable("ShowNumber")
	--event
	self:ListenEvent("OnClickEnter", BindTool.Bind(self.OnClickEnter, self))
	self:ListenEvent("OnClickAdd", BindTool.Bind(self.OnClickAdd, self))
	self:ListenEvent("OnClickSaoDang", BindTool.Bind(self.OnClickSaoDang, self))
	self:ListenEvent("HelpClick", BindTool.Bind(self.OnClickHelp, self))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end

	--obj
	for i = 1, SuoYaoTowerView.REWARD_COUNT do
		local temp = {}
		temp.obj = self:FindObj("Reward_" .. i)
		temp.item = SuoYaoTowerRewardItem.New(temp.obj)
		temp.item.parent_view = self
		temp.item:SetIndex(i - 1)
		self.box_reward[i] = temp
	end

	for i = 1, REWARD_PASS do
		self.pass_reward[i] = ItemCell.New()
		self.pass_reward[i]:SetInstanceParent(self:FindObj("RewardCell_" .. i))
	end

	for i = 1, CHAPTER_TYPE do
		local item_temp = self:FindObj("Item_" .. i)
		self.chapter_list[i] = SuoYaoTowerChapterItem.New(item_temp)
		self.chapter_list[i].parent_view = self
	end

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.left_list = self:FindObj("LeftListView")
	local list_temp = self.left_list.list_simple_delegate
	list_temp.NumberOfCellsDel = BindTool.Bind(self.GetNumOfCell, self)
	list_temp.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self:InitFloor()
	self.left_list.scroller:ReloadData(1)
end

function SuoYaoTowerView:__delete()
	if nil ~= self.chapter_list then
		for k,v in pairs(self.chapter_list) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.chapter_list = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if nil ~= self.box_reward then
		for k,v in pairs(self.box_reward) do
			if v.item then
				v.item:DeleteMe()
				v.item = nil
			end
		end
		self.box_reward = nil
	end

	if nil ~= self.pass_reward then
		for k,v in pairs(self.pass_reward) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.pass_reward = nil
	end
	if nil ~= self.left_list_cell then
		for k,v in pairs(self.left_list_cell) do
			if v then
				v:DeleteMe()
				v = nil
			end
		end
		self.left_list_cell = nil
	end

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.data_instance = nil
end

function SuoYaoTowerView:OpenCallBack()
	self.old_max_chapter = -1
	self:InitFloor()
	self:Flush()
end

function SuoYaoTowerView:InitFloor()
	local data = self.data_instance:GetInfo()

	if nil ~= data then
		self.now_chapter = data.max_chapter
		self.select_index = data.pass_level
	end
end

function SuoYaoTowerView:CloseCallBack()

end

function SuoYaoTowerView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	local other = SuoYaoTowerData.Instance:GetOtherCfg()
	local num = ItemData.Instance:GetItemNumInBagById(other.item_id)
	if num > 0 then
		self.item_cell:SetData({item_id = other.item_id})
		self.show_active:SetValue(true)
		self.item_num:SetValue(ItemData.Instance:GetItemNumInBagById(item_id))
	else
		self.show_active:SetValue(false)
	end

end

--event
function SuoYaoTowerView:OnClickEnter()
	if self.data_instance:CanEnter() then
		self.data_instance:SetChooseInfo(self.now_chapter, self.select_index)
		FuBenCtrl.Instance:SendEnterFBReq(GameEnum.FB_CHECK_TYPE.FBCT_SUOYAOTOWER_FB, nil, self.now_chapter, self.select_index)
	else
		--提示体力不足
		local data = self.data_instance:GetOtherCfg()
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.SuoYaoTower.NotEnoughPower, data.cost_power), 2)
	end
end

function SuoYaoTowerView:OnClickAdd()
	local other = SuoYaoTowerData.Instance:GetOtherCfg()
	local num = ItemData.Instance:GetItemNumInBagById(other.item_id)

	if num > 0 then
		LianhunCtrl.Instance:SendSuoYaoTowerReq(SUOYAOTA_FB_OPERA_REQ_TYPE.SUOYAOTA_FB_OPERA_REQ_TYPE_BUY_POWER)
		return
	end	
	local data = SuoYaoTowerData.Instance:GetBuyPowerCfg()
	if not data then
		SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.MaxManyFB)
		return
	end
	local ok_fun = function()
		LianhunCtrl.Instance:SendSuoYaoTowerReq(SUOYAOTA_FB_OPERA_REQ_TYPE.SUOYAOTA_FB_OPERA_REQ_TYPE_BUY_POWER)
	end

	local cfg = self.data_instance:GetVipBuyTime()
	local str = ""
	local can_buy_time = 0
	if nil ~= cfg then
		local vip_level = GameVoManager.Instance:GetMainRoleVo().vip_level
		local enter_times_max_vip = VipData.Instance:GetEnterTimes(VIPPOWER.SUOYAOTOWER_ENTER_TIMES, VipData.Instance:GetVipMaxLevel())
		if cfg["param_" .. vip_level] == data.has_buy then
			if cfg["param_" .. vip_level] < enter_times_max_vip then
				TipsCtrl.Instance:ShowLockVipView(VIPPOWER.SUOYAOTOWER_ENTER_TIMES)
			else
				SysMsgCtrl.Instance:ErrorRemind(Language.FuBen.MaxManyFB)
			end

			return
		else
			can_buy_time = cfg["param_" .. vip_level] - data.has_buy
		end

		local str = string.format(Language.SuoYaoTower.BuyPower, ToColorStr(data.cost, TEXT_COLOR.BLUE1), ToColorStr(data.add_power, TEXT_COLOR.BLUE1), ToColorStr(can_buy_time, TEXT_COLOR.BLUE1))
		TipsCtrl.Instance:ShowCommonAutoView("", str, ok_fun)
	end

end

function SuoYaoTowerView:OnClickSaoDang()
	if self.data_instance:CanSaoDang() then
		LianhunCtrl.Instance:SendSuoYaoTowerReq(SUOYAOTA_FB_OPERA_REQ_TYPE.SUOYAOTA_FB_OPERA_REQ_TYPE_SAODANG, FB_TYPE, self.now_chapter, self.select_index)
	else
		--提示体力不足
		local data = self.data_instance:GetOtherCfg()
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.SuoYaoTower.NotEnoughPower, data.cost_power), 2)
	end
end

--flush
function SuoYaoTowerView:OnFlush()
	local max_chapter = self.data_instance:GetCanShowListNum()
	if self.old_max_chapter < max_chapter then
		self.old_max_chapter = max_chapter
		self.left_list.scroller:ReloadData(1)
	else
		self.left_list.scroller:RefreshActiveCellViews()
	end

	self:FlushRewardBox()
	self:FlushRewardList()
	self:FlushChapterInfo()
	self:FlushLeftItem()
	self:FlushPower()
	self:FlushTitle()
	-- self:FlushLeftHL()
end

function SuoYaoTowerView:FlushLeftHL()
	for k,v in pairs (self.left_list_cell) do
		if v then
			v:FlushHighLight(self.now_chapter)
		end
	end
end

function SuoYaoTowerView:FlushTitle()
	local data = self.data_instance:GetTitleByChapter(self.now_chapter)

	local asset, bundle = ResPath.GetTitleIcon(data)
	local name = self.data_instance:GetTitleNameByChapter(self.now_chapter)
	if name == nil then
		self.name:SetValue(Language.SuoYaoTower.NoName)
	else
		self.name:SetValue(name)
	end
	self.title:SetAsset(asset, bundle)
end

function SuoYaoTowerView:FlushRewardBox()
	local data = self.data_instance:GetStarRewardByChapter(self.now_chapter)
	if nil == data then
		return
	end

	for i = 1, SuoYaoTowerView.REWARD_COUNT do
		if nil ~= data[i] then
			self.box_reward[i].item:SetData(data[i])
		end
	end

	self.total_star = data[SuoYaoTowerView.REWARD_COUNT].star_num
end

function SuoYaoTowerView:FlushRewardList()
	local data = self.data_instance:GetSingleInfo(self.now_chapter, self.select_index)

	if nil == data[1] then
		return
	end

	local other = SuoYaoTowerData.Instance:GetOtherCfg()
	local num = ItemData.Instance:GetItemNumInBagById(other.item_id)

	if num == 0 then
		self.show_active:SetValue(false)
	else
		self.item_cell:SetData({item_id = other.item_id})
		self.show_active:SetValue(true)
		self.item_num:SetValue(num)
	end	

	local cur_level = self.now_chapter * CHAPTER_TYPE + (self.select_index + 1)
	local item = data[1].first_pass_reward

	local str = Language.SuoYaoTower.FirstPass
	if cur_level <= self.data_instance:GetMaxLevel() then
		item = data[1].normal_reward_item
		str = Language.SuoYaoTower.PassReward
	end
	self.reward_text:SetValue(str)

	for i = 1, REWARD_PASS do
		if nil == item[i - 1] then
			self.pass_reward[i]:SetParentActive(false)
		else
			self.pass_reward[i]:SetParentActive(true)
			self.pass_reward[i]:SetData(item[i - 1])
		end
	end
end

function SuoYaoTowerView:FlushLeftItem()
	local data = self.data_instance:GetSingleInfo(self.now_chapter, self.select_index)
	if nil == data then
		return
	end
end

function SuoYaoTowerView:FlushChapterInfo()
	local data = self.data_instance:GetChapterInfoByChapter(self.now_chapter)
    --设置进度条
	if nil == data then
		return
	end

	self:FlushSlider(data.total_star)
	self.star_num:SetValue(data.total_star)
	for i = 1, CHAPTER_TYPE do
		if nil ~= data.level_info_list[i] then
			self.chapter_list[i]:SetIndex(i - 1)
			self.chapter_list[i]:SetData(data.level_info_list[i])
		end
	end
end

function SuoYaoTowerView:OnClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(271)
end

function SuoYaoTowerView:FlushSlider(num)
	if num > 3 then
		self.slider:SetValue((num - 3) / (self.total_star - 3))
	else
		self.slider:SetValue(num / 2 / (self.total_star - 3))
	end
end

function SuoYaoTowerView:FlushPower()

	local data = self.data_instance:GetOtherCfg()
	local time = data.recover_power_interval / 60	--秒->分钟
	self.wake_power:SetValue(time)
	self.cost_power:SetValue(data.cost_power)
	self.desc:SetValue(string.format(Language.SuoYaoTower.CoseDesc, self.data_instance:GetPower(), data.init_power))
end

function SuoYaoTowerView:GetNumOfCell()
	return self.data_instance:GetCanShowListNum()
end

function SuoYaoTowerView:RefreshCell(cell, data_index)
	local item = self.left_list_cell[cell]
	if nil == item then
		item = SuoYaoTowerFloorItem.New(cell.gameObject)
		self.left_list_cell[cell] = item
		item.parent_view = self
	end

	local data = self.data_instance:GetSingleInfo(data_index, self.is_click[data_index])
	item:SetIndex(data_index)
	item:SetData(data)
	data_index = data_index + 1
end

-------
function SuoYaoTowerView:GetChapter()
	return self.now_chapter
end

function SuoYaoTowerView:SetChapter(index)
	self.now_chapter = index
end

function SuoYaoTowerView:GetSelectIndex()
	return self.select_index
end

function SuoYaoTowerView:SetSelectIndex(index)
	self.select_index = index
end
-------
--上方奖励宝箱
SuoYaoTowerRewardItem = SuoYaoTowerRewardItem or BaseClass(BaseCell)

function SuoYaoTowerRewardItem:__init()
	self.number = self:FindVariable("Number")
	self.icon = self:FindVariable("Icon")

	self.anim = self:FindObj("Icon").animator
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function SuoYaoTowerRewardItem:__delete()
	self.parent_view = nil

	self:RemoveCountDown()
end

function SuoYaoTowerRewardItem:OnFlush()
	if self.data == nil then
		return
	end

	self.chapter = self.parent_view:GetChapter()
	self.flag = SuoYaoTowerData.Instance:GetRewardFlagByIndex(self.chapter)
	self.info = SuoYaoTowerData.Instance:GetChapterInfoByChapter(self.chapter)

	self.number:SetValue(self.data.star_num)

	self:StartCountDown()
end

function SuoYaoTowerRewardItem:ClickItem()
	if self:CanGetReward() then
		--能领奖
		LianhunCtrl.Instance:SendSuoYaoTowerReq(SUOYAOTA_FB_OPERA_REQ_TYPE.SUOYAOTA_FB_OPERA_REQ_TYPE_FETCH_STAR_REWARD, self.chapter, self.index)
	else
		TipsCtrl.Instance:ShowRewardView(self.data.reward)
		--不能领奖 查看奖励显示面板
	end
end

function SuoYaoTowerRewardItem:CanGetReward()
	if self.flag and 0 == self.flag[32 - self.index] and self.info.total_star >= self.data.star_num then
		return true
	end

	return false
end

function SuoYaoTowerRewardItem:StartCountDown()
	if self.count_down then
		self:RemoveCountDown()
	end

	self:CountDown()
	self.count_down = CountDown.Instance:AddCountDown(99999999, 1, BindTool.Bind(self.CountDown, self, nil))
end

function SuoYaoTowerRewardItem:RemoveCountDown()
	if self.count_down then
		CountDown.Instance:RemoveCountDown(self.count_down)
		self.count_down = nil
	end
end

function SuoYaoTowerRewardItem:CountDown()
	local bundle, asset = ResPath.GetGuildBoxIcon(self.index + 2, false)
	if self.flag and 1 == self.flag[32 - self.index] then
		bundle, asset = ResPath.GetGuildBoxIcon(self.index + 2, true)
	end
	self.icon:SetAsset(bundle, asset)

	if self:CanGetReward() then
		self:Shake()
	end
end

function SuoYaoTowerRewardItem:Shake()
	self.anim:SetTrigger("Shake")
end

--章节
SuoYaoTowerChapterItem = SuoYaoTowerChapterItem or BaseClass(BaseCell)

function SuoYaoTowerChapterItem:__init()
	self.show_star = {}

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))

	self.icon_gray = self:FindObj("Icon")
	self.icon = self:FindVariable("Icon")
	self.show_ic_click = self:FindVariable("Show_Is_Click")
	self.fight_num = self:FindVariable("FightNumber")
	self.is_lock = self:FindVariable("IsLock")
	self.is_pass = self:FindVariable("Is_Pass")
	self.is_cur_chapter = self:FindVariable("is_cur_chapter")
	for i = 1, STAR_NUM do
		self.show_star[i] = self:FindObj("Star_" .. i)
	end

	-- self.anim = self:FindObj("Anim")
end

function SuoYaoTowerChapterItem:__delete()
	self.show_star = {}

	self.parent_view = nil
	-- self.anim = nil
end

function SuoYaoTowerChapterItem:OnFlush()
	if nil == self.data then
		return
	end

	for i = 1, STAR_NUM do
		if self.data.pass_star >= i then
			self.show_star[i].grayscale.GrayScale = 0
		else
			self.show_star[i].grayscale.GrayScale = 255
		end
	end

	--战力以及锁
	local chapter = self.parent_view:GetChapter()
	local data = SuoYaoTowerData.Instance:GetSingleInfo(chapter, self.index)
	local num = self.parent_view:GetSelectIndex()

	local lock = (self.parent_view:GetChapter()) * CHAPTER_TYPE + (self.index + 1)

	if lock <= SuoYaoTowerData.Instance:GetMaxLevel() + 1 then
		self.is_lock:SetValue(false)
		self.icon_gray.grayscale.GrayScale = 0
	else
		self.is_lock:SetValue(true)
		self.icon_gray.grayscale.GrayScale = 255
	end

	local level = GameVoManager.Instance:GetMainRoleVo().level

	if lock == SuoYaoTowerData.Instance:GetMaxLevel() + 1 then
		self.is_pass:SetValue(true)
		self.is_cur_chapter:SetValue(true) 
	else
		self.is_pass:SetValue(false)
		self.is_cur_chapter:SetValue(false) 
	end

	if level < data[1].enter_level_limit then
		self.is_lock:SetValue(true)
		self.is_cur_chapter:SetValue(false) 
		self.icon_gray.grayscale.GrayScale = 255
	end

	if lock ~= self.parent_view:GetSelectIndex() and level >= data[1].enter_level_limit then
		local role_cap = GameVoManager.Instance:GetMainRoleVo().capability
		local need_cap = data[1].capability
		if role_cap < need_cap then
			need_cap = ToColorStr(need_cap, TEXT_COLOR.RED)
		end
		self.fight_num:SetValue(string.format(Language.SuoYaoTower.FightNumber, need_cap))
	else
		self.fight_num:SetValue(string.format(Language.SuoYaoTower.ShowLevel, data[1].enter_level_limit))
	end
	self:FlushHl(self.parent_view:GetSelectIndex())
	-- self.anim.animator:SetBool("fold", num == self.index)
end

function SuoYaoTowerChapterItem:ClickItem()
	local click_level = (self.parent_view:GetChapter()) * CHAPTER_TYPE + (self.index + 1)
	local chapter = self.parent_view:GetChapter()
	local data = SuoYaoTowerData.Instance:GetSingleInfo(chapter, self.index)
	local level = GameVoManager.Instance:GetMainRoleVo().level

	if data and level < data[1].enter_level_limit then
		TipsCtrl.Instance:ShowSystemMsg(string.format(Language.SuoYaoTower.Levellimit, data[1].enter_level_limit, 2))
		return
	end

	if click_level > SuoYaoTowerData.Instance:GetMaxLevel() + 1 then
		--提示锁住
		TipsCtrl.Instance:ShowSystemMsg(Language.SuoYaoTower.NeedPassFloor, 2)
		return
	end

	self:ChangeClickIndex()
	self.parent_view.is_click[self.parent_view:GetChapter()] = self.index
	self.parent_view:SetSelectIndex(self.index)
	self.parent_view:Flush()
end

function SuoYaoTowerChapterItem:ChangeClickIndex()
	for k,v in pairs(self.parent_view.is_click) do
		v = 0
	end
end


function SuoYaoTowerChapterItem:FlushHl(index)
	self.show_ic_click:SetValue(self.index == index)
end

--左侧ITEM
SuoYaoTowerFloorItem = SuoYaoTowerFloorItem or BaseClass(BaseCell)

function SuoYaoTowerFloorItem:__init()
	self.model = nil
	self.res_id = 0

	self.name = self:FindVariable("Name")
	self.fight_num = self:FindVariable("FightNumber")
	self.show_hl = self:FindVariable("ShowHL")
	self.show_left = self:FindVariable("ShowLeft")

	local display_left = self:FindObj("DisplayLeft")
	local display_right = self:FindObj("DisplayRight")

	self.model_right = RoleModel.New("suoyao_right_panel")
	self.model_right:SetDisplay(display_right.ui3d_display)

	self.model_left = RoleModel.New("suoyao_left_panel")
	self.model_left:SetDisplay(display_left.ui3d_display)

	self.anim = self:FindObj("Anim")
	self.bgl = self:FindObj("BgL")
	self.bgr = self:FindObj("BgR")

	self:ListenEvent("ClickLeftItem", BindTool.Bind(self.ClickLeftItem, self))
end

function SuoYaoTowerFloorItem:__delete()
	if self.model_left then
		self.model_left:DeleteMe()
		self.model_left = nil
	end

	if self.model_right then
		self.model_right:DeleteMe()
		self.model_right = nil
	end
	self.parent_view = nil
end

function SuoYaoTowerFloorItem:OnFlush()
	if nil == self.data then
		return
	end

	--显示左右
	local t1, t2 = math.modf(self.index / 2)
	if 0 == t2 then
		self.model = self.model_left
		self.show_left:SetValue(false)
	else
		self.model = self.model_right
		self.show_left:SetValue(true)
	end

	-- self.fight_num:SetValue(self.data.capability)
	local str = string.format(Language.SuoYaoTower.Floor, (self.index + 1))

	self:FlushHighLight(self.parent_view:GetChapter())
	--设置模型 monster_0

	self:FlushModel()
	local shake = false
	if self.data and self.data[1] then
		local chapter = self.data[1].chapter or 0
		for i = 1, SuoYaoTowerView.REWARD_COUNT do
			local flag = SuoYaoTowerData.Instance:GetBoxCanReward(chapter, i)
			if flag then
				shake = true
				break
			end
		end
	end
	self:FlushAnimaion(shake)
	if shake then
		str = str .. "·" .. self.data[1].fb_name
		str = str .. ToColorStr(" (" .. Language.Common.KeLingQu .. ")", TEXT_COLOR.GREEN)
		self.name:SetValue(str)
	else
		self.name:SetValue(str .. "·" .. self.data[1].fb_name)
	end
end

function SuoYaoTowerFloorItem:FlushAnimaion(shake)
	GlobalTimerQuest:AddDelayTimer(function ()
		self.bgl.animator:SetBool("shake", shake)
		self.bgr.animator:SetBool("shake", shake)
	end, 0)

end

function SuoYaoTowerFloorItem:ClickLeftItem()
	-- local level = GameVoManager.Instance:GetMainRoleVo().level
	-- if level < self.data[1].enter_level_limit then
	-- 	TipsCtrl.Instance:ShowSystemMsg(string.format(Language.SuoYaoTower.Levellimit, self.data[1].enter_level_limit, 2))
	-- 	return
	-- end

	self.parent_view:SetChapter(self.index)
	self.parent_view:SetSelectIndex(0)
	self.model:SetTrigger("rest1")
	self.parent_view:Flush()
end

function SuoYaoTowerFloorItem:FlushHighLight(index)
	self.show_hl:SetValue(index == self.index)
	self.anim.animator:SetBool("fold", index == self.index)
end

function SuoYaoTowerFloorItem:FlushModel()
	local res_id = BossData.Instance:GetMonsterInfo(self.data[1].monster_0).resid
	if nil == res_id then
		return
	end

	if self.res_id == res_id then
		return
	end

	self.res_id = res_id

	self.model:SetMainAsset(ResPath.GetMonsterModel(res_id))
end

