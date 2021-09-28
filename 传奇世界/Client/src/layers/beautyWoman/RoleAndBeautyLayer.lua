local MainLayer = class("MainLayer", function() return cc.Layer:create() end )
function MainLayer:ctor(otherRoleData,focus_index,param)
	self.bg, self.closeBtn= createBgSprite(self,game.getStrByKey("title_role"),nil,true,nil,otherRoleData)
	--self.closeBtn:removeFromParent()
	--self.closeBtn = createTouchItem(self.bg, "res/common/13.png", cc.p(917,598), )
	if G_TUTO_NODE then
		G_TUTO_NODE:setTouchNode(self.closeBtn, TOUCH_ROLE_CLOSE)
	end

	local tab_control = {}
	local posx,posy = 660,595
	local layers = {require("src/layers/role/roleLayer")}
	if otherRoleData then
		layers = {require("src/layers/role/browse")}
	end
	self.otherRoleData = otherRoleData
	self.select_layers = {}

	local hasBeauty = function() 
		local ret = nil
		if self.otherRoleData then
			if self.beauty_info then
				if self.beauty_info.beauty_id and self.beauty_info.beauty_id > 0 then
					ret = 1
				elseif self.beauty_info.zhj.id and self.beauty_info.zhj.id > 0 then
					ret = 2
				elseif self.beauty_info.zhr.id and self.beauty_info.zhr.id > 0 then
					ret = 3	
				end
			end
		else
			ret =  G_NFTRIGGER_NODE:isFuncOn(NF_BEAUTY)
		end
		return false--ret
	end
	local mfoucs_index = focus_index or 1
	local sub_index = mfoucs_index%10
	mfoucs_index = math.ceil(mfoucs_index/10)
	local menuFunc = function(tag,sender)
		if tag and sender then
			AudioEnginer.playTouchPointEffect()
		end
		--return noticeAdvance(function()
			local icon = tolua.cast(self.bg:getChildByTag(2),"cc.Sprite")
			local name = tolua.cast(self.bg:getChildByTag(1),"cc.Sprite")
			-- if tag == 2 then
			-- 	if (not otherRoleData) and (not hasBeauty() ) then
			-- 		MessageBox(string.format(game.getStrByKey("wr_beauty_noBeautyTip"),getConfigItemByKey("NewFunctionCfg", "q_ID", 15).q_level), "")
			-- 		return true
			-- 	elseif otherRoleData and (not hasBeauty()) then
			-- 		MessageBox(game.getStrByKey("wr_wing_roleNoBeautyTip"), "")
			-- 		return true
			-- 	end
			-- else
			-- end

			if self.select_index and self.select_index ~= tag then
	            tab_control[self.select_index].menu_item:unselected()
			end
			if tag and tab_control[tag] then
				tab_control[tag].menu_item:selected()
			end
			self.select_index = tag
			for k,v in pairs(self.select_layers) do
				if tag == k then
					v:setVisible(true)
				else
					removeFromParent(v)
					self.select_layers[k] = nil
				end
			end
			--dump(param)
			if not self.select_layers[tag] then
				if tag == 1 then
					self.select_layers[tag] = layers[tag].new(self.bg,self.info,sub_index,param)
				else
					self.select_layers[tag] = layers[tag].new(self.bg,self.beauty_info,self.param,sub_index,param)
				end
			end
			sub_index = 1
			--end)
	end
	local menu = cc.Menu:create()
	self.bg:addChild(menu)
	menu:setPosition(0,0)
	for i=1,2 do
		tab_control[i] = {}
		tab_control[i].menu_item = cc.MenuItemImage:create("res/component/TabControl/1.png","res/component/TabControl/2.png")
		tab_control[i].menu_item:setPosition(cc.p(posx,posy))
		--tab_control[i].callback = menuFunc
		menu:addChild(tab_control[i].menu_item,1,i)
		tab_control[i].menu_item:registerScriptTapHandler(menuFunc)
		posx = posx + 140
		if i == 2 then
			G_TUTO_NODE:setTouchNode(tab_control[i].menu_item, TOUCH_ROLE_BEAUTY)
		end
	end
	self.tab_menu = menu--creatTabControlMenu(self.bg,tab_control,mfoucs_index)
	self.tab_menu:setVisible(false)
	self.select_index = mfoucs_index
	
	SwallowTouches(self)
	if otherRoleData then
		self:setVisible(false)
		--g_msgHandlerInst:sendNetDataByFmt(FRAME_CS_LOOKUP_DATA, "iSi", G_ROLE_MAIN.obj_id, otherRoleData.role or MRoleStruct:getAttr(ROLE_NAME), otherRoleData.noTips or 1)
		g_msgHandlerInst:sendNetDataByTable(FRAME_CS_LOOKUP_DATA, "FrameLookUpProtocol", {name=otherRoleData.role or MRoleStruct:getAttr(ROLE_NAME),notice=otherRoleData.noTips or 1})
		g_msgHandlerInst:registerMsgHandler(FRAME_SC_LOOKUP_DATARET, function(buff)
			dump("+++++++++++", "查看资料返回")
			
			local result, roleData = self:ParseRoleData(buff)
			if not result then
				TIPS({ type = 1  , str = "该角色已被删除" })
				removeFromParent(self)
				return
			end
			self:setVisible(true)
			
			self.info = roleData
			self.info.server = roleData.servername
			--dump(self.info)
			
			local beauty_info = self:ParseBeautyData(buff)
			beauty_info.minAttack = roleData.minAttack
			beauty_info.maxAttack = roleData.maxAttack
			self.beauty_info = beauty_info
			
			if not hasBeauty() then
				self.tab_menu:setVisible(false)
				menuFunc(1)
			else
				self.tab_menu:setVisible(true)
				menuFunc(mfoucs_index)
			end
		end)
		addNetLoading(FRAME_CS_LOOKUP_DATA, FRAME_SC_LOOKUP_DATARET)
		self:registerScriptHandler(function(event)
			if event == "exit" then
				g_msgHandlerInst:registerMsgHandler(FRAME_SC_LOOKUP_DATARET, nil)
			end
		end)
	else
		self.tab_menu:setVisible(hasBeauty())
		menuFunc(mfoucs_index)
		--self:addCurrency()
		self:registerScriptHandler(function(event)
			if event == "enter" then
				if G_MAINSCENE and G_MAINSCENE.tipLayer then  --防止z过高挡住界面
					G_MAINSCENE.tipLayer:removeAllChildren()
					require("src/layers/tuto/AutoConfigNode").showList = {}
					G_SETPOSTEMPE = {}
				end
			elseif event == "exit" then
				if G_MAINSCENE and G_MAINSCENE.tipLayer then
					G_MAINSCENE.tipLayer:removeAllChildren()
					require("src/layers/tuto/AutoConfigNode").showList = {}
					G_SETPOSTEMPE = {}
				end
			end
		end)
	end

