
local RewardItem = class("RewardItem", BaseLayer)

function RewardItem:ctor(id, type, rewardId, desc1, desc2, index)
	-- 
    self.super.ctor(self)

    self.activityId 	= id
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

    if self.activityType == OperationActivitiesManager.Type_Continue_Recharge then
    	local desc1 = string.format(self.desc1, self.index)
    	self.txt_desc1:setText(desc1)

    	local posx1 = self.txt_title:getPositionX()
    	local posx2 = self.txt_desc2:getPositionX()
    	self.txt_title:setPositionX(posx1 + 5)
    	self.txt_desc2:setPositionX(posx1 + 40)
    end

    if self.txt_desc1 then
    	local pos = self.txt_desc1:getPosition()
    	self.txt_desc1:setPositionX(pos.x - 20)
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
		--desc = math.floor(num/10000) .. "万"
		desc = stringUtils.format(localizable.fun_wan_desc, math.floor(num/10000))
	end

	self.txt_title:setText(desc)
	self:refreshButtonState()


	self.txt_maxwarning:setVisible(false)


  	local condition 	= self.rewardData.condition

  	-- print("-------------condition1 = ", condition)
  	--local desc = {"普通", "高级", "十连抽"}
	local desc = localizable.activity_recruit_type2

  	local employCondition = ""
  	-- if condition then
  	-- 	for v in condition:iterator() do
  	-- 		employCondition = string.format("%s  %s_%d", employCondition, desc[v.employType], v.employNum)
  	-- 	end
  	-- end


  	local activity = OperationActivitiesManager:getActivityInfo(self.activityId)
  	if condition then
  		for v in condition:iterator() do
  			local employType = v.employType
  			local totalNum 	 = v.employNum
  			local curNum 	 = activity.employStatus[employType] or 0
  			--employCondition = string.format("%s %s%d次(%d/%d)", employCondition, desc[v.employType], totalNum, curNum, totalNum)
			employCondition = stringUtils.format(localizable.activity_employCondition, employCondition, desc[v.employType], totalNum, curNum, totalNum)
  		end
  	end

  	print("employCondition = ", employCondition)
  	self.txt_title:setText('')
    if self.txt_desc1 then
    	self.txt_desc1:setText(employCondition)
    end

    if self.txt_desc2 then
    	self.txt_desc2:setText("")
    end

end

--[[
刷新按钮状态
]]
function RewardItem:refreshButtonState()
	local status = OperationActivitiesManager:getActivityRewardStatus(self.activityId, self.rewardId)
	
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
	-- if self.activityId == EnumActivitiesType.LOGON_REWARD then
	-- 	self.rewardInfo = LogonReward:objectByID(self.rewardId)
	-- elseif self.activityId == EnumActivitiesType.ONLINE_REWARD then
	-- 	self.rewardInfo = OnlineReward:objectByID(self.rewardId)
	-- elseif self.activityId == EnumActivitiesType.TEAM_LEVEL_UP_REWARD then
	-- 	self.rewardInfo = TeamLevelUpReward:objectByID(self.rewardId)
	-- end
	self.rewardData = OperationActivitiesManager:getActivityRewardData(self.activityId, self.rewardId)

	self.rewardItems = self.rewardData.reward
	self.title       = self.rewardData.id

	if self.rewardItems then
		-- self.rewardConfigure = RewardConfigureData:objectByID(self.rewardInfo.reward_id)
		--self.rewardConfigure:getReward()
	else
		print("RewardItem:loadRewardConfigure()  not found reward info : ",self.activityId, self.rewardId,self.rewardInfo)
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
    	-- OperationActivitiesManager:getReward(self.activityId,self.rewardId,function() self:refreshUI() end)
    	-- if self.activityType == EnumActivitiesType.DANBICHONGZHI then
		if self.activityType == OperationActivitiesManager.Type_Single_Recharge then

			-- 显示累计奖励
			local reward = OperationActivitiesManager:getActivityRewardData(self.activityId, self.rewardId)
			if reward then
				print("------reward.maxtime = ", reward.maxtime)
				print("------reward.gottime = ", reward.gottime)
				if reward.gottime >= reward.maxtime then
					 --toastMessage("该单笔充值最多累计"..reward.maxtime.."次")
					 toastMessage(stringUtils.format(localizable.common_pay_times, reward.maxtime))
					return
				end
			end
		end
    	OperationActivitiesManager:sendMsgToGetActivityReward(self.activityId, self.index)
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