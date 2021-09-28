-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_spriteFragmentBag = i3k_class("wnd_spriteFragmentBag", ui.wnd_base)

local WIGETS_TITLE = "ui/widgets/gdyljmt"
local WIGETS_FRAG  = "ui/widgets/gdyljmt1"
local WIGETS_SKILL = "ui/widgets/gdyljmt2"

--开始位置和结束位置
local startPos
local endPos
local dis --距离
local speed --速度 
local time --时间

local selfData = {
	[1] = {},
	[2] = { _children ={ [1] = {}, [2] = {}, [3] = {}, [4] = {},[5] = {} } },
	[3] = {	_children ={ [1] = {} } }
}

function wnd_spriteFragmentBag:ctor()
	self._monsterModelID, self._monsterID = g_i3k_db.i3k_db_get_random_monsterModelID()
	self._listShowIndex = 1
	self._listSwitch = {}
	self._curRewardFragmentID = 0		--当前奖励计算的碎片ID
	self._curRewardFragmentCount = 0  	--当前奖励计算的碎片数量
	self._curRareFragmentCount = 0 		--当前稀有碎片数量
	self._rewardList = {}
	self._isInCD = 0
	self._cdSwitch = false
	self._curTabIndex = 1
	self._fragmentData = g_i3k_game_context:GetSpiritsData()
end

function wnd_spriteFragmentBag:configure()
	local widgets = self._layout.vars
	widgets.close_btn:onClick(self,self.onCloseUI)
	
	--元灵
	self.yulingTime = widgets.yulingTime
	self.canNot = widgets.canNot
	
	self.noFragment 		= widgets.noFragment  
	self.noFragment:setText(i3k_get_string(18591))
	self.monsterDesc 		= widgets.monsterDesc --怪物介绍
	self.monsterModel 		= widgets.monsterModel
	self.fragmentList 		= widgets.fragmentList
	self.skillList			= widgets.skillList
	self.revolve = widgets.revolve
	self.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
	--炼化
	self.lianHuaBagList		= widgets.lianHuaBagList
	self.noFragment2 		= widgets.noFragment2  
	self.noFragment2:setText(i3k_get_string(18591))
	widgets.lianHuaTitle:setText(i3k_get_string(18595))
	self.cdTime 			= widgets.cdTime
	self.rewardList			= widgets.rewardList
	self.lianHuaTimes		= widgets.lianHuaTimes
	self.lianHuaDesc		= widgets.lianHuaDesc
	widgets.tipBtn:onClick(self, self.onTipBtnClick)
	widgets.exchangeBtn:onClick(self, self.onExchangeBtnClick)
	widgets.getLianHuaBtn:onClick(self, self.onGetLianHuaBtnClick)
	widgets.helpBtn:onClick(self, self.onHelpBtnClick)
	widgets.randomModelBtn:onClick(self, self.onRandomBtnClick)

	self.bagWigets = {
		{ scroll = widgets.fragmentList, noFragment = widgets.noFragment },
		{ scroll = widgets.lianHuaBagList, noFragment = widgets.noFragment2 }
	}

	self.tabs = {
		{ btn = widgets.yuanLingBtn , ui = widgets.fragmentRoot, func = self.showFragmentBag},
		{ btn = widgets.lianHuaBtn , ui = widgets.lianHuaRoot, func = self.showLianhuaBag}
	}

	local textColor = { -- 页签文本颜色 选择和为被选中状态
		{"ffbc541e", "fffdf2ba"},
		{"ffe3bc8d", "ff653919"}, -- 主色和描边
	}
	for i,v in ipairs(self.tabs) do
		v.btn:onClick(
            self,
            function()
                self:onTabBtnClick(i)
            end
        )
        v.btn:setTitleTextColor(textColor)
	end
end

function wnd_spriteFragmentBag:onRotateBtn(sender,eventType)
	if eventType == ccui.TouchEventType.began then
		self.rotate = self.monsterModel:getRotation()
		self.monsterModel:setRotation(self.rotate.y)
		startTime = i3k_game_get_time()
		startPos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
	else
		endPos = sender:getParent():convertToNodeSpace(g_i3k_ui_mgr:GetMousePos())
		endTime = i3k_game_get_time()
		self:getRotate(isNotBreakCurAct)
	end
