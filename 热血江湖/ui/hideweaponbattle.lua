-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_HideWeaponBattle = i3k_class("wnd_HideWeaponBattle", ui.wnd_base)

function wnd_HideWeaponBattle:ctor()
    self._timeCounter = 0
    self._timeLimit = 2 -- 0.5秒ui自动关闭
end

function wnd_HideWeaponBattle:configure()

end

function wnd_HideWeaponBattle:onShow()

end

function wnd_HideWeaponBattle:onUpdate(dTime)
    self._timeCounter = self._timeCounter  + dTime
    if self._timeCounter > self._timeLimit then
        self:onCloseUI()
    end
end

-- type 类型1攻击者 2是受击者
function wnd_HideWeaponBattle:refresh(anqiID, type, curSkin)
    self:setInfo(anqiID, type, curSkin)
    self._timeCounter = 0
end

function wnd_HideWeaponBattle:setInfo(anqiID, type, curSkin)
    local widgets = self._layout.vars
    local cfg  = i3k_db_anqi_base[anqiID]
    local skillID = cfg.skillID
	local skill_data = i3k_db_skills[skillID]
    -- widgets.icon:setImage(g_i3k_db.i3k_db_get_icon_path(skill_data.icon))
    -- widgets.cover:setImage()
    -- local typeName = type == 1 and "释放" or "受到"
    -- widgets.label:setText(cfg.name)

    local isUse = type == 1
    self:setAnqiNameImg(anqiID, isUse, curSkin)
    self:playAnis(isUse)
end

function wnd_HideWeaponBattle:getAnqiTipsCfg(anqiID, isUse, curSkin)
    local anqiCfg = i3k_db_anqi_base[anqiID]
    if curSkin ~= 0 then
        anqiCfg = g_i3k_db.i3k_db_get_anqi_skin_by_skinID(curSkin)
    end
    local varName = isUse and "useTipID" or "atTipID"

    local tipID = anqiCfg[varName]
    return i3k_db_anqi_tips[tipID]
end

function wnd_HideWeaponBattle:setAnqiNameImg(anqiID, isUse, curSkin)
    local tipCfg = self:getAnqiTipsCfg(anqiID, isUse, curSkin)
    local widgets = self._layout.vars
    for i = 1, 5 do
        local icon = g_i3k_db.i3k_db_get_icon_path(tipCfg.textImgs[i])
        widgets["name"..i]:setImage(icon)
        widgets["z"..i]:setImage(icon)
        widgets["zi"..i]:setImage(icon)
    end
    local icon = g_i3k_db.i3k_db_get_icon_path(tipCfg.bg)
    widgets.bg:setImage(icon)
end


function wnd_HideWeaponBattle:playAnis(isUse)
    if isUse then
        self._layout.anis.c_shifang.play()
    else
        self._layout.anis.c_shouji.play()
    end
end



function wnd_create(layout, ...)
	local wnd = wnd_HideWeaponBattle.new()
	wnd:create(layout, ...)
	return wnd;
end
