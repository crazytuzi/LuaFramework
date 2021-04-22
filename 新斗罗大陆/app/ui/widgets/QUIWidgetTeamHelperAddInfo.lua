

-- @Author: qinsiyang
-- @Date:   2020-02-13 11:25:37

local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetTeamHelperAddInfo = class("QUIWidgetTeamHelperAddInfo", QUIWidget)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIViewController = import("..QUIViewController")
local QColorLabel = import("...utils.QColorLabel")




local DESC_TEXT1 = {
    "1.援助魂师可以提供自身各项能力的25%给每个主力魂师。",
    "2.援助魂师不可以直接参与战斗，但是每个队伍可以选择2个援助魂师在战斗中释放魂技，每个援助魂技只能释放一次。",
    "3.援助魂师的全部战力，计入战队总战力。",
    "4.战队等级达到60级和75级时开启第一队的援助1和援助2。战队等级达到70和80时开启第二队的援助1和援助2。",
    "5.所有援助魂师pvp属性总和的25%会转化为主力pvp属性，给主力魂师增加",
}
local DESC_TEXT2 = {
    "1.援助魂师可以提供自身各项能力的25%给每个主力和替补魂师。",
    "2.援助魂师不可以直接参与战斗，7人模式内没有援助技能。",
    "3.援助魂师的全部战力，计入战队总战力。",
    "4.替补魂师上阵时会根据替补的位置，获得初始怒气，分别是750,900,1000",
}

local DESC_TEXT3 = {
    "1.主力魂师可以提供自身各项能力的25%给每个替补魂师增加。",
    "2.援助魂师给主力加成的属性不会再给替补魂师增加。",
    "3.在云顶之战：传承的玩法内，替补魂师上阵不会获得怒气。",
}

local DESC_TEXT4 = {
    "1.援助魂师可以提供自身各项能力的25%给每个主力魂师。",
    "2.援助魂师的全部战力，计入战队总战力。",
}

local DESC_TEXT5 = {
    "1.云顶之战均衡玩法内，所有主力和替补的属性的总和除以主力和替补的人数，平均分配给每个出战魂师。",
    "2.魂师的魂技技能(除了增加属性的技能)，真身技能，觉醒技能以及身上穿戴的暗器技能，魂灵技能不变。",
    "3.均衡玩法内，主力不会给替补增加属性，替补也不会获得额外怒气。"
}

local DESC_TEXT6 = {
    "1.援助魂师可以提供自身各项能力的25%给每个主力魂师。",
    "2.援助魂师不可以直接参与战斗，但是选择1个援助魂师在战斗中释放魂技，援助魂技只能释放一次。",
    "3.援助魂师的全部战力，计入战队总战力。",
    "3.最多可以上阵4个援助魂师。",
}


function QUIWidgetTeamHelperAddInfo:ctor(options)
	local ccbFile = "ccb/Widget_add_buff.ccbi"
    local callBacks = {
    }
    QUIWidgetTeamHelperAddInfo.super.ctor(self, ccbFile, callBacks, options)
  
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

end

