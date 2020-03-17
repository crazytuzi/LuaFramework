--[[新婚红包Model
]]

_G.RedPacketMarryModel = RedPacketModel:new("MARRY")

--设置奖励数量
function RedPacketMarryModel:SetRewardNum(num)
	self.rewardnum = num;
	self:sendNotification(NotifyConsts.RedPacketUpdata);
end

--删除当前红包信息
function RedPacketMarryModel:DeleteCurRedPacket(id)
	for i,vo in ipairs(self.redpacketlist) do
		if vo.id == id then
			table.remove(self.redpacketlist, i);
			self:sendNotification(NotifyConsts.RedPacketListUpdata);
			break;
		end
	end
end