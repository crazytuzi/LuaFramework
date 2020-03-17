--[[
	2015年10月23日21:46:53
	wangyanwei
]]

_G.MascotComeNoticeManager = {};

MascotComeNoticeManager.mapCfg = {};
function MascotComeNoticeManager:AddMapId(id)
	if self.mapCfg[id] then
		return
	end
	self.mapCfg[id] = {};
	self.mapCfg[id].state = 0;		--0标记  显示
end

function MascotComeNoticeManager:CloseMapId(id)
	if not self.mapCfg[id] then
		return
	end
	self.mapCfg[id].state = 1;		--1标记  不显示
end

function MascotComeNoticeManager:GetHaveId(id)
	if not self.mapCfg[id] then
		return false;
	end
	return true
end

--当前地图是否显示  0true
function MascotComeNoticeManager:GetIDCfg(id)
	if not self.mapCfg[id] then
		return
	end
	return self.mapCfg[id].state == 0;
end

function MascotComeNoticeManager:CloseCfg()
	self.mapCfg = {};
	if UIMoscotComeNotice:IsShow() then
		UIMoscotComeNotice:Hide();
	end
end