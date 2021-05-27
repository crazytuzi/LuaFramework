require("scripts/game/guanggao/guanggao_view")
require("scripts/game/guanggao/guanggao_data")

-- 广告
GuanggaoCtrl = GuanggaoCtrl or BaseClass(BaseController)
function GuanggaoCtrl:__init()
	if GuanggaoCtrl.Instance ~= nil then
		ErrorLog("[GuanggaoCtrl] attempt to create singleton twice!")
		return
	end
	GuanggaoCtrl.Instance = self

	self.view = GuanggaoView.New(ViewName.Guanggao)
	self.data = GuanggaoData.New()

	self:RegisterAllProtocols()
end	

function GuanggaoCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.roledata_change_callback then
		RoleData.Instance:UnNotifyAttrChange(self.roledata_change_callback)
		self.roledata_change_callback = nil 
	end

	GuanggaoCtrl.Instance = nil
end	

function GuanggaoCtrl:RegisterAllProtocols()
	self.roledata_change_callback = BindTool.Bind1(self.RoleDataChangeCallback,self)
	RoleData.Instance:NotifyAttrChange(self.roledata_change_callback)
	self:RegisterProtocol(SCOpenServerAdvertisementRewardResult, "OnRewardResultData")
end

-- 请求本日开服广告奖励领取状态
function GuanggaoCtrl:SendServerStateReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAdvertisementState)
	protocol:EncodeAndSend()
end

-- 请求领取本日开服广告奖励
function GuanggaoCtrl:SendRewardResult()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOpenServerAdvertisementReward)
	protocol:EncodeAndSend()
end

function GuanggaoCtrl:RoleDataChangeCallback(key, value)
	if key == OBJ_ATTR.CREATURE_LEVEL then
		self:SendServerStateReq()
		self:AdvertiseTipShow()
	end
end

function GuanggaoCtrl:OnRewardResultData(protocol)
	self.data:SetRewardInfo(protocol)
	self:IsShowTip()
	self:AdvertiseTipShow()
	self.view:Flush()
end

function GuanggaoCtrl:AdvertiseTipShow()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local open_day = OtherData.Instance:GetOpenServerDays()
	local state = self.data:GetBtnShowState(open_day)
	if ClientGuanggaoDayCfg.levelLimit <= level then
		if state == 0 then
			ViewManager.Instance:Open(ViewName.Guanggao)
		end
	end
end

function GuanggaoCtrl:IsShowTip()
	local num = 0
	local open_day = OtherData.Instance:GetOpenServerDays()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local state = self.data:GetBtnShowState(open_day)
	if ClientGuanggaoDayCfg.levelLimit <= level then
		if state == 0 then
			num = 1
		end
	end

	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.ADVERTISEMENT, num, function()
			self.view:Open()
		end)
	RemindManager.Instance:DoRemind(RemindName.Guanggao)
end