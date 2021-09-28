-------------------------------------------------------
module(..., package.seeall)

local require = require;

require("ui/ui_funcs")
local ui = require("ui/base");
require("i3k_usercfg");

-------------------------------------------------------
wnd_steed = i3k_class("wnd_steed", ui.wnd_base)

local f_star_img_table = {
[1] = 20016,
[2] = 20017,
[3] = 20018,
[4] = 20019,
[5] = 20020,
[6] = 20021,
[7] = 20022,
[8] = 20023,
[9] = 20024,
[10] = 20025
}
local breakImage = {5325, 5326, 5327}

function wnd_steed:ctor()
	self._steedID = 0
	self._curRideID = 0
	self._cfg = cfg
	self._isUpStar = true
	self._showType = 0 --1单人坐骑，2双人坐骑
end

function wnd_steed:configure()
	self._layout.vars.closeBtn:onClick(self, self.onCloseUI)
	local attributeBtn = self._layout.vars.attributeBtn
	local introduceBtn = self._layout.vars.introduceBtn
	self._tabBar = {[1] = attributeBtn, [2] = introduceBtn}
	for i,v in ipairs(self._tabBar) do
		v:onClick(self, self.onTabBarClick)
		if i==1 then
			v:stateToPressedAndDisable()
		end
	end
	
	self._layout.vars.helpBtn:onClick(self, function ()
		g_i3k_ui_mgr:ShowHelp(i3k_get_string(297))
	end)
	
	local widgets = self._layout.vars
	
	local root = {}
	root.nameLabel = widgets.nameLabel
	root.attrLabel = widgets.attrLabel
	root.powerLabel = widgets.powerLabel
	root.huanhuaBtn = widgets.huanhuaBtn---幻化按钮
	root.huanhuaBtn:onClick(self, self.huanhuaSkin)
	root.fightBtn = widgets.fightBtn--出征
	root.fightBtn:onClick(self, self.steedFight)
	root.showRank_btn = widgets.showRank_btn  --排行
	root.showRank_btn:onClick(self, self.showSteedRank)
	
	--单人多人坐骑按钮
	root.typeButton = {widgets.oneSteedBtn, widgets.moreSteedBtn}
	root.typeButton[1]:stateToPressed(true)
	for i,v in ipairs(root.typeButton) do
		v:onClick(self,self.OnShowTypeChanged, i)
	end
	root.model = widgets.model
	root.steedScroll = widgets.scroll
	root.addLabel = widgets.addLabel
	root.speedLabel = widgets.speedLabel
	
	
	root.func = {}
	root.func.root = widgets.funcRoot
	root.func.practiceBtn = widgets.practiceBtn--洗炼按钮
	root.func.practiceBtn:onClick(self, self.toPractice)
	root.func.practiceBtnRed = widgets.practiceBtnRed
	root.func.practiceMaxIcon = widgets.practiceMaxIcon
	root.func.starBtn = widgets.starBtn--升星
	root.func.bt_name = widgets.bt_name    --升星按钮的文字
	root.func.starBtn:onClick(self, self.onUpStarOrBreak)
	root.func.starMaxIcon = widgets.starMaxIcon
	root.func.recycle_btn = widgets.recycle_btn --回收按钮
	root.func.recycle_btn:onClick(self, self.onRecycle)
	root.func.starBtnRed = widgets.starBtnRed
	root.func.steedSkillBtn = widgets.steedSkillBtn--骑术
	root.func.steedSkillBtn:onClick(self, self.toSteedSkill)
	root.func.steedSkillBtnRed = widgets.steedSkillBtnRed
	root.func.steedSkillMaxIcon = widgets.steedSkillMaxIcon
	
	root.notTame = {}
	root.notTame.root = widgets.notTameRoot--线索描述板子
	root.notTame.tameNeedGradeIcon = widgets.tameNeedGradeIcon
	root.notTame.tameNeedIcon = widgets.tameNeedIcon
	root.notTame.itemBtn = widgets.itemBtn
	root.notTame.tameNeedItemLabel = widgets.tameNeedItemLabel
	root.notTame.descLabel = widgets.descLabel
	
	root.notTame.btnName = widgets.btnName
	root.notTame.btnName:onClick(self, self.FlyPreview)
	root.notTame.tameBtn = widgets.tameBtn--驯服 
	
	root.attrScroll = widgets.attrScroll
	widgets.attrScroll:setBounceEnabled(false)
	root.steedScroll.align = g_UIScrollList_HORZ_ALIGN_NARROW_CENTER
	
	self.go_out = widgets.go_out
	self.go_out:onClick(self, self.steedFight)
	self._widgets = root
	self._widgets.steedScroll:setAlignMode(g_UIScrollList_HORZ_ALIGN_LEFT)
	widgets.steedBtn:stateToPressed()
	self.steed_point = widgets.steed_point
	self.steedSkinPoint = widgets.steedSkinPoint
	--单人多人坐骑红点
	self._steedTypeRed = {widgets.singleRed, widgets.moreRed}
	if g_i3k_game_context:GetLevel() >= i3k_db_steed_fight_base.openLvl then
		widgets.steedFightBtn:show():onClick(self, self.onFightBtn)
	else
		widgets.steedFightBtn:hide()
	end
	widgets.steedSkinBtn:stateToNormal()
	widgets.steedSkinBtn:onClick(self, self.onSteedSkinBtn)
	self.fightRedPoint = widgets.fightRedPoint