end

function wnd_spriteFragmentBag:onRandomBtnClick(sender)
	self._monsterModelID, self._monsterID = g_i3k_db.i3k_db_get_random_monsterModelID()
	self:showMonsterModel(self._monsterModelID)
end

function wnd_spriteFragmentBag:getRotate()--是否屏蔽打断当前动作
	local btnPos = self.revolve:getPosition()
	local btnContentSize = self.revolve:getContentSize()
	local minPosX = btnPos.x - btnContentSize.width / 2
	local maxPosX = btnPos.x + btnContentSize.width / 2
	if endPos.x < minPosX then
		endPos.x = minPosX
	elseif endPos.x > maxPosX then
		endPos.x = maxPosX
	end
	dis = endPos.x - startPos.x
	time = endTime - startTime
	speed = dis / time
	local angel = self.rotate.y + math.rad(-dis)
	self.monsterModel:setRotation(angel)
end


function wnd_spriteFragmentBag:onTipBtnClick()
	g_i3k_ui_mgr:OpenUI(eUIID_SpiritRefreshTip)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritRefreshTip)
end

function wnd_spriteFragmentBag:onHelpBtnClick()
	g_i3k_ui_mgr:OpenUI(eUIID_SpiritTip)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpiritTip)
end

function wnd_spriteFragmentBag:onTabBtnClick(i)
	self:showDataByIndex(i)
end

function wnd_spriteFragmentBag:onUpdate()
	self._isInCD = g_i3k_game_context:GetExchangeIsInCD()
	if self._isInCD > 0 then
		self.cdTime:setText(i3k_get_string(18604,g_i3k_get_HourAndMin(self._isInCD)))
		if not self._cdSwitch then
			self:showLianhuaBag()
			self:SetExchangeDataDesc()
		end
		self._cdSwitch = true
	else
		if self._cdSwitch then
			self._cdSwitch = false
			self:showLianhuaBag()
		end
	end
end

function wnd_spriteFragmentBag:SetExchangeDataDesc()
	local state = g_i3k_game_context:GetSpiritsIsExchangeComplete()
	local text = ""
	if state == g_SPIRIT_STATE_NORMAL then
		text = i3k_get_string(18605)--无交换信息
	elseif state == g_SPIRIT_STATE_COMPLETE then
		text = i3k_get_string(18606)--交换成功
	elseif state == g_SPIRIT_STATE_FAIL then
		text = i3k_get_string(18607)--交换失败
	end
	self.cdTime:setText(i3k_get_string(18604, text))
end

--页签界面控制
function wnd_spriteFragmentBag:showDataByIndex(index)
	self._curTabIndex = index
	for i, v in ipairs(self.tabs) do
        if i == index then
            v.btn:stateToPressed()
            v.ui:setVisible(true)
            v.func(self)
        else
            v.btn:stateToNormal()
            v.ui:setVisible(false)
        end
    end
end 

--加载怪物模型
function wnd_spriteFragmentBag:showMonsterModel(id)
	ui_set_hero_model(self.monsterModel, id)
	self._layout.vars.monsterName:setText(i3k_db_monsters[self._monsterID].name)
	self:showMonsterSkill()
end

function wnd_spriteFragmentBag:showMonsterSkill()
	self.skillList:removeAllChildren()
	local skillList = i3k_db_catch_spirit_monster[self._monsterID].skillList
	local idList = i3k_db_catch_spirit_skills[g_i3k_game_context:GetRoleType()]
	for i,v in ipairs(skillList) do
		local node = require(WIGETS_SKILL)()
		node.vars.skillIcon:setImage(g_i3k_db.i3k_db_get_skill_icon_path(idList.baseSkills[v]))
		if i == #skillList then
			node.vars.jiantou:setVisible(false)
		end
		self.skillList:addItem(node)
	end
end

function wnd_spriteFragmentBag:refresh()
	self:initListState()
	self:showDataByIndex(self._curTabIndex)
	self:showMonsterModel(self._monsterModelID)
end

--初始化碎片列表状态
function wnd_spriteFragmentBag:initListState()
	local bagData = g_i3k_game_context:GetSpiritsBagData()
	for i,v in ipairs(bagData) do
		self._listSwitch[i] = false
	end
