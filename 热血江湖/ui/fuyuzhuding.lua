
-------------------------------------------------------
module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_fuYuZhuDing = i3k_class("wnd_fuYuZhuDing",ui.wnd_base)

local ZHUDING_ITEM 		 = "ui/widgets/njfwzdt"
local ZHUDING_PROP_ITEM	 = "ui/widgets/njfwzdt1"
local ZHUDING_FSAT_ADD	 = "ui/widgets/njfwzdt2"
local ZHUDING_DESC		 = "ui/widgets/njfwzdt3"

local row_count = 5

function wnd_fuYuZhuDing:ctor()
	self.curLangIndex = 0  --符语id
	self.curJieLevel = 0
	self.curData = nil
	self.curExp = 0
	self.maxExp = 0
	self.isFast = false
	self.showType = 1
	self.armorTag = 1
end

function wnd_fuYuZhuDing:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	self.itemScroll = widgets.contentScroll		--符文
	self.propsScroll = widgets.propsScroll		--铸锭属性
	self.expbarCount = widgets.expbarCount
	self.expbar = widgets.expbar
	self.jieName = widgets.jieName
	widgets.fastAddBtn:onClick(self, self.onFastBtnClick)
	self.fastAddIcon = widgets.fastAddIcon
	self.desc = widgets.desc
	self.textScroll = widgets.scroll
	self.fastDesc = widgets.fastDesc
end

function wnd_fuYuZhuDing:refresh(index, showType, armorTag)
	local zhuDingData = g_i3k_game_context:getFuYuZhudingData()
	self.curData = zhuDingData[index]
	self.curLangIndex = index
	self.curJieLevel = self.curData and self.curData.level or 0
	self.curExp = self.curData and self.curData.exp or 0
	self.showType = showType
	self.armorTag = armorTag

	--self.desc:setText(i3k_get_string(18308))
	self:setDescText(i3k_get_string(18308))
	self.fastDesc:setText(i3k_get_string(18338))
	self:refreshWindowData()
end

function wnd_fuYuZhuDing:setDescText(msgText)
	if msgText then
		g_i3k_ui_mgr:AddTask(self, {}, function(ui)
			local gzText = require(ZHUDING_DESC)()
			gzText.vars.text:setText(msgText)
			self.textScroll:addItem(gzText)
			g_i3k_ui_mgr:AddTask(self, {gzText}, function(ui)
				local textUI = gzText.vars.text
				local size = gzText.rootVar:getContentSize()
				local height = textUI:getInnerSize().height
				local width = size.width
				height = size.height > height and size.height or height
				gzText.rootVar:changeSizeInScroll(self.textScroll, width, height, true)
			end, 1)
		end, 1)
	end
end


function wnd_fuYuZhuDing:refreshWindowData()
	self:updateExpBar()
	self:updateProps()
	self:upDateFuWenList()
	self:updateFastAddState()
end

function wnd_fuYuZhuDing:updateExpBar()
	self.maxExp = i3k_db_rune_zhuDing[self.curLangIndex][self.curJieLevel + 1].upNeedExp
	self.expbarCount:setText(self.curExp.."/"..self.maxExp)
	self.expbar:setPercent(self.curExp / self.maxExp * 100)
	self.jieName:setText(i3k_get_string(1095, self.curJieLevel))
end

--铸锭属性
function wnd_fuYuZhuDing:updateProps()
	self.propsScroll:removeAllChildren()
	local curData = i3k_db_rune_zhuDing[self.curLangIndex]  	--当前符语数据
	--属性名称由下一级数据做基准(满级不会进入界面)
	local attributeNextList = curData[self.curJieLevel + 1].attribute
	for i,v in ipairs(attributeNextList) do
		if v.id == 0 then
			break
		end
		--加载属性名称和图标
		local item = require(ZHUDING_PROP_ITEM)()
		local next_prop = i3k_db_prop_id[v.id]
        item.vars.name:setText(next_prop.desc)
        item.vars.propImage:setImage(g_i3k_db.i3k_db_get_icon_path(g_i3k_db.i3k_db_get_property_icon(v.id)))
        --当前属性值
        local curValue = self.curJieLevel > 0 and curData[self.curJieLevel].attribute[i].value or 0
        item.vars.value:setText(curValue)
        --下一阶属性值
        local nextValue = self.curJieLevel == #curData and nil or v.value 		--判断是否满阶
        item.vars.addValue:setVisible(nextValue and true or false)
        item.vars.addValue:setText(nextValue and nextValue - curValue or 0)
        self.propsScroll:addItem(item)
	end
end

--设置各个符文数量
function wnd_fuYuZhuDing:upDateFuWenList()
	self.itemScroll:removeAllChildren()
	self.itemScroll:stateToNoSlip()
	local _,bagItems = g_i3k_game_context:GetRuneBagInfo()
	local fuWenList = g_i3k_db.i3k_db_get_fuWen_sortList()
	local itemList = self.itemScroll:addItemAndChild(ZHUDING_ITEM, row_count, #fuWenList)
	for i,v in ipairs(fuWenList) do
		local id = fuWenList[i].runeId
		local count =  bagItems[id] and bagItems[id] or 0
		itemList[i].id = id
		itemList[i].count = count
		self:setCellData(itemList[i].vars, id, count, fuWenList[i].zhuDingExp)
	end
end

--设置每个符文信息
function wnd_fuYuZhuDing:setCellData(widget, id, count, exp)
	widget.grade_icon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(id))
	widget.item_icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(id,i3k_game_context:IsFemaleRole()))
	local num = count and count or 0
	widget.count:setText("x"..num)
	widget.exp:setText("+"..exp)
	if count > 0 then
		widget.bt:onClick(self, self.onAddClick ,id)
	else
		widget.bt:onClick(self, self.onRuneTips ,id)
	end
