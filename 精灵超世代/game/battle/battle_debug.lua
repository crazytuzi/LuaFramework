----------------------------------------------------
---- 战斗调试
---- @author whjing2011@gmail.com
------------------------------------------------------
local BATTLE_DEBUG = true
if not BATTLE_DEBUG then return end
BattleDebug = BattleDebug or BaseClass(BaseController)

function BattleDebug:registerEvents()
    GlobalEvent:getInstance():Bind(BattleEvent.BATTLE_DEBUG, function()
        self:open()
    end)
end

function BattleDebug:open()
    local layer = ccui.Layout:create()
    local main_size = cc.size(SCREEN_WIDTH, SCREEN_HEIGHT)
	layer:setContentSize(main_size)
	-- layer:setAnchorPoint(cc.p(0.5, 0.5))
	layer:setPosition(display.getLeft(layer), display.getBottom(layer))
    BattleController:getInstance():getModel():getBattleScene():addChild(layer, 1000)
    layer:setVisible(true)
    local draw = cc.DrawNode:create()
    layer:addChild(draw)
    local linecolor1 = cc.c4f(0, 0, 0.8, 0.8)
    local linecolor2 = cc.c4f(1, 0, 0.8, 0.8)
    local max_grid = 80
    local grid_w = gridSizeX()
    local grid_h = gridSizeY()
    local labels = {}
    local roles = BattleController:getInstance():getModel().all_object
    Debug.log("========", max_grid, grid_w, grid_h)
   
    local width,height =  display.getScreenWH(layer)
    for i = 1, max_grid do
        if i % 10 == 0 then
            draw:drawLine(cc.p(i*grid_w,0), cc.p(i*grid_w,height), linecolor2)
            draw:drawLine(cc.p(0,i*grid_h), cc.p(width, i*grid_h), linecolor2)
        else
            draw:drawLine(cc.p(i*grid_w,0), cc.p( i*grid_w,height), linecolor1)
            draw:drawLine(cc.p(0, i*grid_h), cc.p(width, i*grid_h), linecolor1)
        end
    end
    local color = cc.c4f(0,1,0,1)
    local pos_fun = function(pos, type)
        local label = cc.Label:createWithSystemFont(pos, DEFAULT_FONT, 16)
        labels[pos] = label
        local v 
        for _, r in pairs(roles) do
            if r.pos == pos and r.obj_type == type then
                v = r
            end
        end
        if v then
            label:setString(pos.."_"..v.object_name)
        end
        local pos = SkillAct.newPos2Gird(1,pos, type == BattleTypeConf.TYPE_ROLE)
        pos = gridPosToScreenPos(pos)
        draw:drawSolidRect(pos, cc.p(pos.x+grid_w, pos.y + grid_h), color)
        -- label:setTextColor(cc.c4b(255,0,0,255))
        -- draw:addChild(label)
        -- label:setPosition(pos)
    end
    for i=1,9 do
        pos_fun(i,BattleTypeConf.TYPE_ROLE)
        pos_fun(i,BattleTypeConf.TYPE_ENEMY)
    end
end
