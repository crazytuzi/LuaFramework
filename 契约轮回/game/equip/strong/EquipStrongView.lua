--
-- @Author: chk
-- @Date:   2018-09-18 12:01:03
--
EquipStrongView = EquipStrongView or class("EquipStrongView",BaseItem)
local EquipStrongView = EquipStrongView

function EquipStrongView:ctor(parent_node,layer, sub_id)
	self.abName = "equip"
	self.assetName = "EquipStrengView"
	self.layer = layer

	self.model = EquipStrongModel:GetInstance()
	self.role_data = RoleInfoModel.GetInstance():GetMainRoleData()
	self.cost = 0
	self.suitInfoHeight = 0
	self.strongBtnBtn = nil
	self.autoStrongBtnBtn = nil
	self.cancleAutoStrongBtnBtn = nil
	--self.is_auto_strong = false
	self.crntSuitiD =   0              --当前强化套装属性id
	self.auto_strong_scheld_id = nil
	self.can_strong = true
	self.strongItemSettor = {}
	self.cast_items = {}
	self.equipDetail = nil
	self.equipIcon = nil
	self.select_equip = nil
	self.strongestItemSettor = {}
	self.itemSettor = {}
	self.suitAttItemSettors = {}
	self.globalEvents = {}
	self.processStar = {}
	self.processArea = {}
	self.events = {}
	self.effectProcessArea = {}
	if self.model.select_equip == nil then
		self.model.minStrongEquip = self.model:GetMinStrongEquip()
	end

	self.cast_cost_items = {}

	self.scrollRectTra = nil
	self.itemContentRectTra = nil
	self.model.strong_type = sub_id or 1
	EquipStrongView.super.Load(self)
end

function EquipStrongView:dctor()
	if self.blessProcessBar ~= nil then
		self.blessProcessBar:destroy()
		self.blessProcessBar = nil
	end

	if self.sucessEffect ~= nil then
		self.sucessEffect:destroy()
		self.sucessEffect = nil
	end

	if self.outEffect ~= nil then
		self.outEffect:destroy()
		self.outEffect = nil
	end

	if self.insideEffect ~= nil then
		self.insideEffect:destroy()
		self.insideEffect = nil
	end

	if self.auto_strong_scheld_id then
		GlobalSchedule:Stop(self.auto_strong_scheld_id)
		self.auto_strong_scheld_id = nil
	end

	if self.set_suit_schel_id ~= nil then
		GlobalSchedule:Stop(self.set_suit_schel_id)
	end

	if self.red_dot then
		self.red_dot:destroy()
		self.red_dot = nil 
	end
	if self.red_dot1 then
		self.red_dot1:destroy()
		self.red_dot1 = nil
	end
	if self.reddot_strong then
		self.reddot_strong:destroy()
		self.reddot_strong = nil
	end
	if self.reddot_cast then
		self.reddot_cast:destroy()
		self.reddot_cast = nil
	end
	if self.reddot_suite then
		self.reddot_suite:destroy()
		self.reddot_suite = nil
	end

	self.model.is_auto_strong = false
	self.model.select_equip = nil
	self.model.minStrongEquip = nil

	if 	self.equipIcon ~= nil then
		self.equipIcon:destroy()
	end
	self.equipIcon = nil


	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
	self.globalEvents = {}

	self.model.last_select_item = nil

	if self.bind_gold_event ~= nil then
		RoleInfoModel.GetInstance():GetMainRoleData():RemoveListener(self.bind_gold_event)
		self.bind_gold_event = nil
	end
	self.processStar = nil
	self:CleanItemSettors()
	self:CleanSuitItemSettors()
	self:CleanStrongItemSettors()
	for i=1, #self.cast_items do
		self.cast_items[i]:destroy()
	end
	self.model:RemoveTabListener(self.events)
	if self.casticongoods then
		self.casticongoods:destroy()
		self.casticongoods = nil
	end
	for k, v in pairs(self.cast_cost_items) do
		v:destroy()
	end
	self.cast_cost_items = nil
end

