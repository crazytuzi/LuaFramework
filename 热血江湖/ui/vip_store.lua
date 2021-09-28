-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local item_info = "ui/widgets/ybsct"

-------------------------------------------------------
wnd_vip_store = i3k_class("wnd_vip_store", ui.wnd_base)
-------------------------------------------
local e_Type_vip_store_yuanbao = 1
local e_Type_vip_store_bangyuan = 2
local e_Type_vip_store_hongli = 3
local e_Type_vip_store_longhun = 4
-------------------------------------------
local e_Type_store_itemlist_rexiao = 1
local e_Type_store_itemlist_qianghua = 2
local e_Type_store_itemlist_xingxiang = 3
local e_Type_store_itemlist_qita = 4
local e_Type_store_itemlist_xiangou = 5
local e_Type_store_itemlist_homeland = 6
-------------------------------------------
local e_Style_store_item_putong = 1
local e_Style_store_item_dazhe = 2
-------------------------------------------
local e_Refresh_week = 1
local e_Refresh_day = 0
-------------------------------------------
local e_AType_BestSeller = 1
local e_AType_Strengthen = 2
local e_AType_Figure = 4
-------------------------------------------
local vipicon = {874,875,876,877,878,879,880,881,882,883,884,885,886,887,888}
local discounticon = {499,500,501,502,503,504,505,506,507}
local titleicon = {496,495,3851, 8742}
local limiticon = {825,824}
local currency_icon = {32, 3850, 5005}  --货币图标

local GENDER = g_i3k_game_context:GetRoleGender()
local NOW_INDEX = 0

local selectTabel = {[0] = "全部", [1] = "其他", [2] = "坐骑", [3] = "宠物", [4] = "", [5] = ""}
local vip_image = "sc#g%s.png"
------------------
local DRESS_TYPE = 1 --幻形类型
-----------------
function wnd_vip_store:ctor()
	self._sid = e_Type_vip_store_bangyuan;
	self._tid = e_Type_store_itemlist_rexiao;
	self.filterItem = {};
	self._mallInfo = nil;
	self._logInfo = nil;
	self._extraGifts = {}
	self.clickbuytimes = nil;
	self.selectedItemId = nil;--需要购买商品的ID
end

function wnd_vip_store:refresh(info, curPoint, showType, itemId)
	if g_i3k_game_context:GetRoleGender() == 1 then
		selectTabel[4] = "时装女"
		selectTabel[5] = "时装男"
	else
		selectTabel[4] = "时装男"
		selectTabel[5] = "时装女"
	end
	if curPoint then
		self._tid = curPoint
	end
	if showType then
		self._sid = showType
	end
	self.info = info
	self._logInfo = self.info.log
	self._mallInfo = self.info.mall
	self._extraGifts = self.info.extraGifts
	self._lastday = g_i3k_get_day(i3k_game_get_time())
	self._lastweek = g_i3k_get_week(self._lastday)
	self.itemlist = { {}, {}, {}, {}}
	self.itemlist[1] = self._mallInfo.fGoods
	self.itemlist[2] = self._mallInfo.rGoods
	self.itemlist[3] = self._mallInfo.hlGoods  --红利商品
	self.itemlist[4] = self._mallInfo.lhGoods  --龙魂商品
	self.selectedItemId = itemId

	self:setStoreSel();
	self:updateMoney(g_i3k_game_context:GetDiamond(true), g_i3k_game_context:GetDiamond(false), g_i3k_game_context:GetMoney(true), g_i3k_game_context:GetMoney(false))
end

function wnd_vip_store:configure()

	local yuanbao_btn = self._layout.vars.yuanbao_btn
	local bangyuan_btn = self._layout.vars.bangyuan_btn
	local hongli_btn = self._layout.vars.hongli_btn
	local rexiao_btn = self._layout.vars.rexiao_btn
	local qianghua_btn = self._layout.vars.qianghua_btn
	local xingxiang_btn = self._layout.vars.xingxiang_btn
	local qita_btn = self._layout.vars.qita_btn
	local xiangou_btn = self._layout.vars.xiangou_btn---限购
	local furniture_btn = self._layout.vars.furniture_btn
	local longhun_btn = self._layout.vars.longhun_btn --龙魂
	self.title_icon  = self._layout.vars.title_icon
	self.selectTagbtn = {rexiao_btn,qianghua_btn,xingxiang_btn,qita_btn,xiangou_btn, furniture_btn}
	self.selectStorebtn = {yuanbao_btn,bangyuan_btn,hongli_btn, longhun_btn}

	for k,v in pairs(self.selectStorebtn) do
		v:onTouchEvent(self,self.onSelectStore)
		v:setTag(k)
	end

	for k,v in pairs(self.selectTagbtn) do
		v:onTouchEvent(self,self.onSelectTag)
		v:setTag(k)
	end

	self._layout.vars.close_btn:onClick(self,self.onCloseUI)

	local widgets = self._layout.vars
	self.diamond = widgets.diamond
	self.diamondLock = widgets.diamondLock
	self.coin = widgets.coin
	self.coinLock = widgets.coinLock
	self.longhunCount = widgets.longhunCount

	widgets.add_diamond:onClick(self, self.addDiamondBtn)
	widgets.add_coin:onClick(self, self.addCoinBtn)
	widgets.add_longhun:onClick(self, self.addLonghunBtn)
	if g_i3k_game_context:GetIsGlodCoast() then
		widgets.add_diamond_img:disable()
		widgets.add_coin_img:disable()
		widgets.add_longhun_img:disable()
	end

	self._layout.vars.selectBtn:onClick(self, self.showSelectBtn)
