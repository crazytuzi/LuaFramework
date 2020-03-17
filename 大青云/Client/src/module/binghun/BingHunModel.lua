--[[LianTiodel
zhangshuhui
2015年5月20日11:09:16
]]

_G.BingHunModel = Module:new();

BingHunModel.BingHunlist = {};		--冰魂列表
BingHunModel.BingHunselectid = 0;		--当前使用的冰魂

function BingHunModel:GetBingHunList()
	return self.BingHunlist;
end

function BingHunModel:SetBingHunList(list)
	self.BingHunlist = list;
end

function BingHunModel:UpdateBingHun(vo)
	self.BingHunlist[vo.id] = vo;
	
	Notifier:sendNotification(NotifyConsts.BingHunUpdate,{id=vo.id});
end

function BingHunModel:GetBingHunSelect()
	return self.BingHunselectid;
end
function BingHunModel:SetBingHunSelect(id)
	self.BingHunselectid = id;
	
	Notifier:sendNotification(NotifyConsts.BingHunUpdate,{id=id,ischange=true});
	SkillController:OnBingHunSkillChange();
end

function BingHunModel:GetBingHunSkill()
	local cfg = t_binghun[self.BingHunselectid];
	if not cfg then return 0; end
	return cfg.skill;
end

function BingHunModel:GetBingHunById(id)
	if self.BingHunlist[id] then
		return self.BingHunlist[id];
	end
	return nil;
end