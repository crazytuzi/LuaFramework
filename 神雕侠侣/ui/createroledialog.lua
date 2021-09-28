local single = require "ui.singletondialog"

local CCreateRoleDialog = {}
setmetatable(CCreateRoleDialog, single)
CCreateRoleDialog.__index = CCreateRoleDialog

local ROLE_PIC_NUM = 5
local SCHOOL_BTN_NUM = 3
local ROLE_NUM = 8
local INITROLE = 7 
local SCHOOL_INFO_WORDS = 8
local function XiaoPangFRECT(l, t, r, b)
	local frect = {}
	frect.left = l
	frect.top = t
	frect.right = r
	frect.bottom = b
	return frect
end

local function Width(frect)
	return frect.right - frect.left 
end

local function Height(frect)
	return frect.bottom - frect.top 
end
--enumCreateRoleMovingState
local eMovingLeft = 0
local eMovingRight = 1
local eStop = 2
----------
local moveTime = 1.0
local coolDownTime = 1.0
local schoolInfoShow = 0.2
local schoolInfoScale = 1.0

function CCreateRoleDialog.new()
	local self = {}
	setmetatable(self, CCreateRoleDialog)
	function self.GetLayoutFileName()
		return "charactercreateddlg.layout"
	end
	require "ui.dialog".OnCreate(self)
	self.m_iSelectedSchool = 0
	self.m_iModelID = 0
	self.m_fCoolDownTime = 0
	self.m_bChangedPic = false
	self.m_fSchoolInfoShowTime = 0
	self.m_bShowSchoolInfo = false
	self.m_eDialogType = eDlgTypeNull
	self.m_eMovingState = eStop
	self.m_iRoleId = {}
    self.m_pRolePic = {}
	self:InitRoleList()
	local winMgr = CEGUI.WindowManager:getSingleton()
    
    self.m_pRandomName = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/Back/Tube"))
    self.m_pRandomName:subscribeEvent("Clicked", CCreateRoleDialog.HandleRandomClicked,self)
    
    self.m_pNameEdit = CEGUI.toEditbox(winMgr:getWindow("CharacterCreatedDlg/Back/NameBack/Name"))
    self.m_pNameEdit:SetShieldSpace(true)
	self.m_pNameEdit:setMaxTextLength(8)
	self.m_pNameEdit:SetFrameEnabled(false)

    self.m_pFinishBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/Back/OK"))
    self.m_pFinishBtn:subscribeEvent("Clicked", CCreateRoleDialog.HandleFinishBtnClicked,self)
    
    self.m_pReturnBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/Back/OK1"))
    self.m_pReturnBtn:subscribeEvent("Clicked", CCreateRoleDialog.HandleReturnBtnClicked,self)
    local platform = require "config".CUR_3RD_PLATFORM

	if platform ==  "app" or platform == "kuaiyong" then
	    self.m_pReturnBtn:setVisible(false)
	end
    self.m_pLeftBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/Back/role/left"))
    self.m_pLeftBtn:subscribeEvent("Clicked", CCreateRoleDialog.HandleLeftClicked,self)
    
    self.m_pRightBtn = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/Back/role/right"))
    self.m_pRightBtn:subscribeEvent("Clicked", CCreateRoleDialog.HandleRightClicked,self)
    self.m_pSchoolBtn = {}
    for i = 0 , SCHOOL_BTN_NUM - 1 do
        self.m_pSchoolBtn[i] = CEGUI.toPushButton(winMgr:getWindow("CharacterCreatedDlg/Back/Shcool"..(i + 1)))
        self.m_pSchoolBtn[i]:subscribeEvent("Clicked", CCreateRoleDialog.HandleSchoolSelected,self)
    end
  	self.m_pRolePic = {}
  	self.m_rPos = {}
    for i = 0 , ROLE_PIC_NUM - 1 do
        self.m_pRolePic[i] = winMgr:getWindow("CharacterCreatedDlg/role"..i)
        self.m_rPos[i] = XiaoPangFRECT(self.m_pRolePic[i]:GetTopLeftPosOnParent().x, 
        	self.m_pRolePic[i]:GetTopLeftPosOnParent().y, 
        	self.m_pRolePic[i]:GetTopLeftPosOnParent().x + self.m_pRolePic[i]:getPixelSize().width, 
        	self.m_pRolePic[i]:GetTopLeftPosOnParent().y + self.m_pRolePic[i]:getPixelSize().height)
    end
     self.m_pSchoolInfo = {}
     self.m_rSchoolPos = {}
    for i = 0 , SCHOOL_INFO_WORDS - 1 do
        self.m_pSchoolInfo[i] = winMgr:getWindow("CharacterCreatedDlg/pic/school"..(i + 1))
        self.m_pSchoolInfo[i]:setVisible(false)
        self.m_rSchoolPos[i] = XiaoPangFRECT(self.m_pSchoolInfo[i]:GetTopLeftPosOnParent().x, 
        self.m_pSchoolInfo[i]:GetTopLeftPosOnParent().y, 
        self.m_pSchoolInfo[i]:GetTopLeftPosOnParent().x + self.m_pSchoolInfo[i]:getPixelSize().width, 
        self.m_pSchoolInfo[i]:GetTopLeftPosOnParent().y + self.m_pSchoolInfo[i]:getPixelSize().height)
    end
    self.m_pRoleSelectBtn = {}
    for i = 0, ROLE_NUM - 1 do
        self.m_pRoleSelectBtn[i] = winMgr:getWindow("CharacterCreatedDlg/roleBack/school/light"..(i + 1))
        self.m_pRoleSelectBtn[i]:setVisible(true)
    end
    
    self.m_pPane = CEGUI.toScrollablePane(winMgr:getWindow("CharacterCreatedDlg/Back/role/control__auto_container__"))
    self.m_pPane:subscriberEventDrag(CCreateRoleDialog.HandleDragEvent,self)
    
    self.midEffects = winMgr:getWindow("CharacterCreatedDlg/Back/role/back2/effect")
    
    self.m_iModelID = INITROLE --math.random(0, ROLE_NUM - 1)
    self:SetPicture()
    
    self.m_pMainFrame:subscribeEvent("WindowUpdate", CCreateRoleDialog.HandleWindowUpdate, self)



	GetGameUIManager():AddUIEffect(self.m_pFinishBtn, require("utils.mhsdutils").get_effectpath(10421))
    
     self:playRoleEffect()
	return self
