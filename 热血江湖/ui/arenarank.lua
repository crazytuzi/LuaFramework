-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_arenaRank = i3k_class("wnd_arenaRank", ui.wnd_base)
local f_rankImg = {2718, 2719, 2720}
local f_numberImgTable = {"jjc#jjc_0.png", "jjc#jjc_1.png", "jjc#jjc_2.png", "jjc#jjc_3.png", "jjc#jjc_4.png", "jjc#jjc_5.png", "jjc#jjc_6.png", "jjc#jjc_7.png", "jjc#jjc_8.png", "jjc#jjc_9.png"}
function wnd_arenaRank:ctor()
	
end

function wnd_arenaRank:configure()
	self._layout.vars.close:onClick(self, self.onClose)
	self._modelId = 30
	
	g_i3k_game_context:ResetTestFashionData()
	ui_set_hero_model(self._layout.vars.model, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion())
end

function wnd_arenaRank:onShow()
	
end

function wnd_arenaRank:refresh(sRank, ranks)
	local mww = self._layout.vars.ww
	local mqw = self._layout.vars.qw
	local mbw = self._layout.vars.bw
	local msw = self._layout.vars.sw
	local mgw = self._layout.vars.gw
	
	
	if sRank<10000 then
		mgw:hide()
		if sRank<1000 then
			msw:hide()
			if sRank<100 then
				mbw:hide()
				if sRank<10 then
					mqw:hide()
					mww:setImage(f_numberImgTable[sRank+1])
				else
					local sw = math.floor(sRank/10)
					local gw = math.floor(sRank%10/1)
					mww:setImage(f_numberImgTable[sw+1])
					mqw:setImage(f_numberImgTable[gw+1])
				end
			else
				local bw = math.floor(sRank/100)
				local sw = math.floor(sRank%100/10)
				local gw = math.floor(sRank%1000%100%10/1)
				mww:setImage(f_numberImgTable[bw+1])
				mqw:setImage(f_numberImgTable[sw+1])
				mbw:setImage(f_numberImgTable[gw+1])
			end
		else
			local qw = math.floor(sRank/1000)
			local bw = math.floor(sRank%1000/100)
			local sw = math.floor(sRank%1000%100/10)
			local gw = math.floor(sRank%1000%100%10/1)
			mww:setImage(f_numberImgTable[qw+1])
			mqw:setImage(f_numberImgTable[bw+1])
			mbw:setImage(f_numberImgTable[sw+1])
			msw:setImage(f_numberImgTable[gw+1])
		end
	else
		local ww = math.floor(sRank/10000)
		local qw = math.floor(sRank%10000/1000)
		local bw = math.floor(sRank%10000%1000/100)
		local sw = math.floor(sRank%10000%1000%100/10)
		local gw = math.floor(sRank%10000%1000%100%10/1)
		mww:setImage(f_numberImgTable[ww+1])
		mqw:setImage(f_numberImgTable[qw+1])
		mbw:setImage(f_numberImgTable[bw+1])
		msw:setImage(f_numberImgTable[sw+1])
		mgw:setImage(f_numberImgTable[gw+1])
	end
	
	local wordTable = {mww, mqw, mbw, msw, mgw}
	local count = 0
	local needWidth = 0
	for i,v in ipairs(wordTable) do
		if not v:isVisible() then
			count = count + 1
			needWidth = v:getContentSize().width + needWidth
		end
	end
	for i,v in ipairs(wordTable) do
		local x = v:getPositionX()
		local width = v:getContentSize().width
		v:setPosition(v:getPositionX()+needWidth/2, v:getPositionY())
		if count==1 then
			v:setScale(1.1)
		elseif count==2 then
			v:setScale(1.2)
		elseif count==3 then
			v:setScale(1.3)
		elseif count==4 then
			v:setScale(1.4)
		end
		local scale = v:getScale()
		--v:setPosition(v:getPositionX()+count*width/2-(width*scale-width)/2, v:getPositionY())
		local haveCount = #wordTable - count
		if haveCount%2==1 then
			local dis = math.abs(math.ceil(haveCount/2) - i)
			if i<math.ceil(haveCount/2) then
				v:setPosition(v:getPositionX() - dis*(width*scale-width), v:getPositionY())
			elseif i>math.ceil(haveCount/2) then
				v:setPosition(v:getPositionX() + dis*(width*scale-width), v:getPositionY())
			end
		else
			if i<=haveCount/2 then
				local dis = math.abs(haveCount/2 - i+1)
				v:setPosition(v:getPositionX() - dis*(width*scale-width), v:getPositionY())
			elseif i>haveCount/2 then
				local dis = math.abs(haveCount/2 - i)
				v:setPosition(v:getPositionX() + dis*(width*scale-width), v:getPositionY())
			end
		end
	end
	self:reloadRankList(ranks)
