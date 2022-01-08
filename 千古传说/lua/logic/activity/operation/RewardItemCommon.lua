
local RewardItem = class("RewardItem", BaseLayer)

function RewardItem:ctor(type, rewardId, desc1, desc2, index)
	-- 
    self.super.ctor(self)

    self.type = type
    self.title = title
    self.name = name

    self.activityId		= id
    self.activityType 	= type
    self.rewardId  		= rewardId
    self.desc1 			= desc1
    self.desc2  		= desc2
    self.index  		= index

    self:loadRewardConfigure()

    self:init("lua.uiconfig_mango_new.operatingactivities.RewardItem")
end

function RewardItem:initUI(ui)
    self.super.initUI(self,ui)
    self.txt_title 					= TFDirector:getChildByPath(ui, 'txt_title')
    self.txt_name 					= TFDirector:getChildByPath(ui, 'txt_name')
    self.img_ylq 					= TFDirector:getChildByPath(ui, 'img_ylq')
    self.txt_desc1					= TFDirector:getChildByPath(ui, 'txt_desc1')
    self.txt_desc2					= TFDirector:getChildByPath(ui, 'txt_desc2')

    self.panel_rewardnum			= TFDirector:getChildByPath(ui, 'panel_rewardnum')
    self.txt_rewardnum				= TFDirector:getChildByPath(ui, 'txt_rewardnum')

    -- 用于按钮下面的字体显示
    self.txt_maxwarning				= TFDirector:getChildByPath(ui, 'txt_maxwarning')

    self.item = {}
    for i=1,3 do
    	self.item[i] = {}
    	self.item[i].bg 			= TFDirector:getChildByPath(ui, 'img_bg_' .. i)
    	self.item[i].icon 			= TFDirector:getChildByPath(ui, 'img_icon_' .. i)
    	self.item[i].number 		= TFDirector:getChildByPath(ui, 'txt_number_' .. i)
    end

    self.btn_get 					= TFDirector:getChildByPath(ui, 'btn_get')
    self.btn_get.logic = self

    if self.txt_desc1 then
    	self.txt_desc1:setText(self.desc1)
    end

    if self.txt_desc2 then
    	self.txt_desc2:setText(self.desc2)
    end
end

function RewardItem:removeUI()
    self.super.removeUI(self)
end

function RewardItem:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function RewardItem:dispose()
    self.super.dispose(self)
end

--[[
刷新界面
]]
function RewardItem:refreshUI()
	local rewardItems = self.rewardItems -- self.rewardConfigure:getReward()

	local itemCount = rewardItems:length()
	for i=1,3 do
		if i <= itemCount then
			self.item[i].bg:setVisible(true)
			local item = rewardItems:objectAt(i)
			local info = BaseDataManager:getReward(item)
			if item.res_type == EnumDropType.GOODS then
				local goodsData = ItemData:objectByID(item.res_id)
				self.item[i].bg:setTexture(GetBackgroundForGoods(goodsData))
			else
				self.item[i].bg:setTexture(GetColorIconByQuality(info.quality))
			end
			
			self.item[i].icon:setTexture(info.path)
	
			if item.number > 1 then
				self.item[i].number:setVisible(true)
				self.item[i].number:setText("X" .. item.number)
			else
				self.item[i].number:setVisible(false)
			end


			if item.type == EnumDropType.GOODS then
				local rewardItem = {itemid = item.itemid}

				local itemData   = ItemData:objectByID(item.itemid)

				if itemData.type == EnumGameItemType.Piece or itemData.type == EnumGameItemType.Soul then
					Public:addPieceImg(self.item[i].icon,rewardItem,true)
				else
					Public:addPieceImg(self.item[i].icon,rewardItem,false)
				end
				-- adad  = dadaadad + 1
			end
		else
			self.item[i].bg:setVisible(false)
		end
	end

	local num = tonumber(self.title)
	local desc = self.title or ''
	if num >= 10000 then
		desc = math.floor(num/10000) .. "万"
	end

	self.txt_title:setText(desc)
	self:refreshButtonState()

	if self.panel_rewardnum then
	    self.panel_rewardnum:setVisible(false)
	    if self.activityType == EnumActivitiesType.DANBICHONGZHI then
			-- 显示累计奖励
			local reward = OperationActivitiesManager:getActivityRewardData(self.activityType, self.rewardId)
			if reward then
				if reward.status > 0 and reward.gottime < reward.maxtime then
					self.panel_rewardnum:setVisible(true)
					self.txt_rewardnum:setText(reward.status)
				end
			end
		end
	end

	self.txt_maxwarning:setVisible(false)
    if self.activityType == EnumActivitiesType.DANBICHONGZHI then
    	self.txt_maxwarning:setVisible(true)
    	local reward = OperationActivitiesManager:getActivityRewardData(self.activityType, self.rewardId)
		if reward then
			print("reward.gottime = ", reward.gottime)
			if reward.gottime >= reward.maxtime then
				self.txt_maxwarning:setText("已达最大"..reward.maxtime.."次")
				
			else
				self.txt_maxwarning:setText("最多累计"..reward.maxtime.."次")
			end
		end
    end
