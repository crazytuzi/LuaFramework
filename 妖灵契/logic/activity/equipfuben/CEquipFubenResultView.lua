local CEquipFubenResultView = class("CEquipFubenResultView", CViewBase)

CEquipFubenResultView.CloseViewTime = 5

function CEquipFubenResultView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/equipfuben/EquipFubenResultView.prefab", cb)
	self.m_ExtendClose = "Black"
	self.m_IsPass = false
end

function CEquipFubenResultView.OnCreateView(self)
	self.m_PlayerTexture = self:NewUI(1, CTexture)
	self.m_ResultGroup = self:NewUI(2, CBox)
	self.m_ExpGrid = self:NewUI(3, CGrid)
	self.m_ExpBox = self:NewUI(4, CBox)
	self.m_ItemGrid = self:NewUI(5, CGrid)
	self.m_ItemBox = self:NewUI(6, CItemTipsBox)
	self.m_Container = self:NewUI(7, CBox)
	self.m_PassGroup = self:NewUI(8, CBox)
	self.m_PassStarGrid = self:NewUI(9, CGrid)
	self.m_PassTimeLabel = self:NewUI(10, CLabel)
	self.m_StarCondionGrid = self:NewUI(11, CGrid)
	self.m_PassItemGrid = self:NewUI(12, CGrid)
	self.m_PassItemBox = self:NewUI(13, CItemTipsBox)
	self.m_ItemBg = self:NewUI(15, CBox)
	self.m_ProgressSrpite = self:NewUI(16, CSlider)
	self.m_ProgressLabel = self:NewUI(17, CLabel)
	-- self.m_ResultTexture = self:NewUI(18, CTexture)
	self.m_LeftBottomTexture = self:NewUI(19, CTexture)
	self.m_RightBottomTexture = self:NewUI(20, CTexture)
	self.m_End = self:NewUI(21, CBox)
	self.m_Win = self:NewUI(22, CBox)
	self.m_Fail = self:NewUI(23, CBox)
	self.m_WinEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shengli.prefab", self:GetLayer(), false)
	self.m_WinEffect:SetParent(self.m_Win.m_Transform)
	self.m_WinEffect:SetLocalPos(Vector3.New(0, 185, 0))

	self.m_FailEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shibai.prefab", self:GetLayer(), false)
	self.m_FailEffect:SetParent(self.m_Fail.m_Transform)
	self.m_FailEffect:SetLocalPos(Vector3.New(0, 185, 0))

	self.m_EndEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_fubenjieshu.prefab", self:GetLayer(), false)
	self.m_EndEffect:SetParent(self.m_End.m_Transform)
	self.m_EndEffect:SetLocalPos(Vector3.New(0, 185, 0))

	self.m_WarId = nil
	self.m_CloseViewTimer = nil

	self:InitContent()
	netopenui.C2GSOpenInterface(define.OpenInterfaceType.WarResult)
end

function CEquipFubenResultView.InitContent(self)
	self.m_ExpBox:SetActive(false)
	self.m_ItemBox:SetActive(false)
	self.m_PassItemBox:SetActive(false)

	self.m_PlayerTexture:LoadFullPhoto(g_AttrCtrl.model_info.shape, function (oTexture)
		oTexture:MakePixelPerfect()
		oTexture:SetLocalScale(Vector3.New(0.75,0.75,0.75))
	end)
end

function CEquipFubenResultView.SetResultContent(self, isWin, id)
	self.m_PassGroup:SetActive(false)
	self.m_ResultGroup:SetActive(true)

	self.m_WarId = id 

	local resultPath, huoyanPath
	local dResultInfo = g_WarCtrl.m_ResultInfo

	--printc(" SetResultContent ", isWin)
	--table.print( dResultInfo )

	if isWin  == true then
		self:SetDelayClose(CEquipFubenResultView.CloseViewTime)
		resultPath = "Texture/War/text_shengli.png"
		huoyanPath = "Texture/War/pic_shengli_huoyan.png"
	else
		resultPath = "Texture/War/text_shibai.png"
		huoyanPath = "Texture/War/pic_shibai_huoyan.png"	
	end

	if dResultInfo.war_id ~= id then
		return
	end
	self.m_Win:SetActive(isWin)
	self.m_Fail:SetActive(not isWin)
	-- self.m_ResultTexture:LoadPath(resultPath)
	self.m_LeftBottomTexture:LoadPath(huoyanPath)
	self.m_RightBottomTexture:LoadPath(huoyanPath)

	self.m_ExpDatas = dResultInfo.exp_list
	--self:RefreshExpGrid()
	self.m_ItemDatas = dResultInfo.item_list
	--self:RefreshItemGrid()

