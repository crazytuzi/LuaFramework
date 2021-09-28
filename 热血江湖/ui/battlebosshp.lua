module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_battleBossHp = i3k_class("wnd_battleBossHp", ui.wnd_base)
local LAYER_BUFF = "ui/widgets/bufft"
function wnd_battleBossHp:ctor()
    self._selfbuffupdate_time = 0
end

function wnd_battleBossHp:configure()
    local boss = {}--------BOSS
    self._widgets = {}
	self._widget = self._layout.vars
	boss.root = self._layout.vars.boss--------BOSS__控制显隐
	boss.icon = self._layout.vars.bosstx--------BOSS头像Image
	boss.nameLabel = self._layout.vars.bossName--------BOSS名字Label
	boss.bloodLabel = self._layout.vars.bossxl--------BOSS血量显示的Label
	boss.levelLabel = self._layout.vars.bosslevel--------BOSS等级Label
	boss.bloodBar = self._layout.vars.bossxt--------BOSS最上层血量LoadingBar
	boss.bloodNext = self._layout.vars.xd--------BOSS下层血量Image
	boss.levelLabelBg = self._layout.vars.bosslevelbg--------BOSS下层血量Image
	boss.neijiaBar = self._layout.vars.neijiaBar--------内甲条
	boss.neijiaBarBottom = self._layout.vars.neijiaBarBottom--------内甲下层Image
	boss.bosslevel2 = self._layout.vars.bosslevel2--------BOSS等级Labe2
	self._widgets.boss = boss
	--选中人物、选中npc使用的是和boss相同的UI控件
	self._widgets.selectRole = boss
	self._widgets.npc = boss
    --buff相关界面
	local buff = {}
    buff.selbuff = self._layout.vars.buffbar2
    self._layout.vars.buffbar2:setTouchEnabled(false)
    self._widgets.buff = buff
    self._selectbuff = {}
    self._cleanbuff = true
    self._bufflist = {{},{},{},{}}
end

function wnd_battleBossHp:refresh()

end

function wnd_battleBossHp:openInhurtUI(isOpen)
	i3k_log("openComing!!!")
	if isOpen and not self._isMoveDown then
		local buffsNode = self._layout.vars.buffbar2
		local yAbOffset = 10 --编辑器内设定值
		local yAbSizeY = 360
		local yfactor = yAbOffset / yAbSizeY
		local yRealOffset = buffsNode:getParent():getContentSize().height * yfactor
		local tmpPos = buffsNode:getPosition()
		buffsNode:setPosition(tmpPos.x, tmpPos.y - yRealOffset)
		self._layout.vars.bosslevelbg:setVisible(false)
		self._layout.vars.neijiaBar2:setVisible(false)
		self._layout.vars.neijiaBarBottom2:setVisible(false)
		self._layout.vars.neishangNode:setVisible(true)
		self._isMoveDown = true
	end
end
function wnd_battleBossHp:onUpdate(dTime)
    self:onUpdatebuff(dTime)
end

function wnd_battleBossHp:onUpdatebuff(dTime)
	local update = false
	for _, buff in pairs(self._selectbuff) do
		update = true;
	end

	if update or self._cleanbuff then
		self._selfbuffupdate_time = self._selfbuffupdate_time + dTime
		if self._selfbuffupdate_time > 0.1 then
			if self._cleanbuff then
				self:Clearbuff()
			end
			for id,lefttime in pairs(self._selectbuff) do
				self._selectbuff[id] = self._selectbuff[id] - self._selfbuffupdate_time *1000
			end

			if self._cleanbuff then
				-- self:updateselfbuff()
				self:updatetargetbuff()
				self._cleanbuff = false
			end

			self._selfbuffupdate_time = 0;
		end
	end
end
function wnd_battleBossHp:Clearbuff()
		-- self._widgets.buff.mybuff:removeAllChildren()
		self._widgets.buff.selbuff:removeAllChildren()
