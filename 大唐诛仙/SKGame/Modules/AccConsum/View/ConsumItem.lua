ConsumItem = BaseClass(LuaUI)

function ConsumItem:__init( root )
	self.URL = "ui://bveep9rgsjzg8";
	self:Layout(root)
	self:Config()
	self.isInited = true
end

-- start
function ConsumItem:Config()
	self.id = 0 -- item的id
	self.rewardList = {} -- 奖励列表
	self.canRecCharge = 0 -- 可领取额度
	self.model = ConsumModel:GetInstance()
	self:AddEvent()
	self:AddHandler()
end

function ConsumItem:InitData( data )
	if data then
		self.id = data.id
		self.canRecCharge = data.condition
		self.jine.text = StringFormat("达到{0}元宝", self.canRecCharge)
		self:ShowReward( data.reward )
	end
	self:SetRecCtrl()
end

function ConsumItem:AddEvent()
	self.noRec.data = 2001
	self:AddBtnClick()
end

function ConsumItem:AddHandler()
	self.recHandler = self.model:AddEventListener(ConsumConst.ChangeCtrl, function ( id )
		if id == self.id then
			self.getRec.selectedIndex = 2
			self.model.accVo[self.id].state = ConsumConst.RewardState.Received
		end
	end)

	self.handler0 = self.model:AddEventListener(ConsumConst.RefreshPanel, function ()
		if self.isInited then
			self:SetRecCtrl()
		end
	end)
end

function ConsumItem:RemoveHandler()
	self.model:RemoveEventListener(self.recHandler)
	self.model:RemoveEventListener(self.handler0)
end

function ConsumItem:AddBtnClick()
	self.noRec.onClick:Add(function ()
		MallController:GetInstance():OpenMallPanel(0, 0)
	end)

	self.canRec.onClick:Add(function ()
		ConsumController:GetInstance():C_GetTotalSpendReward( self.id )
		self.model:SetRewardState( self.id, ConsumConst.RewardState.Received )
	end)
end

function ConsumItem:SetRecCtrl()
	local totalRecharge = self.model:GetTotalRecharge()
	local receivedList = self.model:GetRewardIdList()
	local index = self.getRec.selectedIndex
	if self.canRecCharge <= totalRecharge and totalRecharge > 0 then
		if receivedList and #receivedList > 0 then
			for _, id in ipairs(receivedList) do
				if id == self.id then
					self.getRec.selectedIndex = 2
					return
				end
			end
		end
		self.getRec.selectedIndex = 1
		self.model:SetRewardState( self.id, ConsumConst.RewardState.CanGet )
	end
end

function ConsumItem:ShowReward( data )
	for i = 1, #data do
		local iconData = data[i]
		local icon = PkgCell.New(self.reward)
		icon:OpenTips(true)
		icon:SetDataByCfg(iconData[1], iconData[2], iconData[3], iconData[4])
		self.rewardList[i] = icon
	end
end

-- wrap UI to lua
function ConsumItem:Layout( root )
	self.ui = self.ui or UIPackage.CreateObject("AccConsum","ConsumItem");
	root:AddChild(self.ui)
	self.getRec = self.ui:GetController("getRec")
	self.jine = self.ui:GetChild("jine")
	self.reward = self.ui:GetChild("reward")
	self.noRec = self.ui:GetChild("noRec")
	self.canRec = self.ui:GetChild("canRec")
	self.received = self.ui:GetChild("received")
end

-- Combining existing UI generates a class
function ConsumItem.Create( ui, ...)
	return ConsumItem.New(ui, "#", {...})
end

function ConsumItem:__delete()
	self:RemoveHandler()
	self.model = nil
	for i,v in ipairs(self.rewardList) do
		v:Destroy()
	end
	self.isInited = false
end