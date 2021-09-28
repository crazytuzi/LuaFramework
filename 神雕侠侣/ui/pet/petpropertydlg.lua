require "ui.label"
require "ui.dialog"
require "utils.mhsdutils"
require "ui.pet.petlistcell"
require "ui.pet.petskilladd"
require "ui.pet.petskilltips"
require "protocoldef.knight.gsp.pet.caddpetlife"
PetPropertyDlg ={}
PetPropertyDlg.NORMAL = 1 -- 普通
PetPropertyDlg.SUBMIT = 2 -- 交付任务

setmetatable(PetPropertyDlg, Dialog)
PetPropertyDlg.__index = PetPropertyDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;

function PetPropertyDlg.getInstance()
	--LogInfo("enter get petpropertydlg instance")
    if not _instance then
        _instance = PetPropertyDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function PetPropertyDlg.getInstanceAndShow()
	LogInfo("enter petpropertydlg instance show")
    if not _instance then
        _instance = PetPropertyDlg:new()
        _instance:OnCreate()
	else
		LogInfo("set petpropertydlg visible")
		_instance:SetVisible(true)
		_instance:Init()
    end
    
    return _instance
end

function PetPropertyDlg.getInstanceNotCreate()
    return _instance
end

function PetPropertyDlg.DestroyDialog()
	if _instance then 
		LogInfo("destroy petpropertydlg")


		if PetLabel.getInstanceNotCreate() then
			PetLabel.getInstanceNotCreate().DestroyDialog()		
		else
			_instance:CloseDialog()
		end
	end
end

--called by label,release resource here
function PetPropertyDlg:CloseDialog()
	if _instance then
		if _instance.m_PetSprite then
			_instance.m_PetSprite:delete()
		end
		--close amulet tips
		PetAmuletTips.DestroyDialog()
		PetAmuletAddDlg.DestroyDialog()

		_instance.m_pIcon:getGeometryBuffer():setRenderEffect(nil)
		LogInfo("petproperty dialog closedialog")
		_instance.m_pPane:cleanupNonAutoChildren()
		GetDataManager().EventMainPetAttributeChange:RemoveScriptFunctor(_instance.m_hMainPetAttributeChange)
		GetDataManager().EventPetNumChange:RemoveScriptFunctor(_instance.m_hPetNumChange)
		GetDataManager().EventPetDataChange:RemoveScriptFunctor(_instance.m_hPetDataChange)
		GetDataManager().EventShowPetChange:RemoveScriptFunctor(_instance.m_hShowPetChange)
		GetDataManager().EventBattlePetStateChange:RemoveScriptFunctor(_instance.m_hBattlePetStateChange)
		GetDataManager().EventBattlePetDataChange:RemoveScriptFunctor(_instance.m_hBattlePetDataChange)
		GetDataManager().EventPetNameChange:RemoveScriptFunctor(_instance.m_hPetNameChange)
		GetDataManager().EventPetSkillChange:RemoveScriptFunctor(_instance.m_hPetSkillChange)
		_instance:OnClose()
		_instance = nil
	end
end


function PetPropertyDlg.ToggleOpenClose()
	if not _instance then 
		_instance = PetPropertyDlg:new() 
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

function PetPropertyDlg.performPostRenderFunctions(userid)
	if PetPropertyDlg.getInstance() then
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 1 then
				return
			end	
		end
		PetPropertyDlg.getInstance():HandleDrawPetSprite()
	end
end
----/////////////////////////////////////////------

function PetPropertyDlg.UpdataPetCapacity()
	if _instance then
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 1 then
				return
			end	
		end
		CNpcSellItemDlg:GetSingletonDialog():OnClose()
		PetPropertyDlg.getInstanceAndShow():InitPetList()
	end
end

function PetPropertyDlg.MainPetRefresh()
	if _instance then
		print("petpropertydlg main pet refresh")
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 1 then
				return
			end	
		end
		_instance:InitPetList()
		if GetDataManager():GetBattlePetID() == _instance.m_iSelectID then
			_instance:RefreshInfo()
		end
	end
end

function PetPropertyDlg.PetNumChange()
	if _instance then
		LogInfo("petpropertydlg pet num change")
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 1 then
				return
			end	
		end
		_instance:Init()
	end
end

function PetPropertyDlg.PetDataChange(key)
	if _instance then
		LogInfo("petpropertydlg pet data change" .. tostring(key))
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 1 then
				return
			end	
		end
		_instance:InitPetList()
		if key == _instance.m_iSelectID then	
			_instance:RefreshInfo()
		end	
	end
end

function PetPropertyDlg.PetSkillChange(key)
	LogInfo("PetPropertyDlg.PetSkillChange"..key)
	if _instance then 
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 1 then
				return
			end	
		end
		if key == _instance.m_iSelectID then
			_instance:RefreshSkillInfo()		
		end
	end
end

function PetPropertyDlg.ShowPetChange()
	if _instance then
		LogInfo("petpropertydlg show pet change")
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 1 then
				return
			end	
		end
		_instance:RefreshBtnState()
	end
end

function PetPropertyDlg.PetBattleStateChange()
	if _instance then
		LogInfo("petpropertydlg battle state change")
		if PetLabel.getInstanceNotCreate() then
			if PetLabel.getInstanceNotCreate().m_index ~= 1 then
				return
			end	
		end
		_instance:InitPetList()
		_instance:RefreshBtnState()
	end
end


function PetPropertyDlg.GetLayoutFileName()
    return "petpropertynew.layout"
end