end

function CCreateRoleDialog:SetPicture()
	local i = self.m_iModelID
    for j = 0, ROLE_PIC_NUM - 1 do
    --    if (j == 0) then
  --          i = i + 1
  --      end
		local foo = (i + ROLE_NUM - 2 ) % ROLE_NUM
        local roleId = self.m_iRoleId[foo]
        local config = knight.gsp.role.GetCreateRoleConfigTableInstance():getRecorder(roleId)
        self.m_pRolePic[j]:setProperty("Image", "set:rolebig"..(foo + 1).." image:"..config.roleimage)
    	i = i + 1
    end
    self:RefreshRoleBtnState()
    self:SetSchoolSelected(self.m_pSchoolBtn[0])

end

function CCreateRoleDialog:RefreshRoleBtnState()
    for i = 0, ROLE_NUM - 1 do
        if (self.m_iModelID == i) then
            self.m_pRoleSelectBtn[i]:setProperty("Image", "set:LoginBack1 image:rolelight")
        else
            self.m_pRoleSelectBtn[i]:setProperty("Image", "set:LoginBack1 image:rolenormal")
        end
    end
end
local function getSchoolStr(id)
    if id == 11 then
    	return "gumu"
    elseif id == 12 then
    	return "gaibang"
    elseif id == 14 then
    	return "baituo"
    elseif id == 15 then
    	return "dali"
    elseif id == 17 then
    	return "taohua"
	elseif id == 19 then
    	return "baihua"
    else
    	return ""
    end