end

function wnd_steed:refresh(steedId)
	self._showType = 0
	self._curRideID = steedId
	local steedType = g_i3k_db.i3k_db_get_steed_type(self._curRideID)
	steedType = steedType == 0 and g_SINGLE_STEED or steedType
	self:OnTypeChanged(steedType)
	self:updateSteedNotice()
end
function wnd_steed:updateSteedListScrool()
	self._widgets.steedScroll:removeAllChildren()
	local sort_cfg = self:getSortedCfg(self._showType)
	local steedInfo = g_i3k_game_context:getAllSteedInfo()
	local firstId = 1 
	for i,v in ipairs(sort_cfg) do
		if v.isShow == 1 then
			local node = require("ui/widgets/zqt")()
			if i == 1 then
				firstId = v.id
			end
			local info
			if steedInfo[id] then
				
			end
			for _,t in pairs(steedInfo) do
				if t.id== v.id then
					info = t
				end
			end
			local cfg = i3k_db_steed_huanhua[v.huanhuaInitId]
			local breakLevel = g_i3k_game_context:GetSteedBreakInfo(v.id)
			node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconId))
			--ui_set_hero_model(node.vars.model, cfg.modelId)
			--node.vars.model:setRotation(3)
			if breakLevel <= 0 then
				node.vars.breakImage:hide()
				node.vars.starRoot:show()
			else
				node.vars.breakImage:show()
				node.vars.breakImage:setImage(g_i3k_db.i3k_db_get_icon_path(breakImage[breakLevel]))
				node.vars.starRoot:hide()
			end
			node.vars.backImg:setImage(info and g_i3k_db.i3k_db_get_icon_path(707) or g_i3k_db.i3k_db_get_icon_path(708))
			node.vars.lightImg:setOpacity(info and 255*0.7 or 255*0.2)
			node.vars.btn:setTag(v.id)
			--node.vars.selectImg:setVisible(i==1) --选中
			node.vars.btn:onClick(self, self.selectSteed)
			self._widgets.steedScroll:addItem(node)
		end
	end

	self:setData(firstId)
	g_i3k_game_context:LeadCheck()
end
--控制单人多人坐骑按钮红点
function wnd_steed:UpdateSingleAndMoreRedPoint()
	for k,v in ipairs(self._steedTypeRed) do
		v:setVisible(self:getRedStateFromType(k))
	end
end
function wnd_steed:getRedStateFromType(steedType)
	for steedID, _ in ipairs(i3k_db_steed_cfg) do
		if g_i3k_db.i3k_db_get_steed_type(steedID) == steedType and self:isCanCollectAll(steedID) then
			return true
		end
	end
	return false
