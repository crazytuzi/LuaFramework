local SingletonDialog = require "ui.singletondialog"
local Dialog = require "ui.dialog"

local XiaGanYiDanMapDlg = {}
setmetatable(XiaGanYiDanMapDlg, SingletonDialog)
XiaGanYiDanMapDlg.__index = XiaGanYiDanMapDlg

function XiaGanYiDanMapDlg.GetLayoutFileName()
	return "xiaganyidandlg.layout"
end

function XiaGanYiDanMapDlg.new()
	local inst = {}
	setmetatable(inst, XiaGanYiDanMapDlg)
	Dialog.OnCreate(inst)

	local winMgr = CEGUI.WindowManager:getSingleton()
	inst.m_wMap = CEGUI.Window.toScrollablePane(winMgr:getWindow("xiaganyidandlg/main"))
	inst.m_wMap:EnableHorzScrollBar(true)
	-- Map
	inst.m_Map = {}
	local MapTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cexpeditionmapconfig")
	local ids = MapTable:getAllID()
	local xpos = 1
	for i,v in ipairs(ids) do
		local record = MapTable:getRecorder(v)
		local wnd = winMgr:createWindow("TaharezLook/StaticImage")
		wnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, record.widthX), CEGUI.UDim(0, record.heightY)))
		wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,xpos),CEGUI.UDim(0,1)))
		wnd:setZOrderingEnabled(false)
		wnd:setProperty("Image", record.addrImage)
		wnd:setProperty("FrameEnabled", "False")
		inst.m_wMap:addChildWindow(wnd)
		xpos = xpos+record.widthX
		table.insert(inst.m_Map, wnd)
	end

	-- Tollgate
	inst.m_Tollgate = {}
	local TollgateTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.ctollgateposconfig")
	local ids = TollgateTable:getAllID()
	for i,v in ipairs(ids) do
		local record = TollgateTable:getRecorder(v)
		local wnd = winMgr:createWindow("TaharezLook/ImageButton")
		wnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, record.width), CEGUI.UDim(0, record.height)))
		wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,record.posX),CEGUI.UDim(0,record.posY)))
		wnd:setProperty("NormalImage", record.addrNormal)
		wnd:setProperty("HoverImage", record.addrNormal)
		wnd:setProperty("PushedImage", record.addrNormal)
		wnd:setProperty("DisabledImage", record.addrDisable)
--		wnd:setProperty("ClippedByParent", "False")
		wnd:setID(v)
		wnd:subscribeEvent("Clicked", XiaGanYiDanMapDlg.HandleTollgateClicked, inst)
		inst.m_wMap:addChildWindow(wnd)
		table.insert(inst.m_Tollgate, wnd)
	end

	-- Box
	inst.m_Box = {}
	local BoxTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cboxposconfig")
	local ids = BoxTable:getAllID()
	for i,v in ipairs(ids) do
		local record = BoxTable:getRecorder(v)
		local wnd = winMgr:createWindow("TaharezLook/ImageButton")
		wnd:setSize(CEGUI.UVector2(CEGUI.UDim(0, record.width), CEGUI.UDim(0, record.height)))
		wnd:setPosition(CEGUI.UVector2(CEGUI.UDim(0,record.posX),CEGUI.UDim(0,record.posY)))
		wnd:setProperty("NormalImage", record.addrNormal)
		wnd:setProperty("HoverImage", record.addrNormal)
		wnd:setProperty("PushedImage", record.addrNormal)
		wnd:setProperty("DisabledImage", record.addrGotten) -- 已领取
		wnd:setEnabled(false)
--		wnd:setProperty("ClippedByParent", "False")
		wnd:setID(v)
		wnd:subscribeEvent("Clicked", XiaGanYiDanMapDlg.HandleBoxClicked, inst)
		inst.m_wMap:addChildWindow(wnd)
		table.insert(inst.m_Box, wnd)
	end

	-- Other
--	inst.m_wCount = winMgr:getWindow("xiaganyidandlg/back/num")
	inst.m_wClose = CEGUI.Window.toPushButton(winMgr:getWindow("xiaganyidandlg/back/closed"))
	inst.m_wClose:subscribeEvent("Clicked", XiaGanYiDanMapDlg.HandleCloseClicked, inst)
--	inst.m_wRestart = CEGUI.Window.toPushButton(winMgr:getWindow("xiaganyidandlg/back/reback"))
--	inst.m_wRestart:subscribeEvent("Clicked", XiaGanYiDanMapDlg.HandleRestartClicked, inst)
	inst.m_wInfo = CEGUI.Window.toPushButton(winMgr:getWindow("xiaganyidandlg/back/info"))
	inst.m_wInfo:subscribeEvent("Clicked", XiaGanYiDanMapDlg.HandleInfoClicked, inst)

	inst.m_FirstOpen = true -- 是否第一次打开界面
	inst.m_CurTollgate = 0 -- 当前关卡
	inst.m_hasReward = false -- 是否还有未领取的奖励
	return inst
end