function PetPropertyDlg:OnCreate()
	LogInfo("petpropertydlg oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
   	self.m_pShowBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetPropertyNew/follow"))
	self.m_pFreeBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetPropertyNew/free"))
	self.m_pIllustrateBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetPropertyNew1/Back2/Field"))
	self.m_pChangeNameBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetPropertyNew/changename"))
	self.m_pRelaxBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetPropertyNew/relax"))	

	self.m_pExpBar = CEGUI.Window.toProgressBar(winMgr:getWindow("PetPropertyNew/exp"))	
	self.m_pHpBar = CEGUI.Window.toProgressBar(winMgr:getWindow("PetPropertyNew/hp"))
	self.m_pMpBar = CEGUI.Window.toProgressBar(winMgr:getWindow("PetPropertyNew/mp"))
	
	self.m_pType = winMgr:getWindow("PetPropertyNew1/life1")	
	self.m_pGrade = winMgr:getWindow("PetPropertyNew1/grade1")
	self.m_pLife = winMgr:getWindow("PetPropertyNew1/life")
	
	self.m_pIcon = winMgr:getWindow("PetPropertyNew/icon")
	self.m_pIconType = winMgr:getWindow("PetPropertyNew/icon/type")
	self.m_pIconLevel = winMgr:getWindow("PetPropertyNew/level")
	self.m_pIconStars = CEGUI.Window.toRichEditbox(winMgr:getWindow("PetPropertyNew/StarBack/back"))	

	self.m_pGroupBtn = {}
	self.m_pGroupBtn[1] = CEGUI.Window.toGroupButton(winMgr:getWindow("PetPropertyNew/infoback/info1"))
	self.m_pGroupBtn[2] = CEGUI.Window.toGroupButton(winMgr:getWindow("PetPropertyNew/infoback/info2"))
	self.m_pGroupBtn[3] = CEGUI.Window.toGroupButton(winMgr:getWindow("PetPropertyNew/infoback/info3"))
	self.m_pGroupBtn[4] = CEGUI.Window.toGroupButton(winMgr:getWindow("PetPropertyNew/infoback/info4"))
	
	self.m_pTab = {}
	self.m_pTab[1] = winMgr:getWindow("PetPropertyNew/Leftback")
	self.m_pTab[2] = winMgr:getWindow("PetPropertyNew1/Back2")
	self.m_pTab[3] = winMgr:getWindow("PetPropertyNew1/RightBack")
	self.m_pTab[4] = winMgr:getWindow("PetPropertyNew/infoback/shengxiaohufu")

	self.m_pBasicPhyAttack = winMgr:getWindow("PetPropertyNew/damage")
	self.m_pBasicPhyDefence = winMgr:getWindow("PetPropertyNew/defence")
	self.m_pBasicSpeed = winMgr:getWindow("PetPropertyNew/speed")
	self.m_pBasicMagicAttack = winMgr:getWindow("PetPropertyNew/agile")
	self.m_pBasicMagicDefence = winMgr:getWindow("PetPropertyNew/neifang")	

	self.m_pZizhiPhyAttackBar = CEGUI.Window.toProgressBar(winMgr:getWindow("PetPropertyNew1/Back2/bar0"))
	self.m_pZizhiPhyDefenceBar = CEGUI.Window.toProgressBar(winMgr:getWindow("PetPropertyNew1/Back2/bar1"))
	self.m_pZizhiHpBar = CEGUI.Window.toProgressBar(winMgr:getWindow("PetPropertyNew1/Back2/bar2"))
	self.m_pZizhiMpBar = CEGUI.Window.toProgressBar(winMgr:getWindow("PetPropertyNew1/Back2/bar3"))
	self.m_pZizhiSpeedBar = CEGUI.Window.toProgressBar(winMgr:getWindow("PetPropertyNew1/Back2/bar4"))
	self.m_pZizhiWuxing = winMgr:getWindow("PetPropertyNew1/xuemaidir")

	self.m_pBack = winMgr:getWindow("PetPropertyNew/left")
	self.m_pBack2 = winMgr:getWindow("PetPropertyNew/infoback")
	
	self.m_pAddLife = CEGUI.Window.toPushButton(winMgr:getWindow("PetPropertyNew/left/addlife"))

	self.m_pSkillBox = {}
	for i = 1,12 do
		self.m_pSkillBox[i] = CEGUI.Window.toSkillBox(winMgr:getWindow("PetPropertyNew1/Skill" .. tostring(i)))
		self.m_pSkillBox[i]:subscribeEvent("MouseClick", PetPropertyDlg.HandleSkillClicked, self)
	end	
	
	self.m_pPane = CEGUI.Window.toScrollablePane(winMgr:getWindow("PetPropertyNew/petlist"))
	self.m_pWeiboShareBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetPropertyNew/StarBack/share"))

	self.m_pNormalLayer = winMgr:getWindow("PetPropertyNew/btnmore")
	self.m_pSubmitLayer = winMgr:getWindow("PetPropertyNew/giveback")
	self.m_pSubmitBtn = CEGUI.Window.toPushButton(winMgr:getWindow("PetPropertyNew/giveback/give"))

	-- amulet
	print("amulet Init Btns")
	self.m_amuletBtns = {}
	for i = 1, 5 do
		self.m_amuletBtns[i] = CEGUI.toItemCell(winMgr:getWindow("PetPropertyNew/infoback/shengxiaohufu/back"..tostring(i-1).."/item"))
		self.m_amuletBtns[i]:setID(i)
		self.m_amuletBtns[i]:subscribeEvent("MouseClick", self.HandleAmuletCellClicked, self)
		self.m_amuletBtns[i].lockText = winMgr:getWindow("PetPropertyNew/infoback/shengxiaohufu/back"..tostring(i-1).."/lock")
		self.m_amuletBtns[i].m_pMainFrame = self.m_amuletBtns[i]
	end
	self.m_amuletLevels = {15, 35, 55, 75, 95}
	self.m_diaowenBtn = winMgr:getWindow("PetPropertyNew/infoback/shengxiaohufu/diaowen")
	self.m_diaowenBtn:subscribeEvent("MouseClick", self.HandleDiaowenClicked, self)
	print("amulet finish init btns")
	
	--init state
	self.m_pIconStars:SetEmotionScale(CEGUI.Vector2(0.6, 0.6))
	
	for i = 1,4 do
		self.m_pGroupBtn[i]:setID(i)
   		self.m_pGroupBtn[i]:subscribeEvent("SelectStateChanged", PetPropertyDlg.HandleSelectStateChanged, self) 
		if i == 1 then
			self.m_pGroupBtn[i]:setSelected(true)
			self.m_pTab[i]:setVisible(true)
		else
			self.m_pGroupBtn[i]:setSelected(false)
			self.m_pTab[i]:setVisible(false)
		end
	end

   	-- subscribe event
	self.m_pShowBtn:subscribeEvent("Clicked", PetPropertyDlg.HandleShowBtnClicked, self)
	self.m_pFreeBtn:subscribeEvent("Clicked", PetPropertyDlg.HandleFreeBtnClicked, self)
	self.m_pIllustrateBtn:subscribeEvent("Clicked", PetPropertyDlg.HandleIllustrateBtnClicked, self)
	self.m_pChangeNameBtn:subscribeEvent("Clicked", PetPropertyDlg.HandleChangeNameBtnClicked, self)
	self.m_pRelaxBtn:subscribeEvent("Clicked", PetPropertyDlg.HandleRelaxBtnClicked, self)
	self.m_pAddLife:subscribeEvent("Clicked", PetPropertyDlg.HandleAddlifeBtnClicked, self)
	self.m_pSubmitBtn:subscribeEvent("Clicked", PetPropertyDlg.HandleSubmitBtnClicked, self)

	self.m_pWeiboShareBtn:setVisible(false)
	if Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "tiger" then
		self.m_pWeiboShareBtn:setVisible(true)
		self.m_pWeiboShareBtn:subscribeEvent("Clicked", PetPropertyDlg.HandleWeiboShareBtnClicked, self)
	elseif ( Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" ) or Config.isKoreanAndroid() then
		self.m_pWeiboShareBtn:setVisible(true)
		self.m_pWeiboShareBtn:subscribeEvent("Clicked", PetPropertyDlg.HandleFacebookShareBtnClicked, self)
	end

	--set xprendersprite for sprite
	self.m_pIcon:getGeometryBuffer():setRenderEffect(CGameUImanager:createXPRenderEffect(0, PetPropertyDlg.performPostRenderFunctions))

	--init
	self:Init()	
	
	self.m_hMainPetAttributeChange = GetDataManager().EventMainPetAttributeChange:InsertScriptFunctor(PetPropertyDlg.MainPetRefresh)
	self.m_hPetNumChange = GetDataManager().EventPetNumChange:InsertScriptFunctor(PetPropertyDlg.PetNumChange)
	self.m_hPetDataChange = GetDataManager().EventPetDataChange:InsertScriptFunctor(PetPropertyDlg.PetDataChange)
	self.m_hShowPetChange = GetDataManager().EventShowPetChange:InsertScriptFunctor(PetPropertyDlg.ShowPetChange)
	self.m_hBattlePetStateChange = GetDataManager().EventBattlePetStateChange:InsertScriptFunctor(PetPropertyDlg.PetBattleStateChange)
	self.m_hBattlePetDataChange = GetDataManager().EventBattlePetDataChange:InsertScriptFunctor(PetPropertyDlg.MainPetRefresh)
	self.m_hPetNameChange = GetDataManager().EventPetNameChange:InsertScriptFunctor(PetPropertyDlg.PetDataChange)
	self.m_hPetSkillChange = GetDataManager().EventPetSkillChange:InsertScriptFunctor(PetPropertyDlg.PetSkillChange)
	LogInfo("petpropertydlg oncreate end")
end

------------------- private: -----------------------------------
function PetPropertyDlg:HandleFacebookShareBtnClicked(args)
	LogInfo("PetPropertyDlg HandleWeiboShareBtnClicked")
	-- local strbuilder = StringBuilder:new()	
	-- strbuilder:SetNum("parameter1", GetPKManager():getRank())
	--strbuilder:GetString(msg)
	local record = MHSD_UTILS.getLuaBean("knight.gsp.message.cfacebook", 1)
	local shareinfo = {}
	shareinfo[1] = record.Comment
	shareinfo[2] = record.Link
	shareinfo[3] = record.LinkPicture
	shareinfo[4] = record.LinkName
	shareinfo[5] = record.LinkCaption
	shareinfo[6] = record.LinkDescription


	if Config.isKoreanAndroid()  then
		local luaj = require "luaj"
		luaj.callStaticMethod("com.wanmei.korean.KoreanCommon", "ShareFacebook", luaj.checkArguments(shareinfo))
	elseif Config.TRD_PLATFORM == 1 and Config.MOBILE_ANDROID == 0 and Config.CUR_3RD_PLATFORM == "kris" then
         SDXL.ChannelManager:CommonShare(record.Comment,record.Link, record.LinkPicture, record.LinkName,record.LinkCaption,record.LinkDescription)
	end

	-- strbuilder:delete()
end
function PetPropertyDlg:Init(mode)
	mode = mode or PetPropertyDlg.NORMAL
	self:InitPetList(mode)

	self:RefreshInfo(mode)	

	self.m_pNormalLayer:setVisible(false)
	self.m_pSubmitLayer:setVisible(false)
	if GetDataManager():GetPetNum() > 0 then
		if     mode == PetPropertyDlg.NORMAL then
			self.m_pNormalLayer:setVisible(true)
		elseif mode == PetPropertyDlg.SUBMIT then
			self.m_pSubmitLayer:setVisible(true)
		end
	end
end

function PetPropertyDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, PetPropertyDlg)
    return self
end

function PetPropertyDlg:ShowGroup( groupid )
	if self.m_pGroupBtn then
		self.m_pGroupBtn[groupid]:setSelected(true)
	end
end

function PetPropertyDlg:HandleSelectStateChanged(args)
	LogInfo("select state change")
	local selected = self.m_pGroupBtn[1]:getSelectedButtonInGroup():getID()
	for i = 1, 4 do
		self.m_pTab[i]:setVisible(false)
	end
	self.m_pTab[selected]:setVisible(true)
	self:RefreshPaneInfo()
	return true
end

function PetPropertyDlg:HandleShowBtnClicked(args)
	LogInfo("show btn clicked")

	if GetBattleManager():IsInBattle() then
		GetGameUIManager():AddMessageTipById(131451)
		return false
	end
	if self.m_iSelectID then
		if GetDataManager():FindMyPetByID(self.m_iSelectID) then
			local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
			if petinfo.key == GetDataManager():GetShowPetID() then
				LogInfo("showpetoff")
				GetNetConnection():send(knight.gsp.pet.CShowPetOff())
			else
				LogInfo("showpet")
				GetNetConnection():send(knight.gsp.pet.CShowPet(petinfo.key))
			end		
		end
	else
		return false
	end

	return true
end

function PetPropertyDlg:HandleFreeBtnClicked(args)
	LogInfo("free btn clicked")
	PetLabel.Show(4)	
	PetChipDlg.ShowTab(3)
	return true
end

function PetPropertyDlg:HandleIllustrateBtnClicked(args)
	LogInfo("illustrate btn clicked")
	local dlg = CPetIllustration:GetSingletonDialogAndShowIt()
	if self.m_iSelectID then
		local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
		dlg:OpenDialog(petinfo.baseid)
	else
		dlg:OpenDialog(0)
	end
	--PetPropertyDlg.DestroyDialog()
	return true
end

function PetPropertyDlg:HandleChangeNameBtnClicked(args)
	LogInfo("change name clicked")

	if GetBattleManager():IsInBattle() then
		GetGameUIManager():AddMessageTipById(131451)
		return false
	end
	if self.m_iSelectID then
		if GetDataManager():FindMyPetByID(self.m_iSelectID) then
			local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
			GetInPutDialoig():SetEvent(eChangePetName, petinfo.key)
		end
	else
		return false
	end
	return true
end

function PetPropertyDlg:HandleRelaxBtnClicked(args)
	LogInfo("relax clicked")
	if GetBattleManager():IsInBattle() then
		GetGameUIManager():AddMessageTipById(131451)
		return false
	end
	if self.m_iSelectID then
		if GetDataManager():FindMyPetByID(self.m_iSelectID) then
			local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
			if petinfo.key == GetDataManager():GetBattlePetID()  then
				GetNetConnection():send(knight.gsp.pet.CSetFightPetRest())
			else
				if (petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL) - GetDataManager():GetMainCharacterLevel()) > 10 then
					GetGameUIManager():AddMessageTipById(141394)
				elseif petinfo:getAttribute(knight.gsp.attr.AttrType.PET_LIFE) < 50 then
					GetGameUIManager():AddMessageTipById(141392)
				else 
				--[[	
					local petattr = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(petinfo.baseid)
					if petattr.uselevel > GetDataManager():GetMainCharacterLevel() then
						GetGameUIManager():AddMessageTipById(1314530)
					else
					--]]
					GetNetConnection():send(knight.gsp.pet.CSetFightPet(petinfo.key))
				--	end
				end
			end
		end
	else
		return false
	end

	return true
