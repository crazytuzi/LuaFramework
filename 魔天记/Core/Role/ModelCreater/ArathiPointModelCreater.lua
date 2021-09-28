require "Core.Role.ModelCreater.BaseModelCreater"
ArathiPointModelCreater = class("ArathiPointModelCreater", BaseModelCreater);

function ArathiPointModelCreater:New(data, parent)
	self = {};
	setmetatable(self, {__index = ArathiPointModelCreater});	
	self.asyncLoadSource = true
	self:Init(data, parent);
	return self;
end

function ArathiPointModelCreater:_Init(data)
	--PrintTable(data);
	self._infoData = data
	if(data.type == 3) then
		self.model_id = data.modle
	elseif(data.type and data.buff > 0) then
		if data.modle == "" then
			self.model_id = "" .. data.buff;
		else
			self.model_id = data.modle;
		end
	end
end

function ArathiPointModelCreater:_GetModern()
	local camp = self._infoData.camp
	if(camp == 0 or camp == nil) then
		return "Effect/ScenceEffect", self.model_id;
	elseif(camp == 1) then
		return "Effect/ScenceEffect", self.model_id .. "_r";
	elseif(camp == 2) then
		return "Effect/ScenceEffect", self.model_id .. "_b";
	end
end

function ArathiPointModelCreater:GetCheckAnimation()
	return false
end