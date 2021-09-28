-- 我的粮仓界面可复仇玩家的pageview item

local ArenaRobPageViewItem = class("ArenaRobPageViewItem", function ( ... )
	return CCSPageCellBase:create("ui_layout/arena_RobPageViewItem.json")
end)

local EnemyInfoLayer = require("app.scenes.arena.ArenaRobEnemyInfoLayer")

function ArenaRobPageViewItem:ctor( ... )
	-- self._nameLabel1 = self:getLabelByName("Label_Name_1")
	-- self._fValueLabel1 = self:getLabelByName("Label_Fight_Value_1")
	-- self._riceAmountLabel1 = self:getLabelByName("Label_Rice_Amount_1")

	-- self._nameLabel2 = self:getLabelByName("Label_Name_2")
	-- self._fValueLabel2 = self:getLabelByName("Label_Fight_Value_2")
	-- self._riceAmountLabel2 = self:getLabelByName("Label_Rice_Amount_2")

	-- self._nameLabel3 = self:getLabelByName("Label_Name_3")
	-- self._fValueLabel3 = self:getLabelByName("Label_Fight_Value_3")
	-- self._riceAmountLabel3 = self:getLabelByName("Label_Rice_Amount_3")

end


function ArenaRobPageViewItem:update( layer, enemiesList )
	if enemiesList == nil or #enemiesList == 0 then return end

	-- 先隐藏控件，该位置有玩家再显示
	for i=1, 3 do
		self:showWidgetByName("Panel_" .. i, false)
	end

	for i = 1, #enemiesList do
		self:showWidgetByName("Panel_" .. i, true)

		local user = enemiesList[i]

		local nameLabel = self:getLabelByName("Label_Name_" .. i)
		local fightValueLabel = self:getLabelByName("Label_Fight_Value_" .. i)
		local riceAmountLable = self:getLabelByName("Label_Rice_Amount_" .. i)

		nameLabel:createStroke(Colors.strokeBrown, 1)
		fightValueLabel:createStroke(Colors.strokeBrown, 1)
		riceAmountLable:createStroke(Colors.strokeBrown, 1)

		nameLabel:setText(user.name)
		fightValueLabel:setText(G_lang:get("LANG_ROB_RICE_FIGHT_VAULE_2", {num = GlobalFunc.ConvertNumToCharacter(user.fight_value)}))
		riceAmountLable:setText(G_lang:get("LANG_ROB_RICE_WIN_RICE_2", {num = math.floor(user.init_rice * 0.15)}))

		local knightPanel = self:getPanelByName("Panel_Knight_" .. i)

		local knightPic = require("app.scenes.common.KnightPic")
	    local knight = knight_info.get(user.base_id)
	    if not knight then
	        return
	    end

	    nameLabel:setColor(Colors.qualityColors[knight.quality])

	    if self._knightImageView ~= nil then
	        knightPanel:removeAllChildrenWithCleanup(true)
	    end 

        local res_id = G_Me.dressData:getDressedResidWithClidAndCltm(user.base_id, user.dress_base,  rawget(user,"clid"),rawget(user,"cltm"),rawget(user,"clop"))
        self._knightImageView = knightPic.createKnightButton(res_id, knightPanel, "" .. user.user_id .. user.id, layer, function()
            EnemyInfoLayer.show(user)
        end,true)

	    knightPanel:setScale(0.4)
	    local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
	    EffectSingleMoving.run(knightPanel, "smoving_idle", nil, {})

	end

end


-- 获取战力对应的颜色 TODO:写到Colors中？？
function ArenaRobPageViewItem:_getFightValueColor( fightValue )
	local fightValueClr = Colors.qualityColors[1]
        if fightValue < 100000 then
            fightValueClr = Colors.qualityColors[1]
        elseif fightValue < 500000 then
            fightValueClr = Colors.qualityColors[2]
        elseif fightValue < 1000000 then
            fightValueClr = Colors.qualityColors[3]
        elseif fightValue < 2000000 then
            fightValueClr = Colors.qualityColors[4]
        elseif fightValue < 4000000 then
            fightValueClr = Colors.qualityColors[5]
        elseif fightValue < 8000000 then
            fightValueClr = Colors.qualityColors[6]
        else
            fightValueClr = Colors.qualityColors[7]
        end
    return fightValueClr
end







return ArenaRobPageViewItem