end

function wnd_steed:setModel(ui,modelID)
	local mcfg = i3k_db_models[modelID];
	if mcfg then
		ui:setSprite(mcfg.path);
		ui:setSprSize(mcfg.uiscale);
		ui:playAction("show");
	end
end

function wnd_steed:setData(id)
	self._steedID = id
	local steedInfo = g_i3k_game_context:getAllSteedInfo()
	local useSteed = g_i3k_game_context:getUseSteed()
	self.level = g_i3k_game_context:GetLevel()
	local info
	local isHave = false
	if steedInfo[id] then
		info = steedInfo[id]
		isHave = true
	end
	self._widgets.fightBtn:setVisible(isHave)
	self._widgets.attrLabel:setVisible(isHave)
	self._layout.vars.recycle_btn:setVisible(info and not i3k_db_steed_star[info.id][info.star+1])
	if info and not i3k_db_steed_breakCfg[info.id][info.breakLvl + 1] then
		self._widgets.func.starMaxIcon:setVisible(true)
	else
		self._widgets.func.starMaxIcon:setVisible(false)
	end
	--设置模型以及出站button状态
	if i3k_db_steed_cfg[id].justEquitation==1  or self.level < i3k_db_common.functionHide.zuoqiHideLvl then
		if useSteed==id then
			self._widgets.attrLabel:setText(i3k_get_string(295))
			self.go_out:disableWithChildren()
		else
			self._widgets.attrLabel:setText(i3k_get_string(296))
			self.go_out:enableWithChildren()
			self.go_out:setTag(id)
		end
	else
		if useSteed==id then
			self._widgets.attrLabel:setText(i3k_get_string(295))
			self._widgets.fightBtn:disableWithChildren()
		else
			self._widgets.attrLabel:setText(i3k_get_string(296))
			self._widgets.fightBtn:enableWithChildren()
			self._widgets.fightBtn:setTag(id)
		end
	end

	local cfg = i3k_db_steed_huanhua[i3k_db_steed_cfg[id].huanhuaInitId]
	self:setModel(self._widgets.model, cfg.modelId)
	if cfg.modelRotation ~= 0 then
		self._widgets.model:setRotation(cfg.modelRotation)
	end

	self.info = info
	self._cfg = cfg
	self:setAttrData(id, info, cfg)
	self:setFuncData(id, info, cfg)
	self:reloadSteedScrollNode(steedInfo, id, info)
	self:UpdateSingleAndMoreRedPoint()
	--设置scroll的选中状态
	local height = 173
	local scrollContainerSize=self._widgets.steedScroll:getContainerSize()
	local heightProportion = scrollContainerSize.height/height
	height = height * heightProportion
	local normalWidth = 254 * heightProportion
	local selectWidth = 282 * heightProportion
	local children = self._widgets.steedScroll:getAllChildren()
	for i,v in ipairs(children) do--redPoint红点
		local steedID = v.vars.btn:getTag()
		v.vars.fightImg:setVisible(steedID == useSteed)
		v.vars.selectImg:setVisible(steedID == id)--选中
		local isShowRedPoint = self:isCanCollectAll(steedID)
		v.vars.redPoint:setVisible(isShowRedPoint)--红点
		v.vars.descLabel:setText(isShowRedPoint and i3k_get_string(5535) or i3k_get_string(5534))
		if steedID==id then
			v.rootVar:changeSizeInScroll(self._widgets.steedScroll, selectWidth, height, false)
			v.vars.lbjdNode:setSizePercent(1, 1)
			v.vars.lightImg:setOpacity(255)
			v.vars.backImg:setImage(g_i3k_db.i3k_db_get_icon_path(706))
			v.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.iconId))--修改头像
		else
			v.rootVar:changeSizeInScroll(self._widgets.steedScroll, normalWidth, height, false)
			v.vars.lbjdNode:setSizePercent(1, 0.90)
		end
	end
end

