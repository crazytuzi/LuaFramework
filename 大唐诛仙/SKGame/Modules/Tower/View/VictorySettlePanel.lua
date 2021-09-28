VictorySettlePanel =BaseClass(BaseView)

-- (Constructor) use VictorySettlePanel.New(...)
function VictorySettlePanel:__init( ... )
	self.URL = "ui://jf5x839xgp6d3";

	self.ui = UIPackage.CreateObject("Tower","VictorySettlePanel")
	
	self.bg = self.ui:GetChild("bg")
	self.QuiteBtn = self.ui:GetChild("QuiteBtn")
	self.NextBtn = self.ui:GetChild("NextBtn")
	self.TurnComponent = self.ui:GetChild("TurnComponent")
	self.ShowLevel = self.ui:GetChild("ShowLevel")
	self.Vicon = self.ui:GetChild("Vicon")
	self.yun1 = self.ui:GetChild("yun1")
	self.yun2 = self.ui:GetChild("yun2")
	self.RewardShow = self.ui:GetChild("RewardShow")

	self.rewardItem = nil
	self.waitTime = 0 --等待两秒开始翻牌
	self.deltaTime = 0 --3秒翻完
	self.delta = 0
	self.deltaDu = 180
	self.cd = 5  --倒计时进入下一层5s
	self.deltaTime1 = 0
	self:Init()
	self:InitEvent()
end

function VictorySettlePanel:InitEvent()
	self.closeCallback = function () end
	self.openCallback  = function ()
		self:OnEnabel()
	end
	self.QuiteBtn.onClick:Add(self.OnClickQuiteBtn,self)
	self.NextBtn.onClick:Add(self.OnClickNextBtn,self)
end

function VictorySettlePanel:Init()
	self.turnGo = self.TurnComponent.displayObject.gameObject
	self.deltaDu = self.deltaDu/2
end

function VictorySettlePanel:Open()
	self.NextBtn.visible = false
	BaseView.Open(self)
end

function VictorySettlePanel:Refresh()
	
end

function VictorySettlePanel:OnEnabel()
	local curLevel = TowerModel:GetInstance().curLevel
	self.ShowLevel:GetChild("title").text = StringFormat("第{0}层",curLevel)
	self.RewardShow.visible = false
	RenderMgr.Add(function () self:PlayEffect() end, "TurnCutDown")
end

function VictorySettlePanel:OnDisable()
	
end

--退出大荒塔
function VictorySettlePanel:OnClickQuiteBtn()
	TowerController:GetInstance():RequireQuiteTower()
end

--进入下一层
function VictorySettlePanel:OnClickNextBtn()
	TowerController:GetInstance():RequireEnterTower()
end

function VictorySettlePanel:PlayEffect()
	self.waitTime = self.waitTime + Time.deltaTime
	if self.waitTime >=2 then 
		if self.turnGo then 
			RenderMgr.Add(function () self:VictoryUpdate() end, "VictorySettleCutDown")
		end
		self.Vicon.visible = false
		self.yun1.visible = false
		self.yun2.visible = false
		self.ShowLevel.visible = false
		RenderMgr.Realse("TurnCutDown")
	end
end

function VictorySettlePanel:VictoryUpdate()
	self.deltaTime = self.deltaTime + Time.deltaTime
	self.delta = self.deltaDu*self.deltaTime*5
	if self.delta <=180 then 
		if self.turnGo then 
			self.turnGo.transform.localRotation = Quaternion.Euler(0, self.delta, 0)
		end
	else
		RenderMgr.Realse("VictorySettleCutDown")
		self.turnGo.transform.localRotation = Quaternion.Euler(0, 180, 0)
		-- 显示奖励
		local rewardList = TowerModel:GetInstance():GetCurrentReward()
		if rewardList then 
			self.rewardItem = {}
			local osetX = 120
			local num = 0
			for _,rewardVo in pairs(rewardList) do
				local item = UIPackage.CreateObject("Tower" , "RewardItem")
				table.insert(self.rewardItem, item)
				self.RewardShow:AddChild(item)
				item:SetXY(osetX*num,0)
				item:GetChild("num").text =StringFormat("{0}",rewardVo.goodsNum or 0) 
				item:GetChild("icon").url = GoodsVo.GetIconUrl(rewardVo.goodsType, rewardVo.goodsId)

				num = num + 1
			end
			self.RewardShow.visible = true
		end
		self.NextBtn.visible = true
		--准备进入下一层的倒计时
		RenderMgr.Add(function () self:NextLevelCDUpdate() end, "NextLevelCDUpdate")
	end
end

--倒计时准备自动进入下一层
function VictorySettlePanel:NextLevelCDUpdate()
	self.deltaTime1 = self.deltaTime1 + Time.deltaTime
	if self.deltaTime1 >=1 then 
		self.deltaTime1 = 0
		self.cd = self.cd - 1
		self.NextBtn:GetChild("title").text = StringFormat("({0})进入下一层",math.abs(self.cd,0))
	end
	if self.cd <= 0 then 
		self.NextBtn:GetChild("title").text = StringFormat("({0})进入下一层",math.abs(self.cd,0))
		RenderMgr.Realse("NextLevelCDUpdate")
		TowerController:GetInstance():RequireEnterTower()
	end
end

-- Dispose use VictorySettlePanel obj:Destroy()
function VictorySettlePanel:__delete()
	RenderMgr.Realse("VictorySettleCutDown")
	RenderMgr.Realse("TurnCutDown")
	RenderMgr.Realse("NextLevelCDUpdate")

	if self.rewardItem then
		for i = 1, #self.rewardItem do
			self.rewardItem[i]:Destroy()
		end
		self.rewardItem = nil
	end

	self.bg = nil
	self.QuiteBtn = nil
	self.NextBtn = nil
	self.TurnComponent = nil
	self.ShowLevel = nil
	self.Vicon = nil
	self.yun1 = nil
	self.yun2 = nil
	self.RewardShow = nil
end