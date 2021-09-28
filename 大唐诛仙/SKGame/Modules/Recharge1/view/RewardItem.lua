RewardItem = BaseClass(LuaUI)
function RewardItem:__init( ... )
	self.URL = "ui://wvu017cpts5t8";
	self:__property(...)
	self:Config()
end
-- Set self property
function RewardItem:SetProperty( ... )
end
-- start
function RewardItem:Config()
	self.model = RechargeModel:GetInstance()

	self.id = 0
	self.items = {}
end
-- wrap UI to lua
function RewardItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Recharge","RewardItem");

	self.txtNumMoney = self.ui:GetChild("txtNumMoney")
	self.reardCont = self.ui:GetChild("reardCont")
	self.btnIsLingqu = self.ui:GetChild("btnIsLingqu")
	self.yiLQicon = self.ui:GetChild("yiLQicon")
end

-- Combining existing UI generates a class
function RewardItem.Create( ui, ...)
	return RewardItem.New(ui, "#", {...})
end

function RewardItem:Updata(vo)
	self.txtNumMoney.text = vo[1]
	for i,v in ipairs(vo[2]) do
		local icon = PkgCell.New(self.reardCont)
		table.insert(self.items,icon)
		local w, h =89,89
		icon:SetSize(w, h)
		icon:SetXY(0,(i-1)*h)    --**设置位置**
		icon:OpenTips(true,true)
		icon:SetDataByCfg(v[1],v[2],v[3],v[4])
	end
end

function RewardItem:Refresh(rechargeNum)
	local dailyRewardState = self.model.dailyRewardState
	if rechargeNum >= tonumber(self.txtNumMoney.text)  then
		if #dailyRewardState <= 0 then
			self.yiLQicon.visible = false
			self.btnIsLingqu.visible = true
			self.btnIsLingqu.title = "领取"
			self.btnIsLingqu.icon = UIPackage.GetItemURL("Common","btn_erji2")
			self.btnIsLingqu.onClick:Add(function ()
				RechargeController:GetInstance():C_GetDailyRrechargeReward(self.id)
			end)
		else
			self.yiLQicon.visible = false
			self.btnIsLingqu.visible = true
			self.btnIsLingqu.title = "领取"
			self.btnIsLingqu.icon = UIPackage.GetItemURL("Common","btn_erji2")
			self.btnIsLingqu.onClick:Add(function ()
				RechargeController:GetInstance():C_GetDailyRrechargeReward(self.id)
			end)
			for i,v in ipairs(dailyRewardState) do
				if v == self.id then
					self.yiLQicon.visible = true
					self.btnIsLingqu.visible = false
					break
				end
			end
		end
	else
		self.yiLQicon.visible = false
		self.btnIsLingqu.visible = true
		self.btnIsLingqu.title = "充值"
		self.btnIsLingqu.icon = UIPackage.GetItemURL("Common","btn_erji1")
		self.btnIsLingqu.onClick:Add(function ()
			MallController:GetInstance():OpenMallPanel(0, 2)
		end)
	end
end

function RewardItem:RefreshBtn()
	local dailyRewardState = self.model.dailyRewardState
	if dailyRewardState then 
		for i,v in ipairs(dailyRewardState) do
			if v == self.id then
				self.yiLQicon.visible = true
				self.btnIsLingqu.visible = false
			end
		end
	end
end

function RewardItem:__delete()
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
		self.items = nil
	end
end