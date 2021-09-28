local single = require "ui.singletondialog"

local RingMake = {}
setmetatable(RingMake, single)
RingMake.__index = RingMake

local modenum = 4
local previewnum = 5
function RingMake.new()
	local self = {}
	setmetatable(self, RingMake)
	function self.GetLayoutFileName()
		return "ringmake.layout"
	end
	require "ui.dialog".OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.modes = {}
	self.selects = {}
	for i = 1, modenum do
		local wndname = i == 1 and "ringmake/left/item" or "ringmake/left/item"..(i-1)
		local wnd = winMgr:getWindow(wndname)
		wnd:subscribeEvent("MouseClick", RingMake.HandleModeClicked, self)
		wnd:setID(i)
		
		table.insert(self.modes, wnd)
		
		wndname = "ringmake/seclect"..(i-1)
		wnd = winMgr:getWindow(wndname)
		wnd:setVisible(false)
		table.insert(self.selects, wnd)
	end
	self.previews = {}
	for i = 1, previewnum do
		local preview = {}
		local wndname = "ringmake/right/top/item"..(i - 1)
		preview.item = CEGUI.toItemCell(winMgr:getWindow(wndname))
		require "utils.mhsdutils".SetWindowShowtips(preview.item)
		wndname = "ringmake/right/top/name"..(i - 1)
		preview.name = winMgr:getWindow(wndname)
		table.insert(self.previews, preview)
	end
	self.item1 = {}
	self.item1.item = CEGUI.toItemCell(winMgr:getWindow("ringmake/right/bot/shi"))
	require "utils.mhsdutils".SetWindowShowtips(self.item1.item)
	self.item1.name = winMgr:getWindow("ringmake/right/bot/name2")
	self.item2 = {}
	self.item2.item = CEGUI.toItemCell(winMgr:getWindow("ringmake/right/bot/zhu"))
	require "utils.mhsdutils".SetWindowShowtips(self.item2.item)
	self.item2.name = winMgr:getWindow("ringmake/right/bot/name1")
	self.paper = {}
	self.paper.item = CEGUI.toItemCell(winMgr:getWindow("ringmake/right/bot/tu"))
--	require "utils.mhsdutils".SetWindowShowtips(self.paper.item)
	self.paper.item:subscribeEvent("MouseClick", RingMake.HandlePaperWndClicked, self)
	self.paper.name = winMgr:getWindow("ringmake/right/bot/name22")
	
	self.okbtn = CEGUI.toPushButton(winMgr:getWindow("ringmake/right/ok"))
	self.okbtn:subscribeEvent("Clicked", RingMake.HandleOkBtnClicked, self)
	self.reminder = winMgr:getWindow("ringmake/right/bot/info")
	self.reminder:subscribeEvent("WindowUpdate", RingMake.HandleUpdateWnd, self)
	
	self.effectwnd = winMgr:getWindow("ringmake/effect")
	self:OnModeSelected(1)
	require "ui.jewelry.label"()
	self.m_hItemNumChangeNotify = GetRoleItemManager():InsertLuaItemNumChangeNotify(RingMake.OnItemNumChange)
	self:RefreshRemind()
	return self
end

function RingMake:HandleUpdateWnd(e)
	if self.bremind then
		local updateArgs = CEGUI.toUpdateEventArgs(e)
		self.theTime = self.theTime and self.theTime + updateArgs.d_timeSinceLastFrame or
			updateArgs.d_timeSinceLastFrame
		local interval = 0.2
		local cycle = 3
		local v = self.theTime / cycle
		local alpha = math.abs(1 - (v - math.floor(v))*2)
		self.reminder:setAlpha(alpha)
		self.reminder:setVisible(true)
	else
		self.theTime = 0
		self.reminder:setVisible(false)
	end
	return true
end

local function showitem(slot, attr)
	GetGameUIManager():RemoveUIEffect(slot.item)
	local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(attr.id)
	local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipConfig.equipcolor)
	if colorconfig.id~= -1 then
		GetGameUIManager():AddUIEffect(slot.item, colorconfig.effectshow)
	end
	slot.item:SetImage(GetIconManager():GetItemIconByID(attr.icon))
	slot.item:setID(attr.id)
	slot.name:setText(attr.name)
	slot.name:setProperty("TextColours", attr.colour)