function wnd_steed:reloadSteedScrollNode(steedInfo, id, info)
	for _,v in ipairs(self._widgets.steedScroll:getAllChildren()) do
		v.vars.btn:stateToNormal()
		local isHave = false
		local breakLevel = 0
		for __,t in pairs(steedInfo) do
			if t.id==v.vars.btn:getTag() then
				local starTable = {
				[1] = v.vars.star1, [2] = v.vars.star2, [3] = v.vars.star3, [4] = v.vars.star4, [5] = v.vars.star5, [6] = v.vars.star6, [7] = v.vars.star7, [8] = v.vars.star8, [9] = v.vars.star9,
				}
				for i,u in ipairs(starTable) do
					u:setVisible(i<=t.star)
				end
				v.vars.levelLabel:setText(t.enhanceLvl .. "级")
				isHave = true
				breakLevel = t.breakLvl
				break
			end
		end
		if v.vars.btn:getTag()==id then
			v.vars.btn:stateToPressedAndDisable()
		end
		v.vars.lightImg:setOpacity(isHave and 255*0.7 or 255*0.2)
		v.vars.backImg:setImage(isHave and g_i3k_db.i3k_db_get_icon_path(707) or g_i3k_db.i3k_db_get_icon_path(708))
		v.vars.starRoot:setVisible(isHave and breakLevel <= 0)
		v.vars.levelLabel:setVisible(isHave)
		v.vars.descLabel:setVisible(not isHave)
	end
end

--设置右侧信息
function wnd_steed:setFuncData(id ,info, cfg)
	self.isTame = false --加已驯服标记
	local isshow =  self.level >= i3k_db_common.functionHide.zuoqiHideLvl
	self._widgets.func.root:setVisible(info~=nil and isshow)
	self._widgets.notTame.root:setVisible(not self._widgets.func.root:isVisible())
	if info~=nil then
		--已经驯服状态
		if i3k_db_steed_cfg[id].justEquitation==1 or self.level < i3k_db_common.functionHide.zuoqiHideLvl then
			self._widgets.notTame.root:show()
			self._widgets.func.root:hide()
			self._layout.vars.consume:hide()
			self._widgets.notTame.tameBtn:hide()
			self.go_out:show()
			self.go_out:setTag(id)
			local steedCfg = i3k_db_steed_cfg[id]
			self._widgets.notTame.descLabel:show()
			self._widgets.notTame.descLabel:setText(steedCfg.desc)
		else
			self.isTame= true
			self._widgets.func.practiceBtn:setTag(id)
			self._widgets.func.practiceBtnRed:setVisible(g_i3k_game_context:isEnoughUpSteedPractice(id))--红点
			self._widgets.func.practiceMaxIcon:setVisible(self:GetPracticeAchieveMax(id))
			if i3k_db_steed_star[info.id][info.star+1] then
				self._widgets.func.bt_name:setText("升星")
				self._isUpStar = true
				self._widgets.func.starBtnRed:setVisible(g_i3k_game_context:isEnoughUpSteedStar(id,info))--红点
			else
				self._widgets.func.bt_name:setText("突破")
				self._isUpStar = false
				self._widgets.func.starBtnRed:setVisible(g_i3k_game_context:isEnoughUpBreakLevel(id,info))--红点
			end
			self._widgets.func.steedSkillBtn:setTag(id)
			self._widgets.func.steedSkillBtnRed:setVisible(g_i3k_game_context:isEnoughUpSteedSkillToAct(id,info) or g_i3k_game_context:canAddBook())--红点
			self._widgets.func.steedSkillMaxIcon:setVisible(self:GetSkillAchieve(id))
		end
	else
		--未驯服状态
		self:setItemScrollData()
	end
