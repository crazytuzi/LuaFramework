local data_jingyingfuben_jingyingfuben = require("data.data_jingyingfuben_jingyingfuben")

local JingYingCell = class("JingYingCell", function()
	return CCTableViewCell:new()
end)

function JingYingCell:getContentSize()
	return cc.size(display.width, 200)
end

function JingYingCell:getIsAllowPlay()
	return self.isAllowPlay
end

function JingYingCell:getTutoBtn()
	return self.item
end

function JingYingCell:refresh(id, isAllLvlDone)
	local index = id
	dump("index" .. index .. " total num  " .. self.totalNum .. "  id  " .. id)
	local name = data_jingyingfuben_jingyingfuben[index].icon
	local imagePath = "ui/ui_jingying_fb/" .. name .. ".png"
	local imageCoverName = "ui/ui_huodong/ui_huodong_cover.png"
	local imageCoverNameGray = "ui/ui_huodong/ui_huodong_cover_gray.png"
	local passed = false
	if index == self.totalNum then
		passed = false
	else
		passed = true
	end
	if isAllLvlDone then
		passed = true
	end
	self.isAllowPlay = true
	if passed then
		item = display.newSprite(imagePath)
		itemCover = display.newScale9Sprite(imageCoverName, 0, 0, cc.size(item:getContentSize().width + 20, item:getContentSize().height + 20))
	else
		item = display.newGraySprite(imagePath, {
		0.4,
		0.4,
		0.4,
		0.1
		})
		itemCover = display.newScale9Sprite(imageCoverNameGray, 0, 0, cc.size(item:getContentSize().width + 20, item:getContentSize().height + 20))
		self.isAllowPlay = false
	end
	item:setPosition(self._rootnode.bg_node:getContentSize().width / 2, self._rootnode.bg_node:getContentSize().height / 2)
	itemCover:setPosition(self._rootnode.bg_node:getContentSize().width / 2, self._rootnode.bg_node:getContentSize().height / 2)
	self._rootnode.bg_node:removeAllChildren()
	self._rootnode.bg_node:addChild(item)
	self.item = item
	self._rootnode.bg_node:addChild(itemCover)
end

function JingYingCell:create(param)
	self.totalNum = param.totalNum
	local _id = param.idx
	local isAllLvlDone = param.isAllLvlDone
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("challenge/jingying_item.ccbi", proxy, self._rootnode)
	self:addChild(node)
	local passed = false
	if _id == 1 then
		passed = true
		self.isAllowPlay = true
	end
	self:refresh(_id + 1, isAllLvlDone)
	return self
end

function JingYingCell:beTouched()
end

function JingYingCell:runEnterAnim()
end

return JingYingCell