local FriendNoticeNode = class("FriendNoticeNode", function() return cc.Node:create() end)

function FriendNoticeNode:ctor(tab)
	self.data = tab
	if tab then
		local num = #tab
		local iconSpr = createMenuItem(self, "res/mainui/friendNotice.png", cc.p(0, 0), function() self:MessageBox(self.data[1]) end)
		performWithNoticeAction(iconSpr)
		local redSpr = createSprite(iconSpr,"res/component/flag/red.png",cc.p(65,50))
	    self.numLabel = createLabel(redSpr, num.."", getCenterPos(redSpr, -2, 3), nil, 18, true, nil, nil, MColor.white)


		--iconSpr:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.15, 1.1), cc.ScaleTo:create(0.15, 0.9) )))
		--[[
		local effect = Effects:create(false)
	    effect:playActionData("newFunctionNotice", 11, 1.5, -1)
	    iconSpr:addChild(effect, -1)
	    effect:setAnchorPoint(cc.p(0.5, 0.5))
	    effect:setPosition(cc.p(iconSpr:getContentSize().width/2, iconSpr:getContentSize().height/2))
		]]
	    --self.numLabel = createLabel(iconSpr, "+" .. num.."", cc.p(iconSpr:getContentSize().width-7, -3), cc.p(0, 0), 26, true, nil, nil, MColor.yellow)
	end

	self.data = G_FIREND_DATA
	--dump(self.data)
	-- if tab then
	-- 	for i,v in ipairs(tab) do
	-- 		self:addRecord(v)
	-- 	end
	-- end
	-- dump(self.data)
end

function FriendNoticeNode:addRecord(record)
	table.insert(self.data, #self.data+1, record)
	self:updateNumLabel()
end

function FriendNoticeNode:deleteRecord(isAll)
	--log("FriendNoticeNode:deleteRecord = "..tostring(isAll))
	if isAll == true then
		self.data = {}
		G_FIREND_DATA = {}
	else
		table.remove(self.data, 1)
	end
	self:updateNumLabel()
	--dump(#self.data)
end

function FriendNoticeNode:updateNumLabel()
	if self.numLabel then
		self.numLabel:setString(tablenums(self.data))
	end
end

-- function FriendNoticeNode:MessageBox(record)
-- 	local content = string.format(game.getStrByKey("friend_notice"), record.name)

-- 	local funcYes = function()
-- 		AddFriends(self.data[1].name)
-- 	   	self:deleteRecord()
-- 	end

-- 	local funcNo = function()
-- 	   	self:deleteRecord()
-- 	end
-- 	MessageBoxYesNo(nil,content,funcYes,funcNo, game.getStrByKey("firend_notice_yes"),game.getStrByKey("firend_notice_no"))
-- end

function FriendNoticeNode:MessageBox(record)
	local retSprite = cc.Sprite:create("res/common/5.png")

	local function getAddNum()
		if self.data then
			return #self.data
		else
			return 0
		end
	end

	local closeFunc = function()
		--log("close func")
		if retSprite then
	        removeFromParent(retSprite)
	        retSprite = nil
	    end

	    self:deleteRecord(true)
		G_MAINSCENE.friendNoticeNode = nil
		removeFromParent(self)
	end

	local r_size  = retSprite:getContentSize()
	createLabel(retSprite,  game.getStrByKey("tip"), cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)

	createMenuItem(retSprite, "res/component/button/X.png", cc.p(r_size.width-25, r_size.height-25), function() closeFunc() end)

	local contentRichText = require("src/RichText").new(retSprite,  cc.p(r_size.width/2, r_size.height/2 + 30), cc.size(r_size.width-58, 100), cc.p(0.5, 0.5), 25, 20, MColor.white)
	
	if getAddNum() > 1 then
		contentRichText:addText(string.format(game.getStrByKey("friend_notice_all"), record.name), MColor.white)
	else
		contentRichText:addText(string.format(game.getStrByKey("friend_notice"), record.name), MColor.white)
	end
	contentRichText:setAutoWidth()
	contentRichText:format()

	local funcYes = function()
		if getAddNum() > 1 then
			-- dump(self.data)
			-- for i,v in ipairs(self.data) do
			-- 	dump(self.data[i].name)
				AddFriends(nil, self.data)
			-- end
			self:deleteRecord(true)
		else
			if self.data and self.data[1] then
				AddFriends(self.data[1].name)
			   	self:deleteRecord()
			end
		end
		closeFunc()
	end

	local menuItem = createMenuItem(retSprite, "res/component/button/50.png", cc.p(210, 45), funcYes)
	if getAddNum() > 1 then
		createLabel(menuItem, game.getStrByKey("firend_notice_yes_all") , getCenterPos(menuItem), nil, 22, true)
	else
		createLabel(menuItem, game.getStrByKey("firend_notice_yes") , getCenterPos(menuItem), nil, 22, true)
	end
	getRunScene():addChild(retSprite,400)
	retSprite:setPosition(cc.p(display.cx, display.cy))
	retSprite:setScale(0.01)
    retSprite:runAction(cc.ScaleTo:create(0.1, 1))
	registerOutsideCloseFunc(retSprite , closeFunc)

	return retSprite
end

return FriendNoticeNode