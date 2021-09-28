-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");
local BaseUI = require("ui/queryRoleArmorRuneBase");

--拥有佣兵 选中效果
local HAVE_PET		= 707
local SELECT_BG		= 706

local petstar_icon = {405,409,410,411,412,413}
local weaponstar_icon = {3055,3056,3057,3058,3059,3060,3061,3062,3063,3064}
local under_wear_icon = {3899, 3900, 3901}  --玄阴，烈阳，太虚

local attained_Icon = 707
local UNDER_WEAR_BG = 707
local STEED_BG = 707
--随从榜、神兵榜、内甲榜、坐骑榜tips
local petPower_rank = 3
local weaponPower_rank= 4

local underwear_rank = 25
local steedPower_rank= 26
local hideWeaponPower_rank = 37
local breakImage = {5325, 5326, 5327}
-------------------------------------------------------
wnd_ranking_list_RoleProperty = i3k_class("wnd_ranking_list_RoleProperty", BaseUI.wnd_queryRoleArmorRuneBase)

function wnd_ranking_list_RoleProperty:ctor()
	self._info = {}
	self._id = 0
	self._feature = nil
	self._masters = nil
	self._steedSpirit = nil
end
function wnd_ranking_list_RoleProperty:configure()
	local widgets = self._layout.vars
	self._layout.vars.close_btn:onClick(self,self.onCloseUI)
	self.mashu = widgets.mashu
	self.steedJd = widgets.steedJd
	self.steedBtn = widgets.steedBtn
	self.steedFightBtn = widgets.steedFightBtn
	self.steedFightBtn:onClick(self, self.onSteedFightBtn)
	self.skinBtn = widgets.skinBtn
	self.skinBtn:onClick(self, self.onSkinBtn)
	self.steedSpiritRoot = widgets.steedSpiritRoot
	self.steedSpiritBtn = widgets.steedSpiritBtn
	widgets.steedSpiritBtn:onClick(self, self.onSteedSpiritBtn)
	self.steedEquipRoot = widgets.steedEquipRoot
	self.steedEquipBtn = widgets.steedEquipBtn
	widgets.steedEquipBtn:onClick(self, self.onSteedEquipBtn)
	self.rune_root = widgets.rune_root
	self:initRuneBaseUI(widgets)
end

function wnd_ranking_list_RoleProperty:refresh(info, id, feature, masters, steedSpirit, steedEquip, roleOverview)
	self.steedJd:show()
	self.mashu:hide()
	local firstNode = self:setInfo(id, info, feature, masters, steedSpirit, steedEquip, roleOverview)
	self._info = info
	self._id = id
	self._feature = feature
	self._masters = masters
	self._steedSpirit = steedSpirit
	self._steedEquip = steedEquip
	self._roleOverview = roleOverview
	if firstNode then
		self:updateSelectedListItem(firstNode.vars.select1_btn)
	end
end

function wnd_ranking_list_RoleProperty:updateSelectedListItem(sender)
	for i, e in ipairs(self._layout.vars.item_scroll:getAllChildren()) do
		if e.vars.select1_btn.actType == sender.actType then
			e.vars.is_show:show()
			e.vars.select1_btn:stateToPressed()
		else
			e.vars.select1_btn:stateToNormal()
			e.vars.is_show:hide()
		end
	end
end

function wnd_ranking_list_RoleProperty:initEquipRuneUI( )
	local widgets = self._layout.vars
	self.wear_equip={}
	for i=1, eEquipCount do
		local equip_icon = "equip_icon"..i
		local grade_icon = "grade_icon"..i
		local is_select	 = "is_select"..i
		local equip_btn  = "equip"..i
		local lizi     	 = "lizi" .. i
		local sjtx1     	 = "sjtx" .. i .. "_1"
		local sjtx2     	 = "sjtx" .. i .. "_2"
		self.wear_equip[i]  = {
			equip_btn	= widgets[equip_btn],
			equip_icon	= widgets[equip_icon],
			grade_icon	= widgets[grade_icon],
			is_select	= widgets[is_select],
			lizi		= widgets[lizi],
			sjtx1		= widgets[sjtx1],
			sjtx2		= widgets[sjtx2],
		}
	end
