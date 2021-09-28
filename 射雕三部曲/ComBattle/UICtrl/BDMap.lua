--[[
    filename: ComBattle.UICtrl.BDMap
    description: 战斗地图
    date: 2016.09.01

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local BDMap = class("BDMap", function()
    return display.newLayer()
end)


--[[
    mapFile = 地图文件名,
    battleLayer = battleLayer,
    time = 地图出现时间,
    callback = 回调函数,
    scroll 是否滚动
]]
function BDMap:ctor(params)
    if not params.mapFile and (not params.guider) then
        local default = {
            "zdcj_01.jpg",
            "zdcj_02.jpg",
            "zdcj_03.jpg",
            "zdcj_04.jpg",
            "zdcj_05.jpg",
            "zdcj_06.jpg",
            "zdcj_07.jpg",
            "zdcj_08.jpg",
            "zdcj_09.jpg",
            "zdcj_10.jpg",
        }
        params.mapFile = default[math.random(1, #default)]

        if g_editor_mode_hero_data then
            params.mapFile = "zdcj_09.jpg"
        end
    end
    if params.mapFile then
        local ef
        if bd.project == "project_shediao" then
            local jpg2effect = {
                ["zdcj_09.jpg"] = {"ui_effect_dugujianzhong"},
                ["zdcj_06.jpg"] = {"ui_effect_emeishan"},
                ["zdcj_05.jpg"] = {"ui_effect_guangmingding", true},
                ["zdcj_04.jpg"] = {"ui_effect_jiulounie", true},
                ["zdcj_07.jpg"] = {"ui_effect_jueqinggu", true},
                ["zdcj_03.jpg"] = {"ui_effect_shaolinsi", true},
                ["zdcj_10.jpg"] = {"ui_effect_taohuadao", true},
                ["zdcj_02.jpg"] = {"ui_effect_wudang", true},
                ["zdcj_01.jpg"] = {"ui_effect_xiangyangcheng", true},
                ["zdcj_08.jpg"] = {"ui_effect_yewangchunluojiaoye"},
            }
            local efFile = jpg2effect[params.mapFile]
            if efFile and cc.FileUtils:getInstance():isFileExist(efFile[1] .. ".skel") then
                ef = ui.newEffect({
                    effectName = efFile[1],
                    animation  = efFile[2] and "xia" or "animation",
                    loop       = true,
                })

                if efFile[2] then
                    bd.mapBuilding = ui.newEffect({
                        parent     = params.battleLayer.parentLayer,
                        effectName = efFile[1],
                        animation  = "shang",
                        zorder     = 1,
                        position   = cc.p(display.cx, display.cy),
                        scale      = bd.ui_config.MinScale,
                        loop       = true,
                    })
                end
            end
        end

        local sp = ef or cc.Sprite:create(params.mapFile)
        if sp then
            if params.x and params.y then
                sp:setPosition(params.x * bd.ui_config.AutoScaleX , params.y * bd.ui_config.AutoScaleX)
            else
                sp:setPosition(display.cx, display.cy)
            end
            sp:setScale(bd.ui_config.MinScale)
            self:addChild(sp)

            self.sprite = sp
        end

        if params.battleLayer.mapLayer then
            if params.scroll then
                local rect = self.sprite:getTextureRect()
                local tmpMap = params.battleLayer.mapLayer
                local rect1 = tmpMap.sprite:getTextureRect()
                local offset = rect.width/2 + (rect1.width - display.width) / 2 + display.cx
                tmpMap:runAction(cc.Sequence:create({
                    cc.MoveBy:create(params.time or 1 , cc.p(-offset , 0)),
                    cc.CallFunc:create(function( ... )
                        tmpMap:removeFromParent()

                        if params.callback then
                            params.callback()
                        end
                    end)
                }))
                self.sprite:setPosition(cc.p(offset + display.cx, display.cy))
                self.sprite:runAction(cc.Sequence:create({
                    cc.MoveBy:create(params.time or 1 , cc.p(-offset , 0))
                }))
            else
                local tmpMap = params.battleLayer.mapLayer
                tmpMap:runAction(cc.Sequence:create({
                    cc.FadeOut:create(params.time or 0.5),
                    cc.CallFunc:create(function( ... )
                        tmpMap:removeFromParent()

                        if params.callback then
                            params.callback()
                        end
                    end)
                }))
                self.sprite:setOpacity(0)
                self.sprite:runAction(cc.Sequence:create({
                    cc.FadeIn:create(params.time or 0.5)
                }))
            end
        else
            if params.callback then
                params.callback()
            end
        end

        params.battleLayer.mapLayer = self
        params.battleLayer.parentLayer:addChild(self, bd.ui_config.zOrderMap)
    end
end



return BDMap
