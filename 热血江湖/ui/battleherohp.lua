module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_battleHeroHp = i3k_class("wnd_battleHeroHp", ui.wnd_base)
local LAYER_BUFF = "ui/widgets/bufft"
local BUFF_DRUG_ICON = 4371
function wnd_battleHeroHp:ctor()
    self._selfbuffupdate_time = 0
    self._isBuffMoveDown = false
    self._neishangCurValue = 0
	self._neishangMaxValue = 0
end

function wnd_battleHeroHp:configure()
    local boss = {}--------BOSS
    self._widgets = {}
	boss.root = self._layout.vars.boss--------BOSS__控制显隐
	boss.icon = self._layout.vars.bosstx--------BOSS头像Image
	boss.nameLabel = self._layout.vars.bossName--------BOSS名字Label
	boss.bloodLabel = self._layout.vars.bossxl--------BOSS血量显示的Label
	boss.levelLabel = self._layout.vars.bosslevel--------BOSS等级Label
	boss.bloodBar = self._layout.vars.bossxt--------BOSS最上层血量LoadingBar
	boss.bloodNext = self._layout.vars.xd--------BOSS下层血量Image
	boss.bossHead = self._layout.vars.bossHead
	self._widgets.boss = boss
	--选中人物、选中npc使用的是和boss相同的UI控件
    -- 修改，选中玩家为新的界面，头像比boss稍大
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

    self._buffDrugs = {}  --buff药数据
end

function wnd_battleHeroHp:refresh()
end

function wnd_battleHeroHp:openInhurtUI(isOpen)
	if isOpen and not self._isBuffMoveDown then
		local buffsNode = self._layout.vars.buffbar2
		local yAbOffset = 10 --编辑器内设定值
		local yAbSizeY = 360
		local yfactor = yAbOffset / yAbSizeY
		local yRealOffset = buffsNode:getParent():getContentSize().height * yfactor
		local tmpPos = buffsNode:getPosition()
		buffsNode:setPosition(tmpPos.x, tmpPos.y - yRealOffset)
		self._layout.vars.neishangNode:setVisible(true)
		self._isBuffMoveDown = true
	end
end

function wnd_battleHeroHp:onUpdate(dTime)
    self:onUpdatebuff(dTime)
    --self:openInhurtUI(g_i3k_game_context:GetLevel() >= i3k_db_wujue.inhurtLevel)
end

function wnd_battleHeroHp:onUpdatebuff(dTime)
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
function wnd_battleHeroHp:Clearbuff()
		-- self._widgets.buff.mybuff:removeAllChildren()
		self._widgets.buff.selbuff:removeAllChildren()
end
function wnd_battleHeroHp:updatetargetbuff()
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
	if g_i3k_game_context:IsShowBuffDrugIcon(true) then
		count = 1
		children[count].vars.bt:setTouchEnabled(false)
		children[count].vars.bt:hide()

		children[count].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(BUFF_DRUG_ICON))
		children[count].vars.bt:onClick(self, self.onBuffDrugSelect, g_NORMAL_BUFF_DRUG)
		children[count].vars.bt:show()

		for i = 2 ,5 do
			count = count + 1
			children[count].vars.bt:setTouchEnabled(false)
			children[count].vars.bt:hide()
			if i - 1 <= targetbuffcount then
				children[count].vars.grade_icon:setImage(g_i3k_db.i3k_db_get_icon_path(self._bufflist[3][i - 1].iconID))
				children[count].vars.bt:setTag(count+9)
				if self._selectbuff[self._bufflist[3][i - 1].id] < 3000 and  self._selectbuff[self._bufflist[3][i - 1].id] > 0 then
					--TODO闪烁特效
				end
				children[count].vars.bt:onClick(self, self.onBuffSelect)
				children[count].vars.bt:show()
			end
		end
	else
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

function wnd_battleHeroHp:onBuffSelect(sender)
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

function wnd_battleHeroHp:onBuffDrugSelect(sender, buffType)
	local isOther = true
	local pos = sender:getPosition()
	pos = sender:getParent():convertToWorldSpace(pos)

	g_i3k_ui_mgr:CloseUI(eUIID_BuffDrugTips)
	g_i3k_ui_mgr:OpenUI(eUIID_OtherBuffDrugTips)
	g_i3k_ui_mgr:RefreshUI(eUIID_OtherBuffDrugTips, isOther, pos, buffType)
end

-- -- 更新boss 血条
-- function wnd_battleHeroHp:updateTargetMonster(monsterId, curHp, maxHp, buffs) -- InvokeUIFunction
-- 	-- local monster = self._widgets.monster
-- 	local boss = self._widgets.boss
-- 	local monsterName = g_i3k_db.i3k_db_get_monster_sect_name(monsterId)
-- 	local isBoss = g_i3k_db.i3k_db_get_monster_is_boss(monsterId)
-- 	boss.root:setTag(isBoss and 1 or 0)
-- 	boss.icon:setImage(g_i3k_db.i3k_db_get_monster_head_icon_path(monsterId))
-- 	boss.nameLabel:setText(monsterName)
-- 	boss.levelLabel:hide()
-- 	-- boss.root:setVisible(isBoss)
-- 	self:updateSeletctBuff(buffs)
-- 	-- monster.nameLabel:setText(monsterName)
-- 	-- monster.root:setVisible(not isBoss)
-- 	self:updateTargetHp(curHp, maxHp)
-- end

