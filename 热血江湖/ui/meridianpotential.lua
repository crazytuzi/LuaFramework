-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------

wnd_meridianPotential = i3k_class("wnd_meridianPotential",ui.wnd_base)

function wnd_meridianPotential:ctor()
	self.meridianId = 0
	self.holes = nil
	self.geaSea = 0
end

function wnd_meridianPotential:configure(...)
	-- local widgets = self._layout.vars
	-- widgets.geaSeaTips:onClick(selef, self.opentips)
	self:initWidgets()
end

function wnd_meridianPotential:initWidgets()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI, function()
		g_i3k_ui_mgr:InvokeUIFunction(eUIID_Meridian, "PotentiaRed")
	end)
	widgets.geaSeaTips:onClick(selef, self.opentips)
	self.canvas = widgets.canvas

	self.power = widgets.power
	self.descTotal = widgets.descTotal
	self.scroll = widgets.scroll
	self.canvasimg = widgets.canvasimg
	self.meridiansTxt = {}
	for i = 1 , 5 do
		self.meridiansTxt[i] = {
			meridianTxt = widgets["meridian"..i],
			energyTxt = widgets["energyTxt"..i],
			energyTxt1 = widgets["energyTxt"..i..i],
			firstArgsBg = widgets["firstArgsBg"..i]  --满级效果
		}
	end
end

function wnd_meridianPotential:getAttrTxt(attr)
	local str = {}
	for i,v in ipairs(attr) do
		if v.id > 0 then
			table.insert(str,i3k_db_prop_id[v.id].desc.."+"..i3k_get_prop_show(v.id, v.value))
		end
	end
	if #str == 0 then
		return "无属性提升"
	else
		return table.concat(str,",")
	end
end

function wnd_meridianPotential:refresh(meridianId, holes)
	self.meridianId = meridianId
	self.holes = holes.holes

	local cfg = i3k_db_meridians
	self.geaSea = 0
	local meridiansCfg = cfg.meridians[self.meridianId]
	local acupIds = meridiansCfg.acupuncturePointIds
    local flay =true
	local drawPercent = {}
	for i=1,#acupIds do
		drawPercent[i] = 0 -- 顺时针逆时针转换
	end
	for k,v in ipairs(acupIds) do
		if k == #acupIds then
			self.geaSea = self.geaSea + self.holes[v].energy*self.holes[acupIds[1]].energy
		else
			self.geaSea = self.geaSea + self.holes[v].energy*self.holes[acupIds[k + 1]].energy
		end
		local acupCfg = cfg.acupuncturePoint[v]
		drawPercent[k] =  (self.holes[v].energy + cfg.common.showParameter) / (acupCfg.upperLimit + cfg.common.showParameter)
		self.meridiansTxt[k].energyTxt:setText(self.holes[v].energy)
		self.meridiansTxt[k].energyTxt1:setText(acupCfg.upperLimit)
		self.meridiansTxt[k].meridianTxt:setText(acupCfg.name)
		self.meridiansTxt[k].firstArgsBg:setImage(self.holes[v].energy==acupCfg.upperLimit and g_i3k_db.i3k_db_get_icon_path(7261) or g_i3k_db.i3k_db_get_icon_path(7260))
	    if self.holes[v].energy~=acupCfg.upperLimit then
            flay=false
        end
    end
	self.geaSea = math.floor( math.sqrt(self.geaSea) *cfg.common.areasFactor)
	self.descTotal:setText(string.format("%s气海:%s",meridiansCfg.name, self.geaSea))
	self.canvas:drawing(drawPercent)
    self.canvas:setVisible(not flay)
    self.canvasimg:setImage(g_i3k_db.i3k_db_get_icon_path(flay and 7259 or 7258 ) )--潜能气海max
	self:updateScroll()
end

