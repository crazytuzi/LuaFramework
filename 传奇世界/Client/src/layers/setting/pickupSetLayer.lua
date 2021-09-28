local pickup = class("pickupSetLayer",require("src/layers/setting/BaseLayer"))

function pickup:ctor()
	self:addScroll(cc.size(930,520),cc.size(935,520),cc.p(0,30))
	local sub_y = 50
 	local bg = self:floor("res/common/scalable/panel_outer_base.png",cc.rect(0, 0, 890,504),cc.p(480,260))
    self.base_node:addChild(bg)
   	createScale9Sprite(self.base_node, "res/common/scalable/panel_outer_frame_scale9.png", cc.p(480,260), cc.size(890, 504), cc.p(0.5, 0.5))
   	createLabel(self.base_node,game.getStrByKey("set_autopickup_drug"),cc.p(70,445+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
   	createLabel(self.base_node,game.getStrByKey("set_autopickup_equip"),cc.p(70,295+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
   	createLabel(self.base_node,game.getStrByKey("set_autopickup_other"),cc.p(70,145+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)

	createScale9Sprite(self.base_node,"res/common/scalable/setbg2.png",cc.p(480,420),cc.size(860,110))
    createScale9Sprite(self.base_node,"res/common/scalable/setbg2.png",cc.p(480,270),cc.size(860,110))
    createScale9Sprite(self.base_node,"res/common/scalable/setbg2.png",cc.p(480,120),cc.size(860,110))
    createSprite(self.base_node,"res/common/scalable/cutLine.png",cc.p(660,420))
    createSprite(self.base_node,"res/common/scalable/cutLine.png",cc.p(660,270))
    createSprite(self.base_node,"res/common/scalable/cutLine.png",cc.p(660,120))

	local switchs = {
		[GAME_SET_ID_PICKUP_MONEY]=game.getStrByKey("set_auto_getcoin"), --自动拾取金币
		[GAME_SET_AUTO_DRUG] = {game.getStrByKey("set_open"),game.getStrByKey("set_close")}, --自动拾药开关
		[GAME_SET_AUTO_EQUIP] ={game.getStrByKey("set_open"),game.getStrByKey("set_close")}, --自动拾装备开关
		[GAME_SET_AUTO_OTHER] = {game.getStrByKey("set_open"),game.getStrByKey("set_close")}, --自动拾其他开关
		[GAME_SET_ID_PICKUP_WHITE_MATERIAL]=game.getStrByKey("set_auto_white"),
		[GAME_SET_ID_PICKUP_GREEN_MATERIAL]=game.getStrByKey("set_auto_green"),
		[GAME_SET_ID_PICKUP_BLUE_MATERIAL]=game.getStrByKey("set_auto_blue"),
		[GAME_SET_ID_PICKUP_VIOLET_MATERIAL]=game.getStrByKey("set_auto_purple"),
		[GAME_SET_ID_PICKUP_ORANGE_MATERIAL]=game.getStrByKey("set_auto_orange"),
		[GAME_SET_ID_PICKUP_WHITE_EQUIP] = game.getStrByKey("set_auto_white"),	--捡取白色品质装备
		[GAME_SET_ID_PICKUP_GREEN_EQUIP] = game.getStrByKey("set_auto_green"),	--捡取绿色品质装备
		[GAME_SET_ID_PICKUP_BLUE_EQUIP] = game.getStrByKey("set_auto_blue"),		--捡取蓝色品质装备
		[GAME_SET_ID_PICKUP_VIOLET_EQUIP] = game.getStrByKey("set_auto_purple"),	--捡取紫色品质装备
		[GAME_SET_ID_PICKUP_ORANGE_EQUIP] = game.getStrByKey("set_auto_orange"),	--捡取橙色品质装备
		[GAME_SET_ID_PICKUP_WHITE_OTHER] = game.getStrByKey("set_auto_white"),	--捡取白色品质其他
		[GAME_SET_ID_PICKUP_GREEN_OTHER] = game.getStrByKey("set_auto_green"),	--捡取绿色品质其他
		[GAME_SET_ID_PICKUP_BLUE_OTHER] = game.getStrByKey("set_auto_blue"),		--捡取蓝色品质其他
		[GAME_SET_ID_PICKUP_VIOLET_OTHER] = game.getStrByKey("set_auto_purple"),	--捡取紫色品质其他
		[GAME_SET_ID_PICKUP_ORANGE_OTHER] = game.getStrByKey("set_auto_orange"),	--捡取橙色品质其他
	}

	local positions = {
		[GAME_SET_ID_PICKUP_MONEY]=cc.p(83,-10+sub_y),
		[GAME_SET_AUTO_DRUG] = cc.p(785,370+sub_y) ,
		[GAME_SET_AUTO_EQUIP] =cc.p(785,220+sub_y) ,
		[GAME_SET_AUTO_OTHER] = cc.p(785,70+sub_y) ,
		[GAME_SET_ID_PICKUP_WHITE_MATERIAL]=cc.p(83,372+sub_y),
		[GAME_SET_ID_PICKUP_GREEN_MATERIAL]=cc.p(203,372+sub_y),
		[GAME_SET_ID_PICKUP_BLUE_MATERIAL]=cc.p(323,372+sub_y),
		[GAME_SET_ID_PICKUP_VIOLET_MATERIAL]=cc.p(443,372+sub_y),
		[GAME_SET_ID_PICKUP_ORANGE_MATERIAL]=cc.p(563,372+sub_y),
		[GAME_SET_ID_PICKUP_WHITE_EQUIP] = cc.p(83,222+sub_y),
		[GAME_SET_ID_PICKUP_GREEN_EQUIP] = cc.p(203,222+sub_y),
		[GAME_SET_ID_PICKUP_BLUE_EQUIP] = cc.p(323,222+sub_y),
		[GAME_SET_ID_PICKUP_VIOLET_EQUIP] = cc.p(443,222+sub_y),
		[GAME_SET_ID_PICKUP_ORANGE_EQUIP] = cc.p(563,222+sub_y),
		[GAME_SET_ID_PICKUP_WHITE_OTHER] = cc.p(83,72+sub_y),
		[GAME_SET_ID_PICKUP_GREEN_OTHER] = cc.p(203,72+sub_y),	
		[GAME_SET_ID_PICKUP_BLUE_OTHER] = cc.p(323,72+sub_y),
		[GAME_SET_ID_PICKUP_VIOLET_OTHER] = cc.p(443,72+sub_y),
		[GAME_SET_ID_PICKUP_ORANGE_OTHER] = cc.p(563,72+sub_y),
	}
	local color = {
		[GAME_SET_ID_PICKUP_MONEY]=MColor.lable_black,
		[GAME_SET_AUTO_DRUG] = MColor.lable_black ,
		[GAME_SET_AUTO_EQUIP] =MColor.lable_black,
		[GAME_SET_AUTO_OTHER] = MColor.lable_black ,
		[GAME_SET_ID_PICKUP_WHITE_MATERIAL]=MColor.white,
		[GAME_SET_ID_PICKUP_GREEN_MATERIAL]=MColor.green,
		[GAME_SET_ID_PICKUP_BLUE_MATERIAL]=MColor.blue,
		[GAME_SET_ID_PICKUP_VIOLET_MATERIAL]=MColor.purple,
		[GAME_SET_ID_PICKUP_ORANGE_MATERIAL]=MColor.orange,
		[GAME_SET_ID_PICKUP_WHITE_EQUIP] = MColor.white,
		[GAME_SET_ID_PICKUP_GREEN_EQUIP] = MColor.green,
		[GAME_SET_ID_PICKUP_BLUE_EQUIP] = MColor.blue,
		[GAME_SET_ID_PICKUP_VIOLET_EQUIP] = MColor.purple,
		[GAME_SET_ID_PICKUP_ORANGE_EQUIP] = MColor.orange,
		[GAME_SET_ID_PICKUP_WHITE_OTHER] = MColor.white,
		[GAME_SET_ID_PICKUP_GREEN_OTHER] = MColor.green,	
		[GAME_SET_ID_PICKUP_BLUE_OTHER] = MColor.blue,
		[GAME_SET_ID_PICKUP_VIOLET_OTHER] = MColor.purple,
		[GAME_SET_ID_PICKUP_ORANGE_OTHER] = MColor.orange,
	}

	local buttonType = {{"res/component/checkbox/openBtn1.png","res/component/checkbox/closeBtn1.png"},{"res/component/checkbox/1-2.png","res/component/checkbox/1.png"}}
	for k,v in pairs(switchs)do
		local temp = 2
		local indefinePos = nil
		if k == GAME_SET_ID_PICKUP_MONEY then
			indefinePos = {cc.p(30,0),cc.p(0,0.5),MColor.lable_yellow,20}
		elseif k >= GAME_SET_AUTO_DRUG and k <= GAME_SET_AUTO_OTHER then
			temp = 1
			indefinePos = {cc.p(-75,0),cc.p(0,0.5),MColor.lable_yellow,20}			
		else
			indefinePos = {cc.p(30,0),cc.p(0,0.5),color[k],18}
		end
		self:createSwitch(self,positions[k],v,getGameSetById(k),k,nil,indefinePos,nil,buttonType[temp][1],buttonType[temp][2])
	end
	local sroll = self:getScroll()
    if sroll then
    	sroll:setContentOffset(cc.p(0, -260))
    end
end

return pickup