end

function wnd_ranking_list_RoleProperty:setInfo(id, info, feature, masters, steedSpirit, steedEquip, roleOverview)
	local firstNode
	self._rune_root:hide()
	if id == petPower_rank then
		firstNode = self:setPetsInfo(id,info)
	elseif id == weaponPower_rank then
		firstNode = self:setWeaponInfo(id,info)
	elseif id == hideWeaponPower_rank then
		firstNode = self:setHideWeaponInfo(id, info)
	elseif id == underwear_rank then
		if g_i3k_game_context:GetLevel() >= i3k_db_under_wear_alone.underWearRuneOpenLvl then
			self._rune_root:show()
		end
		self:initEquipRuneUI()
		firstNode = self:setUnderWearInfo(id,info,feature)
	elseif id == steedPower_rank then
		firstNode = self:setSteedInfo(id,info)
	end
	self.skinBtn:setVisible(id == steedPower_rank or id == weaponPower_rank)
	self.steedBtn:setVisible(id == steedPower_rank or id == weaponPower_rank)
	if id == steedPower_rank and (next(masters) ~= nil or steedSpirit.star > 0) then
		self.steedFightBtn:show();
	else
		self.steedFightBtn:hide();
	end
	self.steedSpiritRoot:hide()
	self.steedSpiritBtn:setVisible(id == steedPower_rank and steedSpirit.star > 0)
	local isShowSteedEquipBtn = (id == steedPower_rank) and (roleOverview.level >= i3k_db_steed_equip_cfg.openLevel)
	self.steedEquipRoot:hide()
	self.steedEquipBtn:setVisible(isShowSteedEquipBtn)
	if id == weaponPower_rank then
		self._layout.vars.steedLabel:setText("神兵")
		self._layout.vars.skinLabel:setText("器灵")
		self.steedBtn:onClick(self, self.onWeaponBtn)
		self.skinBtn:onClick(self, self.onQilingBtn)
	end
	self.steedBtn:stateToPressed()
	return firstNode
end

function wnd_ranking_list_RoleProperty:onWeaponBtn(sender)
	self._layout.vars.qilingRoot:hide()
	self.skinBtn:stateToNormal(true)
	self.steedBtn:stateToPressed()
end
function wnd_ranking_list_RoleProperty:onQilingBtn(sender)
	self._layout.vars.qilingRoot:show()
	self.skinBtn:stateToPressed()
	self.steedBtn:stateToNormal(true)
	local info = self._feature
	local weaponInfo = self._info
	local scroll = self._layout.vars.qilingScroll
	scroll:removeAllChildren()
	local data = i3k_db_qiling_type
	local awakeTable = {}
	for k, v in pairs(weaponInfo) do
		awakeTable[v.id] = v.awake
	end
	for k, v in ipairs(data) do
		local ui = require("ui/widgets/qilingpht")()
		ui.vars.nameImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.nameIcon))
		ui.vars.headImg:setImage(g_i3k_db.i3k_db_get_icon_path(v.headIcon))
		if not next(info) then -- 如果是个空表，那么表示可以激活
			ui.vars.rankLabel:hide()
			-- ui.vars.levelLabel:hide()
			ui.vars.mifaLabel:hide()
			scroll:addItem(ui)
		else
			if info[k] then
				ui.vars.rankLabel:setText( i3k_get_string(1106, info[k].rank, table.nums(info[k].activitePoints))) -- info[k].rank.."阶")
				-- ui.vars.levelLabel:setText(#info[k].activitePoints .."段")
				ui.vars.mifaLabel:setText(info[k].skillLevel == 0 and i3k_get_string(1108) or i3k_get_string(1107, info[k].skillLevel))
				if info[k].equipWeaponId ~= 0 then
					if awakeTable[info[k].equipWeaponId] == 1 then
						ui.vars.weaponIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing_awake[info[k].equipWeaponId].awakeWeaponIcon))
					else
						ui.vars.weaponIcon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[info[k].equipWeaponId].icon))
					end
				end
				scroll:addItem(ui)
			end
		end
	end
