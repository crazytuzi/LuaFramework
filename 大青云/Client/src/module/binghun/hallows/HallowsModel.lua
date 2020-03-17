--[[
	2016年1月4日11:12:58
	wangyanwei
	圣灵model
]]

_G.HallowsModel = Module:new();

--接受圣灵数据
HallowsModel.hallowsHoleList = nil;
function HallowsModel:HallowsData(hallowslist)
	if not self.hallowsHoleList then
		self.hallowsHoleList = {};
	end
	
	for i , hallowsVO in pairs(hallowslist) do
		if not self.hallowsHoleList[hallowsVO.id] then
			local vo = HallowsVO:new();
			vo.id = hallowsVO.id;
			vo.openHole = hallowsVO.holenum;
			vo.sortList = {};					--镶嵌信息
			for sortIndex , sortVO in pairs(hallowsVO.sortlist) do
				local _vo = {};
				_vo.index = sortVO.index + 1;		--镶嵌的位置
				_vo.id = sortVO.id;				--镶嵌ID
				vo.sortList[sortVO.index + 1] = _vo;
			end
			self.hallowsHoleList[hallowsVO.id] = vo;
		else
			self.hallowsHoleList[hallowsVO.id].openHole = hallowsVO.holenum;
			local sortList = {};
			for sortIndex , sortVO in pairs(hallowsVO.sortlist) do
				local _vo = {};
				_vo.index = sortVO.index + 1;		--镶嵌的位置
				_vo.id = sortVO.id;				--镶嵌ID
				sortList[sortVO.index + 1] = _vo;
			end
			self.hallowsHoleList[hallowsVO.id].sortList = sortList;
		end
	end
end

--获取圣灵数据
function HallowsModel:GetHallows(id)
	if not id then
		return self.hallowsHoleList;
	end
	if not self.hallowsHoleList then return end
	local hallowsVO = self.hallowsHoleList[id];
	if not hallowsVO then return end
	return hallowsVO;
end