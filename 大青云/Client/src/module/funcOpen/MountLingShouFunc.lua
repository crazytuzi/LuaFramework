--[[
兵魂功能
lizhuangzhuang
2015年10月9日16:58:09
]]

_G.MountLingShouFunc = setmetatable({},{__index=BaseFunc});

FuncManager:RegisterFuncClass(FuncConsts.MountLingShou,MountLingShouFunc);

MountLingShouFunc.waitOpenShow = false;

function MountLingShouFunc:OnFuncOpen()
	if CPlayerMap:GetCurMapID() == 10340007 then
		self.waitOpenShow = true;
	else
		--临时法宝
		UIFabao:Show();
		-- UIMountShowView:OpenPanel(301)
		-- self:ChangeMount();
	end
end

function MountLingShouFunc:OnChangeSceneMap()
	--[[if self.waitOpenShow then
		TimerManager:RegisterTimer(function()
			UIMountShowView:OpenPanel(301)
			self:ChangeMount();
		end,200,1)
		self.waitOpenShow = false;
	end--]]
end

function MountLingShouFunc:ChangeMount()
	--[[
	--强制使用最新皮肤
	MountController:ChangeMount(301);
	--强制骑上坐骑
	if MountModel.ridedMount.mountState == 0 then
		MountController:RideMount();
	end
	--]]
end