end

function wnd_vip_store:updateMoney(diamondF, diamondR, coinF, coinR)
	self.diamond:setText(diamondF)
	self.diamondLock:setText(diamondR)
	self.coin:setText(i3k_get_num_to_show(coinF))
	self.coinLock:setText(i3k_get_num_to_show(coinR))
end

function wnd_vip_store:addDiamondBtn(sender)
	if g_i3k_game_context:GetIsGlodCoast() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
	end
	g_i3k_logic:OpenChannelPayUI()
end

function wnd_vip_store:addCoinBtn(sender)
	if g_i3k_game_context:GetIsGlodCoast() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
	end
	g_i3k_ui_mgr:OpenUI(eUIID_BuyCoin)
end

function wnd_vip_store:addLonghunBtn(sender)
	if g_i3k_game_context:GetIsGlodCoast() then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(5582))
	end
	g_i3k_logic:OpenChannelPayUI(nil, g_CHANNEL_LONGHUNBI_TYPE)
end

function wnd_vip_store:onShow()
	self:updateHongLi(g_i3k_game_context:GetDividendCount())
	self:updateLongHun(g_i3k_game_context:GetDragonCoinCount())
end

function wnd_vip_store:onHide()

end

function wnd_vip_store:updateHongLi(value)
	self._layout.vars.coinLock2:setText(i3k_get_num_to_show(value))
end

--更新龙魂币
function wnd_vip_store:updateLongHun(value)
	self.longhunCount:setText(value)
end

function wnd_vip_store:setStoreSel(ntag)
	for k,v in pairs(self.selectStorebtn) do
		v:stateToNormal()
	end
	self.selectStorebtn[self._sid]:stateToPressed()
	if ntag then
		self._tid = ntag
	end
	self.title_icon:setImage(i3k_db.i3k_db_get_icon_path(titleicon[self._sid]))
	self:setStoreList()
