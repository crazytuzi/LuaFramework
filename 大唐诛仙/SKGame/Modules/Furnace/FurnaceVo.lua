FurnaceVo = BaseClass()
function FurnaceVo:__init( data )
	self.furnaceId = 0
	self.stage = 0
	self.star = 0
	self.piece = 0
	self:Update( data )
end
function FurnaceVo:Update( data )
	if not data then return end
	self.furnaceId = data.furnaceId or 0
	self.stage = data.stage or 0
	self.star = data.star or 0
	self.piece = data.piece or 0
end