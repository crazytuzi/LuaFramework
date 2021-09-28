local SkillPreview = class("SkillPreview",require ("src/TabViewLayer"))
--define
local tag_button = 10--因为本tag的节点是加在本layer下的node中，因此出于代码简洁度和耦合度低的考虑，没有必要对本tag在全局进行声明
local width_between_slider = 15
local button_width = 275--219
local cell_width = (button_width + width_between_slider * 2)
local cell_height = 105
local margin_top_buttom = 8
local background_height = 436
local label_toLeft = 93
local tag_skillDetailContent = 456
local tag_breakShieldSkill_shieldEff = 789
local tag_monster_summoned = 1000003

--test case begin
--fake data for test
--[[
G_ROLE_MAIN = {skills = {
    {2000}, {3000}
}}
ROLE_SCHOOL = 123
MRoleStruct = {
    getAttr = function(attr_type)
        return 2
    end
}
MRoleStruct:getAttr(ROLE_SCHOOL)
]]
--test case end

function SkillPreview:ctor(skill_id)
    self.bg = createBgSprite(self, game.getStrByKey("skillPreview"))
    --test code begin:
    --以后需要改成可配置
    --self.skillTable = require("src/config/SkillPreviewCfg")
    --有重复技能
    self.skillTable = {}
    for k, v in pairs(require("src/config/SkillCfg")) do
        if v.job == MRoleStruct:getAttr(ROLE_SCHOOL) then
            table.insert(self.skillTable, v)
        end
    end
    --test code end
    self.selectIdx = -1
    self.num = #self.skillTable
    self:createTableView(self.bg, cc.size(cell_width, background_height - margin_top_buttom * 2), cc.p(25 + margin_top_buttom - width_between_slider, margin_top_buttom + 105), true, true)
    local distance_arrow_to_table_view = 8
    local bgsize = self:getContentSize()
    self.m_upBtn = createTouchItem(
        self
        , "res/group/arrows/19.png"
        , cc.p(
            self:getTableView():getPositionX() + self:getTableView():getViewSize().width / 2
            , self:getTableView():getPositionY() + self:getTableView():getViewSize().height + distance_arrow_to_table_view
        )
        , function()
            --点击向上按钮事件
        end
    )
    self.m_upBtn:setRotation(-90)
    self.m_upBtn:setVisible(false)
	self.m_upBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, 5)), cc.MoveBy:create(0.3, cc.p(0, - 5)))))
	self.m_downBtn = createTouchItem(
        self
        , "res/group/arrows/19.png"
        , cc.p(
            self:getTableView():getPositionX() + self:getTableView():getViewSize().width / 2
            , self:getTableView():getPositionY() - distance_arrow_to_table_view
        )
        , function()
            --点击向下按钮事件
        end
    )
    self.m_downBtn:setRotation(90)
    self.m_downBtn:setVisible(self:getTableView():getContentSize().height > self:getTableView():getViewSize().height)
	self.m_downBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(0, - 5)), cc.MoveBy:create(0.3, cc.p(0, 5)))))
    --self:showSkill(self.skillTable[self.selectIdx + 1].skillID)   --只会由导航进入，初始不显示预览技能
    --导航至对应技能
    --点击对应技能
    local target_kind_index
    for kind_index, v in ipairs(self.skillTable) do
        if(v.skillID == skill_id) then
            target_kind_index = kind_index
            break
        end
    end
    local max_offset = math.max(0, self:getTableView():getViewSize().height - self:getTableView():getContentSize().height)
    self:getTableView():setContentOffset({x = 0, y = math.min(max_offset, self:getTableView():getViewSize().height - self:getTableView():getContentSize().height + (target_kind_index - 1) * cell_height)})
    self:tableCellTouched(
        self:getTableView()
        , self:getTableView():cellAtIndex(target_kind_index - 1)
    )
end

function SkillPreview:scrollViewDidScroll(view)
    if not (self.m_upBtn and self.m_downBtn) then
        return
    end
	local tableTemp = self:getTableView()
	local contentPos = tableTemp:getContentOffset()
    if tableTemp:getContentSize().height <= tableTemp:getViewSize().height then
        self.m_upBtn:setVisible(false)
		self.m_downBtn:setVisible(false)
	elseif contentPos.y >= 0 then
		self.m_upBtn:setVisible(true)
		self.m_downBtn:setVisible(false)
    elseif contentPos.y <=  -(tableTemp:getContentSize().height - tableTemp:getViewSize().height) then
		self.m_downBtn:setVisible(true)
		self.m_upBtn:setVisible(false)
	else
		self.m_downBtn:setVisible(true)
		self.m_upBtn:setVisible(true)
	end
end

function SkillPreview:cellSizeForTable(table,idx)
    return cell_height, cell_width