end

--设置佣兵的信息
function wnd_ranking_list_RoleProperty:setPetsInfo(id,info)
	self._layout.vars.item_scroll:removeAllChildren()
	local firstNode
	for i,v in ipairs(info) do
		local pht = require("ui/widgets/scxxt")()--sbxxt,zqxxt
		pht.vars.select1_btn.actType = i
		if i== 1 then
			firstNode = pht
			self._layout.vars.battle_power:setText(v.fightPower)-- 战力
			local cfg = g_i3k_db.i3k_db_get_pet_cfg(v.id).modelID
			if v.awakeUse and v.awakeUse.use and v.awakeUse.use == 1 then
				cfg = i3k_db_mercenariea_waken_property[v.id].modelID;
			end
			self:SetModule(cfg, true)
		end
		local cfg_data = g_i3k_db.i3k_db_get_pet_cfg(v.id)
		local iconid = cfg_data.icon;
		if v.awakeUse and v.awakeUse.use and v.awakeUse.use == 1 then
			iconid = i3k_db_mercenariea_waken_property[v.id].headIcon;
		end
		local name = v.name ~= "" and v.name or cfg_data.name
		pht.vars.name:setText(name)
		pht.vars.icon:setImage(g_i3k_db.i3k_db_get_head_icon_path(iconid, true))

		pht.vars.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(HAVE_PET))
		pht.vars.qlvl:setText(v.level)

		local transfer_lvl = 0
		for i,e in ipairs (i3k_db_suicong_transfer) do
			if v.level >= e.maxLvl then
				transfer_lvl = e.level
			end
		end
		local str = string.format("%s转", transfer_lvl)
		pht.vars.attribute:setText(str)
		pht.vars.slvl:setImage(g_i3k_db.i3k_db_get_icon_path(petstar_icon[v.star + 1]))--star_icon[starlvl + 1]

		if v.id<0 then --机器人
			local robot = i3k_db_arenaRobot[math.abs(v.id)]
			v.fightPower = robot.power
		end

		pht.vars.select1_btn:setTag(v.id)
		pht.vars.select1_btn:onClick(self, self.checkRoleInfo, {fightPower =v.fightPower,index =petPower_rank, awakeUse = v.awakeUse})
		self._layout.vars.item_scroll:addItem(pht)
	end
	return firstNode
end

--设置神兵的信息
function wnd_ranking_list_RoleProperty:setWeaponInfo(id,info)
	--sb_root
	self._layout.vars.item_scroll:removeAllChildren()
	local firstNode
	for i,v in ipairs(info) do
		local pht = require("ui/widgets/sbxxt")()--sbxxt,zqxxt
		pht.vars.select1_btn.actType = i
		if i== 1 then
			firstNode = pht
			self._layout.vars.battle_power:setText(v.fightPower)-- 战力
			if v.awake == 1 then
				self:SetModule(i3k_db_shen_bing_awake[v.id].awakeWeaponModle)
			else
				self:SetModule(i3k_db_shen_bing[v.id].showModuleID)
			end
		end
		pht.vars.xinfaBg:setImage(g_i3k_db.i3k_db_get_icon_path(attained_Icon))
		--i3k_log("++++----setWeaponInfo          ---+",id)----
		if v.awake == 1 then
			pht.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing_awake[v.id].awakeWeaponIcon))
			pht.vars.weaponBg:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing_awake[v.id].awakeBackground))
		else
			pht.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_shen_bing[v.id].icon))
		end
		pht.vars.name:setText(i3k_db_shen_bing[v.id].name)
		pht.vars.qlvl:setText(v.level)
		pht.vars.slvl:setImage(g_i3k_db.i3k_db_get_icon_path(weaponstar_icon[v.star + 1]))----改变星星

		if v.id<0 then --机器人
			local robot = i3k_db_arenaRobot[math.abs(v.id)]
			v.fightPower = robot.power
		end

		pht.vars.select1_btn:setTag(v.id)
		pht.vars.select1_btn:onClick(self, self.checkRoleInfo, {fightPower = v.fightPower, index = weaponPower_rank, awake = v.awake})
		self._layout.vars.item_scroll:addItem(pht)
	end
	return firstNode
