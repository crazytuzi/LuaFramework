require"Lang"
UIDanYao = {}

UIDanYao.ShowType = {
	ShowDanYao = 1, --显示丹药
	ShowYaoCai = 2, --显示药材
}

local scrollView = nil
local sv_item = nil
local ui_fightValue = nil
local ui_gold = nil
local ui_money = nil
local btn_danyao = nil --丹药标签
local btn_yaocai = nil --药材标签

local _showType = nil
local _prevShowType = nil
local _pillCountPoint = cc.p(0, 0) --丹药数量原始坐标

local function setScrollViewItem(item, data)
	local ui_pillFrame = item:getChildByName("image_frame_danyao")
	local ui_pillIcon = ui_pillFrame:getChildByName("image_danyao")
	local ui_pillSuperscript = ui_pillFrame:getChildByName("image_superscript")
	local ui_pillName = item:getChildByName("text_name_danyao")
	local ui_pillEffect = item:getChildByName("text_danyao_add")
	local ui_pillCount = item:getChildByName("text_danyao_number")
	local btn_sell = item:getChildByName("btn_sell")
	btn_sell:setPressedActionEnabled(true)
	local function btnSellEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			UISellProp.setData(data, UIDanYao)
			UIManager.pushScene("ui_sell_prop")
		end
	end
	btn_sell:addTouchEventListener(btnSellEvent)

	if _showType == UIDanYao.ShowType.ShowDanYao then
		local instPillId = data.int["1"] --丹药实例ID
		local pillId = data.int["3"] --丹药字典ID
		local pillCount = data.int["4"] --丹药数量
		local dictPillData = DictPill[tostring(pillId)]
		ui_pillCount:setPosition(_pillCountPoint)
		ui_pillName:setString(dictPillData.name)
		ui_pillIcon:loadTexture("image/" .. DictUI[tostring(dictPillData.smallUiId)].fileName)
		ui_pillCount:setString(Lang.ui_danyao1 .. pillCount)
		ui_pillFrame:loadTexture(utils.getPillQualityImg(dictPillData.pillQualityId))
		local dictTableType = DictTableType[tostring(dictPillData.tableTypeId)]
		if dictTableType.id == StaticTableType.DictFightProp then
			local dictFightProp = DictFightProp[tostring(dictPillData.tableFieldId)]
			ui_pillSuperscript:loadTexture(utils.getPropImage(dictPillData.tableFieldId, "small"))
			ui_pillEffect:setString(Lang.ui_danyao2 .. dictFightProp.name .. "+" .. dictPillData.value)
		elseif dictTableType.id == StaticTableType.DictCardBaseProp then
			local dictCardBaseProp = DictCardBaseProp[tostring(dictPillData.tableFieldId)]
			ui_pillSuperscript:loadTexture(utils.getPropImage(dictPillData.tableFieldId, "small", true))
			ui_pillEffect:setString(Lang.ui_danyao3 .. dictCardBaseProp.name .. "+" .. dictPillData.value)
		end
		ui_pillSuperscript:setVisible(true)
	elseif _showType == UIDanYao.ShowType.ShowYaoCai then
		local pillThingId = data.int["3"] --丹药材料字典ID
		local pillThingCount = data.int["4"] --丹药材料数量
		local dictPillThingData = DictPillThing[tostring(pillThingId)]
		ui_pillCount:setPositionX(_pillCountPoint.x + 50)
		ui_pillName:setString(dictPillThingData.name)
		ui_pillIcon:loadTexture("image/" .. DictUI[tostring(dictPillThingData.smallUiId)].fileName)
		ui_pillCount:setString(Lang.ui_danyao4 .. pillThingCount)
		ui_pillEffect:setString(dictPillThingData.description)
		ui_pillSuperscript:setVisible(false)
	end
end

local function compareFunc(obj1, obj2)
	local pillQualityId1 = DictPill[tostring(obj1.int["3"])].pillQualityId
	local pillQualityId2 = DictPill[tostring(obj2.int["3"])].pillQualityId
	if pillQualityId1 < pillQualityId2 then
		return true
	end
	return false
end

