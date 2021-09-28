-- npcHotel.lua  江湖客栈
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_npcHotel = i3k_class("wnd_npcHotel", ui.wnd_base)

local LAYER_JHKZT  = "ui/widgets/jhkzt" -- 头像控件
local LAYER_JHKZT2 = "ui/widgets/jhkzt2" -- 出售道具控件

function wnd_npcHotel:ctor()
    self._selectNpcId = 1--江湖客栈Npc对应的选中的NpcIndex
    self._npcWordRoot = nil
    self._npcWordTime = 0
end

function wnd_npcHotel:configure()
    self._layout.vars.close_btn:onClick(self, self.onCloseUI)
    self._layout.vars.add_coin:onClick(self , self.addCoinBtn)
    self._layout.vars.add_diamond:onClick(self, self.addDiamondBtn)
	self._layout.vars.detailBtn:onClick(self, self.onDetailBtnClick)
    self._layout.vars.cbt:onClick(self, function()
        g_i3k_logic:OpenActivityUI()
        g_i3k_ui_mgr:InvokeUIFunction(eUIID_Activity, "changeStateImpl", g_TREASURE_STATE)
    end)
	self._layout.anis.c_box:play()
end

function wnd_npcHotel:onShow()
    self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false), g_i3k_game_context:GetMoney(true), g_i3k_game_context:GetMoney(false))
end

function wnd_npcHotel:refresh()
	
end

function wnd_npcHotel:onUpdate(dTime)
    self:updateNpcWord(dTime)
end

-- InvokeUIFunction
function wnd_npcHotel:initHeadiconScroll(npcs)
    local power = i3k_game_get_player_hero():Appraise()
    local widget = self._layout.vars
    for i,v in ipairs(npcs) do
		local npcCfg = i3k_db_hostel_npc[i]
		local node = require(LAYER_JHKZT)()
		node.vars.powerLabel:setText(npcCfg.power)
		node.vars.needLabel:setVisible(power < npcCfg.power)
		node.vars.powerLabel:setVisible(power < npcCfg.power)
		node.vars.darkImg:setVisible(node.vars.powerLabel:isVisible())
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(npcCfg.iconID, true))
		node.vars.btn:setTag(i)
		node.vars.btn:onClick(self, self.onHeadiconBtn, i)
		node.vars.selectImg:hide()
		if i == self._selectNpcId then
			node.vars.selectImg:show()
			self:importNpcData(i)
		end
		if power < npcCfg.power then
			node.vars.icon:disable()
		end
		widget.scroll1:addItem(node)
	end
end

function wnd_npcHotel:importNpcData(id)
    self._selectNpcId = id
    local info = g_i3k_game_context:getNpcInfoById(id)
	local widget = self._layout
	widget.vars.wordRoot:hide()
	--帮助  --江湖
	widget.vars.helpBtn:onClick(self, function ()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(15166))
	end)
	local npcCfg = i3k_db_hostel_npc[id]
	ui_set_hero_model(widget.vars.model, npcCfg.modelId)
	widget.vars.model:onClick(self, self.clickModel, {id = id, widget = widget})

	widget.vars.nameLabel:setText(npcCfg.name)

	widget.vars.refreshBtn:setTag(id)
	widget.vars.refreshBtn:onClick(self, self.refreshChips, info.refreshTimes + 1)
	if info.refreshTimes >= g_MAX_REFRESH_TIMES then
		widget.vars.refreshBtn:disableWithChildren()
	else
		widget.vars.refreshBtn:enableWithChildren()
	end
	widget.vars.scroll2:setBounceEnabled(false)
	widget.vars.scroll2:removeAllChildren(true)
	for i,v in pairs(info.lib) do
		local chipCfg = i3k_db_treasure_chip[i]
		local node = require(LAYER_JHKZT2)()
		node.vars.newImg:setVisible(not g_i3k_game_context:getChipsIsHasBuyed(i))
		node.vars.gradeIcon:setImage(g_i3k_get_icon_frame_path_by_rank(chipCfg.rank))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(chipCfg.iconID))
		node.vars.countLabel:setText("x"..v)
		node.vars.nameLabel:setText(chipCfg.name)
		node.vars.nameLabel:setTextColor(g_i3k_get_color_by_rank(chipCfg.rank))
		node.vars.priceLabel:setText(chipCfg.needFreeMoney * v)
		node.vars.priceLabel:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetMoneyCanUse(true)>=(chipCfg.needFreeMoney * v)))
		node.vars.saleOut:setVisible(v==0)
        local haveCounts = g_i3k_game_context:getTreasureChipOwnCounts(i)
        local needCounts = chipCfg.needChipCount
        node.vars.ownCounts:setText("当前拥有:"..haveCounts.."/"..needCounts)
		node.vars.btn:setVisible(not node.vars.saleOut:isVisible())
		node.vars.btn:setTag(i)
		node.vars.btn:onClick(self, self.buyChips, {id = id, needCount = chipCfg.needFreeMoney * v, count = v})
		widget.vars.scroll2:addItem(node)
	end
	for i,v in ipairs(widget.vars.scroll1:getAllChildren()) do
		v.vars.selectImg:setVisible(i == id)
	end

	--设置友好度
	local canGetTimes = 0
	widget.vars.box:hide() -- 宝箱
	for i,v in ipairs(i3k_db_npc_prestige) do
		if info.fame < v.value then
			widget.vars.box:setVisible(canGetTimes - info.reward > 0)
			widget.vars.box:onClick(self, function ()
				i3k_sbean.get_npc_reward(id)
			end)
			widget.vars.percent:setPercent(info.fame / v.value*100)
			widget.vars.percentLabel:setText(info.fame.."/"..v.value)
			break
		end
		canGetTimes = canGetTimes + 1
		if not i3k_db_npc_prestige[i+1] then
			widget.vars.box:setVisible(canGetTimes - info.reward > 0)
			widget.vars.box:onClick(self, function ()
				i3k_sbean.get_npc_reward(id)
			end)
		end
		if not i3k_db_npc_prestige[i+1] and info.fame >= v.value then
			widget.vars.percent:setPercent(100)
			widget.vars.percentLabel:setText(v.value.."/"..v.value)
		end
	end
	if widget.vars.box:isVisible() then
		widget.anis.c_box:play()
	else
		widget.anis.c_box:stop()
	end