end

--设置暗器的信息
function  wnd_ranking_list_RoleProperty:setHideWeaponInfo(id,info)
	self._layout.vars.item_scroll:removeAllChildren()
	for i,v in ipairs(info) do
		local pht = require("ui/widgets/qtxxt3")()
		pht.vars.select1_btn.actType = i
		local curSkinID = v.skin.curSkin
		if i == 1 then
			firstNode = pht
			self._layout.vars.battle_power:setText(v.fightPower)
			local modelID = i3k_db_anqi_base[v.id].modelID
			if curSkinID ~= 0 then
				local skinCfg = g_i3k_db.i3k_db_get_anqi_skin_by_skinID(curSkinID)
				modelID = skinCfg.skinModel
			end
			self:SetModule(modelID)
			self:showHideWeaponSkills(v.id, v.rankValue, v.aSkillLevel, v.slots, curSkinID)
		end
		local path = ""
		if curSkinID ~= 0 then
			path = g_i3k_db.i3k_db_get_icon_path(i3k_db_anqi_skin[curSkinID].listIcon)
		else
			path = g_i3k_db.i3k_db_get_icon_path(i3k_db_anqi_base[v.id].icon)
		end
		pht.vars.icon:setImage(path)
		pht.vars.name:setText(i3k_db_anqi_base[v.id].name)
		local rank = g_i3k_db.i3k_db_get_anqi_grade_by_addValue(v.id, v.rankValue)
    local img = g_i3k_db.i3k_db_get_anqi_grade_img(rank)
		pht.vars.rank_icon:setImage(g_i3k_db.i3k_db_get_icon_path(img))
		pht.vars.level:setText("等级"..v.level)

		if v.id<0 then --机器人
			local robot = i3k_db_arenaRobot[math.abs(v.id)]
			v.fightPower = robot.power
		end

		pht.vars.select1_btn:setTag(v.id)
		pht.vars.select1_btn:onClick(self, self.checkRoleInfo, {fightPower = v.fightPower,index = hideWeaponPower_rank, rankValue = v.rankValue, slots = v.slots, aSkillLevel = v.aSkillLevel, curSkin = v.skin.curSkin})
		self._layout.vars.item_scroll:addItem(pht)
	end
	return firstNode
end

--设置内甲的信息
function wnd_ranking_list_RoleProperty:setUnderWearInfo(id,info,feature)
	self._layout.vars.item_scroll:removeAllChildren()
	local firstNode
	for i,v in ipairs(info) do
		local pht = require("ui/widgets/njxxt")()
		pht.vars.select1_btn.actType = i
		local data = feature  --玩家装备，时装等数据
		if i== 1 then
			firstNode = pht
			self._layout.vars.battle_power:setText(v.fightPower)-- 战力
			self:SetUnderWearModule(data, v.id, v.rank)
		end
		pht.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(under_wear_icon[v.id]))  --有问题，路径正确，但是显示不出来
		pht.vars.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(UNDER_WEAR_BG))

		local nameStr = i3k_db_under_wear_upStage[v.id][v.rank].stageName
		local levelStr = i3k_db_under_wear_update[v.id][v.level].underWearLevel
		local stageStr = i3k_db_under_wear_upStage[v.id][v.rank].stageRank

		pht.vars.name:setText(nameStr)
		pht.vars.attribute:setText(levelStr.."级")
		pht.vars.rank:setText(stageStr.."阶")

		if v.id<0 then --机器人
			local robot = i3k_db_arenaRobot[math.abs(v.id)]
			v.fightPower = robot.power
		end

		pht.vars.select1_btn:setTag(v.id)
		pht.vars.select1_btn:onClick(self, self.checkRoleInfo, {fightPower =v.fightPower,index =underwear_rank, data = data, id = v.id, stage = v.rank, soltGroupData = v.soltGroupData, runeLangLvls = v.runeLangLvls, castIngots = v.castIngots})
		self._layout.vars.item_scroll:addItem(pht)
	end
	self:selectArmorRune(info[1].soltGroupData, info[1].runeLangLvls, info[1].castIngots)
	return firstNode
