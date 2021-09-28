-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");

-------------------------------------------------------
wnd_steed_huanhua = i3k_class("wnd_steed_huanhua", ui.wnd_base)

function wnd_steed_huanhua:ctor()
	self._steedId = nil
end

function wnd_steed_huanhua:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	local widgets = self._layout.vars
	self._steedTable = {
		[1] = {model = widgets.model1, getLabel = widgets.getLabel1, btn = widgets.btn1, btnNameLabel = widgets.btnNameLabel1, useImg = widgets.useImg1},
		[2] = {model = widgets.model2, getLabel = widgets.getLabel2, btn = widgets.btn2, btnNameLabel = widgets.btnNameLabel2, useImg = widgets.useImg2},
		[3] = {model = widgets.model3, getLabel = widgets.getLabel3, btn = widgets.btn3, btnNameLabel = widgets.btnNameLabel3, useImg = widgets.useImg3},
	}
end

function wnd_steed_huanhua:setModel(ui,modelID)
	local mcfg = i3k_db_models[modelID];
	if mcfg then
		ui:setSprite(mcfg.path);
		ui:setSprSize(mcfg.uiscale);
		ui:playAction("show");
	end
end

function wnd_steed_huanhua:refresh(steedId)
	local steedCfg = i3k_db_steed_cfg[steedId]
	self._steedTable[1].huanhuaId = steedCfg.huanhuaInitId
	self._steedTable[2].huanhuaId = steedCfg.huanhuaMaxId
	self._steedTable[3].huanhuaId = steedCfg.huanhuaStoreId

	for i,v in ipairs(self._steedTable) do
		local huanhuaCfg = i3k_db_steed_huanhua[v.huanhuaId]
		local modelId = huanhuaCfg.modelId
		self:setModel(v.model, modelId)
		if huanhuaCfg.modelRotation ~= 0 then
			v.model:setRotation(huanhuaCfg.modelRotation)
		end
	end
	self._steedId = steedId
	self:setData(steedId)
end

function wnd_steed_huanhua:setData(steedId)
	steedId = steedId or self._steedId
	local steedInfo = g_i3k_game_context:getSteedInfoBySteedId(steedId)
	local info = g_i3k_game_context:getSteedShowIDs()
	local showId = g_i3k_game_context:getSteedCurShowID()
	for i,v in ipairs(self._steedTable) do
		local huanhuaCfg = i3k_db_steed_huanhua[v.huanhuaId]
		local actNeedId = i3k_db_steed_huanhua[v.huanhuaId].actNeedId
		local needCount = i3k_db_steed_huanhua[v.huanhuaId].needCount
		v.btn:setTag(v.huanhuaId)
		v.useImg:setVisible(showId==v.huanhuaId)

		self._layout.vars.item:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(actNeedId))
		self._layout.vars.itemIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(actNeedId, g_i3k_game_context:IsFemaleRole()))
		self._layout.vars.itemCount:setText("x" .. needCount)
		self._layout.vars.itemCount:setTextColor(g_i3k_get_cond_color(g_i3k_game_context:GetCommonItemCanUseCount(actNeedId) >= needCount))
		self._layout.vars.itemBtn:onClick(self, function()
			g_i3k_ui_mgr:ShowCommonItemInfo(actNeedId)
		end)

		if steedInfo then
			if i==1 then
				v.getLabel:setText(huanhuaCfg.name)
				v.btn:setVisible(showId~=v.huanhuaId)
				v.btn:onClick(self, self.huanhuaSkin, steedId)
			elseif i==2 then
				if info[v.huanhuaId] then
					v.getLabel:setText(huanhuaCfg.name)
					v.btnNameLabel:setText(string.format("%s", "幻化外形"))
					v.btn:onClick(self, self.huanhuaSkin, steedId)
				else
					v.getLabel:setText(huanhuaCfg.getMethod)
					v.btnNameLabel:setText(string.format("%s", "立即升星"))
					v.btn:onClick(self, self.riseStar, steedId)
				end
				v.btn:setVisible(showId~=v.huanhuaId and g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.steedfunction )
			else
				v.btn:setVisible(showId~=v.huanhuaId)
				if info[v.huanhuaId] then
					self._layout.vars.show:hide()
					self._layout.vars.item:hide()
					self._layout.vars.itemCount:hide()
					v.getLabel:setText(huanhuaCfg.name)
					v.btnNameLabel:setText(string.format("%s", "幻化外形"))
					v.btn:onClick(self, self.huanhuaSkin, steedId)
				elseif g_i3k_game_context:GetCommonItemCanUseCount(huanhuaCfg.actNeedId)>=huanhuaCfg.needCount and not info[v.huanhuaId] then
					self._layout.vars.show:hide()
					self._layout.vars.item:hide()
					self._layout.vars.itemCount:hide()
					v.getLabel:setText(huanhuaCfg.name)
					v.btnNameLabel:setText(string.format("%s", "启动"))
					local needValue = {needItem = {[huanhuaCfg.actNeedId] = huanhuaCfg.needCount}, steedId = steedId, huanhuaId = v.huanhuaId}
					v.btn:onClick(self, self.actSkin, needValue)
				else
					local can = self:isCanCollectAll(v.huanhuaId)
					local isCanCollectAll = self:isCanCollectAll(v.huanhuaId)
					self._layout.vars.show:setVisible(isCanCollectAll)
					self._layout.vars.item:setVisible(isCanCollectAll)
					self._layout.vars.itemCount:setVisible(isCanCollectAll)
					v.getLabel:setText(huanhuaCfg.getMethod)
					v.btnNameLabel:setText(string.format("%s", "去购买"))
					local actNeedCfg = g_i3k_db.i3k_db_get_common_item_cfg(actNeedId)
					v.btn:setVisible(actNeedCfg.showType ~= 0 or actNeedCfg.isBound ~= 0)
					v.btn:onClick(self, function ()
						g_i3k_logic:OpenVipStoreUI(actNeedCfg.showType,actNeedCfg.isBound, actNeedCfg.id)
					end)
				end
			end
		else
			v.getLabel:setText(huanhuaCfg.getMethod)
			v.btn:hide()
		end
	end
