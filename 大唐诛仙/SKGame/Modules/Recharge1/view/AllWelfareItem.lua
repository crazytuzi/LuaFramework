AllWelfareItem = BaseClass(LuaUI)
function AllWelfareItem:__init( ... )
	self.URL = "ui://wvu017cpoyvms";
	self:__property(...)
	self:Config()
end
-- Set self property
function AllWelfareItem:SetProperty( ... )
end
-- start
function AllWelfareItem:Config()
	self.model = RechargeModel:GetInstance()

	self.id = 0
	self.itemAll = {}
end
-- wrap UI to lua
function AllWelfareItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Recharge","AllWelfareItem");

	self.txtBuyPeopleNum = self.ui:GetChild("txtBuyPeopleNum")
	self.rewardCont = self.ui:GetChild("rewardCont")
	self.btnIsLQ = self.ui:GetChild("btnIsLQ")
	self.alreadyLQ = self.ui:GetChild("alreadyLQ")
end

function AllWelfareItem:AddEvent()
	-- body
end
	

function AllWelfareItem:Updata(vo)
	self.txtBuyPeopleNum.text = StringFormat("购买人数：{0}人", vo[1])
	for i,v in ipairs(vo[2]) do
		local icon = PkgCell.New(self.rewardCont)
		table.insert(self.itemAll,icon)
		local w, h =89,89
		icon:SetSize(w, h)
		icon:SetXY(w*((i-1)%2),math.floor((i-1)/2)*h)    --**设置位置**
		icon:OpenTips(true,true)
		icon:SetDataByCfg(v[1],v[2],v[3],v[4])
	end
end

function AllWelfareItem:Refresh(buyGrowthFundNum)
	local condition = GetCfgData("reward"):Get(self.id).condition
	local allRewardState = self.model.allRewardState
	if buyGrowthFundNum >= condition then
		if #allRewardState <= 0 then
			self.alreadyLQ.visible = false
			self.btnIsLQ.visible = true
			self.btnIsLQ.touchable = true
			self.btnIsLQ.title = "领取"
			self.btnIsLQ.icon = UIPackage.GetItemURL("Common","btn_erji2")
			self.btnIsLQ.onClick:Add(function ()
				RechargeController:GetInstance():C_GetNationalWelfare(self.id)
			end)
		else
			self.alreadyLQ.visible = false
			self.btnIsLQ.visible = true
			self.btnIsLQ.title = "领取"
			self.btnIsLQ.touchable = true
			self.btnIsLQ.icon = UIPackage.GetItemURL("Common","btn_erji2")
			self.btnIsLQ.onClick:Add(function ()
				RechargeController:GetInstance():C_GetNationalWelfare(self.id)
			end)
			for i,v in ipairs(allRewardState) do
				if v == self.id then
					self.alreadyLQ.visible = true
					self.btnIsLQ.visible = false
					break
				end
			end
		end
	else
		local num = condition - buyGrowthFundNum
		self.alreadyLQ.visible = false
		self.btnIsLQ.visible = true
		self.btnIsLQ.touchable = false
		self.btnIsLQ.title = StringFormat("还差{0}人", num)
		self.btnIsLQ.icon = UIPackage.GetItemURL("Common","btn_erji1")
	end
end

function AllWelfareItem:RefreshBtn()
	local allRewardState = self.model.allRewardState
	if allRewardState then 
		for i,v in ipairs(allRewardState) do
			if v == self.id then
				self.alreadyLQ.visible = true
				self.btnIsLQ.visible = false
			end
		end
	end
end

-- Combining existing UI generates a class
function AllWelfareItem.Create( ui, ...)
	return AllWelfareItem.New(ui, "#", {...})
end
function AllWelfareItem:__delete()
	if self.itemAll then
		for i,v in ipairs(self.itemAll) do
			v:Destroy()
		end
		self.itemAll = nil
	end
	--self.btnIsLQ.onClick:Remove(function () RechargeController:GetInstance():C_GetNationalWelfare(self.id) end, self)
end