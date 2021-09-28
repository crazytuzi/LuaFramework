local GodEquipLayer = class("GodEquipLayer", function() return cc.Layer:create() end)

function GodEquipLayer:ctor()
	local bg = createBgSprite(self,game.getStrByKey("title_suit"))
	self.bg = bg
	--底部提示条
	self.leftBtnData = {}--{10,11,12,13,14,15,16,17,18,19}
	
	createSprite(bg, "res/common/bg/buttonBg2.png", cc.p(12, 20), cc.p(0, 0))
	createSprite(bg, "res/common/bg/tableBg2.png", cc.p(208, 20), cc.p(0, 0))
	createSprite(bg,"res/common/bg/infoBg4.png", cc.p(215, 480), cc.p(0.0, 0.5))
	local effectbg = createSprite(bg,"res/layers/godequip/effectbg.png", cc.p(290, 470), cc.p(0.5, 0.5))
	effectbg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(0.5), cc.FadeOut:create(0.5) )))
	local sex = G_ROLE_MAIN:getSex()
	local suit_info_t = getConfigItemByKeys("suitSet", {"q_sex","q_groupID"})
	local suit_info = suit_info_t[sex]
	local MRoleStruct = require("src/layers/role/RoleStruct")
	local school = MRoleStruct:getAttr(ROLE_SCHOOL)
	self.school = school
	self.sex = G_ROLE_MAIN:getSex()
	for k,v in pairs(suit_info)do
		if math.floor(k/1000) == school then
			self.leftBtnData[#self.leftBtnData+1] = k
		end
	end
	local compare = function(a,b)
		return a<b
	end
	table.sort(self.leftBtnData,compare)
	self.leftBtn = {}
	self.discrips = {}
	for k,v in pairs(self.leftBtnData)do
		self.leftBtn[k] = suit_info[v].q_name2
		self.discrips[k] = suit_info[v].q_description
	end
	local callback = function(idx)
		if self.ListLayer then
			self.ListLayer:reloadData(self.leftBtnData[idx])
		end
		self:reloadData(idx)
	end
	require("src/LeftSelectNode").new(bg,self.leftBtn,nil,nil,callback)
	self.ListLayer = require("src/layers/godequip/GodListLayer").new(self.leftBtnData[1])
	bg:addChild(self.ListLayer)
	SwallowTouches(self)
	self:reloadData(1)
end

function GodEquipLayer:reloadData(idx)
	local MpropOp = require "src/config/propOp"
	local data = self.ListLayer.dataShow
	local w_resId = MpropOp.equipResId(data[5])
	w_resId = w_resId + 100000 * self.sex
	local s_path =  "role/" .. (w_resId )
	local w_resId = MpropOp.equipResId(data[1])
	local w_path = "weapon/" .. (w_resId )
	if self.show_node then
		removeFromParent(self.show_node)
		self.show_node = nil
	end
	self.show_node = createRoleNode(self.school,MpropOp.equipResId(data[5]),MpropOp.equipResId(data[1]),0,0.5,self.sex)
	
	if self.show_node then
		self.show_node:setPosition(cc.p(290,470))
		self.bg:addChild(self.show_node)
	end

	if self.discription then
		removeFromParent(self.discription)
		self.discription = nil
	end
	local str = self.discrips[idx] or ""
	local richText = require("src/RichText").new( self.bg , cc.p(680, 500 ) , cc.size( 460 , 130 ) , cc.p( 0.5 , 0.5 ) , 20 , 20 , MColor.lable_yellow)
	richText:addText( str ,MColor.lable_yellow , true )
	richText:format()
	self.discription = richText
end


return GodEquipLayer