local NpcSprite = class("NpcSprite", function(strname) return  SpriteMonster:create(strname) end)
local NpcId_King1 = 10391
local NpcId_King2 = 10398
local NpcId_No1star,NpcId_No1end = 10420, 10425
local NpcId_Biqistar,NpcId_Biqiend = 10455, 10460
local NpcId_ShaWarstar,NpcId_ShaWarend = 10468, 10473
local NpcId_spec = 10395
local NpcId_Charm = 10454
local NpcId_TongTianTa = 10397

function NpcSprite:ctor(strname,id, cj)
	
	local sprute_num = getConfigItemByKey("NPC","q_id",id,"F14") or 4
	--self:initStandStatus(sprute_num,4,1.0,0)
	self:initStandStatus(sprute_num,4,1.0,6)
	self.id = id
	self:setType(1)
	self:standed()
	--createSprite(self,"res/shadow.png",cc.p(0,0))
	self:setNeedShowName(true)
	self.npc_effect = Effects:create(false)
	self.npc_effect:setVisible(false)
	self.npc_effect:setPosition(cc.p(0 , 40))
	if self:getTitleNode() then
		self:getTitleNode():addChild(self.npc_effect,25)
	end
	self.isCollect = false
	if cj and cj == 1 then
		self.isCollect = true
		local effect = Effects:create(false)
		effect:setAnchorPoint(cc.p(0.5,0.5))
		local s = self:getContentSize()
		effect:setPosition(cc.p(s.width/2, s.height/2 + 22))
		self:addChild(effect, 10)
		effect:playActionData("dropeffect",11,2,-1)
	else
		self.isCollect = nil
	end

	--dump(id, "id")

	--self:standed()
	
	local sprute_name = getConfigItemByKey("NPC","q_id",self.id,"q_name") or ""
	local name_label = self:getNameBatchLabel()
    if name_label then
		name_label:setString(sprute_name)
		self:setTheName(sprute_name)
		name_label:setColor(MColor.yellow)
    end

    self:setVisibleNameAndBlood(false)
		
	if self.id == NpcId_King1 or self.id == NpcId_King2 then
    	self:setNameAndBloodPos(true, 20, 80)
	elseif self.id >= NpcId_No1star and self.id <= NpcId_No1end then
		--天下第一
		self:setNameAndBloodPos(true, 15, 180)

		if name_label then
			name_label:setColor(MColor.yellow)
		end
		local index = self.id - NpcId_No1star + 1
		if G_NO_ONEINFO and G_NO_ONEINFO[index] and G_NO_ONEINFO[index] ~= "" then
			self:addNo1Name(G_NO_ONEINFO[index])
		end

	elseif self.id >= NpcId_Biqistar and self.id <= NpcId_Biqiend then
		--中州王
		self:setNameAndBloodPos(true, 15, 180)
		self:showBiqiKingName(G_EMPIRE_INFO.BIQI_KING.name)

	elseif self.id >= NpcId_ShaWarstar and self.id <= NpcId_ShaWarend then
		--沙城主
		self:setNameAndBloodPos(false)
    	self:showShaKingName(G_SHAWAR_DATA.KING.name)

	elseif self.id == NpcId_Charm then
		--万人迷
		self:setNameAndBloodPos(false)

		local name = ""
		if G_CharmRankList and G_CharmRankList.ListData and G_CharmRankList.ListData[1] and G_CharmRankList.ListData[1][2] then
			name = G_CharmRankList.ListData[1][2]
		end
		self:showCharmTopName(name)

	elseif self.id == NpcId_spec then
		self:setNameAndBloodPos(true,13,90)

	elseif self.id == NpcId_TongTianTa then
		self:setNameAndBloodPos(true,0,180)

		local effect = Effects:create(false)
		effect:setPlistNum(-1)
		effect:setAnchorPoint(cc.p(0.5,0.5))
		local s = self:getContentSize()
		effect:setPosition(cc.p(s.width/2 - 20, 100))
		effect:setScale(1.6667)
		effect:playActionData2("towernpc", 100, -1, 0)
		self:getTitleNode():addChild(effect, 100)
    else
    	self:setNameAndBloodPos(false)
    end

end 

function NpcSprite:showTask(idx)
	if self.npc_effect then
		if idx == 1 then
			self.npc_effect:playActionData("finishtask", 9, 2, -1)
		elseif idx == 2 then
			self.npc_effect:playActionData("newtask", 7, 1.6, -1)
		elseif idx == 3 then
			self.npc_effect:playActionData("unfinishtask", 9, 2, -1)
		end
	end
end

function NpcSprite:normalState()
	self.npc_effect:runAction(cc.Sequence:create(cc.DelayTime:create(0.0), cc.Hide:create()))
end

function NpcSprite:addNo1Name(name)
	local height = -15
	local title_node = self:getTitleNode()
	if title_node then
		local lab = title_node:getChildByTag(804)
		if not lab then
			lab = createLabel( title_node , name , cc.p(0 , height) , cc.p( 0.5 , 0.5 ) , 15 , true , 200 , nil , MColor.yellow)
			lab:enableOutline(cc.c4b(0,0,0,255),1)
			lab:setLocalZOrder(50)
			lab:setTag(804)
		end
		lab:setString(name)
	end
end

function NpcSprite:showCharmTopName(name)
	local height = 220
	local batch_name = self:getNameBatchLabel()
	local tempName = game.getStrByKey("biqi_str9")
	if name and name ~= "" then
		tempName = name
	end
	local nameStr = game.getStrByKey("charm_week_top").."【" ..tempName.."】"

	batch_name:setString(nameStr)
end

function NpcSprite:showBiqiKingName(name)
	local height = 220
	local batch_name = self:getNameBatchLabel()
	local tempName = game.getStrByKey("biqi_str16")
	if name and name ~= "" then
		tempName = name
	end
	local nameStr = game.getStrByKey("worShip_Title").."【" ..tempName.."】"
	
	batch_name:setString(nameStr)
end

function NpcSprite:showShaKingName(name)
	local height = 220
	local batch_name = self:getNameBatchLabel()
	local tempName = game.getStrByKey("biqi_str16")
	if name and name ~= "" then
		tempName = name
	end
	local nameStr = game.getStrByKey("worShip_Title3").."【" ..tempName.."】"
	
	batch_name:setString(nameStr)
end

return NpcSprite