end

function PetPropertyDlg:HandlePetSelect(args)
	LogInfo("handle pet select")
	require "luaprotocolhandler.knight_gsp_pet"
	if confirmAddPetSkillType then
	   GetMessageManager():CloseConfirmBox(confirmAddPetSkillType, false)
	end
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	local petinfo = GetDataManager():getPet(id)
	if petinfo then
		if petinfo.key ~= self.m_iSelectID then 
			self.m_iSelectID = petinfo.key
			self:refreshPetSelectState()
			self:RefreshInfo()	
		end
	end	
	return true
end
local confirmtype
local function confirmGotoPetisland()
	if confirmtype then
		GetMessageManager():CloseConfirmBox(confirmtype, false)
	end
	local npcid = 10875
	local npcConfig = knight.gsp.npc.GetCNPCConfigTableInstance():getRecorder(npcid)
	GetMainCharacter():FlyOrWarkToPos(npcConfig.mapid, npcConfig.xPos, npcConfig.yPos, npcConfig.id)
	if _instance then
		_instance.DestroyDialog()
	end
end

local function petCatchGuide()
	local level = GetDataManager():GetMainCharacterLevel()
	if level < 35 then
        if GetChatManager() then
            GetChatManager():AddTipsMsg(145097)
        end
	else
		local msg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145098).msg
		confirmtype = MHSD_UTILS.addConfirmDialog(msg, confirmGotoPetisland)
	end
