DayItem = BaseClass(LuaUI)
function DayItem:__init( ... )
	self.URL = "ui://gyl54s25f3gzf";
	self:__property(...)
	self:Config()
end
-- Set self property
function DayItem:SetProperty( ... )
end
-- start
function DayItem:Config()
	self.model = SevenLoginModel:GetInstance()
	self.id = 0

	self.items = {}
end
-- wrap UI to lua
function DayItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("SevenLogining","DayItem");

	self.dayIcon = self.ui:GetChild("dayIcon")
	self.btnLQ = self.ui:GetChild("btnLQ")
	self.yiLqImg = self.ui:GetChild("yiLqImg")
	self.rewardCon = self.ui:GetChild("rewardCon")
end
-- Combining existing UI generates a class
function DayItem.Create( ui, ...)
	return DayItem.New(ui, "#", {...})
end

function DayItem:Updata(vo)
	self.id = vo[1]
	self.dayIcon.url = "Icon/SevenLogin/day"..vo[3]
	if vo[2] then
		for i,v in ipairs(vo[2]) do
			local icon = PkgCell.New(self.rewardCon)
			table.insert(self.items,icon)
			local w, h =89,89
			icon:SetSize(w, h)
			icon:SetXY((i-1)*w, 0)    --**设置位置**
			icon:OpenTips(true,true)
			icon:SetDataByCfg(v[1],v[2],v[3],v[4])
		end
	end
	self.yiLqImg.visible = false
	self.btnLQ.visible = true
	self.btnLQ.touchable = true
	self.btnLQ.title = "领取"
	self.btnLQ.icon = UIPackage.GetItemURL("Common","btn_erji2")
	self.btnLQ.onClick:Add(function ()
		SevenLoginController:GetInstance():C_GetOpenServerReward(self.id)
	end)
end

function DayItem:Refresh(loginDay)
	local condition = GetCfgData("reward"):Get(self.id).condition
	local rewardGetState = self.model.rewardGetState
	if loginDay >= condition then
		local isLq = false
		for i,v in ipairs(rewardGetState) do
			if self.id == v then
				isLq = true
				break
			end
		end
		if isLq then
			self.yiLqImg.visible = true
			self.btnLQ.visible = false
		else
			self.yiLqImg.visible = false
			self.btnLQ.visible = true
			self.btnLQ.touchable = true
			self.btnLQ.icon = UIPackage.GetItemURL("Common","btn_erji2")
			self.btnLQ.title = "领取"
		end
	else
		self.yiLqImg.visible = false
		self.btnLQ.visible = true
		self.btnLQ.touchable = false
		self.btnLQ.title = "未达成"
		self.btnLQ.icon = UIPackage.GetItemURL("Common","btn_erji1")
	end
end

function DayItem:__delete()
	if self.items then
		for i,v in ipairs(self.items) do
			v:Destroy()
		end
		self.items = nil
	end
end