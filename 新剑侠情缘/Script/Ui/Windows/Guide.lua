

local tbGuide = Ui:CreateClass("Guide");


local tbDescPanel = {"TargetTop", "TargetButtom", "TargetLeft", "TargetRight", "DownDesc", "UpDesc"}
local tbDescType = 
{
	PopT 	= {"TargetTop", 	"TxtDescT"},
	PopB 	= {"TargetButtom", 	"TxtDescB"},
	PopL	= {"TargetLeft", 	"TxtDescL"},
	PopR	= {"TargetRight", 	"TxtDescR"},
	
	NpcDown	= {"DownDesc", "TxtDownDesc"},
	NpcUp 	= {"UpDesc", "TxtUpDesc"},
}

function tbGuide:OnOpen(szDescType, szDesc, pPanel, szWnd, tbPointer, bDisableClick, bBlackBg, bDisableVoice)
	self.TryLockWndTimes = 0;

	local tbUserSet = Ui:GetPlayerSetting();
	self.pPanel:Button_SetCheck("BtnVoice", tbUserSet.bMuteGuideVoice);
	self.pPanel:SetActive("BtnVoice", not bDisableVoice);
	self.pPanel:Label_SetText("Name", Guide.ZHAOLIYING_NAME);
	self:BeginStep(szDescType, szDesc, pPanel, szWnd, tbPointer, bDisableClick, bBlackBg)
end

function tbGuide:BeginStep(szDescType, szDesc, pPanel, szWnd, tbPointer, bDisableClick, bBlackBg)
	self:EndStep()
	
	self:SetDesc(szDescType, szDesc)
	
	if pPanel and szWnd then
		self:SetLockWnd(pPanel, szWnd, tbPointer, bDisableClick, bBlackBg)
		self.pPanel:SetActive("BtnBg", false);
	else
		self.pPanel:SetActive("BtnBg", bDisableClick);
		self.pPanel:SetActive("SprBg", bBlackBg);			
	end
end

function tbGuide:SetLockWnd(pPanel, szWnd, tbPointer, bDisableClick, bBlackBg)
	self:CloseLockWnd()
	if not Ui.UiManager.LockWndToGuideLayer(pPanel, szWnd, bDisableClick, bBlackBg) then
		if self.TryLockWndTimes >= 5 then
			return;
		end

		self.TryLockWndTimes = self.TryLockWndTimes + 1;
		self.nLockWndTimerId = Timer:Register(5, function ()
			Log("[UI][Guide] try lock wnd .......", szWnd, self.TryLockWndTimes);
			self:SetLockWnd(pPanel, szWnd, tbPointer, bDisableClick, bBlackBg);
		end);
		return;
	end

	--self.pPanel:ChangeOtherWndParent(pPanel, szWnd)
	self.pOrgPanel = pPanel;
	self.szOrgWnd = szWnd;
	--local tbPos = pPanel:GetCameraPosition(szWnd)
	self.pPanel:SetActive("LockTarget", true);
	self.pPanel:ChangeWnd2SamePosition("LockTarget", pPanel, szWnd);
	if tbPointer then
		local tbPos = self.pPanel:GetPosition("LockTarget")
		self.pPanel:ChangePosition("LockTarget", tbPos.x + tbPointer[1], tbPos.y + tbPointer[2], 0)
	end

	Log("[UI][Guide] lock wnd .......", szWnd);
end

function tbGuide:CloseLockWnd()
	if self.pOrgPanel and self.szOrgWnd then
		print("Recover Lock Wnd")
		Ui.UiManager.ReleaseWndFromGuideLayer()
		self.pOrgPanel = nil;
		self.szOrgWnd = nil;
		self.pPanel:SetActive("LockTarget", false);
	end

	if self.nLockWndTimerId then
		Timer:Close(self.nLockWndTimerId);
		self.nLockWndTimerId = nil;
	end
end

function tbGuide:SetDesc(szDescType, szDesc)
	local szPanelWnd, szTxtWnd, szPivot = unpack(tbDescType[szDescType] or {})
	for _, szDescPanel in ipairs(tbDescPanel) do
		if szDescPanel == szPanelWnd then
			self.pPanel:SetActive(szPanelWnd, true);
			self.pPanel:Label_SetText(szTxtWnd, szDesc);
		else
			self.pPanel:SetActive(szDescPanel, false);
		end
	end
end

function tbGuide:EndStep()
	self:CloseLockWnd();
	self.bCheckClckScreen = false;
end

function tbGuide:OnClose()
	self:EndStep()
end

function tbGuide:OnGuideClick(szUi, szWnd)
	if self.szOrgWnd and szWnd == self.szOrgWnd then
		
	end
end

tbGuide.tbOnClick = {};
tbGuide.tbOnClick.BtnBg = function (self)
	--Ui:CloseWindow(self.UI_NAME);
	Guide:OnCheckClickScreen()
end

tbGuide.tbOnClick.BtnSkipGuide = function (self)
	RemoteServer.__FinishAllGuide()
	Ui:CloseWindow(self.UI_NAME);
end

tbGuide.tbOnClick.BtnVoice = function (self)
	ChatMgr:OnSwitchNpcGuideVoice()
end

function tbGuide:RegisterEvent()
	local tbRegEvent =
	{
--		{ UiNotify.emNOTIFY_GUIDE_CLICK, 	self.OnGuideClick 	},
--		{ UiNotify.emNOTIFY_WND_OPENED, 	self.OnOpenUi 		},
	};

	return tbRegEvent;
end