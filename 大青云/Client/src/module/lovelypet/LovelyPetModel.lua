--[[LovelyPetModel
zhangshuhui
2015年6月17日11:41:11
]]

_G.LovelyPetModel = Module:new();

LovelyPetModel.lovelypetlist = {};

--当前出战的萌宠id
LovelyPetModel.fightlovelypetid = 0;

--登陆得到萌宠信息的时间
LovelyPetModel.lovelypetlisttime = 0;

--得到当前出战的萌宠id
function LovelyPetModel:GetFightLovelyPetId()
	return self.fightlovelypetid;
end
--设置当前出战的萌宠id
function LovelyPetModel:SetFightLovelyPetId(id)
	self.fightlovelypetid = id;
end

--得到萌宠list
function LovelyPetModel:GetLovelyPetList()
	return self.lovelypetlist;
end
--设置萌宠list
function LovelyPetModel:SetLovelyPetList(list)
	self.lovelypetlist = list;
	
	MountController:sendNotification(NotifyConsts.LovelyPetStateUpdata,{id=nil, index = 2});
end

--更新萌宠状态
function LovelyPetModel:UpdateLovelyPet(petVo)
	local ishave = false;
	for i,vo in ipairs(self.lovelypetlist) do
		if vo.id == petVo.id then
			self.lovelypetlist[i] = petVo;
			ishave = true;
			break;
		end
	end
	
	if ishave == false then
		table.push(self.lovelypetlist,petVo);
	end
	
	MountController:sendNotification(NotifyConsts.LovelyPetStateUpdata,{id=petVo.id, index = 1});
end

--更新萌宠时间
function LovelyPetModel:UpdateLovelyPetTime(petVo)
	local ishave = false;
	for i,vo in ipairs(self.lovelypetlist) do
		if vo.id == petVo.id then
			self.lovelypetlist[i] = petVo;
			ishave = true;
			break;
		end
	end
	
	if ishave == false then
		table.push(self.lovelypetlist,petVo);
	end
	
	MountController:sendNotification(NotifyConsts.LovelyPetTimeUpdata,{id=petVo.id});
end

--更新萌宠状态和时间
function LovelyPetModel:UpdateLovelyPetStateAndTime(petVo)
	local ishave = false;
	for i,vo in ipairs(self.lovelypetlist) do
		if vo.id == petVo.id then
			self.lovelypetlist[i] = petVo;
			ishave = true;
			break;
		end
	end
	
	if ishave == false then
		table.push(self.lovelypetlist,petVo);
	end
	
	MountController:sendNotification(NotifyConsts.LovelyPetStateUpdata,{id=petVo.id, index = 2});
end

--得到
function LovelyPetModel:GetLovelyPetListTime()
	return self.lovelypetlisttime;
end
--设置
function LovelyPetModel:SetLovelyPetListTime(time)
	self.lovelypetlisttime = time;
end