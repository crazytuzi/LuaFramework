
--
-- <img/> 标签解析
--

return function (self, params, default)
	if not params.src then return 
	end
	if (string.find(params.src, "R") ~= nil or string.find(params.src, "H") ~= nil or string.find(params.src, "E") ~= nil) and string.sub(params.src,-4) ~= ".png" then
		local size = ChatController:getInstance():getFaceSpineSize(params.src)
		params.width = params.width or size[1]
		params.height = params.height or size[2]

		local spine = createSpineByName(params.src)
		spine:setAnimation(0, PlayerAction.action, true)
		local node = ccui.Layout:create()
		node:setAnchorPoint(cc.p(0, 0))
		node:setContentSize({width=params.width, height=params.height})
		spine:setPosition(cc.p(params.width/2,params.height/2))
		spine:setAnchorPoint(cc.p(0.5,0.5))
		node:addChild(spine)
		params.nodes = {node}
        return node
	end

	if (string.find(params.src,"face")~=nil) then
		local size = ChatController:getInstance():getFaceSpineSize(params.src)
		params.width = params.width or size[1]
		params.height = params.height or size[2]

		local node = ccui.Layout:create()
		node:setAnchorPoint(cc.p(0, 0))
		node:setContentSize({width=params.width, height=params.height})

		params.width = params.width or size[1]
		params.height = params.height or size[2]
		local res = PathTool.getFaceIconRes(params.src)
		local sprite = createSprite(res,0,0,node,cc.p(0,0),LOADTEXT_TYPE,1)
		params.nodes = {node}
		return node
	end

	-- 创建精灵，自动在帧缓存中查找，屏蔽了图集中加载和直接加载的区别
	--params.src = PathTool.checkRes(params.src) -- 如果找不到，给默认图标
	local sprite = self:getSprite(params.src)
	if not sprite then
		self:printf("<img> - create sprite failde")
		return
	end
	if params.scale then
		sprite:setScale(params.scale)
	end
	if params.rotate then
		sprite:setRotation(params.rotate)
	end
	if params.visible ~= nil then
		sprite:setVisible(params.visible)
	end

	local sprite2 = self:getSprite(params.src)
	if not sprite2 then
		self:printf("<img> - create sprite failde")
		return
	end
	if params.scale then
		sprite2:setScale(params.scale)
		local size = sprite2:getContentSize()
		sprite2:setContentSize(cc.size(size.width*params.scale, size.height*params.scale))
	end
	if params.rotate then
		sprite2:setRotation(params.rotate)
	end
	if params.visible ~= nil then
		sprite2:setVisible(params.visible)
	end
	local element = ccui.RichElementCustomNode:create( autoId(), cc.c3b(255, 255, 255), 255, sprite2 )
	sprite.richtext = element
	sprite.content2 = "图片"..params.src
	sprite.target = sprite2
	params.nodes = {sprite}
end