end

--设置坐骑的信息
function wnd_ranking_list_RoleProperty:setSteedInfo(id,info)
	self._layout.vars.item_scroll:removeAllChildren()
	local firstNode
	for i,v in ipairs(info) do
		local pht = require("ui/widgets/zqxxt")()
		pht.vars.select1_btn.actType = i
		local cfg_data = i3k_db_steed_huanhua[i3k_db_steed_cfg[v.id].huanhuaInitId]
		if i == 1 then
			firstNode = pht
			self._layout.vars.battle_power:setText(v.fightPower)  --战力
			self:SetSteedModule(cfg_data)  --模型
			--self:addHuanhuaIcon(self._layout.vars.steedScroll, v.showIDs, v.id)  --坐骑的幻化头像列表
		end

		pht.vars.name:setText(cfg_data.name)
		pht.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg_data.steedRankIconId, true))

		pht.vars.suicongBg:setImage(g_i3k_db.i3k_db_get_icon_path(STEED_BG))
		pht.vars.attribute:setText(v.level.."级")

		local starTable = {[1] = pht.vars.star1, [2] = pht.vars.star2, [3] = pht.vars.star3, [4] = pht.vars.star4, [5] = pht.vars.star5, [6] = pht.vars.star6, [7] = pht.vars.star7, [8] = pht.vars.star8, [9] = pht.vars.star9,}
		for i,u in ipairs(starTable) do
			u:setVisible(i <= v.star)
		end

		if v.id<0 then --机器人
			local robot = i3k_db_arenaRobot[math.abs(v.id)]
			v.fightPower = robot.power
		end

		pht.vars.select1_btn:setTag(v.id)
		pht.vars.select1_btn:onClick(self, self.checkRoleInfo, {fightPower =v.fightPower,index =steedPower_rank, cfg = cfg_data, showIDs = v.showIDs, id = v.id})
		if v.info.breakLvl <= 0 then
			pht.vars.breakImage:hide()
			pht.vars.starRoot:show()
		else
			pht.vars.breakImage:show()
			pht.vars.breakImage:setImage(g_i3k_db.i3k_db_get_icon_path(breakImage[v.info.breakLvl]))
			pht.vars.starRoot:hide()
		end
		self._layout.vars.item_scroll:addItem(pht)
	end
	return firstNode
end

function wnd_ranking_list_RoleProperty:checkRoleInfo(sender,needValue)
	self:updateSelectedListItem(sender)
	local myId = g_i3k_game_context:GetRoleId()
	local targetId = sender:getTag()
	self._layout.vars.battle_power:setText(needValue.fightPower)-- 战力
	if needValue.index == petPower_rank then
		local cfg = g_i3k_db.i3k_db_get_pet_cfg(targetId).modelID
		if needValue.awakeUse and needValue.awakeUse.use and needValue.awakeUse.use == 1 then
			cfg = i3k_db_mercenariea_waken_property[targetId].modelID;
		end
		self:SetModule(cfg, true)
	elseif needValue.index == weaponPower_rank then
		if needValue.awake == 1 then
			self:SetModule(i3k_db_shen_bing_awake[targetId].awakeWeaponModle)
		else
			self:SetModule(i3k_db_shen_bing[targetId].showModuleID)
		end
	elseif needValue.index == hideWeaponPower_rank then
		local curSkinID = needValue.curSkin
		local modelID = i3k_db_anqi_base[targetId].modelID
		if curSkinID ~= 0 then
			local skinCfg = g_i3k_db.i3k_db_get_anqi_skin_by_skinID(curSkinID)
			modelID = skinCfg.skinModel
		end
		self:SetModule(modelID)
		self:showHideWeaponSkills(targetId, needValue.rankValue, needValue.aSkillLevel, needValue.slots, curSkinID)
	elseif needValue.index == underwear_rank then
		self:SetUnderWearModule(needValue.data, needValue.id, needValue.stage)
		self:selectArmorRune(needValue.soltGroupData, needValue.runeLangLvls, needValue.castIngots)
	elseif needValue.index == steedPower_rank then
		--self:addHuanhuaIcon(self._layout.vars.steedScroll, needValue.showIDs, needValue.id)  --坐骑的幻化头像列表
		self:SetSteedModule(needValue.cfg)
	end


	--[[
	if targetId~=myId then
		if targetId > 0 then
			--i3k_sbean.query_rolebrief(targetId, { arena = true, })查询玩家信息
		else
			--i3k_sbean.query_robot(targetId, rank)查询机器人信息响应
		end
	else
		--g_i3k_game_context:ResetTestFashionData()
		--ui_set_hero_model(self._layout.vars.hero_module, i3k_game_get_player_hero())--添加模型
	end
	]]
