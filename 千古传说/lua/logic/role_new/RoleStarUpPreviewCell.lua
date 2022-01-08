
local RoleStarUpPreviewCell = class("RoleStarUpPreviewCell", BaseLayer)

function RoleStarUpPreviewCell:ctor(data)

	self.super.ctor(self, data)
	self:init("lua.uiconfig_mango_new.role_new.RoleStarUpPreviewCell")

end

function RoleStarUpPreviewCell:initUI( ui )

	self.super.initUI(self, ui)

	self.panel_on = TFDirector:getChildByPath(ui, "panel_liang_yuanfen")
	self.txt_context_on = TFDirector:getChildByPath(self.panel_on, "txt_yuanfen_word")
	self.txt_name_on = TFDirector:getChildByPath(self.panel_on, "txt_name")
	self.star_on = {}
	for i=1,5 do
		self.star_on[i] = TFDirector:getChildByPath(self.panel_on, "img_star_light_"..i)
	end

	self.panel_off = TFDirector:getChildByPath(ui, "panel_hui_yuanfen")
	self.txt_context_off = TFDirector:getChildByPath(self.panel_off, "txt_yuanfen_word")
	self.txt_name_off = TFDirector:getChildByPath(self.panel_off, "txt_name")
	self.Condition = TFDirector:getChildByPath(self.panel_off, "txt_condition")
	self.star_off = {}
	for i=1,5 do
		self.star_off[i] = TFDirector:getChildByPath(self.panel_off, "img_star_light_"..i)
	end

end

function RoleStarUpPreviewCell:removeUI()
	
	self.super.removeUI(self)

end

function RoleStarUpPreviewCell:dispose()

end

function RoleStarUpPreviewCell:registerEvents()
	self.super.registerEvents(self)
end

function RoleStarUpPreviewCell:removeEvents()

    self.super.removeEvents(self)
end

function RoleStarUpPreviewCell:setData(cardRole,item)

	local curr_star = cardRole.starlevel
	local starIdx = 1
	for i=1,5 do
		self.star_on[i]:setVisible(false)
		self.star_off[i]:setVisible(false)
	end
	for i=1,item.star_lv do
		starIdx = i
		local starTextrue = 'ui_new/common/xl_dadian22_icon.png'
		if i > 5 then
			starTextrue = 'ui_new/common/xl_dadian23_icon.png'
			starIdx = i - 5
		end
		self.star_on[starIdx]:setTexture(starTextrue)
		self.star_off[starIdx]:setTexture(starTextrue)
		self.star_on[starIdx]:setVisible(true)
		self.star_off[starIdx]:setVisible(true)		
	end

	if curr_star >= item.star_lv then
		--激活
		self.panel_on:setVisible(true)
		self.panel_off:setVisible(false)
		self.txt_context_on:setText(item.desc)
		self.txt_name_on:setText(item.name)
	else
		--local textBuff = {'一星激活','二星激活','三星激活','四星激活','五星激活','六星激活','七星激活','八星激活'}
		self.panel_on:setVisible(false)
		self.panel_off:setVisible(true)
		--self.Condition:setText(EnumWuxueLevelType[item.star_lv]..'星激活')
		self.Condition:setText(stringUtils.format(localizable.roleQualityUp_jihuo, EnumWuxueLevelType[item.star_lv]))
		self.txt_context_off:setText(item.desc)
		self.txt_name_off:setText(item.name)
	end
end

return RoleStarUpPreviewCell