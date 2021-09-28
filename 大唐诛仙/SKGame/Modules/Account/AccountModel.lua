
AccountModel =BaseClass(LuaModel)

function AccountModel:GetInstance()
	if AccountModel.inst == nil then
		AccountModel.inst = AccountModel.New()
	end
	return AccountModel.inst
end

function AccountModel:__init()
	self.rewardState = -1 --绑定奖励领取状态 （0: 未领， 1: 已领）
	self.bizId = 0
	self.code = 0
	self.bindTelePhone = "0"
end

function AccountModel:ParseSysBindState(data)
	self.bindTelePhone = data.telePhone
	self.rewardState = data.rewardState
	self:DispatchEvent(AccountConst.Update)
end

function AccountModel:ParseBindData(data)
	self.bizId = data.bizId
	self:DispatchEvent(AccountConst.GetNewValidateCode, data)
end

function AccountModel:ParseSBindPhone(data)
	self.bindTelePhone = data.telePhone
	Message:GetInstance():TipsMsg("绑定成功")
	self:DispatchEvent(AccountConst.Update, data)
end

function AccountModel:__delete()
	AccountModel.inst = nil
end

function AccountModel:Reset()
	self.rewardState = -1 --绑定奖励领取状态 （0: 未领， 1: 已领）
	self.bizId = 0
	self.code = 0
	self.bindTelePhone = "0"
end