end
-- 货币显示
function MainLayer:addCurrency()
	local buildCurrencyArea = function()
		local Mcurrency = require "src/functional/currency"
		return Mnode.combineNode(
		{
			nodes = {
				[1] = Mnode.combineNode(
				{
					nodes = {
						[1] = Mcurrency.new(
						{
							cate = PLAYER_INGOT,
							--bg = "res/common/19.png",
							color = MColor.yellow,
						}),
						
						[2] = Mcurrency.new(
						{
							cate = PLAYER_BINDINGOT,
							--bg = "res/common/19.png",
							color = MColor.yellow,
						})

					},
					
					margins = 5,
				}),
				
				[2] = Mnode.combineNode(
				{
					nodes = {
						[1] = Mcurrency.new(
						{
							cate = PLAYER_MONEY,
							--bg = "res/common/19.png",
							color = MColor.yellow,
						}),
					},
					
					margins = 5,
				}),
			},
			
			ori = "|",
			align = "l",
			margins = 0,
		})
	end

	Mnode.addChild(
	{
		parent = self.bg,
		child = buildCurrencyArea(),
		anchor = cc.p(0, 0.5),
		pos = cc.p(20, 605),
	})
end

-----------------------------------------------------------------------
function MainLayer:ParseBeautyData()
	local ret = {}

	-- 解析战甲技能数据
	ret.zhj = {}
	ret.zhj.id = 0 --buff:popInt()
	local zhj = {}
	local num = 0 --ret.zhj.id ~= 0 and buff:popChar() or 0
	ret.zhj.skillCount = num
	ret.zhj.skillTab = zhj
	for i = 1, num do
		zhj[#zhj + 1] = buff:popInt()
	end
	
	-- 解析战刃技能数据
	ret.zhr = {}
	ret.zhr.id = 0 -- buff:popInt()
	local zhr = {}
	local num = 0 --ret.zhr.id ~= 0 and buff:popChar() or 0
	ret.zhr.skillCount = num
	ret.zhr.skillTab = zhr
	for i = 1, num do
		zhr[#zhr + 1] = buff:popInt()
	end
	
	-- 解析翡翠数据
	local fc = {}
	ret.fcTab = fc
	local num = 0 -- buff:popChar()
	for i = 1, num do
		fc[#fc + 1] = {buff:popInt(),buff:popShort()}
	end
	
	-- 解析美人技能数据	
	local beautyskill = {}
	ret.skillTab = beautyskill
	ret.beauty_id = 0
	ret.remainTime = 0
	local num = 0
	ret.skillCount = num
	for i = 1, num do
		beautyskill[#beautyskill + 1] = 0
	end
	
	if ret.zhj.id > 0 or ret.zhr.id > 0 then
		ret.beauty_id = 1
	end
	
	return ret
end
-----------------------------------------------------------------------
function MainLayer:ParseRoleData(buff)
	local t = g_msgHandlerInst:convertBufferToTable("FrameLookUpRetProtocol", buff)
	--dump(t, "查看玩家资料返回")
	
	if t.delete == 0 then
		return false, nil
	end
	
	local ret = {}
	
	-- 静态ID
	local DBID = t.id
	ret.DBID = DBID
	--dump(DBID, "DBID")
	-- 角色名
	ret[ROLE_NAME] = t.name
	--dump(ret[ROLE_NAME], "ROLE_NAME")
	-- 区名
	ret.servername = t.serverName
	--dump(ret.servername, "servername")
	-- 帮会名字
	ret[PLAYER_FACTIONNAME] = t.factionName
	--dump(ret[PLAYER_FACTIONNAME], "PLAYER_FACTIONNAME")
	-- 角色职业
	local school = t.school
	ret[ROLE_SCHOOL] = school
	--dump(school, "school")
	-- 角色性别
	ret[PLAYER_SEX] = t.sex
	--dump(ret[PLAYER_SEX], "PLAYER_SEX")
	-- 角色等级
	ret[ROLE_LEVEL] = t.level
	--dump(ret[ROLE_LEVEL], "ROLE_LEVEL")
	---------------------------------------------
	ret[ROLE_MIN_AT] = t.atmin; ret[ROLE_MAX_AT] = t.atmax -- 物理攻击
	ret[ROLE_MIN_MT] = t.mtmin; ret[ROLE_MAX_MT] = t.mtmax -- 魔法攻击
	ret[ROLE_MIN_DT] = t.dtmin; ret[ROLE_MAX_DT] = t.dtmax -- 道术攻击
	ret[ROLE_MIN_DF] = t.dfmin; ret[ROLE_MAX_DF] = t.dfmax -- 物理防御
	ret[ROLE_MIN_MF] = t.mfmin; ret[ROLE_MAX_MF] = t.mfmax -- 魔法防御
	
	-- 缓存职业攻击
	if school == Mconvertor.eWarrior then -- 战士
		ret.minAttack = ret[ROLE_MIN_AT]
		ret.maxAttack = ret[ROLE_MAX_AT]
	elseif school == Mconvertor.eEnchanter then -- 法师
		ret.minAttack = ret[ROLE_MIN_MT]
		ret.maxAttack = ret[ROLE_MAX_MT]
	elseif school == Mconvertor.eTaoist then -- 道士
		ret.minAttack = ret[ROLE_MIN_DT]
		ret.maxAttack = ret[ROLE_MAX_DT]
	end
	---------------------------------------------
	-- HP
	ret[ROLE_HP] = t.hp
	ret[ROLE_MAX_HP] = t.hpmax
	--dump(t.hp, "HP")
	--dump(t.hpmax, "maxHP")
	-- MP
	ret[ROLE_MP] = t.mp
	ret[ROLE_MAX_MP] = t.mpmax
	--dump(t.mp, "MP")
	--dump(t.mpmax, "maxMP")
	-- 升级经验
	ret[PLAYER_XP] = t.exp
	--dump(ret[PLAYER_XP], "PLAYER_XP")
	ret[PLAYER_NEXT_XP] = t.nextxp
	--dump(ret[PLAYER_NEXT_XP], "PLAYER_NEXT_XP")
	-- 战斗力
	ret[PLAYER_BATTLE] = t.battle
	--dump(ret[PLAYER_BATTLE], "PLAYER_BATTLE")
	-- 幸运值
	ret[PLAYER_LUCK] = t.luck
	--dump(ret[PLAYER_LUCK], "PLAYER_LUCK")
	-- 命中
	ret[ROLE_HIT] = t.hit
	--dump(ret[ROLE_HIT], "ROLE_HIT")
	-- 闪避
	ret[ROLE_DODGE] = t.dodge
	--dump(ret[ROLE_DODGE], "ROLE_DODGE")
	-- PK值
	ret[PLAYER_PK] = t.pk
	--dump(ret[PLAYER_PK], "PLAYER_PK")
	-- 移动速度
	ret[ROLE_MOVE_SPEED] = t.moveSpeed
	--dump(ret[ROLE_MOVE_SPEED], "ROLE_MOVE_SPEED")
	---------------------------------------------
	-- 被送花总值
	ret[PLAYER_GLAMOUR] = t.glamour
	--dump(ret[PLAYER_GLAMOUR], "PLAYER_GLAMOUR")
	---------------------------------------------
	-- 暴击
	ret[ROLE_CRIT] = t.crit
	--dump(ret[ROLE_CRIT], "ROLE_CRIT")
	-- 韧性
	ret[ROLE_TENACITY] = t.tenacity
	--dump(ret[ROLE_TENACITY], "ROLE_TENACITY")
	---------------------------------------------
	-- 免伤
	ret[PLAYER_PROJECT] = t.project
	--dump(ret[PLAYER_PROJECT], "PLAYER_PROJECT")
	
	-- 穿透
	ret[PLAYER_PROJECT_DEF] = t.projectDef
	--dump(ret[PLAYER_PROJECT_DEF], "PLAYER_PROJECT_DEF")
	---------------------------------------------
	-- 解析装备数据
	local MPackManager = require "src/layers/bag/PackManager"
	local equipList = {}
	local eps = t.groups
	------------------------
	local packId = eps.id
	--dump(packId, "packId")
	
	local numOfGirdOpened = eps.capacity
	--dump(numOfGirdOpened, "numOfGirdOpened")
	
	local items = eps.items
	local numOfEquipped = #items -- 已经装备了的装备数量
	--dump(numOfEquipped, "numOfEquipped")
	for i = 1, numOfEquipped do
		local cur = items[i]
		local gridId = cur.slot
		--dump(gridId, "gridId")
		local grid = MPackManager:convertPBItemToGrid(cur)
		equipList[gridId] = grid
	end
	ret.equipList = equipList
	--dump(equipList, "equipList")
	---------------------------------------------
	
	-- 解析坐骑数据
	-- 坐骑ID
	local zuoqi = protobuf.decode("RideClientProtocol", t.rides)
	zuoqi = zuoqi.ride
	
	local horse = {}
	ret.horse = horse
	if zuoqi ~= 0 then
		horse[1] = zuoqi
	end
	--[[
	local horseNum = #zuoqi
	for i=1,horseNum do
		horse[i] = zuoqi[i]
	end
	]]
	ret[PLAYER_EQUIP_RIDE] = horse[1] or 0
	
	-- 解析光翼数据
	-- 翅膀ID
	local chibang = protobuf.decode("WingClientDataProtocol", t.wings)
	
	local wing = {}
	ret.wing = wing
	local wing_id = chibang.wingID or 0
	ret[PLAYER_EQUIP_WING] = wing_id
	--dump(ret[PLAYER_EQUIP_WING], "PLAYER_EQUIP_WING")
	ret.wing.id = wing_id
	if wing_id ~= 0 then
		local chibang_skills = chibang.skill
		local num = #chibang_skills
		dump(num, "wing_skill_num")
		ret.wing.skillTab = {}
		for i = 1, num do
			local cur = chibang_skills[i]
			local skillId = cur.pos
			local skillLevel = cur.level
			local strength = cur.strength
			ret.wing.skillTab[skillId] = {skillId=skillId, skillLevel=skillLevel, strength=strength}
		end
	end
	---------------------------------------------
	--dump(wing, "wing")
	--dump(horse, "horse")
	--dump(ret, "ret")
	return true, ret
end

return MainLayer