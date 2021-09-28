module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_battleShowExp = i3k_class("wnd_battleShowExp", ui.wnd_base)

local buffType2Icon = {
	[g_TEAM_BUFF_DAMAGE_ADD] = 8079,
	[g_TEAM_BUFF_DAMAGE_SUB] = 8078,
	[g_TEAM_BUFF_RESULT_EXP] = 8082,
	[g_TEAM_BUFF_RESULT_COIN] = 8081,
	[g_TEAM_BUFF_RESULT_ITEM] = 8083,
	[g_TEAM_BUFF_MONSTER_EXP] = 8080,
}
local BG_BUFF_ICON = 1 --buff背景图片
local BG_EXP_ICON = 2 --经验背景图片
local EXP_ICON = 3 --经验图片
local SHOW_EXP_CNT = 5 -- 经验值同屏显示最大个数
local SHOW_BUFF_CNT = 5 -- buff同屏显示最大个数
local SHOW_SUPERWEAPON_CNT = 3 -- 神兵经验值同屏显示最大个数
function wnd_battleShowExp:ctor()
    self._itemList = {[g_BATTLE_SHOW_EXP] = {}, [g_BATTLE_SHOW_BUFF] = {}, [g_BATTLE_SHOW_SUPERWEAPON] = {}}
    self._coolDownList = {[g_BATTLE_SHOW_EXP] = 0, [g_BATTLE_SHOW_BUFF] = 0, [g_BATTLE_SHOW_SUPERWEAPON] = 0}
	self._currIndexList = {[g_BATTLE_SHOW_EXP] = 1, [g_BATTLE_SHOW_BUFF] = 1, [g_BATTLE_SHOW_SUPERWEAPON] = 1}
	self._needPosList = {[g_BATTLE_SHOW_EXP] = nil, [g_BATTLE_SHOW_BUFF] = nil, [g_BATTLE_SHOW_SUPERWEAPON] = nil}
	self._orignPosList = {[g_BATTLE_SHOW_EXP] = nil, [g_BATTLE_SHOW_BUFF] = nil, [g_BATTLE_SHOW_SUPERWEAPON] = nil}
	self._widgetList = {[g_BATTLE_SHOW_EXP] = nil, [g_BATTLE_SHOW_BUFF] = nil, [g_BATTLE_SHOW_SUPERWEAPON] = nil}
	self._addFuncList = {[g_BATTLE_SHOW_EXP] = self.addExpShow, [g_BATTLE_SHOW_BUFF] = self.addBuffshow, [g_BATTLE_SHOW_SUPERWEAPON] = self.addSuperWeaponShow}
end
function wnd_battleShowExp:configure()
	self._widgetList[g_BATTLE_SHOW_EXP] = self:initExpWidget()
	self._widgetList[g_BATTLE_SHOW_BUFF] = self:initBuffWidget()
	self._widgetList[g_BATTLE_SHOW_SUPERWEAPON] = self:initSuperWeaponWidget()
end
function wnd_battleShowExp:refresh(typeID, dataList)
	local addFunc = self._addFuncList[typeID]
	addFunc(self, dataList)
end
function wnd_battleShowExp:onUpdate(dTime)
    self:onUpdateExpShow(dTime)
    self:onUpdateBuffShow(dTime)
	self:onUpdateSuperWeaponShow(dTime)
end
function wnd_battleShowExp:initExpWidget()
	--经验显示相关
	local explist = {exptext = {}, expbg = {}}
	for i = 1, SHOW_EXP_CNT do
		explist.exptext[i] = self._layout.vars['exp'..i]
		explist.exptext[i]:setText("")
		explist.expbg[i] = self._layout.vars['expbg'..i]
		explist.expbg[i]:setVisible(false)
	end
	return explist
end
function wnd_battleShowExp:initBuffWidget()
	--buff显示相关
	local bufflist = {bufftext = {}, buffbg = {}, buffIcon = {}}
	for i = 1, SHOW_BUFF_CNT do
		bufflist.bufftext[i] = self._layout.vars['exp'..(i + 5)]
		bufflist.bufftext[i]:setText("")
		bufflist.buffbg[i] = self._layout.vars['expbg'..(i + 5)]
		bufflist.buffbg[i]:setVisible(false)
		bufflist.buffIcon[i] = self._layout.vars['expIcon'..(i + 5)]
	end
	return bufflist
end
function wnd_battleShowExp:initSuperWeaponWidget()
	--神兵熟练度相关
	local superWeaponList = {superWeaponText = {}, superWeaponBG = {}, superWeaponIcon = {}}
	for i=1, SHOW_SUPERWEAPON_CNT do
		superWeaponList.superWeaponText[i] = self._layout.vars['exp' .. (i + 10)]
		superWeaponList.superWeaponText[i]:setText("")
		superWeaponList.superWeaponBG[i] = self._layout.vars['expbg' .. (i + 10)]
		superWeaponList.superWeaponBG[i]:setVisible(false)
		superWeaponList.superWeaponIcon[i] = self._layout.vars['expIcon' .. (i + 10)] 
	end
	return superWeaponList
