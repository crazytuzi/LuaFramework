--[[道具合成Model
zhangshuhui
2014年12月27日15:20:20
]]

_G.HeChengModel = Module:new();

--增加几率list
HeChengModel.rantitemlist = {};

function HeChengModel:GetRantItemList()
	return self.rantitemlist;
end

function HeChengModel:AddRantItem(vo)
	self.rantitemlist[vo.index] = vo;
end

function HeChengModel:GetRantItemVO(index)
	return self.rantitemlist[index];
end

function HeChengModel:ClearRantItemList()
	self.rantitemlist = {};
end

function HeChengModel:GetRantItemCount(tid)
	local count = 0;
	for i,vo in ipairs(self.rantitemlist) do
		if vo.tid == tid then
			count = count + 1;
		end
	end
	
	return count;
end