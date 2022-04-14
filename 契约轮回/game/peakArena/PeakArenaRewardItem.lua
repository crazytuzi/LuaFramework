---
--- Created by  Administrator
--- DateTime: 2019/8/5 11:28
---
PeakArenaRewardItem = PeakArenaRewardItem or class("PeakArenaRewardItem", BaseCloneItem)
local this = PeakArenaRewardItem

function PeakArenaRewardItem:ctor(obj, parent_node, parent_panel)
    PeakArenaRewardItem.super.Load(self)
    self.events = {}
	self.itemicon = {} 
	self.model = PeakArenaModel:GetInstance()
end

function PeakArenaRewardItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
	for i, v in pairs(self.itemicon) do
		v:destroy()
	end
	self.itemicon = {}
	if self.red1 then
		self.red1:destroy()
		self.red1 = nil
	end
end

function PeakArenaRewardItem:LoadCallBack()
    self.nodes = {
		"name","iconparent","lqBtn","stateImg"
    }
    self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.stateImg = GetImage(self.stateImg)
    self:InitUI()
    self:AddEvent()
	self.red1 = RedDot(self.lqBtn, nil, RedDot.RedDotType.Nor)
	self.red1:SetPosition(45, 13)
	
end

function PeakArenaRewardItem:InitUI()

end

function PeakArenaRewardItem:AddEvent()
	local function callBack()
		PeakArenaController:GetInstance():RequestMeritReward(self.data.merit)
	end
	AddClickEvent(self.lqBtn.gameObject,callBack)
end

function PeakArenaRewardItem:SetData(data)
	self.data = data
	local merit = self.data.merit
	self.name.text = string.format("Merit reaches <color=#1D8C0E>%s</color>",merit)
	self:CreatIcons()
	self:SetState()
end

function PeakArenaRewardItem:CreatIcons()
	for i, v in pairs(self.itemicon) do
		v:destroy()
	end
	self.itemicon = {}
	local rewardTab = String2Table(self.data.reward)
	for i = 1, #rewardTab do
		--self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
		if self.itemicon[i] == nil then
			self.itemicon[i] = GoodsIconSettorTwo(self.iconparent)
		end
		local param = {}
		param["model"] = BagModel
		param["item_id"] = rewardTab[i][1]
		param["num"] = rewardTab[i][2]
		--param["bind"] = rewardTab[i][3]
		param["can_click"] = true
		param["size"] = {x = 78,y = 78}
		self.itemicon[i]:SetIcon(param)
	end
end

function PeakArenaRewardItem:SetState()
	--local curMerit = self.model.merit
	
	--if curMerit >= self.data.merit then --可以领取
		--SetVisible(self.stateImg,false)
	--end
	self.isReward = self.model:IsMeritReward(self.data.merit)
	if self.isReward == 1 then --未达到
		SetVisible(self.lqBtn,false)
		SetVisible(self.stateImg,true)
		
		self.red1:SetRedDotParam(false)
		lua_resMgr:SetImageTexture(self, self.stateImg, "common_image", "ing_have_notReached", true, nil, false)
	elseif self.isReward == 0 then  --可领取
		SetVisible(self.lqBtn,true)
		SetVisible(self.stateImg,false)
		self.red1:SetRedDotParam(true)
	else --已领取
		SetVisible(self.lqBtn,false)
		SetVisible(self.stateImg,true)
		self.red1:SetRedDotParam(false)
		lua_resMgr:SetImageTexture(self, self.stateImg, "common_image", "img_have_received_1", true, nil, false)
	end
	
	
end