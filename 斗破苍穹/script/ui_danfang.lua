require"Lang"
UIDanFang = {}

local scrollView = nil
local sv_item = nil
local ui_fightValue = nil
local ui_gold = nil
local ui_money = nil
local ui_image_filter = nil --筛选标签
local btn_all = nil --全部标签
local btn_experience = nil --经验丹标签
local btn_capacity = nil --潜力丹标签
local btn_property = nil --属性丹标签

local experiencePills = nil --经验丹丹方数据
local capacityPills = nil --潜力丹丹方数据
local propertyPills = nil --属性丹丹方数据
local _prevSender = nil

local function netCallbackFunc(data)
	
end

local function setScrollViewItem(item, data)
	local instPillRecipeId = data.int["1"] --丹药丹方实例ID
	local pillRecipeId = data.int["3"] --丹药丹方字典ID
--	local pillRecipeCount = data.int["4"] --丹药丹方数量
	local dictPillRecipeData = DictPillRecipe[tostring(pillRecipeId)] --丹药丹方字典数据
	
	local ui_pillRecipeFrame = item:getChildByName("image_frame_danfang")
	local ui_pillRecipeIcon = ui_pillRecipeFrame:getChildByName("image_danfang")
	local ui_pillRecipeName = ui_pillRecipeFrame:getChildByName("text_dangfang_name")
	local ui_pillRecipeSuperscript = ui_pillRecipeFrame:getChildByName("image_superscript")
	local ui_pillEffect = item:getChildByName("text_danfang_add")
--	local ui_pillRecipeCount = item:getChildByName("text_danfang_number")
	local btn_alchemy = item:getChildByName("btn_alchemy")
	btn_alchemy:setPressedActionEnabled(true)
	
	ui_pillRecipeName:setString(dictPillRecipeData.name)
	ui_pillRecipeIcon:loadTexture("image/" .. DictUI[tostring(dictPillRecipeData.smallUiId)].fileName)
--	ui_pillRecipeCount:setString("数量：" .. pillRecipeCount)
	local dictPillData = DictPill[tostring(dictPillRecipeData.pillId)]
	local dictTableType = DictTableType[tostring(dictPillData.tableTypeId)]
	if dictTableType.id == StaticTableType.DictFightProp then
		local dictFightProp = DictFightProp[tostring(dictPillData.tableFieldId)]
		ui_pillRecipeSuperscript:loadTexture(utils.getPropImage(dictPillData.tableFieldId, "small"))
		ui_pillEffect:setString(Lang.ui_danfang1 .. dictFightProp.name .. "+" .. dictPillData.value)
	elseif dictTableType.id == StaticTableType.DictCardBaseProp then
		local dictCardBaseProp = DictCardBaseProp[tostring(dictPillData.tableFieldId)]
		ui_pillRecipeSuperscript:loadTexture(utils.getPropImage(dictPillData.tableFieldId, "small", true))
		ui_pillEffect:setString(Lang.ui_danfang2 .. dictCardBaseProp.name .. "+" .. dictPillData.value)
	end
	ui_pillRecipeFrame:loadTexture(utils.getPillQualityImg(dictPillData.pillQualityId))
	
	local function btnAlchemyEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			UIManager.showWidget("ui_liandan")
			UILianDan.setInstPillRecipeId(instPillRecipeId)
		end
	end
	btn_alchemy:addTouchEventListener(btnAlchemyEvent)
end

local function compareFunc(obj1, obj2)
	local pillQualityId1 = DictPill[tostring(DictPillRecipe[tostring(obj1.int["3"])].pillId)].pillQualityId
	local pillQualityId2 = DictPill[tostring(DictPillRecipe[tostring(obj2.int["3"])].pillId)].pillQualityId
	if pillQualityId1 < pillQualityId2 then
		return true
	end
	return false
end

local function setBottomState(enabled)
	ui_image_filter:setVisible(enabled)
	btn_all:setVisible(enabled)
	btn_experience:setVisible(enabled)
	btn_capacity:setVisible(enabled)
	btn_property:setVisible(enabled)
	btn_all:setTouchEnabled(enabled)
	btn_experience:setTouchEnabled(enabled)
	btn_capacity:setTouchEnabled(enabled)
	btn_property:setTouchEnabled(enabled)
end

local function setScrollViewData(sender)
	if sv_item:getReferenceCount() == 1 then
		sv_item:retain()
	end
	scrollView:removeAllChildren()
	if sender == btn_all then
		local AllPills = {}
		if experiencePills then 
			for key,obj in pairs(experiencePills) do  
				table.insert(AllPills,obj)
			end
		end
		if capacityPills then 
			for key,obj in pairs(capacityPills) do  
				table.insert(AllPills,obj)
			end
		end
		if propertyPills then 
			for key,obj in pairs(propertyPills) do  
				table.insert(AllPills,obj)
			end
		end
		utils.updateView(UIDanFang,scrollView,sv_item,AllPills,setScrollViewItem)
	elseif sender == btn_experience then
		if experiencePills then 
			utils.updateView(UIDanFang,scrollView,sv_item,experiencePills,setScrollViewItem)
		end
	elseif sender == btn_capacity then
		if capacityPills then 
			utils.updateView(UIDanFang,scrollView,sv_item,capacityPills,setScrollViewItem)
		end
	elseif sender == btn_property then
		if propertyPills then 
			utils.updateView(UIDanFang,scrollView,sv_item,propertyPills,setScrollViewItem)
		end
	end
