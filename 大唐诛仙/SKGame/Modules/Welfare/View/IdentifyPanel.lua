IdentifyPanel = BaseClass(LuaUI)
function IdentifyPanel:__init( ... )
	self.URL = "ui://g35bobp2nkjq23";
	self:__property(...)
	self:InitEvent()
	self:Config()
end

-- Set self property
function IdentifyPanel:SetProperty( ... )
end

-- start
function IdentifyPanel:Config()
	self.name.promptText = "请输入真实姓名"
	self.id.promptText = "请输入身份证号码"
end

function IdentifyPanel:InitEvent()
	self.onlineTime = 0
	self.rewardState = WelfareConst.IdentifyRewardState.None
	self.IDState = WelfareConst.IdentifyState.None
	self.model = WelfareModel:GetInstance()
	self.ctrl = WelfareController:GetInstance()
	self.reward = self.model:GetIdentifyReward()
	self.rewardList = {}
	self:AddBtnClick()
	self:AddEventListener()
end

function IdentifyPanel:AddBtnClick()
	self.rewardBtn.onClick:Add(function ()
		self:RewardBtnClick()
	end)
end

function IdentifyPanel:AddEventListener()
	self.handler1 = self.model:AddEventListener(WelfareConst.ChangeIDState, function ( state )
		self.IDState = state
		self:RefreshIdState()
	end)

	self.handler2 = self.model:AddEventListener(WelfareConst.ChangeRewardState, function ( state )
		self.rewardState = state
		self:RefreshBtnState()
	end)
end

function IdentifyPanel:RemoveEventListener()
	if self.handler1 then
		self.model:RemoveEventListener(self.handler1)
		self.handler1 = nil
	end

	if self.handler2 then
		self.model:RemoveEventListener(self.handler2)
		self.handler2 = nil
	end
	self.model = nil
end

function IdentifyPanel:RewardBtnClick()
	if self.rewardState == WelfareConst.IdentifyRewardState.None then
		self:IsIdentifyAvailable(self.name.text, self.id.text)
	elseif self.rewardState == WelfareConst.IdentifyRewardState.CanGet then
		self.ctrl:C_GetIdCheckAward(self.model:GetIdentifyRewardId())
	-- elseif self.rewardState == WelfareConst.IdentifyRewardState.HasGet then
	end
end

function IdentifyPanel:ShowReward()
	if self.rewardList then
		for i,v in ipairs(self.rewardList) do
			v:Destroy()
		end
	end
	self.rewardList = {}

	local list = self["giftList"..self.IDState]
	for i = 1, #self.reward do
		local iconData = self.reward[i]
		local icon = PkgCell.New(list)
		icon:OpenTips(true)
		icon:SetDataByCfg(iconData[1], iconData[2], iconData[3], iconData[4])
		self.rewardList[i] = icon
	end
end

function IdentifyPanel:RefreshBtnState()
	self.rewardCtrl.selectedIndex = self.rewardState
end

function IdentifyPanel:RefreshIdState()
	-- if self.IDState == WelfareConst.IdentifyState.HasID then
	-- 	self.IDCtrl.selectedIndex = 1
	-- 	self:SetItemVisible(false)
	-- elseif self.IDState == WelfareConst.IdentifyState.NoID then
	-- 	self.IDCtrl.selectedIndex = 0
	-- 	self:SetItemVisible(true)
	-- end
	self.IDCtrl.selectedIndex = self.IDState
	self:SetItemVisible()
end

function IdentifyPanel:SetItemVisible()
	local isShow = self.IDState == WelfareConst.IdentifyState.NoID
	self.noId.visible = isShow
	self.hasId.visible = not isShow
	self:ShowReward()
end

function IdentifyPanel:IsIdentifyAvailable(name, id)
	if name == "" then
		Message:GetInstance():TipsMsg("名字不能为空")
		return
	end

	if id == "" then
		Message:GetInstance():TipsMsg("身份证号码不能为空")
		return
	end

	if CheckIsIdentify(id) and CheckIsName(name) then
		self.ctrl:C_IdentityCheck(name, id)
	elseif not CheckIsIdentify(id) then
		Message:GetInstance():TipsMsg("身份证格式有误")
	elseif not CheckIsName(name) then
		Message:GetInstance():TipsMsg("姓名格式有误")
	end
end

-- wrap UI to lua
function IdentifyPanel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Welfare","IdentifyPanel");

	self.rewardBtn = self.ui:GetChild("rewardBtn")
	self.rewardCtrl = self.rewardBtn:GetController("rewardCtrl")
	self.IDCtrl = self.ui:GetController("IDCtrl")
	self.giftList0 = self.ui:GetChild("giftList0")
	self.giftList1 = self.ui:GetChild("giftList1")
	self.name = self.ui:GetChild("name")
	self.id = self.ui:GetChild("id")
	self.hasIdPic = self.ui:GetChild("hasIdPic")
	self.hasIdTxt = self.ui:GetChild("hasIdTxt")
	self.noId = self.ui:GetChild("noId")
	self.hasId = self.ui:GetChild("hasId")

	WelfareController:GetInstance():C_GetIdentCheckInfo()
end

-- Combining existing UI generates a class
function IdentifyPanel.Create( ui, ...)
	return IdentifyPanel.New(ui, "#", {...})
end

function IdentifyPanel:__delete()
	self:RemoveEventListener()
	self.rewardState = WelfareConst.IdentifyRewardState.None
	self.IDState = WelfareConst.IdentifyState.None
	self.onlineTime = 0
	self.ctrl = nil
	self.reward = nil
	if self.rewardList then 
		for i,v in ipairs(self.rewardList) do
			v:Destroy()
		end
	end
	self.rewardList = nil
end