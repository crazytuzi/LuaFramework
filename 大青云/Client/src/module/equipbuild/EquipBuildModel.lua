--[[
装备打造
wangshuai
]]

_G.EquipBuildModel = Module:new();

EquipBuildModel.buildList = {};
EquipBuildModel.OpenBuildList = {};
EquipBuildModel.Rewardlist = {};

function EquipBuildModel:SetInitInfo(list)
	self.buildList = list;
end;

function EquipBuildModel:GetInitInfo()
	return self.buildList;
end;

function EquipBuildModel:GetInitInfoLenght()
	local num = 0;
	for i,info in pairs(self.buildList) do 
		num = num + 1;
	end;
	return num;
end;

function EquipBuildModel:SetBuildInfo(id,state)
	local vo = {};
	local cit = t_equipcreate[id];
	if not cit then return end;
	vo.id = cit.cid;
	vo.state = true;
	self.OpenBuildList[cit.cid] = vo;
end;

-- 得到当前卷轴是否开启
function EquipBuildModel:GetScrollIsOpen(id)
	if self.OpenBuildList[id] then 
		return true
	end;
	return false;
end;

-- 得到制定品阶下的卷轴
function EquipBuildModel:GetScrollList(id)
	if not self.buildList[id] then return end;
	return self.buildList[id];
end


-- 得到id cfg
function EquipBuildModel:GetBuildCfg(id)
	for i,info in ipairs(t_equipcreate) do 
		if  info.cid == id then 
			return info;
		end;
	end;
end;
EquipBuildModel.ResultDataList = {};
-- 设置奖励数据
function EquipBuildModel:SetResultData(list,cid,attrAddLvl,superNum,superList)
	self.ResultDataList = {};
	for i,info in ipairs(list) do
		local vo = {}
		vo.cid = info.cid;
		vo.extraLvl = info.attrAddLvl;
		vo.superNum = info.superNum;
		vo.groupId = info.groupId;
		vo.groupId2 = info.groupId2;
		vo.groupId2Level = info.group2Level;
		vo.superList = info.superList;
		vo.newSuperList = info.newSuperList;
		vo.bind = info.bind;
		table.push(self.ResultDataList,vo)
	end;
	if UIEquipBuild:IsShow() then 
		if #self.ResultDataList == 1 then 
			if not UIEquipBuildResultTwo:IsShow() then 
				UIEquipBuildResultTwo:SetData();
			end;
			return 
		end;
		if not UIEquipBuildResult:IsShow() then 
			UIEquipBuildResult:SetData();
		end;
	end;
end;

-----------------------  装备分解
function EquipBuildModel:SetDecompRewardList(list)
	self.Rewardlist = list;
	
end;
