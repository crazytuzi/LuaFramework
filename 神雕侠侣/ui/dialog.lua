Dialog = 
{
	m_pMainFrame=nil,
	m_eDialogType={} ,
	m_bCloseIsHide= false
}

DialogTypeTable = {
    eDlgTypeNull = 1,
	eDlgTypeTimeLimit = 2,
	eDlgTypeBattleClose = 3,
	eDlgTypeMoveClose = 4,
	eDlgTypeRBtnClose = 5,
	eDlgTypeMapChangeClose = 6,
	eDlgTypeSceneMovieWnd = 7,
	eDlgTypeInScreenCenter = 8,	
	eDlgTypeMax = 9
}

local ButtonManager = require "ui.buttons.buttonmanager"

Dialog.__index = Dialog

function Dialog:new()
    local self = {}
    setmetatable(self, Dialog)
    return self
end

function Dialog.DestroyDialog()
end

function Dialog:OnCreate(parentwindow, nameprefix)
	--nameprefix default value ""
	if not nameprefix then nameprefix = "" end

    local winMgr = CEGUI.WindowManager:getSingleton()

    fileName = self.GetLayoutFileName()
    print("lua load layout"..nameprefix..fileName)
    self.m_pMainFrame = winMgr:loadWindowLayout(fileName, nameprefix)
	if not self.m_pMainFrame then 
		print(filename .. " layout load error")
		return
	end

    -- if sheet not exist, return 
    local root = CEGUI.System:getSingleton():getGUISheet() 
    if not root then return end
	if self.m_pMainFrame == root then return end

	if not parentwindow then
		if GetSceneMovieManager() then
			if GetSceneMovieManager():isOnSceneMovie() then
				if GetGameUIManager():GetMainRootWnd() then
					if self.m_eDialogType[eDlgTypeSceneMovieWnd] then
						root:addChildWindow(self.m_pMainFrame)
					else
						GetGameUIManager():AddWndToRootWindow(self.m_pMainFrame)
					
					end
				end
			else
				root:addChildWindow(self.m_pMainFrame)
			end
		else
			root:addChildWindow(self.m_pMainFrame)
		end
	else
		parentwindow:addChildWindow(self.m_pMainFrame)
		self.m_pParentWindow = parentwindow
	end

	if self.m_eDialogType[eDlgTypeInScreenCenter] then 
		self.m_pMainFrame:CenterInParent()
	end

	if self.m_pMainFrame:GetCreateWndEffect() ~= CEGUI.CreateWndEffect_None then
		self.m_pMainFrame:BeginCreateEffect()
	end

	local closeBtn = self:GetCloseBtn()
	if closeBtn then 
		closeBtn:subscribeEvent("Clicked", self.HandleCloseBtnClick, self);
	end

	self.m_pMainFrame:subscribeEvent("Shown", self.HandleDialogOpen, self);
	self.m_pMainFrame:subscribeEvent("Hidden", self.HandleDialogClose, self);
	self.m_pMainFrame:subscribeEvent("DestructStart", self.HandleDialogClose, self);
	
	if self.m_pMainFrame:GetCloseWndEffect() ~= CEGUI.CloseWndEffect_None then
		self.m_pMainFrame:subscribeEvent("CloseWndEffectEnd", self.HandleCloseEffectEnd, self)
	end

	if self.m_pMainFrame:isModalAfterShow() then
		self.m_pMainFrame:setModalState(true)
	end
	if not self.m_pParentWindow then
		LuaUIManager.getInstance():AddDialog(self.m_pMainFrame, self)
	end

	if self.bm_needButtonManage == nil then
		self:CheckBtnManage()
	end
	if self.bm_needButtonManage then
		ButtonManager:getInstance():AddButton(self)
	end
end

function Dialog:CheckBtnManage()
	local BtnConfig = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cjiemianbtn")
	local ids = BtnConfig:getAllID()
	for k,v in pairs(ids) do
		local record = BtnConfig:getRecorder(v)
		if self:GetLayoutFileName() == record.layout then
			print("Dialog CheckBtnManage pass "..tostring(self:GetLayoutFileName()))
			self.bm_needButtonManage = true
			self.bm_rowIndex = record.rank
			self.bm_sort = record.sort
			self.bm_show = record.xianshizhuangtai
			return
		end
	end
	self.bm_needButtonManage = false
end

function Dialog:OnClose()
    if not self.m_pMainFrame then return end

    if self.bm_needButtonManage then
    	ButtonManager:getInstance():RemoveButton(self)
    end
    
	if self.m_pMainFrame:GetCloseWndEffect() ~= CEGUI.CloseWndEffect_None then
		if self.m_pMainFrame:GetWndEffectState() ~= CEGUI.WndEffectState_Close then
			self.m_pMainFrame:BeginCloseEffect()
			return
		end
	end

	if self.m_bCloseIsHide then
		self.m_pMainFrame:hide()
	else
		if not self.m_pParentWindow then
			LuaUIManager.getInstance():RemoveUIDialog(self.m_pMainFrame)
		end
		CEGUI.WindowManager:getSingleton():destroyWindow(self.m_pMainFrame)
		self.m_p_MainFrame = nil
		self = nil
	end

end

function Dialog:IsVisible()
	if self.m_pMainFrame then
		return self.m_pMainFrame:isVisible()
	else
		return false
	end
end

function Dialog:SetVisible(bVisible)
    if not self.m_pMainFrame then return end

	bOldIsVis = self.m_pMainFrame:isVisible()

	if bVisible ~= bOldIsVis then
		if (self.m_pMainFrame:GetCreateWndEffect() ~= CEGUI.CreateWndEffect_None)
					and bOldIsVis then
			self.m_pMainFrame:BeginCreateEffect()
		end
		if (self.m_pMainFrame:GetCloseWndEffect() ~= CEGUI.CloseWndEffect_None)
					and bOldIsVis then
			self.m_pMainFrame:BeginCloseEffect()
		end
	end

    self.m_pMainFrame:setVisible(bVisible)

    if bVisible then 
		self.m_pMainFrame:activate() 

		if self.m_pMainFrame:isModalAfterShow() then
			self.m_pMainFrame:setModalState(true)
		end
	end

	if self.bm_needButtonManage then
		if bVisible then
			ButtonManager.getInstance():AddButton(self)
		else
			ButtonManager.getInstance():RemoveButton(self)
		end
	end
end
    
function Dialog.GetLayoutFileName()
    return ""
end

function Dialog:GetMainFrame()
    return self.m_pMainFrame
end

function Dialog:GetCloseBtn()
	if not self.m_pMainFrame then return nil end
	if self.m_pMainFrame:getType():find("FrameWindow") then
		pFrame = CEGUI.toFrameWindow(self.m_pMainFrame)
		return pFrame:getCloseButton()
	end

	return nil
end

function Dialog:GetWindow()
	return self.m_pMainFrame
end

function Dialog:HandleDialogOpen(args)
    if self:GetWindow():isModalAfterShow() then
        self:GetWindow():setModalState(true)
	end
	return true
end

function Dialog:HandleDialogClose(args)
    if self:GetWindow():isModalAfterShow() then
        self:GetWindow():setModalState(false)
	end
	return true
end

function Dialog:HandleCloseEffectEnd(args)
	if not self.m_pMainFrame then return true end

    local windowArgs = CEGUI.toWindowEventArgs(args)
	if windowArgs.window == self:GetWindow() then
        self:OnClose()
	end

	return true
end

function Dialog:HandleCloseBtnClick(args)
	self:DestroyDialog()
	return true
end

return Dialog