end

--更新帮派按钮状态
function CCreateRoleDialog:SetSchoolSelected(pWnd)
    local config = knight.gsp.role.GetCreateRoleConfigTableInstance():getRecorder(self.m_iRoleId[self.m_iModelID])
    for i = 0, SCHOOL_BTN_NUM - 1 do
		GetGameUIManager():RemoveUIEffect(self.m_pSchoolBtn[i])
        if (pWnd == self.m_pSchoolBtn[i]) then
            self.m_pSchoolBtn[i]:setProperty("NormalImage", "set:LoginBack6 image:"..getSchoolStr(config.schools[i]).."Hnormal");
            self.m_pSchoolBtn[i]:setProperty("HoverImage", "set:LoginBack6 image:"..getSchoolStr(config.schools[i]).."Hpushed");
            self.m_pSchoolBtn[i]:setProperty("PushedImage", "set:LoginBack6 image:"..getSchoolStr(config.schools[i]).."Hpushed");
            if (self.m_iSelectedSchool ~= config.schools[i]) then
            
                self.m_iSelectedSchool = config.schools[i]
                for j = 0, SCHOOL_INFO_WORDS - 1 do
                    self.m_pSchoolInfo[j]:setProperty("Image", "set:LoginBack1  image:"..getSchoolStr(config.schools[i])..(j + 1));
                    self.m_pSchoolInfo[j]:setVisible(false);
                end
                self.m_bShowSchoolInfo = true
                self.m_fSchoolInfoShowTime = 0
            end
			GetGameUIManager():AddUIEffect(self.m_pSchoolBtn[i], require("utils.mhsdutils").get_effectpath(10420))
        else
            self.m_pSchoolBtn[i]:setProperty("NormalImage", "set:LoginBack6 image:"..getSchoolStr(config.schools[i]).."normal");
            self.m_pSchoolBtn[i]:setProperty("HoverImage", "set:LoginBack6 image:"..getSchoolStr(config.schools[i]).."pushed");
            self.m_pSchoolBtn[i]:setProperty("PushedImage", "set:LoginBack6 image:"..getSchoolStr(config.schools[i]).."pushed");
        end
    end
end

function CCreateRoleDialog:GiveNameByQianTong(givename)
	self.m_pNameEdit:setText(givename)
	self.m_pNameEdit:setCaratIndex(string.len(self.m_pNameEdit:getText()))
end

function CCreateRoleDialog:HandleRandomClicked(e)
    local givemename = require "protocoldef.knight.gsp.crequestnamebyqiantong":new()
    
    local roleId = self.m_iRoleId[self.m_iModelID]
    local config = knight.gsp.role.GetCreateRoleConfigTableInstance():getRecorder(roleId)
    local RoleSex = require "protocoldef.rpcgen.knight.gsp.rolesex":new()
    if (config.sex == 1) then
        givemename.sex = RoleSex.MALE
    elseif (config.sex == 2) then
        givemename.sex = RoleSex.FEMALE
    end

    require "manager.luaprotocolmanager":send(givemename)
    self.m_fCoolDownTime = 0
    self.m_pRandomName:setEnabled(false)
    
    return true;
end

