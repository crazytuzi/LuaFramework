-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------显示势力战结果slzzj

wnd_forcewar_showresult = i3k_class("wnd_forcewar_showresult",ui.wnd_base)

local f_rankImg = {2718, 2719, 2720}
local WIN_ICON = 416
local FAILED_ICON = 417
local RED_ICON = {3742, 3741} --正，蓝
local BLUE_ICON = {3743, 3740} --邪，红
local FORCEWAR_DESC = {"正派", "邪派"} -- 正邪对战
local MELEE_DESC = {"蓝队", "红队"} -- 正邪混战

function wnd_forcewar_showresult:ctor()

end

function wnd_forcewar_showresult:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	
	self.villain = self._layout.vars.villain
	self.decent = self._layout.vars.decent
	self.scroll =  self._layout.vars.clan_scroll
	local good_clan_btn = self._layout.vars.good_clan_btn
	local evil_clan_btn = self._layout.vars.evil_clan_btn
	good_clan_btn:onClick(self, self.onTabBarClickWhiteSide)
	evil_clan_btn:onClick(self, self.onTabBarClickBlackSide)
	self._tabbar = {good_clan_btn, evil_clan_btn}
	
	self._layout.vars.decentWin:hide()
	self._layout.vars.villainFaild:hide()
	self._layout.vars.wuxun:setText("")
	self.blueIcon = widgets.blueIcon
	self.redIcon = widgets.redIcon
	self.blueTxt = widgets.blueTxt
	self.redTxt = widgets.redTxt
end

function wnd_forcewar_showresult:setTabBarLight()
	for i,v in pairs(self._tabbar) do
		if i== self._state then
			v:stateToPressedAndDisable()
		else
			v:stateToNormal()
		end
	end
	--self.tabName:setImage(l_tTabName[self._state])
end

