uianimate = class("uianimate");

function uianimate:ctor()
	self.framelist = {};
end

function uianimate:destroy()
	self.framelist = nil;
end

function uianimate:addFrame(position, size, alpha, timestamp, textScale)
	local frame = uiframe.new(position, size, alpha, timestamp, textScale);
	
	table.insert(self.framelist, frame);
end

function uianimate:getFrame(time)
	
	local nowFrame = nil;
	local nowKey = nil;
	
	for k,v in ipairs(self.framelist) do
		
		if time <= v:getTimeStamp() then
			nowFrame = v;
			nowKey = k;
			break;
		end
		
	end
	
	if nowFrame == nil then
		return self.framelist[#self.framelist];
	end
	
	--print("time "..time.."nowkey "..nowKey);
	-- Interpolation
	local preFrame = self.framelist[nowKey-1];
	if preFrame then
		
		local percent = (time - preFrame:getTimeStamp()) / (nowFrame:getTimeStamp() - preFrame:getTimeStamp());
		local position = preFrame:getPosition() + (nowFrame:getPosition() - preFrame:getPosition()) * LORD.UVector2(LORD.UDim(percent, percent), LORD.UDim(percent, percent));
		local size = preFrame:getSize() + (nowFrame:getSize() - preFrame:getSize()) * LORD.UVector2(LORD.UDim(percent, percent), LORD.UDim(percent, percent));
		local alpha = preFrame:getAlpha() + (nowFrame:getAlpha() - preFrame:getAlpha()) * percent;
		local scale = preFrame:getTextScale() + (nowFrame:getTextScale() - preFrame:getTextScale()) * percent;
		
		local newFrame = uiframe.new(position, size, alpha, time, scale);
		
		return newFrame;
	else
		return nowFrame;
	end
	
end

