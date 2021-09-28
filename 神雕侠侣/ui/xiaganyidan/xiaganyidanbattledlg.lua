local SingletonDialog = require "ui.singletondialog"
local Dialog = require "ui.dialog"
require "ui.xiake.myxiake_xiake"

local XiaGanYiDanBattleDlg = {}
setmetatable(XiaGanYiDanBattleDlg, SingletonDialog)
XiaGanYiDanBattleDlg.__index = XiaGanYiDanBattleDlg

function XiaGanYiDanBattleDlg.GetLayoutFileName()
	return "xiaganyidanzhandou.layout"
end

function XiaGanYiDanBattleDlg.new()
	local inst = {}
	setmetatable(inst, XiaGanYiDanBattleDlg)
	Dialog.OnCreate(inst)

	local winMgr = CEGUI.WindowManager:getSingleton()
	inst.m_wZhenFa = CEGUI.Window.toPushButton(winMgr:getWindow("xiaganyidanzhandou/up/btn"))
	inst.m_wZhenFa:subscribeEvent("Clicked", XiaGanYiDanBattleDlg.HandleZhenFaClicked, inst)
	inst.m_wZhenRong = CEGUI.Window.toPushButton(winMgr:getWindow("xiaganyidanzhandou/up/btn1"))
	inst.m_wZhenRong:subscribeEvent("Clicked", XiaGanYiDanBattleDlg.HandleZhenRongClicked, inst)
	inst.m_wStartBattle = CEGUI.Window.toPushButton(winMgr:getWindow("xiaganyidanzhandou/down/btn"))
	inst.m_wStartBattle:subscribeEvent("Clicked", XiaGanYiDanBattleDlg.HandleStartBattleClicked, inst)
	inst.m_wMyZonghe = winMgr:getWindow("xiaganyidanzhandou/up/txt1")
	inst.m_wEnemyZonghe = winMgr:getWindow("xiaganyidanzhandou/down/txt1")
	inst.m_wTollgateName = winMgr:getWindow("xiaganyidanzhandou/down/name/txt")

	-- 我方
	inst.m_Up = {}
	for i=0, 4 do
		local card = {}
		card.frame = winMgr:getWindow("xiaganyidanzhandou/up/back/quank" .. tostring(i))
		card.head = winMgr:getWindow("xiaganyidanzhandou/up/back/quank" .. tostring(i) .. "/head")
		card.jingying = winMgr:getWindow("xiaganyidanzhandou/up/back/quank" .. tostring(i) .. "/head/jingying")
		card.level = winMgr:getWindow("xiaganyidanzhandou/up/back/quank" .. tostring(i) .. "/head/num")
		card.starlv = winMgr:getWindow("xiaganyidanzhandou/up/back/quank" .. tostring(i) .. "/head/img")
		card.name = winMgr:getWindow("xiaganyidanzhandou/up/back/quank" .. tostring(i) .. "/name")
		card.qixue = CEGUI.Window.toProgressBar(winMgr:getWindow("xiaganyidanzhandou/up/back/quank" .. tostring(i) .. "/bar"))
--		card.zhengwang = winMgr:getWindow("xiaganyidanzhandou/up/back/quank" .. tostring(i) .. "/zhenwang")
--		card.zhengwang:setVisible(false)
		table.insert(inst.m_Up, card)
	end

	-- 敌方
	inst.m_Down = {}
	for i=0, 4 do
		local card = {}
		card.frame = winMgr:getWindow("xiaganyidanzhandou/down/back/quank" .. tostring(i))
		card.head = winMgr:getWindow("xiaganyidanzhandou/down/back/quank" .. tostring(i) .. "/head")
		card.level = winMgr:getWindow("xiaganyidanzhandou/down/back/quank" .. tostring(i) .. "/head/num")
		card.name = winMgr:getWindow("xiaganyidanzhandou/down/back/quank" .. tostring(i) .. "/name")
		table.insert(inst.m_Down, card)
	end

	return inst
end

function XiaGanYiDanBattleDlg:HandleZhenFaClicked(args)
	ZhenfaChooseDlg.getInstanceAndShow()
end

function XiaGanYiDanBattleDlg:HandleZhenRongClicked(args)
	MyXiake_xiake.getInstance():SetViewMode(1)
	MyXiake_xiake.getInstance():RefreshMyXiakes()
end

function XiaGanYiDanBattleDlg:HandleStartBattleClicked(args)
	local XiaGanYiDanMapDlg = require "ui.xiaganyidan.xiaganyidanmapdlg"
	local CStartBattleXGYD = require "protocoldef.knight.gsp.xiake.xiaganyidan.cstartbattlexgyd"
	local req = CStartBattleXGYD.Create()
	req.curstage = XiaGanYiDanMapDlg:getInstance().m_ClickedTollgate -1
	LuaProtocolManager.getInstance():send(req)
