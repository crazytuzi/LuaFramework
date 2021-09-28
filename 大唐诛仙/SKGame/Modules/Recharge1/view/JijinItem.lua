JijinItem = BaseClass(LuaUI)
function JijinItem:__init( ... )
	self.URL = "ui://wvu017cpts5tr";
	self:__property(...)
	self:Config()
end
-- Set self property
function JijinItem:SetProperty( ... )
end
-- start
function JijinItem:Config()
	self.model = RechargeModel:GetInstance()

	self.id = 0
	self.itemGrow = {}

end
-- wrap UI to lua
function JijinItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Recharge","JijinItem");

	self.txtLQ = self.ui:GetChild("txtLQ")
	self.rewardGezi = self.ui:GetChild("rewardGezi")
	self.btnLQ = self.ui:GetChild("btnLQ")
	self.txtIsBuy = self.ui:GetChild("txtIsBuy")
	self.alreadyLQ = self.ui:GetChild("alreadyLQ")
end

function JijinItem:Updata(vo, isbuyGrowthFund)
	if vo then
		if vo[1] == 1 then
			self.txtLQ.text = "立即领取"
			self.txtIsBuy.text = StringFormat("购买后立即\n可领取[color=#c04d07]{0}[/color]元宝", vo[2][1][3])
		else
			self.txtLQ.text = vo[1].."级领取"
			if isbuyGrowthFund == 0 then
				self.txtIsBuy.text = StringFormat("购买后达到{0}级\n可领取[color=#c04d07]{1}[/color]元宝", vo[1], vo[2][1][3])
			else
				self.txtIsBuy.text = StringFormat("达到{0}级\n可领取[color=#c04d07]{1}[/color]元宝", vo[1], vo[2][1][3])
			end
		end
	end
	for i,v in ipairs(vo[2]) do
		local icon = PkgCell.New(self.rewardGezi)
		table.insert(self.itemGrow,icon)
		local w, h =89,89
		icon:SetSize(w, h)
		icon:SetXY(0,0)    --**设置位置**
		icon:OpenTips(true,true)
		icon:SetDataByCfg(v[1],v[2],v[3],v[4])
	end
	self.btnLQ.visible = false
	self.alreadyLQ.visible = false
end

function JijinItem:Refresh(isbuyGrowthFund, lv)
	local growRewardState = self.model.growRewardState
	local condition = GetCfgData("reward"):Get(self.id).condition
	if isbuyGrowthFund == 0 then
		self.btnLQ.visible = false
		self.txtIsBuy.visible = true
		self.alreadyLQ.visible = false
	else
		if lv >= condition then 
			if #growRewardState <= 0 then
				self.btnLQ.visible = true
				self.txtIsBuy.visible = false
				self.alreadyLQ.visible = false
				self.btnLQ.onClick:Add(function ()
					RechargeController:GetInstance():C_GetGrowthFund(self.id)
				end)
			else
				self.btnLQ.visible = true
				self.txtIsBuy.visible = false
				self.alreadyLQ.visible = false
				self.btnLQ.onClick:Add(function ()
					RechargeController:GetInstance():C_GetGrowthFund(self.id)
				end)
				for i,v in ipairs(growRewardState) do
					if v == self.id then
						self.btnLQ.visible = false
						self.txtIsBuy.visible = false
						self.alreadyLQ.visible = true
						break
					end
				end
			end
		else
			self.btnLQ.visible = false
			self.txtIsBuy.visible = true
			self.alreadyLQ.visible = false
		end
	end
end

function JijinItem:RefreshBtn()
	local growRewardState = self.model.growRewardState
	if growRewardState then 
		for i,v in ipairs(growRewardState) do
			if v == self.id then
				self.alreadyLQ.visible = true
				self.btnLQ.visible = false
			end
		end
	end
end

-- Combining existing UI generates a class
function JijinItem.Create( ui, ...)
	return JijinItem.New(ui, "#", {...})
end
function JijinItem:__delete()
	if self.itemGrow then
		for i,v in ipairs(self.itemGrow) do
			v:Destroy()
		end
		self.itemGrow = nil
	end

end