end

--加载背包里元灵碎片
function wnd_spriteFragmentBag:updateFragmentsBag()
	local logicListNum = 0
	local line = 0
	local widgets = self.bagWigets[self._curTabIndex]
	self._isInCD = g_i3k_game_context:GetExchangeIsInCD()
	widgets.scroll:removeAllChildren()
	widgets.noFragment:setVisible(table.nums(self._fragmentData.spirits) == 0)
	local bagData = g_i3k_game_context:GetSpiritsBagData()
	for i,v in ipairs(bagData) do
		local title = require(WIGETS_TITLE)()
		local clickData = {index = i, addNum = line}
		title.vars.btn:onClick(self, self.updateSelectedListItem, clickData)
		title.vars.name:setText(i3k_db_catch_spirit_fragment[v.id].name)
		widgets.scroll:addItem(title)
		title.vars.down:setVisible(not self._listSwitch[i])
		title.vars.up:setVisible(self._listSwitch[i])
		title.vars.suo:setVisible(self._isInCD > 0 and self._fragmentData.costId == v.id)
		if self._listSwitch[i] then
			widgets.scroll:addItemAndChild(WIGETS_FRAG, 4, v.count)
			local curIndex = 0
			for j = 1, v.count do
				curIndex = i + j + logicListNum
				local node = widgets.scroll.child[curIndex]
				local cData = { node = node , id = v.id }
				if self._curTabIndex == 1 then
					node.vars.btn:onClick(self, self.onFragmentClick, cData)
				end
				node.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(i3k_db_catch_spirit_fragment[v.id].iconId)) 
				node.vars.num:setVisible(false)
				node.vars.select:setVisible(false)
			end
			logicListNum = logicListNum + v.count
			line = line + math.modf( v.count / 4 ) + 1
		end
	end
end


--元灵碎片
function wnd_spriteFragmentBag:showFragmentBag()
	self:updateFragmentsBag()
	local curNum = g_i3k_game_context:GetSpiritsFragmentNum()
	self.yulingTime:setText(i3k_get_string(18592,g_i3k_game_context:GetSpiritsFragmentNum(), i3k_db_catch_spirit_base.spiritFragment.bagMaxCount))	--背包碎片个数
	self.canNot:setText(i3k_get_string(18593, g_i3k_game_context:GetSpiritsData().daySummonedTimes, i3k_db_catch_spirit_base.dungeon.callTimes))
end

--元灵炼化
function wnd_spriteFragmentBag:showLianhuaBag()
	self:updateFragmentsBag()
	self:updateFragmentLianHuaTimes()
	self:showLianHuaReward()
	self:SetExchangeDataDesc()
end

--炼化奖励
function wnd_spriteFragmentBag:showLianHuaReward()
	self._curRewardFragmentID = 0
	 self._curRewardFragmentCount = 0
	local _,rnum,_,normalList,rareList = g_i3k_game_context:GetSpiritsBagData()
	self._curRareFragmentCount = rnum
	if #normalList > 0 then
		self._curRewardFragmentID = normalList[1].id
		self._curRewardFragmentCount = normalList[1].count + self._curRareFragmentCount
	elseif #rareList > 0 then
		self._curRewardFragmentID = rareList[1].id
		self._curRewardFragmentCount = self._curRareFragmentCount
	end
	local isOnlyShow = false
	self._rewardList, isOnlyShow= g_i3k_db.i3k_db_get_spiritsFragment_rewardLists(self._curRewardFragmentID, self._curRewardFragmentCount)
	self:setFragmentRewardData(self.rewardList, self._rewardList, isOnlyShow)
	self:showLianHuaDescByState()
	if isOnlyShow then
		self.lianHuaDesc:setText(i3k_get_string(18599))
	end
end

--奖励标题内容
function wnd_spriteFragmentBag:showLianHuaDescByState()
	local text = ""
	local _,rareNum,_,normalList,rareList = g_i3k_game_context:GetSpiritsBagData()
	--普通碎片显示
	if #normalList > 0 then
		text = i3k_get_string(18597,i3k_db_catch_spirit_fragment[normalList[1].id].name, normalList[1].count)
	end
	--稀有碎片显示
	if rareNum > 0 then
		text = text.." "..i3k_get_string(18598,rareNum)
	end
	self.lianHuaDesc:setText(i3k_get_string(18596, text))