end

local function setitemnum(cell, itemid, neednum)
	local hasnum = GetRoleItemManager():GetItemNumByBaseID(itemid)
	cell:SetTextUnit(neednum)
	if hasnum >= neednum then
		cell:SetTextUnitColor(require "utils.mhsdutils".get_greencolor())
	else
		cell:SetTextUnitColor(require "utils.mhsdutils".get_redcolor())
	end
end

function RingMake:RefreshRemind()
	if self.selectedpaper then
		local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelrypaper", self.selectedpaper)
		
		for i = 1, #self.previews do
			if i < cfg.lvmin then
				if not self.lastlvmin or i >= self.lastlvmin then
					GetGameUIManager():AddUIEffect(self.previews[i].item, require "utils.mhsdutils".get_effectpath(10402))
				end
			else
				if self.lastlvmin and i <= self.lastlvmin then
					GetGameUIManager():RemoveUIEffect(self.previews[i].item)
					-- 叉特效移除后 要把原来的特效加回来
					local equipConfig = knight.gsp.item.GetCEquipEffectTableInstance():getRecorder(self.previews[i].item:getID())
					local colorconfig = knight.gsp.item.GetCEquipColorConfigTableInstance():getRecorder(equipConfig.equipcolor)
					if colorconfig.id~= -1 then
						GetGameUIManager():AddUIEffect(self.previews[i].item, colorconfig.effectshow)
					end
				end
			end
			
		end
		self.lastlvmin = cfg.lvmin
	end
	if not self.mode then
		self.bremind = false
		return
	end
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelrymake", self.mode)
	if not cfg then
		self.bremind = false
		return
	end
	if self.selectedpaper and self.selectedpaper == cfg.paper1 then
		local num = GetRoleItemManager():GetItemNumByBaseID(cfg.paper2)
		if num > 0 then
			self.bremind = true
			return
		else
			num = GetRoleItemManager():GetItemNumByBaseID(cfg.paper3)
			if num > 0 then
				self.bremind = true
				return
			end
		end
	end
	self.bremind = false
end

function RingMake:OnModeSelected(mode)
	assert(mode > 0 and mode <= #self.modes)
	if self.mode == mode then
		return
	end
	if self.mode then
		self.selects[self.mode]:setVisible(false)
		self.selectedpaper = nil
	end
	self.mode = mode
	self.selects[mode]:setVisible(true)
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelrymake", mode)
	assert(cfg)
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.yulan1)
	showitem(self.previews[1], attr)
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.yulan2)
	showitem(self.previews[2], attr)
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.yulan3)
	showitem(self.previews[3], attr)
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.yulan4)
	showitem(self.previews[4], attr)
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.yulan5)
	showitem(self.previews[5], attr)
	
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.needid1)
	showitem(self.item1, attr)
	setitemnum(self.item1.item, cfg.needid1, cfg.neednum1)
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.needid2)
	showitem(self.item2, attr)
	setitemnum(self.item2.item, cfg.needid2, cfg.neednum2)
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.paper1)
	showitem(self.paper, attr)
	self.selectedpaper = cfg.paper1
	self:RefreshRemind()
end

function RingMake:HandleModeClicked(e)
	if self.processing then
		return false
	end
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	if self.m_pSelectedMode == mouseArgs.window then
		return true
	end
	
	self:OnModeSelected(mouseArgs.window:getID())
	return true
end

function RingMake:HandlePaperSelected(e)
	if not self then
		return true
	end
	if self.processing then
		return false
	end
	if not self.mode then
		return false
	end
	
	local dlg = require "ui.jewelry.ringchoose":getInstanceOrNot()
	if not dlg then
		return true
	end
	if not dlg.selectedpaper then
		return true
	end
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelrymake", self.mode)
	assert(cfg)
	local itemid = (dlg.selectedpaper == 1 and cfg.paper1) or 
				   (dlg.selectedpaper == 2 and cfg.paper2) or 
				   (dlg.selectedpaper == 3 and cfg.paper3) or 
				   (dlg.selectedpaper == 4 and cfg.paper4)
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(itemid)
	if self.selectedpaper ~= itemid then
		self.selectedpaper = itemid
		showitem(self.paper, attr)
		self:RefreshRemind()
	end
	dlg:DestroyDialog()
