
RewardCodeCtrl = BaseClass(LuaController)

function RewardCodeCtrl:GetInstance()
	if RewardCodeCtrl.inst == nil then
		RewardCodeCtrl.inst = RewardCodeCtrl.New()
	end
	return RewardCodeCtrl.inst
end

function RewardCodeCtrl:__init()
	resMgr:AddUIAB("RewardCode")
	self.model = RewardCodelModel:GetInstance()
	self:RegistProto()
end

function RewardCodeCtrl:RegistProto()
	self:RegistProtocal("S_GetGiftAward")
end

function RewardCodeCtrl:S_GetGiftAward(buffer)
	local msg = self:ParseMsg(activity_pb.S_GetGiftAward(), buffer)
	if msg.state == 0 then
		local str = "恭喜您，激活码正确\n奖品已通过邮箱发送给你，请注意查收"
		UIMgr.Win_Alter("温馨提示", str, "确定", function()  end)
	end
end

function RewardCodeCtrl:C_GetGiftAward(giftCode)
	local msg = activity_pb.C_GetGiftAward()
	msg.giftCode = giftCode
	self:SendMsg("C_GetGiftAward", msg)
end

function RewardCodeCtrl:__delete()
	RewardCodeCtrl.inst = nil
	if self.model then
		self.model:Destroy()
	end
	self.model=nil
end