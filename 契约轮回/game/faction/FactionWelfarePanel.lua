--
-- @Author: chk
-- @Date:   2018-12-05 20:47:24
--
FactionWelfarePanel = FactionWelfarePanel or class("FactionWelfarePanel",WindowPanel)
local FactionWelfarePanel = FactionWelfarePanel

function FactionWelfarePanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionWelfarePanel"
	self.layer = "UI"

	self.panel_type = 5
	self.btnImg = {}
	self.btnTxt = {}
	self.events = {}
	--self.use_background = true
	--self.change_scene_close = true

	self.model = FactionModel:GetInstance()
end

function FactionWelfarePanel:dctor()
	if self.act_welf_red_point then
		self.act_welf_red_point:destroy()
		self.act_welf_red_point = nil
	end

	if self.baby_welf_red_point then
		self.baby_welf_red_point:destroy()
		self.baby_welf_red_point = nil
	end
end

function FactionWelfarePanel:Open( )
	FactionWelfarePanel.super.Open(self)
end

function FactionWelfarePanel:LoadCallBack()
	self.nodes = {
		"welfare/offline/offBtn",
		"welfare/offline/offBtn/offline_btn_Text",
		"welfare/offline/offline_Text",
		"welfare/activity/activityBtn",
		"welfare/activity/babyImage",
		"welfare/activity/activityBtn/activity_btn_Text",
		"welfare/activity/activity_Text",
		"welfare/career/career_Text",
		"welfare/career",
	}
	self:GetChildren(self.nodes)
	self.btnImg[enum.GUILD_WELFARE.GUILD_WELFARE_DAILY] = self.offBtn:GetComponent('Image')
	self.btnImg[enum.GUILD_WELFARE.GUILD_WELFARE_BABY] = self.activityBtn:GetComponent('Image')
	self.btnTxt[enum.GUILD_WELFARE.GUILD_WELFARE_DAILY] = self.offline_btn_Text:GetComponent('Text')
	self.btnTxt[enum.GUILD_WELFARE.GUILD_WELFARE_BABY] = self.activity_btn_Text:GetComponent('Text')



	self.act_welf_red_point = RedDot(self.offBtn, nil, RedDot.RedDotType.Nor)
	self.act_welf_red_point:SetPosition(52, 15)
	self.act_welf_red_point:SetRedDotParam(true)

	self.baby_welf_red_point = RedDot(self.activityBtn, nil, RedDot.RedDotType.Nor)
	self.baby_welf_red_point:SetPosition(52, 15)
	self.baby_welf_red_point:SetRedDotParam(true)

	SetVisible(self.career,false)

	self:AddEvent()
	self:UpdateView()
end

function FactionWelfarePanel:AddEvent()
	local function call_back()
		if self.model.selfFactionInfo.welfare[enum.GUILD_WELFARE.GUILD_WELFARE_DAILY] == 0 then
			FactionController.GetInstance():RequestWelf(enum.GUILD_WELFARE.GUILD_WELFARE_DAILY)
		end
	end

	AddClickEvent(self.offBtn.gameObject,call_back)


	local function call_back()
		if self.model.selfFactionInfo.welfare[enum.GUILD_WELFARE.GUILD_WELFARE_BABY] == 0 then
			FactionController.GetInstance():RequestWelf(enum.GUILD_WELFARE.GUILD_WELFARE_BABY)
		else
			Notify.ShowText(ConfigLanguage.Faction.GirlOnlyGet)
		end

	end
	AddClickEvent(self.activityBtn.gameObject,call_back)

	self.events[#self.model+1] = self.model:AddListener(FactionEvent.ReceiveWelfare,handler(self,self.DealReceiveWelfare))
	--local function call_back()
	--	FactionController.GetInstance():RequestWelf(enum.GUILD_WELFARE.GUILD_WELFARE_POST)
	--end
	--AddClickEvent(self.careerBtn.gameObject,call_back)
end

function FactionWelfarePanel:OpenCallBack()
	self:UpdateView()
end

function FactionWelfarePanel:DealReceiveWelfare(welfareType)
	if self.model.selfFactionInfo.welfare[welfareType] == 1 then --表示已经领取了
		ShaderManager.GetInstance():SetImageGray(self.btnImg[welfareType])
		self.btnTxt[welfareType].text = ConfigLanguage.Book.HadGet
	end

	if welfareType == enum.GUILD_WELFARE.GUILD_WELFARE_DAILY and  self.model.selfFactionInfo.welfare[welfareType] == 1 then

		self.act_welf_red_point:SetRedDotParam(false)
	end

	if welfareType == enum.GUILD_WELFARE.GUILD_WELFARE_BABY and  self.model.selfFactionInfo.welfare[welfareType] == 1 then
		self.baby_welf_red_point:SetRedDotParam(false)
	end


end

function FactionWelfarePanel:UpdateView( )
	self.offline_Text:GetComponent('Text').text = HelpConfig.Faction.LiXianFuLi
	self.activity_Text:GetComponent('Text').text = HelpConfig.Faction.HuoBaoFuLi
	self.career_Text:GetComponent('Text').text = HelpConfig.Faction.CareerFuLi

	self:SetTileTextImage("faction_image","faction_title_img")

	self:DealReceiveWelfare(enum.GUILD_WELFARE.GUILD_WELFARE_DAILY)
	if self.model.selfCareer == enum.GUILD_POST.GUILD_POST_BABY then
		self:DealReceiveWelfare(enum.GUILD_WELFARE.GUILD_WELFARE_BABY)
	else
		self.model.selfFactionInfo.welfare[enum.GUILD_WELFARE.GUILD_WELFARE_BABY] = 1
		self:DealReceiveWelfare(enum.GUILD_WELFARE.GUILD_WELFARE_BABY)
		self.btnTxt[enum.GUILD_WELFARE.GUILD_WELFARE_BABY].text = ConfigLanguage.Faction.GirlOnly
		--ShaderManager.GetInstance():SetImageGray(GetImage(self.babyImage))
	end

end

function FactionWelfarePanel:CloseCallBack(  )

end