end

function wnd_spriteFragmentBag:updateFragmentLianHuaTimes()
	local count = g_i3k_game_context:GetSpiritsData().artificeTimes
	self.lianHuaTimes:setText(i3k_get_string(18594, count)) --可炼化次数 
end

function wnd_spriteFragmentBag:setFragmentRewardData(scroll, rList, isOnlyShow)
	scroll:removeAllChildren()
	for i,v in ipairs(rList) do
		local node = require(WIGETS_FRAG)()
		node.vars.bg:setImage(g_i3k_db.i3k_db_get_common_item_rank_frame_icon_path(v.id))
		node.vars.icon:setImage(g_i3k_db.i3k_db_get_common_item_icon_path(v.id,i3k_game_context:IsFemaleRole()))
		--特殊碎片数量奖励加成
		if v.id == i3k_db_catch_spirit_base.spiritFragment.extraItemId then
			local _,rnum,_,_,_ = g_i3k_game_context:GetSpiritsBagData()
			v.count = v.count + i3k_db_catch_spirit_base.spiritFragment.extraItemCount * self._curRareFragmentCount
		end
		node.vars.num:setVisible(not isOnlyShow)
		if v.id == g_BASE_ITEM_EXP then
			node.vars.num:setText("x"..i3k_get_num_to_show(v.count))
		else
			node.vars.num:setText("x"..v.count)
		end
		node.vars.select:setVisible(false)
		node.vars.btn:onClick(self,self.ShowItemTip, v.id) 
		scroll:addItem(node)
	end
end


function wnd_spriteFragmentBag:updateSelectedListItem(sender, data)
	self._listShowIndex = data.index
	self._listSwitch[data.index] = not self._listSwitch[data.index]
	if self._curTabIndex == 1 then
		self:showFragmentBag()
		self.fragmentList:jumpToChildWithIndex(data.index + data.addNum)
	else
		self:showLianhuaBag()
		self.lianHuaBagList:jumpToChildWithIndex(data.index + data.addNum)
	end
end
function wnd_spriteFragmentBag:onFragmentClick(sender, data)
	for k,v in pairs(i3k_db_catch_spirit_monster) do
		if v.fragmentId == data.id then
			self._monsterID = k
			break
		end
	end
	self:showMonsterModel(i3k_db_monsters[self._monsterID].modelID)
end

function wnd_spriteFragmentBag:onExchangeBtnClick(sender)
	g_i3k_ui_mgr:OpenUI(eUIID_SpriteFragmentExchange)
	g_i3k_ui_mgr:RefreshUI(eUIID_SpriteFragmentExchange, self._fragmentData)
end

function wnd_spriteFragmentBag:onGetLianHuaBtnClick()
	local fragmentNum = g_i3k_game_context:GetSpiritsFragmentNum()
	if self._isInCD > 0 then 
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18617))
	end
	if fragmentNum < i3k_db_catch_spirit_base.spiritFragment.bagMaxCount then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18616, i3k_db_catch_spirit_base.spiritFragment.bagMaxCount)) --背包碎片个数不足
	end
	if g_i3k_game_context:GetSpiritsData().artificeTimes <= 0 then
		return g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18621))
	end

	if self._curRewardFragmentID > 0 then
		i3k_sbean.ghost_island_artifice( self._curRewardFragmentID)
	else
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(18616, i3k_db_catch_spirit_base.spiritFragment.bagMaxCount))
	end
end


function wnd_spriteFragmentBag:ShowItemTip(sender, id)
	g_i3k_ui_mgr:ShowCommonItemInfo(id)
end

function wnd_spriteFragmentBag:onLianHuaCompelte()
	g_i3k_ui_mgr:OpenUI(eUIID_UseItemGainItems)
	g_i3k_ui_mgr:RefreshUI(eUIID_UseItemGainItems, self._rewardList)
	self:showLianhuaBag()
end

function wnd_create(layout)
	local wnd = wnd_spriteFragmentBag.new()
	wnd:create(layout)
	return wnd
end