end
function wnd_battleShowExp:addExpShow(dataList)
	local offlineExp = dataList.oExp or 0
	local drugExp = dataList.dExp or 0
	local wizardexp = dataList.wExp or 0
	local cityExp = dataList.cexp or 0
	local sectZoneSpiritexp = dataList.sectZoneSpiritexp or 0
	local globalWorldCardAdd = dataList.gwcExp or 0
	local swornAdd = dataList.swornAdd or 0
	local extraExp = offlineExp + drugExp + wizardexp + cityExp + sectZoneSpiritexp + globalWorldCardAdd + swornAdd 
	table.insert(self._itemList[g_BATTLE_SHOW_EXP], {['iexp'] = dataList.iexp, ['extraExp'] = extraExp})
end
function wnd_battleShowExp:addBuffshow(dataList)
	table.insert(self._itemList[g_BATTLE_SHOW_BUFF], dataList)
end
function wnd_battleShowExp:addSuperWeaponShow(dataList)
	local cfg = i3k_db_shen_bing[dataList.id]
	local isAwake = g_i3k_game_context:IsShenBingAwake(dataList.id)
	local icon = isAwake and i3k_db_shen_bing_awake[dataList.id].awakeWeaponIcon or cfg.icon
	if dataList.isFull then
		table.insert(self._itemList[g_BATTLE_SHOW_SUPERWEAPON], {['icon'] = icon, ['isFull'] = true})
	else
		--当前神兵熟练度百分比，保留到小数点后一位，向下取整，取整后结果为0.0%时显示0.1%
		local proficinecy = math.floor(dataList.masterExp * 1000 / cfg.proficinecyMax) / 10
		proficinecy = proficinecy == 0 and 0.1 or proficinecy
		table.insert(self._itemList[g_BATTLE_SHOW_SUPERWEAPON], {['icon'] = icon, ['exp'] = dataList.exp, ['proficinecy'] = proficinecy})
	end
end
function wnd_battleShowExp:removeShowItem(typeID, cnt)
	table.remove(self._itemList[typeID], 1)
	self._coolDownList[typeID] = 0.2
	self._currIndexList[typeID] = self._currIndexList[typeID] % cnt + 1
end
function wnd_battleShowExp:onUpdateExpShow(dTime)
	local expList = self._itemList[g_BATTLE_SHOW_EXP]
	if #expList > 0 then
		self._coolDownList[g_BATTLE_SHOW_EXP] = self._coolDownList[g_BATTLE_SHOW_EXP] - dTime
		local widget = self._widgetList[g_BATTLE_SHOW_EXP]
		local coolDown = self._coolDownList[g_BATTLE_SHOW_EXP]
		local currIndex = self._currIndexList[g_BATTLE_SHOW_EXP]
		if coolDown <= 0 then
			widget.expbg[currIndex]:setOpacity(255)
			widget.expbg[currIndex]:setVisible(true);
			if not self._orignPosList[g_BATTLE_SHOW_EXP] or not self._needPosList[g_BATTLE_SHOW_EXP] then
				local pos = widget.expbg[currIndex]:getPosition()
				self._orignPosList[g_BATTLE_SHOW_EXP] = {x = pos.x, y = pos.y}
				self._needPosList[g_BATTLE_SHOW_EXP] = {x = pos.x, y = pos.y + widget.expbg[currIndex]:getContentSize().height * SHOW_EXP_CNT}
			end
			local strDesc = string.format("+%s", expList[1].iexp)
			if expList[1].extraExp ~= 0 then
				strDesc = string.format("+%s(+%s)", expList[1].iexp, expList[1].extraExp)
			end
			widget.expbg[currIndex]:stopAllActions()
			widget.exptext[currIndex]:setText(strDesc)
			widget.expbg[currIndex]:setPosition(self._orignPosList[g_BATTLE_SHOW_EXP])
			local callbackFunc = function ()
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updataExpProgress",g_i3k_game_context:GetLevelExp())
				g_i3k_ui_mgr:InvokeUIFunction(eUIID_BattleBase,"updataOfflineExpProgress", g_i3k_game_context:GetLevelExp())
			end
			local move = cc.MoveTo:create(0.8, self._needPosList[g_BATTLE_SHOW_EXP])
			local fadeOut = cc.FadeOut:create(0.4)
			local spawn = cc.Sequence:create(move, fadeOut)
            local seq = cc.Sequence:create(spawn, cc.CallFunc:create(callbackFunc) )
            --cc.Spawn的几个动作是同步执行的，cc.Sequence则是顺序执行各个动作的.
            --使用这样的嵌套动作，能在播放完 Spawn 动作之后执行关闭界面的操作
			widget.expbg[currIndex]:runAction(seq)
			self:removeShowItem(g_BATTLE_SHOW_EXP, SHOW_EXP_CNT)
		end
	end
