------------------------------------------------------------
-- 龙珠套装属性视图
------------------------------------------------------------

DragonBallSuitAttrView = DragonBallSuitAttrView or BaseClass(BaseView)

function DragonBallSuitAttrView:__init()
	-- self.texture_path_list[1] = 'res/xui/shangcheng.png'
	self:SetIsAnyClickClose(true)

end

function DragonBallSuitAttrView:__delete()
end

function DragonBallSuitAttrView:ReleaseCallBack()

	-- if self.shop_mystical_grid then
	-- 	self.shop_mystical_grid:DeleteMe()
	-- 	self.shop_mystical_grid = nil
	-- end

end

function DragonBallSuitAttrView:LoadCallBack(index, loaded_times)
	self.layout = XUI.CreateLayout(0, 0, 0, 0)
	self:GetRootNode():addChild(self.layout, 0)

	self.bg = XUI.CreateImageViewScale9(0, 0, 462, 0, ResPath.GetBigPainting("tip_bg_3"), false, cc.rect(90, 310, 150, 2))
	self.layout:addChild(self.bg, 0)
	self.bg:setAnchorPoint(0.5, 0.5)
	self.bg:setPosition(0, 0)

	self.line_1 = XUI.CreateImageView(0, 135, ResPath.GetCommon("line_05"), true)
	self.layout:addChild(self.line_1, 15)

	self.line_2 = XUI.CreateImageView(0, -20, ResPath.GetCommon("line_05"), true)
	self.layout:addChild(self.line_2, 15)

	local text = Language.DragonBall.SuitAttr
	self.bar = XUI.CreateText(0, 165, 462, 36, cc.TEXT_ALIGNMENT_CENTER, text, nil, 23, COLOR3B.GOLD)
	self.layout:addChild(self.bar, 20)

	self.star_1 = XUI.CreateText(0, 110, 400, 36, cc.TEXT_ALIGNMENT_LEFT, "", nil, 23, COLOR3B.GOLD)
	self.layout:addChild(self.star_1, 20)

	self.star_2 = XUI.CreateText(0, -45, 400, 36, cc.TEXT_ALIGNMENT_LEFT, "", nil, 23, COLOR3B.GOLD)
	self.layout:addChild(self.star_2, 20)

	self.attr_1 = XUI.CreateRichText(-160, 90, 1, 1, true)
	self.attr_1:setAnchorPoint(0, 1)
	self.layout:addChild(self.attr_1, 20)

	self.attr_2 = XUI.CreateRichText(-160, -65, 1, 1, true)
	self.attr_2:setAnchorPoint(0, 1)
	self.layout:addChild(self.attr_2, 20)

end

--显示索引回调
function DragonBallSuitAttrView:ShowIndexCallBack(index)
	self.bg:setContentWH(462, 400)
	self:FlushAttr()
end

----------视图函数----------

-- 刷新加成属性视图
function DragonBallSuitAttrView:FlushAttr()
	local suit_info, suit_next_info = TreasureAtticData.Instance.GetSuitInfo()

	local attr
	attr = suit_info.attr
	local text1 = RoleData.Instance.FormatAttrContent(attr)
	attr = suit_next_info.attr
	local text2 = attr and RoleData.Instance.FormatAttrContent(attr) or ""
	RichTextUtil.ParseRichText(self.attr_1, text1, 18, COLOR3B.G_W)
	RichTextUtil.ParseRichText(self.attr_2, text2, 18, COLOR3B.G_W)
	XUI.SetRichTextVerticalSpace(self.attr_1, 5)
	XUI.SetRichTextVerticalSpace(self.attr_2, 5)

	local text1 = string.format(Language.DragonBall.CurrentSuit, suit_info.phase, suit_info.level)
	local text2 = next(suit_next_info) and string.format(Language.DragonBall.NextSuit, suit_next_info.phase, suit_next_info.level) or Language.DragonBall.MaxLevel
	self.star_1:setString(text1)
	self.star_2:setString(text2)
end

----------end----------

--------------------