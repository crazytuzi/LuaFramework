------------------------------------------------------------
--AchieveTitleView		成就称号
------------------------------------------------------------
AchieveTitleView = AchieveTitleView or BaseClass(BaseRender)

local FAST_BUY_ITEM_ID = 22820		-- 快速购买成就物品ID

function AchieveTitleView:__init()
	-- 当前头衔
	self.current_title = AchieveTitleViewGrid.New(self:FindObj("CurrentTitle"))
	-- 下一头衔
	self.next_title = AchieveTitleViewGrid.New(self:FindObj("NextTitle"))
	self.next_title:IsNext(true)
	--进度条
	self.achieve_progress = self:FindVariable("AchieveProgress")
	--进度条文字
	self.achieve_text = self:FindVariable("ProgressText")
	-- 监听升级事件
	self:ListenEvent("TitleUpgadeButton", BindTool.Bind(self.ClickPomoteAchieve, self))
	self:ListenEvent("FastBuyClick", BindTool.Bind(self.FastBuyClick, self))
	--确定初始化完成的flag
	self.init_done = true
	--是否零级
	self.is_zero_level = self:FindVariable("IsZeroLevel")
	--是否满级
	self.is_max_level = self:FindVariable("IsMaxLevel")
	--更新头衔
	self:UpdateTitle()
	--更新进度条
	self:UpdateAchieveProcess()
end

function AchieveTitleView:__delete()
	if self.current_title then
		self.current_title:DeleteMe()
		self.current_title = nil
	end

	if self.next_title then
		self.next_title:DeleteMe()
		self.next_title = nil
	end
end

-- 成就进度条更新
function AchieveTitleView:UpdateAchieveProcess()
	if not self.init_done then
		return
	end
	local current_title_level = AchieveData.Instance:GetTitleLevel()
	local next_title_data = AchieveData.Instance:GetAchieveTitleDataByLevel(current_title_level + 1)
	local mainrole_vo = GameVoManager.Instance:GetMainRoleVo()
	if next_title_data ~= nil then
		self.achieve_progress:SetValue(mainrole_vo.chengjiu/next_title_data.chengjiu)
		self.achieve_text:SetValue(mainrole_vo.chengjiu.."/"..next_title_data.chengjiu)
	else
		self.achieve_progress:SetValue(1)
		self.achieve_text:SetValue(mainrole_vo.chengjiu.."/"..0)
	end
end

--点击了快速购买
function AchieveTitleView:FastBuyClick()
	local func = function(item_id2, item_num, is_bind, is_use)
		MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
	end

	TipsCtrl.Instance:ShowCommonBuyView(func, FAST_BUY_ITEM_ID, nil, 1)
end

function AchieveTitleView:OpenCallBack()
	self:UpdateAchieveProcess()
end

--当前和下一头衔更新
function AchieveTitleView:UpdateTitle()
	if not self.init_done then
		return
	end
	-- 当前头衔
	local current_title_level = AchieveData.Instance:GetTitleLevel()

	local currnet_title_data = AchieveData.Instance:GetAchieveTitleDataByLevel(current_title_level)
	if currnet_title_data ~= nil then
		self.current_title:SetData(currnet_title_data)
		self.is_zero_level:SetValue(false)
	else
		self.is_zero_level:SetValue(true)
	end
	-- 下一头衔
	local next_title_data = AchieveData.Instance:GetAchieveTitleDataByLevel(current_title_level + 1)
	if next_title_data ~= nil then
		self.is_max_level:SetValue(false)
		self.next_title:SetData(next_title_data)
	else
		self.is_max_level:SetValue(true)
	end
end

-- 成就升级按钮按下
function AchieveTitleView:ClickPomoteAchieve()
	AchieveCtrl.Instance:SendTitleUpGrade()
end

----------------------------------------------------------------------------
--AchieveTitleViewGrid		成就称号格
----------------------------------------------------------------------------

AchieveTitleViewGrid = AchieveTitleViewGrid or BaseClass(BaseCell)

function AchieveTitleViewGrid:__init()
	self.attack = self:FindVariable("Atk")
	self.defense = self:FindVariable("Def")
	self.hp = self:FindVariable("HP")
	self.prower = self:FindVariable("Power")
	self.is_next = false

	self.title_list = {}
	local item_manager = self:FindObj("ItemManager")
	local child_number = item_manager.transform.childCount
	for i = 0, child_number - 1 do
		self.title_list[i] = U3DObject(item_manager.transform:GetChild(i).gameObject)
		self.title_list[i].title_name = self.title_list[i]:FindObj("Text")
		self.title_list[i]:SetActive(false)
	end
	self.last_title = self.title_list[1]
end

function AchieveTitleViewGrid:__delete()
	self.is_next = false
end

function AchieveTitleViewGrid:OnFlush()
	-- print_error(">>>>>>>>>>",self.data)
	local show_index = math.ceil((self.data.level/25)-1)
	self.last_title:SetActive(false)
	self.last_title = self.title_list[show_index]
	self.last_title.title_name.text.text = self.data.name
	self.last_title:SetActive(true)

	self.attack:SetValue(self.data.gongji)
	self.defense:SetValue(self.data.fangyu)
	self.hp:SetValue(self.data.maxhp)
	if is_next then
		local current_title_level = AchieveData.Instance:GetTitleLevel()
		local currnet_title_data = AchieveData.Instance:GetAchieveTitleDataByLevel(current_title_level)
		self.prower:SetValue(CommonDataManager.GetCapability(self.data, true, currnet_title_data))
	else
		self.prower:SetValue(CommonDataManager.GetCapability(self.data))
	end
end

function AchieveTitleViewGrid:IsNext(value)
	self.is_next = value
end