function wnd_forcewar_showresult:refresh(whiteSide,blackSide,gainFeat,whiteScore,blackScore,killedBoss,winSide,needsort)
	---rid,rank,name,level,kills,bekills,killNpcs,score,gainFeat
	--根据玩家的正邪显示对应的正邪面板 good_clan_btn  evil_clan_btn
	--local l_transformBWtype = g_i3k_game_context:GetTransformBWtype()--0,1,2
	local forceType = g_i3k_game_context:GetForceType()
	--i3k_log("----- refresh ",gainFeat,whiteScore,blackScore,#whiteSide,#blackSide,killedBoss,l_transformBWtype)
	self._state = forceType
	self._selfSide = {whiteSide,blackSide}
	self:setTabBarLight()
	self._whiteSide = whiteSide
	self._blackSide = blackSide
	self._whiteScore = whiteScore
	self._blackScore = blackScore
	self._killedBoss = killedBoss
	self._winSide = winSide
	self._needsort = needsort
	self._gainFeat = gainFeat
	self:reload(whiteSide,blackSide,whiteScore,blackScore,killedBoss,winSide,needsort,gainFeat)
	self:updateForceWarTypeUI()
end

function wnd_forcewar_showresult:updateForceWarTypeUI()
	local forceWarType = i3k_get_forcewar_type()
	forceWarType = forceWarType == g_FORCEWAR_NORMAL and forceWarType or g_FORCEWAR_CHAOS
	self.blueIcon:setImage(g_i3k_db.i3k_db_get_icon_path(BLUE_ICON[forceWarType]))
	self.redIcon:setImage(g_i3k_db.i3k_db_get_icon_path(RED_ICON[forceWarType]))
	self.blueTxt:setText(forceWarType == g_FORCEWAR_NORMAL and FORCEWAR_DESC[1] or MELEE_DESC[1])
	self.redTxt:setText(forceWarType == g_FORCEWAR_NORMAL and FORCEWAR_DESC[2] or MELEE_DESC[2])
end

function wnd_forcewar_showresult:sortRank( cfg)
	local l_rank = {}	
	for i, e in ipairs(cfg) do
		--index = e.score + e.kills + (100 - e.bekills)+temp--积分，胜利次数，败北次数，id 排序
		table.insert(l_rank, e)		
	end
	local _sort = function(p1, p2)
		if p1.score ~= p2.score then
			return p1.score > p2.score 
		end
		if p1.kills ~= p2.kills  then
			return p1.kills > p2.kills 
		end
		if p1.bekills ~= p2.bekills  then
			return p1.bekills < p2.bekills
		end
		if p1.rid ~= p2.rid then
			return p1.rid > p2.rid 
		end
		return false
	end
	table.sort(l_rank,_sort)
	return l_rank
end

function wnd_forcewar_showresult:reload(whiteSide,blackSide,whiteScore,blackScore,killedBoss,winSide,needsort,gainFeat)
	--killedBoss 1正派水晶被杀也就是输了；2邪派水晶被杀，0是哪边积分高哪边胜利
	self.scroll:removeAllChildren()
	local l_selfGainFeat = 0
	local hero = i3k_game_get_player_hero()
	local open = string.split( hero._guid, "|")
	local rId = tonumber(open[2]) 
	local l_selfSide = self._selfSide[self._state]
	local rank = l_selfSide
	if needsort then
		rank = self:sortRank( l_selfSide)
	end
	
	if whiteScore then
		if winSide~=0 then		
			local whiteImgPath = winSide==1 and g_i3k_db.i3k_db_get_icon_path(WIN_ICON) or g_i3k_db.i3k_db_get_icon_path(FAILED_ICON)
			local blackImgPath = winSide==2 and g_i3k_db.i3k_db_get_icon_path(WIN_ICON) or g_i3k_db.i3k_db_get_icon_path(FAILED_ICON)
			self._layout.vars.decentWin:setImage(whiteImgPath)--正派
			self._layout.vars.villainFaild:setImage(blackImgPath)
		else
			--都输
			self._layout.vars.decentWin:setImage(g_i3k_db.i3k_db_get_icon_path(FAILED_ICON))--正派
			self._layout.vars.villainFaild:setImage(g_i3k_db.i3k_db_get_icon_path(FAILED_ICON))
		end	
		self._layout.vars.decentWin:show()--正派
		self._layout.vars.villainFaild:show()
		self.villain:setText(blackScore)--反派得分
		self.decent:setText(whiteScore)--正派
	else
		--中途进入 不显示
		local score = g_i3k_game_context:getForceWarScore()
		self._layout.vars.decentWin:hide()--正派
		self._layout.vars.villainFaild:hide()
		self.villain:setText(score.blackScore)--反派得分 
		self.decent:setText(score.whiteScore)--正派
	end	
	
	rank = rank or {}
	for i,v in ipairs(rank) do
		local node = require("ui/widgets/slzzjt")()---排名 名称 等级 杀敌 死亡 击杀npc 总分
		local id = i		
		self:setShowAttributeInfo(id,node)
		if v.rid == rId then
			local orangeColor = "FFEE723B"
			node.vars.self_bg:show()
			node.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(8023))
			node.vars.rank_label:setTextColor(orangeColor)
			node.vars.name_label:setTextColor(orangeColor)
			node.vars.lvl_label:setTextColor(orangeColor)
			node.vars.score_label:setTextColor(orangeColor)
		else
			node.vars.self_bg:hide()
			node.vars.bg:setImage(g_i3k_db.i3k_db_get_icon_path(6204))
		end
		node.vars.name_label:setText(v.name)
		node.vars.kill_label:setText(v.kills)
		node.vars.lvl_label:setText(v.level)
		node.vars.dead_label:setText(v.bekills)
		node.vars.killnpc_label:setText(v.killNpcs)
		node.vars.score_label:setText(v.score)
		node.vars.assist_lable:setText(v.assist)
		self.scroll:addItem(node)
	end
	
	self._layout.vars.wuxun:setVisible(not needsort)
	self._layout.vars.wuxun:setText(string.format("本场战斗获得武勋%d点", gainFeat or 0))
end

function wnd_forcewar_showresult:setShowAttributeInfo(index,item)
	if index<=3 then
		item.vars.rank_icon:show()
		item.vars.rank_icon:setImage(g_i3k_db.i3k_db_get_icon_path(f_rankImg[index]))
		item.vars.rank_label:hide()
	else
		item.vars.rank_icon:hide()
		item.vars.rank_label:show()
		item.vars.rank_label:setText(index..".")
	end
end

function wnd_forcewar_showresult:onTabBarClickWhiteSide(sender)
	self._state = 1
	self:setTabBarLight()
	self:reload(self._whiteSide,self._blackSide,self._whiteScore,self._blackScore,self._killedBoss,self._winSide,self._needsort,self._gainFeat)
end

function wnd_forcewar_showresult:onTabBarClickBlackSide(sender)	
	self._state = 2
	self:setTabBarLight()
	self:reload(self._whiteSide,self._blackSide,self._whiteScore,self._blackScore,self._killedBoss,self._winSide,self._needsort,self._gainFeat)
end

function wnd_create(layout, ...)
	local wnd = wnd_forcewar_showresult.new()
		wnd:create(layout, ...)
	return wnd
end