--创建完成
function CCreateRoleDialog:HandleFinishBtnClicked(e)
	if (self.m_iSelectedSchool == 0) then
		return true
	end

	if (self.m_iRoleId[self.m_iModelID] == 0) then
		return true
	end
    
	local editname = self.m_pNameEdit:getText()
	if (not editname or string.len(editname) == 0) then
        --你还没为你的角色取名呢，快给你的角色取一个响亮的名字吧。
		GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(141317).msg,false)
		return true;
	end
    
    
	local CreateRoleCmd = require "protocoldef.knight.gsp.ccreaterole":new()
	CreateRoleCmd.name = editname
	CreateRoleCmd.school = self.m_iSelectedSchool
	CreateRoleCmd.shape = self.m_iRoleId[self.m_iModelID]
	require "manager.luaprotocolmanager":send(CreateRoleCmd)
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "kuwo" then
        require "luaj"
        luaj.callStaticMethod("com.wanmei.mini.condor.kuwo.PlatformKuwo", "roleCreated", {}, "()V")
    end
    if Config.MOBILE_ANDROID == 1 and Config.CUR_3RD_LOGIN_SUFFIX == "lngz" then
        require "luaj"
        luaj.callStaticMethod("com.wanmei.mini.condor.longzhong.PlatformLongZhong", "createRole", {}, "()V")
    end
	return true;
end

function CCreateRoleDialog:HandleReturnBtnClicked(e)
	local trd_platform = require "config".TRD_PLATFORM
	if trd_platform==1 then
		SDXL.ChannelManager:ChangeUserLogin()
	else
		local dlg = LoginDialog.getInstanceAndShow()
	end
	if GetLoginManager() then
		GetLoginManager():Init()
	end
	self:DestroyDialog()
end

function CCreateRoleDialog:DestroyDialog()
	if self._instance then
		GetGameUIManager():RemoveUIEffect(self._instance.midEffects)
		GetGameUIManager():RemoveUIEffect(self._instance.m_pFinishBtn)
		for i = 0, SCHOOL_BTN_NUM - 1 do
			GetGameUIManager():RemoveUIEffect(self._instance.m_pSchoolBtn[i])
		end
		self:OnClose()
		getmetatable(self)._instance = nil
	end
end


function CCreateRoleDialog:HandleLeftClicked(e)
    self.m_fMoveElapseTime = 0
    self.m_eMovingState = eMovingLeft
    self.m_bChangedPic = false
    return true
end

--点击向右按钮
function CCreateRoleDialog:HandleRightClicked(e)
    self.m_fMoveElapseTime = 0
    self.m_eMovingState = eMovingRight
    self.m_bChangedPic = false
    
    return true
end

function CCreateRoleDialog:HandleSchoolSelected(e)
    local WndArgs = CEGUI.toWindowEventArgs(e)
    self:SetSchoolSelected(WndArgs.window)
    return true
end

function CCreateRoleDialog:HandleDragEvent(e)
    local GestureArgs = CEGUI.toGestureEventArgs(e);
  
    local pPanRecognizer = tolua.cast(GestureArgs.d_Recognizer, "CEGUI::Gesture::CEGUIPanGestureRecognizer")
    print("Direction type="..pPanRecognizer:GetPanDirection())
    print("self.m_eMovingState"..self.m_eMovingState)
    if (pPanRecognizer:GetPanDirection() == 1
    --CEGUI.Gesture.UIPanGestureRecognizerDirectionRight 
    	and self.m_eMovingState ~= eMovingRight) then
        GetGameUIManager():RemoveUIEffect(self.midEffects)
        self.m_fMoveElapseTime = 0
        self.m_eMovingState = eMovingRight;
        self.m_bChangedPic = false;
    elseif (pPanRecognizer:GetPanDirection() == 2
    --CEGUI.Gesture.UIPanGestureRecognizerDirectionLeft
     and self.m_eMovingState ~= eMovingLeft) then
        GetGameUIManager():RemoveUIEffect(self.midEffects)
        self.m_fMoveElapseTime = 0
        self.m_eMovingState = eMovingLeft;
        self.m_bChangedPic = false;
    end
    return true;
end

