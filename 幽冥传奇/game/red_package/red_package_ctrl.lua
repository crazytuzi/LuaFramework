require("scripts/game/red_package/red_package_data")
require("scripts/game/red_package/red_package_view")
require("scripts/game/red_package/red_package_tips_page")
require("scripts/game/red_package/red_package_gift_page")

RedPackageCtrl = RedPackageCtrl or BaseClass(BaseController)

function RedPackageCtrl:__init()
	if RedPackageCtrl.Instance then
		ErrorLog("[RedPackageCtrl]:Attempt to create singleton twice!")
	end
	RedPackageCtrl.Instance = self
	self.view = RedPackageView.New(ViewName.RedPackage)
	self.data = RedPackageData.New()
	self.tips_page = RedPaperTipsPage.New(ViewName.RedPackageTips)
	self.gift_page = RedPaperGiftPage.New(ViewName.RedPackageGift)
	self:RegisterAllProtocols()
	self.rob_req_type = 0
end

function RedPackageCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil


	self.data:DeleteMe()
	self.data = nil

	if self.role_data_change_back then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_change_back)
		self.role_data_change_back = nil 
	end

	RedPackageCtrl.Instance = nil
end

function RedPackageCtrl:RegisterAllProtocols()
	self.role_data_change_back = BindTool.Bind(self.RoleDataChangeCallback,self)	
	RoleData.Instance:NotifyAttrChange(self.role_data_change_back)
	self:RegisterProtocol(SCRedPaperActivityInfoIss,"OnRedPaperActivityInfoIss")
	self:RegisterProtocol(SCRedPaperMoneyIss,"OnRedPaperMoneyIss")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))

	GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.RobTime, self, -1),  60)

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.RedPackage)
end

function RedPackageCtrl:OnRecvMainRoleInfo()
	self:SendRedPaperInfo()
end

function RedPackageCtrl:RobTime()
	self:PackChangeBack()
end

function RedPackageCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.RedPackage then
		return self.data:GetRedPaperRemindNum()
	end
end

-- 领红包
function RedPackageCtrl:SendReceiveRedPaper()
	local protocol = ProtocolPool.Instance:GetProtocol(CSRedPaperReceive)
	protocol:EncodeAndSend()
end

-- 请求信息
function RedPackageCtrl:SendRedPaperInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSRedPaperInfo)
	protocol:EncodeAndSend()
	self.rob_req_type = 0
	-- self.view:Flush()
end

-- 发送红包
function RedPackageCtrl:SendRedPaperNumber(num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendRedPaper)
	protocol.money = num
	protocol:EncodeAndSend()
	-- self.view:Flush()
end

-- 抢红包
function RedPackageCtrl:RobRedPaperInfo()
	self.rob_req_type = 1
	local protocol = ProtocolPool.Instance:GetProtocol(CSRobRedPaper)
	protocol:EncodeAndSend()
end

-- 请求红包信息
function RedPackageCtrl:OnRedPaperActivityInfoIss(protocol)
	self.data:SetRedPaperInfo(protocol)
	if self.rob_req_type == 1 then
		local rob_yb, rob_time = RedPackageData.Instance:GetNotVipRobNum()

		-- local cur_data = {}
		-- for k, v in pairs(rob_data) do
		-- 	if v.rob_type == 2 then
		-- 		table.insert(cur_data, v)
		-- 	end
		-- end

		local vip_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_VIP_GRADE)
		if vip_level == 0 then
			ViewManager.Instance:Open(ViewName.RedPackageTips)
			ViewManager.Instance:FlushView(ViewName.RedPackageTips, 0, "param", {rob_yb})
		end	
	end
	self.view:Flush()
	self:PackChangeBack()
	RemindManager.Instance:DoRemind(RemindName.RedPackage)
end

function RedPackageCtrl:RoleDataChangeCallback(key, value, old_value)
	if key == OBJ_ATTR.ACTOR_VIP_GRADE and old_value == 0 then
		self:SendRedPaperInfo()
		self:PackChangeBack()
	end
end

function RedPackageCtrl:OnRedPaperMoneyIss(protocol)
	self.data:SetRobPaperShow(protocol)
	self:PackChangeBack()
	self.view:Flush()
end

function RedPackageCtrl:PackChangeBack()
	local num = 0
	local table = NationwideRedPacketsConfig.getRedPacketsTime[1]
	local open_time = ActivityData.GetTimesSecond(table[1])
	local end_time = ActivityData.GetTimesSecond(table[2])
	local now_time = ActivityData.GetNowShortTime()
	local _, cd_time, rob_num = self.data:GetNotVipRobNum()
	local my_rank, my_donate_yb, remaind_yb = RedPackageData.Instance:GetPersonalInfoData()
	if now_time >= open_time and now_time <= end_time then
		if remaind_yb >= NationwideRedPacketsConfig.canNotGetGoldSystemGoldNum then
			if rob_num > 0 then
				if cd_time - Status.NowTime <= 0 then
					num = 1
				end
			end
		end
	end

	if IS_ON_CROSSSERVER then
		return 
	end

	MainuiCtrl.Instance:InvateTip(MAINUI_TIP_TYPE.RED_PAPER, num, function()
			self.view:Open()
		end)
	RemindManager.Instance:DoRemind(RemindName.RedPackage)
end