end

function RingMake:HandlePaperWndClicked(e)
	if self.processing then
		return false
	end
	if not self.mode then
		return false
	end
	
	local dlg = require "ui.jewelry.ringchoose":getInstanceOrNot()
	if not dlg then
		dlg = require "ui.jewelry.ringchoose":getInstance()
		dlg.okbtn:subscribeEvent("Clicked", RingMake.HandlePaperSelected, self)
	end
	
	--dlg:SetPosition()
	local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelrymake", self.mode)
	assert(cfg)
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.paper1)
	showitem(dlg.normal, attr)
	attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.paper2)
	showitem(dlg.better, attr)
	attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.paper3)
	showitem(dlg.special, attr)
	attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.paper4)
	showitem(dlg.morespecial, attr)
--	local left = "max"
--	dlg.normal.left:setText(left)
	local left = GetRoleItemManager():GetItemNumByBaseID(cfg.paper2)
	dlg.better.left:setText(left)
	left = GetRoleItemManager():GetItemNumByBaseID(cfg.paper3)
	dlg.special.left:setText(left)
	left = GetRoleItemManager():GetItemNumByBaseID(cfg.paper4)
	dlg.morespecial.left:setText(left)
	if self.selectedpaper then
		dlg:setSelectedpaper(self.selectedpaper)
	end
	return true
end

function RingMake.OnEffectEnd()
	local self = RingMake:getInstanceOrNot()
	if not self then
		return
	end
	self.processing = false
	assert(self.mode)
	local p = require "protocoldef.knight.gsp.item.cforgedecoration":new()
	p.mode = self.mode
	p.blueprint = self.paper.item:getID()
	require "manager.luaprotocolmanager":send(p)
end

function RingMake:HandleOkBtnClicked(e)
	if self.processing then
		return false
	end
	if not self.mode then
		return false
	end
	local dlg = require "ui.jewelry.ringchoose":getInstanceOrNot()
	if dlg then
		return false
	end
	local effect = GetGameUIManager():AddUIEffect(self.effectwnd, require "utils.mhsdutils".get_effectpath(10399), false)
	local notify = CGameUImanager:createNotify(self.OnEffectEnd)
	effect:AddNotify(notify)
	self.processing = true
	return true
end
function RingMake:OnClose()
	GetRoleItemManager():RemoveLuaItemNumChangeNotify(self.m_hItemNumChangeNotify)
	if self._instance then
		getmetatable(self)._instance = nil
	end
	Dialog.OnClose(self)
	local dlg = require "ui.jewelry.ringchoose":getInstanceOrNot()
	if dlg then
		dlg:DestroyDialog()
	end
end

function RingMake:setPaper(paperid)
	local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cjewelrymake")
	local ids = tt:getAllID()
	local cfg
	for i = 1, #ids do
		local curcfg = tt:getRecorder(ids[i])
		if curcfg then
			if curcfg.paper1 == paperid or 
				curcfg.paper2 == paperid or
				curcfg.paper3 == paperid or 
				curcfg.paper4 == paperid then
				cfg = curcfg
				break
			end
		end
	end
	if not cfg then
		self:DestroyDialog()
		return
	end
	self:OnModeSelected(cfg.id)
	local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(paperid)
	showitem(self.paper, attr)
	self.selectedpaper = paperid
end

function RingMake:DestroyDialog()
	local dlg = require "ui.label".getLabelById("jewelry")
	if dlg then
		dlg:OnClose()
	else
		single.DestroyDialog(self)
	end
end
function RingMake.OnItemNumChange(bagid, itemkey, itembaseid)
	local self = RingMake:getInstanceOrNot()
	if not self then
		return
	end
	if self.mode then
		local cfg = require "utils.mhsdutils".getLuaBean("knight.gsp.item.cjewelrymake", self.mode)
		assert(cfg)
		if itembaseid == cfg.needid1 or itembaseid == cfg.needid2 then
			local attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.needid1)
			setitemnum(self.item1.item, cfg.needid1, cfg.neednum1)
			attr = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.needid2)
			setitemnum(self.item2.item, cfg.needid2, cfg.neednum2)
		end
	end
	self:RefreshRemind()
end
return RingMake
