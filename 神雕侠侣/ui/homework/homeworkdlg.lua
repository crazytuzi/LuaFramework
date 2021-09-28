require "ui.dialog"

local HomeworkDlg = {}
setmetatable(HomeworkDlg, Dialog)
HomeworkDlg.__index = HomeworkDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function HomeworkDlg.getInstance()
	LogInfo("HomeworkDlg getinstance")
    if not _instance then
        _instance = HomeworkDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function HomeworkDlg.getInstanceAndShow()
	print("enter instance show")
    if not _instance then
        _instance = HomeworkDlg:new()
        _instance:OnCreate()
	else
		print("set visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function HomeworkDlg.getInstanceNotCreate()
    return _instance
end

function HomeworkDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()		
		_instance = nil
	end
end

function HomeworkDlg.ToggleOpenClose()
	if not _instance then 
		_instance = HomeworkDlg:new() 
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

function HomeworkDlg.GetLayoutFileName()
    return "shujiazuoye.layout"
end

function HomeworkDlg:OnCreate()
	LogInfo("enter HomeworkDlg oncreate")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
	if not winMgr then return end
	
	-- 班级（服务器名）
	self.m_pClassName = winMgr:getWindow("shujiazuoye/paper/shuoming/num")
	if self.m_pClassName then
		self.m_pClassName:setText(tostring(GetLoginManager():GetSelectServer()))
	end
	
	-- 角色名
	self.m_pPlayerName = winMgr:getWindow("shujiazuoye/paper/shuoming/num1")
	if self.m_pPlayerName then
		self.m_pPlayerName:setText(tostring(GetDataManager():GetMainCharacterName()))
	end
	
	-- 得分
	self.m_pScore = winMgr:getWindow("shujiazuoye/paper/fenshu/num")
	
	-- 求助按钮
    self.m_pHelpBtn = CEGUI.Window.toPushButton(winMgr:getWindow("shujiazuoye/help"))
	if self.m_pHelpBtn then
		self.m_pHelpBtn:subscribeEvent("Clicked", HomeworkDlg.HandleHelpBtnClick, self) 
	end
	
	-- 领奖按钮
    self.m_pBonusBtn = CEGUI.Window.toPushButton(winMgr:getWindow("shujiazuoye/banjiang"))
	if self.m_pBonusBtn then
		self.m_pBonusBtn:subscribeEvent("Clicked", HomeworkDlg.HandleBonusBtnClick, self) 
	end
	
	-- 获得今天的任务表
	local tQuestId = HomeworkDlg.getQuestId()
	if type(tQuestId) ~= 'table' then return end
	
	-- 任务内容和完成标记
	self.m_vQuest = {}
	self.m_vComplete = {}

	for i = 1,5 do
		local suffix = ''
		if i > 1 then
			suffix = i - 1
		end
		self.m_vQuest[i] = winMgr:getWindow("shujiazuoye/paper/neirong/renwu"..suffix)
		self.m_vComplete[i] = winMgr:getWindow("shujiazuoye/paper/neirong/renwu/yes"..suffix)
		
		-- 根据任务id显示任务内容
		local id = tQuestId['id'..i]
		if type(id) == 'number' then 
			local tQuest = MHSD_UTILS.getLuaBean("knight.gsp.game.cshujiazuoyeleixing", id)
			if type(tQuest) == 'table' and self.m_vQuest[i] then	
				self.m_vQuest[i]:setText(tostring(tQuest.miaoshu)) 
			end
		end
	end
end

------------------- private: -----------------------------------

function HomeworkDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, HomeworkDlg)

    return self
end

-- 根据当前日期获得5个任务的id
function HomeworkDlg.getQuestId()
	
	local nServerTime = GetServerTime()
	if not nServerTime then return end

	local tTime = os.date("*t", math.floor(nServerTime / 1000))
	if not tTime or not tTime.year or not tTime.month or not tTime.day then return end
	
	local nDate = tTime.year * 10000 + tTime.month * 100 + tTime.day
	if not nDate then return end

	local tQuestId = MHSD_UTILS.getLuaBean("knight.gsp.game.cshujiazuoyepeizhi", nDate)

	return tQuestId
end

-- 刷新界面信息
function HomeworkDlg:refreshInfo(canReward, states)

	if type(states) ~= 'table' then return end

	-- 获得今天的任务表
	local tQuestId = HomeworkDlg.getQuestId()
	if type(tQuestId) ~= 'table' then return end
	
	-- 完成的任务打钩
	for i = 1,5 do
		local nQuestId = tQuestId['id'..i]
		if self.m_vComplete[i] and nQuestId then
			for _,homeworkState in ipairs(states) do
				if homeworkState.id and homeworkState.id == nQuestId then		
					self.m_vComplete[i]:setVisible(homeworkState.finish == 1)
				end
			end
		end
	end
	
	-- 计算得分
	self.m_iScore = 0
	for _,homeworkState in ipairs(states) do
		if homeworkState.finish == 1 then
			self.m_iScore = self.m_iScore + 20
		end
	end
	
	-- 更新得分
	if self.m_pScore then
		self.m_pScore:setText(tostring(self.m_iScore))
	end
	
	-- 设置领奖按钮是否可以点击
	if self.m_pBonusBtn then
		self.m_pBonusBtn:setEnabled(canReward == 1)
	end
	
	-- 设置求助按钮是否可以点击
	if self.m_pHelpBtn then
		if canReward == 1 and self.m_iScore < 100 then
			self.m_pHelpBtn:setEnabled(true)
		else
			self.m_pHelpBtn:setEnabled(false)
		end	
	end
end

-- 点击求助
function HomeworkDlg:HandleHelpBtnClick(args)

	-- Ok回调
	local okfunction = function(self)	
		local CHomeworkHelp = require 'protocoldef.knight.gsp.activity.homework.chomeworkhelp'
		local help = CHomeworkHelp.Create()	
		LuaProtocolManager.getInstance():send(help)
		GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
	end
	
	-- 弹出二次确认
	GetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(146297), okfunction, self, CMessageManager.HandleDefaultCancelEvent, CMessageManager)
end

-- 点击领奖
function HomeworkDlg:HandleBonusBtnClick(args)

	-- Ok回调
	local okfunction = function(self)
		local CHomeworkReward = require 'protocoldef.knight.gsp.activity.homework.chomeworkreward'
		local reward = CHomeworkReward.Create()	
		LuaProtocolManager.getInstance():send(reward)
		GetMessageManager():CloseConfirmBox(eConfirmNormal, false)
	end
	
	-- 没有全部完成会弹出二次确认，否则直接进入确定流程
	if self.m_iScore == 100 then
		okfunction(self)
	else
		GetMessageManager():AddConfirmBox(eConfirmNormal, MHSD_UTILS.get_msgtipstring(146291), okfunction, self, CMessageManager.HandleDefaultCancelEvent, CMessageManager)
	end
end

return HomeworkDlg