end

function SkillPreview:numberOfCellsInTableView(table)
    return self.num
end

function SkillPreview:tableCellTouched(table, cell)
    local index = cell:getIdx()
    local num = index + 1
    if self.selectIdx == index or not self:isVisible() then
        return
    end
    AudioEnginer.playTouchPointEffect()
    local old_cell = table:cellAtIndex(self.selectIdx)
    if old_cell then
        local button = tolua.cast(old_cell:getChildByTag(tag_button),"cc.Sprite")
        button:setTexture("res/common/table/cell36.png")
    end
    local button = cell:getChildByTag(tag_button)
    button:setTexture("res/common/table/cell36_sel.png")
    self:showSkill(self.skillTable[num].skillID)
    self.selectIdx = index
end

local createRole = function(sex, dir, yifu, weapon, wing)
	local animateRole1 = UISpriteCharacter:create("role/" .. yifu)
	animateRole1:setType(20+sex)
	animateRole1:initStandStatus(4, 6, 1, 7)
	-- 翅膀
	if wing ~= nil then
		local subSprite = SpriteBase:create("wing/" .. wing)
		subSprite:setType(6)
		subSprite:initStandStatus(4, 6, 1, 7)
		subSprite:setLocalZOrder(9)
		animateRole1:insertActionChild(subSprite)
	end
	-- 武器
	if weapon ~= nil then
		subSprite = SpriteBase:create("weapon/" .. weapon)
		subSprite:setType(2)
		subSprite:initStandStatus(4, 6, 1, 7)
		subSprite:setLocalZOrder(11)
		animateRole1:insertActionChild(subSprite)
	end
	animateRole1:setSpriteDir(dir)
    animateRole1:insertBloodNode(82)
    animateRole1:setMaxHP(900)
    animateRole1:setHP(900)
    animateRole1:setSpeed(0.215)    --默认的人物移动速度是0.215
	return animateRole1
end

