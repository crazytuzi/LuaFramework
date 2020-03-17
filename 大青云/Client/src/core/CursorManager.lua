--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/20
-- Time: 14:54
--
_G.classlist['CCursorManager'] = 'CCursorManager'
_G.CCursorManager = CSingle:new();
_G.CCursorManager.objName = 'CCursorManager'
CSingleManager:AddSingle(CCursorManager);

CCursorManager.setCursorList = {};
CCursorManager.CurrCharCid = nil
CCursorManager.CurrCursor = nil

function CCursorManager:Create()
    _app:loadCursor("normal.cur", "normal")		-- 正常状态
    _app:loadCursor("battle.cur", "battle")		-- 指向敌方单位
    _app:loadCursor("lefttalk.cur", "dialog")		-- 跟npc交互   ‘左键对话’字样
    _app:loadCursor("pickup.cur", "pick")			-- 拾取物品    ‘左键拾取’字样
    _app:loadCursor("sold.cur", "sell")            --sold      ‘卖’字样
    _app.cursor = "normal"
    _app:loadCursor("cj.ani", "collect")           --collect   采集
    _app:loadCursor("battle.cur", "arenaAtk")      --battle    竞技场挑战按钮鼠标变化
	_app:loadCursor("hide.cur", "hide");
    return true
end;
--正常状态,nil代表返回到正常状态
function CCursorManager:Set(szStateName)
    if szStateName then
        _app.cursor = szStateName;
    else
        _app.cursor = "normal";
    end;
end;

function CCursorManager:GetCurState()
    return _app.cursor;
end;

---------------------------------------------------------------------
--显示列表，上面的优先级高于下面的
local arrShowList =
{
	"hide",
    "sell",
    "battle",
    "collect",
    "dialog",
    "pick",
    "normal",
    "arenaAtk",
}
--添加鼠标图标，允许同时有多个状态，但是只显示最高状态
function CCursorManager:AddState(szStateName)
    self.setCursorList[szStateName] = 1;

    self:CountCurrentState();
end;

function CCursorManager:DelState(szStateName)
    self.setCursorList[szStateName] = nil;

    self:CountCurrentState();

    self.CurrCharCid = nil
end;

function CCursorManager:ClearState()
    self.setCursorList = {};

    _app.cursor = "normal";

    self.CurrCharCid = nil
end;

function CCursorManager:CountCurrentState()
    local szShow = "normal";
    for n,str in pairs(arrShowList)do
        if self.setCursorList[str] then
            szShow = str;
            break;
        end
    end

    if _app.cursor ~= szShow then
        _app.cursor = szShow;
    end
end;

function CCursorManager:AddStateOnChar(stateName, cid)
    self.CurrCharCid = cid
    self.CurrCursor = stateName
    self:AddState(stateName)
end