end
function wnd_battleBossHp:updatetargetbuff()
	local targetbuffcount = 0
	local targetdebuffcount = 0
	self._bufflist[3] = {}
	self._bufflist[4] = {}
	for id,lefttime in pairs(self._selectbuff) do
		local cfg = i3k_db_buff[id]
		if cfg.type == 0 or cfg.type == 1 then
			if cfg.iconID ~= 0 and cfg.iconID ~= 1 then
				table.insert(self._bufflist[3],cfg)
				targetbuffcount = targetbuffcount + 1
			end
		elseif cfg.type == 2 then
			if cfg.iconID ~= 0 and cfg.iconID ~= 1 then
				table.insert(self._bufflist[4],cfg)
				targetdebuffcount = targetdebuffcount + 1
			end
		end
	end
	if targetbuffcount > 5 then
		targetbuffcount = 5
	end
	if targetdebuffcount > 5 then
		targetdebuffcount = 5
	end

	local children = self._widgets.buff.selbuff:addChildWithCount(LAYER_BUFF,5,10)
	local count = 0
	for i = 1 ,5 do
		count = count + 1
		children[count].vars.bt:setTouchEnabled(false)
		children[count].vars.bt:hide()
		if i <= targetbuffcount then
			children[count].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(self._bufflist[3][i].iconID))
			children[count].vars.bt:setTag(count+10)
			if self._selectbuff[self._bufflist[3][i].id] < 3000 and  self._selectbuff[self._bufflist[3][i].id] > 0 then
				--TODO闪烁特效
			end
			children[count].vars.bt:onClick(self, self.onBuffSelect)
			children[count].vars.bt:show()
		end
	end
	count = 5
	for i = 1 ,5 do
		count = count + 1
		children[count].vars.bt:setTouchEnabled(false)
		children[count].vars.bt:hide()
		if i <= targetdebuffcount then
			children[count].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(self._bufflist[4][i].iconID))
			children[count].vars.bt:setTag(count+10)
			if self._selectbuff[self._bufflist[4][i].id] < 3000 and  self._selectbuff[self._bufflist[4][i].id] > 0 then
				--TODO闪烁特效
			end
			children[count].vars.bt:onClick(self, self.onBuffSelect)
			children[count].vars.bt:show()
		end
	end
end

function wnd_battleBossHp:onBuffSelect(sender)
	--if i3k_db_common.debugswitch.bufftime == 1 then
		local tagID = sender:getTag()
		local buffname = nil;
		local pos = sender:getPosition()
		pos = sender:getParent():convertToWorldSpace(pos)
		if tagID > 0 and tagID <= 5 then
			buffname = self._bufflist[1][tagID].note
		elseif tagID > 5 and tagID <= 10 then
			buffname = self._bufflist[2][tagID-5].note
		elseif tagID > 10 and tagID <= 15 then
			buffname = self._bufflist[3][tagID-10].note
		elseif tagID > 15 and tagID <= 20 then
			buffname = self._bufflist[4][tagID-15].note
		end
		g_i3k_ui_mgr:OpenUI(eUIID_BuffTips)
		g_i3k_ui_mgr:RefreshUI(eUIID_BuffTips, buffname, pos)
	--end
end

-- 更新boss 血条
function wnd_battleBossHp:updateTargetMonster(monsterId, curHp, maxHp, buffs, curArmor, maxArmor, showName) -- InvokeUIFunction
	-- local monster = self._widgets.monster
	local boss = self._widgets.boss
	local monsterName = g_i3k_db.i3k_db_get_monster_sect_name(monsterId, showName)
	local isBoss = g_i3k_db.i3k_db_get_monster_is_boss(monsterId)
	local isArmor = g_i3k_db.i3k_db_get_monster_is_armor(monsterId)
	local level = i3k_db_monsters[monsterId].level
	if isArmor then
		boss.levelLabelBg:hide();
		self._layout.vars.njGrid:show();
		boss.bosslevel2:setText(level);
		if curArmor and maxArmor then
			self:updateNeiJiaValue(monsterId, curArmor, maxArmor)
		end
	else
		self._layout.vars.njGrid:hide();
		boss.levelLabelBg:show();
		boss.levelLabel:setText(level);
	end
	boss.root:setTag(isBoss and 1 or 0)
	boss.icon:setImage(g_i3k_db.i3k_db_get_monster_head_icon_path(monsterId))
	boss.nameLabel:setText(monsterName)
	boss.levelLabel:setTextColor(g_i3k_db.i3k_db_get_monster_level_color(level))
	-- boss.root:setVisible(isBoss)
	self:updateSeletctBuff(buffs)
	-- monster.nameLabel:setText(monsterName)
	-- monster.root:setVisible(not isBoss)
	self:updateTargetHp(curHp, maxHp)
end

--[[function wnd_battleBossHp:updateTargetRole(roleId, headIcon, name, level, curHp, maxHp, buffs)
	local widgets = self._widgets.selectRole
	widgets.root:setTag(0)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(headIcon, false))
	widgets.nameLabel:setText(name)
	widgets.levelLabel:setText(level)
	widgets.levelLabel:show()
	widgets.root:show()
	self:updateSeletctBuff(buffs)
	-- self._widgets.monster.root:hide()

	self:updateTargetHp(curHp, maxHp)
	widgets.icon:onClick(self, self.onBossTxClicked, roleId)
end

function wnd_battleBossHp:onBossTxClicked(sender, roleId)
	local parent = sender:getParent()
	local pos = sender:getPosition()
	local width = sender:getContentSize().width
	pos = parent:convertToWorldSpace(cc.p(pos.x+width/2, pos.y))

	if roleId then
		local checkTeamId = i3k_sbean.team_role_query_req.new()
		checkTeamId.roleId = roleId
		checkTeamId.pos = pos
		checkTeamId.targetId = roleId
		checkTeamId.openId = eUIID_Wjxx
		i3k_game_send_str_cmd(checkTeamId, i3k_sbean.team_role_query_res.getName())
	end
end--]]

