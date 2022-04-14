--
-- @Author: chk
-- @Date:   2018-12-18 20:22:55
--
FactionCareerApplyView = FactionCareerApplyView or class("FactionCareerApplyView",BaseItem)
local FactionCareerApplyView = FactionCareerApplyView

function FactionCareerApplyView:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionCareerApplyView"
	self.layer = layer

	self.items = {}
	self.events = {}
	self.emptyGirlView = nil
	self.model = FactionModel:GetInstance()
	FactionCareerApplyView.super.Load(self)
end

function FactionCareerApplyView:dctor()
	for i, v in pairs(self.items) do
		v:destroy()
	end

	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	self.events = {}

	if self.emptyGirlView ~= nil then
		self.emptyGirlView:destroy()
	end
end

function FactionCareerApplyView:LoadCallBack()
	self.nodes = {
		"empty",
		"ScrollView",
		"EnterFactionSet",
		"ScrollView/Viewport/Content",
		"EnterFactionSet/EnterFactionSetBtn",
		"EnterFactionSet/OneKeyEnterBtn",
		"EnterFactionSet/Image/enterTip",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
end

function FactionCareerApplyView:AddEvent()


	--大于等于长老权限
	if self.model.selfCareer >= enum.GUILD_POST.GUILD_POST_ELDER then
		SetVisible(self.ScrollView.gameObject,true)
		--SetVisible(self.EnterFactionSet.gameObject,true)
		SetVisible(self.empty.gameObject,false)

		self.model.applyList.appliants = {}
		self.events[#self.events+1] = self.model:AddListener(FactionEvent.ApplyList,handler(self,self.LoadItems))
		self.events[#self.events+1] = self.model:AddListener(FactionEvent.AcceptApply,handler(self,self.DealAcceptApply))
		self.events[#self.events+1] = self.model:AddListener(FactionEvent.RefuseApply,handler(self,self.DealRefuseApply))
		self.events[#self.events+1] = self.model:AddListener(FactionEvent.RefuseApplyCareer,handler(self,self.DealRefuseApplyCareer))
		self.events[#self.events+1] = self.model:AddListener(FactionEvent.AgreeApplyCareer,handler(self,self.DealAgreeApplyCareer))

		FactionController.Instance:RequestApplyList(1)


	else
		SetVisible(self.ScrollView.gameObject,false)
		--SetVisible(self.EnterFactionSet.gameObject,false)
		SetVisible(self.empty.gameObject,true)


		self.emptyGirlView  = EmptyGirl(self.empty,ConfigLanguage.Faction.LeastZL)
	end

	--显示入会设置
	if self.model.selfCareer >= enum.GUILD_POST.GUILD_POST_CHIEF then
		SetVisible(self.EnterFactionSet.gameObject,true)

		self.events[#self.events+1] = self.model:AddListener(FactionEvent.FactionSetInfo, handler(self,self.DealSetInfo))
		self.events[#self.events+1] = self.model:AddListener(FactionEvent.FactionSetSucess,handler(self,self.DealSetInfo))

		if self.model.factionSetInfo ~= nil  then
			self:DealSetInfo()
		else
			FactionController.Instance:RequestFactionSetInfo()
		end
		local function call_back()
			lua_panelMgr:GetPanelOrCreate(FactionEnterSetPanel):Open()
		end
		AddClickEvent(self.EnterFactionSetBtn.gameObject,call_back)

		local function call_back()
			for i, v in pairs(self.model.applyList.appliants or {}) do
				if v.post == enum.GUILD_POST.GUILD_POST_MEMB then
					FactionController.Instance:RequestAcceptApply(v.base.id)
				end
			end
		end
		AddClickEvent(self.OneKeyEnterBtn.gameObject,call_back)
	else
		SetVisible(self.EnterFactionSet.gameObject,false)
	end
end

function FactionCareerApplyView:SetData(data)

end

function FactionCareerApplyView:DealAgreeApplyCareer(role_id)
	self:DealAcceptApply(role_id)
end

function FactionCareerApplyView:DealRefuseApplyCareer(role_id)
	self:DealAcceptApply(role_id)
end

function FactionCareerApplyView:DealAcceptApply(role_id)
	for i, v in pairs(self.items) do
		if v.data ~= nil and v.data.base.id == role_id then
			v:destroy()
			self.items[i] = nil
			break
		end
	end

	--if table.nums(self.items) <= 0 then
	--
	--end
end

function FactionCareerApplyView:DealRefuseApply(role_id,factionId)
	self:DealAcceptApply(role_id)
end

function FactionCareerApplyView:DealSetInfo()
	self.enterTip:GetComponent('Text').text = string.format(ConfigLanguage.Faction.FactionSetInfo,
			self.model.factionSetInfo.level,self.model.factionSetInfo.power)
end

function FactionCareerApplyView:LoadItems()
	local function call_back(a1,a2)
		if a1 ~= nil and a2 ~= nil then
			return a1.time > a2.time
		end
	end

	table.sort(self.model.applyList.appliants or {},call_back)
	for i, v in pairs(self.model.applyList.appliants) do
		local item = FactionCareerApplyItemSettor(self.Content)
		item:SetData(v)
		table.insert(self.items,item)
	end
end
