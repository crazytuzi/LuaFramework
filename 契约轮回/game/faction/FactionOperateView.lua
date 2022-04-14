--
-- @Author: chk
-- @Date:   2018-12-18 14:54:03
--
FactionOperateView = FactionOperateView or class("FactionOperateView",BaseItem)
local FactionOperateView = FactionOperateView

function FactionOperateView:ctor(parent_node,layer)
	self.abName = "faction"
	self.assetName = "FactionOperateView"
	self.layer = layer
	self.count = 30
	self.model = FactionModel:GetInstance()
	self.isBtn = true
	self.events = {}
	FactionOperateView.super.Load(self)
end

function FactionOperateView:dctor()
	self.model:RemoveTabListener(self.events)
	if self.app_red_point then
		self.app_red_point:destroy()
		self.app_red_point = nil
	end
	--if self.btnSchedule then
	--	GlobalSchedule:Stop(self.btnSchedule)
	--	self.btnSchedule = nil
	--end
end

function FactionOperateView:LoadCallBack()
	self.nodes = {
		"bg",
		"CloseBtn",
		"mask",
		"btns/LogBtn",
		"btns/careerApplyBtn",
		"btns/impeachBtn",
		"btns/quitFactionBtn",
		"btns/quitFactionBtn/quitText",
		"btns/quitBtn","btns/recruitBtn",
		"btns/recruitBtn/recruitBtnText",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	SetVisible(self.quitBtn,false)
	SetVisible(self.recruitBtn,false)
	self.recruitBtnText = GetText(self.recruitBtnText)
	self.recruitBtn = GetButton(self.recruitBtn)
	self:UpdateView()

	self.app_red_point = RedDot(self.careerApplyBtn, nil, RedDot.RedDotType.Nor)
	self.app_red_point:SetPosition(57, 20)

	self.app_red_point:SetRedDotParam(self.model.redPoints[1])

end

function FactionOperateView:AddEvent()
	local function call_back()
		SetVisible(self.gameObject,false)
	end
	AddClickEvent(self.CloseBtn.gameObject,call_back)

	AddClickEvent(self.mask.gameObject,call_back)

	local function call_back()
		lua_panelMgr:GetPanelOrCreate(FactionOperatePanel):Open(1)
		self.model:Brocast(FactionEvent.CloseOperateView)
	end
	AddClickEvent(self.LogBtn.gameObject,call_back)

	local function call_back()
		lua_panelMgr:GetPanelOrCreate(FactionOperatePanel):Open(2)
		self.model:Brocast(FactionEvent.CloseOperateView)
	end
	AddClickEvent(self.careerApplyBtn.gameObject,call_back)

	local guildPermCfg = self.model:GetPermCfg(enum.GUILD_PERM.GUILD_PERM_DISBAND)
	if self.model.selfCareer >= guildPermCfg.post then
		local btnScp = self.impeachBtn:GetComponent('Button')
		btnScp.enabled = false
		ShaderManager.GetInstance():SetImageGray(self.impeachBtn:GetComponent('Image'))
	else
		local function call_back()
			FactionController.Instance:RequestImpeach()
		end
		AddClickEvent(self.impeachBtn.gameObject,call_back)
	end




	local function call_back()
		local function call_back()
			if self.model.selfCareer == enum.GUILD_POST.GUILD_POST_CHIEF then
				--FactionController.GetInstance():RequestDisband()
				FactionController.GetInstance():RequestUpLV()
			else
				FactionController.GetInstance():RequestQuitFaction()
			end
		end


		local tip = ""
		if self.model.selfCareer == enum.GUILD_POST.GUILD_POST_CHIEF then
			local curLv = self.model.guildLv
			local nextLv = curLv + 1
			local cfg = Config.db_guild[curLv]
			if not cfg then
				Notify.ShowText("The current guild has reached its max level")
				return
			end
			local const = cfg.fund
			tip = string.format("Guild is Lv.%s, spend %s guild fund to upgrade 1 level?",curLv,const)
			--tip = ConfigLanguage.Faction.RealyDissolution
		else
			tip = ConfigLanguage.Faction.QuitFaction
		end
		Dialog.ShowTwo(ConfigLanguage.Mix.Tips,tip,nil,call_back)
	end
	AddClickEvent(self.quitFactionBtn.gameObject,call_back)

	local function call_back()
		local function call_back()
			lua_panelMgr:GetPanelOrCreate(FactionAppointmentPanel):Open(enum.GUILD_POST.GUILD_POST_CHIEF)
		end
		local msg = "If you are the guild leader, please transfer your leadership to a deputy"
		Dialog.ShowOne("Tip",msg,"Confirm",call_back,10)
	end
	AddClickEvent(self.quitBtn.gameObject,call_back)

	local function call_back()
		if self.model.isBtn then
			self.model.isBtn = false
			self.recruitBtn.interactable = false
			local role = RoleInfoModel.GetInstance():GetMainRoleData()
			local text = role.gname.."Our guild is recruiting! Win easier with strong guildmates! Grow together!"
			ChatController.GetInstance():RequestSendChat(enum.CHAT_CHANNEL.CHAT_CHANNEL_WORLD , 0, text)
			self.recruitBtnText.text = self.model.btnCount
			--self.btnSchedule = GlobalSchedule:Start(handler(self,self.BtnCutDown),1,5)
			self.model:StartBtnCountDown()
		else
			Notify.ShowText("You talked too frequently, please try later")
		end


	end
	AddClickEvent(self.recruitBtn.gameObject,call_back)

	local function call_back()
		self.recruitBtnText.text = self.model.btnCount
		if self.model.isBtn then
			self.recruitBtnText.text = "Recruit"
			self.recruitBtn.interactable = true
		end
	end
	self.events[#self.events + 1] = self.model:AddListener(FactionEvent.BtnCountDown,call_back)

end

function FactionOperateView:BtnCutDown()
	self.count = self.count - 1
	self.recruitBtnText.text = self.count
	if self.count <= 0 then
		self.count = 30
		self.isBtn = true
		self.recruitBtnText.text = "Recruit"
		self.recruitBtn.interactable = true
	end
end

function FactionOperateView:SetData(data)

end

function FactionOperateView:UpdateView()

	local myCareer = self.model:SetSelfCadre()
	if myCareer == enum.GUILD_POST.GUILD_POST_MEMB then
		SetVisible(self.quitBtn,false)
		SetVisible(self.recruitBtn,false)
		SetSizeDeltaY(self.bg, 205)
		self.quitText:GetComponent('Text').text = "Leave guild"
	end

	if myCareer == enum.GUILD_POST.GUILD_POST_CHIEF then
		--SetVisible(self.quitFactionBtn,false)
		self.quitText:GetComponent('Text').text = "Upgrade guild"
		SetVisible(self.quitBtn,true)
		SetVisible(self.recruitBtn,true)

		SetSizeDeltaY(self.bg, 300)
	end

	if myCareer == enum.GUILD_POST.GUILD_POST_VICE or myCareer == enum.GUILD_POST.GUILD_POST_BABY
	or myCareer == enum.GUILD_POST.GUILD_POST_ELDER then
		SetVisible(self.quitBtn,false)
		SetVisible(self.recruitBtn,true)
		SetSizeDeltaY(self.bg, 245)
	end


end