end

function wnd_arenaRank:onClose(sender)
	g_i3k_ui_mgr:CloseUI(eUIID_ArenaRank)
end

function wnd_arenaRank:reloadRankList(ranks)
	local scroll = self._layout.vars.scroll
	for i,v in ipairs(ranks) do
		local pht = require("ui/widgets/11jjpht")()
		if i<=3 then
			pht.vars.rankImg:show()
			pht.vars.rankImg:setImage(g_i3k_db.i3k_db_get_icon_path(f_rankImg[i]))
			pht.vars.rankLabel:hide()
		else
			pht.vars.rankImg:hide()
			pht.vars.rankLabel:show()
			pht.vars.rankLabel:setText(i..".")
		end
		local role = v.role
		local sectData = {sectId = v.sectId, sectName = v.sectName, personalMsg = v.personalMsg}
		pht.vars.btn:setTag(role.id)
		pht.vars.btn:onClick(self, self.checkRoleModel, {rank = i, role = role, sectData = sectData})
		pht.vars.lvlLabel:setText(role.level.."级")
		pht.vars.name:setText(role.name)
		pht.vars.occupation:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_generals[role.type].classImg))
		if role.id<0 then
			local robot = i3k_db_arenaRobot[math.abs(role.id)]
			role.fightPower = robot.power
		end
		pht.vars.power:setText(role.fightPower)
		if i%2==1 then
			pht.vars.sharder:show()
		else
			pht.vars.sharder:hide()
		end
		scroll:addItem(pht)
	end
	
	--[[self._layout.vars.scroll:setLoadEvent(function ()
		g_i3k_ui_mgr:PopupTipMessage("eventLoad")
	end, "ui/widgets/11jjpht2")--]]
end

function wnd_arenaRank:checkRoleModel(sender, value)
	local myId = g_i3k_game_context:GetRoleId()
	local targetId = sender:getTag()
	if targetId~=myId then
		if targetId > 0 then
			i3k_sbean.query_rolebrief(targetId, { arena = true, value = value})
		else
			i3k_sbean.query_robot(targetId, value)
		end
		self._layout.vars.model:setTouchEnabled(false)
	else
		g_i3k_game_context:ResetTestFashionData()
		ui_set_hero_model(self._layout.vars.model, i3k_game_get_player_hero(), g_i3k_game_context:GetWearEquips(), g_i3k_game_context:GetIsShwoFashion())
		--自己的防守信息如何处理
	end
end


function wnd_arenaRank:changeModel(id, bwType, gender, face, hair, equips,fashions,isshow,equipparts,armor, value, weaponSoulShow, isEffectFashion, soaringDisplay)
	local modelTable = {}
	modelTable.node = self._layout.vars.model
	modelTable.id = id
	modelTable.bwType = bwType
	modelTable.gender = gender
	modelTable.face = face
	modelTable.hair = hair
	modelTable.equips = equips
	modelTable.fashions = fashions
	modelTable.isshow = isshow
	modelTable.equipparts = equipparts
	modelTable.armor = armor
	modelTable.weaponSoulShow = weaponSoulShow
	modelTable.isEffectFashion = isEffectFashion
	modelTable.soaringDisplay = soaringDisplay
	self:createModelWithCfg(modelTable)
	self._layout.vars.model:onClick(self, function()
		i3k_sbean.get_rank_defensive(value.role, value.rank, value.sectData)
	end)
end

function wnd_create(layout, ...)
	local wnd = wnd_arenaRank.new();
	wnd:create(layout, ...);
	
	return wnd;
end
