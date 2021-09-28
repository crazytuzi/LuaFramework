GuideSequence = class("GuideSequence", SequenceInstance);

function GuideSequence:GetCfg()
    return self.param;
end

function GuideSequence:Start()
	self.cacheGo = {};
	self.errorFlag = false;		--引导标识 有错误要置成true

	--激活引导
	GuideManager.Start(self.param);
	
	self.super.Start(self);
end

function GuideSequence:NextStep()
	self.super.NextStep(self);
	--执行引导
	if self.currentStep > 2 then
		GuideManager.Doing(self.param);
	end
end

function GuideSequence:Finish()
	self.super.Finish(self);
	--结束引导
	
	if self.errorFlag then
		GuideManager.Error(self.param);
	else
		GuideManager.Finish(self.param);
	end
end

function GuideSequence:Dispose()
	self.super.Dispose(self);

	GuideManager.isForceGuiding = false;
    GuideManager.forceSysGo = nil;
	
    for k, v in pairs(self.cacheGo) do
		self:RemoveCache(k);
	end
end

function GuideSequence:GetCache(key)
	return self.cacheGo[key];
end

function GuideSequence:AddToCache(key, val)
	self.cacheGo[key] = val;
end

function GuideSequence:RemoveCache(key)
	local tmp = self.cacheGo[key];
	if tmp then
		tmp:Dispose();
	end
	self.cacheGo[key] = nil;
end

function GuideSequence:SetCacheDisplay(key)
	for k, v in pairs(self.cacheGo) do
		if v then
			v:SetEnable(k == key);
		else
			--self.cacheGo[k] = nil;
		end
	end
end

function GuideSequence:SetError(param)
	--MsgUtils.ShowTips(nil, nil, nil, "引导中断了! " .. self.name .. " - " .. self.currentStep);
	Warning("引导中断 -> [".. self.name .."] - " .. self.currentStep);
	if param then
		Warning(tostring(param));
	end
	self.errorFlag = true;
end