local function initScrollViewData()
	if sv_item:getReferenceCount() == 1 then
		sv_item:retain()
	end
	scrollView:removeAllChildren()
	if _showType == UIDanYao.ShowType.ShowDanYao then
		if net.InstPlayerPill then
			local experiencePills = {}
			local capacityPills = {}
			local propertyPills = {}
			local AllPills = {}
			for key, obj in pairs(net.InstPlayerPill) do
				local dictPillData = DictPill[tostring(obj.int["3"])]
				local pillType = dictPillData.pillTypeId
				if pillType == StaticPillType.fightProp then --属性丹
					propertyPills[#propertyPills + 1] = obj
				elseif pillType == StaticPillType.exp then --经验丹
					experiencePills[#experiencePills + 1] = obj
				elseif pillType == StaticPillType.potential then --潜力丹
					capacityPills[#capacityPills + 1] = obj
				end
			end
			utils.quickSort(experiencePills, compareFunc)
			utils.quickSort(capacityPills, compareFunc)
			utils.quickSort(propertyPills, compareFunc)
			for key,obj in pairs(experiencePills) do  
				table.insert(AllPills,obj)
			end
			for key,obj in pairs(capacityPills) do  
				table.insert(AllPills,obj)
			end
			for key,obj in pairs(propertyPills) do  
				table.insert(AllPills,obj)
			end
			utils.updateView(UIDanYao,scrollView,sv_item,AllPills,setScrollViewItem)
		end
	elseif _showType == UIDanYao.ShowType.ShowYaoCai then
		if net.InstPlayerPillThing then
			local AllPillThings= {}
			for key, obj in pairs(net.InstPlayerPillThing) do
				table.insert(AllPillThings,obj)
			end
			utils.updateView(UIDanYao,scrollView,sv_item,AllPillThings,setScrollViewItem)
		end
	end
end

local function setTitleLabel(_type)
	if _prevShowType ~= _type then
		_showType = _type
		_prevShowType = _type
		if _showType == UIDanYao.ShowType.ShowDanYao then
			btn_yaocai:loadTextures("ui/yh_btn01.png", "ui/yh_btn01.png")
			btn_yaocai:getChildByName("text_yaocai"):setTextColor(cc.c4b(255, 255, 255, 255))
			btn_danyao:loadTextures("ui/yh_btn02.png", "ui/yh_btn01.png")
			btn_danyao:getChildByName("text_danyao"):setTextColor(cc.c4b(51, 25, 4, 255))
			initScrollViewData()
		elseif _showType == UIDanYao.ShowType.ShowYaoCai then
			btn_danyao:loadTextures("ui/yh_btn01.png", "ui/yh_btn01.png")
			btn_danyao:getChildByName("text_danyao"):setTextColor(cc.c4b(255, 255, 255, 255))
			btn_yaocai:loadTextures("ui/yh_btn02.png", "ui/yh_btn01.png")
			btn_yaocai:getChildByName("text_yaocai"):setTextColor(cc.c4b(51, 25, 4, 255))
			initScrollViewData()
		end
	end
end

function UIDanYao.init()
	ui_fightValue = ccui.Helper:seekNodeByName(UIDanYao.Widget, "label_fight")
	ui_gold = ccui.Helper:seekNodeByName(UIDanYao.Widget, "text_gold_number")
	ui_money = ccui.Helper:seekNodeByName(UIDanYao.Widget, "text_silver_number")
	
	local btn_liandan = ccui.Helper:seekNodeByName(UIDanYao.Widget, "btn_liandan") --炼丹标签
	local btn_danfang = ccui.Helper:seekNodeByName(UIDanYao.Widget, "btn_danfang") --丹方标签
	btn_danyao = ccui.Helper:seekNodeByName(UIDanYao.Widget, "btn_danyao") --丹药标签
	btn_yaocai = ccui.Helper:seekNodeByName(UIDanYao.Widget, "btn_yaocai") --药材标签
	local function labelTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_liandan then
				UIManager.showWidget("ui_liandan")
			elseif sender == btn_danfang then
				UIManager.showWidget("ui_danfang")
			elseif sender == btn_danyao then
--				UIDanYao.setShowType(UIDanYao.ShowType.ShowDanYao)
--				UIManager.showWidget("ui_danyao")
				setTitleLabel(UIDanYao.ShowType.ShowDanYao)
			elseif sender == btn_yaocai then
--				UIDanYao.setShowType(UIDanYao.ShowType.ShowYaoCai)
--				UIManager.showWidget("ui_danyao")
				setTitleLabel(UIDanYao.ShowType.ShowYaoCai)
			end
		end
	end
	btn_liandan:addTouchEventListener(labelTouchEvent)
	btn_danfang:addTouchEventListener(labelTouchEvent)
	btn_danyao:addTouchEventListener(labelTouchEvent)
	btn_yaocai:addTouchEventListener(labelTouchEvent)
	
	scrollView = ccui.Helper:seekNodeByName(UIDanYao.Widget, "view_list_danyao")
	sv_item = scrollView:getChildByName("image_base_danyao"):clone()
	local pillCount = sv_item:getChildByName("text_danyao_number")
	_pillCountPoint = cc.p(pillCount:getPositionX(), pillCount:getPositionY())
end

function UIDanYao.setup()
	ui_fightValue:setString(tostring(utils.getFightValue()))
	ui_gold:setString(tostring(net.InstPlayer.int["5"]))
	ui_money:setString(tostring(net.InstPlayer.string["6"]))
	_prevShowType = nil
	setTitleLabel(_showType)
end

function UIDanYao.setShowType(showType)
	_showType = showType
end

function UIDanYao.getShowType()
	return _showType
end
