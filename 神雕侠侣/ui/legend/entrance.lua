local entrance = {}
local single = require "ui.singletondialog"
setmetatable(entrance, single)
entrance.__index = entrance
local configs = require "manager.beanconfigmanager".getInstance():GetTableByName("knight.gsp.task.cchuanshuo")

local DungeonsSlot = {}
DungeonsSlot.__index = DungeonsSlot
function DungeonsSlot.new(name_prefix, cfg)
	local self = {}
	setmetatable(self, DungeonsSlot)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pCfg = cfg
	self.m_pFrame = winMgr:loadWindowLayout("chuanshuocell.layout", name_prefix)
	self.m_pFrame:setID(cfg.id)
	self.m_pIcon = winMgr:getWindow(name_prefix.."chuanshuocell/logo")
	self.m_pName = winMgr:getWindow(name_prefix.."chuanshuocell/name")
	self.m_pLevel = winMgr:getWindow(name_prefix.."chuanshuocell/level")
	self.m_pLight = winMgr:getWindow(name_prefix.."chuanshuocell/light")
	self.m_pLight:setVisible(false)
	
	self.m_pIcon:setProperty("Image", cfg.logo)
	self.m_pName:setText(cfg.mingzi)
	self.m_pLevel:setText(cfg.leve)
	
	local childcount = self.m_pFrame:getChildCount()
	for i = 0, childcount - 1 do
		local child = self.m_pFrame:getChildAtIdx(i)
		child:setMousePassThroughEnabled(true)
	end
	self.m_pFrame:setMousePassThroughEnabled(false)
	return self
end

local function LoadDungeonses(self)
	self.m_pDungeonsSlots = {}
	local winMgr = CEGUI.WindowManager:getSingleton()
	local ids = configs:getAllID()
--	local dungeonsnum = require "utils.tableutil".tablelength(ids)
	for i = 1, #ids do
		local slot = DungeonsSlot.new(i, configs:getRecorder(ids[i]))
		table.insert(self.m_pDungeonsSlots, slot)
		self.m_pDungeonsPane:addChildWindow(slot.m_pFrame)
		local height = slot.m_pFrame:getHeight():asAbsolute(0)
		local offset = i ~= 1 and height * (i - 1) or 1
		slot.m_pFrame:subscribeEvent("MouseClick", entrance.HandleDungeonsSelected, self)
		slot.m_pFrame:setPosition(CEGUI.UVector2(CEGUI.UDim(0, 1), CEGUI.UDim(0, offset)))
		if i == 1 then
			self.m_pLastSelected = slot
			self:OnDungeonsSelected()
		end
	end
end

function entrance.new()
	local self = {}
	setmetatable(self, entrance)
	function self.GetLayoutFileName()
		return "chuanshuo.layout"
	end
	require "ui.dialog".OnCreate(self)
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_pDungeonsPane = CEGUI.toScrollablePane(winMgr:getWindow("chuanshuo/top/main"))
	self.m_pIntroduceTop = CEGUI.toRichEditbox(winMgr:getWindow("chuanshuo/top1/main1"))
	self.m_pIntroduceBottom = CEGUI.toRichEditbox(winMgr:getWindow("chuanshuo/top1/main2"))
	self.m_pNormalBtn = CEGUI.toPushButton(winMgr:getWindow("chuanshuo/btn1"))
	self.m_pHardBtn = CEGUI.toPushButton(winMgr:getWindow("chuanshuo/btn2"))
	self.m_pTitle = winMgr:getWindow("chuanshuo/top/title/name1")
	self.m_pNpcIcon = winMgr:getWindow("chuanshuo/top1/pic")
	self.m_pFinishTime = winMgr:getWindow("chuanshuo/num")
	self.m_pDungeonsSlots = {}
	LoadDungeonses(self)
	self.m_pNormalBtn:subscribeEvent("Clicked", entrance.HandleNormalBtnClicked, self)
	self.m_pHardBtn:subscribeEvent("Clicked", entrance.HandleHardBtnClicked, self)
	local req = require "protocoldef.knight.gsp.npc.ctgbdtimes":new()
	require "manager.luaprotocolmanager":send(req)
	return self
end
local protocol = require "protocoldef.knight.gsp.npc.creqentertgbdzone"
function entrance:HandleNormalBtnClicked(e)
   	local p = protocol:new()
	p.flag = 1
	require "manager.luaprotocolmanager":send(p)
	return true
end

function entrance:HandleHardBtnClicked(e)
   	local p = protocol:new()
	p.flag = 2
	require "manager.luaprotocolmanager":send(p)
	return true
end

local function appendtext(box, text)
	local idx = string.find(text, "<T")
	if idx then
		box:AppendParseText(CEGUI.String(text))
	else
		box:AppendText(CEGUI.String(text))
	end
end

function entrance:OnDungeonsSelected()
	if not self.m_pLastSelected then
		return
	end
	self.m_pLastSelected.m_pLight:setVisible(true)
	local cfg = self.m_pLastSelected.m_pCfg
	self.m_pIntroduceTop:Clear()
	self.m_pIntroduceBottom:Clear()
	if cfg then
		appendtext(self.m_pIntroduceTop, cfg.xuzhi)
		appendtext(self.m_pIntroduceBottom, cfg.wenan)
		self.m_pNpcIcon:setProperty("Image", cfg.touxiang)
	else
		self.m_pIntroduceTop:Clear()
		self.m_pIntroduceBottom:Clear()
		self.m_pNpcIcon:setProperty("Image", "")
	end
	self.m_pIntroduceTop:Refresh()
	self.m_pIntroduceBottom:Refresh()
end

function entrance:HandleDungeonsSelected(e)
	if self.m_pLastSelected then
		self.m_pLastSelected.m_pLight:setVisible(false)
	end
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	for i = 1, #self.m_pDungeonsSlots do
		if self.m_pDungeonsSlots[i].m_pFrame == mouseArgs.window then
			self.m_pLastSelected = self.m_pDungeonsSlots[i]
			break
		end
	end
	self:OnDungeonsSelected()
	return true
end

return entrance