end

function wnd_steed_huanhua:isCanCollectAll(id)--是否能够集齐
	local _tmp_need = i3k_db_steed_huanhua[id].actNeedId
	local _tmp_need_count = i3k_db_steed_huanhua[id].needCount
	return g_i3k_game_context:GetCommonItemCanUseCount(_tmp_need ) < _tmp_need_count
end

function wnd_steed_huanhua:riseStar(sender, steedId)
	g_i3k_logic:OpenSteedStarUI(steedId)
	g_i3k_ui_mgr:CloseUI(eUIID_SteedHuanhua)
end

function wnd_steed_huanhua:actSkin(sender, needValue)
	local callback = function ()
		if self._steedTable then
			local widgets = self._steedTable[3]
			widgets.btnNameLabel:setText(string.format("%s", "幻化外形"))
			widgets.btn:onClick(self, self.huanhuaSkin, needValue.steedId)
			self._layout.vars.show:hide()
			self._layout.vars.item:hide()
			self._layout.vars.itemCount:hide()
		end
	end
	local id = 0
	local count = 0
	for i,v in pairs(needValue.needItem) do
		id = i
		count = v
	end
	local desc = i3k_get_string(287, g_i3k_db.i3k_db_get_common_item_name(id), count, i3k_db_steed_huanhua[sender:getTag()].name)
	local callfunc = function (isOk)
		if isOk then
			i3k_sbean.act_steed_skin(needValue.steedId, needValue.huanhuaId, callback)
		end
	end
	g_i3k_ui_mgr:ShowMessageBox2(desc, callfunc)
end

function wnd_steed_huanhua:huanhuaSkin(sender, steedId)
	local fightData = g_i3k_game_context:getSteedFightShowIDs()
	local huanhuaId = sender:getTag()
	local cfg = i3k_db_steed_huanhua[huanhuaId]
	local func = function()
		local hero = i3k_game_get_player_hero()
		if hero:IsOnRide() then
			local callback = function ()
				i3k_sbean.change_steed_show(huanhuaId, steedId, 1)
			end
			hero:SetRide(false, nil, callback)--正在骑乘，先下马然后换皮,再上马
		else
			i3k_sbean.change_steed_show(huanhuaId, steedId, 0)
		end
	end
	local isNeedLvl = g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.openLvl
	if cfg.fightSkinType == g_HS_SKIN_FIGHT and not fightData[huanhuaId] and isNeedLvl then
		local fun = (function(ok)
			if ok then
				func()
			end
		end)
		g_i3k_ui_mgr:ShowCustomMessageBox2("使用", "取消", i3k_get_string(1262), fun)
	else
		func()
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_steed_huanhua.new()
	wnd:create(layout, ...)
	return wnd;
end