end

function PetPropertyDlg:InitPetList(mode)
	--self.m_pPane:cleanupNonAutoChildren()
	if not self.m_petDlgList then
		self.m_petDlgList = {}
		for i = 1, 8 do
			self.m_petDlgList[i] = PetListCell.CreateNewDlg(self.m_pPane, i)
			self.m_petDlgList[i]:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 ,0), CEGUI.UDim(0, (i - 1) * self.m_petDlgList[i]:GetWindow():getPixelSize().height + 1)))
		end
	end

	for i = 1, 8 do
		self.m_petDlgList[i]:GetWindow():setVisible(false)
	end

	local maxnum = GetDataManager():GetMaxPetNum()
	local num = GetDataManager():GetPetNum()
	for i = 1, num do 
		self.m_petDlgList[i]:GetWindow():setVisible(true)
		self.m_petDlgList[i]:SetInfo(GetDataManager():getPet(i))	
	end

	for i = num + 1, maxnum do
		self.m_petDlgList[i]:GetWindow():setVisible(true)
		self.m_petDlgList[i]:SetEmpty()
		self.m_petDlgList[i].m_pWnd:subscribeEvent("MouseClick", petCatchGuide)
	end
	if maxnum < 8 and mode ~= PetPropertyDlg.SUBMIT then
		self.m_petDlgList[maxnum + 1]:GetWindow():setVisible(true)
		self.m_petDlgList[maxnum + 1]:SetLock()
	end

	if not self.m_iSelectID or not GetDataManager():FindMyPetByID(self.m_iSelectID) then
		self.m_iSelectID = nil
	end

	if not self.m_iSelectID and num >= 1 then
		self.m_iSelectID = GetDataManager():getPet(1).key
		for i,v in pairs(self.m_petDlgList) do
			local petInfo = GetDataManager():getPet(v.m_pWnd:getID())
			if petInfo then
				if petInfo.key == GetDataManager():GetBattlePetID() then
					self.m_iSelectID = petInfo.key
					break
				end
			end
		end

	end
	if mode == PetPropertyDlg.SUBMIT then
		self.m_iSelectID = GetDataManager():getPet(1).key
	end
	self:refreshPetSelectState()
