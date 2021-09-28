local catalog = class("catalog",function() return cc.Layer:create() end)

function catalog:ctor( idx ,num )
	G_MAINSCENE:csbdOpen(3)
	local activityID = idx or 1
	local page = num or 0
	-- local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 175))
	-- self:addChild(colorbg)
	-- local floor = createSprite(self,"res/common/bg/bg55.png",cc.p(display.cx,display.cy))
	-- floor:setScaleY(0.3)
	local closeFun = function()
		-- bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0), cc.CallFunc:create(function() removeFromParent(self) end)))  
		removeFromParent(self)
	end

	local upBar = createSprite(self,"res/common/bg/bg55-6.png",cc.p(display.cx,display.cy+270),nil,3)
	createSprite(upBar,"res/common/bg/bg55-4.png",cc.p(upBar:getContentSize().width/2,upBar:getContentSize().height/2+5),nil,4)
	createSprite(upBar,"res/layers/dictionary/csbd.png",cc.p(upBar:getContentSize().width/2+8,upBar:getContentSize().height/2+4),nil,5)
	local downBar = createSprite(self,"res/common/bg/bg55-7.png",cc.p(display.cx,display.height-200),nil,3)
	-- upBar:runAction(cc.MoveTo:create(0.3,cc.p(display.cx,display.cy+270)))
	local action = cc.MoveBy:create(0.6,cc.p(0,-380))
	downBar:runAction(action)--(cc.MoveTo:create(0.45,cc.p(display.cx,display.cy-270)))
	-- floor:runAction(cc.ScaleTo:create(0.25, 1))
	createTouchItem(upBar,"res/component/button/X.png",cc.p(920,45),closeFun)

	-- local bg = createSprite(self,"res/common/bg/bg55.png",cc.p(display.cx,display.cy))
	local clipNode = cc.ClippingNode:create()
	clipNode:setPosition(cc.p(0,0))
    self:addChild(clipNode)
    local bg = createSprite(clipNode,"res/common/bg/bg55.png",cc.p(display.cx,display.cy))
    local stencil1 = cc.Sprite:create("res/common/bg/bg55.png")
    stencil1:setScaleX(1.2)
    stencil1:setAnchorPoint(cc.p( 0.5 , 1 ))
    stencil1:setPosition(cc.p(display.cx,display.height-200))
    stencil1:runAction(action:clone())--(cc.MoveTo:create(0.7,cc.p(display.cx,display.cy-500)))    
    clipNode:setStencil(stencil1)
    clipNode:setInverted(true)
    clipNode:setAlphaThreshold(0)
	

	createSprite(bg,"res/common/bg/bg55-3.png",cc.p(bg:getContentSize().width/2,bg:getContentSize().height/2))
	-- bg:setOpacity(0)
	-- createSprite(bg,"res/common/bg/bg55-1.png",cc.p(578,533),nil,50)
	-- createSprite(bg,"res/common/bg/bg55-2.png",cc.p(578,75),nil,100)		
	registerOutsideCloseFunc( bg , closeFun)
	self.lab = {}
	self.select_layers = {}

	local layers = {require("src/layers/dictionary/CQdictionary"),require("src/layers/dictionary/esoterica"),require("src/layers/dictionary/godSuit")}
	local menuFunc = function(tag)
		if self.select_index == tag then
			return
		end
		self.select_index = tag
		for k,v in pairs(self.select_layers) do
			-- v:setVisible(tag == k)
			if tag ~= k and v then
				self.lab[k]:setPosition(cc.p(21,70))
				self.lab[k]:setColor(MColor.lable_black)
				removeFromParent(v)
			else
				self.lab[tag]:setPosition(cc.p(27,70))
				self.lab[tag]:setColor(MColor.lable_yellow)
				self.select_layers[tag] = layers[tag].new(bg)
				self.select_layers[tag]:setPosition(-49,-30)
				bg:addChild(self.select_layers[tag],125)				
			end
		end
		if not self.select_layers[tag] then
			self.lab[tag]:setColor(MColor.lable_yellow)
			self.lab[tag]:setPosition(cc.p(27,70))
			self.select_layers[tag] = layers[tag].new(bg,page)
			self.select_layers[tag]:setPosition(-49,-30)
			bg:addChild(self.select_layers[tag],125)
		end		
	end

	-- local tbook = getConfigItemByKeys("bookDB", {
	-- 	"q_school",
	-- 	"q_id",
	-- })
	-- local school = MRoleStruct:getAttr(ROLE_SCHOOL)
	-- local tabNum = table.size(tbook[school])
	-- local theHighestLvInBook = tbook[school][100*(school-1)+tabNum].q_lv
	-- if  MRoleStruct:getAttr(ROLE_LEVEL) > theHighestLvInBook and activityID == 1 then
	-- 	activityID = 2
	-- end
	if MRoleStruct:getAttr(ROLE_LEVEL) >= 50 and activityID == 1 then
		activityID = 2
	end

	local tab_control = {}
	local posx,posy = 872 ,440
	local str_tab = {"title_cqd" , "dic_jjmj" ,"dic_zytz" }
	for i=1 , #str_tab do
		tab_control[i] = {}
		tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/7.png","res/component/TabControl/8.png")
		tab_control[i].menu_item:setPosition(cc.p(posx,posy))
		tab_control[i].callback = menuFunc
		self.lab[i] = createLabel(tab_control[i].menu_item , game.getStrByKey(str_tab[i]) , cc.p(21,70) , nil , 20,nil,nil,nil,MColor.lable_black,i,26)
		posy = posy - 130
	end
	creatTabControlMenu(bg , tab_control , activityID ,998)
	self.select_index = 0
	menuFunc( activityID )
	-- bg:setVisible(false)
	SwallowTouches(self)
	-- bg:runAction(cc.FadeIn:create( 0.5 ))


end

return catalog