end

function CEquipFubenResultView.SetPassContent(self)
	if self.m_CloseViewTimer ~= nil then
		Utils.DelTimer(self.m_CloseViewTimer)
		self.m_CloseViewTimer = nil
	end	
	local resultPath = "Texture/War/text_shengli.png"
	local huoyanPath = "Texture/War/pic_shengli_huoyan.png"
	self.m_LeftBottomTexture:LoadPath(huoyanPath)
	self.m_RightBottomTexture:LoadPath(huoyanPath)
	self.m_IsPass = true
	
	if g_ActivityCtrl.m_AutoEnter then
		self:SetDelayClose(CEquipFubenResultView.CloseViewTime)
	end

	if g_EquipFubenCtrl.m_PassFubenInfo and next(g_EquipFubenCtrl.m_PassFubenInfo) ~= nil then	
		self.m_PassGroup:SetActive(true)
		self.m_ResultGroup:SetActive(false)

		self.m_PassInfo = g_EquipFubenCtrl.m_PassFubenInfo
		local confg = g_EquipFubenCtrl:GetConfigByFloor(self.m_PassInfo.floor)
		self.m_PassTimeLabel:SetText(string.format("副本时间:%s", g_EquipFubenCtrl:ConverTimeString(self.m_PassInfo.useTime)))
		self.m_ProgressSrpite:SetValue(self.m_PassInfo.sumStar / confg.star)
		self.m_ProgressLabel:SetText(string.format("[ffffff]再取得%d星\n可任选[9c09e0]【紫色】[ffffff]装备", confg.star - self.m_PassInfo.sumStar))

		self:RefeshStarGrid()
		self:RefeshCondition()
		self:RefeshPassItemGrid()
	end
end

function CEquipFubenResultView.RefreshExpGrid(self)
	-- self.m_ExpGrid:Clear()
	-- for i, dExp in ipairs(self.m_ExpDatas) do
	-- 	local oBox = self.m_ExpBox:Clone()
	-- 	oBox:SetActive(true)
	-- 	oBox.m_Avatar = oBox:NewUI(1, CSprite)
	-- 	oBox.m_ExpLabel = oBox:NewUI(2, CLabel)
	-- 	oBox.m_LvLabel = oBox:NewUI(3, CLabel)
	-- 	oBox.m_Slider = oBox:NewUI(4, CSlider)
	-- 	oBox.m_Avatar:SpriteAvatar(dExp.shape)

	-- 	oBox.m_LeftAddExp = dExp.add_exp
	-- 	oBox.m_CurExp = dExp.cur_exp
	-- 	oBox.m_CurGrade = dExp.cur_grade
	-- 	oBox.m_MaxExpFunc = dExp.max_exp_func
	-- 	oBox.m_UpgradeGrade = dExp.uprade_grade
	-- 	oBox.m_AddExp = 0
	-- 	oBox.m_Step = math.ceil(dExp.add_exp / 60)
	-- 	oBox.m_LvLabel:SetText(string.format("lv.%d", oBox.m_CurGrade))
	-- 	Utils.AddTimer(callback(self, "BoxExpAnim", oBox), 0, 0)
	-- 	self.m_ExpGrid:AddChild(oBox)
	-- end
end

function CEquipFubenResultView.BoxExpAnim(self, oBox)
	if not oBox.m_LeftAddExp then
		return false
	end
	if oBox.m_LeftAddExp <= oBox.m_Step then
		oBox.m_Step = oBox.m_LeftAddExp
		oBox.m_LeftAddExp = nil
	else
		oBox.m_LeftAddExp = oBox.m_LeftAddExp - oBox.m_Step
	end
	oBox.m_AddExp = oBox.m_AddExp + oBox.m_Step
	oBox.m_CurExp = oBox.m_CurExp + oBox.m_Step
	if oBox.m_MaxExp == nil then
		oBox.m_MaxExp = oBox.m_MaxExpFunc(oBox.m_CurGrade)
	end
	if oBox.m_CurExp >= oBox.m_MaxExp and oBox.m_CurGrade < oBox.m_UpgradeGrade  then
		oBox.m_CurGrade = oBox.m_CurGrade + 1
		oBox.m_LvLabel:SetText(string.format("lv.%d#G(升级)#n", oBox.m_CurGrade))
		oBox.m_MaxExp = nil
		oBox.m_Slider:SetValue(0)
		oBox.m_CurExp = 0
	else
		oBox.m_Slider:SetValue(oBox.m_CurExp/oBox.m_MaxExp)
	end
	oBox.m_ExpLabel:SetText(string.format("EXP +%d", oBox.m_AddExp))
	return true