function SkillPreview:showSkill(skill_id)
    --清理界面
    while self:getChildByTag(tag_skillDetailContent) do
        self:removeChildByTag(tag_skillDetailContent)
    end
    while self.bg:getChildByTag(tag_skillDetailContent) do
        self.bg:removeChildByTag(tag_skillDetailContent)
    end
    --获取技能必要信息
    local school = MRoleStruct:getAttr(ROLE_SCHOOL)
    local skill_info = getConfigItemByKey("SkillCfg", "skillID", skill_id)
    local skill_learned = nil
    for k, v in pairs(G_ROLE_MAIN.skills) do
        if v[1] >= 1000 and skill_id == v[1] then
            skill_learned = v
            break
        end
    end
    local skill_level = skill_learned and skill_learned[2] or 1
    --技能说明
    local pos_x_left, pos_x_right = 311, 545
    local label_font_size = 18
    local line_height = 22
    local richTextSize_width = 600
    local pos_y_current_line = 123
    local richText_skillDescCurrentLevel = require("src/RichText").new(self.bg, cc.p(pos_x_left, pos_y_current_line), cc.size(richTextSize_width, line_height), cc.p(0, 0.5), line_height, label_font_size, MColor.drop_white)
    richText_skillDescCurrentLevel:setTag(tag_skillDetailContent)
    richText_skillDescCurrentLevel:setAutoWidth()
    richText_skillDescCurrentLevel:addText(
        "^c(lable_yellow)" .. game.getStrByKey("skillDesc") .. ":^"
        .. getConfigItemByKey("SkillLevelCfg","skillID", skill_id * 1000 + skill_level).desc
    )
    richText_skillDescCurrentLevel:format()
    --技能获取方法按钮
    if not skill_learned then
        local btn_learnWay = createTouchItem(self.bg, "res/component/button/50.png", cc.p(836, 75), function()
		    local propid = skill_info.bookDesc
		    if propid then
			    local Mtips = require "src/layers/bag/tips"
			    Mtips.new(
			    {
				    protoId = propid,
				    pos = cc.p(display.cx,display.cy),
				    actions = actions,
				    contrast = true,
			    })
		    else
			    local needLv = skill_info.learnLv or 4
			    TIPS( {str = string.format(getConfigItemByKeys("clientmsg",{"sth","mid"},{ 3000 , 8 }).msg, needLv)})
		    end
	    end, true)
	    createLabel(btn_learnWay, game.getStrByKey("getWay"), cc.p(btn_learnWay:getContentSize().width / 2, btn_learnWay:getContentSize().height / 2), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.lable_yellow)
        btn_learnWay:setTag(tag_skillDetailContent)
    end
    --技能演示动画
    local clipNode = cc.ClippingNode:create()
    clipNode:setTag(tag_skillDetailContent)
	clipNode:setPosition(cc.p(0, 0))
    self:addChild(clipNode)
    local bg = createSprite(clipNode, "res/layers/skill/skillPreviewBg.jpg", cc.p(display.cx + 160, display.cy - 30))
    local stencil1 = cc.Sprite:create("res/layers/skill/skillPreviewBg.jpg")
    stencil1:setScaleX(0.25)
    stencil1:setScaleY(0.275)
    stencil1:setAnchorPoint(cc.p(0.5, 0.5))
    stencil1:setPosition(cc.p(display.cx + 140, display.cy + 20))
    clipNode:setStencil(stencil1)
    clipNode:setAlphaThreshold(0)
    local mapview = UIMapView:create()  --默认100 X 100
	local tempPos = mapview:tile2Space(cc.p(50, 50))
	mapview:setPosition(cc.p(- tempPos.x + display.width / 2, - tempPos.y + display.height / 2))    --先向左下偏移到左下角对齐地图中心位置，然后再把地图中心位置(50, 50)移到屏幕中心
	clipNode:addChild(mapview, 100)
    local whichTypeSkill = 0
    local whichAction = 1
    local tmpRootD = CMagicCtrlMgr:getInstance():GetMagicRootD3(skill_id)
    if tmpRootD >= 0 then
        whichAction = tmpRootD % 10;
        whichTypeSkill = math.floor(tmpRootD / 10)
    end
    print("skill id: " .. skill_id)
    --技能分类(根据技能效果来设计演示剧本:召唤，AOE，治疗，加盾减伤,转移伤害到宝宝等):
    --0.普通攻击

    --1.单体攻击类技能
    if
        --战士
        skill_id == 1002  -- '攻杀剑术'
        or skill_id == 1003  -- '刺杀剑术'
        or skill_id == 1006  -- '烈火剑法'
        or skill_id == 1102  -- '强化攻杀'
        --法师
        or skill_id == 2002  -- '雷电术'
        or skill_id == 2202  -- '强化火球'
        or skill_id == 2038  -- '狂龙紫电'
        --道士
        or skill_id == 3033  -- '灵魂道符'
        or skill_id == 3040  -- '幽冥火咒'
        then
        --UIMapView没有区分itemNode与dressNode，设置人物层级为99990, 高于所有地表技能的层级(如火墙), 低于skill_node层级
        local roleId_1 = 1000001
        local roleId_2 = 1000002
	    -- 角色1
        local animateRole1 = createRole(
            1
            , 7
            , (school == 1 and 5010511 or (school == 2 and 5020510 or 5030510)) + 100000 * 2    --  resource_id + 2 男性
            , school == 1 and 5010107 or (school == 2 and 5020105 or 5030106)
            , 2 + 100000
        )
        mapview:GetItemRoot():addChild(animateRole1, 99990, roleId_1)
	    tempPos = mapview:tile2Space(cc.p(51, 51))
        animateRole1:setPosition(tempPos)
        animateRole1:standed()
	    -- 角色2
        local animateRole2 = createRole(1, 5, 5110504, 5010104, 100002)
        mapview:GetItemRoot():addChild(animateRole2, 99990, roleId_2)
	    tempPos = mapview:tile2Space(cc.p(56, 51))
        animateRole2:setPosition(tempPos)
        animateRole2:standed()
        if school == 1 then
            --人物位置，如果是战士的普通技能，就拉近攻击方和被攻击方
            tempPos = mapview:tile2Space(cc.p(51 + 2, 51))
            animateRole1:setPosition(tempPos)
	        tempPos = mapview:tile2Space(cc.p(56 - 1, 51))
            animateRole2:setPosition(tempPos)
        end
	    schedule(mapview, function()
            --人物施法/攻击动作
            if whichAction == 1 then
                animateRole1:playAction(0.4, 3, 0, 1)
            elseif whichAction == 2 then
                animateRole1:playAction(0.4, 7, 0, 1)
            end
            CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, roleId_1, roleId_2, 0, mapview)
            --伤害
            local luaEventMgr = LuaEventManager:instance()
	        local buffer = luaEventMgr:getLuaEvent(3002)
            protobuf.encode("SkillHurtProtocol"
            , {
                roleId = roleId_1
	            , hurts = {
                    {
                        id = roleId_2
	                    , now = math.max(animateRole2:getHP() - 100, 0)
	                    , crit = false
	                    , hurt = 100
	                    , hurtResistType = nil
	                    , clearbuffs = {}
	                    , buffID = nil
                    }
                }
            }, function(buf, len)
                buffer:pushData(buf, len)
            end)
            mapview:onShowHurt(buffer)
	    end, 1.5)
        return
    end
    --2.AOE
    if
        --战士
        skill_id == 1004  -- '抱月刀'
        --法师
        or skill_id == 2033  -- '地狱雷光'
        then
        --AOE演示人物站位,一个人站中间,3个人站周围
	    -- 角色1
        local roleId_1 = 1000001
        local animateRole1 = createRole(
            1
            , 7
            , (school == 1 and 5010511 or (school == 2 and 5020510 or 5030510)) + 100000 * 2    --  resource_id + 2 男性
            , school == 1 and 5010107 or (school == 2 and 5020105 or 5030106)
            , 2 + 100000
        )
        mapview:GetItemRoot():addChild(animateRole1, 99990, roleId_1)
        animateRole1:setPosition(mapview:tile2Space(cc.p(51 + 2, 51)))
        animateRole1:standed()
	    -- 角色2
        local roleId_2 = 1000002
        local animateRole2 = createRole(1, 5, 5110504, 5010104, 100002)
        mapview:GetItemRoot():addChild(animateRole2, 99990, roleId_2)
	    tempPos = mapview:tile2Space(cc.p(56, 51))
        animateRole2:setPosition(mapview:tile2Space(cc.p(56 - 1, 51)))
        animateRole2:standed()
        local roleId_3 = 1000003
        local animateRole3 = createRole(1, 5, 5110504, 5010104, 100002)
        mapview:GetItemRoot():addChild(animateRole3, 99989, roleId_3)
	    tempPos = mapview:tile2Space(cc.p(51 + 3, 49))
        animateRole3:setPosition(tempPos)
        animateRole3:standed()
        local roleId_4 = 1000004
        local animateRole4 = createRole(1, 5, 5110504, 5010104, 100002)
        mapview:GetItemRoot():addChild(animateRole4, 99991, roleId_4)
	    tempPos = mapview:tile2Space(cc.p(51 + 3, 52))
        animateRole4:setPosition(tempPos)
        animateRole4:standed()
	    schedule(mapview, function()
            --人物施法/攻击动作
            if whichAction == 1 then
                animateRole1:playAction(0.4, 3, 0, 1)
            elseif whichAction == 2 then
                animateRole1:playAction(0.4, 7, 0, 1)
            end
            CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, roleId_1, roleId_2, 0, mapview)
            --伤害
            local luaEventMgr = LuaEventManager:instance()
	        local buffer = luaEventMgr:getLuaEvent(3002)
            protobuf.encode("SkillHurtProtocol"
            , {
                roleId = roleId_1
	            , hurts = {
                    {
                        id = roleId_2
	                    , now = math.max(animateRole2:getHP() - 100, 0)
	                    , crit = false
	                    , hurt = 100
	                    , hurtResistType = nil
	                    , clearbuffs = {}
	                    , buffID = nil
                    }
                    , {
                        id = roleId_3
	                    , now = math.max(animateRole2:getHP() - 100, 0)
	                    , crit = false
	                    , hurt = 100
	                    , hurtResistType = nil
	                    , clearbuffs = {}
	                    , buffID = nil
                    }
                    , {
                        id = roleId_4
	                    , now = math.max(animateRole2:getHP() - 100, 0)
	                    , crit = false
	                    , hurt = 100
	                    , hurtResistType = nil
	                    , clearbuffs = {}
	                    , buffID = nil
                    }
                }
            }, function(buf, len)
                buffer:pushData(buf, len)
            end)
            mapview:onShowHurt(buffer)
	    end, 1.5)
        return
    end
    --3.推人技能
    if
        --战士
        skill_id == 1005  -- '野蛮冲撞'
        or skill_id == 1010  -- '突斩'
        --法师
        or skill_id == 2005  -- '抗拒火环'
        --道士
        or skill_id == 3009  -- '狮子吼'
        then
        local roleId_1 = 1000001
        local roleId_2 = 1000002
        --local createRole = function(sex, dir, yifu, weapon, wing)
	    -- 角色1
        local animateRole1 = createRole(
            1
            , 7
            , (school == 1 and 5010511 or (school == 2 and 5020510 or 5030510)) + 100000 * 2    --  resource_id + 2 男性
            , school == 1 and 5010107 or (school == 2 and 5020105 or 5030106)
            , 2 + 100000
        )
        --UIMapView没有区分itemNode与dressNode，设置人物层级为99990, 高于所有地表技能的层级(如火墙), 低于skill_node层级
        mapview:GetItemRoot():addChild(animateRole1, 99990, roleId_1)
        animateRole1:standed()
	    -- 角色2
        local animateRole2 = createRole(1, 5, 5110504, 5010104, 100002)
        mapview:GetItemRoot():addChild(animateRole2, 99990, roleId_2)
        animateRole2:standed()
        --人物位置，推人技能要两人站一起
        animateRole1:setPosition(mapview:tile2Space(cc.p(51 + 2, 51)))
        animateRole2:setPosition(mapview:tile2Space(cc.p(56 - 1, 51)))
        mapview:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.CallFunc:create(function()
                --人物归位
                animateRole1:setPosition(mapview:tile2Space(cc.p(51 + 2, 51)))
                animateRole1:standed()
                animateRole2:setPosition(mapview:tile2Space(cc.p(56 - 1, 51)))
	            animateRole2:standed()
            end)
            , cc.DelayTime:create(0.5)
            , cc.CallFunc:create(function()
                --人物施法/攻击动作
                if whichAction == 1 then
                    animateRole1:playAction(0.4, 3, 0, 1)
                elseif whichAction == 2 then
                    animateRole1:playAction(0.4, 7, 0, 1)
                end
	            local crashDistance = 3	--推移距离
                --冲撞
                mapview:onCrash(skill_id, roleId_1, roleId_2, 51 + 2 + 1 + crashDistance, 51, 56 - 1, 51, 56 - 1 + crashDistance, 51)
                --突斩有伤害
                --野蛮冲撞无,抗拒火环，狮子吼无伤害
                if skill_id ~= 1010 then
                    return
                end
                local luaEventMgr = LuaEventManager:instance()
	            local buffer = luaEventMgr:getLuaEvent(3002)
                protobuf.encode("SkillHurtProtocol"
                , {
                    roleId = roleId_1
	                , hurts = {
                        {
                            id = roleId_2
	                        , now = math.max(animateRole2:getHP() - 100, 0)
	                        , crit = false
	                        , hurt = 100
	                        , hurtResistType = nil
	                        , clearbuffs = {}
	                        , buffID = nil
                        }
                    }
                }, function(buf, len)
                    buffer:pushData(buf, len)
                end)
                mapview:onShowHurt(buffer)
            end)
            , cc.DelayTime:create(2.5)
        )))
        return
    end
    --4.破盾技能
    if
        --战士
        skill_id == 1009    --破盾斩
    then
        local roleId_1 = 1000001
        local roleId_2 = 1000002
        --local createRole = function(sex, dir, yifu, weapon, wing)
	    -- 角色1
        local animateRole1 = createRole(
            1
            , 7
            , (school == 1 and 5010511 or (school == 2 and 5020510 or 5030510)) + 100000 * 2    --  resource_id + 2 男性
            , school == 1 and 5010107 or (school == 2 and 5020105 or 5030106)
            , 2 + 100000
        )
        mapview:GetItemRoot():addChild(animateRole1, 99990, roleId_1)
        animateRole1:standed()
	    -- 角色2
        local animateRole2 = createRole(1, 5, 5110504, 5010104, 100002)
        mapview:GetItemRoot():addChild(animateRole2, 99990, roleId_2)
        animateRole2:standed()
        animateRole1:setPosition(mapview:tile2Space(cc.p(51 + 2, 51)))
        animateRole2:setPosition(mapview:tile2Space(cc.p(56 - 1, 51)))
        clipNode:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.DelayTime:create(2)
                    , cc.CallFunc:create(function()
                        --破盾，先加上魔法盾
                        local buff_effect_node = animateRole2:getBuffSkillNode()
		                --BUFF特效放在人身上前面
                        local order = 999990000
                        buff_effect_node:setLocalZOrder(order - order % 10000 + skill_id)
                        -- 调用C++接口
                        local skillEffect = CMagicCtrlMgr:getInstance():CreatePichesMagic(2004, 0, mapview)
                        buff_effect_node:addChild(skillEffect)
                        skillEffect:setLocalZOrder(20)
                        skillEffect:setTag(tag_breakShieldSkill_shieldEff)
                    end)
                    , cc.DelayTime:create(1)
                    , cc.CallFunc:create(function()
                        --破盾斩
                        animateRole1:playAction(0.4, 3, 0, 1)
                        CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, roleId_1, roleId_2, 0, mapview)
                        CMagicCtrlMgr:getInstance():CreateMagic(1, 0, roleId_1, roleId_2, 0, mapview)
                        self:runAction(
                            cc.Sequence:create(
                                cc.DelayTime:create(0.5)
                                , cc.CallFunc:create(function()
                                    animateRole2:getBuffSkillNode():removeChildByTag(tag_breakShieldSkill_shieldEff)
                                end)
                            )
                        )
                    end)
                )
            )
        )
        return
    end
    --5.加盾技能
    if
        --战士
        skill_id == 1008    --金刚护体
        --法师
        or skill_id == 2004    --魔法盾
        or skill_id == 2009    --风影盾
        --道士
        or skill_id == 3006    --神圣战甲术
    then
        local roleId_1 = 1000001
        local roleId_2 = 1000002
	    -- 角色1
        local animateRole1 = createRole(1, 7, 5110504, 5010104, 100002)
        mapview:GetItemRoot():addChild(animateRole1, 99990, roleId_1)
        animateRole1:standed()
	    -- 角色2
        local animateRole2 = createRole(
            1
            , 5
            , (school == 1 and 5010511 or (school == 2 and 5020510 or 5030510)) + 100000 * 2    --  resource_id + 2 男性
            , school == 1 and 5010107 or (school == 2 and 5020105 or 5030106)
            , 2 + 100000
        )
        mapview:GetItemRoot():addChild(animateRole2, 99990, roleId_2)
        animateRole2:standed()
        animateRole1:setPosition(mapview:tile2Space(cc.p(51 + 2, 51)))
        animateRole2:setPosition(mapview:tile2Space(cc.p(56 - 1, 51)))
        --一开始没盾，砍一刀看效果，然后加盾，再砍一刀，出现减伤,miss等
        clipNode:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.DelayTime:create(2)
                    , cc.CallFunc:create(function()
                        --盾消失
                        animateRole2:getBuffSkillNode():removeChildByTag(tag_breakShieldSkill_shieldEff)
                    end)
                    , cc.DelayTime:create(1)
                    , cc.CallFunc:create(function()
                        --加盾以后的效果
                        animateRole1:playAction(0.4, 3, 0, 1)
                        local luaEventMgr = LuaEventManager:instance()
	                    local buffer = luaEventMgr:getLuaEvent(3002)
                        protobuf.encode("SkillHurtProtocol"
                        , {
                            roleId = roleId_1
	                        , hurts = {
                                {
                                    id = roleId_2
	                                , now = math.max(animateRole2:getHP() - 200, 0)
	                                , crit = false
	                                , hurt = 200
	                                , hurtResistType = nil
	                                , clearbuffs = {}
	                                , buffID = nil
                                }
                            }
                        }, function(buf, len)
                            buffer:pushData(buf, len)
                        end)
                        mapview:onShowHurt(buffer)
                    end)
                    , cc.DelayTime:create(2)
                    , cc.CallFunc:create(function()
                        if whichAction == 1 then
                            animateRole2:playAction(0.4, 3, 4, 1)
                        elseif whichAction == 2 then
                            animateRole2:playAction(0.4, 7, 4, 1)
                        end
                        local buff_effect_node = animateRole2:getBuffSkillNode()
		                --BUFF特效放在人身上前面
                        local order = 999990000
                        buff_effect_node:setLocalZOrder(order - order % 10000 + skill_id)
                        -- 调用C++接口
                        local skillEffect = CMagicCtrlMgr:getInstance():CreatePichesMagic(skill_id, 0, mapview)
                        buff_effect_node:addChild(skillEffect)
                        skillEffect:setLocalZOrder(20)
                        skillEffect:setTag(tag_breakShieldSkill_shieldEff)
                    end)
                    , cc.DelayTime:create(1.5)
                    , cc.CallFunc:create(function()
                        animateRole2:standed()
                        --加盾以后的效果
                        animateRole1:playAction(0.4, 3, 0, 1)
                        local luaEventMgr = LuaEventManager:instance()
	                    local buffer = luaEventMgr:getLuaEvent(3002)
                        local damage = (
                        skill_id == 1008 and 160
                        or (
                        skill_id == 2004 and 140
                        or (
                        skill_id == 2009 and 0  --如果是风影盾，出现miss
                        or (
                        skill_id == 3006 and 170
                        ))))
                        protobuf.encode("SkillHurtProtocol"
                        , {
                            roleId = roleId_1
	                        , hurts = {
                                {
                                    id = roleId_2
	                                , now = math.max(animateRole2:getHP() - damage, 0)
	                                , crit = false
	                                , hurt = damage
	                                , hurtResistType = (skill_id == 2009 and 4 or nil)
	                                , clearbuffs = {}
	                                , buffID = nil
                                }
                            }
                        }, function(buf, len)
                            buffer:pushData(buf, len)
                        end)
                        mapview:onShowHurt(buffer)
                    end)
                )
            )
        )
        return
    end



    --[[
    type6	地表技能
战士：

法师：
5：火墙：A对B使用火墙，B脚底下出现火墙，B持续受到伤害
9：流星火雨：A对B使用火墙，B脚底下出现火墙，B持续受到伤害
道士：




type13	目标身上释放的AOE
法师：
6：冰咆哮：A对B使用冰咆哮，B周围还有C，B和C都受到伤害


type8
道士：
2：施毒术：A使用施毒术攻击B，B持续受到伤害
9：强化施毒：A使用施毒术攻击B，B持续受到伤害，伤害数值要比施毒术高



type9	召唤
道士：
3：骷髅召唤术：A使用骷髅召唤术，召唤出一个骷髅，A攻击B，骷髅也会攻击B，B受到伤害
8：召唤神兽：A使用召唤神兽，召唤出一个神兽，A攻击B，神兽也会攻击B，B受到伤害
11：强化骷髅：A使用强化骷髅，召唤出一个强化骷髅，A攻击B，强化骷髅也会攻击B，B受到伤害



type10	隐身
道士：
4：集体隐身术，A周围有怪物，怪物在攻击A，A使用集体隐身术后，怪物停止攻击A



type11	治愈
道士：
7：群体治愈术：A角色血量没满，A使用群体治愈术后，持续回血


type12	召唤+伤血
道士：
12：斗转星移：A攻击B，B受到200点伤害，B召唤出神兽，然后使用斗转星移，A攻击B，B受到180点伤害，神兽受到20点伤害
    ]]



    --[[


















    --破盾斩单独处理
    if skill_id == 1009 then
        clipNode:runAction(
            cc.RepeatForever:create(
                cc.Sequence:create(
                    cc.DelayTime:create(3)
                    , cc.CallFunc:create(function()
                        --破盾，先加上魔法盾
                        local buff_effect_node = animateRole2:getBuffSkillNode()
		                --BUFF特效放在人身上前面
                        local order = 999990000
                        buff_effect_node:setLocalZOrder(order - order % 10000 + skill_id)
                        -- 调用C++接口
                        local skillEffect = CMagicCtrlMgr:getInstance():CreatePichesMagic(2004, 0, mapview)
                        buff_effect_node:addChild(skillEffect)
                        skillEffect:setLocalZOrder(20)
                        skillEffect:setTag(tag_breakShieldSkill_shieldEff)
                    end)
                    , cc.DelayTime:create(1)
                    , cc.CallFunc:create(function()
                        --破盾斩
                        animateRole1:playAction(0.4, 3, 0, 1)
                        CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, roleId_1, roleId_2, 0, mapview)
                        CMagicCtrlMgr:getInstance():CreateMagic(1, 0, roleId_1, roleId_2, 0, mapview)
                        self:runAction(
                            cc.Sequence:create(
                                cc.DelayTime:create(0.5)
                                , cc.CallFunc:create(function()
                                    animateRole2:getBuffSkillNode():removeChildByTag(tag_breakShieldSkill_shieldEff)
                                end)
                            )
                        )
                    end)
                )
            )
        )
        return
    end
    --召唤神兽
    if skill_id == 3007 then
        clipNode:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1)
            , cc.CallFunc:create(function()
                animateRole1:playAction(0.4, 7, 0, 1)
                CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, roleId_1, roleId_1, 0, mapview)    --召唤技能 uOwnerID, uTargetID 都是施法者
                local monsterSummoned = UISpriteCharacter:create("20085")
	            monsterSummoned:setType(10) --10 = normal_monster
	            monsterSummoned:initStandStatus(4, 6, 1, 7)
                monsterSummoned:standed()
                mapview:GetItemRoot():addChild(monsterSummoned, 99999, tag_monster_summoned)
                monsterSummoned:setPosition(mapview:tile2Space(cc.p(53, 51)))
                --召唤神兽有特效
                local skill_effect = Effects:create(true)
				skill_effect:playActionData2("skill3007/begin",80,1,0)
				skill_effect:setPosition(cc.p(0,-30))
				skill_effect:setRenderMode(2)
				monsterSummoned:addChild(skill_effect,7)
            end)
            , cc.DelayTime:create(2)
            , cc.CallFunc:create(function()
                mapview:GetItemRoot():removeChildByTag(tag_monster_summoned)
            end)
        )))
        return
    end
    --召唤骷髅
    if skill_id == 3008 then
        clipNode:runAction(cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(1)
            , cc.CallFunc:create(function()
                animateRole1:playAction(0.4, 7, 0, 1)
                CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, roleId_1, roleId_1, 0, mapview)    --召唤技能 uOwnerID, uTargetID 都是施法者
                local monsterSummoned = UISpriteCharacter:create("20081")
	            monsterSummoned:setType(10) --10 = normal_monster
	            monsterSummoned:initStandStatus(4, 6, 1, 7)
                monsterSummoned:standed()
                mapview:GetItemRoot():addChild(monsterSummoned, 99999, tag_monster_summoned)
                monsterSummoned:setPosition(mapview:tile2Space(cc.p(53, 51)))
            end)
            , cc.DelayTime:create(2)
            , cc.CallFunc:create(function()
                mapview:GetItemRoot():removeChildByTag(tag_monster_summoned)
            end)
        )))
        return
    end
    local whichTypeSkill = 0
    local whichAction = 1
    local tmpRootD = CMagicCtrlMgr:getInstance():GetMagicRootD3(skill_id)
    if tmpRootD >= 0 then
        whichAction = tmpRootD % 10;
        whichTypeSkill = math.floor(tmpRootD / 10)
    end
	-- 释放技能
	local playSkill = function()
        --人物施法/攻击动作
        if whichAction == 1 then
            animateRole1:playAction(0.4, 3, 0, 1)
        elseif whichAction == 2 then
            animateRole1:playAction(0.4, 7, 0, 1)
        end
        -- 普通技能
        if whichTypeSkill == 0 then
            -- 流星火雨由两段组成 第一段为普通魔法
            if skill_id == 3001 then
                animateRole2:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.5)
                    , cc.CallFunc:create(function()
                        animateRole2:setOpacity(108)    --技能释放演示时间顺序需要问策划
                    end)
                ))
                CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, roleId_1, roleId_2, 0, mapview)
            elseif (skill_id == 2011) then
                CMagicCtrlMgr:getInstance():CreateMagic(2011, 0, roleId_1, roleId_2, 0, mapview)
                CMagicCtrlMgr:getInstance():CreateFloorMagic(3, 56, 51, 200000+2011, 0, mapview)
            else
                CMagicCtrlMgr:getInstance():CreateMagic(skill_id, 0, roleId_1, roleId_2, 0, mapview)
            end
        -- 位移技能
        elseif whichTypeSkill == 1 then
            animateRole1:setPosition(mapview:tile2Space(cc.p(51 + 2, 51)))
            animateRole1:standed()
            animateRole2:setPosition(mapview:tile2Space(cc.p(56 - 1, 51)))
	        animateRole2:standed()
	        local crashDistance = 3	--推移距离
            mapview:onCrash(skill_id, roleId_1, roleId_2, 51 + 2 + 1 + crashDistance, 51, 56 - 1, 51, 56 - 1 + crashDistance, 51)
        -- 地表技能
        elseif whichTypeSkill == 2 then
			CMagicCtrlMgr:getInstance():CreateFloorMagic(skill_id, 56, 51, 200000+skill_id, 0, mapview);
        -- buff 技能
        elseif whichTypeSkill == 3 then
            local buff_effect_node = animateRole1:getBuffSkillNode()
            if buff_effect_node then
                if 1 then
			        --BUFF特效放在人身上前面
                    local order = 999990000
                    buff_effect_node:setLocalZOrder(order - order % 10000 + skill_id)
                    local skill_effect_node = buff_effect_node:getChildByTag(skill_id)
                    if (skill_effect_node == nil) then
                        -- 调用C++接口
                        local skillEffect = CMagicCtrlMgr:getInstance():CreatePichesMagic(skill_id, 0, mapview);
                        if skillEffect then
                            -- print("CreatePichesMagic")
                            buff_effect_node:addChild(skillEffect)
                            skillEffect:setLocalZOrder(20)
                            skillEffect:setTag(skill_id)
                        end
                    end
                else
                    if (buff_effect_node:getChildByTag(skill_id)) then
                        buff_effect_node:removeChildByTag(skill_id)
                    end
                end
            end
        end

        local luaEventMgr = LuaEventManager:instance()
	    local buffer = luaEventMgr:getLuaEvent(3002)
        protobuf.encode("SkillHurtProtocol"
        , {
            roleId = roleId_1
	        , hurts = {
                {
                    id = roleId_2
	                , now = math.max(animateRole2:getHP() - 100, 0)
	                , crit = true
	                , hurt = 100
	                , hurtResistType = nil
	                , clearbuffs = {}
	                , buffID = nil
                }
            }
        }, function(buf, len)
            buffer:pushData(buf, len)
        end)
        mapview:onShowHurt(buffer)

	end
	schedule(mapview, playSkill, whichTypeSkill == 1 and 3 or 1.5)  --位移类技能需要等人物切换到stand模式以后再进行下一次攻击动作
    ]]
end

function SkillPreview:tableCellAtIndex(tb, idx)
    local cell = tb:dequeueCell()
    if nil == cell then
        cell = cc.TableViewCell:new()
    else 
        cell:removeAllChildren()
    end
    local button = createSprite(cell, "res/common/table/cell36.png", cc.p(cell_width / 2, cell_height / 2))
    button:setTag(tag_button)
    if idx == self.selectIdx then
        --如果重新加上删除的按钮,需要重新设置状态
        button:setTexture("res/common/table/cell36_sel.png")
    end
    local MpropOp = require("src/config/propOp")
    local tabTemp = self.skillTable
    local idx_lua = idx + 1
	local Mprop = require "src/layers/bag/prop"
	createLabel(button, self.skillTable[idx_lua].name, cc.p(label_toLeft, button:getContentSize().height / 2), cc.p(0, 0.5), 20, nil, nil, nil, MColor.yellow)
	return cell
end

return SkillPreview