---
--- Created by  Administrator
--- DateTime: 2019/8/1 17:01
---
PeakArenaItem = PeakArenaItem or class("PeakArenaItem", BaseCloneItem)
local this = PeakArenaItem

function PeakArenaItem:ctor(obj, parent_node, parent_panel)
    PeakArenaItem.super.Load(self)
    self.events = {}
	self.itemicon = {}
	self.model = PeakArenaModel:GetInstance()
end

function PeakArenaItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
	self:ClearEff()
	for i, v in pairs(self.itemicon) do
		v:destroy()
	end
	self.itemicon = {}
	
	
	if self.red1 then
		self.red1:destroy()
		self.red1 = nil
	end
end

function PeakArenaItem:LoadCallBack()
    self.nodes = {
		"num","box","showPanel","showPanel/mask","showPanel/iconParent",
		"showPanel/title"
    }
    self:GetChildren(self.nodes)
	self.num = GetText(self.num)
	self.boxImg = GetImage(self.box)
	self.title = GetText(self.title)
    self:InitUI()
    self:AddEvent()
	self.red1 = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
	self.red1:SetPosition(21, 17)
end

function PeakArenaItem:InitUI()

end

function PeakArenaItem:AddEvent()
	local function callBack() --领奖
		if self.isReward == 0 then
			--Notify.ShowText("场次还未达到！")
			--SetVisible(self.showPanel,true)
			self.model:Brocast(PeakArenaEvent.PeakArenaItemClick,self.data)
			
			return 
		end
		if self.isReward == true then
			Notify.ShowText("Rewards have been claimed")
			return 
		end
		
		PeakArenaController:GetInstance():RequestWinReward(self.data.num)
	end
	AddButtonEvent(self.box.gameObject,callBack)
	
	local function callBack()
		SetVisible(self.showPanel,false)
	end	
	AddClickEvent(self.mask.gameObject,callBack)
end

function PeakArenaItem:SetData(data)
	self.data = data
	--0  486
	self.num.text = self.data.num .. "X games"
	self:CreatIcons()
	self:SetPos()
	self:SetState()
	self.title.text = string.format("[%s-game chest rewards]",self.data.num)
end

function PeakArenaItem:SetPos()
	local max = self.model:GetMaxWin()
	local curNum = self.data.num
	--SetLocalPositionX(self.transform,486 * curNum/max)
	SetAnchoredPosition(self.transform,486 * curNum/max,0)
end


function PeakArenaItem:SetState()
	self.isReward = self.model:IsWinReward(self.data.num)
	if self.isReward == 0 then  --未达到
		self:ClearEff()
		self.red1:SetRedDotParam(false)
		ShaderManager.GetInstance():SetImageNormal(self.boxImg)
	elseif self.isReward == false  then --可领取 （特效）
		if not self.eff  then
			self.red1:SetRedDotParam(true)
			self.eff = UIEffect(self.transform, 30011)
		end
		ShaderManager.GetInstance():SetImageNormal(self.boxImg)
	elseif self.isReward == true then  --已领取  (灰)
		self:ClearEff()
		self.red1:SetRedDotParam(false)
		ShaderManager.GetInstance():SetImageGray(self.boxImg)
	end
end
function PeakArenaItem:ClearEff()
	if self.eff then
		self.eff:destroy()
	end
end

function PeakArenaItem:CreatIcons()
	for i, v in pairs(self.itemicon) do
		v:destroy()
	end
	self.itemicon = {}
	local rewardTab = String2Table(self.data.reward)
	for i = 1, #rewardTab do
		--self:CreateIcon(rewardTab[i][1],rewardTab[i][2])
		if self.itemicon[i] == nil then
			self.itemicon[i] = GoodsIconSettorTwo(self.iconParent)
		end
		local param = {}
		param["model"] = BagModel
		param["item_id"] = rewardTab[i][1]
		param["num"] = rewardTab[i][2]
		--param["bind"] = rewardTab[i][3]
		param["can_click"] = true
		--param["size"] = {x = 78,y = 78}
		self.itemicon[i]:SetIcon(param)
	end
end

function PeakArenaItem:isShowPanel(isShow)
	SetVisible(self.showPanel,isShow)
end