end

function CEquipFubenResultView.RefreshItemGrid(self)
	self.m_ItemBg:SetActive(false)
	-- self.m_ItemGrid:Clear()
	-- if self.m_ItemDatas and next(self.m_ItemDatas) then
	-- 	self.m_ItemBg:SetActive(true)
	-- 	for i, dItemInfo in ipairs(self.m_ItemDatas) do
	-- 		local oBox = self.m_ItemBox:Clone()
	-- 		oBox:SetActive(true)
	-- 		local chip = data.itemdata.PARTNER_CHIP[dItemInfo.sid]
	-- 		if chip ~= nil then
	-- 			oBox.m_IconSprite:SpriteAvatar(chip.icon)
	-- 			self.m_CountLabel:SetText(tostring(dItemInfo.amount))
	-- 		else
	-- 			oBox:SetItemData(dItemInfo.sid, dItemInfo.amount)
	-- 		end		
	-- 		self.m_ItemGrid:AddChild(oBox)
	-- 	end		
	-- else
	-- 	self.m_ItemBg:SetActive(false)
	-- end
end

function CEquipFubenResultView.RefeshStarGrid(self)
	self.m_PassStarGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_StarSprite = oBox:NewUI(1, CSprite)
		return oBox
	end)
end

function CEquipFubenResultView.RefeshCondition(self)
	local condition = self.m_PassInfo.condition
	self.m_StarCondionGrid:InitChild(function (obj, idx)
		local str = ""
		if idx == 3 then
			str = string.format("%s%s", g_EquipFubenCtrl:GetFubenTimeStr(self.m_PassInfo.floor), CEquipFubenCtrl.ConditionText[idx])
		else
			str = CEquipFubenCtrl.ConditionText[idx]
		end
		local oBox = CBox.New(obj)
		oBox.m_ConditionLabel = oBox:NewUI(1, CLabel)
		local starBox = self.m_PassStarGrid:GetChild(idx)
		if condition[idx] == true then
			oBox.m_ConditionLabel:SetColor(Color.New( 254/255, 255/255, 255/255, 255/255))			
			starBox.m_StarSprite:SetActive(true)
		else
			oBox.m_ConditionLabel:SetColor(Color.New( 177/255, 177/255, 177/255, 255/255))
			starBox.m_StarSprite:SetActive(false)
		end
		oBox.m_ConditionLabel:SetText(str)
		return oBox
	end)
end

function CEquipFubenResultView.RefeshPassItemGrid(self)
	self.m_PassItemGrid:Clear()
	if self.m_PassInfo.item and next(self.m_PassInfo.item) then
		for i, dItemInfo in ipairs(self.m_PassInfo.item) do
			local oBox = self.m_PassItemBox:Clone()
			oBox.m_MaskWidget = oBox:NewUI(5, CBox)
			oBox:SetActive(true)
			oBox.m_MaskWidget:SetActive(false)
			local config = {isLocal = true, uiType = 2}
			local partId = tonumber(data.globaldata.GLOBAL.partner_reward_itemid.value)
			if dItemInfo.virtual == partId then
				oBox:SetItemData(dItemInfo.virtual, dItemInfo.amount, dItemInfo.sid, config)
			else
				oBox:SetItemData(dItemInfo.sid, dItemInfo.amount, nil, config)			
			end						
			self.m_PassItemGrid:AddChild(oBox)
		end		
	end
end

function CEquipFubenResultView.SetDelayClose(self, time)
	if self.m_CloseViewTimer ~= nil then
		Utils.DelTimer(self.m_CloseViewTimer)
		self.m_CloseViewTimer = nil
	end
	local function wrap()
		self:CloseView()
	end
	self.m_CloseViewTimer = Utils.AddTimer(wrap, 0, time)
end

function CEquipFubenResultView.Destroy(self)
	if self.m_CloseViewTimer ~= nil then
		Utils.DelTimer(self.m_CloseViewTimer)
		self.m_CloseViewTimer = nil
	end	
	g_WarCtrl:SetInResult(false)
	g_ViewCtrl:CloseInterface(define.OpenInterfaceType.WarResult)
	if self.m_IsPass == true then		
 		g_WarCtrl:SetWarEndAfterCallback(function ()
 			g_EquipFubenCtrl:CtrlC2GSOpenEquipFBMain()
 		end)		
	end
	CViewBase.Destroy(self)
end

return CEquipFubenResultView