function QUIWidgetTeamHelperAddInfo:setInfo(options)
  	self._isCollegeTeam = options.isCollegeTeam or false
    self._chapterId = options.chapterId
    self._isMockBattle = options.isMockBattle or false
    self._ccbOwner.tf_rule:setString("援助加成规则：")
    self._ccbOwner.tf_empty:setString("当前没有援助魂师上阵")
    self._ccbOwner.tf_content:setString("每个主力魂师获得援助加成：")
    self._ccbOwner.node_content:setVisible(false)
    self._ccbOwner.tf_inherit_force:setVisible(false)
    self._ccbOwner.sp_inherit:setVisible(false)
    local helpTeam = {}
    local mainTeam = {}
    for _,acotrId in pairs(options.helpTeam1 or {}) do
        table.insert(helpTeam, acotrId)
    end
    for _,acotrId in pairs(options.helpTeam2 or {}) do
        table.insert(helpTeam, acotrId)
    end
    for _,acotrId in pairs(options.helpTeam3 or {}) do
        table.insert(helpTeam, acotrId)
    end

    for _,acotrId in pairs(options.mainTeam or {}) do
        table.insert(mainTeam, acotrId)
    end

    if #helpTeam == 0 and not options.isEquilibrium then
    	self._ccbOwner.node_empty:setVisible(true)
    	self._ccbOwner.node_have:setVisible(false)
	else	
    	self._ccbOwner.node_empty:setVisible(false)
    	self._ccbOwner.node_have:setVisible(true)
  
        local prop = {hp_value = 1, attack_value = 2, armor_magic = 6, armor_physical = 5, hit_rating = 3, dodge_rating = 4, block_rating = 9, critical_rating = 10, haste_rating = 11, 
        physical_penetration_value = 7, magic_penetration_value = 8, cri_reduce_rating = 12, physical_damage_percent_attack = 13, physical_damage_percent_beattack_reduce = 14, 
        magic_damage_percent_attack = 15, magic_damage_percent_beattack_reduce = 16,soul_damage_percent_attack = 17,soul_damage_percent_beattack_reduce = 18}

        local scale_value = 0.25
        local map = remote.herosUtil:getUiPropMapByTeams(prop,helpTeam,scale_value,{isCollegeTeam = self._isCollegeTeam , chapterId = self._chapterId , isMockBattle = self._isMockBattle})
        QPrintTable(map)
        local mainMap = remote.herosUtil:getUiPropMapByTeams(prop,mainTeam,1,{isCollegeTeam = self._isCollegeTeam, chapterId = self._chapterId })
        local mainTeamHeroNum = #mainTeam
        if options.isEquilibrium and options.temHeroNum > 0 then
            local allProp = {}
            for type_,prop_mod in pairs(map) do
                local index_ = prop[type_]
                if allProp[index_] == nil then
                    allProp[index_] = {}
                end
                allProp[index_].name = prop_mod.name
                allProp[index_].value_str = (tonumber(prop_mod.value_str) or 0) * mainTeamHeroNum
                allProp[index_].percent_value_str = (tonumber(prop_mod.percent_value_str) or 0) * mainTeamHeroNum
            end

            if next(map) == nil then
                for type_,prop_mod in pairs(mainMap) do
                    local index_ = prop[type_]
                    if allProp[index_] == nil then
                        allProp[index_] = {}
                    end
                    allProp[index_].name = prop_mod.name
                    allProp[index_].value_str = tonumber(prop_mod.value_str) or 0
                    allProp[index_].percent_value_str = tonumber(prop_mod.percent_value_str) or 0
                end                
            else
                for type_,prop_mod in pairs(mainMap) do
                    local index_ = prop[type_]
                    if allProp[index_] then
                        allProp[index_].value_str = tonumber(allProp[index_].value_str) + (tonumber(prop_mod.value_str) or 0)
                        allProp[index_].percent_value_str = tonumber(allProp[index_].percent_value_str) + (tonumber(prop_mod.percent_value_str) or 0)
                    end
                end
            end
            for index_,prop_mod in pairs(allProp) do   
                self._ccbOwner["tf_name_"..index_]:setString(prop_mod.name)
                if prop_mod.percent_value_str and tonumber(prop_mod.percent_value_str) > 0 then
                    local value = tonumber(prop_mod.percent_value_str) or 0
                    value = (value * 100) / options.temHeroNum
                    local _,pos1 = string.find(value,"[(0-9)]*.")
                    local pos2 = string.len(tostring(value))
                    pos1 = pos1 or 0
                    pos2 = pos2 or 1
                    local f = pos2-pos1
                    if f < 1 then
                        f = 1
                    elseif f > 1 then
                        f = 2
                    end                    
                    local strAverageValue = string.format("%0."..f.."f%%", value)
                    self._ccbOwner["tf_value_"..index_]:setString("+"..strAverageValue)                    
                else
                    local value = tonumber(prop_mod.value_str) or 0
                    local averageValue = math.floor(value/options.temHeroNum)
                    self._ccbOwner["tf_value_"..index_]:setString("+"..averageValue)
                end
            end            
        else
            for type_,prop_mod in pairs(map) do
                local index_ = prop[type_]        
                self._ccbOwner["tf_name_"..index_]:setString(prop_mod.name)
                self._ccbOwner["tf_value_"..index_]:setString("+"..prop_mod.value_str)
            end
        end


        local map1 = remote.herosUtil:getUiPVPPropMapByTeams(helpTeam,{isCollegeTeam = self._isCollegeTeam , chapterId = self._chapterId , isMockBattle = self._isMockBattle})
		-- local prop_index = {pvp_physical_damage_percent_beattack_reduce = 1,pvp_physical_damage_percent_attack = 2 ,pvp_magic_damage_percent_beattack_reduce = 3
		-- ,pvp_magic_damage_percent_attack = 4}

        local prop_index = {"pvp_physical_damage_percent_attack","pvp_physical_damage_percent_beattack_reduce","pvp_magic_damage_percent_attack","pvp_magic_damage_percent_beattack_reduce"}
		for i,v in ipairs(prop_index) do
			local num = map1[v] or 0
			self._ccbOwner["tf_pvp_value_"..i]:setString("+"..string.format("%0.1f%%", tonumber(num)*100))
		end
     
    end


    local textDesc = DESC_TEXT1
    if options.isAlternate then
        textDesc = DESC_TEXT2
    end
    if self._isCollegeTeam then
        textDesc = DESC_TEXT4
    end
    if options.isInherit then
        self._ccbOwner.tf_rule:setString("传承规则：")
        textDesc = DESC_TEXT3
        if options.inheritForce and options.inheritForce > 0 then
            self._ccbOwner.tf_empty:setString("当前没有可传承的魂师上阵")
            self:showInheritPower( math.floor(options.inheritForce))
        else
            self._ccbOwner.tf_empty:setString("替补位没有可传承的魂师上阵")
            self._ccbOwner.node_empty:setVisible(true)
            self._ccbOwner.node_have:setVisible(false)
        end
    end

    if options.isEquilibrium then
        self._isEquilibrium = true
        self._ccbOwner.tf_rule:setString("均衡规则：")
        textDesc = DESC_TEXT5
        if options.equilibriumForce and options.equilibriumForce > 0 then
            self._ccbOwner.tf_empty:setString("当前没有可均衡的魂师上阵")
            self:showInheritPower( options.equilibriumForce )
        else
            self._ccbOwner.tf_empty:setString("替补位没有可均衡的魂师上阵")
            self._ccbOwner.node_empty:setVisible(true)
            self._ccbOwner.node_have:setVisible(false)
        end        
    end
    if self._isMockBattle then
        self._ccbOwner.tf_rule:setString("大师模拟战援助加成规则:")
        textDesc = DESC_TEXT6
    end

    local height = 0
    for i, text in pairs(textDesc) do
        local text = QColorLabel:create(text, 756, nil, nil, 20, GAME_COLOR_LIGHT.normal)
        text:setAnchorPoint(ccp(0, 1))
        text:setPositionY(-height)
        self._ccbOwner.node_desc:addChild(text)
        height = height + text:getContentSize().height+5
    end
    self._height  = 320 + height
