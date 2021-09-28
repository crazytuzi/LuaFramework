local FactionInviteNoticeNode = class("FactionInviteNoticeNode", function() return cc.Node:create() end)

function FactionInviteNoticeNode:ctor(tab)
	self.data = tab
	if tab then
		local num = #tab
		local iconSpr = createMenuItem(self, "res/mainui/factionNotice.png", cc.p(0, 0), function() self:MessageBox(self.data[1]) end)
		performWithNoticeAction(iconSpr)
		local redSpr = createSprite(iconSpr,"res/component/flag/red.png",cc.p(65,50))
	    self.numLabel = createLabel(redSpr, num.."", getCenterPos(redSpr, -2, 3), nil, 18, true, nil, nil, MColor.white)
	end

	self.data = G_FACTION_INVITE_DATA
end

function FactionInviteNoticeNode:addRecord(record)
	table.insert(self.data, #self.data+1, record)
	self:updateNumLabel()
end

function FactionInviteNoticeNode:deleteRecord(isAll)
	if isAll == true then
		self.data = {}
		G_FACTION_INVITE_DATA = {}
	else
		table.remove(self.data, 1)
	end
	self:updateNumLabel()
end

function FactionInviteNoticeNode:updateNumLabel()
	if self.numLabel then
		self.numLabel:setString(tablenums(self.data))
	end
end

function FactionInviteNoticeNode:MessageBox(record)
	local retSprite = cc.Sprite:create("res/common/5.png")

	local function getAddNum()
		if self.data then
			return #self.data
		else
			return 0
		end
	end

	local closeFunc = function()
		if retSprite then
	        removeFromParent(retSprite)
	        retSprite = nil
	    end

	    self:deleteRecord(true)

        --剩余的全部拒绝

		G_MAINSCENE.factionInviteNoticeNode = nil
		removeFromParent(self)
	end

	local r_size  = retSprite:getContentSize()
	createLabel(retSprite,  game.getStrByKey("tip"), cc.p(r_size.width/2, r_size.height -12), cc.p(0.5,1.0), 22, true)

	createMenuItem(retSprite, "res/component/button/X.png", cc.p(r_size.width-25, r_size.height-25), function() closeFunc() end)

	local contentRichText = require("src/RichText").new(retSprite,  cc.p(r_size.width/2, r_size.height/2 + 30), cc.size(r_size.width-58, 100), cc.p(0.5, 0.5), 25, 20, MColor.white)
	contentRichText:addText(string.format(game.getStrByKey("faction_invite_notice"), record.senderName, record.factionName), MColor.white)
	contentRichText:setAutoWidth()
	contentRichText:format()

	local funcYes = function()
	--[[	if getAddNum() > 1 then
			-- dump(self.data)
			-- for i,v in ipairs(self.data) do
			-- 	dump(self.data[i].name)
				AddFriends(nil, self.data)
			-- end
			self:deleteRecord(true)
		else
			AddFriends(self.data[1].name)
		   	self:deleteRecord()
		end
    ]]
        --发送同意协议
        g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_INVITE_JOIN_CHOOSE, "FactionInviteJoinChoose", {choose=1,inviteRoleSID=record.senderID,factionID=record.factionID})
        self:deleteRecord()
		closeFunc()
	end

	local menuItem = createMenuItem(retSprite, "res/component/button/50.png", cc.p(293, 45), funcYes)
	createLabel(menuItem, game.getStrByKey("factionYST_ok") , getCenterPos(menuItem), nil, 22, true)

    local funcNo = function()
        --发送拒绝协议
		g_msgHandlerInst:sendNetDataByTableExEx(FACTION_CS_INVITE_JOIN_CHOOSE, "FactionInviteJoinChoose", {choose=0,inviteRoleSID=record.senderID,factionID=record.factionID})

        self:deleteRecord()

        if getAddNum() > 0 then
            if retSprite then
                removeFromParent(retSprite)
                retSprite = nil
            end
        else
            closeFunc()
        end       
	end

	local menuItem2 = createMenuItem(retSprite, "res/component/button/50.png", cc.p(120, 45), funcNo)
	createLabel(menuItem2, game.getStrByKey("factionYST_no") , getCenterPos(menuItem2), nil, 22, true)


	getRunScene():addChild(retSprite,400)
	retSprite:setPosition(cc.p(display.cx, display.cy))
	retSprite:setScale(0.01)
    retSprite:runAction(cc.ScaleTo:create(0.1, 1))
	registerOutsideCloseFunc(retSprite , closeFunc)

	return retSprite
end

return FactionInviteNoticeNode