function EquipStrongView:LoadCallBack()
	self.nodes = {
		"leftInfo/itemScrollView",
		"leftInfo/itemScrollView/Viewport/itemContent",

		"leftInfo/title/StrongToggle/Label1",
		"leftInfo/title/CastToggle/Label2",

		"rightInfo",
		"rightInfoEmpty",

		"rightInfo/title/titleName",
		"rightInfo/StrongOperate",
		"rightInfo/StrongOperate/strongBtn",
		"rightInfo/StrongOperate/autoStrongBtn",
		"rightInfo/StrongOperate/cancleAutoStrongBtn",
		"rightInfo/attr/strongestTitle",
		"rightInfo/attr/strongestTitle/strongestPhase",

		"rightInfo/hadStrongest",
		"rightInfo/icon/iconContain",
		"rightInfo/icon/iconEffectContain",
		"rightInfo/attr/title",
		"rightInfo/attr/title/crntPhase",
		"rightInfo/attr/title/nextPhase",
		"rightInfo/StrongOperate/costInfo",
		"rightInfo/StrongOperate/costInfo/costValue",
		"rightInfo/suit/suitInfo/suitBG",
		"rightInfo/suit/suitInfo/suitMask",
		"rightInfo/suit/suitBtn",
		"rightInfo/suit/suitInfo",
		"rightInfo/suit/suitInfo/ScrollView/Viewport",
		"rightInfo/suit/suitInfo/phaseLv",
		"rightInfo/attr/StrongScrollView",
		"rightInfo/attr/StrongScrollView/Viewport/StrongAttContent",
		"rightInfo/attr/StrongestScrollView",
		"rightInfo/attr/StrongestScrollView/Viewport/StrongestAttContent",
		"rightInfo/suit/suitInfo/suitBG/suitItemContent",
		"rightInfo/SucessRatio/ratioVaue",
		"rightInfo/progress/prContain",
		"rightInfo/progress/pgrContain",
		"rightInfo/progress/prEffect",
		"rightInfo/ContentScrollView",
		"rightInfo/EffectScrollView/EffectViewport/EffectContent",
		"rightInfo/suit/TempValue",
		"rightInfo/Text",

		"rightInfo/progress/pgrContain/pgr_1/pgr1_icon",
		"rightInfo/progress/pgrContain/pgr_2/pgr2_icon",
		"rightInfo/progress/pgrContain/pgr_3/pgr3_icon",
		"rightInfo/progress/pgrContain/pgr_4/pgr4_icon",
		"rightInfo/progress/pgrContain/pgr_5/pgr5_icon",
		"rightInfo/progress/pgrContain/pgr_6/pgr6_icon",
		"rightInfo/progress/pgrContain/pgr_7/pgr7_icon",
		"rightInfo/progress/pgrContain/pgr_8/pgr8_icon",
		"rightInfo/progress/pgrContain/pgr_9/pgr9_icon",
		"rightInfo/progress/pgrContain/pgr_10/pgr10_icon",
		"leftInfo/title/StrongToggle",
		"leftInfo/title/CastToggle",
		"leftInfo/castScrollView",
		"leftInfo/castScrollView/Viewport/castContent",
		"leftInfo/castScrollView/Viewport/castContent/EquipCastItem",
		"rightcastInfo",
		"rightcastInfo/iconbg/casticon",
		"rightcastInfo/iconbg/casticonname",
		"rightcastInfo/castleft/curcastlevel",
		"rightcastInfo/CastScrollView",
		"rightcastInfo/CastScrollView/Viewport/CastCostContent",
		"rightcastInfo/castbtn",
		"rightcastInfo/tipbtn",
		"rightcastInfo/getwaybtn",
		"rightcastInfo/castright/nextcastlevel",
		"rightcastInfo/castright2",
		"rightcastInfo/castright",
		"rightcastInfo/castleft/curcastattr1",
		"rightcastInfo/castleft/curcastattr2",
		"rightcastInfo/castright/nextcastattr1",
		"rightcastInfo/castright/nextcastattr2",
		"rightcastInfo/castmaxinfo",
		"rightInfo/composetipbtn",
	}
	self:GetChildren(self.nodes)
	self:GetTranComponent()
	self.casticonname = GetText(self.casticonname)
	self.curcastlevel = GetText(self.curcastlevel)
	self.nextcastlevel = GetText(self.nextcastlevel)
	self.curcastattr1 = GetText(self.curcastattr1)
	self.curcastattr2 = GetText(self.curcastattr2)
	self.nextcastattr1 = GetText(self.nextcastattr1)
	self.nextcastattr2 = GetText(self.nextcastattr2)
	self.castmaxinfo = GetText(self.castmaxinfo)
	self.Text = GetText(self.Text)
	self.ratioVaue = GetText(self.ratioVaue)
	self.Label1 = GetText(self.Label1)
	self.Label2 = GetText(self.Label2)
	self:AddEvent()

	if self.model.strong_type == 1 then
		self.StrongToggle_tg.isOn = true
	else
		self.CastToggle_tg.isOn = true
	end
	if OpenTipModel.GetInstance():IsOpenSystem(120,5) then
		SetVisible(self.CastToggle, true)
	else
		SetVisible(self.CastToggle, false)
	end
	self:LoadItems()
	self:LoadCastItems()
	self:ShowByType()
	--self:LoadProcessPgr()
end

function EquipStrongView:CleanStrongItemSettors(  )
	for k,v in pairs(self.strongItemSettor) do
		v:destroy()
	end
	self.strongItemSettor = {}
end

--function EquipStrongView:LoadProcessPgr()
--	for i, v in ipairs(self.processPgr) do
--		local arange = 3.37 - (i-1) * 0.52
--		local y = 100 * math.sin(arange)
--		local x = 100 * math.cos(arange)
--
--		SetLocalPosition(self.processPgr[i].transform,x,y)
--		SetLocalRotation(self.processPgr[i].transform,0,0,math.deg(arange))
--	end
--end

function EquipStrongView:LoadProcessStar(star)

end

