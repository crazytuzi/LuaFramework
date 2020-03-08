

local tbGuideUI = Ui:CreateClass("RockerGuidePanel");
local TouchMgr = luanet.import_type("TouchMgr");

function tbGuideUI:OnOpen(nDelayTime)
    Operation.bForbidClickMap = true;
    TouchMgr.SetJoyStick(false);

    if me.GetDoing() == Npc.Doing.run then
        local pNpc = me.GetNpc();
        local nDir = pNpc.GetDir();
        me.GoDirection(nDir, 1);
    end
        
    nDelayTime = nDelayTime or 3;
    Timer:Register(nDelayTime, function ()
        TouchMgr.SetJoyStick(true);
    end)
end

function tbGuideUI:OnClose()
    Operation.bForbidClickMap = false;   
end    