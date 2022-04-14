--
-- @Author: chk
-- @Date:   2018-12-08 11:56:58
--
BaseFactionInfoCareerItemSettor = BaseFactionInfoCareerItemSettor or class("BaseFactionInfoCareerItemSettor",BaseItem)
local BaseFactionInfoCareerItemSettor = BaseFactionInfoCareerItemSettor

function BaseFactionInfoCareerItemSettor:ctor(parent_node,layer,index)
	--self.abName = "faction"
	--self.assetName = "FactionInfoCareerItem"
	self.layer = layer
	self.index = index
	self.career = nil
	self.can_appointment = false --是否可以任命
	self.is_operateAppoint = false --是否操作任命
	self.is_operateDisAppoint  = false --是否操作任免
	self.is_operateApply = false   --是否操作申请职位
	self.events = {}
	self.model = FactionModel:GetInstance()
	--BaseFactionInfoCareerItemSettor.super.Load(self)
end

function BaseFactionInfoCareerItemSettor:dctor()
	self.model.lastInfoCareerItem = nil

	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end
end

function BaseFactionInfoCareerItemSettor:LoadCallBack()
	self.nodes = {
		"select",
		"touch",
		"c_bg",
		--"c_bg/role_Icon",
		--"n_bg/name_Text",
		"n_bg",
		"name_Text",
		"c_bg/career_Text",
		"becomBtn",
		"applyBtn",
		"disBtn",
	}
	self:GetChildren(self.nodes)
	self.name_TextTxt = self.name_Text:GetComponent('Text')
	self.career_TextTxt = self.career_Text:GetComponent('Text')
	self.n_bgImg = GetImage(self.n_bg)
	--self.role_Icon_Img = self.role_Icon:GetComponent('Image')
	--self.c_bg_img = self.c_bg:GetComponent('Image')
	self:AddEvent()


	if self.data ~= nil then
		self:UpdateItem()
	elseif self.need_load_end then
		self:InitItem()
	end
end

function BaseFactionInfoCareerItemSettor:AddEvent()

	local function call_back(target,x,y)
		if self.career ~= nil then
			self.model:Brocast(FactionEvent.CancleOperateApplyCareer,self.index)
			self.is_operateAppoint = true
			lua_panelMgr:GetPanelOrCreate(FactionAppointmentPanel):Open(self.career)
		end

	end
	AddClickEvent(self.becomBtn.gameObject,call_back)

	local function call_back()
		if self.career ~= nil then
			local roleInfo =  RoleInfoModel.Instance:GetMainRoleData()
			if self.career == enum.GUILD_POST.GUILD_POST_BABY and roleInfo.career == enum.GENDER.GENDER_MALE then
				Notify.ShowText(ConfigLanguage.Faction.ApplyBabyOnly)
			else
				local message = string.format(ConfigLanguage.Faction.ReallyApplyCareer,enumName.GUILD_POST[tonumber(self.career_TextTxt.text)])
				local function call_back()
					FactionController.Instance:RequestApplyCareer(self.career)
				end
				Dialog.ShowTwo(ConfigLanguage.Faction.CareerApply,message,ConfigLanguage.Mix.Confirm,call_back)
			end
		end
	end

	AddClickEvent(self.applyBtn.gameObject,call_back)


	local function call_back()
		self.model:Brocast(FactionEvent.CancleOperateAppoint,self.index)
		self.is_operateDisAppoint = true
		local function call_back()
			FactionController.Instance:RequestDisCareer(self.data.base.id)
		end
		local message = string.format(ConfigLanguage.Faction.DisAppointment,self.data.base.name)
		Dialog.ShowTwo(ConfigLanguage.Faction.DisAppointment2,message,ConfigLanguage.Mix.Confirm,call_back)
	end
	AddClickEvent(self.disBtn.gameObject,call_back)


	local function call_back()
		if self.data ~= nil then
			self:SelectItem()
			--self.model:Brocast(FactionEvent.SelectCadre,self.data.id)
		else
			if self.model.selfCareer == enum.GUILD_POST.GUILD_POST_CHIEF or self.model.selfCareer == enum.GUILD_POST.GUILD_POST_VICE then
				if self.career ~= nil then
					self.model:Brocast(FactionEvent.CancleOperateApplyCareer,self.index)
					self.is_operateAppoint = true
					lua_panelMgr:GetPanelOrCreate(FactionAppointmentPanel):Open(self.career)
				end
			else
				if self.career ~= nil then
					local roleInfo =  RoleInfoModel.Instance:GetMainRoleData()
					if self.career == enum.GUILD_POST.GUILD_POST_BABY and roleInfo.career == enum.GENDER.GENDER_MALE then
						Notify.ShowText(ConfigLanguage.Faction.ApplyBabyOnly)
					else
						local message = string.format(ConfigLanguage.Faction.ReallyApplyCareer,enumName.GUILD_POST[tonumber(self.career_TextTxt.text)])
						local function call_back()
							FactionController.Instance:RequestApplyCareer(self.career)
						end
						Dialog.ShowTwo(ConfigLanguage.Faction.CareerApply,message,ConfigLanguage.Mix.Confirm,call_back)
					end
				end
			end


			--if self.career ~= nil then
			--	local roleInfo =  RoleInfoModel.Instance:GetMainRoleData()
			--	if self.career == enum.GUILD_POST.GUILD_POST_BABY and roleInfo.career == enum.GENDER.GENDER_MALE then
			--		Notify.ShowText(ConfigLanguage.Faction.ApplyBabyOnly)
			--	else
			--		local message = string.format(ConfigLanguage.Faction.ReallyApplyCareer,enumName.GUILD_POST[tonumber(self.career_TextTxt.text)])
			--		local function call_back()
			--			FactionController.Instance:RequestApplyCareer(self.career)
			--		end
			--		Dialog.ShowTwo(ConfigLanguage.Faction.CareerApply,message,ConfigLanguage.Mix.Confirm,call_back)
			--	end
			--end
		end

	end
	AddClickEvent(self.touch.gameObject,call_back)




	self.events[#self.events+1] = self.model:AddListener(FactionEvent.DisCareerSucess,handler(self,self.DealDisCareer))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.ApplyCareer,handler(self,self.DealApplyCareer))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.CancleOperateApplyCareer,handler(self,self.DealCancleOpearteApplyCareer))
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.CancleOperateAppoint,handler(self,self.DealCancleOperateAppoint))