end
--商城选项卡
function wnd_vip_store:onSelectStore(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self._sid ~= sender:getTag() then
			self._sid = sender:getTag()
			i3k_log(self._sid)
			self:setStoreSel(e_Type_store_itemlist_rexiao)
		end
	end
end
--商品类型
function wnd_vip_store:onSelectTag(sender,eventType)
	if eventType == ccui.TouchEventType.ended then
		if self._tid ~= sender:getTag() then
			self._tid = sender:getTag()
			self:setStoreList()
		end
	end
end

function wnd_vip_store:setStoreList()
	for k,v in pairs(self.selectTagbtn) do
		v:stateToNormal(true)
	end
	self.selectTagbtn[self._tid]:stateToPressed(true)
	self:setStoreListInfo()
end

function wnd_vip_store:setStoreListInfo(showIndex)
	local item_scroll = self._layout.vars.item_scroll
	local count = 0
	self.filterItem = {}
	local k = self._sid
	local tab = self.itemlist[self._sid]
	for k,v in pairs(self.itemlist[self._sid]) do
		if self:sellItemFilter(v) then
			table.insert(self.filterItem,v)
			count = count + 1;
		end
	end
	self._layout.vars.fashionRoot:hide()
	self._layout.vars.selectRoot:hide()
	if self._tid == e_Type_store_itemlist_xingxiang then
		self._layout.vars.fashionRoot:show()
		self._layout.vars.selectLab:setText(selectTabel[showIndex or 0])
		self.filterItem = self:sortItemByFashion(self.filterItem, showIndex or 0)
		count = #self.filterItem
	end
	local curtime = i3k_game_get_time()
	item_scroll:removeAllChildren()
	local allBars = item_scroll:addChildWithCount(item_info, 4, count)
	for index, bar in ipairs(allBars) do
		local item = self.filterItem[index]
		self:calculateTime(index)
		if item.discount and item.discount.time then
			if item.discount.time.endTime then
				if curtime >= item.discount.time.startTime and curtime <= item.discount.time.endTime then
					self:setItemDetail(e_Style_store_item_dazhe,bar,item,index)
				else
					self:setItemDetail(e_Style_store_item_putong,bar,item,index)
				end
			else
				self:setItemDetail(e_Style_store_item_dazhe,bar,item,index)
			end
		else
			self:setItemDetail(e_Style_store_item_putong,bar,item,index)
		end
	end
end

function wnd_vip_store:sortItemByFashion(item, showIndex)
	NOW_INDEX = showIndex
	local sortItem = {[0] = {}, [1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}}
	for k,v in ipairs(item) do
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(v.iid)
		local sortId = 0
		if cfg then
			if cfg.type == UseItemFashion then  --时装道具
				local fashionCfg = g_i3k_db.i3k_db_get_fashion_cfg(cfg.args1)
				if fashionCfg then
					if fashionCfg.sex == g_i3k_game_context:GetRoleGender() then
						if showIndex == 0 or showIndex == 5 then
							table.insert(sortItem[showIndex], v)
							v.sortId = 1000
						end
					else
						if showIndex == 0 or showIndex == 4 then
							table.insert(sortItem[showIndex], v)
							v.sortId = 0
						end
					end
				end
			elseif cfg.type == UseItemPet then  --宠物道具
				if showIndex == 0 or showIndex == 3 then
					table.insert(sortItem[showIndex], v)
					v.sortId = 2000
				end
			elseif cfg.type == UseItemHorse then  --坐骑道具
				if showIndex == 0 or showIndex == 2 then
					table.insert(sortItem[showIndex], v)
					v.sortId = 3000
				end
			else  --其他
				if showIndex == 0 or showIndex == 1 then
					table.insert(sortItem[showIndex], v)
					v.sortId = 4000
				end
			end
		end
	end
	table.sort(sortItem[showIndex],function (a,b)
		return a.sortId > b.sortId
	end)
	return sortItem[showIndex]
end

function wnd_vip_store:showSelectBtn(sender)
	local tab = i3k_clone(selectTabel)
	tab[NOW_INDEX] = nil
	self._layout.vars.selectRoot:show()
	local index = 1
	for i = 5, 0, -1 do
		if tab[i] then
			self._layout.vars["btn"..index]:onClick(self, self.toSelect, i)
			self._layout.vars["lable"..index]:setText(tab[i])
			index = index + 1
		end
	end
end

function wnd_vip_store:toSelect(sender, showIndex)
	self._layout.vars.selectRoot:hide()
	self:setStoreListInfo(showIndex)

end

function wnd_vip_store:isDazheItem(item)
	local curtime = i3k_game_get_time()
	if item.discount and item.discount.time then
		if item.discount.time.endTime then
			if curtime >= item.discount.time.startTime and curtime <= item.discount.time.endTime then
				return true
			else
				return false
			end
		else
			return true
		end
	else
		return false
	end
end

function wnd_vip_store:calculateTime(index)
	local item = self.filterItem[index]
	local curtime = i3k_game_get_time()
	local stime = self:calRestrictionTime(item,curtime)
	item.stime = stime;
end

function wnd_vip_store:calMallinfoTime(curtime)
	if curtime >= self._mallInfo.time.startTime and curtime <= self._mallInfo.time.endTime then
		stime  = math.ceil((self._mallInfo.time.endTime - curtime)/86400)
		if stime > 3 then
			return -1
		else
			return stime
		end
	end
	return -1
end

function wnd_vip_store:calItemTime(item,curtime)
	local stime = -1
	if item.time then
		if item.time.endTime then
			if curtime >= item.time.startTime and curtime <= item.time.endTime then
				stime  = math.ceil((item.time.endTime - curtime)/86400)
				if stime > 3 then
					return -1
				else
					return stime
				end
			end
		else
			stime = self:calMallinfoTime(curtime)
			return stime
		end
	else
		stime = self:calMallinfoTime(curtime)
		return stime
	end
	return -1;
end

function wnd_vip_store:calDiscountTime(item,curtime)
	local stime = -1
	if item.discount and item.discount.time then
		if item.discount.time.endTime then
			if curtime >= item.discount.time.startTime and curtime <= item.discount.time.endTime then
				stime  = math.ceil((item.discount.time.endTime - curtime)/86400)
				return stime
			else
				stime = self:calItemTime(item,curtime)
				return stime
			end
		else
			stime = self:calItemTime(item,curtime)
			return stime
		end
	else
		stime = self:calItemTime(item,curtime)
		return stime
	end
	return -1;
end

function wnd_vip_store:calRestrictionTime(item,curtime)
	local stime = -1
	if item.restriction and item.restriction.time then
		if item.restriction.time.endTime then
			if curtime >= item.restriction.time.startTime and curtime <= item.restriction.time.endTime then
				stime  = math.ceil((item.restriction.time.endTime - curtime)/86400)
				if stime > 7 and item.restriction.weekPeriod == e_Refresh_day then--日限
					return -1
				end
				return stime
			else
				stime = self:calDiscountTime(item,curtime)
				return stime
			end
		else
			stime = self:calDiscountTime(item,curtime)
			return stime
		end
	else
		stime = self:calDiscountTime(item,curtime)
		return stime
	end
	return -1;
end
--设置每个商品框详情
function wnd_vip_store:setItemDetail(style,bar,item,index)
	local xiangou_panel = bar.vars.xiangou_panel
	local xiangou_item_btn = bar.vars.xiangou_item_btn
	local xiangou_item_name = bar.vars.xiangou_item_name
	local xiangou_item_bg = bar.vars.xiangou_item_bg
	local xiangou_item_icon = bar.vars.xiangou_item_icon
	local xiangou_item_count = bar.vars.xiangou_item_count
	local xiangou_item_kuang = bar.vars.xiangou_item_kuang
	local xiangou_item_text = bar.vars.xiangou_item_text
	local vip_icon = bar.vars.vip_icon
	local limited_text = bar.vars.limited_text
	local limited_bg = bar.vars.limited_bg
	local item_soldout = bar.vars.item_soldout
	local xiangou_icon = bar.vars.xiangou_icon
	local v16_icon = bar.vars.v16_icon

	item_soldout:hide()
	limited_text:hide()
	limited_bg:hide()
	xiangou_item_count:hide()
	xiangou_item_kuang:hide()
	xiangou_item_text:hide()
	vip_icon:hide()
	xiangou_icon:hide()
	xiangou_panel:show()
	v16_icon:hide()

	if item.vipReq then
		if item.vipReq > 0 then
			vip_icon:show()
			vip_icon:setImage(string.format(vip_image,item.vipReq))
		end
	end
	local limited_text_text = ""
	--判断时间限制
	if item.stime ~= -1 then
		limited_text:show()
		limited_bg:show()
		if item.stime <= 7 then
			limited_text_text = i3k_get_string(218,item.stime)
		else
			local week = math.floor(item.stime/7)
			limited_text_text = i3k_get_string(219,week)
		end
		-- limited_text:setTextColor(g_i3k_get_blue_color())
	end
	--判断等级限制
	--[[if item.levelReq then
		local hero = i3k_game_get_player_hero()
		if hero._lvl < item.levelReq then
			limited_text:show()
			limited_bg:show()
			limited_text_text = "需要:"..item.levelReq.."级"
			limited_text:setTextColor(g_i3k_get_red_color())
		end
	end]]
	limited_text:setText(limited_text_text)
	xiangou_item_bg:setImage(i3k_db.i3k_db_get_common_item_rank_frame_icon_path(item.iid))
	xiangou_item_icon:setImage(i3k_db.i3k_db_get_common_item_icon_path(item.iid,i3k_game_context:IsFemaleRole()))
	if item.icount > 1 then
		xiangou_item_name:setText(i3k_db.i3k_db_get_common_item_name(item.iid).."*"..item.icount)
	else
		xiangou_item_name:setText(i3k_db.i3k_db_get_common_item_name(item.iid))
	end
	xiangou_item_name:setTextColor(g_i3k_get_color_by_rank(g_i3k_db.i3k_db_get_common_item_rank(item.iid)))
	--xiangou_item_btn:setTag(index)
	xiangou_item_btn:onClick(self, self.onBuyBtnClick, index)

	if self._tid == e_Type_store_itemlist_xiangou then
		xiangou_item_count:show()
		xiangou_item_kuang:show()
		xiangou_item_text:show()
		local times = item.restriction.times
		times = self:checkRestrictionTimes(item)
		if item.restriction.weekPeriod == e_Refresh_week then--周限
			xiangou_icon:show()
			xiangou_icon:setImage(i3k_db.i3k_db_get_icon_path(limiticon[1]))--日限周限
		elseif item.restriction.weekPeriod == e_Refresh_day then--日限
			xiangou_icon:show()
			xiangou_icon:setImage(i3k_db.i3k_db_get_icon_path(limiticon[2]))
		end

		local _, isShow = self:buyRestrictionTimes(item)
		if isShow then
			v16_icon:show()
		end

		xiangou_item_count:setText(times)--限购数量
		if times <= 0 then
			item_soldout:show();
			xiangou_item_count:setText(0)
		end
	end

	self:setStyleShow(bar,style,item)

	self:openSelectItemDetail(index)
 	self:showSelectedImage(bar,item,index)
end

--显示被选中商品的底板
function wnd_vip_store:showSelectedImage(bar, item, index)
	if self.selectedItemId and math.abs(self.selectedItemId) == math.abs(item.iid) then
		self:setScrollPercent(index)
		if self._tid == e_Type_store_itemlist_xiangou then--限购
			local times = item.restriction.times
			times = self:checkRestrictionTimes(item)
			if times > 0 then
				--item_scroll:jumpToChildWithIndex(index)
				bar.vars.xiangou_panel:setImage(g_i3k_db.i3k_db_get_icon_path(3595))
			end
		else
			--item_scroll:jumpToChildWithIndex(index)
			bar.vars.xiangou_panel:setImage(g_i3k_db.i3k_db_get_icon_path(3595))
		end
		self.selectedItemId = nil
	end
end

--恢复底板
function wnd_vip_store:hideSelectedImage(index)
	local item_scroll = self._layout.vars.item_scroll
	local allBars = item_scroll:getAllChildren()
	for i, bar in ipairs(allBars) do
		if i == index then
			bar.vars.xiangou_panel:setImage(g_i3k_db.i3k_db_get_icon_path(3594))
			break
		end
	end
end

--跳转到指定商品
function wnd_vip_store:setScrollPercent(index)
	if index > 8 then--当大于两行的时候再去跳转，一行四个
		local item_scroll = self._layout.vars.item_scroll
		local totalCount = item_scroll:getChildrenCount()
		local percent = index/totalCount*100
		item_scroll:jumpToListPercent(percent)
	end
end

--若为购买时装道具，宠物道具，坐骑道具，则直接打开相对应预览界面
function wnd_vip_store:openSelectItemDetail(index)
	local item = self.filterItem[index]
	
	if self.selectedItemId and math.abs(self.selectedItemId) == math.abs(item.iid) then
		local itemType = g_i3k_db.i3k_db_get_other_item_cfg(item.iid).type
		
		if itemType ~= UseItemFashion and itemType ~= UseItemPet and itemType ~= UseItemHorse and itemType ~= UseItemFurniture and itemType ~= UseItemMetamorphosis then
			return
		end

		local buy = {}
		buy.effectiveTime = self.info.effectiveTime
		buy.id = self._mallInfo.time.startTime;
		buy.gid = item.id;
		buy.count = 1;
		buy.price = item.changePrice
		if self._sid == e_Type_vip_store_yuanbao then
			buy.free = 1
		elseif self._sid == e_Type_vip_store_bangyuan then
			buy.free = 0
		elseif self._sid == e_Type_vip_store_hongli then
			buy.free = 3
		elseif self._sid == e_Type_vip_store_longhun then
			buy.free = 4
		end
		local buyTimes = self:canBuyRestriction(item)
		if buyTimes ~= 0 then
			if itemType == UseItemFashion then
				g_i3k_ui_mgr:OpenUI(eUIID_VIP_STROE_FASHION_BUY)
				g_i3k_ui_mgr:RefreshUI(eUIID_VIP_STROE_FASHION_BUY, buy,item)
			elseif itemType == UseItemMetamorphosis then
				g_i3k_ui_mgr:OpenUI(eUIID_VIP_STROE_FASHION_BUY)
				g_i3k_ui_mgr:RefreshUI(eUIID_VIP_STROE_FASHION_BUY, buy,item, DRESS_TYPE)
			elseif itemType == UseItemPet or itemType == UseItemHorse then
				g_i3k_ui_mgr:OpenUI(eUIID_VipStoreCallItemBuy)
				g_i3k_ui_mgr:RefreshUI(eUIID_VipStoreCallItemBuy, buy, item)
			elseif itemType == UseItemFurniture then
				g_i3k_ui_mgr:OpenUI(eUIID_VipStoreHomeland)
				g_i3k_ui_mgr:RefreshUI(eUIID_VipStoreHomeland, buy, item)
			end
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(214))
		end
		self.selectedItemId = nil
	end