end
-- 洗练是否达到最高
function wnd_steed:GetPracticeAchieveMax(id)
	local isMax = false
	local info = g_i3k_game_context:getSteedInfoBySteedId(id)
	local refineId = i3k_db_steed_cfg[id].refineId
	local refineCfg = i3k_db_steed_practice[refineId]
	local enhanceAttrs = info.enhanceAttrs
	if #enhanceAttrs == #refineCfg then
		local totalNum = 0
		for i, e in ipairs(enhanceAttrs) do
			if e.id ~= 0 then
				local cfg = refineCfg[i]
				local maxValue = cfg[e.id].maxValue
				if e.value == maxValue then
					totalNum = totalNum + 1
				end
			end
		end
		isMax = totalNum == #refineCfg
	end 
	return isMax
end
-- 骑术是否达到最大等级
function wnd_steed:GetSkillAchieve(id)
	local skillData = g_i3k_game_context:getSteedSkillLevelData()
	local equitationId = i3k_db_steed_cfg[id].equitationId
	local skillLvlCfg = i3k_db_steed_skill_cfg[equitationId]
	local skillLvl = skillData[equitationId]
	return skillLvl == #skillLvlCfg
end

function wnd_steed:setSteedRedPoint()
	--设置scroll的红点
	local id = self._steedID
	local children = self._widgets.steedScroll:getAllChildren()
	for i,v in ipairs(children) do--redPoint红点
		local isShowRedPoint = self:isCanCollectAll(v.vars.btn:getTag())
		v.vars.redPoint:setVisible(isShowRedPoint)--红点
		v.vars.descLabel:setText(isShowRedPoint and i3k_get_string(5535) or i3k_get_string(5534))
	end
	self:UpdateSingleAndMoreRedPoint()
	if self.isTame then
		self._widgets.func.practiceBtnRed:setVisible(g_i3k_game_context:isEnoughUpSteedPractice(id))--红点
	end
end

function wnd_steed:setItemScrollData()
	self:setSteedRedPoint()
	if self.info~=nil then
		return
	end
	local id = self._steedID
	local cfg = self._cfg
	local steedCfg = i3k_db_steed_cfg[id]
	local needId = steedCfg.tameNeedId
	self._widgets.notTame.tameNeedGradeIcon:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(needId))
	self._widgets.notTame.tameNeedIcon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(needId,i3k_game_context:IsFemaleRole()))
	self._widgets.notTame.itemBtn:onClick(self, function ()
		g_i3k_ui_mgr:ShowCommonItemInfo(needId)
	end)
	self._widgets.notTame.descLabel:setText(steedCfg.desc)
	local needItemCount = steedCfg.tameNeedCount
	local hasCount = g_i3k_game_context:GetCommonItemCanUseCount(needId)
	local needItemName = g_i3k_db.i3k_db_get_common_item_name(needId)
	self._widgets.notTame.tameNeedItemLabel:setText(needItemName.."x"..needItemCount)
	self._widgets.notTame.tameNeedItemLabel:setTextColor(g_i3k_get_cond_color(needItemCount<=hasCount))
	local needValue = {needId = needId, needCount = needItemCount, steedName = cfg.name}
	self.go_out:hide()
	self._widgets.notTame.descLabel:show()
	self._widgets.notTame.tameBtn:show()
	self._layout.vars.consume:show()
	self._widgets.notTame.tameBtn:setTag(id)
	self._widgets.notTame.tameBtn:onClick(self, self.tameSteed, needValue)
end