end

function QUIWidgetTeamHelperAddInfo:showInheritPower(force)
    local fontColor = EQUIPMENT_COLOR[2]
    if self._isEquilibrium then
        self._ccbOwner.tf_content:setString("均衡战力")
        fontColor = EQUIPMENT_COLOR[3]

    else
        self._ccbOwner.tf_content:setString("传承战力")
        self._ccbOwner.sp_inherit:setVisible(true)
    end
    self._ccbOwner.tf_inherit_force:setVisible(true)

    local force, unit = q.convertLargerNumber(force)
    self._ccbOwner.tf_inherit_force:setString(force..(unit or ""))
    self._ccbOwner.tf_inherit_force:setPositionX(self._ccbOwner.tf_content:getPositionX() + self._ccbOwner.tf_content:getContentSize().width + 10)
    self._ccbOwner.sp_inherit:setPositionX(self._ccbOwner.tf_inherit_force:getPositionX() + self._ccbOwner.tf_inherit_force:getContentSize().width + 20)
   
        
    self._ccbOwner.tf_inherit_force:setColor(fontColor)
    self._ccbOwner.tf_inherit_force = setShadowByFontColor(self._ccbOwner.tf_inherit_force, fontColor) 

end


function QUIWidgetTeamHelperAddInfo:onEnter()
end

function QUIWidgetTeamHelperAddInfo:onExit()
end

function QUIWidgetTeamHelperAddInfo:getContentSize()
	return CCSize(780, self._height)
end

return QUIWidgetTeamHelperAddInfo
