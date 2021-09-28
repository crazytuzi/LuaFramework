local Dialog = require "ui.dialog"
local SingletonDialog = require "ui.singletondialog"

local UserMiniIconDlg = {}
setmetatable(UserMiniIconDlg, SingletonDialog)
UserMiniIconDlg.__index = UserMiniIconDlg

UserMiniIconDlg.Precision = 0.5 -- 每秒改变进度
UserMiniIconDlg.MinBarFlashValue = 0.3 -- 进度条闪烁

function UserMiniIconDlg.new()
	local inst = {}
	setmetatable(inst, UserMiniIconDlg)
	inst:OnCreate()
	return inst
end

function UserMiniIconDlg.GetLayoutFileName()
    return "petanduserminiicon.layout"
end

function UserMiniIconDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
	self.m_wIcon = winMgr:getWindow("petanduserminiicon/userHead")
	self.m_wLevel = winMgr:getWindow("petanduserminiicon/UserBack/Level")
	self.m_wHP = CEGUI.Window.toProgressBarTwoValue(winMgr:getWindow("petanduserminiicon/redBar"))
	self.m_wMP = CEGUI.Window.toProgressBar(winMgr:getWindow("petanduserminiicon/blueBar"))
	self.m_wSP = CEGUI.Window.toProgressBar(winMgr:getWindow("petanduserminiicon/angerBar"))

	self:InitData()
	CPetAndUserIcon:GetSingleton():GetWindow():setVisible(false)
end

function UserMiniIconDlg:OnClose()
	Dialog.OnClose(self)
	if CPetAndUserIcon:GetSingleton() and CPetAndUserIcon:GetSingleton():GetWindow() then
		CPetAndUserIcon:GetSingleton():GetWindow():setVisible(true)
	end
end

function UserMiniIconDlg:InitData()
	-- init icon
	local shapeid = GetDataManager():GetMainCharacterShape()
	local shape = knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(shapeid)
	local iconPath = GetIconManager():GetImagePathByID(shape.littleheadID):c_str()
	self.m_wIcon:setProperty("Image",iconPath)

	-- init lv
	local lv = GetDataManager():GetMainCharacterLevel()
	self.m_wLevel:setText(tostring(lv))

	-- hp, mp, sp
	local data = GetDataManager():GetMainCharacterConstData()
	local hp = data:GetValue(60) / data:GetValue(140)
	local hpR = (data:GetValue(140)-data:GetValue(640)) / data:GetValue(140)
	local mp = data:GetValue(70) / data:GetValue(150)
	local sp = data:GetValue(170) / data:GetValue(160)
	self.m_wHP:setProgress(hp)
	self.m_wHP:setReverseProgress(hpR)
	self.m_wMP:setProgress(mp)
	self.m_wSP:setProgress(sp)

	-- effect
	if hp < self.MinBarFlashValue then
		GetGameUIManager():AddUIEffect(self.m_wHP, MHSD_UTILS.get_effectpath(10223))
		self.m_HPEffect = true
	else
		self.m_HPEffect = false
	end
	if mp < self.MinBarFlashValue then
		GetGameUIManager():AddUIEffect(self.m_wMP, MHSD_UTILS.get_effectpath(10225))
		self.m_MPEffect = true
	else
		self.m_MPEffect = false
	end
end

local function calcPro(cur, dest, delta)
	local pdelta = delta*UserMiniIconDlg.Precision/1000
	local value = 0
	if cur < dest then
		value = cur + pdelta
		if value > dest then
			value = dest
		end
	end
	if cur > dest then
		value = cur - pdelta
		if value < dest then
			value = dest
		end
	end
	return value
end

function UserMiniIconDlg:run(delta)
	local data = GetDataManager():GetMainCharacterConstData()
	local hp = data:GetValue(60) / data:GetValue(140)
	local hpR = (data:GetValue(140)-data:GetValue(640)) / data:GetValue(140)
	local mp = data:GetValue(70) / data:GetValue(150)
	local sp = data:GetValue(170) / data:GetValue(160)

	local whp = self.m_wHP:getProgress()
	local whpR = self.m_wHP:getReverseProgress()
	local wmp = self.m_wMP:getProgress()
	local wsp = self.m_wSP:getProgress()

	-- refresh hp
	if math.abs(hp-whp) > 0.0001 then
		whp = calcPro(whp, hp, delta)
		if self.m_HPEffect and whp >= self.MinBarFlashValue then
			GetGameUIManager():RemoveUIEffect(self.m_wHP)
			self.m_HPEffect = false
		end
		if not self.m_HPEffect and whp < self.MinBarFlashValue then
			GetGameUIManager():AddUIEffect(self.m_wHP, MHSD_UTILS.get_effectpath(10223))
			self.m_HPEffect = true
		end
		self.m_wHP:setProgress(whp)
	end

	-- refresh hpr
	if math.abs(hpR-whpR) > 0.0001 then
		whpR = calcPro(whpR, hpR, delta)
		self.m_wHP:setReverseProgress(whpR)
	end

	-- refresh mp
	if math.abs(mp-wmp) > 0.0001 then
		wmp = calcPro(wmp, mp, delta)
		if self.m_MPEffect and wmp >= self.MinBarFlashValue then
			GetGameUIManager():RemoveUIEffect(self.m_wMP)
			self.m_MPEffect = false
		end
		if not self.m_MPEffect and wmp < self.MinBarFlashValue then
			GetGameUIManager():AddUIEffect(self.m_wMP, MHSD_UTILS.get_effectpath(10225))
			self.m_MPEffect = true
		end
		self.m_wMP:setProgress(wmp)
	end

	-- refresh sp
	if math.abs(sp-wsp) > 0.0001 then
		wsp = calcPro(wsp, sp, delta)
		self.m_wSP:setProgress(wsp)
	end
end

return UserMiniIconDlg
