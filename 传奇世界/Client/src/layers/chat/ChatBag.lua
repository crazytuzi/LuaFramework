local ChatBag = class("ChatBag", function() return  cc.Layer:create() end)
local MPackStruct = require "src/layers/bag/PackStruct"
local MPackManager = require "src/layers/bag/PackManager"
local MPackView = require "src/layers/bag/PackView"
local MpropOp = require "src/config/propOp"

function ChatBag:ctor(parent, callback)	
	parent:addChild(self,1,101)
	local chatLayer = parent:getParent()
	local bagLayer = MPackView.new(
	{
		packId = MPackStruct.eBag,
		layout = { row = 3.5, col = 6, },
		marginLR = 5,
	})

	local generateString = function(isSpecial, protoId, posIndex, name, qualityId)
		--local str = chatLayer.chatEditCtrl:getText()
		
		local str="^l("..qualityId.."~"..name.."~"..tostring(isSpecial).."~"..tostring(protoId).."~"..tostring(posIndex).."~"..tostring(userInfo.currRoleStaticId).."~"..os.time().."~1"..")^"
		--str = str..addStr
		-- chatLayer.chatEditCtrl:setText(str)
		-- chatLayer.linkNum = chatLayer.linkNum or 0
		-- chatLayer.linkData = chatLayer.linkData or {}
		-- chatLayer.linkNum = chatLayer.linkNum+1
		-- chatLayer.linkData[#chatLayer.linkData+1] = {isSpecial,protoId,posIndex}
		dump(str)
		if not callback then
			chatLayer:sendLinkData(str)
		else
			callback(str)
		end
		performWithDelay(self,function() removeFromParent(self) end ,0.1)
	end

	bagLayer.onCellTouched = function(gv, cell, gird)

		local protoId = MPackStruct.protoIdFromGird(gird)
		local globalGirdId = MPackStruct.girdIdFromGird(gird)
		
		local isSpecial = MPackStruct.isSpecialFromGird(gird)
		local name = MpropOp.name(protoId)
		local qualityId = MpropOp.quality(protoId)--,qualitylvl)
		generateString(isSpecial, protoId, globalGirdId, name, qualityId)
	end
	bagLayer:refresh()

	local root = bagLayer:getRootNode()
	local size = root:getContentSize()

	local bg = createScale9Sprite(self,"res/common/68.png",cc.p(610,g_scrSize.height/2-( parent.isSocial and 70 or 40 )),cc.size(size.width+8,size.height+8))
	bg:addChild(root)
	root:setAnchorPoint(cc.p(0.5,0.5))
	root:setPosition(cc.p(size.width/2+4,size.height/2+2))
	--createSprite(bg,"res/chat/bag_title.png",cc.p(size.width/2+4, size.height+13))
	-- createLabel(bg, game.getStrByKey("chat_bag"), cc.p(size.width/2+4, size.height+10), nil, 28,true)

	local closeFunc = function()   
		removeFromParent(self)
	end
	-- createTouchItem(bg,"res/common/13.png",cc.p(size.width-20, size.height),closeFunc)
	registerOutsideCloseFunc(bg , closeFunc)
end

return ChatBag