end

function BaseFactionInfoCareerItemSettor:SetData(data)
	if self.is_loaded then
		self.data = data
		self:UpdateItem()
	else
		self.data = data
	end

end

function BaseFactionInfoCareerItemSettor:DealCancleOpearteApplyCareer(index)
	if self.index ~= index then
		self.is_operateApply = false
	end
end

function BaseFactionInfoCareerItemSettor:DealCancleOperateAppoint(index)
	if self.index ~= index then
		self.is_operateAppoint = false
	end
end

function BaseFactionInfoCareerItemSettor:DealApplyCareer(career)
	if self.data ~= nil and self.data.post == career and self.is_operateApply then

		self.data = self.model:GetSelf()
		self:UpdateItem()
	end
end


function BaseFactionInfoCareerItemSettor:LoadItem(role_id)
	self.data = self.model:GetMemberByUdi(role_id)
	self:UpdateItem()
end

function BaseFactionInfoCareerItemSettor:DealDisCareer(role_id)
	if self.data ~= nil and self.data.base.id == role_id then
		self:InitItem()
	end
end

function BaseFactionInfoCareerItemSettor:InitItem()
	if self.index == 1 then
		self.career = enum.GUILD_POST.GUILD_POST_CHIEF
	elseif self.index <= self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_VICE] and
			self.index < self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_VICE] + self.model.factionCfg.vice then
		self.career = enum.GUILD_POST.GUILD_POST_VICE
	elseif self.index <= self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_BABY] and
			self.index < self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_BABY] + self.model.factionCfg.baby then
		self.career = enum.GUILD_POST.GUILD_POST_BABY
	elseif self.index <= self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_ELDER] and
			self.index < self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_ELDER] + self.model.factionCfg.elder then
		self.career = enum.GUILD_POST.GUILD_POST_ELDER
	end



	if self.is_loaded then
		if self.index == 1 then
			self.career_TextTxt.text = enum.GUILD_POST.GUILD_POST_CHIEF
		elseif self.index <= self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_VICE] and
				self.index < self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_VICE] + self.model.factionCfg.vice then
			self.career_TextTxt.text = enum.GUILD_POST.GUILD_POST_VICE
			--self.career = enum.GUILD_POST.GUILD_POST_VICE
		elseif self.index <= self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_BABY] and
			self.index < self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_BABY] + self.model.factionCfg.baby then
			self.career_TextTxt.text = enum.GUILD_POST.GUILD_POST_BABY
		elseif self.index <= self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_ELDER] and
				self.index < self.model.careerFromIndex[enum.GUILD_POST.GUILD_POST_ELDER] + self.model.factionCfg.elder then
			self.career_TextTxt.text = enum.GUILD_POST.GUILD_POST_ELDER
			--self.career = enum.GUILD_POST.GUILD_POST_ELDER
		end

		if self.model.selfCareer == enum.GUILD_POST.GUILD_POST_CHIEF or self.model.selfCareer == enum.GUILD_POST.GUILD_POST_VICE then
			self.can_appointment = true

			self.name_TextTxt.text =  string.format("<color=#67ff2b>%s</color>", ConfigLanguage.Faction.AppointmentNow)
		else
			self.name_TextTxt.text = string.format("<color=#67ff2b>%s</color>", ConfigLanguage.Faction.ApplyNow)
		end

		self.data = nil
		self.is_operateApply = false
		self.is_operateAppoint = false
		self.is_operateDisAppoint = false

		--local guildPerCfg = Config.db_guild_perm[enum.GUILD_PERM.]
		if self.model.selfCareer > enum.GUILD_POST.GUILD_POST_ELDER then
			SetVisible(self.becomBtn.gameObject,true)
			SetVisible(self.applyBtn.gameObject,false)
		else
			SetVisible(self.applyBtn.gameObject,true)
			SetVisible(self.becomBtn.gameObject,false)
		end


		--SetVisible(self.becomBtn.gameObject,true)
		SetVisible(self.disBtn.gameObject,false)
		--self.c_bg_img.enabled = false
	--	lua_resMgr:SetImageTexture(self, self.role_Icon_Img, "faction_image", "boy", true)
		lua_resMgr:SetImageTexture(self, self.n_bgImg, "faction_image",
				"faction_i_bg1", true)
		self:SetPosition()
	else
		self.need_load_end = true
	end

