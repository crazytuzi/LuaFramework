ZsVipRedpackerData = ZsVipRedpackerData or BaseClass()

ZsVipRedpackerData.INFO_CHANGE = "ZsVipRedpackerData_info_change"
function ZsVipRedpackerData:__init()
	if ZsVipRedpackerData.Instance then
		ErrorLog("[ZsVipRedpackerData] attempt to create singleton twice!")
		return
	end
	ZsVipRedpackerData.Instance = self

	--数据派发组件
	GameObject.Extend(self):AddComponent(EventProtocol):ExportMethods()

	self.done_num = 0				--幸运红包已爆次数
	self.tq_done_num = 0			--特权卡红包已爆次数
	self.tq_add_num = 0				--特权卡附加次数
end

function ZsVipRedpackerData:__delete()

end

function ZsVipRedpackerData:SetProData(pro)
	self.done_num = pro.done_num				
	self.tq_done_num = pro.tq_done_num
	self.tq_add_num = pro.tq_add_num	
	self:DispatchEvent(ZsVipRedpackerData.INFO_CHANGE, {
		done_num = self.done_num,				
		tq_done_num = self.tq_done_num,
		tq_add_num = self.tq_add_num,	
	})
end

function ZsVipRedpackerData:GetRewardRemind()
	return BillionRedPacketCfg.generalMaxTms - self.done_num + self.tq_add_num - self.tq_done_num	
end
