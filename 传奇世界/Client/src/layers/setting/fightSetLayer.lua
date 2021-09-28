local fight = class("fightSetLayer",require("src/layers/setting/BaseLayer"))

function fight:ctor()	
	local sub_y = 185

  	local bg = self:floor("res/common/scalable/panel_outer_base.png",cc.rect(0, 0, 890,504),cc.p(479.5,290.5))
    self:addChild(bg)
   	createScale9Sprite(self, "res/common/scalable/panel_outer_frame_scale9.png", cc.p(479.5,290.5), cc.size(890, 504), cc.p(0.5, 0.5))

   	if G_ROLE_MAIN.school == 1 then
   		self:addScroll(cc.size(880,490),cc.size(880,490),cc.p(40,45))
   		sub_y = 50
   	else
   		self:addScroll(cc.size(880,490),cc.size(880,630),cc.p(40,45),true)
		createLabel(self.base_node,game.getStrByKey("set_skill_cast"),cc.p(30,-45+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
		createScale9Sprite(self.base_node,"res/common/scalable/setbg2.png",cc.p(440,-120+sub_y),cc.size(860,100))
   	end

	createLabel(self.base_node,game.getStrByKey("set_smartfight"),cc.p(30,430+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)
	createLabel(self.base_node,game.getStrByKey("set_smartchoose"),cc.p(30,170+sub_y),cc.p(0,0.5),20,true,nil,nil,MColor.lable_yellow)

	createScale9Sprite(self.base_node,"res/common/scalable/setbg2.png",cc.p(440,302+sub_y),cc.size(860,216))
    createScale9Sprite(self.base_node,"res/common/scalable/setbg2.png",cc.p(440,60+sub_y),cc.size(860,170))   
    createScale9Sprite(self.base_node,"res/common/scalable/cutLine.png",cc.p(620,302+sub_y),cc.size(47,206))
    createScale9Sprite(self.base_node,"res/common/scalable/cutLine.png",cc.p(620,60+sub_y),cc.size(47,160))

	local switchs = {}

	local switchs = {
		[GAME_SET_SMARTFIGHT]={game.getStrByKey("set_open"),game.getStrByKey("set_close")},
		[GAME_SET_SMARTCHOOSE] = {game.getStrByKey("set_open"),game.getStrByKey("set_close")}, 
		[GAME_SET_HIDEFRIEND] =game.getStrByKey("set_hide_friend"), 
		[GAME_SET_HIDETEAMPLAYER] = game.getStrByKey("set_hide_teamplayer"), 
		[GAME_SET_HIDEGUILDSPLAYER]=game.getStrByKey("set_hide_guildsplayer"),
		[GAME_SET_HIDEALLIANCEPLAYER]=game.getStrByKey("set_hide_allianceplayer"),

	}

	local positions = {
		[GAME_SET_SMARTFIGHT]=cc.p(745,305+sub_y),
		[GAME_SET_SMARTCHOOSE] = cc.p(745,55+sub_y) ,
		[GAME_SET_HIDEFRIEND] =cc.p(45,100+sub_y) ,
		[GAME_SET_HIDETEAMPLAYER] = cc.p(390,100+sub_y) ,
		[GAME_SET_HIDEGUILDSPLAYER]=cc.p(45,25+sub_y),
		[GAME_SET_HIDEALLIANCEPLAYER]=cc.p(390,25+sub_y),

	}

	if G_ROLE_MAIN then
		if G_ROLE_MAIN.school == 1 then
			positions[GAME_SET_ID_ELUDE_MONSTER]= cc.p(45,370+sub_y)
			positions[GAME_SET_ID_AUTO_FIRE] = cc.p(245,370+sub_y)--cc.p(85,175+sub_y)
			positions[GAME_SET_ID_AUTO_HALFMOON] = cc.p(45,295+sub_y)
			positions[GAME_SET_ID_AUTO_DOUBLE_FIRE] = cc.p(245,295+sub_y)
			positions[GAME_SET_AUTOCRASH] = cc.p(440,295+sub_y)
			positions[GAME_SET_AUTOCRASHKILL] = cc.p(440,370+sub_y)
			positions[GAME_SET_ZHANSHI_DEFENSE] = cc.p(45,220+sub_y)
			switchs[GAME_SET_ID_ELUDE_MONSTER]=game.getStrByKey("set_auto_attack")
			switchs[GAME_SET_ID_AUTO_FIRE] = game.getStrByKey("set_auto_fire")
			switchs[GAME_SET_ID_AUTO_HALFMOON] = game.getStrByKey("set_auto_banyue")
			switchs[GAME_SET_ID_AUTO_DOUBLE_FIRE] = game.getStrByKey("set_double_fire")
			switchs[GAME_SET_AUTOCRASH] = game.getStrByKey("set_auto_crash")
			switchs[GAME_SET_AUTOCRASHKILL] = game.getStrByKey("set_auto_crashkill")
			switchs[GAME_SET_ZHANSHI_DEFENSE] = game.getStrByKey("set_zhanshidefense")
		else
			if G_ROLE_MAIN.school == 2 then
				positions[GAME_SET_ID_ELUDE_MONSTER]= cc.p(45,370+sub_y)
				positions[GAME_SET_ID_AUTO_THUNDER] = cc.p(45,295+sub_y)--cc.p(85,175+sub_y)
				positions[GAME_SET_ID_AUTO_ICE] = cc.p(390,295+sub_y)--cc.p(395,175+sub_y)
				positions[GAME_SET_FIRERING] = cc.p(390,370+sub_y)
				positions[GAME_SET_MAGICSHIELD] = cc.p(45,225+sub_y)
				positions[GAME_SET_FASHI_DEFENSE] = cc.p(390,225+sub_y)
				switchs[GAME_SET_ID_ELUDE_MONSTER]=game.getStrByKey("set_auto_attack")
				switchs[GAME_SET_ID_AUTO_THUNDER] = game.getStrByKey("set_auto_dylg")
				switchs[GAME_SET_ID_AUTO_ICE] = game.getStrByKey("set_auto_bpx")
				switchs[GAME_SET_FIRERING] = game.getStrByKey("set_auto_firering")
				switchs[GAME_SET_MAGICSHIELD] = game.getStrByKey("set_magicshield")
				switchs[GAME_SET_FASHI_DEFENSE] = game.getStrByKey("set_fashidefense")
			elseif G_ROLE_MAIN.school == 3 then
				positions[GAME_SET_ID_ELUDE_MONSTER]= cc.p(45,370+sub_y)
				positions[GAME_SET_ID_AUTO_SUMMON_GW] = cc.p(245,295+sub_y)--cc.p(85,175+sub_y)
				positions[GAME_SET_ID_AUTO_SUMMON] = cc.p(245,370+sub_y)--cc.p(295,175+sub_y)
				positions[GAME_SET_ID_AUTO_ARMOUR] = cc.p(440,370+sub_y)--cc.p(505,175+sub_y)
				positions[GAME_SET_ID_AUTO_POISON] = cc.p(45,295+sub_y)--cc.p(715,175+sub_y)
				positions[GAME_SET_LIONSHOUT] = cc.p(440,295+sub_y)
				positions[GAME_SET_DAOSHI_DEFENSE] = cc.p(45,225+sub_y)
				switchs[GAME_SET_ID_ELUDE_MONSTER]=game.getStrByKey("set_auto_attack")
				switchs[GAME_SET_ID_AUTO_SUMMON_GW] = game.getStrByKey("set_auto_guwei")
				switchs[GAME_SET_ID_AUTO_SUMMON] = game.getStrByKey("set_auto_shshou")
				switchs[GAME_SET_ID_AUTO_ARMOUR] = game.getStrByKey("set_auto_ylzhj")
				switchs[GAME_SET_ID_AUTO_POISON] = game.getStrByKey("set_auto_shdu")
				switchs[GAME_SET_LIONSHOUT] = game.getStrByKey("set_auto_lionshout")
				switchs[GAME_SET_DAOSHI_DEFENSE] = game.getStrByKey("set_daoshidefense")
			end
			positions[GAME_SET_ACTIVE_SKILL] = cc.p(45,-120+sub_y)
			positions[GAME_SET_CHOOSE_SKILL] = cc.p(390,-120+sub_y)
			switchs[GAME_SET_ACTIVE_SKILL] = game.getStrByKey("active_cast")
			switchs[GAME_SET_CHOOSE_SKILL] = game.getStrByKey("choose_cast")
		end
	end

	local buttonType = {{"res/component/checkbox/openBtn1.png","res/component/checkbox/closeBtn1.png"},{"res/component/checkbox/1-2.png","res/component/checkbox/1.png"}}
	for k,v in pairs(switchs)do
		local temp = 2
		local indefinePos = nil
		if k == 63 or k ==64 then
			temp = 1
			indefinePos = {cc.p(-200,0),cc.p(0,0.5),MColor.lable_yellow,20}
		else
			indefinePos = {cc.p(30,0),cc.p(0,0.5),MColor.lable_black,20}
		end
		self:createSwitch(self.base_node,positions[k],v,getGameSetById(k,true),k,nil,indefinePos,nil,buttonType[temp][1],buttonType[temp][2])
	end
	local sroll = self:getScroll()
    if sroll then
    	sroll:setContentOffset(cc.p(0, -260))
    end
end

return fight