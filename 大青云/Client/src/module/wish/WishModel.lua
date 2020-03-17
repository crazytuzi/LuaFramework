--[[
祈愿	
wangshuai
]]

_G.WishModel = Module:new();

WishModel.wishInfoList = {};

function WishModel:Updatainfo(id,lastnum,withnum)
	local vo = {};
	vo.id = id;
	vo.lastnum = lastnum
	vo.withnum = withnum;
	WishModel.wishInfoList[id] = vo
end;

function WishModel:GetWishInfo(id)
	for i,info in pairs(self.wishInfoList) do 
		if info.id == id then 
			return info
		end;
	end;
end;

function WishModel:GetConsumptionYuanBao(id)
	local cfg = self:GetWishInfo(id)
	if not cfg then return 0 end;	
	local wih = cfg.withnum + 1;
	if wih >= 10 then wih = 10 end;
	local timecfg = t_buytime[wih]
	if not timecfg then return 0 end;
	if id == enAttrType.eaExp then 
		return timecfg.exp
	elseif id == enAttrType.eaZhenQi then 
		return timecfg.lingli
	elseif id == enAttrType.eaBindGold then
		return timecfg.gold
	end;
end;