end

function PetPropertyDlg:HandleUnlock(args)
	LogInfo("unlock pet")
	CNpcSellItemDlg:GetSingletonDialog():BuyExpandCapacityItem()
	return true
end

function PetPropertyDlg:RefreshSprite(wnd, shapeid)
	if self.m_PetSprite then 
		if self.m_PetSprite:GetModelID() ~= shapeid then
			self.m_PetSprite:SetModel(shapeid)
		end
	else
		self.m_PetSprite = CUISprite:new(shapeid)
	end

	local pt = wnd:GetScreenPosOfCenter()
	local wndHeight = wnd:getPixelSize().height
	local loc = XiaoPang.CPOINT(pt.x, pt.y+wndHeight/3.0)
	self.m_PetSprite:SetUILocation(loc)
	self.m_PetSprite:SetUIDirection(XiaoPang.XPDIR_BOTTOMRIGHT)
end

function PetPropertyDlg:RefreshInfo()
	print("refresh pet ")
	LogInfo("petpropertydlg refresh info")
	if self.m_iSelectID then
		if GetDataManager():FindMyPetByID(self.m_iSelectID) then
			self.m_pBack:setVisible(true)
			self.m_pBack2:setVisible(true)
			LogInfo(self.m_iSelectID)
			local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
			self.m_pIconLevel:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL)) .. MHSD_UTILS.get_resstring(2397))


			local petAttr = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(petinfo.baseid);
			self.m_pIconType:setText(petAttr.name)	
			self.m_pType:setText(petAttr.chengzhangleixing)
			self.m_pGrade:setText(tostring(petinfo.score))
			self.m_pLife:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_LIFE)))
			self.m_pHpBar:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.HP)) .. "/" .. tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.MAX_HP)))
			self.m_pHpBar:setProgress(petinfo:getAttribute(knight.gsp.attr.AttrType.HP) / petinfo:getAttribute(knight.gsp.attr.AttrType.MAX_HP))

			self.m_pMpBar:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.MP)) .. "/" .. tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.MAX_MP)))
			self.m_pMpBar:setProgress(petinfo:getAttribute(knight.gsp.attr.AttrType.MP) / petinfo:getAttribute(knight.gsp.attr.AttrType.MAX_MP))
			self.m_pExpBar:setText(tostring(petinfo.curexp) .. "/" .. tostring(petinfo.nextexp))
			self.m_pExpBar:setProgress(petinfo.curexp / petinfo.nextexp)
			
			local petStar = knight.gsp.pet.GetCPetstarsTableInstance():getRecorder(petinfo.starId)
			local stars = petStar.stars	
			self.m_pIconStars:Clear()
			for i = 7,0,-1 do
				local starLevel = stars % (10 ^(i + 1)) / (10 ^ i)
				if starLevel > 0 then
					self.m_pIconStars:AppendEmotion(149 + starLevel)
				end
			end
			self.m_pIconStars:Refresh()
			self:RefreshBtnState()	
			self:RefreshPaneInfo()
			self:RefreshSprite(self.m_pIcon, petAttr.modelid)
		else
			self.m_pBack:setVisible(false)
			self.m_pBack2:setVisible(false)
			self.m_pFreeBtn:setVisible(false)
			self.m_pShowBtn:setVisible(false)
			self.m_pRelaxBtn:setVisible(false)
		end
	else
		self.m_pBack:setVisible(false)
		self.m_pBack2:setVisible(false)
		self.m_pFreeBtn:setVisible(false)
		self.m_pShowBtn:setVisible(false)
		self.m_pRelaxBtn:setVisible(false)
	end
end

