module(..., package.seeall)

local require = require;
local ui = require("ui/base")

-------------------------------------------------------
wnd_qiling = i3k_class("wnd_qiling", ui.wnd_base)


function wnd_qiling:ctor()

end

function wnd_qiling:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self,self.onCloseUI)
	widgets.helpBtn:onClick(self, self.onHelp)
end

function wnd_qiling:onShow()

end


function wnd_qiling:refresh(weaponID)
	self._weaponID = weaponID
	self:updateScroll()
end

function wnd_qiling:updateScroll()
	local info = g_i3k_game_context:getQilingData()
	local widgets = self._layout.vars
	local scroll = widgets.scroll
	scroll:removeAllChildren()
	local data = i3k_db_qiling_type
	for k, v in ipairs(data) do
		local ui = require("ui/widgets/qilingt")()
		ui.vars.nameImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.nameIcon))
		ui.vars.headImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.headIcon))
		ui.vars.infoBtn:onClick(self, self.onPropBtn2, k)
		if not next(info) then -- 如果是个空表，那么表示可以激活
			ui.vars.equipLabel:setText(i3k_get_string(1084))
			ui.vars.headImg:setImage(g_i3k_db.i3k_db_get_icon_path(4548))
			if not g_i3k_game_context:checkCanActiveQiling() then
				ui.vars.equipBtn:disable()
			end
			ui.vars.jindu:hide()
			scroll:addItem(ui)
		else
			if info[k] then
				if info[k].equipWeaponId == self:getSelectWeaponID() then
					ui.vars.equipBtn:disable()
					ui.vars.equipLabel:setText(i3k_get_string(1085))
				else
					ui.vars.equipBtn:onClick(self, self.onEquipBtn, k)
					ui.vars.equipLabel:setText(i3k_get_string(1086))
				end
				if info[k].equipWeaponId ~= 0 then
					if g_i3k_game_context:IsShenBingAwake(info[k].equipWeaponId) then
						ui.vars.weaponIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing_awake[info[k].equipWeaponId].awakeWeaponIcon))
					else
						ui.vars.weaponIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[info[k].equipWeaponId].icon))
					end
				end
				ui.vars.jiewei:setPercent(info[k].rank/i3k_db_qiling_type[k].transUpLevel*100)     --阶位
				ui.vars.mifa:setPercent(info[k].skillLevel/i3k_db_qiling_trans[k][i3k_db_qiling_type[k].transUpLevel].skillUpLevel*100) --秘法
				--ui.vars.jindu:setVisible(g_i3k_game_context:GetShenbingData()[self:getSelectWeaponID()] and g_i3k_game_context:GetShenbingData()[self:getSelectWeaponID()].slvl >=i3k_db_qiling_cfg.weaponStar) --未解锁
				scroll:addItem(ui)
			end
		end
	end
end


function wnd_qiling:getSelectWeaponID()
	return self._weaponID
end

-- 精修（激活）
-- function wnd_qiling:onPropBtn(sender, id)
-- 	i3k_sbean.activeQiling(self:getSelectWeaponID(), id)
-- end

-- 精修，不发协议
function wnd_qiling:onPropBtn2(sender, id)
	local info = g_i3k_game_context:getQilingData()
	if not next(info) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1087))
		return false
	end
	g_i3k_ui_mgr:OpenUI(eUIID_QilingProp)
	g_i3k_ui_mgr:RefreshUI(eUIID_QilingProp, self:getSelectWeaponID(), id)
	self:onCloseUI()
end

-- 装备神兵
function wnd_qiling:onEquipBtn(sender, id)
	local weaponId = self:getSelectWeaponID()
	local allShenbing = g_i3k_game_context:GetShenbingData()
	if not allShenbing[weaponId] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1088))
		return false
	end
	local needStars = i3k_db_qiling_cfg.weaponStar
	if allShenbing[weaponId].slvl < needStars then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1089, needStars))
		return false
	end
	local info = g_i3k_game_context:getQilingData()
	if not next(info) then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1090))
		return false
	end
	local equipWeaponId = info[id].equipWeaponId
	if equipWeaponId ~= 0 then
		local callback = function(ok)
			if ok then
				i3k_sbean.equipQiling(id, self:getSelectWeaponID())
			end
		end
		local weaponName = i3k_db_shen_bing[equipWeaponId].name
		local msg = i3k_get_string(1079, weaponName)
		g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
	else
		i3k_sbean.equipQiling(id, self:getSelectWeaponID())
	end
end


function wnd_qiling:onHelp(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(1080))
end

function wnd_create(layout, ...)
	local wnd = wnd_qiling.new();
		wnd:create(layout, ...);
	return wnd;
end
