WarGiftAlert = BaseClass(LuaUI)
function WarGiftAlert:__init(data, buy)
	local ui = UIPackage.CreateObject("Duhufu","WarGiftAlert") -- MallBuyPanel
	self.ui = ui
	self.desc = ui:GetChild("desc")
	self.txtLimit = ui:GetChild("txtLimit")
	self.numBar = ui:GetChild("numBar")
	self.buyBtn = ui:GetChild("buyBtn")
	self.labelBar = ui:GetChild("labelBar")
	self.btnClose = ui:GetChild("btnClose")


	self.buyNum = 0
	self.numBar = NumberBar.Create(self.numBar)
	self.numBar:SetTypeCallback(function(data)
		self:UpdateCost(data)
	end)

	self.btnClose.onClick:Add(function ()
		UIMgr.HidePopup(ui)
	end)

	self.buyBtn.onClick:Add(function () --购买
		if self.buyNum == 0 then return end
		ClanCtrl:GetInstance():C_GuildBuy(data.itemId, self.buyNum)
		UIMgr.HidePopup(ui)
	end)
	
	self.price = data.curPrice
	local cfg = GoodsVo.GetItemCfg(data.itemId)
	self.icon = PkgCell.New(ui)
	self.icon:SetDataByCfg( GoodsVo.GoodType.item, data.itemId, 1, 0)
	self.icon:SetXY(233,70)

	ui.title = StringFormat("[color={0}]{1}[/color]",GoodsVo.RareColor[cfg.rare], cfg.name)
	self.desc.text = self:CreateDesc(cfg.des, cfg.tinyType, cfg.effectValue)

	self.labelBar:GetChild("title").text = "总价:"
	self.costIcon = self.labelBar:GetChild("icon")
	self.costInfo = self.labelBar:GetChild("txt")

	self.costIcon.url = GoodsVo.GetIconUrl(GoodsVo.GoodType.gold)

	local max = data.limitNum - buy.buyNum
	self.numBar:SetMax(max)
	self.numBar:SetValue(math.min(1, max))
	self:UpdateCost(math.min(1, max))
	self.txtLimit.text = StringFormat("[color=#43596b]每日限购:[color=#3370b7]{0}[/color]/{1}[/color]", max, data.limitNum)
end

function WarGiftAlert:UpdateCost(num)
	self.buyNum = num
	self.costInfo.text = self.price*tonumber(num)
	if tonumber(num) <= 0 then
		self.buyBtn.grayed = true
		self.buyBtn.touchable = false
	else
		self.buyBtn.grayed = false
		self.buyBtn.touchable = true
	end
end

-- 增加描述
function WarGiftAlert:CreateDesc(content, tinyType, effectValue)
	if tinyType == GoodsVo.TinyType.gift and effectValue then -- 礼包处理
		local giftCfg = GetCfgData("gift"):Get(effectValue)
		local career = LoginModel:GetInstance():GetLoginRole().career
		if giftCfg and giftCfg.reward then
			local s = ""
			local rewardList = {}
			for i,v in ipairs(giftCfg.reward) do
				if v[1]==0 or v[1]==career then
					table.insert(rewardList, v)
				end
			end
			local list = {}
			for i,v in ipairs(rewardList) do
				local num = v[5]
				local cfg = GoodsVo.GetCfg(v[3], v[4])
				if cfg then
					local c = StringFormat("[color={0}]{1}[/color]x{2}", GoodsVo.RareColor[cfg.rare], cfg.name, num)
					table.insert(list, c)
				end
			end
			content = StringFormatII(content, list)
		end
	end
	return content
end

function WarGiftAlert:__delete()
	self.icon:Destroy()
	self.icon=nil
	self.numBar:Destroy()
	self.numBar=nil
end