--设置左侧信息
function wnd_steed:setAttrData(id, info, cfg)
	local cfgb = i3k_db_steed_cfg[id]
	self._widgets.huanhuaBtn:setVisible(cfgb.justEquitation~=1 and id ~= 1)
	self._widgets.speedLabel:setText(cfgb.speed)
	self._widgets.huanhuaBtn:setTag(id)
	self._widgets.nameLabel:setText(cfg.name)
	self._widgets.attrScroll:removeAllChildren(true)
	local starLvl = info and info.star or 0
	local breakLvl = info and info.breakLvl or 0
	local starCfg = i3k_db_steed_star[id][starLvl]
	local attrTable = {}
	for i = 1 , 9 do
		if breakLvl <= 0 then
			if starCfg["attrId"..i] > 0 then
				table.insert(attrTable,{id = starCfg["attrId"..i], value = starCfg["attrValue"..i]})
			end
		else
			local breakCfg = i3k_db_steed_breakCfg[id][breakLvl]
			if breakCfg["attrId"..i] > 0 and breakCfg["attrId"..i] == starCfg["attrId"..i] then
				table.insert(attrTable,{id = breakCfg["attrId"..i], value = breakCfg["attrValue"..i] + starCfg["attrValue"..i]})
			end 
		end
	end
	if info~=nil then
		self._widgets.addLabel:setText(i3k_get_string(285))
	else
		self._widgets.addLabel:setText(i3k_get_string(284))
	end
	if info then
		for i,v in pairs(info.enhanceAttrs) do
			isHaveAttr = false
			for j,t in pairs(attrTable) do
				if t.id==v.id then
					isHaveAttr = true
					t.value = t.value + v.value
					break
				end
			end
			if not isHaveAttr and v.id > 0 then
				table.insert(attrTable, {id = v.id, value = v.value})
			end
		end
	end
	table.sort(attrTable, function (a, b)
		return a.id<b.id
	end)
	for i,v in ipairs(attrTable) do
		local node = require("ui/widgets/zqt2")()
		self._widgets.attrScroll:addItem(node)
		node.vars.backImg1:setVisible(i%2==1)
		node.vars.backImg2:setVisible(not node.vars.backImg1:isVisible())
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_property_icon_path(v.id))
		node.vars.nameLabel:setText(i3k_db_prop_id[v.id].desc.."：")
		node.vars.valueLabel:setText(i3k_get_prop_show(v.id, v.value))
	end
	
	if g_i3k_game_context:GetLevel() >= i3k_db_common.functionOpen.steedfunction then
		self._layout.vars.showRank_btn:show()
	else
	    self._layout.vars.showRank_btn:hide()
	end
	
	local power = g_i3k_game_context:getSteedPower(attrTable)
	local skillPower =g_i3k_game_context:AppraiseEquestrianSkill(id) --根据坐骑id 统计附加骑术战力
	self._widgets.powerLabel:setText(power+skillPower)
end

function wnd_steed:tameSteed(sender, needValue)
	local steedId = sender:getTag()
	local name = g_i3k_db.i3k_db_get_common_item_name(needValue.needId)
	local canUseCount = g_i3k_game_context:GetCommonItemCanUseCount(needValue.needId)
	if canUseCount<needValue.needCount then
		local str = string.format("%s", "物品不足，驯化失败")
		g_i3k_ui_mgr:PopupTipMessage(str)
	else
		local desc = i3k_get_string(497,needValue.needCount,name,needValue.steedName)
		local callback = function (isOk)
			if isOk then
				local callfunc = function ()
					g_i3k_game_context:UseBagItem(needValue.needId, needValue.needCount,AT_TAME_HORSE)
				end
				i3k_sbean.tame_steed(steedId, callfunc)
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(desc, callback)
	end
end

function wnd_steed:steedFight(sender)
	if i3k_usercfg:GetSteedSkinPrompt() == 1 then
		if g_i3k_game_context:getUseSteed() ~= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_SteedSkinPrompt)
		end
	end
	local id = sender:getTag()
	i3k_sbean.steed_fight(id, callback)
end

function wnd_steed:selectSteed(sender)
	self:setData(sender:getTag())
end

function wnd_steed:toPractice(sender)
	local steedId = sender:getTag()
	local info = g_i3k_game_context:getSteedInfoBySteedId(steedId)
	local need_level = i3k_db_common.functionOpen.steedfunction
	if g_i3k_game_context:GetLevel() >= need_level then
		g_i3k_ui_mgr:OpenUI(eUIID_SteedPractice)
		local power = tonumber(self._widgets.powerLabel:getText())
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedPractice, steedId, info, power)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(478,need_level))
	end
end

function wnd_steed:huanhuaSkin(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SteedHuanhua)
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedHuanhua, sender:getTag(), g_i3k_game_context:getUseSteed())
end

