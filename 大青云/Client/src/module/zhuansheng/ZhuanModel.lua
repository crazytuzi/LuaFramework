--[[
转生
wangshuai
]]

_G.ZhuanModel = Module:new();

ZhuanModel.zhuanshType = 0;--0为无转生，1=一转，=2转，3转，
ZhuanModel.isZhuanActIng = false; -- true活动中
ZhuanModel.zhuanshinfo = {}; --转生信息

ZhuanModel.proXylist = { --暂只读y
	[1] = {
		["x"] = 76;
		['y'] = 212;
	},
	[2] = {
		["x"] = 76;
		['y'] = 285;
	},
	[3] = {
		["x"] = 76;
		['y'] = 285;
	},
}

function ZhuanModel:SetZhuansType(type)
	self.zhuanshType = type;
end;

function ZhuanModel:GetZhuanType()
	-- return self.zhuanshType;
	return MainPlayerModel.humanDetailInfo.eaZhuansheng or 1
end;

function ZhuanModel:SetZhuanActState(type)
	self.isZhuanActIng = type;
end;

function ZhuanModel:GetZhuanActState()
	return self.isZhuanActIng;
end;

function ZhuanModel:SetZhuanInfo(mlist,copyId)
	local list = {};
	for i,info in ipairs(mlist) do 
		local vo = {};
		vo.id = info.id;
		vo.num = info.num;
		table.push(list,vo)
	end;
	self.zhuanshinfo.mlist = list;
	self.zhuanshinfo.copyId = copyId or 0;
end;

function ZhuanModel:GetZhuanCopyid()
	return self.zhuanshinfo.copyId;
end;

function ZhuanModel:GetMonsterNum(id)
	local list = self.zhuanshinfo.mlist
	for i,info in pairs(list) do 
		if info.id == id then 
			return info.num;
		end;
	end;
	return nil
end;
