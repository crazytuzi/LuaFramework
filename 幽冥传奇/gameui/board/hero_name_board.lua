
HeroNameBoard = HeroNameBoard or BaseClass(NameBoard)

function HeroNameBoard:__init()
	self.hero_name_text_rich = XUI.CreateRichText(0, 18, 200, 24)
	XUI.RichTextSetCenter(self.hero_name_text_rich)
	self.root_node:addChild(self.hero_name_text_rich, -1)

	self.office_name_img = XUI.CreateImageView(-20,36, "")
	self.root_node:addChild(self.office_name_img, 2)

	self.precent_img = XUI.CreateImageView(58,36, "")
	self.precent_img:loadTexture(ResPath.GetScene("precent_img"))
	self.root_node:addChild(self.precent_img, 2)

	self.discount_num = NumberBar.New()
	self.discount_num:SetRootPath(ResPath.GetScene("mb_num_"))
	self.discount_num:SetPosition(30, 24)
	self.discount_num:SetGravity(NumberBarGravity.Left)
	self.root_node:addChild(self.discount_num:GetView(), 2)
end

function HeroNameBoard:__delete()
	if self.discount_num then
		self.discount_num:DeleteMe()
	end
	self.discount_num = nil
end

function HeroNameBoard:SetHero(vo)
	self:SetName(string.format(Language.Zhanjiang.HeroSceneName, RoleData.SubRoleName(vo.owner_name), vo.name), Str2C3b("00c0ff"))
	-- self:SetHeroName(vo.name, Str2C3b(string.format("%06x", vo.name_color)))

	self.office_name_img:setVisible(vo.mabi_race > 0)
	self.discount_num:GetView():setVisible(vo.mabi_race > 0)
	self.precent_img:setVisible(vo.mabi_race > 0)
	
	self.office_name_img:loadTexture(ResPath.GetScene("zhangchong_mabi_tip"))
	self.discount_num:SetNumber(vo.mabi_race / 100)
	self.precent_img:setPositionX(vo.mabi_race / 100 >= 10 and 72 or 58)
	if vo.mabi_race / 100 >= 100 then self.precent_img:setPositionX(82) end
end

function HeroNameBoard:SetHeroName(name, color)
	self.hero_name_text_rich:removeAllElements()
	XUI.RichTextAddText(self.hero_name_text_rich, name, COMMON_CONSTS.FONT, 18, color, 255, nil, 1)
end
