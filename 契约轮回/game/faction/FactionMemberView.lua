--
-- @Author: chk
-- @Date:   2018-12-05 11:48:34
--
FactionMemberView = FactionMemberView or class("FactionMemberView",BaseItem)
local FactionMemberView = FactionMemberView

function FactionMemberView:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionMemberView"
	self.layer = layer

	self.itemSettors = {}
	self.factionItems = {}
	self.views = {}
	self.btnSelects = {}
	self.btnSelectsTex = {}
	self.events = {}
	self.viewIdx = 1
	self.lastViewIdx = 1
	self.model = FactionModel:GetInstance()
	FactionMemberView.super.Load(self)
end

function FactionMemberView:dctor()
	self.model.isMemberPanel = false
	self.model:RemoveTabListener(self.events)
	for i, v in pairs(self.itemSettors) do
		v:destroy()
	end

	for i, v in pairs(self.factionItems) do
		v:destroy()
	end

	if self.emptyGirl ~= nil then
		self.emptyGirl:destroy()
	end
	self.views = nil
	self.btnSelects = nil
	self.btnSelectsTex = nil
end

function FactionMemberView:LoadCallBack()
	self.nodes = {
		"girlContain",
		"MemberScrollView",
		"FactionScrollView",
		"MemberScrollView/Viewport/MemberContent",
		"FactionScrollView/Viewport/FactionContent",
		"btns/memberBtn",
		"btns/memberBtn/memberSelect",
		"btns/factionBtn",
		"btns/factionBtn/factionSelect",
		"downObj/downDes1","wenhao",
		"btns/memberBtn/memberBtnText","btns/factionBtn/factionBtnText",

	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.model.isMemberPanel = true
	self.memberBtnText = GetText(self.memberBtnText)
	self.factionBtnText = GetText(self.factionBtnText)
	self.views[1] = self.MemberScrollView
	self.views[2] = self.FactionScrollView
	self.btnSelects[1] = self.memberSelect
	self.btnSelects[2] = self.factionSelect
	self.btnSelectsTex[1] = self.memberBtnText
	self.btnSelectsTex[2] = self.factionBtnText

	self.downDes1 = GetText(self.downDes1)
	if self.viewIdx == 1 then
		self:CreateMemberItems()
	elseif self.viewIdx == 2 then
		self:CreateFactionItems()
	end
	self:SetDes()
end


function FactionMemberView:AddEvent()
	local function call_back()
		self:Click(1)
	end
	AddClickEvent(self.memberBtn.gameObject,call_back)


	local function call_back()
		self:Click(2)
	end
	AddClickEvent(self.factionBtn.gameObject,call_back)

	local function call_back()
		ShowHelpTip(HelpConfig.Faction.listPanel,2)
	end
	AddButtonEvent(self.wenhao.gameObject,call_back)


	self.events[#self.events+1] = self.model:AddListener(FactionEvent.FactionList,handler(self,self.UpdateFactionList))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.KitOut,handler(self,self.DealKitOut))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.AppointmentSucess,handler(self,self.AppointmentSucess))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.Demise,handler(self,self.AppointmentSucess))

	self.events[#self.events+1] = self.model:AddListener(FactionEvent.DisCareerSucess,handler(self,self.DisCareerSucess))
end

function FactionMemberView:SetData(data)

end

function FactionMemberView:SetDes()
	local  caree = self.model.selfCareer
	if caree == enum.GUILD_POST.GUILD_POST_VICE or caree == enum.GUILD_POST.GUILD_POST_CHIEF  then
		self.downDes1.text = "1. Finish guild quests so you can earn guild funds 2. You can only transfer guild leadership to the deputy"
	else
		self.downDes1.text = "Finish guild quests so you can earn guild funds！"
	end
end

function FactionMemberView:Click(index)
	SetVisible(self.btnSelects[self.lastViewIdx],false)
	SetVisible(self.btnSelects[index],true)
	SetColor(self.btnSelectsTex[index], 133, 132, 176, 255)
	SetColor(self.btnSelectsTex[self.lastViewIdx], 255, 255, 255, 255)
	SetVisible(self.views[self.lastViewIdx].gameObject,false)
	SetVisible(self.views[index].gameObject,true)

	if index == 1 then
		self:ClearMemberItems()
		self:CreateMemberItems()
	elseif index == 2 then
		self:ClearFactionItems()
		self:CreateFactionItems()
	end

	self.lastViewIdx = index
end

function FactionMemberView:ClearMemberItems()
	for i, v in pairs(self.itemSettors) do
		v:destroy()
	end

	self.itemSettors = {}
end

function FactionMemberView:CreateMemberItems()
	local index = 1

	for i, v in pairs(self.itemSettors) do
		v:destroy()
	end

	if table.nums(self.model.members) <= 0 then
		if self.emptyGirl == nil then
			self.emptyGirl = EmptyGirl(self.girlContain,ConfigLanguage.Faction.EnterFactionPlease)
		end
		SetVisible(self.emptyGirl.gameObject,true)

	else
		self.itemSettors = {}
		for i, v in pairs(self.model.members) do
			self.itemSettors[#self.itemSettors+1] = FactionMemberItem(self.MemberContent)
			self.itemSettors[#self.itemSettors]:SetData(v,index)

			index = index + 1
		end
	end
end

function FactionMemberView:DealKitOut()
	self:CreateMemberItems()
end

function FactionMemberView:ClearFactionItems()
	for i, v in pairs(self.factionItems) do
		v:destroy()
	end

	self.factionItems = {}
end


function FactionMemberView:CreateFactionItems()
	if self.emptyGirl ~= nil then
		SetVisible(self.emptyGirl.gameObject,false)
	end

	--if table.nums(self.model.factionLst) <= 0 then
		FactionController.Instance:RequestFactionList()
	--else
	--	self:UpdateFactionList()
	--end
end

function FactionMemberView:UpdateFactionList()
	if table.nums(self.factionItems) ~= table.nums(self.model.factionLst) then
		for i, v in pairs(self.factionItems) do
			v:destroy()
		end

		self.factionItems = {}
		for i, v in pairs(self.model.factionLst) do
			local item = FactionListItemSettor2(self.FactionContent,"UI")
			item:SetData(v,i)
			table.insert(self.factionItems,item)
		end
	end
end

function FactionMemberView:AppointmentSucess()
	self:CreateMemberItems()
end


function FactionMemberView:DisCareerSucess()
	self:CreateMemberItems()
end