end

function wnd_vip_store:checkRestrictionTimes(item)
	--local times = item.restriction.times
	local times = self:buyRestrictionTimes(item)
	local allBuyLogs = self._logInfo.buyLogs  --map

	local currencyType = g_BASE_ITEM_DIAMOND
	if self._sid == e_Type_vip_store_yuanbao then
		currencyType = -g_BASE_ITEM_DIAMOND
	elseif self._sid == e_Type_vip_store_bangyuan then
		currencyType = g_BASE_ITEM_DIAMOND
	elseif self._sid == e_Type_vip_store_hongli then
		currencyType = g_BASE_ITEM_DIVIDEND
	elseif self._sid == e_Type_vip_store_longhun then
		currencyType =  g_BASE_ITEM_DRAGON_COIN
	end

	if allBuyLogs[currencyType] == nil then
		local tempLogs = {}
		tempLogs[item.id] = {weekBuyTimes = 0,id = item.id, dayBuyTimes = 0,allBuyTimes = 0}
		allBuyLogs[currencyType] = {buyLogs = tempLogs}
	end

	local buyLogs = allBuyLogs and allBuyLogs[currencyType] and allBuyLogs[currencyType].buyLogs  --map
	local buyLog = buyLogs and buyLogs[item.id]

	if buyLog then
		if item.restriction.weekPeriod == e_Refresh_day then
			times = times - buyLog.dayBuyTimes
		elseif item.restriction.weekPeriod == e_Refresh_week then
			times = times - buyLog.weekBuyTimes
		end
	end
	return times
