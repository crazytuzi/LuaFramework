MainUIViewHideShow = MainUIViewHideShow or BaseClass(BaseRender)

function MainUIViewHideShow:__init()
	-- 钓鱼面板用的隐藏显示mianview具体的模块
	self.fishing_panel = self:FindObj("FishingPanel")
	self.mining_panel = self:FindObj("MiningPanel")
	self.kf_liujie_panel = self:FindObj("KfLiuJiePanel")

	self.is_fishing = self:FindVariable("IsFishing")
	self.is_mining = self:FindVariable("IsMining")
	self.is_kf_liujie = self:FindVariable("IsKfLiuJie")
end

function MainUIViewHideShow:__delete()
end

-- true隐藏指定mianview面板
function MainUIViewHideShow:HideShowFishing(value)
	self.is_fishing:SetValue(value)
	self.fishing_panel.toggle.isOn = value
end

-- true隐藏指定mianview面板
function MainUIViewHideShow:HideShowMining(value)
	self.is_mining:SetValue(value)
	self.mining_panel.toggle.isOn = value
end

function MainUIViewHideShow:HideShowKfLiuJie(value)
	self.is_kf_liujie:SetValue(value)
	self.kf_liujie_panel.toggle.isOn = value
end