end

--添加模型 id
function wnd_ranking_list_RoleProperty:SetModule(id, isRotation)----模型id
	local path = i3k_db_models[id].path
	local uiscale = i3k_db_models[id].uiscale
	self._layout.vars.hero_module:setSprite(path)
	self._layout.vars.hero_module:setSprSize(uiscale)
	self._layout.vars.hero_module:playAction("stand")
	if isRotation then
		self._layout.vars.hero_module:setRotation(2);
	end
end

--显示坐骑模型
function wnd_ranking_list_RoleProperty:SetSteedModule(cfg)---- 坐骑id，cfg
	local moduleID = cfg.modelId
	local mcfg = i3k_db_models[moduleID]
	if mcfg then
		self._layout.vars.hero_module:setSprite(mcfg.path)
		self._layout.vars.hero_module:setSprSize((mcfg.uiscale)*1.3)
		self._layout.vars.hero_module:playAction("show")

		if cfg.modelRotation ~= 0 then
			self._layout.vars.hero_module:setRotation(cfg.modelRotation - 0.5)
		end
	end
end

--添加幻化Icon
function wnd_ranking_list_RoleProperty:addHuanhuaIcon(root, showIDs, id)
	local showIDs = showIDs
	local huanhuaInitId = i3k_db_steed_cfg[id].huanhuaInitId
	showIDs[huanhuaInitId] = true  --初始幻化坐骑

	local tempTb = {}  --根据坐骑幻化id排序
	for n in pairs(showIDs) do
		table.insert(tempTb, n)
	end
	table.sort(tempTb)

	root:removeAllChildren()
	for i,v in ipairs(tempTb) do
		local cfg = i3k_db_steed_huanhua[v]
		local widget = require("ui/widgets/qtxxt")()
		widget.vars.huanhuaIcon:setImage(g_i3k_db.i3k_db_get_icon_path(cfg.steedRankIconId))
		widget.vars.huanhuaBtn:onClick(self, self.onClickSteedIcon, cfg)
		root:addItem(widget)
	end
end

--点击坐骑图标
function wnd_ranking_list_RoleProperty:onClickSteedIcon(sender, cfg)
	self:SetSteedModule(cfg)
end

--显示内甲模型
function wnd_ranking_list_RoleProperty:SetUnderWearModule(Data, id, stage)---- 内甲模型id，内甲id， 段位rank
	if Data then
		local playerData = Data.overview
		local data = {}
		for k,v in pairs(Data.wear.wearEquips) do
			data[k] = v.equip.id
		end
		local modelTable = {}
		modelTable.node = self._layout.vars.hero_module
		modelTable.id = playerData.type
		modelTable.bwType = playerData.bwType
		modelTable.gender = playerData.gender
		modelTable.face = Data.wear.face
		modelTable.hair = Data.wear.hair
		modelTable.equips = data
		modelTable.fashions = Data.wear.curFashions
		modelTable.isshow = Data.wear.showFashionTypes
		modelTable.equipparts = Data.wear.wearParts
		modelTable.armor = Data.wear.armor
		modelTable.weaponSoulShow = nil
		modelTable.isEffectFashion = nil
		modelTable.soaringDisplay = Data.wear.soaringDisplay
		self:createModelWithCfg(modelTable)
		self:changeArmorEffect(self._layout.vars.hero_module, id, stage)
	end
