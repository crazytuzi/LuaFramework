module(..., package.seeall)

local require = require;

local ui = require("ui/taskBase");
local BASE = ui.taskBase
-------------------------------------------------------
wnd_springBuff = i3k_class("wnd_springBuff", ui.taskBase)

function wnd_springBuff:ctor()
end

function wnd_springBuff:configure()
    BASE.configure(self)
end

function wnd_springBuff:refresh()
    local data = g_i3k_game_context:getSpringBuff()

    local springData = g_i3k_game_context:getSpringData()

    local sectBuff = data.sectBuff
    local serverBuff = data.serverBuff
    local doubleActBuff = data.doubleActBuff
    local fationBuff = data.fashionBuff

    local vars = self._layout.vars
	local expText = i3k_get_string(3152) .. i3k_get_string(3153, springData.addExp)
	local springData = g_i3k_game_context:getSpringData()
	if springData.weekEnterCnt > i3k_db_spring.common.weeklyEnter then
		expText = expText.." "..i3k_get_string(17288)
	end
    vars.totalExp:setText(expText)
    local total = 10000 +  sectBuff + serverBuff + doubleActBuff + fationBuff
    if total >= i3k_db_spring.common.expLimit then
        total = i3k_db_spring.common.expLimit
        vars.isMax:setVisible(true)
    else
        vars.isMax:setVisible(false)
    end
    vars.totalBuff:setText(i3k_get_string(3150) .. i3k_get_string(3151, total / 100))

    local scroll = vars.task_scroll
    scroll:removeAllChildren()

    --世界加成
    local item = require("ui/widgets/zdwenquant")()
    item.vars.desc:setText(i3k_get_string(3142) .. i3k_get_string(3143, serverBuff/100))
    scroll:addItem(item)

    --帮派加成
    local item = require("ui/widgets/zdwenquant")()
    item.vars.desc:setText(i3k_get_string(3144) .. i3k_get_string(3145,sectBuff/100))
    scroll:addItem(item)

    --时装加成
    local item = require("ui/widgets/zdwenquant")()
    item.vars.desc:setText(i3k_get_string(3148) .. i3k_get_string(3149, fationBuff/100))
    scroll:addItem(item)

	--双人交互加成
    local item = require("ui/widgets/zdwenquant")()
    item.vars.desc:setText(i3k_get_string(3146) .. i3k_get_string(3147, doubleActBuff/100))
    scroll:addItem(item)
end

-------------------------------------
function wnd_create(layout)
	local wnd = wnd_springBuff.new();
		wnd:create(layout);
	return wnd;
end