end

function XiaGanYiDanBattleDlg:RefreshData(zonghe, qixue, xiakeids, Ename, EShape, Elevel, Exiakes, Ezonghe, formid)
--	self.m_xiakeqixues = xiakeqixues
--	self.m_xiakedeads = xiakedeads
	local XiaGanYiDanMapDlg = require "ui.xiaganyidan.xiaganyidanmapdlg"
	local record = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cexpeditionconfig"):getRecorder(XiaGanYiDanMapDlg:getInstance().m_ClickedTollgate)
	self.m_wTollgateName:setText(record.stageName)
	self.m_wMyZonghe:setText(tostring(zonghe))
	self.m_wEnemyZonghe:setText(tostring(Ezonghe))
	self:RefreshZhengFa(formid)
	self:RefreshMyMain(qixue)
	self:RefreshMyXiaKe(xiakeids)
	self:RefreshEnemyMain(Ename, EShape, Elevel)
	self:RefreshEnemyXiaKe(Exiakes, Elevel)
end

function XiaGanYiDanBattleDlg:RefreshZhengFa(formid)
	local formationConfig = knight.gsp.battle.GetCFormationbaseConfigTableInstance():getRecorder(formid)
	self.m_wZhenFa:setText(formationConfig.name)
	self.m_wZhenFa:setID(formid)
end

function XiaGanYiDanBattleDlg:RefreshMyMain(qixue)
	local card = self.m_Up[1]
	local md = GetDataManager():GetMainCharacterData()
	local shape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(md.shape)
	card.head:setProperty("Image", GetIconManager():GetImagePathByID(shape.headID):c_str())
	card.jingying:setVisible(false)
	card.level:setText(tostring(GetDataManager():GetMainCharacterLevel()))
	card.starlv:setVisible(false)
	card.name:setText(md.strName)
	card.qixue:setProgress(qixue)
	card.qixue:setText(tostring(math.floor(qixue*100)) .. "%")
end

function XiaGanYiDanBattleDlg:RefreshMyXiaKe(ids)
	for i=2,#ids +1 do
		local key = ids[i-1]
		local xk = XiakeMng.GetXiakeFromKey(key)
		local xkd = XiakeMng.ReadXiakeData(xk.xiakeid)
		local xkyz = XiakeMng.GetXiaKeYuanZhengData(key)
		local card = self.m_Up[i]
		card.frame:setProperty("Image", XiakeMng.eXiakeFrames[xk.color])
		card.head:setProperty("Image", xkd.path)
		card.jingying:setVisible(XiakeMng.IsElite(xk.xiakekey))
		card.level:setText(tostring(GetDataManager():GetMainCharacterLevel()))
		card.starlv:setProperty("Image", XiakeMng.eLvImages[xk.starlv])
		card.name:setText(scene_util.GetPetNameColor(xk.color)..(xkd.xkxx.name))
		card.qixue:setProgress(xkyz.qixue)
		card.qixue:setText(tostring(math.floor(xkyz.qixue*100)) .. "%")
		card.frame:setVisible(true)
	end
	for i=#ids +2, 5 do
		local card = self.m_Up[i]
		card.frame:setVisible(false)
	end
end

function XiaGanYiDanBattleDlg:RefreshEnemyMain(name, shape, level)
	local card = self.m_Down[1]
	local shape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(shape)
	card.head:setProperty("Image", GetIconManager():GetImagePathByID(shape.headID):c_str())
	card.level:setText(tostring(level))
	card.name:setText(name)
end

function XiaGanYiDanBattleDlg:RefreshEnemyXiaKe(xiakes, level)
	local ids = {}
	for k,v in pairs(xiakes) do
		table.insert(ids, k)
	end
	for i=2,#ids +1 do
		local key = ids[i-1]
		local color = xiakes[key]
		local xkd = XiakeMng.ReadXiakeData(key)
		local card = self.m_Down[i]
		card.frame:setProperty("Image", XiakeMng.eXiakeFrames[color])
		card.head:setProperty("Image", xkd.path)
		card.level:setText(tostring(level))
		card.name:setText(scene_util.GetPetNameColor(color)..(xkd.xkxx.name))
		card.frame:setVisible(true)
	end
	for i=#ids +2, 5 do
		local card = self.m_Down[i]
		card.frame:setVisible(false)
	end
end

return XiaGanYiDanBattleDlg
