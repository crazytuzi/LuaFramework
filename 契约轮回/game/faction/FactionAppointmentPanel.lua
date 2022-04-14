--
-- @Author: chk
-- @Date:   2018-12-17 16:54:57
--
FactionAppointmentPanel = FactionAppointmentPanel or class("FactionAppointmentPanel",WindowPanel)
local FactionAppointmentPanel = FactionAppointmentPanel

function FactionAppointmentPanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionAppointmentPanel"
	self.layer = "UI"
	self.events = {}
	--self.use_background = true
	--self.change_scene_close = true
	self.ScrollViews = {}
	self.itemContent = {}
	self.itemSettors = {}    --表中表
	self.idxMapCareer = {}
	self.careerMapIdx = {}
	self.panel_type = 5
	self.index = 1
	self.career = enum.GUILD_POST.GUILD_POST_VICE
	self.lastIndex = 1
	self.model = FactionModel:GetInstance()

	self.show_sidebar = true		--是否显示侧边栏
	if self.show_sidebar then		-- 侧边栏配置
		if self.model.selfCareer == enum.GUILD_POST.GUILD_POST_CHIEF then
			self.sidebar_data = {
				{text = "Guild Leader",id = 1,img_title = "faction:faction_appointment_f",},
				{text = ConfigLanguage.Faction.FBangZhu,id = 2,img_title = "faction:faction_appointment_f",},
				{text = ConfigLanguage.Faction.ZhangLao,id = 3,img_title = "faction:faction_appointment_f",},
				{text = ConfigLanguage.Faction.BaoBei,id = 4,img_title = "faction:faction_appointment_f",},
			}
		else
			self.sidebar_data = {
				{text = ConfigLanguage.Faction.FBangZhu,id = 2,img_title = "faction:faction_appointment_f",},
				{text = ConfigLanguage.Faction.ZhangLao,id = 3,img_title = "faction:faction_appointment_f",},
				{text = ConfigLanguage.Faction.BaoBei,id = 4,img_title = "faction:faction_appointment_f",},
			}
		end

	end

	self.idxMapCareer[1] = enum.GUILD_POST.GUILD_POST_CHIEF
	self.idxMapCareer[2] = enum.GUILD_POST.GUILD_POST_VICE
	self.idxMapCareer[3] = enum.GUILD_POST.GUILD_POST_ELDER
	self.idxMapCareer[4] = enum.GUILD_POST.GUILD_POST_BABY

	self.careerMapIdx[enum.GUILD_POST.GUILD_POST_CHIEF] = 1
	self.careerMapIdx[enum.GUILD_POST.GUILD_POST_VICE] = 2
	self.careerMapIdx[enum.GUILD_POST.GUILD_POST_ELDER] = 3
	self.careerMapIdx[enum.GUILD_POST.GUILD_POST_BABY] = 4
end

function FactionAppointmentPanel:dctor()
	for i, v in pairs(self.itemSettors) do
		for ii, vv in pairs(v or {}) do
			vv:destroy()
		end
	end
	self.model:RemoveTabListener(self.events)
	self.itemContent = nil
	self.ScrollViews = nil
end

function FactionAppointmentPanel:Open(career)
	self.career = career
	self.default_table_index = self.careerMapIdx[self.career]
	FactionAppointmentPanel.super.Open(self)
end

function FactionAppointmentPanel:LoadCallBack()
	self.nodes = {
		"FbzScrollView",
		"FbzScrollView/Viewport/FbzContent",
		"BaoBeiScrollView",
		"BaoBeiScrollView/Viewport/BaoBeiContent",
		"ZLScrollView",
		"ZLScrollView/Viewport/ZLContent","chiefObj",
		"BZScrollView","BZScrollView/Viewport/BZContent",
	}

	self:GetChildren(self.nodes)
	self.ScrollViews[1] = self.BZScrollView
	self.ScrollViews[2] = self.FbzScrollView
	self.ScrollViews[3] = self.ZLScrollView
	self.ScrollViews[4] = self.BaoBeiScrollView

	self.itemContent[1] = self.BZContent
	self.itemContent[2] = self.FbzContent
	self.itemContent[3] = self.ZLContent
	self.itemContent[4] = self.BaoBeiContent

	self.itemSettors[1] = {}
	self.itemSettors[2] = {}
	self.itemSettors[3] = {}
	self.itemSettors[4] = {}
	self.model:SetCanAppointmentMembers()
	self:AddEvent()

	SetVisible(self.ScrollViews[1].gameObject,false)
	SetVisible(self.ScrollViews[2].gameObject,false)
	SetVisible(self.ScrollViews[3].gameObject,false)
	SetVisible(self.ScrollViews[4].gameObject,false)
end

function FactionAppointmentPanel:AddEvent()
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.Demise,handler(self,self.DealDemise))
end

function FactionAppointmentPanel:OpenCallBack()
	self:UpdateView()
end

function FactionAppointmentPanel:DealDemise(data)
	self:Close()
end

function FactionAppointmentPanel:UpdateView( )

	self.default_table_index = self.careerMapIdx[self.career]
end

function FactionAppointmentPanel:CloseCallBack(  )

end

function FactionAppointmentPanel:SwitchCallBack(index)
	SetVisible(self.ScrollViews[self.lastIndex].gameObject,false)
	SetVisible(self.ScrollViews[index].gameObject,true)

	self.model.appointCareer = self.idxMapCareer[index]

	SetVisible(self.chiefObj,index == 1)
	self.model:SetCanAppointmentMembers()
	for i, v in pairs(self.itemSettors) do
		for ii, vv in pairs(v or {}) do
			vv:destroy()
		end
	end
	--if table.nums(self.itemSettors[index]) <= 0 then
		local mems = {}
		if self.model.appointCareer == enum.GUILD_POST.GUILD_POST_BABY then
			mems = self.model.girlMems
		elseif self.model.appointCareer == enum.GUILD_POST.GUILD_POST_CHIEF  then
			mems = self.model.canViceMems
		else
			mems = self.model.canAppointMems
		end

		for i, v in pairs(mems or {}) do
			local item = FactionAppointmentItemSettor(self.itemContent[index],self.idxMapCareer[index])
			table.insert(self.itemSettors[index],item)
			item:SetData(v,index)
		end
	--end


	self.lastIndex = index
end
