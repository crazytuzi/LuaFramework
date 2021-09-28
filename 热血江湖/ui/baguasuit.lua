-------------------------------------------------------
module(..., package.seeall)
local require = require
--local ui = require("ui/base")
local ui = require("ui/profile")
-------------------------------------------------------
wnd_baguaSuit = i3k_class("wnd_baguaSuit", ui.wnd_profile)

function wnd_baguaSuit:ctor()
end

function wnd_baguaSuit:configure()
    self.ui = self._layout.vars
    self.ui.close:onClick(self, self.onCloseUI)

    ui_set_hero_model(
        self.ui.hero_module,
        i3k_game_get_player_hero(),
        g_i3k_game_context:GetWearEquips(),
        g_i3k_game_context:GetIsShwoFashion()
    )

    self.hero_module = self.ui.hero_module
    self.revolve = self.ui.revolve
    self.ui.revolve:onTouchEvent(self, self.onRotateBtn) --旋转模型
end

function wnd_baguaSuit:refresh()
    self.ui.suitScroll:removeAllChildren()
    local suitData = {}
    for i, v in ipairs(i3k_db_bagua_suit_prop) do
        suitData[v.id] = v
    end

    local result = {}
    for _, v in pairs(suitData) do
        table.insert(result, v)
    end

    table.sort(
        result,
        function(a, b)
            return a.id < b.id
        end
    )

    for i, v in pairs(result) do
        local item = require("ui/widgets/baguatzt2")()
        local haveCount = g_i3k_game_context:getBaguaCountBySuitId(v.id)
        item.vars.daw:setText(v.name .. "【" .. haveCount .. "/" .. v.needCnt .. "】")
        item.vars.daw:setTextColor(v.suitColor)
        item.suitId = v.id
        item.vars.btn:onClick(
            self,
            function()
                self:choseSuit(v.id)
            end
        )
        item.vars.rankIcon:setImage(g_i3k_db.i3k_db_get_icon_path(v.suitRankIcon))
        item.vars.icon:setImage(g_i3k_db.i3k_db_get_icon_path(v.suitIcon))
        self.ui.suitScroll:addItem(item)
    end

    self:choseSuit(result[1].id)
end

local function getAffixDataByPart(part, affixData)
    for i, v in ipairs(affixData) do
        if v.partId == part then
            return true
        end
    end
    return false
end

function wnd_baguaSuit:choseSuit(suitId)
    for i, v in ipairs(self.ui.suitScroll:getAllChildren()) do
        if v.suitId == suitId then
            v.vars.btn:stateToPressed()
        else
            v.vars.btn:stateToNormal()
        end
    end

    local affixData = g_i3k_game_context:getBaguaAffixBySuit(suitId)
    for i = 1, 8 do
        if getAffixDataByPart(i, affixData) then
            self.ui["equip" .. i]:setVisible(true)
            if g_i3k_game_context:getBaguaCountBySuitIdAndPartId(suitId,i) == 0 then
                self.ui["equip" .. i]:disableWithChildren()
            else
                self.ui["equip" .. i]:enableWithChildren()
            end
        else
            self.ui["equip" .. i]:setVisible(false)
        end
    end

    self.ui.propScroll:removeAllChildren()
    for _, v in ipairs(i3k_db_bagua_suit_prop) do
    	if v.id == suitId then
    		for i = 1, 3 do
    			if v["desc" .. i] ~= "" then
    				local ui = require("ui/widgets/baguatzt")()
    				if i == 1 then
    					ui.vars.daw:setText(string.format("%s件：", v.needCnt))
    					ui.vars.des2:setText(v["desc" .. i])
    				else
    					ui.vars.des2:setText(v["desc" .. i])
    				end
                    local count = g_i3k_game_context:getYilueUpTaoZhuangCount(v.id, g_i3k_game_context:GetBaguaYilue().changeSkills, g_i3k_game_context:getEquipDiagrams())
    				local newNeed = v.needCnt - count < 0 and 0 or v.needCnt - count 
                    if g_i3k_game_context:getBaguaCountBySuitId(v.id) >= newNeed then
	    				ui.vars.daw:setTextColor(g_i3k_get_green_color())
	    				ui.vars.des2:setTextColor(g_i3k_get_green_color())
	    			end
	    			self.ui.propScroll:addItem(ui)
    			end
    		end
    	end
    end
end

function wnd_create(layout, ...)
    local wnd = wnd_baguaSuit.new()
    wnd:create(layout, ...)
    return wnd
end