function wnd_steed:FlyPreview(sender)--点击预览按钮
	local equitationId = i3k_db_steed_cfg[self._steedID].equitationId;
	g_i3k_ui_mgr:OpenUI(eUIID_Fly_Mount_Preview)
	g_i3k_ui_mgr:RefreshUI(eUIID_Fly_Mount_Preview,equitationId)
end

function wnd_steed:toSteedSkill(sender)
	if self.info then
		local starLvl = self.info.star
		local steedID =  self.info.id
		local cur_level = g_i3k_game_context:GetLevel()
		local need_level = i3k_db_common.functionOpen.steedfunction
		local isOpen = g_i3k_game_context:CheckCurSteedSkillState(steedID)
		if isOpen then
				g_i3k_ui_mgr:OpenUI(eUIID_SteedSkill)
				g_i3k_ui_mgr:RefreshUI(eUIID_SteedSkill, sender:getTag(), g_i3k_game_context:getSteedInfoBySteedId(sender:getTag()))
		else
			self:FlyPreview();
		end
	end
end

function wnd_steed:onTabBarClick(sender)
	local state = sender:getTag()
	for i,v in ipairs(self._tabBar) do
		v:stateToNormal()
	end
	sender:stateToPressedAndDisable()
end

function wnd_steed:isCanCollectAll(id)--是否能够集齐
	local steedInfo = g_i3k_game_context:getAllSteedInfo()
	if steedInfo[id] then
		local practice = g_i3k_game_context:isEnoughUpSteedPractice(id)
		local  star = g_i3k_game_context:isEnoughUpSteedStar(id,steedInfo[id])
		local actskill = g_i3k_game_context:isEnoughUpSteedSkillToAct(id,steedInfo[id])
		local breakLevel = g_i3k_game_context:isEnoughUpBreakLevel(id,steedInfo[id])
		if i3k_db_steed_cfg[id].justEquitation~=1 then
			return practice or star or actskill or breakLevel
		end
	else--未驯化时
		return g_i3k_game_context:isEnougCollectSteed(id)
	end
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_XB, "updateSteedNotice")
end

function wnd_steed:onSteedSkinBtn(sender)
	if g_i3k_game_context:getUseSteed() ~= 0 then
		g_i3k_logic:OpenSteedSkinUI()
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15530))
	end
end

function wnd_steed:onFightBtn(sender)
	if g_i3k_game_context:getIsUnlockSteedSpirit() then -- 达到良驹之灵开启等级默认打开良驹之灵
		g_i3k_logic:OpenSteedSpriteUI()
		self:onCloseUI()
	else
	if g_i3k_game_context:getUseSteed() ~= 0 then
		if g_i3k_game_context:getSteedFightShowCount() ~= 0 then
			g_i3k_ui_mgr:OpenUI(eUIID_SteedFight)
			g_i3k_ui_mgr:RefreshUI(eUIID_SteedFight)
			self:onCloseUI()
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1258))
		end
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(15530))
		end
	end
end

function wnd_steed:updateSteedNotice()
	self.steed_point:setVisible(g_i3k_game_context:canBetterSteed() or g_i3k_game_context:canAddBook())
	self.fightRedPoint:setVisible(g_i3k_game_context:getIsShowSteedFightRed())
end

--进入碎片回收界面
function wnd_steed:onRecycle(sender)
	local steedCfg = i3k_db_steed_star[self._steedID][1]
	local needId = steedCfg.starNeedId2
	i3k_sbean.openDebrisRecycle(needId, g_DEBRIS_STEED)
end

--进入突破界面
--[[function wnd_steed:onBreakthrough(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SteedBreak)
	g_i3k_ui_mgr:RefreshUI(eUIID_SteedBreak, self._steedID)
end

function wnd_steed:onStar(sender)
	local need_level = i3k_db_common.functionOpen.steedfunction
	local steedId = sender:getTag()
	if g_i3k_game_context:GetLevel() >= need_level then
		g_i3k_ui_mgr:OpenUI(eUIID_SteedStar)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedStar, g_i3k_game_context:getSteedInfoBySteedId(steedId))
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(479,need_level))
	end
