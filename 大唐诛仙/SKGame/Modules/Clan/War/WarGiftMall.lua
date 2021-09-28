WarGiftMall = BaseClass(LuaUI)
function WarGiftMall:__init()
	self.model = ClanModel:GetInstance()
	local ui = UIPackage.CreateObject("Duhufu","WarGiftMall")
	self.ui = ui
	self.listConn = ui:GetChild("listConn")
	self.btnClose = ui:GetChild("btnClose")
	self.btnClose.onClick:Add(function ()
		UIMgr.HidePopup(ui)
	end)
	self.items = {}
	self:Layout()
end
local _func = "function"
function WarGiftMall:Layout()
	local listing = GetCfgData("guildbuy")
	local i = 1
	local c,r = 0, 0
	for k,v in pairs(listing) do
		if type(v) ~= _func then
			local item = self.items[i]
			item = WarGiftItem.New(v)
			item:SetClickCallback(function (target, data)
				local buyList = self.model.buyList --列表
				if self.model.warHoster ~= self.model.clanId then
					UIMgr.Win_FloatTip("您所在都护府不是城占都护府，不可以购买此商品")
					return
				end
				if self.selected then self.selected.selected=false end
				target.selected=true
				self.selected = target
				-- data -- itemId,limitNum,curPrice
				local buy = nil
				for i=1,#buyList do
					if buyList[i].itemId == data.itemId then
						buy = buyList[i]
						break
					end
				end

				if buy == nil then
					buy = {}
					buy.itemId = data.itemId
					buy.buyNum = 0
				end
				UIMgr.ShowCenterPopup(WarGiftAlert.New(data, buy), nil, true)
			end)
			item:AddTo(self.listConn)
			r = math.floor((i-1)/2)
			c = math.floor((i-1)%2)
			item:SetXY(c*364, r*120)
			self.items[i] = item
			i=i+1
		end
	end
end

function WarGiftMall:__delete()
	for i=1,#self.items do
		local item = self.items[i]
		item:Destroy()
		item = nil
		self.items[i]=nil
	end
end