end

function BaseFactionInfoCareerItemSettor:SelectItem()
	if self.model.lastInfoCareerItem ~= nil then
		SetVisible(self.model.lastInfoCareerItem.select.gameObject,false)
		SetVisible(self.model.lastInfoCareerItem.disBtn.gameObject,false)
	end
	SetVisible(self.select.gameObject,true)
	SetVisible(self.disBtn.gameObject,true)
	local roleInfo =  RoleInfoModel.Instance:GetMainRoleData()
	if roleInfo.id == self.data.base.id  then
		SetVisible(self.disBtn.gameObject,false)
	else
		if self.model.selfCareer > enum.GUILD_POST.GUILD_POST_ELDER  then
			SetVisible(self.disBtn.gameObject,true)
		else
			SetVisible(self.disBtn.gameObject,false)
		end
	end
	if self.data.post == enum.GUILD_POST.GUILD_POST_CHIEF then
		SetVisible(self.disBtn.gameObject,false)
	end

	self.model.lastInfoCareerItem = self
	self.model:Brocast(FactionEvent.SelectCadre,self.data)
end

function BaseFactionInfoCareerItemSettor:SetPosition()
	local x = math.floor(self.index / 6)
	local y = (self.index - 1) % 5
	SetAnchoredPosition(self.transform,8.62 + x * 410, 28-y * 85)
--	SetLocalPosition(self.transform,8.62 + x * 400, 28-y * 85)
end

function BaseFactionInfoCareerItemSettor:UpdateItem( ... )
	if self.data == nil then
		return
	end

	SetVisible(self.becomBtn.gameObject,false)
	self:SetPosition()

	self.is_operateApply = false
	self.is_operateAppoint = false
	self.is_operateDisAppoint = false

	--self.c_bg_img.enabled = true
	self.name_TextTxt.text = self.data.base.name
	self.career_TextTxt.text = self.data.post
	lua_resMgr:SetImageTexture(self, self.n_bgImg, "faction_image",
	"faction_i_bg", true)

	--SetVisible(self.role_Icon_Img.gameObject,true)
	--lua_resMgr:SetImageTexture(self, self.role_Icon_Img, "main_image",
			--"img_role_head_" .. self.data.base.career, true)
	if self.data.post == enum.GUILD_POST.GUILD_POST_CHIEF then
		self:SelectItem()
	end

	local roleInfo =  RoleInfoModel.Instance:GetMainRoleData()
	if roleInfo.id == self.data.base.id then
		SetVisible(self.becomBtn.gameObject,false)
		--SetVisible(self.disBtn.gameObject,false)
	else
		if self.model.selfCareer > enum.GUILD_POST.GUILD_POST_ELDER  then
			--SetVisible(self.disBtn.gameObject,true)
			SetVisible(self.becomBtn.gameObject,false)
		else
			SetVisible(self.becomBtn.gameObject,false)
			--SetVisible(self.disBtn.gameObject,false)
		end
	end

	SetVisible(self.disBtn.gameObject,false)
	--if self.data.post == enum.GUILD_POST.GUILD_POST_CHIEF then
	--	SetVisible(self.disBtn.gameObject,false)
	--end
end