end

--[[
刷新按钮状态
]]
function RewardItem:refreshButtonState()
	local status = OperationActivitiesManager:getActivityRewardStatus(self.activityType, self.rewardId)
	

	if status == 0 then
		self.btn_get:setTouchEnabled(true)
		self.btn_get:setGrayEnabled(false)
	else
		self.btn_get:setTouchEnabled(false)
		self.btn_get:setGrayEnabled(true)
	end

	if status == 5 or status == 4 then
		self.img_ylq:setVisible(true)
		self.btn_get:setVisible(false)
	else
		self.img_ylq:setVisible(false)
		self.btn_get:setVisible(true)
	end
end

--[[
加载奖励信息t_s_reward_configure以及当前奖励的配置信息
（t_s_open_service_ol、t_s_open_service_sign、t_s_open_service_team_lv_up）表格数据
]]
function RewardItem:loadRewardConfigure()
	-- if self.type == EnumActivitiesType.LOGON_REWARD then
	-- 	self.rewardInfo = LogonReward:objectByID(self.rewardId)
	-- elseif self.type == EnumActivitiesType.ONLINE_REWARD then
	-- 	self.rewardInfo = OnlineReward:objectByID(self.rewardId)
	-- elseif self.type == EnumActivitiesType.TEAM_LEVEL_UP_REWARD then
	-- 	self.rewardInfo = TeamLevelUpReward:objectByID(self.rewardId)
	-- end
	self.rewardData = OperationActivitiesManager:getActivityRewardData(self.activityType, self.rewardId)

	self.rewardItems = self.rewardData.reward
	self.title       = self.rewardData.id

	if self.rewardItems then
		-- self.rewardConfigure = RewardConfigureData:objectByID(self.rewardInfo.reward_id)
		--self.rewardConfigure:getReward()
	else
		print("RewardItem:loadRewardConfigure()  not found reward info : ",self.type,self.rewardId,self.rewardInfo)
	end
end

function RewardItem:setLogic(logic)
    self.logic = logic
end


function RewardItem.onClick(sender)
    local index = sender.index
    local self  = sender.logic

    local rewardItems = self.rewardItems

	local item = rewardItems:objectAt(index)
	Public:ShowItemTipLayer(item.itemid, item.type);
     
end

function RewardItem:registerEvents()
    self.super.registerEvents(self)
    function getButtonClickHandle(widget)
    	local self = widget.logic
    	-- OperationActivitiesManager:getReward(self.type,self.rewardId,function() self:refreshUI() end)
    	if self.activityType == EnumActivitiesType.DANBICHONGZHI then
			-- 显示累计奖励
			local reward = OperationActivitiesManager:getActivityRewardData(self.activityType, self.rewardId)
			if reward then
				print("------reward.maxtime = ", reward.maxtime)
				print("------reward.gottime = ", reward.gottime)
				if reward.gottime >= reward.maxtime then
					 toastMessage("该单笔充值最多累计"..reward.maxtime.."次")
					return
				end
			end
		end
    	OperationActivitiesManager:sendMsgToGetActivityReward(self.type, self.index)
    end
    self.btn_get:addMEListener(TFWIDGET_CLICK, audioClickfun(getButtonClickHandle),1)


 	for i=1,3 do
    	self.item[i].bg.logic = self
    	self.item[i].bg.index = i
    	self.item[i].bg:addMEListener(TFWIDGET_CLICK, audioClickfun(self.onClick));
    end
   
end

function RewardItem:removeEvents()
    self.super.removeEvents(self)
end

return RewardItem