end

--根据vip等级返回限购次数，是否显示v16角标
function wnd_vip_store:buyRestrictionTimes(Item)
	local myVipLvl = g_i3k_game_context:GetVipLevel()
	local doubleVip = Item.restriction.vipdouble
	if myVipLvl >= doubleVip then
		return Item.restriction.times * 2, true  --vip特权翻倍
	else
		return Item.restriction.times, false
	end
end

function wnd_vip_store:setStyleShow(bar,style,item)
	local dazhe_panel = bar.vars.dazhe_panel
	local putong_panel = bar.vars.putong_panel
	putong_panel:hide()
	dazhe_panel:hide()
	local pkpunish = g_i3k_game_context:GetPKPunish()--pk惩罚
	if self._sid == e_Type_vip_store_yuanbao or self._sid == e_Type_vip_store_hongli or e_Type_vip_store_longhun  then
		pkpunish = 0;
	end
	local itemInfo = {
		[e_Type_vip_store_yuanbao] = {money_icon = false, icon =  currency_icon[1] },
		[e_Type_vip_store_bangyuan] = {money_icon = true, icon =  currency_icon[1] },
		[e_Type_vip_store_hongli] = {money_icon = false, icon =  currency_icon[2] },
		[e_Type_vip_store_longhun] = {money_icon = false, icon =  currency_icon[3] },
	}
	if style == e_Style_store_item_putong then---普通情况
		putong_panel:show()
		local xiangou_money_count = bar.vars.xiangou_money_count
		local xiangou_money_icon = bar.vars.xiangou_money_icon
		local xiangou_currency = bar.vars.xiangou_currency  --限购货币类型
		xiangou_money_count:setText(math.floor(item.price*(1+pkpunish)))---向下取整
		item.finalprice = math.floor(item.price*(1+pkpunish))
		item.changePrice = item.price
		if itemInfo[self._sid] then
			xiangou_money_icon:setVisible(itemInfo[self._sid].money_icon)
			xiangou_currency:setImage(i3k_db.i3k_db_get_icon_path(itemInfo[self._sid].icon))  --红利货币图标
		end
	elseif style == e_Style_store_item_dazhe then---打折情况
		dazhe_panel:show()
		local dazhe_oldmoney_count = bar.vars.dazhe_oldmoney_count--打折情况下显示原价
		local dazhe_oldmoney_icon = bar.vars.dazhe_oldmoney_icon
		local dazhe_newmoney_count = bar.vars.dazhe_newmoney_count--显示现价
		local dazhe_newmoney_icon = bar.vars.dazhe_newmoney_icon
		local dazhe_icon = bar.vars.dazhe_icon--打几折

		local dazhe_old_currency = bar.vars.dazhe_old_currency  --打折货币类型
		local dazhe_new_currency = bar.vars.dazhe_new_currency

		local discount = math.ceil(item.discount.price*10/item.price)
		if discount == 10 then
			discount = 9
		end

		dazhe_icon:setImage(i3k_db.i3k_db_get_icon_path(discounticon[discount]))
		dazhe_oldmoney_count:setText(item.price*(1+pkpunish))
		dazhe_newmoney_count:setText(item.discount.price*(1+pkpunish))
		item.finalprice = item.discount.price*(1+pkpunish)
		item.changePrice = item.discount.price
		if itemInfo[self._sid]then
			dazhe_oldmoney_icon:setVisible(itemInfo[self._sid].money_icon)
			dazhe_newmoney_icon:setVisible(itemInfo[self._sid].money_icon)
			dazhe_old_currency:setImage(i3k_db.i3k_db_get_icon_path(itemInfo[self._sid].icon))  --元宝图标
			dazhe_new_currency:setImage(i3k_db.i3k_db_get_icon_path(itemInfo[self._sid].icon))  --元宝图标
		end
	end