end--]]

function wnd_steed:onUpStarOrBreak(sender)
	local steedInfo = g_i3k_game_context:getAllSteedInfo()
	local info = steedInfo[self._steedID]
	if info and not i3k_db_steed_breakCfg[info.id][info.breakLvl + 1] then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1679))
	end
	if self._isUpStar then
		local need_level = i3k_db_common.functionOpen.steedfunction
		if g_i3k_game_context:GetLevel() >= need_level then
			g_i3k_logic:OpenSteedStarUI(self._steedID)
		else
			g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(479,need_level))
		end
	else
		g_i3k_ui_mgr:OpenUI(eUIID_SteedBreak)
		g_i3k_ui_mgr:RefreshUI(eUIID_SteedBreak, self._steedID)
	end
end

--查询坐骑排行
function wnd_steed:showSteedRank(sender)
	local fightPower = tonumber(self._widgets.powerLabel:getText())
	local allSteed = g_i3k_game_context:getAllSteedInfo()
	if not allSteed[self._steedID] then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16811))
	elseif fightPower then
		i3k_sbean.check_steed_rank(self._steedID, fightPower)
	end
end

--坐骑排序规则
-- 				1:是否可驯服
--				2:是否拥有
--3.1:已拥有    				3.2:未拥有  按ID升序
--4:已拥有当前是否骑乘  
--5:已拥有非骑乘按战力降序排序
function wnd_steed:getSortedCfg(showType)
	local sort_cfg = {}
	for i, v in ipairs(i3k_db_steed_cfg) do
		local steedType = g_i3k_db.i3k_db_get_steed_type(v.id)
		if steedType == showType then
		table.insert(sort_cfg, v)
		end
	end
	local steedInfo = g_i3k_game_context:getAllSteedInfo()

	local function sortCfg(a, b)
		local isCurRide_A = a.id == self._curRideID												 --A是否是当前骑乘
		local isCurRide_B = b.id == self._curRideID 											 --B是否是当前骑乘
		local isHave_A = steedInfo and steedInfo[a.id] or false									 --A是否拥有
		local isHave_B = steedInfo and steedInfo[b.id] or false									 --B是否拥有
		local canActive_A = not isHave_A and g_i3k_game_context:isEnougCollectSteed(a.id) 		 --A是否可驯服
		local canActive_B = not isHave_B and g_i3k_game_context:isEnougCollectSteed(b.id) 		 --B是否可驯服
		local power_A = isHave_A and g_i3k_game_context:GetSteedPowerById(a.id) or 0 			 --A的战力
		local power_B = isHave_B and g_i3k_game_context:GetSteedPowerById(b.id) or 0 			 --B的战力

		if canActive_A ~= canActive_B then
			return canActive_A and not canActive_B
	end
		if isCurRide_A ~= isCurRide_B then
			return isCurRide_A and not isCurRide_B
		end
		if power_A ~= power_B and isHave_A and isHave_B then
			return power_B < power_A 
		end
		if a.id ~= b.id and not isHave_A and not isHave_B then
			return a.id < b.id
		end
		if isHave_A ~= isHave_B then
			return isHave_A and not isHave_B
		end
	end
	table.sort(sort_cfg, sortCfg)
	return sort_cfg
end
function wnd_create(layout, ...)
	local wnd = wnd_steed.new()
	wnd:create(layout, ...)
	return wnd;
end
function wnd_steed:OnShowTypeChanged(sender, showType)
	self:OnTypeChanged(showType)
end
function wnd_steed:OnTypeChanged(showType)
	if self._showType ~= showType then
		self._showType = showType
		self:UpdateTypeBtnState()
		self:updateSteedListScrool()
		self._widgets.steedScroll:jumpToListPercent(0)
	end
end
function wnd_steed:UpdateTypeBtnState()
	for i, e in ipairs(self._widgets.typeButton) do
		e:stateToNormal(true)
	end
	self._widgets.typeButton[self._showType]:stateToPressed(true)
end
