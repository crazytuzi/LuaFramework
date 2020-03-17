--[[
HuoYueDuModel
  jiayong
2015年2月2日18:18:18
--数据
]]
_G.HuoYueDuModel = Module:new();

HuoYueDuModel.huoyueInfo = {};
HuoYueDuModel.xianjieupdate = false;
HuoYueDuModel.modelId = 0;
HuoYueDuModel.xianjiemodelId = 0
function HuoYueDuModel:SetHuoyueInfo(exp, level)
	if not exp then exp = self.huoyueInfo.exp or 0 end;
	if not level then level = self.huoyueInfo.level or 0 end;

	self.huoyueInfo.exp = exp;
	self.huoyueInfo.level = level;
	self:sendNotification(NotifyConsts.HuoYueDuInfoUpdata);
end

function HuoYueDuModel:SetmodelId(modelId)

	if not modelId then modelId = self.modelId or 0 end;
	self.modelId = modelId;
	self:sendNotification(NotifyConsts.HuoYueDuChangeModel)
end

function HuoYueDuModel:GetHuoyueLevel()
	return self.huoyueInfo.level or 0;
end

function HuoYueDuModel:GetmodelId()
	return self.modelId or 0;
end

function HuoYueDuModel:GetHuoyueExp()
	return self.huoyueInfo.exp or 0;
end

HuoYueDuModel.huoyueListinfo = {};
--列表信息
function HuoYueDuModel:SetHuoyueListinfo(id, num, exp)
	if not self.huoyueListinfo[id] then
		self.huoyueListinfo[id] = {};
	end;
	self.huoyueListinfo[id].id = id;
	self.huoyueListinfo[id].num = num;

	if not exp then return end
	self.huoyueInfo.exp = exp;
end

function HuoYueDuModel:GetAllHuoyueList()
	return self.huoyueListinfo;
end

function HuoYueDuModel:ClearHuoYueList()
	HuoYueDuModel.huoyueListinfo = {};
end

function HuoYueDuModel:GetIndexHuoyuelist(id)
	if self.huoyueListinfo[id] then
		return self.huoyueListinfo[id]
	end;
	return nil;
end