end

function wnd_vip_store:sellItemFilter(Item)
	local curtime = i3k_game_get_time()
	local addItem = false;
	e_AType_BestSeller = 1
	e_AType_Strengthen = 2
	e_AType_Figure = 4
	e_AType_Homeland = 8
	Item.homeland = math.floor(Item.attribute/e_AType_Homeland)
	Item.figure = math.floor((Item.attribute - Item.homeland * e_AType_Homeland)/e_AType_Figure)
	Item.strengthen = math.floor((Item.attribute - Item.homeland * e_AType_Homeland - Item.figure * e_AType_Figure)/e_AType_Strengthen)
	Item.bestseller = Item.attribute - Item.figure * e_AType_Figure - Item.strengthen * e_AType_Strengthen - Item.homeland * e_AType_Homeland
	Item.homeland = Item.homeland == 1
	Item.figure = Item.figure == 1
	Item.strengthen = Item.strengthen == 1
	Item.bestseller = Item.bestseller == 1
	local Isrestriction = false
	if Item.restriction then
		if Item.restriction.time then
			if Item.restriction.time.endTime then
				if curtime >= Item.restriction.time.startTime and curtime <= Item.restriction.time.endTime then
					Isrestriction = true;
				end
			end
		else
			Isrestriction = true;
		end
	end
	if self._tid == e_Type_store_itemlist_rexiao then
		if Item.bestseller and not Isrestriction then
			addItem = self:sellItemFilterCommon(Item)
		end
	elseif self._tid == e_Type_store_itemlist_qianghua then
		if Item.strengthen and not Isrestriction then
			addItem = self:sellItemFilterCommon(Item)
		end
	elseif self._tid == e_Type_store_itemlist_homeland then
		if Item.homeland and not Isrestriction then
			addItem = self:sellItemFilterCommon(Item)
		end
	elseif self._tid == e_Type_store_itemlist_xingxiang then
		if Item.figure and not Isrestriction then
			addItem = self:sellItemFilterCommon(Item)
		end
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(Item.iid)
		if cfg then
			local fashionCfg = g_i3k_db.i3k_db_get_fashion_cfg(cfg.args1)
			if fashionCfg then
				if self._sid == 2 and cfg.type == UseItemFashion and fashionCfg.sex ~= g_i3k_game_context:GetRoleGender() then
					addItem = false
				end
			end
		end
	elseif self._tid == e_Type_store_itemlist_qita then
		if not Item.figure and not Isrestriction and not Item.strengthen and not Item.homeland then
			addItem = self:sellItemFilterCommon(Item)
		end
	elseif self._tid == e_Type_store_itemlist_xiangou then
		if Item.restriction then
			if Item.restriction.time then
				if Item.restriction.time.endTime then
					if curtime >= Item.restriction.time.startTime and curtime <= Item.restriction.time.endTime then
						addItem = true;
					end
				else
					addItem = self:sellItemFilterCommon(Item)
				end
			else
				addItem = self:sellItemFilterCommon(Item)
			end
		end
	end
	--判断等级限制
	if Item.levelReq then
		local hero = i3k_game_get_player_hero()
		if hero._lvl < Item.levelReq then
			addItem = false;
		end
	end
	if addItem then
		return true
	end
	return false;