end

function wnd_ranking_list_RoleProperty:onSkinBtn(sender)
	local data = {id = self._id, info = self._info, showIDs = self._feature, masters = self._masters, steedSpirit = self._steedSpirit, steedEquip = self._steedEquip, roleOverview = self._roleOverview}
	g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleSteedSkin)
	g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleSteedSkin, data)
	self:onCloseUI()
end

function wnd_ranking_list_RoleProperty:onSteedFightBtn(sender)
	if next(self._masters) == nil then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1305))
	end
	local data = {id = self._id, info = self._info, showIDs = self._feature, masters = self._masters, steedSpirit = self._steedSpirit, steedEquip = self._steedEquip, roleOverview = self._roleOverview}
	g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleSteedFight)
	g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleSteedFight, data)
	self:onCloseUI()
end

function wnd_ranking_list_RoleProperty:onSteedSpiritBtn(sender)
	local data = {id = self._id, info = self._info, showIDs = self._feature, masters = self._masters, steedSpirit = self._steedSpirit, steedEquip = self._steedEquip, roleOverview = self._roleOverview}
	g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleSteedSpirit)
	g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleSteedSpirit, data)
	self:onCloseUI()
end

function wnd_ranking_list_RoleProperty:onSteedEquipBtn(sender)
	local data = {id = self._id, info = self._info, showIDs = self._feature, masters = self._masters, steedSpirit = self._steedSpirit, steedEquip = self._steedEquip, roleOverview = self._roleOverview}

	local curClothes = self._steedEquip.curClothes
	local allSuits = self._steedEquip.allSuits
	local isOpenUI = table.nums(curClothes) > 0 or table.nums(allSuits) > 0

	if isOpenUI then
		g_i3k_ui_mgr:OpenUI(eUIID_RankListRoleSteedEquip)
		g_i3k_ui_mgr:RefreshUI(eUIID_RankListRoleSteedEquip, data)
		self:onCloseUI()
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(1643))
	end
end

function wnd_ranking_list_RoleProperty:showHideWeaponSkills(wid, rankValue, aSkillLevel, slots, curSkinID)
	local widgets = self._layout.vars
	local skillID = i3k_db_anqi_base[wid].skillID
	local skill_data = i3k_db_skills[skillID]
	local gradeCfg = i3k_db_anqi_grade[wid]
	local addlevel = gradeCfg[rankValue].skillAddLevel
	widgets.anqiSkills:show()
	local path = ""
	
	if curSkinID ~= 0 then
		path = g_i3k_db.i3k_db_get_icon_path(i3k_db_anqi_skin[curSkinID].skillIcon)
	else
		path = g_i3k_db.i3k_db_get_skill_icon_path(skillID)
	end
	
	widgets.aSkill_icon:setImage(path)
	widgets.aSkill_lvl:setText(aSkillLevel + addlevel .."级")
	local slotCount = g_i3k_db.i3k_db_get_anqi_slotCount_by_addValue(wid, rankValue)
	local slotCfg = i3k_db_anqi_base[wid].gradeList
	for i = 1,3 do
		widgets["skillLock"..i]:setVisible(slotCount < i)
		widgets["skill"..i.."_lvl"]:setVisible(slots[i].id ~= 0)
		local gradeCfg = g_i3k_db.i3k_db_get_anqi_slot_cfg(slotCfg[i])
		local skillIconImg = slots[i].id == 0 and gradeCfg.cover or g_i3k_db.i3k_db_get_anqi_possitive_skill_icon(wid, slots[i].id)
		widgets["skill"..i.."_icon"]:setImage(g_i3k_db.i3k_db_get_icon_path(skillIconImg))
		widgets["skill"..i.."_bg"]:setImage(g_i3k_db.i3k_db_get_icon_path(gradeCfg.borderImage))
		widgets["skill"..i.."_lvl"]:setText(slots[i].level.."级")
	end
end

function wnd_create(layout)
	local wnd = wnd_ranking_list_RoleProperty.new();
	wnd:create(layout);
	return wnd;
end
