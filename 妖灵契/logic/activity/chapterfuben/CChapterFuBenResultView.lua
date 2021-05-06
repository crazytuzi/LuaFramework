local CChapterFuBenResultView = class("CChapterFuBenResultView", CViewBase)

CChapterFuBenResultView.CloseViewTime = 5

--~CChapterFuBenResultView:ShowView()
function CChapterFuBenResultView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Activity/ChapterFuBen/ChapterFuBenResultView.prefab", cb)
	self.m_ExtendClose = "Black"
end

function CChapterFuBenResultView.OnCreateView(self)
	self.m_Container = self:NewUI(1, CWidget)
	self.m_Win = self:NewUI(2, CObject)
	self.m_ItemScrollView = self:NewUI(3, CScrollView)
	self.m_ItemGrid = self:NewUI(4, CGrid)
	self.m_ItemBox = self:NewUI(5, CItemRewardBox)
	self.m_ExpGrid = self:NewUI(6, CGrid)
	self.m_ExpBox = self:NewUI(7, CBox)
	self.m_PassStarGrid = self:NewUI(8, CGrid)
	self.m_DelayCloseLabel = self:NewUI(9, CLabel)
	self:InitContent()
end

function CChapterFuBenResultView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_ExpDatas = {}
	self.m_ItemDatas = {}
	self.m_ConditionDatas = {}

	self.m_WinEffect = CEffect.New("Effect/UI/ui_eff_1159/Prefabs/ui_eff_1159_shengli.prefab", self:GetLayer(), false)
	self.m_WinEffect:SetParent(self.m_Win.m_Transform)
	self.m_ExpBox:SetActive(false)
	self.m_ItemBox:SetActive(false)
	self.m_PassStarGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_StarSprite = oBox:NewUI(1, CSprite)
		oBox.m_CondionLabel = oBox:NewUI(2, CLabel)
		return oBox
	end)
end

function CChapterFuBenResultView.RefreshResultInfo(self, lExpDatas, lItemDatas, lConditionDatas)
	self.m_ExpDatas = lExpDatas or {}
	self.m_ItemDatas = lItemDatas or {}
	self.m_ConditionDatas = lConditionDatas or {}
	self:RefreshExpGrid()
	self:RefreshItemGrid()
	self:RefreshPassStarGrid()
end

function CChapterFuBenResultView.RefreshExpGrid(self)
	self.m_ExpGrid:Clear()
	for i, dExp in ipairs(self.m_ExpDatas) do
		local oBox = self.m_ExpBox:Clone()
		oBox:SetActive(true)
		oBox.m_Avatar = oBox:NewUI(1, CSprite)
		oBox.m_ExpLabel = oBox:NewUI(2, CLabel)
		oBox.m_LvLabel = oBox:NewUI(3, CLabel)
		oBox.m_Slider = oBox:NewUI(4, CSlider)
		oBox.m_BoderSpr = oBox:NewUI(5, CSprite)
		oBox.m_ExpEffect = oBox:NewUI(6, CUIEffect, false)
		oBox.m_ServerGradeLabel = oBox:NewUI(7, CLabel)
		oBox.m_Avatar:SpriteAvatar(dExp.shape)
		local dPartner = data.partnerdata.DATA[dExp.shape]
		if not dPartner then
			for k,v in pairs(data.itemdata.PARTNER_SKIN) do
				if v.shape == dExp.shape then
					dPartner = data.partnerdata.DATA[v.partner_type]
					break
				end
			end
		end
		if dPartner then
			local rare = dPartner.rare
			local filename = define.Partner.CardColor[rare] or "hui"
			oBox.m_BoderSpr:SetSpriteName("bg_haoyoukuang_"..filename.."se")
			oBox.m_ServerGradeLabel:SetActive(false)
		else
			oBox.m_ServerGradeLabel:SetActive(dExp.is_over_grade or dExp.add_exp > 0)
			oBox.m_ServerGradeLabel:SetText(g_AttrCtrl:GetServerGradeWarDesc(dExp.cur_grade))
		end
		oBox.m_LeftAddExp = dExp.add_exp
		oBox.m_CurExp = dExp.cur_exp
		oBox.m_CurGrade = dExp.cur_grade
		oBox.m_MaxExpFunc = dExp.max_exp_func
		oBox.m_LimitGrade = dExp.limit_grade
		oBox.m_AddExp = 0
		oBox.m_Step = math.ceil(dExp.add_exp / 60)
		oBox.m_LvLabel:SetText(string.format("lv.%d", oBox.m_CurGrade))
		if oBox.m_CurGrade >= oBox.m_LimitGrade then
			oBox.m_ExpLabel:SetText("已满级")
			oBox.m_Slider:SetValue(1)
		else
			Utils.AddTimer(callback(self, "BoxExpAnim", oBox), 0, 0)
		end
		self.m_ExpGrid:AddChild(oBox)
	end
end

function CChapterFuBenResultView.BoxExpAnim(self, oBox)
	if Utils.IsNil(self) then
		return
	end
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
	if oBox.m_CurExp >= oBox.m_MaxExp and oBox.m_CurGrade < oBox.m_LimitGrade  then
		oBox.m_CurGrade = oBox.m_CurGrade + 1
		if not Utils.IsNil(oBox.m_LvLabel) then
			oBox.m_LvLabel:SetText(string.format("lv.%d#G(升级)#n", oBox.m_CurGrade))
			CWarResultView:DoBoxExpEffect(oBox)
		end
		oBox.m_MaxExp = nil
		oBox.m_Slider:SetValue(0)
		oBox.m_CurExp = 0
	else
		oBox.m_Slider:SetValue(oBox.m_CurExp/oBox.m_MaxExp)
	end
	if not Utils.IsNil(oBox.m_ExpLabel) then
		oBox.m_ExpLabel:SetText(string.format("EXP +%d", oBox.m_AddExp))
	end	
	return true
end

function CChapterFuBenResultView.RefreshItemGrid(self)
	self.m_ItemGrid:Clear()
	local config = {side = enum.UIAnchor.Side.Top}
	for i, v in ipairs(self.m_ItemDatas) do
		local oBox = self.m_ItemBox:Clone()
		oBox:SetActive(true)
		config.id = v.id
		config.virtual = v.virtual
		oBox:SetItemBySid(v.sid, v.amount, config)
		self.m_ItemGrid:AddChild(oBox)
	end
end

function CChapterFuBenResultView.RefreshPassStarGrid(self)
	for i,oBox in ipairs(self.m_PassStarGrid:GetChildList()) do
		local dCondtion = self.m_ConditionDatas[i]
		if dCondtion then
			oBox.m_StarSprite:SetActive(dCondtion.reach == 1)
			oBox.m_CondionLabel:SetText(dCondtion.condition)
		end
	end
end

function CChapterFuBenResultView.SetDelayCloseView(self)
	if self.m_DelayCloseTimer ~= nil then
		Utils.DelTimer(self.m_DelayCloseTimer)
		self.m_DelayCloseTimer = nil
	end
	self.m_DelayCloseLabel:SetActive(true)
	local cnt = 0
	local function update()
		if Utils.IsNil(self) then
			return
		end
		local str = string.format("%ds后自动关闭", 3 - cnt)
		self.m_DelayCloseLabel:SetText(str)
		if cnt < 3 then
			cnt = cnt + 1
			return true
		end
		self:CloseView()
	end
	self.m_DelayCloseTimer = Utils.AddTimer(update, 1, 0)
end

function CChapterFuBenResultView.CloseView(self)
	CViewBase.CloseView(self)
	g_WarCtrl:SetInResult(false)
end

return CChapterFuBenResultView