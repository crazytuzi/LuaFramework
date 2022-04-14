AutoPlayRewardPanel = AutoPlayRewardPanel or class("AutoPlayRewardPanel",BasePanel)
local AutoPlayRewardPanel = AutoPlayRewardPanel

function AutoPlayRewardPanel:ctor()
	self.abName = "autoplay"
	self.assetName = "AutoPlayRewardPanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.item_list = {}
	self.model = SettingModel:GetInstance()
end

function AutoPlayRewardPanel:dctor()
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
end

function AutoPlayRewardPanel:Open(data)
	AutoPlayRewardPanel.super.Open(self)
	self.rewards = data.rewards
	self.afk_time = data.afk_time
	self.data = data
end

function AutoPlayRewardPanel:LoadCallBack()
	self.nodes = {
		"close_btn", "big_bg","exp","level_head/old_level","level_head/new_level","lefttime_head/hour",
		"gold_head/gold","Scroll View/Viewport/Content","off_time","rewardbtn","lefttime_head/addbutton",
		"eat_head/tlevel","eat_head/tnlevel",
	}
	self:GetChildren(self.nodes)
    self.big_bg = GetImage(self.big_bg)
    self.exp = GetText(self.exp)
   	self.old_level = GetText(self.old_level)
   	self.new_level = GetText(self.new_level)
   	self.hour = GetText(self.hour)
   	self.gold = GetText(self.gold)
   	self.off_time = GetText(self.off_time)
   	self.tlevel = GetText(self.tlevel)
   	self.tnlevel = GetText(self.tnlevel)
	self:AddEvent()
 
    local res = "guaji_bg3"
    lua_resMgr:SetImageTexture(self,self.big_bg, "iconasset/icon_big_bg_"..res, res)
end

function AutoPlayRewardPanel:AddEvent()
	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.close_btn.gameObject,call_back)

	local function call_back(target,x,y)
		self:Close()
	end
	AddClickEvent(self.rewardbtn.gameObject,call_back)

	local function call_back(target,x,y)
		self.model:AddAfkTime()
	end
	AddClickEvent(self.addbutton.gameObject,call_back)

	local function call_back()
		self.hour.text = self.model:GetAfkTime()
	end
	self.event_id = self.model:AddListener(SettingEvent.UpdateAfkInfo, call_back)
end

function AutoPlayRewardPanel:OpenCallBack()
	self:UpdateView()
end

function AutoPlayRewardPanel:UpdateView( )
	local function get_time_str(seconds, is_floor)
		local day = math.floor(seconds/(3600*24))
		local hour = math.floor((seconds - day*3600*24)/3600)
		local min = 0
		if is_floor then
			min = math.floor((seconds - day*3600*24 - hour*3600)/60)
		else
			min = math.ceil((seconds - day*3600*24 - hour*3600)/60)
		end
		local str = "%d min"
		if day > 0 then
			str = "%dday%dh%dmin"
			return string.format(str, day, hour, min)
		elseif hour > 0 then
			str = "%dh%dmin"
			return string.format(str, hour, min)
		else
			str = "%d min"
			return string.format(str, min)
		end
	end
	self.off_time.text = "You are offline"  .. get_time_str(self.afk_time, false)
	self.exp.text = GetShowNumber(self.rewards[enum.ITEM.ITEM_EXP])
	local up_level = self.rewards[enum.ITEM.ITEM_LEVEL] or 0
	local now_level = RoleInfoModel:GetInstance():GetMainRoleLevel()
	self.old_level.text = string.format(ConfigLanguage.Common.Level, now_level - up_level)
	self.new_level.text = string.format(ConfigLanguage.Common.Level, now_level)
	self.hour.text = get_time_str(self.model:GetAfkTimeSeconds(), true)
	local names = {}
	for item_id, num in pairs(self.data.smelts) do
		local itemcfg = Config.db_item[item_id]
		local name = string.format("%s*%s", itemcfg.name, num)
		name = ColorUtil.GetHtmlStr(itemcfg.color, name)
		names[#names+1] = name
	end
	self.gold.text = table.concat(names, ",")
	--self.gold.text = self.rewards[enum.ITEM.ITEM_COIN] or 0
	self.tlevel.text = string.format(ConfigLanguage.Common.Level, self.data.smelt_old)
	self.tnlevel.text = string.format(ConfigLanguage.Common.Level, self.data.smelt_new)
	for i=1, #self.item_list do
		self.item_list[i]:destroy()
	end
	local equips = {}
	for k, v in pairs(self.rewards) do
		if k ~= enum.ITEM.ITEM_EXP and k ~= enum.ITEM.ITEM_LEVEL then
			equips[k] = (equips[k] or 0) + v
		end
	end
	for k, v in pairs(equips) do
		local param = {}
		param["model"] = self.model
		param["cfg"] = Config.db_item[k]
		param["num"] = v
		local goodsItem = GoodsIconSettorTwo(self.Content)
	    goodsItem:SetIcon(param)
	    self.item_list[#self.item_list+1] = goodsItem
	end
end

function AutoPlayRewardPanel:CloseCallBack(  )
	if self.event_id then
		self.model:RemoveListener(self.event_id)
	end
end