function wnd_battleHeroHp:updateTargetRole(roleId, headIcon, name, level, curHp, maxHp, buffs, bwType, isMulHorse,sectID, gender, headBorder, buffDrugs, curInternalInjuryDamage, maxInternalInjuryDamage)
	local widgets = self._widgets.selectRole
	widgets.root:setTag(0)
	widgets.icon:setImage(g_i3k_db.i3k_db_get_role_head_icon(roleId, headIcon))
	widgets.nameLabel:setText(name)
	widgets.levelLabel:setText(level)
	widgets.levelLabel:show()
	widgets.root:show()
	widgets.bossHead:setImage(g_i3k_get_head_bg_path(bwType, headBorder))
	self:updateSeletctBuff(buffs)
	self:updateBuffDrug(buffDrugs)
	-- self._widgets.monster.root:hide()

	self:updateTargetHp(curHp, maxHp)
	widgets.icon:onClick(self, self.onBossTxClicked, {roleId = roleId, isMulHorse = isMulHorse,sectID = sectID, gender = gender,name = name, level=level})
	self:openInhurtUI(roleId >= i3k_db_wujue.inhurtLevel)
	if curInternalInjuryDamage and maxInternalInjuryDamage then
		self._layout.vars.neishangBar:setPercent(curInternalInjuryDamage / maxInternalInjuryDamage * 100)
	end
end

function wnd_battleHeroHp:onBossTxClicked(sender, data)
	local roleId = data.roleId
	if g_i3k_db.i3k_db_get_is_open_role_menu() and (roleId and roleId > 0) then
		local parent = sender:getParent()
		local pos = sender:getPosition()
		local width = sender:getContentSize().width
		pos = parent:convertToWorldSpace(cc.p(pos.x+width/2, pos.y))
		if roleId then
			local checkTeamId = i3k_sbean.team_role_query_req.new()
			checkTeamId.roleId = roleId
			checkTeamId.pos = pos
			checkTeamId.targetId = roleId
			checkTeamId.isMulHorse = data.isMulHorse
			checkTeamId.openId = eUIID_Wjxx
			checkTeamId.sectID = data.sectID
			checkTeamId.gender = data.gender
			checkTeamId.name = data.name
			checkTeamId.level = data.level
			i3k_game_send_str_cmd(checkTeamId, "team_role_query_res")
		end
	end
end

function wnd_battleHeroHp:updateTargetMercenary(id, level, name, curHp, maxHp, buffs) -- InvokeUIFunction
	-- self._widgets.monster.root:hide()
	local mercenary = self._widgets.boss
	self:updateSeletctBuff(buffs)
	mercenary.root:setTag(0)
	local iconId = g_i3k_db.i3k_db_get_head_icon_id(id)
	mercenary.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId))
	mercenary.levelLabel:setText(level)
	mercenary.nameLabel:setText(name)
	self:updateTargetHp(curHp, maxHp)
	mercenary.root:show()
end

-- 点击npc触发非任务对话
function wnd_battleHeroHp:updateTargetNPC(id, name, curhp, maxhp, mId, mValue)
	local monster = self._widgets.monster
	local npc = self._widgets.npc
	local mosterid = i3k_db_npc[id].monsterID;
	npc.root:setTag(0)
	local iconId = g_i3k_db.i3k_db_get_head_icon_id(mosterid)
	npc.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconId))
	npc.nameLabel:setText(name)
	npc.levelLabel:hide()
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
function wnd_battleHeroHp:updateTargetHp(curHp, maxHp, isNpc)
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

function wnd_battleHeroHp:updateInternalInjuryDamage(curInternalInjuryDamage, maxInternalInjuryDamage)
	self._neishangCurValue = curInternalInjuryDamage
	self._neishangMaxValue = maxInternalInjuryDamage
	self._layout.vars.neishangBar:setPercent(self._neishangCurValue / self._neishangMaxValue * 100)
end
function wnd_battleHeroHp:updateSeletctBuff(buffs) -- 没用到
	self._selectbuff = buffs
	self._cleanbuff = true;
end

function wnd_battleHeroHp:updateBuffDrug(buffDrugs)
	self._buffDrugs = buffDrugs
	g_i3k_game_context:SetOtherPlayerBuffDrugData(buffDrugs)
end

function wnd_battleHeroHp:onHide()
	--移除选中数据
	g_i3k_game_context:SetSelectedRoleData(nil)
	g_i3k_game_context:SetSelectName()
	g_i3k_ui_mgr:CloseUI(eUIID_OtherBuffDrugTips)
end
----------------------------------------
function wnd_create(layout)
	local wnd = wnd_battleHeroHp.new();
		wnd:create(layout);
	return wnd;
end