function PetPropertyDlg:RefreshBtnState()
	if not self.m_iSelectID then
		return true
	end
	local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
	if petinfo then 
		self.m_pShowBtn:setVisible(true)
		self.m_pRelaxBtn:setVisible(true)
		self.m_pFreeBtn:setVisible(true)
		if GetDataManager():GetBattlePetID() == petinfo.key then

			str = MHSD_UTILS.get_resstring(2117)
		else
			str = MHSD_UTILS.get_resstring(2118)
		end
		self.m_pRelaxBtn:setText(str)

		if GetDataManager():GetShowPetID() == petinfo.key then
			str = MHSD_UTILS.get_resstring(2119)
		else
			str = MHSD_UTILS.get_resstring(2120)
		end	
		self.m_pShowBtn:setText(str)		
	end	
end

function PetPropertyDlg:RefreshPaneInfo()
	LogInfo("petpropertydlg refresh pane info")	
	if self.m_iSelectID then
		local selected = self.m_pGroupBtn[1]:getSelectedButtonInGroup():getID()
		if selected == 1 then
			self:RefreshBasicInfo()
		elseif selected == 2 then
			self:RefreshZizhiInfo()
		elseif selected == 3 then
			self:RefreshSkillInfo()
		elseif selected == 4 then
			self:RefreshAmuletInfo()
		end
	end	
end

function PetPropertyDlg:RefreshBasicInfo()
	if self.m_iSelectID then
		if GetDataManager():FindMyPetByID(self.m_iSelectID) then
			local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
			self.m_pBasicPhyAttack:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.ATTACK)))
			self.m_pBasicPhyDefence:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.DEFEND)))
			self.m_pBasicSpeed:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.SPEED)))
			self.m_pBasicMagicAttack:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.MAGIC_ATTACK)))
			self.m_pBasicMagicDefence:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.MAGIC_DEF)))
		end
	end
end

function PetPropertyDlg:RefreshZizhiInfo()
	if self.m_iSelectID then
		if GetDataManager():FindMyPetByID(self.m_iSelectID) then
			local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
			self.m_pZizhiWuxing:setText(tostring(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_GENGU)))
			local petAttr = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(petinfo.baseid);
			PetPropertyDlg.AdjustPetZizhiBar(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_ATTACK_APT), petAttr.attackaptmax + 5 * petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL), self.m_pZizhiPhyAttackBar) 
			PetPropertyDlg.AdjustPetZizhiBar(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_DEFEND_APT), petAttr.defendaptmax + 5 * petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL), self.m_pZizhiPhyDefenceBar) 
			PetPropertyDlg.AdjustPetZizhiBar(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_PHYFORCE_APT), petAttr.phyforceaptmax + 5 * petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL), self.m_pZizhiHpBar) 
			PetPropertyDlg.AdjustPetZizhiBar(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_MAGIC_APT), petAttr.magicaptmax + 5 * petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL), self.m_pZizhiMpBar) 
			PetPropertyDlg.AdjustPetZizhiBar(petinfo:getAttribute(knight.gsp.attr.AttrType.PET_SPEED_APT), petAttr.speedaptmax + 5 * petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL), self.m_pZizhiSpeedBar) 
			LogInfo("end refresh zizhiinfo")
		end
	end
end

function PetPropertyDlg:RefreshSkillInfo()
	if self.SkillEffects == nil then
		self.SkillEffects = {}	
	end
	if self.m_iSelectID then
		if GetDataManager():FindMyPetByID(self.m_iSelectID) then
			local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
			local skillnum = petinfo:getSkilllistlen()		
			for i = 1, skillnum do
				local skill = petinfo:getSkill(i)
				local skillexpiretime = petinfo:getPetSkillExpires(skill.skillid)
				CSkillBoxControl:GetInstance():SetSkillInfo(self.m_pSkillBox[i], skill.skillid, skillexpiretime)
				self.m_pSkillBox[i]:SetBackgroundDynamic(true)
				local skillconfig = knight.gsp.skill.GetCPetSkillConfigTableInstance():getRecorder(skill.skillid)
				if skillconfig.id ~= -1 then
					local bkimageset = CEGUI.String("BaseControl"..(math.floor((skillconfig.color-1)/4)+1))
					local bkimage = CEGUI.String("SkillInCell"..skillconfig.color)
					self.m_pSkillBox[i]:SetBackGroundImage(bkimageset, bkimage)
				end
				self.m_pSkillBox[i]:setID(0)
				if self.SkillEffects[i] then
					self.SkillEffects[i] = false
					GetGameUIManager():RemoveUIEffect(self.m_pSkillBox[i])
				end
			end
			for i = skillnum + 1, 12 do
				local bLock = i > petinfo.skill_grid
				if not bLock and not self.SkillEffects[i]then
					GetGameUIManager():AddUIEffect(self.m_pSkillBox[i], MHSD_UTILS.get_effectpath(10374), true)
					self.SkillEffects[i] = true
				end
				if bLock and self.SkillEffects[i] then
					self.SkillEffects[i] = false
					GetGameUIManager():RemoveUIEffect(self.m_pSkillBox[i])
				end
				self.m_pSkillBox[i]:setID(bLock and 1 or 0)
				CSkillBoxControl:GetInstance():ClearSkillInfo(self.m_pSkillBox[i], bLock);
				self.m_pSkillBox[i]:SetBackGroundImage(CEGUI.String("BaseControl1"), CEGUI.String("SkillInCell1"))
				self.m_pSkillBox[i]:SetBackgroundDynamic(false)
			end		
			for i = 1, 12 do 
				LogInfo(tostring(self.m_pSkillBox[i]:GetSkillID()))
			end
		end
	end