end

--点击背包Item
function wnd_fuYuZhuDing:onRuneTips(sender, itemId)
	g_i3k_ui_mgr:OpenUI(eUIID_RuneBagItemInfo)
	g_i3k_ui_mgr:RefreshUI(eUIID_RuneBagItemInfo, nil, nil,  itemId, 3)
end

function wnd_fuYuZhuDing:onAddClick(sender, itemId)
	if self.isFast then
		local _,bagItems = g_i3k_game_context:GetRuneBagInfo()
		local count = self:getLogicCurCount(itemId, bagItems[itemId])
		local data = {runeId = itemId, fuyuId = self.curLangIndex, curCount = count, maxCount = bagItems[itemId]}
		g_i3k_ui_mgr:OpenUI(eUIID_FuYuFastAdd)
		g_i3k_ui_mgr:RefreshUI(eUIID_FuYuFastAdd, data)
	else 
		self:FuncByItemPinZhi(itemId, 1)
	end
end

function wnd_fuYuZhuDing:FuncByItemPinZhi(itemId, num)
	local pin = i3k_db_under_wear_rune[itemId].zhuDingPin
	if pin == 1 then
		self:sendZhuDing(itemId, num)
	elseif pin == 2 then
		self:showNormalbox(itemId, num)
	elseif pin == 3 then
		self:showInputBox(itemId, num)
	end
end


function wnd_fuYuZhuDing:getLogicCurCount(itemId, haveCount)
	local offsetExp = self.maxExp - self.curExp
	local addExp = i3k_db_under_wear_rune[itemId].zhuDingExp
	local maxCount = math.ceil(offsetExp / addExp)
	return haveCount < maxCount and haveCount or maxCount
end

--普通提示框
function wnd_fuYuZhuDing:showNormalbox(itemId, num)
	local fun = (function(ok)
        if ok then
           self:sendZhuDing(itemId, num)
        end
    end)
    local msg = i3k_get_string(18305)
    g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", msg, fun)
end

--输入提示框
function wnd_fuYuZhuDing:showInputBox(itemId,num)
	local fun = (function(ok)
        if ok then
           self:sendZhuDing(itemId, num)
        end
    end)
    local msg = i3k_get_string(18306)
    local inputNum = i3k_db_under_wear_alone.zhuDingInputNum
    g_i3k_ui_mgr:ShowInputMedssageBox("确定", "取消", msg, inputNum, fun)
end

--发送加经验请求
function wnd_fuYuZhuDing:sendZhuDing(itemId, num)
	local addExp = i3k_db_under_wear_rune[itemId].zhuDingExp * num 				 --需要加的经验
	local curlevel, expOffset = g_i3k_db.i3k_db_FuYuZhuDing_CheckCanUpLevel(self.curLangIndex, self.curExp, addExp, self.curJieLevel) 		 --拿到加成结果

	--当满级且溢出经验大于配置数值，弹出溢出提示框
	if curlevel == 5 and expOffset > i3k_db_under_wear_alone.zhuDingMaxLvShowExp then
		local fun = (function(ok)
	        if ok then
	          	i3k_sbean.useRuneAddExpReq(self.curLangIndex, itemId, num)
	        end
	    end)
	    local msg = i3k_get_string(18304)
	    g_i3k_ui_mgr:ShowCustomMessageBox2("确定", "取消", msg, fun)
	    return
	end
	i3k_sbean.useRuneAddExpReq(self.curLangIndex, itemId, num)
end


--请求成功
function wnd_fuYuZhuDing:onAddSuccess(data)
	--减掉符文数量
	local count = g_i3k_game_context:GetRuneItemCount(data.runeId) - data.num
	g_i3k_game_context:SetRuneItemCount(data.runeId, count)
	local addZDExp = i3k_db_under_wear_rune[data.runeId].zhuDingExp * data.num
	local curlevel, expOffset = g_i3k_db.i3k_db_FuYuZhuDing_CheckCanUpLevel(self.curLangIndex, self.curExp, addZDExp, self.curJieLevel) 		 --拿到加成结果
	self.curExp = expOffset
	g_i3k_game_context:setFuYuZhudingData(self.curLangIndex, self.curExp, curlevel)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune_Lang, "setRuneData", self.curLangIndex)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune, "updateLangLabel",self.curLangIndex)
	--g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune_Lang, "showBtntag",self.curLangIndex)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune_Lang, "setRuneLangData", self.curLangIndex)
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_Under_Wear_Rune_Lang, "setBtnState", self.curLangIndex)
	if curlevel > self.curJieLevel then --触发升级
		self.curJielevel = curlevel
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18300))		    --升阶成功
		g_i3k_ui_mgr:CloseUI(eUIID_FuYuZhuDing)
	else
		self:refreshWindowData()
	end
end


function wnd_fuYuZhuDing:onFastBtnClick(sender)
	self.isFast = not self.fastAddIcon:isVisible()
	self.fastAddIcon:setVisible(self.isFast)
	self:updateFastAddState()
end

function wnd_fuYuZhuDing:updateFastAddState()
	local list = self.itemScroll:getAllChildren()
	for i,item in ipairs(list) do
		if self.isFast then
			if not g_i3k_db.i3k_db_check_rune_canFastAdd(item.id) or item.count == 0 then
				item.vars.item_icon:disable()
				item.vars.grade_icon:disable()
				item.vars.bt:disable()
			end
		else
			if item.count == 0 then
				item.vars.item_icon:disable()
				item.vars.grade_icon:disable()
			else
				item.vars.item_icon:enable()
				item.vars.grade_icon:enable()
			end
			item.vars.bt:enable()
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_fuYuZhuDing.new()
	wnd:create(layout, ...)
	return wnd;
end
