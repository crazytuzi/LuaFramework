--
-- @Author: chk
-- @Date:   2018-12-18 20:48:47
--
FactionCareerApplyItemSettor = FactionCareerApplyItemSettor or class("FactionCareerApplyItemSettor",BaseItem)
local FactionCareerApplyItemSettor = FactionCareerApplyItemSettor

function FactionCareerApplyItemSettor:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionCareerApplyItem"
	self.layer = layer

	self.model = FactionModel:GetInstance()
	FactionCareerApplyItemSettor.super.Load(self)
end

function FactionCareerApplyItemSettor:dctor()
	if self.role_icon1 then
		self.role_icon1:destroy()
		self.role_icon1 = nil
	end
end

function FactionCareerApplyItemSettor:LoadCallBack()
	self.nodes = {
		"icon_bg/icon",
		"name",
		"status",
		"refuseBtn",
		"acceptBtn",
		"vipTex",
	}
	self:GetChildren(self.nodes)
	self.vipTex = GetText(self.vipTex)
	self:AddEvent()

	self:UpdateItem()
end

function FactionCareerApplyItemSettor:AddEvent()
	local guildPermCfg =  self.model:GetPermCfg(enum.GUILD_PERM.GUILD_PERM_APPROVE)
	if self.model.selfCareer < guildPermCfg.post then
		ShaderManager.GetInstance():SetImageGray(GetImage(self.refuseBtn))
		ShaderManager.GetInstance():SetImageGray(GetImage(self.acceptBtn))
	else
		local function call_back()
			if self.data.post == enum.GUILD_POST.GUILD_POST_MEMB then
				FactionController.Instance:RequestRefuseApply(self.data.base.id)
			else
				FactionController.Instance:RequestRefuseApplyCareer(self.data.base.id)
			end
		end
		AddClickEvent(self.refuseBtn.gameObject,call_back)

		local function call_back()
			if self.data.post == enum.GUILD_POST.GUILD_POST_MEMB then
				FactionController.Instance:RequestAcceptApply(self.data.base.id)
			else
				FactionController.Instance:RequestAgreeApplyCareer(self.data.base.id)
			end

		end
		AddClickEvent(self.acceptBtn.gameObject,call_back)
	end


end

function FactionCareerApplyItemSettor:IsSelf(role_id)
	if role_id == self.data.base.id then
		return true
	else
		return false
	end
end

function FactionCareerApplyItemSettor:SetData(data)
	self.data = data
end

function FactionCareerApplyItemSettor:UpdateItem()
	local timeStr = TimeManager.Instance:GetDifTime(self.data.time,TimeManager.Instance:GetServerTime())
	local statusStr = "(" .. timeStr .. ")"
	if self.data.post == enum.GUILD_POST.GUILD_POST_MEMB then
		statusStr = ConfigLanguage.Faction.EnterFaction .. "\n" .. statusStr
	else
		statusStr = string.format(ConfigLanguage.Faction.ApplyToCareer,enumName.GUILD_POST[self.data.post])  .. "\n" .. statusStr
	end
	self.status:GetComponent('Text').text = statusStr

	self.name:GetComponent('Text').text = self.data.base.name
	self.vipTex.text = "V"..self.data.base.viplv
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
end
