local NewFunctionNode = class("NewFunctionNode", function() return cc.Node:create() end)

require("src/layers/newFunction/NewFunctionDefine")

function NewFunctionNode:ctor(record)
	local resPath = "res/newFunction/"
	local key = "newFunction"
	self.id = record.q_ID

	local school = require("src/layers/role/RoleStruct"):getAttr(ROLE_SCHOOL)

	local showTip = function()
		if self.tipBg ~= nil then
			removeFromParent(self.tipBg)
			self.tipBg = nil
		end

		if self.effect then
			removeFromParent(self.effect)
			self.effect = nil
			setLocalRecord(key..self.id, true)
		end

		local tipBg = createSprite(nil, resPath.."3.png", cc.p(display.width/2, display.height/2), cc.p(0.5, 0.5))
		local label = createLabel(tipBg, record.q_content, cc.p(tipBg:getContentSize().width/2, tipBg:getContentSize().height/2), cc.p(0.5, 0.5), 30, true, izorder, fontName, MColor.white)
		self.tipBg = tipBg
		Director:getRunningScene():addChild(tipBg, 150)
		tipBg:setPosition(cc.p(display.cx, display.cy))
		tipBg:setOpacity(0)
		label:setOpacity(0)
		local action1 = cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(3), cc.FadeOut:create(0.3), cc.CallFunc:create(function()  removeFromParent(self.tipBg) self.tipBg=nil end))
		local action2 = cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(3), cc.FadeOut:create(0.3))
		tipBg:runAction(action1)
		label:runAction(action2)

		--G_NFTRIGGER_NODE:trigger(G_NFTRIGGER_NODE.triggerData[5])
	end
	
	if getLocalRecord(key..self.id) ~= true then
		--提示特效
		-- local effect = Effects:create(false)
	 --    effect:playActionData("newFunctionNotice", 11, 1.5, -1)
	 --    self:addChild(effect)
	 --    effect:setAnchorPoint(cc.p(0.5, 0.5))
	 --    effect:setPosition(0, 0)
	 --    self.effect = effect
	end

    --图标
	local icon = createMenuItem(self, iconOffPath..iconTab[record.q_ID], cc.p(0, 0), showTip)

	--名称
	local title = createSprite(icon, titleOffPath..iconTab[record.q_ID], cc.p(icon:getContentSize().width/2, 0), cc.p(0.5, 0.5), nil)

	--即将开放
	createSprite(title, resPath.."1.png", cc.p(title:getContentSize().width/2, 10), cc.p(0.5, 1))

    --锁按钮
	local lockBtn = createSprite(icon, resPath.."2.png", cc.p(icon:getContentSize().width/2, icon:getContentSize().height), cc.p(0.5, 1), nil, 0.7)
end

return NewFunctionNode