end

function PetPropertyDlg.AdjustPetZizhiBar(cur, max, bar, basicWidth, basicNum)
	LogInfo("AdjustPetZizhiBar")
	basicWidth = basicWidth or 100
	basicNum = basicNum or 1800
	local upWidth = cur / basicNum * basicWidth
	local backWidth = max / basicNum * basicWidth
	bar:setText(tostring(cur))
	bar:setWidth(CEGUI.UDim(0, backWidth))
	bar:setProgress(upWidth / backWidth)
end

function PetPropertyDlg:HandleSkillClicked(args)
	LogInfo("skill clicked")	
	require "luaprotocolhandler.knight_gsp_pet"
	if confirmAddPetSkillType then
	   GetMessageManager():CloseConfirmBox(confirmAddPetSkillType, false)
	end
	local e = CEGUI.toWindowEventArgs(args)
	local cell = CEGUI.toSkillBox(e.window)
	if cell:getID() > 0 then
		local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
		if not petinfo then
			return false
		end
		local p = require "protocoldef.knight.gsp.pet.cextendskillgrid".new()
		p.petkey = self.m_iSelectID
		p.flag = 0
		require "manager.luaprotocolmanager":send(p)
		return true 
	end
	if cell:GetSkillID() == 0 then
		PetSkillAdd.getSingletonDialogAndShow():SetPetkey(self.m_iSelectID)	
		if PetSkillTips.getSingleton() then
			PetSkillTips.getSingleton():SetVisible(false)
		end
		return true 
	end
	local xpos = cell:GetScreenPos().x
	local ypos = cell:GetScreenPos().y
	local dueltime = cell:GetSkillDueDate()
	if dueltime > 0 then
		CPetSkillTipsDlg:GetSingletonDialogAndShowIt():ShowPetTimeSkillTips(cell:GetSkillID(), dueltime, xpos, ypos)	
	else
	--	CPetSkillTipsDlg:GetSingletonDialogAndShowIt():ShowPetSkillTips(cell:GetSkillID(), xpos, ypos)
		LogInfo("cell skillid ="..cell:GetSkillID())
		PetSkillTips.getSingletonDialogAndShow():SetPetkeyAndSkillid(self.m_iSelectID, cell:GetSkillID())	
		if PetSkillAdd.getSingleton() then
			PetSkillAdd.getSingleton():SetVisible(false)
		end
	end
	return true 
end

function PetPropertyDlg:HandleDrawPetSprite()
	if self.m_pIcon:isVisible() and self.m_pIcon:getEffectiveAlpha() > 0.95 and self.m_PetSprite then
		local pt = self.m_pIcon:GetScreenPosOfCenter()
		local wndHeight = self.m_pIcon:getPixelSize().height
		local loc = XiaoPang.CPOINT(pt.x, pt.y+wndHeight/3.0)
		self.m_PetSprite:SetUILocation(loc)
		self.m_PetSprite:RenderUISprite()
	end
end

function PetPropertyDlg:refreshPetSelectState()
	LogInfo("petpropertydlg refresh pet select state")
	if self.m_iSelectID then
		for i,v in pairs(self.m_petDlgList) do
			local petInfo = GetDataManager():getPet(v.m_pWnd:getID())
			if petInfo then
				if petInfo.key == self.m_iSelectID then
					v:SetSelected(true)				
				else
					v:SetSelected(false)
				end
			else
				v:SetSelected(false)				
			end		
		end
	end

end

function PetPropertyDlg:HandleAddlifeBtnClicked(args)
	LogInfo("petpropertydlg handle addlife btn clicked")
	if self.m_iSelectID then
		local itemid = 32036
		local found = false
		local item_num = GetRoleItemManager():GetItemNumByBaseID(itemid)
		if item_num > 0 then
			-- print("### found one \n")
			found = true
		end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
		if found then
			local addlife = CAddPetLife.Create()
			addlife.petkey = self.m_iSelectID
			LuaProtocolManager.getInstance():send(addlife)
		else 
			-- print("*** there is no itemid: ",itemid)
			if GetChatManager() then
                GetChatManager():AddTipsMsg(146310)
            end
			CGreenChannel:GetSingletonDialogAndShowIt():SetItem(itemid)
			return true
		end
	end	
end

function PetPropertyDlg:HandleWeiboShareBtnClicked(args)
	LogInfo("PetPropertyDlg HandleWeiboShareBtnClicked")
	local record = MHSD_UTILS.getLuaBean("knight.gsp.message.cweiboshow", 301)
	local title = record.title
	if record.title == "0" then
		title = ""
	end
	local msg = record.msg
	if record.msg == "0" then
		msg = ""
	end
	local link = record.link
	if record.link == "0" then
		link = ""
	end
    local link1 = record.link1
	if record.link1 == "0" then
		link1 = ""
	end
	local strbuilder = StringBuilder:new()	
	local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
	if petinfo then
		local petAttr = knight.gsp.pet.GetCPetAttrTableInstance():getRecorder(petinfo.baseid);
		strbuilder:Set("parameter2", petAttr.name)
		strbuilder:Set("parameter1", MHSD_UTILS.get_resstring(petinfo.colour + 3016))
		SDXL.ChannelManager:CommonShare(title, strbuilder:GetString(msg), link, link1)		
	end
	strbuilder:delete()
end

function PetPropertyDlg:HandleSubmitBtnClicked(args)
	LogInfo("PetPropertyDlg:HandleSubmitBtnClicked")
	local CSubmitTianYaPet = require "protocoldef.knight.gsp.specialquest.csubmittianyapet"
	local req = CSubmitTianYaPet.Create()
	req.petid = self.m_iSelectID
	LuaProtocolManager.getInstance():send(req)
	return true
