Collect =BaseClass(Thing)

function Collect:__init(vo)
	if vo ~= nil then
		self.type = PuppetVo.Type.Collect
		self:SetVo(vo)
		self:InitEvent()
	end
end

function Collect:SetVo(vo)
	if vo then
		Thing.SetVo(self, vo)		
	end
end

function Collect:InitEvent()

end

function Collect:SetGameObject(gameObject)
	if not gameObject then return end
	Thing.SetGameObject(self, gameObject)
end

