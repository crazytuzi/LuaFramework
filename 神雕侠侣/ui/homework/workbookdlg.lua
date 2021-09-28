require "ui.dialog"

local WorkbookDlg = {}
setmetatable(WorkbookDlg, Dialog)
WorkbookDlg.__index = WorkbookDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function WorkbookDlg.getInstance()
	LogInfo("WorkbookDlg getinstance")
    if not _instance then
        _instance = WorkbookDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function WorkbookDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = WorkbookDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function WorkbookDlg.getInstanceNotCreate()
    return _instance
end

function WorkbookDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function WorkbookDlg.ToggleOpenClose()
	if not _instance then 
		_instance = WorkbookDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
----/////////////////////////////////////////------

function WorkbookDlg.GetLayoutFileName()
    return "shujiazuoyelist.layout"
end

function WorkbookDlg:OnCreate()
	LogInfo("enter WorkbookDlg oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
	if not winMgr then return end
	
	-- 领奖按钮
    self.m_pBonusBtn = CEGUI.Window.toPushButton(winMgr:getWindow("shujiazuoyelist/button0"))
	if self.m_pBonusBtn then
		self.m_pBonusBtn:subscribeEvent("Clicked", WorkbookDlg.HandleBonusBtnClick, self) 
	end
	
	-- 成绩列表
	self.m_pScoreList = CEGUI.Window.toMultiColumnList(winMgr:getWindow("shujiazuoyelist/PersonalInfo/list"))
	
	-- 平均分
	self.m_pAvg = winMgr:getWindow("shujiazuoyelist/num")
end

------------------- private: -----------------------------------

function WorkbookDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, WorkbookDlg)

    return self
end

-- 领奖学金
function WorkbookDlg:HandleBonusBtnClick(args)
	local CHomeworkAvgReward = require 'protocoldef.knight.gsp.activity.homework.chomeworkavgreward'
	local avgreward = CHomeworkAvgReward.Create()
	LuaProtocolManager.getInstance():send(avgreward)
end

-- 刷新界面信息
function WorkbookDlg:refreshInfo(homeworks, avgscore)

	if type(homeworks) ~= 'table' then return end
	
	-- 更新平均分
	if self.m_pAvg then
		self.m_pAvg:setText(tostring(avgscore))
	end
	
	-- 根据日期排序
	table.sort(homeworks, function (a,b) return a.id < b.id end)
	
	-- 更新成绩列表
	local num = 0
	for _, dayHomework in ipairs(homeworks) do
		
		-- 将日期显示为xx-xx-xx的格式
		local sDate
		local nDate = dayHomework.id
		if nDate then
			local nYear = math.floor(nDate / 10000)
			local nMonth = math.floor((nDate - nYear * 10000) / 100)
			local nDay = math.floor(nDate % 100)
			sDate = string.format("%04d-%02d-%02d", nYear, nMonth, nDay)
		end

		-- 计算每天得分
		local nScore = 0
		for _,homeworkState in ipairs(dayHomework.state) do
			if homeworkState.finish == 1 then
				nScore = nScore + 20
			end
		end
		
		-- 将日期和当天成绩添加入成绩列表
		if self.m_pScoreList then
			self.m_pScoreList:addRow(num)

			local pItem0 = CEGUI.createListboxTextItem(tostring(sDate))	
			if pItem0 then
				pItem0:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
				pItem0:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
				self.m_pScoreList:setItem(pItem0, 0, num)
			end
			
			local pItem1 = CEGUI.createListboxTextItem(tostring(nScore))
			if pItem1 then			
				pItem1:setTextColours(CEGUI.PropertyHelper:stringToColour("FFFFFFFF"))
				pItem1:SetTextHorFormat(CEGUI.eListBoxTextItemHorFormat_Center)
				self.m_pScoreList:setItem(pItem1, 1, num)
			end

			num = num + 1
		end
	end
end

-- 刷新领奖按钮
function WorkbookDlg:refreshBonusBtn(get)
	-- 设置领奖按钮是否可以点击
	if self.m_pBonusBtn then
		self.m_pBonusBtn:setEnabled(get ~= 1)
	end
end

return WorkbookDlg