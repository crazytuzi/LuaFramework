acAutumnCarnivalVo=activityVo:new()

function acAutumnCarnivalVo:updateSpecialData(data)

	if data.br then
		self.br = data.br
	end
	if data.ls~=nil then
		self.gifts = data.ls
	end
end