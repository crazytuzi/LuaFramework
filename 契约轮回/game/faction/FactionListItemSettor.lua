--
-- @Author: chk
-- @Date:   2018-12-05 16:05:47
--
FactionListItemSettor = FactionListItemSettor or class("FactionListItemSettor",BaseItem)
local FactionListItemSettor = FactionListItemSettor

function FactionListItemSettor:ctor(parent_node,layer,index)
	self.abName = "faction"
	self.assetName = "FactionListItem"
	self.layer = layer
	self.index = index
	self.bg = {}
	self.events = {}
	self.model = FactionModel:GetInstance()
	FactionListItemSettor.super.Load(self)
end

function FactionListItemSettor:dctor()
	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	self.bg = nil
end

function FactionListItemSettor:LoadCallBack()
	self.nodes = {
		"bg_0",
		"bg_1",
		"rank_img",
		"rank_text",
		"name",
		"president",
		"lv",
		"number",
		"power",
		"operation/CheckBtn",
		"operation/ApplyBtn",
		"operation/ApplyBtn/Apply_Text",
	}
	self:GetChildren(self.nodes)
	self.bg[0] = self.bg_0
	self.bg[1] = self.bg_1


	self:AddEvent()

	self:UpdateItem()
end

function FactionListItemSettor:AddEvent()
	local function call_back()
		FactionController.Instance:RequestFactionInfo(self.data.id)
	end
	AddClickEvent(self.CheckBtn.gameObject,call_back)

	local function call_back()
		if self.had_apply then
			local ms = string.format(ConfigLanguage.Faction.CancleApply,self.data.name)
			Dialog.ShowTwo(ConfigLanguage.Mix.Tips,ms, ConfigLanguage.Mix.Confirm, handler(self,self.CancleApply))
		else
			FactionController.Instance:RequestApplyEnterFaction(self.data.id)
		end

	end
	AddClickEvent(self.ApplyBtn.gameObject,call_back)

	self.events[#self.events+1] = self.model:AddListener(FactionEvent.ApplySucess,handler(self,self.DealApplySucess))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.CancleApplySucess,handler(self,self.CancleApplySucess))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.RefuseApply,handler(self,self.DealRefuseApply))
end

function FactionListItemSettor:CancleApply()
	FactionController.Instance:RequestCancleApplyEnterFaction(self.data.id)
end

function FactionListItemSettor:DealRefuseApply(role_id,guild_id)
	self:CancleApplySucess(guild_id)
end

function FactionListItemSettor:DealApplySucess(guild_id)
	if guild_id == self.data.id then
		self.had_apply = true
		self.Apply_Text:GetComponent('Text').text = ConfigLanguage.Faction.HadApply
	end

end

function FactionListItemSettor:CancleApplySucess(guild_id)
	if self.data.id == guild_id then
		self.had_apply = false
		self.Apply_Text:GetComponent('Text').text = ConfigLanguage.Faction.ApplyNow
	end

end

function FactionListItemSettor:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateItem()
	end
end

function FactionListItemSettor:UpdateItem()
	local rectTra = self.transform:GetComponent('RectTransform')
	if self.index % 2 == 0 then
		SetVisible(self.bg_0.gameObject,false)
		SetVisible(self.bg_1.gameObject,false)
	else
		SetVisible(self.bg_0.gameObject,false)
		SetVisible(self.bg_1.gameObject,true)
	end
	rectTra.anchoredPosition = Vector2(rectTra.anchoredPosition.x,-(self.index - 1) * rectTra.sizeDelta.y)
	if self.data.rank <= 3 then
		SetVisible(self.rank_img.gameObject,true)
		SetVisible(self.rank_text.gameObject,false)

		lua_resMgr:SetImageTexture(self,self.rank_img:GetComponent('Image'),"faction_image","faction_r_" .. self.data.rank,true)
	else
		SetVisible(self.rank_img.gameObject,false)
		SetVisible(self.rank_text.gameObject,true)

		self.rank_text:GetComponent('Text').text = self.data.rank .. ""
	end

	self.name:GetComponent('Text').text = self.data.name
	self.president:GetComponent('Text').text = self.data.chief .. ""
	self.lv:GetComponent('Text').text = self.data.level
	self.number:GetComponent('Text').text = self.data.num .. "/" .. Config.db_guild[self.data.level].memb
	self.power:GetComponent('Text').text = self.data.power .. ""

	if self.data.apply then
		self.had_apply = true
		self.Apply_Text:GetComponent('Text').text = ConfigLanguage.Faction.HadApply
	end
end