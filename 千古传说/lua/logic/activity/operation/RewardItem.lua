
local RewardItem = class("RewardItem", BaseLayer)

function RewardItem:ctor(type,rewardId,title,name)
    self.super.ctor(self)
    self.type = type
    self.rewardId = rewardId
    self.title = title
    self.name = name
    self:loadRewardConfigure()
    if type == EnumActivitiesType.LOGON_REWARD then
    	self:init("lua.uiconfig_mango_new.operatingactivities.RewardItem004")
    elseif type == EnumActivitiesType.ONLINE_REWARD then
    	self:init("lua.uiconfig_mango_new.operatingactivities.RewardItem005")
    elseif type == EnumActivitiesType.TEAM_LEVEL_UP_REWARD then
    	self:init("lua.uiconfig_mango_new.operatingactivities.RewardItem006")
    end
end

function RewardItem:initUI(ui)
    self.super.initUI(self,ui)
    self.txt_title 					= TFDirector:getChildByPath(ui, 'txt_title')
    self.txt_name 					= TFDirector:getChildByPath(ui, 'txt_name')
    self.img_ylq 					= TFDirector:getChildByPath(ui, 'img_ylq')

    self.item = {}
    for i=1,3 do
    	self.item[i] = {}
    	self.item[i].bg 			= TFDirector:getChildByPath(ui, 'img_bg_' .. i)
    	self.item[i].icon 			= TFDirector:getChildByPath(ui, 'img_icon_' .. i)
    	self.item[i].number 		= TFDirector:getChildByPath(ui, 'txt_number_' .. i)
    end

    self.btn_get 					= TFDirector:getChildByPath(ui, 'btn_get')
    self.btn_get.logic = self
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
	local rewardItems = self.rewardConfigure:getReward()
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

	self.txt_title:setText(self.title or '')
	self:refreshButtonState()
end

--[[
刷新按钮状态
]]
function RewardItem:refreshButtonState()
	local status = OperationActivitiesManager:calculateRewardState(self.type,self.rewardId)
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
	if self.type == EnumActivitiesType.LOGON_REWARD then
		self.rewardInfo = LogonReward:objectByID(self.rewardId)
	elseif self.type == EnumActivitiesType.ONLINE_REWARD then
		self.rewardInfo = OnlineReward:objectByID(self.rewardId)
	elseif self.type == EnumActivitiesType.TEAM_LEVEL_UP_REWARD then
		self.rewardInfo = TeamLevelUpReward:objectByID(self.rewardId)
	end

	if self.rewardInfo then
		self.rewardConfigure = RewardConfigureData:objectByID(self.rewardInfo.reward_id)
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

    local rewardItems = sender.logic.rewardConfigure:getReward()
	local item = rewardItems:objectAt(index)
	Public:ShowItemTipLayer(item.itemid, item.type);
     
end

function RewardItem:registerEvents()
    self.super.registerEvents(self)
    function getButtonClickHandle(widget)
    	local self = widget.logic
    	OperationActivitiesManager:getReward(self.type,self.rewardId,function() self:refreshUI() end)
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