function CCreateRoleDialog:InitRoleList()
    self.m_iRoleId[0] = 9;       --云夕
    self.m_iRoleId[1] = 2;       --秦少游
    self.m_iRoleId[2] = 10;      --韩忆
    self.m_iRoleId[3] = 4;       --司马长风
    self.m_iRoleId[4] = 7;       --独孤月
    self.m_iRoleId[5] = 3;       --燕重光
    self.m_iRoleId[6] = 8;			--靠    
    self.m_iRoleId[7] = 5;			--靠
end
local function cegui_absdim(v)
	return CEGUI.UDim(0, v)
end
function CCreateRoleDialog:FinishMoving()
    for i = 0, ROLE_PIC_NUM-1 do
        self.m_pRolePic[i]:setXPosition(CEGUI.UDim(0, self.m_rPos[i].left))
        self.m_pRolePic[i]:setYPosition(CEGUI.UDim(0, self.m_rPos[i].top))
    end
    self.m_pRolePic[0]:setAlpha(1.0)
    self.m_eMovingState = eStop;
    self:playRoleEffect()
end

function CCreateRoleDialog:playRoleEffect()
    local config = knight.gsp.role.GetCreateRoleConfigTableInstance():getRecorder(self.m_iRoleId[self.m_iModelID])
    GetGameUIManager():RemoveUIEffect(self.midEffects)
	GetGameUIManager():AddUIEffect(self.midEffects, config.effectpath,true)
