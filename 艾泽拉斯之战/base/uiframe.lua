uiframe = class("uiframe");

function uiframe:ctor(position, size, alpha, timestamp, textScale)

	self.postion = LORD.UVector2(LORD.UDim(position.x.scale, position.x.offset), LORD.UDim(position.y.scale, position.y.offset));
	self.size = LORD.UVector2(LORD.UDim(size.x.scale, size.x.offset), LORD.UDim(size.y.scale, size.y.offset));
	self.alpha = alpha;
	self.timestamp = timestamp;
	self.textScale = textScale or 1;
	
end

function uiframe:getPosition()
	return self.postion;
end

function uiframe:getSize()
	return self.size;
end

function uiframe:getAlpha()
	return self.alpha;
end

function uiframe:getTimeStamp()
	return self.timestamp;
end

function uiframe:getTextScale()
	return self.textScale;
end
