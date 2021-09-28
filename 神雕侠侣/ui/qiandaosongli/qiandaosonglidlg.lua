require "ui.dialog"
local QiandaosongliDlg = {}

setmetatable(QiandaosongliDlg, Dialog);
QiandaosongliDlg.__index = QiandaosongliDlg;

local _instance;

function QiandaosongliDlg.getInstanceNotCreate()
	return _instance;
end

function QiandaosongliDlg.DestroyDialog()
	if _instance then
		_instance:OnClose();
		_instance = nil;
		LogInfo("QiandaosongliDlg DestroyDialog")
	end
end

function QiandaosongliDlg.getInstanceAndShow()
	LogInfo("QiandaosongliDlg getInstanceAndShow")
    if not _instance then
        _instance = QiandaosongliDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function QiandaosongliDlg.GetLayoutFileName()
	return "qiandaosonglimain.layout";
end

function QiandaosongliDlg:new()
	local zf = {};
	zf = Dialog:new();
	setmetatable(zf, QiandaosongliDlg);
	return zf;
end

-------------------------------------------------------------------------------

local squerysignin = require "protocoldef.knight.gsp.activity.signin.squerysignin"
function squerysignin:process()
	LogInfo("squerysignin process ")
	if not _instance then return end
	_instance:SetData(self.month, self.times, self.rewardflag)
end


function QiandaosongliDlg:OnCreate()
	LogInfo("QiandaosongliDlg OnCreate begin")
	Dialog.OnCreate(self)

	local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_backWnd = winMgr:getWindow("qiandaosonglimain/down/back")
	self.m_monthWnd = winMgr:getWindow("qiandaosonglimain/time/num")
	self.m_monthWnd:setText("")
	self.m_talkWnd = winMgr:getWindow("qiandaosonglimain/talk/txt")
	self.m_talkWnd:setText("")
	self.m_talkText = MHSD_UTILS.get_resstring(3177)
	self.m_cells = {}

	local Cell = require "ui.qiandaosongli.qiandaosonglicell"
	-- local cellWidth = self.m_backWnd:getPixelSize().width / 7
	-- local size = CEGUI.UVector2(CEGUI.UDim(0, cellWidth),CEGUI.UDim(0, cellWidth))
	-- for i=1,31 do
	-- 	local curCell = Cell.CreateNewDlg(self.m_backWnd, i)
	-- 	local row = math.floor((i-1) / 7)
	-- 	local x = CEGUI.UDim(0, 1 + (i-1-row*7)*cellWidth)
	-- 	local y = CEGUI.UDim(0, 1 + row*cellWidth)
	-- 	local pos = CEGUI.UVector2(x,y)
	-- 	curCell.pWnd:setArea(pos, size)
	-- 	curCell.pWnd:setVisible(false)
	-- 	table.insert(self.m_cells, curCell)
	-- end
	local parentWidth = self.m_backWnd:getPixelSize().width
	for i=1,31 do
		local curCell = Cell.CreateNewDlg(self.m_backWnd, i)
		local cellPerRow = math.floor(parentWidth / curCell.m_width)
		local row = math.floor((i-1) / cellPerRow)
		local x = CEGUI.UDim(0, 1 + (i-1-row*cellPerRow)*curCell.m_width)
		local y = CEGUI.UDim(0, 1 + row*curCell.m_width)
		local pos = CEGUI.UVector2(x,y)
		curCell.pWnd:setPosition(pos)

		curCell.pWnd:setVisible(false)
		curCell.m_item:subscribeEvent("MouseClick", self.HandleItemClicked, self)
		table.insert(self.m_cells, curCell)
	end

	LogInfo("QiandaosongliDlg OnCreate finish")
end

function QiandaosongliDlg:HandleItemClicked(args)
	local e = CEGUI.toWindowEventArgs(args)
	local cellid = e.window:getID()
	if self.m_times < 31 and e.window == self.m_cells[self.m_times + 1].m_item then
		if self.m_flag == 0 then
			LogInfo("QiandaosongliDlg send message")
			local p = require "protocoldef.knight.gsp.activity.signin.csignin":new()
			p.month = self.m_month
    		require "manager.luaprotocolmanager":send(p)
		end
	end
end

function QiandaosongliDlg:SetData( month, times, flag )
	LogInfo("QiandaosongliDlg SetData"..tostring(times).." "..tostring(flag))
	self.m_month = month
	self.m_times = times
	self.m_flag = flag

	self.m_monthWnd:setText(tostring(self.m_month))
	local str = string.gsub(self.m_talkText, "%$parameter1%$", tostring(self.m_times))
	self.m_talkWnd:setText(str)

	for i,v in ipairs(self.m_cells) do
		local curCell = v
		local cfg = self:GetRecord(self.m_month, i)

		if not cfg then
			curCell.pWnd:setVisible(false)
		else
			curCell.pWnd:setVisible(true)
			GetGameUIManager():RemoveUIEffect(curCell.m_effect)
			GetGameUIManager():RemoveUIEffect(curCell.m_item)

			if self.m_flag == 0 and i == self.m_times + 1 then
				GetGameUIManager():AddUIEffect(curCell.m_effect, MHSD_UTILS.get_effectpath(10305), true, 0, 0, true)	
			end

			if cfg.xiyou == 1 and i > self.m_times then
				GetGameUIManager():AddUIEffect(curCell.m_item, MHSD_UTILS.get_effectpath(10374), true, 0, 0, true)
			end

			curCell.m_check:setVisible(i <= self.m_times)
			curCell.m_double:setVisible(cfg.shuangbei ~= 0)
			curCell.m_double:setText(tostring(cfg.shuangbei))

			if string.len(cfg.pic) == 0 then
				local itembean = knight.gsp.item.GetCItemAttrTableInstance():getRecorder(cfg.itemid)
				curCell.m_item:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
			else
				curCell.m_item:SetImage(GetIconManager():GetItemIconByID(tonumber(string.sub(cfg.pic, -4))))
			end
			if cfg.itemid then
				curCell.m_item:setID(cfg.itemid)
				require "utils.mhsdutils".SetWindowShowtips(curCell.m_item)
			end
			local num = 0
			if cfg.itemnum > num then num = cfg.itemnum end
			if cfg.yuanbaonum > num then num = cfg.yuanbaonum end
			if cfg.yinliangnum > num then num = cfg.yinliangnum end
			curCell.m_item:SetTextUnitText(CEGUI.String("X"..num))

		end
	end
end

function QiandaosongliDlg:GetRecord( month, day )
	local tb = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cqiandaojiangli")
	local id = month * 100 + day
	return tb:getRecorder(id)
end

return QiandaosongliDlg