end

local function showType(sender)
	if _prevSender == sender then
		return
	else
		_prevSender = sender
	end
	btn_all:loadTextureNormal("ui/tk_btn_purple.png")
	btn_experience:loadTextureNormal("ui/tk_btn_purple.png")
	btn_capacity:loadTextureNormal("ui/tk_btn_purple.png")
	btn_property:loadTextureNormal("ui/tk_btn_purple.png")
	if sender == btn_all then
		btn_all:loadTextureNormal("ui/yh_sq_btn01.png")
	elseif sender == btn_experience then
		btn_experience:loadTextureNormal("ui/yh_sq_btn01.png")
	elseif sender == btn_capacity then
		btn_capacity:loadTextureNormal("ui/yh_sq_btn01.png")
	elseif sender == btn_property then
		btn_property:loadTextureNormal("ui/yh_sq_btn01.png")
	end
	setScrollViewData(sender)
end

function UIDanFang.init()
	ui_fightValue = ccui.Helper:seekNodeByName(UIDanFang.Widget, "label_fight")
	ui_gold = ccui.Helper:seekNodeByName(UIDanFang.Widget, "text_gold_number")
	ui_money = ccui.Helper:seekNodeByName(UIDanFang.Widget, "text_silver_number")

	local btn_liandan = ccui.Helper:seekNodeByName(UIDanFang.Widget, "btn_liandan") --炼丹标签
	local btn_danfang = ccui.Helper:seekNodeByName(UIDanFang.Widget, "btn_danfang") --丹方标签
	local btn_danyao = ccui.Helper:seekNodeByName(UIDanFang.Widget, "btn_danyao") --丹药标签
	local btn_yaocai = ccui.Helper:seekNodeByName(UIDanFang.Widget, "btn_yaocai") --药材标签
	local function labelTouchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_liandan then
				UIManager.showWidget("ui_liandan")
			elseif sender == btn_danfang then
--				UIManager.showWidget("ui_danfang")
			elseif sender == btn_danyao then
				UIDanYao.setShowType(UIDanYao.ShowType.ShowDanYao)
				UIManager.showWidget("ui_danyao")
			elseif sender == btn_yaocai then
				UIDanYao.setShowType(UIDanYao.ShowType.ShowYaoCai)
				UIManager.showWidget("ui_danyao")
			end
		end
	end
	btn_liandan:addTouchEventListener(labelTouchEvent)
	btn_danfang:addTouchEventListener(labelTouchEvent)
	btn_danyao:addTouchEventListener(labelTouchEvent)
	btn_yaocai:addTouchEventListener(labelTouchEvent)
	
	scrollView = ccui.Helper:seekNodeByName(UIDanFang.Widget, "view_list_danfang")
	sv_item = scrollView:getChildByName("image_base_danfang"):clone()
	
	local ui_image_base_tab = ccui.Helper:seekNodeByName(UIDanFang.Widget, "image_base_tab")
	ui_image_filter = ui_image_base_tab:getChildByName("image_filter")
	btn_all = ui_image_base_tab:getChildByName("btn_all")
	btn_experience = ui_image_base_tab:getChildByName("btn_experience")
	btn_capacity = ui_image_base_tab:getChildByName("btn_capacity")
	btn_property = ui_image_base_tab:getChildByName("btn_property")
	local function labelBtnEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			showType(sender)
		end
	end
	btn_all:addTouchEventListener(labelBtnEvent)
	btn_experience:addTouchEventListener(labelBtnEvent)
	btn_capacity:addTouchEventListener(labelBtnEvent)
	btn_property:addTouchEventListener(labelBtnEvent)
end

function UIDanFang.setup()
	ui_fightValue:setString(tostring(utils.getFightValue()))
	ui_gold:setString(tostring(net.InstPlayer.int["5"]))
	ui_money:setString(tostring(net.InstPlayer.string["6"]))

	_prevSender = nil
	if net.InstPlayerPillRecipe then
		experiencePills = {}
		capacityPills = {}
		propertyPills = {}
		for key, obj in pairs(net.InstPlayerPillRecipe) do
			local pillRecipeId = obj.int["3"] --丹药丹方字典ID
			local dictPillRecipeData = DictPillRecipe[tostring(pillRecipeId)] --丹药丹方字典数据
			local pillRecipeName = dictPillRecipeData.name
			local dictPillData = DictPill[tostring(dictPillRecipeData.pillId)]
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
	end
	setBottomState(true)
	showType(btn_all)
end