end
function CCreateRoleDialog:HandleWindowUpdate(e)
	local updateArgs = CEGUI.toUpdateEventArgs(e)
	local elapsed = updateArgs.d_timeSinceLastFrame
	if (self.m_bShowSchoolInfo) then
        self.m_fSchoolInfoShowTime = self.m_fSchoolInfoShowTime + elapsed
        local i = 0
        for j = 0, (self.m_fSchoolInfoShowTime / schoolInfoShow) do
            if (j == SCHOOL_INFO_WORDS) then
                self.m_bShowSchoolInfo = false;
                break;
            end
            self.m_pSchoolInfo[j]:setVisible(true);
            i = i + 1
        end
        for j = 0,  i - 1 do
            self.m_pSchoolInfo[j]:setXPosition(cegui_absdim(self.m_rSchoolPos[j].left));
            self.m_pSchoolInfo[j]:setYPosition(cegui_absdim(self.m_rSchoolPos[j].top));
            self.m_pSchoolInfo[j]:setWidth(cegui_absdim(Width(self.m_rSchoolPos[j])));
            self.m_pSchoolInfo[j]:setHeight(cegui_absdim(Height(self.m_rSchoolPos[j])));
        end
        if (self.m_bShowSchoolInfo) then
            self.m_pSchoolInfo[i - 1]:setXPosition(cegui_absdim(
            	self.m_rSchoolPos[i - 1].left - (Width(self.m_rSchoolPos[i - 1])) / 2 
            	+ (self.m_fSchoolInfoShowTime - 
            	math.floor(self.m_fSchoolInfoShowTime / schoolInfoShow) * schoolInfoShow) 
            	/ schoolInfoShow * schoolInfoScale * Width(self.m_rSchoolPos[i - 1]) / 2));
            self.m_pSchoolInfo[i - 1]:setYPosition(cegui_absdim(
            self.m_rSchoolPos[i - 1].top - (Height(self.m_rSchoolPos[i - 1])) / 2
               + (self.m_fSchoolInfoShowTime - 
               math.floor(self.m_fSchoolInfoShowTime / schoolInfoShow) * schoolInfoShow) 
               / schoolInfoShow * schoolInfoScale * Height(self.m_rSchoolPos[i - 1]) / 2));
            self.m_pSchoolInfo[i - 1]:setWidth(cegui_absdim(Width(self.m_rSchoolPos[i - 1]) 
              * (1 + schoolInfoScale) - (self.m_fSchoolInfoShowTime - 
              math.floor(self.m_fSchoolInfoShowTime / schoolInfoShow) * schoolInfoShow) 
              / schoolInfoShow * schoolInfoScale * Width(self.m_rSchoolPos[i - 1])));
            self.m_pSchoolInfo[i - 1]:setHeight(cegui_absdim(Height(self.m_rSchoolPos[i - 1]) 
            * (1 + schoolInfoScale) - (self.m_fSchoolInfoShowTime - 
            math.floor(self.m_fSchoolInfoShowTime / schoolInfoShow) * schoolInfoShow) 
            / schoolInfoShow * schoolInfoScale * Height(self.m_rSchoolPos[i - 1])));
        end
    end
    
    if (self.m_fCoolDownTime < coolDownTime) then
        self.m_fCoolDownTime = self.m_fCoolDownTime + elapsed
        if (self.m_fCoolDownTime >= coolDownTime) then
            self.m_pRandomName:setEnabled(true);
        end
    end
    
    if (self.m_eMovingState == eStop) then
        return true
    end
    
    if (self.m_eMovingState == eMovingRight) then
        self.m_fMoveElapseTime = self.m_fMoveElapseTime + elapsed

        if (self.m_fMoveElapseTime <= moveTime / 2) then
            for i = 0, ROLE_PIC_NUM - 1 do
                self.m_pRolePic[i]:setXPosition(cegui_absdim(self.m_rPos[i].left 
                + ((self.m_fMoveElapseTime / moveTime) * Width(self.m_rPos[i]))));
            end
            
            self.m_pRolePic[1]:setYPosition(cegui_absdim(self.m_rPos[1].top 
            - (self.m_fMoveElapseTime / moveTime) * (self.m_rPos[1].bottom - self.m_rPos[2].bottom)));
            self.m_pRolePic[3]:setYPosition(cegui_absdim(self.m_rPos[3].top 
            + (self.m_fMoveElapseTime / moveTime) * (self.m_rPos[4].bottom - self.m_rPos[3].bottom)));
            self.m_pRolePic[4]:setYPosition(cegui_absdim(self.m_rPos[4].top 
            + (self.m_fMoveElapseTime / moveTime) * (self.m_rPos[0].bottom - self.m_rPos[4].bottom)));
            self.m_pRolePic[0]:setAlpha(1 - 2 * self.m_fMoveElapseTime / moveTime);
        elseif (self.m_fMoveElapseTime > moveTime / 2 and self.m_fMoveElapseTime < moveTime) then
            if (not self.m_bChangedPic) then
                self.m_iModelID = self.m_iModelID + ROLE_NUM - 1;
                self.m_iModelID = self.m_iModelID%ROLE_NUM;
                self:SetPicture();
                self.m_bChangedPic = true;
            end
            
            for i = 0, ROLE_PIC_NUM - 1 do
                self.m_pRolePic[i]:setXPosition(cegui_absdim(self.m_rPos[i].left 
                - Width(self.m_rPos[i]) / 2 + (((self.m_fMoveElapseTime - moveTime / 2) / moveTime) * Width(self.m_rPos[i]))));
            end
            
            self.m_pRolePic[1]:setYPosition(cegui_absdim(self.m_rPos[1].top 
            + (self.m_rPos[0].bottom - self.m_rPos[1].bottom) / 2 
            - ((self.m_fMoveElapseTime - moveTime / 2) / moveTime) 
            * (self.m_rPos[0].bottom - self.m_rPos[1].bottom)));
            self.m_pRolePic[2]:setYPosition(cegui_absdim(self.m_rPos[2].top 
            + (self.m_rPos[1].bottom - self.m_rPos[2].bottom) / 2 
            - ((self.m_fMoveElapseTime - moveTime / 2) / moveTime) 
            * (self.m_rPos[1].bottom - self.m_rPos[2].bottom)));
            self.m_pRolePic[3]:setYPosition(cegui_absdim(self.m_rPos[3].top));
            self.m_pRolePic[4]:setYPosition(cegui_absdim(self.m_rPos[4].top 
            - (self.m_rPos[4].bottom - self.m_rPos[3].bottom) / 2 
            + ((self.m_fMoveElapseTime - moveTime / 2) / moveTime) 
            * (self.m_rPos[4].bottom - self.m_rPos[3].bottom)));
            self.m_pRolePic[0]:setAlpha(2 * (self.m_fMoveElapseTime - moveTime / 2) / moveTime);
        else
            self:FinishMoving();
        end
    elseif (self.m_eMovingState == eMovingLeft) then
        self.m_fMoveElapseTime = self.m_fMoveElapseTime + elapsed;
        
        if (self.m_fMoveElapseTime <= moveTime / 2) then
            for i = 0, ROLE_PIC_NUM -1 do
                self.m_pRolePic[i]:setXPosition(cegui_absdim(self.m_rPos[i].left 
                - ((self.m_fMoveElapseTime / moveTime) 
                * Width(self.m_rPos[i]))));
            end
            
            self.m_pRolePic[1]:setYPosition(cegui_absdim(self.m_rPos[1].top 
            + (self.m_fMoveElapseTime / moveTime) * (self.m_rPos[0].bottom - self.m_rPos[1].bottom)));
            self.m_pRolePic[2]:setYPosition(cegui_absdim(self.m_rPos[2].top 
            + (self.m_fMoveElapseTime / moveTime) * (self.m_rPos[1].bottom - self.m_rPos[2].bottom)));
            self.m_pRolePic[4]:setYPosition(cegui_absdim(self.m_rPos[4].top 
            - (self.m_fMoveElapseTime / moveTime) * (self.m_rPos[0].bottom - self.m_rPos[4].bottom)));
            self.m_pRolePic[0]:setAlpha(1 - 2 * self.m_fMoveElapseTime / moveTime)
        elseif (self.m_fMoveElapseTime > moveTime / 2 and self.m_fMoveElapseTime < moveTime) then
            if (not self.m_bChangedPic) then
                self.m_iModelID = self.m_iModelID + 1
                self.m_iModelID = self.m_iModelID%ROLE_NUM;
                self:SetPicture();
                self.m_bChangedPic = true;
            end
            
            for i = 0, ROLE_PIC_NUM-1 do
                self.m_pRolePic[i]:setXPosition(cegui_absdim(self.m_rPos[i].left 
                + Width(self.m_rPos[i]) / 2 - (((self.m_fMoveElapseTime - moveTime / 2) / moveTime) * Width(self.m_rPos[i]))));
            end
            self.m_pRolePic[1]:setYPosition(cegui_absdim(self.m_rPos[1].top - (self.m_rPos[1].bottom - self.m_rPos[2].bottom) / 2 + ((self.m_fMoveElapseTime - moveTime / 2) / moveTime) * (self.m_rPos[1].bottom - self.m_rPos[2].bottom)));
            self.m_pRolePic[2]:setYPosition(cegui_absdim(self.m_rPos[2].top));
            self.m_pRolePic[3]:setYPosition(cegui_absdim(self.m_rPos[3].top + (self.m_rPos[4].bottom - self.m_rPos[3].bottom) / 2 - ((self.m_fMoveElapseTime - moveTime / 2) / moveTime) * (self.m_rPos[4].bottom - self.m_rPos[3].bottom)));
            self.m_pRolePic[4]:setYPosition(cegui_absdim(self.m_rPos[4].top + (self.m_rPos[0].bottom - self.m_rPos[4].bottom) / 2 - ((self.m_fMoveElapseTime - moveTime / 2) / moveTime) * (self.m_rPos[0].bottom - self.m_rPos[4].bottom)));
            self.m_pRolePic[0]:setAlpha(2 * (self.m_fMoveElapseTime - moveTime / 2) / moveTime)
        else
            self:FinishMoving();
        end
    end
	
end
return CCreateRoleDialog
