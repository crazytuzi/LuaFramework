--[[
兵灵：model

]]

BingLingModel = Module:new();

-- 兵灵等阶
BingLingModel.level = 0; -- 0 ~ 10, 0为未开启
-- 进阶祝福值
BingLingModel.blessing = 0;

--兵灵信息
BingLingModel.binglinglist = {};

-- 进阶时自动购买
BingLingModel.autoBuy = false;
--当前选中等阶
BingLingModel.selectLevel = 0;
function BingLingModel:SetInfo(info)
	self.binglinglist = info;
	self:sendNotification( NotifyConsts.BingLingUpdate );
end
function BingLingModel:GetBingLingList()
	return self.binglinglist;
end

function BingLingModel:UpdateBingLingVO(vo)
	local isfind = false;
	for i,binglingvo in ipairs(self.binglinglist) do
		if toint(binglingvo.id/1000) == toint(vo.id/1000) then
			binglingvo.id = vo.id;
			binglingvo.progress = vo.progress;
			isfind = true;
			break;
		end
	end
	if not isfind then
		table.push(self.binglinglist, vo);
	end
	if vo.id%1000 == 1 and vo.progress == 0 then
		self:sendNotification( NotifyConsts.BingLingBlessing,{id=toint(vo.id/1000)} );
	else
		self:sendNotification( NotifyConsts.BingLingBlessing );
	end
end

-- 兵灵等级上限
function BingLingModel:GetMaxLevel(id)
	local maxlevel = 0;
	for i = id*1000,id*1000 + 100 do
		if not t_shenbingbingling[i] then
			maxlevel = i - 1;
			break;
		end
	end
	return maxlevel;
end

function BingLingModel:GetLevel()
	return self.level;
end

function BingLingModel:GetSelectLevel()
	return self.selectLevel;
end
function BingLingModel:SetSelectLevel(selectLevel)
	self.selectLevel = selectLevel;
	self:sendNotification( NotifyConsts.ChangeBingLingModel );
end

function BingLingModel:GetBlessing()
	return self.blessing;
end