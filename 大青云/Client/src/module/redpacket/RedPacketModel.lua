--[[RedPacketModel
zhangshuhui
2015年10月7日18:18:18
]]

_G.RedPacketModel = Module:new();

RedPacketModel.type = "VIP";
--物品id
RedPacketModel.tid = 0;
--提醒数量 
RedPacketModel.redpacketNum = 0;
--全服礼包提醒列表
RedPacketModel.redpacketlist = {};
--发红包剩余次数
RedPacketModel.curnum = 0;


--当前红包信息
RedPacketModel.curid = 0;
RedPacketModel.redpacketranklist = {};--奖励排行榜
RedPacketModel.sendername = ""
RedPacketModel.rewardnum = 0;

function RedPacketModel:new(type)
	local obj = {}
	setmetatable( obj, {__index = self} )
	obj.type = type;
	obj.tid = 0;
	obj.redpacketNum = 0;
	obj.redpacketlist = {};
	obj.curnum = 0;
	obj.curid = 0;
	obj.redpacketranklist = {}
	obj.sendername = ""
	obj.rewardnum = 0;
	return obj
end

--得到当前红包类型
function RedPacketModel:GetType()
	return self.type;
end

--得到当前红包id
function RedPacketModel:GetCurId()
	return self.curid;
end
--设置当前红包id
function RedPacketModel:SetCurId(id)
	self.curid = id;
end
--得到当前红包tid
function RedPacketModel:GetCurtId()
	return self.tid;
end
--设置当前红包tid
function RedPacketModel:SetCurtId(id)
	self.tid = id;
end
--得到排行榜列表
function RedPacketModel:GetPacketRankList()
	return self.redpacketranklist;
end
--设置排行榜列表
function RedPacketModel:SetPacketRankList(list)
	self.redpacketranklist = list;
end
--得到名称
function RedPacketModel:GetSenderName()
	return self.sendername;
end
--设置名称
function RedPacketModel:SetSenderName(name)
	self.sendername = name;
end

--得到奖励数量
function RedPacketModel:GetRewardNum()
	return self.rewardnum;
end
--设置奖励数量
function RedPacketModel:SetRewardNum(num)
	self.rewardnum = num;
	self:sendNotification(NotifyConsts.RedPacketUpdata);
end



--设置提醒数量
function RedPacketModel:SetredpacketNum(num)
	self.redpacketNum = num;
end
--得到提醒数量
function RedPacketModel:GetredpacketNum()
	return self.redpacketNum;
end

--设置全服礼包列表
function RedPacketModel:SetRedPacket(list)
	self.redpacketlist = list;
	self:sendNotification(NotifyConsts.RedPacketListUpdata);
end

--得到全服礼包列表
function RedPacketModel:GetRedPacketList()
	return self.redpacketlist;
end

--刷新当前红包剩余次数
function RedPacketModel:UpdateCurRedPacket(id)
	for i,vo in ipairs(self.redpacketlist) do
		if vo.id == id then
			self.redpacketlist[i].num = self.redpacketlist[i].num - 1;
			break;
		end
	end
end

--删除当前红包信息
function RedPacketModel:DeleteCurRedPacket(id)
	for i,vo in ipairs(self.redpacketlist) do
		if vo.id == id then
			table.remove(self.redpacketlist, i);
			self:sendNotification(NotifyConsts.RedPacketListUpdata);
			break;
		end
	end
end

--设置剩余次数
function RedPacketModel:SetCurNum(num)
	self.curnum = num;
end
--得到剩余次数
function RedPacketModel:GetCurNum()
	return self.curnum;
end