function wnd_battleBossHp:updateTargetMercenary(id, level, name, curHp, maxHp, buffs, isCar, awaken) -- InvokeUIFunction
	-- self._widgets.monster.root:hide()
	local mercenary = self._widgets.boss
	self:updateSeletctBuff(buffs)
	mercenary.root:setTag(0)
	local iconId = g_i3k_db.i3k_db_get_head_icon_id(id)
	if awaken and awaken == 1 then
		iconId = i3k_db_mercenariea_waken_property[id].headIcon;
	end
	mercenary.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId))
	mercenary.levelLabel:show()
	mercenary.levelLabel:setText(level)
	if isCar then
		mercenary.levelLabel:hide()
		mercenary.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(2201))
	end
	mercenary.nameLabel:setText(name)
	self:updateTargetHp(curHp, maxHp)
	mercenary.root:show()
end

-- 点击npc触发非任务对话
function wnd_battleBossHp:updateTargetNPC(id, name, curhp, maxhp, mId, mValue)
	local monster = self._widgets.monster
	local npc = self._widgets.npc
	local mosterid = i3k_db_npc[id].monsterID;
	npc.root:setTag(0)
	local iconId = g_i3k_db.i3k_db_get_head_icon_id(mosterid)
	npc.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId))
	npc.nameLabel:setText(name)
	npc.levelLabel:hide()
	npc.levelLabelBg:hide()
	npc.root:show()
	--self:updateSeletctBuff(buffs)
	-- monster.root:hide() -- 小怪
	self:updateTargetHp(curhp, maxhp, true)
end

local bloodLayerIconsId =
{
	[0] = 0,
	[1] = 26,
	[2] = 25,
	[3] = 24,
	[4] = 23,
	[5] = 22,
	[6] = 21,
}
function wnd_battleBossHp:updateTargetHp(curHp, maxHp, isNpc)
	local boss = self._widgets.boss
	if boss.root:getTag() == 1 then
		local bloodlayer = math.ceil(curHp * 6 / maxHp)
		bloodlayer = bloodlayer == 0 and 1 or bloodlayer
		boss.bloodBar:setImage(g_i3k_db.i3k_db_get_icon_path(bloodLayerIconsId[bloodlayer]))
		boss.bloodNext:setImage(g_i3k_db.i3k_db_get_icon_path(bloodLayerIconsId[bloodlayer-1]))
		boss.bloodNext:setVisible(bloodlayer ~= 1)
		boss.bloodBar:setPercent((curHp-maxHp*(bloodlayer-1)/6)/(maxHp/6)*100)
		boss.bloodLabel:show()
		boss.bloodLabel:setText("x" .. bloodlayer)
	else
		boss.bloodBar:setImage(g_i3k_db.i3k_db_get_icon_path(bloodLayerIconsId[1]))
		boss.bloodNext:hide()--setImage(g_i3k_db.i3k_db_get_icon_path(bloodLayerIconsId[0]))
		boss.bloodBar:setPercent(curHp/maxHp * 100)
		boss.bloodLabel:setVisible(not isNpc)
		boss.bloodLabel:setText(curHp)
	end
	-- local monster = self._widgets.monster
	-- monster.bloodBar:setPercent(curHp/maxHp * 100)
end

-- 内甲值变化动画
function wnd_battleBossHp:updateNeiJiaValue(monsterId, curValue, maxValue)
	local boss = self._widgets.boss
	local isArmor = g_i3k_db.i3k_db_get_monster_is_armor(monsterId)
	local level = i3k_db_monsters[monsterId].level
	if isArmor then
		boss.levelLabelBg:hide();
		self._layout.vars.njGrid:show();
		boss.bosslevel2:setText(level);
		if curValue and maxValue then
			boss.neijiaBar:setPercent(curValue / maxValue * 100)
		end
	else
		self._layout.vars.njGrid:hide();
		boss.levelLabelBg:show()
		boss.levelLabel:setText(level);
	end
end

function wnd_battleBossHp:updateSeletctBuff(buffs) -- 没用到
	self._selectbuff = buffs
	self._cleanbuff = true;
end

function wnd_battleBossHp:onHide()
	g_i3k_game_context:SetSelectName()
end
----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleBossHp.new();
		wnd:create(layout);
	return wnd;
end