end

function wnd_vip_store:sellItemFilterCommon(Item)
	local curtime = i3k_game_get_time()
	if Item.time then
		if Item.time.endTime then
			if curtime >= Item.time.startTime and curtime <= Item.time.endTime then
				return true;
			end
		else
			if curtime >= self._mallInfo.time.startTime and curtime <= self._mallInfo.time.endTime then
				return true;
			end
		end
	else
		if curtime >= self._mallInfo.time.startTime and curtime <= self._mallInfo.time.endTime then
			return true;
		end
	end
	return false;
end

--[[function wnd_vip_store:onClose(sender, eventType)
	if eventType == ccui.TouchEventType.ended then
		g_i3k_ui_mgr:CloseUI(eUIID_VipStore)
	end
end--]]

function wnd_vip_store:onBuyBtnClick(sender, index)
	self:onBuyBtn(index)
end

--把商品id转换为index
function wnd_vip_store:transIdToIndex(id)
	for k, v in ipairs(self.filterItem) do
		if id == v.iid then
			self:onBuyBtn(k)
			break
		end
	end
end

--是否是买赠商品
function wnd_vip_store:isExtraGifts(index)
	local item = self.filterItem[index]
	if self._extraGifts and self._extraGifts.gifts[item.id] then
		return true
	else
		return false
	end
end