end
function wnd_battleShowExp:onUpdateBuffShow(dTime)
	local buffList = self._itemList[g_BATTLE_SHOW_BUFF]
	if #buffList > 0 then
		self._coolDownList[g_BATTLE_SHOW_BUFF] = self._coolDownList[g_BATTLE_SHOW_BUFF] - dTime
		local widget = self._widgetList[g_BATTLE_SHOW_BUFF]
		local coolDown = self._coolDownList[g_BATTLE_SHOW_BUFF]
		local currIndex = self._currIndexList[g_BATTLE_SHOW_BUFF]
		if coolDown <= 0 then
			widget.buffbg[currIndex]:setOpacity(255)
			widget.buffbg[currIndex]:setVisible(true);
			if not self._orignPosList[g_BATTLE_SHOW_BUFF] or not self._needPosList[g_BATTLE_SHOW_BUFF] then
				local pos = widget.buffbg[currIndex]:getPosition()
				self._orignPosList[g_BATTLE_SHOW_BUFF] = {x = pos.x, y = pos.y}
				self._needPosList[g_BATTLE_SHOW_BUFF] = {x = pos.x, y = pos.y + widget.buffbg[currIndex]:getContentSize().height * SHOW_BUFF_CNT}
			end
			local buffType = buffList[1].buffType
			local buffName = i3k_db_team_buff[buffType].name
			local strDesc = string.format("%s:+%s%%", buffName, buffList[1].buffValue)
			widget.buffIcon[currIndex]:setImage(g_i3k_db.i3k_db_get_icon_path(buffType2Icon[buffType]))
			widget.buffbg[currIndex]:stopAllActions()
			widget.bufftext[currIndex]:setText(strDesc)
			widget.buffbg[currIndex]:setPosition(self._orignPosList[g_BATTLE_SHOW_BUFF])
			local callbackFunc = function ()
			end
			local move = cc.MoveTo:create(0.8, self._needPosList[g_BATTLE_SHOW_BUFF])
			local fadeOut = cc.FadeOut:create(0.4)
			local spawn = cc.Sequence:create(move, fadeOut)
            local seq = cc.Sequence:create(spawn, cc.CallFunc:create(callbackFunc) )
            --cc.Spawn的几个动作是同步执行的，cc.Sequence则是顺序执行各个动作的.
            --使用这样的嵌套动作，能在播放完 Spawn 动作之后执行关闭界面的操作
			widget.buffbg[currIndex]:runAction(seq)
			self:removeShowItem(g_BATTLE_SHOW_BUFF, SHOW_BUFF_CNT)
		end
	end
end
function wnd_battleShowExp:onUpdateSuperWeaponShow(dTime)
	local superWeaponList = self._itemList[g_BATTLE_SHOW_SUPERWEAPON]
	if #superWeaponList > 0 then
		self._coolDownList[g_BATTLE_SHOW_SUPERWEAPON] = self._coolDownList[g_BATTLE_SHOW_SUPERWEAPON] - dTime
		local widget = self._widgetList[g_BATTLE_SHOW_SUPERWEAPON]
		local coolDown = self._coolDownList[g_BATTLE_SHOW_SUPERWEAPON]
		local currIndex = self._currIndexList[g_BATTLE_SHOW_SUPERWEAPON]
		if coolDown <= 0 then
			widget.superWeaponBG[currIndex]:setOpacity(255)
			widget.superWeaponBG[currIndex]:setVisible(true);
			if not self._orignPosList[g_BATTLE_SHOW_SUPERWEAPON] or not self._needPosList[g_BATTLE_SHOW_SUPERWEAPON] then
				local pos = widget.superWeaponBG[currIndex]:getPosition()
				self._orignPosList[g_BATTLE_SHOW_SUPERWEAPON] = {x = pos.x, y = pos.y}
				self._needPosList[g_BATTLE_SHOW_SUPERWEAPON] = {x = pos.x, y = pos.y + widget.superWeaponBG[currIndex]:getContentSize().height * SHOW_SUPERWEAPON_CNT}
			end
			widget.superWeaponIcon[currIndex]:setImage(g_i3k_db.i3k_db_get_icon_path(superWeaponList[1].icon))
			widget.superWeaponBG[currIndex]:stopAllActions()
			if superWeaponList[1].isFull then
				widget.superWeaponText[currIndex]:setText(i3k_get_string(18225))
			else
				widget.superWeaponText[currIndex]:setText(i3k_get_string(18184, superWeaponList[1].exp, superWeaponList[1].proficinecy))
			end
			widget.superWeaponBG[currIndex]:setPosition(self._orignPosList[g_BATTLE_SHOW_SUPERWEAPON])
			local callbackFunc = function ()
			end
			local move = cc.MoveTo:create(0.8, self._needPosList[g_BATTLE_SHOW_SUPERWEAPON])
			local fadeOut = cc.FadeOut:create(0.4)
			local spawn = cc.Sequence:create(move, fadeOut)
            local seq = cc.Sequence:create(spawn, cc.CallFunc:create(callbackFunc) )
			widget.superWeaponBG[currIndex]:runAction(seq)
			self:removeShowItem(g_BATTLE_SHOW_SUPERWEAPON, SHOW_SUPERWEAPON_CNT)
		end
	end
end



function wnd_create(layout)
	local wnd = wnd_battleShowExp.new();
		wnd:create(layout);
	return wnd;
end