function wnd_meridianPotential:updateScroll()
	local rankIcon = i3k_db_meridians.common.rankIcon
	local potCfg = i3k_db_meridians.potentia
	local potential = g_i3k_game_context:getMeridianPotential()
	for i , v in ipairs(i3k_db_meridians.meridians[self.meridianId].potentialIds) do
		local node = require("ui/widgets/qiannengt"	)()
		local lvl = potential[v] or 0
		local cfg = potCfg[v][lvl]
		self.scroll:addItem(node)
		node = node.vars
		node.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.icon))
		node.bg:setImage(g_i3k_db.i3k_db_get_icon_path(rankIcon[cfg.rank]))
		node.name:setText(cfg.name)
		node.btn:onClick(self, self.openUplvl, v)
		node.btnjh:onClick(self, self.openUplvl, v)
	end
	self:updateScrollItem()
end
function wnd_meridianPotential:isCanUpLvl(nextCfg)
	if not nextCfg then
		return false
	end

	local itemEnough = true
	for i,v in ipairs(nextCfg.needItem) do
		if v.id > 0 and g_i3k_game_context:GetCommonItemCanUseCount(v.id) < v.count then
			itemEnough = false
			break
		end
	end
	return itemEnough and self.geaSea >= nextCfg.gasSea
end

function wnd_meridianPotential:openUplvl(sender,potentialId)
	local currlvl = g_i3k_game_context:getMeridianPotentialLvl(potentialId)
	if not i3k_db_meridians.potentia[potentialId][currlvl + 1] then
		return g_i3k_ui_mgr:PopupTipMessage("您已经达到最高级")
	end
	g_i3k_ui_mgr:OpenUI(eUIID_MeridianPotentialUp)
	g_i3k_ui_mgr:RefreshUI(eUIID_MeridianPotentialUp, self.meridianId, potentialId, self.geaSea)
end

function wnd_meridianPotential:updateScrollItem()
	local items = self.scroll:getAllChildren()
	local potCfg = i3k_db_meridians.potentia
	local potentialIds = i3k_db_meridians.meridians[self.meridianId].potentialIds
	local potential = g_i3k_game_context:getMeridianPotential()
	local power = 0
	for i,node in ipairs(items) do
		local potId = potentialIds[i]
		local lvl = potential[potId] or 0
		local cfg = potCfg[potId][lvl]
		if lvl == 0 then
			node.vars.btn:hide()
		    node.vars.btnjh:show()
			--node.vars.upLvl:setText("激活")
			node.vars.lvl:setText(lvl + 1)
			local ncfg = potCfg[potId][lvl + 1]
			node.vars.desc:setText(ncfg.desc)
			if ncfg.combatValue > 0 then
				node.vars.specialIcon:hide()
				node.vars.power:setText(ncfg.combatValue)
			else
				node.vars.power:hide()
			end
		else
			node.vars.btn:show()
		    node.vars.btnjh:hide()
			if not potCfg[potId][lvl+1] then
				node.vars.upLvl:setText("已满级")
				-- node.vars.btn:disable()
			else
				node.vars.upLvl:setText("升级")
			end
			node.vars.lvl:setText(lvl)
			node.vars.desc:setText(cfg.desc)
			if cfg.combatValue > 0 then
				node.vars.specialIcon:hide()
				node.vars.power:setText(cfg.combatValue)
			else
				node.vars.power:hide()
			end
		end
		node.vars.red:setVisible(self:isCanUpLvl(potCfg[potId][lvl+1]))
		node.vars.jhred:setVisible(self:isCanUpLvl(potCfg[potId][lvl+1]))
		power = power + cfg.combatValue
	end
	self.power:setText(power)
end

function wnd_meridianPotential:opentips()
	g_i3k_ui_mgr:OpenUI(eUIID_MeridianPulse)
	g_i3k_ui_mgr:RefreshUI(eUIID_MeridianPulse, {name = "气海", desc = i3k_get_string(16891)})
end

function wnd_create(layout)
	local wnd = wnd_meridianPotential.new()
	wnd:create(layout)
	return wnd
end