function XiaGanYiDanMapDlg:OnClose()
	local CCloseXGYD = require "protocoldef.knight.gsp.xiake.xiaganyidan.cclosexgyd"
	local req = CCloseXGYD.Create()
	LuaProtocolManager.getInstance():send(req)
	Dialog.OnClose(self)
end

function XiaGanYiDanMapDlg:RefreshData(cishu, guanka, boxes)
--	if cishu then
--		self.m_wCount:setText(tostring(cishu))
--	end
	if guanka then
		self.m_CurTollgate = guanka+1
		for i=1, guanka do
			self.m_Tollgate[i]:setEnabled(false)
			GetGameUIManager():RemoveUIEffect(self.m_Tollgate[i])
		end
		for i=self.m_CurTollgate, #self.m_Tollgate do
			self.m_Tollgate[i]:setEnabled(true)
			GetGameUIManager():RemoveUIEffect(self.m_Tollgate[i])
		end
		if self.m_CurTollgate <= #self.m_Tollgate then
			GetGameUIManager():AddUIEffect(self.m_Tollgate[self.m_CurTollgate], MHSD_UTILS.get_effectpath(10457))
		end
	end
	if boxes then
		local RewardDlg = require "ui.xiaganyidan.rewarddlg"
		local BoxTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cboxposconfig")
		self.m_hasReward = false
		for i,v in ipairs(boxes) do
			local record = BoxTable:getRecorder(i)
			local wnd = self.m_Box[i]
			-- 未领取
			if v == 0 then
				if guanka and i<=guanka then -- 可领取
					wnd:setProperty("NormalImage", record.addrNormal)
					wnd:setProperty("HoverImage", record.addrNormal)
					wnd:setProperty("PushedImage", record.addrNormal)
					self.m_hasReward = true
				else -- 未满足条件，不可领取
					wnd:setProperty("NormalImage", record.addrDisable)
					wnd:setProperty("HoverImage", record.addrDisable)
					wnd:setProperty("PushedImage", record.addrDisable)
				end
				wnd:setEnabled(true)
			end
			-- 已领取
			if v == 1 then
				wnd:setEnabled(false)
				if RewardDlg:getInstanceOrNot() then
					RewardDlg:getInstanceOrNot():CloseRewardDlg("xiaganyidanbox" .. tostring(i))
				end
			end
		end
	end
end

function XiaGanYiDanMapDlg:HandleTollgateClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	self.m_ClickedTollgate = id
	local COpenMatchXGYD = require "protocoldef.knight.gsp.xiake.xiaganyidan.copenmatchxgyd"
	local req = COpenMatchXGYD.Create()
	req.curstage = id -1
	if self.m_FirstOpen then
		req.needalldata = 1
		self.m_FirstOpen = false
	else
		req.needalldata = 0
	end
	LuaProtocolManager.getInstance():send(req)
end

function XiaGanYiDanMapDlg:HandleBoxClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local CExpeditionConfigTable = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cexpeditionconfig")
	local record = CExpeditionConfigTable:getRecorder(id)
	local RewardDlg = require "ui.xiaganyidan.rewarddlg"

	local okfunction = function(id)
		local CTakeAwardXGYD = require "protocoldef.knight.gsp.xiake.xiaganyidan.ctakeawardxgyd"
		local req = CTakeAwardXGYD.Create()
		req.awardstage = id-1
		LuaProtocolManager.getInstance():send(req)
	end
	local itemids = {}
	for i=0,TableUtil.tablelength(record.itemID) do
		table.insert(itemids, record.itemID[i])
	end
	if id < self.m_CurTollgate then
		RewardDlg:GetSingletonDialogAndShowIt():RefreshData("xiaganyidanbox" .. tostring(id), itemids, okfunction, id)
	else
		RewardDlg:GetSingletonDialogAndShowIt():RefreshData("xiaganyidanbox" .. tostring(id), itemids)
	end
end

function XiaGanYiDanMapDlg:HandleCloseClicked(args)
	local okfunction = function(arg)
		arg:DestroyDialog()
		GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
	end
	if self.m_hasReward then
		GetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(146416), okfunction, self, CMessageManager.HandleDefaultCancelEvent, CMessageManager)
	else
		self:DestroyDialog()
	end
end

function XiaGanYiDanMapDlg:HandleRestartClicked(args)
	local okfunction = function(self)
		local CStartOverXGYD = require "protocoldef.knight.gsp.xiake.xiaganyidan.cstartoverxgyd"
		local req = CStartOverXGYD.Create()
		LuaProtocolManager.getInstance():send(req)
		GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
		XiakeMng.ClearXiaKeYuanZhengData()
		self.m_FirstOpen = true
	end
	GetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(146252), okfunction, self, CMessageManager.HandleDefaultCancelEvent, CMessageManager)
end

function XiaGanYiDanMapDlg:HandleInfoClicked(args)
	local HowToPlayDlg = require "ui.tips.howtoplaydlg"
	HowToPlayDlg:GetSingletonDialogAndShowIt():Init(52)
end

return XiaGanYiDanMapDlg
