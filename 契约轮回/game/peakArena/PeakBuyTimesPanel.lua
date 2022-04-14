PeakBuyTimesPanel = PeakBuyTimesPanel or class("PeakBuyTimesPanel", WindowPanel)
local this = PeakBuyTimesPanel

function PeakBuyTimesPanel:ctor(parent_node, parent_panel)
	
	self.abName = "peakArena"
	self.assetName = "PeakBuyTimesPanel"
	self.image_ab = "peakArena_image";
	self.layer = "UI"
	self.events = {}
	self.panel_type = 4
	self.model = PeakArenaModel:GetInstance()

end

function PeakBuyTimesPanel:Open()
	WindowPanel.Open(self)
end

function PeakBuyTimesPanel:dctor()
	self.model:RemoveTabListener(self.events)
	-- GlobalEvent:RemoveTabListener(self.events)
	if self.currentView then
		self.currentView:destroy();
	end
end

function PeakBuyTimesPanel:LoadCallBack()
	--self:SetTileTextImage("peakArena_image", "PArena_title_text1");
	self.nodes = {
		"sliderObj/slider","sliderObj/sliderNum","sliderObj/jianBtn","price","sliderObj/jiaBtn","qxBtn","okBtn",
		"title",
	}
	self:GetChildren(self.nodes)
	self.title = GetText(self.title)
	self.slider = GetImage(self.slider)
	self.sliderNum = GetText(self.sliderNum)
	self.price = GetText(self.price)
	self:InitUI()
	self:AddEvent()
	self:SetTileTextImage("peakArena_image", "PArena_title_text3")
end

function PeakBuyTimesPanel:InitUI()
	local buyTimes = self.model.remain_buy
	self.cfg = self.model:GetLimitCfg()
	local joinTimes = self.model.today_join + self.model.remain_join --今日参与次数
	for i = 1, #self.cfg do
		if joinTimes + 1 >= self.cfg[i].min and joinTimes + 1 <= self.cfg[i].max then
			local tab = String2Table(self.cfg[i].buy) 
			self.picId = tab[1][1] -- id
			self.picNum = tab[1][2] --价格
		end
	end
	self.curBuyTimes = 1
	self.title.text = string.format("<color=#DF5626>Ultimate 1V1</color>（Can buy <color=#DF5626>%s</color> times）",self.model.remain_buy)
	self:SetSlider(self.curBuyTimes,buyTimes)
end

function PeakBuyTimesPanel:AddEvent()
	
	local function callBack()
		self.curBuyTimes = self.curBuyTimes + 1
		if self.curBuyTimes > self.model.remain_buy then
			self.curBuyTimes = self.model.remain_buy
		end
		self:SetSlider(self.curBuyTimes,self.model.remain_buy)
	end
	AddClickEvent(self.jiaBtn.gameObject,callBack)
	
	local function callBack()
		self.curBuyTimes = self.curBuyTimes - 1
		if self.curBuyTimes < 1 then
			self.curBuyTimes = 1
		end
		self:SetSlider(self.curBuyTimes,self.model.remain_buy)
	end
	
	AddClickEvent(self.jianBtn.gameObject,callBack)
	
	local function callBack()
		self:Close()
	end
	
	AddClickEvent(self.qxBtn.gameObject,callBack)
	
	local function callBack()
		--self:Close()
		if ActivityModel:GetInstance():GetActivity(10125) or ActivityModel:GetInstance():GetActivity(10126)  then
			--self.startBtnText.text = "开始匹配"
			if RoleInfoModel:GetInstance():CheckGold(self.curBuyTimes * self.picNum,Constant.GoldType.BGold ) then
				PeakArenaController:GetInstance():RequestBuyTimes(self.curBuyTimes)
			end
		
		else
			--self.startBtnText.text = "21:00开启"
			Notify.ShowText("The event is not opened")
		end
	end
	
	AddClickEvent(self.okBtn.gameObject,callBack)
	
	self.events[#self.events +  1] = self.model:AddListener(PeakArenaEvent.BuyTimes,handler(self,self.BuyTimes))
	
end

function PeakBuyTimesPanel:SetSlider(cur,max)
	--0  280
	SetLocalPositionX(self.sliderNum.transform,280*(cur/max))
	self.sliderNum.text = cur
	self.slider.fillAmount = cur/max
	self.price.text = string.format("Total Price: %s%s (Unit Price: %s%s)",cur * self.picNum,enumName.ITEM[self.picId],self.picNum,enumName.ITEM[self.picId])
end

function PeakBuyTimesPanel:BuyTimes(data)
	Notify.ShowText("Purchased")
	self:Close()
end