--选中商品 弹窗
function wnd_vip_store:onBuyBtn(index)
	local pkpunish = g_i3k_game_context:GetPKPunish()--pk惩罚
	if self._sid == e_Type_vip_store_yuanbao then
		pkpunish = 0;
	end
	--local index = sender:getTag()
	local item = self.filterItem[index]
	local buy = {}
	buy.effectiveTime = self.info.effectiveTime
	buy.id = self._mallInfo.time.startTime;
	buy.gid = item.id;
	buy.count = 1;
	buy.price = item.changePrice --item.finalprice
	--item.finalprice = math.floor(item.finalprice*(1+pkpunish))
	if self._sid == e_Type_vip_store_yuanbao then
		buy.free = 1
	elseif self._sid == e_Type_vip_store_bangyuan then
		buy.free = 0
	elseif self._sid == e_Type_vip_store_hongli then
		buy.free = 3
	elseif self._sid == e_Type_vip_store_longhun then
		buy.free = 4
	end
	local buyTimes = self:canBuyRestriction(item)
	if buyTimes ~= 0 then
		local cfg = g_i3k_db.i3k_db_get_other_item_cfg(item.iid)
		if cfg and cfg.type then
			local itemType = cfg.type
			if itemType == UseItemFashion then
				g_i3k_ui_mgr:OpenUI(eUIID_VIP_STROE_FASHION_BUY)
				g_i3k_ui_mgr:RefreshUI(eUIID_VIP_STROE_FASHION_BUY, buy,item)
			elseif itemType == UseItemMetamorphosis then
				g_i3k_ui_mgr:OpenUI(eUIID_VIP_STROE_FASHION_BUY)
				g_i3k_ui_mgr:RefreshUI(eUIID_VIP_STROE_FASHION_BUY, buy,item, DRESS_TYPE)
			elseif self:isExtraGifts(index) then
				g_i3k_ui_mgr:OpenUI(eUIID_BuyGetGifts)
				g_i3k_ui_mgr:RefreshUI(eUIID_BuyGetGifts, buy,item,self:canBuyRestriction(item), self._extraGifts)
			elseif itemType == UseItemHeadPreview and cfg.args1 == 1 then
				g_i3k_ui_mgr:OpenUI(eUIID_Head_Preview)
				g_i3k_ui_mgr:RefreshUI(eUIID_Head_Preview, buy, item, self:canBuyRestriction(item))
			elseif itemType == UseItemPet or itemType == UseItemHorse then
				g_i3k_ui_mgr:OpenUI(eUIID_VipStoreCallItemBuy)
				g_i3k_ui_mgr:RefreshUI(eUIID_VipStoreCallItemBuy, buy, item)
			elseif itemType == UseItemFurniture then
				g_i3k_ui_mgr:OpenUI(eUIID_VipStoreHomeland)
				g_i3k_ui_mgr:RefreshUI(eUIID_VipStoreHomeland, buy, item)
			else
				g_i3k_ui_mgr:OpenUI(eUIID_VIP_STROE_BUY)
				g_i3k_ui_mgr:RefreshUI(eUIID_VIP_STROE_BUY, buy,item,self:canBuyRestriction(item))
			end
		elseif self:isExtraGifts(index) then
			g_i3k_ui_mgr:OpenUI(eUIID_BuyGetGifts)
			g_i3k_ui_mgr:RefreshUI(eUIID_BuyGetGifts, buy,item,self:canBuyRestriction(item), self._extraGifts)
		else
			g_i3k_ui_mgr:OpenUI(eUIID_VIP_STROE_BUY)
			g_i3k_ui_mgr:RefreshUI(eUIID_VIP_STROE_BUY, buy,item,self:canBuyRestriction(item))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(214))
	end
	self:hideSelectedImage(index)
end

function wnd_vip_store:canBuyRestriction(Item)
	self.clickbuytimes = nil;
	if Item.restriction and Item.restriction.times then
		local times = Item.restriction.times
		local curday =g_i3k_get_day(i3k_game_get_time())
		local curweek = g_i3k_get_week(curday)
		if Item.restriction.weekPeriod == e_Refresh_week then
			self:isNeedRefreshLog()
		elseif Item.restriction.weekPeriod == e_Refresh_day then
			self:isNeedRefreshLog()
		end
		self.clickbuytimes = self:checkRestrictionTimes(Item)
		if times <= 0  then
			return 0;
		end
		if self.clickbuytimes and self.clickbuytimes <= 0 then
			self.clickbuytimes = 0
		end
	end
	return self.clickbuytimes
end

function wnd_vip_store:addLog(currencyType,id,count)
	if self._logInfo.buyLogs then
		if self._logInfo.buyLogs[currencyType] and self._logInfo.buyLogs[currencyType].buyLogs then
			if not self._logInfo.buyLogs[currencyType].buyLogs[id] then
				self._logInfo.buyLogs[currencyType].buyLogs[id] = {weekBuyTimes = 0,id = id, dayBuyTimes = 0,allBuyTimes = 0}
			end
			self._logInfo.buyLogs[currencyType].buyLogs[id].dayBuyTimes = self._logInfo.buyLogs[currencyType].buyLogs[id].dayBuyTimes + count
			self._logInfo.buyLogs[currencyType].buyLogs[id].weekBuyTimes = self._logInfo.buyLogs[currencyType].buyLogs[id].weekBuyTimes + count
			self._logInfo.buyLogs[currencyType].buyLogs[id].allBuyTimes = self._logInfo.buyLogs[currencyType].buyLogs[id].allBuyTimes + count
		end
	end
end

function wnd_vip_store:isNeedRefreshLog()
	local curday =g_i3k_get_day(i3k_game_get_time())
	local curweek = g_i3k_get_week(curday)
	if curweek ~= self._lastweek then
		self:refreshLog(e_Refresh_week)
		self._lastweek = curweek
		self._lastday = curday
		return true;
	elseif curday ~= self._lastday then
		self:refreshLog(e_Refresh_day)
		self._lastday = curday
		return true;
	end
	return false
end

function wnd_vip_store:refreshLog(type)
	if self._logInfo.buyLogs then
		for _,v in pairs(self._logInfo.buyLogs) do
			local buyLogs = v.buyLogs  --map
			if buyLogs then
				for _,v1 in pairs(v.buyLogs) do
					v1.dayBuyTimes = 0
					if type == e_Refresh_week then
						v1.weekBuyTimes = 0
					end
				end
			end
		end
	end
end

function wnd_create(layout, ...)
	local wnd = wnd_vip_store.new()
		wnd:create(layout, ...)

	return wnd
end