end

----------------- pet amulet -----------------------------------

function PetPropertyDlg:HandleAmuletCellClicked( args )
	if not self.m_iSelectID then
		return
	end
	LogInfo("amulet clicked")	
	local e = CEGUI.toWindowEventArgs(args)
	local cell = CEGUI.toItemCell(e.window)
	local cellid = cell:getID()
	require "ui.pet.petamulettips"
	require "ui.pet.petamuletadddlg"
	if self.m_amuletBtns[cellid].itemid then
		PetAmuletAddDlg.DestroyDialog()
		PetAmuletTips:getInstance():SetPetId(self.m_iSelectID)
		--show tips
		local btn = self.m_amuletBtns[cellid]
		PetAmuletTips.getInstanceAndShow():SetItem(btn.itemid, btn.diaowenid, btn.curexp, cellid, self.m_dwNum[btn.diaowenid] or 1)

	elseif not self.m_amuletBtns[cellid].lockText:isVisible() then --show amulet list
		PetAmuletTips.DestroyDialog()
		PetAmuletAddDlg:getInstance():SetPetId(self.m_iSelectID)
		PetAmuletAddDlg:getInstanceAndShow():PushAmulets(self.GetAmuletsInBag())
	end
end

function PetPropertyDlg:RefreshAmuletInfo()
	if self.m_iSelectID then
		if GetDataManager():FindMyPetByID(self.m_iSelectID) then
			local petinfo = GetDataManager():FindMyPetByID(self.m_iSelectID)
			local level = petinfo:getAttribute(knight.gsp.attr.AttrType.LEVEL)
			--refresh lock cell
			for i,v in ipairs(self.m_amuletLevels) do
				self.m_amuletBtns[i].lockText:setVisible(level < v)
			end

			local p = require "protocoldef.knight.gsp.pet.creqpetamulet" : new()
			p.petkey = self.m_iSelectID
			require "manager.luaprotocolmanager":send(p)

			PetPropertyDlg.GetAmuletsInBag() -- require tips in bag
		end
	end
end

function PetPropertyDlg:SetAmulet( cellid, amulet )
	if not amulet then
		self.m_amuletBtns[cellid]:SetImage(nil)
		self.m_amuletBtns[cellid].itemid = nil
		self.m_amuletBtns[cellid].diaowenid = nil
		return
	end
	local item_table = knight.gsp.item.GetCItemAttrTableInstance()
	local itembean = item_table:getRecorder(amulet.petamuletid)
	self.m_amuletBtns[cellid]:SetImage(GetIconManager():GetItemIconByID(itembean.icon))
	self.m_amuletBtns[cellid].itemid = amulet.petamuletid
	self.m_amuletBtns[cellid].diaowenid = amulet.diaowenid
	self.m_amuletBtns[cellid].curexp = amulet.curexp
end

function PetPropertyDlg:GetAmuletCells() --used in checktipswnd.lua, 点击护符格子时防止销毁tip界面
	return unpack(self.m_amuletBtns)
end

function PetPropertyDlg:SetCurrAmulets( petkey, amulet_list )
	if self.m_iSelectID ~= petkey then
		self:SetCurrAmulets(self.m_iSelectID, {})
		return
	end
	for i=1,5 do
		self:SetAmulet(i, amulet_list[i])
	end
	self.m_dwNum = {}
	for i=1,5 do
		v = amulet_list[i]
		if v then
			local id = v.diaowenid
			if self.m_dwNum[id] == nil then
				self.m_dwNum[id] = 1
			else
				self.m_dwNum[id] = self.m_dwNum[id] + 1
			end
		end
	end
end

function PetPropertyDlg:HandleDiaowenClicked()
	local PetDiaoWenDlg = require "ui.pet.petdiaowendlg"
	local hasdiaowen = false
	local index = 1
	local tt = BeanConfigManager.getInstance():GetTableByName("knight.gsp.item.cpetglyoh")
	local allIDs = tt:getAllID()
    for k,v in pairs(allIDs) do
        local record = tt:getRecorder(v)
        if record and self.m_dwNum[v] and self.m_dwNum[v] > 1 then
        	PetDiaoWenDlg:getInstanceAndShow()
        	PetDiaoWenDlg:getInstance():SetData(index, v, self.m_dwNum[v])
        	index = index + 1
        	hasdiaowen = true
        end
    end
    if not hasdiaowen then
    	GetGameUIManager():AddMessageTipById(146366)
    end
end

function PetPropertyDlg.GetAmuletsInBag()
	local amulets = std.vector_int_()
	GetRoleItemManager():GetItemKeyListByType(amulets, 161)
	bagList = {}

	for i = 0, amulets:size() - 1 do
		local index = i + 1
		local itemkey = amulets[i]
		local item = GetRoleItemManager():FindItemByBagAndThisID(itemkey, knight.gsp.item.BagTypes.BAG)
		if item ~= nil then

			-- require tips
			local pobj = require "manager.itemmanager".getObject(knight.gsp.item.BagTypes.BAG, itemkey)
			if not pobj or pobj.bNeedRequireself then
				local p = knight.gsp.item.CItemTips(knight.gsp.item.BagTypes.BAG, itemkey)
				GetNetConnection():send(p)
			end

			bagList[index] = {}
			bagList[index].petamuletid = item:GetBaseObject().id
			bagList[index].itemkey = itemkey

			if pobj then
				bagList[index].curexp = pobj.curexp
				bagList[index].diaowenid = pobj.diaowenid
			end
		end
	end

	return bagList
end

return PetPropertyDlg