end

function wnd_npcHotel:clickModel(sender, needValue)
	local npcCfg = i3k_db_hostel_npc[needValue.id]
	local textId = npcCfg.text1
	local count = #i3k_db_dialogue[textId]
	local index = math.random(0, count)
	index = index==0 and 1 or math.ceil(index)
	local text = i3k_db_dialogue[textId][index].txt

	needValue.widget.vars.word:setText(text)
	needValue.widget.vars.wordRoot:show()
    self._npcWordRoot = needValue.widget.vars.wordRoot
	self._npcWordTime = 0
end

-- 将schedule替换为onUpdate方法
function wnd_npcHotel:updateNpcWord(dTime)
    if self._npcWordRoot then
        self._npcWordTime = self._npcWordTime + dTime
        if self._npcWordTime > 1.5 then
            self._npcWordRoot:hide()
            self._npcWordTime = 0
            self._npcWordRoot = nil
        end
    end
end

function wnd_npcHotel:updateMoney(diamondF, diamondR, coinF, coinR)
	self._layout.vars.diamond:setText(diamondF)
	self._layout.vars.diamondLock:setText(diamondR)
	self._layout.vars.coin:setText(i3k_get_num_to_show(coinF))
	self._layout.vars.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_npcHotel:addCoinBtn(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_npcHotel:addDiamondBtn(sender)
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_npcHotel:refreshChips(sender, times)
	if times > g_MAX_REFRESH_TIMES then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15162))
		return
	end
	local id = sender:getTag()
	local diamondTable = i3k_db_treasure_base.refreshNeedDiamond
	local needDiamond = diamondTable[times] or diamondTable[#diamondTable]

	local diamondCanUse = g_i3k_game_context:GetDiamondCanUse(false)
	if diamondCanUse < needDiamond then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15072))
	else
		local desc = i3k_get_string(15073, needDiamond, g_MAX_REFRESH_TIMES - times + 1)
		local callback = function (isOk)
			if isOk then
				local callfunc = function ()
					g_i3k_game_context:UseDiamond(needDiamond, false, AT_REFRESH_TREASURE_INFO)
				end
				i3k_sbean.refresh_treasure_npc(id, times, callfunc)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	end
end

function wnd_npcHotel:buyChips(sender, needValue)
	if needValue.needCount > g_i3k_game_context:GetMoneyCanUse(true) then
		g_i3k_ui_mgr:ShowMessageBox1(i3k_get_string(15071))
	else
		local chipId = sender:getTag()
		local callfunc = function ()
			g_i3k_game_context:UseMoney(needValue.needCount, true,AT_BUY_TREASURE_PIECES)
		end
		i3k_sbean.buy_treasure_chip(needValue.id, chipId, callfunc, needValue.count)
	end
end

function wnd_npcHotel:onHeadiconBtn(sender, i)
    local power = i3k_game_get_player_hero():Appraise()
    local npcCfg = i3k_db_hostel_npc[i]
    if power >= npcCfg.power then
        self:importNpcData(i)
    else
        g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15090))
    end
end

function wnd_npcHotel:onDetailBtnClick(sender)
	g_i3k_logic:OpenHotelDetailUI(self._selectNpcId)
end

function wnd_create(layout, ...)
	local wnd = wnd_npcHotel.new()
	wnd:create(layout, ...)
	return wnd;
end
