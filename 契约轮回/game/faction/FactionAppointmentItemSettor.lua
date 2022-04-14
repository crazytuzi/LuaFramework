--
-- @Author: chk
-- @Date:   2018-12-17 16:58:51
--
FactionAppointmentItemSettor = FactionAppointmentItemSettor or class("FactionAppointmentItemSettor",BaseItem)
local FactionAppointmentItemSettor = FactionAppointmentItemSettor

function FactionAppointmentItemSettor:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionAppointmentItem"
	self.layer = layer
	self.canAppoint = true
	self.is_operateAppoint = false --是否操作了任命
	self.is_operateApply = false   --是否操作了申请职位
	self.career = nil
	self.events = {}
	self.model = FactionModel:GetInstance()
	FactionAppointmentItemSettor.super.Load(self)
end

function FactionAppointmentItemSettor:dctor()
	--if self.vipSettor ~= nil then
	--	self.vipSettor:destroy()
	--end

	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end
	if self.role_icon1 then
		self.role_icon1:destroy()
		self.role_icon1 = nil
	end
end

function FactionAppointmentItemSettor:LoadCallBack()
	self.nodes = {
		"selectBtn",
		"selectBtn/Text",
		"FactionContri",
		"power",
		"career_Text",
		"name",
		"icon_bg/icon",
		--"disBtn",
		"disBtn",
		"vipTex",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.vipTex = GetText(self.vipTex)
	self.FactionContri = GetText(self.FactionContri)
	self:UpdateItem()
end


function FactionAppointmentItemSettor:AddEvent()
	local function call_back()
		if self.canAppoint then
			local message = string.format(ConfigLanguage.Faction.Appointment,self.data.base.name,
					enumName.GUILD_POST[self.model.appointCareer])

			Dialog.ShowTwo(ConfigLanguage.Faction.AppointmentCareer,message,ConfigLanguage.Mix.Confirm,
					handler(self,self.Appointment))
		else
			Chkprint("不能任命")
		end
	end

	AddClickEvent(self.selectBtn.gameObject,call_back)


	local function call_back()
		if self.canAppoint then
			local function call_back()
				FactionController.Instance:RequestDisCareer(self.data.base.id)
			end
			local message = string.format(ConfigLanguage.Faction.DisAppointment,self.data.base.name)
			Dialog.ShowTwo(ConfigLanguage.Faction.DisAppointment2,message,ConfigLanguage.Mix.Confirm,call_back)
		end

	end
	AddClickEvent(self.disBtn.gameObject,call_back)
	self.events[#self.events+1] = self.model:AddListener(FactionEvent.AppointmentSucess,handler(self,self.DealAppointment))

	self.events[#self.events+1] = self.model:AddListener(FactionEvent.DisCareerSucess,handler(self,self.DealDisCareer))

end

function FactionAppointmentItemSettor:Appointment()

	if self.career == 1 then
		FactionController:GetInstance():RequestDemis(self.data.base.id)
	else
		FactionController.GetInstance():RequestAppointment(self.data.base.id,self.model.appointCareer)
	end

end

function FactionAppointmentItemSettor:DealDisCareer(role_id)
	if self.data ~= nil and self.data.base.id == role_id then
		SetVisible(self.disBtn.gameObject,false)
		SetVisible(self.selectBtn.gameObject,true)
	end
end


function FactionAppointmentItemSettor:DealAppointment(data)
	if self.data.base.id == data.role_id then
		SetVisible(self.disBtn.gameObject,true)
		SetVisible(self.selectBtn.gameObject,false)

		self.career_Text:GetComponent('Text').text = enumName.GUILD_POST[data.post]
		self.canAppoint = false
		lua_resMgr:SetImageTexture(self,self.selectBtn:GetComponent('Image'),"common_image",
					"btn_gray_3",true,nil,false)
		lua_resMgr:SetImageTexture(self,self.disBtn:GetComponent('Image'),"common_image",
				"btn_gray_3",true,nil,false)

		----self.data = roleInfo
		--self.career_Text:GetComponent('Text').text = enumName.GUILD_POST[career]
		--
		--
		--if career == self.career then --是一样的
		--	if self.model.selfCareer > self.career then
		--		self.Text:GetComponent('Text').text = ConfigLanguage.Faction.DisCareer
		--	else
		--		lua_resMgr:SetImageTexture(self,self.selectBtn:GetComponent('Image'),"common_image",
		--				"btn_gray_3",true,nil,false)
		--	end
		--else
		--	lua_resMgr:SetImageTexture(self,self.selectBtn:GetComponent('Image'),"common_image",
		--			"btn_gray_3",true,nil,false)
		--end
	end
end

function FactionAppointmentItemSettor:SetData(data,career)
	self.data = data
	self.career = career
end

function FactionAppointmentItemSettor:UpdateItem()
	local powerStr = self.data.base.power
	if self.data.base.power > 99999999 then
		powerStr = GetShowNumber(self.data.base.power)
	end
	self.power:GetComponent('Text').text = powerStr
	self.career_Text:GetComponent('Text').text = enumName.GUILD_POST[self.data.post]
	self.name:GetComponent('Text').text  = self.data.base.name
	self.FactionContri.text = GetShowNumber(self.data.ctrb)

	--lua_resMgr:SetImageTexture(self,self.icon:GetComponent('Image'),"main_image","img_role_head_" ..
	--self.data.base.career,true)
	if self.role_icon1 then
		self.role_icon1:destroy()
		self.role_icon1 = nil
	end
	local param = {}
	local function uploading_cb()
		--  logError("回调")
	end
	--param["is_squared"] = true
	--param["is_hide_frame"] = true
	param["size"] = 65
	param["uploading_cb"] = uploading_cb
	param["role_data"] = self.data.base
	self.role_icon1 = RoleIcon(self.icon)
	self.role_icon1:SetData(param)

	--self.vipSettor = VipValueItemSettor(self.data.base.vip)
	--self.vipSettor:SetData(self.data.base.viplv)
	self.vipTex.text = "V"..self.data.base.viplv
	if self.data.post == self.model.appointCareer then
		SetVisible(self.disBtn.gameObject,true)
		SetVisible(self.selectBtn.gameObject,false)
	else
		SetVisible(self.disBtn.gameObject,false)
		SetVisible(self.selectBtn.gameObject,true)
	end


	local roleModelData = RoleInfoModel.GetInstance():GetMainRoleData()
	if self.data.base.id == roleModelData.id then
		self.canAppoint = false
		lua_resMgr:SetImageTexture(self,self.selectBtn:GetComponent('Image'),"common_image",
				"btn_gray_3",true,nil,false)
		lua_resMgr:SetImageTexture(self,self.disBtn:GetComponent('Image'),"common_image",
				"btn_gray_3",true,nil,false)

	end
	--if self.model.selfCareer <= self.data.post or self.data.post >= self.model.appointCareer
	--		or self.data.post >= enum.GUILD_POST.GUILD_POST_BABY then
	--	self.canAppoint = false
	--
	--	ShaderManager.GetInstance():SetImageGray(self.selectBtn:GetComponent('Image'))
	--end

	--if not self.data.online or self.data.logout == 0 then
	--	self.name:GetComponent('Text').text  = "<color=#878787>" .. self.data.base.name .. "</color>"
	--end
end