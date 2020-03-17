_G.MovController = setmetatable({},{__index=IController})
MovController.name = "MovController";

MovController.movie = nil;

function MovController:Update(e)
	if self.movie then
		self.movie:draw(e);
	end
end