--强化
function EquipStrongView:LoadItems()
	local putOnedEquips = EquipModel.Instance:GetCanStrongEquips()
	if table.nums(putOnedEquips) > 0 then
		local count = 0
		for i, v in pairs(putOnedEquips) do
			count  = count + 1
			local item = EquipStrongItemSettor(self.itemContent,"UI")
			item:UpdateInfo(v,count)
			self.strongItemSettor[#self.strongItemSettor+1] = item
		end
		self:SetScrollViwe()
	end
end

--铸造
function EquipStrongView:LoadCastItems()
	local putOnedEquips = EquipModel.Instance:GetCanCastEquips()
	if table.nums(putOnedEquips) > 0 then
		for i, v in pairs(putOnedEquips) do
			local item = EquipCastItem(self.EquipCastItem_gameobject, self.castContent)
			item:SetData(v)
			self.cast_items[#self.cast_items+1] = item
		end
		self.cast_pitem = putOnedEquips[1]
	end
end

function EquipStrongView:CreateDelStrongestAttrItemLess(attrTbl)
	local itemCount = table.nums(self.strongestItemSettor)
	local attrCount = table.nums(attrTbl)

	if attrCount > itemCount then
		for i = 1, attrCount - itemCount do
			self.strongestItemSettor[#self.strongestItemSettor+1] = StrongestAttItemSettor(self.StrongestAttContent,"UI")
		end
	elseif attrCount < itemCount then
		for i = 1, itemCount - attrCount do
			if self.strongestItemSettor[i] then
				self.strongestItemSettor[i]:destroy()
				self.strongestItemSettor[i] = nil
			end

		end
	end
end


function EquipStrongView:CreateDelAttrItemLess(attrTbl)
	local itemCount = table.nums(self.itemSettor)
	local attrCount = table.nums(attrTbl)

	if attrCount > itemCount then
		for i = 1, attrCount - itemCount do
			self.itemSettor[#self.itemSettor+1] = StrongAttItemSettor(self.StrongAttContent,"UI")
		end
	elseif attrCount < itemCount then
		for i = 1, itemCount - attrCount do
			if self.itemSettor[i] then
				self.itemSettor[i]:destroy()
				self.itemSettor[i] = nil
			end

		end
	end
end

function EquipStrongView:CleanSuitItemSettors(  )
	for k,v in pairs(self.suitAttItemSettors) do
		v:destroy()
	end
	self.suitAttItemSettors = {}


end


function EquipStrongView:SetSuitAttrInfo(suiteId,titleInfo)
	self.suitAttItemSettors[#self.suitAttItemSettors+1] = StrongSuitTitleItemSettor(self.suitItemContent,"UI")
	self.suitAttItemSettors[#self.suitAttItemSettors]:UpdateInfo({title = titleInfo,pos = self.suitInfoHeight})
	self.TempValueTxt.text =  titleInfo
	self.suitInfoHeight = self.TempValueTxt.preferredHeight + self.suitInfoHeight + 16
	local cfgTbl = String2Table(Config.db_equip_strength_suite[suiteId].attrib)
	for k,v in pairs(cfgTbl) do
		local  suitAtt = {att = v[1],value = v[2],pos = self.suitInfoHeight}
		self.suitAttItemSettors[#self.suitAttItemSettors+1] = StrongSuitItemSettor(self.suitItemContent,"UI")
		self.suitAttItemSettors[#self.suitAttItemSettors]:UpdateInfo(suitAtt)

		self.TempValueTxt.text = v[2]
		self.suitInfoHeight = self.suitInfoHeight + self.TempValueTxt.preferredHeight
	end

	self.suitItemContentRectTra.sizeDelta = Vector2(self.suitItemContentRectTra.sizeDelta.x,self.suitInfoHeight)
	self.suitBGRectTra.sizeDelta = Vector2(self.suitItemContentRectTra.sizeDelta.x,self.suitItemContentRectTra.sizeDelta.y + 50)
	--if self.set_suit_schel_id ~= nil then
	--	GlobalSchedule:Stop(self.set_suit_schel_id)
	--end
	--self.set_suit_schel_id = GlobalSchedule:StartOnce(handler(self,self.DelaySetSuitBG),0.09)
end

--加载套装属性
function  EquipStrongView:ShowSuitAttr( suiteId)
	SetVisible(self.suitInfo.gameObject,true)
	LayerManager.GetInstance():AddOrderIndexByCls(self,self.suitInfo.transform, nil, nil,nil, true)
	self:CleanSuitItemSettors()

	--self.phaseLv:GetComponent('Text').text =  self.equipDetail.equip.stren_phase .. ConfigLanguage.Equip.Phase ..
	--		self.equipDetail.equip.stren_lv .. ConfigLanguage.Equip.LV

	if suiteId == 0 then
		local suitCfg = Config.db_equip_strength_suite[1]
		local strongCount = self.model:GetStrongCountByPhase(suitCfg.phase,suitCfg.level)
		local countInfo = "(" .. string.format("<color=#%s>%s</color>/%s",ColorUtil.GetColor(ColorUtil.ColorType.Red),strongCount,suitCfg.num) .. ")"
		local titleInfo = string.format(ConfigLanguage.Equip.StrongTo  ,suitCfg.num, suitCfg.phase,suitCfg.level)

		self:SetSuitAttrInfo(1,ConfigLanguage.Equip.StrongEffect .. "\n" .. titleInfo .. countInfo)
	else
		local suitCfg = Config.db_equip_strength_suite[suiteId]
		local countInfo = "(" .. string.format("<color=#%s>%s</color>",ColorUtil.GetColor(ColorUtil.ColorType.Green),
		ConfigLanguage.Equip.HadActive) .. ")"
		local titleInfo = string.format(ConfigLanguage.Equip.StrongTo  ,suitCfg.num, suitCfg.phase,suitCfg.level)

		self:SetSuitAttrInfo(suiteId,ConfigLanguage.Equip.StrongEffect .. "\n" .. titleInfo .. countInfo)


		local nextSuitCfg = Config.db_equip_strength_suite[suiteId + 1]
		if nextSuitCfg ~= nil then

			local suitCfg = Config.db_equip_strength_suite[suiteId+1]
			local strongCount = self.model:GetStrongCountByPhase(suitCfg.phase,suitCfg.level)
			local countInfo = "(" .. string.format("<color=#%s>%s</color>/%s",ColorUtil.GetColor(ColorUtil.ColorType.Red),strongCount,suitCfg.num) .. ")"
			local titleInfo = string.format(ConfigLanguage.Equip.StrongTo  ,suitCfg.num, suitCfg.phase,suitCfg.level)

			self:SetSuitAttrInfo(suiteId + 1,ConfigLanguage.Equip.StrongEffectNext .. "\n" .. titleInfo .. countInfo)
		end
	end


end

function EquipStrongView:AddEvent()
	local function call_back()
		local a = 3
	end

	self.bind_gold_event = self.role_data:BindData(Constant.GoldType.Gold,call_back)

	AddClickEvent(self.strongBtn.gameObject,handler(self,self.Strong))

	local function call_back( )
		--[[if self.suitInfo.gameObject.activeSelf then
			self.suitInfoHeight = 0
			SetVisible(self.suitInfo.gameObject,false)
		else
			EquipController.Instance:RequestStrongSuite()
		end--]]
		lua_panelMgr:GetPanelOrCreate(EquipStrongSuitePanel):Open()
	end 
	AddClickEvent(self.suitBtn.gameObject,call_back)
	AddClickEvent(self.suitMask.gameObject,call_back)
	AddClickEvent(self.autoStrongBtn.gameObject,handler(self,self.AutoRequestStrong))
	AddClickEvent(self.cancleAutoStrongBtn.gameObject,handler(self,self.CancleAutoStrong))

	local function call_back(target,x,y)
		ShowHelpTip(HelpConfig.Equip.EquipCast, true)
	end
	AddClickEvent(self.tipbtn.gameObject,call_back)


	local function call_back(target, value)
		if value then
			self.model.strong_type = 1
			self:ShowByType()
			SetColor(self.Label1, 122, 140, 185)
			SetColor(self.Label2, 255, 255, 255)
		end
	end
	AddValueChange(self.StrongToggle_tg.gameObject, call_back)

	local function call_back(target, value)
		if value then
			self.model.strong_type = 2
			self:ShowByType()
			SetColor(self.Label2, 122, 140, 185)
			SetColor(self.Label1, 255, 255, 255)
		end
	end
	AddValueChange(self.CastToggle_tg.gameObject, call_back)

	local function call_back(target,x,y)
		local slot = Config.db_equip[self.cast_pitem.id].slot
		EquipController:GetInstance():RequestCast(slot)
	end
	AddClickEvent(self.castbtn.gameObject,call_back)

	local function call_back(target,x,y)
		lua_panelMgr:GetPanelOrCreate(ComposeEquipTipPanel):Open()
	end
	AddButtonEvent(self.composetipbtn.gameObject,call_back)

	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.ShowStrongInfo,handler(self,self.DealShowStrongInfo))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail,handler(self,self.DealEquipUpdate))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.StrongSucess,handler(self,self.DealStrongSucess))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.StrongFail,handler(self,self.DealStrongFail))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.StrongItemPos,handler(self,self.DealSetScrollPos))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.StrongBless,handler(self,self.DealBless))

	
	local function call_back()
		self:ShowRedDot()
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.EquipStrongAll, call_back)
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.ShowSuitAttr, call_back)

	function call_back(equipDetail)
		self.cast_pitem = equipDetail
		self:ShowCastInfo(equipDetail)
	end
	self.events[#self.events+1] = self.model:AddListener(EquipEvent.SelectCastItem, call_back)
end

function EquipStrongView:ShowByType()
	if self.model.strong_type == 1 then
		SetVisible(self.itemScrollView, true)
		SetVisible(self.castScrollView, false)
		SetVisible(self.rightcastInfo.gameObject,false)
		if #self.strongItemSettor > 0 then
			SetVisible(self.rightInfoEmpty.gameObject,false)
			SetVisible(self.rightInfo.gameObject,true)
		else
			SetVisible(self.rightInfoEmpty.gameObject,true)
			SetVisible(self.rightInfo.gameObject,false)
		end
	else
		SetVisible(self.itemScrollView, false)
		SetVisible(self.castScrollView, true)
		SetVisible(self.rightInfo.gameObject,false)
		if #self.cast_items > 0 then
			SetVisible(self.rightInfoEmpty.gameObject,false)
			SetVisible(self.rightcastInfo.gameObject,true)
		else
			SetVisible(self.rightInfoEmpty.gameObject,true)
			SetVisible(self.rightcastInfo.gameObject,false)
		end
		if self.cast_pitem then
			self.model:Brocast(EquipEvent.SelectCastItem, self.cast_pitem)
		end
	end
end

function EquipStrongView:CleanItemSettors()
	for i, v in pairs(self.itemSettor) do
		v:destroy()
	end
	self.itemSettor = {}

	for i, v in pairs(self.strongestItemSettor) do
		v:destroy()
	end
end

function EquipStrongView:DealEquipUpdate(equipDetail)
	if self.equipDetail ~= nil and self.equipDetail.uid == equipDetail.uid then
		self.equipDetail = equipDetail
		self:UpdateProgress(equipDetail.equip.stren_lv)
		self:ShowStrongInfo(equipDetail)
	end
	if self.cast_pitem ~= nil and self.cast_pitem.uid == equipDetail.uid then
		self:ShowCastInfo(equipDetail)
	end
	self:ShowRedDot()
end

function EquipStrongView:DealStrongSucess()
	--Notify.ShowText(ConfigLanguage.Equip.StrongSucess)

	if self.sucessEffect ~= nil then
		self.sucessEffect:destroy()
	end

	self.sucessEffect = UIEffect(self.iconContain,10003,false,self.layer)
	self.sucessEffect:SetConfig({is_loop = false})
	SoundManager.GetInstance():PlayById(54)

	if self.model.is_auto_strong then
		if self.auto_strong_scheld_id ~= nil then
			GlobalSchedule:Stop(self.auto_strong_scheld_id)
		end
		self.auto_strong_scheld_id = GlobalSchedule:StartOnce(handler(self,self.RequestStrong),0.3)
	end
	self:ShowRedDot()
end

function EquipStrongView:EnableStrongBtn(enable)
	self.strongBtnBtn.interactable=enable
	--self.strongBtnBtn.enabled = enable
	self.autoStrongBtnBtn.interactable=enable
	self.cancleAutoStrongBtnBtn.interactable = enable
	--self.autoStrongBtnBtn.enabled = enable
end

function EquipStrongView:SetScrollViwe()
	local count = table.nums(EquipModel.Instance:GetCanStrongEquips())
	local y =  100 * count
	self.itemContentRectTra.sizeDelta = Vector2(self.itemContentRectTra.sizeDelta.x,y)
end

function EquipStrongView:DelaySetSuitBG()
	self.suitBGRectTra.sizeDelta = Vector2(self.suitItemContentRectTra.sizeDelta.x,self.suitItemContentRectTra.sizeDelta.y + 50)
end

--选中最小的强化等级后，要自动设置位置
function EquipStrongView:DealSetScrollPos(itemSettor)
	local scrollRectTra = self.itemScrollView:GetComponent('RectTransform')
	local itemContentRectTra = self.itemContent:GetComponent('RectTransform')
	local itemRectTra = itemSettor.transform:GetComponent('RectTransform')
	local posY = GetLocalPositionY(itemSettor.transform)

	local itemH = math.abs(posY) + 100
	if itemH > scrollRectTra.sizeDelta.y then
		itemContentRectTra.anchoredPosition = Vector2(itemContentRectTra.anchoredPosition.x,itemH - scrollRectTra.sizeDelta.y)
	end

end

function EquipStrongView:DealBless(data)
	if self.blessProcessBar == nil then
		self.blessProcessBar = StrongCircleProcessBar(self.prContain)
	end


	local equipConfig = Config.db_equip[self.equipDetail.id]
	local strong_key = equipConfig.slot .. "@" .. self.equipDetail.equip.stren_phase .. "@" .. self.equipDetail.equip.stren_lv
	
	if Config.db_equip_strength[strong_key] ~= nil then
		local max_bless_value = Config.db_equip_strength[strong_key].max_bless_value
		self.blessProcessBar:UpdateProcess(data.bless, max_bless_value)
		local progress = math.floor(data.bless / max_bless_value * 100)
		self.ratioVaue.text =  progress .. "%"
	end
end

function  EquipStrongView:DealStrongFail()
	--Notify.ShowText(ConfigLanguage.Equip.StrongFail)

	if self.model.is_auto_strong then
		if self.uto_strong_scheld_id ~= nil then
			GlobalSchedule:Stop(self.auto_strong_scheld_id)
		end
		self.auto_strong_scheld_id = GlobalSchedule:StartOnce(handler(self,self.RequestStrong),0.3)
	end
	self:ShowRedDot()
end

function EquipStrongView:GetTranComponent(  )
	self.titleNameTxt = self.titleName:GetComponent('Text')
	self.costValueTxt = self.costValue:GetComponent('Text')
	self.crntPhaseTxt = self.crntPhase:GetComponent('Text')
	self.nextPhaseTxt = self.nextPhase:GetComponent('Text')
	self.strongestPhaseTxt = self.strongestPhase:GetComponent('Text')
	self.strongBtnBtn = self.strongBtn:GetComponent('Button')
	self.autoStrongBtnBtn = self.autoStrongBtn:GetComponent('Button')
	self.cancleAutoStrongBtnBtn = self.cancleAutoStrongBtn:GetComponent('Button')
	self.scrollRectTra = self.itemScrollView:GetComponent('RectTransform')
	self.itemContentRectTra = self.itemContent:GetComponent('RectTransform')
	self.suitItemContentRectTra = self.suitItemContent:GetComponent('RectTransform')
	self.suitBGRectTra = self.suitBG:GetComponent('RectTransform')
	self.ContentScrollViewRectTra = self.ContentScrollView:GetComponent('RectTransform')
	self.TempValueTxt = self.TempValue:GetComponent('Text')
	self.StrongToggle_tg = GetToggle(self.StrongToggle)
	self.CastToggle_tg = GetToggle(self.CastToggle)
	self.EquipCastItem_gameobject = self.EquipCastItem.gameObject
	SetVisible(self.EquipCastItem_gameobject, false)

	self.processArea[0] = {fromProcess = 0.1,endProcess = 0.1}
	self.processArea[1] = {fromProcess = 0.1,endProcess = 0.155}
	self.processArea[2] = {fromProcess = 0.155,endProcess = 0.255}
	self.processArea[3] = {fromProcess = 0.255,endProcess = 0.365}
	self.processArea[4] = {fromProcess = 0.365,endProcess = 0.465}
	self.processArea[5] = {fromProcess = 0.465,endProcess = 0.544}
	self.processArea[6] = {fromProcess = 0.544,endProcess = 0.644}
	self.processArea[7] = {fromProcess = 0.644,endProcess = 0.756}
	self.processArea[8] = {fromProcess = 0.756,endProcess = 0.855}
	self.processArea[9] = {fromProcess = 0.855,endProcess = 0.901}

	self.effectProcessArea[0] = {fromProcess = 3.65,endProcess = 3.65}
	self.effectProcessArea[1] = {fromProcess = 3.65,endProcess = 3.37}
	self.effectProcessArea[2] = {fromProcess = 3.37,endProcess = 2.97}
	self.effectProcessArea[3] = {fromProcess = 2.97,endProcess = 2.45}
	self.effectProcessArea[4] = {fromProcess = 2.45,endProcess = 1.95}
	self.effectProcessArea[5] = {fromProcess = 1.95,endProcess = 1.09}
	self.effectProcessArea[6] = {fromProcess = 1.09,endProcess = 0.63}
	self.effectProcessArea[7] = {fromProcess = 0.63,endProcess = 0.16}
	self.effectProcessArea[8] = {fromProcess = 0.16,endProcess = -0.19}
	self.effectProcessArea[9] = {fromProcess = -0.19,endProcess = -0.45}

	self.processStar[1] = self.pgr1_icon
	self.processStar[2] = self.pgr2_icon
	self.processStar[3] = self.pgr3_icon
	self.processStar[4] = self.pgr4_icon
	self.processStar[5] = self.pgr5_icon
	self.processStar[6] = self.pgr6_icon
	self.processStar[7] = self.pgr7_icon
	self.processStar[8] = self.pgr8_icon
	self.processStar[9] = self.pgr9_icon
	self.processStar[10] = self.pgr10_icon

	SetVisible(self.cancleAutoStrongBtn.gameObject,false)
end


function EquipStrongView:JudgeNeedStrong(equipDetail)
	local need = true
	--if self.equipDetail ~= nil and equipDetail.uid == self.equipDetail.uid and
	--		equipDetail.equip.stren_phase == self.equipDetail.equip.stren_phase and
	--	equipDetail.equip.stren_lv == self.equipDetail.equip.stren_lv then
	--	need = false
	--end

	return need
end
function EquipStrongView:DealShowStrongInfo(equipDetail)
	if self.auto_strong_scheld_id ~= nil then
		GlobalSchedule:Stop(self.auto_strong_scheld_id)
		self.auto_strong_scheld_id = nil
	end

	self.model.is_auto_strong = false

	SetVisible(self.autoStrongBtn.gameObject,true)
	SetVisible(self.cancleAutoStrongBtn.gameObject,false)


	local equipConfig = Config.db_equip[equipDetail.id]
	EquipController.GetInstance():RequestStrongBless(equipConfig.slot)
	self:ShowStrongInfo(equipDetail)
	self:UpdateProgressDirectly(equipDetail.equip.stren_lv)
end

function EquipStrongView:AutoRequestStrong()

	if self.role_data.coin < self.cost then
		self.model.is_auto_strong = false
		Notify.ShowText(ConfigLanguage.Mix.NotEnoughGold)

		SetVisible(self.autoStrongBtnBtn.gameObject,true)
		SetVisible(self.cancleAutoStrongBtn.gameObject,false)
		return
	end

	if self.strongBtnBtn.interactable then
		self.model.is_auto_strong = true
		self:RequestStrong()

		SetVisible(self.autoStrongBtnBtn.gameObject,false)
		SetVisible(self.cancleAutoStrongBtn.gameObject,true)
	end
end

function EquipStrongView:CancleAutoStrong()
	if not self.strongBtnBtn.interactable then
		return
	end

	SetVisible(self.autoStrongBtnBtn.gameObject,true)
	SetVisible(self.cancleAutoStrongBtn.gameObject,false)

	self.model.is_auto_strong = false
	if self.auto_strong_scheld_id ~= nil then
		GlobalSchedule:Stop(self.auto_strong_scheld_id)
		self.auto_strong_scheld_id = nil
	end
end

function EquipStrongView:Strong()
	--local y = self.ContentScrollViewRectTra.anchoredPosition.y * math.sin(self.ContentScrollViewRectTra.anchoredPosition.x)
	--local x = self.ContentScrollViewRectTra.anchoredPosition.y * math.cos(self.ContentScrollViewRectTra.anchoredPosition.x)
	----self.jinduEffect:SetPosition(x,y)
	--
	--self:UpdateProgress(self.ContentScrollViewRectTra.anchoredPosition.x)
	--self:UpdateProcessEffect(self.ContentScrollViewRectTra.anchoredPosition.x)
	--return
	self.model.is_auto_strong = false
	if self.model:IsAllStrongMax() then
		Notify.ShowText("All have been enhanced to the max level, don't need to enhance")
	else
		if EquipStrongModel:GetNeedShowRedDot() then
			self.model.minStrongEquip = nil
			EquipController:GetInstance():RequestStrongAll(Config.db_equip[self.equipDetail.id].slot)
		else
			Notify.ShowText("Not enough gold")
		end
	end
end

function EquipStrongView:RequestStrong()
	if not self.strongBtnBtn.interactable then
		self.model.is_auto_strong = false
		--local function call_back()
			local select_equip = self.model:GetMinStrongEquip()
			if not self.model:IsMaxStrong(select_equip) then
				GlobalEvent:Brocast(EquipEvent.SelectEquipItem, select_equip)
			end
		--end
		--GlobalSchedule:StartOnce(call_back, 0.3)
		return
	end

	if self.role_data.coin >= self.cost then
		EquipController.Instance:RequestStrong(Config.db_equip[self.equipDetail.id].slot)
	else
		self.model.is_auto_strong = false
		Notify.ShowText(ConfigLanguage.Mix.NotEnoughGold)

		SetVisible(self.autoStrongBtnBtn.gameObject,true)
		SetVisible(self.cancleAutoStrongBtn.gameObject,false)
	end
end

function EquipStrongView:ShowEffect()
	if self.outEffect == nil then
		self.outEffect = UIEffect(self.iconEffectContain, 10001)
	end
end


function EquipStrongView:ShowStrongInfo(equipDetail)
	if not self:JudgeNeedStrong(equipDetail) then
		return
	end

	self:ShowEffect()
	--self:CleanItemSettors()

	if self.equipIcon == nil then
		self.equipIcon = GoodsIconSettorTwo(self.iconContain)
	end

	if  (self.equipDetail ~= nil and self.equipDetail.id ~= equipDetail.id) or self.equipDetail == nil then
		--self.equipIcon:UpdateIconClickNotOperate(equipDetail,nil,{x=90,y=90})

		local param = {}
		param["not_need_compare"] = true
		param["model"] = self.model
		param["p_item"] = equipDetail
		param["item_id"] = equipDetail.id
		param["size"] = {x = 76,y=76}
		param["can_click"] = true
		self.equipIcon:SetIcon(param)
	end

	self.equipDetail = equipDetail

	local itemConfig = Config.db_item[self.equipDetail.id]
	local equipConfig = Config.db_equip[self.equipDetail.id]
	local strong_key = equipConfig.slot .. "@" .. self.equipDetail.equip.stren_phase .. "@" .. self.equipDetail.equip.stren_lv
	local strong_limit_key = equipConfig.slot .. "@" .. equipConfig.order .. "@" .. itemConfig.color
	if Config.db_equip_strength_limit[strong_limit_key] == nil then
		Chkprint("EquipStrongView 207  强化限制表id 没有",strong_limit_key)
		return
	end

	self:ShowStrongestBtnAbout(false)

	--if self.model.suitId > 0 then
	--	local suitCfg = Config.db_equip_strength_suite[self.model.suitId]
	--	self.titleNameTxt.text = "s" .. suitCfg.phase .. "d" .. suitCfg.level .. "j"
	--else
	--	self.titleNameTxt.text = "s" .. 0 .. "d" .. 0 .. "j"
	--end


	self.strongestInfo = ""
	local next_strong = self.model:GetNextStrong(equipConfig.slot,self.equipDetail.equip.stren_phase,self.equipDetail.equip.stren_lv)
	if self.model:GetNextPhase(equipConfig.slot,self.equipDetail.equip.stren_phase,self.equipDetail.equip.stren_lv) >= Config.db_equip_strength_limit[strong_limit_key].max_phase then
		self:ShowStrongestInfo()

	elseif Config.db_equip_strength[strong_key] ~= nil then
		if next_strong ~= nil then
			if not self.strongBtnBtn.interactable then
				self:EnableStrongBtn(true)
			end

			SetVisible(self.StrongScrollView.gameObject,true)
			SetVisible(self.StrongestScrollView.gameObject,false)

			SetVisible(self.title.gameObject,true)
			SetVisible(self.strongestTitle.gameObject,false)

			local costCfg = String2Table(Config.db_equip_strength[strong_key].cost)

			for i, v in pairs(costCfg) do
				self.cost = v
			end

			local _strong_info = "T"..self.equipDetail.equip.stren_phase  .."Lv."..self.equipDetail.equip.stren_lv
			self.costValueTxt.text = self.cost
			self.crntPhaseTxt.text =  "d"..self.equipDetail.equip.stren_phase  .. "j"..self.equipDetail.equip.stren_lv
			self.nextPhaseTxt.text = "d" ..next_strong.phase .. "j".. next_strong.level
			--self.ratioVaue:GetComponent('Text').text = Config.db_equip_strength[strong_key].prob .. "%"
			SetVisible(self.Text, true)
			self.Text.text = "<color=#6ce19b>" .. Config.db_equip_strength[strong_key].prob .. "%</color> chance to directly up to 1 level"
			local crntStrongAtt = String2Table(Config.db_equip_strength[strong_key].attrib)
			local nextStrongAtt = String2Table(next_strong.attrib)

			self:CreateDelAttrItemLess(crntStrongAtt)
			for i, v in pairs(crntStrongAtt) do
				local strong_att = {att = v[1],value = v[2]}
				local next_att = {att = v[1],value = nextStrongAtt[i][2]}
				--self.itemSettor[#self.itemSettor+1] = StrongAttItemSettor(self.StrongAttContent,"UI")
				self.itemSettor[i]:UpdateInfo(strong_att,next_att)
			end

			GlobalEvent:Brocast(EquipEvent.PhaseChange,self.equipDetail,_strong_info)
		else --最高了
			self:ShowStrongestInfo()
		end
	end
	self:ShowRedDot()
end

function EquipStrongView:ShowStrongestBtnAbout(show)
	local _show = not show
	SetVisible(self.StrongOperate.gameObject,_show)

	SetVisible(self.hadStrongest.gameObject,show)
end

--显示最高强化等级的信息
function EquipStrongView:ShowStrongestInfo()
	if self.strongBtnBtn.interactable then
		self:EnableStrongBtn(false)
	end
	SetVisible(self.Text, false)
	SetVisible(self.StrongScrollView.gameObject,false)
	SetVisible(self.StrongestScrollView.gameObject,true)

	self:ShowStrongestBtnAbout(true)
	self.strongestPhaseTxt.text = self.equipDetail.equip.stren_phase .. "d" ..
													self.equipDetail.equip.stren_lv .. "j"
	self.strongestInfo = "(" .. ConfigLanguage.Equip.StrongestLV .. ")"

	self.ratioVaue:GetComponent('Text').text = "0%"
	SetVisible(self.title.gameObject,false)
	SetVisible(self.strongestTitle.gameObject,true)

	local  strongCfg = self.model:GetStrongConfig(self.equipDetail.id,self.equipDetail.equip.stren_phase,self.equipDetail.equip.stren_lv)
	if strongCfg ~= nil then
		local strongestTbl = String2Table(strongCfg.attrib)
		self:CreateDelStrongestAttrItemLess(strongestTbl)
		for k,v in pairs(strongestTbl) do
			local strongAttr = {att = v[1],value = v[2]}
			 --self.itemSettor[#self.itemSettor+1] = StrongestAttItemSettor(self.StrongAttContent,"UI")
			 self.strongestItemSettor[k]:UpdateInfo(strongAttr)
		end
	end

	local strongestPhaseTxt = self.equipDetail.equip.stren_phase .. "Stage" ..
													self.equipDetail.equip.stren_lv .. "Level"
	GlobalEvent:Brocast(EquipEvent.PhaseChange,self.equipDetail, strongestPhaseTxt .. self.strongestInfo)
end  

function EquipStrongView:SetData(data)

end

function EquipStrongView:SetProcessEffectPosition()
	self.crntProcessEffect = self.crntProcessEffect + self.processEffectSpeed
	if self.crntProcessEffect <= self.endProcessEffect then
		self.crntProcessEffect = self.endProcessEffect
		GlobalSchedule:Stop(self.process_effect_scheld_id)
		self.process_effect_scheld_id = nil
	end

	local y = 100 * math.sin(self.crntProcessEffect)
	local x = 100 * math.cos(self.crntProcessEffect)
	self.jinduEffect:SetPosition(x,y)
end

function EquipStrongView:UpdateProcessEffect(process)
	if self.process_effect_scheld_id ~= nil then
		GlobalSchedule:Stop(self.process_effect_scheld_id)
	end

	if process == 9 then
		self.endProcessEffect = -0.55
	else
		self.endProcessEffect = 3.37 - (process - 1) * 0.52
	end

	self.processEffectCount = 0

	if process == 1 then
		self.crntProcessEffect = 3.67
	else
		self.crntProcessEffect = 3.37 - (process - 2) * 0.52
	end

	self.processEffectSpeed = (self.endProcessEffect - self.crntProcessEffect) / 10


	self.process_effect_scheld_id = GlobalSchedule:Start(handler(self,self.SetProcessEffectPosition),Time.deltaTime,-1)
end

function EquipStrongView:UpdateProgressEffectDirectly(process)
	if self.jinduEffect ~= nil then
		if process == 0 then
			self.endProcessEffect = 3.67
		elseif process == 9 then
			self.endProcessEffect = -0.55
		else
			self.endProcessEffect = 3.37 - (process - 1) * 0.52
		end


		local y = 100 * math.sin(self.endProcessEffect)
		local x = 100 * math.cos(self.endProcessEffect)
		self.jinduEffect:SetPosition(x,y)
	end
end

function EquipStrongView:UpdateProgress(process)

	----祝福值进度条
	--if self.blessProcessBar == nil then
	--	self.blessProcessBar = StrongCircleProcessBar(self.prContain)
	--end
	--
	--self.blessProcessBar:UpdateProcess(self.processArea[process].fromProcess,self.processArea[process].endProcess)

	--self:UpdateProcessEffect(process)

	self:UpdateProcessStar(process)
end

function EquipStrongView:UpdateProcessStar(process)
	if process == 0 then
		for i = 1, 10 do
			SetVisible(self.processStar[i].gameObject,false)
		end
	else
		for i = 1, 10 do
			if i <= process then
				SetVisible(self.processStar[i].gameObject,true)
			else
				SetVisible(self.processStar[i].gameObject,false)
			end
		end
	end
end

function EquipStrongView:UpdateProgressDirectly(process)
	self:UpdateProgressEffectDirectly(process)

	self:UpdateProcessStar(process)
end

function EquipStrongView:ShowRedDot()
	if not self.red_dot then
		self.red_dot = RedDot(self.strongBtn)
		SetLocalPosition(self.red_dot.transform, 130, -13,0)
	end
	if not self.red_dot1 then
		self.red_dot1 = RedDot(self.autoStrongBtn)
		SetLocalPosition(self.red_dot1.transform, 130, -13,0)
	end
	if not self.reddot_strong then
		self.reddot_strong = RedDot(self.StrongToggle)
		SetLocalPosition(self.reddot_strong.transform, 55, 14,0)
	end
	if not self.reddot_cast then
		self.reddot_cast = RedDot(self.CastToggle)
		SetLocalPosition(self.reddot_cast.transform, 55, 14,0)
	end
	if not self.reddot_suite then
		self.reddot_suite = RedDot(self.suitBtn)
		SetLocalPosition(self.reddot_suite.transform, 55, -10,0)
	end
	local show_reddot = self.model:GetNeedShowRedDotByEquip(self.equipDetail)
	SetVisible(self.red_dot, show_reddot)
	SetVisible(self.red_dot1, show_reddot)
	local show_strong = self.model:GetNeedShowRedDot()
	SetVisible(self.reddot_strong, show_strong)
	local show_cast = self.model:GetNeedShowCastRedDot()
	SetVisible(self.reddot_cast, show_cast)
	local show_suite = self.model:IsCanUpStrongSuite()
	SetVisible(self.reddot_suite, show_suite)
end


--显示铸造信息
function EquipStrongView:ShowCastInfo(equipDetail)
	local item_id = equipDetail.id
	if not self.casticongoods then
		self.casticongoods = GoodsIconSettorTwo(self.casticon)
	end
	local param = {}
	param["not_need_compare"] = true
	param["model"] = self.model
	param["p_item"] = equipDetail
	param["item_id"] = item_id
	param["size"] = {x = 70,y=70}
	param["can_click"] = true
	self.casticongoods:SetIcon(param)
	local itemcfg = Config.db_item[item_id]
	local equipcfg = Config.db_equip[item_id]
	local level = equipDetail.equip.cast
	local curAttr = self.model:CalcCastAttr(equipDetail, level)
	if level > 0 then
		local key = string.format("%s@%s", equipcfg.slot, level)
		local castequipcfg = Config.db_equip_cast[key]
		self.casticonname.text = string.format("%s·%s", castequipcfg.name, itemcfg.name)
		self.curcastlevel.text = string.format("Current [<color=#09b005>%s</color>]", castequipcfg.name)
	else
		self.casticonname.text = itemcfg.name
		self.curcastlevel.text = "Current [<color=#09b005>None</color>]" 
	end
	--当前属性
	local count = 1
	for k, v in pairs(curAttr) do
		if count == 1 then
			self.curcastattr1.text = string.format("%s <color=#09b005>+%s</color>", GetAttrNameByIndex(k), v)
		elseif count == 2 then
			self.curcastattr2.text = string.format("%s <color=#09b005>+%s</color>", GetAttrNameByIndex(k), v)
		end
		count = count + 1
	end
	local nextlevel = level+1
	local nextkey = string.format("%s@%s", equipcfg.slot, nextlevel)
	local nextcastcfg = Config.db_equip_cast[nextkey]
	if nextcastcfg then
		SetVisible(self.castright2, false)
		SetVisible(self.castright, true)
		self.nextcastlevel.text = string.format("Next[<color=#09b005>%s</color>]", nextcastcfg.name)
		--下阶属性
		local NextAttr = self.model:CalcCastAttr(equipDetail, nextlevel)
		count = 1
		for k, v in pairs(NextAttr) do
			if count == 1 then
				self.nextcastattr1.text = string.format("%s <color=#09b005>+%s</color>", GetAttrNameByIndex(k), v)
			elseif count == 2 then
				self.nextcastattr2.text = string.format("%s <color=#09b005>+%s</color>", GetAttrNameByIndex(k), v)
			end
			count = count + 1
		end
	else
		SetVisible(self.castright2, true)
		SetVisible(self.castright, false)
	end
	--消耗道具
	for i=1, #self.cast_cost_items do
		self.cast_cost_items[i]:destroy()
	end
	self.cast_cost_items = {}
	local cost = String2Table(nextcastcfg.cost)
	for i=1, #cost do
		local item_id = cost[i][1]
		local num = cost[i][2]
		local param = {}
		param["item_id"] = item_id
		param["can_click"] = true
		param["bind"] = 2
		local had_num = BagController:GetInstance():GetItemListNum(item_id)
		local message = ""
		if had_num >= num then
			message = string.format("%s/%s", ColorUtil.GetHtmlStr(enum.COLOR.COLOR_GREEN, had_num), num)
		else
			message = string.format("%s/%s", ColorUtil.GetHtmlStr(enum.COLOR.COLOR_RED, had_num), num)
		end
		param["num"] = message
		local item = GoodsIconSettorTwo(self.CastCostContent)
		item:SetIcon(param)
		self.cast_cost_items[#self.cast_cost_items+1] = item
	end
	local max_level = self.model:GetCastMaxLevel(item_id)
	if level >= max_level then
		SetVisible(self.castmaxinfo, true)
		SetVisible(self.castbtn, false)
		SetVisible(self.CastScrollView, false)
		if nextcastcfg then
			if nextcastcfg.star > 0 then
				self.castmaxinfo.text = string.format("Max Lv reached, <color=#09b005>%sT%s%sS</color>.Can be forged to<color=#09b005>%s</color>",
					nextcastcfg.order, ColorUtil.GetColorName(nextcastcfg.color), nextcastcfg.star, nextcastcfg.name)
			else
				self.castmaxinfo.text = string.format("Max Lv reached,<color=#09b005>%sT%s</color>.Can be forged to<color=#09b005>%s</color>",
					nextcastcfg.order, ColorUtil.GetColorName(nextcastcfg.color), nextcastcfg.name)
			end
		else
			self.castmaxinfo.text = "Max forge level reached"
		end
	else
		SetVisible(self.castmaxinfo, false)
		SetVisible(self.castbtn, true)
		SetVisible(self.CastScrollView, true)
	end
end


