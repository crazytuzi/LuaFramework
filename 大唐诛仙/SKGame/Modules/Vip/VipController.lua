RegistModules("Vip/view/VipLvItem")
RegistModules("Vip/view/VipPanel")
RegistModules("Vip/VipModel")
RegistModules("Vip/view/ViptequanDesItem")
RegistModules("Vip/VipConst")

VipController = BaseClass(LuaController)

function VipController:GetInstance()
	if VipController.inst == nil then
		VipController.inst = VipController.New()
	end
	return VipController.inst
end

function VipController:__init()
	self.model = VipModel:GetInstance()
	self:Config()
	self:RegistProto()
end

function VipController:Config()
	
end

--注册协议
function VipController:RegistProto()
	self:RegistProtocal("S_ActiviteVip")
	self:RegistProtocal("S_GetVipActReward")
	self:RegistProtocal("S_GetDailyReward")
	self:RegistProtocal("S_GetDailyRewardState")
	self:RegistProtocal("S_GetPlayerVip")
	self:RegistProtocal("S_GetVipWelfare") --vip每日元宝奖励
	self:RegistProtocal("S_GetVipWelfareState") --vip每日元宝奖励
end	

-----------------------------------------------------------------------------------------------------------------------------
--------------------------------------接收消息-------------------------------------------------------------------------------

function VipController:S_GetDailyRewardState(buffer)      --接收每日领取状态（参数：每日领取状态）
	local msg = self:ParseMsg(vip_pb.S_GetDailyRewardState(), buffer)
	self.model.isDailyLQ = msg.state
	self.model:DispatchEvent(VipConst.GETFIRLQSTATE_CHANGE)
	self.model:ShowRed()
end

function VipController:S_GetPlayerVip(buffer)                   --接收玩家VIP信息（参数：vipId,过期时间，首次激活奖励领取状态（0.不可领，1.可领取，2.已领取[0,0,0]）
    local msg = self:ParseMsg(vip_pb.S_GetPlayerVip(), buffer)
    self.model.vipId = msg.vipLevel
    self.model.vipLevel = msg.vipLevel
    if toLong(msg.invalidTime) > 0 then             --int64 需要先转string再转number才能与int32比较
		self.model.timeStr = StringFormat("到期时间：{0}",TimeTool.getYMDHMS(msg.invalidTime))
	else
		self.model.timeStr = " "
	end
	---------
	if #msg.rewardState > 0 then
		self.model.lqStateTab = {}
		SerialiseProtobufList( msg.rewardState, function ( item )            --table赋值***********
			table.insert(self.model.lqStateTab, item )
		end )
	end
	---------
	GlobalDispatcher:DispatchEvent(EventName.GETVIPINFO_CHANGE, msg.vipLevel)
end

function VipController:S_ActiviteVip(buffer)              --接收激活VIP（参数：vipId当前激活的vipId,过期时间，激活领取状态 playerVipId当前玩家的最高vip等级）
	local msg = self:ParseMsg(vip_pb.S_ActiviteVip(), buffer)
	--激活vip刷新每日任务刷新次数
	if self.model.playerVipId < (msg.vipId-300) then
		local vipID = "vip"..msg.playerVipLevel
		local addNumCfgData = GetCfgData("vipPrivilege"):Get(3)[vipID]
		DailyTaskConst.FreeRefershNum = 3 + addNumCfgData

		DailyTaskController:GetInstance():GetDailyTaskList()
	end
	self.model.vipId = msg.vipId-300
	self.model.playerVipId = msg.playerVipLevel
	self.model.vipLevel = msg.playerVipLevel

	if SceneModel:GetInstance():GetMainPlayer().vipLevel <= 0 then
		self.model.isWelfareDaily = 0
	end
	SceneModel:GetInstance():GetMainPlayer().vipLevel = msg.playerVipLevel
	if self.model.lqStateTab[self.model.vipId] ~= 2 then
		self.model.lqStateTab[self.model.vipId] = msg.rewardState
	end
	self.model.timeStr = StringFormat("到期时间：{0}",TimeTool.getYMDHMS(msg.invalidTime))
	GlobalDispatcher:DispatchEvent(EventName.VIPLV_CHANGE,self.model.vipId,msg.invalidTime,msg.rewardState,msg.playerVipLevel)    --激活vip广播全局变量
	self.model:ShowRed()
end

function VipController:S_GetVipActReward(buffer)          --接收领取VIP奖励（参数：vipID，首次激活是否已领取）
	local msg = self:ParseMsg(vip_pb.S_GetVipActReward(), buffer)
	if msg.rewardState == 2 then
		self.model.lqStateTab[msg.vipId-300] = msg.rewardState
	end
	self.model.vipId = msg.vipId-300
	self.model:DispatchEvent(VipConst.FIRSTLQ_CHANGE,msg.vipId-300)
	GlobalDispatcher:DispatchEvent(EventName.VipDailyState)
	self.model:ShowRed()
end

function VipController:S_GetDailyReward(buffer)           --接收领取每日奖励（参数：领取状态）
	local msg = self:ParseMsg(vip_pb.S_GetDailyReward(), buffer)
	if msg.state == 1 then
		self.model.isDailyLQ = 1
	end
	self.model:DispatchEvent(VipConst.DAILYSTATE_CHANGE)
	GlobalDispatcher:DispatchEvent(EventName.VipDailyState)
	self.model:ShowRed()
end

function VipController:S_GetVipWelfare(buffer)           --接收领取VIP每日福利（参数：领取状态）
	local msg = self:ParseMsg(vip_pb.S_GetVipWelfare(), buffer)
	self.model.isWelfareDaily = msg.state
	self.model:DispatchEvent(VipConst.GetWelfareDailyChange)
	GlobalDispatcher:DispatchEvent(EventName.VipDailyState)
	self.model:ShowRed()
end

function VipController:S_GetVipWelfareState(buffer)           --接收每日福利状态（参数：领取状态）
	local msg = self:ParseMsg(vip_pb.S_GetVipWelfareState(), buffer)
	self.model.isWelfareDaily = msg.state
	self.model:DispatchEvent(VipConst.GetWelfareDailyChange)
	self.model:ShowRed()
end


-----------------------------------------------------------------------------------------------------------------------------
------------------------------------发送消息---------------------------------------------------------------------------------

function VipController:C_GetDailyRewardState()         --发送获取每日奖励领取装态
	self:SendEmptyMsg(vip_pb, "C_GetDailyRewardState")
end

function VipController:C_GetPlayerVip()                --发送获取玩家VIP请求
	self:SendEmptyMsg(vip_pb, "C_GetPlayerVip")
end

function VipController:C_GetVipActReward(lv)              --发送领取首次激活奖励（vip等级）
	local msg = vip_pb.C_GetVipActReward()
	msg.vipId = lv             
	self:SendMsg("C_GetVipActReward", msg)
end

function VipController:C_GetDailyReward()               --发送每日领取奖励（空消息）
	self:SendEmptyMsg(vip_pb, "C_GetDailyReward")
end

function VipController:C_GetVipWelfare()
 	self:SendEmptyMsg(vip_pb, "C_GetVipWelfare")       --发送领取vip每日元宝奖励
 end 

function VipController:C_GetVipWelfareState()
 	self:SendEmptyMsg(vip_pb, "C_GetVipWelfareState")       --发送vip每日元宝奖励领取状态
 end 

function VipController:__delete()
	VipController.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model=nil
end


